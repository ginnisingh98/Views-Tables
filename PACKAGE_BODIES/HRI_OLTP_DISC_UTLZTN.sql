--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_DISC_UTLZTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_DISC_UTLZTN" AS
/* $Header: hriodutl.pkb 115.2 2003/01/24 10:07:20 jtitmas noship $ */

g_formula_type_id        NUMBER;


/******************************************************************************/
/* Coverts value to hours depending on the unit of measure given              */
/******************************************************************************/
FUNCTION convert_entry_to_hours( p_assignment_id       IN NUMBER,
                                 p_business_group_id   IN NUMBER,
                                 p_screen_value        IN VARCHAR2,
                                 p_uom                 IN VARCHAR2,
                                 p_effective_date      IN DATE)
            RETURN NUMBER IS

  l_seconds_per_hour      CONSTANT NUMBER  := 60*60;
  l_days                  NUMBER;
  l_hours                 NUMBER;
  l_seconds                  NUMBER;

BEGIN

/* If UOM is in hours then no conversion required */
  IF (p_uom LIKE 'H_DECIMAL%' OR p_uom = 'H_HH') THEN

    l_hours := TO_NUMBER(p_screen_value);

/* If UOM is in hours and minutes */
  ELSIF (p_uom = 'H_HHMM') THEN

  /* convert to seconds and then to hours */
    l_seconds := TO_NUMBER(TO_CHAR(TO_DATE(p_screen_value,'HH:MI'),'SSSSS'));
    l_hours   := l_seconds / l_seconds_per_hour;

/* If UOM is in hours, minutes and seconds */
  ELSIF (p_uom = 'H_HHMMSS') THEN

  /* convert to seconds and then to hours */
    l_seconds := to_number(to_char(to_date(p_screen_value,'HH:MI:SS'),'SSSSS'));
    l_hours   := l_seconds / l_seconds_per_hour;

/* If UOM is in days, call the fast formula via the bpl package to convert */
  ELSIF (p_uom in ('I','N','ND')) THEN

    l_days := TO_NUMBER(p_screen_value);
    l_hours := hri_bpl_utilization.convert_days_to_hours
                    (p_assignment_id      => p_assignment_id,
                     p_business_group_id  => p_business_group_id,
                     p_effective_date     => p_effective_date,
                     p_session_date       => SYSDATE,
                     p_number_of_days     => l_days);

  END IF;

  RETURN l_hours;

EXCEPTION WHEN OTHERS THEN

  RETURN to_number(null);

END convert_entry_to_hours;

/******************************************************************************/
/* Look up formula id and run formula to get hours worked                     */
/******************************************************************************/
FUNCTION calc_hours_worked_from_formula
                             (p_formula_name        IN VARCHAR2,
                              p_assignment_id       IN NUMBER,
                              p_business_group_id   IN NUMBER,
                              p_effective_date      IN DATE)
             RETURN NUMBER IS

  l_hours_worked          NUMBER;
  l_formula_id            NUMBER;
  l_ff_inputs     FF_Exec.Inputs_t;
  l_ff_outputs    FF_Exec.Outputs_t;

BEGIN

  SELECT formula_id INTO l_formula_id
  FROM ff_formulas_f
  WHERE formula_type_id = g_formula_type_id
  AND formula_name = p_formula_name
  AND TRUNC(sysdate) BETWEEN effective_start_date AND effective_end_date
  AND (business_group_id = p_business_group_id
    OR (business_group_id IS NULL AND p_business_group_id IS NULL));

  -- Initialise the Inputs and Outputs tables
  FF_Exec.Init_Formula
    ( p_formula_id     => l_formula_id
    , p_effective_date => SYSDATE
    , p_inputs         => l_ff_inputs
    , p_outputs        => l_ff_outputs );

  -- Set up context values for the formula
  FOR i IN l_ff_inputs.first .. l_ff_inputs.last LOOP

    IF (l_ff_inputs(i).name = 'DATE_EARNED') THEN
      l_ff_inputs(i).value := FND_Date.Date_To_Canonical(p_effective_date);
    ELSIF (l_ff_inputs(i).name = 'ASSIGNMENT_ID') THEN
      l_ff_inputs(i).value := p_assignment_id;
    END IF;

  END LOOP;

  -- Run the formula and get the return value
  FF_Exec.Run_Formula
    ( p_inputs  => l_ff_inputs
    , p_outputs => l_ff_outputs);

  l_hours_worked := TO_NUMBER(l_ff_outputs(l_ff_outputs.first).value);

  RETURN l_hours_worked;

EXCEPTION WHEN OTHERS THEN

  RETURN to_number(null);

END calc_hours_worked_from_formula;

/******************************************************************************/
/* Initialize formula type id */
/******************************/
BEGIN

  SELECT formula_type_id INTO g_formula_type_id
  FROM ff_formula_types
  WHERE formula_type_name = 'QuickPaint';

END hri_oltp_disc_utlztn;

/
