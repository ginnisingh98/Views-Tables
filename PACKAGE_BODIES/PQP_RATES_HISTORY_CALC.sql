--------------------------------------------------------
--  DDL for Package Body PQP_RATES_HISTORY_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_RATES_HISTORY_CALC" AS
/* $Header: pqrthcal.pkb 120.6.12010000.5 2008/08/05 14:23:40 ubhat ship $ */
--
-- Package Variables
-- do not include globals below this line in clear_cache
g_package_name                 VARCHAR2(31) := 'pqp_rates_history_calc.';
hr_application_error           EXCEPTION;
g_debug                        BOOLEAN;
PRAGMA EXCEPTION_INIT(hr_application_error, -20001);


-- include globals below this line in clear_cache
-- always group globals with reference to the subprograms that use them

-- cache for rates_history function
g_business_group_id            pay_element_types_f.business_group_id%TYPE;
g_legislation_code             pay_element_types_f.legislation_code%TYPE;
g_cache_rate_type_name         fnd_lookup_values.meaning%TYPE;
g_cache_rate_type_code         fnd_lookup_values.lookup_code%TYPE;

-- cache for get_bus_group_id
g_cache_assignment_id          per_all_assignments_f.assignment_id%TYPE;
g_cache_business_group_id      per_all_assignments_f.business_group_id%TYPE;

-- cache for get_element_entry_value
g_geev_element_type_id         pay_element_types_f.element_type_id%TYPE;


-- cursors

CURSOR csr_input_value_id
  (p_element_type_id              NUMBER
  ,p_input_value_name_in_caps     VARCHAR2
  ,p_effective_date               DATE
  ) IS
SELECT input_value_id
      ,default_value
      ,lookup_type
      ,value_set_id
FROM   pay_input_values_f
WHERE  element_type_id = p_element_type_id
  AND  UPPER(name) = UPPER(p_input_value_name_in_caps)
  AND  p_effective_date
         BETWEEN effective_start_date
             AND effective_end_date;


CURSOR csr_element_entry_value
  (p_assignment_id                IN      NUMBER
  ,p_element_type_id              IN      NUMBER
  ,p_input_value_id               IN      NUMBER
  ,p_effective_date               IN      DATE
  ) IS
SELECT eev.screen_entry_value
      ,liv.default_value
FROM   pay_element_entries_f      ele
      ,pay_element_links_f        lnk
      ,pay_link_input_values_f  liv
      ,pay_element_entry_values_f eev
WHERE  ele.assignment_id = p_assignment_id
  AND  ele.entry_type = 'E'
  AND  p_effective_date
         BETWEEN ele.effective_start_date
             AND ele.effective_end_date
  AND  eev.element_entry_id = ele.element_entry_id
  AND  lnk.element_link_id  = ele.element_link_id
  AND  lnk.element_type_id  = p_element_type_id
  AND  p_effective_date
         BETWEEN eev.effective_start_date
             AND eev.effective_end_date
  AND  eev.input_value_id  = p_input_value_id
  AND  liv.element_link_id = lnk.element_link_id
  AND  liv.input_value_id  = p_input_value_id
  AND  p_effective_date
         BETWEEN liv.effective_start_date
             AND liv.effective_end_date
  AND  p_effective_date
         BETWEEN lnk.effective_start_date
             AND lnk.effective_end_date;


-- Cursor to check if an element is linked to a assignment
CURSOR csr_element_entry
  (p_assignment_id                IN NUMBER
  ,p_element_type_id              IN NUMBER
  ,p_effective_date               IN DATE
  ) IS
SELECT pee.element_entry_id
FROM   pay_element_links_f            pel
      ,pay_element_entries_f          pee
WHERE  pel.element_type_id = p_element_type_id
  AND  p_effective_date
         BETWEEN pel.effective_start_date
             AND pel.effective_end_date
  AND  pee.element_link_id = pel.element_link_id
  AND  pee.assignment_id   = p_assignment_id
  AND  p_effective_date
         BETWEEN pee.effective_start_date
             AND pee.effective_end_date
  AND  p_effective_date
         BETWEEN pel.effective_start_date
             AND pel.effective_end_date;


CURSOR csr_given_element_entry_value
  (p_element_entry_id             IN      NUMBER
  ,p_input_value_id               IN      NUMBER
  ,p_effective_date               IN      DATE
  ) IS
SELECT eev.screen_entry_value
      ,liv.default_value
FROM   pay_element_entries_f      ele
      ,pay_element_links_f        lnk
      ,pay_link_input_values_f  liv
      ,pay_element_entry_values_f eev
WHERE  ele.element_entry_id = p_element_entry_id
  AND  p_effective_date
         BETWEEN ele.effective_start_date
             AND ele.effective_end_date
  AND  eev.element_entry_id = ele.element_entry_id
  AND  lnk.element_link_id  = ele.element_link_id
  AND  lnk.element_type_id  = ele.element_type_id
  AND  p_effective_date
         BETWEEN eev.effective_start_date
             AND eev.effective_end_date
  AND  eev.input_value_id  = p_input_value_id
  AND  liv.element_link_id = lnk.element_link_id
  AND  liv.input_value_id  = p_input_value_id
  AND  p_effective_date
         BETWEEN liv.effective_start_date
             AND liv.effective_end_date
  AND  p_effective_date
         BETWEEN lnk.effective_start_date
             AND lnk.effective_end_date;




--
--
--
PROCEDURE debug(
  p_trace_message             IN       VARCHAR2
 ,p_trace_location            IN       NUMBER DEFAULT NULL
)
IS
BEGIN
  pqp_utilities.debug(p_trace_message, p_trace_location);
END debug;
--
--
--
PROCEDURE debug(p_trace_number IN NUMBER)
IS
BEGIN
  pqp_utilities.debug(p_trace_number);
END debug;
--
--
--
PROCEDURE debug(p_trace_date IN DATE)
IS
BEGIN
  pqp_utilities.debug(p_trace_date);
END debug;
--
--
--
PROCEDURE debug_enter(
  p_proc_name                 IN       VARCHAR2
 ,p_trace_on                  IN       VARCHAR2 DEFAULT NULL
)
IS
BEGIN
  pqp_utilities.debug_enter(p_proc_name, p_trace_on);
END debug_enter;
--
--
--
PROCEDURE debug_exit(
  p_proc_name                 IN       VARCHAR2
 ,p_trace_off                 IN       VARCHAR2 DEFAULT NULL
)
IS
BEGIN
  pqp_utilities.debug_exit(p_proc_name, p_trace_off);
END debug_exit;
--
--
--
PROCEDURE debug_others(
  p_proc_name                 IN       VARCHAR2
 ,p_proc_step                 IN       NUMBER DEFAULT NULL
)
IS
BEGIN
  pqp_utilities.debug_others(p_proc_name, p_proc_step);
END debug_others;
--
--
--
PROCEDURE check_error_code
  (p_error_code               IN       NUMBER
  ,p_error_message            IN       VARCHAR2
  )
IS
BEGIN
  pqp_utilities.check_error_code(p_error_code, p_error_message);
END;
--
--
--
PROCEDURE clear_cache
IS
BEGIN
-- cache for rates_history function
  g_business_group_id            := NULL;--pay_element_types_f.business_group_id%TYPE;
  g_legislation_code             := NULL;--pay_element_types_f.business_group_id%TYPE;
  g_cache_rate_type_name         := NULL;--fnd_lookup_values.meaning%TYPE;
  g_cache_rate_type_code         := NULL;--fnd_lookup_values.lookup_code%TYPE;

-- cache for get_bus_group_id
 g_cache_assignment_id            := NULL;--per_all_assignments_f.assignment_id%TYPE;
 g_cache_business_group_id        := NULL;--per_all_assignments_f.business_group_id%TYPE;

END clear_cache;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_bus_grp_id >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: This function returns the business group id for the given assignment Id.
--
--
FUNCTION get_bus_grp_id(p_assignment_id IN NUMBER)
  RETURN NUMBER
IS

  l_proc_step                   NUMBER(20,10):=0;
  l_proc_name                   VARCHAR2(61):=
    g_package_name||'get_bus_grp_id';

  l_business_group_id           per_all_assignments_f.business_group_id%TYPE;

  CURSOR csr_get_bus_grp_id
  IS
    SELECT business_group_id
    FROM   per_all_assignments_f
    WHERE  assignment_id = p_assignment_id;
BEGIN

  IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_assignment_id:'||p_assignment_id);
    debug('g_cache_assignment_id:'||g_cache_assignment_id);
    debug('g_cache_business_group_id:'||g_cache_business_group_id);
  END IF;

  IF p_assignment_id <> g_cache_assignment_id
    OR
     g_cache_assignment_id IS NULL
    OR
     g_cache_business_group_id IS NULL
  THEN
    l_proc_step := 5;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;

    OPEN csr_get_bus_grp_id;
    FETCH csr_get_bus_grp_id INTO l_business_group_id;
    IF csr_get_bus_grp_id%FOUND
    THEN
      l_proc_step := 10;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;
      g_cache_assignment_id := p_assignment_id;
      g_cache_business_group_id := l_business_group_id;
    ELSE
      l_proc_step := 15;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;
      g_cache_assignment_id := NULL;
      g_cache_business_group_id := NULL;
    END IF;
    CLOSE csr_get_bus_grp_id;

  END IF;

  l_business_group_id := g_cache_business_group_id;

  IF g_debug THEN
    debug('l_business_group_id:'||l_business_group_id);
    debug_exit(l_proc_name);
  END IF;

  RETURN l_business_group_id;
EXCEPTION
  WHEN OTHERS THEN
    clear_cache;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END get_bus_grp_id;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_element_attributes >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Returns all the rates history attribution held at the
-- element level.
-- Added extra atributes as the Context is extended to have additional
-- Fields to store calculation information etc.
--
-- pqpgbtp1.pkb:      pqp_rates_history_calc.get_element_attributes
PROCEDURE get_element_attributes(
  p_element_type_extra_info_id IN      NUMBER
 ,p_service_history           OUT NOCOPY VARCHAR2
 ,p_fte                       OUT NOCOPY VARCHAR2
 ,p_pay_source_value          OUT NOCOPY VARCHAR2
 ,p_qualifier                 OUT NOCOPY VARCHAR2
 ,p_from_time_dim             OUT NOCOPY VARCHAR2
 ,p_calculation_type          OUT NOCOPY VARCHAR2
 ,p_calculation_value         OUT NOCOPY VARCHAR2
 ,p_input_value               OUT NOCOPY VARCHAR2
 ,p_linked_to_assignment      OUT NOCOPY VARCHAR2
 ,p_term_time_yes_no          OUT NOCOPY VARCHAR2
 ,p_sum_multiple_entries_yn   OUT NOCOPY VARCHAR2
 ,p_lookup_input_values_yn    OUT NOCOPY VARCHAR2
 ,p_column_name_source_type   OUT NOCOPY VARCHAR2
 ,p_column_name_source_name   OUT NOCOPY VARCHAR2
 ,p_row_name_source_type      OUT NOCOPY VARCHAR2
 ,p_row_name_source_name      OUT NOCOPY VARCHAR2
)
IS

--
-- Cursor to get values from element_attribution EIT
-- Added extra atributes as the Context is extended to have additional
-- Fields to store calculation information etc.

  CURSOR c_element_attributes
  IS
    SELECT pei.eei_information1  from_time_dimension
          ,pei.eei_information2  pay_source_value
          ,pei.eei_information3  qualifier
          ,pei.eei_information4  fte
          ,pei.eei_information5  termtime
          ,pei.eei_information7  calc_type
          ,pei.eei_information8  calc_value
          ,pei.eei_information9  input_value
          ,NVL(pei.eei_information10
              ,decode(pei.eei_information2,'IV','Y','N')) link_to_assign
          ,NVL(pei.eei_information12,'Y') term_time_yes_no  -- ! be careful
          ,NVL(pei.eei_information13,'N') sum_multiple_entries_yn
          ,NVL(pei.eei_information14,'N') lookup_input_values_yn
          ,pei.eei_information16 column_name_source_type
          ,pei.eei_information17 column_name_source_name
          ,pei.eei_information18 row_name_source_type
          ,pei.eei_information19 row_name_source_name
    FROM   pay_element_type_extra_info pei
    WHERE  pei.element_type_extra_info_id = p_element_type_extra_info_id;

  l_proc_step                        NUMBER(20,10):=0;
  l_proc_name                        VARCHAR2(61)
    := g_package_name || 'get_element_attributes';

  l_service_history              fnd_lookups.lookup_code%TYPE;
  l_fte                          fnd_lookups.lookup_code%TYPE;
  l_pay_source_value             fnd_lookups.lookup_code%TYPE;
  l_qualifier                    pay_element_types_f.element_name%TYPE;
  l_from_time_dim                fnd_lookups.lookup_code%TYPE;
  l_calc_type                    fnd_lookups.lookup_code%TYPE;
  l_calc_value                   fnd_lookups.lookup_code%TYPE;
  l_input_value                  fnd_lookups.lookup_code%TYPE;
  l_check_link_to_assignment_yn  fnd_lookups.lookup_code%TYPE;
  l_term_time_yes_no             fnd_lookups.lookup_code%TYPE;
  l_sum_multiple_entries_yn      fnd_lookup_values.lookup_code%TYPE;
  l_lookup_input_values_yn       fnd_lookup_values.lookup_code%TYPE;
  l_column_name_source_type      pay_element_type_extra_info.eei_information16%TYPE;
  l_column_name_source_name      pay_element_type_extra_info.eei_information17%TYPE;
  l_row_name_source_type         pay_element_type_extra_info.eei_information18%TYPE;
  l_row_name_source_name         pay_element_type_extra_info.eei_information19%TYPE;



BEGIN

  g_debug := hr_utility.debug_enabled;

  IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_element_type_extra_info_id:'||p_element_type_extra_info_id);
  END IF;

  OPEN c_element_attributes;
  FETCH c_element_attributes
  INTO  l_from_time_dim
       ,l_pay_source_value
       ,l_qualifier
       ,l_fte
       ,l_service_history
       ,l_calc_type
       ,l_calc_value
       ,l_input_value
       ,l_check_link_to_assignment_yn
       ,l_term_time_yes_no
       ,l_sum_multiple_entries_yn
       ,l_lookup_input_values_yn
       ,l_column_name_source_type
       ,l_column_name_source_name
       ,l_row_name_source_type
       ,l_row_name_source_name
      ;
  CLOSE c_element_attributes;

  l_proc_step := 10;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;

  p_from_time_dim := l_from_time_dim;
  p_pay_source_value := l_pay_source_value;
  p_qualifier := l_qualifier;
  p_fte := l_fte;
  p_service_history := l_service_history;
  p_calculation_type := l_calc_type ;
  p_calculation_value := l_calc_value ;
  p_input_value := l_input_value ;
  p_linked_to_assignment := l_check_link_to_assignment_yn ;
  p_term_time_yes_no :=  l_term_time_yes_no;
  p_sum_multiple_entries_yn := l_sum_multiple_entries_yn;
  p_lookup_input_values_yn := l_lookup_input_values_yn;
  p_column_name_source_type := l_column_name_source_type;
  p_column_name_source_name :=  l_column_name_source_name;
  p_row_name_source_type    :=  l_row_name_source_type;
  p_row_name_source_name     :=  l_row_name_source_name;



  l_proc_step := 20;
  IF g_debug THEN
    debug('p_from_time_dim:'||p_from_time_dim );
    debug('p_pay_source_value:'||p_pay_source_value );
    debug('p_qualifier:'||p_qualifier );
    debug('p_fte:'||p_fte );
    debug('p_service_history:'||p_service_history );
    debug('p_calculation_type:'||p_calculation_type );
    debug('p_calculation_value:'||p_calculation_value );
    debug('p_input_value:'||p_input_value );
    debug('p_linked_to_assignment:'||p_linked_to_assignment );
    debug('p_sum_multiple_entries_yn:'||p_sum_multiple_entries_yn );
    debug('p_lookup_input_values_yn:'||p_lookup_input_values_yn );
    debug_exit(l_proc_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    clear_cache;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END get_element_attributes;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< service_history_factor >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Returns the service history factor, calculated by
-- matching length of continuous service against the service history
-- banding defined for the employee's contract
--
FUNCTION service_history_factor(p_assignment_id IN NUMBER, p_date IN DATE)
  RETURN NUMBER
IS
  l_proc_step                   NUMBER(20,10):=0;
  l_proc_name                        VARCHAR2(61)
                                   := g_package_name || 'service_history_factor';
  l_contract_type               VARCHAR2(80);
  l_service_length              NUMBER;
  l_service_factor              VARCHAR2(80);
  l_lower                       VARCHAR2(80);
  l_upper                       VARCHAR2(80);
  l_column_name                 VARCHAR2(80);
  l_business_group_id           pay_user_column_instances_f.business_group_id%TYPE;

  --
  -- Cursor to get Service History Factor
  --
  CURSOR c_service_factor(p_contract_type VARCHAR2, p_column_name VARCHAR2)
  IS
    SELECT sci.VALUE
          ,lci.VALUE
          ,uci.VALUE
    FROM   pay_user_column_instances_f sci
          ,pay_user_columns sc
          ,pay_user_column_instances_f uci
          ,pay_user_columns uc
          ,pay_user_column_instances_f lci
          ,pay_user_columns lc
          ,pay_user_tables ut
          ,pay_user_rows_f ur
    WHERE  ut.user_table_name = 'PQP_CONTRACT_TYPES'
    AND    ur.user_table_id = ut.user_table_id
    AND    UPPER(ur.row_low_range_or_name) = UPPER(p_contract_type)
    AND    UPPER(sc.user_column_name) =
                                UPPER(p_column_name || ' ADJUSTMENT FACTOR')
    AND    sc.user_table_id = ut.user_table_id
    AND    sci.user_column_id = sc.user_column_id
    AND    ur.user_row_id = sci.user_row_id
    AND    UPPER(uc.user_column_name) =
                                      UPPER(p_column_name || ' UPPER LIMIT')
    AND    uc.user_table_id = ut.user_table_id
    AND    uci.user_column_id = uc.user_column_id
    AND    ur.user_row_id = uci.user_row_id
    AND    UPPER(lc.user_column_name) =
                                      UPPER(p_column_name || ' LOWER LIMIT')
    AND    lc.user_table_id = ut.user_table_id
    AND    lci.user_column_id = lc.user_column_id
    AND    ur.user_row_id = lci.user_row_id
    AND    (
               (
                    sci.business_group_id IS NOT NULL
                AND sci.business_group_id = l_business_group_id
               )
            OR (
                    sci.legislation_code IS NOT NULL
                AND sci.business_group_id IS NULL
               )
            OR (
                    sci.business_group_id IS NULL
                AND sci.legislation_code IS NULL
               )
           )
    AND    (
               (
                    uci.business_group_id IS NOT NULL
                AND uci.business_group_id = l_business_group_id
               )
            OR (
                    uci.legislation_code IS NOT NULL
                AND uci.business_group_id IS NULL
               )
            OR (
                    uci.business_group_id IS NULL
                AND uci.legislation_code IS NULL
               )
           )
    AND    (
               (
                    lci.business_group_id IS NOT NULL
                AND lci.business_group_id = l_business_group_id
               )
            OR (
                    lci.legislation_code IS NOT NULL
                AND lci.business_group_id IS NULL
               )
            OR (
                    lci.business_group_id IS NULL
                AND lci.legislation_code IS NULL
               )
           )
    AND    (
               (
                    ur.business_group_id IS NOT NULL
                AND ur.business_group_id = l_business_group_id
               )
            OR (
                    ur.legislation_code IS NOT NULL
                AND ur.business_group_id IS NULL
               )
            OR (
                ur.business_group_id IS NULL AND ur.legislation_code IS NULL
               )
           )
    AND    p_date BETWEEN ur.effective_start_date AND ur.effective_end_date
    AND    p_date BETWEEN sci.effective_start_date AND sci.effective_end_date
    AND    p_date BETWEEN uci.effective_start_date AND uci.effective_end_date
    AND    p_date BETWEEN lci.effective_start_date AND lci.effective_end_date;

  --
  -- Cursor to get contract type
  --
  CURSOR c_contract_type
  IS
    SELECT contract_type
    FROM   pqp_assignment_attributes_f
    WHERE  assignment_id = p_assignment_id
    AND    p_date BETWEEN effective_start_date AND effective_end_date;
BEGIN
--
  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    debug_enter(l_proc_name);
   END IF;

--
  l_business_group_id := get_bus_grp_id(p_assignment_id => p_assignment_id);
--

  OPEN c_contract_type;
  FETCH c_contract_type INTO l_contract_type;
  CLOSE c_contract_type;

  IF l_contract_type IS NULL
  THEN
    --
    -- Added a new message for contract type not found
    -- BUG 3454641
    hr_utility.set_message(8303, 'PQP_230113_AAT_MISSING_CONTRCT');
    -- ver 115.35 : anshghos : setting token value
    fnd_message.set_token('EFFECTIVEDATE',fnd_date.date_to_canonical(p_date));
    hr_utility.raise_error;
    -- RETURN 0;
  --
  END IF;

  l_service_length :=
    pqp_service_history_calc_pkg.calculate_continuous_service
    (p_assignment_id => p_assignment_id
    ,p_calculation_date => p_date);
  --
  -- Service history function returns result in days, whereas band details
  -- are held in years on the contract type. So, we must convert the figure.
  --

  l_service_length := l_service_length / 365;

  FOR l_band_number IN 1 .. 5
  LOOP
    --
    l_column_name := 'Service History Band ' || TO_CHAR(l_band_number);
    OPEN c_service_factor(l_contract_type, l_column_name);
    FETCH c_service_factor INTO l_service_factor, l_lower, l_upper;
    CLOSE c_service_factor;
    EXIT WHEN l_service_length BETWEEN l_lower AND l_upper;
    l_service_factor := 0;
  --
  END LOOP;

  hr_utility.set_location('Leaving:' || l_proc_name, 20);
  RETURN l_service_factor;
EXCEPTION
WHEN OTHERS THEN
  clear_cache;
  IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
    debug_others(l_proc_name,l_proc_step);
    IF g_debug THEN
      debug('Leaving: '||l_proc_name,-999);
    END IF;
    fnd_message.raise_error;
  ELSE
    RAISE;
  END IF;
END service_history_factor;
-- ----------------------------------------------------------------------------
-- |--------------------------< get_annualization_factor >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Get the contract value from the table PQP_CONTRACT_TYPES
--              for a given contract type and contract attribute
--
FUNCTION get_annualization_factor
  (p_assignment_id                IN            NUMBER
  ,p_effective_date               IN            DATE
  ,p_business_group_id            IN            NUMBER
  ,p_contract_type                IN            VARCHAR2
  ,p_time_dimension               IN            VARCHAR2
  ) RETURN NUMBER
IS

  CURSOR csr_current_pay_frequency
   (p_assignment_id                NUMBER
   ,p_effective_date               DATE
   )
  IS
    SELECT types.number_per_fiscal_year annualization_factor
    FROM   per_all_assignments_f  assign
          ,per_time_periods       period
          ,per_time_period_types  types
    WHERE assign.assignment_id = p_assignment_id
    AND   period.payroll_id    = assign.payroll_id
    AND   p_effective_date BETWEEN period.start_date
                               AND period.end_date
    AND   types.period_type  = period.period_type
    AND   p_effective_date BETWEEN assign.effective_start_date
                               AND assign.effective_end_date;


  CURSOR csr_number_per_fiscal_year
    (p_period_type IN VARCHAR2
    ) IS
  SELECT number_per_fiscal_year
  FROM   per_time_period_types
  WHERE  period_type = p_period_type;

  l_proc_step           NUMBER(20,10):=0;
  l_proc_name           VARCHAR2(61):=
    g_package_name||'get_annualization_factor';

  l_dim_annualization_factor     NUMBER;
  l_current_pay_frequency        per_time_period_types.number_per_fiscal_year%TYPE;
  l_biweekly_pay_frequency       per_time_period_types.number_per_fiscal_year%TYPE:=26;
  l_weekly_pay_frequency         per_time_period_types.number_per_fiscal_year%TYPE:=52;
  l_monthly_pay_frequency        per_time_period_types.number_per_fiscal_year%TYPE:=12;
  l_base_frequency               per_time_period_types.number_per_fiscal_year%TYPE:=12;
  l_pay_frequency_factor         NUMBER:= 1;
  l_contract_factor              NUMBER;
  l_column_name                  pay_user_columns.user_column_name%TYPE;

BEGIN

g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  debug_enter(l_proc_name);
  debug('p_assignment_id:'||p_assignment_id);
  debug('p_effective_date:'||fnd_date.date_to_canonical(p_effective_date));
  debug('p_business_group_id:'||p_business_group_id);
  debug('p_contract_type:'||p_contract_type);
  debug('p_time_dimension:'||p_time_dimension);
END IF;

-- the time dimension here could be both source or to
-- the purpose of the following statements is to return a conversion factor
-- for a given time dimension. The conversion factor may then be used
-- for either to or fro conversions. Some dimensions like O are only
-- "to" time dimensions. Tho there is no restriction on our part to do so.


IF p_time_dimension = 'A'
THEN
  l_proc_step := 10;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;
  l_dim_annualization_factor := 1;
ELSE
  l_proc_step := 20;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;
  IF p_time_dimension <> 'PAY'
  THEN
    l_proc_step := 20;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;
    l_column_name := hr_general.decode_lookup('PQP_TIME_DIMENSION_FACTORS',p_time_dimension);
  ELSE
    -- get the assignments pay frequency annualization factor
    OPEN csr_current_pay_frequency(p_assignment_id,p_effective_date);
    FETCH csr_current_pay_frequency INTO l_current_pay_frequency;
    CLOSE csr_current_pay_frequency;

    l_proc_step := 30;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;

    -- mod payfrequency,26 (hence use biweekly)
    IF MOD(l_current_pay_frequency,l_biweekly_pay_frequency) = 0
    THEN
      -- pay frequency is a weekly multiple
      --e.g. for a Bi-Week =  Periodic Value * (Weekly Payroll Divisor * 26/52) =
      -- Periodic Value * (Weekly Payroll Divisor * 1/2)
      -- i.e. for Bi-Week = 52.14 * l_annualization_factor = 26 / l_week_ann_factor=52

      l_proc_step := 35;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;

      l_column_name := 'WEEKLY PAYROLL DIVISOR';
      l_base_frequency := l_weekly_pay_frequency;

    ELSE
      -- pay frequency is a monthly multiple
      -- e.g. for a Quarter Period
      -- l_multiplier = 12 * 4 / 12

      l_proc_step := 40;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;

      l_column_name := 'MONTHLY PAYROLL DIVISOR';
      l_base_frequency := l_monthly_pay_frequency;

    END IF;

    l_pay_frequency_factor := l_current_pay_frequency/l_base_frequency;

  END IF; -- p_time_dimension <> 'PAY'

  IF g_debug THEN
    debug('l_column_name:'||l_column_name);
  END IF;

  IF l_column_name IS NOT NULL
  THEN

     -- Get the factor value from the contracts table
     BEGIN
       l_contract_factor := fnd_number.canonical_to_number(
                   hruserdt.get_table_value
                  (p_bus_group_id   => p_business_group_id
                  ,p_table_name     => c_contract_table_name
                  ,p_col_name       => l_column_name
                  ,p_row_value      => p_contract_type
                  ,p_effective_date => p_effective_date
                  ));
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       l_contract_factor := NULL;
     END;
  END IF; -- End if of column name is not null check ...

  -- the dimension annualization factor is the factor defined in the contract
  -- multiplied by the pay frequency conversion, if any

  l_proc_step := 40;
  IF g_debug THEN
     debug('l_contract_factor:'||l_contract_factor);
     debug('l_pay_frequency_factor:'||l_pay_frequency_factor);
  END IF;

  l_dim_annualization_factor := l_contract_factor * NVL(l_pay_frequency_factor,1);

END IF;  -- IF p_time_dimension = 'A'


IF l_dim_annualization_factor IS NULL
THEN
  l_proc_step := 50;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;

  hr_utility.set_message(8303, 'PQP_230513_INVALID_CNTRCT_TYPE');
  hr_utility.raise_error;

END IF;

IF g_debug THEN
  debug('l_dim_annualization_factor:'||l_dim_annualization_factor);
  debug_exit(l_proc_name);
END IF;

RETURN l_dim_annualization_factor;

EXCEPTION
  WHEN OTHERS THEN
    clear_cache;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END get_annualization_factor;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< convert_values >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Do time dimension, fte, service hist conversion if necessary
--
-- dependency : pqpgbtp1.pkb:       l_value := pqp_rates_history_calc.convert_values
FUNCTION convert_values
 (p_assignment_id                IN            NUMBER
 ,p_date                         IN            DATE
 ,p_value                        IN            NUMBER
 ,p_to_time_dim                  IN            VARCHAR2
 ,p_from_time_dim                IN            VARCHAR2
 ,p_fte                          IN            VARCHAR2
 ,p_service_history              IN            VARCHAR2
 ,p_term_time_yes_no             IN            VARCHAR2
 ,p_contract_type                IN            VARCHAR2 DEFAULT NULL
 ,p_contract_type_usage          IN            VARCHAR2 DEFAULT g_default_contract_type_usage
 ) RETURN NUMBER
IS
  l_proc_step                    NUMBER(20,10):=0;
  l_proc_name                    VARCHAR2(61)
    := g_package_name||'convert_values';

  l_column_name                  VARCHAR2(80);
  l_divisor                      NUMBER;
  l_multiplier                   NUMBER;
  l_annual_value                 NUMBER;
  l_annual_hours                 NUMBER;
  l_annual_term_time_hours       NUMBER;
  l_term_time_adjustment         NUMBER;
  l_fte_value                    NUMBER;
  l_service_history_factor       NUMBER;
  l_element_rate                 NUMBER;
  l_business_group_id            pay_user_tables.business_group_id%TYPE;

  CURSOR csr_get_contract_type
  IS
  SELECT contract_type
    FROM pqp_assignment_attributes_f
   WHERE assignment_id = p_assignment_id
     AND p_date BETWEEN effective_start_date
                    AND effective_end_date;

  l_contract_type       pay_user_rows_f.row_low_range_or_name%TYPE;
  l_to_time_dimension   fnd_lookup_values.lookup_code%TYPE;

BEGIN

  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    debug_enter(l_proc_name);
   debug('p_assignment_id:'||p_assignment_id);
   debug('p_date:'||fnd_date.date_to_canonical(p_date));
   debug('p_value:'||p_value);
   debug('p_to_time_dim:'||p_to_time_dim);
   debug('p_from_time_dim:'||p_from_time_dim);
   debug('p_fte:'||p_fte);
   debug('p_service_history:'||p_service_history);
   debug('p_term_time_yes_no:'||p_term_time_yes_no);
   debug('p_contract_type:'||p_contract_type);
   debug('p_contract_type_usage:'||p_contract_type_usage);
  END IF;

  -- Get the business group id by passing the Assignment Id
  l_business_group_id := get_bus_grp_id(p_assignment_id => p_assignment_id);

  l_proc_step := 10;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;

  l_contract_type := NULL;

  IF p_contract_type IS NOT NULL
    AND
     p_contract_type_usage = c_overrides_asg_contract
  THEN
    -- don't fetch asg contract use the passed contract
     l_proc_step := 12;
     IF g_debug THEN
      debug(l_proc_name,l_proc_step);
     END IF;

    l_contract_type := p_contract_type;
  ELSE
    -- use assignment contract and if a default is supplied
    -- then use default where assignment contract is not found
    l_proc_step := 14;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;
    OPEN csr_get_contract_type;
    FETCH csr_get_contract_type INTO l_contract_type;
    IF csr_get_contract_type%NOTFOUND
      OR
       l_contract_type is NULL
    THEN
      l_proc_step := 16;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;

      IF p_contract_type IS NOT NULL
        AND
         p_contract_type_usage = c_defaults_asg_contract
      THEN
        l_proc_step := 18;
        IF g_debug THEN
          debug(l_proc_name,l_proc_step);
        END IF;
        l_contract_type := p_contract_type;
      END IF;
    END IF;
    CLOSE csr_get_contract_type;
    --
  END IF; -- IF contract is overriden

  l_proc_step := 20;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
    debug('l_contract_type:'||l_contract_type);
  END IF;

  -- if the "to time dimension" is not provided the user has requested
  -- the same time dimension has the source
  -- note this can only take place if the rate was an 'E' element type

  l_to_time_dimension := NVL(p_to_time_dim,p_from_time_dim);

  IF p_from_time_dim <> l_to_time_dimension
  THEN

    IF l_contract_type IS NULL
    THEN
      hr_utility.set_message(8303, 'PQP_230113_AAT_MISSING_CONTRCT');
      -- ver 115.35 : anshghos : setting token value
      fnd_message.set_token('EFFECTIVEDATE',fnd_date.date_to_canonical(p_date));
      hr_utility.raise_error;
    END IF;

    -- Modified code to improve performance
    -- BUG 3454641
    -- Call local function to get the multiplier value

    l_multiplier := get_annualization_factor
                      (p_assignment_id     => p_assignment_id
                      ,p_business_group_id => l_business_group_id
                      ,p_effective_date    => p_date
                      ,p_contract_type     => l_contract_type
                      ,p_time_dimension    => p_from_time_dim
                      );

    -- Convert source time dimension to annual value

    l_annual_value := p_value * l_multiplier;

    l_proc_step := 30;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;

    -- Call local function to get the divisor value

    l_divisor := get_annualization_factor
                      (p_assignment_id     => p_assignment_id
                      ,p_business_group_id => l_business_group_id
                      ,p_effective_date    => p_date
                      ,p_contract_type     => l_contract_type
                      ,p_time_dimension    => l_to_time_dimension
                      );

    l_proc_step := 35;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;

    -- Convert annual value to requested time dimension

    l_element_rate := l_annual_value / l_divisor;

    -- Commented out the following lines of code
    -- to improve performance
    -- BUG 3454641

  ELSE

      -- Requested dimension was same as stored dimension.
      -- Therefore no conversion required.

    l_element_rate := p_value;

  END IF; -- End if of p_from_time_dim <> p_to_time_dim check ...


  l_proc_step := 50;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
    debug('l_element_rate:'||l_element_rate);
  END IF;

  --
  -- Adjust figure for term time hours, if necessary
  --
  IF p_term_time_yes_no = 'Y'
  THEN

  -- BUG FIX 3570444
  -- Handle exception no_data_found explicitly
  -- for old customers who have set up rates history prior
  -- to adding the new segment term time hours
  --
    -- Comment out the following code
    -- use function to get the value from UDT instead
    -- BUG 3454641
    BEGIN

      l_annual_term_time_hours :=
                   fnd_number.canonical_to_number( hruserdt.get_table_value
                      (p_bus_group_id   => l_business_group_id
                      ,p_table_name     => c_contract_table_name
                      ,p_col_name       => 'ANNUAL TERM TIME HOURS'
                      ,p_row_value      => l_contract_type
                      ,p_effective_date => p_date
                      ));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      l_proc_step := 65;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;
      l_annual_term_time_hours := NULL;
    END;

    IF g_debug THEN
     debug('l_annual_term_time_hours:'||l_annual_term_time_hours);
    END IF;

    IF l_annual_term_time_hours IS NOT NULL
    THEN

      --
      -- Comment out the following code
      -- use function to get the value from UDT instead
      -- BUG 3454641

      BEGIN
        l_annual_hours :=
         fnd_number.canonical_to_number( hruserdt.get_table_value
            (p_bus_group_id   => l_business_group_id
            ,p_table_name     => c_contract_table_name
            ,p_col_name       => 'ANNUAL HOURS'
            ,p_row_value      => l_contract_type
            ,p_effective_date => p_date
            ));
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        l_proc_step := 75;
        IF g_debug THEN
          debug(l_proc_name,l_proc_step);
        END IF;
          l_annual_hours := NULL;
      END;

      IF g_debug THEN
        debug('l_annual_hours:'||l_annual_hours);
      END IF;

      IF l_annual_hours IS NOT NULL
         AND l_annual_hours <> l_annual_term_time_hours
      THEN

        l_term_time_adjustment := l_annual_term_time_hours / l_annual_hours;

        IF g_debug THEN
          debug('l_term_time_adjustment:'||l_term_time_adjustment);
        END IF;

        l_element_rate := l_element_rate * l_term_time_adjustment;

        END IF;
    --
    END IF;
  --
  END IF; -- p_term_time_yes_no = 'Y'

  l_proc_step := 85;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
    debug('l_element_rate:'||l_element_rate);
  END IF;

  --
  -- Apply FTE and Service History if needed
  --

  IF    p_fte = 'Y'
     --
     -- BUGFix 2895930 , if the p_fte = "Yes - Exlcuding Hourly Rates"
     -- then apply FTE only when the "to time dimension" is not Hourly.
     --
     -- For backward compatibility if the FTE switch is Yes then
     -- we still apply the FTE , regardless of the time dimension.
     -- this is because some customers may have implemented workarounds
     -- such has creating multiple elements or dividing the hourly rate
     -- back up by FTE in their custom code or formulae.
     --
     OR (  p_fte = 'H'  AND p_to_time_dim NOT IN ( 'H','O' ) )
  THEN

    l_fte_value :=
      pqp_fte_utilities.get_fte_value
        (p_assignment_id                => p_assignment_id
        ,p_calculation_date             => p_date
        );

    IF g_debug THEN
      debug('l_fte_value:'||l_fte_value);
    END IF;

    l_element_rate := l_element_rate * NVL(l_fte_value, 1);

  END IF;

  l_proc_step := 92;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
    debug('l_element_rate:'||l_element_rate);
  END IF;


  IF p_service_history = 'Y'
  THEN

    l_service_history_factor :=
      service_history_factor
        (p_assignment_id                => p_assignment_id
        ,p_date                         => p_date
        );

    IF g_debug THEN
      debug('l_service_history_factor(%age):'||l_service_history_factor);
    END IF;

    l_element_rate :=
      l_element_rate +
        ((l_service_history_factor / 100) * l_element_rate );

  END IF;

  IF g_debug THEN
    debug('l_element_rate:'||l_element_rate);
    debug_exit(l_proc_name);
  END IF;

  RETURN l_element_rate;

EXCEPTION
  WHEN OTHERS THEN
    clear_cache;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END convert_values;
-- ----------------------------------------------------------------------------
-- |-------------------------< apply_factor_or_percentage >----------------------------|
-- ----------------------------------------------------------------------------
FUNCTION apply_factor_or_percentage
  (p_assignment_id                IN            NUMBER
  ,p_rate                         IN            NUMBER
  ,p_type_factor_or_percentage    IN            VARCHAR2
  ,p_factor_or_percentage_value   IN            NUMBER
  ,p_element_type_id              IN            NUMBER
  ,p_input_value                  IN            VARCHAR2
  ,p_effective_date               IN            DATE
  ,p_lookup_input_values_yn       IN            VARCHAR2
  ) RETURN NUMBER
IS

  l_proc_step                    NUMBER(20,10):=0;
  l_proc_name                    VARCHAR2(61):=
    g_package_name||'apply_factor_or_percentage';

  l_input_value_id               pay_input_values_f.input_value_id%TYPE;
  l_input_value_default_txt      pay_input_values_f.default_value%TYPE;
  l_input_value_lookup_type      pay_input_values_f.lookup_type%TYPE;
  l_input_value_value_set_id     pay_input_values_f.value_set_id%TYPE;
  l_link_default_value_txt       pay_link_input_values_f.default_value%TYPE;
  l_entry_value_txt              pay_element_entry_values_f.screen_entry_value%TYPE;
  l_factor_or_percentage         NUMBER;
  l_modified_rate                NUMBER;

BEGIN

    g_debug := hr_utility.debug_enabled;

    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_rate:'||p_rate);
      debug('p_type_factor_or_percentage:'||p_type_factor_or_percentage);
      debug('p_factor_or_percentage_value:'||p_factor_or_percentage_value);
      debug('p_element_type_id:'||p_element_type_id);
      debug('p_input_value:'||p_input_value);
      debug('p_effective_date:'||p_effective_date);
    END IF;

    IF p_input_value IS NOT NULL
    THEN

      OPEN csr_input_value_id
        (p_element_type_id              => p_element_type_id
        ,p_input_value_name_in_caps     => UPPER(p_input_value)
        ,p_effective_date               => p_effective_date
        );
      FETCH csr_input_value_id
       INTO l_input_value_id
           ,l_input_value_default_txt
           ,l_input_value_lookup_type
           ,l_input_value_value_set_id;
      CLOSE csr_input_value_id;

      IF g_debug THEN
        debug('l_input_value_id:'||l_input_value_id);
        debug('l_input_value_default_txt:'||l_input_value_default_txt);
        debug('l_input_value_lookup_type:'||l_input_value_lookup_type);
        debug('l_input_value_value_set_id:'||l_input_value_value_set_id);
      END IF;

      OPEN csr_element_entry_value
       (p_assignment_id   => p_assignment_id
       ,p_element_type_id => p_element_type_id
       ,p_input_value_id  => l_input_value_id
       ,p_effective_date  => p_effective_date
       );
      FETCH csr_element_entry_value
       INTO l_entry_value_txt, l_link_default_value_txt;
      CLOSE csr_element_entry_value;

      IF g_debug THEN
        debug('l_entry_value_txt:'||l_entry_value_txt);
        debug('l_link_default_value_txt:'||l_link_default_value_txt);
      END IF;

      -- hot default the entry value to use
      -- i.e. if entry value is null, use link default
      --      if link default is null, use input value default

      l_entry_value_txt :=
        NVL(l_entry_value_txt
           ,NVL(l_link_default_value_txt
               ,l_input_value_default_txt
               )
           );

      IF ( l_input_value_lookup_type IS NOT NULL
          OR
           l_input_value_value_set_id IS NOT NULL
         )
        AND
         p_lookup_input_values_yn = 'Y' -- for backward compatbility
        AND
         l_entry_value_txt IS NOT NULL
      THEN

          l_entry_value_txt :=
            pay_ele_shd.convert_lookups(l_input_value_id, l_entry_value_txt);

      END IF; -- IF ( l_input_value_lookup_type IS NOT NULL

      l_factor_or_percentage := fnd_number.canonical_to_number(l_entry_value_txt);

      IF g_debug THEN
        debug('l_factor_or_percentage:'||l_factor_or_percentage);
      END IF;


    ELSE  -- IF p_input_name IS not null then

      l_factor_or_percentage := p_factor_or_percentage_value ;

    END IF; -- IF p_input_name IS not null then

    IF g_debug THEN
      debug('l_factor_or_percentage:'||l_factor_or_percentage);
    END IF;

    IF p_type_factor_or_percentage = 'PERCENT'
    THEN

      l_modified_rate := p_rate * ( l_factor_or_percentage / 100 ) ;

    ELSIF p_type_factor_or_percentage = 'FACTOR' THEN

      l_modified_rate := p_rate * l_factor_or_percentage ;

    END IF;

   l_modified_rate := NVL(l_modified_rate,0);

   IF g_debug THEN
     debug('l_modified_rate:'||l_modified_rate);
     debug_exit(l_proc_name);
   END IF;

   RETURN l_modified_rate;

EXCEPTION
  WHEN OTHERS THEN
    clear_cache;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END apply_factor_or_percentage;
--
--
--
FUNCTION get_element_entry_value
   (p_element_type_id              IN           NUMBER
   ,p_element_entry_id             IN           NUMBER
   ,p_input_value_name             IN           VARCHAR2
   ,p_effective_date               IN           DATE
   ,p_lookup_input_values_yn       IN           VARCHAR2
   ) RETURN pay_element_entry_values_f.screen_entry_value%TYPE
 IS

l_proc_step                    NUMBER(20,10);
l_proc_name                    VARCHAR2(61):=
  g_package_name||'get_element_entry_value';

l_input_value_id               pay_input_values_f.input_value_id%TYPE;
l_input_value_default_txt      pay_input_values_f.default_value%TYPE;
l_input_value_lookup_type      pay_input_values_f.lookup_type%TYPE;
l_input_value_value_set_id     pay_input_values_f.value_set_id%TYPE;
l_link_default_value_txt       pay_link_input_values_f.default_value%TYPE;
l_entry_value_txt              pay_element_entry_values_f.screen_entry_value%TYPE;

BEGIN

  debug_enter(l_proc_name);
  IF g_debug THEN
    debug('p_element_type_id:'||p_element_type_id);
    debug('p_input_value_name:'||p_input_value_name);
    debug('p_effective_date:'||fnd_date.date_to_canonical(p_effective_date));
    debug('p_lookup_input_values_yn:'||p_lookup_input_values_yn);
  END IF;

  OPEN csr_input_value_id
    (p_element_type_id              => p_element_type_id
    ,p_input_value_name_in_caps     => p_input_value_name
    ,p_effective_date               => p_effective_date
    );
  FETCH csr_input_value_id
   INTO l_input_value_id
       ,l_input_value_default_txt
       ,l_input_value_lookup_type
       ,l_input_value_value_set_id;
  CLOSE csr_input_value_id;

  IF g_debug THEN
    debug('l_input_value_id:'||l_input_value_id);
    debug('l_input_value_default_txt:'||l_input_value_default_txt);
    debug('l_input_value_lookup_type:'||l_input_value_lookup_type);
    debug('l_input_value_value_set_id:'||l_input_value_value_set_id);
  END IF;

  OPEN csr_given_element_entry_value
    (p_element_entry_id => p_element_entry_id
    ,p_input_value_id   => l_input_value_id
    ,p_effective_date   => p_effective_date
    );
  FETCH csr_given_element_entry_value INTO l_entry_value_txt, l_link_default_value_txt;
  CLOSE csr_given_element_entry_value;

  IF g_debug THEN
    debug('l_entry_value_txt:'||l_entry_value_txt);
    debug('l_link_default_value_txt:'||l_link_default_value_txt);
  END IF;

  -- hot default the entry value to use
  -- i.e. if entry value is null, use link default
  --      if link default is null, use input value default

  l_entry_value_txt := NVL(l_entry_value_txt
                          ,NVL(l_link_default_value_txt
                              ,l_input_value_default_txt
                              )
                          );
  l_proc_step := 10;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
    debug('l_entry_value_txt:'||l_entry_value_txt);
  END IF;

  IF ( l_input_value_lookup_type IS NOT NULL
      OR
       l_input_value_value_set_id IS NOT NULL
     )
    AND
     p_lookup_input_values_yn = 'Y' -- for backward compatbility
    AND
     l_entry_value_txt IS NOT NULL
  THEN

    l_entry_value_txt :=
      pay_ele_shd.convert_lookups(l_input_value_id, l_entry_value_txt);

  END IF; -- IF ( l_input_value_lookup_type IS NOT NULL

  IF g_debug THEN
    debug('l_entry_value_txt:'||l_entry_value_txt);
  END IF;

  debug_exit(l_proc_name);
  RETURN l_entry_value_txt;

EXCEPTION
  WHEN OTHERS THEN
    clear_cache;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END get_element_entry_value;
--
--
--
FUNCTION get_user_table_value
  (p_business_group_id            IN            NUMBER
  ,p_table_name                   IN            VARCHAR2
  ,p_column_name                  IN            VARCHAR2
  ,p_row_value                    IN            VARCHAR2
  ,p_effective_date               IN            DATE
  ) RETURN NUMBER
IS
  l_proc_step                    NUMBER(20,10);
  l_proc_name                    VARCHAR2(61):=
    g_package_name||'get_user_table_value';

  l_value                        NUMBER;

BEGIN

  debug_enter(l_proc_name);

  IF g_debug THEN
    debug('p_business_group_id:'||p_business_group_id);
    debug('p_table_name:'||p_table_name);
    debug('p_column_name:'||p_column_name);
    debug('p_row_value:'||p_row_value);
    debug('p_effective_date:'||fnd_date.date_to_canonical(p_effective_date));
  END IF;

  BEGIN -- wrapping the hruserdt.get_table_value call

    l_value :=
      TO_NUMBER
        (hruserdt.get_table_value
           (p_bus_group_id   => p_business_group_id
           ,p_table_name     => p_table_name
           ,p_col_name       => p_column_name
           ,p_row_value      => p_row_value
           ,p_effective_date => p_effective_date
           )
        );

    l_proc_step := 10;
    IF g_debug THEN
      debug('l_value:'||l_value);
    END IF;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_proc_step := 15;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;
      l_value := 0;
      NULL;
  END; -- wrapping the get_table_value

  IF g_debug THEN
    debug('l_value:'||l_value);
  END IF;
  debug_exit(l_proc_name);
  RETURN l_value;

EXCEPTION
  WHEN OTHERS THEN
    clear_cache;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END get_user_table_value;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< process_element >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Retrive all necessary data, and calculate the
-- applicable rate of pay.
-- Paramaters Added for Calculation Factors and Term-Time Hours Check
--
-- pqpgbtp1.pkb:             l_element_rate := pqp_rates_history_calc.process_element
FUNCTION process_element(
  p_assignment_id             IN       NUMBER
 ,p_date                      IN       DATE
 ,p_element_type_id           IN       NUMBER
 ,p_to_time_dim               IN       VARCHAR2
 ,p_fte                       IN       VARCHAR2
 ,p_service_history           IN       VARCHAR2
 ,p_pay_source_value          IN       VARCHAR2
 ,p_qualifier                 IN       VARCHAR2
 ,p_from_time_dim             IN       VARCHAR2
 ,p_calculation_type          IN       VARCHAR2
 ,p_calculation_value         IN       NUMBER
 ,p_input_value               IN       VARCHAR2
 ,p_term_time_yes_no          IN       VARCHAR2
 ,p_sum_multiple_entries_yn   IN       VARCHAR2
 ,p_lookup_input_values_yn    IN       VARCHAR2
 ,p_column_name_source_type   IN       VARCHAR2
 ,p_column_name_source_name   IN       VARCHAR2
 ,p_row_name_source_type      IN       VARCHAR2
 ,p_row_name_source_name      IN       VARCHAR2
 ,p_contract_type             IN       VARCHAR2 DEFAULT NULL
 ,p_contract_type_usage       IN       VARCHAR2 DEFAULT g_default_contract_type_usage
)
  RETURN NUMBER
IS

  l_proc_step                    NUMBER(20,10);
  l_proc_name                    VARCHAR2(61)
    := g_package_name ||'process_element';

  l_processed_element_rate       NUMBER;
  l_fetched_rate                 NUMBER;
  l_step_ceiling                 per_spinal_points.spinal_point%TYPE;
  l_step_ceiling_rate            NUMBER;
  l_user_col_name                VARCHAR2(50);
  l_business_group_id            per_assignments_f.business_group_id%TYPE;
  l_error_message                VARCHAR2(200) ;
  l_error_code                   NUMBER ;
  l_input_value_id               pay_input_values_f.input_value_id%TYPE;
  l_input_value_default_txt      pay_input_values_f.default_value%TYPE;
  l_input_value_lookup_type      pay_input_values_f.lookup_type%TYPE;
  l_input_value_value_set_id     pay_input_values_f.value_set_id%TYPE;
  l_link_default_value_txt       pay_link_input_values_f.default_value%TYPE;
  l_entry_value_txt              pay_element_entry_values_f.screen_entry_value%TYPE;
  l_row_name                     pay_user_rows_f.ROW_LOW_RANGE_OR_NAME%TYPE;
  l_column_name                  pay_user_columns.USER_COLUMN_NAME%TYPE;
  l_element_entry                csr_element_entry%ROWTYPE;
  --
  -- Cursor to get rate from spinal point
  --
  CURSOR csr_spinal_pay_scale
  IS
    SELECT TO_NUMBER(pgr.VALUE)
    FROM   pay_grade_rules_f pgr
          ,pay_rates pr
          ,per_spinal_point_placements_f spp
          ,per_spinal_point_steps_f sps
    WHERE  spp.assignment_id = p_assignment_id
    AND    UPPER(pr.NAME) = UPPER(p_qualifier)
    AND    pgr.rate_type = 'SP'
    AND    pr.rate_type = 'SP'
    AND    pgr.business_group_id = l_business_group_id
    AND    pr.business_group_id = l_business_group_id
    AND    spp.business_group_id = l_business_group_id
    AND    sps.business_group_id = l_business_group_id
    AND    pgr.rate_id = pr.rate_id
    AND    spp.step_id = sps.step_id
    AND    sps.spinal_point_id = pgr.grade_or_spinal_point_id
    AND    p_date BETWEEN spp.effective_start_date AND spp.effective_end_date
    AND    p_date BETWEEN sps.effective_start_date AND sps.effective_end_date
    AND    p_date BETWEEN pgr.effective_start_date AND pgr.effective_end_date;

  --
  --Cursor to get rate from Spinal Point in case of Qualifier with a wildcard
  --
  CURSOR csr_spinal_pay_scale_like
  IS
    SELECT   TO_NUMBER(pgr.VALUE)
    FROM     pay_grade_rules_f pgr
            ,pay_rates pr
            ,per_spinal_point_placements_f spp
            ,per_spinal_point_steps_f sps
    WHERE    spp.assignment_id = p_assignment_id
    AND      UPPER(pr.NAME) LIKE UPPER(p_qualifier)
    AND      pgr.rate_type = 'SP'
    AND      pr.rate_type = 'SP'
    AND      pgr.business_group_id = l_business_group_id
    AND      pr.business_group_id = l_business_group_id
    AND      spp.business_group_id = l_business_group_id
    AND      sps.business_group_id = l_business_group_id
    AND      pgr.rate_id = pr.rate_id
    AND      spp.step_id = sps.step_id
    AND      sps.spinal_point_id = pgr.grade_or_spinal_point_id
    AND      p_date BETWEEN spp.effective_start_date AND spp.effective_end_date
    AND      p_date BETWEEN sps.effective_start_date AND sps.effective_end_date
    AND      p_date BETWEEN pgr.effective_start_date AND pgr.effective_end_date
    ORDER BY pgr.effective_start_date DESC;

  --
  -- Cursor to get rate from grade scale
  --
  CURSOR csr_grade_rate
  IS
    SELECT TO_NUMBER(pgr.VALUE)
    FROM   per_assignments_f paf, pay_grade_rules_f pgr, pay_rates pr
    WHERE  paf.assignment_id = p_assignment_id
    AND    paf.grade_id = pgr.grade_or_spinal_point_id
    AND    pgr.rate_type = 'G'
    AND    pgr.rate_id = pr.rate_id
    AND    pr.rate_type = 'G'
    AND    paf.business_group_id = l_business_group_id
    AND    pr.business_group_id = l_business_group_id
    AND    pr.business_group_id = l_business_group_id
    AND    UPPER(pr.NAME) = UPPER(p_qualifier)
    AND    p_date BETWEEN paf.effective_start_date AND paf.effective_end_date
    AND    p_date BETWEEN pgr.effective_start_date AND pgr.effective_end_date;

  --
  --Cursor to get rate from grade scale in case of Qualifier with a wildcard.
  --
  CURSOR csr_grade_rate_like
  IS
    SELECT   TO_NUMBER(pgr.VALUE)
    FROM     per_assignments_f paf, pay_grade_rules_f pgr, pay_rates pr
    WHERE    paf.assignment_id = p_assignment_id
    AND      paf.grade_id = pgr.grade_or_spinal_point_id
    AND      pgr.rate_type = 'G'
    AND      pgr.rate_id = pr.rate_id
    AND      pr.rate_type = 'G'
    AND      paf.business_group_id = l_business_group_id
    AND      pr.business_group_id = l_business_group_id
    AND      pr.business_group_id = l_business_group_id
    AND      UPPER(pr.NAME) LIKE UPPER(p_qualifier)
    AND      p_date BETWEEN paf.effective_start_date AND paf.effective_end_date
    AND      p_date BETWEEN pgr.effective_start_date AND pgr.effective_end_date
    ORDER BY pgr.effective_start_date DESC;

  --
  --  Cursor to get rate from global value
  --
  CURSOR csr_global_value IS
  SELECT TO_NUMBER(ffg.global_value)
  FROM   ff_globals_f ffg
        ,per_business_groups_perf pbg
  WHERE  UPPER(ffg.GLOBAL_NAME) = UPPER(p_qualifier)
    AND  pbg.business_group_id = l_business_group_id
    AND    (
             (ffg.business_group_id = l_business_group_id
             )
            OR
             ( ffg.business_group_id IS NULL
              AND
               ffg.legislation_code = pbg.legislation_code
             )
            OR
             (
               ffg.business_group_id IS NULL
              AND
               ffg.legislation_code IS NULL
             )
           )
    AND  p_date
           BETWEEN ffg.effective_start_date
               AND ffg.effective_end_date;



BEGIN

  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_assignment_id:'||p_assignment_id);             --IN       NUMBER
    debug('p_date:'||fnd_date.date_to_canonical(p_date));                      --IN       DATE
    debug('p_element_type_id:'||p_element_type_id);           --IN       NUMBER
    debug('p_to_time_dim:'||p_to_time_dim);               --IN       VARCHAR2
    debug('p_fte:'||p_fte);                       --IN       VARCHAR2
    debug('p_service_history:'||p_service_history);           --IN       VARCHAR2
    debug('p_pay_source_value:'||p_pay_source_value);          --IN       VARCHAR2
    debug('p_qualifier:'||p_qualifier);                 --IN       VARCHAR2
    debug('p_from_time_dim:'||p_from_time_dim);             --IN       VARCHAR2
    debug('p_calculation_type:'||p_calculation_type);          --IN       VARCHAR2
    debug('p_calculation_value:'||p_calculation_value);         --IN       NUMBER
    debug('p_input_value:'||p_input_value);               --IN       VARCHAR2
    debug('p_term_time_yes_no:'||p_term_time_yes_no);          --IN       VARCHAR2
    debug('p_sum_multiple_entries_yn:'||p_sum_multiple_entries_yn);
    debug('p_lookup_input_values_yn:'||p_lookup_input_values_yn);
    debug('p_contract_type:'||p_contract_type);
    debug('p_contract_type_usage:'||p_contract_type_usage);
    debug('p_column_name_source_type:'||p_column_name_source_type);
    debug('p_column_name_source_name:'||p_column_name_source_name);
    debug('p_row_name_source_type:'||p_row_name_source_type);
    debug('p_row_name_source_name:'||p_row_name_source_name);

  END IF;

  --
  l_business_group_id := get_bus_grp_id(p_assignment_id => p_assignment_id);


  l_proc_step := 10;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;

  IF p_pay_source_value = 'SP'
  THEN

    --
    OPEN csr_spinal_pay_scale;
    FETCH csr_spinal_pay_scale INTO l_fetched_rate;
    l_processed_element_rate := l_fetched_rate;
    FETCH csr_spinal_pay_scale INTO l_fetched_rate;

    IF csr_spinal_pay_scale%FOUND
    THEN
      l_proc_step := 25;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;

      CLOSE csr_spinal_pay_scale;
      hr_utility.set_message(8303, 'PQP_230508_MULTIPLR_SCL_RATES');
      hr_utility.raise_error;
    --
    END IF;

    IF csr_spinal_pay_scale%ROWCOUNT = 0
    THEN
      l_proc_step := 30;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;
      OPEN csr_spinal_pay_scale_like;
      FETCH csr_spinal_pay_scale_like INTO l_processed_element_rate;
      CLOSE csr_spinal_pay_scale_like;
    --
    END IF;

    CLOSE csr_spinal_pay_scale;
  --
  ELSIF p_pay_source_value = 'GR'
  THEN

    OPEN csr_grade_rate;
    FETCH csr_grade_rate INTO l_fetched_rate;
    l_processed_element_rate := l_fetched_rate;
    FETCH csr_grade_rate INTO l_fetched_rate;

    IF csr_grade_rate%FOUND
    THEN
      l_proc_step := 50;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;
      CLOSE csr_grade_rate;
      hr_utility.set_message(8303, 'PQP_230509_MULTIPLE_GRD_RATES');
      hr_utility.raise_error;
    --
    END IF;

    IF csr_grade_rate%ROWCOUNT = 0
    THEN
      l_proc_step := 55;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;
      OPEN csr_grade_rate_like;
      FETCH csr_grade_rate_like INTO l_processed_element_rate;
      CLOSE csr_grade_rate_like;
    --
    END IF;

    CLOSE csr_grade_rate;
  --
  ELSIF p_pay_source_value = 'GV'
  THEN

    OPEN csr_global_value;
    FETCH csr_global_value INTO l_processed_element_rate;
    CLOSE csr_global_value;
  --
  ELSIF p_pay_source_value = 'IV'
  THEN
  -- potential for caching exists in this section

    OPEN csr_input_value_id
      (p_element_type_id              => p_element_type_id
      ,p_input_value_name_in_caps     => UPPER(p_qualifier)
      ,p_effective_date               => p_date
      );
    FETCH csr_input_value_id
     INTO l_input_value_id
         ,l_input_value_default_txt
         ,l_input_value_lookup_type
         ,l_input_value_value_set_id;
    CLOSE csr_input_value_id;

    IF g_debug THEN
      debug('l_input_value_id:'||l_input_value_id);
      debug('l_input_value_default_txt:'||l_input_value_default_txt);
      debug('l_input_value_lookup_type:'||l_input_value_lookup_type);
      debug('l_input_value_value_set_id:'||l_input_value_value_set_id);
    END IF;


    IF g_debug THEN
      debug('l_input_value_default_txt:'||l_input_value_default_txt);
    END IF;

    l_processed_element_rate := 0;
    l_fetched_rate := 0;
    OPEN csr_element_entry_value
     (p_assignment_id   => p_assignment_id
     ,p_element_type_id => p_element_type_id
     ,p_input_value_id  => l_input_value_id
     ,p_effective_date  => p_date
     );
    LOOP
      FETCH csr_element_entry_value
       INTO l_entry_value_txt, l_link_default_value_txt;
      EXIT WHEN csr_element_entry_value%NOTFOUND;


      IF g_debug THEN
        debug('l_entry_value_txt:'||l_entry_value_txt);
        debug('l_link_default_value_txt:'||l_link_default_value_txt);
      END IF;


      IF g_debug THEN
        debug('l_entry_value_txt:'||l_entry_value_txt);
        debug('l_link_default_value_txt:'||l_link_default_value_txt);
      END IF;


      -- hot default the entry value to use
      -- i.e. if entry value is null, use link default
      --      if link default is null, use input value default

      l_entry_value_txt := NVL(l_entry_value_txt
                              ,NVL(l_link_default_value_txt
                                  ,l_input_value_default_txt
                                  )
                              );

      IF ( l_input_value_lookup_type IS NOT NULL
          OR
           l_input_value_value_set_id IS NOT NULL
         )
        AND
         p_lookup_input_values_yn = 'Y' -- for backward compatbility
        AND
         l_entry_value_txt IS NOT NULL
      THEN

          l_entry_value_txt :=
            pay_ele_shd.convert_lookups(l_input_value_id, l_entry_value_txt);

      END IF; -- IF ( l_input_value_lookup_type IS NOT NULL

      IF l_entry_value_txt IS NOT NULL
      THEN
        l_fetched_rate := fnd_number.canonical_to_number(l_entry_value_txt);
      ELSE
        l_fetched_rate := 0;
      END IF;

      IF g_debug THEN
        debug('l_fetched_rate:'||l_fetched_rate);
      END IF;

      l_processed_element_rate := l_processed_element_rate + l_fetched_rate;

      IF g_debug THEN
        debug('l_processed_element_rate:'||l_processed_element_rate);
      END IF;

      IF p_sum_multiple_entries_yn = 'N'
      THEN
        EXIT; -- quit loop after first iteration for backward compatibility
      END IF;

    END LOOP;
    CLOSE csr_element_entry_value;

    IF g_debug THEN
      debug('l_processed_element_rate:'||l_processed_element_rate);
    END IF;

  ELSIF p_pay_source_value = 'RT'
  THEN

    g_rounding_precision := 38;
    l_error_code :=
      rates_history
        (p_assignment_id                => p_assignment_id
        ,p_calculation_date             => p_date
        ,p_name                         => p_qualifier
        ,p_rt_element                   => 'R'
        ,p_to_time_dim                  => p_from_time_dim
        ,p_rate                         => l_processed_element_rate
        ,p_error_message                => l_error_message
        ,p_contract_type                => p_contract_type
        ,p_contract_type_usage          => p_contract_type_usage
        );
     g_rounding_precision := 5;

    IF l_error_code < 0
    THEN
      check_error_code(l_error_code,l_error_message);
    END IF;

  ELSIF p_pay_source_value = 'EN'
  THEN

    g_rounding_precision := 38;
    l_error_code :=
      rates_history
        (p_assignment_id                => p_assignment_id
        ,p_calculation_date             => p_date
        ,p_name                         => p_qualifier
        ,p_rt_element                   => 'E'
        ,p_to_time_dim                  => p_from_time_dim
        ,p_rate                         => l_processed_element_rate
        ,p_error_message                => l_error_message
        ,p_contract_type                => p_contract_type
        ,p_contract_type_usage          => p_contract_type_usage
        );
     g_rounding_precision := 5;

    IF l_error_code < 0
    THEN
      check_error_code(l_error_code,l_error_message);
    END IF;

  ELSIF p_pay_source_value = 'TV'
  THEN

    l_proc_step := 90;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;

    -- at this stage we have the business_group, the table name in the qualifier
    -- column and row names maybe unknown
    -- to determine column and row names we need to check their source type first
    -- if its "Named in an Input Value" then we need to check entry value
    -- link value default, input value default , decode if lookup input values is Yes
    -- then use the column and row names.

      IF p_column_name_source_type = 'IV'
        OR
         p_row_name_source_type = 'IV'
      THEN

       l_proc_step := 92;
       IF g_debug THEN
        debug(l_proc_name,l_proc_step);
       END IF;

        l_processed_element_rate := 0;
        l_fetched_rate := 0;
        OPEN csr_element_entry
          (p_assignment_id   => p_assignment_id
          ,p_element_type_id => p_element_type_id
          ,p_effective_date  => p_date
          );
        LOOP
        FETCH csr_element_entry INTO l_element_entry;
        EXIT WHEN csr_element_entry%NOTFOUND;

        IF  p_column_name_source_type = 'IV'
        THEN

          l_proc_step := 95;
          IF g_debug THEN
            debug(l_proc_name,l_proc_step);
          END IF;

          l_column_name :=
            get_element_entry_value
             (p_element_type_id        => p_element_type_id
             ,p_element_entry_id       => l_element_entry.element_entry_id
             ,p_input_value_name       => p_column_name_source_name
             ,p_effective_date         => p_date
             ,p_lookup_input_values_yn => p_lookup_input_values_yn
             );
        ELSE
          l_column_name := p_column_name_source_name;
        END IF;

        IF  p_row_name_source_type = 'IV' THEN

          l_proc_step := 100;
          IF g_debug THEN
            debug(l_proc_name,l_proc_step);
          END IF;

          l_row_name :=
            get_element_entry_value
             (p_element_type_id        => p_element_type_id
             ,p_element_entry_id       => l_element_entry.element_entry_id
             ,p_input_value_name       => p_row_name_source_name
             ,p_effective_date         => p_date
             ,p_lookup_input_values_yn => p_lookup_input_values_yn
             );
        ELSE
          l_row_name := p_row_name_source_name;
        END IF;


       l_proc_step := 102;
       IF g_debug THEN
        debug(l_proc_name,l_proc_step);
       END IF;


        l_fetched_rate :=
          get_user_table_value
            (p_business_group_id => l_business_group_id
            ,p_table_name        => p_qualifier
            ,p_column_name       => l_column_name
            ,p_row_value         => l_row_name
            ,p_effective_date    => p_date
            );

        l_processed_element_rate := l_processed_element_rate + l_fetched_rate;

        IF p_sum_multiple_entries_yn = 'N'
        THEN
          EXIT; -- quit loop after first iteration for backward compatibility
        END IF;

      END LOOP; -- EXIT WHEN csr_element_entry%NOTFOUND;
      CLOSE csr_element_entry;

     ELSE
     -- donot have to check whether element is linked
     -- row and column name are explictlity defined
     -- so can do a get_table_direct and exit from loop.

       l_proc_step := 105;
       IF g_debug THEN
        debug(l_proc_name,l_proc_step);
       END IF;


        l_processed_element_rate :=
          get_user_table_value
            (p_business_group_id => l_business_group_id
            ,p_table_name        => p_qualifier
            ,p_column_name       => p_column_name_source_name
            ,p_row_value         => p_row_name_source_name
            ,p_effective_date    => p_date
            );

     END IF; -- IF p_column_name_source_type = 'IV' OR ...

  ELSE

    l_proc_step := 195;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;
    hr_utility.set_message(8303, 'PQP_230510_INVALID_PAY_SRC_VAL');
    hr_utility.raise_error;
  --
  END IF;

  l_proc_step := 200;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
    debug('l_processed_element_rate:'||l_processed_element_rate);
  END IF;


  IF l_processed_element_rate IS NOT NULL
  THEN

    -- call convert values function
    -- Added Term-Time Hours Check
    l_processed_element_rate :=
      convert_values(
        p_assignment_id =>              p_assignment_id
       ,p_date =>                       p_date
       ,p_value =>                      l_processed_element_rate
       ,p_to_time_dim =>                p_to_time_dim
       ,p_from_time_dim =>              p_from_time_dim
       ,p_fte =>                        p_fte
       ,p_service_history =>            p_service_history
       ,p_term_time_yes_no =>           p_term_time_yes_no
       ,p_contract_type    =>           p_contract_type
       ,p_contract_type_usage =>        p_contract_type_usage
      );

    l_proc_step := 210;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;

    -- If Pay Source Value is Rate Type or Element Name then
    -- consider the Calculation Part and apply it on Rate Calculated

    IF p_pay_source_value IN ('RT','EN')
    THEN

      l_processed_element_rate :=
        apply_factor_or_percentage
          (p_assignment_id                => p_assignment_id
          ,p_rate                         => l_processed_element_rate
          ,p_type_factor_or_percentage    => p_calculation_type
          ,p_factor_or_percentage_value   => p_calculation_value
          ,p_element_type_id              => p_element_type_id
          ,p_input_value                  => p_input_value
          ,p_effective_date               => p_date
          ,p_lookup_input_values_yn       => p_lookup_input_values_yn
          );

    END IF; -- IF p_pay_source_value in ('RT','EN')

  ELSE

    l_proc_step := 220;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;

    l_processed_element_rate := 0;

  END IF; -- IF l_processed_element_rate IS NOT NULL

  IF g_debug THEN
    debug('l_processed_element_rate:'||l_processed_element_rate);
    debug_exit(l_proc_name);
  END IF;
  RETURN l_processed_element_rate;

EXCEPTION
  WHEN OTHERS THEN
    clear_cache;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END process_element;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< rates_history >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Top level function, returning rate of pay. Can be used
-- for single element or rate type.
--
FUNCTION rates_history
  (p_assignment_id             IN       NUMBER
  ,p_calculation_date          IN       DATE
  ,p_name                      IN       VARCHAR2
  ,p_rt_element                IN       VARCHAR2
  ,p_to_time_dim               IN       VARCHAR2
  ,p_rate                      IN OUT NOCOPY NUMBER
  ,p_error_message             IN OUT NOCOPY VARCHAR2
  ,p_contract_type             IN       VARCHAR2      DEFAULT NULL
  ,p_contract_type_usage       IN       VARCHAR2      DEFAULT g_default_contract_type_usage
  ) RETURN NUMBER
IS
  l_proc_step                    NUMBER(20,10);
  l_proc_name                    VARCHAR2(61)
    := g_package_name ||'rates_history';


     CURSOR csr_rate_type_code
       (p_rate_type_name               VARCHAR2
       ) IS
     SELECT lookup_code
     FROM   hr_lookups hrl
     WHERE  hrl.lookup_type = 'PQP_RATE_TYPE'
       AND  UPPER(hrl.meaning) = p_rate_type_name;


     CURSOR csr_element_attribute_id
       (p_element_type_id              NUMBER
       ) IS
     SELECT eei.element_type_extra_info_id
     FROM   pay_element_type_extra_info eei
     WHERE  eei.element_type_id = p_element_type_id
       AND  eei.information_type = 'PQP_UK_ELEMENT_ATTRIBUTION';


  l_csr_element_set              csr_element_set_typ;
  this_element                   csr_element_type_id%ROWTYPE;
  l_business_group_id            pay_element_types_f.business_group_id%TYPE;
  l_legislation_code             pay_element_types_f.legislation_code%TYPE;
  l_rate_name                    fnd_lookup_values.meaning%TYPE;
  l_rate_code                    fnd_lookup_values.meaning%TYPE;
  l_element_attribution_id       NUMBER;
  l_element_entry                csr_element_entry%ROWTYPE;

  l_fte                          fnd_lookup_values.lookup_code%TYPE;
  l_service_history              fnd_lookup_values.lookup_code%TYPE;
  l_pay_source_value             fnd_lookup_values.lookup_code%TYPE;
  l_qualifier                    pay_element_types_f.element_name%type;
  l_from_time_dimension          fnd_lookups.lookup_code%TYPE;
  l_element_rate                 NUMBER;
  l_total_rate                   NUMBER;
  l_rate_nc                      NUMBER;
  l_error_mesg_nc                fnd_new_messages.message_text%TYPE;
  l_calc_type                    fnd_lookup_values.lookup_code%TYPE;
  l_calc_value                   fnd_lookup_values.lookup_code%TYPE;
  l_input_value                  fnd_lookup_values.lookup_code%TYPE;
  l_check_link_to_assignment_yn  fnd_lookup_values.lookup_code%TYPE;
  l_term_time_yes_no             fnd_lookup_values.lookup_code%TYPE;
  l_linked_to_assignment_yn      fnd_lookup_values.lookup_code%TYPE;
  l_sum_multiple_entries_yn      fnd_lookup_values.lookup_code%TYPE;
  l_lookup_input_values_yn       fnd_lookup_values.lookup_code%TYPE;
  l_column_name_source_type      pay_element_type_extra_info.eei_information16%TYPE;
  l_column_name_source_name      pay_element_type_extra_info.eei_information17%TYPE;
  l_row_name_source_type         pay_element_type_extra_info.eei_information18%TYPE;
  l_row_name_source_name         pay_element_type_extra_info.eei_information19%TYPE;

BEGIN

  g_debug := hr_utility.debug_enabled;

  IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_assignment_id:'||p_assignment_id);
    debug('p_calculation_date:'||
     fnd_date.date_to_canonical(p_calculation_date));
    debug('p_name:'||p_name);
    debug('p_rt_element:'||p_rt_element);
    debug('p_to_time_dim:'||p_to_time_dim);
    debug('p_rate(INOUT):'||p_rate);
    debug('p_error_message(INOUT):'||p_error_message);
    debug('p_contract_type:'||p_contract_type);
    debug('p_contract_type_usage:'||p_contract_type_usage);
  END IF;

  -- nocopy changes
  l_rate_nc := p_rate;
  l_error_mesg_nc := p_error_message;

    l_business_group_id := get_bus_grp_id(p_assignment_id => p_assignment_id);

    l_proc_step := 10;
    IF g_debug THEN
      debug('l_business_group_id:'||l_business_group_id);
      debug('g_business_group_id:'||g_business_group_id);
      debug('g_legislation_code:'||g_legislation_code);
      debug(l_proc_name,l_proc_step);
    END IF;

    IF g_business_group_id IS NULL -- this caching should be in get_leg...code
      OR
       g_legislation_code  IS NULL
      OR
       g_business_group_id <> l_business_group_id
    THEN
      l_proc_step := 15;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;
      g_business_group_id := l_business_group_id;
      g_legislation_code := pqp_utilities.pqp_get_legislation_code(l_business_group_id);
    END IF;

    l_legislation_code := g_legislation_code;

    IF g_debug THEN
      debug('l_legislation_code:'||l_legislation_code);
    END IF;

    l_rate_name := UPPER(p_name);

    IF p_rt_element = 'R'
    THEN

      IF g_debug THEN
        debug('g_cache_rate_type_name:'||g_cache_rate_type_name);
        debug('g_cache_rate_type_code:'||g_cache_rate_type_code);
        debug('l_rate_name:'||l_rate_name);
      END IF;

      IF g_cache_rate_type_name <> l_rate_name
        OR
         g_cache_rate_type_code IS NULL
        OR
         g_cache_rate_type_name IS NULL
      THEN

        OPEN  csr_rate_type_code(l_rate_name);
        FETCH csr_rate_type_code INTO l_rate_code;
        IF csr_rate_type_code%FOUND
        THEN
          l_proc_step := 30;
          IF g_debug THEN
            debug(l_proc_name,l_proc_step);
          END IF;
          g_cache_rate_type_code := l_rate_code;
          g_cache_rate_type_name := l_rate_name;
        ELSE
          l_proc_step := 35;
          IF g_debug THEN
            debug(l_proc_name,l_proc_step);
          END IF;
          g_cache_rate_type_code := NULL; -- must do
          g_cache_rate_type_name := NULL; -- must do
          l_rate_code       := NULL; -- must do
          l_rate_name            := NULL; -- must do
        END IF; -- g_cache_rate_type_name
        CLOSE csr_rate_type_code;

      END IF; -- IF g_cache_rate_type_code IS NULL

      l_rate_code := g_cache_rate_type_code;

    ELSE -- p_rt_element = 'E'

      l_proc_step := 40;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;

      l_rate_code := l_rate_name;

    END IF; -- IF p_rt_element = 'R'

    IF g_debug THEN
      debug('l_rate_code:'||l_rate_code);
      debug('l_rate_name:'||l_rate_name);
    END IF;
    --
    -- Loop for each element in a rate type (element set)
    --
    l_total_rate := 0;


  IF l_rate_code IS NOT NULL
  THEN

     IF p_rt_element = 'R'
     THEN

        OPEN l_csr_element_set FOR
          SELECT ele.element_type_id
          FROM   pay_element_type_extra_info eei
                ,pay_element_types_f         ele
          WHERE  eei.information_type = 'PQP_UK_RATE_TYPE'
            AND  ele.element_type_id = eei.element_type_id
            AND  p_calculation_date
                   BETWEEN ele.effective_start_date
                     AND ele.effective_end_date
            AND  eei.eei_information1 = l_rate_code
            AND  (
                   ( ele.business_group_id IS NOT NULL
                    AND
                     ele.business_group_id = l_business_group_id
                   )
                  OR
                   ( ele.legislation_code = l_legislation_code
                    AND
                     ele.business_group_id IS NULL
                   )
                  OR
                   ( ele.legislation_code IS NULL
                    AND
                     ele.business_group_id IS NULL
                   )
                 );
     ELSE

      OPEN l_csr_element_set FOR
        SELECT ele.element_type_id
        FROM   pay_element_types_f ele
        WHERE  UPPER(ele.element_name) = l_rate_name
        AND    (
                 ( ele.business_group_id = l_business_group_id
                 )
                OR
                 ( ele.legislation_code = l_legislation_code
                  AND
                   ele.business_group_id IS NULL
                 )
                OR
                 ( ele.legislation_code IS NULL
                  AND
                   ele.business_group_id IS NULL
                 )
               )
        AND    p_calculation_date BETWEEN ele.effective_start_date
                                    AND ele.effective_end_date;

     END IF; -- IF p_rt_element = 'R'

    LOOP
      FETCH l_csr_element_set INTO this_element;
      EXIT WHEN l_csr_element_set%NOTFOUND;

      l_proc_step := 65;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
        debug('this_element.element_type_id:' ||this_element.element_type_id);
      END IF;

      OPEN csr_element_attribute_id(this_element.element_type_id);
      LOOP
      FETCH csr_element_attribute_id INTO l_element_attribution_id;
      EXIT WHEN  csr_element_attribute_id%NOTFOUND;
      -- IF csr_element_attribute_id%FOUND THEN

        IF g_debug THEN
          debug('l_element_attribution_id:' ||l_element_attribution_id);
        END IF;

        get_element_attributes(
          p_element_type_extra_info_id => l_element_attribution_id
         ,p_service_history            => l_service_history
         ,p_fte                        => l_fte
         ,p_pay_source_value           => l_pay_source_value
         ,p_qualifier                  => l_qualifier
         ,p_from_time_dim              => l_from_time_dimension
         ,p_calculation_type           => l_calc_type
         ,p_calculation_value          => l_calc_value
         ,p_input_value                => l_input_value
         ,p_linked_to_assignment       => l_check_link_to_assignment_yn
         ,p_term_time_yes_no           => l_term_time_yes_no
         ,p_sum_multiple_entries_yn    => l_sum_multiple_entries_yn
         ,p_lookup_input_values_yn     => l_lookup_input_values_yn
         ,p_column_name_source_type    => l_column_name_source_type
         ,p_column_name_source_name    => l_column_name_source_name
         ,p_row_name_source_type       => l_row_name_source_type
         ,p_row_name_source_name       => l_row_name_source_name
        );
        --

        l_proc_step := 75;
        IF g_debug THEN
          debug(l_proc_name,l_proc_step);
          debug('l_from_time_dimension:'||l_from_time_dimension);
          debug('l_pay_source_value:'||l_pay_source_value);
          debug('l_qualifier:'||l_qualifier);
          debug('l_calc_type:'||l_calc_type);
          debug('l_calc_value:'||l_calc_value);
          debug('l_input_value:'||l_input_value);
          debug('l_check_link_to_assignment_yn:'||l_check_link_to_assignment_yn);
          debug('l_fte:'||l_fte);
          debug('l_service_history:'||l_service_history);
          debug('l_sum_multiple_entries_yn:'||l_sum_multiple_entries_yn);
          debug('l_lookup_input_values_yn:'||l_lookup_input_values_yn);
          debug('l_column_name_source_type:'||l_column_name_source_type);
          debug('l_column_name_source_name:'||l_column_name_source_name);
          debug('l_row_name_source_type:'||l_row_name_source_type);
          debug('l_row_name_source_name:'||l_row_name_source_name);
        END IF;


        -- The value Linked to Assignment is Yes indicates that
        -- the element should be considered only if it is linked to
        -- assignment

        IF l_check_link_to_assignment_yn = 'Y'
        THEN
        -- Checking whether linked to Assignment

         OPEN csr_element_entry
           (p_assignment_id   => p_assignment_id
           ,p_element_type_id => this_element.element_type_id
           ,p_effective_date  => p_calculation_date
           );
         FETCH csr_element_entry INTO l_element_entry;
         IF csr_element_entry%NOTFOUND
         THEN
           l_proc_step := 85;
           IF g_debug THEN
             debug(l_proc_name,l_proc_step);
           END IF;
           -- The element is not linked to assignment
           l_linked_to_assignment_yn := 'N';
         ELSE
           l_linked_to_assignment_yn := 'Y';
         END IF ;
         CLOSE csr_element_entry;

        ELSE -- IF l_check_link_to_assignment_yn = 'Y'

             -- Element Need not be Linked to Assignment
             -- hence deem as "linked" !
             l_linked_to_assignment_yn := 'Y' ;

        END IF ; -- IF l_check_link_to_assignment_yn = 'Y'

        IF g_debug THEN
          debug('l_linked_to_assignment_yn:'||l_linked_to_assignment_yn);
        END IF;

        IF l_linked_to_assignment_yn = 'Y'
        THEN

          l_element_rate :=
          process_element
           (p_assignment_id                => p_assignment_id
           ,p_date                         => p_calculation_date
           ,p_element_type_id              => this_element.element_type_id
           ,p_to_time_dim                  => p_to_time_dim
           ,p_fte                          => l_fte
           ,p_service_history              => l_service_history
           ,p_pay_source_value             => l_pay_source_value
           ,p_qualifier                    => l_qualifier
           ,p_from_time_dim                => l_from_time_dimension
           ,p_calculation_type             => l_calc_type
           ,p_calculation_value            => fnd_number.canonical_to_number(l_calc_value)
           ,p_input_value                  => l_input_value
           ,p_term_time_yes_no             => l_term_time_yes_no
           ,p_sum_multiple_entries_yn      => l_sum_multiple_entries_yn
           ,p_lookup_input_values_yn       => l_lookup_input_values_yn
           ,p_column_name_source_type      => l_column_name_source_type
           ,p_column_name_source_name      => l_column_name_source_name
           ,p_row_name_source_type         => l_row_name_source_type
           ,p_row_name_source_name         => l_row_name_source_name
           ,p_contract_type                => p_contract_type
           ,p_contract_type_usage          => p_contract_type_usage
           );

          l_proc_step := 100;
          IF g_debug THEN
            debug(l_proc_name,l_proc_step);
            debug('l_element_rate:'||l_element_rate);
          END IF;

          l_total_rate := l_total_rate + l_element_rate;

          IF g_debug THEN
            debug('l_total_rate:'||l_element_rate);
          END IF;

       END IF ; -- IF l_linked_to_assignment_yn = 'Y' THEN -- process_element

     END LOOP; -- EXIT WHEN  csr_element_attribute_id%NOTFOUND;
     --END IF; -- IF csr_element_attribute_id%FOUND THEN -- get_element_attributes
     CLOSE csr_element_attribute_id;

     l_proc_step := 110;
     IF g_debug THEN
       debug(l_proc_name,l_proc_step);
     END IF;

    END LOOP; -- FETCH l_csr_element_set INTO this_element
    CLOSE l_csr_element_set;

  END IF; -- IF l_rate_code IS NOT NULL

  l_proc_step := 110;
  IF g_debug THEN
    debug('l_total_rate:'||l_total_rate);
  END IF;

  p_rate := ROUND(l_total_rate, g_rounding_precision);
--  p_rate := l_total_rate;

  p_error_message := NULL;
  IF g_debug THEN
    debug('p_rate:'||p_rate);
    debug('p_error_message:'||p_error_message);
    debug_exit(l_proc_name);
  END IF;
  RETURN 0;

EXCEPTION
  WHEN OTHERS THEN
    clear_cache;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END rates_history;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_historic_rate >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Top level function, returning rate of pay. Can be used
-- for single element or rate type.
-- Formula Function: GET_HISTORIC_RATE (aliased RATES_HISTORY) maps to this spec
-- p_effective_date               DEFAULT session effective date,
--                                        if the session date is no not set then
--                                        system date
-- p_time_dimension               DEFAULT the same as the source time dimension
--                                        for the element
-- p_rate_type_or_element         DEFAULT c_default_type_of_rate = 'E'
-- p_contract_type                DEFAULT Null , if no contract type is supplied
--                                               then one is expected to exist
--                                               at the assignment level
-- p_contract_type_usage          DEFAULT g_default_contract_type_usage = 'OVERRIDE'
--                                        override the assignment contract with
--                                        the one specified in p_contract_type
FUNCTION get_historic_rate
  (p_assignment_id                IN       NUMBER
  ,p_rate_name                    IN       VARCHAR2
  ,p_effective_date               IN       DATE     DEFAULT NULL
  ,p_time_dimension               IN       VARCHAR2 DEFAULT NULL
  ,p_rate_type_or_element         IN       VARCHAR2 DEFAULT c_default_type_of_rate
  ,p_contract_type                IN       VARCHAR2 DEFAULT NULL
  ,p_contract_type_usage          IN       VARCHAR2 DEFAULT g_default_contract_type_usage
  ) RETURN NUMBER
IS

  l_proc_step                    NUMBER(20,10):=0;
  l_proc_name                    VARCHAR2(61):=
    g_package_name||'get_historic_rate';

  l_historic_rate                NUMBER;
  l_effective_date               DATE;
  l_error_code                   fnd_new_messages.message_number%TYPE;
  l_error_message                fnd_new_messages.message_text%TYPE;


BEGIN

  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    debug('p_assignment_id:'||p_assignment_id);
    debug('p_rate_name:'||p_rate_name);
    debug('p_effective_date:'||fnd_date.date_to_canonical(p_effective_date));
    debug('p_time_dimension:'||
      NVL(p_time_dimension,'ISNULL_SAME_AS_FROM'));
    debug('p_rate_type_or_element:'||
      NVL(p_rate_type_or_element,'ISNULL_WILL_USE_'||c_default_type_of_rate));
    debug('p_contract_type:'||p_contract_type);
    debug('p_contract_type_usage:'||
      NVL(p_contract_type_usage,'ISNULL_WILL_USE_'||g_default_contract_type_usage));
  END IF;

  IF p_effective_date IS NULL
  THEN
    l_effective_date := HR_GBNICAR.NICAR_SESSION_DATE(0);
  ELSE
    l_effective_date := p_effective_date;
  END IF;

  IF g_debug THEN
    debug('l_effective_date:'||l_effective_date);
  END IF;

  l_error_code :=
    rates_history
      (p_assignment_id                => p_assignment_id
      ,p_calculation_date             => l_effective_date
      ,p_name                         => UPPER(p_rate_name)
      ,p_rt_element                   => NVL(p_rate_type_or_element,c_default_type_of_rate)
      ,p_to_time_dim                  => p_time_dimension
      ,p_rate                         => l_historic_rate
      ,p_error_message                => l_error_message
      ,p_contract_type                => p_contract_type
      ,p_contract_type_usage          => NVL(p_contract_type_usage,g_default_contract_type_usage)
      );

  l_proc_step := 20;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;

  IF l_error_code < 0
  THEN
    check_error_code(l_error_code,l_error_message);
  END IF;

  IF g_debug THEN
    debug('l_historic_rate:'||l_historic_rate);
  END IF;

  RETURN l_historic_rate;

EXCEPTION
  WHEN OTHERS THEN
    clear_cache;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END get_historic_rate;


END pqp_rates_history_calc;

/
