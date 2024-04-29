--------------------------------------------------------
--  DDL for Package Body BIM_EDW_OPPORTUNITIES_M_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_EDW_OPPORTUNITIES_M_SIZE" AS
/* $Header: bimszopb.pls 115.0 2001/03/14 12:03:23 pkm ship       $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NUMBER) IS


-- v_num_rows        NUMBER := 0;

CURSOR c_cnt_rows IS
   select sum(cnt)
   from (
        select count(*) cnt
	FROM AS_LEAD_LINES_ALL OPL ,
	AS_LEADS_ALL OPH ,
	EDW_LOCAL_INSTANCE INST
	WHERE
	OPH.LEAD_ID = OPL.LEAD_ID AND ( (OPH.LAST_UPDATE_DATE > TO_DATE
	('1000/01/01',
	 'YYYY/MM/DD')) OR (OPL.LAST_UPDATE_DATE > TO_DATE('1000/01/01',
	 'YYYY/MM/DD')) ) AND ( OPH.DELETED_FLAG IS NULL OR OPH.DELETED_FLAG <> 'Y' )
        and oph.last_update_date between
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

 x_date                 NUMBER := 7;
 x_total                NUMBER := 0;
 x_constant             NUMBER := 6;
 X_LEAD_LINE_ID		NUMBER;
 X_LEAD_ID   		NUMBER;
 X_INSTANCE NUMBER;


  CURSOR c_1 IS
	SELECT
	avg(nvl(vsize( LEAD_LINE_ID ), 0))
        FROM AS_LEAD_LINES_ALL;


  CURSOR c_2 IS
	select
	 avg(nvl(vsize(INSTANCE_CODE), 0))
	 from EDW_LOCAL_INSTANCE ;

  CURSOR c_3 IS
	SELECT
	avg(nvl(vsize( LEAD_ID ), 0))
        FROM AS_LEADS_ALL
        where last_update_date between
        p_from_date  and  p_to_date;


  BEGIN

    dbms_output.enable(1000000);

    OPEN c_1;
      FETCH c_1 INTO
	 X_LEAD_LINE_ID   ;

    CLOSE c_1;

    x_total := 5  +
		4*ceil(	 X_LEAD_LINE_ID +1);


    OPEN c_2;
      FETCH c_2 INTO  x_INSTANCE;
    CLOSE c_2;

    OPEN c_3;
      FETCH c_3 INTO
	 X_LEAD_ID   ;

    CLOSE c_3;

    x_total := 2*(x_total +
		5*ceil(x_INSTANCE + 1) +
		2*ceil(x_LEAD_ID + 1)) +
    		15*(x_constant + 1);

    -- dbms_output.put_line('     ');
    dbms_output.put_line('The average row length is : ' || to_char(x_total));

  p_avg_row_len := x_total;

  END;  -- procedure est_row_len.

END;  -- package body BIM_EDW_OPPORTUNITIES_M_SIZE

/
