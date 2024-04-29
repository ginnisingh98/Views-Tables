--------------------------------------------------------
--  DDL for Package Body WSH_BOLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_BOLS_PVT" AS
-- $Header: WSHBLTHB.pls 120.0 2005/05/26 18:48:27 appldev noship $

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_BOLS_PVT';
--
PROCEDURE update_Row
  (   p_api_version               IN      NUMBER
    , p_init_msg_list             IN      VARCHAR2
    , p_commit                    IN      VARCHAR2
    , p_validation_level          IN      NUMBER
    , x_return_status             OUT NOCOPY      VARCHAR2
    , x_msg_count                 OUT NOCOPY      NUMBER
    , x_msg_data                  OUT NOCOPY      VARCHAR2
    , p_entity_name               IN      VARCHAR2
    , x_entity_id                 IN      OUT NOCOPY  NUMBER
    , p_document_type             IN      VARCHAR2
/* Commented for shipping datamodel changes bug#1918342
    , p_pod_flag                  IN      VARCHAR2
    , p_pod_by                    IN      VARCHAR2
    , p_pod_date                  IN      DATE
    , p_reason_of_transport       IN      VARCHAR2
    , p_description               IN      VARCHAR2
    , p_cod_amount                IN      NUMBER
    , p_cod_currency_code         IN      VARCHAR2
    , p_cod_remit_to              IN      VARCHAR2
    , p_cod_charge_paid_by        IN      VARCHAR2
    , p_problem_contact_reference IN      VARCHAR2
    , p_bill_freight_to           IN      VARCHAR2
    , p_carried_by                IN      VARCHAR2
    , p_port_of_loading           IN      VARCHAR2
    , p_port_of_discharge         IN      VARCHAR2
    , p_booking_office            IN      VARCHAR2
    , p_booking_number            IN      VARCHAR2
    , p_service_contract          IN      VARCHAR2
    , p_shipper_export_ref        IN      VARCHAR2
    , p_carrier_export_ref        IN      VARCHAR2
    , p_bol_notify_party          IN      VARCHAR2
    , p_supplier_code             IN      VARCHAR2
    , p_aetc_number               IN      VARCHAR2
    , p_shipper_signed_by         IN      VARCHAR2
    , p_shipper_date              IN      DATE
    , p_carrier_signed_by         IN      VARCHAR2
    , p_carrier_date              IN      DATE
    , p_bol_issue_office          IN      VARCHAR2
    , p_bol_issued_by             IN      VARCHAR2
    , p_bol_date_issued           IN      DATE
    , p_shipper_hm_by             IN      VARCHAR2
    , p_shipper_hm_date           IN      DATE
    , p_carrier_hm_by             IN      VARCHAR2
    , p_carrier_hm_date           IN      DATE
    , p_ledger_id                 IN      NUMBER  */  -- LE Uptake
    , p_consolidate_option        IN      VARCHAR2
    , x_trip_id                   IN  OUT NOCOPY  NUMBER
    , x_trip_name                 IN  OUT NOCOPY  VARCHAR2
    , p_pick_up_location_id       IN      NUMBER
    , p_drop_off_location_id      IN      NUMBER
    , p_carrier_id                IN      NUMBER
    , p_ship_method               IN      VARCHAR2
    , p_delivery_id               IN      NUMBER
    , x_document_number           IN  OUT NOCOPY  VARCHAR2
  )
  IS
     x_rowid     varchar2(30);
     l_trip_info wsh_trips_pvt.trip_rec_type;
     l_leg_info_new wsh_delivery_legs_pvt.delivery_leg_rec_type;
     l_leg_info_old wsh_delivery_legs_pvt.delivery_leg_rec_type;
     l_old_leg_id    NUMBER;
     l_new_leg_id    NUMBER;
     l_ledger_id NUMBER;            -- LE Uptake
     l_del_rows  wsh_util_core.id_tab_type;
     l_leg_rows  wsh_util_core.id_tab_type;
     l_drop_off_stop_id NUMBER;
     l_pick_up_stop_id NUMBER;
     wsh_create_trip_error EXCEPTION;
     wsh_populate_trip_error EXCEPTION;
     wsh_update_trip_error EXCEPTION;
     wsh_assign_delivery_error EXCEPTION;
     wsh_populate_leg_error EXCEPTION;
     wsh_delete_leg_error EXCEPTION;
     wsh_update_leg_error EXCEPTION;
     wsh_create_document_error EXCEPTION;
     wsh_update_document_error EXCEPTION;

     msg_buffer VARCHAR2(32);
     tmp_buffer VARCHAR2(32);
     tmp_out NUMBER;
     --
l_debug_on BOOLEAN;
     --
     l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_ROW';
     --
BEGIN

   --
   -- Debug Statements
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
       WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION',P_API_VERSION);
       WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
       WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
       WSH_DEBUG_SV.log(l_module_name,'P_VALIDATION_LEVEL',P_VALIDATION_LEVEL);
       WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_NAME',P_ENTITY_NAME);
       WSH_DEBUG_SV.log(l_module_name,'X_ENTITY_ID',X_ENTITY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_TYPE',P_DOCUMENT_TYPE);
      -- WSH_DEBUG_SV.log(l_module_name,'P_LEDGER_ID',P_LEDGER_ID);   -- LE Uptake
       WSH_DEBUG_SV.log(l_module_name,'P_CONSOLIDATE_OPTION',P_CONSOLIDATE_OPTION);
       WSH_DEBUG_SV.log(l_module_name,'X_TRIP_ID',X_TRIP_ID);
       WSH_DEBUG_SV.log(l_module_name,'X_TRIP_NAME',X_TRIP_NAME);
       WSH_DEBUG_SV.log(l_module_name,'P_PICK_UP_LOCATION_ID',P_PICK_UP_LOCATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_DROP_OFF_LOCATION_ID',P_DROP_OFF_LOCATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_CARRIER_ID',P_CARRIER_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_SHIP_METHOD',P_SHIP_METHOD);
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
       WSH_DEBUG_SV.log(l_module_name,'X_DOCUMENT_NUMBER',X_DOCUMENT_NUMBER);
   END IF;
   --

   SELECT to_number(HOI.ORG_INFORMATION1) INTO l_ledger_id  -- LE Uptake
   FROM hr_organization_information hoi,
        wsh_new_deliveries wnd
   WHERE HOI.ORGANIZATION_ID = wnd.organization_id
   AND HOI.ORG_INFORMATION_CONTEXT = 'Accounting Information'
   AND wnd.delivery_id = p_delivery_id;

     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_ledger_id',l_ledger_id);  -- LE Uptake
     END IF;


   SAVEPOINT sp1;

   -- if document is not yet created, create it here
   IF x_document_number IS NULL THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_Document_PVT.CREATE_DOCUMENT',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_Document_PVT.create_document
	( 1.0,
	  'T',
	  NULL,
	  NULL,
	  x_return_status,
	  x_msg_count,
	  x_msg_data,
	  p_entity_name,
	  l_old_leg_id,
	  665,
	  p_pick_up_location_id,
	  'BOL',
	  p_ship_method,
	  l_ledger_id,      -- LE Uptake
	  'BOTH',
	  200,
	  x_document_number
	);
   END IF;

   IF x_return_status <> 'S' THEN
      RAISE wsh_create_document_error;
   END IF;



   -- update document
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'x_document_number',x_document_number);
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_Document_PVT.UPDATE_DOCUMENT',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   WSH_Document_PVT.update_document
     (   p_api_version
       , p_init_msg_list
       , p_commit
       , p_validation_level
       , x_return_status
       , x_msg_count
       , x_msg_data
       , p_entity_name
       , x_entity_id
       , p_document_type
       , l_ledger_id         -- LE Uptake
       , p_consolidate_option
     );

   IF x_return_status <> 'S' THEN
      RAISE wsh_update_document_error;
   END IF;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN wsh_create_trip_error THEN
      ROLLBACK TO sp1;
      x_return_status := wsh_util_core.g_ret_sts_error;
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_CREATE_TRIP_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_CREATE_TRIP_ERROR');
      END IF;
      --
   WHEN wsh_populate_trip_error  THEN
      ROLLBACK TO sp1;
      x_return_status := wsh_util_core.g_ret_sts_error;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_POPULATE_TRIP_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_POPULATE_TRIP_ERROR');
      END IF;
      --
   WHEN wsh_update_trip_error  THEN
      ROLLBACK TO sp1;
      x_return_status := wsh_util_core.g_ret_sts_error;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UPDATE_TRIP_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UPDATE_TRIP_ERROR');
      END IF;
      --
   WHEN wsh_assign_delivery_error THEN
      ROLLBACK TO sp1;
      x_return_status := wsh_util_core.g_ret_sts_error;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_ASSIGN_DELIVERY_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_ASSIGN_DELIVERY_ERROR');
      END IF;
      --
   WHEN wsh_populate_leg_error THEN
      ROLLBACK TO sp1;
      x_return_status := wsh_util_core.g_ret_sts_error;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_POPULATE_LEG_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_POPULATE_LEG_ERROR');
      END IF;
      --
   WHEN wsh_delete_leg_error THEN
      ROLLBACK TO sp1;
      x_return_status := wsh_util_core.g_ret_sts_error;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DELETE_LEG_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DELETE_LEG_ERROR');
      END IF;
      --
   WHEN wsh_update_leg_error THEN
      ROLLBACK TO sp1;
      x_return_status := wsh_util_core.g_ret_sts_error;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UPDATE_LEG_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UPDATE_LEG_ERROR');
      END IF;
      --
   WHEN wsh_create_document_error THEN
      ROLLBACK TO sp1;
      x_return_status := wsh_util_core.g_ret_sts_error;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_CREATE_DOCUMENT_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_CREATE_DOCUMENT_ERROR');
      END IF;
      --
   WHEN wsh_update_document_error THEN
      ROLLBACK TO sp1;
      x_return_status := wsh_util_core.g_ret_sts_error;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UPDATE_DOCUMENT_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UPDATE_DOCUMENT_ERROR');
      END IF;
      --
   WHEN OTHERS THEN
      ROLLBACK TO sp1;
      x_return_status := wsh_util_core.g_ret_sts_unexp_error;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Update_Row;


PROCEDURE insert_row
  (x_return_status             IN OUT NOCOPY  VARCHAR2,
   x_msg_count                 IN OUT NOCOPY  VARCHAR2,
   x_msg_data                  IN OUT NOCOPY  VARCHAR2,
   p_entity_name               IN     VARCHAR2,
   x_entity_id                 IN OUT NOCOPY  NUMBER,
   p_application_id            IN     NUMBER,
   p_location_id               IN     NUMBER,
   p_document_type             IN     VARCHAR2,
   p_document_sub_type         IN     VARCHAR2,
  -- p_ledger_id                 IN     NUMBER,       -- LE Uptake
   x_document_number           IN OUT NOCOPY  VARCHAR2,
   x_trip_id                   IN OUT NOCOPY  NUMBER,
   x_trip_name                 IN OUT NOCOPY  VARCHAR2,
   x_delivery_id               IN OUT NOCOPY  NUMBER,
   p_pick_up_location_id       IN     NUMBER,
   p_drop_off_location_id      IN     NUMBER,
   p_carrier_id                IN     NUMBER
  )
  IS
     x_rowid     varchar2(30);
     l_trip_info wsh_trips_pvt.trip_rec_type;
     l_del_rows  wsh_util_core.id_tab_type;
     l_leg_rows  wsh_util_core.id_tab_type;
     l_ledger_id NUMBER;    -- LE Uptake

     wsh_create_trip_error EXCEPTION;
     wsh_populate_trip_error EXCEPTION;
     wsh_update_trip_error EXCEPTION;
     wsh_assign_delivery_error EXCEPTION;
     wsh_create_document_error EXCEPTION;
     --
l_debug_on BOOLEAN;
     --
     l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_ROW';
     --
BEGIN
   --
   -- Debug Statements
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
       WSH_DEBUG_SV.log(l_module_name,'X_RETURN_STATUS',X_RETURN_STATUS);
       WSH_DEBUG_SV.log(l_module_name,'X_MSG_COUNT',X_MSG_COUNT);
       WSH_DEBUG_SV.log(l_module_name,'X_MSG_DATA',X_MSG_DATA);
       WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_NAME',P_ENTITY_NAME);
       WSH_DEBUG_SV.log(l_module_name,'X_ENTITY_ID',X_ENTITY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_APPLICATION_ID',P_APPLICATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_ID',P_LOCATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_TYPE',P_DOCUMENT_TYPE);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_SUB_TYPE',P_DOCUMENT_SUB_TYPE);
      --  WSH_DEBUG_SV.log(l_module_name,'P_LEDGER_ID',P_LEDGER_ID);   -- LE Uptake
       WSH_DEBUG_SV.log(l_module_name,'X_DOCUMENT_NUMBER',X_DOCUMENT_NUMBER);
       WSH_DEBUG_SV.log(l_module_name,'X_TRIP_ID',X_TRIP_ID);
       WSH_DEBUG_SV.log(l_module_name,'X_TRIP_NAME',X_TRIP_NAME);
       WSH_DEBUG_SV.log(l_module_name,'X_DELIVERY_ID',X_DELIVERY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_PICK_UP_LOCATION_ID',P_PICK_UP_LOCATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_DROP_OFF_LOCATION_ID',P_DROP_OFF_LOCATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_CARRIER_ID',P_CARRIER_ID);
   END IF;
   --
   SAVEPOINT sp1;

   -- l_set_of_books_id := 1;

   SELECT to_number(HOI.ORG_INFORMATION1) INTO l_ledger_id      -- LE Uptake
   FROM hr_organization_information hoi,
        wsh_new_deliveries wnd
   WHERE HOI.ORGANIZATION_ID = wnd.organization_id
   AND HOI.ORG_INFORMATION_CONTEXT = 'Accounting Information'
   AND wnd.delivery_id = x_delivery_id;

   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_ledger_id',l_ledger_id);       -- LE Uptake
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_Document_PVT.CREATE_DOCUMENT',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   WSH_Document_PVT.create_document
     ( 1.0,
       'T',
       NULL,
       NULL,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_entity_name,
       x_entity_id,
--       fnd_global.resp_appl_id,
       p_application_id,
       p_location_id,
       p_document_type,
       p_document_sub_type,
       l_ledger_id,             -- LE Uptake
       'BOTH',
       200,
       x_document_number
     );


   IF x_return_status <> 'S' THEN
      RAISE wsh_create_document_error;
   END IF;

   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'x_document_number',x_document_number);
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN wsh_create_trip_error THEN
      ROLLBACK TO sp1;
      x_return_status := wsh_util_core.g_ret_sts_error;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_CREATE_TRIP_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_CREATE_TRIP_ERROR');
      END IF;
      --
   WHEN wsh_populate_trip_error  THEN
      ROLLBACK TO sp1;
      x_return_status := wsh_util_core.g_ret_sts_error;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_POPULATE_TRIP_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_POPULATE_TRIP_ERROR');
      END IF;
      --
   WHEN wsh_update_trip_error  THEN
      ROLLBACK TO sp1;
      x_return_status := wsh_util_core.g_ret_sts_error;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UPDATE_TRIP_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UPDATE_TRIP_ERROR');
      END IF;
      --
   WHEN wsh_assign_delivery_error THEN
      ROLLBACK TO sp1;
      x_return_status := wsh_util_core.g_ret_sts_error;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_ASSIGN_DELIVERY_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_ASSIGN_DELIVERY_ERROR');
      END IF;
      --
   WHEN wsh_create_document_error THEN
      ROLLBACK TO sp1;
      x_return_status := wsh_util_core.g_ret_sts_error;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_CREATE_DOCUMENT_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_CREATE_DOCUMENT_ERROR');
      END IF;
      --
   WHEN OTHERS THEN
      ROLLBACK TO sp1;
      x_return_status := wsh_util_core.g_ret_sts_unexp_error;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Insert_Row;


PROCEDURE delete_row
  ( p_api_version                 IN  NUMBER
    , p_init_msg_list             IN  VARCHAR2
    , p_commit                    IN  VARCHAR2
    , p_validation_level          IN  NUMBER
    , x_return_status             OUT NOCOPY  VARCHAR2
    , x_msg_count                 OUT NOCOPY  NUMBER
    , x_msg_data                  OUT NOCOPY  VARCHAR2
    , p_entity_id                 IN  NUMBER
    , p_document_type             IN  VARCHAR2
    , p_document_number           IN  VARCHAR2
    )
  IS
     l_rowid VARCHAR2(30);

     wsh_cancel_document_error EXCEPTION;
     wsh_delete_leg_error EXCEPTION;
     --
l_debug_on BOOLEAN;
     --
     l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_ROW';
     --
BEGIN
   --
   -- Debug Statements
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
       WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION',P_API_VERSION);
       WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
       WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
       WSH_DEBUG_SV.log(l_module_name,'P_VALIDATION_LEVEL',P_VALIDATION_LEVEL);
       WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID',P_ENTITY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_TYPE',P_DOCUMENT_TYPE);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_NUMBER',P_DOCUMENT_NUMBER);
   END IF;
   --
   SAVEPOINT sp1;

   IF p_document_number <> NULL THEN
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_Document_PVT.CANCEL_DOCUMENT',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_Document_PVT.cancel_document
	(P_API_VERSION
	 , P_INIT_MSG_LIST
	 , P_COMMIT
	 , P_VALIDATION_LEVEL
	 , X_RETURN_STATUS
	 , X_MSG_COUNT
	 , X_MSG_DATA
	 , NULL
	 , p_ENTITY_ID
	 , P_DOCUMENT_TYPE
	 , 'BOTH'
	 );
      IF x_return_status <> 'S' THEN
	 RAISE wsh_cancel_document_error;
      END IF;
   END IF;

   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_PVT.DELETE_DELIVERY_LEG',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_delivery_legs_pvt.delete_delivery_leg
     (l_rowid,
      p_entity_id,
      x_return_status
      );

   IF x_return_status <> 'S' THEN
      RAISE wsh_delete_leg_error;
   END IF;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN wsh_delete_leg_error THEN
      ROLLBACK TO sp1;
      x_return_status := wsh_util_core.g_ret_sts_error;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DELETE_LEG_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DELETE_LEG_ERROR');
      END IF;
      --
   WHEN wsh_cancel_document_error THEN
      ROLLBACK TO sp1;
      x_return_status := wsh_util_core.g_ret_sts_error;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_CANCEL_DOCUMENT_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_CANCEL_DOCUMENT_ERROR');
      END IF;
      --
   WHEN OTHERS THEN
      ROLLBACK TO sp1;
      x_return_status := wsh_util_core.g_ret_sts_unexp_error;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END delete_row;


PROCEDURE cancel_bol
  ( p_trip_id			  IN NUMBER
    ,p_old_ship_method_code	  IN VARCHAR2
    ,p_new_ship_method_code	  IN VARCHAR2
    , x_return_status		  OUT NOCOPY  VARCHAR2
  )
IS
-- Two  cursors are defined to have better performance.
-- bol_num_cur_1 is used when the new_ship_method_code is not null.
-- bol_num_cur_2 is used when new_ship_method_code is null.  All the BOL Numbers associated to
-- trip must be cancelled.

cursor  bol_num_cur_1 (p_trip_id number) is
select  wdl.delivery_leg_id,
	wdi.sequence_number,
	wts1.stop_location_id,
	wdi.document_instance_id,
	wdl.delivery_id  ,                    --bugfix 3990683
	wt.name
from    wsh_delivery_legs  wdl,
        wsh_trip_stops     wts1,
        wsh_trips          wt,
        wsh_document_instances wdi,
        wsh_doc_sequence_categories wdsc
where   wdsc.doc_sequence_category_id = wdi.doc_sequence_category_id
AND     NVL(wdsc.document_code, '-99') <> '-99'
AND     wdi.entity_id = wdl.delivery_leg_id
AND     wdi.entity_name = 'WSH_DELIVERY_LEGS'
AND     wdi.document_type = 'BOL'
AND     wdi.status <> 'CANCELLED'
AND     wts1.trip_id = wt.trip_id
and     wts1.stop_id =wdl.PICK_UP_STOP_ID
and     wt.trip_id   = p_trip_id;

cursor  bol_num_cur_2 (p_trip_id number) is
select  wdl.delivery_leg_id,
	wdi.sequence_number,
	wts1.stop_location_id,
	wdi.document_instance_id,
        wdl.delivery_id  ,                    --bugfix 3990683
	wt.name
from    wsh_delivery_legs  wdl,
        wsh_trip_stops     wts1,
        wsh_trip_stops     wts2,
        wsh_trips          wt,
        wsh_document_instances wdi
where   wdi.entity_id = wdl.delivery_leg_id
AND     wdi.entity_name = 'WSH_DELIVERY_LEGS'
AND     wdi.document_type = 'BOL'
AND     wdi.status <> 'CANCELLED'
AND     wts1.trip_id = wt.trip_id
and     wts2.trip_id = wt.trip_id
and     wts1.stop_id =wdl.PICK_UP_STOP_ID
and     wts2.stop_id = wdl.DROP_OFF_STOP_ID
and     wt.trip_id   = p_trip_id;
--
--
l_return_status VARCHAR2(1);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);
l_okay          BOOLEAN;
TYPE Tab_bol_num_Type IS TABLE OF bol_num_cur_1%ROWTYPE INDEX BY BINARY_INTEGER;
l_bol_num_tab Tab_bol_num_Type;
--
--
i NUMBER;
l_tmp NUMBER;
--
--
-- Variables for logging exceptions
l_exception_error_message               VARCHAR2(2000) := NULL;
l_exception_msg_count                   NUMBER;
l_dummy_exception_id                    NUMBER;
l_exception_msg_data                    VARCHAR2(4000) := NULL;
l_msg                                   VARCHAR2(2000);
l_entity                                VARCHAR2(30);
--
--
wsh_cancel_bol_error EXCEPTION;

record_locked        EXCEPTION;
PRAGMA EXCEPTION_INIT(record_locked, -54);

--
--

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CANCEL_BOL';
--
BEGIN
  --
  -- Debug Statements
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
      WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_OLD_SHIP_METHOD_CODE',P_OLD_SHIP_METHOD_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_NEW_SHIP_METHOD_CODE',P_NEW_SHIP_METHOD_CODE);
  END IF;
  --
  SAVEPOINT cancel_bol1;

  FND_MESSAGE.SET_NAME('WSH','WSH_BOL_NUM_CANCELLED');
  FND_MESSAGE.SET_TOKEN('TRIP_ID',p_trip_id);
  l_msg := FND_MESSAGE.GET;

  IF p_old_ship_method_code is not null then

    IF p_new_ship_method_code is not null then

      OPEN bol_num_cur_1(p_trip_id);
      LOOP
         FETCH bol_num_cur_1 INTO l_bol_num_tab(l_bol_num_tab.COUNT + 1);
         EXIT WHEN bol_num_cur_1%NOTFOUND;
      END LOOP;
      close bol_num_cur_1;
    ELSE
      OPEN bol_num_cur_2(p_trip_id);
      LOOP
         FETCH bol_num_cur_2 INTO l_bol_num_tab(l_bol_num_tab.COUNT + 1);
         EXIT WHEN bol_num_cur_2%NOTFOUND;
      END LOOP;
      close bol_num_cur_2;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_bol_num_tab.COUNT',l_bol_num_tab.COUNT);
    END IF;

    IF l_bol_num_tab.COUNT <> 0 THEN

	-- Locking the document instances.

        FOR i IN l_bol_num_tab.FIRST..l_bol_num_tab.LAST
        LOOP
	   select  1 into l_tmp
	   from    wsh_document_instances
  	   where   document_instance_id = l_bol_num_tab(i).document_instance_id
	   FOR UPDATE NOWAIT;
	END LOOP;

        FOR i IN l_bol_num_tab.FIRST..l_bol_num_tab.LAST
        LOOP
       	   --
       	   -- Debug Statements
       	   --
       	   IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'delivery_leg_id',
                    l_bol_num_tab(i).delivery_leg_id);
               WSH_DEBUG_SV.log(l_module_name,'stop_location_id',
                     l_bol_num_tab(i).stop_location_id);
       	       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_Document_PVT.CANCEL_DOCUMENT',WSH_DEBUG_SV.C_PROC_LEVEL);
       	   END IF;
       	   --
       	   WSH_Document_PVT.cancel_document
      	           (p_api_version               => 1.0,
       	            p_init_msg_list             => fnd_api.g_false,
       	            p_commit                    => fnd_api.g_false,
       	            p_validation_level          => 100,
       	            x_return_status             => l_return_status,
    	            x_msg_count                 => l_msg_count,
    	            x_msg_data                  => l_msg_data,
    	            p_entity_name		=> NULL,
    		    p_entity_id                 => l_bol_num_tab(i).delivery_leg_id,
    		    p_document_type             => 'BOL',
    		    p_consolidate_option        => 'BOTH');
          IF (l_return_status not in (WSH_UTIL_CORE.G_RET_STS_SUCCESS, WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
              raise wsh_cancel_bol_error;
          END IF;

	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.LOG_EXCEPTION',WSH_DEBUG_SV.C_PROC_LEVEL);
	  END IF;
	  --
	  l_dummy_exception_id := null; --Bugfix 3990683
	  wsh_xc_util.log_exception(
            	    p_api_version	      => 1.0,
                    x_return_status           => l_return_status,
                    x_msg_count               => l_exception_msg_count,
                    x_msg_data                => l_exception_msg_data,
                    x_exception_id            => l_dummy_exception_id ,
		    p_exception_location_id   => l_bol_num_tab(i).stop_location_id,
		    p_logged_at_location_id   => l_bol_num_tab(i).stop_location_id,
                    p_logging_entity          => 'SHIPPER',
                    p_logging_entity_id       => FND_GLOBAL.USER_ID,
                    p_exception_name          => 'WSH_CHANGED_SHIP_METHOD',
                    p_message                 => l_msg,
		    p_trip_id		      => p_trip_id,
		    p_trip_name               => l_bol_num_tab(i).name,             --bugfix 3990683
                    p_error_message           => l_exception_error_message
                    );

	  IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
              --
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,  'WSH_XC_UTIL.LOG_EXCEPTION DID NOT RETURN SUCCESS'  );
              END IF;
              --
	      raise wsh_cancel_bol_error;
          END IF;
        END LOOP;
    END IF;
  END IF;

  IF l_return_status is not null then
    x_return_status := l_return_status;
    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
    END IF;
  ELSE
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  END IF;

  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
--
EXCEPTION
   WHEN wsh_cancel_bol_error THEN
        ROLLBACK TO cancel_bol1;
        x_return_status := wsh_util_core.g_ret_sts_error;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_CANCEL_BOL_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_CANCEL_BOL_ERROR');
        END IF;
        --
   WHEN record_locked THEN
        x_return_status := wsh_util_core.g_ret_sts_error;
        FND_MESSAGE.Set_Name('WSH', 'WSH_NO_LOCK');
        WSH_UTIL_CORE.add_message (x_return_status, l_module_name);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:RECORD_LOCKED');
        END IF;
        --
   WHEN OTHERS THEN
        ROLLBACK TO cancel_bol1;
        wsh_util_core.default_handler('WSH_BOLS_PVT.cancel_bol',l_module_name);
	IF bol_num_cur_1%ISOPEN THEN
          close bol_num_cur_1;
	END IF;
	IF bol_num_cur_2%ISOPEN THEN
          close bol_num_cur_2;
	END IF;
	x_return_status := wsh_util_core.g_ret_sts_unexp_error;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
END cancel_bol;

END WSH_BOLS_PVT;

/
