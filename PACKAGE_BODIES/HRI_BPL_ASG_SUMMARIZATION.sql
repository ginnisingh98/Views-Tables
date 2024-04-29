--------------------------------------------------------
--  DDL for Package Body HRI_BPL_ASG_SUMMARIZATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_ASG_SUMMARIZATION" AS
/* $Header: hribasum.pkb 120.0 2005/10/05 22:32:00 anmajumd noship $ */
  --
  c_summarization_rqd_ff_name CONSTANT VARCHAR2(30):= 'HRI_MAP_ASG_SUMMARIZATION';
  --
  g_summarization_rqd_ff_id NUMBER;
  --
  /* Type of caching record to store the output of fast formula,       */
  /* By using the outputs in this records, the number of fast formula  */
  /* calls will reduce                                                 */

  TYPE ff_output_rec IS RECORD
      (summarization_rqd   VARCHAR2(1)
       );

  TYPE g_ff_ouptut_tab_type IS TABLE OF ff_output_rec INDEX BY VARCHAR2(480);

  g_summarization_rqd_cache          g_ff_ouptut_tab_type;

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
  -- Cursor to fetch assignment summarization fast formula
  --
  CURSOR c_summarization_rqd_formula IS
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
  OPEN  c_summarization_rqd_formula;
  FETCH c_summarization_rqd_formula INTO l_ff_id;
  CLOSE c_summarization_rqd_formula;
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
--
-- ----------------------------------------------------------------------------
-- Returns the fast formula id
-- ----------------------------------------------------------------------------
--
FUNCTION get_summarization_rqd_ff_id
RETURN NUMBER
IS
--
BEGIN
  --
  -- Check if the formula_id is already cached
  --
  IF g_summarization_rqd_ff_id IS NULL THEN
    --
    g_summarization_rqd_ff_id := ff_exists_and_compiled
                            (p_business_group_id   => 0
                            ,p_date                => trunc(SYSDATE)
                            ,p_ff_name             => c_summarization_rqd_ff_name
                            );
    --
    IF (g_summarization_rqd_ff_id IS NULL) AND (g_warning_flag = 'N') THEN
      --
      g_warning_flag := 'Y';
      --
      output('The fast formula' || ' ' || c_summarization_rqd_ff_name || ' ' || 'is not defined in business_group_id = 0');
      --
      RETURN g_summarization_rqd_ff_id;
      --
    END IF;
    --
  END IF;
  --
  RETURN g_summarization_rqd_ff_id;
  --
END get_summarization_rqd_ff_id;
--
-- ----------------------------------------------------------------------------
--  Runs the fast formula and gets the result.
-- ----------------------------------------------------------------------------

PROCEDURE run_summarization_rqd_rule(p_business_group_id IN NUMBER,
                                     p_assignment_id IN NUMBER,
                                     p_effective_date IN DATE,
                                     p_summarization_rqd OUT NOCOPY VARCHAR2
                                     )
IS
  --
  l_ff_id        NUMBER;
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
   l_ff_id := get_summarization_rqd_ff_id;
   --
   -- In case a formula is not defined then return 'Y'
   --
   IF l_ff_id IS NULL THEN
     --
     p_summarization_rqd := 'Y';
     --
     RETURN;
     --
   END IF;
   --
   -- If the assignment id is available in the cache, then return the value stored in the
   -- cache instead of calling fast formula
   --
   -- BEGIN
     --
     -- p_summarization_rqd := g_summarization_rqd_cache(p_assignment_id || p_effective_date).summarization_rqd;
     --
     --  RETURN;
     --
     --  EXCEPTION
     --
     --    WHEN OTHERS THEN
     --
     --    NULL;
     --
     --  END;
       --
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
             --
             --
             l_inputs(l_loop_count).value := fnd_date.date_to_canonical(SYSDATE);
             --
           ELSIF upper(l_inputs(l_loop_count).name) = 'ASSIGNMENT_ID' THEN
             --
             l_inputs(l_loop_count).value := p_assignment_id;
             --
           ELSIF l_inputs(l_loop_count).name = 'EFFECTIVE_DATE' THEN
             --
             l_inputs(l_loop_count).value := fnd_date.date_to_canonical(p_effective_date);
             --
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
        IF upper(l_outputs(l_loop_count).name) = 'INCLUDE_IN_REPORTS' THEN
        --
        p_summarization_rqd := l_outputs(l_loop_count).value;
        --
        END IF;
        --
      END LOOP;
      --
    END IF;
    --
    -- Store the values in cache
    --
    -- g_summarization_rqd_cache(p_assignment_id || p_effective_date).summarization_rqd := NVL(p_summarization_rqd,'Y');
    --
 END run_summarization_rqd_rule;

--
-- ----------------------------------------------------------------------------
-- Retuns N, if summarization is not required, Else, returns Y
-- ----------------------------------------------------------------------------
--
FUNCTION is_summarization_rqd(p_assignment_id IN NUMBER,
                              p_effective_date IN DATE)
RETURN VARCHAR2
IS
--
l_summarization_rqd VARCHAR2(1);
--
BEGIN
  --
  -- Call to run the fast formula to know if the assignment needs to be summarized
  --
  run_summarization_rqd_rule
    (p_business_group_id => 0,
     p_assignment_id => p_assignment_id,
     p_effective_date => p_effective_date,
     p_summarization_rqd => l_summarization_rqd);
  --
  RETURN l_summarization_rqd;
  --
END is_summarization_rqd;
--
END hri_bpl_asg_summarization;

/
