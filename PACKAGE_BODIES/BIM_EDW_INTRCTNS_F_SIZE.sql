--------------------------------------------------------
--  DDL for Package Body BIM_EDW_INTRCTNS_F_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_EDW_INTRCTNS_F_SIZE" AS
/* $Header: bimszfib.pls 115.0 2001/03/14 12:02:18 pkm ship       $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NUMBER) IS


 -- v_num_rows        NUMBER := 0;

CURSOR c_cnt_rows IS
   select sum(cnt)
   from (
        select count(*) cnt
	FROM JTF_IH_ACTIVITIES JIA,
	 JTF_IH_INTERACTIONS JII,
	 HZ_PARTY_SITES HPS,
	 EDW_BIM_SOURCE_CODE_DETAILS BSCD,
	 BIM_EDW_INTRCTNS_INC INC,
	 EDW_LOCAL_INSTANCE INST
        WHERE JIA.INTERACTION_ID = JII.INTERACTION_ID
         AND JII.PARTY_ID = HPS.PARTY_ID (+)
	 AND HPS.IDENTIFYING_ADDRESS_FLAG(+) = 'Y'
         AND JIA.ACTIVITY_ID = INC.PRIMARY_KEY
	 AND NVL(JIA.SOURCE_CODE_ID, -999) = BSCD.SOURCE_CODE_ID
	 and
	 JIA.last_update_date between
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
 x_ACTIVITY_ID NUMBER;
 x_INTERACTION_ID NUMBER;
 x_DURATION NUMBER;
 x_SOURCE_CODE NUMBER;

 x_CAMPAIGN_FK NUMBER;
 x_EVENT_FK NUMBER;
 x_MEDIA_CHANNEL_FK NUMBER;
 x_OFFER_FK NUMBER;

 x_INSTANCE NUMBER;


  CURSOR c_1 IS
	SELECT
	avg(nvl(vsize( ACTIVITY_ID ), 0)),
	avg(nvl(vsize( INTERACTION_ID), 0)),
	avg(nvl(vsize( DURATION), 0)),
	avg(nvl(vsize( SOURCE_CODE), 0))
	FROM JTF_IH_ACTIVITIES
        where last_update_date between
        p_from_date  and  p_to_date;



  CURSOR c_2 IS
	select
	 avg(nvl(vsize(CAMPAIGN_FK), 0)),
	 avg(nvl(vsize(EVENT_FK), 0)),
	 avg(nvl(vsize(MEDIA_CHANNEL_FK), 0)),
	 avg(nvl(vsize(OFFER_FK), 0))
	 from EDW_BIM_SOURCE_CODE_DETAILS  ;


  CURSOR c_3 IS
	select
	 avg(nvl(vsize(INSTANCE_CODE), 0))
	 from EDW_LOCAL_INSTANCE ;



  BEGIN

    dbms_output.enable(1000000);

    OPEN c_1;
      FETCH c_1 INTO
	 x_ACTIVITY_ID,
	 x_INTERACTION_ID,
	 x_DURATION,
	 x_SOURCE_CODE;

    CLOSE c_1;

    x_total := 160  +
		ceil(	 x_ACTIVITY_ID +1) +
		ceil(	 x_INTERACTION_ID +1) +
		ceil(	 x_DURATION +1) +
		ceil(	 x_SOURCE_CODE +1) ;




    OPEN c_2;
      FETCH c_2 INTO
	 x_CAMPAIGN_FK,
	 x_EVENT_FK,
	 x_MEDIA_CHANNEL_FK,
	 x_OFFER_FK;
    CLOSE c_2;
    x_total := x_total +
	ceil(x_CAMPAIGN_FK + 1) +
	ceil(x_EVENT_FK + 1) +
	ceil(x_MEDIA_CHANNEL_FK + 1) +
	ceil(x_OFFER_FK + 1);

    OPEN c_3;
      FETCH c_3 INTO  x_INSTANCE;
    CLOSE c_3;

    x_total := x_total + 8*ceil(x_INSTANCE + 1);

    x_total := x_total + 15*(x_constant + 1);

    -- dbms_output.put_line('     ');
    dbms_output.put_line('The average row length is : ' || to_char(x_total));
  p_avg_row_len := x_total;

  END;  -- procedure est_row_len.

END;  -- package body BIM_EDW_INTRCTNS_F_SIZE

/
