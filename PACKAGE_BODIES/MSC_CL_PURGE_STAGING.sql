--------------------------------------------------------
--  DDL for Package Body MSC_CL_PURGE_STAGING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_PURGE_STAGING" AS
/* $Header: MSCCLPSB.pls 120.5.12010000.4 2009/08/27 14:05:19 arusubra ship $ */


    v_batch_size        NUMBER ;
    v_debug             NUMBER;
    v_applsys_schema    VARCHAR2(32);
    v_program_status    NUMBER := G_SUCCESS;


  -- Declaring the Private Procedures
  PROCEDURE delete_records (   p_instance_code IN VARCHAR2 , p_del_rej_rec IN NUMBER );

  -- Declaring the Private Functions
  FUNCTION is_purge_possible (  ERRBUF  OUT NOCOPY VARCHAR2, RETCODE  OUT NOCOPY NUMBER, pINSTANCE_CODE   IN  VARCHAR2 , pINSTANCE_ID IN NUMBER   )
  RETURN BOOLEAN;


  /*========================================================================================+
  | DESCRIPTION  : This procedure is called to delete the records for a particular          |
  |                instance from all the tables from lookup type MSC_X_SETUP_ENTITY_CODE    |
  +========================================================================================*/

  PROCEDURE delete_records ( p_instance_code IN VARCHAR2 , p_del_rej_rec IN NUMBER )
  AS

  lv_instance_code VARCHAR2(5);
  lv_p_del_rej_rec NUMBER;


  lv_tablename FND_LOOKUP_VALUES.attribute1%Type;
  lv_errtxt VARCHAR2(300);

  lv_total number :=0; -- total number of rows deleted

  CURSOR table_names IS
  SELECT DISTINCT (LV.ATTRIBUTE1) TABLE_NAME
  FROM   FND_LOOKUP_VALUES LV
  WHERE LV.ENABLED_FLAG          = 'Y'
  AND LV.VIEW_APPLICATION_ID   = 700
  AND   SUBSTR  (LV.ATTRIBUTE1, 1, 3)  = 'MSC'
  AND nvl(LV.ATTRIBUTE4,2) = 2
  AND LV.LOOKUP_TYPE           = 'MSC_X_SETUP_ENTITY_CODE';

  lv_sql_stmt VARCHAR2(500);


  table_not_found EXCEPTION;
  PRAGMA EXCEPTION_INIT (table_not_found,-00942);

  synonym_translation_invalid EXCEPTION;
  PRAGMA EXCEPTION_INIT (synonym_translation_invalid,-00980);

  BEGIN


  lv_instance_code := p_instance_code;
  lv_p_del_rej_rec :=p_del_rej_rec;
  v_batch_size := TO_NUMBER(NVL(FND_PROFILE.VALUE('MRP_PURGE_BATCH_SIZE'),75000));


        OPEN table_names;
        LOOP
          lv_total := 0;
          FETCH table_names INTO lv_tablename;
          EXIT WHEN table_names%NOTFOUND;
           loop

             IF ( lv_tablename = 'MSC_ST_PROFILES' ) THEN
                IF ( lv_p_del_rej_rec = SYS_YES ) THEN
                   lv_sql_stmt := 'DELETE FROM '||lv_tablename||' WHERE ROWNUM <= '||v_batch_size||'  AND PROCESS_FLAG IN ( '||G_ERROR_FLG||','||G_PROPAGATION||')';
                ELSE
                   lv_sql_stmt := 'DELETE FROM '||lv_tablename||' WHERE ROWNUM <= '||v_batch_size||'';
                END IF;
             ELSE
                IF ( lv_p_del_rej_rec = SYS_YES ) THEN
                   lv_sql_stmt := 'DELETE FROM '||lv_tablename||' WHERE SR_INSTANCE_CODE= '''||lv_instance_code||'''  AND ROWNUM <= '||v_batch_size||'  AND PROCESS_FLAG IN ( '||G_ERROR_FLG||','||G_PROPAGATION||')';
                ELSE
                   lv_sql_stmt := 'DELETE FROM '||lv_tablename||' WHERE SR_INSTANCE_CODE= '''||lv_instance_code||''' AND ROWNUM <= '||v_batch_size||'';
                END IF;
             END IF;



                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Sql statements executed-'||lv_sql_stmt);



                BEGIN
                 EXECUTE IMMEDIATE lv_sql_stmt;

                EXCEPTION

                   WHEN table_not_found THEN
                   lv_errtxt := substr(SQLERRM,1,240) ;
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_WARNING,lv_errtxt);
                   exit;

                   WHEN synonym_translation_invalid THEN
                   lv_errtxt := substr(SQLERRM,1,240) ;
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_WARNING,lv_errtxt);
                   exit;

                   WHEN OTHERS THEN
                   lv_errtxt := substr(SQLERRM,1,240) ;
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_WARNING,lv_errtxt);
                   exit;

                END;

                lv_total := lv_total+SQL%ROWCOUNT ;

             EXIT WHEN SQL%NOTFOUND;

            COMMIT;
           end loop;

                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'No. of rows deleted from '|| lv_tablename ||' - '||lv_total);


        END LOOP;
        CLOSE table_names;


  EXCEPTION

  WHEN OTHERS THEN

  lv_errtxt := substr(SQLERRM,1,240) ;
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_WARNING,lv_errtxt);

  END delete_records;


  /*========================================================================================+
  | DESCRIPTION  : This fuction is called to check whether the st_status for a particular   |
  |                instance is not in PULLING , LOADING and PRE-PROCESSING                  |
  +========================================================================================*/


  FUNCTION is_purge_possible ( ERRBUF  OUT NOCOPY VARCHAR2, RETCODE  OUT NOCOPY NUMBER, pINSTANCE_CODE   IN  VARCHAR2 , pINSTANCE_ID IN NUMBER )
  RETURN BOOLEAN
  AS
  lv_staging_table_status NUMBER;

  BEGIN

     SELECT ST_STATUS INTO lv_staging_table_status
     FROM msc_apps_instances
     WHERE INSTANCE_CODE= pINSTANCE_CODE
     FOR UPDATE;

            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Entered to check whether purge possible for the instance-'||pINSTANCE_CODE);




           IF lv_staging_table_status=  G_ST_PULLING THEN
              FND_MESSAGE.SET_NAME('MSC', 'MSC_ST_ERROR_PULLING');
              ERRBUF:= FND_MESSAGE.GET;

                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,ERRBUF);


                IF ( pINSTANCE_ID <> -1 )
                THEN
                   v_program_status :=G_ERROR;

                ELSE
                   v_program_status :=G_WARNING;

                END IF;

                RETURN FALSE;


           ELSIF lv_staging_table_status= G_ST_COLLECTING THEN
              FND_MESSAGE.SET_NAME('MSC', 'MSC_ST_ERROR_LOADING');
              ERRBUF:= FND_MESSAGE.GET;

             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,ERRBUF);


                IF ( pINSTANCE_ID <> -1 )
                THEN
                   v_program_status :=G_ERROR;

                ELSE
                   v_program_status :=G_WARNING;

                END IF;

                RETURN FALSE;

           ELSIF lv_staging_table_status= G_ST_PRE_PROCESSING THEN
              FND_MESSAGE.SET_NAME('MSC', 'MSC_ST_ERROR_PRE_PROCESSING');
              ERRBUF:= FND_MESSAGE.GET;

                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,ERRBUF);


                IF ( pINSTANCE_ID <> -1 )
                THEN
                   v_program_status :=G_ERROR;

                ELSE
                   v_program_status :=G_WARNING;

                END IF;

                RETURN FALSE;


           ELSE
              UPDATE msc_apps_instances
              SET st_status=G_ST_PURGING
              WHERE INSTANCE_CODE= pINSTANCE_CODE;
              COMMIT;

              RETURN TRUE;

           END IF;


  END is_purge_possible;

  /*=============================================================================================+
  | DESCRIPTION  : This is the main program that deletes the records from the MSC staging        |
  |                tables.It takes instance_code as a parameter and deletes records for the      |
  |                instance only when st_status for this instance is not in G_ST_PULLING,        |
  |                G_ST_COLLECTING  and G_ST_PRE_PROCESSING .If the instance_code is null        |
  |                then it will delete records from all instances after checking the st_status.  |
  |                It also takes a parameter , whether to delete only errored out records or     |
  |                all legacy data (st_status check before deletion will only take place         |
  |                when 'delete only rejected records parameter is set to NO).                   |
  +=============================================================================================*/


  PROCEDURE launch_purge (  ERRBUF  OUT NOCOPY VARCHAR2,
                          RETCODE  OUT NOCOPY NUMBER,
                          p_instance_id IN NUMBER,
                          p_del_rej_rec IN NUMBER )

  AS

  CURSOR table_names IS
  SELECT DISTINCT (LV.ATTRIBUTE1) TABLE_NAME
  FROM   FND_LOOKUP_VALUES LV
  WHERE LV.ENABLED_FLAG          = 'Y'
  AND LV.VIEW_APPLICATION_ID   = 700
  AND   SUBSTR  (LV.ATTRIBUTE1, 1, 3)  = 'MSC'
  AND LV.LOOKUP_TYPE           = 'MSC_X_SETUP_ENTITY_CODE';

  CURSOR instance_codes ( cp_instance_id NUMBER ) IS
  SELECT instance_code,instance_type,st_status
  FROM msc_apps_instances
  WHERE instance_id=cp_instance_id
  UNION ALL
  SELECT instance_code,instance_type,st_status
  FROM msc_apps_instances
  WHERE cp_instance_id =-1;

  -- Cursor P and q are for update to lock the records before checking for the st_status.
  CURSOR p IS
  SELECT instance_code
  FROM msc_apps_instances
  WHERE st_status NOT IN (G_ST_PULLING,G_ST_COLLECTING,G_ST_PRE_PROCESSING)
  FOR UPDATE;

  CURSOR q (cp_instance_id NUMBER ) IS
  SELECT instance_code
  FROM msc_apps_instances
  WHERE st_status NOT IN (G_ST_PULLING,G_ST_COLLECTING,G_ST_PRE_PROCESSING)
  AND instance_id=cp_instance_id
  FOR UPDATE;

  -- input variables of procedure
  lv_p_del_rej_rec  NUMBER;
  lv_p_instance_id NUMBER ;

  -- variable for cursor table_names
  lv_table_name   FND_LOOKUP_VALUES.attribute1%Type;

  -- variable for cursor instance_codes
  lv_p_instance_code VARCHAR2(5);
  lv_st_status NUMBER;
  lv_instance_type NUMBER;

  lv_inst_flag  NUMBER := 0 ;
  lv_leg_inst_flag  NUMBER := 0;
  lv_st_status_flag NUMBER := 0;
  lv_trunc_profile NUMBER := SYS_NO;

  lv_trunc_flag NUMBER := SYS_NO;

  lv_sql_stmt VARCHAR2(500);
  lv_errtxt VARCHAR2(300);

  lv_retval boolean;
  lv_dummy1 varchar2(32);
  lv_dummy2 varchar2(32);

  table_not_found EXCEPTION;
  PRAGMA EXCEPTION_INIT (table_not_found,-00942);


  BEGIN


  lv_p_instance_id := nvl( p_instance_id ,-1);
  lv_p_del_rej_rec :=p_del_rej_rec;


  OPEN table_names;
  FETCH table_names INTO lv_table_name;
  IF ( table_names%ROWCOUNT = 0 ) THEN
          FND_MESSAGE.SET_NAME('MSC','MSC_PS_INVALID_LOOKUP');
          ERRBUF:= FND_MESSAGE.GET;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_WARNING,ERRBUF);
          v_program_status := G_ERROR;

          CLOSE table_names;
  ELSE      -- IF ( table_names%ROWCOUNT = 0 ) THEN


    CLOSE table_names;
    SELECT DECODE(nvl(FND_PROFILE.VALUE('MRP_DEBUG'),'N'),'Y',1,2),
        DECODE(nvl(FND_PROFILE.VALUE('MSC_PURGE_ST_CONTROL'),'No'),'Yes',1,2)
        INTO v_debug,lv_trunc_profile
    FROM dual;


    IF (lv_trunc_profile = SYS_YES AND lv_p_del_rej_rec=SYS_NO ) THEN
       SELECT count(*) INTO lv_leg_inst_flag  FROM msc_apps_instances WHERE instance_type = G_INS_OTHER ;
       SELECT count(*) INTO lv_inst_flag  FROM msc_apps_instances;

        -- locking the records in msc_apps_instances before checking the st_status
                  IF (lv_p_instance_id <> -1) THEN
                      open q(lv_p_instance_id);
                      close q;
                  ELSE
                      open p;
                      close p;
                  END IF;
       -- Counting number of instances for which st_status is G_ST_PULLING , G_ST_COLLECTING and G_ST_PRE_PROCESSING
       SELECT count(*) INTO lv_st_status_flag FROM msc_apps_instances WHERE st_status IN ( G_ST_PULLING,G_ST_COLLECTING,G_ST_PRE_PROCESSING ) AND ((instance_id=lv_p_instance_id) OR (lv_p_instance_id=-1));

             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Value of lv_st_status_flag-'||lv_st_status_flag);

    END IF;

    -- Setting the truncation flag
    IF ( (lv_p_del_rej_rec  = SYS_NO ) AND ( lv_trunc_profile  = SYS_YES ) AND ((lv_p_instance_id  = -1) OR (lv_inst_flag = 1)) AND (lv_leg_inst_flag  = lv_inst_flag) AND (lv_st_status_flag = 0) )
    THEN
         lv_trunc_flag :=SYS_YES;
    ELSE
         lv_trunc_flag :=SYS_NO;
    END IF;


    IF (lv_trunc_flag=SYS_YES) THEN

           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Truncation flag is YES. Entering in truncation LOOP');


           UPDATE msc_apps_instances
           SET st_status= G_ST_PURGING;
           COMMIT;

           lv_retval := FND_INSTALLATION.GET_APP_INFO ( 'MSC', lv_dummy1, lv_dummy2, v_applsys_schema);

        OPEN table_names;


             LOOP
               FETCH table_names INTO lv_table_name;
                  EXIT WHEN table_names%NOTFOUND;
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_table_name);



                BEGIN
                lv_sql_stmt := 'TRUNCATE TABLE '||v_applsys_schema||'.'||lv_table_name|| '';

                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Sql statements to be executed-'||lv_sql_stmt);




               EXECUTE IMMEDIATE lv_sql_stmt;

               EXCEPTION

               WHEN table_not_found THEN
               lv_errtxt := substr(SQLERRM,1,240) ;
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_WARNING,lv_errtxt);


               WHEN OTHERS THEN
               lv_errtxt := substr(SQLERRM,1,240) ;
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_WARNING,lv_errtxt);


               END;

             END LOOP;
        CLOSE table_names;

           UPDATE msc_apps_instances
           SET st_status= G_ST_EMPTY;
           COMMIT;

  ELSE

           commit;  -- To break the lock on the records, acquired while opening the cursor p or q

            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Truncation flag is NO. Entered in DELETION LOOP');


     OPEN instance_codes(lv_p_instance_id);
         LOOP
         FETCH instance_codes INTO lv_p_instance_code,lv_instance_type,lv_st_status;
            EXIT WHEN instance_codes%NOTFOUND;

            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_p_instance_code);


             IF (lv_p_del_rej_rec=SYS_YES) THEN

              MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Deleting without checking the ST_STATUS');




               delete_records( lv_p_instance_code,lv_p_del_rej_rec);

             ELSE


                 IF ( is_purge_possible( ERRBUF,RETCODE,lv_p_instance_code,lv_p_instance_id) ) THEN


                      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Deleting after checking the ST_STATUS');


                      delete_records(lv_p_instance_code,lv_p_del_rej_rec);


                      IF ( lv_instance_type = G_INS_OTHER ) THEN

                         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,' Instance type is LEGACY ,so setting st_status to empty');


                         UPDATE msc_apps_instances
                         SET st_status=G_ST_EMPTY
                         WHERE instance_code=lv_p_instance_code;
                         COMMIT;

                      ELSE

                         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Instance type is ERP ,so setting st_status to previous st_status-'||lv_st_status);


                         UPDATE msc_apps_instances
                         SET st_status=lv_st_status
                         WHERE instance_code=lv_p_instance_code;
                         COMMIT;

                      END IF;


              END IF;
         END IF;

         END LOOP;
     CLOSE instance_codes;
 END IF;
 END IF;   --  IF ( table_names%ROWCOUNT = 0 ) THEN

  IF v_program_status=G_WARNING THEN
     RETCODE := G_WARNING;
  ELSIF v_program_status=G_ERROR THEN
     RETCODE := G_ERROR;
  END IF;


EXCEPTION

  WHEN OTHERS THEN
  ERRBUF  := SQLERRM;
  RETCODE := SQLCODE;

  lv_errtxt := substr(SQLERRM,1,240) ;
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_WARNING,lv_errtxt);

END launch_purge;

--===================================================================
PROCEDURE PURGE_STAGING_TABLES_TRNC( p_instance_id    IN  NUMBER) IS



BEGIN



   ---------------- CALENDAR --------------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE('MSC_ST_CALENDAR_ASSIGNMENTS');

      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE('MSC_ST_CALENDAR_SHIFTS');

   ---------------- BOM --------------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_BOM_COMPONENTS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_BOMS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_CO_PRODUCTS'); -- for OSFM Integration (bug fix 2377866)



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_COMPONENT_SUBSTITUTES');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_ROUTINGS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_ROUTING_OPERATIONS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_OPERATION_RESOURCES');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_OPERATION_RESOURCE_SEQS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_OPERATION_NETWORKS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_PROCESS_EFFECTIVITY');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_OPERATION_COMPONENTS');



   ---------------- BOR -------------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_BILL_OF_RESOURCES');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_BOR_REQUIREMENTS');



   ---------------- CALENDAR_DATE -------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_CALENDAR_DATES');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_PERIOD_START_DATES');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_CAL_YEAR_START_DATES');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_CAL_WEEK_START_DATES');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_RESOURCE_SHIFTS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_CALENDAR_SHIFTS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_SHIFT_DATES');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_RESOURCE_CHANGES');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_SHIFT_TIMES');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_SHIFT_EXCEPTIONS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_NET_RESOURCE_AVAIL');



   ----------------  CATEGORY -------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_ITEM_CATEGORIES');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_CATEGORY_SETS');



   ----------------  DEMAND -------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_DEMANDS');



   ----------------  SALES ORDER -------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_SALES_ORDERS');



   ----------------  HARD RESERVATION -------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_RESERVATIONS');



   ----------------  ITEM -------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_SYSTEM_ITEMS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_ABC_CLASSES');



   ----------------- ITEM SUBSTITUTES -------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE('MSC_ST_ITEM_SUBSTITUTES');



   ----------------  RESOURCE -------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_DEPARTMENT_RESOURCES');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_SIMULATION_SETS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_RESOURCE_GROUPS');



   ----------------  SAFETY STOCK-------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_SAFETY_STOCKS');



   ----------------  SCHEDULE DESIGNATOR -------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_DESIGNATORS');



   ----------------  SOURCING -------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_ASSIGNMENT_SETS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_SOURCING_RULES');



      /* delete FROM MSC_ST_SR_ASSIGNMENTS

      // WHERE SR_ASSIGNMENT_INSTANCE_ID= p_instance_id;

      */



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_SR_ASSIGNMENTS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_SR_RECEIPT_ORG');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_SR_SOURCE_ORG');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_INTERORG_SHIP_METHODS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_REGIONS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_ZONE_REGIONS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_REGION_LOCATIONS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_REGION_SITES');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_CARRIER_SERVICES');



   ---------------- SUB INVENTORY -------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_SUB_INVENTORIES');



   ----------------  SUPPLIER CAPACITY -------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_ITEM_SUPPLIERS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_SUPPLIER_CAPACITIES');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_SUPPLIER_FLEX_FENCES');



   ---------------- SUPPLY -------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_SUPPLIES');



   ---------------- RESOURCE REQUIREMENT -------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_RESOURCE_REQUIREMENTS');



   ---------------- TRADING PARTNER -------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_TRADING_PARTNERS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_TRADING_PARTNER_SITES');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_LOCATION_ASSOCIATIONS');



   ---------------- UNIT NUMBER -------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_UNIT_NUMBERS');



   ---------------- PROJECT -------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_PROJECTS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_PROJECT_TASKS');



   ---------------- PARAMETER -------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_PARAMETERS');



   ---------------- UOM -------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_UNITS_OF_MEASURE');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_UOM_CLASS_CONVERSIONS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_UOM_CONVERSIONS');



   ---------------- BIS -------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_BIS_PFMC_MEASURES');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_BIS_TARGET_LEVELS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_BIS_TARGETS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_BIS_BUSINESS_PLANS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_BIS_PERIODS');



   ---------------- ATP RULES -------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_ATP_RULES');



   ---------------- PLANNERS -------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_PLANNERS');



   ---------------- DEMAND CLASS -------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_DEMAND_CLASSES');



   ---------------- PARTNER CONTACTS -----------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_PARTNER_CONTACTS');



   ---------------- LEGACY TABLES --------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_ITEM_SOURCING');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_CALENDARS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_WORKDAY_PATTERNS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_CALENDAR_EXCEPTIONS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_GROUPS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_GROUP_COMPANIES');



   -------------  JOB DETAILS ---------------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_JOB_OPERATION_NETWORKS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_JOB_OPERATIONS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_JOB_REQUIREMENT_OPS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_JOB_OP_RESOURCES');



      /* SCE Change starts */

      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_COMPANY_USERS');

      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_ITEM_CUSTOMERS');

      /* SCE Change ends */



      -------------- TRIP TABLES ---------------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_TRIPS');



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_TRIP_STOPS');



      --------- PROFILE TABLES --------------



      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_APPS_INSTANCES');



	/* ds_change: start */

	MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_DEPT_RES_INSTANCES');

	MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_NET_RES_INST_AVAIL');

	MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_JOB_OP_RES_INSTANCES');

	MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_RESOURCE_INSTANCE_REQS');

	MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_RESOURCE_SETUPS');

	MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_SETUP_TRANSITIONS');

	MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_STD_OP_RESOURCES');

	MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_RES_INSTANCE_CHANGES');

	MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_RESOURCE_CHARGES');

	/* ds_change: end */



			---------------- SR LOOKUPS -------------

  MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_SR_LOOKUPS');



    ----------------- FISCAL CALENDAR ------------------

  MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_ST_CALENDAR_MONTHS');



END PURGE_STAGING_TABLES_TRNC;



-- =========== Purge Tables by Deleting them ==============



PROCEDURE PURGE_STAGING_TABLES_DEL( p_instance_id     IN  NUMBER) IS



BEGIN



   ---------------- CALENDAR --------------------



      MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_ST_CALENDAR_ASSIGNMENTS', p_instance_id, NULL);



      COMMIT;





   ---------------- BOM --------------------



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_BOM_COMPONENTS', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_BOMS', p_instance_id, NULL);



      COMMIT;



      -- for OSFM Integration (bug fix 2377866)

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_CO_PRODUCTS', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_COMPONENT_SUBSTITUTES', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_ROUTINGS', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_ROUTING_OPERATIONS', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_OPERATION_RESOURCES', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_OPERATION_RESOURCE_SEQS', p_instance_id, NULL);



      MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_ST_OPERATION_NETWORKS',p_instance_id,NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_PROCESS_EFFECTIVITY', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_OPERATION_COMPONENTS', p_instance_id, NULL);



      COMMIT;



   ---------------- BOR -------------------



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_BILL_OF_RESOURCES', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_BOR_REQUIREMENTS', p_instance_id, NULL);



      COMMIT;



   ---------------- CALENDAR_DATE -------------



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_CALENDAR_DATES', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_PERIOD_START_DATES', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_CAL_YEAR_START_DATES', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_CAL_WEEK_START_DATES', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_RESOURCE_SHIFTS', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_CALENDAR_SHIFTS', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_SHIFT_DATES', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_RESOURCE_CHANGES', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_SHIFT_TIMES', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_SHIFT_EXCEPTIONS', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_NET_RESOURCE_AVAIL', p_instance_id, NULL);



     COMMIT;



   ----------------  CATEGORY -------------

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_ITEM_CATEGORIES', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_CATEGORY_SETS', p_instance_id, NULL);



      COMMIT;



   ----------------  DEMAND -------------

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_DEMANDS', p_instance_id, NULL);



      COMMIT;



   ----------------  SALES ORDER -------------

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_SALES_ORDERS', p_instance_id, NULL);



      COMMIT;



   ----------------  HARD RESERVATION -------------

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_RESERVATIONS', p_instance_id, NULL);



      COMMIT;



   ----------------  ITEM -------------

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_SYSTEM_ITEMS', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_SYSTEM_ITEMS', p_instance_id, NULL);



      COMMIT;



   ----------------- ITEM SUBSTITUTES -------------



      MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_ST_ITEM_SUBSTITUTES',p_instance_id, NULL);



      COMMIT;



   ----------------  RESOURCE -------------

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_DEPARTMENT_RESOURCES', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_SIMULATION_SETS', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_RESOURCE_GROUPS', p_instance_id, NULL);



      COMMIT;

   ----------------  SAFETY STOCK-------------



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_SAFETY_STOCKS', p_instance_id, NULL);



      COMMIT;



   ----------------  SCHEDULE DESIGNATOR -------------

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_DESIGNATORS', p_instance_id, NULL);



      COMMIT;



   ----------------  SOURCING -------------

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_ASSIGNMENT_SETS', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_SOURCING_RULES', p_instance_id, NULL);



      COMMIT;



      DELETE FROM MSC_ST_SR_ASSIGNMENTS

       WHERE SR_ASSIGNMENT_INSTANCE_ID= p_instance_id;



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_SR_RECEIPT_ORG', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_SR_SOURCE_ORG', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_INTERORG_SHIP_METHODS', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_REGIONS', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_ZONE_REGIONS', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_REGION_LOCATIONS', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_REGION_SITES', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_CARRIER_SERVICES', p_instance_id, NULL);



      COMMIT;

   ---------------- SUB INVENTORY -------------

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_SUB_INVENTORIES', p_instance_id, NULL);



      COMMIT;



   ----------------  SUPPLIER CAPACITY -------------

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_ITEM_SUPPLIERS', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_SUPPLIER_CAPACITIES', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_SUPPLIER_FLEX_FENCES', p_instance_id, NULL);



      COMMIT;



   ---------------- SUPPLY -------------

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_SUPPLIES', p_instance_id, NULL);



      COMMIT;



   ---------------- RESOURCE REQUIREMENT -------------

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_RESOURCE_REQUIREMENTS', p_instance_id, NULL);



      COMMIT;



   ---------------- TRADING PARTNER -------------

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_TRADING_PARTNERS', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_TRADING_PARTNER_SITES', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_LOCATION_ASSOCIATIONS', p_instance_id, NULL);



      COMMIT;



   ---------------- UNIT NUMBER -------------

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_UNIT_NUMBERS', p_instance_id, NULL);



      COMMIT;

   ---------------- PROJECT -------------

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_PROJECTS', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_PROJECT_TASKS', p_instance_id, NULL);



      COMMIT;



   ---------------- PARAMETER -------------

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_PARAMETERS', p_instance_id, NULL);



      COMMIT;



   ---------------- UOM -------------

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_UNITS_OF_MEASURE', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_UOM_CLASS_CONVERSIONS', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_UOM_CONVERSIONS', p_instance_id, NULL);



      COMMIT;



   ---------------- BIS -------------

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_BIS_PFMC_MEASURES', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_BIS_TARGET_LEVELS', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_BIS_TARGETS', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_BIS_BUSINESS_PLANS', p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_BIS_PERIODS', p_instance_id, NULL);



      COMMIT;



   ---------------- ATP RULES -------------

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_ATP_RULES', p_instance_id, NULL);



      COMMIT;



   ---------------- PLANNERS -------------

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_PLANNERS', p_instance_id, NULL);



      COMMIT;



   ---------------- DEMAND CLASS -------------

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_DEMAND_CLASSES', p_instance_id, NULL);



      COMMIT;



   ---------------- PARTNER CONTACTS -----------

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_PARTNER_CONTACTS', p_instance_id, NULL);



      COMMIT;



   ---------------- LEGACY TABLES --------------

        MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_ST_ITEM_SOURCING',p_instance_id, NULL);



        COMMIT;



        MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_ST_CALENDARS',p_instance_id, NULL);



        COMMIT;



        MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_ST_WORKDAY_PATTERNS',p_instance_id, NULL);



        COMMIT;



        MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_ST_CALENDAR_EXCEPTIONS',p_instance_id, NULL);



        COMMIT;



        MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_ST_GROUPS',p_instance_id, NULL);



        COMMIT;



        MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_ST_GROUP_COMPANIES',p_instance_id, NULL);



        COMMIT;



        /* SCE change starts */

        MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_ST_COMPANY_USERS', p_instance_id, NULL);



        COMMIT;



        MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_ST_ITEM_CUSTOMERS', p_instance_id, NULL);



        COMMIT;

        /* SCE change ends */



        -------------  JOB DETAILS ---------------------



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_JOB_OPERATION_NETWORKS',p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_JOB_OPERATIONS',p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_JOB_REQUIREMENT_OPS',p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_JOB_OP_RESOURCES',p_instance_id, NULL);



      COMMIT;



      -------------  TRIP  ---------------------



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_TRIPS',p_instance_id, NULL);



      COMMIT;



      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_TRIP_STOPS',p_instance_id, NULL);



      COMMIT;



     ----------- PROFILE ----------------



     MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_APPS_INSTANCES',p_instance_id, NULL);



      COMMIT;





	/* ds_change: start */

	MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_DEPT_RES_INSTANCES',p_instance_id, NULL);

	commit;

	MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_NET_RES_INST_AVAIL',p_instance_id, NULL);

	commit;

	MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_JOB_OP_RES_INSTANCES',p_instance_id, NULL);

	commit;

	MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_RESOURCE_INSTANCE_REQS',p_instance_id, NULL);

	commit;

	MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_RESOURCE_SETUPS',p_instance_id, NULL);

	commit;

	MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_SETUP_TRANSITIONS',p_instance_id, NULL);

	commit;

	MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_STD_OP_RESOURCES',p_instance_id, NULL);

        commit;

	MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_RES_INSTANCE_CHANGES',p_instance_id, NULL);

	commit;

	MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_RESOURCE_CHARGES',p_instance_id, NULL);

	commit;

	/* ds_change: end */

	   ---------------- LOOKUPS -------------

    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_SR_LOOKUPS', p_instance_id, NULL);

    COMMIT;

    ----------------------  FISCAL CALENDAR  -----------------------------

	MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_CALENDAR_MONTHS',p_instance_id, NULL);

	commit;



END PURGE_STAGING_TABLES_DEL;



PROCEDURE PURGE_STAGING_TABLES_SUB( p_instance_id IN NUMBER,
                                    p_Blind_Purge IN  NUMBER:=SYS_NO)

IS

   lv_control_flag	NUMBER;



   lv_sql_stmt 		VARCHAR2(2048);

   lv_pbs 		NUMBER;



   lv_instance_type 	NUMBER;

   lv_last_refresh_type	VARCHAR2(1);



   lv_retval 		boolean;

   lv_dummy1 		varchar2(32);

   lv_dummy2 		varchar2(32);

   lv_schema 		varchar2(30);

   lv_prod_short_name   varchar2(30);



   CURSOR c_tab_list IS

   SELECT attribute1 application_id, attribute2 table_name, attribute5 part_type
   FROM   fnd_lookup_values
   WHERE  lookup_type = 'MSC_STAGING_TABLE' AND
          enabled_flag = 'Y' AND
          view_application_id = 700 AND
          language = userenv('lang');



BEGIN
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'inside purge staging table ');

   SELECT decode(nvl(fnd_profile.value('MSC_PURGE_ST_CONTROL'),'N'),'Y',1,2)
   INTO   lv_control_flag
   FROM   dual;

   IF p_instance_id IS NOT NULL THEN
     SELECT instance_type, lrtype
     INTO   lv_instance_type, lv_last_refresh_type
     FROM   msc_apps_instances
     WHERE  instance_id= p_instance_id;
	MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'instance_type='||lv_instance_type);
   END IF;
   lv_pbs := nvl(TO_NUMBER(FND_PROFILE.VALUE('MRP_PURGE_BATCH_SIZE')), 2000);
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'before loop');
   FOR c_rec IN c_tab_list
   LOOP

      lv_prod_short_name := AD_TSPACE_UTIL.get_product_short_name(to_number(c_rec.application_id));
      lv_retval := FND_INSTALLATION.GET_APP_INFO (lv_prod_short_name, lv_dummy1, lv_dummy2, lv_schema);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'Schema name - ' || lv_schema);


       IF  (p_Blind_Purge = SYS_YES) OR
           (lv_control_flag = 1 AND lv_instance_type <> G_INS_OTHER AND c_rec.part_type <> 'L')  THEN -- do a blind purge
	lv_sql_stmt:= 'TRUNCATE TABLE ' || lv_schema || '.' || c_rec.table_name||' DROP STORAGE';
	   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'lv_sql_stmt1 - ' || lv_sql_stmt);

	   EXECUTE IMMEDIATE lv_sql_stmt;

       ELSIF (lv_instance_type = G_INS_OTHER) OR (c_rec.part_type <> 'L')  THEN
                 lv_sql_stmt:= ' DELETE ' || lv_schema || '.' || c_rec.table_name
                           || ' WHERE sr_instance_id = ' || p_instance_id
                           || ' AND rownum < ' || lv_pbs;
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'lv_sql_stmt1 - ' || lv_sql_stmt);
                LOOP
                   EXECUTE IMMEDIATE lv_sql_stmt;
                   EXIT WHEN SQL%ROWCOUNT = 0;
                   COMMIT;
                END LOOP;

      ELSE

             lv_sql_stmt:= 'ALTER TABLE ' || lv_schema || '.' || c_rec.table_name
                        || ' TRUNCATE PARTITION ' || SUBSTR(c_rec.table_name, 8) || '_' || p_instance_id;

             MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'lv_sql_stmt2 - ' || lv_sql_stmt);
             EXECUTE IMMEDIATE lv_sql_stmt;
     END IF;

END LOOP;
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'exiting purge staging table ');



EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN (-01578,-26040) THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,SQLERRM);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'To rectify this problem -');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Run concurrent program "Truncate Planning Staging Tables" ');
    END IF;
    RAISE;
END PURGE_STAGING_TABLES_SUB;
PROCEDURE TRUNCATE_STAGING_TABLES(ERRBUF               OUT NOCOPY VARCHAR2,
                                  RETCODE              OUT NOCOPY NUMBER)
AS
BEGIN
  PURGE_STAGING_TABLES_SUB( p_instance_id => NULL,
                            p_Blind_Purge => SYS_YES);
EXCEPTION
  WHEN OTHERS THEN
  RETCODE := G_ERROR;
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,SQLERRM);
  RAISE;
END TRUNCATE_STAGING_TABLES;
END msc_cl_purge_staging ;

/
