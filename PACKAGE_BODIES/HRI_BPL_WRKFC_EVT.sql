--------------------------------------------------------
--  DDL for Package Body HRI_BPL_WRKFC_EVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_WRKFC_EVT" AS
/* $Header: hribwevt.pkb 120.0.12000000.2 2007/04/12 12:08:27 smohapat noship $ */

  g_hri_promotion_formula_id     NUMBER;
  g_hr_promotion_formula_id      NUMBER;

FUNCTION get_job_name(p_job_id   IN NUMBER)
      RETURN VARCHAR2 IS

  l_job_name   VARCHAR2(240);

BEGIN

  SELECT name INTO l_job_name
  FROM per_jobs
  WHERE job_id = p_job_id;

  RETURN l_job_name;

EXCEPTION WHEN OTHERS THEN

  RETURN 'Unassigned';

END get_job_name;

FUNCTION get_position_name(p_position_id   IN NUMBER)
      RETURN VARCHAR2 IS

  l_position_name   VARCHAR2(240);

BEGIN

  SELECT name INTO l_position_name
  FROM per_all_positions
  WHERE position_id = p_position_id;

  RETURN l_position_name;

EXCEPTION WHEN OTHERS THEN

  RETURN 'Unassigned';

END get_position_name;

FUNCTION get_grade_name(p_grade_id   IN NUMBER)
      RETURN VARCHAR2 IS

  l_grade_name   VARCHAR2(240);

BEGIN

  SELECT name INTO l_grade_name
  FROM per_grades
  WHERE grade_id = p_grade_id;

  RETURN l_grade_name;

EXCEPTION WHEN OTHERS THEN

  RETURN 'Unassigned';

END get_grade_name;

FUNCTION get_promotion_ind
   (p_assignment_id      IN NUMBER,
    p_business_group_id  IN NUMBER,
    p_effective_date     IN DATE,
    p_new_job_id         IN NUMBER,
    p_new_pos_id         IN NUMBER,
    p_new_grd_id         IN NUMBER,
    p_old_job_id         IN NUMBER,
    p_old_pos_id         IN NUMBER,
    p_old_grd_id         IN NUMBER)
     RETURN NUMBER IS

  l_formula_input_tab   hri_bpl_fast_formula_util.formula_param_type;
  l_formula_output_tab  hri_bpl_fast_formula_util.formula_param_type;
  l_promotion_flag      VARCHAR2(30);
  l_promotion_ind       NUMBER;

BEGIN

  -- Check if hr formula exists
  g_hr_promotion_formula_id := hri_bpl_fast_formula_util.fetch_bg_formula_id
                                (p_formula_name      => 'PROMOTION',
                                 p_business_group_id => p_business_group_id,
                                 p_formula_type_name => 'Promotion');

  -- Use HR formula if it exists
  IF g_hr_promotion_formula_id IS NOT NULL THEN

    -- Initialize formula input parameters
    l_formula_input_tab('ASSIGNMENT_ID') := p_assignment_id;
    l_formula_input_tab('DATE_EARNED') := fnd_date.date_to_canonical(p_effective_date);

    -- Extract outputs
    BEGIN

      -- Run formula
      hri_bpl_fast_formula_util.run_formula
       (p_formula_id => g_hr_promotion_formula_id,
        p_input_tab  => l_formula_input_tab,
        p_output_tab => l_formula_output_tab);

      -- Set output values
      IF l_formula_output_tab(l_formula_output_tab.FIRST) > 0 THEN
        l_promotion_flag := 'Y';
      END IF;

    -- Trap exception if formula does not exists, or errors
    EXCEPTION WHEN OTHERS THEN
      null;
    END;

  -- Otherwise check if HRI formula is available
  ELSIF (g_hri_promotion_formula_id IS NOT NULL AND
         (p_new_grd_id <> p_old_grd_id OR
          p_new_job_id <> p_old_job_id OR
          p_new_pos_id <> p_old_pos_id)) THEN

    -- Initialize formula input parameters
    l_formula_input_tab('JOB_NEW') := get_job_name(p_new_job_id);
    l_formula_input_tab('JOB_OLD') := get_job_name(p_old_job_id);
    l_formula_input_tab('GRADE_NEW') := get_grade_name(p_new_grd_id);
    l_formula_input_tab('GRADE_OLD') := get_grade_name(p_old_grd_id);
    l_formula_input_tab('POSITION_NEW') := get_position_name(p_new_pos_id);
    l_formula_input_tab('POSITION_OLD') := get_position_name(p_old_pos_id);

    -- Extract outputs
    BEGIN

      -- Run formula
      hri_bpl_fast_formula_util.run_formula
       (p_formula_id => g_hri_promotion_formula_id,
        p_input_tab  => l_formula_input_tab,
        p_output_tab => l_formula_output_tab);

      -- Set output values
      l_promotion_flag := l_formula_output_tab('PROMOTION_CODE');

    -- Trap exception if formula does not exists, or errors
    EXCEPTION WHEN OTHERS THEN
      null;
    END;

  -- If formula undefined default to grade change = promotion
  ELSIF p_new_grd_id = p_old_grd_id THEN
    l_promotion_flag := 'N';
  ELSE
    l_promotion_flag := 'Y';
  END IF;

  -- Return indicator
  IF l_promotion_flag = 'Y' THEN
    l_promotion_ind := 1;
  ELSE
    l_promotion_ind := 0;
  END IF;

  RETURN l_promotion_ind;

END get_promotion_ind;

BEGIN

  g_hri_promotion_formula_id := hri_bpl_fast_formula_util.fetch_setup_formula_id
                                 (p_formula_name => 'HRI_MAP_PROMOTION_EVENT');

END hri_bpl_wrkfc_evt;

/
