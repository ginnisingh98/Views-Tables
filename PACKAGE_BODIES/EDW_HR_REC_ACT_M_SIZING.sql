--------------------------------------------------------
--  DDL for Package Body EDW_HR_REC_ACT_M_SIZING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_HR_REC_ACT_M_SIZING" AS
/* $Header: hriezrec.pkb 120.1 2005/06/08 02:49:50 anmajumd noship $ */
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
  SELECT count(recruitment_activity_id) total
  FROM per_recruitment_activities
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

  x_date                    NUMBER :=7;

  x_total_rec               NUMBER :=0;
  x_total_aty               NUMBER :=0;

/* Activity Type Level */
  x_activity_type_pk        NUMBER :=0;
  x_activity_type_code      NUMBER :=0;
  x_aty_name                NUMBER :=0;
  x_activity_type_dp        NUMBER :=0;
  x_aty_meaning            NUMBER :=0;

/* Recruitment Activity Level */

  x_rec_activity_pk         NUMBER :=0;
  x_activity_type_fk        NUMBER :=0;
  x_rec_name                NUMBER :=0;
  x_rca_name                NUMBER :=0;
  x_bgr_name                NUMBER :=0;
  x_rec_activity_dp         NUMBER :=0;
  x_external_contact        NUMBER :=0;
  x_instance                NUMBER :=0;
  x_business_group_id       NUMBER :=0;
  x_rec_activity_id         NUMBER :=0;
  x_activity_cost           NUMBER :=0;
  x_activity_planned_cost   NUMBER :=0;
  x_start_date              NUMBER :=x_date;
  x_end_date                NUMBER :=x_date;
  x_closing_date            NUMBER :=x_date;
  x_last_update_date        NUMBER :=x_date;
  x_creation_date           NUMBER :=x_date;


/* Selects the length of the instance code */
  CURSOR inst_cur IS
  SELECT avg(nvl(vsize(instance_code),0))
  FROM edw_local_instance
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

 CURSOR rca_cur IS
  SELECT
   avg(nvl(vsize(name),0))
  ,avg(nvl(vsize(external_contact),0))
  ,avg(nvl(vsize(business_group_id),0))
  ,avg(nvl(vsize(recruitment_activity_id),0))
  ,avg(nvl(vsize(actual_cost),0))
  ,avg(nvl(vsize(planned_cost),0))
  FROM per_recruitment_activities
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

 CURSOR bus_cur IS
  SELECT avg(nvl(vsize(name),0))
  FROM hr_all_organization_units
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

 CURSOR hrl_cur IS
  SELECT avg(nvl(vsize(lookup_code),0))
  ,avg(nvl(vsize(meaning),0))
  FROM hr_lookups
  WHERE last_update_date BETWEEN p_from_date AND p_to_date
  AND lookup_type = 'REC_TYPE';


BEGIN
/* Selects the length of the instance code */
  OPEN inst_cur;
  FETCH inst_cur INTO x_instance;
  CLOSE inst_cur;

  OPEN hrl_cur;
  FETCH hrl_cur INTO x_activity_type_code, x_aty_meaning;
  CLOSE hrl_cur;

  OPEN rca_cur;
  FETCH rca_cur INTO
  x_rca_name
 ,x_external_contact
 ,x_business_group_id
 ,x_rec_activity_id
 ,x_activity_cost
 ,x_activity_planned_cost;
 CLOSE rca_cur;

  OPEN bus_cur;
  FETCH bus_cur INTO x_bgr_name;
  CLOSE bus_cur;

/* Activity Type Level */

  x_activity_type_pk := x_activity_type_code + x_instance;
  x_aty_name := x_aty_meaning + x_instance;
  x_activity_type_dp := x_aty_name;

  x_total_aty := NVL (ceil(x_activity_type_pk + 1), 0)
               + NVL (ceil(x_activity_type_code + 1), 0)
               + NVL (ceil(x_aty_name + 1), 0)
               + NVL (ceil(x_activity_type_dp + 1), 0)
               + NVL (ceil(x_instance + 1), 0)
               + NVL (ceil(x_last_update_date + 1), 0)
               + NVL (ceil(x_creation_date + 1), 0);

/* Recruitment Activity Level */

  x_rec_activity_pk := x_activity_type_pk + x_rec_activity_id + x_instance;
  x_rec_name := x_rca_name + x_bgr_name + x_instance;
  x_rec_activity_dp := x_rec_name;
  x_activity_type_fk := x_activity_type_pk;

  x_total_rec :=   NVL (ceil(x_rec_activity_pk  + 1), 0)
                 + NVL (ceil(x_activity_type_fk + 1), 0)
                 + NVL (ceil(x_rec_name + 1), 0)
                 + NVL (ceil(x_rec_activity_dp  + 1), 0)
                 + NVL (ceil(x_external_contact + 1), 0)
                 + NVL (ceil(x_instance + 1), 0)
                 + NVL (ceil(x_business_group_id + 1), 0)
                 + NVL (ceil(x_rec_activity_id + 1), 0)
                 + NVL (ceil(x_activity_cost + 1), 0)
                 + NVL (ceil(x_activity_planned_cost + 1), 0)
                 + NVL (ceil(x_start_date + 1), 0)
                 + NVL (ceil(x_end_date + 1), 0)
                 + NVL (ceil(x_closing_date + 1), 0)
                 + NVL (ceil(x_last_update_date + 1), 0)
                 + NVL (ceil(x_creation_date + 1), 0);


  p_avg_row_length := x_total_rec + x_total_aty;

END estimate_row_length;

END edw_hr_rec_act_m_sizing;

/
