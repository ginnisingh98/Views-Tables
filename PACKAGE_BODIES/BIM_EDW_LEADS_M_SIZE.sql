--------------------------------------------------------
--  DDL for Package Body BIM_EDW_LEADS_M_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_EDW_LEADS_M_SIZE" AS
/* $Header: bimszldb.pls 115.0 2001/03/14 12:02:45 pkm ship       $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NUMBER) IS


-- v_num_rows        NUMBER := 0;

CURSOR c_cnt_rows IS
   select sum(cnt)
   from (
        select count(*) cnt
	FROM AS_SALES_LEAD_LINES ASLL ,
	AS_SALES_LEADS ASL ,
	EDW_LOCAL_INSTANCE INST
	WHERE ASLL.SALES_LEAD_ID = ASL.SALES_LEAD_ID AND
	( (ASL.LAST_UPDATE_DATE > TO_DATE('1000/01/01', 'YYYY/MM/DD') )
	OR (ASLL.LAST_UPDATE_DATE > TO_DATE('1000/01/01', 'YYYY/MM/DD') ) )
	AND ( ASL.DELETED_FLAG IS NULL OR ASL.DELETED_FLAG <> 'Y' )
        and
        asl.last_update_date between
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
 X_SALES_LEAD_ID	NUMBER;
 X_SALES_LEAD_LINE_ID   NUMBER;
 X_INSTANCE NUMBER;


  CURSOR c_1 IS
	SELECT
	avg(nvl(vsize( ASLL.SALES_LEAD_LINE_ID ), 0)),
	avg(nvl(vsize( ASL.SALES_LEAD_ID), 0))
        FROM AS_SALES_LEAD_LINES ASLL ,
        AS_SALES_LEADS ASL ,
        EDW_LOCAL_INSTANCE INST
        WHERE ASLL.SALES_LEAD_ID = ASL.SALES_LEAD_ID AND
        ( (ASL.LAST_UPDATE_DATE > TO_DATE('1000/01/01', 'YYYY/MM/DD') )
        OR (ASLL.LAST_UPDATE_DATE > TO_DATE('1000/01/01', 'YYYY/MM/DD') ) )
        AND ( ASL.DELETED_FLAG IS NULL OR ASL.DELETED_FLAG <> 'Y' )
	AND ASL.last_update_date between
        p_from_date  and  p_to_date ;


  CURSOR c_2 IS
	select
	 avg(nvl(vsize(INSTANCE_CODE), 0))
	 from EDW_LOCAL_INSTANCE ;



  BEGIN

    dbms_output.enable(1000000);

    OPEN c_1;
      FETCH c_1 INTO
	 X_SALES_LEAD_ID        ,
	 X_SALES_LEAD_LINE_ID   ;

    CLOSE c_1;

    x_total := 5  +
		ceil(	 X_SALES_LEAD_ID +1) +
		3*ceil(	 X_SALES_LEAD_LINE_ID +1);


    OPEN c_2;
      FETCH c_2 INTO  x_INSTANCE;
    CLOSE c_2;

    x_total := x_total + 5*ceil(x_INSTANCE + 1);

    x_total := 3*x_total + 15*(x_constant + 1);

    -- dbms_output.put_line('     ');
    dbms_output.put_line('The average row length is : ' || to_char(x_total));

  p_avg_row_len := x_total;

  END;  -- procedure est_row_len.

END;  -- package body BIM_EDW_LEADS_M_SIZE

/
