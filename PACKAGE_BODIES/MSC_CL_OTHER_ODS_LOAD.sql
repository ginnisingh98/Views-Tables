--------------------------------------------------------
--  DDL for Package Body MSC_CL_OTHER_ODS_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_OTHER_ODS_LOAD" AS -- body
/* $Header: MSCLOTHB.pls 120.10.12010000.6 2010/03/24 07:19:23 vsiyer ship $ */


   PROCEDURE LOAD_SAFETY_STOCK IS

   CURSOR c1 IS
SELECT
  msss.ORGANIZATION_ID,
  t1.INVENTORY_ITEM_ID,             -- msss.INVENTORY_ITEM_ID,
  msss.PERIOD_START_DATE,
  msss.SAFETY_STOCK_QUANTITY,
  msss.UPDATED,
  msss.STATUS,
  msss.PROJECT_ID,
  msss.TASK_ID,
  msss.PLANNING_GROUP,
  msss.SR_INSTANCE_ID
FROM MSC_ITEM_ID_LID t1,
     MSC_ST_SAFETY_STOCKS msss
WHERE t1.SR_INVENTORY_ITEM_ID=        msss.inventory_item_id
  AND t1.sr_instance_id= msss.sr_instance_id
  AND msss.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

   c_count NUMBER:= 0;
    lv_ITEM_TYPE_VALUE            NUMBER;
    lv_ITEM_TYPE_ID               NUMBER;
   BEGIN

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

--MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SAFETY_STOCKS', MSC_CL_COLLECTION.v_instance_id, -1);

  IF MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SAFETY_STOCKS', MSC_CL_COLLECTION.v_instance_id, -1);
  ELSE
    MSC_CL_COLLECTION.v_sub_str :=' AND ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SAFETY_STOCKS', MSC_CL_COLLECTION.v_instance_id, -1,MSC_CL_COLLECTION.v_sub_str);
  END IF;

END IF;
	-- SRP enhancement
IF MSC_UTIL.G_COLLECT_SRP_DATA = 'Y' THEN
     lv_ITEM_TYPE_ID     := MSC_UTIL.G_PARTCONDN_ITEMTYPEID;
     lv_ITEM_TYPE_VALUE  :=  MSC_UTIL.G_PARTCONDN_GOOD;
ELSE
     lv_ITEM_TYPE_ID     := NULL;
     lv_ITEM_TYPE_VALUE  := NULL;
END IF;
c_count:= 0;

FOR c_rec IN c1 LOOP

BEGIN

IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

UPDATE MSC_SAFETY_STOCKS
SET
 SAFETY_STOCK_QUANTITY= c_rec.SAFETY_STOCK_QUANTITY,
 UPDATED= c_rec.UPDATED,
 STATUS= c_rec.STATUS,
 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user,
 ITEM_TYPE_ID    = lv_ITEM_TYPE_ID ,
 ITEM_TYPE_VALUE = lv_ITEM_TYPE_VALUE
WHERE PLAN_ID= -1
  AND ORGANIZATION_ID= c_rec.ORGANIZATION_ID
  AND INVENTORY_ITEM_ID= c_rec.INVENTORY_ITEM_ID
  AND PERIOD_START_DATE= c_rec.PERIOD_START_DATE
  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID;

END IF;

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

INSERT INTO MSC_SAFETY_STOCKS
( PLAN_ID,
  ORGANIZATION_ID,
  INVENTORY_ITEM_ID,
  PERIOD_START_DATE,
  SAFETY_STOCK_QUANTITY,
  UPDATED,
  STATUS,
  PROJECT_ID,
  TASK_ID,
  PLANNING_GROUP,
  SR_INSTANCE_ID,
  REFRESH_NUMBER,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY,
  ITEM_TYPE_ID,
  ITEM_TYPE_VALUE)
VALUES
( -1,
  c_rec.ORGANIZATION_ID,
  c_rec.INVENTORY_ITEM_ID,
  c_rec.PERIOD_START_DATE,
  c_rec.SAFETY_STOCK_QUANTITY,
  c_rec.UPDATED,
  c_rec.STATUS,
  c_rec.PROJECT_ID,
  c_rec.TASK_ID,
  c_rec.PLANNING_GROUP,
  c_rec.SR_INSTANCE_ID,
  MSC_CL_COLLECTION.v_last_collection_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  lv_ITEM_TYPE_ID,
  lv_ITEM_TYPE_VALUE
   );

END IF;

  c_count:= c_count+1;

  IF c_count> MSC_CL_COLLECTION.PBS THEN
     COMMIT;
     c_count:= 0;
  END IF;

EXCEPTION
   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SAFETY_STOCK');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SAFETY_STOCKS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SAFETY_STOCK');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SAFETY_STOCKS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'MSC_CL_ITEM_ODS_LOAD.ITEM_NAME');
      FND_MESSAGE.SET_TOKEN('VALUE', MSC_CL_ITEM_ODS_LOAD.ITEM_NAME( c_rec.INVENTORY_ITEM_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
      FND_MESSAGE.SET_TOKEN('VALUE',
                            MSC_GET_NAME.ORG_CODE( c_rec.ORGANIZATION_ID,
                                                   MSC_CL_COLLECTION.v_instance_id));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'PERIOD_START_DATE');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.PERIOD_START_DATE));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'PROJECT_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.PROJECT_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'TASK_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.TASK_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;

COMMIT;

   END LOAD_SAFETY_STOCK;



--==================================================================

   PROCEDURE LOAD_SOURCING IS

   CURSOR c1 IS
SELECT
  msas.SR_ASSIGNMENT_SET_ID,
  msas.DESCRIPTION,
  msas.ASSIGNMENT_SET_NAME,
  msas.SR_INSTANCE_ID
FROM MSC_ST_ASSIGNMENT_SETS msas
WHERE msas.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

   CURSOR c2 IS
 SELECT
  mssr.ORGANIZATION_ID,
  mssr.SR_SOURCING_RULE_ID,
  mssr.SOURCING_RULE_NAME,
  substrb(mssr.DESCRIPTION,1,80) DESCRIPTION,--added for the NLS bug3463401
  mssr.STATUS,
  mssr.SOURCING_RULE_TYPE,
  mssr.PLANNING_ACTIVE,
  mssr.SR_INSTANCE_ID
FROM MSC_ST_SOURCING_RULES mssr
WHERE mssr.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

   CURSOR c3 IS
SELECT
  mssa.SR_ASSIGNMENT_ID,
  mas.ASSIGNMENT_SET_ID,
  mssa.ASSIGNMENT_TYPE,
  msr.SOURCING_RULE_ID,
  mssa.SOURCING_RULE_TYPE,
  miil.INVENTORY_ITEM_ID,
  mtil.TP_ID,
  mtsil.TP_SITE_ID,
  mcsil.Category_Set_ID,
  mssa.ORGANIZATION_ID,
  mssa.SR_INSTANCE_ID,
  mssa.CATEGORY_NAME,
  mssa.SR_ASSIGNMENT_INSTANCE_ID
FROM MSC_ITEM_ID_LID miil,
     MSC_TP_ID_LID mtil,
     MSC_TP_SITE_ID_LID mtsil,
     MSC_CATEGORY_SET_ID_LID mcsil,
     MSC_Assignment_SETS mas,
     MSC_Sourcing_Rules msr,
     MSC_ST_SR_ASSIGNMENTS mssa
WHERE mas.SR_ASSIGNMENT_SET_ID= mssa.ASSIGNMENT_SET_ID           -- Assignment Set
  AND mas.SR_INSTANCE_ID= mssa.SR_ASSIGNMENT_INSTANCE_ID
  AND msr.SR_SOURCING_RULE_ID= mssa.SOURCING_RULE_ID             -- Sourcing Rule
  AND msr.SR_INSTANCE_ID= mssa.SR_ASSIGNMENT_INSTANCE_ID
  AND mtsil.SR_TP_SITE_ID(+)= mssa.SHIP_TO_SITE_ID               -- Ship to Site
  AND mtsil.SR_Instance_ID(+)= mssa.SR_ASSIGNMENT_Instance_ID
  AND mtsil.Partner_Type(+)=2
  AND mcsil.SR_Category_Set_ID(+)= mssa.Category_Set_Identifier  -- Category Set
  AND mcsil.SR_Instance_ID(+)= mssa.SR_ASSIGNMENT_Instance_ID
  AND miil.SR_INVENTORY_ITEM_ID(+)= mssa.INVENTORY_ITEM_ID       -- ITEM
  AND miil.SR_INSTANCE_ID(+)= mssa.SR_ASSIGNMENT_INSTANCE_ID
  AND mtil.SR_TP_ID(+)= mssa.PARTNER_ID                          -- TP
  AND mtil.SR_INSTANCE_ID(+)= mssa.SR_ASSIGNMENT_INSTANCE_ID
  AND mtil.Partner_Type(+)= 2
  AND mssa.SR_ASSIGNMENT_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND
  (
    EXISTS
    (
    select 1 from msc_item_id_lid miil1
    where miil1.SR_INVENTORY_ITEM_ID=mssa.INVENTORY_ITEM_ID AND
          miil1.SR_INSTANCE_ID=mssa.SR_ASSIGNMENT_INSTANCE_ID AND
          mssa.assignment_type in (3,6)
    )
  OR
    EXISTS
    (
    select 1 from MSC_CATEGORY_SET_ID_LID mcsil1
    where mcsil1.SR_Category_Set_ID= mssa.Category_Set_Identifier AND
          mcsil1.SR_Instance_ID= mssa.SR_ASSIGNMENT_Instance_ID AND
          mssa.assignment_type in (2,5)
    )
  OR
    mssa.assignment_type not in (2,3,5,6)
  );

   CURSOR c4 IS
SELECT
  mssro.SR_RECEIPT_ID,
  mssro.SR_SR_RECEIPT_ORG,
  mssro.RECEIPT_ORG_INSTANCE_ID,
  msr.SOURCING_RULE_ID,
  mssro.RECEIPT_PARTNER_ID,
  mssro.RECEIPT_PARTNER_SITE_ID,
  mssro.EFFECTIVE_DATE,
  mssro.DISABLE_DATE,
  mssro.SR_INSTANCE_ID
FROM MSC_Sourcing_Rules msr,
     MSC_ST_SR_RECEIPT_ORG mssro
WHERE msr.SR_SOURCING_RULE_ID= mssro.SOURCING_RULE_ID
  AND msr.SR_INSTANCE_ID= mssro.SR_INSTANCE_ID
  AND mssro.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;


   CURSOR c5 IS
SELECT
  mssso.SR_SR_SOURCE_ID,
  msro.SR_RECEIPT_ID,             -- mssso.SR_RECEIPT_ID,
  mssso.Source_Organization_ID,
  mssso.SOURCE_ORG_INSTANCE_ID,
  mtil.TP_ID,                     -- mssso.SOURCE_PARTNER_ID,
  mtsil.TP_SITE_ID,               -- mssso.SOURCE_PARTNER_SITE_ID,
  mssso.ALLOCATION_PERCENT,
  mssso.RANK,
  mssso.SR_INSTANCE_ID,
  mssso.SHIP_METHOD,
  mssso.SOURCE_TYPE
FROM MSC_TP_ID_LID mtil,
     MSC_TP_SITE_ID_LID mtsil,
     MSC_SR_Receipt_Org msro,
     MSC_ST_SR_SOURCE_ORG mssso
WHERE msro.SR_SR_RECEIPT_ID= mssso.SR_RECEIPT_ID
  AND msro.SR_Instance_ID= mssso.SR_Instance_ID
  AND mtil.SR_TP_ID(+)= mssso.SOURCE_PARTNER_ID
  AND mtil.SR_INSTANCE_ID(+)= mssso.SR_INSTANCE_ID
  AND mtil.Partner_Type(+)= 1
  AND mtsil.SR_TP_SITE_ID(+)= mssso.SOURCE_PARTNER_SITE_ID
  AND mtsil.SR_INSTANCE_ID(+)= mssso.SR_Instance_ID
  AND mtsil.Partner_Type(+)= 1
  AND mssso.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

   CURSOR c6 IS
SELECT
   NVL(msism.FROM_ORGANIZATION_ID,-1) FROM_ORGANIZATION_ID,
   NVL(msism.TO_ORGANIZATION_ID,-1) TO_ORGANIZATION_ID,
   msism.SHIP_METHOD,
   msism.SHIP_METHOD_TEXT,
   msism.TIME_UOM_CODE,
   NVL(msism.DEFAULT_FLAG,2) DEFAULT_FLAG,
   NVL(msism.FROM_LOCATION_ID,-1) FROM_LOCATION_ID,
   NVL(msism.TO_LOCATION_ID,-1) TO_LOCATION_ID,
   msism.WEIGHT_CAPACITY,
   msism.WEIGHT_UOM,
   msism.VOLUME_CAPACITY,
   msism.VOLUME_UOM,
   msism.COST_PER_WEIGHT_UNIT,
   msism.COST_PER_VOLUME_UNIT,
   msism.INTRANSIT_TIME,
   msism.TO_REGION_ID,
   msism.FROM_REGION_ID,
   msism.CURRENCY,
   msism.TRANSPORT_CAP_OVER_UTIL_COST,
   msism.SR_INSTANCE_ID,
   msism.SR_INSTANCE_ID2,      -- to_org
   msism.SHIPMENT_WEIGHT,
   msism.SHIPMENT_VOLUME,
   msism.SHIPMENT_WEIGHT_UOM,
   msism.SHIPMENT_VOLUME_UOM,
   msism.LEADTIME_VARIABILITY
FROM MSC_ST_INTERORG_SHIP_METHODS msism
WHERE msism.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;
/* Changed Refresh_id to Refresh_Number */
  CURSOR c7 IS
SELECT msr.REGION_ID,
   msr.REGION_TYPE,
   msr.PARENT_REGION_ID,
   msr.COUNTRY_CODE,
   msr.COUNTRY_REGION_CODE,
   msr.STATE_CODE,
   msr.CITY_CODE,
   msr.PORT_FLAG,
   msr.AIRPORT_FLAG,
   msr.ROAD_TERMINAL_FLAG,
   msr.RAIL_TERMINAL_FLAG,
   msr.LONGITUDE,
   msr.LATITUDE,
   msr.TIMEZONE,
   msr.CREATED_BY,
   msr.CREATION_DATE,
   msr.LAST_UPDATED_BY,
   msr.LAST_UPDATE_DATE,
   msr.LAST_UPDATE_LOGIN,
   msr.CONTINENT,
   msr.COUNTRY,
   msr.COUNTRY_REGION,
   msr.STATE,
   msr.CITY,
   msr.ZONE,
   msr.ZONE_LEVEL,
   msr.POSTAL_CODE_FROM,
   msr.POSTAL_CODE_TO,
   msr.ALTERNATE_NAME,
   msr.COUNTY,
   msr.SR_INSTANCE_ID,
   msr.REFRESH_NUMBER,
   msr.ZONE_USAGE
FROM MSC_ST_REGIONS msr
WHERE msr.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

/* Changed Refresh_id to Refresh_number */
 CURSOR c8 IS
SELECT mszr.ZONE_REGION_ID,
   mszr.REGION_ID,
   mszr.PARENT_REGION_ID,
   mszr.PARTY_ID,
   mszr.CREATED_BY,
   mszr.CREATION_DATE,
   mszr.LAST_UPDATED_BY,
   mszr.LAST_UPDATE_DATE,
   mszr.LAST_UPDATE_LOGIN,
   mszr.SR_INSTANCE_ID,
   mszr.REFRESH_NUMBER
FROM MSC_ST_ZONE_REGIONS mszr
WHERE mszr.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;
/* Changed Refresh_id to Refresh_number */
CURSOR c9 IS
SELECT
   msrl.REGION_ID,
   msrl.LOCATION_ID,
   msrl.REGION_TYPE,
   msrl.PARENT_REGION_FLAG,
   msrl.LOCATION_SOURCE,
   msrl.EXCEPTION_TYPE,
   msrl.CREATED_BY,
   msrl.CREATION_DATE,
   msrl.LAST_UPDATED_BY,
   msrl.LAST_UPDATE_DATE,
   msrl.LAST_UPDATE_LOGIN,
   msrl.SR_INSTANCE_ID,
   msrl.REFRESH_NUMBER
FROM  MSC_ST_REGION_LOCATIONS msrl
WHERE msrl.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

CURSOR c10 IS
SELECT DISTINCT
   msrs.REGION_ID,
   mtsil.TP_SITE_ID,
   msrs.REGION_TYPE,
   msrs.ZONE_LEVEL,
   msrs.SR_INSTANCE_ID,
   msrs.REFRESH_ID
FROM  MSC_ST_REGION_SITES msrs,
      MSC_TP_SITE_ID_LID mtsil
WHERE msrs.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND mtsil.SR_TP_SITE_ID = msrs.VENDOR_SITE_ID
  AND mtsil.SR_Instance_ID = msrs.SR_INSTANCE_ID
  AND mtsil.Partner_Type = 1;

CURSOR c11 IS
SELECT
   mscs.SHIP_METHOD_CODE,
   mtil.TP_ID,
   mscs.SERVICE_LEVEL,
   mscs.MODE_OF_TRANSPORT,
   mscs.SR_INSTANCE_ID,
   mscs.REFRESH_ID
FROM  MSC_ST_CARRIER_SERVICES mscs,
      MSC_TP_ID_LID mtil
WHERE mscs.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND mtil.SR_TP_ID = mscs.CARRIER_ID
  AND mtil.SR_Instance_ID = mscs.SR_INSTANCE_ID
  AND mtil.Partner_Type = 4;

   c_count NUMBER:= 0;

  TYPE CharTblTyp IS TABLE OF VARCHAR2(250);
  TYPE NumTblTyp  IS TABLE OF NUMBER;
  TYPE dateTblTyp IS TABLE OF DATE;
  lb_SR_ASSIGNMENT_ID                 NumTblTyp;
  lb_ASSIGNMENT_SET_ID                NumTblTyp;
  lb_ASSIGNMENT_TYPE                  NumTblTyp;
  lb_SOURCING_RULE_ID                 NumTblTyp;
  lb_SOURCING_RULE_TYPE               NumTblTyp;
  lb_INVENTORY_ITEM_ID                NumTblTyp;
  lb_TP_ID                            NumTblTyp;
  lb_TP_SITE_ID                       NumTblTyp;
  lb_Category_Set_ID                  NumTblTyp;
  lb_ORGANIZATION_ID                  NumTblTyp;
  lb_SR_INSTANCE_ID                   NumTblTyp;
  lb_category_name                    CharTblTyp;
  lb_SR_ASSIGNMENT_INSTANCE_ID        NumTblTyp;
  lb_FetchComplete  Boolean;
  ln_rows_to_fetch  Number := nvl(TO_NUMBER( FND_PROFILE.VALUE('MRP_PURGE_BATCH_SIZE')),75000);


   lv_control_flag NUMBER;
   lv_msc_tp_coll_window     NUMBER;
   lv_sql_stmt     	     VARCHAR2(4000);

   i                      NUMBER := -1; -- added for 6643314
   lv_crt_ind_status	    NUMBER;
   BEGIN

--/* it's removed due to bug 1219661
IF ((MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh)
                             AND MSC_CL_COLLECTION.v_sourcing_flag=MSC_UTIL.SYS_YES ) THEN

UPDATE MSC_ASSIGNMENT_SETS
   SET DELETED_FLAG= MSC_UTIL.SYS_YES,
       LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
       LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND COLLECTED_FLAG= MSC_UTIL.SYS_YES;

END IF;

COMMIT;
--*/

c_count:= 0;

FOR c_rec IN c1 LOOP

BEGIN

UPDATE MSC_ASSIGNMENT_SETS mas
   SET mas.ASSIGNMENT_SET_NAME=c_rec.ASSIGNMENT_SET_NAME,
       mas.Description= c_rec.Description,
       mas.Deleted_Flag= MSC_UTIL.SYS_NO,
       REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
       LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
       LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
 WHERE mas.SR_Assignment_Set_Id= c_rec.SR_Assignment_Set_Id
   AND mas.SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
   AND COLLECTED_FLAG= MSC_UTIL.SYS_YES;

  IF SQL%NOTFOUND THEN

INSERT INTO MSC_ASSIGNMENT_SETS
( ASSIGNMENT_SET_ID,
  SR_ASSIGNMENT_SET_ID,
  DESCRIPTION,
  ASSIGNMENT_SET_NAME,
  COLLECTED_FLAG,
  SR_INSTANCE_ID,
  DELETED_FLAG,
  REFRESH_NUMBER,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
( MSC_ASSIGNMENT_SETS_S.NEXTVAL,
  c_rec.SR_ASSIGNMENT_SET_ID,
  c_rec.DESCRIPTION,
  c_rec.ASSIGNMENT_SET_NAME,
  MSC_UTIL.SYS_YES,
  c_rec.SR_INSTANCE_ID,
  MSC_UTIL.SYS_NO,
  MSC_CL_COLLECTION.v_last_collection_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user);

  END IF;

  c_count:= c_count+1;

  IF c_count> MSC_CL_COLLECTION.PBS THEN
     COMMIT;
     c_count:= 0;
  END IF;

EXCEPTION
   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ASSIGNMENT_SETS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE

      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ASSIGNMENT_SETS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ASSIGNMENT_SET_NAME');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.ASSIGNMENT_SET_NAME);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'SR_ASSIGNMENT_SET_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.SR_ASSIGNMENT_SET_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;

COMMIT;

--/* it's removed due to bug 1219661
DELETE MSC_ASSIGNMENT_SETS
WHERE DELETED_FLAG= MSC_UTIL.SYS_YES
  AND SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND COLLECTED_FLAG= MSC_UTIL.SYS_YES;

COMMIT;
--*/

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

  msc_analyse_tables_pk.analyse_table( 'MSC_ASSIGNMENT_SETS');

END IF;

--/* it's removed due to bug 1219661
IF ((MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh)
                     AND MSC_CL_COLLECTION.v_sourcing_flag =MSC_UTIL.SYS_YES) THEN

UPDATE MSC_SOURCING_RULES
   SET DELETED_FLAG= MSC_UTIL.SYS_YES,
       LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
       LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND COLLECTED_FLAG= MSC_UTIL.SYS_YES;

END IF;

COMMIT;
--*/

c_count:= 0;

FOR c_rec IN c2 LOOP

BEGIN

UPDATE MSC_SOURCING_RULES msr
   SET msr.Description= c_rec.Description,
       msr.Status= c_rec.Status,
       msr.Sourcing_Rule_Type= c_rec.Sourcing_Rule_Type,
       msr.sourcing_rule_name= c_rec.sourcing_rule_name,
       msr.Planning_Active= c_rec.Planning_Active,
       msr.Deleted_Flag= MSC_UTIL.SYS_NO,
       REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
       LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
       LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user,
       CREATION_DATE= MSC_CL_COLLECTION.v_current_date,
       CREATED_BY= MSC_CL_COLLECTION.v_current_user
 WHERE msr.SR_Sourcing_Rule_ID= c_rec.SR_Sourcing_Rule_ID
   AND msr.SR_Instance_ID= c_rec.SR_Instance_ID
   AND msr.COLLECTED_FLAG= MSC_UTIL.SYS_YES;

  IF SQL%NOTFOUND THEN

INSERT INTO MSC_SOURCING_RULES
( ORGANIZATION_ID,
  SOURCING_RULE_ID,
  SR_SOURCING_RULE_ID,
  SOURCING_RULE_NAME,
  DESCRIPTION,
  STATUS,
  SOURCING_RULE_TYPE,
  PLANNING_ACTIVE,
  COLLECTED_FLAG,
  SR_INSTANCE_ID,
  DELETED_FLAG,
  REFRESH_NUMBER,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
( c_rec.ORGANIZATION_ID,
  MSC_SOURCING_RULES_S.NEXTVAL,
  c_rec.SR_SOURCING_RULE_ID,
  c_rec.SOURCING_RULE_NAME,
  c_rec.DESCRIPTION,
  c_rec.STATUS,
  c_rec.SOURCING_RULE_TYPE,
  c_rec.PLANNING_ACTIVE,
  MSC_UTIL.SYS_YES,
  c_rec.SR_INSTANCE_ID,
  MSC_UTIL.SYS_NO,
  MSC_CL_COLLECTION.v_last_collection_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user);

  END IF;

  c_count:= c_count+1;

  IF c_count> MSC_CL_COLLECTION.PBS THEN
     COMMIT;
     c_count:= 0;
  END IF;

EXCEPTION
   WHEN OTHERS THEN
    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SOURCING_RULES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SOURCING_RULES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'SOURCING_RULE_NAME');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.SOURCING_RULE_NAME);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;

COMMIT;

--/* it's removed due to bug 1219661
DELETE MSC_SOURCING_RULES
 WHERE DELETED_FLAG= MSC_UTIL.SYS_YES
   AND SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
   AND COLLECTED_FLAG= MSC_UTIL.SYS_YES;

COMMIT;
--*/

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh)  THEN

  msc_analyse_tables_pk.analyse_table( 'MSC_SOURCING_RULES');

END IF;

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh)  THEN

UPDATE MSC_SR_ASSIGNMENTS
   SET DELETED_FLAG= MSC_UTIL.SYS_YES,
       LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
       LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE SR_ASSIGNMENT_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND COLLECTED_FLAG= MSC_UTIL.SYS_YES;

END IF;

COMMIT;


OPEN  c3;

IF (c3%ISOPEN) THEN
  LOOP

  --
  -- Retrieve the next set of rows if we are currently not in the
  -- middle of processing a fetched set or rows.
  --
  IF (lb_FetchComplete) THEN
    EXIT;
  END IF;

  -- Fetch the next set of rows
  FETCH c3 BULK COLLECT INTO     lb_SR_ASSIGNMENT_ID,
                                        lb_ASSIGNMENT_SET_ID,
                                        lb_ASSIGNMENT_TYPE,
                                        lb_SOURCING_RULE_ID,
                                        lb_SOURCING_RULE_TYPE,
                                        lb_INVENTORY_ITEM_ID,
                                        lb_TP_ID,
                                        lb_TP_SITE_ID,
                                        lb_Category_Set_ID,
                                        lb_ORGANIZATION_ID,
                                        lb_SR_INSTANCE_ID,
                                        lb_category_name,
                                        lb_SR_ASSIGNMENT_INSTANCE_ID
  LIMIT ln_rows_to_fetch;

  -- Since we are only fetching records if either (1) this is the first
  -- fetch or (2) the previous fetch did not retrieve all of the
  -- records, then at least one row should always be fetched.  But
  -- checking just to make sure.
  EXIT WHEN lb_SR_ASSIGNMENT_ID.count = 0;

  -- Check if all of the rows have been fetched.  If so, indicate that
  -- the fetch is complete so that another fetch is not made.
  -- Additional check is introduced for the following reasons
  -- In 9i, the table of records gets modified but in 8.1.6 the table of records is
  -- unchanged after the fetch(bug#2995144)

  IF (c3%NOTFOUND) THEN
    lb_FetchComplete := TRUE;
  END IF;

BEGIN

FORALL j IN lb_SR_ASSIGNMENT_ID.FIRST..lb_SR_ASSIGNMENT_ID.LAST

UPDATE MSC_SR_ASSIGNMENTS msa
   SET msa.ASSIGNMENT_TYPE    = lb_ASSIGNMENT_TYPE(j),
       msa.SOURCING_RULE_ID   = lb_SOURCING_RULE_ID(j),
       msa.SOURCING_RULE_TYPE = lb_SOURCING_RULE_TYPE(j),
       msa.INVENTORY_ITEM_ID  = lb_INVENTORY_ITEM_ID(j),
       msa.PARTNER_ID         = lb_TP_ID(j),
       msa.SHIP_TO_SITE_ID    = lb_TP_SITE_ID(j),
       msa.CATEGORY_SET_ID    = lb_Category_Set_ID(j),
       msa.ORGANIZATION_ID    = lb_ORGANIZATION_ID(j),
       msa.SR_INSTANCE_ID     = lb_SR_INSTANCE_ID(j),
       msa.CATEGORY_NAME      = lb_category_name(j),
       msa.Deleted_Flag= MSC_UTIL.SYS_NO,
       REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
       LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
       LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user,
       CREATION_DATE= MSC_CL_COLLECTION.v_current_date,
       CREATED_BY= MSC_CL_COLLECTION.v_current_user
 WHERE msa.SR_Assignment_ID= lb_SR_ASSIGNMENT_ID(j)
   AND msa.SR_Assignment_Instance_ID= lb_SR_ASSIGNMENT_INSTANCE_ID(j)
   AND msa.COLLECTED_FLAG= MSC_UTIL.SYS_YES;

 EXCEPTION
   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SR_ASSIGNMENTS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE

      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SR_ASSIGNMENTS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

  END;
  commit;
  END LOOP;
 END IF;
CLOSE c3;

BEGIN


INSERT /*+ APPEND  */
INTO MSC_SR_ASSIGNMENTS
( ASSIGNMENT_ID,
  SR_ASSIGNMENT_ID,
  ASSIGNMENT_SET_ID,
  ASSIGNMENT_TYPE,
  SOURCING_RULE_ID,
  SOURCING_RULE_TYPE,
  INVENTORY_ITEM_ID,
  PARTNER_ID,
  SHIP_TO_SITE_ID,
  CATEGORY_SET_ID,
  ORGANIZATION_ID,
  SR_INSTANCE_ID,
  CATEGORY_NAME,
  COLLECTED_FLAG,
  SR_ASSIGNMENT_INSTANCE_ID,
  DELETED_FLAG,
  REFRESH_NUMBER,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
SELECT
  MSC_SR_ASSIGNMENTS_S.NEXTVAL,
  mssa.SR_ASSIGNMENT_ID,
  mas.ASSIGNMENT_SET_ID,
  mssa.ASSIGNMENT_TYPE,
  msr.SOURCING_RULE_ID,
  mssa.SOURCING_RULE_TYPE,
  miil.INVENTORY_ITEM_ID,
  mtil.TP_ID,
  mtsil.TP_SITE_ID,
  mcsil.Category_Set_ID,
  mssa.ORGANIZATION_ID,
  mssa.SR_INSTANCE_ID,
  mssa.CATEGORY_NAME,
  MSC_UTIL.SYS_YES,
  mssa.SR_ASSIGNMENT_INSTANCE_ID,
  MSC_UTIL.SYS_NO,
  MSC_CL_COLLECTION.v_last_collection_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user
FROM MSC_ITEM_ID_LID miil,
     MSC_TP_ID_LID mtil,
     MSC_TP_SITE_ID_LID mtsil,
     MSC_CATEGORY_SET_ID_LID mcsil,
     MSC_Assignment_SETS mas,
     MSC_Sourcing_Rules msr,
     MSC_ST_SR_ASSIGNMENTS mssa
WHERE mas.SR_ASSIGNMENT_SET_ID= mssa.ASSIGNMENT_SET_ID           -- Assignment Set
  AND mas.SR_INSTANCE_ID= mssa.SR_ASSIGNMENT_INSTANCE_ID
  AND msr.SR_SOURCING_RULE_ID= mssa.SOURCING_RULE_ID             -- Sourcing Rule
  AND msr.SR_INSTANCE_ID= mssa.SR_ASSIGNMENT_INSTANCE_ID
  AND mtsil.SR_TP_SITE_ID(+)= mssa.SHIP_TO_SITE_ID               -- Ship to Site
  AND mtsil.SR_Instance_ID(+)= mssa.SR_ASSIGNMENT_Instance_ID
  AND mtsil.Partner_Type(+)=2
  AND mcsil.SR_Category_Set_ID(+)= mssa.Category_Set_Identifier  -- Category Set
  AND mcsil.SR_Instance_ID(+)= mssa.SR_ASSIGNMENT_Instance_ID
  AND miil.SR_INVENTORY_ITEM_ID(+)= mssa.INVENTORY_ITEM_ID       -- ITEM
  AND miil.SR_INSTANCE_ID(+)= mssa.SR_ASSIGNMENT_INSTANCE_ID
  AND mtil.SR_TP_ID(+)= mssa.PARTNER_ID                          -- TP
  AND mtil.SR_INSTANCE_ID(+)= mssa.SR_ASSIGNMENT_INSTANCE_ID
  AND mtil.Partner_Type(+)= 2
  AND mssa.SR_ASSIGNMENT_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND
  (
    EXISTS
    (
    select 1 from msc_item_id_lid miil1
    where miil1.SR_INVENTORY_ITEM_ID=mssa.INVENTORY_ITEM_ID AND
          miil1.SR_INSTANCE_ID=mssa.SR_ASSIGNMENT_INSTANCE_ID AND
          mssa.assignment_type in (3,6)
    )
  OR
    EXISTS
    (
    select 1 from MSC_CATEGORY_SET_ID_LID mcsil1
    where mcsil1.SR_Category_Set_ID= mssa.Category_Set_Identifier AND
          mcsil1.SR_Instance_ID= mssa.SR_ASSIGNMENT_Instance_ID AND
          mssa.assignment_type in (2,5)
    )
  OR
    mssa.assignment_type not in (2,3,5,6)
  )
  AND not exists (select 1
                  from   MSC_SR_ASSIGNMENTS msa2
                  where  msa2.SR_Assignment_ID          = mssa.SR_Assignment_ID
                  AND    msa2.SR_Assignment_Instance_ID = mssa.SR_Assignment_Instance_ID
                  AND    msa2.collected_flag            = MSC_UTIL.SYS_YES);

EXCEPTION
   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SR_ASSIGNMENTS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE

      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SR_ASSIGNMENTS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;


COMMIT;

DELETE MSC_SR_ASSIGNMENTS
 WHERE DELETED_FLAG= MSC_UTIL.SYS_YES
   AND SR_ASSIGNMENT_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
   AND COLLECTED_FLAG= MSC_UTIL.SYS_YES;

COMMIT;

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh)  THEN

  msc_analyse_tables_pk.analyse_table( 'MSC_SR_ASSIGNMENTS');

END IF;

--/* it's removed due to bug 1219661
IF ((MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh)
                               AND MSC_CL_COLLECTION.v_sourcing_flag=MSC_UTIL.SYS_YES ) THEN

UPDATE MSC_SR_RECEIPT_ORG
  SET DELETED_FLAG= MSC_UTIL.SYS_YES,
       LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
       LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND COLLECTED_FLAG= MSC_UTIL.SYS_YES;

END IF;

COMMIT;
--*/

c_count:= 0;

FOR c_rec IN c4 LOOP

BEGIN

UPDATE MSC_SR_RECEIPT_ORG msro
   SET msro.SR_RECEIPT_ORG= c_rec.SR_SR_Receipt_Org,
       msro.RECEIPT_ORG_INSTANCE_ID= c_rec.RECEIPT_ORG_INSTANCE_ID,
       msro.SOURCING_RULE_ID= c_rec.Sourcing_Rule_ID,
       msro.RECEIPT_PARTNER_ID= c_rec.Receipt_Partner_ID,
       msro.RECEIPT_PARTNER_SITE_ID= c_rec.Receipt_Partner_Site_ID,
       msro.EFFECTIVE_DATE= c_rec.Effective_Date,
       msro.DISABLE_DATE= c_rec.Disable_Date,
       msro.Deleted_Flag= MSC_UTIL.SYS_NO,
       REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
       LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
       LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user,
       CREATION_DATE= MSC_CL_COLLECTION.v_current_date,
       CREATED_BY= MSC_CL_COLLECTION.v_current_user
 WHERE msro.SR_SR_Receipt_ID= c_rec.SR_Receipt_ID
   AND msro.SR_Instance_ID= c_rec.SR_Instance_ID
   AND msro.COLLECTED_FLAG= MSC_UTIL.SYS_YES;

  IF SQL%NOTFOUND THEN

INSERT INTO MSC_SR_RECEIPT_ORG
( SR_RECEIPT_ID,
  SR_SR_RECEIPT_ID,
  SR_RECEIPT_ORG,
  RECEIPT_ORG_INSTANCE_ID,
  SOURCING_RULE_ID,
  RECEIPT_PARTNER_ID,
  RECEIPT_PARTNER_SITE_ID,
  EFFECTIVE_DATE,
  DISABLE_DATE,
  COLLECTED_FLAG,
  SR_INSTANCE_ID,
  DELETED_FLAG,
  REFRESH_NUMBER,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
( MSC_SR_RECEIPT_ORG_S.NEXTVAL,
  c_rec.SR_RECEIPT_ID,
  c_rec.SR_SR_RECEIPT_ORG,
  c_rec.RECEIPT_ORG_INSTANCE_ID,
  c_rec.SOURCING_RULE_ID,
  c_rec.RECEIPT_PARTNER_ID,
  c_rec.RECEIPT_PARTNER_SITE_ID,
  c_rec.EFFECTIVE_DATE,
  c_rec.DISABLE_DATE,
  MSC_UTIL.SYS_YES,
  c_rec.SR_INSTANCE_ID,
  MSC_UTIL.SYS_NO,
  MSC_CL_COLLECTION.v_last_collection_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user);

   END IF;

  c_count:= c_count+1;

  IF c_count> MSC_CL_COLLECTION.PBS THEN
     COMMIT;
     c_count:= 0;
  END IF;

EXCEPTION

   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SR_RECEIPT_ORG');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SR_RECEIPT_ORG');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'SR_RECEIPT_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.SR_RECEIPT_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;   -- c4

COMMIT;

--/* it's removed due to bug 1219661
DELETE MSC_SR_RECEIPT_ORG
 WHERE DELETED_FLAG= MSC_UTIL.SYS_YES
   AND SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
   AND COLLECTED_FLAG= MSC_UTIL.SYS_YES;

COMMIT;
--*/

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

  msc_analyse_tables_pk.analyse_table( 'MSC_SR_RECEIPT_ORG');

END IF;

--/* it's removed due to bug 1219661
IF ((MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh)
                               AND MSC_CL_COLLECTION.v_sourcing_flag=MSC_UTIL.SYS_YES ) THEN

UPDATE MSC_SR_SOURCE_ORG
   SET DELETED_FLAG= MSC_UTIL.SYS_YES,
       LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
       LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND COLLECTED_FLAG= MSC_UTIL.SYS_YES;

END IF;

COMMIT;
--*/

c_count:= 0;

FOR c_rec IN c5 LOOP

BEGIN

UPDATE MSC_SR_SOURCE_ORG msso
   SET msso.SR_RECEIPT_ID= c_rec.SR_Receipt_ID,
       msso.SOURCE_ORGANIZATION_ID= c_rec.Source_Organization_ID,
       msso.SOURCE_ORG_INSTANCE_ID= c_rec.SOURCE_ORG_INSTANCE_ID,
       msso.SOURCE_PARTNER_ID= c_rec.TP_ID,
       msso.SOURCE_PARTNER_SITE_ID= c_rec.TP_Site_ID,
       msso.ALLOCATION_PERCENT= c_rec.Allocation_percent,
       msso.RANK= c_rec.Rank,
       msso.SHIP_METHOD= c_rec.Ship_Method,
       msso.SOURCE_TYPE= c_rec.Source_Type,
       msso.Deleted_Flag= MSC_UTIL.SYS_NO,
       REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
       LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
       LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
 WHERE msso.SR_SR_SOURCE_ID= c_rec.SR_SR_SOURCE_ID
   AND msso.SR_Instance_ID= c_rec.SR_Instance_ID
   AND msso.COLLECTED_FLAG= MSC_UTIL.SYS_YES;

  IF SQL%NOTFOUND THEN

INSERT INTO MSC_SR_SOURCE_ORG
( SR_SOURCE_ID,
  SR_SR_SOURCE_ID,
  SR_RECEIPT_ID,
  SOURCE_ORGANIZATION_ID,
  SOURCE_ORG_INSTANCE_ID,
  SOURCE_PARTNER_ID,
  SOURCE_PARTNER_SITE_ID,
  ALLOCATION_PERCENT,
  RANK,
  COLLECTED_FLAG,
  SR_INSTANCE_ID,
  DELETED_FLAG,
  SHIP_METHOD,
  SOURCE_TYPE,
  REFRESH_NUMBER,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
( MSC_SR_SOURCE_ORG_S.NEXTVAL,
  c_rec.SR_SR_SOURCE_ID,
  c_rec.SR_RECEIPT_ID,
  c_rec.Source_Organization_ID,
  c_rec.SOURCE_ORG_INSTANCE_ID,
  c_rec.TP_ID,
  c_rec.TP_SITE_ID,
  c_rec.ALLOCATION_PERCENT,
  c_rec.RANK,
  MSC_UTIL.SYS_YES,
  c_rec.SR_INSTANCE_ID,
  MSC_UTIL.SYS_NO,
  c_rec.SHIP_METHOD,
  c_rec.SOURCE_TYPE,
  MSC_CL_COLLECTION.v_last_collection_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user);

   END IF;

  c_count:= c_count+1;

  IF c_count> MSC_CL_COLLECTION.PBS THEN
     COMMIT;
     c_count:= 0;
  END IF;

EXCEPTION

   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SR_SOURCE_ORG');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SR_SOURCE_ORG');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'SR_SR_SOURCE_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.SR_SR_SOURCE_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;   -- c5

COMMIT;

--/* it's removed due to bug 1219661
DELETE MSC_SR_SOURCE_ORG
 WHERE DELETED_FLAG= MSC_UTIL.SYS_YES
   AND SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
   AND COLLECTED_FLAG= MSC_UTIL.SYS_YES;

COMMIT;
--*/

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

  msc_analyse_tables_pk.analyse_table( 'MSC_SR_SOURCE_ORG');

END IF;


UPDATE msc_st_interorg_ship_methods msism
SET (shipment_weight, shipment_volume, shipment_weight_uom, shipment_volume_uom, leadtime_variability) =
(SELECT shipment_weight, shipment_volume, shipment_weight_uom, shipment_volume_uom, leadtime_variability FROM
   msc_interorg_ship_methods mism
   WHERE mism.from_organization_id = msism.from_organization_id
         AND mism.sr_instance_id = msism.sr_instance_id
	 AND mism.to_organization_id = msism.to_organization_id
         AND mism.sr_instance_id2 = msism.sr_instance_id2
	 AND mism.plan_id = -1
	 AND mism.from_location_id = msism.from_location_id
	 AND mism.to_location_id = msism.to_location_id
	 AND mism.ship_method = msism.ship_method);

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

 MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_INTERORG_SHIP_METHODS', MSC_CL_COLLECTION.v_instance_id,-1, 'AND nvl(COLLECTED_FLAG,1) <> 2');

END IF;

c_count:= 0;

FOR c_rec IN c6 LOOP

BEGIN

INSERT INTO MSC_INTERORG_SHIP_METHODS
(  PLAN_ID,
   TRANSACTION_ID,
   FROM_ORGANIZATION_ID,
   TO_ORGANIZATION_ID,
   SHIP_METHOD,
   SHIP_METHOD_TEXT,
   TIME_UOM_CODE,
   DEFAULT_FLAG,
   FROM_LOCATION_ID,
   TO_LOCATION_ID,
   WEIGHT_CAPACITY,
   WEIGHT_UOM,
   VOLUME_CAPACITY,
   VOLUME_UOM,
   COST_PER_WEIGHT_UNIT,
   COST_PER_VOLUME_UNIT,
   INTRANSIT_TIME,
   TO_REGION_ID,
   FROM_REGION_ID,
   CURRENCY,
   TRANSPORT_CAP_OVER_UTIL_COST,
   SR_INSTANCE_ID,
   SR_INSTANCE_ID2,
   REFRESH_NUMBER,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   CREATION_DATE,
   CREATED_BY,
   SHIPMENT_WEIGHT,
   SHIPMENT_VOLUME,
   SHIPMENT_WEIGHT_UOM,
   SHIPMENT_VOLUME_UOM,
   LEADTIME_VARIABILITY)
VALUES
(  -1,
   MSC_INTERORG_SHIP_METHODS_S.NEXTVAL,
   c_rec.FROM_ORGANIZATION_ID,
   c_rec.TO_ORGANIZATION_ID,
   c_rec.SHIP_METHOD,
   c_rec.SHIP_METHOD_TEXT,
   c_rec.TIME_UOM_CODE,
   c_rec.DEFAULT_FLAG,
   c_rec.FROM_LOCATION_ID,
   c_rec.TO_LOCATION_ID,
   c_rec.WEIGHT_CAPACITY,
   c_rec.WEIGHT_UOM,
   c_rec.VOLUME_CAPACITY,
   c_rec.VOLUME_UOM,
   c_rec.COST_PER_WEIGHT_UNIT,
   c_rec.COST_PER_VOLUME_UNIT,
   c_rec.INTRANSIT_TIME,
   c_rec.TO_REGION_ID,
   c_rec.FROM_REGION_ID,
   c_rec.CURRENCY,
   c_rec.TRANSPORT_CAP_OVER_UTIL_COST,
   c_rec.SR_INSTANCE_ID,
   c_rec.SR_INSTANCE_ID2,
   MSC_CL_COLLECTION.v_last_collection_id,
   MSC_CL_COLLECTION.v_current_date,
   MSC_CL_COLLECTION.v_current_user,
   MSC_CL_COLLECTION.v_current_date,
   MSC_CL_COLLECTION.v_current_user,
   c_rec.SHIPMENT_WEIGHT,
   c_rec.SHIPMENT_VOLUME,
   c_rec.SHIPMENT_WEIGHT_UOM,
   c_rec.SHIPMENT_VOLUME_UOM,
   c_rec.LEADTIME_VARIABILITY);
/*
  c_count:= c_count+1;

  IF c_count> MSC_CL_COLLECTION.PBS THEN
     COMMIT;
     c_count:= 0;
  END IF;
*/
EXCEPTION

   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_INTERORG_SHIP_METHODS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_INTERORG_SHIP_METHODS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'FROM_ORGANIZATION_CODE');
      FND_MESSAGE.SET_TOKEN('VALUE',
                            MSC_GET_NAME.ORG_CODE( c_rec.FROM_ORGANIZATION_ID,
                                                   MSC_CL_COLLECTION.v_instance_id));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'TO_ORGANIZATION_CODE');
      FND_MESSAGE.SET_TOKEN('VALUE',
                            MSC_GET_NAME.ORG_CODE( c_rec.TO_ORGANIZATION_ID,
                                                   MSC_CL_COLLECTION.v_instance_id));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'FROM_LOCATION_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.FROM_LOCATION_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'TO_LOCATION_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.TO_LOCATION_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'SHIP_METHOD');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.SHIP_METHOD);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;

COMMIT;

/* Code added for Region Level Sourcing for ATP - Only for 11i Source */
IF MSC_CL_COLLECTION.v_apps_ver >= 3 THEN


     IF (MSC_CL_COLLECTION.v_apps_ver = MSC_UTIL.G_APPS107) OR (MSC_CL_COLLECTION.v_apps_ver = MSC_UTIL.G_APPS110) THEN
      lv_msc_tp_coll_window := 0;
   ELSE
      BEGIN
	lv_msc_tp_coll_window:= NVL(TO_NUMBER(FND_PROFILE.VALUE('MSC_COLLECTION_WINDOW_FOR_TP_CHANGES')),0);
      EXCEPTION
         WHEN OTHERS THEN
            lv_msc_tp_coll_window := 0;
      END ;
   END IF;
   -- bug 4590579
   -- During complete/targeted refresh, we will delete or truncate the
   -- following tables based upon the profile option: MSC_PURGE_ST_CONTROL:
   -- 1. MSC_REGIONS
   -- 2. MSC_ZONE_REGIONS
   -- 3. MSC_REGION_LOCATIONS
   -- 4. MSC_REGION_SITES
   -- 5. MSC_CARRIER_SERVICES

   SELECT
	 decode(nvl(fnd_profile.value('MSC_PURGE_ST_CONTROL'),'N'),'Y',1,2)
	 INTO lv_control_flag
	 FROM dual;

/*
Bug 5126455
Tables:
-- 1. MSC_REGIONS
-- 2. MSC_ZONE_REGIONS
-- 3. MSC_REGION_LOCATIONS
-- 4. MSC_REGION_SITES

Changed row by row processing to do bulk update/insert

Also, the data pulled into the msc_st_region_locations will depend on
the value of the profile, MSC_COLLECTION_WINDOW_FOR_TP_CHANGES.
We will delete/truncate this ods tables only if the profile is null or 0

*/



/* ------------- MSC_REGIONS ------------- */
IF ((MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh)) THEN

BEGIN  -- load for MSC_REGIONS
/* Updating Who cols of Staging Tables */
    UPDATE MSC_ST_REGIONS
    SET
        REFRESH_NUMBER    = MSC_CL_COLLECTION.v_last_collection_id,
        LAST_UPDATE_DATE  = MSC_CL_COLLECTION.v_current_date,
        LAST_UPDATED_BY   = MSC_CL_COLLECTION.v_current_user,
        CREATION_DATE     = MSC_CL_COLLECTION.v_current_date,
        CREATED_BY        = MSC_CL_COLLECTION.v_current_user,
        LAST_UPDATE_LOGIN = MSC_CL_COLLECTION.v_current_user
     WHERE SR_INSTANCE_ID = MSC_CL_COLLECTION.v_instance_id;

 COMMIT;

      /* Initialize the list */
           IF NOT MSC_CL_EXCHANGE_PARTTBL.Initialize_SWAP_Tbl_List(MSC_CL_COLLECTION.v_instance_id,MSC_CL_COLLECTION.v_instance_code)   THEN
                  RAISE MSC_CL_COLLECTION.EXCHANGE_PARTN_ERROR;
           END IF;
      /* Get the swap table index number in the list*/
           i := MSC_CL_EXCHANGE_PARTTBL.get_SWAP_table_index('MSC_REGIONS'); --ods table name
      IF i = -1 THEN
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Table not in the list of SWAP partition');
        RAISE MSC_CL_COLLECTION.EXCHANGE_PARTN_ERROR;
      END IF;
      /* Do phase 1 exchange*/

      IF NOT MSC_CL_EXCHANGE_PARTTBL.EXCHANGE_SINGLE_TAB_PARTN (
                    MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).stg_table_name,
                    MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).stg_table_partn_name,
                    MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).temp_table_name,
                                              MSC_UTIL.SYS_NO  ) THEN
                    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Exchange partition failed');
         RAISE MSC_CL_COLLECTION.EXCHANGE_PARTN_ERROR;
      END IF;

             EXECUTE IMMEDIATE ' Update msc_coll_parameters set  '
      || MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).column_name || ' = '
      || MSC_CL_COLLECTION.G_STG_ODS_SWP_PHASE_1
      || ' where instance_id = ' || MSC_CL_COLLECTION.v_instance_id;

commit;
      /* Add code to copy required data from ods table to this temp table*/

      /* Add code to create indexes on this temp table*/
            lv_crt_ind_status := MSC_CL_EXCHANGE_PARTTBL.create_temp_table_index
       			      ( 'NONUNIQUE',
                                MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).ods_table_name,
                                MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).temp_table_name,
                                MSC_CL_COLLECTION.v_instance_code,
                                MSC_CL_COLLECTION.v_instance_id,
                                MSC_UTIL.SYS_NO,
                                MSC_CL_COLLECTION.G_WARNING
                              );

       IF lv_crt_ind_status = MSC_CL_COLLECTION.G_WARNING THEN
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Warning during nonunique index creation on table, ' || MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).temp_table_name);
       ELSIF lv_crt_ind_status = MSC_CL_COLLECTION.G_ERROR THEN
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error during nonunique index creation on table, ' || MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).temp_table_name);
          --RETURN ;
       ELSE
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'NonUnique index creation successful on table, ' || MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).temp_table_name);
       END IF;

   COMMIT;



   EXCEPTION
   WHEN MSC_CL_COLLECTION.EXCHANGE_PARTN_ERROR THEN
        RAISE;
   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_REGIONS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_REGIONS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;
END;  -- load for MSC_REGIONS



/* ------------- MSC_ZONE_REGIONS ------------- */

BEGIN  -- load for MSC_ZONE_REGIONS
/* Updating Who cols of Staging Tables */
    UPDATE MSC_ST_ZONE_REGIONS
    SET
        REFRESH_NUMBER    = MSC_CL_COLLECTION.v_last_collection_id,
        LAST_UPDATE_DATE  = MSC_CL_COLLECTION.v_current_date,
        LAST_UPDATED_BY   = MSC_CL_COLLECTION.v_current_user,
        CREATION_DATE     = MSC_CL_COLLECTION.v_current_date,
        CREATED_BY        = MSC_CL_COLLECTION.v_current_user,
        LAST_UPDATE_LOGIN = MSC_CL_COLLECTION.v_current_user
     WHERE SR_INSTANCE_ID = MSC_CL_COLLECTION.v_instance_id;

 COMMIT;

      /* Initialize the list */
           IF NOT MSC_CL_EXCHANGE_PARTTBL.Initialize_SWAP_Tbl_List(MSC_CL_COLLECTION.v_instance_id,MSC_CL_COLLECTION.v_instance_code)   THEN
                  RAISE MSC_CL_COLLECTION.EXCHANGE_PARTN_ERROR;
           END IF;
      /* Get the swap table index number in the list*/
           i := MSC_CL_EXCHANGE_PARTTBL.get_SWAP_table_index('MSC_ZONE_REGIONS'); --ods table name
      IF i = -1 THEN
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Table not in the list of SWAP partition');
        RAISE MSC_CL_COLLECTION.EXCHANGE_PARTN_ERROR;
      END IF;
      /* Do phase 1 exchange*/

      IF NOT MSC_CL_EXCHANGE_PARTTBL.EXCHANGE_SINGLE_TAB_PARTN (
                    MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).stg_table_name,
                    MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).stg_table_partn_name,
                    MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).temp_table_name,
                                              MSC_UTIL.SYS_NO  ) THEN
                    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Exchange partition failed');
         RAISE MSC_CL_COLLECTION.EXCHANGE_PARTN_ERROR;
      END IF;

             EXECUTE IMMEDIATE ' Update msc_coll_parameters set  '
      || MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).column_name || ' = '
      || MSC_CL_COLLECTION.G_STG_ODS_SWP_PHASE_1
      || ' where instance_id = ' || MSC_CL_COLLECTION.v_instance_id;

commit;
      /* Add code to copy required data from ods table to this temp table*/

      /* Add code to create indexes on this temp table*/
              lv_crt_ind_status := MSC_CL_EXCHANGE_PARTTBL.create_temp_table_index
       			      ( 'NONUNIQUE',
                                MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).ods_table_name,
                                MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).temp_table_name,
                                MSC_CL_COLLECTION.v_instance_code,
                                MSC_CL_COLLECTION.v_instance_id,
                                MSC_UTIL.SYS_NO,
                                MSC_CL_COLLECTION.G_WARNING
                              );

       IF lv_crt_ind_status = MSC_CL_COLLECTION.G_WARNING THEN
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Warning during nonunique index creation on table, ' || MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).temp_table_name);
       ELSIF lv_crt_ind_status = MSC_CL_COLLECTION.G_ERROR THEN
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error during nonunique index creation on table, ' || MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).temp_table_name);
--          RETURN ;
       ELSE
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'NonUnique index creation successful on table, ' || MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).temp_table_name);
       END IF;

   EXCEPTION
   WHEN MSC_CL_COLLECTION.EXCHANGE_PARTN_ERROR THEN
        RAISE;
   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ZONE_REGIONS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ZONE_REGIONS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;
END;  -- load for MSC_ZONE_REGIONS


/* ------------- MSC_REGION_LOCATIONS ------------- */
BEGIN  -- load for MSC_REGION_LOCATIONS
/* Updating Who cols of Staging Tables */
    UPDATE MSC_ST_REGION_LOCATIONS
    SET
        REFRESH_NUMBER    = MSC_CL_COLLECTION.v_last_collection_id,
        LAST_UPDATE_DATE  = MSC_CL_COLLECTION.v_current_date,
        LAST_UPDATED_BY   = MSC_CL_COLLECTION.v_current_user,
        CREATION_DATE     = MSC_CL_COLLECTION.v_current_date,
        CREATED_BY        = MSC_CL_COLLECTION.v_current_user,
        LAST_UPDATE_LOGIN = MSC_CL_COLLECTION.v_current_user
     WHERE SR_INSTANCE_ID = MSC_CL_COLLECTION.v_instance_id;

 COMMIT;

      /* Initialize the list */
           IF NOT MSC_CL_EXCHANGE_PARTTBL.Initialize_SWAP_Tbl_List(MSC_CL_COLLECTION.v_instance_id,MSC_CL_COLLECTION.v_instance_code)   THEN
                  RAISE MSC_CL_COLLECTION.EXCHANGE_PARTN_ERROR;
           END IF;
      /* Get the swap table index number in the list*/
           i := MSC_CL_EXCHANGE_PARTTBL.get_SWAP_table_index('MSC_REGION_LOCATIONS'); --ods table name
      IF i = -1 THEN
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Table not in the list of SWAP partition');
        RAISE MSC_CL_COLLECTION.EXCHANGE_PARTN_ERROR;
      END IF;
      /* Do phase 1 exchange*/

      IF NOT MSC_CL_EXCHANGE_PARTTBL.EXCHANGE_SINGLE_TAB_PARTN (
                    MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).stg_table_name,
                    MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).stg_table_partn_name,
                    MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).temp_table_name,
                                              MSC_UTIL.SYS_NO  ) THEN
                    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Exchange partition failed');
         RAISE MSC_CL_COLLECTION.EXCHANGE_PARTN_ERROR;
      END IF;

             EXECUTE IMMEDIATE ' Update msc_coll_parameters set  '
      || MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).column_name || ' = '
      || MSC_CL_COLLECTION.G_STG_ODS_SWP_PHASE_1
      || ' where instance_id = ' || MSC_CL_COLLECTION.v_instance_id;

commit;
      /* Add code to copy required data from ods table to this temp table*/

      /* Add code to create indexes on this temp table*/
             lv_crt_ind_status := MSC_CL_EXCHANGE_PARTTBL.create_temp_table_index
       			      ( 'NONUNIQUE',
                                MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).ods_table_name,
                                MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).temp_table_name,
                                MSC_CL_COLLECTION.v_instance_code,
                                MSC_CL_COLLECTION.v_instance_id,
                                MSC_UTIL.SYS_NO,
                                MSC_CL_COLLECTION.G_WARNING
                              );

       IF lv_crt_ind_status = MSC_CL_COLLECTION.G_WARNING THEN
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Warning during nonunique index creation on table, ' || MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).temp_table_name);
       ELSIF lv_crt_ind_status = MSC_CL_COLLECTION.G_ERROR THEN
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error during nonunique index creation on table, ' || MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).temp_table_name);
--          RETURN ;
       ELSE
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'NonUnique index creation successful on table, ' || MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).temp_table_name);
       END IF;

   EXCEPTION
   WHEN MSC_CL_COLLECTION.EXCHANGE_PARTN_ERROR THEN
        RAISE;
   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_REGION_LOCATIONS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_REGION_LOCATIONS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;
END;  -- load for MSC_REGION_LOCATIONS
END IF; --IF ((MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh)) THEN


/* ------------- MSC_REGION_SITES ------------- */
BEGIN

   IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN
      IF lv_control_flag = 2 THEN
         MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_REGION_SITES', MSC_CL_COLLECTION.v_instance_id,NULL);
      ELSE
         MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE('MSC_REGION_SITES');
      END IF;
   END IF;

   lv_sql_stmt:=
   ' INSERT INTO MSC_REGION_SITES '
   ||'   (REGION_ID,              '
   ||'    VENDOR_SITE_ID,         '
   ||'    REGION_TYPE,            '
   ||'    ZONE_LEVEL,             '
   ||'    SR_INSTANCE_ID,         '
   ||'    REFRESH_NUMBER,         '
   ||'    CREATED_BY,             '
   ||'    CREATION_DATE,          '
   ||'    LAST_UPDATED_BY,        '
   ||'    LAST_UPDATE_DATE,       '
   ||'    LAST_UPDATE_LOGIN)      '
   ||' (SELECT DISTINCT            '
   ||'    msrs.REGION_ID,         '
   ||'    mtsil.TP_SITE_ID,       '
   ||'    msrs.REGION_TYPE,       '
   ||'    msrs.ZONE_LEVEL,        '
   ||'    msrs.SR_INSTANCE_ID,    '
   ||'    :v_last_collection_id,    '
   ||'    :v_current_user,          '
   ||'    :v_current_date,          '
   ||'    :v_current_user,          '
   ||'    :v_current_date,          '
   ||'    :v_current_user           '
   ||' FROM  MSC_ST_REGION_SITES msrs, '
   ||'       MSC_TP_SITE_ID_LID mtsil  '
   ||' WHERE msrs.SR_INSTANCE_ID= :v_instance_id        '
   ||'   AND mtsil.SR_TP_SITE_ID = msrs.VENDOR_SITE_ID  '
   ||'   AND mtsil.SR_Instance_ID = msrs.SR_INSTANCE_ID '
   ||'   AND mtsil.Partner_Type = 1 '
   ||'    ) ';

   EXECUTE IMMEDIATE lv_sql_stmt
   USING   MSC_CL_COLLECTION.v_last_collection_id,
           MSC_CL_COLLECTION.v_current_user,
           MSC_CL_COLLECTION.v_current_date,
           MSC_CL_COLLECTION.v_current_user,
           MSC_CL_COLLECTION.v_current_date,
           MSC_CL_COLLECTION.v_current_user,
           MSC_CL_COLLECTION.v_instance_id;

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_REGION_SITES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_REGION_SITES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;



IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

   IF lv_control_flag = 2 THEN
	  MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_CARRIER_SERVICES', MSC_CL_COLLECTION.v_instance_id,-1);
	ELSE
	  MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE('MSC_CARRIER_SERVICES');
   END IF;

END IF;

FOR c_rec IN c11 LOOP

BEGIN

INSERT INTO MSC_CARRIER_SERVICES
  (SHIP_METHOD_CODE,
   CARRIER_ID,
   SERVICE_LEVEL,
   MODE_OF_TRANSPORT,
   SR_INSTANCE_ID,
   REFRESH_NUMBER,
   PLAN_ID,
   CREATED_BY,
   CREATION_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN)
VALUES
  (c_rec.SHIP_METHOD_CODE,
   c_rec.TP_ID,
   c_rec.SERVICE_LEVEL,
   c_rec.MODE_OF_TRANSPORT,
   c_rec.SR_INSTANCE_ID,
   MSC_CL_COLLECTION.v_last_collection_id,
   -1,
   MSC_CL_COLLECTION.v_current_user,
   MSC_CL_COLLECTION.v_current_date,
   MSC_CL_COLLECTION.v_current_user,
   MSC_CL_COLLECTION.v_current_date,
   MSC_CL_COLLECTION.v_current_user);

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_CARRIER_SERVICES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_REGION_SITES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;

COMMIT;

END IF;

END LOAD_SOURCING;


--==================================================================

   PROCEDURE LOAD_SUB_INVENTORY IS

    CURSOR c1 IS
SELECT
  mssi.ORGANIZATION_ID,
  mssi.SUB_INVENTORY_CODE,
  mssi.NETTING_TYPE,
  mssi.INVENTORY_ATP_CODE,
  substrb(mssi.DESCRIPTION,1,50) DESCRIPTION, --added for the NLS bug3463401
  mssi.SR_INSTANCE_ID,
  mssi.condition_type,     -- For Bug # 5660122 SRP Changes
  mssi.SR_RESOURCE_NAME,
  mssi.SR_CUSTOMER_ACCT_ID
FROM MSC_ST_SUB_INVENTORIES mssi
WHERE mssi.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

   c_count NUMBER:= 0;

   BEGIN

IF (MSC_CL_COLLECTION.v_is_complete_refresh or MSC_CL_COLLECTION.v_is_partial_refresh) THEN

--MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SUB_INVENTORIES', MSC_CL_COLLECTION.v_instance_id, -1);

  IF MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SUB_INVENTORIES', MSC_CL_COLLECTION.v_instance_id, -1);
  ELSE
    MSC_CL_COLLECTION.v_sub_str :=' AND ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SUB_INVENTORIES', MSC_CL_COLLECTION.v_instance_id, -1,MSC_CL_COLLECTION.v_sub_str);
  END IF;

END IF;

c_count:= 0;

FOR c_rec IN c1 LOOP

BEGIN

IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

UPDATE MSC_SUB_INVENTORIES
SET
 NETTING_TYPE= c_rec.NETTING_TYPE,
 INVENTORY_ATP_CODE= c_rec.INVENTORY_ATP_CODE,
 DESCRIPTION= c_rec.DESCRIPTION,
 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user,
 condition_type=c_rec.condition_type,     -- For Bug # 5660122 SRP Changes
 SR_RESOURCE_NAME=c_rec.SR_RESOURCE_NAME,
 SR_CUSTOMER_ACCT_ID=c_rec.SR_CUSTOMER_ACCT_ID
WHERE PLAN_ID= -1
  AND ORGANIZATION_ID= c_rec.ORGANIZATION_ID
  AND SUB_INVENTORY_CODE= c_rec.SUB_INVENTORY_CODE
  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID;

END IF;

IF (MSC_CL_COLLECTION.v_is_complete_refresh or MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

INSERT INTO MSC_SUB_INVENTORIES
( PLAN_ID,
  ORGANIZATION_ID,
  SUB_INVENTORY_CODE,
  NETTING_TYPE,
  INVENTORY_ATP_CODE,
  DESCRIPTION,
  CONDITION_TYPE,
  SR_RESOURCE_NAME,
  SR_CUSTOMER_ACCT_ID, -- For Bug # 5660122 SRP Changes
  SR_INSTANCE_ID,
  REFRESH_NUMBER,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
( -1,
  c_rec.ORGANIZATION_ID,
  c_rec.SUB_INVENTORY_CODE,
  c_rec.NETTING_TYPE,
  c_rec.INVENTORY_ATP_CODE,
  c_rec.DESCRIPTION,
  c_rec.CONDITION_TYPE,
  c_rec.SR_RESOURCE_NAME,
  c_rec.SR_CUSTOMER_ACCT_ID, -- For Bug # 5660122 SRP Changes
  c_rec.SR_INSTANCE_ID,
  MSC_CL_COLLECTION.v_last_collection_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user );


END IF;

  c_count:= c_count+1;

  IF c_count> MSC_CL_COLLECTION.PBS THEN
     COMMIT;
     c_count:= 0;
  END IF;

EXCEPTION

   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SUB_INVENTORY');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SUB_INVENTORIES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SUB_INVENTORY');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SUB_INVENTORIES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
      FND_MESSAGE.SET_TOKEN('VALUE',
                            MSC_GET_NAME.ORG_CODE( c_rec.ORGANIZATION_ID,
                                                   MSC_CL_COLLECTION.v_instance_id));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'SUB_INVENTORY_CODE');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.SUB_INVENTORY_CODE);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;
END;

END LOOP;

COMMIT;

   END LOAD_SUB_INVENTORY;

   --==================================================================

   PROCEDURE LOAD_UNIT_NUMBER IS

   CURSOR c1 IS
SELECT
  msun.UNIT_NUMBER,
  t1.INVENTORY_ITEM_ID  END_ITEM_ID,
  msun.MASTER_ORGANIZATION_ID,
  msun.COMMENTS,
  msun.SR_INSTANCE_ID
FROM MSC_ITEM_ID_LID t1,
     MSC_ST_Unit_Numbers msun
WHERE t1.SR_INVENTORY_ITEM_ID=        msun.end_item_id
  AND t1.sr_instance_id= msun.sr_instance_id
  AND msun.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

   c_count NUMBER:= 0;

   BEGIN

IF (MSC_CL_COLLECTION.v_is_complete_refresh or MSC_CL_COLLECTION.v_is_partial_refresh) THEN

--MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_UNIT_NUMBERS', MSC_CL_COLLECTION.v_instance_id, NULL);

  IF MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_UNIT_NUMBERS', MSC_CL_COLLECTION.v_instance_id,NULL);
  ELSE
    MSC_CL_COLLECTION.v_sub_str :='AND MASTER_ORGANIZATION_ID'||MSC_UTIL.v_in_org_str;
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_UNIT_NUMBERS', MSC_CL_COLLECTION.v_instance_id,NULL,MSC_CL_COLLECTION.v_sub_str);
  END IF;

END IF;

c_count:= 0;

FOR c_rec IN c1 LOOP

BEGIN

IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

UPDATE MSC_UNIT_NUMBERS
SET
 END_ITEM_ID= c_rec.END_ITEM_ID,
 MASTER_ORGANIZATION_ID= c_rec.MASTER_ORGANIZATION_ID,
 COMMENTS= c_rec.COMMENTS,
 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE UNIT_NUMBER= c_rec.UNIT_NUMBER
  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID;

END IF;

IF (MSC_CL_COLLECTION.v_is_complete_refresh or MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

INSERT INTO MSC_UNIT_NUMBERS
( UNIT_NUMBER,
  END_ITEM_ID,
  MASTER_ORGANIZATION_ID,
  COMMENTS,
  SR_INSTANCE_ID,
  REFRESH_NUMBER,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
( c_rec.UNIT_NUMBER,
  c_rec.END_ITEM_ID,
  c_rec.MASTER_ORGANIZATION_ID,
  c_rec.COMMENTS,
  c_rec.SR_INSTANCE_ID,
  MSC_CL_COLLECTION.v_last_collection_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user );

END IF;

  c_count:= c_count+1;

  IF c_count> MSC_CL_COLLECTION.PBS THEN
     COMMIT;
     c_count:= 0;
  END IF;

EXCEPTION
   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_UNIT_NUMBER');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_UNIT_NUMBERS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_UNIT_NUMBER');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_UNIT_NUMBERS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'UNIT_NUMBER');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.UNIT_NUMBER);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'END_ITEM_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', MSC_CL_ITEM_ODS_LOAD.ITEM_NAME(c_rec.END_ITEM_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'MASTER_ORGANIZATION_CODE');
      FND_MESSAGE.SET_TOKEN('VALUE',
                            MSC_GET_NAME.ORG_CODE(
                                   c_rec.MASTER_ORGANIZATION_ID,
                                   MSC_CL_COLLECTION.v_instance_id));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;

COMMIT;

   END LOAD_UNIT_NUMBER;
--==================================================================

   PROCEDURE LOAD_PROJECT IS

   CURSOR c1 IS
SELECT
  msp.PROJECT_ID,
  msp.ORGANIZATION_ID,
  msp.PLANNING_GROUP,
  msp.COSTING_GROUP_ID,
  msp.MATERIAL_ACCOUNT,
  msp.WIP_ACCT_CLASS_CODE,
  msp.SEIBAN_NUMBER_FLAG,
  msp.PROJECT_NAME,
  msp.PROJECT_NUMBER,
  msp.PROJECT_NUMBER_SORT_ORDER,
  msp.PROJECT_DESCRIPTION,
  msp.START_DATE,
  msp.COMPLETION_DATE,
  msp.OPERATING_UNIT,
  msp.MANAGER_CONTACT,
  msp.SR_INSTANCE_ID
FROM MSC_ST_PROJECTS msp
WHERE msp.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

   CURSOR c2 IS
SELECT
  mspt.PROJECT_ID,
  mspt.TASK_ID,
  mspt.ORGANIZATION_ID,
  mspt.TASK_NUMBER,
  mspt.TASK_NAME,
  mspt.DESCRIPTION,
  mspt.MANAGER,
  mspt.START_DATE,
  mspt.END_DATE,
  mspt.MANAGER_CONTACT,
  mspt.SR_INSTANCE_ID
FROM MSC_ST_PROJECT_TASKS mspt
WHERE mspt.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

   c_count NUMBER:= 0;

   BEGIN

IF (MSC_CL_COLLECTION.v_is_complete_refresh or MSC_CL_COLLECTION.v_is_partial_refresh) THEN

--MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_PROJECTS', MSC_CL_COLLECTION.v_instance_id, -1);

  IF MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_PROJECTS', MSC_CL_COLLECTION.v_instance_id, -1);
  ELSE
    MSC_CL_COLLECTION.v_sub_str :=' AND ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_PROJECTS', MSC_CL_COLLECTION.v_instance_id, -1,MSC_CL_COLLECTION.v_sub_str);
  END IF;

END IF;

c_count:= 0;

FOR c_rec IN c1 LOOP

BEGIN

IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

UPDATE MSC_PROJECTS
SET
 PLANNING_GROUP= c_rec.PLANNING_GROUP,
 COSTING_GROUP_ID= c_rec.COSTING_GROUP_ID,
 MATERIAL_ACCOUNT= c_rec.MATERIAL_ACCOUNT,
 WIP_ACCT_CLASS_CODE= c_rec.WIP_ACCT_CLASS_CODE,
 SEIBAN_NUMBER_FLAG= c_rec.SEIBAN_NUMBER_FLAG,
 PROJECT_NAME= c_rec.PROJECT_NAME,
 PROJECT_NUMBER= c_rec.PROJECT_NUMBER,
 PROJECT_NUMBER_SORT_ORDER= c_rec.PROJECT_NUMBER_SORT_ORDER,
 PROJECT_DESCRIPTION= c_rec.PROJECT_DESCRIPTION,
 START_DATE= c_rec.START_DATE,
 COMPLETION_DATE= c_rec.COMPLETION_DATE,
 OPERATING_UNIT= c_rec.OPERATING_UNIT,
 MANAGER_CONTACT= c_rec.MANAGER_CONTACT,
 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE PLAN_ID= -1
  AND PROJECT_ID= c_rec.PROJECT_ID
  AND ORGANIZATION_ID= c_rec.ORGANIZATION_ID
  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID;

END IF;

IF (MSC_CL_COLLECTION.v_is_complete_refresh or MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

INSERT INTO MSC_PROJECTS
( PLAN_ID,
  PROJECT_ID,
  ORGANIZATION_ID,
  PLANNING_GROUP,
  COSTING_GROUP_ID,
  MATERIAL_ACCOUNT,
  WIP_ACCT_CLASS_CODE,
  SEIBAN_NUMBER_FLAG,
  PROJECT_NAME,
  PROJECT_NUMBER,
  PROJECT_NUMBER_SORT_ORDER,
  PROJECT_DESCRIPTION,
  START_DATE,
  COMPLETION_DATE,
  OPERATING_UNIT,
  MANAGER_CONTACT,
  SR_INSTANCE_ID,
  REFRESH_NUMBER,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
( -1,
  c_rec.PROJECT_ID,
  c_rec.ORGANIZATION_ID,
  c_rec.PLANNING_GROUP,
  c_rec.COSTING_GROUP_ID,
  c_rec.MATERIAL_ACCOUNT,
  c_rec.WIP_ACCT_CLASS_CODE,
  c_rec.SEIBAN_NUMBER_FLAG,
  c_rec.PROJECT_NAME,
  c_rec.PROJECT_NUMBER,
  c_rec.PROJECT_NUMBER_SORT_ORDER,
  c_rec.PROJECT_DESCRIPTION,
  c_rec.START_DATE,
  c_rec.COMPLETION_DATE,
  c_rec.OPERATING_UNIT,
  c_rec.MANAGER_CONTACT,
  c_rec.SR_INSTANCE_ID,
  MSC_CL_COLLECTION.v_last_collection_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user );

END IF;

  c_count:= c_count+1;

  IF c_count> MSC_CL_COLLECTION.PBS THEN
     COMMIT;
     c_count:= 0;
  END IF;

EXCEPTION
   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_PROJECT');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_PROJECTS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE

      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_PROJECT');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_PROJECTS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
      FND_MESSAGE.SET_TOKEN('VALUE',
                            MSC_GET_NAME.ORG_CODE( c_rec.ORGANIZATION_ID,
                                                   MSC_CL_COLLECTION.v_instance_id));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'PROJECT_NAME');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.PROJECT_NAME);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;

COMMIT;

IF (MSC_CL_COLLECTION.v_is_complete_refresh or MSC_CL_COLLECTION.v_is_partial_refresh) THEN

--MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_PROJECT_TASKS', MSC_CL_COLLECTION.v_instance_id, -1);

  IF MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_PROJECT_TASKS', MSC_CL_COLLECTION.v_instance_id, -1);
  ELSE
    MSC_CL_COLLECTION.v_sub_str :=' AND ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_PROJECT_TASKS', MSC_CL_COLLECTION.v_instance_id, -1,MSC_CL_COLLECTION.v_sub_str);
  END IF;

END IF;

c_count:= 0;

FOR c_rec IN c2 LOOP

BEGIN

IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

UPDATE MSC_PROJECT_TASKS
SET
 TASK_NUMBER= c_rec.TASK_NUMBER,
 TASK_NAME= c_rec.TASK_NAME,
 DESCRIPTION= c_rec.DESCRIPTION,
 MANAGER= c_rec.MANAGER,
 START_DATE= c_rec.START_DATE,
 END_DATE= c_rec.END_DATE,
 MANAGER_CONTACT= c_rec.MANAGER_CONTACT,
 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE PLAN_ID= -1
  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
  AND ORGANIZATION_ID= c_rec.ORGANIZATION_ID
  AND PROJECT_ID= c_rec.PROJECT_ID
  AND TASK_ID= c_rec.TASK_ID;

END IF;

IF (MSC_CL_COLLECTION.v_is_complete_refresh or MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

INSERT INTO MSC_PROJECT_TASKS
( PLAN_ID,
  PROJECT_ID,
  TASK_ID,
  ORGANIZATION_ID,
  TASK_NUMBER,
  TASK_NAME,
  DESCRIPTION,
  MANAGER,
  START_DATE,
  END_DATE,
  MANAGER_CONTACT,
  SR_INSTANCE_ID,
  REFRESH_NUMBER,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
( -1,
  c_rec.PROJECT_ID,
  c_rec.TASK_ID,
  c_rec.ORGANIZATION_ID,
  c_rec.TASK_NUMBER,
  c_rec.TASK_NAME,
  c_rec.DESCRIPTION,
  c_rec.MANAGER,
  c_rec.START_DATE,
  c_rec.END_DATE,
  c_rec.MANAGER_CONTACT,
  c_rec.SR_INSTANCE_ID,
  MSC_CL_COLLECTION.v_last_collection_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user );

END IF;

  c_count:= c_count+1;

  IF c_count> MSC_CL_COLLECTION.PBS THEN
     COMMIT;
     c_count:= 0;
  END IF;

EXCEPTION

   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_PROJECT');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_PROJECT_TASKS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE

      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_PROJECT');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_PROJECT_TASKS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
      FND_MESSAGE.SET_TOKEN('VALUE',
                            MSC_GET_NAME.ORG_CODE( c_rec.ORGANIZATION_ID,
                                                   MSC_CL_COLLECTION.v_instance_id));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'PROJECT_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.PROJECT_ID);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'TASK_NAME');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.TASK_NAME);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;

COMMIT;

   END LOAD_PROJECT;


-- ====================== LOAD BIS ======================

   PROCEDURE LOAD_BIS_PFMC_MEASURES IS

   CURSOR c1 IS
SELECT
  MEASURE_ID,
  MEASURE_SHORT_NAME,
  MEASURE_NAME,
  DESCRIPTION,
  ORG_DIMENSION_ID,
  TIME_DIMENSION_ID,
  DIMENSION1_ID,
  DIMENSION2_ID,
  DIMENSION3_ID,
  DIMENSION4_ID,
  DIMENSION5_ID,
  UNIT_OF_MEASURE_CLASS
FROM MSC_ST_BIS_PFMC_MEASURES
WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

   c_count NUMBER:= 0;

   BEGIN

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_BIS_PERFORMANCE_MEASURES', MSC_CL_COLLECTION.v_instance_id, NULL);

END IF;

c_count:= 0;

FOR c_rec IN c1 LOOP

BEGIN

INSERT INTO MSC_BIS_PERFORMANCE_MEASURES
( MEASURE_ID,
  MEASURE_SHORT_NAME,
  MEASURE_NAME,
  DESCRIPTION,
  ORG_DIMENSION_ID,
  TIME_DIMENSION_ID,
  DIMENSION1_ID,
  DIMENSION2_ID,
  DIMENSION3_ID,
  DIMENSION4_ID,
  DIMENSION5_ID,
  UNIT_OF_MEASURE_CLASS,
  SR_INSTANCE_ID,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
( c_rec.MEASURE_ID,
  c_rec.MEASURE_SHORT_NAME,
  c_rec.MEASURE_NAME,
  c_rec.DESCRIPTION,
  c_rec.ORG_DIMENSION_ID,
  c_rec.TIME_DIMENSION_ID,
  c_rec.DIMENSION1_ID,
  c_rec.DIMENSION2_ID,
  c_rec.DIMENSION3_ID,
  c_rec.DIMENSION4_ID,
  c_rec.DIMENSION5_ID,
  c_rec.UNIT_OF_MEASURE_CLASS,
  MSC_CL_COLLECTION.v_instance_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user );

  c_count:= c_count+1;

  IF c_count> MSC_CL_COLLECTION.PBS THEN
     COMMIT;
     c_count:= 0;
  END IF;

EXCEPTION
   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_BIS');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_BIS_PERFORMANCE_MEASURES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_BIS');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_BIS_PERFORMANCE_MEASURES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'MEASURE_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.MEASURE_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORG_DIMENSION_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.ORG_DIMENSION_ID);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'TIME_DIMENSION_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.TIME_DIMENSION_ID);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;

COMMIT;

   END LOAD_BIS_PFMC_MEASURES;


   PROCEDURE LOAD_BIS_TARGET_LEVELS IS

   CURSOR c2 IS
SELECT
TARGET_LEVEL_ID,
  TARGET_LEVEL_SHORT_NAME,
  TARGET_LEVEL_NAME,
  DESCRIPTION,
  MEASURE_ID,
  ORG_LEVEL_ID,
  TIME_LEVEL_ID,
  DIMENSION1_LEVEL_ID,
  DIMENSION2_LEVEL_ID,
  DIMENSION3_LEVEL_ID,
  DIMENSION4_LEVEL_ID,
  DIMENSION5_LEVEL_ID,
  WORKFLOW_ITEM_TYPE,
  WORKFLOW_PROCESS_SHORT_NAME,
  DEFAULT_NOTIFY_RESP_ID,
  DEFAULT_NOTIFY_RESP_SHORT_NAME,
  COMPUTING_FUNCTION_ID,
  REPORT_FUNCTION_ID,
  UNIT_OF_MEASURE,
  SYSTEM_FLAG
FROM MSC_ST_BIS_TARGET_LEVELS
WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

   c_count NUMBER:= 0;

   BEGIN

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_BIS_TARGET_LEVELS', MSC_CL_COLLECTION.v_instance_id, NULL);

END IF;

c_count:= 0;

FOR c_rec IN c2 LOOP

BEGIN

INSERT INTO MSC_BIS_TARGET_LEVELS
( TARGET_LEVEL_ID,
  TARGET_LEVEL_SHORT_NAME,
  TARGET_LEVEL_NAME,
  DESCRIPTION,
  MEASURE_ID,
  ORG_LEVEL_ID,
  TIME_LEVEL_ID,
  DIMENSION1_LEVEL_ID,
  DIMENSION2_LEVEL_ID,
  DIMENSION3_LEVEL_ID,
  DIMENSION4_LEVEL_ID,
  DIMENSION5_LEVEL_ID,
  WORKFLOW_ITEM_TYPE,
  WORKFLOW_PROCESS_SHORT_NAME,
  DEFAULT_NOTIFY_RESP_ID,
  DEFAULT_NOTIFY_RESP_SHORT_NAME,
  COMPUTING_FUNCTION_ID,
  REPORT_FUNCTION_ID,
  UNIT_OF_MEASURE,
  SYSTEM_FLAG,
  SR_INSTANCE_ID,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
( c_rec.TARGET_LEVEL_ID,
  c_rec.TARGET_LEVEL_SHORT_NAME,
  c_rec.TARGET_LEVEL_NAME,
  c_rec.DESCRIPTION,
  c_rec.MEASURE_ID,
  c_rec.ORG_LEVEL_ID,
  c_rec.TIME_LEVEL_ID,
  c_rec.DIMENSION1_LEVEL_ID,
  c_rec.DIMENSION2_LEVEL_ID,
  c_rec.DIMENSION3_LEVEL_ID,
  c_rec.DIMENSION4_LEVEL_ID,
  c_rec.DIMENSION5_LEVEL_ID,
  c_rec.WORKFLOW_ITEM_TYPE,
  c_rec.WORKFLOW_PROCESS_SHORT_NAME,
  c_rec.DEFAULT_NOTIFY_RESP_ID,
  c_rec.DEFAULT_NOTIFY_RESP_SHORT_NAME,
  c_rec.COMPUTING_FUNCTION_ID,
  c_rec.REPORT_FUNCTION_ID,
  c_rec.UNIT_OF_MEASURE,
  c_rec.SYSTEM_FLAG,
  MSC_CL_COLLECTION.v_instance_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user );

  c_count:= c_count+1;

  IF c_count> MSC_CL_COLLECTION.PBS THEN
     COMMIT;
     c_count:= 0;
  END IF;

EXCEPTION
   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_BIS');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_BIS_TARGET_LEVELS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE

      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_BIS');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_BIS_TARGET_LEVELS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'TARGET_LEVEL_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.TARGET_LEVEL_ID);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'MEASURE_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.MEASURE_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORG_LEVEL_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.ORG_LEVEL_ID);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'TIME_LEVEL_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.TIME_LEVEL_ID);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;

COMMIT;

   END LOAD_BIS_TARGET_LEVELS;


   PROCEDURE LOAD_BIS_TARGETS IS

   CURSOR c3 IS
SELECT
TARGET_ID,
  TARGET_LEVEL_ID,
  BUSINESS_PLAN_ID,
  ORG_LEVEL_VALUE_ID,
  TIME_LEVEL_VALUE_ID,
  DIM1_LEVEL_VALUE_ID,
  DIM2_LEVEL_VALUE_ID,
  DIM3_LEVEL_VALUE_ID,
  DIM4_LEVEL_VALUE_ID,
  DIM5_LEVEL_VALUE_ID,
  TARGET,
  RANGE1_LOW,
  RANGE1_HIGH,
  RANGE2_LOW,
  RANGE2_HIGH,
  RANGE3_LOW,
  RANGE3_HIGH,
  NOTIFY_RESP1_ID,
  NOTIFY_RESP1_SHORT_NAME,
  NOTIFY_RESP2_ID,
  NOTIFY_RESP2_SHORT_NAME,
  NOTIFY_RESP3_ID,
  NOTIFY_RESP3_SHORT_NAME
FROM MSC_ST_BIS_TARGETS
WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

   c_count NUMBER:= 0;

   BEGIN

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_BIS_TARGETS', MSC_CL_COLLECTION.v_instance_id, NULL);

c_count:= 0;

FOR c_rec IN c3 LOOP

BEGIN

INSERT INTO MSC_BIS_TARGETS
( TARGET_ID,
  TARGET_LEVEL_ID,
  BUSINESS_PLAN_ID,
  ORG_LEVEL_VALUE_ID,
  TIME_LEVEL_VALUE_ID,
  DIM1_LEVEL_VALUE_ID,
  DIM2_LEVEL_VALUE_ID,
  DIM3_LEVEL_VALUE_ID,
  DIM4_LEVEL_VALUE_ID,
  DIM5_LEVEL_VALUE_ID,
  TARGET,
  RANGE1_LOW,
  RANGE1_HIGH,
  RANGE2_LOW,
  RANGE2_HIGH,
  RANGE3_LOW,
  RANGE3_HIGH,
  NOTIFY_RESP1_ID,
  NOTIFY_RESP1_SHORT_NAME,
  NOTIFY_RESP2_ID,
  NOTIFY_RESP2_SHORT_NAME,
  NOTIFY_RESP3_ID,
  NOTIFY_RESP3_SHORT_NAME,
  SR_INSTANCE_ID,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
( c_rec.TARGET_ID,
  c_rec.TARGET_LEVEL_ID,
  c_rec.BUSINESS_PLAN_ID,
  c_rec.ORG_LEVEL_VALUE_ID,
  c_rec.TIME_LEVEL_VALUE_ID,
  c_rec.DIM1_LEVEL_VALUE_ID,
  c_rec.DIM2_LEVEL_VALUE_ID,
  c_rec.DIM3_LEVEL_VALUE_ID,
  c_rec.DIM4_LEVEL_VALUE_ID,
  c_rec.DIM5_LEVEL_VALUE_ID,
  c_rec.TARGET,
  c_rec.RANGE1_LOW,
  c_rec.RANGE1_HIGH,
  c_rec.RANGE2_LOW,
  c_rec.RANGE2_HIGH,
  c_rec.RANGE3_LOW,
  c_rec.RANGE3_HIGH,
  c_rec.NOTIFY_RESP1_ID,
  c_rec.NOTIFY_RESP1_SHORT_NAME,
  c_rec.NOTIFY_RESP2_ID,
  c_rec.NOTIFY_RESP2_SHORT_NAME,
  c_rec.NOTIFY_RESP3_ID,
  c_rec.NOTIFY_RESP3_SHORT_NAME,
  MSC_CL_COLLECTION.v_instance_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user );

  c_count:= c_count+1;

  IF c_count> MSC_CL_COLLECTION.PBS THEN
     COMMIT;
     c_count:= 0;
  END IF;

EXCEPTION
   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_BIS');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_BIS_TARGETS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_BIS');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_BIS_TARGETS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'TARGET_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.TARGET_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'TARGET_LEVEL_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.TARGET_LEVEL_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'BUSINESS_PLAN_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.BUSINESS_PLAN_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORG_LEVEL_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.ORG_LEVEL_VALUE_ID);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'TIME_LEVEL_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.TIME_LEVEL_VALUE_ID);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;

END IF;

COMMIT;

   END LOAD_BIS_TARGETS;


   PROCEDURE LOAD_BIS_BUSINESS_PLANS IS

   CURSOR c4 IS
SELECT
  BUSINESS_PLAN_ID,
  SHORT_NAME,
  NAME,
  DESCRIPTION,
  VERSION_NO,
  CURRENT_PLAN_FLAG
FROM MSC_ST_BIS_BUSINESS_PLANS
WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

   c_count NUMBER:= 0;

   BEGIN

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_BIS_BUSINESS_PLANS', MSC_CL_COLLECTION.v_instance_id, NULL);

END IF;

c_count:= 0;

FOR c_rec IN c4 LOOP

BEGIN
INSERT INTO MSC_BIS_BUSINESS_PLANS
( BUSINESS_PLAN_ID,
  SHORT_NAME,
  NAME,
  DESCRIPTION,
  VERSION_NO,
  CURRENT_PLAN_FLAG,
  SR_INSTANCE_ID,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
( c_rec.BUSINESS_PLAN_ID,
  c_rec.SHORT_NAME,
  c_rec.NAME,
  c_rec.DESCRIPTION,
  c_rec.VERSION_NO,
  c_rec.CURRENT_PLAN_FLAG,
  MSC_CL_COLLECTION.v_instance_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user );

  c_count:= c_count+1;

  IF c_count> MSC_CL_COLLECTION.PBS THEN
     COMMIT;
     c_count:= 0;
  END IF;

EXCEPTION
   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_BIS');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_BIS_BUSINESS_PLANS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE

      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_BIS');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_BIS_BUSINESS_PLANS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'BUSINESS_PLAN_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.BUSINESS_PLAN_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'VERSION_NO');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.VERSION_NO));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;

COMMIT;

   END LOAD_BIS_BUSINESS_PLANS;


   PROCEDURE LOAD_BIS_PERIODS IS

   CURSOR c5 IS
SELECT
  ORGANIZATION_ID,
  PERIOD_SET_NAME,
  PERIOD_NAME,
  START_DATE,
  END_DATE,
  PERIOD_TYPE,
  PERIOD_YEAR,
  PERIOD_NUM,
  QUARTER_NUM,
  ENTERED_PERIOD_NAME,
  ADJUSTMENT_PERIOD_FLAG,
  DESCRIPTION,
  CONTEXT,
  YEAR_START_DATE,
  QUARTER_START_DATE
FROM MSC_ST_BIS_PERIODS
WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

   c_count NUMBER:= 0;

/************** LEGACY_CHANGE_START*************************/
   lv_rec_count  NUMBER:= 0;

/*****************LEGACY_CHANGE_ENDS************************/
   BEGIN

/************** LEGACY_CHANGE_START*************************/
     BEGIN


       SELECT  1
       INTO    lv_rec_count
       FROM    dual
       WHERE   EXISTS(SELECT 1
                      FROM   msc_st_bis_periods
                      WHERE  sr_instance_id = MSC_CL_COLLECTION.v_instance_id);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          lv_rec_count := 0;
      END;

  IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) or
     (MSC_CL_COLLECTION.v_instance_type = MSC_UTIL.G_INS_OTHER AND lv_rec_count > 0) THEN
    --MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_BIS_PERIODS', MSC_CL_COLLECTION.v_instance_id, NULL);

      IF (MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS) OR (MSC_CL_COLLECTION.v_coll_prec.org_group_flag IS NULL) THEN
        MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_BIS_PERIODS', MSC_CL_COLLECTION.v_instance_id,NULL);
      ELSE
        MSC_CL_COLLECTION.v_sub_str :=' AND ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
        MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_BIS_PERIODS', MSC_CL_COLLECTION.v_instance_id,NULL,MSC_CL_COLLECTION.v_sub_str);
      END IF;

  END IF;

/*****************LEGACY_CHANGE_ENDS************************/
c_count:= 0;

FOR c_rec IN c5 LOOP

BEGIN

INSERT INTO MSC_BIS_PERIODS
( ORGANIZATION_ID,
  PERIOD_SET_NAME,
  PERIOD_NAME,
  START_DATE,
  END_DATE,
  PERIOD_TYPE,
  PERIOD_YEAR,
  PERIOD_NUM,
  QUARTER_NUM,
  ENTERED_PERIOD_NAME,
  ADJUSTMENT_PERIOD_FLAG,
  DESCRIPTION,
  CONTEXT,
  YEAR_START_DATE,
  QUARTER_START_DATE,
  SR_INSTANCE_ID,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
( c_rec.ORGANIZATION_ID,
  c_rec.PERIOD_SET_NAME,
  c_rec.PERIOD_NAME,
  c_rec.START_DATE,
  c_rec.END_DATE,
  c_rec.PERIOD_TYPE,
  c_rec.PERIOD_YEAR,
  c_rec.PERIOD_NUM,
  c_rec.QUARTER_NUM,
  c_rec.ENTERED_PERIOD_NAME,
  c_rec.ADJUSTMENT_PERIOD_FLAG,
  c_rec.DESCRIPTION,
  c_rec.CONTEXT,
  c_rec.YEAR_START_DATE,
  c_rec.QUARTER_START_DATE,
  MSC_CL_COLLECTION.v_instance_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user );

  c_count:= c_count+1;

  IF c_count> MSC_CL_COLLECTION.PBS THEN
     COMMIT;
     c_count:= 0;
  END IF;

EXCEPTION

   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_BIS');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_BIS_PERIODS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_BIS');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_BIS_PERIODS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
      FND_MESSAGE.SET_TOKEN('VALUE',
                            MSC_GET_NAME.ORG_CODE( c_rec.ORGANIZATION_ID,
                                                   MSC_CL_COLLECTION.v_instance_id));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'PERIOD_SET_NAME');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.PERIOD_SET_NAME);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'PERIOD_NAME');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.PERIOD_NAME);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;

COMMIT;

   END LOAD_BIS_PERIODS;


-- ============ LOAD_ATP_RULES =================

   PROCEDURE LOAD_ATP_RULES IS

   CURSOR c1 IS
SELECT
   RULE_ID,
   RULE_NAME,
   DESCRIPTION,
   ACCUMULATE_AVAILABLE_FLAG,
   BACKWARD_CONSUMPTION_FLAG,
   FORWARD_CONSUMPTION_FLAG,
   PAST_DUE_DEMAND_CUTOFF_FENCE,
   PAST_DUE_SUPPLY_CUTOFF_FENCE,
   INFINITE_SUPPLY_FENCE_CODE,
   INFINITE_SUPPLY_TIME_FENCE,
   ACCEPTABLE_EARLY_FENCE,
   ACCEPTABLE_LATE_FENCE,
   DEFAULT_ATP_SOURCES,
   DEMAND_CLASS_ATP_FLAG,
   INCLUDE_SALES_ORDERS,
   INCLUDE_DISCRETE_WIP_DEMAND,
   INCLUDE_REP_WIP_DEMAND,
   INCLUDE_NONSTD_WIP_DEMAND,
   INCLUDE_DISCRETE_MPS,
   INCLUDE_USER_DEFINED_DEMAND,
   INCLUDE_PURCHASE_ORDERS,
   INCLUDE_DISCRETE_WIP_RECEIPTS,
   INCLUDE_REP_WIP_RECEIPTS,
   INCLUDE_NONSTD_WIP_RECEIPTS,
   INCLUDE_INTERORG_TRANSFERS,
   INCLUDE_ONHAND_AVAILABLE,
   INCLUDE_USER_DEFINED_SUPPLY,
   ACCUMULATION_WINDOW,
   INCLUDE_REP_MPS,
   INCLUDE_INTERNAL_REQS,
   INCLUDE_SUPPLIER_REQS,
   INCLUDE_INTERNAL_ORDERS,
   INCLUDE_FLOW_SCHEDULE_DEMAND,
   INCLUDE_FLOW_SCHEDULE_RECEIPTS,
   USER_ATP_SUPPLY_TABLE_NAME,
   USER_ATP_DEMAND_TABLE_NAME,
   MPS_DESIGNATOR,
   AGGREGATE_TIME_FENCE_CODE,
   AGGREGATE_TIME_FENCE
FROM MSC_ST_ATP_RULES
WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

   c_count NUMBER:= 0;

   BEGIN

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

   DELETE MSC_ATP_RULES
    WHERE sr_instance_id= MSC_CL_COLLECTION.v_instance_id;

   -- MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ATP_RULES', MSC_CL_COLLECTION.v_instance_id, NULL);

END IF;

c_count:= 0;

FOR c_rec IN c1 LOOP

BEGIN

INSERT INTO MSC_ATP_RULES
(  RULE_ID,
   RULE_NAME,
   DESCRIPTION,
   ACCUMULATE_AVAILABLE_FLAG,
   BACKWARD_CONSUMPTION_FLAG,
   FORWARD_CONSUMPTION_FLAG,
   PAST_DUE_DEMAND_CUTOFF_FENCE,
   PAST_DUE_SUPPLY_CUTOFF_FENCE,
   INFINITE_SUPPLY_FENCE_CODE,
   INFINITE_SUPPLY_TIME_FENCE,
   ACCEPTABLE_EARLY_FENCE,
   ACCEPTABLE_LATE_FENCE,
   DEFAULT_ATP_SOURCES,
   DEMAND_CLASS_ATP_FLAG,
   INCLUDE_SALES_ORDERS,
   INCLUDE_DISCRETE_WIP_DEMAND,
   INCLUDE_REP_WIP_DEMAND,
   INCLUDE_NONSTD_WIP_DEMAND,
   INCLUDE_DISCRETE_MPS,
   INCLUDE_USER_DEFINED_DEMAND,
   INCLUDE_PURCHASE_ORDERS,
   INCLUDE_DISCRETE_WIP_RECEIPTS,
   INCLUDE_REP_WIP_RECEIPTS,
   INCLUDE_NONSTD_WIP_RECEIPTS,
   INCLUDE_INTERORG_TRANSFERS,
   INCLUDE_ONHAND_AVAILABLE,
   INCLUDE_USER_DEFINED_SUPPLY,
   ACCUMULATION_WINDOW,
   INCLUDE_REP_MPS,
   INCLUDE_INTERNAL_REQS,
   INCLUDE_SUPPLIER_REQS,
   INCLUDE_INTERNAL_ORDERS,
   INCLUDE_FLOW_SCHEDULE_DEMAND,
   INCLUDE_FLOW_SCHEDULE_RECEIPTS,
   USER_ATP_SUPPLY_TABLE_NAME,
   USER_ATP_DEMAND_TABLE_NAME,
   MPS_DESIGNATOR,
   AGGREGATE_TIME_FENCE_CODE,
   AGGREGATE_TIME_FENCE,
   SR_INSTANCE_ID,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   CREATION_DATE,
   CREATED_BY)
VALUES
(  c_rec.RULE_ID,
   c_rec.RULE_NAME,
   c_rec.DESCRIPTION,
   c_rec.ACCUMULATE_AVAILABLE_FLAG,
   c_rec.BACKWARD_CONSUMPTION_FLAG,
   c_rec.FORWARD_CONSUMPTION_FLAG,
   c_rec.PAST_DUE_DEMAND_CUTOFF_FENCE,
   c_rec.PAST_DUE_SUPPLY_CUTOFF_FENCE,
   c_rec.INFINITE_SUPPLY_FENCE_CODE,
   c_rec.INFINITE_SUPPLY_TIME_FENCE,
   c_rec.ACCEPTABLE_EARLY_FENCE,
   c_rec.ACCEPTABLE_LATE_FENCE,
   c_rec.DEFAULT_ATP_SOURCES,
   c_rec.DEMAND_CLASS_ATP_FLAG,
   c_rec.INCLUDE_SALES_ORDERS,
   c_rec.INCLUDE_DISCRETE_WIP_DEMAND,
   c_rec.INCLUDE_REP_WIP_DEMAND,
   c_rec.INCLUDE_NONSTD_WIP_DEMAND,
   c_rec.INCLUDE_DISCRETE_MPS,
   c_rec.INCLUDE_USER_DEFINED_DEMAND,
   c_rec.INCLUDE_PURCHASE_ORDERS,
   c_rec.INCLUDE_DISCRETE_WIP_RECEIPTS,
   c_rec.INCLUDE_REP_WIP_RECEIPTS,
   c_rec.INCLUDE_NONSTD_WIP_RECEIPTS,
   c_rec.INCLUDE_INTERORG_TRANSFERS,
   c_rec.INCLUDE_ONHAND_AVAILABLE,
   c_rec.INCLUDE_USER_DEFINED_SUPPLY,
   c_rec.ACCUMULATION_WINDOW,
   c_rec.INCLUDE_REP_MPS,
   c_rec.INCLUDE_INTERNAL_REQS,
   c_rec.INCLUDE_SUPPLIER_REQS,
   c_rec.INCLUDE_INTERNAL_ORDERS,
   c_rec.INCLUDE_FLOW_SCHEDULE_DEMAND,
   c_rec.INCLUDE_FLOW_SCHEDULE_RECEIPTS,
   c_rec.USER_ATP_SUPPLY_TABLE_NAME,
   c_rec.USER_ATP_DEMAND_TABLE_NAME,
   c_rec.MPS_DESIGNATOR,
   c_rec.AGGREGATE_TIME_FENCE_CODE,
   c_rec.AGGREGATE_TIME_FENCE,
   MSC_CL_COLLECTION.v_instance_id,
   MSC_CL_COLLECTION.v_current_date,
   MSC_CL_COLLECTION.v_current_user,
   MSC_CL_COLLECTION.v_current_date,
   MSC_CL_COLLECTION.v_current_user );
/*
  c_count:= c_count+1;

  IF c_count> MSC_CL_COLLECTION.PBS THEN
     COMMIT;
     c_count:= 0;
  END IF;
*/
EXCEPTION

   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_ATP_RULES');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ATP_RULES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_ATP_RULES');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ATP_RULES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'RULE_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.RULE_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'RULE_NAME');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.RULE_NAME);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;

COMMIT;

   END LOAD_ATP_RULES;


-- ============= PLANNERS ===================
PROCEDURE LOAD_PLANNERS IS

   CURSOR c1 IS
SELECT
   x.PLANNER_CODE,
   x.ORGANIZATION_ID,
   x.DESCRIPTION,
   x.DISABLE_DATE,
   x.ELECTRONIC_MAIL_ADDRESS,
   x.EMPLOYEE_ID,
   x.CURRENT_EMPLOYEE_FLAG,
   x.USER_NAME
  FROM MSC_ST_PLANNERS x
 WHERE x.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

 /* added this cursor for bug: 1121172 */
   CURSOR c2 IS
SELECT x.USER_NAME,
       x.ELECTRONIC_MAIL_ADDRESS,
       x.EMPLOYEE_ID,
       x.ORGANIZATION_ID
   FROM MSC_ST_PLANNERS x,
	FND_USER y
   WHERE UPPER(x.USER_NAME) = y.USER_NAME
	AND x.CURRENT_EMPLOYEE_FLAG = 1
	AND x.EMPLOYEE_ID IS NOT NULL
        AND x.ELECTRONIC_MAIL_ADDRESS IS NOT NULL
        AND x.SR_INSTANCE_ID = MSC_CL_COLLECTION.v_instance_id;

   c_count NUMBER:= 0;

BEGIN

IF (MSC_CL_COLLECTION.v_is_complete_refresh or MSC_CL_COLLECTION.v_is_partial_refresh) THEN

--MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_PLANNERS', MSC_CL_COLLECTION.v_instance_id, NULL);
  IF MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_PLANNERS', MSC_CL_COLLECTION.v_instance_id,NULL);
  ELSE
    MSC_CL_COLLECTION.v_sub_str :=' AND ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_PLANNERS', MSC_CL_COLLECTION.v_instance_id,NULL,MSC_CL_COLLECTION.v_sub_str);
  END IF;

c_count:= 0;

FOR c_rec IN c1 LOOP

BEGIN

INSERT INTO MSC_PLANNERS
(  PLANNER_CODE,
   ORGANIZATION_ID,
   DESCRIPTION,
   DISABLE_DATE,
   ELECTRONIC_MAIL_ADDRESS,
   EMPLOYEE_ID,
   CURRENT_EMPLOYEE_FLAG,
   USER_NAME,
   SR_INSTANCE_ID,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   CREATION_DATE,
   CREATED_BY)
VALUES
(  c_rec.PLANNER_CODE,
   c_rec.ORGANIZATION_ID,
   c_rec.DESCRIPTION,
   c_rec.DISABLE_DATE,
   c_rec.ELECTRONIC_MAIL_ADDRESS,
   c_rec.EMPLOYEE_ID,
   c_rec.CURRENT_EMPLOYEE_FLAG,
   c_rec.USER_NAME,
   MSC_CL_COLLECTION.v_instance_id,
   MSC_CL_COLLECTION.v_current_date,
   MSC_CL_COLLECTION.v_current_user,
   MSC_CL_COLLECTION.v_current_date,
   MSC_CL_COLLECTION.v_current_user );

  c_count:= c_count+1;

  IF c_count> MSC_CL_COLLECTION.PBS THEN
     COMMIT;
     c_count:= 0;
  END IF;

EXCEPTION

   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_PLANNERS');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_PLANNERS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_PLANNERS');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_PLANNERS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
      FND_MESSAGE.SET_TOKEN('VALUE',
                            MSC_GET_NAME.ORG_CODE( c_rec.ORGANIZATION_ID,
                                                   MSC_CL_COLLECTION.v_instance_id));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'PLANNER_CODE');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.PLANNER_CODE);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;

COMMIT;

/* For Bug: 1121172, update the E-mail address of the planner*/
FOR c_rec IN c2 LOOP

BEGIN
 UPDATE FND_USER
 SET EMAIL_ADDRESS = c_rec.ELECTRONIC_MAIL_ADDRESS
 WHERE USER_NAME = UPPER(c_rec.USER_NAME);

EXCEPTION

   WHEN OTHERS THEN

      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_PLANNERS');
      FND_MESSAGE.SET_TOKEN('TABLE', 'FND_USER');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'USER_NAME');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.USER_NAME);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

END;

END LOOP;

COMMIT;

END IF;

END LOAD_PLANNERS;

-- ============= DEMAND_CLASS ===================
PROCEDURE LOAD_DEMAND_CLASS IS

   CURSOR c1 IS
SELECT
  msrg.DEMAND_CLASS,
  msrg.MEANING,
  msrg.DESCRIPTION,
  msrg.FROM_DATE,
  msrg.TO_DATE,
  msrg.ENABLED_FLAG
FROM MSC_ST_DEMAND_CLASSES msrg
WHERE msrg.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

   c_count NUMBER:= 0;

BEGIN

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_DEMAND_CLASSES', MSC_CL_COLLECTION.v_instance_id, NULL);

END IF;

-- IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

FOR c_rec IN c1 LOOP

BEGIN

IF MSC_CL_COLLECTION.v_is_legacy_refresh THEN

UPDATE MSC_DEMAND_CLASSES
SET
 MEANING = c_rec.MEANING,
 DESCRIPTION = c_rec.DESCRIPTION,
 FROM_DATE = c_rec.FROM_DATE,
 TO_DATE = c_rec.TO_DATE,
 ENABLED_FLAG = c_rec.ENABLED_FLAG,
 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND DEMAND_CLASS = c_rec.DEMAND_CLASS;

END IF;

IF (MSC_CL_COLLECTION.v_is_complete_refresh or MSC_CL_COLLECTION.v_is_partial_refresh) OR (MSC_CL_COLLECTION.v_is_legacy_refresh AND SQL%NOTFOUND) THEN

INSERT INTO MSC_DEMAND_CLASSES
( DEMAND_CLASS,
  MEANING,
  DESCRIPTION,
  FROM_DATE,
  TO_DATE,
  ENABLED_FLAG,
  SR_INSTANCE_ID,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
( c_rec.DEMAND_CLASS,
  c_rec.MEANING,
  c_rec.DESCRIPTION,
  c_rec.FROM_DATE,
  c_rec.TO_DATE,
  c_rec.ENABLED_FLAG,
  MSC_CL_COLLECTION.v_instance_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user );

END IF;

EXCEPTION
   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_DEMAND_CLASS');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_DEMAND_CLASSES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE

      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_DEMAND_CLASS');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_DEMAND_CLASSES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'DEMAND_CLASS');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.DEMAND_CLASS);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;

COMMIT;

END LOAD_DEMAND_CLASS;

PROCEDURE LOAD_SALES_CHANNEL IS
   CURSOR c1 IS
SELECT
  mssc.SALES_CHANNEL,
  mssc.MEANING,
  mssc.DESCRIPTION,
  mssc.FROM_DATE,
  mssc.TO_DATE,
  mssc.ENABLED_FLAG
FROM MSC_ST_SALES_CHANNEL mssc
WHERE mssc.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

   c_count NUMBER:= 0;

BEGIN
    IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

    MSC_CL_COLLECTION.DELETE_MSC_TABLE ('MSC_SALES_CHANNEL', MSC_CL_COLLECTION.v_instance_id, NULL);
        END IF;

FOR c_rec IN c1 LOOP

BEGIN

IF MSC_CL_COLLECTION.v_is_legacy_refresh THEN
UPDATE MSC_SR_LOOKUPS
SET
 MEANING = c_rec.MEANING,
 DESCRIPTION = c_rec.DESCRIPTION,
 FROM_DATE = c_rec.FROM_DATE,
 TO_DATE = c_rec.TO_DATE,
 ENABLED_FLAG = c_rec.ENABLED_FLAG,
 REFRESH_NUMBER = MSC_CL_COLLECTION.v_last_collection_id,
 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND LOOKUP_CODE = c_rec.SALES_CHANNEL
  AND LOOKUP_TYPE = 'SALES_CHANNEL';

END IF;

IF (MSC_CL_COLLECTION.v_is_complete_refresh or MSC_CL_COLLECTION.v_is_partial_refresh) OR (MSC_CL_COLLECTION.v_is_legacy_refresh AND SQL%NOTFOUND) THEN
INSERT INTO MSC_SR_LOOKUPS (
  LOOKUP_TYPE,
  LOOKUP_CODE,
  MEANING,
  DESCRIPTION,
  FROM_DATE,
  TO_DATE,
  ENABLED_FLAG,
  REFRESH_NUMBER,
  SR_INSTANCE_ID,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
  ('SALES_CHANNEL',
  c_rec.SALES_CHANNEL,
  c_rec.MEANING,
  c_rec.DESCRIPTION,
  c_rec.FROM_DATE,
  c_rec.TO_DATE,
  c_rec.ENABLED_FLAG,
  MSC_CL_COLLECTION.v_last_collection_id,
  MSC_CL_COLLECTION.v_instance_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user);

END IF;

EXCEPTION
   WHEN OTHERS THEN

      --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'An error has occurred.');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
END;

END LOOP;

COMMIT;

END LOAD_SALES_CHANNEL;


PROCEDURE LOAD_FISCAL_CALENDAR IS
   CURSOR c1 IS
SELECT
    mscm.CALENDAR_CODE,
    mscm.YEAR,
    mscm.YEAR_DESCRIPTION,
    mscm.YEAR_START_DATE,
    mscm.YEAR_END_DATE,
    mscm.QUARTER,
    mscm.QUARTER_DESCRIPTION,
    mscm.QUARTER_START_DATE,
    mscm.QUARTER_END_DATE,
    mscm.MONTH,
    mscm.MONTH_DESCRIPTION,
    mscm.MONTH_START_DATE,
    mscm.MONTH_END_DATE
FROM MSC_ST_CALENDAR_MONTHS mscm
WHERE mscm.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

   c_count NUMBER:= 0;
BEGIN

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

MSC_CL_COLLECTION.DELETE_MSC_TABLE ('MSC_CALENDARS', MSC_CL_COLLECTION.v_instance_id, Null, 'AND CALENDAR_TYPE=''FISCAL''');
MSC_CL_COLLECTION.DELETE_MSC_TABLE ('MSC_CALENDAR_MONTHS', MSC_CL_COLLECTION.v_instance_id, NULL);

    INSERT INTO MSC_CALENDARS
     (
      CALENDAR_CODE,
      CALENDAR_TYPE,
      REFRESH_ID,
      SR_INSTANCE_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY
     )
SELECT
  		DISTINCT
      CALENDAR_CODE,
      CALENDAR_TYPE,
      MSC_CL_COLLECTION.v_last_collection_id,
      MSC_CL_COLLECTION.v_instance_id,
      MSC_CL_COLLECTION.v_current_date,
      MSC_CL_COLLECTION.v_current_user,
      MSC_CL_COLLECTION.v_current_date,
      MSC_CL_COLLECTION.v_current_user
      FROM 	MSC_ST_CALENDAR_MONTHS
      WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
      AND   CALENDAR_TYPE  = 'FISCAL';

    COMMIT;
END IF;

FOR c_rec IN c1 LOOP
  BEGIN

    IF MSC_CL_COLLECTION.v_is_legacy_refresh THEN

    UPDATE MSC_CALENDARS
    SET
     REFRESH_NUMBER = MSC_CL_COLLECTION.v_last_collection_id,
     LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
     LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
    WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
      AND CALENDAR_CODE = c_rec.calendar_code
      AND CALENDAR_TYPE = 'FISCAL';

    END IF;

    IF (MSC_CL_COLLECTION.v_is_legacy_refresh AND SQL%NOTFOUND) THEN
        INSERT INTO MSC_CALENDARS
    (     CALENDAR_CODE,
          CALENDAR_TYPE,
          REFRESH_NUMBER,
          SR_INSTANCE_ID,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY
          )
    VALUES
    (     c_rec.CALENDAR_CODE,
          'FISCAL',
          MSC_CL_COLLECTION.v_last_collection_id,
          MSC_CL_COLLECTION.v_instance_id,
          MSC_CL_COLLECTION.v_current_date,
          MSC_CL_COLLECTION.v_current_user,
          MSC_CL_COLLECTION.v_current_date,
          MSC_CL_COLLECTION.v_current_user
    );

    END IF;
EXCEPTION
   WHEN OTHERS THEN

      --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'An error has occurred.');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
  END;

BEGIN

IF MSC_CL_COLLECTION.v_is_legacy_refresh THEN

UPDATE MSC_CALENDAR_MONTHS
SET
	YEAR = c_rec.YEAR,
	YEAR_DESCRIPTION = c_rec.YEAR_DESCRIPTION,
  YEAR_START_DATE = c_rec.YEAR_START_DATE,
  YEAR_END_DATE = c_rec.YEAR_END_DATE,
  QUARTER = c_rec.QUARTER,
  QUARTER_DESCRIPTION = c_rec.QUARTER_DESCRIPTION,
  QUARTER_START_DATE = c_rec.QUARTER_START_DATE,
  QUARTER_END_DATE = c_rec.QUARTER_END_DATE,
  MONTH = c_rec.MONTH,
  MONTH_DESCRIPTION = c_rec.MONTH_DESCRIPTION,
  MONTH_START_DATE = c_rec.MONTH_START_DATE,
  MONTH_END_DATE = c_rec.MONTH_END_DATE,
  REFRESH_NUMBER = MSC_CL_COLLECTION.v_last_collection_id,
  LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
  LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE
  SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND CALENDAR_CODE = c_rec.calendar_code
  AND CALENDAR_TYPE= 'FISCAL'
  AND YEAR = c_rec.YEAR
  AND MONTH = c_rec.MONTH;

END IF;


IF (MSC_CL_COLLECTION.v_is_complete_refresh or MSC_CL_COLLECTION.v_is_partial_refresh) OR (MSC_CL_COLLECTION.v_is_legacy_refresh AND SQL%NOTFOUND) THEN

INSERT INTO MSC_CALENDAR_MONTHS (
    CALENDAR_CODE,
    CALENDAR_TYPE,
    YEAR,
    YEAR_DESCRIPTION,
    YEAR_START_DATE,
    YEAR_END_DATE,
    QUARTER,
    QUARTER_DESCRIPTION,
    QUARTER_START_DATE,
    QUARTER_END_DATE,
    MONTH,
    MONTH_DESCRIPTION,
    MONTH_START_DATE,
    MONTH_END_DATE,
    REFRESH_NUMBER,
    SR_INSTANCE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN)
Values (
    c_rec.CALENDAR_CODE,
    'FISCAL',
    c_rec.YEAR,
    c_rec.YEAR_DESCRIPTION,
    c_rec.YEAR_START_DATE,
    c_rec.YEAR_END_DATE,
    c_rec.QUARTER,
    c_rec.QUARTER_DESCRIPTION,
    c_rec.QUARTER_START_DATE,
    c_rec.QUARTER_END_DATE,
    c_rec.MONTH,
    c_rec.MONTH_DESCRIPTION,
    c_rec.MONTH_START_DATE,
    c_rec.MONTH_END_DATE,
    MSC_CL_COLLECTION.v_last_collection_id,
    MSC_CL_COLLECTION.v_instance_id,
    MSC_CL_COLLECTION.v_current_date,
    MSC_CL_COLLECTION.v_current_user,
    MSC_CL_COLLECTION.v_current_date,
    MSC_CL_COLLECTION.v_current_user,
    MSC_CL_COLLECTION.v_current_user
);


END IF;

COMMIT;

EXCEPTION
   WHEN OTHERS THEN

      --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'An error has occurred.');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
END;

END LOOP;

COMMIT;


END LOAD_FISCAL_CALENDAR;

/* LOAD_TRIP added for Collecting Trip and Trip Stops for Deployment Planning */
PROCEDURE LOAD_TRIP IS

   CURSOR c1 IS
SELECT
  mst.TRIP_ID,
  mst.NAME,
  mst.SHIP_METHOD_CODE,
  mst.PLANNED_FLAG,
  mst.STATUS_CODE,
  mst.WEIGHT_CAPACITY,
  mst.WEIGHT_UOM,
  mst.VOLUME_CAPACITY,
  mst.VOLUME_UOM,
  mst.SR_INSTANCE_ID
FROM MSC_ST_TRIPS mst
WHERE mst.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND mst.DELETED_FLAG= MSC_UTIL.SYS_NO;

   CURSOR c1_d IS
SELECT
  mst.TRIP_ID,
  mst.SR_INSTANCE_ID
FROM MSC_ST_TRIPS mst
WHERE mst.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND mst.DELETED_FLAG= MSC_UTIL.SYS_YES;

CURSOR c2 IS
SELECT
   STOP_ID,
   STOP_LOCATION_ID,
   STATUS_CODE,
   STOP_SEQUENCE_NUMBER,
   PLANNED_ARRIVAL_DATE,
   PLANNED_DEPARTURE_DATE,
   TRIP_ID,
  mst.SR_INSTANCE_ID
FROM MSC_ST_TRIP_STOPS mst
WHERE mst.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND mst.DELETED_FLAG= MSC_UTIL.SYS_NO;

   CURSOR c2_d IS
SELECT
  mst.STOP_ID,
  mst.SR_INSTANCE_ID
FROM MSC_ST_TRIP_STOPS mst
WHERE mst.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND mst.DELETED_FLAG= MSC_UTIL.SYS_YES;


c_count NUMBER:= 0;
   lv_tbl      VARCHAR2(30);
   lv_sql_stmt VARCHAR2(5000);

BEGIN

IF MSC_CL_COLLECTION.v_apps_ver >= MSC_UTIL.G_APPS115 THEN

  IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_TRIPS', MSC_CL_COLLECTION.v_instance_id, -1);

    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_TRIP_STOPS', MSC_CL_COLLECTION.v_instance_id, -1);

  END IF;   -- MSC_CL_COLLECTION.v_is_complete_refresh

  IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

    FOR c_rec IN c1_d LOOP

      DELETE MSC_TRIPS
      WHERE PLAN_ID= -1
      AND TRIP_ID= c_rec.TRIP_ID
      AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID;

    END LOOP;

    FOR c_rec IN c2_d LOOP

      DELETE MSC_TRIP_STOPS
      WHERE PLAN_ID= -1
      AND STOP_ID= c_rec.STOP_ID
      AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID;

    END LOOP;

  END IF;

  c_count:= 0;

  FOR c_rec IN c1 LOOP

  BEGIN

    IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

    UPDATE MSC_TRIPS
    SET
   	NAME = c_rec.NAME,
   	SHIP_METHOD_CODE = c_rec.SHIP_METHOD_CODE,
   	PLANNED_FLAG = c_rec.PLANNED_FLAG,
   	STATUS_CODE = c_rec.STATUS_CODE,
   	WEIGHT_CAPACITY = c_rec.WEIGHT_CAPACITY,
   	WEIGHT_UOM = c_rec.WEIGHT_UOM,
   	VOLUME_CAPACITY = c_rec.VOLUME_CAPACITY,
   	VOLUME_UOM = c_rec.VOLUME_UOM,
   	REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
   	LAST_UPDATED_BY = MSC_CL_COLLECTION.v_current_user,
   	LAST_UPDATE_DATE = MSC_CL_COLLECTION.v_current_date,
   	LAST_UPDATE_LOGIN = MSC_CL_COLLECTION.v_current_user
    WHERE PLAN_ID= -1
  	AND TRIP_ID= c_rec.TRIP_ID
  	AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID;

    END IF;

    IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

      INSERT INTO MSC_TRIPS
        ( PLAN_ID,
          TRIP_ID,
  	  NAME,
          SHIP_METHOD_CODE,
  	  PLANNED_FLAG,
  	  STATUS_CODE,
          WEIGHT_CAPACITY,
  	  WEIGHT_UOM,
  	  VOLUME_CAPACITY,
  	  VOLUME_UOM,
  	  SR_INSTANCE_ID,
  	  REFRESH_NUMBER,
  	  LAST_UPDATE_DATE,
  	  LAST_UPDATED_BY,
  	  CREATION_DATE,
  	  CREATED_BY)
      	VALUES
	( -1,
        c_rec.TRIP_ID,
  	c_rec.NAME,
  	c_rec.SHIP_METHOD_CODE,
  	c_rec.PLANNED_FLAG,
  	c_rec.STATUS_CODE,
        c_rec.WEIGHT_CAPACITY,
        c_rec.WEIGHT_UOM,
        c_rec.VOLUME_CAPACITY,
        c_rec.VOLUME_UOM,
        c_rec.SR_INSTANCE_ID,
        MSC_CL_COLLECTION.v_last_collection_id,
        MSC_CL_COLLECTION.v_current_date,
        MSC_CL_COLLECTION.v_current_user,
        MSC_CL_COLLECTION.v_current_date,
        MSC_CL_COLLECTION.v_current_user );

       END IF;  --SQL%NOTFOUND

       c_count:= c_count+1;

       IF c_count> MSC_CL_COLLECTION.PBS THEN
         COMMIT;
         c_count:= 0;
       END IF;

       EXCEPTION WHEN OTHERS THEN

         IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN

           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      	   FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
           FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_TRIP');
           FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_TRIPS');
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
           RAISE;

         ELSE
           MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
           FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
           FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_TRIP');
           FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_TRIPS');
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);


           FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
           FND_MESSAGE.SET_TOKEN('COLUMN', 'NAME');
           FND_MESSAGE.SET_TOKEN('VALUE', c_rec.NAME);
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

        END IF;

      END;

    END LOOP;


    c_count:= 0;

    FOR c_rec IN c2 LOOP

      BEGIN

        IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

          UPDATE MSC_TRIP_STOPS
            SET
      		STOP_LOCATION_ID = c_rec.STOP_LOCATION_ID,
   		STATUS_CODE = c_rec.STATUS_CODE,
   		STOP_SEQUENCE_NUMBER = c_rec.STOP_SEQUENCE_NUMBER,
   		PLANNED_ARRIVAL_DATE = c_rec.PLANNED_ARRIVAL_DATE,
   		PLANNED_DEPARTURE_DATE = c_rec.PLANNED_DEPARTURE_DATE,
   		TRIP_ID = c_rec.TRIP_ID,
   		REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
   		LAST_UPDATED_BY = MSC_CL_COLLECTION.v_current_user,
   		LAST_UPDATE_DATE = MSC_CL_COLLECTION.v_current_date,
   		LAST_UPDATE_LOGIN = MSC_CL_COLLECTION.v_current_user
	      WHERE PLAN_ID= -1
  		AND STOP_ID= c_rec.STOP_ID
  		AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID;

	END IF;

        IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

	    INSERT INTO MSC_TRIP_STOPS
	      ( PLAN_ID,
  		STOP_ID,
  		STOP_LOCATION_ID,
  		STATUS_CODE,
  		STOP_SEQUENCE_NUMBER,
  		PLANNED_ARRIVAL_DATE,
  		PLANNED_DEPARTURE_DATE,
  		TRIP_ID,
  		SR_INSTANCE_ID,
  		REFRESH_NUMBER,
  		LAST_UPDATE_DATE,
  		LAST_UPDATED_BY,
  		CREATION_DATE,
  		CREATED_BY)
	    VALUES
	      ( -1,
  		c_rec.STOP_ID,
  		c_rec.STOP_LOCATION_ID,
  		c_rec.STATUS_CODE,
  		c_rec.STOP_SEQUENCE_NUMBER,
  		c_rec.PLANNED_ARRIVAL_DATE,
  		c_rec.PLANNED_DEPARTURE_DATE,
  		c_rec.TRIP_ID,
  		c_rec.SR_INSTANCE_ID,
  		MSC_CL_COLLECTION.v_last_collection_id,
  		MSC_CL_COLLECTION.v_current_date,
  		MSC_CL_COLLECTION.v_current_user,
  		MSC_CL_COLLECTION.v_current_date,
  		MSC_CL_COLLECTION.v_current_user );

        END IF;  --SQL%NOTFOUND

        c_count:= c_count+1;

        IF c_count> MSC_CL_COLLECTION.PBS THEN
   	  COMMIT;
          c_count:= 0;
        END IF;

        EXCEPTION WHEN OTHERS THEN

    	  IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN

      		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      		FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      		FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_TRIP');
      		FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_TRIP_STOPS');
      		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      		RAISE;

    	      ELSE
      		MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      		FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      		FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_TRIP');
      		FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_TRIP_STOPS');
      		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);


		FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      		FND_MESSAGE.SET_TOKEN('COLUMN', 'STOP_ID');
      		FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR( c_rec.STOP_ID));
      		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

    	  END IF;

        END;

      END LOOP;

     COMMIT;

  END IF; -- v_apps_ver >= G_APPS115
END LOAD_TRIP;

--- for bug # 6469722
PROCEDURE LOAD_CURRENCY_CONVERSION IS

cnt number := 0;
reqid number;
v_sql_stmt VARCHAR2(2000);

BEGIN

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

Begin
  select 1 into cnt from MSC_CURRENCY_CONVERSIONS
  where (to_currency = MSC_CL_OTHER_PULL.G_MSC_HUB_CURR_CODE and
	conv_type = MSC_CL_OTHER_PULL.G_MSC_CURR_CONV_TYPE)
  and rownum < 2;

   exception
   	when no_data_found then
        cnt :=0;

end;


  If (cnt = 0)  then
          MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE('MSC_CURRENCY_CONVERSIONS');
  End if;


MERGE INTO MSC_CURRENCY_CONVERSIONS mcc
USING (Select * from MSC_ST_CURRENCY_CONVERSIONS where sr_instance_id = MSC_CL_COLLECTION.v_instance_id) mst
ON (mcc.from_currency = mst.from_currency
    AND mcc.to_currency = mst.to_currency
    AND mcc.conv_date = mst.conv_date
    AND mcc.conv_type = mst.conv_type
    AND mcc.conv_type = MSC_CL_OTHER_PULL.G_MSC_CURR_CONV_TYPE)
WHEN MATCHED THEN
  UPDATE SET mcc.conv_rate = mst.conv_rate,
	     mcc.last_coll_instance_id = mst.sr_instance_id
WHEN NOT MATCHED THEN
  INSERT (mcc.last_coll_instance_id,mcc.from_currency,mcc.to_currency,mcc.conv_date,mcc.conv_type,mcc.conv_rate,mcc.creation_date,mcc.created_by,mcc.last_update_date,mcc.last_updated_by,mcc.last_update_login,mcc.rn)
  VALUES (mst.sr_instance_id,mst.from_currency,mst.to_currency,mst.conv_date,mst.conv_type,mst.conv_rate,mst.creation_date,mst.created_by,mst.last_update_date,mst.last_updated_by,mst.last_update_login,mst.rn);
COMMIT;
END IF;

Begin
/* Submit the CP for Purging old rows   */

reqid := FND_REQUEST.SUBMIT_REQUEST('MSC',
			    'MSCCLMISC',
                             Null,
			     Null,
			     False,
			     'MSC_CL_OTHER_ODS_LOAD',
                             'PURGE_STALE_CURRENCY_CONV',
			     Null);
commit ;
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Submitted CP for purge stale currency data. '|| reqid);
EXCEPTION
   WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
End;

Begin
 /* submit CP for refreshing MV */
 reqid := FND_REQUEST.SUBMIT_REQUEST('MSC',
			    'MSCCLMISC',
                             Null,
			     Null,
			     False,
			     'MSC_PHUB_PKG',
                             'REFRESH_MVS',
			     1);
commit ;
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Submitted CP to refresh MV. '|| reqid);
EXCEPTION
   WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
End;

EXCEPTION
   WHEN OTHERS THEN

      --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'An error has occurred.');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

END LOAD_CURRENCY_CONVERSION;

PROCEDURE LOAD_DELIVERY_DETAILS  IS -- for bug 6730983
lv_sql_stmt     	     VARCHAR2(32767);
i                      NUMBER := -1;
reqid                  number;
BEGIN
IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN
/* Updating Who cols of Staging Tables */
    UPDATE MSC_ST_DELIVERY_DETAILS
    SET
        REFRESH_NUMBER    = MSC_CL_COLLECTION.v_last_collection_id,
        LAST_UPDATE_DATE  = MSC_CL_COLLECTION.v_current_date,
        LAST_UPDATED_BY   = MSC_CL_COLLECTION.v_current_user,
        CREATION_DATE     = MSC_CL_COLLECTION.v_current_date,
        CREATED_BY        = MSC_CL_COLLECTION.v_current_user,
        LAST_UPDATE_LOGIN =MSC_CL_COLLECTION.v_current_user
     WHERE SR_INSTANCE_ID = MSC_CL_COLLECTION.v_instance_id;

 COMMIT;

      /* Initialize the list */
           IF NOT MSC_CL_EXCHANGE_PARTTBL.Initialize_SWAP_Tbl_List(MSC_CL_COLLECTION.v_instance_id,MSC_CL_COLLECTION.v_instance_code)   THEN
                  RAISE MSC_CL_COLLECTION.EXCHANGE_PARTN_ERROR;
           END IF;
      /* Get the swap table index number in the list*/
           i := MSC_CL_EXCHANGE_PARTTBL.get_SWAP_table_index('MSC_DELIVERY_DETAILS'); --ods table name
      IF i = -1 THEN
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Table not in the list of SWAP partition');
        RAISE MSC_CL_COLLECTION.EXCHANGE_PARTN_ERROR;
      END IF;
      /* Do phase 1 exchange*/

      IF NOT MSC_CL_EXCHANGE_PARTTBL.EXCHANGE_SINGLE_TAB_PARTN (
                    MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).stg_table_name,
                    MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).stg_table_partn_name,
                    MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).temp_table_name,
                                              MSC_UTIL.SYS_NO  ) THEN
                    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Exchange partition failed');
         RAISE MSC_CL_COLLECTION.EXCHANGE_PARTN_ERROR;
      END IF;

             EXECUTE IMMEDIATE ' Update msc_coll_parameters set  '
      || MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).column_name || ' = '
      || MSC_CL_COLLECTION.G_STG_ODS_SWP_PHASE_1
      || ' where instance_id = ' || MSC_CL_COLLECTION.v_instance_id;

commit;
      /* Add code to copy required data from ods table to this temp table*/

     lv_sql_stmt := ' INSERT INTO '||MSC_CL_EXCHANGE_PARTTBL.v_swapTblList(i).temp_table_name
       ||' ('
||'        SR_INSTANCE_ID,'
||'        DELIVERY_DETAIL_ID,'
||'        SOURCE_CODE,'
||'        SOURCE_HEADER_ID,'
||'        SOURCE_LINE_ID,'
||'        SOURCE_HEADER_NUMBER,'
||'        SHIP_SET_ID,'
||'        ARRIVAL_SET_ID,'
||'        SHIP_FROM_LOCATION_ID,'
||'        ORGANIZATION_ID,'
||'        SHIP_TO_LOCATION_ID,'
||'        SHIP_TO_SITE_USE_ID,'
||'        DELIVER_TO_LOCATION_ID,'
||'        DELIVER_TO_SITE_USE_ID,'
||'        CANCELLED_QUANTITY,'
||'        REQUESTED_QUANTITY,'
||'        REQUESTED_QUANTITY_UOM,'
||'        SHIPPED_QUANTITY,'
||'        DELIVERED_QUANTITY,'
||'        DATE_REQUESTED,'
||'        DATE_SCHEDULED,'
||'        OPERATING_UNIT,'
||'        INV_INTERFACED_FLAG,'
||'        EARLIEST_PICKUP_DATE,'
||'        LATEST_PICKUP_DATE,'
||'        EARLIEST_DROPOFF_DATE,'
||'        LATEST_DROPOFF_DATE,'
||'        REFRESH_NUMBER,'
||'        LAST_UPDATE_DATE,'
||'        LAST_UPDATED_BY,'
||'        CREATION_DATE,'
||'        CREATED_BY,'
||'        LAST_UPDATE_LOGIN'
||'        )      '
||'        SELECT'
||'        SR_INSTANCE_ID,'
||'        DELIVERY_DETAIL_ID,'
||'        SOURCE_CODE,'
||'        SOURCE_HEADER_ID,'
||'        SOURCE_LINE_ID,'
||'        SOURCE_HEADER_NUMBER,'
||'        SHIP_SET_ID,'
||'        ARRIVAL_SET_ID,'
||'        SHIP_FROM_LOCATION_ID,'
||'        ORGANIZATION_ID,'
||'        SHIP_TO_LOCATION_ID,'
||'        SHIP_TO_SITE_USE_ID,'
||'        DELIVER_TO_LOCATION_ID,'
||'        DELIVER_TO_SITE_USE_ID,'
||'        CANCELLED_QUANTITY,'
||'        REQUESTED_QUANTITY,'
||'        REQUESTED_QUANTITY_UOM,'
||'        SHIPPED_QUANTITY,'
||'        DELIVERED_QUANTITY,'
||'        DATE_REQUESTED,'
||'        DATE_SCHEDULED,'
||'        OPERATING_UNIT,'
||'        INV_INTERFACED_FLAG,'
||'        EARLIEST_PICKUP_DATE,'
||'        LATEST_PICKUP_DATE,'
||'        EARLIEST_DROPOFF_DATE,'
||'        LATEST_DROPOFF_DATE,'
||'        REFRESH_NUMBER,'
||'        LAST_UPDATE_DATE,'
||'        LAST_UPDATED_BY,'
||'        CREATION_DATE,'
||'        CREATED_BY,'
||'        LAST_UPDATE_LOGIN'
||'       FROM MSC_DELIVERY_DETAILS '
||'       WHERE sr_instance_id = '||MSC_CL_COLLECTION.v_instance_id
||'       and organization_id not '|| msc_Util.v_in_org_str;


      EXECUTE IMMEDIATE lv_sql_stmt;
      /* Add code to create indexes on this temp table*/


COMMIT;
Begin
/* Submit the CP for Purging MSC_TRANSPORTATION_UPDATES   */

reqid := FND_REQUEST.SUBMIT_REQUEST('MSC',
			                              'MSCCLMISC',
                                    Null,
			                              Null,
			                              False,
			                              'MSC_WS_OTM_BPEL',
                                    'PURGETRANSPORTATIONUPDATES',
			                              Null);
commit ;
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Submitted CP for purge MSC_TRANSPORTATION_UPDATES. '|| reqid);
EXCEPTION
   WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
End;
END IF; -- MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh
END LOAD_DELIVERY_DETAILS;


PROCEDURE LOAD_VISITS IS
   CURSOR c1 IS
SELECT
    msv.VISIT_ID,
    msv.VISIT_NAME,
    msv.VISIT_DESC,
    msv.VISIT_START_DATE,
    msv.VISIT_END_DATE,
    msv.ORGANIZATION_ID,
    msv.SR_INSTANCE_ID
FROM MSC_ST_VISITS msv
WHERE msv.deleted_flag = MSC_UTIL.SYS_NO
AND msv.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

CURSOR c_del IS
SELECT
    msv.VISIT_ID,
    msv.ORGANIZATION_ID,
    msv.SR_INSTANCE_ID
FROM MSC_ST_VISITS msv
WHERE msv.deleted_flag = MSC_UTIL.SYS_YES
and   msv.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

BEGIN

 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'IN LOAD VISITS');

FOR c_rec IN c_del LOOP
BEGIN

     DELETE MSC_WO_MILESTONES
       WHERE SR_INSTANCE_ID= c_rec.sr_instance_id
       AND VISIT_ID = c_rec.visit_id
       AND ORGANIZATION_ID = c_rec.organization_id;

     DELETE MSC_VISITS
       WHERE SR_INSTANCE_ID= c_rec.sr_instance_id
       AND VISIT_ID = c_rec.visit_id
       AND ORGANIZATION_ID = c_rec.organization_id;

EXCEPTION
   WHEN OTHERS THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'An error has occurred during deletion of Visits.');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
END;
END LOOP;

COMMIT;
FOR c_rec IN c1 LOOP

BEGIN

IF MSC_CL_COLLECTION.v_is_legacy_refresh THEN
UPDATE MSC_VISITS
SET
 VISIT_DESC = c_rec.VISIT_DESC,
 VISIT_START_DATE = c_rec.VISIT_START_DATE,
 VISIT_END_DATE = c_rec.VISIT_END_DATE,
 REFRESH_ID = MSC_CL_COLLECTION.v_last_collection_id,
 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND VISIT_ID = c_rec.VISIT_ID
  AND ORGANIZATION_ID = c_rec.ORGANIZATION_ID;

END IF;

IF (MSC_CL_COLLECTION.v_is_complete_refresh or MSC_CL_COLLECTION.v_is_partial_refresh) OR (MSC_CL_COLLECTION.v_is_legacy_refresh AND SQL%NOTFOUND) THEN
INSERT INTO MSC_VISITS (
  VISIT_ID,
  VISIT_NAME,
  VISIT_DESC,
  VISIT_START_DATE,
  VISIT_END_DATE,
  ORGANIZATION_ID,
  REFRESH_ID,
  SR_INSTANCE_ID,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
  (c_rec.VISIT_ID,
  c_rec.VISIT_NAME,
  c_rec.VISIT_DESC,
  c_rec.VISIT_START_DATE,
  c_rec.VISIT_END_DATE,
  c_rec.ORGANIZATION_ID,
  MSC_CL_COLLECTION.v_last_collection_id,
  MSC_CL_COLLECTION.v_instance_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user);

END IF;

EXCEPTION
   WHEN OTHERS THEN

      --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'An error has occurred.');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
END;

END LOOP;
COMMIT;

END LOAD_VISITS;

PROCEDURE LOAD_MILESTONES IS
   CURSOR c1 IS
SELECT
    mswm.MILESTONE,
    mswm.MILESTONE_DESC,
    mswm.VISIT_ID,
    mswm.ORGANIZATION_ID,
    mswm.SR_INSTANCE_ID
FROM MSC_ST_WO_MILESTONES mswm
WHERE mswm.deleted_flag = MSC_UTIL.SYS_NO
AND  mswm.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

CURSOR c_del IS
SELECT
    mswm.MILESTONE,
    mswm.VISIT_ID,
    mswm.ORGANIZATION_ID,
    mswm.SR_INSTANCE_ID
FROM MSC_ST_WO_MILESTONES mswm
WHERE mswm.deleted_flag = MSC_UTIL.SYS_YES
and   mswm.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

BEGIN
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'IN LOAD MILESTONES- Inst :'||MSC_CL_COLLECTION.v_instance_id );
FOR c_rec IN c_del LOOP
BEGIN

     DELETE MSC_WO_MILESTONES
       WHERE SR_INSTANCE_ID= c_rec.sr_instance_id
       AND MILESTONE = c_rec.milestone
       AND VISIT_ID = c_rec.visit_id
       AND ORGANIZATION_ID = c_rec.organization_id;

EXCEPTION
   WHEN OTHERS THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'An error has occurred during deletion of Milestones.');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
END;

END LOOP;

COMMIT;

FOR c_rec IN c1 LOOP

BEGIN

IF MSC_CL_COLLECTION.v_is_legacy_refresh THEN
UPDATE MSC_WO_MILESTONES
SET
 MILESTONE_DESC = c_rec.MILESTONE_DESC,
 REFRESH_ID = MSC_CL_COLLECTION.v_last_collection_id,
 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND VISIT_ID = c_rec.VISIT_ID
  AND MILESTONE = c_rec.MILESTONE
  AND ORGANIZATION_ID = c_rec.ORGANIZATION_ID;

END IF;
IF (MSC_CL_COLLECTION.v_is_complete_refresh or MSC_CL_COLLECTION.v_is_partial_refresh) OR (MSC_CL_COLLECTION.v_is_legacy_refresh AND SQL%NOTFOUND) THEN
INSERT INTO MSC_WO_MILESTONES (
  MILESTONE,
  MILESTONE_DESC,
  VISIT_ID,
  ORGANIZATION_ID,
  REFRESH_ID,
  SR_INSTANCE_ID,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
  (c_rec.MILESTONE,
  c_rec.MILESTONE_DESC,
  c_rec.VISIT_ID,
  c_rec.ORGANIZATION_ID,
  MSC_CL_COLLECTION.v_last_collection_id,
  MSC_CL_COLLECTION.v_instance_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user);

END IF;
EXCEPTION
   WHEN OTHERS THEN

      --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'An error has occurred.');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
END;

END LOOP;

COMMIT;
END LOAD_MILESTONES;

PROCEDURE LOAD_WBS IS
   CURSOR c1 IS
SELECT
    mswbs.PARAMETER_NAME,
    mswbs.DISPLAY_NAME,
    mswbs.ORGANIZATION_ID,
    mswbs.SR_INSTANCE_ID
FROM MSC_ST_WORK_BREAKDOWN_STRUCT mswbs
WHERE mswbs.deleted_flag = MSC_UTIL.SYS_NO
AND  mswbs.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

CURSOR c_del IS
SELECT
    mswbs.PARAMETER_NAME,
    mswbs.DISPLAY_NAME,
    mswbs.ORGANIZATION_ID,
    mswbs.SR_INSTANCE_ID
FROM MSC_ST_WORK_BREAKDOWN_STRUCT mswbs
WHERE mswbs.deleted_flag = MSC_UTIL.SYS_YES
and   mswbs.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

BEGIN
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'IN LOAD WBS- Inst :'||MSC_CL_COLLECTION.v_instance_id );
FOR c_rec IN c_del LOOP
BEGIN

     DELETE MSC_WORK_BREAKDOWN_STRUCT
       WHERE SR_INSTANCE_ID= c_rec.sr_instance_id
       AND PARAMETER_NAME = c_rec.parameter_name
       AND ORGANIZATION_ID = c_rec.organization_id;

EXCEPTION
   WHEN OTHERS THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'An error has occurred during deletion of WBS.');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
END;

END LOOP;

COMMIT;

FOR c_rec IN c1 LOOP

BEGIN

IF MSC_CL_COLLECTION.v_is_legacy_refresh THEN

UPDATE MSC_WORK_BREAKDOWN_STRUCT
SET DISPLAY_NAME   = c_rec.DISPLAY_NAME,
 REFRESH_ID = MSC_CL_COLLECTION.v_last_collection_id,
 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
AND ORGANIZATION_ID =  c_rec.ORGANIZATION_ID
AND   PARAMETER_NAME = c_rec.PARAMETER_NAME;


END IF;
IF (MSC_CL_COLLECTION.v_is_complete_refresh or MSC_CL_COLLECTION.v_is_partial_refresh) OR (MSC_CL_COLLECTION.v_is_legacy_refresh AND SQL%NOTFOUND) THEN
INSERT INTO MSC_WORK_BREAKDOWN_STRUCT (
  PARAMETER_NAME,
  DISPLAY_NAME,
  ORGANIZATION_ID,
  REFRESH_ID,
  SR_INSTANCE_ID,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
  (c_rec.PARAMETER_NAME,
  c_rec.DISPLAY_NAME,
  c_rec.ORGANIZATION_ID,
  MSC_CL_COLLECTION.v_last_collection_id,
  MSC_CL_COLLECTION.v_instance_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user);

END IF;
EXCEPTION
   WHEN OTHERS THEN

      --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'An error has occurred.');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
END;

END LOOP;

COMMIT;
END LOAD_WBS;

PROCEDURE LOAD_WOATTRIBUTES IS
   CURSOR c1 IS
SELECT
    mswa.SUPPLY_ID,
    mswa.PRODUCES_TO_STOCK,
    mswa.SERIAL_NUM,
    mswa.VISIT_ID,
    mswa.VISIT_NAME,
    mswa.PARAMETER1,
    mswa.PARAMETER2,
    mswa.PARAMETER3,
    mswa.PARAMETER4,
    mswa.PARAMETER5,
    mswa.PARAMETER6,
    mswa.PARAMETER7,
    mswa.PARAMETER8,
    mswa.PARAMETER9,
    mswa.MASTER_WO,
    mswa.PREV_MILESTONE,
    mswa.NEXT_MILESTONE,
    mswa.ORGANIZATION_ID,
    mswa.SR_INSTANCE_ID
FROM MSC_ST_WO_ATTRIBUTES mswa
WHERE  mswa.deleted_flag = MSC_UTIL.SYS_NO
AND  mswa.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

CURSOR c_del IS
SELECT
    mswa.SUPPLY_ID,
    mswa.VISIT_ID,
    mswa.ORGANIZATION_ID,
    mswa.SR_INSTANCE_ID
FROM MSC_ST_WO_ATTRIBUTES mswa
WHERE mswa.deleted_flag = MSC_UTIL.SYS_YES
and   mswa.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

BEGIN

 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'IN LOAD WO ATTRIBUTES- Inst :'||MSC_CL_COLLECTION.v_instance_id );
FOR c_rec IN c_del LOOP
BEGIN

     DELETE MSC_WO_ATTRIBUTES
       WHERE SR_INSTANCE_ID= c_rec.sr_instance_id
       AND VISIT_ID = c_rec.visit_id
       AND SUPPLY_ID = c_rec.supply_id
       AND ORGANIZATION_ID = c_rec.organization_id;

EXCEPTION
   WHEN OTHERS THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'An error has occurred during deletion of WO attributes.');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
END;

END LOOP;

COMMIT;
FOR c_rec IN c1 LOOP

BEGIN

IF MSC_CL_COLLECTION.v_is_legacy_refresh THEN
UPDATE MSC_WO_ATTRIBUTES
SET
 SERIAL_NUM = c_rec.SERIAL_NUM,
 PRODUCES_TO_STOCK = c_rec.PRODUCES_TO_STOCK,
 VISIT_ID   = c_rec.VISIT_ID,
 PARAMETER1 = c_rec.PARAMETER1,
 PARAMETER2 = c_rec.PARAMETER2,
 PARAMETER3 = c_rec.PARAMETER3,
 PARAMETER4 = c_rec.PARAMETER4,
 PARAMETER5 = c_rec.PARAMETER5,
 PARAMETER6 = c_rec.PARAMETER6,
 PARAMETER7 = c_rec.PARAMETER7,
 PARAMETER8 = c_rec.PARAMETER8,
 PARAMETER9 = c_rec.PARAMETER9,
 MASTER_WO = c_rec.MASTER_WO,
 PREV_MILESTONE = c_rec.PREV_MILESTONE,
 NEXT_MILESTONE = c_rec.NEXT_MILESTONE,
 REFRESH_ID = MSC_CL_COLLECTION.v_last_collection_id,
 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND SUPPLY_ID = c_rec.SUPPLY_ID
  AND ORGANIZATION_ID = c_rec.ORGANIZATION_ID;

END IF;

IF (MSC_CL_COLLECTION.v_is_complete_refresh or MSC_CL_COLLECTION.v_is_partial_refresh) OR (MSC_CL_COLLECTION.v_is_legacy_refresh AND SQL%NOTFOUND) THEN

INSERT INTO MSC_WO_ATTRIBUTES (
  SUPPLY_ID,
  PRODUCES_TO_STOCK,
  SERIAL_NUM,
  VISIT_ID,
  VISIT_NAME,
  PARAMETER1,
  PARAMETER2,
  PARAMETER3,
  PARAMETER4,
  PARAMETER5,
  PARAMETER6,
  PARAMETER7,
  PARAMETER8,
  PARAMETER9,
  MASTER_WO,
  PREV_MILESTONE,
  NEXT_MILESTONE,
  ORGANIZATION_ID,
  REFRESH_ID,
  SR_INSTANCE_ID,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
  (c_rec.SUPPLY_ID,
  c_rec.PRODUCES_TO_STOCK,
  c_rec.SERIAL_NUM,
  c_rec.VISIT_ID,
  c_rec.VISIT_NAME,
  c_rec.PARAMETER1,
  c_rec.PARAMETER2,
  c_rec.PARAMETER3,
  c_rec.PARAMETER4,
  c_rec.PARAMETER5,
  c_rec.PARAMETER6,
  c_rec.PARAMETER7,
  c_rec.PARAMETER8,
  c_rec.PARAMETER9,
  c_rec.MASTER_WO,
  c_rec.PREV_MILESTONE,
  c_rec.NEXT_MILESTONE,
  c_rec.ORGANIZATION_ID,
  MSC_CL_COLLECTION.v_last_collection_id,
  MSC_CL_COLLECTION.v_instance_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user);

END IF;
EXCEPTION
   WHEN OTHERS THEN

      --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'An error has occurred.');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
END;

END LOOP;

COMMIT;

END LOAD_WOATTRIBUTES;

PROCEDURE LOAD_WO_TASK_HIERARCHY IS
   CURSOR c1 IS
SELECT
    mswth.CURR_SUPPLY_ID,
    mswth.NEXT_SUPPLY_ID,
    mswth.PRECEDENCE_CONSTRAINT,
    mswth.MIN_SEPARATION,
    mswth.MIN_SEP_TIME_UNIT,
    mswth.MAX_SEPARATION,
    mswth.MAX_SEP_TIME_UNIT,
    mswth.ORGANIZATION_ID,
    mswth.SR_INSTANCE_ID
FROM MSC_ST_WO_TASK_HIERARCHY mswth
WHERE mswth.deleted_flag = MSC_UTIL.SYS_NO
AND  mswth.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

CURSOR c_del IS
SELECT
    mswth.CURR_SUPPLY_ID,
    mswth.NEXT_SUPPLY_ID,
    mswth.ORGANIZATION_ID,
    mswth.SR_INSTANCE_ID
FROM MSC_ST_WO_TASK_HIERARCHY mswth
WHERE mswth.deleted_flag = MSC_UTIL.SYS_YES
AND   mswth.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

BEGIN

 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'IN LOAD WO_TASK_HIERARCHY- Inst :'||MSC_CL_COLLECTION.v_instance_id );

FOR c_rec IN c_del LOOP
BEGIN

     DELETE MSC_WO_TASK_HIERARCHY
       WHERE SR_INSTANCE_ID= c_rec.sr_instance_id
       AND CURR_SUPPLY_ID = c_rec.curr_supply_id
       AND NEXT_SUPPLY_ID = c_rec.next_supply_id
       AND ORGANIZATION_ID = c_rec.organization_id;

EXCEPTION
   WHEN OTHERS THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'An error has occurred during deletion of WO task hierarchy.');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
END;

END LOOP;

COMMIT;
FOR c_rec IN c1 LOOP

BEGIN

IF MSC_CL_COLLECTION.v_is_legacy_refresh THEN
UPDATE MSC_WO_TASK_HIERARCHY
SET
 PRECEDENCE_CONSTRAINT = c_rec.PRECEDENCE_CONSTRAINT,
 MIN_SEPARATION = c_rec.MIN_SEPARATION,
 MIN_SEP_TIME_UNIT = c_rec.MIN_SEP_TIME_UNIT,
 MAX_SEPARATION = c_rec.MAX_SEPARATION,
 MAX_SEP_TIME_UNIT = c_rec.MAX_SEP_TIME_UNIT,
 REFRESH_ID = MSC_CL_COLLECTION.v_last_collection_id,
 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND ORGANIZATION_ID = c_rec.ORGANIZATION_ID
  AND CURR_SUPPLY_ID = c_rec.CURR_SUPPLY_ID
  AND NEXT_SUPPLY_ID = c_rec.NEXT_SUPPLY_ID;

END IF;

IF (MSC_CL_COLLECTION.v_is_complete_refresh or MSC_CL_COLLECTION.v_is_partial_refresh) OR (MSC_CL_COLLECTION.v_is_legacy_refresh AND SQL%NOTFOUND) THEN

INSERT INTO MSC_WO_TASK_HIERARCHY (
  CURR_SUPPLY_ID,
  NEXT_SUPPLY_ID,
  PRECEDENCE_CONSTRAINT,
  MIN_SEPARATION,
  MIN_SEP_TIME_UNIT,
  MAX_SEPARATION,
  MAX_SEP_TIME_UNIT,
  ORGANIZATION_ID,
  REFRESH_ID,
  SR_INSTANCE_ID,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
  (c_rec.CURR_SUPPLY_ID,
  c_rec.NEXT_SUPPLY_ID,
  c_rec.PRECEDENCE_CONSTRAINT,
  c_rec.MIN_SEPARATION,
  c_rec.MIN_SEP_TIME_UNIT,
  c_rec.MAX_SEPARATION,
  c_rec.MAX_SEP_TIME_UNIT,
  c_rec.ORGANIZATION_ID,
  MSC_CL_COLLECTION.v_last_collection_id,
  MSC_CL_COLLECTION.v_instance_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user);

END IF;
EXCEPTION
   WHEN OTHERS THEN

      --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'An error has occurred.');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
END;

END LOOP;

COMMIT;

END LOAD_WO_TASK_HIERARCHY;

PROCEDURE LOAD_WO_OPERATION_REL IS
   CURSOR c1 IS
SELECT
    mswor.SUPPLY_ID,
    mswor.PRECEDENCE_CONSTRAINT,
    mswor.MIN_SEPARATION,
    mswor.MIN_SEP_TIME_UNIT,
    mswor.MAX_SEPARATION,
    mswor.MAX_SEP_TIME_UNIT,
    mswor.FROM_OP_SEQ_NUM,
    mswor.FROM_OP_RES_SEQ_NUM,
    mswor.FROM_OP_DESC,
    mswor.TO_OP_SEQ_NUM,
    mswor.TO_OP_RES_SEQ_NUM,
    mswor.TO_OP_DESC,
    mswor.ORGANIZATION_ID,
    mswor.SR_INSTANCE_ID
FROM MSC_ST_WO_OPERATION_REL mswor
WHERE mswor.deleted_flag = MSC_UTIL.SYS_NO
AND  mswor.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

CURSOR c_del IS
SELECT
    mswor.SUPPLY_ID,
    mswor.FROM_OP_SEQ_NUM,
    mswor.FROM_OP_RES_SEQ_NUM,
    mswor.TO_OP_SEQ_NUM,
    mswor.TO_OP_RES_SEQ_NUM,
    mswor.ORGANIZATION_ID,
    mswor.SR_INSTANCE_ID
FROM MSC_ST_WO_OPERATION_REL mswor
WHERE mswor.deleted_flag = MSC_UTIL.SYS_YES
and   mswor.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

BEGIN

 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'IN LOAD WO_OPERATION REL- Inst :'||MSC_CL_COLLECTION.v_instance_id );

FOR c_rec IN c_del LOOP
BEGIN

     DELETE MSC_WO_OPERATION_REL
       WHERE SR_INSTANCE_ID= c_rec.sr_instance_id
       AND SUPPLY_ID = c_rec.supply_id
       AND FROM_OP_SEQ_NUM = c_rec.FROM_OP_SEQ_NUM
       AND nvl(FROM_OP_RES_SEQ_NUM,-1) = nvl(c_rec.FROM_OP_RES_SEQ_NUM,-1)
       AND TO_OP_SEQ_NUM =  c_rec.TO_OP_SEQ_NUM
       AND nvl(TO_OP_RES_SEQ_NUM,-1) = nvl(c_rec.TO_OP_RES_SEQ_NUM,-1)
       AND ORGANIZATION_ID = c_rec.organization_id;

EXCEPTION
   WHEN OTHERS THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'An error has occurred during deletion of WO operation Relation.');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
END;

END LOOP;

COMMIT;
FOR c_rec IN c1 LOOP

BEGIN
IF MSC_CL_COLLECTION.v_is_legacy_refresh THEN
UPDATE MSC_WO_OPERATION_REL
SET
 PRECEDENCE_CONSTRAINT = c_rec.PRECEDENCE_CONSTRAINT,
 FROM_OP_DESC = c_rec.FROM_OP_DESC,
 TO_OP_DESC = c_rec.TO_OP_DESC,
 MIN_SEPARATION = c_rec.MIN_SEPARATION,
 MIN_SEP_TIME_UNIT = c_rec.MIN_SEP_TIME_UNIT,
 MAX_SEPARATION = c_rec.MAX_SEPARATION,
 MAX_SEP_TIME_UNIT = c_rec.MAX_SEP_TIME_UNIT,
 REFRESH_ID = MSC_CL_COLLECTION.v_last_collection_id,
 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
 WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND ORGANIZATION_ID = c_rec.ORGANIZATION_ID
  AND SUPPLY_ID = c_rec.SUPPLY_ID
  AND FROM_OP_SEQ_NUM = c_rec.FROM_OP_SEQ_NUM
  AND TO_OP_SEQ_NUM = c_rec.TO_OP_SEQ_NUM
  AND nvl(FROM_OP_RES_SEQ_NUM,-1) =  nvl(c_rec.FROM_OP_RES_SEQ_NUM,-1)
  AND nvl(TO_OP_RES_SEQ_NUM,-1) =  nvl(c_rec.TO_OP_RES_SEQ_NUM,-1);

END IF;
IF (MSC_CL_COLLECTION.v_is_complete_refresh or MSC_CL_COLLECTION.v_is_partial_refresh) OR (MSC_CL_COLLECTION.v_is_legacy_refresh AND SQL%NOTFOUND) THEN

INSERT INTO MSC_WO_OPERATION_REL (
  SUPPLY_ID,
  PRECEDENCE_CONSTRAINT,
  MIN_SEPARATION,
  MIN_SEP_TIME_UNIT,
  MAX_SEPARATION,
  MAX_SEP_TIME_UNIT,
  FROM_OP_SEQ_NUM,
  FROM_OP_RES_SEQ_NUM,
  FROM_OP_DESC,
  TO_OP_SEQ_NUM,
  TO_OP_RES_SEQ_NUM,
  TO_OP_DESC,
  ORGANIZATION_ID,
  REFRESH_ID,
  SR_INSTANCE_ID,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
  (c_rec.SUPPLY_ID,
  c_rec.PRECEDENCE_CONSTRAINT,
  c_rec.MIN_SEPARATION,
  c_rec.MIN_SEP_TIME_UNIT,
  c_rec.MAX_SEPARATION,
  c_rec.MAX_SEP_TIME_UNIT,
  c_rec.FROM_OP_SEQ_NUM,
  c_rec.FROM_OP_RES_SEQ_NUM,
  c_rec.FROM_OP_DESC,
  c_rec.TO_OP_SEQ_NUM,
  c_rec.TO_OP_RES_SEQ_NUM,
  c_rec.TO_OP_DESC,
  c_rec.ORGANIZATION_ID,
  MSC_CL_COLLECTION.v_last_collection_id,
  MSC_CL_COLLECTION.v_instance_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user);

END IF;
EXCEPTION
   WHEN OTHERS THEN

      --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'An error has occurred.');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
END;

END LOOP;

COMMIT;
END LOAD_WO_OPERATION_REL;

PROCEDURE PURGE_STALE_CURRENCY_CONV IS
v_pbs number;

BEGIN

v_pbs := TO_NUMBER(FND_PROFILE.VALUE('MRP_PURGE_BATCH_SIZE'));

Loop
   Delete from MSC_CURRENCY_CONVERSIONS
   where conv_date  > (sysdate + MSC_CL_OTHER_PULL.G_MSC_FUTURE_DAYS) or conv_date < (sysdate - MSC_CL_OTHER_PULL.G_MSC_PAST_DAYS)
      And rownum < v_pbs;
Exit when sql%rowcount = 0;

End loop;
 commit;

END PURGE_STALE_CURRENCY_CONV;


END MSC_CL_OTHER_ODS_LOAD;

/
