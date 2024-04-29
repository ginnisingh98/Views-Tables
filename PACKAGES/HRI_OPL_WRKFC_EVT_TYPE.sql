--------------------------------------------------------
--  DDL for Package HRI_OPL_WRKFC_EVT_TYPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_WRKFC_EVT_TYPE" AUTHID CURRENT_USER AS
/* $Header: hriowevtdim.pkh 120.1.12000000.2 2007/04/12 13:23:13 smohapat noship $ */

TYPE evtypcmb_rec_type IS RECORD
  (evtypcmb_code               VARCHAR2(240)
  ,assgnmnt_chng_flag_code     VARCHAR2(30)
  ,salary_chng_flag_code       VARCHAR2(30)
  ,prfrtng_chng_flag_code      VARCHAR2(30)
  ,perfband_chng_flag_code     VARCHAR2(30)
  ,powband_chng_flag_code      VARCHAR2(30)
  ,hdc_gain_flag_code          VARCHAR2(30)
  ,hdc_loss_flag_code          VARCHAR2(30)
  ,hdc_chng_flag_code          VARCHAR2(30)
  ,fte_gain_flag_code          VARCHAR2(30)
  ,fte_loss_flag_code          VARCHAR2(30)
  ,fte_chng_flag_code          VARCHAR2(30)
  ,grd_chng_flag_code          VARCHAR2(30)
  ,job_chng_flag_code          VARCHAR2(30)
  ,pos_chng_flag_code          VARCHAR2(30)
  ,loc_chng_flag_code          VARCHAR2(30)
  ,org_chng_flag_code          VARCHAR2(30)
  ,mgrh_chng_flag_code         VARCHAR2(30)
  ,hire_flag_code              VARCHAR2(30)
  ,asg_start_flag_code         VARCHAR2(30)
  ,hire_or_start_flag_code     VARCHAR2(30)
  ,term_or_end_flag_code       VARCHAR2(30)
  ,term_vol_flag_code          VARCHAR2(30)
  ,term_invol_flag_code        VARCHAR2(30)
  ,term_flag_code              VARCHAR2(30)
  ,asg_end_flag_code           VARCHAR2(30)
  ,start_sspnsn_flag_code      VARCHAR2(30)
  ,end_sspnsn_flag_code        VARCHAR2(30)
  ,prmtn_flag_code             VARCHAR2(30));

PROCEDURE truncate_evtypcmb_table;

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
        RETURN NUMBER;

END hri_opl_wrkfc_evt_type;

 

/
