--------------------------------------------------------
--  DDL for Package Body BIM_EDW_SRCLSTS_M_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_EDW_SRCLSTS_M_SIZE" AS
/* $Header: bimszslb.pls 115.0 2001/03/14 12:03:51 pkm ship       $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NUMBER) IS


-- v_num_rows        NUMBER := 0;

CURSOR c_cnt_rows IS
   select sum(cnt)
   from (
	select count(*) cnt
	from
	ams_imp_list_headers_all ail ,
	ams_list_src_types als ,
	edw_local_instance inst
	WHERE
	ail.list_source_type_id = als.list_source_type_id(+)
	and ail.import_type = 'SOURCE'
        and ail.last_update_date between
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

 x_name number;
 x_import_list_header_id number;
 x_list_source_type_id number;
 x_user_status_id number;
 x_status_code number;
 x_status_date number;
 x_vendor_id number;
 x_transactional_cost number;
 x_transactional_currency_code number;
 x_functional_cost number;
 x_functional_currency_code number;
 x_pin_id number;
 x_org_id number;
 x_source_system number;
 x_keywords number;
 x_description number;

 x_list_source_type number;

 x_instance number;


  CURSOR c_1 IS
	SELECT
	avg(nvl(vsize( name ), 0)),
	avg(nvl(vsize( import_list_header_id ), 0)),
	avg(nvl(vsize( list_source_type_id ), 0)),
	avg(nvl(vsize( user_status_id ), 0)),
	avg(nvl(vsize( status_code ), 0)),
	avg(nvl(vsize( status_date ), 0)),
	avg(nvl(vsize( vendor_id ), 0)),
	avg(nvl(vsize( transactional_cost ), 0)),
	avg(nvl(vsize( transactional_currency_code ), 0)),
	avg(nvl(vsize( functional_cost ), 0)),
	avg(nvl(vsize( functional_currency_code ), 0)),
	avg(nvl(vsize( pin_id ), 0)),
	avg(nvl(vsize( org_id ), 0)),
	avg(nvl(vsize( source_system ), 0)),
	avg(nvl(vsize( keywords ), 0)),
	avg(nvl(vsize( description ), 0))
	from
	ams_imp_list_headers_all
        where last_update_date between
        p_from_date  and  p_to_date;



  CURSOR c_2 IS
	select
	 avg(nvl(vsize(INSTANCE_CODE), 0))
	 from EDW_LOCAL_INSTANCE ;


  CURSOR c_3 IS
        select
	avg(nvl(vsize(list_source_type), 0))
        from ams_list_src_types;

  BEGIN

    dbms_output.enable(1000000);

    OPEN c_1;
      FETCH c_1 INTO
	 x_name,
	 x_import_list_header_id,
	 x_list_source_type_id,
	 x_user_status_id,
	 x_status_code,
	 x_status_date,
	 x_vendor_id,
	 x_transactional_cost,
	 x_transactional_currency_code,
	 x_functional_cost,
	 x_functional_currency_code,
	 x_pin_id,
	 x_org_id,
	 x_source_system,
	 x_keywords,
	 x_description;


    CLOSE c_1;

    x_total := 5  +
	 3*ceil(X_name + 1) +
	 2*ceil(x_import_list_header_id + 1) +
	ceil(	 x_list_source_type_id +1) +
	ceil(	 x_user_status_id +1) +
	ceil(	 x_status_code +1) +
	ceil(	 x_status_date +1) +
	ceil(	 x_vendor_id +1) +
	ceil(	 x_transactional_cost +1) +
	ceil(	 x_transactional_currency_code +1) +
	ceil(	 x_functional_cost +1) +
	ceil(	 x_functional_currency_code +1) +
	ceil(	 x_pin_id +1) +
	ceil(	 x_org_id +1) +
	ceil(	 x_source_system +1) +
	ceil(	 x_keywords +1) +
	ceil(	 x_description +1) ;

    OPEN c_2;
      FETCH c_2 INTO  x_INSTANCE;
    CLOSE c_2;

    x_total := x_total + 2*ceil(x_INSTANCE + 1);

    OPEN c_3;
	FETCH c_3 into x_list_source_type;
    CLOSE c_3;


    x_total := x_total + ceil(x_list_source_type +1) + 15*(x_constant + 1);

    -- dbms_output.put_line('     ');
    dbms_output.put_line('The average row length is : ' || to_char(x_total));

  p_avg_row_len := x_total;

  END;  -- procedure est_row_len.

END;  -- package body BIM_EDW_SRCLSTS_M_SIZE

/
