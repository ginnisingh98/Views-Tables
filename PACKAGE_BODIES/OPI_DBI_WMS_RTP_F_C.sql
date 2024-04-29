--------------------------------------------------------
--  DDL for Package Body OPI_DBI_WMS_RTP_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_WMS_RTP_F_C" AS
/* $Header: OPIDEWMSRTPB.pls 120.0 2005/05/24 17:14:27 appldev noship $ */
g_init boolean := false;

/* PUBLIC PROCEDURE */
PROCEDURE initial_load (errbuf    OUT NOCOPY VARCHAR2,
                        retcode         OUT NOCOPY NUMBER)
  IS
     l_opi_schema          VARCHAR2(30);
     l_status              VARCHAR2(30);
     l_industry            VARCHAR2(30);

     l_stmt VARCHAR2(4000);
BEGIN
   IF (FND_INSTALLATION.GET_APP_INFO('OPI', l_status, l_industry, l_opi_schema)) THEN
      l_stmt := 'TRUNCATE TABLE ' || l_opi_schema || '.OPI_DBI_WMS_RTP_F';
      EXECUTE IMMEDIATE l_stmt;
      g_init := true;
      populate_rtp_fact (errbuf, retcode);
   END IF;

EXCEPTION
WHEN OTHERS THEN
   Errbuf:= Sqlerrm;
   Retcode:=sqlcode;

   ROLLBACK;
   POA_LOG.debug_line('initial_load' || Sqlerrm || sqlcode || sysdate);
   RAISE_APPLICATION_ERROR(-20000,'Stack Dump Follows =>', true);

END initial_load;



/* PUBLIC PROCEDURE */
PROCEDURE populate_rtp_fact (errbuf    OUT NOCOPY VARCHAR2,
                            retcode         OUT NOCOPY NUMBER)
IS
   l_go_ahead BOOLEAN := false;
   l_count NUMBER := 0;

   l_opi_schema          VARCHAR2(30);
   l_status              VARCHAR2(30);
   l_industry            VARCHAR2(30);

   l_stmt varchar2(4000);
   l_start_date VARCHAR2(22);
   l_end_date varchar2(22);
   l_glob_date VARCHAR2(22);

   l_start_time DATE;
   l_login number;
   l_user number;
   l_dop NUMBER := 1;
   d_start_date DATE;
   d_end_date DATE;
   d_glob_date DATE;
BEGIN
   Errbuf :=NULL;
   Retcode:=0;

   DBMS_APPLICATION_INFO.SET_MODULE(module_name => 'OPI DBI RTP COLLECT', action_name => 'start');
   l_dop := bis_common_parameters.get_degree_of_parallelism;
   -- default DOP to profile in EDW_PARALLEL_SRC if 2nd param is not passed
   l_go_ahead := bis_collection_utilities.setup('OPIDBIRTP');
   if (g_init) then
	   execute immediate 'alter session set hash_area_size=104857600';
	   execute immediate 'alter session set sort_area_size=104857600';
   end if;
   IF (NOT l_go_ahead) THEN
      errbuf := fnd_message.get;
      RAISE_APPLICATION_ERROR (-20000, 'Error in SETUP: ' || errbuf);
   END IF;
   bis_collection_utilities.g_debug := FALSE;

 IF(g_init) THEN
	l_start_date := To_char(bis_common_parameters.get_global_start_date
				, 'YYYY/MM/DD HH24:MI:SS');
        d_start_date := bis_common_parameters.get_global_start_date;
   ELSE
        l_start_date := To_char(fnd_date.displaydt_to_date(bis_collection_utilities.get_last_refresh_period('OPIDBIRTP')) - 0.004,'YYYY/MM/DD HH24:MI:SS');
      /* note that if there is not a success record in the log, we should get global start date as l_start_date */
      d_start_date := fnd_date.displaydt_to_date(bis_collection_utilities.get_last_refresh_period('OPIDBIRTP')) - 0.004;
   END IF;

      l_end_date := To_char(Sysdate, 'YYYY/MM/DD HH24:MI:SS');
      d_end_date := Sysdate;

   bis_collection_utilities.log( 'The collection range is from '||
				 l_start_date ||' to '|| l_end_date, 0);

   l_glob_date := To_char(bis_common_parameters.get_global_start_date, 'YYYY/MM/DD HH24:MI:SS');
   d_glob_date := bis_common_parameters.get_global_start_date;

  DBMS_APPLICATION_INFO.SET_ACTION('rates');
  if (not(fnd_installation.get_app_info('OPI', l_status, l_industry, l_opi_schema))) then
    bis_collection_utilities.log('Error getting app info '|| 'Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
    RAISE_APPLICATION_ERROR (-20000, 'Error in GET_APP_INFO: ' || errbuf);
  end if;
  l_stmt := 'TRUNCATE TABLE ' || l_opi_schema || '.OPI_DBI_WMS_UOM_RATES';
  execute immediate l_stmt;

  if(g_init) then

    insert /*+ APPEND PARALLEL (opi_dbi_wms_uom_rates) */ into opi_dbi_wms_uom_rates
    (
      inventory_item_id,
      primary_uom_code,
      transaction_uom_code,
      rate
    )
    select
    inventory_item_id,
    primary_uom_code,
    transaction_uom_code,
    ( case when primary_uom_code = transaction_uom_code then 1
         else opi_dbi_wms_utility_pkg.get_uom_rate(
                inventory_item_id,
                primary_uom_code,
                transaction_uom_code
              )
      end
    ) rate
    from
    (
      select /*+ PARALLEL (wdth) PARALLEL (msi) PARALLEL (rtx) PARALLEL (oplan)
             PARALLEL (sinv) USE_HASH(wdth) USE_HASH(msi) USE_HASH(rtx) USE_HASH(oplan)
             USE_HASH(sinv) pq_distribute(oplan hash,hash) pq_distribute(msi hash,hash)
             pq_distribute(rtx hash,hash) */ distinct
      wdth.inventory_item_id,
      msi.primary_uom_code,
      wdth.transaction_uom_code
      from
      wms_dispatched_tasks_history  wdth,
      mtl_system_items              msi,
      poa_dbi_rtx_f                 rtx,
      wms_op_plans_b                oplan,
      mtl_secondary_inventories     sinv
      where
            nvl(wdth.is_parent, 'N') = 'Y'
      and   wdth.task_type = 2
      and   wdth.status = 6
      and   nvl(sinv.subinventory_type, 1) = 1
      and   oplan.plan_type_id = 1
      and   wdth.dest_subinventory_code = sinv.secondary_inventory_name
      and   wdth.inventory_item_id = msi.inventory_item_id
      and   wdth.organization_id = msi.organization_id
      and   wdth.source_document_id = rtx.transaction_id
      and   wdth.organization_id = sinv.organization_id
      and   wdth.operation_plan_id = oplan.operation_plan_id
      and   wdth.last_update_date >= d_start_date
      and   (wdth.last_update_date is null or wdth.last_update_date <= d_end_date)
      and   wdth.creation_date >= d_start_date
    );

  else

    insert /*+ APPEND */ into opi_dbi_wms_uom_rates
    (
      inventory_item_id,
      primary_uom_code,
      transaction_uom_code,
      rate
    )
    select
    inventory_item_id,
    primary_uom_code,
    transaction_uom_code,
    ( case when primary_uom_code = transaction_uom_code then 1
         else opi_dbi_wms_utility_pkg.get_uom_rate(
                inventory_item_id,
                primary_uom_code,
                transaction_uom_code
              )
      end
    ) rate
    from
    (
      select /*+ leading(wdth) */ distinct
      wdth.inventory_item_id,
      msi.primary_uom_code,
      wdth.transaction_uom_code
      from
      wms_dispatched_tasks_history  wdth,
      mtl_system_items              msi,
      poa_dbi_rtx_f                 rtx,
      wms_op_plans_b                oplan,
      mtl_secondary_inventories     sinv
      where
            nvl(wdth.is_parent, 'N') = 'Y'
      and   wdth.task_type = 2
      and   wdth.status = 6
      and   nvl(sinv.subinventory_type, 1) = 1
      and   oplan.plan_type_id = 1
      and   wdth.dest_subinventory_code = sinv.secondary_inventory_name
      and   wdth.inventory_item_id = msi.inventory_item_id
      and   wdth.organization_id = msi.organization_id
      and   wdth.source_document_id = rtx.transaction_id
      and   wdth.organization_id = sinv.organization_id
      and   wdth.operation_plan_id = oplan.operation_plan_id
      and   wdth.last_update_date between d_start_date and d_end_date
      and   wdth.creation_date >= d_glob_date
    );

  end if;

  if (opi_dbi_wms_utility_pkg.g_missing_uom) then
    opi_dbi_wms_utility_pkg.g_missing_uom := false;
    errbuf := 'there are missing uom conversions';
    raise_application_error (-20000, 'error in rates table collection: ' || errbuf);
  end if;

  COMMIT;
  DBMS_APPLICATION_INFO.SET_ACTION('stats');
  fnd_stats.gather_table_stats(OWNNAME => l_opi_schema, TABNAME => 'OPI_DBI_WMS_UOM_RATES');

   bis_collection_utilities.log('Populate base table: '|| 'Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
										   -- bis_collection_utilities.log('Identified '||

   l_start_time := sysdate;
   l_login := fnd_global.login_id;
   l_user := fnd_global.user_id;
   DBMS_APPLICATION_INFO.SET_ACTION('collect');

      IF (g_init) THEN

 	bis_collection_utilities.log('Initial Load - populate base fact. '|| 'Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
	INSERT /*+ APPEND PARALLEL(t) */ INTO opi_dbi_wms_rtp_f t (
                                  task_id,
                                  transaction_id,
                                  organization_id,
                                  subinventory_code,
                                  inventory_item_id,
                                  operation_plan_id,
                                  op_plan_instance_id,
                                  source_document_id,
                                  putaway_completion_date,
                                  putaway_quantity,
                                  putaway_uom_code,
                                  putaway_uom_conv_rate,
                                  rcv_transaction_date,
                                  last_update_date,
                                  created_by,
                                  last_updated_by,
                                  last_update_login,
                                  program_id,
                                  program_login_id,
                                  program_application_id,
                                  request_id
       ) SELECT task_id,
                transaction_id,
                organization_id,
                subinventory_code,
                inventory_item_id,
                operation_plan_id,
                op_plan_instance_id,
                source_document_id,
                putaway_completion_date,
                putaway_quantity,
                putaway_uom_code,
                putaway_uom_conv_rate,
                rcv_transaction_date,
                current_time,
                login_id,
                login_id,
                user_id,
                null,
                null,
                null,
                null
      FROM (
      SELECT /*+ PARALLEL(wdth) PARALLEL(rtx) PARALLEL(oplan) PARALLEL(sinv) PARALLEL(msi)
              PARALLEL(rat) USE_HASH(wdth) use_hash(rtx) use_hash(oplan) use_hash(sinv)
              use_hash(msi) use_hash(rat) pq_distribute(wdth hash,hash)
              pq_distribute(oplan hash,hash) pq_distribute(msi hash,hash) pq_distribute(rtx hash,hash) */
	       wdth.task_id,
               wdth.transaction_id,
               wdth.organization_id,
               wdth.dest_subinventory_code subinventory_code,
               wdth.inventory_item_id,
               wdth.operation_plan_id,
               wdth.op_plan_instance_id,
               wdth.source_document_id,
               wdth.drop_off_time putaway_completion_date,
               wdth.transaction_quantity putaway_quantity,
               msi.primary_uom_code putaway_uom_code,
               rtx.receive_txn_date rcv_transaction_date,
               rat.rate putaway_uom_conv_rate,
	       l_start_time current_time,
	       l_login login_id,
	       l_user user_id
     FROM      wms_dispatched_tasks_history wdth,
	       poa_dbi_rtx_f rtx,
	       wms_op_plans_b oplan,
               mtl_secondary_inventories sinv,
               mtl_system_items msi,
               opi_dbi_wms_uom_rates rat
     WHERE     nvl(wdth.is_parent, 'N') = 'Y' -- make sure that op plan started after inspections have 18/1/27 and task_type of 2, checked that 18/1/27 is true.. need to check 2
           and wdth.task_type = 2
	   and wdth.status = 6
           and nvl(sinv.subinventory_type, 1) = 1
	   and oplan.plan_type_id = 1
           and wdth.dest_subinventory_code = sinv.secondary_inventory_name
           and wdth.inventory_item_id = msi.inventory_item_id
           and wdth.organization_id = msi.organization_id
	   and wdth.organization_id = sinv.organization_id
	   and wdth.operation_plan_id = oplan.operation_plan_id
	   and wdth.source_document_id = rtx.transaction_id
           and wdth.inventory_item_id = rat.inventory_item_id
           and wdth.transaction_uom_code = rat.transaction_uom_code
           and msi.primary_uom_code = rat.primary_uom_code
           and wdth.creation_date >= d_start_date
           and wdth.last_update_date >= d_start_date
           and (wdth.last_update_date is null or wdth.last_update_date <= d_end_date) );
    COMMIT;
    else
/*incremental branch*/
	    merge INTO opi_dbi_wms_rtp_f T
	      using (
		     select /*+ leading(wdth) */
	       wdth.task_id,
               wdth.transaction_id,
               wdth.organization_id,
               wdth.dest_subinventory_code subinventory_code,
               wdth.inventory_item_id,
               wdth.operation_plan_id,
               wdth.op_plan_instance_id,
               wdth.source_document_id,
               wdth.drop_off_time putaway_completion_date,
               wdth.transaction_quantity putaway_quantity,
               msi.primary_uom_code putaway_uom_code,
               rtx.receive_txn_date rcv_transaction_date,
               rat.rate putaway_uom_conv_rate,
	       l_start_time current_time,
	       l_login login_id,
	       l_user user_id
     FROM      wms_dispatched_tasks_history wdth,
	       poa_dbi_rtx_f rtx,
	       wms_op_plans_b oplan,
               mtl_secondary_inventories sinv,
               mtl_system_items msi,
               opi_dbi_wms_uom_rates rat
     WHERE     nvl(wdth.is_parent, 'N') = 'Y' -- make sure that op plan started after inspections have 18/1/27 and task_type of 2, checked that 18/1/27 is true.. need to check 2
           and wdth.task_type = 2
	   and wdth.status = 6
           and nvl(sinv.subinventory_type, 1) = 1
	   and oplan.plan_type_id = 1
           and wdth.dest_subinventory_code = sinv.secondary_inventory_name
           and wdth.inventory_item_id = msi.inventory_item_id
           and wdth.organization_id = msi.organization_id
           and wdth.organization_id = sinv.organization_id
	   and wdth.operation_plan_id = oplan.operation_plan_id
 	   and wdth.source_document_id = rtx.transaction_id
	   and wdth.last_update_date between d_start_date and d_end_date
           and wdth.inventory_item_id = rat.inventory_item_id
           and msi.primary_uom_code = rat.primary_uom_code
           and wdth.transaction_uom_code = rat.transaction_uom_code
           and wdth.creation_date >= d_glob_date
) s
	ON (t.task_id = s.task_id)
	WHEN matched THEN UPDATE SET
           t.organization_id = s.organization_id,
           t.subinventory_code = s.subinventory_code,
           t.inventory_item_id = s.inventory_item_id,
           t.operation_plan_id = s.operation_plan_id,
           t.op_plan_instance_id = s.op_plan_instance_id,
           t.source_document_id = s.source_document_id,
           t.putaway_completion_date = s.putaway_completion_date,
           t.putaway_quantity = s.putaway_quantity,
           t.putaway_uom_code = s.putaway_uom_code,
           t.putaway_uom_conv_rate = s.putaway_uom_conv_rate,
           t.rcv_transaction_date = s.rcv_transaction_date ,
           t.last_update_date = sysdate,
           t.created_by = s.user_id,
           t.last_updated_by = s.user_id,
           t.last_update_login = s.login_id,
           t.program_id = null,
           t.program_login_id = null,
           t.program_application_id = null,
           t.request_id = null

	WHEN NOT matched THEN INSERT (
                                  t.task_id,
                                  t.transaction_id,
                                  t.organization_id,
                                  t.subinventory_code,
                                  t.inventory_item_id,
                                  t.operation_plan_id,
                                  t.op_plan_instance_id,
                                  t.source_document_id,
                                  t.putaway_completion_date,
                                  t.putaway_quantity,
                                  t.putaway_uom_code,
                                  t.putaway_uom_conv_rate,
                                  t.rcv_transaction_date,
                                  t.last_update_date,
                                  t.created_by,
                                  t.last_updated_by,
                                  t.last_update_login,
                                  t.program_id,
                                  t.program_login_id,
                                  t.program_application_id,
                                  t.request_id
       ) VALUES (
		s.task_id,
                s.transaction_id,
                s.organization_id,
                s.subinventory_code,
                s.inventory_item_id,
                s.operation_plan_id,
                s.op_plan_instance_id,
                s.source_document_id,
                s.putaway_completion_date,
                s.putaway_quantity,
                s.putaway_uom_code,
                s.putaway_uom_conv_rate,
                s.rcv_transaction_date,
                sysdate,
                s.user_id,
                s.user_id,
                s.login_id,
                null,
                null,
                null,
                null
);

COMMIT;

  END IF;

   bis_collection_utilities.log('Collection complete '|| 'Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
   bis_collection_utilities.wrapup(TRUE, l_count, 'OPI DBI WMS RTP COLLECTION SUCEEDED', To_date(l_start_date, '''YYYY/MM/DD HH24:MI:SS'''), To_date(l_end_date, '''YYYY/MM/DD HH24:MI:SS'''));
   g_init := false;
   DBMS_APPLICATION_INFO.set_module(NULL, NULL);
EXCEPTION
   WHEN OTHERS THEN
      DBMS_APPLICATION_INFO.SET_ACTION('error');
      errbuf:=sqlerrm;
      retcode:=sqlcode;
      bis_collection_utilities.log('Collection failed with '||errbuf||':'||retcode||' Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
--      dbms_output.put_line(l_start_date || l_end_date);
      bis_collection_utilities.wrapup(FALSE, l_count, errbuf||':'||retcode,
				      To_date(l_start_date, '''YYYY/MM/DD HH24:MI:SS'''), To_date(l_end_date, '''YYYY/MM/DD HH24:MI:SS'''));


      RAISE;
END populate_rtp_fact;


END OPI_DBI_WMS_RTP_F_C;

/
