--------------------------------------------------------
--  DDL for Package Body HRI_BPL_SETUP_DIAGNOSTIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_SETUP_DIAGNOSTIC" AS
/* $Header: hribdgsp.pkb 120.9 2006/12/11 09:55:24 msinghai noship $ */

-- =========================================================================
--
-- OVERVIEW
-- --------
-- This package contains procedures to test the set up of DBI on the system.
-- Checks is performed for the following:
--  (a) Profiles
--  (b) Fast Formulas
--  (c) Triggers
--  (d) Key DBI Tables
--  (e) Job Family and Job Function
--  (f) Geography
--
-- DOCUMENT REFERENCE
-- ------------------
-- http://files.oraclecorp.com/content/AllPublic/SharedFolders/HRMS%20
-- Intelligence%20%28HRMSi%29%20-%20Documents-Public/Design%20Specifications
-- /hri_lld_dgn_system_stup.doc
--
-- =========================================================================


  TYPE g_prd_type IS RECORD(
     dbi_ind   NUMBER(10),
     obiee_ind NUMBER(10),
     all_ind   NUMBER(10));

  TYPE g_prd_type_tab IS TABLE OF g_prd_type INDEX BY VARCHAR2(100);

  g_prd_type_tab_v  g_prd_type_tab;

  g_object_name VARCHAR2(100);

  TYPE g_flex_structure_rec_type IS RECORD
   (structure_name           VARCHAR2(240),
    job_family_defined_msg   VARCHAR2(240),
    job_function_defined_msg VARCHAR2(240));

  TYPE g_flex_structure_tab_type IS TABLE OF g_flex_structure_rec_type
                                    INDEX BY VARCHAR2(80);

  g_debugging                BOOLEAN;
  g_setup_rec                NUMBER;
  g_global_start_date        DATE;
  g_functional_area          VARCHAR2(30);

  -- Cursor to fetch records from the Diagnostics Table
  CURSOR c_objects
   (v_object_name      VARCHAR2,
    v_object_type      VARCHAR2,
    v_functional_area  VARCHAR2) IS
  SELECT
   stp.*
  FROM
   hri_adm_dgnstc_setup   stp
  ,hri_adm_dgnstc_sbscrb  sbs
  WHERE stp.object_type= v_object_type
  AND stp.object_name = sbs.object_name
  AND stp.object_type = sbs.object_type
  AND sbs.functional_area_cd = v_functional_area
  AND (v_object_name IS NULL
    OR stp.object_name = v_object_name)
  AND stp.enabled_flag = 'Y'
  AND ((stp.foundation_hr_flag = 'Y' AND
        hri_bpl_system.is_full_hr_installed = 'N')
    OR hri_bpl_system.is_full_hr_installed = 'Y')
  UNION ALL
  SELECT
   stp.*
  FROM
   hri_adm_dgnstc_setup  stp
  WHERE stp.object_type= v_object_type
  AND v_functional_area = 'ALL'
  AND (v_object_name IS NULL
    OR stp.object_name = v_object_name)
  AND stp.enabled_flag = 'Y'
  AND ((stp.foundation_hr_flag = 'Y' AND
        hri_bpl_system.is_full_hr_installed = 'N')
    OR hri_bpl_system.is_full_hr_installed = 'Y')
  ORDER BY 1;

-- ----------------------------------------------------------------------------
-- Switches debugging messages on or off. Setting to on will
-- mean extra debugging information will be generated when the
-- process is run.
-- ----------------------------------------------------------------------------
PROCEDURE set_debugging(p_on IN BOOLEAN) IS

BEGIN

  g_debugging := p_on;

END set_debugging;

-- ----------------------------------------------------------------------------
-- Procedure msg logs a message
-- ----------------------------------------------------------------------------
PROCEDURE output(p_text IN VARCHAR2) IS

BEGIN

  hri_bpl_conc_log.output(p_text);

END output;

-- ----------------------------------------------------------------------------
-- Procedure dbg decides whether to log the passed in message
-- depending on whether debug mode is set.
-- ----------------------------------------------------------------------------
PROCEDURE dbg(p_text IN VARCHAR2) IS

BEGIN

  IF g_debugging THEN
    output(p_text);
  END IF;

END dbg;

-- ----------------------------------------------------------------------------
-- PROCEDURE trim_msg removes blank spaces and enter characters from the string
-- ----------------------------------------------------------------------------
FUNCTION trim_msg(p_text IN VARCHAR2)
      RETURN VARCHAR2 IS

  l_text VARCHAR2(20000);

BEGIN

  -- Remove blank spaces
  l_text := TRIM(both ' ' FROM p_text);

  -- Remove Enter characters
  l_text := TRIM(both fnd_global.local_chr(10) FROM l_text);

  RETURN l_text;

END trim_msg;

-- ----------------------------------------------------------------------------
-- Function GET_MESSAGE takes the message name and returns back the
-- message text
-- ----------------------------------------------------------------------------
FUNCTION get_message(p_message IN VARCHAR2)
      RETURN VARCHAR2 IS

BEGIN
  --
  fnd_message.set_name('HRI', p_message);
  IF is_token_exist(p_message,'PRODUCT_NAME')
  THEN
    fnd_message.set_token('PRODUCT_NAME'
                          ,get_product_name(g_object_name));
  END IF;

  RETURN trim_msg(fnd_message.get);
  --
END get_message;

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
FUNCTION is_token_exist(p_message    IN   VARCHAR2,
                        p_token_name IN   VARCHAR2)
      RETURN BOOLEAN IS
--
l_exists BOOLEAN := FALSE;
--
BEGIN
  --
  IF instr(fnd_message.get_string('HRI',p_message),p_token_name,1) > 0 THEN
    --
    l_exists := TRUE ;
    --
  END IF;
  --
  RETURN l_exists;
  --
END is_token_exist;

-------------------------------------------------------------------------------
-- Get the product name being called by the Concurrect program.
-------------------------------------------------------------------------------

FUNCTION get_product_name(p_object_name IN VARCHAR2)
      RETURN VARCHAR2 IS

  l_product_name varchar2(1000);

BEGIN
   dbg('Entering get_product_name');

    IF     ((g_prd_type_tab_v(p_object_name).dbi_ind = 1
       AND g_prd_type_tab_v(p_object_name).obiee_ind = 0
       AND g_prd_type_tab_v(p_object_name).all_ind = 0)
       OR ( p_object_name = 'HRI_IMPL_DBI')) THEN
      --
      l_product_name :=fnd_message.GET_STRING('HRI', 'HRI_407494_HRI_PRODUCT_NAME');
      --
    ELSIF  ((g_prd_type_tab_v(p_object_name).dbi_ind = 0
       AND g_prd_type_tab_v(p_object_name).obiee_ind = 1
       AND g_prd_type_tab_v(p_object_name).all_ind = 0)
       OR  (p_object_name = 'HRI_IMPL_OBIEE')) THEN
      --
        l_product_name :=fnd_message.GET_STRING('HRI', 'HRI_407493_OBIEE_PRODUCT_NAME');
      --
    ELSIF  g_prd_type_tab_v(p_object_name).all_ind = 1 then

      l_product_name :=fnd_message.GET_STRING('HRI', 'HRI_407493_OBIEE_PRODUCT_NAME')||' & '||
                             fnd_message.GET_STRING('HRI', 'HRI_407494_HRI_PRODUCT_NAME');
    ELSE
      l_product_name :=fnd_message.GET_STRING('HRI', 'HRI_407493_OBIEE_PRODUCT_NAME')||'/'||
                             fnd_message.GET_STRING('HRI', 'HRI_407494_HRI_PRODUCT_NAME');
    END IF;

   dbg('Exiting get_product_name');
   RETURN l_product_name;

END get_product_name;

-- ----------------------------------------------------------------------------
-- Function get_profile_message takes the message name and returns back the
-- message text for a profile
-- ----------------------------------------------------------------------------
FUNCTION get_profile_message(p_message           IN   VARCHAR2,
                             p_user_profile_name IN   VARCHAR2)
      RETURN VARCHAR2 IS

l_product_name VARCHAR2(1000);
BEGIN

  fnd_message.set_name('HRI', p_message);
  fnd_message.set_token('PROFILE_NAME',p_user_profile_name);

  IF is_token_exist(p_message,'PRODUCT_NAME') THEN
    l_product_name:= get_product_name(p_object_name => g_object_name);
    fnd_message.set_token('PRODUCT_NAME',l_product_name);
  END IF;

  RETURN trim_msg(fnd_message.get);

END get_profile_message;


-- ----------------------------------------------------------------------------
-- Function get_ff_message takes the message name and returns back the
-- message text for a fast formula
-- ----------------------------------------------------------------------------
FUNCTION get_ff_message(p_message IN VARCHAR2,
                        p_ff_name IN VARCHAR2)
      RETURN VARCHAR2 IS

BEGIN

  fnd_message.set_name('HRI', p_message);

  -- Set the Fast Formula name
  fnd_message.set_token('FF_NAME',p_ff_name);

  IF is_token_exist(p_message,'PRODUCT_NAME')
  THEN
    fnd_message.set_token('PRODUCT_NAME',get_product_name(p_object_name => g_object_name));
  END IF;


  RETURN trim_msg(fnd_message.get);

END get_ff_message;

-- ----------------------------------------------------------------------------
-- Function is_dbi_date_format_correct checks the string format of DBI Global
-- Start Date. If the format is correct, then the global variable for DBI
-- Global Start Date is set to the date given in the string otherwise it is
-- set to sysdate
-- ----------------------------------------------------------------------------
FUNCTION is_dbi_date_format_correct(p_date_value IN VARCHAR2)
      RETURN VARCHAR2 IS

BEGIN

  -- If the value is null return wrong format
  IF p_date_value IS NULL THEN
    RETURN 'N';
  END IF;

  -- Set the global start date
  g_global_start_date := TRUNC(TO_DATE(p_date_value,'MM/DD/YYYY'));

  RETURN 'Y';

EXCEPTION WHEN OTHERS THEN

  RETURN 'N';

END is_dbi_date_format_correct;

-- ----------------------------------------------------------------------------
-- FUNCTION get_user_profile_name is used to fetch the user profile name of a
-- profile.
-- ----------------------------------------------------------------------------
FUNCTION get_user_profile_name(p_profile_name IN VARCHAR2)
      RETURN VARCHAR2 IS

  -- Cursor to fetch the user name of the profile
  CURSOR c_user_profile_name IS
  SELECT user_profile_option_name
  FROM   fnd_profile_options_vl
  WHERE  profile_option_name = p_profile_name;

  l_user_profile_name   VARCHAR2(1000);

BEGIN

  OPEN  c_user_profile_name;
  FETCH c_user_profile_name INTO l_user_profile_name;
  CLOSE c_user_profile_name;

  RETURN l_user_profile_name;

END get_user_profile_name;

-- ----------------------------------------------------------------------------
-- Procedure check_profiles checks the values for the profiles defined in the
-- set up diagnostics table.
-- ----------------------------------------------------------------------------
PROCEDURE check_profile_option
       (p_profile_name       IN VARCHAR2,
        p_functional_area    IN VARCHAR2,
        p_user_profile_name  OUT NOCOPY VARCHAR2,
        p_profile_value      OUT NOCOPY VARCHAR2,
        p_impact             OUT NOCOPY BOOLEAN,
        p_impact_msg         OUT NOCOPY VARCHAR2,
        p_doc_links_url      OUT NOCOPY VARCHAR2) IS

  l_value_code    VARCHAR2(240);
  l_dynamic_sql   VARCHAR2(32000);

BEGIN
  g_functional_area:= p_functional_area;
  -- Loop through all the profiles in the set up table
  FOR l_profile IN c_objects(p_profile_name, 'PROFILE', p_functional_area) LOOP

    -- Get the user name of the profile
    p_user_profile_name := get_user_profile_name(l_profile.object_name);
    g_object_name := l_profile.object_name ;

    -- Get the profile option value
    l_value_code := fnd_profile.value(l_profile.object_name);

    -- If the profile value is the exception value stored in the set up table,
    -- store the impact message for this
    IF (l_value_code = l_profile.exception_value) THEN

      -- Set impact flag
      p_impact := TRUE;

      -- Store the specific impact message
      p_impact_msg := get_profile_message
                       (p_message => l_profile.impact_msg_name,
                        p_user_profile_name => p_user_profile_name);

      -- Add the URL if provided
      IF (l_profile.add_info_url IS NOT NULL) THEN
        p_doc_links_url := l_profile.add_info_url;
      END IF;

    -- Store the null impact message if
    --   The value for the profile is not set
    --   It is the DBI Global Start Date profile and
    --   the profile value is in an incorrect format
    ELSIF (l_value_code IS NULL OR
           (l_profile.object_name = 'BIS_GLOBAL_START_DATE' AND
            is_dbi_date_format_correct(l_value_code) = 'N')) THEN

      -- Set impact flag
      p_impact := TRUE;

      -- Store the specific impact message
      p_impact_msg := get_profile_message
                       (p_message => l_profile.null_impact_msg_name,
                        p_user_profile_name => p_user_profile_name);

      -- Add the URL if provided
      IF (l_profile.add_info_url IS NOT NULL) THEN
        p_doc_links_url := l_profile.add_info_url;
      END IF;

    END IF;

    -- If the dynamic SQL is available for finding the profile value then use it else
    -- use the existing profile value
    l_dynamic_sql := hri_bpl_data_setup_dgnstc.get_dynamic_sql
                      (p_dyn_sql_type => l_profile.dynamic_sql_type,
                       p_dyn_sql      => l_profile.dynamic_sql);

    -- Run the SQL if given
    IF l_dynamic_sql IS NOT NULL AND l_value_code IS NOT NULL THEN
      EXECUTE IMMEDIATE l_dynamic_sql INTO p_profile_value USING l_value_code;
    ELSE
      p_profile_value := l_value_code;
    END IF;

  END LOOP;

EXCEPTION WHEN OTHERS THEN

  output('Exception Raised in check_profiles');
  RAISE;

END check_profile_option;

-- ----------------------------------------------------------------------------
-- Procedure check_fast_formula checks the status of all the fast formulas
-- in the set up diagnostics table.
-- ----------------------------------------------------------------------------
PROCEDURE check_fast_formula
       (p_ff_name          IN VARCHAR2,
        p_functional_area  IN VARCHAR2,
        p_type             IN VARCHAR2,
        p_formula_tab      OUT NOCOPY fast_formula_tab_type,
        p_impact_msg_tab   OUT NOCOPY impact_msg_tab_type) IS

  l_formula_tab          fast_formula_tab_type;
  l_impact_msg_tab       impact_msg_tab_type;
  l_status               VARCHAR2(240);
  l_bg_index             PLS_INTEGER;
  l_bg_name              VARCHAR2(100);
  l_bg_id                NUMBER;
  l_bg_without_ff        BOOLEAN;
  l_ff_name   VARCHAR2(100);
  l_dynamic_sql   VARCHAR2(32000);

  -- Reference type cursor is used when the Dynamic SQL fetches more than one records
  TYPE ref_cursor_type   IS REF CURSOR;
  c_user_defn_records    ref_cursor_type;

  -- Cursor to check the existence of the seeded fast formulas as on sysdate
  CURSOR c_seeded_ff_nm(p_obj_nm VARCHAR2) IS
    SELECT 'FFP'||formula_id||'_'||TO_CHAR(effective_start_date,'DDMMYYYY') ff_name
    FROM   ff_formulas_f ff
    WHERE  ff.formula_name = p_obj_nm
    AND    ff.business_group_id IS NULL
    AND    trunc(SYSDATE) BETWEEN ff.effective_start_date AND ff.effective_end_date
    ORDER BY ff_name;

  -- Cursor to find the status of the fast formula
  CURSOR c_status(p_ff_nm VARCHAR2) IS
    SELECT CASE WHEN COUNT(DISTINCT status)=1 THEN
             'Valid'
           ELSE
             'Invalid'
           END status
    FROM user_objects
    WHERE object_name = p_ff_nm
    AND   object_type IN ('PACKAGE','PACKAGE BODY');

BEGIN

  dbg('Checking ff');

  -- Initialize variables
  l_bg_index     := 0;

  -- Only process one type - SEEDED or USER
  IF (p_type = 'SEEDED') THEN

    -- Loop through the seeded fast formulas in the diagnostics table
    FOR l_ff IN c_objects(p_ff_name,'SEEDED_FAST_FORMULA',p_functional_area) LOOP
      g_object_name := l_ff.object_name ;

      -- Find the current existing formulas
      FOR l_seeded_ff_nm IN c_seeded_ff_nm(l_ff.object_name) LOOP

        -- Increment the counter
        l_bg_index := l_bg_index + 1;

        -- Check the status of each formula
        OPEN  c_status(l_seeded_ff_nm.ff_name);
        FETCH c_status INTO l_status;
        CLOSE c_status;

        -- Check if the fast formula is compiled
        IF l_status = 'Invalid' THEN

          -- Fetch the exception status message
          l_formula_tab(l_bg_index).status :=
                    get_message(l_ff.exception_status_msg_cd);

          -- Fetch the impact message
          l_formula_tab(l_bg_index).impact_msg :=
                    get_ff_message('HRI_407170_FF_UCMP_IMPCT',l_ff.object_name);
        ELSE

          -- Store the valid status message
          l_formula_tab(l_bg_index).status :=
                    get_message(l_ff.valid_status_msg_cd);
        END IF;

      END LOOP;

    END LOOP;

  -- USER formula
  ELSE

    -- Loop through the user defined fast formulas in the diagnostics table
    FOR l_ff IN c_objects(p_ff_name,'USER_DEFN_FAST_FORMULA',p_functional_area) LOOP
      g_object_name := l_ff.object_name ;

      -- Fetch the information for all business groups for this formula
      l_dynamic_sql := hri_bpl_data_setup_dgnstc.get_dynamic_sql
                        (p_dyn_sql_type => l_ff.dynamic_sql_type,
                         p_dyn_sql      => l_ff.dynamic_sql);

      -- Execute dynamic sql
      OPEN  c_user_defn_records
      FOR   l_dynamic_sql
      USING l_ff.object_name;

      -- Loop through all the business groups
      LOOP

      -- Fetch a record
      FETCH c_user_defn_records
      INTO  l_bg_name, l_bg_id, l_ff_name;

      -- Exit when no further records found
      EXIT WHEN (c_user_defn_records%NOTFOUND OR
                 c_user_defn_records%NOTFOUND IS NULL);

      -- Increment the business group count
      l_bg_index := l_bg_index + 1;

      -- Add record for the business group
      l_formula_tab(l_bg_index).business_group_name := l_bg_name;

      -- If the formula is not defined for the business group
      IF l_ff_name = 'FFP_' THEN

        l_formula_tab(l_bg_index).status :=
                 get_message(l_ff.null_impact_msg_name);
        l_bg_without_ff := true;

      -- Formula is defined for the business group
      ELSE

        -- Fetch the status of the user defined fast formula
        OPEN  c_status(l_ff_name);
        FETCH c_status INTO l_status;
        CLOSE c_status;

        -- Check if the fast formula is compiled
        IF l_status = 'Invalid' THEN

          -- This fast formula has an invalid status
          l_formula_tab(l_bg_index).status :=
                      get_message(l_ff.exception_status_msg_cd);

          l_formula_tab(l_bg_index).impact_msg :=
                      get_ff_message('HRI_407170_FF_UCMP_IMPCT',
                                     l_ff.object_name);

        ELSIF l_status = 'Valid' THEN

          -- This fast formula has an invalid status
          l_formula_tab(l_bg_index).status :=
                      get_message(l_ff.valid_status_msg_cd);

          -- If the formula is not defined in Setup Business Group and should be
          -- record this information
          IF (l_bg_id <> 0 AND
              (l_ff.object_name = 'HR_MOVE_TYPE' OR
               l_ff.object_name = 'NORMALIZE_REVIEW_RATING' OR
               l_ff.object_name = 'CATEGORIZE_PERSON_TYPE')) THEN

            -- This bit needs "genericising"
            IF (l_ff.object_name = 'HR_MOVE_TYPE') THEN

              l_impact_msg_tab('HRI_407168_USR_LVRSN_IMPCT').impact_msg :=
                      get_message('HRI_407168_USR_LVRSN_IMPCT');

            ELSIF (l_ff.object_name = 'NORMALIZE_REVIEW_RATING') THEN

              l_impact_msg_tab('HRI_407267_REVRTG_WRNGBG_IMPCT').impact_msg :=
                      get_message('HRI_407267_REVRTG_WRNGBG_IMPCT');

            ELSIF (l_ff.object_name = 'CATEGORIZE_PERSON_TYPE') THEN

              l_impact_msg_tab('HRI_407284_CTRPRN_WRNGBG_IMPCT').impact_msg :=
                      get_message('HRI_407284_CTRPRN_WRNGBG_IMPCT');
            END IF;

          END IF;

        END IF; -- Compile Status

      END IF; -- Formula exists for BG

      END LOOP; -- BG Loop

      -- If a business group is found without a formula then
      IF l_bg_without_ff THEN

        -- Store impact message
        l_impact_msg_tab('HRI_407269_APPRTG_UNDEF_IMPCT').impact_msg :=
                         get_message('HRI_407269_APPRTG_UNDEF_IMPCT');

      -- If the number of BG are 0 then store a message
      ELSIF (l_bg_index = 0 AND
             l_ff.object_name <> 'NORMALIZE_APPRAISAL_RATING' AND
             l_ff.impact_msg_name IS NOT NULL) THEN

        l_impact_msg_tab(l_ff.impact_msg_name).impact_msg :=
                get_message(l_ff.impact_msg_name);
        l_impact_msg_tab(l_ff.impact_msg_name).doc_links_url :=
                l_ff.add_info_url;

      END IF;

    END LOOP;

  END IF;

  -- Assign tables to output
  p_formula_tab    := l_formula_tab;
  p_impact_msg_tab := l_impact_msg_tab;

EXCEPTION WHEN OTHERS THEN

  output('Exception Raised in check_fast_formula');
  RAISE;

END check_fast_formula;

-- ----------------------------------------------------------------------------
-- PROCEDURE check_triggers checks whether the triggers are generated and
-- enabled
-- ----------------------------------------------------------------------------
PROCEDURE check_triggers(p_trigger_name      IN VARCHAR2,
                         p_functional_area   IN VARCHAR2,
                         p_generated         OUT NOCOPY VARCHAR2,
                         p_enabled           OUT NOCOPY VARCHAR2,
                         p_status            OUT NOCOPY VARCHAR2,
                         p_impact            OUT NOCOPY BOOLEAN,
                         p_impact_msg        OUT NOCOPY VARCHAR2,
                         p_doc_links_url     OUT NOCOPY VARCHAR2) IS

  -- Cursor to check if the trigger is enabled and generated
  CURSOR c_check_trigger(p_trigger_nm VARCHAR2) IS
    SELECT generated_flag generated,
           enabled_flag   enabled
    FROM   pay_trigger_events
    WHERE  short_name = p_trigger_nm;

  l_generated     VARCHAR2(5);
  l_enabled       VARCHAR2(5);

BEGIN

  dbg('Checking trigger');

  -- Loop through all the triggers in the set up table
  FOR l_trigger IN c_objects(p_trigger_name,'TRIGGER',p_functional_area) LOOP
    g_object_name := l_trigger.object_name;

    -- Fetch the values for the generated and enabled flag
    OPEN c_check_trigger(l_trigger.object_name);
    FETCH c_check_trigger INTO l_generated, l_enabled;
    CLOSE c_check_trigger;

    -- Set the messages
    IF (l_generated = 'Y' AND l_enabled = 'Y') THEN

      -- If the trigger is generated and enabled then there is no problem
      p_status := get_message(l_trigger.valid_status_msg_cd);
      p_impact := FALSE;

    ELSE

      -- Otherwise exception message has to be shown
      p_status := get_message(l_trigger.exception_status_msg_cd);
      p_impact := TRUE;

      -- To show impact message since a trigger is not enabled or not generated.
      p_impact_msg := get_message('HRI_407171_TRGGR_IMPCT');
      p_doc_links_url := get_message('HRI_407182_TRGGR_LINK');

    END IF;

    -- Find the lookup value for generated and enabled
    p_generated := hr_bis.bis_decode_lookup('YES_NO',l_generated);
    p_enabled   := hr_bis.bis_decode_lookup('YES_NO',l_enabled);

  END LOOP;

EXCEPTION WHEN OTHERS THEN

  output('Exception Raised in check_triggers');
  RAISE;

END check_triggers;

-- ----------------------------------------------------------------------------
-- PROCEDURE check_dbi_tables to check if the key DBI tables are populated
-- ----------------------------------------------------------------------------
PROCEDURE check_dbi_tables(p_table_name       IN VARCHAR2,
                           p_functional_area  IN VARCHAR2,
                           p_status           OUT NOCOPY VARCHAR2,
                           p_impact           OUT NOCOPY BOOLEAN,
                           p_impact_msg       OUT NOCOPY VARCHAR2,
                           p_doc_links_url    OUT NOCOPY VARCHAR2) IS

  l_records            NUMBER;
  l_stmt               VARCHAR2(100);

BEGIN

  dbg('Checking tables');

  -- Get the table information
  FOR l_tables IN c_objects(p_table_name,'TABLE',p_functional_area) LOOP
    g_object_name := l_tables.object_name;

    -- Check whether data is present in the table
    l_stmt := 'SELECT COUNT(*) FROM ' || UPPER(l_tables.object_name) ||
              ' WHERE ROWNUM = 1';
    EXECUTE IMMEDIATE l_stmt INTO l_records;

    -- If there is no data in the table
    IF (l_records = 0) THEN

      -- Store the exception staus since the table is empty
      p_impact := TRUE;
      p_status := get_message(l_tables.exception_status_msg_cd);
      p_impact_msg := get_message('HRI_407184_TABLE_IMPCT');
      p_doc_links_url := get_message('HRI_407182_TRGGR_LINK');

    -- Table is populated
    ELSE

      -- No impact
      p_impact := FALSE;
      p_status := get_message(l_tables.valid_status_msg_cd);

    END IF;

  END LOOP;

EXCEPTION WHEN OTHERS THEN

  output('Exception Raised in check_dbi_tables');
  RAISE;

END check_dbi_tables;

-- ------------------------------------
-- Checks details for a given job group
-- ------------------------------------
PROCEDURE check_job_group
  (p_value_set_id       IN NUMBER,
   p_job_type           IN VARCHAR2,
   p_flex_structure_tab IN OUT NOCOPY job_flex_tab_type,
   p_flex_type          OUT NOCOPY VARCHAR2) IS

  -- Cursor to find all the job keyflex structure codes that are
  -- linked to a business group but do not have a segment linked
  -- with the given value set
  CURSOR check_keyflex_csr(v_valueset_id  NUMBER) IS
  SELECT DISTINCT
   flx.id_flex_num
  ,flx.id_flex_structure_code
  ,flx.id_flex_structure_name
  FROM
   hr_organization_information  hoi
  ,fnd_id_flex_structures_vl    flx
  WHERE hoi.org_information_context = 'Business Group Information'
  AND flx.id_flex_num = hoi.org_information6
  AND flx.id_flex_code= 'JOB'
  AND flx.application_id = 800
  AND NOT EXISTS
    (SELECT /*+ NO_UNNEST */ null
     FROM fnd_id_flex_segments_vl seg
     WHERE seg.id_flex_code = 'JOB'
     AND seg.application_id = 800
     AND seg.id_flex_num = hoi.org_information6
     AND seg.flex_value_set_id = v_valueset_id)
  AND EXISTS
    (SELECT /*+ NO_UNNEST */ null
     FROM per_periods_of_service pps
     WHERE pps.business_group_id = hoi.organization_id
     AND NVL(pps.actual_termination_date, g_global_start_date) >= g_global_start_date);

  -- Cursor to find all non global job descriptive flexfield contexts that
  -- do not have a segment linked with the given value set and do not have
  -- a global segment available
  CURSOR check_dscflex_csr(v_valueset_id  NUMBER) IS
  SELECT
   ctxt.descriptive_flex_context_code
  ,ctxt.descriptive_flex_context_name
  FROM
   fnd_descr_flex_contexts_vl  ctxt
  WHERE ctxt.descriptive_flexfield_name = 'PER_JOBS'
  AND ctxt.application_id = 800
  AND ctxt.enabled_flag = 'Y'
  AND ctxt.global_flag = 'N'
  AND NOT EXISTS
   (SELECT NULL
    FROM
     fnd_descr_flex_col_usage_vl  col
    WHERE ctxt.application_id = col.application_id
    AND ctxt.descriptive_flexfield_name = col.descriptive_flexfield_name
    AND ctxt.descriptive_flex_context_code = col.descriptive_flex_context_code
    AND col.flex_value_set_id = v_valueset_id)
  AND NOT EXISTS
   (SELECT NULL
    FROM
     fnd_descr_flex_contexts_vl   ctxt2
    ,fnd_descr_flex_col_usage_vl  col2
    WHERE ctxt2.application_id = ctxt.application_id
    AND ctxt2.descriptive_flexfield_name = ctxt.descriptive_flexfield_name
    AND ctxt2.application_id = col2.application_id
    AND ctxt2.descriptive_flexfield_name = col2.descriptive_flexfield_name
    AND ctxt2.descriptive_flex_context_code = col2.descriptive_flex_context_code
    AND ctxt2.global_flag = 'Y'
    AND col2.flex_value_set_id = v_valueset_id);

  l_index     VARCHAR2(240);

BEGIN

  -- Get the flexfield type
  p_flex_type := hri_opl_jobh.get_flexfield_type
                  (p_job_type     => p_job_type,
                   p_value_set_id => p_value_set_id);

  -- Load structure table with the undefined structures from the relevant cursor
  IF (p_flex_type = 'KEY') THEN

    FOR keyflex_rec IN check_keyflex_csr(p_value_set_id) LOOP
 --     g_object_name := l_tables.object_name;

      l_index := p_flex_type || '|' || keyflex_rec.id_flex_structure_code;

      p_flex_structure_tab(l_index).structure_name :=
              keyflex_rec.id_flex_structure_name;

      IF (p_job_type = 'JOB_FAMILY') THEN
        p_flex_structure_tab(l_index).job_family_defined_msg :=
                       get_message('HRI_407177_JOB_UNDEF_STTS');
      ELSIF (p_job_type = 'JOB_FUNCTION') THEN
        p_flex_structure_tab(l_index).job_function_defined_msg :=
                       get_message('HRI_407177_JOB_UNDEF_STTS');
      END IF;

    END LOOP;

  ELSIF (p_flex_type = 'DESCRIPTIVE') THEN

    FOR dscflex_rec IN check_dscflex_csr(p_value_set_id) LOOP

      l_index := p_flex_type || '|' || dscflex_rec.descriptive_flex_context_code;

      p_flex_structure_tab(l_index).structure_name :=
              dscflex_rec.descriptive_flex_context_name;

      IF (p_job_type = 'JOB_FAMILY') THEN
        p_flex_structure_tab(l_index).job_family_defined_msg :=
                       get_message('HRI_407177_JOB_UNDEF_STTS');
      ELSIF (p_job_type = 'JOB_FUNCTION') THEN
        p_flex_structure_tab(l_index).job_function_defined_msg :=
                       get_message('HRI_407177_JOB_UNDEF_STTS');
      END IF;

    END LOOP;

  END IF;

END check_job_group;

-- ----------------------------------------------------------------------------
-- PROCEDURE check_job checks the set up for Job Family and Job Function.
-- ----------------------------------------------------------------------------
PROCEDURE check_job(p_job_family_mode        OUT NOCOPY VARCHAR2,
                    p_job_function_mode      OUT NOCOPY VARCHAR2,
                    p_flex_structure_tab     OUT NOCOPY job_flex_tab_type,
                    p_impact                 OUT NOCOPY BOOLEAN,
                    p_impact_msg             OUT NOCOPY VARCHAR2,
                    p_doc_links_url          OUT NOCOPY VARCHAR2) IS

  l_family_vl            VARCHAR2(100);
  l_function_vl          VARCHAR2(100);
  l_job_family_impact    BOOLEAN;
  l_job_function_impact  BOOLEAN;

BEGIN

  -- Do not check job set up for foundation HR
  IF hri_bpl_system.is_full_hr_installed = 'Y' THEN

    -- If the global start date, job family or job function profile is not set correctly
    -- then store an impact message and return
    IF (fnd_profile.value('HR_BIS_JOB_FAMILY')   IS NULL AND
        fnd_profile.value('HR_BIS_JOB_FUNCTION') IS NULL) THEN

      -- Set the message up
      fnd_message.set_name
       ('HRI','HRI_407183_UNSET_JOB_PRF_IMPCT');

      -- Set the Profile names
      fnd_message.set_token
       ('PROFILE_NAME1',get_user_profile_name('BIS_GLOBAL_START_DATE'));
      fnd_message.set_token
       ('PROFILE_NAME2',get_user_profile_name('HR_BIS_JOB_FAMILY'));
      fnd_message.set_token
       ('PROFILE_NAME3',get_user_profile_name('HR_BIS_JOB_FUNCTION'));

      -- Store the general impact message
      p_impact     := TRUE;
      p_impact_msg := trim_msg(fnd_message.get);

    ELSE

      -- Find the profile value for Job Family and Job Function
      l_family_vl   := fnd_profile.value('HR_BIS_JOB_FAMILY');
      l_function_vl := fnd_profile.value('HR_BIS_JOB_FUNCTION');

      -- Get the setup information for job family
      check_job_group(p_value_set_id       => l_family_vl,
                      p_job_type           => 'JOB_FAMILY',
                      p_flex_structure_tab => p_flex_structure_tab,
                      p_flex_type          => p_job_family_mode);

      -- Get the setup information for job function
      check_job_group(p_value_set_id       => l_function_vl,
                      p_job_type           => 'JOB_FUNCTION',
                      p_flex_structure_tab => p_flex_structure_tab,
                      p_flex_type          => p_job_function_mode);

      -- If any structures are returned in the table then there may be impact
      BEGIN
        IF (p_flex_structure_tab.FIRST IS NOT NULL) THEN

          -- Store the general impact message
          p_impact        := TRUE;
          p_impact_msg    := get_message('HRI_407172_JOB_IMPCT');
          p_doc_links_url := get_message('HRI_407181_JOB_LINK');

        ELSE

          -- No impact
          p_impact := FALSE;

        END IF;

      -- Trap exceptions if the structure table is empty
      EXCEPTION WHEN OTHERS THEN
        null;
      END;

    END IF; -- Profile setup correct

  END IF; -- Shared HR

EXCEPTION WHEN OTHERS THEN

  output('Exception Raised in check_job');
  RAISE;

END check_job;

-- ----------------------------------------------------------------------------
-- PROCEDURE check_geography checks if the set up for Region. It
-- checks all the structures in Additional Location Details for the Region
-- segment.
-- ----------------------------------------------------------------------------
PROCEDURE check_geography(p_context_name     OUT NOCOPY VARCHAR2,
                          p_flex_column      OUT NOCOPY VARCHAR2,
                          p_status           OUT NOCOPY VARCHAR2,
                          p_impact           OUT NOCOPY BOOLEAN,
                          p_impact_msg       OUT NOCOPY VARCHAR2) IS

  -- Cursor to find the attribute for Region
  CURSOR c_reg_attr IS
  SELECT bfm.application_column_name
  FROM
   bis_flex_mappings_v   bfm
  ,bis_dimensions        bd
  WHERE bfm.dimension_id = bd.dimension_id
  AND bd.short_name = 'GEOGRAPHY'
  AND bfm.level_short_name = 'REGION'
  AND bfm.application_id = 800;

  -- Cursor which finds the structures in the descriptive flexfield
  -- 'Additional Location Details' that have a segment that uses
  -- an attribute defined for Region
  CURSOR c_reg_structures(p_attribute VARCHAR2) IS
  SELECT
   cntxt.descriptive_flex_context_name
  FROM
   fnd_descr_flex_col_usage_vl  col
  ,fnd_descr_flex_contexts_vl   cntxt
  WHERE col.application_id = 800
  AND col.descriptive_flexfield_name = 'HR_LOCATIONS'
  AND application_column_name = p_attribute
  AND cntxt.descriptive_flexfield_name = col.descriptive_flexfield_name
  AND cntxt.descriptive_flex_context_code = col.descriptive_flex_context_code
  AND col.application_id = cntxt.application_id;

BEGIN

  -- Do not check geography set up for foundation HR
  IF hri_bpl_system.is_full_hr_installed = 'Y' THEN

    -- Get the column the region flex field segment is mapped to
    OPEN  c_reg_attr;
    FETCH c_reg_attr INTO p_flex_column;
    CLOSE c_reg_attr;

    -- If the region segment attribute is not null then find the
    -- flexfield structures using the region atribute
    IF p_flex_column IS NOT NULL THEN

      -- Find whether the location flexfield has the region column
      OPEN c_reg_structures(p_flex_column);
      FETCH c_reg_structures INTO p_context_name;
      CLOSE c_reg_structures;

    END IF;

    -- If the location structure has no region attribute then set status
    -- to undefined
    IF (p_context_name IS NULL) THEN

      p_impact := TRUE;
      p_status := get_message('HRI_407179_GEO_UNDEF_STTS');
      p_impact_msg := get_message('HRI_407173_GEO_IMPCT');

     -- Otherwise the geography setup is fine
    ELSE

      p_impact := FALSE;
      p_status := get_message('HRI_407178_GEO_DEF_STTS');

    END IF;

  END IF;

EXCEPTION WHEN OTHERS THEN

  output('Exception Raised in check_geography');
  RAISE;

END check_geography;

-- ----------------------------------------------------------------------------
-- PROCEDURE check_buckets to check if the number of ranges in the HRI buckets
-- are correct.
-- ----------------------------------------------------------------------------
PROCEDURE check_buckets(p_bucket_name       IN VARCHAR2,
                        p_functional_area   IN VARCHAR2,
                        p_user_bucket_name  OUT NOCOPY VARCHAR2,
                        p_status            OUT NOCOPY VARCHAR2,
                        p_impact            OUT NOCOPY BOOLEAN,
                        p_impact_msg        OUT NOCOPY VARCHAR2,
                        p_doc_links_url     OUT NOCOPY VARCHAR2) IS

  l_range              VARCHAR2(1);
  l_bucket_name        VARCHAR2(240);
  l_dynamic_sql        VARCHAR2(32000);

  CURSOR bucket_name_csr(v_bucket_name VARCHAR2) IS
  SELECT name
  FROM bis_bucket_vl
  WHERE short_name = v_bucket_name;

BEGIN

  dbg('Checking buckets');

  -- Get the bucket metadata
  FOR l_buckets IN c_objects(p_bucket_name, 'BUCKET', p_functional_area) LOOP

    -- Execute the dynamic sql to get the ranges defined for the bucket
    l_dynamic_sql := hri_bpl_data_setup_dgnstc.get_dynamic_sql
                      (p_dyn_sql_type => l_buckets.dynamic_sql_type,
                       p_dyn_sql      => l_buckets.dynamic_sql);
    EXECUTE IMMEDIATE l_dynamic_sql
    INTO  l_range;

    -- If the bucket is invalid
    IF l_range = 'N' THEN

      -- Store the impact message that is to be displayed since the bucket
      -- does not have correct number of ranges
      p_impact := TRUE;
      p_impact_msg := get_message(l_buckets.impact_msg_name);
      p_doc_links_url := l_buckets.add_info_url;
      p_status := get_message(l_buckets.exception_status_msg_cd);

    ELSE

      -- No impact
      p_impact := FALSE;
      p_status := get_message(l_buckets.valid_status_msg_cd);

    END IF;

    -- Get the bucket name
    OPEN bucket_name_csr(l_buckets.object_name);
    FETCH bucket_name_csr INTO p_user_bucket_name;
    CLOSE bucket_name_csr;

    -- Use bucket code if the name is not found
    IF (p_user_bucket_name IS NULL) THEN
      p_user_bucket_name := p_bucket_name;
    END IF;

  END LOOP;

EXCEPTION WHEN OTHERS THEN

  output('Exception Raised in check_buckets');
  RAISE;

END check_buckets;

-- ----------------------------------------------------------------------------
-- PROCEDURE pplt_obj_farea_tab is populate PRODUCT NAME(DBI/OBIEE/ALL)
-- flags for all the objects based on functional area.
-- ----------------------------------------------------------------------------
PROCEDURE pplt_obj_farea_tab IS

  l_obiee_flag VARCHAR2(10) := 'N';
  l_dbi_flag   VARCHAR2(10) := 'N';
  l_all_flag   VARCHAR2(10) := 'N';

  -- Cursor to load product name table
  CURSOR prd_name_csr IS
     SELECT sub.object_name, sub.functional_area_cd
     FROM hri_adm_dgnstc_sbscrb sub
     ORDER BY sub.object_name;

  l_object_name         VARCHAR2(100);
  l_functional_area_cd  VARCHAR2(100);
  l_object_name_prv     VARCHAR2(100);

BEGIN

  OPEN prd_name_csr;
  LOOP

    FETCH prd_name_csr
    INTO l_object_name,l_functional_area_cd;

    EXIT WHEN prd_name_csr % NOTFOUND;

    IF NOT(g_prd_type_tab_v.EXISTS(l_object_name)) THEN
      --
      g_prd_type_tab_v(l_object_name).obiee_ind := 0;
      g_prd_type_tab_v(l_object_name).dbi_ind := 0;
      g_prd_type_tab_v(l_object_name).all_ind := 0;
      --
    END IF;

    IF(l_functional_area_cd LIKE 'OBIEE%') THEN
      --
      g_prd_type_tab_v(l_object_name).obiee_ind := 1;
      --
    END IF;

    IF(l_functional_area_cd IN('BENEFITS',  'WRKFC_BDGT_MNGMNT') OR(l_functional_area_cd LIKE 'PPL%')) THEN
       --
       g_prd_type_tab_v(l_object_name).dbi_ind := 1;
       --
    END IF;

    IF(g_prd_type_tab_v(l_object_name).obiee_ind = 1)
     AND(g_prd_type_tab_v(l_object_name).dbi_ind = 1) THEN
      --
      g_prd_type_tab_v(l_object_name).all_ind := 1;
      --
    END IF;
    --
  END LOOP;
  CLOSE prd_name_csr;
END  pplt_obj_farea_tab;
--
--

END hri_bpl_setup_diagnostic;

/
