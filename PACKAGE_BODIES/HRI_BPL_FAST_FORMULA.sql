--------------------------------------------------------
--  DDL for Package Body HRI_BPL_FAST_FORMULA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_FAST_FORMULA" AS
/* $Header: hribffl.pkb 120.0 2005/05/29 06:52:57 appldev noship $ */
-- ----------------------------------------------------------------------------
-- PURPOSE OF PACKAGE
-- ~~~~~~~~~~~~~~~~~~
-- This a generic fast formula package created in support of HRI and HRI DBI
--
-- The urpose of the package is to either generate or compile specific fast
-- formulas required by HRI.
--
-- CURRENT STATUS
-- ~~~~~~~~~~~~~~
-- Currently this patch only supports the fast formula
-- 'NORMALIZE_APPRAISAL_RATING', which is implimented in HRI DBI 6.0H.
-- However the intention is that in the future it will be extended to either:
--  + Compile fast formulas required by HRI if they exist, but are not
--    compiled.
--  + Generate fast formulas required by HRI, if they do not exist, and then
--    compile them.
--
-- ----------------------------------------------------------------------------
-- DEFINE GLOBALS
--
g_debug_flag VARCHAR2(1) := NVL(fnd_profile.value('HRI_ENBL_DTL_LOG'),'N');
--
-- Global used to store the previous rating scale id used.
--
g_rating_scale_id NUMBER;
--
-- Global used to store the number of ratings in the scale g_rating_scale_name
--
g_rating_scales NUMBER;
--
-- Global variable used to store the formula type id for the QuickPaint
-- type of fastformula.
--
g_formula_type_id ff_formula_types.formula_type_id%TYPE;
--
g_msg_sub_group           VARCHAR2(400) := '';
--
-- END DEFINE GLOBALS
--
-- -----------------------------------------------------------------------------
--
-- DEFINE GLOBAL CONSTANTS
--
c_OUTPUT_LINE_LENGTH CONSTANT NUMBER := 254;
--
-- RETURN Character
-- NOTE: please note this MUST be on 2 lines of code i.e.:
-- c_RETURN VARCHAR2(1) DEFAULT '
-- ';
--
c_RETURN CONSTANT VARCHAR2(1) := '
';
--
-- Standard performance fast formula introduction text
--
c_Perf_FF_intro_text CONSTANT VARCHAR2(250) :=
'INPUTS are APPRAISAL_TEMPLATE_NAME (Text),
	    RATING
DEFAULT for APPRAISAL_TEMPLATE_NAME is ''###''
DEFAULT for RATING is 0
SKIP_REVIEW = ''Y''
';
--
-- Standard performance fast formula closing text
--
c_Perf_FF_clsng_text CONSTANT VARCHAR2(250) :=
'RETURN SKIP_REVIEW, NORMALIZED_RATING';
--
-- The performance appraisal fastformula name
--
c_prf_aprsl_ff_name CONSTANT VARCHAR2(30) := 'NORMALIZE_APPRAISAL_RATING';
--
--
-- END DEFINE GLOBAL CONSTANTS
--
-- --------------------------------------------------------------
-- Procedure msg logs a message, either using fnd_file, or
-- hr_utility.trace
--
PROCEDURE msg(p_text IN VARCHAR2) IS
--
BEGIN
  --
  -- Bug 4105868: Collection Diagnostics
  --
  HRI_BPL_CONC_LOG.output(p_text);
  --
END msg;
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
-- Procedure design to faithfully display the text passed to it
-- without corrupting the layout. This procedure may be slow,
-- and should only be used where specifically required e.g. to display
-- dynamically generated code.
--
--
PROCEDURE display (p_text IN VARCHAR2 DEFAULT NULL)
IS
  --
  -- Counter used by loop
  --
  i NUMBER;
  j NUMBER;
  --
  -- The length of the input parameter p_text
  --
  l_text_len NUMBER := LENGTH (p_text);
  --
  -- The current character being processed
  --
  c VARCHAR2(1);
  --
  -- The text string being generated.
  --
  l_text VARCHAR2(78);
  --
  -- The maximum length of the text before displaying it.
  --
  l_max_line_len NUMBER DEFAULT 78;
  --
BEGIN
  --
  -- If debugging is not turned on, exit the procedure
  --
  IF g_debug_flag <> 'Y'
  THEN
    --
    RETURN;
    --
  END IF;
  --
  l_text := '';
  j := 0;
  --
  FOR i IN 1 .. l_text_len
  LOOP
    --
    c := SUBSTR (p_text, i, 1);   -- Fetch current character
    --
    -- If a return character is found display text so far
    -- and re-set line length counter
    --
    IF c = c_RETURN
    THEN
      --
      fnd_file.put_line(fnd_file.LOG,l_text);
      l_text := '';
      j := 0;
      --
    --
    -- If the maximum line length is reached, display the text so far,
    -- and re-set line length counter
    --
    ELSIF j = l_max_line_len
    THEN
      --
      fnd_file.put_line(fnd_file.LOG,l_text);
      l_text := '';
      j := 0;
      --
    ELSE
      --
      -- Add the current char to the text string to display and
      -- increment the line length counter 'j'
      --
      l_text := l_text||c;
      j := j + 1;
      --
    END IF;
    --
  END LOOP;
  --
  -- If there is any left over text that is undisplayed then output it.
  --
  IF j > 0
  THEN
    --
    fnd_file.put_line(fnd_file.LOG,l_text);
    --
  END iF;
  --
END display;
--
-- -----------------------------------------------------------------------------
-- Procedure to generate the standard error text for the main entry point
-- procedures.
--
PROCEDURE failure_exit_message IS
  --
  l_message                fnd_new_messages.message_text%TYPE;
  --
BEGIN
  --
  -- Bug 4105868: Collection Diagnostics
  --
  fnd_message.set_name('HRI', 'HRI_407290_FF_FLD_CMPL');
  --
  l_message := fnd_message.get;
  --
  hri_bpl_conc_log.log_process_info
          (p_msg_type      => 'ERROR'
          ,p_note          => l_message
          ,p_package_name  => 'HRI_BPL_FAST_FORMULA'
          ,p_msg_sub_group => 'FAILURE_EXIT_MESSAGE'
          ,p_sql_err_code  => SQLCODE
          ,p_msg_group     => 'FST_FTML_CHCK'
          );
  --
  msg(l_message);
  --
END;
--
-- -----------------------------------------------------------------------------
-- Procedure used by the EXCEPTION statements in the main entry point
-- procedures called from DBI request sets.
--
-- This procedure will output a standard error message and set the status of
-- the process to 'WARNING' rather than error, to prevent fastformula issues
-- halting the request set.
--
--
PROCEDURE handle_exit_exception IS
  --
  -- Return value from call to fnd_concurrent.set_completion_status
  --
  l_success BOOLEAN DEFAULT FALSE;
  --
BEGIN
  --
  -- Output standard failure message.
  --
  failure_exit_message;
  --
  -- Set process status to 'WARNING' if there has been an error
  -- rather than 'ERROR', so that this process failing does not stop
  -- the entire request set.
  --
  l_success := fnd_concurrent.set_completion_status (
                                       'WARNING'
                                      ,NULL);
  --
END handle_exit_exception;
--
-- ----------------------------------------------------------------------------
-- This function returns true if the env is a shared HR env, or force
-- foundation profile option has been set to Yes.
--
FUNCTION check_if_shared_hr RETURN BOOLEAN
IS
  --
  -- Variable used to store whether or not shared HR is installed.
  --
  l_hr_installed         VARCHAR2(30); -- Stores HR installed or not
  --
  -- Varibale stores whether shared HR mode has been forced or not.
  --
  l_frc_shrd_hr_prfl_val VARCHAR2(30); -- Variable to store value for
                                       -- Profile HRI:DBI Force Foundation HR Processes
  --
BEGIN
  --
  -- Check if this we are on a shared HR environment
  --
  l_frc_shrd_hr_prfl_val := NVL(fnd_profile.value('HRI_DBI_FORCE_SHARED_HR'),'N');
  l_hr_installed         := hr_general.chk_product_installed(800);
  --
  -- If we are in a shared HR environment, then fast formula are not required
  -- and the process should do nothing.
  --
  IF l_hr_installed = 'FALSE'
     OR l_frc_shrd_hr_prfl_val = 'Y'
  THEN
    --
    -- Separation of the full stop (period) '.' for GSCC standards.
    --
    dbg('This system has been configured for Shared HRMS'||'.');
    dbg('FastFormula are not required in a shared HR environment.');
    dbg('No further processing required.');
    --
    -- Shared HR mode is set so return true.
    --
    RETURN TRUE;
    --
  END IF;
  --
  -- Shared HR mode is not set, so return FALSE
  --
  dbg('Shared HR mode not detected');
  --
  RETURN FALSE;
  --
END check_if_shared_hr;
--
-- ----------------------------------------------------------------------------
-- Compile all fast formulas with a given name.
--
PROCEDURE compile_fast_formula (p_fast_formula_name IN VARCHAR2)
IS
  --
  -- The request id of the sub process submitted to compile the fastformula
  --
  l_request_id   NUMBER;
  --
BEGIN
  --
  dbg('Attempting to compile fastformula '||p_fast_formula_name||'.');
  --
  l_request_id :=
    fnd_request.submit_request
      (
       application => 'FF' -- Fast Formula application code
      ,program     => 'SINGLECOMPILE' -- Name of concurrent process
      ,sub_request => TRUE -- Indicates that the request should be
                           -- executed as a sub process.
      ,argument1   => 'QuickPaint' -- FastFormula Type
      ,argument2   => p_fast_formula_name -- Name of fast formula to compile
      );
  --
  dbg('Called sub process to compile fastformula '||p_fast_formula_name||'.');
  --
  -- Tell the process to pause awaiting sub process completion.
  --
  dbg('Tell process to wait for sub process to compile fastformula '||
      p_fast_formula_name||'.');
  --
  fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                  request_data=> TO_CHAR(l_request_id));
  --
  dbg('Waiting for sub process to compile fastformula '||
      p_fast_formula_name||'.');
  --
  RETURN;
  --
EXCEPTION
  --
  WHEN OTHERS
  THEN
    --
    dbg('An error occurred while trying to launch a slave process to '||
        'compile all performance appraisal fastformulas.');
    --
  --
END compile_fast_formula;
--
--
-- ----------------------------------------------------------------------------
-- Compile all performance appraisal (Self Service) fast formulas.
--
PROCEDURE compile_prfrmnc_apprsl_ff
IS
  --
BEGIN
  --
  compile_fast_formula (c_prf_aprsl_ff_name);
  --
  RETURN;
  --
END compile_prfrmnc_apprsl_ff;
--
-- ----------------------------------------------------------------------------
-- This function returns true if the program is re-entering after having
-- suspended for a sub-process to complete.
--
FUNCTION check_if_re_entered RETURN BOOLEAN
IS
  --
  -- Used to store the return value of fnd_conc_global.request_data. If
  -- it is non null then this indicates that the process has returned
  -- from a paused state.
  --
  l_request_data VARCHAR2(240);
  --
  -- Store the request id of the sub process launched to run PYUGEN.
  --
  l_request_id   NUMBER;
  --
  -- Local variables used to store details of successfully completed
  -- sub processes.
  --
  l_phase       VARCHAR2(240); -- Dummy output variable that is ignored.
  l_status      VARCHAR2(240); -- Dummy output variable that is ignored.
  l_dev_phase   VARCHAR2(240); -- Dummy output variable that is ignored.
  l_dev_status  VARCHAR2(240); -- Set to NORMAL if the sub process ended
                               -- successfully.
  l_message     VARCHAR2(240); -- Dummy output variable that is ignored.
  l_success     BOOLEAN;
  --
BEGIN
  --
  -- Call fnd_conc_global.request_data, to see if this program is re-entering
  -- after being paused.
  --
  l_request_data := fnd_conc_global.request_data;
  --
  -- NOTE!!!  THE FOLLOWING CODE WITHIN THE CONDITION:
  -- 'IF l_request_data IS NOT NULL', is only run after re-entering the
  -- package when sub processes have completed.
  --
  IF l_request_data IS NOT NULL
  THEN
    --
    dbg('Re-starting after sub-process completion ......');
    --
    -- Get the request_id of the sub process previously executed so that we
    -- can check it's status.
    --
    l_request_id := TO_NUMBER(l_request_data);
    --
    -- Check whether the sub process finished successfully.
    --
    l_success := fnd_concurrent.get_request_status
      (
       request_id      => l_request_id
      ,appl_shortname  => NULL
      ,program         => NULL
      ,phase           => l_phase
      ,status          => l_status
      ,dev_phase       => l_dev_phase
      ,dev_status      => l_dev_status
      ,message         => l_message
      );
    --
    -- Set Varchar2 equivalent (l_success_chr) of l_success
    --
    IF l_success
    THEN
      --
      -- Debug info
      --
      dbg('Sub process finished with status '||l_dev_status||'.');
      --
      -- If l_dev_status 'NORMAL', then that means the sub process was
      -- successful.
      --
      IF l_dev_status <> 'NORMAL'
      THEN
        --
        -- The sub process failed so raise an exception
        --
        dbg('The FastFormula compilation sub process failed. Raising an exception.');
        --
        RAISE  sub_process_failed;
        --
      ELSE
        --
        -- The sub process completed successfully so end.
        --
        dbg('The FastFormula compilation sub process ended successfully.');
        --
        RETURN TRUE;
        --
      END IF;
      --
    ELSE
      --
      -- Details of the sub process can not be found for some reason, so
      -- raise an exception.
      --
      dbg('Cannot identify completion status for FastFormula compilation sub process');
      --
      RAISE sub_process_not_found;
      --
    END IF;
    --
  --
  -- If we are not returning from a sub process, then return FALSE.
  --
  ELSE
    --
    RETURN FALSE;
    --
  END IF; -- End process re-entered logic.
  --
END check_if_re_entered;
--
-- ----------------------------------------------------------------------------
-- Function that returns the default percentile value to use, for a given
-- step on the rating scale.
--
FUNCTION get_percentile_value (p_scale_cnt NUMBER) RETURN NUMBER
IS
  --
  -- Stores the percentile value to use for the current step on the rating
  -- scale.
  --
  l_pcntl_value NUMBER;
  --
BEGIN
  --
  -- If this is the first step in the scale, return 1 as the percventile
  -- value.
  --
  IF p_scale_cnt = 1
  THEN
    --
    l_pcntl_value := 1;
    --
  --
  -- If the step is in not the top or the bottom of the scale
  -- then calculate the percentile value, based on the current step
  -- and the total number of steps.
  --
  ELSIF p_scale_cnt > 1 AND
        p_scale_cnt < g_rating_scales
  THEN
    --
    l_pcntl_value := ROUND(((100/(g_rating_scales - 1))*(p_scale_cnt - 1)),0);
    --
  ELSIF p_scale_cnt = g_rating_scales
  THEN
    --
    l_pcntl_value := 100;
    --
  END IF;
  --
  -- Return the percentile value
  --
  RETURN l_pcntl_value;
  --
END get_percentile_value;
--
-- ----------------------------------------------------------------------------
--
-- Get the QuickPaint formula_type_id
--
PROCEDURE set_quick_paint_ff_type_id
IS
  --
  -- Cursor to find out the formula type id of the QuickPaint fast formula
  -- type.
  --
  CURSOR c_ff_type_id IS
    SELECT formula_type_id
    FROM ff_formula_types
    WHERE formula_type_name = 'QuickPaint';
  --
BEGIN
  --
  OPEN   c_ff_type_id;
  FETCH  c_ff_type_id INTO g_formula_type_id;
  CLOSE  c_ff_type_id;
  --
END set_quick_paint_ff_type_id;
--
--
-- ----------------------------------------------------------------------------
--
-- Check if a fast formula with a given name exists in a business group
--
FUNCTION check_fast_formula_exists
  (
   p_business_group_id NUMBER
  ,p_formula_name VARCHAR2
  )
  RETURN BOOLEAN
IS
  --
  -- Cursor to find out the formula type id of the QuickPaint fast formula
  -- type.
  --
  CURSOR csr_formula_exists (cp_business_group_id   NUMBER
                          ,cp_formula_name        VARCHAR2)
  IS
    SELECT 'x' l_exists
    FROM ff_formulas_f
    WHERE business_group_id = cp_business_group_id
    AND   formula_name      = cp_formula_name;

    t_rec csr_formula_exists%rowtype;
  --
  -- Dummy variable to store the value returned by cursor c_formula_exists.
  --
  l_formula_exists VARCHAR2(100);
  --
  -- Stores the number of rows returned
  --
  l_row_count NUMBER DEFAULT 0;
  --
BEGIN
  --
  dbg('Checking formula exists ...');
  dbg('Business Group Id: '||TO_CHAR(p_business_group_id));
  dbg('Formula: '||p_formula_name);
  --
  -- Look for fast formula. If it is found set l_row_count to 1
  --
  FOR t_rec IN csr_formula_exists (p_business_group_id, p_formula_name)
  LOOP
    --
    l_row_count := 1;
    --
  END LOOP;
  --
  dbg('Checked whether formula exists ...');
  --
  -- IF a row has been found return TRUE, otherwise return FALSE
  --
  IF l_row_count = 1
  THEN
    --
    dbg('Returning fastformula exists ...');
    --
    RETURN TRUE;
    --
  ELSE
    --
    dbg('Returning fastformula does not exist ...');
    --
    RETURN FALSE;
    --
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    dbg('Exception occurred while checking if fastformula exists ...');
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'CHECK_FAST_FORMULA_EXISTS');
    --
    -- A row has not been found, so return false.
    --
    RAISE;
  --
END check_fast_formula_exists;
--
--
-- ----------------------------------------------------------------------------
--
-- Check if a fast formula with a given name exists in a business group
--
FUNCTION check_fast_formula_cmpld
  (
   p_business_group_id NUMBER
  ,p_formula_name VARCHAR2
  )
  RETURN BOOLEAN
IS
  --
  -- Cursor to find out if a given fast formula is compiled for a specific
  -- business group.
  --
  CURSOR csr_formula_compiled (cp_business_group_id NUMBER
                              ,cp_formula_name      VARCHAR2)
  IS
    --
    SELECT 'x' l_exists
    FROM
       ff_formulas_f       frm
      ,ff_compiled_info_f  fcp
    WHERE frm.formula_id        = fcp.formula_id
    AND   frm.business_group_id = cp_business_group_id
    AND   frm.formula_name      = cp_formula_name;
    --
    t_rec csr_formula_compiled%rowtype;
  --
  -- Dummy variable to store the value returned by cursor c_formula_exists.
  --
  l_formula_compiled VARCHAR2(100);
  --
  -- Stores the number of rows returned
  --
  l_row_count NUMBER DEFAULT 0;
  --
BEGIN
  --
  dbg('Checking whether an existing FastFormula is compiled.');
  --
  dbg('Business Group Id: '||TO_CHAR(p_business_group_id));
  dbg('Fast Formula Name: '||p_formula_name);
  --
  -- Look for fast formula. If it is found set l_row_count to 1
  --
  FOR t_rec IN csr_formula_compiled (p_business_group_id, p_formula_name)
  LOOP
    --
    l_row_count := 1;
    --
  END LOOP;
  --
  dbg('Checked whether FastFormula compiled ...');
  --
  -- IF a row has been found return TRUE, otherwise return FALSE
  --
  IF l_row_count = 1
  THEN
    --
    dbg('The FastFormula was already compiled ...');
    --
    RETURN TRUE;
    --
  ELSE
    --
    dbg('The FastFormula requires compilation ...');
    --
    RETURN FALSE;
    --
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    dbg('Exception occurred while checking if FastFormula compiled ...');
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'CHECK_FAST_FORMULA_CMPLD');
    --
    -- A row has not been found, so return false.
    --
    RAISE;
  --
END check_fast_formula_cmpld;
--
-- ----------------------------------------------------------------------------
-- This procedure adds the static initialization and end code to
-- the fast formula, and creates the first formula for the relevant business
-- group.
--
PROCEDURE generate_performance_formula(p_business_group_id IN NUMBER
                                      ,p_formula_text IN OUT NOCOPY VARCHAR)
IS
  --
  -- Stores the last_update_date returned by ff_formulas_f_pkg.insert_row
  --
  l_last_update_date DATE;
  --
  -- Stores the rowid returned by ff_formulas_f_pkg.insert_row
  --
  l_Rowid        VARCHAR2(240);
  --
  -- End of time
  --
  l_end_date DATE DEFAULT hr_general.end_of_time;
  --
  -- Stores the formula_id returned by ff_formulas_f_pkg.insert_row
  --
  l_Formula_Id   ff_formulas_f.formula_id%TYPE DEFAULT NULL;
  --
  -- Stores the name of the fast formula that we are trying to save.
  --
  l_formula_name ff_formulas_f.formula_name%TYPE DEFAULT c_prf_aprsl_ff_name;
  --
  -- Stores the legislation code for the current business group
  --
  l_legislation_code per_business_groups.legislation_code%TYPE;
  --
BEGIN
  --
  -- Create the FF text for the current business group.
  --
  p_formula_text :=
    c_Perf_FF_intro_text
	||
    p_formula_text
    ||
	c_Perf_FF_clsng_text;
  --
  -- Output final formula text
  --
  dbg('---------------------------------------------------------------------');
  dbg('p_formula_text:');
  display(p_formula_text);
  dbg('---------------------------------------------------------------------');
  --
  -- Insert the formula into the base table.
  --
  BEGIN
    --
    -- 4106225 The legislation code for the formula should not be set. It is set
    -- only for global legislative formulas that are shipped out of the
    -- the box. Any user created formula should not have this set, or else the
    -- formula will not show up on the PUI if the bg's legislation is changed
    -- l_legislation_code is set to null by default
    --
    ff_formulas_f_pkg.Insert_Row
            (
             X_Rowid                => l_rowid
            ,X_Formula_Id           => l_formula_id
            ,X_Effective_Start_Date => hr_general.start_of_time
            ,X_Effective_End_Date   => l_end_date
            ,X_Business_Group_Id    => p_business_group_id
            ,X_Legislation_Code     => l_legislation_code
            ,X_Formula_Type_Id      => g_Formula_Type_Id
            ,X_Formula_Name         => l_formula_name
            ,X_Description          => l_formula_name
            ,X_Formula_Text         => p_formula_text
            ,X_Sticky_Flag          => NULL
            ,X_Last_Update_Date     => l_last_update_date
            );
  EXCEPTION
    --
    WHEN OTHERS THEN
      dbg('An error was encountered while inserting the generated fastformula');
      msg(fnd_message.get);
      --
      g_msg_sub_group := NVL(g_msg_sub_group, 'GENERATE_PERFORMANCE_FORMULA');
      --
      RAISE;
    --
  END;
  --
  -- COMMIT the formula that has been created to the database.
  --
  COMMIT;
  --
  dbg('Generated formula has been successfully created ...');
  --
  --
END;
--
-- ----------------------------------------------------------------------------
-- This FUNCTION returns the number of levels in a particular rating scale
--
FUNCTION get_number_of_levels (p_rating_scale_id IN NUMBER) RETURN NUMBER
IS
  --
  CURSOR csr_rating_template_scales (cp_rating_scale_id NUMBER) IS
    SELECT COUNT(step_value)
    FROM   per_rating_levels
    WHERE rating_scale_id = cp_rating_scale_id;
  --
  -- Used to store the number of levels in the rating scale.
  --
  l_rating_levels NUMBER;
  --
BEGIN
  --
  -- If the rating scale name is the same as the one previously used,
  -- then return the previous rating scale value
  --
  IF p_rating_scale_id = g_rating_scale_id
  THEN
    --
    RETURN g_rating_scales;
    --
  END IF;
  --
  -- get the number of ratings in the scale as we don't have it cached.
  --
  OPEN   csr_rating_template_scales (p_rating_scale_id);
  FETCH  csr_rating_template_scales INTO l_rating_levels;
  CLOSE  csr_rating_template_scales;
  --
  -- Store the rating scale id and the number of levels for later use
  --
  g_rating_scale_id := p_rating_scale_id;
  g_rating_scales := l_rating_levels;
  --
  RETURN g_rating_scales;
  --
END get_number_of_levels;
--
-- ----------------------------------------------------------------------------
-- This procedure generates fast formulas where none exist for performance
-- appraisals in either a specific business group, or all business groups
--
-- The following code, is an example of the text that should be
-- generated for a given business groups fast formula.
--
--	INPUTS are APPRAISAL_TEMPLATE_NAME (Text),
--	                     RATING_LEVEL_CODE,
--	DEFAULT for APPRAISL_TEMPLATE_NAME is 'SKIPPP'
--	SKIP_REVIEW = 'YES'
--	IF APPRAISAL_TEMPLATE_NAME = 'Annual Template'
--	THEN
--	 (
--	       SKIP_REVIEW = 'NO'
--	        IF RATING_LEVEL_CODE = 1 then
--	          NORMALIZED_RATING = 1
--	        IF RATING_LEVEL_CODE = 2 then
--	          NORMALIZED_RATING  = 50
--	        IF RATING_LEVEL_CODE = 3 then
--	          NORMALIZED_RATING  = 100
--	)
--	IF APPRAISAL_TEMPLATE_NAME = 'Annual Template for developers'
--	THEN
--	 (
--	       SKIP_REVIEW = 'NO'
--	        IF RATING_LEVEL_CODE = 5 then
--	          NORMALIZED_RATING = 1
--	        IF RATING_LEVEL_CODE = 6 then
--	          NORMALIZED_RATING  = 25
--	        IF RATING_LEVEL_CODE = 7 then
--	          NORMALIZED_RATING  = 50
--	        IF RATING_LEVEL_CODE = 8 then
--	          NORMALIZED_RATING  = 75
--	        IF RATING_LEVEL_CODE = 9 then
--	          NORMALIZED_RATING  = 100
--	)
--	RETURN SKIP_REVIEW, NORMALIZED_RATING
--
--
PROCEDURE gnrt_bg_ss_prfrmnce_apprsl_ff (p_business_group_id IN NUMBER)
IS
  --
  -- Cursor returning all of the appraisal templates, and their step values
  -- for all business groups.
  --
  -- This cursor is used to drive the generation of fast formula for
  -- each business group that requires a formula.
  --
  CURSOR csr_rating_template_scales (cp_business_group_id NUMBER) IS
  SELECT pat.business_group_id
      ,pat.name rating_template_name
      ,prs.name rating_scale_name
      ,prs.rating_scale_id
      ,prl.step_value
  FROM per_appraisal_templates pat
      ,per_rating_scales       prs
      ,per_rating_levels       prl
  WHERE pat.business_group_id = cp_business_group_id
  AND   pat.rating_scale_id   = prs.rating_scale_id
  AND   pat.rating_scale_id   = prl.rating_scale_id
  ORDER BY business_group_id
         , prs.rating_scale_id
         , rating_template_name
         , step_value;
  --
  -- Declare record based on the csr_rating_template_scales cursor
  --
  rating_template_scales_rec csr_rating_template_scales%ROWTYPE;
  --
  -- Declare local variables to store the latest business group and template
  --
  l_business_group_id       NUMBER DEFAULT NULL;
  l_rating_template_name    per_appraisal_templates.name%TYPE DEFAULT NULL;
  --
  -- The string l_formula_text stores the code that has been generated for
  -- a given business group.
  --
  l_formula_text VARCHAR2(32767);
  --
  -- Used to store the number of scales there are for a particular
  -- rating scale.
  --
  l_rating_levels NUMBER;
  --
  -- Counter to indicate at what point on the rating scale you are at.
  --
  l_scale_cnt NUMBER;
  --
  -- Stores the percentile default value for the current step on
  -- the rating scale.
  --
  l_scale_pcnt_value NUMBER;
  --
BEGIN
  --
  dbg('Starting to create a FastFormula for the business group.');
  --
  dbg('Starting to initialize variables ...');
  --
  -- A fastformula does not exist for this business group, so we
  -- need to start the process of creating one.
  --
  ------------------------------------------------------------------------
  --
  -- START Initialize variables variables

  -- Reset varibales affected by change in business group.
  --
  g_rating_scale_id := NULL;
  --
  g_rating_scales := NULL;
  --
  -- Make sure that the formula text is empty
  --
  l_formula_text := '';
  --
  -- Set the current rating template to NULL
  --
  l_rating_template_name := NULL;
  --
  dbg('Finished initializing variables ...');
  --
  -- END Initialize variables variables
  ------------------------------------------------------------------------
  --
  -- For each template and rating scale step, loop through
  -- creating appropriate fastformula code.
  --
  FOR rating_template_scales_rec IN
      csr_rating_template_scales(p_business_group_id)
  LOOP
    --
    dbg('Looping for ....');
    dbg('business_group_id: '||TO_CHAR(rating_template_scales_rec.business_group_id));
    dbg('rating_template_name: '||rating_template_scales_rec.rating_template_name);
    dbg('rating_scale_name: '||rating_template_scales_rec.rating_scale_name);
    dbg('step_value: '||rating_template_scales_rec.step_value);
    --
    -- Check to see if the template has changed, or this is the first
    -- time through the loop.
    --
    IF rating_template_scales_rec.rating_template_name <>
       NVL(l_rating_template_name,-1)
    THEN
      --
      -- RESET the scale count
      --
      l_scale_cnt := 1;
      --
      -- Get the number of scales in the current rating template's
      -- rating scale.
      --
      l_rating_levels :=
        get_number_of_levels(rating_template_scales_rec.rating_scale_id);
      --
      dbg('Rating template has changed ...');
      --
      -- IF this is not the very first template for the business group.
      -- then put the end bracket on the current condition.
      --
      IF l_rating_template_name IS NOT NULL
      THEN
        --
        dbg('Closing previous template condition ...');
        --
        l_formula_text := l_formula_text||
        ')';
        --
      END IF;
      --
      l_formula_text := l_formula_text||c_RETURN||
'IF APPRAISAL_TEMPLATE_NAME = '||c_RETURN||
'  '''||rating_template_scales_rec.rating_template_name||'''
THEN
  (
  SKIP_REVIEW = ''N'' '||c_RETURN;
      --
      -- Set the current template that is being processed
      --
      l_rating_template_name
        := rating_template_scales_rec.rating_template_name;
      --
    END IF;
    --
    -- Get the percentile value (l_scale_pcnt_value) for the current
    -- step on the rating scale (l_scale_cnt).
    --
    l_scale_pcnt_value := get_percentile_value(l_scale_cnt);
    --
    -- If this is simply another level in the rating scale, create a new
    -- condition.
    --
    l_formula_text := l_formula_text||
'  IF RATING = '
 ||rating_template_scales_rec.step_value||c_RETURN||
'    THEN
       ( NORMALIZED_RATING = '||l_scale_pcnt_value||' ) '||c_RETURN;
    --
    -- Increment the scale level count
    --
    l_scale_cnt := l_scale_cnt + 1;
    --
    dbg(rating_template_scales_rec.step_value);
    --
  END LOOP;
  --
  -- Finished generating the main body text for the business group.
  -- Now process text ...
  --
  -- Providing we have generated some fastformula text generate the
  -- fast formula for the business group.
  --
  IF LENGTH(l_formula_text) > 0
  THEN
    --
    dbg('Generate formula for previous BG ....');
    --
    -- Cose the condition for the current template
    --
    l_formula_text := l_formula_text||')'||c_RETURN;
    --
    -- Call procedure to complete / generate the fast formula for the
    -- current business group.
    --
    generate_performance_formula(p_business_group_id
                                ,l_formula_text
                                );
    --
  END IF;
  --
  dbg('Successfully created a FastFormula for the business group.');
  --
EXCEPTION
  --
  WHEN OTHERS
  THEN
    --
    dbg('An error occurred while create a FastFormula for the business group.');
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'GNRT_BG_SS_PRFRMNCE_APPRSL_FF');
    --
    RAISE;
    --
  --
END gnrt_bg_ss_prfrmnce_apprsl_ff;
--
-- ----------------------------------------------------------------------------
-- Entry point for the generation of performance appraisal fastformula for a
-- specific business group OR all business groups.
--
FUNCTION gnrt_ss_prfrmnce_apprsl_ff
  (
   p_business_group_id IN NUMBER DEFAULT NULL
  )
RETURN BOOLEAN -- Indicates if a new formula was created
IS
  --
  -- Select all of the business groups, that have appraisal templates,
  -- that have associated rating scales.
  --
  CURSOR csr_rtng_tmplt_bsnss_grps IS
    SELECT DISTINCT pat.business_group_id business_group_id
    FROM   per_appraisal_templates pat
    WHERE  rating_scale_id IS NOT NULL
    ORDER  BY business_group_id;
  --
  -- Declare record based on the csr_rtng_tmplt_bsnss_grps cursor
  --
  l_rtng_tmplt_bsnss_grps csr_rtng_tmplt_bsnss_grps%ROWTYPE;
  --
  -- Boolean variable used to indicate a performance appraisal fastformula
  -- exists for a business group.
  --
  l_formula_exists BOOLEAN DEFAULT FALSE;
  --
  -- Indicates if a fastformula compilation is required
  --
  l_formula_cmpl_rqd BOOLEAN DEFAULT FALSE;
  --
  -- Indicates if a fastformula has been compiled
  --
  l_formula_cmpld BOOLEAN DEFAULT TRUE;
  --
BEGIN
  --
  dbg('Starting to process Self Service Performance Appraisal FastFormula(s) ...');
  --
  -- Get the ff type id for the formula type QuickPaint
  --
  set_quick_paint_ff_type_id;
  --
  -- If a specific business group has been passed in, call
  -- gnrt_bg_ss_prfrmnce_apprsl_ff directly for that business group.
  --
  IF p_business_group_id IS NOT NULL
  THEN
    --
    dbg('Checking the Self Service Performance Appraisal FastFormulas for a single business groups.');
    --
    dbg('Processing business group id '||p_business_group_id||'.');
    --
    -- Check whether a fastformula already exists for the business_group.
    -- If the formula does exist then bail out.
    --
    l_formula_exists := check_fast_formula_exists
                        (
                         p_business_group_id
                        ,c_prf_aprsl_ff_name
                        );
    --
    dbg('If formula exixts then do nothing further for this business group');
    --
    IF l_formula_exists
    THEN
      --
      dbg('A FastFormula already exists for this business group.');
      --
      -- If the FastFormula exists already, then check if the formula is
      -- compiled. If the formula is not compiled, set l_formula_cmpl_rqd
      -- to TRUE, to indicate a FastFormula compilation is required.
      --
      l_formula_cmpld := check_fast_formula_cmpld
        (
         p_business_group_id
        ,c_prf_aprsl_ff_name
        );
      --
      -- If the formula is not compiled then set l_formula_cmpl_rqd to
      -- TRUE to indicate FastFormula compilation is required.
      --
      l_formula_cmpl_rqd := NOT(l_formula_cmpld);

      -- Return False to indicate that the no fast formula has been
      -- created.
      --
      RETURN l_formula_cmpl_rqd;
      --
    END IF;
    --
    -- Call gnrt_bg_ss_prfrmnce_apprsl_ff to generate the appraisal
    -- fastformula for the business group.
    --
    dbg('A FastFormula needs to be generated for the business group.');
    --
    gnrt_bg_ss_prfrmnce_apprsl_ff(p_business_group_id);
    --
    RETURN TRUE;
    --
  END IF;
  --
  dbg('Checking the Self Service Performance Appraisal FastFormulas for all relevant business groups.');
  --
  -- If no business group is specified, try to generate fast formula
  -- for all business groups that have appraisal templates.
  --
  FOR l_rtng_tmplt_bsnss_grps IN csr_rtng_tmplt_bsnss_grps
  LOOP
    --
    -- Check whether a performance appraisal fast formula already
    -- exists for the business group.
    --
    --
    dbg('Checking if a FastFormula has been defined for business group id '
      || l_rtng_tmplt_bsnss_grps.business_group_id||'.');
    --
    l_formula_exists := check_fast_formula_exists
                        (
                         l_rtng_tmplt_bsnss_grps.business_group_id
                        ,c_prf_aprsl_ff_name
                        );
    --
    IF l_formula_exists = TRUE
    THEN
      --
      dbg('A formula already exists for this business group.');
      --
      -- If the FastFormula exists already, and we do not have any other
      -- reason yet identified to compile the FastFormula (across business
      -- groups) then check if the formula is compiled. If the formula is not
      -- compiled, set l_formula_cmpl_rqd to TRUE, to indicate a FastFormula
      -- compilation is required.
      --
      IF NOT l_formula_cmpl_rqd
      THEN
        --
        -- Check if the fast formula is compiled for this business group.
        --
        l_formula_cmpld := check_fast_formula_cmpld
          (
           l_rtng_tmplt_bsnss_grps.business_group_id
          ,c_prf_aprsl_ff_name
          );
        --
        -- If the formula is not compiled then set l_formula_cmpl_rqd to
        -- TRU to indicate FastFormula compilation is required.
        --
        l_formula_cmpl_rqd := NOT(l_formula_cmpld);
        --
      END IF;
      --
    --
    -- A formula does not exist and we need to create one
    --
    ELSE
      --
      dbg('A formula needs to be generated for the business group.');
      --
      gnrt_bg_ss_prfrmnce_apprsl_ff(l_rtng_tmplt_bsnss_grps.business_group_id);
      --
      l_formula_cmpl_rqd := TRUE;
      --
    END IF;
    --
  END LOOP;
  --
  dbg('Finished processing Self Service Performance Appraisal FastFormula(s) ...');
  --
  RETURN l_formula_cmpl_rqd;
  --
END gnrt_ss_prfrmnce_apprsl_ff;
--
-- ----------------------------------------------------------------------------
-- Standard Entry point to be called from standalone concurrent process, where
-- a user can generate performance apraisal fastformula for 1 or a number of
-- business groups.
--
PROCEDURE gnrt_ss_prfrmnce_apprsl_ff
  (
   errbuf              OUT NOCOPY VARCHAR2
  ,retcode             OUT NOCOPY NUMBER
  ,p_business_group_id IN NUMBER DEFAULT NULL
  )
IS
  --
  -- Indocates if any formulas have been created.
  --
  l_formula_created BOOLEAN DEFAULT FALSE;
  --
BEGIN
  --
  dbg('Starting FastFormula check (Ad Hoc).');
  --
  -- Debugging on the process is enabled by profile HRI:Enable Detailed Logging
  --
  g_debug_flag := NVL(fnd_profile.value('HRI_ENBL_DTL_LOG'),'N');
  --
  dbg('profile HRI:Enable Detailed Logging = '|| g_debug_flag);
  --
  -- If foundation HR mode is detected then do nothing.
  --
  dbg('Checking if foundation HR mode is selected.');
  --
  IF check_if_shared_hr
  THEN
    --
    dbg('Foundation HR mode is selected.');
    --
    RETURN;
    --
  END iF;
  --
  -- Check if process is re-entering after being suspended
  --
  dbg('Checking if process has been re-entered.');
  --
  IF check_if_re_entered
  THEN
    --
    -- If the process has re-entered with no error the exit.
    --
    dbg('Process has been re-entered.');
    --
    RETURN;
    --
  END IF;
  --
  -- Call function to generate the fast formula(s)
  --
  dbg('Checking / building Performance Appraisal FastFormulas.');
  --
  l_formula_created := gnrt_ss_prfrmnce_apprsl_ff(p_business_group_id);
  --
  -- If formula(s) have been created, then compile them.
  --
  dbg('If any Performance Appraisal FastFormulas have been created or are un-compiled then compile them.');
  --
  IF l_formula_created
  THEN
    --
    dbg('Request Performance Appraisal FastFormula compilation.');
    --
    compile_prfrmnc_apprsl_ff;
    --
    dbg('FastFormula compilation requested.');
    --
  END IF;
  --
  dbg('Finished FastFormula check (Ad Hoc).');
  --
EXCEPTION
  --
  WHEN OTHERS
  THEN
    --
    dbg('Execption has occurred in gnrt_ss_prfrmnce_apprsl_ff.');
    --
    failure_exit_message;
    --
    errbuf := SQLERRM;
    retcode := SQLCODE;
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'GNRT_SS_PRFRMNCE_APPRSL_FF');
    --
    RAISE;
    --
  --
END gnrt_ss_prfrmnce_apprsl_ff;
--
-- ----------------------------------------------------------------------------
-- This procedure deletes performance appraisal fastformulas for a specific
-- business group.
--
PROCEDURE delete_performance_formula(p_business_group_id IN NUMBER)
IS
  --
  -- find the rowid of the fast_formula that we want to delete
  --
  CURSOR csr_formula_rowid (cp_business_group_id NUMBER) IS
    SELECT rowid
    FROM ff_formulas_f
    WHERE formula_name = c_prf_aprsl_ff_name
    AND business_group_id = cp_business_group_id;
  --
  l_row_id VARCHAR2(30);
  --
BEGIN
  --
  -- Find the rowid for the fastformula
  --
  OPEN   csr_formula_rowid (p_business_group_id);
  FETCH  csr_formula_rowid INTO l_row_id;
  CLOSE  csr_formula_rowid;
  --
  -- call API to delete the fast formula
  --
  ff_formulas_f_pkg.Delete_Row
              (
               X_Rowid                  => l_row_id
              ,X_Formula_Id             => NULL
              ,X_Dt_Delete_Mode         => 'DELETE'
              ,X_Validation_Start_Date  => NULL
              ,X_Validation_End_Date    => NULL
              );
  --
  -- COMMIT the formula delete to the database.
  --
  COMMIT;
  --
  dbg('Formula has been successfully deleted ...');
  --
EXCEPTION
  --
  WHEN OTHERS
  THEN
    --
    msg(fnd_message.get);
    dbg('An error was encountered while attempting to delete a fastformula');
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'DELETE_PERFORMANCE_FORMULA');
    --
    RAISE;
  --
END delete_performance_formula;
--
-- ----------------------------------------------------------------------------
-- This procedure deletes all performance appraisal fastformulas
--
PROCEDURE delete_all_prfrmnc_formulas
IS
  --
  -- find all performance appraisal fast formulas
  --
  CURSOR csr_all_prfrmnc_formulas IS
    SELECT rowid
    FROM ff_formulas_f
    WHERE formula_name = c_prf_aprsl_ff_name;
  --
  l_all_prfrmnc_formulas csr_all_prfrmnc_formulas%ROWTYPE;
  --
  l_row_id VARCHAR2(30);
  --
BEGIN
  --
  FOR l_all_prfrmnc_formulas IN csr_all_prfrmnc_formulas
  LOOP
    --
    ff_formulas_f_pkg.Delete_Row
              (
               X_Rowid                  => l_all_prfrmnc_formulas.rowid
              ,X_Formula_Id             => NULL
              ,X_Dt_Delete_Mode         => 'DELETE'
              ,X_Validation_Start_Date  => NULL
              ,X_Validation_End_Date    => NULL
              );
    --
  END LOOP;
  --
  -- COMMIT the formula deletes to the database.
  --
  COMMIT;
  --
  dbg('Formulas have been successfully deleted ...');
  --
EXCEPTION
  --
  WHEN OTHERS
  THEN
    --
    msg(fnd_message.get);
    dbg('An error was encountered while attempting to delete fastformulas');
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'DELETE_ALL_PRFRMNC_FORMULAS');
    --
    RAISE;
  --
END delete_all_prfrmnc_formulas;
--
-- ----------------------------------------------------------------------------
-- This is a standard entry point.
-- This procedure controls the dynamic creation of DBI related fastformulas.
-- This process is designed to be called from a full refresh request set.
--
-- The steps it follows are:
--
-- 1. For all business groups that have appraisal templates, generate a
-- default performance appraisal template.
--
-- 2. If no PUI appraisal formula exists, create a default formula, where
--    all ratings are set to 50% [NOT YET CODED]
--
--
PROCEDURE fastformula_check_full
  (
   errbuf              OUT NOCOPY VARCHAR2
  ,retcode             OUT NOCOPY NUMBER
  )
IS
  --
  -- Indocates if any formulas have been created.
  --
  l_compile_reqd BOOLEAN DEFAULT FALSE;
  --
BEGIN
  --
  dbg('Starting FastFormula check (Full Refresh).');
  --
  hri_bpl_conc_log.record_process_start('HRI_BPL_FAST_FORMULA');
  --
  dbg('profile HRI:Enable Detailed Logging = '|| g_debug_flag);
  --
  -- If foundation HR mode is detected then do nothing.
  --
  dbg('Checking if foundation HR mode is selected.');
  --
  IF check_if_shared_hr
  THEN
    --
    dbg('Foundation HR mode is selected.');
    --
    RETURN;
    --
  END iF;
  --
  -- Check if process is re-entering after being suspended
  --
  dbg('Checking if process has been re-entered.');
  --
  IF check_if_re_entered
  THEN
    --
    -- If the process has re-entered with no error the exit.
    --
    dbg('Process has been re-entered.');
    --
    RETURN;
    --
  END IF;
  --
  -- Call function to generate the fast formula(s). Pass NULL in so that
  -- it will run for all formulas.
  --
  dbg('Checking / building Performance Appraisal FastFormulas.');
  --
  l_compile_reqd := gnrt_ss_prfrmnce_apprsl_ff(NULL);
  --
  -- If formula(s) have been created, then compile them.
  --
  dbg('If any Performance Appraisal FastFormulas have been created or are un-compiled then compile them.');
  --
  IF l_compile_reqd
  THEN
    --
    dbg('Request Performance Appraisal FastFormula compilation.');
    --
    compile_prfrmnc_apprsl_ff;
    --
    dbg(' Performance Appraisal FastFormula compilation requested.');
    --
  END IF;
  --
  dbg('Finished FastFormula check (Full Refresh).');
  --
  -- Bug 4105868: Collection Diagnostics
  --
  hri_bpl_conc_log.log_process_end
          (p_status         => TRUE
          ,p_period_from    => hr_general.start_of_time
          ,p_period_to      => hr_general.end_of_time
          ,p_attribute1     => 'Y'
          );
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    dbg('Execption has occurred in fastformula_check_full.');
    --
    handle_exit_exception;
    --
    errbuf := SQLERRM;
    retcode := SQLCODE;
    --
    -- Bug 4105868: Collection Diagnostics
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'FASTFORMULA_CHECK_FULL');
    --
    hri_bpl_conc_log.log_process_info
            (p_package_name      => 'HRI_BPL_FAST_FORMULA'
            ,p_msg_type          => 'ERROR'
            ,p_msg_group         => 'FST_FTML_CHCK'
            ,p_msg_sub_group     => g_msg_sub_group
            ,p_sql_err_code      => SQLCODE
            ,p_note              => SQLERRM);
    --
    hri_bpl_conc_log.log_process_end
            (p_status         => FALSE
            ,p_period_from    => hr_general.start_of_time
            ,p_period_to      => hr_general.end_of_time
            ,p_attribute1     => 'Y'
            );
    --
    RAISE;
    --
  --
END fastformula_check_full;
--
-- ----------------------------------------------------------------------------
-- This is a standard entry point:
-- This procedure controls the dynamic creation of DBI related fastformulas.
--
-- This process is designed to be called from an incremental refresh request
-- set.
--
-- The steps it follows are:
--
-- 1. For all business groups that have appraisal templates, generate a
-- default performance appraisal template.
--
-- 2. If no PUI appraisal formula exists, create a default formula, where
--    all ratings are set to 50% [NOT YET CODED]
--
PROCEDURE fastformula_check_incr
  (
   errbuf              OUT NOCOPY VARCHAR2
  ,retcode             OUT NOCOPY NUMBER
  )
IS
  --
  -- Indocates if any formulas have been created.
  --
  l_compile_reqd BOOLEAN DEFAULT FALSE;
  --
BEGIN
  --
  dbg('Starting FastFormula check (Incremental Refresh).');
  --
  hri_bpl_conc_log.record_process_start('HRI_BPL_FAST_FORMULA');
  --
  -- If foundation HR mode is detected then do nothing.
  --
  dbg('Checking if foundation HR mode is selected.');
  --
  IF check_if_shared_hr
  THEN
    --
    dbg('Foundation HR mode is selected.');
    --
    RETURN;
    --
  END iF;
  --
  -- Check if process is re-entering after being suspended
  --
  dbg('Checking if process has been re-entered.');
  --
  IF check_if_re_entered
  THEN
    --
    -- If the process has re-entered with no error the exit.
    --
    dbg('Process has been re-entered.');
    --
    RETURN;
    --
  END IF;
  --
  -- Call function to generate the fast formula(s). Pass NULL in so that
  -- it will run for all formulas.
  --
  dbg('Checking / building Performance Appraisal FastFormulas.');
  --
  l_compile_reqd := gnrt_ss_prfrmnce_apprsl_ff(NULL);
  --
  -- If formula(s) have been created, then compile them.
  --
  dbg('If any Performance Appraisal FastFormulas have been created or are un-compiled then compile them.');
  --
  IF l_compile_reqd
  THEN
    --
    dbg('Request Performance Appraisal FastFormula compilation.');
    --
    compile_prfrmnc_apprsl_ff;
    --
    dbg('FastFormula compilation requested.');
    --
  END IF;
  --
  dbg('Finished FastFormula check (Incremental Refresh).');
  --
  -- Bug 4105868: Collection Diagnostics
  --
  hri_bpl_conc_log.log_process_end
          (p_status         => TRUE
          ,p_period_from    => hr_general.start_of_time
          ,p_period_to      => hr_general.end_of_time
          ,p_attribute1     => 'N'
          );
  --
EXCEPTION
  --
  WHEN OTHERS
  THEN
    --
    dbg('Execption has occurred in fastformula_check_incr.');
    --
    handle_exit_exception;
    --
    errbuf := SQLERRM;
    retcode := SQLCODE;
    --
    -- Bug 4105868: Collection Diagnostics
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'FASTFORMULA_CHECK_INCR');
    --
    hri_bpl_conc_log.log_process_info
            (p_package_name      => 'HRI_BPL_FAST_FORMULA'
            ,p_msg_type          => 'ERROR'
            ,p_msg_group         => 'FST_FTML_CHCK'
            ,p_msg_sub_group     => g_msg_sub_group
            ,p_sql_err_code      => SQLCODE
            ,p_note              => SQLERRM);
    --
    hri_bpl_conc_log.log_process_end
            (p_status         => FALSE
            ,p_period_from    => hr_general.start_of_time
            ,p_period_to      => hr_general.end_of_time
            ,p_attribute1     => 'N'
            );
    --
    RAISE;
    --
  --
END fastformula_check_incr;
--
END hri_bpl_fast_formula;

/
