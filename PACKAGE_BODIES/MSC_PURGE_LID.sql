--------------------------------------------------------
--  DDL for Package Body MSC_PURGE_LID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_PURGE_LID" AS
/*$Header: MSCPPURB.pls 120.1.12010000.8 2009/07/08 13:03:10 lsindhur ship $ */
  v_sql_stmt PLS_INTEGER;--Holds the DML statement no used for error logging.

-- ========= Global Parameters ===========
  v_instance_id                NUMBER ;
  v_date                       DATE;
  v_debug                      BOOLEAN;

-- User Environment --
  v_current_date            DATE ;
  v_current_user            NUMBER;
  v_login_user              NUMBER;
  v_request_id              NUMBER;
  v_prog_appl_id            NUMBER;
  v_program_id              NUMBER;
  v_applsys_schema          VARCHAR2(32);
  lv_pbs NUMBER := TO_NUMBER( FND_PROFILE.VALUE('MRP_PURGE_BATCH_SIZE'));

  TYPE NmTblTyp IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;



/*=======================================================================
  This function return true if the status of staging table is ready/purging
  or empty.
=========================================================================*/

  FUNCTION   CHECK_ST_STATUS( errbuf                          OUT NOCOPY VARCHAR2,
                             retcode                          OUT NOCOPY NUMBER,
                             p_instance_id                    IN  NUMBER   )
  RETURN BOOLEAN
  IS
  lv_staging_table_status NUMBER;
  lv_instance_enabled NUMBER;

  BEGIN

    SELECT mai.enable_flag,
          mai.st_status
          INTO lv_instance_enabled, lv_staging_table_status
          FROM MSC_APPS_INSTANCES mai
          WHERE mai.INSTANCE_ID= v_instance_id
          AND   mai.instance_type IN (G_INS_OTHER,G_INS_EXCH) ;


         IF lv_instance_enabled= SYS_YES THEN

            IF lv_staging_table_status= G_ST_READY THEN

               FND_MESSAGE.SET_NAME('MSC', 'MSC_ST_ERROR_DATA_EXIST');
               ERRBUF:= FND_MESSAGE.GET;
               retcode:= G_SUCCESS ;
               RETURN TRUE ;

           ELSIF lv_staging_table_status= G_ST_PULLING  THEN
               FND_MESSAGE.SET_NAME('MSC', 'MSC_ST_ERROR_PULLING');
               errbuf:= FND_MESSAGE.GET;
               retcode:= G_ERROR ;
               RETURN FALSE ;

            ELSIF lv_staging_table_status= G_ST_COLLECTING THEN
               FND_MESSAGE.SET_NAME('MSC', 'MSC_ST_ERROR_LOADING');
               ERRBUF:= FND_MESSAGE.GET;
               retcode:= G_ERROR ;
               RETURN FALSE ;

            ELSIF lv_staging_table_status= G_ST_PURGING THEN

               FND_MESSAGE.SET_NAME('MSC', 'MSC_ST_ERROR_PURGING');
               ERRBUF:= FND_MESSAGE.GET;
               retcode:= G_SUCCESS ;
               RETURN TRUE ;

            ELSIF lv_staging_table_status= G_ST_PRE_PROCESSING THEN

               FND_MESSAGE.SET_NAME('MSC', 'MSC_ST_PRE_PROCESSING');
               ERRBUF:= FND_MESSAGE.GET;
               retcode:= G_ERROR ;
               RETURN FALSE ;

             ELSE
               retcode:= G_SUCCESS ;
               RETURN TRUE ;
            END IF;

        ELSE
           FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_INSTANCE_INACTIVE');
           errbuf:= FND_MESSAGE.GET;
           retcode:= G_ERROR;
           RETURN FALSE;
         END IF;

  EXCEPTION
    WHEN OTHERS THEN
      errbuf := SQLERRM;
      retcode := SQLCODE;
      RETURN FALSE;

  END CHECK_ST_STATUS;

   FUNCTION is_msctbl_partitioned ( p_table_name  IN  VARCHAR2)
            RETURN BOOLEAN
   IS
      lv_partitioned     VARCHAR2(3);

      CURSOR c_partitioned IS
      SELECT tab.partitioned
        FROM dba_tables tab,
             FND_ORACLE_USERID a,
             FND_PRODUCT_INSTALLATIONS b
       WHERE a.oracle_id = b.oracle_id
         AND b.application_id= 724
         AND tab.owner= a.oracle_username
         AND tab.table_name= p_table_name;

   BEGIN

      OPEN c_partitioned;
      FETCH c_partitioned INTO lv_partitioned;
      CLOSE c_partitioned;

      IF lv_partitioned='YES' THEN RETURN TRUE; END IF;
      RETURN FALSE;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN FALSE;
   END is_msctbl_partitioned;

/*=======================================================================
  This function deletes record from the MSC tables.
=========================================================================*/

  PROCEDURE DELETE_MSC_TABLE( p_table_name            IN VARCHAR2,
                              p_instance_id           IN NUMBER,
                              p_plan_id               IN NUMBER:= NULL,
                              p_sub_str               IN VARCHAR2:= NULL) IS

    lv_cnt          NUMBER;
    lv_sql_stmt     VARCHAR2(2048);

    lv_task_start_time DATE;

    lv_partition_name  VARCHAR2(30);
    lv_is_plan         NUMBER;

    lv_msg_data        VARCHAR2(2048);
    lv_return_status   VARCHAR2(2048);
    lv_errtext         VARCHAR2(2048);

    lv_retval         BOOLEAN;
    lv_dummy1       VARCHAR2(30);
    lv_dummy2       VARCHAR2(30);
     --lv_schema       VARCHAR2(30);

lv_appl_short_nm       VARCHAR2(30);


  BEGIN

lv_retval := FND_INSTALLATION.GET_APP_INFO(
                    'FND', lv_dummy1,lv_dummy2, v_applsys_schema);

    lv_task_start_time:= SYSDATE;

    FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
    FND_MESSAGE.SET_TOKEN('PROCEDURE', 'DELETE_MSC_TABLE:'||p_table_name);
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'   '||FND_MESSAGE.GET);


     IF p_sub_str IS NULL
     AND  is_msctbl_partitioned( p_table_name) THEN


      SELECT application_short_name
        INTO lv_appl_short_nm
        FROM fnd_application
       WHERE application_id=724;

         IF p_plan_id= -1 OR p_plan_id IS NULL THEN
          lv_is_plan:= SYS_NO;
         ELSE
          lv_is_plan:= SYS_YES;
         END IF;

         msc_manage_plan_partitions.get_partition_name
                         ( p_plan_id,
                           p_instance_id,
                           p_table_name,
                           lv_is_plan,
                           lv_partition_name,
                           lv_return_status,
                           lv_msg_data);


         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Partition Name : '||lv_partition_name);

         v_sql_stmt := 01;

         lv_sql_stmt:= 'ALTER TABLE '||p_table_name
                  ||' TRUNCATE PARTITION '||lv_partition_name;


          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);


          AD_DDL.DO_DDL( APPLSYS_SCHEMA => v_applsys_schema,
                      APPLICATION_SHORT_NAME => lv_appl_short_nm,
                      STATEMENT_TYPE => AD_DDL.ALTER_TABLE,
                      STATEMENT => lv_sql_stmt,
                      OBJECT_NAME => p_table_name);

    ELSE


       IF p_plan_id IS NULL THEN

       v_sql_stmt := 02;

          lv_sql_stmt:= 'SELECT COUNT(*)'
                   ||' FROM '|| p_table_name
                   ||' WHERE SR_INSTANCE_ID= :p_instance_id '
                   ||  p_sub_str;

          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
          EXECUTE IMMEDIATE lv_sql_stmt
                    INTO lv_cnt
                   USING p_instance_id;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_cnt || ' Rows Fetched ');



          IF lv_pbs IS NULL OR
             lv_cnt < lv_pbs THEN

       v_sql_stmt := 03;

             lv_sql_stmt:= 'DELETE  '||p_table_name
                      ||' WHERE SR_INSTANCE_ID= :p_instance_id '
                      ||  p_sub_str;

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
             EXECUTE IMMEDIATE lv_sql_stmt
                         USING p_instance_id;


             COMMIT;

          ELSE

             v_sql_stmt := 04;
             lv_sql_stmt:=   'DELETE  '||p_table_name
                         ||'  WHERE SR_INSTANCE_ID= :p_instance_id '
                         ||     p_sub_str
                         ||'    AND ROWNUM < :lv_pbs';
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);

             LOOP

                EXECUTE IMMEDIATE lv_sql_stmt
                            USING p_instance_id, lv_pbs;

                EXIT WHEN SQL%ROWCOUNT= 0;

               COMMIT;

             END LOOP;

          END IF;

       ELSE

     v_sql_stmt := 05;
          lv_sql_stmt:= 'SELECT COUNT(*)'
                   ||' FROM '||p_table_name
                   ||' WHERE SR_INSTANCE_ID= :p_instance_id'
                   ||'   AND PLAN_ID= -1 '
                   ||    p_sub_str;


MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);


          EXECUTE IMMEDIATE lv_sql_stmt
                       INTO lv_cnt
                      USING p_instance_id;
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_cnt || ' Rows Fetched ');
          IF lv_pbs IS NULL OR
             lv_cnt < lv_pbs THEN

     v_sql_stmt := 06;

             lv_sql_stmt:=  'DELETE '||p_table_name
                         ||'  WHERE SR_INSTANCE_ID= :lv_instance_id'
                         ||'    AND PLAN_ID= -1 '
                         ||   p_sub_str;

           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);


             EXECUTE IMMEDIATE lv_sql_stmt
                         USING p_instance_id;

             COMMIT;

          ELSE
             v_sql_stmt := 07;
             lv_sql_stmt:=   'DELETE '||p_table_name
                         ||'  WHERE SR_INSTANCE_ID= :p_instance_id '
                         ||'    AND PLAN_ID= -1 '
                         ||     p_sub_str
                         ||'    AND ROWNUM < :lv_pbs';

          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);


             LOOP

                EXECUTE IMMEDIATE lv_sql_stmt
                            USING p_instance_id, lv_pbs;

                EXIT WHEN SQL%ROWCOUNT= 0;

             COMMIT;

             END LOOP;

          END IF;
        END IF;
  END IF;

     FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
     FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',
                 TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'   '||FND_MESSAGE.GET);

 EXCEPTION
    WHEN OTHERS THEN
	lv_errtext := substr('DELETE_MSC_TABLE'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);

	MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_WARNING,lv_errtext);

  END DELETE_MSC_TABLE;



/*=======================================================================
  This function deletes record from MSC_LOCAL_ID_XXX  table
=========================================================================*/

  PROCEDURE DELETE_LID_TABLE(p_entity_name         IN VARCHAR2,
                             p_lid_table           IN VARCHAR2,
                             p_instance_id         IN NUMBER,
                             p_where_str           IN VARCHAR2) IS


    lv_cnt          NUMBER;
    lv_total        NUMBER  := 0;
    lv_sql_stmt     VARCHAR2(2048);
    lv_where_str      VARCHAR2(2048);

    lv_task_start_time DATE;

    lv_return        NUMBER;
    lv_errtext       VARCHAR2(2048);
    ex_logging_err    EXCEPTION;

  BEGIN

    lv_task_start_time:= SYSDATE;

    FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
    FND_MESSAGE.SET_TOKEN('PROCEDURE', 'DELETE_LID_TABLE:'||p_lid_table);
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'   '||FND_MESSAGE.GET);

    lv_where_str := p_where_str;

    v_sql_stmt := 01;
    lv_sql_stmt :=  ' SELECT COUNT(*) '
                   ||' FROM  '||p_lid_table||' lid'
                   ||' WHERE lid.instance_id = :p_instance_id'
                   ||' AND lid.entity_name = :p_entity_name'
                   ||  lv_where_str  ;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);


         EXECUTE IMMEDIATE lv_sql_stmt
                      INTO lv_cnt
                     USING p_instance_id,p_entity_name;


       IF lv_pbs IS NULL OR
             lv_cnt < lv_pbs THEN

       v_sql_stmt := 02;
               lv_sql_stmt :=  'DELETE FROM  '||p_lid_table||' lid'
                              ||' WHERE lid.instance_id = :p_instance_id'
                              ||' AND lid.entity_name = :p_entity_name'
                              ||  lv_where_str  ;


         EXECUTE IMMEDIATE lv_sql_stmt
                     USING p_instance_id,p_entity_name;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);


         lv_total := lv_total+SQL%ROWCOUNT ;

        ELSE
              v_sql_stmt := 03;
              lv_sql_stmt :=  'DELETE FROM  '||p_lid_table||' lid'
                              ||' WHERE lid.instance_id = :p_instance_id'
                              ||' AND lid.entity_name = :p_entity_name'
                              ||  lv_where_str
                              ||' AND ROWNUM < :lv_pbs';

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);

            lv_total := 0;

             LOOP
                 EXECUTE IMMEDIATE lv_sql_stmt
                       USING p_instance_id,p_entity_name,lv_pbs;

               lv_total := lv_total+ SQL%ROWCOUNT;

               EXIT WHEN SQL%ROWCOUNT = 0;

              COMMIT;
             END LOOP ;
        END IF ; -- batch size



            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Table: '||p_lid_table||' Entity :'||p_entity_name);
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'No of Rows deleted : '||lv_total);


        COMMIT;


     FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
     FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',
                 TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'   '||FND_MESSAGE.GET);


  EXCEPTION

     WHEN OTHERS THEN
 	lv_errtext := substr('DELETE_LID_TABLE'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);

	MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_WARNING,lv_errtext);

  END DELETE_LID_TABLE ;


/*==========================================================================+
 This is the main program that deletes the record from ths MSC_LOCAL_ID_XXX
 table . This accepts parameter, date upto which the record has to be deleted
 and different Business Object for which this program should delete LID .
 If it is complete refresh then it deletes record from the ODS and LID both.
+==========================================================================*/

  PROCEDURE PURGE_LID_TABLES(ERRBUF              OUT NOCOPY VARCHAR2,
                             RETCODE             OUT NOCOPY NUMBER,
                             p_instance_id       IN  NUMBER,
                             p_complete_refresh  IN  NUMBER     DEFAULT SYS_NO,
                             p_date              IN  VARCHAR2,
                             p_supply_flag       IN  NUMBER     DEFAULT SYS_NO,
                             p_demand_flag       IN  NUMBER     DEFAULT SYS_NO)
  IS

  lv_errtext        VARCHAR2(5000);
  lv_where_str      VARCHAR2(2048);
  lv_row_count      NUMBER ;
  lv_return         NUMBER;
  lv_retval             BOOLEAN;
  lv_dummy1             VARCHAR2(32);
  lv_dummy2             VARCHAR2(32);
  ex_logging_err    EXCEPTION;

-- from here added for the deletion from lid tables for non complete refresh ( for the bug fix 2229944)--

  lv_total        NUMBER  := 0;
  lv_task_start_time DATE;
  TYPE RowidTab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
  lb_rowid          RowidTab;
  lv_supplyId	 NUMBER;
   CURSOR  C1(p_instance_id NUMBER) IS
           SELECT rowid
           FROM msc_local_id_demand lid
           WHERE lid.entity_name ='DISPOSITION_ID_FCT'
           AND lid.instance_id = p_instance_id
           MINUS
           SELECT distinct lid.rowid
           FROM msc_local_id_demand lid, msc_demands ms
           WHERE lid.instance_id = p_instance_id
           AND lid.entity_name = 'DISPOSITION_ID_FCT'
           AND ms.sales_order_line_id = lid.local_id
           AND ms.plan_id = -1
           AND ms.origination_type = 29
           AND ms.sr_instance_id = lid.instance_id;

   CURSOR C2(p_instance_id NUMBER) IS
          SELECT rowid
          FROM msc_local_id_demand lid
          WHERE lid.entity_name ='DISPOSITION_ID_MDS'
          AND lid.instance_id = p_instance_id
          MINUS
          SELECT distinct lid.rowid
          FROM msc_local_id_demand lid, msc_demands ms
          WHERE lid.instance_id = p_instance_id
          AND lid.entity_name = 'DISPOSITION_ID_MDS'
          AND ms.disposition_id = lid.local_id
          AND ms.origination_type = 8
          AND ms.plan_id = -1
          AND ms.sr_instance_id = lid.instance_id;

   CURSOR C3(p_instance_id NUMBER) IS
          SELECT rowid
          FROM msc_local_id_demand lid
          WHERE lid.entity_name ='SALES_ORDER_ID'
          AND lid.instance_id = p_instance_id
          MINUS
          SELECT distinct lid.rowid
          FROM msc_local_id_demand lid, msc_sales_orders ms
          WHERE lid.instance_id = p_instance_id
          AND lid.entity_name = 'SALES_ORDER_ID'
          AND ms.demand_source_header_id = lid.local_id
          AND ms.sr_instance_id = lid.instance_id;

   CURSOR C4(p_instance_id NUMBER) IS
          SELECT rowid
          FROM msc_local_id_demand lid
          WHERE lid.entity_name ='DEMAND_ID'
          AND lid.instance_id = p_instance_id
          MINUS
          SELECT distinct lid.rowid
          FROM msc_local_id_demand lid, msc_sales_orders ms
          WHERE lid.instance_id = p_instance_id
          AND lid.entity_name = 'DEMAND_ID'
          AND ms.demand_id = lid.local_id
          AND ms.sr_instance_id = lid.instance_id;

      CURSOR C5(p_instance_id NUMBER) IS
             SELECT rowid
             FROM msc_local_id_supply lid
             WHERE lid.entity_name ='WIP_ENTITY_ID'
             AND lid.instance_id = p_instance_id
             MINUS
             SELECT distinct lid.rowid
             FROM msc_local_id_supply lid, msc_supplies ms
             WHERE lid.instance_id = p_instance_id
             AND lid.entity_name ='WIP_ENTITY_ID'
             AND ms.disposition_id = lid.local_id
             AND ms.order_type IN (3,7,27)
             AND ms.plan_id = -1
             AND ms.sr_instance_id = lid.instance_id;

      CURSOR C6(p_instance_id NUMBER) IS
	     SELECT rowid
             FROM msc_local_id_supply lid
             WHERE lid.entity_name ='SR_MTL_SUPPLY_ID'
             AND lid.instance_id = p_instance_id
             MINUS
             SELECT distinct lid.rowid
             FROM msc_local_id_supply lid, msc_supplies ms
             WHERE lid.instance_id = p_instance_id
             AND lid.entity_name = 'SR_MTL_SUPPLY_ID'
             AND ms.sr_mtl_supply_id = lid.local_id
             AND ms.order_type IN (1,2,8,11,12)
             AND ms.plan_id = -1
             AND ms.sr_instance_id = lid.instance_id;

      CURSOR C7(p_instance_id NUMBER) IS
             SELECT rowid
             FROM msc_local_id_supply lid
             WHERE lid.entity_name ='PO_LINE_ID'
             AND lid.instance_id = p_instance_id
             MINUS
             SELECT distinct lid.rowid
             FROM msc_local_id_supply lid, msc_supplies ms
             WHERE lid.instance_id = p_instance_id
             AND lid.entity_name = 'PO_LINE_ID'
             AND ms.po_line_id = lid.local_id
             AND ms.order_type IN (1,2,8,11,12)
             AND ms.plan_id = -1
             AND ms.sr_instance_id = lid.instance_id;

      CURSOR C8(p_instance_id NUMBER) IS
             SELECT rowid
             FROM msc_local_id_supply lid
             WHERE lid.entity_name ='DISPOSITION_ID'
             AND lid.instance_id = p_instance_id
             MINUS
             SELECT distinct lid.rowid
             FROM msc_local_id_supply lid, msc_supplies ms
             WHERE lid.instance_id = p_instance_id
             AND lid.entity_name = 'DISPOSITION_ID'
             AND ms.disposition_id = lid.local_id
             AND ms.order_type IN (1,2,8,11,12)
             AND ms.plan_id = -1
             AND ms.sr_instance_id = lid.instance_id;

     CURSOR C9(p_instance_id NUMBER) IS
            SELECT rowid
            FROM msc_local_id_supply lid
            WHERE lid.entity_name ='DISPOSITION_ID_MPS'
            AND lid.instance_id = p_instance_id
            MINUS
            SELECT distinct lid.rowid
            FROM msc_local_id_supply lid, msc_supplies ms
            WHERE lid.instance_id = p_instance_id
            AND lid.entity_name = 'DISPOSITION_ID_MPS'
            AND ms.disposition_id = lid.local_id
            AND ms.order_type = 5
            AND ms.plan_id = -1
            AND ms.sr_instance_id = lid.instance_id;

     CURSOR C10(p_instance_id NUMBER) IS
            SELECT rowid
            FROM msc_local_id_supply lid
            WHERE lid.entity_name ='SCHEDULE_GROUP_ID'
            AND lid.instance_id = p_instance_id
            MINUS
            SELECT distinct lid. rowid
            FROM msc_local_id_supply lid, msc_supplies ms
            WHERE lid.instance_id = p_instance_id
            AND lid.entity_name = 'SCHEDULE_GROUP_ID'
            AND ms.schedule_group_id = lid.local_id
            AND ms.plan_id = -1
            AND ms.sr_instance_id = lid.instance_id;

 -- till here added for the deletion of lid tables  ( for the bug fix 2229944) --
     CURSOR C11(p_instance_id NUMBER) IS
            SELECT transaction_id
            FROM msc_supplies ms
            WHERE ms.sr_instance_id=p_instance_id
            AND ms.plan_id = -1 and trunc(NEW_SCHEDULE_DATE) <=
trunc(to_date(p_date,'YYYY/MM/DD HH24:MI:SS'));

  BEGIN

    --========= Setting global variables==============--------------
      v_current_date := SYSDATE ;
      v_current_user := FND_GLOBAL.USER_ID ;
      v_login_user   := FND_GLOBAL.CONC_LOGIN_ID;
      v_request_id   := FND_GLOBAL.CONC_REQUEST_ID;
      v_prog_appl_id := FND_GLOBAL.PROG_APPL_ID;
      v_program_id   := FND_GLOBAL.CONC_PROGRAM_ID;

      v_instance_id  := p_instance_id;
      v_date         := fnd_date.canonical_to_date(p_date);
      lv_retval := FND_INSTALLATION.GET_APP_INFO(
                   'FND', lv_dummy1,lv_dummy2, v_applsys_schema);



     -- ===== Switch on/ off debug based on MRP: Debug Profile=====--

      v_debug := FND_PROFILE.VALUE('MRP_DEBUG') = 'Y';


     --======= Check the Status of the instance.
     --======= Delete only if the staging table is empty

    IF NOT CHECK_ST_STATUS(p_instance_id => v_instance_id,
                           errbuf     => lv_errtext,
                           retcode    => v_sql_stmt) THEN

    RAISE  ex_logging_err ;
    END IF;

----------------------Complete Referesh ----------------------------
    IF p_complete_refresh = SYS_YES THEN

/* if complete refresh, regen the key mapping data */

   DELETE MSC_ITEM_ID_LID    WHERE SR_INSTANCE_ID= v_instance_id;
   --DELETE MSC_TP_ID_LID      WHERE SR_INSTANCE_ID= v_instance_id;
   --DELETE MSC_TP_SITE_ID_LID WHERE SR_INSTANCE_ID= v_instance_id;
   --DELETE MSC_CATEGORY_SET_ID_LID  WHERE SR_INSTANCE_ID= v_instance_id;
   DELETE MSC_ITEM_ID_LID    WHERE SR_INSTANCE_ID= -1;
   --DELETE MSC_TP_ID_LID      WHERE SR_INSTANCE_ID= -1;
   --DELETE MSC_TP_SITE_ID_LID WHERE SR_INSTANCE_ID= -1;
   --DELETE MSC_CATEGORY_SET_ID_LID  WHERE SR_INSTANCE_ID= -1;

  COMMIT;


----------------------DELETE ITEM ----------------------------
       DELETE_MSC_TABLE('MSC_SYSTEM_ITEMS', v_instance_id, -1);

       DELETE_LID_TABLE( p_entity_name     => 'SR_INVENTORY_ITEM_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_ITEM',
                         p_instance_id     => v_instance_id ,
                         p_where_str       => NULL );


----------------------DELETE ABC Class ----------------------------
      DELETE_MSC_TABLE( 'MSC_ABC_CLASSES', v_instance_id, NULL);

       DELETE_LID_TABLE( p_entity_name     => 'ABC_CLASS_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_MISC',
                         p_instance_id     => v_instance_id ,
                         p_where_str       => NULL );

-----------------------DELETE Item Substitutes---------------------------
       DELETE_MSC_TABLE( 'MSC_ITEM_SUBSTITUTES', v_instance_id, -1);
----------------------DELETE BOM ----------------------------
       DELETE_MSC_TABLE( 'MSC_BOMS', v_instance_id, -1);

       DELETE_LID_TABLE( p_entity_name     => 'BILL_SEQUENCE_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_SETUP',
                         p_instance_id     => v_instance_id ,
                         p_where_str       => NULL );

       DELETE_MSC_TABLE( 'MSC_BOM_COMPONENTS', v_instance_id, -1);

       DELETE_LID_TABLE( p_entity_name     => 'COMPONENT_SEQUENCE_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_SETUP',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );

       DELETE_MSC_TABLE( 'MSC_COMPONENT_SUBSTITUTES', v_instance_id, -1);

       -- For OSFM support --
       DELETE_LID_TABLE( p_entity_name     => 'CO_PRODUCT_GROUP_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_SETUP',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );


---------------------DELETE Routing---------------------------

       DELETE_MSC_TABLE( 'MSC_ROUTINGS', v_instance_id, -1);

       DELETE_LID_TABLE( p_entity_name     => 'ROUTING_SEQUENCE_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_SETUP',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );


       DELETE_MSC_TABLE( 'MSC_ROUTING_OPERATIONS', v_instance_id, -1);

       DELETE_LID_TABLE( p_entity_name     => 'OPERATION_SEQUENCE_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_SETUP',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );

       DELETE_MSC_TABLE( 'MSC_OPERATION_RESOURCES', v_instance_id, -1);

       DELETE_LID_TABLE( p_entity_name     => 'RESOURCE_SEQ_NUM',
                         p_lid_table       => 'MSC_LOCAL_ID_SETUP',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );

       DELETE_MSC_TABLE( 'MSC_OPERATION_COMPONENTS', v_instance_id, -1);
       DELETE_MSC_TABLE( 'MSC_OPERATION_RESOURCE_SEQS', v_instance_id, -1);
       DELETE_MSC_TABLE( 'MSC_PROCESS_EFFECTIVITY', v_instance_id, -1);

       -- Added for OSFM support --
       DELETE_MSC_TABLE( 'MSC_OPERATION_NETWORKS', v_instance_id, -1);

--------------------------DELETE ASL-------------------------------------
       DELETE_MSC_TABLE( 'MSC_ITEM_SUPPLIERS', v_instance_id, -1);
       DELETE_MSC_TABLE( 'MSC_SUPPLIER_CAPACITIES', v_instance_id, -1);
       DELETE_MSC_TABLE( 'MSC_SUPPLIER_FLEX_FENCES', v_instance_id, -1);
-------------------------------------------------------------------------

--------------------------DELETE Resource Group--------------------------
DELETE_MSC_TABLE( 'MSC_RESOURCE_GROUPS', v_instance_id, NULL);
--------------------------DELETE Department/Line ------------------------
       DELETE_MSC_TABLE( 'MSC_DEPARTMENT_RESOURCES', v_instance_id, -1);

       DELETE_LID_TABLE( p_entity_name     => 'DEPARTMENT_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_SETUP',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );

       DELETE_LID_TABLE( p_entity_name     => 'LINE_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_SETUP',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );

       DELETE_LID_TABLE( p_entity_name     => 'RESOURCE_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_SETUP',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );

       DELETE_MSC_TABLE( 'MSC_RESOURCE_SHIFTS', v_instance_id, NULL);
       DELETE_MSC_TABLE( 'MSC_RESOURCE_CHANGES', v_instance_id, NULL);
       DELETE_MSC_TABLE( 'MSC_SIMULATION_SETS', v_instance_id, NULL);
       DELETE_MSC_TABLE( 'MSC_RESOURCE_REQUIREMENTS', v_instance_id, -1);


--------------- DELETE PROJECT/TASK----------------------------------
       DELETE_MSC_TABLE( 'MSC_PROJECTS', v_instance_id, -1);

       DELETE_LID_TABLE( p_entity_name     => 'PROJECT_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_MISC',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );

       DELETE_MSC_TABLE( 'MSC_PROJECT_TASKS', v_instance_id, -1);

       DELETE_LID_TABLE( p_entity_name     => 'TASK_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_MISC',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );

       DELETE_LID_TABLE( p_entity_name     => 'COSTING_GROUP_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_MISC',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );

--------------- DELETE Demand Class--------------------

DELETE_MSC_TABLE( 'MSC_DEMAND_CLASSES', v_instance_id, NULL);

--------------- DELETE Trading Partner--------------------
    -- For org directly  deleting from ODS, as done in MSCCLBAB
    -- We do not delete vendor an customer from the ODS

  -- DELETE_MSC_TABLE( 'MSC_TRADING_PARTNERS', v_instance_id, NULL,
  --                  'AND PARTNER_TYPE=3');

/*      DELETE MSC_TRADING_PARTNERS
          WHERE sr_instance_id= v_instance_id
           AND partner_type=3;

       DELETE_LID_TABLE( p_entity_name     => 'SR_TP_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_SETUP',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );


        DELETE_MSC_TABLE( 'MSC_TRADING_PARTNER_SITES', v_instance_id, NULL,
                          'AND PARTNER_TYPE=3');

        DELETE_LID_TABLE( p_entity_name     => 'SR_TP_SITE_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_SETUP',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );

       DELETE_MSC_TABLE( 'MSC_PARTNER_CONTACTS', v_instance_id, NULL);

       -- DELETE_MSC_TABLE( 'MSC_LOCATION_ASSOCIATIONS', v_instance_id, NULL);

       DELETE MSC_LOCATION_ASSOCIATIONS
          WHERE SR_INSTANCE_ID= v_instance_id;

       DELETE_LID_TABLE(p_entity_name     => 'LOCATION_ID',
                        p_lid_table       => 'MSC_LOCAL_ID_SETUP',
                        p_instance_id     => v_instance_id,
                        p_where_str       => NULL );      */ --- for legacyno deletion


-----------------------DELETE Planners---------------------------
        DELETE_MSC_TABLE( 'MSC_PLANNERS', v_instance_id, NULL);

--------------- DELETE Category---------------------------
        DELETE_MSC_TABLE( 'MSC_ITEM_CATEGORIES', v_instance_id, NULL);

        DELETE_LID_TABLE( p_entity_name    => 'SR_CATEGORY_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_MISC',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );

   /*    DELETE_LID_TABLE( p_entity_name    => 'SR_CATEGORY_SET_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_MISC',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL ); */ -- as we do not purge ODS

------------- DELETE Calendar--------------------------------
-- For legacy we will not be deleting any calendar tables

/*   DELETE_MSC_TABLE( 'MSC_PERIOD_START_DATES', v_instance_id, NULL);

      DELETE_MSC_TABLE( 'MSC_CAL_YEAR_START_DATES', v_instance_id, NULL);

      DELETE_MSC_TABLE( 'MSC_CAL_WEEK_START_DATES', v_instance_id, NULL);

      DELETE_MSC_TABLE( 'MSC_RESOURCE_SHIFTS', v_instance_id, NULL);

      DELETE_MSC_TABLE( 'MSC_CALENDAR_SHIFTS', v_instance_id, NULL);

      DELETE_MSC_TABLE( 'MSC_SHIFT_DATES', v_instance_id, NULL);

      DELETE_MSC_TABLE( 'MSC_RESOURCE_CHANGES', v_instance_id, NULL);

      DELETE_MSC_TABLE( 'MSC_SHIFT_TIMES', v_instance_id, NULL);

      DELETE_MSC_TABLE( 'MSC_SHIFT_EXCEPTIONS', v_instance_id, NULL);

      DELETE_LID_TABLE( p_entity_name     => 'SHIFT_NUM',
                       p_lid_table       => 'MSC_LOCAL_ID_SETUP',
                       p_instance_id     => v_instance_id,
                       p_where_str       => NULL );                    */

------------------DELETE SOURCING--------------------------------
DELETE_MSC_TABLE( 'MSC_INTERORG_SHIP_METHODS', v_instance_id,-1);
------------------DELETE SOURCING--------------------------------
/*   --  not deleting from ODS because of bug 1219661 as done in MSCCLBAB

       DELETE_LID_TABLE( p_entity_name     => 'SOURCING_RULE_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_MISC',
                         p_instance_id     => v_instance_id ,
                         p_where_str       => NULL );

       DELETE_LID_TABLE( p_entity_name     => 'ASSIGNMENT_SET_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_MISC',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );


       DELETE_LID_TABLE( p_entity_name     => 'SR_RECEIPT_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_MISC',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );

       DELETE_LID_TABLE( p_entity_name     => 'SR_SOURCE_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_MISC',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );

       DELETE_LID_TABLE( p_entity_name     => 'ASSIGNMENT_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_MISC',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );      */

------------------DELETE UOM-----------------------------------------
 -- No deletion IN ODS
 -- No deltion in LID

------------------DELETE Designator-----------------------------------------

   UPDATE MSC_DESIGNATORS
   SET DISABLE_DATE= v_current_date,
       LAST_UPDATE_DATE= v_current_date,
       LAST_UPDATED_BY= v_current_user
   WHERE SR_INSTANCE_ID= v_instance_id
   AND COLLECTED_FLAG= SYS_YES;

-----------------------DELETE Safety Stock---------------------------
DELETE_MSC_TABLE( 'MSC_SAFETY_STOCKS', v_instance_id, -1);

-----------------------DELETE Hard Reservations-----------------------
DELETE_MSC_TABLE( 'MSC_RESERVATIONS', v_instance_id, -1);

-----------------------DELETE Demand----------------------------
       DELETE_MSC_TABLE( 'MSC_DEMANDS', v_instance_id, -1 );
       DELETE_MSC_TABLE( 'MSC_SALES_ORDERS', v_instance_id, NULL);


       DELETE_LID_TABLE( p_entity_name     => 'DISPOSITION_ID_FCT',
                         p_lid_table       => 'MSC_LOCAL_ID_DEMAND',
                         p_instance_id     => v_instance_id ,
                         p_where_str       => NULL );

       DELETE_LID_TABLE( p_entity_name     => 'DISPOSITION_ID_MDS',
                         p_lid_table       => 'MSC_LOCAL_ID_DEMAND',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );

       DELETE_LID_TABLE( p_entity_name     => 'DISPOSITION_ID_FCT',
                         p_lid_table       => 'MSC_LOCAL_ID_DEMAND',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );

       DELETE_LID_TABLE( p_entity_name     => 'SALES_ORDER_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_DEMAND',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );

       DELETE_LID_TABLE( p_entity_name     => 'DEMAND_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_DEMAND',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );

-----------------------DELETE Supply----------------------------

       DELETE_MSC_TABLE( 'MSC_SUPPLIES', v_instance_id, -1);

       DELETE_LID_TABLE( p_entity_name     => 'DISPOSITION_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_SUPPLY',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );

       DELETE_LID_TABLE( p_entity_name     => 'PO_LINE_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_SUPPLY',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );

       DELETE_LID_TABLE( p_entity_name     => 'SCHEDULE_GROUP_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_SUPPLY',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );

       DELETE_LID_TABLE( p_entity_name     => 'DISPOSTION_ID_MPS',
                         p_lid_table       => 'MSC_LOCAL_ID_SUPPLY',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );

       DELETE_LID_TABLE( p_entity_name     => 'SR_MTL_SUPPLY_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_SUPPLY',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );

       DELETE_LID_TABLE( p_entity_name     => 'WIP_ENTITY_ID',
                         p_lid_table       => 'MSC_LOCAL_ID_SUPPLY',
                         p_instance_id     => v_instance_id,
                         p_where_str       => NULL );

   -------- Delete OSFM tables ---------------------------

   DELETE_MSC_TABLE('MSC_JOB_OPERATION_NETWORKS', v_instance_id, -1);
   DELETE_MSC_TABLE('MSC_JOB_OPERATIONS', v_instance_id, -1);
   DELETE_MSC_TABLE('MSC_JOB_REQUIREMENT_OPS', v_instance_id, -1);
   DELETE_MSC_TABLE('MSC_JOB_OP_RESOURCES', v_instance_id, -1);


   ELSE  -- if not complete refresh

/*************************************************************************
         From here modified  for the bug fix 2229944

       Note the deletion from lid tables done using cursors,
       becuase deletion using co-related sub queries was
       becoming a major performance issue without indexes.

*************************************************************************/


      IF p_demand_flag = SYS_YES  THEN

         DELETE_MSC_TABLE( p_table_name  =>'MSC_DEMANDS',
                           p_instance_id => v_instance_id,
                           p_plan_id     => -1,
                           p_sub_str     => '  and trunc(USING_ASSEMBLY_DEMAND_DATE) <= '||'trunc(to_date('||''''||p_date||''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''''||'))');


        DELETE_MSC_TABLE( p_table_name  =>'MSC_SALES_ORDERS',
                           p_instance_id => v_instance_id,
                           p_plan_id     => NULL,
                           p_sub_str     => '  and trunc(REQUIREMENT_DATE) <= '||'trunc(to_date('||''''||p_date||''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''''||'))');


 -- Delete from MSC_LOCAL_ID_DEMAND  for entity_name  DISPOSITION_ID_FCT starts here --

       lv_task_start_time:= SYSDATE;
       lv_total := 0;
       v_sql_stmt := 01;


            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Delete from MSC_LOCAL_ID_DEMAND  for entity_name  DISPOSITION_ID_FCT' );


       OPEN C1(v_instance_id);

       FETCH C1 BULK COLLECT INTO lb_rowid ;

       IF C1%ROWCOUNT > 0  THEN

         FORALL j IN lb_rowid.FIRST..lb_rowid.LAST

           DELETE FROM  MSC_LOCAL_ID_DEMAND
           WHERE ROWID = lb_rowid(j);

           lv_total :=  C1%ROWCOUNT;

       END IF;

       CLOSE C1;

     COMMIT;

            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'No of Rows deleted : '||lv_total);


     FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
     FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'   '||FND_MESSAGE.GET);

-- Delete from MSC_LOCAL_ID_DEMAND  for entity_name  DISPOSITION_ID_FCT ends here----


-- Delete from MSC_LOCAL_ID_DEMAND  for entity_name  DISPOSITION_ID_MDS starts here --

       lv_task_start_time:= SYSDATE;
       lv_total := 0;
       v_sql_stmt := 02;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Delete from MSC_LOCAL_ID_DEMAND  for entity_name  DISPOSITION_ID_MDS');


       OPEN C2(v_instance_id);

       FETCH C2 BULK COLLECT INTO lb_rowid ;

       IF C2%ROWCOUNT > 0  THEN

         FORALL j IN lb_rowid.FIRST..lb_rowid.LAST

         DELETE FROM  MSC_LOCAL_ID_DEMAND
         WHERE ROWID = lb_rowid(j);

         lv_total :=  C2%ROWCOUNT;

       END IF;

       CLOSE C2;

     COMMIT;


            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'No of Rows deleted : '||lv_total);


     FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
     FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'   '||FND_MESSAGE.GET);

-- Delete from MSC_LOCAL_ID_DEMAND  for entity_name  DISPOSITION_ID_MDS ends here----


-- Delete from MSC_LOCAL_ID_DEMAND  for entity_name  SALES_ORDER_ID starts here --

       lv_task_start_time:= SYSDATE;
       lv_total := 0;
       v_sql_stmt := 03;

            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Delete from MSC_LOCAL_ID_DEMAND  for entity_name  SALES_ORDER_ID');


       OPEN C3(v_instance_id);

       FETCH C3 BULK COLLECT INTO lb_rowid ;

       IF C3%ROWCOUNT > 0  THEN

         FORALL j IN lb_rowid.FIRST..lb_rowid.LAST

         DELETE FROM  MSC_LOCAL_ID_DEMAND
         WHERE ROWID = lb_rowid(j);

         lv_total := C3%ROWCOUNT;

       END IF;

       CLOSE C3;

     COMMIT;


            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'No of Rows deleted : '||lv_total);

     FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
     FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'   '||FND_MESSAGE.GET);

-- Deletion from MSC_LOCAL_ID_DEMAND  for entity_name  SALES_ORDER_ID ends here----


-- Delete from MSC_LOCAL_ID_DEMAND  for entity_name  DEMAND_ID starts here --

       lv_task_start_time:= SYSDATE;
       lv_total := 0;
       v_sql_stmt := 04;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Delete from MSC_LOCAL_ID_DEMAND  for entity_name  DEMAND_ID');


       OPEN C4(v_instance_id);

       FETCH C4 BULK COLLECT INTO lb_rowid ;

       IF C4%ROWCOUNT > 0  THEN

         FORALL j IN lb_rowid.FIRST..lb_rowid.LAST

         DELETE FROM  MSC_LOCAL_ID_DEMAND
         WHERE ROWID = lb_rowid(j);

         lv_total :=  C4%ROWCOUNT;

       END IF;

       CLOSE C4;

     COMMIT;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'No of Rows deleted : '||lv_total);

     FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
     FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'   '||FND_MESSAGE.GET);

-- Deletion from MSC_LOCAL_ID_DEMAND  for entity_name  DEMAND_ID  ends here ----


  END IF; -- p_demand_flag


      IF  p_supply_flag = SYS_YES  THEN


 lv_task_start_time:= SYSDATE;
       lv_total := 0;
       v_sql_stmt := 05;

       IF V_DEBUG THEN
            msc_st_util.log_message('Delete from MSC_RESOURCE_REQUIREMENTS,MSC_JOB_OPERATIONS,MSC_JOB_OP_RESOURCES,MSC_JOB_REQUIREMENT_OPS for delted supply Id');
       END IF;

       OPEN C11(v_instance_id);
       LOOP
       FETCH C11 INTO lv_supplyId ;
         EXIT WHEN C11%NOTFOUND;

         DELETE FROM  MSC_RESOURCE_REQUIREMENTS
         WHERE  plan_id = -1 and
                sr_instance_id = v_instance_id and
                SUPPLY_ID  = lv_supplyId ;

         DELETE FROM MSC_JOB_OPERATIONS
         WHERE plan_id = -1 and
                sr_instance_id = v_instance_id and
                 TRANSACTION_ID = lv_supplyId;

         DELETE FROM MSC_JOB_OPERATION_NETWORKS
         WHERE  plan_id = -1 and
                sr_instance_id = v_instance_id and
                TRANSACTION_ID = lv_supplyId;

         DELETE FROM MSC_JOB_OP_RESOURCES
         WHERE  plan_id = -1 and
                sr_instance_id = v_instance_id and
                TRANSACTION_ID = lv_supplyId;

         DELETE FROM MSC_JOB_REQUIREMENT_OPS
         WHERE  plan_id = -1 and
                sr_instance_id = v_instance_id and
                TRANSACTION_ID = lv_supplyId;


       END LOOP;

       CLOSE C11;

     IF V_DEBUG THEN
            MSC_ST_UTIL.LOG_MESSAGE('Deletion Complete ');
     END IF ;

     FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
     FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
     MSC_ST_UTIL.LOG_MESSAGE('   '||FND_MESSAGE.GET);



         DELETE_MSC_TABLE( p_table_name  =>'MSC_SUPPLIES',
                           p_instance_id => v_instance_id,
                           p_plan_id     => -1,
                           p_sub_str     => '  and trunc(NEW_SCHEDULE_DATE) <= '||'trunc(to_date('||''''||p_date||''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''''||'))');


-- Delete from MSC_LOCAL_ID_SUPPLY for entity_name  WIP_ENTITY_IDstarts here --

       lv_task_start_time:= SYSDATE;
       lv_total := 0;
       v_sql_stmt := 06;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Delete from MSC_LOCAL_ID_SUPPLY for entity_name  WIP_ENTITY_ID');

       OPEN C5(v_instance_id);

       FETCH C5 BULK COLLECT INTO lb_rowid ;
       IF C5%ROWCOUNT > 0  THEN

         FORALL j IN lb_rowid.FIRST..lb_rowid.LAST

         DELETE FROM  MSC_LOCAL_ID_SUPPLY
         WHERE ROWID = lb_rowid(j);

         lv_total :=  C5%ROWCOUNT;

       END IF;

       CLOSE C5;

     COMMIT;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'No of Rows deleted : '||lv_total);


     FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
     FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'   '||FND_MESSAGE.GET);

-- Deletion from MSC_LOCAL_ID_SUPPLY for entity_name  WIP_ENTITY_ID ends here ----


-- Delete from MSC_LOCAL_ID_SUPPLY for entity_name  SR_MTL_SUPPLY_ID starts here --

       lv_task_start_time:= SYSDATE;
       lv_total := 0;
       v_sql_stmt := 07;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Delete from MSC_LOCAL_ID_SUPPLY for entity_name  SR_MTL_SUPPLY_ID');


       OPEN C6(v_instance_id);

       FETCH C6 BULK COLLECT INTO lb_rowid ;

       IF C6%ROWCOUNT > 0  THEN

         FORALL j IN lb_rowid.FIRST..lb_rowid.LAST

          DELETE FROM  MSC_LOCAL_ID_SUPPLY
          WHERE ROWID = lb_rowid(j);

          lv_total :=  C6%ROWCOUNT;

       END IF;

       CLOSE C6;

     COMMIT;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'No of Rows deleted : '||lv_total);


     FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
     FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'   '||FND_MESSAGE.GET);

-- Deletion from MSC_LOCAL_ID_SUPPLY for entity_name  SR_MTL_SUPPLY_ID ends here ----


-- Delete from MSC_LOCAL_ID_SUPPLY for entity_name   PO_LINE_ID starts here --

       lv_task_start_time:= SYSDATE;
       lv_total := 0;
       v_sql_stmt := 08;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Delete from MSC_LOCAL_ID_SUPPLY for entity_name   PO_LINE_ID');

       OPEN C7(v_instance_id);

       FETCH C7 BULK COLLECT INTO lb_rowid ;

       IF C7%ROWCOUNT > 0  THEN

         FORALL j IN lb_rowid.FIRST..lb_rowid.LAST

          DELETE FROM  MSC_LOCAL_ID_SUPPLY
          WHERE ROWID = lb_rowid(j);

          lv_total :=  C7%ROWCOUNT;

       END IF;

       CLOSE C7;

     COMMIT;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'No of Rows deleted : '||lv_total);


     FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
     FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'   '||FND_MESSAGE.GET);

-- Deletion from MSC_LOCAL_ID_SUPPLY for entity_name  PO_LINE_ID ends here ----

-- Delete from MSC_LOCAL_ID_SUPPLY for entity_name  DISPOSITION_ID starts here --

       lv_task_start_time:= SYSDATE;
       lv_total := 0;
       v_sql_stmt := 09;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Delete from MSC_LOCAL_ID_SUPPLY for entity_name  DISPOSITION_ID');


       OPEN C8(v_instance_id);

       FETCH C8 BULK COLLECT INTO lb_rowid ;

       IF C8%ROWCOUNT > 0  THEN

         FORALL j IN lb_rowid.FIRST..lb_rowid.LAST

          DELETE FROM  MSC_LOCAL_ID_SUPPLY
          WHERE ROWID = lb_rowid(j);

          lv_total :=  C8%ROWCOUNT;

       END IF;

       CLOSE C8;

     COMMIT;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'No of Rows deleted : '||lv_total);


     FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
     FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'   '||FND_MESSAGE.GET);

-- Deletion from MSC_LOCAL_ID_SUPPLY for entity_name  DISPOSITION_ID ends here ----


-- Delete from MSC_LOCAL_ID_SUPPLY for entity_name  DISPOSITION_ID_MPS starts here --

       lv_task_start_time:= SYSDATE;
       lv_total := 0;
       v_sql_stmt := 10;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Delete from MSC_LOCAL_ID_SUPPLY for entity_name  DISPOSITION_ID_MPS');


       OPEN C9(v_instance_id);

       FETCH C9 BULK COLLECT INTO lb_rowid ;

       IF C9%ROWCOUNT > 0  THEN

         FORALL j IN lb_rowid.FIRST..lb_rowid.LAST

          DELETE FROM  MSC_LOCAL_ID_SUPPLY
          WHERE ROWID = lb_rowid(j);

          lv_total :=  C9%ROWCOUNT;

       END IF;

       CLOSE C9;

     COMMIT;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'No of Rows deleted : '||lv_total);


     FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
     FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'   '||FND_MESSAGE.GET);

-- Deletion from MSC_LOCAL_ID_SUPPLY for entity_name  DISPOSITION_ID_MPS ends here ----


-- Delete from MSC_LOCAL_ID_SUPPLY for entity_name  SCHEDULE_GROUP_ID starts here --

       lv_task_start_time:= SYSDATE;
       lv_total := 0;
       v_sql_stmt := 11;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Delete from MSC_LOCAL_ID_SUPPLY for entity_name  SCHEDULE_GROUP_ID');


       OPEN C10(v_instance_id);

       FETCH C10 BULK COLLECT INTO lb_rowid ;

       IF C10%ROWCOUNT > 0  THEN

         FORALL j IN lb_rowid.FIRST..lb_rowid.LAST

          DELETE FROM  MSC_LOCAL_ID_SUPPLY
          WHERE ROWID = lb_rowid(j);

          lv_total :=  C10%ROWCOUNT;

       END IF;

       CLOSE C10;

     COMMIT;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,' No of Rows deleted : '||lv_total);


     FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
     FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'   '||FND_MESSAGE.GET);

-- Deletion from MSC_LOCAL_ID_SUPPLY for entity_name  SCHEDULE_GROUP_ID ends here ----
      END IF ; -- p_suply_flag
    END IF ; -- Complete refresh

--------- Till here modified  for the bug fix 2229944 --------------


    FND_MESSAGE.SET_NAME('MSC', 'MSC_PP_PURGE_SUCCEED');
    ERRBUF:= FND_MESSAGE.GET;
    RETCODE := G_SUCCESS;
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ERRBUF);
    RETCODE := G_SUCCESS;


  EXCEPTION

    WHEN  ex_logging_err THEN
       ERRBUF   := lv_errtext;
       RETCODE  := G_ERROR;
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_WARNING,lv_errtext);

    WHEN OTHERS THEN
       ERRBUF  := SQLERRM;
       RETCODE := SQLCODE;
      lv_errtext := substr(v_sql_stmt||SQLERRM,1,240) ;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_WARNING,lv_errtext);
    END PURGE_LID_TABLES ;

PROCEDURE PURGE_ODS_TABLES_DEL( p_instance_id     IN  NUMBER) IS

BEGIN
   ---------------- BOM --------------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_BOM_COMPONENTS', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_BOMS', p_instance_id, NULL);
      COMMIT;

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_COMPONENT_SUBSTITUTES', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ROUTINGS', p_instance_id, NULL);
      COMMIT;

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ROUTING_OPERATIONS', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_OPERATION_RESOURCES', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_OPERATION_RESOURCE_SEQS', p_instance_id, NULL);
      MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_OPERATION_NETWORKS',p_instance_id,NULL);
      COMMIT;

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_PROCESS_EFFECTIVITY', p_instance_id, NULL);
      COMMIT;

      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_OPERATION_COMPONENTS', p_instance_id, NULL);
      COMMIT;
   ---------------- BOR -------------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_BILL_OF_RESOURCES', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_BOR_REQUIREMENTS', p_instance_id, NULL);
      COMMIT;
   ---------------- CALENDAR_DATE -------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_CALENDAR_DATES', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_PERIOD_START_DATES', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_CAL_YEAR_START_DATES', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_CAL_WEEK_START_DATES', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_RESOURCE_SHIFTS', p_instance_id, NULL);

      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_CALENDAR_SHIFTS', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SHIFT_DATES', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_RESOURCE_CHANGES', p_instance_id, NULL);
     COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SHIFT_TIMES', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SHIFT_EXCEPTIONS', p_instance_id, NULL);
      COMMIT;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'debug-02');
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_NET_RESOURCE_AVAIL', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_NET_RES_INST_AVAIL', p_instance_id, NULL);
      COMMIT;
   ----------------  CATEGORY -------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ITEM_CATEGORIES', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_CATEGORY_SETS', p_instance_id, NULL);
      COMMIT;
   ----------------  DEMAND -------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_DEMANDS', p_instance_id, NULL);
      COMMIT;
   ----------------  SALES ORDER -------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SALES_ORDERS', p_instance_id, NULL);
      COMMIT;
   ----------------  HARD RESERVATION -------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_RESERVATIONS', p_instance_id, NULL);
      COMMIT;
   ----------------  ITEM -------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SYSTEM_ITEMS', p_instance_id, NULL);
      COMMIT;
   ----------------  RESOURCE -------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_DEPARTMENT_RESOURCES', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SIMULATION_SETS', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_RESOURCE_GROUPS', p_instance_id, NULL);
      COMMIT;
   ----------------  SAFETY STOCK-------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SAFETY_STOCKS', p_instance_id, NULL);
      COMMIT;
   ----------------  SCHEDULE DESIGNATOR -------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_DESIGNATORS', p_instance_id, NULL);
      COMMIT;
   ----------------  SOURCING -------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ASSIGNMENT_SETS', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SOURCING_RULES', p_instance_id, NULL);
      COMMIT;
      DELETE FROM MSC_SR_ASSIGNMENTS
       WHERE SR_ASSIGNMENT_INSTANCE_ID= p_instance_id;
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SR_RECEIPT_ORG', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SR_SOURCE_ORG', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_INTERORG_SHIP_METHODS', p_instance_id, NULL);
      COMMIT;
           MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_CARRIER_SERVICES', p_instance_id, NULL);
      COMMIT;
   ---------------- SUB INVENTORY -------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SUB_INVENTORIES', p_instance_id, NULL);
      COMMIT;
   ----------------  SUPPLIER CAPACITY -------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ITEM_SUPPLIERS', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SUPPLIER_CAPACITIES', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SUPPLIER_FLEX_FENCES', p_instance_id, NULL);
      COMMIT;
   ---------------- SUPPLY -------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SUPPLIES', p_instance_id, NULL);
      COMMIT;
   ---------------- RESOURCE REQUIREMENT -------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_RESOURCE_REQUIREMENTS', p_instance_id, NULL);
      COMMIT;
   ---------------- TRADING PARTNER -------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_TRADING_PARTNERS', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_TRADING_PARTNER_SITES', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_LOCATION_ASSOCIATIONS', p_instance_id, NULL);
      COMMIT;
   ---------------- UNIT NUMBER -------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_UNIT_NUMBERS', p_instance_id, NULL);
      COMMIT;
   ---------------- PROJECT -------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_PROJECTS', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_PROJECT_TASKS', p_instance_id, NULL);
      COMMIT;
   ---------------- PARAMETER -------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_PARAMETERS', p_instance_id, NULL);
      COMMIT;
   ---------------- UOM -------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_UNITS_OF_MEASURE', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_UOM_CLASS_CONVERSIONS', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_UOM_CONVERSIONS', p_instance_id, NULL);
      COMMIT;
   ---------------- BIS -------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_BIS_PERFORMANCE_MEASURES', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_BIS_TARGET_LEVELS', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_BIS_TARGETS', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_BIS_BUSINESS_PLANS', p_instance_id, NULL);
      COMMIT;
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_BIS_PERIODS', p_instance_id, NULL);
      COMMIT;
   ---------------- ATP RULES -------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ATP_RULES', p_instance_id, NULL);
      COMMIT;
   ---------------- PLANNERS -------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_PLANNERS', p_instance_id, NULL);
      COMMIT;
   ---------------- DEMAND CLASS -------------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_DEMAND_CLASSES', p_instance_id, NULL);
      COMMIT;
   ---------------- PARTNER CONTACTS -----------
      MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_PARTNER_CONTACTS', p_instance_id, NULL);
      COMMIT;
   ---------------- LEGACY TABLES --------------
        MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_ITEM_SOURCING',p_instance_id, NULL);
        COMMIT;
        MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_CALENDARS',p_instance_id, NULL);
        COMMIT;
        MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_WORKDAY_PATTERNS',p_instance_id, NULL);
        COMMIT;
        MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_CALENDAR_EXCEPTIONS',p_instance_id, NULL);
        COMMIT;
               MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_GROUPS',p_instance_id, NULL);
        COMMIT;
        MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_GROUP_COMPANIES',p_instance_id, NULL);
        COMMIT;
              ---------------- TRIP --------------
        MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_TRIPS',p_instance_id, NULL);
        COMMIT;
        MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_TRIP_STOPS',p_instance_id, NULL);
        COMMIT;

	/* ds_change: start */
	MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_DEPT_RES_INSTANCES',p_instance_id, NULL);
	commit;
	MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_NET_RES_INST_AVAIL',p_instance_id, NULL);
	commit;
	MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_JOB_OP_RES_INSTANCES',p_instance_id, NULL);
	commit;
	MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_RESOURCE_INSTANCE_REQS',p_instance_id, NULL);
	commit;
	MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_RESOURCE_SETUPS',p_instance_id, NULL);
	commit;
	MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SETUP_TRANSITIONS',p_instance_id, NULL);
	commit;
	MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_ST_STD_OP_RESOURCES',p_instance_id, NULL);
        commit;
	MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_RES_INSTANCE_CHANGES',p_instance_id, NULL);
	commit;
	MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_RESOURCE_CHARGES',p_instance_id, NULL);
	commit;
	/* ds_change: end */
	MSC_CL_COLLECTION.DELETE_MSC_TABLE ('MSC_SR_LOOKUPS', p_instance_id, NULL);
	commit;
	MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_CALENDAR_MONTHS',p_instance_id, NULL);
	commit;

END PURGE_ODS_TABLES_DEL;
--=======================================================================

FUNCTION GET_M2A_DBLINK(pInstId NUMBER) RETURN VARCHAR

IS

lv_dblink VARCHAR2(30);

BEGIN

  SELECT DECODE( M2A_DBLINK, NULL, ' ', '@'||M2A_DBLINK)

    INTO lv_dblink

    FROM MSC_APPS_INSTANCES

   WHERE INSTANCE_ID= pInstId;



   RETURN lv_dblink;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    RETURN NULL;

END GET_M2A_DBLINK;

--=======================================================================
PROCEDURE PURGE_INSTANCE_DATA( ERRBUF        OUT NOCOPY VARCHAR2,

                    RETCODE       OUT NOCOPY NUMBER,

                    pInstList  tblTyp)

IS

TYPE cur_typ IS REF CURSOR;

v_index_cur     cur_typ;

lv_inst_str     VARCHAR2(2000);

lv_qry_str      VARCHAR2(4000);

lv_tab          VARCHAR2(30);

lv_tab_Part     VARCHAR2(30);

row_limit       number;

lv_dummy1       VARCHAR2(30);

lv_dummy2       VARCHAR2(30);

lv_schema       VARCHAR2(30);

lv_source_schema VARCHAR2(30);

lv_schema_short_nm       VARCHAR2(30);

lv_err_flag    BOOLEAN :=FALSE;

BEGIN





  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'*******  Prcocedure PURGE_INSTANCE_DATA       *******');

  -- Get row_limit and schema

   BEGIN



      SELECT application_short_name

        INTO lv_schema_short_nm

        FROM fnd_application

       WHERE application_id=724;



      IF NOT FND_INSTALLATION.GET_APP_INFO ( lv_schema_short_nm, lv_dummy1, lv_dummy2, lv_schema) THEN

        ERRBUF := lv_schema_short_nm||'--Schema not found';

        RETCODE := MSC_UTIL.G_ERROR;

        RETURN;

      END IF;

   EXCEPTION

    WHEN NO_DATA_FOUND THEN

        ERRBUF := 'Schema Short name for application_id 724 Not found';

        RETCODE := MSC_UTIL.G_ERROR;

        RETURN;

   END;



  row_limit := TO_NUMBER( FND_PROFILE.VALUE('MRP_PURGE_BATCH_SIZE'));

  --

  -- Generate List of Instances passed --

  lv_inst_str := '(';

  FOR indx IN pInstList.FIRST .. pInstList.LAST

  LOOP

    lv_inst_str := lv_inst_str  ||''''||  pInstList(indx)||''''  ||  ',' ;

  END LOOP;

  lv_inst_str := substr(lv_inst_str,1,length(lv_inst_str)-1)  ||  ')';

   --End  Generate List of Instances passed --



  lv_qry_str :=    'SELECT table_name,partition_name '

                  ||' FROM fnd_lookup_values a,DBA_TAB_PARTITIONS b'

                  ||' WHERE a.attribute2 = b.table_name' -- (Not in MSC_%)see that meaning is there in upper case

                  ||' AND b.table_owner = :B1'

                  ||' AND a.lookup_type IN (''MSC_ODS_TABLE'',''MSC_OTHER_TABLE'')'-- see that staging table can be included here

                  ||' AND a.ATTRIBUTE11 = ''Y''' -- Column SR_INSTANCE_ID Present

                  ||' AND a.enabled_flag = ''Y'''

                  ||' AND a.view_application_id = 700'

                  ||' AND a.language = userenv(''lang'')'

                  ||' AND a.attribute5 != ''U'''   -- Table is Partitioned

                  ||' AND NVL(a.attribute13,''-1'')!=''G'''

                  ||' AND b.partition_name like substr( a.attribute2,5)||''%'''

                  --AND  INSTR(partition_name,'__') > 0

                  ||' AND SUBSTR(b.partition_name,INSTR(partition_name,''__'')+2) IN '||lv_inst_str;



                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,lv_qry_str);

  --EXECUTE IMMEDIATE lv_qry_str1  INTO lv_tab_list,lv_Index_list ;

      BEGIN

       OPEN v_index_cur  FOR lv_qry_str USING lv_schema;

        LOOP

          FETCH v_index_cur INTO lv_tab, lv_tab_Part;

          EXIT WHEN v_index_cur%NOTFOUND;

             BEGIN

                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'ALTER TABLE '||lv_schema||'.'||lv_tab||' DROP PARTITION '||lv_tab_Part);

                EXECUTE IMMEDIATE 'ALTER TABLE '||lv_schema||'.'||lv_tab||' DROP PARTITION '||lv_tab_Part ;

             EXCEPTION

                WHEN OTHERS THEN

                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'ERROR IN DEL_INST --'||SQLERRM);

                RETCODE := MSC_UTIL.G_WARNING;

             END;

        END LOOP;

      CLOSE v_index_cur;

      EXCEPTION

      WHEN OTHERS THEN

              ERRBUF := SQLERRM;

              RETCODE := MSC_UTIL.G_ERROR;

              RETURN;

      END;



    -- make inst str number only

    SELECT REPLACE(lv_inst_str,'''','') INTO lv_inst_str  FROM DUAL;

    --

    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'*******  Delete Rows for  Instance  *******');

    FOR tab IN ( SELECT attribute2 tname,ATTRIBUTE12 Plan_Id

                   FROM fnd_lookup_values a, dba_tables b

                  WHERE a.attribute2 = b.table_name

                    AND b.owner = lv_schema

                    AND lookup_type IN ('MSC_ODS_TABLE','MSC_OTHER_TABLE')

                    AND enabled_flag = 'Y'

                    AND view_application_id = 700

                    AND language = userenv('lang')

                    AND attribute5='U'      -- Unpartitioned table

                    AND a.ATTRIBUTE11 = 'Y' -- Column SR_INSTANCE_ID Present

                    AND NVL(attribute13,'-1')<>'G') -- to check

    LOOP

      IF tab.Plan_Id = 'Y' THEN

        lv_qry_str := 'DELETE FROM '||lv_schema||'.'||tab.tname||' WHERE plan_id= -1 AND  sr_instance_id IN '||lv_inst_str||' AND ROWNUM <= '||row_limit;

       -- TRC('DELETE FROM '||tab.tname||' WHERE plan_id= -1 AND  sr_instance_id IN '||lv_inst_str);

      ELSE

        lv_qry_str := 'DELETE FROM '||lv_schema||'.'||tab.tname||' WHERE sr_instance_id IN '||lv_inst_str||' AND ROWNUM <= '||row_limit;

       -- TRC('DELETE FROM '||tab.tname||' WHERE sr_instance_id IN '||lv_inst_str);

      END IF;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,lv_qry_str);



      -- Delete Using Rownum Limitation

      LOOP

          lv_err_flag := FALSE;

          BEGIN

              EXECUTE IMMEDIATE lv_qry_str ;

          EXCEPTION

              WHEN OTHERS THEN

                RETCODE := MSC_UTIL.G_WARNING;

                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'Error while deleting from '||tab.tname|| '--'||SQLERRM);

                lv_err_flag := TRUE;

          END;

          EXIT WHEN (SQL%ROWCOUNT < row_limit) OR  (lv_err_flag = TRUE); -- Exit when Not enough rows to be deleted;

          COMMIT; -- After Commit SQL%ROWCOUNT always returns 0 <-- check whether you can get the desired row count after commit

      END LOOP;



    END LOOP;







    -- Delete Instance from MSC_INST_PARTITIONS, MSC_APPS_INSTANCES, MRP_AP_APPS_INSTANCES_ALL GET_DBLINK(pInstId NUMBER)



    -- get source schema short name.

     BEGIN

        SELECT application_short_name

          INTO lv_schema_short_nm

          FROM fnd_application

         WHERE application_id=704;

      EXCEPTION

        WHEN NO_DATA_FOUND THEN

        ERRBUF := 'Schema Short name for application_id 704 Not found';

        RETCODE := MSC_UTIL.G_WARNING;

      END;





        -- Delete from Source MRP_AP_APPS_INSTANCES_ALL using M2A DBLINK.

      IF  FND_INSTALLATION.GET_APP_INFO ( lv_schema_short_nm, lv_dummy1, lv_dummy2, lv_source_schema) THEN --schema name exist



          FOR indx IN pInstList.FIRST .. pInstList.LAST

          LOOP

            BEGIN

              lv_qry_str := 'DELETE FROM '||lv_source_schema ||'.MRP_AP_APPS_INSTANCES_ALL'||GET_M2A_DBLINK(pInstList(indx) )

                                                             ||' WHERE instance_id IN '||lv_inst_str;

              MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,lv_qry_str);

              EXECUTE IMMEDIATE lv_qry_str;

            EXCEPTION

              WHEN OTHERS THEN

                RETCODE := MSC_UTIL.G_WARNING;

                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'Error while deleting from MRP_AP_APPS_INSTANCES_ALL --'||SQLERRM);

            END;

          END LOOP;

       ELSE

          ERRBUF := 'Source Schema not found';

          RETCODE := MSC_UTIL.G_WARNING;

       END IF;

    --



    BEGIN -- delete  from MSC_INST_PARTITIONS --

      lv_qry_str := 'DELETE FROM '||lv_schema||'.MSC_INST_PARTITIONS WHERE instance_id IN '||lv_inst_str;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,lv_qry_str);

      EXECUTE IMMEDIATE lv_qry_str;

    EXCEPTION

          WHEN OTHERS THEN

            RETCODE := MSC_UTIL.G_WARNING;

            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'Error while deleting from MSC_INST_PARTITIONS --'||SQLERRM);

      END;

      --

    BEGIN -- delete from MSC_APPS_INSTANCES --

      lv_qry_str := 'DELETE FROM '||lv_schema||'.MSC_APPS_INSTANCES WHERE instance_id IN '||lv_inst_str;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,lv_qry_str);

      EXECUTE IMMEDIATE lv_qry_str;

    EXCEPTION

      WHEN OTHERS THEN

        RETCODE := MSC_UTIL.G_WARNING;

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'Error while deleting from MSC_APPS_INSTANCES --'||SQLERRM);

    END;

    COMMIT;

    --

  IF NVL(RETCODE,-1)  <> MSC_UTIL.G_WARNING THEN

      RETCODE := MSC_UTIL.G_SUCCESS;

  END IF;

EXCEPTION

  WHEN OTHERS THEN

        ERRBUF := SQLERRM;

        RETCODE := MSC_UTIL.G_ERROR;

END PURGE_INSTANCE_DATA;

---------------------------------PURGE_PLAN_DATA----------------------------------------



PROCEDURE PURGE_PLAN_DATA( ERRBUF        OUT NOCOPY VARCHAR2,

                    RETCODE       OUT NOCOPY NUMBER,

                    pPlanList tblTyp)

IS



TYPE cur_typ IS REF CURSOR;

v_plan_part_cur  cur_typ;

lv_plan_str	 VARCHAR2(2000);

lv_qry_str  	 VARCHAR2(4000);

lv_tab     	 VARCHAR2(30);

lv_tab_Part	 VARCHAR2(30);

row_limit      	 number;

lv_dummy1        VARCHAR2(30);

lv_dummy2      	 VARCHAR2(30);

lv_schema     	 VARCHAR2(30);

lv_schema_short_nm VARCHAR2(30);

lv_err_flag BOOLEAN:=FALSE;



BEGIN





 -- Get row_limit and  schema

   BEGIN



      SELECT application_short_name

        INTO lv_schema_short_nm

        FROM fnd_application

       WHERE application_id=724;



      IF NOT FND_INSTALLATION.GET_APP_INFO ( lv_schema_short_nm, lv_dummy1, lv_dummy2, lv_schema) THEN

        ERRBUF := lv_schema_short_nm||'--Schema not found ';

        RETCODE := MSC_UTIL.G_ERROR;

        RETURN;

      END IF;

   EXCEPTION

    WHEN NO_DATA_FOUND THEN

        ERRBUF := 'Schema Short name for application_id 724 Not found';

        RETCODE := MSC_UTIL.G_ERROR;

        RETURN;

   END;



  row_limit := TO_NUMBER( FND_PROFILE.VALUE('MRP_PURGE_BATCH_SIZE'));

  --

  -- Generate List of Instances passed --



  lv_plan_str := '(';

  FOR indx IN pPlanList.FIRST .. pPlanList.LAST

  LOOP

    lv_plan_str := lv_plan_str  ||''''||  pPlanList(indx)||''''  ||  ',' ;

  END LOOP;

  lv_plan_str := substr(lv_plan_str,1,length(lv_plan_str)-1)  ||  ')';

--End  Generate List of Instances passed --

--

  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'*******  Drop Plan Partition ***********');

  lv_qry_str := 'SELECT table_name,partition_name '

                  ||' FROM fnd_lookup_values a,DBA_TAB_PARTITIONS b'

                  ||' WHERE a.attribute2 = b.table_name' --

                  ||' AND b.table_owner = :B1'

                  ||' AND a.lookup_type IN (''MSC_ODS_TABLE'',''MSC_PDSONLY_TABLE'',''MSC_OTHER_TABLE'')'-- see that staging table can be included here

                  ||' AND a.ATTRIBUTE12 = ''Y''' -- Column PLAN_ID Present

                  ||' AND a.enabled_flag = ''Y'''

                  ||' AND a.view_application_id = 700'

                  ||' AND a.language = userenv(''lang'')'

                  ||' AND a.attribute5 != ''U'''   -- Table is Partitioned

                  ||' AND b.partition_name like substr( a.attribute2,5)||''%'''

                  ||' AND NVL(a.attribute13,''-1'')!=''G'''

                  ||' AND LTRIM(''MSC_''||partition_name, table_name||''_'') IN '||lv_plan_str;

  BEGIN

      OPEN v_plan_part_cur FOR lv_qry_str USING lv_schema;

      LOOP

          FETCH v_plan_part_cur INTO lv_tab, lv_tab_Part;

          EXIT WHEN v_plan_part_cur%NOTFOUND;

             BEGIN

                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'ALTER TABLE '||lv_schema||'.'||lv_tab||' DROP PARTITION '||lv_tab_Part);

                EXECUTE IMMEDIATE 'ALTER TABLE '||lv_schema||'.'||lv_tab||' DROP PARTITION '||lv_tab_Part;

             EXCEPTION

                WHEN OTHERS THEN

                    RETCODE := MSC_UTIL.G_WARNING;

             END;

         --TRC(lv_tab||'-----------'||lv_tab_Part);

      END LOOP;

      CLOSE v_plan_part_cur;

  EXCEPTION

      WHEN OTHERS THEN

        ERRBUF := SQLERRM;

        RETCODE := MSC_UTIL.G_ERROR;

        RETURN;

  END;

   -- change plan list to number only

   SELECT REPLACE(lv_plan_str,'''','') INTO lv_plan_str FROM DUAL;

   --

    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'*******  Delete Rows for plan***********');

    -- delete rows for Plan

    FOR tab IN (SELECT a.attribute2 tname

                  FROM fnd_lookup_values a,dba_tables b

                  WHERE a.attribute2 = b.table_name

                    AND b.owner = lv_schema

                    AND lookup_type IN ('MSC_ODS_TABLE','MSC_PDSONLY_TABLE','MSC_OTHER_TABLE')

                    AND enabled_flag = 'Y'

                    AND view_application_id = 700

                    AND language = userenv('lang')

                    AND attribute5 = DECODE(fnd_profile.value('MSC_SHARE_PARTITIONS'),'Y',attribute5,'U')      -- Unpartitioned table

                    AND a.ATTRIBUTE12 = 'Y' -- Column PLAN_ID Present

                    AND NVL(attribute13,'-1')<>'G')

    LOOP

     lv_qry_str  := 'DELETE FROM '||lv_schema||'.'||tab.tname||' WHERE plan_id  IN '||lv_plan_str||' AND ROWNUM <= '||row_limit;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,lv_qry_str);

      LOOP

          lv_err_flag := FALSE;

          BEGIN

              EXECUTE IMMEDIATE lv_qry_str ;

          EXCEPTION

              WHEN OTHERS THEN

              RETCODE := MSC_UTIL.G_WARNING;

              MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'ERROR IN DEL_INST --'||SQLERRM);

              lv_err_flag := TRUE;

          END;

          EXIT WHEN (SQL%ROWCOUNT < row_limit) OR  (lv_err_flag = TRUE); -- Exit when Not enough rows to be deleted;

          COMMIT;

      END LOOP;

    END LOOP;

    COMMIT;



    IF NVL(RETCODE,-1) <> MSC_UTIL.G_WARNING THEN

      RETCODE := MSC_UTIL.G_SUCCESS;

    END IF;

EXCEPTION

    WHEN OTHERS THEN

      ERRBUF := SQLERRM;

      RETCODE := MSC_UTIL.G_ERROR;

END PURGE_PLAN_DATA;

--======================================================================

PROCEDURE PURGE_INSTANCE_PLAN_DATA(  ERRBUF        OUT NOCOPY VARCHAR2,

                            RETCODE       OUT NOCOPY NUMBER,

                            pInstanceId   NUMBER,

                            pPlanId       NUMBER)

IS
BEGIN
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'****************START  PURGE_INSTANCE_PLAN_DATA**********************');

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'******---InstanceId = '||nvl(to_char(pInstanceId),'NULL')

				  || ' AND PlanId = '||nvl(to_char(pPlanId),'NULL')

				  ||'  -------***** ');



  IF pInstanceId IS NOT NULL THEN



    DECLARE

      lv_Inst_List tblTyp:=tblTyp(pInstanceId) ;

    BEGIN

      PURGE_INSTANCE_DATA(ERRBUF,RETCODE,lv_Inst_List);

      IF RETCODE = MSC_UTIL.G_ERROR THEN

          RETURN;

      END IF;

    END;



  END IF;



  IF pPlanId IS NOT NULL THEN



      DECLARE

        lv_Plan_List tblTyp:=tblTyp(pPlanId) ;

      BEGIN

        PURGE_PLAN_DATA(ERRBUF,RETCODE,lv_Plan_List);

      END;



  END IF;



  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'****************************END******************************************');



EXCEPTION

	WHEN OTHERS THEN

        	ERRBUF := SQLERRM;

	        RETCODE := MSC_UTIL.G_ERROR;

END PURGE_INSTANCE_PLAN_DATA;

PROCEDURE Purge_localid_table( pMode NUMBER,
                            pTable_name VARCHAR2,
                            pInstance_id NUMBER,
                            pPlan_id     NUMBER,
                            pWhereClause VARCHAR2
                            /*pIsLIDTable  NUMBER */) IS
    lv_cnt          NUMBER;
    lv_sql_stmt     VARCHAR2(2048);

    lv_task_start_time DATE;

    lv_partition_name  VARCHAR2(30);
    lv_is_plan         NUMBER;

    lv_msg_data        VARCHAR2(2048);
    lv_return_status   VARCHAR2(2048);
    lv_errtext         VARCHAR2(2048);

    lv_is_data_truncated  boolean := false;

BEGIN
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEV,'pWhereClause'|| pWhereClause || 'XXX');
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEV,'pTable_name'|| pTable_name || 'XXX');
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEV,'pInstance_id'|| pInstance_id || 'XXX');
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEV,'pPlan_id'|| pPlan_id || 'XXX');
/*
    IF pWhereClause IS NULL
     AND pMode = 1
     AND pInstance_id IS NOT NULL
     AND is_msctbl_partitioned( pTable_name) THEN

       IF pPlan_id= -1 OR pPlan_id IS NULL THEN
          lv_is_plan:= MSC_UTIL.SYS_NO;
       ELSE
          lv_is_plan:= MSC_UTIL.SYS_YES;
       END IF;

       msc_manage_plan_partitions.get_partition_name
                         ( pPlan_id,
                           pInstance_id,
                           pTable_name,
                           lv_is_plan,
                           lv_partition_name,
                           lv_return_status,
                           lv_msg_data);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Partition Name : '||lv_partition_name);
        IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN
         lv_sql_stmt:= 'ALTER TABLE '||pTable_name
                    ||' TRUNCATE PARTITION '||lv_partition_name;

          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
         AD_DDL.DO_DDL( APPLSYS_SCHEMA => v_applsys_schema,
                        APPLICATION_SHORT_NAME => 'MSC',
                        STATEMENT_TYPE => AD_DDL.ALTER_TABLE,
                        STATEMENT => lv_sql_stmt,
                        OBJECT_NAME => pTable_name);
            lv_is_data_truncated := true;
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'Table ' || pTable_name || 'Partition ' || lv_partition_name || ' truncated ');
        ELSE
            lv_is_data_truncated := false;
        END IF;
      END IF;

      IF NOT lv_is_data_truncated THEN
        */
             lv_sql_stmt:=   'DELETE  '||pTable_name ||
                             ' WHERE ROWNUM < :lv_pbs ' ;
         IF pInstance_id IS NOT NULL THEN
            --IF pIsLIDTable = 1 THEN
              lv_sql_stmt:=   lv_sql_stmt || ' AND INSTANCE_ID = ' || pInstance_id;
            --ELSE
            --  lv_sql_stmt:=   lv_sql_stmt || ' AND SR_INSTANCE_ID = ' || pInstance_id;
            --END IF;
         END IF;
         IF pPlan_id IS NOT NULL THEN
            lv_sql_stmt:=   lv_sql_stmt || ' AND Plan_id = ' || pPlan_id;
         END IF;

         IF pWhereClause IS NOT NULL THEN
             lv_sql_stmt:=   lv_sql_stmt || ' AND ' ||    pWhereClause;
         END IF;

          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
          lv_cnt := 0;
           LOOP
              EXECUTE IMMEDIATE lv_sql_stmt
                          USING  lv_pbs;
              EXIT WHEN SQL%ROWCOUNT= 0;
              lv_cnt := lv_cnt + SQL%ROWCOUNT;
             COMMIT;
           END LOOP;
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,lv_cnt || ' records deleted from ' || pTable_name);
      --END IF;
EXCEPTION
  WHEN OTHERS THEN
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error Wile purging data from ' || pTable_name);
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,lv_sql_stmt);
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,DBMS_UTILITY.FORMAT_ERROR_STACK);
END;

PROCEDURE PURGE_ODS_DATA(
               ERRBUF                            OUT NOCOPY VARCHAR2,
               RETCODE                           OUT NOCOPY NUMBER,
               pINSTANCE_ID                       IN  NUMBER,
               ppurgeglobalflag                        IN  NUMBER, --New
               pAPPROV_SUPPLIER_CAP_ENABLED       IN  NUMBER   ,
               pATP_RULES_ENABLED                 IN  NUMBER   ,
               pBOM_ENABLED                       IN  NUMBER   ,
               pBOR_ENABLED                       IN  NUMBER   ,
               pCALENDAR_ENABLED                  IN  NUMBER   ,
               pDEMAND_CLASS_ENABLED              IN  NUMBER   ,
               pITEM_SUBST_ENABLED                IN  NUMBER   ,
               pFORECAST_ENABLED                  IN  NUMBER   ,
               pITEM_ENABLED                      IN  NUMBER   ,
               pKPI_BIS_ENABLED                   IN  NUMBER   ,
               pMDS_ENABLED                       IN  NUMBER   ,
               pMPS_ENABLED                       IN  NUMBER   ,
               pOH_ENABLED                        IN  NUMBER   ,
               pPARAMETER_ENABLED                 IN  NUMBER   ,
               pPLANNER_ENABLED                   IN  NUMBER   ,
               pPO_RECEIPTS_ENABLED               IN  NUMBER   ,
               pPROJECT_ENABLED                   IN  NUMBER   ,
               pPUR_REQ_PO_ENABLED                IN  NUMBER   ,
               pRESERVES_HARD_ENABLED             IN  NUMBER   ,
               pRESOURCE_NRA_ENABLED              IN  NUMBER   ,
               pSafeStock_ENABLED                 IN  NUMBER   ,
               pSalesOrder_ENABLED                IN  NUMBER   ,
               pSH_ENABLED                        IN  NUMBER   ,
               pSOURCING_ENABLED                  IN  NUMBER   ,
               pSUB_INV_ENABLED                   IN  NUMBER   ,
               pSUPPLIER_RESPONSE_ENABLED         IN  NUMBER   ,
               pTP_ENABLED                        IN  NUMBER   ,
               pTRIP_ENABLED                      IN  NUMBER   ,
               pUNIT_NO_ENABLED                   IN  NUMBER   ,
               pUOM_ENABLED                       IN  NUMBER   ,
	             pUSER_COMPANY_ENABLED              IN  NUMBER   ,
               pUSER_SUPPLY_DEMAND                IN  NUMBER   ,
               pWIP_ENABLED                       IN  NUMBER   ,
               pSALES_CHANNEL_ENABLED             IN  NUMBER   ,
               pFISCAL_CALENDAR_ENABLED           IN  NUMBER   ,
               pINTERNAL_REPAIR_ENABLED           IN  NUMBER   ,
               pEXTERNAL_REPAIR_ENABLED           IN  NUMBER   ,
               pPAYBACK_DEMAND_SUPPLY_ENABLED     IN  NUMBER   ,
               pCURRENCY_CONVERSION_ENABLED	      IN  NUMBER   ,
               pDELIVERY_DETAILS_ENABLED	        IN  NUMBER
               )    IS


array1 entity_list  ;
pstatusflag number;
 i number :=1;
BEGIN

IF pAPPROV_SUPPLIER_CAP_ENABLED =1 THEN array1(i) := 'ASL'; i:=i+1;  END IF;
IF pATP_RULES_ENABLED =1 THEN array1(i) := 'ATP RULES'; i:=i+1;   END IF;
IF pBOM_ENABLED =1 THEN array1(i) := 'BOM'; i:=i+1;  END IF;
IF pBOR_ENABLED =1 THEN array1(i) := 'BOR'; i:=i+1;  END IF;
IF pCALENDAR_ENABLED =1 THEN array1(i) := 'CALENDARS'; i:=i+1;  END IF;
IF pDEMAND_CLASS_ENABLED =1 THEN array1(i) := 'DEMAND CLASSES'; i:=i+1;  END IF;
IF pITEM_SUBST_ENABLED =1 THEN array1(i) := 'END ITEM SUBSTITUTES'; i:=i+1;  END IF;
IF pFORECAST_ENABLED =1 THEN array1(i) := 'FORECASTS'; i:=i+1;  END IF;
IF pITEM_ENABLED =1 THEN array1(i) := 'ITEMS'; i:=i+1;  END IF;
IF pKPI_BIS_ENABLED =1 THEN array1(i) := 'KPI TARGETS'; i:=i+1;  END IF;
IF pMDS_ENABLED =1 THEN array1(i) := 'MDS'; i:=i+1;  END IF;
IF pMPS_ENABLED =1 THEN array1(i) := 'MPS'; i:=i+1;  END IF;
IF pOH_ENABLED =1 THEN array1(i) := 'ON HAND';i:=i+1;  END IF;
IF pPARAMETER_ENABLED =1 THEN array1(i) := 'PLANNING PARAM'; i:=i+1;  END IF;
IF pPLANNER_ENABLED =1 THEN  array1(i) := 'PLANNERS'; i:=i+1;  END IF;
IF pPO_RECEIPTS_ENABLED =1 THEN array1(i) := 'PO RECEIPTS';i:=i+1;  END IF;
IF pPROJECT_ENABLED =1 THEN array1(i) := 'PROJECTS TASKS';i:=i+1;  END IF;
IF pPUR_REQ_PO_ENABLED =1 THEN array1(i) := 'PO PR';i:=i+1;  END IF;
IF pRESERVES_HARD_ENABLED =1 THEN array1(i) := 'RESERVATIONS';i:=i+1;  END IF;
IF pRESOURCE_NRA_ENABLED =1 THEN array1(i) := 'RESOURCE AVAILABILITY';i:=i+1;  END IF;
IF pSafeStock_ENABLED =1 THEN array1(i) := 'SAFETY STOCKS';i:=i+1;  END IF;
IF pSalesOrder_ENABLED =1 THEN array1(i) := 'SALES ORDERS';i:=i+1;  END IF;
IF pSH_ENABLED =1 THEN array1(i) := 'SOURCING HISTORY';i:=i+1;  END IF;
IF pSOURCING_ENABLED =1 THEN array1(i) := 'SOURCING';i:=i+1;  END IF;
IF pSUB_INV_ENABLED =1 THEN array1(i) := 'SUB INVENTORIES';i:=i+1;  END IF;
IF pSUPPLIER_RESPONSE_ENABLED =1 THEN array1(i) := 'SUPPLIER RESPONSE';i:=i+1;  END IF;
IF pTP_ENABLED =1 THEN array1(i) := 'TRADING PARTNERS';i:=i+1;  END IF;
IF pTRIP_ENABLED =1 THEN array1(i) := 'TRANSPORTATION DETAILS';i:=i+1;  END IF;
IF pUNIT_NO_ENABLED =1 THEN array1(i) := 'UNIT NUMBERS';i:=i+1;  END IF;
IF pUOM_ENABLED =1 THEN array1(i) := 'UOM';i:=i+1;  END IF;
IF pUSER_COMPANY_ENABLED =1 THEN array1(i) := 'USER COMPANY ASSOCIATIONS';i:=i+1;  END IF;
IF pUSER_SUPPLY_DEMAND =1 THEN array1(i) := 'USER SUPPLIES AND DEMANDS';i:=i+1;  END IF;
IF pWIP_ENABLED =1 THEN array1(i) := 'WIP and OSFM';i:=i+1;  END IF;
IF pSALES_CHANNEL_ENABLED =1 THEN array1(i) := 'SALES CHANNELS';i:=i+1;  END IF;
IF pFISCAL_CALENDAR_ENABLED =1 THEN array1(i) := 'FISCAL CALENDAR';i:=i+1;  END IF;
IF pINTERNAL_REPAIR_ENABLED =1 THEN array1(i) := 'IRO';i:=i+1;  END IF;
IF pEXTERNAL_REPAIR_ENABLED =1 THEN array1(i) := 'ERO';i:=i+1;  END IF;
IF pPAYBACK_DEMAND_SUPPLY_ENABLED =1 THEN array1(i) := 'PAYBACK DEMAND SUPPLY';i:=i+1;  END IF;
IF pCURRENCY_CONVERSION_ENABLED =1 THEN array1(i) := 'CURRENCY CONVERSIONS';i:=i+1;  END IF;
IF pDELIVERY_DETAILS_ENABLED =1 THEN array1(i) := 'DELIVERY DETAILS';i:=i+1;  END IF;

  purge_inst_entity_ods_data(pINSTANCE_ID,array1,2,ppurgeglobalflag,pstatusflag);

if pstatusflag =MSC_UTIL.G_SUCCESS THEN
RETCODE := MSC_UTIL.G_SUCCESS;
END IF ;

EXCEPTION WHEN OTHERS THEN
    RETCODE := MSC_UTIL.G_ERROR;

END PURGE_ODS_DATA;

PROCEDURE PURGE_ODS_LEG_DATA(
               ERRBUF                            OUT NOCOPY VARCHAR2,
               RETCODE                           OUT NOCOPY NUMBER,
               pINSTANCE_ID                       IN  NUMBER,
               ppurgelocalidflag                        IN NUMBER,
               ppurgeglobalflag                      IN NUMBER,
               pAPPROV_SUPPLIER_CAP_ENABLED       IN  NUMBER   ,
               pATP_RULES_ENABLED                 IN  NUMBER   ,
               pBOM_ENABLED                       IN  NUMBER   ,
               pRESOURCE_ENABLED                  IN  NUMBER   ,
               pROUTING_ENABLED                   IN  NUMBER   ,
               pOPERATION_ENABLED                 IN  NUMBER   ,
               pBOR_ENABLED                       IN  NUMBER   ,
               pCALENDAR_ENABLED                  IN  NUMBER   ,
               pCALENDAR_ASSIGN_ENABLED           IN  NUMBER   ,
               pDEMAND_CLASS_ENABLED              IN  NUMBER   ,
               pITEM_SUBST_ENABLED                IN  NUMBER   ,
               pDESIGNATORS_ENABLED               IN  NUMBER   ,
               pFORECAST_ENABLED                  IN  NUMBER   ,
               pITEM_ENABLED                      IN  NUMBER   ,
               pITEM_CATEGORIES_ENABLED           IN  NUMBER   ,
               pCATEGORY_SETS_ENABLED             IN  NUMBER   ,
               pKPI_BIS_ENABLED                   IN  NUMBER   ,
               pMDS_ENABLED                       IN  NUMBER   ,
               pMPS_ENABLED                       IN  NUMBER   ,
               pOH_ENABLED                        IN  NUMBER   ,
               pPARAMETER_ENABLED                 IN  NUMBER   ,
               pPLANNER_ENABLED                   IN  NUMBER   ,
               pPO_RECEIPTS_ENABLED               IN  NUMBER   ,
               pPROJECT_ENABLED                   IN  NUMBER   ,
               pPUR_REQ_PO_ENABLED                IN  NUMBER   ,
               pRESERVES_HARD_ENABLED             IN  NUMBER   ,
               pRESOURCE_NRA_ENABLED              IN  NUMBER   ,
               pSafeStock_ENABLED                 IN  NUMBER   ,
               pSalesOrder_ENABLED                IN  NUMBER   ,
               pSH_ENABLED                        IN  NUMBER   ,
               pSHIP_METHOD_ENABLED               IN  NUMBER   ,
               pSOURCING_ENABLED                  IN  NUMBER   ,
               pSUB_INV_ENABLED                   IN  NUMBER   ,
               pSUPPLIER_RESPONSE_ENABLED         IN  NUMBER   ,
               pTP_ENABLED                        IN  NUMBER   ,
               pTRIP_ENABLED                      IN  NUMBER   ,
               pUNIT_NO_ENABLED                   IN  NUMBER   ,
               pUOM_ENABLED                       IN  NUMBER   ,
               pUOM_CONVERSIONS_ENABLED           IN  NUMBER   ,
               pUSER_COMPANY_ENABLED              IN  NUMBER   ,
               pUSER_DEMAND                       IN  NUMBER   ,
               pUSER_SUPPLY                       IN  NUMBER   ,
               pWIP_ENABLED                       IN  NUMBER   ,
               pSALES_CHANNEL_ENABLED             IN  NUMBER   ,
               pFISCAL_CALENDAR_ENABLED           IN  NUMBER   ,
               pINTERNAL_REPAIR_ENABLED           IN  NUMBER   ,
               pEXTERNAL_REPAIR_ENABLED           IN  NUMBER   ,
               pPAYBACK_DEMAND_SUPPLY_ENABLED     IN  NUMBER   ,
               pCURRENCY_CONVERSION_ENABLED       IN  NUMBER   ,
               pDELIVERY_DETAILS_ENABLED          IN  NUMBER
               )
           IS

array1 entity_list ;
pstatusflag number;
i number :=1;
BEGIN

IF pAPPROV_SUPPLIER_CAP_ENABLED =1 THEN array1(i) := 'ASL'; i:=i+1; END IF;
IF pATP_RULES_ENABLED =1 THEN array1(i) := 'ATP RULES'; i:=i+1; END IF;
IF pBOM_ENABLED =1 THEN array1(i) := 'BOM'; i:=i+1; END IF;
IF pRESOURCE_ENABLED =1 THEN array1(i) := 'RESOURCES'; i:=i+1; END IF;
IF pROUTING_ENABLED =1 THEN array1(i) := 'ROUTINGS'; i:=i+1; END IF;
IF pOPERATION_ENABLED =1 THEN array1(i) := 'OPERATIONS';i:=i+1; END IF;
IF pBOR_ENABLED =1 THEN array1(i) := 'BOR';i:=i+1; END IF;
IF pCALENDAR_ENABLED =1 THEN array1(i) := 'CALENDARS';i:=i+1; END IF;
IF pCALENDAR_ASSIGN_ENABLED =1 THEN array1(i) := 'CALENDAR_ASSIGNMENTS';i:=i+1; END IF;
IF pDEMAND_CLASS_ENABLED =1 THEN array1(i) := 'DEMAND CLASSES'; i:=i+1; END IF;
IF pITEM_SUBST_ENABLED =1 THEN array1(i) := 'END ITEM SUBSTITUTES'; i:=i+1;END IF;
IF pDESIGNATORS_ENABLED =1 THEN array1(i) := 'DESIGNATORS';i:=i+1; END IF;
IF pFORECAST_ENABLED =1 THEN array1(i) := 'FORECASTS'; i:=i+1; END IF;
IF pITEM_ENABLED  =1 THEN array1(i) := 'ITEMS';i:=i+1; END IF;
IF pITEM_CATEGORIES_ENABLED =1 THEN  array1(i) := 'ITEM_CATEGORIES';i:=i+1; END IF;
IF pCATEGORY_SETS_ENABLED =1 THEN array1(i) := 'CATEGORY_SETS'; i:=i+1;END IF;
IF pKPI_BIS_ENABLED =1 THEN array1(i) := 'KPI TARGETS'; i:=i+1;END IF;
IF pMDS_ENABLED =1 THEN array1(i) := 'MDS';i:=i+1; END IF;
IF pMPS_ENABLED =1 THEN array1(i) := 'MPS'; i:=i+1;END IF;
IF pOH_ENABLED =1 THEN array1(i) := 'ON HAND'; i:=i+1; END IF;
IF pPARAMETER_ENABLED =1 THEN array1(i) := 'PLANNING PARAM';i:=i+1; END IF;
IF pPLANNER_ENABLED =1 THEN array1(i) := 'PLANNERS'; i:=i+1; END IF;
IF pPO_RECEIPTS_ENABLED =1 THEN array1(i) := 'PO RECEIPTS'; i:=i+1;END IF;
IF pPROJECT_ENABLED =1 THEN array1(i) := 'PROJECTS TASKS'; i:=i+1; END IF;
IF pPUR_REQ_PO_ENABLED =1 THEN array1(i) := 'PO PR';i:=i+1; END IF;
IF pRESERVES_HARD_ENABLED =1 THEN array1(i) := 'RESERVATIONS';i:=i+1; END IF;
IF pRESOURCE_NRA_ENABLED =1 THEN array1(i) := 'RESOURCE AVAILABILITY';i:=i+1; END IF;
IF pSafeStock_ENABLED =1 THEN array1(i) := 'SAFETY STOCKS';i:=i+1; END IF;
IF pSalesOrder_ENABLED =1 THEN array1(i) := 'SALES ORDERS';i:=i+1; END IF;
IF pSH_ENABLED =1 THEN array1(i) := 'SOURCING HISTORY'; i:=i+1; END IF;
IF pSHIP_METHOD_ENABLED=1 THEN array1(i) := 'SHIPMETHODS'; i:=i+1; END IF;
IF pSOURCING_ENABLED =1 THEN array1(i) := 'SOURCING RULES'; i:=i+1; END IF;
IF pSUB_INV_ENABLED =1 THEN array1(i) := 'SUB INVENTORIES'; i:=i+1; END IF;
IF pSUPPLIER_RESPONSE_ENABLED =1 THEN array1(i) := 'SUPPLIER RESPONSE'; i:=i+1; END IF;
IF pTP_ENABLED =1 THEN array1(i) := 'TRADING PARTNERS'; i:=i+1;END IF;
IF pTRIP_ENABLED =1 THEN array1(i) := 'TRANSPORTATION DETAILS'; i:=i+1; END IF;
IF pUNIT_NO_ENABLED =1 THEN array1(i) := 'UNIT NUMBERS'; i:=i+1;END IF;
IF pUOM_ENABLED =1 THEN array1(i) := 'UOM'; i:=i+1;END IF;
IF pUOM_CONVERSIONS_ENABLED =1 THEN array1(i) := 'UOM CONVERSIONS'; i:=i+1; END IF;
IF pUSER_COMPANY_ENABLED =1 THEN array1(i) := 'USER COMPANY ASSOCIATIONS'; i:=i+1;END IF;
IF pUSER_DEMAND =1 THEN array1(i) := 'USER DEMAND';i:=i+1; END IF;
IF pUSER_SUPPLY =1 THEN array1(i) := 'USER SUPPLY'; i:=i+1;END IF;
IF pWIP_ENABLED =1 THEN array1(i) := 'WIP'; i:=i+1; END IF;
IF pSALES_CHANNEL_ENABLED =1 THEN array1(i) := 'SALES CHANNELS'; i:=i+1; END IF;
IF pFISCAL_CALENDAR_ENABLED =1 THEN array1(i) := 'FISCAL CALENDAR'; i:=i+1;END IF;
IF pINTERNAL_REPAIR_ENABLED =1 THEN array1(i) := 'IRO'; i:=i+1;END IF;
IF pEXTERNAL_REPAIR_ENABLED =1 THEN array1(i) := 'ERO'; i:=i+1; END IF;
IF pPAYBACK_DEMAND_SUPPLY_ENABLED =1 THEN array1(i) := 'PAYBACK DEMAND SUPPLY'; i:=i+1;END IF;
IF pCURRENCY_CONVERSION_ENABLED =1 THEN array1(i) := 'CURRENCY CONVERSIONS'; i:=i+1; END IF;
IF pDELIVERY_DETAILS_ENABLED =1 THEN array1(i) := 'DELIVERY DETAILS';i:=i+1; END IF;

  purge_inst_entity_ods_data(pINSTANCE_ID,array1,ppurgelocalidflag,ppurgeglobalflag,pstatusflag);

if pstatusflag =MSC_UTIL.G_SUCCESS THEN
RETCODE := MSC_UTIL.G_SUCCESS;
end if;

EXCEPTION WHEN OTHERS THEN
    RETCODE := MSC_UTIL.G_ERROR;

END PURGE_ODS_LEG_DATA;

PROCEDURE PURGE_INST_ENTITY_ODS_DATA (
            pINSTANCE_ID                       IN  NUMBER,
            parray                             IN entity_list,
            ppurgelocalidflag                  IN NUMBER,
            ppurgeglobalflag                   IN NUMBER,
            pstatusflag                      OUT NOCOPY NUMBER
              )
          IS

TYPE refCursorTp IS REF CURSOR;
c1 refCursorTp;

lv_prev_entity  Varchar2(50);
lv_prev_table   Varchar2(40) := 'NOT INITIALIZED';
lv_sql1 varchar2(2000);
lv_where_clause varchar2(200);
lv_stmt_empty   NUMBER := 1;

lv_inst_id  number;
lv_pln_id   number := -1;
lv_inst_type number;

p_entity_name Varchar2(50);
p_table_name Varchar2(50);
p_local_id_table Varchar2(50);
p_local_id_entity Varchar2(50);
p_where_clause varchar2(200);
p_instance_flag number;
p_plan_flag number;
p_global_flag number;
p_count number;


BEGIN

lv_sql1 := 'Select distinct entity_name ENT,table_name,local_id_table,local_id_entity,'
           ||'where_clause, nvl(instance_id,2) instance_flag, '
           ||'  nvl(plan_id,2) plan_flag, nvl(global,2) global_flag '
           ||'  from msc_entity_table_map_v where nvl(delete_flag,2) = 1 and '
           ||' UPPER(entity_name)= :entityname'
           ;

select instance_type into lv_inst_type from msc_apps_instances where instance_id = pINSTANCE_ID;

if lv_inst_type = G_INS_OTHER then
lv_sql1 := replace(lv_sql1, 'entity_name', 'leg_entity_name');
end if;

if ppurgeglobalflag = 2 then
lv_sql1 := lv_sql1 || ' and nvl(global,2) = 2 ' ;
end if;

lv_sql1 := lv_sql1 ||' order by table_name ';

for i in parray.FIRST..parray.LAST loop

open c1  for lv_sql1 using UPPER(parray(i)) ;  --ref cursor
p_count :=0;
  LOOP
  fetch c1 into p_entity_name,p_table_name,p_local_id_table,
  p_local_id_entity,p_where_clause,p_instance_flag,p_plan_flag,p_global_flag ;

  exit when c1%NOTFOUND;

  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEV, p_entity_name );
  /*
   IF lv_prev_entity <> p_entity_name THEN
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,p_entity_name );
    lv_prev_entity := p_entity_name;
    lv_prev_table   := 'NOT INITIALIZED';
  END IF;
  */

   lv_where_clause := '';
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEV,p_table_name || '   ' || lv_prev_table);

  IF p_table_name <> lv_prev_table THEN
    lv_prev_table := p_table_name;

   IF p_where_clause = '' OR p_where_clause IS NULL THEN
      lv_where_clause := NULL;
    ELSE
      lv_where_clause :=  'AND ' ||p_where_clause ;
    END IF;

    IF p_instance_flag = 1 THEN
      lv_inst_id := pINSTANCE_ID;
    ELSE
      lv_inst_id := NULL;
    END IF;

    IF p_plan_flag = 1 THEN
      lv_pln_id := -1;
    ELSE
      lv_pln_id := NULL;
    END IF;
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEV,'delete_msc_table  1' );
     DELETE_MSC_TABLE(p_table_name,lv_inst_id,lv_pln_id,lv_where_clause);

  END IF;

   IF (ppurgelocalidflag =MSC_UTIL.SYS_YES AND p_local_id_table IS NOT NULL) THEN
      lv_where_clause :=  ' ENTITY_NAME = ''' || p_local_id_table || ''' ';
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEV,'Purge_table_data  2' );
       Purge_localid_table(2,p_local_id_table,pINSTANCE_ID,NULL,lv_where_clause);
  END IF;

 END loop;


CLOSE c1;
    lv_prev_entity := p_entity_name;
    lv_prev_table   := 'NOT INITIALIZED';

END LOOP;

  pstatusflag :=MSC_UTIL.G_SUCCESS;

  EXCEPTION WHEN OTHERS THEN
    pstatusflag :=  MSC_UTIL.G_ERROR;


END PURGE_INST_ENTITY_ODS_DATA;

END MSC_PURGE_LID ;

/
