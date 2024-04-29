--------------------------------------------------------
--  DDL for Package Body BIM_EDW_CMPSTATS_M_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_EDW_CMPSTATS_M_SIZE" AS
/* $Header: bimszcsb.pls 115.0 2001/03/14 12:01:51 pkm ship       $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NUMBER) IS


-- v_num_rows        NUMBER := 0;

CURSOR c_cnt_rows IS
   select sum(cnt)
   from (
        select count(*) cnt
	from
	ams_user_statuses_vl aus ,
	edw_local_instance inst
	WHERE aus.system_status_type = 'AMS_CAMPAIGN_STATUS' and
        aus.last_update_date between
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
 x_NAME NUMBER;
 x_USER_STATUS_ID NUMBER;
 x_SYSTEM_STATUS_CODE NUMBER;
 x_SYSTEM_STATUS_TYPE NUMBER;
 x_ENABLED_FLAG NUMBER;
 x_DEFAULT_FLAG NUMBER;
 x_SEEDED_FLAG NUMBER;
 x_START_DATE_ACTIVE NUMBER;
 x_END_DATE_ACTIVE NUMBER;
 x_DESCRIPTION NUMBER;
 x_CREATION_DATE NUMBER;
 x_LAST_UPDATE_DATE NUMBER;
 x_INSTANCE NUMBER;


  CURSOR c_1 IS
	SELECT
	 avg(nvl(vsize(NAME), 0)),
	 avg(nvl(vsize(USER_STATUS_ID), 0)),
	 avg(nvl(vsize(SYSTEM_STATUS_CODE), 0)),
	 avg(nvl(vsize(SYSTEM_STATUS_TYPE), 0)),
	 avg(nvl(vsize(ENABLED_FLAG), 0)),
	 avg(nvl(vsize(DEFAULT_FLAG), 0)),
	 avg(nvl(vsize(SEEDED_FLAG), 0)),
	 avg(nvl(vsize(START_DATE_ACTIVE), 0)),
	 avg(nvl(vsize(END_DATE_ACTIVE), 0)),
	 avg(nvl(vsize(DESCRIPTION), 0)),
	 avg(nvl(vsize(CREATION_DATE), 0)),
	 avg(nvl(vsize(LAST_UPDATE_DATE), 0))
	FROM ams_user_statuses_vl
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
	 x_NAME,
	 x_USER_STATUS_ID,
	 x_SYSTEM_STATUS_CODE,
	 x_SYSTEM_STATUS_TYPE,
	 x_ENABLED_FLAG,
	 x_DEFAULT_FLAG,
	 x_SEEDED_FLAG,
	 x_START_DATE_ACTIVE,
	 x_END_DATE_ACTIVE,
	 x_DESCRIPTION,
	 x_CREATION_DATE,
	 x_LAST_UPDATE_DATE;

    CLOSE c_1;

    x_total := 20  +
	 ceil(x_NAME + 1) +
	 ceil(x_USER_STATUS_ID + 1) +
	 ceil(x_SYSTEM_STATUS_CODE + 1) +
	 ceil(x_SYSTEM_STATUS_TYPE + 1) +
	 ceil(x_ENABLED_FLAG + 1) +
	 ceil(x_DEFAULT_FLAG + 1) +
	 ceil(x_SEEDED_FLAG + 1) +
	 ceil(x_START_DATE_ACTIVE + 1) +
	 ceil(x_END_DATE_ACTIVE + 1) +
	 ceil(x_DESCRIPTION + 1) +
	 ceil(x_CREATION_DATE + 1) +
	 ceil(x_LAST_UPDATE_DATE + 1);

    OPEN c_2;
      FETCH c_2 INTO  x_INSTANCE;
    CLOSE c_2;

    x_total := x_total + 3*ceil(x_INSTANCE + 1);

    x_total := x_total + 15*(x_constant + 1);

    -- dbms_output.put_line('     ');
    dbms_output.put_line('The average row length is : ' || to_char(x_total));

  p_avg_row_len := x_total;

  END;  -- procedure est_row_len.

END;  -- package body BIM_EDW_CMPSTATS_M_SIZE

/
