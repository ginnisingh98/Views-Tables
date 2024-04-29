--------------------------------------------------------
--  DDL for Package Body WSH_DELIVERY_LEGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DELIVERY_LEGS_PVT" as
/* $Header: WSHDGTHB.pls 120.2 2007/01/05 01:03:45 jishen noship $ */

--
--  Procedure:		Create_Delivery_Leg
--  Parameters:		All Attributes of a Delivery Leg Record
--  Description:	This procedure will create a delivery leg. It will
--			return to the user the delivery_leg_id. This is a
--			table handler style procedure and no additional
--			validations are provided.
--

  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_DELIVERY_LEGS_PVT';
  --
  PROCEDURE Create_Delivery_Leg (
	   	p_delivery_leg_info     	IN   Delivery_Leg_Rec_Type,
	   	x_rowid                 	OUT NOCOPY   VARCHAR2,
		x_delivery_leg_id       	OUT NOCOPY   NUMBER,
		x_return_status	   	OUT NOCOPY 	VARCHAR2
		) IS

  CURSOR get_rowid  IS
  SELECT rowid
  FROM wsh_delivery_legs
  WHERE delivery_leg_id = x_delivery_leg_id;

  CURSOR get_next_delivery_leg IS
  SELECT wsh_delivery_legs_s.nextval
  FROM sys.dual;

  /* csun 02/25/2002 */
  l_freight_cost_info    WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
  l_row_id               VARCHAR2(30);
  l_freight_cost_id      NUMBER ;
  l_return_status        VARCHAR2(1);
  l_fte_install_status   VARCHAR2(30);
  l_industry             VARCHAR2(30);
  l_leg_id_tab           WSH_UTIL_CORE.id_tab_type;

  others EXCEPTION;
  WSH_CREATE_FC_ERROR    EXCEPTION;
  mark_reprice_error     EXCEPTION;

  l_stop_tab WSH_UTIL_CORE.id_tab_type;  -- DBI Project
  l_dbi_rs               VARCHAR2(1);    -- DBI Project
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_DELIVERY_LEG';
  --
  BEGIN

     --
     --
     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     --
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.push(l_module_name);
     END IF;
     --
     OPEN  get_next_delivery_leg;
     FETCH get_next_delivery_leg INTO x_delivery_leg_id;
     CLOSE get_next_delivery_leg;
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'x_delivery_leg_id',x_delivery_leg_id);
     END IF;
     INSERT INTO wsh_delivery_legs (
            delivery_leg_id
           ,delivery_id
           ,sequence_number
           ,pick_up_stop_id
           ,drop_off_stop_id
           ,gross_weight
           ,net_weight
           ,weight_uom_code
           ,volume
           ,volume_uom_code
           ,creation_date
           ,created_by
           ,last_update_date
           ,last_updated_by
           ,last_update_login
           ,program_application_id
           ,program_id
           ,program_update_date
           ,request_id
		 ,load_tender_status
/* H Integration: datamodel changes wrudge */
	   ,fte_trip_id
	   ,reprice_required
	   ,actual_arrival_date
	   ,actual_departure_date
	   ,actual_receipt_date
	   ,tracking_drilldown_flag
	   ,status_code
	   ,tracking_remarks
	   ,carrier_est_departure_date
	   ,carrier_est_arrival_date
	   ,loading_start_datetime
	   ,loading_end_datetime
	   ,unloading_start_datetime
	   ,unloading_end_datetime
	   ,delivered_quantity
	   ,loaded_quantity
	   ,received_quantity
	   ,origin_stop_id
	   ,destination_stop_id
           ,parent_delivery_leg_id
	) VALUES (
           x_delivery_leg_id
          ,p_delivery_leg_info.delivery_id
          ,nvl(p_delivery_leg_info.sequence_number, -99)
          ,nvl(p_delivery_leg_info.pick_up_stop_id, -99)
          ,nvl(p_delivery_leg_info.drop_off_stop_id, -99)
          ,p_delivery_leg_info.gross_weight
          ,p_delivery_leg_info.net_weight
          ,p_delivery_leg_info.weight_uom_code
          ,p_delivery_leg_info.volume
          ,p_delivery_leg_info.volume_uom_code
          ,nvl(p_delivery_leg_info.creation_date, SYSDATE)
          ,nvl(p_delivery_leg_info.created_by, FND_GLOBAL.USER_ID)
          ,nvl(p_delivery_leg_info.last_update_date, SYSDATE)
          ,nvl(p_delivery_leg_info.last_updated_by, FND_GLOBAL.USER_ID)
          ,nvl(p_delivery_leg_info.last_update_login, FND_GLOBAL.LOGIN_ID)
          ,p_delivery_leg_info.program_application_id
          ,p_delivery_leg_info.program_id
          ,p_delivery_leg_info.program_update_date
          ,p_delivery_leg_info.request_id
      	,nvl(p_delivery_leg_info.load_tender_status, 'N')
/* H Integration: datamodel changes wrudge */
          ,p_delivery_leg_info.fte_trip_id
          ,NVL(p_delivery_leg_info.reprice_required, 'N')
          ,p_delivery_leg_info.actual_arrival_date
          ,p_delivery_leg_info.actual_departure_date
          ,p_delivery_leg_info.actual_receipt_date
          ,p_delivery_leg_info.tracking_drilldown_flag
          ,p_delivery_leg_info.status_code
          ,p_delivery_leg_info.tracking_remarks
          ,p_delivery_leg_info.carrier_est_departure_date
          ,p_delivery_leg_info.carrier_est_arrival_date
          ,p_delivery_leg_info.loading_start_datetime
          ,p_delivery_leg_info.loading_end_datetime
          ,p_delivery_leg_info.unloading_start_datetime
          ,p_delivery_leg_info.unloading_end_datetime
          ,p_delivery_leg_info.delivered_quantity
          ,p_delivery_leg_info.loaded_quantity
          ,p_delivery_leg_info.received_quantity
          ,p_delivery_leg_info.origin_stop_id
          ,p_delivery_leg_info.destination_stop_id
          ,p_delivery_leg_info.parent_delivery_leg_id
		);

 --
        -- DBI Project
        -- Insert into WSH_DELIVERY_LEGS
        -- Call DBI API after the Insert.
        -- This API will also check for DBI Installed or not
	l_stop_tab(1) := p_delivery_leg_info.pick_up_stop_id;
	l_stop_tab(2) := p_delivery_leg_info.drop_off_stop_id;
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail Count -',l_stop_tab.count);
        END IF;
        WSH_INTEGRATION.DBI_Update_Trip_Stop_Log
          (p_stop_id_tab	=> l_stop_tab,
           p_dml_type		=> 'UPDATE',
           x_return_status      => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
	  x_return_status := l_dbi_rs;
          -- just pass this return status to caller API
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          return;
        END IF;
        -- End of Code for DBI Project
 --
     OPEN get_rowid;
     FETCH get_rowid INTO x_rowid;
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Rows inserted',SQL%ROWCOUNT);
        WSH_DEBUG_SV.log(l_module_name,'x_rowid',x_rowid);
     END IF;
     IF (get_rowid%NOTFOUND) THEN
        CLOSE get_rowid;
        RAISE others;
	ELSE
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     END IF;

     CLOSE get_rowid;
/*  H integration: Pricing integration csun
*/
     IF WSH_UTIL_CORE.FTE_Is_Installed = 'Y' THEN
                l_leg_id_tab(1) := x_delivery_leg_id;
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'FTE is installed');
                END IF;
                --
                WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
		         p_entity_type => 'DELIVERY_LEG',
		         p_entity_ids  => l_leg_id_tab,
		         x_return_status => l_return_status);
                IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
                    raise mark_reprice_error;
                END IF;

                l_freight_cost_info.freight_cost_id := NULL;
                l_freight_cost_info.freight_cost_type_id := -1 ;
                l_freight_cost_info.charge_source_code := NULL;
                l_freight_cost_info.line_type_code := 'SUMMARY';
                l_freight_cost_info.unit_amount := NULL;
                l_freight_cost_info.currency_code :=  NULL;
                l_freight_cost_info.delivery_leg_id := x_delivery_leg_id;
                l_freight_cost_info.creation_date := SYSDATE;
                l_freight_cost_info.created_by := FND_GLOBAL.USER_ID;
                l_freight_cost_info.last_update_date := SYSDATE;
                l_freight_cost_info.last_updated_by := FND_GLOBAL.USER_ID;
                --
                WSH_FREIGHT_COSTS_PVT.create_freight_cost(
                      p_freight_cost_info => l_freight_cost_info,
                      x_rowid             => l_row_id,
                      x_freight_cost_id   => l_freight_cost_id,
                      x_return_status     => l_return_status );
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                   raise WSH_CREATE_FC_ERROR;
                END IF;

    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
	EXCEPTION

           WHEN mark_reprice_error THEN
           	FND_MESSAGE.SET_NAME('WSH', 'WSH_REPRICE_REQUIRED_ERR');
	   	WSH_UTIL_CORE.add_message(l_return_status,l_module_name);
		x_return_status := l_return_status;
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'MARK_REPRICE_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:MARK_REPRICE_ERROR');
                END IF;
                --
	   WHEN WSH_CREATE_FC_ERROR THEN
		 wsh_util_core.default_handler('WSH_DELIVERY_LEGS_PVT.CREATE_DELIVERY_LEG',l_module_name);
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		 --
		 IF l_debug_on THEN
		     WSH_DEBUG_SV.logmsg(l_module_name,'WSH_CREATE_FC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_CREATE_FC_ERROR');
		 END IF;
		 --
	   WHEN others THEN
		 wsh_util_core.default_handler('WSH_DELIVERY_LEGS_PVT.CREATE_DELIVERY_LEG',l_module_name);
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
                 END IF;
                 --
  END Create_Delivery_Leg;


--
--  Procedure:		Update_Delivery_Leg
--  Parameters:		All Attributes of a Delivery Leg Record
--  Description:	This procedure will update attributes of a delivery leg.
--			This is a table handler style procedure and no additional
--			validations are provided.
--

  PROCEDURE Update_Delivery_Leg(
		   p_rowid               IN   VARCHAR2 := NULL,
		   p_delivery_leg_info   IN   Delivery_Leg_Rec_Type,
		   x_return_status		OUT NOCOPY 	VARCHAR2
		   ) IS

  CURSOR get_rowid  IS
  SELECT rowid
  FROM wsh_delivery_legs
  WHERE delivery_leg_id = p_delivery_leg_info.delivery_leg_id;

  l_rowid VARCHAR2(30);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_DELIVERY_LEG';
--
  BEGIN
	--
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
	END IF;
	--
	IF (p_rowid IS NULL) THEN
        OPEN get_rowid;
        FETCH get_rowid INTO l_rowid;
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_rowid',l_rowid);
        END IF;
        IF (get_rowid%NOTFOUND) THEN
           CLOSE get_rowid;
           RAISE no_data_found;
        END IF;

        CLOSE get_rowid;
     ELSE
	   l_rowid := p_rowid;
     END IF;

     UPDATE wsh_delivery_legs
     SET
	 delivery_leg_id              =  p_delivery_leg_info.delivery_leg_id
     , delivery_id                	=  p_delivery_leg_info.delivery_id
     ,sequence_number			=  p_delivery_leg_info.sequence_number
     ,pick_up_stop_id     		=  p_delivery_leg_info.pick_up_stop_id
     ,drop_off_stop_id   		=  p_delivery_leg_info.drop_off_stop_id
     ,Gross_Weight               	=  p_delivery_leg_info.Gross_Weight
     ,Net_Weight                 	=  p_delivery_leg_info.Net_Weight
     ,Weight_Uom_Code            	=  p_delivery_leg_info.Weight_Uom_Code
     ,Volume                     	=  p_delivery_leg_info.Volume
     ,Volume_Uom_Code            	=  p_delivery_leg_info.Volume_Uom_Code
     ,Last_Update_Date           	=  NVL(p_delivery_leg_info.Last_Update_Date, sysdate)
     ,Last_Updated_By            	=  NVL(p_delivery_leg_info.Last_Updated_By, fnd_global.user_id)
     ,Last_Update_Login          	=  p_delivery_leg_info.Last_Update_Login
     ,Program_Application_Id     	=  p_delivery_leg_info.Program_Application_Id
     ,Program_Id                 	=  p_delivery_leg_info.Program_Id
     ,Program_Update_Date        	=  p_delivery_leg_info.Program_Update_Date
     ,Request_Id                 	=  p_delivery_leg_info.Request_Id
     ,Load_Tender_Status                =  p_delivery_leg_info.Load_Tender_Status
/* Changes for the shipping data model Bug#1918342*/

     ,SHIPPER_TITLE                     =  p_delivery_leg_info.SHIPPER_TITLE
     ,SHIPPER_PHONE                     =  p_delivery_leg_info.SHIPPER_PHONE
     ,POD_FLAG                          =  p_delivery_leg_info.POD_FLAG
     ,POD_BY                            =  p_delivery_leg_info.POD_BY
     ,POD_DATE                          =  p_delivery_leg_info.POD_DATE
     ,EXPECTED_POD_DATE                 =  p_delivery_leg_info.EXPECTED_POD_DATE
     ,BOOKING_OFFICE                    =  p_delivery_leg_info.BOOKING_OFFICE
     ,SHIPPER_EXPORT_REF                =  p_delivery_leg_info.SHIPPER_EXPORT_REF
     ,CARRIER_EXPORT_REF                =  p_delivery_leg_info.CARRIER_EXPORT_REF
     ,DOC_NOTIFY_PARTY                  =  p_delivery_leg_info.DOC_NOTIFY_PARTY
     ,AETC_NUMBER                       =  p_delivery_leg_info.AETC_NUMBER
     ,SHIPPER_SIGNED_BY                 =  p_delivery_leg_info.SHIPPER_SIGNED_BY
     ,SHIPPER_DATE                      =  p_delivery_leg_info.SHIPPER_DATE
     ,CARRIER_SIGNED_BY                 =  p_delivery_leg_info.CARRIER_SIGNED_BY
     ,CARRIER_DATE                      =  p_delivery_leg_info.CARRIER_DATE
     ,DOC_ISSUE_OFFICE                  =  p_delivery_leg_info.DOC_ISSUE_OFFICE
     ,DOC_ISSUED_BY                     =  p_delivery_leg_info.DOC_ISSUED_BY
     ,DOC_DATE_ISSUED                   =  p_delivery_leg_info.DOC_DATE_ISSUED
     ,SHIPPER_HM_BY                     =  p_delivery_leg_info.SHIPPER_HM_BY
     ,SHIPPER_HM_DATE                   =  p_delivery_leg_info.SHIPPER_HM_DATE
     ,CARRIER_HM_BY                     =  p_delivery_leg_info.CARRIER_HM_BY
     ,CARRIER_HM_DATE                   =  p_delivery_leg_info.CARRIER_HM_DATE
     ,BOOKING_NUMBER                    =  p_delivery_leg_info.BOOKING_NUMBER
     ,PORT_OF_LOADING                   =  P_delivery_leg_info.PORT_OF_LOADING
     ,PORT_OF_DISCHARGE                 =  p_delivery_leg_info.PORT_OF_DISCHARGE
     ,SERVICE_CONTRACT                  =  p_delivery_leg_info.SERVICE_CONTRACT
     ,BILL_FREIGHT_TO                   =  p_delivery_leg_info.BILL_FREIGHT_TO
/* H Integration: datamodel changes wrudge */
     ,FTE_TRIP_ID			=  p_delivery_leg_info.FTE_TRIP_ID
     ,REPRICE_REQUIRED			=  p_delivery_leg_info.REPRICE_REQUIRED
     ,ACTUAL_ARRIVAL_DATE		=  p_delivery_leg_info.ACTUAL_ARRIVAL_DATE
     ,ACTUAL_DEPARTURE_DATE		=  p_delivery_leg_info.ACTUAL_DEPARTURE_DATE
     ,ACTUAL_RECEIPT_DATE		=  p_delivery_leg_info.ACTUAL_RECEIPT_DATE
     ,TRACKING_DRILLDOWN_FLAG		=  p_delivery_leg_info.TRACKING_DRILLDOWN_FLAG
     ,STATUS_CODE			=  p_delivery_leg_info.STATUS_CODE
     ,TRACKING_REMARKS			=  p_delivery_leg_info.TRACKING_REMARKS
     ,CARRIER_EST_DEPARTURE_DATE	=  p_delivery_leg_info.CARRIER_EST_DEPARTURE_DATE
     ,CARRIER_EST_ARRIVAL_DATE		=  p_delivery_leg_info.CARRIER_EST_ARRIVAL_DATE
     ,LOADING_START_DATETIME		=  p_delivery_leg_info.LOADING_START_DATETIME
     ,LOADING_END_DATETIME		=  p_delivery_leg_info.LOADING_END_DATETIME
     ,UNLOADING_START_DATETIME		=  p_delivery_leg_info.UNLOADING_START_DATETIME
     ,UNLOADING_END_DATETIME		=  p_delivery_leg_info.UNLOADING_END_DATETIME
     ,DELIVERED_QUANTITY		=  p_delivery_leg_info.DELIVERED_QUANTITY
     ,LOADED_QUANTITY			=  p_delivery_leg_info.LOADED_QUANTITY
     ,RECEIVED_QUANTITY			=  p_delivery_leg_info.RECEIVED_QUANTITY
     ,ORIGIN_STOP_ID			=  p_delivery_leg_info.ORIGIN_STOP_ID
     ,DESTINATION_STOP_ID		=  p_delivery_leg_info.DESTINATION_STOP_ID
     ,parent_delivery_leg_id		=  p_delivery_leg_info.parent_delivery_leg_id

     WHERE rowid = l_rowid;
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Rows updated',SQL%ROWCOUNT);
     END IF;
     IF (SQL%NOTFOUND) THEN
        RAISE no_data_found;
     ELSE
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     END IF;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
	EXCEPTION
	   WHEN no_data_found THEN
	      FND_MESSAGE.SET_NAME('WSH','WSH_LEG_NOT_FOUND');
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
	      --
	      IF l_debug_on THEN
	          WSH_DEBUG_SV.logmsg(l_module_name,'NO_DATA_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
	      END IF;
	      --
	   WHEN others THEN
		 wsh_util_core.default_handler('WSH_DELIVERY_LEGS_PVT.UPDATE_DELIVERY_LEG',l_module_name);
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
                 END IF;
                 --
  END Update_Delivery_Leg;


--
--  Procedure:		Delete_Delivery_Leg
--  Parameters:		All Attributes of a Delivery Leg Record
--  Description:	This procedure will delete a delivery Leg.
--                      The order in which it looks at the parameters
--                      are:
--                      - p_rowid
--                      - p_delivery_leg_id
--			This is a table handler style procedure and no additional
--			validations are provided.
--

  PROCEDURE Delete_Delivery_Leg
		(p_rowid			IN	VARCHAR2 := NULL,
		 p_delivery_leg_id	IN	NUMBER := NULL,
		 x_return_status 	OUT NOCOPY   VARCHAR2
		) IS

  CURSOR get_del_leg_id_rowid (v_rowid VARCHAR2) IS
  SELECT delivery_leg_id
  FROM   wsh_delivery_legs
  WHERE  rowid = v_rowid;

  CURSOR check_docs (l_leg_id NUMBER) IS
  SELECT entity_id
  FROM   wsh_document_instances
  WHERE  entity_id = l_leg_id AND
	    entity_name = 'WSH_DELIVERY_LEGS' AND
	    status <> 'CANCELLED'
  FOR UPDATE NOWAIT;

  -- DBI Project
  CURSOR get_stop_ids(v_del_leg_id NUMBER) IS
  SELECT pick_up_stop_id,drop_off_stop_id
  FROM   wsh_delivery_legs
  WHERE  delivery_leg_id = v_del_leg_id;

  l_stop_tab WSH_UTIL_CORE.id_tab_type;
  l_dbi_rs         VARCHAR2(1);
  --

  l_delivery_leg_id	NUMBER;
  l_doc_id          NUMBER := NULL;
  l_msg_data        VARCHAR2(2000);
  l_msg_count       NUMBER;
  /* csun 02/25/2002 */
  l_fte_install_status   VARCHAR2(30);
  l_industry             VARCHAR2(30);

  others            EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_DELIVERY_LEG';
--

    --
    -- Get stop and trip information for the delivery leg.
    --
    CURSOR leg_csr (p_delivery_leg_id IN NUMBER)
    IS
        SELECT pick_up_stop_id, drop_off_stop_id, wts1.trip_id,
               nvl(shipment_direction,'O') shipment_direction,
               wt.name trip_name,
               wdl.delivery_id    --J-IB-HEALI
        FROM   wsh_delivery_legs  wdl,
               wsh_trip_stops     wts1,
               wsh_new_deliveries wnd,
               wsh_trips          wt
        WHERE  delivery_leg_id      = p_delivery_leg_id
        AND    wdl.pick_up_stop_id  = wts1.stop_id
        AND    wdl.delivery_id      = wnd.delivery_id
        AND    wts1.trip_id         = wt.trip_id;
    --
    --
    leg_rec leg_csr%ROWTYPE;
    --
    -- Lock trip
    --
    CURSOR lock_trip_csr (p_trip_id in number, p_pickup_stop_id IN NUMBER, p_dropoff_stop_id IN NUMBER)
    IS
        SELECT NVL(wts1.shipments_type_flag,'O') pu_stop_shipments_type_flag,
               NVL(wts2.shipments_type_flag,'O') do_stop_shipments_type_flag,
               NVL(wt.shipments_type_flag,'O')   trip_shipments_type_flag,
               wt.status_Code                    trip_status_Code
        FROM   wsh_trip_stops     wts1,
               wsh_trip_stops     wts2,
               wsh_trips          wt
        WHERE  wt.trip_id          = p_trip_id
        AND    wts1.stop_id        = p_pickup_stop_id
        AND    wts2.stop_id        = p_dropoff_stop_id
        FOR UPDATE OF wt.shipments_type_flag NOWAIT;
    --
    lock_trip_rec lock_trip_csr%ROWTYPE;
    --
    CURSOR dlvy_csr (p_stop_id IN NUMBER)
    IS
	SELECT 1
	FROM   wsh_delivery_legs wdl,
	       wsh_new_deliveries wnd
        WHERE  wdl.delivery_id = wnd.delivery_id
	AND    wnd.status_code IN  ('IT','CL')
	AND    ( wdl.pick_up_stop_id = p_stop_id or wdl.drop_off_stop_id = p_stop_id)
	AND    rownum = 1;
    --
    RECORD_LOCKED          EXCEPTION;
    PRAGMA EXCEPTION_INIT(RECORD_LOCKED, -54);
    --
    l_pu_stop_shipType_flag_orig  VARCHAR2(30);
    l_do_stop_shipType_flag_orig  VARCHAR2(30);
    --
    l_num_warnings                NUMBER := 0;
    l_num_errors                  NUMBER := 0;
    l_return_status               VARCHAR2(10);
    l_stop_rec  WSH_TRIP_STOPS_PVT.TRIP_STOP_REC_TYPE;
    l_pub_stop_rec  WSH_TRIP_STOPS_PUB.TRIP_STOP_PUB_REC_TYPE;
    l_trip_rec  WSH_TRIPS_PVT.TRIP_REC_TYPE;
    --
    l_has_mixed_deliveries  VARCHAR2(10);
    l_stop_opened           VARCHAR2(10);
    l_stop_in_rec           WSH_TRIP_STOPS_VALIDATIONS.chkClose_in_rec_type;
    l_leg_complete	    boolean;

    l_gc3_is_installed      VARCHAR2(1);  --OTM R12

  BEGIN

     --
     --
     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     --
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.push(l_module_name);
         --
         WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
         WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_LEG_ID',P_DELIVERY_LEG_ID);
     END IF;
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     --OTM R12
     l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED; -- this is global variable

     IF l_gc3_is_installed IS NULL THEN
       l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED; -- this is actual function
     END IF;
     --

     IF p_rowid IS NOT NULL THEN
        OPEN  get_del_leg_id_rowid(p_rowid);
        FETCH get_del_leg_id_rowid INTO l_delivery_leg_id;
        CLOSE get_del_leg_id_rowid;
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_delivery_leg_id',l_delivery_leg_id);
        END IF;
     END IF;

     IF l_delivery_leg_id IS NULL THEN
        l_delivery_leg_id := p_delivery_leg_id;
     END IF;

     IF l_delivery_leg_id IS NOT NULL THEN

        -- J-IB-NPARIKH-{
        --
        --
        BEGIN
        --{
            OPEN leg_csr(l_delivery_leg_id);
            --
            FETCH leg_csr INTO leg_rec;
            --
            CLOSE leg_csr;
            --
            -- Lock the trip
            --
            OPEN lock_trip_csr( leg_rec.trip_id, leg_rec.pick_up_stop_id, leg_rec.drop_off_stop_id);
            --
            FETCH lock_trip_csr INTO lock_trip_rec;
            --
            CLOSE lock_trip_csr;
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'leg_rec.shipment_direction',leg_rec.shipment_direction);
                WSH_DEBUG_SV.log(l_module_name,'lock_trip_rec.pu_stop_shipments_type_flag',lock_trip_rec.pu_stop_shipments_type_flag);
                WSH_DEBUG_SV.log(l_module_name,'lock_trip_rec.do_stop_shipments_type_flag',lock_trip_rec.do_stop_shipments_type_flag);
                WSH_DEBUG_SV.log(l_module_name,'lock_trip_rec.trip_status_code',lock_trip_rec.trip_status_code);

            END IF;
            --
            --
            l_pu_stop_shipType_flag_orig := lock_trip_rec.pu_stop_shipments_type_flag;
            l_do_stop_shipType_flag_orig := lock_trip_rec.do_stop_shipments_type_flag;
        --}
        EXCEPTION
        --{
            WHEN RECORD_LOCKED THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_LOCK_FAILED');
                FND_MESSAGE.SET_TOKEN('ENTITY_NAME', leg_rec.trip_name);
                wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
                RAISE FND_API.G_EXC_ERROR;
        --}
        END;
        --
        --
        --
        -- J-IB-NPARIKH-}


-- Check if documents exist for this delivery leg

	   OPEN  check_docs(l_delivery_leg_id);
	   FETCH check_docs INTO l_doc_id;
	   CLOSE check_docs;
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_doc_id',l_doc_id);
           END IF;
	   IF (l_doc_id IS NOT NULL) THEN
		 wsh_document_pvt.cancel_all_documents(
			 p_api_version      => 1.0,
			 x_return_status    => x_return_status,
			 x_msg_count        => l_msg_count,
			 x_msg_data         => l_msg_data,
			 p_entity_name      => 'WSH_DELIVERY_LEGS',
			 p_entity_id        => p_delivery_leg_id);

	      IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		    --
		    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'x_return_status',
                                                             x_return_status);
		        WSH_DEBUG_SV.pop(l_module_name);
		    END IF;
		    --
		    RETURN;
           ELSE
		    l_num_warnings := l_num_warnings + 1;
		    FND_MESSAGE.SET_NAME('WSH','WSH_LEG_DOCS_CANCELLED');
		    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		    wsh_util_core.add_message(x_return_status,l_module_name);
           END IF;

        END IF;

	-- DBI Project
	Open get_stop_ids(l_delivery_leg_id);
	Fetch get_stop_ids into l_stop_tab(1),l_stop_tab(2);
	Close get_stop_ids;
       --

        DELETE FROM wsh_delivery_legs
        WHERE delivery_leg_id = l_delivery_leg_id;


	IF (SQL%NOTFOUND) THEN

	      FND_MESSAGE.SET_NAME('WSH','WSH_LEG_NOT_FOUND');
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'WSH_LEG_NOT_FOUND');
              END IF;

           RAISE FND_API.G_EXC_ERROR;      -- J-IB-NPARIKH
        END IF;


 --
        -- DBI Project
        -- Delete from WSH_DELIVERY_LEGS
        -- Call DBI API after the Update.
        -- This API will also check for DBI Installed or not

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail Count -',l_stop_tab.count);
        END IF;
        WSH_INTEGRATION.DBI_Update_Trip_Stop_Log
          (p_stop_id_tab	=> l_stop_tab,
           p_dml_type		=> 'UPDATE',
           x_return_status      => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
	  x_return_status := l_dbi_rs;
          -- just pass this return status to caller API
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          return;
        END IF;
        -- End of Code for DBI Project
 --

	/*  H integration: Pricing integration csun
            delete corresponding freight cost record, ignore if
            the record is not found
        */
        IF WSH_UTIL_CORE.FTE_Is_Installed = 'Y'
           --OTM R12, allow delete when OTM is installed
           OR l_gc3_is_installed = 'Y'
           --
           THEN
              DELETE FROM wsh_freight_costs
              WHERE delivery_leg_id = l_delivery_leg_id;

              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,
                            'Rows deleted from wsh_freight_costs',SQL%ROWCOUNT);
              END IF;
        END IF;
        --

        -- J-IB-NPARIKH-{
        --
        -- Delivery leg has been deleted.
        -- Recalculate value of shipments type flag for
        -- pickup and dropoff stop
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WWSH_TRIP_STOPS_VALIDATIONS.refreshShipmentsTypeFlag',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        -- Recalculate value of shipments type flag for pickup stop
        --
        WSH_TRIP_STOPS_VALIDATIONS.refreshShipmentsTypeFlag
            (
                p_trip_id               => leg_rec.trip_id,
                p_stop_id               => leg_rec.pick_up_stop_id,
                p_action                => 'UNASSIGN',
                p_shipment_direction    => leg_rec.shipment_direction,
                x_shipments_type_flag   => lock_trip_rec.pu_stop_shipments_type_flag,
                x_return_status         => l_return_status
            );
        --
        wsh_util_core.api_post_call
          (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
          );
        --
        --
           IF   lock_trip_rec.pu_stop_shipments_type_flag <> l_pu_stop_shipType_flag_orig
           THEN
           --{
                    -- Since pickup stop's shipments type flag
                    -- has changed,
                    -- call FTE API for validations
                    -- and then update trip stop with new value.
                    --
                    /* H integration - call Multi Leg FTE */
                    IF (WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y') THEN
                       -- Get pvt type record structure for stop
                       --
                       -- Debug Statements
                       --
                       IF l_debug_on THEN
                          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_GRP.GET_STOP_DETAILS_PVT',WSH_DEBUG_SV.C_PROC_LEVEL);
                       END IF;
                       --
                       wsh_trip_stops_grp.get_stop_details_pvt
                       (p_stop_id => leg_rec.pick_up_stop_id,
                       x_stop_rec => l_stop_rec,
                       x_return_status => l_return_status);
                        --
                        wsh_util_core.api_post_call
                          (
                            p_return_status => l_return_status,
                            x_num_warnings  => l_num_warnings,
                            x_num_errors    => l_num_errors
                          );
                        --
                       --
                       IF l_debug_on THEN
                          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FTE_INTEGRATION.TRIP_STOP_VALIDATIONS',WSH_DEBUG_SV.C_PROC_LEVEL);
                       END IF;
                       --
                       wsh_fte_integration.trip_stop_validations
                       (p_stop_rec => l_stop_rec,
                       p_trip_rec => l_trip_rec,
                       p_action => 'UPDATE',
                       x_return_status => l_return_status);
                        --
                        wsh_util_core.api_post_call
                          (
                            p_return_status => l_return_status,
                            x_num_warnings  => l_num_warnings,
                            x_num_errors    => l_num_errors
                          );
                        --
                    END IF;

                    /* End of H integration - call Multi Leg FTE */
                    update wsh_trip_stops
                    set    shipments_type_flag = lock_trip_rec.pu_stop_shipments_type_flag,    -- J-IB-NPARIKH
                           last_update_date    = SYSDATE,
                           last_updated_by     = FND_GLOBAL.USER_ID,
                           last_update_login   = FND_GLOBAL.LOGIN_ID
                    where  stop_id             = leg_rec.pick_up_stop_id;

                IF  lock_trip_rec.pu_stop_shipments_type_flag = 'I'
                AND l_pu_stop_shipType_flag_orig              = 'M'
                THEN
                --{
                    -- Display a warning whenever stop changes from mixed to inbound
                    FND_MESSAGE.SET_NAME('WSH','WSH_STOP_CHANGE_WARNING');
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    --tkt calling get_namewith caller as FTE as inbound is available only with FTE
                    FND_MESSAGE.SET_TOKEN('STOP_NAME',wsh_trip_stops_pvt.get_name(leg_rec.pick_up_stop_id, 'FTE'));
                    wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
                    --
                    l_num_warnings := l_num_warnings + 1;
                --}
                END IF;
           --}
           END IF;
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WWSH_TRIP_STOPS_VALIDATIONS.refreshShipmentsTypeFlag',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        -- Recalculate value of shipments type flag for dropoff stop
        --
        --
        WSH_TRIP_STOPS_VALIDATIONS.refreshShipmentsTypeFlag
            (
                p_trip_id               => leg_rec.trip_id,
                p_stop_id               => leg_rec.drop_off_stop_id,
                p_action                => 'UNASSIGN',
                p_shipment_direction    => leg_rec.shipment_direction,
                x_shipments_type_flag   => lock_trip_rec.do_stop_shipments_type_flag,
                x_return_status         => l_return_status
            );
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'refreshShipmentsTypeFlag l_return_status',l_return_status);
            WSH_DEBUG_SV.log(l_module_name,'do_stop_shipments_type_flag',lock_trip_rec.do_stop_shipments_type_flag);
        END IF;
        wsh_util_core.api_post_call
          (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
          );
        --
        --
           IF   lock_trip_rec.do_stop_shipments_type_flag <> l_do_stop_shipType_flag_orig
           THEN
           --{
                    -- Since dropoff stop's shipments type flag
                    -- has changed,
                    -- call FTE API for validations
                    -- and then update trip stop with new value.
                    --
                    /* H integration - call Multi Leg FTE */
                    IF (WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y') THEN
                       -- Get pvt type record structure for stop
                       --
                       -- Debug Statements
                       --
                       IF l_debug_on THEN
                          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_GRP.GET_STOP_DETAILS_PVT',WSH_DEBUG_SV.C_PROC_LEVEL);
                       END IF;
                       --
                       wsh_trip_stops_grp.get_stop_details_pvt
                       (p_stop_id => leg_rec.drop_off_stop_id,
                       x_stop_rec => l_stop_rec,
                       x_return_status => l_return_status);
                        --
                        wsh_util_core.api_post_call
                          (
                            p_return_status => l_return_status,
                            x_num_warnings  => l_num_warnings,
                            x_num_errors    => l_num_errors
                          );
                        --
                       --
                       IF l_debug_on THEN
                          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FTE_INTEGRATION.TRIP_STOP_VALIDATIONS',WSH_DEBUG_SV.C_PROC_LEVEL);
                       END IF;
                       --
                       wsh_fte_integration.trip_stop_validations
                       (p_stop_rec => l_stop_rec,
                       p_trip_rec => l_trip_rec,
                       p_action => 'UPDATE',
                       x_return_status => l_return_status);
                        --
                        wsh_util_core.api_post_call
                          (
                            p_return_status => l_return_status,
                            x_num_warnings  => l_num_warnings,
                            x_num_errors    => l_num_errors
                          );
                        --
                    END IF;

                    /* End of H integration - call Multi Leg FTE */
                    update wsh_trip_stops
                    set    shipments_type_flag = lock_trip_rec.do_stop_shipments_type_flag,    -- J-IB-NPARIKH
                           last_update_date    = SYSDATE,
                           last_updated_by     = FND_GLOBAL.USER_ID,
                           last_update_login   = FND_GLOBAL.LOGIN_ID
                    where  stop_id             = leg_rec.drop_off_stop_id;

                IF  lock_trip_rec.do_stop_shipments_type_flag = 'I'
                AND l_do_stop_shipType_flag_orig              = 'M'
                THEN
                --{
                    -- Display a warning whenever stop changes from mixed to inbound
                    FND_MESSAGE.SET_NAME('WSH','WSH_STOP_CHANGE_WARNING');
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    --tkt calling get_namewith caller as FTE as inbound is available only with FTE
                    FND_MESSAGE.SET_TOKEN('STOP_NAME',wsh_trip_stops_pvt.get_name(leg_rec.drop_off_stop_id,'FTE'));
                    wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
                    --
                    l_num_warnings := l_num_warnings + 1;
                --}
                END IF;
           --}
           END IF;
        --
        -- If trip was mixed (before delete of delivery leg)
        -- and pickup or dropoff stop's shipments type flag
        -- have changed, need to re-evaluate trip's shipment
        -- type flag.
        --
        IF lock_trip_rec.trip_shipments_type_flag = 'M'
        --AND (
         --       lock_trip_rec.pu_stop_shipments_type_flag <> l_pu_stop_shipType_flag_orig
         --    OR lock_trip_rec.do_stop_shipments_type_flag <> l_do_stop_shipType_flag_orig
         --   )
        THEN
        --{
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_VALIDATIONS.has_mixed_deliveries',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            --  Check if trip still has both inbound and outbound deliveries
            --
            l_has_mixed_deliveries := WSH_TRIP_VALIDATIONS.has_mixed_deliveries
                                        (
                                          p_trip_id => leg_rec.trip_id
                                        );
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_has_mixed_deliveries',l_has_mixed_deliveries);
            END IF;
            --
            IF l_has_mixed_deliveries <> 'Y'
            THEN
            --{
                -- Trip does not have both inbound and outbound deliveries
                --
                --
                IF l_has_mixed_deliveries = 'NI'
                THEN
                    -- trip has only inbound deliveries
                    --
                    lock_trip_rec.trip_shipments_type_flag := 'I';
                ELSE
                    -- trip has only outbound deliveries
                    --
                    lock_trip_rec.trip_shipments_type_flag := 'O';
                END IF;
                --
                --
                UPDATE WSH_TRIPS
                SET    shipments_type_flag = lock_trip_rec.trip_shipments_type_flag,
                       last_update_date    = SYSDATE,
                       last_updated_by     = FND_GLOBAL.USER_ID,
                       last_update_login   = FND_GLOBAL.LOGIN_ID
                WHERE  trip_id             = leg_rec.trip_id;

                -- To keep the shipments_type_flag of all the
                -- stops in SYNC with the trip
                UPDATE WSH_TRIP_STOPS
                SET    shipments_type_flag = lock_trip_rec.trip_shipments_type_flag,
                       last_update_date    = SYSDATE,
                       last_updated_by     = FND_GLOBAL.USER_ID,
                       last_update_login   = FND_GLOBAL.LOGIN_ID
                WHERE  trip_id             = leg_rec.trip_id
                AND    shipments_type_flag <> lock_trip_rec.trip_shipments_type_flag;

                IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,' Number of rows updated in WTS are',SQL%ROWCOUNT);
                END IF;
            --}
            END IF;
        --}
        END IF;

     ELSE
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Raise others');
           END IF;
	   raise others;
     END IF;
     --
     --
     -- J-IB-HEALI-{
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'calling Process_Leg_Sequence delivery_id',leg_rec.delivery_id);
     END IF;

     WSH_NEW_DELIVERY_ACTIONS.Process_Leg_Sequence
      ( p_delivery_id        => leg_rec.delivery_id,
        p_update_del_flag    => 'Y',
        p_update_leg_flag    => 'N',
        x_leg_complete	     => l_leg_complete,
        x_return_status      => l_return_status);

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Process_Leg_Sequence l_return_status',l_return_status);
      END IF;

      wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors);

     -- J-IB-HEALI-}

     IF l_num_errors > 0
     THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     ELSIF l_num_warnings > 0
     THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
     ELSE
         x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     END IF;
     --
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
	EXCEPTION
        -- J-IB-NPARIKH-{
        WHEN FND_API.G_EXC_ERROR THEN

          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
          END IF;
          --
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

          x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
          END IF;
          --

        -- J-IB-NPARIKH-}

	   WHEN others THEN
		 wsh_util_core.default_handler('WSH_DELIVERY_LEGS_PVT.DELETE_DELIVERY_LEG',l_module_name);
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
                 END IF;
                 --
  END Delete_Delivery_Leg;


--
--  Procedure:		Lock_Delivery_Leg
--  Parameters:		All Attributes of a Delivery Leg Record
--  Description:	This procedure will lock a delivery leg record. It is
--			specifically designed for use by the form.
--
  PROCEDURE Lock_Delivery_Leg (
	  	p_rowid                 IN   VARCHAR2,
	    	p_delivery_leg_info     IN   Delivery_Leg_Rec_Type
		) IS

  CURSOR lock_row IS
  SELECT *
  FROM wsh_delivery_legs
  WHERE rowid = p_rowid
  FOR UPDATE OF delivery_leg_id NOWAIT;

  Recinfo lock_row%ROWTYPE;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_DELIVERY_LEG';
--
  BEGIN

     --
     --
     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     --
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.push(l_module_name);
         --
         WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
     END IF;
     --
     OPEN  lock_row;
     FETCH lock_row INTO Recinfo;
     IF (lock_row%NOTFOUND) THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'FORM_RECORD_DELETED');
        END IF;
        CLOSE lock_row;
        FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
        app_exception.raise_exception;
     END IF;
     CLOSE lock_row;

     IF (
                (Recinfo.Delivery_Leg_Id = p_delivery_leg_info.Delivery_Leg_Id)
         AND    (Recinfo.Delivery_Id = p_delivery_leg_info.Delivery_Id)
         AND    (Recinfo.Sequence_Number = p_delivery_leg_info.Sequence_Number)
         AND 	 (Recinfo.Pick_Up_Stop_Id = p_delivery_leg_info.Pick_Up_Stop_Id)
         AND    (Recinfo.Drop_Off_Stop_Id = p_delivery_leg_info.Drop_Off_Stop_Id)
         AND (  (Recinfo.Gross_Weight = p_delivery_leg_info.Gross_Weight)
              OR (  (Recinfo.Gross_Weight IS NULL)
                  AND  (p_delivery_leg_info.Gross_Weight IS NULL)))
         AND (  (Recinfo.Net_Weight = p_delivery_leg_info.Net_Weight)
              OR (  (Recinfo.Net_Weight IS NULL)
                  AND  (p_delivery_leg_info.Net_Weight IS NULL)))
         AND (  (Recinfo.Weight_Uom_Code = p_delivery_leg_info.Weight_Uom_Code)
              OR (  (Recinfo.Weight_Uom_Code IS NULL)
                  AND  (p_delivery_leg_info.Weight_Uom_Code IS NULL)))
         AND (  (Recinfo.Volume = p_delivery_leg_info.Volume)
              OR (  (Recinfo.Volume IS NULL)
                  AND  (p_delivery_leg_info.Volume IS NULL)))
         AND (  (Recinfo.Volume_Uom_Code = p_delivery_leg_info.Volume_Uom_Code)
              OR (  (Recinfo.Volume_Uom_Code IS NULL)
                  AND  (p_delivery_leg_info.Volume_Uom_Code IS NULL)))
         AND (  (Recinfo.Creation_Date = p_delivery_leg_info.Creation_Date)
              OR (  (Recinfo.Creation_Date IS NULL)
                  AND  (p_delivery_leg_info.Creation_Date IS NULL)))
         AND (  (Recinfo.Created_By = p_delivery_leg_info.Created_By)
              OR (  (Recinfo.Created_By IS NULL)
                  AND  (p_delivery_leg_info.Created_By IS NULL)))
         AND (  (Recinfo.Last_Update_Date = p_delivery_leg_info.Last_Update_Date)
              OR (  (Recinfo.Last_Update_Date IS NULL)
                  AND  (p_delivery_leg_info.Last_Update_Date IS NULL)))
         AND (  (Recinfo.Last_Updated_By = p_delivery_leg_info.Last_Updated_By)
              OR (  (Recinfo.Last_Updated_By IS NULL)
                  AND  (p_delivery_leg_info.Last_Updated_By IS NULL)))
         AND (  (Recinfo.Last_Update_Login = p_delivery_leg_info.Last_Update_Login)
              OR (  (Recinfo.Last_Update_Login IS NULL)
                  AND  (p_delivery_leg_info.Last_Update_Login IS NULL)))
         AND (  (Recinfo.Program_Application_Id = p_delivery_leg_info.Program_Application_Id)
              OR (  (Recinfo.Program_Application_Id IS NULL)
                  AND  (p_delivery_leg_info.Program_Application_Id IS NULL)))
         AND (  (Recinfo.Program_Id = p_delivery_leg_info.Program_Id)
              OR (  (Recinfo.Program_Id IS NULL)
                  AND  (p_delivery_leg_info.Program_Id IS NULL)))
         AND (  (Recinfo.Program_Update_Date = p_delivery_leg_info.Program_Update_Date)
              OR (  (Recinfo.Program_Update_Date IS NULL)
                  AND  (p_delivery_leg_info.Program_Update_Date IS NULL)))
         AND (  (Recinfo.Load_Tender_Status = p_delivery_leg_info.Load_Tender_Status)
              OR (  (Recinfo.Load_Tender_Status IS NULL)
                  AND  (p_delivery_leg_info.Load_Tender_Status IS NULL)))
/*Changes for Shipping Data Model Bug#1918342*/

         AND (  (Recinfo.shipper_title= p_delivery_leg_info.shipper_title)
              OR (  (Recinfo.shipper_title IS NULL)
                  AND  (p_delivery_leg_info.shipper_title IS NULL)))
         AND (  (Recinfo.shipper_phone= p_delivery_leg_info.shipper_phone)
              OR (  (Recinfo.shipper_phone IS NULL)
                  AND  (p_delivery_leg_info.shipper_phone IS NULL)))
         AND (  (Recinfo.pod_flag = p_delivery_leg_info.pod_flag)
              OR (  (Recinfo.pod_flag IS NULL)
                  AND  (p_delivery_leg_info.pod_flag IS NULL)))
         AND (  (Recinfo.pod_by = p_delivery_leg_info.pod_by)
              OR (  (Recinfo.pod_by IS NULL)
                  AND  (p_delivery_leg_info.pod_by IS NULL)))
         AND (  (Recinfo.pod_date = p_delivery_leg_info.pod_date)
              OR (  (Recinfo.pod_date IS NULL)
                  AND  (p_delivery_leg_info.pod_date IS NULL)))
         AND (  (Recinfo.expected_pod_date = p_delivery_leg_info.expected_pod_date)
              OR (  (Recinfo.expected_pod_date IS NULL)
                  AND  (p_delivery_leg_info.expected_pod_date IS NULL)))
         AND (  (Recinfo.booking_office = p_delivery_leg_info.booking_office)
              OR (  (Recinfo.booking_office IS NULL)
                  AND  (p_delivery_leg_info.booking_office IS NULL)))
         AND (  (Recinfo.SHIPPER_EXPORT_REF = p_delivery_leg_info.SHIPPER_EXPORT_REF )
              OR (  (Recinfo.SHIPPER_EXPORT_REF IS NULL)
                  AND  (p_delivery_leg_info.SHIPPER_EXPORT_REF IS NULL)))
         AND (  (Recinfo.CARRIER_EXPORT_REF = p_delivery_leg_info.CARRIER_EXPORT_REF )
              OR (  (Recinfo.CARRIER_EXPORT_REF IS NULL)
                  AND  (p_delivery_leg_info.CARRIER_EXPORT_REF IS NULL)))
         AND (  (Recinfo.DOC_NOTIFY_PARTY = p_delivery_leg_info.DOC_NOTIFY_PARTY )
              OR (  (Recinfo.DOC_NOTIFY_PARTY IS NULL)
                  AND  (p_delivery_leg_info.DOC_NOTIFY_PARTY IS NULL)))
         AND (  (Recinfo.AETC_NUMBER = p_delivery_leg_info.AETC_NUMBER )
              OR (  (Recinfo.AETC_NUMBER IS NULL)
                  AND  (p_delivery_leg_info.AETC_NUMBER IS NULL)))
         AND (  (Recinfo.SHIPPER_SIGNED_BY = p_delivery_leg_info.SHIPPER_SIGNED_BY )
              OR (  (Recinfo.SHIPPER_SIGNED_BY IS NULL)
                  AND  (p_delivery_leg_info.SHIPPER_SIGNED_BY IS NULL)))
         AND (  (Recinfo.SHIPPER_DATE = p_delivery_leg_info.SHIPPER_DATE)
              OR (  (Recinfo.SHIPPER_DATE IS NULL)
                  AND  (p_delivery_leg_info.SHIPPER_DATE IS NULL)))
         AND (  (Recinfo.CARRIER_SIGNED_BY = p_delivery_leg_info.CARRIER_SIGNED_BY )
              OR (  (Recinfo.CARRIER_SIGNED_BY IS NULL)
                  AND  (p_delivery_leg_info.CARRIER_SIGNED_BY IS NULL)))
         AND (  (Recinfo.CARRIER_DATE = p_delivery_leg_info.CARRIER_DATE )
              OR (  (Recinfo.CARRIER_DATE IS NULL)
                  AND  (p_delivery_leg_info.CARRIER_DATE IS NULL)))
         AND (  (Recinfo.DOC_ISSUE_OFFICE = p_delivery_leg_info.DOC_ISSUE_OFFICE)
              OR (  (Recinfo.DOC_ISSUE_OFFICE IS NULL)
                  AND  (p_delivery_leg_info.DOC_ISSUE_OFFICE IS NULL)))
         AND (  (Recinfo.DOC_ISSUED_BY = p_delivery_leg_info.DOC_ISSUED_BY)
              OR (  (Recinfo.DOC_ISSUED_BY IS NULL)
                  AND  (p_delivery_leg_info.DOC_ISSUED_BY IS NULL)))
         AND (  (Recinfo.DOC_DATE_ISSUED = p_delivery_leg_info.DOC_DATE_ISSUED )
              OR (  (Recinfo.DOC_DATE_ISSUED IS NULL)
                  AND  (p_delivery_leg_info.DOC_DATE_ISSUED IS NULL)))
         AND (  (Recinfo.SHIPPER_HM_BY = p_delivery_leg_info.SHIPPER_HM_BY )
              OR (  (Recinfo.SHIPPER_HM_BY IS NULL)
                  AND  (p_delivery_leg_info.SHIPPER_HM_BY IS NULL)))
         AND (  (Recinfo.SHIPPER_HM_DATE = p_delivery_leg_info.SHIPPER_HM_DATE )
              OR (  (Recinfo.SHIPPER_HM_DATE IS NULL)
                  AND  (p_delivery_leg_info.SHIPPER_HM_DATE IS NULL)))
         AND (  (Recinfo.CARRIER_HM_BY = p_delivery_leg_info.CARRIER_HM_BY )
              OR (  (Recinfo.CARRIER_HM_BY IS NULL)
                  AND  (p_delivery_leg_info.CARRIER_HM_BY IS NULL)))
         AND (  (Recinfo.CARRIER_HM_DATE = p_delivery_leg_info.CARRIER_HM_DATE )
              OR (  (Recinfo.CARRIER_HM_DATE IS NULL)
                  AND  (p_delivery_leg_info.CARRIER_HM_DATE IS NULL)))
         AND (  (Recinfo.BOOKING_NUMBER = p_delivery_leg_info.BOOKING_NUMBER )
              OR (  (Recinfo.BOOKING_NUMBER IS NULL)
                  AND  (p_delivery_leg_info.BOOKING_NUMBER IS NULL)))
         AND (  (Recinfo.PORT_OF_LOADING = p_delivery_leg_info.PORT_OF_LOADING )
              OR (  (Recinfo.PORT_OF_LOADING IS NULL)
                  AND  (p_delivery_leg_info.PORT_OF_LOADING IS NULL)))
         AND (  (Recinfo.PORT_OF_DISCHARGE = p_delivery_leg_info.PORT_OF_DISCHARGE )
              OR (  (Recinfo.PORT_OF_DISCHARGE IS NULL)
                  AND  (p_delivery_leg_info.PORT_OF_DISCHARGE IS NULL)))
         AND (  (Recinfo.SERVICE_CONTRACT = p_delivery_leg_info.SERVICE_CONTRACT )
              OR (  (Recinfo.SERVICE_CONTRACT IS NULL)
                  AND  (p_delivery_leg_info.SERVICE_CONTRACT IS NULL)))
         AND (  (Recinfo.BILL_FREIGHT_TO = p_delivery_leg_info.BILL_FREIGHT_TO )
              OR (  (Recinfo.BILL_FREIGHT_TO IS NULL)
                  AND  (p_delivery_leg_info.BILL_FREIGHT_TO IS NULL)))
/* H Integration: datamodel changes wrudge */
         AND (  (Recinfo.FTE_TRIP_ID = p_delivery_leg_info.FTE_TRIP_ID )
              OR (  (Recinfo.FTE_TRIP_ID IS NULL)
                  AND  (p_delivery_leg_info.FTE_TRIP_ID IS NULL)))
         AND (  (Recinfo.REPRICE_REQUIRED = p_delivery_leg_info.REPRICE_REQUIRED )
              OR (  (Recinfo.REPRICE_REQUIRED IS NULL)
                  AND  (p_delivery_leg_info.REPRICE_REQUIRED IS NULL)))
         AND (  (Recinfo.ACTUAL_ARRIVAL_DATE = p_delivery_leg_info.ACTUAL_ARRIVAL_DATE )
              OR (  (Recinfo.ACTUAL_ARRIVAL_DATE IS NULL)
                  AND  (p_delivery_leg_info.ACTUAL_ARRIVAL_DATE IS NULL)))
         AND (  (Recinfo.ACTUAL_DEPARTURE_DATE = p_delivery_leg_info.ACTUAL_DEPARTURE_DATE )
              OR (  (Recinfo.ACTUAL_DEPARTURE_DATE IS NULL)
                  AND  (p_delivery_leg_info.ACTUAL_DEPARTURE_DATE IS NULL)))
         AND (  (Recinfo.ACTUAL_RECEIPT_DATE = p_delivery_leg_info.ACTUAL_RECEIPT_DATE )
              OR (  (Recinfo.ACTUAL_RECEIPT_DATE IS NULL)
                  AND  (p_delivery_leg_info.ACTUAL_RECEIPT_DATE IS NULL)))
         AND (  (Recinfo.TRACKING_DRILLDOWN_FLAG = p_delivery_leg_info.TRACKING_DRILLDOWN_FLAG )
              OR (  (Recinfo.TRACKING_DRILLDOWN_FLAG IS NULL)
                  AND  (p_delivery_leg_info.TRACKING_DRILLDOWN_FLAG IS NULL)))
         AND (  (Recinfo.STATUS_CODE = p_delivery_leg_info.STATUS_CODE )
              OR (  (Recinfo.STATUS_CODE IS NULL)
                  AND  (p_delivery_leg_info.STATUS_CODE IS NULL)))
         AND (  (Recinfo.TRACKING_REMARKS = p_delivery_leg_info.TRACKING_REMARKS )
              OR (  (Recinfo.TRACKING_REMARKS IS NULL)
                  AND  (p_delivery_leg_info.TRACKING_REMARKS IS NULL)))
         AND (  (Recinfo.CARRIER_EST_DEPARTURE_DATE = p_delivery_leg_info.CARRIER_EST_DEPARTURE_DATE )
              OR (  (Recinfo.CARRIER_EST_DEPARTURE_DATE IS NULL)
                  AND  (p_delivery_leg_info.CARRIER_EST_DEPARTURE_DATE IS NULL)))
         AND (  (Recinfo.CARRIER_EST_ARRIVAL_DATE = p_delivery_leg_info.CARRIER_EST_ARRIVAL_DATE )
              OR (  (Recinfo.CARRIER_EST_ARRIVAL_DATE IS NULL)
                  AND  (p_delivery_leg_info.CARRIER_EST_ARRIVAL_DATE IS NULL)))
         AND (  (Recinfo.LOADING_START_DATETIME = p_delivery_leg_info.LOADING_START_DATETIME )
              OR (  (Recinfo.LOADING_START_DATETIME IS NULL)
                  AND  (p_delivery_leg_info.LOADING_START_DATETIME IS NULL)))
         AND (  (Recinfo.LOADING_END_DATETIME = p_delivery_leg_info.LOADING_END_DATETIME )
              OR (  (Recinfo.LOADING_END_DATETIME IS NULL)
                  AND  (p_delivery_leg_info.LOADING_END_DATETIME IS NULL)))
         AND (  (Recinfo.UNLOADING_START_DATETIME = p_delivery_leg_info.UNLOADING_START_DATETIME )
              OR (  (Recinfo.UNLOADING_START_DATETIME IS NULL)
                  AND  (p_delivery_leg_info.UNLOADING_START_DATETIME IS NULL)))
         AND (  (Recinfo.UNLOADING_END_DATETIME = p_delivery_leg_info.UNLOADING_END_DATETIME )
              OR (  (Recinfo.UNLOADING_END_DATETIME IS NULL)
                  AND  (p_delivery_leg_info.UNLOADING_END_DATETIME IS NULL)))
         AND (  (Recinfo.DELIVERED_QUANTITY = p_delivery_leg_info.DELIVERED_QUANTITY )
              OR (  (Recinfo.DELIVERED_QUANTITY IS NULL)
                  AND  (p_delivery_leg_info.DELIVERED_QUANTITY IS NULL)))
         AND (  (Recinfo.LOADED_QUANTITY = p_delivery_leg_info.LOADED_QUANTITY )
              OR (  (Recinfo.LOADED_QUANTITY IS NULL)
                  AND  (p_delivery_leg_info.LOADED_QUANTITY IS NULL)))
         AND (  (Recinfo.RECEIVED_QUANTITY = p_delivery_leg_info.RECEIVED_QUANTITY )
              OR (  (Recinfo.RECEIVED_QUANTITY IS NULL)
                  AND  (p_delivery_leg_info.RECEIVED_QUANTITY IS NULL)))
         AND (  (Recinfo.ORIGIN_STOP_ID = p_delivery_leg_info.ORIGIN_STOP_ID )
              OR (  (Recinfo.ORIGIN_STOP_ID IS NULL)
                  AND  (p_delivery_leg_info.ORIGIN_STOP_ID IS NULL)))
         AND (  (Recinfo.DESTINATION_STOP_ID = p_delivery_leg_info.DESTINATION_STOP_ID )
              OR (  (Recinfo.DESTINATION_STOP_ID IS NULL)
                  AND  (p_delivery_leg_info.DESTINATION_STOP_ID IS NULL)))
         AND (  (Recinfo.parent_delivery_leg_id = p_delivery_leg_info.parent_delivery_leg_id )
              OR (  (Recinfo.parent_delivery_leg_id IS NULL)
                  AND  (p_delivery_leg_info.parent_delivery_leg_id IS NULL)))
     ) THEN
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Nothing has changed');
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
     ELSE
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'FORM_RECORD_CHANGED');
        END IF;
        app_exception.raise_exception;
     END IF;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
  EXCEPTION
     WHEN others THEN

        -- Is this necessary?  Does PL/SQL automatically close a
        -- cursor when it goes out of scope?

	if (lock_row%ISOPEN) then
	    close lock_row;
	end if;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
	raise;
  END Lock_Delivery_Leg;

  PROCEDURE Populate_Record (
		 p_delivery_leg_id            IN   NUMBER,
		 x_delivery_leg_info          OUT NOCOPY   Delivery_Leg_Rec_Type,
		 x_return_status              OUT NOCOPY   VARCHAR2) IS

  CURSOR leg_record IS
  SELECT
         DELIVERY_LEG_ID,
         DELIVERY_ID,
         SEQUENCE_NUMBER,
         LOADING_ORDER_FLAG,
         PICK_UP_STOP_ID,
         DROP_OFF_STOP_ID,
         GROSS_WEIGHT,
         NET_WEIGHT,
         WEIGHT_UOM_CODE,
         VOLUME,
         VOLUME_UOM_CODE,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE,
         REQUEST_ID,
         LOAD_TENDER_STATUS,
/* Changes in the shipping datamodel Bug#1918342*/
         SHIPPER_TITLE,
         SHIPPER_PHONE,
         POD_FLAG,
         POD_BY,
         POD_DATE,
         EXPECTED_POD_DATE,
         BOOKING_OFFICE,
         SHIPPER_EXPORT_REF,
         CARRIER_EXPORT_REF,
         DOC_NOTIFY_PARTY,
         AETC_NUMBER,
         SHIPPER_SIGNED_BY,
         SHIPPER_DATE,
         CARRIER_SIGNED_BY,
         CARRIER_DATE,
         DOC_ISSUE_OFFICE,
         DOC_ISSUED_BY,
         DOC_DATE_ISSUED,
         SHIPPER_HM_BY,
         SHIPPER_HM_DATE,
         CARRIER_HM_BY,
         CARRIER_HM_DATE,
         BOOKING_NUMBER,
         PORT_OF_LOADING,
         PORT_OF_DISCHARGE,
         SERVICE_CONTRACT,
         BILL_FREIGHT_TO,
/* H Integration: datamodel changes wrudge */
	 FTE_TRIP_ID,
	 REPRICE_REQUIRED,
	 ACTUAL_ARRIVAL_DATE,
	 ACTUAL_DEPARTURE_DATE,
	 ACTUAL_RECEIPT_DATE,
	 TRACKING_DRILLDOWN_FLAG,
	 STATUS_CODE,
	 TRACKING_REMARKS,
	 CARRIER_EST_DEPARTURE_DATE,
	 CARRIER_EST_ARRIVAL_DATE,
	 LOADING_START_DATETIME,
	 LOADING_END_DATETIME,
	 UNLOADING_START_DATETIME,
	 UNLOADING_END_DATETIME,
	 DELIVERED_QUANTITY,
	 LOADED_QUANTITY,
	 RECEIVED_QUANTITY,
	 ORIGIN_STOP_ID,
	 DESTINATION_STOP_ID,
/* Harmonization Project I **heali  */
         ROWID,
/* K: MDC: sperera */
         parent_delivery_leg_id
  FROM   wsh_delivery_legs
  WHERE  delivery_leg_id = p_delivery_leg_id;

  others EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'POPULATE_RECORD';
--
  BEGIN
	--
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_LEG_ID',P_DELIVERY_LEG_ID);
	END IF;
	--
	IF (p_delivery_leg_id IS NULL) THEN
	   raise others;
     END IF;

     OPEN  leg_record;
     FETCH leg_record INTO x_delivery_leg_info;

     IF (leg_record%NOTFOUND) THEN
  	  FND_MESSAGE.SET_NAME('WSH','WSH_LEG_NOT_FOUND');
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	  WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'WSH_LEG_NOT_FOUND');
          END IF;
     ELSE
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     END IF;

     CLOSE leg_record;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     EXCEPTION
        WHEN others THEN
	      wsh_util_core.default_handler('WSH_DELIVERY_LEGS_PVT.POPULATE_RECORD',l_module_name);
	      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
              --
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                  WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
              END IF;
              --
  END Populate_Record;


-----------------------------------------------------------------------------
--
-- Procedure:     Get_Disabled_List
-- Parameters:    stop_id, x_return_status, p_trip_flag
-- Description:   Get the disabled columns/fields in a delivery leg
--
-----------------------------------------------------------------------------
PROCEDURE Get_Disabled_List (
						p_delivery_leg_id        IN  NUMBER,
						p_parent_entity_id IN NUMBER,
						p_list_type		  IN  VARCHAR2,
						x_return_status  OUT NOCOPY  VARCHAR2,
						x_disabled_list  OUT NOCOPY  wsh_util_core.column_tab_type,
						x_msg_count             OUT NOCOPY      NUMBER,
						x_msg_data              OUT NOCOPY      VARCHAR2
						) IS

CURSOR get_delivery_status(x_delivery_id NUMBER) IS
  SELECT status_code, planned_flag
  FROM   wsh_new_deliveries
  WHERE  delivery_id = x_delivery_id;

CURSOR get_leg_status(x_leg_id NUMBER) IS
  SELECT delivery_id, pick_up_stop_id, drop_off_stop_id
  FROM   wsh_delivery_legs
  WHERE  delivery_leg_id = x_leg_id;

CURSOR get_stop_status(x_stop_id NUMBER) IS
  SELECT status_code
  FROM   wsh_trip_stops
  WHERE  stop_id = x_stop_id;

	i              NUMBER := 0;
	dummy_id       NUMBER := 0;
	l_status_code  VARCHAR2(10) := NULL;
	l_planned_flag VARCHAR2(10) := NULL;

	l_pick_up_stop	get_stop_status%ROWTYPE;
	l_drop_off_stop get_stop_status%ROWTYPE;
	l_delivery_id  NUMBER := 0;
	l_pick_up_stop_id NUMBER := 0;
	l_drop_off_stop_id NUMBER := 0;

	l_msg_summary					VARCHAR2(2000) := NULL;
	l_msg_details					VARCHAR2(4000) := NULL;

	WSH_DP_NO_ENTITY		exception;
	WSH_INV_LIST_TYPE		exception;
	WSH_DP_NO_STOP			exception;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DISABLED_LIST';
--
BEGIN
	   --
	   --
	   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	   --
	   IF l_debug_on IS NULL
	   THEN
	       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	   END IF;
	   --
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.push(l_module_name);
	       --
	       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_LEG_ID',P_DELIVERY_LEG_ID);
	       WSH_DEBUG_SV.log(l_module_name,'P_PARENT_ENTITY_ID',P_PARENT_ENTITY_ID);
	       WSH_DEBUG_SV.log(l_module_name,'P_LIST_TYPE',P_LIST_TYPE);
	   END IF;
	   --
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
		x_disabled_list.delete;

	   IF p_list_type <> 'FORM' THEN
			raise WSH_INV_LIST_TYPE;
		END IF;
      IF (p_parent_entity_id is NULL) THEN
              FND_MESSAGE.Set_Name('WSH','WSH_API_INVALID_PARAM_VALUE');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
      END IF;

      OPEN  get_delivery_status(p_parent_entity_id);
      FETCH get_delivery_status INTO l_status_code, l_planned_flag;
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_status_code',l_status_code);
         WSH_DEBUG_SV.log(l_module_name,'l_planned_flag',l_planned_flag);
      END IF;
      IF get_delivery_status%NOTFOUND THEN
			CLOSE get_delivery_status;
         FND_MESSAGE.Set_Name('WSH','WSH_API_INVALID_PARAM_VALUE');
			x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.pop(l_module_name);
			END IF;
			--
			RETURN;
      END IF;
      CLOSE get_delivery_status;

      IF (l_status_code = 'CL') THEN
        i:=i+1; x_disabled_list(i) := 'SHIP_METHOD_NAME';
        i:=i+1; x_disabled_list(i) := '+BOOKING_NUMBER';
        i:=i+1; x_disabled_list(i) := '+SERVICE_CONTRACT';
        i:=i+1; x_disabled_list(i) := '+AETC_NUMBER';
--Bugfix#1918342        i:=i+1; x_disabled_list(i) := '+SUPPLIER_CODE';
        i:=i+1; x_disabled_list(i) := '+CARRIER_EXPORT_REF';
        i:=i+1; x_disabled_list(i) := '+SHIPPER_EXPORT_REF';
        i:=i+1; x_disabled_list(i) := '+NOTIFY_PARTY';
        i:=i+1; x_disabled_list(i) := '+BILL_FREIGHT_TO';
     --Bug#1918342   i:=i+1; x_disabled_list(i) := '+PROBLEM_CONTACT_REF';
        i:=i+1; x_disabled_list(i) := '+BOOKING_OFFICE';
        i:=i+1; x_disabled_list(i) := '+ISSUING_OFFICE';
        i:=i+1; x_disabled_list(i) := '+ISSUING_PERSON';
        i:=i+1; x_disabled_list(i) := '+DATE_ISSUED';
        i:=i+1; x_disabled_list(i) := '+PORT_OF_LOADING';
        i:=i+1; x_disabled_list(i) := '+PORT_OF_DISCHARGE';
/* Commented for shipping Data model Bug#1918342
        i:=i+1; x_disabled_list(i) := '+COD_AMOUNT';
        i:=i+1; x_disabled_list(i) := '+COD_CURRENCY_CODE';
        i:=i+1; x_disabled_list(i) := '+COD_REMIT_TO';
        i:=i+1; x_disabled_list(i) := '+COD_CHARGE_PAID_BY';*/
        i:=i+1; x_disabled_list(i) := '+SHIPPER_TITLE';
        i:=i+1; x_disabled_list(i) := '+SHIPPER_PHONE';
        i:=i+1; x_disabled_list(i) := '+SHIPPER_SIGNED_BY';
        i:=i+1; x_disabled_list(i) := '+SHIPPER_SIGNED_DATE';
        i:=i+1; x_disabled_list(i) := '+CARRIER_SIGNED_BY';
        i:=i+1; x_disabled_list(i) := '+CARRIER_SIGNED_DATE';
        i:=i+1; x_disabled_list(i) := '+POD_SIGNED_BY';
        i:=i+1; x_disabled_list(i) := '+POD_SIGNED_DATE';
--Bug#1918342        i:=i+1; x_disabled_list(i) := '+POD_COMMENTS';
        i:=i+1; x_disabled_list(i) := '+SHIPPER_SIGNED_HM_BY';
        i:=i+1; x_disabled_list(i) := '+SHIPPER_SIGNED_HM_DATE';
        i:=i+1; x_disabled_list(i) := '+CARRIER_SIGNED_HM_BY';
        i:=i+1; x_disabled_list(i) := '+CARRIER_SIGNED_HM_DATE';
		ELSE
			OPEN get_leg_status(p_delivery_leg_id);
			FETCH get_leg_status INTO l_delivery_id, l_pick_up_stop_id, l_drop_off_stop_id;
                        IF l_debug_on THEN
                           WSH_DEBUG_SV.log(l_module_name,'l_delivery_id',
                                                         l_delivery_id);
                           WSH_DEBUG_SV.log(l_module_name,'l_pick_up_stop_id',
                                                         l_pick_up_stop_id);
                           WSH_DEBUG_SV.log(l_module_name,'l_drop_off_stop_id',
                                                         l_drop_off_stop_id);
                        END IF;
			IF get_leg_status%NOTFOUND then
			   CLOSE get_leg_status;
			   RAISE WSH_DP_NO_ENTITY;
         END IF;
			CLOSE get_leg_status;

			OPEN get_stop_status(l_pick_up_stop_id);
			FETCH get_stop_status INTO l_pick_up_stop;
                        IF l_debug_on THEN
                           WSH_DEBUG_SV.log(l_module_name,'status_code',
                                                   l_pick_up_stop.status_code);
                        END IF;
			IF get_stop_status%NOTFOUND then
				CLOSE get_stop_status;
				RAISE WSH_DP_NO_STOP;
			END IF;
			CLOSE get_stop_status;

			OPEN get_stop_status(l_drop_off_stop_id);
			FETCH get_stop_status INTO l_drop_off_stop;
                        IF l_debug_on THEN
                           WSH_DEBUG_SV.log(l_module_name,'status_code',
                                                   l_drop_off_stop.status_code);
                        END IF;
			IF get_stop_status%NOTFOUND then
				CLOSE get_stop_status;
				RAISE WSH_DP_NO_STOP;
			END IF;
			CLOSE get_stop_status;

			IF (l_pick_up_stop.status_code = 'OP' )
			    AND ( l_drop_off_stop.status_code = 'OP') THEN
				i:=i+1; x_disabled_list(i) := '+SHIP_METHOD_NAME';
			ELSIF (l_pick_up_stop.status_code = 'CL') OR
			       (l_drop_off_stop.status_code in ('AR','CL')) THEN
				i:=i+1; x_disabled_list(i) := 'SHIP_METHOD_NAME';
			END IF;
		END IF;
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                --
EXCEPTION

  WHEN WSH_DP_NO_ENTITY THEN
		FND_MESSAGE.SET_NAME('WSH', 'WSH_DP_NO_ENTITY');
		WSH_UTIL_CORE.ADD_MESSAGE(FND_API.G_RET_STS_ERROR,l_module_name);
		x_return_status := FND_API.G_RET_STS_ERROR;
		WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
		if x_msg_count > 1 then
			x_msg_data := l_msg_summary || l_msg_details;
		else
			x_msg_data := l_msg_summary;
		end if;
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DP_NO_ENTITY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                     IF x_msg_count > 1 then
                         WSH_DEBUG_SV.log(l_module_name,'x_msg_data',
                                                     SUBSTR(x_msg_data,1,200));
                      END IF;
                     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DP_NO_ENTITY');
                 END IF;
                 --
  WHEN WSH_DP_NO_STOP THEN
		FND_MESSAGE.SET_NAME('WSH', 'WSH_DP_NO_STOP');
		WSH_UTIL_CORE.ADD_MESSAGE(FND_API.G_RET_STS_ERROR,l_module_name);
		x_return_status := FND_API.G_RET_STS_ERROR;
		WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
		if x_msg_count > 1 then
			x_msg_data := l_msg_summary || l_msg_details;
		else
			x_msg_data := l_msg_summary;
		end if;
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DP_NO_STOP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                    IF x_msg_count > 1 then
                       WSH_DEBUG_SV.log(l_module_name,'x_msg_data',
                                           SUBSTR(x_msg_data,1,200));
                    END IF;
                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DP_NO_STOP');
                END IF;
                --
  WHEN WSH_INV_LIST_TYPE THEN
  		FND_MESSAGE.SET_NAME('WSH', 'WSH_INV_LIST_TYPE');
		WSH_UTIL_CORE.ADD_MESSAGE(FND_API.G_RET_STS_ERROR,l_module_name);
		x_return_status := FND_API.G_RET_STS_ERROR;
		WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
		if x_msg_count > 1 then
			x_msg_data := l_msg_summary || l_msg_details;
		else
			x_msg_data := l_msg_summary;
		end if;
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INV_LIST_TYPE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INV_LIST_TYPE');
                END IF;
                --
  WHEN OTHERS THEN
    IF get_delivery_status%ISOPEN THEN
      CLOSE get_delivery_status;
    END IF;
    IF get_leg_status%ISOPEN THEN
      CLOSE get_leg_status;
    END IF;
    IF get_stop_status%ISOPEN THEN
      CLOSE get_stop_status;
    END IF;

    FND_MESSAGE.Set_Name('WSH','WSH_UNEXPECTED_ERROR');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
  END Get_Disabled_List;

/*    ---------------------------------------------------------------------
     Procedure:	Lock_Dlvy_Leg_No_Compare

     Parameters:	Delivery_Leg Id DEFAULT NULL
                         Delivery Id        DEFAULT NULL

     Description:  This procedure is used for obtaining locks of delivery legs
                    using the delivery_leg_id or the delivery_id.
                   It is called by delivery's wrapper lock API when the
                   action is CONFIRM.
                    This procedure does not compare the attributes. It just
                    does a SELECT using FOR UPDATE NOWAIT
     Created:   Harmonization Project. Patchset I
     ----------------------------------------------------------------------- */

PROCEDURE Lock_Dlvy_Leg_No_Compare(
          p_dlvy_leg_id   IN NUMBER, -- default null in spec
          p_delivery_id   IN NUMBER -- DEFAULT null in spec
          )
IS
l_dummy_leg_id  NUMBER;
l_del_name      VARCHAR2(30);

CURSOR c_lock_dlvy_leg(p_leg_id NUMBER) IS
SELECT delivery_leg_id
FROM wsh_delivery_legs
WHERE delivery_leg_id = p_leg_id
FOR UPDATE NOWAIT;

CURSOR c_lock_legs_of_dlvy(p_dlvy_id NUMBER) IS
SELECT delivery_leg_id
FROM wsh_delivery_legs
WHERE delivery_id = p_dlvy_id
FOR UPDATE NOWAIT;

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_DLVY_LEG';

BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'p_dlvy_leg_id', p_dlvy_leg_id);
      WSH_DEBUG_SV.log(l_module_name, 'p_delivery_id', p_delivery_id);
  END IF;
  --
  IF p_dlvy_leg_id IS NOT NULL THEN
     open c_lock_dlvy_leg(p_dlvy_leg_id);
     fetch c_lock_dlvy_leg INTO l_dummy_leg_id;
     close c_lock_dlvy_leg;

  ELSIF p_delivery_id IS NOT NULL THEN
     open c_lock_legs_of_dlvy(p_delivery_id);
     close c_lock_legs_of_dlvy;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
EXCEPTION
	WHEN app_exception.application_exception or app_exception.record_lock_exception THEN
            IF p_delivery_id IS NOT NULL THEN
              l_del_name := wsh_new_deliveries_pvt.get_name(p_delivery_id);
              FND_MESSAGE.SET_NAME('WSH', 'WSH_DLVY_DEL_LEG_LOCK');
              FND_MESSAGE.SET_TOKEN('DEL_NAME', l_del_name);
              wsh_util_Core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
              IF l_debug_on THEN
                 wsh_debug_sv.log(l_module_name, 'Could not obtain locks on some or all delivery legs of delivery', p_delivery_id);
              END IF;
            ELSE
              IF l_debug_on THEN
                 wsh_debug_sv.log(l_module_name, 'Could not obtain lock on delivery leg', p_dlvy_leg_id);
              END IF;
            END IF;
              --
	      IF l_debug_on THEN
	          WSH_DEBUG_SV.logmsg(l_module_name,'APP_EXCEPTION.APPLICATION_EXCEPTION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:APP_EXCEPTION.APPLICATION_EXCEPTION');
	      END IF;
	      --
	      RAISE;

END Lock_Dlvy_Leg_No_Compare;


END WSH_DELIVERY_LEGS_PVT;


/
