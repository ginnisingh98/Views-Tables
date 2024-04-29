--------------------------------------------------------
--  DDL for Package Body BIM_EDW_MDCHN_M_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_EDW_MDCHN_M_SIZE" AS
/* $Header: bimszmcb.pls 115.0 2001/03/14 12:02:58 pkm ship       $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NUMBER) IS


-- v_num_rows        NUMBER := 0;

CURSOR c_cnt_rows IS
   select sum(cnt)
   from (
	select count(*) cnt
	from ams_media_vl ame,
	edw_local_instance inst
        where ame.last_update_date between
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
 x_media_type_code number;
 x_media_id number;
 x_inbound_flag number;
 x_enabled_flag number;
 x_media_name number;
 x_description number;


 x_INSTANCE NUMBER;


  CURSOR c_1 IS
	SELECT
	avg(nvl(vsize(media_type_code ), 0)),
	avg(nvl(vsize(media_id ), 0)),
	avg(nvl(vsize(inbound_flag ), 0)),
	avg(nvl(vsize(enabled_flag ), 0)),
	avg(nvl(vsize(media_name ), 0)),
	avg(nvl(vsize(description ), 0))
        FROM ams_media_vl
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
	 x_media_type_code,
	 x_media_id,
	 x_inbound_flag,
	 x_enabled_flag,
	 x_media_name,
	 x_description;

    CLOSE c_1;

    x_total := 5  +
	ceil(	 x_media_type_code+1) +
	ceil(	 x_media_id+1) +
	2*ceil(	 x_inbound_flag+1) +
	ceil(	 x_enabled_flag+1) +
	2*ceil(	 x_media_name+1) +
	ceil(	 x_description);

    OPEN c_2;
      FETCH c_2 INTO  x_INSTANCE;
    CLOSE c_2;

    x_total := x_total + 3*ceil(x_INSTANCE + 1);
    x_total := 4*x_total;

    x_total := x_total + 15*(x_constant + 1);

    -- dbms_output.put_line('     ');
    dbms_output.put_line('The average row length is : ' || to_char(x_total));

  p_avg_row_len := x_total;

  END;  -- procedure est_row_len.

END;  -- package body BIM_EDW_MDCHN_M_SIZE

/
