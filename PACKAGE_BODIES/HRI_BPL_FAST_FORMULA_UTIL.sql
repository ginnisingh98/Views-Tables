--------------------------------------------------------
--  DDL for Package Body HRI_BPL_FAST_FORMULA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_FAST_FORMULA_UTIL" AS
/* $Header: hribuffl.pkb 120.1.12000000.2 2007/04/12 12:07:43 smohapat noship $ */

  g_formula_type_id   NUMBER;

-- -----------------------------------------------------------------------------
-- Sets Quickpaint FF type
-- -----------------------------------------------------------------------------
PROCEDURE set_ff_type_id(p_formula_type_name    IN VARCHAR2) IS

BEGIN

  SELECT formula_type_id INTO g_formula_type_id
  FROM ff_formula_types
  WHERE formula_type_name = p_formula_type_name;

END set_ff_type_id;

-- -----------------------------------------------------------------------------
-- Runs fast formula to determine event details
-- -----------------------------------------------------------------------------
PROCEDURE run_formula
      (p_formula_id      IN NUMBER,
       p_input_tab       IN formula_param_type,
       p_output_tab      OUT NOCOPY formula_param_type) IS

  l_inputs        FF_EXEC.INPUTS_T;
  l_outputs       FF_EXEC.OUTPUTS_T;
  l_idx           VARCHAR2(30);

BEGIN

  -- Check formula exists
  IF p_formula_id IS NOT NULL THEN

    -- Run FF procedure initialization
    FF_Exec.Init_Formula
     (p_formula_id,
      SYSDATE,
      l_inputs,
      l_outputs);

    -- Populate input array
    IF l_inputs.count > 0 THEN

      FOR l_loop_count in l_inputs.first..l_inputs.last LOOP

        -- Get input table index
        l_idx := upper(l_inputs(l_loop_count).name);

        -- If an input table entry exists, set the parameter accordingly
        IF p_input_tab.EXISTS(l_idx) THEN
          l_inputs(l_loop_count).value := p_input_tab(l_idx);
        END IF;

      END LOOP;

    END IF;

    -- Execute formula
    FF_Exec.Run_Formula
     (l_inputs,
      l_outputs);

    -- Translate results from output array to output table
    IF l_outputs.count > 0 THEN

      FOR l_loop_count in l_outputs.first..l_outputs.last LOOP

        -- Set output table index
        l_idx := upper(l_outputs(l_loop_count).name);

        -- Translate result to table
        p_output_tab(l_idx) := l_outputs(l_loop_count).value;

      END LOOP;

    END IF;

  END IF;

END run_formula;

-- -----------------------------------------------------------------------------
-- Returns fast formula id from given business group
-- -----------------------------------------------------------------------------
FUNCTION fetch_bg_formula_id(p_formula_name       IN VARCHAR2,
                             p_business_group_id  IN NUMBER)
    RETURN NUMBER IS

  CURSOR bg_formula_csr IS
  SELECT fff.formula_id
  FROM ff_formulas_f fff
  WHERE fff.formula_type_id = g_formula_type_id
  AND fff.business_group_id = p_business_group_id
  AND trunc(sysdate) BETWEEN fff.effective_start_date
                     AND fff.effective_end_date
  AND fff.formula_name = p_formula_name;

  CURSOR seeded_formula_csr IS
  SELECT fff.formula_id
  FROM ff_formulas_f fff
  WHERE fff.formula_type_id = g_formula_type_id
  AND fff.business_group_id IS NULL
  AND trunc(sysdate) BETWEEN fff.effective_start_date
                     AND fff.effective_end_date
  AND fff.formula_name = p_formula_name;

  l_formula_id     NUMBER;

BEGIN

  IF (p_business_group_id IS NULL) THEN

    OPEN  seeded_formula_csr;
    FETCH seeded_formula_csr INTO l_formula_id;
    CLOSE seeded_formula_csr;

  ELSE

    OPEN  bg_formula_csr;
    FETCH bg_formula_csr INTO l_formula_id;
    CLOSE bg_formula_csr;

  END IF;

  RETURN l_formula_id;

END fetch_bg_formula_id;

-- -----------------------------------------------------------------------------
-- Returns fast formula id from given business group
-- -----------------------------------------------------------------------------
FUNCTION fetch_bg_formula_id(p_formula_name       IN VARCHAR2,
                             p_business_group_id  IN NUMBER,
                             p_formula_type_name  IN VARCHAR2)
    RETURN NUMBER IS

  l_formula_id      NUMBER;

BEGIN

  set_ff_type_id('Promotion');

  l_formula_id := hri_bpl_fast_formula_util.fetch_bg_formula_id
                   (p_formula_name      => p_formula_name,
                    p_business_group_id => p_business_group_id);

  set_ff_type_id('QuickPaint');

  RETURN l_formula_id;

END fetch_bg_formula_id;


-- -----------------------------------------------------------------------------
-- Returns fast formula id from setup business group
-- -----------------------------------------------------------------------------
FUNCTION fetch_setup_formula_id(p_formula_name  IN VARCHAR2)
    RETURN NUMBER IS

BEGIN

  RETURN fetch_bg_formula_id
          (p_formula_name      => p_formula_name,
           p_business_group_id => 0);

END fetch_setup_formula_id;

-- -----------------------------------------------------------------------------
-- Returns seeded fast formula id
-- -----------------------------------------------------------------------------
FUNCTION fetch_seeded_formula_id(p_formula_name  IN VARCHAR2)
    RETURN NUMBER IS

BEGIN

  RETURN fetch_bg_formula_id
          (p_formula_name      => p_formula_name,
           p_business_group_id => to_number(null));

END fetch_seeded_formula_id;

-- -----------------------------------------------------------------------------
-- Return fast formula id
-- -----------------------------------------------------------------------------
FUNCTION fetch_formula_id
   (p_formula_name        IN VARCHAR2,
    p_business_group_id   IN NUMBER,
    p_bg_formula_name     IN VARCHAR2 DEFAULT NULL,
    p_setup_formula_name  IN VARCHAR2 DEFAULT NULL,
    p_seeded_formula_name IN VARCHAR2 DEFAULT NULL,
    p_try_bg_formula      IN VARCHAR2 DEFAULT 'Y',
    p_try_setup_formula   IN VARCHAR2 DEFAULT 'Y',
    p_try_seeded_formula  IN VARCHAR2 DEFAULT 'Y')
      RETURN NUMBER IS

  l_bg_formula_name       VARCHAR2(30);
  l_setup_formula_name    VARCHAR2(30);
  l_seeded_formula_name   VARCHAR2(30);
  l_formula_id            NUMBER;

BEGIN

  -- Set BG formula name
  IF p_try_bg_formula = 'Y' AND p_bg_formula_name IS NULL THEN
    l_bg_formula_name := p_formula_name;
  ELSE
    l_bg_formula_name := p_bg_formula_name;
  END IF;

  -- Set setup formula name
  IF p_try_setup_formula = 'Y' AND p_setup_formula_name IS NULL THEN
    l_setup_formula_name := p_formula_name;
  ELSE
    l_setup_formula_name := p_setup_formula_name;
  END IF;

  -- Set seeded formula name
  IF p_try_seeded_formula = 'Y' AND p_seeded_formula_name IS NULL THEN
    l_seeded_formula_name := p_formula_name;
  ELSE
    l_seeded_formula_name := p_seeded_formula_name;
  END IF;

  -- Test for BG formula
  IF p_try_bg_formula = 'Y' AND
     l_bg_formula_name IS NOT NULL THEN

    l_formula_id := fetch_bg_formula_id
                     (p_formula_name       => l_bg_formula_name,
                      p_business_group_id => p_business_group_id);
  END IF;

  -- If BG formula not found, try setup formula
  IF l_formula_id IS NULL AND
     p_try_setup_formula = 'Y' AND
     l_setup_formula_name IS NOT NULL THEN

    l_formula_id := fetch_setup_formula_id
                     (p_formula_name => l_setup_formula_name);

  END IF;

  -- If BG and setup formulas not found, try seeded formula
  IF l_formula_id IS NULL AND
     p_try_seeded_formula = 'Y' AND
     l_seeded_formula_name IS NOT NULL THEN

    l_formula_id := fetch_seeded_formula_id
                     (p_formula_name => l_seeded_formula_name);

  END IF;

  -- Return formula id
  RETURN l_formula_id;

END fetch_formula_id;

-- -----------------------------------------------------------------------------
-- Initialize QuckPaint formula type
-- -----------------------------------------------------------------------------
BEGIN

  set_ff_type_id('QuickPaint');

END hri_bpl_fast_formula_util;

/
