--------------------------------------------------------
--  DDL for Package Body BIM_EDW_IH_MEDIA_M_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_EDW_IH_MEDIA_M_SIZE" AS
/* $Header: bimszmeb.pls 115.0 2001/03/14 12:03:06 pkm ship       $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NUMBER) IS


-- v_num_rows        NUMBER := 0;

CURSOR c_cnt_rows IS
   select sum(cnt)
   from (
        select count(*) cnt
	FROM JTF_IH_MEDIA_ITEMS JMI ,
	FND_LOOKUP_VALUES_VL LKP ,
	EDW_LOCAL_INSTANCE INST
	WHERE JMI.MEDIA_ITEM_TYPE = LKP.LOOKUP_CODE AND
	LKP.LOOKUP_TYPE = 'JTF_MEDIA_TYPE' AND LKP.VIEW_APPLICATION_ID = 0
        AND
        LKP.SECURITY_GROUP_ID=FND_GLOBAL.LOOKUP_SECURITY_GROUP( LKP.LOOKUP_CODE,
        LKP.VIEW_APPLICATION_ID )
        and jmi.last_update_date between
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
 X_DIRECTION NUMBER;


 x_INSTANCE NUMBER;


  CURSOR c_1 IS
	SELECT
	avg(nvl(vsize(JMI.DIRECTION ), 0))
        FROM JTF_IH_MEDIA_ITEMS JMI
        where jmi.last_update_date between
        p_from_date  and  p_to_date;


  CURSOR c_2 IS
	select
	 avg(nvl(vsize(INSTANCE_CODE), 0))
	 from EDW_LOCAL_INSTANCE ;



  BEGIN

    dbms_output.enable(1000000);

    OPEN c_1;
      FETCH c_1 INTO
	 X_DIRECTION;

    CLOSE c_1;

    x_total := 150  +
	 6*ceil(X_DIRECTION + 1);

    OPEN c_2;
      FETCH c_2 INTO  x_INSTANCE;
    CLOSE c_2;

    x_total := x_total + 2*ceil(x_INSTANCE + 1);

    x_total := x_total + 15*(x_constant + 1);

    -- dbms_output.put_line('     ');
    dbms_output.put_line('The average row length is : ' || to_char(x_total));

  p_avg_row_len := x_total;

  END;  -- procedure est_row_len.

END;  -- package body BIM_EDW_IH_MEDIA_M_SIZE

/
