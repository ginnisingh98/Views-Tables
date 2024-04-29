--------------------------------------------------------
--  DDL for Package Body ISC_DBI_WSH_FTE_OBJECTS_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_WSH_FTE_OBJECTS_C" AS
/* $Header: ISCSCF9B.pls 120.8 2006/09/13 06:41:03 abhdixi noship $ */

 g_batch_size			NUMBER;
 g_global_currency		VARCHAR2(30);
 g_global_rate_type   		VARCHAR2(80);
 g_sec_global_currency		VARCHAR2(30);
 g_sec_global_rate_type   	VARCHAR2(80);
 g_global_start_date		DATE;
 g_treasury_rate_type		VARCHAR2(80);
 g_reporting_weight_uom		VARCHAR2(30);
 g_reporting_volume_uom		VARCHAR2(30);
 g_reporting_distance_uom	VARCHAR2(30);
 g_new_arr_window		NUMBER;

 g_errbuf			VARCHAR2(2000);
 g_retcode			VARCHAR2(200);
 g_row_count         		NUMBER;
 g_push_from_date		DATE;
 g_push_to_date			DATE;
 g_incre_start_date		DATE;
 g_load_mode			VARCHAR2(30);
 g_isc_schema			VARCHAR2(50);
 g_sec_curr_def  		VARCHAR2(1);

-- =================
-- Private Functions
-- =================

-- -----------
-- CHECK_SETUP
-- -----------

FUNCTION check_setup RETURN NUMBER IS

  l_list 		dbms_sql.varchar2_table;
  l_status       	VARCHAR2(30);
  l_industry     	VARCHAR2(30);
  l_setup		NUMBER;

BEGIN

  l_list(1) := 'BIS_GLOBAL_START_DATE';
  IF (NOT bis_common_parameters.check_global_parameters(l_list)) THEN
     BIS_COLLECTION_UTILITIES.put_line(' ');
     BIS_COLLECTION_UTILITIES.put_line('Error! Collection aborted because the global start date has not been set up.');
     BIS_COLLECTION_UTILITIES.put_line(' ');
     l_setup := -999;
  END IF;

  IF (nvl(FND_PROFILE.VALUE('ISC_WSH_FTE_DBI_INSTALLED'),'N') <> 'Y') THEN
     BIS_COLLECTION_UTILITIES.put_line(' ');
     BIS_COLLECTION_UTILITIES.put_line('Error! Collection aborted because the profile option "ISC: Shipping/Transportation Execution DBI Installation" has not been set to Y.');
     BIS_COLLECTION_UTILITIES.put_line(' ');
     l_setup := -999;
  END IF;

  g_sec_curr_def := isc_dbi_currency_pkg.is_sec_curr_defined;
  IF (g_sec_curr_def = 'E') THEN
     BIS_COLLECTION_UTILITIES.put_line(' ');
     BIS_COLLECTION_UTILITIES.put_line('Error! Collection aborted because the set-up of the DBI Global Parameter "Secondary Global Currency" is incomplete. Please verify the proper set-up of the Global Currency Rate Type and the Global Currency Code.');
     BIS_COLLECTION_UTILITIES.put_line(' ');
     l_setup := -999;
  END IF;

  g_batch_size := bis_common_parameters.get_batch_size(bis_common_parameters.high);
  BIS_COLLECTION_UTILITIES.put_line('The batch size is ' || g_batch_size);

  g_global_start_date := bis_common_parameters.get_global_start_date;
  BIS_COLLECTION_UTILITIES.put_line('The global start date is ' || g_global_start_date);

  g_global_currency := bis_common_parameters.get_currency_code;
  BIS_COLLECTION_UTILITIES.put_line('The global currency code is ' || g_global_currency);

  g_global_rate_type := bis_common_parameters.get_rate_type;
  BIS_COLLECTION_UTILITIES.put_line('The primary rate type is ' || g_global_rate_type);

  g_sec_global_currency := bis_common_parameters.get_secondary_currency_code;
  BIS_COLLECTION_UTILITIES.put_line('The secondary global currency code is ' || g_sec_global_currency);

  g_sec_global_rate_type := bis_common_parameters.get_secondary_rate_type;
  BIS_COLLECTION_UTILITIES.put_line('The secondary rate type is ' || g_sec_global_rate_type);

  g_treasury_rate_type := bis_common_parameters.get_treasury_rate_type;
--  IF (g_treasury_rate_type IS NULL) THEN
--     g_errbuf := 'Collection aborted because the set-up of the DBI Global Parameter "Treasury Rate Type" is incomplete. Please verify the proper set-up of the Treasury Rate Type.';
--    return(-1);
--  END IF;
  BIS_COLLECTION_UTILITIES.put_line('The treasury rate type is ' || g_treasury_rate_type);

  BEGIN
    g_new_arr_window := FND_PROFILE.VALUE('FTE_CARRIER_ARR_WINDOW');
    IF (g_new_arr_window IS NULL) THEN
       BIS_COLLECTION_UTILITIES.put_line(' ');
       BIS_COLLECTION_UTILITIES.Put_Line('Error! Collection aborted because the profile option "FTE: Carrier On-time Arrival Window" has not been set up.');
       BIS_COLLECTION_UTILITIES.put_line(' ');
       l_setup := -999;
   ELSE
     BIS_COLLECTION_UTILITIES.Put_Line('Carrier On-time Arrival Window is ' || g_new_arr_window);
   END IF;
  EXCEPTION
    WHEN VALUE_ERROR THEN
      g_retcode := sqlcode;
      BIS_COLLECTION_UTILITIES.put_line(' ');
      BIS_COLLECTION_UTILITIES.Put_Line('Error! Collection aborted because the profile option "FTE: Carrier On-time Arrival Window" has not been set up correctly.');
      BIS_COLLECTION_UTILITIES.Put_Line('Please set up the profile option as a valid number.');
      BIS_COLLECTION_UTILITIES.put_line(' ');
      l_setup := -999;
  END;

  IF (NOT FND_INSTALLATION.GET_APP_INFO('ISC', l_status, l_industry, g_isc_schema)) THEN
     BIS_COLLECTION_UTILITIES.put_line(' ');
     BIS_COLLECTION_UTILITIES.Put_Line('Error! Collection aborted while retrieving schema information.');
     BIS_COLLECTION_UTILITIES.put_line(' ');
     l_setup := -999;
  END IF;

  IF (l_setup = -999) THEN
     g_errbuf  := 'Collection aborted because the setup has not been completed. Please refer to the log file for the details.';
     return(-1);
  END IF;

  BIS_COLLECTION_UTILITIES.put_line('Truncating the temp tables');
  FII_UTIL.Start_Timer;

  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_TMP_WDD_LOG';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_TMP_WTS_LOG';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_TMP_FIH_LOG';

  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_TMP_DEL_DETAILS';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_TMP_DEL_LEGS';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_TMP_TRIP_STOPS';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_TMP_FTE_INVOICES';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_FTE_CURR_RATES';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_FTE_UOM_RATES';

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Truncated the temp tables in');
  BIS_COLLECTION_UTILITIES.Put_Line(' ');

  RETURN(1);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in function CHECK_SETUP : '||sqlerrm;
    RETURN(-1);

END check_setup;

FUNCTION get_reporting_uom RETURN NUMBER IS

BEGIN
  g_reporting_weight_uom := opi_dbi_rep_uom_pkg.get_reporting_uom('WT');
  IF (g_reporting_weight_uom IS NULL) THEN
     g_retcode := 1;
     g_errbuf := g_errbuf || 'DBI Weight Reporting UOM has not been set up.';
     BIS_COLLECTION_UTILITIES.put_line(' ');
     BIS_COLLECTION_UTILITIES.put_line('Warning! DBI Weight Reporting UOM has not been set up.');
     BIS_COLLECTION_UTILITIES.put_line(' ');
  ELSE
     BIS_COLLECTION_UTILITIES.put_line('The reporting weight uom is ' || g_reporting_weight_uom);
  END IF;

  g_reporting_volume_uom := opi_dbi_rep_uom_pkg.get_reporting_uom('VOL');
  IF (g_reporting_volume_uom IS NULL) THEN
     g_retcode := 1;
     g_errbuf := g_errbuf || 'DBI Volume Reporting UOM has not been set up.';
     BIS_COLLECTION_UTILITIES.put_line(' ');
     BIS_COLLECTION_UTILITIES.put_line('Warning! DBI Volume Reporting UOM has not been set up.');
     BIS_COLLECTION_UTILITIES.put_line(' ');
  ELSE
     BIS_COLLECTION_UTILITIES.put_line('The reporting volume uom is ' || g_reporting_volume_uom);
  END IF;

  g_reporting_distance_uom := opi_dbi_rep_uom_pkg.get_reporting_uom('DIS');
  IF (g_reporting_distance_uom IS NULL) THEN
     g_retcode := 1;
     g_errbuf := g_errbuf || 'DBI Distance Reporting UOM has not been set up.';
     BIS_COLLECTION_UTILITIES.put_line(' ');
     BIS_COLLECTION_UTILITIES.put_line('Warning! DBI Distance Reporting UOM has not been set up.');
     BIS_COLLECTION_UTILITIES.put_line(' ');
  ELSE
     BIS_COLLECTION_UTILITIES.put_line('The reporting distance uom is ' || g_reporting_distance_uom);
  END IF;

  RETURN(1);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in function CHECK_SETUP : '||sqlerrm;
    RETURN(-1);
END get_reporting_uom;


FUNCTION update_parameter_table RETURN NUMBER IS

  l_old_arr_window	NUMBER;

BEGIN

  BEGIN
    SELECT on_time_window INTO l_old_arr_window FROM isc_dbi_fte_parameters;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       BIS_COLLECTION_UTILITIES.Put_Line('Inserting data into isc_dbi_fte_parameters.');
       INSERT INTO isc_dbi_fte_parameters (ON_TIME_WINDOW, LAST_UPDATE_DATE) VALUES (g_new_arr_window, sysdate);
       l_old_arr_window := g_new_arr_window;
  END;

  IF (l_old_arr_window IS NULL or g_new_arr_window <> l_old_arr_window) THEN
     g_retcode := 1;
     g_errbuf := 'The profile option "FTE: Carrier On-time Arrival Window" has been changed since last collection.';
     BIS_COLLECTION_UTILITIES.Put_Line(' ');
     BIS_COLLECTION_UTILITIES.Put_Line('Warning! Profile option "FTE: Carrier On-time Arrival Window" has been changed since last collection.');
     BIS_COLLECTION_UTILITIES.Put_Line('The new setting will affect current and future data, but not past data.');
     BIS_COLLECTION_UTILITIES.Put_Line('Depending on your implementation');
     BIS_COLLECTION_UTILITIES.Put_Line('- No action is required if past data should be preserved in the context of the previous profile option setting.');
     BIS_COLLECTION_UTILITIES.Put_Line('- If past data should be updated with the latest setting, an initial load is required to be executed.');
     BIS_COLLECTION_UTILITIES.Put_Line(' ');
     BIS_COLLECTION_UTILITIES.Put_Line('Carrier On-time Arrival Window was ' || l_old_arr_window || ' as last collection.');
     BIS_COLLECTION_UTILITIES.Put_Line('Carrier On-time Arrival Window is set to ' || g_new_arr_window || ' now.');
     UPDATE isc_dbi_fte_parameters SET on_time_window = g_new_arr_window, last_update_date = sysdate;
  END IF;

  RETURN(1);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in function UPDATE_PARAMETER_TABLE : '||sqlerrm;
    RETURN(-1);

END update_parameter_table;

FUNCTION SET_WMS_PTS_GSD RETURN NUMBER IS

  l_overwrite	BOOLEAN;

BEGIN

  l_overwrite := FALSE;

  BIS_COLLECTION_UTILITIES.Put_Line('Setting the 11.5.10 CU1 date for WMS page.');
  OPI_DBI_WMS_UTILITY_PKG.Set_Wms_Pts_Gsd(l_overwrite);

  RETURN(1);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in function SET_WMS_PTS_GSD : '||sqlerrm;
    RETURN(-1);

END set_wms_pts_gsd;

      -- --------------------
      -- IDENTIFY_CHANGE_INIT
      -- --------------------

FUNCTION IDENTIFY_CHANGE_INIT RETURN NUMBER IS

  l_detail_count 	NUMBER;
  l_leg_count 		NUMBER;
  l_stop_count 		NUMBER;
  l_invoice_count 	NUMBER;
  l_total		NUMBER;
--  l_stmt		VARCHAR2(8000);
--  l_from_date		VARCHAR2(30);
--  l_to_date		VARCHAR2(30);

BEGIN

  l_detail_count := 0;
  l_leg_count := 0;
  l_stop_count := 0;
  l_invoice_count := 0;
  l_total := 0;

--  l_from_date := to_char(g_push_from_date,'MM/DD/YYYY HH24:MI:SS');
--  l_to_date   := to_char(g_push_to_date,'MM/DD/YYYY HH24:MI:SS');

 BIS_COLLECTION_UTILITIES.put_line('Identifying delivery details');
 FII_UTIL.Start_Timer;

  INSERT /*+ APPEND PARALLEL(F) */ INTO isc_dbi_tmp_del_details F (
         DELIVERY_DETAIL_ID,
         INVENTORY_ITEM_ID,
         ORGANIZATION_ID,
         SHIPMENT_DIRECTION,
         SUBINVENTORY_CODE,
         TIME_IP_DATE_ID,
         TIME_PR_DATE_ID,
         DELIVERY_ID,
         INITIAL_PICKUP_DATE,
         MOVE_ORDER_LINE_ID,
         PICK_RELEASED_DATE,
         RELEASED_STATUS,
         REQUESTED_QUANTITY,
         REQUESTED_QUANTITY_UOM,
         SHIPPED_QUANTITY,
         WMS_ENABLED_FLAG)
  SELECT /*+ USE_HASH(wnd,wda,wdd,mol,mmt,mp) PARALLEL(wnd) PARALLEL(wda) PARALLEL(wdd) PARALLEL(mol) PARALLEL(mmt) PARALLEL(mp) */
         wdd.delivery_detail_id				DELIVERY_DETAIL_ID,
         wdd.inventory_item_id				INVENTORY_ITEM_ID,
         nvl(wnd.organization_id, wdd.organization_id)	ORGANIZATION_ID,
         nvl(wnd.shipment_direction, 'O')		SHIPMENT_DIRECTION,
         mmt.subinventory_code				SUBINVENTORY_CODE,
         trunc(wnd.initial_pickup_date)			TIME_IP_DATE_ID,
         trunc(mol.creation_date) 			TIME_PR_DATE_ID,
         wnd.delivery_id				DELIVERY_ID,
         wnd.initial_pickup_date			INITIAL_PICKUP_DATE,
         wdd.move_order_line_id				MOVE_ORDER_LINE_ID,
         mol.creation_date				PICK_RELEASED_DATE,
         wdd.released_status				RELEASED_STATUS,
         wdd.requested_quantity				REQUESTED_QUANTITY,
         wdd.requested_quantity_uom			REQUESTED_QUANTITY_UOM,
         wdd.shipped_quantity				SHIPPED_QUANTITY,
         mp.wms_enabled_flag				WMS_ENABLED_FLAG
    FROM wsh_delivery_details		wdd,
         wsh_delivery_assignments	wda,
         wsh_new_deliveries		wnd,
         mtl_txn_request_lines		mol,
         mtl_material_transactions      mmt,
         mtl_parameters			mp
   WHERE wdd.released_status in ('S','Y','C','L','P')
     AND wdd.delivery_detail_id = wda.delivery_detail_id
     AND nvl(wda.type,'S') in ('S','O')
     AND nvl(wdd.container_flag,'N') = 'N'
     AND wda.delivery_id = wnd.delivery_id (+)
     AND wdd.move_order_line_id = mol.line_id (+)
     AND wdd.transaction_id = mmt.transaction_id (+)
     AND nvl(mmt.transaction_source_type_id,2) IN (2,8)
     AND nvl(mmt.transaction_action_id,28) = 28
     AND nvl(mmt.transaction_quantity,-1) < 0
     AND wdd.organization_id = mp.organization_id
     AND nvl((CASE WHEN wdd.released_status in ('C', 'L', 'P') THEN wnd.initial_pickup_date ELSE null END), g_global_start_date) >= g_global_start_date;

  l_detail_count := sql%rowcount;
 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Identified ' || l_detail_count || ' delivery details in');
 COMMIT;

 BIS_COLLECTION_UTILITIES.put_line('Identifying trip stops');
 FII_UTIL.Start_Timer;

  INSERT /*+ APPEND PARALLEL(tmp) */ INTO isc_dbi_tmp_trip_stops tmp (
         STOP_ID,
         CARRIER_ID,
         MODE_OF_TRANSPORT,
         SERVICE_LEVEL,
         TIME_ACTL_ARRL_DATE_ID,
         TIME_INIT_DEPT_DATE_ID,
         TIME_PLN_ARRL_DATE_ID,
         ACTUAL_ARRIVAL_DATE,
         ACTUAL_DEPARTURE_DATE,
         DISTANCE_TO_NEXT_STOP_TRX,
         DISTANCE_UOM_CODE,
         PLANNED_ARRIVAL_DATE,
         STOP_RANK,
         STOP_SEQUENCE_NUMBER,
         TRIP_ID,
         ULTIMATE_STOP_SEQUENCE_NUMBER)
  SELECT /*+ USE_HASH(idl,wt,wts) PARALLEL(idl) PARALLEL(wt) PARALLEL(wts) */
         wts.stop_id								 STOP_ID,
         nvl(wt.carrier_id, -1)							 CARRIER_ID,
         nvl(wt.mode_of_transport, -1)						 MODE_OF_TRANSPORT,
         nvl(wt.service_level, -1)						 SERVICE_LEVEL,
         trunc(wts.actual_arrival_date)						 TIME_ACTL_ARRL_DATE_ID,
         trunc(min(wts.actual_departure_date) over (partition by wt.trip_id))	 TIME_INIT_DEPT_DATE_ID,
         trunc(wts.planned_arrival_date)					 TIME_PLN_ARRL_DATE_ID,
         wts.actual_arrival_date						 ACTUAL_ARRIVAL_DATE,
         wts.actual_departure_date						 ACTUAL_DEPARTURE_DATE,
         wts.distance_to_next_stop 						 DISTANCE_TO_NEXT_STOP_TRX,
         wts.distance_uom							 DISTANCE_UOM_CODE,
         wts.planned_arrival_date					  	 PLANNED_ARRIVAL_DATE,
         rank() over (partition by wt.trip_id order by wts.stop_sequence_number) STOP_RANK,
         wts.stop_sequence_number						 STOP_SEQUENCE_NUMBER,
         wt.trip_id								 TRIP_ID,
         max(wts.stop_sequence_number) over (partition by wt.trip_id)		 ULTIMATE_STOP_SEQUENCE_NUMBER
    FROM (select /*+ PARALLEL(wts_tmp) */ distinct trip_id
  	  from wsh_trip_stops wts_tmp where actual_departure_date > g_global_start_date) idl,
         wsh_trips wt,
         wsh_trip_stops wts
   WHERE idl.trip_id = wt.trip_id
     AND wt.trip_id = wts.trip_id
     AND wt.status_code IN ('IT', 'CL')
     AND wts.physical_stop_id IS NULL
     AND wts.stop_sequence_number <> -99;

  l_stop_count := sql%rowcount;
  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Identified ' || l_stop_count || ' trip stops in');
  COMMIT;

 BIS_COLLECTION_UTILITIES.put_line('Identifying delivery legs');
 FII_UTIL.Start_Timer;

INSERT /*+ APPEND PARALLEL(tmp) */ INTO isc_dbi_tmp_del_legs tmp (
       DELIVERY_LEG_ID,
       CARRIER_ID,
       SHIPMENT_DIRECTION,
       MODE_OF_TRANSPORT,
       ORGANIZATION_ID,
       SERVICE_LEVEL,
       TIME_INIT_DEPT_DATE_ID,
       CONVERSION_DATE,
       CONVERSION_RATE,
       CONVERSION_TYPE_CODE,
       DELIVERY_ID,
       DROP_OFF_STOP_ID,
       FREIGHT_COST_TRX,
       FREIGHT_VOLUME_TRX,
       FREIGHT_WEIGHT_TRX,
       PICK_UP_STOP_ID,
       TRIP_ID,
       TRX_CURRENCY_CODE,
       VOLUME_UOM_CODE,
       WEIGHT_UOM_CODE,
       WH_CURRENCY_CODE,
       DELIVERY_TYPE,
       PARENT_DELIVERY_LEG_ID)
SELECT /*+ USE_HASH(wnd,wdl,its,ifc,hoi,gsb) PARALLEL(wnd) PARALLEL(wdl) PARALLEL(its) PARALLEL(wfc) PARALLEL(wfct) PARALLEL(hoi) PARALLEL(gsb) */
       wdl.delivery_leg_id					 DELIVERY_LEG_ID,
       its.carrier_id						 CARRIER_ID,
       nvl(wnd.shipment_direction, 'O')				 SHIPMENT_DIRECTION,
       its.mode_of_transport					 MODE_OF_TRANSPORT,
       wnd.organization_id					 ORGANIZATION_ID,
       its.service_level					 SERVICE_LEVEL,
       its.time_init_dept_date_id				 TIME_INIT_DEPT_DATE_ID,
       decode(upper(ifc.conversion_type_code),
              'USER',ifc.conversion_date,
	      its.time_init_dept_date_id)		 	 CONVERSION_DATE,
       decode(upper(ifc.conversion_type_code),
              'USER', ifc.conversion_rate, null)		 CONVERSION_RATE,
       nvl(ifc.conversion_type_code, nvl(g_treasury_rate_type, g_global_rate_type))	 CONVERSION_TYPE_CODE,
       wdl.delivery_id						 DELIVERY_ID,
       wdl.drop_off_stop_id					 DROP_OFF_STOP_ID,
       ifc.total_amount						 FREIGHT_COST_TRX,
       decode(wdl.parent_delivery_leg_id,null, wnd.volume,decode(delivery_type,'CONSOLIDATION',wnd.volume,0)) FREIGHT_VOLUME_TRX,
       decode(wdl.parent_delivery_leg_id,null, wnd.gross_weight,decode(delivery_type,'CONSOLIDATION',wnd.gross_weight,0)) FREIGHT_WEIGHT_TRX,
       wdl.pick_up_stop_id					 PICK_UP_STOP_ID,
       its.trip_id						 TRIP_ID,
       ifc.currency_code					 TRX_CURRENCY_CODE,
       wnd.volume_uom_code					 VOLUME_UOM_CODE,
       wnd.weight_uom_code					 WEIGHT_UOM_CODE,
       gsb.currency_code					 WH_CURRENCY_CODE,
       wnd.delivery_type                                         DELIVERY_TYPE,
       wdl.parent_delivery_leg_id                                PARENT_DELIVERY_LEG_ID
  FROM wsh_new_deliveries wnd,
       wsh_delivery_legs wdl,
       (select  /*+ PARALLEL(wfc) */
               wfc.delivery_leg_id, total_amount, wfc.currency_code, conversion_type_code, conversion_rate, conversion_date
          from wsh_freight_costs wfc,wsh_freight_cost_types wfct,
           wsh_new_deliveries wnd, wsh_delivery_legs wdl
         where wfc.delivery_detail_id IS NULL
           AND wfc.freight_cost_type_id = wfct.freight_cost_type_id
           AND wnd.delivery_id = wdl.delivery_id
           AND wdl.delivery_leg_id = wfc.delivery_leg_id
           AND (wdl.parent_delivery_leg_id is null
              OR wnd.delivery_type = 'CONSOLIDATION')
           AND wfct.name = 'SUMMARY'
           AND wfct.freight_cost_type_code = 'FTESUMMARY') ifc,
       isc_dbi_tmp_trip_stops its,
       hr_organization_information hoi,
       gl_sets_of_books gsb
 WHERE wdl.delivery_id = wnd.delivery_id
      AND wnd.initial_pickup_date >= g_global_start_date
   AND nvl(wnd.shipping_control, 'NA') <> 'SUPPLIER'
   AND wdl.pick_up_stop_id = its.stop_id
   AND wdl.delivery_leg_id = ifc.delivery_leg_id(+)
   AND hoi.org_information_context ='Accounting Information'
   AND hoi.organization_id = wnd.organization_id
   AND hoi.org_information1 = to_char(gsb.set_of_books_id);

  l_leg_count := sql%rowcount;
  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Identified ' || l_leg_count || ' delivery legs in');
  COMMIT;

  FII_UTIL.Start_Timer;

INSERT /*+ APPEND PARALLEL(tmp) */ INTO isc_dbi_tmp_fte_invoices tmp (
       INVOICE_HEADER_ID,
       CARRIER_ID,
       MODE_OF_TRANSPORT,
       ORG_ID,
       SERVICE_LEVEL,
       SUPPLIER_ID,
       APPROVED_AMT_TRX,
       BILL_AMT_TRX,
       BILL_NUMBER,
       BILL_STATUS,
       BILL_TYPE,
       BOL,
       CONVERSION_DATE,
       CONVERSION_TYPE_CODE,
       DELIVERY_LEG_ID,
       TRIP_ID,
       TRX_CURRENCY_CODE,
       WH_CURRENCY_CODE)
SELECT /*+ USE_HASH(idl,wdi,fih,aspa,gsb) PARALLEL(idl) PARALLEL(wdi) PARALLEL(fih) PARALLEL(aspa) PARALLEL(gsb) */
       fih.invoice_header_id		INVOICE_HEADER_ID,
       idl.carrier_id			CARRIER_ID,
       idl.mode_of_transport		MODE_OF_TRANSPORT,
       fih.org_id		        ORG_ID,
       idl.service_level		SERVICE_LEVEL,
       fih.supplier_id			SUPPLIER_ID,
       fih.approved_amount		APPROVED_AMT_TRX,
       fih.total_amount			BILL_AMT_TRX,
       fih.bill_number			BILL_NUMBER,
       fih.bill_status			BILL_STATUS,
       fih.bill_type			BILL_TYPE,
       fih.bol				BOL,
       idl.time_init_dept_date_id   	CONVERSION_DATE,
       nvl(g_treasury_rate_type, g_global_rate_type) CONVERSION_TYPE_CODE,
       idl.delivery_leg_id		DELIVERY_LEG_ID,
       idl.trip_id			TRIP_ID,
       fih.currency_code		TRX_CURRENCY_CODE,
       gsb.currency_code		WH_CURRENCY_CODE
  FROM fte_invoice_headers fih,
       wsh_document_instances wdi,
       isc_dbi_tmp_del_legs idl,
       ar_system_parameters_all aspa,
       gl_sets_of_books gsb
 WHERE fih.mode_of_transport = 'LTL'
   AND fih.bill_status in ('APPROVED', 'IN_PROGRESS', 'PAID', 'PARTIALLY PAID', 'PARTIAL_PAID')
   AND fih.bol = wdi.sequence_number
   AND wdi.entity_name = 'WSH_DELIVERY_LEGS'
   AND wdi.document_type = 'BOL'
   AND wdi.entity_id = idl.delivery_leg_id
   AND fih.org_id = aspa.org_id
   AND aspa.set_of_books_id = gsb.set_of_books_id
   AND idl.mode_of_transport = 'LTL'
 UNION ALL
SELECT /*+ USE_HASH(itr,wdi,fih,aspa,gsb) PARALLEL(itr) PARALLEL(wdi) PARALLEL(fih) PARALLEL(aspa) PARALLEL(gsb) */
       fih.invoice_header_id		INVOICE_HEADER_ID,
       itr.carrier_id			CARRIER_ID,
       itr.mode_of_transport		MODE_OF_TRANSPORT,
       fih.org_id	   	        ORG_ID,
       itr.service_level		SERVICE_LEVEL,
       fih.supplier_id			SUPPLIER_ID,
       fih.approved_amount		APPROVED_AMT_TRX,
       fih.total_amount			BILL_AMT_TRX,
       fih.bill_number			BILL_NUMBER,
       fih.bill_status			BILL_STATUS,
       fih.bill_type			BILL_TYPE,
       fih.bol				BOL,
       itr.time_init_dept_date_id	CONVERSION_DATE,
       nvl(g_treasury_rate_type, g_global_rate_type)	CONVERSION_TYPE_CODE,
       null		                DELIVERY_LEG_ID,
       itr.trip_id			TRIP_ID,
       fih.currency_code		TRX_CURRENCY_CODE,
       gsb.currency_code		WH_CURRENCY_CODE
  FROM fte_invoice_headers fih,
       wsh_document_instances wdi,
       isc_dbi_tmp_trip_stops itr,
       ar_system_parameters_all aspa,
       gl_sets_of_books gsb
 WHERE fih.mode_of_transport = 'TL'
   AND fih.bill_status in ('APPROVED', 'IN_PROGRESS', 'PAID', 'PARTIALLY PAID', 'PARTIAL_PAID')
   AND fih.bol = wdi.sequence_number
   AND wdi.entity_name = 'WSH_TRIPS'
   AND wdi.document_type = 'MBOL'
   AND wdi.entity_id = itr.trip_id
   AND itr.stop_rank = 1
   AND fih.org_id = aspa.org_id
   AND aspa.set_of_books_id = gsb.set_of_books_id;

  l_invoice_count := sql%rowcount;
  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Identified ' || l_invoice_count || ' invoice headers in');
  COMMIT;

  FII_UTIL.Start_Timer;

  IF g_reporting_weight_uom IS NOT NULL THEN
     INSERT INTO isc_dbi_fte_uom_rates (MEASURE_CODE, FROM_UOM_CODE, TO_UOM_CODE, INVENTORY_ITEM_ID, CONVERSION_RATE)
     SELECT 'WT', from_uom, g_reporting_weight_uom, NULL inventory_item_id,
            decode(from_uom, g_reporting_weight_uom, 1, opi_dbi_rep_uom_pkg.uom_convert(NULL, NULL, 1, from_uom, g_reporting_weight_uom))
       FROM (SELECT /*+ PARALLEL(tmp1) */ DISTINCT weight_uom_code FROM_UOM
               FROM isc_dbi_tmp_del_legs tmp1
              WHERE weight_uom_code is not null);
  END IF;

  IF g_reporting_volume_uom IS NOT NULL THEN
     INSERT INTO isc_dbi_fte_uom_rates (MEASURE_CODE, FROM_UOM_CODE, TO_UOM_CODE, INVENTORY_ITEM_ID, CONVERSION_RATE)
     SELECT 'VOL', from_uom, g_reporting_volume_uom, NULL inventory_item_id,
            decode(from_uom, g_reporting_volume_uom, 1, opi_dbi_rep_uom_pkg.uom_convert(NULL, NULL, 1, from_uom, g_reporting_volume_uom))
       FROM (SELECT /*+ PARALLEL(tmp2) */ DISTINCT volume_uom_code FROM_UOM
               FROM isc_dbi_tmp_del_legs tmp2
              WHERE volume_uom_code is not null);
  END IF;

  IF g_reporting_distance_uom IS NOT NULL THEN
     INSERT INTO isc_dbi_fte_uom_rates (MEASURE_CODE, FROM_UOM_CODE, TO_UOM_CODE, INVENTORY_ITEM_ID, CONVERSION_RATE)
     SELECT 'DIS', from_uom, g_reporting_distance_uom, NULL inventory_item_id,
            decode(from_uom,g_reporting_distance_uom,1,opi_dbi_rep_uom_pkg.uom_convert(NULL, NULL, 1, from_uom, g_reporting_distance_uom))
       FROM (SELECT /*+ PARALLEL(tmp3) */ DISTINCT distance_uom_code FROM_UOM
               FROM isc_dbi_tmp_trip_stops tmp3
              where distance_uom_code is not null);
  END IF;

--  INSERT INTO isc_dbi_fte_uom_rates (FROM_UOM_CODE, TO_UOM_CODE, INVENTORY_ITEM_ID, CONVERSION_RATE)
--  SELECT from_uom, to_uom, NULL inventory_item_id,
--         decode(from_uom, to_uom, 1, opi_dbi_rep_uom_pkg.uom_convert(NULL, NULL, 1, from_uom, to_uom))
--    FROM (SELECT /*+ PARALLEL(tmp1) */ DISTINCT weight_uom_code FROM_UOM, 'WT' TO_UOM
--            FROM isc_dbi_tmp_del_legs tmp1
--           WHERE weight_uom_code is not null
--           UNION
--          SELECT /*+ PARALLEL(tmp2) */ DISTINCT volume_uom_code FROM_UOM, 'VOL' TO_UOM
--            FROM isc_dbi_tmp_del_legs tmp2
--           WHERE volume_uom_code is not null
--           UNION
--          SELECT /*+ PARALLEL(tmp3) */ DISTINCT distance_uom_code, 'DIS' TO_UOM
--            FROM isc_dbi_tmp_trip_stops tmp3
--           where distance_uom_code is not null);

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Retrieved '||sql%rowcount||' uom rates in');
  COMMIT;

  FII_UTIL.Start_Timer;

  INSERT /*+ APPEND */ INTO  isc_dbi_fte_curr_rates
              (TRX_CURRENCY_CODE, WH_CURRENCY_CODE, CONVERSION_DATE, CONVERSION_TYPE_CODE, TRX_WH_RATE, WH_PRIM_RATE, WH_SEC_RATE)
  SELECT trx_currency_code, wh_currency_code, conversion_date, conversion_type_code,
         decode(trx_currency_code, wh_currency_code, 1,
                fii_currency.get_rate(trx_currency_code, wh_currency_code, conversion_date, conversion_type_code)) TRX_WH_RATE,
         decode(g_global_currency, trx_currency_code, 1, wh_currency_code, 1,
                fii_currency.get_global_rate_primary(wh_currency_code, conversion_date)) 				WH_PRIM_RATE,
         decode(g_sec_global_currency, trx_currency_code, 1, wh_currency_code, 1,
                fii_currency.get_global_rate_secondary(wh_currency_code, conversion_date)) 			WH_SEC_RATE
    FROM (SELECT /*+ PARALLEL(idl) */
                 distinct trx_currency_code, wh_currency_code, conversion_date CONVERSION_DATE, conversion_type_code CONVERSION_TYPE_CODE
            FROM isc_dbi_tmp_del_legs idl
           WHERE idl.freight_cost_trx is not null
           UNION
          SELECT /*+ PARALLEL(ifi) */
		 distinct trx_currency_code, wh_currency_code, conversion_date, conversion_type_code CONVERSION_TYPE_CODE
            FROM isc_dbi_tmp_fte_invoices ifi);

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Retrieved '||sql%rowcount||' currency rates in');
  COMMIT;

  l_total := l_detail_count + l_leg_count + l_stop_count + l_invoice_count;
  RETURN(l_total);

  EXCEPTION
   WHEN OTHERS THEN
    g_errbuf  := 'Error in Function IDENTIFY_CHANGE_INIT : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
 END;

      -- --------------------
      -- IDENTIFY_CHANGE_ICRL
      -- --------------------

FUNCTION IDENTIFY_CHANGE_DETAIL_ICRL RETURN NUMBER IS

  l_total		NUMBER;

BEGIN

  l_total := 0;

  FII_UTIL.Start_Timer;

  INSERT INTO isc_dbi_tmp_wdd_log (DELIVERY_DETAIL_ID, LOG_ROWID, DML_TYPE, LAST_UPDATE_DATE)
  SELECT delivery_detail_id, rowid LOG_ROWID, dml_type, last_update_date
    FROM isc_dbi_wdd_change_log;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Inserted '|| sql%rowcount || ' rows into ISC_DBI_TMP_WDD_LOG');

  COMMIT;

  FND_STATS.GATHER_TABLE_STATS(OWNNAME => g_isc_schema,
 			       TABNAME => 'ISC_DBI_TMP_WDD_LOG');

  BIS_COLLECTION_UTILITIES.put_line('Deleting obsolete records from the base summary');
  FII_UTIL.Start_Timer;

  DELETE FROM isc_dbi_del_details_f
   WHERE delivery_detail_id IN (SELECT DISTINCT log.delivery_detail_id
                                  FROM isc_dbi_tmp_wdd_log log
                                 WHERE NOT EXISTS (select '1' from wsh_delivery_details wdd
                                                    where wdd.delivery_detail_id = log.delivery_detail_id
                                                      and wdd.released_status in ('S','Y','C','L','P')));

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Deleted '||sql%rowcount||' delivery details from base summary in');
  COMMIT;

  FII_UTIL.Start_Timer;

  INSERT INTO isc_dbi_tmp_del_details F (
         DELIVERY_DETAIL_ID,
         INVENTORY_ITEM_ID,
         ORGANIZATION_ID,
         SHIPMENT_DIRECTION,
         SUBINVENTORY_CODE,
         TIME_IP_DATE_ID,
         TIME_PR_DATE_ID,
         DELIVERY_ID,
         INITIAL_PICKUP_DATE,
         MOVE_ORDER_LINE_ID,
         PICK_RELEASED_DATE,
         RELEASED_STATUS,
         REQUESTED_QUANTITY,
         REQUESTED_QUANTITY_UOM,
         SHIPPED_QUANTITY,
         WMS_ENABLED_FLAG)
  SELECT /*+ leading(log) use_nl(mp) */
         wdd.delivery_detail_id				DELIVERY_DETAIL_ID,
         wdd.inventory_item_id				INVENTORY_ITEM_ID,
         nvl(wnd.organization_id, wdd.organization_id)	ORGANIZATION_ID,
         nvl(wnd.shipment_direction, 'O')		SHIPMENT_DIRECTION,
         mmt.subinventory_code				SUBINVENTORY_CODE,
         trunc(wnd.initial_pickup_date)			TIME_IP_DATE_ID,
         trunc(mol.creation_date) 			TIME_PR_DATE_ID,
         wnd.delivery_id				DELIVERY_ID,
         wnd.initial_pickup_date			INITIAL_PICKUP_DATE,
         wdd.move_order_line_id				MOVE_ORDER_LINE_ID,
         mol.creation_date				PICK_RELEASED_DATE,
         wdd.released_status				RELEASED_STATUS,
         wdd.requested_quantity				REQUESTED_QUANTITY,
         wdd.requested_quantity_uom			REQUESTED_QUANTITY_UOM,
         wdd.shipped_quantity				SHIPPED_QUANTITY,
         mp.wms_enabled_flag				WMS_ENABLED_FLAG
    FROM (select distinct delivery_detail_id from isc_dbi_tmp_wdd_log) log,
         wsh_delivery_details		wdd,
         wsh_delivery_assignments	wda,
         wsh_new_deliveries		wnd,
         mtl_txn_request_lines		mol,
         mtl_material_transactions      mmt,
         mtl_parameters			mp
   WHERE wdd.delivery_detail_id = log.delivery_detail_id
     AND wdd.released_status in ('S','Y','C','L','P')
     AND wdd.delivery_detail_id = wda.delivery_detail_id
     AND nvl(wda.type,'S') in ('S','O')
     AND nvl(wdd.container_flag,'N') = 'N'
     AND wda.delivery_id = wnd.delivery_id (+)
     AND wdd.move_order_line_id = mol.line_id (+)
     AND wdd.transaction_id = mmt.transaction_id (+)
     AND nvl(mmt.transaction_source_type_id,2) IN (2,8)
     AND nvl(mmt.transaction_action_id,28) = 28
     AND nvl(mmt.transaction_quantity,-1) < 0
     AND wdd.organization_id = mp.organization_id
     AND nvl((CASE WHEN wdd.released_status in ('C', 'L', 'P') THEN wnd.initial_pickup_date ELSE null END), g_global_start_date) >= g_global_start_date;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Identified '|| sql%rowcount || ' delivery details in');
  COMMIT;

  FII_UTIL.Start_Timer;

  UPDATE isc_dbi_tmp_del_details SET batch_id = ceil(rownum/g_batch_size);
  l_total := sql%rowcount;
  COMMIT;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Updated the batch id for '|| l_total || ' rows in');

  RETURN(l_total);

  EXCEPTION
   WHEN OTHERS THEN
    g_errbuf  := 'Error in Function IDENTIFY_CHANGE_DETAIL_ICRL : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
 END identify_change_detail_icrl;

FUNCTION IDENTIFY_CHANGE_STOP_LEG_ICRL RETURN NUMBER IS

  l_total		NUMBER;

 BEGIN

  l_total := 0;

 FII_UTIL.Start_Timer;

  INSERT INTO isc_dbi_tmp_wts_log (STOP_ID, LOG_ROWID, DML_TYPE, LAST_UPDATE_DATE)
  SELECT stop_id, rowid LOG_ROWID, dml_type, last_update_date
    FROM isc_dbi_wts_change_log;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Inserted '|| sql%rowcount || ' rows into ISC_DBI_TMP_WTS_LOG');

  COMMIT;

 FND_STATS.GATHER_TABLE_STATS(OWNNAME => g_isc_schema,
			      TABNAME => 'ISC_DBI_TMP_WTS_LOG');

 BIS_COLLECTION_UTILITIES.put_line('Deleting obsolete records from the base summary');
 FII_UTIL.Start_Timer;

  DELETE /*+ index(a, ISC_DBI_DEL_LEGS_F_U1) */ FROM isc_dbi_del_legs_f a
   WHERE delivery_leg_id IN (SELECT /*+ index(idl,ISC_DBI_DEL_LEGS_F_U1) use_nl( log,  idl)*/ idl.delivery_leg_id
                               FROM isc_dbi_tmp_wts_log log,
                                    isc_dbi_del_legs_f idl
                              WHERE (log.stop_id = idl.pick_up_stop_id or log.stop_id = idl.drop_off_stop_id)
                                AND NOT EXISTS (select '1' from wsh_delivery_legs wdl where wdl.delivery_leg_id = idl.delivery_leg_id));

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Deleted '||sql%rowcount||' delivery legs from base summary in');
 COMMIT;

 FII_UTIL.Start_Timer;

--  DELETE FROM isc_dbi_trip_stops_f
--   WHERE stop_id IN (SELECT DISTINCT wts.stop_id
--                       FROM isc_dbi_tmp_wts_log log,
--                            isc_dbi_
--                      WHERE dml_type = 'DELETE');

  DELETE FROM isc_dbi_trip_stops_f
   WHERE stop_id IN (SELECT DISTINCT log.stop_id
                       FROM isc_dbi_tmp_wts_log log
                      WHERE NOT EXISTS (select '1' from wsh_trip_stops wts, wsh_trips wt
                                         where log.stop_id = wts.stop_id
                                           and wts.trip_id = wt.trip_id
                                           and wt.status_code IN ('IT', 'CL')));

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Deleted '||sql%rowcount||' trip stops from base summary in');
 COMMIT;

 FII_UTIL.Start_Timer;

  INSERT INTO isc_dbi_tmp_trip_stops tmp (
         STOP_ID,
         CARRIER_ID,
         MODE_OF_TRANSPORT,
         SERVICE_LEVEL,
         TIME_ACTL_ARRL_DATE_ID,
         TIME_INIT_DEPT_DATE_ID,
         TIME_PLN_ARRL_DATE_ID,
         ACTUAL_ARRIVAL_DATE,
         ACTUAL_DEPARTURE_DATE,
         DISTANCE_TO_NEXT_STOP_TRX,
         DISTANCE_UOM_CODE,
         PLANNED_ARRIVAL_DATE,
         STOP_RANK,
         STOP_SEQUENCE_NUMBER,
         TRIP_ID,
         ULTIMATE_STOP_SEQUENCE_NUMBER)
  SELECT /*+ leading(log) */ wts.stop_id					 STOP_ID,
         nvl(wt.carrier_id, -1)							 CARRIER_ID,
         nvl(wt.mode_of_transport, -1)						 MODE_OF_TRANSPORT,
         nvl(wt.service_level, -1)						 SERVICE_LEVEL,
         trunc(wts.actual_arrival_date)						 TIME_ACTL_ARRL_DATE_ID,
         trunc(min(wts.actual_departure_date) over (partition by wt.trip_id))	 TIME_INIT_DEPT_DATE_ID,
         trunc(wts.planned_arrival_date)					 TIME_PLN_ARRL_DATE_ID,
         wts.actual_arrival_date						 ACTUAL_ARRIVAL_DATE,
         wts.actual_departure_date						 ACTUAL_DEPARTURE_DATE,
         wts.distance_to_next_stop 						 DISTANCE_TO_NEXT_STOP_TRX,
         wts.distance_uom 							 DISTANCE_UOM_CODE,
         wts.planned_arrival_date					  	 PLANNED_ARRIVAL_DATE,
         rank() over (partition by wt.trip_id order by wts.stop_sequence_number) STOP_RANK,
         wts.stop_sequence_number						 STOP_SEQUENCE_NUMBER,
         wt.trip_id								 TRIP_ID,
         max(wts.stop_sequence_number) over (partition by wt.trip_id)		 ULTIMATE_STOP_SEQUENCE_NUMBER
    FROM (select /*+ no_merge index(tr) */ distinct tr.trip_id
            from isc_dbi_tmp_wts_log tmp, wsh_trip_stops tr
           where tmp.stop_id = tr.stop_id) log,
         wsh_trips wt,
         wsh_trip_stops wts
   WHERE log.trip_id = wt.trip_id
     AND wt.trip_id = wts.trip_id
     AND wt.status_code IN ('IT', 'CL')
     AND wts.physical_stop_id IS NULL
     AND wts.stop_sequence_number <> -99;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Identified '|| sql%rowcount || ' trip stops in');
 COMMIT;

INSERT INTO isc_dbi_tmp_del_legs tmp (
       DELIVERY_LEG_ID,
       CARRIER_ID,
       SHIPMENT_DIRECTION,
       MODE_OF_TRANSPORT,
       ORGANIZATION_ID,
       SERVICE_LEVEL,
       TIME_INIT_DEPT_DATE_ID,
       CONVERSION_DATE,
       CONVERSION_RATE,
       CONVERSION_TYPE_CODE,
       DELIVERY_ID,
       DROP_OFF_STOP_ID,
       FREIGHT_COST_TRX,
       FREIGHT_VOLUME_TRX,
       FREIGHT_WEIGHT_TRX,
       PICK_UP_STOP_ID,
       TRIP_ID,
       TRX_CURRENCY_CODE,
       VOLUME_UOM_CODE,
       WEIGHT_UOM_CODE,
       WH_CURRENCY_CODE,
       DELIVERY_TYPE,
       PARENT_DELIVERY_LEG_ID)
SELECT /*+ leading(its) use_nl(wdl)use_nl(hoi) use_nl(gsb) use_nl (wnd) */
       wdl.delivery_leg_id					 DELIVERY_LEG_ID,
       its.carrier_id						 CARRIER_ID,
       nvl(wnd.shipment_direction,'O')				 SHIPMENT_DIRECTION,
       its.mode_of_transport					 MODE_OF_TRANSPORT,
       wnd.organization_id					 ORGANIZATION_ID,
       its.service_level					 SERVICE_LEVEL,
       its.time_init_dept_date_id				 TIME_INIT_DEPT_DATE_ID,
       decode(upper(ifc.conversion_type_code),
              'USER',ifc.conversion_date,
	      its.time_init_dept_date_id)		 	 CONVERSION_DATE,
       decode(upper(ifc.conversion_type_code),
              'USER', ifc.conversion_rate, null)		 CONVERSION_RATE,
       nvl(ifc.conversion_type_code, nvl(g_treasury_rate_type, g_global_rate_type))	 CONVERSION_TYPE_CODE,
       wdl.delivery_id						 DELIVERY_ID,
       wdl.drop_off_stop_id					 DROP_OFF_STOP_ID,
       ifc.total_amount						 FREIGHT_COST_TRX,
       decode(wdl.parent_delivery_leg_id,null, wnd.volume,decode(delivery_type,'CONSOLIDATION',wnd.volume,0)) FREIGHT_VOLUME_TRX,
       decode(wdl.parent_delivery_leg_id,null, wnd.gross_weight,decode(delivery_type,'CONSOLIDATION',wnd.gross_weight,0)) FREIGHT_WEIGHT_TRX,
       wdl.pick_up_stop_id					 PICK_UP_STOP_ID,
       its.trip_id						 TRIP_ID,
       ifc.currency_code					 TRX_CURRENCY_CODE,
       wnd.volume_uom_code					 VOLUME_UOM_CODE,
       wnd.weight_uom_code					 WEIGHT_UOM_CODE,
       gsb.currency_code					 WH_CURRENCY_CODE,
       wnd.delivery_type                                         DELIVERY_TYPE,
       wdl.parent_delivery_leg_id                                PARENT_DELIVERY_LEG_ID
  FROM wsh_new_deliveries wnd,
       wsh_delivery_legs wdl,
       (select /*+ use_nl (wfct, wfc) */
               wfc.delivery_leg_id, total_amount, wfc.currency_code, conversion_type_code, conversion_rate, conversion_date
          from wsh_freight_costs wfc,wsh_freight_cost_types wfct,
               wsh_new_deliveries wnd, wsh_delivery_legs wdl
         where wfc.delivery_detail_id IS NULL
           AND wfc.freight_cost_type_id = wfct.freight_cost_type_id
           AND wnd.delivery_id = wdl.delivery_id
           AND wdl.delivery_leg_id = wfc.delivery_leg_id
           AND (wdl.parent_delivery_leg_id is null
              OR wnd.delivery_type = 'CONSOLIDATION')
           AND wfct.name = 'SUMMARY'
           AND wfct.freight_cost_type_code = 'FTESUMMARY') ifc,
       isc_dbi_tmp_trip_stops its,
       hr_organization_information hoi,
       gl_sets_of_books gsb
 WHERE wdl.delivery_id = wnd.delivery_id
   AND wnd.initial_pickup_date >= g_global_start_date
   AND nvl(wnd.shipping_control, 'NA') <> 'SUPPLIER'
   AND wdl.pick_up_stop_id = its.stop_id
   AND wdl.delivery_leg_id = ifc.delivery_leg_id(+)
   AND hoi.org_information_context ='Accounting Information'
   AND hoi.organization_id = wnd.organization_id
   AND to_number(hoi.org_information1) = gsb.set_of_books_id;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Identified '|| sql%rowcount || ' delivery legs in');
 COMMIT;

  FII_UTIL.Start_Timer;

  IF g_reporting_weight_uom IS NOT NULL THEN
     INSERT INTO isc_dbi_fte_uom_rates (MEASURE_CODE, FROM_UOM_CODE, TO_UOM_CODE, INVENTORY_ITEM_ID, CONVERSION_RATE)
     SELECT 'WT', from_uom, g_reporting_weight_uom, NULL inventory_item_id,
            decode(from_uom, g_reporting_weight_uom, 1, opi_dbi_rep_uom_pkg.uom_convert(NULL, NULL, 1, from_uom, g_reporting_weight_uom))
       FROM (SELECT DISTINCT weight_uom_code FROM_UOM
               FROM isc_dbi_tmp_del_legs
              WHERE weight_uom_code is not null);
  END IF;

  IF g_reporting_volume_uom IS NOT NULL THEN
     INSERT INTO isc_dbi_fte_uom_rates (MEASURE_CODE, FROM_UOM_CODE, TO_UOM_CODE, INVENTORY_ITEM_ID, CONVERSION_RATE)
     SELECT 'VOL', from_uom, g_reporting_volume_uom, NULL inventory_item_id,
            decode(from_uom, g_reporting_volume_uom, 1, opi_dbi_rep_uom_pkg.uom_convert(NULL, NULL, 1, from_uom, g_reporting_volume_uom))
       FROM (SELECT DISTINCT volume_uom_code FROM_UOM
               FROM isc_dbi_tmp_del_legs
              WHERE volume_uom_code is not null);
  END IF;

  IF g_reporting_distance_uom IS NOT NULL THEN
     INSERT INTO isc_dbi_fte_uom_rates (MEASURE_CODE, FROM_UOM_CODE, TO_UOM_CODE, INVENTORY_ITEM_ID, CONVERSION_RATE)
     SELECT 'DIS', from_uom, g_reporting_distance_uom, NULL inventory_item_id,
            decode(from_uom,g_reporting_distance_uom,1,opi_dbi_rep_uom_pkg.uom_convert(NULL, NULL, 1, from_uom, g_reporting_distance_uom))
       FROM (SELECT DISTINCT distance_uom_code FROM_UOM
               FROM isc_dbi_tmp_trip_stops
              where distance_uom_code is not null);
  END IF;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Retrieved '||sql%rowcount||' uom rates in');
  COMMIT;

  FII_UTIL.Start_Timer;

  INSERT INTO isc_dbi_fte_curr_rates
              (TRX_CURRENCY_CODE, WH_CURRENCY_CODE, CONVERSION_DATE, CONVERSION_TYPE_CODE, TRX_WH_RATE, WH_PRIM_RATE, WH_SEC_RATE)
  SELECT trx_currency_code, wh_currency_code, conversion_date, conversion_type_code,
         decode(trx_currency_code, wh_currency_code, 1,
                fii_currency.get_rate(trx_currency_code, wh_currency_code, conversion_date, conversion_type_code)) TRX_WH_RATE,
         decode(g_global_currency, trx_currency_code, 1, wh_currency_code, 1,
                fii_currency.get_global_rate_primary(wh_currency_code, conversion_date)) 				WH_PRIM_RATE,
         decode(g_sec_global_currency, trx_currency_code, 1, wh_currency_code, 1,
                fii_currency.get_global_rate_secondary(wh_currency_code, conversion_date)) 			WH_SEC_RATE
    FROM (SELECT distinct trx_currency_code, wh_currency_code, conversion_date CONVERSION_DATE, conversion_type_code CONVERSION_TYPE_CODE
            FROM isc_dbi_tmp_del_legs idl
           WHERE idl.freight_cost_trx is not null);

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Retrieved '||sql%rowcount||' currency rates in');
  COMMIT;

 FII_UTIL.Start_Timer;

  UPDATE isc_dbi_tmp_del_legs SET batch_id = ceil(rownum/g_batch_size);
  l_total := l_total + sql%rowcount;

  UPDATE isc_dbi_tmp_trip_stops SET batch_id = ceil(rownum/g_batch_size);
  l_total := l_total + sql%rowcount;

  COMMIT;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Updated the batch id for '|| l_total || ' rows in');

  RETURN(l_total);

  EXCEPTION
   WHEN OTHERS THEN
    g_errbuf  := 'Error in Function IDENTIFY_CHANGE_STOP_LEG_ICRL : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
 END identify_change_stop_leg_icrl;

FUNCTION IDENTIFY_CHANGE_INVOICE_ICRL RETURN NUMBER IS

  l_total		NUMBER;

 BEGIN

  l_total := 0;

 FII_UTIL.Start_Timer;

  INSERT INTO isc_dbi_tmp_fih_log (INVOICE_HEADER_ID, LOG_ROWID, DML_TYPE, LAST_UPDATE_DATE)
  SELECT invoice_header_id, rowid LOG_ROWID, dml_type, last_update_date
    FROM isc_dbi_fih_change_log;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Inserted '|| sql%rowcount || ' rows into ISC_DBI_TMP_FIH_LOG');

  COMMIT;

 FND_STATS.GATHER_TABLE_STATS(OWNNAME => g_isc_schema,
			      TABNAME => 'ISC_DBI_TMP_FIH_LOG');

 BIS_COLLECTION_UTILITIES.put_line('Deleting obsolete records from the base summary');
 FII_UTIL.Start_Timer;

  DELETE FROM isc_dbi_fte_invoices_f
   WHERE invoice_header_id IN (SELECT DISTINCT log.invoice_header_id
                                  FROM isc_dbi_tmp_fih_log log
                                 WHERE NOT EXISTS (select '1' from fte_invoice_headers fih
                                                    where fih.invoice_header_id = log.invoice_header_id
						      and fih.bill_status in ('APPROVED', 'IN_PROGRESS', 'PAID', 'PARTIALLY PAID', 'PARTIAL_PAID')));

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Deleted '||sql%rowcount||' invoice headers from base summary in');
 COMMIT;

  FII_UTIL.Start_Timer;

INSERT INTO isc_dbi_tmp_fte_invoices tmp (
       INVOICE_HEADER_ID,
       CARRIER_ID,
       MODE_OF_TRANSPORT,
       ORG_ID,
       SERVICE_LEVEL,
       SUPPLIER_ID,
       APPROVED_AMT_TRX,
       BILL_AMT_TRX,
       BILL_NUMBER,
       BILL_STATUS,
       BILL_TYPE,
       BOL,
       CONVERSION_DATE,
       CONVERSION_TYPE_CODE,
       DELIVERY_LEG_ID,
       TRIP_ID,
       TRX_CURRENCY_CODE,
       WH_CURRENCY_CODE)
SELECT /*+ leading(log) */
       fih.invoice_header_id		INVOICE_HEADER_ID,
       idl.carrier_id			CARRIER_ID,
       idl.mode_of_transport		MODE_OF_TRANSPORT,
       fih.org_id			ORG_ID,
       idl.service_level		SERVICE_LEVEL,
       fih.supplier_id			SUPPLIER_ID,
       fih.approved_amount		APPROVED_AMT_TRX,
       fih.total_amount			BILL_AMT_TRX,
       fih.bill_number			BILL_NUMBER,
       fih.bill_status			BILL_STATUS,
       fih.bill_type			BILL_TYPE,
       fih.bol				BOL,
       idl.time_init_dept_date_id   	CONVERSION_DATE,
       nvl(g_treasury_rate_type, g_global_rate_type) CONVERSION_TYPE_CODE,
       idl.delivery_leg_id		DELIVERY_LEG_ID,
       idl.trip_id			TRIP_ID,
       fih.currency_code		TRX_CURRENCY_CODE,
       gsb.currency_code		WH_CURRENCY_CODE
  FROM (select distinct invoice_header_id from isc_dbi_tmp_fih_log) log,
       fte_invoice_headers fih,
       wsh_document_instances wdi,
       isc_dbi_del_legs_f idl,
       ar_system_parameters_all aspa,
       gl_sets_of_books gsb
 WHERE log.invoice_header_id = fih.invoice_header_id
   AND fih.mode_of_transport = 'LTL'
   AND fih.bill_status in ('APPROVED', 'IN_PROGRESS', 'PAID', 'PARTIALLY PAID', 'PARTIAL_PAID')
   AND fih.bol = wdi.sequence_number
   AND wdi.entity_name = 'WSH_DELIVERY_LEGS'
   AND wdi.document_type = 'BOL'
   AND wdi.entity_id = idl.delivery_leg_id
   AND fih.org_id = aspa.org_id
   AND aspa.set_of_books_id = gsb.set_of_books_id
   AND idl.mode_of_transport = 'LTL'
 UNION ALL
SELECT /*+ leading(log) */
       fih.invoice_header_id		INVOICE_HEADER_ID,
       itr.carrier_id			CARRIER_ID,
       itr.mode_of_transport		MODE_OF_TRANSPORT,
       fih.org_id			ORG_ID,
       itr.service_level		SERVICE_LEVEL,
       fih.supplier_id			SUPPLIER_ID,
       fih.approved_amount		APPROVED_AMT_TRX,
       fih.total_amount			BILL_AMT_TRX,
       fih.bill_number			BILL_NUMBER,
       fih.bill_status			BILL_STATUS,
       fih.bill_type			BILL_TYPE,
       fih.bol				BOL,
       itr.time_init_dept_date_id	CONVERSION_DATE,
       nvl(g_treasury_rate_type, g_global_rate_type) CONVERSION_TYPE_CODE,
       null				DELIVERY_LEG_ID,
       itr.trip_id			TRIP_ID,
       fih.currency_code		TRX_CURRENCY_CODE,
       gsb.currency_code		WH_CURRENCY_CODE
  FROM (select distinct invoice_header_id from isc_dbi_tmp_fih_log) log,
       fte_invoice_headers fih,
       wsh_document_instances wdi,
       isc_dbi_trip_stops_f itr,
       ar_system_parameters_all aspa,
       gl_sets_of_books gsb
 WHERE log.invoice_header_id = fih.invoice_header_id
   AND fih.mode_of_transport = 'TL'
   AND fih.bill_status in ('APPROVED', 'IN_PROGRESS', 'PAID', 'PARTIALLY PAID', 'PARTIAL_PAID')
   AND fih.bol = wdi.sequence_number
   AND wdi.entity_name = 'WSH_TRIPS'
   AND wdi.document_type = 'MBOL'
   AND wdi.entity_id = itr.trip_id
   AND itr.stop_rank = 1
   AND fih.org_id = aspa.org_id
   AND aspa.set_of_books_id = gsb.set_of_books_id;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Identified '|| sql%rowcount || ' invoice headers in');
 COMMIT;

  FII_UTIL.Start_Timer;

  INSERT INTO isc_dbi_fte_curr_rates
              (TRX_CURRENCY_CODE, WH_CURRENCY_CODE, CONVERSION_DATE, CONVERSION_TYPE_CODE, TRX_WH_RATE, WH_PRIM_RATE, WH_SEC_RATE)
  SELECT trx_currency_code, wh_currency_code, conversion_date, conversion_type_code,
         decode(trx_currency_code, wh_currency_code, 1,
                fii_currency.get_rate(trx_currency_code, wh_currency_code, conversion_date, conversion_type_code)) TRX_WH_RATE,
         decode(g_global_currency, trx_currency_code, 1, wh_currency_code, 1,
                fii_currency.get_global_rate_primary(wh_currency_code, conversion_date)) 				WH_PRIM_RATE,
         decode(g_sec_global_currency, trx_currency_code, 1, wh_currency_code, 1,
                fii_currency.get_global_rate_secondary(wh_currency_code, conversion_date)) 			WH_SEC_RATE
    FROM (SELECT distinct trx_currency_code, wh_currency_code, conversion_date, conversion_type_code CONVERSION_TYPE_CODE
            FROM isc_dbi_tmp_fte_invoices);

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Retrieved '||sql%rowcount||' currency rates in');
  COMMIT;

 FII_UTIL.Start_Timer;

  UPDATE isc_dbi_tmp_fte_invoices SET batch_id = ceil(rownum/g_batch_size);
  l_total := l_total + sql%rowcount;

  COMMIT;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Updated the batch id for '|| l_total || ' rows in');

  RETURN(l_total);

  EXCEPTION
   WHEN OTHERS THEN
    g_errbuf  := 'Error in Function IDENTIFY_CHANGE_INVOICE_ICRL : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
 END identify_change_invoice_icrl;

      -- ---------------------
      -- CHECK_TIME_CONTINUITY
      -- ---------------------

FUNCTION CHECK_TIME_CONTINUITY_INIT RETURN NUMBER IS

  l_min_ip_date		DATE;
  l_max_ip_date		DATE;
  l_min_pr_date		DATE;
  l_max_pr_date		DATE;
  l_min_actl_arrl_date	DATE;
  l_max_actl_arrl_date	DATE;
  l_min_init_dept_date	DATE;
  l_max_init_dept_date	DATE;
  l_min_pln_arrl_date	DATE;
  l_max_pln_arrl_date	DATE;
  l_min			DATE;
  l_max			DATE;
  l_is_missing		BOOLEAN;
  l_time_min		DATE;
  l_time_max		DATE;
  l_time_missing	BOOLEAN;

  CURSOR Lines_Missing_Date IS
  SELECT /*+ PARALLEL(tmp) */ delivery_detail_id,
         to_char(time_ip_date_id, 'MM/DD/YYYY') time_ip_date_id,
	 to_char(time_pr_date_id, 'MM/DD/YYYY') time_pr_date_id
    FROM isc_dbi_tmp_del_details tmp
   WHERE (least(nvl(time_ip_date_id,l_time_min), nvl(time_pr_date_id,l_time_min)) < l_time_min
      OR greatest(nvl(time_ip_date_id, l_time_max), nvl(time_pr_date_id, l_time_max)) > l_time_max);

  CURSOR Stops_Missing_Date IS
  SELECT /*+ PARALLEL(tmp) */
         trip_id,
	 stop_id,
	 to_char(time_actl_arrl_date_id, 'MM/DD/YYYY') time_actl_arrl_date_id,
	 to_char(actual_departure_date, 'MM/DD/YYYY') time_actl_dept_date_id,
	 to_char(time_pln_arrl_date_id,'MM/DD/YYYY') time_pln_arrl_date_id
    FROM isc_dbi_tmp_trip_stops tmp
   WHERE (least(nvl(time_actl_arrl_date_id,l_time_min),nvl(trunc(actual_departure_date),l_time_min), nvl(time_pln_arrl_date_id,l_time_min)) < l_time_min
      OR greatest(nvl(time_actl_arrl_date_id,l_time_max),nvl(trunc(actual_departure_date),l_time_max), nvl(time_pln_arrl_date_id,l_time_max)) > l_time_max);

  l_line		LINES_MISSING_DATE%ROWTYPE;
  l_stop		STOPS_MISSING_DATE%ROWTYPE;

BEGIN

  l_is_missing := TRUE;
  l_time_missing := TRUE;

  FII_UTIL.Start_Timer;

  BIS_COLLECTION_UTILITIES.Put_Line('Begin to retrieve the time boundary for the initial load');

  SELECT /*+ PARALLEL(tmp) */
         min(time_ip_date_id), max(time_ip_date_id),
         min(time_pr_date_id), max(time_pr_date_id)
    INTO l_min_ip_date, l_max_ip_date, l_min_pr_date, l_max_pr_date
    FROM isc_dbi_tmp_del_details tmp;

  SELECT /*+ PARALLEL(tmp) */
         min(time_actl_arrl_date_id), max(time_actl_arrl_date_id),
  	 min(time_init_dept_date_id), max(time_init_dept_date_id),
         min(time_pln_arrl_date_id), max(time_pln_arrl_date_id)
    INTO l_min_actl_arrl_date, l_max_actl_arrl_date, l_min_init_dept_date, l_max_init_dept_date, l_min_pln_arrl_date, l_max_pln_arrl_date
    FROM isc_dbi_tmp_trip_stops tmp;

  l_min := least(nvl(l_min_ip_date,sysdate), nvl(l_min_pr_date,sysdate), nvl(l_min_actl_arrl_date,sysdate),
                 nvl(l_min_init_dept_date,sysdate), nvl(l_min_pln_arrl_date,sysdate));
  l_max := greatest(nvl(l_max_ip_date,sysdate), nvl(l_max_pr_date,sysdate), nvl(l_max_actl_arrl_date,sysdate),
		    nvl(l_max_init_dept_date,sysdate), nvl(l_max_pln_arrl_date,sysdate));

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Retrieved the time boundary ' || l_min || ' - ' || l_max || ' in ');

  BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
  BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
  FII_UTIL.Start_Timer;

  FII_TIME_API.check_missing_date(l_min, l_max, l_is_missing);

  IF (l_is_missing) THEN
     BIS_COLLECTION_UTILITIES.Put_Line('Collection failed because there are dangling keys for time dimension.');
     BIS_COLLECTION_UTILITIES.Put_Line('No records were loaded.');

     SELECT min(report_date), max(report_date)
       INTO l_time_min, l_time_max
       FROM fii_time_day;

     OPEN lines_missing_date;
     FETCH lines_missing_date INTO l_line;

     BIS_COLLECTION_UTILITIES.Put_Line_Out(fnd_message.get_string('ISC', 'ISC_DBI_DATE_NO_LOAD'));
     BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
     BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(fnd_message.get_string('ISC','ISC_DBI_DELIVERY_DETAIL'),18,' ')
	||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_IP_DATE'),19,' ')
	||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_PR_DATE'),19,' '));
     BIS_COLLECTION_UTILITIES.Put_Line_Out('------------------ - ------------------- - ------------------');

     WHILE LINES_MISSING_DATE%FOUND LOOP
        BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(l_line.delivery_detail_id,18,' ')
			      ||' - '||RPAD(l_line.time_ip_date_id,19,' ')
			      ||' - '||RPAD(nvl(l_line.time_pr_date_id,' '),19,' '));
        FETCH Lines_Missing_Date INTO l_line;
     END LOOP;

     CLOSE LINES_MISSING_DATE;
     BIS_COLLECTION_UTILITIES.Put_Line_Out('+-------------------------------------------------------------------------+');

     OPEN stops_missing_date;
     FETCH stops_missing_date INTO l_stop;

     BIS_COLLECTION_UTILITIES.Put_Line_Out(fnd_message.get_string('ISC', 'ISC_DBI_DATE_NO_LOAD'));
     BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
     BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(fnd_message.get_string('ISC','ISC_DBI_TRIP_ID'),18,' ')
	||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_STOP_ID'),18,' ')
	||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_ACTL_ARRL_DATE'),19,' ')
	||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_ACTL_DEPT_DATE'),21,' ')
	||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_PLN_ARRL_DATE'),20,' '));
     BIS_COLLECTION_UTILITIES.Put_Line_Out('------------------ - ------------------ - ------------------- - --------------------- - --------------------');

     WHILE STOPS_MISSING_DATE%FOUND LOOP
        BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(l_stop.trip_id,18,' ')
			      ||' - '||RPAD(l_stop.stop_id,18,' ')
			      ||' - '||RPAD(l_stop.time_actl_arrl_date_id,19,' ')
			      ||' - '||RPAD(l_stop.time_actl_dept_date_id,21,' ')
			      ||' - '||RPAD(nvl(l_stop.time_pln_arrl_date_id,' '),20,' '));
        FETCH STOPS_MISSING_DATE INTO l_stop;
     END LOOP;

     CLOSE STOPS_MISSING_DATE;
     BIS_COLLECTION_UTILITIES.Put_Line_Out('+-------------------------------------------------------------------------------------------------+');

     RETURN (-999);
  ELSE
     BIS_COLLECTION_UTILITIES.Put_Line(' ');
     BIS_COLLECTION_UTILITIES.Put_Line('           THERE IS NO DANGLING TIME ATTRIBUTES    ');
     BIS_COLLECTION_UTILITIES.Put_Line('+---------------------------------------------------------------------------+');
     BIS_COLLECTION_UTILITIES.Put_Line(' ');
  END IF;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Completed time continuity check in');

  RETURN(1);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function CHECK_TIME_CONTINUITY_INIT : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
END;

FUNCTION CHECK_TIME_CONTINUITY_DETAIL RETURN NUMBER IS

  l_min_ip_date		DATE;
  l_max_ip_date		DATE;
  l_min_pr_date		DATE;
  l_max_pr_date		DATE;
  l_min			DATE;
  l_max			DATE;
  l_is_missing		BOOLEAN;
  l_time_min		DATE;
  l_time_max		DATE;
  l_time_missing	BOOLEAN;

  CURSOR Lines_Missing_Date IS
  SELECT delivery_detail_id,
	 to_char(time_ip_date_id, 'MM/DD/YYYY') time_ip_date_id,
	 to_char(time_pr_date_id, 'MM/DD/YYYY') time_pr_date_id
    FROM isc_dbi_tmp_del_details
   WHERE (least(nvl(time_ip_date_id,l_time_min), nvl(time_pr_date_id,l_time_min)) < l_time_min
      OR greatest(nvl(time_ip_date_id, l_time_max), nvl(time_pr_date_id, l_time_max)) > l_time_max);

  l_line		LINES_MISSING_DATE%ROWTYPE;

BEGIN

  l_is_missing := TRUE;
  l_time_missing := TRUE;

  FII_UTIL.Start_Timer;

  BIS_COLLECTION_UTILITIES.Put_Line('Begin to retrieve the time boundary for the incremental load');

  SELECT min(time_ip_date_id), max(time_ip_date_id),
 	 min(time_pr_date_id), max(time_pr_date_id)
    INTO l_min_ip_date, l_max_ip_date, l_min_pr_date, l_max_pr_date
    FROM isc_dbi_tmp_del_details tmp;

  l_min := least(nvl(l_min_ip_date,sysdate), nvl(l_min_pr_date,sysdate));
  l_max := greatest(nvl(l_max_ip_date,sysdate), nvl(l_max_pr_date,sysdate));

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Retrieved the time boundary ' || l_min || ' - ' || l_max || ' in ');

  BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
  BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
  FII_UTIL.Start_Timer;

  FII_TIME_API.check_missing_date(l_min, l_max, l_is_missing);

  IF (l_is_missing) THEN
     BIS_COLLECTION_UTILITIES.Put_Line('Collection failed because there are dangling keys for time dimension.');
     BIS_COLLECTION_UTILITIES.Put_Line('No records were loaded.');

     SELECT min(report_date), max(report_date)
       INTO l_time_min, l_time_max
       FROM fii_time_day;

     OPEN lines_missing_date;
     FETCH lines_missing_date INTO l_line;

     BIS_COLLECTION_UTILITIES.Put_Line_Out(fnd_message.get_string('ISC', 'ISC_DBI_DATE_NO_LOAD'));
     BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
     BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(fnd_message.get_string('ISC','ISC_DBI_DELIVERY_DETAIL_ID'),18,' ')
	||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_IP_DATE'),19,' ')
	||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_PR_DATE'),19,' '));
     BIS_COLLECTION_UTILITIES.Put_Line_Out('------------------ - ------------------- - ------------------');

     WHILE LINES_MISSING_DATE%FOUND LOOP
        BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(l_line.delivery_detail_id,18,' ')
			      ||' - '||RPAD(l_line.time_ip_date_id,19,' ')
			      ||' - '||RPAD(nvl(l_line.time_pr_date_id,' '),19,' '));
        FETCH Lines_Missing_Date INTO l_line;
     END LOOP;

     CLOSE LINES_MISSING_DATE;
     BIS_COLLECTION_UTILITIES.Put_Line_Out('+-------------------------------------------------------------------------+');

     RETURN (-999);
  ELSE
     BIS_COLLECTION_UTILITIES.Put_Line(' ');
     BIS_COLLECTION_UTILITIES.Put_Line('           THERE IS NO DANGLING TIME ATTRIBUTES    ');
     BIS_COLLECTION_UTILITIES.Put_Line('+---------------------------------------------------------------------------+');
     BIS_COLLECTION_UTILITIES.Put_Line(' ');
  END IF;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Completed time continuity check in');

  RETURN(1);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function CHECK_TIME_CONTINUITY_DETAIL : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
END;

FUNCTION CHECK_TIME_CONTINUITY_STOP RETURN NUMBER IS

  l_min_actl_arrl_date	DATE;
  l_max_actl_arrl_date	DATE;
  l_min_init_dept_date	DATE;
  l_max_init_dept_date	DATE;
  l_min_pln_arrl_date	DATE;
  l_max_pln_arrl_date	DATE;
  l_min			DATE;
  l_max			DATE;
  l_is_missing		BOOLEAN;
  l_time_min		DATE;
  l_time_max		DATE;
  l_time_missing	BOOLEAN;

  CURSOR Stops_Missing_Date IS
  SELECT trip_id,
	 stop_id,
	 to_char(time_actl_arrl_date_id, 'MM/DD/YYYY') time_actl_arrl_date_id,
	 to_char(actual_departure_date, 'MM/DD/YYYY') time_actl_dept_date_id,
	 to_char(time_pln_arrl_date_id,'MM/DD/YYYY') time_pln_arrl_date_id
    FROM isc_dbi_tmp_trip_stops
   WHERE (least(nvl(time_actl_arrl_date_id,l_time_min), nvl(trunc(actual_departure_date),l_time_min), nvl(time_pln_arrl_date_id,l_time_min)) < l_time_min
      OR greatest(nvl(time_actl_arrl_date_id,l_time_max),nvl(trunc(actual_departure_date),l_time_max), nvl(time_pln_arrl_date_id,l_time_max)) > l_time_max);

  l_stop		STOPS_MISSING_DATE%ROWTYPE;

BEGIN

  l_is_missing := TRUE;
  l_time_missing := TRUE;

  FII_UTIL.Start_Timer;
  BIS_COLLECTION_UTILITIES.Put_Line('Begin to retrieve the time boundary for the incremental load');

  SELECT min(time_actl_arrl_date_id), max(time_actl_arrl_date_id),
  	 min(time_init_dept_date_id), max(time_init_dept_date_id),
         min(time_pln_arrl_date_id), max(time_pln_arrl_date_id)
    INTO l_min_actl_arrl_date, l_max_actl_arrl_date, l_min_init_dept_date, l_max_init_dept_date, l_min_pln_arrl_date, l_max_pln_arrl_date
    FROM isc_dbi_tmp_trip_stops tmp;

  l_min := least(nvl(l_min_actl_arrl_date,sysdate), nvl(l_min_init_dept_date,sysdate), nvl(l_min_pln_arrl_date,sysdate));
  l_max := greatest(nvl(l_max_actl_arrl_date,sysdate), nvl(l_max_init_dept_date,sysdate), nvl(l_max_pln_arrl_date,sysdate));

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Retrieved the time boundary ' || l_min || ' - ' || l_max || ' in ');

  BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
  BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
  FII_UTIL.Start_Timer;

  FII_TIME_API.check_missing_date(l_min, l_max, l_is_missing);

  IF (l_is_missing) THEN
     BIS_COLLECTION_UTILITIES.Put_Line('Collection failed because there are dangling keys for time dimension.');
     BIS_COLLECTION_UTILITIES.Put_Line('No records were loaded.');

     SELECT min(report_date), max(report_date)
       INTO l_time_min, l_time_max
       FROM fii_time_day;

     OPEN stops_missing_date;
     FETCH stops_missing_date INTO l_stop;

     BIS_COLLECTION_UTILITIES.Put_Line_Out(fnd_message.get_string('ISC', 'ISC_DBI_DATE_NO_LOAD'));
     BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
     BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(fnd_message.get_string('ISC','ISC_DBI_TRIP_ID'),18,' ')
	||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_STOP_ID'),18,' ')
	||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_ACTL_ARRL_DATE'),19,' ')
	||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_ACTL_DEPT_DATE'),21,' ')
	||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_PLN_ARRL_DATE'),20,' '));
     BIS_COLLECTION_UTILITIES.Put_Line_Out('------------------ - ------------------ - ------------------- - --------------------- - --------------------');

     WHILE STOPS_MISSING_DATE%FOUND LOOP
        BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(l_stop.trip_id,18,' ')
			      ||' - '||RPAD(l_stop.stop_id,18,' ')
			      ||' - '||RPAD(l_stop.time_actl_arrl_date_id,19,' ')
			      ||' - '||RPAD(l_stop.time_actl_dept_date_id,21,' ')
			      ||' - '||RPAD(nvl(l_stop.time_pln_arrl_date_id,' '),20,' '));
        FETCH STOPS_MISSING_DATE INTO l_stop;
     END LOOP;

     CLOSE STOPS_MISSING_DATE;
     BIS_COLLECTION_UTILITIES.Put_Line_Out('+-------------------------------------------------------------------------------------------------+');

     RETURN (-999);
  ELSE
     BIS_COLLECTION_UTILITIES.Put_Line(' ');
     BIS_COLLECTION_UTILITIES.Put_Line('           THERE IS NO DANGLING TIME ATTRIBUTES    ');
     BIS_COLLECTION_UTILITIES.Put_Line('+---------------------------------------------------------------------------+');
     BIS_COLLECTION_UTILITIES.Put_Line(' ');
  END IF;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Completed time continuity check in');

  RETURN(1);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function CHECK_TIME_CONTINUITY_STOP : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
END;

      -- ----------------------------------------
      -- Identify Dangling Key for Item Dimension
      -- ----------------------------------------

FUNCTION IDENTIFY_DANGLING_ITEM RETURN NUMBER IS

  CURSOR Dangling_Items_Init IS
  SELECT /*+ PARALLEL(tmp) PARALLEL(item) */ distinct tmp.inventory_item_id, tmp.organization_id
    FROM isc_dbi_tmp_del_details tmp,
         eni_oltp_item_star item
   WHERE tmp.inventory_item_id = item.inventory_item_id(+)
     AND tmp.organization_id = item.organization_id(+)
     AND item.inventory_item_id IS NULL
     AND tmp.inventory_item_id IS NOT NULL;

  CURSOR Dangling_Items_Incre IS
  SELECT distinct tmp.inventory_item_id, tmp.organization_id
    FROM isc_dbi_tmp_del_details tmp,
         eni_oltp_item_star item
   WHERE tmp.inventory_item_id = item.inventory_item_id(+)
     AND tmp.organization_id = item.organization_id(+)
     AND item.inventory_item_id IS NULL
     AND tmp.inventory_item_id IS NOT NULL;

  l_item	NUMBER;
  l_org		NUMBER;
  l_total	NUMBER;

BEGIN

  l_total := 0;

  IF (g_load_mode = 'INITIAL') THEN
     OPEN dangling_items_init;
     FETCH dangling_items_init INTO l_item, l_org;

     IF dangling_items_init%ROWCOUNT <> 0 THEN
        BIS_COLLECTION_UTILITIES.Put_Line('Collection failed because there are dangling keys for item dimension.');
        BIS_COLLECTION_UTILITIES.Put_Line('No records were loaded');

        BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
        BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
        BIS_COLLECTION_UTILITIES.Put_Line_Out(fnd_message.get_string('ISC', 'ISC_DBI_ITEM_NO_LOAD'));
        BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
        BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(fnd_message.get_string('ISC','ISC_DBI_INV_ITEM_ID'),23,' ')||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_ORG_ID'),20,' '));
        BIS_COLLECTION_UTILITIES.Put_Line_Out('----------------------- - --------------------');

        WHILE Dangling_Items_Init%FOUND LOOP
           BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(l_item,23,' ')||' - '||RPAD(l_org,20,' '));
  	   FETCH Dangling_Items_Init INTO l_item, l_org;
        END LOOP;
        BIS_COLLECTION_UTILITIES.Put_Line_Out('+--------------------------------------------+');
     ELSE
        BIS_COLLECTION_UTILITIES.Put_Line(' ');
        BIS_COLLECTION_UTILITIES.Put_Line('           THERE IS NO DANGLING ITEMS        ');
        BIS_COLLECTION_UTILITIES.Put_Line('+--------------------------------------------+');
        BIS_COLLECTION_UTILITIES.Put_Line(' ');
     END IF;
     l_total := Dangling_Items_Init%ROWCOUNT;
     CLOSE Dangling_Items_Init;

  ELSIF (g_load_mode = 'INCREMENTAL') THEN
     OPEN dangling_items_incre;
     FETCH dangling_items_incre INTO l_item, l_org;

     IF dangling_items_incre%ROWCOUNT <> 0 THEN
        BIS_COLLECTION_UTILITIES.Put_Line('Collection failed because there are dangling keys for item dimension.');
        BIS_COLLECTION_UTILITIES.Put_Line('No records were loaded');

        BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
        BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
        BIS_COLLECTION_UTILITIES.Put_Line_Out(fnd_message.get_string('ISC', 'ISC_DBI_ITEM_NO_LOAD'));
        BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
        BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(fnd_message.get_string('ISC','ISC_DBI_INV_ITEM_ID'),23,' ')||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_ORG_ID'),20,' '));
        BIS_COLLECTION_UTILITIES.Put_Line_Out('----------------------- - --------------------');

        WHILE Dangling_Items_Incre%FOUND LOOP
           BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(l_item,23,' ')||' - '||RPAD(l_org,20,' '));
	   FETCH Dangling_Items_Incre INTO l_item, l_org;
        END LOOP;
        BIS_COLLECTION_UTILITIES.Put_Line_Out('+--------------------------------------------+');
     ELSE
        BIS_COLLECTION_UTILITIES.Put_Line(' ');
        BIS_COLLECTION_UTILITIES.Put_Line('           THERE IS NO DANGLING ITEMS        ');
        BIS_COLLECTION_UTILITIES.Put_Line('+--------------------------------------------+');
        BIS_COLLECTION_UTILITIES.Put_Line(' ');
     END IF;
     l_total := Dangling_Items_Incre%ROWCOUNT;
     CLOSE Dangling_Items_Incre;
  END IF;

  RETURN(l_total);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function IDENTIFY_DANGLING_ITEM : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
 END;

      -- -----------------------------------
      -- Reporting of the missing currencies
      -- -----------------------------------

FUNCTION REPORT_MISSING_RATE RETURN NUMBER IS

CURSOR Missing_Currency_Conversion IS
   SELECT distinct decode(trx_wh_rate, -3, to_date('01/01/1999','MM/DD/RRRR'), conversion_date) CURR_CONV_DATE,
	  trx_currency_code FROM_CURRENCY,
 	  wh_currency_code  TO_CURRENCY,
	  conversion_type_code RATE_TYPE,
 	  decode(trx_wh_rate, -1, 'RATE NOT AVAILABLE', -2, 'INVALID CURRENCY') STATUS
     FROM isc_dbi_fte_curr_rates tmp
    WHERE trx_wh_rate < 0
      AND upper(conversion_type_code) <> 'USER'
   UNION
   SELECT distinct decode(wh_prim_rate, -3, to_date('01/01/1999','MM/DD/RRRR'), conversion_date) CURR_CONV_DATE,
	  wh_currency_code  FROM_CURRENCY,
 	  g_global_currency TO_CURRENCY,
	  g_global_rate_type RATE_TYPE,
 	  decode(wh_prim_rate, -1, 'RATE NOT AVAILABLE', -2, 'INVALID CURRENCY') STATUS
     FROM isc_dbi_fte_curr_rates tmp
    WHERE wh_prim_rate < 0
   UNION
   SELECT distinct decode(wh_sec_rate, -3, to_date('01/01/1999','MM/DD/RRRR'), conversion_date) CURR_CONV_DATE,
	  wh_currency_code FROM_CURRENCY,
 	  g_sec_global_currency TO_CURRENCY,
	  g_sec_global_rate_type RATE_TYPE,
 	  decode(wh_sec_rate, -1, 'RATE NOT AVAILABLE', -2, 'INVALID CURRENCY') STATUS
     FROM isc_dbi_fte_curr_rates tmp
    WHERE wh_sec_rate < 0
      AND g_sec_curr_def = 'Y';

l_record				Missing_Currency_Conversion%ROWTYPE;
l_total					NUMBER;

 BEGIN

  l_total := 0;
  OPEN Missing_Currency_Conversion;
  FETCH Missing_Currency_Conversion INTO l_record;

  IF Missing_Currency_Conversion%ROWCOUNT <> 0
    THEN
      BIS_COLLECTION_UTILITIES.Put_Line('Collection failed because there are missing currency conversion rates.');
      BIS_COLLECTION_UTILITIES.Put_Line(fnd_message.get_string('BIS', 'BIS_DBI_CURR_NO_LOAD'));

      BIS_COLLECTION_UTILITIES.writeMissingRateHeader;
        WHILE Missing_Currency_Conversion%FOUND LOOP
          l_total := l_total + 1;
	  BIS_COLLECTION_UTILITIES.writeMissingRate(
        	l_record.rate_type,
        	l_record.from_currency,
        	l_record.to_currency,
        	l_record.curr_conv_date);
	  FETCH Missing_Currency_Conversion INTO l_record;
	END LOOP;
      BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
      BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');

  ELSE -- Missing_Currency_Conversion%ROWCOUNT = 0
      BIS_COLLECTION_UTILITIES.Put_Line(' ');
      BIS_COLLECTION_UTILITIES.Put_Line('           THERE IS NO MISSING CURRENCY CONVERSION RATE        ');
      BIS_COLLECTION_UTILITIES.Put_Line('+---------------------------------------------------------------------------+');
      BIS_COLLECTION_UTILITIES.Put_Line(' ');
  END IF; -- Missing_Currency_Conversion%ROWCOUNT <> 0

  CLOSE Missing_Currency_Conversion;

  RETURN(l_total);

  EXCEPTION
   WHEN OTHERS THEN
    g_errbuf  := 'Error in Function REPORT_MISSING_RATE : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
 END;

      -- ---------------------------------------------
      -- Reporting of the Missing UOM Conversion Rates
      -- ---------------------------------------------

FUNCTION REPORT_MISSING_UOM_RATE RETURN NUMBER IS

  CURSOR Missing_UOM_Conversion IS
  SELECT distinct inventory_item_id,
	 from_uom_code from_unit,
	 to_uom_code to_unit
    FROM isc_dbi_fte_uom_rates
   WHERE conversion_rate between -99999 and -99995;

  CURSOR Missing_Transaction_UOM IS
  SELECT name
    FROM wsh_new_deliveries
   WHERE delivery_id IN (SELECT distinct delivery_id
                           FROM isc_dbi_tmp_del_legs
		          WHERE (freight_weight_trx is not null and weight_uom_code is null)
		             OR (freight_volume_trx is not null and volume_uom_code is null));

  l_record			Missing_UOM_Conversion%ROWTYPE;
  l_uom_record			Missing_Transaction_UOM%ROWTYPE;
  l_total			NUMBER;

BEGIN

  l_total := 0;
  OPEN Missing_UOM_Conversion;
  FETCH Missing_UOM_Conversion INTO l_record;

  IF Missing_UOM_Conversion%ROWCOUNT <> 0 THEN
     BIS_COLLECTION_UTILITIES.Put_Line('Collection failed because there are missing UOM conversion rates.');
     BIS_COLLECTION_UTILITIES.Put_Line(fnd_message.get_string('BIS', 'BIS_DBI_UOM_NO_LOAD'));

     OPI_DBI_REP_UOM_PKG.err_msg_header;
     WHILE Missing_UOM_Conversion%FOUND LOOP
  	l_total := l_total + 1;

          OPI_DBI_REP_UOM_PKG.err_msg_missing_uoms(
		nvl(l_record.from_unit,' '),
		nvl(l_record.to_unit,' '));

	  FETCH Missing_UOM_Conversion INTO l_record;
     END LOOP;
     OPI_DBI_REP_UOM_PKG.Err_Msg_Footer;

  ELSE -- Missing_UOM_Conversion%ROWCOUNT = 0
    BIS_COLLECTION_UTILITIES.Put_Line(' ');
    BIS_COLLECTION_UTILITIES.Put_Line('	    THERE IS NO MISSING UOM CONVERSION RATE	   ');
    BIS_COLLECTION_UTILITIES.Put_Line('+---------------------------------------------------------------------------+');
    BIS_COLLECTION_UTILITIES.Put_Line(' ');
  END IF; -- Missing_UOM_Conversion%ROWCOUNT <> 0

  CLOSE Missing_UOM_Conversion;

  OPEN Missing_Transaction_UOM;
  FETCH Missing_Transaction_UOM INTO l_uom_record;

  IF Missing_Transaction_UOM%ROWCOUNT <> 0 THEN
     BIS_COLLECTION_UTILITIES.Put_Line('Collection failed because there are missing UOM conversion rates.');
     g_errbuf := g_errbuf || 'There are transactions that do not have transaction UOMs.';

     BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
     BIS_COLLECTION_UTILITIES.Put_Line_Out(fnd_message.get_string('ISC', 'ISC_DBI_UOM_NO_LOAD'));
     BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
     BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(fnd_message.get_string('ISC','ISC_DBI_DELIVERY_NAME'),21,' '));

     BIS_COLLECTION_UTILITIES.Put_Line_Out('----------------');

     WHILE Missing_Transaction_UOM%FOUND LOOP
  	l_total := l_total + 1;
	BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(l_uom_record.name,16,' '));

	FETCH Missing_Transaction_UOM INTO l_uom_record;
     END LOOP;
     BIS_COLLECTION_UTILITIES.Put_Line_Out('+---------------------------------------------------------------------------+');
  END IF;

  CLOSE Missing_Transaction_UOM;

  RETURN(l_total);

  EXCEPTION
   WHEN OTHERS THEN
    g_errbuf  := 'Error in Function REPORT_MISSING_UOM_RATE : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
 END;

      -- --------------
      -- DANGLING_CHECK
      -- --------------

FUNCTION DANGLING_CHECK_INIT RETURN NUMBER IS

l_time_danling	NUMBER;
l_item_count	NUMBER;
l_miss_conv	NUMBER;
l_miss_uom	NUMBER;
l_dangling	NUMBER;

BEGIN

  l_time_danling := 0;
  l_item_count := 0;
  l_miss_conv := 0;
  l_miss_uom := 0;
  l_dangling := 0;

  -- ----------------------------------------------------------
  -- Identify Missing Currency Rate
  -- When there is missing rate, exit the collection with error
  -- ----------------------------------------------------------

  BIS_COLLECTION_UTILITIES.put_line(' ');
  BIS_COLLECTION_UTILITIES.put_line('Identifying the missing currency conversion rates');
  FII_UTIL.Start_Timer;

  l_miss_conv := REPORT_MISSING_RATE;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Completed missing currency check in');

  IF (l_miss_conv = -1) THEN
     return(-1);
  ELSIF (l_miss_conv > 0) THEN
     g_errbuf  := g_errbuf || 'Collection aborted due to missing currency conversion rates. ';
     l_dangling := -999;
  END IF;

  -- --------------------------------------------------------------
  -- Identify Missing UOM Rate
  -- When there is missing UOM rate, exit the collection with error
  -- --------------------------------------------------------------

  BIS_COLLECTION_UTILITIES.put_line(' ');
  BIS_COLLECTION_UTILITIES.put_line('Identifying the missing UOM conversion rates');
  FII_UTIL.Start_Timer;

  l_miss_uom := REPORT_MISSING_UOM_RATE;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Completed missing UOM check in');

  IF (l_miss_uom = -1) THEN
     return(-1);
  ELSIF (l_miss_uom > 0) THEN
     g_errbuf  := g_errbuf || 'Collection aborted due to missing UOM conversion rates. ';
     l_dangling := -999;
  END IF;

  -- ---------------------
  -- CHECK_TIME_CONTINUITY
  -- ---------------------

  BIS_COLLECTION_UTILITIES.Put_Line(' ');
  BIS_COLLECTION_UTILITIES.put_line('Checking Time Continuity');

  l_time_danling := CHECK_TIME_CONTINUITY_INIT;

  IF (l_time_danling = -1) THEN
     return(-1);
  ELSIF (l_time_danling = -999) THEN
     g_errbuf  := g_errbuf || 'Collection aborted due to dangling keys for time dimension. ';
     l_dangling := -999;
  END IF;

  -- -------------------------------------
  -- Check Dangling Key for Item Dimension
  -- -------------------------------------

  BIS_COLLECTION_UTILITIES.put_line(' ');
  BIS_COLLECTION_UTILITIES.put_line('Identifying the dangling items');

  FII_UTIL.Start_Timer;

  l_item_count := IDENTIFY_DANGLING_ITEM;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Identified '||l_item_count||' dangling items in');

  IF (l_item_count = -1)
     THEN return(-1);
  ELSIF (l_item_count > 0) THEN
     g_errbuf  := g_errbuf || 'Collection aborted due to dangling items. ';
     l_dangling := -999;
  END IF;

  IF (l_dangling = -999) THEN
     return(-1);
  END IF;

  RETURN(1);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function DANGLING_CHECK_INIT : '||sqlerrm;
    g_retcode	:= sqlcode;
    RETURN(-1);

END dangling_check_init;

FUNCTION DANGLING_CHECK_DETAIL_ICRL RETURN NUMBER IS

  l_time_danling	NUMBER;
  l_item_count		NUMBER;
  l_dangling		NUMBER;

BEGIN

  l_time_danling := 0;
  l_item_count := 0;
  l_dangling := 0;

  -- ---------------------
  -- CHECK_TIME_CONTINUITY
  -- ---------------------

  BIS_COLLECTION_UTILITIES.Put_Line(' ');
  BIS_COLLECTION_UTILITIES.put_line('Checking Time Continuity');

  l_time_danling := CHECK_TIME_CONTINUITY_DETAIL;

  IF (l_time_danling = -1) THEN
     return(-1);
  ELSIF (l_time_danling = -999) THEN
     g_errbuf  := g_errbuf || 'Collection aborted due to dangling keys for time dimension. ';
     l_dangling := -999;
  END IF;

  -- -------------------------------------
  -- Check Dangling Key for Item Dimension
  -- -------------------------------------

  BIS_COLLECTION_UTILITIES.put_line(' ');
  BIS_COLLECTION_UTILITIES.put_line('Identifying the dangling items');

  FII_UTIL.Start_Timer;

  l_item_count := IDENTIFY_DANGLING_ITEM;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Identified '||l_item_count||' dangling items in');

  IF (l_item_count = -1) THEN
     return(-1);
  ELSIF (l_item_count > 0) THEN
     g_errbuf  := g_errbuf || 'Collection aborted due to dangling items. ';
     l_dangling := -999;
  END IF;

  IF (l_dangling = -999) THEN
     return(-1);
  END IF;

  RETURN(1);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function DANGLING_CHECK_DETAIL_ICRL : '||sqlerrm;
    g_retcode	:= sqlcode;
    RETURN(-1);

END dangling_check_detail_icrl;


FUNCTION DANGLING_CHECK_LEG_STOP_ICRL RETURN NUMBER IS

  l_time_danling	NUMBER;
  l_miss_conv		NUMBER;
  l_miss_uom		NUMBER;
  l_dangling		NUMBER;

BEGIN

  l_time_danling := 0;
  l_miss_conv := 0;
  l_miss_uom := 0;
  l_dangling := 0;

      -- ----------------------------------------------------------
      -- Identify Missing Currency Rate
      -- When there is missing rate, exit the collection with error
      -- ----------------------------------------------------------

     BIS_COLLECTION_UTILITIES.put_line(' ');
     BIS_COLLECTION_UTILITIES.put_line('Identifying the missing currency conversion rates');
     FII_UTIL.Start_Timer;

     l_miss_conv := REPORT_MISSING_RATE;

     FII_UTIL.Stop_Timer;
     FII_UTIL.Print_Timer('Completed missing currency check in');

     IF (l_miss_conv = -1) THEN
        return(-1);
     ELSIF (l_miss_conv > 0) THEN
        g_errbuf  := g_errbuf || 'Collection aborted due to missing currency conversion rates. ';
        l_dangling := -999;
     END IF;

      -- --------------------------------------------------------------
      -- Identify Missing UOM Rate
      -- When there is missing UOM rate, exit the collection with error
      -- --------------------------------------------------------------

     BIS_COLLECTION_UTILITIES.put_line(' ');
     BIS_COLLECTION_UTILITIES.put_line('Identifying the missing UOM conversion rates');
     FII_UTIL.Start_Timer;

     l_miss_uom := REPORT_MISSING_UOM_RATE;

     FII_UTIL.Stop_Timer;
     FII_UTIL.Print_Timer('Completed missing UOM check in');

     IF (l_miss_uom = -1) THEN
	return(-1);
     ELSIF (l_miss_uom > 0) THEN
        g_errbuf  := g_errbuf || 'Collection aborted due to missing UOM conversion rates. ';
	l_dangling := -999;
     END IF;

      -- ---------------------
      -- CHECK_TIME_CONTINUITY
      -- ---------------------

     BIS_COLLECTION_UTILITIES.Put_Line(' ');
     BIS_COLLECTION_UTILITIES.put_line('Checking Time Continuity');

      l_time_danling := CHECK_TIME_CONTINUITY_STOP;

     IF (l_time_danling = -1) THEN
        return(-1);
     ELSIF (l_time_danling = -999) THEN
        g_errbuf  := g_errbuf || 'Collection aborted due to dangling keys for time dimension. ';
        l_dangling := -999;
     END IF;

     IF (l_dangling = -999) THEN
        return(-1);
     END IF;

 RETURN(1);

 EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function DANGLING_CHECK_LEG_STOP_ICRL : '||sqlerrm;
    g_retcode	:= sqlcode;
    RETURN(-1);

END dangling_check_leg_stop_icrl;


FUNCTION DANGLING_CHECK_INVOICE_ICRL RETURN NUMBER IS

  l_time_danling	NUMBER;
  l_miss_conv		NUMBER;
  l_dangling		NUMBER;

BEGIN

  l_time_danling := 0;
  l_miss_conv := 0;
  l_dangling := 0;

      -- ----------------------------------------------------------
      -- Identify Missing Currency Rate
      -- When there is missing rate, exit the collection with error
      -- ----------------------------------------------------------

     BIS_COLLECTION_UTILITIES.put_line(' ');
     BIS_COLLECTION_UTILITIES.put_line('Identifying the missing currency conversion rates');
     FII_UTIL.Start_Timer;

     l_miss_conv := REPORT_MISSING_RATE;

     FII_UTIL.Stop_Timer;
     FII_UTIL.Print_Timer('Completed missing currency check in');

     IF (l_miss_conv = -1) THEN
        return(-1);
     ELSIF (l_miss_conv > 0) THEN
        g_errbuf  := g_errbuf || 'Collection aborted due to missing currency conversion rates. ';
        l_dangling := -999;
     END IF;

     IF (l_dangling = -999) THEN
        return(-1);
     END IF;

 RETURN(1);

 EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function DANGLING_CHECK_INVOICE_ICRL : '||sqlerrm;
    g_retcode	:= sqlcode;
    RETURN(-1);

END dangling_check_invoice_icrl;

      -- -----------
      -- INSERT_FACT
      -- -----------

FUNCTION INSERT_FACT RETURN NUMBER IS

  l_detail_count	NUMBER;
  l_leg_count	 	NUMBER;
  l_stop_count		NUMBER;
  l_invoice_count	NUMBER;

BEGIN

 BIS_COLLECTION_UTILITIES.put_line(' ');
 BIS_COLLECTION_UTILITIES.put_line('Inserting data into isc_dbi_del_details_f');
 FII_UTIL.Start_Timer;

  INSERT /*+ APPEND PARALLEL(F) */ INTO ISC_DBI_DEL_DETAILS_F F
     (DELIVERY_DETAIL_ID,
      INVENTORY_ITEM_ID,
      SHIPMENT_DIRECTION,
      ORGANIZATION_ID,
      SUBINVENTORY_CODE,
      TIME_IP_DATE_ID,
      TIME_PR_DATE_ID,
      DELIVERY_ID,
      INITIAL_PICKUP_DATE,
      MOVE_ORDER_LINE_ID,
      PICK_RELEASED_DATE,
      RELEASED_STATUS,
      REQUESTED_QUANTITY,
      REQUESTED_QUANTITY_UOM,
      SHIPPED_QUANTITY,
      WMS_ENABLED_FLAG,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE,
      REQUEST_ID)
  SELECT /*+ PARALLEL(v) */
         v.delivery_detail_id		DELIVERY_DETAIL_ID,
         v.inventory_item_id		INVENTORY_ITEM_ID,
         v.shipment_direction		SHIPMENT_DIRECTION,
         v.organization_id		ORGANIZATION_ID,
         v.subinventory_code		SUBINVENTORY_CODE,
         v.time_ip_date_id		TIME_IP_DATE_ID,
         v.time_pr_date_id		TIME_PR_DATE_ID,
         v.delivery_id			DELIVERY_ID,
         v.initial_pickup_date		INITIAL_PICKUP_DATE,
         v.move_order_line_id		MOVE_ORDER_LINE_ID,
         v.pick_released_date		PICK_RELEASED_DATE,
         v.released_status		RELEASED_STATUS,
         v.requested_quantity		REQUESTED_QUANTITY,
         v.requested_quantity_uom	REQUESTED_QUANTITY_UOM,
         v.shipped_quantity		SHIPPED_QUANTITY,
         v.wms_enabled_flag		WMS_ENABLED_FLAG,
         -1				CREATED_BY,
         sysdate			CREATION_DATE,
         -1				LAST_UPDATED_BY,
         sysdate			LAST_UPDATE_DATE,
         -1				LAST_UPDATE_LOGIN,
         -1				PROGRAM_APPLICATION_ID,
         -1				PROGRAM_ID,
         sysdate			PROGRAM_UPDATE_DATE,
         -1				REQUEST_ID
    FROM isc_dbi_tmp_del_details v;

 l_detail_count := sql%rowcount;
 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Inserted '|| l_detail_count ||' rows into isc_dbi_del_details_f in');

 BIS_COLLECTION_UTILITIES.put_line(' ');
 BIS_COLLECTION_UTILITIES.put_line('Inserting data into isc_dbi_del_legs_f');
 FII_UTIL.Start_Timer;

  INSERT /*+ APPEND PARALLEL(F) */ INTO ISC_DBI_DEL_LEGS_F F
     (DELIVERY_LEG_ID,
      CARRIER_ID,
      SHIPMENT_DIRECTION,
      MODE_OF_TRANSPORT,
      ORGANIZATION_ID,
      SERVICE_LEVEL,
      TIME_INIT_DEPT_DATE_ID,
      DELIVERY_ID,
      DROP_OFF_STOP_ID,
      FREIGHT_COST_F,
      FREIGHT_COST_G,
      FREIGHT_COST_G1,
      FREIGHT_VOLUME_G,
      FREIGHT_VOLUME_TRX,
      FREIGHT_WEIGHT_G,
      FREIGHT_WEIGHT_TRX,
      PICK_UP_STOP_ID,
      TRIP_ID,
      VOLUME_UOM_CODE,
      WEIGHT_UOM_CODE,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE,
      REQUEST_ID,
      DELIVERY_TYPE,
      PARENT_DELIVERY_LEG_ID)
  SELECT /*+ PARALLEL(v) */
         v.delivery_leg_id 		DELIVERY_LEG_ID,
	 v.carrier_id			CARRIER_ID,
 	 v.shipment_direction		SHIPMENT_DIRECTION,
 	 v.mode_of_transport		MODE_OF_TRANSPORT,
  	 v.organization_id		ORGANIZATION_ID,
  	 v.service_level		SERVICE_LEVEL,
 	 v.time_init_dept_date_id	TIME_INIT_DEPT_DATE_ID,
 	 v.delivery_id			DELIVERY_ID,
 	 v.drop_off_stop_id		DROP_OFF_STOP_ID,
 	 v.freight_cost_trx
         * nvl(v.conversion_rate, curr.trx_wh_rate) FREIGHT_COST_F,
 	 v.freight_cost_trx
         * decode(v.trx_currency_code, g_global_currency, 1, curr.trx_wh_rate * curr.wh_prim_rate)	FREIGHT_COST_G,
 	 v.freight_cost_trx
         * decode(v.trx_currency_code, g_sec_global_currency, 1, curr.trx_wh_rate * curr.wh_sec_rate) FREIGHT_COST_G1,
 	 v.freight_volume_trx * v_rates.conversion_rate	FREIGHT_VOLUME_G,
         v.freight_volume_trx		FREIGHT_VOLUME_TRX,
 	 v.freight_weight_trx * w_rates.conversion_rate	FREIGHT_WEIGHT_G,
         v.freight_weight_trx		FREIGHT_WEIGHT_TRX,
 	 v.pick_up_stop_id		PICK_UP_STOP_ID,
 	 v.trip_id			TRIP_ID,
 	 v.volume_uom_code		VOLUME_UOM_CODE,
 	 v.weight_uom_code		WEIGHT_UOM_CODE,
	 -1				CREATED_BY,
 	 sysdate			CREATION_DATE,
	 -1				LAST_UPDATED_BY,
	 sysdate			LAST_UPDATE_DATE,
 	 -1 				LAST_UPDATE_LOGIN,
 	 -1				PROGRAM_APPLICATION_ID,
 	 -1				PROGRAM_ID,
 	 sysdate			PROGRAM_UPDATE_DATE,
	 -1				REQUEST_ID,
         v.delivery_type                DELIVERY_TYPE,
         v.parent_delivery_leg_id       PARENT_DELIVERY_LEG_ID
    FROM isc_dbi_tmp_del_legs v,
         isc_dbi_fte_curr_rates curr,
         isc_dbi_fte_uom_rates w_rates,
         isc_dbi_fte_uom_rates v_rates
   WHERE v.weight_uom_code = w_rates.from_uom_code(+)
     AND w_rates.measure_code(+) = 'WT'
     AND v.volume_uom_code = v_rates.from_uom_code(+)
     AND v_rates.measure_code(+) = 'VOL'
     AND v.trx_currency_code = curr.trx_currency_code(+)
     AND v.wh_currency_code = curr.wh_currency_code(+)
     AND v.conversion_date = curr.conversion_date(+)
     AND v.conversion_type_code = curr.conversion_type_code(+);

 l_leg_count := sql%rowcount;
 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Inserted '|| l_leg_count ||' rows into isc_dbi_del_legs_f in');

 BIS_COLLECTION_UTILITIES.put_line(' ');
 BIS_COLLECTION_UTILITIES.put_line('Inserting data into isc_dbi_trip_stops_f');
 FII_UTIL.Start_Timer;

  INSERT /*+ APPEND PARALLEL(F) */ INTO ISC_DBI_TRIP_STOPS_F F
     (STOP_ID,
      CARRIER_ID,
      MODE_OF_TRANSPORT,
      SERVICE_LEVEL,
      TIME_ACTL_ARRL_DATE_ID,
      TIME_INIT_DEPT_DATE_ID,
      TIME_PLN_ARRL_DATE_ID,
      ACTUAL_ARRIVAL_DATE,
      ACTUAL_DEPARTURE_DATE,
      DISTANCE_TO_NEXT_STOP_G,
      DISTANCE_TO_NEXT_STOP_TRX,
      DISTANCE_UOM_CODE,
      PLANNED_ARRIVAL_DATE,
      STOP_RANK,
      STOP_SEQUENCE_NUMBER,
      TRIP_FREIGHT_COST_G,
      TRIP_FREIGHT_COST_G1,
      TRIP_ID,
      ULTIMATE_STOP_SEQUENCE_NUMBER,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE,
      REQUEST_ID)
  SELECT /*+ PARALLEL(v) PARALLEL(itr) */
         v.stop_id			STOP_ID,
         v.carrier_id			CARRIER_ID,
         v.mode_of_transport		MODE_OF_TRANSPORT,
         v.service_level		SERVICE_LEVEL,
         v.time_actl_arrl_date_id	TIME_ACTL_ARRL_DATE_ID,
         v.time_init_dept_date_id	TIME_INIT_DEPT_DATE_ID,
         v.time_pln_arrl_date_id	TIME_PLN_ARRL_DATE_ID,
         v.actual_arrival_date		ACTUAL_ARRIVAL_DATE,
         v.actual_departure_date	ACTUAL_DEPARTURE_DATE,
         v.distance_to_next_stop_trx * d_rates.conversion_rate	DISTANCE_TO_NEXT_STOP_G,
         v.distance_to_next_stop_trx 	DISTANCE_TO_NEXT_STOP_TRX,
         v.distance_uom_code		DISTANCE_UOM_CODE,
         v.planned_arrival_date		PLANNED_ARRIVAL_DATE,
         v.stop_rank			STOP_RANK,
         v.stop_sequence_number		STOP_SEQUENCE_NUMBER,
         itr.trip_freight_cost_g	TRIP_FREIGHT_COST_G,
         itr.trip_freight_cost_g1	TRIP_FREIGHT_COST_G1,
         v.trip_id			TRIP_ID,
         v.ultimate_stop_sequence_number	ULTIMATE_STOP_SEQUENCE_NUMBER,
         -1				CREATED_BY,
         sysdate			CREATION_DATE,
         -1				LAST_UPDATED_BY,
         sysdate			LAST_UPDATE_DATE,
         -1				LAST_UPDATE_LOGIN,
         -1				PROGRAM_APPLICATION_ID,
         -1				PROGRAM_ID,
         sysdate			PROGRAM_UPDATE_DATE,
         -1				REQUEST_ID
    FROM isc_dbi_tmp_trip_stops v,
         (select /*+ PARALLEL(tmp) */ trip_id,
                 sum(decode(tmp.parent_delivery_leg_id,null,freight_cost_trx,decode(tmp.delivery_type,'CONSOLIDATION',freight_cost_trx,0))
                 * decode(tmp.trx_currency_code,g_global_currency,1,curr.trx_wh_rate * curr.wh_prim_rate)) TRIP_FREIGHT_COST_G,
                 sum(decode(tmp.parent_delivery_leg_id,null,freight_cost_trx,decode(tmp.delivery_type,'CONSOLIDATION',freight_cost_trx,0))
                 * decode(tmp.trx_currency_code,g_sec_global_currency,1,curr.trx_wh_rate*curr.wh_sec_rate)) TRIP_FREIGHT_COST_G1
            from isc_dbi_tmp_del_legs tmp,
                 isc_dbi_fte_curr_rates curr
           where tmp.trx_currency_code = curr.trx_currency_code(+)
             and tmp.wh_currency_code = curr.wh_currency_code(+)
             and tmp.conversion_date = curr.conversion_date(+)
             and tmp.conversion_type_code = curr.conversion_type_code(+)
           group by trip_id) itr,
         isc_dbi_fte_uom_rates d_rates
   WHERE v.trip_id = itr.trip_id
     AND v.distance_uom_code = d_rates.from_uom_code(+)
     AND d_rates.measure_code(+) = 'DIS';

 l_stop_count := sql%rowcount;
 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Inserted '|| l_stop_count ||' rows into isc_dbi_trip_stops_f in');

 BIS_COLLECTION_UTILITIES.put_line(' ');
 BIS_COLLECTION_UTILITIES.put_line('Inserting data into isc_dbi_fte_invoices_f');
 FII_UTIL.Start_Timer;

  INSERT /*+ APPEND PARALLEL(F) */ INTO ISC_DBI_FTE_INVOICES_F F
     (INVOICE_HEADER_ID,
      CARRIER_ID,
      MODE_OF_TRANSPORT,
      ORG_ID,
      SERVICE_LEVEL,
      SUPPLIER_ID,
      APPROVED_AMT_F,
      APPROVED_AMT_G,
      APPROVED_AMT_G1,
      BILL_AMT_F,
      BILL_AMT_G,
      BILL_AMT_G1,
      BILL_NUMBER,
      BILL_STATUS,
      BILL_TYPE,
      BOL,
      DELIVERY_LEG_ID,
      TRIP_ID,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE,
      REQUEST_ID)
  SELECT /*+ PARALLEL(v) PARALLEL(curr) */
         v.invoice_header_id					INVOICE_HEADER_ID,
         v.carrier_id						CARRIER_ID,
         v.mode_of_transport					MODE_OF_TRANSPORT,
         v.org_id						ORG_ID,
         v.service_level					SERVICE_LEVEL,
         v.supplier_id						SUPPLIER_ID,
         v.approved_amt_trx * curr.trx_wh_rate			APPROVED_AMT_F,
         v.approved_amt_trx
         * decode(v.trx_currency_code, g_global_currency, 1,
                  curr.trx_wh_rate * curr.wh_prim_rate)		APPROVED_AMT_G,
         v.approved_amt_trx
         * decode(v.trx_currency_code, g_sec_global_currency, 1,
                  curr.trx_wh_rate * curr.wh_sec_rate)		APPROVED_AMT_G1,
         v.bill_amt_trx * curr.trx_wh_rate			BILL_AMT_F,
         v.bill_amt_trx
         * decode(v.trx_currency_code, g_global_currency, 1,
                  curr.trx_wh_rate * curr.wh_prim_rate)		BILL_AMT_G,
         v.bill_amt_trx
         * decode(v.trx_currency_code, g_sec_global_currency, 1,
                  curr.trx_wh_rate * curr.wh_sec_rate)		BILL_AMT_G1,
         v.bill_number						BILL_NUMBER,
         v.bill_status						BILL_STATUS,
         v.bill_type						BILL_TYPE,
         v.bol							BOL,
         v.delivery_leg_id					DELIVERY_LEG_ID,
         v.trip_id						TRIP_ID,
         -1							CREATED_BY,
         sysdate						CREATION_DATE,
         -1							LAST_UPDATED_BY,
         sysdate						LAST_UPDATE_DATE,
         -1							LAST_UPDATE_LOGIN,
         -1							PROGRAM_APPLICATION_ID,
         -1							PROGRAM_ID,
         sysdate						PROGRAM_UPDATE_DATE,
         -1							REQUEST_ID
     FROM isc_dbi_tmp_fte_invoices v,
          isc_dbi_fte_curr_rates curr
    WHERE v.trx_currency_code = curr.trx_currency_code
      AND v.wh_currency_code = curr.wh_currency_code
      AND v.conversion_date = curr.conversion_date
      AND v.conversion_type_code = curr.conversion_type_code;

 l_invoice_count := sql%rowcount;
 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Inserted '|| l_invoice_count ||' rows into isc_dbi_fte_invoices_f in');

 COMMIT;
 RETURN(l_detail_count + l_leg_count + l_stop_count + l_invoice_count);

 EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function INSERT_FACT : '||sqlerrm;
    g_retcode	:= sqlcode;
    RETURN(-1);

END insert_fact;

      -- -----------
      -- MERGE_FACT
      -- -----------

FUNCTION MERGE_DETAIL_FACT(p_batch number) RETURN NUMBER IS

  l_count		NUMBER;
  l_total		NUMBER;
  l_max_batch		NUMBER;
  l_date		DATE;

BEGIN

  l_total := 0;
  l_date := to_date('01/01/0001','DD/MM/YYYY');

  FOR v_batch_id IN 1..p_batch
  LOOP
     FII_UTIL.Start_Timer;
     BIS_COLLECTION_UTILITIES.put_line('Merging batch '||v_batch_id);

     l_count := 0;

     MERGE INTO ISC_DBI_DEL_DETAILS_F f
     USING
     (select new.* from isc_dbi_tmp_del_details new, isc_dbi_del_details_f old
       where new.delivery_detail_id = old.delivery_detail_id(+)
         and new.batch_id = v_batch_id
	 and (old.delivery_detail_id is null
              or new.inventory_item_id <> old.inventory_item_id
              or new.shipment_direction <> old.shipment_direction
              or new.organization_id <> old.organization_id
              or nvl(new.subinventory_code, -1) <> nvl(old.subinventory_code, -1)
              or nvl(new.delivery_id, -1) <> nvl(old.delivery_id, -1)
              or nvl(new.initial_pickup_date,l_date) <> nvl(old.initial_pickup_date,l_date)
              or nvl(new.move_order_line_id,-1) <> nvl(old.move_order_line_id,-1)
              or nvl(new.pick_released_date,l_date) <> nvl(old.pick_released_date,l_date)
              or nvl(new.released_status,'na') <> nvl(old.released_status,'na')
              or new.requested_quantity <> old.requested_quantity
              or new.requested_quantity_uom <> old.requested_quantity_uom
              or nvl(new.shipped_quantity,-1) <> nvl(old.shipped_quantity,-1)
              or nvl(new.wms_enabled_flag,'na') <> nvl(old.wms_enabled_flag,'na'))) v
     ON (f.delivery_detail_id = v.delivery_detail_id)
     WHEN MATCHED THEN UPDATE SET
      f.inventory_item_id = v.inventory_item_id,
      f.shipment_direction = v.shipment_direction,
      f.organization_id = v.organization_id,
      f.subinventory_code = v.subinventory_code,
      f.time_ip_date_id = v.time_ip_date_id,
      f.time_pr_date_id = v.time_pr_date_id,
      f.delivery_id = v.delivery_id,
      f.initial_pickup_date = v.initial_pickup_date,
      f.move_order_line_id = v.move_order_line_id,
      f.pick_released_date = v.pick_released_date,
      f.released_status = v.released_status,
      f.requested_quantity = v.requested_quantity,
      f.requested_quantity_uom = v.requested_quantity_uom,
      f.shipped_quantity = v.shipped_quantity,
      f.wms_enabled_flag = v.wms_enabled_flag,
      f.last_update_date = g_incre_start_date
     WHEN NOT MATCHED THEN INSERT(
      f.delivery_detail_id,
      f.inventory_item_id,
      f.shipment_direction,
      f.organization_id,
      f.subinventory_code,
      f.time_ip_date_id,
      f.time_pr_date_id,
      f.delivery_id,
      f.initial_pickup_date,
      f.move_order_line_id,
      f.pick_released_date,
      f.released_status,
      f.requested_quantity,
      f.requested_quantity_uom,
      f.shipped_quantity,
      f.wms_enabled_flag,
      f.created_by,
      f.creation_date,
      f.last_updated_by,
      f.last_update_date,
      f.last_update_login,
      f.program_application_id,
      f.program_id,
      f.program_update_date,
      f.request_id)
     VALUES (
      v.delivery_detail_id,
      v.inventory_item_id,
      v.shipment_direction,
      v.organization_id,
      v.subinventory_code,
      v.time_ip_date_id,
      v.time_pr_date_id,
      v.delivery_id,
      v.initial_pickup_date,
      v.move_order_line_id,
      v.pick_released_date,
      v.released_status,
      v.requested_quantity,
      v.requested_quantity_uom,
      v.shipped_quantity,
      v.wms_enabled_flag,
      -1,
      g_incre_start_date,
      -1,
      g_incre_start_date,
      -1,
      -1,
      -1,
      g_incre_start_date,
      -1);

     l_count := sql%rowcount;
     l_total := l_total + l_count;
     COMMIT;
     FII_UTIL.Stop_Timer;
     FII_UTIL.Print_Timer('Merged '||l_count|| ' rows in ');

  END LOOP;

  RETURN(l_total);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function MERGE_DETAIL_FACT : '||sqlerrm;
    g_retcode	:= sqlcode;
    RETURN(-1);

END merge_detail_fact;

FUNCTION MERGE_LEG_STOP_FACT(p_batch number) RETURN NUMBER IS

  l_count		NUMBER;
  l_total		NUMBER;
  l_max_batch		NUMBER;
  l_date		DATE;

BEGIN

  l_total := 0;
  l_date := to_date('01/01/0001','DD/MM/YYYY');

  FOR v_batch_id IN 1..p_batch
  LOOP
     FII_UTIL.Start_Timer;
     BIS_COLLECTION_UTILITIES.put_line('Merging batch '||v_batch_id);

     l_count := 0;

     MERGE INTO ISC_DBI_DEL_LEGS_F f
     USING
     (select new.*
        from (select tmp.delivery_leg_id 		DELIVERY_LEG_ID,
                   tmp.carrier_id			CARRIER_ID,
                   tmp.shipment_direction		SHIPMENT_DIRECTION,
                   tmp.mode_of_transport		MODE_OF_TRANSPORT,
                   tmp.organization_id			ORGANIZATION_ID,
                   tmp.service_level			SERVICE_LEVEL,
                   tmp.time_init_dept_date_id		TIME_INIT_DEPT_DATE_ID,
                   tmp.delivery_id			DELIVERY_ID,
                   tmp.drop_off_stop_id			DROP_OFF_STOP_ID,
                   tmp.freight_cost_trx
                   * nvl(tmp.conversion_rate, curr.trx_wh_rate) FREIGHT_COST_F,
                   tmp.freight_cost_trx
                   * decode(tmp.trx_currency_code, g_global_currency, 1, curr.trx_wh_rate * curr.wh_prim_rate)	FREIGHT_COST_G,
                   tmp.freight_cost_trx
                   * decode(tmp.trx_currency_code, g_sec_global_currency, 1, curr.trx_wh_rate * curr.wh_sec_rate) FREIGHT_COST_G1,
                   tmp.freight_volume_trx * v_rates.conversion_rate	FREIGHT_VOLUME_G,
                   tmp.freight_volume_trx				FREIGHT_VOLUME_TRX,
                   tmp.freight_weight_trx * w_rates.conversion_rate	FREIGHT_WEIGHT_G,
                   tmp.freight_weight_trx				FREIGHT_WEIGHT_TRX,
                   tmp.pick_up_stop_id			PICK_UP_STOP_ID,
                   tmp.trip_id				TRIP_ID,
                   tmp.volume_uom_code			VOLUME_UOM_CODE,
                   tmp.weight_uom_code			WEIGHT_UOM_CODE,
                   tmp.delivery_type                    DELIVERY_TYPE,
                   tmp.parent_delivery_leg_id           PARENT_DELIVERY_LEG_ID
              from isc_dbi_tmp_del_legs tmp,
                   isc_dbi_fte_curr_rates curr,
                   isc_dbi_fte_uom_rates w_rates,
                   isc_dbi_fte_uom_rates v_rates
             where tmp.weight_uom_code = w_rates.from_uom_code(+)
               and w_rates.measure_code(+) = 'WT'
               and tmp.volume_uom_code = v_rates.from_uom_code(+)
               and v_rates.measure_code(+) = 'VOL'
               and tmp.trx_currency_code = curr.trx_currency_code(+)
               and tmp.wh_currency_code = curr.wh_currency_code(+)
               and tmp.conversion_date = curr.conversion_date(+)
               and tmp.conversion_type_code = curr.conversion_type_code(+)
               and tmp.batch_id = v_batch_id) new, isc_dbi_del_legs_f old
       where new.delivery_leg_id = old.delivery_leg_id(+)
	 and (old.delivery_leg_id is null
              or new.carrier_id <> old.carrier_id
              or new.shipment_direction <> old.shipment_direction
              or new.mode_of_transport <> old.mode_of_transport
              or new.organization_id <> old.organization_id
              or new.service_level <> old.service_level
              or new.time_init_dept_date_id <> old.time_init_dept_date_id
              or new.delivery_id <> old.delivery_id
              or new.drop_off_stop_id <> old.drop_off_stop_id
              or nvl(new.freight_cost_f,-1) <> nvl(old.freight_cost_f,-1)
              or nvl(new.freight_cost_g,-1) <> nvl(old.freight_cost_g,-1)
              or nvl(new.freight_cost_g1,-1) <> nvl(old.freight_cost_g1,-1)
              or nvl(new.freight_volume_g,-1) <> nvl(old.freight_volume_g,-1)
              or nvl(new.freight_volume_trx,-1) <> nvl(old.freight_volume_trx,-1)
              or nvl(new.freight_weight_g,-1) <> nvl(old.freight_weight_g,-1)
              or nvl(new.freight_weight_trx,-1) <> nvl(old.freight_weight_trx,-1)
              or new.pick_up_stop_id <> old.pick_up_stop_id
              or new.trip_id <> old.trip_id
              or nvl(new.volume_uom_code,'na') <> nvl(old.volume_uom_code,'na')
              or nvl(new.weight_uom_code,'na') <> nvl(old.weight_uom_code,'na')
              or nvl(new.delivery_type,'na') <> nvl(old.delivery_type,'na')
              or nvl(new.parent_delivery_leg_id,-1) <> nvl(old.parent_delivery_leg_id,-1))) v
     ON (f.delivery_leg_id = v.delivery_leg_id)
     WHEN MATCHED THEN UPDATE SET
      f.carrier_id = v.carrier_id,
      f.shipment_direction = v.shipment_direction,
      f.mode_of_transport = v.mode_of_transport,
      f.organization_id = v.organization_id,
      f.service_level = v.service_level,
      f.time_init_dept_date_id = v.time_init_dept_date_id,
      f.delivery_id = v.delivery_id,
      f.drop_off_stop_id = v.drop_off_stop_id,
      f.freight_cost_f = v.freight_cost_f,
      f.freight_cost_g = v.freight_cost_g,
      f.freight_cost_g1 = v.freight_cost_g1,
      f.freight_volume_g = v.freight_volume_g,
      f.freight_volume_trx = v.freight_volume_trx,
      f.freight_weight_g = v.freight_weight_g,
      f.freight_weight_trx = v.freight_weight_trx,
      f.pick_up_stop_id = v.pick_up_stop_id,
      f.trip_id = v.trip_id,
      f.volume_uom_code = v.volume_uom_code,
      f.weight_uom_code = v.weight_uom_code,
      f.last_update_date = g_incre_start_date,
      f.delivery_type = v.delivery_type,
      f.parent_delivery_leg_id = v.parent_delivery_leg_id
     WHEN NOT MATCHED THEN INSERT(
      f.delivery_leg_id,
      f.carrier_id,
      f.shipment_direction,
      f.mode_of_transport,
      f.organization_id,
      f.service_level,
      f.time_init_dept_date_id,
      f.delivery_id,
      f.drop_off_stop_id,
      f.freight_cost_f,
      f.freight_cost_g,
      f.freight_cost_g1,
      f.freight_volume_g,
      f.freight_volume_trx,
      f.freight_weight_g,
      f.freight_weight_trx,
      f.pick_up_stop_id,
      f.trip_id,
      f.volume_uom_code,
      f.weight_uom_code,
      f.created_by,
      f.creation_date,
      f.last_updated_by,
      f.last_update_date,
      f.last_update_login,
      f.program_application_id,
      f.program_id,
      f.program_update_date,
      f.request_id,
      f.delivery_type,
      f.parent_delivery_leg_id)
     VALUES (
      v.delivery_leg_id,
      v.carrier_id,
      v.shipment_direction,
      v.mode_of_transport,
      v.organization_id,
      v.service_level,
      v.time_init_dept_date_id,
      v.delivery_id,
      v.drop_off_stop_id,
      v.freight_cost_f,
      v.freight_cost_g,
      v.freight_cost_g1,
      v.freight_volume_g,
      v.freight_volume_trx,
      v.freight_weight_g,
      v.freight_weight_trx,
      v.pick_up_stop_id,
      v.trip_id,
      v.volume_uom_code,
      v.weight_uom_code,
      -1,
      g_incre_start_date,
      -1,
      g_incre_start_date,
      -1,
      -1,
      -1,
      g_incre_start_date,
      -1,
      v.delivery_type,
      v.parent_delivery_leg_id);

     MERGE INTO ISC_DBI_TRIP_STOPS_F f
     USING
     (select new.*
        from (select v.stop_id				STOP_ID,
                   v.carrier_id				CARRIER_ID,
                   v.mode_of_transport			MODE_OF_TRANSPORT,
                   v.service_level			SERVICE_LEVEL,
                   v.time_actl_arrl_date_id		TIME_ACTL_ARRL_DATE_ID,
                   v.time_init_dept_date_id		TIME_INIT_DEPT_DATE_ID,
                   v.time_pln_arrl_date_id		TIME_PLN_ARRL_DATE_ID,
                   v.actual_arrival_date		ACTUAL_ARRIVAL_DATE,
                   v.actual_departure_date		ACTUAL_DEPARTURE_DATE,
                   v.distance_to_next_stop_trx * d_rates.conversion_rate	DISTANCE_TO_NEXT_STOP_G,
                   v.distance_to_next_stop_trx 		DISTANCE_TO_NEXT_STOP_TRX,
                   v.distance_uom_code			DISTANCE_UOM_CODE,
                   v.planned_arrival_date		PLANNED_ARRIVAL_DATE,
                   v.stop_rank				STOP_RANK,
                   v.stop_sequence_number		STOP_SEQUENCE_NUMBER,
                   itr.trip_freight_cost_g		TRIP_FREIGHT_COST_G,
                   itr.trip_freight_cost_g1		TRIP_FREIGHT_COST_G1,
                   v.trip_id				TRIP_ID,
                   v.ultimate_stop_sequence_number	ULTIMATE_STOP_SEQUENCE_NUMBER
                from isc_dbi_tmp_trip_stops v,
                    (select trip_id,
                            sum(decode(tmp.parent_delivery_leg_id,null,freight_cost_trx,decode(tmp.delivery_type,'CONSOLIDATION',freight_cost_trx,0))
                            * decode(tmp.trx_currency_code,g_global_currency,1,curr.trx_wh_rate * curr.wh_prim_rate)) TRIP_FREIGHT_COST_G,
                            sum(decode(tmp.parent_delivery_leg_id,null,freight_cost_trx,decode(tmp.delivery_type,'CONSOLIDATION',freight_cost_trx,0))
                            * decode(tmp.trx_currency_code,g_sec_global_currency,1,curr.trx_wh_rate*curr.wh_sec_rate)) TRIP_FREIGHT_COST_G1
                       from isc_dbi_tmp_del_legs tmp,
                            isc_dbi_fte_curr_rates curr
                      where tmp.trx_currency_code = curr.trx_currency_code(+)
                        and tmp.wh_currency_code = curr.wh_currency_code(+)
                        and tmp.conversion_date = curr.conversion_date(+)
                        and tmp.conversion_type_code = curr.conversion_type_code(+)
                      group by trip_id) itr,
                     isc_dbi_fte_uom_rates d_rates
               where v.trip_id = itr.trip_id
                 and v.distance_uom_code = d_rates.from_uom_code(+)
                 and d_rates.measure_code(+) = 'DIS'
                 and v.batch_id = v_batch_id) new, isc_dbi_trip_stops_f old
       where new.stop_id = old.stop_id(+)
	 and (old.stop_id is null
              or new.carrier_id <> old.carrier_id
              or new.mode_of_transport <> old.mode_of_transport
              or new.service_level <> old.service_level
              or new.time_init_dept_date_id <> old.time_init_dept_date_id
              or nvl(new.actual_arrival_date, l_date) <> nvl(old.actual_arrival_date, l_date)
              or nvl(new.actual_departure_date, l_date) <> nvl(old.actual_departure_date, l_date)
              or nvl(new.distance_to_next_stop_g, -1) <> nvl(old.distance_to_next_stop_g, -1)
              or nvl(new.distance_to_next_stop_trx, -1) <> nvl(old.distance_to_next_stop_trx, -1)
              or nvl(new.distance_uom_code, 'na') <> nvl(old.distance_uom_code, 'na')
              or new.planned_arrival_date <> old.planned_arrival_date
              or new.stop_rank <> old.stop_rank
              or new.stop_sequence_number <> old.stop_sequence_number
              or nvl(new.trip_freight_cost_g, -1) <> nvl(old.trip_freight_cost_g, -1)
              or nvl(new.trip_freight_cost_g1, -1) <> nvl(old.trip_freight_cost_g1, -1)
              or new.trip_id <> old.trip_id
              or new.ultimate_stop_sequence_number <> old.ultimate_stop_sequence_number)) v
     ON (f.stop_id = v.stop_id)
     WHEN MATCHED THEN UPDATE SET
      f.carrier_id = v.carrier_id,
      f.mode_of_transport = v.mode_of_transport,
      f.service_level = v.service_level,
      f.time_actl_arrl_date_id = v.time_actl_arrl_date_id,
      f.time_init_dept_date_id = v.time_init_dept_date_id,
      f.time_pln_arrl_date_id = v.time_pln_arrl_date_id,
      f.actual_arrival_date = v.actual_arrival_date,
      f.actual_departure_date = v.actual_departure_date,
      f.distance_to_next_stop_g = v.distance_to_next_stop_g,
      f.distance_to_next_stop_trx = v.distance_to_next_stop_trx,
      f.distance_uom_code = v.distance_uom_code,
      f.planned_arrival_date = v.planned_arrival_date,
      f.stop_rank = v.stop_rank,
      f.stop_sequence_number = v.stop_sequence_number,
      f.trip_freight_cost_g = v.trip_freight_cost_g,
      f.trip_freight_cost_g1 = v.trip_freight_cost_g1,
      f.trip_id = v.trip_id,
      f.ultimate_stop_sequence_number = v.ultimate_stop_sequence_number,
      f.last_update_date = g_incre_start_date
     WHEN NOT MATCHED THEN INSERT(
      f.stop_id,
      f.carrier_id,
      f.mode_of_transport,
      f.service_level,
      f.time_actl_arrl_date_id,
      f.time_init_dept_date_id,
      f.time_pln_arrl_date_id,
      f.actual_arrival_date,
      f.actual_departure_date,
      f.distance_to_next_stop_g,
      f.distance_to_next_stop_trx,
      f.distance_uom_code,
      f.planned_arrival_date,
      f.stop_rank,
      f.stop_sequence_number,
      f.trip_freight_cost_g,
      f.trip_freight_cost_g1,
      f.trip_id,
      f.ultimate_stop_sequence_number,
      f.created_by,
      f.creation_date,
      f.last_updated_by,
      f.last_update_date,
      f.last_update_login,
      f.program_application_id,
      f.program_id,
      f.program_update_date,
      f.request_id)
     VALUES (
      v.stop_id,
      v.carrier_id,
      v.mode_of_transport,
      v.service_level,
      v.time_actl_arrl_date_id,
      v.time_init_dept_date_id,
      v.time_pln_arrl_date_id,
      v.actual_arrival_date,
      v.actual_departure_date,
      v.distance_to_next_stop_g,
      v.distance_to_next_stop_trx,
      v.distance_uom_code,
      v.planned_arrival_date,
      v.stop_rank,
      v.stop_sequence_number,
      v.trip_freight_cost_g,
      v.trip_freight_cost_g1,
      v.trip_id,
      v.ultimate_stop_sequence_number,
      -1,
      g_incre_start_date,
      -1,
      g_incre_start_date,
      -1,
      -1,
      -1,
      g_incre_start_date,
      -1);

     l_count := sql%rowcount;
     l_total := l_total + l_count;
     COMMIT;
     FII_UTIL.Stop_Timer;
     FII_UTIL.Print_Timer('Merged '||l_count|| ' rows in ');

  END LOOP;

  RETURN(l_total);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function MERGE_LEG_STOP_FACT : '||sqlerrm;
    g_retcode	:= sqlcode;
    RETURN(-1);

END merge_leg_stop_fact;

FUNCTION MERGE_INVOICE_FACT(p_batch number) RETURN NUMBER IS

  l_count		NUMBER;
  l_total		NUMBER;
  l_max_batch		NUMBER;
  l_date		DATE;

BEGIN

  l_total := 0;
  l_date := to_date('01/01/0001','DD/MM/YYYY');

  FOR v_batch_id IN 1..p_batch
  LOOP
     FII_UTIL.Start_Timer;
     BIS_COLLECTION_UTILITIES.put_line('Merging batch '||v_batch_id);

     l_count := 0;

     MERGE INTO ISC_DBI_FTE_INVOICES_F f
     USING
     (select new.*
        from (select tmp.invoice_header_id					INVOICE_HEADER_ID,
                     tmp.carrier_id						CARRIER_ID,
                     tmp.mode_of_transport					MODE_OF_TRANSPORT,
                     tmp.org_id							ORG_ID,
                     tmp.service_level						SERVICE_LEVEL,
                     tmp.supplier_id						SUPPLIER_ID,
                     tmp.approved_amt_trx * curr.trx_wh_rate			APPROVED_AMT_F,
                     tmp.approved_amt_trx
                     * decode(tmp.trx_currency_code, g_global_currency, 1,
                              curr.trx_wh_rate * curr.wh_prim_rate)		APPROVED_AMT_G,
                     tmp.approved_amt_trx
                     * decode(tmp.trx_currency_code, g_sec_global_currency, 1,
                              curr.trx_wh_rate * curr.wh_sec_rate)		APPROVED_AMT_G1,
                     tmp.bill_amt_trx * curr.trx_wh_rate			BILL_AMT_F,
                     tmp.bill_amt_trx
                     * decode(tmp.trx_currency_code, g_global_currency, 1,
                              curr.trx_wh_rate * curr.wh_prim_rate)		BILL_AMT_G,
                     tmp.bill_amt_trx
                     * decode(tmp.trx_currency_code, g_sec_global_currency, 1,
                              curr.trx_wh_rate * curr.wh_sec_rate)		BILL_AMT_G1,
                     tmp.bill_number						BILL_NUMBER,
                     tmp.bill_status						BILL_STATUS,
                     tmp.bill_type						BILL_TYPE,
                     tmp.bol							BOL,
                     tmp.delivery_leg_id					DELIVERY_LEG_ID,
                     tmp.trip_id						TRIP_ID
                from isc_dbi_tmp_fte_invoices tmp, isc_dbi_fte_curr_rates curr
               where tmp.trx_currency_code = curr.trx_currency_code
                 and tmp.wh_currency_code = curr.wh_currency_code
                 and tmp.conversion_date = curr.conversion_date
                 and tmp.conversion_type_code = curr.conversion_type_code
      	         and tmp.batch_id = v_batch_id) new,
             isc_dbi_fte_invoices_f old
       where new.invoice_header_id = old.invoice_header_id(+)
	 and (old.invoice_header_id is null
              or new.carrier_id <> old.carrier_id
              or new.mode_of_transport <> old.mode_of_transport
              or new.org_id <> old.org_id
              or new.service_level <> old.service_level
              or nvl(new.supplier_id, -1) <> nvl(old.supplier_id, -1)
              or nvl(new.approved_amt_f, -1) <> nvl(old.approved_amt_f, -1)
              or nvl(new.approved_amt_g, -1) <> nvl(old.approved_amt_g, -1)
              or nvl(new.approved_amt_g1, -1) <> nvl(old.approved_amt_g1, -1)
              or nvl(new.bill_amt_f, -1) <> nvl(old.bill_amt_f, -1)
              or nvl(new.bill_amt_g, -1) <> nvl(old.bill_amt_g, -1)
              or nvl(new.bill_amt_g1, -1) <> nvl(old.bill_amt_g1, -1)
              or new.bill_number <> old.bill_number
              or new.bill_status <> old.bill_status
              or nvl(new.bill_type, 'na') <> nvl(old.bill_type, 'na')
              or nvl(new.bol, 'na') <> nvl(old.bol,'na')
              or nvl(new.delivery_leg_id, -1) <> nvl(old.delivery_leg_id, -1)
              or new.trip_id <> old.trip_id)) v
     ON (f.invoice_header_id = v.invoice_header_id)
     WHEN MATCHED THEN UPDATE SET
      f.carrier_id = v.carrier_id,
      f.mode_of_transport = v.mode_of_transport,
      f.org_id = v.org_id,
      f.service_level = v.service_level,
      f.supplier_id = v.supplier_id,
      f.approved_amt_f = v.approved_amt_f,
      f.approved_amt_g = v.approved_amt_g,
      f.approved_amt_g1 = v.approved_amt_g1,
      f.bill_amt_f = v.bill_amt_f,
      f.bill_amt_g = v.bill_amt_g,
      f.bill_amt_g1 = v.bill_amt_g1,
      f.bill_number = v.bill_number,
      f.bill_status = v.bill_status,
      f.bill_type = v.bill_type,
      f.bol = v.bol,
      f.delivery_leg_id = v.delivery_leg_id,
      f.trip_id = v.trip_id,
      f.last_update_date = g_incre_start_date
     WHEN NOT MATCHED THEN INSERT(
      f.invoice_header_id,
      f.carrier_id,
      f.mode_of_transport,
      f.org_id,
      f.service_level,
      f.supplier_id,
      f.approved_amt_f,
      f.approved_amt_g,
      f.approved_amt_g1,
      f.bill_amt_f,
      f.bill_amt_g,
      f.bill_amt_g1,
      f.bill_number,
      f.bill_status,
      f.bill_type,
      f.bol,
      f.delivery_leg_id,
      f.trip_id,
      f.created_by,
      f.creation_date,
      f.last_updated_by,
      f.last_update_date,
      f.last_update_login,
      f.program_application_id,
      f.program_id,
      f.program_update_date,
      f.request_id)
     VALUES (
      v.invoice_header_id,
      v.carrier_id,
      v.mode_of_transport,
      v.org_id,
      v.service_level,
      v.supplier_id,
      v.approved_amt_f,
      v.approved_amt_g,
      v.approved_amt_g1,
      v.bill_amt_f,
      v.bill_amt_g,
      v.bill_amt_g1,
      v.bill_number,
      v.bill_status,
      v.bill_type,
      v.bol,
      v.delivery_leg_id,
      v.trip_id,
      -1,
      g_incre_start_date,
      -1,
      g_incre_start_date,
      -1,
      -1,
      -1,
      g_incre_start_date,
      -1);

     l_count := sql%rowcount;
     l_total := l_total + l_count;
     COMMIT;
     FII_UTIL.Stop_Timer;
     FII_UTIL.Print_Timer('Merged '||l_count|| ' rows in ');

  END LOOP;

  RETURN(l_total);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function MERGE_INVOICE_FACT : '||sqlerrm;
    g_retcode	:= sqlcode;
    RETURN(-1);

END merge_invoice_fact;

FUNCTION WRAPUP RETURN NUMBER IS

BEGIN

      -- ------------------------
      -- Truncate temp tables
      -- ------------------------

  BIS_COLLECTION_UTILITIES.put_line('Truncating the temp tables');
  FII_UTIL.Start_Timer;

  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_TMP_WDD_LOG';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_TMP_WTS_LOG';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_TMP_FIH_LOG';

  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_TMP_DEL_DETAILS';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_TMP_DEL_LEGS';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_TMP_TRIP_STOPS';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_TMP_FTE_INVOICES';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_FTE_CURR_RATES';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_FTE_UOM_RATES';

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Truncated the temp tables in');
  BIS_COLLECTION_UTILITIES.Put_Line(' ');

      -- ----------------------------------------------
      -- No exception raised so far.  Successful.  Call
      -- Wrapup to commit and insert messages into logs
      -- ----------------------------------------------

  BIS_COLLECTION_UTILITIES.WRAPUP(
  TRUE,
  g_row_count,
  NULL,
  ISC_DBI_WSH_FTE_OBJECTS_C.g_push_from_date,
  ISC_DBI_WSH_FTE_OBJECTS_C.g_push_to_date
  );

  RETURN (1);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function WRAPUP : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
END wrapup;

      ---------------------
      -- Public Procedures
      ---------------------

Procedure load_facts(errbuf		IN OUT NOCOPY VARCHAR2,
                    retcode		IN OUT NOCOPY VARCHAR2) IS

  l_failure		EXCEPTION;
  l_start		DATE;
  l_end			DATE;
  l_period_from		DATE;
  l_period_to		DATE;
  l_row_count		NUMBER;

BEGIN

  errbuf := NULL;
  retcode := '0';
  g_load_mode := 'INITIAL';

 BIS_COLLECTION_UTILITIES.Put_Line(' ');
 BIS_COLLECTION_UTILITIES.put_line('Begin the ' || g_load_mode || ' load');

  IF (NOT BIS_COLLECTION_UTILITIES.setup('ISC_DBI_WSH_FTE_F')) THEN
     RAISE_APPLICATION_ERROR (-20000,'Error in SETUP: ' || errbuf);
     return;
  END IF;

  IF (CHECK_SETUP = -1)
     THEN RAISE l_failure;
  END IF;

  IF (GET_REPORTING_UOM = -1)
     THEN RAISE l_failure;
  END IF;

  IF (SET_WMS_PTS_GSD = -1)
     THEN RAISE l_failure;
  END IF;

  ISC_DBI_WSH_FTE_OBJECTS_C.g_push_from_date := g_global_start_date;
  ISC_DBI_WSH_FTE_OBJECTS_C.g_push_to_date := sysdate;

 BIS_COLLECTION_UTILITIES.put_line( 'The collection date range is from '||
	to_char(g_push_from_date,'MM/DD/YYYY HH24:MI:SS')||' to '||
	to_char(g_push_to_date,'MM/DD/YYYY HH24:MI:SS'));
 BIS_COLLECTION_UTILITIES.put_line(' ');

  EXECUTE IMMEDIATE 'alter session set hash_area_size=104857600';
  EXECUTE IMMEDIATE 'alter session set sort_area_size=104857600';

  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_WDD_CHANGE_LOG';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_WTS_CHANGE_LOG';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_FIH_CHANGE_LOG';

      --  -----------------------------
      --  Load Data into staging tables
      --  -----------------------------

  l_row_count := IDENTIFY_CHANGE_INIT;

  IF (l_row_count = -1)
     THEN RAISE l_failure;
  ELSIF (l_row_count = 0) THEN

    -- Fix bug 4150188
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line('Truncating the fact tables');
    FII_UTIL.Start_Timer;

     EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_DEL_DETAILS_F';
     EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_DEL_LEGS_F';
     EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_TRIP_STOPS_F';
     EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_FTE_INVOICES_F';
     EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_FTE_PARAMETERS';

    FII_UTIL.Stop_Timer;
    FII_UTIL.Print_Timer('Truncated the fact tables in');
     g_row_count := 0;

  ELSE

      -- --------------
      -- Analyze tables
      -- --------------

    BIS_COLLECTION_UTILITIES.Put_Line(' ');
    BIS_COLLECTION_UTILITIES.Put_Line('Analyzing temp tables');
    FII_UTIL.Start_Timer;

     FND_STATS.GATHER_TABLE_STATS(OWNNAME => g_isc_schema,
    			       TABNAME => 'ISC_DBI_TMP_DEL_DETAILS');
     FND_STATS.GATHER_TABLE_STATS(OWNNAME => g_isc_schema,
    			       TABNAME => 'ISC_DBI_TMP_DEL_LEGS');
     FND_STATS.GATHER_TABLE_STATS(OWNNAME => g_isc_schema,
   			       TABNAME => 'ISC_DBI_TMP_TRIP_STOPS');
     FND_STATS.GATHER_TABLE_STATS(OWNNAME => g_isc_schema,
   			       TABNAME => 'ISC_DBI_TMP_FTE_INVOICES');
     FND_STATS.GATHER_TABLE_STATS(OWNNAME => g_isc_schema,
   			       TABNAME => 'ISC_DBI_FTE_CURR_RATES');
     FND_STATS.GATHER_TABLE_STATS(OWNNAME => g_isc_schema,
   			       TABNAME => 'ISC_DBI_FTE_UOM_RATES');

    FII_UTIL.Stop_Timer;
    FII_UTIL.Print_Timer('Analyzed the temp tables in ');

     IF (DANGLING_CHECK_INIT = -1) THEN
        RAISE l_failure;
     END IF;

      --  ----------------------------------------
      --  Truncate base summaries for initial load
      --  ----------------------------------------

    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line('Truncating the fact tables');
    FII_UTIL.Start_Timer;

     EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_DEL_DETAILS_F';
     EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_DEL_LEGS_F';
     EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_TRIP_STOPS_F';
     EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_FTE_INVOICES_F';
     EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_FTE_PARAMETERS';

    FII_UTIL.Stop_Timer;
    FII_UTIL.Print_Timer('Truncated the fact tables in');

     --  --------------------------------------------
     --  Update Parameter Table
     --  --------------------------------------------

     IF (UPDATE_PARAMETER_TABLE = -1) THEN
        RAISE l_failure;
     END IF;

      --  -------------------------------
      --  Insert data into base summaries
      --  -------------------------------

     g_row_count := Insert_fact;

     IF (g_row_count = -1) THEN
        RAISE l_failure;
     END IF;

  END IF;

  IF (WRAPUP = -1) THEN
     RAISE l_failure;
  END IF;

  retcode := g_retcode;
  errbuf := g_errbuf;

  EXCEPTION

  WHEN L_FAILURE THEN
    ROLLBACK;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line(g_errbuf);
    retcode := -1;
    errbuf := g_errbuf;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    g_row_count,
    g_errbuf,
    ISC_DBI_WSH_FTE_OBJECTS_C.g_push_from_date,
    ISC_DBI_WSH_FTE_OBJECTS_C.g_push_to_date
    );

  WHEN OTHERS THEN
    ROLLBACK;
    g_errbuf := sqlerrm ||' - '||sqlcode;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line('Other errors : '|| g_errbuf);
    retcode := -1;
    errbuf := g_errbuf;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    g_row_count,
    g_errbuf,
    ISC_DBI_WSH_FTE_OBJECTS_C.g_push_from_date,
    ISC_DBI_WSH_FTE_OBJECTS_C.g_push_to_date
    );

END load_facts;

Procedure update_detail_fact(errbuf		IN OUT NOCOPY VARCHAR2,
                             retcode		IN OUT NOCOPY VARCHAR2) IS

  l_failure		EXCEPTION;
  l_row_count		NUMBER;

BEGIN
  errbuf  := NULL;
  retcode := '0';
  g_load_mode := 'INCREMENTAL';
  l_row_count := 0;

  BIS_COLLECTION_UTILITIES.Put_Line(' ');
  BIS_COLLECTION_UTILITIES.put_line('Begin the ' || g_load_mode || ' load');

  IF (NOT BIS_COLLECTION_UTILITIES.setup('ISC_DBI_DEL_DETAILS_F_INC')) THEN
     RAISE_APPLICATION_ERROR (-20000,'Error in SETUP: ' || errbuf);
     return;
  END IF;

  ISC_DBI_WSH_FTE_OBJECTS_C.g_push_from_date := null;
  ISC_DBI_WSH_FTE_OBJECTS_C.g_push_to_date := sysdate;

  IF (CHECK_SETUP = -1)
     THEN RAISE l_failure;
  END IF;

  IF (SET_WMS_PTS_GSD = -1)
     THEN RAISE l_failure;
  END IF;

  --  --------------------------------------------
  --  Identify Change for Delivery Details
  --  --------------------------------------------

  BIS_COLLECTION_UTILITIES.put_line('Identifying changed records');

  g_incre_start_date := sysdate;
  BIS_COLLECTION_UTILITIES.put_line('Last updated date is '|| to_char(g_incre_start_date,'MM/DD/YYYY HH24:MI:SS'));

  l_row_count := IDENTIFY_CHANGE_DETAIL_ICRL;

  IF (l_row_count = -1) THEN
     RAISE l_failure;
  ELSIF (l_row_count = 0) THEN
     g_row_count := 0;
  ELSE

     BIS_COLLECTION_UTILITIES.Put_Line(' ');
     BIS_COLLECTION_UTILITIES.Put_Line('Analyzing temp tables');
     FII_UTIL.Start_Timer;

     FND_STATS.GATHER_TABLE_STATS(OWNNAME => g_isc_schema,
			          TABNAME => 'ISC_DBI_TMP_DEL_DETAILS');

     FII_UTIL.Stop_Timer;
     FII_UTIL.Print_Timer('Analyzed the temp tables in ');

     --  --------------------------------------------
     --  Dangling Checks
     --  --------------------------------------------

     IF (DANGLING_CHECK_DETAIL_ICRL = -1) THEN
        RAISE l_failure;
     END IF;

     --  --------------------------------------------
     --  Update Parameter Table
     --  --------------------------------------------

     IF (UPDATE_PARAMETER_TABLE = -1) THEN
        RAISE l_failure;
     END IF;

     --  --------------------------------------------
     --  Merge data into Sum2 table
     --  --------------------------------------------

     BIS_COLLECTION_UTILITIES.put_line(' ');
     BIS_COLLECTION_UTILITIES.put_line('Merging data to fact tables');

     g_row_count := Merge_Detail_Fact(ceil(l_row_count/g_batch_size));

     BIS_COLLECTION_UTILITIES.put_line('Merged '||nvl(g_row_count,0)||' rows into the fact table');

     IF (g_row_count = -1) THEN
        RAISE l_failure;
     END IF;

  END IF;

      -- -------------------------------------------------
      -- Delete rows from change log tables base on rowid
      -- -------------------------------------------------

  BIS_COLLECTION_UTILITIES.put_line('Deleting rows from log tables');
  FII_UTIL.Start_Timer;

  DELETE FROM ISC_DBI_WDD_CHANGE_LOG
   WHERE rowid IN (select log_rowid from isc_dbi_tmp_wdd_log);
--     AND last_update_date < g_incre_start_date;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Deleted ' || sql%rowcount || ' rows from ISC_DBI_WDD_CHANGE_LOG in');
  COMMIT;

  IF (WRAPUP = -1) THEN
     RAISE l_failure;
  END IF;

  retcode := g_retcode;
  errbuf := g_errbuf;

EXCEPTION

  WHEN L_FAILURE THEN
    ROLLBACK;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line(g_errbuf);
    retcode := -1;
    errbuf := g_errbuf;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    g_row_count,
    g_errbuf,
    ISC_DBI_WSH_FTE_OBJECTS_C.g_push_from_date,
    ISC_DBI_WSH_FTE_OBJECTS_C.g_push_to_date
    );

  WHEN OTHERS THEN
    ROLLBACK;
    g_errbuf := sqlerrm ||' - '||sqlcode;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line('Other errors : '|| g_errbuf);
    retcode := -1;
    errbuf := g_errbuf;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    g_row_count,
    g_errbuf,
    ISC_DBI_WSH_FTE_OBJECTS_C.g_push_from_date,
    ISC_DBI_WSH_FTE_OBJECTS_C.g_push_to_date
    );

END update_detail_fact;

Procedure update_leg_stop_fact(errbuf			IN OUT NOCOPY VARCHAR2,
                      retcode			IN OUT NOCOPY VARCHAR2) IS

l_failure		EXCEPTION;
l_start			DATE;
l_end			DATE;
l_period_from		DATE;
l_period_to		DATE;
l_row_count		NUMBER;

BEGIN
  errbuf  := NULL;
  retcode := '0';
  g_load_mode := 'INCREMENTAL';
  l_row_count := 0;

 BIS_COLLECTION_UTILITIES.Put_Line(' ');
 BIS_COLLECTION_UTILITIES.put_line('Begin the ' || g_load_mode || ' load');

  IF (NOT BIS_COLLECTION_UTILITIES.setup('ISC_DBI_LEG_STOP_F_INC')) THEN
     RAISE_APPLICATION_ERROR (-20000,'Error in SETUP: ' || errbuf);
     return;
  END IF;

  ISC_DBI_WSH_FTE_OBJECTS_C.g_push_from_date := null;
  ISC_DBI_WSH_FTE_OBJECTS_C.g_push_to_date := sysdate;

  IF (CHECK_SETUP = -1)
     THEN RAISE l_failure;
  END IF;

  IF (GET_REPORTING_UOM = -1)
     THEN RAISE l_failure;
  END IF;

      --  ------------------------------------------------
      --  Identify Change for Delivery Legs and Trip Stops
      --  ------------------------------------------------

 BIS_COLLECTION_UTILITIES.put_line('Identifying changed records');

  g_incre_start_date := sysdate;
 BIS_COLLECTION_UTILITIES.put_line('Last updated date is '|| to_char(g_incre_start_date,'MM/DD/YYYY HH24:MI:SS'));
  l_row_count := IDENTIFY_CHANGE_STOP_LEG_ICRL;

 IF (l_row_count = -1) THEN
    RAISE l_failure;
 ELSIF (l_row_count = 0) THEN
    g_row_count := 0;
 ELSE
      -- --------------
      -- Analyze tables
      -- --------------

 BIS_COLLECTION_UTILITIES.Put_Line(' ');
 BIS_COLLECTION_UTILITIES.Put_Line('Analyzing temp tables');
 FII_UTIL.Start_Timer;

 FND_STATS.GATHER_TABLE_STATS(OWNNAME => g_isc_schema,
			      TABNAME => 'ISC_DBI_TMP_DEL_LEGS');
 FND_STATS.GATHER_TABLE_STATS(OWNNAME => g_isc_schema,
			      TABNAME => 'ISC_DBI_TMP_TRIP_STOPS');
 FND_STATS.GATHER_TABLE_STATS(OWNNAME => g_isc_schema,
			      TABNAME => 'ISC_DBI_FTE_CURR_RATES');
 FND_STATS.GATHER_TABLE_STATS(OWNNAME => g_isc_schema,
			      TABNAME => 'ISC_DBI_FTE_UOM_RATES');

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Analyzed the temp tables in ');

      --  ---------------------
      --  Dangling Checking
      --  ---------------------

  IF (DANGLING_CHECK_LEG_STOP_ICRL = -1) THEN
     RAISE l_failure;
  END IF;

     --  --------------------------------------------
     --  Update Parameter Table
     --  --------------------------------------------

     IF (UPDATE_PARAMETER_TABLE = -1) THEN
        RAISE l_failure;
     END IF;

      --  --------------------------------------------
      --  Merge data into Sum2 table
      --  --------------------------------------------

 BIS_COLLECTION_UTILITIES.put_line(' ');
 BIS_COLLECTION_UTILITIES.put_line('Merging data to fact tables');

  g_row_count := Merge_Leg_Stop_Fact(ceil(l_row_count/g_batch_size));

 BIS_COLLECTION_UTILITIES.put_line('Merged '||nvl(g_row_count,0)||' rows into the fact tables');

  IF (g_row_count = -1) THEN
     RAISE l_failure;
  END IF;

 END IF;

      -- -------------------------------------------------
      -- Delete rows from change log tables base on rowid
      -- -------------------------------------------------

 BIS_COLLECTION_UTILITIES.put_line('Deleting rows from log tables');
 FII_UTIL.Start_Timer;

  DELETE FROM ISC_DBI_WTS_CHANGE_LOG
   WHERE rowid IN (select log_rowid from isc_dbi_tmp_wts_log);
--     AND last_update_date < g_incre_start_date;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Deleted ' || sql%rowcount || ' rows from ISC_DBI_WTS_CHANGE_LOG in');
 COMMIT;

  IF (WRAPUP = -1) THEN
     RAISE l_failure;
  END IF;

  retcode := g_retcode;
  errbuf := g_errbuf;

 EXCEPTION

  WHEN L_FAILURE THEN
    ROLLBACK;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line(g_errbuf);
    retcode := -1;
    errbuf := g_errbuf;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    g_row_count,
    g_errbuf,
    ISC_DBI_WSH_FTE_OBJECTS_C.g_push_from_date,
    ISC_DBI_WSH_FTE_OBJECTS_C.g_push_to_date
    );

  WHEN OTHERS THEN
    ROLLBACK;
    g_errbuf := sqlerrm ||' - '||sqlcode;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line('Other errors : '|| g_errbuf);
    retcode := -1;
    errbuf := g_errbuf;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    g_row_count,
    g_errbuf,
    ISC_DBI_WSH_FTE_OBJECTS_C.g_push_from_date,
    ISC_DBI_WSH_FTE_OBJECTS_C.g_push_to_date
    );

END update_leg_stop_fact;

Procedure update_invoice_fact(errbuf		IN OUT NOCOPY VARCHAR2,
                      retcode			IN OUT NOCOPY VARCHAR2) IS

l_failure		EXCEPTION;
l_row_count		NUMBER;

BEGIN
  errbuf  := NULL;
  retcode := '0';
  g_load_mode := 'INCREMENTAL';
  l_row_count := 0;

 BIS_COLLECTION_UTILITIES.Put_Line(' ');
 BIS_COLLECTION_UTILITIES.put_line('Begin the ' || g_load_mode || ' load');

  IF (NOT BIS_COLLECTION_UTILITIES.setup('ISC_DBI_FTE_INVOICES_F_INC')) THEN
     RAISE_APPLICATION_ERROR (-20000,'Error in SETUP: ' || errbuf);
     return;
  END IF;

  ISC_DBI_WSH_FTE_OBJECTS_C.g_push_from_date := null;
  ISC_DBI_WSH_FTE_OBJECTS_C.g_push_to_date := sysdate;

  IF (CHECK_SETUP = -1)
     THEN RAISE l_failure;
  END IF;

      --  --------------------------------------------
      --  Identify Change for Invoice Headers
      --  --------------------------------------------

 BIS_COLLECTION_UTILITIES.put_line('Identifying changed records');

  g_incre_start_date := sysdate;
 BIS_COLLECTION_UTILITIES.put_line('Last updated date is '|| to_char(g_incre_start_date,'MM/DD/YYYY HH24:MI:SS'));
  l_row_count := IDENTIFY_CHANGE_INVOICE_ICRL;

 IF (l_row_count = -1) THEN
    RAISE l_failure;
 ELSIF (l_row_count = 0) THEN
    g_row_count := 0;
 ELSE
      -- --------------
      -- Analyze tables
      -- --------------

 BIS_COLLECTION_UTILITIES.Put_Line(' ');
 BIS_COLLECTION_UTILITIES.Put_Line('Analyzing temp tables');
 FII_UTIL.Start_Timer;

 FND_STATS.GATHER_TABLE_STATS(OWNNAME => g_isc_schema,
			      TABNAME => 'ISC_DBI_TMP_FTE_INVOICES');
 FND_STATS.GATHER_TABLE_STATS(OWNNAME => g_isc_schema,
			      TABNAME => 'ISC_DBI_FTE_CURR_RATES');

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Analyzed the temp tables in ');

      --  ---------------------
      --  Dangling Checking
      --  ---------------------

  IF (DANGLING_CHECK_INVOICE_ICRL = -1) THEN
     RAISE l_failure;
  END IF;

     --  --------------------------------------------
     --  Update Parameter Table
     --  --------------------------------------------

     IF (UPDATE_PARAMETER_TABLE = -1) THEN
        RAISE l_failure;
     END IF;

      --  --------------------------------------------
      --  Merge data into Base Summary
      --  --------------------------------------------

 BIS_COLLECTION_UTILITIES.put_line(' ');
 BIS_COLLECTION_UTILITIES.put_line('Merging data to fact tables');

  g_row_count := Merge_Invoice_Fact(ceil(l_row_count/g_batch_size));

 BIS_COLLECTION_UTILITIES.put_line('Merged '||nvl(g_row_count,0)||' rows into the fact tables');

  IF (g_row_count = -1) THEN
     RAISE l_failure;
  END IF;

 END IF;

      -- -------------------------------------------------
      -- Delete rows from change log tables base on rowid
      -- -------------------------------------------------

 BIS_COLLECTION_UTILITIES.put_line('Deleting rows from log tables');

 FII_UTIL.Start_Timer;

  DELETE FROM ISC_DBI_FIH_CHANGE_LOG
   WHERE rowid IN (select log_rowid from isc_dbi_tmp_fih_log);
--     AND last_update_date < g_incre_start_date;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Deleted ' || sql%rowcount || ' rows from ISC_DBI_FIH_CHANGE_LOG in');
 COMMIT;

  IF (WRAPUP = -1) THEN
     RAISE l_failure;
  END IF;

  retcode := g_retcode;
  errbuf := g_errbuf;

 EXCEPTION

  WHEN L_FAILURE THEN
    ROLLBACK;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line(g_errbuf);
    retcode := -1;
    errbuf := g_errbuf;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    g_row_count,
    g_errbuf,
    ISC_DBI_WSH_FTE_OBJECTS_C.g_push_from_date,
    ISC_DBI_WSH_FTE_OBJECTS_C.g_push_to_date
    );

  WHEN OTHERS THEN
    ROLLBACK;
    g_errbuf := sqlerrm ||' - '||sqlcode;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line('Other errors : '|| g_errbuf);
    retcode := -1;
    errbuf := g_errbuf;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    g_row_count,
    g_errbuf,
    ISC_DBI_WSH_FTE_OBJECTS_C.g_push_from_date,
    ISC_DBI_WSH_FTE_OBJECTS_C.g_push_to_date
    );

END update_invoice_fact;

END ISC_DBI_WSH_FTE_OBJECTS_C;

/
