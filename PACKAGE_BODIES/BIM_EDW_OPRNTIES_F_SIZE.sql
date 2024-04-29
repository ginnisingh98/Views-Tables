--------------------------------------------------------
--  DDL for Package Body BIM_EDW_OPRNTIES_F_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_EDW_OPRNTIES_F_SIZE" AS
/* $Header: bimszfob.pls 115.0 2001/03/14 12:02:38 pkm ship       $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NUMBER) IS


 -- v_num_rows        NUMBER := 0;

CURSOR c_cnt_rows IS
   select sum(cnt)
   from (
        select count(*) cnt
	FROM AS_LEAD_LINES_ALL ASLL,
	 AS_LEADS_ALL ASL,
	 EDW_BIM_SOURCE_CODE_DETAILS BSCD,
	 BIM_EDW_OPRNTIES_INC INC,
	 EDW_LOCAL_INSTANCE INST
	WHERE ASL.LEAD_ID = ASLL.LEAD_ID
	 AND ASLL.LEAD_LINE_ID = INC.PRIMARY_KEY
	 AND NVL(ASLL.SOURCE_PROMOTION_ID,
	 -999) = BSCD.SOURCE_CODE_ID
	 AND ( ( ASL.LAST_UPDATE_DATE > TO_DATE( '1000/01/01', 'YYYY/MM/DD' ) )
         OR ( ASLL.LAST_UPDATE_DATE > TO_DATE( '1000/01/01','YYYY/MM/DD' ) ) )
	and
	ASL.last_update_date between
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

 x_LEAD_LINE_ID NUMBER;
 x_OFFER_ID NUMBER;
 x_ORG_ID NUMBER;
 x_TOTAL_AMOUNT NUMBER;
 x_QUANTITY NUMBER;

 x_CAMPAIGN_FK NUMBER;
 x_EVENT_FK NUMBER;
 x_MEDIA_CHANNEL_FK NUMBER;

 x_STATUS_CODE NUMBER;
 x_CUSTOMER_ID NUMBER;
 x_CURRENCY_CODE NUMBER;
 x_CHANNEL_CODE NUMBER;
 x_ADRESS_ID NUMBER;

 x_INSTANCE NUMBER;


  CURSOR c_1 IS
	SELECT
	avg(nvl(vsize( LEAD_LINE_ID ), 0)),
	avg(nvl(vsize( OFFER_ID ), 0)),
	avg(nvl(vsize( ORG_ID ), 0)),
	avg(nvl(vsize( TOTAL_AMOUNT ), 0)),
	avg(nvl(vsize( QUANTITY ), 0))
	FROM AS_LEAD_LINES_ALL
        where last_update_date between
        p_from_date  and  p_to_date;

  CURSOR c_2 IS
	select
	 avg(nvl(vsize(CAMPAIGN_FK), 0)),
	 avg(nvl(vsize(EVENT_FK), 0)),
	 avg(nvl(vsize(MEDIA_CHANNEL_FK), 0))
	 from EDW_BIM_SOURCE_CODE_DETAILS  ;


  CURSOR c_3 IS
	select
	 avg(nvl(vsize(STATUS_CODE), 0)),
	 avg(nvl(vsize(CUSTOMER_ID), 0)),
	 avg(nvl(vsize(CURRENCY_CODE), 0)),
	 avg(nvl(vsize(CHANNEL_CODE), 0)),
	 avg(nvl(vsize(ADDRESS_ID), 0))
	 from AS_SALES_LEADS
         where last_update_date between
         p_from_date  and  p_to_date;


  CURSOR c_4 IS
	select
	 avg(nvl(vsize(INSTANCE_CODE), 0))
	 from EDW_LOCAL_INSTANCE ;



  BEGIN

    dbms_output.enable(1000000);

    OPEN c_1;
      FETCH c_1 INTO
	 x_LEAD_LINE_ID,
	 x_OFFER_ID,
	 x_ORG_ID,
	 x_TOTAL_AMOUNT,
	 x_QUANTITY;

    CLOSE c_1;

    x_total := 100  +
		2*ceil(	 x_LEAD_LINE_ID +1) +
		ceil(	 x_OFFER_ID +1) +
		ceil(	 x_ORG_ID +1) +
		ceil(	 x_TOTAL_AMOUNT +1) +
		ceil(	 x_QUANTITY +1) ;

    OPEN c_2;
      FETCH c_2 INTO
	 x_CAMPAIGN_FK,
	 x_EVENT_FK,
	 x_MEDIA_CHANNEL_FK;
    CLOSE c_2;

    x_total := x_total +
	ceil(x_CAMPAIGN_FK + 1) +
	ceil(x_EVENT_FK + 1) +
	ceil(x_MEDIA_CHANNEL_FK + 1) ;

    OPEN c_3;
      FETCH c_3 INTO
	 x_STATUS_CODE,
	 x_CUSTOMER_ID,
	 x_CURRENCY_CODE,
	 x_CHANNEL_CODE,
	 x_ADRESS_ID;
    CLOSE c_3;

    x_total := x_total +
	ceil(x_STATUS_CODE + 1) +
	ceil(x_CUSTOMER_ID + 1) +
	ceil(x_CURRENCY_CODE + 1) +
	ceil(x_CHANNEL_CODE + 1) +
	2*ceil(x_ADRESS_ID + 1) ;


    OPEN c_4;
      FETCH c_4 INTO  x_INSTANCE;
    CLOSE c_4;

    x_total := x_total + 16*ceil(x_INSTANCE + 1);

    x_total := x_total + 15*(x_constant + 1);

    -- dbms_output.put_line('     ');
    dbms_output.put_line('The average row length is : ' || to_char(x_total));

  p_avg_row_len := x_total;

  END;  -- procedure est_row_len.

END;  -- package body BIM_EDW_OPRNTIES_F_SIZE

/
