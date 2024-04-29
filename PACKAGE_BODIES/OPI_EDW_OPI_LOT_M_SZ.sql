--------------------------------------------------------
--  DDL for Package Body OPI_EDW_OPI_LOT_M_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_OPI_LOT_M_SZ" AS
/* $Header: OPIOLTZB.pls 120.1 2005/06/07 02:29:29 appldev  $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS
CURSOR c_cnt_rows IS
	select count(*) cnt
	FROM
	MTL_LOT_NUMBERS
	where  last_update_date between p_from_date and p_to_date ;
BEGIN

  OPEN c_cnt_rows;
       FETCH c_cnt_rows INTO p_num_rows;
  CLOSE c_cnt_rows;

END;  -- procedure cnt_rows.


PROCEDURE est_row_len(p_from_date DATE,
                   p_to_date DATE,
                   p_est_row_len OUT NOCOPY NUMBER) IS
	x_EDW_LOT_PK  NUMBER ;
	x_Organization_id NUMBER ;
	x_Inventory_Item_id NUMBER ;
	x_Name NUMBER ;
	x_LOT_NAME NUMBER ;
	x_EXPIRATION_DATE NUMBER ;
	x_LOT_DESCRIPTION NUMBER ;
	x_LAST_UPDATE_DATE NUMBER ;
	x_CREATION_DATE NUMBER ;
	x_INSTANCE NUMBER;

	x_total NUMBER := 0 ;

CURSOR c_1  IS

	SELECT
	-- EDW_LOT_PK need to add instance_code
	avg(nvl(vsize(INVENTORY_ITEM_ID||ORGANIZATION_ID||LOT_NUMBER), 0)),
	-- EDW_LOT_DP
	-- Organization_id
	avg(nvl(vsize(ORGANIZATION_ID), 0)),
	-- Inventory_Item_id
	avg(nvl(vsize(Inventory_Item_id), 0)),
	-- Name
	avg(nvl(vsize(lot_number||Inventory_Item_ID||Organization_ID), 0)) ,
	-- LOT_NAME
	avg(nvl(vsize(lot_number), 0)),
	-- ITEM_REVISION
	-- NETTABLE_FLAG
	-- EXPIRATION_DATE
	avg(nvl(vsize(expiration_date), 0)),
	-- LOT_DESCRIPTION
	avg(nvl(vsize(lot_number), 0)) ,
	-- LAST_UPDATE_DATE
	avg(nvl(vsize(LAST_UPDATE_DATE), 0)),
	-- CREATION_DATE
	avg(nvl(vsize(CREATION_DATE), 0))
	FROM
	MTL_LOT_NUMBERS ;
	--WHERE
	--last_update_date between p_from_date and p_to_date ;

  CURSOR c_2 IS
	SELECT
		avg(nvl(vsize(instance_code), 0))
	FROM	EDW_LOCAL_INSTANCE ;
        -- WHERE last_update_date between
       --  p_from_date  and  p_to_date;
BEGIN

  /* dbms_output.put_line ('******************'||x_total||'******') ; */

  OPEN c_1;
       FETCH c_1 INTO
	x_EDW_LOT_PK  ,
	x_Organization_id,
	x_Inventory_Item_id,
	x_Name ,
	x_LOT_NAME ,
	x_EXPIRATION_DATE ,
	x_LOT_DESCRIPTION,
	x_LAST_UPDATE_DATE ,
	x_CREATION_DATE  ;
  CLOSE c_1;

  /* dbms_output.put_line ('******************'||x_total||'******') ; */
    x_total := 3 +
	    x_total +
	ceil(x_EDW_LOT_PK + 1) +
	ceil(x_Organization_id+ 1) +
	ceil(x_Inventory_Item_id+ 1) +
	ceil(x_Name + 1) +
	ceil(x_LOT_NAME + 1) +
	ceil(x_EXPIRATION_DATE+ 1) +
	ceil(x_LOT_DESCRIPTION+ 1) +
	ceil(x_LAST_UPDATE_DATE + 1) +
	ceil(x_CREATION_DATE+ 1)   ;

  /* dbms_output.put_line ('******************'||x_total||'******') ; */
  OPEN c_2;
       FETCH c_2 INTO
	x_INSTANCE ;
  CLOSE c_2;

  /* dbms_output.put_line ('******************'||x_total||'******') ; */
  x_total := x_total +
	ceil(x_INSTANCE + 1) ;

	p_est_row_len := x_total ;


  /* dbms_output.put_line ('******************'||x_total||'******') ; */


END ;

END OPI_EDW_OPI_LOT_M_SZ ;  -- procedure est_row_len.

/
