--------------------------------------------------------
--  DDL for Package Body EDW_HR_REASON_M_SIZING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_HR_REASON_M_SIZING" AS
/* $Header: hriezrsn.pkb 120.1 2005/06/08 02:50:11 anmajumd noship $ */
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
  SELECT count(hrl.meaning) total
  FROM hr_lookups          hrl
  ,(select evt.reason_type from hri_edw_event_hrchys evt
  where not exists (select 1 from hri_edw_event_hrchys dummy
                    where dummy.rowid > evt.rowid
                    and evt.reason_type = dummy.reason_type)) types
  WHERE NVL(hrl.last_update_date, to_date('01-01-2000','DD-MM-YYYY'))
  BETWEEN p_from_date AND p_to_date
  AND hrl.lookup_type = types.reason_type;



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

  x_total_reason        NUMBER;

/* Reason Level */
  x_reason_pk           NUMBER :=0;
  x_instance            NUMBER :=0;
  x_name                NUMBER :=0;
  x_reason_dp           NUMBER :=0;
  x_lookup_type         NUMBER :=0;
  x_lookup_code         NUMBER :=0;
  x_last_update_date    NUMBER:= x_date;
  x_creation_date       NUMBER:= x_date;

/* Select the length of the instance code */
  CURSOR inst_cur IS
  SELECT avg(nvl( vsize(instance_code),0 ))
  FROM edw_local_instance;


 CURSOR rsn_cur IS
  SELECT
   avg(nvl(vsize(hrl.meaning),0))
  ,avg(nvl(vsize(hrl.meaning),0))
  ,avg(nvl(vsize(hrl.lookup_type),0))
  ,avg(nvl(vsize(hrl.lookup_code),0))
FROM hr_lookups          hrl
  ,(select evt.reason_type from hri_edw_event_hrchys evt
  where not exists (select 1 from hri_edw_event_hrchys dummy
                    where dummy.rowid > evt.rowid
                    and evt.reason_type = dummy.reason_type)) types
  WHERE NVL(hrl.last_update_date, to_date('01-01-2000','DD-MM-YYYY'))
  BETWEEN p_from_date AND p_to_date
  AND hrl.lookup_type = types.reason_type;

BEGIN

  OPEN inst_cur;
  FETCH inst_cur INTO x_instance;
  CLOSE inst_cur;

  OPEN rsn_cur;
  FETCH rsn_cur INTO
   x_name
  ,x_reason_dp
  ,x_lookup_type
  ,x_lookup_code;
  CLOSE rsn_cur;

/* Reason Level */

  x_reason_pk := x_lookup_type + x_lookup_code + x_instance;


  x_total_reason :=  NVL(ceil(x_reason_pk + 1), 0)
		     + NVL(ceil(x_instance + 1), 0)
		     + NVL(ceil(x_name + 1), 0)
		     + NVL(ceil(x_reason_dp + 1), 0)
		     + NVL(ceil(x_lookup_type + 1), 0)
		     + NVL(ceil(x_lookup_code + 1), 0)
		     + NVL(ceil(x_last_update_date + 1), 0)
 	 	     + NVL(ceil(x_creation_date + 1), 0);

/* TOTAL */

  p_avg_row_length :=  x_total_reason;

END estimate_row_length;

END edw_hr_reason_m_sizing;

/
