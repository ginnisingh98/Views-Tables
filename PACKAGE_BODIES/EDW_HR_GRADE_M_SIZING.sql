--------------------------------------------------------
--  DDL for Package Body EDW_HR_GRADE_M_SIZING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_HR_GRADE_M_SIZING" AS
/* $Header: hriezgrd.pkb 120.1 2005/06/08 02:45:28 anmajumd noship $ */
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
  SELECT count(gra.grade_id) total
  FROM per_grades gra
  WHERE NVL(gra.last_update_date, to_date('01-01-2000','DD-MM-YYYY'))
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

  x_date                NUMBER :=7;

  x_total_grade		NUMBER;

/* Grade Level */
  x_grade_pk		NUMBER :=0;
  x_instance		NUMBER :=0;
  x_name		NUMBER :=0;
  x_grade_dp		NUMBER :=0;
  x_grade_date_from	NUMBER :=x_date;
  x_grade_date_to 	NUMBER :=x_date;
  x_grade_sequence 	NUMBER :=0;
  x_business_group 	NUMBER :=0;
  x_grade_id		NUMBER :=0;
  x_business_group_id	NUMBER :=0;
  x_grade_definition_id NUMBER :=0;
  x_last_update_date	NUMBER := x_date;
  x_creation_date	NUMBER := x_date;

  l_grade_name	        NUMBER :=0;

/* Select the length of the instance code */
  CURSOR inst_cur IS
  SELECT avg(nvl( vsize(instance_code),0 ))
  FROM edw_local_instance;

  CURSOR grade_cur IS
  SELECT
   avg(nvl(vsize(sequence),0))
  ,avg(nvl(vsize(name),0))
  ,avg(nvl(vsize(grade_id),0))
  ,avg(nvl(vsize(business_group_id),0))
  FROM per_grades
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

  CURSOR bus_cur IS
  SELECT
  avg(nvl(vsize(name),0))
  FROM hr_all_organization_units
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

  CURSOR gra_def_cur IS
  SELECT
  avg(nvl(vsize(grade_definition_id),0))
  FROM per_grade_definitions
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

BEGIN

  OPEN inst_cur;
  FETCH inst_cur INTO x_instance;
  CLOSE inst_cur;

  OPEN grade_cur;
  FETCH grade_cur INTO x_grade_sequence, l_grade_name, x_grade_id, x_business_group_id;
  CLOSE grade_cur;

  OPEN bus_cur;
  FETCH bus_cur INTO x_business_group;
  CLOSE bus_cur;

  OPEN gra_def_cur;
  FETCH gra_def_cur INTO x_grade_definition_id;
  CLOSE gra_def_cur;

/* Grade Level */

  x_grade_pk := x_grade_id + x_instance;
  x_name     := l_grade_name + x_instance;
  x_grade_dp := x_name;

  x_total_grade :=  	   NVL(ceil(x_grade_pk + 1), 0 )
 	        	 + NVL(ceil(x_instance  + 1), 0 )
			 + NVL(ceil(x_name  + 1), 0 )
			 + NVL(ceil(x_grade_dp  + 1), 0 )
			 + NVL(ceil(x_grade_date_from  + 1), 0 )
			 + NVL(ceil(x_grade_date_to  + 1), 0 )
			 + NVL(ceil(x_grade_sequence  + 1), 0 )
 			 + NVL(ceil(x_business_group  + 1), 0 )
 			 + NVL(ceil(x_grade_id  + 1), 0 )
 		 	 + NVL(ceil(x_business_group_id  + 1), 0 )
			 + NVL(ceil(x_grade_definition_id  + 1), 0 )
 		         + NVL(ceil(x_last_update_date  + 1), 0 )
			 + NVL(ceil(x_creation_date  + 1), 0 );

/* TOTAL */

  p_avg_row_length := x_total_grade;

END estimate_row_length;

END edw_hr_grade_m_sizing;

/
