--------------------------------------------------------
--  DDL for Package Body HRI_BPL_ABV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_ABV" AS
/* $Header: hribabv.pkb 120.2 2008/05/22 08:54:12 smohapat noship $ */

/* Global variables for formula ids based on business group id */
/* to improve performance where more than one person from the  */
/* same business group is being used */

/* Type of record stored in a global temporary table */
TYPE budget_formula_rec IS RECORD(
       fte_formula_id              NUMBER,
       head_formula_id             NUMBER);

/* Global temporary table used to store fast formula ids for a business group */
TYPE g_budget_formula_tabtype IS TABLE OF budget_formula_rec
   INDEX BY BINARY_INTEGER;

/* g_formula_ids will be indexed by business group id and hold the fast */
/* formulae to be used when no value is stored in the ABV table for a   */
/* person in that business group */
g_formula_ids     g_budget_formula_tabtype;

/* Cache of formula names for uncompiled formulae */
TYPE g_formula_names_type IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;

g_formula_names_tab    g_formula_names_type;
g_template_head_id     NUMBER;
g_formula_type_id      NUMBER;
--
-- Set to true to output to a concurrent log file
--
g_conc_request_id         NUMBER := fnd_global.conc_request_id;
--
-- Debuging flag
--
g_debug_flag              VARCHAR2(1) := NVL(fnd_profile.value('HRI_ENBL_DTL_LOG'),'N');
--
-- Inserts row into concurrent program log
--
PROCEDURE output(p_text  VARCHAR2) IS
BEGIN
  --
  IF (g_conc_request_id is not null) THEN
    --
    -- Write to the concurrent request log
    --
    fnd_file.put_line(fnd_file.log, p_text);
    --
  ELSE
    --
    hr_utility.trace(p_text);
    --
  END IF;
  --
END output;
--
-- -----------------------------------------------------------------------------
-- Inserts row into concurrent program log if debugging is enabled
-- -----------------------------------------------------------------------------
--
PROCEDURE dbg(p_text  VARCHAR2) IS
--
BEGIN
--
  IF (g_debug_flag = 'Y' ) THEN
    --
    -- Write to output
    --
    output(p_text);
    --
  END IF;
--
END dbg;
/******************************************************************************/
/* Function which, given a budget type and a business group id, retrieves the */
/* formula id of the ABV Fast Formula to be run.
/******************************************************************************/
FUNCTION fetch_formula_id(p_business_group_id  IN NUMBER,
                          p_budget_type       IN VARCHAR2)
                  RETURN NUMBER IS
  --
  -- The customer formula is called 'BUDGET_<budget type>'
  --
  CURSOR customer_formula_csr IS
  SELECT fff.formula_id
  FROM ff_formulas_f fff
  WHERE fff.formula_type_id = g_formula_type_id
  AND fff.business_group_id = p_business_group_id
  AND trunc(sysdate) BETWEEN fff.effective_start_date AND fff.effective_end_date
  AND fff.formula_name = 'BUDGET_' || p_budget_type;
  --
  -- The template formula is called 'TEMPLATE_<budget type>'
  --
  CURSOR template_formula_csr IS
  SELECT fff.formula_id
  FROM ff_formulas_f fff
  WHERE fff.formula_type_id = g_formula_type_id
  AND fff.business_group_id IS NULL
  AND trunc(sysdate) BETWEEN fff.effective_start_date AND fff.effective_end_date
  AND fff.formula_name = 'TEMPLATE_' || p_budget_type;
  --
  -- The customer formula is called 'GLOBAL_BUDGET_<budget type>'
  --
  CURSOR global_formula_csr IS
  SELECT fff.formula_id
  FROM   ff_formulas_f fff
  WHERE  fff.formula_type_id = g_formula_type_id
  AND    fff.business_group_id = 0
  AND    trunc(sysdate) BETWEEN fff.effective_start_date AND fff.effective_end_date
  AND    fff.formula_name = 'GLOBAL_BUDGET_' || p_budget_type;
  --
  l_temp_formula_id     NUMBER;  -- Variable to hold retrieved formula id
  --
BEGIN
  --
  -- Try and retrieve a customer formula
  --
  OPEN customer_formula_csr;
  FETCH customer_formula_csr INTO l_temp_formula_id;
  CLOSE customer_formula_csr;
  --
  IF l_temp_formula_id is not null THEN
    --
    dbg('Using BUDGET_'||p_budget_type||' for bg = '||p_business_group_id);
    --
    RETURN l_temp_formula_id;
    --
  END IF;
  --
  -- 4273256 Customers can define a single formula for all business group
  -- This formulas should be defined in the setup businesss group
  -- and will only be invoked when the BUDGET formula is not defined
  -- If no customer formula exists try the global formula defined in setup bg
  --
  OPEN  global_formula_csr;
  FETCH global_formula_csr INTO l_temp_formula_id;
  CLOSE global_formula_csr;
  --
  IF l_temp_formula_id is not null THEN
    --
    dbg('Using GLOBAL_BUDGET_'||p_budget_type||' formulas for bg = '||p_business_group_id);
    --
    RETURN l_temp_formula_id;
    --
  END IF;
  --
  -- If no global formula exists try the template formula
  --
  OPEN template_formula_csr;
  FETCH template_formula_csr INTO l_temp_formula_id;
  CLOSE template_formula_csr;
  --
  dbg('Using TEMPLATE_'||p_budget_type||' formulas for bg = '||p_business_group_id);
  --
  RETURN l_temp_formula_id;
  --
END fetch_formula_id;

/******************************************************************************/
/* This returns the assignment budget value of an applicant given their       */
/* assignment, the vacancy they are applying for, the effective date          */
/* the budget measurement type (BMT) and the applicant's business group       */
/*                                                                            */
/* Firstly the actual assignment budget value table is checked                */
/* Then the fast formula associated with the business group and BMT is run    */
/******************************************************************************/
FUNCTION calc_abv(p_assignment_id     IN NUMBER,
                  p_business_group_id IN NUMBER,
                  p_budget_type       IN VARCHAR2,
                  p_effective_date    IN DATE,
                  p_primary_flag      IN VARCHAR2 := NULL,
                  p_run_formula       IN VARCHAR2 := NULL)
RETURN NUMBER IS
  --
  l_return_value    NUMBER := to_number(null);  -- Keeps the ABV to be returned
  l_formula_id      NUMBER;                 -- Id of the Fast Formula to be run
  l_inputs          ff_exec.inputs_t;
  l_outputs         ff_exec.outputs_t;
  --
  -- Selects applicant's assignment budget value from the ABV table for a given
  -- budget_measurement type (if it exists)
  --
  CURSOR applicant_csr IS
  SELECT abv.value
  FROM   per_assignment_budget_values_f abv
  WHERE  abv.assignment_id = p_assignment_id
  AND    abv.unit = p_budget_type
  AND    p_effective_date BETWEEN abv.effective_start_date
                          AND abv.effective_end_date;
  --
BEGIN
  --
  IF (p_run_formula IS NULL) THEN
    --
    -- Try and find an ABV in the ABV table
    --
    OPEN applicant_csr;
    FETCH applicant_csr INTO l_return_value;
    CLOSE applicant_csr;
    --
  END IF;
  --
  -- If no ABV was found then get a fast formula
  --
  IF l_return_value IS NULL THEN
    --
    -- Split out by p_budget_type to make use of stored formula ids
    --
    IF (p_budget_type='HEAD') THEN
      --
      ----------------------------------------------------------------------------
      -- Check stored table for formula id of formula to run.
      --
      --   - If a record has not yet been stored for the business group then
      --     a "NO_DATA_FOUND" error is automatically raised.
      --
      --   - If a record has been stored for the business group, but not for
      --     the head_formula_id, then the same error is raised when
      --     head_formula_id shows as NULL.
      --
      -- In the error handling section the formula id is retrieved and stored
      -- in the temporary. The use of the EXCEPTION section in this way
      -- requires an enclosed PL/SQL block to trap any unforseen errors which
      -- may occur within the EXCEPTION section.
      ----------------------------------------------------------------------------
      --
      BEGIN
        --
        -- If value exists in global temporary table
        -- Note that if no entry exists in g_formula_ids for p_business_group
        -- then a NO_DATA_FOUND error will automatically be raised when it is
        -- referenced
        --
        IF (g_formula_ids(p_business_group_id).head_formula_id IS NOT NULL) THEN
          --
          -- Use the stored value
          --
          l_formula_id := g_formula_ids(p_business_group_id).head_formula_id;
          --
        ELSE
          --
          -- fte_formula_id stored for p_business_group, but head_formula_id
          -- is not
          --
          RAISE NO_DATA_FOUND;
          --
        END IF;
        --
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          --
          -- Value not already stored
          -- Fetch formula id for the business group and budget type
          --
          l_formula_id := fetch_formula_id(p_business_group_id,p_budget_type);
          --
          -- Store it in the temporary table for future use
          --
          g_formula_ids(p_business_group_id).head_formula_id := l_formula_id;
          --
      END;
    ----------------------------------------------------------------------------
    ELSIF (p_budget_type='FTE') THEN
      --
      -- Check temporary table
      --
      --------------------------------------------------------------------------
      -- As above, but for the fte_formula_id
      --------------------------------------------------------------------------
      BEGIN
        --
        -- If value exists in global temporary table
        -- Note that if no entry exists in g_formula_ids for p_business_group
        -- then a NO_DATA_FOUND error will automatically be raised when it is
        -- referenced
        --
        IF (g_formula_ids(p_business_group_id).fte_formula_id IS NOT NULL) THEN
          --
          -- Use the stored value
          --
          l_formula_id := g_formula_ids(p_business_group_id).fte_formula_id;
          --
        ELSE
          --
          -- head_formula_id stored for p_business_group, but fte_formula_id
          -- is not
          --
          RAISE NO_DATA_FOUND;
          --
        END IF;
        --
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          --
          -- Value not already stored
          -- Fetch formula id for the business group and budget type
          --
          l_formula_id := fetch_formula_id(p_business_group_id,p_budget_type);
          --
          -- Store it in the temporary table for future use
          --
          g_formula_ids(p_business_group_id).fte_formula_id := l_formula_id;
          --
      END;
    ----------------------------------------------------------------------------
    ELSE
      --
      -- Budget type is not 'HEAD' or 'FTE' so no formula id for this
      -- budget type is held in the temporary table
      -- Fetch formula id for the business group and budget type
      --
      l_formula_id := fetch_formula_id(p_budget_type,p_business_group_id);
      --
    END IF;
    --
    -- If the fast formula does not exist then raise an error
    --
    IF (l_formula_id IS NULL) THEN
      --
      raise_ff_not_exist( p_budget_type );
      --
    END IF;
    --
    -- If the formula to run is TEMPLATE_HEAD and primary flag has been passed
    -- then don't run the formula
    --
    IF (l_formula_id  = g_template_head_id AND
        p_budget_type = 'HEAD' AND
        p_primary_flag IS NOT NULL)
    THEN
      --
      IF (p_primary_flag = 'Y') THEN
        l_return_value := 1;
      ELSE
        l_return_value := 0;
      END IF;
      --
    ELSE
      --
      -- Initialise the Inputs and  Outputs tables
      --
      FF_Exec.Init_Formula
        ( l_formula_id
        , SYSDATE
        , l_inputs
        , l_outputs );
      --
      IF (l_inputs.first IS NOT NULL AND l_inputs.last IS NOT NULL)
      THEN
        --
        -- Set up context values for the formula
        --
        FOR i IN l_inputs.first..l_inputs.last LOOP
          --
          IF l_inputs(i).name = 'DATE_EARNED' THEN
            l_inputs(i).value := FND_Date.Date_To_Canonical (p_effective_date);
          ELSIF l_inputs(i).name = 'ASSIGNMENT_ID' THEN
            l_inputs(i).value := p_assignment_id;
          END IF;
          --
        END LOOP;
        --
      END IF;
      --
      -- Run the formula
      --
      FF_Exec.Run_Formula (l_inputs, l_outputs);
      --
      -- Get the result
      --
      l_return_value := FND_NUMBER.canonical_to_number( l_outputs(l_outputs.first).value );
      --
    END IF;
    --
  END IF;
  --
  RETURN l_return_value;
  --
EXCEPTION
  --
  -- Normally due to Fast Formula not being compiled
  --
  WHEN OTHERS THEN
    --
    raise_ff_not_compiled( l_formula_id );
    --
END calc_abv;
/******************************************************************************/
/* The CheckFastFormulaCompiled procedure should be called from the "Before   */
/* Report Trigger" of a report in all reports which use a fast formula.  It   */
/* checks if the fast formula exists and whether it is compiled. If not, then */
/* it raises the appropriate exception for the report trigger to catch and    */
/* display.                                                                   */
/******************************************************************************/

/******************************************************************************/
/* Procedure to raise an exception if a fast formula does not exist           */
/******************************************************************************/
PROCEDURE raise_ff_not_exist(p_bgttyp IN VARCHAR2)
IS
BEGIN

  Fnd_Message.Set_Name('HRI', 'HR_BIS_FF_NOT_EXIST');

  RAISE ff_not_exist;

END raise_ff_not_exist;

/******************************************************************************/
/* Procedure to raise an exception if a fast formula is not compiled          */
/******************************************************************************/
PROCEDURE raise_ff_not_compiled( p_formula_id  IN NUMBER)
IS

  CURSOR fast_formula_csr IS
  SELECT formula_name
  FROM ff_formulas_f
  WHERE formula_id = p_formula_id;

  l_formula_name    ff_formulas_f.formula_name%TYPE := NULL;

BEGIN

/* Get the formula name */
  BEGIN

  /* Try the cache - if there's nothing there then an exception is raised */
    l_formula_name := g_formula_names_tab(p_formula_id);

  EXCEPTION
    WHEN OTHERS THEN

  /* If nothing's in the cache, get the formula name from the cursor */
    OPEN  fast_formula_csr;
    FETCH fast_formula_csr INTO l_formula_name;
    CLOSE fast_formula_csr;

  /* Store the name retrieved in the cache for future use */
    g_formula_names_tab(p_formula_id) := l_formula_name;

  END;

  Fnd_Message.Set_Name('HRI', 'HR_BIS_FF_NOT_COMPILED');
  Fnd_Message.Set_Token('FORMULA', l_formula_name, FALSE);

  RAISE ff_not_compiled;

END raise_ff_not_compiled;

/******************************************************************************/
/* Procedure to checks if a fast formula exists and whether it is compiled    */
/******************************************************************************/
PROCEDURE check_ff_name_compiled( p_formula_name     IN VARCHAR2) IS

  CURSOR compiled_csr IS
  SELECT fci.formula_id
  FROM ff_compiled_info_f   fci
  ,ff_formulas_f            fff
  WHERE fci.formula_id = fff.formula_id
  AND fff.formula_type_id = g_formula_type_id
  AND fff.formula_name = p_formula_name
  AND trunc(sysdate) BETWEEN fff.effective_start_date AND fff.effective_end_date
  AND trunc(sysdate) BETWEEN fci.effective_start_date AND fci.effective_end_date;

  l_formula_id   ff_compiled_info_f.formula_id%TYPE := NULL;

BEGIN

  OPEN compiled_csr;
  FETCH compiled_csr INTO l_formula_id;
  CLOSE compiled_csr;

  IF (l_formula_id IS NULL) THEN

    Fnd_Message.Set_Name('HRI', 'HR_BIS_FF_NOT_COMPILED');
    Fnd_Message.Set_Token('FORMULA', p_formula_name, FALSE);
    RAISE ff_not_compiled;

  END IF;

END check_ff_name_compiled;

PROCEDURE CheckFastFormulaCompiled(p_formula_id  IN NUMBER,
                                   p_bgttyp      IN VARCHAR2)
IS

  CURSOR fast_formula_compiled_csr IS
  SELECT formula_id
  FROM   ff_compiled_info_f
  WHERE  formula_id = p_formula_id;

  l_formula_id   ff_compiled_info_f.formula_id%TYPE := NULL;

BEGIN

  IF p_formula_id IS NULL THEN
    raise_ff_not_exist( p_bgttyp );
  END IF;

  OPEN fast_formula_compiled_csr;
  FETCH fast_formula_compiled_csr INTO l_formula_id;
  CLOSE fast_formula_compiled_csr;

  IF l_formula_id IS NULL THEN
    raise_ff_not_compiled( p_formula_id );
  END IF;

END CheckFastFormulaCompiled;

BEGIN

  SELECT formula_type_id INTO g_formula_type_id
  FROM ff_formula_types
  WHERE formula_type_name = 'QuickPaint';

  SELECT formula_id INTO g_template_head_id
  FROM ff_formulas_f
  WHERE formula_type_id = g_formula_type_id
  AND formula_name = 'TEMPLATE_HEAD'
  AND business_group_id IS NULL
  AND trunc(sysdate) BETWEEN effective_start_date AND effective_end_date;

END hri_bpl_abv;

/
