--------------------------------------------------------
--  DDL for Package Body HRI_EDW_DIM_SIZING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_EDW_DIM_SIZING" AS
/* $Header: hriezdmn.pkb 120.0 2005/05/29 07:20:41 appldev noship $ */

/******************************************************************************/
/* Returns average size of dimension pk                                       */
/******************************************************************************/
FUNCTION get_size_agb_pk
           RETURN NUMBER IS

  l_pk_length     NUMBER;

  CURSOR pk_cur IS
  SELECT avg(nvl(vsize(age_band_pk),0))
  FROM edw_hr_age_age_band_lcv;

BEGIN

  OPEN pk_cur;
  FETCH pk_cur INTO l_pk_length;
  CLOSE pk_cur;

  RETURN l_pk_length;

END get_size_agb_pk;

/******************************************************************************/
/* Returns average size of dimension pk                                       */
/******************************************************************************/
FUNCTION get_size_acg_pk
           RETURN NUMBER IS

  l_pk_length     NUMBER;

  CURSOR pk_cur IS
  SELECT avg(nvl(vsize(asg_change_pk),0))
  FROM edw_hr_asch_asg_chng_lcv;

BEGIN

  OPEN pk_cur;
  FETCH pk_cur INTO l_pk_length;
  CLOSE pk_cur;

  RETURN l_pk_length;

END get_size_acg_pk;

/******************************************************************************/
/* Returns average size of dimension pk                                       */
/******************************************************************************/
FUNCTION get_size_asg_pk
           RETURN NUMBER IS

  l_pk_length     NUMBER;

  CURSOR pk_cur IS
  SELECT avg(nvl(vsize(assignment_pk),0))
  FROM edw_hr_asgn_assgnmnt_lcv;

BEGIN

  OPEN pk_cur;
  FETCH pk_cur INTO l_pk_length;
  CLOSE pk_cur;

  RETURN l_pk_length;

END get_size_asg_pk;

/******************************************************************************/
/* Returns average size of dimension pk                                       */
/******************************************************************************/
FUNCTION get_size_grd_pk
           RETURN NUMBER IS

  l_pk_length     NUMBER;

  CURSOR pk_cur IS
  SELECT avg(nvl(vsize(grade_pk),0))
  FROM edw_hr_grd_grades_lcv;

BEGIN

  OPEN pk_cur;
  FETCH pk_cur INTO l_pk_length;
  CLOSE pk_cur;

  RETURN l_pk_length;

END get_size_grd_pk;

/******************************************************************************/
/* Returns average size of dimension pk                                       */
/******************************************************************************/
FUNCTION get_size_job_pk
           RETURN NUMBER IS

  l_pk_length     NUMBER;

  CURSOR pk_cur IS
  SELECT avg(nvl(vsize(job_pk),0))
  FROM edw_hr_job_jobs_lcv;

BEGIN

  OPEN pk_cur;
  FETCH pk_cur INTO l_pk_length;
  CLOSE pk_cur;

  RETURN l_pk_length;

END get_size_job_pk;

/******************************************************************************/
/* Returns average size of dimension pk                                       */
/******************************************************************************/
FUNCTION get_size_lwb_pk
           RETURN NUMBER IS

  l_pk_length     NUMBER;

  CURSOR pk_cur IS
  SELECT avg(nvl(vsize(service_band_pk),0))
  FROM edw_hr_srvc_srv_band_lcv;

BEGIN

  OPEN pk_cur;
  FETCH pk_cur INTO l_pk_length;
  CLOSE pk_cur;

  RETURN l_pk_length;

END get_size_lwb_pk;

/******************************************************************************/
/* Returns average size of dimension pk                                       */
/******************************************************************************/
FUNCTION get_size_mvt_pk
           RETURN NUMBER IS

  l_pk_length     NUMBER;

  CURSOR pk_cur IS
  SELECT avg(nvl(vsize(movement_pk),0))
  FROM edw_hr_mvmt_mvmnts_lcv;

BEGIN

  OPEN pk_cur;
  FETCH pk_cur INTO l_pk_length;
  CLOSE pk_cur;

  RETURN l_pk_length;

END get_size_mvt_pk;

/******************************************************************************/
/* Returns average size of dimension pk                                       */
/******************************************************************************/
FUNCTION get_size_pty_pk
           RETURN NUMBER IS

  l_pk_length     NUMBER;

  CURSOR pk_cur IS
  SELECT avg(nvl(vsize(person_type_pk),0))
  FROM edw_hr_ptyp_prsn_typ_lcv;

BEGIN

  OPEN pk_cur;
  FETCH pk_cur INTO l_pk_length;
  CLOSE pk_cur;

  RETURN l_pk_length;

END get_size_pty_pk;

/******************************************************************************/
/* Returns average size of dimension pk                                       */
/******************************************************************************/
FUNCTION get_size_pos_pk
           RETURN NUMBER IS

  l_pk_length     NUMBER;

  CURSOR pk_cur IS
  SELECT avg(nvl(vsize(position_pk),0))
  FROM edw_hr_pstn_position_lcv;

BEGIN

  OPEN pk_cur;
  FETCH pk_cur INTO l_pk_length;
  CLOSE pk_cur;

  RETURN l_pk_length;

END get_size_pos_pk;

/******************************************************************************/
/* Returns average size of dimension pk                                       */
/******************************************************************************/
FUNCTION get_size_psn_pk
           RETURN NUMBER IS

  l_pk_length     NUMBER;

  CURSOR pk_cur IS
  SELECT avg(nvl(vsize(assignment_pk),0))
  FROM edw_hr_perm_assign_lcv;

BEGIN

  OPEN pk_cur;
  FETCH pk_cur INTO l_pk_length;
  CLOSE pk_cur;

  RETURN l_pk_length;

END get_size_psn_pk;

/******************************************************************************/
/* Returns average size of dimension pk                                       */
/******************************************************************************/
FUNCTION get_size_org_pk
           RETURN NUMBER IS

  l_pk_length     NUMBER;

  CURSOR pk_cur IS
  SELECT avg(nvl(vsize(organization_pk),0))
  FROM edw_orga_org_lcv;

BEGIN

  OPEN pk_cur;
  FETCH pk_cur INTO l_pk_length;
  CLOSE pk_cur;

  RETURN l_pk_length;

END get_size_org_pk;

/******************************************************************************/
/* Returns average size of dimension pk                                       */
/******************************************************************************/
FUNCTION get_size_rsn_pk
           RETURN NUMBER IS

  l_pk_length     NUMBER;

  CURSOR pk_cur IS
  SELECT avg(nvl(vsize(reason_pk),0))
  FROM edw_hr_rson_reasons_lcv;

BEGIN

  OPEN pk_cur;
  FETCH pk_cur INTO l_pk_length;
  CLOSE pk_cur;

  RETURN l_pk_length;

END get_size_rsn_pk;

/******************************************************************************/
/* Returns average size of dimension pk                                       */
/******************************************************************************/
FUNCTION get_size_vac_pk
           RETURN NUMBER IS

  l_pk_length     NUMBER;

  CURSOR pk_cur IS
  SELECT avg(nvl(vsize(vacancy_pk),0))
  FROM edw_hr_rqvc_vacancy_lcv;

BEGIN

  OPEN pk_cur;
  FETCH pk_cur INTO l_pk_length;
  CLOSE pk_cur;

  RETURN l_pk_length;

END get_size_vac_pk;

/******************************************************************************/
/* Returns average size of dimension pk                                       */
/******************************************************************************/
FUNCTION get_size_rec_pk
           RETURN NUMBER IS

  l_pk_length     NUMBER;

  CURSOR pk_cur IS
  SELECT avg(nvl(vsize(rec_activity_pk),0))
  FROM edw_hr_ract_activity_lcv;

BEGIN

  OPEN pk_cur;
  FETCH pk_cur INTO l_pk_length;
  CLOSE pk_cur;

  RETURN l_pk_length;

END get_size_rec_pk;

/******************************************************************************/
/* Returns average size of dimension pk                                       */
/******************************************************************************/
FUNCTION get_size_geog_pk
           RETURN NUMBER IS

  l_pk_length     NUMBER;

  CURSOR pk_cur IS
  SELECT avg(nvl(vsize(location_pk),0))
  FROM edw_geog_location_lcv;

BEGIN

  OPEN pk_cur;
  FETCH pk_cur INTO l_pk_length;
  CLOSE pk_cur;

  RETURN l_pk_length;

END get_size_geog_pk;

/******************************************************************************/
/* Returns average size of dimension pk                                       */
/******************************************************************************/
FUNCTION get_size_time_pk
           RETURN NUMBER IS

  l_pk_length     NUMBER := 7;

BEGIN

/* Time pk is date plus constant */
  RETURN l_pk_length;

END get_size_time_pk;

END hri_edw_dim_sizing;

/
