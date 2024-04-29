--------------------------------------------------------
--  DDL for Package Body EDW_MTL_INVENTORY_LOC_M_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_MTL_INVENTORY_LOC_M_SZ" AS
/* $Header: OPIINLZB.pls 120.1 2005/06/10 13:35:19 appldev  $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS
CURSOR c_cnt_rows IS
	select sum(cnt)
	FROM
        (
        -- Locator Level
        select count(*) cnt
	FROM mtl_item_locations_kfv locf,
	mtl_parameters mp,
	hr_organization_units hou
	where
        locf.last_update_date between p_from_date and p_to_date AND
        locf.organization_id = mp.organization_id AND
        hou.organization_id=mp.organization_id AND
 	(locf.physical_location_id = locf.inventory_location_id OR
	locf.physical_location_id IS NULL)
        union all
        -- Sub Inventory Level
        select count(*) cnt
        FROM mtl_secondary_inventories msi,
	hr_all_organization_units bg,
	hr_all_organization_units org,
	mtl_parameters mp
	WHERE msi.organization_id = mp.organization_id + 0
	AND bg.organization_id = org.business_group_id
	AND org.organization_id = mp.organization_id
        and msi.last_update_date between p_from_date and p_to_date
        union all
        -- Inventory Organization Level
        select count(*) cnt
	FROM
	hr_all_organization_units bg,
	hr_all_organization_units org,
	HR_ORGANIZATION_INFORMATION HOI,
	mtl_parameters mp
	WHERE bg.organization_id = org.business_group_id
	AND org.organization_id = mp.organization_id
	and org.ORGANIZATION_ID = HOI.ORGANIZATION_ID
	AND ( HOI.ORG_INFORMATION_CONTEXT || '') ='Accounting Information'
        and mp.last_update_date between p_from_date and p_to_date
        union all
        -- Operating Unit Level
	select count(*) cnt
	FROM EDW_ORGA_OPER_UNIT_LCV
	where  last_update_date between p_from_date and p_to_date
        -- Inventory Organization Parent Goup level
      union all
      SELECT COUNT(*) cnt
      FROM SY_ORGN_MST
      WHERE ORGN_CODE = CO_CODE
        -- Inventory Organization Parent Goup level
      union all
      SELECT COUNT(*) cnt
      FROM SY_ORGN_MST
       -- Locator level non location controlled
      UNION ALL
      SELECT COUNT(*) cnt
      FROM IC_LOCT_INV ILI,
        IC_ITEM_MST IIM,
        IC_WHSE_MST IWM,
        MTL_PARAMETERS MP
      WHERE
        ILI.ITEM_ID   = IIM.ITEM_ID
      AND ILI.WHSE_CODE = IWM.WHSE_CODE
      AND MP.ORGANIZATION_ID = IWM.MTL_ORGANIZATION_ID
      AND IWM.LOCT_CTL * IIM.LOCT_CTL = 0
       -- Locator level Non Validated
      UNION ALL
      SELECT COUNT(*) cnt
      FROM IC_LOCT_INV ILI,
        IC_ITEM_MST IIM,
        IC_WHSE_MST IWM,
        MTL_PARAMETERS MP
      WHERE
            ILI.ITEM_ID   = IIM.ITEM_ID
        AND ILI.WHSE_CODE = IWM.WHSE_CODE
        AND MP.ORGANIZATION_ID = IWM.MTL_ORGANIZATION_ID
        AND IWM.LOCT_CTL * IIM.LOCT_CTL >1 );

BEGIN

  OPEN c_cnt_rows;
       FETCH c_cnt_rows INTO p_num_rows;
  CLOSE c_cnt_rows;

END;  -- procedure cnt_rows.


PROCEDURE est_row_len(p_from_date DATE,
                   p_to_date DATE,
                   p_est_row_len OUT NOCOPY NUMBER) IS

	x_LOCATOR_PK  NUMBER ;
	x_STOCK_ROOM_FK NUMBER ;
	x_Locator_Locator_Name NUMBER ;
	x_Locator_Description NUMBER ;
	x_Enabled_Flag NUMBER ;
	x_Locator_DP NUMBER ;
	x_Locator_Name NUMBER ;
	x_Locator_Creation_Date NUMBER ;
	x_Locator_Last_Update_Date NUMBER ;
	x_Inventory_Location_ID NUMBER;
        x_Organization_ID NUMBER;
	x_Org_Code NUMBER;
	x_Org_Name NUMBER;
	x_Instance NUMBER;
	x_Stock_Room_Name_PK NUMBER;
	x_Stock_Room_Description NUMBER;
	x_Stock_Room_DP NUMBER;
	x_Stock_Room_Creation_Date NUMBER;
	x_Stock_Room_Last_Update_Date NUMBER;
        x_Plant_Last_Update_Date NUMBER;
	x_Plant_Creation_date NUMBER;
	x_PLANT_DP NUMBER;
	x_PLANT_NAME_ORG_Name NUMBER;
	x_OU_FK_OPM_ORG_FK NUMBER;
	x_total NUMBER := 0 ;
      x_ORGN_CODE  NUMBER;
      x_ORGN_NAME  NUMBER;
CURSOR c_1 IS	 -- Locator Level
    SELECT
	-- LOCATOR_PK needs to add instance_code and org_code
	avg(nvl(vsize(locf.inventory_location_id), 0)),
	-- INSTANCE_CODE, needs to instance_Code
	-- STOCK_ROOM_FK needs to add org_code and instance code
        avg(nvl(vsize(locf.SUBINVENTORY_CODE), 0)),
        -- Locator_Name needs to add org_code
        avg(nvl(vsize(locf.CONCATENATED_SEGMENTS), 0)),
	-- Description
        avg(nvl(vsize(locf.description), 0)),
        -- Enabled_Flag
        avg(nvl(vsize(locf.ENABLED_FLAG), 0)),
        -- Locator_DP
        --  length('LOCATOR'),
        7, -- for some strange reason, the package doesn't compile the length function here
        -- Name needs to add name
        avg(nvl(vsize(locf.CONCATENATED_SEGMENTS), 0)),
        -- Creation_Date
        avg(nvl(vsize(locf.creation_date), 0)),
        -- Last_Update_Date
        avg(nvl(vsize(locf.last_update_date), 0)),
	-- Inventory_Location_ID
        avg(nvl(vsize(locf.inventory_location_id), 0)),
	-- Organization_ID
        avg(nvl(vsize(locf.organization_id), 0))
    From
        mtl_item_locations_kfv locf;


CURSOR c_2 IS -- Organization_Code used in all levels: Locator, Stock_Room, Plant
              -- and Plant's Creation and Last_Update_Date
    Select
        -- Org_Code
        10*avg(nvl(vsize(mp.organization_code), 0)),
        -- Plant_Last_Update_Date
	avg(nvl(vsize(mp.last_update_date), 0)),
        -- Plant_Creation_date
 	avg(nvl(vsize(mp.creation_date), 0))
    From
        mtl_parameters mp;


CURSOR c_3 IS -- Part of Locator Name
    Select
       --  Org_Name
       avg(nvl(vsize(hou.name), 0))
    From
       hr_organization_units hou;


CURSOR c_4 IS -- Instance_Code used in all Levels: Locator, Stock_Room, Plant
    SELECT
        -- Instance
	15*avg(nvl(vsize(instance_code), 0))
    FROM EDW_LOCAL_INSTANCE ;

CURSOR c_5 IS  -- Stock_Room (Sub Inv) Level
    Select
	-- STOCK_ROOM_PK, needs to add org_code and instance_Code
	3*avg(nvl(vsize(msi.secondary_inventory_name), 0)),
	-- PLANT_FK, needs to add org_code and instance_Code
	-- INSTANCE_CODE, needs to instance_Code
	-- STOCK_ROOM, needs to add org_code
	-- avg(nvl(vsize(msi.secondary_inventory_name), 0)),
	-- DESCRIPTION
	avg(nvl(vsize(msi.description), 0)),
        -- STOCK_ROOM_DP
	length('SUB_INVENTORY'),
	-- NAME
	-- avg(nvl(vsize(msi.secondary_inventory_name), 0)),
	-- CREATION_DATE
	avg(nvl(vsize(msi.creation_date), 0)),
	-- LAST_UPDATE_DATE
	avg(nvl(vsize(msi.last_update_date), 0))
    From
        mtl_secondary_inventories msi;

CURSOR c_6 IS  -- Plant Level (Inv Org)
    Select
        -- PLANT_PK, it's org_code and instance_code
	-- INSTANCE_CODE, needs to instance_Code
	-- PLANT_DP
	length('PLANT'),
	-- NAME and Org_Name
	3*avg(nvl(vsize(bg.name), 0))
    From
	hr_all_organization_units bg;

CURSOR c_7 IS  -- Plant_Level (Inv Org)
    Select
	 -- OPERATING_UNIT_FK needs to add instance_code
	 -- OPM_ORGANIZATION_FK needs to add instance_code
	 2*avg(nvl(vsize(HOI.ORG_INFORMATION3), 0))
    From
	HR_ORGANIZATION_INFORMATION HOI;

 CURSOR c_8 IS
    SELECT avg(nvl(vsize(ORGN_CODE),0)) ORGN_CODE,
           avg(nvl(vsize(ORGN_NAME),0)) ORGN_NAME
    FROM SY_ORGN_MST;

BEGIN

  --dbms_output.put_line ('******************'||x_total||'******') ;
  OPEN c_1;
       FETCH c_1 INTO
        x_LOCATOR_PK,
	x_STOCK_ROOM_FK,
	x_Locator_Locator_Name,
	x_Locator_Description,
	x_Enabled_Flag,
	x_Locator_DP,
	x_Locator_Name,
	x_Locator_Creation_Date,
	x_Locator_Last_Update_Date,
	x_Inventory_Location_ID,
        x_Organization_ID;
  CLOSE c_1;

  x_total := 3 +
	    x_total +
	ceil(x_LOCATOR_PK + 1) +
	ceil(x_STOCK_ROOM_FK + 1) +
	ceil(x_Locator_Locator_Name + 1) +
	ceil(x_Locator_Description + 1) +
	ceil(x_Enabled_Flag + 1) +
	ceil(x_Locator_DP + 1) +
	ceil(x_Locator_Name + 1) +
	ceil(x_Locator_Creation_Date + 1) +
	ceil(x_Locator_Last_Update_Date + 1) +
	ceil(x_Inventory_Location_ID + 1) +
	ceil(x_Organization_ID + 1) ;

  --dbms_output.put_line ('******************'||x_total||'******') ;
  OPEN c_2;
       FETCH c_2 INTO
	x_Org_Code,
        x_Plant_Last_Update_Date,
	x_Plant_Creation_date;
  CLOSE c_2;

  x_total := x_total + ceil(x_Org_Code + 1) + ceil(x_Plant_Last_Update_Date + 1) + ceil(x_Plant_Creation_date + 1);


  --dbms_output.put_line ('******************'||x_total||'******') ;
  OPEN c_3;
       FETCH c_3 INTO
	x_Org_Name;
  CLOSE c_3;

  x_total := x_total + ceil(x_Org_Name + 1) ;


  --dbms_output.put_line ('******************'||x_total||'******') ;
  OPEN c_4;
       FETCH c_4 INTO
	x_Instance;
  CLOSE c_4;

  x_total := x_total + ceil(x_Instance  + 1) ;

  --dbms_output.put_line ('******************'||x_total||'******') ;
  OPEN c_5;
       FETCH c_5 INTO
	x_Stock_Room_Name_PK,
	x_Stock_Room_Description,
	x_Stock_Room_DP,
	x_Stock_Room_Creation_Date,
	x_Stock_Room_Last_Update_Date;
  CLOSE c_5;

  x_total := x_total +
       	ceil(x_Stock_Room_Name_PK + 1) +
	ceil(x_Stock_Room_Description + 1) +
	ceil(x_Stock_Room_DP + 1) +
	ceil(x_Stock_Room_Creation_Date + 1) +
	ceil(x_Stock_Room_Last_Update_Date + 1);

  --dbms_output.put_line ('******************'||x_total||'******') ;
  OPEN c_6;
       FETCH c_6 INTO
         x_PLANT_DP,
 	 x_PLANT_NAME_ORG_Name;
  Close c_6;

  x_total := x_total + ceil(x_PLANT_DP + 1) + ceil(x_PLANT_NAME_ORG_Name + 1);

  --dbms_output.put_line ('******************'||x_total||'******') ;
  OPEN c_7;
       FETCH c_7 INTO
	 x_OU_FK_OPM_ORG_FK;
  CLOSE c_7;

  x_total := x_total + ceil(x_OU_FK_OPM_ORG_FK + 1);

  OPEN c_8;
  FETCH c_8 INTO X_ORGN_CODE,X_ORGN_NAME;
  CLOSE c_8;
  -- Inventory Parent Group level

  x_total := x_total + 4 * ceil(x_ORGN_CODE+1) + 3 * ceil(x_ORGN_NAME+1) + 35;

  -- Inventory Group level
  x_total := x_total + 4 * ceil(x_ORGN_CODE+1) + 3 * ceil(x_ORGN_NAME+1) + 30;

  p_est_row_len := x_total ;

  --dbms_output.put_line ('******************'||x_total||'******') ;


END ;

END EDW_MTL_INVENTORY_LOC_M_SZ;  -- procedure est_row_len.

/
