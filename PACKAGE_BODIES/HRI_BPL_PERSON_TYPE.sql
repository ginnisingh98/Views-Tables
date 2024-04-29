--------------------------------------------------------
--  DDL for Package Body HRI_BPL_PERSON_TYPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_PERSON_TYPE" AS
/* $Header: hribptu.pkb 120.3 2005/08/23 05:57:14 jtitmas noship $ */

-- DBI person type categorization
TYPE g_wkth_cat_rec_type IS RECORD
 (wkth_wktyp_sk_fk   VARCHAR2(240)
 ,wkth_lvl1_sk_fk    VARCHAR2(240)
 ,wkth_lvl2_sk_fk    VARCHAR2(240)
 ,wkth_wktyp_code    VARCHAR2(240)
 ,wkth_lvl1_code     VARCHAR2(240)
 ,wkth_lvl2_code     VARCHAR2(240)
 ,include_flag       VARCHAR2(30));

TYPE g_wkth_base_rec_type IS RECORD
 (person_type_id       NUMBER
 ,system_person_type   VARCHAR2(30)
 ,user_person_type     VARCHAR2(240)
 ,business_group_id    NUMBER
 ,primary_flag         VARCHAR2(30)
 ,employment_category  VARCHAR2(30)
 ,assignment_type      VARCHAR2(30));

TYPE g_number_tab_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

TYPE g_varchar240_tab_type IS TABLE OF NUMBER INDEX BY VARCHAR2(240);

TYPE g_wkth_cat_tab_type IS TABLE OF g_wkth_cat_rec_type INDEX BY BINARY_INTEGER;

-- Cache tables for DBI person type dimension
g_cache_wkth_base_rec   g_wkth_base_rec_type;
g_cache_wkth_cat_rec    g_wkth_cat_rec_type;
g_cache_formula_ids     g_number_tab_type;
g_cache_prsntyp_sk      g_varchar240_tab_type;
g_cache_wkth_values     g_wkth_cat_tab_type;

-- globals to cache the person type information for performance.
g_user_person_type per_person_types_tl.user_person_type%type;
g_person_id per_all_people_f.person_id%type;
g_effective_date date;
g_EMP_person_type     per_person_types_tl.user_person_type%type;
g_CWK_person_type     per_person_types_tl.user_person_type%type;
g_APL_person_type     per_person_types_tl.user_person_type%type;
g_EXEMP_person_type  per_person_types_tl.user_person_type%type;
g_EXCWK_person_type  per_person_types_tl.user_person_type%type;
g_EXAPL_person_type  per_person_types_tl.user_person_type%type;
g_OTHER_person_type  per_person_types_tl.user_person_type%type;
g_CONCAT_person_type  varchar2(4000);

-- constants.
c_separator varchar2(1) := '.';
--
-- -----------------------------------------------------------------------------
-- Global Variables required by invoking the CATEGORIZE_PERSON_TYPE fast formula
-- -----------------------------------------------------------------------------
--
-- Global Parameter for caching setup business group id
--
g_debug_flag                     VARCHAR2(1) := NVL(fnd_profile.value('HRI_ENBL_DTL_LOG'),'N');
g_concurrent_flag                VARCHAR2(1);
g_review_ff_id                   NUMBER;
c_prsn_type_ff_name  CONSTANT    VARCHAR2(30) := 'CATEGORIZE_PERSON_TYPE';
--
-- Type of caching record to store the output of fast formula,
-- By using the outputs in this records, the number of fast formula
-- calls will reduce
--
TYPE ff_output_rec IS RECORD
    (used_for_summarization       VARCHAR2(30)
    ,person_type_category         VARCHAR2(30));
--
TYPE g_ff_ouptut_tab_type IS TABLE OF ff_output_rec INDEX BY BINARY_INTEGER;
--
g_per_typ_cache                    g_ff_ouptut_tab_type;
--
-- -----------------------------------------------------------------------------
--
PROCEDURE UPDATE_PERSON_TYPE_GLOBALS(
            p_effective_date              IN    DATE
           ,p_person_id                   IN    NUMBER)
IS

  -- bug 2820666, added support for 'CWK' segments in person type.
  CURSOR csr_person_types
  IS
    SELECT  ttl.user_person_type
           ,DECODE(typ.system_person_type
                    ,'EMP'  ,1
                    ,'CWK'  ,2
                    ,'APL'  ,3
                    ,'EX_EMP',4
                    ,'EX_CWK',5
                    ,'EX_APL',6
                             ,7) order_by
           ,DECODE(typ.system_person_type
                    ,'EMP'
                    ,ttl.user_person_type
                    ,NULL ) EMP_PERSON_TYPE
           ,DECODE(typ.system_person_type
                    ,'CWK'
                    ,ttl.user_person_type
                    ,NULL ) CWK_PERSON_TYPE
           ,DECODE(typ.system_person_type
                    ,'APL'
                    ,ttl.user_person_type
                    ,NULL ) APL_PERSON_TYPE
           ,DECODE(typ.system_person_type
                    ,'EX_EMP'
                    ,ttl.user_person_type
                    ,NULL ) EXEMP_PERSON_TYPE
           ,DECODE(typ.system_person_type
                    ,'EX_CWK'
                    ,ttl.user_person_type
                    ,NULL ) EXCWK_PERSON_TYPE
           ,DECODE(typ.system_person_type
                    ,'EX_APL'
                    ,ttl.user_person_type
                    ,NULL ) EXAPL_PERSON_TYPE
           ,DECODE(typ.system_person_type
                    ,'OTHER'
                    ,ttl.user_person_type
                    ,NULL ) OTHER_PERSON_TYPE
      FROM per_person_types_tl ttl
          ,per_person_types typ
          ,per_person_type_usages_f ptu
    WHERE ttl.language = userenv('LANG')
      AND ttl.person_type_id = typ.person_type_id
      AND typ.system_person_type IN ('APL','EMP','EX_APL','EX_EMP','CWK','EX_CWK','OTHER')
      AND typ.person_type_id = ptu.person_type_id
      AND p_effective_date BETWEEN ptu.effective_start_date
                                AND ptu.effective_end_date
      AND ptu.person_id = p_person_id
  ORDER BY DECODE(typ.system_person_type
                 ,'EMP'   ,1
                 ,'CWK'   ,2
                 ,'APL'   ,3
                 ,'EX_EMP',4
                 ,'EX_CWK',5
                 ,'EX_APL',6
                          ,7
                 );

  l_user_concat_person_type  varchar2(4000);

BEGIN

    FOR l_user_person_rec in csr_person_types
    LOOP
        IF (l_user_concat_person_type IS NULL)
        THEN
          l_user_concat_person_type := l_user_person_rec.user_person_type;

          -- update the global individual person type segements.
          g_emp_person_type    := l_user_person_rec.EMP_PERSON_TYPE;
          g_exemp_person_type  := l_user_person_rec.EXEMP_PERSON_TYPE;
          g_apl_person_type    := l_user_person_rec.APL_PERSON_TYPE;
          g_exapl_person_type  := l_user_person_rec.EXAPL_PERSON_TYPE;
          g_cwk_person_type    := l_user_person_rec.CWK_PERSON_TYPE;
          g_excwk_person_type  := l_user_person_rec.EXCWK_PERSON_TYPE;

        ELSE

          IF g_exemp_person_type IS NULL THEN
            g_exemp_person_type := l_user_person_rec.EXEMP_PERSON_TYPE;
          END IF;

          IF g_apl_person_type IS NULL THEN
            g_apl_person_type := l_user_person_rec.APL_PERSON_TYPE;
          END IF;

          IF g_exapl_person_type IS NULL THEN
            g_exapl_person_type := l_user_person_rec.EXAPL_PERSON_TYPE;
          END IF;

          -- append the person types to the concatenated string.
          begin
          l_user_concat_person_type := l_user_concat_person_type
                             || c_separator
                             || l_user_person_rec.user_person_type;
          exception
              when others then
		l_user_concat_person_type := '';
          end;

        END IF;
      END LOOP;

      -- update the cache.
      g_concat_person_type := l_user_concat_person_type;
      g_effective_date   := p_effective_date;
      g_person_id        := p_person_id;


END UPDATE_PERSON_TYPE_GLOBALS;



FUNCTION GET_EMP_USER_PERSON_TYPE
  (p_effective_date              IN    DATE
  ,p_person_id                   IN    NUMBER
  )
RETURN VARCHAR2
IS


BEGIN

  IF (g_person_id = p_person_id
     AND g_effective_date = p_effective_date) THEN
        -- cache hit, already have the user person types cached
        RETURN NVL(g_EMP_person_type, g_exemp_person_type);

  ELSE
      -- cache miss, get the user person type[s] from translation table.
      UPDATE_PERSON_TYPE_GLOBALS
        (p_effective_date               => p_effective_date
        ,p_person_id                    => p_person_id
        );


      RETURN NVL(g_EMP_person_type,g_exemp_person_type) ;

   END IF;

END GET_EMP_USER_PERSON_TYPE;


FUNCTION GET_APL_USER_PERSON_TYPE
  (p_effective_date              IN    DATE
  ,p_person_id                   IN    NUMBER
  )
RETURN VARCHAR2
IS


BEGIN

  IF (g_person_id = p_person_id
     AND g_effective_date = p_effective_date) THEN
        -- cache hit, already have the user person types cached
        RETURN NVL(g_APL_person_type,g_exAPL_person_type);
  ELSE
      -- cache miss, get the user person type[s] from translation table.
      UPDATE_PERSON_TYPE_GLOBALS
        (p_effective_date               => p_effective_date
        ,p_person_id                    => p_person_id
        );

      RETURN NVL(g_APL_person_type,g_exAPL_person_type);

   END IF;

END GET_APL_USER_PERSON_TYPE;

FUNCTION GET_CWK_USER_PERSON_TYPE
  (p_effective_date              IN    DATE
  ,p_person_id                   IN    NUMBER
  )
RETURN VARCHAR2
IS


BEGIN

  IF (g_person_id = p_person_id
     AND g_effective_date = p_effective_date) THEN
        -- cache hit, already have the user person types cached
        RETURN NVL(g_CWK_person_type, g_excwk_person_type);

  ELSE
      -- cache miss, get the user person type[s] from translation table.
      UPDATE_PERSON_TYPE_GLOBALS
        (p_effective_date               => p_effective_date
        ,p_person_id                    => p_person_id
        );


      RETURN NVL(g_cwk_person_type,g_excwk_person_type) ;

   END IF;

END GET_CWK_USER_PERSON_TYPE;


FUNCTION GET_CONCAT_USER_PERSON_TYPE
  (p_effective_date              IN    DATE
  ,p_person_id                   IN    NUMBER
  )
RETURN VARCHAR2
IS


BEGIN

  IF (g_person_id = p_person_id
     AND g_effective_date = p_effective_date) THEN
        -- cache hit, already have the user person types cached
        RETURN g_CONCAT_person_type;

  ELSE
      -- cache miss, get the user person type[s] from translation table.
      UPDATE_PERSON_TYPE_GLOBALS
        (p_effective_date               => p_effective_date
        ,p_person_id                    => p_person_id
        );

       RETURN g_CONCAT_person_type;

   END IF;

END GET_CONCAT_USER_PERSON_TYPE;

FUNCTION get_emp_system_type(p_effective_date       IN DATE,
                             p_person_id            IN NUMBER)
           RETURN VARCHAR2 IS

  CURSOR emp_type_csr IS
  SELECT
   ppt.system_person_type
  FROM
   per_person_types          ppt
  ,per_person_type_usages_f  ptu
  WHERE ptu.person_id = p_person_id
  AND p_effective_date
    BETWEEN ptu.effective_start_date AND ptu.effective_end_date
  AND ptu.person_type_id = ppt.person_type_id
  AND ppt.system_person_type IN ('EMP','EX_EMP')
  ORDER BY DECODE(ppt.system_person_type,'EMP',1,2);

  l_return_type        VARCHAR2(30);

BEGIN

  OPEN emp_type_csr;
  FETCH emp_type_csr INTO l_return_type;
  CLOSE emp_type_csr;

  RETURN l_return_type;

END get_emp_system_type;
--
-- -----------------------------------------------------------------------------
-- 3829100 Routines added for CATEGORIZE_PERSON_TYPE fast formula
-- -----------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------
-- Inserts row into concurrent program log
-- -----------------------------------------------------------------------------
--
PROCEDURE output(p_text  VARCHAR2) IS
--
BEGIN
  --
  -- Bug 4105868: Collection Diagnostics
  --
  HRI_BPL_CONC_LOG.output(p_text);
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
  -- Bug 4105868: Collection Diagnostics
  --
  HRI_BPL_CONC_LOG.dbg(p_text);
  --
END dbg;
--
-- -----------------------------------------------------------------------------
-- Procedure to check if the fast formula for a business group on the given date
-- exists and is compiled
-- -----------------------------------------------------------------------------
--
FUNCTION ff_exists_and_compiled(p_business_group_id     IN NUMBER
			       ,p_date                  IN DATE
			       ,p_ff_name               IN VARCHAR2)
RETURN NUMBER
IS
  --
  -- Cursor to fetch peformance rating fast formula
  --
  CURSOR c_perf_formula IS
    SELECT formula_id
    FROM   ff_formulas_f
    WHERE  business_group_id = p_business_group_id
    AND    p_date BETWEEN effective_start_date
                  AND     effective_end_date
    AND    formula_name = p_ff_name;
  --
  l_ff_id  NUMBER;
  --
BEGIN
  --
  -- Check if the fast fromula exists
  --
  OPEN c_perf_formula;
  FETCH c_perf_formula INTO l_ff_id;
  CLOSE c_perf_formula;
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
  dbg('formula id ='||l_ff_id);
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
--
-- -----------------------------------------------------------------------------
-- GET_EXCLUSION_FF
-- This function returns the fast formula_id of the formula NORMALIZE_REVIEW_RATING
-- This formula should be created in setup business group and is used for
-- determining the normalizing the rating give to a performance review
-- -----------------------------------------------------------------------------
--
FUNCTION get_person_typ_ff_id
RETURN NUMBER IS
  --
  l_message                fnd_new_messages.message_text%TYPE;
  --
BEGIN
  --
  -- Check if the formula_id is already cached, or else determine the ff_id
  -- The NORMALIZE_REVIEW_RATING formula should always be created in the Setup
  -- business group
  --
  IF g_review_ff_id is null THEN
    --
    g_review_ff_id := ff_exists_and_compiled
                              (p_business_group_id     => 0
			      ,p_date                  => trunc(SYSDATE)
			      ,p_ff_name               => c_prsn_type_ff_name);
    --
    IF g_review_ff_id IS NULL AND
       g_warning_flag IS NULL THEN
      --
      g_warning_flag := 'Y';
      --
      -- Bug 4105868: : Collection Diagnostics
      --
      fnd_message.set_name('HRI', 'HRI_407291_FF_NOT_DFND_IN_BG');
      fnd_message.set_token('FF_NAME', c_prsn_type_ff_name );
      fnd_message.set_token('PERSON_TYPE_CATEGORY'
                           ,hr_bis.bis_decode_lookup('HRI_PERSON_TYPE_CATEGORY'
                                                    ,'NA_EDW'
                                                    )
                           );
      --
      l_message := fnd_message.get;
      --
      hri_bpl_conc_log.log_process_info
              (p_msg_type      => 'WARNING'
              ,p_note          => l_message
              ,p_package_name  => 'HRI_BPL_PERSON_TYPE'
              ,p_msg_sub_group => 'GET_PERSON_TYP_FF_ID'
              ,p_sql_err_code  => SQLCODE
              ,p_msg_group     => 'BPL_PRSN_TYPE'
              );
      --
      output(l_message);
      --
      -- output('WARNING! The  fast formula '||c_prsn_type_ff_name ||
      --       ' is not defined in business_group_id = 0 '||
      --       ', all person types will be categorized as '||
      --       hr_bis.bis_decode_lookup('HRI_PERSON_TYPE_CATEGORY','NA_EDW') );
      --
      RETURN g_review_ff_id;
      --
    END IF;
    --
  END IF;
  --
  RETURN g_review_ff_id;
  --
END get_person_typ_ff_id;

/******************************************************************************/
/* DBI Person Type dimension                                                  */
/******************************************************************************/

-- -------------------------------------------------------------
-- Gets fast formula id for HRI_MAP_WORKER_TYPE formula
-- -------------------------------------------------------------
FUNCTION get_worker_cat_ff_id
  (p_business_group_id  IN NUMBER)
      RETURN NUMBER IS

  -- Finds HRI_MAP_WORKER_TYPE formula for given business group first
  -- If that doesn't exist then finds a global formula (Setup BG)
  CURSOR worker_cat_ff_csr IS
  SELECT fff.formula_id
  FROM
   ff_formulas_f     fff
  ,ff_formula_types  fft
  WHERE fft.formula_type_name = 'QuickPaint'
  AND trunc(sysdate) between fff.effective_start_date AND fff.effective_end_date
  AND fff.formula_type_id = fft.formula_type_id
  AND fff.formula_name = 'HRI_MAP_WORKER_TYPE'
  AND fff.business_group_id IN (p_business_group_id,0)
  ORDER BY
   fff.business_group_id DESC;

  l_formula_id    NUMBER;

BEGIN

  -- See if formula id is already stored in cache
  BEGIN
    l_formula_id := g_cache_formula_ids(p_business_group_id);

  -- If cache miss then get formula id from cursor
  EXCEPTION WHEN OTHERS THEN
    OPEN worker_cat_ff_csr;
    FETCH worker_cat_ff_csr INTO l_formula_id;
    CLOSE worker_cat_ff_csr;
    g_cache_formula_ids(p_business_group_id) := l_formula_id;
  END;

  RETURN l_formula_id;

END get_worker_cat_ff_id;

-- -------------------------------------------------------------
-- Returns worker type hierarchy for given worker type record
-- If there is an appropriate fast formula it is run otherwise
-- default logic is used to categorize the record
-- -------------------------------------------------------------
FUNCTION run_worker_cat_ff
  (p_wkth_base_rec   IN g_wkth_base_rec_type)
    RETURN g_wkth_cat_rec_type IS

  l_formula_id    NUMBER;
  l_wkth_cat_rec  g_wkth_cat_rec_type;
  l_inputs        FF_EXEC.INPUTS_T;
  l_outputs       FF_EXEC.OUTPUTS_T;
  l_wktyp_code    VARCHAR2(30);

BEGIN

  -- Get the fast formula id to run
  l_formula_id := get_worker_cat_ff_id(p_wkth_base_rec.business_group_id);

  -- Initialize worker type code based on person type
  -- Default include flag
    IF (p_wkth_base_rec.system_person_type = 'EMP' OR
        p_wkth_base_rec.system_person_type = 'CWK') THEN
      l_wkth_cat_rec.include_flag := 'Y';
      l_wktyp_code := p_wkth_base_rec.system_person_type;
    ELSE
      l_wkth_cat_rec.include_flag := 'N';
      l_wktyp_code := 'NA_EDW';
    END IF;

  -- If a formula is returned then run it
  IF (l_formula_id IS NOT NULL) THEN

    -- Run FF procedure initialization
    FF_Exec.Init_Formula
     (l_formula_id,
      SYSDATE,
      l_inputs,
      l_outputs);

    -- Populate input array
    IF l_inputs.count > 0 THEN

      FOR l_loop_count in l_inputs.first..l_inputs.last LOOP

        IF l_inputs(l_loop_count).name = 'DATE_EARNED' THEN
          l_inputs(l_loop_count).value := fnd_date.date_to_canonical(SYSDATE);
        ELSIF upper(l_inputs(l_loop_count).name) = 'ASSIGNMENT_ID' THEN
          l_inputs(l_loop_count).value := -1;
        ELSIF upper(l_inputs(l_loop_count).name) = 'SYSTEM_PERSON_TYPE' THEN
          l_inputs(l_loop_count).value := p_wkth_base_rec.system_person_type;
        ELSIF upper(l_inputs(l_loop_count).name) = 'USER_PERSON_TYPE' THEN
          l_inputs(l_loop_count).value := p_wkth_base_rec.user_person_type;
        ELSIF upper(l_inputs(l_loop_count).name) = 'EMPLOYMENT_CATEGORY' THEN
          l_inputs(l_loop_count).value := p_wkth_base_rec.employment_category;
        ELSIF upper(l_inputs(l_loop_count).name) = 'PRIMARY_FLAG' THEN
          l_inputs(l_loop_count).value := p_wkth_base_rec.primary_flag;
        ELSIF upper(l_inputs(l_loop_count).name) = 'ASSIGNMENT_TYPE' THEN
          l_inputs(l_loop_count).value := p_wkth_base_rec.assignment_type;
        END IF;

      END LOOP;

    END IF;

    -- Execute formula
    FF_Exec.Run_Formula
     (l_inputs,
      l_outputs);

    -- Get results from output array
    IF l_outputs.count > 0 THEN

      FOR l_loop_count in l_outputs.first..l_outputs.last LOOP

        IF upper(l_outputs(l_loop_count).name) = 'INCLUDE_IN_REPORTS' THEN
          l_wkth_cat_rec.include_flag := l_outputs(l_loop_count).value;
        ELSIF upper(l_outputs(l_loop_count).name) = 'WORKER_TYPE_LVL1' THEN
          l_wkth_cat_rec.wkth_lvl1_code := l_outputs(l_loop_count).value;
        ELSIF upper(l_outputs(l_loop_count).name) = 'WORKER_TYPE_LVL2' THEN
          l_wkth_cat_rec.wkth_lvl2_code := l_outputs(l_loop_count).value;
        END IF;

      END LOOP;

      -- Compose surrogate keys for levels
      l_wkth_cat_rec.wkth_lvl1_sk_fk := l_wktyp_code || '-' ||
                                        l_wkth_cat_rec.wkth_lvl1_code;

      l_wkth_cat_rec.wkth_lvl2_sk_fk := l_wkth_cat_rec.wkth_lvl1_sk_fk || '-' ||
                                        l_wkth_cat_rec.wkth_lvl2_code;

    END IF;

  ELSE

    -- Populate return record with default hierarchy information
    l_wkth_cat_rec.wkth_lvl1_sk_fk  := l_wktyp_code || '-NA_EDW';
    l_wkth_cat_rec.wkth_lvl1_code   := 'NA_EDW';
    l_wkth_cat_rec.wkth_lvl2_sk_fk  := l_wktyp_code || '-NA_EDW-NA_EDW';
    l_wkth_cat_rec.wkth_lvl2_code   := 'NA_EDW';

  END IF;

  RETURN l_wkth_cat_rec;

END run_worker_cat_ff;

-- --------------------------------------------------------------
-- Gets the worker type hierarchy information for the base record
-- by running the fast formula
-- --------------------------------------------------------------
FUNCTION cache_wkth_categories
  (p_wkth_base_rec   IN g_wkth_base_rec_type)
    RETURN g_wkth_cat_rec_type IS

BEGIN

  -- Check whether there is a cache hit
  IF (p_wkth_base_rec.person_type_id      = g_cache_wkth_base_rec.person_type_id AND
      p_wkth_base_rec.system_person_type  = g_cache_wkth_base_rec.system_person_type AND
      p_wkth_base_rec.user_person_type    = g_cache_wkth_base_rec.user_person_type AND
      p_wkth_base_rec.business_group_id   = g_cache_wkth_base_rec.business_group_id AND
      p_wkth_base_rec.primary_flag        = g_cache_wkth_base_rec.primary_flag AND
      p_wkth_base_rec.employment_category = g_cache_wkth_base_rec.employment_category AND
      p_wkth_base_rec.assignment_type     = g_cache_wkth_base_rec.assignment_type) THEN
    RETURN g_cache_wkth_cat_rec;
  END IF;

  -- No cache hit - populate the cache
  g_cache_wkth_base_rec := p_wkth_base_rec;
  g_cache_wkth_cat_rec  := run_worker_cat_ff(p_wkth_base_rec);

  RETURN g_cache_wkth_cat_rec;

END cache_wkth_categories;

-- --------------------------------------------------------------
-- Gets the worker type hierarchy information from the collected
-- table for the given surrogate key
-- --------------------------------------------------------------
PROCEDURE cache_wkth_values(p_prsntyp_sk_pk  IN NUMBER) IS

  -- Get hierarchy columns from the table
  CURSOR wkth_values_csr IS
  SELECT
   wkth_wktyp_sk_fk
  ,wkth_wktyp_code
  ,wkth_lvl1_sk_fk
  ,wkth_lvl1_code
  ,wkth_lvl2_sk_fk
  ,wkth_lvl2_code
  FROM
   hri_cs_prsntyp_ct
  WHERE prsntyp_sk_pk = p_prsntyp_sk_pk;

  l_wkth_wktyp_sk_fk    VARCHAR2(240);
  l_wkth_wktyp_code     VARCHAR2(240);
  l_wkth_lvl1_sk_fk     VARCHAR2(240);
  l_wkth_lvl1_code      VARCHAR2(240);
  l_wkth_lvl2_sk_fk     VARCHAR2(240);
  l_wkth_lvl2_code      VARCHAR2(240);

BEGIN

  -- Populate local variables from cursor
  OPEN wkth_values_csr;
  FETCH wkth_values_csr INTO
    l_wkth_wktyp_sk_fk,
    l_wkth_wktyp_code,
    l_wkth_lvl1_sk_fk,
    l_wkth_lvl1_code,
    l_wkth_lvl2_sk_fk,
    l_wkth_lvl2_code;
  CLOSE wkth_values_csr;

  -- Populate cache
  g_cache_wkth_values(p_prsntyp_sk_pk).wkth_wktyp_sk_fk := l_wkth_wktyp_sk_fk;
  g_cache_wkth_values(p_prsntyp_sk_pk).wkth_wktyp_code  := l_wkth_wktyp_code;
  g_cache_wkth_values(p_prsntyp_sk_pk).wkth_lvl1_sk_fk  := l_wkth_lvl1_sk_fk;
  g_cache_wkth_values(p_prsntyp_sk_pk).wkth_lvl1_code   := l_wkth_lvl1_code;
  g_cache_wkth_values(p_prsntyp_sk_pk).wkth_lvl2_sk_fk  := l_wkth_lvl2_sk_fk;
  g_cache_wkth_values(p_prsntyp_sk_pk).wkth_lvl2_code   := l_wkth_lvl2_code;

END cache_wkth_values;

-- --------------------------------------------------------------
-- Returns single column value for given base record by running
-- the fast formula
-- --------------------------------------------------------------
FUNCTION get_wkth_lvl1_sk_fk
  (p_person_type_id       IN NUMBER
  ,p_system_person_type   IN VARCHAR2
  ,p_user_person_type     IN VARCHAR2
  ,p_business_group_id    IN NUMBER
  ,p_primary_flag         IN VARCHAR2
  ,p_employment_category  IN VARCHAR2
  ,p_assignment_type      IN VARCHAR2)
      RETURN VARCHAR2 IS

  l_wkth_base_rec    g_wkth_base_rec_type;
  l_wkth_cat_rec     g_wkth_cat_rec_type;

BEGIN

  -- Set up base level record
  l_wkth_base_rec.person_type_id      := p_person_type_id;
  l_wkth_base_rec.system_person_type  := p_system_person_type;
  l_wkth_base_rec.user_person_type    := p_user_person_type;
  l_wkth_base_rec.business_group_id   := p_business_group_id;
  l_wkth_base_rec.primary_flag        := p_primary_flag;
  l_wkth_base_rec.employment_category := p_employment_category;
  l_wkth_base_rec.assignment_type     := p_assignment_type;

  -- Populate hierarchy record
  l_wkth_cat_rec := cache_wkth_categories(l_wkth_base_rec);

  -- Return required column
  RETURN l_wkth_cat_rec.wkth_lvl1_sk_fk;

END get_wkth_lvl1_sk_fk;

-- --------------------------------------------------------------
-- Returns single column value for given base record by running
-- the fast formula
-- --------------------------------------------------------------
FUNCTION get_wkth_lvl2_sk_fk
  (p_person_type_id       IN NUMBER
  ,p_system_person_type   IN VARCHAR2
  ,p_user_person_type     IN VARCHAR2
  ,p_business_group_id    IN NUMBER
  ,p_primary_flag         IN VARCHAR2
  ,p_employment_category  IN VARCHAR2
  ,p_assignment_type      IN VARCHAR2)
      RETURN VARCHAR2 IS

  l_wkth_base_rec    g_wkth_base_rec_type;
  l_wkth_cat_rec     g_wkth_cat_rec_type;

BEGIN

  -- Set up base level record
  -- Populate hierarchy record
  -- Return required column
  l_wkth_base_rec.person_type_id      := p_person_type_id;
  l_wkth_base_rec.system_person_type  := p_system_person_type;
  l_wkth_base_rec.user_person_type    := p_user_person_type;
  l_wkth_base_rec.business_group_id   := p_business_group_id;
  l_wkth_base_rec.primary_flag        := p_primary_flag;
  l_wkth_base_rec.employment_category := p_employment_category;
  l_wkth_base_rec.assignment_type     := p_assignment_type;

  l_wkth_cat_rec := cache_wkth_categories(l_wkth_base_rec);

  RETURN l_wkth_cat_rec.wkth_lvl2_sk_fk;

END get_wkth_lvl2_sk_fk;


-- --------------------------------------------------------------
-- Returns single column value for given base record by running
-- the fast formula
-- --------------------------------------------------------------
FUNCTION get_wkth_lvl1_code
  (p_person_type_id       IN NUMBER
  ,p_system_person_type   IN VARCHAR2
  ,p_user_person_type     IN VARCHAR2
  ,p_business_group_id    IN NUMBER
  ,p_primary_flag         IN VARCHAR2
  ,p_employment_category  IN VARCHAR2
  ,p_assignment_type      IN VARCHAR2)
      RETURN VARCHAR2 IS

  l_wkth_base_rec    g_wkth_base_rec_type;
  l_wkth_cat_rec     g_wkth_cat_rec_type;

BEGIN

  -- Set up base level record
  l_wkth_base_rec.person_type_id      := p_person_type_id;
  l_wkth_base_rec.system_person_type  := p_system_person_type;
  l_wkth_base_rec.user_person_type    := p_user_person_type;
  l_wkth_base_rec.business_group_id   := p_business_group_id;
  l_wkth_base_rec.primary_flag        := p_primary_flag;
  l_wkth_base_rec.employment_category := p_employment_category;
  l_wkth_base_rec.assignment_type     := p_assignment_type;

  -- Populate hierarchy record
  l_wkth_cat_rec := cache_wkth_categories(l_wkth_base_rec);

  -- Return required column
  RETURN l_wkth_cat_rec.wkth_lvl1_code;

END get_wkth_lvl1_code;

-- --------------------------------------------------------------
-- Returns single column value for given base record by running
-- the fast formula
-- --------------------------------------------------------------
FUNCTION get_wkth_lvl2_code
  (p_person_type_id       IN NUMBER
  ,p_system_person_type   IN VARCHAR2
  ,p_user_person_type     IN VARCHAR2
  ,p_business_group_id    IN NUMBER
  ,p_primary_flag         IN VARCHAR2
  ,p_employment_category  IN VARCHAR2
  ,p_assignment_type      IN VARCHAR2)
      RETURN VARCHAR2 IS

  l_wkth_base_rec    g_wkth_base_rec_type;
  l_wkth_cat_rec     g_wkth_cat_rec_type;

BEGIN

  -- Set up base level record
  l_wkth_base_rec.person_type_id      := p_person_type_id;
  l_wkth_base_rec.system_person_type  := p_system_person_type;
  l_wkth_base_rec.user_person_type    := p_user_person_type;
  l_wkth_base_rec.business_group_id   := p_business_group_id;
  l_wkth_base_rec.primary_flag        := p_primary_flag;
  l_wkth_base_rec.employment_category := p_employment_category;
  l_wkth_base_rec.assignment_type     := p_assignment_type;

  -- Populate hierarchy record
  l_wkth_cat_rec := cache_wkth_categories(l_wkth_base_rec);

  -- Return required column
  RETURN l_wkth_cat_rec.wkth_lvl2_code;

END get_wkth_lvl2_code;


-- --------------------------------------------------------------
-- Returns single column value for given primary key from the
-- collected table
-- --------------------------------------------------------------
FUNCTION get_wkth_wktyp_code
  (p_prsntyp_sk_pk  IN NUMBER)
       RETURN VARCHAR2 IS

  l_wkth_wktyp_code     VARCHAR2(240);

BEGIN
  -- Get column value from the cache
  BEGIN
    l_wkth_wktyp_code := g_cache_wkth_values(p_prsntyp_sk_pk).wkth_wktyp_code;

  -- If there is no value in the cache then load the cache from the table
  EXCEPTION WHEN OTHERS THEN
    cache_wkth_values(p_prsntyp_sk_pk);
    l_wkth_wktyp_code := g_cache_wkth_values(p_prsntyp_sk_pk).wkth_wktyp_code;
  END;

  RETURN l_wkth_wktyp_code;

END get_wkth_wktyp_code;

-- --------------------------------------------------------------
-- Returns single column value for given base record by running
-- the fast formula
-- --------------------------------------------------------------
FUNCTION get_include_flag
  (p_person_type_id       IN NUMBER
  ,p_system_person_type   IN VARCHAR2
  ,p_user_person_type     IN VARCHAR2
  ,p_business_group_id    IN NUMBER
  ,p_primary_flag         IN VARCHAR2
  ,p_employment_category  IN VARCHAR2
  ,p_assignment_type      IN VARCHAR2)
      RETURN VARCHAR2 IS

  l_wkth_base_rec    g_wkth_base_rec_type;
  l_wkth_cat_rec     g_wkth_cat_rec_type;

BEGIN

  -- Set up base level record
  l_wkth_base_rec.person_type_id      := p_person_type_id;
  l_wkth_base_rec.system_person_type  := p_system_person_type;
  l_wkth_base_rec.user_person_type    := p_user_person_type;
  l_wkth_base_rec.business_group_id   := p_business_group_id;
  l_wkth_base_rec.primary_flag        := p_primary_flag;
  l_wkth_base_rec.employment_category := p_employment_category;
  l_wkth_base_rec.assignment_type     := p_assignment_type;

  -- Populate hierarchy record
  l_wkth_cat_rec := cache_wkth_categories(l_wkth_base_rec);

  -- Return required column
  RETURN l_wkth_cat_rec.include_flag;

END get_include_flag;

-- -------------------------------------------------------------------------
-- Looks up person type surrogate key given the composite OLTP primary key
-- -------------------------------------------------------------------------
FUNCTION get_prsntyp_sk_fk
  (p_person_type_id       IN NUMBER
  ,p_employment_category  IN VARCHAR2
  ,p_primary_flag         IN VARCHAR2
  ,p_assignment_type      IN VARCHAR2)
     RETURN NUMBER IS

  -- Cursor to get the SK also cache any information
  -- that will be resused later
  CURSOR prsntyp_sk_csr IS
  SELECT
   prsntyp_sk_pk
  ,wkth_wktyp_code
  FROM hri_cs_prsntyp_ct
  WHERE person_type_id = p_person_type_id
  AND employment_category_code = p_employment_category
  AND primary_flag_code = p_primary_flag
  AND assignment_type_code = p_assignment_type;

  l_cache_key        VARCHAR2(240);
  l_prsntyp_sk_fk    NUMBER;
  l_wkth_wktyp_code  VARCHAR2(240);

BEGIN

  -- Formulate cache key
  l_cache_key := to_char(p_person_type_id) || '|' ||
                 p_primary_flag || '|' ||
                 p_employment_category || '|' ||
                 p_assignment_type;

  -- Test if surrogate key can be returned from the cache
  BEGIN

    l_prsntyp_sk_fk := g_cache_prsntyp_sk(l_cache_key);

  -- If no value is in the cache then populate cache
  EXCEPTION WHEN OTHERS THEN

    -- Get SK from table
    OPEN prsntyp_sk_csr;
    FETCH prsntyp_sk_csr INTO l_prsntyp_sk_fk, l_wkth_wktyp_code;
    CLOSE prsntyp_sk_csr;

    -- Store SK in cache for future reference
    IF (l_prsntyp_sk_fk IS NULL) THEN
      l_prsntyp_sk_fk := -1;
      g_cache_prsntyp_sk(l_cache_key) := l_prsntyp_sk_fk;
      g_cache_wkth_values(l_prsntyp_sk_fk).wkth_wktyp_code := 'NA_EDW';
    ELSE
      g_cache_prsntyp_sk(l_cache_key) := l_prsntyp_sk_fk;
      g_cache_wkth_values(l_prsntyp_sk_fk).wkth_wktyp_code := l_wkth_wktyp_code;
    END IF;

  END;

  -- Return SK
  RETURN l_prsntyp_sk_fk;

END get_prsntyp_sk_fk;

END HRI_BPL_PERSON_TYPE;

/
