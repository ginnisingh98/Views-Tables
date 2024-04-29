--------------------------------------------------------
--  DDL for Package Body WSH_INTERFACE_EXT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_INTERFACE_EXT_GRP" as
/* $Header: WSHEXGPB.pls 120.4.12010000.2 2010/02/10 11:22:06 anvarshn ship $ */

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_INTERFACE_EXT_GRP';
-- add your constants here if any
--===================
-- PUBLIC VARS
--===================



FUNCTION Handle_missing_info
                  (p_value        IN  NUMBER,
                   p_entity	  IN  VARCHAR2 DEFAULT NULL,
		   p_action       IN  VARCHAR2 DEFAULT NULL
                  ) RETURN NUMBER  IS

 l_debug_on BOOLEAN;
 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Handle_missing_info';
 l_value NUMBER;

BEGIN
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

 IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;
    --
/*
 IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_value',p_value);
 END IF;
*/

 l_value := p_value;
 IF (nvl(p_entity,'$$') = 'DLVB' and nvl(p_action,'$$')= 'CREATE') THEN
    IF (p_value = fnd_api.g_miss_num) THEN
       l_value := NULL;
    END IF;
 ELSE
    IF (p_value = fnd_api.g_miss_num) THEN
      l_value := NULL;
    ELSIF (p_value IS NULL) THEN
      l_value := fnd_api.g_miss_num;
    END IF;
 END IF;

/*
 IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name,'l_value',l_value);
   WSH_DEBUG_SV.pop(l_module_name);
 END IF;
*/
 return l_value;
EXCEPTION
 WHEN OTHERS THEN
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    raise;
END Handle_missing_info;


FUNCTION Handle_missing_info
                  (p_value        IN  VARCHAR2,
                   p_entity	  IN  VARCHAR2 DEFAULT NULL,
		   p_action       IN  VARCHAR2 DEFAULT NULL
                  ) RETURN VARCHAR2 IS

 l_debug_on BOOLEAN;
 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Handle_missing_info';
 l_value VARCHAR2(32767);

BEGIN
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

 IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;
    --
/*
 IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_value',p_value);
 END IF;
*/

 l_value := p_value;
 IF (nvl(p_entity,'$$') = 'DLVB' and nvl(p_action,'$$')='CREATE') THEN
    IF (p_value = fnd_api.g_miss_char) THEN
       l_value := NULL;
    END IF;
 ELSE
    IF (p_value = fnd_api.g_miss_char) THEN
      l_value := NULL;
    ELSIF (p_value IS NULL) THEN
      l_value := fnd_api.g_miss_char;
    END IF;
 END IF;
 /*
 IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name,'l_value',l_value);
   WSH_DEBUG_SV.pop(l_module_name);
 END IF;
*/
 return l_value;
EXCEPTION
 WHEN OTHERS THEN
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    raise;
END Handle_missing_info;


FUNCTION Handle_missing_info
                  (p_value        IN  DATE,
                   p_entity	  IN  VARCHAR2 DEFAULT NULL,
		   p_action       IN  VARCHAR2 DEFAULT NULL
                  ) RETURN DATE  IS

 l_debug_on BOOLEAN;
 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Handle_missing_info';
 l_value DATE;

BEGIN
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

 IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;
    --
/*
 IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_value',p_value);
 END IF;
*/

 l_value := p_value;
 IF (nvl(p_entity,'$$') = 'DLVB' and nvl(p_action,'$$')='CREATE') THEN
    IF (p_value = fnd_api.g_miss_date) THEN
       l_value := NULL;
    END IF;
 ELSE
    IF (p_value = fnd_api.g_miss_date) THEN
      l_value := NULL;
    ELSIF (p_value IS NULL) THEN
      l_value := fnd_api.g_miss_date;
    END IF;
 END IF;

/*
IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name,'l_value',l_value);
   WSH_DEBUG_SV.pop(l_module_name);
 END IF;
*/
 return l_value;
EXCEPTION
 WHEN OTHERS THEN
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    raise;
END Handle_missing_info;

Procedure Map_del_act_params_rectype(
  p_in_rec IN WSH_INTERFACE_EXT_GRP.del_action_parameters_rectype,
  x_out_rec OUT NOCOPY WSH_DELIVERIES_GRP.action_parameters_rectype) IS

Begin
  x_out_rec.caller                          := p_in_rec.caller               ;
  x_out_rec.phase    			    := p_in_rec.phase    			;
  x_out_rec.action_code  		    := p_in_rec.action_code  		;
  x_out_rec.trip_id  			    := p_in_rec.trip_id  			;
  x_out_rec.trip_name  			    := p_in_rec.trip_name  		;
  x_out_rec.pickup_stop_id   		    := p_in_rec.pickup_stop_id   		;
  x_out_rec.pickup_loc_id   		    := p_in_rec.pickup_loc_id   		;
  x_out_rec.pickup_stop_seq   	  	    := p_in_rec.pickup_stop_seq   	;
  x_out_rec.pickup_loc_code  		    := p_in_rec.pickup_loc_code  		;
  x_out_rec.pickup_arr_date   	  	    := p_in_rec.pickup_arr_date   	;
  x_out_rec.pickup_dep_date  		    := p_in_rec.pickup_dep_date  		;
  x_out_rec.pickup_stop_status   	    := p_in_rec.pickup_stop_status   ;
  x_out_rec.dropoff_stop_id   	  	    := p_in_rec.dropoff_stop_id   	;
  x_out_rec.dropoff_loc_id    	  	    := p_in_rec.dropoff_loc_id    	;
  x_out_rec.dropoff_stop_seq  	  	    := p_in_rec.dropoff_stop_seq  	;
  x_out_rec.dropoff_loc_code  	  	    := p_in_rec.dropoff_loc_code  	;
  x_out_rec.dropoff_arr_date  	  	    := p_in_rec.dropoff_arr_date  	;
  x_out_rec.dropoff_dep_date 		    := p_in_rec.dropoff_dep_date 		;
  x_out_rec.dropoff_stop_status    	    := p_in_rec.dropoff_stop_status   ;
  x_out_rec.action_flag   		    := p_in_rec.action_flag   		;
  x_out_rec.intransit_flag   		    := p_in_rec.intransit_flag   		;
  x_out_rec.close_trip_flag  		    := p_in_rec.close_trip_flag  		;
  x_out_rec.stage_del_flag   		    := p_in_rec.stage_del_flag   		;
  x_out_rec.bill_of_lading_flag 	    := p_in_rec.bill_of_lading_flag ;
  x_out_rec.mc_bill_of_lading_flag  	    := p_in_rec.mc_bill_of_lading_flag;
  x_out_rec.override_flag   		    := p_in_rec.override_flag   		;
  x_out_rec.defer_interface_flag 	    := p_in_rec.defer_interface_flag ;
  x_out_rec.ship_method_code  	  	    := p_in_rec.ship_method_code  	;
  x_out_rec.actual_dep_date 		    := p_in_rec.actual_dep_date 		;
  x_out_rec.report_set_id  		    := p_in_rec.report_set_id  		;
  x_out_rec.report_set_name   	  	    := p_in_rec.report_set_name   	;
  x_out_rec.send_945_flag  		    := p_in_rec.send_945_flag  		;
  x_out_rec.action_type   		    := p_in_rec.action_type   		;
  x_out_rec.document_type   		    := p_in_rec.document_type   		;
  x_out_rec.organization_id  		    := p_in_rec.organization_id  		;
  x_out_rec.reason_of_transport 	    := p_in_rec.reason_of_transport ;
  x_out_rec.description  		    := p_in_rec.description  		;
  x_out_rec.event    		            := p_in_rec.event 		;



End Map_del_act_params_rectype;


Procedure Map_del_act_OutRecType(
   p_in_rec   IN   WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type,
   x_out_rec  OUT  NOCOPY WSH_INTERFACE_EXT_GRP.Del_Action_Out_Rec_Type) IS


   Begin

     x_out_rec.packing_slip_number          := p_in_rec.packing_slip_number  ;
     x_out_rec.valid_ids_tab         	    := p_in_rec.valid_ids_tab        ;
     x_out_rec.result_id_tab         	    := p_in_rec.result_id_tab        ;
     x_out_rec.selection_issue_flag  	    := p_in_rec.selection_issue_flag ;


End Map_del_act_OutRecType;


--========================================================================
-- PROCEDURE : Delivery_Action         Wrapper API      PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_action_prms           Record of caller, phase, action_code and other
--                                     parameters specific to the actions.
--	       p_rec_attr_tab          Table of Attributes for the delivery entity
--             x_delivery_out_rec      Record of output parameters based on the actions.
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to perform an action specified
--             in p_action_prms.action_code on an existing delivery identified
--             by p_rec_attr.delivery_id/p_rec_attr.name.
--========================================================================
  PROCEDURE Delivery_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2 , -- default fnd_api.g_false
    p_action_prms            IN   WSH_INTERFACE_EXT_GRP.del_action_parameters_rectype,
    p_delivery_id_tab        IN   wsh_util_core.id_tab_type,
    x_delivery_out_rec       OUT  NOCOPY WSH_INTERFACE_EXT_GRP.Del_Action_Out_Rec_Type,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2)
  IS
    --
    l_del_act_params_rectype   WSH_DELIVERIES_GRP.action_parameters_rectype;
    l_Del_Act_Out_Rec_Type         WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type;


    --
  BEGIN

 Map_del_act_params_rectype(p_action_prms, l_del_act_params_rectype);

 WSH_INTERFACE_GRP.Delivery_Action
  ( p_api_version_number     =>   p_api_version_number,
    p_init_msg_list          =>   p_init_msg_list,
    p_commit                 =>   p_commit , -- default fnd_api.g_false
    p_action_prms            =>   l_del_act_params_rectype,
    p_delivery_id_tab        =>   p_delivery_id_tab,
    x_delivery_out_rec       =>   l_Del_Act_Out_Rec_Type,
    x_return_status          =>   x_return_status,
    x_msg_count              =>   x_msg_count,
    x_msg_data               =>   x_msg_data);

 Map_del_act_OutRecType(l_Del_Act_Out_Rec_Type, x_delivery_out_rec);
    --
  EXCEPTION
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INTERFACE_EXT_GRP.DELIVERY_ACTION');
      --
  END Delivery_Action;

Procedure Map_Del_InRecType(
   p_in_rec  IN WSH_INTERFACE_EXT_GRP.Del_In_Rec_Type,
   x_out_rec OUT NOCOPY WSH_DELIVERIES_GRP.Del_In_Rec_Type) IS

   Begin

     x_out_rec.caller          := p_in_rec.caller       ;
     x_out_rec.phase           := p_in_rec.phase     ;
     x_out_rec.action_code     := p_in_rec.action_code;

   End Map_Del_InRecType;

Procedure Map_Del_Attr_Tbl_Type (
    p_in_tab IN WSH_INTERFACE_EXT_GRP.Delivery_Attr_Tbl_Type,
    x_out_tab OUT NOCOPY WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type) Is

Begin

for i in 1..p_in_tab.count LOOP

x_out_tab(i).DELIVERY_ID                      := handle_missing_info(p_in_tab(i).DELIVERY_ID );
x_out_tab(i).NAME                             := handle_missing_info(p_in_tab(i).NAME        );
x_out_tab(i).PLANNED_FLAG                     := handle_missing_info(p_in_tab(i).PLANNED_FLAG);
x_out_tab(i).STATUS_CODE                      := handle_missing_info(p_in_tab(i).STATUS_CODE );
x_out_tab(i).DELIVERY_TYPE                    := handle_missing_info(p_in_tab(i).DELIVERY_TYPE);
x_out_tab(i).LOADING_SEQUENCE                 := handle_missing_info(p_in_tab(i).LOADING_SEQUENCE);
x_out_tab(i).LOADING_ORDER_FLAG               := handle_missing_info(p_in_tab(i).LOADING_ORDER_FLAG);
x_out_tab(i).INITIAL_PICKUP_DATE              := handle_missing_info(p_in_tab(i).INITIAL_PICKUP_DATE);
x_out_tab(i).INITIAL_PICKUP_LOCATION_ID       := handle_missing_info(p_in_tab(i).INITIAL_PICKUP_LOCATION_ID);
x_out_tab(i).ORGANIZATION_ID                  := handle_missing_info(p_in_tab(i).ORGANIZATION_ID);
x_out_tab(i).ULTIMATE_DROPOFF_LOCATION_ID     := handle_missing_info(p_in_tab(i).ULTIMATE_DROPOFF_LOCATION_ID);
x_out_tab(i).ULTIMATE_DROPOFF_DATE            := handle_missing_info(p_in_tab(i).ULTIMATE_DROPOFF_DATE);
x_out_tab(i).CUSTOMER_ID                      := handle_missing_info(p_in_tab(i).CUSTOMER_ID );
x_out_tab(i).INTMED_SHIP_TO_LOCATION_ID       := handle_missing_info(p_in_tab(i).INTMED_SHIP_TO_LOCATION_ID);
x_out_tab(i).POOLED_SHIP_TO_LOCATION_ID       := handle_missing_info(p_in_tab(i).POOLED_SHIP_TO_LOCATION_ID);
x_out_tab(i).CARRIER_ID                       := handle_missing_info(p_in_tab(i).CARRIER_ID  );
x_out_tab(i).SHIP_METHOD_CODE                 := handle_missing_info(p_in_tab(i).SHIP_METHOD_CODE);
x_out_tab(i).FREIGHT_TERMS_CODE               := handle_missing_info(p_in_tab(i).FREIGHT_TERMS_CODE);
x_out_tab(i).FOB_CODE                         := handle_missing_info(p_in_tab(i).FOB_CODE    );
x_out_tab(i).FOB_LOCATION_ID                  := handle_missing_info(p_in_tab(i).FOB_LOCATION_ID);
x_out_tab(i).WAYBILL                          := handle_missing_info(p_in_tab(i).WAYBILL     );
x_out_tab(i).DOCK_CODE                        := handle_missing_info(p_in_tab(i).DOCK_CODE   );
x_out_tab(i).ACCEPTANCE_FLAG                  := handle_missing_info(p_in_tab(i).ACCEPTANCE_FLAG);
x_out_tab(i).ACCEPTED_BY                      := handle_missing_info(p_in_tab(i).ACCEPTED_BY );
x_out_tab(i).ACCEPTED_DATE                    := handle_missing_info(p_in_tab(i).ACCEPTED_DATE);
x_out_tab(i).ACKNOWLEDGED_BY                  := handle_missing_info(p_in_tab(i).ACKNOWLEDGED_BY);
x_out_tab(i).CONFIRMED_BY                     := handle_missing_info(p_in_tab(i).CONFIRMED_BY);
x_out_tab(i).CONFIRM_DATE                     := handle_missing_info(p_in_tab(i).CONFIRM_DATE);
x_out_tab(i).ASN_DATE_SENT                    := handle_missing_info(p_in_tab(i).ASN_DATE_SENT);
x_out_tab(i).ASN_STATUS_CODE                  := handle_missing_info(p_in_tab(i).ASN_STATUS_CODE);
x_out_tab(i).ASN_SEQ_NUMBER                   := handle_missing_info(p_in_tab(i).ASN_SEQ_NUMBER);
x_out_tab(i).GROSS_WEIGHT                     := handle_missing_info(p_in_tab(i).GROSS_WEIGHT);
x_out_tab(i).NET_WEIGHT                       := handle_missing_info(p_in_tab(i).NET_WEIGHT  );
x_out_tab(i).WEIGHT_UOM_CODE                  := handle_missing_info(p_in_tab(i).WEIGHT_UOM_CODE);
x_out_tab(i).VOLUME                           := handle_missing_info(p_in_tab(i).VOLUME      );
x_out_tab(i).VOLUME_UOM_CODE                  := handle_missing_info(p_in_tab(i).VOLUME_UOM_CODE);
x_out_tab(i).ADDITIONAL_SHIPMENT_INFO         := handle_missing_info(p_in_tab(i).ADDITIONAL_SHIPMENT_INFO);
x_out_tab(i).CURRENCY_CODE                    := handle_missing_info(p_in_tab(i).CURRENCY_CODE);
x_out_tab(i).ATTRIBUTE_CATEGORY               := handle_missing_info(p_in_tab(i).ATTRIBUTE_CATEGORY);
x_out_tab(i).ATTRIBUTE1                       := handle_missing_info(p_in_tab(i).ATTRIBUTE1  );
x_out_tab(i).ATTRIBUTE2                       := handle_missing_info(p_in_tab(i).ATTRIBUTE2  );
x_out_tab(i).ATTRIBUTE3                       := handle_missing_info(p_in_tab(i).ATTRIBUTE3  );
x_out_tab(i).ATTRIBUTE4                       := handle_missing_info(p_in_tab(i).ATTRIBUTE4  );
x_out_tab(i).ATTRIBUTE5                       := handle_missing_info(p_in_tab(i).ATTRIBUTE5  );
x_out_tab(i).ATTRIBUTE6                       := handle_missing_info(p_in_tab(i).ATTRIBUTE6  );
x_out_tab(i).ATTRIBUTE7                       := handle_missing_info(p_in_tab(i).ATTRIBUTE7  );
x_out_tab(i).ATTRIBUTE8                       := handle_missing_info(p_in_tab(i).ATTRIBUTE8  );
x_out_tab(i).ATTRIBUTE9                       := handle_missing_info(p_in_tab(i).ATTRIBUTE9  );
x_out_tab(i).ATTRIBUTE10                      := handle_missing_info(p_in_tab(i).ATTRIBUTE10 );
x_out_tab(i).ATTRIBUTE11                      := handle_missing_info(p_in_tab(i).ATTRIBUTE11 );
x_out_tab(i).ATTRIBUTE12                      := handle_missing_info(p_in_tab(i).ATTRIBUTE12 );
x_out_tab(i).ATTRIBUTE13                      := handle_missing_info(p_in_tab(i).ATTRIBUTE13 );
x_out_tab(i).ATTRIBUTE14                      := handle_missing_info(p_in_tab(i).ATTRIBUTE14 );
x_out_tab(i).ATTRIBUTE15                      := handle_missing_info(p_in_tab(i).ATTRIBUTE15 );
x_out_tab(i).TP_ATTRIBUTE_CATEGORY            := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE_CATEGORY);
x_out_tab(i).TP_ATTRIBUTE1                    := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE1);
x_out_tab(i).TP_ATTRIBUTE2                    := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE2);
x_out_tab(i).TP_ATTRIBUTE3                    := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE3);
x_out_tab(i).TP_ATTRIBUTE4                    := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE4);
x_out_tab(i).TP_ATTRIBUTE5                    := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE5);
x_out_tab(i).TP_ATTRIBUTE6                    := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE6);
x_out_tab(i).TP_ATTRIBUTE7                    := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE7);
x_out_tab(i).TP_ATTRIBUTE8                    := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE8);
x_out_tab(i).TP_ATTRIBUTE9                    := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE9);
x_out_tab(i).TP_ATTRIBUTE10                   := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE10);
x_out_tab(i).TP_ATTRIBUTE11                   := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE11);
x_out_tab(i).TP_ATTRIBUTE12                   := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE12);
x_out_tab(i).TP_ATTRIBUTE13                   := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE13);
x_out_tab(i).TP_ATTRIBUTE14                   := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE14);
x_out_tab(i).TP_ATTRIBUTE15                   := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE15);
x_out_tab(i).GLOBAL_ATTRIBUTE_CATEGORY        := handle_missing_info(p_in_tab(i).GLOBAL_ATTRIBUTE_CATEGORY);
x_out_tab(i).GLOBAL_ATTRIBUTE1                := handle_missing_info(p_in_tab(i).GLOBAL_ATTRIBUTE1);
x_out_tab(i).GLOBAL_ATTRIBUTE2                := handle_missing_info(p_in_tab(i).GLOBAL_ATTRIBUTE2);
x_out_tab(i).GLOBAL_ATTRIBUTE3                := handle_missing_info(p_in_tab(i).GLOBAL_ATTRIBUTE3);
x_out_tab(i).GLOBAL_ATTRIBUTE4                := handle_missing_info(p_in_tab(i).GLOBAL_ATTRIBUTE4);
x_out_tab(i).GLOBAL_ATTRIBUTE5                := handle_missing_info(p_in_tab(i).GLOBAL_ATTRIBUTE5);
x_out_tab(i).GLOBAL_ATTRIBUTE6                := handle_missing_info(p_in_tab(i).GLOBAL_ATTRIBUTE6);
x_out_tab(i).GLOBAL_ATTRIBUTE7                := handle_missing_info(p_in_tab(i).GLOBAL_ATTRIBUTE7);
x_out_tab(i).GLOBAL_ATTRIBUTE8                := handle_missing_info(p_in_tab(i).GLOBAL_ATTRIBUTE8);
x_out_tab(i).GLOBAL_ATTRIBUTE9                := handle_missing_info(p_in_tab(i).GLOBAL_ATTRIBUTE9);
x_out_tab(i).GLOBAL_ATTRIBUTE10               := handle_missing_info(p_in_tab(i).GLOBAL_ATTRIBUTE10);
x_out_tab(i).GLOBAL_ATTRIBUTE11               := handle_missing_info(p_in_tab(i).GLOBAL_ATTRIBUTE11);
x_out_tab(i).GLOBAL_ATTRIBUTE12               := handle_missing_info(p_in_tab(i).GLOBAL_ATTRIBUTE12);
x_out_tab(i).GLOBAL_ATTRIBUTE13               := handle_missing_info(p_in_tab(i).GLOBAL_ATTRIBUTE13);
x_out_tab(i).GLOBAL_ATTRIBUTE14               := handle_missing_info(p_in_tab(i).GLOBAL_ATTRIBUTE14);
x_out_tab(i).GLOBAL_ATTRIBUTE15               := handle_missing_info(p_in_tab(i).GLOBAL_ATTRIBUTE15);
x_out_tab(i).GLOBAL_ATTRIBUTE16               := handle_missing_info(p_in_tab(i).GLOBAL_ATTRIBUTE16);
x_out_tab(i).GLOBAL_ATTRIBUTE17               := handle_missing_info(p_in_tab(i).GLOBAL_ATTRIBUTE17);
x_out_tab(i).GLOBAL_ATTRIBUTE18               := handle_missing_info(p_in_tab(i).GLOBAL_ATTRIBUTE18);
x_out_tab(i).GLOBAL_ATTRIBUTE19               := handle_missing_info(p_in_tab(i).GLOBAL_ATTRIBUTE19);
x_out_tab(i).GLOBAL_ATTRIBUTE20               := handle_missing_info(p_in_tab(i).GLOBAL_ATTRIBUTE20);
x_out_tab(i).CREATION_DATE                    := handle_missing_info(p_in_tab(i).CREATION_DATE);
x_out_tab(i).CREATED_BY                       := handle_missing_info(p_in_tab(i).CREATED_BY  );
x_out_tab(i).LAST_UPDATE_DATE                 := handle_missing_info(p_in_tab(i).LAST_UPDATE_DATE);
x_out_tab(i).LAST_UPDATED_BY                  := handle_missing_info(p_in_tab(i).LAST_UPDATED_BY);
x_out_tab(i).LAST_UPDATE_LOGIN                := handle_missing_info(p_in_tab(i).LAST_UPDATE_LOGIN);
x_out_tab(i).PROGRAM_APPLICATION_ID           := handle_missing_info(p_in_tab(i).PROGRAM_APPLICATION_ID);
x_out_tab(i).PROGRAM_ID                       := handle_missing_info(p_in_tab(i).PROGRAM_ID  );
x_out_tab(i).PROGRAM_UPDATE_DATE              := handle_missing_info(p_in_tab(i).PROGRAM_UPDATE_DATE);
x_out_tab(i).REQUEST_ID                       := handle_missing_info(p_in_tab(i).REQUEST_ID  );
x_out_tab(i).BATCH_ID                         := handle_missing_info(p_in_tab(i).BATCH_ID    );
x_out_tab(i).HASH_VALUE                       := handle_missing_info(p_in_tab(i).HASH_VALUE  );
x_out_tab(i).SOURCE_HEADER_ID                 := handle_missing_info(p_in_tab(i).SOURCE_HEADER_ID);
x_out_tab(i).NUMBER_OF_LPN                    := handle_missing_info(p_in_tab(i).NUMBER_OF_LPN);
x_out_tab(i).COD_AMOUNT                       := handle_missing_info(p_in_tab(i).COD_AMOUNT  );
x_out_tab(i).COD_CURRENCY_CODE                := handle_missing_info(p_in_tab(i).COD_CURRENCY_CODE);
x_out_tab(i).COD_REMIT_TO                     := handle_missing_info(p_in_tab(i).COD_REMIT_TO);
x_out_tab(i).COD_CHARGE_PAID_BY               := handle_missing_info(p_in_tab(i).COD_CHARGE_PAID_BY);
x_out_tab(i).PROBLEM_CONTACT_REFERENCE        := handle_missing_info(p_in_tab(i).PROBLEM_CONTACT_REFERENCE);
x_out_tab(i).PORT_OF_LOADING                  := handle_missing_info(p_in_tab(i).PORT_OF_LOADING);
x_out_tab(i).PORT_OF_DISCHARGE                := handle_missing_info(p_in_tab(i).PORT_OF_DISCHARGE);
x_out_tab(i).FTZ_NUMBER                       := handle_missing_info(p_in_tab(i).FTZ_NUMBER  );
x_out_tab(i).ROUTED_EXPORT_TXN                := handle_missing_info(p_in_tab(i).ROUTED_EXPORT_TXN);
x_out_tab(i).ENTRY_NUMBER                     := handle_missing_info(p_in_tab(i).ENTRY_NUMBER);
x_out_tab(i).ROUTING_INSTRUCTIONS             := handle_missing_info(p_in_tab(i).ROUTING_INSTRUCTIONS);
x_out_tab(i).IN_BOND_CODE                     := handle_missing_info(p_in_tab(i).IN_BOND_CODE);
x_out_tab(i).SHIPPING_MARKS                   := handle_missing_info(p_in_tab(i).SHIPPING_MARKS);
x_out_tab(i).SERVICE_LEVEL                    := handle_missing_info(p_in_tab(i).SERVICE_LEVEL);
x_out_tab(i).MODE_OF_TRANSPORT                := handle_missing_info(p_in_tab(i).MODE_OF_TRANSPORT);
x_out_tab(i).ASSIGNED_TO_FTE_TRIPS            := handle_missing_info(p_in_tab(i).ASSIGNED_TO_FTE_TRIPS);
x_out_tab(i).AUTO_SC_EXCLUDE_FLAG             := handle_missing_info(p_in_tab(i).AUTO_SC_EXCLUDE_FLAG);
x_out_tab(i).AUTO_AP_EXCLUDE_FLAG             := handle_missing_info(p_in_tab(i).AUTO_AP_EXCLUDE_FLAG);
x_out_tab(i).AP_BATCH_ID                      := handle_missing_info(p_in_tab(i).AP_BATCH_ID );
x_out_tab(i).ROWID                            := p_in_tab(i).ROWID;
x_out_tab(i).LOADING_ORDER_DESC               := handle_missing_info(p_in_tab(i).LOADING_ORDER_DESC);
x_out_tab(i).ORGANIZATION_CODE                := handle_missing_info(p_in_tab(i).ORGANIZATION_CODE);
x_out_tab(i).ULTIMATE_DROPOFF_LOCATION_CODE   := handle_missing_info(p_in_tab(i).ULTIMATE_DROPOFF_LOCATION_CODE);
x_out_tab(i).INITIAL_PICKUP_LOCATION_CODE     := handle_missing_info(p_in_tab(i).INITIAL_PICKUP_LOCATION_CODE);
x_out_tab(i).CUSTOMER_NUMBER                  := handle_missing_info(p_in_tab(i).CUSTOMER_NUMBER);
x_out_tab(i).INTMED_SHIP_TO_LOCATION_CODE     := handle_missing_info(p_in_tab(i).INTMED_SHIP_TO_LOCATION_CODE);
x_out_tab(i).POOLED_SHIP_TO_LOCATION_CODE     := handle_missing_info(p_in_tab(i).POOLED_SHIP_TO_LOCATION_CODE);
x_out_tab(i).CARRIER_CODE                     := handle_missing_info(p_in_tab(i).CARRIER_CODE);
x_out_tab(i).SHIP_METHOD_NAME                 := handle_missing_info(p_in_tab(i).SHIP_METHOD_NAME);
x_out_tab(i).FREIGHT_TERMS_NAME               := handle_missing_info(p_in_tab(i).FREIGHT_TERMS_NAME);
x_out_tab(i).FOB_NAME                         := handle_missing_info(p_in_tab(i).FOB_NAME    );
x_out_tab(i).FOB_LOCATION_CODE                := handle_missing_info(p_in_tab(i).FOB_LOCATION_CODE);
x_out_tab(i).WEIGHT_UOM_DESC                  := handle_missing_info(p_in_tab(i).WEIGHT_UOM_DESC);
x_out_tab(i).VOLUME_UOM_DESC                  := handle_missing_info(p_in_tab(i).VOLUME_UOM_DESC);
x_out_tab(i).CURRENCY_NAME                    := handle_missing_info(p_in_tab(i).CURRENCY_NAME);

END LOOP;

END Map_Del_Attr_Tbl_Type;


Procedure Map_Del_OutTblType(
   p_in_tab  IN  WSH_DELIVERIES_GRP.Del_Out_Tbl_Type,
   x_out_tab OUT NOCOPY WSH_INTERFACE_EXT_GRP.Del_Out_Tbl_Type) IS


Begin

for i in 1..p_in_tab.count LOOP
 x_out_tab(i).delivery_id   := p_in_tab(i).delivery_id;
 x_out_tab(i).name          := p_in_tab(i).name       ;
 x_out_tab(i).rowid         := p_in_tab(i).rowid      ;

END LOOP;
End  Map_Del_OutTblType;


--========================================================================

-- I Harmonization: rvishnuv ******* Actions ******

-- I Harmonization: rvishnuv ******* Create/Update ******
--========================================================================
-- PROCEDURE : Create_Update_Delivery  Wrapper API      PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_in_rec                Record for caller, phase
--                                     and action_code ( CREATE-UPDATE )
--	       p_rec_attr_tab          Table of Attributes for the delivery entity
--  	       x_del_out_rec           Record of delivery_id, and name of new deliveries,
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Creates or updates a record in wsh_new_deliveries table with information
--             specified in p_delivery_info
--========================================================================
  PROCEDURE Create_Update_Delivery
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit		     IN   VARCHAR2 , -- default fnd_api.g_false
    p_in_rec                 IN   WSH_INTERFACE_EXT_GRP.Del_In_Rec_Type,
    p_rec_attr_tab	     IN   WSH_INTERFACE_EXT_GRP.Delivery_Attr_Tbl_Type,
    x_del_out_rec_tab        OUT  NOCOPY WSH_INTERFACE_EXT_GRP.Del_Out_Tbl_Type,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2)
  IS
    --

    l_Del_In_Rec_Type            WSH_DELIVERIES_GRP.Del_In_Rec_Type;
    l_Del_Attr_Tbl_Type     WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
    l_Del_Out_Tbl_Type           WSH_DELIVERIES_GRP.Del_Out_Tbl_Type;

    --
  BEGIN
    --
    Map_Del_InRecType(p_in_rec, l_Del_In_Rec_Type);
    Map_Del_Attr_Tbl_Type(p_rec_attr_tab, l_Del_Attr_Tbl_Type);
    --
    WSH_INTERFACE_GRP.Create_Update_Delivery(
    p_api_version_number     =>   p_api_version_number,
    p_init_msg_list          =>   p_init_msg_list,
    p_commit                 =>   p_commit , -- default fnd_api.g_false
    p_in_rec                 =>   l_Del_In_Rec_Type,
    p_rec_attr_tab           =>   l_Del_Attr_Tbl_Type,
    x_del_out_rec_tab        =>   l_Del_Out_Tbl_Type,
    x_return_status          =>   x_return_status,
    x_msg_count              =>   x_msg_count,
    x_msg_data               =>   x_msg_data);

    Map_Del_OutTblType(l_Del_Out_Tbl_Type, x_del_out_rec_tab);
    --
    --
  EXCEPTION
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INTERFACE_EXT_GRP.CREATE_UPDATE_DELIVERY');
      --

END Create_Update_Delivery;
--========================================================================

-- I Harmonization: rvishnuv ******* Create/Update ******


Procedure map_det_act_params_rec_type(
   p_in_rec  IN  WSH_INTERFACE_EXT_GRP.det_action_parameters_rec_type,
   x_out_rec OUT NOCOPY wsh_glbl_var_strct_grp.dd_action_parameters_rec_type) IS

Begin

               x_out_rec.Caller                     := p_in_rec.Caller       ;
               x_out_rec.Action_Code  		    := p_in_rec.Action_Code  ;
               x_out_rec.Phase        		    := p_in_rec.Phase        ;
               x_out_rec.delivery_id  		    := p_in_rec.delivery_id  ;
               x_out_rec.delivery_name 		    := p_in_rec.delivery_name ;
               x_out_rec.wv_override_flag  	    := p_in_rec.wv_override_flag  ;
               x_out_rec.quantity_to_split 	    := p_in_rec.quantity_to_split ;
               x_out_rec.quantity2_to_split	    := p_in_rec.quantity2_to_split;
               x_out_rec.container_name    	    := p_in_rec.container_name    ;
               x_out_rec.container_instance_id 	    := p_in_rec.container_instance_id;
               x_out_rec.container_flag    	    := p_in_rec.container_flag    ;
               x_out_rec.delivery_flag     	    := p_in_rec.delivery_flag     ;
               x_out_rec.group_id_tab      	    := p_in_rec.group_id_tab      ;
               x_out_rec.split_quantity    	    := p_in_rec.split_quantity    ;
               x_out_rec.split_quantity2   	    := p_in_rec.split_quantity2   ;


End map_det_act_params_rec_type;



Procedure map_det_act_OutRecType(
  p_in_rec   IN  wsh_glbl_var_strct_grp.dd_action_out_rec_type,
  x_out_rec  OUT NOCOPY WSH_INTERFACE_EXT_GRP.det_action_out_rec_type) IS

Begin

         x_out_rec.valid_id_tab          :=  p_in_rec.valid_id_tab        ;
         x_out_rec.selection_issue_flag  :=  p_in_rec.selection_issue_flag;
         x_out_rec.delivery_id_tab       :=  p_in_rec.delivery_id_tab     ;
         x_out_rec.result_id_tab         :=  p_in_rec.result_id_tab       ;
         x_out_rec.split_quantity        :=  p_in_rec.split_quantity      ;
         x_out_rec.split_quantity2   	 :=  p_in_rec.split_quantity2   ;

End map_det_act_OutRecType;


    -- ---------------------------------------------------------------------
    -- Procedure:	Delivery_Detail_Action	Wrapper API
    --
    -- Parameters:
    --
    -- Description:  This procedure is the wrapper(overloaded) version for the
    --               main delivery_detail_group API. This is for use by public APIs
    --		 and by other product APIs. This signature does not have
    --               the form(UI) specific parameters
    -- Created :  Patchset I : Harmonization Project
    -- Created by: KVENKATE
    -- -----------------------------------------------------------------------
    PROCEDURE Delivery_Detail_Action
    (
    -- Standard Parameters
       p_api_version_number        IN       NUMBER,
       p_init_msg_list             IN 	    VARCHAR2,
       p_commit                    IN 	    VARCHAR2,
       x_return_status             OUT 	  NOCOPY  VARCHAR2,
       x_msg_count                 OUT 	  NOCOPY  NUMBER,
       x_msg_data                  OUT 	  NOCOPY  VARCHAR2,

    -- Procedure specific Parameters
       p_detail_id_tab             IN	    WSH_UTIL_CORE.id_tab_type,
       p_action_prms               IN	    WSH_INTERFACE_EXT_GRP.det_action_parameters_rec_type,
       x_action_out_rec            OUT NOCOPY     WSH_INTERFACE_EXT_GRP.det_action_out_rec_type
    ) IS

	--
       l_det_act_params_rec_type  wsh_glbl_var_strct_grp.dd_action_parameters_rec_type;
       l_det_action_out_rec_type         wsh_glbl_var_strct_grp.dd_action_out_rec_type;

  BEGIN
        -- Standard Start of API savepoint
     map_det_act_params_rec_type(p_action_prms, l_det_act_params_rec_type);

     WSH_INTERFACE_GRP.Delivery_Detail_Action(
    -- Standard Parameters
       p_api_version_number        =>       p_api_version_number,
       p_init_msg_list             =>       p_init_msg_list,
       p_commit                    =>       p_commit,
       x_return_status             =>       x_return_status,
       x_msg_count                 =>       x_msg_count,
       x_msg_data                  =>       x_msg_data,

    -- Procedure specific Parameters
       p_detail_id_tab             =>       p_detail_id_tab,
       p_action_prms               =>       l_det_act_params_rec_type,
       x_action_out_rec            =>       l_det_action_out_rec_type
    );

    map_det_act_OutRecType(l_det_action_out_rec_type, x_action_out_rec);
        --
  EXCEPTION
      --
        WHEN OTHERS THEN
               WSH_UTIL_CORE.default_handler('WSH_INTERFACE_EXT_GRP.Delivery_Detail_Action');
                ROLLBACK TO DEL_DETAIL_ACTION_WRAP_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --
    END Delivery_Detail_Action;


Procedure map_det_Attr_tbl_Type(
    p_in_tab   IN  WSH_INTERFACE_EXT_GRP.delivery_details_Attr_tbl_Type,
    x_out_tab  OUT NOCOPY wsh_glbl_var_strct_grp.delivery_details_Attr_tbl_Type,
    p_action   IN  VARCHAR2) IS

  l_entity	VARCHAR2(4):='DLVB';
Begin

for i in 1..p_in_tab.count LOOP
       x_out_tab(i).delivery_detail_id            := handle_missing_info(p_in_tab(i).delivery_detail_id,l_entity,p_action);
       x_out_tab(i).source_code                	  := handle_missing_info(p_in_tab(i).source_code,l_entity,p_action);
       x_out_tab(i).source_header_id           	  := handle_missing_info(p_in_tab(i).source_header_id,l_entity,p_action);
       x_out_tab(i).source_line_id             	  := handle_missing_info(p_in_tab(i).source_line_id,l_entity,p_action);
       x_out_tab(i).customer_id                	  := handle_missing_info(p_in_tab(i).customer_id,l_entity,p_action);
       x_out_tab(i).sold_to_contact_id         	  := handle_missing_info(p_in_tab(i).sold_to_contact_id,l_entity,p_action);
       x_out_tab(i).inventory_item_id          	  := handle_missing_info(p_in_tab(i).inventory_item_id,l_entity,p_action);
       x_out_tab(i).item_description           	  := handle_missing_info(p_in_tab(i).item_description,l_entity,p_action);
       x_out_tab(i).hazard_class_id            	  := handle_missing_info(p_in_tab(i).hazard_class_id,l_entity,p_action);
       x_out_tab(i).country_of_origin          	  := handle_missing_info(p_in_tab(i).country_of_origin,l_entity,p_action);
       x_out_tab(i).classification             	  := handle_missing_info(p_in_tab(i).classification,l_entity,p_action);
       x_out_tab(i).ship_from_location_id      	  := handle_missing_info(p_in_tab(i).ship_from_location_id,l_entity,p_action);
       x_out_tab(i).ship_to_location_id        	  := handle_missing_info(p_in_tab(i).ship_to_location_id,l_entity,p_action);
       x_out_tab(i).ship_to_contact_id         	  := handle_missing_info(p_in_tab(i).ship_to_contact_id,l_entity,p_action);
       x_out_tab(i).ship_to_site_use_id        	  := handle_missing_info(p_in_tab(i).ship_to_site_use_id,l_entity,p_action);
       x_out_tab(i).deliver_to_location_id     	  := handle_missing_info(p_in_tab(i).deliver_to_location_id,l_entity,p_action);
       x_out_tab(i).deliver_to_contact_id      	  := handle_missing_info(p_in_tab(i).deliver_to_contact_id,l_entity,p_action);
       x_out_tab(i).deliver_to_site_use_id     	  := handle_missing_info(p_in_tab(i).deliver_to_site_use_id,l_entity,p_action);
       x_out_tab(i).intmed_ship_to_location_id 	  := handle_missing_info(p_in_tab(i).intmed_ship_to_location_id,l_entity,p_action);
       x_out_tab(i).intmed_ship_to_contact_id  	  := handle_missing_info(p_in_tab(i).intmed_ship_to_contact_id,l_entity,p_action);
       x_out_tab(i).hold_code                  	  := handle_missing_info(p_in_tab(i).hold_code,l_entity,p_action);
       x_out_tab(i).ship_tolerance_above       	  := handle_missing_info(p_in_tab(i).ship_tolerance_above,l_entity,p_action);
       x_out_tab(i).ship_tolerance_below       	  := handle_missing_info(p_in_tab(i).ship_tolerance_below,l_entity,p_action);
       x_out_tab(i).requested_quantity         	  := handle_missing_info(p_in_tab(i).requested_quantity,l_entity,p_action);
       x_out_tab(i).shipped_quantity           	  := handle_missing_info(p_in_tab(i).shipped_quantity,l_entity,p_action);
       x_out_tab(i).delivered_quantity         	  := handle_missing_info(p_in_tab(i).delivered_quantity,l_entity,p_action);
       x_out_tab(i).requested_quantity_uom     	  := handle_missing_info(p_in_tab(i).requested_quantity_uom,l_entity,p_action);
       x_out_tab(i).subinventory               	  := handle_missing_info(p_in_tab(i).subinventory,l_entity,p_action);
       x_out_tab(i).revision                   	  := handle_missing_info(p_in_tab(i).revision,l_entity,p_action);
       x_out_tab(i).lot_number                 	  := handle_missing_info(p_in_tab(i).lot_number ,l_entity,p_action);
       x_out_tab(i).customer_requested_lot_flag	  := handle_missing_info(p_in_tab(i).customer_requested_lot_flag,l_entity,p_action);
       x_out_tab(i).serial_number              	  := handle_missing_info(p_in_tab(i).serial_number,l_entity,p_action);
       x_out_tab(i).locator_id                 	  := handle_missing_info(p_in_tab(i).locator_id ,l_entity,p_action);
       x_out_tab(i).date_requested             	  := handle_missing_info(p_in_tab(i).date_requested,l_entity,p_action);
       x_out_tab(i).date_scheduled             	  := handle_missing_info(p_in_tab(i).date_scheduled,l_entity,p_action);
       x_out_tab(i).master_container_item_id   	  := handle_missing_info(p_in_tab(i).master_container_item_id,l_entity,p_action);
       x_out_tab(i).detail_container_item_id   	  := handle_missing_info(p_in_tab(i).detail_container_item_id,l_entity,p_action);
       x_out_tab(i).detail_container_item_id   	  := handle_missing_info(p_in_tab(i).detail_container_item_id,l_entity,p_action);
       x_out_tab(i).load_seq_number            	  := handle_missing_info(p_in_tab(i).load_seq_number,l_entity,p_action);
       x_out_tab(i).ship_method_code           	  := handle_missing_info(p_in_tab(i).ship_method_code,l_entity,p_action);
       x_out_tab(i).carrier_id                 	  := handle_missing_info(p_in_tab(i).carrier_id ,l_entity,p_action);
       x_out_tab(i).freight_terms_code         	  := handle_missing_info(p_in_tab(i).freight_terms_code,l_entity,p_action);
       x_out_tab(i).shipment_priority_code     	  := handle_missing_info(p_in_tab(i).shipment_priority_code,l_entity,p_action);
       x_out_tab(i).fob_code                   	  := handle_missing_info(p_in_tab(i).fob_code,l_entity,p_action);
       x_out_tab(i).customer_item_id           	  := handle_missing_info(p_in_tab(i).customer_item_id,l_entity,p_action);
       x_out_tab(i).dep_plan_required_flag     	  := handle_missing_info(p_in_tab(i).dep_plan_required_flag,l_entity,p_action);
       x_out_tab(i).customer_prod_seq          	  := handle_missing_info(p_in_tab(i).customer_prod_seq,l_entity,p_action);
       x_out_tab(i).customer_dock_code         	  := handle_missing_info(p_in_tab(i).customer_dock_code,l_entity,p_action);
       x_out_tab(i).cust_model_serial_number   	  := handle_missing_info(p_in_tab(i).cust_model_serial_number,l_entity,p_action);
       x_out_tab(i).customer_job               	  := handle_missing_info(p_in_tab(i).customer_job,l_entity,p_action);
       x_out_tab(i).customer_production_line   	  := handle_missing_info(p_in_tab(i).customer_production_line,l_entity,p_action);
       x_out_tab(i).net_weight                 	  := handle_missing_info(p_in_tab(i).net_weight ,l_entity,p_action);
       x_out_tab(i).weight_uom_code            	  := handle_missing_info(p_in_tab(i).weight_uom_code,l_entity,p_action);
       x_out_tab(i).volume                     	  := handle_missing_info(p_in_tab(i).volume  ,l_entity,p_action);
       x_out_tab(i).volume_uom_code            	  := handle_missing_info(p_in_tab(i).volume_uom_code,l_entity,p_action);
       x_out_tab(i).tp_attribute_category      	  := handle_missing_info(p_in_tab(i).tp_attribute_category,l_entity,p_action);
       x_out_tab(i).tp_attribute1              	  := handle_missing_info(p_in_tab(i).tp_attribute1,l_entity,p_action);
       x_out_tab(i).tp_attribute2              	  := handle_missing_info(p_in_tab(i).tp_attribute2,l_entity,p_action);
       x_out_tab(i).tp_attribute3              	  := handle_missing_info(p_in_tab(i).tp_attribute3,l_entity,p_action);
       x_out_tab(i).tp_attribute4              	  := handle_missing_info(p_in_tab(i).tp_attribute4,l_entity,p_action);
       x_out_tab(i).tp_attribute5              	  := handle_missing_info(p_in_tab(i).tp_attribute5,l_entity,p_action);
       x_out_tab(i).tp_attribute6              	  := handle_missing_info(p_in_tab(i).tp_attribute6,l_entity,p_action);
       x_out_tab(i).tp_attribute7              	  := handle_missing_info(p_in_tab(i).tp_attribute7,l_entity,p_action);
       x_out_tab(i).tp_attribute8              	  := handle_missing_info(p_in_tab(i).tp_attribute8,l_entity,p_action);
       x_out_tab(i).tp_attribute9              	  := handle_missing_info(p_in_tab(i).tp_attribute9,l_entity,p_action);
       x_out_tab(i).tp_attribute10             	  := handle_missing_info(p_in_tab(i).tp_attribute10,l_entity,p_action);
       x_out_tab(i).tp_attribute11             	  := handle_missing_info(p_in_tab(i).tp_attribute11,l_entity,p_action);
       x_out_tab(i).tp_attribute12             	  := handle_missing_info(p_in_tab(i).tp_attribute12,l_entity,p_action);
       x_out_tab(i).tp_attribute13             	  := handle_missing_info(p_in_tab(i).tp_attribute13,l_entity,p_action);
       x_out_tab(i).tp_attribute14             	  := handle_missing_info(p_in_tab(i).tp_attribute14,l_entity,p_action);
       x_out_tab(i).tp_attribute15             	  := handle_missing_info(p_in_tab(i).tp_attribute15,l_entity,p_action);
       x_out_tab(i).attribute_category         	  := handle_missing_info(p_in_tab(i).attribute_category,l_entity,p_action);
       x_out_tab(i).attribute1                 	  := handle_missing_info(p_in_tab(i).attribute1 ,l_entity,p_action);
       x_out_tab(i).attribute2                 	  := handle_missing_info(p_in_tab(i).attribute2 ,l_entity,p_action);
       x_out_tab(i).attribute3                 	  := handle_missing_info(p_in_tab(i).attribute3 ,l_entity,p_action);
       x_out_tab(i).attribute3                 	  := handle_missing_info(p_in_tab(i).attribute3 ,l_entity,p_action);
       x_out_tab(i).attribute4                 	  := handle_missing_info(p_in_tab(i).attribute4 ,l_entity,p_action);
       x_out_tab(i).attribute5                 	  := handle_missing_info(p_in_tab(i).attribute5 ,l_entity,p_action);
       x_out_tab(i).attribute6                 	  := handle_missing_info(p_in_tab(i).attribute6 ,l_entity,p_action);
       x_out_tab(i).attribute7                 	  := handle_missing_info(p_in_tab(i).attribute7 ,l_entity,p_action);
       x_out_tab(i).attribute8                 	  := handle_missing_info(p_in_tab(i).attribute8 ,l_entity,p_action);
       x_out_tab(i).attribute9                 	  := handle_missing_info(p_in_tab(i).attribute9 ,l_entity,p_action);
       x_out_tab(i).attribute10                	  := handle_missing_info(p_in_tab(i).attribute10,l_entity,p_action);
       x_out_tab(i).attribute11                	  := handle_missing_info(p_in_tab(i).attribute11,l_entity,p_action);
       x_out_tab(i).attribute12                	  := handle_missing_info(p_in_tab(i).attribute12,l_entity,p_action);
       x_out_tab(i).attribute13                	  := handle_missing_info(p_in_tab(i).attribute13,l_entity,p_action);
       x_out_tab(i).attribute14                	  := handle_missing_info(p_in_tab(i).attribute14,l_entity,p_action);
       x_out_tab(i).attribute15                	  := handle_missing_info(p_in_tab(i).attribute15,l_entity,p_action);
       x_out_tab(i).created_by                 	  := handle_missing_info(p_in_tab(i).created_by ,l_entity,p_action);
       x_out_tab(i).creation_date              	  := handle_missing_info(p_in_tab(i).creation_date,l_entity,p_action);
       x_out_tab(i).last_update_date           	  := handle_missing_info(p_in_tab(i).last_update_date,l_entity,p_action);
       x_out_tab(i).last_update_login          	  := handle_missing_info(p_in_tab(i).last_update_login,l_entity,p_action);
       x_out_tab(i).last_updated_by            	  := handle_missing_info(p_in_tab(i).last_updated_by,l_entity,p_action);
       x_out_tab(i).program_application_id     	  := handle_missing_info(p_in_tab(i).program_application_id,l_entity,p_action);
       x_out_tab(i).program_id                 	  := handle_missing_info(p_in_tab(i).program_id ,l_entity,p_action);
       x_out_tab(i).program_update_date        	  := handle_missing_info(p_in_tab(i).program_update_date,l_entity,p_action);
       x_out_tab(i).request_id                 	  := handle_missing_info(p_in_tab(i).request_id ,l_entity,p_action);
       x_out_tab(i).mvt_stat_status            	  := handle_missing_info(p_in_tab(i).mvt_stat_status,l_entity,p_action);
       x_out_tab(i).released_flag              	  := handle_missing_info(p_in_tab(i).released_flag,l_entity,p_action);
       x_out_tab(i).organization_id            	  := handle_missing_info(p_in_tab(i).organization_id,l_entity,p_action);
       x_out_tab(i).transaction_temp_id        	  := handle_missing_info(p_in_tab(i).transaction_temp_id,l_entity,p_action);
       x_out_tab(i).ship_set_id                	  := handle_missing_info(p_in_tab(i).ship_set_id,l_entity,p_action);
       x_out_tab(i).arrival_set_id             	  := handle_missing_info(p_in_tab(i).arrival_set_id,l_entity,p_action);
       x_out_tab(i).ship_model_complete_flag   	  := handle_missing_info(p_in_tab(i).ship_model_complete_flag,l_entity,p_action);
       x_out_tab(i).top_model_line_id          	  := handle_missing_info(p_in_tab(i).top_model_line_id,l_entity,p_action);
       x_out_tab(i).source_header_number       	  := handle_missing_info(p_in_tab(i).source_header_number,l_entity,p_action);
       x_out_tab(i).source_header_type_id      	  := handle_missing_info(p_in_tab(i).source_header_type_id,l_entity,p_action);
       x_out_tab(i).source_header_type_name    	  := handle_missing_info(p_in_tab(i).source_header_type_name,l_entity,p_action);
       x_out_tab(i).cust_po_number             	  := handle_missing_info(p_in_tab(i).cust_po_number,l_entity,p_action);
       x_out_tab(i).ato_line_id                	  := handle_missing_info(p_in_tab(i).ato_line_id,l_entity,p_action);
       x_out_tab(i).src_requested_quantity     	  := handle_missing_info(p_in_tab(i).src_requested_quantity,l_entity,p_action);
       x_out_tab(i).src_requested_quantity_uom 	  := handle_missing_info(p_in_tab(i).src_requested_quantity_uom,l_entity,p_action);
       x_out_tab(i).move_order_line_id         	  := handle_missing_info(p_in_tab(i).move_order_line_id,l_entity,p_action);
       x_out_tab(i).cancelled_quantity         	  := handle_missing_info(p_in_tab(i).cancelled_quantity,l_entity,p_action);
       x_out_tab(i).quality_control_quantity   	  := handle_missing_info(p_in_tab(i).quality_control_quantity,l_entity,p_action);
       x_out_tab(i).cycle_count_quantity       	  := handle_missing_info(p_in_tab(i).cycle_count_quantity,l_entity,p_action);
       x_out_tab(i).tracking_number            	  := handle_missing_info(p_in_tab(i).tracking_number,l_entity,p_action);
       x_out_tab(i).movement_id                	  := handle_missing_info(p_in_tab(i).movement_id,l_entity,p_action);
       x_out_tab(i).shipping_instructions      	  := handle_missing_info(p_in_tab(i).shipping_instructions,l_entity,p_action);
       x_out_tab(i).packing_instructions       	  := handle_missing_info(p_in_tab(i).packing_instructions,l_entity,p_action);
       x_out_tab(i).project_id                 	  := handle_missing_info(p_in_tab(i).project_id ,l_entity,p_action);
       x_out_tab(i).task_id                    	  := handle_missing_info(p_in_tab(i).task_id ,l_entity,p_action);
       x_out_tab(i).org_id                     	  := handle_missing_info(p_in_tab(i).org_id  ,l_entity,p_action);
       x_out_tab(i).oe_interfaced_flag         	  := handle_missing_info(p_in_tab(i).oe_interfaced_flag,l_entity,p_action);
       x_out_tab(i).split_from_detail_id       	  := handle_missing_info(p_in_tab(i).split_from_detail_id,l_entity,p_action);
       x_out_tab(i).inv_interfaced_flag        	  := handle_missing_info(p_in_tab(i).inv_interfaced_flag,l_entity,p_action);
       x_out_tab(i).source_line_number         	  := handle_missing_info(p_in_tab(i).source_line_number,l_entity,p_action);
       x_out_tab(i).inspection_flag            	  := handle_missing_info(p_in_tab(i).inspection_flag,l_entity,p_action);
       x_out_tab(i).released_status            	  := handle_missing_info(p_in_tab(i).released_status,l_entity,p_action);
       x_out_tab(i).container_flag             	  := handle_missing_info(p_in_tab(i).container_flag,l_entity,p_action);
       x_out_tab(i).container_type_code        	  := handle_missing_info(p_in_tab(i).container_type_code,l_entity,p_action);
       x_out_tab(i).container_name             	  := handle_missing_info(p_in_tab(i).container_name,l_entity,p_action);
       x_out_tab(i).fill_percent               	  := handle_missing_info(p_in_tab(i).fill_percent,l_entity,p_action);
       x_out_tab(i).gross_weight               	  := handle_missing_info(p_in_tab(i).gross_weight,l_entity,p_action);
       x_out_tab(i).master_serial_number       	  := handle_missing_info(p_in_tab(i).master_serial_number,l_entity,p_action);
       x_out_tab(i).maximum_load_weight        	  := handle_missing_info(p_in_tab(i).maximum_load_weight,l_entity,p_action);
       x_out_tab(i).maximum_volume             	  := handle_missing_info(p_in_tab(i).maximum_volume,l_entity,p_action);
       x_out_tab(i).minimum_fill_percent       	  := handle_missing_info(p_in_tab(i).minimum_fill_percent,l_entity,p_action);
       x_out_tab(i).seal_code                  	  := handle_missing_info(p_in_tab(i).seal_code,l_entity,p_action);
       x_out_tab(i).unit_number                	  := handle_missing_info(p_in_tab(i).unit_number,l_entity,p_action);
       x_out_tab(i).unit_price                 	  := handle_missing_info(p_in_tab(i).unit_price ,l_entity,p_action);
       x_out_tab(i).currency_code              	  := handle_missing_info(p_in_tab(i).currency_code,l_entity,p_action);
       x_out_tab(i).freight_class_cat_id       	  := handle_missing_info(p_in_tab(i).freight_class_cat_id,l_entity,p_action);
       x_out_tab(i).commodity_code_cat_id      	  := handle_missing_info(p_in_tab(i).commodity_code_cat_id,l_entity,p_action);
       x_out_tab(i).preferred_grade            	  := handle_missing_info(p_in_tab(i).preferred_grade,l_entity,p_action);
       x_out_tab(i).src_requested_quantity2    	  := handle_missing_info(p_in_tab(i).src_requested_quantity2,l_entity,p_action);
       x_out_tab(i).src_requested_quantity_uom2	  := handle_missing_info(p_in_tab(i).src_requested_quantity_uom2,l_entity,p_action);
       x_out_tab(i).requested_quantity2        	  := handle_missing_info(p_in_tab(i).requested_quantity2,l_entity,p_action);
       x_out_tab(i).shipped_quantity2          	  := handle_missing_info(p_in_tab(i).shipped_quantity2,l_entity,p_action);
       x_out_tab(i).delivered_quantity2        	  := handle_missing_info(p_in_tab(i).delivered_quantity2,l_entity,p_action);
       x_out_tab(i).cancelled_quantity2        	  := handle_missing_info(p_in_tab(i).cancelled_quantity2,l_entity,p_action);
       x_out_tab(i).quality_control_quantity2  	  := handle_missing_info(p_in_tab(i).quality_control_quantity2,l_entity,p_action);
       x_out_tab(i).cycle_count_quantity2      	  := handle_missing_info(p_in_tab(i).cycle_count_quantity2,l_entity,p_action);
       x_out_tab(i).requested_quantity_uom2    	  := handle_missing_info(p_in_tab(i).requested_quantity_uom2,l_entity,p_action);
-- HW OPMCONV. No need for sublot anymore
--     x_out_tab(i).sublot_number              	  := handle_missing_info(p_in_tab(i).sublot_number ,l_entity,p_action);
       x_out_tab(i).lpn_id                     	  := handle_missing_info(p_in_tab(i).lpn_id     ,l_entity,p_action);
       x_out_tab(i).pickable_flag              	  := handle_missing_info(p_in_tab(i).pickable_flag,l_entity,p_action);
       x_out_tab(i).original_subinventory      	  := handle_missing_info(p_in_tab(i).original_subinventory,l_entity,p_action);
       x_out_tab(i).to_serial_number           	  := handle_missing_info(p_in_tab(i).to_serial_number,l_entity,p_action);
       x_out_tab(i).picked_quantity            	  := handle_missing_info(p_in_tab(i).picked_quantity,l_entity,p_action);
       x_out_tab(i).picked_quantity2           	  := handle_missing_info(p_in_tab(i).picked_quantity2,l_entity,p_action);
       x_out_tab(i).received_quantity          	  := handle_missing_info(p_in_tab(i).received_quantity,l_entity,p_action);
       x_out_tab(i).received_quantity2         	  := handle_missing_info(p_in_tab(i).received_quantity2,l_entity,p_action);
       x_out_tab(i).source_line_set_id         	  := handle_missing_info(p_in_tab(i).source_line_set_id,l_entity,p_action);
       -- X-dock requirement
       x_out_tab(i).batch_id         	          := handle_missing_info(p_in_tab(i).batch_id,l_entity,p_action);
       --bug# 6689448 (replenishment project)
       x_out_tab(i).replenishment_status          := handle_missing_info(p_in_tab(i).replenishment_status,l_entity,p_action);

END LOOP;
End map_det_Attr_tbl_Type;

Procedure Map_detailInRecType(
  p_in_rec  IN WSH_INTERFACE_EXT_GRP.detailInRecType,
  x_out_rec OUT NOCOPY wsh_glbl_var_strct_grp.detailInRecType) IS

Begin

             x_out_rec.caller                   :=  p_in_rec.caller             ;
             x_out_rec.action_code         	:=  p_in_rec.action_code        ;
             x_out_rec.phase               	:=  p_in_rec.phase              ;
             x_out_rec.container_item_id   	:=  p_in_rec.container_item_id  ;
             x_out_rec.container_item_name 	:=  p_in_rec.container_item_name;
             x_out_rec.container_item_seg  	:=  p_in_rec.container_item_seg ;
             x_out_rec.organization_id     	:=  p_in_rec.organization_id    ;
             x_out_rec.organization_code   	:=  p_in_rec.organization_code  ;
             x_out_rec.name_prefix         	:=  p_in_rec.name_prefix        ;
             x_out_rec.name_suffix         	:=  p_in_rec.name_suffix        ;
             x_out_rec.base_number         	:=  p_in_rec.base_number        ;
             x_out_rec.num_digits          	:=  p_in_rec.num_digits         ;
             x_out_rec.quantity            	:=  p_in_rec.quantity           ;
             x_out_rec.container_name      	:=  p_in_rec.container_name     ;
             x_out_rec.lpn_ids             	:=  p_in_rec.lpn_ids            ;

End Map_detailInRecType;

Procedure Map_detailOutRecType(
   p_in_rec    IN   wsh_glbl_var_strct_grp.detailOutRecType,
   x_out_rec   OUT  NOCOPY WSH_INTERFACE_EXT_GRP.detailOutRecType) IS

BEGIN

   x_out_rec.detail_ids :=  p_in_rec.detail_ids;

END Map_detailOutRecType;


    -- ---------------------------------------------------------------------
    -- Procedure:	Create_Update_Delivery_Detail	Wrapper API
    --
    -- Parameters:
    --
    -- Description:  This procedure is the new API for wrapping the logic of CREATE/UPDATE of delivery details
    -- Created    : Patchset I - Harmonization Project
    -- Created By : KVENKATE
    -- -----------------------------------------------------------------------

    PROCEDURE Create_Update_Delivery_Detail
    (
       -- Standard Parameters
       p_api_version_number	 IN	 NUMBER,
       p_init_msg_list           IN 	 VARCHAR2,
       p_commit                  IN 	 VARCHAR2,
       x_return_status           OUT NOCOPY	 VARCHAR2,
       x_msg_count               OUT NOCOPY	 NUMBER,
       x_msg_data                OUT NOCOPY	 VARCHAR2,

       -- Procedure Specific Parameters
       p_detail_info_tab         IN 	WSH_INTERFACE_EXT_GRP.delivery_details_Attr_tbl_Type,
       p_IN_rec                  IN  	WSH_INTERFACE_EXT_GRP.detailInRecType,
       x_OUT_rec                 OUT NOCOPY	WSH_INTERFACE_EXT_GRP.detailOutRecType
    ) IS

       l_det_Attr_tbl_Type  wsh_glbl_var_strct_grp.delivery_details_Attr_tbl_Type;
       l_detailInRecType                 wsh_glbl_var_strct_grp.detailInRecType;
       l_detailOutRecType                wsh_glbl_var_strct_grp.detailOutRecType;

  BEGIN

    --bug # 6689448 (replenishment project): Valid values for replenishment flag are FND_API.G_MISS_CHAR/NULL/R/C only.
    FOR i IN 1..p_detail_info_tab.COUNT LOOP
    --{
        IF ( (p_detail_info_tab(i).replenishment_status <> FND_API.G_MISS_CHAR)
             AND (p_detail_info_tab(i).replenishment_status IS NOT NULL)
             AND (p_detail_info_tab(i).replenishment_status <> 'R')
             AND (p_detail_info_tab(i).replenishment_status <> 'C') )THEN
        --{
            FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','replenishment_status');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            wsh_util_core.add_message(x_return_status);
            return;
        --}
        END IF;
    --}
    END LOOP;
    --bug # 6689448 (replenishment project): end

    map_det_Attr_tbl_Type(p_detail_info_tab, l_det_Attr_tbl_Type,p_IN_rec.action_code);
    Map_detailInRecType(p_IN_rec, l_detailInRecType);

    WSH_INTERFACE_GRP.Create_Update_Delivery_Detail (
       -- Standard Parameters
       p_api_version_number      =>      p_api_version_number,
       p_init_msg_list           =>      p_init_msg_list,
       p_commit                  =>      p_commit,
       x_return_status           =>      x_return_status,
       x_msg_count               =>      x_msg_count,
       x_msg_data                =>      x_msg_data,

       -- Procedure Specific Parameters
       p_detail_info_tab         =>     l_det_Attr_tbl_Type,
       p_IN_rec                  =>     l_detailInRecType,
       x_OUT_rec                 =>     l_detailOutRecType
    );

   Map_detailOutRecType(l_detailOutRecType,x_OUT_rec);

--
  EXCEPTION
        WHEN OTHERS THEN
               WSH_UTIL_CORE.default_handler('WSH_INTERFACE_EXT_GRP.Create_Update_Delivery_Detail');
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  END Create_Update_Delivery_Detail;


Procedure Map_trip_act_params_rectype(
  p_in_rec   IN  WSH_INTERFACE_EXT_GRP.trip_action_parameters_rectype,
  x_out_rec  OUT NOCOPY WSH_TRIPS_GRP.action_parameters_rectype) IS

Begin


   x_out_rec.caller                              := p_in_rec.caller  ;
   x_out_rec.phase                               := p_in_rec.phase        ;
   x_out_rec.action_code                         := p_in_rec.action_code    ;
   x_out_rec.organization_id                     := p_in_rec.organization_id  ;
   x_out_rec.report_set_id                       := p_in_rec.report_set_id   ;
   x_out_rec.override_flag                       := p_in_rec.override_flag  ;
   x_out_rec.trip_name                           := p_in_rec.trip_name      ;
   x_out_rec.actual_date                         := p_in_rec.actual_date ;
   x_out_rec.stop_id                             := p_in_rec.stop_id         ;
   x_out_rec.action_flag                         := p_in_rec.action_flag   ;
   x_out_rec.autointransit_flag                  := p_in_rec.autointransit_flag      ;
   x_out_rec.autoclose_flag                      := p_in_rec.autoclose_flag   ;
   x_out_rec.stage_del_flag                      := p_in_rec.stage_del_flag  ;
   x_out_rec.ship_method                         := p_in_rec.ship_method  ;
   x_out_rec.bill_of_lading_flag                 := p_in_rec.bill_of_lading_flag    ;
   x_out_rec.defer_interface_flag                := p_in_rec.defer_interface_flag  ;
   x_out_rec.actual_departure_date               := p_in_rec.actual_departure_date   ;


End Map_trip_act_params_rectype;


Procedure map_tripActionOutRecType(
  p_in_rec   IN  WSH_TRIPS_GRP.tripActionOutRecType,
  x_out_rec  OUT NOCOPY WSH_INTERFACE_EXT_GRP.tripActionOutRecType) IS

Begin

          x_out_rec.result_id_tab               := p_in_rec.result_id_tab       ;
          x_out_rec.valid_ids_tab            	:= p_in_rec.valid_ids_tab      ;
          x_out_rec.selection_issue_flag     	:= p_in_rec.selection_issue_flag;

End map_tripActionOutRecType;



/*------------------------------------------------------------
  PROCEDURE Trip_Action  This is the wrapper for the
            Trip action
-------------------------------------------------------------*/

PROCEDURE Trip_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2,
    p_entity_id_tab          IN   wsh_util_core.id_tab_type,
    p_action_prms            IN   WSH_INTERFACE_EXT_GRP.trip_action_parameters_rectype,
    x_trip_out_rec           OUT  NOCOPY WSH_INTERFACE_EXT_GRP.tripActionOutRecType,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2)
IS

    l_trip_act_params_rectype  WSH_TRIPS_GRP.action_parameters_rectype;
    l_tripActionOutRecType            WSH_TRIPS_GRP.tripActionOutRecType;

BEGIN
   --
    Map_trip_act_params_rectype(p_action_prms, l_trip_act_params_rectype);

    WSH_INTERFACE_GRP.Trip_Action(
    p_api_version_number     =>   p_api_version_number,
    p_init_msg_list          =>   p_init_msg_list,
    p_commit                 =>   p_commit,
    p_entity_id_tab          =>   p_entity_id_tab,
    p_action_prms            =>   l_trip_act_params_rectype,
    x_trip_out_rec           =>   l_tripActionOutRecType,
    x_return_status          =>   x_return_status,
    x_msg_count              =>   x_msg_count,
    x_msg_data               =>   x_msg_data);

    map_tripActionOutRecType(l_tripActionOutRecType, x_trip_out_rec);

EXCEPTION
   WHEN OTHERS THEN
     wsh_util_core.default_handler('WSH_TRIPS_GRP.TRIP_ACTION');

      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

END Trip_Action;


Procedure map_stop_act_params_rectype(
  p_in_rec   IN   WSH_INTERFACE_EXT_GRP.stop_action_parameters_rectype,
  x_out_rec  OUT  NOCOPY WSH_TRIP_STOPS_GRP.action_parameters_rectype) IS

Begin

        x_out_rec.caller                      := p_in_rec.caller                   ;
        x_out_rec.phase                       := p_in_rec.phase                    ;
        x_out_rec.action_code                 := p_in_rec.action_code              ;
        x_out_rec.stop_action                 := p_in_rec.stop_action              ;
        x_out_rec.organization_id             := p_in_rec.organization_id          ;
        x_out_rec.actual_date                 := p_in_rec.actual_date              ;
        x_out_rec.defer_interface_flag        := p_in_rec.defer_interface_flag     ;
        x_out_rec.report_set_id               := p_in_rec.report_set_id            ;
        x_out_rec.override_flag               := p_in_rec.override_flag            ;

End map_stop_act_params_rectype;


Procedure map_stopActionOutRecType(
   p_in_rec    IN   WSH_TRIP_STOPS_GRP.stopActionOutRecType,
   x_out_rec   OUT  NOCOPY WSH_INTERFACE_EXT_GRP.stopActionOutRecType) IS

Begin

   x_out_rec.result_id_tab            := p_in_rec.result_id_tab       ;
   x_out_rec.valid_ids_tab            := p_in_rec.valid_ids_tab       ;
   x_out_rec.selection_issue_flag     := p_in_rec.selection_issue_flag;

End map_stopActionOutRecType;

/*------------------------------------------------------------
  PROCEDURE Stop_Action  This is the wrapper for the
            stop action
-------------------------------------------------------------*/
PROCEDURE Stop_Action
(   p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2,
    p_entity_id_tab          IN   wsh_util_core.id_tab_type,
    p_action_prms            IN   WSH_INTERFACE_EXT_GRP.stop_action_parameters_rectype,
    x_stop_out_rec           OUT  NOCOPY WSH_INTERFACE_EXT_GRP.stopActionOutRecType,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2)
IS

    l_stop_act_params_rectype     WSH_TRIP_STOPS_GRP.action_parameters_rectype;
    l_stopActionOutRecType               WSH_TRIP_STOPS_GRP.stopActionOutRecType;

BEGIN
   --
   map_stop_act_params_rectype(p_action_prms, l_stop_act_params_rectype);


   WSH_INTERFACE_GRP.Stop_Action(
    p_api_version_number     =>   p_api_version_number,
    p_init_msg_list          =>   p_init_msg_list,
    p_commit                 =>   p_commit,
    p_entity_id_tab          =>   p_entity_id_tab,
    p_action_prms            =>   l_stop_act_params_rectype,
    x_stop_out_rec           =>   l_stopActionOutRecType,
    x_return_status          =>   x_return_status,
    x_msg_count              =>   x_msg_count,
    x_msg_data               =>   x_msg_data);

  map_stopActionOutRecType(l_stopActionOutRecType, x_stop_out_rec);

EXCEPTION
   WHEN OTHERS THEN
     wsh_util_core.default_handler('WSH_TRIP_STOPS_GRP.STOP_ACTION');

      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

END Stop_Action;

--heali


Procedure Map_stopInRecType(
  p_in_rec    IN   WSH_INTERFACE_EXT_GRP.stopInRecType,
  x_out_rec   OUT  NOCOPY WSH_TRIP_STOPS_GRP.stopInRecType)  IS

Begin

  x_out_rec.caller         := p_in_rec.caller     ;
  x_out_rec.phase          := p_in_rec.phase      ;
  x_out_rec.action_code    := p_in_rec.action_code;

END Map_stopInRecType;


Procedure map_Stop_Attr_Tbl_Type(
  p_in_tab   IN   WSH_INTERFACE_EXT_GRP.Stop_Attr_Tbl_Type,
  x_out_tab  OUT  NOCOPY WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type) IS

Begin


for i in 1..p_in_tab.count LOOP
x_out_tab(i).STOP_ID                         := handle_missing_info(p_in_tab(i).STOP_ID);
x_out_tab(i).TRIP_ID                         := handle_missing_info(p_in_tab(i).TRIP_ID);
x_out_tab(i).STOP_LOCATION_ID                := handle_missing_info(p_in_tab(i).STOP_LOCATION_ID);
x_out_tab(i).STATUS_CODE                     := handle_missing_info(p_in_tab(i).STATUS_CODE);
x_out_tab(i).STOP_SEQUENCE_NUMBER            := handle_missing_info(p_in_tab(i).STOP_SEQUENCE_NUMBER);
x_out_tab(i).PLANNED_ARRIVAL_DATE            := handle_missing_info(p_in_tab(i).PLANNED_ARRIVAL_DATE);
x_out_tab(i).PLANNED_DEPARTURE_DATE          := handle_missing_info(p_in_tab(i).PLANNED_DEPARTURE_DATE);
x_out_tab(i).ACTUAL_ARRIVAL_DATE             := handle_missing_info(p_in_tab(i).ACTUAL_ARRIVAL_DATE);
x_out_tab(i).ACTUAL_DEPARTURE_DATE           := handle_missing_info(p_in_tab(i).ACTUAL_DEPARTURE_DATE);
x_out_tab(i).DEPARTURE_GROSS_WEIGHT          := handle_missing_info(p_in_tab(i).DEPARTURE_GROSS_WEIGHT);
x_out_tab(i).DEPARTURE_NET_WEIGHT            := handle_missing_info(p_in_tab(i).DEPARTURE_NET_WEIGHT);
x_out_tab(i).WEIGHT_UOM_CODE                 := handle_missing_info(p_in_tab(i).WEIGHT_UOM_CODE);
x_out_tab(i).DEPARTURE_VOLUME                := handle_missing_info(p_in_tab(i).DEPARTURE_VOLUME);
x_out_tab(i).VOLUME_UOM_CODE                 := handle_missing_info(p_in_tab(i).VOLUME_UOM_CODE);
x_out_tab(i).DEPARTURE_SEAL_CODE             := handle_missing_info(p_in_tab(i).DEPARTURE_SEAL_CODE);
x_out_tab(i).DEPARTURE_FILL_PERCENT          := handle_missing_info(p_in_tab(i).DEPARTURE_FILL_PERCENT);
x_out_tab(i).TP_ATTRIBUTE_CATEGORY           := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE_CATEGORY);
x_out_tab(i).TP_ATTRIBUTE1                   := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE1);
x_out_tab(i).TP_ATTRIBUTE2                   := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE2);
x_out_tab(i).TP_ATTRIBUTE3                   := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE3);
x_out_tab(i).TP_ATTRIBUTE4                   := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE4);
x_out_tab(i).TP_ATTRIBUTE5                   := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE5);
x_out_tab(i).TP_ATTRIBUTE6                   := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE6);
x_out_tab(i).TP_ATTRIBUTE7                   := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE7);
x_out_tab(i).TP_ATTRIBUTE8                   := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE8);
x_out_tab(i).TP_ATTRIBUTE9                   := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE9);
x_out_tab(i).TP_ATTRIBUTE10                  := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE10);
x_out_tab(i).TP_ATTRIBUTE11                  := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE11);
x_out_tab(i).TP_ATTRIBUTE12                  := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE12);
x_out_tab(i).TP_ATTRIBUTE13                  := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE13);
x_out_tab(i).TP_ATTRIBUTE14                  := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE14);
x_out_tab(i).TP_ATTRIBUTE15                  := handle_missing_info(p_in_tab(i).TP_ATTRIBUTE15);
x_out_tab(i).ATTRIBUTE_CATEGORY              := handle_missing_info(p_in_tab(i).ATTRIBUTE_CATEGORY);
x_out_tab(i).ATTRIBUTE1                      := handle_missing_info(p_in_tab(i).ATTRIBUTE1);
x_out_tab(i).ATTRIBUTE2                      := handle_missing_info(p_in_tab(i).ATTRIBUTE2);
x_out_tab(i).ATTRIBUTE3                      := handle_missing_info(p_in_tab(i).ATTRIBUTE3);
x_out_tab(i).ATTRIBUTE4                      := handle_missing_info(p_in_tab(i).ATTRIBUTE4);
x_out_tab(i).ATTRIBUTE5                      := handle_missing_info(p_in_tab(i).ATTRIBUTE5);
x_out_tab(i).ATTRIBUTE6                      := handle_missing_info(p_in_tab(i).ATTRIBUTE6);
x_out_tab(i).ATTRIBUTE7                      := handle_missing_info(p_in_tab(i).ATTRIBUTE7);
x_out_tab(i).ATTRIBUTE8                      := handle_missing_info(p_in_tab(i).ATTRIBUTE8);
x_out_tab(i).ATTRIBUTE9                      := handle_missing_info(p_in_tab(i).ATTRIBUTE9);
x_out_tab(i).ATTRIBUTE10                     := handle_missing_info(p_in_tab(i).ATTRIBUTE10);
x_out_tab(i).ATTRIBUTE11                     := handle_missing_info(p_in_tab(i).ATTRIBUTE11);
x_out_tab(i).ATTRIBUTE12                     := handle_missing_info(p_in_tab(i).ATTRIBUTE12);
x_out_tab(i).ATTRIBUTE13                     := handle_missing_info(p_in_tab(i).ATTRIBUTE13);
x_out_tab(i).ATTRIBUTE14                     := handle_missing_info(p_in_tab(i).ATTRIBUTE14);
x_out_tab(i).ATTRIBUTE15                     := handle_missing_info(p_in_tab(i).ATTRIBUTE15);
x_out_tab(i).CREATION_DATE                   := handle_missing_info(p_in_tab(i).CREATION_DATE);
x_out_tab(i).CREATED_BY                      := handle_missing_info(p_in_tab(i).CREATED_BY);
x_out_tab(i).LAST_UPDATE_DATE                := handle_missing_info(p_in_tab(i).LAST_UPDATE_DATE);
x_out_tab(i).LAST_UPDATED_BY                 := handle_missing_info(p_in_tab(i).LAST_UPDATED_BY);
x_out_tab(i).LAST_UPDATE_LOGIN               := handle_missing_info(p_in_tab(i).LAST_UPDATE_LOGIN);
x_out_tab(i).PROGRAM_APPLICATION_ID          := handle_missing_info(p_in_tab(i).PROGRAM_APPLICATION_ID);
x_out_tab(i).PROGRAM_ID                      := handle_missing_info(p_in_tab(i).PROGRAM_ID);
x_out_tab(i).PROGRAM_UPDATE_DATE             := handle_missing_info(p_in_tab(i).PROGRAM_UPDATE_DATE);
x_out_tab(i).REQUEST_ID                      := handle_missing_info(p_in_tab(i).REQUEST_ID);
x_out_tab(i).WSH_LOCATION_ID                 := handle_missing_info(p_in_tab(i).WSH_LOCATION_ID);
x_out_tab(i).TRACKING_DRILLDOWN_FLAG         := handle_missing_info(p_in_tab(i).TRACKING_DRILLDOWN_FLAG);
x_out_tab(i).TRACKING_REMARKS                := handle_missing_info(p_in_tab(i).TRACKING_REMARKS);
x_out_tab(i).CARRIER_EST_DEPARTURE_DATE      := handle_missing_info(p_in_tab(i).CARRIER_EST_DEPARTURE_DATE);
x_out_tab(i).CARRIER_EST_ARRIVAL_DATE        := handle_missing_info(p_in_tab(i).CARRIER_EST_ARRIVAL_DATE);
x_out_tab(i).LOADING_START_DATETIME          := handle_missing_info(p_in_tab(i).LOADING_START_DATETIME);
x_out_tab(i).LOADING_END_DATETIME            := handle_missing_info(p_in_tab(i).LOADING_END_DATETIME);
x_out_tab(i).UNLOADING_START_DATETIME        := handle_missing_info(p_in_tab(i).UNLOADING_START_DATETIME);
x_out_tab(i).UNLOADING_END_DATETIME          := handle_missing_info(p_in_tab(i).UNLOADING_END_DATETIME);
x_out_tab(i).ROWID                           := p_in_tab(i).ROWID;
x_out_tab(i).TRIP_NAME                       := handle_missing_info(p_in_tab(i).TRIP_NAME);
x_out_tab(i).STOP_LOCATION_CODE              := handle_missing_info(p_in_tab(i).STOP_LOCATION_CODE);
x_out_tab(i).WEIGHT_UOM_DESC                 := handle_missing_info(p_in_tab(i).WEIGHT_UOM_DESC);
x_out_tab(i).VOLUME_UOM_DESC                 := handle_missing_info(p_in_tab(i).VOLUME_UOM_DESC);
x_out_tab(i).LOCK_STOP_ID                    := handle_missing_info(p_in_tab(i).LOCK_STOP_ID);
x_out_tab(i).PENDING_INTERFACE_FLAG          := handle_missing_info(p_in_tab(i).PENDING_INTERFACE_FLAG);
x_out_tab(i).TRANSACTION_HEADER_ID           := handle_missing_info(p_in_tab(i).TRANSACTION_HEADER_ID);

END LOOP;

End Map_Stop_Attr_Tbl_Type;

Procedure map_stop_out_tab_type(
  p_in_tab   IN  WSH_TRIP_STOPS_GRP.stop_out_tab_type,
  x_out_tab  OUT NOCOPY WSH_INTERFACE_EXT_GRP.stop_out_tab_type) IS

Begin

for i in 1..p_in_tab.count LOOP
  x_out_tab(i).parameter1    :=  p_in_tab(i).parameter1 ;
  x_out_tab(i).rowid         :=  p_in_tab(i).rowid     ;
  x_out_tab(i).stop_id       :=  p_in_tab(i).stop_id  ;

END LOOP;
End map_stop_out_tab_type;


--========================================================================
-- PROCEDURE : Create_Update_Stop      Wrapper  API
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_commit                'T'/'F'
--             p_in_rec                stopInRecType
--             p_rec_attr_tab          Table of Attributes for the stop entity
--             p_stop_OUT_tab          Table of Output Attributes for the stop entity
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This calls core API WSH_TRIP_STOPS_GRP.CREATE_UPDATE_STOP
--========================================================================
PROCEDURE CREATE_UPDATE_STOP(
        p_api_version_number    IN NUMBER,
        p_init_msg_list         IN VARCHAR2,
        p_commit                IN VARCHAR2,
        p_in_rec                IN WSH_INTERFACE_EXT_GRP.stopInRecType,
        p_rec_attr_tab          IN WSH_INTERFACE_EXT_GRP.Stop_Attr_Tbl_Type,
        x_stop_out_tab          OUT NOCOPY WSH_INTERFACE_EXT_GRP.stop_out_tab_type,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2) IS

        l_stopInRecType             WSH_TRIP_STOPS_GRP.stopInRecType;
        l_Stop_Attr_Tbl_Type        WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
        l_stop_out_tab_type         WSH_TRIP_STOPS_GRP.stop_out_tab_type;
BEGIN
   --
Map_stopInRecType(p_in_rec, l_stopInRecType);
Map_Stop_Attr_Tbl_Type(p_rec_attr_tab, l_Stop_Attr_Tbl_Type);
   --
WSH_INTERFACE_GRP.CREATE_UPDATE_STOP(
        p_api_version_number    => p_api_version_number,
        p_init_msg_list         => p_init_msg_list,
        p_commit                => p_commit,
        p_in_rec                => l_stopInRecType,
        p_rec_attr_tab          => l_Stop_Attr_Tbl_Type,
        x_stop_out_tab          => l_stop_out_tab_type,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data) ;

map_stop_out_tab_type(l_stop_out_tab_type, x_stop_out_tab);
    --
EXCEPTION
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INTERFACE_EXT_GRP.CREATE_UPDATE_STOP');
      --
END Create_Update_Stop;


Procedure Map_Trip_Attr_Tbl_Type(
   p_in_tab   IN  WSH_INTERFACE_EXT_GRP.Trip_Attr_Tbl_Type,
   x_out_tab  OUT NOCOPY WSH_TRIPS_PVT.Trip_Attr_Tbl_Type) IS

Begin
for i in 1..p_in_tab.count LOOP
 x_out_tab(i).TRIP_ID                   := handle_missing_info(p_in_tab(i).TRIP_ID                   );
 x_out_tab(i).NAME                      := handle_missing_info(p_in_tab(i).NAME                      );
 x_out_tab(i).PLANNED_FLAG              := handle_missing_info(p_in_tab(i).PLANNED_FLAG              );
 x_out_tab(i).ARRIVE_AFTER_TRIP_ID      := handle_missing_info(p_in_tab(i).ARRIVE_AFTER_TRIP_ID      );
 x_out_tab(i).STATUS_CODE               := handle_missing_info(p_in_tab(i).STATUS_CODE               );
 x_out_tab(i).VEHICLE_ITEM_ID           := handle_missing_info(p_in_tab(i).VEHICLE_ITEM_ID           );
 x_out_tab(i).VEHICLE_ORGANIZATION_ID   := handle_missing_info(p_in_tab(i).VEHICLE_ORGANIZATION_ID   );
 x_out_tab(i).VEHICLE_NUMBER            := handle_missing_info(p_in_tab(i).VEHICLE_NUMBER            );
 x_out_tab(i).VEHICLE_NUM_PREFIX        := handle_missing_info(p_in_tab(i).VEHICLE_NUM_PREFIX        );
 x_out_tab(i).CARRIER_ID                := handle_missing_info(p_in_tab(i).CARRIER_ID                );
 x_out_tab(i).SHIP_METHOD_CODE          := handle_missing_info(p_in_tab(i).SHIP_METHOD_CODE          );
 x_out_tab(i).ROUTE_ID                  := handle_missing_info(p_in_tab(i).ROUTE_ID                  );
 x_out_tab(i).ROUTING_INSTRUCTIONS      := handle_missing_info(p_in_tab(i).ROUTING_INSTRUCTIONS      );
 x_out_tab(i).ATTRIBUTE_CATEGORY        := handle_missing_info(p_in_tab(i).ATTRIBUTE_CATEGORY        );
 x_out_tab(i).ATTRIBUTE1                := handle_missing_info(p_in_tab(i).ATTRIBUTE1                );
 x_out_tab(i).ATTRIBUTE2                := handle_missing_info(p_in_tab(i).ATTRIBUTE2                );
 x_out_tab(i).ATTRIBUTE3                := handle_missing_info(p_in_tab(i).ATTRIBUTE3                );
 x_out_tab(i).ATTRIBUTE4                := handle_missing_info(p_in_tab(i).ATTRIBUTE4                );
 x_out_tab(i).ATTRIBUTE5                := handle_missing_info(p_in_tab(i).ATTRIBUTE5                );
 x_out_tab(i).ATTRIBUTE6                := handle_missing_info(p_in_tab(i).ATTRIBUTE6                );
 x_out_tab(i).ATTRIBUTE7                := handle_missing_info(p_in_tab(i).ATTRIBUTE7                );
 x_out_tab(i).ATTRIBUTE8                := handle_missing_info(p_in_tab(i).ATTRIBUTE8                );
 x_out_tab(i).ATTRIBUTE9                := handle_missing_info(p_in_tab(i).ATTRIBUTE9                );
 x_out_tab(i).ATTRIBUTE10               := handle_missing_info(p_in_tab(i).ATTRIBUTE10               );
 x_out_tab(i).ATTRIBUTE11               := handle_missing_info(p_in_tab(i).ATTRIBUTE11               );
 x_out_tab(i).ATTRIBUTE12               := handle_missing_info(p_in_tab(i).ATTRIBUTE12               );
 x_out_tab(i).ATTRIBUTE13               := handle_missing_info(p_in_tab(i).ATTRIBUTE13               );
 x_out_tab(i).ATTRIBUTE14               := handle_missing_info(p_in_tab(i).ATTRIBUTE14               );
 x_out_tab(i).ATTRIBUTE15               := handle_missing_info(p_in_tab(i).ATTRIBUTE15               );
 x_out_tab(i).CREATION_DATE             := handle_missing_info(p_in_tab(i).CREATION_DATE             );
 x_out_tab(i).CREATED_BY                := handle_missing_info(p_in_tab(i).CREATED_BY                );
 x_out_tab(i).LAST_UPDATE_DATE          := handle_missing_info(p_in_tab(i).LAST_UPDATE_DATE          );
 x_out_tab(i).LAST_UPDATED_BY           := handle_missing_info(p_in_tab(i).LAST_UPDATED_BY           );
 x_out_tab(i).LAST_UPDATE_LOGIN         := handle_missing_info(p_in_tab(i).LAST_UPDATE_LOGIN         );
 x_out_tab(i).PROGRAM_APPLICATION_ID    := handle_missing_info(p_in_tab(i).PROGRAM_APPLICATION_ID    );
 x_out_tab(i).PROGRAM_ID                := handle_missing_info(p_in_tab(i).PROGRAM_ID                );
 x_out_tab(i).PROGRAM_UPDATE_DATE       := handle_missing_info(p_in_tab(i).PROGRAM_UPDATE_DATE       );
 x_out_tab(i).REQUEST_ID                := handle_missing_info(p_in_tab(i).REQUEST_ID                );
 x_out_tab(i).SERVICE_LEVEL             := handle_missing_info(p_in_tab(i).SERVICE_LEVEL             );
 x_out_tab(i).MODE_OF_TRANSPORT         := handle_missing_info(p_in_tab(i).MODE_OF_TRANSPORT         );
 x_out_tab(i).FREIGHT_TERMS_CODE        := handle_missing_info(p_in_tab(i).FREIGHT_TERMS_CODE        );
 x_out_tab(i).CONSOLIDATION_ALLOWED     := handle_missing_info(p_in_tab(i).CONSOLIDATION_ALLOWED     );
 x_out_tab(i).LOAD_TENDER_STATUS        := handle_missing_info(p_in_tab(i).LOAD_TENDER_STATUS        );
 x_out_tab(i).ROUTE_LANE_ID             := handle_missing_info(p_in_tab(i).ROUTE_LANE_ID             );
 x_out_tab(i).LANE_ID                   := handle_missing_info(p_in_tab(i).LANE_ID                   );
 x_out_tab(i).SCHEDULE_ID               := handle_missing_info(p_in_tab(i).SCHEDULE_ID               );
 x_out_tab(i).BOOKING_NUMBER            := handle_missing_info(p_in_tab(i).BOOKING_NUMBER            );
 x_out_tab(i).ROWID                     :=  p_in_tab(i).ROWID;
 x_out_tab(i).ARRIVE_AFTER_TRIP_NAME    := handle_missing_info(p_in_tab(i).ARRIVE_AFTER_TRIP_NAME    );
 x_out_tab(i).SHIP_METHOD_NAME          := handle_missing_info(p_in_tab(i).SHIP_METHOD_NAME          );
 x_out_tab(i).VEHICLE_ITEM_DESC         := handle_missing_info(p_in_tab(i).VEHICLE_ITEM_DESC         );
 x_out_tab(i).VEHICLE_ORGANIZATION_CODE := handle_missing_info(p_in_tab(i).VEHICLE_ORGANIZATION_CODE );
 x_out_tab(i).LOAD_TENDER_NUMBER        := handle_missing_info(p_in_tab(i).LOAD_TENDER_NUMBER        );
 x_out_tab(i).VESSEL                    := handle_missing_info(p_in_tab(i).VESSEL                    );
 x_out_tab(i).VOYAGE_NUMBER             := handle_missing_info(p_in_tab(i).VOYAGE_NUMBER             );
 x_out_tab(i).PORT_OF_LOADING           := handle_missing_info(p_in_tab(i).PORT_OF_LOADING           );
 x_out_tab(i).PORT_OF_DISCHARGE         := handle_missing_info(p_in_tab(i).PORT_OF_DISCHARGE         );
 x_out_tab(i).WF_NAME                   := handle_missing_info(p_in_tab(i).WF_NAME                   );
 x_out_tab(i).WF_PROCESS_NAME           := handle_missing_info(p_in_tab(i).WF_PROCESS_NAME           );
 x_out_tab(i).WF_ITEM_KEY               := handle_missing_info(p_in_tab(i).WF_ITEM_KEY               );
 x_out_tab(i).CARRIER_CONTACT_ID        := handle_missing_info(p_in_tab(i).CARRIER_CONTACT_ID        );
 x_out_tab(i).SHIPPER_WAIT_TIME         := handle_missing_info(p_in_tab(i).SHIPPER_WAIT_TIME         );
 x_out_tab(i).WAIT_TIME_UOM             := handle_missing_info(p_in_tab(i).WAIT_TIME_UOM             );
 x_out_tab(i).LOAD_TENDERED_TIME        := handle_missing_info(p_in_tab(i).LOAD_TENDERED_TIME        );
 x_out_tab(i).CARRIER_RESPONSE          := handle_missing_info(p_in_tab(i).CARRIER_RESPONSE          );


END LOOP;
End Map_Trip_Attr_Tbl_Type;


Procedure map_tripInRecType(
   p_in_rec   IN   WSH_INTERFACE_EXT_GRP.tripInRecType,
   x_out_rec  OUT  NOCOPY WSH_TRIPS_GRP.tripInRecType) IS

Begin

 x_out_rec.caller        :=  p_in_rec.caller     ;
 x_out_rec.phase       	 :=  p_in_rec.phase      ;
 x_out_rec.action_code 	 :=  p_in_rec.action_code;


End map_tripInRecType;

Procedure map_trip_Out_Tab_Type(
   p_in_tab   IN   WSH_TRIPS_GRP.trip_Out_Tab_Type,
   x_out_tab  OUT  NOCOPY WSH_INTERFACE_EXT_GRP.trip_Out_Tab_Type) Is

Begin

for i in 1..p_in_tab.count LOOP
  x_out_tab(i).rowid         :=  p_in_tab(i).rowid     ;
  x_out_tab(i).trip_id       :=  p_in_tab(i).trip_id   ;
  x_out_tab(i).trip_name     :=  p_in_tab(i).trip_name ;

END LOOP;
End map_trip_Out_Tab_Type;


--========================================================================
-- PROCEDURE : Create_Update_Trip      Wrapper API
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_trip_info_tab         Table of Attributes for the trip entity
--             p_IN_rec                Input Attributes for the trip entity
--             p_OUT_rec               Table of output Attributes for the trip entity
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This calls Core API WSH_TRIPS_GRP.Create_Update_Trip.
--========================================================================
PROCEDURE Create_Update_Trip(
        p_api_version_number     IN     NUMBER,
        p_init_msg_list          IN     VARCHAR2,
        p_commit                 IN     VARCHAR2,
        x_return_status          OUT    NOCOPY VARCHAR2,
        x_msg_count              OUT    NOCOPY NUMBER,
        x_msg_data               OUT    NOCOPY VARCHAR2,
        p_trip_info_tab          IN     WSH_INTERFACE_EXT_GRP.Trip_Attr_Tbl_Type,
        p_In_rec                 IN     WSH_INTERFACE_EXT_GRP.tripInRecType,
        x_Out_Tab                OUT    NOCOPY WSH_INTERFACE_EXT_GRP.trip_Out_Tab_Type) IS

        l_Trip_Attr_Tbl_Type     WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
        l_tripInRecType          WSH_TRIPS_GRP.tripInRecType;
        l_trip_Out_Tab_Type      WSH_TRIPS_GRP.trip_Out_Tab_Type;
BEGIN
    --
Map_Trip_Attr_Tbl_Type(p_trip_info_tab, l_Trip_Attr_Tbl_Type);
map_tripInRecType(p_In_rec, l_tripInRecType);

WSH_INTERFACE_GRP.Create_Update_Trip(
        p_api_version_number     =>     p_api_version_number,
        p_init_msg_list          =>     p_init_msg_list,
        p_commit                 =>     p_commit,
        x_return_status          =>     x_return_status,
        x_msg_count              =>     x_msg_count,
        x_msg_data               =>     x_msg_data,
        p_trip_info_tab          =>     l_Trip_Attr_Tbl_Type,
        p_In_rec                 =>     l_tripInRecType,
        x_Out_Tab                =>     l_trip_Out_Tab_Type);

map_trip_Out_Tab_Type(l_trip_Out_Tab_Type, x_Out_Tab);

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INTERFACE_EXT_GRP.CREATE_UPDATE_TRIP');
      --
END Create_Update_Trip;


Procedure map_freight_rec_tab_type(
   p_in_tab    IN    WSH_INTERFACE_EXT_GRP.freight_rec_tab_type,
   x_out_tab   OUT   NOCOPY WSH_FREIGHT_COSTS_GRP.freight_rec_tab_type) IS

Begin

for i in 1..p_in_tab.count LOOP
x_out_tab(i).FREIGHT_COST_ID                 := handle_missing_info(p_in_tab(i).FREIGHT_COST_ID   );
x_out_tab(i).FREIGHT_COST_TYPE_ID   	    := handle_missing_info(p_in_tab(i).FREIGHT_COST_TYPE_ID   );
x_out_tab(i).UNIT_AMOUNT            	    := handle_missing_info(p_in_tab(i).UNIT_AMOUNT       );
x_out_tab(i).CALCULATION_METHOD     	    := handle_missing_info(p_in_tab(i).CALCULATION_METHOD);
x_out_tab(i).UOM                    	    := handle_missing_info(p_in_tab(i).UOM               );
x_out_tab(i).QUANTITY               	    := handle_missing_info(p_in_tab(i).QUANTITY          );
x_out_tab(i).TOTAL_AMOUNT           	    := handle_missing_info(p_in_tab(i).TOTAL_AMOUNT      );
x_out_tab(i).CURRENCY_CODE          	    := handle_missing_info(p_in_tab(i).CURRENCY_CODE     );
x_out_tab(i).CONVERSION_DATE        	    := handle_missing_info(p_in_tab(i).CONVERSION_DATE   );
x_out_tab(i).CONVERSION_RATE        	    := handle_missing_info(p_in_tab(i).CONVERSION_RATE   );
x_out_tab(i).CONVERSION_TYPE_CODE   	    := handle_missing_info(p_in_tab(i).CONVERSION_TYPE_CODE   );
x_out_tab(i).TRIP_ID                	    := handle_missing_info(p_in_tab(i).TRIP_ID           );
x_out_tab(i).STOP_ID                	    := handle_missing_info(p_in_tab(i).STOP_ID           );
x_out_tab(i).DELIVERY_ID            	    := handle_missing_info(p_in_tab(i).DELIVERY_ID       );
x_out_tab(i).DELIVERY_LEG_ID        	    := handle_missing_info(p_in_tab(i).DELIVERY_LEG_ID   );
x_out_tab(i).DELIVERY_DETAIL_ID     	    := handle_missing_info(p_in_tab(i).DELIVERY_DETAIL_ID);
x_out_tab(i).ATTRIBUTE_CATEGORY     	    := handle_missing_info(p_in_tab(i).ATTRIBUTE_CATEGORY);
x_out_tab(i).ATTRIBUTE1             	    := handle_missing_info(p_in_tab(i).ATTRIBUTE1        );
x_out_tab(i).ATTRIBUTE2             	    := handle_missing_info(p_in_tab(i).ATTRIBUTE2        );
x_out_tab(i).ATTRIBUTE3             	    := handle_missing_info(p_in_tab(i).ATTRIBUTE3        );
x_out_tab(i).ATTRIBUTE4             	    := handle_missing_info(p_in_tab(i).ATTRIBUTE4        );
x_out_tab(i).ATTRIBUTE5             	    := handle_missing_info(p_in_tab(i).ATTRIBUTE5        );
x_out_tab(i).ATTRIBUTE6             	    := handle_missing_info(p_in_tab(i).ATTRIBUTE6        );
x_out_tab(i).ATTRIBUTE7             	    := handle_missing_info(p_in_tab(i).ATTRIBUTE7        );
x_out_tab(i).ATTRIBUTE8             	    := handle_missing_info(p_in_tab(i).ATTRIBUTE8        );
x_out_tab(i).ATTRIBUTE9             	    := handle_missing_info(p_in_tab(i).ATTRIBUTE9        );
x_out_tab(i).ATTRIBUTE10            	    := handle_missing_info(p_in_tab(i).ATTRIBUTE10       );
x_out_tab(i).ATTRIBUTE11            	    := handle_missing_info(p_in_tab(i).ATTRIBUTE11       );
x_out_tab(i).ATTRIBUTE12            	    := handle_missing_info(p_in_tab(i).ATTRIBUTE12       );
x_out_tab(i).ATTRIBUTE13            	    := handle_missing_info(p_in_tab(i).ATTRIBUTE13       );
x_out_tab(i).ATTRIBUTE14            	    := handle_missing_info(p_in_tab(i).ATTRIBUTE14       );
x_out_tab(i).ATTRIBUTE15            	    := handle_missing_info(p_in_tab(i).ATTRIBUTE15       );
x_out_tab(i).CREATION_DATE          	    := handle_missing_info(p_in_tab(i).CREATION_DATE     );
x_out_tab(i).CREATED_BY             	    := handle_missing_info(p_in_tab(i).CREATED_BY        );
x_out_tab(i).LAST_UPDATE_DATE       	    := handle_missing_info(p_in_tab(i).LAST_UPDATE_DATE  );
x_out_tab(i).LAST_UPDATE_LOGIN      	    := handle_missing_info(p_in_tab(i).LAST_UPDATE_LOGIN );
x_out_tab(i).PROGRAM_APPLICATION_ID 	    := handle_missing_info(p_in_tab(i).PROGRAM_APPLICATION_ID );
x_out_tab(i).PROGRAM_ID             	    := handle_missing_info(p_in_tab(i).PROGRAM_ID        );
x_out_tab(i).PROGRAM_UPDATE_DATE    	    := handle_missing_info(p_in_tab(i).PROGRAM_UPDATE_DATE    );
x_out_tab(i).REQUEST_ID             	    := handle_missing_info(p_in_tab(i).REQUEST_ID        );
x_out_tab(i).PRICING_LIST_HEADER_ID 	    := handle_missing_info(p_in_tab(i).PRICING_LIST_HEADER_ID );
x_out_tab(i).PRICING_LIST_LINE_ID   	    := handle_missing_info(p_in_tab(i).PRICING_LIST_LINE_ID   );
x_out_tab(i).APPLIED_TO_CHARGE_ID   	    := handle_missing_info(p_in_tab(i).APPLIED_TO_CHARGE_ID   );
x_out_tab(i).CHARGE_UNIT_VALUE   	    := handle_missing_info(p_in_tab(i).CHARGE_UNIT_VALUE   );
x_out_tab(i).CHARGE_SOURCE_CODE    	    := handle_missing_info(p_in_tab(i).CHARGE_SOURCE_CODE    );
x_out_tab(i).LINE_TYPE_CODE    		    := handle_missing_info(p_in_tab(i).LINE_TYPE_CODE    );
x_out_tab(i).ESTIMATED_FLAG    		    := handle_missing_info(p_in_tab(i).ESTIMATED_FLAG    );
x_out_tab(i).FREIGHT_CODE           	    := handle_missing_info(p_in_tab(i).FREIGHT_CODE      );
x_out_tab(i).TRIP_NAME              	    := handle_missing_info(p_in_tab(i).TRIP_NAME         );
x_out_tab(i).DELIVERY_NAME          	    := handle_missing_info(p_in_tab(i).DELIVERY_NAME     );
x_out_tab(i).FREIGHT_COST_TYPE      	    := handle_missing_info(p_in_tab(i).FREIGHT_COST_TYPE );
x_out_tab(i).STOP_LOCATION_ID       	    := handle_missing_info(p_in_tab(i).STOP_LOCATION_ID  );
x_out_tab(i).PLANNED_DEP_DATE       	    := handle_missing_info(p_in_tab(i).PLANNED_DEP_DATE  );
x_out_tab(i).COMMODITY_CATEGORY_ID    	    := handle_missing_info(p_in_tab(i).COMMODITY_CATEGORY_ID  );


END LOOP;
End map_freight_rec_tab_type;


Procedure map_freightInRecType(
  p_in_rec   IN   WSH_INTERFACE_EXT_GRP.freightInRecType,
  x_out_rec  OUT  NOCOPY WSH_FREIGHT_COSTS_GRP.freightInRecType) IS

Begin

       x_out_rec.caller         := p_in_rec.caller       ;
       x_out_rec.action_code    := p_in_rec.action_code  ;
       x_out_rec.phase          := p_in_rec.phase      ;

End map_freightInRecType;


Procedure map_freight_out_tab_type(
   p_in_tab    IN  WSH_FREIGHT_COSTS_GRP.freight_out_tab_type,
   x_out_tab   OUT NOCOPY WSH_INTERFACE_EXT_GRP.freight_out_tab_type) IS

Begin


for i in 1..p_in_tab.count LOOP
        x_out_tab(i).freight_cost_id    := p_in_tab(i).freight_cost_id;
        x_out_tab(i).rowid              := p_in_tab(i).rowid;

END LOOP;
End map_freight_out_tab_type;



PROCEDURE Create_Update_Freight_Costs(
        p_api_version_number     IN     NUMBER,
        p_init_msg_list          IN     VARCHAR2,
        p_commit                 IN     VARCHAR2,
        x_return_status          OUT    NOCOPY VARCHAR2,
        x_msg_count              OUT    NOCOPY NUMBER,
        x_msg_data               OUT    NOCOPY VARCHAR2,
        p_freight_info_tab       IN     WSH_INTERFACE_EXT_GRP.freight_rec_tab_type,
        p_in_rec                 IN     WSH_INTERFACE_EXT_GRP.freightInRecType,
        x_out_tab                OUT    NOCOPY WSH_INTERFACE_EXT_GRP.freight_out_tab_type) IS

        l_freight_rec_tab_type  WSH_FREIGHT_COSTS_GRP.freight_rec_tab_type;
        l_freightInRecType      WSH_FREIGHT_COSTS_GRP.freightInRecType;
        l_freight_out_tab_type  WSH_FREIGHT_COSTS_GRP.freight_out_tab_type;

BEGIN
   --
map_freight_rec_tab_type(p_freight_info_tab, l_freight_rec_tab_type);
map_freightInRecType(p_in_rec, l_freightInRecType);
   --
WSH_INTERFACE_GRP.Create_Update_Freight_Costs(
        p_api_version_number     =>     p_api_version_number,
        p_init_msg_list          =>     p_init_msg_list,
        p_commit                 =>     p_commit,
        x_return_status          =>     x_return_status,
        x_msg_count              =>     x_msg_count,
        x_msg_data               =>     x_msg_data,
        p_freight_info_tab       =>     l_freight_rec_tab_type,
        p_in_rec                 =>     l_freightInRecType,
        x_out_tab                =>     l_freight_out_tab_type);
map_freight_out_tab_type(l_freight_out_tab_type, x_out_tab);
    --
EXCEPTION
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INTERFACE_EXT_GRP.CREATE_UPDATE_FREIGHT_COSTS');
END Create_Update_Freight_costs;
--heali

PROCEDURE Get_Exceptions (
        -- Standard parameters
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_msg_count             OUT NOCOPY      NUMBER,
        x_msg_data              OUT NOCOPY      VARCHAR2,

        -- program specific parameters
        p_logging_entity_id	IN 	NUMBER,
	p_logging_entity_name	IN	VARCHAR2,

        -- program specific out parameters
        x_exceptions_tab	OUT NOCOPY 	WSH_INTERFACE_EXT_GRP.XC_TAB_TYPE
	)
IS

BEGIN
   --
   --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
EXCEPTION
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INTERFACE_EXT_GRP.Get_Exceptions');
END Get_Exceptions;


PROCEDURE Exception_Action (
	p_api_version	        IN	NUMBER,
	p_init_msg_list		IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
	p_validation_level      IN      NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
        p_commit                IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
        x_msg_count             OUT NOCOPY      NUMBER,
        x_msg_data              OUT NOCOPY      VARCHAR2,
        x_return_status         OUT NOCOPY      VARCHAR2,

	p_exception_rec         IN OUT  NOCOPY WSH_INTERFACE_EXT_GRP.XC_ACTION_REC_TYPE,
        p_action                IN              VARCHAR2
	)

IS

BEGIN
   --
   --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
EXCEPTION
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INTERFACE_EXT_GRP.Exception_Action');
END Exception_Action;



PROCEDURE Delivery_Leg_Action(
	p_api_version_number	 	IN 	NUMBER,
	p_init_msg_list			IN	VARCHAR2,
	p_commit                 	IN 	VARCHAR2,
	p_dlvy_leg_id_tab		IN	wsh_util_core.id_tab_type,
	p_action_prms			IN	WSH_INTERFACE_EXT_GRP.dlvy_leg_action_prms_rectype,
	x_action_out_rec		IN OUT  NOCOPY WSH_INTERFACE_EXT_GRP.dlvy_leg_action_out_rec_type,
	x_return_status  		OUT 	NOCOPY VARCHAR2,
	x_msg_count     		OUT 	NOCOPY NUMBER,
	x_msg_data       		OUT 	NOCOPY VARCHAR2
) IS

BEGIN
   --
   --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
EXCEPTION
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INTERFACE_EXT_GRP.Delivery_Leg_Action');
END Delivery_Leg_Action;


  --OTM R12
  ----------------------------------------------------------
  -- PROCEDURE OTM_PRE_SHIP_CONFIRM
  --
  -- parameters:	p_delivery_id_tab	delivery id to process
  --                    p_delivery_name         delivery name
  --			p_tms_interface_flag    the tms interface flag value of the delivery
  --                    p_trip_id               trip id for the delivery
  --			x_return_status		return status
  --
  -- description:	This procedure checks the delivery exception to determine
  -- 			if ship confirm can proceed, log warning exception if necessary.
  ----------------------------------------------------------
  PROCEDURE OTM_PRE_SHIP_CONFIRM
  (p_delivery_id        IN         NUMBER,
   p_delivery_name      IN         VARCHAR2 DEFAULT NULL,
   p_tms_interface_flag IN         VARCHAR2,
   p_trip_id            IN         NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2) IS

  l_exception_name    WSH_EXCEPTIONS.EXCEPTION_NAME%TYPE;
  l_severity          WSH_EXCEPTIONS.SEVERITY%TYPE;
  l_return_status     VARCHAR2(1);
  -- This table is used to pass delivery ids to Ignore_for_Plan during forced ship-confirm.
  l_otm_del_ids       WSH_UTIL_CORE.id_tab_type;
  l_num_warn          NUMBER;
  api_return_fail     EXCEPTION;

  l_debug_on          BOOLEAN;
  l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'OTM_PRE_SHIP_CONFIRM';

  BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'delivery id', p_delivery_id);
      WSH_DEBUG_SV.log(l_module_name, 'tms interface flag', p_tms_interface_flag);
      WSH_DEBUG_SV.log(l_module_name, 'trip id', p_trip_id);
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    l_exception_name := NULL;
    l_severity := NULL;
    l_num_warn := 0;

    --for delivery without trip and in CR/AW/UR/UP/CP status, we will check for exception and turn to
    --ignore for planning if doesn't have error OTM exception.
    IF (p_trip_id IS NULL AND p_tms_interface_flag IN (WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_REQUIRED,
                                                       WSH_NEW_DELIVERIES_PVT.C_TMS_AWAITING_ANSWER,
                                                       WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED,
                                                       WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_IN_PROCESS,
                                                       WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_IN_PROCESS)) THEN

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.GET_OTM_DELIVERY_EXCEPTION',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_XC_UTIL.get_otm_delivery_exception(
        p_delivery_id	 =>  p_delivery_id,
        x_exception_name =>  l_exception_name,
        x_severity       =>  l_severity,
        x_return_status  =>  l_return_status);

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_XC_UTIL.GET_OTM_DELIVERY_EXCEPTION: ' || l_return_status);
        WSH_DEBUG_SV.log(l_module_name, 'exception name', l_exception_name);
        WSH_DEBUG_SV.log(l_module_name, 'severity', l_severity);
      END IF;

      IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'WSH_XC_UTIL.GET_OTM_DELIVERY_EXCEPTION procedure failed');
        END IF;

        RAISE api_return_fail;

      END IF;

      IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        l_num_warn := l_num_warn + 1 ;
      END IF;

      IF (l_severity IS NULL OR l_severity = 'WARNING') THEN

        --add the warning message before it is closed
        IF (l_severity = 'WARNING') THEN
          FND_MESSAGE.SET_NAME('WSH', l_exception_name);  --exception name is the same as the message name for this one
          IF (p_delivery_name IS NULL) THEN
            FND_MESSAGE.SET_TOKEN('DELIVERY_NAME', WSH_NEW_DELIVERIES_PVT.get_name(p_delivery_id));
          ELSE
            FND_MESSAGE.SET_TOKEN('DELIVERY_NAME', p_delivery_name);
          END IF;
          l_num_warn := l_num_warn + 1;
          wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING, l_module_name);
        END IF;

        l_otm_del_ids(1) := p_delivery_id;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TP_RELEASE.CHANGE_IGNOREPLAN_STATUS',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        WSH_TP_RELEASE.change_ignoreplan_status(
          p_entity        =>  'DLVY',
          p_in_ids        =>  l_otm_del_ids,
          p_action_code   =>  'IGNORE_PLAN',
          x_return_status =>  l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_TP_RELEASE.CHANGE_IGNOREPLAN_STATUS: ' || l_return_status);
        END IF;

        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'WSH_TP_RELEASE.CHANGE_IGNOREPLAN_STATUS procedure failed');
          END IF;
          RAISE api_return_fail;

        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
       	  l_num_warn := l_num_warn + 1;
        END IF;
      END IF;
    END IF;
    --Bug 8571352 added warning message to stack so that it is displyed during ship confirm
    IF (p_trip_id IS NOT NULL AND p_tms_interface_flag IN (WSH_NEW_DELIVERIES_PVT.C_TMS_AWAITING_ANSWER,
                                                           WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED,
                                                           WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_IN_PROCESS
                                                          )) THEN

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.GET_OTM_DELIVERY_EXCEPTION',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_XC_UTIL.get_otm_delivery_exception(
        p_delivery_id	 =>  p_delivery_id,
        x_exception_name =>  l_exception_name,
        x_severity       =>  l_severity,
        x_return_status  =>  l_return_status);

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_XC_UTIL.GET_OTM_DELIVERY_EXCEPTION: ' || l_return_status);
        WSH_DEBUG_SV.log(l_module_name, 'exception name', l_exception_name);
        WSH_DEBUG_SV.log(l_module_name, 'severity', l_severity);
      END IF;

      IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'WSH_XC_UTIL.GET_OTM_DELIVERY_EXCEPTION procedure failed');
        END IF;

        RAISE api_return_fail;

      END IF;

      IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        l_num_warn := l_num_warn + 1 ;
      END IF;

      IF (l_severity IS NULL OR l_severity = 'WARNING') THEN

        --add the warning message before it is closed
        IF (l_severity = 'WARNING') THEN
          FND_MESSAGE.SET_NAME('WSH', l_exception_name);  --exception name is the same as the message name for this one
          IF (p_delivery_name IS NULL) THEN
            FND_MESSAGE.SET_TOKEN('DELIVERY_NAME', WSH_NEW_DELIVERIES_PVT.get_name(p_delivery_id));
          ELSE
            FND_MESSAGE.SET_TOKEN('DELIVERY_NAME', p_delivery_name);
          END IF;
          l_num_warn := l_num_warn + 1;
          wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING, l_module_name);
        END IF;
      END IF;
    END IF;
    --Bug 8571352
    IF (l_num_warn > 0 AND x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    END IF;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  EXCEPTION
    WHEN api_return_fail THEN
      x_return_status := l_return_status;
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;

    WHEN Others THEN

      WSH_UTIL_CORE.Default_Handler('WSH_INTERFACE_EXT_GRP.OTM_PRE_SHIP_CONFIRM', l_module_name);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;

  END OTM_PRE_SHIP_CONFIRM;
  --END OTM R12

END WSH_INTERFACE_EXT_GRP;

/
