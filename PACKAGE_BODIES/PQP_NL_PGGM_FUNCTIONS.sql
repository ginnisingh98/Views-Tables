--------------------------------------------------------
--  DDL for Package Body PQP_NL_PGGM_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_NL_PGGM_FUNCTIONS" AS
/* $Header: pqpnlpgg.pkb 120.18 2007/07/03 13:20:31 rsahai noship $ */

--
--Cursor to fetch the max. salary value beyond which
--the threshold is constant,from global values
--
CURSOR c_get_global_value(c_global_name IN VARCHAR2,c_date_earned IN DATE) IS
SELECT nvl(fnd_number.canonical_to_number(global_value),0)
  FROM ff_globals_f
WHERE  global_name = c_global_name
  AND  legislation_code = 'NL'
  AND  (c_date_earned between effective_start_date and effective_end_date);


CURSOR c_get_num_periods_per_year(c_payroll_action_id IN NUMBER)  IS
SELECT TPTYPE.number_per_fiscal_year
 FROM  pay_payroll_actions     PACTION
      ,per_time_periods        TPERIOD
      ,per_time_period_types   TPTYPE
WHERE PACTION.payroll_action_id   = c_payroll_action_id
  AND TPERIOD.payroll_id          = PACTION.payroll_id
  AND (PACTION.date_earned   between TPERIOD.start_date
                                and TPERIOD.end_date)
  AND TPTYPE.period_type          = TPERIOD.period_type;

--
-- ----------------------------------------------------------------------------
-- |------------------------< CHECK_ELIGIBILITY >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- This function is used to check if an employee is eligible to contribute
-- towards a particular pension type by verifying that the employee age
-- falls between the minimum and maximum ages for the pension type

FUNCTION CHECK_ELIGIBILITY
   (p_date_earned       IN  DATE
   ,p_business_group_id IN  NUMBER
   ,p_person_age        IN  NUMBER
   ,p_pension_type_id   IN  NUMBER
   ,p_eligible          OUT NOCOPY NUMBER
   ,p_err_message       OUT NOCOPY VARCHAR2)

RETURN NUMBER IS

--
--Cursor to fetch the min. and max. age specified at the pension type
--
CURSOR c_get_min_max_ages IS
SELECT nvl(minimum_age,0),nvl(maximum_age,100)
 FROM  pqp_pension_types_f
WHERE  pension_type_id = p_pension_type_id
  AND  p_date_earned BETWEEN effective_start_date
  AND  effective_end_date;

l_min_age   NUMBER := 0;
l_max_age   NUMBER := 100;
l_ret_value NUMBER := 0;
l_proc_name VARCHAR2(30) := 'CHECK_ELIGIBILITY';

BEGIN

hr_utility.set_location('Entering : '||g_pkg_name||l_proc_name,10);
--Query up the min. and max. age specified at the pension type

OPEN c_get_min_max_ages;
FETCH c_get_min_max_ages INTO l_min_age,l_max_age;

IF c_get_min_max_ages%FOUND THEN
   --the min and max ages have been found,now check for eligibility

   CLOSE c_get_min_max_ages;
   hr_utility.set_location('Min. and Max. ages are : '||l_min_age||
                           ' and '||l_max_age,20);

   IF p_person_age BETWEEN l_min_age and l_max_age THEN
      --the person is eligible for the pension type

      hr_utility.set_location('Person is eligible, age is : '||p_person_age,30);
      p_eligible := 1;

   ELSE
      --the person is not eligible for this pension type
      hr_utility.set_location('Person is not eligible, age is : '||p_person_age,30);
      p_err_message := 'This person is not eligible for the pension type';
      p_eligible := 0;
      l_ret_value := 2;

   END IF;

ELSE
   --no row could be found for this pension type
   CLOSE c_get_min_max_ages;
   hr_utility.set_location('No row could be found for this pension type',40);
   p_err_message := 'No row could be found for this pension type on this date';
   p_eligible := 0;
   l_ret_value := 2;

END IF;

hr_utility.set_location('Returning from : '||g_pkg_name||l_proc_name,50);

RETURN 0;

EXCEPTION
WHEN OTHERS THEN
   hr_utility.set_location('Exception occured in : '||g_pkg_name||l_proc_name,60);
   p_eligible := 0;
   p_err_message := 'Error occured when determining eligibility : '||SQLERRM;
   RETURN 1;

END CHECK_ELIGIBILITY;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< GET_CONTRIBUTION >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- This function is used to get the contribution percentage / flat amount from
-- the org hierarchy or from the pension types table if there is no override
-- at the org hierarchy level

FUNCTION GET_CONTRIBUTION
   (p_assignment_id     IN  NUMBER
   ,p_date_earned       IN  DATE
   ,p_business_group_id IN  NUMBER
   ,p_ee_or_total       IN  NUMBER
   ,p_pension_type_id   IN  NUMBER
   ,p_contrib_value     OUT NOCOPY NUMBER
   ,p_err_message       OUT NOCOPY VARCHAR2)

RETURN NUMBER IS

--
-- Cursor to fetch the org id for a given assignment id
--
CURSOR c_get_org_id IS
SELECT organization_id
  FROM per_all_assignments_f
WHERE  assignment_id = p_assignment_id
  AND  p_date_earned BETWEEN effective_start_date
  AND  effective_end_date;

--
-- Cursor to get the parent org id for a given organization
-- given the version id of the org hierarchy defined
--
CURSOR c_get_parent_id(c_org_id     IN NUMBER
                      ,c_version_id IN NUMBER) IS
SELECT organization_id_parent
  FROM per_org_structure_elements
WHERE  organization_id_child = c_org_id
  AND  org_structure_version_id = c_version_id
  AND  business_group_id = p_business_group_id;

--
-- Cursor to get the percentage value from the ORG EIT
--
CURSOR c_get_contrib_frm_org(c_org_id IN NUMBER) IS
SELECT decode(p_ee_or_total,0,nvl(fnd_number.canonical_to_number(org_information4),0)
             ,nvl(fnd_number.canonical_to_number(org_information5),0))
  FROM hr_organization_information
WHERE  org_information_context = 'PQP_NL_PGGM_PT'
  AND  organization_id = c_org_id
  AND  p_date_earned BETWEEN fnd_date.canonical_to_date(org_information1)
  AND  nvl(fnd_date.canonical_to_date(org_information2),hr_api.g_eot)
  AND  fnd_number.canonical_to_number(org_information3) = p_pension_type_id;

--
-- Cursor to get the percentage value from the pension types table
--
CURSOR c_get_contrib_frm_pt IS
SELECT decode(p_ee_or_total,0,nvl(ee_contribution_percent,0)
             ,nvl(er_contribution_percent,0))
  FROM pqp_pension_types_f
WHERE  pension_type_id = p_pension_type_id
  AND  p_date_earned BETWEEN effective_start_date
  AND  effective_end_date;

l_proc_name         VARCHAR2(30) := 'GET_CONTRIBUTION';
l_loop_again        NUMBER := 1;
l_emp_or_total      VARCHAR2(30) := 'Employee';
l_org_contrib_found NUMBER := 0;
l_ret_value         NUMBER := 0;
l_version_id        NUMBER;
l_org_id            NUMBER;
l_contrib_value     NUMBER := 0;


BEGIN

hr_utility.set_location('Entering : '||g_pkg_name||l_proc_name,10);
--First fetch the HR Org Id for the current assignment
OPEN c_get_org_id;
FETCH c_get_org_id INTO l_org_id;
CLOSE c_get_org_id;
hr_utility.set_location('Org Id for this assignment is : '||l_org_id,20);

-- Now fetch the contribution percentages from the ORG EIT
-- This will proceed in a loop from the HR Organization
-- of this assignment and then up the org the hierarchy until
-- we find a EIT row or the topmost parent is reached

IF p_ee_or_total = 0 THEN
   l_emp_or_total := 'Employee';
ELSE
   l_emp_or_total := 'Total';
END IF;
hr_utility.set_location('Now deriving contribution percentage for : '||l_emp_or_total,25);

--check to see if the version id is already present for this business group
IF NOT g_version_info.EXISTS(p_business_group_id) THEN
   --no cached value of the version id exists for this BG
   g_version_info(p_business_group_id).version_id
   := pqp_pension_functions.GET_VERSION_ID(p_business_group_id
                                          ,p_date_earned);

END IF;

l_version_id := g_version_info(p_business_group_id).version_id;
hr_utility.set_location('Org Hierarchy version id : '||l_version_id,27);

WHILE (l_loop_again = 1)
LOOP
   OPEN c_get_contrib_frm_org(l_org_id);
   FETCH c_get_contrib_frm_org INTO l_contrib_value;

   IF c_get_contrib_frm_org%FOUND THEN
      --Contribution percentages have been found at this org
      hr_utility.set_location('Contribution values found at org : '||l_org_id,30);
      CLOSE c_get_contrib_frm_org;

      p_contrib_value := fnd_number.canonical_to_number(l_contrib_value);

      --set the flag indicating that contribution percentage has been found at the
      --ORG level, so we dont need to continue any further
      l_org_contrib_found := 1;

      hr_utility.set_location('Contribution percentage is : '||p_contrib_value,40);
      --we no longer need to continue up the hierarchy
      l_loop_again := 0;

   ELSE
      --contribution percentages not found at this org, now move up the hierarchy
      --find the parent org for this current org
      CLOSE c_get_contrib_frm_org;
      OPEN c_get_parent_id(c_org_id     => l_org_id
                          ,c_version_id => l_version_id);
      FETCH c_get_parent_id INTO l_org_Id;

      IF c_get_parent_id%FOUND THEN
         --a parent org has been found,so we can loop again
         CLOSE c_get_parent_id;

      ELSE
         --no further parents exist,so exit the loop
         CLOSE c_get_parent_id;
         l_loop_again := 0;

         --set the flag indicating that org contributions
         --have not been found, so derive it from the Pension Type
         l_org_contrib_found := 0;

      END IF;

   END IF;

END LOOP;

--now check to see if the contribution percentage
--has been found at the ORG level or do we need to
--derive it from the pension type
IF l_org_contrib_found = 0 THEN
  hr_utility.set_location('No contribution values found at the org'||
                          ' ,now deriving it from the pension type',50);
  --contribution values have not been found at the ORG level
  --query up the contribution percentages from the pension type
  OPEN c_get_contrib_frm_pt;
  FETCH c_get_contrib_frm_pt INTO p_contrib_value;

  IF c_get_contrib_frm_pt%FOUND THEN
     --contribution percentages have been found from the pension type
     hr_utility.set_location('Contribution derived from pension type : '
                             ||p_contrib_value,60);
     CLOSE c_get_contrib_frm_pt;

  ELSE
     --no data has been found for this pension type, this is an error condition
     CLOSE c_get_contrib_frm_pt;
     hr_utility.set_location('No data could be found for the pension type on date earned',70);
     p_contrib_value := 0;
     p_err_message := 'No data could be found for the pension type attached to '
                     ||'this scheme on the date earned.';
     l_ret_value := 2;

  END IF;

END IF;

hr_utility.set_location('Returning from : '||g_pkg_name||l_proc_name,80);
RETURN l_ret_value;

EXCEPTION
WHEN OTHERS THEN
   hr_utility.set_location('Exception occured in : '||g_pkg_name||l_proc_name,90);
   p_contrib_value := 0;
   p_err_message := 'Error occured when determining contribution : '||SQLERRM;
   RETURN 1;

END GET_CONTRIBUTION;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< GET_AGE_DEPENDANT_THLD>--------------------------|
-- ----------------------------------------------------------------------------
--
-- This function is used to derive the age dependant threshold for an employee
-- based on his/her age from a user defined table

FUNCTION GET_AGE_DEPENDANT_THLD
   (p_person_age        IN  NUMBER
   ,p_business_group_id IN  NUMBER
   ,p_date_earned       IN  DATE)

RETURN NUMBER IS

--
--Cursor to fetch the maximum age for which thresholds are defined
--all ages above this value have the same threshold
--
CURSOR c_get_max_age IS
SELECT max(fnd_number.canonical_to_number(row_low_range_or_name))
  FROM pay_user_rows_f
WHERE  p_date_earned BETWEEN effective_start_date
  AND  effective_end_date
  AND  user_table_id = (SELECT user_table_id
                          FROM pay_user_tables
                        WHERE  user_table_name = 'PQP_NL_PGGM_AGE_DEPENDANT_THRESHOLD'
                          AND  legislation_code = 'NL'
                       );

l_proc_name            VARCHAR2(30) := 'GET_AGE_DEPENDANT_THLD';
l_return_value         pay_user_column_instances.value%TYPE;
l_value_found          NUMBER := 0;
l_threshold_percentage NUMBER := 0;
l_max_age              NUMBER;

BEGIN

hr_utility.set_location('Entering : '||g_pkg_name||l_proc_name,10);

--first check to see if the user defined table for age dependant
--thresholds has a row for the person's age, then return this value
BEGIN
hr_utility.set_location('Checking for threshold percentage for age : '||p_person_age,20);
l_return_value :=
               hruserdt.get_table_value
               (
                p_bus_group_id    => p_business_group_id
               ,p_table_name      => 'PQP_NL_PGGM_AGE_DEPENDANT_THRESHOLD'
               ,p_col_name        => 'Percentage Of Maximum Threshold'
               ,p_row_value       => p_person_age
               ,p_effective_date  => p_date_earned
               );

l_value_found := 1;
l_threshold_percentage := nvl(fnd_number.canonical_to_number(l_return_value),0);
hr_utility.set_location('Threshold percentage derived as : '||l_threshold_percentage,30);

EXCEPTION
WHEN NO_DATA_FOUND THEN
   l_value_found := 0;

END;

--if no value has been found for the person's age, find the maximum age
--for which values have been defined, if the person's age exceeds this age
--then the value applicable for the person is the same as the value defined
--for the maximum age
IF l_value_found = 0 THEN

   hr_utility.set_location('No row found for the person''s age,now finding max age',40);
   --query up the maximum age defined in the rows for this user defined tbl
   OPEN c_get_max_age;
   FETCH c_get_max_age INTO l_max_age;
   IF c_get_max_age%FOUND THEN

      --Found the maximum age upto which thresholds have been defined
      hr_utility.set_location('Max age in threshold udt : '||l_max_age,50);
      CLOSE c_get_max_age;

      --if the person's age is > the max age, then the threshold is the same
      --as the value defined for this max age
      IF p_person_age > l_max_age THEN

         BEGIN
         l_return_value :=
                        hruserdt.get_table_value
                        (
                         p_bus_group_id    => p_business_group_id
                        ,p_table_name      => 'PQP_NL_PGGM_AGE_DEPENDANT_THRESHOLD'
                        ,p_col_name        => 'Percentage Of Maximum Threshold'
                        ,p_row_value       => l_max_age
                        ,p_effective_date  => p_date_earned
                        );
         l_threshold_percentage := nvl(fnd_number.canonical_to_number(l_return_value),0);
         hr_utility.set_location('value of max age used : '||l_threshold_percentage,60);

         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_threshold_percentage := 0;
         END;

      --else the person's age is lesser than the max age and no row has been defined
      ELSE

         l_threshold_percentage := 0;

      END IF;

   --else no rows have been defined for the user defined table
   --so return the percentage as 0
   ELSE

      hr_utility.set_location('No rows were defined for the udt',70);
      CLOSE c_get_max_age;
      l_threshold_percentage := 0;

   END IF;

END IF;

hr_utility.set_location('Value of threshold percentage is : '||l_threshold_percentage,75);
hr_utility.set_location('Leaving : '||g_pkg_name||l_proc_name,80);

RETURN l_threshold_percentage;

EXCEPTION
WHEN OTHERS THEN
   hr_utility.set_location('Exception occured in : '||g_pkg_name||l_proc_name,90);
   RETURN 0;

END GET_AGE_DEPENDANT_THLD;

--=============================================================================
-- Function to get the age of a person given the effective date
--=============================================================================
FUNCTION Get_Age
         (p_assignment_id   IN  per_all_assignments_f.assignment_id%TYPE
         ,p_effective_date  IN  DATE
	 ,p_begin_of_year_date IN DATE)
RETURN NUMBER IS

CURSOR get_dob IS
SELECT trunc(date_of_birth)
  FROM per_all_people_f per
      ,per_all_assignments_f paf
 WHERE per.person_id      = paf.person_id
   AND paf.assignment_id  = p_assignment_id
   AND p_effective_date BETWEEN per.effective_start_date
                            AND per.effective_end_date
   AND p_effective_date BETWEEN paf.effective_start_date
                            AND paf.effective_end_date;

l_age NUMBER;
l_dob DATE;

BEGIN

--
--Fetch the date of birth
--
OPEN get_dob;
FETCH get_dob INTO l_dob;
CLOSE get_dob;

l_dob := NVL(l_dob,p_effective_date);

RETURN (TRUNC(MONTHS_BETWEEN(p_begin_of_year_date,l_dob)/12,2));

END Get_Age;


--
-- ----------------------------------------------------------------------------
-- |-------------------------< GET_PENSION_BASIS >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- This function is used to derive the pension basis value for a given pension
-- type based on the basis method defined

FUNCTION GET_PENSION_BASIS
   (
    p_payroll_action_id    IN  NUMBER
   ,p_date_earned          IN  DATE
   ,p_business_group_id    IN  NUMBER
   ,p_person_age           IN  NUMBER
   ,p_pension_type_id      IN  NUMBER
   ,p_pension_salary       IN  NUMBER
   ,p_part_time_percentage IN  NUMBER
   ,p_pension_basis        OUT NOCOPY NUMBER
   ,p_err_message          OUT NOCOPY VARCHAR2
   ,p_avlb_thld            IN  OUT NOCOPY NUMBER
   ,p_used_thld            IN  OUT NOCOPY NUMBER)

RETURN NUMBER IS

--
--Cursor to fetch the basis method from the pension type
--
CURSOR c_get_basis_method IS
SELECT pension_basis_calc_method
  FROM pqp_pension_types_f
WHERE  pension_type_id = p_pension_type_id
  AND  p_date_earned BETWEEN effective_start_date
  AND  effective_end_date;

l_proc_name            VARCHAR2(30) := 'GET_PENSION_BASIS';
l_ret_value            NUMBER := 0;
l_threshold_salary     NUMBER;
l_max_salary_threshold NUMBER;
l_max_age_threshold    NUMBER;
l_threshold            NUMBER;
l_threshold_percentage NUMBER;
l_avlb_thld            NUMBER := 0;
l_used_thld            NUMBER := 0;
l_basis_method         pqp_pension_types_f.pension_basis_calc_method%TYPE;
l_num_periods          NUMBER :=12;

BEGIN
--hr_utility.trace_on(null,'SS');
hr_utility.set_location('Entering : '||g_pkg_name||l_proc_name,10);

--first fetch the basis method for this pension type
OPEN c_get_basis_method;
FETCH c_get_basis_method INTO l_basis_method;
CLOSE c_get_basis_method;

--Get number of payroll periods in a year
OPEN c_get_num_periods_per_year(p_payroll_action_id);
FETCH c_get_num_periods_per_year INTO l_num_periods;
CLOSE c_get_num_periods_per_year;

--now calculate the basis value depending on the basis method
--derived above
IF l_basis_method = '6' THEN

   --basis method is (Pension Salary - Salary dependant threshold)
   -- * Part Time Percentage

   hr_utility.set_location('Basis method : '||'(Pension Salary - Salary threshold)'
                           ||' * Part Time %',20);

   --first derive the salary dependant threshold
   --query up the maximum salary
   OPEN c_get_global_value('PQP_NL_PGGM_THRESHOLD_SALARY',p_date_earned);
   FETCH c_get_global_value INTO l_threshold_salary;

   IF c_get_global_value%FOUND THEN
      CLOSE c_get_global_value;
      --the value for the threshold salary has been found
      hr_utility.set_location('PQP_NL_PGGM_THRESHOLD_SALARY : '||l_threshold_salary,25);

   ELSE
      CLOSE c_get_global_value;
      --the global value was not found,raise a warning
      hr_utility.set_location('PQP_NL_PGGM_THRESHOLD_SALARY not found',25);
      p_err_message := 'No value was found for the global PQP_NL_PGGM_THRESHOLD_SALARY';
      l_ret_value := 2;

   END IF;

   --query up the maximum salary dependant threshold
   OPEN c_get_global_value('PQP_NL_PGGM_MAX_SALARY_THRESHOLD',p_date_earned);
   FETCH c_get_global_value INTO l_max_salary_threshold;

   IF c_get_global_value%FOUND THEN
      CLOSE c_get_global_value;
      --the value for the salary threshold has been found
      hr_utility.set_location('PQP_NL_PGGM_MAX_SALARY_THRESHOLD : '||l_max_salary_threshold,26);

   ELSE
      CLOSE c_get_global_value;
      --the global value was not found,raise a warning
      hr_utility.set_location('PQP_NL_PGGM_MAX_SALARY_THRESHOLD not found',26);
      p_err_message := p_err_message || 'No value was found for the global'||
                      'PQP_NL_PGGM_MAX_SALARY_THRESHOLD';
      l_ret_value := 2;

   END IF;

   IF (p_date_earned < to_date('01-01-2006','DD-MM-YYYY'))THEN
      IF p_pension_salary >= l_threshold_salary THEN
         l_threshold := l_max_salary_threshold;
      ELSE
         l_threshold := (p_pension_salary * l_max_salary_threshold)/
                     (l_threshold_salary + 1);
      END IF;
   ELSE --Legislative year 2006 Change
        l_threshold := l_max_salary_threshold; -- 9566 fixed value
   END IF;

   hr_utility.set_location('Salary Dependant Threshold : '||l_threshold,30);

   p_pension_basis := (p_pension_salary - l_threshold)
                      * p_part_time_percentage/100;

   p_pension_basis := p_pension_basis / l_num_periods;

ELSIF l_basis_method = '7' THEN

   --basis method is Pension Salary * Part Time Percentage
   hr_utility.set_location('Basis method : '||'(Pension Salary * Part Time %)',20);
   p_pension_basis := p_pension_salary * p_part_time_percentage/100;

   p_pension_basis := p_pension_basis / l_num_periods;

ELSIF l_basis_method = '8' THEN

   --basis method is (Pension Salary * Part Time Percentage) -
   -- Age Dependant Threshold
   hr_utility.set_location('Basis method : '||'(Pension Salary * Part Time %)'
                           ||' - Age Threshold',20);

   --query up the maximum age dependant threshold
   OPEN c_get_global_value('PQP_NL_PGGM_MAX_AGE_THRESHOLD',p_date_earned);
   FETCH c_get_global_value INTO l_max_age_threshold;

   IF c_get_global_value%FOUND THEN
      CLOSE c_get_global_value;
      --the value for the age threshold has been found
      hr_utility.set_location('PQP_NL_PGGM_MAX_AGE_THRESHOLD : '||l_max_age_threshold,22);

   ELSE
      CLOSE c_get_global_value;
      --the global value was not found,raise a warning
      hr_utility.set_location('PQP_NL_PGGM_MAX_AGE_THRESHOLD not found',22);
      p_err_message := p_err_message || 'No value was found for the global'||
                      'PQP_NL_PGGM_MAX_AGE_THRESHOLD';
      l_ret_value := 2;

   END IF;

   l_threshold_percentage := GET_AGE_DEPENDANT_THLD(p_person_age        => p_person_age
                                                   ,p_business_group_id => p_business_group_id
                                                   ,p_date_earned       => p_date_earned);

   IF l_threshold_percentage = 0 THEN
      p_err_message := p_err_message ||' The age dependant threshold could not be '
                      ||'derived for this person and 0 will be used';
      l_ret_value := 2;
   END IF;

   --Calculate Age dependent Threshold value and drop the decimals
   l_threshold := trunc(l_max_age_threshold * l_threshold_percentage/100);

   hr_utility.set_location('Age Dependant Threshold : '||l_threshold,30);
   hr_utility.set_location('Available threshold : '||l_avlb_thld,30);
   hr_utility.set_location('Used Threshold : '||l_used_thld,30);

   l_avlb_thld := l_threshold/l_num_periods;

   l_threshold := GREATEST((p_avlb_thld + l_threshold/l_num_periods - p_used_thld),0);

   p_pension_basis := (p_pension_salary * p_part_time_percentage/100)/l_num_periods -
                      l_threshold;

   IF p_pension_basis < 0 THEN
      l_used_thld := (p_pension_salary * p_part_time_percentage/100)/l_num_periods;
   ELSE
      l_used_thld := l_threshold;
   END IF;

END IF;

/*
Bug 5215600
SR : 5461519.993
--if the calculated pension basis is < 0 then restrict it to 0
IF p_pension_basis < 0 THEN
   p_pension_basis := 0;
END IF;
*/
p_avlb_thld := l_avlb_thld;
p_used_thld := l_used_thld;

hr_utility.set_location('Calculated pension basis value : '||p_pension_basis,40);
hr_utility.set_location('Available threshold : '||l_avlb_thld,40);
hr_utility.set_location('Used Threshold : '||l_used_thld,40);

hr_utility.set_location('Leaving : '||g_pkg_name||l_proc_name,50);
--hr_utility.trace_off;

RETURN l_ret_value;

EXCEPTION
WHEN OTHERS THEN
   hr_utility.set_location('Exception occured in : '||g_pkg_name||l_proc_name,60);
   p_pension_basis := 0;
   p_err_message := 'Error occured while deriving the pension basis : '||SQLERRM;
   RETURN 1;

END GET_PENSION_BASIS;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< DO_PRORATION >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- This function is used to perform a calendar day proration of the deduction
-- amount for starter/leavers

FUNCTION DO_PRORATION
   (p_assignment_id        IN  NUMBER
   ,p_payroll_action_id    IN  NUMBER
   ,p_period_start_date    IN  DATE
   ,p_period_end_date      IN  DATE
   ,p_dedn_amount          IN  OUT NOCOPY NUMBER
   ,p_err_message          OUT NOCOPY VARCHAR2)

RETURN NUMBER IS

--
--Cursor to fetch the range of dates for which the assignment
--is active in the pay period
--
CURSOR c_get_asg_dates IS
SELECT asg.effective_start_date start_date
      ,nvl(asg.effective_end_date,p_period_end_date) end_date
 FROM  per_all_assignments_f asg,per_assignment_status_types past
WHERE  asg.assignment_id = p_assignment_id
  AND  asg.assignment_status_type_id = past.assignment_status_type_id
  AND  past.per_system_status = 'ACTIVE_ASSIGN'
  AND  asg.effective_start_date <= p_period_end_date
  AND  nvl(asg.effective_end_date,p_period_end_date)
       >= p_period_start_date;

--
--Cursor to fetch period type of payroll attached to assignment
--
CURSOR c_get_period_type(c_payroll_action_id IN NUMBER)
IS
SELECT TPERIOD.period_type
 FROM  pay_payroll_actions     PACTION
      ,per_time_periods        TPERIOD
 WHERE PACTION.payroll_action_id   = c_payroll_action_id
  AND TPERIOD.payroll_id          = PACTION.payroll_id
  AND (PACTION.date_earned   between TPERIOD.start_date
                                and TPERIOD.end_date);


c_asg_row c_get_asg_dates%ROWTYPE;

l_proc_name         VARCHAR2(30) := 'DO_PRORATION';
l_ret_value         NUMBER := 0;
l_start_date        DATE;
l_end_date          DATE;
l_days              NUMBER := 0;
l_payroll_days      NUMBER := 0;
l_non_insured_days  NUMBER := 0;
l_proration_factor  NUMBER := 1;
l_period_type       VARCHAR2(150);
l_num_of_days_in_period NUMBER:=30;

BEGIN

--first fetch the range of dates when the assignment is
--active in the pay period
hr_utility.set_location('Entering : '||g_pkg_name||l_proc_name,10);

OPEN c_get_period_type(p_payroll_action_id);
FETCH c_get_period_type INTO l_period_type;
CLOSE c_get_period_type;
 IF l_period_type='Calendar Month' THEN
    l_num_of_days_in_period:= 30;
 ELSE  IF l_period_type = 'Lunar Month' THEN
         l_num_of_days_in_period:=28;
       ELSE  IF l_period_type = 'Week' THEN
                l_num_of_days_in_period:=7;
             ELSE IF l_period_type = 'Quarter' THEN
                    l_num_of_days_in_period:=90;
                  END IF;
             END IF;
       END IF;
 END IF;

FOR c_asg_row IN c_get_asg_dates
LOOP
   --loop through all assignment rows effective in this pay period
   --and find the number of days the person is insured for
   IF c_asg_row.start_date < p_period_start_date THEN
      l_start_date := p_period_start_date;
   ELSE
      l_start_date := c_asg_row.start_date;
   END IF;

   IF c_asg_row.end_date > p_period_end_date THEN
      l_end_date := p_period_end_date;
   ELSE
      l_end_date := c_asg_row.end_date;
   END IF;

   l_days := l_days + (l_end_date - l_start_date) + 1;

END LOOP;

hr_utility.set_location('Assignment was active for : '||l_days||' days',20);

--now find the days the person was not insured for in this period
--first find the total number of days in this pay period

l_payroll_days := p_period_end_date - p_period_start_date + 1;
hr_utility.set_location('Days in pay period : '||l_payroll_days,30);

--the non insured days in the difference of the pay period days and
--the number of days the assignment has been active
--if the assignment has not been active any day in the pay period
--then the non insured days is taken as 30 to make the proration
--factor 0

IF l_days > 0 THEN
   l_non_insured_days := l_payroll_days - l_days;
ELSE
   l_non_insured_days := l_num_of_days_in_period;
   p_err_message := 'Assignment was not active in this pay period, so '||
                    'deduction amount is prorated as 0';
   l_ret_value := 2;
END IF;

hr_utility.set_location('Non insured days : '||l_non_insured_days,40);

--now derive the proration factor, the days in a pay period are
--taken as 30 for this purpose, so we need to first find the days the
--person has been insured for in the period, ie (30 - days not insured)
--the proration factor is then this number divided by 30

l_proration_factor := (l_num_of_days_in_period - l_non_insured_days) / l_num_of_days_in_period;
hr_utility.set_location('Proration factor is : '||l_proration_factor,50);

--now multiply the deduction amount with the proration factor to
--find the prorated amount
hr_utility.set_location('Original deduction amount : '||p_dedn_amount,60);

p_dedn_amount := p_dedn_amount * l_proration_factor;

hr_utility.set_location('Prorated deduction amount : '||p_dedn_amount,70);
hr_utility.set_location('Leaving : '||g_pkg_name||l_proc_name,80);

RETURN l_ret_value;

EXCEPTION
WHEN OTHERS THEN
   hr_utility.set_location('Exception occured in : '||g_pkg_name||l_proc_name,90);
   p_dedn_amount := 0;
   p_err_message := 'Error occured while prorating : '||SQLERRM;
   RETURN 1;

END DO_PRORATION;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< GET_GENERAL_INFO >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- This function is used to derive the general information such as holiday allowance
-- and end of year bonus percentage from the org extra information by traversing
-- the org hierarchy

FUNCTION GET_GENERAL_INFO
   (p_assignment_id     IN  NUMBER
   ,p_business_group_id IN  NUMBER
   ,p_date_earned       IN  DATE
   ,p_code              IN  NUMBER
   ,p_value             OUT NOCOPY NUMBER)

RETURN NUMBER IS

--
-- Cursor to fetch the org id for the current assignment
--
CURSOR c_get_org_id IS
SELECT organization_id
  FROM per_all_assignments_f
WHERE  assignment_id = p_assignment_id
  AND  p_date_earned BETWEEN effective_start_date
  AND  effective_end_date;

--
-- Cursor to fetch the parent id for a given organization id
-- for a particular hierarchy version id
--
CURSOR c_get_parent_id(c_org_id     IN NUMBER
                      ,c_version_id IN NUMBER) IS
SELECT organization_id_parent
  FROM per_org_structure_elements
WHERE  organization_id_child = c_org_id
  AND  org_structure_version_id = c_version_id
  AND  business_group_id = p_business_group_id;

--
-- Cursor to fetch the holiday allowance or eoy bonus
-- percentage from the relevant segment based on the
-- code passed in
-- Code 0 => Holiday Allowance Percentage
-- Code 1 => End Of Year Bonus Percentage
--
CURSOR c_get_general_info(c_org_id IN NUMBER) IS
SELECT decode(p_code,0,org_information3,1,org_information4)
  FROM hr_organization_information
WHERE  organization_id = c_org_id
  AND  org_information_context = 'PQP_NL_PGGM_INFO'
  AND  p_date_earned BETWEEN fnd_date.canonical_to_date(org_information1)
  AND  fnd_date.canonical_to_date(nvl(org_information2,fnd_date.date_to_canonical(hr_api.g_eot)))
  AND  decode(p_code,0,org_information3,1,org_information4) IS NOT NULL;

l_proc_name  VARCHAR2(30) := 'GET_GENERAL_INFO';
l_org_id     NUMBER;
l_value      hr_organization_information.org_information1%TYPE;
l_loop_again NUMBER := 1;
l_version_id NUMBER;

BEGIN
hr_utility.set_location('Entering : '||g_pkg_name||l_proc_name,10);

--initialise the percentage return value to 0
p_value := 0;

-- fetch the org id for the organization this assignment is attached to
OPEN c_get_org_id;
FETCH c_get_org_id INTO l_org_id;
IF c_get_org_id%NOTFOUND THEN
   --org id for the assignment could not be found
   --return 1 and a value of 0
   CLOSE c_get_org_id;
   p_value := 0;
   RETURN 1;
ELSE
   --org id was found
   CLOSE c_get_org_id;
   hr_utility.set_location('Org id for the ASG : '||l_org_id,20);

   -- now find the holiday allowance/eoy bonus percentage from the
   -- org extra information and by traversing the org hierarchy
   --check to see if the version id is already present for this business group

   IF NOT g_version_info.EXISTS(p_business_group_id) THEN
      --no cached value of the version id exists for this BG
      g_version_info(p_business_group_id).version_id
      := pqp_pension_functions.GET_VERSION_ID(p_business_group_id
                                             ,p_date_earned);

   END IF;

   l_version_id := g_version_info(p_business_group_id).version_id;
   hr_utility.set_location('Org Hierarchy version id : '||l_version_id,30);

   WHILE (l_loop_again = 1)
   LOOP
      OPEN c_get_general_info(l_org_id);
      FETCH c_get_general_info INTO l_value;

      IF c_get_general_info%FOUND THEN
         --holiday allowance /eoy bonus percentages have been found at this org
         hr_utility.set_location('Percentages found at org : '||l_org_id,40);
         CLOSE c_get_general_info;

         p_value := fnd_number.canonical_to_number(l_value);

         hr_utility.set_location('Percentage is : '||p_value,50);
         --we no longer need to continue up the hierarchy
         l_loop_again := 0;

      ELSE
         -- percentages not found at this org, now move up the hierarchy
         --find the parent org for this current org
         CLOSE c_get_general_info;
         OPEN c_get_parent_id(c_org_id     => l_org_id
                             ,c_version_id => l_version_id);
         FETCH c_get_parent_id INTO l_org_Id;

         IF c_get_parent_id%FOUND THEN
            --a parent org has been found,so we can loop again
            CLOSE c_get_parent_id;

         ELSE
            --no further parents exist,so exit the loop
            CLOSE c_get_parent_id;
            l_loop_again := 0;

            -- no value has been found , so set it to 0
            p_value := 0;

         END IF;

      END IF;

   END LOOP;

END IF;

hr_utility.set_location('Percentage value : '||p_value,55);
hr_utility.set_location('Leaving : '||g_pkg_name||l_proc_name,60);

RETURN 0;

EXCEPTION
WHEN OTHERS THEN
   hr_utility.set_location('Exception occured in : '||g_pkg_name||l_proc_name,70);
   p_value := 0;
   RETURN 1;

END GET_GENERAL_INFO;


-- ----------------------------------------------------------------------------
-- |------------------------<GET_PENSION_SALARY >------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION GET_PENSION_SALARY
         (p_assignment_id        IN  NUMBER
         ,p_date_earned          IN  DATE
         ,p_business_group_id    IN  NUMBER
         ,p_payroll_id           IN  NUMBER
         ,p_period_start_date    IN  DATE
         ,p_period_end_date      IN  DATE
         ,p_scale_salary         IN  NUMBER
         ,p_scale_salary_h       IN  NUMBER
         ,p_scale_salary_e       IN  NUMBER
         ,p_ft_rec_payments      IN  NUMBER
         ,p_ft_rec_payments_h    IN  NUMBER
         ,p_ft_rec_payments_e    IN  NUMBER
         ,p_pt_rec_payments      IN  NUMBER
         ,p_pt_rec_payments_h    IN  NUMBER
         ,p_pt_rec_payments_e    IN  NUMBER
         ,p_salary_balance_value OUT NOCOPY NUMBER
         ,p_err_message          OUT NOCOPY VARCHAR2
         ,p_err_message1         OUT NOCOPY VARCHAR2
         ,p_err_message2         OUT NOCOPY VARCHAR2
         )
RETURN NUMBER IS

--
-- Cursor to get the hire date of the person
--
CURSOR c_hire_dt_cur(c_asg_id IN NUMBER) IS
SELECT max(date_start)
 FROM  per_all_assignments_f asg
      ,per_periods_of_service pps
WHERE  pps.person_id     = asg.person_id
  AND  asg.assignment_id = c_asg_id
  AND  pps.business_group_id = p_business_group_id
  AND  date_start <= p_date_earned;

--
--Cursor to fetch the part time percentage from the
--assignment standard conditions for a given effective date
--
CURSOR c_pt_cur (c_effective_date IN DATE) IS
SELECT fnd_number.canonical_to_number(NVL(target.SEGMENT29,'100')) pt_perc
 FROM  per_assignments_f asg
      ,hr_soft_coding_keyflex target
WHERE  asg.assignment_id = p_assignment_id
  AND  target.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
  AND  trunc(c_effective_date) between asg.effective_start_date
  AND  asg.effective_end_date
  AND  target.enabled_flag = 'Y';

--
--Cursor to fetch the assignment start date
--
CURSOR c_get_asg_start IS
SELECT min(effective_start_date)
  FROM per_all_assignments_f
WHERE  assignment_id = p_assignment_id;

--
-- Cursor to get the defined balance id for a given balance and dimension
--
CURSOR csr_defined_bal (c_balance_name      IN VARCHAR2
                       ,c_dimension_name    IN VARCHAR2
                       ,c_business_group_id IN NUMBER) IS
SELECT db.defined_balance_id
  FROM pay_balance_types pbt
      ,pay_defined_balances db
      ,pay_balance_dimensions bd
WHERE  pbt.balance_name        = c_balance_name
  AND  pbt.balance_type_id     = db.balance_type_id
  AND  bd.balance_dimension_id = db.balance_dimension_id
  AND  bd.dimension_name       = c_dimension_name
  AND  (pbt.business_group_id  = c_business_group_id OR
        pbt.legislation_code   = 'NL')
  AND  (db.business_group_id   = pbt.business_group_id OR
        db.legislation_code    = 'NL');

--
-- Cursor to get the holiday allowance global
--
CURSOR c_global_cur(c_global_name IN VARCHAR2) IS
SELECT fnd_number.canonical_to_number(global_value)
  FROM ff_globals_f
WHERE  global_name = c_global_name
  AND  trunc (p_date_earned) BETWEEN effective_start_date
  AND  effective_end_date;

--
-- Cursor to get the collective agreement name as of 1 Jan/Hire Date
--
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

--
-- Cursor to get the number of pay periods per year.
--
CURSOR c_pp_cur IS
SELECT pety.number_per_fiscal_year
  FROM pay_payrolls_f ppaf
      ,per_time_period_types pety
WHERE  ppaf.payroll_id   = p_payroll_id
  AND  ppaf.period_type  = pety.period_type;

--
--Cursor to fetch the org id for the organization
--attached to this assignment
--
CURSOR c_get_org_id(c_eff_date IN DATE) IS
SELECT organization_id
  FROM per_all_assignments_f
WHERE  assignment_id = p_assignment_id
  AND  c_eff_date BETWEEN effective_start_date
  AND  effective_end_date;

--
-- Cursor to get the value for EOY Bonus override percent
--
CURSOR c_eoy_per_or (c_asg_id         IN NUMBER
                    ,c_effective_date IN DATE) IS
select min (fffunc.cn(decode(
    decode(INPUTV.uom,'M','N','N','N','I','N',null),'N',decode(INPUTV.hot_default_flag,'Y',nvl(EEV.screen_entry_value,
nvl(LIV.default_value,INPUTV.default_value)),'N',EEV.screen_entry_value),null))) eoy_or
FROM    pay_element_entry_values_f               EEV,
        pay_element_entries_f                    EE,
        pay_link_input_values_f                  LIV,
        pay_input_values_f                       INPUTV,
        pay_element_types_f                      pet
WHERE   INPUTV.element_type_id                  = pet.element_type_id
AND     INPUTV.name                             = 'End of Year Bonus Percentage'
AND     c_effective_date BETWEEN INPUTV.effective_start_date
                             AND INPUTV.effective_end_date
AND     INPUTV.element_type_id = pet.element_type_id
AND     c_effective_date BETWEEN pet.effective_start_date
                             AND pet.effective_end_date
AND     pet.element_name = 'PGGM Pensions General Information'
AND     pet.legislation_code = 'NL'
AND     LIV.input_value_id                     = INPUTV.input_value_id
AND     c_effective_date BETWEEN LIV.effective_start_date
                 AND LIV.effective_end_date
AND     EEV.input_value_id + 0                 = INPUTV.input_value_id
AND     EEV.element_entry_id                   = EE.element_entry_id
AND     EEV.effective_start_date               = EE.effective_start_date
AND     EEV.effective_end_date                 = EE.effective_end_date
AND     EE.element_link_id                     = LIV.element_link_id
AND     EE.assignment_id                       = c_asg_id
AND     c_effective_date BETWEEN EE.effective_start_date
                             AND EE.effective_end_date ;

--
-- Cursor to get the value for Holiday Allowance override percent
--
CURSOR c_ha_per_or (c_asg_id         IN NUMBER
                   ,c_effective_date IN DATE) IS
select min (fffunc.cn(decode(
    decode(INPUTV.uom,'M','N','N','N','I','N',null),'N',decode(INPUTV.hot_default_flag,'Y',nvl(EEV.screen_entry_value,
nvl(LIV.default_value,INPUTV.default_value)),'N',EEV.screen_entry_value),null))) ha_or
FROM    pay_element_entry_values_f               EEV,
        pay_element_entries_f                    EE,
        pay_link_input_values_f                  LIV,
        pay_input_values_f                       INPUTV,
        pay_element_types_f                      pet
WHERE   INPUTV.element_type_id                  = pet.element_type_id
AND     INPUTV.name                             = 'Holiday Allowance Percentage'
AND     c_effective_date BETWEEN INPUTV.effective_start_date
                             AND INPUTV.effective_end_date
AND     INPUTV.element_type_id = pet.element_type_id
AND     c_effective_date BETWEEN pet.effective_start_date
                             AND pet.effective_end_date
AND     pet.element_name = 'PGGM Pensions General Information'
AND     pet.legislation_code = 'NL'
AND     LIV.input_value_id                     = INPUTV.input_value_id
AND     c_effective_date BETWEEN LIV.effective_start_date
                 AND LIV.effective_end_date
AND     EEV.input_value_id + 0                 = INPUTV.input_value_id
AND     EEV.element_entry_id                   = EE.element_entry_id
AND     EEV.effective_start_date               = EE.effective_start_date
AND     EEV.effective_end_date                 = EE.effective_end_date
AND     EE.element_link_id                     = LIV.element_link_id
AND     EE.assignment_id                       = c_asg_id
AND     c_effective_date BETWEEN EE.effective_start_date
                             AND EE.effective_end_date ;

-- =============================================================================
--Cursor to fetch Start date of a year
-- =============================================================================
CURSOR c_get_period_start_date ( c_year           IN VARCHAR2
                                )
IS
SELECT NVL(min(PTP.start_date),to_date('0101'||c_year,'DDMMYYYY'))
 FROM per_time_periods PTP
 WHERE
      PTP.payroll_id = p_payroll_id
 AND (substr(PTP.period_name,4,4)=c_year
      OR substr(PTP.period_name,3,4)=c_year);

l_loop_again          NUMBER;
l_valid_pt            NUMBER;
l_org_id              NUMBER;
l_run_year            NUMBER;
l_begin_of_year_date  DATE;
l_end_of_last_year    DATE;
l_effective_date      DATE;
l_hire_date           DATE;
l_asg_st_date         DATE;
l_jan_hire_ptp        NUMBER;
l_error_message       VARCHAR2(1000);
l_defined_balance_id  NUMBER;
l_scale_salary        NUMBER := nvl(p_scale_salary,0);
l_scale_salary_h      NUMBER := nvl(p_scale_salary_h,0);
l_scale_salary_e      NUMBER := nvl(p_scale_salary_e,0);
l_ft_rec_paymnt       NUMBER := nvl(p_ft_rec_payments,0);
l_ft_rec_paymnt_h     NUMBER := nvl(p_ft_rec_payments_h,0);
l_ft_rec_paymnt_e     NUMBER := nvl(p_ft_rec_payments_e,0);
l_pt_rec_paymnt       NUMBER := nvl(p_pt_rec_payments,0);
l_pt_rec_paymnt_h     NUMBER := nvl(p_pt_rec_payments_h,0);
l_pt_rec_paymnt_e     NUMBER := nvl(p_pt_rec_payments_e,0);
l_holiday_allowance   NUMBER := 0;
l_holiday_allow_per   NUMBER := 0;
l_min_holiday_allow   NUMBER := 0;
l_min_holiday_char    VARCHAR2(80);
l_eoy_bonus           NUMBER := 0;
l_eoy_bonus_per       NUMBER := 0;
l_min_eoy_bonus       NUMBER := 0;
l_min_eoy_bonus_char  VARCHAR2(80);
l_cag_name            per_collective_agreements.name%TYPE;
l_max_periods         NUMBER;
l_max_ptp             NUMBER := 0;
l_prev_max_ptp        NUMBER := 0;
l_ret_val             NUMBER := 0;
l_error_status        CHAR;
l_message_flag        CHAR;
UDT_CONTAINS_NO_DATA  EXCEPTION;
l_proc_name           VARCHAR2(30) := 'GET_PENSION_SALARY';
l_asg_eoy_bonus_per   NUMBER;
l_asg_ha_per          NUMBER;
l_ignore_eoy_cag      NUMBER;
l_ignore_ha_cag       NUMBER;
l_min_age_holiday_allow VARCHAR2(50);
l_person_age          NUMBER;
l_first_date_of_year  DATE;

BEGIN
hr_utility.set_location('Entering : '||g_pkg_name||l_proc_name,10);
--hr_utility.trace_on(null,'SS');

--initialise the error message params
p_err_message         := ' ';
p_err_message1        := ' ';
p_err_message2        := ' ';

--derive the year in which payroll is being run
l_run_year := to_number(to_char(p_date_earned,'YYYY'));
hr_utility.set_location('Payroll run year : '||l_run_year,20);

OPEN c_get_period_start_date(l_run_year);
FETCH c_get_period_start_date INTO l_first_date_of_year;
CLOSE c_get_period_start_date;

-- Get the first date of the run year
l_begin_of_year_date := l_first_date_of_year;

-- Get the latest start date of the assignment
OPEN c_get_asg_start;
FETCH c_get_asg_start INTO l_asg_st_date;

IF c_get_asg_start%FOUND THEN
   CLOSE c_get_asg_start;
ELSE
   CLOSE c_get_asg_start;
   p_err_message := 'Error: Unable to find the start date of the assignment';
   p_salary_balance_value := 0;
   RETURN 1;

END IF;

hr_utility.set_location('Asg start date : '||l_asg_st_date,30);

-- Get the hire date
OPEN c_hire_dt_cur (p_assignment_id);
FETCH c_hire_dt_cur INTO l_hire_date;

IF c_hire_dt_cur%FOUND THEN
   CLOSE c_hire_dt_cur;
   hr_utility.set_location('Hire date is : '||l_hire_date,40);
   -- The effective date is now the valid assignemnt
   --start date for the assignment
   l_effective_date := pqp_nl_abp_functions.get_valid_start_date
                       (p_assignment_id,
                        p_date_earned,
                        l_error_status,
                        l_error_message);

   --if an error occured while fetching the valid start date
   IF(l_error_status = trim(to_char(1,'9'))) THEN
      hr_utility.set_location('Error occured while fetching valid start date',50);
      fnd_message.set_name('PQP',l_error_message);
      p_err_message :='Error : '|| fnd_message.get();
      p_salary_balance_value :=0;
      RETURN 1;
   ELSE
      hr_utility.set_location('Valid start date fetched : '||l_effective_date,50);
   END IF;

ELSE
   CLOSE c_hire_dt_cur;
   hr_utility.set_location('Hire date could not be found',60);
   p_err_message := 'Error: Unable to find the hire date for the person ';
   p_salary_balance_value :=0;
   RETURN 1;
END IF;

-- Get the maximum number of periods in a year.
OPEN c_pp_cur;
FETCH c_pp_cur INTO l_max_periods;

IF c_pp_cur%NOTFOUND THEN
   p_err_message := 'Error: Unable to find the pay periods per year';
   p_salary_balance_value :=0;
   CLOSE c_pp_cur;
   RETURN 1;
ELSE
   CLOSE c_pp_cur;
END IF;

hr_utility.set_location('Number of periods in a year : '||l_max_periods,70);
hr_utility.set_location('Deriving the part time percentage',80);

-- Calculate the ptp as of 1 jan or Hire Date
OPEN c_pt_cur (l_effective_date);
FETCH c_pt_cur INTO l_jan_hire_ptp;

IF c_pt_cur%NOTFOUND THEN
   CLOSE c_pt_cur;
   hr_utility.set_location('No value found for part time percentage',90);
   p_err_message := 'Error: Unable to find the part time percentage.';
   p_err_message := p_err_message || 'Please enter a value as of 1 January or Hire Date';
   p_salary_balance_value :=0;
   RETURN 1;
ELSE
    CLOSE c_pt_cur;
END IF;

IF l_jan_hire_ptp = 0 THEN
   l_jan_hire_ptp := 100;
END IF;

l_jan_hire_ptp := LEAST(l_jan_hire_ptp,125);

hr_utility.set_location('Part Time Percentage used for salary : '||l_jan_hire_ptp,100);
l_jan_hire_ptp := l_jan_hire_ptp/100;

-- Divide all the part time balances by this value

l_pt_rec_paymnt          := l_pt_rec_paymnt/l_jan_hire_ptp;
l_pt_rec_paymnt_h        := l_pt_rec_paymnt_h/l_jan_hire_ptp;
l_pt_rec_paymnt_e        := l_pt_rec_paymnt_e/l_jan_hire_ptp;

--
-- EOY Bonus Calculation
-- This section will calculate the end of year bonus
-- based on the EOY Bonus percentage specified at the
-- org level. These will be derived from the following
-- three balances.
--
-- PGGM Scale Salary For End Of Year Bonus
-- PGGM Full Time Recurring Payments For End Of Year Bonus
-- PGGM Part Time Recurring Payments For End Of Year Bonus
--

--
-- Check to see if the EOY Bonus has been overridden
-- at the assignment input value level. If it has been overridden
-- and is not null. Use this value and do not derive from the org.
-- Otherwise derive it from the org.
-- It is imp to note that if the value is 0, then do not consider
-- the min at the CAG level.
--
OPEN c_eoy_per_or(p_assignment_id
                 ,l_effective_date);
   FETCH c_eoy_per_or INTO l_asg_eoy_bonus_per;
   IF c_eoy_per_or%FOUND THEN

      l_eoy_bonus_per := l_asg_eoy_bonus_per;
      hr_utility.set_location('EOY Bonus Override at the I/V Level',105);

   END IF;

CLOSE c_eoy_per_or;

--
-- Call the function to derive EOY Bonus
-- percentage from the org level only if it is null at the asg i/v level.
--
IF NVL(l_eoy_bonus_per,-99) = -99 THEN

   l_ret_val := pqp_nl_pggm_functions.get_general_info
             (p_assignment_id         => p_assignment_id
             ,p_business_group_id     => p_business_group_id
             ,p_date_earned           => p_date_earned
             ,p_code                  => 1
             ,p_value                 => l_eoy_bonus_per
             );

   IF l_ret_val <> 0 THEN
      l_eoy_bonus_per := 0;
   END IF;
   hr_utility.set_location('EOY Bonus Calculated from the org',106);

END IF;

--
-- Check if the final calculated value for EOY Bonus % is 0
-- If it is zero then ignore the min EOY Bonus specified
-- at the CAG ( Collective Agreement) level.
--
   IF l_eoy_bonus_per = 0 THEN
      l_ignore_eoy_cag := 1;
   ELSE
      l_ignore_eoy_cag := 0;
   END IF;

hr_utility.set_location('EOY Bonus % used for calculation is : '||l_eoy_bonus_per,110);

--
-- Calculate the EOY Bonus that needs to be included for
-- PGGM Pension Salary calculations
--
l_eoy_bonus := (l_scale_salary_e
               +l_ft_rec_paymnt_e
               +l_pt_rec_paymnt_e
               )
               * l_eoy_bonus_per/100
               * l_max_periods;

hr_utility.set_location('EOY Bonus amount calculated : '||l_eoy_bonus,120);

--
-- Holiday Allowance Calculation
-- This section will calculate the holiday allowance
-- based on the holiday allowance percentage specified
-- at the org level. These will be derived from the
-- following three balances.
--
-- PGGM Scale Salary For Holiday Allowance
-- PGGM Full Time Recurring Payments For Holiday Allowance
-- PGGM Part Time Recurring Payments For Holiday Allowance
--

--
-- Check to see if the Holiday Allowance % has been overridden
-- at the assignment input value level. If it has been overridden
-- and is not null, Use this value and do not derive from the org.
-- Otherwise derive it from the org.
-- It is imp to note that if the value is 0, the do not consider
-- the min at the cag level.
--
OPEN c_ha_per_or(p_assignment_id
                 ,l_effective_date);
   FETCH c_ha_per_or INTO l_asg_ha_per;

   IF c_ha_per_or%FOUND THEN

      l_holiday_allow_per := l_asg_ha_per;
      hr_utility.set_location('Holiday Allowance overridden at the iv level ',125);

   END IF;

CLOSE c_ha_per_or;
--
-- Call the function to derive Holiday allowance
-- percentage from the org level only if it is null at the asg i/v level.
--
IF NVL(l_holiday_allow_per,-99) = -99 THEN

   l_ret_val := pqp_nl_pggm_functions.get_general_info
             (p_assignment_id         => p_assignment_id
             ,p_business_group_id     => p_business_group_id
             ,p_date_earned           => p_date_earned
             ,p_code                  => 0
             ,p_value                 => l_holiday_allow_per
             );

   IF l_ret_val <> 0 THEN
      l_holiday_allow_per := 0;
   END IF;
   hr_utility.set_location('Holiday Allowance Calculated from the org',125);

END IF;

hr_utility.set_location('Holiday allow % used for calculation is : '
                        ||l_holiday_allow_per,130);

--
-- Check if the final calculated value for HA % is 0
-- If it is zero then ignore the min HA specified
-- at the CAG (Collective Agreement) level.
--
IF l_holiday_allow_per = 0 THEN
   l_ignore_ha_cag := 1;
ELSE
   l_ignore_ha_cag := 0;
END IF;

l_holiday_allowance   := (l_scale_salary_h
                         +l_ft_rec_paymnt_h
                         +l_pt_rec_paymnt_h
                         )
                         * l_holiday_allow_per/100
                         * l_max_periods;

hr_utility.set_location('Calculated holiday allowance : '||l_holiday_allowance,140);

-- Find the minimum values for EOY Bonus and Holiday
-- allowance that may have been defined for this
-- assignment. The value of holiday allowance and EOY
-- bonus used in pension salary calculation should
-- not be lesser than this defined minimum

-- First get the CAG Name
OPEN  c_cag_name (c_asg_id    => p_assignment_id
                 ,c_eff_date  => l_effective_date) ;

FETCH c_cag_name INTO l_cag_name;

IF c_cag_name%FOUND THEN

  -- We found a CAG at the asg level . Now get the Min End Of
  -- Year Bonus for this CAG from the UDT.
  hr_utility.set_location('CAG attached to the asg : '||l_cag_name,150);
  BEGIN
     l_min_eoy_bonus_char := hruserdt.get_table_value
                             (
                              p_bus_group_id    => p_business_group_id
                             ,p_table_name      => 'PQP_NL_MIN_END_OF_YEAR_BONUS'
                             ,p_col_name        => 'PGGM Minimum End Of Year Bonus'
                             ,p_row_value       => l_cag_name
                             ,p_effective_date  => l_effective_date
                             );

     --
     -- Calculate the min EOY bonus only if the override percentage is not 0
     --
     IF NVL(l_ignore_eoy_cag,0) = 0 THEN
        l_min_eoy_bonus   := fnd_number.canonical_to_number(NVL(l_min_eoy_bonus_char,'0'));
     ELSIF NVL(l_ignore_eoy_cag,0) = 1 THEN
        l_min_eoy_bonus := 0;
     END IF;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
     hr_utility.set_location('Exception occured :NO_DATA_FOUND ',160);
     l_min_eoy_bonus := 0;
  END;

  -- We found a CAG at the asg level . Now get the Min holiday
  -- allowance for this CAG from the UDT.
  BEGIN
     l_min_age_holiday_allow:= hruserdt.get_table_value
                         (
                          p_bus_group_id    => p_business_group_id
                         ,p_table_name      => 'PQP_NL_MIN_HOLIDAY_ALLOWANCE'
                         ,p_col_name        => 'PGGM Min Age for Holiday Allowance'
                         ,p_row_value       => l_cag_name
                         ,p_effective_date  => l_effective_date
                         );
     --Get the age of the person
     hr_utility.set_location('l_begin_of_year_date'||l_begin_of_year_date,161);
     l_person_age := Get_age(p_assignment_id,l_effective_date,l_begin_of_year_date);
     hr_utility.set_location('l_person_age'||l_person_age,162);
     hr_utility.set_location('l_min_age_holiday_allow'||l_min_age_holiday_allow,163);

     --Comapre it with min age defined at CAG level
     IF (l_person_age < to_number(l_min_age_holiday_allow) ) THEN
      --Person is not eligible for Min holiday allowance
        l_min_holiday_allow :=0;
       p_err_message2 :=p_err_message2|| 'Min. holiday allowance is set to 0 as'
                      ||'person age is less than min age defined at collective agreement ';
      l_ret_val := 2;
     ELSE
       l_min_holiday_char := hruserdt.get_table_value
                         (
                          p_bus_group_id    => p_business_group_id
                         ,p_table_name      => 'PQP_NL_MIN_HOLIDAY_ALLOWANCE'
                         ,p_col_name        => 'PGGM Minimum Holiday Allowance'
                         ,p_row_value       => l_cag_name
                         ,p_effective_date  => l_effective_date
                         );
       hr_utility.set_location('l_min_holiday_char'||l_min_holiday_char,165);
           --
           -- Calculate the min HA only if the override percentage is not 0
           --
        IF NVL(l_ignore_ha_cag,0) = 0 THEN
           l_min_holiday_allow := fnd_number.canonical_to_number(NVL(l_min_holiday_char,'0'));
        ELSIF NVL(l_ignore_ha_cag,0) = 1 THEN
           l_min_holiday_allow := 0;
        END IF;
     END IF; -- End of person age check

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
     hr_utility.set_location('Exception occured :NO_DATA_FOUND ',170);
     l_min_holiday_allow := 0;
  END;

--no collective agreement defined for this assignment
ELSE
  -- set Min EOY bonus and Min Holiday allowance to 0 .
  hr_utility.set_location('No CAG attached',160);
  l_min_eoy_bonus     := 0;
  l_min_holiday_allow := 0;
END IF;

CLOSE c_cag_name;

hr_utility.set_location('Min. EOY bonus : '||l_min_eoy_bonus,170);
hr_utility.set_location('Min. Holiday allowance : '||l_min_holiday_allow,180);

--now compare the calculated eoy bonus and the min. eoy bonus
IF l_eoy_bonus < l_min_eoy_bonus THEN
   p_err_message1 :=p_err_message1|| 'Min. end of year bonus for the collective agreement'
                      ||' was used for Pension Salary calculation ';
   l_ret_val := 2;
END IF;

l_eoy_bonus    := GREATEST(l_eoy_bonus,nvl(l_min_eoy_bonus,0));

hr_utility.set_location('Final EOY Bonus value : '||l_eoy_bonus,190);

--now compare the calculated holiday allowance and the min. holiday allowance
IF l_holiday_allowance < l_min_holiday_allow THEN
   p_err_message2 :=p_err_message2|| 'Min. holiday allowance for the collective agreement'
                      ||' was used for Pension Salary calculation ';
   l_ret_val := 2;
END IF;

l_holiday_allowance    := GREATEST(l_holiday_allowance,nvl(l_min_holiday_allow,0));

hr_utility.set_location('Final Holiday Allowance value : '||l_holiday_allowance,200);

p_salary_balance_value := (l_scale_salary
                          +l_ft_rec_paymnt
                          +l_pt_rec_paymnt
                          ) * l_max_periods
                          +l_holiday_allowance
                          +l_eoy_bonus;

p_salary_balance_value := CEIL(p_salary_balance_value);

hr_utility.set_location('Leaving : '||g_pkg_name||l_proc_name,210);
--hr_utility.trace_off;
RETURN l_ret_val;

EXCEPTION
WHEN OTHERS THEN
   p_salary_balance_value := 0;
   hr_utility.set_location('Exception occured in : '||g_pkg_name||l_proc_name,220);
   p_err_message := 'Error occured while deriving the PGGM Pension Salary'
                      ||' value : '||SQLERRM;
RETURN 1;

END GET_PENSION_SALARY;

-- ----------------------------------------------------------------------------
-- |----------------------<GET_PART_TIME_PERCENTAGE >--------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION GET_PART_TIME_PERCENTAGE
         (p_assignment_id        IN  NUMBER
	 ,p_payroll_action_id    IN  NUMBER
	 ,p_date_earned          IN  DATE
         ,p_business_group_id    IN  NUMBER
         ,p_period_start_date    IN  DATE
         ,p_period_end_date      IN  DATE
         ,p_override_value       IN  NUMBER
         ,p_parental_leave       IN  VARCHAR2
         ,p_extra_hours          IN  NUMBER
         ,p_hours_worked         OUT NOCOPY NUMBER
         ,p_total_hours          OUT NOCOPY NUMBER
         ,p_part_time_percentage OUT NOCOPY NUMBER
         ,p_err_message          OUT NOCOPY VARCHAR2
         )
RETURN NUMBER IS

--
-- Cursor to fetch the earliest start date of the assignment
-- for this period
--
CURSOR c_get_st_date IS
SELECT min(effective_start_date)
  FROM per_all_assignments_f
WHERE  assignment_id = p_assignment_id
   AND effective_end_date >= p_period_start_date;
--
--Cursor to fetch the part time percentage from the
--assignment standard conditions for a given effective date
--
CURSOR c_get_ptp(c_effective_date IN DATE) IS
SELECT fnd_number.canonical_to_number(NVL(target.SEGMENT29,'0')) pt_perc
 FROM  per_assignments_f asg
      ,hr_soft_coding_keyflex target
WHERE  asg.assignment_id = p_assignment_id
  AND  target.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
  AND  c_effective_date between asg.effective_start_date
  AND  asg.effective_end_date
  AND  target.enabled_flag = 'Y';

--
-- cursor to fetch the date tracked assignment rows
-- for all changes in the pay period
-- the calendar day average value of all these changes
-- is taken as the average part time percentage of this period
--
CURSOR c_get_asg_rows IS
SELECT fnd_number.canonical_to_number(NVL(target.segment28,'0')) hours_worked
      ,nvl(asg.normal_hours,0) total_hours
      ,nvl(asg.frequency,'W') freq
      ,asg.effective_start_date start_date
      ,asg.effective_end_date end_date
  FROM per_assignments_f asg
      ,per_assignment_status_types ast
      ,hr_soft_coding_keyflex target
WHERE  asg.assignment_id = p_assignment_id
   AND asg.assignment_status_type_id = ast.assignment_status_type_id
   AND ast.per_system_status = 'ACTIVE_ASSIGN'
   AND target.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
   AND asg.effective_start_date <= p_period_end_date
   AND asg.effective_end_date >= p_period_start_date;


--
--Cursor to fetch period type of payroll attached to assignment
--
CURSOR c_get_period_type(c_payroll_action_id IN NUMBER)
IS
SELECT TPERIOD.period_type
 FROM  pay_payroll_actions     PACTION
      ,per_time_periods        TPERIOD
 WHERE PACTION.payroll_action_id   = c_payroll_action_id
  AND TPERIOD.payroll_id          = PACTION.payroll_id
  AND (PACTION.date_earned   between TPERIOD.start_date
                                and TPERIOD.end_date);

c_asg_row c_get_asg_rows%ROWTYPE;

l_proc_name    VARCHAR2(30) := 'GET_PART_TIME_PERCENTAGE';
l_eff_date     DATE;
l_ptp          NUMBER := 100;
l_emp_kind     NUMBER := 1;
l_start_date   DATE;
l_end_date     DATE;
l_days         NUMBER;
l_pay_days     NUMBER;
l_tot_days     NUMBER := 0;
hours_worked   NUMBER := 0;
total_hours    NUMBER := 0;
l_hours_worked NUMBER;
l_total_hours  NUMBER;
l_ret_value    NUMBER := 0;
l_num_periods  NUMBER :=12;
l_period_type  VARCHAR2(150):='Calendar Month';
l_num_of_days_in_period NUMBER:=30;

BEGIN
hr_utility.set_location('Entering : '||g_pkg_name||l_proc_name,10);

OPEN c_get_period_type(p_payroll_action_id);
FETCH c_get_period_type INTO l_period_type;
CLOSE c_get_period_type;
 IF l_period_type='Calendar Month' THEN
    l_num_of_days_in_period:= 30;
 ELSE  IF l_period_type = 'Lunar Month' THEN
         l_num_of_days_in_period:=28;
       ELSE  IF l_period_type = 'Week' THEN
                l_num_of_days_in_period:=7;
             ELSE IF l_period_type = 'Quarter' THEN
                    l_num_of_days_in_period:=90;
                  END IF;
             END IF;
       END IF;
 END IF;

p_err_message := '';
--
-- check if the person is a full timer or part timer
-- if the person is a part timer, then the final part time
-- percentage cannot exceed 100% and it cannot exceed 125%
-- for a full timer
-- If the part time percentage derived from the standard
-- conditions is < 100 then the person is a part time employee
-- if the value is equal to or exceeds 100 then this is a full
-- timer
--

-- fetch the part time percentage on the period start date
-- first fetch the date on which this part time percentage needs
-- to be derived on

OPEN c_get_st_date;
FETCH c_get_st_date INTO l_eff_date;
CLOSE c_get_st_date;

hr_utility.set_location('Start date of asg for this period : '||l_eff_date,20);

-- the date on which ptp needs to be derived is the greater of the asg start date
-- and the period start date

l_eff_date := GREATEST(l_eff_date,p_period_start_date);

hr_utility.set_location('date on which check is performed : '||l_eff_date,30);

--Get number of payroll periods in a year
OPEN c_get_num_periods_per_year(p_payroll_action_id);
FETCH c_get_num_periods_per_year INTO l_num_periods;
CLOSE c_get_num_periods_per_year;


--now derive the ptp from standard conditions on this eff date to check
-- for part/full timers

OPEN c_get_ptp(l_eff_date);
FETCH c_get_ptp INTO l_ptp;
CLOSE c_get_ptp;

hr_utility.set_location('PTP on the start date : '||l_ptp,40);

IF l_ptp < 100 THEN
   -- the employee is a part time employee
   l_emp_kind := 0;
ELSE
   -- the employee is full time
   l_emp_kind := 1;
END IF;

hr_utility.set_location('Employee Kind : '||l_emp_kind,50);

--calculate the number of days in this pay period
l_pay_days := TRUNC(p_period_end_date) - TRUNC(p_period_start_date) + 1;

--now loop through the asg changes to find the total average hours worked
FOR c_asg_row IN c_get_asg_rows
LOOP
   --if the start date is before period start,use period start
   IF c_asg_row.start_date < p_period_start_date THEN
      l_start_date := p_period_start_date;
   ELSE
      l_start_date := c_asg_row.start_date;
   END IF;

   -- if end date is after period end,use period end
   IF c_asg_row.end_date > p_period_end_date THEN
      l_end_date := p_period_end_date;
   ELSE
      l_end_date := c_asg_row.end_date;
   END IF;

   hr_utility.set_location('Start Date : '||l_start_date,60);
   hr_utility.set_location('End Date : '||l_end_date,70);
   hr_utility.set_location('Hours worked : '||c_asg_row.hours_worked,80);
   hr_utility.set_location('Total Hours : '||c_asg_row.total_hours,90);
   hr_utility.set_location('Frequency : '||c_asg_row.freq,100);

   --calculate the hours per week based on the frequency
   IF c_asg_row.freq = 'D' THEN
      l_hours_worked := c_asg_row.hours_worked * 5;
      l_total_hours  := c_asg_row.total_hours * 5;
   ELSIF c_asg_row.freq = 'M' THEN
      l_hours_worked := c_asg_row.hours_worked * l_num_periods/52;
      l_total_hours  := c_asg_row.total_hours * l_num_periods/52;
   ELSIF c_asg_row.freq = 'Y' THEN
      l_hours_worked := c_asg_row.hours_worked/52;
      l_total_hours  := c_asg_row.total_hours/52;
   ELSE
      l_hours_worked := c_asg_row.hours_worked;
      l_total_hours  := c_asg_row.total_hours;
   END IF;

   --calculate the days for this asg row
   l_days := TRUNC(l_end_date) - TRUNC(l_start_date) + 1;
   l_tot_days := l_tot_days + l_days;

    --the total days should always be l_num_of_days_in_period,
    --adjust the last l_days so that it adds up to l_num_of_days_in_period
   IF l_tot_days = l_pay_days THEN
      --the number of days is equal to the number of days in the
      --pay period,but this has to always be l_num_of_days_in_period
      l_days := l_days + (l_num_of_days_in_period - l_tot_days);
   END IF;

   hr_utility.set_location('l_days : '||l_days,110);

   hours_worked := hours_worked +
                   l_hours_worked * l_days/l_num_of_days_in_period;

   total_hours  := total_hours +
                   l_total_hours * l_days/l_num_of_days_in_period;
END LOOP;

--hours worked and total hours for the month is the average calculated
-- above * 52/12
hours_worked := hours_worked * 52/l_num_periods;
total_hours := total_hours * 52/l_num_periods;

hr_utility.set_location('Avg. Hours worked : '||hours_worked,120);
hr_utility.set_location('Avg. Total Hours : '||total_hours,130);

--
-- check if an override has been entered, if so then the part time
-- percentage is the same as the value entered in the override
-- however for the case where the person is on parental leave,
-- the override part time percentage needs to be added with
-- the extra hours entered
--

IF p_override_value <> -99 THEN
   --override has been entered
   l_ptp := p_override_value;
   hr_utility.set_location('Override exists : '||l_ptp,140);
   --check if the employee is also on parental leave
   IF p_parental_leave = 'Y' THEN
      --we also need to add any increase in ptp due to extra hours
      hr_utility.set_location('parental leave exists',150);
      IF total_hours > 0 THEN
         --only if the employee is part time,extra hours can be considered
         IF l_emp_kind = 0 THEN
            l_ptp := l_ptp + (nvl(p_extra_hours,0)/total_hours) * 100;
         END IF;
      END IF;
   END IF;

ELSE
   --no override exists
   hr_utility.set_location('No override exists',160);
   --final ptp value is calculated value + increase due to extra hours
   IF total_hours > 0 THEN
      --only if emp is part time, then consider extra hours
      IF l_emp_kind = 0 THEN
         l_ptp := ((hours_worked + nvl(p_extra_hours,0))/total_hours) * 100;
      ELSE
         l_ptp := (hours_worked/total_hours) * 100;
      END IF;
   ELSE
      l_ptp := 0;
   END IF;
END IF;

l_ptp := nvl(l_ptp,0);

hr_utility.set_location('Calculated PTP : '||l_ptp,170);
/*
PGGM 2006 Legislative change
No max limit for Part time percentage
--
-- Restrict the final value of PTP to 125
--
IF l_ptp > 125 THEN
   p_err_message := 'Part time percentage has been restricted to 125%';
   l_ret_value := 2;
END IF;

l_ptp := LEAST(l_ptp,125);
*/

hr_utility.set_location('Final ptp value : '||l_ptp,180);

p_part_time_percentage := round(nvl(l_ptp,0),2);
p_hours_worked := round(nvl(hours_worked,0),2);
p_total_hours := round(nvl(total_hours,0),2);

hr_utility.set_location('Leaving : '||g_pkg_name||l_proc_name,190);

RETURN l_ret_value;

EXCEPTION
WHEN OTHERS THEN
   hr_utility.set_location('Exception occured in : '||g_pkg_name||l_proc_name,200);
   p_part_time_percentage := 0;
   p_hours_worked := 0;
   p_total_hours := 0;
   p_err_message := 'Error occured while deriving part time percentage : '||SQLERRM;
   RETURN 1;

END GET_PART_TIME_PERCENTAGE;

-- ----------------------------------------------------------------------------
-- |----------------------<GET_INCI_WKR_CODE >--------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION GET_INCI_WKR_CODE
         (p_assignment_id        IN  NUMBER
          ,p_business_group_id    IN  NUMBER
	  ,p_date_earned          IN  DATE
	  ,p_result_value         OUT NOCOPY VARCHAR2
          ,p_err_message          OUT NOCOPY VARCHAR2
         )
RETURN NUMBER IS
CURSOR csr_get_inci_wkr_code(c_assignment_id NUMBER,c_date_earned DATE) IS
SELECT scl.SEGMENT1
  FROM per_all_assignments_f asg
      ,hr_soft_coding_keyflex scl
WHERE asg.assignment_id = c_assignment_id
  AND c_date_earned BETWEEN asg.effective_start_date
  AND asg.effective_end_date
  AND asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id;

l_proc_name    VARCHAR2(30) := 'GET_INCI_WKR_CODE';
l_inci_code VARCHAR2(1):='N';
l_ret_value NUMBER:=0;
BEGIN
hr_utility.set_location('Entering : '||g_pkg_name||l_proc_name,10);

OPEN csr_get_inci_wkr_code(p_assignment_id,p_date_earned);
FETCH csr_get_inci_wkr_code INTO l_inci_code;

IF csr_get_inci_wkr_code%FOUND THEN
p_result_value:=l_inci_code;
ELSE
p_result_value:='N';
END IF;
CLOSE csr_get_inci_wkr_code;

hr_utility.set_location('Leaving : '||g_pkg_name||l_proc_name,190);
RETURN l_ret_value;
EXCEPTION
WHEN OTHERS THEN
   hr_utility.set_location('Exception occured in : '||g_pkg_name||l_proc_name,200);
   p_err_message := 'Error occured while deriving incidental worker code : '||SQLERRM;
   RETURN 1;
END GET_INCI_WKR_CODE;

END PQP_NL_PGGM_FUNCTIONS;

/
