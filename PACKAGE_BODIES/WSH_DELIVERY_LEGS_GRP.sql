--------------------------------------------------------
--  DDL for Package Body WSH_DELIVERY_LEGS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DELIVERY_LEGS_GRP" as
/* $Header: WSHDGGPB.pls 120.9 2007/01/05 00:48:12 anxsharm noship $ */

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_DELIVERY_LEGS_GRP';
--

-- forward declaration
PROCEDURE Get_Disabled_List  (
  p_del_leg_rec          IN  WSH_DELIVERY_LEGS_PVT.Delivery_Leg_Rec_Type
, p_action               IN  VARCHAR2 DEFAULT 'UPDATE'
, x_del_leg_rec          OUT NOCOPY WSH_DELIVERY_LEGS_PVT.Delivery_Leg_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
);

PROCEDURE Delivery_Leg_Action(
        p_api_version_number            IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2,
        p_commit                        IN      VARCHAR2,
        p_rec_attr_tab                  IN      dlvy_leg_tab_type,
        p_action_prms                   IN      action_parameters_rectype,
        x_action_out_rec                IN OUT  NOCOPY action_out_rec_type,
        x_return_status                 OUT     NOCOPY VARCHAR2,
        x_msg_count                     OUT     NOCOPY NUMBER,
        x_msg_data                      OUT     NOCOPY VARCHAR2
) IS

l_api_version   	CONSTANT        NUMBER          := 1.0;
l_api_name      	CONSTANT        VARCHAR2(30)    := 'delivery_leg_action';
l_debug_on BOOLEAN;
l_module_name 		CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELIVERY_LEG_ACTION';

CURSOR get_trip_ship_method(p_trip_id NUMBER) IS
 SELECT ship_method_code
 FROM 	wsh_trips
 WHERE	trip_id=p_trip_id;

CURSOR  get_delivery_info( p_delivery_id IN NUMBER ) is
SELECT  name,
        organization_id,
        status_code,
        planned_flag,
        NVL(shipment_direction, 'O'),  -- J IB jckwok
        NVL(ignore_for_planning, 'N'),  -- OTM R12, glog proj
        NVL(tms_interface_flag,WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT) -- OTM R12, glog proj
FROM    wsh_new_deliveries
WHERE   delivery_id = p_delivery_id;

CURSOR get_parent_leg(p_delivery_leg_id in number) is
select parent.delivery_leg_id, parent.delivery_id
from wsh_Delivery_legs child, wsh_Delivery_legs parent
where child.delivery_leg_id = p_delivery_leg_id
and child.parent_delivery_leg_id = parent.delivery_leg_id;

CURSOR c_get_delivery_id (p_delivery_leg_id IN NUMBER) IS
SELECT delivery_leg_id, delivery_id from wsh_Delivery_legs
WHERE delivery_leg_id = p_delivery_leg_id;

CURSOR get_delivery_from_leg(p_leg_id in number) IS
SELECT delivery_id
FROM wsh_delivery_legs
WHERE delivery_leg_id = p_leg_id;

-- Cursor c_bol_doc_set added for bug 4493263
CURSOR c_bol_doc_set IS
SELECT WRS.Report_Set_Id
FROM   Wsh_Report_Sets Wrs,
       Wsh_Report_Set_Lines Wrsl
WHERE  Wrsl.Report_Set_Id = Wrs.Report_Set_Id
AND    Wrs.Name = 'Bill of Lading Report';

l_parent_delivery_leg_id NUMBER;
l_parent_delivery_id NUMBER;
l_tmp_parent_delivery_id NUMBER;

l_organization_id	NUMBER;
l_status_code		VARCHAR2(30);
l_planned_flag		VARCHAR2(30);
l_shipment_direction    VARCHAR2(30);
--
l_return_status		VARCHAR2(1);
l_msg_data        	VARCHAR2(32767);
l_msg_count       	NUMBER;

l_ship_method_code	VARCHAR2(30);
l_bol_number            NUMBER;

l_valid_ids             wsh_util_core.id_tab_type;
l_error_ids             wsh_util_core.id_tab_type;
l_valid_index_tab       wsh_util_core.id_tab_type;
l_dlvy_rec_tab          WSH_DELIVERY_VALIDATIONS.dlvy_rec_tab_type;
l_delivery_leg_id	NUMBER;
l_delivery_id	        NUMBER;

l_ignore                WSH_NEW_DELIVERIES.IGNORE_FOR_PLANNING%TYPE; -- OTM R12,glog proj
l_tms_interface_flag    WSH_NEW_DELIVERIES.TMS_INTERFACE_FLAG%TYPE; -- OTM R12,glog proj

-- Added for bug 4493263
l_dummy_doc_set_params  wsh_document_sets.document_set_tab_type;
l_dummy_id_tab          wsh_util_core.id_tab_type;
l_delivery_id_tab       wsh_util_core.id_tab_type;
l_doc_set_id            NUMBER;


RECORD_LOCKED          EXCEPTION;
PRAGMA EXCEPTION_INIT(RECORD_LOCKED, -54);

l_num_errors 		NUMBER := 0;
l_num_warnings 		NUMBER := 0;
l_loop_warnings 	NUMBER :=0;
l_index			NUMBER;

    -- PACK J: KVENKATE
    l_action_prms    action_parameters_rectype;
    l_action_out_rec action_out_rec_type;
    l_delivery_name VARCHAR2(30);
/*3301344*/
    wsh_create_document_error EXCEPTION;
    l_trip_name      VARCHAR2(30);
     -- PACK J: KVENKATE


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
    WSH_DEBUG_SV.log(l_module_name,'p_api_version_number',p_api_version_number);
    WSH_DEBUG_SV.log(l_module_name,'p_init_msg_list',p_init_msg_list);
    WSH_DEBUG_SV.log(l_module_name,'p_commit',p_commit);
    WSH_DEBUG_SV.log(l_module_name,'p_action_prms.caller',p_action_prms.caller);
    WSH_DEBUG_SV.log(l_module_name,'p_action_prms.action_code',p_action_prms.action_code);
    WSH_DEBUG_SV.log(l_module_name,'x_action_out_rec.x_delivery_id',x_action_out_rec.x_delivery_id);
    WSH_DEBUG_SV.log(l_module_name,'x_action_out_rec.x_trip_id',x_action_out_rec.x_trip_id);
    WSH_DEBUG_SV.log(l_module_name,'p_rec_attr_tab.count',p_rec_attr_tab.count);
 END IF;

 -- OTM R12, there was no initialization to 'S' for x_return_status
 -- Also, x_return_status was being used to add message earlier,
 -- changed that to wsh_util_core.g_ret_sts_error below
 x_return_status      := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
 l_ignore             := NULL;
 l_tms_interface_flag := NULL;

 IF NOT FND_API.compatible_api_call(l_api_version,p_api_version_number,l_api_name,G_PKG_NAME) THEN
    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Not comatible');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 IF FND_API.to_boolean(p_init_msg_list)  THEN
    FND_MSG_PUB.initialize;
 END IF;

  IF (p_action_prms.caller IS NULL) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_action_prms.caller');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
 END IF;
 IF (p_action_prms.action_code IS NULL ) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_action_prms.action_code');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
 END IF;

 IF (nvl(p_action_prms.phase,1) < 1) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_action_prms.phase');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
 END IF;

 IF (x_action_out_rec.x_delivery_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','x_action_out_rec.x_delivery_id');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
 END IF;

 IF (x_action_out_rec.x_trip_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','x_action_out_rec.x_trip_id');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
 END IF;

 IF ( p_rec_attr_tab.count < 0 ) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_rec_attr_tab.count');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
 END IF;

 WSH_ACTIONS_LEVELS.set_validation_level (
        p_entity                => 'DLEG',
        p_caller                => p_action_prms.caller,
        p_phase                 => p_action_prms.phase,
        p_action                => p_action_prms.action_code,
        x_return_status         => l_return_status);

 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'C_LOCK_RECORDS_LVL',
                                    WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_LOCK_RECORDS_LVL));
    WSH_DEBUG_SV.log(l_module_name,'C_TRIP_SMC_LVL',
                                    WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_TRIP_SMC_LVL));
 END IF;
 WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                             x_num_warnings     =>l_num_warnings,
                             x_num_errors       =>l_num_errors);

 l_index := p_rec_attr_tab.FIRST;
 WHILE l_index IS NOT NULL LOOP
 BEGIN
  /* Fix for bug 3337292
    Since print-bol has a recursive calls to same group API,
    Rollback done for generate-bol should not affect the rollback for print-bol.
    Need to have separate savepoints and separate rollbacks based on the action.
    Now, savepoints are defined under the IF condition for the action_code

    IMPORTANT NOTE: If any new action or savepoint is added, please change the respective
    code in the Exception block to handle the Rollbacks specific to the new action or new savepoint.
  */


  -- Bug 5532887
  l_delivery_leg_id:= NULL;
  l_delivery_id := NULL;
  l_parent_delivery_leg_id := NULL;
  l_parent_delivery_id := NULL;

  OPEN get_parent_leg(p_rec_attr_tab(l_index).delivery_leg_id);
  FETCH get_parent_leg INTO l_parent_delivery_leg_id, l_parent_delivery_id;
  IF get_parent_leg%FOUND THEN
    l_delivery_leg_id := l_parent_delivery_leg_id;
    l_delivery_id := l_parent_delivery_id;
  ELSE
    OPEN c_get_delivery_id (p_rec_attr_tab(l_index).delivery_leg_id);
    FETCH c_get_delivery_id
    INTO l_parent_delivery_leg_id, l_parent_delivery_id;
    CLOSE c_get_delivery_id;
    l_delivery_leg_id := l_parent_delivery_leg_id;
    l_delivery_id := l_parent_delivery_id;
  END IF;

  CLOSE get_parent_leg;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'p_rec_attr_tab(l_index).delivery_leg_id',p_rec_attr_tab(l_index).delivery_leg_id);
     WSH_DEBUG_SV.log(l_module_name,'l_parent_delivery_leg_id',l_parent_delivery_leg_id);
     WSH_DEBUG_SV.log(l_module_name,'l_delivery_leg_id',l_delivery_leg_id);
     WSH_DEBUG_SV.log(l_module_name,'l_parent_delivery_id',l_parent_delivery_id);
     WSH_DEBUG_SV.log(l_module_name,'l_delivery_id',l_delivery_id);
  END IF;


  IF (p_action_prms.action_code = 'GENERATE-BOL') THEN

    --Bug fix 3337292
    SAVEPOINT action_genbol_sp;

     IF (WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_LOCK_RECORDS_LVL) = 1) THEN

       WSH_DELIVERY_LEGS_PVT.Lock_Delivery_Leg(
            	p_rowid             	=> p_rec_attr_tab(l_index).rowid,
                p_delivery_leg_info     => p_rec_attr_tab(l_index));

       WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_loop_warnings,
                                   x_num_errors       =>l_num_errors);
     END IF;

       IF (WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_TRIP_SMC_LVL) = 1) THEN
          OPEN get_trip_ship_method(x_action_out_rec.x_trip_id);
          FETCH get_trip_ship_method INTO l_ship_method_code;
          CLOSE get_trip_ship_method;

/*3301344 : Get the trip name from trip id */
          l_trip_name := wsh_trips_pvt.get_name(x_action_out_rec.x_trip_id);

          IF (l_ship_method_code IS NULL ) THEN
            l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
/*3301344*/
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_ship_method_code',l_ship_method_code);
            END IF;

            FND_MESSAGE.SET_NAME('WSH','WSH_BOL_NULL_SHIP_METHOD_ERROR');
            FND_MESSAGE.SET_TOKEN('TRIP_NAME',l_trip_name);
            wsh_util_core.add_message(l_return_status,l_module_name);

            RAISE wsh_create_document_error;

          END IF;

/*3301344 : Commented out the following code*/

     /*     IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_ship_method_code',l_ship_method_code);
             WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
          END IF;
          WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_loop_warnings,
                                   x_num_errors       =>l_num_errors);
     */
       END IF;


       OPEN	get_delivery_info(x_action_out_rec.x_delivery_id);
       FETCH	get_delivery_info
       INTO l_delivery_name,
            l_organization_id,
            l_status_code,
            l_planned_flag,
            l_shipment_direction,
            l_ignore,             -- OTM R12, glog proj
            l_tms_interface_flag; -- OTM R12, glog proj
       CLOSE	get_delivery_info;

       --OTM R12, glog proj, add debug
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Delivery id',x_action_out_rec.x_delivery_id);
         WSH_DEBUG_SV.log(l_module_name,'Organization id',l_organization_id);
         WSH_DEBUG_SV.log(l_module_name,'Status_Code',l_status_code);
         WSH_DEBUG_SV.log(l_module_name,'Planned_Flag',l_planned_flag);
         WSH_DEBUG_SV.log(l_module_name,'Shipment Direction',l_shipment_direction);
         WSH_DEBUG_SV.log(l_module_name,'Ignore for Planning',l_ignore);
         WSH_DEBUG_SV.log(l_module_name,'Tms Interface Flag',l_tms_interface_flag);
       END IF;


       l_dlvy_rec_tab(1).delivery_id := x_action_out_rec.x_delivery_id;
       l_dlvy_rec_tab(1).organization_id := l_organization_id;
       l_dlvy_rec_tab(1).status_code := l_status_code;
       l_dlvy_rec_tab(1).planned_flag := l_planned_flag;
       l_dlvy_rec_tab(1).shipment_direction := l_shipment_direction;
       l_dlvy_rec_tab(1).ignore_for_planning := l_ignore;             -- OTM R12, glog proj
       l_dlvy_rec_tab(1).tms_interface_flag  := l_tms_interface_flag; -- OTM R12, glog proj

       WSH_DELIVERY_VALIDATIONS.Is_Action_Enabled(
                p_dlvy_rec_tab          => l_dlvy_rec_tab,
                p_action                => p_action_prms.action_code,
                p_caller                => p_action_prms.caller,
                x_return_status         => l_return_status,
                x_valid_ids             => l_valid_ids,
                x_error_ids             => l_error_ids,
                x_valid_index_tab       => l_valid_index_tab);

       IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'WSH_DELIVERY_VALIDATIONS.Is_Action_Enabled l_return_status',l_return_status);
       END IF;

       WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_loop_warnings,
                                   x_num_errors       =>l_num_errors);

       IF (WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_BOL_NUM_LVL) = 1) THEN
          SELECT count(*)
          INTO  l_bol_number
          FROM  WSH_DOCUMENT_INSTANCES wdi,
          	WSH_DELIVERY_LEGS wdl
          WHERE wdi.entity_id = wdl.delivery_leg_id
          AND   wdi.entity_name = 'WSH_DELIVERY_LEGS'
          AND   wdi.status <> 'CANCELLED'
          AND   wdl.delivery_leg_id = l_delivery_leg_id;--p_rec_attr_tab(l_index).delivery_leg_id;

          IF (l_bol_number > 0 ) THEN
            l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          END IF;

          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_bol_number',l_bol_number);
             WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
          END IF;
          WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_loop_warnings,
                                   x_num_errors       =>l_num_errors);
       END IF;


       WSH_BOLS_PVT.Insert_Row(
             x_return_status             => l_return_status,
             x_msg_count                 => l_msg_count,
             x_msg_data                  => l_msg_data,
             p_entity_name               => 'WSH_DELIVERY_LEGS',
             x_entity_id                 =>  l_delivery_leg_id,
             p_application_id            => 665 ,
             p_location_id               => p_action_prms.p_Pick_Up_Location_Id,
             p_document_type             => 'BOL',
             p_document_sub_type         => p_action_prms.p_Ship_Method,
             -- p_ledger_id              => 1,  --LE Uptake
             x_document_number           => x_action_out_rec.x_bol_number,
             x_trip_id                   => x_action_out_rec.x_trip_Id,
             x_trip_name                 => x_action_out_rec.x_trip_Name,
             x_delivery_id               => x_action_out_rec.x_delivery_Id,
             p_pick_up_location_Id       => p_action_prms.p_Pick_Up_Location_Id,
             p_drop_off_location_Id      => p_action_prms.p_Drop_Off_Location_Id,
             p_carrier_id                => p_action_prms.p_Carrier_Id);

       IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,' x_action_out_rec.x_bol_number: '|| x_action_out_rec.x_bol_number);
            WSH_DEBUG_SV.log(l_module_name,'WSH_BOLS_PVT.Insert_Row l_return_status',l_return_status);
       END IF;
       WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_loop_warnings,
                                   x_num_errors       =>l_num_errors);

    ELSIF (p_action_prms.action_code = 'PRINT-BOL') THEN

        --Bug fix 3337292
        SAVEPOINT action_prnbol_sp;

       OPEN get_parent_leg(p_rec_attr_tab(l_index).delivery_leg_id);
       FETCH get_parent_leg INTO l_parent_delivery_leg_id, l_tmp_parent_delivery_id;

       IF get_parent_leg%FOUND THEN
         l_delivery_leg_id := l_parent_delivery_leg_id;
       ELSE
	 l_delivery_leg_id := p_rec_attr_tab(l_index).delivery_leg_id;
       END IF;
       CLOSE get_parent_leg;

          SELECT count(*)
          INTO  l_bol_number
          FROM  WSH_DOCUMENT_INSTANCES wdi,
          	WSH_DELIVERY_LEGS wdl
          WHERE wdi.entity_id = wdl.delivery_leg_id
          AND   wdi.entity_name = 'WSH_DELIVERY_LEGS'
          AND   wdi.status <> 'CANCELLED'
          AND   wdl.delivery_leg_id = l_delivery_leg_id;

       IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name, 'BOL count for delivery', l_bol_number);
          wsh_debug_sv.log(l_module_name, 'delivery leg', l_delivery_leg_id);
       END IF;

       OPEN	get_delivery_info(x_action_out_rec.x_delivery_id);
       FETCH	get_delivery_info
       INTO l_delivery_name,
            l_organization_id,
            l_status_code,
            l_planned_flag,
            l_shipment_direction,
            l_ignore, -- OTM R12, glog proj
            l_tms_interface_flag; -- OTM R12, glog proj
       CLOSE	get_delivery_info;

       --OTM R12, glog proj, add debug
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Delivery id',x_action_out_rec.x_delivery_id);
         WSH_DEBUG_SV.log(l_module_name,'Organization id',l_organization_id);
         WSH_DEBUG_SV.log(l_module_name,'Status_Code',l_status_code);
         WSH_DEBUG_SV.log(l_module_name,'Planned_Flag',l_planned_flag);
         WSH_DEBUG_SV.log(l_module_name,'Shipment Direction',l_shipment_direction);
         WSH_DEBUG_SV.log(l_module_name,'Ignore for Planning',l_ignore);
         WSH_DEBUG_SV.log(l_module_name,'Tms Interface Flag',l_tms_interface_flag);
       END IF;

       l_dlvy_rec_tab(1).delivery_id := x_action_out_rec.x_delivery_id;
       l_dlvy_rec_tab(1).organization_id := l_organization_id;
       l_dlvy_rec_tab(1).status_code := l_status_code;
       l_dlvy_rec_tab(1).planned_flag := l_planned_flag;
       l_dlvy_rec_tab(1).shipment_direction := l_shipment_direction;
       l_dlvy_rec_tab(1).ignore_for_planning := l_ignore;             -- OTM R12, glog proj
       l_dlvy_rec_tab(1).tms_interface_flag  := l_tms_interface_flag; -- OTM R12, glog proj

      IF l_bol_number = 0
      THEN
      --{
         l_action_prms.caller := p_action_prms.caller;
         l_action_prms.action_code := 'GENERATE-BOL';
         l_action_prms.phase := p_action_prms.phase;
         l_action_prms.p_Pick_Up_Location_Id := p_action_prms.p_pick_Up_Location_Id;
         l_action_prms.p_Ship_Method := p_action_prms.p_Ship_Method;
         l_action_prms.p_Drop_Off_Location_Id := p_action_prms.p_Drop_Off_Location_Id;
         l_action_prms.p_Carrier_Id := p_action_prms.p_Carrier_Id;

         l_action_out_rec.x_trip_id := x_action_out_rec.x_trip_id;
         l_action_out_rec.x_trip_name := x_action_out_rec.x_trip_name;
         l_action_out_rec.x_delivery_id := x_action_out_rec.x_delivery_id;

         WSH_DELIVERY_LEGS_GRP.DELIVERY_LEG_ACTION(
            p_api_version_number => p_api_version_number,
            p_init_msg_list          => FND_API.G_FALSE,
            p_commit                 => FND_API.G_FALSE,
            p_rec_attr_tab           => p_rec_attr_tab,
            p_action_prms            => l_action_prms,
            x_action_out_rec         => l_action_out_rec,
            x_return_status          => l_return_status,
            x_msg_count              => l_msg_count,
            x_msg_data               => l_msg_data);

            x_action_out_rec := l_action_out_rec;

          WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_loop_warnings,
                                   x_num_errors       =>l_num_errors);

      -- }
      END IF; -- if l_bol_number = 0

      -- Start of bug-fix 4493263
      OPEN  c_bol_doc_set;
      FETCH c_bol_doc_set into l_doc_set_id;
      CLOSE c_bol_doc_set;

      IF ( l_doc_set_id IS NOT NULL )
      THEN
         l_delivery_id_tab(1) := l_delivery_id;
         IF l_debug_on THEN
             wsh_debug_sv.log(l_module_name, 'Calling Print_Document_Sets for delivery', l_delivery_id);
         END IF;

         WSH_DOCUMENT_SETS.Print_Document_Sets(
                      p_report_set_id       => l_doc_set_id,
                      p_organization_id     => l_organization_id,
                      p_trip_ids            => l_dummy_id_tab,
                      p_stop_ids            => l_dummy_id_tab,
                      p_delivery_ids        => l_delivery_id_tab,
                      p_document_param_info => l_dummy_doc_set_params,
                      x_return_status       => l_return_status);

         wsh_util_core.api_post_call(
                  p_return_status    => l_return_status,
                  x_num_warnings     => l_loop_warnings,
                  x_num_errors       => l_num_errors,
                  p_msg_data         => l_msg_data );
      END IF;
      -- End of bug-fix 4493263
    END IF; --'GENERATE-BOL'

    IF l_loop_warnings > 0 THEN
       l_num_warnings := l_num_warnings + 1;
    END IF;


    x_action_out_rec.valid_id_tab(x_action_out_rec.valid_id_tab.COUNT + 1) := l_delivery_leg_id;

  EXCEPTION
    /*3301344 : Added the following exception section*/

    WHEN wsh_create_document_error THEN
      -- OTM R12, glog proj, close all cursors
      IF get_trip_ship_method%ISOPEN THEN
        CLOSE get_trip_ship_method;
      END IF;
      IF get_delivery_info%ISOPEN THEN
        CLOSE get_delivery_info;
      END IF;
      IF get_parent_leg%ISOPEN THEN
        CLOSE get_parent_leg;
      END IF;
      IF get_delivery_from_leg%ISOPEN THEN
        CLOSE get_delivery_from_leg;
      END IF;
      IF c_bol_doc_set%ISOPEN THEN
        CLOSE c_bol_doc_set;
      END IF;

      --Bug fix 3337292
      IF p_action_prms.action_code = 'GENERATE-BOL' THEN
         ROLLBACK TO action_genbol_sp;
      ELSIF p_action_prms.action_code = 'PRINT-BOL' THEN
         ROLLBACK TO action_prnbol_sp;
      END IF;
     x_return_status := wsh_util_core.g_ret_sts_error;
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'DELIVERY_LEG_ACTION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
     END IF;
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;

     RETURN;

    WHEN fnd_api.g_exc_error THEN
      -- OTM R12, glog proj, close all cursors
      IF get_trip_ship_method%ISOPEN THEN
        CLOSE get_trip_ship_method;
      END IF;
      IF get_delivery_info%ISOPEN THEN
        CLOSE get_delivery_info;
      END IF;
      IF get_parent_leg%ISOPEN THEN
        CLOSE get_parent_leg;
      END IF;
      IF get_delivery_from_leg%ISOPEN THEN
        CLOSE get_delivery_from_leg;
      END IF;
      IF c_bol_doc_set%ISOPEN THEN
        CLOSE c_bol_doc_set;
      END IF;
      --Bug fix 3337292
      IF p_action_prms.action_code = 'GENERATE-BOL' THEN
        ROLLBACK TO action_genbol_sp;
      ELSIF p_action_prms.action_code = 'PRINT-BOL' THEN
        ROLLBACK TO action_prnbol_sp;
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      -- OTM R12, glog proj, close all cursors
      IF get_trip_ship_method%ISOPEN THEN
        CLOSE get_trip_ship_method;
      END IF;
      IF get_delivery_info%ISOPEN THEN
        CLOSE get_delivery_info;
      END IF;
      IF get_parent_leg%ISOPEN THEN
        CLOSE get_parent_leg;
      END IF;
      IF get_delivery_from_leg%ISOPEN THEN
        CLOSE get_delivery_from_leg;
      END IF;
      IF c_bol_doc_set%ISOPEN THEN
        CLOSE c_bol_doc_set;
      END IF;
      --Bug fix 3337292
      IF p_action_prms.action_code = 'GENERATE-BOL' THEN
        ROLLBACK TO action_genbol_sp;
      ELSIF p_action_prms.action_code = 'PRINT-BOL' THEN
        ROLLBACK TO action_prnbol_sp;
      END IF;

    WHEN others THEN
      -- OTM R12, glog proj, close all cursors
      IF get_trip_ship_method%ISOPEN THEN
        CLOSE get_trip_ship_method;
      END IF;
      IF get_delivery_info%ISOPEN THEN
        CLOSE get_delivery_info;
      END IF;
      IF get_parent_leg%ISOPEN THEN
        CLOSE get_parent_leg;
      END IF;
      IF get_delivery_from_leg%ISOPEN THEN
        CLOSE get_delivery_from_leg;
      END IF;
      IF c_bol_doc_set%ISOPEN THEN
        CLOSE c_bol_doc_set;
      END IF;
      --Bug fix 3337292
      IF p_action_prms.action_code = 'GENERATE-BOL' THEN
        ROLLBACK TO action_genbol_sp;
      ELSIF p_action_prms.action_code = 'PRINT-BOL' THEN
        ROLLBACK TO action_prnbol_sp;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


 END;
 l_index := p_rec_attr_tab.NEXT(l_index);
 END LOOP;

 IF (l_num_errors = p_rec_attr_tab.count ) THEN
    raise FND_API.G_EXC_ERROR;
 ELSIF (l_num_errors > 0 ) THEN
    raise WSH_UTIL_CORE.G_EXC_WARNING;
 ELSIF (l_num_warnings > 0 ) THEN
    raise WSH_UTIL_CORE.G_EXC_WARNING;
 ELSE
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
 END IF;


 IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
 END IF;

 FND_MSG_PUB.Count_And_Get
  (  p_count         =>      x_msg_count,
     p_data          =>      x_msg_data,
     p_encoded       =>      FND_API.G_FALSE
  );


 IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;

EXCEPTION
  WHEN RECORD_LOCKED THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     FND_MESSAGE.Set_Name('WSH', 'WSH_NO_LOCK');
     wsh_util_core.add_message(x_return_status,l_module_name);
     FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
     IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Message Count',x_msg_count);
      WSH_DEBUG_SV.log(l_module_name,'Message Data', x_msg_data);
      WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:RECORD_LOCKED');
     END IF;


  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
     IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Message Count',x_msg_count);
      WSH_DEBUG_SV.log(l_module_name,'Message Data', x_msg_data);
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
     IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Message Count',x_msg_count);
      WSH_DEBUG_SV.log(l_module_name,'Message Data', x_msg_data);
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
     END IF;


  WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
     FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
     IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Message Count',x_msg_count);
      WSH_DEBUG_SV.log(l_module_name,'Message Data', x_msg_data);
      WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
     END IF;


  WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
     wsh_util_core.default_handler ('WSH_DELIVERY_LEGS_GRP.DELIVERY_LEG_ACTION');
     FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Message Count',x_msg_count);
        WSH_DEBUG_SV.log(l_module_name,'Message Data', x_msg_data);
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);

     END IF;


END Delivery_Leg_Action;
--========================================================================
-- PROCEDURE : Update_Delivery_Leg  Wrapper API      PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_in_rec                Record for caller, phase
--                                     and action_code ('UPDATE' )
--             p_delivery_leg_tab      Table of Attributes for the delivery leg entity
--             x_out_rec               for future usage.
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Updates a record in wsh_delivery_legs table with information
--             specified in p_delivery_leg_tab. Please note that as per perfomance
--             standards, if you need to update a field to null, then use the
--             fnd_api.g_miss_(num/char/date) value for that field. If a field
--             has a null value, it will not be updated.

PROCEDURE Update_Delivery_Leg(
p_api_version_number     IN     NUMBER,
p_init_msg_list          IN     VARCHAR2,
p_commit                 IN     VARCHAR2,
p_delivery_leg_tab       IN     WSH_DELIVERY_LEGS_GRP.dlvy_leg_tab_type,
p_in_rec                 IN     WSH_DELIVERY_LEGS_GRP.action_parameters_rectype,
x_out_rec                OUT    NOCOPY WSH_DELIVERY_LEGS_GRP.action_out_rec_type,
x_return_status          OUT    NOCOPY VARCHAR2,
x_msg_count              OUT    NOCOPY NUMBER,
x_msg_data               OUT    NOCOPY VARCHAR2) IS

l_api_version_number    CONSTANT NUMBER := 1.0;
l_api_name              CONSTANT VARCHAR2(30) := 'Update_Delivery_Leg';
l_debug_on BOOLEAN;
l_module_name           CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_DELIVERY_LEGS';
l_delivery_leg_rec      WSH_DELIVERY_LEGS_PVT.Delivery_Leg_Rec_Type;

l_return_status VARCHAR2(1);
l_num_warnings NUMBER;
l_num_errors NUMBER;

cursor c_is_final_leg (p_dleg_id in number) is
select d.delivery_id from
wsh_new_deliveries d, wsh_delivery_legs l, wsh_trip_stops s
where l.delivery_id = d.delivery_id
and d.ultimate_dropoff_location_id = s.stop_location_id
and l.drop_off_stop_id =  s.stop_id
and l.delivery_leg_id = p_dleg_id;

l_delivery_id number;

RECORD_LOCKED          EXCEPTION;
PRAGMA EXCEPTION_INIT(RECORD_LOCKED, -54);



Begin

 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 --
 IF l_debug_on IS NULL
 THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;
 IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
 END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF (p_in_rec.action_code= 'UPDATE') THEN

    FOR l_index in p_delivery_leg_tab.FIRST .. p_delivery_leg_tab.LAST LOOP

       IF p_in_rec.caller like 'FTE%' THEN

          IF p_delivery_leg_tab(l_index).POD_DATE is NOT NULL
          AND p_delivery_leg_tab(l_index).POD_DATE <> FND_API.G_MISS_DATE THEN


          -- See if the delivery leg is the last on the delivery.

             OPEN c_is_final_leg(p_delivery_leg_tab(l_index).delivery_leg_id);
             FETCH c_is_final_leg INTO l_delivery_id;
             CLOSE c_is_final_leg;

             -- If it is the final leg, sync the POD date with delivery.

             IF l_delivery_id IS NOT NULL THEN

                -- Lock the delivery before update

                wsh_new_deliveries_pvt.lock_dlvy_no_compare(
                                         p_delivery_id => l_delivery_id);


                UPDATE wsh_new_deliveries
                SET DELIVERED_DATE = p_delivery_leg_tab(l_index).POD_DATE
                WHERE delivery_id = l_delivery_id;

             END IF;

          END IF;

       END IF;


       IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Get_Disabled_List',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       Get_Disabled_List(p_del_leg_rec => p_delivery_leg_tab(l_index),
                         p_action => 'UPDATE',
                         x_del_leg_rec => l_delivery_leg_rec,
                         x_return_status => x_return_status);


       IF x_return_status in  (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;

          RETURN;

       END IF;

       IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_PVT.Update_Delivery_Leg',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       WSH_DELIVERY_LEGS_PVT.Update_Delivery_Leg(
                p_rowid                 => NULL,
                p_delivery_leg_info     => l_delivery_leg_rec,
                x_return_status         => l_return_status);

       IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Update_Delivery_Leg x_return_status',l_return_status);
       END IF;
       WSH_UTIL_CORE.api_post_call(
                                   p_return_status    => l_return_status,
                                   x_num_warnings     => l_num_warnings,
                                   x_num_errors       => l_num_errors,
                                   p_module_name      => l_module_name,
                                   p_msg_data         =>  'WSH_PUB_UPDATE_FAILURE',
                                   p_token1           => 'ENTITY',
                                   p_value1           => 'Delivery_Leg');

    END LOOP;

  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;


EXCEPTION

        WHEN app_exception.application_exception or app_exception.record_lock_exception THEN
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              FND_MESSAGE.Set_Name('WSH', 'WSH_NO_LOCK');
              wsh_util_core.add_message(x_return_status,l_module_name);
              IF l_debug_on THEN
                 wsh_debug_sv.log(l_module_name, 'Could not lock delivery', l_delivery_id);
                 WSH_DEBUG_SV.logmsg(l_module_name,'APP_EXCEPTION.APPLICATION_EXCEPTION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                 WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:APP_EXCEPTION.APPLICATION_EXCEPTION');
              END IF;
              --

        WHEN others THEN

              IF c_is_final_leg%isopen THEN
                 close c_is_final_leg;
              END IF;
              wsh_util_core.default_handler('WSH_DELIVERY_LEGS_GRP.Update_Delivery_Leg',l_module_name);
              x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
              --
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                 WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
              END IF;

END Update_Delivery_Leg;


PROCEDURE Get_Disabled_List  (
  p_del_leg_rec          IN  WSH_DELIVERY_LEGS_PVT.Delivery_Leg_Rec_Type
, p_action               IN  VARCHAR2 DEFAULT 'UPDATE'
, x_del_leg_rec          OUT NOCOPY WSH_DELIVERY_LEGS_PVT.Delivery_Leg_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
) IS

cursor c_get_leg_record(p_dleg_id in number) IS
select
        DELIVERY_LEG_ID,
        DELIVERY_ID ,
        SEQUENCE_NUMBER         ,
        LOADING_ORDER_FLAG      ,
        PICK_UP_STOP_ID         ,
        DROP_OFF_STOP_ID        ,
        GROSS_WEIGHT            ,
        NET_WEIGHT              ,
        WEIGHT_UOM_CODE         ,
        VOLUME                  ,
        VOLUME_UOM_CODE         ,
        CREATION_DATE           ,
        CREATED_BY              ,
        LAST_UPDATE_DATE        ,
        LAST_UPDATED_BY         ,
        LAST_UPDATE_LOGIN       ,
        PROGRAM_APPLICATION_ID  ,
        PROGRAM_ID              ,
        PROGRAM_UPDATE_DATE     ,
        REQUEST_ID              ,
        LOAD_TENDER_STATUS      ,
        SHIPPER_TITLE           ,
        SHIPPER_PHONE           ,
        POD_FLAG                ,
        POD_BY                  ,
        POD_DATE                ,
        EXPECTED_POD_DATE       ,
        BOOKING_OFFICE          ,
        SHIPPER_EXPORT_REF      ,
        CARRIER_EXPORT_REF      ,
        DOC_NOTIFY_PARTY        ,
        AETC_NUMBER             ,
        SHIPPER_SIGNED_BY       ,
        SHIPPER_DATE            ,
        CARRIER_SIGNED_BY       ,
        CARRIER_DATE            ,
        DOC_ISSUE_OFFICE        ,
        DOC_ISSUED_BY           ,
        DOC_DATE_ISSUED         ,
        SHIPPER_HM_BY           ,
        SHIPPER_HM_DATE         ,
        CARRIER_HM_BY           ,
        CARRIER_HM_DATE         ,
        BOOKING_NUMBER          ,
        PORT_OF_LOADING         ,
        PORT_OF_DISCHARGE       ,
        SERVICE_CONTRACT        ,
        BILL_FREIGHT_TO         ,
        FTE_TRIP_ID                     ,
        REPRICE_REQUIRED                ,
        ACTUAL_ARRIVAL_DATE             ,
        ACTUAL_DEPARTURE_DATE           ,
        ACTUAL_RECEIPT_DATE             ,
        TRACKING_DRILLDOWN_FLAG      ,
        STATUS_CODE                     ,
        TRACKING_REMARKS                ,
        CARRIER_EST_DEPARTURE_DATE      ,
        CARRIER_EST_ARRIVAL_DATE        ,
        LOADING_START_DATETIME          ,
        LOADING_END_DATETIME            ,
        UNLOADING_START_DATETIME        ,
        UNLOADING_END_DATETIME          ,
        DELIVERED_QUANTITY              ,
        LOADED_QUANTITY                 ,
        RECEIVED_QUANTITY               ,
        ORIGIN_STOP_ID                  ,
        DESTINATION_STOP_ID             ,
        ROWID                           ,
        PARENT_DELIVERY_LEG_ID
        FROM wsh_delivery_legs where
        delivery_leg_id = p_dleg_id;

l_api_version_number    CONSTANT NUMBER := 1.0;
l_api_name              CONSTANT VARCHAR2(30) := 'Get_Disabled_List';
l_debug_on BOOLEAN;
l_module_name           CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Disabled_List';
l_dleg_rec WSH_DELIVERY_LEGS_PVT.Delivery_Leg_Rec_Type;

Begin

 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 --
 IF l_debug_on IS NULL
 THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;
 IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
 END IF;

         x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        OPEN c_get_leg_record(p_del_leg_rec.delivery_leg_id);
        FETCH c_get_leg_record INTO l_dleg_rec;
        IF c_get_leg_record%NOTFOUND THEN
           CLOSE c_get_leg_record;
           RAISE NO_DATA_FOUND;
        end if;
        CLOSE c_get_leg_record;


        IF p_del_leg_rec.DELIVERY_ID = FND_API.G_MISS_NUM THEN
           l_dleg_rec.DELIVERY_ID := NULL;
        ELSIF p_del_leg_rec.DELIVERY_ID IS NOT NULL THEN
           l_dleg_rec.DELIVERY_ID := p_del_leg_rec.DELIVERY_ID;
        END IF;
        IF p_del_leg_rec.SEQUENCE_NUMBER = FND_API.G_MISS_NUM THEN
           l_dleg_rec.SEQUENCE_NUMBER := NULL;
        ELSIF p_del_leg_rec.SEQUENCE_NUMBER IS NOT NULL THEN
           l_dleg_rec.SEQUENCE_NUMBER := p_del_leg_rec.SEQUENCE_NUMBER;
        END IF;
        IF p_del_leg_rec.LOADING_ORDER_FLAG = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.LOADING_ORDER_FLAG := NULL;
        ELSIF p_del_leg_rec.LOADING_ORDER_FLAG IS NOT NULL THEN
           l_dleg_rec.LOADING_ORDER_FLAG := p_del_leg_rec.LOADING_ORDER_FLAG;
        END IF;
        IF p_del_leg_rec.PICK_UP_STOP_ID = FND_API.G_MISS_NUM THEN
           l_dleg_rec.PICK_UP_STOP_ID := NULL;
        ELSIF p_del_leg_rec.PICK_UP_STOP_ID IS NOT NULL THEN
           l_dleg_rec.PICK_UP_STOP_ID := p_del_leg_rec.PICK_UP_STOP_ID;
        END IF;
        IF p_del_leg_rec.DROP_OFF_STOP_ID = FND_API.G_MISS_NUM THEN
           l_dleg_rec.DROP_OFF_STOP_ID := NULL;
        ELSIF p_del_leg_rec.DROP_OFF_STOP_ID IS NOT NULL THEN
           l_dleg_rec.DROP_OFF_STOP_ID := p_del_leg_rec.DROP_OFF_STOP_ID;
        END IF;
        IF p_del_leg_rec.GROSS_WEIGHT = FND_API.G_MISS_NUM THEN
           l_dleg_rec.GROSS_WEIGHT := NULL;
        ELSIF p_del_leg_rec.GROSS_WEIGHT IS NOT NULL THEN
           l_dleg_rec.GROSS_WEIGHT := p_del_leg_rec.GROSS_WEIGHT;
        END IF;
        IF p_del_leg_rec.NET_WEIGHT = FND_API.G_MISS_NUM THEN
           l_dleg_rec.NET_WEIGHT := NULL;
        ELSIF p_del_leg_rec.NET_WEIGHT IS NOT NULL THEN
           l_dleg_rec.NET_WEIGHT := p_del_leg_rec.NET_WEIGHT;
        END IF;
        IF p_del_leg_rec.WEIGHT_UOM_CODE = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.WEIGHT_UOM_CODE := NULL;
        ELSIF p_del_leg_rec.WEIGHT_UOM_CODE IS NOT NULL THEN
           l_dleg_rec.WEIGHT_UOM_CODE := p_del_leg_rec.WEIGHT_UOM_CODE;
        END IF;
        IF p_del_leg_rec.VOLUME = FND_API.G_MISS_NUM THEN
           l_dleg_rec.VOLUME := NULL;
        ELSIF p_del_leg_rec.VOLUME IS NOT NULL THEN
           l_dleg_rec.VOLUME := p_del_leg_rec.VOLUME;
        END IF;
        IF p_del_leg_rec.VOLUME_UOM_CODE = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.VOLUME_UOM_CODE := NULL;
        ELSIF p_del_leg_rec.VOLUME_UOM_CODE IS NOT NULL THEN
           l_dleg_rec.VOLUME_UOM_CODE := p_del_leg_rec.VOLUME_UOM_CODE;
        END IF;
        IF p_del_leg_rec.VOLUME_UOM_CODE = FND_API.G_MISS_NUM THEN
           l_dleg_rec.VOLUME_UOM_CODE := NULL;
        ELSIF p_del_leg_rec.VOLUME_UOM_CODE IS NOT NULL THEN
           l_dleg_rec.VOLUME_UOM_CODE := p_del_leg_rec.VOLUME_UOM_CODE;
        END IF;
        IF p_del_leg_rec.LAST_UPDATE_DATE = FND_API.G_MISS_DATE THEN
           l_dleg_rec.LAST_UPDATE_DATE := NULL;
        ELSIF p_del_leg_rec.LAST_UPDATE_DATE IS NOT NULL THEN
           l_dleg_rec.LAST_UPDATE_DATE := p_del_leg_rec.LAST_UPDATE_DATE;
        END IF;
        IF p_del_leg_rec.LAST_UPDATED_BY = FND_API.G_MISS_NUM THEN
           l_dleg_rec.LAST_UPDATED_BY := NULL;
        ELSIF p_del_leg_rec.LAST_UPDATED_BY IS NOT NULL THEN
           l_dleg_rec.LAST_UPDATED_BY := p_del_leg_rec.LAST_UPDATED_BY;
        END IF;
        IF p_del_leg_rec.LAST_UPDATE_LOGIN = FND_API.G_MISS_NUM THEN
           l_dleg_rec.LAST_UPDATE_LOGIN := NULL;
        ELSIF p_del_leg_rec.LAST_UPDATE_LOGIN IS NOT NULL THEN
           l_dleg_rec.LAST_UPDATE_LOGIN := p_del_leg_rec.LAST_UPDATE_LOGIN;
        END IF;
        IF p_del_leg_rec.PROGRAM_APPLICATION_ID = FND_API.G_MISS_NUM THEN
           l_dleg_rec.PROGRAM_APPLICATION_ID := NULL;
        ELSIF p_del_leg_rec.PROGRAM_APPLICATION_ID IS NOT NULL THEN
           l_dleg_rec.PROGRAM_APPLICATION_ID := p_del_leg_rec.PROGRAM_APPLICATION_ID;
        END IF;
        IF p_del_leg_rec.PROGRAM_ID = FND_API.G_MISS_NUM THEN
           l_dleg_rec.PROGRAM_ID := NULL;
        ELSIF p_del_leg_rec.PROGRAM_ID IS NOT NULL THEN
           l_dleg_rec.PROGRAM_ID := p_del_leg_rec.PROGRAM_ID;
        END IF;
        IF p_del_leg_rec.PROGRAM_UPDATE_DATE = FND_API.G_MISS_DATE THEN
           l_dleg_rec.PROGRAM_UPDATE_DATE := NULL;
        ELSIF p_del_leg_rec.PROGRAM_UPDATE_DATE IS NOT NULL THEN
           l_dleg_rec.PROGRAM_UPDATE_DATE := p_del_leg_rec.PROGRAM_UPDATE_DATE;
        END IF;
        IF p_del_leg_rec.REQUEST_ID = FND_API.G_MISS_NUM THEN
           l_dleg_rec.REQUEST_ID := NULL;
        ELSIF p_del_leg_rec.REQUEST_ID IS NOT NULL THEN
           l_dleg_rec.REQUEST_ID := p_del_leg_rec.REQUEST_ID;
        END IF;
        IF p_del_leg_rec.LOAD_TENDER_STATUS = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.LOAD_TENDER_STATUS := NULL;
        ELSIF p_del_leg_rec.LOAD_TENDER_STATUS IS NOT NULL THEN
           l_dleg_rec.LOAD_TENDER_STATUS := p_del_leg_rec.LOAD_TENDER_STATUS;
        END IF;
        IF p_del_leg_rec.SHIPPER_TITLE = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.SHIPPER_TITLE := NULL;
        ELSIF p_del_leg_rec.SHIPPER_TITLE IS NOT NULL THEN
           l_dleg_rec.SHIPPER_TITLE := p_del_leg_rec.SHIPPER_TITLE;
        END IF;
        IF p_del_leg_rec.SHIPPER_PHONE = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.SHIPPER_PHONE := NULL;
        ELSIF p_del_leg_rec.SHIPPER_PHONE IS NOT NULL THEN
           l_dleg_rec.SHIPPER_PHONE := p_del_leg_rec.SHIPPER_PHONE;
        END IF;
        IF p_del_leg_rec.POD_FLAG = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.POD_FLAG := NULL;
        ELSIF p_del_leg_rec.POD_FLAG IS NOT NULL THEN
           l_dleg_rec.POD_FLAG := p_del_leg_rec.POD_FLAG;
        END IF;
        IF p_del_leg_rec.POD_BY = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.POD_BY := NULL;
        ELSIF p_del_leg_rec.POD_BY IS NOT NULL THEN
           l_dleg_rec.POD_BY := p_del_leg_rec.POD_BY;
        END IF;
        IF p_del_leg_rec.POD_DATE = FND_API.G_MISS_DATE THEN
           l_dleg_rec.POD_DATE := NULL;
        ELSIF p_del_leg_rec.POD_DATE IS NOT NULL THEN
           l_dleg_rec.POD_DATE := p_del_leg_rec.POD_DATE;
        END IF;
        IF p_del_leg_rec.EXPECTED_POD_DATE = FND_API.G_MISS_DATE THEN
           l_dleg_rec.EXPECTED_POD_DATE := NULL;
        ELSIF p_del_leg_rec.EXPECTED_POD_DATE IS NOT NULL THEN
           l_dleg_rec.EXPECTED_POD_DATE := p_del_leg_rec.EXPECTED_POD_DATE;
        END IF;
        IF p_del_leg_rec.BOOKING_OFFICE = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.BOOKING_OFFICE := NULL;
        ELSIF p_del_leg_rec.BOOKING_OFFICE IS NOT NULL THEN
           l_dleg_rec.BOOKING_OFFICE := p_del_leg_rec.BOOKING_OFFICE;
        END IF;
        IF p_del_leg_rec.SHIPPER_EXPORT_REF = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.SHIPPER_EXPORT_REF := NULL;
        ELSIF p_del_leg_rec.SHIPPER_EXPORT_REF IS NOT NULL THEN
           l_dleg_rec.SHIPPER_EXPORT_REF := p_del_leg_rec.SHIPPER_EXPORT_REF;
        END IF;
        IF p_del_leg_rec.CARRIER_EXPORT_REF = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.CARRIER_EXPORT_REF := NULL;
        ELSIF p_del_leg_rec.CARRIER_EXPORT_REF IS NOT NULL THEN
           l_dleg_rec.CARRIER_EXPORT_REF := p_del_leg_rec.CARRIER_EXPORT_REF;
        END IF;
        IF p_del_leg_rec.DOC_NOTIFY_PARTY = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.DOC_NOTIFY_PARTY := NULL;
        ELSIF p_del_leg_rec.DOC_NOTIFY_PARTY IS NOT NULL THEN
           l_dleg_rec.DOC_NOTIFY_PARTY := p_del_leg_rec.DOC_NOTIFY_PARTY;
        END IF;
        IF p_del_leg_rec.AETC_NUMBER = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.AETC_NUMBER := NULL;
        ELSIF p_del_leg_rec.AETC_NUMBER IS NOT NULL THEN
           l_dleg_rec.AETC_NUMBER := p_del_leg_rec.AETC_NUMBER;
        END IF;
        IF p_del_leg_rec.SHIPPER_SIGNED_BY = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.SHIPPER_SIGNED_BY := NULL;
        ELSIF p_del_leg_rec.SHIPPER_SIGNED_BY IS NOT NULL THEN
           l_dleg_rec.SHIPPER_SIGNED_BY := p_del_leg_rec.SHIPPER_SIGNED_BY;
        END IF;
        IF p_del_leg_rec.SHIPPER_DATE = FND_API.G_MISS_DATE THEN
           l_dleg_rec.SHIPPER_DATE := NULL;
        ELSIF p_del_leg_rec.SHIPPER_DATE IS NOT NULL THEN
           l_dleg_rec.SHIPPER_DATE := p_del_leg_rec.SHIPPER_DATE;
        END IF;
        IF p_del_leg_rec.CARRIER_SIGNED_BY = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.CARRIER_SIGNED_BY := NULL;
        ELSIF p_del_leg_rec.CARRIER_SIGNED_BY IS NOT NULL THEN
           l_dleg_rec.CARRIER_SIGNED_BY := p_del_leg_rec.CARRIER_SIGNED_BY;
        END IF;
        IF p_del_leg_rec.CARRIER_DATE = FND_API.G_MISS_DATE THEN
           l_dleg_rec.CARRIER_DATE := NULL;
        ELSIF p_del_leg_rec.CARRIER_DATE IS NOT NULL THEN
           l_dleg_rec.CARRIER_DATE := p_del_leg_rec.CARRIER_DATE;
        END IF;
        IF p_del_leg_rec.DOC_ISSUE_OFFICE = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.DOC_ISSUE_OFFICE := NULL;
        ELSIF p_del_leg_rec.DOC_ISSUE_OFFICE IS NOT NULL THEN
           l_dleg_rec.DOC_ISSUE_OFFICE := p_del_leg_rec.DOC_ISSUE_OFFICE;
        END IF;
        IF p_del_leg_rec.DOC_ISSUED_BY = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.DOC_ISSUED_BY := NULL;
        ELSIF p_del_leg_rec.DOC_ISSUED_BY IS NOT NULL THEN
           l_dleg_rec.DOC_ISSUED_BY := p_del_leg_rec.DOC_ISSUED_BY;
        END IF;
        IF p_del_leg_rec.DOC_DATE_ISSUED = FND_API.G_MISS_DATE THEN
           l_dleg_rec.DOC_DATE_ISSUED := NULL;
        ELSIF p_del_leg_rec.DOC_DATE_ISSUED IS NOT NULL THEN
           l_dleg_rec.DOC_DATE_ISSUED := p_del_leg_rec.DOC_ISSUED_BY;
        END IF;
        IF p_del_leg_rec.SHIPPER_HM_BY = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.SHIPPER_HM_BY := NULL;
        ELSIF p_del_leg_rec.SHIPPER_HM_BY IS NOT NULL THEN
           l_dleg_rec.SHIPPER_HM_BY := p_del_leg_rec.SHIPPER_HM_BY;
        END IF;
        IF p_del_leg_rec.SHIPPER_HM_DATE = FND_API.G_MISS_DATE THEN
           l_dleg_rec.SHIPPER_HM_DATE := NULL;
        ELSIF p_del_leg_rec.SHIPPER_HM_DATE IS NOT NULL THEN
           l_dleg_rec.SHIPPER_HM_DATE := p_del_leg_rec.SHIPPER_HM_DATE;
        END IF;
        IF p_del_leg_rec.CARRIER_HM_BY = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.CARRIER_HM_BY := NULL;
        ELSIF p_del_leg_rec.CARRIER_HM_BY IS NOT NULL THEN
           l_dleg_rec.CARRIER_HM_BY := p_del_leg_rec.CARRIER_HM_BY;
        END IF;
        IF p_del_leg_rec.CARRIER_HM_DATE = FND_API.G_MISS_DATE THEN
           l_dleg_rec.CARRIER_HM_DATE := NULL;
        ELSIF p_del_leg_rec.CARRIER_HM_DATE IS NOT NULL THEN
           l_dleg_rec.CARRIER_HM_DATE := p_del_leg_rec.CARRIER_HM_DATE;
        END IF;
        IF p_del_leg_rec.BOOKING_NUMBER = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.BOOKING_NUMBER := NULL;
        ELSIF p_del_leg_rec.BOOKING_NUMBER IS NOT NULL THEN
           l_dleg_rec.BOOKING_NUMBER := p_del_leg_rec.BOOKING_NUMBER;
        END IF;
        IF p_del_leg_rec.PORT_OF_LOADING = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.PORT_OF_LOADING := NULL;
        ELSIF p_del_leg_rec.PORT_OF_LOADING IS NOT NULL THEN
           l_dleg_rec.PORT_OF_LOADING := p_del_leg_rec.PORT_OF_LOADING;
        END IF;
        IF p_del_leg_rec.PORT_OF_DISCHARGE = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.PORT_OF_DISCHARGE := NULL;
        ELSIF p_del_leg_rec.PORT_OF_DISCHARGE IS NOT NULL THEN
           l_dleg_rec.PORT_OF_DISCHARGE := p_del_leg_rec.PORT_OF_DISCHARGE;
        END IF;
        IF p_del_leg_rec.SERVICE_CONTRACT = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.SERVICE_CONTRACT := NULL;
        ELSIF p_del_leg_rec.SERVICE_CONTRACT IS NOT NULL THEN
           l_dleg_rec.SERVICE_CONTRACT := p_del_leg_rec.SERVICE_CONTRACT;
        END IF;
        IF p_del_leg_rec.BILL_FREIGHT_TO = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.BILL_FREIGHT_TO := NULL;
        ELSIF p_del_leg_rec.BILL_FREIGHT_TO IS NOT NULL THEN
           l_dleg_rec.BILL_FREIGHT_TO := p_del_leg_rec.BILL_FREIGHT_TO;
        END IF;
        IF p_del_leg_rec.FTE_TRIP_ID = FND_API.G_MISS_NUM THEN
           l_dleg_rec.FTE_TRIP_ID := NULL;
        ELSIF p_del_leg_rec.FTE_TRIP_ID IS NOT NULL THEN
           l_dleg_rec.FTE_TRIP_ID := p_del_leg_rec.FTE_TRIP_ID;
        END IF;
        IF p_del_leg_rec.REPRICE_REQUIRED = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.REPRICE_REQUIRED := NULL;
        ELSIF p_del_leg_rec.REPRICE_REQUIRED IS NOT NULL THEN
           l_dleg_rec.REPRICE_REQUIRED := p_del_leg_rec.REPRICE_REQUIRED;
        END IF;
        IF p_del_leg_rec.ACTUAL_ARRIVAL_DATE = FND_API.G_MISS_DATE THEN
           l_dleg_rec.ACTUAL_ARRIVAL_DATE := NULL;
        ELSIF p_del_leg_rec.ACTUAL_ARRIVAL_DATE IS NOT NULL THEN
           l_dleg_rec.ACTUAL_ARRIVAL_DATE := p_del_leg_rec.ACTUAL_ARRIVAL_DATE;
        END IF;
        IF p_del_leg_rec.ACTUAL_DEPARTURE_DATE = FND_API.G_MISS_DATE THEN
           l_dleg_rec.ACTUAL_DEPARTURE_DATE := NULL;
        ELSIF p_del_leg_rec.ACTUAL_DEPARTURE_DATE IS NOT NULL THEN
           l_dleg_rec.ACTUAL_DEPARTURE_DATE := p_del_leg_rec.ACTUAL_DEPARTURE_DATE;
        END IF;
        IF p_del_leg_rec.ACTUAL_RECEIPT_DATE = FND_API.G_MISS_DATE THEN
           l_dleg_rec.ACTUAL_RECEIPT_DATE := NULL;
        ELSIF p_del_leg_rec.ACTUAL_RECEIPT_DATE IS NOT NULL THEN
           l_dleg_rec.ACTUAL_RECEIPT_DATE := p_del_leg_rec.ACTUAL_RECEIPT_DATE;
        END IF;
        IF p_del_leg_rec.TRACKING_DRILLDOWN_FLAG = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.TRACKING_DRILLDOWN_FLAG := NULL;
        ELSIF p_del_leg_rec.TRACKING_DRILLDOWN_FLAG IS NOT NULL THEN
           l_dleg_rec.TRACKING_DRILLDOWN_FLAG := p_del_leg_rec.TRACKING_DRILLDOWN_FLAG;
        END IF;
        IF p_del_leg_rec.STATUS_CODE = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.STATUS_CODE := NULL;
        ELSIF p_del_leg_rec.STATUS_CODE IS NOT NULL THEN
           l_dleg_rec.STATUS_CODE := p_del_leg_rec.STATUS_CODE;
        END IF;
        IF p_del_leg_rec.TRACKING_REMARKS = FND_API.G_MISS_CHAR THEN
           l_dleg_rec.TRACKING_REMARKS := NULL;
        ELSIF p_del_leg_rec.TRACKING_REMARKS IS NOT NULL THEN
           l_dleg_rec.TRACKING_REMARKS := p_del_leg_rec.TRACKING_REMARKS;
        END IF;
        IF p_del_leg_rec.CARRIER_EST_DEPARTURE_DATE = FND_API.G_MISS_DATE THEN
           l_dleg_rec.CARRIER_EST_DEPARTURE_DATE := NULL;
        ELSIF p_del_leg_rec.CARRIER_EST_DEPARTURE_DATE IS NOT NULL THEN
           l_dleg_rec.CARRIER_EST_DEPARTURE_DATE := p_del_leg_rec.CARRIER_EST_DEPARTURE_DATE;
        END IF;
        IF p_del_leg_rec.CARRIER_EST_ARRIVAL_DATE = FND_API.G_MISS_DATE THEN
           l_dleg_rec.CARRIER_EST_ARRIVAL_DATE := NULL;
        ELSIF p_del_leg_rec.CARRIER_EST_ARRIVAL_DATE IS NOT NULL THEN
           l_dleg_rec.CARRIER_EST_ARRIVAL_DATE := p_del_leg_rec.CARRIER_EST_ARRIVAL_DATE;
        END IF;
        IF p_del_leg_rec.LOADING_START_DATETIME = FND_API.G_MISS_DATE THEN
           l_dleg_rec.LOADING_START_DATETIME := NULL;
        ELSIF p_del_leg_rec.LOADING_START_DATETIME IS NOT NULL THEN
           l_dleg_rec.LOADING_START_DATETIME := p_del_leg_rec.LOADING_START_DATETIME;
        END IF;
        IF p_del_leg_rec.LOADING_END_DATETIME = FND_API.G_MISS_DATE THEN
           l_dleg_rec.LOADING_END_DATETIME := NULL;
        ELSIF p_del_leg_rec.LOADING_END_DATETIME IS NOT NULL THEN
           l_dleg_rec.LOADING_END_DATETIME := p_del_leg_rec.LOADING_END_DATETIME;
        END IF;
        IF p_del_leg_rec.UNLOADING_START_DATETIME = FND_API.G_MISS_DATE THEN
           l_dleg_rec.UNLOADING_START_DATETIME := NULL;
        ELSIF p_del_leg_rec.UNLOADING_START_DATETIME IS NOT NULL THEN
           l_dleg_rec.UNLOADING_START_DATETIME := p_del_leg_rec.UNLOADING_START_DATETIME;
        END IF;
        IF p_del_leg_rec.UNLOADING_END_DATETIME = FND_API.G_MISS_DATE THEN
           l_dleg_rec.UNLOADING_END_DATETIME := NULL;
        ELSIF p_del_leg_rec.UNLOADING_END_DATETIME IS NOT NULL THEN
           l_dleg_rec.UNLOADING_END_DATETIME := p_del_leg_rec.UNLOADING_END_DATETIME;
        END IF;
        IF p_del_leg_rec.DELIVERED_QUANTITY = FND_API.G_MISS_NUM THEN
           l_dleg_rec.DELIVERED_QUANTITY := NULL;
        ELSIF p_del_leg_rec.DELIVERED_QUANTITY IS NOT NULL THEN
           l_dleg_rec.DELIVERED_QUANTITY := p_del_leg_rec.DELIVERED_QUANTITY;
        END IF;
        IF p_del_leg_rec.LOADED_QUANTITY = FND_API.G_MISS_NUM THEN
           l_dleg_rec.LOADED_QUANTITY := NULL;
        ELSIF p_del_leg_rec.LOADED_QUANTITY IS NOT NULL THEN
           l_dleg_rec.LOADED_QUANTITY := p_del_leg_rec.LOADED_QUANTITY;
        END IF;
        IF p_del_leg_rec.RECEIVED_QUANTITY = FND_API.G_MISS_NUM THEN
           l_dleg_rec.RECEIVED_QUANTITY := NULL;
        ELSIF p_del_leg_rec.RECEIVED_QUANTITY IS NOT NULL THEN
           l_dleg_rec.RECEIVED_QUANTITY := p_del_leg_rec.RECEIVED_QUANTITY;
        END IF;
        IF p_del_leg_rec.ORIGIN_STOP_ID = FND_API.G_MISS_NUM THEN
           l_dleg_rec.ORIGIN_STOP_ID := NULL;
        ELSIF p_del_leg_rec.ORIGIN_STOP_ID IS NOT NULL THEN
           l_dleg_rec.ORIGIN_STOP_ID := p_del_leg_rec.ORIGIN_STOP_ID;
        END IF;
        IF p_del_leg_rec.DESTINATION_STOP_ID = FND_API.G_MISS_NUM THEN
           l_dleg_rec.DESTINATION_STOP_ID := NULL;
        ELSIF p_del_leg_rec.DESTINATION_STOP_ID IS NOT NULL THEN
           l_dleg_rec.DESTINATION_STOP_ID := p_del_leg_rec.DESTINATION_STOP_ID;
        END IF;
        IF p_del_leg_rec.parent_delivery_leg_id = FND_API.G_MISS_NUM THEN
           l_dleg_rec.parent_delivery_leg_id := NULL;
        ELSIF p_del_leg_rec.parent_delivery_leg_id IS NOT NULL THEN
           l_dleg_rec.parent_delivery_leg_id := p_del_leg_rec.parent_delivery_leg_id;
        END IF;


         x_del_leg_rec := l_dleg_rec;

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION

           WHEN others THEN
                 wsh_util_core.default_handler('WSH_DELIVERY_LEGS_GRP.get_disabled_list',l_module_name);
                 x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                 --
                 IF c_get_leg_record%isopen THEN
                    CLOSE c_get_leg_record;
                 END IF;
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
                 END IF;

END get_disabled_list;

END WSH_DELIVERY_LEGS_GRP;

/
