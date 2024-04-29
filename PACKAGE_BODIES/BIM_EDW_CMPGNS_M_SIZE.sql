--------------------------------------------------------
--  DDL for Package Body BIM_EDW_CMPGNS_M_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_EDW_CMPGNS_M_SIZE" AS
/* $Header: bimszcpb.pls 115.0 2001/03/14 12:01:43 pkm ship       $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NUMBER) IS


 -- v_num_rows        NUMBER := 0;

CURSOR c_cnt_rows IS
   select sum(cnt)
   from (
        select count(*) cnt
	FROM AMS_CAMPAIGN_SCHEDULES AMS ,
	 AMS_CAMPAIGNS_VL AMC ,
	 EDW_LOCAL_INSTANCE INST
	WHERE AMS.CAMPAIGN_ID = AMC.CAMPAIGN_ID
	and
	AMS.last_update_date between
        p_from_date  and  p_to_date
        );


BEGIN

  dbms_output.enable(1000000);

  OPEN c_cnt_rows;
       FETCH c_cnt_rows INTO p_num_rows;
  CLOSE c_cnt_rows;


    dbms_output.put_line('The number of rows is: ' || to_char(p_num_rows));
END;  -- procedure cnt_rows.


PROCEDURE est_row_len(p_from_date DATE,
                      p_to_date DATE,
                      p_avg_row_len OUT NUMBER) IS

 x_date                 number := 7;
 x_total                number := 0;
 x_constant             number := 6;
 x_CAMPAIGN_SCHEDULE_ID NUMBER;
 x_CAMPAIGN_ID1 NUMBER;
 x_CAMPAIGN_ID2 NUMBER;
 x_SOURCE_CODE NUMBER;
 x_FREQUENCY NUMBER;
 x_FREQUENCY_UOM_CODE NUMBER;
 x_DELIVERABLE_ID NUMBER;
 x_ACTIVITY_OFFER_ID NUMBER;
 x_FORECASTED_START_DATE_TIME NUMBER;
 x_FORECASTED_END_DATE_TIME NUMBER;
 x_ACTUAL_START_DATE_TIME NUMBER;
 x_ACTUAL_END_DATE_TIME NUMBER;
 x_CREATION_DATE NUMBER;
 x_LAST_UPDATE_DATE  NUMBER;
 x_INSTANCE NUMBER;


  CURSOR c_1 IS
	SELECT
	avg(nvl(vsize( CAMPAIGN_SCHEDULE_ID ), 0)),
	avg(nvl(vsize( CAMPAIGN_ID), 0)),
	avg(nvl(vsize( SOURCE_CODE), 0)),
	avg(nvl(vsize( FREQUENCY), 0)),
	avg(nvl(vsize( FREQUENCY_UOM_CODE), 0)),
	avg(nvl(vsize( DELIVERABLE_ID), 0)),
	avg(nvl(vsize( ACTIVITY_OFFER_ID), 0)),
	avg(nvl(vsize( FORECASTED_START_DATE_TIME), 0)),
	avg(nvl(vsize( FORECASTED_END_DATE_TIME), 0)),
	avg(nvl(vsize( ACTUAL_START_DATE_TIME), 0)),
	avg(nvl(vsize( ACTUAL_END_DATE_TIME), 0)),
	avg(nvl(vsize( CREATION_DATE), 0)),
	avg(nvl(vsize( LAST_UPDATE_DATE ), 0))
	FROM AMS_CAMPAIGN_SCHEDULES
        where last_update_date between
        p_from_date  and  p_to_date;



  CURSOR c_2 IS
	select
	 avg(nvl(vsize(campaign_id), 0))
	 from AMS_CAMPAIGNS_VL  ;


  CURSOR c_3 IS
	select
	 avg(nvl(vsize(INSTANCE_CODE), 0))
	 from EDW_LOCAL_INSTANCE ;



  BEGIN

    dbms_output.enable(1000000);

    OPEN c_1;
      FETCH c_1 INTO
	 x_CAMPAIGN_SCHEDULE_ID,
	 x_CAMPAIGN_ID1,
	 x_SOURCE_CODE,
	 x_FREQUENCY,
	 x_FREQUENCY_UOM_CODE,
	 x_DELIVERABLE_ID,
	 x_ACTIVITY_OFFER_ID,
	 x_FORECASTED_START_DATE_TIME,
	 x_FORECASTED_END_DATE_TIME,
	 x_ACTUAL_START_DATE_TIME,
	 x_ACTUAL_END_DATE_TIME,
	 x_CREATION_DATE,
	 x_LAST_UPDATE_DATE;

    CLOSE c_1;

    x_total := 35  +
		ceil(	 x_CAMPAIGN_SCHEDULE_ID +1) +
		ceil(	 x_CAMPAIGN_ID1 +1) +
		ceil(	 x_SOURCE_CODE +1) +
		ceil(	 x_FREQUENCY +1) +
		ceil(	 x_FREQUENCY_UOM_CODE +1) +
		ceil(	 x_DELIVERABLE_ID +1) +
		ceil(	 x_ACTIVITY_OFFER_ID +1) +
		ceil(	 x_FORECASTED_START_DATE_TIME +1) +
		ceil(	 x_FORECASTED_END_DATE_TIME +1) +
		ceil(	 x_ACTUAL_START_DATE_TIME +1) +
		ceil(	 x_ACTUAL_END_DATE_TIME +1) +
		ceil(	 x_CREATION_DATE +1) +
		ceil(	 x_LAST_UPDATE_DATE +1);





    OPEN c_2;
      FETCH c_2 INTO  x_CAMPAIGN_ID2;
    CLOSE c_2;
    x_total := x_total + ceil(x_CAMPAIGN_ID2 + 1);

    OPEN c_3;
      FETCH c_3 INTO  x_INSTANCE;
    CLOSE c_3;

    x_total := x_total + 3*ceil(x_INSTANCE + 1);

    x_total := 10*x_total + 15*(x_constant + 1);

    -- dbms_output.put_line('     ');
    dbms_output.put_line('The average row length is : ' || to_char(x_total));

  p_avg_row_len := x_total;

  END;  -- procedure est_row_len.

END;  -- package body BIM_EDW_CMPGNS_M_SIZE

/
