--------------------------------------------------------
--  DDL for Package Body EDW_HR_JOBS_M_SIZING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_HR_JOBS_M_SIZING" AS
/* $Header: hriezjob.pkb 120.1 2005/06/08 02:45:51 anmajumd noship $ */

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
  SELECT count(job.job_id) total
  FROM per_jobs job
  WHERE NVL(job.last_update_date, to_date('01-01-2000','DD-MM-YYYY'))
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

    x_job_total      NUMBER;

/* Job Band Level */

  x_job_pk              NUMBER := 0;
  x_instance            NUMBER := 0;
  x_job_name            NUMBER := 0;
  x_name                NUMBER := 0;
  x_job_dp              NUMBER := 0;
  x_business_group      NUMBER := 0;
  x_job_id              NUMBER := 0;
  x_business_group_id   NUMBER := 0;
  x_job_definition_id   NUMBER := 0;
  x_job_cat_set1        NUMBER := 0;
  x_job_cat_set2        NUMBER := 0;
  x_job_cat_set3        NUMBER := 0;
  x_job_cat_set4        NUMBER := 0;
  x_job_cat_set5        NUMBER := 0;
  x_job_cat_set6        NUMBER := 0;
  x_job_cat_set7        NUMBER := 0;
  x_job_cat_set8        NUMBER := 0;
  x_job_cat_set9        NUMBER := 0;
  x_job_cat_set10       NUMBER := 0;
  x_job_cat_set11       NUMBER := 0;
  x_job_cat_set12       NUMBER := 0;
  x_job_cat_set13       NUMBER := 0;
  x_job_cat_set14       NUMBER := 0;
  x_job_cat_set15       NUMBER := 0;
  x_benchmark_job_name  NUMBER := 0;
  x_benchmark_job_id    NUMBER := 0;
  x_emp_rights_flag     NUMBER := 0;
  x_benchmark_job_flag  NUMBER := 0;
  x_creation_date       NUMBER := x_date;
  x_last_update_date    NUMBER := x_date;


/* Select the length of the instance code */
  CURSOR inst_cur IS
  SELECT avg(nvl( vsize(instance_code),0 ))
  FROM edw_local_instance;

CURSOR job_cur IS
SELECT
  avg(nvl(vsize(job.job_id),0))
 ,avg(nvl(vsize(job.name),0))
 ,avg(nvl(vsize(hri_edw_dim_job.find_job_category(job.job_id,1)),0))
 ,avg(nvl(vsize(hri_edw_dim_job.find_job_category(job.job_id,2)),0))
 ,avg(nvl(vsize(hri_edw_dim_job.find_job_category(job.job_id,3)),0))
 ,avg(nvl(vsize(hri_edw_dim_job.find_job_category(job.job_id,4)),0))
 ,avg(nvl(vsize(hri_edw_dim_job.find_job_category(job.job_id,5)),0))
 ,avg(nvl(vsize(hri_edw_dim_job.find_job_category(job.job_id,6)),0))
 ,avg(nvl(vsize(hri_edw_dim_job.find_job_category(job.job_id,7)),0))
 ,avg(nvl(vsize(hri_edw_dim_job.find_job_category(job.job_id,8)),0))
 ,avg(nvl(vsize(hri_edw_dim_job.find_job_category(job.job_id,9)),0))
 ,avg(nvl(vsize(hri_edw_dim_job.find_job_category(job.job_id,10)),0))
 ,avg(nvl(vsize(hri_edw_dim_job.find_job_category(job.job_id,11)),0))
 ,avg(nvl(vsize(hri_edw_dim_job.find_job_category(job.job_id,12)),0))
 ,avg(nvl(vsize(hri_edw_dim_job.find_job_category(job.job_id,13)),0))
 ,avg(nvl(vsize(hri_edw_dim_job.find_job_category(job.job_id,14)),0))
 ,avg(nvl(vsize(hri_edw_dim_job.find_job_category(job.job_id,15)),0))
 ,avg(nvl(vsize(job.emp_rights_flag),0))
 ,avg(nvl(vsize(job.benchmark_job_flag),0))
FROM per_jobs job
WHERE job.last_update_date BETWEEN p_from_date AND p_to_date;

CURSOR jdef_cur IS
SELECT avg(nvl(vsize(jdef.job_definition_id),0))
FROM per_job_definitions jdef, per_jobs job
WHERE job.last_update_date BETWEEN p_from_date AND p_to_date;

CURSOR bgr_cur IS
SELECT
  avg(nvl(vsize(organization_id),0))
 ,avg(nvl(vsize(bgr.name),0))
FROM hr_all_organization_units bgr, per_jobs job
WHERE job.last_update_date BETWEEN p_from_date AND p_to_date;


BEGIN

  OPEN inst_cur;
  FETCH inst_cur INTO x_instance;
  CLOSE inst_cur;

  OPEN job_cur;
  FETCH job_cur INTO
   x_job_id
  ,x_job_name
  ,x_job_cat_set1
  ,x_job_cat_set2
  ,x_job_cat_set3
  ,x_job_cat_set4
  ,x_job_cat_set5
  ,x_job_cat_set6
  ,x_job_cat_set7
  ,x_job_cat_set8
  ,x_job_cat_set9
  ,x_job_cat_set10
  ,x_job_cat_set11
  ,x_job_cat_set12
  ,x_job_cat_set13
  ,x_job_cat_set14
  ,x_job_cat_set15
  ,x_emp_rights_flag
  ,x_benchmark_job_flag;
CLOSE job_cur;

  OPEN jdef_cur;
  FETCH jdef_cur INTO
   x_job_definition_id;
  CLOSE jdef_cur;

  OPEN bgr_cur;
  FETCH bgr_cur INTO x_business_group, x_business_group_id;
  CLOSE bgr_cur;

  x_benchmark_job_name := x_job_name;
  x_benchmark_job_id := x_job_id;
  x_job_pk := x_job_id + x_instance;
  x_name := x_job_name + x_business_group + x_instance;
  x_job_dp := x_name;

  x_job_total :=    NVL(ceil(x_job_pk + 1), 0 )
                  + NVL(ceil(x_instance + 1), 0 )
                  + NVL(ceil(x_name + 1), 0 )
                  + NVL(ceil(x_job_dp + 1), 0 )
                  + NVL(ceil(x_business_group + 1), 0 )
                  + NVL(ceil(x_job_id + 1), 0 )
                  + NVL(ceil(x_business_group_id + 1), 0 )
                  + NVL(ceil(x_job_definition_id + 1), 0 )
                  + NVL(ceil(x_job_cat_set1 + 1), 0 )
                  + NVL(ceil(x_job_cat_set2 + 1), 0 )
                  + NVL(ceil(x_job_cat_set3 + 1), 0 )
                  + NVL(ceil(x_job_cat_set4 + 1), 0 )
                  + NVL(ceil(x_job_cat_set5 + 1), 0 )
                  + NVL(ceil(x_job_cat_set6 + 1), 0 )
                  + NVL(ceil(x_job_cat_set7 + 1), 0 )
                  + NVL(ceil(x_job_cat_set8 + 1), 0 )
                  + NVL(ceil(x_job_cat_set9 + 1), 0 )
                  + NVL(ceil(x_job_cat_set1 + 1), 0 )
                  + NVL(ceil(x_job_cat_set11 + 1), 0 )
                  + NVL(ceil(x_job_cat_set12 + 1), 0 )
                  + NVL(ceil(x_job_cat_set13 + 1), 0 )
                  + NVL(ceil(x_job_cat_set14 + 1), 0 )
                  + NVL(ceil(x_job_cat_set15 + 1), 0 )
                  + NVL(ceil(x_benchmark_job_name + 1), 0 )
                  + NVL(ceil(x_benchmark_job_id + 1), 0 )
                  + NVL(ceil(x_emp_rights_flag + 1), 0 )
                  + NVL(ceil(x_benchmark_job_flag + 1), 0 )
                  + NVL(ceil(x_creation_date + 1), 0 )
                  + NVL(ceil(x_last_update_date + 1), 0 );

  p_avg_row_length := x_job_total;

END estimate_row_length;

END edw_hr_jobs_m_sizing;

/
