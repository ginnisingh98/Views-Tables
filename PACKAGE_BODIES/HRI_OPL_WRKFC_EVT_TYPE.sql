--------------------------------------------------------
--  DDL for Package Body HRI_OPL_WRKFC_EVT_TYPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_WRKFC_EVT_TYPE" AS
/* $Header: hriowevtdim.pkb 120.1.12000000.2 2007/04/12 13:23:03 smohapat noship $ */

TYPE g_varchar2_idx_tab_type IS TABLE OF NUMBER INDEX BY VARCHAR2(240);

g_evtypcmb_cache_tab      g_varchar2_idx_tab_type;

-- -----------------------------------------------------------------------------
-- Truncates event combination table
-- -----------------------------------------------------------------------------
PROCEDURE truncate_evtypcmb_table IS

  l_dummy1        VARCHAR2(2000);
  l_dummy2        VARCHAR2(2000);
  l_schema        VARCHAR2(400);

BEGIN

  -- Get HRI schema name - get_app_info populates l_schema
  IF fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema) THEN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_schema || '.HRI_CL_WEVT_EVTYPCMB_CT';
  END IF;

  -- Insert -1 row
  INSERT INTO hri_cl_wevt_evtypcmb_ct
   (etcb_evtypcmb_pk
   ,etcb_evtypcmb_code
   ,etcb_assgnmnt_chng_flag_code
   ,etcb_salary_chng_flag_code
   ,etcb_prfrtng_chng_flag_code
   ,etcb_perfband_chng_flag_code
   ,etcb_powband_chng_flag_code
   ,etcb_hdc_gain_flag_code
   ,etcb_hdc_loss_flag_code
   ,etcb_hdc_chng_flag_code
   ,etcb_fte_gain_flag_code
   ,etcb_fte_loss_flag_code
   ,etcb_fte_chng_flag_code
   ,etcb_grd_chng_flag_code
   ,etcb_job_chng_flag_code
   ,etcb_pos_chng_flag_code
   ,etcb_loc_chng_flag_code
   ,etcb_org_chng_flag_code
   ,etcb_mgrh_chng_flag_code
   ,etcb_hire_flag_code
   ,etcb_asg_start_flag_code
   ,etcb_hire_or_start_flag_code
   ,etcb_term_or_end_flag_code
   ,etcb_term_vol_flag_code
   ,etcb_term_invol_flag_code
   ,etcb_term_flag_code
   ,etcb_asg_end_flag_code
   ,etcb_start_sspnsn_flag_code
   ,etcb_end_sspnsn_flag_code
   ,etcb_prmtn_flag_code)
    VALUES
     (-1
     ,'N-N-N-N-N-N-N-N-N-N-N-N-N-N-N-N-N-N-N-N-N-N-N-N-N-N-N-N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N'
     ,'N');

END truncate_evtypcmb_table;

-- -----------------------------------------------------------------------------
-- Translates an indicator (1/0) to a flag_code (Y/N)
-- -----------------------------------------------------------------------------
PROCEDURE ind_to_flag_code(p_indicator   IN NUMBER,
                      p_flag_code        OUT NOCOPY VARCHAR2) IS
BEGIN

  IF (p_indicator = 1) THEN
    p_flag_code := 'Y';
  ELSE
    p_flag_code := 'N';
  END IF;

END ind_to_flag_code;


-- -----------------------------------------------------------------------------
-- Inserts event combination record
-- -----------------------------------------------------------------------------
FUNCTION insert_evtypcmb(p_event_rec    IN evtypcmb_rec_type)
           RETURN NUMBER IS

  l_evtypcmb_fk    NUMBER;

BEGIN

  -- Get next sequence value
  SELECT hri_cl_wevt_evtypcmb_ct_s.nextval
  INTO l_evtypcmb_fk
  FROM dual;

  -- Insert row
  INSERT INTO hri_cl_wevt_evtypcmb_ct
   (etcb_evtypcmb_pk
   ,etcb_evtypcmb_code
   ,etcb_assgnmnt_chng_flag_code
   ,etcb_salary_chng_flag_code
   ,etcb_prfrtng_chng_flag_code
   ,etcb_perfband_chng_flag_code
   ,etcb_powband_chng_flag_code
   ,etcb_hdc_gain_flag_code
   ,etcb_hdc_loss_flag_code
   ,etcb_hdc_chng_flag_code
   ,etcb_fte_gain_flag_code
   ,etcb_fte_loss_flag_code
   ,etcb_fte_chng_flag_code
   ,etcb_grd_chng_flag_code
   ,etcb_job_chng_flag_code
   ,etcb_pos_chng_flag_code
   ,etcb_loc_chng_flag_code
   ,etcb_org_chng_flag_code
   ,etcb_mgrh_chng_flag_code
   ,etcb_hire_flag_code
   ,etcb_asg_start_flag_code
   ,etcb_hire_or_start_flag_code
   ,etcb_term_or_end_flag_code
   ,etcb_term_vol_flag_code
   ,etcb_term_invol_flag_code
   ,etcb_term_flag_code
   ,etcb_asg_end_flag_code
   ,etcb_start_sspnsn_flag_code
   ,etcb_end_sspnsn_flag_code
   ,etcb_prmtn_flag_code)
    VALUES
     (l_evtypcmb_fk
     ,p_event_rec.evtypcmb_code
     ,p_event_rec.assgnmnt_chng_flag_code
     ,p_event_rec.salary_chng_flag_code
     ,p_event_rec.prfrtng_chng_flag_code
     ,p_event_rec.perfband_chng_flag_code
     ,p_event_rec.powband_chng_flag_code
     ,p_event_rec.hdc_gain_flag_code
     ,p_event_rec.hdc_loss_flag_code
     ,p_event_rec.hdc_chng_flag_code
     ,p_event_rec.fte_gain_flag_code
     ,p_event_rec.fte_loss_flag_code
     ,p_event_rec.fte_chng_flag_code
     ,p_event_rec.grd_chng_flag_code
     ,p_event_rec.job_chng_flag_code
     ,p_event_rec.pos_chng_flag_code
     ,p_event_rec.loc_chng_flag_code
     ,p_event_rec.org_chng_flag_code
     ,p_event_rec.mgrh_chng_flag_code
     ,p_event_rec.hire_flag_code
     ,p_event_rec.asg_start_flag_code
     ,p_event_rec.hire_or_start_flag_code
     ,p_event_rec.term_or_end_flag_code
     ,p_event_rec.term_vol_flag_code
     ,p_event_rec.term_invol_flag_code
     ,p_event_rec.term_flag_code
     ,p_event_rec.asg_end_flag_code
     ,p_event_rec.start_sspnsn_flag_code
     ,p_event_rec.end_sspnsn_flag_code
     ,p_event_rec.prmtn_flag_code);

END insert_evtypcmb;


-- -----------------------------------------------------------------------------
-- Converts event combination record to a cache key
-- -----------------------------------------------------------------------------
FUNCTION get_evtypcmb_code(p_event_rec    IN evtypcmb_rec_type)
           RETURN VARCHAR2 IS

  l_evtypcmb_code   VARCHAR2(240);

BEGIN

  l_evtypcmb_code :=
   p_event_rec.assgnmnt_chng_flag_code || '-' ||
   p_event_rec.salary_chng_flag_code || '-' ||
   p_event_rec.prfrtng_chng_flag_code || '-' ||
   p_event_rec.perfband_chng_flag_code || '-' ||
   p_event_rec.powband_chng_flag_code || '-' ||
   p_event_rec.hdc_gain_flag_code || '-' ||
   p_event_rec.hdc_loss_flag_code || '-' ||
   p_event_rec.hdc_chng_flag_code || '-' ||
   p_event_rec.fte_gain_flag_code || '-' ||
   p_event_rec.fte_loss_flag_code || '-' ||
   p_event_rec.fte_chng_flag_code || '-' ||
   p_event_rec.grd_chng_flag_code || '-' ||
   p_event_rec.job_chng_flag_code || '-' ||
   p_event_rec.pos_chng_flag_code || '-' ||
   p_event_rec.loc_chng_flag_code || '-' ||
   p_event_rec.org_chng_flag_code || '-' ||
   p_event_rec.mgrh_chng_flag_code || '-' ||
   p_event_rec.hire_flag_code || '-' ||
   p_event_rec.asg_start_flag_code || '-' ||
   p_event_rec.hire_or_start_flag_code || '-' ||
   p_event_rec.term_or_end_flag_code || '-' ||
   p_event_rec.term_vol_flag_code || '-' ||
   p_event_rec.term_invol_flag_code || '-' ||
   p_event_rec.term_flag_code || '-' ||
   p_event_rec.asg_end_flag_code || '-' ||
   p_event_rec.start_sspnsn_flag_code || '-' ||
   p_event_rec.end_sspnsn_flag_code || '-' ||
   p_event_rec.prmtn_flag_code;

  RETURN l_evtypcmb_code;

END get_evtypcmb_code;


-- -----------------------------------------------------------------------------
-- Lookups up event combination record
-- -----------------------------------------------------------------------------
FUNCTION lookup_evtypcmb_fk(p_event_rec    IN evtypcmb_rec_type)
           RETURN NUMBER IS

  CURSOR evtypcmb_csr(v_evtypcmb_code  IN VARCHAR2) IS
  SELECT etcb_evtypcmb_pk
  FROM hri_cl_wevt_evtypcmb_ct
  WHERE etcb_evtypcmb_code = v_evtypcmb_code;

  l_evtypcmb_fk    NUMBER;

BEGIN

  -- Test whether combination key is already in cache
  BEGIN

    -- Get value from cache
    l_evtypcmb_fk := g_evtypcmb_cache_tab(p_event_rec.evtypcmb_code);

  -- Exception raised when cache miss
  EXCEPTION WHEN OTHERS THEN

    -- Test whether combination exists in table
    OPEN evtypcmb_csr(p_event_rec.evtypcmb_code);
    FETCH evtypcmb_csr INTO l_evtypcmb_fk;
    CLOSE evtypcmb_csr;

    -- If combination exists in table then set cache
    IF (l_evtypcmb_fk IS NOT NULL) THEN
      g_evtypcmb_cache_tab(p_event_rec.evtypcmb_code) := l_evtypcmb_fk;
    END IF;

  END;

  RETURN l_evtypcmb_fk;

END lookup_evtypcmb_fk;


-- -----------------------------------------------------------------------------
-- Main function to lookup, insert if necessary, and return key for event
-- combination.
-- -----------------------------------------------------------------------------
FUNCTION get_evtypcmb_fk(p_event_rec    IN evtypcmb_rec_type)
           RETURN NUMBER IS

  l_evtypcmb_fk    NUMBER;

BEGIN

  -- First lookup event combination to see if it already exists
  l_evtypcmb_fk := lookup_evtypcmb_fk
                         (p_event_rec => p_event_rec);

  -- Attempt insert of event combination if lookup failed
  IF (l_evtypcmb_fk IS NULL) THEN

    -- Trap exception that might occur if a simultaneous insert occurs
    -- by another thread
    BEGIN

      l_evtypcmb_fk := insert_evtypcmb
                             (p_event_rec => p_event_rec);

    EXCEPTION WHEN OTHERS THEN

      -- Retry lookup
      l_evtypcmb_fk := lookup_evtypcmb_fk
                             (p_event_rec => p_event_rec);

    END;

  END IF;

  RETURN l_evtypcmb_fk;

END get_evtypcmb_fk;


-- -----------------------------------------------------------------------------
-- Entry point to function to lookup, insert if necessary, and return key
-- for event combination.
-- -----------------------------------------------------------------------------
FUNCTION get_evtypcmb_fk
   (p_assignment_change_ind    IN NUMBER
   ,p_salary_change_ind        IN NUMBER
   ,p_perf_rating_change_ind   IN NUMBER
   ,p_perf_band_change_ind     IN NUMBER
   ,p_pow_band_change_ind      IN NUMBER
   ,p_headcount_gain_ind       IN NUMBER
   ,p_headcount_loss_ind       IN NUMBER
   ,p_fte_gain_ind             IN NUMBER
   ,p_fte_loss_ind             IN NUMBER
   ,p_grade_change_ind         IN NUMBER
   ,p_job_change_ind           IN NUMBER
   ,p_position_change_ind      IN NUMBER
   ,p_location_change_ind      IN NUMBER
   ,p_organization_change_ind  IN NUMBER
   ,p_supervisor_change_ind    IN NUMBER
   ,p_worker_hire_ind          IN NUMBER
   ,p_post_hire_asgn_start_ind IN NUMBER
   ,p_pre_sprtn_asgn_end_ind   IN NUMBER
   ,p_term_voluntary_ind       IN NUMBER
   ,p_term_involuntary_ind     IN NUMBER
   ,p_worker_term_ind          IN NUMBER
   ,p_start_sspnsn_ind         IN NUMBER
   ,p_end_sspnsn_ind           IN NUMBER
   ,p_promotion_ind            IN NUMBER)
        RETURN NUMBER IS

  l_evtypcmb_rec      evtypcmb_rec_type;
  l_hire_or_start_ind      NUMBER;
  l_term_or_end_ind        NUMBER;
  l_hdc_chng_ind           NUMBER;
  l_fte_chng_ind           NUMBER;
  l_evtypcmb_fk            NUMBER;

BEGIN

  -- Set derived indicators
  l_hire_or_start_ind := p_worker_hire_ind + p_post_hire_asgn_start_ind;
  l_term_or_end_ind   := p_worker_term_ind + p_pre_sprtn_asgn_end_ind;
  l_hdc_chng_ind      := p_headcount_gain_ind + p_headcount_loss_ind;
  l_fte_chng_ind      := p_fte_gain_ind + p_fte_loss_ind;

  -- Translate indicators to event combination record
  ind_to_flag_code(p_assignment_change_ind,    l_evtypcmb_rec.assgnmnt_chng_flag_code);
  ind_to_flag_code(p_salary_change_ind,        l_evtypcmb_rec.salary_chng_flag_code);
  ind_to_flag_code(p_perf_rating_change_ind,   l_evtypcmb_rec.prfrtng_chng_flag_code);
  ind_to_flag_code(p_perf_band_change_ind,     l_evtypcmb_rec.perfband_chng_flag_code);
  ind_to_flag_code(p_pow_band_change_ind,      l_evtypcmb_rec.powband_chng_flag_code);
  ind_to_flag_code(p_headcount_gain_ind,       l_evtypcmb_rec.hdc_gain_flag_code);
  ind_to_flag_code(p_headcount_loss_ind,       l_evtypcmb_rec.hdc_loss_flag_code);
  ind_to_flag_code(l_hdc_chng_ind,             l_evtypcmb_rec.hdc_chng_flag_code);
  ind_to_flag_code(p_fte_gain_ind,             l_evtypcmb_rec.fte_gain_flag_code);
  ind_to_flag_code(p_fte_loss_ind,             l_evtypcmb_rec.fte_loss_flag_code);
  ind_to_flag_code(l_fte_chng_ind,             l_evtypcmb_rec.fte_chng_flag_code);
  ind_to_flag_code(p_grade_change_ind,         l_evtypcmb_rec.grd_chng_flag_code);
  ind_to_flag_code(p_job_change_ind,           l_evtypcmb_rec.job_chng_flag_code);
  ind_to_flag_code(p_position_change_ind,      l_evtypcmb_rec.pos_chng_flag_code);
  ind_to_flag_code(p_location_change_ind,      l_evtypcmb_rec.loc_chng_flag_code);
  ind_to_flag_code(p_organization_change_ind,  l_evtypcmb_rec.org_chng_flag_code);
  ind_to_flag_code(p_supervisor_change_ind,    l_evtypcmb_rec.mgrh_chng_flag_code);
  ind_to_flag_code(p_worker_hire_ind,          l_evtypcmb_rec.hire_flag_code);
  ind_to_flag_code(p_post_hire_asgn_start_ind, l_evtypcmb_rec.asg_start_flag_code);
  ind_to_flag_code(l_hire_or_start_ind,        l_evtypcmb_rec.hire_or_start_flag_code);
  ind_to_flag_code(l_term_or_end_ind,          l_evtypcmb_rec.term_or_end_flag_code);
  ind_to_flag_code(p_term_voluntary_ind,       l_evtypcmb_rec.term_vol_flag_code);
  ind_to_flag_code(p_term_involuntary_ind,     l_evtypcmb_rec.term_invol_flag_code);
  ind_to_flag_code(p_worker_term_ind,          l_evtypcmb_rec.term_flag_code);
  ind_to_flag_code(p_pre_sprtn_asgn_end_ind,   l_evtypcmb_rec.asg_end_flag_code);
  ind_to_flag_code(p_start_sspnsn_ind,         l_evtypcmb_rec.start_sspnsn_flag_code);
  ind_to_flag_code(p_end_sspnsn_ind,           l_evtypcmb_rec.end_sspnsn_flag_code);
  ind_to_flag_code(p_promotion_ind,            l_evtypcmb_rec.prmtn_flag_code);

  -- Set event combination code
  l_evtypcmb_rec.evtypcmb_code := get_evtypcmb_code
                                   (p_event_rec => l_evtypcmb_rec);

  -- Call overloaded function with record
  l_evtypcmb_fk := get_evtypcmb_fk
                    (p_event_rec => l_evtypcmb_rec);

  RETURN l_evtypcmb_fk;

END get_evtypcmb_fk;

END hri_opl_wrkfc_evt_type;

/
