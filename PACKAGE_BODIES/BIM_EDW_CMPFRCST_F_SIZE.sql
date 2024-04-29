--------------------------------------------------------
--  DDL for Package Body BIM_EDW_CMPFRCST_F_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_EDW_CMPFRCST_F_SIZE" AS
/* $Header: bimszfcb.pls 115.0 2001/03/14 12:02:05 pkm ship       $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NUMBER) IS


 -- v_num_rows        NUMBER := 0;
last_date DATE := TO_DATE( '1000/01/01','YYYY/MM/DD' );

CURSOR c_cnt_rows IS
   select sum(cnt)
   from (
        select count(*) cnt
	FROM AMS_CAMPAIGNS_ALL_B AMC ,
	 AMS_ACT_METRICS_ALL AAM ,
	 AMS_METRICS_ALL_B AMT ,
	 BIM_EDW_CMPFRCST_INC INC ,
	 EDW_LOCAL_INSTANCE INST
	WHERE AMC.CAMPAIGN_ID = AAM.ACT_METRIC_USED_BY_ID
	 AND AAM.ARC_ACT_METRIC_USED_BY = 'CAMP'
	 AND AAM.METRIC_ID = AMT.METRIC_ID
	 AND AMT.SUMMARY_METRIC_ID IS NULL AND AMT.METRIC_CATEGORY = 901
	 AND AMC.STATUS_CODE NOT IN ( 'NEW',
	 'PLANNING' ) AND AMC.SHOW_CAMPAIGN_FLAG = 'Y'
	 AND AMC.CAMPAIGN_ID = INC.PRIMARY_KEY
	 AND  ( AMC.LAST_UPDATE_DATE > last_date
	 OR  AAM.LAST_UPDATE_DATE > last_date
	 )  and
	AMC.last_update_date between
        p_from_date  and  p_to_date
	UNION ALL
	select count(*) cnt
	FROM AMS_CAMPAIGNS_ALL_B AMC ,
	 AMS_ACT_METRICS_ALL AAM ,
	 AMS_METRICS_ALL_B AMT ,
	 BIM_EDW_CMPFRCST_INC INC ,
	 EDW_LOCAL_INSTANCE INST
	WHERE AMC.CAMPAIGN_ID = AAM.ACT_METRIC_USED_BY_ID
	 AND AAM.ARC_ACT_METRIC_USED_BY = 'CAMP'
	 AND AAM.METRIC_ID = AMT.METRIC_ID AND AMT.SUMMARY_METRIC_ID IS NULL
	 AND AMT.METRIC_CATEGORY = 902 AND AMC.STATUS_CODE NOT IN ( 'NEW',
	 'PLANNING' )
	 AND AMC.SHOW_CAMPAIGN_FLAG = 'Y' AND AMC.CAMPAIGN_ID = INC.PRIMARY_KEY
	 AND (  AMC.LAST_UPDATE_DATE > last_date
	 OR  AAM.LAST_UPDATE_DATE > last_date )
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
 x_CAMPAIGN_ID NUMBER;
 x_CHANNEL_ID NUMBER;
 x_TRANSACTION_CURRENCY_CODE NUMBER;
 x_ORG_ID NUMBER;

 x_INSTANCE NUMBER;


  CURSOR c_1 IS
	SELECT
	avg(nvl(vsize( CAMPAIGN_ID), 0)),
	avg(nvl(vsize( CHANNEL_ID), 0)),
	avg(nvl(vsize( TRANSACTION_CURRENCY_CODE), 0)),
	avg(nvl(vsize( ORG_ID), 0))
	FROM AMS_CAMPAIGNS_ALL_B
        where last_update_date between
        p_from_date  and  p_to_date;




  CURSOR c_2 IS
	select
	 avg(nvl(vsize(INSTANCE_CODE), 0))
	 from EDW_LOCAL_INSTANCE ;



  BEGIN

    dbms_output.enable(1000000);

    OPEN c_1;
      FETCH c_1 INTO
	 x_CAMPAIGN_ID,
	 x_CHANNEL_ID,
	 x_TRANSACTION_CURRENCY_CODE,
	 x_ORG_ID;


    CLOSE c_1;

    x_total := 150  +
		ceil(	 x_CAMPAIGN_ID +1) +
		ceil(	 x_CHANNEL_ID +1) +
		ceil(	 x_TRANSACTION_CURRENCY_CODE +1) +
		ceil(	 x_ORG_ID +1);





    OPEN c_2;
      FETCH c_2 INTO  x_INSTANCE;
    CLOSE c_2;

    x_total := x_total + 8*ceil(x_INSTANCE + 1);

    x_total := x_total + 20*(x_constant + 1);

    -- dbms_output.put_line('     ');
    dbms_output.put_line('The average row length is : ' || to_char(x_total));

  p_avg_row_len := x_total;

  END;  -- procedure est_row_len.

END;  -- package body BIM_EDW_CMPFRCST_F_SIZE

/
