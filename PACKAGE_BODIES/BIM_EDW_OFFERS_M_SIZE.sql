--------------------------------------------------------
--  DDL for Package Body BIM_EDW_OFFERS_M_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_EDW_OFFERS_M_SIZE" AS
/* $Header: bimszofb.pls 115.0 2001/03/14 12:03:18 pkm ship       $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NUMBER) IS


-- v_num_rows        NUMBER := 0;

CURSOR c_cnt_rows IS
   select sum(cnt)
   from (
	select count(*) cnt
	from ams_act_offers aao ,
	qp_list_headers_vl qlh ,
	edw_local_instance inst
	WHERE aao.qp_list_header_id = qlh.list_header_id and
	((aao.last_update_date > to_date('1000/01/01', 'YYYY/MM/DD'))
	or (qlh.last_update_date > to_date('1000/01/01', 'YYYY/MM/DD')))
        and aao.last_update_date between
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


 x_activity_offer_id number;
 x_offer_code number;
 x_offer_type number;
 x_primary_offer_flag number;

 x_list_header_id number;
 x_name number;
 x_description number;

 x_INSTANCE NUMBER;


  CURSOR c_1 IS
	SELECT
	avg(nvl(vsize(activity_offer_id ), 0)),
	avg(nvl(vsize(offer_code ), 0)),
	avg(nvl(vsize(offer_type ), 0)),
	avg(nvl(vsize(primary_offer_flag ), 0))
        FROM ams_act_offers
        where last_update_date between
        p_from_date  and  p_to_date;


  CURSOR c_2 IS
	select
	 avg(nvl(vsize(INSTANCE_CODE), 0))
	 from EDW_LOCAL_INSTANCE ;

  CURSOR c_3 IS
	select
	avg(nvl(vsize(name ), 0)),
	avg(nvl(vsize(list_header_id ), 0)),
	avg(nvl(vsize(description ), 0))
        FROM qp_list_headers_vl;

  BEGIN

    dbms_output.enable(1000000);

    OPEN c_1;
      FETCH c_1 INTO
	 x_activity_offer_id,
	 x_offer_code,
	 x_offer_type,
	 x_primary_offer_flag;

    CLOSE c_1;

    x_total := 57  +
	 2*ceil(x_activity_offer_id + 1) +
	 ceil(x_offer_code + 1) +
	 ceil(x_offer_type + 1) +
	 ceil(x_primary_offer_flag + 1);

    OPEN c_2;
      FETCH c_2 INTO  x_INSTANCE;
    CLOSE c_2;

    x_total := x_total + 2*ceil(x_INSTANCE + 1);

    OPEN c_3;
      FETCH c_3 INTO
	 x_name,
	 x_list_header_id,
	 x_description;
    CLOSE c_3;

    x_total := x_total +
               ceil(x_name + 1) +
	       ceil(x_list_header_id + 1) +
	       ceil(x_description + 1) +
               15*(x_constant + 1);

    -- dbms_output.put_line('     ');
    dbms_output.put_line('The average row length is : ' || to_char(x_total));

  p_avg_row_len := x_total;

  END;  -- procedure est_row_len.

END;  -- package body BIM_EDW_OFFERS_M_SIZE

/
