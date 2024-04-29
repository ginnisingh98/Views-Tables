--------------------------------------------------------
--  DDL for Package Body MSC_CL_ITEM_ODS_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_ITEM_ODS_LOAD" AS -- specification
/* $Header: MSCLITEB.pls 120.8.12010000.5 2009/01/05 07:23:59 lsindhur ship $ */

   v_sql_stmt                    VARCHAR2(4000);
   lv_sql_stmt1                  VARCHAR2(4000);
   v_sub_str                     VARCHAR2(4000);
--   v_warning_flag                NUMBER:= MSC_UTIL.SYS_NO;  --2 be changed

--   G_COLLECT_SRP_DATA       VARCHAR2(1) :=  NVL(FND_PROFILE.VALUE('MSC_SRP_ENABLED'),'N');
   -- To collect SRP Data when this profile is set to Yes   neds to be deleted
--   v_is_cont_refresh             BOOLEAN;   -- 2 be changed
   v_chr9                        VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(9);
--   v_chr10                       VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(10);
--   v_chr13                       VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(13);


--    PROCEDURE ADD_NEW_IMPL_ITEM_ASL;
--    PROCEDURE UPDATE_LEADTIME;
--    PROCEDURE LOAD_ABC_CLASSES;
--    PROCEDURE LOAD_ITEM_SUBSTITUTES; --for Product substitution
   -- PROCEDURE ADD_NEW_IMPL_ITEM_ASL;
--    PROCEDURE LOAD_CATEGORY;
    /*PROCEDURE GENERATE_ITEM_KEYS (
                                   ERRBUF				  OUT NOCOPY VARCHAR2,
	                                 RETCODE				OUT NOCOPY NUMBER,
     		                           pINSTANCE_ID   IN  NUMBER
                                 );*/
--    PROCEDURE LOAD_SUPPLIER_CAPACITY;
--    PROCEDURE LOAD_ITEM;


FUNCTION Handle_Exception ( pErrorCode   IN NUMBER)
    RETURN BOOLEAN
IS
BEGIN
    IF pErrorCode IN (-0001,-01400) THEN
       -- These error codes can be skipped with out affecting the collections run
       RETURN TRUE;
    END IF;
    RETURN FALSE;
END;

 PROCEDURE ADD_NEW_IMPL_ITEM_ASL IS
 TYPE CurTyp IS REF CURSOR; -- define weak REF CURSOR type -Cursor variable
   c1              CurTyp;
   lv_sql_stmt varchar2(5000);
   lv_sql_stmt1 varchar2(5000);
   lv_table_name varchar2(100);
   lv_inventory_item_id  Number;
   lv_organization_id  Number ;
   lv_min_last_item_coll_date DATE;
BEGIN
		IF  (MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES and MSC_CL_COLLECTION.v_coll_prec.item_flag = MSC_UTIL.SYS_YES )  THEN
			lv_table_name:= 'SYSTEM_ITEMS_' || MSC_CL_COLLECTION.v_INSTANCE_CODE;
			MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, ' table name in ADD_NEW_IMPL_ITEM_ASL is ' || lv_table_name);
  	else
			lv_table_name:= 'MSC_SYSTEM_ITEMS';
			MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, ' table name in ADD_NEW_IMPL_ITEM_ASL is ' || lv_table_name);
    End if;

    v_sql_stmt := 'Select min (nvl(LAST_SUCC_ITEM_REF_TIME,SYSDATE-365000))'
   						  ||'  From msc_instance_orgs '
   							||'  Where sr_instance_id = ' || MSC_CL_COLLECTION.v_instance_id
  							||'  And   organization_id '|| MSC_UTIL.v_in_org_str;

 -- MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'the sql statement is ' || v_sql_stmt);

  EXECUTE IMMEDIATE v_sql_stmt  into lv_min_last_item_coll_date;

  --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'the sql statement is ' || v_sql_stmt);
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'minimum of last successful ITEM Collection refresh time is '||lv_min_last_item_coll_date);

    lv_sql_stmt := 'select x.inventory_item_id , x.organization_id '
                  ||' FROM ' || lv_table_name ||' x , MSC_INSTANCE_ORGS mio'
                  ||' WHERE '
                  ||'   x.organization_id = mio.organization_id '
                  ||' AND  x.sr_instance_id = mio.sr_instance_id '
                  ||' AND  x.organization_id '|| MSC_UTIL.v_in_org_str
                  ||' AND x.item_creation_date > nvl(mio.LAST_SUCC_ITEM_REF_TIME, SYSDATE-365000)'
                  ||' AND x.item_creation_date>:lv_min_last_item_coll_date'
                  ||' AND  x.sr_instance_id = ' || MSC_CL_COLLECTION.v_instance_id
                  ||' AND x.plan_id =-1 ';

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'the sql statement is ' || lv_sql_stmt);

   Open c1 for lv_sql_stmt using lv_min_last_item_coll_date  ;
      IF (c1%ISOPEN ) THEN
         LOOP
     			FETCH c1 INTO lv_inventory_item_id,lv_organization_id;
     			EXIT WHEN c1%NOTFOUND ;
     			lv_sql_stmt1:= ' INSERT INTO MSC_ITEM_SUPPLIERS '
												|| ' ( USING_ORGANIZATION_ID,'
					|| '  SUPPLIER_ID,'
					|| '  SUPPLIER_SITE_ID,'
					|| '  INVENTORY_ITEM_ID,'
					|| '  PROCESSING_LEAD_TIME,'
					|| '  MINIMUM_ORDER_QUANTITY,'
					|| '  FIXED_LOT_MULTIPLIER,'
					|| '  DELIVERY_CALENDAR_CODE,'
					|| '  SUPPLIER_CAP_OVER_UTIL_COST,'
					|| '  PURCHASING_UNIT_OF_MEASURE,'
					|| '  SR_INSTANCE_ID2,'
					|| '  ITEM_PRICE, ' -- Item Price by Supplier Fix
					|| '  SR_INSTANCE_ID,'
				 	|| '  SUPPLIER_ITEM_NAME,'
					|| '  PLANNER_CODE,'
					|| '  VMI_FLAG ,'
					|| '  MIN_MINMAX_QUANTITY,'
					|| '  MAX_MINMAX_QUANTITY,'
					|| '  MAXIMUM_ORDER_QUANTITY,'
					|| '  UOM_CODE,'
					|| '  VMI_REPLENISHMENT_APPROVAL,'
					|| '  ENABLE_VMI_AUTO_REPLENISH_FLAG,'
					|| '  REPLENISHMENT_METHOD,'
					|| '  MIN_MINMAX_DAYS,'
					|| '  MAX_MINMAX_DAYS,'
					|| '  FORECAST_HORIZON,'
					|| '  FIXED_ORDER_QUANTITY,'
					|| '  VMI_REFRESH_FLAG,'
					|| '  PLAN_ID,'
					|| '  ORGANIZATION_ID,'
					|| '  REFRESH_NUMBER,'
					|| '  LAST_UPDATE_DATE,'
					|| '  LAST_UPDATED_BY,'
					|| '  CREATION_DATE,'
					|| '  CREATED_BY)'
					|| ' SELECT a.USING_ORGANIZATION_ID ,'
					|| '  a.SUPPLIER_ID,'
					|| '  a.SUPPLIER_SITE_ID,'
					|| '  a.INVENTORY_ITEM_ID,'
					|| '  a.PROCESSING_LEAD_TIME,'
					|| '  a.MINIMUM_ORDER_QUANTITY,'
					|| '  a.FIXED_LOT_MULTIPLIER,'
					|| '  a.DELIVERY_CALENDAR_CODE,'
					|| '  a.SUPPLIER_CAP_OVER_UTIL_COST,'
					|| '  a.PURCHASING_UNIT_OF_MEASURE,'
					|| '  a.SR_INSTANCE_ID2,'
					|| '  a.ITEM_PRICE, ' -- Item Price by Supplier Fix
					|| '  a.SR_INSTANCE_ID,'
				 	|| '  a.SUPPLIER_ITEM_NAME,'
					|| '  a.PLANNER_CODE,'
					|| '  a.VMI_FLAG ,'
					|| '  a.MIN_MINMAX_QUANTITY,'
					|| '  a.MAX_MINMAX_QUANTITY,'
					|| '  a.MAXIMUM_ORDER_QUANTITY,'
					|| '  a.UOM_CODE,'
					|| '  a.VMI_REPLENISHMENT_APPROVAL,'
					|| '  a.ENABLE_VMI_AUTO_REPLENISH_FLAG,'
					|| '  a.REPLENISHMENT_METHOD,'
					|| '  a.MIN_MINMAX_DAYS,'
					|| '  a.MAX_MINMAX_DAYS,'
					|| '  a.FORECAST_HORIZON,'
					|| '  a.FIXED_ORDER_QUANTITY,'
					|| ' 1, -1, :lv_organization_id , :v_last_collection_id,:v_current_date,'
					|| ' :v_current_user,:v_current_date,:v_current_user'
					||'     FROM  ('
					||'						SELECT DISTINCT USING_ORGANIZATION_ID, '
					|| '  SUPPLIER_ID,'
					|| '  SUPPLIER_SITE_ID,'
					|| '  INVENTORY_ITEM_ID,'
					|| '  PROCESSING_LEAD_TIME,'
					|| '  MINIMUM_ORDER_QUANTITY,'
					|| '  FIXED_LOT_MULTIPLIER,'
					|| '  DELIVERY_CALENDAR_CODE,'
					|| '  SUPPLIER_CAP_OVER_UTIL_COST,'
					|| '  PURCHASING_UNIT_OF_MEASURE,'
					|| '  SR_INSTANCE_ID2,'
					|| '  ITEM_PRICE, ' -- Item Price by Supplier Fix
					|| '  SR_INSTANCE_ID,'
					|| '  SUPPLIER_ITEM_NAME,'
					|| '  PLANNER_CODE,'
					|| '  VMI_FLAG ,'
					|| '  MIN_MINMAX_QUANTITY,'
					|| '  MAX_MINMAX_QUANTITY,'
					|| '  MAXIMUM_ORDER_QUANTITY,'
					|| '  UOM_CODE,'
					|| '  VMI_REPLENISHMENT_APPROVAL,'
					|| '  ENABLE_VMI_AUTO_REPLENISH_FLAG,'
					|| '  REPLENISHMENT_METHOD,'
					|| '  MIN_MINMAX_DAYS,'
					|| '  MAX_MINMAX_DAYS,'
					|| '  FORECAST_HORIZON,'
					|| '  FIXED_ORDER_QUANTITY'
					|| ' FROM MSC_ITEM_SUPPLIERS '
					|| ' WHERE SR_INSTANCE_ID =' || MSC_CL_COLLECTION.v_instance_id
					|| ' AND PLAN_ID =-1 '
					|| ' AND USING_ORGANIZATION_ID =-1 '
					|| ' AND  INVENTORY_ITEM_ID =' ||lv_inventory_item_id
					|| ' AND  ORGANIZATION_ID '|| MSC_UTIL.v_in_org_str || ' ) a ';

					MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'sql in inser_Asl ' || lv_sql_stmt1);

		EXECUTE IMMEDIATE lv_sql_stmt1
     USING   lv_organization_id ,MSC_CL_COLLECTION.v_last_collection_id,MSC_CL_COLLECTION.v_current_date,MSC_CL_COLLECTION.v_current_user,MSC_CL_COLLECTION.v_current_date,MSC_CL_COLLECTION.v_current_user;

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of rows inserted in ADD_NEW_IMPL_ITEM_ASL  ' || SQL%ROWCOUNT);
     	commit ;
     	END LOOP;

     END IF ;

     CLOSE c1 ;
     EXCEPTION

       WHEN OTHERS THEN
           MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

    		  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
     			FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      		FND_MESSAGE.SET_TOKEN('PROCEDURE', 'ADD_NEW_IMPL_ITEM_ASL');
      		FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ITEM_SUPPLIERS');
     			 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'ITEM_NAME');
		      FND_MESSAGE.SET_TOKEN('VALUE', ITEM_NAME( lv_inventory_item_id));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
		      FND_MESSAGE.SET_TOKEN('VALUE',
		                            MSC_GET_NAME.ORG_CODE( lv_organization_id,
		                                                   MSC_CL_COLLECTION.v_instance_id));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

END ADD_NEW_IMPL_ITEM_ASL;

	   FUNCTION ITEM_NAME ( p_item_id                          IN NUMBER)
		    RETURN VARCHAR2
	   IS
	      CURSOR c_item( cp_item_id IN NUMBER) IS
	      SELECT ITEM_NAME
		FROM MSC_ITEMS
	       WHERE INVENTORY_ITEM_ID= cp_item_id;

	      lv_item_name  VARCHAR2(250):= NULL;
	   BEGIN
	      OPEN  c_item( p_item_id);
	      FETCH c_item INTO lv_item_name;
	      CLOSE c_item;

	      RETURN lv_item_name;
	   EXCEPTION
	      WHEN OTHERS THEN
		 IF c_item%ISOPEN THEN CLOSE c_item; END IF;
		 RETURN lv_item_name;
	   END ITEM_NAME;

PROCEDURE UPDATE_LEADTIME
IS
BEGIN

update MSC_SYSTEM_ITEMS
	 set VARIABLE_LEAD_TIME=0,
	 FIXED_LEAD_TIME=0
	 where PLAN_ID=-1
	 and SR_INSTANCE_ID=MSC_CL_COLLECTION.v_instance_id
	 and (INVENTORY_ITEM_ID,organization_id) in (
	select current_item.inventory_item_id,current_item.organization_id
	from
	     msc_routings model_routing,
	     msc_routings option_class_routing,
	     msc_system_items model_item,
	     msc_system_items current_item
	where
	     current_item.bom_item_type = 2
	and  model_routing.PLAN_ID=-1
	and  option_class_routing.PLAN_ID=-1
	and  model_item.PLAN_ID=-1
	and  current_item.PLAN_ID=-1
	and  current_item.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
	and  model_routing.SR_INSTANCE_ID=current_item.SR_INSTANCE_ID
	and  option_class_routing.SR_INSTANCE_ID=current_item.SR_INSTANCE_ID
	and  model_item.SR_INSTANCE_ID=current_item.SR_INSTANCE_ID
	and  model_routing.ORGANIZATION_ID = current_item.ORGANIZATION_ID
	and  option_class_routing.ORGANIZATION_ID = current_item.ORGANIZATION_ID
	and  model_item.ORGANIZATION_ID = current_item.ORGANIZATION_ID
	and  model_item.bom_item_type = 1
	and  model_item.inventory_item_id = model_routing.ASSEMBLY_ITEM_ID
	and  option_class_routing.ASSEMBLY_ITEM_ID = current_item.inventory_item_id
	and  option_class_routing.common_routing_sequence_id = model_routing.routing_sequence_id);
COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'An error has occurred.');
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

END  UPDATE_LEADTIME;

PROCEDURE LOAD_ABC_CLASSES IS
lv_temp_sql_stmt   VARCHAR2(2000);
lv_sql_stmt VARCHAR2(7500);
BEGIN

 IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh
     OR (MSC_CL_COLLECTION.v_is_incremental_refresh AND MSC_CL_COLLECTION.v_apps_ver >= MSC_UTIL.G_APPS120)) THEN

   IF MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ABC_CLASSES', MSC_CL_COLLECTION.v_instance_id,NULL );
  ELSE
    v_sub_str :=' AND ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ABC_CLASSES', MSC_CL_COLLECTION.v_instance_id,NULL,v_sub_str);
  END IF;
     /*changed for bug:4765403*/
    IF MSC_CL_COLLECTION.v_apps_ver >= MSC_UTIL.G_APPS120 THEN

    lv_temp_sql_stmt :=
                   ' SELECT'
                 ||' msa.abc_class_id,'
                 ||' msa.abc_class_name,'
                 ||' msa.organization_id,'
                 ||' msa.sr_instance_id,'
                 ||' :v_current_date,'
                 ||' :v_current_user,'
                 ||' :v_current_date,'
                 ||' :v_current_user,'
                 ||' msa.sr_assignment_group_id'
                 ||' FROM   MSC_ST_ABC_CLASSES msa'
                 ||' WHERE  msa.sr_instance_id = '||MSC_CL_COLLECTION.v_instance_id;

    ELSE

    lv_temp_sql_stmt :=
                  ' SELECT distinct'
                ||' msi.abc_class_id,'
                ||' msi.abc_class_name,'
                ||' msi.organization_id,'
                ||' msi.sr_instance_id,'
                ||' :v_current_date,'
                ||' :v_current_user,'
                ||' :v_current_date,'
                ||' :v_current_user,'
                ||' NULL'
                ||' FROM   MSC_ST_SYSTEM_ITEMS msi'
                ||' WHERE  msi.sr_instance_id = '||MSC_CL_COLLECTION.v_instance_id
                ||' AND    msi.abc_class_id is not null'
                ||' AND    msi.abc_class_name is not null';

    END IF;

  BEGIN

  lv_sql_stmt :=
          ' INSERT INTO MSC_ABC_CLASSES'
        ||' ( ABC_CLASS_ID,'
        ||' ABC_CLASS_NAME,'
        ||' ORGANIZATION_ID,'
        ||' SR_INSTANCE_ID,'
        ||' LAST_UPDATE_DATE,'
        ||' LAST_UPDATED_BY,'
        ||' CREATION_DATE,'
        ||' CREATED_BY,'
        ||' SR_ASSIGNMENT_GROUP_ID)'
        ||lv_temp_sql_stmt;

    EXECUTE IMMEDIATE lv_sql_stmt USING MSC_CL_COLLECTION.v_current_date,MSC_CL_COLLECTION.v_current_user,MSC_CL_COLLECTION.v_current_date,MSC_CL_COLLECTION.v_current_user;


     COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_ABC_CLASSES');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ABC_CLASSES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;
      null;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_ABC_CLASSES');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ABC_CLASSES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

  END;
  END IF;

END LOAD_ABC_CLASSES;
--==================================================================

PROCEDURE LOAD_ITEM_SUBSTITUTES IS

  c_count         NUMBER:=0;
  lv_tbl          VARCHAR2(30);
  lv_sql_stmt     VARCHAR2(5000);
  lv_sql_stmt1    VARCHAR2(5000);
  lv_cursor_stmt  VARCHAR2(5000);
  lv_cursor_stmt1 VARCHAR2(5000);

  lv_errbuf	  		VARCHAR2(240);
  lv_retcode			NUMBER;

  CURSOR c1 IS
  SELECT
    t1.INVENTORY_ITEM_ID HIGHER_ITEM_ID,
    t2.INVENTORY_ITEM_ID LOWER_ITEM_ID,
    msis.RECIPROCAL_FLAG,
    msis.SUBSTITUTION_SET,
    msis.ORGANIZATION_ID,
    nvl(msis.EFFECTIVE_DATE,sysdate) EFFECTIVE_DATE,
    msis.DISABLE_DATE,
    msis.RELATIONSHIP_TYPE,
    msis.PARTIAL_FULFILLMENT_FLAG,
    tp.TP_ID                     CUSTOMER_ID,
    tps.TP_SITE_ID               CUSTOMER_SITE_ID
  FROM MSC_TP_SITE_ID_LID tps,
       MSC_TP_ID_LID tp,
       MSC_ITEM_ID_LID t1,
       MSC_ITEM_ID_LID t2,
       MSC_ST_ITEM_SUBSTITUTES msis
  WHERE t1.SR_INVENTORY_ITEM_ID= msis.HIGHER_ITEM_ID
    AND t1.SR_INSTANCE_ID= msis.SR_INSTANCE_ID
    AND t2.SR_INVENTORY_ITEM_ID = msis.LOWER_ITEM_ID
    AND t2.SR_INSTANCE_ID = msis.SR_INSTANCE_ID
    AND tp.SR_TP_ID(+)= msis.CUSTOMER_ID
    AND tp.SR_INSTANCE_ID(+)= msis.SR_INSTANCE_ID
    AND tp.PARTNER_TYPE(+) = 2
    AND tps.SR_TP_SITE_ID(+)= msis.CUSTOMER_SITE_ID
    AND tps.SR_INSTANCE_ID(+)= msis.SR_INSTANCE_ID
    AND tps.PARTNER_TYPE(+)= 2
    AND msis.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
    AND msis.relationship_type=2
    AND msis.deleted_flag=MSC_UTIL.SYS_NO;

CURSOR c2 IS
  SELECT
    t1.INVENTORY_ITEM_ID HIGHER_ITEM_ID,
    t2.INVENTORY_ITEM_ID LOWER_ITEM_ID,
    msis.RECIPROCAL_FLAG,
    msis.SUBSTITUTION_SET,
    msis.ORGANIZATION_ID,
    msis.RELATIONSHIP_TYPE,
    msis.PARTIAL_FULFILLMENT_FLAG,
    nvl(msis.EFFECTIVE_DATE,sysdate) EFFECTIVE_DATE,
    msis.DISABLE_DATE
  FROM --MSC_TP_SITE_ID_LID tps,
       --MSC_TP_ID_LID tp,
       MSC_ITEM_ID_LID t1,
       MSC_ITEM_ID_LID t2,
       MSC_ST_ITEM_SUBSTITUTES msis
  WHERE t1.SR_INVENTORY_ITEM_ID= msis.HIGHER_ITEM_ID
    AND t1.SR_INSTANCE_ID= msis.SR_INSTANCE_ID
    AND t2.SR_INVENTORY_ITEM_ID = msis.LOWER_ITEM_ID
    AND t2.SR_INSTANCE_ID = msis.SR_INSTANCE_ID
    AND msis.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
    AND msis.relationship_type in (5,8,18)
    AND msis.deleted_flag=MSC_UTIL.SYS_NO;

  TYPE CharTblTyp IS TABLE OF VARCHAR2(70);
  TYPE NumTblTyp  IS TABLE OF NUMBER;
  TYPE dateTblTyp IS TABLE OF DATE;

  lb_FetchComplete  Boolean;
  ln_rows_to_fetch  Number := nvl(TO_NUMBER( FND_PROFILE.VALUE('MRP_PURGE_BATCH_SIZE')),75000);

    lb_HIGHER_ITEM_ID             NumTblTyp;
    lb_LOWER_ITEM_ID              NumTblTyp;
    lb_RECIPROCAL_FLAG            NumTblTyp;
    lb_SUBSTITUTION_SET           CharTblTyp;
    lb_ORGANIZATION_ID            NumTblTyp;
    lb_EFFECTIVE_DATE             dateTblTyp;
    lb_DISABLE_DATE               dateTblTyp;
    lb_RELATIONSHIP_TYPE          NumTblTyp;
    lb_PARTIAL_FULFILLMENT_FLAG   NumTblTyp;
    lb_CUSTOMER_ID                NumTblTyp;
    lb_CUSTOMER_SITE_ID           NumTblTyp;

BEGIN


IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   lv_tbl:= 'ITEM_SUBSTITUTES_'||MSC_CL_COLLECTION.v_INSTANCE_CODE;
ELSE
   lv_tbl:= ' MSC_ITEM_SUBSTITUTES ';
END IF;

  /* below statement will be used to insert new recs in case of net change */
  lv_sql_stmt :=
  'INSERT INTO '||lv_tbl
  ||'( PLAN_ID,'
  ||'  HIGHER_ITEM_ID,'
  ||'  LOWER_ITEM_ID,'
  ||'  RECIPROCAL_FLAG,'
  ||'  SUBSTITUTION_SET,'
  ||'  CUSTOMER_ID,'
  ||'  CUSTOMER_SITE_ID,'
  ||'  EFFECTIVE_DATE,'
  ||'  DISABLE_DATE,'
  ||'  RELATIONSHIP_TYPE,'
  ||'  PARTIAL_FULFILLMENT_FLAG,'
  ||'  USAGE_RATIO,'
  ||'  REFRESH_ID,'
  ||'  SR_INSTANCE_ID,'
  ||'  ORGANIZATION_ID, '
  ||'  LAST_UPDATE_DATE,'
  ||'  LAST_UPDATED_BY,'
  ||'  LAST_UPDATE_LOGIN,'
  ||'  CREATION_DATE,'
  ||'  CREATED_BY)'
  ||'VALUES'
  ||'( -1, '
  ||' :HIGHER_ITEM_ID, '
  ||' :LOWER_ITEM_ID, '
  ||' :RECIPROCAL_FLAG, '
  ||' :SUBSTITUTION_SET, '
  ||' :CUSTOMER_ID, '
  ||' :CUSTOMER_SITE_ID, '
  ||' :EFFECTIVE_DATE, '
  ||' :DISABLE_DATE, '
  ||' :RELATIONSHIP_TYPE, '
  ||' :PARTIAL_FULFILLMENT_FLAG, '
  ||'  1, '
  ||'  :v_last_collection_id,'
  ||'  :v_instance_id, '
  ||'  :ORGANIZATION_ID, '
  ||'  :v_current_date, '
  ||'  :v_current_user, '
  ||'  :v_current_user, '
  ||'  :v_current_date, '
  ||'  :v_current_user)';

lv_sql_stmt1 :=
  'INSERT INTO '||lv_tbl
  ||'( PLAN_ID,'
  ||'  HIGHER_ITEM_ID,'
  ||'  LOWER_ITEM_ID,'
  ||'  RECIPROCAL_FLAG,'
  ||'  SUBSTITUTION_SET,'
  ||'  EFFECTIVE_DATE,'
  ||'  DISABLE_DATE,'
  ||'  RELATIONSHIP_TYPE,'
  ||'  PARTIAL_FULFILLMENT_FLAG,'
  ||'  USAGE_RATIO,'
  ||'  REFRESH_ID,'
  ||'  SR_INSTANCE_ID,'
  ||'  ORGANIZATION_ID, '
  ||'  LAST_UPDATE_DATE,'
  ||'  LAST_UPDATED_BY,'
  ||'  LAST_UPDATE_LOGIN,'
  ||'  CREATION_DATE,'
  ||'  CREATED_BY)'
  ||'VALUES'
  ||'( -1, '
  ||' :HIGHER_ITEM_ID, '
  ||' :LOWER_ITEM_ID, '
  ||' :RECIPROCAL_FLAG, '
  ||' :SUBSTITUTION_SET,'
  ||' :EFFECTIVE_DATE, '
  ||' :DISABLE_DATE, '
  ||' :RELATIONSHIP_TYPE, '
  ||' :PARTIAL_FULFILLMENT_FLAG,'
  ||'  1, '
  ||'  :v_last_collection_id,'
  ||'  :v_instance_id, '
  ||'  :ORGANIZATION_ID, '
  ||'  :v_current_date, '
  ||'  :v_current_user, '
  ||'  :v_current_user, '
  ||'  :v_current_date, '
  ||'  :v_current_user)';



  /* bulk insert statement, used in case of target/complete collection */
  lv_cursor_stmt:=
  'INSERT INTO '||lv_tbl
  ||'( PLAN_ID,'
  ||'     HIGHER_ITEM_ID,'
  ||'     LOWER_ITEM_ID,'
  ||'     RECIPROCAL_FLAG,'
  ||'     SUBSTITUTION_SET,'
  ||'     CUSTOMER_ID,'
  ||'     CUSTOMER_SITE_ID,'
  ||'     EFFECTIVE_DATE,'
  ||'     DISABLE_DATE,'
  ||'     RELATIONSHIP_TYPE,'
  ||'     PARTIAL_FULFILLMENT_FLAG,'
  ||'     USAGE_RATIO,'
  ||'     REFRESH_ID,'
  ||'     SR_INSTANCE_ID,'
  ||'     ORGANIZATION_ID,'
  ||'     LAST_UPDATE_DATE,'
  ||'     LAST_UPDATED_BY,'
  ||'     LAST_UPDATE_LOGIN,'
  ||'     CREATION_DATE,'
  ||'     CREATED_BY)'
  ||' SELECT'
  ||'    -1, '
  ||'     t1.INVENTORY_ITEM_ID HIGHER_ITEM_ID,'
  ||'     t2.INVENTORY_ITEM_ID LOWER_ITEM_ID,'
  ||'     msis.RECIPROCAL_FLAG,'
  ||'     msis.SUBSTITUTION_SET,'
  ||'     tp.TP_ID,'
  ||'     tps.tp_SITE_ID,'
  ||'     nvl(msis.EFFECTIVE_DATE, sysdate),'
  ||'     msis.DISABLE_DATE,'
  ||'     msis.RELATIONSHIP_TYPE,'
  ||'     msis.PARTIAL_FULFILLMENT_FLAG,'
  ||'     1,'
  ||'     :v_last_collection_id,'
  ||'     msis.SR_INSTANCE_ID,'
  ||'     msis.ORGANIZATION_ID,'
  ||'     :v_current_date,'
  ||'     :v_current_user,'
  ||'     :v_current_user,'
  ||'     :v_current_date,'
  ||'     :v_current_user'
  ||'   FROM MSC_TP_SITE_ID_LID tps,'
  ||'     MSC_TP_ID_LID tp,'
  ||'     MSC_ITEM_ID_LID t1,'
  ||'     MSC_ITEM_ID_LID t2,'
  ||'     MSC_ST_ITEM_SUBSTITUTES msis'
  ||'   WHERE t1.SR_INVENTORY_ITEM_ID= msis.HIGHER_ITEM_ID'
  ||'     AND t1.SR_INSTANCE_ID= msis.SR_INSTANCE_ID'
  ||'     AND t2.SR_INVENTORY_ITEM_ID = msis.LOWER_ITEM_ID'
  ||'     AND t2.SR_INSTANCE_ID = msis.SR_INSTANCE_ID'
  ||'     AND tp.SR_TP_ID(+)= msis.CUSTOMER_ID'
  ||'     AND tp.SR_INSTANCE_ID(+)= msis.SR_INSTANCE_ID'
  ||'     AND tp.PARTNER_TYPE(+) = 2'
  ||'     AND tps.SR_TP_SITE_ID(+)= msis.CUSTOMER_SITE_ID'
  ||'     AND tps.SR_INSTANCE_ID(+)= msis.SR_INSTANCE_ID'
  ||'     AND tps.PARTNER_TYPE(+)= 2'
  ||'     AND msis.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id
  ||'     AND msis. RELATIONSHIP_TYPE =2'
  ||'     AND nvl(msis.deleted_flag,2)='||MSC_UTIL.SYS_NO;


lv_cursor_stmt1:=
  'INSERT INTO '||lv_tbl
  ||'( PLAN_ID,'
  ||'     HIGHER_ITEM_ID,'
  ||'     LOWER_ITEM_ID,'
  ||'     RECIPROCAL_FLAG,'
  ||'     EFFECTIVE_DATE,'
  ||'     DISABLE_DATE,'
  ||'     RELATIONSHIP_TYPE,'
  ||'     SUBSTITUTION_SET,'
  ||'     PARTIAL_FULFILLMENT_FLAG,'
  ||'     USAGE_RATIO,'
  ||'     REFRESH_ID,'
  ||'     SR_INSTANCE_ID,'
  ||'     ORGANIZATION_ID,'
  ||'     LAST_UPDATE_DATE,'
  ||'     LAST_UPDATED_BY,'
  ||'     LAST_UPDATE_LOGIN,'
  ||'     CREATION_DATE,'
  ||'     CREATED_BY)'
  ||' SELECT'
  ||'    -1, '
  ||'     t1.INVENTORY_ITEM_ID HIGHER_ITEM_ID,'
  ||'     t2.INVENTORY_ITEM_ID LOWER_ITEM_ID,'
  ||'     msis.RECIPROCAL_FLAG,'
  ||'     nvl(msis.EFFECTIVE_DATE, sysdate),'
  ||'     msis.DISABLE_DATE,'
  ||'     msis.RELATIONSHIP_TYPE,'
  ||'     msis.SUBSTITUTION_SET,'
  ||'     msis.PARTIAL_FULFILLMENT_FLAG,'
  ||'     1,'
  ||'     :v_last_collection_id,'
  ||'     msis.SR_INSTANCE_ID,'
  ||'     msis.ORGANIZATION_ID,'
  ||'     :v_current_date,'
  ||'     :v_current_user,'
  ||'     :v_current_user,'
  ||'     :v_current_date,'
  ||'     :v_current_user'
  ||'   FROM '
  ||'     MSC_ITEM_ID_LID t1,'
  ||'     MSC_ITEM_ID_LID t2,'
  ||'     MSC_ST_ITEM_SUBSTITUTES msis'
  ||'   WHERE t1.SR_INVENTORY_ITEM_ID= msis.HIGHER_ITEM_ID'
  ||'     AND t1.SR_INSTANCE_ID= msis.SR_INSTANCE_ID'
  ||'     AND t2.SR_INVENTORY_ITEM_ID = msis.LOWER_ITEM_ID'
  ||'     AND t2.SR_INSTANCE_ID = msis.SR_INSTANCE_ID'
  ||'     AND msis.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id
  ||'     AND msis. RELATIONSHIP_TYPE  in (5,8,18)'
  ||'     AND nvl(msis.deleted_flag,2)='||MSC_UTIL.SYS_NO;

 IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) AND
                                    MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_NO THEN
    IF MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ITEM_SUBSTITUTES', MSC_CL_COLLECTION.v_instance_id, -1);
    ELSE
      v_sub_str :=' AND ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ITEM_SUBSTITUTES', MSC_CL_COLLECTION.v_instance_id, -1,v_sub_str);
    END IF;
  END IF;

 IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

     begin

     EXECUTE IMMEDIATE lv_cursor_stmt
     USING MSC_CL_COLLECTION.v_last_collection_id,
        MSC_CL_COLLECTION.v_current_date,
        MSC_CL_COLLECTION.v_current_user,
        MSC_CL_COLLECTION.v_current_user,
        MSC_CL_COLLECTION.v_current_date,
        MSC_CL_COLLECTION.v_current_user;

      EXCEPTION
      WHEN OTHERS THEN
       --LOG_MESSAGE(SQLERRM);
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
       IF NOT Handle_Exception(SQLCODE) THEN RAISE; END IF;

      end;
    IF  (MSC_UTIL.G_COLLECT_SRP_DATA = 'Y' AND MSC_CL_COLLECTION.v_apps_ver >= MSC_UTIL.G_APPS115) THEN

    begin
    EXECUTE IMMEDIATE lv_cursor_stmt1
     USING MSC_CL_COLLECTION.v_last_collection_id,
        MSC_CL_COLLECTION.v_current_date,
        MSC_CL_COLLECTION.v_current_user,
        MSC_CL_COLLECTION.v_current_user,
        MSC_CL_COLLECTION.v_current_date,
        MSC_CL_COLLECTION.v_current_user;

    EXCEPTION
      WHEN OTHERS THEN
--       LOG_MESSAGE(SQLERRM);
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
       IF NOT Handle_Exception(SQLCODE) THEN RAISE; END IF;
      end;

    END IF ;

  END IF;

  IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN
    --Net Change
      LOOP
        DELETE  FROM MSC_ITEM_SUBSTITUTES
        WHERE ( HIGHER_ITEM_ID, LOWER_ITEM_ID, ORGANIZATION_ID, RELATIONSHIP_TYPE) in
                        ( select t1.INVENTORY_ITEM_ID, t2.INVENTORY_ITEM_ID, msis.ORGANIZATION_ID, msis.RELATIONSHIP_TYPE
                           from MSC_ST_ITEM_SUBSTITUTES msis,
                                MSC_ITEM_ID_LID t1,
                                MSC_ITEM_ID_LID t2
                           where
                            t1.SR_INVENTORY_ITEM_ID= msis.HIGHER_ITEM_ID
                        AND t1.SR_INSTANCE_ID= msis.SR_INSTANCE_ID
                        AND t2.SR_INVENTORY_ITEM_ID = msis.LOWER_ITEM_ID
                        --AND plan_id = -1
                        AND t2.SR_INSTANCE_ID = msis.SR_INSTANCE_ID
                        AND msis.SR_INSTANCE_ID = MSC_CL_COLLECTION.v_instance_id
                        AND DELETED_FLAG =1   )
       AND  PLAN_ID =-1
       AND  SR_INSTANCE_ID =MSC_CL_COLLECTION.v_instance_id
        AND ROWNUM <1000;

           COMMIT;
       EXIT WHEN SQL%ROWCOUNT =0 ;
     END LOOP;
     COMMIT;


  open c1;

  IF (c1%ISOPEN) THEN
  LOOP

   IF (lb_FetchComplete) THEN
    EXIT;
   END IF;

   FETCH c1 BULK COLLECT INTO
                             lb_HIGHER_ITEM_ID,
                             lb_LOWER_ITEM_ID ,
                             lb_RECIPROCAL_FLAG ,
                             lb_SUBSTITUTION_SET,
                             lb_ORGANIZATION_ID,
                             lb_EFFECTIVE_DATE,
                             lb_DISABLE_DATE ,
                             lb_RELATIONSHIP_TYPE ,
                             lb_PARTIAL_FULFILLMENT_FLAG,
                             lb_CUSTOMER_ID  ,
                             lb_CUSTOMER_SITE_ID
    LIMIT ln_rows_to_fetch;

    EXIT WHEN lb_HIGHER_ITEM_ID.count = 0;

    IF (c1%NOTFOUND) THEN
     lb_FetchComplete := TRUE;
    END IF;

    FOR j IN 1..lb_HIGHER_ITEM_ID.COUNT LOOP



         UPDATE MSC_ITEM_SUBSTITUTES
        SET
          RECIPROCAL_FLAG = lb_RECIPROCAL_FLAG(j),
          SUBSTITUTION_SET = lb_SUBSTITUTION_SET(j),
          CUSTOMER_ID = lb_CUSTOMER_ID(j),
          CUSTOMER_SITE_ID = lb_CUSTOMER_SITE_ID(j),
          EFFECTIVE_DATE = lb_EFFECTIVE_DATE(j),
          DISABLE_DATE = lb_DISABLE_DATE(j) ,
          PARTIAL_FULFILLMENT_FLAG = lb_PARTIAL_FULFILLMENT_FLAG(j),
          REFRESH_ID = MSC_CL_COLLECTION.v_last_collection_id,
          LAST_UPDATE_DATE = MSC_CL_COLLECTION.v_current_date,
          LAST_UPDATED_BY = MSC_CL_COLLECTION.v_current_user,
          LAST_UPDATE_LOGIN = MSC_CL_COLLECTION.v_current_user,
          CREATION_DATE = MSC_CL_COLLECTION.v_current_date
       WHERE
          PLAN_ID = -1
          AND SR_INSTANCE_ID = MSC_CL_COLLECTION.v_instance_id
          AND HIGHER_ITEM_ID = lb_HIGHER_ITEM_ID(j)
          AND LOWER_ITEM_ID = lb_LOWER_ITEM_ID(j)
          AND ORGANIZATION_ID = lb_ORGANIZATION_ID(j)
          AND RELATIONSHIP_TYPE = lb_RELATIONSHIP_TYPE(j);

        IF SQL%NOTFOUND THEN
        begin
           EXECUTE IMMEDIATE lv_sql_stmt
           USING lb_HIGHER_ITEM_ID(j),
                 lb_LOWER_ITEM_ID(j),
                 lb_RECIPROCAL_FLAG(j),
                 lb_SUBSTITUTION_SET(j),
                 lb_CUSTOMER_ID(j),
                 lb_CUSTOMER_SITE_ID(j),
                 lb_EFFECTIVE_DATE(j),
                 lb_DISABLE_DATE(j),
                 lb_RELATIONSHIP_TYPE(j),
                 lb_PARTIAL_FULFILLMENT_FLAG(j),
                 MSC_CL_COLLECTION.v_last_collection_id,
                 MSC_CL_COLLECTION.v_instance_id,
                 lb_ORGANIZATION_ID(j),
                 MSC_CL_COLLECTION.v_current_date,
                 MSC_CL_COLLECTION.v_current_user,
                 MSC_CL_COLLECTION.v_current_user,
                 MSC_CL_COLLECTION.v_current_date,
                 MSC_CL_COLLECTION.v_current_user;
       EXCEPTION
       WHEN OTHERS THEN
--       LOG_MESSAGE(SQLERRM);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
        IF NOT Handle_Exception(SQLCODE) THEN RAISE; END IF;
      end;
        END IF;

        c_count:= c_count+1;
        IF c_count > MSC_CL_COLLECTION.PBS THEN
           COMMIT;
          -- LOG_MESSAGE('The total record count inserted is '||TO_CHAR(c_count));
           c_count:= 0;
        END IF;

        END loop; -- j loop
        END loop; --c1 loop
        END IF;
     CLOSE c1;

     lb_FetchComplete := FALSE;


   IF (MSC_UTIL.G_COLLECT_SRP_DATA = 'Y' AND (MSC_CL_COLLECTION.v_apps_ver >= MSC_UTIL.G_APPS115 OR MSC_CL_COLLECTION.v_is_legacy_refresh)) THEN
   Open c2;

    IF (c2%ISOPEN) THEN
    LOOP

    IF (lb_FetchComplete) THEN
     EXIT;
    END IF;

     FETCH c2 BULK COLLECT INTO
                             lb_HIGHER_ITEM_ID,
                             lb_LOWER_ITEM_ID ,
                             lb_RECIPROCAL_FLAG ,
                             lb_SUBSTITUTION_SET,
                             lb_ORGANIZATION_ID,
                             lb_RELATIONSHIP_TYPE,
                             lb_PARTIAL_FULFILLMENT_FLAG,
                             lb_EFFECTIVE_DATE,
                             lb_DISABLE_DATE
     LIMIT ln_rows_to_fetch;


     EXIT WHEN lb_HIGHER_ITEM_ID.count = 0;

      IF (c2%NOTFOUND) THEN
        lb_FetchComplete := TRUE;
      END IF;

    FOR j IN 1..lb_HIGHER_ITEM_ID.COUNT LOOP

        UPDATE MSC_ITEM_SUBSTITUTES
        SET
          RECIPROCAL_FLAG = lb_RECIPROCAL_FLAG(j),
          EFFECTIVE_DATE = lb_EFFECTIVE_DATE(j),
          DISABLE_DATE = lb_DISABLE_DATE(j),
          REFRESH_ID = MSC_CL_COLLECTION.v_last_collection_id,
          LAST_UPDATE_DATE = MSC_CL_COLLECTION.v_current_date,
          LAST_UPDATED_BY = MSC_CL_COLLECTION.v_current_user,
          LAST_UPDATE_LOGIN = MSC_CL_COLLECTION.v_current_user,
          CREATION_DATE = MSC_CL_COLLECTION.v_current_date
       WHERE
          PLAN_ID = -1
          AND SR_INSTANCE_ID = MSC_CL_COLLECTION.v_instance_id
          AND HIGHER_ITEM_ID = lb_HIGHER_ITEM_ID(j)
          AND LOWER_ITEM_ID = lb_LOWER_ITEM_ID(j)
          AND ORGANIZATION_ID = lb_ORGANIZATION_ID(j)
          AND RELATIONSHIP_TYPE = lb_RELATIONSHIP_TYPE(j);

        IF SQL%NOTFOUND THEN
        begin

           EXECUTE IMMEDIATE lv_sql_stmt1
           USING lb_HIGHER_ITEM_ID(j),
                 lb_LOWER_ITEM_ID(j),
                 lb_RECIPROCAL_FLAG(j),
                 lb_SUBSTITUTION_SET(j),
                 lb_EFFECTIVE_DATE(j),
                 lb_DISABLE_DATE(j),
                 lb_RELATIONSHIP_TYPE(j),
                 lb_PARTIAL_FULFILLMENT_FLAG(j),
                 MSC_CL_COLLECTION.v_last_collection_id,
                 MSC_CL_COLLECTION.v_instance_id,
                 lb_ORGANIZATION_ID(j),
                 MSC_CL_COLLECTION.v_current_date,
                 MSC_CL_COLLECTION.v_current_user,
                 MSC_CL_COLLECTION.v_current_user,
                 MSC_CL_COLLECTION.v_current_date,
                 MSC_CL_COLLECTION.v_current_user;

          EXCEPTION
          WHEN OTHERS THEN
--          LOG_MESSAGE(SQLERRM);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
        IF NOT Handle_Exception(SQLCODE) THEN RAISE; END IF;
      end;
         END IF;

        c_count:= c_count+1;
        IF c_count > MSC_CL_COLLECTION.PBS THEN
           COMMIT;
--           LOG_MESSAGE('The total record count inserted is '||TO_CHAR(c_count));
           c_count:= 0;
        END IF;


    END LOOP; -- j loop
    END loop; -- c2 loop
    END IF;
    END IF;    -- SRP Collections
    CLOSE c2;
   END IF;  -- End of Net Change


IF ((MSC_CL_COLLECTION.v_coll_prec.org_group_flag <> MSC_UTIL.G_ALL_ORGANIZATIONS) AND (MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES)) THEN

  lv_tbl:= 'ITEM_SUBSTITUTES_'||MSC_CL_COLLECTION.v_INSTANCE_CODE;

  lv_sql_stmt:=
         'INSERT INTO '||lv_tbl
          ||' SELECT * from MSC_ITEM_SUBSTITUTES'
          ||' WHERE sr_instance_id = '||MSC_CL_COLLECTION.v_instance_id
          ||' AND plan_id = -1 '
          ||' AND organization_id not '||MSC_UTIL.v_in_org_str;

   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The sql statement is '||lv_sql_stmt);
   EXECUTE IMMEDIATE lv_sql_stmt;

   COMMIT;

END IF;

IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   MSC_CL_COLLECTION.alter_temp_table (lv_errbuf,
     	               lv_retcode,
                     'MSC_ITEM_SUBSTITUTES',
                     MSC_CL_COLLECTION.v_INSTANCE_CODE,
                     MSC_UTIL.G_WARNING
                     );


   IF lv_retcode = MSC_UTIL.G_WARNING THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_errbuf);
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;
   END IF;

END IF;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_ITEM_SUBSTITUTES');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ITEM_SUBSTITUTES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE

      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_ITEM_SUBSTITUTES');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ITEM_SUBSTITUTES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'HIGHER_ITEM_ID');
 --     FND_MESSAGE.SET_TOKEN('VALUE',TO_CHAR(c_rec.HIGHER_ITEM_ID) );
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'LOWER_ITEM_ID');
 --     FND_MESSAGE.SET_TOKEN('VALUE',TO_CHAR(c_rec.LOWER_ITEM_ID) );
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;


COMMIT;

END LOAD_ITEM_SUBSTITUTES;


   PROCEDURE LOAD_CATEGORY IS

   CURSOR c1 IS
 SELECT /*+ LEADING (msic) */
  msic.ORGANIZATION_ID,
  t1.INVENTORY_ITEM_ID,
  mcsil.Category_Set_ID,
  msic.CATEGORY_NAME,
  msic.DESCRIPTION,
  msic.DISABLE_DATE,
  msic.SUMMARY_FLAG,
  msic.ENABLED_FLAG,
  msic.START_DATE_ACTIVE,
  msic.END_DATE_ACTIVE,
  msic.SR_INSTANCE_ID,
  msic.SR_CATEGORY_ID
FROM MSC_CATEGORY_SET_ID_LID mcsil,
     MSC_ITEM_ID_LID t1,
     MSC_ST_ITEM_CATEGORIES msic
WHERE t1.SR_INVENTORY_ITEM_ID=        msic.inventory_item_id
  AND t1.sr_instance_id= msic.sr_instance_id
  AND mcsil.SR_Category_Set_ID= msic.SR_Category_Set_ID
  AND mcsil.SR_Instance_ID= msic.SR_Instance_ID
  AND msic.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND msic.DELETED_FLAG= MSC_UTIL.SYS_NO;

   CURSOR c1_d IS
SELECT
  msic.ORGANIZATION_ID,
  t1.INVENTORY_ITEM_ID,
  mcsil.Category_Set_ID,
  msic.SR_INSTANCE_ID,
  msic.SR_CATEGORY_ID
FROM MSC_CATEGORY_SET_ID_LID mcsil,
     MSC_ITEM_ID_LID t1,
     MSC_ST_ITEM_CATEGORIES msic
WHERE t1.SR_INVENTORY_ITEM_ID= msic.inventory_item_id
  AND t1.sr_instance_id= msic.sr_instance_id
  AND mcsil.SR_Category_Set_ID= msic.SR_Category_Set_ID
  AND mcsil.SR_Instance_ID= msic.SR_Instance_ID
  AND msic.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND msic.DELETED_FLAG= MSC_UTIL.SYS_YES;

   c_count     NUMBER:= 0;
   lv_tbl      VARCHAR2(30);
   lv_sql_stmt VARCHAR2(5000);
   lv_sql_ins        VARCHAR2(5000);
   lb_FetchComplete  Boolean;
   ln_rows_to_fetch  Number := nvl(TO_NUMBER( FND_PROFILE.VALUE('MRP_PURGE_BATCH_SIZE')),75000);


   TYPE CharTblTyp IS TABLE OF VARCHAR2(250);
  TYPE NumTblTyp  IS TABLE OF NUMBER;
  TYPE dateTblTyp IS TABLE OF DATE;
  lb_organization_id       NumTblTyp;
  lb_inventory_item_id     NumTblTyp;
  lb_category_set_id       NumTblTyp;
  lb_category_name         CharTblTyp;
  lb_description           CharTblTyp;
  lb_disable_date          dateTblTyp;
  lb_summary_flag          CharTblTyp;
  lb_enabled_flag          CharTblTyp;
  lb_start_date_active     dateTblTyp;
  lb_end_date_active       dateTblTyp;
  lb_sr_instance_id        NumTblTyp;
  lb_sr_category_id        NumTblTyp;

  lv_errbuf			VARCHAR2(240);
  lv_retcode			NUMBER;

   BEGIN

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN
         -- We want to delete all CATEGORY related data and get new stuff.

if (MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_NO) then
--MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ITEM_CATEGORIES', MSC_CL_COLLECTION.v_instance_id, NULL);

  IF MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ITEM_CATEGORIES', MSC_CL_COLLECTION.v_instance_id, NULL);
  ELSE
    v_sub_str :=' AND ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ITEM_CATEGORIES', MSC_CL_COLLECTION.v_instance_id, NULL,v_sub_str);
  END IF;
end if;

END IF;

IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   lv_tbl:= 'ITEM_CATEGORIES_'||MSC_CL_COLLECTION.v_INSTANCE_CODE;
ELSE
   lv_tbl:= 'MSC_ITEM_CATEGORIES';
END IF;

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

     BEGIN

     lv_sql_ins :=
     ' INSERT /*+ APPEND  */ '
     || ' INTO '||lv_tbl
     ||' ( ORGANIZATION_ID, '
     ||'   INVENTORY_ITEM_ID, '
     ||'   CATEGORY_SET_ID, '
     ||'   CATEGORY_NAME, '
     ||'   DESCRIPTION, '
     ||'   DISABLE_DATE, '
     ||'   SUMMARY_FLAG, '
     ||'   ENABLED_FLAG, '
     ||'   START_DATE_ACTIVE, '
     ||'   END_DATE_ACTIVE, '
     ||'   SR_INSTANCE_ID, '
     ||'   SR_CATEGORY_ID, '
     ||'   REFRESH_NUMBER, '
     ||'   LAST_UPDATE_DATE, '
     ||'   LAST_UPDATED_BY, '
     ||'   CREATION_DATE, '
     ||'   CREATED_BY) '
     ||'   SELECT /*+ LEADING (msic) */ '
     ||'  msic.ORGANIZATION_ID,'
     ||'  t1.INVENTORY_ITEM_ID,'
     ||'  mcsil.Category_Set_ID,'
     ||'  msic.CATEGORY_NAME,'
     ||'  msic.DESCRIPTION,'
     ||'  msic.DISABLE_DATE,'
     ||'  msic.SUMMARY_FLAG,'
     ||'  msic.ENABLED_FLAG,'
     ||'  msic.START_DATE_ACTIVE,'
     ||'  msic.END_DATE_ACTIVE,'
     ||'  msic.SR_INSTANCE_ID,'
     ||'  msic.SR_CATEGORY_ID,'
     ||'   :v_last_collection_id, '
     ||'   :v_current_date      , '
     ||'   :v_current_user      , '
     ||'   :v_current_date      , '
     ||'   :v_current_user        '
     ||'  FROM MSC_CATEGORY_SET_ID_LID mcsil,'
     ||'     MSC_ITEM_ID_LID t1,'
     ||'     MSC_ST_ITEM_CATEGORIES msic'
     ||'  WHERE t1.SR_INVENTORY_ITEM_ID = msic.inventory_item_id '
     ||'  AND t1.sr_instance_id         = msic.sr_instance_id '
     ||'  AND mcsil.SR_Category_Set_ID  = msic.SR_Category_Set_ID '
     ||'  AND mcsil.SR_Instance_ID      = msic.SR_Instance_ID '
     ||'  AND msic.SR_INSTANCE_ID       = '||MSC_CL_COLLECTION.v_instance_id;

     EXECUTE IMMEDIATE lv_sql_ins
     USING MSC_CL_COLLECTION.v_last_collection_id,MSC_CL_COLLECTION.v_current_date,MSC_CL_COLLECTION.v_current_user,MSC_CL_COLLECTION.v_current_date,MSC_CL_COLLECTION.v_current_user;

     commit;
     EXCEPTION
           WHEN OTHERS THEN

               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
               FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
               FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CATEGORY');
               FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ITEM_CATEGORIES');
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
               RAISE;

     END;
     ELSE
			  FOR c_rec IN c1_d LOOP

					DELETE FROM MSC_ITEM_CATEGORIES
					 WHERE ORGANIZATION_ID= c_rec.ORGANIZATION_ID
					 AND INVENTORY_ITEM_ID= c_rec.INVENTORY_ITEM_ID
					 AND CATEGORY_SET_ID= c_rec.CATEGORY_SET_ID
					 AND SR_CATEGORY_ID= c_rec.SR_CATEGORY_ID
					 AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID;

				END LOOP;
     lv_sql_stmt :=
' INSERT INTO '||lv_tbl
||' ( ORGANIZATION_ID, '
||'   INVENTORY_ITEM_ID, '
||'   CATEGORY_SET_ID, '
||'   CATEGORY_NAME, '
||'   DESCRIPTION, '
||'   DISABLE_DATE, '
||'   SUMMARY_FLAG, '
||'   ENABLED_FLAG, '
||'   START_DATE_ACTIVE, '
||'   END_DATE_ACTIVE, '
||'   SR_INSTANCE_ID, '
||'   SR_CATEGORY_ID, '
||'   REFRESH_NUMBER, '
||'   LAST_UPDATE_DATE, '
||'   LAST_UPDATED_BY, '
||'   CREATION_DATE, '
||'   CREATED_BY) '
||' VALUES '
||' ( :ORGANIZATION_ID, '
||'   :INVENTORY_ITEM_ID, '
||'   :CATEGORY_SET_ID, '
||'   :CATEGORY_NAME, '
||'   :DESCRIPTION, '
||'   :DISABLE_DATE, '
||'   :SUMMARY_FLAG, '
||'   :ENABLED_FLAG, '
||'   :START_DATE_ACTIVE, '
||'   :END_DATE_ACTIVE, '
||'   :SR_INSTANCE_ID, '
||'   :SR_CATEGORY_ID, '
||'   :v_last_collection_id, '
||'   :v_current_date, '
||'   :v_current_user, '
||'   :v_current_date, '
||'   :v_current_user ) ';


c_count:= 0;

OPEN  c1;
IF (c1%ISOPEN) THEN
       LOOP

         --
         -- Retrieve the next set of rows if we are currently not in the
         -- middle of processing a fetched set or rows.
         --
         IF (lb_FetchComplete) THEN
           EXIT;
         END IF;

         -- Fetch the next set of rows
FETCH c1 BULK COLLECT INTO   lb_organization_id,
                             lb_inventory_item_id,
                             lb_category_set_id,
                             lb_category_name,
                             lb_description,
                             lb_disable_date,
                             lb_summary_flag,
                             lb_enabled_flag,
                             lb_start_date_active,
                             lb_end_date_active,
                             lb_sr_instance_id,
                             lb_sr_category_id
LIMIT ln_rows_to_fetch;

         -- Since we are only fetching records if either (1) this is the first
         -- fetch or (2) the previous fetch did not retrieve all of the
         -- records, then at least one row should always be fetched.  But
         -- checking just to make sure.
         EXIT WHEN lb_inventory_item_id.count = 0;

         -- Check if all of the rows have been fetched.  If so, indicate that
         -- the fetch is complete so that another fetch is not made.
         -- Additional check is introduced for the following reasons
         -- In 9i, the table of records gets modified but in 8.1.6 the table of records is
         -- unchanged after the fetch(bug#2995144)
         IF (c1%NOTFOUND) THEN
           lb_FetchComplete := TRUE;
         END IF;

FOR j IN 1..lb_inventory_item_id.COUNT LOOP

BEGIN

IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

UPDATE MSC_ITEM_CATEGORIES
SET
CATEGORY_NAME          = lb_category_name(j),
 DESCRIPTION            = lb_description(j),
 DISABLE_DATE           = lb_disable_date(j),
 SUMMARY_FLAG           = lb_summary_flag(j),
 ENABLED_FLAG           = lb_enabled_flag(j),
 START_DATE_ACTIVE      = lb_start_date_active(j),
 END_DATE_ACTIVE        = lb_end_date_active(J),
 /* SR_CATEGORY_ID= lb_sr_category_id(j),               --If the item is assigned to more than 1 category in the same category-set then,
							only one row of that category set will be repeatedly updated and the other
							item categories will not be inserted. Moving this into the WHERE clause.
*/
 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE ORGANIZATION_ID   = lb_organization_id(j)
  AND INVENTORY_ITEM_ID = lb_inventory_item_id(J)
  AND CATEGORY_SET_ID   = lb_category_set_id(j)
  AND SR_INSTANCE_ID    = lb_sr_instance_id(j)
  AND SR_CATEGORY_ID    = lb_sr_category_id(j);

END IF;

IF SQL%NOTFOUND THEN
EXECUTE IMMEDIATE lv_sql_stmt
USING
 lb_organization_id(j),
  lb_inventory_item_id(J),
  lb_category_set_id(j),
  lb_category_name(j),
  lb_description(j),
  lb_disable_date(j),
  lb_summary_flag(j),
  lb_enabled_flag(j),
  lb_start_date_active(j),
  lb_end_date_active(J),
  lb_sr_instance_id(j),
  lb_sr_category_id(j),
  MSC_CL_COLLECTION.v_last_collection_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user  ;

END IF;

  c_count:= c_count+1;

  IF c_count>MSC_CL_COLLECTION.PBS THEN

     COMMIT;

     c_count:= 0;

  END IF;


EXCEPTION
   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CATEGORY');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ITEM_CATEGORIES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE

      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CATEGORY');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ITEM_CATEGORIES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ITEM_NAME');
      FND_MESSAGE.SET_TOKEN('VALUE', ITEM_NAME( lb_inventory_item_id(J)));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
      FND_MESSAGE.SET_TOKEN('VALUE',
                            MSC_GET_NAME.ORG_CODE( lb_organization_id(j),
                                                   MSC_CL_COLLECTION.v_instance_id));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'CATEGORY_NAME');
      FND_MESSAGE.SET_TOKEN('VALUE', lb_category_name(j));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;
 END LOOP;
 END IF;
 CLOSE c1;
END IF;
COMMIT;

BEGIN

IF ((MSC_CL_COLLECTION.v_coll_prec.org_group_flag <> MSC_UTIL.G_ALL_ORGANIZATIONS) AND (MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES)) THEN

lv_tbl:= 'ITEM_CATEGORIES_'||MSC_CL_COLLECTION.v_INSTANCE_CODE;

lv_sql_stmt:=
         'INSERT INTO '||lv_tbl
          ||' SELECT * from MSC_ITEM_CATEGORIES'
          ||' WHERE sr_instance_id = '||MSC_CL_COLLECTION.v_instance_id
          ||' AND organization_id not '||MSC_UTIL.v_in_org_str;

   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The sql statement is '||lv_sql_stmt);
   EXECUTE IMMEDIATE lv_sql_stmt;

   COMMIT;

END IF;

IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   MSC_CL_COLLECTION.alter_temp_table (lv_errbuf,
   	              lv_retcode,
                      'MSC_ITEM_CATEGORIES',
                      MSC_CL_COLLECTION.v_INSTANCE_CODE,
                      MSC_UTIL.G_ERROR
                     );

   IF lv_retcode = MSC_UTIL.G_ERROR THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_errbuf);
      RAISE MSC_CL_COLLECTION.ALTER_TEMP_TABLE_ERROR;
   ELSIF lv_retcode = MSC_UTIL.G_WARNING THEN
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;
   END IF;

END IF;

EXCEPTION
  WHEN OTHERS THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
END;

  END LOAD_CATEGORY;

     -- ============== KEY TRANSFORMATION FOR ITEMS, CATEGORY SETS =================

   PROCEDURE GENERATE_ITEM_KEYS (
                ERRBUF				OUT NOCOPY VARCHAR2,
	        RETCODE				OUT NOCOPY NUMBER,
     		pINSTANCE_ID                    IN  NUMBER) IS

   Cursor c3 IS
      SELECT mcsil.Category_Set_ID,
             mscs.Category_set_Name,
             mscs.DESCRIPTION,
             mscs.CONTROL_LEVEL,
             mscs.DEFAULT_FLAG,
             mscs.SR_INSTANCE_ID
        FROM MSC_CATEGORY_SET_ID_LID mcsil,
             MSC_ST_CATEGORY_SETS mscs
       WHERE mcsil.SR_Category_Set_ID= mscs.SR_Category_Set_ID
         AND mcsil.SR_Instance_ID= mscs.SR_Instance_ID
         AND mscs.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
       ORDER BY
             mcsil.Category_Set_ID;

   Cursor c4 IS
      SELECT distinct msi.Item_Name
        FROM MSC_ST_SYSTEM_ITEMS msi
       WHERE NOT EXISTS ( select 1
                               from MSC_ITEMS mi
                              where mi.Item_Name= msi.Item_Name)
         AND msi.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
    ORDER BY msi.Item_Name;    -- using ORDER BY to avoid dead lock

   Cursor c8 IS
         SELECT DISTINCT
                mscs.Category_Set_Name
           FROM MSC_ST_CATEGORY_SETS mscs
          WHERE NOT EXISTS ( select 1
                               from MSC_Category_Sets mcs
                              where mscs.Category_Set_Name= mcs.Category_Set_Name)
            AND mscs.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
       ORDER BY mscs.Category_Set_Name;  -- using ORDER BY to avoid dead lock

   CURSOR c11 IS
    SELECT distinct
           msi.SR_INVENTORY_ITEM_ID, msi.SR_INSTANCE_ID, mi.INVENTORY_ITEM_ID
      FROM MSC_ST_SYSTEM_ITEMS msi,
           MSC_ITEMS mi
     WHERE NOT EXISTS( select 1
                         from MSC_ITEM_ID_LID miil
                        where msi.SR_INVENTORY_ITEM_ID=
                              miil.SR_INVENTORY_ITEM_ID
                          and msi.SR_INSTANCE_ID= miil.SR_INSTANCE_ID)
       AND msi.ITEM_NAME= mi.ITEM_NAME
       AND msi.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

   lv_default_category_set_id  NUMBER;
   lv_control_flag NUMBER;

   lv_item_id_count NUMBER := 0;
   lv_cat_id_count  NUMBER := 0;
   lv_items_stat_stale NUMBER := MSC_UTIL.SYS_NO;
   lv_cat_stat_stale   NUMBER := MSC_UTIL.SYS_NO;
   lv_ins_records   NUMBER := 0;

   BEGIN

--  MSC_CL_SETUP_COLLECTION.GET_COLL_PARAM (pINSTANCE_ID);   -- 2 be changed

MSC_CL_COLLECTION.INITIALIZE( pINSTANCE_ID);

SELECT decode(nvl(fnd_profile.value('MSC_PURGE_ST_CONTROL'),'N'),'Y',1,2)
INTO lv_control_flag
FROM dual;

begin
    select num_rows,decode (stale_stats,'NO', MSC_UTIL.SYS_NO, MSC_UTIL.SYS_YES )
     into  lv_item_id_count, lv_items_stat_stale
    from dba_TAB_STATISTICS
    where table_name =  'MSC_ITEM_ID_LID';
exception when no_data_found then
          lv_items_stat_stale := MSC_UTIL.SYS_YES ;
end;

begin
    select num_rows,decode (stale_stats,'NO', MSC_UTIL.SYS_NO, MSC_UTIL.SYS_YES )
     into  lv_cat_id_count, lv_cat_stat_stale
    from dba_TAB_STATISTICS
    where table_name ='MSC_CATEGORY_SET_ID_LID';
exception when no_data_found then
          lv_cat_stat_stale := MSC_UTIL.SYS_YES ;
end;


/* if complete refresh, regen the key mapping data */
IF MSC_CL_COLLECTION.v_is_complete_refresh THEN

 IF lv_control_flag = 2 THEN

   IF MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
      DELETE MSC_ITEM_ID_LID    WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;
      DELETE MSC_CATEGORY_SET_ID_LID  WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;
      DELETE MSC_ITEM_ID_LID    WHERE SR_INSTANCE_ID= -1;
      DELETE MSC_CATEGORY_SET_ID_LID  WHERE SR_INSTANCE_ID= -1;
      lv_items_stat_stale := MSC_UTIL.SYS_YES;
      lv_cat_stat_stale   := MSC_UTIL.SYS_YES;
   END IF;

 ELSE

   IF MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
     MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ITEM_ID_LID');
     MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_CATEGORY_SET_ID_LID');
     lv_items_stat_stale := MSC_UTIL.SYS_YES;
     lv_cat_stat_stale   := MSC_UTIL.SYS_YES;
   END IF;

 END IF;

END IF;

   /*************** PREPLACE CHANGE START *****************/

   IF MSC_CL_COLLECTION.v_is_partial_refresh THEN

      IF (MSC_CL_COLLECTION.v_coll_prec.item_flag  = MSC_UTIL.SYS_YES and MSC_CL_COLLECTION.v_coll_prec.org_group_flag =MSC_UTIL.G_ALL_ORGANIZATIONS ) THEN

           IF lv_control_flag = 2 THEN
             DELETE MSC_ITEM_ID_LID    WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;
             DELETE MSC_CATEGORY_SET_ID_LID  WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;
             DELETE MSC_ITEM_ID_LID    WHERE SR_INSTANCE_ID= -1;
             DELETE MSC_CATEGORY_SET_ID_LID  WHERE SR_INSTANCE_ID= -1;
             lv_items_stat_stale := MSC_UTIL.SYS_YES;
             lv_cat_stat_stale   := MSC_UTIL.SYS_YES;
           ELSE
             MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ITEM_ID_LID');
             MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_CATEGORY_SET_ID_LID');
             lv_items_stat_stale := MSC_UTIL.SYS_YES;
             lv_cat_stat_stale   := MSC_UTIL.SYS_YES;
           END IF;

      END IF;

   END IF;

   /***************  PREPLACE CHANGE END  *****************/

--agmcont
   IF MSC_CL_COLLECTION.v_is_cont_refresh THEN

      IF (MSC_CL_COLLECTION.v_coll_prec.item_flag  = MSC_UTIL.SYS_YES) and
          (MSC_CL_COLLECTION.v_coll_prec.item_sn_flag  = MSC_UTIL.SYS_TGT) and (MSC_CL_COLLECTION.v_coll_prec.org_group_flag=MSC_UTIL.G_ALL_ORGANIZATIONS) THEN

           IF lv_control_flag = 2 THEN
             DELETE MSC_ITEM_ID_LID    WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;
             DELETE MSC_CATEGORY_SET_ID_LID  WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;
             DELETE MSC_ITEM_ID_LID    WHERE SR_INSTANCE_ID= -1;
             DELETE MSC_CATEGORY_SET_ID_LID  WHERE SR_INSTANCE_ID= -1;
             lv_items_stat_stale := MSC_UTIL.SYS_YES;
             lv_cat_stat_stale   := MSC_UTIL.SYS_YES;
           ELSE
             MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ITEM_ID_LID');
             MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_CATEGORY_SET_ID_LID');
             lv_items_stat_stale := MSC_UTIL.SYS_YES;
             lv_cat_stat_stale   := MSC_UTIL.SYS_YES;
           END IF;

      END IF;

   END IF;

COMMIT;

  --========== ITEM ==========
FOR c_rec IN c4 LOOP

BEGIN

INSERT INTO MSC_ITEMS
( ITEM_NAME,
  INVENTORY_ITEM_ID,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
( c_rec.Item_Name,
  MSC_Items_S.NEXTVAL,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user);

EXCEPTION

   WHEN DUP_VAL_ON_INDEX THEN

        NULL;

   WHEN OTHERS THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'GENERATE_ITEM_KEYS');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ITEMS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ITEM_NAME');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.ITEM_NAME);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

      ERRBUF := sqlerrm;
      RETCODE := MSC_UTIL.G_ERROR;
      RAISE;

END;

END LOOP;

COMMIT;

lv_ins_records := 0;

FOR c_rec IN c11 LOOP

BEGIN

INSERT INTO MSC_ITEM_ID_LID
( SR_INVENTORY_ITEM_ID,
  SR_INSTANCE_ID,
  INVENTORY_ITEM_ID)
VALUES
( c_rec.SR_INVENTORY_ITEM_ID,
  c_rec.SR_INSTANCE_ID,
  c_rec.INVENTORY_ITEM_ID);

lv_ins_records := lv_ins_records + 1;

EXCEPTION

   WHEN OTHERS THEN

    IF SQLCODE IN (-1653,-1654) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'GENERATE_ITEM_KEYS');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ITEM_ID_LID');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ITEM_NAME');
      FND_MESSAGE.SET_TOKEN('VALUE', ITEM_NAME( c_rec.INVENTORY_ITEM_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'SR_INVENTORY_ITEM_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.SR_INVENTORY_ITEM_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

      ERRBUF := sqlerrm;
      RETCODE := MSC_UTIL.G_ERROR;
      RAISE;

    ELSE

      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'GENERATE_ITEM_KEYS');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ITEM_ID_LID');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ITEM_NAME');
      FND_MESSAGE.SET_TOKEN('VALUE', ITEM_NAME( c_rec.INVENTORY_ITEM_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'SR_INVENTORY_ITEM_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.SR_INVENTORY_ITEM_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

      ERRBUF := sqlerrm;
      RETCODE := MSC_UTIL.G_WARNING;

    END IF;

END;

END LOOP;

COMMIT;

/* Bug 7653761 - If inserted records are more than 20% */
IF lv_items_stat_stale = MSC_UTIL.SYS_NO  AND lv_ins_records > lv_item_id_count * 0.2 THEN
   lv_items_stat_stale := MSC_UTIL.SYS_YES;
END IF;

  --========== CATEGORY SET ==========

FOR c_rec IN c8 LOOP

BEGIN

INSERT INTO MSC_CATEGORY_SETS
( CATEGORY_SET_ID,
  CATEGORY_SET_NAME,
  CONTROL_LEVEL,
  SR_CATEGORY_SET_ID,  -- using ORDER BY to avoid dead lock
  SR_INSTANCE_ID,
  REFRESH_NUMBER,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
( MSC_Category_Sets_S.NEXTVAL,
  c_rec.Category_Set_Name,
  -1,
  MSC_Category_Sets_S.NEXTVAL, -- dummy value to satisfy the unique constraint
  -1,
  MSC_CL_COLLECTION.v_last_collection_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user);

EXCEPTION

   WHEN DUP_VAL_ON_INDEX THEN

        NULL;

   WHEN OTHERS THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'GENERATE_ITEM_KEYS');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_CATEGORY_SETS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'CATEGORY_SET_NAME');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.CATEGORY_SET_NAME);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

      ERRBUF := sqlerrm;
      RETCODE := MSC_UTIL.G_ERROR;
      RAISE;

END;

END LOOP;

COMMIT;

INSERT INTO MSC_CATEGORY_SET_ID_LID
( SR_Category_Set_ID,
  SR_INSTANCE_ID,
  Category_Set_ID)
    SELECT distinct
           mscs.SR_Category_Set_ID,
           mscs.SR_INSTANCE_ID,
           mcs.Category_Set_ID
      FROM MSC_ST_CATEGORY_SETS mscs,
           MSC_CATEGORY_SETS mcs
     WHERE NOT EXISTS( select 1
                         from MSC_CATEGORY_SET_ID_LID mcsil
                        where mscs.SR_Category_Set_ID= mcsil.SR_Category_Set_ID
                          and mscs.SR_INSTANCE_ID= mcsil.SR_INSTANCE_ID)
       AND mscs.Category_Set_NAME= mcs.Category_Set_NAME
       AND mscs.SR_INSTANCE_ID = MSC_CL_COLLECTION.v_instance_id;

lv_ins_records := SQL%ROWCOUNT;

COMMIT;

/* Bug 7653761 - If inserted records are more than 20%*/
IF lv_cat_stat_stale = MSC_UTIL.SYS_NO AND lv_ins_records > lv_cat_id_count * 0.2 THEN
   lv_cat_stat_stale := MSC_UTIL.SYS_YES;
END IF;

  /* in order to set default flag, access the lock on the table first*/
  LOCK TABLE MSC_CATEGORY_SETS IN EXCLUSIVE MODE;

  lv_default_category_set_id:= NULL;

  FOR c_rec IN c3 LOOP

BEGIN

UPDATE MSC_Category_Sets mcs
SET mcs.DESCRIPTION= c_rec.Description,
    mcs.CONTROL_LEVEL= c_rec.Control_Level,
    mcs.DEFAULT_FLAG= c_rec.DEFAULT_FLAG,
    mcs.SR_INSTANCE_ID= c_rec.SR_Instance_ID,
    REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
    LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
    LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user,
    CREATION_DATE= MSC_CL_COLLECTION.v_current_date,
    CREATED_BY=  MSC_CL_COLLECTION.v_current_user
WHERE mcs.Category_Set_ID= c_rec.Category_Set_ID;

    IF c_rec.DEFAULT_FLAG= 1 THEN
       lv_default_category_set_id:= c_rec.Category_Set_ID;
    END IF;

EXCEPTION

   WHEN OTHERS THEN

    IF SQLCODE IN (-1653,-1654) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'GENERATE_ITEM_KEYS');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_CATEGORY_SETS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'CATEGORY_SET_NAME');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.CATEGORY_SET_NAME);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

      ERRBUF := sqlerrm;
      RETCODE := MSC_UTIL.G_ERROR;
      RAISE;

    ELSE

      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'GENERATE_ITEM_KEYS');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_CATEGORY_SETS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'CATEGORY_SET_NAME');
      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.CATEGORY_SET_NAME);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

      ERRBUF := sqlerrm;
      RETCODE := MSC_UTIL.G_WARNING;

    END IF;

  END;

  END LOOP;

  IF lv_default_category_set_id IS NOT NULL THEN

     UPDATE MSC_CATEGORY_SETS
        SET DEFAULT_FLAG= 2
      WHERE DEFAULT_FLAG= 1
        AND CATEGORY_SET_ID <> lv_default_category_set_id;

  END IF;

  COMMIT;

  /* analyse the key mapping tables */
  IF MSC_CL_COLLECTION.v_coll_prec.item_flag  = MSC_UTIL.SYS_YES THEN
     IF lv_items_stat_stale = MSC_UTIL.SYS_YES THEN
        msc_analyse_tables_pk.analyse_table( 'MSC_ITEM_ID_LID');
     END IF;
     IF lv_cat_stat_stale = MSC_UTIL.SYS_YES THEN
        msc_analyse_tables_pk.analyse_table( 'MSC_CATEGORY_SET_ID_LID');
     END IF;
  END IF;

EXCEPTION

  WHEN OTHERS THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);

      ERRBUF := sqlerrm;
      RETCODE := MSC_UTIL.G_ERROR;
      RAISE;

   END GENERATE_ITEM_KEYS;

--==================================================================

   PROCEDURE LOAD_SUPPLIER_CAPACITY IS

   CURSOR c1 IS
SELECT
  msis.ORGANIZATION_ID,
  msis.USING_ORGANIZATION_ID,
  mtil.TP_ID SUPPLIER_ID,
  mtsil.TP_SITE_ID SUPPLIER_SITE_ID,
  t1.INVENTORY_ITEM_ID,
  msis.PROCESSING_LEAD_TIME,
  msis.MINIMUM_ORDER_QUANTITY,
  msis.FIXED_LOT_MULTIPLE,
  msis.DELIVERY_CALENDAR_CODE,
  msis.SUPPLIER_CAP_OVER_UTIL_COST,
  msis.PURCHASING_UNIT_OF_MEASURE,
  msis.SR_INSTANCE_ID2,
  msis.ITEM_PRICE, --Item Price by Supplier Fix
  /* SCE Change starts */
  -- Pull Supplier Item Name for cross reference functionality.
  msis.supplier_item_name,
  msis.planner_code,
  msis.vmi_flag,
  msis.min_minmax_quantity,
  msis.max_minmax_quantity,
  msis.maximum_order_quantity,
  --msis.VMI_UNIT_OF_MEASURE,
  msis.VMI_REPLENISHMENT_APPROVAL,
  msis.ENABLE_VMI_AUTO_REPLENISH_FLAG,
  muom.uom_code,
  --muom1.uom_code VMI_UOM_CODE,
  msis.REPLENISHMENT_METHOD,
  msis.MIN_MINMAX_DAYS,
  msis.MAX_MINMAX_DAYS,
  msis.FORECAST_HORIZON,
  msis.FIXED_ORDER_QUANTITY,
  /* SCE Change ends */
    msis.SR_INSTANCE_ID
FROM MSC_TP_ID_LID mtil,
     MSC_TP_SITE_ID_LID mtsil,
     MSC_ITEM_ID_LID t1,
     MSC_ST_ITEM_SUPPLIERS msis,
     MSC_UNITS_OF_MEASURE muom
     -- MSC_UNITS_OF_MEASURE muom1
WHERE t1.SR_INVENTORY_ITEM_ID=        msis.inventory_item_id
  AND t1.sr_instance_id= msis.sr_instance_id
  AND mtil.SR_TP_ID = msis.SUPPLIER_ID
  AND mtil.SR_INSTANCE_ID = msis.SR_INSTANCE_ID
  AND mtil.PARTNER_TYPE = 1
  AND mtsil.SR_TP_SITE_ID(+)= msis.Supplier_Site_ID
  AND mtsil.SR_INSTANCE_ID(+)= msis.SR_Instance_ID
  AND mtsil.Partner_Type(+)= 1
  /* SCE Change starts */
  -- Pull only valid records
  AND nvl(msis.process_flag, -99) <> MSC_UTIL.G_ERROR
  -- Make a join with company_id
  -- If company_id is null then it means the record is owned by the Application
  -- owner company.
  AND nvl(msis.company_id, -1) = nvl(mtil.sr_company_id, -1)
  AND nvl(msis.company_id, -1) = nvl(mtsil.sr_company_id, -1)
  -- Join to get uom_code
  AND nvl(msis.purchasing_unit_of_measure, '-99') = muom.unit_of_measure (+)
  -- Join to get vmi_uom_code
  -- AND nvl(msis.vmi_unit_of_measure, '-99') = muom1.unit_of_measure (+)
  /* SCE change ends */
  AND msis.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

   CURSOR c2 IS
SELECT
  mssc.ORGANIZATION_ID,
  mssc.USING_ORGANIZATION_ID,
  mtil.TP_ID         SUPPLIER_ID,
  mtsil.TP_SITE_ID   SUPPLIER_SITE_ID,
  t1.INVENTORY_ITEM_ID,
  mssc.FROM_DATE,
  mssc.TO_DATE,
  mssc.CAPACITY,
  mssc.SR_INSTANCE_ID
FROM MSC_TP_ID_LID mtil,
     MSC_TP_SITE_ID_LID mtsil,
     MSC_ITEM_ID_LID t1,
     MSC_ST_SUPPLIER_CAPACITIES mssc
WHERE t1.SR_INVENTORY_ITEM_ID=        mssc.inventory_item_id
  AND t1.sr_instance_id= mssc.sr_instance_id
  AND mtil.SR_TP_ID = mssc.SUPPLIER_ID
  AND mtil.SR_INSTANCE_ID = mssc.SR_INSTANCE_ID
  AND mtil.PARTNER_TYPE = 1
  AND mtsil.SR_TP_SITE_ID(+)= mssc.Supplier_Site_ID
  AND mtsil.SR_INSTANCE_ID(+)= mssc.SR_Instance_ID
  AND mtsil.Partner_Type(+)= 1
  AND mssc.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND mssc.DELETED_FLAG= MSC_UTIL.SYS_NO
  AND NVL(decode( MSC_CL_COLLECTION.v_coll_prec.app_supp_cap_flag, MSC_UTIL.ASL_YES, 1,
                                                MSC_UTIL.ASL_YES_RETAIN_CP, (select distinct 0
                                                from msc_supplier_capacities msc1
                                                where msc1.SR_INSTANCE_ID = mssc.SR_INSTANCE_ID
                                                and msc1.ORGANIZATION_ID = mssc.ORGANIZATION_ID
                                                and msc1.INVENTORY_ITEM_ID = t1.INVENTORY_ITEM_ID
                                                and msc1.SUPPLIER_ID = mtil.TP_ID
                                                and msc1.SUPPLIER_SITE_ID = mtsil.TP_SITE_ID
                                                and msc1.collected_flag=3 )
                  ,0 ) , 1 ) = 1;

   CURSOR c2d IS
SELECT
  mssc.ORGANIZATION_ID,
  mssc.USING_ORGANIZATION_ID,
  mtil.TP_ID         SUPPLIER_ID,
  mtsil.TP_SITE_ID   SUPPLIER_SITE_ID,
  t1.INVENTORY_ITEM_ID,
  mssc.FROM_DATE,
  mssc.SR_INSTANCE_ID
FROM MSC_TP_ID_LID mtil,
     MSC_TP_SITE_ID_LID mtsil,
     MSC_ITEM_ID_LID t1,
     MSC_ST_SUPPLIER_CAPACITIES mssc
WHERE t1.SR_INVENTORY_ITEM_ID=        mssc.inventory_item_id
  AND t1.sr_instance_id= mssc.sr_instance_id
  AND mtil.SR_TP_ID = mssc.SUPPLIER_ID
  AND mtil.SR_INSTANCE_ID = mssc.SR_INSTANCE_ID
  AND mtil.PARTNER_TYPE = 1
  AND mtsil.SR_TP_SITE_ID(+)= mssc.Supplier_Site_ID
  AND mtsil.SR_INSTANCE_ID(+)= mssc.SR_Instance_ID
  AND mtsil.Partner_Type(+)= 1
  AND mssc.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND mssc.DELETED_FLAG= MSC_UTIL.SYS_YES;

  CURSOR c5d IS
 SELECT mssc.ORGANIZATION_ID,
  mssc.USING_ORGANIZATION_ID,
  mtil.TP_ID         SUPPLIER_ID,
  mtsil.TP_SITE_ID   SUPPLIER_SITE_ID,
  t1.INVENTORY_ITEM_ID,
  mssc.FROM_DATE,
  mssc.SR_INSTANCE_ID
FROM MSC_TP_ID_LID mtil,
     MSC_TP_SITE_ID_LID mtsil,
     MSC_ITEM_ID_LID t1,
     MSC_ST_SUPPLIER_CAPACITIES mssc,
     MSC_SUPPLIER_CAPACITIES msc1
WHERE t1.SR_INVENTORY_ITEM_ID=        mssc.inventory_item_id
  AND t1.sr_instance_id= mssc.sr_instance_id
  AND mtil.SR_TP_ID = mssc.SUPPLIER_ID
  AND mtil.SR_INSTANCE_ID = mssc.SR_INSTANCE_ID
  AND mtil.PARTNER_TYPE = 1
  AND mtsil.SR_TP_SITE_ID(+)= mssc.Supplier_Site_ID
  AND mtsil.SR_INSTANCE_ID(+)= mssc.SR_Instance_ID
  AND mtsil.Partner_Type(+)= 1
  AND msc1.supplier_id = mtil.tp_id
  AND msc1.supplier_site_id(+) = mtsil.tp_site_id
  AND msc1.inventory_item_id = t1.inventory_item_id
  AND msc1.organization_id = mssc.organization_id
  AND msc1.sr_instance_id = mssc.sr_instance_id
  AND mssc.SR_INSTANCE_ID = MSC_CL_COLLECTION.v_instance_id
  AND msc1.collected_flag = 3
  AND decode(MSC_CL_COLLECTION.v_coll_prec.app_supp_cap_flag , MSC_UTIL.ASL_YES,1,0)= 1;

   CURSOR c3 IS
SELECT
  mtil.TP_ID        SUPPLIER_ID,
  mtsil.TP_SITE_ID  SUPPLIER_SITE_ID,
  mssfe.ORGANIZATION_ID,
  mssfe.USING_ORGANIZATION_ID,
  t1.INVENTORY_ITEM_ID,             -- mssfe.INVENTORY_ITEM_ID,
  mssfe.FENCE_DAYS,
  mssfe.TOLERANCE_PERCENTAGE,
  mssfe.SR_INSTANCE_ID
FROM MSC_TP_ID_LID mtil,
     MSC_TP_SITE_ID_LID mtsil,
     MSC_ITEM_ID_LID t1,
     MSC_ST_SUPPLIER_FLEX_FENCES mssfe
WHERE t1.SR_INVENTORY_ITEM_ID=        mssfe.inventory_item_id
  AND t1.sr_instance_id= mssfe.sr_instance_id
  AND mtil.SR_TP_ID = mssfe.SUPPLIER_ID
  AND mtil.SR_INSTANCE_ID = mssfe.SR_INSTANCE_ID
  AND mtil.PARTNER_TYPE = 1
  AND mtsil.SR_TP_SITE_ID(+)= mssfe.Supplier_Site_ID
  AND mtsil.SR_INSTANCE_ID(+)= mssfe.SR_Instance_ID
  AND mtsil.Partner_Type(+)= 1
  AND mssfe.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

   /*ASL */
Cursor del_asl is
	SELECT T1.INVENTORY_ITEM_ID, msis.USING_ORGANIZATION_ID,
				mtil.TP_ID SUPPLIER_ID, mtsil.TP_SITE_ID SUPPLIER_SITE_ID
	FROM   MSC_TP_ID_LID mtil,
				 MSC_TP_SITE_ID_LID mtsil,
	     	 MSC_ITEM_ID_LID t1,
	     	 MSC_ST_ITEM_SUPPLIERS msis
	 WHERE t1.SR_INVENTORY_ITEM_ID= msis.inventory_item_id
	  AND t1.sr_instance_id= msis.sr_instance_id
	  AND mtil.SR_TP_ID = msis.SUPPLIER_ID
	  AND mtil.SR_INSTANCE_ID = msis.SR_INSTANCE_ID
	  AND mtil.PARTNER_TYPE = 1
	  AND mtsil.SR_TP_SITE_ID (+)= msis.Supplier_Site_ID
	  AND mtsil.SR_INSTANCE_ID (+)= msis.SR_Instance_ID
	  AND mtsil.Partner_Type (+)= 1
	  AND nvl(msis.process_flag, -99) <> MSC_UTIL.G_ERROR
	  AND nvl(msis.company_id, -1) = nvl (mtil.sr_company_id, -1)
	  AND nvl(msis.company_id, -1) = nvl (mtsil.sr_company_id, -1)
	  AND msis.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
	  And msis.deleted_flag=MSC_UTIL.SYS_YES
  ;


	CURSOR c4  IS
	SELECT
	  Msis.ORGANIZATION_ID,
	  Msis.USING_ORGANIZATION_ID,
	  Mtil.TP_ID  SUPPLIER_ID,
	  Mtsil.TP_SITE_ID SUPPLIER_SITE_ID,
	  T1.INVENTORY_ITEM_ID,
	  Msis.PROCESSING_LEAD_TIME,
	  Msis.MINIMUM_ORDER_QUANTITY,
	  Msis.FIXED_LOT_MULTIPLE,
	  Msis.DELIVERY_CALENDAR_CODE,
	  Msis.SUPPLIER_CAP_OVER_UTIL_COST,
	  Msis.PURCHASING_UNIT_OF_MEASURE,
	  Msis.SR_INSTANCE_ID2,
	  Msis.ITEM_PRICE, --Item Price by Supplier Fix
	  /* SCE Change starts */
	  -- Pull Supplier Item Name for cross-reference functionality.
	  Msis.supplier_item_name,
	  Msis.planner_code,
	  Msis.vmi_flag,
	  Msis.min_minmax_quantity,
	  Msis.max_minmax_quantity,
	  Msis.maximum_order_quantity,
	  --msis. VMI_UNIT_OF_MEASURE,
	  Msis.VMI_REPLENISHMENT_APPROVAL,
	  Msis.ENABLE_VMI_AUTO_REPLENISH_FLAG,
	  Muom.uom_code,
	  --Muom1.uom_code VMI_UOM_CODE,
	  Msis.REPLENISHMENT_METHOD,
	  Msis.MIN_MINMAX_DAYS,
	  Msis.MAX_MINMAX_DAYS,
	  Msis.FORECAST_HORIZON,
	  Msis.FIXED_ORDER_QUANTITY,
	  /* SCE Change ends */
	    Msis.SR_INSTANCE_ID
	FROM MSC_TP_ID_LID mtil,
	     MSC_TP_SITE_ID_LID mtsil,
	     MSC_ITEM_ID_LID t1,
	     MSC_ST_ITEM_SUPPLIERS msis,
	     MSC_UNITS_OF_MEASURE muom
	WHERE t1.SR_INVENTORY_ITEM_ID= msis.inventory_item_id
	  AND t1.sr_instance_id= msis.sr_instance_id
	  AND mtil.SR_TP_ID = msis.SUPPLIER_ID
	  AND mtil.SR_INSTANCE_ID = msis.SR_INSTANCE_ID
	  AND mtil.PARTNER_TYPE = 1
	  AND mtsil.SR_TP_SITE_ID (+)= msis.Supplier_Site_ID
	  AND mtsil.SR_INSTANCE_ID (+)= msis.SR_Instance_ID
	  AND mtsil.Partner_Type (+)= 1
	  AND nvl (msis.process_flag, -99) <> MSC_UTIL.G_ERROR
	  AND nvl (msis.company_id, -1) = nvl (mtil.sr_company_id, -1)
	  AND nvl (msis.company_id, -1) = nvl (mtsil.sr_company_id, -1)
	  AND nvl (msis.purchasing_unit_of_measure, '-99') = muom.unit_of_measure (+)
	  AND msis.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
	  AND  msis.deleted_flag=MSC_UTIL.SYS_NO ;

	lv_table_name         VARCHAR2(100);
  lv_sql_stmt           VARCHAR2(5000);
  lv_last_asl_collection_date  DATE;

/*ASL */

   c_count NUMBER:= 0;

   BEGIN

     /*ASL */
	IF  (MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES and MSC_CL_COLLECTION.v_coll_prec.item_flag = MSC_UTIL.SYS_YES )  THEN
			lv_table_name:= 'SYSTEM_ITEMS_' || MSC_CL_COLLECTION.v_INSTANCE_CODE;
			MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, ' table name in LOAD_SUPPLIER_CAPACITY is ' || lv_table_name);
	else
			lv_table_name:= 'MSC_SYSTEM_ITEMS';
			MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, ' table name in LOAD_SUPPLIER_CAPACITY is ' || lv_table_name);
  End if;

 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, ' table name is ' || lv_table_name);

  /*ASL */

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN


  --MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ITEM_SUPPLIERS', MSC_CL_COLLECTION.v_instance_id, -1, 'AND nvl(COLLECTED_FLAG,1) <> 2');

  IF MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
    v_sub_str := 'AND nvl(COLLECTED_FLAG,1) <> 2';
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ITEM_SUPPLIERS', MSC_CL_COLLECTION.v_instance_id, -1,v_sub_str);
  ELSE
    v_sub_str :=  ' AND nvl(COLLECTED_FLAG,1) <> 2'
                ||' AND ORGANIZATION_ID'||MSC_UTIL.v_in_org_str;
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ITEM_SUPPLIERS', MSC_CL_COLLECTION.v_instance_id, -1,v_sub_str);
  END IF;

END IF;

c_count:= 0;

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh or MSC_CL_COLLECTION.v_is_legacy_refresh) THEN
	FOR c_rec IN c1 LOOP

-- Always setting VMI_REFRESH_FLAG to 1 incase of update/inserts
-- to identify records for whom the ASL has changed since the last
-- time VMI ran in CP and redo the VMI calculations.

	BEGIN

  IF MSC_CL_COLLECTION.v_is_legacy_refresh THEN

				UPDATE MSC_ITEM_SUPPLIERS
				SET
				 PROCESSING_LEAD_TIME= c_rec.PROCESSING_LEAD_TIME,
				 MINIMUM_ORDER_QUANTITY= c_rec.MINIMUM_ORDER_QUANTITY,
				 FIXED_LOT_MULTIPLIER= c_rec.FIXED_LOT_MULTIPLE,
				 DELIVERY_CALENDAR_CODE= c_rec.DELIVERY_CALENDAR_CODE,
				 SUPPLIER_CAP_OVER_UTIL_COST= c_rec.SUPPLIER_CAP_OVER_UTIL_COST,
				 PURCHASING_UNIT_OF_MEASURE= c_rec.PURCHASING_UNIT_OF_MEASURE,
				 SR_INSTANCE_ID2= c_rec.SR_INSTANCE_ID2,
				 ITEM_PRICE= c_rec.ITEM_PRICE,  -- Item Price by Supplier Fix
				 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
				 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
				  /* SCE Change Starts */
				 /* Pull Supplier Item Name, company_id and company_site_id */
				 SUPPLIER_ITEM_NAME = c_rec.SUPPLIER_ITEM_NAME,
				 PLANNER_CODE = c_rec.planner_code,
				 VMI_FLAG = c_rec.vmi_flag,
				 MIN_MINMAX_QUANTITY = c_rec.min_minmax_quantity,
				 MAX_MINMAX_QUANTITY = c_rec.max_minmax_quantity,
				 MAXIMUM_ORDER_QUANTITY = c_rec.maximum_order_quantity,
				 UOM_CODE = c_rec.UOM_CODE,
				 -- VMI_UOM_CODE = c_rec.VMI_UOM_CODE,
				 /* SCE change ends */
				 --VMI_UNIT_OF_MEASURE = c_rec.VMI_UNIT_OF_MEASURE,
				 VMI_REPLENISHMENT_APPROVAL = c_rec.VMI_REPLENISHMENT_APPROVAL,
				 ENABLE_VMI_AUTO_REPLENISH_FLAG =c_rec.ENABLE_VMI_AUTO_REPLENISH_FLAG,
				 REPLENISHMENT_METHOD = c_rec.REPLENISHMENT_METHOD,
				 MIN_MINMAX_DAYS = c_rec.MIN_MINMAX_DAYS,
				 MAX_MINMAX_DAYS = c_rec.MAX_MINMAX_DAYS,
				 FORECAST_HORIZON = c_rec.FORECAST_HORIZON,
				 FIXED_ORDER_QUANTITY = c_rec.FIXED_ORDER_QUANTITY,
				 VMI_REFRESH_FLAG=1,
				 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
				WHERE PLAN_ID= -1
				  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
				  AND INVENTORY_ITEM_ID= c_rec.INVENTORY_ITEM_ID
				  AND ORGANIZATION_ID= c_rec.ORGANIZATION_ID
				  AND USING_ORGANIZATION_ID= c_rec.USING_ORGANIZATION_ID
				  AND SUPPLIER_ID= c_rec.SUPPLIER_ID
				  AND NVL(SUPPLIER_SITE_ID,MSC_UTIL.NULL_VALUE)=
				          NVL(c_rec.SUPPLIER_SITE_ID,MSC_UTIL.NULL_VALUE);

			END IF;

		IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

			INSERT INTO MSC_ITEM_SUPPLIERS
			( PLAN_ID,
			  ORGANIZATION_ID,
			  USING_ORGANIZATION_ID,
			  SUPPLIER_ID,
			  SUPPLIER_SITE_ID,
			  INVENTORY_ITEM_ID,
			  PROCESSING_LEAD_TIME,
			  MINIMUM_ORDER_QUANTITY,
			  FIXED_LOT_MULTIPLIER,
			  DELIVERY_CALENDAR_CODE,
			  SUPPLIER_CAP_OVER_UTIL_COST,
			  PURCHASING_UNIT_OF_MEASURE,
			  SR_INSTANCE_ID2,
			  ITEM_PRICE,  -- Item Price by Supplier Fix
			  SR_INSTANCE_ID,
			  REFRESH_NUMBER,
			  LAST_UPDATE_DATE,
			  LAST_UPDATED_BY,
			  CREATION_DATE,
			  /* SCE Change Starts */
			  SUPPLIER_ITEM_NAME,
			  PLANNER_CODE,
			  VMI_FLAG ,
			  MIN_MINMAX_QUANTITY,
			  MAX_MINMAX_QUANTITY,
			  MAXIMUM_ORDER_QUANTITY,
			  UOM_CODE,
			  -- VMI_UOM_CODE,
			  /* SCE Change Ends */
			  --VMI_UNIT_OF_MEASURE,
			  VMI_REPLENISHMENT_APPROVAL,
			  ENABLE_VMI_AUTO_REPLENISH_FLAG,
			  REPLENISHMENT_METHOD,
			  MIN_MINMAX_DAYS,
			  MAX_MINMAX_DAYS,
			  FORECAST_HORIZON,
			  FIXED_ORDER_QUANTITY,
			  VMI_REFRESH_FLAG,
			  CREATED_BY)
			VALUES
			( -1,
			  c_rec.ORGANIZATION_ID,
			  c_rec.USING_ORGANIZATION_ID,
			  c_rec.SUPPLIER_ID,
			  c_rec.SUPPLIER_SITE_ID,
			  c_rec.INVENTORY_ITEM_ID,
			  c_rec.PROCESSING_LEAD_TIME,
			  c_rec.MINIMUM_ORDER_QUANTITY,
			  c_rec.FIXED_LOT_MULTIPLE,
			  c_rec.DELIVERY_CALENDAR_CODE,
			  c_rec.SUPPLIER_CAP_OVER_UTIL_COST,
			  c_rec.PURCHASING_UNIT_OF_MEASURE,
			  c_rec.SR_INSTANCE_ID2,
			  c_rec.ITEM_PRICE,  -- Item Price by Supplier Fix
			  c_rec.SR_INSTANCE_ID,
			  MSC_CL_COLLECTION.v_last_collection_id,
			  MSC_CL_COLLECTION.v_current_date,
			  MSC_CL_COLLECTION.v_current_user,
			  MSC_CL_COLLECTION.v_current_date,
			  /* SCE Change Starts */
			  c_rec.SUPPLIER_ITEM_NAME,
			  c_rec.planner_code,
			  c_rec.vmi_flag,
			  c_rec.min_minmax_quantity,
			  c_rec.max_minmax_quantity,
			  c_rec.maximum_order_quantity,
			  c_rec.UOM_CODE,
			  -- c_rec.VMI_UOM_CODE,
			  /* SCE Change Ends */
			  -- c_rec.VMI_UNIT_OF_MEASURE,
			  c_rec.VMI_REPLENISHMENT_APPROVAL,
			  c_rec.ENABLE_VMI_AUTO_REPLENISH_FLAG,
			  c_rec.REPLENISHMENT_METHOD,
			  c_rec.MIN_MINMAX_DAYS,
			  c_rec.MAX_MINMAX_DAYS,
			  c_rec.FORECAST_HORIZON,
			  c_rec.FIXED_ORDER_QUANTITY,
			  1,
			  MSC_CL_COLLECTION.v_current_user );

			END IF;

  c_count:= c_count+1;

  IF c_count> MSC_CL_COLLECTION.PBS THEN
     COMMIT;
     c_count:= 0;
  END IF;

EXCEPTION

   WHEN DUP_VAL_ON_INDEX THEN

        NULL;

   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SUPPLIER_CAPACITY');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ITEM_SUPPLIERS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SUPPLIER_CAPACITY');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ITEM_SUPPLIERS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ITEM_NAME');
      FND_MESSAGE.SET_TOKEN('VALUE', ITEM_NAME( c_rec.INVENTORY_ITEM_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
      FND_MESSAGE.SET_TOKEN('VALUE',
                            MSC_GET_NAME.ORG_CODE( c_rec.ORGANIZATION_ID,
                                                   MSC_CL_COLLECTION.v_instance_id));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'SUPPLIER_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.SUPPLIER_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'SUPPLIER_SITE_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.SUPPLIER_SITE_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

		END;

		END LOOP;

		COMMIT;
END IF ;

/* ASL */
IF (MSC_CL_COLLECTION.v_is_incremental_refresh and not MSC_CL_COLLECTION.v_is_legacy_refresh) THEN

  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'INCREMENTAL ASL CODE START ');
  /*NOT REQUIRED
  IF (MSC_CL_COLLECTION.v_coll_prec.app_supp_cap_flag=MSC_UTIL.SYS_YES AND MSC_CL_COLLECTION.v_coll_prec.item_flag=MSC_UTIL.SYS_YES AND NOT MSC_CL_COLLECTION.v_is_legacy_refresh) THEN
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'ADD_NEW_IMPL_ITEM_ASL PROCEDURE BEING CALLED FROM LOAD_SUPPLIER_CAPACITY PROCEDURE ');
		ADD_NEW_IMPL_ITEM_ASL;
 END IF ;
 */

  lv_sql_stmt := 'Select min (nvl(LAST_SUCC_ASL_REF_TIME,SYSDATE-365000))'
   						  ||'  From msc_instance_orgs '
   							||'  Where sr_instance_id = ' || MSC_CL_COLLECTION.v_instance_id
  							||'  And   organization_id '|| MSC_UTIL.v_in_org_str;

  EXECUTE IMMEDIATE lv_sql_stmt  into lv_last_asl_collection_date;
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'last successful ASL Collection refresh time is '||lv_last_asl_collection_date);
  c_count:= 0;
	FOR del_rec in del_asl LOOP
  	 BEGIN
		   lv_sql_stmt:= 'Delete  MSC_ITEM_SUPPLIERS mis'
		        ||' WHERE mis.inventory_item_id =' ||  del_rec.inventory_item_id
		        ||' AND mis.USING_ORGANIZATION_ID=' || del_rec.USING_ORGANIZATION_ID
		  	    ||' AND   mis.SUPPLIER_ID = ' || del_rec.SUPPLIER_ID
						||' AND nvl(mis.SUPPLIER_SITE_ID, -1) = nvl( :SUPPLIER_SITE_ID , -1)'
		        ||' AND mis.sr_instance_id = ' ||  MSC_CL_COLLECTION.v_instance_id
		        ||' AND mis.plan_id  = -1  '
		        ||' AND mis.ORGANIZATION_ID  ' ||  MSC_UTIL.v_in_org_str;

		 		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'delete query is ' || lv_sql_stmt);

		 		EXECUTE IMMEDIATE  lv_sql_stmt  using del_rec.SUPPLIER_SITE_ID;

		 		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'the number of rows deleted '|| SQL%ROWCOUNT);
 			EXCEPTION
 		   WHEN OTHERS THEN

		    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SUPPLIER_CAPACITY');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ITEM_SUPPLIERS');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		      RAISE;

		    ELSE
		      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SUPPLIER_CAPACITY');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ITEM_SUPPLIERS');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'ITEM_NAME');
		      FND_MESSAGE.SET_TOKEN('VALUE', ITEM_NAME( del_rec.INVENTORY_ITEM_ID));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'SUPPLIER_ID');
		      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(del_rec.SUPPLIER_ID));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'SUPPLIER_SITE_ID');
		      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(del_rec.SUPPLIER_SITE_ID));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		   END IF ;
		 END ;

	END LOOP;
	MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,  'number of row deleted ' || c_count);
  COMMIT;

  /*Insert Logic */
   FOR c_rec in c4  LOOP
    	BEGIN
				UPDATE MSC_ITEM_SUPPLIERS
				 SET
				 PROCESSING_LEAD_TIME= c_rec.PROCESSING_LEAD_TIME,
				 MINIMUM_ORDER_QUANTITY= c_rec.MINIMUM_ORDER_QUANTITY,
				 FIXED_LOT_MULTIPLIER= c_rec.FIXED_LOT_MULTIPLE,
				 DELIVERY_CALENDAR_CODE= c_rec.DELIVERY_CALENDAR_CODE,
				 SUPPLIER_CAP_OVER_UTIL_COST= c_rec.SUPPLIER_CAP_OVER_UTIL_COST,
				 PURCHASING_UNIT_OF_MEASURE= c_rec.PURCHASING_UNIT_OF_MEASURE,
				 SR_INSTANCE_ID2= c_rec.SR_INSTANCE_ID2,
				 ITEM_PRICE= c_rec.ITEM_PRICE,  -- Item Price by Supplier Fix
				 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
				 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
				  /* SCE Change Starts */
				 /* Pull Supplier Item Name, company_id and company_site_id */
				 SUPPLIER_ITEM_NAME = c_rec.SUPPLIER_ITEM_NAME,
				 PLANNER_CODE = c_rec.planner_code,
				 VMI_FLAG = c_rec.vmi_flag,
				 MIN_MINMAX_QUANTITY = c_rec.min_minmax_quantity,
				 MAX_MINMAX_QUANTITY = c_rec.max_minmax_quantity,
				 MAXIMUM_ORDER_QUANTITY = c_rec.maximum_order_quantity,
				 UOM_CODE = c_rec.UOM_CODE,
				 -- VMI_UOM_CODE = c_rec.VMI_UOM_CODE,
				 /* SCE change ends */
				 --VMI_UNIT_OF_MEASURE = c_rec.VMI_UNIT_OF_MEASURE,
				 VMI_REPLENISHMENT_APPROVAL = c_rec.VMI_REPLENISHMENT_APPROVAL,
				 ENABLE_VMI_AUTO_REPLENISH_FLAG =c_rec.ENABLE_VMI_AUTO_REPLENISH_FLAG,
				 REPLENISHMENT_METHOD = c_rec.REPLENISHMENT_METHOD,
				 MIN_MINMAX_DAYS = c_rec.MIN_MINMAX_DAYS,
				 MAX_MINMAX_DAYS = c_rec.MAX_MINMAX_DAYS,
				 FORECAST_HORIZON = c_rec.FORECAST_HORIZON,
				 FIXED_ORDER_QUANTITY = c_rec.FIXED_ORDER_QUANTITY,
				 VMI_REFRESH_FLAG=1,
				 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
				WHERE PLAN_ID= -1
				  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
				  AND INVENTORY_ITEM_ID= c_rec.INVENTORY_ITEM_ID
				  AND USING_ORGANIZATION_ID= c_rec.USING_ORGANIZATION_ID
				  AND SUPPLIER_ID= c_rec.SUPPLIER_ID
				  AND NVL(SUPPLIER_SITE_ID,MSC_UTIL.NULL_VALUE)=
				          NVL(c_rec.SUPPLIER_SITE_ID,MSC_UTIL.NULL_VALUE);

				   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'ROW UPDATED ' || SQL%ROWCOUNT);

				 IF SQL%NOTFOUND THEN
				     IF c_rec.using_organization_id =-1 THEN
				     		lv_sql_stmt:= 'INSERT INTO MSC_ITEM_SUPPLIERS'
								|| ' ( PLAN_ID, '
								||'  ORGANIZATION_ID, '
								||'  USING_ORGANIZATION_ID,'
								||'  SUPPLIER_ID, '
								||'  SUPPLIER_SITE_ID,'
								||'  INVENTORY_ITEM_ID,'
								||'  PROCESSING_LEAD_TIME,'
								||'  MINIMUM_ORDER_QUANTITY,'
								||'  FIXED_LOT_MULTIPLIER,'
								||'  DELIVERY_CALENDAR_CODE,'
								||'  SUPPLIER_CAP_OVER_UTIL_COST,'
								||'  PURCHASING_UNIT_OF_MEASURE,'
								||'  SR_INSTANCE_ID2,'
								||'  ITEM_PRICE,'  -- Item Price by Supplier Fix
								||'  SR_INSTANCE_ID,'
								||'  REFRESH_NUMBER,'
								||'  LAST_UPDATE_DATE,'
								||'  LAST_UPDATED_BY,'
								||'  CREATION_DATE,'
								 /* SCE Change Starts */
								||'  SUPPLIER_ITEM_NAME,'
								||'  PLANNER_CODE,'
								||'  VMI_FLAG ,'
								||'  MIN_MINMAX_QUANTITY,'
								||'  MAX_MINMAX_QUANTITY,'
								||'  MAXIMUM_ORDER_QUANTITY,'
								||'  UOM_CODE,'
								  -- VMI_UOM_CODE,
								  /* SCE Change Ends */
								  --VMI_UNIT_OF_MEASURE,'
								||'  VMI_REPLENISHMENT_APPROVAL,'
								||'  ENABLE_VMI_AUTO_REPLENISH_FLAG,'
								||' REPLENISHMENT_METHOD,'
								||'  MIN_MINMAX_DAYS,'
								||'  MAX_MINMAX_DAYS,'
								||'  FORECAST_HORIZON,'
								||'  FIXED_ORDER_QUANTITY,'
								||'  VMI_REFRESH_FLAG,'
								||'  CREATED_BY)'
								||'select'
								||' -1,'
								||'  msi.ORGANIZATION_ID,'
								||'  :USING_ORGANIZATION_ID,'
								||'  :SUPPLIER_ID,'
								||'  :SUPPLIER_SITE_ID,'
								||'  :INVENTORY_ITEM_ID,'
								||'  :PROCESSING_LEAD_TIME,'
								||'  :MINIMUM_ORDER_QUANTITY,'
								||'  :FIXED_LOT_MULTIPLE,'
								||'  :DELIVERY_CALENDAR_CODE,'
								||'  :SUPPLIER_CAP_OVER_UTIL_COST,'
								||'  :PURCHASING_UNIT_OF_MEASURE,'
								||'  :SR_INSTANCE_ID2,'
								||'  :ITEM_PRICE,'
								||'  :SR_INSTANCE_ID,'
								||'  :v_last_collection_id,'
								||'  :v_current_date,'
								||'  :v_current_user,'
								||'  :v_current_date,'
								||'  :SUPPLIER_ITEM_NAME,'
								||'  :planner_code,'
								||'  :vmi_flag,'
								||'  :min_minmax_quantity,'
								||'  :max_minmax_quantity,'
								||'  :maximum_order_quantity,'
								||'  :UOM_CODE,'
								||'  :VMI_REPLENISHMENT_APPROVAL,'
								||'  :ENABLE_VMI_AUTO_REPLENISH_FLAG,'
								||'  :REPLENISHMENT_METHOD,'
								||'  :MIN_MINMAX_DAYS,'
								||'  :MAX_MINMAX_DAYS,'
								||'  :FORECAST_HORIZON,'
								||'  :FIXED_ORDER_QUANTITY,'
								||'  1,'
								||'  :v_current_user '
								||'  FROM '
								|| lv_table_name ||'  msi '
								||'  WHERE msi.inventory_item_id = '|| c_rec.INVENTORY_ITEM_ID
								||'  and msi.organization_id ' ||  MSC_UTIL.v_in_org_str
								||'  and msi.sr_instance_id = '||  MSC_CL_COLLECTION.v_instance_id
								||'  and msi.plan_id =-1 ' ;

							MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'the insert statement is ' || lv_sql_stmt );

								execute immediate  lv_sql_stmt using   c_rec.USING_ORGANIZATION_ID,
								  c_rec.SUPPLIER_ID,
								  c_rec.SUPPLIER_SITE_ID,
								  c_rec.INVENTORY_ITEM_ID,
								  c_rec.PROCESSING_LEAD_TIME,
								  c_rec.MINIMUM_ORDER_QUANTITY,
								  c_rec.FIXED_LOT_MULTIPLE,
								  c_rec.DELIVERY_CALENDAR_CODE,
								  c_rec.SUPPLIER_CAP_OVER_UTIL_COST,
								  c_rec.PURCHASING_UNIT_OF_MEASURE,
								  c_rec.SR_INSTANCE_ID2,
								  c_rec.ITEM_PRICE,
								  c_rec.SR_INSTANCE_ID,
								  MSC_CL_COLLECTION.v_last_collection_id,
								  MSC_CL_COLLECTION.v_current_date,
								  MSC_CL_COLLECTION.v_current_user,
								  MSC_CL_COLLECTION.v_current_date,
								  c_rec.SUPPLIER_ITEM_NAME,
								  c_rec.planner_code,
								  c_rec.vmi_flag,
								  c_rec.min_minmax_quantity,
								  c_rec.max_minmax_quantity,
								  c_rec.maximum_order_quantity,
								  c_rec.UOM_CODE,
								  c_rec.VMI_REPLENISHMENT_APPROVAL,
								  c_rec.ENABLE_VMI_AUTO_REPLENISH_FLAG,
								  c_rec.REPLENISHMENT_METHOD,
								  c_rec.MIN_MINMAX_DAYS,
								 c_rec.MAX_MINMAX_DAYS,
								  c_rec.FORECAST_HORIZON,
								  c_rec.FIXED_ORDER_QUANTITY,
								   MSC_CL_COLLECTION.v_current_user ;

							  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'ROW INSERTED WITH USING ORG -1  ' || SQL%ROWCOUNT);

	               ELSE
				         INSERT INTO MSC_ITEM_SUPPLIERS
									( PLAN_ID,
									  ORGANIZATION_ID,
									  USING_ORGANIZATION_ID,
									  SUPPLIER_ID,
									  SUPPLIER_SITE_ID,
									  INVENTORY_ITEM_ID,
									  PROCESSING_LEAD_TIME,
									  MINIMUM_ORDER_QUANTITY,
									  FIXED_LOT_MULTIPLIER,
									  DELIVERY_CALENDAR_CODE,
									  SUPPLIER_CAP_OVER_UTIL_COST,
									  PURCHASING_UNIT_OF_MEASURE,
									  SR_INSTANCE_ID2,
									  ITEM_PRICE,  -- Item Price by Supplier Fix
									  SR_INSTANCE_ID,
									  REFRESH_NUMBER,
									  LAST_UPDATE_DATE,
									  LAST_UPDATED_BY,
									  CREATION_DATE,
									  /* SCE Change Starts */
									  SUPPLIER_ITEM_NAME,
									  PLANNER_CODE,
									  VMI_FLAG ,
									  MIN_MINMAX_QUANTITY,
									  MAX_MINMAX_QUANTITY,
									  MAXIMUM_ORDER_QUANTITY,
									  UOM_CODE,
									  -- VMI_UOM_CODE,
									  /* SCE Change Ends */
									  --VMI_UNIT_OF_MEASURE,
									  VMI_REPLENISHMENT_APPROVAL,
									  ENABLE_VMI_AUTO_REPLENISH_FLAG,
									  REPLENISHMENT_METHOD,
									  MIN_MINMAX_DAYS,
									  MAX_MINMAX_DAYS,
									  FORECAST_HORIZON,
									  FIXED_ORDER_QUANTITY,
									  VMI_REFRESH_FLAG,
									  CREATED_BY)
									VALUES
									( -1,
									  c_rec.USING_ORGANIZATION_ID,
									  c_rec.USING_ORGANIZATION_ID,
									  c_rec.SUPPLIER_ID,
									  c_rec.SUPPLIER_SITE_ID,
									  c_rec.INVENTORY_ITEM_ID,
									  c_rec.PROCESSING_LEAD_TIME,
									  c_rec.MINIMUM_ORDER_QUANTITY,
									  c_rec.FIXED_LOT_MULTIPLE,
									  c_rec.DELIVERY_CALENDAR_CODE,
									  c_rec.SUPPLIER_CAP_OVER_UTIL_COST,
									  c_rec.PURCHASING_UNIT_OF_MEASURE,
									  c_rec.SR_INSTANCE_ID2,
									  c_rec.ITEM_PRICE,  -- Item Price by Supplier Fix
									  c_rec.SR_INSTANCE_ID,
									  MSC_CL_COLLECTION.v_last_collection_id,
									  MSC_CL_COLLECTION.v_current_date,
									  MSC_CL_COLLECTION.v_current_user,
									  MSC_CL_COLLECTION.v_current_date,
									  /* SCE Change Starts */
									  c_rec.SUPPLIER_ITEM_NAME,
									  c_rec.planner_code,
									  c_rec.vmi_flag,
									  c_rec.min_minmax_quantity,
									  c_rec.max_minmax_quantity,
									  c_rec.maximum_order_quantity,
									  c_rec.UOM_CODE,
									  -- c_rec.VMI_UOM_CODE,
									  /* SCE Change Ends */
									  -- c_rec.VMI_UNIT_OF_MEASURE,
									  c_rec.VMI_REPLENISHMENT_APPROVAL,
									  c_rec.ENABLE_VMI_AUTO_REPLENISH_FLAG,
									  c_rec.REPLENISHMENT_METHOD,
									  c_rec.MIN_MINMAX_DAYS,
									  c_rec.MAX_MINMAX_DAYS,
									  c_rec.FORECAST_HORIZON,
									  c_rec.FIXED_ORDER_QUANTITY,
									  1,
									  MSC_CL_COLLECTION.v_current_user );

									 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'ROW INSERTED WITH USING org id not -1   ' || SQL%ROWCOUNT);

				     END IF ;
				  END IF ;

				MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, ' the item id ' || c_rec.INVENTORY_ITEM_ID);
				MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, ' the using organization_id is  ' || c_rec.USING_ORGANIZATION_ID);
				MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, ' the supplier id  is  ' || c_rec.SUPPLIER_ID);
				MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, ' the supplier site id  is  ' || c_rec.SUPPLIER_SITE_ID);

  EXCEPTION
   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SUPPLIER_CAPACITY');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ITEM_SUPPLIERS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE

      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SUPPLIER_CAPACITY');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ITEM_SUPPLIERS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;-- exception end
   END ;	 -- begin end
 END LOOP;	 	  -- loop insert or update
COMMIT ;

 END IF ; -- v_is_incremental

/*ASL */

IF MSC_CL_COLLECTION.v_apps_ver <> MSC_UTIL.G_APPS107 AND
   MSC_CL_COLLECTION.v_apps_ver <> MSC_UTIL.G_APPS110 THEN

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

--MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SUPPLIER_CAPACITIES', MSC_CL_COLLECTION.v_instance_id, -1);

  IF MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
  if  MSC_CL_COLLECTION.v_coll_prec.app_supp_cap_flag= MSC_UTIL.ASL_YES_RETAIN_CP THEN
    v_sub_str :=' AND COLLECTED_FLAG <> 3';
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SUPPLIER_CAPACITIES', MSC_CL_COLLECTION.v_instance_id, -1,v_sub_str);
    else
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SUPPLIER_CAPACITIES', MSC_CL_COLLECTION.v_instance_id, -1);
  end if ;
  ELSE
   if  MSC_CL_COLLECTION.v_coll_prec.app_supp_cap_flag= MSC_UTIL.ASL_YES_RETAIN_CP THEN
    v_sub_str :=' AND COLLECTED_FLAG <> 3 AND ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SUPPLIER_CAPACITIES', MSC_CL_COLLECTION.v_instance_id, -1,v_sub_str);
    else
    v_sub_str :=' AND ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SUPPLIER_CAPACITIES', MSC_CL_COLLECTION.v_instance_id, -1,v_sub_str);
   end if ;
  END IF;

END IF;

--============ Incremental Refresh for DELETE =========

IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

FOR c_rec IN c2d LOOP

UPDATE MSC_SUPPLIER_CAPACITIES
SET
 USING_ORGANIZATION_ID= c_rec.USING_ORGANIZATION_ID,
 CAPACITY= NULL,
 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE PLAN_ID= -1
  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
  AND INVENTORY_ITEM_ID= c_rec.INVENTORY_ITEM_ID
  AND ORGANIZATION_ID= c_rec.ORGANIZATION_ID
  AND SUPPLIER_ID= c_rec.SUPPLIER_ID
  AND NVL(SUPPLIER_SITE_ID,MSC_UTIL.NULL_VALUE)=
          NVL(c_rec.SUPPLIER_SITE_ID,MSC_UTIL.NULL_VALUE)
  AND FROM_DATE= c_rec.FROM_DATE
  AND COLLECTED_FLAG=1;

END LOOP;

FOR c_rec IN c5d LOOP

DELETE FROM MSC_SUPPLIER_CAPACITIES
WHERE PLAN_ID= -1
  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
  AND INVENTORY_ITEM_ID= c_rec.INVENTORY_ITEM_ID
  AND ORGANIZATION_ID= c_rec.ORGANIZATION_ID
  AND SUPPLIER_ID= c_rec.SUPPLIER_ID
  AND NVL(SUPPLIER_SITE_ID,MSC_UTIL.NULL_VALUE)=
          NVL(c_rec.SUPPLIER_SITE_ID,MSC_UTIL.NULL_VALUE)
  AND COLLECTED_FLAG=3;

END LOOP;


END IF;

COMMIT;

c_count:= 0;

FOR c_rec IN c2 LOOP

BEGIN

IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

UPDATE MSC_SUPPLIER_CAPACITIES
SET
 USING_ORGANIZATION_ID= c_rec.USING_ORGANIZATION_ID,
 TO_DATE= c_rec.TO_DATE,
 CAPACITY= c_rec.CAPACITY,
 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE PLAN_ID= -1
  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
  AND INVENTORY_ITEM_ID= c_rec.INVENTORY_ITEM_ID
  AND ORGANIZATION_ID= c_rec.ORGANIZATION_ID
  AND SUPPLIER_ID= c_rec.SUPPLIER_ID
  AND NVL(SUPPLIER_SITE_ID,MSC_UTIL.NULL_VALUE)=
            NVL(c_rec.SUPPLIER_SITE_ID,MSC_UTIL.NULL_VALUE)
  AND FROM_DATE= c_rec.FROM_DATE
  AND COLLECTED_FLAG=1;

END IF;

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

INSERT INTO MSC_SUPPLIER_CAPACITIES
( TRANSACTION_ID,
  PLAN_ID,
  ORGANIZATION_ID,
  USING_ORGANIZATION_ID,
  SUPPLIER_ID,
  SUPPLIER_SITE_ID,
  INVENTORY_ITEM_ID,
  FROM_DATE,
  TO_DATE,
  CAPACITY,
  SR_INSTANCE_ID,
  COLLECTED_FLAG,
  REFRESH_NUMBER,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
( MSC_SUPPLIER_CAPACITIES_S.NEXTVAL,
  -1,
  c_rec.ORGANIZATION_ID,
  c_rec.USING_ORGANIZATION_ID,
  c_rec.SUPPLIER_ID,
  c_rec.SUPPLIER_SITE_ID,
  c_rec.INVENTORY_ITEM_ID,
  c_rec.FROM_DATE,
  c_rec.TO_DATE,
  c_rec.CAPACITY,
  c_rec.SR_INSTANCE_ID,
  1,
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
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SUPPLIER_CAPACITY');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SUPPLIER_CAPACITIES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SUPPLIER_CAPACITY');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SUPPLIER_CAPACITIES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ITEM_NAME');
      FND_MESSAGE.SET_TOKEN('VALUE', ITEM_NAME( c_rec.INVENTORY_ITEM_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
      FND_MESSAGE.SET_TOKEN('VALUE',
                            MSC_GET_NAME.ORG_CODE( c_rec.ORGANIZATION_ID,
                                                   MSC_CL_COLLECTION.v_instance_id));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'SUPPLIER_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.SUPPLIER_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'SUPPLIER_SITE_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.SUPPLIER_SITE_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'FROM_DATE');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.FROM_DATE));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;

COMMIT;

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

--MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SUPPLIER_FLEX_FENCES', MSC_CL_COLLECTION.v_instance_id, -1);

  IF MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SUPPLIER_FLEX_FENCES', MSC_CL_COLLECTION.v_instance_id, -1);
  ELSE
    v_sub_str :=' AND ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SUPPLIER_FLEX_FENCES', MSC_CL_COLLECTION.v_instance_id, -1,v_sub_str);
  END IF;

END IF;

c_count:= 0;

FOR c_rec IN c3 LOOP

BEGIN

IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

UPDATE MSC_SUPPLIER_FLEX_FENCES
SET
 USING_ORGANIZATION_ID= c_rec.USING_ORGANIZATION_ID,
 TOLERANCE_PERCENTAGE= c_rec.TOLERANCE_PERCENTAGE,
 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE PLAN_ID= -1
  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
  AND INVENTORY_ITEM_ID= c_rec.INVENTORY_ITEM_ID
  AND ORGANIZATION_ID= c_rec.ORGANIZATION_ID
  AND SUPPLIER_ID= c_rec.SUPPLIER_ID
  AND NVL(SUPPLIER_SITE_ID,MSC_UTIL.NULL_VALUE)=
               NVL(c_rec.SUPPLIER_SITE_ID,MSC_UTIL.NULL_VALUE)
  AND FENCE_DAYS= c_rec.FENCE_DAYS;

END IF;

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

INSERT INTO MSC_SUPPLIER_FLEX_FENCES
( TRANSACTION_ID,
  PLAN_ID,
  SUPPLIER_ID,
  SUPPLIER_SITE_ID,
  ORGANIZATION_ID,
  USING_ORGANIZATION_ID,
  INVENTORY_ITEM_ID,
  FENCE_DAYS,
  TOLERANCE_PERCENTAGE,
  SR_INSTANCE_ID,
  REFRESH_NUMBER,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY)
VALUES
( MSC_SUPPLIER_FLEX_FENCES_S.NEXTVAL,
  -1,
  c_rec.SUPPLIER_ID,
  c_rec.SUPPLIER_SITE_ID,
  c_rec.ORGANIZATION_ID,
  c_rec.USING_ORGANIZATION_ID,
  c_rec.INVENTORY_ITEM_ID,
  c_rec.FENCE_DAYS,
  c_rec.TOLERANCE_PERCENTAGE,
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
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SUPPLIER_CAPACITY');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SUPPLIER_FLEX_FENCES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SUPPLIER_CAPACITY');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SUPPLIER_FLEX_FENCES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ITEM_NAME');
      FND_MESSAGE.SET_TOKEN('VALUE', ITEM_NAME( c_rec.INVENTORY_ITEM_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
      FND_MESSAGE.SET_TOKEN('VALUE',
                            MSC_GET_NAME.ORG_CODE( c_rec.ORGANIZATION_ID,
                                                   MSC_CL_COLLECTION.v_instance_id));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'SUPPLIER_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.SUPPLIER_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'SUPPLIER_SITE_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.SUPPLIER_SITE_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'FENCE_DAYS');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.FENCE_DAYS));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;

COMMIT;

END IF;   -- MSC_CL_COLLECTION.v_apps_ver

   END LOAD_SUPPLIER_CAPACITY;

--==================================================================
--==================================================================

   PROCEDURE LOAD_ITEM IS

   CURSOR c1 IS
SELECT
  msi.ORGANIZATION_ID,
  t1.INVENTORY_ITEM_ID,                    -- msi.INVENTORY_ITEM_ID,
  msi.ITEM_NAME,
  msi.LOTS_EXPIRATION,
  msi.LOT_CONTROL_CODE,
  msi.SHRINKAGE_RATE,
  msi.FIXED_DAYS_SUPPLY,
  msi.FIXED_ORDER_QUANTITY,
  msi.FIXED_LOT_MULTIPLIER,
  msi.MINIMUM_ORDER_QUANTITY,
  msi.MAXIMUM_ORDER_QUANTITY,
  msi.ROUNDING_CONTROL_TYPE,
  msi.PLANNING_TIME_FENCE_CODE,
  msi.PLANNING_TIME_FENCE_DAYS,
  msi.DEMAND_TIME_FENCE_DAYS,
  replace(substrb(msi.DESCRIPTION,1,240),v_chr9,' ') DESCRIPTION,
  msi.RELEASE_TIME_FENCE_CODE,
  msi.RELEASE_TIME_FENCE_DAYS,
  msi.IN_SOURCE_PLAN,
  msi.REVISION,
  msi.SR_CATEGORY_ID,
  msi.CATEGORY_NAME,
  msi.ABC_CLASS_ID,
  msi.ABC_CLASS_NAME,
  msi.MRP_PLANNING_CODE,
  msi.FIXED_LEAD_TIME,
  msi.VARIABLE_LEAD_TIME,
  msi.PREPROCESSING_LEAD_TIME,
  msi.POSTPROCESSING_LEAD_TIME,
  msi.FULL_LEAD_TIME,
  msi.CUMULATIVE_TOTAL_LEAD_TIME,
  msi.CUM_MANUFACTURING_LEAD_TIME,
  msi.UOM_CODE,
  msi.UNIT_WEIGHT,
  msi.UNIT_VOLUME,
  msi.WEIGHT_UOM,
  msi.VOLUME_UOM,
  t3.Inventory_Item_ID PRODUCT_FAMILY_ID,
  msi.ATP_RULE_ID,
  msi.ATP_COMPONENTS_FLAG,
  msi.BUILT_IN_WIP_FLAG,
  msi.PURCHASING_ENABLED_FLAG,
  msi.PLANNING_MAKE_BUY_CODE,
  msi.REPETITIVE_TYPE,
  msi.REPETITIVE_VARIANCE_DAYS,
  msi.STANDARD_COST,
  msi.CARRYING_COST,
  msi.ORDER_COST,
  nvl(msi.DMD_LATENESS_COST, mtp.DEMAND_LATENESS_COST),
  msi.SS_PENALTY_COST,
  msi.SUPPLIER_CAP_OVERUTIL_COST,
  nvl(msi.LIST_PRICE,msi.STANDARD_COST)  LIST_PRICE,
  msi.AVERAGE_DISCOUNT,
  msi.ENGINEERING_ITEM_FLAG,
  msi.INVENTORY_ITEM_FLAG,
  msi.WIP_SUPPLY_TYPE,
  msi.MRP_SAFETY_STOCK_CODE,
  msi.MRP_SAFETY_STOCK_PERCENT,
  msi.SAFETY_STOCK_BUCKET_DAYS,
--  msi.INVENTORY_USE_UP_DATE,
  msi.BUYER_NAME,
  msi.PLANNER_CODE,
  msi.PLANNING_EXCEPTION_SET,
  msi.EXCESS_QUANTITY,
  msi.SHORTAGE_TYPE,
  msi.EXCEPTION_SHORTAGE_DAYS,
  msi.EXCESS_TYPE,
  msi.EXCEPTION_EXCESS_DAYS,
  msi.EXCEPTION_OVERPROMISED_DAYS,
--  msi.EXCEPTION_CODE,
  msi.BOM_ITEM_TYPE,
  msi.ATO_FORECAST_CONTROL,
  msi.EFFECTIVITY_CONTROL,
  msi.ORGANIZATION_CODE,
  msi.ACCEPTABLE_RATE_INCREASE,
  msi.ACCEPTABLE_RATE_DECREASE,
  msi.INVENTORY_PLANNING_CODE,
  msi.ACCEPTABLE_EARLY_DELIVERY,
  msi.MRP_CALCULATE_ATP_FLAG,
  msi.END_ASSEMBLY_PEGGING_FLAG,
  t2.INVENTORY_ITEM_ID BASE_ITEM_ID,     -- msi.BASE_ITEM_ID,
  msi.PRIMARY_SUPPLIER_ID,
/* ATP SUMMARY CHANGES
If the ATP_FLAG is 'C' - this means that this record has been updated and the ATP_FLAG
has been changed from 'N' to 'Y' OR This is a new record and the ATP_FLAG for this item is 'Y'.
We will flag this kind of change by putting a 'Y' in
the column new_atp_flag. This (complimentary with the refresh number)
will be being used for ATP Team so that the ATP Code can identify
such records  after a net change collections and calculate the ATP summary for these items.
*/
  decode(msi.ATP_FLAG,'C', 'Y', msi.ATP_FLAG) ATP_FLAG ,
  decode(msi.ATP_FLAG,'C', 'Y', 'N') NEW_ATP_FLAG ,
  msi.REVISION_QTY_CONTROL_CODE,
  msi.EXPENSE_ACCOUNT,
  msi.INVENTORY_ASSET_FLAG,
  msi.BUYER_ID,
  msi.SOURCE_ORG_ID,
  msi.MATERIAL_COST,
  msi.RESOURCE_COST,
  msi.SR_INVENTORY_ITEM_ID,
  msi.DELETED_FLAG,
  msi.SR_INSTANCE_ID,
  msi.replenish_to_order_flag,
  msi.pick_components_flag,
  msi.pip_flag,
  msi.REDUCE_MPS,
  msi.CRITICAL_COMPONENT_FLAG,
  msi.VMI_MINIMUM_UNITS,
  msi.VMI_MINIMUM_DAYS,
  msi.VMI_MAXIMUM_UNITS,
  msi.VMI_MAXIMUM_DAYS,
  msi.VMI_FIXED_ORDER_QUANTITY,
  msi.SO_AUTHORIZATION_FLAG,
  msi.CONSIGNED_FLAG,
  msi.ASN_AUTOEXPIRE_FLAG,
  msi.VMI_FORECAST_TYPE,
  msi.FORECAST_HORIZON,
  msi.BUDGET_CONSTRAINED,
  msi.DAYS_TGT_INV_SUPPLY,
  msi.DAYS_TGT_INV_WINDOW,
  msi.DAYS_MAX_INV_SUPPLY,
  msi.DAYS_MAX_INV_WINDOW,
  msi.DRP_PLANNED,
  msi.CONTINOUS_TRANSFER,
  msi.CONVERGENCE,
  msi.DIVERGENCE,
  msi.SOURCE_TYPE,
  msi.SUBSTITUTION_WINDOW,
  msi.CREATE_SUPPLY_FLAG,
  msi.yield_conv_factor,
  msi.serial_number_control_code  ,
  msi.Item_Creation_Date,
  msi.EAM_ITEM_TYPE,	/* ds change change */
  msi.pegging_demand_window_days,
  msi.pegging_supply_window_days,
  msi.REPAIR_LEAD_TIME , --# For Bug 5606037 SRP Changes
  msi.PREPOSITION_POINT,
  msi.REPAIR_YIELD ,
  msi.REPAIR_PROGRAM
FROM MSC_ITEM_ID_LID t3,
     MSC_ITEM_ID_LID t2,
     MSC_ITEM_ID_LID t1,
     MSC_TRADING_PARTNERS mtp,
     MSC_ST_SYSTEM_ITEMS msi
WHERE t1.SR_INVENTORY_ITEM_ID= msi.sr_inventory_item_id
  AND t1.sr_instance_id= msi.sr_instance_id
  AND t2.SR_INVENTORY_ITEM_ID(+)= msi.base_item_id
  AND t2.sr_instance_id(+)= msi.sr_instance_id
  AND t3.SR_INVENTORY_ITEM_ID(+)= msi.product_family_id
  AND t3.sr_instance_id(+)= msi.sr_instance_id
  AND mtp.sr_tp_id(+)= msi.organization_id
  AND mtp.partner_type(+) = 3
  AND mtp.sr_instance_id(+)= msi.sr_instance_id
  AND msi.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

/*
   CURSOR c2 IS
SELECT distinct
       msi.abc_class_id,
       msi.abc_class_name,
       msi.sr_instance_id,
       msi.organization_id
FROM   MSC_ST_SYSTEM_ITEMS msi
WHERE  msi.sr_instance_id = MSC_CL_COLLECTION.v_instance_id
AND    msi.abc_class_id is not null
AND    msi.abc_class_name is not null;*/

   c_count     NUMBER:=0;
   lv_tbl      VARCHAR2(30);
   lv_sql_stmt VARCHAR2(7500);
   lv_sql_ins     vARCHAR2(8000);
   lb_FetchComplete  Boolean;
   ln_rows_to_fetch  Number := nvl(TO_NUMBER( FND_PROFILE.VALUE('MRP_PURGE_BATCH_SIZE')),75000);
   lv_MSC_CONFIGURATION VARCHAR2(10) := nvl(fnd_profile.value('MSC_X_CONFIGURATION'), MSC_UTIL.G_CONF_APS);

   TYPE CharTblTyp IS TABLE OF VARCHAR2(270);
   TYPE NumTblTyp  IS TABLE OF NUMBER;
   TYPE dateTblTyp IS TABLE OF DATE;

   lb_ORGANIZATION_ID    	NumTblTyp;
  lb_INVENTORY_ITEM_ID   	NumTblTyp;
  lb_ITEM_NAME          	CharTblTyp;
  lb_LOTS_EXPIRATION    	NumTblTyp;
  lb_LOT_CONTROL_CODE   	NumTblTyp;
  lb_SHRINKAGE_RATE	        NumTblTyp;
  lb_FIXED_DAYS_SUPPLY         NumTblTyp;
  lb_FIXED_ORDER_QUANTITY     NumTblTyp;
  lb_FIXED_LOT_MULTIPLIER     NumTblTyp;
  lb_MINIMUM_ORDER_QUANTITY     NumTblTyp;
  lb_MAXIMUM_ORDER_QUANTITY     NumTblTyp;
  lb_ROUNDING_CONTROL_TYPE     NumTblTyp;
  lb_PLANNING_TIME_FENCE_CODE     NumTblTyp;
  lb_PLANNING_TIME_FENCE_DAYS     NumTblTyp;
  lb_DEMAND_TIME_FENCE_DAYS     NumTblTyp;
  lb_DESCRIPTION     CharTblTyp;
  lb_RELEASE_TIME_FENCE_CODE     NumTblTyp;
  lb_RELEASE_TIME_FENCE_DAYS     NumTblTyp;
  lb_IN_SOURCE_PLAN     NumTblTyp;
  lb_REVISION      CharTblTyp;
  lb_SR_CATEGORY_ID     NumTblTyp;
  lb_CATEGORY_NAME     CharTblTyp;
  lb_ABC_CLASS_ID     NumTblTyp;
  lb_ABC_CLASS_NAME     CharTblTyp;
  lb_MRP_PLANNING_CODE     NumTblTyp;
  lb_FIXED_LEAD_TIME     NumTblTyp;
  lb_VARIABLE_LEAD_TIME     NumTblTyp;
  lb_PREPROCESSING_LEAD_TIME     NumTblTyp;
  lb_POSTPROCESSING_LEAD_TIME     NumTblTyp;
  lb_FULL_LEAD_TIME     NumTblTyp;
  lb_CUMULATIVE_TOTAL_LEAD_TIME     NumTblTyp;
  lb_CUM_MANUFACTURING_LEAD_TIME     NumTblTyp;
  lb_UOM_CODE    CharTblTyp;
  lb_UNIT_WEIGHT     NumTblTyp;
  lb_UNIT_VOLUME     NumTblTyp;
  lb_WEIGHT_UOM       CharTblTyp;
  lb_VOLUME_UOM      CharTblTyp;
  lb_PRODUCT_FAMILY_ID     NumTblTyp;
  lb_ATP_RULE_ID     NumTblTyp;
  lb_ATP_COMPONENTS_FLAG   CharTblTyp;
  lb_BUILT_IN_WIP_FLAG     NumTblTyp;
  lb_PURCHASING_ENABLED_FLAG     NumTblTyp;
  lb_PLANNING_MAKE_BUY_CODE     NumTblTyp;
  lb_REPETITIVE_TYPE     NumTblTyp;
  lb_REPETITIVE_VARIANCE_DAYS     NumTblTyp;
  lb_STANDARD_COST     NumTblTyp;
  lb_CARRYING_COST     NumTblTyp;
  lb_ORDER_COST     NumTblTyp;
  lb_DMD_LATENESS_COST     NumTblTyp;
  lb_SS_PENALTY_COST     NumTblTyp;
  lb_SUPPLIER_CAP_OVERUTIL_COST     NumTblTyp;
  lb_LIST_PRICE     NumTblTyp;
  lb_AVERAGE_DISCOUNT     NumTblTyp;
  lb_ENGINEERING_ITEM_FLAG     NumTblTyp;
  lb_INVENTORY_ITEM_FLAG     NumTblTyp;
  lb_WIP_SUPPLY_TYPE     NumTblTyp;
  lb_MRP_SAFETY_STOCK_CODE     NumTblTyp;
  lb_MRP_SAFETY_STOCK_PERCENT     NumTblTyp;
  lb_SAFETY_STOCK_BUCKET_DAYS     NumTblTyp;
  lb_BUYER_NAME     CharTblTyp;
  lb_PLANNER_CODE     CharTblTyp;
  lb_PLANNING_EXCEPTION_SET    CharTblTyp;
  lb_EXCESS_QUANTITY     NumTblTyp;
  lb_SHORTAGE_TYPE     NumTblTyp;
  lb_EXCEPTION_SHORTAGE_DAYS     NumTblTyp;
  lb_EXCESS_TYPE     NumTblTyp;
  lb_EXCEPTION_EXCESS_DAYS     NumTblTyp;
  lb_EXCEPTION_OVERPROMISED_DAYS     NumTblTyp;
  lb_BOM_ITEM_TYPE     NumTblTyp;
  lb_ATO_FORECAST_CONTROL     NumTblTyp;
  lb_EFFECTIVITY_CONTROL     NumTblTyp;
  lb_ORGANIZATION_CODE     CharTblTyp;
  lb_ACCEPTABLE_RATE_INCREASE     NumTblTyp;
  lb_ACCEPTABLE_RATE_DECREASE     NumTblTyp;
  lb_INVENTORY_PLANNING_CODE     NumTblTyp;
  lb_ACCEPTABLE_EARLY_DELIVERY     NumTblTyp;
  lb_MRP_CALCULATE_ATP_FLAG     NumTblTyp;
  lb_END_ASSEMBLY_PEGGING_FLAG  CharTblTyp;
  lb_BASE_ITEM_ID     NumTblTyp;
  lb_PRIMARY_SUPPLIER_ID     NumTblTyp;
  lb_ATP_FLAG      CharTblTyp;
  lb_NEW_ATP_FLAG    CharTblTyp;
  lb_REVISION_QTY_CONTROL_CODE     NumTblTyp;
  lb_EXPENSE_ACCOUNT     NumTblTyp;
  lb_INVENTORY_ASSET_FLAG   CharTblTyp;
  lb_BUYER_ID     NumTblTyp;
  lb_SOURCE_ORG_ID     NumTblTyp;
  lb_MATERIAL_COST     NumTblTyp;
  lb_RESOURCE_COST     NumTblTyp;
  lb_SR_INVENTORY_ITEM_ID     NumTblTyp;
  lb_DELETED_FLAG     NumTblTyp;
  lb_SR_INSTANCE_ID     NumTblTyp;
  lb_EAM_ITEM_TYPE     NumTblTyp;      /* ds change change */
  lb_REPLENISH_TO_ORDER_FLAG  CharTblTyp;
  lb_PICK_COMPONENTS_FLAG   CharTblTyp;
  lb_PIP_FLAG     NumTblTyp;
  lb_SOURCE_TYPE     NumTblTyp;
  lb_SUBSTITUTION_WINDOW     NumTblTyp;
  lb_CREATE_SUPPLY_FLAG  NumTblTyp;
  lb_YIELD_CONV_FACTOR     NumTblTyp;
  lb_SERIAL_NUMBER_CONTROL_CODE NumTblTyp;

  lb_REDUCE_MPS			NumTblTyp;
  lb_CRITICAL_COMPONENT_FLAG	CharTblTyp;
  lb_VMI_MINIMUM_UNITS		NumTblTyp;
  lb_VMI_MINIMUM_DAYS		NumTblTyp;
  lb_VMI_MAXIMUM_UNITS		NumTblTyp;
  lb_VMI_MAXIMUM_DAYS		NumTblTyp;
  lb_VMI_FIXED_ORDER_QUANTITY	NumTblTyp;
  lb_SO_AUTHORIZATION_FLAG	CharTblTyp;
  lb_CONSIGNED_FLAG		CharTblTyp;
  lb_ASN_AUTOEXPIRE_FLAG	CharTblTyp;
  lb_VMI_FORECAST_TYPE		CharTblTyp;
  lb_FORECAST_HORIZON		NumTblTyp;
  lb_BUDGET_CONSTRAINED		NumTblTyp;
  lb_DAYS_TGT_INV_SUPPLY	NumTblTyp;
  lb_DAYS_TGT_INV_WINDOW	NumTblTyp;
  lb_DAYS_MAX_INV_SUPPLY	NumTblTyp;
  lb_DAYS_MAX_INV_WINDOW	NumTblTyp;
  lb_DRP_PLANNED		NumTblTyp;
  lb_CONTINOUS_TRANSFER		NumTblTyp;
  lb_CONVERGENCE		NumTblTyp;
  lb_DIVERGENCE			NumTblTyp;
  lb_ITEM_CREATION_DATE dateTblTyp;
  lb_PEGGING_DEMAND_WINDOW_DAYS NumTblTyp;
  lb_PEGGING_SUPPLY_WINDOW_DAYS NumTblTyp;
  lb_REPAIR_LEAD_TIME NumTblTyp; --# For Bug 5606037 SRP Changes
  lb_REPAIR_YIELD NumTblTyp;
  lb_PRE_POSITIONING_POINT CharTblTyp;
  lb_REPAIR_PROGRAM NumTblTyp;

  lv_errbuf			VARCHAR2(240);
  lv_retcode			NUMBER;

   BEGIN

IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   lv_tbl:= 'SYSTEM_ITEMS_'||MSC_CL_COLLECTION.v_INSTANCE_CODE;
ELSE
   lv_tbl:= 'MSC_SYSTEM_ITEMS';
END IF;


lv_sql_stmt:=
'INSERT INTO '||lv_tbl
||'( PLAN_ID,'
||'  ORGANIZATION_ID,'
||'  INVENTORY_ITEM_ID,'
||'  ITEM_NAME,'
||'  LOTS_EXPIRATION,'
||'  LOT_CONTROL_CODE,'
||'  SHRINKAGE_RATE,'
||'  FIXED_DAYS_SUPPLY,'
||'  FIXED_ORDER_QUANTITY,'
||'  FIXED_LOT_MULTIPLIER,'
||'  MINIMUM_ORDER_QUANTITY,'
||'  MAXIMUM_ORDER_QUANTITY,'
||'  ROUNDING_CONTROL_TYPE,'
||'  PLANNING_TIME_FENCE_CODE,'
||'  PLANNING_TIME_FENCE_DAYS,'
||'  DEMAND_TIME_FENCE_DAYS,'
||'  DESCRIPTION,'
||'  RELEASE_TIME_FENCE_CODE,'
||'  RELEASE_TIME_FENCE_DAYS,'
||'  IN_SOURCE_PLAN,'
||'  REVISION,'
||'  SR_CATEGORY_ID,'
||'  CATEGORY_NAME,'
||'  ABC_CLASS,'
||'  ABC_CLASS_NAME,'
||'  MRP_PLANNING_CODE,'
||'  FIXED_LEAD_TIME,'
||'  VARIABLE_LEAD_TIME,'
||'  PREPROCESSING_LEAD_TIME,'
||'  POSTPROCESSING_LEAD_TIME,'
||'  FULL_LEAD_TIME,'
||'  CUMULATIVE_TOTAL_LEAD_TIME,'
||'  CUM_MANUFACTURING_LEAD_TIME,'
||'  UOM_CODE,'
||'  UNIT_WEIGHT,'
||'  UNIT_VOLUME,'
||'  WEIGHT_UOM,'
||'  VOLUME_UOM,'
||'  PRODUCT_FAMILY_ID,'
||'  ATP_RULE_ID,'
||'  ATP_COMPONENTS_FLAG,'
||'  BUILD_IN_WIP_FLAG,'
||'  PURCHASING_ENABLED_FLAG,'
||'  PLANNING_MAKE_BUY_CODE,'
||'  REPETITIVE_TYPE,'
||'  REPETITIVE_VARIANCE,'
||'  STANDARD_COST,'
||'  CARRYING_COST,'
||'  ORDER_COST,'
||'  DMD_LATENESS_COST,'
||'  SS_PENALTY_COST,'
||'  SUPPLIER_CAP_OVERUTIL_COST,'
||'  LIST_PRICE,'
||'  AVERAGE_DISCOUNT,'
||'  ENGINEERING_ITEM_FLAG,'
||'  INVENTORY_ITEM_FLAG,'
||'  WIP_SUPPLY_TYPE,'
||'  SAFETY_STOCK_CODE,'
||'  SAFETY_STOCK_PERCENT,'
||'  SAFETY_STOCK_BUCKET_DAYS,'
||'  BUYER_NAME,'
||'  PLANNER_CODE,'
||'  PLANNING_EXCEPTION_SET,'
||'  EXCESS_QUANTITY,'
||'  SHORTAGE_TYPE,'
||'  EXCEPTION_SHORTAGE_DAYS,'
||'  EXCESS_TYPE,'
||'  EXCEPTION_EXCESS_DAYS,'
||'  EXCEPTION_OVERPROMISED_DAYS,'
||'  BOM_ITEM_TYPE,'
||'  ATO_FORECAST_CONTROL,'
||'  EFFECTIVITY_CONTROL,'
||'  ORGANIZATION_CODE,'
||'  ACCEPTABLE_RATE_INCREASE,'
||'  ACCEPTABLE_RATE_DECREASE,'
||'  INVENTORY_PLANNING_CODE,'
||'  ACCEPTABLE_EARLY_DELIVERY,'
||'  CALCULATE_ATP,'
||'  END_ASSEMBLY_PEGGING_FLAG,'
||'  BASE_ITEM_ID,'
||'  PRIMARY_SUPPLIER_ID,'
||'  ATP_FLAG,'
||'  NEW_ATP_FLAG,'
||'  REVISION_QTY_CONTROL_CODE,'
||'  EXPENSE_ACCOUNT,'
||'  INVENTORY_ASSET_FLAG,'
||'  BUYER_ID,'
||'  SOURCE_ORG_ID,'
||'  MATERIAL_COST,'
||'  RESOURCE_COST,'
||'  REPLENISH_TO_ORDER_FLAG,'
||'  PICK_COMPONENTS_FLAG,'
||'  YIELD_CONV_FACTOR,'
||'  PIP_FLAG,'
||'  REDUCE_MPS,'
||'  CRITICAL_COMPONENT_FLAG,'
||'  VMI_MINIMUM_UNITS,'
||'  VMI_MINIMUM_DAYS,'
||'  VMI_MAXIMUM_UNITS,'
||'  VMI_MAXIMUM_DAYS,'
||'  VMI_FIXED_ORDER_QUANTITY,'
||'  SO_AUTHORIZATION_FLAG,'
||'  CONSIGNED_FLAG,'
||'  ASN_AUTOEXPIRE_FLAG,'
||'  VMI_FORECAST_TYPE,'
||'  FORECAST_HORIZON,'
||'  BUDGET_CONSTRAINED,'
||'  DAYS_TGT_INV_SUPPLY,'
||'  DAYS_TGT_INV_WINDOW,'
||'  DAYS_MAX_INV_SUPPLY,'
||'  DAYS_MAX_INV_WINDOW,'
||'  DRP_PLANNED,'
||'  CONTINOUS_TRANSFER,'
||'  CONVERGENCE,'
||'  DIVERGENCE,'
||'  VMI_REFRESH_FLAG,'
||'  SOURCE_TYPE,'
||'  SUBSTITUTION_WINDOW,'
||'  CREATE_SUPPLY_FLAG,'
||'  SERIAL_NUMBER_CONTROL_CODE,'
||'  SR_INVENTORY_ITEM_ID,'
||'  ITEM_CREATION_DATE,'
||'  SR_INSTANCE_ID,'
||'  EAM_ITEM_TYPE,'  /* ds change change */
||'  REPAIR_LEAD_TIME,' /* SRP Changes */
||'  PREPOSITION_POINT ,'
||'  REPAIR_YIELD,'
||'  REPAIR_PROGRAM,'

||'  REFRESH_NUMBER,'
||'  LAST_UPDATE_DATE,'
||'  LAST_UPDATED_BY,'
||'  CREATION_DATE,'
||'  CREATED_BY,'
||'  PEGGING_DEMAND_WINDOW_DAYS,'
||'  PEGGING_SUPPLY_WINDOW_DAYS )'
||'VALUES'
||'( -1,'
||'  :ORGANIZATION_ID,'
||'  :INVENTORY_ITEM_ID,'
||'  :ITEM_NAME,'
||'  :LOTS_EXPIRATION,'
||'  :LOT_CONTROL_CODE,'
||'  :SHRINKAGE_RATE,'
||'  :FIXED_DAYS_SUPPLY,'
||'  :FIXED_ORDER_QUANTITY,'
||'  :FIXED_LOT_MULTIPLIER,'
||'  :MINIMUM_ORDER_QUANTITY,'
||'  :MAXIMUM_ORDER_QUANTITY,'
||'  :ROUNDING_CONTROL_TYPE,'
||'  :PLANNING_TIME_FENCE_CODE,'
||'  :PLANNING_TIME_FENCE_DAYS,'
||'  :DEMAND_TIME_FENCE_DAYS,'
||'  :DESCRIPTION,'
||'  :RELEASE_TIME_FENCE_CODE,'
||'  :RELEASE_TIME_FENCE_DAYS,'
||'  :IN_SOURCE_PLAN,'
||'  :REVISION,'
||'  :SR_CATEGORY_ID,'
||'  :CATEGORY_NAME,'
||'  :ABC_CLASS_ID,'
||'  :ABC_CLASS_NAME,'
||'  :MRP_PLANNING_CODE,'
||'  :FIXED_LEAD_TIME,'
||'  :VARIABLE_LEAD_TIME,'
||'  :PREPROCESSING_LEAD_TIME,'
||'  :POSTPROCESSING_LEAD_TIME,'
||'  :FULL_LEAD_TIME,'
||'  :CUMULATIVE_TOTAL_LEAD_TIME,'
||'  :CUM_MANUFACTURING_LEAD_TIME,'
||'  :UOM_CODE,'
||'  :UNIT_WEIGHT,'
||'  :UNIT_VOLUME,'
||'  :WEIGHT_UOM,'
||'  :VOLUME_UOM,'
||'  :PRODUCT_FAMILY_ID,'
||'  :ATP_RULE_ID,'
||'  :ATP_COMPONENTS_FLAG,'
||'  :BUILT_IN_WIP_FLAG,'
||'  :PURCHASING_ENABLED_FLAG,'
||'  :PLANNING_MAKE_BUY_CODE,'
||'  :REPETITIVE_TYPE,'
||'  :REPETITIVE_VARIANCE_DAYS,'
||'  :STANDARD_COST,'
||'  :CARRYING_COST,'
||'  :ORDER_COST,'
||'  :DMD_LATENESS_COST,'
||'  :SS_PENALTY_COST,'
||'  :SUPPLIER_CAP_OVERUTIL_COST,'
||'  :LIST_PRICE,'
||'  :AVERAGE_DISCOUNT,'
||'  :ENGINEERING_ITEM_FLAG,'
||'  :INVENTORY_ITEM_FLAG,'
||'  :WIP_SUPPLY_TYPE,'
||'  :MRP_SAFETY_STOCK_CODE,'
||'  :MRP_SAFETY_STOCK_PERCENT,'
||'  :SAFETY_STOCK_BUCKET_DAYS,'
||'  :BUYER_NAME,'
||'  :PLANNER_CODE,'
||'  :PLANNING_EXCEPTION_SET,'
||'  :EXCESS_QUANTITY,'
||'  :SHORTAGE_TYPE,'
||'  :EXCEPTION_SHORTAGE_DAYS,'
||'  :EXCESS_TYPE,'
||'  :EXCEPTION_EXCESS_DAYS,'
||'  :EXCEPTION_OVERPROMISED_DAYS,'
||'  :BOM_ITEM_TYPE,'
||'  :ATO_FORECAST_CONTROL,'
||'  :EFFECTIVITY_CONTROL,'
||'  :ORGANIZATION_CODE,'
||'  :ACCEPTABLE_RATE_INCREASE,'
||'  :ACCEPTABLE_RATE_DECREASE,'
||'  :INVENTORY_PLANNING_CODE,'
||'  :ACCEPTABLE_EARLY_DELIVERY,'
||'  :MRP_CALCULATE_ATP_FLAG,'
||'  :END_ASSEMBLY_PEGGING_FLAG,'
||'  :BASE_ITEM_ID,'
||'  :PRIMARY_SUPPLIER_ID,'
||'  :ATP_FLAG,'
||'  :NEW_ATP_FLAG,'
||'  :REVISION_QTY_CONTROL_CODE,'
||'  :EXPENSE_ACCOUNT,'
||'  :INVENTORY_ASSET_FLAG,'
||'  :BUYER_ID,'
||'  :SOURCE_ORG_ID,'
||'  :MATERIAL_COST,'
||'  :RESOURCE_COST,'
||'  :REPLENISH_TO_ORDER_FLAG,'
||'  :PICK_COMPONENTS_FLAG,'
||'  :YIELD_CONV_FACTOR,'
||'  :PIP_FLAG,'
||'  :REDUCE_MPS,'
||'  :CRITICAL_COMPONENT_FLAG,'
||'  :VMI_MINIMUM_UNITS,'
||'  :VMI_MINIMUM_DAYS,'
||'  :VMI_MAXIMUM_UNITS,'
||'  :VMI_MAXIMUM_DAYS,'
||'  :VMI_FIXED_ORDER_QUANTITY,'
||'  :SO_AUTHORIZATION_FLAG,'
||'  :CONSIGNED_FLAG,'
||'  :ASN_AUTOEXPIRE_FLAG,'
||'  :VMI_FORECAST_TYPE,'
||'  :FORECAST_HORIZON,'
||'  :BUDGET_CONSTRAINED,'
||'  :DAYS_TGT_INV_SUPPLY,'
||'  :DAYS_TGT_INV_WINDOW,'
||'  :DAYS_MAX_INV_SUPPLY,'
||'  :DAYS_MAX_INV_WINDOW,'
||'  :DRP_PLANNED,'
||'  :CONTINOUS_TRANSFER,'
||'  :CONVERGENCE,'
||'  :DIVERGENCE,'
||'  1,'
||'  :SOURCE_TYPE,'
||'  :SUBSTITUTION_WINDOW,'
||'  :CREATE_SUPPLY_FLAG,'
||'  :SERIAL_NUMBER_CONTROL_CODE,'
||'  :SR_INVENTORY_ITEM_ID,'
||'  :ITEM_CREATION_DATE,'
||'  :SR_INSTANCE_ID,'
||'  :EAM_ITEM_TYPE,'	/* ds change change */
||'  :REPAIR_LEAD_TIME,' --# For Bug 5606037 SRP Changes
||'  :PREPOSITION_POINT,'
||'  :REPAIR_YIELD,'
||'  :REPAIR_PROGRAM,'
||'  :v_last_collection_id,'
||'  :v_current_date,'
||'  :v_current_user,'
||'  :v_current_date,'
||'  :v_current_user,'
||'  :PEGGING_DEMAND_WINDOW_DAYS,'
||'  :PEGGING_SUPPLY_WINDOW_DAYS )';

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) AND
                                    MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_NO THEN

  IF MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SYSTEM_ITEMS', MSC_CL_COLLECTION.v_instance_id, -1);
  ELSE
    v_sub_str :=' AND ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SYSTEM_ITEMS', MSC_CL_COLLECTION.v_instance_id, -1,v_sub_str);
  END IF;
END IF;

-- delete is not supported
IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN
BEGIN
lv_sql_ins :=
' INSERT /*+ append  */ '
|| ' INTO '||lv_tbl
||'( PLAN_ID,'
||'  ORGANIZATION_ID,'
||'  INVENTORY_ITEM_ID,'
||'  ITEM_NAME,'
||'  LOTS_EXPIRATION,'
||'  LOT_CONTROL_CODE,'
||'  SHRINKAGE_RATE,'
||'  FIXED_DAYS_SUPPLY,'
||'  FIXED_ORDER_QUANTITY,'
||'  FIXED_LOT_MULTIPLIER,'
||'  MINIMUM_ORDER_QUANTITY,'
||'  MAXIMUM_ORDER_QUANTITY,'
||'  ROUNDING_CONTROL_TYPE,'
||'  PLANNING_TIME_FENCE_CODE,'
||'  PLANNING_TIME_FENCE_DAYS,'
||'  DEMAND_TIME_FENCE_DAYS,'
||'  DESCRIPTION,'
||'  RELEASE_TIME_FENCE_CODE,'
||'  RELEASE_TIME_FENCE_DAYS,'
||'  IN_SOURCE_PLAN,'
||'  REVISION,'
||'  SR_CATEGORY_ID,'
||'  CATEGORY_NAME,'
||'  ABC_CLASS,'
||'  ABC_CLASS_NAME,'
||'  MRP_PLANNING_CODE,'
||'  FIXED_LEAD_TIME,'
||'  VARIABLE_LEAD_TIME,'
||'  PREPROCESSING_LEAD_TIME,'
||'  POSTPROCESSING_LEAD_TIME,'
||'  FULL_LEAD_TIME,'
||'  CUMULATIVE_TOTAL_LEAD_TIME,'
||'  CUM_MANUFACTURING_LEAD_TIME,'
||'  UOM_CODE,'
||'  UNIT_WEIGHT,'
||'  UNIT_VOLUME,'
||'  WEIGHT_UOM,'
||'  VOLUME_UOM,'
||'  PRODUCT_FAMILY_ID,'
||'  ATP_RULE_ID,'
||'  ATP_COMPONENTS_FLAG,'
||'  BUILD_IN_WIP_FLAG,'
||'  PURCHASING_ENABLED_FLAG,'
||'  PLANNING_MAKE_BUY_CODE,'
||'  REPETITIVE_TYPE,'
||'  REPETITIVE_VARIANCE,'
||'  STANDARD_COST,'
||'  CARRYING_COST,'
||'  ORDER_COST,'
||'  DMD_LATENESS_COST,'
||'  SS_PENALTY_COST,'
||'  SUPPLIER_CAP_OVERUTIL_COST,'
||'  LIST_PRICE,'
||'  AVERAGE_DISCOUNT,'
||'  ENGINEERING_ITEM_FLAG,'
||'  INVENTORY_ITEM_FLAG,'
||'  WIP_SUPPLY_TYPE,'
||'  SAFETY_STOCK_CODE,'
||'  SAFETY_STOCK_PERCENT,'
||'  SAFETY_STOCK_BUCKET_DAYS,'
||'  BUYER_NAME,'
||'  PLANNER_CODE,'
||'  PLANNING_EXCEPTION_SET,'
||'  EXCESS_QUANTITY,'
||'  SHORTAGE_TYPE,'
||'  EXCEPTION_SHORTAGE_DAYS,'
||'  EXCESS_TYPE,'
||'  EXCEPTION_EXCESS_DAYS,'
||'  EXCEPTION_OVERPROMISED_DAYS,'
||'  BOM_ITEM_TYPE,'
||'  ATO_FORECAST_CONTROL,'
||'  EFFECTIVITY_CONTROL,'
||'  ORGANIZATION_CODE,'
||'  ACCEPTABLE_RATE_INCREASE,'
||'  ACCEPTABLE_RATE_DECREASE,'
||'  INVENTORY_PLANNING_CODE,'
||'  ACCEPTABLE_EARLY_DELIVERY,'
||'  CALCULATE_ATP,'
||'  END_ASSEMBLY_PEGGING_FLAG,'
||'  BASE_ITEM_ID,'
||'  PRIMARY_SUPPLIER_ID,'
||'  ATP_FLAG,'
||'  NEW_ATP_FLAG,'
||'  REVISION_QTY_CONTROL_CODE,'
||'  EXPENSE_ACCOUNT,'
||'  INVENTORY_ASSET_FLAG,'
||'  BUYER_ID,'
||'  SOURCE_ORG_ID,'
||'  MATERIAL_COST,'
||'  RESOURCE_COST,'
||'  REPLENISH_TO_ORDER_FLAG,'
||'  PICK_COMPONENTS_FLAG,'
||'  YIELD_CONV_FACTOR,'
||'  PIP_FLAG,'
||'  REDUCE_MPS,'
||'  CRITICAL_COMPONENT_FLAG,'
||'  VMI_MINIMUM_UNITS,'
||'  VMI_MINIMUM_DAYS,'
||'  VMI_MAXIMUM_UNITS,'
||'  VMI_MAXIMUM_DAYS,'
||'  VMI_FIXED_ORDER_QUANTITY,'
||'  SO_AUTHORIZATION_FLAG,'
||'  CONSIGNED_FLAG,'
||'  ASN_AUTOEXPIRE_FLAG,'
||'  VMI_FORECAST_TYPE,'
||'  FORECAST_HORIZON,'
||'  BUDGET_CONSTRAINED,'
||'  DAYS_TGT_INV_SUPPLY,'
||'  DAYS_TGT_INV_WINDOW,'
||'  DAYS_MAX_INV_SUPPLY,'
||'  DAYS_MAX_INV_WINDOW,'
||'  DRP_PLANNED,'
||'  CONTINOUS_TRANSFER,'
||'  CONVERGENCE,'
||'  DIVERGENCE,'
||'  VMI_REFRESH_FLAG,'
||'  SOURCE_TYPE,'
||'  SUBSTITUTION_WINDOW,'
||'  CREATE_SUPPLY_FLAG,'
||'  SERIAL_NUMBER_CONTROL_CODE,'
||'  SR_INVENTORY_ITEM_ID,'
||'  ITEM_CREATION_DATE,'
||'  SR_INSTANCE_ID,'
||'  EAM_ITEM_TYPE,'   /* ds change change */
||'  REPAIR_LEAD_TIME,'  --# For Bug 5606037 SRP Changes
||'  PREPOSITION_POINT,'
||'  REPAIR_YIELD,'
||'  REPAIR_PROGRAM,'
||'  REFRESH_NUMBER,'
||'  LAST_UPDATE_DATE,'
||'  LAST_UPDATED_BY,'
||'  CREATION_DATE,'
||'  CREATED_BY,'
||'  PEGGING_DEMAND_WINDOW_DAYS,'
||'  PEGGING_SUPPLY_WINDOW_DAYS )'
||'  SELECT '
||'  -1,'
||'  msi.ORGANIZATION_ID,'
||'  t1.INVENTORY_ITEM_ID,'
||'  msi.ITEM_NAME,'
||'  msi.LOTS_EXPIRATION,'
||'  msi.LOT_CONTROL_CODE,'
||'  msi.SHRINKAGE_RATE,'
||'  msi.FIXED_DAYS_SUPPLY,'
||'  msi.FIXED_ORDER_QUANTITY,'
||'  msi.FIXED_LOT_MULTIPLIER,'
||'  msi.MINIMUM_ORDER_QUANTITY,'
||'  msi.MAXIMUM_ORDER_QUANTITY,'
||'  msi.ROUNDING_CONTROL_TYPE,'
||'  msi.PLANNING_TIME_FENCE_CODE,'
||'  msi.PLANNING_TIME_FENCE_DAYS,'
||'  msi.DEMAND_TIME_FENCE_DAYS,'
||'  replace(substrb(msi.DESCRIPTION,1,240),:v_chr9,'' '') DESCRIPTION,'
||'  msi.RELEASE_TIME_FENCE_CODE,'
||'  msi.RELEASE_TIME_FENCE_DAYS,'
||'  msi.IN_SOURCE_PLAN,'
||'  msi.REVISION,'
||'  msi.SR_CATEGORY_ID,'
||'  msi.CATEGORY_NAME,'
||'  msi.ABC_CLASS_ID,'
||'  msi.ABC_CLASS_NAME,'
||'  msi.MRP_PLANNING_CODE,'
||'  msi.FIXED_LEAD_TIME,'
||'  msi.VARIABLE_LEAD_TIME,'
||'  msi.PREPROCESSING_LEAD_TIME,'
||'  msi.POSTPROCESSING_LEAD_TIME,'
||'  msi.FULL_LEAD_TIME,'
||'  msi.CUMULATIVE_TOTAL_LEAD_TIME,'
||'  msi.CUM_MANUFACTURING_LEAD_TIME,'
||'  msi.UOM_CODE,'
||'  msi.UNIT_WEIGHT,'
||'  msi.UNIT_VOLUME,'
||'  msi.WEIGHT_UOM,'
||'  msi.VOLUME_UOM,'
||'  t3.Inventory_Item_ID,'
||'  msi.ATP_RULE_ID,'
||'  msi.ATP_COMPONENTS_FLAG,'
||'  msi.BUILT_IN_WIP_FLAG,'
||'  msi.PURCHASING_ENABLED_FLAG,'
||'  msi.PLANNING_MAKE_BUY_CODE,'
||'  msi.REPETITIVE_TYPE,'
||'  msi.REPETITIVE_VARIANCE_DAYS,'
||'  msi.STANDARD_COST,'
||'  msi.CARRYING_COST,'
||'  msi.ORDER_COST,'
||'  nvl(msi.DMD_LATENESS_COST, mtp.DEMAND_LATENESS_COST),'
||'  msi.SS_PENALTY_COST,'
||'  msi.SUPPLIER_CAP_OVERUTIL_COST,'
||'  nvl(msi.LIST_PRICE,msi.STANDARD_COST),'
||'  msi.AVERAGE_DISCOUNT,'
||'  msi.ENGINEERING_ITEM_FLAG,'
||'  msi.INVENTORY_ITEM_FLAG,'
||'  msi.WIP_SUPPLY_TYPE,'
||'  msi.MRP_SAFETY_STOCK_CODE,'
||'  msi.MRP_SAFETY_STOCK_PERCENT,'
||'  msi.SAFETY_STOCK_BUCKET_DAYS,'
||'  msi.BUYER_NAME,'
||'  msi.PLANNER_CODE,'
||'  msi.PLANNING_EXCEPTION_SET,'
||'  msi.EXCESS_QUANTITY,'
||'  msi.SHORTAGE_TYPE,'
||'  msi.EXCEPTION_SHORTAGE_DAYS,'
||'  msi.EXCESS_TYPE,'
||'  msi.EXCEPTION_EXCESS_DAYS,'
||'  msi.EXCEPTION_OVERPROMISED_DAYS,'
||'  msi.BOM_ITEM_TYPE,'
||'  msi.ATO_FORECAST_CONTROL,'
||'  msi.EFFECTIVITY_CONTROL,'
||'  msi.ORGANIZATION_CODE,'
||'  msi.ACCEPTABLE_RATE_INCREASE,'
||'  msi.ACCEPTABLE_RATE_DECREASE,'
||'  msi.INVENTORY_PLANNING_CODE,'
||'  msi.ACCEPTABLE_EARLY_DELIVERY,'
||'  msi.MRP_CALCULATE_ATP_FLAG,'
||'  msi.END_ASSEMBLY_PEGGING_FLAG,'
||'  t2.INVENTORY_ITEM_ID, '
||'  msi.PRIMARY_SUPPLIER_ID,'
||'  decode(msi.ATP_FLAG,''C'', ''Y'', msi.ATP_FLAG) ,'
||'  decode(msi.ATP_FLAG,''C'', ''Y'', ''N'') ,'
||'  msi.REVISION_QTY_CONTROL_CODE,'
||'  msi.EXPENSE_ACCOUNT,'
||'  msi.INVENTORY_ASSET_FLAG,'
||'  msi.BUYER_ID,'
||'  msi.SOURCE_ORG_ID,'
||'  msi.MATERIAL_COST,'
||'  msi.RESOURCE_COST,'
||'  msi.replenish_to_order_flag,'
||'  msi.pick_components_flag,'
||'  msi.yield_conv_factor,'
||'  msi.pip_flag,'
||'  msi.REDUCE_MPS,'
||'  msi.CRITICAL_COMPONENT_FLAG,'
||'  msi.VMI_MINIMUM_UNITS,'
||'  msi.VMI_MINIMUM_DAYS,'
||'  msi.VMI_MAXIMUM_UNITS,'
||'  msi.VMI_MAXIMUM_DAYS,'
||'  msi.VMI_FIXED_ORDER_QUANTITY,'
||'  msi.SO_AUTHORIZATION_FLAG,'
||'  msi.CONSIGNED_FLAG,'
||'  msi.ASN_AUTOEXPIRE_FLAG,'
||'  msi.VMI_FORECAST_TYPE,'
||'  msi.FORECAST_HORIZON,'
||'  msi.BUDGET_CONSTRAINED,'
||'  msi.DAYS_TGT_INV_SUPPLY,'
||'  msi.DAYS_TGT_INV_WINDOW,'
||'  msi.DAYS_MAX_INV_SUPPLY,'
||'  msi.DAYS_MAX_INV_WINDOW,'
||'  msi.DRP_PLANNED,'
||'  msi.CONTINOUS_TRANSFER,'
||'  msi.CONVERGENCE,'
||'  msi.DIVERGENCE,'
||'  1,'
||'  msi.SOURCE_TYPE,'
||'  msi.SUBSTITUTION_WINDOW,'
||'  msi.CREATE_SUPPLY_FLAG,'
||'  msi.serial_number_control_code,'
||'  msi.SR_INVENTORY_ITEM_ID,'
||'  msi.ITEM_CREATION_DATE,'
||'  msi.SR_INSTANCE_ID,'
||'  msi.EAM_ITEM_TYPE,'  /* ds change change */
||'  msi.REPAIR_LEAD_TIME   , '--# For Bug 5606037 SRP Changes
||'  msi.PREPOSITION_POINT ,'
||'  msi.REPAIR_YIELD ,'
||'  msi.REPAIR_PROGRAM ,'
||'   :v_last_collection_id, '
||'   :v_current_date      , '
||'   :v_current_user      , '
||'   :v_current_date      , '
||'   :v_current_user      , '
||'  msi.PEGGING_DEMAND_WINDOW_DAYS,'
||'  msi.PEGGING_SUPPLY_WINDOW_DAYS '
||'  FROM MSC_ITEM_ID_LID t3, '
||'  MSC_ITEM_ID_LID t2, '
||'  MSC_ITEM_ID_LID t1, '
||'  MSC_TRADING_PARTNERS mtp, '
||'  MSC_ST_SYSTEM_ITEMS msi '
||' WHERE t1.SR_INVENTORY_ITEM_ID  = msi.sr_inventory_item_id '
||' AND t1.sr_instance_id          = msi.sr_instance_id '
||' AND t2.SR_INVENTORY_ITEM_ID(+) = msi.base_item_id '
||' AND t2.sr_instance_id(+)       = msi.sr_instance_id '
||' AND t3.SR_INVENTORY_ITEM_ID(+) = msi.product_family_id '
||' AND t3.sr_instance_id(+)       = msi.sr_instance_id '
||' AND mtp.sr_tp_id(+) = msi.organization_id '
||' AND mtp.partner_type(+) = 3 '
||' AND mtp.sr_instance_id(+) = msi.sr_instance_id '
||' AND msi.SR_INSTANCE_ID         = '||MSC_CL_COLLECTION.v_instance_id;

     EXECUTE IMMEDIATE lv_sql_ins
     USING   v_chr9, MSC_CL_COLLECTION.v_last_collection_id,MSC_CL_COLLECTION.v_current_date,MSC_CL_COLLECTION.v_current_user,MSC_CL_COLLECTION.v_current_date,MSC_CL_COLLECTION.v_current_user;

     commit;
EXCEPTION
   WHEN OTHERS THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_ITEM');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SYSTEM_ITEMS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

END;
END IF;

IF (MSC_CL_COLLECTION.v_is_incremental_refresh OR
       lv_MSC_CONFIGURATION = MSC_UTIL.G_CONF_APS_SCE OR
       lv_MSC_CONFIGURATION = MSC_UTIL.G_CONF_SCE) THEN
c_count :=0;

OPEN  c1;
IF (c1%ISOPEN) THEN
	LOOP
--
  -- Retrieve the next set of rows if we are currently not in the
  -- middle of processing a fetched set or rows.
  --
  IF (lb_FetchComplete) THEN
    EXIT;
  END IF;
 -- Fetch the next set of rows
  FETCH c1 BULK COLLECT INTO
  lb_ORGANIZATION_ID,
  lb_INVENTORY_ITEM_ID,
  lb_ITEM_NAME,
  lb_LOTS_EXPIRATION,
  lb_LOT_CONTROL_CODE,
  lb_SHRINKAGE_RATE,
  lb_FIXED_DAYS_SUPPLY,
  lb_FIXED_ORDER_QUANTITY,
  lb_FIXED_LOT_MULTIPLIER,
  lb_MINIMUM_ORDER_QUANTITY,
  lb_MAXIMUM_ORDER_QUANTITY,
  lb_ROUNDING_CONTROL_TYPE,
  lb_PLANNING_TIME_FENCE_CODE,
  lb_PLANNING_TIME_FENCE_DAYS,
  lb_DEMAND_TIME_FENCE_DAYS,
  lb_DESCRIPTION,
  lb_RELEASE_TIME_FENCE_CODE,
  lb_RELEASE_TIME_FENCE_DAYS,
  lb_IN_SOURCE_PLAN,
  lb_REVISION,
  lb_SR_CATEGORY_ID,
  lb_CATEGORY_NAME,
  lb_ABC_CLASS_ID,
  lb_ABC_CLASS_NAME,
  lb_MRP_PLANNING_CODE,
  lb_FIXED_LEAD_TIME,
  lb_VARIABLE_LEAD_TIME,
  lb_PREPROCESSING_LEAD_TIME,
  lb_POSTPROCESSING_LEAD_TIME,
  lb_FULL_LEAD_TIME,
  lb_CUMULATIVE_TOTAL_LEAD_TIME,
  lb_CUM_MANUFACTURING_LEAD_TIME,
  lb_UOM_CODE,
  lb_UNIT_WEIGHT,
  lb_UNIT_VOLUME,
  lb_WEIGHT_UOM,
  lb_VOLUME_UOM,
  lb_PRODUCT_FAMILY_ID,
  lb_ATP_RULE_ID,
  lb_ATP_COMPONENTS_FLAG,
  lb_BUILT_IN_WIP_FLAG,
  lb_PURCHASING_ENABLED_FLAG,
  lb_PLANNING_MAKE_BUY_CODE,
  lb_REPETITIVE_TYPE,
  lb_REPETITIVE_VARIANCE_DAYS,
  lb_STANDARD_COST,
  lb_CARRYING_COST,
  lb_ORDER_COST,
  lb_DMD_LATENESS_COST,
  lb_SS_PENALTY_COST,
  lb_SUPPLIER_CAP_OVERUTIL_COST,
  lb_LIST_PRICE,
  lb_AVERAGE_DISCOUNT,
  lb_ENGINEERING_ITEM_FLAG,
  lb_INVENTORY_ITEM_FLAG,
  lb_WIP_SUPPLY_TYPE,
  lb_MRP_SAFETY_STOCK_CODE,
  lb_MRP_SAFETY_STOCK_PERCENT,
  lb_SAFETY_STOCK_BUCKET_DAYS,
  lb_BUYER_NAME,
  lb_PLANNER_CODE,
  lb_PLANNING_EXCEPTION_SET,
  lb_EXCESS_QUANTITY,
  lb_SHORTAGE_TYPE,
  lb_EXCEPTION_SHORTAGE_DAYS,
  lb_EXCESS_TYPE,
  lb_EXCEPTION_EXCESS_DAYS,
  lb_EXCEPTION_OVERPROMISED_DAYS,
  lb_BOM_ITEM_TYPE,
  lb_ATO_FORECAST_CONTROL,
  lb_EFFECTIVITY_CONTROL,
  lb_ORGANIZATION_CODE,
  lb_ACCEPTABLE_RATE_INCREASE,
  lb_ACCEPTABLE_RATE_DECREASE,
  lb_INVENTORY_PLANNING_CODE,
  lb_ACCEPTABLE_EARLY_DELIVERY,
  lb_MRP_CALCULATE_ATP_FLAG,
  lb_END_ASSEMBLY_PEGGING_FLAG,
  lb_BASE_ITEM_ID,
  lb_PRIMARY_SUPPLIER_ID,
  lb_ATP_FLAG ,
  lb_NEW_ATP_FLAG ,
  lb_REVISION_QTY_CONTROL_CODE,
  lb_EXPENSE_ACCOUNT,
  lb_INVENTORY_ASSET_FLAG,
  lb_BUYER_ID,
  lb_SOURCE_ORG_ID,
  lb_MATERIAL_COST,
  lb_RESOURCE_COST,
  lb_SR_INVENTORY_ITEM_ID,
  lb_DELETED_FLAG,
  lb_SR_INSTANCE_ID,
  lb_REPLENISH_TO_ORDER_FLAG,
  lb_PICK_COMPONENTS_FLAG,
  lb_PIP_FLAG,
  lb_REDUCE_MPS,
  lb_CRITICAL_COMPONENT_FLAG,
  lb_VMI_MINIMUM_UNITS,
  lb_VMI_MINIMUM_DAYS,
  lb_VMI_MAXIMUM_UNITS,
  lb_VMI_MAXIMUM_DAYS,
  lb_VMI_FIXED_ORDER_QUANTITY,
  lb_SO_AUTHORIZATION_FLAG,
  lb_CONSIGNED_FLAG,
  lb_ASN_AUTOEXPIRE_FLAG,
  lb_VMI_FORECAST_TYPE,
  lb_FORECAST_HORIZON,
  lb_BUDGET_CONSTRAINED,
  lb_DAYS_TGT_INV_SUPPLY,
  lb_DAYS_TGT_INV_WINDOW,
  lb_DAYS_MAX_INV_SUPPLY,
  lb_DAYS_MAX_INV_WINDOW,
  lb_DRP_PLANNED,
  lb_CONTINOUS_TRANSFER,
  lb_CONVERGENCE,
  lb_DIVERGENCE,
  lb_SOURCE_TYPE,
  lb_SUBSTITUTION_WINDOW,
  lb_CREATE_SUPPLY_FLAG,
  lb_YIELD_CONV_FACTOR,
  lb_SERIAL_NUMBER_CONTROL_CODE ,
  lb_ITEM_CREATION_DATE,
  lb_EAM_ITEM_TYPE,	/* ds change change */
  lb_PEGGING_DEMAND_WINDOW_DAYS,
  lb_PEGGING_SUPPLY_WINDOW_DAYS,
  lb_REPAIR_LEAD_TIME,    --# For Bug 5606037 SRP Changes
  lb_PRE_POSITIONING_POINT,
  lb_REPAIR_YIELD,
  lb_REPAIR_PROGRAM
LIMIT ln_rows_to_fetch;

  -- Since we are only fetching records if either (1) this is the first
  -- fetch or (2) the previous fetch did not retrieve all of the
  -- records, then at least one row should always be fetched.  But
  -- checking just to make sure.
  EXIT WHEN lb_INVENTORY_ITEM_ID.count = 0;

  -- Check if all of the rows have been fetched.  If so, indicate that
  -- the fetch is complete so that another fetch is not made.
  -- Additional check is introduced for the following reasons
  -- In 9i, the table of records gets modified but in 8.1.6 the table of records is
  -- unchanged after the fetch(bug#2995144)
  IF (c1%NOTFOUND) THEN
    lb_FetchComplete := TRUE;
  END IF;

FOR j IN 1..lb_INVENTORY_ITEM_ID.COUNT LOOP



BEGIN

IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

UPDATE MSC_SYSTEM_ITEMS
SET
 ITEM_NAME= lb_ITEM_NAME(j),
 LOTS_EXPIRATION= lb_LOTS_EXPIRATION(j),
 LOT_CONTROL_CODE= lb_LOT_CONTROL_CODE(j),
 SHRINKAGE_RATE= lb_SHRINKAGE_RATE(j),
 FIXED_DAYS_SUPPLY= lb_FIXED_DAYS_SUPPLY(j),
 FIXED_ORDER_QUANTITY= lb_FIXED_ORDER_QUANTITY(j),
 FIXED_LOT_MULTIPLIER= lb_FIXED_LOT_MULTIPLIER(j),
 MINIMUM_ORDER_QUANTITY= lb_MINIMUM_ORDER_QUANTITY(j),
 MAXIMUM_ORDER_QUANTITY= lb_MAXIMUM_ORDER_QUANTITY(j),
 ROUNDING_CONTROL_TYPE= lb_ROUNDING_CONTROL_TYPE(j),
 PLANNING_TIME_FENCE_CODE= lb_PLANNING_TIME_FENCE_CODE(j),
 PLANNING_TIME_FENCE_DAYS= lb_PLANNING_TIME_FENCE_DAYS(j),
 DEMAND_TIME_FENCE_DAYS= lb_DEMAND_TIME_FENCE_DAYS(j),
 DESCRIPTION= lb_DESCRIPTION(j),
 RELEASE_TIME_FENCE_CODE= lb_RELEASE_TIME_FENCE_CODE(j),
 RELEASE_TIME_FENCE_DAYS= lb_RELEASE_TIME_FENCE_DAYS(j),
 IN_SOURCE_PLAN= lb_IN_SOURCE_PLAN(j),
 REVISION= lb_REVISION(j),
 SR_CATEGORY_ID= lb_SR_CATEGORY_ID(j),
 CATEGORY_NAME= lb_CATEGORY_NAME(j),
 ABC_CLASS= lb_ABC_CLASS_ID(j),
 ABC_CLASS_NAME= lb_ABC_CLASS_NAME(j),
 MRP_PLANNING_CODE= lb_MRP_PLANNING_CODE(j),
 FIXED_LEAD_TIME= lb_FIXED_LEAD_TIME(j),
 VARIABLE_LEAD_TIME= lb_VARIABLE_LEAD_TIME(j),
 PREPROCESSING_LEAD_TIME= lb_PREPROCESSING_LEAD_TIME(j),
 POSTPROCESSING_LEAD_TIME= lb_POSTPROCESSING_LEAD_TIME(j),
 FULL_LEAD_TIME= lb_FULL_LEAD_TIME(j),
 CUMULATIVE_TOTAL_LEAD_TIME= lb_CUMULATIVE_TOTAL_LEAD_TIME(j),
 CUM_MANUFACTURING_LEAD_TIME= lb_CUM_MANUFACTURING_LEAD_TIME(j),
 UOM_CODE= lb_UOM_CODE(j),
 UNIT_WEIGHT= lb_UNIT_WEIGHT(j),
 UNIT_VOLUME= lb_UNIT_VOLUME(j),
 WEIGHT_UOM= lb_WEIGHT_UOM(j),
 VOLUME_UOM= lb_VOLUME_UOM(j),
 PRODUCT_FAMILY_ID= lb_PRODUCT_FAMILY_ID(j),
 ATP_RULE_ID= lb_ATP_RULE_ID(j),
 ATP_COMPONENTS_FLAG= lb_ATP_COMPONENTS_FLAG(j),
 BUILD_IN_WIP_FLAG= lb_BUILT_IN_WIP_FLAG(j),
 PURCHASING_ENABLED_FLAG= lb_PURCHASING_ENABLED_FLAG(j),
 PLANNING_MAKE_BUY_CODE= lb_PLANNING_MAKE_BUY_CODE(j),
 REPETITIVE_TYPE= lb_REPETITIVE_TYPE(j),
 REPETITIVE_VARIANCE= lb_REPETITIVE_VARIANCE_DAYS(j),
 STANDARD_COST= lb_STANDARD_COST(j),
 CARRYING_COST= lb_CARRYING_COST(j),
 ORDER_COST= lb_ORDER_COST(j),
 DMD_LATENESS_COST= lb_DMD_LATENESS_COST(j),
 SS_PENALTY_COST= lb_SS_PENALTY_COST(j),
 SUPPLIER_CAP_OVERUTIL_COST= lb_SUPPLIER_CAP_OVERUTIL_COST(j),
 LIST_PRICE= lb_LIST_PRICE(j),
 AVERAGE_DISCOUNT= lb_AVERAGE_DISCOUNT(j),
 ENGINEERING_ITEM_FLAG= lb_ENGINEERING_ITEM_FLAG(j),
 INVENTORY_ITEM_FLAG= lb_INVENTORY_ITEM_FLAG(j),
 WIP_SUPPLY_TYPE= lb_WIP_SUPPLY_TYPE(j),
 SAFETY_STOCK_CODE= lb_MRP_SAFETY_STOCK_CODE(j),
 SAFETY_STOCK_PERCENT= lb_MRP_SAFETY_STOCK_PERCENT(j),
 SAFETY_STOCK_BUCKET_DAYS= lb_SAFETY_STOCK_BUCKET_DAYS(j),
 BUYER_NAME= lb_BUYER_NAME(j),
 PLANNER_CODE= lb_PLANNER_CODE(j),
 PLANNING_EXCEPTION_SET= lb_PLANNING_EXCEPTION_SET(j),
 EXCESS_QUANTITY= lb_EXCESS_QUANTITY(j),
 SHORTAGE_TYPE= lb_SHORTAGE_TYPE(j),
 EXCEPTION_SHORTAGE_DAYS= lb_EXCEPTION_SHORTAGE_DAYS(j),
 EXCESS_TYPE= lb_EXCESS_TYPE(j),
 EXCEPTION_EXCESS_DAYS= lb_EXCEPTION_EXCESS_DAYS(j),
 EXCEPTION_OVERPROMISED_DAYS= lb_EXCEPTION_OVERPROMISED_DAYS(j),
 BOM_ITEM_TYPE= lb_BOM_ITEM_TYPE(j),
 ATO_FORECAST_CONTROL= lb_ATO_FORECAST_CONTROL(j),
 EFFECTIVITY_CONTROL= lb_EFFECTIVITY_CONTROL(j),
 ORGANIZATION_CODE= lb_ORGANIZATION_CODE(j),
 ACCEPTABLE_RATE_INCREASE= lb_ACCEPTABLE_RATE_INCREASE(j),
 ACCEPTABLE_RATE_DECREASE= lb_ACCEPTABLE_RATE_DECREASE(j),
 INVENTORY_PLANNING_CODE= lb_INVENTORY_PLANNING_CODE(j),
 ACCEPTABLE_EARLY_DELIVERY= lb_ACCEPTABLE_EARLY_DELIVERY(j),
 CALCULATE_ATP= lb_MRP_CALCULATE_ATP_FLAG(j),
 END_ASSEMBLY_PEGGING_FLAG= lb_END_ASSEMBLY_PEGGING_FLAG(j),
 BASE_ITEM_ID= lb_BASE_ITEM_ID(j),
 PRIMARY_SUPPLIER_ID= lb_PRIMARY_SUPPLIER_ID(j),
 ATP_FLAG= lb_ATP_FLAG(j),
 NEW_ATP_FLAG= lb_NEW_ATP_FLAG(j),
 REVISION_QTY_CONTROL_CODE= lb_REVISION_QTY_CONTROL_CODE(j),
 EXPENSE_ACCOUNT= lb_EXPENSE_ACCOUNT(j),
 INVENTORY_ASSET_FLAG= lb_INVENTORY_ASSET_FLAG(j),
 BUYER_ID= lb_BUYER_ID(j),
 SOURCE_ORG_ID= lb_SOURCE_ORG_ID(j),
 MATERIAL_COST= lb_MATERIAL_COST(j),
 RESOURCE_COST= lb_RESOURCE_COST(j),
 REPLENISH_TO_ORDER_FLAG = lb_REPLENISH_TO_ORDER_FLAG (j),
 PICK_COMPONENTS_FLAG = lb_PICK_COMPONENTS_FLAG(j),
 YIELD_CONV_FACTOR = lb_YIELD_CONV_FACTOR(j),
 PIP_FLAG = lb_PIP_FLAG(j),
 REDUCE_MPS = lb_REDUCE_MPS(j),
 CRITICAL_COMPONENT_FLAG = lb_CRITICAL_COMPONENT_FLAG(j),
 VMI_MINIMUM_UNITS = lb_VMI_MINIMUM_UNITS(j),
 VMI_MINIMUM_DAYS = lb_VMI_MINIMUM_DAYS(j),
 VMI_MAXIMUM_UNITS = lb_VMI_MAXIMUM_UNITS(j),
 VMI_MAXIMUM_DAYS = lb_VMI_MAXIMUM_DAYS(j),
 VMI_FIXED_ORDER_QUANTITY = lb_VMI_FIXED_ORDER_QUANTITY(j),
 SO_AUTHORIZATION_FLAG = lb_SO_AUTHORIZATION_FLAG(j),
 CONSIGNED_FLAG = lb_CONSIGNED_FLAG(j),
 ASN_AUTOEXPIRE_FLAG = lb_ASN_AUTOEXPIRE_FLAG(j),
 VMI_FORECAST_TYPE = lb_VMI_FORECAST_TYPE(j),
 FORECAST_HORIZON = lb_FORECAST_HORIZON(j),
 BUDGET_CONSTRAINED  = lb_BUDGET_CONSTRAINED(j),
 DAYS_TGT_INV_SUPPLY = lb_DAYS_TGT_INV_SUPPLY(j),
 DAYS_TGT_INV_WINDOW = lb_DAYS_TGT_INV_WINDOW(j),
 DAYS_MAX_INV_SUPPLY = lb_DAYS_MAX_INV_SUPPLY(j),
 DAYS_MAX_INV_WINDOW = lb_DAYS_MAX_INV_WINDOW(j),
 DRP_PLANNED = lb_DRP_PLANNED(j),
 CONTINOUS_TRANSFER = lb_CONTINOUS_TRANSFER(j),
 CONVERGENCE = lb_CONVERGENCE(j),
 DIVERGENCE = lb_DIVERGENCE(j),
 VMI_REFRESH_FLAG = 1,
 SOURCE_TYPE = lb_SOURCE_TYPE(j),
 SUBSTITUTION_WINDOW = lb_SUBSTITUTION_WINDOW(j),
 CREATE_SUPPLY_FLAG = lb_CREATE_SUPPLY_FLAG(j),
 SERIAL_NUMBER_CONTROL_CODE = lb_SERIAL_NUMBER_CONTROL_CODE(j),
 SR_INVENTORY_ITEM_ID= lb_SR_INVENTORY_ITEM_ID(j),
 EAM_ITEM_TYPE       = lb_EAM_ITEM_TYPE(j),  /* ds change change */
 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
/* ATP SUMMARY CHANGES Added the Refresh_number */
 REFRESH_NUMBER = MSC_CL_COLLECTION.v_last_collection_id,
 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user,
 REPAIR_LEAD_TIME= lb_REPAIR_LEAD_TIME(j), --# For Bug 5606037 SRP Changes
 PREPOSITION_POINT = lb_PRE_POSITIONING_POINT(j),
 REPAIR_PROGRAM = lb_REPAIR_PROGRAM(j),
 REPAIR_YIELD = lb_REPAIR_YIELD(j),
 PEGGING_DEMAND_WINDOW_DAYS = lb_PEGGING_DEMAND_WINDOW_DAYS(j),
 PEGGING_SUPPLY_WINDOW_DAYS = lb_PEGGING_SUPPLY_WINDOW_DAYS(j)
WHERE PLAN_ID= -1
  AND ORGANIZATION_ID= lb_ORGANIZATION_ID(j)
  AND INVENTORY_ITEM_ID= lb_INVENTORY_ITEM_ID(j)
  AND SR_INSTANCE_ID= lb_SR_INSTANCE_ID(j);

--END IF; -- refresh mode

IF  SQL%NOTFOUND THEN

EXECUTE IMMEDIATE lv_sql_stmt
USING lb_ORGANIZATION_ID(j),
  lb_INVENTORY_ITEM_ID(j),
  lb_ITEM_NAME(j),
  lb_LOTS_EXPIRATION(j),
  lb_LOT_CONTROL_CODE(j),
  lb_SHRINKAGE_RATE(j),
  lb_FIXED_DAYS_SUPPLY(j),
  lb_FIXED_ORDER_QUANTITY(j),
  lb_FIXED_LOT_MULTIPLIER(j),
  lb_MINIMUM_ORDER_QUANTITY(j),
  lb_MAXIMUM_ORDER_QUANTITY(j),
  lb_ROUNDING_CONTROL_TYPE(j),
  lb_PLANNING_TIME_FENCE_CODE(j),
  lb_PLANNING_TIME_FENCE_DAYS(j),
  lb_DEMAND_TIME_FENCE_DAYS(j),
  lb_DESCRIPTION(j),
  lb_RELEASE_TIME_FENCE_CODE(j),
  lb_RELEASE_TIME_FENCE_DAYS(j),
  lb_IN_SOURCE_PLAN(j),
  lb_REVISION(j),
  lb_SR_CATEGORY_ID(j),
  lb_CATEGORY_NAME(j),
  lb_ABC_CLASS_ID(j),
  lb_ABC_CLASS_NAME(j),
  lb_MRP_PLANNING_CODE(j),
  lb_FIXED_LEAD_TIME(j),
  lb_VARIABLE_LEAD_TIME(j),
  lb_PREPROCESSING_LEAD_TIME(j),
  lb_POSTPROCESSING_LEAD_TIME(j),
  lb_FULL_LEAD_TIME(j),
  lb_CUMULATIVE_TOTAL_LEAD_TIME(j),
  lb_CUM_MANUFACTURING_LEAD_TIME(j),
  lb_UOM_CODE(j),
  lb_UNIT_WEIGHT(j),
  lb_UNIT_VOLUME(j),
  lb_WEIGHT_UOM(j),
  lb_VOLUME_UOM(j),
  lb_PRODUCT_FAMILY_ID(j),
  lb_ATP_RULE_ID(j),
  lb_ATP_COMPONENTS_FLAG(j),
  lb_BUILT_IN_WIP_FLAG(j),
  lb_PURCHASING_ENABLED_FLAG(j),
  lb_PLANNING_MAKE_BUY_CODE(j),
  lb_REPETITIVE_TYPE(j),
  lb_REPETITIVE_VARIANCE_DAYS(j),
  lb_STANDARD_COST(j),
  lb_CARRYING_COST(j),
  lb_ORDER_COST(j),
  lb_DMD_LATENESS_COST(j),
  lb_SS_PENALTY_COST(j),
  lb_SUPPLIER_CAP_OVERUTIL_COST(j),
  lb_LIST_PRICE(j),
  lb_AVERAGE_DISCOUNT(j),
  lb_ENGINEERING_ITEM_FLAG(j),
  lb_INVENTORY_ITEM_FLAG(j),
  lb_WIP_SUPPLY_TYPE(j),
  lb_MRP_SAFETY_STOCK_CODE(j),
  lb_MRP_SAFETY_STOCK_PERCENT(j),
  lb_SAFETY_STOCK_BUCKET_DAYS(j),
  lb_BUYER_NAME(j),
  lb_PLANNER_CODE(j),
  lb_PLANNING_EXCEPTION_SET(j),
  lb_EXCESS_QUANTITY(j),
  lb_SHORTAGE_TYPE(j),
  lb_EXCEPTION_SHORTAGE_DAYS(j),
  lb_EXCESS_TYPE(j),
  lb_EXCEPTION_EXCESS_DAYS(j),
  lb_EXCEPTION_OVERPROMISED_DAYS(j),
  lb_BOM_ITEM_TYPE(j),
  lb_ATO_FORECAST_CONTROL(j),
  lb_EFFECTIVITY_CONTROL(j),
  lb_ORGANIZATION_CODE(j),
  lb_ACCEPTABLE_RATE_INCREASE(j),
  lb_ACCEPTABLE_RATE_DECREASE(j),
  lb_INVENTORY_PLANNING_CODE(j),
  lb_ACCEPTABLE_EARLY_DELIVERY(j),
  lb_MRP_CALCULATE_ATP_FLAG(j),
  lb_END_ASSEMBLY_PEGGING_FLAG(j),
  lb_BASE_ITEM_ID(j),
  lb_PRIMARY_SUPPLIER_ID(j),
  lb_ATP_FLAG(j),
  lb_NEW_ATP_FLAG(j),
  lb_REVISION_QTY_CONTROL_CODE(j),
  lb_EXPENSE_ACCOUNT(j),
  lb_INVENTORY_ASSET_FLAG(j),
  lb_BUYER_ID(j),
  lb_SOURCE_ORG_ID(j),
  lb_MATERIAL_COST(j),
  lb_RESOURCE_COST(j),
  lb_REPLENISH_TO_ORDER_FLAG(j),
  lb_PICK_COMPONENTS_FLAG(j),
  lb_YIELD_CONV_FACTOR(j),
  lb_PIP_FLAG(j),
  lb_REDUCE_MPS(j),
  lb_CRITICAL_COMPONENT_FLAG(j),
  lb_VMI_MINIMUM_UNITS(j),
  lb_VMI_MINIMUM_DAYS(j),
  lb_VMI_MAXIMUM_UNITS(j),
  lb_VMI_MAXIMUM_DAYS(j),
  lb_VMI_FIXED_ORDER_QUANTITY(j),
  lb_SO_AUTHORIZATION_FLAG(j),
  lb_CONSIGNED_FLAG(j),
  lb_ASN_AUTOEXPIRE_FLAG(j),
  lb_VMI_FORECAST_TYPE(j),
  lb_FORECAST_HORIZON(j),
  lb_BUDGET_CONSTRAINED(j),
  lb_DAYS_TGT_INV_SUPPLY(j),
  lb_DAYS_TGT_INV_WINDOW(j),
  lb_DAYS_MAX_INV_SUPPLY(j),
  lb_DAYS_MAX_INV_WINDOW(j),
  lb_DRP_PLANNED(j),
  lb_CONTINOUS_TRANSFER(j),
  lb_CONVERGENCE(j),
  lb_DIVERGENCE(j),
  lb_SOURCE_TYPE(j),
  lb_SUBSTITUTION_WINDOW(j),
  lb_CREATE_SUPPLY_FLAG(j),
  lb_SERIAL_NUMBER_CONTROL_CODE(j),
  lb_SR_INVENTORY_ITEM_ID(j),
  lb_ITEM_CREATION_DATE(j),
  lb_SR_INSTANCE_ID(j),
  lb_EAM_ITEM_TYPE(j),
  lb_REPAIR_LEAD_TIME(j),  --# For Bug 5606037 SRP Changes
  lb_PRE_POSITIONING_POINT(j),
  lb_REPAIR_YIELD(j),
  lb_REPAIR_PROGRAM(j),
  MSC_CL_COLLECTION.v_last_collection_id,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  MSC_CL_COLLECTION.v_current_date,
  MSC_CL_COLLECTION.v_current_user,
  lb_PEGGING_DEMAND_WINDOW_DAYS(j),
  lb_PEGGING_SUPPLY_WINDOW_DAYS(j);

END IF;
END IF;
 IF ( lv_MSC_CONFIGURATION = MSC_UTIL.G_CONF_APS_SCE OR
       lv_MSC_CONFIGURATION = MSC_UTIL.G_CONF_SCE) THEN
  UPDATE MSC_ITEMS
     SET description= lb_DESCRIPTION(j)
    WHERE inventory_item_id = lb_INVENTORY_ITEM_ID(j);
 END IF;
  c_count:= c_count+1;

  IF c_count>MSC_CL_COLLECTION.PBS THEN

     COMMIT;

     c_count:= 0;

  END IF;

EXCEPTION
   WHEN OTHERS THEN
    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_ITEM');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SYSTEM_ITEMS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE

      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_ITEM');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SYSTEM_ITEMS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ITEM_NAME');
      FND_MESSAGE.SET_TOKEN('VALUE', ITEM_NAME( lb_INVENTORY_ITEM_ID(j)));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
      FND_MESSAGE.SET_TOKEN('VALUE',
                            MSC_GET_NAME.ORG_CODE( lb_ORGANIZATION_ID(j),
                                                   MSC_CL_COLLECTION.v_instance_id));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'SR_INVENTORY_ITEM_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(lb_SR_INVENTORY_ITEM_ID(j)));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;
END LOOP;
END LOOP;
END IF;
CLOSE c1;
COMMIT;

END IF;

BEGIN

IF ((MSC_CL_COLLECTION.v_coll_prec.org_group_flag <> MSC_UTIL.G_ALL_ORGANIZATIONS) AND (MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES)) THEN

lv_tbl:= 'SYSTEM_ITEMS_'||MSC_CL_COLLECTION.v_INSTANCE_CODE;

lv_sql_stmt:=
         'INSERT INTO '||lv_tbl
          ||' SELECT * from MSC_SYSTEM_ITEMS'
          ||' WHERE sr_instance_id = '||MSC_CL_COLLECTION.v_instance_id
          ||' AND plan_id = -1 '
          ||' AND organization_id not '||MSC_UTIL.v_in_org_str;

   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The sql statement is '||lv_sql_stmt);
   EXECUTE IMMEDIATE lv_sql_stmt;

   COMMIT;

END IF;

IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   MSC_CL_COLLECTION.alter_temp_table (lv_errbuf,
   	              lv_retcode,
                      'MSC_SYSTEM_ITEMS',
                      MSC_CL_COLLECTION.v_INSTANCE_CODE,
                      MSC_UTIL.G_ERROR
                     );

   IF lv_retcode = MSC_UTIL.G_ERROR THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_errbuf);
      RAISE MSC_CL_COLLECTION.ALTER_TEMP_TABLE_ERROR;
   ELSIF lv_retcode = MSC_UTIL.G_WARNING THEN
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;
   END IF;

END IF;

/*call to insert ASL */
 IF ( NOT MSC_CL_COLLECTION.v_is_legacy_refresh) THEN
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'ADD_NEW_IMPL_ITEM_ASL PROCEDURE BEING CALLED FROM ITEM PROCEDURE ');
		ADD_NEW_IMPL_ITEM_ASL;
 END IF ;

EXCEPTION
  WHEN OTHERS THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
END;
COMMIT;

   END LOAD_ITEM;




END MSC_CL_ITEM_ODS_LOAD;

/
