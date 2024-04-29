--------------------------------------------------------
--  DDL for Package Body HRI_BPL_REC_PIPLN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_REC_PIPLN" AS
/* $Header: hribrec.pkb 120.1.12000000.2 2007/04/12 12:07:17 smohapat noship $ */

  TYPE g_status_rec_type IS RECORD
   (stage_code   VARCHAR2(30),
    event_code   VARCHAR2(30),
    event_seq    NUMBER);

  TYPE g_event_rec_type IS RECORD
   (stage_code   VARCHAR2(30),
    event_seq    PLS_INTEGER);

  TYPE g_status_tab_type IS TABLE OF g_status_rec_type
                           INDEX BY BINARY_INTEGER;

  TYPE g_event_tab_type IS TABLE OF g_event_rec_type
                               INDEX BY VARCHAR2(30);

  TYPE g_term_cache_tab_type IS TABLE OF varchar2(30) INDEX BY VARCHAR2(30);


  g_status_formula_id  NUMBER;
  g_term_formula_id    NUMBER;
  g_status_cache       g_status_tab_type;
  g_term_cache_tab     g_term_cache_tab_type;
  g_event_cache        g_event_tab_type;
  g_cache_loaded       BOOLEAN;


-- -----------------------------------------------------------------------------
-- Calculates event details for status type and caches them
-- -----------------------------------------------------------------------------
PROCEDURE cache_event_info
      (p_system_status   IN VARCHAR2,
       p_user_status     IN VARCHAR2,
       p_status_id       IN NUMBER,
       p_stage_code      OUT NOCOPY VARCHAR2,
       p_event_code      OUT NOCOPY VARCHAR2,
       p_event_seq       OUT NOCOPY NUMBER) IS

  l_formula_input_tab   hri_bpl_fast_formula_util.formula_param_type;
  l_formula_output_tab  hri_bpl_fast_formula_util.formula_param_type;
  l_skip_event          VARCHAR2(30);

BEGIN

  -- Initialize formula input parameters
  l_formula_input_tab('SYSTEM_ASG_STATUS') := p_system_status;
  l_formula_input_tab('USER_ASG_STATUS')   := p_user_status;

  -- Extract outputs
  BEGIN

    -- Run formula
    hri_bpl_fast_formula_util.run_formula
     (p_formula_id => g_status_formula_id,
      p_input_tab  => l_formula_input_tab,
      p_output_tab => l_formula_output_tab);

    -- Set output values
    p_stage_code := l_formula_output_tab('STAGE_CODE');
    p_event_code := l_formula_output_tab('EVENT_CODE');
    p_event_seq  := l_formula_output_tab('EVENT_SEQ');
    l_skip_event := l_formula_output_tab('SKIP_EVENT');

  -- Trap exception if formula does not exists, or errors
  EXCEPTION WHEN OTHERS THEN
    null;
  END;

  -- If event is NULL (formula has not executed successfully), or
  -- Event is unassigned but user has not chosen to skip it
  -- then apply default classification
  IF (p_event_code IS NULL OR
      (p_event_code = 'NA_EDW' AND
       l_skip_event = 'N')) THEN

    IF p_system_status = 'ACTIVE_APL' THEN
      p_event_code := 'APPL_STRT';
    ELSIF p_system_status = 'INTERVIEW1' THEN
      p_event_code := 'ASMT_INT1';
    ELSIF p_system_status = 'INTERVIEW2' THEN
      p_event_code := 'ASMT_INT2';
    ELSIF p_system_status = 'OFFER' THEN
      p_event_code := 'OFFR_EXTD';
    ELSIF p_system_status = 'ACCEPTED' THEN
      p_event_code := 'OFFR_ACPT';
    ELSIF p_system_status = 'TERM_APL' THEN
      p_event_code := 'APPL_TERM_INIT';
    ELSE
      p_event_code := 'NA_EDW';
    END IF;

    p_stage_code := g_event_cache(p_event_code).stage_code;
    p_event_seq  := g_event_cache(p_event_code).event_seq;

  END IF;

  -- Update Caches
  g_status_cache(p_status_id).stage_code := p_stage_code;
  g_status_cache(p_status_id).event_code := p_event_code;
  g_status_cache(p_status_id).event_seq  := p_event_seq;

  -- Do not override seeded information
  IF NOT g_event_cache.EXISTS(p_event_code) THEN
    g_event_cache(p_event_code).stage_code := p_stage_code;
    g_event_cache(p_event_code).event_seq  := p_event_seq;
  END IF;

END cache_event_info;


-- -----------------------------------------------------------------------------
-- Returns stage code
-- -----------------------------------------------------------------------------
FUNCTION get_stage_code
      (p_system_status   IN VARCHAR2,
       p_user_status     IN VARCHAR2,
       p_status_id       IN NUMBER)
     RETURN VARCHAR2 IS

  l_stage_code      VARCHAR2(30);
  l_event_code      VARCHAR2(30);
  l_event_seq       NUMBER;

BEGIN

  IF NOT g_status_cache.EXISTS(p_status_id) THEN

    cache_event_info
     (p_system_status => p_system_status,
      p_user_status   => p_user_status,
      p_status_id     => p_status_id,
      p_stage_code    => l_stage_code,
      p_event_code    => l_event_code,
      p_event_seq     => l_event_seq);

  END IF;

  RETURN g_status_cache(p_status_id).stage_code;

EXCEPTION WHEN OTHERS THEN

  RETURN 'NON_PIPLN_STG';

END get_stage_code;


-- -----------------------------------------------------------------------------
-- Returns event code
-- -----------------------------------------------------------------------------
FUNCTION get_event_code
      (p_system_status   IN VARCHAR2,
       p_user_status     IN VARCHAR2,
       p_status_id       IN NUMBER)
     RETURN VARCHAR2 IS

  l_stage_code      VARCHAR2(30);
  l_event_code      VARCHAR2(30);
  l_event_seq       NUMBER;

BEGIN

  IF NOT g_status_cache.EXISTS(p_status_id) THEN

    cache_event_info
     (p_system_status => p_system_status,
      p_user_status   => p_user_status,
      p_status_id     => p_status_id,
      p_stage_code    => l_stage_code,
      p_event_code    => l_event_code,
      p_event_seq     => l_event_seq);

  END IF;

  RETURN g_status_cache(p_status_id).event_code;

EXCEPTION WHEN OTHERS THEN

  RETURN 'NA_EDW';

END get_event_code;


-- -----------------------------------------------------------------------------
-- Loads event information cache
-- -----------------------------------------------------------------------------
PROCEDURE load_event_cache IS

  CURSOR status_csr IS
  SELECT
   per_system_status            system_status
  ,assignment_status_type_id    status_id
  ,user_status                  user_status
  FROM per_assignment_status_types
  WHERE per_system_status IN
   ('ACTIVE_APL','INTERVIEW1','INTERVIEW2','OFFER','ACCEPTED','TERM_APL');

  l_stage_code    VARCHAR2(30);
  l_event_code    VARCHAR2(30);
  l_event_seq     PLS_INTEGER;

BEGIN

  FOR status_rec IN status_csr LOOP

    cache_event_info
     (p_system_status => status_rec.system_status,
      p_user_status   => status_rec.user_status,
      p_status_id     => status_rec.status_id,
      p_stage_code    => l_stage_code,
      p_event_code    => l_event_code,
      p_event_seq     => l_event_seq);

  END LOOP;

END load_event_cache;


-- -----------------------------------------------------------------------------
-- Returns stage code for event
-- -----------------------------------------------------------------------------
FUNCTION get_stage_code(p_event_code      IN VARCHAR2)
        RETURN VARCHAR2 IS

BEGIN

  IF NOT g_event_cache.EXISTS(p_event_code) AND
     NOT g_cache_loaded THEN
    load_event_cache;
  END IF;

  IF NOT g_event_cache.EXISTS(p_event_code) THEN
    g_event_cache(p_event_code).stage_code := 'NON_PIPLN_STG';
    g_event_cache(p_event_code).event_seq  := -1;
  END IF;

  RETURN g_event_cache(p_event_code).stage_code;

END get_stage_code;


-- -----------------------------------------------------------------------------
-- Returns event sequence for event
-- -----------------------------------------------------------------------------
FUNCTION get_event_seq(p_event_code      IN VARCHAR2)
        RETURN NUMBER IS

BEGIN

  IF NOT g_event_cache.EXISTS(p_event_code) AND
     NOT g_cache_loaded THEN
    load_event_cache;
  END IF;

  IF NOT g_event_cache.EXISTS(p_event_code) THEN
    g_event_cache(p_event_code).stage_code := 'NON_PIPLN_STG';
    g_event_cache(p_event_code).event_seq  := -1;
  END IF;

  RETURN g_event_cache(p_event_code).event_seq;

EXCEPTION WHEN OTHERS THEN

  RETURN -1;

END get_event_seq;


-- -----------------------------------------------------------------------------
-- Returns termination type (Voluntary or Involuntary) for an application
-- termination reason
-- -----------------------------------------------------------------------------
FUNCTION get_appl_term_type(p_appl_term_rsn IN VARCHAR2) RETURN VARCHAR2 IS

  l_formula_input_tab  hri_bpl_fast_formula_util.formula_param_type;
  l_formula_output_tab hri_bpl_fast_formula_util.formula_param_type;

  l_term_type       varchar2(10);

BEGIN

  -- Calculate from FF if cache is empty
  IF NOT (g_term_cache_tab.exists(p_appl_term_rsn)) then

    -- Initialize formula input parameters
    l_formula_input_tab('TERMINATION_REASON') := p_appl_term_rsn;

    -- Trap exceptions if formula fails or doesn't exist
    BEGIN

      -- Run formula
      hri_bpl_fast_formula_util.run_formula
       (p_formula_id => g_term_formula_id,
        p_input_tab  => l_formula_input_tab,
        p_output_tab => l_formula_output_tab);

      -- Set output values
      l_term_type := l_formula_output_tab('TERMINATION_TYPE');

    EXCEPTION WHEN OTHERS THEN

      -- Default to Involuntary
      l_term_type := 'I';

    END;

    -- cache return value
    g_term_cache_tab(p_appl_term_rsn) := l_term_type;

  ELSE

    -- get cache value
    l_term_type := g_term_cache_tab(p_appl_term_rsn);

  END IF;

  -- Return termination type
  RETURN l_term_type;

END get_appl_term_type;


-- -----------------------------------------------------------------------------
-- Initialization
-- -----------------------------------------------------------------------------
BEGIN

  g_event_cache('VAC_OPEN').stage_code       := 'VAC_OPEN_STG';
  g_event_cache('APPL_STRT').stage_code      := 'INIT_APPL_STG';
  g_event_cache('ASMT_STRT').stage_code      := 'ASMT_STG';
  g_event_cache('ASMT_INT1').stage_code      := 'ASMT_STG';
  g_event_cache('ASMT_INT2').stage_code      := 'ASMT_STG';
  g_event_cache('OFFR_EXTD').stage_code      := 'OFFR_EXTD_STG';
  g_event_cache('OFFR_ACPT').stage_code      := 'STRT_PNDG_STG';
  g_event_cache('APPL_TERM_INIT').stage_code := 'APPL_TERM_STG';
  g_event_cache('APPL_TERM_ASMT').stage_code := 'APPL_TERM_STG';
  g_event_cache('APPL_TERM_OFFR').stage_code := 'APPL_TERM_STG';
  g_event_cache('APPL_TERM_ACPT').stage_code := 'APPL_TERM_STG';
  g_event_cache('EMPL_HIRE').stage_code      := 'HIRE_STG';
  g_event_cache('EMPL_APR1').stage_code      := 'HIRE_STG';
  g_event_cache('EMPL_LOW1_END').stage_code  := 'HIRE_STG';
  g_event_cache('EMPL_TERM').stage_code      := 'HIRE_STG';
  g_event_cache('NA_EDW').stage_code         := 'NON_PIPLN_STG';
  g_event_cache('VAC_OPEN').event_seq        := 100;
  g_event_cache('APPL_STRT').event_seq       := 200;
  g_event_cache('ASMT_STRT').event_seq       := 300;
  g_event_cache('ASMT_INT1').event_seq       := 400;
  g_event_cache('ASMT_INT2').event_seq       := 500;
  g_event_cache('OFFR_EXTD').event_seq       := 600;
  g_event_cache('OFFR_ACPT').event_seq       := 700;
  g_event_cache('APPL_TERM_INIT').event_seq  := 800;
  g_event_cache('APPL_TERM_ASMT').event_seq  := 900;
  g_event_cache('APPL_TERM_OFFR').event_seq  := 1000;
  g_event_cache('APPL_TERM_ACPT').event_seq  := 1100;
  g_event_cache('EMPL_HIRE').event_seq       := 1200;
  g_event_cache('EMPL_APR1').event_seq       := 1300;
  g_event_cache('EMPL_LOW1_END').event_seq   := 1400;
  g_event_cache('EMPL_TERM').event_seq       := 1500;
  g_event_cache('NA_EDW').event_seq          := -1;
  g_status_formula_id := hri_bpl_fast_formula_util.fetch_setup_formula_id
                          (p_formula_name => 'HRI_MAP_REC_APPL_STATUS');
  g_term_formula_id := hri_bpl_fast_formula_util.fetch_setup_formula_id
                        (p_formula_name => 'HRI_MAP_REC_APPL_TERM_TYPE');
  g_cache_loaded := FALSE;

END hri_bpl_rec_pipln;

/
