--------------------------------------------------------
--  DDL for Package Body HR_EDW_WRK_CMPSTN_F_SIZING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EDW_WRK_CMPSTN_F_SIZING" AS
/* $Header: hriezwcp.pkb 120.1 2005/06/08 02:51:46 anmajumd noship $ */
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
  SELECT count(*) total
  FROM hri_edw_cmpstn_snpsht_dts;

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

  x_date                    NUMBER :=7;

  x_total_wrk_cmpstn               NUMBER;

  x_composition_pk          NUMBER:=0;

  x_age_band_fk             NUMBER:=0;
  x_service_band_fk         NUMBER:=0;
  x_assignment_fk           NUMBER:=0;
  x_geography_fk            NUMBER:=0;
  x_grade_fk                NUMBER:=0;
  x_instance_fk             NUMBER:=0;
  x_job_fk                  NUMBER:=0;
  x_organization_fk         NUMBER:=0;
  x_person_fk               NUMBER:=0;
  x_person_type_fk          NUMBER:=0;
  x_position_fk             NUMBER:=0;
  x_time_fk                 NUMBER:=0;

  x_asg_assignment_id       NUMBER:=0;
  x_asg_business_group_id   NUMBER:=0;
  x_asg_grade_id            NUMBER:=0;
  x_asg_job_id              NUMBER:=0;
  x_asg_location_id         NUMBER:=0;
  x_asg_organization_id     NUMBER:=0;
  x_asg_person_id           NUMBER:=0;
  x_asg_position_id         NUMBER:=0;

  x_snapshot_date           NUMBER:=x_date;
  x_assignment_start_date   NUMBER:=x_date;
  x_date_of_birth           NUMBER:=x_date;
  x_last_update_date        NUMBER:=x_date;
  x_creation_date           NUMBER:=x_date;

  /* Select the length of the instance code */
  CURSOR inst_cur IS
  SELECT avg(nvl( vsize(instance_code),0 ))
  FROM edw_local_instance;

  CURSOR asg_cur IS
  SELECT
   avg(nvl(vsize(asg.assignment_id ),0))
  ,avg(nvl(vsize(asg.business_group_id ),0))
  ,avg(nvl(vsize(asg.grade_id),0))
  ,avg(nvl(vsize(asg.job_id),0))
  ,avg(nvl(vsize(asg.location_id ),0))
  ,avg(nvl(vsize(asg.organization_id),0))
  ,avg(nvl(vsize(asg.person_id ),0))
  ,avg(nvl(vsize(asg.position_id ),0))
  FROM  per_all_assignments_f      asg
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

BEGIN

  OPEN inst_cur;
  FETCH inst_cur INTO x_instance_fk;
  CLOSE inst_cur;

  OPEN asg_cur;
  FETCH asg_cur INTO
   x_asg_assignment_id
  ,x_asg_business_group_id
  ,x_asg_grade_id
  ,x_asg_job_id
  ,x_asg_location_id
  ,x_asg_organization_id
  ,x_asg_person_id
  ,x_asg_position_id;
  CLOSE asg_cur;

  x_composition_pk  := x_asg_assignment_id + x_snapshot_date + x_instance_fk  ;

  x_age_band_fk     := hri_edw_dim_sizing.get_size_agb_pk;
  x_service_band_fk := hri_edw_dim_sizing.get_size_lwb_pk;
  x_assignment_fk   := hri_edw_dim_sizing.get_size_asg_pk;
  x_geography_fk    := hri_edw_dim_sizing.get_size_geog_pk;
  x_grade_fk        := hri_edw_dim_sizing.get_size_grd_pk;
  x_job_fk          := hri_edw_dim_sizing.get_size_job_pk;
  x_organization_fk := hri_edw_dim_sizing.get_size_org_pk;
  x_person_fk       := hri_edw_dim_sizing.get_size_psn_pk;
  x_person_type_fk  := hri_edw_dim_sizing.get_size_pty_pk;
  x_position_fk     := hri_edw_dim_sizing.get_size_pos_pk;
  x_time_fk         := hri_edw_dim_sizing.get_size_time_pk;


  x_total_wrk_cmpstn :=  NVL(ceil(x_composition_pk + 1), 0)
                       + NVL(ceil(x_composition_pk + 1), 0)
                       + NVL(ceil(x_age_band_fk + 1), 0)
                       + NVL(ceil(x_service_band_fk + 1), 0)
                       + NVL(ceil(x_assignment_fk + 1), 0)
                       + NVL(ceil(x_geography_fk + 1), 0)
                       + NVL(ceil(x_grade_fk + 1), 0)
                       + NVL(ceil(x_instance_fk + 1), 0)
                       + NVL(ceil(x_job_fk + 1), 0)
                       + NVL(ceil(x_organization_fk + 1), 0)
                       + NVL(ceil(x_person_fk + 1), 0)
                       + NVL(ceil(x_person_type_fk + 1), 0)
                       + NVL(ceil(x_position_fk + 1), 0)
                       + NVL(ceil(x_time_fk + 1), 0)
                       + NVL(ceil(x_asg_assignment_id + 1), 0)
                       + NVL(ceil(x_asg_business_group_id + 1), 0)
                       + NVL(ceil(x_asg_grade_id + 1), 0)
                       + NVL(ceil(x_asg_job_id + 1), 0)
                       + NVL(ceil(x_asg_location_id + 1), 0)
                       + NVL(ceil(x_asg_organization_id + 1), 0)
                       + NVL(ceil(x_asg_person_id + 1), 0)
                       + NVL(ceil(x_asg_position_id + 1), 0)
                       + NVL(ceil(x_snapshot_date + 1), 0)
                       + NVL(ceil(x_assignment_start_date + 1), 0)
                       + NVL(ceil(x_date_of_birth + 1), 0)
                       + NVL(ceil(x_last_update_date + 1), 0)
                       + NVL(ceil(x_creation_date + 1), 0);

/* TOTAL */

  p_avg_row_length :=  x_total_wrk_cmpstn;

END estimate_row_length;

END hr_edw_wrk_cmpstn_f_sizing;

/
