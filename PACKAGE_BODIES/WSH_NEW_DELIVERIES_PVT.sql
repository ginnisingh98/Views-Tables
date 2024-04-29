--------------------------------------------------------
--  DDL for Package Body WSH_NEW_DELIVERIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_NEW_DELIVERIES_PVT" as
/* $Header: WSHDETHB.pls 120.15.12010000.4 2009/12/03 14:31:50 mvudugul ship $ */

--
-- Package internal global variables
--
  g_return_status		VARCHAR2(1);

--
-- Package exceptions
--
  wsh_duplicate_name		EXCEPTION;

--
--  Procedure:		Create_Delivery
--  Parameters:		p_delivery_info - All Attributes of a Delivery Record
--			x_rowid - Rowid of delivery created
--			x_delivery_id - Delivery_Id of delivery created
--			x_name - Name of delivery created
--			x_return_status - Status of procedure call
--  Description:	This procedure will create a delivery. It will
--			return to the use the delivery_id and name (if
--			not provided as a parameter.
--


  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_NEW_DELIVERIES_PVT';
  --
  PROCEDURE Create_Delivery
		(p_delivery_info	IN	Delivery_Rec_Type,
		 x_rowid		OUT NOCOPY  	VARCHAR2,
		 x_delivery_id		OUT NOCOPY 	NUMBER,
		 x_name			OUT NOCOPY 	VARCHAR2,
		 x_return_status	OUT NOCOPY 	VARCHAR2
		) IS

  CURSOR get_next_delivery IS
  SELECT wsh_new_deliveries_s.nextval
  FROM   sys.dual;

  CURSOR count_delivery_rows (v_delivery_name VARCHAR2) IS
  SELECT delivery_id
  FROM wsh_new_deliveries
  WHERE name = v_delivery_name;

  l_delivery_name	VARCHAR2(30);
  l_temp_id		NUMBER;
  l_row_check		NUMBER;
  l_message		VARCHAR2(30);

  others                EXCEPTION;

  l_wh_type             VARCHAR2(3);
  l_return_status       VARCHAR2(1);
  l_ignore_for_planning VARCHAR2(1);
  --

  l_wf_rs VARCHAR2(1);  -- Workflow Changes


l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_DELIVERY';
--
  BEGIN

    -- initialize parameters
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
        WSH_DEBUG_SV.log(l_module_name,'p_delivery_info.delivery_id',
                                                  p_delivery_info.delivery_id);
        WSH_DEBUG_SV.log(l_module_name,'p_delivery_info.name',
                                                  p_delivery_info.name);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    x_delivery_id := p_delivery_info.delivery_id;
    x_name := p_delivery_info.name;

     -- get next delivery id
     IF x_delivery_id IS NULL THEN

	   OPEN  get_next_delivery;
	   FETCH get_next_delivery INTO x_delivery_id;
	   CLOSE get_next_delivery;

            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'x_delivery_id',x_delivery_id);
            END IF;
     END IF;
     -- try to generate a new default delivery name
     IF x_name IS NULL THEN
	l_delivery_name := wsh_custom_pub.delivery_name(x_delivery_id,p_delivery_info);

        -- shipping default make sure the delivery name is not duplicate
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_delivery_name',l_delivery_name);
           WSH_DEBUG_SV.log(l_module_name,'x_delivery_id',x_delivery_id);
        END IF;
        IF ( l_delivery_name = to_char(x_delivery_id) ) THEN
           l_temp_id := x_delivery_id;

           LOOP

              l_delivery_name := to_char(l_temp_id);

              OPEN count_delivery_rows( l_delivery_name);
              FETCH count_delivery_rows INTO l_row_check;
              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'l_row_check',l_row_check);
              END IF;
              IF (count_delivery_rows%NOTFOUND) THEN
                 CLOSE count_delivery_rows;
                 EXIT;
              END IF;

              CLOSE count_delivery_rows;

              OPEN get_next_delivery;
              FETCH get_next_delivery INTO l_temp_id;
              CLOSE get_next_delivery;
              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'l_temp_id',l_temp_id);
              END IF;
           END LOOP;

           x_delivery_id := l_temp_id;

        END IF;

        x_name := l_delivery_name;

     ELSE

           OPEN count_delivery_rows(x_name);
           FETCH count_delivery_rows INTO l_row_check;
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_row_check',l_row_check);
           END IF;
           IF (count_delivery_rows%FOUND) THEN
              CLOSE count_delivery_rows;
              RAISE wsh_duplicate_name;
           END IF;

           CLOSE count_delivery_rows;

     END IF;

     INSERT INTO wsh_new_deliveries
	(
		 delivery_id
		,name
		,planned_flag
		,status_code
		,delivery_type
		,loading_sequence
		,loading_order_flag
		,initial_pickup_date
		,initial_pickup_location_id
		,organization_id
		,ultimate_dropoff_location_id
		,ultimate_dropoff_date
		,customer_id
		,intmed_ship_to_location_id
		,pooled_ship_to_location_id
		,carrier_id
		,ship_method_code
		,freight_terms_code
		,fob_code
		,fob_location_id
		,waybill
		,dock_code
		,acceptance_flag
		,accepted_by
		,accepted_date
		,acknowledged_by
		,confirmed_by
		,confirm_date
		,asn_date_sent
		,asn_status_code
		,asn_seq_number
		,gross_weight
		,net_weight
		,weight_uom_code
		,volume
		,volume_uom_code
		,additional_shipment_info
		,currency_code
		,attribute_category
		,attribute1
		,attribute2
		,attribute3
		,attribute4
		,attribute5
		,attribute6
		,attribute7
		,attribute8
		,attribute9
		,attribute10
		,attribute11
		,attribute12
		,attribute13
		,attribute14
		,attribute15
		,tp_attribute_category
		,tp_attribute1
		,tp_attribute2
		,tp_attribute3
		,tp_attribute4
		,tp_attribute5
		,tp_attribute6
		,tp_attribute7
		,tp_attribute8
		,tp_attribute9
		,tp_attribute10
		,tp_attribute11
		,tp_attribute12
		,tp_attribute13
		,tp_attribute14
		,tp_attribute15
		,global_attribute_category
		,global_attribute1
		,global_attribute2
		,global_attribute3
		,global_attribute4
		,global_attribute5
		,global_attribute6
		,global_attribute7
		,global_attribute8
		,global_attribute9
		,global_attribute10
		,global_attribute11
		,global_attribute12
		,global_attribute13
		,global_attribute14
		,global_attribute15
		,global_attribute16
		,global_attribute17
		,global_attribute18
		,global_attribute19
		,global_attribute20
		,creation_date
		,created_by
		,last_update_date
		,last_updated_by
		,last_update_login
		,program_application_id
		,program_id
		,program_update_date
		,request_id
                ,batch_id
                ,hash_value
                ,source_header_id
		,number_of_lpn
/* Changes for Shipping Data Model Bug#1918342*/
		,cod_amount
		,cod_currency_code
		,cod_remit_to
		,cod_charge_paid_by
		,problem_contact_reference
		,port_of_loading
		,port_of_discharge
		,ftz_number
		,routed_export_txn
		,entry_number
		,routing_instructions
		,in_bond_code
		,shipping_marks
/* H Integration: datamodel changes wrudge */
		,service_level
		,mode_of_transport
		,assigned_to_fte_trips
                ,auto_sc_exclude_flag
                ,auto_ap_exclude_flag
/* J Inbound Logistics jckwok */
                ,shipment_direction
                ,vendor_id
                ,party_id
                ,routing_response_id
                ,rcv_shipment_header_id
                ,asn_shipment_header_id
                ,shipping_control
/* J TP Release : ttrichy */
                ,TP_DELIVERY_NUMBER
                ,EARLIEST_PICKUP_DATE
                ,LATEST_PICKUP_DATE
                ,EARLIEST_DROPOFF_DATE
                ,LATEST_DROPOFF_DATE
                ,IGNORE_FOR_PLANNING
                ,TP_PLAN_NAME
-- J: W/V Changes
                ,WV_FROZEN_FLAG
                ,HASH_STRING
                ,delivered_date
-- bug 3667348
                ,REASON_OF_TRANSPORT
                ,DESCRIPTION
--OTM R12
                ,TMS_INTERFACE_FLAG
                ,TMS_VERSION_NUMBER
                , client_id -- LSP PROJECT  --Modified R12.1.1 LSP PROJECT(rminocha)
            )
     VALUES (
		 x_delivery_id
		,x_name
		,nvl(p_delivery_info.planned_flag,'N')
		,nvl(p_delivery_info.status_code,'OP')
		,nvl(p_delivery_info.delivery_type,'STANDARD')
		,p_delivery_info.loading_sequence
		,p_delivery_info.loading_order_flag
		,p_delivery_info.initial_pickup_date
		,p_delivery_info.initial_pickup_location_id
		,p_delivery_info.organization_id
		,p_delivery_info.ultimate_dropoff_location_id
		,p_delivery_info.ultimate_dropoff_date
		,p_delivery_info.customer_id
		,p_delivery_info.intmed_ship_to_location_id
		,p_delivery_info.pooled_ship_to_location_id
		,p_delivery_info.carrier_id
		,p_delivery_info.ship_method_code
		,p_delivery_info.freight_terms_code
		,p_delivery_info.fob_code
		,p_delivery_info.fob_location_id
		,p_delivery_info.waybill
		,p_delivery_info.dock_code
		,p_delivery_info.acceptance_flag
		,p_delivery_info.accepted_by
		,p_delivery_info.accepted_date
		,p_delivery_info.acknowledged_by
		,p_delivery_info.confirmed_by
		,p_delivery_info.confirm_date
		,p_delivery_info.asn_date_sent
		,p_delivery_info.asn_status_code
		,p_delivery_info.asn_seq_number
		,p_delivery_info.gross_weight
		,p_delivery_info.net_weight
		,p_delivery_info.weight_uom_code
		,p_delivery_info.volume
		,p_delivery_info.volume_uom_code
		,p_delivery_info.additional_shipment_info
		,p_delivery_info.currency_code
		,p_delivery_info.attribute_category
		,p_delivery_info.attribute1
		,p_delivery_info.attribute2
		,p_delivery_info.attribute3
		,p_delivery_info.attribute4
		,p_delivery_info.attribute5
		,p_delivery_info.attribute6
		,p_delivery_info.attribute7
		,p_delivery_info.attribute8
		,p_delivery_info.attribute9
		,p_delivery_info.attribute10
		,p_delivery_info.attribute11
		,p_delivery_info.attribute12
		,p_delivery_info.attribute13
		,p_delivery_info.attribute14
		,p_delivery_info.attribute15
		,p_delivery_info.tp_attribute_category
		,p_delivery_info.tp_attribute1
		,p_delivery_info.tp_attribute2
		,p_delivery_info.tp_attribute3
		,p_delivery_info.tp_attribute4
		,p_delivery_info.tp_attribute5
		,p_delivery_info.tp_attribute6
		,p_delivery_info.tp_attribute7
		,p_delivery_info.tp_attribute8
		,p_delivery_info.tp_attribute9
		,p_delivery_info.tp_attribute10
		,p_delivery_info.tp_attribute11
		,p_delivery_info.tp_attribute12
		,p_delivery_info.tp_attribute13
		,p_delivery_info.tp_attribute14
		,p_delivery_info.tp_attribute15
		,p_delivery_info.global_attribute_category
		,p_delivery_info.global_attribute1
		,p_delivery_info.global_attribute2
		,p_delivery_info.global_attribute3
		,p_delivery_info.global_attribute4
		,p_delivery_info.global_attribute5
		,p_delivery_info.global_attribute6
		,p_delivery_info.global_attribute7
		,p_delivery_info.global_attribute8
		,p_delivery_info.global_attribute9
		,p_delivery_info.global_attribute10
		,p_delivery_info.global_attribute11
		,p_delivery_info.global_attribute12
		,p_delivery_info.global_attribute13
		,p_delivery_info.global_attribute14
		,p_delivery_info.global_attribute15
		,p_delivery_info.global_attribute16
		,p_delivery_info.global_attribute17
		,p_delivery_info.global_attribute18
		,p_delivery_info.global_attribute19
		,p_delivery_info.global_attribute20
		,nvl(p_delivery_info.creation_date, SYSDATE)
		,nvl(p_delivery_info.created_by,FND_GLOBAL.USER_ID)
		,nvl(p_delivery_info.last_update_date, SYSDATE)
		,nvl(p_delivery_info.last_updated_by,FND_GLOBAL.USER_ID)
		,nvl(p_delivery_info.last_update_login,FND_GLOBAL.LOGIN_ID)
		,p_delivery_info.program_application_id
		,p_delivery_info.program_id
		,p_delivery_info.program_update_date
		,p_delivery_info.request_id
                ,p_delivery_info.batch_id
                ,p_delivery_info.hash_value
                ,p_delivery_info.source_header_id
		,p_delivery_info.number_of_lpn
		/* Changes for Shipping Data Model Bug#1918342*/
		,p_delivery_info.cod_amount
		,p_delivery_info.cod_currency_code
		,p_delivery_info.cod_remit_to
		,p_delivery_info.cod_charge_paid_by
		,p_delivery_info.problem_contact_reference
		,p_delivery_info.port_of_loading
		,p_delivery_info.port_of_discharge
		,p_delivery_info.ftz_number
		,p_delivery_info.routed_export_txn
		,p_delivery_info.entry_number
		,p_delivery_info.routing_instructions
		,p_delivery_info.in_bond_code
		,p_delivery_info.shipping_marks
/* H Integration: datamodel changes wrudge */
		,p_delivery_info.service_level
		,p_delivery_info.mode_of_transport
		,p_delivery_info.assigned_to_fte_trips
		,p_delivery_info.auto_sc_exclude_flag
		,p_delivery_info.auto_ap_exclude_flag
/* J Inbound Logistics jckwok */
                ,nvl(p_delivery_info.shipment_direction, 'O')
                ,p_delivery_info.vendor_id
                ,p_delivery_info.party_id
                ,p_delivery_info.routing_response_id
                ,p_delivery_info.rcv_shipment_header_id
                ,p_delivery_info.asn_shipment_header_id
                ,p_delivery_info.shipping_control
/* J TP Release : ttrichy */
                ,p_delivery_info.TP_DELIVERY_NUMBER
                ,p_delivery_info.EARLIEST_PICKUP_DATE
                ,p_delivery_info.LATEST_PICKUP_DATE
                ,p_delivery_info.EARLIEST_DROPOFF_DATE
                ,p_delivery_info.LATEST_DROPOFF_DATE
                ,nvl(p_delivery_info.ignore_for_planning,'N')
                ,p_delivery_info.TP_PLAN_NAME
-- J: W/V Changes
                ,nvl(p_delivery_info.wv_frozen_flag, 'N')
                ,p_delivery_info.hash_string
                ,p_delivery_info.delivered_date
  -- bug 3667348
                ,p_delivery_info.REASON_OF_TRANSPORT
                ,p_delivery_info.DESCRIPTION
 -- bug 3667348
--OTM R12
                ,WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT
                ,1
                , p_delivery_info.client_id -- LSP PROJECT --Modified R12.1.1 LSP PROJECT(rminocha)
             )
	RETURNING rowid
	INTO x_rowid;


  --/== Workflow Changes
  IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.RAISE_EVENT',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;

  WSH_WF_STD.RAISE_EVENT(p_entity_type   =>  'DELIVERY',
		       p_entity_id       =>  x_delivery_id,
		       p_event           =>  'oracle.apps.wsh.delivery.gen.create',
		       p_organization_id =>  p_delivery_info.organization_id,
		       x_return_status   =>  l_wf_rs);

  IF l_debug_on THEN
	WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_WF_STD.RAISE_EVENT => ',l_wf_rs);
  END IF;
  -- Workflow Changes ==/

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_rowid',x_rowid);
      WSH_DEBUG_SV.log(l_module_name,'x_delivery_id',x_delivery_id);
      WSH_DEBUG_SV.log(l_module_name,'x_name',x_name);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
     WHEN wsh_duplicate_name THEN
        FND_MESSAGE.Set_Name('FND', 'FORM_DUPLICATE_KEY_IN_INDEX');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
	   --
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DUPLICATE_NAME exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DUPLICATE_NAME');
	   END IF;
	   --
     WHEN others THEN
	   wsh_util_core.default_handler('WSH_NEW_DELIVERIES_PVT.CREATE_DELIVERY',l_module_name);
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
               WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
           END IF;
           --
  END Create_Delivery;


--
--  Procedure:		Update_Delivery
--  Parameters:		p_rowid - Rowid for delivery to be updated
--			p_delivery_info - All Attributes of a Delivery Record
--			x_return_status - Status of procedure call
--  Description:	This procedure will update attributes of a delivery.
--

  PROCEDURE Update_Delivery
		(p_rowid		IN	VARCHAR2,
		 p_delivery_info	IN	Delivery_Rec_Type,
		 x_return_status		OUT NOCOPY 	VARCHAR2
		) IS

-- J: W/V Changes
  CURSOR get_del_info IS
  SELECT rowid,
         gross_weight,
         net_weight,
         volume,
         weight_uom_code,
         volume_uom_code,
         wv_frozen_flag,
         organization_id
  FROM   wsh_new_deliveries
  WHERE  delivery_id = p_delivery_info.delivery_id;

  CURSOR c_iscarriersmcchanged IS
  SELECT organization_id, name
  FROM wsh_new_deliveries
  WHERE  delivery_id = p_delivery_info.delivery_id
  and (carrier_id <> p_delivery_info.carrier_id
       OR ship_method_code <> p_delivery_info.ship_method_code);

l_return_status    VARCHAR2 (1);
l_wh_type VARCHAR2(3);


l_rowid               VARCHAR2(30);
-- J: W/V Changes
l_gross_wt            NUMBER;
l_net_wt              NUMBER;
l_volume              NUMBER;
l_old_gross_wt            NUMBER;
l_old_net_wt              NUMBER;
l_old_volume              NUMBER;
l_weight_uom_code     VARCHAR2(3);
l_volume_uom_code     VARCHAR2(3);
l_frozen_flag         VARCHAR2(1);
l_diff_gross_wt       NUMBER;
l_diff_net_wt         NUMBER;
l_diff_vol            NUMBER;
e_wt_vol_fail         EXCEPTION;
--
l_num_errors            NUMBER := 0;
l_num_warnings          NUMBER := 0;
--WF: CMR
l_wf_rs               VARCHAR2(1);
l_del_ids             WSH_UTIL_CORE.ID_TAB_TYPE;
l_del_old_carrier_ids WSH_UTIL_CORE.ID_TAB_TYPE;
l_del_new_carrier_ids WSH_UTIL_CORE.ID_TAB_TYPE;
l_organization_id NUMBER;
-- Following two variable are added for Bugfix #4587421
l_gross_weight        NUMBER;
l_net_weight          NUMBER;

--OTM R12
l_delivery_info_tab      WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
l_delivery_info	         WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;
l_new_interface_flag_tab WSH_UTIL_CORE.COLUMN_TAB_TYPE;
l_tms_update	         VARCHAR2(1);
l_trip_not_found         VARCHAR2(1);
l_trip_info_rec	         WSH_DELIVERY_VALIDATIONS.trip_info_rec_type;
l_tms_version_number     WSH_NEW_DELIVERIES.TMS_VERSION_NUMBER%TYPE;
l_gc3_is_installed       VARCHAR2(1);
l_sysdate                DATE;
api_return_fail          EXCEPTION;
--

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_DELIVERY';
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
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


    --OTM R12, initialize
    l_tms_update := 'N';
    l_new_interface_flag_tab(1) := NULL;
    l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED; -- this is global variable

    IF l_gc3_is_installed IS NULL THEN
      l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED; -- this is actual function
    END IF;
    --

    /*CURRENTLY NOT IN USE
    --WF: CMR
    l_del_ids(1) := p_delivery_info.delivery_id;
    */
--Bugfix #4587421
    l_gross_weight := p_delivery_info.gross_weight;
    l_net_weight := p_delivery_info.net_weight;

    /*WSH_WF_STD.Get_Carrier(p_del_ids => l_del_ids,
                           x_del_old_carrier_ids => l_del_old_carrier_ids,
                           x_return_status => l_wf_rs);
*/
-- J: W/V Changes
    OPEN  get_del_info;
    FETCH get_del_info INTO l_rowid, l_gross_wt, l_net_wt, l_volume, l_weight_uom_code, l_volume_uom_code, l_frozen_flag, l_organization_id;
    IF get_del_info%NOTFOUND THEN
      CLOSE get_del_info;
      RAISE no_data_found;
    END IF;
    CLOSE get_del_info;
    IF p_rowid IS NOT NULL THEN
      l_rowid := p_rowid;
    END IF;

    IF l_weight_uom_code <> p_delivery_info.weight_uom_code THEN

       l_old_gross_wt := WSH_WV_UTILS.Convert_Uom(
                                           from_uom => l_weight_uom_code,
                                           to_uom   => p_delivery_info.weight_uom_code,
                                           quantity => l_gross_wt);

       l_old_net_wt := WSH_WV_UTILS.Convert_Uom(
                                           from_uom => l_weight_uom_code,
                                           to_uom   => p_delivery_info.weight_uom_code,
                                           quantity => l_net_wt);
    ELSE

      l_old_gross_wt := l_gross_wt;
      l_old_net_wt   := l_net_wt;

    END IF;

    IF l_volume_uom_code <> p_delivery_info.volume_uom_code THEN

       l_old_volume   := WSH_WV_UTILS.Convert_Uom(
                                           from_uom => l_volume_uom_code,
                                           to_uom   => p_delivery_info.volume_uom_code,
                                           quantity => l_volume);

    ELSE

       l_old_volume := l_volume;

    END IF;
    -- Set wv_frozen_flag to Y if W/V info changes
    IF (NVL(l_old_gross_wt,-99) <> NVL(p_delivery_info.gross_weight,-99)) OR
       (NVL(l_old_net_wt,-99) <> NVL(p_delivery_info.net_weight,-99)) OR
       (NVL(l_old_volume,-99) <> NVL(p_delivery_info.volume,-99)) THEN
      -- Bug 5157444
      IF    l_organization_id <> p_delivery_info.organization_id
        AND p_delivery_info.net_weight IS NULL
        AND p_delivery_info.volume IS NULL
        AND p_delivery_info.gross_weight IS NULL
      THEN
         l_frozen_flag := 'N';
      ELSE
         l_frozen_flag := 'Y';
      END IF;
    END IF;

--Bugfix #4587421
-- If the new gross weight is less than net weight then gross weight should be equal to net weight.
-- If Gross weight is Zero/Null then Net weight should be Zero/Null.
    IF nvl(l_old_gross_wt , -99) = nvl(p_delivery_info.gross_weight, -99)
    THEN
         IF p_delivery_info.net_weight is not null
            and nvl(p_delivery_info.gross_weight, 0) < p_delivery_info.net_weight
         THEN
              l_gross_weight := p_delivery_info.net_weight;
              l_net_weight := p_delivery_info.net_weight;
         END IF;
    ELSIF nvl(l_old_gross_wt , -99) <> nvl(p_delivery_info.gross_weight, -99)
    THEN
         IF p_delivery_info.net_weight is not null
            and nvl(p_delivery_info.gross_weight, 0) < p_delivery_info.net_weight
         THEN
             l_gross_weight := p_delivery_info.gross_weight;
             l_net_weight := p_delivery_info.gross_weight;
         END IF;

         IF p_delivery_info.gross_weight is null
         THEN
            l_net_weight := p_delivery_info.gross_weight;
         END IF;
    END IF;

    --OTM R12, check for tms update
    IF l_gc3_is_installed = 'Y' AND
       NVL(p_delivery_info.ignore_for_planning, 'N') = 'N' THEN

      l_trip_not_found := 'N';
      l_tms_version_number := 1;

      --get trip information for delivery, no update when trip not OPEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.GET_TRIP_INFORMATION',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_DELIVERY_VALIDATIONS.get_trip_information
        (p_delivery_id     => p_delivery_info.delivery_id,
         x_trip_info_rec   => l_trip_info_rec,
         x_return_status   => l_return_status);

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_DELIVERY_VALIDATIONS.GET_TRIP_INFORMATION',l_return_status);
      END IF;

      IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_DELIVERY_VALIDATIONS.get_trip_information');
        END IF;
        RAISE api_return_fail;
      END IF;

      IF (l_trip_info_rec.trip_id IS NULL) THEN
        l_trip_not_found := 'Y';
      END IF;

      -- only do changes when there's no trip or trip status is OPEN
      IF (l_trip_info_rec.status_code = 'OP' OR l_trip_not_found = 'Y') THEN

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.get_delivery_information',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        WSH_DELIVERY_VALIDATIONS.get_delivery_information(
          p_delivery_id   => p_delivery_info.delivery_id,
          x_delivery_rec  => l_delivery_info,
          x_return_status => l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_DELIVERY_VALIDATIONS.get_delivery_information',l_return_status);
        END IF;

        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_DELIVERY_VALIDATIONS.get_delivery_information');
          END IF;
          RAISE api_return_fail;
        END IF;

        l_sysdate := sysdate;

        --checking the value differences for the critical fields
        IF ((NVL(l_delivery_info.name, '!@#$%') <> NVL(p_delivery_info.name, '!@#$%'))
            OR (NVL(l_delivery_info.initial_pickup_location_id, -99) <>
                NVL(p_delivery_info.initial_pickup_location_id, -99))
            OR (NVL(l_delivery_info.ultimate_dropoff_location_id, -99) <>
                NVL(p_delivery_info.ultimate_dropoff_location_id, -99))
            OR (NVL(l_delivery_info.freight_terms_code, '!@#$%') <>
                NVL(p_delivery_info.freight_terms_code, '!@#$%'))
            OR (NVL(l_delivery_info.fob_code, '!@#$%') <> NVL(p_delivery_info.fob_code, '!@#$%'))
            OR (NVL(l_delivery_info.ship_method_code, '!@#$%') <> NVL(p_delivery_info.ship_method_code, '!@#$%'))
            OR (NVL(l_delivery_info.carrier_id, -99) <> NVL(p_delivery_info.carrier_id, -99))
            OR (NVL(l_delivery_info.service_level, '!@#$%') <> NVL(p_delivery_info.service_level, '!@#$%'))
            OR (NVL(l_delivery_info.mode_of_transport, '!@#$%') <>
                NVL(p_delivery_info.mode_of_transport, '!@#$%'))
            OR (NVL(l_delivery_info.earliest_pickup_date, l_sysdate) <>
                NVL(p_delivery_info.earliest_pickup_date, l_sysdate))
            OR (NVL(l_delivery_info.latest_pickup_date, l_sysdate) <>
                NVL(p_delivery_info.latest_pickup_date, l_sysdate))
            OR (NVL(l_delivery_info.earliest_dropoff_date, l_sysdate) <>
                NVL(p_delivery_info.earliest_dropoff_date, l_sysdate))
            OR (NVL(l_delivery_info.latest_dropoff_date, l_sysdate) <>
                NVL(p_delivery_info.latest_dropoff_date, l_sysdate))) THEN

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'p_delivery_info name', p_delivery_info.name);
            WSH_DEBUG_SV.log(l_module_name,'l_delivery_info name', l_delivery_info.name);
            WSH_DEBUG_SV.log(l_module_name,'p_delivery_info initial_pickup_location_id', p_delivery_info.initial_pickup_location_id);
            WSH_DEBUG_SV.log(l_module_name,'l_delivery_info initial_pickup_location_id', l_delivery_info.initial_pickup_location_id);
            WSH_DEBUG_SV.log(l_module_name,'p_delivery_info ultimate_dropoff_location_id', p_delivery_info.ultimate_dropoff_location_id);
            WSH_DEBUG_SV.log(l_module_name,'l_delivery_info ultimate_dropoff_location_id', l_delivery_info.ultimate_dropoff_location_id);
            WSH_DEBUG_SV.log(l_module_name,'p_delivery_info freight_terms_code', p_delivery_info.freight_terms_code);
            WSH_DEBUG_SV.log(l_module_name,'l_delivery_info freight_terms_code', l_delivery_info.freight_terms_code);
            WSH_DEBUG_SV.log(l_module_name,'p_delivery_info fob_code', p_delivery_info.fob_code);
            WSH_DEBUG_SV.log(l_module_name,'l_delivery_info fob_code', l_delivery_info.fob_code);
            WSH_DEBUG_SV.log(l_module_name,'p_delivery_info ship_method_code', p_delivery_info.ship_method_code);
            WSH_DEBUG_SV.log(l_module_name,'l_delivery_info ship_method_code', l_delivery_info.ship_method_code);
            WSH_DEBUG_SV.log(l_module_name,'p_delivery_info carrier_id', p_delivery_info.carrier_id);
            WSH_DEBUG_SV.log(l_module_name,'l_delivery_info carrier_id', l_delivery_info.carrier_id);
            WSH_DEBUG_SV.log(l_module_name,'p_delivery_info service_level', p_delivery_info.service_level);
            WSH_DEBUG_SV.log(l_module_name,'l_delivery_info service_level', l_delivery_info.service_level);
            WSH_DEBUG_SV.log(l_module_name,'p_delivery_info mode_of_transport', p_delivery_info.mode_of_transport);
            WSH_DEBUG_SV.log(l_module_name,'l_delivery_info mode_of_transport', l_delivery_info.mode_of_transport);
            WSH_DEBUG_SV.log(l_module_name,'p_delivery_info earliest_pickup_date', p_delivery_info.earliest_pickup_date);
            WSH_DEBUG_SV.log(l_module_name,'l_delivery_info earliest_pickup_date', l_delivery_info.earliest_pickup_date);
            WSH_DEBUG_SV.log(l_module_name,'p_delivery_info latest_pickup_date', p_delivery_info.latest_pickup_date);
            WSH_DEBUG_SV.log(l_module_name,'l_delivery_info latest_pickup_date', l_delivery_info.latest_pickup_date);
            WSH_DEBUG_SV.log(l_module_name,'p_delivery_info earliest_dropoff_date', p_delivery_info.earliest_dropoff_date);
            WSH_DEBUG_SV.log(l_module_name,'l_delivery_info earliest_dropoff_date', l_delivery_info.earliest_dropoff_date);
            WSH_DEBUG_SV.log(l_module_name,'p_delivery_info latest_dropoff_date', p_delivery_info.latest_dropoff_date);
            WSH_DEBUG_SV.log(l_module_name,'l_delivery_info latest_dropoff_date', l_delivery_info.latest_dropoff_date);
            WSH_DEBUG_SV.log(l_module_name,'l_delivery_info client_id', p_delivery_info.client_id); -- Modified R12.1.1 LSP PROJECT
          END IF;

          IF (NVL(l_delivery_info.tms_interface_flag,
                  WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT) IN
                  (WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_IN_PROCESS,
                   WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_IN_PROCESS,
                   WSH_NEW_DELIVERIES_PVT.C_TMS_AWAITING_ANSWER,
                   WSH_NEW_DELIVERIES_PVT.C_TMS_ANSWER_RECEIVED)) THEN
            l_tms_update := 'Y';
            l_delivery_info_tab(1) := l_delivery_info;
            l_new_interface_flag_tab(1) := WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED;
            l_tms_version_number := NVL(l_delivery_info.tms_version_number, 1) + 1;
          ELSE
            l_tms_update := 'N';
          END IF;
        END IF;
      END IF;
    END IF;
    --END OTM R12

    UPDATE wsh_new_deliveries
    SET
	 delivery_id                  = p_delivery_info.delivery_id
	,name                         = p_delivery_info.name
	,planned_flag                 = p_delivery_info.planned_flag
	,status_code                  = p_delivery_info.status_code
	,delivery_type                = p_delivery_info.delivery_type
	,loading_sequence             = p_delivery_info.loading_sequence
	,loading_order_flag           = p_delivery_info.loading_order_flag
	,initial_pickup_date          = p_delivery_info.initial_pickup_date
	,initial_pickup_location_id   = p_delivery_info.initial_pickup_location_id
	,organization_id              = p_delivery_info.organization_id
	,ultimate_dropoff_location_id = p_delivery_info.ultimate_dropoff_location_id
	,ultimate_dropoff_date        = p_delivery_info.ultimate_dropoff_date
	,customer_id                  = p_delivery_info.customer_id
	,intmed_ship_to_location_id   = p_delivery_info.intmed_ship_to_location_id
	,pooled_ship_to_location_id   = p_delivery_info.pooled_ship_to_location_id
	,carrier_id                   = p_delivery_info.carrier_id
	,ship_method_code             = p_delivery_info.ship_method_code
	,freight_terms_code           = p_delivery_info.freight_terms_code
	,fob_code                     = p_delivery_info.fob_code
	,fob_location_id              = p_delivery_info.fob_location_id
	,waybill                      = p_delivery_info.waybill
	,dock_code                    = p_delivery_info.dock_code
	,acceptance_flag              = p_delivery_info.acceptance_flag
	,accepted_by                  = p_delivery_info.accepted_by
	,accepted_date                = p_delivery_info.accepted_date
	,acknowledged_by              = p_delivery_info.acknowledged_by
	,confirmed_by                 = p_delivery_info.confirmed_by
	,confirm_date                 = p_delivery_info.confirm_date
	,asn_date_sent                = p_delivery_info.asn_date_sent
	,asn_status_code              = p_delivery_info.asn_status_code
	,asn_seq_number               = p_delivery_info.asn_seq_number
	,gross_weight                 = l_gross_weight -- Bugfix #4587421
	,net_weight                   = l_net_weight   -- Bugfix #4587421
	,weight_uom_code              = p_delivery_info.weight_uom_code
	,volume                       = p_delivery_info.volume
	,volume_uom_code              = p_delivery_info.volume_uom_code
	,additional_shipment_info     = p_delivery_info.additional_shipment_info
	,currency_code                = p_delivery_info.currency_code
	,attribute_category           = p_delivery_info.attribute_category
	,attribute1                   = p_delivery_info.attribute1
	,attribute2                   = p_delivery_info.attribute2
	,attribute3                   = p_delivery_info.attribute3
	,attribute4                   = p_delivery_info.attribute4
	,attribute5                   = p_delivery_info.attribute5
	,attribute6                   = p_delivery_info.attribute6
	,attribute7                   = p_delivery_info.attribute7
	,attribute8                   = p_delivery_info.attribute8
	,attribute9                   = p_delivery_info.attribute9
	,attribute10                  = p_delivery_info.attribute10
	,attribute11                  = p_delivery_info.attribute11
	,attribute12                  = p_delivery_info.attribute12
	,attribute13                  = p_delivery_info.attribute13
	,attribute14                  = p_delivery_info.attribute14
	,attribute15                  = p_delivery_info.attribute15
	,tp_attribute_category        = p_delivery_info.tp_attribute_category
	,tp_attribute1                = p_delivery_info.tp_attribute1
	,tp_attribute2                = p_delivery_info.tp_attribute2
	,tp_attribute3                = p_delivery_info.tp_attribute3
	,tp_attribute4                = p_delivery_info.tp_attribute4
	,tp_attribute5                = p_delivery_info.tp_attribute5
	,tp_attribute6                = p_delivery_info.tp_attribute6
	,tp_attribute7                = p_delivery_info.tp_attribute7
	,tp_attribute8                = p_delivery_info.tp_attribute8
	,tp_attribute9                = p_delivery_info.tp_attribute9
	,tp_attribute10               = p_delivery_info.tp_attribute10
	,tp_attribute11               = p_delivery_info.tp_attribute11
	,tp_attribute12               = p_delivery_info.tp_attribute12
	,tp_attribute13               = p_delivery_info.tp_attribute13
	,tp_attribute14               = p_delivery_info.tp_attribute14
	,tp_attribute15               = p_delivery_info.tp_attribute15
	,global_attribute_category    = p_delivery_info.global_attribute_category
	,global_attribute1            = p_delivery_info.global_attribute1
	,global_attribute2            = p_delivery_info.global_attribute2
	,global_attribute3            = p_delivery_info.global_attribute3
	,global_attribute4            = p_delivery_info.global_attribute4
	,global_attribute5            = p_delivery_info.global_attribute5
	,global_attribute6            = p_delivery_info.global_attribute6
	,global_attribute7            = p_delivery_info.global_attribute7
	,global_attribute8            = p_delivery_info.global_attribute8
	,global_attribute9            = p_delivery_info.global_attribute9
	,global_attribute10           = p_delivery_info.global_attribute10
	,global_attribute11           = p_delivery_info.global_attribute11
	,global_attribute12           = p_delivery_info.global_attribute12
	,global_attribute13           = p_delivery_info.global_attribute13
	,global_attribute14           = p_delivery_info.global_attribute14
	,global_attribute15           = p_delivery_info.global_attribute15
	,global_attribute16           = p_delivery_info.global_attribute16
	,global_attribute17           = p_delivery_info.global_attribute17
	,global_attribute18           = p_delivery_info.global_attribute18
	,global_attribute19           = p_delivery_info.global_attribute19
	,global_attribute20           = p_delivery_info.global_attribute20
	,last_update_date             = p_delivery_info.last_update_date
	,last_updated_by              = p_delivery_info.last_updated_by
	,last_update_login            = p_delivery_info.last_update_login
	,program_application_id       = p_delivery_info.program_application_id
	,program_id                   = p_delivery_info.program_id
	,program_update_date          = p_delivery_info.program_update_date
	,request_id                   = p_delivery_info.request_id
	,number_of_lpn                = p_delivery_info.number_of_lpn
/* Changes for the Shipping Data Model Bug#1918342*/
	,COD_AMOUNT                   = p_delivery_info.COD_AMOUNT
	,COD_CURRENCY_CODE            = p_delivery_info.COD_CURRENCY_CODE
	,COD_REMIT_TO                 = p_delivery_info.COD_REMIT_TO
	,COD_CHARGE_PAID_BY           = p_delivery_info.COD_CHARGE_PAID_BY
	,PROBLEM_CONTACT_REFERENCE    = p_delivery_info.PROBLEM_CONTACT_REFERENCE
	,PORT_OF_LOADING              = p_delivery_info.PORT_OF_LOADING
	,PORT_OF_DISCHARGE            = p_delivery_info.PORT_OF_DISCHARGE
        ,FTZ_NUMBER                   = p_delivery_info.FTZ_NUMBER
        ,ROUTED_EXPORT_TXN            = p_delivery_info.ROUTED_EXPORT_TXN
        ,ENTRY_NUMBER                 = p_delivery_info.ENTRY_NUMBER
        ,ROUTING_INSTRUCTIONS         = p_delivery_info.ROUTING_INSTRUCTIONS
        ,IN_BOND_CODE                 = p_delivery_info.IN_BOND_CODE
        ,SHIPPING_MARKS               = p_delivery_info.SHIPPING_MARKS
/* H Integration: datamodel changes wrudge */
	,SERVICE_LEVEL		      = p_delivery_info.SERVICE_LEVEL
	,MODE_OF_TRANSPORT	      = p_delivery_info.MODE_OF_TRANSPORT
	,ASSIGNED_TO_FTE_TRIPS	      = p_delivery_info.ASSIGNED_TO_FTE_TRIPS
        ,auto_sc_exclude_flag         = p_delivery_info.auto_sc_exclude_flag
        ,auto_ap_exclude_flag         = p_delivery_info.auto_ap_exclude_flag
/* J Inbound Logistics new columns jckwok*/
        ,SHIPMENT_DIRECTION           = nvl(p_delivery_info.SHIPMENT_DIRECTION, 'O')
        ,VENDOR_ID                    = p_delivery_info.VENDOR_ID
        ,PARTY_ID                     = p_delivery_info.PARTY_ID
        ,ROUTING_RESPONSE_ID          = p_delivery_info.ROUTING_RESPONSE_ID
        ,RCV_SHIPMENT_HEADER_ID       = p_delivery_info.RCV_SHIPMENT_HEADER_ID
        ,ASN_SHIPMENT_HEADER_ID       = p_delivery_info.ASN_SHIPMENT_HEADER_ID
        ,SHIPPING_CONTROL             = p_delivery_info.SHIPPING_CONTROL
/* J TP Release : ttrichy */
        ,TP_DELIVERY_NUMBER           = p_delivery_info.TP_DELIVERY_NUMBER
        ,EARLIEST_PICKUP_DATE         = p_delivery_info.EARLIEST_PICKUP_DATE
        ,LATEST_PICKUP_DATE           = p_delivery_info.LATEST_PICKUP_DATE
        ,EARLIEST_DROPOFF_DATE        = p_delivery_info.EARLIEST_DROPOFF_DATE
        ,LATEST_DROPOFF_DATE          = p_delivery_info.LATEST_DROPOFF_DATE
        ,IGNORE_FOR_PLANNING          = nvl(p_delivery_info.IGNORE_FOR_PLANNING, 'N')
        ,TP_PLAN_NAME                 = p_delivery_info.TP_PLAN_NAME
/* J: W/V Changes */
        ,WV_FROZEN_FLAG               = l_frozen_flag
        ,HASH_VALUE                   = p_delivery_info.HASH_VALUE
        ,HASH_STRING                  = p_delivery_info.HASH_STRING
        ,delivered_date               = p_delivery_info.delivered_date
 -- bug 3667348
        ,REASON_OF_TRANSPORT		=p_delivery_info.REASON_OF_TRANSPORT
        ,DESCRIPTION			=p_delivery_info.DESCRIPTION
-- bug 3667348
--OTM R12
        ,TMS_INTERFACE_FLAG = DECODE(l_tms_update,
                                     'Y', l_new_interface_flag_tab(1),
                                     NVL(TMS_INTERFACE_FLAG, WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT))
        ,TMS_VERSION_NUMBER = DECODE(l_tms_update,
                                     'Y', l_tms_version_number,
                                     NVL(tms_version_number, 1))
        ,CLIENT_ID          = p_delivery_info.client_id  -- LSP PROJECT --Modified R12.1.1 LSP PROJECT(rminocha)
--
    WHERE rowid = l_rowid;

    IF (SQL%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
    END IF;

   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Rows updated',SQL%ROWCOUNT);
       WSH_DEBUG_SV.logmsg(l_module_name,'Org Gross '||l_gross_wt||' New Gross '||p_delivery_info.gross_weight||' Org Net '||l_net_wt||' New Net '||p_delivery_info.net_weight||' Org Vol '||l_volume||' New Vol '||p_delivery_info.volume);

   END IF;

   --OTM R12
   IF (l_gc3_is_installed = 'Y' AND l_tms_update = 'Y') THEN

     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.LOG_OTM_EXCEPTION',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

     WSH_XC_UTIL.log_otm_exception(
       p_delivery_info_tab      => l_delivery_info_tab,
       p_new_interface_flag_tab => l_new_interface_flag_tab,
       x_return_status          => l_return_status);

     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_XC_UTIL.LOG_OTM_EXCEPTION',l_return_status);
     END IF;

     IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_XC_UTIL.log_otm_exception');
       END IF;
       RAISE api_return_fail;
     END IF;
   END IF;
   --END OTM R12

   /*CURRENTLY NOT IN USE
   --WF: CMR
   WSH_WF_STD.Get_Carrier(p_del_ids => l_del_ids,
                          x_del_old_carrier_ids => l_del_new_carrier_ids,
                          x_return_status => l_wf_rs);
   WSH_WF_STD.Assign_Unassign_Carrier(p_delivery_id => p_delivery_info.delivery_id,
			              p_old_carrier_id => l_del_old_carrier_ids(1),
                                      p_new_carrier_id =>
l_del_new_carrier_ids(1),
                                      x_return_status => l_wf_rs);
   */
   -- J: W/V Changes
   -- If UOM changes then compute the delta (difference between new W/V and old W/V)
   IF ( NVL(l_weight_uom_code,'-99') <> NVL(p_delivery_info.weight_uom_code,'-99')  AND
        l_gross_weight is not null ) THEN -- BugFix #4587421
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.convert_uom',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     l_diff_gross_wt := WSH_WV_UTILS.convert_uom(
                          from_uom => p_delivery_info.weight_uom_code,
                          to_uom   => l_weight_uom_code,
                          quantity => l_gross_weight) - NVL(l_gross_wt,0); -- BugFix #4587421

     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.convert_uom',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     l_diff_net_wt := WSH_WV_UTILS.convert_uom(
                          from_uom => p_delivery_info.weight_uom_code,
                          to_uom   => l_weight_uom_code,
                          quantity => l_net_weight) - NVL(l_net_wt,0); -- BigFix #4587421
   ELSE
     l_diff_gross_wt := NVL(l_gross_weight,0) - NVL(l_gross_wt,0); -- BigFix #4587421
     l_diff_net_wt   := NVL(l_net_weight,0) - NVL(l_net_wt,0); -- BigFix #4587421
   END IF;

   IF (NVL(l_volume_uom_code,'-99') <> NVL(p_delivery_info.volume_uom_code,'-99') AND
       p_delivery_info.volume is not null) THEN
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.convert_uom',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     l_diff_vol := WSH_WV_UTILS.convert_uom(
                     from_uom => p_delivery_info.volume_uom_code,
                     to_uom   => l_volume_uom_code,
                     quantity => p_delivery_info.volume) - NVL(l_volume,0);
   ELSE
     l_diff_vol := NVL(p_delivery_info.volume,0) - NVL(l_volume,0);
   END IF;

   -- Call DEL_WV_Post_Process to adjust W/V on parent entities
   IF l_diff_gross_wt is not null OR l_diff_net_wt is not null OR l_diff_vol is not null THEN

     --
     -- Bug No:4085560 - 11.5.10.1CU:INCORRECT WT SHOWN FOR THE STOP(start)
     --
     IF (l_weight_uom_code<>p_delivery_info.weight_uom_code) THEN

	  IF (l_diff_gross_wt IS NOT NULL) THEN
		 l_diff_gross_wt := WSH_WV_UTILS.convert_uom( from_uom => l_weight_uom_code,
						 to_uom  =>p_delivery_info.weight_uom_code,
						 quantity => l_diff_gross_wt);
	  END IF;

	  IF (l_diff_net_wt IS NOT NULL) THEN
	 	     l_diff_net_wt := WSH_WV_UTILS.convert_uom( from_uom => l_weight_uom_code,
					  	  to_uom  =>p_delivery_info.weight_uom_code,
						  quantity => l_diff_net_wt);
	  END IF;
     END IF;

     IF (l_volume_uom_code<>p_delivery_info.volume_uom_code AND l_diff_vol IS NOT NULL) THEN
		l_diff_vol:= WSH_WV_UTILS.convert_uom( from_uom => l_volume_uom_code,
					       to_uom  => p_delivery_info.volume_uom_code,
					       quantity => l_diff_vol);

     END IF;

     --
     -- Bug No:4085560 - 11.5.10.1CU:INCORRECT WT SHOWN FOR THE STOP(end)
     --

     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DEL_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

     WSH_WV_UTILS.DEL_WV_Post_Process(
       p_delivery_id   => p_delivery_info.delivery_id,
       p_diff_gross_wt => l_diff_gross_wt,
       p_diff_net_wt   => l_diff_net_wt,
       p_diff_volume   => l_diff_vol,
       x_return_status => l_return_status);

     IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
       raise e_wt_vol_fail;
     END IF;

   END IF;
   --

   -- "Proration of weight from Delivery to delivery lines" Project(Bug#4254552).
   -- Do the Proration only for the 'Standard' Deliveries.

   IF NVL(p_delivery_info.delivery_type, 'STANDARD')='STANDARD' AND NVL(p_delivery_info.PRORATE_WT_FLAG,'N')='Y'
			AND (nvl(l_diff_gross_wt,0) <> 0 OR nvl(l_diff_net_wt,0) <> 0) THEN --{
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.prorate_weight',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_WV_UTILS.prorate_weight(
	       p_entity_type	  => 'DELIVERY',
		p_entity_id       => p_delivery_info.delivery_id,
		p_old_gross_wt    => l_gross_wt,
		p_new_gross_wt    => l_gross_weight, -- BigFix #4587421
		p_old_net_wt	  => l_net_wt,
		p_new_net_wt      => l_net_weight, -- BigFix #4587421
		p_weight_uom_code => l_weight_uom_code,
		x_return_status   => l_return_status);
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           x_return_status := l_return_status;
	   --
	   IF l_debug_on THEN
	    wsh_debug_sv.log(l_module_name,'Return Status After Calling WSH_WV_UTILS.prorate_weight',l_return_status);
	   END IF;
	   --
            wsh_util_core.api_post_call(
	     p_return_status    => l_return_status,
	     x_num_warnings     => l_num_warnings,
	     x_num_errors       => l_num_errors);
	   --
       END IF;
   END IF; --}

   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --

  EXCEPTION
    --OTM R12
    WHEN api_return_fail THEN
      x_return_status := l_return_status;
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
    --END OTM R12
-- J: W/V Changes
    WHEN e_wt_vol_fail THEN
       FND_MESSAGE.Set_Name('WSH','WSH_DEL_WT_VOL_FAILED');
       FND_MESSAGE.Set_Token('DEL_NAME', p_delivery_info.name);
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       WSH_UTIL_CORE.add_message (x_return_status);
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'E_WT_VOL_FAIL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_WT_VOL_FAIL');
       END IF;

    WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('WSH','WSH_DEL_NOT_FOUND');
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	  WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'NO_DATA_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
	  END IF;
	  --

     --Bug # 3268641
     WHEN DUP_VAL_ON_INDEX THEN
           FND_MESSAGE.SET_NAME('WSH','WSH_ASSIGN_NEW_DEL');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

	   IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'DUP_VAL_ON_INDEX exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DUP_VAL_ON_INDEX');
	   END IF;
     --

    WHEN others THEN
	  wsh_util_core.default_handler('WSH_NEW_DELIVERIES_PVT.UPDATE_DELIVERY',l_module_name);
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
          END IF;
          --
  END Update_Delivery;


--
--  Procedure:		Delete_Delivery
--  Parameters:		p_rowid - Rowid for delivery to be Deleted
--			p_delivery_id - Delivery_id of delivery to be deleted
--			x_return_status - Status of procedure call
--             p_validate_flag - calls validate procedure if 'Y'
--  Description:	This procedure will delete a delivery.
--                      The order in which it looks at the parameters
--                      are:
--                      - p_rowid
--                      - p_delivery_id
--

  PROCEDURE Delete_Delivery
		(p_rowid		IN	VARCHAR2 := NULL,
		 p_delivery_id		IN	NUMBER := NULL,
		 x_return_status		OUT NOCOPY 	VARCHAR2,
		 p_validate_flag    IN   VARCHAR2 DEFAULT 'Y'
		) IS

  CURSOR get_del_id_rowid (v_rowid VARCHAR2) IS
  SELECT delivery_id
  FROM   wsh_new_deliveries
  WHERE  rowid = v_rowid;

  CURSOR get_delivery_legs (v_delivery_id NUMBER) IS
  SELECT delivery_leg_id, parent_delivery_leg_id
  FROM   wsh_delivery_legs
  WHERE  delivery_id = v_delivery_id;

  CURSOR detail_info(v_delivery_id NUMBER) IS
  SELECT delivery_detail_id
  FROM   wsh_delivery_assignments_v
  WHERE  delivery_id = v_delivery_id
         and parent_delivery_detail_id is NULL;




  l_delivery_id		NUMBER;
  l_delivery_leg_id	NUMBER;
  l_mdc_del_tab         WSH_UTIL_CORE.id_tab_type;

  cannot_delete_delivery EXCEPTION;
  others EXCEPTION;

  l_num_warn NUMBER := 0;
  l_return_status       VARCHAR2(1);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_DELIVERY';
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
         WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
         WSH_DEBUG_SV.log(l_module_name,'P_VALIDATE_FLAG',P_VALIDATE_FLAG);
     END IF;
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     g_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     l_num_warn := 0;

     -- map rowid to a delivery_id
     IF p_rowid IS NOT NULL THEN
        OPEN  get_del_id_rowid(p_rowid);
        FETCH get_del_id_rowid INTO l_delivery_id;
        CLOSE get_del_id_rowid;
     END IF;

     IF l_delivery_id IS NULL THEN
        l_delivery_id := p_delivery_id;
     END IF;

     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_delivery_id',l_delivery_id);
     END IF;

     IF (p_validate_flag = 'Y') THEN
        wsh_delivery_validations.check_delete_delivery(
          p_delivery_id   => l_delivery_id,
          x_return_status => l_return_status);
        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
           RAISE cannot_delete_delivery;
        ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
           l_num_warn := l_num_warn + 1;
        END IF;
     END IF;

     SAVEPOINT wsh_before_delivery_delete;

     IF l_delivery_id IS NOT NULL THEN --{

          -- bug 4416863 detail unassignment is moved before deletion of delivery legs
          -- because if deletion of delivery legs is called first, it will break the link between
          -- the delivery and trip stop so that w/v is not calculated correctly for the stops.

          -- unassign all delivery detials

          SAVEPOINT unassign_details;

          FOR dt IN detail_info(l_delivery_id) LOOP
            wsh_delivery_details_actions.unassign_detail_from_delivery
              (p_detail_id => dt.delivery_detail_id,
               x_return_status => l_return_status);

            IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
                OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                  x_return_status := l_return_status;
                  ROLLBACK TO SAVEPOINT unassign_details;
                  FND_MESSAGE.SET_NAME('WSH','WSH_DEL_UNASSIGN_DET_ERROR');
                  FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(l_delivery_id));
                  FND_MESSAGE.SET_TOKEN('DET_NAME',dt.delivery_detail_id);
                  wsh_util_core.add_message(x_return_status,l_module_name);
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,'x_return_status',
                                                           x_return_status);
                      WSH_DEBUG_SV.pop(l_module_name);
                  END IF;
                  --
                  RETURN;
            ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              l_num_warn := l_num_warn + 1;
            END IF;

          END LOOP;
          -- end bug 4416863

        -- delete all Delivery Legs for the delivery

        FOR dl IN get_delivery_legs (l_delivery_id) LOOP
          IF dl.parent_delivery_leg_id IS NOT NULL THEN
          -- MDC: Unassign the delivery from the parent delivery
          --      if it exists.
             l_mdc_del_tab(1) := l_delivery_id;
             WSH_NEW_DELIVERY_ACTIONS.Unassign_Dels_from_Consol_Del(
                       p_parent_del     => NULL,
                       p_caller         => 'WSH_DELETE_DEL',
                       p_del_tab        => l_mdc_del_tab,
                       x_return_status  => l_return_status);
             l_mdc_del_tab.delete;
             IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                 ROLLBACK TO wsh_before_delivery_delete;
                 RAISE cannot_delete_delivery;
             ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                 l_num_warn := l_num_warn + 1;
             END IF;

          END IF;

	  WSH_DELIVERY_LEGS_PVT.Delete_Delivery_Leg(
			p_delivery_leg_id => dl.delivery_leg_id,
			x_return_status   => l_return_status);
 IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
) THEN
	    ROLLBACK TO wsh_before_delivery_delete;

	    RAISE cannot_delete_delivery;
	  ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	    l_num_warn := l_num_warn + 1;
	  END IF;
	END LOOP;

        -- delete freight costs associated with delivery (bug 4376236)
        DELETE FROM wsh_freight_costs
        WHERE delivery_id = l_delivery_id;
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,
                            'Freight cost rows deleted', SQL%ROWCOUNT);
        END IF;

	-- delete the delivery
        DELETE FROM wsh_new_deliveries
        WHERE  delivery_id = l_delivery_id;
        --

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Rows deleted',SQL%ROWCOUNT);
        END IF;

     ELSE
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Raise Others');
          END IF;
	  RAISE others;
     END IF; --} l_delivery_id IS NOT NULL
/* Bug 2310456 warning */
  IF l_num_warn > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
     WHEN cannot_delete_delivery THEN

       IF (get_del_id_rowid%ISOPEN) THEN
         CLOSE get_del_id_rowid;
       END IF;

       IF (get_delivery_legs%ISOPEN) THEN
         CLOSE get_delivery_legs;
       END IF;

       IF (detail_info%ISOPEN) THEN
         CLOSE detail_info;
       END IF;

       FND_MESSAGE.SET_NAME('WSH','WSH_DEL_DELETE_ERROR');
       FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(l_delivery_id));
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       wsh_util_core.add_message(x_return_status,l_module_name);
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'CANNOT_DELETE_DELIVERY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CANNOT_DELETE_DELIVERY');
       END IF;
       --

     WHEN others THEN
       ROLLBACK TO wsh_before_delivery_delete;

       IF (get_del_id_rowid%ISOPEN) THEN
         CLOSE get_del_id_rowid;
       END IF;

       IF (get_delivery_legs%ISOPEN) THEN
         CLOSE get_delivery_legs;
       END IF;

       IF (detail_info%ISOPEN) THEN
         CLOSE detail_info;
       END IF;

       wsh_util_core.default_handler('WSH_NEW_DELIVERIES_PVT.DELETE_DELIVERY',l_module_name);
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
       --
  END Delete_Delivery;


--
--  Procedure:		Lock_Delivery
--  Parameters:		p_rowid - Rowid for delivery to be locked
--			p_delivery_info - All Attributes of a Delivery Record
--			x_return_status - Status of procedure call
--  Description:	This procedure will lock a delivery record. It is
--			specifically designed for use by the form.
--

  PROCEDURE Lock_Delivery
		(p_rowid		IN	VARCHAR2,
		 p_delivery_info	IN	Delivery_Rec_Type
		) IS

  CURSOR lock_row IS
  SELECT *
  FROM wsh_new_deliveries
  WHERE rowid = p_rowid
  FOR UPDATE OF delivery_id NOWAIT;

  Recinfo lock_row%ROWTYPE;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_DELIVERY';
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
	CLOSE lock_row;
        FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'FORM_RECORD_DELETED');
        END IF;
	app_exception.raise_exception;
     END IF;

     CLOSE lock_row;

     IF (
                (Recinfo.delivery_id = p_delivery_info.delivery_id)
         AND    (Recinfo.name = p_delivery_info.name)
         AND    (Recinfo.planned_flag = p_delivery_info.planned_flag)
         AND    (Recinfo.status_code = p_delivery_info.status_code)
         AND    (Recinfo.delivery_type = p_delivery_info.delivery_type)
         AND (  (Recinfo.loading_sequence = p_delivery_info.loading_sequence)
              OR (  (Recinfo.loading_sequence IS NULL)
                  AND  (p_delivery_info.loading_sequence IS NULL)))
         AND (  (Recinfo.loading_order_flag = p_delivery_info.loading_order_flag)
              OR (  (Recinfo.loading_order_flag IS NULL)
                  AND  (p_delivery_info.loading_order_flag IS NULL)))
         AND (  (Recinfo.initial_pickup_date = p_delivery_info.initial_pickup_date)
              OR (  (Recinfo.initial_pickup_date IS NULL)
                  AND  (p_delivery_info.initial_pickup_date IS NULL)))
         AND    (Recinfo.initial_pickup_location_id = p_delivery_info.initial_pickup_location_id)
         AND (  (Recinfo.organization_id = p_delivery_info.organization_id)
              OR (  (Recinfo.organization_id IS NULL)
                  AND  (p_delivery_info.organization_id IS NULL)))
         AND    (Recinfo.ultimate_dropoff_location_id = p_delivery_info.ultimate_dropoff_location_id)
         AND (  (Recinfo.Ultimate_dropoff_date = p_delivery_info.ultimate_dropoff_date)
              OR (  (Recinfo.ultimate_dropoff_date IS NULL)
                  AND  (p_delivery_info.ultimate_dropoff_date IS NULL)))
         AND (  (Recinfo.customer_id = p_delivery_info.customer_id)
              OR (  (Recinfo.customer_id IS NULL)
                  AND  (p_delivery_info.customer_id IS NULL)))
         AND (  (Recinfo.intmed_ship_to_location_id = p_delivery_info.intmed_ship_to_location_id)
              OR (  (Recinfo.intmed_ship_to_location_id IS NULL)
                  AND  (p_delivery_info.intmed_ship_to_location_id IS NULL)))
         AND (  (Recinfo.pooled_ship_to_location_id = p_delivery_info.pooled_ship_to_location_id)
              OR (  (Recinfo.pooled_ship_to_location_id IS NULL)
                  AND  (p_delivery_info.pooled_ship_to_location_id IS NULL)))
         AND (  (Recinfo.carrier_id = p_delivery_info.carrier_id)
              OR (  (Recinfo.carrier_id IS NULL)
                  AND  (p_delivery_info.carrier_id IS NULL)))
         AND (  (Recinfo.ship_method_code = p_delivery_info.ship_method_code)
              OR (  (Recinfo.ship_method_code IS NULL)
                  AND  (p_delivery_info.ship_method_code IS NULL)))
         AND (  (Recinfo.freight_terms_code = p_delivery_info.freight_terms_code)
              OR (  (Recinfo.freight_terms_code IS NULL)
                  AND  (p_delivery_info.freight_terms_code IS NULL)))
         AND (  (Recinfo.fob_code = p_delivery_info.fob_code)
              OR (  (Recinfo.fob_code IS NULL)
                  AND  (p_delivery_info.fob_code IS NULL)))
         AND (  (Recinfo.fob_location_id = p_delivery_info.fob_location_id)
              OR (  (Recinfo.fob_location_id IS NULL)
                  AND  (p_delivery_info.fob_location_id IS NULL)))
         AND (  (recinfo.waybill = p_delivery_info.waybill)
              OR (  (recinfo.waybill is NULL)
                  AND  (p_delivery_info.waybill is NULL)))
         AND (  (Recinfo.dock_code = p_delivery_info.dock_code)
              OR (  (Recinfo.dock_code IS NULL)
                  AND  (p_delivery_info.dock_code IS NULL)))
         AND (  (Recinfo.acceptance_flag = p_delivery_info.acceptance_flag)
              OR (  (Recinfo.acceptance_flag IS NULL)
                  AND  (p_delivery_info.acceptance_flag IS NULL)))
         AND (  (Recinfo.accepted_by = p_delivery_info.accepted_by)
              OR (  (Recinfo.accepted_by IS NULL)
                  AND  (p_delivery_info.accepted_by IS NULL)))
         AND (  (Recinfo.accepted_date = p_delivery_info.accepted_date)
              OR (  (Recinfo.accepted_date IS NULL)
                  AND  (p_delivery_info.accepted_date IS NULL)))
         AND (  (recinfo.acknowledged_by = p_delivery_info.acknowledged_by)
              OR (  (recinfo.acknowledged_by is NULL)
                  AND  (p_delivery_info.acknowledged_by is NULL)))
         AND (  (recinfo.confirmed_by = p_delivery_info.confirmed_by)
              OR (  (recinfo.confirmed_by is NULL)
                  AND  (p_delivery_info.confirmed_by is NULL)))
         AND (  (recinfo.confirm_date = p_delivery_info.confirm_date)
              OR (  (recinfo.confirm_date is NULL)
                  AND  (p_delivery_info.confirm_date is NULL)))
         AND (  (recinfo.asn_date_sent = p_delivery_info.asn_date_sent)
              OR (  (recinfo.asn_date_sent is NULL)
                  AND  (p_delivery_info.asn_date_sent is NULL)))
         AND (  (recinfo.asn_status_code = p_delivery_info.asn_status_code)
              OR (  (recinfo.asn_status_code is NULL)
                  AND  (p_delivery_info.asn_status_code is NULL)))
         AND (  (recinfo.asn_seq_number = p_delivery_info.asn_seq_number)
              OR (  (recinfo.asn_seq_number is NULL)
                  AND  (p_delivery_info.asn_seq_number is NULL)))
         AND (  (recinfo.gross_weight = p_delivery_info.gross_weight)
              OR (  (recinfo.gross_weight is NULL)
                  AND  (p_delivery_info.gross_weight is NULL)))
         AND (  (recinfo.net_weight = p_delivery_info.net_weight)
              OR (  (recinfo.net_weight is NULL)
                  AND  (p_delivery_info.net_weight is NULL)))
         AND (  (recinfo.weight_uom_code = p_delivery_info.weight_uom_code)
              OR (  (recinfo.weight_uom_code is NULL)
                  AND  (p_delivery_info.weight_uom_code is NULL)))
         AND (  (recinfo.volume = p_delivery_info.volume)
              OR (  (recinfo.volume is NULL)
                  AND  (p_delivery_info.volume is NULL)))
         AND (  (recinfo.volume_uom_code = p_delivery_info.volume_uom_code)
              OR (  (recinfo.volume_uom_code is NULL)
                  AND  (p_delivery_info.volume_uom_code is NULL)))
         AND (  (recinfo.additional_shipment_info = p_delivery_info.additional_shipment_info)
              OR (  (recinfo.additional_shipment_info is NULL)
                  AND  (p_delivery_info.additional_shipment_info is NULL)))
         AND (  (recinfo.currency_code = p_delivery_info.currency_code)
              OR (  (recinfo.currency_code is NULL)
                  AND  (p_delivery_info.currency_code is NULL)))
         AND (  (recinfo.attribute_category = p_delivery_info.attribute_category)
              OR (  (recinfo.attribute_category is NULL)
                  AND  (p_delivery_info.attribute_category is NULL)))
         AND (  (recinfo.attribute1 = p_delivery_info.attribute1)
              OR (  (recinfo.attribute1 is NULL)
                  AND  (p_delivery_info.attribute1 is NULL)))
         AND (  (recinfo.attribute2 = p_delivery_info.attribute2)
              OR (  (recinfo.attribute2 is NULL)
                  AND  (p_delivery_info.attribute2 is NULL)))
         AND (  (recinfo.attribute3 = p_delivery_info.attribute3)
              OR (  (recinfo.attribute3 is NULL)
                  AND  (p_delivery_info.attribute3 is NULL)))
         AND (  (recinfo.attribute4 = p_delivery_info.attribute4)
              OR (  (recinfo.attribute4 is NULL)
                  AND  (p_delivery_info.attribute4 is NULL)))
         AND (  (recinfo.attribute5 = p_delivery_info.attribute5)
              OR (  (recinfo.attribute5 is NULL)
                  AND  (p_delivery_info.attribute5 is NULL)))
         AND (  (recinfo.attribute6 = p_delivery_info.attribute6)
              OR (  (recinfo.attribute6 is NULL)
                  AND  (p_delivery_info.attribute6 is NULL)))
         AND (  (recinfo.attribute7 = p_delivery_info.attribute7)
              OR (  (recinfo.attribute7 is NULL)
                  AND  (p_delivery_info.attribute7 is NULL)))
         AND (  (recinfo.attribute8 = p_delivery_info.attribute8)
              OR (  (recinfo.attribute8 is NULL)
                  AND  (p_delivery_info.attribute8 is NULL)))
         AND (  (recinfo.attribute9 = p_delivery_info.attribute9)
              OR (  (recinfo.attribute9 is NULL)
                  AND  (p_delivery_info.attribute9 is NULL)))
         AND (  (recinfo.attribute10 = p_delivery_info.attribute10)
              OR (  (recinfo.attribute10 is NULL)
                  AND  (p_delivery_info.attribute10 is NULL)))
         AND (  (recinfo.attribute11 = p_delivery_info.attribute11)
              OR (  (recinfo.attribute11 is NULL)
                  AND  (p_delivery_info.attribute11 is NULL)))
         AND (  (recinfo.attribute12 = p_delivery_info.attribute12)
              OR (  (recinfo.attribute12 is NULL)
                  AND  (p_delivery_info.attribute12 is NULL)))
         AND (  (recinfo.attribute13 = p_delivery_info.attribute13)
              OR (  (recinfo.attribute13 is NULL)
                  AND  (p_delivery_info.attribute13 is NULL)))
         AND (  (recinfo.attribute14 = p_delivery_info.attribute14)
              OR (  (recinfo.attribute14 is NULL)
                  AND  (p_delivery_info.attribute14 is NULL)))
         AND (  (recinfo.attribute15 = p_delivery_info.attribute15)
              OR (  (recinfo.attribute15 is NULL)
                  AND  (p_delivery_info.attribute15 is NULL)))
         AND (  (recinfo.tp_attribute_category = p_delivery_info.tp_attribute_category)
              OR (  (recinfo.tp_attribute_category is NULL)
                  AND  (p_delivery_info.tp_attribute_category is NULL)))
         AND (  (recinfo.tp_attribute1 = p_delivery_info.tp_attribute1)
              OR (  (recinfo.tp_attribute1 is NULL)
                  AND  (p_delivery_info.tp_attribute1 is NULL)))
         AND (  (recinfo.tp_attribute2 = p_delivery_info.tp_attribute2)
              OR (  (recinfo.tp_attribute2 is NULL)
                  AND  (p_delivery_info.tp_attribute2 is NULL)))
         AND (  (recinfo.tp_attribute3 = p_delivery_info.tp_attribute3)
              OR (  (recinfo.tp_attribute3 is NULL)
                  AND  (p_delivery_info.tp_attribute3 is NULL)))
         AND (  (recinfo.tp_attribute4 = p_delivery_info.tp_attribute4)
              OR (  (recinfo.tp_attribute4 is NULL)
                  AND  (p_delivery_info.tp_attribute4 is NULL)))
         AND (  (recinfo.tp_attribute5 = p_delivery_info.tp_attribute5)
              OR (  (recinfo.tp_attribute5 is NULL)
                  AND  (p_delivery_info.tp_attribute5 is NULL)))
         AND (  (recinfo.tp_attribute6 = p_delivery_info.tp_attribute6)
              OR (  (recinfo.tp_attribute6 is NULL)
                  AND  (p_delivery_info.tp_attribute6 is NULL)))
         AND (  (recinfo.tp_attribute7 = p_delivery_info.tp_attribute7)
              OR (  (recinfo.tp_attribute7 is NULL)
                  AND  (p_delivery_info.tp_attribute7 is NULL)))
         AND (  (recinfo.tp_attribute8 = p_delivery_info.tp_attribute8)
              OR (  (recinfo.tp_attribute8 is NULL)
                  AND  (p_delivery_info.tp_attribute8 is NULL)))
         AND (  (recinfo.tp_attribute9 = p_delivery_info.tp_attribute9)
              OR (  (recinfo.tp_attribute9 is NULL)
                  AND  (p_delivery_info.tp_attribute9 is NULL)))
         AND (  (recinfo.tp_attribute10 = p_delivery_info.tp_attribute10)
              OR (  (recinfo.tp_attribute10 is NULL)
                  AND  (p_delivery_info.tp_attribute10 is NULL)))
         AND (  (recinfo.tp_attribute11 = p_delivery_info.tp_attribute11)
              OR (  (recinfo.tp_attribute11 is NULL)
                  AND  (p_delivery_info.tp_attribute11 is NULL)))
         AND (  (recinfo.tp_attribute12 = p_delivery_info.tp_attribute12)
              OR (  (recinfo.tp_attribute12 is NULL)
                  AND  (p_delivery_info.tp_attribute12 is NULL)))
         AND (  (recinfo.tp_attribute13 = p_delivery_info.tp_attribute13)
              OR (  (recinfo.tp_attribute13 is NULL)
                  AND  (p_delivery_info.tp_attribute13 is NULL)))
         AND (  (recinfo.tp_attribute14 = p_delivery_info.tp_attribute14)
              OR (  (recinfo.tp_attribute14 is NULL)
                  AND  (p_delivery_info.tp_attribute14 is NULL)))
         AND (  (recinfo.tp_attribute15 = p_delivery_info.tp_attribute15)
              OR (  (recinfo.tp_attribute15 is NULL)
                  AND  (p_delivery_info.tp_attribute15 is NULL)))
         AND (  (recinfo.global_attribute_category = p_delivery_info.global_attribute_category)
              OR (  (recinfo.global_attribute_category is NULL)
                  AND  (p_delivery_info.global_attribute_category is NULL)))
         AND (  (recinfo.global_attribute1 = p_delivery_info.global_attribute1)
              OR (  (recinfo.global_attribute1 is NULL)
                  AND  (p_delivery_info.global_attribute1 is NULL)))
         AND (  (recinfo.global_attribute2 = p_delivery_info.global_attribute2)
              OR (  (recinfo.global_attribute2 is NULL)
                  AND  (p_delivery_info.global_attribute2 is NULL)))
         AND (  (recinfo.global_attribute3 = p_delivery_info.global_attribute3)
              OR (  (recinfo.global_attribute3 is NULL)
                  AND  (p_delivery_info.global_attribute3 is NULL)))
         AND (  (recinfo.global_attribute4 = p_delivery_info.global_attribute4)
              OR (  (recinfo.global_attribute4 is NULL)
                  AND  (p_delivery_info.global_attribute4 is NULL)))
         AND (  (recinfo.global_attribute5 = p_delivery_info.global_attribute5)
              OR (  (recinfo.global_attribute5 is NULL)
                  AND  (p_delivery_info.global_attribute5 is NULL)))
         AND (  (recinfo.global_attribute6 = p_delivery_info.global_attribute6)
              OR (  (recinfo.global_attribute6 is NULL)
                  AND  (p_delivery_info.global_attribute6 is NULL)))
         AND (  (recinfo.global_attribute7 = p_delivery_info.global_attribute7)
              OR (  (recinfo.global_attribute7 is NULL)
                  AND  (p_delivery_info.global_attribute7 is NULL)))
         AND (  (recinfo.global_attribute8 = p_delivery_info.global_attribute8)
              OR (  (recinfo.global_attribute8 is NULL)
                  AND  (p_delivery_info.global_attribute8 is NULL)))
         AND (  (recinfo.global_attribute9 = p_delivery_info.global_attribute9)
              OR (  (recinfo.global_attribute9 is NULL)
                  AND  (p_delivery_info.global_attribute9 is NULL)))
         AND (  (recinfo.global_attribute10 = p_delivery_info.global_attribute10)
              OR (  (recinfo.global_attribute10 is NULL)
                  AND  (p_delivery_info.global_attribute10 is NULL)))
         AND (  (recinfo.global_attribute11 = p_delivery_info.global_attribute11)
              OR (  (recinfo.global_attribute11 is NULL)
                  AND  (p_delivery_info.global_attribute11 is NULL)))
         AND (  (recinfo.global_attribute12 = p_delivery_info.global_attribute12)
              OR (  (recinfo.global_attribute12 is NULL)
                  AND  (p_delivery_info.global_attribute12 is NULL)))
         AND (  (recinfo.global_attribute13 = p_delivery_info.global_attribute13)
              OR (  (recinfo.global_attribute13 is NULL)
                  AND  (p_delivery_info.global_attribute13 is NULL)))
         AND (  (recinfo.global_attribute14 = p_delivery_info.global_attribute14)
              OR (  (recinfo.global_attribute14 is NULL)
                  AND  (p_delivery_info.global_attribute14 is NULL)))
         AND (  (recinfo.global_attribute15 = p_delivery_info.global_attribute15)
              OR (  (recinfo.global_attribute15 is NULL)
                  AND  (p_delivery_info.global_attribute15 is NULL)))
         AND (  (recinfo.global_attribute16 = p_delivery_info.global_attribute16)
              OR (  (recinfo.global_attribute16 is NULL)
                  AND  (p_delivery_info.global_attribute16 is NULL)))
         AND (  (recinfo.global_attribute17 = p_delivery_info.global_attribute17)
              OR (  (recinfo.global_attribute17 is NULL)
                  AND  (p_delivery_info.global_attribute17 is NULL)))
         AND (  (recinfo.global_attribute18 = p_delivery_info.global_attribute18)
              OR (  (recinfo.global_attribute18 is NULL)
                  AND  (p_delivery_info.global_attribute18 is NULL)))
         AND (  (recinfo.global_attribute19 = p_delivery_info.global_attribute19)
              OR (  (recinfo.global_attribute19 is NULL)
                  AND  (p_delivery_info.global_attribute19 is NULL)))
         AND (  (recinfo.global_attribute20 = p_delivery_info.global_attribute20)
              OR (  (recinfo.global_attribute20 is NULL)
                  AND  (p_delivery_info.global_attribute20 is NULL)))
         AND    (recinfo.creation_date = p_delivery_info.creation_date)
         AND    (recinfo.created_by = p_delivery_info.created_by)
	 /*  Bug 1990178 : Commenting out these three  conditions because
	     the last updated date gets updated in the database , but not
	     in the form.
         AND    (recinfo.last_update_date = p_delivery_info.last_update_date)
         AND    (recinfo.last_updated_by = p_delivery_info.last_updated_by)
         AND (  (recinfo.last_update_login = p_delivery_info.last_update_login)
              OR (  (recinfo.last_update_login is NULL)
                  AND  (p_delivery_info.last_update_login is NULL)))
	 */
         AND (  (recinfo.program_application_id = p_delivery_info.program_application_id)
              OR (  (recinfo.program_application_id is NULL)
                  AND  (p_delivery_info.program_application_id is NULL)))
         AND (  (recinfo.program_id = p_delivery_info.program_id)
              OR (  (recinfo.program_id is NULL)
                  AND  (p_delivery_info.program_id is NULL)))
         AND (  (recinfo.program_update_date = p_delivery_info.program_update_date)
              OR (  (recinfo.program_update_date is NULL)
                  AND  (p_delivery_info.program_update_date is NULL)))
         AND (  (recinfo.request_id = p_delivery_info.request_id)
              OR (  (recinfo.request_id is NULL)
                  AND  (p_delivery_info.request_id is NULL)))
         AND (  (recinfo.number_of_lpn = p_delivery_info.number_of_lpn)	--bugfix 1426086: added number_of_lpn
              OR (  (recinfo.number_of_lpn is NULL)
                  AND  (p_delivery_info.number_of_lpn is NULL)))
/* Changes for the shipping data model bug#1918342*/
         AND (  (recinfo.cod_amount= p_delivery_info.cod_amount)
              OR (  (recinfo.cod_amount is NULL)
                  AND  (p_delivery_info.cod_amount is NULL)))
         AND (  (recinfo.cod_currency_code = p_delivery_info.cod_currency_code)
              OR (  (recinfo.cod_currency_code is NULL)
                  AND  (p_delivery_info.cod_currency_code is NULL)))
         AND (  (recinfo.cod_remit_to = p_delivery_info.cod_remit_to)
              OR (  (recinfo.cod_remit_to is NULL)
                  AND  (p_delivery_info.cod_remit_to is NULL)))
         AND (  (recinfo.cod_charge_paid_by = p_delivery_info.cod_charge_paid_by)
              OR (  (recinfo.cod_charge_paid_by is NULL)
                  AND  (p_delivery_info.cod_charge_paid_by is NULL)))
         AND (  (recinfo.problem_contact_reference = p_delivery_info.problem_contact_reference)
              OR (  (recinfo.problem_contact_reference is NULL)
                  AND  (p_delivery_info.problem_contact_reference is NULL)))
         AND (  (recinfo.port_of_loading = p_delivery_info.port_of_loading)
              OR (  (recinfo.port_of_loading is NULL)
                  AND  (p_delivery_info.port_of_loading is NULL)))
         AND (  (recinfo.port_of_discharge = p_delivery_info.port_of_discharge)
              OR (  (recinfo.port_of_discharge is NULL)
                  AND  (p_delivery_info.port_of_discharge is NULL)))
         AND (  (recinfo.ftz_number = p_delivery_info.ftz_number)
              OR (  (recinfo.ftz_number is NULL)
                  AND  (p_delivery_info.ftz_number is NULL)))
         AND (  (recinfo.routed_export_txn = p_delivery_info.routed_export_txn)
              OR (  (recinfo.routed_export_txn is NULL)
                  AND  (p_delivery_info.routed_export_txn is NULL)))
         AND (  (recinfo.entry_number = p_delivery_info.entry_number)
              OR (  (recinfo.entry_number is NULL)
                  AND  (p_delivery_info.entry_number is NULL)))
         AND (  (recinfo.routing_instructions = p_delivery_info.routing_instructions)
              OR (  (recinfo.routing_instructions is NULL)
                  AND  (p_delivery_info.routing_instructions is NULL)))
         AND (  (recinfo.in_bond_code = p_delivery_info.in_bond_code)
              OR (  (recinfo.in_bond_code is NULL)
                  AND  (p_delivery_info.in_bond_code is NULL)))
         AND (  (recinfo.shipping_marks = p_delivery_info.shipping_marks)
              OR (  (recinfo.shipping_marks is NULL)
                  AND  (p_delivery_info.shipping_marks is NULL)))
/* H Integration: datamodel changes wrudge */
	 AND (  (recinfo.service_level = p_delivery_info.service_level)
              OR (  (recinfo.service_level is NULL)
                  AND  (p_delivery_info.service_level is NULL)))
	 AND (  (recinfo.mode_of_transport = p_delivery_info.mode_of_transport)
              OR (  (recinfo.mode_of_transport is NULL)
                  AND  (p_delivery_info.mode_of_transport is NULL)))
	 AND (  (recinfo.assigned_to_fte_trips = p_delivery_info.assigned_to_fte_trips)
              OR (  (recinfo.assigned_to_fte_trips is NULL)
                  AND  (p_delivery_info.assigned_to_fte_trips is NULL)))
	 AND (  (recinfo.auto_sc_exclude_flag = p_delivery_info.auto_sc_exclude_flag)
              OR (  (recinfo.auto_sc_exclude_flag is NULL)
                  AND  (p_delivery_info.auto_sc_exclude_flag is NULL)))
	 AND (  (recinfo.auto_ap_exclude_flag = p_delivery_info.auto_ap_exclude_flag)
              OR (  (recinfo.auto_ap_exclude_flag is NULL)
                  AND  (p_delivery_info.auto_ap_exclude_flag is NULL)))
         AND (  (nvl(recinfo.shipment_direction, 'O') = nvl(p_delivery_info.shipment_direction,'O'))
              OR (  (recinfo.shipment_direction is NULL)
                  AND  (p_delivery_info.shipment_direction is NULL)))
         AND (  (recinfo.vendor_id = p_delivery_info.vendor_id)
              OR (  (recinfo.vendor_id is NULL)
                  AND  (p_delivery_info.vendor_id is NULL)))
         AND (  (recinfo.party_id = p_delivery_info.party_id)
              OR (  (recinfo.party_id is NULL)
                  AND  (p_delivery_info.party_id is NULL)))
         AND (  (recinfo.routing_response_id = p_delivery_info.routing_response_id)
              OR (  (recinfo.routing_response_id is NULL)
                  AND  (p_delivery_info.routing_response_id is NULL)))
         AND (  (recinfo.rcv_shipment_header_id = p_delivery_info.rcv_shipment_header_id)
              OR (  (recinfo.rcv_shipment_header_id is NULL)
                  AND  (p_delivery_info.rcv_shipment_header_id is NULL)))
         AND (  (recinfo.asn_shipment_header_id = p_delivery_info.asn_shipment_header_id)
              OR (  (recinfo.asn_shipment_header_id is NULL)
                  AND  (p_delivery_info.asn_shipment_header_id is NULL)))
         AND (  (recinfo.shipping_control = p_delivery_info.shipping_control)
              OR (  (recinfo.shipping_control is NULL)
                  AND  (p_delivery_info.shipping_control is NULL)))
/* J TP Release : ttrichy */
         AND (  (recinfo.TP_DELIVERY_NUMBER = p_delivery_info.TP_DELIVERY_NUMBER)
              OR (  (recinfo.TP_DELIVERY_NUMBER is NULL)
                  AND  (p_delivery_info.TP_DELIVERY_NUMBER is NULL)))
         AND (  (recinfo.EARLIEST_PICKUP_DATE = p_delivery_info.EARLIEST_PICKUP_DATE)
              OR (  (recinfo.EARLIEST_PICKUP_DATE is NULL)
                  AND  (p_delivery_info.EARLIEST_PICKUP_DATE is NULL)))
         AND (  (recinfo.LATEST_PICKUP_DATE = p_delivery_info.LATEST_PICKUP_DATE)
              OR (  (recinfo.LATEST_PICKUP_DATE is NULL)
                  AND  (p_delivery_info.LATEST_PICKUP_DATE is NULL)))
         AND (  (recinfo.EARLIEST_DROPOFF_DATE = p_delivery_info.EARLIEST_DROPOFF_DATE)
              OR (  (recinfo.EARLIEST_DROPOFF_DATE is NULL)
                  AND  (p_delivery_info.EARLIEST_DROPOFF_DATE is NULL)))
         AND (  (recinfo.LATEST_DROPOFF_DATE = p_delivery_info.LATEST_DROPOFF_DATE)
              OR (  (recinfo.LATEST_DROPOFF_DATE is NULL)
                  AND  (p_delivery_info.LATEST_DROPOFF_DATE is NULL)))
         AND (  (nvl(recinfo.IGNORE_FOR_PLANNING, 'N') = nvl(p_delivery_info.IGNORE_FOR_PLANNING, 'N')))
         AND (  (recinfo.TP_PLAN_NAME = p_delivery_info.TP_PLAN_NAME)
              OR (  (recinfo.TP_PLAN_NAME is NULL)
                  AND  (p_delivery_info.TP_PLAN_NAME is NULL)))
-- J: W/V Changes
         AND (  (recinfo.wv_frozen_flag = p_delivery_info.wv_frozen_flag)
              OR (  (recinfo.wv_frozen_flag is NULL)
                  AND  (p_delivery_info.wv_frozen_flag is NULL)))
         AND (  (recinfo.delivered_date = p_delivery_info.delivered_date)
              OR (  (recinfo.delivered_date is NULL)
                  AND  (p_delivery_info.delivered_date is NULL)))
	-- bug 3667348
    	AND (  (recinfo.REASON_OF_TRANSPORT = p_delivery_info.REASON_OF_TRANSPORT)
                OR (  (recinfo.REASON_OF_TRANSPORT is NULL)
                     AND  (p_delivery_info.REASON_OF_TRANSPORT is NULL)))
	AND (  (recinfo.DESCRIPTION = p_delivery_info.DESCRIPTION)
                OR (  (recinfo.DESCRIPTION is NULL)
                     AND  (p_delivery_info.DESCRIPTION is NULL)))
	-- bug 3667348
        --OTM R12
        AND (  (recinfo.TMS_INTERFACE_FLAG = p_delivery_info.TMS_INTERFACE_FLAG)
                OR (  (recinfo.TMS_INTERFACE_FLAG IS NULL)
                     AND  (p_delivery_info.TMS_INTERFACE_FLAG IS NULL)))
        AND (  (recinfo.TMS_VERSION_NUMBER = p_delivery_info.TMS_VERSION_NUMBER)
                OR (  (recinfo.TMS_VERSION_NUMBER IS NULL)
                     AND  (p_delivery_info.TMS_VERSION_NUMBER IS NULL)))
     -- LSP PROJECT
     AND (  (recinfo.client_id = p_delivery_info.client_id)
                OR (  (recinfo.client_id IS NULL)
                     AND  (p_delivery_info.client_id IS NULL)))
    -- LSP PROJECT
        --
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
    WHEN app_exception.application_exception or app_exception.record_lock_exception THEN
      if (lock_row%ISOPEN) then
	close lock_row;
      end if;
      --
      IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'APP_EXCEPTION.APPLICATION_EXCEPTION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:APP_EXCEPTION.APPLICATION_EXCEPTION');
      END IF;
      --
      RAISE;
      --
    WHEN others THEN
      if (lock_row%ISOPEN) then
	close lock_row;
      end if;
      --
      IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      raise;
      --
  END Lock_Delivery;

--
--  Procedure:		Populate_Record
--  Parameters:		p_delivery_id - Id for delivery
--			x_delivery_info - All Attributes of a Delivery Record
--			x_return_status - Status of procedure call
--  Description:	This procedure will populate a delivery record.
--

  PROCEDURE Populate_Record
		(p_delivery_id		IN	VARCHAR2,
		 x_delivery_info	OUT NOCOPY 	Delivery_Rec_Type,
		 x_return_status	OUT NOCOPY 	VARCHAR2
		 ) IS

  CURSOR delivery_record IS
  SELECT
	    DELIVERY_ID,
    	    NAME,
    	    PLANNED_FLAG,
    	    STATUS_CODE,
    	    DELIVERY_TYPE,
    	    LOADING_SEQUENCE,
    	    LOADING_ORDER_FLAG,
	    INITIAL_PICKUP_DATE,
	    INITIAL_PICKUP_LOCATION_ID,
	    ORGANIZATION_ID,
	    ULTIMATE_DROPOFF_LOCATION_ID,
	    ULTIMATE_DROPOFF_DATE,
	    CUSTOMER_ID,
	    INTMED_SHIP_TO_LOCATION_ID,
	    POOLED_SHIP_TO_LOCATION_ID,
	    CARRIER_ID,
	    SHIP_METHOD_CODE,
	    FREIGHT_TERMS_CODE,
	    FOB_CODE,
	    FOB_LOCATION_ID,
	    WAYBILL,
	    DOCK_CODE,
	    ACCEPTANCE_FLAG,
	    ACCEPTED_BY,
	    ACCEPTED_DATE,
	    ACKNOWLEDGED_BY,
	    CONFIRMED_BY,
	    CONFIRM_DATE,
	    ASN_DATE_SENT,
	    ASN_STATUS_CODE,
	    ASN_SEQ_NUMBER,
	    GROSS_WEIGHT,
	    NET_WEIGHT,
	    WEIGHT_UOM_CODE,
	    VOLUME,
	    VOLUME_UOM_CODE,
	    ADDITIONAL_SHIPMENT_INFO,
	    CURRENCY_CODE,
	    ATTRIBUTE_CATEGORY,
	    ATTRIBUTE1,
	    ATTRIBUTE2,
	    ATTRIBUTE3,
	    ATTRIBUTE4,
	    ATTRIBUTE5,
	    ATTRIBUTE6,
	    ATTRIBUTE7,
	    ATTRIBUTE8,
	    ATTRIBUTE9,
	    ATTRIBUTE10,
	    ATTRIBUTE11,
	    ATTRIBUTE12,
	    ATTRIBUTE13,
	    ATTRIBUTE14,
	    ATTRIBUTE15,
	    TP_ATTRIBUTE_CATEGORY,
	    TP_ATTRIBUTE1,
	    TP_ATTRIBUTE2,
	    TP_ATTRIBUTE3,
	    TP_ATTRIBUTE4,
	    TP_ATTRIBUTE5,
	    TP_ATTRIBUTE6,
	    TP_ATTRIBUTE7,
	    TP_ATTRIBUTE8,
	    TP_ATTRIBUTE9,
	    TP_ATTRIBUTE10,
	    TP_ATTRIBUTE11,
	    TP_ATTRIBUTE12,
	    TP_ATTRIBUTE13,
	    TP_ATTRIBUTE14,
	    TP_ATTRIBUTE15,
	    GLOBAL_ATTRIBUTE_CATEGORY,
	    GLOBAL_ATTRIBUTE1,
	    GLOBAL_ATTRIBUTE2,
	    GLOBAL_ATTRIBUTE3,
	    GLOBAL_ATTRIBUTE4,
	    GLOBAL_ATTRIBUTE5,
	    GLOBAL_ATTRIBUTE6,
	    GLOBAL_ATTRIBUTE7,
	    GLOBAL_ATTRIBUTE8,
	    GLOBAL_ATTRIBUTE9,
	    GLOBAL_ATTRIBUTE10,
	    GLOBAL_ATTRIBUTE11,
	    GLOBAL_ATTRIBUTE12,
	    GLOBAL_ATTRIBUTE13,
	    GLOBAL_ATTRIBUTE14,
	    GLOBAL_ATTRIBUTE15,
	    GLOBAL_ATTRIBUTE16,
	    GLOBAL_ATTRIBUTE17,
	    GLOBAL_ATTRIBUTE18,
	    GLOBAL_ATTRIBUTE19,
	    GLOBAL_ATTRIBUTE20,
	    CREATION_DATE,
	    CREATED_BY,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    LAST_UPDATE_LOGIN,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    REQUEST_ID,
            BATCH_ID,
            HASH_VALUE,
            SOURCE_HEADER_ID,
	    NUMBER_OF_LPN,
/* Changes for the Shipping Data Model Bug#1918342*/
	    COD_AMOUNT,
	    COD_CURRENCY_CODE,
	    COD_REMIT_TO,
	    COD_CHARGE_PAID_BY,
	    PROBLEM_CONTACT_REFERENCE,
	    PORT_OF_LOADING,
	    PORT_OF_DISCHARGE,
            FTZ_NUMBER,
            ROUTED_EXPORT_TXN,
            ENTRY_NUMBER,
            ROUTING_INSTRUCTIONS,
            IN_BOND_CODE,
            SHIPPING_MARKS,
/* H Integration: datamodel changes wrudge */
	    SERVICE_LEVEL,
            MODE_OF_TRANSPORT,
            ASSIGNED_TO_FTE_TRIPS,
            AUTO_SC_EXCLUDE_FLAG,
            AUTO_AP_EXCLUDE_FLAG,
            AP_BATCH_ID,
	    ROWID,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
/*  J  Inbound Logistics: New columns jckwok */
            SHIPMENT_DIRECTION,
            VENDOR_ID,
            PARTY_ID,
            ROUTING_RESPONSE_ID,
            RCV_SHIPMENT_HEADER_ID,
            ASN_SHIPMENT_HEADER_ID,
            SHIPPING_CONTROL
/* J TP Release : ttrichy */
            ,TP_DELIVERY_NUMBER
            ,EARLIEST_PICKUP_DATE
            ,LATEST_PICKUP_DATE
            ,EARLIEST_DROPOFF_DATE
            ,LATEST_DROPOFF_DATE
            ,nvl(IGNORE_FOR_PLANNING, 'N') ignore_for_planning
            ,TP_PLAN_NAME
-- J: W/V Changes
            ,WV_FROZEN_FLAG
            ,hash_string
            ,delivered_date,
            null , -- packing_slip
-- bug 3667348
            REASON_OF_TRANSPORT,
            DESCRIPTION,
-- bug 3667348
            'N',--Non Database field added for "Proration of weight from Delivery to delivery lines" Project(Bug#4254552).
--OTM R12
            TMS_INTERFACE_FLAG,
            TMS_VERSION_NUMBER,
--
-- R12.1.1 STANDALONE PROJECT
            PENDING_ADVICE_FLAG,
            CLIENT_ID, -- LSP PROJECT  --Modified R12.1.1 LSP PROJECT(rminocha)
            NULL  -- client_code , LSP PROJECT
  FROM   wsh_new_deliveries
  WHERE  delivery_id = p_delivery_id;

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
	    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
	END IF;
	--
	IF (p_delivery_id IS NULL) THEN
	   raise others;
     END IF;

     OPEN  delivery_record;
     FETCH delivery_record INTO x_delivery_info;

     IF (delivery_record%NOTFOUND) THEN
  	  FND_MESSAGE.SET_NAME('WSH','WSH_DEL_NOT_FOUND');
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	  WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'WSH_DEL_NOT_FOUND');
          END IF;
     ELSE
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     END IF;

     CLOSE delivery_record;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     EXCEPTION
        WHEN others THEN
          IF (delivery_record%ISOPEN) THEN
            CLOSE delivery_record;
          END IF;

	      wsh_util_core.default_handler('WSH_NEW_DELIVERIES_PVT.POPULATE_RECORD',l_module_name);
	      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
              --
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                  WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
              END IF;
              --
  END Populate_Record;


--
--  Function:		Get_Name
--  Parameters:		p_delivery_id - Id for delivery
--  Description:	This procedure will return Delivery Name for a Delivery Id
--

  FUNCTION Get_Name
		(p_delivery_id		IN	NUMBER
		 ) RETURN VARCHAR2 IS

  CURSOR get_name IS
  SELECT name
  FROM   wsh_new_deliveries
  WHERE  delivery_id = p_delivery_id;

  x_name VARCHAR2(30);

  others EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_NAME';
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
         WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
     END IF;
     --
     IF (p_delivery_id IS NULL) THEN
        raise others;
     END IF;

     OPEN  get_name;
     FETCH get_name INTO x_name;
     CLOSE get_name;

     IF (x_name IS NULL) THEN
         FND_MESSAGE.SET_NAME('WSH','WSH_DEL_NOT_FOUND');
         wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
	    --
	    IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'WSH_DEL_NOT_FOUND');
	        WSH_DEBUG_SV.pop(l_module_name);
	    END IF;
	    --
	    RETURN null;
     END IF;

	--
	IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'returns ',x_name);
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	RETURN x_name;

     EXCEPTION

        WHEN others THEN
	      wsh_util_core.default_handler('WSH_NEW_DELIVERIES_PVT.GET_NAME',l_module_name);
              --
              IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
              END IF;
		 --
		 RETURN null;
  END Get_Name;


procedure Lock_Delivery(
        p_rec_attr_tab          IN              Delivery_Attr_Tbl_Type,
        p_caller                IN              VARCHAR2,
        p_valid_index_tab       IN              wsh_util_core.id_tab_type,
        x_valid_ids_tab         OUT             NOCOPY wsh_util_core.id_tab_type,
        x_return_status         OUT             NOCOPY VARCHAR2,
        p_action                IN              VARCHAR2 -- Bug fix 2657182
)

IS
--
--
l_index NUMBER := 0;
l_num_errors NUMBER := 0;
--
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_DELIVERY_WRAPPER';
--
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
      WSH_DEBUG_SV.log(l_module_name,'p_caller',p_caller);
      WSH_DEBUG_SV.log(l_module_name, 'p_action', p_action);
      WSH_DEBUG_SV.log(l_module_name,'Total Number of Delivery Records being locked',p_valid_index_tab.COUNT);
  END IF;
  --
  --
  l_index := p_valid_index_tab.FIRST;
  --
  while l_index is not null loop
    begin
      --
      savepoint lock_delivery_loop;
      --
      if p_caller = 'WSH_FSTRX' then
           lock_delivery(p_rowid => p_rec_attr_tab(l_index).rowid,
  	             p_delivery_info => p_rec_attr_tab(l_index)
                    );
      else
           wsh_new_deliveries_pvt.lock_dlvy_no_compare(p_delivery_id => p_rec_attr_tab(l_index).delivery_id);
      end if;

      -- Bug fix 2657182
      -- Need to lock the related entities - lines, containers and delivery legs
      -- For actions ship confirm and autopacking
      if p_action IN ('CONFIRM', 'AUTO-PACK', 'AUTO-PACK-MASTER') then
          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.LOCK_DETAIL',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          wsh_delivery_details_pkg.lock_detail_no_compare(
                      p_delivery_id =>  p_rec_attr_tab(l_index).delivery_id);

          if p_action = 'CONFIRM' then
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_PVT.LOCK_DLVY_LEG',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             wsh_delivery_legs_pvt.lock_dlvy_leg_no_compare(
                      p_delivery_id  => p_rec_attr_tab(l_index).delivery_id);
          end if;

      end if;
      -- End of Bug fix 2657182

      IF nvl(p_caller,FND_API.G_MISS_CHAR) NOT IN ('WSH_FSTRX','WSH_TRCON') THEN
        x_valid_ids_tab(x_valid_ids_tab.COUNT + 1) := p_rec_attr_tab(l_index).delivery_id;
      ELSE
        x_valid_ids_tab(x_valid_ids_tab.COUNT + 1) := l_index;
      END IF;
      --
    exception
      --
      WHEN app_exception.application_exception or app_exception.record_lock_exception THEN
        rollback to lock_delivery_loop;
        IF nvl(p_caller,FND_API.G_MISS_CHAR) = 'WSH_PUB'
           OR nvl(p_caller, '!') like 'FTE%'
           OR nvl(p_caller, '!') = 'WSH_TRCON' THEN
          FND_MESSAGE.SET_NAME('WSH', 'WSH_DLVY_LOCK_FAILED');
	  FND_MESSAGE.SET_TOKEN('ENTITY_NAME',p_rec_attr_tab(l_index).name);
          wsh_util_core.add_message(wsh_util_core.g_ret_sts_error,l_module_name);
        END IF;
        l_num_errors := l_num_errors + 1;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Unable to obtain lock on the Delivery Id',p_rec_attr_tab(l_index).delivery_id);
      END IF;
      --
      WHEN others THEN
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end;
    --
    l_index := p_valid_index_tab.NEXT(l_index);
    --
  end loop;
  --
  --
  IF p_valid_index_tab.COUNT = 0 THEN
    x_return_status := wsh_util_core.g_ret_sts_success;
  ELSIF l_num_errors = p_valid_index_tab.COUNT THEN
    FND_MESSAGE.SET_NAME('WSH', 'WSH_UI_NOT_PERFORMED');
    x_return_status := wsh_util_core.g_ret_sts_error;
    wsh_util_core.add_message(x_return_status,l_module_name);
    IF l_debug_on THEN
      wsh_debug_sv.logmsg(l_module_name, 'WSH_UI_NOT_PERFORMED');
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_num_errors > 0 THEN
    FND_MESSAGE.SET_NAME('WSH', 'WSH_UI_NOT_PROCESSED');
    x_return_status := wsh_util_core.g_ret_sts_warning;
    wsh_util_core.add_message(x_return_status,l_module_name);
    IF l_debug_on THEN
      wsh_debug_sv.logmsg(l_module_name, 'WSH_UI_NOT_PROCESSED');
    END IF;
    raise wsh_util_core.g_exc_warning;
  ELSE
    x_return_status := wsh_util_core.g_ret_sts_success;
  END IF;
  --
  --
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
  --
  --
  WHEN FND_API.G_EXC_ERROR THEN
  --
    x_return_status := wsh_util_core.g_ret_sts_error;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := wsh_util_core.g_ret_sts_unexp_error;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
    END IF;
  --
  --
  WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
    x_return_status := wsh_util_core.g_ret_sts_warning;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
    END IF;
  --
  --
  WHEN OTHERS THEN
  --
    x_return_status := wsh_util_core.g_ret_sts_unexp_error;
    --
    wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_PKG.LOCK_DELIVERY_WRAPPER',l_module_name);
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
  --
  --
END Lock_Delivery;

/*    ---------------------------------------------------------------------
     Procedure:	Lock_Dlvy_No_Compare

     Parameters:	Delivery Id.

     Description:  This procedure is used for obtaining locks of deliveries
                    using only the delivery id. This is called by the
                   wrapper lock API ,when the p_caller is NOT WSHFSTRX.
                    This procedure does not compare the attributes. It just
                    does a SELECT using FOR UPDATE NOWAIT
     Created:   Harmonization Project. Patchset I
     ----------------------------------------------------------------------- */


PROCEDURE Lock_Dlvy_No_Compare(
                p_delivery_id          IN    NUMBER)
IS

CURSOR c_lock_dlvy(p_dlvy_id NUMBER) IS
     SELECT wnd.delivery_id
     FROM wsh_new_deliveries wnd
     WHERE wnd.delivery_id = p_dlvy_id
     FOR UPDATE NOWAIT;

l_dummy_dlvy_id  NUMBER;

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_DLVY_NO_COMPARE';

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
      WSH_DEBUG_SV.log(l_module_name, 'p_delivery_id', p_delivery_id);
  END IF;
  --

  IF p_delivery_id IS NOT NULL THEN
     OPEN c_lock_dlvy(p_delivery_id);
     FETCH c_lock_dlvy INTO l_dummy_dlvy_id;
     CLOSE c_lock_dlvy;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
	WHEN app_exception.application_exception or app_exception.record_lock_exception THEN
              IF l_debug_on THEN
                 wsh_debug_sv.log(l_module_name, 'Could not lock delivery', p_delivery_id);
              END IF;
	      IF l_debug_on THEN
	          WSH_DEBUG_SV.logmsg(l_module_name,'APP_EXCEPTION.APPLICATION_EXCEPTION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:APP_EXCEPTION.APPLICATION_EXCEPTION');
	      END IF;
	      --
	      RAISE;

END Lock_Dlvy_No_Compare;


-- J-IB-NPARIKH-{
--
--========================================================================
-- PROCEDURE : clone
--
-- PARAMETERS: p_delivery_rec    Delivery record for new delivery (Table handler)
--             p_delivery_id     Source Delivery ID
--             p_copy_legs       Copy delivery legs as well (Y/N)
--             x_delivery_id     ID for new delivery
--             x_rowid           RowID for new delivery
--             x_leg_id_tab      Table of delivery leg IDs for new delivery.
--             x_return_status   Return status of the API
--
--
-- COMMENT   : This procedure clones an input delivery.
--             You can override specific attributes by specifying its value in p_delivery_rec
--             for new delivery.
--             IF p_delivery_rec."attribute" is null, it is inherited from source delivery.
--             IF p_delivery_rec."attribute" is G_MISS*, it is set to NULL.
--
--             It also copies delivery legs, depending on value of parameter p_copy_legs.
--             If p_copy_legs = 'Y', set itinerary_complete on cloned delivery same as old del.
--             If p_copy_legs = 'N', set itinerary_complete on cloned delivery to 'N'
--
--========================================================================
--
PROCEDURE clone
    (
        p_delivery_rec   IN Delivery_Rec_Type,
        p_delivery_id    IN NUMBER,
        p_copy_legs      IN VARCHAR2 DEFAULT 'N',
        x_delivery_id   OUT NOCOPY NUMBER,
        x_rowid         OUT NOCOPY VARCHAR2,
        x_leg_id_tab    OUT NOCOPY WSH_UTIL_CORE.id_tab_type,
        x_return_status OUT NOCOPY  VARCHAR2
    )
IS
--{
				--
				-- Generate delivery ID
				--
    CURSOR get_next_delivery
    IS
    SELECT wsh_new_deliveries_s.nextval
    FROM   dual;
    --
    CURSOR dlvy_csr(p_delivery_id NUMBER)
    IS
    SELECT rowid
    FROM wsh_new_deliveries
    WHERE delivery_id = p_delivery_id;
    --
    CURSOR leg_csr(p_delivery_id NUMBER)
    IS
    SELECT delivery_leg_id
    FROM wsh_delivery_legs
    WHERE delivery_id = p_delivery_id;
    --
    --
    CURSOR count_delivery_rows (p_delivery_name VARCHAR2) IS
    SELECT delivery_id
    FROM wsh_new_deliveries
    WHERE name = p_delivery_name;
    --
    l_delivery_id   NUMBER;
    l_delivery_name     VARCHAR2(30);
    l_temp_id           NUMBER;
    l_row_check         NUMBER;
    --
    --
    l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'clone';
    --
--}
BEGIN
--{
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
        WSH_DEBUG_SV.log(l_module_name,'p_delivery_id',p_delivery_id);
        WSH_DEBUG_SV.log(l_module_name,'p_copy_legs',p_copy_legs);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    -- Generate delivery ID
    --
    OPEN get_next_delivery;
    FETCH get_next_delivery INTO l_delivery_id;
    CLOSE get_next_delivery;
    --
    --
    --
    --{
     IF p_delivery_rec.name IS NULL THEN
								--
								-- If delivery name was not passed in, generate it.
								--
        l_delivery_name := wsh_custom_pub.delivery_name(l_delivery_id,p_delivery_rec);

        -- shipping default make sure the delivery name is not duplicate
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_delivery_name',l_delivery_name);
           WSH_DEBUG_SV.log(l_module_name,'l_delivery_id',l_delivery_id);
        END IF;
        IF ( l_delivery_name = to_char(l_delivery_id) ) THEN
           l_temp_id := l_delivery_id;

           LOOP

              l_delivery_name := to_char(l_temp_id);

              OPEN count_delivery_rows( l_delivery_name);
              FETCH count_delivery_rows INTO l_row_check;
              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'l_row_check',l_row_check);
              END IF;
              IF (count_delivery_rows%NOTFOUND) THEN
                 CLOSE count_delivery_rows;
                 EXIT;
              END IF;

              CLOSE count_delivery_rows;

              OPEN get_next_delivery;
              FETCH get_next_delivery INTO l_temp_id;
              CLOSE get_next_delivery;
              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'l_temp_id',l_temp_id);
              END IF;
           END LOOP;

           l_delivery_id := l_temp_id;

        END IF;

     ELSE
        l_delivery_name := p_delivery_rec.name;
     END IF;
    --}
    --
    --
    INSERT INTO WSH_NEW_DELIVERIES
      (
        DELIVERY_ID,
        NAME,
        PLANNED_FLAG,
        STATUS_CODE,
        DELIVERY_TYPE,
        LOADING_SEQUENCE,
        LOADING_ORDER_FLAG,
        INITIAL_PICKUP_DATE,
        INITIAL_PICKUP_LOCATION_ID,
        ORGANIZATION_ID,
        ULTIMATE_DROPOFF_LOCATION_ID,
        ULTIMATE_DROPOFF_DATE,
        CUSTOMER_ID,
        INTMED_SHIP_TO_LOCATION_ID,
        POOLED_SHIP_TO_LOCATION_ID,
        CARRIER_ID,
        SHIP_METHOD_CODE,
        FREIGHT_TERMS_CODE,
        FOB_CODE,
        FOB_LOCATION_ID,
        WAYBILL,
        DOCK_CODE,
        ACCEPTANCE_FLAG,
        ACCEPTED_BY,
        ACCEPTED_DATE,
        ACKNOWLEDGED_BY,
        CONFIRMED_BY,
        CONFIRM_DATE,
        ASN_DATE_SENT,
        ASN_STATUS_CODE,
        ASN_SEQ_NUMBER,
        GROSS_WEIGHT,
        NET_WEIGHT,
        WEIGHT_UOM_CODE,
        VOLUME,
        VOLUME_UOM_CODE,
        ADDITIONAL_SHIPMENT_INFO,
        CURRENCY_CODE,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        TP_ATTRIBUTE_CATEGORY,
        TP_ATTRIBUTE1,
        TP_ATTRIBUTE2,
        TP_ATTRIBUTE3,
        TP_ATTRIBUTE4,
        TP_ATTRIBUTE5,
        TP_ATTRIBUTE6,
        TP_ATTRIBUTE7,
        TP_ATTRIBUTE8,
        TP_ATTRIBUTE9,
        TP_ATTRIBUTE10,
        TP_ATTRIBUTE11,
        TP_ATTRIBUTE12,
        TP_ATTRIBUTE13,
        TP_ATTRIBUTE14,
        TP_ATTRIBUTE15,
        GLOBAL_ATTRIBUTE_CATEGORY,
        GLOBAL_ATTRIBUTE1,
        GLOBAL_ATTRIBUTE2,
        GLOBAL_ATTRIBUTE3,
        GLOBAL_ATTRIBUTE4,
        GLOBAL_ATTRIBUTE5,
        GLOBAL_ATTRIBUTE6,
        GLOBAL_ATTRIBUTE7,
        GLOBAL_ATTRIBUTE8,
        GLOBAL_ATTRIBUTE9,
        GLOBAL_ATTRIBUTE10,
        GLOBAL_ATTRIBUTE11,
        GLOBAL_ATTRIBUTE12,
        GLOBAL_ATTRIBUTE13,
        GLOBAL_ATTRIBUTE14,
        GLOBAL_ATTRIBUTE15,
        GLOBAL_ATTRIBUTE16,
        GLOBAL_ATTRIBUTE17,
        GLOBAL_ATTRIBUTE18,
        GLOBAL_ATTRIBUTE19,
        GLOBAL_ATTRIBUTE20,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        REQUEST_ID,
        BATCH_ID,
        HASH_VALUE,
        SOURCE_HEADER_ID,
        NUMBER_OF_LPN,
        COD_AMOUNT,
        COD_CURRENCY_CODE,
        COD_REMIT_TO,
        COD_CHARGE_PAID_BY,
        PROBLEM_CONTACT_REFERENCE,
        PORT_OF_LOADING,
        PORT_OF_DISCHARGE,
        FTZ_NUMBER,
        ROUTED_EXPORT_TXN,
        ENTRY_NUMBER,
        ROUTING_INSTRUCTIONS,
        IN_BOND_CODE,
        SHIPPING_MARKS,
        SERVICE_LEVEL,
        MODE_OF_TRANSPORT,
        ASSIGNED_TO_FTE_TRIPS,
        AUTO_SC_EXCLUDE_FLAG,
        AUTO_AP_EXCLUDE_FLAG,
        AP_BATCH_ID,
        SHIPMENT_DIRECTION,
        VENDOR_ID,
        PARTY_ID,
        ROUTING_RESPONSE_ID,
        RCV_SHIPMENT_HEADER_ID,
        ASN_SHIPMENT_HEADER_ID,
        SHIPPING_CONTROL,
        TP_DELIVERY_NUMBER,
        EARLIEST_PICKUP_DATE,
        LATEST_PICKUP_DATE,
        EARLIEST_DROPOFF_DATE,
        LATEST_DROPOFF_DATE,
        IGNORE_FOR_PLANNING,
        TP_PLAN_NAME,
        HASH_STRING,
        DELIVERED_DATE,
	-- bug 3667348
	REASON_OF_TRANSPORT,
	DESCRIPTION,
	-- bug 3667348
        ITINERARY_COMPLETE,
        --OTM R12
        TMS_INTERFACE_FLAG,
        TMS_VERSION_NUMBER
        --
      )
    SELECT
        l_delivery_id,
        --DECODE(p_delivery_rec.NAME,NULL,WND.NAME,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.NAME),
        DECODE(l_delivery_NAME,NULL,WND.NAME,FND_API.G_MISS_CHAR,NULL,l_delivery_NAME),
        DECODE(p_delivery_rec.PLANNED_FLAG,NULL,WND.PLANNED_FLAG,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.PLANNED_FLAG),
        DECODE(p_delivery_rec.STATUS_CODE,NULL,WND.STATUS_CODE,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.STATUS_CODE),
        DECODE(p_delivery_rec.DELIVERY_TYPE,NULL,WND.DELIVERY_TYPE,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.DELIVERY_TYPE),
        DECODE(p_delivery_rec.LOADING_SEQUENCE,NULL,WND.LOADING_SEQUENCE,FND_API.G_MISS_NUM,NULL,p_delivery_rec.LOADING_SEQUENCE),
        DECODE(p_delivery_rec.LOADING_ORDER_FLAG,NULL,WND.LOADING_ORDER_FLAG,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.LOADING_ORDER_FLAG),
        DECODE(p_delivery_rec.INITIAL_PICKUP_DATE,NULL,WND.INITIAL_PICKUP_DATE,FND_API.G_MISS_DATE,NULL,p_delivery_rec.INITIAL_PICKUP_DATE),
        DECODE(p_delivery_rec.INITIAL_PICKUP_LOCATION_ID,NULL,WND.INITIAL_PICKUP_LOCATION_ID,FND_API.G_MISS_NUM,NULL,p_delivery_rec.INITIAL_PICKUP_LOCATION_ID),
        DECODE(p_delivery_rec.ORGANIZATION_ID,NULL,WND.ORGANIZATION_ID,FND_API.G_MISS_NUM,NULL,p_delivery_rec.ORGANIZATION_ID),
        DECODE(p_delivery_rec.ULTIMATE_DROPOFF_LOCATION_ID,NULL,WND.ULTIMATE_DROPOFF_LOCATION_ID,FND_API.G_MISS_NUM,NULL,p_delivery_rec.ULTIMATE_DROPOFF_LOCATION_ID),
        DECODE(p_delivery_rec.ULTIMATE_DROPOFF_DATE,NULL,WND.ULTIMATE_DROPOFF_DATE,FND_API.G_MISS_DATE,NULL,p_delivery_rec.ULTIMATE_DROPOFF_DATE),
        DECODE(p_delivery_rec.CUSTOMER_ID,NULL,WND.CUSTOMER_ID,FND_API.G_MISS_NUM,NULL,p_delivery_rec.CUSTOMER_ID),
        DECODE(p_delivery_rec.INTMED_SHIP_TO_LOCATION_ID,NULL,WND.INTMED_SHIP_TO_LOCATION_ID,FND_API.G_MISS_NUM,NULL,p_delivery_rec.INTMED_SHIP_TO_LOCATION_ID),
        DECODE(p_delivery_rec.POOLED_SHIP_TO_LOCATION_ID,NULL,WND.POOLED_SHIP_TO_LOCATION_ID,FND_API.G_MISS_NUM,NULL,p_delivery_rec.POOLED_SHIP_TO_LOCATION_ID),
        DECODE(p_delivery_rec.CARRIER_ID,NULL,WND.CARRIER_ID,FND_API.G_MISS_NUM,NULL,p_delivery_rec.CARRIER_ID),
        DECODE(p_delivery_rec.SHIP_METHOD_CODE,NULL,WND.SHIP_METHOD_CODE,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.SHIP_METHOD_CODE),
        DECODE(p_delivery_rec.FREIGHT_TERMS_CODE,NULL,WND.FREIGHT_TERMS_CODE,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.FREIGHT_TERMS_CODE),
        DECODE(p_delivery_rec.FOB_CODE,NULL,WND.FOB_CODE,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.FOB_CODE),
        DECODE(p_delivery_rec.FOB_LOCATION_ID,NULL,WND.FOB_LOCATION_ID,FND_API.G_MISS_NUM,NULL,p_delivery_rec.FOB_LOCATION_ID),
        DECODE(p_delivery_rec.WAYBILL,NULL,WND.WAYBILL,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.WAYBILL),
        DECODE(p_delivery_rec.DOCK_CODE,NULL,WND.DOCK_CODE,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.DOCK_CODE),
        DECODE(p_delivery_rec.ACCEPTANCE_FLAG,NULL,WND.ACCEPTANCE_FLAG,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ACCEPTANCE_FLAG),
        DECODE(p_delivery_rec.ACCEPTED_BY,NULL,WND.ACCEPTED_BY,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ACCEPTED_BY),
        DECODE(p_delivery_rec.ACCEPTED_DATE,NULL,WND.ACCEPTED_DATE,FND_API.G_MISS_DATE,NULL,p_delivery_rec.ACCEPTED_DATE),
        DECODE(p_delivery_rec.ACKNOWLEDGED_BY,NULL,WND.ACKNOWLEDGED_BY,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ACKNOWLEDGED_BY),
        DECODE(p_delivery_rec.CONFIRMED_BY,NULL,WND.CONFIRMED_BY,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.CONFIRMED_BY),
        DECODE(p_delivery_rec.CONFIRM_DATE,NULL,WND.CONFIRM_DATE,FND_API.G_MISS_DATE,NULL,p_delivery_rec.CONFIRM_DATE),
        DECODE(p_delivery_rec.ASN_DATE_SENT,NULL,WND.ASN_DATE_SENT,FND_API.G_MISS_DATE,NULL,p_delivery_rec.ASN_DATE_SENT),
        DECODE(p_delivery_rec.ASN_STATUS_CODE,NULL,WND.ASN_STATUS_CODE,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ASN_STATUS_CODE),
        DECODE(p_delivery_rec.ASN_SEQ_NUMBER,NULL,WND.ASN_SEQ_NUMBER,FND_API.G_MISS_NUM,NULL,p_delivery_rec.ASN_SEQ_NUMBER),
        DECODE(p_delivery_rec.GROSS_WEIGHT,NULL,WND.GROSS_WEIGHT,FND_API.G_MISS_NUM,NULL,p_delivery_rec.GROSS_WEIGHT),
        DECODE(p_delivery_rec.NET_WEIGHT,NULL,WND.NET_WEIGHT,FND_API.G_MISS_NUM,NULL,p_delivery_rec.NET_WEIGHT),
        DECODE(p_delivery_rec.WEIGHT_UOM_CODE,NULL,WND.WEIGHT_UOM_CODE,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.WEIGHT_UOM_CODE),
        DECODE(p_delivery_rec.VOLUME,NULL,WND.VOLUME,FND_API.G_MISS_NUM,NULL,p_delivery_rec.VOLUME),
        DECODE(p_delivery_rec.VOLUME_UOM_CODE,NULL,WND.VOLUME_UOM_CODE,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.VOLUME_UOM_CODE),
        DECODE(p_delivery_rec.ADDITIONAL_SHIPMENT_INFO,NULL,WND.ADDITIONAL_SHIPMENT_INFO,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ADDITIONAL_SHIPMENT_INFO),
        DECODE(p_delivery_rec.CURRENCY_CODE,NULL,WND.CURRENCY_CODE,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.CURRENCY_CODE),
        DECODE(p_delivery_rec.ATTRIBUTE_CATEGORY,NULL,WND.ATTRIBUTE_CATEGORY,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ATTRIBUTE_CATEGORY),
        DECODE(p_delivery_rec.ATTRIBUTE1,NULL,WND.ATTRIBUTE1,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ATTRIBUTE1),
        DECODE(p_delivery_rec.ATTRIBUTE2,NULL,WND.ATTRIBUTE2,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ATTRIBUTE2),
        DECODE(p_delivery_rec.ATTRIBUTE3,NULL,WND.ATTRIBUTE3,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ATTRIBUTE3),
        DECODE(p_delivery_rec.ATTRIBUTE4,NULL,WND.ATTRIBUTE4,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ATTRIBUTE4),
        DECODE(p_delivery_rec.ATTRIBUTE5,NULL,WND.ATTRIBUTE5,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ATTRIBUTE5),
        DECODE(p_delivery_rec.ATTRIBUTE6,NULL,WND.ATTRIBUTE6,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ATTRIBUTE6),
        DECODE(p_delivery_rec.ATTRIBUTE7,NULL,WND.ATTRIBUTE7,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ATTRIBUTE7),
        DECODE(p_delivery_rec.ATTRIBUTE8,NULL,WND.ATTRIBUTE8,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ATTRIBUTE8),
        DECODE(p_delivery_rec.ATTRIBUTE9,NULL,WND.ATTRIBUTE9,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ATTRIBUTE9),
        DECODE(p_delivery_rec.ATTRIBUTE10,NULL,WND.ATTRIBUTE10,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ATTRIBUTE10),
        DECODE(p_delivery_rec.ATTRIBUTE11,NULL,WND.ATTRIBUTE11,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ATTRIBUTE11),
        DECODE(p_delivery_rec.ATTRIBUTE12,NULL,WND.ATTRIBUTE12,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ATTRIBUTE12),
        DECODE(p_delivery_rec.ATTRIBUTE13,NULL,WND.ATTRIBUTE13,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ATTRIBUTE13),
        DECODE(p_delivery_rec.ATTRIBUTE14,NULL,WND.ATTRIBUTE14,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ATTRIBUTE14),
        DECODE(p_delivery_rec.ATTRIBUTE15,NULL,WND.ATTRIBUTE15,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ATTRIBUTE15),
        DECODE(p_delivery_rec.TP_ATTRIBUTE_CATEGORY,NULL,WND.TP_ATTRIBUTE_CATEGORY,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.TP_ATTRIBUTE_CATEGORY),
        DECODE(p_delivery_rec.TP_ATTRIBUTE1,NULL,WND.TP_ATTRIBUTE1,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.TP_ATTRIBUTE1),
        DECODE(p_delivery_rec.TP_ATTRIBUTE2,NULL,WND.TP_ATTRIBUTE2,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.TP_ATTRIBUTE2),
        DECODE(p_delivery_rec.TP_ATTRIBUTE3,NULL,WND.TP_ATTRIBUTE3,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.TP_ATTRIBUTE3),
        DECODE(p_delivery_rec.TP_ATTRIBUTE4,NULL,WND.TP_ATTRIBUTE4,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.TP_ATTRIBUTE4),
        DECODE(p_delivery_rec.TP_ATTRIBUTE5,NULL,WND.TP_ATTRIBUTE5,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.TP_ATTRIBUTE5),
        DECODE(p_delivery_rec.TP_ATTRIBUTE6,NULL,WND.TP_ATTRIBUTE6,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.TP_ATTRIBUTE6),
        DECODE(p_delivery_rec.TP_ATTRIBUTE7,NULL,WND.TP_ATTRIBUTE7,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.TP_ATTRIBUTE7),
        DECODE(p_delivery_rec.TP_ATTRIBUTE8,NULL,WND.TP_ATTRIBUTE8,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.TP_ATTRIBUTE8),
        DECODE(p_delivery_rec.TP_ATTRIBUTE9,NULL,WND.TP_ATTRIBUTE9,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.TP_ATTRIBUTE9),
        DECODE(p_delivery_rec.TP_ATTRIBUTE10,NULL,WND.TP_ATTRIBUTE10,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.TP_ATTRIBUTE10),
        DECODE(p_delivery_rec.TP_ATTRIBUTE11,NULL,WND.TP_ATTRIBUTE11,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.TP_ATTRIBUTE11),
        DECODE(p_delivery_rec.TP_ATTRIBUTE12,NULL,WND.TP_ATTRIBUTE12,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.TP_ATTRIBUTE12),
        DECODE(p_delivery_rec.TP_ATTRIBUTE13,NULL,WND.TP_ATTRIBUTE13,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.TP_ATTRIBUTE13),
        DECODE(p_delivery_rec.TP_ATTRIBUTE14,NULL,WND.TP_ATTRIBUTE14,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.TP_ATTRIBUTE14),
        DECODE(p_delivery_rec.TP_ATTRIBUTE15,NULL,WND.TP_ATTRIBUTE15,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.TP_ATTRIBUTE15),
        DECODE(p_delivery_rec.GLOBAL_ATTRIBUTE_CATEGORY,NULL,WND.GLOBAL_ATTRIBUTE_CATEGORY,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.GLOBAL_ATTRIBUTE_CATEGORY),
        DECODE(p_delivery_rec.GLOBAL_ATTRIBUTE1,NULL,WND.GLOBAL_ATTRIBUTE1,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.GLOBAL_ATTRIBUTE1),
        DECODE(p_delivery_rec.GLOBAL_ATTRIBUTE2,NULL,WND.GLOBAL_ATTRIBUTE2,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.GLOBAL_ATTRIBUTE2),
        DECODE(p_delivery_rec.GLOBAL_ATTRIBUTE3,NULL,WND.GLOBAL_ATTRIBUTE3,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.GLOBAL_ATTRIBUTE3),
        DECODE(p_delivery_rec.GLOBAL_ATTRIBUTE4,NULL,WND.GLOBAL_ATTRIBUTE4,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.GLOBAL_ATTRIBUTE4),
        DECODE(p_delivery_rec.GLOBAL_ATTRIBUTE5,NULL,WND.GLOBAL_ATTRIBUTE5,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.GLOBAL_ATTRIBUTE5),
        DECODE(p_delivery_rec.GLOBAL_ATTRIBUTE6,NULL,WND.GLOBAL_ATTRIBUTE6,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.GLOBAL_ATTRIBUTE6),
        DECODE(p_delivery_rec.GLOBAL_ATTRIBUTE7,NULL,WND.GLOBAL_ATTRIBUTE7,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.GLOBAL_ATTRIBUTE7),
        DECODE(p_delivery_rec.GLOBAL_ATTRIBUTE8,NULL,WND.GLOBAL_ATTRIBUTE8,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.GLOBAL_ATTRIBUTE8),
        DECODE(p_delivery_rec.GLOBAL_ATTRIBUTE9,NULL,WND.GLOBAL_ATTRIBUTE9,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.GLOBAL_ATTRIBUTE9),
        DECODE(p_delivery_rec.GLOBAL_ATTRIBUTE10,NULL,WND.GLOBAL_ATTRIBUTE10,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.GLOBAL_ATTRIBUTE10),
        DECODE(p_delivery_rec.GLOBAL_ATTRIBUTE11,NULL,WND.GLOBAL_ATTRIBUTE11,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.GLOBAL_ATTRIBUTE11),
        DECODE(p_delivery_rec.GLOBAL_ATTRIBUTE12,NULL,WND.GLOBAL_ATTRIBUTE12,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.GLOBAL_ATTRIBUTE12),
        DECODE(p_delivery_rec.GLOBAL_ATTRIBUTE13,NULL,WND.GLOBAL_ATTRIBUTE13,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.GLOBAL_ATTRIBUTE13),
        DECODE(p_delivery_rec.GLOBAL_ATTRIBUTE14,NULL,WND.GLOBAL_ATTRIBUTE14,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.GLOBAL_ATTRIBUTE14),
        DECODE(p_delivery_rec.GLOBAL_ATTRIBUTE15,NULL,WND.GLOBAL_ATTRIBUTE15,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.GLOBAL_ATTRIBUTE15),
        DECODE(p_delivery_rec.GLOBAL_ATTRIBUTE16,NULL,WND.GLOBAL_ATTRIBUTE16,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.GLOBAL_ATTRIBUTE16),
        DECODE(p_delivery_rec.GLOBAL_ATTRIBUTE17,NULL,WND.GLOBAL_ATTRIBUTE17,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.GLOBAL_ATTRIBUTE17),
        DECODE(p_delivery_rec.GLOBAL_ATTRIBUTE18,NULL,WND.GLOBAL_ATTRIBUTE18,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.GLOBAL_ATTRIBUTE18),
        DECODE(p_delivery_rec.GLOBAL_ATTRIBUTE19,NULL,WND.GLOBAL_ATTRIBUTE19,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.GLOBAL_ATTRIBUTE19),
        DECODE(p_delivery_rec.GLOBAL_ATTRIBUTE20,NULL,WND.GLOBAL_ATTRIBUTE20,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.GLOBAL_ATTRIBUTE20),
        DECODE(p_delivery_rec.CREATION_DATE,NULL,WND.CREATION_DATE,FND_API.G_MISS_DATE,NULL,p_delivery_rec.CREATION_DATE),
        DECODE(p_delivery_rec.CREATED_BY,NULL,WND.CREATED_BY,FND_API.G_MISS_NUM,NULL,p_delivery_rec.CREATED_BY),
        DECODE(p_delivery_rec.LAST_UPDATE_DATE,NULL,WND.LAST_UPDATE_DATE,FND_API.G_MISS_DATE,NULL,p_delivery_rec.LAST_UPDATE_DATE),
        DECODE(p_delivery_rec.LAST_UPDATED_BY,NULL,WND.LAST_UPDATED_BY,FND_API.G_MISS_NUM,NULL,p_delivery_rec.LAST_UPDATED_BY),
        DECODE(p_delivery_rec.LAST_UPDATE_LOGIN,NULL,WND.LAST_UPDATE_LOGIN,FND_API.G_MISS_NUM,NULL,p_delivery_rec.LAST_UPDATE_LOGIN),
        DECODE(p_delivery_rec.PROGRAM_APPLICATION_ID,NULL,WND.PROGRAM_APPLICATION_ID,FND_API.G_MISS_NUM,NULL,p_delivery_rec.PROGRAM_APPLICATION_ID),
        DECODE(p_delivery_rec.PROGRAM_ID,NULL,WND.PROGRAM_ID,FND_API.G_MISS_NUM,NULL,p_delivery_rec.PROGRAM_ID),
        DECODE(p_delivery_rec.PROGRAM_UPDATE_DATE,NULL,WND.PROGRAM_UPDATE_DATE,FND_API.G_MISS_DATE,NULL,p_delivery_rec.PROGRAM_UPDATE_DATE),
        DECODE(p_delivery_rec.REQUEST_ID,NULL,WND.REQUEST_ID,FND_API.G_MISS_NUM,NULL,p_delivery_rec.REQUEST_ID),
        DECODE(p_delivery_rec.BATCH_ID,NULL,WND.BATCH_ID,FND_API.G_MISS_NUM,NULL,p_delivery_rec.BATCH_ID),
        DECODE(p_delivery_rec.HASH_VALUE,NULL,WND.HASH_VALUE,FND_API.G_MISS_NUM,NULL,p_delivery_rec.HASH_VALUE),
        DECODE(p_delivery_rec.SOURCE_HEADER_ID,NULL,WND.SOURCE_HEADER_ID,FND_API.G_MISS_NUM,NULL,p_delivery_rec.SOURCE_HEADER_ID),
        DECODE(p_delivery_rec.NUMBER_OF_LPN,NULL,WND.NUMBER_OF_LPN,FND_API.G_MISS_NUM,NULL,p_delivery_rec.NUMBER_OF_LPN),
        DECODE(p_delivery_rec.COD_AMOUNT,NULL,WND.COD_AMOUNT,FND_API.G_MISS_NUM,NULL,p_delivery_rec.COD_AMOUNT),
        DECODE(p_delivery_rec.COD_CURRENCY_CODE,NULL,WND.COD_CURRENCY_CODE,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.COD_CURRENCY_CODE),
        DECODE(p_delivery_rec.COD_REMIT_TO,NULL,WND.COD_REMIT_TO,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.COD_REMIT_TO),
        DECODE(p_delivery_rec.COD_CHARGE_PAID_BY,NULL,WND.COD_CHARGE_PAID_BY,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.COD_CHARGE_PAID_BY),
        DECODE(p_delivery_rec.PROBLEM_CONTACT_REFERENCE,NULL,WND.PROBLEM_CONTACT_REFERENCE,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.PROBLEM_CONTACT_REFERENCE),
        DECODE(p_delivery_rec.PORT_OF_LOADING,NULL,WND.PORT_OF_LOADING,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.PORT_OF_LOADING),
        DECODE(p_delivery_rec.PORT_OF_DISCHARGE,NULL,WND.PORT_OF_DISCHARGE,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.PORT_OF_DISCHARGE),
        DECODE(p_delivery_rec.FTZ_NUMBER,NULL,WND.FTZ_NUMBER,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.FTZ_NUMBER),
        DECODE(p_delivery_rec.ROUTED_EXPORT_TXN,NULL,WND.ROUTED_EXPORT_TXN,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ROUTED_EXPORT_TXN),
        DECODE(p_delivery_rec.ENTRY_NUMBER,NULL,WND.ENTRY_NUMBER,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ENTRY_NUMBER),
        DECODE(p_delivery_rec.ROUTING_INSTRUCTIONS,NULL,WND.ROUTING_INSTRUCTIONS,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ROUTING_INSTRUCTIONS),
        DECODE(p_delivery_rec.IN_BOND_CODE,NULL,WND.IN_BOND_CODE,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.IN_BOND_CODE),
        DECODE(p_delivery_rec.SHIPPING_MARKS,NULL,WND.SHIPPING_MARKS,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.SHIPPING_MARKS),
        DECODE(p_delivery_rec.SERVICE_LEVEL,NULL,WND.SERVICE_LEVEL,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.SERVICE_LEVEL),
        DECODE(p_delivery_rec.MODE_OF_TRANSPORT,NULL,WND.MODE_OF_TRANSPORT,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.MODE_OF_TRANSPORT),
        DECODE(p_delivery_rec.ASSIGNED_TO_FTE_TRIPS,NULL,WND.ASSIGNED_TO_FTE_TRIPS,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.ASSIGNED_TO_FTE_TRIPS),
        DECODE(p_delivery_rec.AUTO_SC_EXCLUDE_FLAG,NULL,WND.AUTO_SC_EXCLUDE_FLAG,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.AUTO_SC_EXCLUDE_FLAG),
        DECODE(p_delivery_rec.AUTO_AP_EXCLUDE_FLAG,NULL,WND.AUTO_AP_EXCLUDE_FLAG,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.AUTO_AP_EXCLUDE_FLAG),
        DECODE(p_delivery_rec.AP_BATCH_ID,NULL,WND.AP_BATCH_ID,FND_API.G_MISS_NUM,NULL,p_delivery_rec.AP_BATCH_ID),
        DECODE(p_delivery_rec.SHIPMENT_DIRECTION,NULL,WND.SHIPMENT_DIRECTION,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.SHIPMENT_DIRECTION),
        DECODE(p_delivery_rec.VENDOR_ID,NULL,WND.VENDOR_ID,FND_API.G_MISS_NUM,NULL,p_delivery_rec.VENDOR_ID),
        DECODE(p_delivery_rec.PARTY_ID,NULL,WND.PARTY_ID,FND_API.G_MISS_NUM,NULL,p_delivery_rec.PARTY_ID),
        DECODE(p_delivery_rec.ROUTING_RESPONSE_ID,NULL,WND.ROUTING_RESPONSE_ID,FND_API.G_MISS_NUM,NULL,p_delivery_rec.ROUTING_RESPONSE_ID),
        DECODE(p_delivery_rec.RCV_SHIPMENT_HEADER_ID,NULL,WND.RCV_SHIPMENT_HEADER_ID,FND_API.G_MISS_NUM,NULL,p_delivery_rec.RCV_SHIPMENT_HEADER_ID),
        DECODE(p_delivery_rec.ASN_SHIPMENT_HEADER_ID,NULL,WND.ASN_SHIPMENT_HEADER_ID,FND_API.G_MISS_NUM,NULL,p_delivery_rec.ASN_SHIPMENT_HEADER_ID),
        DECODE(p_delivery_rec.SHIPPING_CONTROL,NULL,WND.SHIPPING_CONTROL,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.SHIPPING_CONTROL),
        DECODE(p_delivery_rec.TP_DELIVERY_NUMBER,NULL,WND.TP_DELIVERY_NUMBER,FND_API.G_MISS_NUM,NULL,p_delivery_rec.TP_DELIVERY_NUMBER),
        DECODE(p_delivery_rec.EARLIEST_PICKUP_DATE,NULL,WND.EARLIEST_PICKUP_DATE,FND_API.G_MISS_DATE,NULL,p_delivery_rec.EARLIEST_PICKUP_DATE),
        DECODE(p_delivery_rec.LATEST_PICKUP_DATE,NULL,WND.LATEST_PICKUP_DATE,FND_API.G_MISS_DATE,NULL,p_delivery_rec.LATEST_PICKUP_DATE),
        DECODE(p_delivery_rec.EARLIEST_DROPOFF_DATE,NULL,WND.EARLIEST_DROPOFF_DATE,FND_API.G_MISS_DATE,NULL,p_delivery_rec.EARLIEST_DROPOFF_DATE),
        DECODE(p_delivery_rec.LATEST_DROPOFF_DATE,NULL,WND.LATEST_DROPOFF_DATE,FND_API.G_MISS_DATE,NULL,p_delivery_rec.LATEST_DROPOFF_DATE),
        DECODE(p_delivery_rec.IGNORE_FOR_PLANNING,NULL,WND.IGNORE_FOR_PLANNING,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.IGNORE_FOR_PLANNING),
        DECODE(p_delivery_rec.TP_PLAN_NAME,NULL,WND.TP_PLAN_NAME,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.TP_PLAN_NAME),
        DECODE(p_delivery_rec.hash_string,NULL,WND.hash_string,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.hash_string),
        DECODE(p_delivery_rec.delivered_date,NULL,WND.delivered_date,FND_API.G_MISS_DATE,NULL,p_delivery_rec.delivered_date),
	-- bug 3667348
	DECODE(p_delivery_rec.REASON_OF_TRANSPORT,NULL,WND.REASON_OF_TRANSPORT,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.REASON_OF_TRANSPORT),
	DECODE(p_delivery_rec.DESCRIPTION,NULL,WND.DESCRIPTION,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.DESCRIPTION),
        DECODE(p_copy_legs, 'Y', WND.ITINERARY_COMPLETE, 'N'),
	-- bug 3667348
        --OTM R12
        DECODE(p_delivery_rec.TMS_INTERFACE_FLAG,NULL,WND.TMS_INTERFACE_FLAG,FND_API.G_MISS_CHAR,NULL,p_delivery_rec.TMS_INTERFACE_FLAG),
        DECODE(p_delivery_rec.TMS_VERSION_NUMBER,NULL,WND.TMS_VERSION_NUMBER,FND_API.G_MISS_NUM,NULL,p_delivery_rec.TMS_VERSION_NUMBER)
        --
    FROM    WSH_NEW_DELIVERIES WND
    WHERE   delivery_id = p_delivery_id;
    --
    --
    IF SQL%ROWCOUNT = 0
    THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_DLVY_NOT_EXIST');
        FND_MESSAGE.SET_TOKEN('DELIVERY_ID', p_delivery_id);
        WSH_UTIL_CORE.add_message (wsh_util_core.g_ret_sts_error,l_module_name);
        --
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'l_delivery_id', l_delivery_id );
    END IF;
    --
    --
    OPEN dlvy_csr(l_delivery_id);
    FETCH dlvy_csr INTO x_rowid;
    CLOSE dlvy_csr;
    --
    --
    IF p_copy_legs = 'Y'
    THEN
    --{
        INSERT INTO wsh_delivery_legs
            (
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
                DESTINATION_STOP_ID
            )
        SELECT
                wsh_delivery_legs_s.NEXTVAL,
                l_delivery_id,
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
                DESTINATION_STOP_ID
        FROM    WSH_DELIVERY_LEGS
        WHERE   DELIVERY_ID = p_delivery_id;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Inserted ' || SQL%ROWCOUNT || ' Legs' );
        END IF;
        --
       OPEN leg_csr(l_delivery_id);
       FETCH leg_csr BULK COLLECT INTO x_leg_id_tab;
       CLOSE leg_csr;
       --
       --
    --}
    END IF;
    --
    x_delivery_id := l_delivery_id;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
--}
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
    WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        wsh_util_core.default_handler('WSH_NEW_DELIVERIES_PVT.CLONE',l_module_name);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
END CLONE;
-- J-IB-NPARIKH-}

--  Bug 3292364
--  Procedure:   Table_To_Record
--  Parameters:  x_delivery_rec: A record of all attributes of a Delivery Record
--               p_delivery_id : delivery_id of the delivery that is to be copied
--  Description: This procedure will copy the attributes of a delivery in wsh_new_deliveries
--               and copy it to a record.

PROCEDURE Table_to_Record (p_delivery_id IN NUMBER,
                           x_delivery_rec OUT NOCOPY WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type,
                           x_return_status OUT NOCOPY VARCHAR2) IS

  CURSOR c_tbl_rec (p_delivery_id in NUMBER) IS
  SELECT DELIVERY_ID
        ,NAME
        ,PLANNED_FLAG
        ,STATUS_CODE
        ,DELIVERY_TYPE
        ,LOADING_SEQUENCE
        ,LOADING_ORDER_FLAG
        ,INITIAL_PICKUP_DATE
        ,INITIAL_PICKUP_LOCATION_ID
        ,ORGANIZATION_ID
        ,ULTIMATE_DROPOFF_LOCATION_ID
        ,ULTIMATE_DROPOFF_DATE
        ,CUSTOMER_ID
        ,INTMED_SHIP_TO_LOCATION_ID
        ,POOLED_SHIP_TO_LOCATION_ID
        ,CARRIER_ID
        ,SHIP_METHOD_CODE
        ,FREIGHT_TERMS_CODE
        ,FOB_CODE
        ,FOB_LOCATION_ID
        ,WAYBILL
        ,DOCK_CODE
        ,ACCEPTANCE_FLAG
        ,ACCEPTED_BY
        ,ACCEPTED_DATE
        ,ACKNOWLEDGED_BY
        ,CONFIRMED_BY
        ,CONFIRM_DATE
        ,ASN_DATE_SENT
        ,ASN_STATUS_CODE
        ,ASN_SEQ_NUMBER
        ,GROSS_WEIGHT
        ,NET_WEIGHT
        ,WEIGHT_UOM_CODE
        ,VOLUME
        ,VOLUME_UOM_CODE
        ,ADDITIONAL_SHIPMENT_INFO
        ,CURRENCY_CODE
        ,ATTRIBUTE_CATEGORY
        ,ATTRIBUTE1
        ,ATTRIBUTE2
        ,ATTRIBUTE3
        ,ATTRIBUTE4
        ,ATTRIBUTE5
        ,ATTRIBUTE6
        ,ATTRIBUTE7
        ,ATTRIBUTE8
        ,ATTRIBUTE9
        ,ATTRIBUTE10
        ,ATTRIBUTE11
        ,ATTRIBUTE12
        ,ATTRIBUTE13
        ,ATTRIBUTE14
        ,ATTRIBUTE15
        ,TP_ATTRIBUTE_CATEGORY
        ,TP_ATTRIBUTE1
        ,TP_ATTRIBUTE2
        ,TP_ATTRIBUTE3
        ,TP_ATTRIBUTE4
        ,TP_ATTRIBUTE5
        ,TP_ATTRIBUTE6
        ,TP_ATTRIBUTE7
        ,TP_ATTRIBUTE8
        ,TP_ATTRIBUTE9
        ,TP_ATTRIBUTE10
        ,TP_ATTRIBUTE11
        ,TP_ATTRIBUTE12
        ,TP_ATTRIBUTE13
        ,TP_ATTRIBUTE14
        ,TP_ATTRIBUTE15
        ,GLOBAL_ATTRIBUTE_CATEGORY
        ,GLOBAL_ATTRIBUTE1
        ,GLOBAL_ATTRIBUTE2
        ,GLOBAL_ATTRIBUTE3
        ,GLOBAL_ATTRIBUTE4
        ,GLOBAL_ATTRIBUTE5
        ,GLOBAL_ATTRIBUTE6
        ,GLOBAL_ATTRIBUTE7
        ,GLOBAL_ATTRIBUTE8
        ,GLOBAL_ATTRIBUTE9
        ,GLOBAL_ATTRIBUTE10
        ,GLOBAL_ATTRIBUTE11
        ,GLOBAL_ATTRIBUTE12
        ,GLOBAL_ATTRIBUTE13
        ,GLOBAL_ATTRIBUTE14
        ,GLOBAL_ATTRIBUTE15
        ,GLOBAL_ATTRIBUTE16
        ,GLOBAL_ATTRIBUTE17
        ,GLOBAL_ATTRIBUTE18
        ,GLOBAL_ATTRIBUTE19
        ,GLOBAL_ATTRIBUTE20
        ,CREATION_DATE
        ,CREATED_BY
        ,sysdate
        ,FND_GLOBAL.USER_ID
        ,FND_GLOBAL.LOGIN_ID
        ,PROGRAM_APPLICATION_ID
        ,PROGRAM_ID
        ,PROGRAM_UPDATE_DATE
        ,REQUEST_ID
        ,BATCH_ID
        ,HASH_VALUE
        ,SOURCE_HEADER_ID
        ,NUMBER_OF_LPN
        ,COD_AMOUNT
        ,COD_CURRENCY_CODE
        ,COD_REMIT_TO
        ,COD_CHARGE_PAID_BY
        ,PROBLEM_CONTACT_REFERENCE
        ,PORT_OF_LOADING
        ,PORT_OF_DISCHARGE
        ,FTZ_NUMBER
        ,ROUTED_EXPORT_TXN
        ,ENTRY_NUMBER
        ,ROUTING_INSTRUCTIONS
        ,IN_BOND_CODE
        ,SHIPPING_MARKS
        ,SERVICE_LEVEL
        ,MODE_OF_TRANSPORT
        ,ASSIGNED_TO_FTE_TRIPS
        ,AUTO_SC_EXCLUDE_FLAG
        ,AUTO_AP_EXCLUDE_FLAG
        ,AP_BATCH_ID
        -- The following are non database columns in the rec. structure.
        ,NULL -- ROWID
        ,NULL -- LOADING_ORDER_DESC
        ,NULL -- ORGANIZATION_CODE
        ,NULL -- ULTIMATE_DROPOFF_LOCATION_CODE
        ,NULL -- INITIAL_PICKUP_LOCATION_CODE
        ,NULL -- CUSTOMER_NUMBER
        ,NULL -- INTMED_SHIP_TO_LOCATION_CODE
        ,NULL -- POOLED_SHIP_TO_LOCATION_CODE
        ,NULL -- CARRIER_CODE
        ,NULL -- SHIP_METHOD_NAME
        ,NULL -- FREIGHT_TERMS_NAME
        ,NULL -- FOB_NAME
        ,NULL -- FOB_LOCATION_CODE
        ,NULL -- WEIGHT_UOM_DESC
        ,NULL -- VOLUME_UOM_DESC
        ,NULL -- CURRENCY_NAME
        --  End non database columns in the rec. structure.
        ,SHIPMENT_DIRECTION
        ,VENDOR_ID
        ,PARTY_ID
        ,ROUTING_RESPONSE_ID
        ,RCV_SHIPMENT_HEADER_ID
        ,ASN_SHIPMENT_HEADER_ID
        ,SHIPPING_CONTROL
        ,TP_DELIVERY_NUMBER
        ,EARLIEST_PICKUP_DATE
        ,LATEST_PICKUP_DATE
        ,EARLIEST_DROPOFF_DATE
        ,LATEST_DROPOFF_DATE
        ,nvl(IGNORE_FOR_PLANNING, 'N')
        ,TP_PLAN_NAME
        ,WV_FROZEN_FLAG
        ,HASH_STRING
        ,DELIVERED_DATE
        -- Non database column
        ,NULL -- packing_slip
	-- bug 3667348
	,REASON_OF_TRANSPORT
	,DESCRIPTION
	-- bug 3667348
	,'N'--Non Database field added for "Proration of weight from Delivery to delivery lines" Project(Bug#4254552).
        --OTM R12
        ,TMS_INTERFACE_FLAG
        ,TMS_VERSION_NUMBER
        --R12.1.1 STANDALONE PROJECT
        ,pending_advice_flag
        ,client_id -- LSP PROJECT -- --Modified R12.1.1 LSP PROJECT(rminocha)
        ,NULL -- client_code LSP PROJECT
   FROM wsh_new_deliveries
  WHERE delivery_id = p_delivery_id;

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Table_To_Record';


BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'p_delivery_id', p_delivery_id);
    END IF;
    --

    OPEN c_tbl_rec (p_delivery_id);
    FETCH c_tbl_rec INTO x_delivery_rec;
        IF c_tbl_rec%NOTFOUND THEN
        --
           CLOSE c_tbl_rec;
           RAISE no_data_found;
        --
        END IF;
    CLOSE c_tbl_rec;
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    x_return_status := wsh_util_core.g_ret_sts_success;

EXCEPTION

    WHEN OTHERS THEN
      IF c_tbl_rec%ISOPEN THEN
         CLOSE c_tbl_rec;
      END IF;
      --
      x_return_status := wsh_util_core.g_ret_sts_unexp_error;
      --
      wsh_util_core.default_handler('WSH_NEW_DELIVERIES_PVT.Table_to_Record',l_module_name);
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --

END  Table_to_Record;


  --OTM R12
  ----------------------------------------------------------
  -- PROCEDURE UPDATE_TMS_INTERFACE_FLAG
  --
  -- parameters:	p_delivery_id_tab	table of delivery ids to update
  --			p_tms_interface_flag_tab table of the interface_flag
  --                                             for the delivery to set to
  --			x_return_status		return status
  --
  -- description:	This procedure updates the delivery's tms_interface_flag
  --                    to the according flag in the p_tms_interface_flag_tab.
  -- 	                Also calls LOG_OTM_EXCEPTION.
  ----------------------------------------------------------
  PROCEDURE UPDATE_TMS_INTERFACE_FLAG
  (p_delivery_id_tab        IN WSH_UTIL_CORE.ID_TAB_TYPE,
   p_tms_interface_flag_tab IN WSH_UTIL_CORE.COLUMN_TAB_TYPE,
   x_return_status          OUT NOCOPY VARCHAR2) IS

  l_num_error                   NUMBER;
  l_num_warn                    NUMBER;
  l_return_status               VARCHAR2(1);
  l_delivery_info_tab           WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
  l_delivery_info               WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;

  l_new_tms_interface_flag_tab  WSH_UTIL_CORE.COLUMN_TAB_TYPE;
  l_new_tms_version_number_tab  WSH_UTIL_CORE.ID_TAB_TYPE;
  l_delivery_id_tab             WSH_UTIL_CORE.ID_TAB_TYPE;
  l_trip_not_found              VARCHAR2(1);
  l_trip_info_rec               WSH_DELIVERY_VALIDATIONS.trip_info_rec_type;
  i                             NUMBER;
  l_count                       NUMBER;
  l_gc3_is_installed            VARCHAR2(1);
  RECORD_LOCKED                 EXCEPTION;
  PRAGMA EXCEPTION_INIT(RECORD_LOCKED, -54);

  l_debug_on                    BOOLEAN;

  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_TMS_INTERFACE_FLAG';

  BEGIN
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'Delivery ID count', p_delivery_id_tab.COUNT);
      WSH_DEBUG_SV.log(l_module_name,'Interface Flag count', p_tms_interface_flag_tab.COUNT);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED; -- this is global variable

    IF l_gc3_is_installed IS NULL THEN
      l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED; -- this is actual function
    END IF;

    l_num_warn := 0;
    l_num_error := 0;
    i := 0;
    l_count := 0;

    SAVEPOINT tms_update;

    IF (p_delivery_id_tab.COUNT <> p_tms_interface_flag_tab.COUNT) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Delivery ID and TMS_interface_flag_tab count does not match');
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_delivery_id_tab.COUNT > 0
        AND l_gc3_is_installed = 'Y') THEN

      i := p_delivery_id_tab.FIRST;

      WHILE i IS NOT NULL LOOP

        l_trip_not_found := 'N';

        --get trip information for delivery, no update when trip not OPEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.GET_TRIP_INFORMATION',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        WSH_DELIVERY_VALIDATIONS.get_trip_information
              (p_delivery_id     => p_delivery_id_tab(i),
               x_trip_info_rec   => l_trip_info_rec,
               x_return_status   => l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_DELIVERY_VALIDATIONS.GET_TRIP_INFORMATION',l_return_status);
        END IF;

        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Delivery ' || p_delivery_id_tab(i) || ' failed during get_trip_information');
          END IF;
          l_num_error := l_num_error + 1;
          EXIT;
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
          l_num_warn := l_num_warn + 1;
        END IF;

        IF (l_trip_not_found = 'N' AND l_trip_info_rec.trip_id IS NULL) THEN
          l_trip_not_found := 'Y';
        END IF;

        -- only do changes when there's no trip or trip status is OPEN
        -- if trip is found closed, should be actual shipment update
        --Bug 7408338 Trip in status 'In-Transit' should also get processed.
        IF (l_trip_info_rec.status_code IN ('OP','IT','CL') OR l_trip_not_found = 'Y') THEN

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.get_delivery_information',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_DELIVERY_VALIDATIONS.get_delivery_information(
                p_delivery_id   => p_delivery_id_tab(i),
                x_delivery_rec  => l_delivery_info,
                x_return_status => l_return_status);

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_DELIVERY_VALIDATIONS.get_delivery_information',l_return_status);
          END IF;

          IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Delivery ' || p_delivery_id_tab(i) || ' failed during table_to_record');
            END IF;
            l_num_error := l_num_error + 1;
            EXIT;
          ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
            l_num_warn := l_num_warn + 1;
          END IF;

          l_delivery_info_tab(l_delivery_info_tab.COUNT+1) := l_delivery_info;
          l_count := l_delivery_info_tab.COUNT;
          l_delivery_id_tab(l_count) := l_delivery_info.delivery_id;

          -- we only increment the version number on interface_flag when
          -- the interface_flag is changed from other status to DR or UR or CR
          IF (p_tms_interface_flag_tab(i) IS NULL) THEN
            --assume regular update
            IF (l_delivery_info.tms_interface_flag IN
                (WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_IN_PROCESS,
                 WSH_NEW_DELIVERIES_PVT.C_TMS_AWAITING_ANSWER,
                 WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_IN_PROCESS,
                 WSH_NEW_DELIVERIES_PVT.C_TMS_ANSWER_RECEIVED)) THEN
              l_new_tms_interface_flag_tab(l_count) := WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED;
              l_new_tms_version_number_tab(l_count) := NVL(l_delivery_info.tms_version_number, 1) + 1;
            ELSE
              l_new_tms_interface_flag_tab(l_count) := NVL(l_delivery_info.tms_interface_flag, WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT);
              l_new_tms_version_number_tab(l_count) := NVL(l_delivery_info.tms_version_number, 1);
            END IF;
          ELSIF (p_tms_interface_flag_tab(i) = WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_REQUIRED
                 AND l_delivery_info.tms_interface_flag IN
                     (WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_REQUIRED,
                      WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT)) THEN
            --set to NS if previous flag is CR or NS and new flag is DR, CP might already be sent so set to DR
            l_new_tms_interface_flag_tab(l_count) := WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT;
            l_new_tms_version_number_tab(l_count) := NVL(l_delivery_info.tms_version_number, 1);
          ELSIF (p_tms_interface_flag_tab(i) = WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_REQUIRED
                 AND l_delivery_info.tms_interface_flag = WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_IN_PROCESS) THEN
            --DP stays in DP
            l_new_tms_interface_flag_tab(l_count) := l_delivery_info.tms_interface_flag;
            l_new_tms_version_number_tab(l_count) := NVL(l_delivery_info.tms_version_number, 1);
          ELSIF (p_tms_interface_flag_tab(i) IN
                 (WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT,
                  WSH_NEW_DELIVERIES_PVT.C_TMS_AWAITING_ANSWER,
                  WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_IN_PROCESS,
                  WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_IN_PROCESS,
                  WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_IN_PROCESS,
                  WSH_NEW_DELIVERIES_PVT.C_TMS_ANSWER_RECEIVED,
                  WSH_NEW_DELIVERIES_PVT.C_TMS_COMPLETED)
                 OR p_tms_interface_flag_tab(i) = l_delivery_info.tms_interface_flag) THEN
            --all updates that does not change tms interface flag or are changing to anything besides UR CR DR,
            --do not increment the version
            l_new_tms_interface_flag_tab(l_count) := p_tms_interface_flag_tab(i);
            l_new_tms_version_number_tab(l_count) := NVL(l_delivery_info.tms_version_number, 1);
          ELSE
            l_new_tms_interface_flag_tab(l_count) := p_tms_interface_flag_tab(i);
            l_new_tms_version_number_tab(l_count) := NVL(l_delivery_info.tms_version_number, 1)+1;
          END IF;

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'p interface flag for '|| i, p_tms_interface_flag_tab(i));
            WSH_DEBUG_SV.log(l_module_name, 'new interface flag for '|| i, l_new_tms_interface_flag_tab(l_count));
            WSH_DEBUG_SV.log(l_module_name, 'new version number for '|| i, l_new_tms_version_number_tab(l_count));
          END IF;

        END IF;

        i := p_delivery_id_tab.NEXT(i);
      END LOOP;
      -- end of while loop

      IF l_num_error > 0 THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      ELSIF l_num_warn > 0 THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      END IF;

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      END IF;

      --proceed with update if not error status
      IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS, WSH_UTIL_CORE.G_RET_STS_WARNING)
         AND (l_delivery_info_tab.COUNT > 0)) THEN

        FORALL j IN l_delivery_info_tab.FIRST..l_delivery_info_tab.LAST
          UPDATE wsh_new_deliveries
          SET
                 TMS_VERSION_NUMBER = l_new_tms_version_number_tab(j)
                 ,TMS_INTERFACE_FLAG = l_new_tms_interface_flag_tab(j)
                 ,last_update_date = SYSDATE
                 ,last_updated_by = FND_GLOBAL.USER_ID
                 ,last_update_login = FND_GLOBAL.LOGIN_ID
          WHERE  DELIVERY_ID = l_delivery_id_tab(j);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Rows updated',SQL%ROWCOUNT);
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.LOG_OTM_EXCEPTION',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        WSH_XC_UTIL.log_otm_exception(
            p_delivery_info_tab      => l_delivery_info_tab,
            p_new_interface_flag_tab => l_new_tms_interface_flag_tab,
            x_return_status          => l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_XC_UTIL.LOG_OTM_EXCEPTION',l_return_status);
        END IF;

        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'ERROR: WSH_XC_UTIL.log_otm_exception failed');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'ERROR: WSH_XC_UTIL.log_otm_exception failed unexpectedly');
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
          --set return status to warning if l_return_status is warning
          x_return_status := l_return_status;
        END IF;

      END IF;

    END IF;
    -- Debug Statements
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO tms_update;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO tms_update;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

    WHEN RECORD_LOCKED THEN
      ROLLBACK TO tms_update;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Record_locked exception has occured. Cannot update delivery tms_interface_flag', WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:RECORD_LOCKED');
      END IF;

    WHEN others THEN
      ROLLBACK TO tms_update;
      wsh_util_core.default_handler('WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG',l_module_name);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

  END UPDATE_TMS_INTERFACE_FLAG;
  --END OTM R12

END WSH_NEW_DELIVERIES_PVT;

/
