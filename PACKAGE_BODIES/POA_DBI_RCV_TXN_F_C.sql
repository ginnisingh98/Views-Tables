--------------------------------------------------------
--  DDL for Package Body POA_DBI_RCV_TXN_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_RCV_TXN_F_C" AS
/* $Header: poadbirtxfrefb.pls 120.0 2005/06/01 14:29:56 appldev noship $ */
g_init boolean := false;

/* PUBLIC PROCEDURE */
PROCEDURE initial_load (errbuf    OUT NOCOPY VARCHAR2,
                        retcode         OUT NOCOPY NUMBER)
  IS
     l_poa_schema          VARCHAR2(30);
     l_status              VARCHAR2(30);
     l_industry            VARCHAR2(30);

     l_stmt VARCHAR2(4000);
BEGIN
   IF (FND_INSTALLATION.GET_APP_INFO('POA', l_status, l_industry, l_poa_schema)) THEN
      l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_RTX_F';
      EXECUTE IMMEDIATE l_stmt;

      l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_RTX_INC';
      EXECUTE IMMEDIATE l_stmt;

      l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_RTX_RATES';
      EXECUTE IMMEDIATE l_stmt;

--      l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_ITEMS';
--      EXECUTE IMMEDIATE l_stmt;

      g_init := true;
      populate_rcv_txn_facts (errbuf, retcode);
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
PROCEDURE populate_rcv_txn_facts (errbuf    OUT NOCOPY VARCHAR2,
                            retcode         OUT NOCOPY NUMBER)
IS
   l_no_batch NUMBER;
   l_go_ahead BOOLEAN := false;
   l_count NUMBER := 0;

   l_poa_schema          VARCHAR2(30);
   l_status              VARCHAR2(30);
   l_industry            VARCHAR2(30);

   l_stmt varchar2(4000);
   l_start_date VARCHAR2(22);
   l_end_date varchar2(22);
   l_glob_date VARCHAR2(22);
/*
  fnd_date.initialize('YYYY/MM/DD', 'YYYY/MM/DD HH24:MI:SS');
  l_from_date := fnd_date.displayDT_to_date(p_from_date);
  l_to_date := fnd_date.displayDT_to_date(p_to_date);
*/
   l_ret number;
   l_batch_size NUMBER;
   l_start_time DATE;
   l_login number;
   l_user number;
   l_dop NUMBER := 1;
   d_start_date DATE;
   d_end_date DATE;
   d_glob_date DATE;
   l_rate_type VARCHAR2(30);
   l_srate_type varchar2(30);
   l_sec_cur_yn number;
   l_global_cur_code gl_sets_of_books.currency_code%type;
   l_sglobal_cur_code gl_sets_of_books.currency_code%type;
BEGIN
   Errbuf :=NULL;
   Retcode:=0;
   l_global_cur_code := bis_common_parameters.get_currency_code;
   l_sglobal_cur_code := bis_common_parameters.get_secondary_currency_code;
   l_srate_type := bis_common_parameters.get_secondary_rate_type;
   l_batch_size := bis_common_parameters.get_batch_size(10);
   l_rate_type := bis_common_parameters.get_rate_type;
   if(poa_currency_pkg.display_secondary_currency_yn)
   then
     l_sec_cur_yn := 1;
   else
     l_sec_cur_yn := 0;
   end if;

   DBMS_APPLICATION_INFO.SET_MODULE(module_name => 'DBI RTX COLLECT', action_name => 'start');
   l_dop := bis_common_parameters.get_degree_of_parallelism;
   -- default DOP to profile in EDW_PARALLEL_SRC if 2nd param is not passed
   l_go_ahead := bis_collection_utilities.setup('POARCVTXN');
   if (g_init) then
	   execute immediate 'alter session set hash_area_size=104857600';
	   execute immediate 'alter session set sort_area_size=104857600';
--	   execute immediate 'alter session disable parallel dml' ;
   end if;
   IF (NOT l_go_ahead) THEN
      errbuf := fnd_message.get;
      RAISE_APPLICATION_ERROR (-20000, 'Error in SETUP: ' || errbuf);
   END IF;
   bis_collection_utilities.g_debug := FALSE;

  -- --------------------------------------------
  -- Taking care of cases where the input from/to
  -- date is NULL.
  -- --------------------------------------------

  IF(g_init) THEN
	l_start_date := To_char(bis_common_parameters.get_global_start_date
				, 'YYYY/MM/DD HH24:MI:SS');
        d_start_date := bis_common_parameters.get_global_start_date;
   ELSE
      l_start_date := '''' || To_char(fnd_date.displaydt_to_date(bis_collection_utilities.get_last_refresh_period('POARCVTXN')) - 0.004,'YYYY/MM/DD HH24:MI:SS') || '''';
      /* note that if there is not a success record in the log, we should get global start date as l_start_date */
      d_start_date := fnd_date.displaydt_to_date(bis_collection_utilities.get_last_refresh_period('POARCVTXN')) - 0.004;
    END IF;

      l_end_date := '''' || To_char(Sysdate, 'YYYY/MM/DD HH24:MI:SS') || '''';
      d_end_date := Sysdate;



   bis_collection_utilities.log( 'The collection range is from '||
				 l_start_date ||' to '|| l_end_date, 0);


   IF (l_batch_size IS NULL) THEN
      l_batch_size := 10000;
   END if;

   bis_collection_utilities.log('Truncate INC table: '|| 'Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
   IF (FND_INSTALLATION.GET_APP_INFO('POA', l_status, l_industry, l_poa_schema)) THEN
      l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_RTX_INC';
      EXECUTE IMMEDIATE l_stmt;

      l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_RTX_RATES';
      EXECUTE IMMEDIATE l_stmt;
   END IF;

   DBMS_APPLICATION_INFO.SET_ACTION('inc');
   bis_collection_utilities.log('Populate INC table '|| 'Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
   l_glob_date := '''' || To_char(bis_common_parameters.get_global_start_date, 'YYYY/MM/DD HH24:MI:SS') || '''';
   d_glob_date := bis_common_parameters.get_global_start_date;

   if (g_init) then
     insert /*+ append  parallel(poa_dbi_rtx_inc) */ into
     poa_dbi_rtx_inc
     (
       primary_key,
       global_cur_conv_rate,
       batch_id,
       txn_cur_code,
       func_cur_code,
       rate_date,
       source_document_code
     )
     select /*+ parallel(rcv) parallel(poh) */
     rcv.transaction_id primary_key,
     null global_cur_conv_rate,
     1 batch_id,
     poh.currency_code txn_cur_code,
     poa_gl.currency_code func_cur_code,
     trunc(nvl(rcv.currency_conversion_date, rcv.transaction_date)) rate_date,
     rcv.source_document_code source_document_code
     from rcv_transactions rcv,
     po_headers_all poh,
     financials_system_params_all fsp,
     gl_sets_of_books poa_gl
     where ( rcv.last_update_date between d_start_date and d_end_date or
             poh.last_update_date between d_start_date and d_end_date
           )
     and rcv.po_header_id = poh.po_header_id (+)
     and poh.org_id = fsp.org_id (+)
     and fsp.set_of_books_id = poa_gl.set_of_books_id (+)
   --and rcv.transaction_type in ('RECEIVE','MATCH','CORRECT', 'REJECT', 'ACCEPT', 'RETURN TO VENDOR', 'DELIVER', 'TRANSFER')
     and rcv.creation_date >= d_glob_date;

    ELSE -- not initial load

      insert /*+ append */ into
      poa_dbi_rtx_inc
      (
        primary_key,
        global_cur_conv_rate,
        batch_id,
        txn_cur_code,
        func_cur_code,
        rate_date,
	source_document_code
      )
          select /*+ cardinality(rcv, 1)*/
          rcv.transaction_id primary_key,
	  null global_cur_conv_rate,
          ceil(rownum/l_batch_size) batch_id,
          poh.currency_code txn_cur_code,
          poa_gl.currency_code func_cur_code,
          trunc(nvl(rcv.currency_conversion_date, rcv.transaction_date)) rate_date,
	  rcv.source_document_code source_document_code
          from rcv_transactions rcv,
          po_headers_all poh,
          financials_system_params_all fsp,
          gl_sets_of_books poa_gl
          where rcv.last_update_date between d_start_date and d_end_date
          and rcv.po_header_id                = poh.po_header_id (+)
          and poh.org_id = fsp.org_id (+)
          and fsp.set_of_books_id = poa_gl.set_of_books_id (+)
          and rcv.creation_date >= d_glob_date
       --   and rcv.transaction_type in ('RECEIVE','MATCH','CORRECT','REJECT','ACCEPT','RETURN TO VENDOR',  'DELIVER', 'TRANSFER')
UNION
          select /*+ cardinality(poh, 1)*/
          rcv.transaction_id primary_key,
	  null global_cur_conv_rate,
          ceil(rownum/l_batch_size) batch_id,
          poh.currency_code txn_cur_code,
          poa_gl.currency_code func_cur_code,
          trunc(nvl(rcv.currency_conversion_date, rcv.transaction_date)) rate_date,
	  rcv.source_document_code source_document_code
          from rcv_transactions rcv,
          po_headers_all poh,
          financials_system_params_all fsp,
          gl_sets_of_books poa_gl
          where
          poh.last_update_date between d_start_date and d_end_date
          and rcv.po_header_id                = poh.po_header_id (+)
          and poh.org_id = fsp.org_id (+)
          and fsp.set_of_books_id = poa_gl.set_of_books_id (+)
          and rcv.creation_date >= d_glob_date
          ;
    END IF;

    COMMIT;

   DBMS_APPLICATION_INFO.SET_ACTION('stats incremental');

   IF (FND_INSTALLATION.GET_APP_INFO('POA', l_status, l_industry, l_poa_schema)) THEN
     FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_poa_schema,
              TABNAME => 'POA_DBI_RTX_INC') ;
   END IF;

    insert /*+ APPEND */ into
    poa_dbi_rtx_rates
    (
      txn_cur_code,
      func_cur_code,
      rate_date,
      global_cur_conv_rate,
      sglobal_cur_conv_rate
    )
    select
    txn_cur_code,
    func_cur_code,
    rate_date,
    poa_currency_pkg.get_dbi_global_rate(
      l_rate_type,
      func_cur_code,
      rate_date,
      txn_cur_code
    ) global_cur_conv_rate,
    ( case when l_sec_cur_yn = 0
      then null
      else poa_currency_pkg.get_dbi_sglobal_rate(
             l_srate_type,
             func_cur_code,
             rate_date,
             txn_cur_code
           )
      end
    ) sglobal_cur_conv_rate
    from
    ( select distinct
      txn_cur_code,
      func_cur_code,
      rate_date
      from poa_dbi_rtx_inc
      where source_document_code = 'PO'
        and txn_cur_code is not null -- added this for UNORDERED txns that have a source doc code of PO but don't have any PO reference on them
      order by func_cur_code,rate_date
    );

   commit;
   DBMS_APPLICATION_INFO.SET_ACTION('stats rates');

   IF (FND_INSTALLATION.GET_APP_INFO('POA', l_status, l_industry, l_poa_schema)) THEN
     FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_poa_schema,
              TABNAME => 'POA_DBI_RTX_RATES') ;
   END IF;

   bis_collection_utilities.log('Populate base table: '|| 'Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);

   select max(batch_id), COUNT(1) into l_no_batch, l_count from poa_dbi_rtx_inc;
   bis_collection_utilities.log('Identified '|| l_count ||' changed records. Batch size='|| l_batch_size || '. # of Batches=' || l_no_batch
				|| '. Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);

   /* missing currency handling */

   IF (poa_currency_pkg.g_missing_cur) THEN
      poa_currency_pkg.g_missing_cur := false;
      errbuf := 'There are missing currencies\n';
      RAISE_APPLICATION_ERROR (-20000, 'Error in INC table collection: ' || errbuf);
   END IF;

   l_start_time := sysdate;
   l_login := fnd_global.login_id;
   l_user := fnd_global.user_id;
   DBMS_APPLICATION_INFO.SET_ACTION('collect');

   if (l_no_batch is NOT NULL) then
      IF (g_init) THEN
	 INSERT /*+ APPEND PARALLEL(poa_dbi_rtx_f) */ INTO poa_dbi_rtx_f
	   ( transaction_id,
	     transaction_type,
	     parent_transaction_type,
	     grp_txn_date,
	     receive_txn_date,
	     supplier_id,
	     supplier_site_id,
	     creation_operating_unit_id,
	     receiving_org_id,
	     reason_id,
	     transaction_date,
	     rcv_creation_date,
	     quantity,
	     func_cur_code,
	     global_cur_conv_rate,
	     line_location_id,
	     shipment_header_id,
	     shipment_line_id,
	     asn_type,
	     receipt_num,
	     created_by,
	     last_update_login,
	     creation_date,
	     last_updated_by,
	     last_update_date,
             sglobal_cur_conv_rate,
	     source_doc_quantity,
	     receipt_exists,
	     currency_conversion_rate,
	     currency_conversion_date,
	     source_document_code,
	     shipping_control,
	     oe_order_line_id,
             requisition_line_id,
             routing_header_id,
             inventory_item_id,
             primary_quantity,
             primary_uom_code,
             wms_enabled_flag,
             wms_grp_txn_date,
	     dropship_type_code,
	     inv_transaction_id
	    )
	   (
		 select /*+ PARALLEL(val) PARALLEL(par) PARALLEL(inc) PARALLEL(f) PARALLEL(poh) PARALLEL(rsh) PARALLEL(rsl) parallel(item) parallel(poa_gl)  no_merge */
	   val.transaction_id,
	   val.transaction_type,
	   par.transaction_type parent_transaction_type,
	   (CASE WHEN (val.transaction_type<>'CORRECT') THEN val.transaction_date
	    WHEN (val.transaction_type='CORRECT' AND par.transaction_type='MATCH') THEN get_date(par.parent_transaction_id)
	    ELSE par.transaction_date END) grp_txn_date,
           (CASE WHEN (val.transaction_type='RECEIVE') THEN val.transaction_date
	    WHEN (Nvl(par.parent_transaction_id,0) <=0 ) THEN par.transaction_date
	    else get_top_date(val.transaction_id)
	    END) receive_txn_date,
	   poh.vendor_id supplier_id,
           poh.vendor_site_id supplier_site_id,
           poh.org_id creation_operating_unit_id,
           val.organization_id receiving_org_id,
           (CASE WHEN val.transaction_type = 'CORRECT' THEN par.reason_id ELSE val.reason_id END) reason_id,
           val.transaction_date transaction_date,
           val.creation_date rcv_creation_date,
	   val.quantity quantity,
           poa_gl.currency_code func_cur_code,
           rat.global_cur_conv_rate,
	   val.po_line_location_id line_location_id,
	   val.shipment_header_id,
	   val.shipment_line_id,
	   rsh.asn_type,
	   rsh.receipt_num,
	   l_user created_by,
	   l_login last_update_login,
	   l_start_time creation_date,
	   l_user last_updated_by,
	   l_start_time last_update_date,
           rat.sglobal_cur_conv_rate,
	   val.source_doc_quantity,
	   (CASE WHEN val.transaction_type IN ('MATCH', 'RECEIVE') OR val.transaction_type = 'CORRECT' AND par.transaction_type IN ('MATCH', 'RECEIVE')
	    THEN 'Y' ELSE 'N' END ) receipt_exists,
           val.currency_conversion_rate,
	   val.currency_conversion_date,
	   val.source_document_code,
	   poh.shipping_control shipping_control,
	   val.oe_order_line_id,
	   val.requisition_line_id,
           val.routing_header_id routing_header_id,
	   rsl.item_id inventory_item_id,
	   Decode(rsl.item_id, NULL, NULL, val.quantity * inv_convert.inv_um_convert(rsl.item_id, 5, 1, null, null, val.unit_of_measure, item.primary_unit_of_measure)) primary_quantity,
           item.primary_uom_code primary_uom_code,
           param.wms_enabled_flag wms_enabled_flag,
	   trunc(CASE WHEN (val.transaction_type<>'CORRECT') THEN val.transaction_date
	    ELSE par.transaction_date END) wms_grp_txn_date,
	   val.dropship_type_code,
	   val.inv_transaction_id
  from   rcv_transactions val,
         rcv_transactions par,
	 poa_dbi_rtx_inc inc,
	 PO_HEADERS_ALL               POH,
	 RCV_SHIPMENT_HEADERS         RSH,
	 RCV_SHIPMENT_LINES           rsl,
	 gl_sets_of_books             poa_gl,
	 financials_system_params_all fsp,
	 mtl_system_items             item,
	 mtl_parameters               param,
         poa_dbi_rtx_rates            rat
 where
--	 val.transaction_type IN ('RECEIVE','MATCH','CORRECT','REJECT','ACCEPT','RETURN TO VENDOR')
--	 AND val.source_document_code = 'PO'	 AND
	 inc.primary_key = val.transaction_id
	 and val.parent_transaction_id = par.transaction_id(+)
	 AND val.SHIPMENT_HEADER_ID = RSH.SHIPMENT_HEADER_ID
	 AND val.SHIPMENT_LINE_ID   = RSL.SHIPMENT_LINE_ID
	 AND val.PO_HEADER_ID = POH.PO_HEADER_ID (+)
         and inc.txn_cur_code = rat.txn_cur_code (+)
         and inc.func_cur_code = rat.func_cur_code (+)
         and inc.rate_date = rat.rate_date (+)
	 AND poh.org_id = fsp.org_id (+)
	 AND fsp.set_of_books_id = poa_gl.set_of_books_id (+)
	 AND rsl.item_id = item.inventory_item_id (+)
	 AND val.organization_id = nvl(item.organization_id,val.organization_id)
         AND val.organization_id = param.organization_id
	 );

	 COMMIT;
      else

	 FOR v_batch_no IN 1..l_no_batch LOOP
	    bis_collection_utilities.log('batch no='||v_batch_no || ' Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 1);
	    merge INTO poa_dbi_rtx_f T
	      using (
		     select /*+ cardinality(inc,1) */
		     val.transaction_id,
		     val.transaction_type,
		     par.transaction_type parent_transaction_type,
		     (CASE WHEN (val.transaction_type<>'CORRECT') THEN val.transaction_date
		      WHEN (val.transaction_type='CORRECT' AND par.transaction_type='MATCH') THEN get_date(par.parent_transaction_id)
		      ELSE par.transaction_date END) grp_txn_date,
		     (CASE WHEN (val.transaction_type='RECEIVE') THEN val.transaction_date
		      WHEN (Nvl(par.parent_transaction_id,0) <=0 ) THEN par.transaction_date
		      ELSE get_top_date(val.transaction_id)
		      END) receive_txn_date,
		     poh.vendor_id supplier_id,
		     poh.vendor_site_id supplier_site_id,
		     poh.org_id creation_operating_unit_id,
		     val.organization_id receiving_org_id,
		     (CASE WHEN val.transaction_type = 'CORRECT' THEN par.reason_id ELSE val.reason_id END) reason_id,
		     val.transaction_date transaction_date,
		     val.creation_date rcv_creation_date,
		     val.quantity quantity,
		     poa_gl.currency_code func_cur_code,
		     rat.global_cur_conv_rate,
		     val.po_line_location_id line_location_id,
		     val.shipment_header_id,
		     val.shipment_line_id,
		     rsh.asn_type,
		     rsh.receipt_num,
		     l_user created_by,
	             l_login last_update_login,
	             l_start_time creation_date,
	             l_user last_updated_by,
	             l_start_time last_update_date,
                     rat.sglobal_cur_conv_rate,
		     val.source_doc_quantity,
	             (CASE WHEN val.transaction_type IN ('MATCH', 'RECEIVE') OR val.transaction_type = 'CORRECT' AND par.transaction_type IN ('MATCH', 'RECEIVE')
	             THEN 'Y' ELSE 'N' END ) receipt_exists,
                     val.currency_conversion_rate,
	             val.currency_conversion_date,
	             val.source_document_code,
		     poh.shipping_control shipping_control,
	             val.oe_order_line_id,
	             val.requisition_line_id,
                     val.routing_header_id,
	             rsl.item_id inventory_item_id,
	             Decode(rsl.item_id, NULL, NULL, val.quantity * inv_convert.inv_um_convert(rsl.item_id, 5, 1, null, null, val.unit_of_measure, item.primary_unit_of_measure)) primary_quantity,
                     item.primary_uom_code primary_uom_code,
                     param.wms_enabled_flag wms_enabled_flag,
	             trunc(CASE WHEN (val.transaction_type<>'CORRECT') THEN val.transaction_date
	              ELSE par.transaction_date END) wms_grp_txn_date,
		      val.dropship_type_code,
		      val.inv_transaction_id
	 from           rcv_transactions val,
	                rcv_transactions par,
			poa_dbi_rtx_inc inc,
			PO_HEADERS_ALL               POH,
			RCV_SHIPMENT_HEADERS         RSH,
			RCV_SHIPMENT_LINES           rsl,
			gl_sets_of_books             poa_gl,
			financials_system_params_all fsp,
			mtl_system_items             item,
			mtl_parameters               param,
                        poa_dbi_rtx_rates            rat
	  where
			inc.primary_key = val.transaction_id
			and val.parent_transaction_id = par.transaction_id(+)
			AND val.SHIPMENT_HEADER_ID = RSH.SHIPMENT_HEADER_ID
			AND val.SHIPMENT_LINE_ID   = RSL.SHIPMENT_LINE_ID
			AND val.PO_HEADER_ID = POH.PO_HEADER_ID (+)
                        and inc.txn_cur_code = rat.txn_cur_code (+)
                        and inc.func_cur_code = rat.func_cur_code (+)
                        and inc.rate_date = rat.rate_date (+)
			AND poh.org_id = fsp.org_id (+)
			AND fsp.set_of_books_id = poa_gl.set_of_books_id (+)
		        AND rsl.item_id = item.inventory_item_id (+)
			AND val.organization_id = nvl(item.organization_id,val.organization_id)
                        AND val.organization_id = param.organization_id
			AND inc.batch_id            = v_batch_no
	     ) S
	    ON (T.transaction_id = S.transaction_id)
	      WHEN matched THEN UPDATE SET
		t.supplier_id = s.supplier_id,
		t.supplier_site_id = s.supplier_site_id,
		t.global_cur_conv_rate = s.global_cur_conv_rate,
		t.last_update_login = s.last_update_login,
		t.last_updated_by = s.last_updated_by,
		t.last_update_date = s.last_update_date,
                t.sglobal_cur_conv_rate = s.sglobal_cur_conv_rate,
		t.source_doc_quantity = s.source_doc_quantity,
	        t.receipt_exists = s.receipt_exists,
                t.currency_conversion_rate = s.currency_conversion_rate,
	        t.currency_conversion_date = s.currency_conversion_date,
	        t.source_document_code = s.source_document_code,
		t.shipping_control = s.shipping_control,
		t.quantity = s.quantity,
	        t.oe_order_line_id = s.oe_order_line_id,
	        t.requisition_line_id = s.requisition_line_id,
                t.routing_header_id = s.routing_header_id,
	        t.inventory_item_id = s.inventory_item_id,
	        t.primary_quantity = s.primary_quantity,
                t.primary_uom_code = s.primary_uom_code,
                t.wms_enabled_flag = s.wms_enabled_flag,
                t.wms_grp_txn_date = s.wms_grp_txn_date,
		t.dropship_type_code = s.dropship_type_code,
		t.inv_transaction_id = s.inv_transaction_id


	      WHEN NOT matched THEN INSERT (
					      t.transaction_id,
					      t.transaction_type,
					      t.parent_transaction_type,
					      t.grp_txn_date,
					      t.receive_txn_date,
					      t.supplier_id,
					      t.supplier_site_id,
					      t.creation_operating_unit_id,
					      t.receiving_org_id,
					      t.reason_id,
					      t.transaction_date,
					      t.rcv_creation_date,
					      t.quantity,
					      t.func_cur_code,
					      t.global_cur_conv_rate,
					      t.line_location_id,
					      t.shipment_header_id,
					      t.shipment_line_id,
					      t.asn_type,
					      t.receipt_num,
					      t.created_by,
					      t.last_update_login,
		                              t.creation_date,
		                              t.last_updated_by,
		                              t.last_update_date,
                                              t.sglobal_cur_conv_rate,
					      t.source_doc_quantity,
					      t.receipt_exists,
                                              t.currency_conversion_rate,
	                                      t.currency_conversion_date,
	                                      t.source_document_code,
					      t.shipping_control,
	                                      t.oe_order_line_id,
	                                      t.requisition_line_id,
                                              t.routing_header_id,
	                                      t.inventory_item_id,
	                                      t.primary_quantity,
			                      t.primary_uom_code,
                                              t.wms_enabled_flag,
                                              t.wms_grp_txn_date,
					      t.dropship_type_code,
					      t.inv_transaction_id

		  ) VALUES (
                            s.transaction_id,
			    s.transaction_type,
			    s.parent_transaction_type,
		            s.grp_txn_date,
		            s.receive_txn_date,
			    s.supplier_id,
			    s.supplier_site_id,
			    s.creation_operating_unit_id,
		            s.receiving_org_id,
			    s.reason_id,
			    s.transaction_date,
			    s.rcv_creation_date,
			    s.quantity,
		            s.func_cur_code,
			    s.global_cur_conv_rate,
			    s.line_location_id,
			    s.shipment_header_id,
			    s.shipment_line_id,
			    s.asn_type,
			    s.receipt_num,
			    s.created_by,
			    s.last_update_login,
		            s.creation_date,
		            s.last_updated_by,
		            s.last_update_date,
                            s.sglobal_cur_conv_rate,
			    s.source_doc_quantity,
		            s.receipt_exists,
                            s.currency_conversion_rate,
	                    s.currency_conversion_date,
	                    s.source_document_code,
			    s.shipping_control,
	                    s.oe_order_line_id,
	                    s.requisition_line_id,
                            s.routing_header_id,
	                    s.inventory_item_id,
	                    s.primary_quantity,
			    s.primary_uom_code,
                            s.wms_enabled_flag,
                            s.wms_grp_txn_date,
			    s.dropship_type_code,
			    s.inv_transaction_id
			    );

	    COMMIT;

	    DBMS_APPLICATION_INFO.SET_ACTION('batch ' || v_batch_no || ' done');
	 END LOOP;
      END IF; -- init load
   END IF; -- no data

   bis_collection_utilities.log('Collection complete '|| 'Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
   bis_collection_utilities.wrapup(TRUE, l_count, 'POA DBI RCV TXN COLLECTION SUCEEDED', To_date(l_start_date, '''YYYY/MM/DD HH24:MI:SS'''), To_date(l_end_date, '''YYYY/MM/DD HH24:MI:SS'''));
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

      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20000,'Stack Dump Follows =>', true);
END populate_rcv_txn_facts;

FUNCTION get_date (txn_id NUMBER) RETURN DATE IS
   ret DATE;
begin
   SELECT rcv.transaction_date
     INTO ret
     from rcv_transactions rcv
     where rcv.transaction_id = txn_id;
   RETURN ret;
END GET_DATE;

FUNCTION get_top_date (txn_id NUMBER) RETURN DATE IS
   ret date;
begin
   SELECT rcv.transaction_date
     INTO ret
     from rcv_transactions rcv
     where rcv.parent_transaction_id <= 0
     start with rcv.transaction_id = txn_id
     connect by prior rcv.parent_transaction_id = rcv.transaction_id;
   RETURN ret;
END GET_TOP_DATE;



END POA_DBI_RCV_TXN_F_C;

/
