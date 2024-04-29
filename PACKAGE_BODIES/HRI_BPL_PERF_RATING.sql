--------------------------------------------------------
--  DDL for Package Body HRI_BPL_PERF_RATING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_PERF_RATING" AS
/* $Header: hribpfrt.pkb 120.3 2005/12/21 03:52:20 anmajumd noship $ */
--
-- -----------------------------------------------------------------------------
-- The package Normalizes the Performance Review Rating and the Overall Rating
-- given for an Appraisal based on the fast formulas NORMALIZE_REVIEW_RATING
-- and NORMALIZE_APPRAISAL_RATING. These formulas are called for the appraisals
-- and reviews created.
--
-- NORMALIZE_REVIEW_RATING :
--     This formula should always be created in the setup business group (bg_id = 0)
--     The NORMALIZED_RATING value will only be considered for collection if
--     SKIP_REVIEW = 'N'
-- INPUT_VALUES  : REVIEW_TYPE , RATING
-- OUTPUT_VALUES : SKIP_REVIEW , NORMALIZED_RATING
--
-- NORMALIZE_APPRAISAL_RATING :
--     This formula should be created for evenry business business group for which
--     the data is to be collected.
--     The NORMALIZED_RATING value will only be considered for collection if
--     SKIP_REVIEW = 'N'
-- INPUT_VALUES  : APPRAISAL_TEMPLATE_NAME  , RATING
-- OUTPUT_VALUES : SKIP_REVIEW , NORMALIZED_RATING
--
-- In order to determine normailized rating given for a Appraisal/Review. Call
-- function get_perf_rating_val with the relevant parameters.
-- -----------------------------------------------------------------------------
--
-- Global Parameter for caching setup business group id
--
g_setup_business_group_id        NUMBER;
g_debug_flag                     VARCHAR2(1);
g_concurrent_flag                VARCHAR2(1);
g_review_ff_id                   NUMBER;
--
-- Simple table types
--
TYPE g_number_tab_type    IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  --
  -- Type for service dates containing hire date, termination date, secondary
  -- assignment start date, secondary assignment end date, primary assignment
  -- start date and primary assignment end date.
  --
TYPE g_normalized_rating_type IS RECORD
    (skip_review                  VARCHAR2(5)
    ,normalized_rating            NUMBER);
--
TYPE g_normalization_tab_type IS TABLE OF g_normalized_rating_type INDEX BY VARCHAR2(500);
--
g_normalization_cache           g_normalization_tab_type;
--
-- Global array for storing the appraisal formulas for different bg's
--
g_appraisal_ff_id                g_number_tab_type;
--
-- Stores the value to be stored in the performance band columns for not rated records
--
g_perf_not_rated_id      NUMBER := hri_bpl_dimension_utilities.get_not_rated_id;
--
-- Global variable for storing the performance band ranges
--
g_perf_bucket            BIS_BUCKET_CUSTOMIZATIONS%rowtype;
--
g_rtn              VARCHAR2(30) := '
';
--
-- Exceptions
--
--
-- -----------------------------------------------------------------------------
-- Inserts row into concurrent program log
-- -----------------------------------------------------------------------------
--
PROCEDURE output(p_text  VARCHAR2) IS
BEGIN
  --
  IF (g_concurrent_flag = 'Y') THEN
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
BEGIN
    --
    IF g_debug_flag is null THEN
      --
      g_debug_flag := NVL(fnd_profile.value('HRI_ENBL_DTL_LOG'),'N');
      --
    END IF;
    --
    IF g_debug_flag = 'Y' THEN
      --
      fnd_file.put_line(fnd_file.log, p_text);
      --
    END IF;
    --
END dbg;
--
-- -----------------------------------------------------------------------------
-- Procedure to check if the fast formula for a business group on the given date
-- exists and is compiled
-- -----------------------------------------------------------------------------
--
FUNCTION ff_exits_and_compiled(p_business_group_id     IN NUMBER,
			       p_date                  IN DATE,
			       p_ff_name               IN VARCHAR2)
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
  dbg('ff_id = '||l_ff_id);
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
END ff_exits_and_compiled;
--
-- -----------------------------------------------------------------------------
-- GET_REVIEW_FF
-- This function returns the fast formula_id of the formula NORMALIZE_REVIEW_RATING
-- This formula should be created in setup business group and is used for
-- determining the normalizing the rating give to a performance review
-- -----------------------------------------------------------------------------
--
FUNCTION get_review_ff
RETURN NUMBER
IS
  --
  --
BEGIN
  --
  -- Check if the formula_id is already cached, or else determine the ff_id
  -- The NORMALIZE_REVIEW_RATING formula should always be created in the Setup
  -- business group
  --
  IF g_review_ff_id is null THEN
    --
    g_review_ff_id := ff_exits_and_compiled
                              (p_business_group_id     => 0
			      ,p_date                  => TRUNC(SYSDATE)
			      ,p_ff_name               => 'NORMALIZE_REVIEW_RATING');
    --
  END IF;
  --
  RETURN g_review_ff_id;
  --
END get_review_ff;
--
-- -----------------------------------------------------------------------------
-- GET_APPRAISAL_FF
-- This function returns the fast formula_id of the formula NORMALIZE_APPRAISAL_RATING
-- which has been defined in the specified business group. This formula is used
-- for normalizing the rating give to a APPRAISAL
-- -----------------------------------------------------------------------------
--
FUNCTION get_appraisal_ff (p_business_group_id     IN NUMBER)
RETURN NUMBER
IS
  --
  l_ff_id    NUMBER;
  --
BEGIN
  --
  -- Check if the formula_id for the business_group_id is already cached,
  -- or else determine the ff_id
  --
  BEGIN
    --
    l_ff_id := g_appraisal_ff_id(p_business_group_id);
    --
    RETURN l_ff_id;
    --
  EXCEPTION
    WHEN others THEN
      --
      g_appraisal_ff_id(p_business_group_id) := ff_exits_and_compiled
                              (p_business_group_id     => p_business_group_id
    			      ,p_date                  => trunc(SYSDATE)
			      ,p_ff_name               => 'NORMALIZE_APPRAISAL_RATING');
      --
      dbg('ff_id for appraisal in bg '||p_business_group_id || ' is '||g_appraisal_ff_id(p_business_group_id));
      --
      IF g_appraisal_ff_id(p_business_group_id) is null THEN
        --
        output('WARNING! The  fast formula NORMALIZE_APPRAISAL_RATING does '||
               'not exists in business group = '||p_business_group_id||
               ', appraisals created in this business group will not be collected');
        --
      END IF;
      --
      RETURN g_appraisal_ff_id(p_business_group_id);
      --
   END;
   --
EXCEPTION
  WHEN others THEN
    --
    dbg('exception in get_appraisal_ff');
    RAISE;
    --
END get_appraisal_ff;
--
-- -----------------------------------------------------------------------------
-- PROCEDURE : GET_CACHED_RATING
--             This procedure searches the cache for the already collected ff
--             output based on the input values. Incase an entry already exists
--             in the cache then return the values or else it returns null
--             In case the cache contains a SKIP instruction, it returns -1
-- -----------------------------------------------------------------------------
--
PROCEDURE get_cached_rating  ( p_business_group_id        IN   NUMBER
                            , p_perf_rating_cd            IN   VARCHAR2
                            , p_review_type               IN   VARCHAR2
                            , p_appraisal_template_name   IN   VARCHAR2
                            , p_skip_review               OUT NOCOPY VARCHAR2
                            , p_normalized_rating         OUT NOCOPY NUMBER)
IS
  --
  l_cache_index    varchar2(500);
  --
BEGIN
  --
  -- Create the cache index
  --
  l_cache_index := p_business_group_id||'##'||
                   p_perf_rating_cd||'##'||
                   p_review_type||'##'||
                   p_appraisal_template_name;
  --
  -- Return the skip code and normailized rating stored in the cache for the review
  -- In case the no entry exists in the cache for review, an exception will be raised
  -- based on which the formula can be invoked by the calling routine.
  -- 4243156 this was reported as the old function used to return -1 when the
  -- SKIP_REVIEW o/p param was set to Y. Because of this the process was skipping
  -- reviews that had a normalized rating of -1 without any skip instruction
  --
  p_skip_review        := g_normalization_cache(l_cache_index).skip_review;
  p_normalized_rating  := g_normalization_cache(l_cache_index).normalized_rating;
  --
EXCEPTION
  WHEN others THEN
    --
    dbg('rating not found in cache, invoke the formula');
    --
END get_cached_rating;
--
-- -----------------------------------------------------------------------------
-- PROCEDURE : CACHE_RATING
--             This procedure stores the formulas output in cache.
-- -----------------------------------------------------------------------------
--
PROCEDURE cache_rating ( p_business_group_id        IN   NUMBER
                      , p_perf_rating_cd            IN   VARCHAR2
                      , p_review_type               IN   VARCHAR2
                      , p_appraisal_template_name   IN   VARCHAR2
                      , p_skip_review               IN   VARCHAR2
                      , p_normalized_rating         IN   NUMBER)
IS
  --
  l_cache_index    varchar2(500);
  --
BEGIN
  --
  -- Create the cache index
  --
  l_cache_index := p_business_group_id||'##'||
                   p_perf_rating_cd||'##'||
                   p_review_type||'##'||
                   p_appraisal_template_name;
  --
  -- Store the output of the formla in the varchar2 indexed cached.
  --
  g_normalization_cache(l_cache_index).skip_review       := p_skip_review;
  g_normalization_cache(l_cache_index).normalized_rating := p_normalized_rating;
  --
END cache_rating;
--
-- -----------------------------------------------------------------------------
-- Function  :GET_PERF_RATING_VAL
-- Inputs    : p_perf_rating_formula_id :Performance Rating Formula ID
--             p_perf_rating_cd : The perfromance rating code
-- 	       p_session_date : The date for which the fast formula is to be called
--             p_param: Incase the PUI fast formula is to be used, this parameter
--                      is used to pass the value of review type.
--                      Incase the Self Service fast formula is to be used, this
--                      parameter is used to pass the appraisal template name
-- Outputs   : Performance Rating Scaled Up Value
-- -----------------------------------------------------------------------------
--
FUNCTION get_perf_rating_val
  ( p_session_date	        IN   DATE
  , p_business_group_id         IN   NUMBER
  , p_perf_rating_cd	        IN   VARCHAR2
  , p_review_type               IN   VARCHAR2
  , p_appraisal_template_name   IN   VARCHAR2
  )
RETURN NUMBER IS
  --
  l_perf_rating		NUMBER;
  l_cached_skip         VARCHAR2(30);
  l_cached_rating       NUMBER;
  l_business_group      NUMBER;
  l_skip_review         VARCHAR2(30);
  l_inputs		ff_exec.inputs_t;
  l_outputs		ff_exec.outputs_t;
  l_ff_id               NUMBER;
  --
BEGIN
  --
  dbg('-----------------------------------------------------');
  dbg('p_session_date            '||p_session_date           );
  dbg('p_perf_rating_cd          '||p_perf_rating_cd         );
  dbg('p_review_type             '||p_review_type            );
  dbg('p_appraisal_template_name '||p_appraisal_template_name);
  --
  -- Determine the business group in which the formula should be searched.
  -- Yhe performance review formula, should be created in setup business group
  --
  IF p_appraisal_template_name IS NULL THEN
    --
    l_business_group := 0;
    --
  ELSE
    --
    l_business_group := p_business_group_id;
    --
  END IF;
  --
  -- If the normalized rating is available in the cache, then return the
  -- value stored in the cache instead of calling the fast formula
  --
  get_cached_rating
          ( p_business_group_id        => l_business_group
          , p_perf_rating_cd           => p_perf_rating_cd
          , p_review_type              => p_review_type
          , p_appraisal_template_name  => p_appraisal_template_name
          , p_skip_review              => l_cached_skip
          , p_normalized_rating        => l_cached_rating);

  --
  -- 4243156 Changed the old logic of skipping rating when -1 was returned by
  -- the cache. Use the skip_review parameter to determine if a rating is to be
  -- skipped
  --
  IF l_cached_skip = 'N' THEN
    --
    -- rating is found in cache so return
    --
    dbg('performance rating found in cache = '||l_cached_rating);
    RETURN l_cached_rating;
    --
  ELSIF l_cached_rating is not null THEN
    --
    -- The cached contains a skip instruction i.e. skip <> 'N' so return
    -- without calling the ff
    --
    dbg('skip code found in cache');
    RETURN null;
    --
  ELSE
    --
    -- The value cannot be found in cache so determine the forumla to be called
    --
    IF p_appraisal_template_name IS NULL THEN
      --
      l_ff_id := get_review_ff;
      --
    ELSE
      --
      l_ff_id := get_appraisal_ff(p_business_group_id);
      --
    END IF;
    --
  END IF;
  --
  -- In case a formula is not defined for review in setup bg or for appraisal in
  -- the business_group, then store the details in the cache are return gracefully
  -- without throwing any error
  --
  IF l_ff_id is null THEN
    --
    dbg('No ff_found for bg '||l_business_group);
    --
    cache_rating
          ( p_business_group_id        => l_business_group
          , p_perf_rating_cd           => p_perf_rating_cd
          , p_review_type              => p_review_type
          , p_appraisal_template_name  => p_appraisal_template_name
          , p_skip_review              => 'Y'
          , p_normalized_rating        => NULL);
    --
    RETURN null;
    --
  END IF;
  --
  -- The value for this formula is not cached and the formula exists to convert the rating
  -- Initialise the Inputs and Outputs tables
  --
  FF_Exec.Init_Formula
	( l_ff_id
	, SYSDATE
  	, l_inputs
	, l_outputs );
  --
  -- Set the input values
  --
  IF l_inputs.count > 0 THEN
    --
    FOR l_loop_count in l_inputs.first..l_inputs.last LOOP
      --
      -- intialize the input values
      --
      IF l_inputs(l_loop_count).name = 'DATE_EARNED' THEN
        --
        l_inputs(l_loop_count).value := fnd_date.date_to_canonical(p_session_date);
        --
      ELSIF upper(l_inputs(l_loop_count).name) = 'RATING' THEN
        --
        l_inputs(l_loop_count).value := p_perf_rating_cd;
        --
      ELSIF upper(l_inputs(l_loop_count).name) = 'RATING_LEVEL_CODE' THEN
        --
        l_inputs(l_loop_count).value := p_perf_rating_cd;
        --
      ELSIF upper(l_inputs(l_loop_count).name) = 'REVIEW_TYPE' THEN
        --
        l_inputs(l_loop_count).value := p_review_type;
        --
      ELSIF upper(l_inputs(l_loop_count).name) = 'APPRAISAL_TEMPLATE_NAME' THEN
        --
        l_inputs(l_loop_count).value := p_appraisal_template_name;
        --
      END IF;
      --
    END LOOP;
    --
  END IF;
  --
  -- Run the fast formula
  --
  dbg('Before running the formula');
  FF_Exec.Run_Formula (l_inputs, l_outputs);
  dbg('After running the formula');
  --
  -- Get the output from tha fast formula
  --
  IF l_outputs.count > 0 THEN
    --
    FOR l_loop_count in l_outputs.first..l_outputs.last LOOP
      --
      IF upper(l_outputs(l_loop_count).name) = 'SKIP_REVIEW' THEN
        --
        -- Fetch the value for skip_review
        --
        l_skip_review := l_outputs(l_loop_count).value;
        --
      ELSIF upper(l_outputs(l_loop_count).name) = 'NORMALIZED_RATING' THEN
        --
        -- Fetch the value for normalized rating
        --
        BEGIN
          --
          l_perf_rating := l_outputs(l_loop_count).value;
          --
        EXCEPTION
          WHEN VALUE_ERROR THEN
            --
            -- This error is raised when the formula returned a character value for normalized_rating
            -- out parameter
            --
            Fnd_Message.Set_Name('BEN', 'BEN_92311_FORMULA_VAL_PARAM');
            Fnd_Message.Set_Token('PARAMETER','NORMALIZED_RATING' );
            Fnd_Message.Set_Token('FORMULA',l_ff_id);
            Fnd_Message.Set_Token('PROC','HRI_BPL_PERF_RATING');
            RAISE ff_returned_invalid_value;
            --
        END;
        --
      END IF;
      --
    END LOOP;
    --
  END IF;
  --
  dbg('SKIP = '||l_skip_review||' , NORMALIZED_RATING = '||l_perf_rating);
  --
  -- Store the output of the formula in a cache,
  --
  cache_rating
            ( p_business_group_id        => l_business_group
            , p_perf_rating_cd           => p_perf_rating_cd
            , p_review_type              => p_review_type
            , p_appraisal_template_name  => p_appraisal_template_name
            , p_skip_review              => NVL(l_skip_review,'N')
            , p_normalized_rating        => l_perf_rating);
  --
  -- If skip_review is yes then return the normalized perfromance rating as null
  --
  IF l_skip_review <> 'N' THEN
    --
    dbg('The performance rating is to be skipped');
    dbg('-----------------------------------------------------');
    --
    RETURN NULL;
    --
  ELSE
    --
    dbg('normalized rating = '||l_perf_rating);
    dbg('-----------------------------------------------------');
    --
    RETURN l_perf_rating;
    --
  END IF;
  --
EXCEPTION
  WHEN ff_returned_invalid_value THEN
    --
    -- This error is raised when the formula returned a character value for normalized_rating
    -- out parameter, raise the error.
    --
    RAISE ;
  --
  -- raises an exception and appropriate error message if
  -- the fast formula fails to run (usually due to not being compiled).
  --
  WHEN others THEN
    --
    dbg(sqlerrm);
    --
    RAISE ff_perf_rating_not_compiled;
    --
END get_perf_rating_val;
--
--
-- ----------------------------------------------------------------------------
-- Function to fetch the dynamic sql that will be used by the performance
-- records. The SQL query to fetch the performance rating records depends upon
-- the presence of assignment_id column in per_appraisals table. By looking at
-- this column, the function identifies the performance rating version being
-- used in the system and forms the version specific performance query
-- ----------------------------------------------------------------------------
--
FUNCTION get_perf_sql
RETURN VARCHAR2
IS
  --
  l_column                    VARCHAR2(30);
  l_asg_id_in_per_appraisals  VARCHAR2(1);
  --
  -- Varriables to get the schema name
  --
  l_schema                    VARCHAR2(30);
  l_dummy1                    VARCHAR2(2000);
  l_dummy2                    VARCHAR2(2000);
  --
  -- Cursor to identify if the assignment_id column is present in per_appraisals
  -- Bug 4873576 , added condition on owner for performance reason
  --
  CURSOR c_asg_col IS
    SELECT column_name
    INTO   l_column
    FROM  sys.all_tab_columns
    WHERE table_name = 'PER_APPRAISALS'
    AND   column_name = 'ASSIGNMENT_ID'
    AND   owner = l_schema;
  --
  -- Variable to fetch the performance SQl to fetch the performance rating records
  --
  -- SELECT clause for the case when the performance review is done using PUI
  --
  l_perf_select_sql VARCHAR2(1500);
  --
  -- WHERE clause for the case when the performance review is done using PUI
  --
  l_perf_where_sql  VARCHAR2(1500);
  --
  -- SELECT clause for the case when the appraisal is done using SS
  --
  l_appr_select_sql VARCHAR2(1000);
  --
  -- WHERE clause for the case when the appraisal is done using SS
  --
  l_appr_where_sql          VARCHAR2(1500);
  l_appr_asg_where_sql      VARCHAR2(1500);

  --
  -- The outer parts of the sql
  --
  l_outer_select          VARCHAR2(1000);
  l_outer_where           VARCHAR2(1000);
  --
  -- Final query formed for fetching appraisal and performance review reocrds
  --
  l_perf_sql        VARCHAR2(10000);
  --
  l_message       fnd_new_messages.message_text%type;
  --
  -- Fast formula id
  --
  l_review_ff_id     NUMBER;
  --
BEGIN
  --
  -- The performane rating data is collected from the per_performance_reviews
  -- and per_appraisals table. For this, two SQL queries are written and these
  -- queries are joined by a union.
  -- The absence of assignment_id column in per_appraisals implies the use of the
  -- older version of appraisal.
  -- However if the assignment_id column is present in the per_appraisal table
  -- it implies, the newer version of performance collection is installed for which
  -- the where clause of the queries have to add a few more constraints
  --
  -- Set the SELECT clause to fetch recored from per_performance_reviews
  -- 4259647 Added the last_update_date column
  -- 4300665 Rehire Issue, added code to restrict the appraisals made during first
  -- term from getting collected in the second term and vice versa
  --
  l_perf_select_sql :=
    'SELECT perf.performance_rating    perf_rating,
            perf.review_date           review_date,
            perf.last_update_date      last_update_date,
            perf.performance_review_id performance_review_id,
            pevt.type                  perf_review_type,
            NULL                       app_temp_name,
            hri_bpl_perf_rating.get_perf_rating_val (perf.review_date,
              :p_business_group_id,perf.performance_rating,pevt.type,null) nrmlsd_rating,
            nvl(ppos.actual_termination_date,hr_general.end_of_time) termination_date
     FROM   per_performance_reviews perf,
            per_events pevt,
            per_all_assignments_f asgn,
            per_periods_of_service ppos
    ';
  --
  -- Set the WHERE clause to fetch recored from per_performance_reviews
  -- 4300665 Rehire Issue, added code to restrict the appraisals made during first
  -- term from getting collected in the second term and vice versa
  --
  l_perf_where_sql :=
    'WHERE  perf.person_id = :p_person_id
     AND    perf.review_date <= :p_end_date_active
     AND    pevt.event_id(+) = perf.event_id
     AND    asgn.person_id = perf.person_id
     AND    asgn.primary_flag = ''Y''
     AND    perf.review_date BETWEEN asgn.effective_start_date AND asgn.effective_end_date
     AND    ppos.person_id = asgn.person_id
     AND    ppos.period_of_service_id = asgn.period_of_service_id
     AND    ppos.date_start = :p_hire_date
     AND    perf.review_date  between ppos.date_start and
              nvl(ppos.actual_termination_date,hr_general.end_of_time)';
  --
  -- Determine if Assignment_Id exists in appraisals table
  -- Bug 4873576, schema name required for performance reason
  --
  IF (fnd_installation.get_app_info('PER',l_dummy1, l_dummy2, l_schema)) THEN
    --
    OPEN  c_asg_col;
    FETCH c_asg_col INTO l_column;
    CLOSE c_asg_col;
    --
  END IF;
  --
  -- Check the presence of assignment_id column in the per_appraisals
  -- table
  --
  IF l_column IS NOT NULL THEN
    --
    l_asg_id_in_per_appraisals := 'Y';
    --
  ELSE
    --
    l_asg_id_in_per_appraisals := 'N';
    --
  END IF;
  --
  -- Set the SELECT clause to fetch records from per_appraisals
  -- 4259647 Added the last_update_date column
  -- 4300665 Rehire Issue, added code to restrict the appraisals made during first
  -- term from getting collected in the second term and vice versa
  --
  l_appr_select_sql :=
    'SELECT to_char(prl.step_value) perf_rating,
            papp.appraisal_date     review_date,
            papp.last_update_date   last_update_date,
            null                    performance_review_id,
            null                    perf_review_type,
            papt.name               app_temp_name,
	    hri_bpl_perf_rating.get_perf_rating_val(papp.appraisal_date ,
	         :p_business_group_id,prl.step_value,null,papt.name)  nrmlsd_rating,
            nvl(ppos.actual_termination_date,hr_general.end_of_time) termination_date
     FROM   per_appraisals papp,
            per_rating_levels prl,
            per_appraisal_templates papt,
            per_all_assignments_f asgn,
            per_periods_of_service ppos
    ';
  --
  -- Set the WHERE clause to fetch records from per_appraisals
  -- Fetch only those records where the overall_performance_level_id is populated
  -- 4300665 Rehire Issue, added code to restrict the appraisals made during first
  -- term from getting collected in the second term and vice versa
  --
  l_appr_where_sql :=
    'WHERE  papp.appraisee_person_id = :p_person_id
     AND    papp.appraisal_date <= :p_end_date_active
     AND    papp.overall_performance_level_id is not null
     AND    papp.overall_performance_level_id = prl.rating_level_id(+)
     AND    papp.appraisal_template_id = papt.appraisal_template_id(+)
     AND    asgn.person_id = papp.appraisee_person_id
     AND    asgn.primary_flag = ''Y''
     AND    papp.appraisal_date BETWEEN asgn.effective_start_date AND asgn.effective_end_date
     AND    ppos.person_id = asgn.person_id
     AND    ppos.period_of_service_id = asgn.period_of_service_id
     AND    papp.appraisal_date  between ppos.date_start
             AND nvl(ppos.actual_termination_date,hr_general.end_of_time)
     AND    ppos.date_start = :p_hire_date
    ';
  --
  -- Case when the assignment_id column is present in per_appraisals (new version)
  --
  IF l_asg_id_in_per_appraisals = 'Y' THEN
    --
    -- capture only those records from per_appraisals table which have the
    -- appraisal system status as COMPLETED (finally submitted records have this status in the
    -- newer version of appraisal) or the open is 'N' (finally submitted records
    -- have this status in the older version of appraisal)
    --
    l_appr_where_sql := l_appr_where_sql||
                        ' AND (papp.appraisal_system_status = ''COMPLETED''
                               OR  papp.open = ''N'')';
    --
    -- If the appraisal table contains the assignment record then the
    -- the appraisal should be collected for the assignment for which the
    -- appraisal is created
    --
    l_appr_asg_where_sql := ' AND  (papp.assignment_id = :p_assignment_id
                                    OR papp.assignment_id is null)';
    --
    -- Do not capture those records in the per_performance_reviews table that have the
    -- corresponding information the per_appraisal table because the SQL query on per_appraisal
    -- has already captured the infromation for this appraisal
    --
    l_perf_where_sql := l_perf_where_sql||
                        ' AND NOT EXISTS (SELECT 1
                                          FROM   per_appraisals papp
                                          WHERE  papp.appraisee_person_id = perf.person_id
                                          AND    papp.event_id            = pevt.event_id
                                          AND    pevt.type                = ''APPRAISAL'')';
    --
  ELSE
    --
    -- capture only those records from per_appraisals table which have the
    -- open as 'N' (finally submitted records have this status in the
    -- older version of performance rating)
    --
    l_appr_where_sql := l_appr_where_sql||
                        ' AND    papp.open = ''N''';
    --
    l_appr_asg_where_sql := ' AND  :p_assignment_id > 0';
    --
  END IF;
  --
  -- Append the performance review related query only when the NORMALIZE_REVIEW_RATING
  -- fast formula has been defined.
  --
  l_review_ff_id  := get_review_ff;
  --
  -- Form the final query
  -- 4259647 Order by last update date
  --
  IF l_review_ff_id IS NOT NULL THEN
    --
    l_perf_sql:= l_perf_select_sql     ||' '||
                 l_perf_where_sql      ||' '||
                 ' UNION ALL '         ||
                 l_appr_select_sql     ||' '||
                 l_appr_where_sql      ||' '||
                 l_appr_asg_where_sql  ||' '||
                 ' ORDER BY 2, 3';
    --
  ELSE
    --
    -- 4457702 Added the additional bind variable :p_business_group_id and :p_hire_date
    -- to the query to ensure that the cursor in asg events does not fail.
    --
    l_perf_sql:= l_appr_select_sql     ||' '||
                 l_appr_where_sql      ||' '||
                 ' AND    :p_business_group_id is not null
                   AND    papp.appraisee_person_id = :p_person_id
                   AND    papp.appraisal_date <= :p_end_date_active
                   AND    :p_hire_date is not null '||
                 l_appr_asg_where_sql ||
                 ' ORDER BY 2, 3';
    --
    -- Bug 4105868: Collection Diagnostic Call
    --
    fnd_message.set_name('HRI', 'HRI_407267_REVRTG_WRNGBG_IMPCT');
    --
    l_message := fnd_message.get;
    --
    hri_bpl_conc_log.log_process_info
          (p_msg_type      => 'WARNING'
          ,p_note          => l_message
          ,p_package_name  => 'HRI_BPL_PERF_RATING'
          ,p_msg_sub_group => 'GET_PERF_SQL'
          ,p_sql_err_code  => SQLCODE
          ,p_msg_group     => 'ASG_EVT_FCT');
    --
    output(l_message);
    --
  END IF;
  --
  -- 4300665
  -- The outer query determines the ranking for the appraisal done on the same day,
  -- in such a case the last updated record should be considered for collection.
  -- The ranking feature is used to handle this situation. The asg event program
  -- only includes the records that have rank as 1. In case there are multiple
  -- perf records on the same date the process gives ranks based on last update dt
  -- Note: restriction based on rank is not done in sql as it needs to reported in
  -- the log
  --
  l_outer_select :=
       'select  perf_rating,
                review_date,
                last_update_date,
                nvl((lead(review_date,1) over (order by review_date) - 1),termination_date) end_date,
                performance_review_id,
                perf_review_type,
                app_temp_name,
	        nrmlsd_rating,
                hri_bpl_perf_rating.get_perf_rating_band
                     (nrmlsd_rating,:p_business_group_id,:p_person_id,perf_rating,
                      perf_review_type,app_temp_name ) perf_band,
	        dense_rank() over (partition by review_date
	             order by last_update_date desc)  same_day_rank
         from ( ';
  --
  l_outer_where := ' ) where  nrmlsd_rating is not null';
  --
  -- Include the outer layer of the query which determines the normalized rating and
  -- bnad information
  --
  l_perf_sql := l_outer_select||l_perf_sql||l_outer_where;
  --
  -- Return the query that is formed
  --
  dbg('performance rating query = '|| l_perf_sql);
  --
  RETURN l_perf_sql;
  --
END get_perf_sql;
--
--
-- -----------------------------------------------------------------------------
-- Function to fetch the performance rating band from the normalized performance
-- rating
-- ----------------------------------------------------------------------------
--
FUNCTION get_perf_rating_band
              (p_perf_nrmlsd_rating       NUMBER
              ,p_business_group_id        NUMBER
              ,p_person_id                NUMBER
              ,p_perf_rating_cd           VARCHAR2
              ,p_review_type              VARCHAR2
              ,p_appraisal_template_name  VARCHAR2)
RETURN NUMBER
IS
  --
  l_band                               NUMBER;
  --
  -- Variable to store the message
  --
  l_message                            fnd_new_messages.message_text%TYPE;
  --
  -- Variable to store the message
  --
  l_person_name                        per_all_people_f.full_name%TYPE;
  --
  -- Stores the name of the formula
  --
  l_ff_name                            VARCHAR2(100);
  --
  -- 4293064 Bucket definition should be picked from the bucket customization table
  --
  CURSOR c_bucket (c_bucket VARCHAR2) IS
  SELECT bb.*
  FROM   bis_bucket_customizations bb,
         bis_bucket b
  WHERE  b.short_name = c_bucket
  AND    b.bucket_id  = bb.bucket_id;
  --
  CURSOR c_person_name IS
  SELECT full_name
  FROM   per_all_people_f per
  WHERE  per.person_id = p_person_id
  AND    trunc(sysdate) between  per.effective_start_date and effective_end_date;
  --
BEGIN
  --
  -- Open the cursor only if the global cache record is not populated
  --
  IF g_perf_bucket.bucket_id is null THEN
    --
    OPEN   c_bucket ('HRI_DBI_PERF_BAND_OVERALL');
    FETCH  c_bucket INTO g_perf_bucket;
    CLOSE  c_bucket;
    --
  END IF;
  --
  -- Identify the band withing which the normalized rating falls and return the value
  --
  IF p_perf_nrmlsd_rating between g_perf_bucket.range1_low and g_perf_bucket.range1_high THEN
    --
    l_band := 1;
    --
  ELSIF p_perf_nrmlsd_rating between g_perf_bucket.range2_low and g_perf_bucket.range2_high THEN
    --
    l_band := 2;
    --
  ELSIF p_perf_nrmlsd_rating between g_perf_bucket.range3_low and g_perf_bucket.range3_high THEN
    --
    l_band := 3;
    --
  ELSE

    --
    -- 4104051 When the formula returns a values which cannot be classified into any of the
    -- bands, mark the process as warning and also write to the log file. The normalized
    -- rating should be set to -5 (using global g_perf_not_rated_id)
    --
    l_band := g_perf_not_rated_id;
    --
    -- Determine all the context values that are to be passed to the formula
    -- Get the name of the formula for displaying it in the message
    --
    IF p_appraisal_template_name is not null THEN
      --
      l_ff_name  := 'NORMALIZE_APPRAISAL_RATING';
      --
    ELSE
      --
      l_ff_name  := 'NORMALIZE_REVIEW_RATING';
      --
    END IF;
    --
    -- Determine person name
    --
    OPEN   c_person_name;
    FETCH  c_person_name into l_person_name;
    CLOSE  c_person_name;
    --
    -- Bug 4105868: Collection Diagnostic Call
    -- 4237434 The name of the formula was wrongly being passed, Because of which
    -- a error was thrown. Changed the name of the message
    --
    fnd_message.set_name('HRI', 'HRI_407289_NRMLZD_RTNG_NOT_CLS');
    --
    fnd_message.set_token('FF_NAME', l_ff_name);
    fnd_message.set_token('PERSON_NAME', l_person_name);
    fnd_message.set_token('BUSINESS_GROUP_ID',
                           hr_general.decode_organization(p_business_group_id));
    fnd_message.set_token('APPRAISAL_TEMPLATE_NAME', p_appraisal_template_name);
    fnd_message.set_token('REVIEW_TYPE', p_review_type);
    fnd_message.set_token('PERF_RATING_CD', p_perf_rating_cd);
    fnd_message.set_token('PERF_NRMLSD_RATING', p_perf_nrmlsd_rating);
    --
    l_message := nvl(fnd_message.get, SQLERRM);
    --
    hri_bpl_conc_log.log_process_info
            (p_msg_type      => 'WARNING'
            ,p_note          => l_message
            ,p_package_name  => 'HRI_BPL_PERF_RATING'
            ,p_msg_sub_group => 'GET_PERF_RATING_BAND'
            ,p_sql_err_code  => SQLCODE
            ,p_msg_group     => 'ASG_EVT_FCT');
    --
    output(l_message);
    --
  END IF;
  --
  RETURN l_band;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    IF c_bucket%ISOPEN THEN
      --
      CLOSE c_bucket;
      --
    END IF;
    --
    RAISE;
    --
END get_perf_rating_band;
--
BEGIN
 --
 -- The g_concurrent_flag should be set if the process is running through conc manager
 --
 IF fnd_global.conc_request_id is not null THEN
   --
   g_concurrent_flag := 'Y';
   --
 END IF;
 --
END HRI_BPL_PERF_RATING;

/
