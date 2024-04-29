--------------------------------------------------------
--  DDL for Package Body EDW_HR_ASSGNMNT_M_SIZING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_HR_ASSGNMNT_M_SIZING" AS
/* $Header: hriezasg.pkb 120.1 2005/06/08 02:45:02 anmajumd noship $ */
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
  FROM
   per_all_assignments_f       asg
  /* Generates list of earliest date tracked start dates by assignment */
  ,(select assignment_id, effective_start_date
  from per_all_assignments_f asg
  minus
  /* Remove any assignment start date which has an earlier start date */
  select assignment_id, effective_start_date
  from per_all_assignments_f asg
  where exists (select 1 from per_all_assignments_f asg1
                where asg1.assignment_id = asg.assignment_id
                and asg1.effective_start_date < asg.effective_start_date)
  )asg_start
  WHERE
  asg_start.assignment_id = asg.assignment_id
  AND    asg_start.effective_start_date = asg.effective_start_date
  AND NVL(asg.last_update_date, to_date('01-01-2000','DD-MM-YYYY'))
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

  x_date              NUMBER :=7;

  x_total_assgnmnt    NUMBER;

/* Assignment Level */

  x_assignment_pk		NUMBER :=0;
  x_name			NUMBER :=0;
  x_assignment_dp		NUMBER :=0;
  x_business_group		NUMBER :=0;
  x_assignment_number		NUMBER :=0;
  x_start_date			NUMBER :=x_date;
  x_end_date			NUMBER :=x_date;
  x_primary_flag		NUMBER :=0;
  x_instance			NUMBER :=0;
  x_assignment_id		NUMBER :=0;
  x_assignment_status_type_id   NUMBER :=0;
  x_business_group_id		NUMBER :=0;
  x_people_group_id		NUMBER :=0;
  x_effective_start_date	NUMBER :=x_date;
  x_effective_end_date		NUMBER :=x_date;
  x_title			NUMBER :=0;
  x_normal_hours_frequency 	NUMBER :=0;
  x_normal_hours		NUMBER :=0;
  x_assignment_status		NUMBER :=0;
  x_assignment_type		NUMBER :=0;
  x_manager_flag		NUMBER :=0;
  x_time_normal_start		NUMBER :=0;
  x_time_normal_end		NUMBER :=0;
  x_probation_period_unit	NUMBER :=0;
  x_probation_period		NUMBER :=0;
  x_perf_review_period_frqncy   NUMBER :=0;
  x_performance_review_period   NUMBER :=0;
  x_slry_review_period_frqncy   NUMBER :=0;
  x_slry_review_period		NUMBER :=0;
  x_hourly_salaried_flag	NUMBER :=0;
  x_last_update_date		NUMBER := x_date;
  x_creation_date		NUMBER := x_date;



/* Select the length of the instance code */
  CURSOR inst_cur IS
  SELECT avg(nvl( vsize(instance_code),0 ))
  FROM edw_local_instance;

 CURSOR asg_cur IS
 SELECT
   avg(nvl(vsize(assignment_number),0))
  ,avg(nvl(vsize(assignment_id),0))
  ,avg(nvl(vsize(title),0))
  ,avg(nvl(vsize(normal_hours),0))
  ,avg(nvl(vsize(time_normal_start),0))
  ,avg(nvl(vsize(time_normal_finish),0))
  ,avg(nvl(vsize(probation_period),0))
  ,avg(nvl(vsize(perf_review_period),0))
  ,avg(nvl(vsize(sal_review_period),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('YES_NO', primary_flag)),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('FREQUENCY', frequency)),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('EMP_APL', assignment_type)),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('YES_NO', manager_flag)),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('FREQUENCY', probation_unit)),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('FREQUENCY', perf_review_period_frequency)),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('FREQUENCY', sal_review_period_frequency)),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('HOURLY_SALARIED_CODE', hourly_salaried_code)),0))
 FROM per_all_assignments_f
 WHERE last_update_date BETWEEN p_from_date AND p_to_date;

 CURSOR ast_cur IS
  SELECT
    avg(nvl(vsize(assignment_status_type_id),0))
  FROM per_assignment_status_types
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

 CURSOR pgr_cur IS
  SELECT avg(nvl(vsize(people_group_id),0))
  FROM pay_people_groups
 WHERE last_update_date BETWEEN p_from_date AND p_to_date;

 CURSOR bgr_cur IS
  SELECT avg(nvl(vsize(name),0))
  FROM hr_all_organization_units
 WHERE last_update_date BETWEEN p_from_date AND p_to_date;

BEGIN

  OPEN inst_cur;
  FETCH inst_cur INTO x_instance;
  CLOSE inst_cur;

  OPEN asg_cur;
  FETCH asg_cur INTO
   x_assignment_number,
   x_assignment_id,
   x_title,
   x_normal_hours,
   x_time_normal_start,
   x_time_normal_end,
   x_probation_period,
   x_performance_review_period,
   x_slry_review_period,
   x_primary_flag,
   x_normal_hours_frequency,
   x_assignment_type,
   x_manager_flag,
   x_probation_period_unit,
   x_perf_review_period_frqncy,
   x_slry_review_period_frqncy,
   x_hourly_salaried_flag;
  CLOSE asg_cur;

  OPEN ast_cur;
  FETCH ast_cur INTO x_assignment_status_type_id;
  CLOSE ast_cur;

  OPEN pgr_cur;
  FETCH pgr_cur INTO x_people_group_id;
  CLOSE pgr_cur;

  OPEN bgr_cur;
  FETCH bgr_cur INTO x_business_group;
  CLOSE bgr_cur;


  x_assignment_pk := x_assignment_id + x_instance;
  x_name := x_assignment_number + x_instance;
  x_assignment_dp := x_assignment_number + x_instance;

  x_total_assgnmnt :=  NVL(ceil(x_assignment_pk + 1), 0)
 		     + NVL(ceil(x_name + 1), 0)
 		     + NVL(ceil(x_assignment_dp + 1), 0)
 		     + NVL(ceil(x_business_group + 1), 0)
		     + NVL(ceil(x_assignment_number + 1), 0)
 		     + NVL(ceil(x_start_date + 1), 0)
 	 	     + NVL(ceil(x_end_date + 1), 0)
 		     + NVL(ceil(x_primary_flag + 1), 0)
		     + NVL(ceil(x_instance + 1), 0)
 	             + NVL(ceil(x_assignment_id + 1), 0)
 		     + NVL(ceil(x_assignment_status_type_id + 1), 0)
 		     + NVL(ceil(x_business_group_id + 1), 0)
 		     + NVL(ceil(x_people_group_id + 1), 0)
 	             + NVL(ceil(x_effective_start_date + 1), 0)
 	             + NVL(ceil(x_effective_end_date + 1), 0)
 		     + NVL(ceil(x_title + 1), 0)
 		     + NVL(ceil(x_normal_hours_frequency + 1), 0)
 		     + NVL(ceil(x_normal_hours + 1), 0)
		     + NVL(ceil(x_assignment_status + 1), 0)
	             + NVL(ceil(x_assignment_type + 1), 0)
		     + NVL(ceil(x_manager_flag + 1), 0)
 		     + NVL(ceil(x_time_normal_start + 1), 0)
 		     + NVL(ceil(x_time_normal_end + 1), 0)
		     + NVL(ceil(x_probation_period_unit + 1), 0)
 		     + NVL(ceil(x_probation_period + 1), 0)
		     + NVL(ceil(x_perf_review_period_frqncy + 1), 0)
 		     + NVL(ceil(x_performance_review_period + 1), 0)
 		     + NVL(ceil(x_slry_review_period_frqncy + 1), 0)
 		     + NVL(ceil(x_slry_review_period + 1), 0)
		     + NVL(ceil(x_hourly_salaried_flag + 1), 0)
		     + NVL(ceil(x_last_update_date + 1), 0)
 		     + NVL(ceil(x_creation_date + 1), 0);

  /* TOTAL */

  p_avg_row_length := x_total_assgnmnt;

END estimate_row_length;

END edw_hr_assgnmnt_m_sizing;

/
