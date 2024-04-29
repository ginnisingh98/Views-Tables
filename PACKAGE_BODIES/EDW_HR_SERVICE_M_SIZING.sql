--------------------------------------------------------
--  DDL for Package Body EDW_HR_SERVICE_M_SIZING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_HR_SERVICE_M_SIZING" AS
/* $Header: hriezlwb.pkb 120.1 2005/06/08 02:46:39 anmajumd noship $ */
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
  FROM hri_service_bands bnds
  WHERE NVL(last_update_date, to_date('01-01-2000','DD-MM-YYYY'))
  BETWEEN p_from_date AND p_to_date
  AND bnds.days_to_month IS NULL;


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

  x_total_service       NUMBER;

  x_service_band_pk             NUMBER:=0;
  x_instance                    NUMBER:=0;
  x_name                        NUMBER:=0;
  x_service_band_dp             NUMBER:=0;
  x_service_length_max_year     NUMBER:=0;
  x_service_length_max_month    NUMBER:=0;
  x_service_length_max_week     NUMBER:=0;
  x_service_length_max_day      NUMBER:=0;
  x_service_length_min_year     NUMBER:=0;
  x_service_length_min_month    NUMBER:=0;
  x_service_length_min_week     NUMBER:=0;
  x_service_length_min_day      NUMBER:=0;
  x_last_update_date            NUMBER:=x_date;
  x_creation_date               NUMBER:=x_date;

/* Select the length of the instance code */
  CURSOR inst_cur IS
  SELECT avg(nvl( vsize(instance_code),0 ))
  FROM edw_local_instance;

  CURSOR bnd_cur IS
  SELECT
   avg(nvl(vsize(bnds.band_max_total_years),0))
  ,avg(nvl(vsize(bnds.band_max_total_months),0))
  ,avg(nvl(vsize(bnds.band_max_total_weeks),0))
  ,avg(nvl(vsize(bnds.band_max_total_days),0))
  ,avg(nvl(vsize(bnds.band_min_total_years),0))
  ,avg(nvl(vsize(bnds.band_min_total_months),0))
  ,avg(nvl(vsize(bnds.band_min_total_weeks),0))
  ,avg(nvl(vsize(bnds.band_min_total_days),0))
  FROM
  hri_service_bands bnds
  WHERE bnds.last_update_date BETWEEN p_from_date AND p_to_date;

BEGIN

  OPEN inst_cur;
  FETCH inst_cur INTO x_instance;
 CLOSE inst_cur;

  OPEN bnd_cur;
  FETCH bnd_cur INTO
    x_service_length_max_year
   ,x_service_length_max_month
   ,x_service_length_max_week
   ,x_service_length_max_day
   ,x_service_length_min_year
   ,x_service_length_min_month
   ,x_service_length_min_week
   ,x_service_length_min_day;
 CLOSE bnd_cur;

x_name :=   x_service_length_max_year
          + x_service_length_max_month
          + x_service_length_max_week
          + x_service_length_max_day
          + x_service_length_min_year
          + x_service_length_min_month
          + x_service_length_min_week
          + x_service_length_min_day;

x_service_band_dp := x_name;
x_service_band_pk := x_name + x_instance;

x_total_service :=  NVL(ceil(x_service_band_pk + 1), 0)
+ NVL(ceil(x_instance + 1), 0)
+ NVL(ceil(x_name + 1), 0)
+ NVL(ceil(x_service_band_dp + 1), 0)
+ NVL(ceil(x_service_length_max_year + 1), 0)
+ NVL(ceil(x_service_length_max_month + 1), 0)
+ NVL(ceil(x_service_length_max_week + 1), 0)
+ NVL(ceil(x_service_length_max_day + 1), 0)
+ NVL(ceil(x_service_length_min_year + 1), 0)
+ NVL(ceil(x_service_length_min_month + 1), 0)
+ NVL(ceil(x_service_length_min_week + 1), 0)
+ NVL(ceil(x_service_length_min_day + 1), 0)
+ NVL(ceil(x_last_update_date + 1), 0)
+ NVL(ceil(x_creation_date + 1), 0);

/* TOTAL */

  p_avg_row_length :=  x_total_service;

END estimate_row_length;

END edw_hr_service_m_sizing;

/
