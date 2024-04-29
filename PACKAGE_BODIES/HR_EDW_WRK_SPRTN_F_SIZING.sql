--------------------------------------------------------
--  DDL for Package Body HR_EDW_WRK_SPRTN_F_SIZING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EDW_WRK_SPRTN_F_SIZING" AS
/* $Header: hriezwsp.pkb 120.1 2005/06/08 02:52:46 anmajumd noship $ */
/******************************************************************************/
/* Sets p_row_count to the number of rows which would be collected between    */
/* the given dates                                                            */
/******************************************************************************/
PROCEDURE count_source_rows( p_from_date IN  DATE,
                             p_to_date   IN  DATE,
                             p_row_count OUT NOCOPY NUMBER )
IS

  /* Cursor description */
  CURSOR row_count_cur IS
  SELECT count(pps.period_of_service_id) total
  FROM per_periods_of_service     pps
  WHERE NVL(pps.last_update_date, to_date('01-01-2000','DD-MM-YYYY'))
  BETWEEN p_from_date AND p_to_date;

BEGIN

  OPEN row_count_cur;
  FETCH row_count_cur INTO p_row_count;
  CLOSE row_count_cur;

END count_source_rows;

/******************************************************************************/
/* Estimates row lengths.                                                     */
/******************************************************************************/
PROCEDURE estimate_row_length( p_from_date        IN  DATE,
                               p_to_date          IN  DATE,
                               p_avg_row_length   OUT NOCOPY NUMBER )

IS

  x_date           NUMBER :=7;

  x_total_wsp      NUMBER;

  x_separation_pk                 NUMBER :=0;
  x_assignment_fk                 NUMBER :=0;
  x_age_band_fk                   NUMBER :=0;
  x_service_band_fk               NUMBER :=0;
  x_geography_fk                  NUMBER :=0;
  x_grade_fk                      NUMBER :=0;
  x_instance_fk                   NUMBER :=0;
  x_job_fk                        NUMBER :=0;
  x_organization_fk               NUMBER :=0;
  x_person_fk                     NUMBER :=0;
  x_person_type_fk                NUMBER :=0;
  x_position_fk                   NUMBER :=0;
  x_time_trm_ntfd_fk              NUMBER :=0;
  x_time_emp_strt_fk              NUMBER :=0;
  x_time_trm_accptd_fk            NUMBER :=0;
  x_time_trm_prjctd_fk            NUMBER :=0;
  x_time_trm_prcss_fk             NUMBER :=0;
  x_time_trm_occrd_fk             NUMBER :=0;
  x_reason_fk                     NUMBER :=0;
  x_movement_type_fk              NUMBER :=0;

  x_asg_assignment_id             NUMBER :=0;
  x_asg_business_group_id         NUMBER :=0;
  x_asg_grade_id                  NUMBER :=0;
  x_asg_job_id                    NUMBER :=0;
  x_asg_location_id               NUMBER :=0;
  x_asg_organization_id           NUMBER :=0;
  x_asg_person_id                 NUMBER :=0;
  x_asg_position_id               NUMBER :=0;

  x_pps_prd_of_srvc_id            NUMBER :=0;
  x_pps_trm_acptd_prsn_id         NUMBER :=0;
  x_leaving_reason                NUMBER :=0;

  x_date_of_birth                 NUMBER :=x_date;
  x_last_update_date              NUMBER :=x_date;
  x_creation_date                 NUMBER :=x_date;
  x_ntfd_trmntn_dt                NUMBER :=x_date;
  x_accptd_trmntn_dt              NUMBER :=x_date;
  x_prjctd_trmntn_dt              NUMBER :=x_date;
  x_actual_trmntn_dt              NUMBER :=x_date;
  x_final_process_dt              NUMBER :=x_date;

/* Select the length of the instance code */
  CURSOR inst_cur IS
  SELECT avg(nvl( vsize(instance_code),0 ))
  FROM edw_local_instance;

  CURSOR pps_cur IS
  SELECT
   avg(nvl(vsize(pps.period_of_service_id),0 ))
  ,avg(nvl(vsize(pps.termination_accepted_person_id),0 ))
  ,avg(nvl(vsize(pps.leaving_reason),0 ))
  FROM per_periods_of_service     pps
  WHERE pps.last_update_date BETWEEN p_from_date AND p_to_date;

  CURSOR pasg_cur IS
  SELECT
   avg(nvl(vsize(pasg.assignment_id),0 ))
  ,avg(nvl(vsize(pasg.business_group_id),0 ))
  ,avg(nvl(vsize(pasg.grade_id),0 ))
  ,avg(nvl(vsize(pasg.job_id  ),0 ))
  ,avg(nvl(vsize(pasg.location_id  ),0 ))
  ,avg(nvl(vsize(pasg.organization_id   ),0 ))
  ,avg(nvl(vsize(pasg.person_id  ),0 ))
  ,avg(nvl(vsize(pasg.position_id ),0 ))
  FROM per_all_assignments_f      pasg
  WHERE pasg.last_update_date BETWEEN p_from_date AND p_to_date;

BEGIN

  OPEN inst_cur;
  FETCH inst_cur INTO x_instance_fk;
  CLOSE inst_cur;

  OPEN pps_cur;
  FETCH pps_cur INTO
    x_pps_prd_of_srvc_id
   ,x_pps_trm_acptd_prsn_id
   ,x_leaving_reason;
  CLOSE pps_cur;

  OPEN pasg_cur;
  FETCH pasg_cur INTO
   x_asg_assignment_id
  ,x_asg_business_group_id
  ,x_asg_grade_id
  ,x_asg_job_id
  ,x_asg_location_id
  ,x_asg_organization_id
  ,x_asg_person_id
  ,x_asg_position_id;
  CLOSE pasg_cur;

  x_separation_pk      := x_pps_prd_of_srvc_id + x_asg_person_id + x_instance_fk;

  x_assignment_fk      := hri_edw_dim_sizing.get_size_asg_pk;
  x_age_band_fk        := hri_edw_dim_sizing.get_size_agb_pk;
  x_service_band_fk    := hri_edw_dim_sizing.get_size_lwb_pk;
  x_geography_fk       := hri_edw_dim_sizing.get_size_geog_pk;
  x_grade_fk           := hri_edw_dim_sizing.get_size_grd_pk;
  x_job_fk             := hri_edw_dim_sizing.get_size_job_pk;
  x_organization_fk    := hri_edw_dim_sizing.get_size_org_pk;
  x_person_fk          := hri_edw_dim_sizing.get_size_psn_pk;
  x_person_type_fk     := hri_edw_dim_sizing.get_size_pty_pk;
  x_position_fk        := hri_edw_dim_sizing.get_size_pos_pk;
  x_time_trm_accptd_fk := hri_edw_dim_sizing.get_size_time_pk;
  x_time_trm_ntfd_fk   := x_time_trm_accptd_fk;
  x_time_emp_strt_fk   := x_time_trm_accptd_fk;
  x_time_trm_prjctd_fk := x_time_trm_accptd_fk;
  x_time_trm_prcss_fk  := x_time_trm_accptd_fk;
  x_time_trm_occrd_fk  := x_time_trm_accptd_fk;
  x_reason_fk          := hri_edw_dim_sizing.get_size_rsn_pk;
  x_movement_type_fk   := hri_edw_dim_sizing.get_size_mvt_pk;


  x_total_wsp :=  NVL(ceil(  x_separation_pk   + 1), 0)
                + NVL(ceil(  x_assignment_fk    + 1), 0)
                + NVL(ceil(  x_age_band_fk     + 1), 0)
                + NVL(ceil(  x_service_band_fk + 1), 0)
                + NVL(ceil(  x_geography_fk  + 1), 0)
                + NVL(ceil(  x_grade_fk  + 1), 0)
                + NVL(ceil(  x_instance_fk  + 1), 0)
                + NVL(ceil(  x_job_fk  + 1), 0)
                + NVL(ceil(  x_organization_fk  + 1), 0)
                + NVL(ceil(  x_person_fk  + 1), 0)
                + NVL(ceil(  x_person_type_fk  + 1), 0)
                + NVL(ceil(  x_position_fk  + 1), 0)
                + NVL(ceil(  x_time_trm_ntfd_fk + 1), 0)
                + NVL(ceil(  x_time_emp_strt_fk  + 1), 0)
                + NVL(ceil(  x_time_trm_accptd_fk + 1), 0)
                + NVL(ceil(  x_time_trm_prjctd_fk + 1), 0)
                + NVL(ceil(  x_time_trm_prcss_fk + 1), 0)
                + NVL(ceil(  x_time_trm_occrd_fk + 1), 0)
                + NVL(ceil(  x_reason_fk + 1), 0)
                + NVL(ceil(  x_movement_type_fk  + 1), 0)
                + NVL(ceil(  x_asg_assignment_id  + 1), 0)
                + NVL(ceil(  x_asg_business_group_id  + 1), 0)
                + NVL(ceil(  x_asg_grade_id + 1), 0)
                + NVL(ceil(  x_asg_job_id + 1), 0)
                + NVL(ceil(  x_asg_location_id  + 1), 0)
                + NVL(ceil(  x_asg_organization_id  + 1), 0)
                + NVL(ceil(  x_asg_person_id  + 1), 0)
                + NVL(ceil(  x_asg_position_id + 1), 0)
                + NVL(ceil(  x_pps_prd_of_srvc_id  + 1), 0)
                + NVL(ceil(  x_pps_trm_acptd_prsn_id + 1), 0)
                + NVL(ceil(  x_date_of_birth  + 1), 0)
                + NVL(ceil(  x_last_update_date  + 1), 0)
                + NVL(ceil(  x_creation_date  + 1), 0)
                + NVL(ceil(  x_ntfd_trmntn_dt + 1), 0)
                + NVL(ceil(  x_accptd_trmntn_dt + 1), 0)
                + NVL(ceil(  x_prjctd_trmntn_dt + 1), 0)
                + NVL(ceil(  x_actual_trmntn_dt + 1), 0)
                + NVL(ceil(  x_final_process_dt + 1), 0)
                + NVL(ceil(  x_leaving_reason + 1), 0);

/* TOTAL */

  p_avg_row_length :=  x_total_wsp;

END estimate_row_length;

END hr_edw_wrk_sprtn_f_sizing;

/
