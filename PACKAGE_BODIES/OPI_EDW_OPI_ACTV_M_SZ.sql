--------------------------------------------------------
--  DDL for Package Body OPI_EDW_OPI_ACTV_M_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_OPI_ACTV_M_SZ" AS
/* $Header: OPIOACZB.pls 120.1 2005/06/08 18:33:02 appldev  $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS
CURSOR c_cnt_rows IS
	select count(*) cnt
	FROM
	CST_ACTIVITIES
	where  last_update_date between p_from_date and p_to_date ;
BEGIN

  OPEN c_cnt_rows;
       FETCH c_cnt_rows INTO p_num_rows;
  CLOSE c_cnt_rows;

END;  -- procedure cnt_rows.


PROCEDURE est_row_len(p_from_date DATE,
                   p_to_date DATE,
                   p_est_row_len OUT NOCOPY NUMBER) IS

	x_ACTV_PK NUMBER ;
	x_ACTV_DP NUMBER ;
	x_ACTV_CODE NUMBER ;
	x_NAME NUMBER ;
	x_ACTV_NAME NUMBER ;
	x_DESCRIPTION NUMBER ;
	x_VALUE_ADDED NUMBER ;
	x_LAST_UPDATE_DATE NUMBER ;
	x_CREATION_DATE NUMBER ;
	x_INSTANCE NUMBER ;

	x_total NUMBER := 0;

CURSOR c_1  IS
	SELECT
	-- ACTV_PK need to add instance_code
	avg(nvl(vsize(ACTIVITY_ID), 0)),
	-- EDW_LOT_DP
	-- ACTV_CODE
	avg(nvl(vsize(ACTIVITY), 0)),
	-- Name
	avg(nvl(vsize(ACTIVITY), 0)) ,
	-- ACTV_NAME
	avg(nvl(vsize(ACTIVITY), 0)),
	-- DESCRIPTION
	avg(nvl(vsize(DESCRIPTION), 0)) ,
	-- COST_ANALYSIS_CODE
	-- VALUE_ADDED ??
	avg(nvl(vsize(VALUE_ADDED_ACTIVITY_FLAG), 0)) ,
	-- LAST_UPDATE_DATE
	avg(nvl(vsize(LAST_UPDATE_DATE), 0)),
	-- CREATION_DATE
	avg(nvl(vsize(CREATION_DATE), 0))
	FROM
	CST_ACTIVITIES
	WHERE
	last_update_date between p_from_date and p_to_date ;

  CURSOR c_2 IS
	SELECT
		avg(nvl(vsize(instance_code), 0))
	FROM	EDW_LOCAL_INSTANCE ;
        -- WHERE last_update_date between
       --  p_from_date  and  p_to_date;

BEGIN

  OPEN c_1;
       FETCH c_1 INTO
	x_ACTV_PK ,
	x_ACTV_CODE ,
	x_NAME  ,
	x_ACTV_NAME ,
	x_DESCRIPTION ,
	x_VALUE_ADDED ,
	x_LAST_UPDATE_DATE,
	x_CREATION_DATE  ;

  CLOSE c_1;

    x_total := 3 +
	    x_total +
	ceil(x_ACTV_PK + 1) +
	ceil(x_ACTV_CODE + 1) +
	ceil(x_NAME + 1) +
	ceil(x_ACTV_NAME + 1) +
	ceil(x_VALUE_ADDED + 1 ) +
	ceil(x_DESCRIPTION+ 1) +
	ceil(x_LAST_UPDATE_DATE + 1) +
	ceil(x_CREATION_DATE+ 1)   ;

  OPEN c_2;
       FETCH c_2 INTO
	x_INSTANCE ;
  CLOSE c_2;

  x_total := x_total +
	ceil(x_INSTANCE + 1) ;

	p_est_row_len := x_total ;

END ;

END OPI_EDW_OPI_ACTV_M_SZ ;  -- procedure est_row_len.

/
