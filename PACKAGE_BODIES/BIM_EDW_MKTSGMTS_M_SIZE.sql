--------------------------------------------------------
--  DDL for Package Body BIM_EDW_MKTSGMTS_M_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_EDW_MKTSGMTS_M_SIZE" AS
/* $Header: bimszmsb.pls 115.0 2001/03/14 12:03:13 pkm ship       $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NUMBER) IS


-- v_num_rows        NUMBER := 0;

CURSOR c_cnt_rows IS
   select sum(cnt)
   from (
        select count(*) cnt
	FROM AMS_CELLS_VL AMC ,
	EDW_LOCAL_INSTANCE INST
	WHERE AMC.MARKET_SEGMENT_FLAG = 'Y'
        and amc.last_update_date between
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
 X_CELL_NAME NUMBER;
 X_CELL_ID NUMBER;
 X_CELL_CODE NUMBER;
 X_ENABLED_FLAG NUMBER;
 X_DESCRIPTION NUMBER;


 x_INSTANCE NUMBER;


  CURSOR c_1 IS
	SELECT
	avg(nvl(vsize( CELL_NAME ), 0)),
	avg(nvl(vsize( CELL_ID), 0)),
	avg(nvl(vsize( CELL_CODE), 0)),
	avg(nvl(vsize( ENABLED_FLAG), 0)),
	avg(nvl(vsize( DESCRIPTION), 0))
	FROM AMS_CELLS_VL AMC
	WHERE AMC.MARKET_SEGMENT_FLAG = 'Y'
        and last_update_date between
        p_from_date  and  p_to_date;


  CURSOR c_2 IS
	select
	 avg(nvl(vsize(INSTANCE_CODE), 0))
	 from EDW_LOCAL_INSTANCE ;



  BEGIN

    dbms_output.enable(1000000);

    OPEN c_1;
      FETCH c_1 INTO
	 X_CELL_NAME,
	 X_CELL_ID,
	 X_CELL_CODE,
	 X_ENABLED_FLAG,
	 X_DESCRIPTION;

    CLOSE c_1;

    x_total := 5  +
	 3*ceil(X_CELL_NAME +1) +
	 ceil(X_CELL_ID +1) +
	 2*ceil(X_CELL_CODE +1) +
	 ceil(X_ENABLED_FLAG +1) +
	 ceil(X_DESCRIPTION +1) ;




    OPEN c_2;
      FETCH c_2 INTO  x_INSTANCE;
    CLOSE c_2;

    x_total := x_total + 2*ceil(x_INSTANCE + 1);

    x_total := x_total + 15*(x_constant + 1);

    -- dbms_output.put_line('     ');
    dbms_output.put_line('The average row length is : ' || to_char(x_total));

  p_avg_row_len := x_total;

  END;  -- procedure est_row_len.

END;  -- package body BIM_EDW_MKTSGMTS_M_SIZE

/
