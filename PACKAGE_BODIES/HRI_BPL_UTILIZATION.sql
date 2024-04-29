--------------------------------------------------------
--  DDL for Package Body HRI_BPL_UTILIZATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_UTILIZATION" AS
/* $Header: hributl.pkb 120.4 2007/03/05 06:15:18 pachidam noship $ */

/* Package Global Variables */
  TYPE g_number_tab_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE g_varchar2_tab_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

  g_formula_tab                 g_number_tab_type;
  g_hr_formula_tab              g_varchar2_tab_type;
  g_formula_type_id             NUMBER;
  g_template_formula_id         NUMBER;

/* Global Cursors */
  CURSOR g_formula_type_csr IS
  SELECT formula_type_id
  FROM ff_formula_types
  WHERE formula_type_name = 'QuickPaint';

  CURSOR g_template_formula_csr IS
  SELECT fff.formula_id
  FROM ff_formulas_f fff
  WHERE fff.formula_type_id = g_formula_type_id
  AND fff.business_group_id IS NULL
  AND sysdate BETWEEN fff.effective_start_date AND fff.effective_end_date
  AND fff.formula_name = 'TEMPLATE_BIS_DAYS_TO_HOURS';


/******************************************************************************/
/* Retrieves the HR formula to default absence duration for a business group  */
/******************************************************************************/
FUNCTION use_hr_formula(p_business_group_id  IN NUMBER)
           RETURN VARCHAR2 IS

  CURSOR use_customer_formula_csr IS
  SELECT 'Y'
  FROM ff_formulas_f fff
  WHERE fff.formula_type_id = g_formula_type_id
  AND TRUNC(sysdate) BETWEEN fff.effective_start_date AND fff.effective_end_date
  AND fff.business_group_id = p_business_group_id
  AND fff.formula_name = 'BG_ABSENCE_DURATION'
  UNION ALL
  SELECT 'Y'
  FROM
   ff_formulas_f        fff
  ,per_business_groups  bgr
  WHERE fff.formula_type_id = g_formula_type_id
  AND TRUNC(sysdate) BETWEEN fff.effective_start_date AND fff.effective_end_date
  AND fff.business_group_id IS NULL
  AND bgr.business_group_id = p_business_group_id
  AND bgr.legislation_code = fff.legislation_code
  AND fff.formula_name = 'LEGISLATION_ABSENCE_DURATION'
  UNION ALL
  SELECT 'Y'
  FROM ff_formulas_f fff
  WHERE fff.formula_type_id = g_formula_type_id
  AND TRUNC(sysdate) BETWEEN fff.effective_start_date AND fff.effective_end_date
  AND fff.business_group_id IS NULL
  AND fff.formula_name = 'CORE_ABSENCE_DURATION';

  l_use_customer_formula   VARCHAR2(30);

BEGIN

/* Try the cache */
  BEGIN

    l_use_customer_formula := g_hr_formula_tab(p_business_group_id);

/* Cache Miss */
  EXCEPTION WHEN OTHERS THEN

  /* Try and retrieve a customer formula */
    OPEN  use_customer_formula_csr;
    FETCH use_customer_formula_csr INTO l_use_customer_formula;
    CLOSE use_customer_formula_csr;

  /* If no formula is found set flag to No */
    IF (l_use_customer_formula IS NULL) THEN
      l_use_customer_formula := 'N';
    END IF;

  /* Cache the formula to use for the business group */
    g_hr_formula_tab(p_business_group_id) := l_use_customer_formula;

  END;

  RETURN l_use_customer_formula;

END use_hr_formula;

/******************************************************************************/
/* Retrieves the days to hours conversion formula for a business group        */
/******************************************************************************/
FUNCTION get_formula_id(p_business_group_id  IN NUMBER)
           RETURN NUMBER IS

  CURSOR customer_formula_csr IS
  SELECT fff.formula_id
  FROM ff_formulas_f fff
  WHERE fff.formula_type_id = g_formula_type_id
  AND fff.business_group_id = p_business_group_id
  AND TRUNC(sysdate) BETWEEN fff.effective_start_date AND fff.effective_end_date
  AND fff.formula_name = 'BIS_DAYS_TO_HOURS';

  CURSOR customer_global_formula_csr IS
  SELECT fff.formula_id
  FROM ff_formulas_f fff
  WHERE fff.formula_type_id = g_formula_type_id
  AND fff.business_group_id = 0
  AND TRUNC(sysdate) BETWEEN fff.effective_start_date AND fff.effective_end_date
  AND fff.formula_name = 'BIS_DAYS_TO_HOURS';

  l_formula_id      NUMBER;

BEGIN

/* Try the cache */
  BEGIN

    l_formula_id := g_formula_tab(p_business_group_id);

/* Cache Miss */
  EXCEPTION WHEN OTHERS THEN

  /* Try and retrieve a customer formula */
    OPEN  customer_formula_csr;
    FETCH customer_formula_csr INTO l_formula_id;
    CLOSE customer_formula_csr;

  /* If there is no customer formula, get the global */
    IF (l_formula_id IS NULL) THEN
      OPEN  customer_global_formula_csr;
      FETCH customer_global_formula_csr INTO l_formula_id;
      CLOSE customer_global_formula_csr;
    END IF;

  /* If there is no customer formula, get the template */
    IF (l_formula_id IS NULL) THEN
      l_formula_id := g_template_formula_id;
    END IF;

  /* Cache the formula to use for the business group */
    g_formula_tab(p_business_group_id) := l_formula_id;

  END;

  RETURN l_formula_id;

END get_formula_id;


/******************************************************************************/
/* Runs the days to hours conversion formula                                  */
/******************************************************************************/
FUNCTION run_formula(p_assignment_id       IN NUMBER,
                     p_business_group_id   IN NUMBER,
                     p_effective_date      IN DATE,
                     p_session_date        IN DATE,
                     p_number_of_days      IN NUMBER)
        RETURN NUMBER IS

    l_ff_inputs     FF_Exec.Inputs_t;
    l_ff_outputs    FF_Exec.Outputs_t;
    l_hours         NUMBER;
    l_formula_id    NUMBER;

BEGIN

  -- Get the formula id to run
  l_formula_id := get_formula_id(p_business_group_id);

  -- Initialise the Inputs and Outputs tables
  FF_Exec.Init_Formula
    ( p_formula_id     => l_formula_id
    , p_effective_date => p_session_date
    , p_inputs         => l_ff_inputs
    , p_outputs        => l_ff_outputs );

  -- Set up context values for the formula
  FOR i IN l_ff_inputs.first .. l_ff_inputs.last LOOP

    IF (l_ff_inputs(i).name = 'DATE_EARNED') THEN
      l_ff_inputs(i).value := FND_Date.Date_To_Canonical(p_effective_date);
    ELSIF (l_ff_inputs(i).name = 'ASSIGNMENT_ID') THEN
      l_ff_inputs(i).value := p_assignment_id;
    ELSIF (l_ff_inputs(i).name = 'DAYS_WORKED') THEN
      l_ff_inputs(i).value := p_number_of_days;
    END IF;

  END LOOP;

  -- Run the formula and get the return value
  FF_Exec.Run_Formula
    ( p_inputs  => l_ff_inputs
    , p_outputs => l_ff_outputs);

  l_hours := FND_NUMBER.canonical_to_number(l_ff_outputs(l_ff_outputs.first).value);

  RETURN l_hours;

END run_formula;


/******************************************************************************/
/* Converts a value from days to hours                                        */
/******************************************************************************/
FUNCTION convert_days_to_hours(p_assignment_id       IN NUMBER,
                               p_business_group_id   IN NUMBER,
                               p_effective_date      IN DATE,
                               p_session_date        IN DATE,
                               p_number_of_days      IN NUMBER)
        RETURN NUMBER IS

  l_hours     NUMBER;

BEGIN

  IF (p_number_of_days IS NULL) THEN
    l_hours := to_number(null);
  ELSIF (p_number_of_days = 0) THEN
    l_hours := 0;
  ELSE
    l_hours := run_formula(p_assignment_id => p_assignment_id,
                           p_business_group_id => p_business_group_id,
                           p_effective_date => p_effective_date,
                           p_session_date => p_session_date,
                           p_number_of_days => p_number_of_days);
  END IF;

  RETURN l_hours;

END convert_days_to_hours;

/******************************************************************************/
/* Converts a value from hours to days                                        */
/******************************************************************************/
FUNCTION convert_hours_to_days(p_assignment_id       IN NUMBER,
                               p_business_group_id   IN NUMBER,
                               p_effective_date      IN DATE,
                               p_session_date        IN DATE,
                               p_number_of_hours     IN NUMBER)
        RETURN NUMBER IS

  l_hours_in_day     NUMBER;
  l_number_of_days   NUMBER;

BEGIN

  -- Check a valid number is passed in
  IF (p_number_of_hours IS NULL) THEN
    l_number_of_days := to_number(null);
  ELSIF (p_number_of_hours = 0) THEN
    l_number_of_days := 0;
  ELSE
    -- Get the number of working hours in 1 day
    l_hours_in_day := convert_days_to_hours
                       (p_assignment_id     => p_assignment_id,
                        p_business_group_id => p_business_group_id,
                        p_effective_date    => p_effective_date,
                        p_session_date      => p_session_date,
                        p_number_of_days    => 1);

    -- Scale back to the number of hours given
    IF (l_hours_in_day IS NULL OR
        l_hours_in_day = 0) THEN
      l_number_of_days := to_number(null);
    ELSE
      l_number_of_days := p_number_of_hours / l_hours_in_day;
    END IF;
  END IF;

  RETURN l_number_of_days;

END convert_hours_to_days;

/******************************************************************************/
/* Converts an absence duration in hours and/or days to hours or days         */
/******************************************************************************/
FUNCTION calculate_absence_duration(p_absence_attendance_id  IN VARCHAR2,
                                    p_uom_code               IN VARCHAR2,
                                    p_absence_hours          IN NUMBER,
                                    p_absence_days           IN NUMBER,
                                    p_assignment_id          IN NUMBER,
                                    p_business_group_id      IN NUMBER,
                                    p_primary_flag           IN VARCHAR2,
                                    p_date_start             IN DATE,
                                    p_date_end               IN DATE,
                                    p_time_start             IN VARCHAR2,
                                    p_time_end               IN VARCHAR2)
        RETURN NUMBER IS

  -- Cursor to get additional absence details
  -- if required to call HR formula
  CURSOR absence_details_csr IS
  SELECT
   piv.element_type_id
  ,bgr.legislation_code
  FROM
   per_absence_attendances       paa
  ,per_absence_attendance_types  pat
  ,pay_input_values_f            piv
  ,per_business_groups           bgr
  WHERE paa.absence_attendance_id = p_absence_attendance_id
  AND paa.business_group_id = bgr.business_group_id
  AND paa.absence_attendance_type_id = pat.absence_attendance_type_id
  AND pat.input_value_id = piv.input_value_id (+)
  AND pat.date_effective BETWEEN piv.effective_start_date (+)
                         AND piv.effective_end_date (+);

  l_hours     NUMBER;
  l_days      NUMBER;

  l_abs_element_id      NUMBER;
  l_abs_leg_code        VARCHAR2(30);
  l_abs_err_msg         VARCHAR2(1000);
  l_abs_duration        NUMBER;
  l_abs_use_formula     VARCHAR2(30);

BEGIN

  -- Check that at least one time component is provided
  -- Route 1
  IF (p_absence_hours IS NOT NULL OR p_absence_days IS NOT NULL) THEN

    -- Bug 4870326 - Ensure absence total for person adds up to duration
    --               by returning value only for primary assignment
    IF (p_primary_flag = 'N') THEN

      l_abs_duration := 0;

    ELSE

      -- Get absence duration in days
      IF (p_uom_code = 'DAYS') THEN

        -- Return days if provided, otherwise convert hours to days
        IF (p_absence_days IS NOT NULL) THEN
          l_abs_duration := p_absence_days;
        ELSE
          l_abs_duration := convert_hours_to_days
                             (p_assignment_id     => p_assignment_id,
                              p_business_group_id => p_business_group_id,
                              p_effective_date    => p_date_start,
                              p_session_date      => TRUNC(SYSDATE),
                              p_number_of_hours   => p_absence_hours);
        END IF;

      -- Get absence duration in hours
      ELSE

        -- Return hours if provided, otherwise convert days to hours
        IF (p_absence_hours IS NOT NULL) THEN
          l_abs_duration := p_absence_hours;
        ELSE
          l_abs_duration := convert_days_to_hours
                             (p_assignment_id     => p_assignment_id,
                              p_business_group_id => p_business_group_id,
                              p_effective_date    => p_date_start,
                              p_session_date      => TRUNC(SYSDATE),
                              p_number_of_days    => p_absence_days);
        END IF;

      END IF;  -- Absence duration Days/Hours

    END IF;  -- Primary/secondary assignment

  -- No absence duration component is provided
  -- Route 2
  ELSE

    -- Check whether HR formula is set up to default absence duration
    l_abs_use_formula := use_hr_formula
                          (p_business_group_id => p_business_group_id);

    -- If so, call the formula to get the absence duration
    IF (l_abs_use_formula = 'Y') THEN

      -- Get extra details needed
      OPEN absence_details_csr;
      FETCH absence_details_csr INTO
       l_abs_element_id,
       l_abs_leg_code;
      CLOSE absence_details_csr;

      -- Trap any errors running custom formulas
      BEGIN
        hr_cal_abs_dur_pkg.calculate_absence_duration
         ( p_days_or_hours     => SUBSTR(p_uom_code, 1, 1),
           p_date_start        => p_date_start,
           p_date_end          => p_date_end,
           p_time_start        => p_time_start,
           p_time_end          => p_time_end,
           p_business_group_id => p_business_group_id,
           p_legislation_code  => l_abs_leg_code,
           p_session_date      => TRUNC(SYSDATE),
           p_assignment_id     => p_assignment_id,
           p_element_type_id   => l_abs_element_id,
           p_invalid_message   => l_abs_err_msg,
           p_duration          => l_abs_duration,
           p_use_formula       => l_abs_use_formula);

      -- If an exception occurs log it and continue using basic calculation
      EXCEPTION WHEN OTHERS THEN
        hri_bpl_conc_log.output
         ('Warning: Error encountered running absence duration formula');
        hri_bpl_conc_log.output
         ('for assignment ' || to_char(p_assignment_id) ||
          ' on ' || to_char(p_date_start, 'DD-MON-YYYY') ||
          ' ' || p_time_start);
        -- Reset duration so basic calculation is used
        l_abs_duration := to_number(null);
      END;

    END IF;

    -- If hr formula is not setup then get absence duration using basic calculation
    IF (l_abs_duration IS NULL) THEN

      -- If absence spans 1 day and the time component is provided use that
      IF (p_time_start IS NOT NULL AND
          p_time_end IS NOT NULL AND
          p_date_start = p_date_end) THEN
        l_hours := 24 * (to_date(p_time_end,   'HH24:MI') -
                         to_date(p_time_start, 'HH24:MI'));
      ELSE
        l_days := p_date_end - p_date_start + 1;
      END IF;

      -- Get the duration by re-calling this function
      IF (l_hours >= 0 OR l_days >= 0) THEN

        -- Recursive call will provide one of the absence durations
        -- so pl/sql will follow route 1
        l_abs_duration :=  calculate_absence_duration
                            (p_absence_attendance_id => p_absence_attendance_id,
                             p_uom_code              => p_uom_code,
                             p_absence_hours         => l_hours,
                             p_absence_days          => l_days,
                             p_assignment_id         => p_assignment_id,
                             p_business_group_id     => p_business_group_id,
                             p_primary_flag          => p_primary_flag,
                             p_date_start            => p_date_start,
                             p_date_end              => p_date_end,
                             p_time_start            => p_time_start,
                             p_time_end              => p_time_end);
      ELSE
        l_abs_duration := 0;
      END IF;

    END IF;

  END IF;

  -- Return the sum of the converted components
  RETURN l_abs_duration;

END calculate_absence_duration;

/******************************************************************************/
/* Retrieves  value from profile option Absence Duration                      */
/******************************************************************************/
FUNCTION get_abs_durtn_profile_vl
	RETURN VARCHAR2 IS

    l_profile_vl   VARCHAR2(40);

BEGIN

 fnd_profile.get('HRI_DBI_ABS_DRTN_UOM',l_profile_vl);

 RETURN l_profile_vl;

EXCEPTION WHEN OTHERS THEN
      l_profile_vl:= 'DAYS';
  RETURN l_profile_vl;

END get_abs_durtn_profile_vl;

/******************************************************************************/
/* Initialize formula type id */
/******************************/
BEGIN

  OPEN g_formula_type_csr;
  FETCH g_formula_type_csr INTO g_formula_type_id;
  CLOSE g_formula_type_csr;

  OPEN g_template_formula_csr;
  FETCH g_template_formula_csr INTO g_template_formula_id;
  CLOSE g_template_formula_csr;

END hri_bpl_utilization;

/
