--------------------------------------------------------
--  DDL for Package Body MSC_CL_EXCHANGE_PARTTBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_EXCHANGE_PARTTBL" AS
/* $Header: MSCCLJAB.pls 120.19.12010000.4 2009/09/09 11:25:16 sbyerram ship $ */

   v_is_initialized      BOOLEAN:= FALSE;  /* default to FALSE */

   v_partTblList TblNmTblTyp:=
                 TblNmTblTyp( 'MSC_SYSTEM_ITEMS',
                              'MSC_RESOURCE_REQUIREMENTS',
                              'MSC_SUPPLIES',
                              'MSC_BOM_COMPONENTS',
                              'MSC_ITEM_CATEGORIES',
                              'MSC_ITEM_SUBSTITUTES',
                              'MSC_OPERATION_RESOURCES',
                              'MSC_OPERATION_RESOURCE_SEQS',
                              'MSC_ROUTING_OPERATIONS',
                              'MSC_DEMANDS',
                              'MSC_JOB_OPERATION_NETWORKS',
                              'MSC_JOB_OPERATIONS',
                              'MSC_JOB_REQUIREMENT_OPS',
                              'MSC_JOB_OP_RESOURCES',
                              'MSC_RESOURCE_INSTANCE_REQS',   /* ds_plan: chaneg */
                              'MSC_JOB_OP_RES_INSTANCES',	 /* ds_plan: change */
                              'MSC_SALES_ORDERS'
                           );

   /* concatenate the tempTblList with the instance_code to be the exact
      temp table name */
   v_tempTblList TblNmTblTyp:=
                 TblNmTblTyp( 'SYSTEM_ITEMS_',
                              'RESOURCE_REQUIREMENTS_',
                              'SUPPLIES_',
                              'BOM_COMPONENTS_',
                              'ITEM_CATEGORIES_',
                              'ITEM_SUBSTITUTES_',
                              'OPERATION_RESOURCES_',
                              'OPERATION_RESOURCE_SEQS_',
                              'ROUTING_OPERATIONS_',
                              'DEMANDS_',
                              'JOB_OPERATION_NETWORKS_',
                              'JOB_OPERATIONS_',
                              'JOB_REQUIREMENT_OPS_',
                              'JOB_OP_RESOURCES_',
                              'RESOURCE_INSTANCE_REQS_',  /* ds_plan: change */
                              'JOB_OP_RES_INSTANCES_',    /* ds_plan: change */
                              'SALES_ORDERS_'
                            );


   v_is_TTL_initialized  BOOLEAN:= FALSE;  /* default to FALSE */

   v_sql_stmt VARCHAR2(4000);
   v_applsys_schema  VARCHAR2(32);
   v_msc_schema      VARCHAR2(32);

   v_instance_id    NUMBER;
   v_instance_code  VARCHAR2(3);

   v_100K VARCHAR2(20) := '102400';
   v_1M   VARCHAR2(20) := '1048576';
   v_10M  VARCHAR2(20) := '10485760';



/* ======== private functions ========= */
/* ======== Log Messages ========== */
PROCEDURE LOG_MESSAGE(  pBUFF IN VARCHAR2)
IS
BEGIN
  IF fnd_global.conc_request_id > 0  THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
	null;
  ELSE
      --DBMS_OUTPUT.PUT_LINE( pBUFF);
	null;
  END IF;
END LOG_MESSAGE;

PROCEDURE TRC( pBUFF IN VARCHAR2)
IS
BEGIN
  IF fnd_global.conc_request_id > 0  THEN
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,  '<trc '||TO_CHAR(SYSDATE,'HH24:MI:SS>')||pBUFF);
  ELSE
     --DBMS_OUTPUT.PUT_LINE( '<trc '||pBUFF);
     null;
  END IF;
END TRC;

/* =========== Initialize Schema ============= */
FUNCTION Initialize_Schema_PVT RETURN BOOLEAN
IS
   lv_retval         BOOLEAN;
   lv_dummy1         VARCHAR2(32);
   lv_dummy2         VARCHAR2(32);

   CURSOR c_msc IS
   SELECT a.oracle_username
     FROM FND_ORACLE_USERID a,
          FND_PRODUCT_INSTALLATIONS b
    WHERE a.oracle_id = b.oracle_id
      AND b.application_id= 724;

BEGIN
   trc( 'st:Initialize_Schema_PVT');
   /* APPLSYS */
   lv_retval := FND_INSTALLATION.GET_APP_INFO(
                    'FND', lv_dummy1,lv_dummy2, v_applsys_schema);
   /* MSC */
   OPEN c_msc;
   FETCH c_msc INTO v_msc_schema;
   CLOSE c_msc;

   trc( 'en:Initialize_Schema_PVT');
   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
      IF c_msc%ISOPEN THEN CLOSE c_msc; END IF;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<Initialize_Schema_PVT>>');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
      RETURN FALSE;
END Initialize_Schema_PVT;

/* =========== Initialize Temporary Table List ============= */
FUNCTION Initialize_TTL_List_PVT RETURN BOOLEAN
IS
BEGIN
   trc( 'st:Initialize_TTL_List_PVT');

   /* concatenate the tempTblList with the instance_code to be the exact
      temp table name */
   IF NOT v_is_TTL_initialized THEN
          trc( 'ST:V_PARTtBLlIST COUNT = '|| to_char(v_partTblList.COUNT));
      FOR i IN 1..v_partTblList.COUNT LOOP
          v_tempTblList(i):= v_tempTblList(i)||v_instance_code;
      END LOOP;

      v_is_TTL_initialized:= TRUE;
   END IF;

   trc( 'en:Initialize_TTL_List_PVT');
   RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<Initialize_TTL_List_PVT>>');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
      RETURN FALSE;
END Initialize_TTL_List_PVT;


FUNCTION Initialize_SWAP_Tbl_List( p_instance_id   IN NUMBER,
                                   p_instance_code IN VARCHAR2)
RETURN BOOLEAN
IS
BEGIN

   IF NOT Initialize_Schema_PVT   THEN RETURN FALSE; END IF;

/* Add the following details for each table

   v_swapTblList(1).ods_table_name        := 'MSC_TABLE_NAME';  --ODS table name
   v_swapTblList(1).stg_table_name        := 'MSC_ST_TABLE_NAME';  --Staging table name
   v_swapTblList(1).temp_table_name       := 'TABLE_NAME_'|| p_instance_code ;  --Temp table name
   v_swapTblList(1).stg_table_partn_name  := 'TABLE_NAME_' || p_instance_id ;  -- staging table partition name
   v_swapTblList(1).entity_name           := 'Entity Name'; --Entity name
   v_swapTblList(1).column_name           := 'entity_status'; --status column in msc_coll_parameters to track the swap status
*/
   v_swapTblList(1).ods_table_name        := 'MSC_DELIVERY_DETAILS';
   v_swapTblList(1).stg_table_name        := 'MSC_ST_DELIVERY_DETAILS';
   v_swapTblList(1).temp_table_name       := 'DELIVERY_DETAILS_'|| p_instance_code ;
   v_swapTblList(1).stg_table_partn_name  := 'DELIVERY_DETAILS_' || p_instance_id ;
   v_swapTblList(1).entity_name           := 'Delivery Details';
   v_swapTblList(1).column_name           := 'DELIVERY_DTL_SWAP_FLAG';

   v_swapTblList(2).ods_table_name        := 'MSC_REGION_LOCATIONS';
   v_swapTblList(2).stg_table_name        := 'MSC_ST_REGION_LOCATIONS';
   v_swapTblList(2).temp_table_name       := 'REGION_LOCATIONS_'|| p_instance_code ;
   v_swapTblList(2).stg_table_partn_name  := 'REGION_LOCATIONS_' || p_instance_id ;
   v_swapTblList(2).entity_name           := 'Sourcing Rules';
   v_swapTblList(2).column_name           := 'SOURCING_DTL_SWAP_FLAG';

   v_swapTblList(3).ods_table_name        := 'MSC_ZONE_REGIONS';
   v_swapTblList(3).stg_table_name        := 'MSC_ST_ZONE_REGIONS';
   v_swapTblList(3).temp_table_name       := 'ZONE_REGIONS_'|| p_instance_code ;
   v_swapTblList(3).stg_table_partn_name  := 'ZONE_REGIONS_' || p_instance_id ;
   v_swapTblList(3).entity_name           := 'Sourcing Rules';
   v_swapTblList(3).column_name           := 'SOURCING_DTL_SWAP_FLAG';

   v_swapTblList(4).ods_table_name        := 'MSC_REGIONS';
   v_swapTblList(4).stg_table_name        := 'MSC_ST_REGIONS';
   v_swapTblList(4).temp_table_name       := 'REGIONS_'|| p_instance_code ;
   v_swapTblList(4).stg_table_partn_name  := 'REGIONS_' || p_instance_id ;
   v_swapTblList(4).entity_name           := 'Sourcing Rules';
   v_swapTblList(4).column_name           := 'SOURCING_DTL_SWAP_FLAG';

   RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<Initialize_SWAP_Tbl_List_PVT>>');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
      RETURN FALSE;
END Initialize_SWAP_Tbl_List;

FUNCTION Drop_Temp_Tab_PVT(pTableName VARCHAR2) RETURN BOOLEAN
IS
   CURSOR c_query_table( p_tblname IN VARCHAR2) IS
   SELECT 1
     FROM ALL_TABLES
    WHERE table_name= upper(p_tblname)
    AND owner = v_msc_schema;

   lv_table_exist NUMBER;
BEGIN
   trc('st:Drop_Temp_Tab_PVT :' || pTableName);
   /* dropTemparyTable; */
       lv_table_exist := SYS_NO;
       OPEN  c_query_table( pTableName);
       FETCH c_query_table INTO lv_table_exist;
       CLOSE c_query_table;

       IF lv_table_exist=SYS_YES THEN
          v_sql_stmt := 'DROP TABLE '||pTableName;

          ad_ddl.do_ddl( applsys_schema => v_applsys_schema,
                         application_short_name => 'MSC',
                         statement_type => AD_DDL.DROP_TABLE,
                         statement => v_sql_stmt,
                         object_name => pTableName);
       END IF;

   trc('en:Drop_Temp_Tab_PVT');
   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  '<<Drop_Temp_Tab_PVT>>');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
      RETURN FALSE;
END Drop_Temp_Tab_PVT;

FUNCTION get_block_size RETURN NUMBER
IS
   lv_block_size NUMBER := 8192;
BEGIN

   select value
   into  lv_block_size
   from v$parameter
   where name = 'db_block_size' ;
   return lv_block_size ;

EXCEPTION
   WHEN OTHERS THEN
     lv_block_size := 8192;
     return lv_block_size;

END get_block_size;

/* =========== Create Temporary Tables ============= */
FUNCTION Create_Temp_Tab_PVT(pTableName    VARCHAR2,
                             pTmpTableName VARCHAR2) RETURN BOOLEAN
IS
   lv_partition_name  VARCHAR2(30);
   lv_return_status   VARCHAR2(2048);
   lv_msg_data        VARCHAR2(2048);
   lv_extent_management VARCHAR2(10);
   lv_allocation_type	VARCHAR2(9);
   lv_part_exists     NUMBER := 0;

   CURSOR c_part_para( p_owner IN VARCHAR,
                       p_tbl   IN VARCHAR,
                       p_partname IN VARCHAR) IS
   SELECT atp.tablespace_name,
          decode(atp.initial_extent, NULL, '', ' INITIAL ' || atp.initial_extent),
          decode(atp.next_extent, NULL, '', ' NEXT ' || atp.next_extent),
          decode(atp.pct_increase, NULL, '', ' PCTINCREASE ' || atp.pct_increase),
          decode(atp.pct_free, NULL, '', ' PCTFREE ' || atp.pct_free),
          decode(atp.ini_trans, NULL, '', ' INITRANS ' || atp.ini_trans),
          decode(atp.max_trans, NULL, '', ' MAXTRANS ' || atp.max_trans),
          dt.EXTENT_MANAGEMENT,
          dt.ALLOCATION_TYPE
     FROM ALL_TAB_PARTITIONS atp ,
          dba_tablespaces dt
    WHERE atp.table_name = p_tbl
      AND atp.table_owner = p_owner
      AND atp.partition_name=p_partname
      AND atp.TABLESPACE_Name = dt.TABLESPACE_NAME;


   lv_tablespace_name VARCHAR2(30);
   lv_initial_extent  VARCHAR2(50);
   lv_next_extent     VARCHAR2(50);
   lv_pct_increase    VARCHAR2(50);
   lv_storage_clause   VARCHAR2(255);

   lv_ini_trans      VARCHAR2(50);
   lv_max_trans      VARCHAR2(50);
   lv_pct_free        VARCHAR2(50);



BEGIN
   trc('st:Create_Temp_Tab_PVT');
   /* createTempraryTable; */

   trc('st ' || pTableName);

       msc_manage_plan_partitions.get_partition_name
                         ( -1,
                           v_instance_id,
                           pTableName,
                           SYS_NO,
                           lv_partition_name,
                           lv_return_status,
                           lv_msg_data);
   trc('i='|| lv_msg_data);

      select count(*)
        into lv_part_exists
        from ALL_TAB_PARTITIONS
       where table_name = pTableName
         AND table_owner = v_msc_schema
         AND partition_name=lv_partition_name;

      IF lv_part_exists = 0 THEN
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  '<<Create_Temp_Tab_PVT>>');
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Specified partition: ' || lv_partition_name || ' on table: '|| pTableName ||' does not exist');
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Please create all the missing partitions');
       RETURN FALSE;
      END IF;

      OPEN c_part_para( v_msc_schema, pTableName,lv_partition_name);
       FETCH c_part_para
        INTO lv_tablespace_name,
             lv_initial_extent,
             lv_next_extent,
             lv_pct_increase,
             lv_pct_free,
             lv_ini_trans,
             lv_max_trans,
             lv_extent_management,
             lv_allocation_type;
       CLOSE c_part_para;

     IF (lv_extent_management = 'DICTIONARY' OR (lv_extent_management = 'LOCAL' AND  lv_allocation_type = 'USER')) THEN
     			IF (lv_initial_extent is  null and  lv_next_extent is  null and  lv_pct_increase is  null) THEN
     					lv_storage_clause:='';
     			ELSE
     					lv_storage_clause:=' STORAGE( ' || lv_initial_extent || lv_next_extent || lv_pct_increase ||')';
     			END IF;
     END IF ;

     IF (  lv_extent_management = 'LOCAL' AND  lv_allocation_type = 'SYSTEM') THEN
      		lv_next_extent :='';
      		lv_pct_increase := '';
      		IF (lv_initial_extent is  null and  lv_next_extent is  null and  lv_pct_increase is  null) THEN
     					lv_storage_clause:='';
     			ELSE
     					lv_storage_clause:=' STORAGE( ' || lv_initial_extent || lv_next_extent || lv_pct_increase ||')';
     			END IF;
     END IF;

     IF (  lv_extent_management = 'LOCAL' AND  lv_allocation_type = 'UNIFORM') THEN
     					lv_storage_clause:='';
     END IF;

       v_sql_stmt:=
           'CREATE TABLE '||pTmpTableName
              ||' TABLESPACE '||lv_tablespace_name
        			||lv_storage_clause
       			  ||lv_pct_free
        			||lv_ini_trans
        			||lv_max_trans
--        		||' NOLOGGING '
        			||' AS SELECT *'
              ||' FROM '||pTableName
        			||' WHERE NULL=NULL';



       ad_ddl.do_ddl( applsys_schema => v_applsys_schema,
                      application_short_name => 'MSC',
                      statement_type => AD_DDL.CREATE_TABLE,
                      statement => v_sql_stmt,
                      object_name => pTmpTableName);

   --trc('en:Create_Temp_Tab_PVT');
   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
      IF c_part_para%ISOPEN THEN CLOSE c_part_para; END IF;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  '<<Create_Temp_Tab_PVT>>');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  '<<SQL>>'||v_sql_stmt);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
      RETURN FALSE;
END Create_Temp_Tab_PVT;

/* =========== Create Indexes on Temporary Tables ========== */

FUNCTION Create_Index_PVT( p_uniqueness IN VARCHAR2) RETURN BOOLEAN
IS
   lv_crt_ind_status	NUMBER;
BEGIN
   trc('st:Create_Index_PVT');
   /* creatIndexOnTempraryTable; */


   FOR i IN 1..v_tempTblList.COUNT LOOP

       lv_crt_ind_status := create_temp_table_index
       			      ( p_uniqueness,
                                v_partTblList(i),
                                v_tempTblList(i),
                                v_instance_code,
                                v_instance_id,
                                SYS_NO,
                                MSC_CL_COLLECTION.G_WARNING
                              );

       IF lv_crt_ind_status = MSC_CL_COLLECTION.G_WARNING THEN
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Warning during unique index creation on table, ' || v_tempTblList(i));
       ELSIF lv_crt_ind_status = MSC_CL_COLLECTION.G_ERROR THEN
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error during unique index creation on table, ' || v_tempTblList(i));
          RETURN FALSE;
       ELSE
          trc('Unique index creation successful on table, ' || v_tempTblList(i));
       END IF;

   END LOOP;

   trc('en:Create_Index_PVT');
   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  '<<Create_Index_PVT>>');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  '<<SQL>>'||v_sql_stmt);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
      RETURN FALSE;
END Create_Index_PVT;

/* ========= Exchange Partitions =========== */
FUNCTION Exchange_Partition_PVT RETURN BOOLEAN
IS

   lv_partition_name  VARCHAR2(30);
   lv_return_status   VARCHAR2(2048);
   lv_msg_data        VARCHAR2(2048);
   lv_result          BOOLEAN;

BEGIN
   trc('st:Exchange_Partition_PVT');
   trc('st:Exchange_Partition_PVT: v_tempTblList='||to_char(v_tempTblList.COUNT + v_swapTblList.COUNT ));
   /* exchange partition with temporary table */
   FOR i IN 1..v_tempTblList.COUNT LOOP

       msc_manage_plan_partitions.get_partition_name
                         ( -1,
                           v_instance_id,
                           v_partTblList(i),
                           SYS_NO,
                           lv_partition_name,
                           lv_return_status,
                           lv_msg_data);

      if NOT      EXCHANGE_SINGLE_TAB_PARTN ( v_partTblList(i) ,
                                            lv_partition_name ,
                                            v_tempTblList(i),
                                            MSC_UTIL.SYS_YES) THEN
        return FALSE;
      END IF;
   END LOOP;

   FOR i IN 1..v_swapTblList.COUNT LOOP

       msc_manage_plan_partitions.get_partition_name
                         ( -1,
                           v_instance_id,
                           v_swapTblList(i).ods_table_name,
                           SYS_NO,
                           lv_partition_name,
                           lv_return_status,
                           lv_msg_data);

      if NOT      EXCHANGE_SINGLE_TAB_PARTN ( v_swapTblList(i).ods_table_name ,
                                            lv_partition_name ,
                                            v_swapTblList(i).temp_table_name,
                                            MSC_UTIL.SYS_YES) THEN
        return FALSE;
      END IF;

            --if the table is in the ods-staging swap table list.
          EXECUTE IMMEDIATE ' update msc_coll_parameters set '
                             || v_swapTblList(i).column_name || ' = ' || MSC_CL_COLLECTION.G_STG_ODS_SWP_PHASE_2
                             || ' where instance_id = ' || v_instance_id;

   END LOOP;

   trc('en:Exchange_Partition_PVT');
   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  '<<Exchange_Partition_PVT>>');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  '<<SQL>>'||v_sql_stmt);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
      RETURN FALSE;
END Exchange_Partition_PVT;

/* ========== Analyse Temporary Table =========== */
FUNCTION Analyse_Temp_Tab_PVT RETURN BOOLEAN
IS
BEGIN
   trc('st:Analyse_Temp_Tab_PVT');
   /* Analyse temporary table; */
   FOR i IN 1..v_tempTblList.COUNT LOOP
       msc_analyse_tables_pk.analyse_table( v_tempTblList(i));
   END LOOP;

   FOR i IN 1..v_swapTblList.COUNT LOOP
       msc_analyse_tables_pk.analyse_table( v_tempTblList(i));
   END LOOP;

   trc('en:Analyse_Temp_Tab_PVT');
   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  '<<Analyse_Temp_Tab_PVT>>');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
      RETURN FALSE;
END Analyse_Temp_Tab_PVT;


/* ========== Public Functions ============= */
/* ========== Create Temporary Tables =========== */
FUNCTION Create_Temp_Tbl RETURN BOOLEAN
IS
BEGIN

   IF NOT v_is_initialized        THEN RETURN FALSE; END IF;

   trc('DS tbl count= ' || to_char(v_partTblList.COUNT + v_swapTblList.COUNT));

   FOR i IN 1..v_partTblList.COUNT LOOP
      IF NOT Drop_Temp_Tab_PVT(v_tempTblList(i))   THEN RETURN FALSE; END IF;
      IF NOT Create_Temp_Tab_PVT (v_partTblList(i),v_tempTblList(i))     THEN RETURN FALSE; END IF;
   END LOOP;

   FOR i IN 1..v_swapTblList.COUNT LOOP
      IF NOT Drop_Temp_Tab_PVT(v_swapTblList(i).temp_table_name)   THEN RETURN FALSE; END IF;
      IF NOT Create_Temp_Tab_PVT (v_swapTblList(i).ods_table_name,v_swapTblList(i).temp_table_name)     THEN RETURN FALSE; END IF;
   END LOOP;

   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  '<<Create_Temp_Tbl>>');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RETURN FALSE;
END Create_Temp_Tbl;

FUNCTION Exchange_Partition RETURN BOOLEAN
IS
BEGIN

   IF NOT v_is_initialized        THEN RETURN FALSE; END IF;
   IF NOT Exchange_Partition_PVT  THEN RETURN FALSE; END IF;

   RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  '<<Exchange_Partition>>');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RETURN FALSE;
END Exchange_Partition;

/* ========== Drop Temporary Tables =========== */
FUNCTION Drop_Temp_Tbl RETURN BOOLEAN
IS
BEGIN

   IF NOT v_is_initialized        THEN RETURN FALSE; END IF;

   FOR i IN 1..v_partTblList.COUNT LOOP
      IF NOT Drop_Temp_Tab_PVT(v_tempTblList(i))   THEN RETURN FALSE; END IF;
   END LOOP;

   FOR i IN 1..v_swapTblList.COUNT LOOP
      IF NOT Drop_Temp_Tab_PVT(v_swapTblList(i).temp_table_name)   THEN RETURN FALSE; END IF;
   END LOOP;

   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<Drop_Temp_Tbl>>');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RETURN FALSE;
END Drop_Temp_Tbl;

FUNCTION Create_Unique_Index RETURN BOOLEAN
IS
BEGIN
   IF NOT v_is_initialized        THEN RETURN FALSE; END IF;
   IF NOT Create_Index_PVT('UNIQUE') THEN RETURN FALSE; END IF;

   RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  '<<Create_Unique_Index>>');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RETURN FALSE;
END Create_Unique_Index;

FUNCTION Create_NonUnique_Index RETURN BOOLEAN
IS
BEGIN

   IF NOT v_is_initialized        THEN RETURN FALSE; END IF;
   IF NOT Create_Index_PVT('NONUNIQUE') THEN RETURN FALSE; END IF;

   RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  '<<Create_NonUnique_Index>>');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RETURN FALSE;
END Create_NonUnique_Index;

FUNCTION Analyse_Temp_Tbl RETURN BOOLEAN
IS
BEGIN

   IF NOT v_is_initialized        THEN RETURN FALSE; END IF;
   IF NOT Analyse_Temp_Tab_PVT    THEN RETURN FALSE; END IF;

   RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  '<<Analyse_Temp_Tbl>>');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RETURN FALSE;
END Analyse_Temp_Tbl;

FUNCTION Initialize( p_instance_id   IN NUMBER,
                     p_instance_code IN VARCHAR2,
                     p_is_so_cmp_rf  IN BOOLEAN)
     RETURN BOOLEAN
IS
BEGIN

   IF NOT v_is_initialized THEN
      v_instance_id := p_instance_id;
      v_instance_code := p_instance_code;

      IF NOT Initialize_Schema_PVT   THEN RETURN FALSE; END IF;
      IF NOT Initialize_TTL_List_PVT THEN RETURN FALSE; END IF;
      IF NOT Initialize_SWAP_Tbl_List(p_instance_id,p_instance_code ) THEN RETURN FALSE; END IF;

      IF NOT p_is_so_cmp_rf THEN
         v_partTblList.TRIM;
         v_tempTblList.TRIM;
      END IF;

      v_is_initialized:= TRUE;
   END IF;

   RETURN v_is_initialized;
EXCEPTION
   WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  '<<Initialize>>');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RETURN v_is_initialized;
END Initialize;

/***********************  PREPLACE CHANGE START ***********************/

FUNCTION Get_Table_Index (p_table_name   VARCHAR2) RETURN INTEGER

IS

   j          INTEGER;
   parm_str   VARCHAR2(30);
   tab_str    VARCHAR2(30);


BEGIN

   parm_str := SUBSTR(p_table_name, 1, INSTR(p_table_name, '_', -1));

   FOR j IN 1..v_tempTblList.COUNT LOOP
      tab_str := SUBSTR(v_tempTblList(j), 1, INSTR(v_tempTblList(j), '_', -1));
      IF  (parm_str = tab_str) THEN
         RETURN j;
      END IF;
   END LOOP;

   RETURN 0;

END Get_Table_Index;


FUNCTION Get_SWAP_Table_Index (p_table_name   VARCHAR2) RETURN INTEGER
IS
BEGIN
   FOR j IN 1..v_swapTblList.COUNT LOOP
      IF  (p_table_name = v_swapTblList(j).ods_table_name) THEN
         RETURN j;
      END IF;
   END LOOP;
   RETURN 0;
END Get_SWAP_Table_Index;


FUNCTION Get_SWAP_TMP_Table_Index (p_table_name   VARCHAR2) RETURN INTEGER
IS
BEGIN
   FOR j IN 1..v_swapTblList.COUNT LOOP
      IF  (p_table_name = v_swapTblList(j).temp_table_name) THEN
         RETURN j;
      END IF;
   END LOOP;
   RETURN 0;
END Get_SWAP_TMP_Table_Index;
/* ========= Exchange Partitions New function for PREPLACE =========== */
FUNCTION Exchange_Partition_PARTIAL ( p_tempTblList TblNmTblTyp)
                                                  RETURN BOOLEAN
IS

   lv_partition_name  VARCHAR2(30);
   lv_return_status   VARCHAR2(2048);
   lv_msg_data        VARCHAR2(2048);
   j                  INTEGER;
   lv_is_swap_table   BOOLEAN := FALSE;
   lv_partn_tbl_name  VARCHAR2(30);

BEGIN
   trc('st:Exchange_Partition_PARTIAL: p_tempTblList='||to_char(p_tempTblList.COUNT));
   /* exchange partition with temporary table */
   FOR i IN 1..p_tempTblList.COUNT LOOP

       lv_is_swap_table := FALSE;
       j := Get_Table_Index(p_tempTblList(i));

       IF j = 0 THEN
          j := Get_SWAP_TMP_Table_Index(p_tempTblList(i));
          IF j = 0 THEN
            trc('st:Exchange_Partition_PARTIAL - NO Tables to Exchange');
            RETURN TRUE;
          END IF;
          lv_is_swap_table := TRUE;
       END IF;

       if lv_is_swap_table then
            lv_partn_tbl_name := v_swapTblList(j).ods_table_name;
       else
            lv_partn_tbl_name := v_partTblList(j);
       end if;

       msc_manage_plan_partitions.get_partition_name
                         ( -1,
                           v_instance_id,
                           lv_partn_tbl_name,
                           SYS_NO,
                           lv_partition_name,
                           lv_return_status,
                           lv_msg_data);

      if NOT  EXCHANGE_SINGLE_TAB_PARTN ( lv_partn_tbl_name ,
                                            lv_partition_name ,
                                            p_tempTblList(i),
                                            MSC_UTIL.SYS_YES) THEN
        return FALSE;
      END IF;

      --if the table is in the ods-staging swap table list.
      if lv_is_swap_table then
          EXECUTE IMMEDIATE ' update msc_coll_parameters set '
                             || v_swapTblList(j).column_name || ' = ' || MSC_CL_COLLECTION.G_STG_ODS_SWP_PHASE_2
                             || ' where instance_id = ' || v_instance_id;
      end if;

   END LOOP;

   trc('en:Exchange_Partition_PARTIAL');
   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  '<<Exchange_Partition_PARTIAL>>');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  '<<SQL>>'||v_sql_stmt);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
      RETURN FALSE;
END Exchange_Partition_PARTIAL;

FUNCTION Exchange_Single_Tab_Partn ( pPartitionedTableName    IN VARCHAR2,
                                     pPartitionName           IN VARCHAR2,
                                     pUnPartitionedTableName  IN VARCHAR2,
                                     pIncludeIndexes          IN NUMBER DEFAULT MSC_UTIL.SYS_YES ) RETURN BOOLEAN
IS
BEGIN

      trc('st:EXCHANGE_SINGLE_TAB_PARTN  ' || pPartitionedTableName);

       v_sql_stmt:=
           'ALTER TABLE '|| pPartitionedTableName
        ||' EXCHANGE PARTITION '||pPartitionName
        ||' WITH TABLE '|| pUnPartitionedTableName;

        IF ( pIncludeIndexes = MSC_UTIL.SYS_YES )THEN
            v_sql_stmt:= v_sql_stmt ||' INCLUDING INDEXES';
        END IF;

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'exchange part:-'||v_sql_stmt);

       /* execute the sql statement */
       ad_ddl.do_ddl( applsys_schema => v_applsys_schema,
                      application_short_name => 'MSC',
                      statement_type => AD_DDL.ALTER_TABLE,
                      statement => v_sql_stmt,
                      object_name => pPartitionedTableName);

   trc('en:EXCHANGE_SINGLE_TAB_PARTN' || pPartitionedTableName);
   RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, sqlerrm);
    RETURN FALSE;
END EXCHANGE_SINGLE_TAB_PARTN;


FUNCTION Undo_Stg_Ods_Swap RETURN BOOLEAN IS
   lv_partition_name  VARCHAR2(30);
   lv_return_status   VARCHAR2(2048);
   lv_msg_data        VARCHAR2(2048);
   lv_swap_status     NUMBER;
BEGIN

    FOR i IN 1..v_swapTblList.COUNT LOOP

        EXECUTE IMMEDIATE ' select nvl(' ||v_swapTblList(i).column_name || ',' || MSC_CL_COLLECTION.G_STG_ODS_SWP_PHASE_0 || ') from msc_coll_parameters '
                       || ' where instance_id = ' || v_instance_id
                INTO lv_swap_status;

        If lv_swap_status = MSC_CL_COLLECTION.G_STG_ODS_SWP_PHASE_2 then

               msc_manage_plan_partitions.get_partition_name
                         ( -1,
                           v_instance_id,
                           v_swapTblList(i).ods_table_name ,
                           SYS_NO,
                           lv_partition_name,
                           lv_return_status,
                           lv_msg_data);

              if NOT EXCHANGE_SINGLE_TAB_PARTN (  v_swapTblList(i).ods_table_name ,
                                                  lv_partition_name ,
                                                  v_swapTblList(i).temp_table_name,
                                                  MSC_UTIL.SYS_YES) then
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,' Error while exchanging partition for table :'  || v_swapTblList(i).ods_table_name );
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,' Please launch targetted collections for following entities :' );

                     FOR j IN i..v_swapTblList.COUNT LOOP
                           EXECUTE IMMEDIATE ' select ' ||v_swapTblList(j).column_name || ' from msc_coll_parameters '
                                           || ' where instance_id = ' || v_instance_id
                              INTO lv_swap_status;
                            If lv_swap_status <> MSC_CL_COLLECTION.G_STG_ODS_SWP_PHASE_0 then
                                 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,v_swapTblList(j).entity_name );
                            End if;
                    END LOOP;

              return FALSE;
              END IF;
            lv_swap_status := MSC_CL_COLLECTION.G_STG_ODS_SWP_PHASE_1;
        End if;

        If lv_swap_status = MSC_CL_COLLECTION.G_STG_ODS_SWP_PHASE_1 then

            if NOT EXCHANGE_SINGLE_TAB_PARTN (  v_swapTblList(i).stg_table_name ,
                                                v_swapTblList(i).stg_table_partn_name ,
                                                v_swapTblList(i).temp_table_name,
                                                MSC_UTIL.SYS_NO) then
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,' Error while exchanging partition for table :'  || v_swapTblList(i).stg_table_name  );
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,' Please launch planning data pull again for following entities :' );
                     FOR j IN i..v_swapTblList.COUNT LOOP
                           EXECUTE IMMEDIATE ' select ' ||v_swapTblList(j).column_name || ' from msc_coll_parameters '
                                           || ' where instance_id = ' || v_instance_id
                              INTO lv_swap_status;
                            If lv_swap_status <> MSC_CL_COLLECTION.G_STG_ODS_SWP_PHASE_0 then
                                 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,v_swapTblList(j).entity_name );
                            End if;
                    END LOOP;

            return FALSE;
            END IF;
        End if;


        EXECUTE IMMEDIATE ' update msc_coll_parameters set '
                           || v_swapTblList(i).column_name || ' = ' || MSC_CL_COLLECTION.G_STG_ODS_SWP_PHASE_0
                           || ' where instance_id = ' || v_instance_id;

    End loop;

RETURN TRUE;
END;

/****** This is the overloaded Function for partial replacement *****/

FUNCTION Exchange_Partition (prec  CollParamREC,
                             p_is_cont_refresh in boolean) RETURN BOOLEAN
IS

  lv_TblList     TblNmTblTyp;
  tbl_count      INTEGER     := 0;
  i              INTEGER ;
  tbl_nam_str    VARCHAR2(30);
  lv_swap_status     NUMBER;

BEGIN

   IF NOT v_is_initialized        THEN RETURN FALSE; END IF;

   lv_TBlList := TblNmTblTyp('INITIALIZE');

   /* Add entries to the Temp Table List */

-- agmcont
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'payback flag:-'||prec.payback_demand_supply_flag);
   IF prec.item_flag = SYS_YES THEN
     if (p_is_cont_refresh and
         (prec.item_sn_flag = SYS_INCR or prec.item_sn_flag = SYS_NO)) then
            null;
     else
        tbl_nam_str := 'SYSTEM_ITEMS_'||v_instance_code;
        IF (tbl_count = 0) THEN
          tbl_count := tbl_count + 1;
          lv_TblList(tbl_count) := tbl_nam_str;
        ELSE
           lv_TblList.EXTEND;                         -- Extend the size
           tbl_count := tbl_count + 1;
           lv_TblList(tbl_count) := tbl_nam_str;
        END IF;
        tbl_nam_str := 'ITEM_CATEGORIES_'||v_instance_code;
        lv_TblList.EXTEND;                         -- Extend the size
        tbl_count := tbl_count + 1;
        lv_TblList(tbl_count) := tbl_nam_str;
     end if;
   END IF;     -- item_flag

   IF prec. item_subst_flag = SYS_YES THEN
      IF(NOT p_is_cont_refresh) THEN
        tbl_nam_str := 'ITEM_SUBSTITUTES_'||v_instance_code;
        IF (tbl_count = 0) THEN
          tbl_count := tbl_count + 1;
          lv_TblList(tbl_count) := tbl_nam_str;
        ELSE
           lv_TblList.EXTEND;                         -- Extend the size
           tbl_count := tbl_count + 1;
           lv_TblList(tbl_count) := tbl_nam_str;
        END IF;
      END IF ;

   END IF;


   IF prec.wip_flag = SYS_YES THEN

     if (p_is_cont_refresh and
         (prec.wip_sn_flag = SYS_INCR or prec.wip_sn_flag = SYS_NO)) then
            null;
     else
        tbl_nam_str := 'RESOURCE_REQUIREMENTS_'||v_instance_code;
        IF (tbl_count = 0) THEN
          tbl_count := tbl_count + 1;
          lv_TblList(tbl_count) := tbl_nam_str;
        ELSE
           lv_TblList.EXTEND;                         -- Extend the size
           tbl_count := tbl_count + 1;
           lv_TblList(tbl_count) := tbl_nam_str;
        END IF;
        tbl_nam_str :='JOB_OPERATION_NETWORKS_'||v_instance_code;
        lv_TblList.EXTEND;
        tbl_count := tbl_count + 1;
        lv_TblList(tbl_count) := tbl_nam_str;
        tbl_nam_str :='JOB_OPERATIONS_'||v_instance_code;
        lv_TblList.EXTEND;
        tbl_count := tbl_count + 1;
        lv_TblList(tbl_count) := tbl_nam_str;
        tbl_nam_str :='JOB_REQUIREMENT_OPS_'||v_instance_code;
        lv_TblList.EXTEND;
        tbl_count := tbl_count + 1;
        lv_TblList(tbl_count) := tbl_nam_str;
        tbl_nam_str :='JOB_OP_RESOURCES_'||v_instance_code;
        lv_TblList.EXTEND;
        tbl_count := tbl_count + 1;
        lv_TblList(tbl_count) := tbl_nam_str;

        /* ds_plan: change start */
        tbl_nam_str :='RESOURCE_INSTANCE_REQS_'||v_instance_code;
        lv_TblList.EXTEND;
        tbl_count := tbl_count + 1;
        lv_TblList(tbl_count) := tbl_nam_str;

        tbl_nam_str :='JOB_OP_RES_INSTANCES_'||v_instance_code;
        lv_TblList.EXTEND;
        tbl_count := tbl_count + 1;
        lv_TblList(tbl_count) := tbl_nam_str;

        /* ds_plan: change end */
     end if;
   END IF;     -- wip_flag

   -- All supplies related flags
   IF ((prec.po_flag = SYS_YES)    or
       (prec.oh_flag = SYS_YES)    or
       (prec.wip_flag = SYS_YES)   or
       (prec.mps_flag = SYS_YES)   or
       (prec.user_supply_demand_flag = SYS_YES)
	   /* CP-ACK starts */
	   or(prec.supplier_response_flag = SYS_YES)
	   or (prec.internal_repair_flag = SYS_YES)       -- Added for Bug 5909379 SRP Additions
	   or (prec.external_repair_flag = SYS_YES)
	   /* CP-ACK ends */
     OR (prec.payback_demand_supply_flag = SYS_YES)
	   ) THEN

     if (p_is_cont_refresh and
         (prec.po_sn_flag = SYS_INCR or prec.po_sn_flag = SYS_NO) and
         (prec.oh_sn_flag = SYS_INCR or prec.oh_sn_flag = SYS_NO) and
         (prec.wip_sn_flag = SYS_INCR or prec.wip_sn_flag = SYS_NO) and
         (prec.mps_sn_flag = SYS_INCR or prec.mps_sn_flag = SYS_NO) and
	 (prec.usup_sn_flag = SYS_INCR or prec.usup_sn_flag = SYS_NO ) and
         /* CP-AUTO */
         (prec.suprep_sn_flag = SYS_INCR or prec.suprep_sn_flag = SYS_NO) ) then
            NULL;
     else

        tbl_nam_str := 'SUPPLIES_'||v_instance_code;
        IF (tbl_count = 0) THEN
          tbl_count := tbl_count + 1;
          lv_TblList(tbl_count) := tbl_nam_str;
        ELSE
           lv_TblList.EXTEND;                         -- Extend the size
           tbl_count := tbl_count + 1;
           lv_TblList(tbl_count) := tbl_nam_str;
        END IF;
     end if;
   END IF;     -- supplies

   IF prec.bom_flag = SYS_YES THEN

     if (p_is_cont_refresh and
         (prec.bom_sn_flag = SYS_INCR or prec.bom_sn_flag = SYS_NO)) then
            null;
     else
        tbl_nam_str := 'BOM_COMPONENTS_'||v_instance_code;
        IF (tbl_count = 0) THEN
          tbl_count := tbl_count + 1;
          lv_TblList(tbl_count) := tbl_nam_str;
        ELSE
           lv_TblList.EXTEND;                         -- Extend the size
           tbl_count := tbl_count + 1;
           lv_TblList(tbl_count) := tbl_nam_str;
        END IF;
        tbl_nam_str := 'OPERATION_RESOURCES_'||v_instance_code;
        lv_TblList.EXTEND;                         -- Extend the size
        tbl_count := tbl_count + 1;
        lv_TblList(tbl_count) := tbl_nam_str;
        tbl_nam_str := 'OPERATION_RESOURCE_SEQS_'||v_instance_code;
        lv_TblList.EXTEND;                         -- Extend the size
        tbl_count := tbl_count + 1;
        lv_TblList(tbl_count) := tbl_nam_str;
        tbl_nam_str := 'ROUTING_OPERATIONS_'||v_instance_code;
        lv_TblList.EXTEND;                         -- Extend the size
        tbl_count := tbl_count + 1;
        lv_TblList(tbl_count) := tbl_nam_str;
     end if;
   END IF;     -- bom_flag

   -- All demands related flags
   IF ((prec.wip_flag = SYS_YES)     or
       (prec.mds_flag = SYS_YES)     or
       (prec.forecast_flag = SYS_YES) or
       (prec.user_supply_demand_flag = SYS_YES)
       or (prec.internal_repair_flag = SYS_YES)
       or (prec.external_repair_flag = SYS_YES)
       OR (prec.payback_demand_supply_flag = SYS_YES ) ) THEN    -- added for Bug 5909379 Srp Additions

     if (p_is_cont_refresh and
         (prec.wip_sn_flag = SYS_INCR or prec.wip_sn_flag = SYS_NO) and
         (prec.mds_sn_flag = SYS_INCR or prec.mds_sn_flag = SYS_NO) and
         (prec.fcst_sn_flag = SYS_INCR or prec.fcst_sn_flag = SYS_NO) and
	 (prec.udmd_sn_flag = SYS_INCR or prec.udmd_sn_flag = SYS_NO ) ) then
            null;
     else
        tbl_nam_str := 'DEMANDS_'||v_instance_code;
        IF (tbl_count = 0) THEN
          tbl_count := tbl_count + 1;
          lv_TblList(tbl_count) := tbl_nam_str;
        ELSE
           lv_TblList.EXTEND;                         -- Extend the size
           tbl_count := tbl_count + 1;
           lv_TblList(tbl_count) := tbl_nam_str;
        END IF;
     end if;
   END IF;     -- demands

   IF prec.sales_order_flag = SYS_YES THEN
     if (p_is_cont_refresh and
         (prec.so_sn_flag = SYS_INCR or prec.so_sn_flag = SYS_NO)) then
         null;
     else
        tbl_nam_str := 'SALES_ORDERS_'||v_instance_code;
        IF (tbl_count = 0) THEN
          tbl_count := tbl_count + 1;
          lv_TblList(tbl_count) := tbl_nam_str;
        ELSE
           lv_TblList.EXTEND;                         -- Extend the size
           tbl_count := tbl_count + 1;
           lv_TblList(tbl_count) := tbl_nam_str;
        END IF;
     end if;
   END IF;     -- sales_order_flag

    FOR i IN 1..v_swapTblList.COUNT LOOP

        EXECUTE IMMEDIATE ' select nvl(' ||v_swapTblList(i).column_name || ',' || MSC_CL_COLLECTION.G_STG_ODS_SWP_PHASE_0 || ') from msc_coll_parameters '
                       || ' where instance_id = ' || v_instance_id
                INTO lv_swap_status;

        If lv_swap_status = MSC_CL_COLLECTION.G_STG_ODS_SWP_PHASE_1 then
            lv_TblList.EXTEND;                         -- Extend the size
            tbl_count := tbl_count + 1;
            lv_TblList(tbl_count) := v_swapTblList(i).temp_table_name;
        END if;
    END LOOP;

   FOR i IN 1..lv_TblList.COUNT LOOP

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<< '||TO_CHAR(i) ||' '||lv_TblList(i)||' >>');

   END LOOP;


   IF NOT Exchange_Partition_PARTIAL (lv_TBlList)  THEN
      RETURN FALSE;
   END IF;

   RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  '<<Exchange_Partition with prec PARAM>>');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RETURN FALSE;
END Exchange_Partition;

/*
-- added below procedure for bug 3890821
-- procedure checks for the existance of a partition p_part_name;
-- if not present, a new partition is created.
*/

PROCEDURE create_partition(p_table_name    IN VARCHAR2,
                           p_part_name     IN VARCHAR2,
                           p_part_type     IN NUMBER,
                           p_high_value    IN VARCHAR2)
IS

lv_sql_stmt   VARCHAR2(3000);
lv_msc_schema VARCHAR2(32);
lv_base_part  VARCHAR2(50);
lv_part_to_split VARCHAR2(30);
lv_part_exists NUMBER;

lv_tblspace_name VARCHAR2(50);
lv_pct_free VARCHAR2(50);
lv_pct_used VARCHAR2(50);
lv_init_ext VARCHAR2(50);
lv_nxt_ext VARCHAR2(50);
lv_pct_inc VARCHAR2(50);

lv_retval         BOOLEAN; /* 8800601 */
lv_dummy1         VARCHAR2(30); /* 8800601 */
lv_dummy2         VARCHAR2(30); /* 8800601 */
lv_appl_short_nm  VARCHAR2(30); /* 8800601 */

BEGIN

   BEGIN
    SELECT application_short_name
    INTO   lv_appl_short_nm
    FROM   fnd_application
    WHERE  application_id = 724;

lv_retval := FND_INSTALLATION.GET_APP_INFO(
                    lv_appl_short_nm, lv_dummy1,lv_dummy2, lv_msc_schema);
      /*End 8800601 */

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
       RAISE_APPLICATION_ERROR(-20001,
       'Application ID "'|| '724'
           ||'" is not registered in FND_APPLICATION.');
   END;


   lv_base_part := SUBSTR(p_table_name, 5) || '_' || '0'; /* 8800601 */


   lv_part_exists := 2;

   BEGIN

      SELECT decode(t1.tablespace_name, NULL, '', ' TABLESPACE ' || t1.tablespace_name),
             decode(t1.pct_free, NULL, '', ' PCTFREE ' || t1.pct_free),
             decode(t1.pct_used, NULL, '', ' PCTUSED ' || t1.pct_used),
             decode(t1.initial_extent, NULL, '', ' INITIAL ' || t1.initial_extent),
             decode(t1.next_extent, NULL, '', ' NEXT ' || t1.next_extent),
             decode(t1.pct_increase, NULL, '', ' PCTINCREASE ' || t1.pct_increase)
      INTO   lv_tblspace_name, lv_pct_free, lv_pct_used, lv_init_ext, lv_nxt_ext, lv_pct_inc
      FROM   all_tab_partitions t1
      WHERE  t1.table_name = p_table_name
             AND t1.partition_name = lv_base_part
             AND t1.table_owner = lv_msc_schema
             AND NOT EXISTS (SELECT 1 FROM all_tab_partitions t2
                             WHERE t2.table_name = t1.table_name
                                   AND t2.partition_name = p_part_name
                                   AND t2.table_owner = t1.table_owner);

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
         lv_part_exists := 1;

   END;

   IF lv_part_exists = 2 THEN

      IF p_part_type = SPLIT_PARTITION THEN
      lv_part_to_split := get_next_high_val_part(lv_msc_schema,p_table_name,p_high_value);

         lv_sql_stmt := 'ALTER TABLE ' || lv_msc_schema || '.' || p_table_name || ' SPLIT PARTITION ' || lv_part_to_split
                       || ' AT (' || p_high_value || ')'
                       || ' INTO ( PARTITION  ' || p_part_name
                       || lv_pct_free || lv_pct_used
                       || ' STORAGE(' || lv_init_ext || lv_nxt_ext || lv_pct_inc || ')' || lv_tblspace_name
                       || ' ,PARTITION ' || lv_part_to_split
                       || ')';

         EXECUTE IMMEDIATE lv_sql_stmt;


      ELSE

         lv_sql_stmt := 'ALTER TABLE ' || lv_msc_schema || '.' || p_table_name || ' ADD PARTITION ' || p_part_name
                       || ' VALUES LESS THAN ('|| p_high_value || ')'
                       || lv_pct_free || lv_pct_used
                       || ' STORAGE(' || lv_init_ext || lv_nxt_ext || lv_pct_inc || ')' || lv_tblspace_name;

         EXECUTE IMMEDIATE lv_sql_stmt;

      END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'ERROR in procedure create_partition ');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);

END create_partition;

/*-----------------------------------------------------------------------------
Procedure	: create_st_partition

Description	: This procedure partitions the staging table, for a newly
		  created ERP instance.

Parameters	: p_instance_id (IN NUMBER)
		  Instance Id of ERP instance
-----------------------------------------------------------------------------*/
PROCEDURE create_st_partition (p_instance_id IN NUMBER) IS

lv_retval 		boolean;
lv_dummy1 		varchar2(32);
lv_dummy2 		varchar2(32);
lv_schema 		varchar2(30);
lv_prod_short_name   	varchar2(30);

CURSOR c_tab_list IS
SELECT attribute1 application_id, attribute2 table_name
FROM   fnd_lookup_values
WHERE  lookup_type = 'MSC_STAGING_TABLE' AND
       enabled_flag = 'Y' AND
       view_application_id = 700 AND
       language = userenv('lang') AND
       attribute5 = 'L';

lv_sql_stmt varchar2(1000);

BEGIN

   FOR c_rec IN c_tab_list
   LOOP

      lv_prod_short_name := AD_TSPACE_UTIL.get_product_short_name(to_number(c_rec.application_id));
      lv_retval := FND_INSTALLATION.GET_APP_INFO (lv_prod_short_name, lv_dummy1, lv_dummy2, lv_schema);

      BEGIN
         lv_sql_stmt := ' ALTER TABLE ' || lv_schema || '.' || c_rec.table_name
                        || ' SPLIT PARTITION ' || SUBSTR(c_rec.table_name, 5) || '_DEF '
                        || ' VALUES (' || p_instance_id || ') INTO (PARTITION '
                        || SUBSTR(c_rec.table_name, 8) || '_' || to_char(p_instance_id)
                        || ' , PARTITION ' || SUBSTR(c_rec.table_name, 5) || '_DEF )';

         EXECUTE IMMEDIATE lv_sql_stmt;
      EXCEPTION
         WHEN OTHERS THEN
            IF SQLCODE IN (-14322) THEN
               /* supress exp if partition already exists */
               NULL;
            ELSE
               RAISE;
            END IF;
      END;

   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END;

/*-----------------------------------------------------------------------------
Procedure	: drop_st_partition

Description	: This procedure drops the partition for a dropped/deleted ERP
		  instance.

Parameters	: p_instance_id (IN NUMBER)
		  Instance Id of ERP instance
-----------------------------------------------------------------------------*/
PROCEDURE drop_st_partition (p_instance_id IN NUMBER) IS

lv_retval 		boolean;
lv_dummy1 		varchar2(32);
lv_dummy2 		varchar2(32);
lv_schema 		varchar2(30);
lv_prod_short_name   	varchar2(30);

CURSOR c_tab_list IS
SELECT flv.attribute1 application_id,
       flv.attribute2 table_name,
       substr(flv.attribute2, 8) || '_' || p_instance_id partition_name
FROM   fnd_lookup_values flv
WHERE  flv.lookup_type = 'MSC_STAGING_TABLE' AND
       flv.enabled_flag = 'Y' AND
       flv.view_application_id = 700 AND
       flv.language = userenv('lang') AND
       flv.attribute5 = 'L' AND
       EXISTS (
               SELECT 1
               FROM   all_tab_partitions atp
               WHERE  atp.table_name = flv.attribute2 AND
                      atp.partition_name = substr(flv.attribute2, 8) || '_' || to_char(p_instance_id)
              );

lv_sql_stmt varchar2(1000);

BEGIN

   FOR c_rec IN c_tab_list
   LOOP

      lv_prod_short_name := AD_TSPACE_UTIL.get_product_short_name(to_number(c_rec.application_id));
      lv_retval := FND_INSTALLATION.GET_APP_INFO (lv_prod_short_name, lv_dummy1, lv_dummy2, lv_schema);

      lv_sql_stmt := 'ALTER TABLE ' || lv_schema || '.' || c_rec.table_name
                  || ' DROP PARTITION ' || c_rec.partition_name;
      EXECUTE IMMEDIATE lv_sql_stmt;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END;

/*-----------------------------------------------------------------------------
Procedure	: modify_st_partition_add

Description	: This procedure adds the legacy instance_id to the default
                  partitions' list.

Parameters	: p_instance_id (IN NUMBER)
		  Instance Id of Legacy instance
-----------------------------------------------------------------------------*/
PROCEDURE modify_st_partition_add (p_instance_id IN NUMBER) IS

lv_retval 		boolean;
lv_dummy1 		varchar2(32);
lv_dummy2 		varchar2(32);
lv_schema 		varchar2(30);
lv_prod_short_name   	varchar2(30);

CURSOR c_tab_list IS
SELECT attribute1 application_id, attribute2 table_name
FROM   fnd_lookup_values
WHERE  lookup_type = 'MSC_STAGING_TABLE' AND
       enabled_flag = 'Y' AND
       view_application_id = 700 AND
       language = userenv('lang') AND
       attribute5 = 'L';

lv_sql_stmt varchar2(1000);

BEGIN

   FOR c_rec IN c_tab_list
   LOOP

      lv_prod_short_name := AD_TSPACE_UTIL.get_product_short_name(to_number(c_rec.application_id));
      lv_retval := FND_INSTALLATION.GET_APP_INFO (lv_prod_short_name, lv_dummy1, lv_dummy2, lv_schema);

      BEGIN
         lv_sql_stmt := 'ALTER TABLE ' || lv_schema || '.'
                     || c_rec.table_name || ' MODIFY PARTITION '
                     || SUBSTR(c_rec.table_name, 5) || '_LEG ADD VALUES (' || p_instance_id || ')';
         EXECUTE IMMEDIATE lv_sql_stmt;
      EXCEPTION
         WHEN OTHERS THEN
            IF SQLCODE IN (-14312) THEN
               /* supress exp if value already exists */
               NULL;
            ELSE
               RAISE;
            END IF;
      END;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END;

/*-----------------------------------------------------------------------------
Procedure	: modify_st_partition_drop

Description	: This procedure drops the legacy instance_id from the default
                  partitions' list.

Parameters	: p_instance_id (IN NUMBER)
		  Instance Id of Legacy instance
-----------------------------------------------------------------------------*/
PROCEDURE modify_st_partition_drop (p_instance_id IN NUMBER) IS

lv_retval 		boolean;
lv_dummy1 		varchar2(32);
lv_dummy2 		varchar2(32);
lv_schema 		varchar2(30);
lv_prod_short_name   	varchar2(30);

CURSOR c_tab_list IS
SELECT attribute1 application_id, attribute2 table_name
FROM   fnd_lookup_values
WHERE  lookup_type = 'MSC_STAGING_TABLE' AND
       enabled_flag = 'Y' AND
       view_application_id = 700 AND
       language = userenv('lang') AND
       attribute5 = 'L';

lv_sql_stmt varchar2(1000);

BEGIN

   FOR c_rec IN c_tab_list
   LOOP

      lv_prod_short_name := AD_TSPACE_UTIL.get_product_short_name(to_number(c_rec.application_id));
      lv_retval := FND_INSTALLATION.GET_APP_INFO (lv_prod_short_name, lv_dummy1, lv_dummy2, lv_schema);

      BEGIN
         lv_sql_stmt := 'ALTER TABLE ' || lv_schema || '.' || c_rec.table_name
                     || ' MODIFY PARTITION ' || SUBSTR(c_rec.table_name, 5) || '_LEG '
                     || ' DROP VALUES (' || p_instance_id || ')';
         EXECUTE IMMEDIATE lv_sql_stmt;
      EXCEPTION
         WHEN OTHERS THEN
            IF SQLCODE IN (-14313) THEN
               /* supress exp if value does not exist */
               NULL;
            ELSE
               RAISE;
            END IF;
      END;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END;

FUNCTION create_temp_table_index (p_uniqueness 		IN VARCHAR2,
                                  p_part_table 		IN VARCHAR2,
                                  p_temp_table 		IN VARCHAR2,
                                  p_instance_code 	IN VARCHAR2,
                                  p_instance_id 	IN NUMBER,
                                  p_is_plan		IN NUMBER,
                                  p_error_level		IN NUMBER
                                 )
RETURN NUMBER
IS
   CURSOR c_index_name( cp_tblname        IN VARCHAR2,
                        cp_inscode        IN VARCHAR2,
                        cp_uniqueness     IN VARCHAR2,
                        cp_partname       IN VARCHAR2
                      ) IS
   SELECT ipa.index_name,
          DECODE( di.uniqueness,'UNIQUE','UNIQUE',NULL) uniqueness,
          SUBSTRB( ipa.index_name,5)||'_'||cp_inscode,
          ipa.tablespace_name,
          decode(ipa.initial_extent, NULL, '', ' INITIAL ' || ipa.initial_extent),
          decode(ipa.next_extent, NULL, '', ' NEXT ' || ipa.next_extent),
          decode(ipa.pct_increase, NULL, '', ' PCTINCREASE ' || ipa.pct_increase),
          decode(ipa.pct_free, NULL, '', ' PCTFREE ' || ipa.pct_free),
          decode(ipa.ini_trans, NULL, '', ' INITRANS ' || ipa.ini_trans),
          decode(ipa.max_trans, NULL, '', ' MAXTRANS ' || ipa.max_trans),
          di.index_type,
          dt.EXTENT_MANAGEMENT,
          dt.ALLOCATION_TYPE
     FROM ALL_IND_PARTITIONS ipa,
          ALL_INDEXES di,
          dba_tablespaces dt
     WHERE ipa.index_owner= v_msc_schema
      AND di.table_owner= v_msc_schema
      AND ipa.partition_name=cp_partname
      AND di.table_name= cp_tblname
      AND di.uniqueness= cp_uniqueness
      AND ipa.index_name= di.index_name
      AND ipa.index_owner= di.owner
      AND ipa.tablespace_name= dt.tablespace_name;

   CURSOR index_columns ( p_msc_schema IN VARCHAR2,
                          p_index_name IN VARCHAR2,
                          p_table_name IN VARCHAR2)
   IS
   select ai.INDEX_TYPE, aic.column_name, aie.column_expression, aic.column_position
   from all_indexes ai, all_ind_columns aic, all_ind_expressions aie
   where ai.index_name = aic.index_name
   and ai.owner = aic.index_owner
   and ai.table_name = aic.table_name
   and ai.table_owner = aic.table_owner
   and aic.index_name = aie.index_name (+)
   and aic.index_owner = aie.index_owner  (+)
   and aic.table_name = aie.table_name  (+)
   and aic.table_owner = aie.table_owner  (+)
   and aic.column_position = aie.column_position  (+)
   AND aic.index_owner= p_msc_schema
   AND aic.table_owner= p_msc_schema
   AND aic.index_name = p_index_name
   AND aic.table_name = p_table_name
   order by aic.column_position;

   lv_indexColList    IndCharTblTyp;
   lv_indexColList1   IndCharTblTyp;
   lv_indColList      IndNmTblTyp;

   lv_indexColListCnt NUMBER;

   lv_index_name      VARCHAR2(30);
   lv_uniqueness      VARCHAR2(9);
   lv_temp_index_name VARCHAR2(30);

   lv_tablespace_name VARCHAR2(30);

   lv_min_extent      VARCHAR2(40);
   lv_max_extent      VARCHAR2(40);


   lv_index_type      VARCHAR2(27);
   lv_segment_space_management VARCHAR2(20);

   lv_partition_name  VARCHAR2(30);
   lv_return_status   VARCHAR2(2048);
   lv_msg_data        VARCHAR2(2048);

   lv_deg_parallel    NUMBER;
   lv_ind_stmt	      VARCHAR2(2048);
   lv_sql_stmt2	      VARCHAR2(2048);
   lv_sql_stmt3	      VARCHAR2(2048);
   lv_sql_stmt4       VARCHAR2(2048);
   lv_retval	      NUMBER := MSC_CL_COLLECTION.G_SUCCESS;
   TYPE CharTblTyp IS TABLE OF VARCHAR2(4000);
   lv_error_msg       CharTblTyp;
   lv_extent_management VARCHAR2(10);
   lv_allocation_type	VARCHAR2(9);
     lv_initial_extent  VARCHAR2(50);
   lv_next_extent     VARCHAR2(50);
   lv_pct_increase    VARCHAR2(50);
   lv_storage_clause   VARCHAR2(255);
   lv_pct_free       VARCHAR2(50);
   lv_ini_trans      VARCHAR2(50);
   lv_max_trans      VARCHAR2(50);


BEGIN
   trc('st:create_temp_table_index');
   /* creatIndexOnTempraryTable; */

   /* this profile option will determine the number of parallel threads to be used in creating the index in parallel*/

   SELECT to_number(fnd_profile.value('MSC_INDEX_PARALLEL_THREADS'))
   INTO   lv_deg_parallel
   FROM   dual;

   msc_manage_plan_partitions.get_partition_name
                          (-1,
                           p_instance_id,
                           p_part_table,
                           p_is_plan,
                           lv_partition_name,
                           lv_return_status,
                           lv_msg_data);

   OPEN c_index_name
                   (p_part_table,
                    p_instance_code,
                    p_uniqueness,
                    lv_partition_name);

   LOOP
          FETCH c_index_name
           INTO lv_index_name,
                lv_uniqueness,
                lv_temp_index_name,
                lv_tablespace_name,
                lv_initial_extent,
                lv_next_extent,
                lv_pct_increase,
                lv_pct_free,
                lv_ini_trans,
                lv_max_trans,
                lv_index_type,
                lv_extent_management,
                lv_allocation_type;

      EXIT WHEN c_index_name%NOTFOUND;

      /* select the index column order by the column position */

      IF (lv_index_type <> 'NORMAL') THEN
         lv_indexColList :=lv_indexColList1;

         OPEN index_columns(v_msc_schema,
                            lv_index_name,
                            p_part_table);

         lv_indexColListCnt :=0;

         LOOP
            FETCH index_columns INTO
                  lv_indexColList(lv_indexColListCnt).l_index_type,
                  lv_indexColList(lv_indexColListCnt).l_column_name,
                  lv_indexColList(lv_indexColListCnt).l_column_expression,
                  lv_indexColList(lv_indexColListCnt).l_column_position;

         EXIT WHEN index_columns%NOTFOUND;
            IF (lv_indexColList(lv_indexColListCnt).l_column_expression is not null) AND ( lv_indexColList(lv_indexColListCnt).l_index_type='FUNCTION-BASED NORMAL') THEN
               lv_indexColList(lv_indexColListCnt).l_column_name := lv_indexColList(lv_indexColListCnt).l_column_expression;
            END IF;
            lv_indexColListCnt := lv_indexColListCnt + 1;
         END LOOP;

         CLOSE index_columns;

      ELSE
         SELECT b.column_name
         BULK COLLECT
         INTO   lv_indColList
         FROM   ALL_IND_COLUMNS b
         WHERE  b.index_owner = v_msc_schema AND
                b.table_owner = v_msc_schema AND
                b.index_name = lv_index_name AND
                b.table_name = p_part_table
         ORDER BY b.COLUMN_POSITION;

         lv_indexColListCnt:= SQL%ROWCOUNT;

      END IF;

      /* prepare the sql statement */
      v_sql_stmt := ' CREATE '||lv_uniqueness||' INDEX '||lv_temp_index_name
                  ||' ON '||p_temp_table ||'(';

      IF (lv_index_type <> 'NORMAL') THEN
         FOR j IN 0..lv_indexColList.count-1 LOOP
            IF j= 0 THEN
               lv_ind_stmt:= lv_indexColList(j).l_column_name;
            ELSE
               lv_ind_stmt:= lv_ind_stmt||','||lv_indexColList(j).l_column_name;
            END IF;
         END LOOP;

      ELSE
         FOR j IN 1..lv_indexColListCnt LOOP
            IF j= 1 THEN
               lv_ind_stmt:= lv_indColList(j);
            ELSE
               lv_ind_stmt:= lv_ind_stmt||','||lv_indColList(j);
            END IF;
         END LOOP;

      END IF;

      IF lv_tablespace_name  IS NULL THEN
         v_sql_stmt:= v_sql_stmt || lv_ind_stmt || ') PARALLEL '|| lv_deg_parallel ;
      ELSE
         v_sql_stmt:= v_sql_stmt || lv_ind_stmt || ') PARALLEL '|| lv_deg_parallel ||' TABLESPACE '||lv_tablespace_name;
      END IF ;

          IF (lv_extent_management = 'DICTIONARY' OR (lv_extent_management = 'LOCAL' AND  lv_allocation_type = 'USER')) THEN
		     			IF (lv_initial_extent is  null and  lv_next_extent is  null and  lv_pct_increase is  null) THEN
		     					lv_storage_clause:='';
		     			ELSE
		     					lv_storage_clause:=' STORAGE( ' || lv_initial_extent || lv_next_extent || lv_pct_increase ||')';
		     			END IF;
     			END IF ;

     			IF (  lv_extent_management = 'LOCAL' AND  lv_allocation_type = 'SYSTEM') THEN
		      		lv_next_extent :='';
		      		lv_pct_increase := '';
		      		IF (lv_initial_extent is  null and  lv_next_extent is  null and  lv_pct_increase is  null) THEN
		     					lv_storage_clause:='';
		     			ELSE
		     					lv_storage_clause:=' STORAGE( ' || lv_initial_extent || lv_next_extent || lv_pct_increase ||')';
     					END IF;
     			END IF;

     			IF (  lv_extent_management = 'LOCAL' AND  lv_allocation_type = 'UNIFORM') THEN
     					lv_storage_clause:='';
     			END IF;
     			v_sql_stmt:= v_sql_stmt||lv_storage_clause ||lv_pct_free ||lv_ini_trans	||lv_max_trans;



      v_sql_stmt:= v_sql_stmt || ' COMPUTE STATISTICS';

      /* execute the sql statement */

      BEGIN
         /* create index */
         ad_ddl.do_ddl(applsys_schema => v_applsys_schema,
                       application_short_name => 'MSC',
                       statement_type => AD_DDL.CREATE_INDEX,
                       statement => v_sql_stmt,
                       object_name => lv_temp_index_name);
      EXCEPTION
         WHEN OTHERS THEN
            /* handle unique index violation exception */

            IF SQLCODE IN (-00001, -01452, -12801) THEN
               IF p_error_level = MSC_CL_COLLECTION.G_ERROR THEN
                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'ERROR');
               ELSE
                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'WARNING');
               END IF;

               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Unique index violated - ' || lv_temp_index_name);
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

               lv_sql_stmt2 := 'SELECT ';
               lv_sql_stmt3 := 'WHERE ';

               IF (lv_index_type <> 'NORMAL') THEN

	          FOR j IN 0..lv_indexColList.count-1 LOOP
	             lv_sql_stmt2 := lv_sql_stmt2 || '''' || lv_indexColList(j).l_column_name || '''' || ' || '' '' || '
	                          || 't1.' || lv_indexColList(j).l_column_name;

	             lv_sql_stmt3 := lv_sql_stmt3 || ' t1.' || lv_indexColList(j).l_column_name
	                          || ' = t2.' || lv_indexColList(j).l_column_name || ' AND ';

	             IF j <> lv_indexColList.count-1 THEN
	                lv_sql_stmt2 := lv_sql_stmt2 || '|| '' / '' || ';
	             END IF;
	          END LOOP;

	       ELSE
	          FOR j IN 1..lv_indexColListCnt LOOP
	             lv_sql_stmt2 := lv_sql_stmt2 || '''' || lv_indColList(j) || '''' || ' || '' '' || '
	                          || 't1.' || lv_indColList(j);
	             lv_sql_stmt3 := lv_sql_stmt3 || 'nvl( t1.' || lv_indColList(j)
	                          || ',''-99999'') = nvl(t2.' || lv_indColList(j) || ',''-99999'') AND ';

	             IF j <> lv_indexColListCnt THEN
	                lv_sql_stmt2 := lv_sql_stmt2 || '|| '' / '' || ';
	             END IF;
	          END LOOP;
	       END IF;

	       lv_sql_stmt2 := lv_sql_stmt2 || ' err_text FROM ' || p_temp_table || ' t1 WHERE EXISTS '
	                  || '(SELECT 1 FROM ' || p_temp_table || ' t2 ' || lv_sql_stmt3
	                  || 't1.rowid < t2.rowid)';

               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '======= Below records violate the unique constraint =======');

               EXECUTE IMMEDIATE lv_sql_stmt2 BULK COLLECT INTO lv_error_msg;

               FOR j IN 1..lv_error_msg.COUNT LOOP
                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  lv_error_msg(j) );
               END LOOP;

               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '===========================================================');

               IF p_error_level = MSC_CL_COLLECTION.G_ERROR THEN
                  lv_retval := MSC_CL_COLLECTION.G_ERROR;
                  RAISE;
               ELSE
                  lv_retval := MSC_CL_COLLECTION.G_WARNING;
                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The above records would not be collected');
                  lv_sql_stmt4 := 'DELETE FROM ' || p_temp_table || ' t1 WHERE EXISTS '
	                       || '(SELECT 1 FROM ' || p_temp_table || ' t2 ' || lv_sql_stmt3
	                       || 't1.rowid < t2.rowid)';

	                 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'deleting the duplicate row ' ||lv_sql_stmt4 );

	          EXECUTE IMMEDIATE lv_sql_stmt4;
	          COMMIT;

	          BEGIN
	             ad_ddl.do_ddl( applsys_schema => v_applsys_schema,
                                    application_short_name => 'MSC',
                                    statement_type => AD_DDL.CREATE_INDEX,
                                    statement => v_sql_stmt,
                                    object_name => lv_temp_index_name);
                  EXCEPTION
                     WHEN OTHERS THEN
                        lv_retval := MSC_CL_COLLECTION.G_ERROR;
                        RAISE;
                  END;
               END IF;
            ELSE
               lv_retval := MSC_CL_COLLECTION.G_ERROR;
               RAISE;
            END IF;
         END;
         trc('Index creation done - ' || lv_temp_index_name);

   END LOOP;
   CLOSE c_index_name;

   trc('en:create_temp_table_index');
   RETURN lv_retval;

EXCEPTION
   WHEN OTHERS THEN
      lv_retval := MSC_CL_COLLECTION.G_ERROR;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  '<<create_temp_table_index>>');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  '<<SQL>>'||v_sql_stmt);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
      RETURN lv_retval;
END create_temp_table_index;


/***********************  PREPLACE CHANGE END  *************************/
------------- Clean Repaiir junk inst Part--------------------------------
PROCEDURE EXEC_DDL(qry varchar2)
IS
 BEGIN
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,qry);
    EXECUTE IMMEDIATE qry ;
 END EXEC_DDL;

PROCEDURE list_create_def_part_stg ( ERRBUF        OUT NOCOPY VARCHAR2,
                                      RETCODE       OUT NOCOPY NUMBER,
                                      p_mode number default 0) -- 0 -- List; 1-  drop
 IS
 lv_qry_add_part varchar2(2000);
 lv_schema varchar2(30);
 BEGIN
 lv_schema:=msc_util.get_schema_name(724);
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Following DEFAULT partitions are missing');
 FOR tab in (select table_name
             from MSC_STAGING_TABLE_V mst
             where partition_type <> 'U'
             and not exists (select 1 from all_tab_partitions ATP
                             where ATP.table_owner = lv_schema
                               and atp.table_name=mst.table_name
                               and partition_name like '%_DEF') )
 loop
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,tab.table_name||'.'||substr(tab.table_name,5)||'_DEF');
  lv_qry_add_part := 'ALTER TABLE '||lv_schema||'.'||tab.table_name||'  ADD PARTITION '||substr(tab.table_name,5)||'_DEF VALUES (DEFAULT)';
  IF p_mode = 1 then
  EXEC_DDL(lv_qry_add_part);
  end if;
 end loop;
EXCEPTION
WHEN OTHERS THEN
              ERRBUF := SQLERRM;
              RETCODE := G_ERROR;
              RAISE;
END list_create_def_part_stg;

PROCEDURE list_drop_bad_staging_part ( ERRBUF        OUT NOCOPY VARCHAR2,
                                      RETCODE       OUT NOCOPY NUMBER,
                                      p_mode number default 0) -- 0 -- List; 1-  drop
IS
TYPE cur_typ IS REF CURSOR;
lv_inst_str     VARCHAR2(2000);
lv_leg_inst_str   VARCHAR2(2000);
--lv_qry_str      VARCHAR2(4000);
--lv_tab          VARCHAR2(30);
--lv_tab_Part     VARCHAR2(30);
--row_limit       number;
--lv_dummy1       VARCHAR2(30);
--lv_dummy2       VARCHAR2(30);
lv_schema       VARCHAR2(30);
--lv_source_schema VARCHAR2(30);
--lv_schema_short_nm       VARCHAR2(30);
--lv_err_flag    BOOLEAN :=FALSE;
lv_qry_drop_part varchar2(1000);
lv_Part_high_value long;
lv_Part_high_val_len number;
lv_Part_inst_id varchar2(100);
IS_BAD_PARTITION BOOLEAN;
  l_tablen  BINARY_INTEGER;
  l_tab     DBMS_UTILITY.uncl_array;
  lv_high_val_str varchar2(2000);
  lv_str varchar2(2000);
  i number :=0;

CURSOR c_tab_part(p_schema varchar2) IS
    SELECT b.table_name
          ,b.partition_name
          ,b.high_value
          ,b.high_value_length
          --,SUBSTR(b.partition_name,INSTR(partition_name,'_',-1)+1) part_inst_id
    FROM MSC_STAGING_TABLE_V a,DBA_TAB_PARTITIONS b
    WHERE a.table_name = b.table_name
    AND b.table_owner = p_schema
    AND a.PARTITION_TYPE <> 'U'   -- Table is Partitioned
    ORDER BY a.table_name ;
    --AND b.partition_name like substr( a.table_name,8)||'%';


BEGIN

   lv_schema:=msc_util.get_schema_name(724);
  --
  -- Generate List of Instances passed --
  lv_inst_str := ',';
  lv_leg_inst_str := ', ';
  FOR inst IN (select instance_id,instance_type from MSC_APPS_INSTANCES )
  LOOP
  if inst.instance_type <> 3 then
    lv_inst_str := lv_inst_str  ||  inst.instance_id   ||  ',' ;
  else
    lv_leg_inst_str := lv_leg_inst_str  ||  inst.instance_id   ||  ', ' ;
  end if;
  END LOOP;

   --End  Generate List of Instances passed --
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'List of Junk Stg Partitions:-');
        FOR  tab  in c_tab_part(lv_schema)
        LOOP
        --
        IF ( (INSTR(lv_inst_str,','||SUBSTR(tab.partition_name,INSTR(tab.partition_name,'_',-1)+1)||',') < 1
              OR SUBSTR(tab.table_name,8) <> SUBSTR(tab.partition_name,1,INSTR(tab.partition_name,'_',-1)- 1))
            AND tab.partition_name <> substr(tab.table_name,5)||'_LEG'
            AND tab.partition_name <> substr(tab.table_name,5)||'_DEF')
        then -- not in list
           IS_BAD_PARTITION := TRUE;

         ELSE -- check the High Value
             IF tab.partition_name = substr(tab.table_name,5)||'_DEF' THEN
              NULL; -- DO nothing
             ELSIF tab.partition_name = substr(tab.table_name,5)||'_LEG' THEN
                for inst in (select instance_id from msc_apps_instances where instance_type = 3 ) loop
                  if instr(', '||substr(tab.high_value,1,tab.high_value_length)||',' , ', '||inst.instance_id||',') < 1  then
                  IS_BAD_PARTITION := TRUE;
                  --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_2,'Leg part marked as wrong1:-'||tab.table_name||'.'||tab.partition_name);
                  end if;
                end loop;

                -- check if there is any extra value in the high_value of leg part
                  lv_high_val_str  := ','||substr(tab.high_value,1,tab.high_value_length)||',';
                  i := 0;
                  --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'lv_high_val_str--'||lv_high_val_str);
                  --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'lv_leg_inst_str--'||lv_leg_inst_str);
                   LOOP
                    i := i+1;
                    lv_str := substr (lv_high_val_str,instr(lv_high_val_str,',',1,i) +1
                                  ,instr(lv_high_val_str,',',1,i+1)-instr(lv_high_val_str,',',1,i) -1);
                      --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'lv_str--'||lv_str);
                    exit when lv_str is null;
                     if lv_str in ('0',' NULL') then
                      NULL;
                     ELSIF  instr(lv_leg_inst_str,','||lv_str||',') < 1 then
                        IS_BAD_PARTITION := TRUE;
                        --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Leg part marked as wrong2:-'||tab.table_name||'.'||tab.partition_name);
                     end if;
                   END LOOP;


             ELSIF substr(tab.high_value,1,tab.high_value_length) <> SUBSTR(tab.partition_name,INSTR(tab.partition_name,'_',-1)+1) then
                IS_BAD_PARTITION := TRUE;
             END IF;
          END IF;

          IF IS_BAD_PARTITION  THEN
                 BEGIN
                    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,tab.table_name||'.'||tab.partition_name);
                    lv_qry_drop_part := 'ALTER TABLE '||lv_schema||'.'||tab.table_name||' DROP PARTITION '||tab.partition_name;
                  IF p_mode = 1 then
                    EXEC_DDL(lv_qry_drop_part);
                  end if;
                 EXCEPTION
                    WHEN OTHERS THEN
                    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'ERROR while executing --'||lv_qry_drop_part);
                    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,SQLERRM);
                    RAISE;
                 END;
                 IS_BAD_PARTITION := FALSE;
           END IF;
        END LOOP;
EXCEPTION
WHEN OTHERS THEN
              ERRBUF := SQLERRM;
              RETCODE := G_ERROR;
              RAISE;
END list_drop_bad_staging_part;
--1
PROCEDURE list_drop_bad_ods_inst_part ( ERRBUF        OUT NOCOPY VARCHAR2,
                    RETCODE       OUT NOCOPY NUMBER,
                    p_mode number default 0) -- 0 -- List; 1-  repair
IS
lv_inst_str     VARCHAR2(2000);
lv_schema       VARCHAR2(30);
lv_qry_drop_part varchar2(1000);
lv_Part_high_value long;
lv_Part_high_val_len number;
lv_Part_inst_id varchar2(100);
lv_inst_col varchar2(1);
lv_plan_col varchar2(1);

cursor c_tab_part(p_schema varchar2) IS
SELECT b.table_name
      ,b.partition_name
      ,b.high_value
      ,b.high_value_length
      ,SUBSTR(b.partition_name,INSTR(b.partition_name,'__',-1)+2) part_inst_id
      ,nvl(instance_id_flag,'N') instance_id_flag
      ,nvl(plan_id_flag,'N')     plan_id_flag
 FROM MSC_ODS_TABLE_V a,DBA_TAB_PARTITIONS b
 WHERE a.table_name = b.table_name
 AND b.table_owner = p_schema
  AND a.instance_id_flag = 'Y'
  AND a.PARTITION_TYPE <> 'U'   -- Table is Partitioned
  AND NVL(a.global_flag,'-1')<>'G'
 AND b.partition_name like substr( a.table_name,5)||'%'
 AND  INSTR(b.partition_name,'__') > 0;
BEGIN

   lv_schema:=msc_util.get_schema_name(724);

--  row_limit := TO_NUMBER( FND_PROFILE.VALUE('MRP_PURGE_BATCH_SIZE'));
  --
  -- Generate List of Instances passed --
    lv_inst_str := ',';
  FOR inst IN (select instance_id from MSC_INST_PARTITIONS )
  LOOP
    lv_inst_str := lv_inst_str  ||  inst.instance_id   ||  ',' ;
  END LOOP;

   --End  Generate List of Instances passed --
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'List of junk ODS Partitions');
FOR tab in c_tab_part(lv_schema)
    LOOP
    --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'|tab.part_inst_id:-'||tab.part_inst_id||';');
    --IF SUBSTR(tabs.partition_name,INSTR(tabs.partition_name,'__')+2) NOT IN lv_inst_str then
    IF INSTR(lv_inst_str,','||SUBSTR(tab.partition_name,INSTR(tab.partition_name,'__')+2)||',') < 1 then -- not in list
            BEGIN
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,tab.table_name||'.'||tab.partition_name);
                lv_qry_drop_part := 'ALTER TABLE '||lv_schema||'.'||tab.table_name||' DROP PARTITION '||tab.partition_name;
                IF p_mode = 1 then
                    EXEC_DDL(lv_qry_drop_part);
                  end if;
             EXCEPTION
                WHEN OTHERS THEN
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'ERROR while executing --'||lv_qry_drop_part);
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,SQLERRM);
                RAISE;
             END;
    ELSE

          if tab.instance_id_flag  = 'Y' and tab.plan_id_flag = 'Y' then
          lv_Part_inst_id := '-1, '||to_char(to_number(tab.part_inst_id)+1);
          else
          lv_Part_inst_id := to_char(to_number(tab.part_inst_id)+1);
          end if;

          if substr(tab.high_value,1,tab.high_value_length) <>  lv_Part_inst_id then
             BEGIN
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,tab.table_name||'.'||tab.partition_name);
                lv_qry_drop_part := 'ALTER TABLE '||lv_schema||'.'||tab.table_name||' DROP PARTITION '||tab.partition_name;
                IF p_mode = 1 then
                    EXEC_DDL(lv_qry_drop_part);
                  end if;
             EXCEPTION
                WHEN OTHERS THEN
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'ERROR while executing --'||lv_qry_drop_part);
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,SQLERRM);
                RAISE;
             END;
          end if;
    END IF;
    END LOOP;

EXCEPTION
WHEN OTHERS THEN
              ERRBUF := SQLERRM;
              RETCODE := G_ERROR;
              RAISE;
END list_drop_bad_ods_inst_part;

PROCEDURE list_create_missing_ods_partn(  ERRBUF        OUT NOCOPY VARCHAR2,
                                          RETCODE       OUT NOCOPY NUMBER,
                                          p_mode          number default 0)
IS
CURSOR missing_ods_part(cp_schema varchar2) is
select b.table_name
      ,a.instance_id
      ,nvl(instance_id_flag,'N') instance_id_flag
      ,nvl(plan_id_flag,'N') plan_id_flag
from msc_inst_partitions a,
     MSC_ODS_TABLE_V b
WHERE b.PARTITION_TYPE='R'
  AND NOT EXISTS (    select 1
                      FROM    all_tab_partitions atp
                      WHERE   atp.table_name = b.table_name AND
                              atp.table_owner = cp_schema AND
                              atp.partition_name = substr(b.table_name, 5) || '__' || to_char(a.instance_id)
                     )
                     ;
lv_high_value varchar2(1000);
lv_part_name varchar2(1000);
lv_schema VARCHAR2(30);

BEGIN
lv_schema:=msc_util.get_schema_name(724);
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Following Partitions to be created');
   FOR tab IN missing_ods_part(lv_schema)
   LOOP
        if tab.instance_id_flag  = 'Y' and tab.plan_id_flag = 'Y' then
          lv_high_value := '-1, ' || to_char(tab.instance_id+1);
        elsif tab.instance_id_flag  = 'Y' and tab.plan_id_flag = 'N' then
          lv_high_value := to_char(tab.instance_id+1);
        else
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Partitioned ODS Table '||tab.table_name||' does not have Instance_id as expected. Pls investigate');
          ERRBUF := 'Partitioned ODS Table '||tab.table_name||' does not have Instance_id as expected. Pls investigate';
          RETCODE := G_WARNING;
        end if;
      lv_part_name := substr(tab.table_name, 5) || '__' || tab.instance_id;
      --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Create Part:-'||tab.table_name||'.'||lv_part_name);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,tab.table_name||'.'||lv_part_name);
      IF p_mode  = 1 THEN
      --GET_NEXT_PART(lv_high_value)
      MSC_CL_EXCHANGE_PARTTBL.create_partition(tab.table_name,
                                               lv_part_name,
                                               1, --split
                                               lv_high_value);
      END IF;
    END LOOP;
EXCEPTION
WHEN OTHERS THEN
              ERRBUF := SQLERRM;
              RETCODE := G_ERROR;
              RAISE;
END list_create_missing_ods_partn;

PROCEDURE list_create_missing_stg_part(  ERRBUF        OUT NOCOPY VARCHAR2,
                                          RETCODE       OUT NOCOPY NUMBER,
                                          p_mode          number default 0)
IS

   lv_schema 		varchar2(30);

   CURSOR c_tab_list(cp_owner varchar2,cp_table varchar2) IS
   SELECT mst.application_id,
          mst.table_name,
          mai.instance_id instance_id,
          mai.instance_type instance_type
   FROM   msc_staging_table_v mst,
          msc_apps_instances mai
   WHERE  mst.table_name = cp_table AND
          mst.PARTITION_TYPE = 'L'  AND
          (
          mai.instance_type = 3 OR
          NOT EXISTS (
                      select 1
                      FROM    all_tab_partitions atp
                      WHERE   atp.table_name = mst.table_name AND
                              atp.table_owner = cp_owner    AND
                              atp.partition_name = substr(mst.table_name, 8) || '_' || to_char(mai.instance_id)
                     )
          )
  order by mst.table_name;

  cursor c_leg_part(cp_owner varchar2,cp_table varchar2) IS
  SELECT 1
  from all_tab_partitions
  where table_owner = cp_owner
  AND   table_name  = cp_table
  AND partition_name = substr(table_name,5)||'_LEG';




   lv_sql_stmt VARCHAR2(1000);
   tbl_name VARCHAR2(30);
   lv_count number;

BEGIN

lv_schema:=msc_util.get_schema_name(724);

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Following Partitions to be created');
for stg_tab in (select table_name from msc_staging_table_v where PARTITION_TYPE = 'L' ) loop

   open c_leg_part (lv_schema,stg_tab.table_name);
   fetch c_leg_part into lv_count;
   if c_leg_part%notfound then
     lv_sql_stmt :='ALTER TABLE '||lv_schema||'.'||stg_tab.table_name
                ||' SPLIT PARTITION '||substr(stg_tab.table_name,5)||'_DEF'
                ||' VALUES (0, NULL) INTO (PARTITION '||substr(stg_tab.table_name,5)||'_LEG, PARTITION '|| substr(stg_tab.table_name,5)||'_DEF )';

    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,stg_tab.table_name||'.'||substr(stg_tab.table_name,5)||'_LEG');
    IF p_mode = 1 then
      EXEC_DDL(lv_sql_stmt);
    end if;
   end if;

   close c_leg_part;

--
   FOR c_rec IN c_tab_list(lv_schema,stg_tab.table_name)
   LOOP
      IF c_rec.instance_type <> 3 THEN
         lv_sql_stmt := ' ALTER TABLE ' || lv_schema || '.' || c_rec.table_name
                     || ' SPLIT PARTITION ' || SUBSTR(c_rec.table_name, 5) || '_DEF '
                     || ' VALUES (' || c_rec.instance_id || ') INTO (PARTITION '
                     || SUBSTR(c_rec.table_name, 8) || '_' || to_char(c_rec.instance_id)
                     || ' , PARTITION ' || SUBSTR(c_rec.table_name, 5) || '_DEF )';

                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, c_rec.table_name||'.'||SUBSTR(c_rec.table_name, 8) || '_' || to_char(c_rec.instance_id));
                  IF p_mode = 1 then
                    EXEC_DDL(lv_sql_stmt);
                  end if;
      ELSE
         BEGIN
            lv_sql_stmt := ' ALTER TABLE ' || lv_schema || '.' || c_rec.table_name
                        || ' MODIFY PARTITION ' || SUBSTR(c_rec.table_name, 5) || '_LEG'
                        || ' ADD VALUES (' || c_rec.instance_id || ')';

                  IF p_mode = 1 then
                    EXEC_DDL(lv_sql_stmt);
                  end if;
         EXCEPTION
            WHEN OTHERS THEN
               IF SQLCODE IN (-14312) THEN
                  /* supress exp if value already exists */
                  NULL;
               ELSE
                  RAISE;
               END IF;
         END;
      END IF;

   END LOOP;

end loop;
EXCEPTION
WHEN OTHERS THEN
              ERRBUF := SQLERRM;
              RETCODE := G_ERROR;
              RAISE;
END list_create_missing_stg_part;

PROCEDURE Clean_Instance_partitions(  ERRBUF        OUT NOCOPY VARCHAR2,
                                    RETCODE       OUT NOCOPY NUMBER,
                                    p_mode          number default 0)
IS
begin
      list_create_def_part_stg(ERRBUF,RETCODE,p_mode);
      list_drop_bad_staging_part(ERRBUF,RETCODE,p_mode);
      list_drop_bad_ods_inst_part(ERRBUF,RETCODE,p_mode);
      list_create_missing_stg_part(ERRBUF,RETCODE,p_mode);
      list_create_missing_ods_partn(ERRBUF,RETCODE,p_mode);
end Clean_Instance_partitions;


FUNCTION get_next_high_val_part(powner varchar2,p_tab varchar2,p_high_val  varchar2) return VARCHAR2 IS
BEGIN
For i in (select partition_name,high_value,high_value_length
            from all_tab_partitions
            where table_name = p_tab
            AND   table_owner= powner
            order by partition_position
            )
LOOP
    IF COMPARE_PARTITION_BOUND(powner, p_tab, 'TABLE', p_high_val, i.high_value)=2 THEN
      RETURN i.partition_name ;
    END IF;
end loop;
RETURN -1;
END get_next_high_val_part;


FUNCTION COMPARE_PARTITION_BOUND( powner        IN VARCHAR2
                                , pobject_name  IN VARCHAR2
                                , pobject_type  IN VARCHAR2
                                , phval1        IN VARCHAR2
                                , phval2        IN VARCHAR2) RETURN NUMBER
IS
--return 1 if hval1 > hval2
--return 2 if hval1 < hval2
--return 0 if they are equal
l_sql VARCHAR2(2001);
numval1 number;
numval2 number;
lv_hval1 varchar2(1000);
lv_hval2 varchar2(1000);

lv_column_position  number;
lv_column_name     varchar2(30);
lv_data_type       varchar2(30);


TYPE refCursorTp IS REF CURSOR;
cur_part refCursorTp;

BEGIN
lv_hval1 :=','||phval1||',';
lv_hval2 :=','||phval2||',';


    IF pobject_type='TABLE' THEN
      l_sql := '    SELECT pk.column_position, pk.COLUMN_NAME, tc.DATA_TYPE
                    FROM  ALL_PART_KEY_COLUMNS pk, ALL_TAB_COLUMNS tc
                      WHERE pk.OWNER = tc.OWNER
                        AND pk.name = tc.table_name
                        AND pk.column_name = tc.column_name
                        AND pk.owner = '''||powner||''''||
                  '  AND pk.name = '''||pobject_name||''''||
                  ' ORDER BY pk.column_position ASC';
    ELSIF pobject_type='INDEX' THEN
        l_sql:= 'select c.column_position, a.column_name,a.data_type
                  from ALL_TAB_COLUMNS a,all_part_indexes b,all_part_key_columns c
                  where a.owner = b.owner
                   and a.table_name = b.table_name
                   and b.index_name = c.name
                   and a.column_name = c.column_name
                   and a.owner = '''||powner||''''||
                   ' and b.owner = '''||powner||''''||
                   'and c.owner = '''||powner||''''||
                  ' and b.index_name = '''||pobject_name||''''||
                 ' ORDER BY c.column_position ASC';
    ELSE
        return -1;
    END IF;


--   FOR partkeyrec IN cur_1(powner,pobject_name) LOOP
open cur_part for l_sql;
loop
fetch cur_part into lv_column_position,lv_column_name,lv_data_type;
exit when cur_part%NOTFOUND;

      CASE --partkeyrec.DATA_TYPE
         WHEN lv_data_type='NUMBER' THEN
           numval1:=        to_number(substr( lv_hval1
                                          , instr(lv_hval1, ',',1,lv_column_position)+1
                                          , instr(lv_hval1, ',',1,lv_column_position + 1)  - instr(lv_hval1, ',',1,lv_column_position)-1));
           numval2:=        to_number(substr( lv_hval2
                                          , instr(lv_hval2, ',',1,lv_column_position)+1
                                          , instr(lv_hval2, ',',1,lv_column_position + 1)  - instr(lv_hval2, ',',1,lv_column_position)-1));


                              if numval1 = numval2 then
                                null; -- check next col
                              elsif numval1 > numval2 then
                                return 1;
                              elsif numval1 < numval2 then
                                return 2;
                              else
                                return -1;
                              end if;

         WHEN lv_data_type IN('VARCHAR2','CHAR') THEN
              NULL;

         WHEN lv_data_type='DATE' THEN
            return -1;

         ELSE
            return -1;
       END CASE;

    /*   IF lv_ret <>0 THE
         return lv_ret
       END IF;*/
END LOOP;

return 0;
END COMPARE_PARTITION_BOUND;

--------------------------------------------------------------------------


END MSC_CL_EXCHANGE_PARTTBL;

/
