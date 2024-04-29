--------------------------------------------------------
--  DDL for Package Body OPI_EDW_UOM_CONV_F_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_UOM_CONV_F_SZ" AS
/* $Header: OPIOUCZB.pls 120.1 2005/06/16 03:52:28 appldev  $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS
CURSOR c_cnt_rows IS
	select sum(cnt)
	from (select count(*) cnt
		FROM EDW_LOCAL_INSTANCE ELI, MTL_UOM_CONVERSIONS MUC,
		MTL_UNITS_OF_MEASURE MUOM, MTL_UNITS_OF_MEASURE BUOM,
		mtl_system_items_kfv msik
		WHERE
		muom.uom_code = muc.uom_code and
		muom.uom_class = muc.uom_class and
		muom.uom_class = buom.uom_class and
		buom.BASE_UOM_FLAG='Y' and
		msik.inventory_item_id (+) = MUC.INVENTORY_ITEM_ID and
		muom.last_update_date between p_from_date and p_to_date
		UNION
		select count(*) cnt
		FROM
		edw_local_instance eli,
		mtl_uom_class_conversions mucc ,
		mtl_system_items_kfv msik
		where
		mucc.from_uom_code <> mucc.to_uom_code and
		msik.inventory_item_id = MUCC.INVENTORY_ITEM_ID and
		mucc.last_update_date between p_from_date and p_to_date
		group by DECODE(MUCC.INVENTORY_ITEM_ID,0, 'STANDARD',
		TO_CHAR(MUCC.INVENTORY_ITEM_ID)) ||'-' ||
		MUCC.FROM_UOM_CODE||'-'||MUCC.TO_UOM_CODE||'-'||
		ELI.INSTANCE_CODE , MUCC.INVENTORY_ITEM_ID,
		MUCC.FROM_UOM_CODE, MUCC.TO_UOM_CODE,
		MUCC.CONVERSION_RATE, ELI.INSTANCE_CODE, MUCC.LAST_UPDATE_DATE, MUCC.CREATION_DATE ) ;

BEGIN

  OPEN c_cnt_rows;
       FETCH c_cnt_rows INTO p_num_rows;
  CLOSE c_cnt_rows;

END;  -- procedure cnt_rows.


PROCEDURE est_row_len(p_from_date DATE, p_to_date DATE, p_avg_row_len OUT NOCOPY NUMBER) IS
	x_UOM_CONV_PK NUMBER ;
	x_EDW_UOM_FK NUMBER ;
	x_EDW_BASE_UOM_FK NUMBER ;
	x_INVENTORY_ITEM_ID NUMBER ;
	x_UOM NUMBER ;
	x_BASE_UOM NUMBER ;
	x_CONVERSION_RATE NUMBER ;
	x_EDW_CONVERSION_RATE NUMBER ;
	x_INSTANCE_FK NUMBER ;
	x_USER_ATTRIBUTE1 NUMBER ;
	x_LAST_UPDATE_DATE NUMBER ;
	x_CREATION_DATE NUMBER ;
	x_CLASS_CONVERSION_FLAG NUMBER ;

	x_total NUMBER := 0 ;

	CURSOR c_1 IS
		SELECT
			--	x_UOM_CONV_PK NUMBER ;
			avg(nvl(vsize(DECODE(MUC.INVENTORY_ITEM_ID,0,'STANDARD',TO_CHAR(MUC.INVENTORY_ITEM_ID))||MUC.UOM_CODE||eli.instance_code), 0)) ,
			-- x_EDW_UOM_FK NUMBER ;
			-- NULL,
			-- x_EDW_BASE_UOM_FK NUMBER ;
			-- NULL,
			-- x_INVENTORY_ITEM_ID NUMBER ;
			avg(nvl(vsize(MUC.INVENTORY_ITEM_ID), 0)),
			-- x_UOM NUMBER ;
			avg(nvl(vsize(MUC.UOM_CODE), 0)),
			-- x_BASE_UOM NUMBER ;
			avg(nvl(vsize(BUOM.UOM_CODE), 0)),
			-- x_CONVERSION_RATE NUMBER ;
			avg(nvl(vsize(MUC.CONVERSION_RATE), 0)),
			-- x_EDW_CONVERSION_RATE NUMBER ;
			-- TO_NUMBER(NULL),
			-- x_INSTANCE_FK NUMBER ;
			avg(nvl(vsize(ELI.INSTANCE_CODE), 0)),
			-- x_USER_ATTRIBUTE1 NUMBER ;
			avg(nvl(vsize(msik.concatenated_segments), 0)),
			-- x_LAST_UPDATE_DATE NUMBER ;
			avg(nvl(vsize(MUC.LAST_UPDATE_DATE), 0)),
			-- x_CREATION_DATE NUMBER ;
			avg(nvl(vsize(MUC.CREATION_DATE), 0))
			-- x_CLASS_CONVERSION_FLAG NUMBER ;
			FROM
			EDW_LOCAL_INSTANCE ELI,
			MTL_UOM_CONVERSIONS MUC,
			MTL_UNITS_OF_MEASURE MUOM,
			MTL_UNITS_OF_MEASURE BUOM,
			mtl_system_items_kfv msik
			WHERE
			muom.uom_code = muc.uom_code and
			muom.uom_class = muc.uom_class and
			muom.uom_class = buom.uom_class and
			buom.BASE_UOM_FLAG='Y' and
			msik.inventory_item_id (+) = MUC.INVENTORY_ITEM_ID and
			muom.last_update_date between p_from_date and p_to_date ;
BEGIN
  OPEN c_1;
       FETCH c_1 INTO
			x_UOM_CONV_PK ,
			x_INVENTORY_ITEM_ID,
			x_UOM ,
			x_BASE_UOM ,
			x_CONVERSION_RATE ,
			x_INSTANCE_FK ,
			x_USER_ATTRIBUTE1,
			x_LAST_UPDATE_DATE,
			x_CREATION_DATE  ;
  CLOSE c_1 ;
    x_total := 3 +
	    x_total +
			ceil(x_UOM_CONV_PK + 1)+
			ceil(x_INVENTORY_ITEM_ID+ 1)+
			ceil(x_UOM+ 1) +
			ceil(x_BASE_UOM+ 1) +
			ceil(x_CONVERSION_RATE+ 1) +
			ceil(x_INSTANCE_FK+ 1) +
			ceil(x_USER_ATTRIBUTE1+ 1)+
			ceil(x_LAST_UPDATE_DATE+ 1)+
			ceil(x_CREATION_DATE + 1) ;

	p_avg_row_len := x_total ;

END  est_row_len ;  -- procedure est_row_len.

END OPI_EDW_UOM_CONV_F_SZ ;

/
