--------------------------------------------------------
--  DDL for Package Body HRI_BPL_JOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_JOB" AS
/* $Header: hribjob.pkb 120.1 2005/08/09 03:45:48 jtitmas noship $ */

TYPE g_varchar80_tabtype  IS TABLE OF VARCHAR2(80)  INDEX BY BINARY_INTEGER;
TYPE g_varchar400_tabtype IS TABLE OF VARCHAR2(400) INDEX BY BINARY_INTEGER;

/* Table of job display name segment formats by business group */
g_bg_segment_value        g_varchar400_tabtype;

/* Table of product/job associations */
g_prod_cat_table          g_varchar80_tabtype;
g_prod_cat_segment        VARCHAR2(30);

g_job_role_ff_id            NUMBER;
c_job_role_ff_name CONSTANT VARCHAR2(30):= 'HRI_MAP_JOB_JOB_ROLE';


/* Type of caching record to store the output of fast formula,       */
/* By using the outputs in this records, the number of fast formula  */
/* calls will reduce                                                 */

TYPE ff_output_rec IS RECORD
    (job_role_code       VARCHAR2(240)
     );

TYPE g_ff_ouptut_tab_type IS TABLE OF ff_output_rec INDEX BY VARCHAR2(480);

g_job_role_cache           g_ff_ouptut_tab_type;

/******************************************************************************/
/*                 PUBLIC Functions and Procedures                            */
/******************************************************************************/


/******************************************************************************/
/* HRI Job Categories consists of a number of member (lookups) for the set    */
/* plus one lookup if a job does not match any of the set (other). The single */
/* (other) lookup is identified by the member lookup column holding NULL.     */
/*                                                                            */
/* Add_job_category inserts a row if it does not already exist, but updates   */
/* the other lookup row if it exists already and is different.                */
/******************************************************************************/
PROCEDURE add_job_category( p_job_cat_set     IN NUMBER,
                            p_job_cat_lookup  IN VARCHAR2 := null,
                            p_other_lookup    IN VARCHAR2 := null )
IS

  l_other_lookup   VARCHAR2(30);  -- Holds other lookup if it already exists

/* Selects the other lookup column from a row if it exists */
  CURSOR row_exists_cur IS
  SELECT other_lookup_code FROM hri_job_category_sets
  WHERE job_category_set = p_job_cat_set
  AND (member_lookup_code = p_job_cat_lookup
    OR member_lookup_code IS NULL and p_job_cat_lookup IS NULL);

BEGIN

/* Check that primary key is valid - the job category set is within range */
/* and one (and only one) of the lookups must be populated */
  IF (p_job_cat_lookup IS NULL AND p_other_lookup IS NULL) THEN
    RETURN;
  ELSIF (p_job_cat_lookup IS NOT NULL AND p_other_lookup IS NOT NULL) THEN
    RETURN;
  ELSIF (p_job_cat_set < 1 OR p_job_cat_set > 15) THEN
    RETURN;
  END IF;

/* See if a row already exists */
  OPEN row_exists_cur;
  FETCH row_exists_cur INTO l_other_lookup;
  IF (row_exists_cur%NOTFOUND OR row_exists_cur%NOTFOUND IS NULL) THEN
  /* If row does not exist, insert it */
    INSERT INTO hri_job_category_sets
      ( job_category_set
      , member_lookup_code
      , other_lookup_code )
      VALUES
        ( p_job_cat_set
        , p_job_cat_lookup
        , p_other_lookup );
  ELSIF (l_other_lookup <> p_other_lookup AND p_other_lookup IS NOT NULL) THEN
  /* If the other row exists, update it if it is different */
    UPDATE hri_job_category_sets
    SET other_lookup_code = p_other_lookup
    WHERE job_category_set = p_job_cat_set
    AND member_lookup_code IS NULL;
  END IF;
  CLOSE row_exists_cur;

END add_job_category;

/******************************************************************************/
/* Removes given job category by blanket delete                               */
/******************************************************************************/
PROCEDURE remove_job_category( p_job_cat_set     IN NUMBER,
                               p_job_cat_lookup  IN VARCHAR2 := null,
                               p_other_lookup    IN VARCHAR2 := null )
IS

BEGIN

/* Remove row if it exists */
  DELETE FROM hri_job_category_sets
  WHERE job_category_set = p_job_cat_set
  AND (member_lookup_code = p_job_cat_lookup
    OR other_lookup_code = p_other_lookup);

END remove_job_category;

/******************************************************************************/
/* This procedure is called by FNDLOAD via the tempalte hrijcts.lct           */
/* Load row simply calls the update procedure                                 */
/******************************************************************************/
PROCEDURE load_row( p_job_cat_set     IN NUMBER,
                    p_job_cat_lookup  IN VARCHAR2,
                    p_other_lookup    IN VARCHAR2,
                    p_owner           IN VARCHAR2 )
IS

BEGIN

/* Call to add_job_category includes the update functionality required */
  add_job_category(p_job_cat_set, p_job_cat_lookup, p_other_lookup);

END load_row;


/******************************************************************************/
/* Caches the job segment which stores product category                       */
/******************************************************************************/
PROCEDURE cache_prod_cat_segment IS

  CURSOR prod_cat_segment_csr IS
  SELECT bfm.application_column_name
  FROM bis_flex_mappings_v bfm
     , bis_dimensions_vl bd
  WHERE bfm.dimension_id = bd.dimension_id
  AND bd.short_name = 'PRODUCT'
  AND bfm.level_short_name = 'PRODUCT GROUP'
  AND bfm.application_id = 800;

BEGIN

  OPEN prod_cat_segment_csr;
  FETCH prod_cat_segment_csr INTO g_prod_cat_segment;
  CLOSE prod_cat_segment_csr;

  IF (g_prod_cat_segment IS NULL) THEN
    g_prod_cat_segment := 'NA_EDW';
  END IF;

END cache_prod_cat_segment;


/******************************************************************************/
/* Finds the product category for a given job                                 */
/******************************************************************************/
FUNCTION lookup_product_category( p_job_id     IN NUMBER )
     RETURN VARCHAR2 IS

  TYPE prod_cat_csr_type IS REF CURSOR;
  prod_cat_cv   prod_cat_csr_type;

  csr_sql_stmt   VARCHAR2(200);
  l_product_category     VARCHAR2(80);

BEGIN

/* Cache product category segment */
  IF (g_prod_cat_segment IS NULL) THEN
    cache_prod_cat_segment;
  END IF;

  IF (g_prod_cat_segment <> 'NA_EDW') THEN

    BEGIN
      l_product_category := g_prod_cat_table(p_job_id);
    EXCEPTION WHEN OTHERS THEN
      csr_sql_stmt := 'SELECT pct.value ' ||
                      'FROM bis_product_categories_v  pct, per_jobs job ' ||
                      'WHERE job.job_id = :1 ' ||
                      'AND pct.id = job.' || g_prod_cat_segment;
      OPEN prod_cat_cv FOR csr_sql_stmt USING p_job_id;
      LOOP
        FETCH prod_cat_cv INTO l_product_category;
        EXIT WHEN prod_cat_cv%NOTFOUND;
      END LOOP;
      CLOSE prod_cat_cv;
      g_prod_cat_table(p_job_id) := l_product_category;
    END;
  END IF;

  RETURN l_product_category;

END lookup_product_category;


/******************************************************************************/
/* Returns the configurable display format to use for a job name              */
/******************************************************************************/
FUNCTION get_job_display_name(p_job_id             IN NUMBER,
                              p_business_group_id  IN NUMBER,
                              p_job_name           IN VARCHAR2)
            RETURN VARCHAR2 IS

  l_return_value     VARCHAR2(240);

BEGIN

/* Check parameters are passed in correctly */
  IF (p_business_group_id IS NOT NULL AND
      p_job_id IS NOT NULL AND
      p_job_name IS NOT NULL) THEN

  /* Trap NO_DATA_FOUND exceptions when accessing global table */
    BEGIN
    /* Re-use cached segment format if possible */
      IF (g_bg_segment_value(p_business_group_id) IS NOT NULL) THEN
        l_return_value := hr_misc_web.get_user_defined_job_segments
                              (p_job_segments => g_bg_segment_value(p_business_group_id)
                              ,p_job_name => p_job_name
                              ,p_job_id => p_job_id);
      END IF;
    EXCEPTION WHEN OTHERS THEN
    /* Calculate segment format for business group */
      g_bg_segment_value(p_business_group_id) :=
                     hr_misc_web.get_sshr_segment_value
                            (p_bg_id => p_business_group_id,
                             p_user_column_name => 'Display MEE Job Segments');
    /* If a value is found use it */
      IF (g_bg_segment_value(p_business_group_id) IS NOT NULL) THEN
        l_return_value := hr_misc_web.get_user_defined_job_segments
                              (p_job_segments => g_bg_segment_value(p_business_group_id)
                              ,p_job_name => p_job_name
                              ,p_job_id => p_job_id);
      END IF;
    END;

  END IF;

/* If no display format is found return the job name */
  RETURN NVL(l_return_value, p_job_name);

END get_job_display_name;
--
-- -----------------------------------------------------------------------------
-- Inserts row into concurrent program log
-- -----------------------------------------------------------------------------
--
PROCEDURE output(p_text  VARCHAR2) IS
--
BEGIN
  --
  HRI_BPL_CONC_LOG.output(p_text);
  --
END output;
-- -----------------------------------------------------------------------------
-- Inserts row into concurrent program log if debugging is enabled
-- -----------------------------------------------------------------------------
--
PROCEDURE dbg(p_text  VARCHAR2) IS
--
BEGIN
  --
  HRI_BPL_CONC_LOG.dbg(p_text);
  --
END dbg;
--
-- -------------------------------------------------------------------------
-- Checks that the fast formula exist in the proper business group and
-- is compiled
-- -------------------------------------------------------------------------
--
FUNCTION ff_exists_and_compiled(p_business_group_id     IN NUMBER
			       ,p_date                  IN DATE
			       ,p_ff_name               IN VARCHAR2)
RETURN NUMBER
IS
  --
  -- Cursor to fetch job role fast formula
  --
  CURSOR c_job_role_formula IS
  SELECT fff.formula_id
  FROM
   ff_formulas_f fff
  ,ff_formula_types  fft
  WHERE fft.formula_type_name = 'QuickPaint'
  AND fff.formula_type_id = fft.formula_type_id
  AND fff.business_group_id = p_business_group_id
  AND p_date BETWEEN fff.effective_start_date AND fff.effective_end_date
  AND fff.formula_name = p_ff_name;
  --
  l_ff_id NUMBER;
  --
BEGIN
  --
  -- Check if the fast formula exists
  --
  OPEN  c_job_role_formula;
  FETCH c_job_role_formula INTO l_ff_id;
  CLOSE c_job_role_formula;
  --
  -- If the fast formula is not available then return null
  --
  IF l_ff_id IS NULL THEN
    --
    RETURN NULL;
    --
  END IF;
  --
  hri_bpl_abv.CheckFastFormulaCompiled(p_formula_id  => l_ff_id,
                                       p_bgttyp      => p_business_group_id);
  --
  -- If no exception is raised then return the fast formula
  --
  RETURN l_ff_id;
  --
EXCEPTION
  --
  -- Handling the case when the fast formula is not compiled
  --
  WHEN hri_bpl_abv.ff_not_compiled THEN
    --
    RAISE;
    --
END ff_exists_and_compiled;

-- -----------------------------------------------------------------------
-- Function returning the id of the fast formula
-- -----------------------------------------------------------------------

FUNCTION get_job_role_ff_id
RETURN NUMBER
IS
--
BEGIN
  --
  -- Check if the formula_id is already cached
  --
  IF g_job_role_ff_id IS NULL THEN
      g_job_role_ff_id := ff_exists_and_compiled
                            (p_business_group_id   => 0
                            ,p_date                => trunc(SYSDATE)
                            ,p_ff_name             => c_job_role_ff_name
                            );
    --
    IF (g_job_role_ff_id IS NULL) AND (g_warning_flag = 'N') THEN
      --
      g_warning_flag := 'Y';
      --
      output('The fast formula' || ' ' || c_job_role_ff_name || ' ' || 'is not defined in business_group_id = 0');
      --
      RETURN g_job_role_ff_id;
      --
    END IF;
    --
  END IF;
  --
  RETURN g_job_role_ff_id;
  --
END get_job_role_ff_id;
--
-- ---------------------------------------------------------------------------
--  Run the job role rule by calling the fast formula
-- ---------------------------------------------------------------------------

PROCEDURE run_job_role_rule
  (p_business_group_id  IN         NUMBER
  ,p_job_fmly_code      IN         VARCHAR2
  ,p_job_fnctn_code     IN         VARCHAR2
  ,p_job_role_code      OUT NOCOPY VARCHAR2
  )
IS
  --
  l_ff_id        NUMBER;
  l_job_code     VARCHAR2(480);
  l_inputs       FF_EXEC.INPUTS_T;
  l_outputs      FF_EXEC.OUTPUTS_T;
  l_bg_name      PER_BUSINESS_GROUPS.NAME%TYPE;
  --
  CURSOR c_bg_name IS
  SELECT name
  FROM   per_business_groups
  WHERE  business_group_id = p_business_group_id;
  --
BEGIN
  --
  -- Identify the formula to be executed
  --
  l_ff_id := get_job_role_ff_id;
  --
  -- In case a formula is not defined then return 'NA_EDW'
  --
  IF l_ff_id IS NULL THEN
    --
    p_job_role_code := 'NA_EDW';
    --
    RETURN;
    --
  --
  END IF;
  --
  -- If the job role for the specified combination of job_function and job
  -- family is available in the cache, then return the value stored in the
  -- cache instead of calling fast formula
  --
  BEGIN
    --
    l_job_code := p_job_fmly_code || p_job_fnctn_code;
    --
    p_job_role_code := g_job_role_cache(l_job_code).job_role_code;
    --
    RETURN;
    --
  EXCEPTION
    --
    WHEN OTHERS THEN
    --
    NULL;
    --
  END;
    --
    -- Initialize the formula input and output tables */
    --
     FF_Exec.Init_Formula
       (l_ff_id
        ,SYSDATE
        ,l_inputs
        ,l_outputs
        );
    --
    -- Set the input values
    --
    IF l_inputs.count > 0 THEN
      --
      FOR l_loop_count IN l_inputs.FIRST..l_inputs.LAST LOOP
        --
        -- CODE the inputs here
        --
        IF l_inputs(l_loop_count).name = 'DATE_EARNED' THEN
            l_inputs(l_loop_count).value := fnd_date.date_to_canonical(SYSDATE);
        ELSIF upper(l_inputs(l_loop_count).name) = 'ASSIGNMENT_ID' THEN
            l_inputs(l_loop_count).value := -1;
        ELSIF upper(l_inputs(l_loop_count).name) = 'JOB_FAMILY_CODE' THEN
            l_inputs(l_loop_count).value := p_job_fmly_code;
        ELSIF upper(l_inputs(l_loop_count).name) = 'JOB_FUNCTION_CODE' THEN
            l_inputs(l_loop_count).value := p_job_fnctn_code;
        ELSIF upper(l_inputs(l_loop_count).name) = 'BUSINESS_GROUP_NAME' THEN
          --
          OPEN  c_bg_name;
          FETCH c_bg_name into l_bg_name;
          CLOSE c_bg_name;
          --
          l_inputs(l_loop_count).value := l_bg_name;
          --
        END IF;

        --
      END LOOP;
      --
    END IF;
    --
    -- Run the fast formula
    --
    FF_Exec.Run_Formula
      (l_inputs
      ,l_outputs
       );
    --
    -- Get the output from the fast formula
    --
    IF l_outputs.count > 0 THEN
      --
      FOR l_loop_count IN l_outputs.FIRST..l_outputs.LAST LOOP
        --
        -- CODE the outputs here
        --
        IF upper(l_outputs(l_loop_count).name) = 'JOB_ROLE_CODE' THEN
          --
          p_job_role_code := l_outputs(l_loop_count).value;
          --
        END IF;
        --
        IF hr_api.not_exists_in_hr_lookups
             (p_lookup_type => 'HRI_CL_JOB_ROLE'
             ,p_lookup_code => p_job_role_code
             ,p_effective_date => SYSDATE) AND p_job_role_code <> 'NA_EDW'
        THEN
          --
          g_warning_flag := 'Y';

          --
          output('The lookup does not contain the job role code' || ' ' || p_job_role_code );
          --
        END IF;
      END LOOP;
      --
    END IF;
    --
    -- Store the values in cache
    --
    l_job_code := p_job_fmly_code || p_job_fnctn_code;
    --
    g_job_role_cache(l_job_code).job_role_code := NVL(p_job_role_code, 'NA_EDW');
    --
END run_job_role_rule;

-- -------------------------------------------------------------------------
-- Function retuning the job role code
-- -------------------------------------------------------------------------

FUNCTION get_job_role_code(p_job_fmly_code   IN VARCHAR,
                           p_job_fnctn_code  IN VARCHAR2)
RETURN VARCHAR2
IS
  --
  l_job_role_code VARCHAR2(240);
  --
BEGIN
  --
  -- Call to run the fast formula in order to get the job role code
  --
  run_job_role_rule
    (p_business_group_id => 0
    ,p_job_fmly_code     => p_job_fmly_code
    ,p_job_fnctn_code    => p_job_fnctn_code
    ,p_job_role_code     => l_job_role_code
     );
  --
  RETURN l_job_role_code;
  --
END get_job_role_code;
--

END hri_bpl_job;

/
