--------------------------------------------------------
--  DDL for Package Body HR_EDW_WRK_RCTMNT_F_SIZING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EDW_WRK_RCTMNT_F_SIZING" AS
/* $Header: hriezwrt.pkb 120.1 2005/06/08 02:52:08 anmajumd noship $ */
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
  SELECT count(rec.application_id) total
  FROM hri_recruitment_stages       rec
  WHERE NVL(rec.last_update_date, to_date('01-01-2000','DD-MM-YYYY'))
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

  x_date       NUMBER := 7;

  x_total                 NUMBER;

  x_recruitment_gain_pk   NUMBER;

/****************************/
/* Fact Hidden Primary Keys */
/****************************/
  x_application_id           NUMBER := 0;
  x_assignment_id            NUMBER := 0;
  x_business_group_id        NUMBER := 0;
  x_person_id                NUMBER := 0;
  x_instance                 NUMBER := 0;

/******************************/
/* Foreign Keys to Dimensions */
/******************************/
  x_age_band_fk               NUMBER := 0;
  x_assignment_fk             NUMBER := 0;
  x_geography_fk              NUMBER := 0;
  x_grade_fk                  NUMBER := 0;
  x_instance_fk               NUMBER := 0;
  x_job_fk                    NUMBER := 0;
  x_organization_fk           NUMBER := 0;
  x_person_fk                 NUMBER := 0;
  x_person_type_fk            NUMBER := 0;
  x_position_fk               NUMBER := 0;
  x_movement_fk               NUMBER := 0;
  x_reason_fk                 NUMBER := 0;
  x_requisition_vacancy_fk    NUMBER := 0;
  x_recruitment_activity_fk   NUMBER := 0;
  x_service_band_fk           NUMBER := 0;
  x_time_fk                   NUMBER := 0;

/**********************/
/* Regular Attributes */
/**********************/
  x_application_start_date    NUMBER := x_date;
  x_application_end_date      NUMBER := x_date;
  x_hire_date                 NUMBER := x_date;
  x_planned_start_date        NUMBER := x_date;
  x_creation_date             NUMBER := x_date;
  x_last_update_date          NUMBER := x_date;

/* Select the length of the instance code */
  CURSOR inst_cur IS
  SELECT avg(nvl( vsize(instance_code),0 ))
  FROM edw_local_instance;

  CURSOR asg_cur IS
  SELECT
   avg(nvl(vsize(application_id),0))
  ,avg(nvl(vsize(assignment_id),0))
  ,avg(nvl(vsize(business_group_id  ),0))
  ,avg(nvl(vsize(person_id),0))
  FROM
   per_all_assignments_f
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

BEGIN

  OPEN inst_cur;
  FETCH inst_cur INTO x_instance;
  CLOSE inst_cur;

  x_age_band_fk             := hri_edw_dim_sizing.get_size_agb_pk;
  x_assignment_fk           := hri_edw_dim_sizing.get_size_asg_pk;
  x_geography_fk            := hri_edw_dim_sizing.get_size_geog_pk;
  x_grade_fk                := hri_edw_dim_sizing.get_size_grd_pk;
  x_instance_fk             := x_instance;
  x_job_fk                  := hri_edw_dim_sizing.get_size_job_pk;
  x_organization_fk         := 2 * hri_edw_dim_sizing.get_size_org_pk;
  x_person_fk               := 4 * hri_edw_dim_sizing.get_size_psn_pk;
  x_person_type_fk          := hri_edw_dim_sizing.get_size_pty_pk;
  x_position_fk             := hri_edw_dim_sizing.get_size_pos_pk;
  x_movement_fk             := 8 * hri_edw_dim_sizing.get_size_mvt_pk;
  x_reason_fk               := 8 * hri_edw_dim_sizing.get_size_rsn_pk;
  x_requisition_vacancy_fk  := hri_edw_dim_sizing.get_size_vac_pk;
  x_recruitment_activity_fk := hri_edw_dim_sizing.get_size_rec_pk;
  x_service_band_fk         := hri_edw_dim_sizing.get_size_lwb_pk;
  x_time_fk                 := 8* hri_edw_dim_sizing.get_size_time_pk;

  OPEN asg_cur;
  FETCH asg_cur INTO
   x_application_id
  ,x_assignment_id
  ,x_business_group_id
  ,x_person_id;
  CLOSE asg_cur;

  x_recruitment_gain_pk := x_application_id + x_assignment_id + x_instance;

  x_total          := NVL(ceil(x_recruitment_gain_pk+ 1), 0)
                    + NVL(ceil(x_application_id+ 1), 0)
                    + NVL(ceil(x_assignment_id+ 1), 0)
                    + NVL(ceil(x_business_group_id+ 1), 0)
                    + NVL(ceil(x_person_id+ 1), 0)
                    + NVL(ceil(x_age_band_fk+ 1), 0)
                    + NVL(ceil(x_assignment_fk+ 1), 0)
                    + NVL(ceil(x_geography_fk+ 1), 0)
                    + NVL(ceil(x_grade_fk+ 1), 0)
                    + NVL(ceil(x_instance_fk+ 1), 0)
                    + NVL(ceil(x_job_fk+ 1), 0)
                    + NVL(ceil(x_organization_fk + 1), 0)
                    + NVL(ceil(x_person_fk + 1), 0)
                    + NVL(ceil(x_person_type_fk+ 1), 0)
                    + NVL(ceil(x_position_fk+ 1), 0)
                    + NVL(ceil(x_movement_fk+ 1), 0)
                    + NVL(ceil(x_reason_fk+ 1), 0)
                    + NVL(ceil(x_requisition_vacancy_fk+ 1), 0)
                    + NVL(ceil(x_recruitment_activity_fk+ 1), 0)
                    + NVL(ceil(x_service_band_fk+ 1), 0)
                    + NVL(ceil(x_time_fk+ 1), 0)
                    + NVL(ceil(x_application_start_date+ 1), 0)
                    + NVL(ceil(x_application_end_date+ 1), 0)
                    + NVL(ceil(x_hire_date+ 1), 0)
                    + NVL(ceil(x_planned_start_date+ 1), 0)
                    + NVL(ceil(x_creation_date+ 1), 0)
                    + NVL(ceil(x_last_update_date+ 1), 0);

  p_avg_row_length :=  x_total;

END estimate_row_length;

END hr_edw_wrk_rctmnt_f_sizing;

/
