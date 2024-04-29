--------------------------------------------------------
--  DDL for Package Body EDW_HR_POSITION_M_SIZING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_HR_POSITION_M_SIZING" AS
/* $Header: hriezpos.pkb 120.1 2005/06/08 02:48:05 anmajumd noship $ */

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
  SELECT count(position_id) total
  FROM per_all_positions
  WHERE NVL(last_update_date, to_date('01-01-2000','DD-MM-YYYY'))
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

  x_date                       NUMBER :=7;

  x_total_pos                  NUMBER;

  x_position_pk                NUMBER:=0;
  x_instance                   NUMBER:=0;
  x_pos_name                   NUMBER:=0;
  x_name                       NUMBER:=0;
  x_position_dp                NUMBER:=0;
  x_business_group             NUMBER:=0;
  x_all_fk                     NUMBER:=0;
  x_organization_id            NUMBER:=0;
  x_job_id                     NUMBER:=0;
  x_position_id                NUMBER:=0;
  x_position_definition_id     NUMBER:=0;
  x_business_group_id          NUMBER:=0;
  x_position_from_date         NUMBER:= x_date;
  x_position_to_date           NUMBER:= x_date;
  x_probation_period           NUMBER:=0;
  x_replacement_required       NUMBER:=0;
  x_time_normal_start          NUMBER:=0;
  x_time_normal_finish         NUMBER:=0;
  x_working_hours              NUMBER:=0;
  x_working_hour_freq          NUMBER:=0;
  x_last_update_date           NUMBER:= x_date;
  x_creation_date              NUMBER:= x_date;


/* Select the length of the instance code */
  CURSOR inst_cur IS
  SELECT avg(nvl( vsize(instance_code),0 ))
  FROM edw_local_instance;

  CURSOR pos_cur IS
  SELECT
      avg(nvl(vsize(name),0))
     ,avg(nvl(vsize(organization_id),0))
     ,avg(nvl(vsize(job_id),0))
     ,avg(nvl(vsize(position_id),0))
     ,avg(nvl(vsize(position_definition_id),0))
     ,avg(nvl(vsize(business_group_id),0))
     ,avg(nvl(vsize(probation_period),0))
     ,avg(nvl(vsize(replacement_required_flag),0))
     ,avg(nvl(vsize(time_normal_start),0))
     ,avg(nvl(vsize(time_normal_finish),0))
     ,avg(nvl(vsize(working_hours),0))
     ,avg(nvl(vsize(hr_general.decode_lookup('FREQUENCY',frequency)),0))
  FROM per_all_positions
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

  CURSOR bgr_cur IS
  SELECT
      avg(nvl(vsize(name),0))
  FROM hr_all_organization_units
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

  BEGIN

  OPEN inst_cur;
  FETCH inst_cur INTO x_instance;
  CLOSE inst_cur;

  OPEN pos_cur;
  FETCH pos_cur INTO
    x_pos_name
   ,x_organization_id
   ,x_job_id
   ,x_position_id
   ,x_position_definition_id
   ,x_business_group_id
   ,x_probation_period
   ,x_replacement_required
   ,x_time_normal_start
   ,x_time_normal_finish
   ,x_working_hours
   ,x_working_hour_freq;
  CLOSE pos_cur;

  OPEN bgr_cur;
  FETCH bgr_cur INTO x_business_group;
  CLOSE bgr_cur;

  x_position_pk := x_position_id + x_instance;
  x_name := x_pos_name + x_business_group + x_instance;
  x_name := x_position_dp;

  x_total_pos  :=  NVL(ceil(x_position_pk + 1), 0)
                 + NVL(ceil(x_instance + 1), 0)
                 + NVL(ceil(x_name + 1), 0)
                 + NVL(ceil(x_position_dp + 1), 0)
                 + NVL(ceil(x_business_group + 1), 0)
                 + NVL(ceil(x_organization_id + 1), 0)
                 + NVL(ceil(x_job_id + 1), 0)
                 + NVL(ceil(x_position_id + 1), 0)
                 + NVL(ceil(x_position_definition_id + 1), 0)
                 + NVL(ceil(x_business_group_id + 1), 0)
                 + NVL(ceil(x_position_from_date + 1), 0)
                 + NVL(ceil(x_position_to_date + 1), 0)
                 + NVL(ceil(x_probation_period + 1), 0)
                 + NVL(ceil(x_replacement_required + 1), 0)
                 + NVL(ceil(x_time_normal_start + 1), 0)
                 + NVL(ceil(x_time_normal_finish + 1), 0)
                 + NVL(ceil(x_working_hours + 1), 0)
                 + NVL(ceil(x_working_hour_freq + 1), 0)
                 + NVL(ceil(x_last_update_date + 1), 0)
                 + NVL(ceil(x_creation_date + 1), 0);

  p_avg_row_length :=  x_total_pos;

END estimate_row_length;


END edw_hr_position_m_sizing;

/
