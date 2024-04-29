--------------------------------------------------------
--  DDL for Package Body PAY_IN_TAX_DECLARATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_TAX_DECLARATION" AS
/* $Header: pyintaxd.pkb 120.16.12010000.7 2010/04/01 11:02:33 mdubasi ship $ */
--
-- Global Variables Section
--
  g_legislation_code     VARCHAR2(3);
  g_approval_info_type   VARCHAR2(40);
  g_element_value_list   t_element_values_tab;
  g_80dd_values          t_entry_details_tab;
  g_80g_values           t_entry_details_tab;
  g_insurace_values      t_entry_details_tab;
  g_80cce_values         t_entry_details_tab;
  g_list_index           NUMBER;
  g_80dd_index           NUMBER;
  g_80g_index            NUMBER;
  g_insurace_index       NUMBER;
  g_80cce_index          NUMBER;
  g_assignment_id        per_all_assignments_f.assignment_id%TYPE;
  g_index_assignment_id  per_all_assignments_f.assignment_id%TYPE;
  g_is_valid             BOOLEAN;
  g_index_values_valid   BOOLEAN;
  g_package              CONSTANT VARCHAR2(100) := 'pay_in_tax_declaration.';
  g_debug                BOOLEAN;
--
-- The following type is declared to store all
-- the inputs values of tax elements.
--
  type t_input_values_rec is record
          (input_name      pay_input_values_f.name%TYPE
          ,input_value_id  pay_input_values_f.input_value_id%TYPE
          ,input_value     pay_element_entry_values.screen_entry_value%TYPE);

  type t_input_values_tab is table of t_input_values_rec
     index by binary_integer;
--
--------------------------------------------------------------------------
--                                                                      --
-- Name           : IS_LOCKING_PERIOD                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for returning the      --
--                  freeze period details like start date, along with   --
--                  a flag to indicate if it is the freeze period.      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_person_id   per_people_f.person_id%TYPE           --
--          OUT   : p_locked        VARCHAR2                            --
--                  p_lock_start    DATE                                --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  24-Sep-2004  PUCHIL      Initial Version                        --
-- 1.0  25-Sep-2007  RSAHARAY    Parameter p_person_id replaced with    --
--                               p_assignment_id                        --
-- 1.1	01-Oct-2007  RSAHARAY    Reverted to the initial IN parameters  --
--                               Modified the CURSOR                    --
--				 csr_locking_period_details             --
--------------------------------------------------------------------------
PROCEDURE is_locking_period
   (p_person_id  IN         per_people_f.person_id%TYPE
   ,p_locked     OUT NOCOPY VARCHAR2
   ,p_lock_start OUT NOCOPY DATE)
IS
   --
   CURSOR csr_locking_period_details(c_person_id IN NUMBER)
   IS
   SELECT nvl(org.org_information1, 'N') locking_period
        , nvl(org.org_information3, 0) window_period
        , fnd_date.canonical_to_date(org.org_information2) locking_period_start
        , TRUNC(SYSDATE - start_date) hire_duration
     FROM hr_organization_information org
        , per_people_f person
        , per_assignments_f assign
        , hr_soft_coding_keyflex scl
    WHERE org.org_information_context = 'PER_IN_TAX_DECL_DETAILS'
      AND person.person_id = c_person_id
      AND assign.person_id = person.person_id
      AND assign.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
      AND assign.primary_flag = 'Y'
      AND org.organization_id = nvl(scl.segment1, person.business_group_id)
      AND SYSDATE BETWEEN person.effective_start_date
                      AND person.effective_end_date
      AND SYSDATE BETWEEN assign.effective_start_date
                      AND assign.effective_end_date;
   --
   l_proc VARCHAR2(120);
   l_locking_period VARCHAR2(2);
   l_window_period NUMBER;
   l_hire_duration NUMBER;
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   --
BEGIN
   --
    l_procedure := g_package || 'is_locking_period';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_person_id',p_person_id);
      pay_in_utils.trace('**************************************************','********************');
    END IF;
    p_locked := 'Y';
   --

   --
   OPEN csr_locking_period_details(p_person_id);
   FETCH csr_locking_period_details INTO l_locking_period
                                       , l_window_period
                                       , p_lock_start
                                       , l_hire_duration;
   CLOSE csr_locking_period_details;
   --
   pay_in_utils.set_location(g_debug, l_proc, 20);
   --
   -- If locking period if its a new hire falling within the window period
   -- if so allow him access to declare his tax. For all other cases deny
   -- access.
   -- If declaration period allow access.
   --
   IF l_locking_period = 'Y' THEN
      --
      -- locking period logic
      --
      IF l_hire_duration < l_window_period THEN
         --
         pay_in_utils.set_location(g_debug, l_proc, 30);
	 --
         p_locked := 'N';
         --
      END IF;
      --
      pay_in_utils.set_location(g_debug, l_proc, 40);
      --
   ELSE
      --
      -- Declaration period logic.
      --
      pay_in_utils.set_location(g_debug, l_proc, 50);
      --
      p_locked := 'N';
      --
   END IF;

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_locked ',p_locked);
      pay_in_utils.trace('p_lock_start ',p_lock_start);
      pay_in_utils.trace('**************************************************','********************');
    END IF;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

   --
END is_locking_period;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : IS_APPROVED                                         --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for returning the      --
--                  the flag stating if the employee tax declaration    --
--                  details have been approved or not.                  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_person_id       per_people_f.person_id%TYPE       --
--                  p_effective_date  DATE                              --
--            OUT : p_status          VARCHAR2                          --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  24-Sep-2004  PUCHIL      Initial Version                        --
--------------------------------------------------------------------------
PROCEDURE is_approved
   (p_person_id      IN NUMBER
   ,p_effective_date IN DATE default null
   ,p_status         OUT NOCOPY VARCHAR2)
IS
   --
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_effective_date DATE;
   l_assignment_id per_assignments_f.assignment_id%TYPE;
   l_extra_info_id per_assignment_extra_info.assignment_extra_info_id%TYPE;
   --
BEGIN
   --
    l_procedure := g_package || 'is_approved';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_person_id',p_person_id);
      pay_in_utils.trace('p_effective_date',p_effective_date);
      pay_in_utils.trace('**************************************************','********************');
    END IF;
   --
   -- Get the currect effective date to be used.
   --
   l_effective_date:= pay_in_utils.get_effective_date(p_effective_date);
    pay_in_utils.trace('l_effective_date ',l_effective_date);
    pay_in_utils.set_location(g_debug,l_procedure,20);
   --
   -- Get the assignment Id for which to find the details.
   --
   l_assignment_id := pay_in_utils.get_assignment_id
                         (p_person_id
                         ,l_effective_date);
    pay_in_utils.trace('l_assignment_id ',l_assignment_id);
    pay_in_utils.set_location(g_debug,l_procedure,30);
   --
   -- Get the approval details for the above assignment ID
   --
   p_status := pay_in_tax_declaration.get_approval_status
      (p_assignment_id => l_assignment_id
      ,p_tax_year => pay_in_tax_declaration.get_tax_year(l_effective_date)
      ,p_extra_info_id => l_extra_info_id);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_status ', p_status);
      pay_in_utils.trace('**************************************************','********************');
    END IF;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);


END is_approved;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_CITY_TYPE                                       --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : The function is responsible for quering the city    --
--                  type of the primary address of the employee if the  --
--                  primary address is not available then return NA.    --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_person_id       per_people_f.person_id%TYPE       --
--                  p_effective_date  DATE                              --
--         RETURN : VARCHAR2                                            --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  24-Sep-2004  PUCHIL      Initial Version                        --
--------------------------------------------------------------------------
FUNCTION get_city_type
        (p_person_id       IN    NUMBER
        ,p_effective_date  IN    DATE)
RETURN varchar2
IS
  --
  -- Cursor to get the city type from per_addresses
  --
  CURSOR csr_city_type
  IS
  SELECT add_information16
    FROM per_addresses
   WHERE person_id = p_person_id
     AND primary_flag = 'Y'
     AND style = 'IN'
     AND p_effective_date BETWEEN date_from
                              AND NVL(date_to, hr_general.end_of_time);
  --
   l_lookup_code hr_lookups.lookup_code%TYPE;
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);

  --
BEGIN
  --
    l_procedure := g_package || 'get_city_type';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_person_id',p_person_id);
      pay_in_utils.trace('p_effective_date',p_effective_date);
      pay_in_utils.trace('**************************************************','********************');
    END IF;
  --
  -- Comments should be of this form
  --
  OPEN csr_city_type;
  FETCH csr_city_type INTO l_lookup_code;
  --
  IF csr_city_type%NOTFOUND THEN
     l_lookup_code := 'NA';
     pay_in_utils.trace('l_lookup_code ',l_lookup_code);
     pay_in_utils.set_location(g_debug,l_procedure,20);
  END IF;
  --
  CLOSE csr_city_type;
  --
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('Decoded Lookup Code',hr_general.decode_lookup('IN_CITY_TYPE', l_lookup_code));
      pay_in_utils.trace('**************************************************','********************');
    END IF;


  return hr_general.decode_lookup('IN_CITY_TYPE', l_lookup_code);



END get_city_type;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_TAX_YEAR                                        --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : The function is responsible returning the tax year  --
--                  created based on the effective date passed to it.   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_effective_date  DATE                              --
--         RETURN : VARCHAR2                                            --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  24-Sep-2004  PUCHIL      Initial Version                        --
--------------------------------------------------------------------------
FUNCTION get_tax_year(p_effective_date IN DATE)
RETURN VARCHAR2
IS
   --
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_year NUMBER;
   l_month NUMBER;
   --
BEGIN
   --
    l_procedure := g_package || 'get_tax_year';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_effective_date',p_effective_date);
      pay_in_utils.trace('**************************************************','********************');
    END IF;
   --
   -- Get the year and month for the effective date
   --
   l_year := to_number(to_char(p_effective_date, 'YYYY'));
   l_month := to_number(to_char(p_effective_date, 'MM'));
   pay_in_utils.trace('l_year ',l_year);
   pay_in_utils.set_location(g_debug,l_procedure,20);
   pay_in_utils.trace('l_month ',l_month);
   pay_in_utils.set_location(g_debug,l_procedure,30);
   --
   -- If it is Jan, Feb or Mar it is current_year-1 and current_year.
   --
   IF l_month in (1, 2, 3) THEN
      --
      pay_in_utils.set_location(g_debug,l_procedure,40);
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,50);
      RETURN (to_char(l_year-1)||'-'||to_char(l_year));
      --
   ELSE
      --
      -- Else it is current_year and current_year + 1
      --
     pay_in_utils.set_location(g_debug,l_procedure,60);
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,80);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('Tax Year',(to_char(l_year)||'-'||to_char(l_year+1)));
      pay_in_utils.trace('**************************************************','********************');
    END IF;

      RETURN (to_char(l_year)||'-'||to_char(l_year+1));
      --
   END IF;
   --


END get_tax_year;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_APPROVAL_STATUS                                 --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for returning the      --
--                  the flag stating if the employee tax declaration    --
--                  details have been approved or not.           .      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id  per_assignments_f.assignment_id    --
--                  p_tax_year       VARCHAR2                           --
--                  p_extra_info_id  assignment_extra_info_id           --
--         RETURN : VARCHAR2                                            --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  24-Sep-2004  PUCHIL      Initial Version                        --
--------------------------------------------------------------------------
FUNCTION get_approval_status
   (p_assignment_id IN per_assignments_f.assignment_id%TYPE
   ,p_tax_year      IN VARCHAR2
   ,p_extra_info_id OUT NOCOPY per_assignment_extra_info.assignment_extra_info_id%TYPE)
RETURN VARCHAR2
IS
   --
   CURSOR csr_approval_details
   IS
   SELECT assignment_extra_info_id
        , aei_information2 flag
     FROM per_assignment_extra_info
    WHERE assignment_id = p_assignment_id
      AND information_type = g_approval_info_type
      AND aei_information1 = p_tax_year
      AND aei_information_category = g_approval_info_type;
   --
   l_found VARCHAR2(2);
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);

   --
BEGIN
   --
    l_procedure := g_package || 'get_approval_status';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id',p_assignment_id);
      pay_in_utils.trace('p_tax_year',p_tax_year);
      pay_in_utils.trace('**************************************************','********************');
    END IF;
   --
   OPEN csr_approval_details;
   FETCH csr_approval_details INTO p_extra_info_id, l_found;
   CLOSE csr_approval_details;
   --
    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('l_found',l_found);
      pay_in_utils.trace('p_extra_info_id',p_extra_info_id);
      pay_in_utils.trace('**************************************************','********************');
    END IF;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

   RETURN l_found;



  --
END get_approval_status;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_DONATION_TYPE                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : The function has the same code which is used to     --
--                  validate teh donation type details entered. Further --
--                  is used to validate the same in self-service        --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_lookup_code    VARCHAR2                           --
--         RETURN : pay_user_column_instances_f.value%TYPE              --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  24-Sep-2004  PUCHIL      Initial Version                        --
--------------------------------------------------------------------------
FUNCTION get_donation_type(p_lookup_code IN VARCHAR2)
RETURN pay_user_column_instances_f.value%TYPE
IS
   --
   CURSOR csr_get_meaning
   IS
   SELECT cinstances.value
     FROM pay_user_tables utab
        , pay_user_columns ucols
        , pay_user_rows_f urows
        , pay_user_column_instances_f cinstances
    WHERE utab.user_table_id = ucols.user_table_id
      AND utab.user_table_id = urows.user_table_id
      AND ucols.user_column_id = cinstances.user_column_id
      AND urows.user_row_id = cinstances.user_row_id
      AND utab.user_table_name = 'PER_IN_DONATION_DETAILS'
      AND utab.legislation_code  = 'IN'
      AND ucols.user_column_name =  'Donation Type'
      AND urows.row_low_range_or_name = p_lookup_code;
   --
   l_meaning pay_user_column_instances_f.value%TYPE;
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);

   --
BEGIN
   --
    l_procedure := g_package || 'get_donation_type';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_lookup_code',p_lookup_code);
      pay_in_utils.trace('**************************************************','********************');
    END IF;

   OPEN csr_get_meaning;
   FETCH csr_get_meaning INTO l_meaning;
   CLOSE csr_get_meaning;

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('l_meaning',l_meaning);
      pay_in_utils.trace('**************************************************','********************');
    END IF;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

   RETURN l_meaning;


END get_donation_type;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_PLANNED_VALUE                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : The function calculates the value of an element     --
--                  entries's input value on a date which is before the --
--                  freeze date for the financial year.                 --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_actual_value  VARCHAR2                            --
--                  p_ele_entry_id  element_entry_id%TYPE               --
--                  p_input_value_id input_value_id%TYPE                --
--         RETURN : VARCHAR2                                            --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  24-Sep-2004  PUCHIL      Initial Version                        --
--------------------------------------------------------------------------
FUNCTION get_planned_value
        (p_assignment_id   IN per_assignments_f.assignment_id%TYPE
        ,p_actual_value    IN VARCHAR2
        ,p_ele_entry_id    IN pay_element_entries_f.element_entry_id%TYPE
        ,p_input_value_id  IN pay_input_values_f.input_value_id%TYPE)
RETURN VARCHAR2
IS
   --
   CURSOR csr_entry_value(c_effective_date IN DATE)
   IS
   SELECT screen_entry_value
     FROM pay_element_entry_values_f
    WHERE element_entry_id = p_ele_entry_id
      AND input_value_id = p_input_value_id
      AND c_effective_date BETWEEN effective_start_date
                               AND effective_end_date;
   --
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_value pay_element_entry_values.screen_entry_value%TYPE;
   l_locked VARCHAR2(2);
   l_date_start DATE;
   --
BEGIN

    l_procedure := g_package || 'get_planned_value';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id',p_assignment_id);
      pay_in_utils.trace('p_actual_value',p_actual_value);
      pay_in_utils.trace('p_ele_entry_id',p_ele_entry_id);
      pay_in_utils.trace('p_input_value_id',p_input_value_id);
      pay_in_utils.trace('**************************************************','********************');
    END IF;
    --
   is_locking_period
      (p_person_id => pay_in_utils.get_person_id(p_assignment_id)
      ,p_locked        => l_locked
      ,p_lock_start    => l_date_start);
   --
    pay_in_utils.set_location(g_debug,l_procedure,20);
   --
   IF l_locked = 'N' THEN
     --
    pay_in_utils.set_location(g_debug,l_procedure,30);
     l_value := p_actual_value;
     --
   ELSE
     --
    pay_in_utils.set_location(g_debug,l_procedure,40);
     OPEN csr_entry_value(l_date_start-1);
     FETCH csr_entry_value INTO l_value;
     CLOSE csr_entry_value;

    pay_in_utils.set_location(g_debug,l_procedure,50);

     IF l_value IS NULL THEN
     pay_in_utils.set_location(g_debug, l_procedure, 60);
       OPEN csr_entry_value(SYSDATE);
       FETCH csr_entry_value INTO l_value;
       CLOSE csr_entry_value;
     END IF;

     pay_in_utils.set_location(g_debug, l_procedure, 70);
     --
   END IF;

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('l_value',l_value);
      pay_in_utils.trace('**************************************************','********************');
    END IF;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,80);
   --
   RETURN l_value;


END get_planned_value;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_VALUE                                           --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : The function calculates the planned and the actual  --
--                  values of the following elements and stores then in --
--                  the cache when the function is first called on sub- --
--                  sequent calls it would used the cached value.       --
--                    1. Rebates under Section 88                       --
--                    2. Tuition Fee                                    --
--                    3. Deductions under Chapter VI A and              --
--                    4. Other Income                                   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id NUMBER                              --
--                  p_element_name  VARCHAR2                            --
--                  p_input_name    VARCHAR2                            --
--                  p_effective_date DATE                               --
--                  p_actual_value  VARCHAR2                            --
--         RETURN : VARCHAR2                                            --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  24-Sep-2004  PUCHIL      Initial Version                        --
--------------------------------------------------------------------------
FUNCTION get_value
        (p_assignment_id   IN    number
        ,p_element_name    IN    varchar2
        ,p_input_name      IN    varchar2
        ,p_effective_date  IN    date
        ,p_actual_value    IN    varchar2
        )
RETURN VARCHAR2
IS
   --
   CURSOR csr_element_details(c_effective_date IN DATE)
   IS
   SELECT types.element_name
        , inputs.name name
        , value.screen_entry_value planned
        , value.screen_entry_value actual
   FROM per_assignments_f assgn
      , pay_element_links_f link
      , pay_element_types_f types
      , pay_element_entries_f entries
      , pay_element_entry_values_f value
      , pay_input_values_f inputs
   WHERE assgn.assignment_id = p_assignment_id
     AND link.element_link_id = pay_in_utils.get_element_link_id(p_assignment_id
                                                                ,c_effective_date
                                                                ,types.element_type_id
                                                                )
     AND (types.processing_type = 'R' OR assgn.payroll_id IS NOT NULL)
     AND link.business_group_id = assgn.business_group_id
     AND link.element_type_id = types.element_type_id
     AND types.element_name in ( 'House Rent Information'
                               , 'Rebates under Section 88'
                               , 'Tuition Fee'
                               , 'Deduction under Section 80GG'
			       , 'Deduction under Section 80D'
			       , 'Deduction under Section 80DDB'
			       , 'Deduction under Section 80GGA'
			       , 'Deduction under Section 80E'
			       , 'Deduction under Section 80U' -- Check if it is really required
                               , 'Other Income'
			       , 'Deduction under Section 80CCF'
			       , 'PF Information')
     AND entries.element_type_id = types.element_type_id
     AND entries.element_link_id = link.element_link_id
     AND entries.assignment_id = assgn.assignment_id
     AND entries.element_entry_id = value.element_entry_id
     AND inputs.input_value_id = value.input_value_id
     AND inputs.element_type_id = types.element_type_id
     AND c_effective_date BETWEEN assgn.effective_start_date
                              AND assgn.effective_end_date
     AND c_effective_date BETWEEN link.effective_start_date
                              AND link.effective_end_date
     AND c_effective_date BETWEEN types.effective_start_date
                              AND types.effective_end_date
     AND c_effective_date BETWEEN entries.effective_start_date
                              AND entries.effective_end_date
     AND c_effective_date BETWEEN inputs.effective_start_date
                              AND inputs.effective_end_date
     AND c_effective_date BETWEEN value.effective_start_date
                              AND value.effective_end_date
     order by types.element_name, inputs.name;
   --
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_locked VARCHAR2(2);
   l_date_start DATE;
   iLoop NUMBER;
   --
BEGIN
   --
   l_procedure := g_package || 'get_value';
   pay_in_utils.set_location(g_debug, 'Entering: '||l_procedure, 10);
   --
   IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('Assignment ID: ',p_assignment_id);
      pay_in_utils.trace('Element Name: ', p_element_name);
      pay_in_utils.trace('Input Name: ', p_input_name);
      pay_in_utils.trace('Effective Date: ', p_effective_date);
      pay_in_utils.trace('Actual Value? ', p_actual_value);
      pay_in_utils.trace('**************************************************','********************');
   END IF;
   --
   -- If the data in the global pl/sql table is valid
   -- then check if the assignment id's are same for
   -- the data in pl/sql table and the current assignment.
   --
   -- This is required in the case of superuser where in the
   -- same session he might query the details for more than
   -- one assignments.
   --
   IF g_is_valid THEN
      IF g_assignment_id <> p_assignment_id THEN
         --
         -- If the details are invalid requery the details.
         --
         pay_in_utils.set_location(g_debug, l_procedure, 20);
         g_is_valid := false;
         --
      END IF;
   END IF;
   --
   IF g_is_valid = false THEN
      --
      -- Entering because of either of the following reasons:
      -- 1) The pl/sql table doesn't have any data(first time).
      -- 2) Data is being requeried for a different assignment.
      --
      pay_in_utils.set_location(g_debug, l_procedure, 30);
      g_list_index := 0;
      g_assignment_id := p_assignment_id;
      --
      FOR rec_element_details IN csr_element_details(p_effective_date) LOOP
	 --
	 IF g_debug THEN
	    hr_utility.trace(g_list_index||'...Input ->' || rec_element_Details.name ||' ['||rec_element_details.planned||']');
	 END IF;
         g_element_value_list(g_list_index).element_name := rec_element_details.element_name;
         g_element_value_list(g_list_index).input_name := rec_element_details.name;
         g_element_value_list(g_list_index).planned_val := rec_element_details.planned;
         g_element_value_list(g_list_index).actual_val := rec_element_details.actual;
         g_list_index := g_list_index + 1;
	 --
      END LOOP;
      --
      pay_in_utils.set_location(g_debug, l_procedure, 40);
      --
      is_locking_period
         (p_person_id => pay_in_utils.get_person_id(p_assignment_id)
         ,p_locked         => l_locked
         ,p_lock_start     => l_date_start);
      --
      pay_in_utils.set_location(g_debug, l_procedure, 50);
      --
      IF l_locked = 'Y' THEN
         --
         pay_in_utils.set_location(g_debug, l_procedure, 60);
	 iLoop := 0;
         --
         FOR rec_element_details IN csr_element_details(l_date_start-1) LOOP
            --
            pay_in_utils.set_location(g_debug, l_procedure, 70);
            --
            IF (g_element_value_list(iLoop).element_name = rec_element_details.element_name
                AND g_element_value_list(iLoop).input_name = rec_element_details.name) THEN
               --
               pay_in_utils.set_location(g_debug, l_procedure, 80);
               g_element_value_list(iLoop).planned_val := rec_element_details.actual;
               --
            END IF;
            --
	    iLoop := iLoop+1;
            --
         END LOOP;
	 --
      END IF;
      --
   END IF;

   IF g_debug THEN
      hr_utility.trace('List Index: ' || g_list_index);
   END IF;

   IF g_list_index = 0 THEN
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,90);
   pay_in_utils.trace('**************************************************','********************');
      return null;
   ELSE
      FOR indx IN 0..g_list_index LOOP
        IF (g_element_value_list(indx).element_name = p_element_name AND
            g_element_value_list(indx).input_name = p_input_name)
        THEN
           IF g_debug THEN
              hr_utility.trace('...Value[' || g_element_value_list(indx).actual_val || ']');
           END IF;
           IF p_actual_value = 'TRUE' THEN
               pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,100);
               IF g_debug THEN
                  pay_in_utils.trace('**************************************************','********************');
                  pay_in_utils.trace('Actual Value ',g_element_value_list(indx).actual_val);
                  pay_in_utils.trace('**************************************************','********************');
               END IF;
              pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,110);
              return g_element_value_list(indx).actual_val;

           ELSE
               IF g_debug THEN
                  pay_in_utils.trace('**************************************************','********************');
                  pay_in_utils.trace('Planned Value ',g_element_value_list(indx).planned_val);
                  pay_in_utils.trace('**************************************************','********************');
               END IF;
                 pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,110);
              return g_element_value_list(indx).planned_val;
           END IF;
        END IF;
      END LOOP;
   END IF;

   pay_in_utils.trace('**************************************************','********************');
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,110);
   return null;

END get_value;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_NUMERIC_VALUE                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : The function calls get_value internally, but the    --
--                  value returned would be converted to number using   --
--                  to_number and the numeric value returned.           --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id NUMBER                              --
--                  p_element_name  VARCHAR2                            --
--                  p_input_name    VARCHAR2                            --
--                  p_effective_date DATE                               --
--                  p_actual_value  VARCHAR2                            --
--         RETURN : NUMBER                                              --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  24-Sep-2004  PUCHIL      Initial Version                        --
--------------------------------------------------------------------------
FUNCTION get_numeric_value
   (p_assignment_id   IN    number
   ,p_element_name    IN    varchar2
   ,p_input_name      IN    varchar2
   ,p_effective_date  IN    date
   ,p_actual_value    IN    varchar2
   )
RETURN NUMBER
IS
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);

BEGIN

    l_procedure := g_package || 'get_numeric_value';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('Assignment ID: ',p_assignment_id);
      pay_in_utils.trace('Element Name: ', p_element_name);
      pay_in_utils.trace('Input Name: ', p_input_name);
      pay_in_utils.trace('Effective Date: ', p_effective_date);
      pay_in_utils.trace('Actual Value? ', p_actual_value);
      pay_in_utils.trace('**************************************************','********************');
   END IF;

   IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('Value: ',to_number(get_value(p_assignment_id,p_element_name,p_input_name,p_effective_date,p_actual_value)));
      pay_in_utils.trace('**************************************************','********************');
   END IF;
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
   return to_number(get_value
                      (p_assignment_id
                      ,p_element_name
                      ,p_input_name
                      ,p_effective_date
                      ,p_actual_value
                      )
                    );

END get_numeric_value;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_LAST_UPDATED_DATE                               --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : The is called with one of these values and returns  --
--                  the last updated date of the associated element for --
--                  element type in question. The valid element types   --
--                  are:                                                --
--                      1. HOUSE                                        --
--                      2. CHAPTER6                                     --
--                      3. SECTION88                                    --
--                      4. OTHER                                        --
--                      5. ALL                                          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_person_id      NUMBER                             --
--                  p_effective_date DATE                               --
--                  p_element_type   VARCHAR2                           --
--         RETURN : NUMBER                                              --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  24-Sep-2004  PUCHIL      Initial Version                        --
--------------------------------------------------------------------------
FUNCTION get_last_updated_date
         (p_person_id      IN NUMBER
         ,p_effective_date IN DATE
         ,p_element_type   IN VARCHAR2)
RETURN DATE
IS
   CURSOR csr_get_date(c_element_name1  IN VARCHAR2
                      ,c_element_name2  IN VARCHAR2
                      ,c_element_name3  IN VARCHAR2
                      ,c_element_name4  IN VARCHAR2
                      ,c_element_name5  IN VARCHAR2
                      ,c_element_name6  IN VARCHAR2
                      ,c_element_name7  IN VARCHAR2
	              ,c_element_name8  IN VARCHAR2
	              ,c_element_name9  IN VARCHAR2
		      ,c_element_name10 IN VARCHAR2
		      ,c_element_name11 IN VARCHAR2
		      ,c_element_name12 IN VARCHAR2
                      ,c_element_name13 IN VARCHAR2
                      ,c_element_name14 IN VARCHAR2)
   IS
   SELECT MAX(entries.last_update_date)
     FROM pay_element_types_f ele
        , pay_element_entries_f entries
        , per_assignments_f assgn
    WHERE ele.element_name in (c_element_name1
                              ,c_element_name2
                              ,c_element_name3
                              ,c_element_name4
                              ,c_element_name5
                              ,c_element_name6
                              ,c_element_name7
			      ,c_element_name8
			      ,c_element_name9
			      ,c_element_name10
			      ,c_element_name11
			      ,c_element_name12
                              ,c_element_name13
			      ,c_element_name14)
      AND ele.legislation_code = 'IN'
      AND assgn.person_id = p_person_id
      AND entries.assignment_id = assgn.assignment_id
      AND entries.element_type_id = ele.element_type_id
      AND p_effective_date BETWEEN assgn.effective_start_date
                               AND assgn.effective_end_date
      AND p_effective_date BETWEEN ele.effective_start_date
                               AND ele.effective_end_date
      AND p_effective_date BETWEEN entries.effective_start_date
                               AND entries.effective_end_date;
   --
   l_updated_date DATE;
   l_procedure     VARCHAR(100);
   l_message       VARCHAR2(250);
   l_element_name1 VARCHAR2(120);
   l_element_name2 VARCHAR2(120);
   l_element_name3 VARCHAR2(120);
   l_element_name4 VARCHAR2(120);
   l_element_name5 VARCHAR2(120);
   l_element_name6 VARCHAR2(120);
   l_element_name7 VARCHAR2(120);
   l_element_name8 VARCHAR2(120);
   l_element_name9 VARCHAR2(120);
   l_element_name10 VARCHAR2(120);
   l_element_name11 VARCHAR2(120);
   l_element_name12 VARCHAR2(120);
   l_element_name13 VARCHAR2(120);
   l_element_name14 VARCHAR2(120);

   --
BEGIN
   --
    l_procedure := g_package || 'get_last_updated_date';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_person_id: ',p_person_id);
      pay_in_utils.trace('p_element_type: ', p_element_type);
      pay_in_utils.trace('Effective Date: ', p_effective_date);
      pay_in_utils.trace('**************************************************','********************');
   END IF;

   --
   IF p_element_type = 'HOUSE' THEN
      pay_in_utils.set_location(g_debug, l_procedure, 20);
      l_element_name1 := 'House Rent Information';
   ELSIF p_element_type = 'CHAPTER6' THEN
      pay_in_utils.set_location(g_debug, l_procedure, 30);
      l_element_name1 := 'Deduction under Section 80GG';
      l_element_name2 := 'Deduction under Section 80DD';
      l_element_name3 := 'Deduction under Section 80G';
      l_element_name4 := 'Deduction under Section 80D';
      l_element_name5 := 'Deduction under Section 80DDB';
      l_element_name6 := 'Deduction under Section 80E';
      l_element_name7 := 'Deduction under Section 80GGA';
      l_element_name8 := 'Deduction under Section 80CCE';
      l_element_name9 := 'Life Insurance Premium';
      l_element_name10 := 'Deduction under Section 80CCF';
   ELSIF p_element_type = 'SECTION88' THEN
      pay_in_utils.set_location(g_debug, l_procedure, 40);
--      l_element_name1 := 'Rebates under Section 88';
--      l_element_name2 := 'Tuition Fee';
--      l_element_name3 := 'Life Insurance Premium';
   ELSIF p_element_type = 'OTHER' THEN
      pay_in_utils.set_location(g_debug, l_procedure, 50);
      l_element_name1 := 'Other Income';
   ELSIF p_element_type = 'ALL' THEN
      pay_in_utils.set_location(g_debug, l_procedure, 60);
      l_element_name1 := 'House Rent Information';
      l_element_name2 := 'Deduction under Section 80GG';
      l_element_name3 := 'Deduction under Section 80DD';
      l_element_name4 := 'Deduction under Section 80G';
      l_element_name5 := 'Rebates under Section 88';
      l_element_name6 := 'Tuition Fee';
      l_element_name7 := 'Life Insurance Premium';
      l_element_name8 := 'Other Income';
      l_element_name9 := 'Deduction under Section 80D';
      l_element_name10 := 'Deduction under Section 80DDB';
      l_element_name11 := 'Deduction under Section 80E';
      l_element_name12 := 'Deduction under Section 80GGA';
      l_element_name13 := 'Deduction under Section 80CCE';
      l_element_name14 := 'Deduction under Section 80CCF';
   ELSE
      pay_in_utils.set_location(g_debug, l_procedure, 70);
      return null;
   END IF;
   --
   pay_in_utils.set_location(g_debug, l_procedure, 80);
   --
   OPEN csr_get_date(l_element_name1, l_element_name2, l_element_name3, l_element_name4,
                     l_element_name5, l_element_name6, l_element_name7, l_element_name8,
		     l_element_name9, l_element_name10, l_element_name11, l_element_name12, l_element_name13, l_element_name14);
   FETCH csr_get_date INTO l_updated_date;
   CLOSE csr_get_date;
   --
   IF g_debug THEN
   pay_in_utils.trace('**************************************************','********************');
   pay_in_utils.trace('l_updated_date',l_updated_date);
   pay_in_utils.trace('**************************************************','********************');
   END IF;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,90);
   --
   RETURN l_updated_date;


END get_last_updated_date;







PROCEDURE get_element_entry_ids
   (p_element_type_id  IN         pay_element_types_f.element_type_id%TYPE
   ,p_effective_date   IN         DATE
   ,p_expected_entries IN         NUMBER
   ,p_input_values     OUT NOCOPY t_input_values_tab)
IS

   CURSOR csr_element_inputs
     (c_element_type_id IN pay_element_types_f.element_type_id%TYPE)
   IS
   SELECT inputs.name
        , inputs.input_value_id
     FROM pay_element_types_f types
        , pay_input_values_f inputs
    WHERE types.element_type_id = c_element_type_id
      AND inputs.element_type_id = types.element_type_id
      AND inputs.legislation_code = g_legislation_code
      AND sysdate BETWEEN types.effective_start_date
                      AND types.effective_end_date
      AND sysdate BETWEEN inputs.effective_start_date
                      AND inputs.effective_end_date
    ORDER BY inputs.display_sequence;
   --
   l_count                NUMBER;
   l_procedure            VARCHAR(100);
   l_message              VARCHAR2(250);
   --
BEGIN
   --
    l_procedure := g_package || 'get_element_entry_ids';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_expected_entries: ',p_expected_entries);
      pay_in_utils.trace('p_element_type_id: ', p_element_type_id);
      pay_in_utils.trace('Effective Date: ', p_effective_date);
      pay_in_utils.trace('**************************************************','********************');
   END IF;
   --
   -- Query the details to get all the entries for the
   -- element type in question and then store it in the pl/sql table.
   l_count := 0;
   FOR rec_input_values IN csr_element_inputs(p_element_type_id)
   LOOP
     --
     pay_in_utils.set_location(g_debug, l_procedure, 20);

     p_input_values(l_count).input_value_id := rec_input_values.input_value_id;
    IF g_debug THEN
        pay_in_utils.trace('Input Name: '|| rec_input_values.name,p_input_values(l_count).input_value_id);
    END IF;
     l_count := l_count+1;
     --
   END LOOP;
   --
   pay_in_utils.set_location(g_debug, l_procedure, 30);
   --
   IF l_count < p_expected_entries THEN
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
      RETURN;
   END IF;
   --


     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,50);

END get_element_entry_ids;




PROCEDURE get_entry_details
   (p_assignment_id         IN         per_assignments_f.assignment_id%TYPE
   ,p_element_name          IN         pay_element_types_f.element_name%TYPE
   ,p_effective_date        IN         DATE
   ,p_element_type_id       OUT NOCOPY pay_element_types_f.element_type_id%TYPE
   ,p_element_link_id       OUT NOCOPY pay_element_links_f.element_link_id%TYPE
   ,p_element_entry_id      OUT NOCOPY pay_element_entries_f.element_entry_id%TYPE
   ,p_expected_entries      IN         NUMBER
   ,p_business_group_id     OUT NOCOPY per_business_groups.business_group_id%TYPE
   ,p_object_version_number OUT NOCOPY pay_element_entries_f.object_version_number%TYPE
   ,p_input_values          OUT NOCOPY t_input_values_tab
   )
IS
   --
   CURSOR csr_element_entry
     (c_element_link_id  IN pay_element_links_f.element_link_id%TYPE
     ,c_assignment_id IN per_assignments_f.assignment_id%TYPE)
   IS
   SELECT entries.element_entry_id
        , links.element_type_id
        , links.business_group_id
        , entries.object_version_number
     FROM pay_element_entries_f entries
        , pay_element_links_f links
    WHERE entries.element_link_id = links.element_link_id
      AND entries.assignment_id = c_assignment_id
      AND links.element_link_id = c_element_link_id
      AND links.element_type_id = entries.element_type_id
      AND p_effective_date BETWEEN entries.effective_start_date
                               AND entries.effective_end_date
      AND p_effective_date BETWEEN links.effective_start_date
                               AND links.effective_end_date;
   --
   CURSOR csr_element_details
     (c_element_link_id  IN pay_element_links_f.element_link_id%TYPE)
   IS
   SELECT links.element_type_id
        , links.business_group_id
     FROM pay_element_links_f links
    WHERE links.element_link_id = c_element_link_id
      AND p_effective_date BETWEEN links.effective_start_date
                               AND links.effective_end_date;
   --
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_status      VARCHAR2(30);

   --
BEGIN
   --
    l_procedure := g_package || 'get_entry_details';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id: ',p_assignment_id);
      pay_in_utils.trace('p_element_name: ', p_element_name);
      pay_in_utils.trace('Effective Date: ', p_effective_date);
      pay_in_utils.trace('p_expected_entries: ', p_expected_entries);
      pay_in_utils.trace('**************************************************','********************');
   END IF;
   --
   -- Query the link details for the assignment
   -- If link doesn't exists then error out.
   l_status := pay_in_utils.chk_element_link
                   (p_element_name => p_element_name
                   ,p_assignment_id => p_assignment_id
                   ,p_effective_date => p_effective_date
                   ,p_element_link_id => p_element_link_id);
   --
     pay_in_utils.set_location(g_debug,l_procedure,20);
   --
   IF l_status <> 'SUCCESS' THEN
      --
      hr_utility.set_message(800, 'PER_IN_MISSING_LINK');
      hr_utility.set_message_token('ELEMENT_NAME',p_element_name);
      hr_utility.raise_error;
      --
   END IF;
   --
    pay_in_utils.set_location(g_debug,l_procedure,30);
   --
   -- Query the details of the element required to update/create
   -- the element entries.
   OPEN csr_element_entry(p_element_link_id, p_assignment_id);
   FETCH csr_element_entry INTO p_element_entry_id
                              , p_element_type_id
                              , p_business_group_id
                              , p_object_version_number;
   --
   IF csr_element_entry%NOTFOUND THEN
     --
     pay_in_utils.set_location(g_debug, 'Alternate logic: ' || l_procedure, 40);
     OPEN csr_element_details(p_element_link_id);
     FETCH csr_element_details INTO p_element_type_id, p_business_group_id;
     CLOSE csr_element_details;
     --
   END IF;
   --
   CLOSE csr_element_entry;
   --
    pay_in_utils.set_location(g_debug,l_procedure,40);
   --
   IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('Element Link ID: ', p_element_link_id);
      pay_in_utils.trace('Element Type ID: ', p_element_type_id);
      pay_in_utils.trace('Element Entry ID: ', p_element_entry_id);
      pay_in_utils.trace('Business Group : ', p_business_group_id);
      pay_in_utils.trace('p_object_version_number : ', p_object_version_number);
      pay_in_utils.trace('**************************************************','********************');
   --
   END IF;
   --
    pay_in_utils.set_location(g_debug,l_procedure,50);
   --
   -- Fetch all the input IDs into the pl/sql table
   -- These IDs would be used by the calling function.
   get_element_entry_ids(p_element_type_id
                        ,p_effective_date
                        ,p_expected_entries
                        ,p_input_values);
   --
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,60);

END get_entry_details;




FUNCTION get_update_mode
   (p_element_entry_id IN pay_element_entries_f.element_entry_id%TYPE
   ,p_effective_date   IN DATE)
RETURN VARCHAR2
IS
   --
     l_procedure            VARCHAR(100);
     l_message              VARCHAR2(250);
     l_correction           BOOLEAN;
     l_update               BOOLEAN;
     l_update_override      BOOLEAN;
     l_update_change_insert BOOLEAN;
     l_update_mode          VARCHAR2(30);
   --
BEGIN
   --
    l_procedure := g_package || 'get_update_mode';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_element_entry_id: ',p_element_entry_id);
      pay_in_utils.trace('Effective Date: ', p_effective_date);
      pay_in_utils.trace('**************************************************','********************');
   END IF;
   --
   -- Use the dt_api to get the valid values for the update mode
   dt_api.find_dt_upd_modes
      (p_effective_date      => p_effective_date
      ,p_base_table_name     => 'pay_element_entries_f'
      ,p_base_key_column     => 'element_entry_id'
      ,p_base_key_value      => p_element_entry_id
      ,p_correction          => l_correction
      ,p_update              => l_update
      ,p_update_override     => l_update_override
      ,p_update_change_insert=> l_update_change_insert);
   --
   pay_in_utils.set_location(g_debug, l_procedure, 20);
   --
   -- Check which flag has been set by DT_API.Find_DT_Upd_Modes
   -- Correction is always set to true hence check it's value at last
   -- as default. If effective start date is not same as effective date, then
   -- If any future row exists for element, then Update is false and Update
   -- override and Update Change Insert is set to true.
   -- If there are no future row exists then Update mode is used.
   --
   -- No need to use update_change_insert mode as both update_override
   -- and update_change_insert are always set to true or false.
   IF l_update THEN
      l_update_mode := hr_api.g_update;
   ELSIF l_update_override THEN
      l_update_mode := hr_api.g_update_override;
   ELSIF l_correction THEN
      l_update_mode := hr_api.g_correction;
   ELSE
      l_update_mode := hr_api.g_correction;
   END IF;
   --

   IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('l_update_mode : ',l_update_mode);
      pay_in_utils.trace('**************************************************','********************');
   END IF;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);

   RETURN l_update_mode;


END get_update_mode;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_HOUSE_RENT                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the detials--
--                  in 'House Rent Information' element.                --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_apr             NUMBER                            --
--                  p_may             NUMBER                            --
--                  p_jun             NUMBER                            --
--                  p_jul             NUMBER                            --
--                  p_aug             NUMBER                            --
--                  p_sep             NUMBER                            --
--                  p_oct             NUMBER                            --
--                  p_nov             NUMBER                            --
--                  p_dec             NUMBER                            --
--                  p_jan             NUMBER                            --
--                  p_feb             NUMBER                            --
--                  p_mar             NUMBER                            --
--                  p_effective_date  DATE                              --
--            OUT : p_warnings        BOOLEAN                           --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  24-Sep-2004  PUCHIL      Initial Version                        --
--------------------------------------------------------------------------
PROCEDURE declare_house_rent
   (p_assignment_id  IN per_assignments_f.assignment_id%TYPE
   ,p_apr            IN NUMBER
   ,p_may            IN NUMBER
   ,p_jun            IN NUMBER
   ,p_jul            IN NUMBER
   ,p_aug            IN NUMBER
   ,p_sep            IN NUMBER
   ,p_oct            IN NUMBER
   ,p_nov            IN NUMBER
   ,p_dec            IN NUMBER
   ,p_jan            IN NUMBER
   ,p_feb            IN NUMBER
   ,p_mar            IN NUMBER
   ,p_effective_date IN DATE DEFAULT NULL
   ,p_warnings       OUT NOCOPY BOOLEAN)
IS
   --
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_input_values t_input_values_tab;
   l_element_type_id  pay_element_types_f.element_type_id%TYPE;
   l_element_link_id      pay_element_links_f.element_link_id%TYPE;
   l_element_entry_id pay_element_entries_f.element_entry_id%TYPE;
   l_business_group_id per_business_groups.business_group_id%TYPE;
   l_object_version_number pay_element_entries_f.object_version_number%TYPE;
   l_effective_start_date DATE;
   l_effective_end_date DATE;
   l_effective_date DATE;
   l_warnings VARCHAR2(6);
   --
BEGIN
   --
    l_procedure := g_package || 'declare_house_rent';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id  ',p_assignment_id);
      pay_in_utils.trace('p_apr ',p_apr);
      pay_in_utils.trace('p_may ',p_may);
      pay_in_utils.trace('p_jun ',p_jun);
      pay_in_utils.trace('p_jul ',p_jul);
      pay_in_utils.trace('p_aug ',p_aug);
      pay_in_utils.trace('p_sep ',p_sep);
      pay_in_utils.trace('p_oct ',p_oct);
      pay_in_utils.trace('p_nov ',p_nov);
      pay_in_utils.trace('p_dec ',p_dec);
      pay_in_utils.trace('p_jan ',p_jan);
      pay_in_utils.trace('p_feb ',p_feb);
      pay_in_utils.trace('p_mar ',p_mar);
      pay_in_utils.trace('p_effective_date ',p_effective_date);
      pay_in_utils.trace('**************************************************','********************');
    END IF;
   --
   l_effective_date := pay_in_utils.get_effective_date(p_effective_date);
   --
   get_entry_details(p_assignment_id        => p_assignment_id
                    ,p_element_name         => 'House Rent Information'
                    ,p_effective_date       => l_effective_date
                    ,p_element_type_id      => l_element_type_id
                    ,p_element_link_id      => l_element_link_id
                    ,p_element_entry_id     => l_element_entry_id
                    ,p_expected_entries     => 12
                    ,p_business_group_id    => l_business_group_id
                    ,p_object_version_number=> l_object_version_number
                    ,p_input_values         => l_input_values
                    );
   --
   IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('Element Type ID: ',l_element_type_id);
      pay_in_utils.trace('Element Entry ID: ', l_element_entry_id);
      pay_in_utils.trace('Business Group ID: ', l_business_group_id);
      pay_in_utils.trace('Object Version Number: ', l_object_version_number);
      pay_in_utils.trace('**************************************************','********************');
   END IF;
   --
   pay_in_utils.set_location(g_debug, l_procedure, 20);
   --
   IF l_element_entry_id is null THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 30);
      --
      -- In this case, we would have to create an element entry to the
      -- assignment and return the entry id, the rest would be handled
      -- by the update command in the calling procedure.
      --
      pay_element_entry_api.create_element_entry
         (p_effective_date        => l_effective_date
         ,p_business_group_id     => l_business_group_id
         ,p_assignment_id         => p_assignment_id
         ,p_element_link_id       => l_element_link_id
         ,p_entry_type            => 'E'
          -- April
         ,p_input_value_id1          => l_input_values(0).input_value_id
          -- May
         ,p_input_value_id2          => l_input_values(1).input_value_id
          -- June
         ,p_input_value_id3          => l_input_values(2).input_value_id
          -- July
         ,p_input_value_id4          => l_input_values(3).input_value_id
          -- August
         ,p_input_value_id5          => l_input_values(4).input_value_id
          -- September
         ,p_input_value_id6          => l_input_values(5).input_value_id
          -- October
         ,p_input_value_id7          => l_input_values(6).input_value_id
          -- November
         ,p_input_value_id8          => l_input_values(7).input_value_id
          -- December
         ,p_input_value_id9          => l_input_values(8).input_value_id
          -- January
         ,p_input_value_id10         => l_input_values(9).input_value_id
          -- February
         ,p_input_value_id11         => l_input_values(10).input_value_id
          -- March
         ,p_input_value_id12         => l_input_values(11).input_value_id
         ,p_entry_value1             => p_apr
         ,p_entry_value2             => p_may
         ,p_entry_value3             => p_jun
         ,p_entry_value4             => p_jul
         ,p_entry_value5             => p_aug
         ,p_entry_value6             => p_sep
         ,p_entry_value7             => p_oct
         ,p_entry_value8             => p_nov
         ,p_entry_value9             => p_dec
         ,p_entry_value10            => p_jan
         ,p_entry_value11            => p_feb
         ,p_entry_value12            => p_mar
         ,p_effective_start_date  => l_effective_start_date
         ,p_effective_end_date    => l_effective_end_date
         ,p_element_entry_id      => l_element_entry_id
         ,p_object_version_number => l_object_version_number
         ,p_create_warning        => p_warnings
         );
      --
      pay_in_utils.set_location(g_debug, l_procedure, 40);
      --
      -- End date the entry as of the financial year end date
      --
      delete_declaration
         (p_element_entry_id => l_element_entry_id
         ,p_effective_date   => pay_in_utils.next_tax_year(l_effective_date)-1
         ,p_warnings         => l_warnings);
      --
   ELSE
      --
      pay_in_utils.set_location(g_debug, l_procedure, 50);
      --
      -- An element entry for this element already exists we have to
      -- update the element entry with the newly submitted date.
      --
        pay_element_entry_api.update_element_entry
         (p_datetrack_update_mode    => get_update_mode(l_element_entry_id
                                                       ,l_effective_date)
         ,p_effective_date           => l_effective_date
         ,p_business_group_id        => l_business_group_id
         ,p_element_entry_id         => l_element_entry_id
         ,p_object_version_number    => l_object_version_number
          -- April
         ,p_input_value_id1          => l_input_values(0).input_value_id
          -- May
         ,p_input_value_id2          => l_input_values(1).input_value_id
          -- June
         ,p_input_value_id3          => l_input_values(2).input_value_id
          -- July
         ,p_input_value_id4          => l_input_values(3).input_value_id
          -- August
         ,p_input_value_id5          => l_input_values(4).input_value_id
          -- September
         ,p_input_value_id6          => l_input_values(5).input_value_id
          -- October
         ,p_input_value_id7          => l_input_values(6).input_value_id
          -- November
         ,p_input_value_id8          => l_input_values(7).input_value_id
          -- December
         ,p_input_value_id9          => l_input_values(8).input_value_id
          -- January
         ,p_input_value_id10         => l_input_values(9).input_value_id
          -- February
         ,p_input_value_id11         => l_input_values(10).input_value_id
          -- March
         ,p_input_value_id12         => l_input_values(11).input_value_id
         ,p_entry_value1             => p_apr
         ,p_entry_value2             => p_may
         ,p_entry_value3             => p_jun
         ,p_entry_value4             => p_jul
         ,p_entry_value5             => p_aug
         ,p_entry_value6             => p_sep
         ,p_entry_value7             => p_oct
         ,p_entry_value8             => p_nov
         ,p_entry_value9             => p_dec
         ,p_entry_value10            => p_jan
         ,p_entry_value11            => p_feb
         ,p_entry_value12            => p_mar
         ,p_effective_start_date     => l_effective_start_date
         ,p_effective_end_date       => l_effective_end_date
         ,p_update_warning           => p_warnings
         );
      --
      pay_in_utils.set_location(g_debug, l_procedure, 60);
      --
      IF l_effective_end_date <> (pay_in_utils.next_tax_year(l_effective_date)-1)
      THEN
        --
        -- End date the entry as of the financial year end date
        --
        delete_declaration
           (p_element_entry_id =>l_element_entry_id
           ,p_effective_date   =>pay_in_utils.next_tax_year(l_effective_date)-1
           ,p_warnings         =>l_warnings);
        --
      END IF;
      --
   END IF;
   --
      pay_in_utils.trace('Effective Start Date: ', l_effective_start_date);
      pay_in_utils.trace('Effective End Date: ', l_effective_end_date);
      pay_in_utils.set_location(g_debug,l_procedure,70);

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,80);
   --
EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
         (p_pkg_name => g_package
         ,p_procedure_name => 'declare_house_rent'
         ,p_error_text => substr(sqlerrm, 1, 240)
         );
   --
END declare_house_rent;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_CHAPTER6A                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure calculates the value of permanent     --
--                  disability 80u and then stores the detials in the   --
--                  'Deductions under Chapter VI A' element.            --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_pension_fund_80ccc           NUMBER               --
--                  p_medical_insurance_prem_80d   NUMBER               --
--                  p_sec_80ddb_senior_citizen     VARCHAR2             --
--                  p_disease_treatment_80ddb      NUMBER               --
--                  p_sec_80d_senior_citizen       VARCHAR2             --
--                  p_higher_education_loan_80e    NUMBER               --
--                  p_claim_exemp_under_sec_80gg   VARCHAR2             --
--                  p_donation_for_research_80gga  NUMBER               --
--                  p_int_on_gen_investment_80L    NUMBER               --
--                  p_int_on_securities_80L        NUMBER               --
--                  p_effective_date               DATE                 --
--            OUT : p_warnings        BOOLEAN                           --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  24-Sep-2004  PUCHIL      Initial Version                        --
--------------------------------------------------------------------------
PROCEDURE declare_chapter6a
   (p_assignment_id                   IN   per_assignments_f.assignment_id%TYPE
   ,p_pension_fund_80ccc              IN   NUMBER
   ,p_medical_insurance_prem_80d      IN   NUMBER
   ,p_sec_80ddb_senior_citizen        IN   VARCHAR2
   ,p_disease_treatment_80ddb         IN   NUMBER
   ,p_sec_80d_senior_citizen          IN   VARCHAR2
   ,p_higher_education_loan_80e       IN   NUMBER
   ,p_claim_exemp_under_sec_80gg      IN   VARCHAR2
   ,p_donation_for_research_80gga     IN   NUMBER
   ,p_int_on_gen_investment_80L       IN   NUMBER
   ,p_int_on_securities_80L           IN   NUMBER
   ,p_effective_date                  IN   DATE DEFAULT NULL
   ,p_warnings                        OUT  NOCOPY BOOLEAN)
IS
   --
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_disability_proof VARCHAR2(2);
   l_permanent_disability_80u NUMBER;
   l_input_values t_input_values_tab;
   l_element_type_id  pay_element_types_f.element_type_id%TYPE;
   l_element_link_id      pay_element_links_f.element_link_id%TYPE;
   l_element_entry_id pay_element_entries_f.element_entry_id%TYPE;
   l_business_group_id per_business_groups.business_group_id%TYPE;
   l_object_version_number pay_element_entries_f.object_version_number%TYPE;
   l_effective_start_date DATE;
   l_effective_end_date DATE;
   l_effective_date DATE;
   l_endation_date DATE;
   l_category VARCHAR2(10);
   l_degree NUMBER;
   l_warnings VARCHAR2(6);
   --
   CURSOR get_permanent_disability_80u
   IS
   SELECT global_value
     FROM ff_globals_f
    WHERE global_name = 'IN_PERMANENT_PHYSICAL_DISABILITY_80U'
      AND legislation_code = g_legislation_code;
BEGIN
   --
    l_procedure := g_package || 'declare_chapter6a';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id',p_assignment_id);
      pay_in_utils.trace('p_pension_fund_80ccc',p_pension_fund_80ccc);
      pay_in_utils.trace('p_medical_insurance_prem_80d',p_medical_insurance_prem_80d);
      pay_in_utils.trace('p_sec_80ddb_senior_citizen',p_sec_80ddb_senior_citizen);
      pay_in_utils.trace('p_disease_treatment_80ddb',p_disease_treatment_80ddb);
      pay_in_utils.trace('p_sec_80d_senior_citizen',p_sec_80d_senior_citizen);
      pay_in_utils.trace('p_higher_education_loan_80e',p_higher_education_loan_80e);
      pay_in_utils.trace('p_claim_exemp_under_sec_80gg',p_claim_exemp_under_sec_80gg);
      pay_in_utils.trace('p_donation_for_research_80gga',p_donation_for_research_80gga);
      pay_in_utils.trace('p_int_on_gen_investment_80L',p_int_on_gen_investment_80L);
      pay_in_utils.trace('p_int_on_securities_80L',p_int_on_securities_80L);
      pay_in_utils.trace('p_effective_date',p_effective_date);
      pay_in_utils.trace('**************************************************','********************');
    END IF;
   --
   l_effective_date := pay_in_utils.get_effective_date(p_effective_date);
   --
   -- Permanent Disability 80u Calculation
   -- Permanent disability is calculated based on the details
   -- entered in per_disabilities_f by the user. If the
   -- disability proof is submitted then only the exemption
   -- amount is entered i.e., when l_disability_proof = 'Y'.
   l_permanent_disability_80u :=
      pay_in_tax_utils.get_disability_details
         (p_assignment_id => p_assignment_id
         ,p_date_earned   => l_effective_date
         ,p_disable_catg  => l_category
         ,p_disable_degree=> l_degree
         ,p_disable_proof => l_disability_proof
         );
   --
   l_permanent_disability_80u := 0;
   --
   IF (l_disability_proof = 'Y' AND l_degree >= 40 AND l_category IN ('BLIND','SA_VIS_IMP','LC','SA_HEA_IMP','LD','07','MI','AU','CP','MD'))
   THEN
      --
      OPEN get_permanent_disability_80u;
      FETCH get_permanent_disability_80u INTO l_permanent_disability_80u;
      CLOSE get_permanent_disability_80u;
      --
   END IF;
   --

   get_entry_details(p_assignment_id        => p_assignment_id
                    ,p_element_name         => 'Deductions under Chapter VI A'
                    ,p_effective_date       => l_effective_date
                    ,p_element_type_id      => l_element_type_id
                    ,p_element_link_id      => l_element_link_id
                    ,p_element_entry_id     => l_element_entry_id
                    ,p_expected_entries     => 11
                    ,p_business_group_id    => l_business_group_id
                    ,p_object_version_number=> l_object_version_number
                    ,p_input_values         => l_input_values
                    );
   --
   IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('Element Type ID: ',l_element_type_id);
      pay_in_utils.trace('Element Entry ID: ',l_element_entry_id);
      pay_in_utils.trace('Business Group ID: ',l_business_group_id);
      pay_in_utils.trace('Object Version Number: ',l_object_version_number);
      pay_in_utils.trace('**************************************************','********************');
   END IF;
   --
   pay_in_utils.set_location(g_debug, l_procedure, 20);
   --
   IF l_element_entry_id is null THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 30);
      --
      --
      -- In this case, we would have to create an element entry to the
      -- assignment and return the entry id, the rest would be handled
      -- by the update command in the calling procedure.
      --
      pay_element_entry_api.create_element_entry
         (p_effective_date        => l_effective_date
         ,p_business_group_id     => l_business_group_id
         ,p_assignment_id         => p_assignment_id
         ,p_element_link_id       => l_element_link_id
         ,p_entry_type            => 'E'
           --Pension Fund 80CCC
         ,p_input_value_id1          => l_input_values(0).input_value_id
           --Medical Insurance Premium 80D
         ,p_input_value_id2          => l_input_values(1).input_value_id
           --Sec 80DDB Cover Senior Citizen
         ,p_input_value_id3          => l_input_values(2).input_value_id
           --Disease Treatment 80DDB
         ,p_input_value_id4          => l_input_values(3).input_value_id
           --Sec 80D Cover Senior Citizen
         ,p_input_value_id5          => l_input_values(4).input_value_id
           --Higher Education Loan 80E
         ,p_input_value_id6          => l_input_values(5).input_value_id
           --Claim Exemption under Sec 80GG
         ,p_input_value_id7          => l_input_values(6).input_value_id
           --Donation for Research 80GGA
         ,p_input_value_id8          => l_input_values(7).input_value_id
           --Int on Gen Investment 80L
         ,p_input_value_id9          => l_input_values(8).input_value_id
           --Int on Securities 80L
         ,p_input_value_id10         => l_input_values(9).input_value_id
           --Permanent Disability 80U
         ,p_input_value_id11         => l_input_values(10).input_value_id
         ,p_entry_value1             => p_pension_fund_80ccc
         ,p_entry_value2             => p_medical_insurance_prem_80d
         ,p_entry_value3             => p_sec_80ddb_senior_citizen
         ,p_entry_value4             => p_disease_treatment_80ddb
         ,p_entry_value5             => p_sec_80d_senior_citizen
         ,p_entry_value6             => p_higher_education_loan_80e
         ,p_entry_value7             => p_claim_exemp_under_sec_80gg
         ,p_entry_value8             => p_donation_for_research_80gga
         ,p_entry_value9             => p_int_on_gen_investment_80L
         ,p_entry_value10            => p_int_on_securities_80L
         ,p_entry_value11            => l_permanent_disability_80u
         ,p_effective_start_date     => l_effective_start_date
         ,p_effective_end_date       => l_effective_end_date
         ,p_element_entry_id         => l_element_entry_id
         ,p_object_version_number    => l_object_version_number
         ,p_create_warning           => p_warnings
         );
      --
      pay_in_utils.set_location(g_debug, l_procedure, 40);
      --
      -- End date the entry as of the financial year end date
      --
      IF l_disability_proof = 'N' THEN
        --
        --
        pay_in_utils.set_location(g_debug, l_procedure, 45);
        --
        delete_declaration
           (p_element_entry_id => l_element_entry_id
           ,p_effective_date   => pay_in_utils.next_tax_year(l_effective_date)-1
           ,p_warnings         => l_warnings);
        --
      END IF;
      --
   ELSE
      --
      pay_in_utils.set_location(g_debug, l_procedure, 50);
      --
      --
      -- An element entry for this element already exists we have to
      -- update the element entry with the newly submitted date.
      --
        pay_element_entry_api.update_element_entry
         (p_datetrack_update_mode    => get_update_mode(l_element_entry_id
                                                       ,l_effective_date)
         ,p_effective_date           => l_effective_date
         ,p_business_group_id        => l_business_group_id
         ,p_element_entry_id         => l_element_entry_id
         ,p_object_version_number    => l_object_version_number
           --Pension Fund 80CCC
         ,p_input_value_id1          => l_input_values(0).input_value_id
           --Medical Insurance Premium 80D
         ,p_input_value_id2          => l_input_values(1).input_value_id
           --Sec 80DDB Cover Senior Citizen
         ,p_input_value_id3          => l_input_values(2).input_value_id
           --Disease Treatment 80DDB
         ,p_input_value_id4          => l_input_values(3).input_value_id
           --Sec 80D Cover Senior Citizen
         ,p_input_value_id5          => l_input_values(4).input_value_id
           --Higher Education Loan 80E
         ,p_input_value_id6          => l_input_values(5).input_value_id
           --Claim Exemption under Sec 80GG
         ,p_input_value_id7          => l_input_values(6).input_value_id
           --Donation for Research 80GGA
         ,p_input_value_id8          => l_input_values(7).input_value_id
           --Int on Gen Investment 80L
         ,p_input_value_id9          => l_input_values(8).input_value_id
           --Int on Securities 80L
         ,p_input_value_id10         => l_input_values(9).input_value_id
         ,p_entry_value1             => p_pension_fund_80ccc
         ,p_entry_value2             => p_medical_insurance_prem_80d
         ,p_entry_value3             => p_sec_80ddb_senior_citizen
         ,p_entry_value4             => p_disease_treatment_80ddb
         ,p_entry_value5             => p_sec_80d_senior_citizen
         ,p_entry_value6             => p_higher_education_loan_80e
         ,p_entry_value7             => p_claim_exemp_under_sec_80gg
         ,p_entry_value8             => p_donation_for_research_80gga
         ,p_entry_value9             => p_int_on_gen_investment_80L
         ,p_entry_value10            => p_int_on_securities_80L
         ,p_effective_start_date     => l_effective_start_date
         ,p_effective_end_date       => l_effective_end_date
         ,p_update_warning           => p_warnings
         );
      --
      --
      pay_in_utils.set_location(g_debug, l_procedure, 60);
      --
      l_endation_date := pay_in_utils.next_tax_year(l_effective_date);
      --
      IF l_effective_end_date <> (l_endation_date-1)
      THEN
        --
        -- End date the entry as of the financial year end date
        --
        pay_in_utils.set_location(g_debug, l_procedure, 70);
        --
        IF l_disability_proof = 'Y' THEN
          --
          --
            pay_in_utils.set_location(g_debug, l_procedure, 80);
            --
            pay_element_entry_api.update_element_entry
             (p_datetrack_update_mode    => get_update_mode(l_element_entry_id
                                                           ,l_endation_date)
             ,p_effective_date           => l_endation_date
             ,p_business_group_id        => l_business_group_id
             ,p_element_entry_id         => l_element_entry_id
             ,p_object_version_number    => l_object_version_number
               --Pension Fund 80CCC
             ,p_input_value_id1          => l_input_values(0).input_value_id
                --Medical Insurance Premium 80D
             ,p_input_value_id2          => l_input_values(1).input_value_id
               --Sec 80DDB Cover Senior Citizen
             ,p_input_value_id3          => l_input_values(2).input_value_id
               --Disease Treatment 80DDB
             ,p_input_value_id4          => l_input_values(3).input_value_id
               --Sec 80D Cover Senior Citizen
             ,p_input_value_id5          => l_input_values(4).input_value_id
               --Higher Education Loan 80E
             ,p_input_value_id6          => l_input_values(5).input_value_id
               --Claim Exemption under Sec 80GG
             ,p_input_value_id7          => l_input_values(6).input_value_id
               --Donation for Research 80GGA
             ,p_input_value_id8          => l_input_values(7).input_value_id
               --Int on Gen Investment 80L
             ,p_input_value_id9          => l_input_values(8).input_value_id
               --Int on Securities 80L
             ,p_input_value_id10         => l_input_values(9).input_value_id
             ,p_entry_value1             => 0
             ,p_entry_value2             => 0
             ,p_entry_value3             => 'N'
             ,p_entry_value4             => 0
             ,p_entry_value5             => 'N'
             ,p_entry_value6             => 0
             ,p_entry_value7             => 'N'
             ,p_entry_value8             => 0
             ,p_entry_value9             => 0
             ,p_entry_value10            => 0
             ,p_effective_start_date     => l_effective_start_date
             ,p_effective_end_date       => l_effective_end_date
             ,p_update_warning           => p_warnings
             );
          --
        ELSE
          --
            pay_in_utils.set_location(g_debug, l_procedure, 90);
            --
            delete_declaration
             (p_element_entry_id => l_element_entry_id
             ,p_effective_date   => l_endation_date-1
             ,p_warnings         => l_warnings);
          --
        END IF;
        --
      END IF;
      --
   END IF;
   --
   IF g_debug THEN
      pay_in_utils.trace('Effective Start Date: ', l_effective_start_date);
      pay_in_utils.trace('Effective End Date: ', l_effective_end_date);
   END IF;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
   --
EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
         (p_pkg_name => g_package
         ,p_procedure_name => 'declare_chapter6a'
         ,p_error_text => substr(sqlerrm, 1, 240)
         );
   --
END declare_chapter6a;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_SECTION88                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the detials--
--                  in 'Rebates under Section 88' element.              --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_public_provident_fund           NUMBER            --
--                  p_post_office_savings_scheme      NUMBER            --
--                  p_deposit_in_nsc_vi_issue         NUMBER            --
--                  p_deposit_in_nsc_viii_issue       NUMBER            --
--                  p_interest_on_nsc_reinvested      NUMBER            --
--                  p_house_loan_repayment            NUMBER            --
--                  p_notified_mutual_fund_or_uti     NUMBER            --
--                  p_national_housing_bank_scheme    NUMBER            --
--                  p_unit_linked_insurance_plan      NUMBER            --
--                  p_notified_annuity_plan           NUMBER            --
--                  p_notified_pension_fund           NUMBER            --
--                  p_public_sector_company_scheme    NUMBER            --
--                  p_approved_superannuation_fund    NUMBER            --
--                  p_infrastructure_bond             NUMBER            --
--                  p_effective_date                  DATE              --
--            OUT : p_warnings        BOOLEAN                           --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  24-Sep-2004  PUCHIL      Initial Version                        --
-- 1.1  25-Apr-2005  VGSRINIV    Nulled out for stat update(Bug 4251141)--
--------------------------------------------------------------------------
PROCEDURE declare_section88
   (p_assignment_id                  IN per_assignments_f.assignment_id%TYPE
   ,p_deferred_annuity               IN NUMBER
   ,p_senior_citizen_sav_scheme      IN NUMBER
   ,p_public_provident_fund          IN NUMBER
   ,p_post_office_savings_scheme     IN NUMBER
   ,p_deposit_in_nsc_vi_issue        IN NUMBER
   ,p_deposit_in_nsc_viii_issue      IN NUMBER
   ,p_interest_on_nsc_reinvested     IN NUMBER
   ,p_house_loan_repayment           IN NUMBER
   ,p_notified_mutual_fund_or_uti    IN NUMBER
   ,p_national_housing_bank_scheme   IN NUMBER
   ,p_unit_linked_insurance_plan     IN NUMBER
   ,p_notified_annuity_plan          IN NUMBER
   ,p_notified_pension_fund          IN NUMBER
   ,p_public_sector_company_scheme   IN NUMBER
   ,p_approved_superannuation_fund   IN NUMBER
   ,p_infrastructure_bond            IN NUMBER
   ,p_effective_date                 IN DATE DEFAULT NULL
   ,p_warnings                       OUT NOCOPY BOOLEAN)
IS
   --
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_input_values t_input_values_tab;
   l_element_type_id  pay_element_types_f.element_type_id%TYPE;
   l_element_link_id      pay_element_links_f.element_link_id%TYPE;
   l_element_entry_id pay_element_entries_f.element_entry_id%TYPE;
   l_business_group_id per_business_groups.business_group_id%TYPE;
   l_object_version_number pay_element_entries_f.object_version_number%TYPE;
   l_effective_start_date DATE;
   l_effective_end_date DATE;
   l_effective_date DATE;
   l_warnings VARCHAR2(6);
   --
BEGIN
   --
    l_procedure := g_package || 'declare_section88';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id',p_assignment_id);
      pay_in_utils.trace('p_deferred_annuity',p_deferred_annuity);
      pay_in_utils.trace('p_senior_citizen_sav_scheme',p_senior_citizen_sav_scheme);
      pay_in_utils.trace('p_public_provident_fund',p_public_provident_fund);
      pay_in_utils.trace('p_post_office_savings_scheme',p_post_office_savings_scheme);
      pay_in_utils.trace('p_deposit_in_nsc_vi_issue',p_deposit_in_nsc_vi_issue);
      pay_in_utils.trace('p_deposit_in_nsc_viii_issue',p_deposit_in_nsc_viii_issue);
      pay_in_utils.trace('p_interest_on_nsc_reinvested',p_interest_on_nsc_reinvested);
      pay_in_utils.trace('p_house_loan_repayment',p_house_loan_repayment);
      pay_in_utils.trace('p_notified_mutual_fund_or_uti',p_notified_mutual_fund_or_uti);
      pay_in_utils.trace('p_national_housing_bank_scheme',p_national_housing_bank_scheme);
      pay_in_utils.trace('p_unit_linked_insurance_plan',p_unit_linked_insurance_plan);
      pay_in_utils.trace('p_notified_annuity_plan',p_notified_annuity_plan);
      pay_in_utils.trace('p_notified_pension_fund',p_notified_pension_fund);
      pay_in_utils.trace('p_public_sector_company_scheme',p_public_sector_company_scheme);
      pay_in_utils.trace('p_approved_superannuation_fund',p_approved_superannuation_fund);
      pay_in_utils.trace('p_infrastructure_bond',p_infrastructure_bond);
      pay_in_utils.trace('p_effective_date',p_effective_date);
      pay_in_utils.trace('**************************************************','********************');
    END IF;


   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
   --
EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
         (p_pkg_name => g_package
         ,p_procedure_name => 'declare_section88'
         ,p_error_text => substr(sqlerrm, 1, 240)
         );
   --
END declare_section88;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_OTHER_INCOME                                --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Other Income' element.                  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_income_from_house_property     NUMBER             --
--                  p_profit_and_gain_from_busines   NUMBER             --
--                  p_long_term_capital_gain         NUMBER             --
--                  p_short_term_capital_gain        NUMBER             --
--                  p_income_from_any_other_source   NUMBER             --
--                  p_tds_paid_on_other_income       NUMBER             --
--                  p_effective_date                  DATE              --
--            OUT : p_warnings        BOOLEAN                           --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  24-Sep-2004  PUCHIL      Initial Version                        --
--------------------------------------------------------------------------
PROCEDURE declare_other_income
   (p_assignment_id                 IN per_assignments_f.assignment_id%TYPE
   ,p_income_from_house_property    IN NUMBER
   ,p_profit_and_gain_from_busines  IN NUMBER
   ,p_long_term_capital_gain        IN NUMBER
   ,p_short_term_capital_gain       IN NUMBER
   ,p_income_from_any_other_source  IN NUMBER
   ,p_tds_paid_on_other_income      IN NUMBER
   ,p_effective_date                IN DATE DEFAULT NULL
   ,p_warnings                      OUT NOCOPY BOOLEAN)
IS
   --
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_input_values t_input_values_tab;
   l_element_type_id  pay_element_types_f.element_type_id%TYPE;
   l_element_link_id      pay_element_links_f.element_link_id%TYPE;
   l_element_entry_id pay_element_entries_f.element_entry_id%TYPE;
   l_business_group_id per_business_groups.business_group_id%TYPE;
   l_object_version_number pay_element_entries_f.object_version_number%TYPE;
   l_effective_start_date DATE;
   l_effective_end_date DATE;
   l_effective_date DATE;
   l_warnings VARCHAR2(6);
   --
BEGIN
   --
    l_procedure := g_package || 'declare_other_income';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id',p_assignment_id);
      pay_in_utils.trace('p_income_from_house_property  ',p_income_from_house_property );
      pay_in_utils.trace('p_profit_and_gain_from_busines',p_profit_and_gain_from_busines);
      pay_in_utils.trace('p_long_term_capital_gain      ',p_long_term_capital_gain );
      pay_in_utils.trace('p_short_term_capital_gain     ',p_short_term_capital_gain);
      pay_in_utils.trace('p_income_from_any_other_source',p_income_from_any_other_source);
      pay_in_utils.trace('p_tds_paid_on_other_income    ',p_tds_paid_on_other_income);
      pay_in_utils.trace('**************************************************','********************');
    END IF;
   --
   l_effective_date := pay_in_utils.get_effective_date(p_effective_date);
   --
   get_entry_details(p_assignment_id        => p_assignment_id
                    ,p_element_name         => 'Other Income'
                    ,p_effective_date       => l_effective_date
                    ,p_element_type_id      => l_element_type_id
                    ,p_element_link_id      => l_element_link_id
                    ,p_element_entry_id     => l_element_entry_id
                    ,p_expected_entries     => 6
                    ,p_business_group_id    => l_business_group_id
                    ,p_object_version_number=> l_object_version_number
                    ,p_input_values         => l_input_values
                    );
   --
   IF g_debug THEN
      pay_in_utils.trace('Element Type ID: ', l_element_type_id);
      pay_in_utils.trace('Element Entry ID: ', l_element_entry_id);
      pay_in_utils.trace('Business Group ID: ', l_business_group_id);
      pay_in_utils.trace('Object Version Number: ', l_object_version_number);
      pay_in_utils.set_location(g_debug,l_procedure,20);
   END IF;
   --
   pay_in_utils.set_location(g_debug, l_procedure, 20);
   --
   IF l_element_entry_id is null THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 30);
      --
      --
      -- In this case, we would have to create an element entry to the
      -- assignment and return the entry id, the rest would be handled
      -- by the update command in the calling procedure.
      --
      pay_element_entry_api.create_element_entry
         (p_effective_date        => l_effective_date
         ,p_business_group_id     => l_business_group_id
         ,p_assignment_id         => p_assignment_id
         ,p_element_link_id       => l_element_link_id
         ,p_entry_type            => 'E'
           -- Income from House Property
         ,p_input_value_id1       => l_input_values(0).input_value_id
           -- Profit and Gain from Business
         ,p_input_value_id2       => l_input_values(1).input_value_id
           -- Long Term Capital Gain
         ,p_input_value_id3       => l_input_values(2).input_value_id
           -- Short Term Capital Gain
         ,p_input_value_id4       => l_input_values(3).input_value_id
           -- Income from any other sources
         ,p_input_value_id5       => l_input_values(4).input_value_id
           -- TDS Paid on Other Income
         ,p_input_value_id6       => l_input_values(5).input_value_id
         ,p_entry_value1          => p_income_from_house_property
         ,p_entry_value2          => p_profit_and_gain_from_busines
         ,p_entry_value3          => p_long_term_capital_gain
         ,p_entry_value4          => p_short_term_capital_gain
         ,p_entry_value5          => p_income_from_any_other_source
         ,p_entry_value6          => p_tds_paid_on_other_income
         ,p_effective_start_date  => l_effective_start_date
         ,p_effective_end_date    => l_effective_end_date
         ,p_element_entry_id      => l_element_entry_id
         ,p_object_version_number => l_object_version_number
         ,p_create_warning        => p_warnings
         );
      --
      pay_in_utils.set_location(g_debug, l_procedure, 40);
      --
      -- End date the entry as of the financial year end date
      --
      delete_declaration
         (p_element_entry_id => l_element_entry_id
         ,p_effective_date   => pay_in_utils.next_tax_year(l_effective_date)-1
         ,p_warnings         => l_warnings);
      --
   ELSE
      --
      pay_in_utils.set_location(g_debug, l_procedure, 50);
      --
      --
      -- An element entry for this element already exists we have to
      -- update the element entry with the newly submitted date.
      --
        pay_element_entry_api.update_element_entry
         (p_datetrack_update_mode    => get_update_mode(l_element_entry_id
                                                       ,l_effective_date)
         ,p_effective_date        => l_effective_date
         ,p_business_group_id     => l_business_group_id
         ,p_element_entry_id      => l_element_entry_id
         ,p_object_version_number => l_object_version_number
           -- Income from House Property
         ,p_input_value_id1       => l_input_values(0).input_value_id
           -- Profit and Gain from Business
         ,p_input_value_id2       => l_input_values(1).input_value_id
           -- Long Term Capital Gain
         ,p_input_value_id3       => l_input_values(2).input_value_id
           -- Short Term Capital Gain
         ,p_input_value_id4       => l_input_values(3).input_value_id
           -- Income from any other sources
         ,p_input_value_id5       => l_input_values(4).input_value_id
           -- TDS Paid on Other Income
         ,p_input_value_id6       => l_input_values(5).input_value_id
         ,p_entry_value1          => p_income_from_house_property
         ,p_entry_value2          => p_profit_and_gain_from_busines
         ,p_entry_value3          => p_long_term_capital_gain
         ,p_entry_value4          => p_short_term_capital_gain
         ,p_entry_value5          => p_income_from_any_other_source
         ,p_entry_value6          => p_tds_paid_on_other_income
         ,p_effective_start_date  => l_effective_start_date
         ,p_effective_end_date    => l_effective_end_date
         ,p_update_warning        => p_warnings
         );
      --
      pay_in_utils.set_location(g_debug, l_procedure, 60);
      --
      IF l_effective_end_date <> (pay_in_utils.next_tax_year(l_effective_date)-1)
      THEN
        --
        -- End date the entry as of the financial year end date
        --
        delete_declaration
           (p_element_entry_id =>l_element_entry_id
           ,p_effective_date   =>pay_in_utils.next_tax_year(l_effective_date)-1
           ,p_warnings         =>l_warnings);
        --
      END IF;
      --
   END IF;
   --
      pay_in_utils.trace('Effective Start Date: ', l_effective_start_date);
      pay_in_utils.trace('Effective End Date: ', l_effective_end_date);
      pay_in_utils.set_location(g_debug,l_procedure,70);
   --


   pay_in_utils.set_location(g_debug, 'Leaving: ' || l_procedure, 80);
   --
EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
         (p_pkg_name => g_package
         ,p_procedure_name => 'declare_other_income'
         ,p_error_text => substr(sqlerrm, 1, 240)
         );
    --
END declare_other_income;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_SECTION80DD                                 --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Deduction under Section 80DD' element.  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_disability_type        VARCHAR2                   --
--                  p_disability_percentage  VARCHAR2                   --
--                  p_treatment_amount       NUMBER                     --
--                  p_effective_date         DATE                       --
--                  p_element_entry_id       element_entry_id%TYPE      --
--            OUT : p_warnings        BOOLEAN                           --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  24-Sep-2004  PUCHIL      Initial Version                        --
--------------------------------------------------------------------------
PROCEDURE declare_section80dd
   (p_assignment_id         IN per_assignments_f.assignment_id%TYPE
   ,p_disability_type       IN VARCHAR2
   ,p_disability_percentage IN VARCHAR2
   ,p_treatment_amount      IN NUMBER
   ,p_effective_date        IN DATE default null
   ,p_element_entry_id      IN pay_element_entries_f.element_entry_id%TYPE default null
   ,p_warnings              OUT NOCOPY VARCHAR2)
IS
   --
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_warnings BOOLEAN;
   l_input_values t_input_values_tab;
   l_element_type_id pay_element_types_f.element_type_id%TYPE;
   l_element_link_id pay_element_links_f.element_link_id%TYPE;
   l_element_entry_id pay_element_entries.element_entry_id%TYPE;
   l_business_group_id per_business_groups.business_group_id%TYPE;
   l_object_version_number pay_element_entries_f.object_version_number%TYPE;
   l_effective_date DATE;
   l_effective_start_date DATE;
   l_effective_end_date DATE;
   --
   -- Added as a part of bug fix 4774108
   CURSOR csr_element_type_id(p_element_name    VARCHAR2
                             ,p_effective_date  DATE)-- Added as a part of bug 4938573
   IS
   SELECT element_type_id
   FROM   pay_element_types_f
   WHERE  (legislation_code = 'IN' OR business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID'))
   AND    element_name = p_element_name
   AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;

   CURSOR csr_element_link_details
    (c_assignment_id IN per_assignments_f.assignment_id%TYPE
    ,c_effective_date IN DATE
    ,c_element_link_id IN NUMBER)
   IS
   SELECT types.element_type_id
        , links.element_link_id
        , assgn.business_group_id
     FROM per_assignments_f assgn
        , pay_element_links_f links
        , pay_element_types_f types
    WHERE assgn.assignment_id = c_assignment_id
      AND links.element_link_id = c_element_link_id
      AND (types.processing_type = 'R' OR assgn.payroll_id IS NOT NULL)
      AND links.business_group_id = assgn.business_group_id
      AND links.element_type_id = types.element_type_id
      AND types.element_name = 'Deduction under Section 80DD'
      AND c_effective_date BETWEEN assgn.effective_start_date
                               AND assgn.effective_end_date
      AND c_effective_date BETWEEN links.effective_start_date
                               AND links.effective_end_date
      AND c_effective_date BETWEEN types.effective_start_date
                               AND types.effective_end_date;
   --
   CURSOR csr_element_entry_details
    (c_element_entry_id IN pay_element_entries_f.element_entry_id%TYPE
    ,c_effective_date IN DATE)
   IS
   SELECT entries.element_type_id
        , entries.object_version_number
        , assgn.business_group_id
     FROM pay_element_entries_f entries
        , per_assignments_f assgn
    WHERE entries.element_entry_id = c_element_entry_id
    AND   entries.assignment_id = assgn.assignment_id
    AND   c_effective_date BETWEEN entries.effective_start_date
                               AND entries.effective_end_date
    AND   c_effective_date BETWEEN assgn.effective_start_date
                               AND assgn.effective_end_date;
BEGIN
   --


    l_procedure := g_package || 'declare_section80dd';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id',p_assignment_id);
      pay_in_utils.trace('p_disability_type  ',p_disability_type );
      pay_in_utils.trace('p_disability_percentage',p_disability_percentage);
      pay_in_utils.trace('p_treatment_amount      ',p_treatment_amount );
      pay_in_utils.trace('p_effective_date     ',p_effective_date );
      pay_in_utils.trace('p_element_entry_id',p_element_entry_id);
      pay_in_utils.trace('**************************************************','********************');
    END IF;

   p_warnings := 'FALSE';

   --
   l_effective_date := pay_in_utils.get_effective_date(p_effective_date);
   -- Added for bug 3990922
   hr_session_utilities.insert_session_row(l_effective_date);
   --
   IF (NVL(p_element_entry_id, 0) = 0) THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 20);
      --
      -- Added as a part of bug fix 4774108
      OPEN  csr_element_type_id('Deduction under Section 80DD',l_effective_date);-- Added as a part of bug 4938573
      FETCH csr_element_type_id INTO l_element_type_id;
      CLOSE csr_element_type_id;

      l_element_link_id := pay_in_utils.get_element_link_id(p_assignment_id
                                                           ,l_effective_date-- Modified as a part of bug 4938573
                                                           ,l_element_type_id
                                                            );

      OPEN  csr_element_link_details(p_assignment_id
                                    ,l_effective_date
                                    ,l_element_link_id
                                    );
      FETCH csr_element_link_details INTO l_element_type_id
                                        , l_element_link_id
                                        , l_business_group_id;
      CLOSE csr_element_link_details;
      --
      IF l_element_link_id IS NULL THEN
         --
         hr_utility.set_message(800, 'PER_IN_MISSING_LINK');
         hr_utility.set_message_token('ELEMENT_NAME', 'Deduction under Section 80DD');
         hr_utility.raise_error;
         --
      END IF;
      --
      pay_in_utils.set_location(g_debug, l_procedure, 30);
      --
      IF g_debug THEN
        pay_in_utils.trace('Element Type ID: ', l_element_type_id);
        pay_in_utils.trace('Element Link ID: ', l_element_link_id);
        pay_in_utils.trace('Business Group ID: ', l_business_group_id);
      END IF;
      --
      -- Query the entry IDs required for creation of the element.
      get_element_entry_ids(l_element_type_id
                           ,l_effective_date
                           ,6
                           ,l_input_values);
      --
      pay_in_utils.set_location(g_debug, l_procedure, 40);
      --
      -- In this case, we would have to create an element entry to the
      -- assignment and return the entry id, the rest would be handled
      -- by the update command in the calling procedure.
      hr_utility.trace('Disability Type= '||p_disability_type);
      pay_element_entry_api.create_element_entry
         (p_effective_date        => l_effective_date
         ,p_business_group_id     => l_business_group_id
         ,p_assignment_id         => p_assignment_id
         ,p_element_link_id       => l_element_link_id
         ,p_entry_type            => 'E'
           -- Disability Type
         ,p_input_value_id1       => l_input_values(0).input_value_id
           -- Disability Percentage
         ,p_input_value_id2       => l_input_values(1).input_value_id
           -- Treatment Amount
         ,p_input_value_id3       => l_input_values(2).input_value_id
         ,p_entry_value1          => p_disability_type
         ,p_entry_value2          => p_disability_percentage
         ,p_entry_value3          => p_treatment_amount
         ,p_effective_start_date  => l_effective_start_date
         ,p_effective_end_date    => l_effective_end_date
         ,p_element_entry_id      => l_element_entry_id
         ,p_object_version_number => l_object_version_number
         ,p_create_warning        => l_warnings
         );
      --
      pay_in_utils.set_location(g_debug, l_procedure, 50);
      --
      -- End date the entry as of the financial year end date
      --
      delete_declaration
         (p_element_entry_id => l_element_entry_id
         ,p_effective_date   => pay_in_utils.next_tax_year(l_effective_date)-1
         ,p_warnings         => p_warnings);
      --
   ELSE
      --
      pay_in_utils.set_location(g_debug, l_procedure, 60);
      --
      OPEN csr_element_entry_details(p_element_entry_id
                                    ,l_effective_date);
      FETCH csr_element_entry_details INTO l_element_type_id
                                         , l_object_version_number
					 , l_business_group_id;
      CLOSE csr_element_entry_details;
      --
      --
      -- Query the entry IDs required for creation of the element.
      get_element_entry_ids(l_element_type_id
                           ,l_effective_date
                           ,6
                           ,l_input_values);
      --
      pay_in_utils.set_location(g_debug, l_procedure, 70);
      --
      -- An element entry for this element already exists we have to
      -- update the element entry with the newly submitted date.
      --
        pay_element_entry_api.update_element_entry
         (p_datetrack_update_mode    => get_update_mode(p_element_entry_id
                                                       ,l_effective_date)
         ,p_effective_date           => l_effective_date
         ,p_business_group_id        => l_business_group_id
         ,p_element_entry_id         => p_element_entry_id
         ,p_object_version_number    => l_object_version_number
           -- Disability Type
         ,p_input_value_id1          => l_input_values(0).input_value_id
           -- Disability Percentage
         ,p_input_value_id2          => l_input_values(1).input_value_id
           -- Treatment Amount
         ,p_input_value_id3          => l_input_values(2).input_value_id
         ,p_entry_value1             => p_disability_type
         ,p_entry_value2             => p_disability_percentage
         ,p_entry_value3             => p_treatment_amount
         ,p_effective_start_date     => l_effective_start_date
         ,p_effective_end_date       => l_effective_end_date
         ,p_update_warning           => l_warnings
         );
      --
      IF g_debug THEN
         pay_in_utils.trace('Effective Start Date: ', l_effective_start_date);
         pay_in_utils.trace('Effective End Date: ', l_effective_end_date);
      END IF;
      --
      pay_in_utils.set_location(g_debug, l_procedure, 80);
      --
      IF l_effective_end_date <> (pay_in_utils.next_tax_year(l_effective_date)-1)
      THEN
        --
        -- End date the entry as of the financial year end date
        --
        delete_declaration
           (p_element_entry_id =>l_element_entry_id
           ,p_effective_date   =>pay_in_utils.next_tax_year(l_effective_date)-1
           ,p_warnings         =>p_warnings);
        --
      END IF;
      --
   END IF;
   --
   IF l_warnings = TRUE THEN
      --
      p_warnings := 'TRUE';
      --
   END IF;


   pay_in_utils.set_location(g_debug, 'Leaving: ' || l_procedure, 90);
   --
EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
         (p_pkg_name => g_package
         ,p_procedure_name => 'declare_section80dd'
         ,p_error_text => substr(sqlerrm, 1, 240)
         );
   --
END declare_section80dd;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_SECTION80G                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Deduction under Section 80G' element.   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_donation_type      VARCHAR2                       --
--                  p_donation_amount    NUMBER                         --
--                  p_effective_date     DATE                           --
--                  p_element_entry_id   element_entry_id%TYPE          --
--            OUT : p_warnings           BOOLEAN                        --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  24-Sep-2004  PUCHIL      Initial Version                        --
--------------------------------------------------------------------------
PROCEDURE declare_section80g
   (p_assignment_id         IN per_assignments_f.assignment_id%TYPE
   ,p_donation_type         IN VARCHAR2
   ,p_donation_amount       IN NUMBER
   ,p_effective_date        IN DATE default null
   ,p_element_entry_id      IN pay_element_entries_f.element_entry_id%TYPE default null
   ,p_warnings              OUT NOCOPY VARCHAR2)
IS
   --
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_warnings BOOLEAN;
   l_input_values t_input_values_tab;
   l_element_type_id  pay_element_types_f.element_type_id%TYPE;
   l_element_link_id      pay_element_links_f.element_link_id%TYPE;
   l_element_entry_id pay_element_entries.element_entry_id%TYPE;
   l_business_group_id per_business_groups.business_group_id%TYPE;
   l_object_version_number pay_element_entries_f.object_version_number%TYPE;
   l_effective_date DATE;
   l_effective_start_date DATE;
   l_effective_end_date DATE;
   --
   -- Added as a part of bug fix 4774108
   CURSOR csr_element_type_id(p_element_name VARCHAR2
                             ,p_effective_date DATE -- Added as a part of bug 4938573
                             )
   IS
   SELECT element_type_id
   FROM   pay_element_types_f
   WHERE  legislation_code = 'IN'
   AND    element_name = p_element_name
   AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;

   CURSOR csr_element_link_details
    (c_assignment_id IN per_assignments_f.assignment_id%TYPE
    ,c_effective_date IN DATE
    ,c_element_link_id IN NUMBER)
   IS
   SELECT types.element_type_id
        , link.element_link_id
        , assgn.business_group_id
     FROM per_assignments_f assgn
        , pay_element_links_f link
        , pay_element_types_f types
    WHERE assgn.assignment_id = c_assignment_id
      AND link.element_link_id = c_element_link_id
      AND (types.processing_type = 'R' OR assgn.payroll_id IS NOT NULL)
      AND link.business_group_id = assgn.business_group_id
      AND link.element_type_id = types.element_type_id
      AND types.element_name = 'Deduction under Section 80G'
      AND c_effective_date BETWEEN assgn.effective_start_date
                               AND assgn.effective_end_date
      AND c_effective_date BETWEEN link.effective_start_date
                               AND link.effective_end_date
      AND c_effective_date BETWEEN types.effective_start_date
                               AND types.effective_end_date;
   --
   CURSOR csr_element_entry_details
    (c_element_entry_id IN pay_element_entries_f.element_entry_id%TYPE
    ,c_effective_date IN DATE)
   IS
   SELECT entries.element_type_id
        , entries.object_version_number
        , assgn.business_group_id
     FROM pay_element_entries_f entries
        , per_assignments_f assgn
    WHERE entries.element_entry_id = c_element_entry_id
    AND   entries.assignment_id = assgn.assignment_id
    AND   c_effective_date BETWEEN entries.effective_start_date
                               AND entries.effective_end_date
    AND   c_effective_date BETWEEN assgn.effective_start_date
                               AND assgn.effective_end_date;
BEGIN
   --
    l_procedure := g_package || 'declare_section80g';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id',p_assignment_id);
      pay_in_utils.trace('p_donation_type  ',p_donation_type );
      pay_in_utils.trace('p_donation_amount',p_donation_amount);
      pay_in_utils.trace('p_effective_date     ',p_effective_date );
      pay_in_utils.trace('p_element_entry_id',p_element_entry_id);
      pay_in_utils.trace('**************************************************','********************');
    END IF;

   p_warnings := 'FALSE';

   --
   IF g_debug THEN
      --
      pay_in_utils.trace('Donation Type: ', p_donation_type);
      pay_in_utils.trace('Donation Amount: ', p_donation_amount);
      --
   END IF;
   --
   l_effective_date := pay_in_utils.get_effective_date(p_effective_date);
   -- Added for bug 3990922
   hr_session_utilities.insert_session_row(l_effective_date);
   --
   IF (NVL(p_element_entry_id, 0) = 0) THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 20);
      --
    -- Added as a part of bug fix 4774108
      OPEN  csr_element_type_id('Deduction under Section 80G',l_effective_date); -- Added as a part of bug 4938573
      FETCH csr_element_type_id INTO l_element_type_id;
      CLOSE csr_element_type_id;

      l_element_link_id := pay_in_utils.get_element_link_id(p_assignment_id
                                                           ,l_effective_date -- Modified as a part of bug 4938573
                                                           ,l_element_type_id
                                                            );
      OPEN  csr_element_link_details(p_assignment_id
                                    ,l_effective_date
                                    ,l_element_link_id
                                    );
      FETCH csr_element_link_details INTO l_element_type_id
                                        , l_element_link_id
                                        , l_business_group_id;
      CLOSE csr_element_link_details;
      --
      pay_in_utils.set_location(g_debug, l_procedure, 30);
      --
      IF l_element_link_id IS NULL THEN
         --
         hr_utility.set_message(800, 'PER_IN_MISSING_LINK');
         hr_utility.set_message_token('ELEMENT_NAME', 'Deduction under Section 80G');
         hr_utility.raise_error;
         --
      END IF;
      --
      IF g_debug THEN
        pay_in_utils.trace('Element Type ID: ', l_element_type_id);
        pay_in_utils.trace('Element Link ID: ', l_element_link_id);
        pay_in_utils.trace('Business Group ID: ', l_business_group_id);
      END IF;
      --
      -- Query the entry IDs required for creation of the element.
      get_element_entry_ids(l_element_type_id
                           ,l_effective_date
                           ,5
                           ,l_input_values);
      --
      pay_in_utils.set_location(g_debug, l_procedure, 40);
      --
      -- In this case, we would have to create an element entry to the
      -- assignment and return the entry id, the rest would be handled
      -- by the update command in the calling procedure.
      pay_element_entry_api.create_element_entry
         (p_effective_date        => l_effective_date
         ,p_business_group_id     => l_business_group_id
         ,p_assignment_id         => p_assignment_id
         ,p_element_link_id       => l_element_link_id
         ,p_entry_type            => 'E'
           -- Donation Type
         ,p_input_value_id1       => l_input_values(0).input_value_id
           -- Donation Amount
         ,p_input_value_id2       => l_input_values(1).input_value_id
         ,p_entry_value1          => p_donation_type
         ,p_entry_value2          => p_donation_amount
         ,p_effective_start_date  => l_effective_start_date
         ,p_effective_end_date    => l_effective_end_date
         ,p_element_entry_id      => l_element_entry_id
         ,p_object_version_number => l_object_version_number
         ,p_create_warning        => l_warnings
         );
      --
      pay_in_utils.set_location(g_debug, l_procedure, 50);
      --
      -- End date the entry as of the financial year end date
      --
      delete_declaration
         (p_element_entry_id => l_element_entry_id
         ,p_effective_date   => pay_in_utils.next_tax_year(l_effective_date)-1
         ,p_warnings         => p_warnings);
      --
   ELSE
      --
      pay_in_utils.set_location(g_debug, l_procedure, 60);
      --
      OPEN csr_element_entry_details(p_element_entry_id
                                    ,l_effective_date);
      FETCH csr_element_entry_details INTO l_element_type_id
                                         , l_object_version_number
                                         , l_business_group_id;
      CLOSE csr_element_entry_details;
      --
      --
      -- Query the entry IDs required for creation of the element.
      get_element_entry_ids(l_element_type_id
                           ,l_effective_date
                           ,5
                           ,l_input_values);
      --
      pay_in_utils.set_location(g_debug, l_procedure, 70);
      --
      -- An element entry for this element already exists we have to
      -- update the element entry with the newly submitted date.
      --
        pay_element_entry_api.update_element_entry
         (p_datetrack_update_mode    => get_update_mode(p_element_entry_id
                                                       ,l_effective_date)
         ,p_effective_date           => l_effective_date
         ,p_business_group_id        => l_business_group_id
         ,p_element_entry_id         => p_element_entry_id
         ,p_object_version_number    => l_object_version_number
           -- Donation Type
         ,p_input_value_id1          => l_input_values(0).input_value_id
           -- Donation Amount
         ,p_input_value_id2          => l_input_values(1).input_value_id
         ,p_entry_value1             => p_donation_type
         ,p_entry_value2             => p_donation_amount
         ,p_effective_start_date     => l_effective_start_date
         ,p_effective_end_date       => l_effective_end_date
         ,p_update_warning           => l_warnings
         );
      --
      IF g_debug THEN
         pay_in_utils.trace('Effective Start Date: ', l_effective_start_date);
         pay_in_utils.trace('Effective End Date: ', l_effective_end_date);
      END IF;
      --
      pay_in_utils.set_location(g_debug, l_procedure, 80);
      --
      IF l_effective_end_date <> (pay_in_utils.next_tax_year(l_effective_date)-1)
      THEN
        --
        -- End date the entry as of the financial year end date
        --
        delete_declaration
           (p_element_entry_id =>l_element_entry_id
           ,p_effective_date   =>pay_in_utils.next_tax_year(l_effective_date)-1
           ,p_warnings         =>p_warnings);
        --
      END IF;
      --
   END IF;
   --
   IF l_warnings = TRUE THEN
      --
      p_warnings := 'TRUE';
      --
   END IF;

   pay_in_utils.set_location(g_debug, 'Leaving: ' || l_procedure, 90);
   --
EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
         (p_pkg_name => g_package
         ,p_procedure_name => 'declare_section80g'
         ,p_error_text => substr(sqlerrm, 1, 240)
         );
   --
END declare_section80g;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_LIFE_INSURANCE_PREMIUM                      --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Life Insurance Premium' element.        --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_premium_paid       VARCHAR2                       --
--                  p_sum_assured        NUMBER                         --
--                  p_effective_date     DATE                           --
--                  p_element_entry_id   element_entry_id%TYPE          --
--            OUT : p_warnings           BOOLEAN                        --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  24-Sep-2004  PUCHIL      Initial Version                        --
-- 1.1  02-Feb-2010  MDUBASI     Added LIC Policy Number
--------------------------------------------------------------------------
PROCEDURE declare_life_insurance_premium
   (p_assignment_id         IN per_assignments_f.assignment_id%TYPE
   ,p_premium_paid          IN VARCHAR2
   ,p_sum_assured           IN NUMBER
   ,p_effective_date        IN DATE default null
   ,p_element_entry_id      IN pay_element_entries_f.element_entry_id%TYPE default null
   ,p_policy_number         IN VARCHAR2
   ,p_warnings              OUT NOCOPY VARCHAR2)
IS
   --
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_warnings BOOLEAN;
   l_input_values t_input_values_tab;
   l_element_type_id  pay_element_types_f.element_type_id%TYPE;
   l_element_link_id      pay_element_links_f.element_link_id%TYPE;
   l_element_entry_id pay_element_entries.element_entry_id%TYPE;
   l_business_group_id per_business_groups.business_group_id%TYPE;
   l_object_version_number pay_element_entries_f.object_version_number%TYPE;
   l_effective_date DATE;
   l_effective_start_date DATE;
   l_effective_end_date DATE;
   --
   CURSOR csr_element_link_details
    (c_assignment_id IN per_assignments_f.assignment_id%TYPE
    ,c_effective_date IN DATE
    ,c_element_link_id IN NUMBER)
   IS
   SELECT types.element_type_id
        , link.element_link_id
        , assgn.business_group_id
     FROM per_assignments_f assgn
        , pay_element_links_f link
        , pay_element_types_f types
    WHERE assgn.assignment_id = c_assignment_id
      AND link.element_link_id = c_element_link_id
      AND (types.processing_type = 'R' OR assgn.payroll_id IS NOT NULL)
      AND link.business_group_id = assgn.business_group_id
      AND link.element_type_id = types.element_type_id
      AND types.element_name = 'Life Insurance Premium'
      AND c_effective_date BETWEEN assgn.effective_start_date
                               AND assgn.effective_end_date
      AND c_effective_date BETWEEN link.effective_start_date
                               AND link.effective_end_date
      AND c_effective_date BETWEEN types.effective_start_date
                               AND types.effective_end_date;
   --
   CURSOR csr_element_entry_details
    (c_element_entry_id IN pay_element_entries_f.element_entry_id%TYPE
    ,c_effective_date IN DATE)
   IS
   SELECT entries.element_type_id
        , entries.object_version_number
        , assgn.business_group_id
     FROM pay_element_entries_f entries
        , per_assignments_f assgn
    WHERE entries.element_entry_id = c_element_entry_id
    AND   entries.assignment_id = assgn.assignment_id
    AND   c_effective_date BETWEEN entries.effective_start_date
                               AND entries.effective_end_date
    AND   c_effective_date BETWEEN assgn.effective_start_date
                               AND assgn.effective_end_date;
  -- Added as a part of bug fix 4774108
   CURSOR csr_element_type_id(p_element_name   VARCHAR2
                             ,p_effective_date DATE
                             )
   IS
   SELECT element_type_id
   FROM   pay_element_types_f
   WHERE  legislation_code = 'IN'
   AND    element_name = p_element_name
   AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
BEGIN
   --
    l_procedure := g_package || 'declare_life_insurance_premium';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id',p_assignment_id);
      pay_in_utils.trace('p_premium_paid  ',p_premium_paid );
      pay_in_utils.trace('p_sum_assured',p_sum_assured);
      pay_in_utils.trace('p_effective_date     ',p_effective_date );
      pay_in_utils.trace('p_element_entry_id',p_element_entry_id);
      pay_in_utils.trace('p_policy_number',p_policy_number);
      pay_in_utils.trace('**************************************************','********************');
    END IF;

   p_warnings := 'FALSE';

   --
   l_effective_date := pay_in_utils.get_effective_date(p_effective_date);
   --
   IF (NVL(p_element_entry_id, 0) = 0) THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 20);
      --
      -- Added as a part of bug fix 4774108
      OPEN  csr_element_type_id('Life Insurance Premium',l_effective_date);
      FETCH csr_element_type_id INTO l_element_type_id;
      CLOSE csr_element_type_id;

      l_element_link_id := pay_in_utils.get_element_link_id(p_assignment_id
                                                           ,l_effective_date
                                                           ,l_element_type_id
                                                           );
      OPEN  csr_element_link_details(p_assignment_id
                                    ,l_effective_date
                                    ,l_element_link_id);
      FETCH csr_element_link_details INTO l_element_type_id
                                        , l_element_link_id
                                        , l_business_group_id;
      CLOSE csr_element_link_details;
      --
      IF l_element_link_id IS NULL THEN
         --
         hr_utility.set_message(800, 'PER_IN_MISSING_LINK');
         hr_utility.set_message_token('ELEMENT_NAME', 'Life Insurance Premium');
         hr_utility.raise_error;
         --
      END IF;
      --
      pay_in_utils.set_location(g_debug, l_procedure, 30);
      --
      IF g_debug THEN
        pay_in_utils.trace('Element Type ID: ' , l_element_type_id);
        pay_in_utils.trace('Element Link ID: ' , l_element_link_id);
        pay_in_utils.trace('Business Group ID: ' , l_business_group_id);
      END IF;
      --
      -- Query the entry IDs required for creation of the element.
      get_element_entry_ids(l_element_type_id
                           ,l_effective_date
                           ,5
                           ,l_input_values);
      --
      pay_in_utils.set_location(g_debug, l_procedure, 40);
      --
      -- In this case, we would have to create an element entry to the
      -- assignment and return the entry id, the rest would be handled
      -- by the update command in the calling procedure.
      pay_element_entry_api.create_element_entry
         (p_effective_date        => l_effective_date
         ,p_business_group_id     => l_business_group_id
         ,p_assignment_id         => p_assignment_id
         ,p_element_link_id       => l_element_link_id
         ,p_entry_type            => 'E'
           -- Premium Paid
         ,p_input_value_id1       => l_input_values(0).input_value_id
           -- Sum Assured
         ,p_input_value_id2       => l_input_values(1).input_value_id
	   -- Policy Number
         ,p_input_value_id3       => l_input_values(4).input_value_id
         ,p_entry_value1          => p_premium_paid
         ,p_entry_value2          => p_sum_assured
	 ,p_entry_value3          => p_policy_number
         ,p_effective_start_date  => l_effective_start_date
         ,p_effective_end_date    => l_effective_end_date
         ,p_element_entry_id      => l_element_entry_id
         ,p_object_version_number => l_object_version_number
         ,p_create_warning        => l_warnings
         );
      --
      pay_in_utils.set_location(g_debug, l_procedure, 50);
      --
      -- End date the entry as of the financial year end date
      --
      delete_declaration
         (p_element_entry_id => l_element_entry_id
         ,p_effective_date   => pay_in_utils.next_tax_year(l_effective_date)-1
         ,p_warnings         => p_warnings);
      --
   ELSE
      --
      pay_in_utils.set_location(g_debug, l_procedure, 60);
      --
      OPEN csr_element_entry_details(p_element_entry_id
                                    ,l_effective_date);
      FETCH csr_element_entry_details INTO l_element_type_id
                                         , l_object_version_number
                                         , l_business_group_id;

      CLOSE csr_element_entry_details;
      --
      --
      -- Query the entry IDs required for creation of the element.
      get_element_entry_ids(l_element_type_id
                           ,l_effective_date
                           ,5
                           ,l_input_values);
      --
      pay_in_utils.set_location(g_debug, l_procedure, 70);
      --
      -- An element entry for this element already exists we have to
      -- update the element entry with the newly submitted date.
      --
        pay_element_entry_api.update_element_entry
         (p_datetrack_update_mode    => get_update_mode(p_element_entry_id
                                                       ,l_effective_date)
         ,p_effective_date           => l_effective_date
         ,p_business_group_id        => l_business_group_id
         ,p_element_entry_id         => p_element_entry_id
         ,p_object_version_number    => l_object_version_number
           -- Premium Paid
         ,p_input_value_id1          => l_input_values(0).input_value_id
           -- Sum Assured
         ,p_input_value_id2          => l_input_values(1).input_value_id
	   -- Policy Number
         ,p_input_value_id3          => l_input_values(4).input_value_id
         ,p_entry_value1             => p_premium_paid
         ,p_entry_value2             => p_sum_assured
         ,p_entry_value3             => p_policy_number
         ,p_effective_start_date     => l_effective_start_date
         ,p_effective_end_date       => l_effective_end_date
         ,p_update_warning           => l_warnings
         );
      --
      IF g_debug THEN
         pay_in_utils.trace('Effective Start Date: ', l_effective_start_date);
         pay_in_utils.trace('Effective End Date: ' , l_effective_end_date);
      END IF;
      --
      pay_in_utils.set_location(g_debug, l_procedure, 80);
      --
      IF l_effective_end_date <> (pay_in_utils.next_tax_year(l_effective_date)-1)
      THEN
        --
        -- End date the entry as of the financial year end date
        --
        delete_declaration
           (p_element_entry_id =>l_element_entry_id
           ,p_effective_date   =>pay_in_utils.next_tax_year(l_effective_date)-1
           ,p_warnings         =>p_warnings);
        --
      END IF;
      --
   END IF;
   --

   --
   IF l_warnings = TRUE THEN
     --
     p_warnings := 'TRUE';
     --
   END IF;



   pay_in_utils.set_location(g_debug, 'Leaving: ' || l_procedure, 90);

EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
         (p_pkg_name => g_package
         ,p_procedure_name => 'declare_life_insurance_premium'
         ,p_error_text => substr(sqlerrm, 1, 240)
         );
   --
END declare_life_insurance_premium;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_VPF                                 --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'PF Information' element.                --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_effective_date          DATE                      --
--                  p_ee_vol_pf_amount        NUMBER                    --
--                  p_ee_vol_pf_percent       NUMBER                    --
--            OUT : p_warnings                BOOLEAN                   --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  02-Feb-2010  mdubasi     Initial Version                        --
--------------------------------------------------------------------------

PROCEDURE declare_vpf
          (p_assignment_id              IN   per_assignments_f.assignment_id%TYPE
          ,p_effective_date            IN   DATE DEFAULT NULL
          ,p_ee_vol_pf_amount           IN   NUMBER
          ,p_ee_vol_pf_percent          IN   NUMBER
          ,p_warnings                   OUT  NOCOPY BOOLEAN)
IS
   CURSOR c_vpf_update(c_element_entry_id pay_element_entries_f.element_entry_id%TYPE
                                          ,c_effective_date DATE)
   IS
   SELECT ee.effective_start_date
   FROM   pay_element_entries_f ee
   WHERE  ee.element_entry_id = c_element_entry_id
   AND c_effective_date BETWEEN ee.effective_start_date and ee.effective_end_date;

   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_input_values t_input_values_tab;
   l_element_type_id  pay_element_types_f.element_type_id%TYPE;
   l_element_link_id      pay_element_links_f.element_link_id%TYPE;
   l_element_entry_id pay_element_entries_f.element_entry_id%TYPE;
   l_business_group_id per_business_groups.business_group_id%TYPE;
   l_object_version_number pay_element_entries_f.object_version_number%TYPE;
   l_effective_start_date DATE;
   l_effective_end_date DATE;
   l_effective_date DATE;
   l_endation_date DATE;
   l_warnings VARCHAR2(6);
   l_current_date pay_element_entries_f.effective_start_date%TYPE;
   --
BEGIN
   --
    l_procedure := g_package || 'declare_vpf';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id',p_assignment_id);
      pay_in_utils.trace('p_effective_date     ',p_effective_date );
      pay_in_utils.trace('p_ee_vol_pf_amount',p_ee_vol_pf_amount);
      pay_in_utils.trace('p_ee_vol_pf_percent',p_ee_vol_pf_percent);
      pay_in_utils.trace('**************************************************','********************');
    END IF;
   --
   l_effective_date := pay_in_utils.get_effective_date(p_effective_date);


   get_entry_details(p_assignment_id        => p_assignment_id
                    ,p_element_name         => 'PF Information'
                    ,p_effective_date       => l_effective_date
                    ,p_element_type_id      => l_element_type_id
                    ,p_element_link_id      => l_element_link_id
                    ,p_element_entry_id     => l_element_entry_id
                    ,p_expected_entries     => 2
                    ,p_business_group_id    => l_business_group_id
                    ,p_object_version_number=> l_object_version_number
                    ,p_input_values         => l_input_values
                    );
   --
   IF g_debug THEN
      pay_in_utils.trace('Element Type ID: ' , l_element_type_id);
      pay_in_utils.trace('Element Entry ID: ' , l_element_entry_id);
      pay_in_utils.trace('Business Group ID: ' , l_business_group_id);
      pay_in_utils.trace('Object Version Number: ' , l_object_version_number);
   END IF;

   --
   pay_in_utils.set_location(g_debug, l_procedure, 20);
   --
   IF l_element_entry_id is null THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 30);
      --
      --
      -- In this case, we would have to create an element entry to the
      -- assignment and return the entry id, the rest would be handled
      -- by the update command in the calling procedure.
      --
      IF (p_ee_vol_pf_amount > 0 OR p_ee_vol_pf_percent > 0) THEN
      pay_element_entry_api.create_element_entry
         (p_effective_date        => l_effective_date
         ,p_business_group_id     => l_business_group_id
         ,p_assignment_id         => p_assignment_id
         ,p_element_link_id       => l_element_link_id
         ,p_entry_type            => 'E'
           --PF Information
         ,p_input_value_id1          => l_input_values(0).input_value_id
         ,p_entry_value1             => p_ee_vol_pf_amount
         ,p_input_value_id2          => l_input_values(1).input_value_id
         ,p_entry_value2             => p_ee_vol_pf_percent
         ,p_effective_start_date     => l_effective_start_date
         ,p_effective_end_date       => l_effective_end_date
         ,p_element_entry_id         => l_element_entry_id
         ,p_object_version_number    => l_object_version_number
         ,p_create_warning           => p_warnings
         );
      END IF;
      --
      pay_in_utils.set_location(g_debug, l_procedure, 40);
      --
   ELSE
      --
      pay_in_utils.set_location(g_debug, l_procedure, 50);
      --
      OPEN  c_vpf_update(l_element_entry_id,l_effective_date);
      FETCH c_vpf_update into l_current_date;
      CLOSE c_vpf_update;

         IF (trunc(l_current_date,'MM') = trunc(l_effective_date,'MM'))
         THEN
         l_effective_date := l_current_date;
         END IF;
      --
      -- An element entry for this element already exists we have to
      -- update the element entry with the newly submitted date.
      --
       IF (p_ee_vol_pf_amount > 0 OR p_ee_vol_pf_percent > 0) THEN
        pay_element_entry_api.update_element_entry
         (p_datetrack_update_mode    => get_update_mode(l_element_entry_id
                                                       ,l_effective_date)
         ,p_effective_date           => l_effective_date
         ,p_business_group_id        => l_business_group_id
         ,p_element_entry_id         => l_element_entry_id
         ,p_object_version_number    => l_object_version_number
           --PF Information
         ,p_input_value_id1          => l_input_values(0).input_value_id
         ,p_entry_value1             => p_ee_vol_pf_amount
         ,p_input_value_id2          => l_input_values(1).input_value_id
         ,p_entry_value2             => p_ee_vol_pf_percent
         ,p_effective_start_date     => l_effective_start_date
         ,p_effective_end_date       => l_effective_end_date
         ,p_update_warning           => p_warnings
         );
       ELSE
           delete_declaration
           (p_element_entry_id =>l_element_entry_id
           ,p_effective_date   =>l_effective_date
           ,p_warnings         =>l_warnings);
       END IF;
      --
      --
      pay_in_utils.set_location(g_debug, l_procedure, 60);
      --

      --
   END IF;
   --
   IF g_debug THEN
      pay_in_utils.trace('Effective Start Date: ', l_effective_start_date);
      pay_in_utils.trace('Effective End Date: ', l_effective_end_date);
   END IF;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
   --
EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
         (p_pkg_name => g_package
         ,p_procedure_name => 'declare_vpf'
         ,p_error_text => substr(sqlerrm, 1, 240)
         );

END;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_TUITION_FEE                                 --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Tuition Fee' element.                   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_tuition_fee_for_child_1 NUMBER                    --
--                  p_tuition_fee_for_child_2 NUMBER                    --
--                  p_effective_date          DATE                      --
--                  p_element_entry_id        element_entry_id%TYPE     --
--            OUT : p_warnings                BOOLEAN                   --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  24-Sep-2004  PUCHIL      Initial Version                        --
-- 1.1  25-Apr-2005  VGSRINIV    Nulled out for Stat Update(Bug 4251141)--
--------------------------------------------------------------------------
PROCEDURE declare_tuition_fee
   (p_assignment_id           IN per_assignments_f.assignment_id%TYPE
   ,p_tuition_fee_for_child_1 IN NUMBER
   ,p_tuition_fee_for_child_2 IN NUMBER
   ,p_effective_date          IN DATE DEFAULT NULL
   ,p_warnings                OUT NOCOPY BOOLEAN)
IS
   --
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_input_values t_input_values_tab;
   l_element_type_id  pay_element_types_f.element_type_id%TYPE;
   l_element_link_id      pay_element_links_f.element_link_id%TYPE;
   l_element_entry_id pay_element_entries_f.element_entry_id%TYPE;
   l_business_group_id per_business_groups.business_group_id%TYPE;
   l_object_version_number pay_element_entries_f.object_version_number%TYPE;
   l_effective_start_date DATE;
   l_effective_end_date DATE;
   l_effective_date DATE;
   l_warnings VARCHAR2(6);
   --
BEGIN
   --
    l_procedure := g_package || 'declare_tuition_fee';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id',p_assignment_id);
      pay_in_utils.trace('p_tuition_fee_for_child_1 ',p_tuition_fee_for_child_1 );
      pay_in_utils.trace('p_tuition_fee_for_child_2 ',p_tuition_fee_for_child_2 );
      pay_in_utils.trace('p_effective_date     ',p_effective_date );
      pay_in_utils.trace('**************************************************','********************');
    END IF;

   --
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
   --
EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
         (p_pkg_name => g_package
         ,p_procedure_name => 'declare_tuition_fee'
         ,p_error_text => substr(sqlerrm, 1, 240)
         );
    --
END declare_tuition_fee;

/* BUG 4251141: STAT UPDATE 2005 CHANGES START HERE */

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_SECTION80CCE                                --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Deduction under Section 80CCE' element. --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_investment_type    VARCHAR2                       --
--                  p_investment_amount  NUMBER                         --
--                  p_effective_date     DATE                           --
--                  p_element_entry_id   element_entry_id%TYPE          --
--            OUT : p_warnings           BOOLEAN                        --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  14-Apr-2005  VGSRINIV    Initial Version                        --
--------------------------------------------------------------------------

PROCEDURE declare_section80cce
   (p_assignment_id         IN per_assignments_f.assignment_id%TYPE
   ,p_investment_type       IN VARCHAR2
   ,p_investment_amount     IN NUMBER
   ,p_effective_date        IN DATE default null
   ,p_element_entry_id      IN pay_element_entries_f.element_entry_id%TYPE DEFAULT NULL
   ,p_warnings              OUT NOCOPY VARCHAR2)
IS
   --
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_warnings BOOLEAN;
   l_input_values t_input_values_tab;
   l_element_type_id  pay_element_types_f.element_type_id%TYPE;
   l_element_link_id      pay_element_links_f.element_link_id%TYPE;
   l_element_entry_id pay_element_entries.element_entry_id%TYPE;
   l_business_group_id per_business_groups.business_group_id%TYPE;
   l_object_version_number pay_element_entries_f.object_version_number%TYPE;
   l_effective_date DATE;
   l_effective_start_date DATE;
   l_effective_end_date DATE;
   l_ele_entry_id pay_element_entries.element_entry_id%TYPE;
   l_ovn pay_element_entries_f.object_version_number%TYPE;
   l_entry_value pay_element_entry_values_f.screen_entry_value%TYPE;
   l_element_name     pay_element_types_f.element_name%TYPE;
   l_token1              VARCHAR2(240);
   --
   CURSOR csr_element_link_details
    (c_assignment_id IN per_assignments_f.assignment_id%TYPE
    ,c_effective_date IN DATE
    ,c_element_name   IN pay_element_types_f.element_name%TYPE)
   IS
   SELECT types.element_type_id
        , link.element_link_id
        , assgn.business_group_id
     FROM per_assignments_f assgn
        , pay_element_links_f link
        , pay_element_types_f types
    WHERE assgn.assignment_id = c_assignment_id
      AND link.element_link_id = pay_in_utils.get_element_link_id(c_assignment_id
                                                                 ,c_effective_date
                                                                 ,types.element_type_id
                                                                )
      AND (types.processing_type = 'R' OR assgn.payroll_id IS NOT NULL)
      AND link.business_group_id = assgn.business_group_id
      AND link.element_type_id = types.element_type_id
      AND types.element_name = c_element_name--'Deduction under Section 80CCE'
      AND c_effective_date BETWEEN assgn.effective_start_date
                               AND assgn.effective_end_date
      AND c_effective_date BETWEEN link.effective_start_date
                               AND link.effective_end_date
      AND c_effective_date BETWEEN types.effective_start_date
                               AND types.effective_end_date;
   --
   CURSOR csr_element_entry_details
    (c_element_entry_id IN pay_element_entries_f.element_entry_id%TYPE
    ,c_effective_date IN DATE)
   IS
   SELECT entries.element_type_id
        , entries.object_version_number
        , assgn.business_group_id
     FROM pay_element_entries_f entries
        , per_assignments_f assgn
    WHERE entries.element_entry_id = c_element_entry_id
    AND   entries.assignment_id = assgn.assignment_id
    AND   c_effective_date BETWEEN entries.effective_start_date
                               AND entries.effective_end_date
    AND   c_effective_date BETWEEN assgn.effective_start_date
                               AND assgn.effective_end_date;

   CURSOR c_check_entry(c_element_name   IN pay_element_types_f.element_name%TYPE
                       ,c_effective_date IN DATE)
   IS
   SELECT entries.element_entry_id entry_id
         ,entries.object_version_number
	 ,value2.screen_entry_value
  FROM per_assignments_f assgn
     , pay_element_links_f link
     , pay_element_types_f types
     , pay_element_entries_f entries
     , pay_element_entry_values_f value1
     , pay_input_values_f inputs1
     , pay_element_entry_values_f value2
     , pay_input_values_f inputs2
 WHERE assgn.assignment_id = p_assignment_id
   AND link.element_link_id = pay_in_utils.get_element_link_id(p_assignment_id
                                                              ,c_effective_date
                                                              ,types.element_type_id
                                                                )
   AND (types.processing_type = 'R' OR assgn.payroll_id IS NOT NULL)
   AND link.business_group_id = assgn.business_group_id
   AND link.element_type_id = types.element_type_id
   AND types.element_name = c_element_name--'Deduction under Section 80CCE'
   AND entries.element_type_id = types.element_type_id
   AND entries.element_link_id = link.element_link_id
   AND entries.assignment_id = assgn.assignment_id
   AND value1.element_entry_id =  entries.element_entry_id
   AND inputs1.input_value_id = value1.input_value_id
   AND inputs1.element_type_id = types.element_type_id
   AND inputs1.name = 'Component Name'
   AND value2.element_entry_id =  entries.element_entry_id
   AND inputs2.input_value_id = value2.input_value_id
   AND inputs2.element_type_id = types.element_type_id
   AND inputs2.name = 'Investment Amount'
   AND c_effective_date BETWEEN assgn.effective_start_date AND assgn.effective_end_date
   AND c_effective_date BETWEEN link.effective_start_date AND link.effective_end_date
   AND c_effective_date BETWEEN types.effective_start_date AND types.effective_end_date
   AND c_effective_date BETWEEN entries.effective_start_date AND entries.effective_end_date
   AND c_effective_date BETWEEN inputs1.effective_start_date AND inputs1.effective_end_date
   AND c_effective_date BETWEEN value1.effective_start_date AND value1.effective_end_date
   AND c_effective_date BETWEEN inputs2.effective_start_date AND inputs2.effective_end_date
   AND c_effective_date BETWEEN value2.effective_start_date AND value2.effective_end_date
   AND value1.screen_entry_value = p_investment_type;

   CURSOR c_screen_entry_value(p_effective_date DATE)
   IS
   SELECT peev.screen_entry_value
   FROM pay_element_entries_f  peef,
        pay_input_values_f piv,
        pay_element_entry_values_f peev
   WHERE peef.element_entry_id = p_element_entry_id
   AND  piv.element_type_id  = peef.element_type_id
   AND  piv.name = 'Component Name'
   AND  peev.input_value_id = piv.input_value_id
   AND  peev.element_entry_id = peef.element_entry_id
   AND  piv.legislation_code = 'IN'
   AND  p_effective_date BETWEEN peev.effective_start_date AND peev.effective_end_date
   AND  p_effective_date BETWEEN piv.effective_start_date  AND piv.effective_end_date
   AND  p_effective_date BETWEEN peef.effective_start_date AND peef.effective_end_date;

BEGIN
   --
    l_procedure := g_package || 'declare_section80cce';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id',p_assignment_id);
      pay_in_utils.trace('p_investment_type  ',p_investment_type );
      pay_in_utils.trace('p_investment_amount',p_investment_amount);
      pay_in_utils.trace('p_effective_date     ',p_effective_date );
      pay_in_utils.trace('p_element_entry_id',p_element_entry_id);
      pay_in_utils.trace('**************************************************','********************');
    END IF;

   p_warnings := 'FALSE';


   --
   l_effective_date := pay_in_utils.get_effective_date(p_effective_date);

   hr_session_utilities.insert_session_row(l_effective_date);
   --
   SELECT DECODE(p_investment_type
                ,'Pension Fund 80CCC','Pension Fund 80CCC'
                ,'Deferred Annuity','Deferred Annuity'
                ,'Senior Citizens Savings Scheme','Senior Citizens Savings Scheme'
                ,'Deduction under Section 80CCE'
                )
   INTO l_element_name
   FROM dual;

   IF (p_element_entry_id IS NOT NULL)
   THEN
       OPEN  c_screen_entry_value(l_effective_date);
       FETCH c_screen_entry_value INTO l_token1;
       CLOSE c_screen_entry_value;

       IF (l_token1 <> p_investment_type)
       THEN
         --
         p_warnings := 'PER_IN_INVESTMENT_80CCE'||l_token1;
         RETURN;
         --
       END IF;
   END IF;

   IF (NVL(p_element_entry_id, 0) = 0) THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 20);
      --
      OPEN  csr_element_link_details(p_assignment_id
                                    ,l_effective_date
                                    ,l_element_name);
      FETCH csr_element_link_details INTO l_element_type_id
                                        , l_element_link_id
                                        , l_business_group_id;
      CLOSE csr_element_link_details;
      --
      pay_in_utils.set_location(g_debug, l_procedure, 30);
      --
      IF l_element_link_id IS NULL THEN
         --
         hr_utility.set_message(800, 'PER_IN_MISSING_LINK');
         hr_utility.set_message_token('ELEMENT_NAME', l_element_name);--'Deduction under Section 80CCE');
         hr_utility.raise_error;
         --
      END IF;
      --
      IF g_debug THEN
        pay_in_utils.trace('Element Type ID: ', l_element_type_id);
        pay_in_utils.trace('Element Link ID: ', l_element_link_id);
        pay_in_utils.trace('Business Group ID: ', l_business_group_id);
      END IF;
      --
      -- Query the entry IDs required for creation of the element.
      get_element_entry_ids(l_element_type_id
                           ,l_effective_date
                           ,2
                           ,l_input_values);
      --
      pay_in_utils.set_location(g_debug, l_procedure, 40);

      --  Check if the element entry with same component is already present.
      --  If so then Update the same element by adding the investment amount
      --  to the existing one
      OPEN c_check_entry(l_element_name,l_effective_date);
      FETCH c_check_entry INTO l_ele_entry_id,l_ovn,l_entry_value;
      IF c_check_entry%FOUND THEN

        pay_element_entry_api.update_element_entry
         (p_datetrack_update_mode    => get_update_mode(l_ele_entry_id
                                                       ,l_effective_date)
         ,p_effective_date           => l_effective_date
         ,p_business_group_id        => l_business_group_id
         ,p_element_entry_id         => l_ele_entry_id
         ,p_object_version_number    => l_ovn
           -- Investment Amount
         ,p_input_value_id1          => l_input_values(0).input_value_id
           -- Investment Type
         ,p_input_value_id2          => l_input_values(1).input_value_id
         ,p_entry_value1             => p_investment_amount+l_entry_value
         ,p_entry_value2             => p_investment_type
         ,p_effective_start_date     => l_effective_start_date
         ,p_effective_end_date       => l_effective_end_date
         ,p_update_warning           => l_warnings
         );

        IF l_effective_end_date <> (pay_in_utils.next_tax_year(l_effective_date)-1)
        THEN
          --
          -- End date the entry as of the financial year end date
          --
           delete_declaration
             (p_element_entry_id =>l_element_entry_id
             ,p_effective_date   =>pay_in_utils.next_tax_year(l_effective_date)-1
             ,p_warnings         =>p_warnings);
        --
        END IF;

      ELSE /* If Element Entry does not exist */
      --
      -- In this case, we would have to create an element entry to the
      -- assignment and return the entry id, the rest would be handled
      -- by the update command in the calling procedure.
      pay_element_entry_api.create_element_entry
         (p_effective_date        => l_effective_date
         ,p_business_group_id     => l_business_group_id
         ,p_assignment_id         => p_assignment_id
         ,p_element_link_id       => l_element_link_id
         ,p_entry_type            => 'E'
           -- Investment Amount
         ,p_input_value_id1       => l_input_values(0).input_value_id
           -- Investment Type
         ,p_input_value_id2       => l_input_values(1).input_value_id
         ,p_entry_value1          => p_investment_amount
         ,p_entry_value2          => p_investment_type
         ,p_effective_start_date  => l_effective_start_date
         ,p_effective_end_date    => l_effective_end_date
         ,p_element_entry_id      => l_element_entry_id
         ,p_object_version_number => l_object_version_number
         ,p_create_warning        => l_warnings
         );
      --
      pay_in_utils.set_location(g_debug, l_procedure, 50);
      --
      -- End date the entry as of the financial year end date
      --
      delete_declaration
         (p_element_entry_id => l_element_entry_id
         ,p_effective_date   => pay_in_utils.next_tax_year(l_effective_date)-1
         ,p_warnings         => p_warnings);

      END IF;
      CLOSE c_check_entry;
   --
   ELSE
      --
      pay_in_utils.set_location(g_debug, l_procedure, 60);
      --
      OPEN csr_element_entry_details(p_element_entry_id
                                    ,l_effective_date);
      FETCH csr_element_entry_details INTO l_element_type_id
                                         , l_object_version_number
                                         , l_business_group_id;
      CLOSE csr_element_entry_details;
      --
      --
      -- Query the entry IDs required for creation of the element.
      get_element_entry_ids(l_element_type_id
                           ,l_effective_date
                           ,2
                           ,l_input_values);
      --
      pay_in_utils.set_location(g_debug, l_procedure, 70);
      --
      -- An element entry for this element already exists we have to
      -- update the element entry with the newly submitted date.
      --
        pay_element_entry_api.update_element_entry
         (p_datetrack_update_mode    => get_update_mode(p_element_entry_id
                                                       ,l_effective_date)
         ,p_effective_date           => l_effective_date
         ,p_business_group_id        => l_business_group_id
         ,p_element_entry_id         => p_element_entry_id
         ,p_object_version_number    => l_object_version_number
           -- Investment Amount
         ,p_input_value_id1          => l_input_values(0).input_value_id
           -- Investment Type
         ,p_input_value_id2          => l_input_values(1).input_value_id
         ,p_entry_value1             => p_investment_amount
         ,p_entry_value2             => p_investment_type
         ,p_effective_start_date     => l_effective_start_date
         ,p_effective_end_date       => l_effective_end_date
         ,p_update_warning           => l_warnings
         );
      --
      IF g_debug THEN
         pay_in_utils.trace('Effective Start Date: ', l_effective_start_date);
         pay_in_utils.trace('Effective End Date: ', l_effective_end_date);
      END IF;
      --
      pay_in_utils.set_location(g_debug, l_procedure, 80);
      --
      IF l_effective_end_date <> (pay_in_utils.next_tax_year(l_effective_date)-1)
      THEN
        --
        -- End date the entry as of the financial year end date
        --
        delete_declaration
           (p_element_entry_id =>l_element_entry_id
           ,p_effective_date   =>pay_in_utils.next_tax_year(l_effective_date)-1
           ,p_warnings         =>p_warnings);
        --
      END IF;
      --
   END IF;
   --
   IF l_warnings = TRUE THEN
      --
      p_warnings := 'TRUE';
      --
   END IF;
   --

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,90);
   --
EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
         (p_pkg_name => g_package
         ,p_procedure_name => 'declare_section80cce'
         ,p_error_text => substr(sqlerrm, 1, 240)
         );
   --
END declare_section80cce;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_SECTION80GG                                --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Deduction under Section 80GG' element. --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_effective_date             DATE                   --
--                  p_claim_exemp_under_sec_80gg VARCHAR2               --
--            OUT : p_warnings                   BOOLEAN                --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  14-Apr-2005  VGSRINIV    Initial Version                        --
--------------------------------------------------------------------------

PROCEDURE declare_section80gg
          (p_assignment_id              IN   per_assignments_f.assignment_id%TYPE
	  ,p_effective_date             IN   DATE DEFAULT NULL
          ,p_claim_exemp_under_sec_80gg IN   VARCHAR2
          ,p_warnings                   OUT  NOCOPY BOOLEAN)
IS

   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_input_values t_input_values_tab;
   l_element_type_id  pay_element_types_f.element_type_id%TYPE;
   l_element_link_id      pay_element_links_f.element_link_id%TYPE;
   l_element_entry_id pay_element_entries_f.element_entry_id%TYPE;
   l_business_group_id per_business_groups.business_group_id%TYPE;
   l_object_version_number pay_element_entries_f.object_version_number%TYPE;
   l_effective_start_date DATE;
   l_effective_end_date DATE;
   l_effective_date DATE;
   l_endation_date DATE;
   l_warnings VARCHAR2(6);
   --
BEGIN
   --
    l_procedure := g_package || 'declare_section80gg';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id',p_assignment_id);
      pay_in_utils.trace('p_effective_date     ',p_effective_date );
      pay_in_utils.trace('p_claim_exemp_under_sec_80gg',p_claim_exemp_under_sec_80gg);
      pay_in_utils.trace('**************************************************','********************');
    END IF;
   --
   l_effective_date := pay_in_utils.get_effective_date(p_effective_date);


   get_entry_details(p_assignment_id        => p_assignment_id
                    ,p_element_name         => 'Deduction under Section 80GG'
                    ,p_effective_date       => l_effective_date
                    ,p_element_type_id      => l_element_type_id
                    ,p_element_link_id      => l_element_link_id
                    ,p_element_entry_id     => l_element_entry_id
                    ,p_expected_entries     => 1
                    ,p_business_group_id    => l_business_group_id
                    ,p_object_version_number=> l_object_version_number
                    ,p_input_values         => l_input_values
                    );
   --
   IF g_debug THEN
      pay_in_utils.trace('Element Type ID: ' , l_element_type_id);
      pay_in_utils.trace('Element Entry ID: ' , l_element_entry_id);
      pay_in_utils.trace('Business Group ID: ' , l_business_group_id);
      pay_in_utils.trace('Object Version Number: ' , l_object_version_number);
   END IF;

   --
   pay_in_utils.set_location(g_debug, l_procedure, 20);
   --
   IF l_element_entry_id is null THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 30);
      --
      --
      -- In this case, we would have to create an element entry to the
      -- assignment and return the entry id, the rest would be handled
      -- by the update command in the calling procedure.
      --
      pay_element_entry_api.create_element_entry
         (p_effective_date        => l_effective_date
         ,p_business_group_id     => l_business_group_id
         ,p_assignment_id         => p_assignment_id
         ,p_element_link_id       => l_element_link_id
         ,p_entry_type            => 'E'
           --Claim Exemption under Sec 80GG
         ,p_input_value_id1          => l_input_values(0).input_value_id
         ,p_entry_value1             => p_claim_exemp_under_sec_80gg
         ,p_effective_start_date     => l_effective_start_date
         ,p_effective_end_date       => l_effective_end_date
         ,p_element_entry_id         => l_element_entry_id
         ,p_object_version_number    => l_object_version_number
         ,p_create_warning           => p_warnings
         );
      --
      pay_in_utils.set_location(g_debug, l_procedure, 40);
      --
      -- End date the entry as of the financial year end date
      --
      --
      pay_in_utils.set_location(g_debug, l_procedure, 45);
        --
      delete_declaration
         (p_element_entry_id => l_element_entry_id
         ,p_effective_date   => pay_in_utils.next_tax_year(l_effective_date)-1
         ,p_warnings         => l_warnings);
        --
      --
   ELSE
      --
      pay_in_utils.set_location(g_debug, l_procedure, 50);
      --
      --
      -- An element entry for this element already exists we have to
      -- update the element entry with the newly submitted date.
      --
        pay_element_entry_api.update_element_entry
         (p_datetrack_update_mode    => get_update_mode(l_element_entry_id
                                                       ,l_effective_date)
         ,p_effective_date           => l_effective_date
         ,p_business_group_id        => l_business_group_id
         ,p_element_entry_id         => l_element_entry_id
         ,p_object_version_number    => l_object_version_number
           --Claim Exemption under Sec 80GG
         ,p_input_value_id1          => l_input_values(0).input_value_id
         ,p_entry_value1             => p_claim_exemp_under_sec_80gg
         ,p_effective_start_date     => l_effective_start_date
         ,p_effective_end_date       => l_effective_end_date
         ,p_update_warning           => p_warnings
         );
      --
      --
      pay_in_utils.set_location(g_debug, l_procedure, 60);
      --
      l_endation_date := pay_in_utils.next_tax_year(l_effective_date);
      --
      IF l_effective_end_date <> (l_endation_date - 1) THEN
        --
        -- End date the entry as of the financial year end date
        --
        delete_declaration
           (p_element_entry_id =>l_element_entry_id
           ,p_effective_date   =>l_endation_date-1
           ,p_warnings         =>l_warnings);
        --
      END IF;
      --

      --
   END IF;
   --
   IF g_debug THEN
      pay_in_utils.trace('Effective Start Date: ', l_effective_start_date);
      pay_in_utils.trace('Effective End Date: ', l_effective_end_date);
   END IF;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
   --
EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
         (p_pkg_name => g_package
         ,p_procedure_name => 'declare_section80gg'
         ,p_error_text => substr(sqlerrm, 1, 240)
         );

END;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_SECTION80E                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Deduction under Section 80E' element.   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_effective_date             DATE                   --
--                  p_higher_education_loan_80e  NUMBER                 --
--            OUT : p_warnings                   BOOLEAN                --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  14-Apr-2005  VGSRINIV    Initial Version                        --
--------------------------------------------------------------------------

PROCEDURE declare_section80e
          (p_assignment_id              IN   per_assignments_f.assignment_id%TYPE
	  ,p_effective_date             IN   DATE DEFAULT NULL
          ,p_higher_education_loan_80e  IN   NUMBER DEFAULT NULL
          ,p_warnings                   OUT  NOCOPY BOOLEAN)
IS

   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_input_values t_input_values_tab;
   l_element_type_id  pay_element_types_f.element_type_id%TYPE;
   l_element_link_id      pay_element_links_f.element_link_id%TYPE;
   l_element_entry_id pay_element_entries_f.element_entry_id%TYPE;
   l_business_group_id per_business_groups.business_group_id%TYPE;
   l_object_version_number pay_element_entries_f.object_version_number%TYPE;
   l_effective_start_date DATE;
   l_effective_end_date DATE;
   l_effective_date DATE;
   l_endation_date DATE;
   l_warnings VARCHAR2(6);
   --
BEGIN
   --
    l_procedure := g_package || 'declare_section80e';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id',p_assignment_id);
      pay_in_utils.trace('p_effective_date     ',p_effective_date );
      pay_in_utils.trace('p_higher_education_loan_80e ',p_higher_education_loan_80e);
      pay_in_utils.trace('**************************************************','********************');
    END IF;
   --
   l_effective_date := pay_in_utils.get_effective_date(p_effective_date);
   --


   get_entry_details(p_assignment_id        => p_assignment_id
                    ,p_element_name         => 'Deduction under Section 80E'
                    ,p_effective_date       => l_effective_date
                    ,p_element_type_id      => l_element_type_id
                    ,p_element_link_id      => l_element_link_id
                    ,p_element_entry_id     => l_element_entry_id
                    ,p_expected_entries     => 2
                    ,p_business_group_id    => l_business_group_id
                    ,p_object_version_number=> l_object_version_number
                    ,p_input_values         => l_input_values
                    );
   --
   IF g_debug THEN
      hr_utility.trace('Element Type ID: ' || l_element_type_id);
      hr_utility.trace('Element Entry ID: ' || l_element_entry_id);
      hr_utility.trace('Business Group ID: ' || l_business_group_id);
      hr_utility.trace('Object Version Number: ' || l_object_version_number);
   END IF;
   --
   pay_in_utils.set_location(g_debug, l_procedure, 20);
   --
   IF l_element_entry_id is null THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 30);
      --
      --
      -- In this case, we would have to create an element entry to the
      -- assignment and return the entry id, the rest would be handled
      -- by the update command in the calling procedure.
      --
      pay_element_entry_api.create_element_entry
         (p_effective_date        => l_effective_date
         ,p_business_group_id     => l_business_group_id
         ,p_assignment_id         => p_assignment_id
         ,p_element_link_id       => l_element_link_id
         ,p_entry_type            => 'E'
           --Claim Exemption under Sec 80E
         ,p_input_value_id1          => l_input_values(0).input_value_id
         ,p_entry_value1             => p_higher_education_loan_80e
         ,p_effective_start_date     => l_effective_start_date
         ,p_effective_end_date       => l_effective_end_date
         ,p_element_entry_id         => l_element_entry_id
         ,p_object_version_number    => l_object_version_number
         ,p_create_warning           => p_warnings
         );
      --
      pay_in_utils.set_location(g_debug, l_procedure, 40);
      --
      -- End date the entry as of the financial year end date
      --
      --
      pay_in_utils.set_location(g_debug, l_procedure, 45);
        --
      delete_declaration
         (p_element_entry_id => l_element_entry_id
         ,p_effective_date   => pay_in_utils.next_tax_year(l_effective_date)-1
         ,p_warnings         => l_warnings);
        --
      --
   ELSE
      --
      pay_in_utils.set_location(g_debug, l_procedure, 50);
      --
      --
      -- An element entry for this element already exists we have to
      -- update the element entry with the newly submitted date.
      --
      IF p_higher_education_loan_80e > 0 THEN

        pay_element_entry_api.update_element_entry
         (p_datetrack_update_mode    => get_update_mode(l_element_entry_id
                                                       ,l_effective_date)
         ,p_effective_date           => l_effective_date
         ,p_business_group_id        => l_business_group_id
         ,p_element_entry_id         => l_element_entry_id
         ,p_object_version_number    => l_object_version_number
           --Claim Exemption under Sec 80E
         ,p_input_value_id1          => l_input_values(0).input_value_id
         ,p_entry_value1             => p_higher_education_loan_80e
         ,p_effective_start_date     => l_effective_start_date
         ,p_effective_end_date       => l_effective_end_date
         ,p_update_warning           => p_warnings
         );
      --
      --
      pay_in_utils.set_location(g_debug, l_procedure, 60);
      --
      l_endation_date := pay_in_utils.next_tax_year(l_effective_date);

      IF l_effective_end_date <> (l_endation_date - 1) THEN
        --
        -- End date the entry as of the financial year end date
        --
        delete_declaration
           (p_element_entry_id =>l_element_entry_id
           ,p_effective_date   =>l_endation_date-1
           ,p_warnings         =>l_warnings);
        --
      END IF;

     ELSE

        delete_declaration
           (p_element_entry_id =>l_element_entry_id
           ,p_effective_date   =>l_effective_date
           ,p_warnings         =>l_warnings);

     END IF;
      --

      --
   END IF;
   --
      IF g_debug THEN
         pay_in_utils.trace('Effective Start Date: ', l_effective_start_date);
         pay_in_utils.trace('Effective End Date: ', l_effective_end_date);
      END IF;

   --
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,80);
   --
EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
         (p_pkg_name => g_package
         ,p_procedure_name => 'declare_section80e'
         ,p_error_text => substr(sqlerrm, 1, 240)
         );

END;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_SECTION80CCF                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Deduction under Section 80CCF' element.   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_effective_date             DATE                   --
--                  p_infrastructure_bonds_80ccf  NUMBER                 --
--            OUT : p_warnings                   BOOLEAN                --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  11-Mar-2010  MDUBASI    Initial Version                        --
--------------------------------------------------------------------------

PROCEDURE declare_section80ccf
          (p_assignment_id              IN   per_assignments_f.assignment_id%TYPE
	  ,p_effective_date             IN   DATE DEFAULT NULL
          ,p_infrastructure_bonds_80ccf  IN   NUMBER DEFAULT NULL
          ,p_warnings                   OUT  NOCOPY BOOLEAN)
IS

   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_input_values t_input_values_tab;
   l_element_type_id  pay_element_types_f.element_type_id%TYPE;
   l_element_link_id      pay_element_links_f.element_link_id%TYPE;
   l_element_entry_id pay_element_entries_f.element_entry_id%TYPE;
   l_business_group_id per_business_groups.business_group_id%TYPE;
   l_object_version_number pay_element_entries_f.object_version_number%TYPE;
   l_effective_start_date DATE;
   l_effective_end_date DATE;
   l_effective_date DATE;
   l_endation_date DATE;
   l_warnings VARCHAR2(6);
   --
BEGIN
   --
    l_procedure := g_package || 'declare_section80ccf';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id',p_assignment_id);
      pay_in_utils.trace('p_effective_date     ',p_effective_date );
      pay_in_utils.trace('p_infrastructure_bonds_80ccf ',p_infrastructure_bonds_80ccf);
      pay_in_utils.trace('**************************************************','********************');
    END IF;
   --
   l_effective_date := pay_in_utils.get_effective_date(p_effective_date);
   --


   get_entry_details(p_assignment_id        => p_assignment_id
                    ,p_element_name         => 'Deduction under Section 80CCF'
                    ,p_effective_date       => l_effective_date
                    ,p_element_type_id      => l_element_type_id
                    ,p_element_link_id      => l_element_link_id
                    ,p_element_entry_id     => l_element_entry_id
                    ,p_expected_entries     => 3
                    ,p_business_group_id    => l_business_group_id
                    ,p_object_version_number=> l_object_version_number
                    ,p_input_values         => l_input_values
                    );
   --
   IF g_debug THEN
      hr_utility.trace('Element Type ID: ' || l_element_type_id);
      hr_utility.trace('Element Entry ID: ' || l_element_entry_id);
      hr_utility.trace('Business Group ID: ' || l_business_group_id);
      hr_utility.trace('Object Version Number: ' || l_object_version_number);
   END IF;
   --
   pay_in_utils.set_location(g_debug, l_procedure, 20);
   --
   IF l_element_entry_id is null THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 30);
      --
      --
      -- In this case, we would have to create an element entry to the
      -- assignment and return the entry id, the rest would be handled
      -- by the update command in the calling procedure.
      --
      pay_element_entry_api.create_element_entry
         (p_effective_date        => l_effective_date
         ,p_business_group_id     => l_business_group_id
         ,p_assignment_id         => p_assignment_id
         ,p_element_link_id       => l_element_link_id
         ,p_entry_type            => 'E'
           --Claim Exemption under Sec 80CCF
         ,p_input_value_id1          => l_input_values(0).input_value_id
         ,p_entry_value1             => p_infrastructure_bonds_80ccf
         ,p_effective_start_date     => l_effective_start_date
         ,p_effective_end_date       => l_effective_end_date
         ,p_element_entry_id         => l_element_entry_id
         ,p_object_version_number    => l_object_version_number
         ,p_create_warning           => p_warnings
         );
      --
      pay_in_utils.set_location(g_debug, l_procedure, 40);
      --
      -- End date the entry as of the financial year end date
      --
      --
      pay_in_utils.set_location(g_debug, l_procedure, 45);
        --
      delete_declaration
         (p_element_entry_id => l_element_entry_id
         ,p_effective_date   => pay_in_utils.next_tax_year(l_effective_date)-1
         ,p_warnings         => l_warnings);
        --
      --
   ELSE
      --
      pay_in_utils.set_location(g_debug, l_procedure, 50);
      --
      --
      -- An element entry for this element already exists we have to
      -- update the element entry with the newly submitted date.
      --
      IF p_infrastructure_bonds_80ccf > 0 THEN

        pay_element_entry_api.update_element_entry
         (p_datetrack_update_mode    => get_update_mode(l_element_entry_id
                                                       ,l_effective_date)
         ,p_effective_date           => l_effective_date
         ,p_business_group_id        => l_business_group_id
         ,p_element_entry_id         => l_element_entry_id
         ,p_object_version_number    => l_object_version_number
           --Claim Exemption under Sec 80CCF
         ,p_input_value_id1          => l_input_values(0).input_value_id
         ,p_entry_value1             => p_infrastructure_bonds_80ccf
         ,p_effective_start_date     => l_effective_start_date
         ,p_effective_end_date       => l_effective_end_date
         ,p_update_warning           => p_warnings
         );
      --
      --
      pay_in_utils.set_location(g_debug, l_procedure, 60);
      --
      l_endation_date := pay_in_utils.next_tax_year(l_effective_date);

      IF l_effective_end_date <> (l_endation_date - 1) THEN
        --
        -- End date the entry as of the financial year end date
        --
        delete_declaration
           (p_element_entry_id =>l_element_entry_id
           ,p_effective_date   =>l_endation_date-1
           ,p_warnings         =>l_warnings);
        --
      END IF;

     ELSE

        delete_declaration
           (p_element_entry_id =>l_element_entry_id
           ,p_effective_date   =>l_effective_date
           ,p_warnings         =>l_warnings);

     END IF;
      --

      --
   END IF;
   --
      IF g_debug THEN
         pay_in_utils.trace('Effective Start Date: ', l_effective_start_date);
         pay_in_utils.trace('Effective End Date: ', l_effective_end_date);
      END IF;

   --
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,80);
   --
EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
         (p_pkg_name => g_package
         ,p_procedure_name => 'declare_section80ccf'
         ,p_error_text => substr(sqlerrm, 1, 240)
         );

END declare_section80ccf;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_SECTION80GGA                                --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Deduction under Section 80GGA' element. --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_effective_date              DATE                  --
--                  p_donation_for_research_80gga NUMBER                --
--            OUT : p_warnings                    BOOLEAN               --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  14-Apr-2005  VGSRINIV    Initial Version                        --
--------------------------------------------------------------------------

PROCEDURE declare_section80gga
          (p_assignment_id               IN   per_assignments_f.assignment_id%TYPE
	  ,p_effective_date              IN   DATE DEFAULT NULL
          ,p_donation_for_research_80gga IN   NUMBER DEFAULT NULL
          ,p_warnings                    OUT  NOCOPY BOOLEAN)
IS

   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_input_values t_input_values_tab;
   l_element_type_id  pay_element_types_f.element_type_id%TYPE;
   l_element_link_id      pay_element_links_f.element_link_id%TYPE;
   l_element_entry_id pay_element_entries_f.element_entry_id%TYPE;
   l_business_group_id per_business_groups.business_group_id%TYPE;
   l_object_version_number pay_element_entries_f.object_version_number%TYPE;
   l_effective_start_date DATE;
   l_effective_end_date DATE;
   l_effective_date DATE;
   l_endation_date DATE;
   l_warnings VARCHAR2(6);
   --
BEGIN
   --
    l_procedure := g_package || 'declare_section80gga';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id',p_assignment_id);
      pay_in_utils.trace('p_effective_date     ',p_effective_date );
      pay_in_utils.trace('p_donation_for_research_80gga ',p_donation_for_research_80gga);
      pay_in_utils.trace('**************************************************','********************');
    END IF;
   --
   l_effective_date := pay_in_utils.get_effective_date(p_effective_date);
   --
   --

   get_entry_details(p_assignment_id        => p_assignment_id
                    ,p_element_name         => 'Deduction under Section 80GGA'
                    ,p_effective_date       => l_effective_date
                    ,p_element_type_id      => l_element_type_id
                    ,p_element_link_id      => l_element_link_id
                    ,p_element_entry_id     => l_element_entry_id
                    ,p_expected_entries     => 3
                    ,p_business_group_id    => l_business_group_id
                    ,p_object_version_number=> l_object_version_number
                    ,p_input_values         => l_input_values
                    );
   --
   IF g_debug THEN
      pay_in_utils.trace('Element Type ID: ' , l_element_type_id);
      pay_in_utils.trace('Element Entry ID: ' , l_element_entry_id);
      pay_in_utils.trace('Business Group ID: ' , l_business_group_id);
      pay_in_utils.trace('Object Version Number: ' , l_object_version_number);
   END IF;

   --
   pay_in_utils.set_location(g_debug, l_procedure, 20);
   --
   IF l_element_entry_id is null THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 30);
      --
      --
      -- In this case, we would have to create an element entry to the
      -- assignment and return the entry id, the rest would be handled
      -- by the update command in the calling procedure.
      --
      pay_element_entry_api.create_element_entry
         (p_effective_date        => l_effective_date
         ,p_business_group_id     => l_business_group_id
         ,p_assignment_id         => p_assignment_id
         ,p_element_link_id       => l_element_link_id
         ,p_entry_type            => 'E'
           --Deduction under Sec 80GGA
         ,p_input_value_id1          => l_input_values(0).input_value_id
         ,p_entry_value1             => p_donation_for_research_80gga
         ,p_effective_start_date     => l_effective_start_date
         ,p_effective_end_date       => l_effective_end_date
         ,p_element_entry_id         => l_element_entry_id
         ,p_object_version_number    => l_object_version_number
         ,p_create_warning           => p_warnings
         );
      --
      pay_in_utils.set_location(g_debug, l_procedure, 40);
      --
      -- End date the entry as of the financial year end date
      --
      --
      pay_in_utils.set_location(g_debug, l_procedure, 45);
        --
      delete_declaration
         (p_element_entry_id => l_element_entry_id
         ,p_effective_date   => pay_in_utils.next_tax_year(l_effective_date)-1
         ,p_warnings         => l_warnings);
        --
      --
   ELSE
      --
      pay_in_utils.set_location(g_debug, l_procedure, 50);
      --
      --
      -- An element entry for this element already exists we have to
      -- update the element entry with the newly submitted date.
      --
      IF p_donation_for_research_80gga > 0 THEN

        pay_element_entry_api.update_element_entry
         (p_datetrack_update_mode    => get_update_mode(l_element_entry_id
                                                       ,l_effective_date)
         ,p_effective_date           => l_effective_date
         ,p_business_group_id        => l_business_group_id
         ,p_element_entry_id         => l_element_entry_id
         ,p_object_version_number    => l_object_version_number
           --Deduction under Sec 80GGA
         ,p_input_value_id1          => l_input_values(0).input_value_id
         ,p_entry_value1             => p_donation_for_research_80gga
         ,p_effective_start_date     => l_effective_start_date
         ,p_effective_end_date       => l_effective_end_date
         ,p_update_warning           => p_warnings
         );
      --
      --
      pay_in_utils.set_location(g_debug, l_procedure, 60);
      --
      l_endation_date := pay_in_utils.next_tax_year(l_effective_date);
      --
      IF l_effective_end_date <> (l_endation_date - 1) THEN
        --
        -- End date the entry as of the financial year end date
        --
        delete_declaration
           (p_element_entry_id =>l_element_entry_id
           ,p_effective_date   =>l_endation_date-1
           ,p_warnings         =>l_warnings);
        --
      END IF;

     ELSE

        delete_declaration
           (p_element_entry_id =>l_element_entry_id
           ,p_effective_date   =>l_effective_date
           ,p_warnings         =>l_warnings);

     END IF;

      --
   END IF;
   --
      IF g_debug THEN
         pay_in_utils.trace('Effective Start Date: ', l_effective_start_date);
         pay_in_utils.trace('Effective End Date: ', l_effective_end_date);
      END IF;
   --
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
   --
EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
         (p_pkg_name => g_package
         ,p_procedure_name => 'declare_section80gga'
         ,p_error_text => substr(sqlerrm, 1, 240)
         );

END;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_SECTION80D                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Deduction under Section 80D' element.   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_effective_date              DATE                  --
--                  p_medical_insurance_prem_80d  NUMBER                --
--                  p_sec_80d_senior_citizen      VARCHAR2              --
--            OUT : p_warnings                    BOOLEAN               --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  14-Apr-2005  VGSRINIV    Initial Version                        --
--------------------------------------------------------------------------

PROCEDURE declare_section80d
          (p_assignment_id               IN   per_assignments_f.assignment_id%TYPE
	  ,p_effective_date              IN   DATE DEFAULT NULL
          ,p_medical_insurance_prem_80d  IN   NUMBER DEFAULT NULL
	  ,p_sec_80d_senior_citizen      IN   VARCHAR2 DEFAULT NULL
	  ,p_med_par_insurance_prem_80d  IN   NUMBER DEFAULT NULL
	  ,p_sec_80d_par_senior_citizen  IN   VARCHAR2 DEFAULT NULL
          ,p_warnings                    OUT  NOCOPY BOOLEAN)
IS

   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_input_values t_input_values_tab;
   l_element_type_id  pay_element_types_f.element_type_id%TYPE;
   l_element_link_id      pay_element_links_f.element_link_id%TYPE;
   l_element_entry_id pay_element_entries_f.element_entry_id%TYPE;
   l_business_group_id per_business_groups.business_group_id%TYPE;
   l_object_version_number pay_element_entries_f.object_version_number%TYPE;
   l_effective_start_date DATE;
   l_effective_end_date DATE;
   l_effective_date DATE;
   l_endation_date DATE;
   l_warnings VARCHAR2(6);
   --
BEGIN
   --
    l_procedure := g_package || 'declare_section80d';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id',p_assignment_id);
      pay_in_utils.trace('p_effective_date     ',p_effective_date );
      pay_in_utils.trace('p_medical_insurance_prem_80d ',p_medical_insurance_prem_80d);
      pay_in_utils.trace('p_sec_80d_senior_citizen ',p_sec_80d_senior_citizen);
      pay_in_utils.trace('p_med_par_insurance_prem_80d ',p_med_par_insurance_prem_80d);
      pay_in_utils.trace('p_sec_80d_par_senior_citizen ',p_sec_80d_par_senior_citizen);
      pay_in_utils.trace('**************************************************','********************');
    END IF;
   --
   l_effective_date := pay_in_utils.get_effective_date(p_effective_date);
   --
   --

   get_entry_details(p_assignment_id        => p_assignment_id
                    ,p_element_name         => 'Deduction under Section 80D'
                    ,p_effective_date       => l_effective_date
                    ,p_element_type_id      => l_element_type_id
                    ,p_element_link_id      => l_element_link_id
                    ,p_element_entry_id     => l_element_entry_id
                    ,p_expected_entries     => 6
                    ,p_business_group_id    => l_business_group_id
                    ,p_object_version_number=> l_object_version_number
                    ,p_input_values         => l_input_values
                    );
   --
   IF g_debug THEN
      pay_in_utils.trace('Element Type ID: ' , l_element_type_id);
      pay_in_utils.trace('Element Entry ID: ' , l_element_entry_id);
      pay_in_utils.trace('Business Group ID: ' , l_business_group_id);
      pay_in_utils.trace('Object Version Number: ' , l_object_version_number);
   END IF;
   --
   pay_in_utils.set_location(g_debug, l_procedure, 20);
   --
   IF l_element_entry_id is null THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 30);
      --
      --
      -- In this case, we would have to create an element entry to the
      -- assignment and return the entry id, the rest would be handled
      -- by the update command in the calling procedure.
      --
      pay_element_entry_api.create_element_entry
         (p_effective_date        => l_effective_date
         ,p_business_group_id     => l_business_group_id
         ,p_assignment_id         => p_assignment_id
         ,p_element_link_id       => l_element_link_id
         ,p_entry_type            => 'E'
           --Deduction under Sec 80D
         ,p_input_value_id1          => l_input_values(0).input_value_id
         ,p_entry_value1             => p_medical_insurance_prem_80d
         ,p_input_value_id2          => l_input_values(2).input_value_id
         ,p_entry_value2             => p_sec_80d_senior_citizen
	 ,p_input_value_id3          => l_input_values(4).input_value_id
         ,p_entry_value3             => p_med_par_insurance_prem_80d
         ,p_input_value_id4          => l_input_values(5).input_value_id
         ,p_entry_value4             => p_sec_80d_par_senior_citizen
         ,p_effective_start_date     => l_effective_start_date
         ,p_effective_end_date       => l_effective_end_date
         ,p_element_entry_id         => l_element_entry_id
         ,p_object_version_number    => l_object_version_number
         ,p_create_warning           => p_warnings
         );
      --
      pay_in_utils.set_location(g_debug, l_procedure, 40);
      --
      -- End date the entry as of the financial year end date
      --
      --
      pay_in_utils.set_location(g_debug, l_procedure, 45);
        --
      delete_declaration
         (p_element_entry_id => l_element_entry_id
         ,p_effective_date   => pay_in_utils.next_tax_year(l_effective_date)-1
         ,p_warnings         => l_warnings);
        --
      --
   ELSE
      --
      pay_in_utils.set_location(g_debug, l_procedure, 50);
      --
      --
      -- An element entry for this element already exists we have to
      -- update the element entry with the newly submitted date.
      --


        pay_element_entry_api.update_element_entry
         (p_datetrack_update_mode    => get_update_mode(l_element_entry_id
                                                       ,l_effective_date)
         ,p_effective_date           => l_effective_date
         ,p_business_group_id        => l_business_group_id
         ,p_element_entry_id         => l_element_entry_id
         ,p_object_version_number    => l_object_version_number
           --Deduction under Sec 80D
         ,p_input_value_id1          => l_input_values(0).input_value_id
         ,p_entry_value1             => p_medical_insurance_prem_80d
         ,p_input_value_id2          => l_input_values(2).input_value_id
         ,p_entry_value2             => p_sec_80d_senior_citizen
	 ,p_input_value_id3          => l_input_values(4).input_value_id
         ,p_entry_value3             => p_med_par_insurance_prem_80d
         ,p_input_value_id4          => l_input_values(5).input_value_id
         ,p_entry_value4             => p_sec_80d_par_senior_citizen
         ,p_effective_start_date     => l_effective_start_date
         ,p_effective_end_date       => l_effective_end_date
         ,p_update_warning           => p_warnings
         );
      --
      --
      pay_in_utils.set_location(g_debug, l_procedure, 60);
      --
      l_endation_date := pay_in_utils.next_tax_year(l_effective_date);
      --
      IF l_effective_end_date <> (l_endation_date - 1) THEN
        --
        -- End date the entry as of the financial year end date
        --
        delete_declaration
           (p_element_entry_id =>l_element_entry_id
           ,p_effective_date   =>l_endation_date-1
           ,p_warnings         =>l_warnings);
        --
      END IF;

      --

      --
   END IF;
   --
      IF g_debug THEN
         pay_in_utils.trace('Effective Start Date: ', l_effective_start_date);
         pay_in_utils.trace('Effective End Date: ', l_effective_end_date);
      END IF;
      pay_in_utils.set_location(g_debug, l_procedure, 70);
   --
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
   --
EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
         (p_pkg_name => g_package
         ,p_procedure_name => 'declare_section80d'
         ,p_error_text => substr(sqlerrm, 1, 240)
         );

END;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_SECTION80DDB                                --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Deduction under Section 80DDB' element. --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_effective_date              DATE                  --
--                  p_disease_treatment_80ddb     NUMBER                --
--                  p_sec_80ddb_senior_citizen    VARCHAR2              --
--            OUT : p_warnings                    BOOLEAN               --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  14-Apr-2005  VGSRINIV    Initial Version                        --
--------------------------------------------------------------------------
PROCEDURE declare_section80ddb
          (p_assignment_id               IN   per_assignments_f.assignment_id%TYPE
	  ,p_effective_date              IN   DATE DEFAULT NULL
          ,p_disease_treatment_80ddb     IN   NUMBER DEFAULT NULL
	  ,p_sec_80ddb_senior_citizen    IN   VARCHAR2 DEFAULT NULL
          ,p_warnings                    OUT  NOCOPY BOOLEAN)
IS

   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_input_values t_input_values_tab;
   l_element_type_id  pay_element_types_f.element_type_id%TYPE;
   l_element_link_id      pay_element_links_f.element_link_id%TYPE;
   l_element_entry_id pay_element_entries_f.element_entry_id%TYPE;
   l_business_group_id per_business_groups.business_group_id%TYPE;
   l_object_version_number pay_element_entries_f.object_version_number%TYPE;
   l_effective_start_date DATE;
   l_effective_end_date DATE;
   l_effective_date DATE;
   l_endation_date DATE;
   l_warnings VARCHAR2(6);
   --
BEGIN
   --
    l_procedure := g_package || 'declare_section80ddb';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id',p_assignment_id);
      pay_in_utils.trace('p_effective_date     ',p_effective_date );
      pay_in_utils.trace('p_disease_treatment_80ddb ',p_disease_treatment_80ddb);
      pay_in_utils.trace('p_sec_80ddb_senior_citizen ',p_sec_80ddb_senior_citizen);
      pay_in_utils.trace('**************************************************','********************');
    END IF;
   --
   l_effective_date := pay_in_utils.get_effective_date(p_effective_date);
   --

   get_entry_details(p_assignment_id        => p_assignment_id
                    ,p_element_name         => 'Deduction under Section 80DDB'
                    ,p_effective_date       => l_effective_date
                    ,p_element_type_id      => l_element_type_id
                    ,p_element_link_id      => l_element_link_id
                    ,p_element_entry_id     => l_element_entry_id
                    ,p_expected_entries     => 4
                    ,p_business_group_id    => l_business_group_id
                    ,p_object_version_number=> l_object_version_number
                    ,p_input_values         => l_input_values
                    );
   --
   IF g_debug THEN
      pay_in_utils.trace('Element Type ID: ' , l_element_type_id);
      pay_in_utils.trace('Element Entry ID: ' , l_element_entry_id);
      pay_in_utils.trace('Business Group ID: ' , l_business_group_id);
      pay_in_utils.trace('Object Version Number: ' , l_object_version_number);
   END IF;
   --
   pay_in_utils.set_location(g_debug, l_procedure, 20);
   --
   IF l_element_entry_id is null THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 30);
      --
      --
      -- In this case, we would have to create an element entry to the
      -- assignment and return the entry id, the rest would be handled
      -- by the update command in the calling procedure.
      --
      pay_element_entry_api.create_element_entry
         (p_effective_date        => l_effective_date
         ,p_business_group_id     => l_business_group_id
         ,p_assignment_id         => p_assignment_id
         ,p_element_link_id       => l_element_link_id
         ,p_entry_type            => 'E'
           --Deduction under Sec 80DDB
         ,p_input_value_id1          => l_input_values(0).input_value_id
         ,p_entry_value1             => p_disease_treatment_80ddb
         ,p_input_value_id2          => l_input_values(2).input_value_id
         ,p_entry_value2             => p_sec_80ddb_senior_citizen
         ,p_effective_start_date     => l_effective_start_date
         ,p_effective_end_date       => l_effective_end_date
         ,p_element_entry_id         => l_element_entry_id
         ,p_object_version_number    => l_object_version_number
         ,p_create_warning           => p_warnings
         );
      --
      pay_in_utils.set_location(g_debug, l_procedure, 40);
      --
      -- End date the entry as of the financial year end date
      --
      --
      pay_in_utils.set_location(g_debug, l_procedure, 45);
        --
      delete_declaration
         (p_element_entry_id => l_element_entry_id
         ,p_effective_date   => pay_in_utils.next_tax_year(l_effective_date)-1
         ,p_warnings         => l_warnings);
        --
      --
   ELSE
      --
      pay_in_utils.set_location(g_debug, l_procedure, 50);
      --
      --
      -- An element entry for this element already exists we have to
      -- update the element entry with the newly submitted date.
      --

      IF p_disease_treatment_80ddb > 0 THEN

        pay_element_entry_api.update_element_entry
         (p_datetrack_update_mode    => get_update_mode(l_element_entry_id
                                                       ,l_effective_date)
         ,p_effective_date           => l_effective_date
         ,p_business_group_id        => l_business_group_id
         ,p_element_entry_id         => l_element_entry_id
         ,p_object_version_number    => l_object_version_number
           --Deduction under Sec 80DDB
         ,p_input_value_id1          => l_input_values(0).input_value_id
         ,p_entry_value1             => p_disease_treatment_80ddb
         ,p_input_value_id2          => l_input_values(2).input_value_id
         ,p_entry_value2             => p_sec_80ddb_senior_citizen
         ,p_effective_start_date     => l_effective_start_date
         ,p_effective_end_date       => l_effective_end_date
         ,p_update_warning           => p_warnings
         );
      --
      --
      pay_in_utils.set_location(g_debug, l_procedure, 60);
      --
      l_endation_date := pay_in_utils.next_tax_year(l_effective_date);
      --
      IF l_effective_end_date <> (l_endation_date - 1) THEN
        --
        -- End date the entry as of the financial year end date
        --
        delete_declaration
           (p_element_entry_id =>l_element_entry_id
           ,p_effective_date   =>l_endation_date-1
           ,p_warnings         =>l_warnings);
        --
      END IF;

     ELSE

        delete_declaration
           (p_element_entry_id =>l_element_entry_id
           ,p_effective_date   =>l_effective_date
           ,p_warnings         =>l_warnings);

     END IF;


      --

      --
   END IF;
   --
      IF g_debug THEN
         pay_in_utils.trace('Effective Start Date: ', l_effective_start_date);
         pay_in_utils.trace('Effective End Date: ', l_effective_end_date);
      END IF;
      pay_in_utils.set_location(g_debug, l_procedure, 70);
   --
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,80);
   --
EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
         (p_pkg_name => g_package
         ,p_procedure_name => 'declare_section80ddb'
         ,p_error_text => substr(sqlerrm, 1, 240)
         );

END;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_SECTION80U                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Deduction under Section 80U' element.   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_effective_date              DATE                  --
--            OUT : p_warnings                    BOOLEAN               --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  14-Apr-2005  VGSRINIV    Initial Version                        --
--------------------------------------------------------------------------

PROCEDURE declare_section80U
          (p_assignment_id               IN   per_assignments_f.assignment_id%TYPE
	  ,p_effective_date              IN   DATE DEFAULT NULL
          ,p_warnings                    OUT  NOCOPY BOOLEAN)
IS

   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_input_values t_input_values_tab;
   l_element_type_id  pay_element_types_f.element_type_id%TYPE;
   l_element_link_id      pay_element_links_f.element_link_id%TYPE;
   l_element_entry_id pay_element_entries_f.element_entry_id%TYPE;
   l_business_group_id per_business_groups.business_group_id%TYPE;
   l_object_version_number pay_element_entries_f.object_version_number%TYPE;
   l_effective_start_date DATE;
   l_effective_end_date DATE;
   l_effective_date DATE;
   l_endation_date DATE;
   l_warnings VARCHAR2(6);
   --
BEGIN
   --
    l_procedure := g_package || 'declare_section80U';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id',p_assignment_id);
      pay_in_utils.trace('p_effective_date     ',p_effective_date );
      pay_in_utils.trace('**************************************************','********************');
    END IF;

   --
   l_effective_date := pay_in_utils.get_effective_date(p_effective_date);
   --
   --

   get_entry_details(p_assignment_id        => p_assignment_id
                    ,p_element_name         => 'Deduction under Section 80U'
                    ,p_effective_date       => l_effective_date
                    ,p_element_type_id      => l_element_type_id
                    ,p_element_link_id      => l_element_link_id
                    ,p_element_entry_id     => l_element_entry_id
                    ,p_expected_entries     => 1
                    ,p_business_group_id    => l_business_group_id
                    ,p_object_version_number=> l_object_version_number
                    ,p_input_values         => l_input_values
                    );
   --
   IF g_debug THEN
      pay_in_utils.trace('Element Type ID: ' , l_element_type_id);
      pay_in_utils.trace('Element Entry ID: ' , l_element_entry_id);
      pay_in_utils.trace('Business Group ID: ' , l_business_group_id);
      pay_in_utils.trace('Object Version Number: ' , l_object_version_number);
   END IF;
   --
   pay_in_utils.set_location(g_debug, l_procedure, 20);
   --
   IF l_element_entry_id is null THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 30);
      --
      --
      -- In this case, we would have to create an element entry to the
      -- assignment and return the entry id, the rest would be handled
      -- by the update command in the calling procedure.
      --
      pay_element_entry_api.create_element_entry
         (p_effective_date        => l_effective_date
         ,p_business_group_id     => l_business_group_id
         ,p_assignment_id         => p_assignment_id
         ,p_element_link_id       => l_element_link_id
         ,p_entry_type            => 'E'
         ,p_effective_start_date  => l_effective_start_date
         ,p_effective_end_date    => l_effective_end_date
         ,p_element_entry_id      => l_element_entry_id
         ,p_object_version_number => l_object_version_number
         ,p_create_warning        => p_warnings
         );
      --
      pay_in_utils.set_location(g_debug, l_procedure, 40);
      --
   END IF;
   --
      IF g_debug THEN
         pay_in_utils.trace('Effective Start Date: ', l_effective_start_date);
         pay_in_utils.trace('Effective End Date: ', l_effective_end_date);
      END IF;
      pay_in_utils.set_location(g_debug, l_procedure, 50);

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,60);
   --
EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
         (p_pkg_name => g_package
         ,p_procedure_name => 'declare_section80u'
         ,p_error_text => substr(sqlerrm, 1, 240)
         );

END;

/* BUG 4251141: STAT UPDATE 2005 CHANGES END HERE */

PROCEDURE declare_tax
   (p_assignment_id                IN  per_assignments_f.assignment_id%TYPE
   ,p_is_monthly_rent_changed      IN  VARCHAR2
   ,p_apr                          IN  NUMBER   default null
   ,p_may                          IN  NUMBER   default null
   ,p_jun                          IN  NUMBER   default null
   ,p_jul                          IN  NUMBER   default null
   ,p_aug                          IN  NUMBER   default null
   ,p_sep                          IN  NUMBER   default null
   ,p_oct                          IN  NUMBER   default null
   ,p_nov                          IN  NUMBER   default null
   ,p_dec                          IN  NUMBER   default null
   ,p_jan                          IN  NUMBER   default null
   ,p_feb                          IN  NUMBER   default null
   ,p_mar                          IN  NUMBER   default null
   ,p_is_chapter6a_changed         IN  VARCHAR2
   ,p_pension_fund_80ccc           IN  NUMBER   default null
   ,p_medical_insurance_prem_80d   IN  NUMBER   default null
   ,p_med_par_insurance_prem_80d   IN  NUMBER   default NULL
   ,p_80d_par_prem_changed         IN  VARCHAR2 DEFAULT NULL
   ,p_sec_80d_par_senior_citizen   IN  VARCHAR2 default null
   ,p_80d_par_snr_changed          IN  VARCHAR2 DEFAULT NULL
   ,p_sec_80ddb_senior_citizen     IN  VARCHAR2 default null
   ,p_disease_treatment_80ddb      IN  NUMBER   default null
   ,p_sec_80d_senior_citizen       IN  VARCHAR2 default null
   ,p_higher_education_loan_80e    IN  NUMBER   default null
   ,p_claim_exemp_under_sec_80gg   IN  VARCHAR2 default null
   ,p_donation_for_research_80gga  IN  NUMBER   default null
   ,p_80gg_changed                 IN  VARCHAR2 DEFAULT NULL
   ,p_80e_changed                  IN  VARCHAR2 DEFAULT NULL
   ,p_80gga_changed                IN  VARCHAR2 DEFAULT NULL
   ,p_80d_changed                  IN  VARCHAR2 DEFAULT NULL
   ,p_80dsc_planned_value          IN  VARCHAR2 DEFAULT NULL
   ,p_80ddb_changed                IN  VARCHAR2 DEFAULT NULL
   ,p_80ddbsc_planned_value        IN  VARCHAR2 DEFAULT NULL
   ,p_int_on_gen_investment_80L    IN  NUMBER   default null
   ,p_int_on_securities_80L        IN  NUMBER   default null
   ,p_80ccf_changed                IN  Varchar2 default null
   ,p_infrastructure_bonds_80ccf   IN  NUMBER   default null
   ,p_ee_vol_pf_amount             IN  NUMBER   default null
   ,p_ee_vol_pf_percent            IN  NUMBER   default null
   ,p_ee_pf_amt_changed            IN  VARCHAR2 DEFAULT NULL
   ,p_ee_pf_percent_changed        IN  VARCHAR2 DEFAULT NULL
   ,p_is_section88_changed         IN  VARCHAR2 DEFAULT NULL
   ,p_deferred_annuity             IN  NUMBER   default null
   ,p_senior_citizen_sav_scheme    IN  NUMBER   default null
   ,p_public_provident_fund        IN  NUMBER   default null
   ,p_post_office_savings_scheme   IN  NUMBER   default null
   ,p_deposit_in_nsc_vi_issue      IN  NUMBER   default null
   ,p_deposit_in_nsc_viii_issue    IN  NUMBER   default null
   ,p_interest_on_nsc_reinvested   IN  NUMBER   default null
   ,p_house_loan_repayment         IN  NUMBER   default null
   ,p_notified_mutual_fund_or_uti  IN  NUMBER   default null
   ,p_national_housing_bank_scheme IN  NUMBER   default null
   ,p_unit_linked_insurance_plan   IN  NUMBER   default null
   ,p_notified_annuity_plan        IN  NUMBER   default null
   ,p_notified_pension_fund        IN  NUMBER   default null
   ,p_public_sector_company_scheme IN  NUMBER   default null
   ,p_approved_superannuation_fund IN  NUMBER   default null
   ,p_infrastructure_bond          IN  NUMBER   default null
   ,p_tuition_fee_for_child_1      IN  NUMBER   default null
   ,p_tuition_fee_for_child_2      IN  NUMBER   default null
   ,p_is_other_income_changed      IN  VARCHAR2
   ,p_income_from_house_property   IN  NUMBER   default null
   ,p_profit_and_gain_from_busines IN  NUMBER   default null
   ,p_long_term_capital_gain       IN  NUMBER   default null
   ,p_short_term_capital_gain      IN  NUMBER   default null
   ,p_income_from_any_other_source IN  NUMBER   default null
   ,p_tds_paid_on_other_income     IN  NUMBER   default null
   ,p_approved_flag                IN  VARCHAR2 default null
   ,p_comment_text                 IN  VARCHAR2 default null
   ,p_effective_date               IN  DATE     default null
   ,p_warnings                     OUT NOCOPY VARCHAR2)
IS
   --
   l_effective_date DATE;
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_disability_proof VARCHAR2(2);
   l_permanent_disability_80u NUMBER;
   l_category VARCHAR2(10);
   l_degree NUMBER;
   l_declare_warn BOOLEAN;

   CURSOR get_permanent_disability_80u
   IS
   SELECT global_value
     FROM ff_globals_f
    WHERE global_name = 'IN_PERMANENT_PHYSICAL_DISABILITY_80U'
      AND legislation_code = g_legislation_code;
   --
BEGIN
   --
    l_procedure := g_package || 'declare_tax';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace ('p_assignment_id                ',p_assignment_id);
      pay_in_utils.trace ('p_is_monthly_rent_changed      ',p_is_monthly_rent_changed);
      pay_in_utils.trace ('p_apr                          ',p_apr);
      pay_in_utils.trace ('p_may                          ',p_may);
      pay_in_utils.trace ('p_jun                          ',p_jun);
      pay_in_utils.trace ('p_jul                          ',p_jul);
      pay_in_utils.trace ('p_aug                          ',p_aug);
      pay_in_utils.trace ('p_sep                          ',p_sep);
      pay_in_utils.trace ('p_oct                          ',p_oct);
      pay_in_utils.trace ('p_nov                          ',p_nov);
      pay_in_utils.trace ('p_dec                          ',p_dec);
      pay_in_utils.trace ('p_jan                          ',p_jan);
      pay_in_utils.trace ('p_feb                          ',p_feb);
      pay_in_utils.trace ('p_mar                          ',p_mar);
      pay_in_utils.trace ('p_is_chapter6a_changed         ',p_is_chapter6a_changed);
      pay_in_utils.trace ('p_pension_fund_80ccc           ',p_pension_fund_80ccc );
      pay_in_utils.trace ('p_medical_insurance_prem_80d   ',p_medical_insurance_prem_80d);
      pay_in_utils.trace ('p_sec_80ddb_senior_citizen     ',p_sec_80ddb_senior_citizen);
      pay_in_utils.trace ('p_disease_treatment_80ddb      ',p_disease_treatment_80ddb);
      pay_in_utils.trace ('p_sec_80d_senior_citizen       ',p_sec_80d_senior_citizen);
      pay_in_utils.trace ('p_higher_education_loan_80e    ',p_higher_education_loan_80e);
      pay_in_utils.trace ('p_claim_exemp_under_sec_80gg   ',p_claim_exemp_under_sec_80gg);
      pay_in_utils.trace ('p_donation_for_research_80gga  ',p_donation_for_research_80gga);
      pay_in_utils.trace ('p_80gg_changed                 ',p_80gg_changed);
      pay_in_utils.trace ('p_80e_changed                  ',p_80e_changed);
      pay_in_utils.trace ('p_80gga_changed                ',p_80gga_changed);
      pay_in_utils.trace ('p_80d_changed                  ',p_80d_changed);
      pay_in_utils.trace ('p_80dsc_planned_value          ',p_80dsc_planned_value);
      pay_in_utils.trace ('p_80ddb_changed                ',p_80ddb_changed);
      pay_in_utils.trace ('p_80ddbsc_planned_value        ',p_80ddbsc_planned_value);
      pay_in_utils.trace ('p_int_on_gen_investment_80L    ',p_int_on_gen_investment_80L);
      pay_in_utils.trace ('p_int_on_securities_80L        ',p_int_on_securities_80L);
      pay_in_utils.trace ('p_80ccf_changed                ',p_80ccf_changed);
      pay_in_utils.trace ('p_infrastructure_bonds_80ccf   ',p_infrastructure_bonds_80ccf);
      pay_in_utils.trace ('p_ee_vol_pf_amount             ',p_ee_vol_pf_amount);
      pay_in_utils.trace ('p_ee_pf_amt_changed            ',p_ee_pf_amt_changed);
      pay_in_utils.trace ('p_ee_vol_pf_percent            ',p_ee_vol_pf_percent);
      pay_in_utils.trace ('p_ee_pf_percent_changed        ',p_ee_pf_percent_changed);
      pay_in_utils.trace ('p_is_section88_changed         ',p_is_section88_changed);
      pay_in_utils.trace ('p_deferred_annuity             ',p_deferred_annuity);
      pay_in_utils.trace ('p_senior_citizen_sav_scheme    ',p_senior_citizen_sav_scheme);
      pay_in_utils.trace ('p_public_provident_fund        ',p_public_provident_fund);
      pay_in_utils.trace ('p_post_office_savings_scheme   ',p_post_office_savings_scheme);
      pay_in_utils.trace ('p_deposit_in_nsc_vi_issue      ',p_deposit_in_nsc_vi_issue);
      pay_in_utils.trace ('p_deposit_in_nsc_viii_issue    ',p_deposit_in_nsc_viii_issue);
      pay_in_utils.trace ('p_interest_on_nsc_reinvested   ',p_interest_on_nsc_reinvested);
      pay_in_utils.trace ('p_house_loan_repayment         ',p_house_loan_repayment);
      pay_in_utils.trace ('p_notified_mutual_fund_or_uti  ',p_notified_mutual_fund_or_uti);
      pay_in_utils.trace ('p_national_housing_bank_scheme ',p_national_housing_bank_scheme);
      pay_in_utils.trace ('p_unit_linked_insurance_plan   ',p_unit_linked_insurance_plan);
      pay_in_utils.trace ('p_notified_annuity_plan        ',p_notified_annuity_plan);
      pay_in_utils.trace ('p_notified_pension_fund        ',p_notified_pension_fund);
      pay_in_utils.trace ('p_public_sector_company_scheme ',p_public_sector_company_scheme );
      pay_in_utils.trace ('p_approved_superannuation_fund ',p_approved_superannuation_fund);
      pay_in_utils.trace ('p_infrastructure_bond          ',p_infrastructure_bond);
      pay_in_utils.trace ('p_tuition_fee_for_child_1      ',p_tuition_fee_for_child_1);
      pay_in_utils.trace ('p_tuition_fee_for_child_2      ',p_tuition_fee_for_child_2);
      pay_in_utils.trace ('p_is_other_income_changed      ',p_is_other_income_changed);
      pay_in_utils.trace ('p_income_from_house_property   ',p_income_from_house_property);
      pay_in_utils.trace ('p_profit_and_gain_from_busines ',p_profit_and_gain_from_busines);
      pay_in_utils.trace ('p_long_term_capital_gain       ',p_long_term_capital_gain);
      pay_in_utils.trace ('p_short_term_capital_gain      ',p_short_term_capital_gain);
      pay_in_utils.trace ('p_income_from_any_other_source ',p_income_from_any_other_source);
      pay_in_utils.trace ('p_tds_paid_on_other_income     ',p_tds_paid_on_other_income);
      pay_in_utils.trace ('p_approved_flag                ',p_approved_flag);
      pay_in_utils.trace ('p_comment_text                 ',p_comment_text);
      pay_in_utils.trace ('p_effective_date               ',p_effective_date);
      pay_in_utils.trace('**************************************************','********************');
    END IF;
   l_declare_warn := false;
   --

   --
   l_effective_date := pay_in_utils.get_effective_date(p_effective_date);
   -- Added for bug 3990922
   hr_session_utilities.insert_session_row(l_effective_date);
   --
   --
   IF p_is_monthly_rent_changed = 'Y' THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 20);
      --
      declare_house_rent
         (p_assignment_id  => p_assignment_id
         ,p_effective_date => l_effective_date
         ,p_apr            => p_apr
         ,p_may            => p_may
         ,p_jun            => p_jun
         ,p_jul            => p_jul
         ,p_aug            => p_aug
         ,p_sep            => p_sep
         ,p_oct            => p_oct
         ,p_nov            => p_nov
         ,p_dec            => p_dec
         ,p_jan            => p_jan
         ,p_feb            => p_feb
         ,p_mar            => p_mar
         ,p_warnings       => l_declare_warn);
      --
      pay_in_utils.set_location(g_debug, l_procedure, 30);
      --
   END IF;
   --
   pay_in_utils.set_location(g_debug, 'Entering: '||l_procedure, 40);
   --

   IF p_is_chapter6a_changed = 'Y' THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 50);

/* STAT 2005 CHANGES START */

      -- Permanent Disability 80u Calculation
      -- Permanent disability is calculated based on the details
      -- entered in per_disabilities_f by the user. If the
      -- disability proof is submitted then only the exemption
      -- amount is entered i.e., when l_disability_proof = 'Y'.
/*      l_permanent_disability_80u :=
        pay_in_tax_utils.get_disability_details
         (p_assignment_id => p_assignment_id
         ,p_date_earned   => l_effective_date
         ,p_disable_catg  => l_category
         ,p_disable_degree=> l_degree
         ,p_disable_proof => l_disability_proof
         );
      --
      l_permanent_disability_80u := 0;
      --
      IF (l_disability_proof = 'Y' AND l_degree >= 40 AND l_category IN ('BLIND','SA_VIS_IMP','LC','SA_HEA_IMP','LD','07','MI','AU','CP','MD'))
      THEN
      --
        declare_section80u
         (p_assignment_id                   => p_assignment_id
         ,p_effective_date                  => l_effective_date
         ,p_warnings                        => l_declare_warn);
      --
      END IF; */

--      IF p_80gg_changed = 'Y' THEN
      IF p_80gg_changed = 'Y' THEN

        declare_section80gg
         (p_assignment_id                   => p_assignment_id
         ,p_effective_date                  => l_effective_date
         ,p_claim_exemp_under_sec_80gg      => p_claim_exemp_under_sec_80gg
         ,p_warnings                        => l_declare_warn);

      END IF;

     IF p_80e_changed = 'Y' THEN

        declare_section80e
         (p_assignment_id                   => p_assignment_id
         ,p_effective_date                  => l_effective_date
         ,p_higher_education_loan_80e       => p_higher_education_loan_80e
         ,p_warnings                        => l_declare_warn);

      END IF;

     IF p_80ccf_changed = 'Y' THEN
        declare_section80ccf
         (p_assignment_id                   => p_assignment_id
         ,p_effective_date                  => l_effective_date
         ,p_infrastructure_bonds_80ccf      => p_infrastructure_bonds_80ccf
         ,p_warnings                        => l_declare_warn);

     END IF;

      IF p_80gga_changed = 'Y' THEN

        declare_section80gga
         (p_assignment_id                   => p_assignment_id
         ,p_effective_date                  => l_effective_date
         ,p_donation_for_research_80gga     => p_donation_for_research_80gga
         ,p_warnings                        => l_declare_warn);

      END IF;

     IF p_ee_pf_amt_changed = 'Y' OR p_ee_pf_percent_changed = 'Y' THEN
      declare_vpf
      (p_assignment_id          => p_assignment_id
      ,p_effective_date         => l_effective_date
      ,p_ee_vol_pf_amount       => p_ee_vol_pf_amount
      ,p_ee_vol_pf_percent      => p_ee_vol_pf_percent
      ,p_warnings               => l_declare_warn);
     END IF;

      IF p_80d_changed = 'Y'
         OR p_80d_par_prem_changed = 'Y'
	 OR p_80d_par_snr_changed = 'Y'
         OR p_sec_80d_senior_citizen <> p_80dsc_planned_value THEN


         declare_section80d
         (p_assignment_id                   => p_assignment_id
         ,p_effective_date                  => l_effective_date
         ,p_medical_insurance_prem_80d      => NVL (p_medical_insurance_prem_80d,0)
	 ,p_sec_80d_senior_citizen          => p_sec_80d_senior_citizen
	 ,p_med_par_insurance_prem_80d      => p_med_par_insurance_prem_80d
         ,p_sec_80d_par_senior_citizen      => p_sec_80d_par_senior_citizen
	 ,p_warnings                        => l_declare_warn);

      END IF;

      IF p_80ddb_changed = 'Y' OR p_sec_80ddb_senior_citizen <> p_80ddbsc_planned_value THEN

         declare_section80ddb
         (p_assignment_id                   => p_assignment_id
         ,p_effective_date                  => l_effective_date
         ,p_disease_treatment_80ddb         => p_disease_treatment_80ddb
	 ,p_sec_80ddb_senior_citizen        => p_sec_80ddb_senior_citizen
         ,p_warnings                        => l_declare_warn);

      END IF;

/* Stat Changes 2005 End */
      --
/*      declare_chapter6a
         (p_assignment_id                   => p_assignment_id
         ,p_effective_date                  => l_effective_date
         ,p_pension_fund_80ccc              => p_pension_fund_80ccc
         ,p_medical_insurance_prem_80d      => p_medical_insurance_prem_80d
         ,p_sec_80ddb_senior_citizen        => p_sec_80ddb_senior_citizen
         ,p_disease_treatment_80ddb         => p_disease_treatment_80ddb
         ,p_sec_80d_senior_citizen          => p_sec_80d_senior_citizen
         ,p_higher_education_loan_80e       => p_higher_education_loan_80e
         ,p_claim_exemp_under_sec_80gg      => p_claim_exemp_under_sec_80gg
         ,p_donation_for_research_80gga     => p_donation_for_research_80gga
         ,p_int_on_gen_investment_80L       => p_int_on_gen_investment_80L
         ,p_int_on_securities_80L           => p_int_on_securities_80L
         ,p_warnings                        => l_declare_warn);
  */    --
      pay_in_utils.set_location(g_debug, l_procedure, 60);
      --
   END IF; /* p_is_chapter6a_changed = 'Y' */
   --
   pay_in_utils.set_location(g_debug, 'Entering: '||l_procedure, 70);
   --

/*   IF p_is_section88_changed = 'Y' THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 61);
      --
      declare_section88
         (p_assignment_id                  => p_assignment_id
         ,p_effective_date                 => l_effective_date
         ,p_deferred_annuity               => p_deferred_annuity
         ,p_public_provident_fund          => p_public_provident_fund
         ,p_post_office_savings_scheme     => p_post_office_savings_scheme
         ,p_deposit_in_nsc_vi_issue        => p_deposit_in_nsc_vi_issue
         ,p_deposit_in_nsc_viii_issue      => p_deposit_in_nsc_viii_issue
         ,p_interest_on_nsc_reinvested     => p_interest_on_nsc_reinvested
         ,p_house_loan_repayment           => p_house_loan_repayment
         ,p_notified_mutual_fund_or_uti    => p_notified_mutual_fund_or_uti
         ,p_national_housing_bank_scheme   => p_national_housing_bank_scheme
         ,p_unit_linked_insurance_plan     => p_unit_linked_insurance_plan
         ,p_notified_annuity_plan          => p_notified_annuity_plan
         ,p_notified_pension_fund          => p_notified_pension_fund
         ,p_public_sector_company_scheme   => p_public_sector_company_scheme
         ,p_approved_superannuation_fund   => p_approved_superannuation_fund
         ,p_infrastructure_bond            => p_infrastructure_bond
         ,p_warnings                       => l_declare_warn);
      --
      pay_in_utils.set_location(g_debug, l_procedure, 80);
      --
      declare_tuition_fee
         (p_assignment_id           => p_assignment_id
         ,p_effective_date          => l_effective_date
         ,p_tuition_fee_for_child_1 => p_tuition_fee_for_child_1
         ,p_tuition_fee_for_child_2 => p_tuition_fee_for_child_2
         ,p_warnings                => l_declare_warn);
      --
      pay_in_utils.set_location(g_debug, l_procedure, 90);
      --
   END IF; */
   --
   pay_in_utils.set_location(g_debug, l_procedure, 100);
   --

   IF p_is_other_income_changed = 'Y' THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 110);
      --
      declare_other_income
         (p_assignment_id                 => p_assignment_id
         ,p_effective_date                => l_effective_date
         ,p_income_from_house_property    => p_income_from_house_property
         ,p_profit_and_gain_from_busines  => p_profit_and_gain_from_busines
         ,p_long_term_capital_gain        => p_long_term_capital_gain
         ,p_short_term_capital_gain       => p_short_term_capital_gain
         ,p_income_from_any_other_source  => p_income_from_any_other_source
         ,p_tds_paid_on_other_income      => p_tds_paid_on_other_income
         ,p_warnings                      => l_declare_warn);
      --
      pay_in_utils.set_location(g_debug, l_procedure, 120);
   END IF;
   --
   IF p_approved_flag is not null THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 130);
      --
      approve_declaration
         (p_assignment_id  => p_assignment_id
         ,p_approval_flag  => p_approved_flag
         ,p_effective_date => l_effective_date
         ,p_comment_text   => p_comment_text);
      --
      pay_in_utils.set_location(g_debug, l_procedure, 140);
      --
   END IF;
   --
   IF l_declare_warn THEN
      p_warnings := 'TRUE';
   ELSE
      p_warnings := 'FALSE';
   END IF;
   --
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,150);
   --
EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
         (p_pkg_name => g_package
         ,p_procedure_name => 'declare_tax'
         ,p_error_text => substr(sqlerrm, 1, 240)
         );
   --
END declare_tax;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DELETE_DECLARATION                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for deletion of        --
--                  element entries as of the effective date.           --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_element_entry_id        element_entry_id%TYPE     --
--                  p_effective_date          DATE                      --
--            OUT : p_warnings                BOOLEAN                   --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  24-Sep-2004  PUCHIL      Initial Version                        --
--------------------------------------------------------------------------
PROCEDURE delete_declaration
   (p_element_entry_id IN NUMBER
   ,p_effective_date   IN DATE DEFAULT NULL
   ,p_warnings         OUT NOCOPY VARCHAR2)
IS
   --
   l_effective_date DATE;
   l_effective_start_date DATE;
   l_effective_end_date DATE;
   l_object_version_number NUMBER;
   l_warnings BOOLEAN;
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_effective_end_date_check DATE;
   --
   CURSOR csr_entry_details(c_effective_date IN DATE)
   IS
   SELECT object_version_number
         ,effective_end_date
     FROM pay_element_entries_f
    WHERE element_entry_id = p_element_entry_id
      AND c_effective_date BETWEEN effective_start_date
                               AND effective_end_date;
   --
BEGIN
   --
   p_warnings := 'FALSE';

    l_procedure := g_package || 'delete_declaration';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('Element Entry ID:',p_element_Entry_id);
      pay_in_utils.trace('Effective Date:',p_effective_date);
      pay_in_utils.trace('**************************************************','********************');
    END IF;

   l_effective_date := pay_in_utils.get_effective_date(p_effective_date);
   --
   IF g_debug THEN
      pay_in_utils.trace('Calculate Effective Date: ' , l_effective_date);
   END IF;
   --
   OPEN csr_entry_details(l_effective_date);
   FETCH csr_entry_details INTO l_object_version_number
                               ,l_effective_end_date_check;
   CLOSE csr_entry_details;
   --
   IF l_object_version_number is null
   or l_effective_end_date_check = l_effective_date THEN
      return;
   END IF;
   --
   pay_in_utils.set_location(g_debug, l_procedure, 40);
   --
     pay_element_entry_api.delete_element_entry
        (p_validate => FALSE
        ,p_datetrack_delete_mode => hr_api.g_delete
        ,p_effective_date => l_effective_date
        ,p_element_entry_id => p_element_entry_id
        ,p_object_version_number => l_object_version_number
        ,p_effective_start_date => l_effective_start_date
        ,p_effective_end_date => l_effective_end_date
        ,p_delete_warning => l_warnings
        );
   --
   pay_in_utils.set_location(g_debug, l_procedure, 50);
   --
   IF l_warnings = TRUE THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 60);
      p_warnings := 'TRUE';
      --
   END IF;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,70);
   --
EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
         (p_pkg_name => g_package
         ,p_procedure_name => 'delete_declaration'
         ,p_error_text => substr(sqlerrm, 1, 240)
         );
   --
END delete_declaration;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : APPROVE_DECLARATION                                 --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for approval of        --
--                  tax declaration for the assignment in question.     --
--                                                                      --
-- Parameters     :                                                     --
--             IN :p_assignment_id  per_assignments_f.assignment_id%TYPE--
--                  p_approval_flag  VARCHAR2                           --
--                  p_effective_date DATE                               --
--                  p_comment_text   VARCHAR2                           --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  24-Sep-2004  PUCHIL      Initial Version                        --
--------------------------------------------------------------------------
PROCEDURE approve_declaration
   (p_assignment_id  IN per_assignments_f.assignment_id%TYPE
   ,p_approval_flag  IN VARCHAR2
   ,p_effective_date IN DATE
   ,p_comment_text   IN VARCHAR2)
IS
   --
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_approval_status VARCHAR2(2);
   l_object_version_number NUMBER;
   l_extra_info_id per_assignment_extra_info.assignment_extra_info_id%TYPE;
   --
   CURSOR get_object_version(c_extra_info_id IN NUMBER)
   IS
   SELECT object_version_number
   FROM   per_assignment_extra_info
   WHERE  assignment_extra_info_id = c_extra_info_id;
   --
BEGIN
   --
    l_procedure := g_package || 'approve_declaration';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id',p_assignment_id);
      pay_in_utils.trace('p_effective_date     ',p_effective_date );
      pay_in_utils.trace('p_approval_flag ',p_approval_flag);
      pay_in_utils.trace('p_comment_text ',p_comment_text);
      pay_in_utils.trace('**************************************************','********************');
    END IF;


   --
   l_approval_status := get_approval_status
      (p_assignment_id
      ,get_tax_year(p_effective_date)
      ,l_extra_info_id);
   --
   pay_in_utils.set_location(g_debug, l_procedure, 20);
   --
   IF l_approval_status is not null THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 30);
      --
      OPEN get_object_version(l_extra_info_id);
      FETCH get_object_version INTO l_object_version_number;
      CLOSE get_object_version;
      --
      pay_in_utils.set_location(g_debug, l_procedure, 40);
      --
      hr_assignment_extra_info_api.update_assignment_extra_info
         (p_assignment_extra_info_id => l_extra_info_id
         ,p_object_version_number    => l_object_version_number
         ,p_aei_information_category => g_approval_info_type
         ,p_aei_information1         => get_tax_year(p_effective_date)
         ,p_aei_information2         => p_approval_flag
         ,p_aei_information3         => substr(p_comment_text, 0, 150));
      --
      pay_in_utils.set_location(g_debug, l_procedure, 50);
      --
   ELSE
      --
      pay_in_utils.set_location(g_debug, l_procedure, 60);
      --
      hr_assignment_extra_info_api.create_assignment_extra_info
         (p_assignment_id            => p_assignment_id
         ,p_information_type         => g_approval_info_type
         ,p_aei_information_category => g_approval_info_type
         ,p_aei_information1         => get_tax_year(p_effective_date)
         ,p_aei_information2         => p_approval_flag
         ,p_aei_information3         => substr(p_comment_text, 0, 150)
         ,p_assignment_extra_info_id => l_extra_info_id
         ,p_object_version_number    => l_object_version_number);
      --
      pay_in_utils.set_location(g_debug, l_procedure, 70);
      --
   END IF;
   --
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,80);
   --
EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
         (p_pkg_name => g_package
         ,p_procedure_name => 'approve_declaration'
         ,p_error_text => substr(sqlerrm, 1, 240)
         );
   --
END approve_declaration;

-- Start changes to Enhancement 3886086(Web ADI)

--------------------------------------------------------------------------
--                                                                      --
-- Name           : WEB_ADI_DECLARE_TAX                                 --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  details through WEB ADI                         .   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_effective_date              DATE                  --
--                  p_warnings                    BOOLEAN               --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.1  20-Jun-2005  abhjain     Added changes after stat update        --
--------------------------------------------------------------------------

PROCEDURE web_adi_declare_tax
   (p_assignment_id                 IN number
   ,p_effective_date                IN date default null
   ,p_april                         IN number default null
   ,p_may                           IN number default null
   ,p_june                          IN number default null
   ,p_july                          IN number default null
   ,p_august                        IN number default null
   ,p_september                     IN number default null
   ,p_october                       IN number default null
   ,p_november                      IN number default null
   ,p_december                      IN number default null
   ,p_january                       IN number default null
   ,p_february                      IN number default null
   ,p_march                         IN number default null
   ,p_cce_ee_id1                    IN number default null
   ,p_cce_component1                IN varchar2 default null
   ,p_investment_amount1            IN number default null
   ,p_cce_ee_id2                    IN number default null
   ,p_cce_component2                IN varchar2 default null
   ,p_investment_amount2            IN number default null
   ,p_cce_ee_id3                    IN number default null
   ,p_cce_component3                IN varchar2 default null
   ,p_investment_amount3            IN number default null
   ,p_cce_ee_id4                    IN number default null
   ,p_cce_component4                IN varchar2 default null
   ,p_investment_amount4            IN number default null
   ,p_cce_ee_id5                    IN number default null
   ,p_cce_component5                IN varchar2 default null
   ,p_investment_amount5            IN number default null
   ,p_cce_ee_id6                    IN number default null
   ,p_cce_component6                IN varchar2 default null
   ,p_investment_amount6            IN number default null
   ,p_cce_ee_id7                    IN number default null
   ,p_cce_component7                IN varchar2 default null
   ,p_investment_amount7            IN number default null
   ,p_cce_ee_id8                    IN number default null
   ,p_cce_component8                IN varchar2 default null
   ,p_investment_amount8            IN number default null
   ,p_cce_ee_id9                    IN number default null
   ,p_cce_component9                IN varchar2 default null
   ,p_investment_amount9            IN number default null
   ,p_cce_ee_id10                   IN number default null
   ,p_cce_component10               IN varchar2 default null
   ,p_investment_amount10           IN number default null
   ,p_cce_ee_id11                   IN number default null
   ,p_cce_component11               IN varchar2 default null
   ,p_investment_amount11           IN number default null
   ,p_cce_ee_id12                   IN number default null
   ,p_cce_component12               IN varchar2 default null
   ,p_investment_amount12           IN number default null
   ,p_cce_ee_id13                   IN number default null
   ,p_cce_component13               IN varchar2 default null
   ,p_investment_amount13           IN number default null
   ,p_cce_ee_id14                   IN number default null
   ,p_cce_component14               IN varchar2 default null
   ,p_investment_amount14           IN number default null
   ,p_cce_ee_id15                   IN number default null
   ,p_cce_component15               IN varchar2 default null
   ,p_investment_amount15           IN number default null
   ,p_cce_ee_id16                   IN number default null
   ,p_cce_component16               IN varchar2 default null
   ,p_investment_amount16           IN number default null
   ,p_cce_ee_id17                   IN number default null
   ,p_cce_component17               IN varchar2 default null
   ,p_investment_amount17           IN number default null
   ,p_cce_ee_id18                   IN number default null
   ,p_cce_component18               IN varchar2 default null
   ,p_investment_amount18           IN number default null
   ,p_cce_ee_id19                   IN number default null
   ,p_cce_component19               IN varchar2 default null
   ,p_investment_amount19           IN number default null
   ,p_cce_ee_id20                   IN number default null
   ,p_cce_component20               IN varchar2 default null
   ,p_investment_amount20           IN number default null
   ,p_cce_ee_id21                   IN number default null
   ,p_cce_component21               IN varchar2 default null
   ,p_investment_amount21           IN number default null
   ,p_higher_education_loan         IN number default null
   ,p_donation_for_research         IN number default null
   ,p_claim_exemption_sec_80gg      IN varchar2 default null
   ,p_premium_amount                IN number default null
   ,p_premium_covers_sc             IN varchar2 default null
   ,p_treatment_amount              IN number default null
   ,p_treatment_covers_sc           IN varchar2 default null
   ,p_income_from_house_property    IN number default null
   ,p_profit_and_gain               IN number default null
   ,p_long_term_capital_gain        IN number default null
   ,p_short_term_capital_gain       IN number default null
   ,p_income_from_other_sources     IN number default null
   ,p_tds_paid                      IN number default null
   ,p_disease_entry_id1             IN number default null
   ,p_disability_type1              IN varchar2 default null
   ,p_disability_percentage1        IN varchar2 default null
   ,p_treatment_amount1             IN number default null
   ,p_disease_entry_id2             IN number default null
   ,p_disability_type2              IN varchar2 default null
   ,p_disability_percentage2        IN varchar2 default null
   ,p_treatment_amount2             IN number default null
   ,p_donation_entry_id1            IN number default null
   ,p_donation_type1                IN varchar2 default null
   ,p_donation_amount1              IN number default null
   ,p_donation_entry_id2            IN number default null
   ,p_donation_type2                IN varchar2 default null
   ,p_donation_amount2              IN number default null
   ,p_lic_entry_id1                 IN number default null
   ,p_premium_paid1                 IN number default null
   ,p_sum_assured1                  IN number default null
   ,p_lic_entry_id2                 IN number default null
   ,p_premium_paid2                 IN number default null
   ,p_sum_assured2                  IN number default null
   ,p_lic_entry_id3                 IN number default null
   ,p_premium_paid3                 IN number default null
   ,p_sum_assured3                  IN number default null
   ,p_lic_entry_id4                 IN number default null
   ,p_premium_paid4                 IN number default null
   ,p_sum_assured4                  IN number default null
   ,p_lic_entry_id5                 IN number default null
   ,p_premium_paid5                 IN number default null
   ,p_sum_assured5                  IN number default null
   ,p_comment_text                  IN varchar2 default NULL
   ,P_PERSON_ID                     IN number default null
   ,P_FULL_NAME                     IN varchar2 default NULL
   ,P_EMPLOYEE_NUMBER               IN varchar2 default NULL
   ,P_ASSIGNMENT_NUMBER             IN varchar2 default NULL
   ,P_DEPARTMENT                    IN varchar2 default NULL
   ,P_LAST_UPDATED_DATE             IN date default null
   ,P_ORGANIZATION_ID               IN number default null
   ,P_BUSINESS_GROUP_ID             IN number default null
   ,P_START_DATE                    IN date default null
   ,P_GRADE_ID                      IN number default null
   ,P_JOB_ID                        IN number default null
   ,P_POSITION_ID                   IN number default null
   ,P_TAX_AREA_NUMBER               IN varchar2 default NULL
   ,P_APPROVAL_STATUS               IN varchar2 default NULL
   ,P_TAX_YEAR			    IN varchar2 default NULL
   ,p_parent_premium                IN number default null
   ,p_parent_sc                     IN varchar2 default null
   ,p_isb_amount                    IN Number  default null
   ,p_policy_number2                IN Varchar2 default null
   ,p_policy_number3                IN Varchar2 default null
   ,p_policy_number4                IN Varchar2 default null
   ,p_policy_number5                IN Varchar2 default null
   ,p_vpf_amount                    IN number default null
   ,p_vpf_percent                   IN number default null
   ,p_policy_number1                IN Varchar2 default null

)
IS
   --
   l_effective_date DATE;
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   l_declare_warn BOOLEAN;
   l_warnings VARCHAR2(256);
   l_approved_flag VARCHAR2(10);
   l_count NUMBER;
   --
   -- Added as a part of bug fix for 4774108
   l_element_type_id NUMBER;
   l_element_link_id NUMBER;

   CURSOR csr_element_type_id(p_element_name VARCHAR2)
   IS
   SELECT element_type_id
   FROM   pay_element_types_f
   WHERE  legislation_code = 'IN'
   AND    element_name = p_element_name
   AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;

   CURSOR csr_number_of_entries
      (c_assignment_id IN per_assignments_f.assignment_id%TYPE
      ,c_element_name  IN pay_element_types_f.element_name%TYPE
      ,c_effective_date IN DATE
      ,c_element_link_id IN NUMBER)
   IS
   SELECT count(entries.element_entry_id)
     FROM per_assignments_f assgn
        , pay_element_links_f link
        , pay_element_types_f types
        , pay_element_entries_f entries
    WHERE assgn.assignment_id = c_assignment_id
      AND link.element_link_id = c_element_link_id
      AND (types.processing_type = 'R' OR assgn.payroll_id IS NOT NULL)
      AND link.business_group_id = assgn.business_group_id
      AND link.element_type_id = types.element_type_id
      AND types.element_name = c_element_name
      AND entries.element_type_id = types.element_type_id
      AND entries.element_link_id = link.element_link_id
      AND entries.assignment_id = assgn.assignment_id
      AND c_effective_date BETWEEN assgn.effective_start_date
                               AND assgn.effective_end_date
      AND c_effective_date BETWEEN link.effective_start_date
                               AND link.effective_end_date
      AND c_effective_date BETWEEN types.effective_start_date
                               AND types.effective_end_date
      AND c_effective_date BETWEEN entries.effective_start_date
                               AND entries.effective_end_date;




   PROCEDURE store_Disability
      (p_assignment_id          IN number
      ,p_effective_date         IN date     default null
      ,p_disease_entry_id       IN number   default null
      ,p_disability_type        IN varchar2 default null
      ,p_disability_percentage  IN varchar2 default null
      ,p_treatment_amount       IN number   default null)
   IS
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);

   BEGIN
     --
    l_procedure := g_package || 'store_Disability';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('Disease Entry ID: ', p_disease_entry_id);
      pay_in_utils.trace('Disability _type: ', p_disability_type);
      pay_in_utils.trace('Disability Percentage: ',p_disability_percentage);
      pay_in_utils.trace('Treatment Amount: ' , p_treatment_amount);
      pay_in_utils.trace('**************************************************','********************');
    END IF;

pay_in_utils.set_location(g_debug,'Entering Section80dd', 20);

     --
        declare_section80dd
           (p_assignment_id => p_assignment_id
           ,p_disability_type => p_disability_type
           ,p_disability_percentage => p_disability_percentage
           ,p_treatment_amount => p_treatment_amount
           ,p_effective_date => l_effective_date
           ,p_element_entry_id => p_disease_entry_id
           ,p_warnings => l_warnings);
         --
pay_in_utils.set_location(g_debug,'Leaving Section80dd', 20);

pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
     --
   END store_Disability;




   PROCEDURE store_Donation
      (p_assignment_id      IN number
      ,p_effective_date     IN date     default null
      ,p_donation_entry_id  IN number   default null
      ,p_donation_type      IN varchar2 default null
      ,p_donation_amount    IN number   default null)
   IS
   l_procedure   VARCHAR(100);

   BEGIN

    l_procedure := g_package || 'store_Donation';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('Donation Entry ID: ', p_donation_entry_id);
       pay_in_utils.trace('Donation Type: ', p_donation_type);
       pay_in_utils.trace('Donation Amount: ', p_donation_amount);
       pay_in_utils.trace('**************************************************','********************');
    END IF;

pay_in_utils.set_location(g_debug,'Entering store_Donation', 20);
     --
       declare_section80g
        (p_assignment_id => p_assignment_id
        ,p_donation_type => p_donation_type
        ,p_donation_amount => p_donation_amount
        ,p_effective_date => p_effective_date
        ,p_element_entry_id => p_donation_entry_id
        ,p_warnings => l_warnings);
       --
pay_in_utils.set_location(g_debug,'Leaving store_Donation', 20);

pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
     --
   END store_Donation;



   PROCEDURE store_LIC
      (p_assignment_id   IN number
      ,p_effective_date  IN date default null
      ,p_lic_entry_id    IN number default null
      ,p_premium_paid    IN number default null
      ,p_sum_assured     IN number default null
      ,p_policy_number   IN Varchar2 default null)
   IS
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);

   BEGIN

    l_procedure := g_package || 'store_LIC';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('LIC Entry ID: ' , p_lic_entry_id);
       pay_in_utils.trace('Premium Paid: ' , p_premium_paid);
       pay_in_utils.trace('Sum Assured: '  , p_sum_assured);
       pay_in_utils.trace('Policy Number: ', p_policy_number);
      pay_in_utils.trace('**************************************************','********************');
    END IF;
     --
       pay_in_utils.set_location(g_debug,'Entering store_LIC', 20);

       declare_life_insurance_premium
         (p_assignment_id => p_assignment_id
         ,p_premium_paid => p_premium_paid
         ,p_sum_assured => p_sum_assured
         ,p_effective_date => p_effective_date
         ,p_element_entry_id => p_lic_entry_id
         ,p_policy_number => p_policy_number
         ,p_warnings => l_warnings);
     --
     pay_in_utils.set_location(g_debug,'Leaving store_LIC', 30);

     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

     --
   END store_LIC;



   PROCEDURE raise_message
      (p_token1       IN VARCHAR2
      ,p_token2       IN VARCHAR2)
   IS
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   BEGIN

    l_procedure := g_package || 'raise_message';
     pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

      IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('p_token1 : ' , p_token1);
         pay_in_utils.trace('p_token2 : ' , p_token2);
         pay_in_utils.trace('**************************************************','********************');
      END IF;

       IF (INSTR(p_token1,'PER_IN_INVESTMENT_80CCE')= 1)
       THEN
         hr_utility.set_message(800, 'PER_IN_INVESTMENT_80CCE');
         hr_utility.set_message_token('FROM', SUBSTR(p_token1,LENGTH('PER_IN_INVESTMENT_80CCE') + 1));
         hr_utility.set_message_token('TO', p_token2);
         hr_utility.raise_error;
      END IF;

    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

   END raise_message;



   --
BEGIN


    l_procedure := g_package || 'web_adi_declare_tax';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


   IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id ',p_assignment_id);
      pay_in_utils.trace('p_effective_date ',p_effective_date);
      pay_in_utils.trace ('p_apr                          ',p_april);
      pay_in_utils.trace ('p_may                          ',p_may);
      pay_in_utils.trace ('p_jun                          ',p_june);
      pay_in_utils.trace ('p_jul                          ',p_july);
      pay_in_utils.trace ('p_aug                          ',p_august);
      pay_in_utils.trace ('p_sep                          ',p_september);
      pay_in_utils.trace ('p_oct                          ',p_october);
      pay_in_utils.trace ('p_nov                          ',p_november);
      pay_in_utils.trace ('p_dec                          ',p_december);
      pay_in_utils.trace ('p_jan                          ',p_january);
      pay_in_utils.trace ('p_feb                          ',p_february);
      pay_in_utils.trace ('p_mar                          ',p_march);
      pay_in_utils.trace('p_cce_ee_id1                    ',p_cce_ee_id1);
      pay_in_utils.trace('p_cce_component1                ',p_cce_component1);
      pay_in_utils.trace('p_investment_amount1            ',p_investment_amount1);
      pay_in_utils.trace('p_cce_ee_id2                    ',p_cce_ee_id2);
      pay_in_utils.trace('p_cce_component2                ',p_cce_component2);
      pay_in_utils.trace('p_investment_amount2            ',p_investment_amount2);
      pay_in_utils.trace('p_cce_ee_id3                    ',p_cce_ee_id3);
      pay_in_utils.trace('p_cce_component3                ',p_cce_component3);
      pay_in_utils.trace('p_investment_amount3            ',p_investment_amount3);
      pay_in_utils.trace('p_cce_ee_id4                    ',p_cce_ee_id4);
      pay_in_utils.trace('p_cce_component4                ',p_cce_component4);
      pay_in_utils.trace('p_investment_amount4            ',p_investment_amount4);
      pay_in_utils.trace('p_cce_ee_id5                    ',p_cce_ee_id5);
      pay_in_utils.trace('p_cce_component5                ',p_cce_component5);
      pay_in_utils.trace('p_investment_amount5            ',p_investment_amount6);
      pay_in_utils.trace('p_cce_ee_id6                    ',p_cce_ee_id6);
      pay_in_utils.trace('p_cce_component6                ',p_cce_component6);
      pay_in_utils.trace('p_investment_amount6            ',p_investment_amount6);
      pay_in_utils.trace('p_cce_ee_id7                    ',p_cce_ee_id7);
      pay_in_utils.trace('p_cce_component7                ',p_cce_component7);
      pay_in_utils.trace('p_investment_amount7            ',p_investment_amount7);
      pay_in_utils.trace('p_cce_ee_id8                    ',p_cce_ee_id8);
      pay_in_utils.trace('p_cce_component8                ',p_cce_component8);
      pay_in_utils.trace('p_investment_amount8            ',p_investment_amount8);
      pay_in_utils.trace('p_cce_ee_id9                    ',p_cce_ee_id9);
      pay_in_utils.trace('p_cce_component9                ',p_cce_component9);
      pay_in_utils.trace('p_investment_amount9            ',p_investment_amount9);
      pay_in_utils.trace('p_cce_ee_id10                    ',p_cce_ee_id10);
      pay_in_utils.trace('p_cce_component10                ',p_cce_component10);
      pay_in_utils.trace('p_investment_amount10            ',p_investment_amount10);
      pay_in_utils.trace('p_cce_ee_id11                    ',p_cce_ee_id11);
      pay_in_utils.trace('p_cce_component11                ',p_cce_component11);
      pay_in_utils.trace('p_investment_amount11            ',p_investment_amount11);
      pay_in_utils.trace('p_cce_ee_id12                    ',p_cce_ee_id12);
      pay_in_utils.trace('p_cce_component12                ',p_cce_component12);
      pay_in_utils.trace('p_investment_amount12            ',p_investment_amount12);
      pay_in_utils.trace('p_cce_ee_id13                    ',p_cce_ee_id13);
      pay_in_utils.trace('p_cce_component13                ',p_cce_component13);
      pay_in_utils.trace('p_investment_amount13            ',p_investment_amount13);
      pay_in_utils.trace('p_cce_ee_id14                    ',p_cce_ee_id14);
      pay_in_utils.trace('p_cce_component14                ',p_cce_component14);
      pay_in_utils.trace('p_investment_amount14            ',p_investment_amount14);
      pay_in_utils.trace('p_cce_ee_id15                    ',p_cce_ee_id15);
      pay_in_utils.trace('p_cce_component15                ',p_cce_component15);
      pay_in_utils.trace('p_investment_amount15            ',p_investment_amount15);
      pay_in_utils.trace('p_cce_ee_id16                    ',p_cce_ee_id16);
      pay_in_utils.trace('p_cce_component16                ',p_cce_component16);
      pay_in_utils.trace('p_investment_amount16            ',p_investment_amount16);
      pay_in_utils.trace('p_cce_ee_id17                    ',p_cce_ee_id17);
      pay_in_utils.trace('p_cce_component17                ',p_cce_component17);
      pay_in_utils.trace('p_investment_amount17            ',p_investment_amount17);
      pay_in_utils.trace('p_cce_ee_id18                    ',p_cce_ee_id18);
      pay_in_utils.trace('p_cce_component18                ',p_cce_component18);
      pay_in_utils.trace('p_investment_amount18            ',p_investment_amount18);
      pay_in_utils.trace('p_cce_ee_id19                    ',p_cce_ee_id19);
      pay_in_utils.trace('p_cce_component19                ',p_cce_component19);
      pay_in_utils.trace('p_investment_amount19            ',p_investment_amount19);
      pay_in_utils.trace('p_cce_ee_id20                    ',p_cce_ee_id20);
      pay_in_utils.trace('p_cce_component20                ',p_cce_component20);
      pay_in_utils.trace('p_investment_amount20            ',p_investment_amount20);
      pay_in_utils.trace('p_cce_ee_id21                    ',p_cce_ee_id21);
      pay_in_utils.trace('p_cce_component21                ',p_cce_component21);
      pay_in_utils.trace('p_investment_amount21            ',p_investment_amount21);
      pay_in_utils.trace('p_higher_education_loan         ',p_higher_education_loan);
      pay_in_utils.trace('p_donation_for_research         ',p_donation_for_research);
      pay_in_utils.trace('p_claim_exemption_sec_80gg      ',p_claim_exemption_sec_80gg);
      pay_in_utils.trace('p_premium_amount                ',p_premium_amount);
      pay_in_utils.trace('p_premium_covers_sc             ',p_premium_covers_sc);
      pay_in_utils.trace('p_treatment_amount              ',p_treatment_amount);
      pay_in_utils.trace('p_treatment_covers_sc           ',p_treatment_covers_sc);
      pay_in_utils.trace('p_income_from_house_property    ',p_income_from_house_property);
      pay_in_utils.trace('p_profit_and_gain               ',p_profit_and_gain);
      pay_in_utils.trace('p_long_term_capital_gain        ',p_long_term_capital_gain);
      pay_in_utils.trace('p_short_term_capital_gain       ',p_short_term_capital_gain);
      pay_in_utils.trace('p_income_from_other_sources     ',p_income_from_other_sources);
      pay_in_utils.trace('p_tds_paid                      ',p_tds_paid);
      pay_in_utils.trace('p_disease_entry_id1             ',p_disease_entry_id1);
      pay_in_utils.trace('p_disability_type1              ',p_disability_type1);
      pay_in_utils.trace('p_disability_percentage1        ',p_disability_percentage1);
      pay_in_utils.trace('p_treatment_amount1             ',p_treatment_amount1);
      pay_in_utils.trace('p_disease_entry_id2             ',p_disease_entry_id2);
      pay_in_utils.trace('p_disability_type2              ',p_disability_type2);
      pay_in_utils.trace('p_disability_percentage2        ',p_disability_percentage2 );
      pay_in_utils.trace('p_treatment_amount2             ',p_treatment_amount2);
      pay_in_utils.trace('p_donation_entry_id1            ',p_donation_entry_id1);
      pay_in_utils.trace('p_donation_type1                ',p_donation_type1);
      pay_in_utils.trace('p_donation_amount1              ',p_donation_amount1);
      pay_in_utils.trace('p_donation_entry_id2            ',p_donation_amount1);
      pay_in_utils.trace('p_donation_type2                ',p_donation_type2);
      pay_in_utils.trace('p_donation_amount2              ',p_donation_amount2);
      pay_in_utils.trace('p_lic_entry_id1                 ',p_lic_entry_id1);
      pay_in_utils.trace('p_premium_paid1                 ',p_premium_paid1);
      pay_in_utils.trace('p_sum_assured1                  ',p_sum_assured1);
      pay_in_utils.trace('p_policy_number1                ',p_policy_number1);
      pay_in_utils.trace('p_lic_entry_id2                 ',p_lic_entry_id2);
      pay_in_utils.trace('p_premium_paid2                 ',p_premium_paid2);
      pay_in_utils.trace('p_sum_assured2                  ',p_sum_assured2);
      pay_in_utils.trace('p_policy_number2                ',p_policy_number2);
      pay_in_utils.trace('p_lic_entry_id3                 ',p_lic_entry_id3);
      pay_in_utils.trace('p_premium_paid3                 ',p_premium_paid3);
      pay_in_utils.trace('p_sum_assured3                  ',p_sum_assured3);
      pay_in_utils.trace('p_policy_number3                ',p_policy_number3);
      pay_in_utils.trace('p_lic_entry_id4                 ',p_lic_entry_id4);
      pay_in_utils.trace('p_premium_paid4                 ',p_premium_paid4);
      pay_in_utils.trace('p_sum_assured4                  ',p_sum_assured4);
      pay_in_utils.trace('p_policy_number4                ',p_policy_number4);
      pay_in_utils.trace('p_lic_entry_id5                 ',p_lic_entry_id5);
      pay_in_utils.trace('p_premium_paid5                 ',p_premium_paid5);
      pay_in_utils.trace('p_sum_assured5                  ',p_sum_assured5);
      pay_in_utils.trace('p_policy_number5                ',p_policy_number5);
      pay_in_utils.trace('p_comment_text                  ',p_comment_text);
      pay_in_utils.trace('p_vpf_amount                    ',p_vpf_amount);
      pay_in_utils.trace('p_vpf_percent                   ',p_vpf_percent);
      pay_in_utils.trace('**************************************************','********************');
   END IF ;

   l_declare_warn := false;
   l_approved_flag := 'Y';
   --
   --
   l_effective_date := pay_in_utils.get_effective_date(p_effective_date);
   --
   declare_house_rent
         (p_assignment_id  => p_assignment_id
         ,p_effective_date => l_effective_date
         ,p_apr            => p_april
         ,p_may            => p_may
         ,p_jun            => p_june
         ,p_jul            => p_july
         ,p_aug            => p_august
         ,p_sep            => p_september
         ,p_oct            => p_october
         ,p_nov            => p_november
         ,p_dec            => p_december
         ,p_jan            => p_january
         ,p_feb            => p_february
         ,p_mar            => p_march
         ,p_warnings       => l_declare_warn);
    --
    pay_in_utils.set_location(g_debug, l_procedure, 20);
    --
/*    declare_chapter6a
       (p_assignment_id                   => p_assignment_id
       ,p_effective_date                  => l_effective_date
       ,p_pension_fund_80ccc              => p_pension_fund
       ,p_medical_insurance_prem_80d      => p_premium_amount
       ,p_sec_80ddb_senior_citizen        => p_premium_covers_sc
       ,p_disease_treatment_80ddb         => p_treatment_amount
       ,p_sec_80d_senior_citizen          => p_treatment_covers_sc
       ,p_higher_education_loan_80e       => p_higher_education_loan
       ,p_claim_exemp_under_sec_80gg      => p_claim_exemption_sec_80gg
       ,p_donation_for_research_80gga     => p_donation_for_research
       ,p_int_on_gen_investment_80L       => p_general_investments
       ,p_int_on_securities_80L           => p_securities
       ,p_warnings                        => l_declare_warn);

    --
    pay_in_utils.set_location(g_debug, l_procedure, 30);
    --
    declare_section88
       (p_assignment_id                  => p_assignment_id
       ,p_effective_date                 => l_effective_date
       ,p_deferred_annuity               => p_deferred_annuity
       ,p_public_provident_fund          => p_public_provident_fund
       ,p_post_office_savings_scheme     => p_post_office_savings
       ,p_deposit_in_nsc_vi_issue        => p_nsc_6_Issue
       ,p_deposit_in_nsc_viii_issue      => p_nsc_8_Issue
       ,p_interest_on_nsc_reinvested     => p_interest_on_nsc
       ,p_house_loan_repayment           => p_housing_loan_principal
       ,p_notified_mutual_fund_or_uti    => p_notified_mutual_fund
       ,p_national_housing_bank_scheme   => p_national_housing_bank
       ,p_unit_linked_insurance_plan     => p_unit_linked_insurance
       ,p_notified_annuity_plan          => p_notified_annuity_plan
       ,p_notified_pension_fund          => p_notified_pension_fund
       ,p_public_sector_company_scheme   => p_public_sector_company
       ,p_approved_superannuation_fund   => p_approved_superannuation
       ,p_infrastructure_bond            => p_infrastructure_bonds
       ,p_warnings                       => l_declare_warn);
    --

    pay_in_utils.set_location(g_debug, l_procedure, 40);
    --
    declare_tuition_fee
       (p_assignment_id           => p_assignment_id
       ,p_effective_date          => l_effective_date
       ,p_tuition_fee_for_child_1 => p_tuition_fee_for_first_child
       ,p_tuition_fee_for_child_2 => p_tuition_fee_for_second_child
       ,p_warnings                => l_declare_warn);
    --
    pay_in_utils.set_location(g_debug, l_procedure, 50);
    */
    --
    declare_other_income
       (p_assignment_id                 => p_assignment_id
       ,p_effective_date                => l_effective_date
       ,p_income_from_house_property    => p_income_from_house_property
       ,p_profit_and_gain_from_busines  => p_profit_and_gain
       ,p_long_term_capital_gain        => p_long_term_capital_gain
       ,p_short_term_capital_gain       => p_short_term_capital_gain
       ,p_income_from_any_other_source  => p_income_from_other_sources
       ,p_tds_paid_on_other_income      => p_tds_paid
       ,p_warnings                      => l_declare_warn);
    --
    pay_in_utils.set_location(g_debug, l_procedure, 60);
    --

    declare_section80e
          (p_assignment_id              => p_assignment_id
	  ,p_effective_date             => l_effective_date
          ,p_higher_education_loan_80e  => p_higher_education_loan
          ,p_warnings                   => l_declare_warn);


    --
    pay_in_utils.set_location(g_debug, l_procedure, 70);
    --

          declare_section80ccf
          (p_assignment_id              => p_assignment_id
	  ,p_effective_date             => l_effective_date
          ,p_infrastructure_bonds_80ccf  => p_isb_amount
          ,p_warnings                   => l_declare_warn);


    --
    pay_in_utils.set_location(g_debug, l_procedure, 75);

    declare_section80gga
          (p_assignment_id               => p_assignment_id
	  ,p_effective_date              => l_effective_date
          ,p_donation_for_research_80gga => p_donation_for_research
          ,p_warnings                    => l_declare_warn);

    --
    pay_in_utils.set_location(g_debug, l_procedure, 80);
    --
    declare_section80gg
          (p_assignment_id              => p_assignment_id
	  ,p_effective_date             => l_effective_date
          ,p_claim_exemp_under_sec_80gg => p_claim_exemption_sec_80gg
          ,p_warnings                   => l_declare_warn);
    --
    pay_in_utils.set_location(g_debug, l_procedure, 90);
    --
    declare_section80d
          (p_assignment_id               => p_assignment_id
	  ,p_effective_date              => l_effective_date
          ,p_medical_insurance_prem_80d  => p_premium_amount
	  ,p_sec_80d_senior_citizen      => p_premium_covers_sc
	  ,p_med_par_insurance_prem_80d  => p_parent_premium
	  ,p_sec_80d_par_senior_citizen  => p_parent_sc
          ,p_warnings                    => l_declare_warn);
    --
    pay_in_utils.set_location(g_debug, l_procedure, 100);
    --
    declare_section80ddb
          (p_assignment_id               => p_assignment_id
	  ,p_effective_date              => l_effective_date
          ,p_disease_treatment_80ddb     => p_treatment_amount
	  ,p_sec_80ddb_senior_citizen    => p_treatment_covers_sc
          ,p_warnings                    => l_declare_warn);
    --
    pay_in_utils.set_location(g_debug, l_procedure, 110);
    --
    declare_vpf
          (p_assignment_id              => p_assignment_id
           ,p_effective_date            => l_effective_date
           ,p_ee_vol_pf_amount          => p_vpf_amount
           ,p_ee_vol_pf_percent         => p_vpf_percent
           ,p_warnings                  => l_declare_warn);

    --
    pay_in_utils.set_location(g_debug, l_procedure, 120);
    --
    store_Disability(p_assignment_id, l_effective_date, p_disease_entry_id1, p_disability_type1, p_disability_percentage1, p_treatment_amount1);
    store_Disability(p_assignment_id, l_effective_date, p_disease_entry_id2, p_disability_type2, p_disability_percentage2, p_treatment_amount2);

    --
    pay_in_utils.set_location(g_debug, l_procedure, 130);
    --
    store_Donation(p_assignment_id, l_effective_date, p_donation_entry_id1, p_donation_type1, p_donation_amount1);
    store_Donation(p_assignment_id, l_effective_date, p_donation_entry_id2, p_donation_type2, p_donation_amount2);
    --
    pay_in_utils.set_location(g_debug, l_procedure, 140);
    --

    store_LIC(p_assignment_id, l_effective_date, p_lic_entry_id1, p_premium_paid1, p_sum_assured1, p_policy_number1);
    store_LIC(p_assignment_id, l_effective_date, p_lic_entry_id2, p_premium_paid2, p_sum_assured2, p_policy_number2);
    store_LIC(p_assignment_id, l_effective_date, p_lic_entry_id3, p_premium_paid3, p_sum_assured3, p_policy_number3);
    store_LIC(p_assignment_id, l_effective_date, p_lic_entry_id4, p_premium_paid4, p_sum_assured4, p_policy_number4);
    store_LIC(p_assignment_id, l_effective_date, p_lic_entry_id5, p_premium_paid5, p_sum_assured5, p_policy_number5);
    --
    pay_in_utils.set_location(g_debug, l_procedure, 150);
    --
    declare_section80cce(p_assignment_id, p_cce_component1, p_investment_amount1, p_effective_date, p_cce_ee_id1, l_warnings);
    raise_message(l_warnings,p_cce_component1);
    declare_section80cce(p_assignment_id, p_cce_component2, p_investment_amount2, p_effective_date, p_cce_ee_id2, l_warnings);
    raise_message(l_warnings,p_cce_component2);
    declare_section80cce(p_assignment_id, p_cce_component3, p_investment_amount3, p_effective_date, p_cce_ee_id3, l_warnings);
    raise_message(l_warnings,p_cce_component3);
    declare_section80cce(p_assignment_id, p_cce_component4, p_investment_amount4, p_effective_date, p_cce_ee_id4, l_warnings);
    raise_message(l_warnings,p_cce_component4);
    declare_section80cce(p_assignment_id, p_cce_component5, p_investment_amount5, p_effective_date, p_cce_ee_id5, l_warnings);
    raise_message(l_warnings,p_cce_component5);
    declare_section80cce(p_assignment_id, p_cce_component6, p_investment_amount6, p_effective_date, p_cce_ee_id6, l_warnings);
    raise_message(l_warnings,p_cce_component6);
    declare_section80cce(p_assignment_id, p_cce_component7, p_investment_amount7, p_effective_date, p_cce_ee_id7, l_warnings);
    raise_message(l_warnings,p_cce_component7);
    declare_section80cce(p_assignment_id, p_cce_component8, p_investment_amount8, p_effective_date, p_cce_ee_id8, l_warnings);
    raise_message(l_warnings,p_cce_component8);
    declare_section80cce(p_assignment_id, p_cce_component9, p_investment_amount9, p_effective_date, p_cce_ee_id9, l_warnings);
    raise_message(l_warnings,p_cce_component9);
    declare_section80cce(p_assignment_id, p_cce_component10, p_investment_amount10, p_effective_date, p_cce_ee_id10, l_warnings);
    raise_message(l_warnings,p_cce_component10);
    declare_section80cce(p_assignment_id, p_cce_component11, p_investment_amount11, p_effective_date, p_cce_ee_id11, l_warnings);
    raise_message(l_warnings,p_cce_component11);
    declare_section80cce(p_assignment_id, p_cce_component12, p_investment_amount12, p_effective_date, p_cce_ee_id12, l_warnings);
    raise_message(l_warnings,p_cce_component12);
    declare_section80cce(p_assignment_id, p_cce_component13, p_investment_amount13, p_effective_date, p_cce_ee_id13, l_warnings);
    raise_message(l_warnings,p_cce_component13);
    declare_section80cce(p_assignment_id, p_cce_component14, p_investment_amount14, p_effective_date, p_cce_ee_id14, l_warnings);
    raise_message(l_warnings,p_cce_component14);
    declare_section80cce(p_assignment_id, p_cce_component15, p_investment_amount15, p_effective_date, p_cce_ee_id15, l_warnings);
    raise_message(l_warnings,p_cce_component15);
    declare_section80cce(p_assignment_id, p_cce_component16, p_investment_amount16, p_effective_date, p_cce_ee_id16, l_warnings);
    raise_message(l_warnings,p_cce_component16);
    declare_section80cce(p_assignment_id, p_cce_component17, p_investment_amount17, p_effective_date, p_cce_ee_id17, l_warnings);
    raise_message(l_warnings,p_cce_component17);
    declare_section80cce(p_assignment_id, p_cce_component18, p_investment_amount18, p_effective_date, p_cce_ee_id18, l_warnings);
    raise_message(l_warnings,p_cce_component18);
    declare_section80cce(p_assignment_id, p_cce_component19, p_investment_amount19, p_effective_date, p_cce_ee_id19, l_warnings);
    raise_message(l_warnings,p_cce_component19);
    declare_section80cce(p_assignment_id, p_cce_component20, p_investment_amount20, p_effective_date, p_cce_ee_id20, l_warnings);
    raise_message(l_warnings,p_cce_component20);
    declare_section80cce(p_assignment_id, p_cce_component21, p_investment_amount21, p_effective_date, p_cce_ee_id21, l_warnings);
    raise_message(l_warnings,p_cce_component21);

    l_count := 0;
    -- Added as a part of bug fix 4774108
    OPEN  csr_element_type_id('Deduction under Section 80DD');
    FETCH csr_element_type_id INTO l_element_type_id;
    CLOSE csr_element_type_id;

    l_element_link_id := pay_in_utils.get_element_link_id(p_assignment_id
                                                         ,l_effective_date
                                                         ,l_element_type_id
                                                         );

    OPEN csr_number_of_entries(p_assignment_id, 'Deduction under Section 80DD', l_effective_date,l_element_link_id);
    FETCH csr_number_of_entries INTO l_count;
    CLOSE csr_number_of_entries;
    --
    IF l_count > 2 THEN
      --
      l_approved_flag := 'N';
      --
    END IF;
    --
    pay_in_utils.set_location(g_debug, l_procedure, 160);
    --
    -- Added as a part of bug fix 4774108
    OPEN  csr_element_type_id('Deduction under Section 80G');
    FETCH csr_element_type_id INTO l_element_type_id;
    CLOSE csr_element_type_id;

    l_element_link_id := pay_in_utils.get_element_link_id(p_assignment_id
                                                         ,l_effective_date
                                                         ,l_element_type_id
                                                         );

    l_count := 0;
    OPEN csr_number_of_entries(p_assignment_id, 'Deduction under Section 80G',l_effective_date,l_element_link_id);
    FETCH csr_number_of_entries INTO l_count;
    CLOSE csr_number_of_entries;
    --
    IF l_count > 2 THEN
      --
      l_approved_flag := 'N';
      --
    END IF;
    --
    pay_in_utils.set_location(g_debug, l_procedure, 170);
    --
    l_count := 0;
    -- Added as a part of bug fix 4774108
    OPEN  csr_element_type_id('Life Insurance Premium');
    FETCH csr_element_type_id INTO l_element_type_id;
    CLOSE csr_element_type_id;

    l_element_link_id := pay_in_utils.get_element_link_id(p_assignment_id
                                                         ,l_effective_date
                                                         ,l_element_type_id
                                                         );

    OPEN csr_number_of_entries(p_assignment_id, 'Life Insurance Premium', l_effective_date,l_element_link_id);
    FETCH csr_number_of_entries INTO l_count;
    CLOSE csr_number_of_entries;
    --
    IF l_count > 5 THEN
      --
      l_approved_flag := 'N';
      --
    END IF;
    --
    pay_in_utils.set_location(g_debug, l_procedure, 180);
    --
    -- Added as a part of bug fix 4774108
    OPEN  csr_element_type_id('Deduction under Section 80CCE');
    FETCH csr_element_type_id INTO l_element_type_id;
    CLOSE csr_element_type_id;

    l_element_link_id := pay_in_utils.get_element_link_id(p_assignment_id
                                                         ,l_effective_date
                                                         ,l_element_type_id
                                                         );

    l_count := 0;
    OPEN csr_number_of_entries(p_assignment_id,'Deduction under Section 80CCE',l_effective_date,l_element_link_id);
    FETCH csr_number_of_entries INTO l_count;
    CLOSE csr_number_of_entries;
    --
    IF l_count > 19 THEN
      --
      l_approved_flag := 'N';
      --
    END IF;
    --
    pay_in_utils.set_location(g_debug, l_procedure, 190);

    -- Added as a part of bug fix 4774108
    OPEN  csr_element_type_id('Pension Fund 80CCC');
    FETCH csr_element_type_id INTO l_element_type_id;
    CLOSE csr_element_type_id;

    l_element_link_id := pay_in_utils.get_element_link_id(p_assignment_id
                                                         ,l_effective_date
                                                         ,l_element_type_id
                                                         );

    l_count := 0;
    OPEN csr_number_of_entries(p_assignment_id, 'Pension Fund 80CCC', l_effective_date,l_element_link_id);
    FETCH csr_number_of_entries INTO l_count;
    CLOSE csr_number_of_entries;
    --
    IF l_count > 1 THEN
      --
      l_approved_flag := 'N';
      --
    END IF;
    --
    pay_in_utils.set_location(g_debug, l_procedure, 200);

    l_count := 0;
    -- Added as a part of bug fix 4774108
    OPEN  csr_element_type_id('Deferred Annuity');
    FETCH csr_element_type_id INTO l_element_type_id;
    CLOSE csr_element_type_id;

    l_element_link_id := pay_in_utils.get_element_link_id(p_assignment_id
                                                         ,l_effective_date
                                                         ,l_element_type_id
                                                         );

    OPEN csr_number_of_entries(p_assignment_id, 'Deferred Annuity', l_effective_date,l_element_link_id);
    FETCH csr_number_of_entries INTO l_count;
    CLOSE csr_number_of_entries;
    --
    IF l_count > 1 THEN
      --
      l_approved_flag := 'N';
      --
    END IF;

    l_count := 0;
    OPEN  csr_element_type_id('Senior Citizens Savings Scheme');
    FETCH csr_element_type_id INTO l_element_type_id;
    CLOSE csr_element_type_id;

    l_element_link_id := pay_in_utils.get_element_link_id(p_assignment_id
                                                         ,l_effective_date
                                                         ,l_element_type_id
                                                         );

    OPEN csr_number_of_entries(p_assignment_id, 'Senior Citizens Savings Scheme', l_effective_date,l_element_link_id);
    FETCH csr_number_of_entries INTO l_count;
    CLOSE csr_number_of_entries;
    --
    IF l_count > 1 THEN
      --
      l_approved_flag := 'N';
      --
    END IF;
    --
    pay_in_utils.set_location(g_debug, l_procedure, 210);
    --
    approve_declaration
      (p_assignment_id  => p_assignment_id
      ,p_approval_flag  => l_approved_flag
      ,p_effective_date => l_effective_date
      ,p_comment_text   => p_comment_text);
    --
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,220);

END web_adi_declare_tax;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_VALUE                                           --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for getting values     --
--                  of the input values in case of multiple element     --
--                  of an element in tax declaration                    --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id  NUMBER                             --
--                  p_index          NUMBER                             --
--                  p_element_name   VARCHAR2                           --
--                  p_input_name     VARCHAR2                           --
--                  p_effective_date DATE                               --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.1  20-Jun-2005  abhjain     Added changes after stat update        --
--------------------------------------------------------------------------
FUNCTION get_value
        (p_assignment_id   IN    number
        ,p_index           IN    number
        ,p_element_name    IN    varchar2
        ,p_input_name      IN    varchar2
        ,p_effective_date  IN    date
        )
RETURN VARCHAR2
IS
   --
   CURSOR csr_get_80dd_values(p_element_link_id NUMBER)
   IS
   SELECT entries.element_entry_id entry_id
        , value1.screen_entry_value Disability_Type
        , value2.screen_entry_value Treatment_Amount
        , value3.screen_entry_value Disability_Percentage
     FROM per_assignments_f assgn
        , pay_element_links_f link
        , pay_element_types_f types
        , pay_element_entries_f entries
        , pay_element_entry_values_f value1
        , pay_input_values_f inputs1
        , pay_element_entry_values_f value2
        , pay_input_values_f inputs2
        , pay_element_entry_values_f value3
        , pay_input_values_f inputs3
    WHERE assgn.assignment_id = p_assignment_id
      AND link.element_link_id = p_element_link_id-- Changed for bug 4774108
      AND (types.processing_type = 'R' OR assgn.payroll_id IS NOT NULL)
      AND link.business_group_id = assgn.business_group_id
      AND link.element_type_id = types.element_type_id
      AND types.element_name = 'Deduction under Section 80DD'
      AND entries.element_type_id = types.element_type_id
      AND entries.element_link_id = link.element_link_id
      AND entries.assignment_id = assgn.assignment_id
      AND value1.element_entry_id =  entries.element_entry_id
      AND inputs1.input_value_id = value1.input_value_id
      AND inputs1.element_type_id = types.element_type_id
      AND inputs1.name = 'Disability Type'
      AND value2.element_entry_id =  entries.element_entry_id
      AND inputs2.input_value_id = value2.input_value_id
      AND inputs2.element_type_id = types.element_type_id
      AND inputs2.name = 'Treatment Amount'
      AND value3.element_entry_id =  entries.element_entry_id
      AND inputs3.input_value_id = value3.input_value_id
      AND inputs3.element_type_id = types.element_type_id
      AND inputs3.name = 'Disability Percentage'
      AND p_effective_date BETWEEN assgn.effective_start_date
                               AND assgn.effective_end_date
      AND p_effective_date BETWEEN link.effective_start_date
                               AND link.effective_end_date
      AND p_effective_date BETWEEN types.effective_start_date
                               AND types.effective_end_date
      AND p_effective_date BETWEEN entries.effective_start_date
                               AND entries.effective_end_date
      AND p_effective_date BETWEEN inputs1.effective_start_date
                               AND inputs1.effective_end_date
      AND p_effective_date BETWEEN value1.effective_start_date
                               AND value1.effective_end_date
      AND p_effective_date BETWEEN inputs2.effective_start_date
                               AND inputs2.effective_end_date
      AND p_effective_date BETWEEN value2.effective_start_date
                               AND value2.effective_end_date
      AND p_effective_date BETWEEN inputs3.effective_start_date
                               AND inputs3.effective_end_date
      AND p_effective_date BETWEEN value3.effective_start_date
                               AND value3.effective_end_date;
   --
   CURSOR csr_get_80g_values(p_element_link_id NUMBER)
   IS
   SELECT entries.element_entry_id entry_id
        , value1.screen_entry_value Donation_Type
        , value2.screen_entry_value Donation_Amount
     FROM per_assignments_f assgn
        , pay_element_links_f link
        , pay_element_types_f types
        , pay_element_entries_f entries
        , pay_element_entry_values_f value1
        , pay_input_values_f inputs1
        , pay_element_entry_values_f value2
        , pay_input_values_f inputs2
    WHERE assgn.assignment_id = p_assignment_id
      AND link.element_link_id = p_element_link_id
      AND (types.processing_type = 'R' OR assgn.payroll_id IS NOT NULL)
      AND link.business_group_id = assgn.business_group_id
      AND link.element_type_id = types.element_type_id
      AND types.element_name = 'Deduction under Section 80G'
      AND entries.element_type_id = types.element_type_id
      AND entries.element_link_id = link.element_link_id
      AND entries.assignment_id = assgn.assignment_id
      AND value1.element_entry_id =  entries.element_entry_id
      AND inputs1.input_value_id = value1.input_value_id
      AND inputs1.element_type_id = types.element_type_id
      AND inputs1.name = 'Donation Type'
      AND value2.element_entry_id =  entries.element_entry_id
      AND inputs2.input_value_id = value2.input_value_id
      AND inputs2.element_type_id = types.element_type_id
      AND inputs2.name = 'Donation Amount'
      AND p_effective_date BETWEEN assgn.effective_start_date
                               AND assgn.effective_end_date
      AND p_effective_date BETWEEN link.effective_start_date
                               AND link.effective_end_date
      AND p_effective_date BETWEEN types.effective_start_date
                               AND types.effective_end_date
      AND p_effective_date BETWEEN entries.effective_start_date
                               AND entries.effective_end_date
      AND p_effective_date BETWEEN inputs1.effective_start_date
                               AND inputs1.effective_end_date
      AND p_effective_date BETWEEN value1.effective_start_date
                               AND value1.effective_end_date
      AND p_effective_date BETWEEN inputs2.effective_start_date
                               AND inputs2.effective_end_date
      AND p_effective_date BETWEEN value2.effective_start_date
                               AND value2.effective_end_date;
   --
   CURSOR csr_get_insurace_values(p_element_link_id     NUMBER)
   IS
   SELECT entries.element_entry_id entry_id
        , value1.screen_entry_value Premium_Paid
        , value2.screen_entry_value Sum_Assured
	, value3.screen_entry_value Policy_Number
     FROM per_assignments_f assgn
        , pay_element_links_f link
        , pay_element_types_f types
        , pay_element_entries_f entries
        , pay_element_entry_values_f value1
        , pay_input_values_f inputs1
        , pay_element_entry_values_f value2
        , pay_input_values_f inputs2
        , pay_element_entry_values_f value3
        , pay_input_values_f inputs3
    WHERE assgn.assignment_id = p_assignment_id
      AND link.element_link_id = p_element_link_id
      AND (types.processing_type = 'R' OR assgn.payroll_id IS NOT NULL)
      AND link.business_group_id = assgn.business_group_id
      AND link.element_type_id = types.element_type_id
      AND types.element_name = 'Life Insurance Premium'
      AND entries.element_type_id = types.element_type_id
      AND entries.element_link_id = link.element_link_id
      AND entries.assignment_id = assgn.assignment_id
      AND value1.element_entry_id =  entries.element_entry_id
      AND inputs1.input_value_id = value1.input_value_id
      AND inputs1.element_type_id = types.element_type_id
      AND inputs1.name = 'Premium Paid'
      AND value2.element_entry_id =  entries.element_entry_id
      AND inputs2.input_value_id = value2.input_value_id
      AND inputs2.element_type_id = types.element_type_id
      AND inputs2.name = 'Sum Assured'
      AND value3.element_entry_id = entries.element_entry_id
      AND inputs3.input_value_id = value3.input_value_id
      AND inputs3.element_type_id = types.element_type_id
      AND inputs3.name = 'Policy Number'
      AND p_effective_date BETWEEN assgn.effective_start_date
                               AND assgn.effective_end_date
      AND p_effective_date BETWEEN link.effective_start_date
                               AND link.effective_end_date
      AND p_effective_date BETWEEN types.effective_start_date
                               AND types.effective_end_date
      AND p_effective_date BETWEEN entries.effective_start_date
                               AND entries.effective_end_date
      AND p_effective_date BETWEEN inputs1.effective_start_date
                               AND inputs1.effective_end_date
      AND p_effective_date BETWEEN value1.effective_start_date
                               AND value1.effective_end_date
      AND p_effective_date BETWEEN inputs2.effective_start_date
                               AND inputs2.effective_end_date
      AND p_effective_date BETWEEN value2.effective_start_date
                               AND value2.effective_end_date
      AND p_effective_date BETWEEN inputs3.effective_start_date
                               AND inputs3.effective_end_date
      AND p_effective_date BETWEEN value3.effective_start_date
                               AND value3.effective_end_date;
   --
   CURSOR csr_get_80cce_values(p_element_name           VARCHAR2
                              ,p_element_link_id        NUMBER
                              )
   IS
   SELECT entries.element_entry_id  entry_id
        , value1.screen_entry_value Investment_Amount
        , value2.screen_entry_value Component_Name
     FROM per_assignments_f assgn
        , pay_element_links_f link
        , pay_element_types_f types
        , pay_element_entries_f entries
        , pay_element_entry_values_f value1
        , pay_input_values_f inputs1
        , pay_element_entry_values_f value2
        , pay_input_values_f inputs2
    WHERE assgn.assignment_id = p_assignment_id
      AND link.element_link_id = p_element_link_id
      AND (types.processing_type = 'R' OR assgn.payroll_id IS NOT NULL)
      AND link.business_group_id = assgn.business_group_id
      AND link.element_type_id = types.element_type_id
      AND types.element_name = p_element_name
      AND entries.element_type_id = types.element_type_id
      AND entries.element_link_id = link.element_link_id
      AND entries.assignment_id = assgn.assignment_id
      AND value1.element_entry_id =  entries.element_entry_id
      AND inputs1.input_value_id = value1.input_value_id
      AND inputs1.element_type_id = types.element_type_id
      AND inputs1.name = 'Investment Amount'
      AND value2.element_entry_id =  entries.element_entry_id
      AND inputs2.input_value_id = value2.input_value_id
      AND inputs2.element_type_id = types.element_type_id
      AND inputs2.name = 'Component Name'
      AND p_effective_date BETWEEN assgn.effective_start_date
                               AND assgn.effective_end_date
      AND p_effective_date BETWEEN link.effective_start_date
                               AND link.effective_end_date
      AND p_effective_date BETWEEN types.effective_start_date
                               AND types.effective_end_date
      AND p_effective_date BETWEEN entries.effective_start_date
                               AND entries.effective_end_date
      AND p_effective_date BETWEEN inputs1.effective_start_date
                               AND inputs1.effective_end_date
      AND p_effective_date BETWEEN value1.effective_start_date
                               AND value1.effective_end_date
      AND p_effective_date BETWEEN inputs2.effective_start_date
                               AND inputs2.effective_end_date
      AND p_effective_date BETWEEN value2.effective_start_date
                               AND value2.effective_end_date;
   --
   --Added as a part of bug fix 4774108
   CURSOR csr_element_type_id(p_element_name    VARCHAR2)
   IS
   SELECT element_type_id
   FROM   pay_element_types_f
   WHERE  legislation_code = 'IN'
   AND    element_name = p_element_name
   AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;

   l_element_type_id     NUMBER; --Added as a part of bug fix 4774108
   l_element_link_id     NUMBER; --Added as a part of bug fix 4774108
   l_element_name        pay_element_types_f.element_name%TYPE;--Added as a part of bug fix 4774108
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
BEGIN
   --
    l_procedure := g_package || 'get_value';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id',p_assignment_id);
      pay_in_utils.trace('p_index',p_index);
      pay_in_utils.trace('p_element_name',p_element_name);
      pay_in_utils.trace('p_input_name',p_input_name);
      pay_in_utils.trace('p_effective_date',p_effective_date);
      pay_in_utils.trace('**************************************************','********************');
    END IF;


   IF g_index_assignment_id <> p_assignment_id THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 20);
      g_index_values_valid := false;
      --
   END IF;
   --
   IF NOT g_index_values_valid THEN
      --
      -- Put the details in the appropriate table available
      -- for each of the elements.
      --
      g_80dd_values.DELETE;
      g_80g_values.DELETE;
      g_insurace_values.DELETE;
      g_80cce_values.DELETE;
      g_80dd_index := 0;
      g_80g_index := 0;
      g_insurace_index := 0;
      g_80cce_index := 0;
      pay_in_utils.set_location(g_debug, l_procedure, 30);
      --
      --Added as a part of bug fix 4774108
      OPEN  csr_element_type_id('Deduction under Section 80DD');
      FETCH csr_element_type_id INTO l_element_type_id;
      CLOSE csr_element_type_id;

      l_element_link_id := pay_in_utils.get_element_link_id(p_assignment_id
                                                           ,p_effective_date
                                                           ,l_element_type_id
                                                           );

      FOR rec IN csr_get_80dd_values(l_element_link_id) LOOP
         --
         pay_in_utils.set_location(g_debug, l_procedure, 40);
         g_80dd_values(g_80dd_index).entry_id := rec.entry_id;
         g_80dd_values(g_80dd_index).input1_value := rec.disability_type;
         g_80dd_values(g_80dd_index).input2_value := rec.treatment_amount;
         g_80dd_values(g_80dd_index).input3_value := rec.disability_percentage;
         g_80dd_index := g_80dd_index + 1;
         --
      END LOOP;
      --
      --Added as a part of bug fix 4774108
      OPEN  csr_element_type_id('Deduction under Section 80G');
      FETCH csr_element_type_id INTO l_element_type_id;
      CLOSE csr_element_type_id;

      l_element_link_id := pay_in_utils.get_element_link_id(p_assignment_id
                                                           ,p_effective_date
                                                           ,l_element_type_id
                                                           );

      FOR rec IN csr_get_80g_values(l_element_link_id)LOOP
         --
         pay_in_utils.set_location(g_debug, l_procedure, 50);
         g_80g_values(g_80g_index).entry_id := rec.entry_id;
         g_80g_values(g_80g_index).input1_value := rec.donation_type;
         g_80g_values(g_80g_index).input2_value := rec.donation_amount;
         g_80g_index := g_80g_index + 1;
         --
      END LOOP;
      --Added as a part of bug fix 4774108
      OPEN  csr_element_type_id('Life Insurance Premium');
      FETCH csr_element_type_id INTO l_element_type_id;
      CLOSE csr_element_type_id;

      l_element_link_id := pay_in_utils.get_element_link_id(p_assignment_id
                                                           ,p_effective_date
                                                           ,l_element_type_id
                                                           );

      FOR rec IN csr_get_insurace_values(l_element_link_id) LOOP
         --
         pay_in_utils.set_location(g_debug, l_procedure, 60);
         g_insurace_values(g_insurace_index).entry_id := rec.entry_id;
         g_insurace_values(g_insurace_index).input1_value := rec.premium_paid;
         g_insurace_values(g_insurace_index).input2_value := rec.sum_assured;
         g_insurace_values(g_insurace_index).input3_value := rec.policy_number;
         g_insurace_index := g_insurace_index + 1;
         --
      END LOOP;
      --
      FOR i IN 1..4
      LOOP
            IF (i = 1) THEN
               l_element_name := 'Deduction under Section 80CCE';
            ELSIF (i = 2) THEN
               l_element_name := 'Pension Fund 80CCC';
            ELSIF (i = 3) THEN
               l_element_name := 'Deferred Annuity';
	    ELSE
	       l_element_name := 'Senior Citizens Savings Scheme';
            END IF;

            --Added as a part of bug fix 4774108
            OPEN  csr_element_type_id(l_element_name);
            FETCH csr_element_type_id INTO l_element_type_id;
            CLOSE csr_element_type_id;

            l_element_link_id := pay_in_utils.get_element_link_id(p_assignment_id
                                                                 ,p_effective_date
                                                                 ,l_element_type_id
                                                                 );

            FOR rec IN csr_get_80cce_values(l_element_name,l_element_link_id) LOOP
               --
               pay_in_utils.set_location(g_debug, l_procedure, 70);
               g_80cce_values(g_80cce_index).entry_id := rec.entry_id;
               g_80cce_values(g_80cce_index).input1_value := rec.Investment_Amount;
               g_80cce_values(g_80cce_index).input2_value := rec.Component_Name;
               g_80cce_index := g_80cce_index + 1;
               --
            END LOOP;
      END LOOP;
      --
      pay_in_utils.set_location(g_debug, l_procedure, 70);
      g_index_values_valid := true;
      g_index_assignment_id := p_assignment_id;
      --
   END IF;
   --
   IF p_element_name = 'Deduction under Section 80DD' THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 80);
      IF p_index <= g_80dd_index AND g_80dd_values.exists(p_index-1) THEN
         --
         pay_in_utils.set_location(g_debug, l_procedure, 90);
         IF p_input_name = 'Disability Type' THEN
	    pay_in_utils.set_location(g_debug, l_procedure, 100);
            IF g_debug THEN
                pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('Disablity Type',g_80dd_values(p_index-1).input1_value);
                pay_in_utils.trace('**************************************************','********************');
            END IF;
            pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,110);
	    RETURN g_80dd_values(p_index-1).input1_value;

         ELSIF p_input_name = 'Treatment Amount' THEN
            IF g_debug THEN
                pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('Treatment Amount',g_80dd_values(p_index-1).input2_value);
                pay_in_utils.trace('**************************************************','********************');
            END IF;
            pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,120);
            RETURN g_80dd_values(p_index-1).input2_value;

         ELSIF p_input_name = 'Disability Percentage' THEN
            IF g_debug THEN
                pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('Disability Percentage',g_80dd_values(p_index-1).input3_value);
                pay_in_utils.trace('**************************************************','********************');
            END IF;
            pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,130);
	    pay_in_utils.set_location(g_debug, l_procedure, 120);
            RETURN g_80dd_values(p_index-1).input3_value;

         ELSIF p_input_name = 'Element Entry Id' THEN
            IF g_debug THEN
                pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('Element ',g_80dd_values(p_index-1).entry_id);
                pay_in_utils.trace('**************************************************','********************');
            END IF;
            pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,130);
	    return g_80dd_values(p_index-1).entry_id;
         ELSE
	    return NULL;
         END IF;
      ELSE
	 pay_in_utils.set_location(g_debug, l_procedure, 130);
         return NULL;
      END IF;

   ELSIF p_element_name = 'Deduction under Section 80G' THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 140);
      IF p_index <= g_80g_index AND g_80g_values.exists(p_index-1) THEN
         --
         IF p_input_name = 'Donation Type' THEN
            IF g_debug THEN
                pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('Donation Type',g_80g_values(p_index-1).input1_value);
                pay_in_utils.trace('**************************************************','********************');
            END IF;
            pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,140);
            return g_80g_values(p_index-1).input1_value;

         ELSIF p_input_name = 'Donation Amount' THEN
            IF g_debug THEN
                pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('Donation Amount',g_80g_values(p_index-1).input2_value);
                pay_in_utils.trace('**************************************************','********************');
            END IF;
            pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,150);
            return g_80g_values(p_index-1).input2_value;

         ELSIF p_input_name = 'Element Entry Id' THEN
            IF g_debug THEN
                pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('Element Entry',g_80g_values(p_index-1).entry_id);
                pay_in_utils.trace('**************************************************','********************');
            END IF;
            pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,160);
	    return g_80g_values(p_index-1).entry_id;
         END IF;

      ELSE
         pay_in_utils.set_location(g_debug, l_procedure, 180);
         return NULL;
      END IF;
   ELSIF p_element_name = 'Life Insurance Premium' THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 190);
      IF p_index <= g_insurace_index AND g_insurace_values.exists(p_index-1) THEN
         --
         IF p_input_name = 'Premium Paid' THEN
            IF g_debug THEN
                pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('Premium Amount',g_insurace_values(p_index-1).input1_value);
                pay_in_utils.trace('**************************************************','********************');
            END IF;
            pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,170);
            return g_insurace_values(p_index-1).input1_value;

         ELSIF p_input_name = 'Sum Assured' THEN
            IF g_debug THEN
                pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('Sum Assured',g_insurace_values(p_index-1).input2_value);
                pay_in_utils.trace('**************************************************','********************');
            END IF;
            pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,180);
	    return g_insurace_values(p_index-1).input2_value;

         ELSIF p_input_name = 'Policy Number' THEN
            IF g_debug THEN
                pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('Policy Number',g_insurace_values(p_index-1).input3_value);
                pay_in_utils.trace('**************************************************','********************');
            END IF;
            pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,185);
            return g_insurace_values(p_index-1).input3_value;
         ELSIF p_input_name = 'Element Entry Id' THEN
            IF g_debug THEN
                pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('Element ',g_insurace_values(p_index-1).entry_id);
                pay_in_utils.trace('**************************************************','********************');
            END IF;
            pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,190);
	    return g_insurace_values(p_index-1).entry_id;
         END IF;

      ELSE
         pay_in_utils.set_location(g_debug, l_procedure, 230);
	 return NULL;
      END IF;
   ELSIF p_element_name = 'Deduction under Section 80CCE' THEN
      --
      pay_in_utils.set_location(g_debug, l_procedure, 240);
      IF p_index <= g_80cce_index AND g_80cce_values.exists(p_index-1) THEN
         --
         IF p_input_name = 'Investment Amount' THEN
            IF g_debug THEN
                pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('Investment Amount',g_80cce_values(p_index-1).input1_value);
                pay_in_utils.trace('**************************************************','********************');
            END IF;
            pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,200);
            return g_80cce_values(p_index-1).input1_value;

         ELSIF p_input_name = 'Component Name' THEN
            IF g_debug THEN
                pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('Component Name',g_80cce_values(p_index-1).input2_value);
                pay_in_utils.trace('**************************************************','********************');
            END IF;
            pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,210);
	    return g_80cce_values(p_index-1).input2_value;

         ELSIF p_input_name = 'Element Entry Id' THEN
            IF g_debug THEN
                pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('Element',g_80cce_values(p_index-1).entry_id);
                pay_in_utils.trace('**************************************************','********************');
            END IF;
            pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,220);
	    pay_in_utils.set_location(g_debug, l_procedure, 270);
	    return g_80cce_values(p_index-1).entry_id;
         END IF;
      ELSE
         pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,230);
	 return NULL;
      END IF;
   ELSE
        pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,240);
      return null;
   END IF;
   --
   -- As per logic should not come here at all.
   return null;
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,250);

END get_value;
-- End changes to Enhancement 3886086(Web ADI)



BEGIN
   --
   -- Global variable Initialization
   --
   g_legislation_code := 'IN';
   g_approval_info_type := 'PER_IN_TAX_DECL_DETAILS';
   g_is_valid := false;

   -- Following lines added for Web ADI Support
   g_index_values_valid := false;
   g_index_assignment_id := 0;
   g_80dd_index := 0;
   g_80g_index := 0;
   g_insurace_index := 0;
   g_80cce_index := 0;

   --
END pay_in_tax_declaration;

/
