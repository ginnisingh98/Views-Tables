--------------------------------------------------------
--  DDL for Package Body WSH_DELIVERY_DETAILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DELIVERY_DETAILS_PUB" as
/* $Header: WSHDDPBB.pls 120.3.12010000.2 2009/09/15 13:03:09 skanduku ship $ */

  -- standard global constants
  G_PKG_NAME CONSTANT VARCHAR2(30)    := 'WSH_DELIVERY_DETAILS_PUB';
  p_message_type  CONSTANT VARCHAR2(1)  := 'E';


PROCEDURE Copy_Attributes(
  x_detail_info_tab OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type
, x_changed_attributes IN WSH_DELIVERY_DETAILS_PUB.ChangedAttributeTabType);


-- -----------------------------------------------------------------------
-- Procedure: detail_to_delivery
--
-- Parameters:    1) table of delivery_detail_ids
--            2) action: assign/unassign
--            3) delivery_id: need to specify delivery id or delivery name
--              if the action is 'ASSIGN'
--            4) delivery_name: need to specify delivery id or delivery
--              name if the action is 'ASSIGN'
--            5) other standard parameters
--
--
-- Description:  This procedure assign/unassign delivery_details to
--            a delivery.
-- Parameters: p_TabOfDelDets: required
--          p_action: required
--          p_delivery_id: required if action='ASSIGN'
-- -----------------------------------------------------------------------

PROCEDURE detail_to_delivery(
  -- Standard parameters
  p_api_version         IN NUMBER,
  p_init_msg_list       IN VARCHAR2,
  p_commit              IN VARCHAR2,
  p_validation_level      IN NUMBER,
  x_return_status       OUT NOCOPY  VARCHAR2,
  x_msg_count           OUT NOCOPY  NUMBER,
  x_msg_data            OUT NOCOPY  VARCHAR2,

  -- procedure specific parameters
  p_TabOfDelDets          IN ID_TAB_TYPE,
  p_action              IN VARCHAR2,
  p_delivery_id         IN NUMBER,
  p_delivery_name       IN VARCHAR2
  ) IS

-- Standard call to check for call compatibility
l_api_version CONSTANT  NUMBER    := 1.0;
l_api_name    CONSTANT  VARCHAR2(30):= 'delivery_detail_to_delivery';

l_return_status VARCHAR2(30)  := NULL;
l_delivery_id number        := NULL;
l_cont_ins_id number        := NULL;
l_TabOfDelDets WSH_UTIL_CORE.ID_TAB_TYPE;
l_msg_summary varchar2(2000)  := NULL;
l_msg_details varchar2(4000)  := NULL;

-- Harmonization Project
      l_action_prms             WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
      l_action_out_rec         WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type;
      l_dummy_qty               NUMBER;
      l_dummy_qty2              NUMBER;
      l_dummy_ids               wsh_util_core.id_tab_type;

  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(32767);
  l_number_of_errors    NUMBER := 0;
  l_number_of_warnings  NUMBER := 0;

-- Harmonization Project

WSH_NO_DEL_DET_TBL        exception;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DETAIL_TO_DELIVERY';
--
begin

    -- Standard begin of API savepoint
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  SAVEPOINT DETAIL_TO_DELIVERY_PUB;
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION',P_API_VERSION);
      WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
      WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
      WSH_DEBUG_SV.log(l_module_name,'P_VALIDATION_LEVEL',P_VALIDATION_LEVEL);
      WSH_DEBUG_SV.log(l_module_name,'P_ACTION',P_ACTION);
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_NAME',P_DELIVERY_NAME);
  END IF;
  --

  IF NOT FND_API.compatible_api_call( l_api_version,
                 p_api_version,
                             l_api_name,
                             G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_boolean(p_init_msg_list)  THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  if (p_TabOfDelDets.count = 0) then
      raise WSH_NO_DEL_DET_TBL;
  end if;


  FOR I IN p_TabOfDelDets.first .. p_TabOfDelDets.last
  LOOP

    l_TabOfDelDets(i) :=  p_TabOfDelDets(i);
    -- dbms_output.put_line(l_TabOfDelDets(i));
  END LOOP;
        l_action_prms.caller := 'WSH_PUB';
        l_action_prms.action_code := p_action;
        l_action_prms.delivery_id := p_delivery_id;
        l_action_prms.delivery_name := p_delivery_name;

          /* Patchset I: Harmonization Project. Call group API
           All validations done by Group API */

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTERFACE_GRP.DELIVERY_DETAIL_ACTION',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --

        wsh_interface_grp.delivery_detail_action(
            p_api_version_number    => p_api_version,
            p_init_msg_list         => FND_API.G_FALSE,
            p_commit                => FND_API.G_FALSE,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data,
            p_detail_id_tab         => l_TabOfDelDets,
            p_action_prms           => l_action_prms ,
            x_action_out_rec        => l_action_out_rec);

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );

  IF l_number_of_warnings > 0 THEN
      x_return_status := wsh_util_core.g_ret_sts_warning;
  END IF;


  IF FND_API.TO_BOOLEAN(p_commit) THEN
    -- dbms_output.put_line('commit');
    COMMIT WORK;
  END IF;

        FND_MSG_PUB.Count_And_Get
          (
      p_count =>  x_msg_count,
            p_data  =>  x_msg_data,
            p_encoded => FND_API.G_FALSE
          );

   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
--
  exception
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO DETAIL_TO_DELIVERY_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                wsh_util_core.add_message(x_return_status);
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );

                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                  WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
                END IF;
--
         WHEN WSH_NO_DEL_DET_TBL then
              ROLLBACK TO DETAIL_TO_DELIVERY_PUB;
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              fnd_message.set_name('WSH', 'WSH_PUB_NO_DEL_DET_TBL');
              WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );

               IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'WSH_NO_DEL_DET_TBL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_NO_DEL_DET_TBL');
         END IF;
  --
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DETAIL_TO_DELIVERY_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
               wsh_util_core.add_message(x_return_status, l_module_name);
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );
                  --

           IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
           END IF;
          WHEN others then
               ROLLBACK TO DETAIL_TO_DELIVERY_PUB;
               wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_PUB.DETAIL_TO_DELIVERY');
               x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );

          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
          END IF;
  --
END detail_to_delivery;

-- ----------------------------------------------------------------------
-- Procedure:   split_line
-- Parameters:     p_from_detail_id: The delivery detail ID to be split
--            x_new_detail_id:  The new delivery detail ID
--            p_source_quantity:
--            split_quantity:
--
-- Description:   This procedure split a delivery_deatil line
--          03/19/01 OPM changes. Added split_quantity2
--  ----------------------------------------------------------------------

PROCEDURE   split_line
    (
    -- Standard parameters
    p_api_version         IN NUMBER,
    p_init_msg_list       IN VARCHAR2,
    p_commit              IN VARCHAR2,
    p_validation_level      IN NUMBER,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,

    -- Procedure specific parameters
    p_from_detail_id        IN NUMBER,
    x_new_detail_id       OUT NOCOPY  NUMBER,
    x_split_quantity        IN OUT NOCOPY  NUMBER,
    x_split_quantity2                 IN OUT NOCOPY  NUMBER
     ) is

l_msg_summary varchar2(2000);
l_msg_details varchar2(4000);

-- Harmonization Project
      l_action_prms             WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
      l_action_out_rec         WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type;
      l_dummy_qty               NUMBER;
      l_dummy_qty2              NUMBER;
      l_dummy_ids               wsh_util_core.id_tab_type;
      l_detail_ids              wsh_util_core.id_tab_type;
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(32767);
  l_number_of_errors    NUMBER := 0;
  l_number_of_warnings  NUMBER := 0;
        l_return_status       VARCHAR2(30);
        l_index  NUMBER;

-- Standard call to check for call compatibility.
l_api_version CONSTANT  NUMBER    := 1.0;
l_api_name    CONSTANT  VARCHAR2(30):= 'delivery_detail_to_delivery';

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SPLIT_LINE';
--
BEGIN

    -- Standard begin of API savepoint
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  SAVEPOINT SPLIT_LINE_PUB;

  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION',P_API_VERSION);
      WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
      WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
      WSH_DEBUG_SV.log(l_module_name,'P_VALIDATION_LEVEL',P_VALIDATION_LEVEL);
      WSH_DEBUG_SV.log(l_module_name,'P_FROM_DETAIL_ID',P_FROM_DETAIL_ID);
      WSH_DEBUG_SV.log(l_module_name,'X_SPLIT_QUANTITY',X_SPLIT_QUANTITY);
      WSH_DEBUG_SV.log(l_module_name,'X_SPLIT_QUANTITY2',X_SPLIT_QUANTITY2);
  END IF;
  --

  IF NOT FND_API.compatible_api_call(l_api_version,
          p_api_version,
                                        l_api_name,
                                        G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Check p_init_msg_list
  IF FND_API.to_boolean(p_init_msg_list)  THEN
    FND_MSG_PUB.initialize;
  END IF;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


        l_detail_ids(1) := p_from_detail_id;
        l_action_prms.caller := 'WSH_PUB';
        l_action_prms.action_code := 'SPLIT-LINE';
        l_action_prms.split_quantity := x_split_quantity;
        l_action_prms.split_quantity2 := x_split_quantity2;

          /* Patchset I: Harmonization Project. Call group API
           All validations done by Group API */

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTERFACE_GRP.DELIVERY_DETAIL_ACTION',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

        wsh_interface_grp.delivery_detail_action(
            p_api_version_number    => p_api_version,
            p_init_msg_list         => FND_API.G_FALSE,
            p_commit                => FND_API.G_FALSE,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data,
            p_detail_id_tab         => l_detail_ids,
            p_action_prms           => l_action_prms ,
            x_action_out_rec        => l_action_out_rec);

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );

        x_split_quantity  := l_action_out_rec.split_quantity;
        x_split_quantity2 := l_action_out_rec.split_quantity2;
        l_index := l_action_out_rec.result_id_tab.first;
        x_new_detail_id := l_action_out_rec.result_id_tab(l_index);

  IF l_number_of_warnings > 0 THEN
      x_return_status := wsh_util_core.g_ret_sts_warning;
  END IF;

  IF FND_API.TO_BOOLEAN(p_commit) THEN
    -- dbms_output.put_line('commit');
    COMMIT WORK;
  END IF;

        FND_MSG_PUB.Count_And_Get
          (
      p_count =>  x_msg_count,
            p_data  =>  x_msg_data,
            p_encoded => FND_API.G_FALSE
           );

 IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
 END IF;
 --
exception
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO SPLIT_LINE_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                wsh_util_core.add_message(x_return_status);
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;
        --
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO SPLIT_LINE_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
               wsh_util_core.add_message(x_return_status, l_module_name);
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );
                  --

           IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
           END IF;
        WHEN OTHERS THEN
                ROLLBACK TO SPLIT_LINE_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               wsh_util_core.add_message(x_return_status, l_module_name);
               WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_PUB.Split_Line');
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );
    --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
            END IF;
--
END split_line;
--===================
-- PROCEDURES
--===================

-- Procedure Init_Changed_Attribute_Rec
-- Parameter p_init_rec record that needs to be initialized.
-- This procedure takes in a record of WSH_DELIVERY_DETAILS_PUB.ChangedAttributeRecType and
-- initializes its attributes to the default FND_API_G values.

Procedure Init_Changed_Attribute_Rec(p_init_rec IN OUT NOCOPY  WSH_DELIVERY_DETAILS_PUB.ChangedAttributeRecType,
                                     x_return_status OUT NOCOPY  VARCHAR2) IS
                                     --
l_debug_on BOOLEAN;
                                     --
                                     l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INIT_CHANGED_ATTRIBUTE_REC';
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
        END IF;
        --
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        p_init_rec.source_header_id                     :=             FND_API.G_MISS_NUM;
        p_init_rec.source_line_id                       :=             FND_API.G_MISS_NUM;
        p_init_rec.sold_to_org_id                       :=             FND_API.G_MISS_NUM;
        p_init_rec.customer_number                      :=             FND_API.G_MISS_NUM;
        p_init_rec.sold_to_contact_id                   :=             FND_API.G_MISS_NUM;
        p_init_rec.ship_from_org_id                     :=             FND_API.G_MISS_NUM;
        p_init_rec.ship_from_org_code                   :=             FND_API.G_MISS_CHAR;
        p_init_rec.ship_to_org_id                       :=             FND_API.G_MISS_NUM;
        p_init_rec.ship_to_org_code                     :=             FND_API.G_MISS_CHAR;
        p_init_rec.ship_to_contact_id                   :=             FND_API.G_MISS_NUM;
        p_init_rec.deliver_to_org_id                    :=             FND_API.G_MISS_NUM;
        p_init_rec.deliver_to_org_code                  :=             FND_API.G_MISS_CHAR;
        p_init_rec.deliver_to_contact_id                :=             FND_API.G_MISS_NUM;
        p_init_rec.intmed_ship_to_org_id                :=             FND_API.G_MISS_NUM;
        p_init_rec.intmed_ship_to_org_code              :=             FND_API.G_MISS_CHAR;
        p_init_rec.intmed_ship_to_contact_id            :=             FND_API.G_MISS_NUM;
        p_init_rec.ship_tolerance_above                 :=             FND_API.G_MISS_NUM;
        p_init_rec.ship_tolerance_below                 :=             FND_API.G_MISS_NUM;
        p_init_rec.ordered_quantity                     :=             FND_API.G_MISS_NUM;
        p_init_rec.ordered_quantity2                    :=             FND_API.G_MISS_NUM;
        p_init_rec.order_quantity_uom                   :=             FND_API.G_MISS_CHAR;
        p_init_rec.ordered_quantity_uom2                :=             FND_API.G_MISS_CHAR;
        p_init_rec.preferred_grade                      :=             FND_API.G_MISS_CHAR;
        p_init_rec.ordered_qty_unit_of_measure          :=             FND_API.G_MISS_CHAR;
        p_init_rec.ordered_qty_unit_of_measure2         :=             FND_API.G_MISS_CHAR;
        p_init_rec.subinventory                         :=             FND_API.G_MISS_CHAR;
        p_init_rec.revision                             :=             FND_API.G_MISS_CHAR;
        p_init_rec.lot_number                           :=             FND_API.G_MISS_CHAR;
-- HW OPMCONV - No need for sublot_number
--      p_init_rec.sublot_number                        :=             FND_API.G_MISS_CHAR;
        p_init_rec.customer_requested_lot_flag          :=             FND_API.G_MISS_CHAR;
        p_init_rec.serial_number                        :=             FND_API.G_MISS_CHAR;
        p_init_rec.locator_id                           :=             FND_API.G_MISS_NUM;
        p_init_rec.date_requested                       :=             FND_API.G_MISS_DATE;
        p_init_rec.date_scheduled                       :=             FND_API.G_MISS_DATE;
        p_init_rec.master_container_item_id             :=             FND_API.G_MISS_NUM;
        p_init_rec.detail_container_item_id             :=             FND_API.G_MISS_NUM;
        p_init_rec.shipping_method_code                 :=             FND_API.G_MISS_CHAR;
        p_init_rec.carrier_id                           :=             FND_API.G_MISS_NUM;
        p_init_rec.freight_terms_code                   :=             FND_API.G_MISS_CHAR;
        p_init_rec.freight_terms_name                   :=             FND_API.G_MISS_CHAR;
        p_init_rec.freight_carrier_code                 :=             FND_API.G_MISS_CHAR;
        p_init_rec.shipment_priority_code               :=             FND_API.G_MISS_CHAR;
        p_init_rec.fob_code                             :=             FND_API.G_MISS_CHAR;
        p_init_rec.fob_name                             :=             FND_API.G_MISS_CHAR;
        p_init_rec.dep_plan_required_flag               :=             FND_API.G_MISS_CHAR;
        p_init_rec.customer_prod_seq                    :=             FND_API.G_MISS_CHAR;
        p_init_rec.customer_dock_code                   :=             FND_API.G_MISS_CHAR;
        p_init_rec.gross_weight                         :=             FND_API.G_MISS_NUM;
        p_init_rec.net_weight                           :=             FND_API.G_MISS_NUM;
        p_init_rec.weight_uom_code                      :=             FND_API.G_MISS_CHAR;
        p_init_rec.weight_uom_desc                      :=             FND_API.G_MISS_CHAR;
        p_init_rec.volume                               :=             FND_API.G_MISS_NUM;
        p_init_rec.volume_uom_code                      :=             FND_API.G_MISS_CHAR;
        p_init_rec.volume_uom_desc                      :=             FND_API.G_MISS_CHAR;
        p_init_rec.top_model_line_id                    :=             FND_API.G_MISS_NUM;
        p_init_rec.ship_set_id                          :=             FND_API.G_MISS_NUM;
        p_init_rec.ato_line_id                          :=             FND_API.G_MISS_NUM;
        p_init_rec.arrival_set_id                       :=             FND_API.G_MISS_NUM;
        p_init_rec.ship_model_complete_flag             :=             FND_API.G_MISS_CHAR;
        p_init_rec.cust_po_number                       :=             FND_API.G_MISS_CHAR;
        p_init_rec.released_status                      :=             FND_API.G_MISS_CHAR;
        p_init_rec.packing_instructions                 :=             FND_API.G_MISS_CHAR;
        p_init_rec.shipping_instructions                :=             FND_API.G_MISS_CHAR;
        p_init_rec.container_name                       :=             FND_API.G_MISS_CHAR;
        p_init_rec.container_flag                       :=             FND_API.G_MISS_CHAR;
        p_init_rec.delivery_detail_id                   :=             FND_API.G_MISS_NUM;
        p_init_rec.shipped_quantity                     :=             FND_API.G_MISS_NUM;
        p_init_rec.cycle_count_quantity                 :=             FND_API.G_MISS_NUM;
-- HW OPMCONV - Added Qty2
        p_init_rec.shipped_quantity2                    :=             FND_API.G_MISS_NUM;
        p_init_rec.cycle_count_quantity2                :=             FND_API.G_MISS_NUM;
        p_init_rec.tracking_number                      :=             FND_API.G_MISS_CHAR;
        p_init_rec.attribute1                           :=             FND_API.G_MISS_CHAR;
        p_init_rec.attribute2                           :=             FND_API.G_MISS_CHAR;
        p_init_rec.attribute3                           :=             FND_API.G_MISS_CHAR;
        p_init_rec.attribute4                           :=             FND_API.G_MISS_CHAR;
        p_init_rec.attribute5                           :=             FND_API.G_MISS_CHAR;
        p_init_rec.attribute6                           :=             FND_API.G_MISS_CHAR;
        p_init_rec.attribute7                           :=             FND_API.G_MISS_CHAR;
        p_init_rec.attribute8                           :=             FND_API.G_MISS_CHAR;
        p_init_rec.attribute9                           :=             FND_API.G_MISS_CHAR;
        p_init_rec.attribute10                          :=             FND_API.G_MISS_CHAR;
        p_init_rec.attribute11                          :=             FND_API.G_MISS_CHAR;
        p_init_rec.attribute12                          :=             FND_API.G_MISS_CHAR;
        p_init_rec.attribute13                          :=             FND_API.G_MISS_CHAR;
        p_init_rec.attribute14                          :=             FND_API.G_MISS_CHAR;
        p_init_rec.attribute15                          :=             FND_API.G_MISS_CHAR;
-- J: W/V Changes
        p_init_rec.filled_volume                        :=             FND_API.G_MISS_NUM;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
        EXCEPTION
           WHEN Others THEN
               x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
               WSH_UTIL_CORE.add_message (x_return_status);
               WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_PUB.Init_Changed_Attribute_Rec');


 --
 -- Debug Statements
 --
 IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
 END IF;
 --
END Init_Changed_Attribute_Rec;

--========================================================================
-- PROCEDURE : Update_Shipping_Attributes
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         initialize message stack
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_changed_attributes    changed attributes for delivery details
--             p_source_code           source system
--
--
-- COMMENT   : Validates Organization_id and Organization_code against view
--             org_organization_definitions. If both values are
--             specified then only Org_Id is used
--
--DESCRIPTION: This overloaded version of Update_Shipping_Attributes is created
--             to  enable entry of multiple serial ranges for a given delivery
--             detail
--
--CREATED:     During patchset I
--========================================================================

PROCEDURE Update_Shipping_Attributes (
  -- Standard parameters
  p_api_version_number     IN     NUMBER
, p_init_msg_list          IN     VARCHAR2
, p_commit                 IN     VARCHAR2
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2

  -- Procedure specific parameters
, p_changed_attributes    IN     WSH_DELIVERY_DETAILS_PUB.ChangedAttributeTabType
, p_source_code            IN     VARCHAR2
, p_container_flag         IN     VARCHAR2
)
IS

l_valid_index_tab      WSH_UTIL_CORE.Id_Tab_Type;
l_valid_ids_tab        WSH_UTIL_CORE.Id_Tab_Type;
l_msg_summary varchar2(2000)  := NULL;
l_msg_details varchar2(4000)  := NULL;
l_return_status       VARCHAR2(30);
l_counter         NUMBER;
l_index               NUMBER;
l_api_version_number  NUMBER := 1.0;
l_api_name            VARCHAR2(30) := 'Update_Shipping_Attributes';
l_ship_to_location_id   NUMBER;
invalid_source_code     EXCEPTION;

m     NUMBER := 0;


      -- Harmonization Project
      l_detail_info_tab WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type;
      l_in_rec    WSH_GLBL_VAR_STRCT_GRP.detailInRecType;
      l_lpn_ids       wsh_util_core.id_Tab_type;
      l_out_Rec       WSH_GLBL_VAR_STRCT_GRP.detailOutRecType;
      l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(32767);
  l_number_of_errors    NUMBER := 0;
  l_number_of_warnings  NUMBER := 0;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_SHIPPING_ATTRIBUTES';
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
        SAVEPOINT UPDATE_SHIPPING_ATTR_PUB;

        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            --
            WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
            WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
            WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
            WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
            WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_FLAG',P_CONTAINER_FLAG);
        END IF;
        --

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  --  Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(
    l_api_version_number,
    p_api_version_number,
    l_api_name,
    G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    --  Initialize message stack if required
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- <start of API logic>
        -- sperera source_code has to be 'OE' or 'WSH'
  IF (NVL(p_source_code, FND_API.G_MISS_CHAR) NOT IN ('WSH', 'OE')) THEN
    RAISE invalid_source_code;
  END IF;


       -- call the copy procedure here

       Copy_Attributes(x_detail_info_tab => l_detail_info_tab,
                       x_changed_attributes=>p_changed_attributes);

       l_in_rec.caller := 'WSH_PUB';
       l_in_rec.action_code := 'UPDATE';
        --Bug 8900333: Locking the delivery details before calling the group API for further processing
        BEGIN
        savepoint before_lock;
            l_index := l_detail_info_tab.FIRST;
            WHILE l_index IS NOT NULL LOOP
                l_valid_index_tab(l_index) :=l_index;
                l_index := l_detail_info_tab.NEXT(l_index);
            END LOOP;
            IF l_valid_index_tab.count >0 THEN
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.LOCK_DELIVERY_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                wsh_delivery_details_pkg.Lock_Delivery_Details(
                    p_rec_attr_tab          => l_detail_info_tab,
                    p_caller                => l_In_rec.caller,
                    p_valid_index_tab       => l_valid_index_tab,
                    x_valid_ids_tab         => l_valid_ids_tab,
                    x_return_status         => l_return_status
                    );

                wsh_util_core.api_post_call(
                    p_return_status => l_return_status,
                    x_num_warnings  => l_number_of_warnings,
                    x_num_errors    => l_number_of_errors,
                    p_msg_data      => l_msg_data,
                    p_raise_error_flag => FALSE
                    );
                IF l_return_status <> wsh_util_core.g_ret_sts_success THEN
                    wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;
            EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN
                    ROLLBACK TO  before_lock;
                    IF l_debug_on THEN
                        wsh_debug_sv.logmsg(l_module_name, 'FND_API.G_EXC_ERROR exception has occured',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                    END IF;
                    RAISE FND_API.G_EXC_ERROR ;
                WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                    ROLLBACK TO before_lock;
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                    END IF;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                WHEN OTHERS THEN
                    ROLLBACK TO before_lock;
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
                    END IF;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END;

          /* Patchset I: Harmonization Project. Call group API
           All validations done by Group API */

             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_GRP.CREATE_UPDATE_DELIVERY_DETAIL',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
       wsh_interface_grp.create_update_delivery_detail(
       p_api_version_number  => p_api_version_number,
       p_init_msg_list           => FND_API.G_FALSE,
       p_commit                  => FND_API.G_FALSE,
       x_return_status           => l_return_status,
       x_msg_count               => l_msg_count,
       x_msg_data                => l_msg_data,
       p_detail_info_tab         => l_detail_info_tab,
       p_IN_rec                  => l_in_rec,
       x_OUT_rec                 => l_out_rec);

             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             --
             wsh_util_core.api_post_call(
                      p_return_status => l_return_status,
                      x_num_warnings  => l_number_of_warnings,
                      x_num_errors    => l_number_of_errors,
                      p_msg_data      => l_msg_data
                      );
               --

  IF l_number_of_warnings > 0 THEN
      x_return_status := wsh_util_core.g_ret_sts_warning;
  END IF;

    -- report success
  IF FND_API.TO_BOOLEAN(p_commit) THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get (
    p_count => x_msg_count,
    p_data  => x_msg_data,
                p_encoded => FND_API.G_FALSE
    );

   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
--
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO UPDATE_SHIPPING_ATTR_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                wsh_util_core.add_message(x_return_status);
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );

       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
         --
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO UPDATE_SHIPPING_ATTR_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
               wsh_util_core.add_message(x_return_status, l_module_name);
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );
                  --

           IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
           END IF;
         --
         WHEN invalid_source_code THEN
              ROLLBACK TO UPDATE_SHIPPING_ATTR_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.Set_Name('WSH', 'WSH_INVALID_SOURCE_CODE');
              FND_MESSAGE.SET_TOKEN('SOURCE_CODE',p_source_code );
              WSH_UTIL_CORE.Add_Message(x_return_status);

              FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE
                  );

                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_SOURCE_CODE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_SOURCE_CODE');
                 END IF;
          --
         WHEN Others THEN
                 ROLLBACK TO UPDATE_SHIPPING_ATTR_PUB;
               x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
               WSH_UTIL_CORE.add_message (x_return_status);
               WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_PUB.Update_Shipping_Attributes')
          ;

              FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE
                  );

              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                 WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
             END IF;
--
END Update_Shipping_Attributes;


--Overloaded Update_Shipping_Attributes


--========================================================================
-- PROCEDURE : Update_Shipping_Attributes   (overloaded)
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         initialize message stack
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--            p_changed_attributes    changed attributes for delivery details
--             p_source_code           source system
--            p_serial_range_tab       serial number range
--
--
-- COMMENT   : Validates Organization_id and Organization_code against view
--             org_organization_definitions. If both values are
--             specified then only Org_Id is used
--========================================================================

PROCEDURE Update_Shipping_Attributes (
  -- Standard parameters
  p_api_version_number     IN     NUMBER
, p_init_msg_list          IN     VARCHAR2
, p_commit                 IN     VARCHAR2
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2

  -- Procedure specific parameters
, p_changed_attributes    IN     WSH_DELIVERY_DETAILS_PUB.ChangedAttributeTabType
, p_source_code            IN     VARCHAR2
, p_container_flag         IN     VARCHAR2
, p_serial_range_tab       IN     WSH_GLBL_VAR_STRCT_GRP.ddSerialRangeTabType
)
IS

l_valid_index_tab      WSH_UTIL_CORE.Id_Tab_Type;
l_valid_ids_tab        WSH_UTIL_CORE.Id_Tab_Type;
l_msg_summary varchar2(2000)  := NULL;
l_msg_details varchar2(4000)  := NULL;
l_return_status       VARCHAR2(30);
l_counter         NUMBER;
l_index               NUMBER;
l_api_version_number  NUMBER := 1.0;
l_api_name            VARCHAR2(30) := 'Update_Shipping_Attributes2';
l_ship_to_location_id   NUMBER;
invalid_source_code     EXCEPTION;

l_serial_range_tab   WSH_GLBL_VAR_STRCT_GRP.ddSerialRangeTabType;

m     NUMBER := 0;


      -- Harmonization Project
      l_detail_info_tab WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type;
      l_in_rec    WSH_GLBL_VAR_STRCT_GRP.detailInRecType;
      l_lpn_ids       wsh_util_core.id_Tab_type;
      l_out_Rec       WSH_GLBL_VAR_STRCT_GRP.detailOutRecType;
      l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(32767);
  l_number_of_errors    NUMBER := 0;
  l_number_of_warnings  NUMBER := 0;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_SHIPPING_ATTRIBUTES';
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
        SAVEPOINT UPDATE_SHIPPING_ATTR_PUB2;

        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            --
            WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
            WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
            WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
            WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
            WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_FLAG',P_CONTAINER_FLAG);
            WSH_DEBUG_SV.log(l_module_name,'P_SERIAL_RANGE_TAB.COUNT', P_SERIAL_RANGE_TAB.COUNT);


        END IF;
        --

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  --  Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(
    l_api_version_number,
    p_api_version_number,
    l_api_name,
    G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    --  Initialize message stack if required
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- <start of API logic>
        -- sperera source_code has to be 'OE' or 'WSH'
  IF (NVL(p_source_code, FND_API.G_MISS_CHAR) NOT IN ('WSH', 'OE')) THEN
    RAISE invalid_source_code;
  END IF;

       -- call the copy procedure here

       Copy_Attributes(x_detail_info_tab => l_detail_info_tab,
                       x_changed_attributes=>p_changed_attributes);

  -- frontport bug 5049214 - Trim leading spaces from serial number
  l_serial_range_tab := p_serial_range_tab;
  l_index            := l_serial_range_tab.FIRST;
  WHILE l_index IS NOT NULL LOOP
    l_serial_range_tab(l_index).from_serial_number :=
        LTRIM(RTRIM(l_serial_range_tab(l_index).from_serial_number));
    l_serial_range_tab(l_index).to_serial_number   :=
        LTRIM(RTRIM(l_serial_range_tab(l_index).to_serial_number));
    l_index := l_serial_range_tab.NEXT(l_index);
  END LOOP;

       l_in_rec.caller := 'WSH_PUB';
       l_in_rec.action_code := 'UPDATE';
       --Bug 8900333: Locking the delivery details before calling the group API for further processing
       BEGIN
            savepoint before_lock;
            l_index := l_detail_info_tab.FIRST;
            WHILE l_index IS NOT NULL LOOP
                l_valid_index_tab(l_index) :=l_index;
                l_index := l_detail_info_tab.NEXT(l_index);
            END LOOP;
            IF l_valid_index_tab.count >0 THEN
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.LOCK_DELIVERY_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                wsh_delivery_details_pkg.Lock_Delivery_Details(
                    p_rec_attr_tab          => l_detail_info_tab,
                    p_caller                => l_In_rec.caller,
                    p_valid_index_tab       => l_valid_index_tab,
                    x_valid_ids_tab         => l_valid_ids_tab,
                    x_return_status         => l_return_status
                    );

                wsh_util_core.api_post_call(
                    p_return_status => l_return_status,
                    x_num_warnings  => l_number_of_warnings,
                    x_num_errors    => l_number_of_errors,
                    p_msg_data      => l_msg_data,
                    p_raise_error_flag => FALSE
                    );
                IF l_return_status <> wsh_util_core.g_ret_sts_success THEN
                    wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;
            EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN
                    ROLLBACK TO  before_lock;
                    IF l_debug_on THEN
                        wsh_debug_sv.logmsg(l_module_name, 'FND_API.G_EXC_ERROR exception has occured',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                    END IF;
                    RAISE FND_API.G_EXC_ERROR ;
                WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                    ROLLBACK TO before_lock;
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                    END IF;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                WHEN OTHERS THEN
                    ROLLBACK TO before_lock;
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
                    END IF;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END;

          /* Patchset I: Harmonization Project. Call group API
           All validations done by Group API */

             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_GRP.CREATE_UPDATE_DELIVERY_DETAIL',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;

       wsh_delivery_details_grp.create_update_delivery_detail(
       p_api_version_number  => p_api_version_number,
       p_init_msg_list           => FND_API.G_FALSE,
       p_commit                  => FND_API.G_FALSE,
       x_return_status           => l_return_status,
       x_msg_count               => l_msg_count,
       x_msg_data                => l_msg_data,
       p_detail_info_tab         => l_detail_info_tab,
       p_IN_rec                  => l_in_rec,
       x_OUT_rec                 => l_out_rec,
       p_serial_range_tab        => l_serial_range_tab
       );

             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             --
             wsh_util_core.api_post_call(
                      p_return_status => l_return_status,
                      x_num_warnings  => l_number_of_warnings,
                      x_num_errors    => l_number_of_errors,
                      p_msg_data      => l_msg_data
                      );
               --

  IF l_number_of_warnings > 0 THEN
      x_return_status := wsh_util_core.g_ret_sts_warning;
  END IF;
    -- report success
  IF FND_API.TO_BOOLEAN(p_commit) THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get (
    p_count => x_msg_count,
    p_data  => x_msg_data,
                p_encoded => FND_API.G_FALSE
    );

   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
--
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO UPDATE_SHIPPING_ATTR_PUB2;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                wsh_util_core.add_message(x_return_status);
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );

       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
         --
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO UPDATE_SHIPPING_ATTR_PUB2;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
               wsh_util_core.add_message(x_return_status, l_module_name);
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );
                  --

           IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
           END IF;
         --
         WHEN invalid_source_code THEN
              ROLLBACK TO UPDATE_SHIPPING_ATTR_PUB2;
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.Set_Name('WSH', 'WSH_INVALID_SOURCE_CODE');
              FND_MESSAGE.SET_TOKEN('SOURCE_CODE',p_source_code );
              WSH_UTIL_CORE.Add_Message(x_return_status);

              FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE
                  );

                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_SOURCE_CODE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_SOURCE_CODE');
                 END IF;
          --
         WHEN Others THEN
                 ROLLBACK TO UPDATE_SHIPPING_ATTR_PUB2;
               x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
               WSH_UTIL_CORE.add_message (x_return_status);
               WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_PUB.Update_Shipping_Attributes')
          ;

              FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE
                  );
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                 WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
             END IF;
--
END Update_Shipping_Attributes;


PROCEDURE Get_Detail_Status(
  p_delivery_detail_id  IN NUMBER
, x_line_status         OUT NOCOPY  VARCHAR2
, x_return_status       OUT NOCOPY  VARCHAR2
)
IS
CURSOR del_assign IS
SELECT delivery_id, parent_delivery_detail_id
FROM wsh_delivery_assignments_v
WHERE delivery_detail_id = p_delivery_detail_id;
l_assign_rec del_assign%ROWTYPE;

CURSOR del_status(c_del_id NUMBER) IS
SELECT status_code
FROM wsh_new_deliveries
WHERE delivery_id = c_del_id;

l_del_status  VARCHAR2(100) := NULL;
l_msg_summary VARCHAR2(3000);
x_msg_count   NUMBER;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DETAIL_STATUS';
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
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- get line status for delivery detail
  OPEN del_assign;
  FETCH del_assign INTO l_assign_rec;
  IF (l_assign_rec.delivery_id IS NOT NULL) THEN
    OPEN del_status(l_assign_rec.delivery_id);
    FETCH del_status INTO l_del_status;
    CLOSE del_status;
  END IF;
  CLOSE del_assign;

  IF (l_del_status IN ('CO', 'IT', 'CL')) THEN
    x_line_status := 'SIC';
  ELSIF (l_assign_rec.parent_delivery_detail_id IS NOT NULL) THEN
    x_line_status := 'PK';
  ELSIF( l_assign_rec.parent_delivery_detail_id IS NULL) THEN
    x_line_status := 'OK';
  ELSE
    NULL;
  END IF;

/*
  EXCEPTION
  when others then
    wsh_util_core.default_handler('WSH_SHIP_CONFRIM_ACTIONS.SHIP_CONFIRM_A_TRIP_STOP');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
    if x_msg_count > 1 then
      x_msg_data := l_msg_summary || l_msg_details;
    else
      x_msg_data := l_msg_summary;
    end if;
    */
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
END get_detail_status;

PROCEDURE Autocreate_Deliveries(
  -- Standard parameters
  p_api_version_number     IN     NUMBER
, p_init_msg_list          IN     VARCHAR2
, p_commit                 IN     VARCHAR2
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_line_rows              IN     WSH_UTIL_CORE.id_tab_type
, x_del_rows                  OUT NOCOPY  wsh_util_core.id_tab_type
)
IS
      l_dummy_rows               WSH_UTIL_CORE.id_tab_type;
      l_api_version_number    NUMBER := 1.0;
      l_api_name    CONSTANT  VARCHAR2(30):= 'Autocreate_Deliveries';
      l_return_status            VARCHAR2(30);
      autocreate_delivery_failed  EXCEPTION;
      l_msg_summary varchar2(2000)  := NULL;
      l_msg_details varchar2(4000)  := NULL;

-- Harmonization Project
      l_action_prms             WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
      l_action_out_rec         WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type;
      l_dummy_qty               NUMBER;
      l_dummy_qty2              NUMBER;
      l_dummy_ids               wsh_util_core.id_tab_type;
      l_msg_count                 NUMBER;
      l_msg_data                  VARCHAR2(32767);
      l_number_of_errors    NUMBER := 0;
      l_number_of_warnings  NUMBER := 0;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'AUTOCREATE_DELIVERIES';
--
BEGIN
    -- Standard begin of API savepoint
        --
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
        --
        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;
        --
        SAVEPOINT AUTOCREATE_DEL_PUB;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            --
            WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
            WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
            WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
        END IF;
        --


  IF NOT FND_API.compatible_api_call(
    l_api_version_number,
    p_api_version_number,
    l_api_name,
    G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_boolean(p_init_msg_list)  THEN
    FND_MSG_PUB.initialize;
  END IF;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        l_action_prms.caller := 'WSH_PUB';
        l_action_prms.action_code := 'AUTOCREATE-DEL';

          /* Patchset I: Harmonization Project. Call group API
           All validations done by Group API */

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTERFACE_GRP.DELIVERY_DETAIL_ACTION',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

        wsh_interface_grp.delivery_detail_action(
            p_api_version_number    => p_api_version_number,
            p_init_msg_list         => FND_API.G_FALSE,
            p_commit                => FND_API.G_FALSE,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data,
            p_detail_id_tab         => p_line_rows,
            p_action_prms           => l_action_prms ,
            x_action_out_rec        => l_action_out_rec);

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );

         x_del_rows := l_action_out_rec.delivery_id_tab;

    IF l_number_of_warnings > 0 THEN
       x_return_status := wsh_util_core.g_ret_sts_warning;
    END IF;


        FND_MSG_PUB.Count_And_Get
          (
      p_count =>  x_msg_count,
            p_data  =>  x_msg_data,
            p_encoded => FND_API.G_FALSE
          );


  IF FND_API.TO_BOOLEAN(p_commit) THEN
    COMMIT WORK;
  END IF;


        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;
--
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO AUTOCREATE_DEL_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                wsh_util_core.add_message(x_return_status);
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );

          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
         END IF;

         WHEN autocreate_delivery_failed THEN
              ROLLBACK TO AUTOCREATE_DEL_PUB;
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );

            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'AUTOCREATE_DELIVERY_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
               WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:AUTOCREATE_DELIVERY_FAILED');
           END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO AUTOCREATE_DEL_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
               wsh_util_core.add_message(x_return_status, l_module_name);
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );
                  --

           IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
           END IF;
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                ROLLBACK TO AUTOCREATE_DEL_PUB;
               wsh_util_core.add_message(x_return_status, l_module_name);
               WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_PUB.Autocreate_Deliveries');
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );
    --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
            END IF;
   --
END Autocreate_Deliveries;

PROCEDURE Autocreate_del_trip(
  -- Standard parameters
  p_api_version_number     IN     NUMBER
, p_init_msg_list          IN     VARCHAR2
, p_commit                 IN     VARCHAR2
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_line_rows              IN     WSH_UTIL_CORE.id_tab_type
, x_del_rows                  OUT NOCOPY  WSH_UTIL_CORE.id_tab_type
, x_trip_id                   OUT NOCOPY  NUMBER
, x_trip_name                 OUT NOCOPY  VARCHAR2
)
IS

  l_trip_rows WSH_UTIL_CORE.id_tab_type;
  l_first    NUMBER := 0;
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'AUTOCREATE_DEL_TRIP - single trip';

BEGIN
    -- Standard begin of API savepoint
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    SAVEPOINT AUTOCREATE_TRIP_PUB;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
    END IF;
    --


    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PUB.Autocreate_del_trip - multiple trips',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;


    WSH_DELIVERY_DETAILS_PUB.Autocreate_del_trip(
      -- Standard parameters
      p_api_version_number  => p_api_version_number,
      p_init_msg_list       => p_init_msg_list,
      p_commit              => p_commit,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      p_line_rows           => p_line_rows,
      x_del_rows            => x_del_rows,
      x_trip_rows           => l_trip_rows );

    IF l_trip_rows.count > 0 THEN
      l_first := l_trip_rows.first;
      x_trip_id := l_trip_rows(l_first);
      IF x_trip_id IS NOT NULL THEN
        x_trip_name := wsh_trips_pvt.get_name(x_trip_id);
      ELSE
        x_trip_name := NULL;
      END IF;
    ELSE
      x_trip_id := NULL;
      x_trip_name := NULL;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

  EXCEPTION


    WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO AUTOCREATE_TRIP_PUB;
      wsh_util_core.add_message(x_return_status, l_module_name);
      WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_PUB.Autocreate_Del_Trip');
      FND_MSG_PUB.Count_And_Get
        (
           p_count  => x_msg_count,
           p_data  =>  x_msg_data,
           p_encoded => FND_API.G_FALSE
        );

      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

END Autocreate_del_trip;


PROCEDURE Autocreate_del_trip(
  -- Standard parameters
  p_api_version_number     IN     NUMBER
, p_init_msg_list          IN     VARCHAR2
, p_commit                 IN     VARCHAR2
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_line_rows              IN     WSH_UTIL_CORE.id_tab_type
, x_del_rows                  OUT NOCOPY  WSH_UTIL_CORE.id_tab_type
, x_trip_rows                   OUT NOCOPY  WSH_UTIL_CORE.id_tab_type
)
IS
      l_api_name    CONSTANT  VARCHAR2(30):= 'Autocreate_del_trip';
      l_api_version_number      CONSTANT NUMBER := 1.0;
      l_return_status           VARCHAR2(30);
      l_msg_summary             varchar2(2000)  := NULL;
      l_msg_details             varchar2(4000)  := NULL;
      l_org_rows    wsh_util_core.id_tab_type; -- bug 1668578
      autocreate_trip_failed    EXCEPTION;

      -- Harmonization Project
      l_action_prms             WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
      l_action_out_rec         WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type;
      l_dummy_qty               NUMBER;
      l_dummy_qty2              NUMBER;
      l_del_rows                wsh_util_core.id_tab_type;
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(32767);
  l_number_of_errors    NUMBER := 0;
  l_number_of_warnings  NUMBER := 0;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'AUTOCREATE_DEL_TRIP - multiple trips';
--
BEGIN
    -- Standard begin of API savepoint
        --
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
        --
        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;
        --
        SAVEPOINT AUTOCREATE_TRIP_PUB;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            --
            WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
            WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
            WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
        END IF;
        --

  IF NOT FND_API.compatible_api_call(
    l_api_version_number,
    p_api_version_number,
    l_api_name,
    G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_boolean(p_init_msg_list)  THEN
    FND_MSG_PUB.initialize;
  END IF;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        l_action_prms.caller := 'WSH_PUB';
        l_action_prms.action_code := 'AUTOCREATE-TRIP';

          /* Patchset I: Harmonization Project. Call group API
           All validations done by Group API */

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTERFACE_GRP.DELIVERY_DETAIL_ACTION',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

        wsh_interface_grp.delivery_detail_action(
            p_api_version_number    => p_api_version_number,
            p_init_msg_list         => FND_API.G_FALSE,
            p_commit                => FND_API.G_FALSE,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data,
            p_detail_id_tab         => p_line_rows,
            p_action_prms           => l_action_prms ,
            x_action_out_rec        => l_action_out_rec);

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );

            x_del_rows := l_action_out_rec.delivery_id_tab;
            x_trip_rows:= l_action_out_rec.result_id_tab;

  IF l_number_of_warnings > 0 THEN
      x_return_status := wsh_util_core.g_ret_sts_warning;
  END IF;

  IF FND_API.TO_BOOLEAN(p_commit) THEN
    COMMIT WORK;
  END IF;

        FND_MSG_PUB.Count_And_Get
          (
      p_count =>  x_msg_count,
            p_data  =>  x_msg_data,
            p_encoded => FND_API.G_FALSE
          );


      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO AUTOCREATE_TRIP_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                wsh_util_core.add_message(x_return_status);
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );

       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO AUTOCREATE_TRIP_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
               wsh_util_core.add_message(x_return_status, l_module_name);
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );
                  --

           IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
           END IF;


        WHEN autocreate_trip_failed THEN
                ROLLBACK TO AUTOCREATE_TRIP_PUB;
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                   FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );

  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'AUTOCREATE_TRIP_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:AUTOCREATE_TRIP_FAILED');
  END IF;

        WHEN OTHERS THEN

                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                ROLLBACK TO AUTOCREATE_TRIP_PUB;
               wsh_util_core.add_message(x_return_status, l_module_name);
               WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_PUB.Autocreate_Del_Trip');
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );
    --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
            END IF;
  --
END Autocreate_del_trip;


PROCEDURE Copy_Attributes(
  x_detail_info_tab OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type
, x_changed_attributes IN WSH_DELIVERY_DETAILS_PUB.ChangedAttributeTabType)

IS

l_index    NUMBER;
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'COPY_ATTRIBUTES';

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
            WSH_DEBUG_SV.log(l_module_name,'X_CHANGED_ATTRIBUTES.COUNT', X_CHANGED_ATTRIBUTES.COUNT);

        END IF;

        l_index := x_changed_attributes.FIRST;


        WHILE l_index IS NOT NULL
        LOOP

             x_detail_info_tab(l_index).source_header_id :=     x_changed_attributes(l_index).source_header_id;
             x_detail_info_tab(l_index).source_line_id   :=     x_changed_attributes(l_index).source_line_id;
             x_detail_info_tab(l_index).sold_to_contact_id :=     x_changed_attributes(l_index).sold_to_contact_id;
             x_detail_info_tab(l_index).ship_to_contact_id :=     x_changed_attributes(l_index).ship_to_contact_id;
             x_detail_info_tab(l_index).deliver_to_contact_id :=     x_changed_attributes(l_index).deliver_to_contact_id;
             x_detail_info_tab(l_index).intmed_ship_to_contact_id :=     x_changed_attributes(l_index).intmed_ship_to_contact_id;
             x_detail_info_tab(l_index).ship_tolerance_above :=     x_changed_attributes(l_index).ship_tolerance_above;
             x_detail_info_tab(l_index).ship_tolerance_below :=     x_changed_attributes(l_index).ship_tolerance_below;
             x_detail_info_tab(l_index).preferred_grade :=     x_changed_attributes(l_index).preferred_grade;
             x_detail_info_tab(l_index).subinventory :=     x_changed_attributes(l_index).subinventory;
             x_detail_info_tab(l_index).revision :=     x_changed_attributes(l_index).revision;
             x_detail_info_tab(l_index).lot_number :=     x_changed_attributes(l_index).lot_number;
-- HW OPMCONV - No need for sublot_number
--           x_detail_info_tab(l_index).sublot_number :=     x_changed_attributes(l_index).sublot_number;
             x_detail_info_tab(l_index).customer_requested_lot_flag :=     x_changed_attributes(l_index).customer_requested_lot_flag;
             x_detail_info_tab(l_index).serial_number :=     x_changed_attributes(l_index).serial_number;
             x_detail_info_tab(l_index).to_serial_number := x_changed_attributes(l_index).to_serial_number;
             x_detail_info_tab(l_index).locator_id :=     x_changed_attributes(l_index).locator_id;
             x_detail_info_tab(l_index).date_requested :=     x_changed_attributes(l_index).date_requested;
             x_detail_info_tab(l_index).date_scheduled :=     x_changed_attributes(l_index).date_scheduled;
             x_detail_info_tab(l_index).master_container_item_id :=     x_changed_attributes(l_index).master_container_item_id;
             x_detail_info_tab(l_index).detail_container_item_id :=     x_changed_attributes(l_index).detail_container_item_id;
             x_detail_info_tab(l_index).ship_method_code :=     x_changed_attributes(l_index).shipping_method_code;
             x_detail_info_tab(l_index).carrier_id :=     x_changed_attributes(l_index).carrier_id;
             x_detail_info_tab(l_index).freight_terms_code :=     x_changed_attributes(l_index).freight_terms_code;
             x_detail_info_tab(l_index).shipment_priority_code :=     x_changed_attributes(l_index).shipment_priority_code;
             x_detail_info_tab(l_index).fob_code :=     x_changed_attributes(l_index).fob_code;
             x_detail_info_tab(l_index).dep_plan_required_flag :=     x_changed_attributes(l_index).dep_plan_required_flag;
             x_detail_info_tab(l_index).customer_prod_seq :=     x_changed_attributes(l_index).customer_prod_seq;
             x_detail_info_tab(l_index).customer_dock_code :=     x_changed_attributes(l_index).customer_dock_code;
             x_detail_info_tab(l_index).gross_weight :=     x_changed_attributes(l_index).gross_weight;
             x_detail_info_tab(l_index).net_weight :=     x_changed_attributes(l_index).net_weight;
             x_detail_info_tab(l_index).weight_uom_code :=     x_changed_attributes(l_index).weight_uom_code;
             x_detail_info_tab(l_index).volume :=     x_changed_attributes(l_index).volume;
             x_detail_info_tab(l_index).volume_uom_code :=     x_changed_attributes(l_index).volume_uom_code;
             x_detail_info_tab(l_index).top_model_line_id :=     x_changed_attributes(l_index).top_model_line_id;
             x_detail_info_tab(l_index).ship_set_id :=     x_changed_attributes(l_index).ship_set_id;
             x_detail_info_tab(l_index).ato_line_id :=     x_changed_attributes(l_index).ato_line_id;
             x_detail_info_tab(l_index).arrival_set_id :=     x_changed_attributes(l_index).arrival_set_id;
             x_detail_info_tab(l_index).ship_model_complete_flag :=     x_changed_attributes(l_index).ship_model_complete_flag;
             x_detail_info_tab(l_index).cust_po_number :=     x_changed_attributes(l_index).cust_po_number;
             x_detail_info_tab(l_index).released_status :=     x_changed_attributes(l_index).released_status;
             x_detail_info_tab(l_index).packing_instructions :=     x_changed_attributes(l_index).packing_instructions;
             x_detail_info_tab(l_index).shipping_instructions :=     x_changed_attributes(l_index).shipping_instructions;
             x_detail_info_tab(l_index).container_name :=     x_changed_attributes(l_index).container_name;
             x_detail_info_tab(l_index).container_flag :=     x_changed_attributes(l_index).container_flag ;
             x_detail_info_tab(l_index).delivery_detail_id :=     x_changed_attributes(l_index).delivery_detail_id;
             x_detail_info_tab(l_index).shipped_quantity :=     x_changed_attributes(l_index).shipped_quantity   ;
             x_detail_info_tab(l_index).cycle_count_quantity :=     x_changed_attributes(l_index).cycle_count_quantity  ;
             /* Bug 3055126  added shipped_quantity 2 and cycle_count_quantity2 and removed from defaulting below */
             x_detail_info_tab(l_index).shipped_quantity2            :=   x_changed_attributes(l_index).shipped_quantity2   ;
             x_detail_info_tab(l_index).cycle_count_quantity2        :=   x_changed_attributes(l_index).cycle_count_quantity2  ;x_detail_info_tab(l_index).tracking_number :=     x_changed_attributes(l_index).tracking_number ;
             x_detail_info_tab(l_index).attribute_category :=      x_changed_attributes(l_index).attribute_category;
             x_detail_info_tab(l_index).attribute1 :=     x_changed_attributes(l_index).attribute1;
             x_detail_info_tab(l_index).attribute2 :=     x_changed_attributes(l_index).attribute2;
             x_detail_info_tab(l_index).attribute3 :=     x_changed_attributes(l_index).attribute3;
             x_detail_info_tab(l_index).attribute4 :=     x_changed_attributes(l_index).attribute4;
             x_detail_info_tab(l_index).attribute5 :=     x_changed_attributes(l_index).attribute5;
             x_detail_info_tab(l_index).attribute6 :=     x_changed_attributes(l_index).attribute6;
             x_detail_info_tab(l_index).attribute7 :=     x_changed_attributes(l_index).attribute7;
             x_detail_info_tab(l_index).attribute8 :=     x_changed_attributes(l_index).attribute8;
             x_detail_info_tab(l_index).attribute9 :=     x_changed_attributes(l_index).attribute9;
             x_detail_info_tab(l_index).attribute10 :=     x_changed_attributes(l_index).attribute10;
             x_detail_info_tab(l_index).attribute11 :=     x_changed_attributes(l_index).attribute11;
             x_detail_info_tab(l_index).attribute12 :=     x_changed_attributes(l_index).attribute12;
             x_detail_info_tab(l_index).attribute13 :=     x_changed_attributes(l_index).attribute13;
             x_detail_info_tab(l_index).attribute14 :=     x_changed_attributes(l_index).attribute14;
             x_detail_info_tab(l_index).attribute15 :=     x_changed_attributes(l_index).attribute15;
-- Bug 3723831 :tp attributes also part of the public API update_shipping_attributes
             x_detail_info_tab(l_index).tp_attribute_category  :=     x_changed_attributes(l_index).tp_attribute_category;
             x_detail_info_tab(l_index).tp_attribute1          :=     x_changed_attributes(l_index).tp_attribute1;
             x_detail_info_tab(l_index).tp_attribute2          :=     x_changed_attributes(l_index).tp_attribute2;
             x_detail_info_tab(l_index).tp_attribute3          :=     x_changed_attributes(l_index).tp_attribute3;
             x_detail_info_tab(l_index).tp_attribute4          :=     x_changed_attributes(l_index).tp_attribute4;
             x_detail_info_tab(l_index).tp_attribute5          :=     x_changed_attributes(l_index).tp_attribute5;
             x_detail_info_tab(l_index).tp_attribute6          :=     x_changed_attributes(l_index).tp_attribute6;
             x_detail_info_tab(l_index).tp_attribute7          :=     x_changed_attributes(l_index).tp_attribute7;
             x_detail_info_tab(l_index).tp_attribute8          :=     x_changed_attributes(l_index).tp_attribute8;
             x_detail_info_tab(l_index).tp_attribute9          :=     x_changed_attributes(l_index).tp_attribute9;
             x_detail_info_tab(l_index).tp_attribute10         :=     x_changed_attributes(l_index).tp_attribute10;
             x_detail_info_tab(l_index).tp_attribute11         :=     x_changed_attributes(l_index).tp_attribute11;
             x_detail_info_tab(l_index).tp_attribute12         :=     x_changed_attributes(l_index).tp_attribute12;
             x_detail_info_tab(l_index).tp_attribute13         :=     x_changed_attributes(l_index).tp_attribute13;
             x_detail_info_tab(l_index).tp_attribute14         :=     x_changed_attributes(l_index).tp_attribute14;
             x_detail_info_tab(l_index).tp_attribute15         :=     x_changed_attributes(l_index).tp_attribute15;

-- J: W/V Changes
             x_detail_info_tab(l_index).filled_volume :=     x_changed_attributes(l_index).filled_volume;
	     -- Bug 4146352 : Added seal_code and load_seq_number.
	     --
             x_detail_info_tab(l_index).seal_code       :=     x_changed_attributes(l_index).seal_code;
             x_detail_info_tab(l_index).load_seq_number := x_changed_attributes(l_index).load_seq_number;
             /* Start of fix for Bug 2766446
             For those attributes that are not available in public api record,
             need to send G_MISS values so that the database values are used for such attributes */

             x_detail_info_tab(l_index).batch_id          :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).cancelled_quantity      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).cancelled_quantity2         :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).classification      :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).commodity_code_cat_id       :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).container_type_code       :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).country_of_origin      :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).currency_code      :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).cust_model_serial_number        :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).customer_id           := FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).customer_item_id      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).customer_job              :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).customer_production_line      :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).deliver_to_location_id      := FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).deliver_to_site_use_id      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).delivered_quantity      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).delivered_quantity2       :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).freight_class_cat_id      := FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).fill_percent      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).hazard_class_id      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).hold_code      :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).inspection_flag        :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).intmed_ship_to_location_id := FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).inv_interfaced_flag      :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).inventory_item_id      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).item_description      :=      FND_API.G_MISS_CHAR;
	     -- Bug 4146352 : Need to comment seal_code as this is now added to
	     -- the public api record structure.
             -- x_detail_info_tab(l_index).load_seq_number      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).lpn_id        :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).master_serial_number      :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).maximum_load_weight      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).maximum_volume      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).minimum_fill_percent      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).move_order_line_id      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).movement_id      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).mvt_stat_status      :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).oe_interfaced_flag      :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).org_id              := FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).organization_id     := FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).original_subinventory        :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).pickable_flag        :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).picked_quantity      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).picked_quantity2      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).project_id      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).quality_control_quantity      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).quality_control_quantity2       :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).received_quantity      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).received_quantity2      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).released_flag      :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).request_id      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).requested_quantity      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).requested_quantity_uom      :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).requested_quantity_uom2      :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).requested_quantity2        :=      FND_API.G_MISS_NUM;
	     -- Bug 4146352 : Need to comment seal_code as this is now added to
	     -- the public api record structure.
             -- x_detail_info_tab(l_index).seal_code      :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).ship_from_location_id    :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).ship_to_location_id      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).ship_to_site_use_id      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).source_code      :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).source_header_number      :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).source_header_type_id      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).source_header_type_name      :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).source_line_number      :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).source_line_set_id      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).split_from_detail_id      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).src_requested_quantity      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).src_requested_quantity_uom      :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).src_requested_quantity_uom2        :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).src_requested_quantity2       :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).task_id      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).transaction_temp_id      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).unit_number        :=      FND_API.G_MISS_CHAR;
             x_detail_info_tab(l_index).unit_price      :=      FND_API.G_MISS_NUM;
-- J: W/V Changes
             x_detail_info_tab(l_index).unit_weight      :=      FND_API.G_MISS_NUM;
             x_detail_info_tab(l_index).unit_volume      :=      FND_API.G_MISS_NUM;

             /* End of fix for  Bug 2766446 */

             l_index := x_changed_attributes.NEXT(l_index);
       END LOOP;

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;
    raise;


  WHEN OTHERS THEN

     wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_PUB.UPDATE_ATTRIBUTES');
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
     raise;

END Copy_Attributes;


END WSH_DELIVERY_DETAILS_PUB;

/
