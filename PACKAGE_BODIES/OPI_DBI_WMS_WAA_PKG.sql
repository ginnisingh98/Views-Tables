--------------------------------------------------------
--  DDL for Package Body OPI_DBI_WMS_WAA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_WMS_WAA_PKG" AS
/* $Header: OPIDEWMSWAAB.pls 120.0 2005/05/24 18:17:07 appldev noship $ */
--
--Global Variables
--
g_gsd                     DATE;
g_last_run_date           DATE;
g_sysdate                 DATE;
g_user_id                 NUMBER;
g_login_id                NUMBER;
g_program_id              NUMBER;
g_program_login_id        NUMBER;
g_program_application_id  NUMBER;
g_request_id              NUMBER;
--
g_error                   NUMBER;
g_package                 VARCHAR2(100);
g_row_count               NUMBER;
no_initial_data           EXCEPTION;
--
--Local Procedures
--
/****************************** GET_WMS_GSD **********************************/
FUNCTION get_wms_gsd(errbuf      IN OUT NOCOPY VARCHAR2
                    ,retcode     IN OUT NOCOPY VARCHAR2)
RETURN DATE IS
  --
  CURSOR c_opi_gsd IS
  SELECT MIN(creation_date)
  FROM   wms_dispatched_tasks_history
  WHERE  transaction_temp_id IS NOT NULL;
  --
  CURSOR c_wms_gsd IS
  SELECT last_run_date
  FROM   opi_dbi_conc_prog_run_log
  WHERE  etl_type = 'WMS_WAA_GSD';
  --
  l_stmt_num            NUMBER;
  x_gsd                 DATE;
  l_wms_gsd_available   BOOLEAN;
  --
  l_procedure   VARCHAR2(100);
  --
  no_data_available     EXCEPTION;
BEGIN
	--
	--Initialize Local Variables
	l_procedure   := 'GET_WMS_GSD';
  --
  l_stmt_num := 10;
  --
  OPEN  c_wms_gsd;
  FETCH c_wms_gsd INTO x_gsd;
  l_wms_gsd_available := c_wms_gsd%found;
  CLOSE c_wms_gsd;
  --
  l_stmt_num := 20;
  --
  IF x_gsd IS NULL THEN
    OPEN  c_opi_gsd;
    FETCH c_opi_gsd INTO x_gsd;
    CLOSE c_opi_gsd;
    l_stmt_num := 30;
    --
    IF x_gsd IS NULL THEN
      RAISE no_data_available;
    ELSE
      IF l_wms_gsd_available THEN
        l_stmt_num := 40;
        UPDATE opi_dbi_conc_prog_run_log log
        SET    log.last_run_date      = x_gsd
              ,log.last_update_date   = sysdate
              ,log.last_updated_by    = g_user_id
              ,log.last_update_login  = g_login_id
        WHERE  log.etl_type = 'WMS_WAA_GSD';
        l_stmt_num := 50;
      ELSE
        INSERT INTO opi_dbi_conc_prog_run_log log
                 (log.etl_type
                 ,log.last_run_date
                 ,log.created_by
                 ,log.creation_date
                 ,log.last_update_date
                 ,log.last_updated_by
                 ,log.last_update_login
                 ,log.program_id
                 ,log.program_login_id
                 ,log.program_application_id
                 ,log.request_id)
              VALUES ('WMS_WAA_GSD'
                     ,x_gsd
                     ,g_user_id
                     ,sysdate
                     ,sysdate
                     ,g_user_id
                     ,g_login_id
                     ,g_program_id
                     ,g_login_id
                     ,g_program_application_id
                     ,g_request_id);
      l_stmt_num := 60;
    END IF;
    END IF;
  END IF;
  --
  l_stmt_num := 70;
  --
  COMMIT;
  --
  l_stmt_num := 80;
  RETURN x_gsd;
EXCEPTION
WHEN no_data_available THEN
  retcode := 1;
  errbuf := 'Warning in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num||' - '
                       ||'No data avialble for extraction';
  --
  bis_collection_utilities.put_line('Error Number: ' || retcode);
  bis_collection_utilities.put_line('Error Message: '|| errbuf);
  --
WHEN OTHERS THEN
  retcode := SQLCODE;
  errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
  --
  bis_collection_utilities.put_line('Error Number: ' || retcode);
  bis_collection_utilities.put_line('Error Message: '|| errbuf);
  --
END get_wms_gsd;
--
/****************************** SET_LAST_RUN_DATE ****************************/
PROCEDURE set_last_run_date(errbuf      IN OUT NOCOPY VARCHAR2
                           ,retcode     IN OUT NOCOPY VARCHAR2) IS
--
  l_procedure           VARCHAR2(100);
  l_stmt_num            NUMBER;
--
BEGIN
	--
	--Initialize Local Variables
	l_procedure   := 'SET_LAST_RUN_DATE';
	--
  l_stmt_num := 10;
  INSERT INTO opi_dbi_conc_prog_run_log
             (etl_type
             ,last_run_date
             ,created_by
             ,creation_date
             ,last_update_date
             ,last_updated_by
             ,last_update_login
             ,program_id
             ,program_login_id
             ,program_application_id
             ,request_id)
      VALUES ('WMS_WAA'
             ,g_last_run_date
             ,g_user_id
             ,sysdate
             ,sysdate
             ,g_user_id
             ,g_login_id
             ,g_program_id
             ,g_login_id
             ,g_program_application_id
             ,g_request_id);
  --
  bis_collection_utilities.put_line('Updated the information of '
                                   ||'Last Collection Date');
  --
  l_stmt_num := 20;
EXCEPTION
WHEN OTHERS THEN
  l_stmt_num := 30;
  retcode := SQLCODE;
  errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
  --
  bis_collection_utilities.put_line('Failed to update collection date'
                                   ||' in log table. Aborting');
  bis_collection_utilities.put_line('Error Number: ' || retcode);
  bis_collection_utilities.put_line('Error Message: '|| errbuf);
  --
END set_last_run_date;
--
/****************************** RESET_LAST_RUN_DATE **************************/
PROCEDURE reset_last_run_date(errbuf      IN OUT NOCOPY VARCHAR2
                             ,retcode     IN OUT NOCOPY VARCHAR2) IS
  --
  l_procedure   VARCHAR2(100);
  l_stmt_num            NUMBER;
  --
BEGIN
	--
	--Initialize Local Variables
	l_procedure   := 'RESET_LAST_RUN_DATE';
	--
  l_stmt_num := 10;
  --
  UPDATE opi_dbi_conc_prog_run_log
  SET    last_run_date            = g_last_run_date
        ,last_update_date         = SYSDATE
        ,last_updated_by          = g_user_id
        ,last_update_login        = g_login_id
        ,program_id               = g_program_id
        ,program_login_id         = g_login_id
        ,program_application_id   = g_program_application_id
        ,request_id               = g_request_id
  WHERE  etl_type = 'WMS_WAA';
  --
  l_stmt_num := 20;
EXCEPTION
WHEN OTHERS THEN
  retcode := SQLCODE;
  errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
  --
  bis_collection_utilities.put_line('Failed to update collection date'
                                   ||' in log table. Aborting');
  bis_collection_utilities.put_line('Error Number: ' || retcode);
  bis_collection_utilities.put_line('Error Message: '|| errbuf);
  --
END reset_last_run_date;
--
/*************************** CLEANUP_STAGING_INDEX ***************************/
PROCEDURE cleanup_staging_index(errbuf      IN OUT NOCOPY VARCHAR2
                               ,retcode     IN OUT NOCOPY VARCHAR2) IS
  --
  l_procedure       VARCHAR2(100);
  --
  l_schema          VARCHAR2(30);
  l_status          VARCHAR2(30);
  l_industry        VARCHAR2(30);
  l_stmt_num        NUMBER;
  --
BEGIN
	--
	--Initialize Local Variables
	l_procedure       := 'CLEANUP_STAGING_INDEX';
	--
  l_stmt_num := 10;
  IF fnd_installation.get_app_info(application_short_name => 'OPI'
                                  ,status                 => l_status
                                  ,industry               => l_industry
                                  ,oracle_schema          => l_schema) THEN
    l_stmt_num := 20;
    oki_dbi_scm_rsg_api_pvt.drop_index(p_table_name => 'opi_dbi_wms_tasks_stg'
                                      ,p_owner      => l_schema
                                      ,p_retcode    => retcode);
    --
    l_stmt_num := 30;
    oki_dbi_scm_rsg_api_pvt.drop_index(p_table_name => 'opi_dbi_wms_op_stg'
                                      ,p_owner      => l_schema
                                      ,p_retcode    => retcode);
    --
    l_stmt_num := 40;
    oki_dbi_scm_rsg_api_pvt.drop_index(p_table_name => 'opi_dbi_wms_ex_stg'
                                      ,p_owner      => l_schema
                                      ,p_retcode    => retcode);
    --
    bis_collection_utilities.put_line('Dropped the Indexes on Staging Tables');
    l_stmt_num := 50;
  END IF;
  l_stmt_num := 60;
EXCEPTION
WHEN OTHERS THEN
  retcode := SQLCODE;
  errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
  --
  bis_collection_utilities.put_line('Error Number: ' || retcode);
  bis_collection_utilities.put_line('Error Message: '|| errbuf);
  --
END cleanup_staging_index;
--
/*************************** RESET_STAGING_INDEX *****************************/
PROCEDURE reset_staging_index(errbuf      IN OUT NOCOPY VARCHAR2
                             ,retcode     IN OUT NOCOPY VARCHAR2) IS
  --
  l_procedure       VARCHAR2(100);
  --
  l_schema          VARCHAR2(30);
  l_status          VARCHAR2(30);
  l_industry        VARCHAR2(30);
  l_stmt_num        NUMBER;
  --
BEGIN
	--
	--Initialize Local Variables
	l_procedure       := 'RESET_STAGING_INDEX';
	--
  l_stmt_num := 10;
  --
  IF fnd_installation.get_app_info(application_short_name => 'OPI'
                                  ,status                 => l_status
                                  ,industry               => l_industry
                                  ,oracle_schema          => l_schema) THEN
    l_stmt_num := 20;
    oki_dbi_scm_rsg_api_pvt.create_index(p_table_name=>'opi_dbi_wms_tasks_stg'
                                        ,p_owner     =>l_schema
                                        ,p_retcode   =>retcode);
    --
    l_stmt_num := 30;
    oki_dbi_scm_rsg_api_pvt.create_index(p_table_name=>'opi_dbi_wms_op_stg'
                                        ,p_owner     =>l_schema
                                        ,p_retcode   =>retcode);
    --
    l_stmt_num := 40;
    oki_dbi_scm_rsg_api_pvt.create_index(p_table_name=>'opi_dbi_wms_ex_stg'
                                        ,p_owner     =>l_schema
                                        ,p_retcode   =>retcode);
    --
    l_stmt_num := 50;
    --
    bis_collection_utilities.put_line('Recreated the Indexes on the '
                                     ||'Staging Tables');
  END IF;
  l_stmt_num := 60;
  --
EXCEPTION
WHEN OTHERS THEN
  retcode := SQLCODE;
  errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
  --
  bis_collection_utilities.put_line('Error Number: ' || retcode);
  bis_collection_utilities.put_line('Error Message: '|| errbuf);
  --
END reset_staging_index;
/*************************** CLEANUP_INITIAL_DATA ****************************/
PROCEDURE cleanup_initial_data(errbuf      IN OUT NOCOPY VARCHAR2
                              ,retcode     IN OUT NOCOPY VARCHAR2) IS
  --
  l_procedure       VARCHAR2(100);
  --
  l_schema          VARCHAR2(30);
  l_status          VARCHAR2(30);
  l_industry        VARCHAR2(30);
  l_stmt_num        NUMBER;
  --
BEGIN
	--
	--Initialize Local Variables
	l_procedure       := 'CLEANUP_INITIAL_DATA';
  --
  l_stmt_num := 10;
  --
  IF fnd_installation.get_app_info(application_short_name => 'OPI'
                                  ,status                 => l_status
                                  ,industry               => l_industry
                                  ,oracle_schema          => l_schema) THEN
    l_stmt_num := 20;
    --Delete the Last Run Date from Log Table
    BEGIN
      DELETE FROM opi_dbi_conc_prog_run_log
      WHERE  ETL_TYPE = 'WMS_WAA';
    END;
    --Truncate Staging Tables
    l_stmt_num := 30;
    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.opi_dbi_wms_op_stg';
    l_stmt_num := 40;
    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.opi_dbi_wms_tasks_stg';
    l_stmt_num := 50;
    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.opi_dbi_wms_ex_stg';
    l_stmt_num := 60;
    bis_collection_utilities.put_line('Truncated the Staging Tables');
    --Truncate Fact Tables along with MV Logs
    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema
                     ||'.opi_dbi_wms_op_f PURGE MATERIALIZED VIEW LOG';
    l_stmt_num := 70;
    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema
                     ||'.opi_dbi_wms_tasks_f PURGE MATERIALIZED VIEW LOG';
    l_stmt_num := 80;
    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema
                     ||'.opi_dbi_wms_ex_f PURGE MATERIALIZED VIEW LOG';
    --
    bis_collection_utilities.put_line('Truncated the Fact Tables');
    l_stmt_num := 90;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  retcode := SQLCODE;
  errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
  --
  bis_collection_utilities.put_line('Error Number: ' || retcode);
  bis_collection_utilities.put_line('Error Message: '|| errbuf);
  --
END cleanup_initial_data;
--
/*************************** CLEANUP_STAGING_DATA ****************************/
PROCEDURE cleanup_staging_data(errbuf      IN OUT NOCOPY VARCHAR2
                              ,retcode     IN OUT NOCOPY VARCHAR2) IS
  --
  l_procedure       VARCHAR2(100);
  --
  l_schema          VARCHAR2(30);
  l_status          VARCHAR2(30);
  l_industry        VARCHAR2(30);
  l_stmt_num        NUMBER;
  --
BEGIN
	--
	--Initialize Local Variables
	l_procedure       := 'CLEANUP_STAGING_DATA';
  --
  l_stmt_num := 10;
  IF fnd_installation.get_app_info(application_short_name => 'OPI'
                                  ,status                 => l_status
                                  ,industry               => l_industry
                                  ,oracle_schema          => l_schema) THEN
    l_stmt_num := 20;
    --Truncate Staging Tables
    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.opi_dbi_wms_tasks_stg';
    l_stmt_num := 30;
    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.opi_dbi_wms_op_stg';
    l_stmt_num := 40;
    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.opi_dbi_wms_ex_stg';
    l_stmt_num := 50;
  END IF;
  l_stmt_num := 60;
EXCEPTION
WHEN OTHERS THEN
  retcode := SQLCODE;
  errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
  --
  bis_collection_utilities.put_line('Error Number: ' || retcode);
  bis_collection_utilities.put_line('Error Message: '|| errbuf);
  --
END cleanup_staging_data;
--
/*************************** WRAPUP_SUCCESS **********************************/
PROCEDURE wrapup_success(program_type   IN            VARCHAR2
                        ,errbuf         IN OUT NOCOPY VARCHAR2
                        ,retcode        IN OUT NOCOPY VARCHAR2) IS

  --
  l_procedure   VARCHAR2(100);
  l_message     VARCHAR2(500);
  l_stmt_num    NUMBER;
BEGIN
	--
	--Initialize Local Variables
	l_procedure   := 'WRAPUP_SUCCESS';
	--
  l_stmt_num := 10;
  --
  COMMIT;
  --
  IF program_type = 'INIT' THEN
    l_message := 'Successful in Initial Load';
  ELSIF program_type = 'INCR' THEN
    l_message := 'Successful in Incremental Load';
  END IF;
  --
  bis_collection_utilities.wrapup(p_status  => TRUE
                                 ,p_count   => g_row_count
                                 ,p_message => l_message
                                 );
  l_stmt_num := 20;
  --
  COMMIT;
  --
EXCEPTION
WHEN OTHERS THEN
  retcode := SQLCODE;
  errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
  --
  bis_collection_utilities.put_line('Error Number: ' || retcode);
  bis_collection_utilities.put_line('Error Message: '|| errbuf);
  --
END wrapup_success;
--
/*************************** WRAPUP_FAILURE **********************************/
PROCEDURE wrapup_failure(program_type IN  VARCHAR2) IS
  --
  l_procedure   VARCHAR2(100);
  l_message     VARCHAR2(500);
  l_stmt_num    NUMBER;
BEGIN
	--
	--Initialize Local Variables
	l_procedure   := 'WRAPUP_FAILURE';
	--
  l_stmt_num := 10;
  --
  ROLLBACK;
  --
  IF program_type = 'INIT' THEN
    l_message := 'Failed in Initial Load';
  ELSIF program_type = 'INCR' THEN
    l_message := 'Failed in Incremental Load';
  END IF;
  --
  bis_collection_utilities.wrapup(p_status  => FALSE
                                 ,p_count   => 0
                                 ,p_message => l_message
                                 );
  l_stmt_num := 20;
END wrapup_failure;
--
/*************************** GATHER_STATS ************************************/
PROCEDURE gather_stats(p_table_name   VARCHAR2) IS
  --
  l_procedure     VARCHAR2(100);
  l_table_owner   VARCHAR2(32);
  l_stmt_num      NUMBER;
  --
  CURSOR c_table_owner IS
  SELECT  table_owner
  FROM    USER_SYNONYMS
  WHERE   synonym_name = p_table_name;
BEGIN
	--
	--Initialize Local Variables
	l_procedure     := 'GATHER_STATS';
	--
  l_stmt_num := 10;
  --
  -- Find owner of the table passed to procedure
  --
  OPEN  c_table_owner;
  FETCH c_table_owner INTO l_table_owner;
  CLOSE c_table_owner;
  l_stmt_num := 20;
  --
  --   Gather table statistics these stats will be used by CBO
  --   for query optimization.
  --
  FND_STATS.GATHER_TABLE_STATS(ownname    =>  l_table_owner
                              ,tabname    =>  p_table_name
                              ,percent    =>  10
                              ,degree     =>  4
                              ,cascade    =>  true);
  --
  l_stmt_num := 30;
END GATHER_STATS;
--
/*********************** STAGING_GATHER_STATS ********************************/
PROCEDURE staging_gather_stats(errbuf      IN OUT NOCOPY VARCHAR2
                              ,retcode     IN OUT NOCOPY VARCHAR2) IS
  --
  l_procedure 			VARCHAR2(100);
  l_stmt_num        NUMBER;
  --
BEGIN
	--
	--Initialize Local Variables
	l_procedure := 'STAGING_GATHER_STATS';
	--
  l_stmt_num := 10;
  --
  -- Gather Status for all the Staging Tables
  --
  gather_stats('OPI_DBI_WMS_TASKS_STG');
  l_stmt_num := 20;
  gather_stats('OPI_DBI_WMS_OP_STG');
  l_stmt_num := 30;
  gather_stats('OPI_DBI_WMS_EX_STG');
  l_stmt_num := 40;
  --
EXCEPTION
WHEN OTHERS THEN
  retcode := SQLCODE;
  errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
  --
  bis_collection_utilities.put_line('Error Number: ' || retcode);
  bis_collection_utilities.put_line('Error Message: '|| errbuf);
  --
END staging_gather_stats;
--
/*********************** PRINT_GSD_MESSAGE ***********************************/
PROCEDURE print_gsd_message(p_gsd IN DATE) IS
BEGIN
  BIS_COLLECTION_UTILITIES.put_line(
  '*****************************************'
  ||'*************************************');
  BIS_COLLECTION_UTILITIES.put_line(
  'The Picks '||fnd_global.local_chr(38)
  ||' Exception Analysis reports as well as the '
  ||'Operation Plan');
  BIS_COLLECTION_UTILITIES.put_line(
  'Performance reports are suppported only from the date the '
  ||'WMS CU1 patch was');
  BIS_COLLECTION_UTILITIES.put_line(
  'applied.  Hence, this extraction includes data from '
  ||to_char(p_gsd,'MM/DD/YYYY HH24:MI:SS')||' to '
  ||to_char(g_sysdate,'MM/DD/YYYY HH24:MI:SS')||'.  ');
  BIS_COLLECTION_UTILITIES.put_line(
  'The following are the reports affected by '
  ||'this restriction:');
  BIS_COLLECTION_UTILITIES.put_line('    ');
  BIS_COLLECTION_UTILITIES.put_line('Picks '||fnd_global.local_chr(38)
  ||' Exceptions Analysis ');
  BIS_COLLECTION_UTILITIES.put_line('Picks '||fnd_global.local_chr(38)
                                            ||' Exceptions Trend ');
  BIS_COLLECTION_UTILITIES.put_line('Pick Exceptions By Reason ');
  BIS_COLLECTION_UTILITIES.put_line('Operation Plan Performance ');
  BIS_COLLECTION_UTILITIES.put_line('Operation Plan Exceptions By Reason');
  BIS_COLLECTION_UTILITIES.put_line(
  '*****************************************'
  ||'*************************************');
END print_gsd_message;
--
/*********************** CHECK_LAST_RUN_DATE *********************************/
PROCEDURE check_last_run_date(errbuf 		IN OUT NOCOPY VARCHAR2
                             ,retcode 	IN OUT NOCOPY VARCHAR2) IS
  CURSOR c_last_run_date IS
  SELECT last_run_date
  FROM   opi_dbi_conc_prog_run_log
  WHERE  etl_type = 'WMS_WAA';
  --
  l_stmt_num        						NUMBER;
  l_last_run_date               DATE;
  l_procedure                   VARCHAR2(100);
  last_run_date_not_available		EXCEPTION;
BEGIN
  --
  --Initialize Local Variables
  l_procedure := 'CHECK_LAST_RUN_DATE';
  --
  l_stmt_num := 10;
  --
  OPEN  c_last_run_date;
  FETCH c_last_run_date INTO l_last_run_date;
  CLOSE c_last_run_date;
  --
  l_stmt_num := 20;
  IF l_last_run_date IS NULL THEN
  	l_stmt_num := 30;
  	retcode := -1;
    errbuf  := ' Last Run Date is not available, Aborting. '
               ||'Pls. run the Initial Load';
    retcode := -1;
    RAISE last_run_date_not_available;
  END IF;
  --
  l_stmt_num := 40;
EXCEPTION
WHEN last_run_date_not_available THEN
  retcode := -1;
  errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num
                       ||errbuf;
  bis_collection_utilities.put_line(errbuf);
  RAISE no_initial_data;
WHEN OTHERS THEN
  retcode := SQLCODE;
  errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
  --
  bis_collection_utilities.put_line('Error Number: ' || retcode);
  bis_collection_utilities.put_line('Error Message: '|| errbuf);
  --
END check_last_run_date;
--
/*************************** INIT_TASKS **************************************
|  07-APR-2005 MOHIT      Updated the performance hints on OLTP tables       |
******************************************************************************/
PROCEDURE init_tasks(errbuf      IN OUT NOCOPY VARCHAR2
                    ,retcode     IN OUT NOCOPY VARCHAR2) IS
  --
  l_procedure 		  VARCHAR2(100);
  l_stmt_num        NUMBER;
  --
  l_row_count 			NUMBER;
BEGIN
	--
	--Initialize Local Variables
	l_procedure := 'INIT_TASKS';
	--
  l_stmt_num := 10;
  --
  --Collect all Pick Tasks into Tasks Staging Table
  --
  INSERT /*+ append parallel(tasks) */
  INTO   opi_dbi_wms_tasks_stg tasks
        (tasks.task_id
        ,tasks.organization_id
        ,tasks.inventory_item_id
        ,tasks.task_type
        ,tasks.completion_date
        ,tasks.op_plan_instance_id
        ,tasks.is_parent
        ,tasks.subinventory_code
        ,tasks.transaction_temp_id
        )
  select /*+ ordered parallel (wdth) parallel (msi)
             use_hash (sinv,wdth,msi) */
         wdth.task_id             task_id
        ,wdth.organization_id     organization_id
        ,wdth.inventory_item_id   inventory_item_id
        ,wdth.task_type           task_type
        ,wdth.drop_off_time       completion_date
        ,wdth.op_plan_instance_id op_plan_instance_id
        ,nvl(wdth.is_parent,'Y')
        ,CASE WHEN wdth.task_type = 1      THEN wdth.source_subinventory_code
              WHEN wdth.task_type in (2,8) THEN wdth.dest_subinventory_code
         END                      subinventory_code
        ,wdth.transaction_temp_id transaction_temp_id
  from   wms_dispatched_tasks_history wdth
        ,mtl_system_items_b           msi
        ,mtl_secondary_inventories    sinv
  where  wdth.inventory_item_id     = msi.inventory_item_id
  AND    wdth.organization_id       = msi.organization_id
  AND    decode(wdth.task_type
               ,1,wdth.source_subinventory_code
               ,wdth.dest_subinventory_code) = sinv.secondary_inventory_name
  AND    wdth.organization_id = sinv.organization_id
  AND    wdth.drop_off_time >= g_gsd
  AND    wdth.drop_off_time <= g_last_run_date
  AND    wdth.transaction_temp_id IS NOT NULL
  AND    wdth.task_type in (1,2,8)
  AND    wdth.status in (6,11);
  --
  l_stmt_num := 20;
  l_row_count := sql%rowcount;
  bis_collection_utilities.put_line('Finished collection of Tasks '
                                    ||'into Tasks Staging Table : '
                                    ||l_row_count||' row(s) processed');
  --
  l_stmt_num := 30;
  COMMIT;
  --
  l_stmt_num := 40;
EXCEPTION
WHEN OTHERS THEN
  retcode := SQLCODE;
  errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
  --
  bis_collection_utilities.put_line('Error Number: ' || retcode);
  bis_collection_utilities.put_line('Error Message: '|| errbuf);
  --
END init_tasks;
--
/*************************** INIT_OPS ****************************************/
PROCEDURE init_ops(errbuf      IN OUT NOCOPY VARCHAR2
                  ,retcode     IN OUT NOCOPY VARCHAR2) IS
  --
  l_procedure   VARCHAR2(100);
  l_stmt_num    NUMBER;
  --
  l_row_count   NUMBER;
BEGIN
	--
	--Initialize Local Variables
	l_procedure   := 'INIT_OPS';
	--
  l_stmt_num := 10;
  --
  --Collect all the Operation Plans into OP Staging Table
  --
  INSERT  /*+ append parallel(ops) */
  INTO    opi_dbi_wms_op_stg ops
         (ops.organization_id
         ,ops.subinventory_code
         ,ops.inventory_item_id
         ,ops.operation_plan_id
         ,ops.op_plan_instance_id
         ,ops.status
         ,ops.plan_execution_start_date
         ,ops.plan_execution_end_date
         ,ops.plan_elapsed_time
         )
    SELECT /*+ parallel (tasks) parallel (woiph)
               parallel (wop) parallel (msi) parallel (sinv)
               use_hash (tasks) use_hash (woiph)
               use_hash (wop) use_hash (msi) use_hash (sinv) */
           woiph.organization_id            			organization_id
          ,tasks.subinventory_code          			subinventory_code
          ,tasks.inventory_item_id          			inventory_item_id
          ,wop.operation_plan_id            			operation_plan_id
          ,woiph.op_plan_instance_id        			op_plan_instance_id
          ,woiph.status                     			status
          ,woiph.plan_execution_start_date  			plan_execution_start_date
          ,woiph.plan_execution_end_date    			plan_execution_end_date
          ,( woiph.plan_execution_end_date
           - woiph.plan_execution_start_date)*24 	plan_elapsed_time
    FROM   opi_dbi_wms_tasks_stg        tasks
          ,wms_op_plan_instances_hist   woiph
          ,wms_op_plans_b               wop
          ,mtl_system_items_b           msi
          ,mtl_secondary_inventories    sinv
    WHERE  tasks.op_plan_instance_id  = woiph.op_plan_instance_id
    AND    woiph.operation_plan_id    = wop.operation_plan_id
    AND    tasks.subinventory_code    = sinv.secondary_inventory_name
    AND    tasks.organization_id      = sinv.organization_id
    AND    tasks.inventory_item_id    = msi.inventory_item_id
    AND    tasks.organization_id      = msi.organization_id
    AND    woiph.status in (3,4,5)
    AND    wop.activity_type_id       = 1
    AND    woiph.plan_execution_start_date >= g_gsd
    AND    woiph.plan_execution_end_date   <= g_last_run_date
    AND    tasks.is_parent = 'Y'
    AND    tasks.task_type in (2,8);
  --
  l_stmt_num := 20;
  l_row_count := sql%rowcount;
  bis_collection_utilities.put_line('Finished collection of Operation Plans '
                                    ||'into OP Staging Table : '
                                    ||l_row_count||' row(s) processed');
  --
  l_stmt_num := 30;
  COMMIT;
  --
  l_stmt_num := 40;
EXCEPTION
WHEN OTHERS THEN
  retcode := SQLCODE;
  errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
  --
  bis_collection_utilities.put_line('Error Number: ' || retcode);
  bis_collection_utilities.put_line('Error Message: '|| errbuf);
  --
END init_ops;
--
/*************************** INIT_EXS ****************************************/
PROCEDURE init_exs(errbuf      IN OUT NOCOPY VARCHAR2
                  ,retcode     IN OUT NOCOPY VARCHAR2) IS
  --
  l_procedure   VARCHAR2(100);
  l_stmt_num    NUMBER;
  --
  l_row_count   NUMBER;
BEGIN
	--
	--Initialize Local Variables
	l_procedure   := 'INIT_EXS';
	--
  l_stmt_num := 10;
  --
  --Collect all Exceptions into Exceptions Staging Table
  --
  INSERT  /*+ append (exs) */
  INTO    opi_dbi_wms_ex_stg exs
         (exs.exception_id
         ,exs.task_id
         ,exs.organization_id
         ,exs.inventory_item_id
         ,exs.subinventory_code
         ,exs.operation_plan_id
         ,exs.operation_plan_indicator
         ,exs.operation_plan_status
         ,exs.op_plan_instance_id
         ,exs.completion_date
         ,exs.reason_id
         )
  SELECT /*+ parallel (tasks) parallel (wmx) parallel (mtr)
             use_hash (tasks) use_hash (wmx) use_hash (mtr) */
         wmx.sequence_number        exception_id
        ,wmx.task_id                task_id
        ,tasks.organization_id      organization_id
        ,tasks.inventory_item_id    inventory_item_id
        ,tasks.subinventory_code    subinventory_code
        ,NULL                       operation_plan_id
        ,1                          operation_plan_indicator
        ,NULL                       operation_plan_status
        ,NULL                       op_plan_instance_id
        ,tasks.completion_date      completion_date
        ,wmx.reason_id              reason_id
  FROM   opi_dbi_wms_tasks_stg      tasks
        ,wms_exceptions             wmx
        ,mtl_transaction_reasons    mtr
  WHERE  wmx.task_id     = tasks.transaction_temp_id
  AND    tasks.task_type = 1
  AND    tasks.is_parent = 'Y'
  AND    mtr.reason_id   = wmx.reason_id
  AND    mtr.reason_type = 1
  UNION ALL
  SELECT /*+ parallel (ops) parallel (wmx) parallel (tasks) parallel (mtr)
             use_hash (ops) use_hash (wmx) use_hash (tasks) use_hash (mtr) */
         wmx.sequence_number          exception_id
        ,wmx.task_id                  task_id
        ,ops.organization_id          organization_id
        ,ops.inventory_item_id        inventory_item_id
        ,ops.subinventory_code        subinventory_code
        ,ops.operation_plan_id        operation_plan_id
        ,2                            operation_plan_indicator
        ,ops.status                   operation_plan_status
        ,ops.op_plan_instance_id      op_plan_instance_id
        ,ops.plan_execution_end_date  completion_date
        ,wmx.reason_id                reason_id
  FROM   opi_dbi_wms_op_stg       ops
        ,wms_exceptions           wmx
        ,opi_dbi_wms_tasks_stg    tasks
        ,mtl_transaction_reasons  mtr
  WHERE  tasks.op_plan_instance_id = ops.op_plan_instance_id
  AND    tasks.task_type in (2,8)
  AND    wmx.task_id           = tasks.transaction_temp_id
  AND    tasks.organization_id = ops.organization_id
  AND    mtr.reason_id   = wmx.reason_id;
  --
  l_stmt_num := 20;
  l_row_count := sql%rowcount;
  bis_collection_utilities.put_line('Finished collection of Exceptions '
                                    ||'into Exceptions Staging Table : '
                                    ||l_row_count||' row(s) processed');
  --
  l_stmt_num := 30;
  COMMIT;
  --
  l_stmt_num := 40;
EXCEPTION
WHEN OTHERS THEN
  retcode := SQLCODE;
  errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
  --
  bis_collection_utilities.put_line('Error Number: ' || retcode);
  bis_collection_utilities.put_line('Error Message: '|| errbuf);
  --
END init_exs;
--
/*************************** INIT_TASKF **************************************/
PROCEDURE init_taskf (errbuf      IN OUT NOCOPY VARCHAR2
                     ,retcode     IN OUT NOCOPY VARCHAR2) IS
  --
  l_procedure   VARCHAR2(100);
  l_stmt_num    NUMBER;
  l_row_count   NUMBER;
BEGIN
	--
	--Initialize Local Variables
	l_procedure   := 'INIT_TASKF';
	--
  l_stmt_num := 10;
  --
  --Load all Pick Tasks collected in Staging Table into Tasks Fact
  --
  INSERT  /*+ append parallel(taskf) */
  INTO    opi_dbi_wms_tasks_f taskf
         (taskf.organization_id
         ,taskf.subinventory_code
         ,taskf.inventory_item_id
         ,taskf.completion_date
         ,taskf.picks
         ,taskf.picks_with_exceptions
         ,taskf.pick_exceptions
         ,taskf.creation_date
         ,taskf.last_update_date
         ,taskf.created_by
         ,taskf.last_updated_by
         ,taskf.last_update_login
         ,taskf.request_id
         ,taskf.program_application_id
         ,taskf.program_id
         ,taskf.program_update_date
         )
  SELECT /*+ parallel (tasks) parallel (exs)
             use_hash (tasks) use_hash (exs) */
         tasks.organization_id              organization_id
        ,tasks.subinventory_code            subinventory_code
        ,tasks.inventory_item_id            inventory_item_id
        ,TRUNC(tasks.completion_date)       completion_date
        ,COUNT(tasks.task_id)               picks
        ,COUNT(exs.task_id)                 picks_with_exceptions
        ,SUM(exs.ex_cnt)                    pick_exceptions
        ,SYSDATE                            creation_date
        ,SYSDATE                            last_update_date
        ,g_user_id                          created_by
        ,g_user_id                          last_updated_by
        ,g_login_id                         last_update_login
        ,g_request_id                       request_id
        ,g_program_application_id           program_application_id
        ,g_program_id                       program_id
        ,g_sysdate                          program_update_date
  FROM   opi_dbi_wms_tasks_stg tasks
        ,(SELECT /*+ parallel (ex) use_hash (ex) */
                 ex.task_id
                ,COUNT(ex.exception_id) ex_cnt
          FROM   opi_dbi_wms_ex_stg ex
          WHERE  ex.operation_plan_indicator = 1
          GROUP BY task_id ) exs
  WHERE  tasks.transaction_temp_id = exs.task_id(+)
  AND    tasks.task_type = 1
  GROUP BY tasks.organization_id
          ,tasks.subinventory_code
          ,tasks.inventory_item_id
          ,TRUNC(tasks.completion_date);
  --
  l_stmt_num := 20;
  l_row_count := sql%rowcount;
  g_row_count := nvl(g_row_count,0) + l_row_count;
  bis_collection_utilities.put_line('Finished Loading Pick Tasks '
                                    ||'into Tasks Fact Table : '
                                    ||l_row_count||' row(s) processed');
  --
  l_stmt_num := 40;
  COMMIT;
  --
  l_stmt_num := 50;
EXCEPTION
WHEN OTHERS THEN
  retcode := SQLCODE;
  bis_collection_utilities.put_line('Tasks Fact Initial '
                                   ||'Load Failed.');
  errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
  --
  bis_collection_utilities.put_line('Error Number: ' || retcode);
  bis_collection_utilities.put_line('Error Message: '|| errbuf);
  --
END init_taskf;
--
/*************************** INIT_OPF ****************************************/
PROCEDURE init_opf(errbuf      IN OUT NOCOPY VARCHAR2
                  ,retcode     IN OUT NOCOPY VARCHAR2) IS
	--
	l_procedure   VARCHAR2(100);
	l_stmt_num    NUMBER;
	--
	l_row_count   NUMBER;
BEGIN
	--
	--Initiailize Local Variables
	l_procedure   := 'INIT_OPF';
  l_stmt_num := 10;
  --
  --Load all Operation Plans collected in Staging Table into OP Fact
  --
  INSERT  /*+ append parallel(opf) */
  INTO    opi_dbi_wms_op_f opf
         (opf.organization_id
         ,opf.subinventory_code
         ,opf.inventory_item_id
         ,opf.operation_plan_id
         ,opf.status
         ,opf.plan_execution_end_date
         ,opf.plan_elapsed_time
         ,opf.executions
         ,opf.executions_with_exceptions
         ,opf.exceptions
         ,opf.creation_date
         ,opf.last_update_date
         ,opf.created_by
         ,opf.last_updated_by
         ,opf.last_update_login
         ,opf.request_id
         ,opf.program_application_id
         ,opf.program_id
         ,opf.program_update_date
         )
  SELECT /*+ parallel (ops) parallel (exs)
             use_hash (ops) use_hash (exs) */
         ops.organization_id                organization_id
        ,ops.subinventory_code              subinventory_code
        ,ops.inventory_item_id              inventory_item_id
        ,ops.operation_plan_id              operation_plan_id
        ,ops.status                         status
        ,trunc(ops.plan_execution_end_date) plan_execution_end_date
        ,sum(ops.plan_elapsed_time)         plan_elapsed_time
        ,count(ops.op_plan_instance_id)     executions
        ,count(exs.op_plan_instance_id)     executions_with_exceptions
        ,sum(nvl(exs.ex_cnt,0))             exceptions
        ,SYSDATE                            creation_date
        ,SYSDATE                            last_update_date
        ,g_user_id                          created_by
        ,g_user_id                          last_updated_by
        ,g_login_id                         last_update_login
        ,g_request_id                       request_id
        ,g_program_application_id           program_application_id
        ,g_program_id                       program_id
        ,g_sysdate                          program_update_date
  FROM   opi_dbi_wms_op_stg ops
        ,(SELECT /*+ parallel (ex) use_hash (ex) */
                 NVL(ex.op_plan_instance_id,0)  op_plan_instance_id
                ,count(ex.exception_id)         ex_cnt
          FROM   opi_dbi_wms_ex_stg ex
          WHERE  ex.operation_plan_indicator = 2
          GROUP BY nvl(ex.op_plan_instance_id,0)) exs
  WHERE  ops.op_plan_instance_id = exs.op_plan_instance_id(+)
  GROUP BY ops.organization_id
          ,ops.subinventory_code
          ,ops.inventory_item_id
          ,ops.operation_plan_id
          ,ops.status
          ,TRUNC(ops.plan_execution_end_date);
  --
  l_stmt_num := 20;
  l_row_count := sql%rowcount;
  g_row_count := nvl(g_row_count,0) + l_row_count;
  bis_collection_utilities.put_line('Finished Loading Operation Plans '
                                    ||'into OP Fact Table : '
                                    ||l_row_count||' row(s) processed');
  --
  l_stmt_num := 30;
  COMMIT;
  --
  l_stmt_num := 40;
EXCEPTION
WHEN OTHERS THEN
  retcode := SQLCODE;
  bis_collection_utilities.put_line('Operation Plans Fact Initial '
                                   ||'Load Failed.');
  errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
  --
  bis_collection_utilities.put_line('Error Number: ' || retcode);
  bis_collection_utilities.put_line('Error Message: '|| errbuf);
  --
END init_opf;
--
/*************************** INIT_EXF ****************************************/
PROCEDURE init_exf(errbuf      IN OUT NOCOPY VARCHAR2
                  ,retcode     IN OUT NOCOPY VARCHAR2) IS
  --
  l_procedure   VARCHAR2(100);
  l_stmt_num    NUMBER;
  l_row_count   NUMBER;
BEGIN
	--
	--Initialize Local Variables
	l_procedure   := 'INIT_EXF';
  l_stmt_num := 10;
  --
  --Load all Exceptions collected in Staging Table into Exceptions Fact
  --
  INSERT  /*+ append (exf) */
  INTO    opi_dbi_wms_ex_f exf
         (exf.organization_id
         ,exf.subinventory_code
         ,exf.inventory_item_id
         ,exf.operation_plan_id
         ,exf.operation_plan_indicator
         ,exf.operation_plan_status
         ,exf.reason_id
         ,exf.completion_date
         ,exf.exceptions
         ,exf.creation_date
         ,exf.last_update_date
         ,exf.created_by
         ,exf.last_updated_by
         ,exf.last_update_login
         ,exf.request_id
         ,exf.program_application_id
         ,exf.program_id
         ,exf.program_update_date
         )
  SELECT /*+ parallel (exs) use_hash (exs) */
         exs.organization_id                  organization_id
        ,exs.subinventory_code                subinventory_code
        ,exs.inventory_item_id                inventory_item_id
        ,exs.operation_plan_id                operation_plan_id
        ,exs.operation_plan_indicator         operation_plan_indicator
        ,exs.operation_plan_status            operation_plan_status
        ,exs.reason_id                        reason_id
        ,trunc(exs.completion_date)           completion_date
        ,COUNT(exs.exception_id)              exceptions
        ,SYSDATE                              creation_date
        ,SYSDATE                              last_update_date
        ,g_user_id                            created_by
        ,g_user_id                            last_updated_by
        ,g_login_id                           last_update_login
        ,g_request_id                         request_id
        ,g_program_application_id             program_application_id
        ,g_program_id                         program_id
        ,g_sysdate                            program_update_date
  FROM   opi_dbi_wms_ex_stg exs
  GROUP BY exs.organization_id
          ,exs.subinventory_code
          ,exs.inventory_item_id
          ,exs.operation_plan_id
          ,exs.operation_plan_indicator
          ,exs.operation_plan_status
          ,exs.reason_id
          ,TRUNC(exs.completion_date) ;
  --
  l_stmt_num := 20;
  l_row_count := sql%rowcount;
  g_row_count := nvl(g_row_count,0) + l_row_count;
  bis_collection_utilities.put_line('Finished Loading Exceptions '
                                    ||'into Exceptions Fact Table : '
                                    ||l_row_count||' row(s) processed');
  --
  l_stmt_num := 30;
  COMMIT;
  --
EXCEPTION
WHEN OTHERS THEN
  retcode := SQLCODE;
  bis_collection_utilities.put_line('Exceptions Fact Initial '
                                   ||'Load Failed.');
  errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
  --
  bis_collection_utilities.put_line('Error Number: ' || retcode);
  bis_collection_utilities.put_line('Error Message: '|| errbuf);
  --
END init_exf;
--
/*************************** INCR_TASKS **************************************/
PROCEDURE incr_tasks(errbuf      IN OUT NOCOPY VARCHAR2
                    ,retcode     IN OUT NOCOPY VARCHAR2) IS
  --
  l_procedure VARCHAR2(100);
  l_stmt_num  NUMBER;
  --
  l_row_count NUMBER;
BEGIN
	--
	--Initialize Local Variables
	l_procedure := 'INCR_TASKS';
	--
  l_stmt_num := 10;
  --
  --Collect all Pick Tasks into Tasks Staging Table
  --
  INSERT  INTO opi_dbi_wms_tasks_stg tasks
              (tasks.task_id
              ,tasks.organization_id
              ,tasks.inventory_item_id
              ,tasks.task_type
              ,tasks.completion_date
              ,tasks.op_plan_instance_id
              ,tasks.is_parent
              ,tasks.subinventory_code
              ,tasks.transaction_temp_id
              )
  select wdth.task_id                   task_id
        ,wdth.organization_id           organization_id
        ,wdth.inventory_item_id         inventory_item_id
        ,wdth.task_type                 task_type
        ,wdth.drop_off_time             completion_date
        ,wdth.op_plan_instance_id       op_plan_instance_id
        ,nvl(wdth.is_parent,'Y')        is_parent
        ,wdth.source_subinventory_code  subinventory_code
        ,wdth.transaction_temp_id       transaction_temp_id
  from   wms_dispatched_tasks_history wdth
        ,mtl_system_items_b           msi
        ,mtl_secondary_inventories    sinv
        ,opi_dbi_conc_prog_run_log    log
  where  wdth.inventory_item_id     = msi.inventory_item_id
  AND    wdth.organization_id       = msi.organization_id
  AND    decode(wdth.task_type
               ,1,source_subinventory_code
               ,dest_subinventory_code) = sinv.secondary_inventory_name
  AND    wdth.organization_id = sinv.organization_id
  AND    wdth.drop_off_time >= g_gsd
  AND    wdth.drop_off_time <= g_last_run_date
  AND    wdth.drop_off_time >= log.last_run_date
  AND    log.etl_type = 'WMS_WAA'
  AND    wdth.transaction_temp_id IS NOT NULL
  and    nvl(wdth.is_parent,'Y') = 'Y'
  AND    wdth.task_type = 1
  AND    wdth.status in (6,11);
  --
  l_stmt_num := 20;
  l_row_count := sql%rowcount;
  bis_collection_utilities.put_line('Finished collection of Tasks '
                                    ||'into Tasks Staging Table : '
                                    ||l_row_count||' row(s) processed');
  --
  l_stmt_num := 30;
  --
  l_stmt_num := 40;
EXCEPTION
WHEN OTHERS THEN
  retcode := SQLCODE;
  errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
  --
  bis_collection_utilities.put_line('Error Number: ' || retcode);
  bis_collection_utilities.put_line('Error Message: '|| errbuf);
  --
END incr_tasks;
--
/*************************** INCR_OPS ****************************************/
PROCEDURE incr_ops(errbuf      IN OUT NOCOPY VARCHAR2
                  ,retcode     IN OUT NOCOPY VARCHAR2) IS
  --
  l_procedure   VARCHAR2(100);
  l_stmt_num    NUMBER;
  --
  l_row_count   NUMBER;
BEGIN
	--
	--Initialize Local Variables
	l_procedure   := 'INCR_OPS';
	--
  l_stmt_num := 10;
  --
  --Collect all the Operation Plans into OP Staging Table
  --
  INSERT INTO opi_dbi_wms_op_stg ops
             (ops.organization_id
             ,ops.subinventory_code
             ,ops.inventory_item_id
             ,ops.operation_plan_id
             ,ops.op_plan_instance_id
             ,ops.status
             ,ops.plan_execution_start_date
             ,ops.plan_execution_end_date
             ,ops.plan_elapsed_time
             )
  SELECT wopih.organization_id                   organization_id
        ,wdth.dest_subinventory_code             subinventory_code
        ,wdth.inventory_item_id                  inventory_item_id
        ,wop.operation_plan_id                   operation_plan_id
        ,wopih.op_plan_instance_id               op_plan_instance_id
        ,wopih.status                            status
        ,wopih.plan_execution_start_date         plan_execution_start_date
        ,wopih.plan_execution_end_date           plan_execution_end_date
        ,( wopih.plan_execution_end_date
         - wopih.plan_execution_start_date)*24   plan_elapsed_time
  FROM   wms_dispatched_tasks_history  wdth
        ,opi_dbi_conc_prog_run_log     log
        ,wms_op_plan_instances_hist    wopih
        ,wms_op_plans_b                wop
        ,mtl_system_items_b            msi
        ,mtl_secondary_inventories     sinv
  WHERE  wdth.op_plan_instance_id  = wopih.op_plan_instance_id
  AND    wopih.operation_plan_id   = wop.operation_plan_id
  AND    wdth.dest_subinventory_code    = sinv.secondary_inventory_name
  AND    wdth.organization_id      = sinv.organization_id
  AND    wdth.inventory_item_id    = msi.inventory_item_id
  AND    wdth.organization_id      = msi.organization_id
  AND    wopih.status in (3,4,5)
  AND    wop.activity_type_id      = 1
  AND    wopih.plan_execution_start_date >= g_gsd
  AND    wopih.plan_execution_end_date   <= g_last_run_date
  AND    wopih.plan_execution_end_date >= log.last_run_date
  AND    log.etl_type = 'WMS_WAA'
  AND    nvl(wdth.is_parent,'Y') = 'Y'
  AND    wdth.transaction_temp_id IS NOT NULL
  AND    wdth.drop_off_time >= g_gsd
  AND    wdth.task_type in (2,8);
  --
  l_stmt_num := 20;
  l_row_count := sql%rowcount;
  bis_collection_utilities.put_line('Finished collection of Operation Plans '
                                    ||'into OP Staging Table : '
                                    ||l_row_count||' row(s) processed');
  --
  l_stmt_num := 30;
  --
  l_stmt_num := 40;
EXCEPTION
WHEN OTHERS THEN
  retcode := SQLCODE;
  errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
  --
  bis_collection_utilities.put_line('Error Number: ' || retcode);
  bis_collection_utilities.put_line('Error Message: '|| errbuf);
  --
END incr_ops;
--
/*************************** INCR_EXS ****************************************/
PROCEDURE incr_exs(errbuf      IN OUT NOCOPY VARCHAR2
                  ,retcode     IN OUT NOCOPY VARCHAR2) IS
  --
  l_procedure   VARCHAR2(100);
  l_stmt_num    NUMBER;
  --
  l_row_count   NUMBER;
BEGIN
	--
	--Initialize Local Variables
	l_procedure   := 'INCR_EXS';
	--
  l_stmt_num := 10;
  --
  --Collect all Exceptions into Exceptions Staging Table
  --
  INSERT INTO opi_dbi_wms_ex_stg exs
              (exs.exception_id
              ,exs.task_id
              ,exs.organization_id
              ,exs.inventory_item_id
              ,exs.subinventory_code
              ,exs.operation_plan_id
              ,exs.operation_plan_indicator
              ,exs.operation_plan_status
              ,exs.op_plan_instance_id
              ,exs.completion_date
              ,exs.reason_id
              )
  SELECT wmx.sequence_number        exception_id
        ,wmx.task_id                task_id
        ,tasks.organization_id      organization_id
        ,tasks.inventory_item_id    inventory_item_id
        ,tasks.subinventory_code    subinventory_code
        ,NULL                       operation_plan_id
        ,1                          operation_plan_indicator
        ,NULL                       operation_plan_status
        ,NULL                       op_plan_instance_id
        ,tasks.completion_date      completion_date
        ,wmx.reason_id              reason_id
  FROM   opi_dbi_wms_tasks_stg      tasks
        ,wms_exceptions             wmx
        ,mtl_transaction_reasons    mtr
  WHERE  wmx.task_id     = tasks.transaction_temp_id
  AND    tasks.task_type = 1
  AND    tasks.is_parent = 'Y'
  AND    mtr.reason_id   = wmx.reason_id
  AND    mtr.reason_type = 1
  UNION ALL
  SELECT wmx.sequence_number          exception_id
        ,wmx.task_id                  task_id
        ,ops.organization_id          organization_id
        ,ops.inventory_item_id        inventory_item_id
        ,ops.subinventory_code        subinventory_code
        ,ops.operation_plan_id        operation_plan_id
        ,2                            operation_plan_indicator
        ,ops.status                   operation_plan_status
        ,ops.op_plan_instance_id      op_plan_instance_id
        ,ops.plan_execution_end_date  completion_date
        ,wmx.reason_id                reason_id
  FROM   opi_dbi_wms_op_stg              ops
        ,wms_exceptions                  wmx
        ,wms_dispatched_tasks_history    wdth
        ,mtl_transaction_reasons         mtr
  WHERE  wdth.op_plan_instance_id = ops.op_plan_instance_id
  AND    wdth.task_type in (2,8)
  AND    wdth.transaction_temp_id IS NOT NULL
  AND    wmx.task_id           = wdth.transaction_temp_id
  AND    wdth.organization_id  = ops.organization_id
  AND    mtr.reason_id         = wmx.reason_id;
  --
  l_stmt_num := 20;
  l_row_count := sql%rowcount;
  bis_collection_utilities.put_line('Finished collection of Exceptions '
                                    ||'into Exceptions Staging Table : '
                                    ||l_row_count||' row(s) processed');
  --
  l_stmt_num := 30;
  --
  l_stmt_num := 40;
EXCEPTION
WHEN OTHERS THEN
  retcode := SQLCODE;
  errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
  --
  bis_collection_utilities.put_line('Error Number: ' || retcode);
  bis_collection_utilities.put_line('Error Message: '|| errbuf);
  --
END incr_exs;
--
/*************************** INCR_TASKF **************************************/
PROCEDURE incr_taskf (errbuf      IN OUT NOCOPY VARCHAR2
                     ,retcode     IN OUT NOCOPY VARCHAR2) IS
  --
  l_procedure   VARCHAR2(100);
  l_stmt_num    NUMBER;
  l_row_count   NUMBER;
BEGIN
	--
	--Initialize Local Variables
	l_procedure   := 'INCR_TASKF';
  l_stmt_num := 10;
  --
  --Load all Pick Tasks collected in Staging Table into Tasks Fact
  --
  MERGE INTO opi_dbi_wms_tasks_f taskf
  USING (
         SELECT  tasks.organization_id              organization_id
                ,tasks.subinventory_code            subinventory_code
                ,tasks.inventory_item_id            inventory_item_id
                ,TRUNC(tasks.completion_date)       completion_date
                ,COUNT(tasks.task_id)               picks
                ,COUNT(exs.task_id)                 picks_with_exceptions
                ,SUM(exs.ex_cnt)                    pick_exceptions
         FROM   opi_dbi_wms_tasks_stg tasks
              ,(SELECT ex.task_id
                      ,COUNT(ex.exception_id) ex_cnt
                FROM   opi_dbi_wms_ex_stg ex
                WHERE  ex.operation_plan_indicator = 1
                GROUP BY task_id ) exs
         WHERE  tasks.transaction_temp_id = exs.task_id(+)
         AND    tasks.task_type = 1
         GROUP BY tasks.organization_id
                 ,tasks.subinventory_code
                 ,tasks.inventory_item_id
                 ,TRUNC(tasks.completion_date)
        ) s
  ON (    taskf.organization_id   = s.organization_id
      AND taskf.subinventory_code = s.subinventory_code
      AND taskf.inventory_item_id = s.inventory_item_id
      AND taskf.completion_date = s.completion_date
     )
  WHEN MATCHED THEN
  UPDATE SET taskf.picks = taskf.picks + s.picks
            ,taskf.picks_with_exceptions
                          = taskf.picks_with_exceptions
                          + s.picks_with_exceptions
            ,taskf.pick_exceptions = taskf.pick_exceptions
                                    + s.pick_exceptions
            ,taskf.last_update_date   = SYSDATE
            ,taskf.last_updated_by    = g_user_id
            ,taskf.last_update_login  = g_login_id
  WHEN NOT MATCHED THEN
  INSERT (taskf.organization_id
         ,taskf.subinventory_code
         ,taskf.inventory_item_id
         ,taskf.completion_date
         ,taskf.picks
         ,taskf.picks_with_exceptions
         ,taskf.pick_exceptions
         ,taskf.creation_date
         ,taskf.last_update_date
         ,taskf.created_by
         ,taskf.last_updated_by
         ,taskf.last_update_login
         ,taskf.request_id
         ,taskf.program_application_id
         ,taskf.program_id
         ,taskf.program_update_date
         )VALUES
         (s.organization_id
         ,s.subinventory_code
         ,s.inventory_item_id
         ,s.completion_date
         ,s.picks
         ,s.picks_with_exceptions
         ,s.pick_exceptions
         ,SYSDATE
         ,SYSDATE
         ,g_user_id
         ,g_user_id
         ,g_login_id
         ,g_request_id
         ,g_program_application_id
         ,g_program_id
         ,g_sysdate
         );
  --
  l_stmt_num := 20;
  l_row_count := sql%rowcount;
  g_row_count := nvl(g_row_count,0) + l_row_count;
  bis_collection_utilities.put_line('Finished Loading Pick Tasks '
                                    ||'into Tasks Fact Table : '
                                    ||l_row_count||' row(s) processed');
  --
  l_stmt_num := 40;
  --
  l_stmt_num := 50;
EXCEPTION
WHEN OTHERS THEN
  retcode := SQLCODE;
  bis_collection_utilities.put_line('Tasks Fact Incremental '
                                   ||'Load Failed.');
  errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
  --
  bis_collection_utilities.put_line('Error Number: ' || retcode);
  bis_collection_utilities.put_line('Error Message: '|| errbuf);
  --
END incr_taskf;
--
/*************************** INCR_OPF ****************************************/
PROCEDURE incr_opf(errbuf      IN OUT NOCOPY VARCHAR2
                  ,retcode     IN OUT NOCOPY VARCHAR2) IS
	--
	l_procedure   VARCHAR2(100);
  l_stmt_num    NUMBER;
	--
l_row_count   	NUMBER;
BEGIN
	--
	--Initialize Local Variables
	--
	l_procedure   := 'INCR_OPF';
  l_stmt_num := 10;
  --
  --Load all Operation Plans collected in Staging Table into OP Fact
  --
  MERGE INTO opi_dbi_wms_op_f opf
  USING (
        SELECT ops.organization_id                   organization_id
              ,ops.subinventory_code                 subinventory_code
              ,ops.inventory_item_id                 inventory_item_id
              ,ops.operation_plan_id                 operation_plan_id
              ,ops.status                            status
              ,trunc(ops.plan_execution_end_date)    plan_execution_end_date
              ,sum(ops.plan_elapsed_time)            plan_elapsed_time
              ,nvl(count(ops.op_plan_instance_id),0) executions
              ,nvl(count(exs.op_plan_instance_id),0) executions_with_exceptions
              ,sum(nvl(exs.ex_cnt,0))                exceptions
        FROM   opi_dbi_wms_op_stg ops
              ,(SELECT NVL(ex.op_plan_instance_id,0)  op_plan_instance_id
                      ,count(ex.exception_id)         ex_cnt
                FROM   opi_dbi_wms_ex_stg ex
                WHERE  ex.operation_plan_indicator = 2
                GROUP BY nvl(ex.op_plan_instance_id,0)) exs
        WHERE  ops.op_plan_instance_id = exs.op_plan_instance_id(+)
        GROUP BY ops.organization_id
                ,ops.subinventory_code
                ,ops.inventory_item_id
                ,ops.operation_plan_id
                ,ops.status
                ,TRUNC(ops.plan_execution_end_date)
         ) s
  ON (    opf.organization_id   = s.organization_id
      AND opf.subinventory_code = s.subinventory_code
      AND opf.inventory_item_id = s.inventory_item_id
      AND opf.operation_plan_id = s.operation_plan_id
      AND opf.status            = s.status
      AND opf.plan_execution_end_date = s.plan_execution_end_date
     )
  WHEN MATCHED THEN
  UPDATE SET opf.plan_elapsed_time = opf.plan_elapsed_time
                                   + s.plan_elapsed_time
            ,opf.executions = opf.executions
                            + s.executions
            ,opf.executions_with_exceptions = opf.executions_with_exceptions
                                            + s.executions_with_exceptions
            ,opf.exceptions = opf.exceptions
                            + s.exceptions
            ,opf.last_update_date   = SYSDATE
            ,opf.last_updated_by    = g_user_id
            ,opf.last_update_login  = g_login_id
  WHEN NOT MATCHED THEN
  INSERT (opf.organization_id
         ,opf.subinventory_code
         ,opf.inventory_item_id
         ,opf.operation_plan_id
         ,opf.status
         ,opf.plan_execution_end_date
         ,opf.plan_elapsed_time
         ,opf.executions
         ,opf.executions_with_exceptions
         ,opf.exceptions
         ,opf.creation_date
         ,opf.last_update_date
         ,opf.created_by
         ,opf.last_updated_by
         ,opf.last_update_login
         ,opf.request_id
         ,opf.program_application_id
         ,opf.program_id
         ,opf.program_update_date
         )VALUES
         (s.organization_id
         ,s.subinventory_code
         ,s.inventory_item_id
         ,s.operation_plan_id
         ,s.status
         ,s.plan_execution_end_date
         ,s.plan_elapsed_time
         ,s.executions
         ,s.executions_with_exceptions
         ,s.exceptions
         ,SYSDATE
         ,SYSDATE
         ,g_user_id
         ,g_user_id
         ,g_login_id
         ,g_request_id
         ,g_program_application_id
         ,g_program_id
         ,g_sysdate
         );
  --
  l_stmt_num := 20;
  l_row_count := sql%rowcount;
  g_row_count := nvl(g_row_count,0) + l_row_count;
  bis_collection_utilities.put_line('Finished Loading Operation Plans '
                                    ||'into OP Fact Table : '
                                    ||l_row_count||' row(s) processed');
  --
  l_stmt_num := 30;
  COMMIT;
  --
  l_stmt_num := 40;
EXCEPTION
WHEN OTHERS THEN
  retcode := SQLCODE;
  bis_collection_utilities.put_line('Operation Plans Fact Incremental '
                                   ||'Load Failed.');
  errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
  --
  bis_collection_utilities.put_line('Error Number: ' || retcode);
  bis_collection_utilities.put_line('Error Message: '|| errbuf);
  --
END incr_opf;
--
/*************************** INCR_EXF ****************************************/
PROCEDURE incr_exf(errbuf      IN OUT NOCOPY VARCHAR2
                  ,retcode     IN OUT NOCOPY VARCHAR2) IS
  --
  l_procedure   VARCHAR2(100);
  l_stmt_num    NUMBER;
  l_row_count   NUMBER;
BEGIN
  --
  --Initialize Local Variables
  l_procedure   := 'INCR_EXF';
  l_stmt_num := 10;
  --
  --Load all Exceptions collected in Staging Table into Exceptions Fact
  --
  MERGE INTO opi_dbi_wms_ex_f exf
  USING (
          SELECT exs.organization_id                  organization_id
                ,exs.subinventory_code                subinventory_code
                ,exs.inventory_item_id                inventory_item_id
                ,exs.operation_plan_id                operation_plan_id
                ,exs.operation_plan_indicator         operation_plan_indicator
                ,exs.operation_plan_status            operation_plan_status
                ,exs.reason_id                        reason_id
                ,trunc(exs.completion_date)           completion_date
                ,COUNT(exs.exception_id)              exceptions
          FROM   opi_dbi_wms_ex_stg exs
          GROUP BY exs.organization_id
                  ,exs.subinventory_code
                  ,exs.inventory_item_id
                  ,exs.operation_plan_id
                  ,exs.operation_plan_indicator
                  ,exs.operation_plan_status
                  ,exs.reason_id
                  ,TRUNC(exs.completion_date)
        ) s
  ON (    exf.organization_id   = s.organization_id
      AND exf.subinventory_code = s.subinventory_code
      AND exf.inventory_item_id = s.inventory_item_id
      AND exf.operation_plan_id = s.operation_plan_id
      AND exf.operation_plan_indicator = s.operation_plan_indicator
      AND exf.operation_plan_status    = s.operation_plan_status
      AND exf.reason_id         = s.reason_id
      AND exf.completion_date   = s.completion_date
     )
  WHEN MATCHED THEN UPDATE SET exf.exceptions = exf.exceptions + s.exceptions
                              ,exf.last_update_date   = SYSDATE
                              ,exf.last_updated_by    = g_user_id
                              ,exf.last_update_login  = g_login_id
  WHEN NOT MATCHED THEN
  INSERT (exf.organization_id
         ,exf.subinventory_code
         ,exf.inventory_item_id
         ,exf.operation_plan_id
         ,exf.operation_plan_indicator
         ,exf.operation_plan_status
         ,exf.reason_id
         ,exf.completion_date
         ,exf.exceptions
         ,exf.creation_date
         ,exf.last_update_date
         ,exf.created_by
         ,exf.last_updated_by
         ,exf.last_update_login
         ,exf.request_id
         ,exf.program_application_id
         ,exf.program_id
         ,exf.program_update_date
         )VALUES
         (s.organization_id
         ,s.subinventory_code
         ,s.inventory_item_id
         ,s.operation_plan_id
         ,s.operation_plan_indicator
         ,s.operation_plan_status
         ,s.reason_id
         ,s.completion_date
         ,s.exceptions
         ,SYSDATE
         ,SYSDATE
         ,g_user_id
         ,g_user_id
         ,g_login_id
         ,g_request_id
         ,g_program_application_id
         ,g_program_id
         ,g_sysdate
         );
  --
  l_stmt_num := 20;
  l_row_count := sql%rowcount;
  g_row_count := nvl(g_row_count,0) + l_row_count;
  bis_collection_utilities.put_line('Finished Loading Exceptions '
                                    ||'into Exceptions Fact Table : '
                                    ||l_row_count||' row(s) processed');
  --
  l_stmt_num := 30;
  COMMIT;
  --
EXCEPTION
WHEN OTHERS THEN
  retcode := SQLCODE;
  bis_collection_utilities.put_line('Exceptions Fact Incremental '
                                   ||'Load Failed.');
  errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                       ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
  --
  bis_collection_utilities.put_line('Error Number: ' || retcode);
  bis_collection_utilities.put_line('Error Message: '|| errbuf);
  --
END incr_exf;
--
--Public Procedures
--
/*****************************************************************************/
/********************************* INITIAL_LOAD ******************************/
/*****************************************************************************/
PROCEDURE initial_load(errbuf      IN OUT NOCOPY VARCHAR2
                      ,retcode     IN OUT NOCOPY VARCHAR2)
AS
  --
  --Local Variables
  --
  l_wms_gsd                 DATE;
  l_bis_gsd                 DATE;
  l_list                    DBMS_SQL.VARCHAR2_TABLE;
  --
  l_procedure               VARCHAR2(100);
  l_stmt_num        				NUMBER;
  program_in_progress       EXCEPTION;
  gsd_not_available         EXCEPTION;
  no_data_available         EXCEPTION;
  PRAGMA                    EXCEPTION_INIT(no_data_available,-06503);
BEGIN
  --
  --Initialize Global Variables
  g_package                 := 'OPI_DBI_WAA_PKG.';
	g_sysdate                 := SYSDATE;
	g_user_id                 := nvl(fnd_global.user_id, -1);
	g_login_id                := nvl(fnd_global.login_id, -1);
	g_program_id              := fnd_global.CONC_PROGRAM_ID;
	g_program_login_id        := fnd_global.CONC_LOGIN_ID;
	g_program_application_id  := fnd_global.PROG_APPL_ID;
	g_request_id              := fnd_global.CONC_REQUEST_ID;
	g_error                   := -1;
  --
  --Initialize Local Variables
  l_procedure               := 'INITIAL_LOAD';
  l_stmt_num := 10;
  --
  g_last_run_date := SYSDATE;
  --
  l_stmt_num := 20;
  --
  l_list(1) := 'BIS_GLOBAL_START_DATE';
  IF bis_common_parameters.check_global_parameters(l_list) THEN
    --
    l_stmt_num := 30;
    l_bis_gsd := BIS_COMMON_PARAMETERS.GET_GLOBAL_START_DATE;
    --
    IF l_bis_gsd IS NULL THEN
      RAISE gsd_not_available;
    END IF;
    --
    l_stmt_num := 60;
    --
    BEGIN
      l_wms_gsd:= get_wms_gsd(errbuf,retcode);
    EXCEPTION
		WHEN no_data_available THEN
		  retcode := 1;
		  errbuf := 'Warning in '||g_package||l_procedure||' at line#: '
		                       ||l_stmt_num||' - '
		                       ||'No data avialble for extraction';
		  --
		  bis_collection_utilities.put_line('Error Number: ' || retcode);
		  bis_collection_utilities.put_line('Error Message: '|| errbuf);
		  --
    END;
    --
    print_gsd_message(l_wms_gsd);
    --
    l_stmt_num := 70;
    --
    IF g_gsd IS NULL THEN
      g_gsd                   := greatest(l_wms_gsd,l_bis_gsd);
      l_stmt_num := 80;
    END IF;
    --
    l_stmt_num := 100;
    --
    bis_collection_utilities.put_line
    ('Initial Load starts at '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
    --
    l_stmt_num := 110;
    --
    IF BIS_COLLECTION_UTILITIES.SETUP('OPI_DBI_WMS_TASKS_F') = FALSE THEN
      --
      l_stmt_num := 120;
      RAISE_APPLICATION_ERROR(-20000, errbuf);
    END IF;
    --
    l_stmt_num := 130;
    --
    -- Alter the Session variables for good Performance
    execute immediate 'alter session set hash_area_size=100000000';
    execute immediate 'alter session set sort_area_size=100000000';
    --
    l_stmt_num := 140;
    --
    cleanup_initial_data(errbuf,retcode);
    l_stmt_num := 150;
    --
    cleanup_staging_index(errbuf,retcode);
    l_stmt_num := 160;
    -- Collect data into all Staging Tables
    init_tasks(errbuf,retcode);
    l_stmt_num := 170;
    --
    init_ops(errbuf,retcode);
    l_stmt_num := 180;
    --
    init_exs(errbuf,retcode);
    l_stmt_num := 190;
    --
    reset_staging_index(errbuf,retcode);
    l_stmt_num := 200;
    --
    staging_gather_stats(errbuf,retcode);
    l_stmt_num := 210;
    --
    init_taskf(errbuf,retcode);
    l_stmt_num := 220;
    --
    init_opf(errbuf,retcode);
    l_stmt_num := 230;
    --
    init_exf(errbuf,retcode);
    l_stmt_num := 240;
    --
    IF l_wms_gsd IS NOT NULL THEN
      set_last_run_date(errbuf,retcode);
    END IF;
    l_stmt_num := 250;
    --
    cleanup_staging_data(errbuf,retcode);
    l_stmt_num := 260;
    --
    wrapup_success('INIT',errbuf,retcode);
    l_stmt_num := 270;
    --
  ELSE
    l_stmt_num := 280;
    retcode := g_error;
    bis_collection_utilities.put_line('Global Parameters are not setup.');
    bis_collection_utilities.put_line('Please check that the profile option '
                                     ||'BIS_GLOBAL_START_DATE is setup.');
    wrapup_failure('INIT');
    l_stmt_num := 290;
  END IF;
EXCEPTION
  WHEN GSD_NOT_AVAILABLE THEN
    errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                         ||l_stmt_num;
    bis_collection_utilities.put_line('Error Message: '|| errbuf);
    bis_collection_utilities.put_line('Global start date'
                                     ||' is not available.'
                                     ||' Aborting.');
    BIS_COLLECTION_UTILITIES.put_line(SQLERRM);
    retcode := SQLCODE;
    errbuf  := SQLERRM;
  WHEN OTHERS THEN
    retcode := SQLCODE;
    bis_collection_utilities.put_line('Initial Load Failed.');
    errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                         ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
    --
    bis_collection_utilities.put_line('Error Number: ' || retcode);
    bis_collection_utilities.put_line('Error Message: '|| errbuf);
    --
    wrapup_failure('INIT');
    --
    RAISE_APPLICATION_ERROR(-20000,errbuf);
    --
END initial_load;
--
/*****************************************************************************/
/******************************** INCREMENTAL_LOAD ***************************/
/*****************************************************************************/
PROCEDURE incremental_load(errbuf      IN OUT NOCOPY VARCHAR2
                          ,retcode     IN OUT NOCOPY VARCHAR2) IS
  l_wms_gsd                 DATE;
  l_bis_gsd                 DATE;
  l_list                    DBMS_SQL.VARCHAR2_TABLE;
  --
  l_procedure               VARCHAR2(100);
  l_stmt_num        				NUMBER;
  program_in_progress       EXCEPTION;
  gsd_not_available         EXCEPTION;
  no_data_available         EXCEPTION;
  PRAGMA                    EXCEPTION_INIT(no_data_available,-06503);
BEGIN
  --
  --Initialize Global Variables
  g_package                 := 'OPI_DBI_WAA_PKG.';
	g_sysdate                 := SYSDATE;
	g_user_id                 := nvl(fnd_global.user_id, -1);
	g_login_id                := nvl(fnd_global.login_id, -1);
	g_program_id              := fnd_global.CONC_PROGRAM_ID;
	g_program_login_id        := fnd_global.CONC_LOGIN_ID;
	g_program_application_id  := fnd_global.PROG_APPL_ID;
	g_request_id              := fnd_global.CONC_REQUEST_ID;
	g_error                   := -1;
  g_last_run_date           :=  SYSDATE;
  --
  --Initialize Local Variables
  l_procedure               := 'INCREMENTAL_LOAD';
  --
  l_list(1) := 'BIS_GLOBAL_START_DATE';
  IF bis_common_parameters.check_global_parameters(l_list) THEN
    --
    l_stmt_num := 30;
    l_bis_gsd := BIS_COMMON_PARAMETERS.GET_GLOBAL_START_DATE;
    --
    IF l_bis_gsd IS NULL THEN
      RAISE gsd_not_available;
    END IF;
    --
    l_stmt_num := 60;
    --
    check_last_run_date(errbuf,retcode);
    --
    BEGIN
      l_wms_gsd:= get_wms_gsd(errbuf,retcode);
    EXCEPTION
		WHEN no_data_available THEN
		  retcode := 1;
		  errbuf := 'Warning in '||g_package||l_procedure||' at line#: '
		                       ||l_stmt_num||' - '
		                       ||'No data avialble for extraction';
		  --
		  bis_collection_utilities.put_line('Error Number: ' || retcode);
		  bis_collection_utilities.put_line('Error Message: '|| errbuf);
		  --
    END;
    --
    print_gsd_message(l_wms_gsd);
    --
    l_stmt_num := 70;
    --
    IF g_gsd IS NULL THEN
      g_gsd                   := greatest(l_wms_gsd,l_bis_gsd);
      l_stmt_num := 80;
      --
    END IF;
    --
    l_stmt_num := 100;
    --
    bis_collection_utilities.put_line
    ('Incremental Load starts at '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
    --
    l_stmt_num := 110;
    --
    IF BIS_COLLECTION_UTILITIES.SETUP('OPI_DBI_WMS_TASKS_F') = FALSE THEN
      --
      l_stmt_num := 120;
      RAISE_APPLICATION_ERROR(-20000, errbuf);
    END IF;
    --
    l_stmt_num := 130;
    --
    -- Alter the Session variables for good Performance
    execute immediate 'alter session set hash_area_size=100000000';
    execute immediate 'alter session set sort_area_size=100000000';
    --
    l_stmt_num := 140;
    --
    cleanup_staging_data(errbuf,retcode);
    --
    incr_tasks(errbuf,retcode);
    l_stmt_num := 170;
    --
    incr_ops(errbuf,retcode);
    l_stmt_num := 180;
    --
    incr_exs(errbuf,retcode);
    l_stmt_num := 190;
    --
    staging_gather_stats(errbuf,retcode);
    l_stmt_num := 210;
    --
    incr_taskf(errbuf,retcode);
    l_stmt_num := 220;
    --
    incr_opf(errbuf,retcode);
    l_stmt_num := 230;
    --
    incr_exf(errbuf,retcode);
    l_stmt_num := 240;
    --
    reset_last_run_date(errbuf,retcode);
    l_stmt_num := 250;
    --
    wrapup_success('INCR',errbuf,retcode);
    l_stmt_num := 270;
  ELSE
    l_stmt_num := 280;
    retcode := g_error;
    bis_collection_utilities.put_line('Global Parameters are not setup.');
    bis_collection_utilities.put_line('Please check that the profile option '
                                     ||'BIS_GLOBAL_START_DATE is setup.');
    wrapup_failure('INCR');
    l_stmt_num := 290;
  END IF;
  --
EXCEPTION
  WHEN GSD_NOT_AVAILABLE THEN
    errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                         ||l_stmt_num;
    bis_collection_utilities.put_line('Error Message: '|| errbuf);
    bis_collection_utilities.put_line('Global start date'
                                     ||' is not available.'
                                     ||' Aborting.');
    BIS_COLLECTION_UTILITIES.put_line(SQLERRM);
    retcode := SQLCODE;
    errbuf  := SQLERRM;
  WHEN NO_INITIAL_DATA THEN
    errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                         ||l_stmt_num;
    bis_collection_utilities.put_line('Error Message: '|| errbuf);
    bis_collection_utilities.put_line(' Initial Load data is not available,'
                                     ||' Please run the Initial Load');
    retcode := -1;
  WHEN OTHERS THEN
    retcode := SQLCODE;
    bis_collection_utilities.put_line('Incremental Load Failed.');
    errbuf := 'ERROR in '||g_package||l_procedure||' at line#: '
                         ||l_stmt_num||' - '||substr(SQLERRM, 1,200);
    --
    bis_collection_utilities.put_line('Error Number: ' || retcode);
    bis_collection_utilities.put_line('Error Message: '|| errbuf);
    --
    wrapup_failure('INCR');
    --
    RAISE_APPLICATION_ERROR(-20000,errbuf);
    --
END incremental_load;
--
END opi_dbi_wms_waa_pkg;

/
