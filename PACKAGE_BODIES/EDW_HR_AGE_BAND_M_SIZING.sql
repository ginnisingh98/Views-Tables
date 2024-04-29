--------------------------------------------------------
--  DDL for Package Body EDW_HR_AGE_BAND_M_SIZING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_HR_AGE_BAND_M_SIZING" AS
/* $Header: hriezagb.pkb 120.1 2005/06/08 02:44:36 anmajumd noship $ */
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
  SELECT count(bnds.band_min_total_months) total
  FROM hri_age_bands bnds
  WHERE NVL(bnds.last_update_date, to_date('01-01-2000','DD-MM-YYYY'))
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

  x_date		NUMBER :=7;

  x_total_age_band	NUMBER;

/* Age Band Level */
  x_age_band_pk		NUMBER :=0;
  x_instance		NUMBER :=0;
  x_name		NUMBER :=0;
  x_age_band_dp		NUMBER :=0;
  x_age_max		NUMBER :=0;
  x_age_min		NUMBER :=0;
  x_last_update_date	NUMBER := x_date;
  x_creation_date	NUMBER := x_date;

/* Select the length of the instance code */
  CURSOR inst_cur IS
  SELECT avg(nvl( vsize(instance_code),0 ))
  FROM edw_local_instance;


  CURSOR age_cur IS
  SELECT
   avg(nvl(vsize(band_min_total_months),0))
  ,avg(nvl(vsize(band_max_total_months),0))
  FROM hri_age_bands
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

BEGIN

  OPEN inst_cur;
  FETCH inst_cur INTO x_instance;
  CLOSE inst_cur;

  OPEN age_cur;
  FETCH age_cur INTO x_age_min, x_age_max;
  CLOSE age_cur;

/* Age Band Level */

  x_age_band_pk := x_age_max + x_age_min + x_instance;
  x_name := x_age_max + x_age_min;
  x_age_band_dp := x_age_max + x_age_min;

  x_total_age_band :=  NVL(ceil(x_age_band_pk + 1), 0)
		     + NVL(ceil(x_instance + 1), 0)
		     + NVL(ceil(x_name + 1), 0)
		     + NVL(ceil(x_age_band_dp + 1), 0)
		     + NVL(ceil(x_age_max + 1), 0)
		     + NVL(ceil(x_age_min + 1), 0)
		     + NVL(ceil(x_last_update_date + 1), 0)
 	 	     + NVL(ceil(x_creation_date + 1), 0);

/* TOTAL */

  p_avg_row_length :=  x_total_age_band;

END estimate_row_length;

END edw_hr_age_band_m_sizing;

/
