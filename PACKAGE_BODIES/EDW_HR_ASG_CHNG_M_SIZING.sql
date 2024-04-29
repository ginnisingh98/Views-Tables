--------------------------------------------------------
--  DDL for Package Body EDW_HR_ASG_CHNG_M_SIZING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_HR_ASG_CHNG_M_SIZING" AS
/* $Header: hriezacg.pkb 120.1 2005/06/08 02:44:02 anmajumd noship $ */
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
  (SELECT hr_general.decode_lookup('YES_NO', lookup_code) lookup
         ,lookup_code
         ,last_update_date
         ,creation_date
   FROM   hr_lookups
   WHERE lookup_type = 'YES_NO') t1
 ,(SELECT hr_general.decode_lookup('YES_NO', lookup_code) lookup
         ,lookup_code
   FROM   hr_lookups
   WHERE lookup_type = 'YES_NO') t2
 ,(SELECT hr_general.decode_lookup('YES_NO', lookup_code) lookup
         ,lookup_code
   FROM   hr_lookups
   WHERE lookup_type = 'YES_NO') t3
 ,(SELECT hr_general.decode_lookup('YES_NO', lookup_code) lookup
         ,lookup_code
   FROM   hr_lookups
   WHERE lookup_type = 'YES_NO') t4
 ,(SELECT hr_general.decode_lookup('YES_NO', lookup_code) lookup
         ,lookup_code
   FROM   hr_lookups
   WHERE lookup_type = 'YES_NO') t5
 ,(SELECT hr_general.decode_lookup('YES_NO', lookup_code) lookup
         ,lookup_code
   FROM   hr_lookups
   WHERE lookup_type = 'YES_NO') t6
 ,(SELECT hr_general.decode_lookup('YES_NO', lookup_code) lookup
         ,lookup_code
   FROM   hr_lookups
   WHERE lookup_type = 'YES_NO') t7;

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

  x_date                NUMBER :=7;

  x_total_asg_chng      NUMBER;

/* Assignment Change Level */
  x_asg_chng_pk	        NUMBER :=0;
  x_instance            NUMBER :=0;
  x_name                NUMBER :=0;
  x_asg_chng_dp         NUMBER :=0;
  x_flag                NUMBER :=0;
  x_yes                 NUMBER :=0;
  x_no                  NUMBER :=0;
  x_creation_date       NUMBER := x_date;
  x_last_update_date    NUMBER := x_date;

/* Select the length of the instance code */
  CURSOR inst_cur IS
  SELECT avg(nvl( vsize(instance_code),0 ))
  FROM edw_local_instance;


  CURSOR flag_cur IS
  SELECT
   avg(nvl(vsize(hr_general.decode_lookup('YES_NO','Y')),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('YES_NO','N')),0))
  FROM dual;

BEGIN

  OPEN inst_cur;
  FETCH inst_cur INTO x_instance;
  CLOSE inst_cur;

  OPEN flag_cur;
  FETCH flag_cur INTO x_yes, x_no;
  CLOSE flag_cur;

  x_flag := (x_yes + x_no) / 2;

/* Assignment Change Level */

  x_asg_chng_pk := x_instance;
  x_name := x_instance;
  x_asg_chng_dp := x_name;

  x_total_asg_chng :=  NVL(ceil(x_asg_chng_pk + 1), 0)
		     + NVL(ceil(x_instance + 1), 0)
		     + NVL(ceil(x_name + 1), 0)
		     + NVL(ceil(x_asg_chng_dp + 1), 0)
                     + (7 * NVL(ceil(x_flag + 1), 0))
		     + NVL(ceil(x_last_update_date + 1), 0)
 	 	     + NVL(ceil(x_creation_date + 1), 0);

/* TOTAL */

  p_avg_row_length :=  x_total_asg_chng;

END estimate_row_length;

END edw_hr_asg_chng_m_sizing;

/
