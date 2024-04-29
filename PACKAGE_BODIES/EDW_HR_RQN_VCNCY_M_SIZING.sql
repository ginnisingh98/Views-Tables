--------------------------------------------------------
--  DDL for Package Body EDW_HR_RQN_VCNCY_M_SIZING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_HR_RQN_VCNCY_M_SIZING" AS
/* $Header: hriezvac.pkb 120.1 2005/06/08 02:50:53 anmajumd noship $ */
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
  SELECT count(vacancy_id) total
  FROM per_all_vacancies
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

  x_date                NUMBER :=7;

  x_total_req           NUMBER;
  x_total_vac           NUMBER;

/* Requisition Level */
  x_requisition_pk      NUMBER:=0;
  x_instance            NUMBER:=0;
  x_rqn_name            NUMBER:=0;
  x_requisition_dp      NUMBER:=0;
  x_business_group_id   NUMBER:=0;
  x_business_group      NUMBER:=0;
  x_requisition_id      NUMBER:=0;
  x_start_date          NUMBER:= x_date;
  x_end_date            NUMBER:= x_date;
  x_creation_date       NUMBER:= x_date;
  x_last_update_date    NUMBER:= x_date;

/* Vacancy Level */
x_vacancy_pk               NUMBER:=0;
x_requisition_fk           NUMBER:=0;
x_vacancy_status_code      NUMBER:=0;
x_vacancy_status           NUMBER:=0;
x_number_of_openings       NUMBER:=0;
x_budget_msrmnt_type_code  NUMBER:=0;
x_budget_msrmnt_type       NUMBER:=0;
x_budget_msrmnt_value      NUMBER:=0;
x_vacancy_dp               NUMBER:=0;
x_vac_name                 NUMBER:=0;
x_vacancy_id               NUMBER:=0;
x_vacancy_start_date       NUMBER:= x_date;
x_vacancy_end_date         NUMBER:= x_date;

/* Selects the length of the instance code */
  CURSOR inst_cur IS
  SELECT avg(nvl(vsize(instance_code),0))
  FROM edw_local_instance
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

  CURSOR req_cur IS
  SELECT avg(nvl(vsize(name),0))
  ,avg(nvl(vsize(business_group_id),0))
  ,avg(nvl(vsize(requisition_id),0))
  FROM per_requisitions
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;


  CURSOR bus_cur IS
  SELECT avg(nvl(vsize(name),0))
  FROM hr_all_organization_units
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

  CURSOR vcs_cur IS
  SELECT
   avg(nvl(vsize(vacancy_id),0))
  ,avg(nvl(vsize(status),0))
  ,avg(nvl(vsize(name),0))
  ,avg(nvl(vsize(number_of_openings),0))
  ,avg(nvl(vsize(budget_measurement_type),0))
  ,avg(nvl(vsize(budget_measurement_value),0))
  ,avg(nvl(vsize(business_group_id),0))
  ,avg(nvl(vsize(requisition_id),0))
  ,avg(nvl(vsize(vacancy_id),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('BUDGET_MEASUREMENT_TYPE',budget_measurement_type)),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('VACANCY_STATUS',status)),0))
  FROM per_all_vacancies
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

BEGIN
/* Selects the length of the instance code */
  OPEN inst_cur;
  FETCH inst_cur INTO x_instance;
  CLOSE inst_cur;

  OPEN req_cur;
  FETCH req_cur INTO
   x_rqn_name
  ,x_business_group_id
  ,x_requisition_id;
  CLOSE req_cur;

  OPEN bus_cur;
  FETCH bus_cur INTO x_business_group;
  CLOSE bus_cur;

  OPEN vcs_cur;
  FETCH vcs_cur INTO
   x_vacancy_id
  ,x_vacancy_status_code
  ,x_vac_name
  ,x_number_of_openings
  ,x_budget_msrmnt_type_code
  ,x_budget_msrmnt_value
  ,x_business_group_id
  ,x_requisition_id
  ,x_vacancy_id
  ,x_budget_msrmnt_type
  ,x_vacancy_status;
CLOSE vcs_cur;

 /* Requisition Level */

  x_requisition_pk := x_requisition_id + x_instance;
  x_rqn_name := x_rqn_name + x_business_group;
  x_requisition_dp := x_rqn_name;

  x_total_req :=   NVL (ceil(x_requisition_pk + 1), 0)
                 + NVL (ceil(x_instance  + 1), 0)
                 + NVL (ceil(x_rqn_name  + 1), 0)
                 + NVL (ceil(x_requisition_dp  + 1), 0)
                 + NVL (ceil( x_business_group_id  + 1), 0)
                 + NVL (ceil(x_requisition_id  + 1), 0)
                 + NVL (ceil(x_start_date  + 1), 0)
                 + NVL (ceil( x_end_date  + 1), 0)
                 + NVL (ceil( x_creation_date  + 1), 0)
                 + NVL (ceil(x_last_update_date  + 1), 0);


 /* Vacancy Level */

  x_vacancy_pk := x_requisition_pk + x_vacancy_id + x_instance;
  x_requisition_pk := x_requisition_fk;
  x_vac_name := x_vac_name + x_business_group;
  x_requisition_dp := x_vac_name;

  x_total_vac :=  NVL (ceil(x_vacancy_pk  + 1), 0)
              + NVL (ceil(x_requisition_fk  + 1), 0)
              + NVL (ceil(x_instance  + 1), 0)
              + NVL (ceil(x_vacancy_status_code  + 1), 0)
              + NVL (ceil(x_vacancy_status  + 1), 0)
              + NVL (ceil(x_number_of_openings  + 1), 0)
              + NVL (ceil(x_budget_msrmnt_type_code + 1), 0)
              + NVL (ceil(x_budget_msrmnt_type  + 1), 0)
              + NVL (ceil(x_budget_msrmnt_value  + 1), 0)
              + NVL (ceil(x_vac_name  + 1), 0)
              + NVL (ceil(x_vacancy_dp  + 1), 0)
              + NVL (ceil(x_business_group_id  + 1), 0)
              + NVL (ceil(x_requisition_id  + 1), 0)
              + NVL (ceil(x_vacancy_id  + 1), 0)
              + NVL (ceil(x_vacancy_start_date  + 1), 0)
              + NVL (ceil(x_vacancy_end_date  + 1), 0) ;

  p_avg_row_length := x_total_req + x_total_vac;


END estimate_row_length;

END edw_hr_rqn_vcncy_m_sizing;

/
