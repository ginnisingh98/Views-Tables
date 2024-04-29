--------------------------------------------------------
--  DDL for Package Body WSH_DELIVERY_DETAILS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DELIVERY_DETAILS_GRP" as
/* $Header: WSHDDGPB.pls 120.28.12010000.3 2009/09/08 10:30:01 selsubra ship $ */

  -- standard global constants
  G_PKG_NAME CONSTANT VARCHAR2(30)    := 'WSH_DELIVERY_DETAILS_GRP';
  p_message_type  CONSTANT VARCHAR2(1)  := 'E';
  c_wms_code_present VARCHAR2(1) := 'Y';

-- anxsharm for Load Tender
-- add delivery id and parent_delivery_detail_id
CURSOR c_original_detail_cur(p_detail_id  NUMBER) IS
     SELECT wdd.source_line_id,
           wdd.organization_id,
           wdd.inventory_item_id,
           wdd.serial_number,
           wdd.to_serial_number, -- Bug fix 2652300
           wdd.top_model_line_id, -- Bug fix 2652300
           wdd.transaction_temp_id,
           wdd.locator_id,
           wdd.revision,
           wdd.subinventory,
           wdd.lot_number,
           wdd.released_status,
           wdd.requested_quantity_uom,
           wdd.gross_weight,
           wdd.net_weight,
           wdd.weight_uom_code,
           wdd.volume,
           wdd.volume_uom_code,
           wdd.container_name,
           wdd.container_flag,
           wdd.master_serial_number,
           wdd.inspection_flag,
           wdd.cycle_count_quantity,
           wdd.shipped_quantity,
           wdd.requested_quantity,
           wdd.picked_quantity,
-- PK added for Bug 3055126 qty2's
           wdd.cycle_count_quantity2,
           wdd.shipped_quantity2,
           wdd.requested_quantity2,
           wdd.picked_quantity2,
           wdd.pickable_flag,
           wda.delivery_id,
           wda.parent_delivery_detail_id
     FROM wsh_delivery_details wdd,
          wsh_delivery_assignments_v wda
     WHERE wdd.delivery_detail_id = p_detail_id
       AND wdd.delivery_detail_id = wda.delivery_detail_id;


-- Forward Declarations for local procedures
PROCEDURE  Create_Delivery_Detail(
                p_detail_info_tab      IN   WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type,
                p_detail_IN_rec        IN   WSH_GLBL_VAR_STRCT_GRP.detailInRecType,
                p_valid_index_tab      IN   wsh_util_core.id_tab_type,
                x_detail_OUT_rec       OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.detailOutRecType,
                x_return_status        OUT NOCOPY VARCHAR2,
                x_msg_count            OUT NOCOPY     NUMBER,
                x_msg_data             OUT NOCOPY     VARCHAR2
                );

PROCEDURE  Validate_Delivery_Detail(
                x_detail_info_tab  IN  OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type,
                p_in_detail_tab    IN   WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type,
                p_action           IN  VARCHAR2,
                p_validation_tab   IN  wsh_util_core.Id_Tab_Type,
                p_caller           IN  varchar2,
                x_valid_index_tab  OUT NOCOPY WSH_UTIL_CORE.Id_Tab_Type,
                x_details_marked   OUT NOCOPY WSH_UTIL_CORE.Id_Tab_Type,
                x_detail_tender_tab  OUT NOCOPY WSH_UTIL_CORE.Id_Tab_Type,
                x_return_status    OUT NOCOPY VARCHAR2,
                x_msg_count        OUT NOCOPY     NUMBER,
                x_msg_data         OUT NOCOPY     VARCHAR2,
                p_in_rec           IN  WSH_GLBL_VAR_STRCT_GRP.detailInRecType,
                p_serial_range_tab IN  WSH_GLBL_VAR_STRCT_GRP.ddSerialRangeTabType
            );

PROCEDURE  Update_Delivery_Detail(
                p_detail_info_tab     IN        WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type ,
                p_valid_index_tab     IN  wsh_util_core.id_tab_type,
                x_return_status       OUT NOCOPY  varchar2,
                x_msg_count            OUT NOCOPY     NUMBER,
                x_msg_data             OUT NOCOPY     VARCHAR2,
                p_caller               IN             VARCHAR2 DEFAULT NULL
                );

    -- ---------------------------------------------------------------------
    -- Procedure: Cancel_Delivery_Detail
    --
    -- Parameters:
    --
    -- Description:  This local procedure is the new API for wrapping the logic of CANCEL of delivery details
    -- Created:   Harmonization Project. Patchset I
    -- -----------------------------------------------------------------------

PROCEDURE  Cancel_Delivery_Detail(
                p_detail_info_tab     IN  WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type ,
                x_return_status       OUT NOCOPY      VARCHAR2,
                x_msg_count           OUT NOCOPY      NUMBER,
                x_msg_data            OUT NOCOPY      VARCHAR2,
                p_caller              IN              VARCHAR2 DEFAULT NULL
    );



PROCEDURE Validate_Detail_Line(
                x_detail_rec          IN OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
                p_in_detail_rec    IN   WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
                p_original_rec        IN   c_original_detail_cur%ROWTYPE,
                p_validation_tab      IN   WSH_UTIL_CORE.id_tab_type,
                x_mark_reprice_flag   OUT NOCOPY VARCHAR2,
                x_return_status       OUT NOCOPY VARCHAR2,
                x_msg_count           OUT NOCOPY NUMBER,
                x_msg_data            OUT NOCOPY VARCHAR2,
                p_in_rec              IN  WSH_GLBL_VAR_STRCT_GRP.detailInRecType,
                p_serial_range_tab    IN  WSH_GLBL_VAR_STRCT_GRP.ddSerialRangeTabType
                );

PROCEDURE Validate_Detail_Container(
                x_detail_rec          IN OUT NOCOPY  WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
                p_original_rec        IN   c_original_detail_cur%ROWTYPE,
                p_validation_tab      IN   WSH_UTIL_CORE.id_tab_type,
                x_mark_reprice_flag   OUT  NOCOPY VARCHAR2,
                x_return_status       OUT  NOCOPY VARCHAR2,
                x_msg_count           OUT  NOCOPY NUMBER,
                x_msg_data            OUT  NOCOPY VARCHAR2
                );

PROCEDURE Validate_Detail_Common(
                x_detail_rec          IN OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
                p_original_rec        IN   c_original_detail_cur%ROWTYPE,
                p_validation_tab      IN   wsh_util_core.id_tab_type,
                x_mark_reprice_flag   OUT  NOCOPY VARCHAR2,
                x_return_status       OUT  NOCOPY VARCHAR2,
                x_msg_count           OUT  NOCOPY NUMBER,
                x_msg_data            OUT  NOCOPY VARCHAR2
                );

PROCEDURE get_serial_quantity(
          p_transaction_temp_id  IN  NUMBER,
          p_serial_number        IN  VARCHAR2,
          p_to_serial_number     IN  VARCHAR2,
          p_shipped_quantity     IN  VARCHAR2,
          x_serial_qty           OUT NOCOPY NUMBER,
          x_return_status        OUT NOCOPY VARCHAR2);

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
   p_api_version        IN              NUMBER,
   p_init_msg_list      IN              VARCHAR2,
   p_commit             IN              VARCHAR2,
   p_validation_level   IN              NUMBER,
   x_return_status      OUT NOCOPY      VARCHAR2,
   x_msg_count          OUT NOCOPY      NUMBER,
   x_msg_data           OUT NOCOPY      VARCHAR2,
   -- procedure specific parameters
   p_tabofdeldets       IN              WSH_UTIL_CORE.id_tab_type,
   p_action             IN              VARCHAR2,
   p_delivery_id        IN              NUMBER,
   p_delivery_name      IN              VARCHAR2,
   p_action_prms  IN WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type   -- J-IB-NPARIKH
) IS
-- Standard call to check for call compatibility
   l_api_version        CONSTANT NUMBER := 1.0;
   l_api_name           CONSTANT VARCHAR2(30) := 'delivery_detail_to_delivery';
   l_return_status               VARCHAR2(30) := NULL;
   l_delivery_id                 NUMBER := NULL;
   l_cont_ins_id                 NUMBER := NULL;
   l_tabofdeldets                wsh_util_core.id_tab_type;
   l_msg_summary                 VARCHAR2(2000) := NULL;
   l_msg_details                 VARCHAR2(4000) := NULL;
   l_del_params                  wsh_delivery_autocreate.grp_attr_tab_type;
   wsh_no_del_det_tbl            EXCEPTION;
   wsh_no_delivery_id            EXCEPTION;
   wsh_no_delivery               EXCEPTION; /*2777869*/
   wsh_invalid_delivery_id       EXCEPTION; /*2777869*/
   wsh_invalid_action            EXCEPTION;

   CURSOR c_delivery_record IS
      SELECT delivery_id
        FROM wsh_new_deliveries
       WHERE NAME = p_delivery_name;

/*2777869*/
    CURSOR c_delivery_id is
      SELECT delivery_id
      FROM  wsh_new_deliveries
      WHERE delivery_id = p_delivery_id;

   -- deliveryMerge
   CURSOR c_get_assigned_delivery (c_delivery_detail_id NUMBER) IS
      SELECT wda.delivery_id
      FROM   wsh_delivery_assignments_v wda,
             wsh_delivery_details wdd
      WHERE  wda.delivery_detail_id = c_delivery_detail_id
      AND    wda.delivery_detail_id = wdd.delivery_detail_id
      AND    wdd.container_flag = 'N'
      AND    NVL(wdd.line_direction,'O') in ('O','IO');
   --
   l_debug_on                    BOOLEAN;
   --
   l_module_name        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_pkg_name || '.' || 'DETAIL_TO_DELIVERY';

   -- Patchset I: Harmonization Project
   l_pack_status_dummy           VARCHAR2(100);
   l_msg_data                    VARCHAR2(32767);

-- anxsharm for Load Tender
   l_trip_id_tab                 wsh_util_core.id_tab_type;
   l_det_tab                     wsh_util_core.id_tab_type;
   l_number_of_errors            NUMBER := 0;
   l_number_of_warnings          NUMBER := 0;
   --
   l_cnt                         NUMBER;
   i                             number;

   -- deliveryMerge
   l_adjust_planned_del_tab      wsh_util_core.id_tab_type;
   l_delivery_already_included   boolean;
   --LPN Convergence
   e_invalid_quantity EXCEPTION;

BEGIN
   --
   l_debug_on := wsh_debug_interface.g_debug;

   --
   IF l_debug_on IS NULL THEN
      l_debug_on := wsh_debug_sv.is_debug_enabled;
   END IF;

   --
   SAVEPOINT detail_to_delivery_grp;

    -- Standard begin of API savepoint
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      --
      wsh_debug_sv.LOG(l_module_name, 'P_API_VERSION', p_api_version);
      wsh_debug_sv.LOG(l_module_name, 'P_INIT_MSG_LIST', p_init_msg_list);
      wsh_debug_sv.LOG(l_module_name, 'P_COMMIT', p_commit);
      wsh_debug_sv.LOG(l_module_name, 'P_VALIDATION_LEVEL', p_validation_level);
      wsh_debug_sv.LOG(l_module_name, 'P_ACTION', p_action);
      wsh_debug_sv.LOG(l_module_name, 'P_DELIVERY_ID', p_delivery_id);
      wsh_debug_sv.LOG(l_module_name, 'P_DELIVERY_NAME', p_delivery_name);
      wsh_debug_sv.LOG(l_module_name, 'P_TABOFDELDETS.COUNT', p_tabofdeldets.COUNT);
   END IF;

   --
   l_adjust_planned_del_tab.delete;

   IF NOT fnd_api.compatible_api_call(
            l_api_version,
            p_api_version,
            l_api_name,
            g_pkg_name
         ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Check p_init_msg_list
   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   x_return_status := wsh_util_core.g_ret_sts_success;

   IF (p_tabofdeldets.COUNT = 0) THEN
      RAISE wsh_no_del_det_tbl;
   END IF;

   /* check action */
   IF UPPER(NVL(p_action, 'N')) NOT IN('ASSIGN', 'UNASSIGN') THEN
      RAISE wsh_invalid_action;
   END IF;

   i := p_tabofdeldets.FIRST;
   l_cnt := 0;
   --
   WHILE i IS NOT NULL
   LOOP
    l_cnt := l_cnt + 1;
    --
    l_tabofdeldets(l_cnt) := p_tabofdeldets(i);
    --
    i := p_tabofdeldets.NEXT(i);
    --
   END LOOP;


   IF UPPER(NVL(p_action, 'N')) = 'ASSIGN' THEN
      IF (
                 (p_delivery_id IS NOT NULL)
             AND (p_delivery_id <> fnd_api.g_miss_num)
          OR     (p_delivery_name IS NOT NULL)
             AND (p_delivery_name <> fnd_api.g_miss_char)
         ) THEN
         IF (p_delivery_id IS NULL OR p_delivery_id = fnd_api.g_miss_num) THEN
            /* convert delivery_name to delivery_id */
            OPEN c_delivery_record;
            FETCH c_delivery_record INTO l_delivery_id;

            IF c_delivery_record%NOTFOUND THEN
               CLOSE c_delivery_record;
            -- RAISE wsh_no_delivery_id;  /*2777869*/
               RAISE wsh_no_delivery;
            END IF;

            CLOSE c_delivery_record;
         ELSE
            OPEN c_delivery_id;     /*2777869*/
            FETCH c_delivery_id into l_delivery_id;
            IF c_delivery_id%NOTFOUND THEN
               CLOSE c_delivery_id;
               RAISE wsh_invalid_delivery_id;
            END IF;
         -- l_delivery_id := p_delivery_id;
         END IF;

         IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'Calling program unit WSH_DLVB_COMMON_ACTIONS.ASSIGN_DETAILS', wsh_debug_sv.c_proc_level);
         END IF;

         --

         /* Patchset I : Harmonization Project Begin
               Instead of the old call to Assign_Multiple_Details
         We now have call to wsh_dlvb_common_actions.assign_details */
 IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, '  befor assign_details');
      END IF;
         wsh_dlvb_common_actions.assign_details(
            p_detail_tab            => l_tabofdeldets,
            p_parent_detail_id      => NULL,
            p_delivery_id           => p_delivery_id,
            x_pack_status           => l_pack_status_dummy,
            x_return_status         => l_return_status
         );
         wsh_util_core.api_post_call(
            p_return_status => l_return_status,
            x_num_warnings       => l_number_of_warnings,
            x_num_errors         => l_number_of_errors);
         /* Patchset I : Harmonization Project End */
         l_det_tab(1) := p_delivery_id;
         wsh_tp_release.calculate_cont_del_tpdates(
            p_entity => 'DLVY',
            p_entity_ids =>l_det_tab,
            x_return_status => x_return_status);

         wsh_util_core.api_post_call(
              p_return_status => l_return_status,
              x_num_warnings       => l_number_of_warnings,
              x_num_errors         => l_number_of_errors);

         -- deliveryMerge, collect the delivery ids for adjust_planned_flag call

         l_adjust_planned_del_tab(l_adjust_planned_del_tab.count+1) := p_delivery_id;
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, ' added delivery '||p_delivery_id ||' for adjustment');
      END IF;

      ELSE
         /* no delivery id is passed for action assign */
         RAISE wsh_no_delivery_id;
      END IF;
   ELSE
      /*  unassign */
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_UNASSIGN_FROM_DELIVERY', wsh_debug_sv.c_proc_level);
      END IF;

      wsh_details_validations.check_unassign_from_delivery(
         p_detail_rows => l_tabofdeldets,
         x_return_status      => l_return_status);

      wsh_util_core.api_post_call(
         p_return_status => l_return_status,
         x_num_warnings       => l_number_of_warnings,
         x_num_errors         => l_number_of_errors);

      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'Calling program unit WSH_DLVB_COMMON_ACTIONS.UNASSIGN_DETAILS', wsh_debug_sv.c_proc_level);
      END IF;

      /* Patchset I : Harmonization Project Begin
      Instead of the old call to WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Multiple_Details We now have call to wsh_dlvb_common_actions.unassign_details */
      -- deliveryMerge

      i := l_tabofdeldets.FIRST;
      WHILE i is not NULL LOOP
         OPEN c_get_assigned_delivery(l_tabofdeldets(i));
         FETCH c_get_assigned_delivery INTO l_delivery_id;
         IF c_get_assigned_delivery%NOTFOUND THEN
           goto end_of_loop;
         ELSE
         --
           l_delivery_already_included := false;

           IF l_adjust_planned_del_tab.count > 0 THEN
              FOR i in l_adjust_planned_del_tab.FIRST .. l_adjust_planned_del_tab.LAST LOOP
                 IF l_adjust_planned_del_tab(i) = l_delivery_id THEN
                    l_delivery_already_included := true;
                 END IF;
              END LOOP;
           END IF;

           IF NOT l_delivery_already_included THEN
              l_adjust_planned_del_tab(l_adjust_planned_del_tab.count+1) := l_delivery_id;
           END IF;

         --
         END IF;
         <<end_of_loop>>
         CLOSE c_get_assigned_delivery;
      i := l_tabofdeldets.next(i);
      END LOOP;

      wsh_dlvb_common_actions.unassign_details(
         p_detail_tab              => l_tabofdeldets,
         p_parent_detail_flag      => 'N',
         p_delivery_flag           => 'Y',
         x_return_status           => l_return_status,
         p_action_prms             => p_action_prms
      );
      wsh_util_core.api_post_call(
         p_return_status => l_return_status,
         x_num_warnings       => l_number_of_warnings,
         x_num_errors         => l_number_of_errors);
      /* Patchset I : Harmonization Project End */
   END IF;
   -- deliveryMerge
   IF l_adjust_planned_del_tab.count > 0 and WSH_PICK_LIST.G_BATCH_ID is NULL THEN
      WSH_NEW_DELIVERY_ACTIONS.Adjust_Planned_Flag(
         p_delivery_ids          => l_adjust_planned_del_tab,
         p_caller                => 'WSH_DLMG',
         p_force_appending_limit => 'N',
         p_call_lcss             => 'Y',
         x_return_status         => l_return_status);

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Adjust_Planned_Flag returns ',l_return_status);
      END IF;

      wsh_util_core.api_post_call(
         p_return_status => l_return_status,
         x_num_warnings       => l_number_of_warnings,
         x_num_errors         => l_number_of_errors);

   END IF;

   IF l_number_of_warnings > 0 THEN
      IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name, 'Number of warnings', l_number_of_warnings);
      END IF;

      RAISE wsh_util_core.g_exc_warning;
   END IF;

   fnd_msg_pub.count_and_get(
      p_count => x_msg_count,
      p_data => x_msg_data,
      p_encoded      => fnd_api.g_false);

   IF fnd_api.to_boolean(p_commit) THEN
      -- dbms_output.put_line('commit');
      COMMIT WORK;
   END IF;

   IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name);
   END IF;
--
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO detail_to_delivery_grp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
         p_count => x_msg_count,
         p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);

      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'FND_API.G_EXC_ERROR exception has occured.', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
   --
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO detail_to_delivery_grp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);

      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
   --
   WHEN wsh_util_core.g_exc_warning THEN
      x_return_status := wsh_util_core.g_ret_sts_warning;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);

      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;

   WHEN wsh_invalid_action THEN
      ROLLBACK TO detail_to_delivery_grp;
      x_return_status := wsh_util_core.g_ret_sts_error;
      fnd_message.set_name('WSH', 'WSH_PUB_INVALID_ACTION');
      wsh_util_core.add_message(x_return_status);
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);

      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'WSH_INVALID_ACTION exception has occured.', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:WSH_INVALID_ACTION');
      END IF;

   WHEN wsh_no_del_det_tbl THEN
      ROLLBACK TO detail_to_delivery_grp;
      x_return_status := wsh_util_core.g_ret_sts_error;
      fnd_message.set_name('WSH', 'WSH_PUB_NO_DEL_DET_TBL');
      wsh_util_core.add_message(x_return_status);
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);

      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'WSH_NO_DEL_DET_TBL exception has occured.', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:WSH_NO_DEL_DET_TBL');
      END IF;
   --
   WHEN wsh_no_delivery_id THEN
      ROLLBACK TO detail_to_delivery_grp;
      x_return_status := wsh_util_core.g_ret_sts_error;
      fnd_message.set_name('WSH', 'WSH_PUB_NO_DELIVERY');
      wsh_util_core.add_message(x_return_status);
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);

      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'WSH_NO_DELIVERY_ID exception has occured.', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:WSH_NO_DELIVERY_ID');
      END IF;
--

/*Start of 2777869*/

   WHEN wsh_no_delivery THEN
      ROLLBACK TO detail_to_delivery_grp;
      x_return_status := wsh_util_core.g_ret_sts_error;
      fnd_message.set_name('WSH', 'WSH_DELIVERY_NOT_EXIST');
      fnd_message.set_token('DELIVERY_NAME', p_delivery_name);
      wsh_util_core.add_message(x_return_status);
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);

      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'WSH_NO_DELIVERY exception has occured.', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:WSH_NO_DELIVERY');
      END IF;
--
   WHEN wsh_invalid_delivery_id THEN
      ROLLBACK TO detail_to_delivery_grp;
      x_return_status := wsh_util_core.g_ret_sts_error;
      fnd_message.set_name('WSH', 'WSH_INVALID_DELIVERY');
      fnd_message.set_token('DELIVERY', p_delivery_id);
      wsh_util_core.add_message(x_return_status);
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);

      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'WSH_INVALID_DELIVERY_ID exception has occured.', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:WSH_INVALID_DELIVERY_ID');
      END IF;

/* End of 2777869*/
--

   WHEN OTHERS THEN
      ROLLBACK TO detail_to_delivery_grp;
      x_return_status := wsh_util_core.g_ret_sts_unexp_error;
      wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_GRP.DETAIL_TO_DELIVERY');
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);

      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'Unexpected error has occured. Oracle error message is ' || SQLERRM, wsh_debug_sv.c_unexpec_err_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
      END IF;
--
END detail_to_delivery;


--This procedure is for backward compatibility only. Do not use this.
PROCEDURE detail_to_delivery(
   -- Standard parameters
   p_api_version        IN              NUMBER,
   p_init_msg_list      IN              VARCHAR2,
   p_commit             IN              VARCHAR2,
   p_validation_level   IN              NUMBER,
   x_return_status      OUT NOCOPY      VARCHAR2,
   x_msg_count          OUT NOCOPY      NUMBER,
   x_msg_data           OUT NOCOPY      VARCHAR2,
   -- procedure specific parameters
   p_tabofdeldets       IN              WSH_UTIL_CORE.id_tab_type,
   p_action             IN              VARCHAR2,
   p_delivery_id        IN              NUMBER,
   p_delivery_name      IN              VARCHAR2
) IS

   --
   l_debug_on                    BOOLEAN;
   --
   l_module_name        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_pkg_name || '.' || 'DETAIL_TO_DELIVERY';
   --
   l_action_prms   WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;  -- J-IB-NPARIKH
BEGIN
   --
   l_debug_on := wsh_debug_interface.g_debug;

   --
   IF l_debug_on IS NULL THEN
      l_debug_on := wsh_debug_sv.is_debug_enabled;
   END IF;


   -- Debug Statements
   --
   IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      --
      wsh_debug_sv.LOG(l_module_name, 'P_API_VERSION', p_api_version);
      wsh_debug_sv.LOG(l_module_name, 'P_INIT_MSG_LIST', p_init_msg_list);
      wsh_debug_sv.LOG(l_module_name, 'P_COMMIT', p_commit);
      wsh_debug_sv.LOG(l_module_name, 'P_VALIDATION_LEVEL', p_validation_level);
      wsh_debug_sv.LOG(l_module_name, 'P_ACTION', p_action);
      wsh_debug_sv.LOG(l_module_name, 'P_DELIVERY_ID', p_delivery_id);
      wsh_debug_sv.LOG(l_module_name, 'P_DELIVERY_NAME', p_delivery_name);
      wsh_debug_sv.LOG(l_module_name, 'P_TABOFDELDETS.COUNT', p_tabofdeldets.COUNT);
   END IF;


      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'Calling program unit WSH_DELIVERY_DETAILS_GRP.DETAIL_TO_DELIVERY', wsh_debug_sv.c_proc_level);
      END IF;

      DETAIL_TO_DELIVERY
        (
           p_api_version ,
           p_init_msg_list ,
           p_commit    ,
           p_validation_level,
           x_return_status ,
           x_msg_count   ,
           x_msg_data   ,
           p_tabofdeldets,
           p_action      ,
           p_delivery_id  ,
           p_delivery_name  ,
           l_action_prms
        );
   IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name);
   END IF;
--
EXCEPTION

   WHEN OTHERS THEN
      x_return_status := wsh_util_core.g_ret_sts_unexp_error;
      wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_GRP.DETAIL_TO_DELIVERY');
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);

      IF l_debug_on THEN
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
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
PROCEDURE split_line(
   -- Standard parameters
   p_api_version        IN              NUMBER,
   p_init_msg_list      IN              VARCHAR2,
   p_commit             IN              VARCHAR2,
   p_validation_level   IN              NUMBER,
   x_return_status      OUT NOCOPY      VARCHAR2,
   x_msg_count          OUT NOCOPY      NUMBER,
   x_msg_data           OUT NOCOPY      VARCHAR2,
   -- Procedure specific parameters
   p_from_detail_id     IN              NUMBER,
   x_new_detail_id      OUT NOCOPY      NUMBER,
   x_split_quantity     IN OUT NOCOPY   NUMBER,
   x_split_quantity2    IN OUT NOCOPY   NUMBER,
   p_manual_split       IN              VARCHAR2 DEFAULT NULL,
   p_converted_flag     IN              VARCHAR2 DEFAULT NULL
) IS
   l_msg_summary                 VARCHAR2(2000);
   l_msg_details                 VARCHAR2(4000);
   l_requested_quantity          NUMBER := NULL;
   l_requested_quantity2         NUMBER := NULL;/* OPM changes  NC 03/19/01 */
   l_received_quantity           NUMBER := NULL;
   l_received_quantity2          NUMBER := NULL;
   l_line_direction              VARCHAR2(30);
-- Standard call to check for call compatibility.
   l_api_version        CONSTANT NUMBER := 1.0;
   l_api_name           CONSTANT VARCHAR2(30) := 'Split_Line';

/* OPM changes NC . Added requsted_quantity2 in the select */
   CURSOR c_find_delivery_detail(c_delivery_detail_id NUMBER) IS
      SELECT NVL(LINE_DIRECTION,'O'),
             NVL(received_quantity, shipped_quantity),
             NVL(received_quantity2, shipped_quantity2),
             NVL(picked_quantity, requested_quantity),
             NVL(picked_quantity2, requested_quantity2)
        FROM wsh_delivery_details
       WHERE delivery_detail_id = c_delivery_detail_id;

   wsh_invalid_split_qty         EXCEPTION;
   wsh_invalid_split_qty2        EXCEPTION; /* Added for OPM. NC - 03/19/01 */
   wsh_inalid_detail_id          EXCEPTION;
   --
   l_debug_on                    BOOLEAN;
   --
   l_module_name        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_pkg_name || '.' || 'SPLIT_LINE';
   --
      -- Patchset I : Harmonization Project
      --
   l_number_of_errors            NUMBER := 0;
   l_number_of_warnings          NUMBER := 0;
   l_msg_data                    VARCHAR2(32767);
   l_inv_item_id                 NUMBER;
   l_organization_id             NUMBER;
   l_requested_quantity_uom      VARCHAR2(32767);
   l_return_status               VARCHAR2(32767);
   l_output_quantity             NUMBER;
   l_validation_level_tab        wsh_util_core.id_tab_type;

   -- bug 3524851
   l_top_model_line_id           NUMBER;

   --
   CURSOR det_cur(p_del_det_id NUMBER) IS
      SELECT inventory_item_id, organization_id, requested_quantity_uom, top_model_line_id
        FROM wsh_delivery_details
       WHERE delivery_detail_id = p_del_det_id;
BEGIN
   --
   l_debug_on := wsh_debug_interface.g_debug;

   --
   IF l_debug_on IS NULL THEN
      l_debug_on := wsh_debug_sv.is_debug_enabled;
   END IF;

   --
   SAVEPOINT split_line_grp;

   -- Standard begin of API savepoint
   IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      --
      wsh_debug_sv.LOG(l_module_name, 'P_API_VERSION', p_api_version);
      wsh_debug_sv.LOG(l_module_name, 'P_INIT_MSG_LIST', p_init_msg_list);
      wsh_debug_sv.LOG(l_module_name, 'P_COMMIT', p_commit);
      wsh_debug_sv.LOG(l_module_name, 'P_VALIDATION_LEVEL', p_validation_level);
      wsh_debug_sv.LOG(l_module_name, 'P_FROM_DETAIL_ID', p_from_detail_id);
      wsh_debug_sv.LOG(l_module_name, 'X_SPLIT_QUANTITY', x_split_quantity);
      wsh_debug_sv.LOG(l_module_name, 'X_SPLIT_QUANTITY2', x_split_quantity2);
   END IF;

   --

   IF NOT fnd_api.compatible_api_call(
            l_api_version,
            p_api_version,
            l_api_name,
            g_pkg_name
         ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Check p_init_msg_list
   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   x_return_status := wsh_util_core.g_ret_sts_success;
   --
   /* Patchset I : Harmonization Project */
   l_validation_level_tab := wsh_actions_levels.g_validation_level_tab;
   /* OPM changes  NC - added l_requested_quantity2 */
   OPEN c_find_delivery_detail(p_from_detail_id);
   FETCH c_find_delivery_detail INTO l_line_direction, l_received_quantity,
    l_received_quantity2, l_requested_quantity,
    l_requested_quantity2;

   IF c_find_delivery_detail%NOTFOUND THEN
      RAISE wsh_inalid_detail_id;
   END IF;

   CLOSE c_find_delivery_detail;

   -- J-IB-NPARIKH-{
   IF l_line_direction NOT IN ('O','IO')
   THEN
   --{
        --
        -- For inbound/drop-ship lines,
        -- qty. to be split cannot be greater than
        -- NVL(RCV,SHP,PICK,REQ).
        -- Hence, setting variables l_requested_quantity(2) to
        -- NVL(RCV,SHP,PICK,REQ).
        --
        l_requested_quantity  := NVL(l_received_quantity,l_requested_quantity);
        l_requested_quantity2 := NVL(l_received_quantity2,l_requested_quantity2);
   --}
   END IF;
   -- J-IB-NPARIKH-}



   IF l_requested_quantity < x_split_quantity THEN
      RAISE wsh_invalid_split_qty;
   END IF;

   /* OPM changes  NC - added */
   IF l_requested_quantity2 < x_split_quantity2 THEN
      RAISE wsh_invalid_split_qty2;
   END IF;

   /* PATCHSET I: Harmonization Project. validate decimal quantity */

   IF (l_validation_level_tab(wsh_actions_levels.c_decimal_quantity_lvl) = 1) THEN
      OPEN det_cur(p_from_detail_id);
      FETCH det_cur INTO l_inv_item_id, l_organization_id,
       l_requested_quantity_uom, l_top_model_line_id;
      CLOSE det_cur;

-- HW Harmonization project. Added p_organization_id
-- HW OPMCONV - Removed branching

         IF l_debug_on THEN
            wsh_debug_sv.LOG(l_module_name, 'Inv item id', l_inv_item_id);
            wsh_debug_sv.LOG(l_module_name, 'Org id', l_organization_id);
            wsh_debug_sv.LOG(l_module_name, 'Req qty uom', l_requested_quantity_uom);
            wsh_debug_sv.logmsg(l_module_name, 'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_DECIMAL_QUANTITY', wsh_debug_sv.c_proc_level);
         END IF;

         wsh_details_validations.check_decimal_quantity(
            p_item_id              => l_inv_item_id,
            p_organization_id      => l_organization_id,
            p_input_quantity       => x_split_quantity,
            p_uom_code             => l_requested_quantity_uom, -- :split_line.quantity_UOM,
            x_output_quantity      => l_output_quantity,
            x_return_status        => l_return_status,
            p_top_model_line_id    => l_top_model_line_id -- bug 3524851
         );

         IF l_debug_on THEN
            wsh_debug_sv.LOG(l_module_name, 'Return Status after check decimal', l_return_status);
            wsh_debug_sv.LOG(l_module_name, 'Output qty after check decimal', l_output_quantity);
         END IF;

         -- UT Bug fix 2650839
         --IF l_return_status <> wsh_util_core.g_ret_sts_success THEN
         --   RAISE fnd_api.g_exc_error;
         --END IF;
         -- Reverting the fix made in 2650839 as we need to return warning instead of
         -- error to public API users.
         wsh_util_core.api_post_call(
            p_return_status => l_return_status,
            x_num_warnings       => l_number_of_warnings,
            x_num_errors         => l_number_of_errors);

   END IF;

   IF l_debug_on THEN
      wsh_debug_sv.logmsg(l_module_name, 'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.SPLIT_DELIVERY_DETAILS', wsh_debug_sv.c_proc_level);
   END IF;

  --
-- HW added p_converted_flag
   wsh_delivery_details_actions.split_delivery_details(
      p_from_detail_id      => p_from_detail_id,
      p_req_quantity        => x_split_quantity,
      p_req_quantity2       => x_split_quantity2,
      p_manual_split        => p_manual_split,
      p_converted_flag      => p_converted_flag,
      x_new_detail_id       => x_new_detail_id,
      x_return_status       => l_return_status
   );
   wsh_util_core.api_post_call(
      p_return_status => l_return_status,
      x_num_warnings       => l_number_of_warnings,
      x_num_errors         => l_number_of_errors);

   IF l_number_of_warnings > 0 THEN
      IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name, 'Number of warnings', l_number_of_warnings);
      END IF;

      RAISE wsh_util_core.g_exc_warning;
   END IF;

   fnd_msg_pub.count_and_get(
      p_count => x_msg_count,
      p_data => x_msg_data,
      p_encoded      => fnd_api.g_false);

   IF l_debug_on THEN
      wsh_debug_sv.LOG(l_module_name, 'X_NEW_DETAIL_ID', x_new_detail_id);
      wsh_debug_sv.LOG(l_module_name, 'X_SPLIT_QUANTITY', x_split_quantity);
      wsh_debug_sv.pop(l_module_name);
   END IF;
--
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO split_line_grp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
         p_count => x_msg_count,
         p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);

      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'FND_API.G_EXC_ERROR exception has occured.', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
   --
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO split_line_grp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
         p_count => x_msg_count,
         p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);

      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
   --
   WHEN wsh_util_core.g_exc_warning THEN
      x_return_status := wsh_util_core.g_ret_sts_warning;
      fnd_msg_pub.count_and_get(
         p_count => x_msg_count,
         p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);

      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
   WHEN wsh_inalid_detail_id THEN
      ROLLBACK TO split_line_grp;
      x_return_status := wsh_util_core.g_ret_sts_error;

/* Bug 2777869 : Instead of message "WSH_PUB_INALID_DETAIL_ID",now we are using
"WSH_DET_INVALID_DETAIL".*/

      fnd_message.set_name('WSH', 'WSH_DET_INVALID_DETAIL');
      fnd_message.set_token('DETAIL_ID',p_from_detail_id);
      wsh_util_core.add_message(x_return_status);

      fnd_msg_pub.count_and_get(
         p_count => x_msg_count,
         p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);

      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'WSH_INALID_DETAIL_ID exception has occured.', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:WSH_INALID_DETAIL_ID');
      END IF;
--
   WHEN wsh_invalid_split_qty THEN
      ROLLBACK TO split_line_grp;
      x_return_status := wsh_util_core.g_ret_sts_error;
      fnd_message.set_name('WSH', 'WSH_DET_SPLIT_EXCEED');
      wsh_util_core.add_message(x_return_status);

      fnd_msg_pub.count_and_get(
         p_count => x_msg_count,
         p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);

      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'WSH_INVALID_SPLIT_QTY exception has occured.', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:WSH_INVALID_SPLIT_QTY');
      END IF;
--
   WHEN wsh_invalid_split_qty2 THEN               /* OPM changes. NC - Added */
      ROLLBACK TO split_line_grp;
      x_return_status := wsh_util_core.g_ret_sts_error;
      fnd_message.set_name('WSH', 'WSH_PUB_INVALID_SPLIT_QTY');
      wsh_util_core.add_message(x_return_status);

      fnd_msg_pub.count_and_get(
         p_count => x_msg_count,
         p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);

      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'WSH_INVALID_SPLIT_QTY2 exception has occured.', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:WSH_INVALID_SPLIT_QTY2');
      END IF;
--
   WHEN OTHERS THEN
      ROLLBACK TO split_line_grp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      wsh_util_core.add_message(x_return_status, l_module_name);
      wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_GRP.Split_Line');

      fnd_msg_pub.count_and_get(
         p_count => x_msg_count,
         p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'Unexpected error has occured. Oracle error message is ' || SQLERRM, wsh_debug_sv.c_unexpec_err_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
      END IF;
--
END split_line;





--===================
-- PROCEDURES
--===================







--========================================================================
-- PROCEDURE : Update_Shipping_Attributes
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         initialize message stack
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--            p_changed_attributes    changed attributes for delivery details
--             p_source_code           source system
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
, p_changed_attributes     IN OUT NOCOPY   WSH_INTERFACE.ChangedAttributeTabType
, p_source_code            IN     VARCHAR2
, p_container_flag         IN     VARCHAR2 DEFAULT NULL
)
IS

  --
  l_number_of_errors    NUMBER := 0;
  l_number_of_warnings  NUMBER := 0;
        l_return_status     VARCHAR2(30);
        l_counter   NUMBER;
        l_index             NUMBER;
        l_api_version_number  NUMBER := 1.0;
        l_api_name          VARCHAR2(30) := 'Update_Shipping_Attributes';

        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(32767);
        l_detail_info_tab       WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type;
        l_detail_in_rec         WSH_GLBL_VAR_STRCT_GRP.detailInRecType;
        l_detail_out_rec        WSH_GLBL_VAR_STRCT_GRP.detailOutRecType;
        l_dummy_ids             wsh_util_core.id_Tab_type;
        invalid_source_code     exception;
        mark_reprice_error      exception;
        update_failed           exception;
detail_no_found         EXCEPTION;
invalid_released_status EXCEPTION; -- Bug fix  2154620
l_error_detail_id NUMBER;
l_error_attribute VARCHAR2(240);
l_error_attribute_value VARCHAR2(360);

l_org         NUMBER;

cursor get_org (p_detail_id in number)is
select organization_id
from wsh_delivery_details
where delivery_detail_id = p_detail_id;
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
  SAVEPOINT UPDATE_SHIPPING_ATTR_GRP;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
          WSH_DEBUG_SV.push(l_module_name);
      --
    WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
    WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
    WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
    WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
    WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_FLAG',P_CONTAINER_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'Table Count',p_changed_attributes.COUNT);

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

        -- sperera source_code has to be 'OE' or 'WSH'
  IF (NVL(p_source_code, FND_API.G_MISS_CHAR)) NOT IN ('WSH', 'OE') THEN
    RAISE invalid_source_code;
  END IF;

       -- Patchset I : Harmonization Project.
             l_detail_in_rec.action_code := 'UPDATE';

      l_index := p_changed_attributes.FIRST;
      WHILE l_index IS NOT NULL LOOP

        OPEN get_org (p_changed_attributes(l_index).delivery_detail_id);
        FETCH get_org into l_org;
        IF get_org%notfound THEN
           CLOSE get_org;
           RAISE update_failed;
        END IF;
        CLOSE get_org;

             IF (wsh_util_validate.Check_Wms_Org(l_org)='Y') THEN
               l_detail_in_rec.caller := 'WMS';
             ELSE
               l_detail_in_rec.caller := 'WSH_GRP';
             END IF;

        l_detail_info_tab(l_index).arrival_set_id      :=   p_changed_attributes(l_index).arrival_set_id;
        l_detail_info_tab(l_index).ato_line_id      :=   p_changed_attributes(l_index).ato_line_id;
        l_detail_info_tab(l_index).attribute_category      :=   p_changed_attributes(l_index).attribute_category;
        l_detail_info_tab(l_index).attribute1      :=   p_changed_attributes(l_index).attribute1;
        l_detail_info_tab(l_index).attribute10      :=   p_changed_attributes(l_index).attribute10;
        l_detail_info_tab(l_index).attribute11      :=   p_changed_attributes(l_index).attribute11;
        l_detail_info_tab(l_index).attribute12      :=   p_changed_attributes(l_index).attribute12;
        l_detail_info_tab(l_index).attribute13      :=   p_changed_attributes(l_index).attribute13;
        l_detail_info_tab(l_index).attribute14      :=   p_changed_attributes(l_index).attribute14;
        l_detail_info_tab(l_index).attribute15      :=   p_changed_attributes(l_index).attribute15;
        l_detail_info_tab(l_index).attribute2      :=   p_changed_attributes(l_index).attribute2;
        l_detail_info_tab(l_index).attribute3      :=   p_changed_attributes(l_index).attribute3;
        l_detail_info_tab(l_index).attribute4      :=   p_changed_attributes(l_index).attribute4;
        l_detail_info_tab(l_index).attribute5      :=   p_changed_attributes(l_index).attribute5;
        l_detail_info_tab(l_index).attribute6      :=   p_changed_attributes(l_index).attribute6;
        l_detail_info_tab(l_index).attribute7      :=   p_changed_attributes(l_index).attribute7;
        l_detail_info_tab(l_index).attribute8      :=   p_changed_attributes(l_index).attribute8;
        l_detail_info_tab(l_index).attribute9      :=   p_changed_attributes(l_index).attribute9;
        l_detail_info_tab(l_index).cancelled_quantity      :=   p_changed_attributes(l_index).cancelled_quantity;
        l_detail_info_tab(l_index).cancelled_quantity2       :=   p_changed_attributes(l_index).cancelled_quantity2;
        l_detail_info_tab(l_index).carrier_id      :=   p_changed_attributes(l_index).carrier_id;
        l_detail_info_tab(l_index).classification      :=   p_changed_attributes(l_index).classification    ;
        l_detail_info_tab(l_index).commodity_code_cat_id       :=   p_changed_attributes(l_index).commodity_code_cat_id ;
        l_detail_info_tab(l_index).container_flag      :=   p_changed_attributes(l_index).container_flag   ;
        l_detail_info_tab(l_index).container_name      :=   p_changed_attributes(l_index).container_name   ;
        l_detail_info_tab(l_index).container_type_code       :=   p_changed_attributes(l_index).container_type_code   ;
        l_detail_info_tab(l_index).country_of_origin      :=   p_changed_attributes(l_index).country_of_origin ;
        l_detail_info_tab(l_index).currency_code      :=   p_changed_attributes(l_index).currency_code      ;
        l_detail_info_tab(l_index).cust_model_serial_number       :=   p_changed_attributes(l_index).cust_model_serial_number;
        l_detail_info_tab(l_index).cust_po_number      :=   p_changed_attributes(l_index).cust_po_number;
        l_detail_info_tab(l_index).customer_dock_code      :=   p_changed_attributes(l_index).customer_dock_code;
        l_detail_info_tab(l_index).customer_id      :=   p_changed_attributes(l_index).customer_id       ;
        l_detail_info_tab(l_index).customer_item_id      :=   p_changed_attributes(l_index).customer_item_id  ;
        l_detail_info_tab(l_index).customer_job        :=   p_changed_attributes(l_index).customer_job      ;
        l_detail_info_tab(l_index).customer_prod_seq      :=   p_changed_attributes(l_index).customer_prod_seq;
        l_detail_info_tab(l_index).customer_production_line       :=   p_changed_attributes(l_index).customer_production_line;
        l_detail_info_tab(l_index).customer_requested_lot_flag    :=   p_changed_attributes(l_index).customer_requested_lot_flag;
        l_detail_info_tab(l_index).cycle_count_quantity      :=   p_changed_attributes(l_index).cycle_count_quantity ;
        l_detail_info_tab(l_index).cycle_count_quantity2       :=   p_changed_attributes(l_index).cycle_count_quantity2   ;
        l_detail_info_tab(l_index).date_requested      :=   p_changed_attributes(l_index).date_requested;
        l_detail_info_tab(l_index).date_scheduled      :=   p_changed_attributes(l_index).date_scheduled;
        l_detail_info_tab(l_index).deliver_to_contact_id      :=   p_changed_attributes(l_index).deliver_to_contact_id;
        l_detail_info_tab(l_index).delivered_quantity      :=   p_changed_attributes(l_index).delivered_quantity;
        l_detail_info_tab(l_index).delivered_quantity2      :=   p_changed_attributes(l_index).delivered_quantity2   ;
        l_detail_info_tab(l_index).delivery_detail_id      :=   p_changed_attributes(l_index).delivery_detail_id;
        l_detail_info_tab(l_index).dep_plan_required_flag      :=   p_changed_attributes(l_index).dep_plan_required_flag;
        l_detail_info_tab(l_index).detail_container_item_id      :=   p_changed_attributes(l_index).detail_container_item_id;
        l_detail_info_tab(l_index).fill_percent      :=   p_changed_attributes(l_index).fill_percent;
        l_detail_info_tab(l_index).fob_code      :=   p_changed_attributes(l_index).fob_code;
        l_detail_info_tab(l_index).freight_class_cat_id      :=   p_changed_attributes(l_index).freight_class_cat_id;
        l_detail_info_tab(l_index).freight_terms_code      :=   p_changed_attributes(l_index).freight_terms_code;
        l_detail_info_tab(l_index).gross_weight      :=   p_changed_attributes(l_index).gross_weight;
        l_detail_info_tab(l_index).hazard_class_id      :=   p_changed_attributes(l_index).hazard_class_id;
        l_detail_info_tab(l_index).hold_code      :=   p_changed_attributes(l_index).hold_code;
        l_detail_info_tab(l_index).inspection_flag      :=   p_changed_attributes(l_index).inspection_flag    ;
        l_detail_info_tab(l_index).intmed_ship_to_contact_id      :=   p_changed_attributes(l_index).intmed_ship_to_contact_id;
        l_detail_info_tab(l_index).inv_interfaced_flag      :=   p_changed_attributes(l_index).inv_interfaced_flag   ;
        l_detail_info_tab(l_index).inventory_item_id      :=   p_changed_attributes(l_index).inventory_item_id ;
        l_detail_info_tab(l_index).item_description      :=   p_changed_attributes(l_index).item_description  ;
        l_detail_info_tab(l_index).load_seq_number      :=   p_changed_attributes(l_index).load_seq_number   ;
        l_detail_info_tab(l_index).lot_number      :=   p_changed_attributes(l_index).lot_number;
        l_detail_info_tab(l_index).lpn_id      :=   p_changed_attributes(l_index).lpn_id   ;
        l_detail_info_tab(l_index).master_container_item_id      :=   p_changed_attributes(l_index).master_container_item_id;
        l_detail_info_tab(l_index).master_serial_number      :=   p_changed_attributes(l_index).master_serial_number  ;
        l_detail_info_tab(l_index).maximum_load_weight      :=   p_changed_attributes(l_index).maximum_load_weight   ;
        l_detail_info_tab(l_index).maximum_volume      :=   p_changed_attributes(l_index).maximum_volume    ;
        l_detail_info_tab(l_index).minimum_fill_percent      :=   p_changed_attributes(l_index).minimum_fill_percent  ;
        l_detail_info_tab(l_index).move_order_line_id      :=   p_changed_attributes(l_index).move_order_line_id;
        l_detail_info_tab(l_index).movement_id      :=   p_changed_attributes(l_index).movement_id ;
        l_detail_info_tab(l_index).mvt_stat_status      :=   p_changed_attributes(l_index).mvt_stat_status   ;
        l_detail_info_tab(l_index).net_weight      :=   p_changed_attributes(l_index).net_weight;
        l_detail_info_tab(l_index).oe_interfaced_flag      :=   p_changed_attributes(l_index).oe_interfaced_flag;
        l_detail_info_tab(l_index).org_id      :=   p_changed_attributes(l_index).org_id   ;
        l_detail_info_tab(l_index).organization_id      :=   p_changed_attributes(l_index).organization_id   ;
        l_detail_info_tab(l_index).original_subinventory      :=   p_changed_attributes(l_index).original_subinventory    ;
        l_detail_info_tab(l_index).packing_instructions      :=   p_changed_attributes(l_index).packing_instructions;
        l_detail_info_tab(l_index).pickable_flag      :=   p_changed_attributes(l_index).pickable_flag ;
        l_detail_info_tab(l_index).picked_quantity      :=   p_changed_attributes(l_index).picked_quantity;
        l_detail_info_tab(l_index).picked_quantity2      :=   p_changed_attributes(l_index).picked_quantity2;
        l_detail_info_tab(l_index).preferred_grade      :=   p_changed_attributes(l_index).preferred_grade;
        l_detail_info_tab(l_index).project_id      :=   p_changed_attributes(l_index).project_id;
        l_detail_info_tab(l_index).quality_control_quantity      :=   p_changed_attributes(l_index).quality_control_quantity;
        l_detail_info_tab(l_index).quality_control_quantity2      :=   p_changed_attributes(l_index).quality_control_quantity2;
        l_detail_info_tab(l_index).received_quantity      :=   p_changed_attributes(l_index).received_quantity;
        l_detail_info_tab(l_index).received_quantity2      :=   p_changed_attributes(l_index).received_quantity2;
        l_detail_info_tab(l_index).released_status      :=   p_changed_attributes(l_index).released_status;
        l_detail_info_tab(l_index).request_id      :=   p_changed_attributes(l_index).request_id;
        l_detail_info_tab(l_index).revision      :=   p_changed_attributes(l_index).revision;
        l_detail_info_tab(l_index).seal_code      :=   p_changed_attributes(l_index).seal_code;

        l_detail_info_tab(l_index).ship_method_code      :=   p_changed_attributes(l_index).shipping_method_code;
        l_detail_info_tab(l_index).ship_model_complete_flag       :=   p_changed_attributes(l_index).ship_model_complete_flag;
        l_detail_info_tab(l_index).ship_set_id      :=   p_changed_attributes(l_index).ship_set_id;
        l_detail_info_tab(l_index).ship_to_contact_id      :=   p_changed_attributes(l_index).ship_to_contact_id;
        l_detail_info_tab(l_index).ship_to_site_use_id      :=   p_changed_attributes(l_index).ship_to_site_use_id   ;
        l_detail_info_tab(l_index).ship_tolerance_above      :=   p_changed_attributes(l_index).ship_tolerance_above;
        l_detail_info_tab(l_index).ship_tolerance_below      :=   p_changed_attributes(l_index).ship_tolerance_below;
        l_detail_info_tab(l_index).shipment_priority_code      :=   p_changed_attributes(l_index).shipment_priority_code;
        l_detail_info_tab(l_index).shipped_quantity      :=   p_changed_attributes(l_index).shipped_quantity ;
        l_detail_info_tab(l_index).shipped_quantity2      :=   p_changed_attributes(l_index).shipped_quantity2  ;
        l_detail_info_tab(l_index).shipping_instructions      :=   p_changed_attributes(l_index).shipping_instructions;
        l_detail_info_tab(l_index).sold_to_contact_id      :=   p_changed_attributes(l_index).sold_to_contact_id;
        l_detail_info_tab(l_index).source_code      :=   p_changed_attributes(l_index).source_code;
        l_detail_info_tab(l_index).source_header_id      :=   p_changed_attributes(l_index).source_header_id;
        l_detail_info_tab(l_index).source_header_number      :=   p_changed_attributes(l_index).source_header_number ;
        l_detail_info_tab(l_index).source_header_type_id      :=   p_changed_attributes(l_index).source_header_type_id  ;
        l_detail_info_tab(l_index).source_header_type_name      :=   p_changed_attributes(l_index).source_header_type_name   ;
        l_detail_info_tab(l_index).source_line_id      :=   p_changed_attributes(l_index).source_line_id;
        l_detail_info_tab(l_index).source_line_set_id      :=   p_changed_attributes(l_index).source_line_set_id;
        l_detail_info_tab(l_index).split_from_detail_id      :=   p_changed_attributes(l_index).split_from_delivery_detail_id ;
        l_detail_info_tab(l_index).src_requested_quantity      :=   p_changed_attributes(l_index).src_requested_quantity ;
        l_detail_info_tab(l_index).src_requested_quantity_uom      :=   p_changed_attributes(l_index).src_requested_quantity_uom;
        l_detail_info_tab(l_index).src_requested_quantity_uom2    :=   p_changed_attributes(l_index).src_requested_quantity_uom2 ;
        l_detail_info_tab(l_index).src_requested_quantity2       :=   p_changed_attributes(l_index).src_requested_quantity2 ;
        l_detail_info_tab(l_index).subinventory      :=   p_changed_attributes(l_index).subinventory;
-- HW OPMCONV - No need for sublot_number
--      l_detail_info_tab(l_index).sublot_number       :=   p_changed_attributes(l_index).sublot_number  ;
        l_detail_info_tab(l_index).task_id      :=   p_changed_attributes(l_index).task_id  ;
        l_detail_info_tab(l_index).to_serial_number      :=   p_changed_attributes(l_index).to_serial_number  ;
        l_detail_info_tab(l_index).top_model_line_id      :=   p_changed_attributes(l_index).top_model_line_id;
        l_detail_info_tab(l_index).tp_attribute_category      :=   p_changed_attributes(l_index).tp_attribute_category      ;
        l_detail_info_tab(l_index).tp_attribute1      :=   p_changed_attributes(l_index).tp_attribute1 ;
        l_detail_info_tab(l_index).tp_attribute10      :=   p_changed_attributes(l_index).tp_attribute10 ;
        l_detail_info_tab(l_index).tp_attribute11      :=   p_changed_attributes(l_index).tp_attribute11  ;
        l_detail_info_tab(l_index).tp_attribute12      :=   p_changed_attributes(l_index).tp_attribute12  ;
        l_detail_info_tab(l_index).tp_attribute13      :=   p_changed_attributes(l_index).tp_attribute13;
        l_detail_info_tab(l_index).tp_attribute14      :=   p_changed_attributes(l_index).tp_attribute14;
        l_detail_info_tab(l_index).tp_attribute15      :=   p_changed_attributes(l_index).tp_attribute15 ;
        l_detail_info_tab(l_index).tp_attribute2      :=   p_changed_attributes(l_index).tp_attribute2 ;
        l_detail_info_tab(l_index).tp_attribute3      :=   p_changed_attributes(l_index).tp_attribute3;
        l_detail_info_tab(l_index).tp_attribute4      :=   p_changed_attributes(l_index).tp_attribute4;
        l_detail_info_tab(l_index).tp_attribute5      :=   p_changed_attributes(l_index).tp_attribute5;
        l_detail_info_tab(l_index).tp_attribute6      :=   p_changed_attributes(l_index).tp_attribute6;
        l_detail_info_tab(l_index).tp_attribute7      :=   p_changed_attributes(l_index).tp_attribute7;
        l_detail_info_tab(l_index).tp_attribute8      :=   p_changed_attributes(l_index).tp_attribute8;
        l_detail_info_tab(l_index).tp_attribute9      :=   p_changed_attributes(l_index).tp_attribute9;
        l_detail_info_tab(l_index).tracking_number    :=   p_changed_attributes(l_index).tracking_number;

-- jckwok Bug 3579965: must check whether transaction_temp_id <> FND_API.G_MISS_NUM also
        if (p_changed_attributes(l_index).transaction_temp_id is not null
               AND p_changed_attributes(l_index).transaction_temp_id <> FND_API.G_MISS_NUM)  then
           l_detail_info_tab(l_index).transaction_temp_id      :=   p_changed_attributes(l_index).transaction_temp_id;
        else
           l_detail_info_tab(l_index).serial_number      :=   p_changed_attributes(l_index).serial_number;
        end if;

        l_detail_info_tab(l_index).unit_price      :=   p_changed_attributes(l_index).unit_price;
        l_detail_info_tab(l_index).volume      :=   p_changed_attributes(l_index).volume;
        l_detail_info_tab(l_index).volume_uom_code      :=   p_changed_attributes(l_index).volume_uom_code;
        l_detail_info_tab(l_index).weight_uom_code      :=   p_changed_attributes(l_index).weight_uom_code;


          l_index := p_changed_attributes.NEXT(l_index);
      END LOOP;

             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTERFACE_GRP.CREATE_UPDATE_DELIVERY_DETAIL',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;

       wsh_interface_grp.Create_Update_Delivery_Detail
       (
          p_api_version_number  => l_api_version_number,
          p_init_msg_list          => FND_API.G_FALSE,
          p_commit                => FND_API.G_FALSE,
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data,
          p_detail_info_tab       => l_detail_info_tab,
          p_IN_rec                => l_detail_in_rec,
          x_OUT_rec               => l_detail_out_rec
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


    -- report success
  IF FND_API.TO_BOOLEAN(p_commit) THEN
    COMMIT WORK;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Count_And_Get
       ( p_count => x_msg_count,
         p_data  => x_msg_data,
               p_encoded => FND_API.G_FALSE
       );
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
  EXCEPTION
    WHEN mark_reprice_error then
                        ROLLBACK TO UPDATE_SHIPPING_ATTR_GRP;
      FND_MESSAGE.Set_Name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
      x_return_status := l_return_status;
    WSH_UTIL_CORE.add_message (x_return_status);
    FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data,
                       p_encoded => FND_API.G_FALSE
         );
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'MARK_REPRICE_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:MARK_REPRICE_ERROR');
         END IF;
         --
    WHEN invalid_source_code THEN
                        ROLLBACK TO UPDATE_SHIPPING_ATTR_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
                        FND_MESSAGE.Set_Name('WSH', 'WSH_INVALID_SOURCE_CODE');
                        WSH_UTIL_CORE.Add_Message(x_return_status);
      FND_MSG_PUB.Count_And_Get
           ( p_count => x_msg_count,
             p_data  => x_msg_data,
                               p_encoded => FND_API.G_FALSE
           );
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_SOURCE_CODE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
               WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_SOURCE_CODE');
           END IF;
           --
    WHEN update_failed THEN
                        ROLLBACK TO UPDATE_SHIPPING_ATTR_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('WSH', 'WSH_DETAIL_VALIDATION_FAILED');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE', l_error_attribute);
      FND_MESSAGE.SET_TOKEN('ATTRB_VALUE', l_error_attribute_value);
      FND_MESSAGE.SET_TOKEN('DELIVERY_DETAIL', l_error_detail_id);
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
      FND_MSG_PUB.Count_And_Get
           ( p_count => x_msg_count,
             p_data  => x_msg_data,
                               p_encoded => FND_API.G_FALSE
           );

    -- Bug fix  2154602
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'UPDATE_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:UPDATE_FAILED');
    END IF;
    --
    WHEN invalid_released_status THEN
                        ROLLBACK TO UPDATE_SHIPPING_ATTR_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
      FND_MSG_PUB.Count_And_Get
           ( p_count => x_msg_count,
             p_data  => x_msg_data,
                               p_encoded => FND_API.G_FALSE
           );
    -- End of Bug fix  2154602

                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_RELEASED_STATUS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_RELEASED_STATUS');
                  END IF;
--
               WHEN Others THEN
               IF get_org%isopen THEN
                  close get_org;
               END IF;
                        ROLLBACK TO UPDATE_SHIPPING_ATTR_GRP;
               x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
               WSH_UTIL_CORE.add_message (x_return_status);
               WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_GRP.Update_Shipping_Attributes');
    FND_MSG_PUB.Count_And_Get
           ( p_count => x_msg_count,
             p_data  => x_msg_data,
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
  WHEN others then
    wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_GRP.Get_Detail_Status');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
    if x_msg_count > 1 then
      x_msg_data := l_msg_summary || l_msg_details;
    else
      x_msg_data := l_msg_summary;
    end if;
    */
    IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'X_LINE_STATUS',x_line_status);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
END get_detail_status;

-- ---------------------------------------------------------------------
-- Procedure: Autocreate_Deliveries
--
-- change on 8/24/2005 : p_caller is added
--                       refer to bug 4467032 (R12 Routing Guide)
-- -----------------------------------------------------------------------
PROCEDURE Autocreate_Deliveries(
  -- Standard parameters
  p_api_version_number     IN     NUMBER
, p_init_msg_list          IN     VARCHAR2
, p_commit                 IN     VARCHAR2
, p_caller                 IN     VARCHAR2 DEFAULT NULL
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_line_rows              IN     WSH_UTIL_CORE.id_tab_type
, p_group_by_header_flag        IN     VARCHAR2
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
--
  l_number_of_errors    NUMBER := 0;
  l_number_of_warnings  NUMBER := 0;
  l_msg_data                  VARCHAR2(32767);
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'AUTOCREATE_DELIVERIES';
--

  --
  -- Following 4 variables are added for bugfix #4070732
  l_api_session_name CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
  l_reset_flags BOOLEAN;
  --
BEGIN
	-- Bugfix 4070732
	IF WSH_UTIL_CORE.G_START_OF_SESSION_API is null
	THEN
		WSH_UTIL_CORE.G_START_OF_SESSION_API     := l_api_session_name;
		WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API := FALSE;
	END IF;
	-- End of Code Bugfix 4070732
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  SAVEPOINT  AUTOCREATE_DEL_GRP;

    -- Standard begin of API savepoint
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
      WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
      WSH_DEBUG_SV.log(l_module_name,'P_LINE_ROWS.COUNT',P_LINE_ROWS.COUNT);
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

  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_AUTOCREATE.AUTOCREATE_DEL_ACROSS_ORGS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_delivery_autocreate.autocreate_del_across_orgs(
    p_line_rows         => p_line_rows,
    p_org_rows     => l_dummy_rows, -- bug 1668578
    p_container_flag     => 'N',
    p_check_flag         => 'N',
    p_caller             => p_caller,
    p_max_detail_commit  => NULL,
    p_group_by_header_flag   => p_group_by_header_flag,
    x_del_rows           => x_del_rows,
    x_grouping_rows      => l_dummy_rows,
    x_return_status      => l_return_status);

  wsh_util_core.api_post_call(
     p_return_status => l_return_status,
     x_num_warnings  => l_number_of_warnings,
     x_num_errors    => l_number_of_errors,
     p_msg_data      => l_msg_data
     );

  IF l_number_of_warnings > 0 THEN
    IF l_debug_on THEN
              wsh_debug_sv.log(l_module_name,'Number of warnings', l_number_of_warnings);
    END IF;
    RAISE WSH_UTIL_CORE.G_EXC_WARNING;
  END IF;


  IF FND_API.TO_BOOLEAN(p_commit) THEN
    --
    -- Start code for Bugfix 4070732
    --
	IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
	   IF l_debug_on THEN
		 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
	   END IF;
           l_reset_flags := FALSE;

	   WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => l_reset_flags,
						       x_return_status => l_return_status);

	   IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
	   END IF;

           IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
           ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              RAISE WSH_UTIL_CORE.G_EXC_WARNING;
           END IF;

	END IF;
    --
    -- End of code for Bugfix 4070732
    --
    COMMIT WORK;
  END IF;


    --bug 4070732
    --End of the API handling of calls to process_stops_for_load_tender
    IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
    --{
        IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
        --{

           IF FND_API.TO_BOOLEAN(p_commit) THEN

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_UTIL_CORE.reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);

           ELSE

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);
           END IF;

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            END IF;

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                x_return_status := l_return_status;

              IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                   WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                IF NOT(FND_API.TO_BOOLEAN(p_commit)) THEN
                 ROLLBACK TO AUTOCREATE_DEL_GRP;
	        end if;
              END IF;
            END IF;
        --}
        END IF;
    --}
    END IF;

    --bug 4070732
    --
  FND_MSG_PUB.Count_And_Get
  (
    p_count  => x_msg_count,
    p_data  =>  x_msg_data,
    p_encoded => FND_API.G_FALSE
  );


       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'X_DEL_ROWS.COUNT',x_del_rows.count);
          WSH_DEBUG_SV.pop(l_module_name);
       END IF;
--
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO AUTOCREATE_DEL_GRP;
                x_return_status := FND_API.G_RET_STS_ERROR ;
             --
             -- Start code for Bugfix 4070732
             --
             IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name)
             THEN
             --{
                IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
                --{
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;

                  WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                     x_return_status => l_return_status);

                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                  END IF;

                  IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                     x_return_status := l_return_status;
                  END IF;
                --}
                END IF;
              --}
             END IF;
             --
             -- End of Code Bugfix 4070732
             --
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

    WHEN autocreate_delivery_failed THEN
                ROLLBACK TO AUTOCREATE_DEL_GRP;
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                        wsh_util_core.add_message(x_return_status, l_module_name);
             --
             -- Start code for Bugfix 4070732
             --
             IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name)
             THEN
             --{
                IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
                --{
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;

                  WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                     x_return_status => l_return_status);

                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                  END IF;

                  IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                     x_return_status := l_return_status;
                  END IF;
                --}
                END IF;
              --}
             END IF;
             --
             -- End of Code Bugfix 4070732
             --

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

        WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
             x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      -- Start code for Bugfix 4070732
      --
       IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name)
       THEN
       --{
          IF NOT (WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API)
          THEN
          --{

             WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => TRUE,
                                                         x_return_status => l_return_status);

             IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
             END IF;

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                x_return_status := l_return_status;

              IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                   WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                 ROLLBACK TO AUTOCREATE_DEL_GRP;
              END IF;
             END IF;
          --}
          END IF;
      ---}
      END IF;
     --
     -- End of Code Bugfix 4070732
     --

            FND_MSG_PUB.Count_And_Get
             (
               p_count  => x_msg_count,
               p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
             );


           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
           END IF;
      --
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO AUTOCREATE_DEL_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		--
		-- Start of code for Bugfix 4070732
		--
		   IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
		      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
			 IF l_debug_on THEN
			       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
			 END IF;

			 WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
								   x_return_status => l_return_status);


			 IF l_debug_on THEN
			      WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
			 END IF;

		      END IF;
		   END IF;
		--
		-- End of code for Bugfix 4070732
		--
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
        WHEN OTHERS THEN
                ROLLBACK TO AUTOCREATE_DEL_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               wsh_util_core.add_message(x_return_status, l_module_name);
               WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_GRP.Autocreate_Deliveries');
		--
		-- Start of code for Bugfix 4070732
		--
		   IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
		      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
			 IF l_debug_on THEN
			       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
			 END IF;

			 WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
								   x_return_status => l_return_status);


			 IF l_debug_on THEN
			      WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
			 END IF;

		      END IF;
		   END IF;
		--
		-- End of code for Bugfix 4070732
		--
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
, x_trip_rows                   OUT NOCOPY WSH_UTIL_CORE.id_tab_type
)
IS
l_api_name    CONSTANT  VARCHAR2(30):= 'Autocreate_del_trip';
l_api_version_number CONSTANT NUMBER := 1.0;
l_return_status VARCHAR2(30);
autocreate_trip_failed EXCEPTION;
l_msg_summary varchar2(2000)  := NULL;
l_msg_details varchar2(4000)  := NULL;
l_org_rows    wsh_util_core.id_tab_type; -- bug 1668578
  l_number_of_errors    NUMBER := 0;
  l_number_of_warnings  NUMBER := 0;
  l_msg_data                  VARCHAR2(32767);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'AUTOCREATE_DEL_TRIP';
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
  SAVEPOINT AUTOCREATE_TRIP_GRP;
    -- Standard begin of API savepoint

  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
      WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
      WSH_DEBUG_SV.log(l_module_name,'P_LINE_ROWS.COUNT',P_LINE_ROWS.COUNT);
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

  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_ACTIONS.AUTOCREATE_DEL_TRIP',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  WSH_TRIPS_ACTIONS.autocreate_del_trip(
    p_line_rows     => p_line_rows,
    p_org_rows    => l_org_rows,  -- bug 1668578
    x_del_rows    => x_del_rows,
    x_trip_rows   => x_trip_rows,
    x_return_status   => l_return_status);

            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );


        IF l_number_of_warnings > 0 THEN
           IF l_debug_on THEN
              wsh_debug_sv.log(l_module_name,'Number of warnings', l_number_of_warnings);
           END IF;
           RAISE WSH_UTIL_CORE.G_EXC_WARNING;
        END IF;


                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE
                  );

       IF FND_API.TO_BOOLEAN(p_commit) THEN
         COMMIT WORK;
       END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'X_DEL_ROWS.COUNT',x_del_rows.count);
            WSH_DEBUG_SV.log(l_module_name, 'X trip rows.count', x_trip_rows.count);
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
--
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO AUTOCREATE_TRIP_GRP;
                x_return_status := FND_API.G_RET_STS_ERROR ;
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
    WHEN autocreate_trip_failed THEN
                ROLLBACK TO AUTOCREATE_TRIP_GRP;
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                        wsh_util_core.add_message(x_return_status);
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
        --
        WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
             x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
            FND_MSG_PUB.Count_And_Get
             (
               p_count  => x_msg_count,
               p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
             );
            --
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
           END IF;
      --
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO AUTOCREATE_TRIP_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
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
        WHEN OTHERS THEN
                ROLLBACK TO AUTOCREATE_TRIP_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               wsh_util_core.add_message(x_return_status, l_module_name);
               WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_GRP.Autocreate_Del_Trip');
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


    -- ---------------------------------------------------------------------
    -- Procedure: Delivery_Detail_Action
    --
    -- Parameters:
    --
    -- Description:  This procedure is the core group API for the
    --               delivery_detail_action. This is for called by STF directly.
    --         Public API and other product APIs call the wrapper version.
    --               The wrapper version, in turn, calls this procedure.
    -- Created:   Harmonization Project. Patchset I
    -- -----------------------------------------------------------------------
    PROCEDURE Delivery_Detail_Action(
    -- Standard Parameters
       p_api_version_number        IN       NUMBER,
       p_init_msg_list             IN       VARCHAR2,
       p_commit                    IN       VARCHAR2,
       x_return_status             OUT  NOCOPY    VARCHAR2,
       x_msg_count                 OUT  NOCOPY    NUMBER,
       x_msg_data                  OUT  NOCOPY    VARCHAR2,

    -- Procedure specific Parameters
       p_rec_attr_tab              IN     WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type,
       p_action_prms               IN     WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type,
       x_defaults                  OUT  NOCOPY    WSH_GLBL_VAR_STRCT_GRP.dd_default_parameters_rec_type,  -- defaults
       x_action_out_rec            OUT  NOCOPY    WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type
       ) IS

        l_api_name              CONSTANT VARCHAR2(30)   := 'delivery_detail_action';
        l_api_version           CONSTANT NUMBER         := 1.0;
        --
  --
  l_return_status             VARCHAR2(32767);
  l1_return_status             VARCHAR2(32767);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(32767);
  l_program_name              VARCHAR2(32767);
        l_validation_level          NUMBER;
        --
        --
  --
  l_number_of_errors    NUMBER := 0;
  l_number_of_warnings  NUMBER := 0;
        l_counter             NUMBER := 0;
        l_index               NUMBER;
        check_status          NUMBER;

        -- Variables for pack, unpack, auto-pack
        l_group_id_tab     WSH_UTIL_CORE.ID_TAB_TYPE;
        l_entity_type      VARCHAR2(32767);
        l_cont_flag        VARCHAR2(32767);
        l_container_name   VARCHAR2(32767);
        l_delivery_flag    VARCHAR2(32767);
        l_cont_instance_id NUMBER;


  -- Variables for cycle_count
        l_bo_rows          WSH_UTIL_CORE.Id_Tab_Type;
        l_bo_qtys          WSH_UTIL_CORE.Id_Tab_Type;
        l_req_qtys         WSH_UTIL_CORE.Id_Tab_Type;
        l_bo_qtys2         WSH_UTIL_CORE.Id_Tab_Type;
        l_overpick_qtys    WSH_UTIL_CORE.Id_Tab_Type;
        l_overpick_qtys2   WSH_UTIL_CORE.Id_Tab_Type;

        --
        l_released_status     VARCHAR2(32767);
        l_line_direction      VARCHAR2(32767);
        l_inventory_item_id   NUMBER;
        l_requested_quantity  NUMBER;
        l_requested_quantity2 NUMBER;
        l_picked_quantity     NUMBER;
        l_picked_quantity2    NUMBER;
        l_shipped_quantity    NUMBER;
        l_shipped_quantity2   NUMBER;
        l_inv_item_id         NUMBER;
        l_organization_id     NUMBER;
        l_requested_quantity_uom            VARCHAR2(32767);
-- HW OPMCONV - Added variable uom2
        l_requested_quantity_uom2           VARCHAR2(32767);
        l_output_quantity     NUMBER;
        l_split_quantity      NUMBER;
        l_split_quantity2     NUMBER;
        l_manual_split        VARCHAR2(1);
        l_converted_flag  VARCHAR2(1); -- HW OPM

        --
        l_validation_level_tab WSH_UTIL_CORE.Id_Tab_Type;
        l_id_tab               WSH_UTIL_CORE.Id_Tab_Type;
        l_dummy_ids            WSH_UTIL_CORE.Id_Tab_Type;
        l_request_ids          WSH_UTIL_CORE.Id_Tab_Type;
        l_valid_ids            WSH_UTIL_CORE.Id_Tab_Type;
        l_error_ids            WSH_UTIL_CORE.Id_Tab_Type;
        l_valid_index_tab      WSH_UTIL_CORE.Id_Tab_Type;
        l_valid_ids_tab        WSH_UTIL_CORE.Id_Tab_Type;
        --
        --anxsharm for load tender
        l_trip_id_tab          WSH_UTIL_CORE.Id_Tab_Type;

        l_dlvy_organization_id  NUMBER;
        l_dlvy_status_code          VARCHAR2(32767);
        l_dlvy_planned_flag         VARCHAR2(32767);
        l_dlvy_shipment_direction   VARCHAR2(30);
        --
        l_detail_rec_tab       WSH_DETAILS_VALIDATIONS.detail_rec_tab_type;
        l_dlvy_rec_tab         WSH_DELIVERY_VALIDATIONS.dlvy_rec_tab_type;
        l_det_id_tab           WSH_UTIL_CORE.ID_TAB_TYPE;
        l_detail_group_params  wsh_delivery_autocreate.grp_attr_rec_type;

        l_attr_tab  wsh_delivery_autocreate.grp_attr_tab_type;
        l_group_info  wsh_delivery_autocreate.grp_attr_tab_type;
        l_action_rec wsh_delivery_autocreate.action_rec_type;
        l_target_rec wsh_delivery_autocreate.grp_attr_rec_type;
        l_matched_entities wsh_util_core.id_tab_type;
        l_out_rec wsh_delivery_autocreate.out_rec_type;

	-- Consolidation of BO Delivery details project
	l_line_ids	   WSH_UTIL_CORE.Id_Tab_Type;
	l_cons_flags        WSH_UTIL_CORE.Column_Tab_Type;
	l_global_param_rec  WSH_SHIPPING_PARAMS_PVT.Global_Parameters_Rec_Typ;

        CURSOR det_cur(p_del_det_id NUMBER) IS
          SELECT inventory_item_id
               , organization_id
               , requested_quantity_uom
               , nvl(line_direction,'O') line_direction -- J-IB-NPARIKH
               , released_status
          FROM wsh_delivery_details
          WHERE delivery_detail_id = p_del_det_id;

-- HW Harmonization project for OPM. Need to get organization_id
-- HW OPMCONV  - 1) Added retrieval of UOM2 -
--             - 2) Changed name to det_line
        CURSOR det_line(l_del_det_id NUMBER) IS
          SELECT nvl(line_direction,'O') line_direction, requested_quantity_uom2
          FROM wsh_delivery_details
          WHERE delivery_detail_id = l_del_det_id;
-- HW OPM end

  --
        CURSOR cycle_count_cur(p_del_det_id NUMBER) IS
          SELECT released_status, requested_quantity,  requested_quantity2,
                 picked_quantity,  picked_quantity2 , shipped_quantity , shipped_quantity2,
                 organization_id, inventory_item_id
          FROM wsh_delivery_details
          WHERE delivery_detail_id = p_del_det_id;

        --
        CURSOR del_cur(p_dlvy_id NUMBER) IS
          SELECT organization_id,
                 status_code,
                 planned_flag,
                 nvl(shipment_direction, 'O'),  -- shipment_direction jckwok
                 nvl(ignore_for_planning, 'N'), -- OTM R12 : WSHDEVLS record
                 nvl(tms_interface_flag, WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT)                                           -- OTM R12 : WSHDEVLS record
          FROM wsh_new_deliveries
          WHERE delivery_id = p_dlvy_id;

        --
        -- deliveryMerge

        CURSOR get_delivery(p_del_det_id NUMBER) IS
          SELECT wda.delivery_id
          FROM wsh_delivery_assignments_v wda, wsh_delivery_details wdd
          WHERE wdd.delivery_detail_id = p_del_det_id
                AND wdd.delivery_detail_id = wda.delivery_detail_id
                AND wdd.container_flag = 'N'
                AND wdd.source_code = 'OE'
                AND NVL(wdd.line_direction, 'O') in ('O', 'IO');

l_debug_on BOOLEAN;
       --
       l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELIVERY_DETAIL_ACTION';


--Compatibility Changes
    l_cc_validate_result    VARCHAR2(1);
    l_cc_failed_records     WSH_FTE_COMP_CONSTRAINT_PKG.failed_line_tab_type;
    l_cc_line_groups      WSH_FTE_COMP_CONSTRAINT_PKG.line_group_tab_type;
    l_cc_group_info     WSH_FTE_COMP_CONSTRAINT_PKG.cc_group_tab_type;


    b_cc_linefailed     boolean;
    b_cc_groupidexists      boolean;
    l_id_tab_temp     wsh_util_core.id_tab_type;
    l_id_tab_t        wsh_util_core.id_tab_type;
    l_cc_count_success      NUMBER;
    l_cc_count_group_ids    NUMBER;
    l_cc_count_rec      NUMBER;
    l_cc_group_ids      wsh_util_core.id_tab_type;

    l_cc_upd_dlvy_intmed_ship_to  VARCHAR2(1);
    l_cc_upd_dlvy_ship_method   VARCHAR2(1);
    l_cc_dlvy_intmed_ship_to    NUMBER;
    l_cc_dlvy_ship_method   VARCHAR2(30);

    l_cc_count_del_rows     NUMBER;
    l_num_errors      NUMBER;
    l_cc_del_rows     wsh_util_core.id_tab_type;
    l_cc_grouping_rows      wsh_util_core.id_tab_type;
    l_cc_return_status      VARCHAR2(1);
    l_trip_id       NUMBER;

    --dummy tables for calling validate_constraint_mainper
    l_cc_del_attr_tab         WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
    l_cc_det_attr_tab         WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type;
    l_cc_trip_attr_tab          WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
    l_cc_stop_attr_tab          WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
    l_cc_in_ids           wsh_util_core.id_tab_type;
    l_cc_fail_ids   wsh_util_core.id_tab_type;

    l_delivery_detail_id  NUMBER;

    CURSOR c_delcur(p_dlvy_id NUMBER) IS
    SELECT SHIP_METHOD_CODE, INTMED_SHIP_TO_LOCATION_ID
    FROM wsh_new_deliveries
    WHERE delivery_id = p_dlvy_id;

--Compatibility Changes

    l_action_code VARCHAR2(32767);
--
    -- deliveryMerge
    l_delivery_ids   wsh_util_core.id_tab_type;
    l_delivery_id    NUMBER;
    l_delivery_already_included boolean;
    --
    --
    l_cnt            NUMBER;
    l_action_prms    WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
    --

    l_dummy_line_ids    WSH_UTIL_CORE.Id_Tab_Type;

    e_end_of_api     EXCEPTION;
    --dcp
    l_check_dcp NUMBER;
--Bugfix 4070732
    l_api_session_name CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
    l_reset_flags BOOLEAN;

    -- K LPN CONV. rv
    l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
    l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
    -- K LPN CONV. rv
    --

    -- OTM R12 : due to record changes in WSHDEVLS
    l_dlvy_ignore         WSH_NEW_DELIVERIES.IGNORE_FOR_PLANNING%TYPE;
    l_tms_interface_flag  WSH_NEW_DELIVERIES.TMS_INTERFACE_FLAG%TYPE;
    -- End of OTM R12 : due to record changes in WSHDEVLS

    -- OTM R12 : packing ECO
    l_gc3_is_installed    VARCHAR2(1);
    -- End of OTM R12 : packing ECO


  BEGIN
       --dcp
       <<api_start>>

	-- Bugfix 4070732
	IF WSH_UTIL_CORE.G_START_OF_SESSION_API is null
	THEN
		WSH_UTIL_CORE.G_START_OF_SESSION_API     := l_api_session_name;
		WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API := FALSE;
	END IF;
	-- End of Code Bugfix 4070732

        -- Standard Start of API savepoint
        --
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
        --
        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;
        --
        SAVEPOINT   DELIVERY_DETAIL_ACTION_GRP;

       l_check_dcp := WSH_DCP_PVT.G_CHECK_DCP;

       if l_check_dcp is null then
          l_check_dcp := wsh_dcp_pvt.is_dcp_enabled;
       end if;

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            --
            WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
            WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
            WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
            WSH_DEBUG_SV.log(l_module_name, 'Caller', p_action_prms.caller);
            WSH_DEBUG_SV.log(l_module_name, 'Phase', p_action_prms.phase);
            WSH_DEBUG_SV.log(l_module_name, 'Action Code', p_action_prms.action_code);
            WSH_DEBUG_SV.log(l_module_name, 'Input Table count', p_rec_attr_tab.count);
        END IF;
        --
        -- Initialize message list if p_init_msg_list is set to TRUE.
  --
        IF FND_API.to_Boolean( p_init_msg_list )
  THEN
                FND_MSG_PUB.initialize;
        ELSE
           IF nvl(l_check_dcp, -99) IN (1,2) THEN
                WSH_DCP_PVT.G_INIT_MSG_COUNT := fnd_msg_pub.count_msg;
           END IF;
        END IF;
  --
        --  Initialize API return status to success
  x_return_status       := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_number_of_errors := 0;
  l_number_of_warnings := 0;

       -- deliveryMerge
       l_delivery_ids.delete;

        -- Mandatory parameters check
        IF( p_action_prms.caller IS NULL) THEN
            FND_MESSAGE.SET_NAME('WSH', 'WSH_REQUIRED_FIELD_NULL');
            FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'CALLER');
            wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
           IF l_debug_on THEN
              wsh_debug_sv.logmsg(l_module_name,'Null Caller');
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        ELSIF(p_action_prms.action_code IS NULL) THEN
           FND_MESSAGE.SET_NAME('WSH', 'WSH_REQUIRED_FIELD_NULL');
           FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'ACTION_CODE');
            wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
           IF l_debug_on THEN
              wsh_debug_sv.logmsg(l_module_name,'WSH_INVALID_ACTION_CODE');
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF(p_rec_attr_tab.count = 0) THEN
           IF l_debug_on THEN
              wsh_debug_sv.logmsg(l_module_name,'Table count zero');
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        --
        -- bug 2788946
        -- This condition is added so that we treat these actions
        -- as equivalent to "PICK-RELEASE" ONLY during
        -- setting the levels and validating the eligibility of the action
        IF p_action_prms.action_code IN ('PICK-SHIP', 'PICK-PACK-SHIP') THEN
            l_action_code := 'PICK-RELEASE';
        ELSE
            l_action_code := p_action_prms.action_code;
        END IF;
        --
        --
        -- J-IB-NPARIKH-{
        --
        IF l_action_code = 'SPLIT_DELIVERY'
        THEN
        --{
            l_action_prms := p_action_prms;
            --
            l_action_prms.caller       := p_action_prms.caller || WSH_UTIL_CORE.C_SPLIT_DLVY_SUFFIX;
            l_action_prms.action_code  := 'UNASSIGN';
            --
            Delivery_Detail_Action
                (
                   p_api_version_number     => p_api_version_number,
                   p_init_msg_list          => FND_API.G_FALSE,
                   p_commit                 => FND_API.G_FALSE,
                   x_return_status          => l_return_status,
                   x_msg_count              => l_msg_count,
                   x_msg_data               => l_msg_data,
                   p_rec_attr_tab           => p_rec_attr_tab,
                   p_action_prms            => l_action_prms,
                   x_defaults               => x_defaults,
                   x_action_out_rec         => x_action_out_rec
                );
            --
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_number_of_warnings,
                x_num_errors    => l_number_of_errors,
                p_msg_data      => l_msg_data
              );
            --
            --
            l_action_prms.caller       := p_action_prms.caller || WSH_UTIL_CORE.C_SPLIT_DLVY_SUFFIX;
            --
            --
            IF  p_action_prms.delivery_id IS NULL
            AND p_action_prms.delivery_name IS NULL
            THEN
                l_action_prms.action_code  := 'AUTOCREATE-DEL';
            ELSE
                l_action_prms.action_code  := 'ASSIGN';
            END IF;
            --
            Delivery_Detail_Action
                (
                   p_api_version_number     => p_api_version_number,
                   p_init_msg_list          => FND_API.G_FALSE,
                   p_commit                 => FND_API.G_FALSE,
                   x_return_status          => l_return_status,
                   x_msg_count              => l_msg_count,
                   x_msg_data               => l_msg_data,
                   p_rec_attr_tab           => p_rec_attr_tab,
                   p_action_prms            => l_action_prms,
                   x_defaults               => x_defaults,
                   x_action_out_rec         => x_action_out_rec
                );
            --
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_number_of_warnings,
                x_num_errors    => l_number_of_errors,
                p_msg_data      => l_msg_data
              );
            --
            RAISE e_end_of_api;
        --}
        END IF;
        --
        -- J-IB-NPARIKH-}
        --
        --
        --
        -- Set validation level
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ACTIONS_LEVELS.SET_VALIDATION_LEVEL',WSH_DEBUG_SV.C_PROC_LEVEL);
            WSH_DEBUG_SV.log(l_module_name,'l_action_code',l_action_code);
        END IF;
        --
        wsh_actions_levels.set_validation_level(
            p_entity           => 'DLVB',
            p_caller           => p_action_prms.caller,
            p_phase            => nvl(p_action_prms.phase,1),
            p_action           => l_action_code,
            x_return_status    => l_return_status
        );

            --
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

        l_validation_level_tab := wsh_actions_levels.g_validation_level_tab;

        -- Need to create l_detail_rec_tab to call Is_Action_Enabled

        l_index := p_rec_attr_tab.FIRST;
        while l_index is not null
        loop

            IF NVL(p_action_prms.phase,1) = 1 THEN
                  l_detail_rec_tab(l_index).delivery_detail_id := p_rec_attr_tab(l_index).delivery_detail_id;
                  l_detail_rec_tab(l_index).organization_id    := p_rec_attr_tab(l_index).organization_id;
                  l_detail_rec_tab(l_index).released_status    := p_rec_attr_tab(l_index).released_status;
                  l_detail_rec_tab(l_index).container_flag     := p_rec_attr_tab(l_index).container_flag;
                  l_detail_rec_tab(l_index).source_code        := p_rec_attr_tab(l_index).source_code;
                  l_detail_rec_tab(l_index).lpn_id             := p_rec_attr_tab(l_index).lpn_id;
                  -- J Inbound Logistics: need to populate line_direction,sf_locn_id before calling Is_Action_Enabled
                  l_detail_rec_tab(l_index).line_direction     := p_rec_attr_tab(l_index).line_direction;
                  -- J-IB-NPARIKH
                  --
                  -- Populate ship from location from database
                  -- so that it can be utlized to validate if actions
                  -- are enabled/disabled.
                  --
                  l_detail_rec_tab(l_index).ship_from_location_id := p_rec_attr_tab(l_index).ship_from_location_id;

                  -- R12, X-dock
                  l_detail_rec_tab(l_index).move_order_line_id := p_rec_attr_tab(l_index).move_order_line_id;

            END IF;
            l_id_tab(l_index) := p_rec_attr_tab(l_index).delivery_detail_id;
            l_index := p_rec_attr_tab.NEXT(l_index);
        END LOOP;


        -- Call Is_Action_Enabled API depending on validation level
        IF l_validation_level_tab(wsh_actions_levels.C_ACTION_ENABLED_LVL) = 1  THEN
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.IS_ACTION_ENABLED',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_DETAILS_VALIDATIONS.Is_Action_Enabled(
                p_del_detail_rec_tab    => l_detail_rec_tab,
                p_action                => l_action_code,
                p_caller                => p_action_prms.caller,
                p_deliveryid            => p_action_prms.delivery_id,
                x_return_status         => l_return_status,
                x_valid_ids             => l_valid_ids,
                x_error_ids             => l_error_ids,
                x_valid_index_tab       => l_valid_index_tab
               );

               IF l_debug_on THEN
                  wsh_debug_sv.log(l_module_name,'Is_Action_Enabled returns',
                                                         l_return_status);
               END IF;
            --
            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data,
               p_raise_error_flag => FALSE
               );
        END IF;

        IF(l_number_of_errors >0 ) THEN
         --{
         IF p_action_prms.caller = 'WSH_FSTRX' THEN
            FND_MESSAGE.SET_NAME('WSH', 'WSH_DISABLE_ACTION');
            wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
         END IF;
         --
         IF l_debug_on THEN
             wsh_debug_sv.logmsg(l_module_name, 'WSH_DISABLE_ACTION');
         END IF;
         --
         raise FND_API.G_EXC_ERROR;
         --}
        END IF;

        IF( l_validation_level_tab(wsh_actions_levels.C_DLVY_ACTION_ENABLED_LVL) = 1) THEN

      --
            IF(p_action_prms.delivery_id IS NOT NULL) THEN

               OPEN del_cur(p_action_prms.delivery_id);
               FETCH del_cur INTO l_dlvy_organization_id, l_dlvy_status_code,
                                  l_dlvy_planned_flag,
                                  l_dlvy_shipment_direction,
                                  l_dlvy_ignore,        -- OTM R12 : WSHDEVLS
                                  l_tms_interface_flag; -- OTM R12 : WSHDEVLS

               IF del_cur%NOTFOUND THEN
                  CLOSE del_cur;
                  FND_MESSAGE.SET_NAME('WSH', 'WSH_INVALID_DELIVERY');
                  FND_MESSAGE.SET_TOKEN('DELIVERY', p_action_prms.delivery_id);
                 wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
                  IF l_debug_on THEN
                     wsh_debug_sv.logmsg(l_module_name, 'Delivery does not exist');
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
               CLOSE del_cur;
            ELSE
               FND_MESSAGE.SET_NAME('WSH', 'WSH_REQUIRED_FIELD_NULL');
               FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'DELIVERY_ID');
            wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
               IF l_debug_on THEN
                  wsh_debug_sv.logmsg(l_module_name, 'Null Delivery Id');
               END IF;
               RAISE FND_API.G_EXC_ERROR;
            END IF;

            l_dlvy_rec_tab(1).delivery_id     :=  p_action_prms.delivery_id;
            l_dlvy_rec_tab(1).organization_id :=  l_dlvy_organization_id;
            l_dlvy_rec_tab(1).status_code     :=  l_dlvy_status_code;
            l_dlvy_rec_tab(1).planned_flag    :=  l_dlvy_planned_flag;
            -- J Inbound jckwok
            l_dlvy_rec_tab(1).shipment_direction  := l_dlvy_shipment_direction;
            -- call dlvy's action enabled.

            -- OTM R12 : due to record changes in WSHDEVLS
            l_dlvy_rec_tab(1).ignore_for_planning :=  l_dlvy_ignore;
            l_dlvy_rec_tab(1).tms_interface_flag  :=  l_tms_interface_flag;
            -- End of OTM R12 : due to record changes in WSHDEVLS

               --

               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.IS_ACTION_ENABLED',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               wsh_delivery_validations.Is_Action_Enabled(
                p_dlvy_rec_tab          => l_dlvy_rec_tab,
                p_action                => p_action_prms.action_code,
                p_caller                => p_action_prms.caller,
                x_return_status         => l_return_status,
                x_valid_ids             => l_valid_ids,
                x_error_ids             => l_error_ids,
                x_valid_index_tab       => l_valid_index_tab
               );
               --
            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data,
               p_raise_error_flag => FALSE
               );

            IF p_action_prms.caller = 'WSH_FSTRX' THEN
                 x_action_out_rec.valid_id_tab := l_valid_index_tab;
            ELSE
                 x_action_out_rec.valid_id_tab := l_valid_ids;
            END IF;
            --
        END IF;

        -- Lock records
        IF  l_validation_level_tab(wsh_actions_levels.C_LOCK_RECORDS_LVL) = 1 THEN

            -- we need to send only the valid records to lock procedure
            -- Build the table using the valid index output from Is_Action_Enabled
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.LOCK_DELIVERY_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
	 IF  NOT (    p_action_prms.caller = 'WSH_FSTRX'
                  AND p_action_prms.action_code =  'DELETE'
                  ) THEN  --BUG 4354579
            wsh_delivery_details_pkg.Lock_Delivery_Details(
               p_rec_attr_tab          => p_rec_attr_tab,
               p_caller                => p_action_prms.caller,
               p_valid_index_tab       => l_valid_index_tab,
               x_valid_ids_tab         => l_valid_ids_tab,
               x_return_status         => l_return_status
               );

              x_action_out_rec.valid_id_tab := l_valid_ids_tab;

            --
            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data,
               p_raise_error_flag => FALSE
               );
	 END IF;
        END IF;

        --
       IF(l_number_of_errors >0 ) THEN
           FND_MESSAGE.SET_NAME('WSH', 'WSH_DISABLE_ACTION');
            wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
           IF l_debug_on THEN
               wsh_debug_sv.logmsg(l_module_name, 'WSH_DISABLE_ACTION');
           END IF;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
         --
         IF l_number_of_warnings > 0 THEN

           FND_MESSAGE.SET_NAME('WSH', 'WSH_DISABLE_ACTION_WARN');
            wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
           IF l_debug_on THEN
               wsh_debug_sv.logmsg(l_module_name, 'WSH_DISABLE_ACTION_WARN');
            END IF;

            IF(p_action_prms.caller = 'WSH_FSTRX') THEN
                 x_action_out_rec.selection_issue_flag := 'Y';
                 RAISE WSH_UTIL_CORE.G_EXC_WARNING;
            ELSE
               IF l_debug_on THEN
                  wsh_debug_sv.log(l_module_name,'Number of warnings', l_number_of_warnings);
               END IF;
                 RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;


    IF l_validation_level_tab(wsh_actions_levels.C_VALIDATE_CONSTRAINTS_LVL) = 1
    THEN --{

   --Compatibility Changes
    -- Autocreate trip calls autocreate del and then autocreate trip so the constraint validation
    -- will be done at that point (in private API)
    -- actions PACK, AUTO-PACK, AUTO-PACK-MASTER only post-I (constraints for these have not been implemented yet)

       IF wsh_util_core.fte_is_installed = 'Y' THEN

          WSH_FTE_COMP_CONSTRAINT_PKG.validate_constraint_main(
          p_api_version_number =>  1.0,
          p_init_msg_list      =>  FND_API.G_FALSE,
          p_entity_type        =>  'L',
          p_target_id          =>  p_action_prms.DELIVERY_ID,
          p_action_code        =>  p_action_prms.action_code,
          p_del_attr_tab       =>  l_cc_del_attr_tab,
          p_det_attr_tab       =>  p_rec_attr_tab,
          p_trip_attr_tab      =>  l_cc_trip_attr_tab,
          p_stop_attr_tab      =>  l_cc_stop_attr_tab,
          p_in_ids             =>  l_cc_in_ids,
          x_fail_ids           =>  l_cc_fail_ids,
          x_validate_result          =>  l_cc_validate_result,
          x_failed_lines             =>  l_cc_failed_records,
          x_line_groups              =>  l_cc_line_groups,
          x_group_info               =>  l_cc_group_info,
          x_msg_count                =>  l_msg_count,
          x_msg_data                 =>  l_msg_data,
          x_return_status            =>  l_return_status);

         IF l_debug_on THEN
           wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_constraint_main',l_return_status);
           wsh_debug_sv.log(l_module_name,'validate_result After Calling validate_constraint_main',l_cc_validate_result);
           wsh_debug_sv.log(l_module_name,'msg_count After Calling validate_constraint_main',l_msg_count);
           wsh_debug_sv.log(l_module_name,'msg_data After Calling validate_constraint_main',l_msg_data);
           wsh_debug_sv.log(l_module_name,'fail_ids count After Calling validate_constraint_main',l_cc_failed_records.COUNT);
           wsh_debug_sv.log(l_module_name,'l_cc_line_groups.count count After Calling validate_constraint_main',l_cc_line_groups.COUNT);
           wsh_debug_sv.log(l_module_name,'group_info count After Calling validate_constraint_main',l_cc_group_info.COUNT);
         END IF;
         --

        IF l_return_status=wsh_util_core.g_ret_sts_error  THEN
           --fix p_rec_attr_tab to have only successful records
           l_cc_count_success:=1;

           IF l_debug_on THEN
               wsh_debug_sv.log(l_module_name,'p_rec_attr_tab count before removing failed lines',p_rec_attr_tab.COUNT);
           END IF;

           IF l_cc_failed_records.COUNT>0 AND p_rec_attr_tab.COUNT>0 THEN

             --set return_status as warning
             IF l_cc_failed_records.COUNT<>p_rec_attr_tab.COUNT THEN
                l_return_status:=wsh_util_core.g_ret_sts_warning;
             END IF;

             FOR i in p_rec_attr_tab.FIRST..p_rec_attr_tab.LAST LOOP
               b_cc_linefailed:=FALSE;
               FOR j in l_cc_failed_records.FIRST..l_cc_failed_records.LAST LOOP
                   IF (p_rec_attr_tab(i).delivery_detail_id=l_cc_failed_records(j).entity_line_id) THEN
                     b_cc_linefailed:=TRUE;
                     FND_MESSAGE.SET_NAME('WSH','WSH_DELDET_COMP_FAILED');
                     FND_MESSAGE.SET_TOKEN('DELDET_ID',l_cc_failed_records(j).entity_line_id);
                     wsh_util_core.add_message(l_return_status);
                   END IF;
               END LOOP;
               IF (NOT(b_cc_linefailed)) THEN
                 l_id_tab_t(l_cc_count_success):=p_rec_attr_tab(i).delivery_detail_id;
                 l_cc_count_success:=l_cc_count_success+1;
               END IF;
             END LOOP;

             --bsadri for assign, if one line fails, then fail all lines {
             IF l_action_code = 'ASSIGN'
                AND l_cc_failed_records.COUNT > 0 THEN
                l_id_tab_t.DELETE;
                l_return_status := wsh_util_core.g_ret_sts_error;
             END IF;
             --}

             IF l_id_tab_t.COUNT>0 THEN
                l_id_tab:=l_id_tab_t;
             ELSE
                IF l_debug_on THEN
                  wsh_debug_sv.logmsg(l_module_name,'all lines errored in compatibility check');
                END IF;
                wsh_util_core.api_post_call(
                    p_return_status    => l_return_status,
                    x_num_warnings     => l_number_of_warnings,
                    x_num_errors       => l_num_errors,
                    p_msg_data         => l_msg_data);
             END IF;

             IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name,'l_id_tab count after removing failed lines',l_id_tab.COUNT);
             END IF;

           END IF;

        ELSIF l_return_status=wsh_util_core.g_ret_sts_unexp_error THEN
           wsh_util_core.api_post_call(
              p_return_status    => l_return_status,
              x_num_warnings     => l_number_of_warnings,
              x_num_errors       => l_num_errors,
              p_msg_data         => l_msg_data);
        END IF;

         wsh_util_core.api_post_call(
           p_return_status    => l_return_status,
           x_num_warnings     => l_number_of_warnings,
           x_num_errors       => l_num_errors,
           p_msg_data         => l_msg_data,
           p_raise_error_flag => FALSE);

       END IF;
       --Compatibility Changes
    END IF; --}




-- HW OPM BUG#:2677054
-- Need this part to be used by form and public API
       IF ( nvl(p_action_prms.phase,1) = 1 ) AND  (p_action_prms.action_code ='SPLIT-LINE' ) THEN

           OPEN  det_cur(l_id_tab(l_id_tab.first));
           FETCH det_cur
           INTO l_inv_item_id
           , l_organization_id
           , l_requested_quantity_uom
           , l_line_direction
           , l_released_status
           ;
           CLOSE det_cur;

-- Check for if line belongs to OPM
-- HW OPMCONV - Removed checking for process
             IF (l_line_direction IN ('O','IO') -- J-IB-NPARIKH
               ) THEN
-- Check if line is allocated , check is required only for outbound lines
-- HW OPMCONV - Removed call to old OPM API is_line_allocated
-- and replaced it with is_split_allowed

-- Check if split is allowed
-- HW OPMCONV - New WSH API to check if split is allowed
                l_delivery_detail_id := l_id_tab(l_id_tab.first);

                IF (NOT WSH_DETAILS_VALIDATIONS.is_split_allowed
                      ( p_delivery_detail_id  => l_delivery_detail_id,
                        p_organization_id     => l_organization_id,
                        p_inventory_item_id   => l_inv_item_id,
                        p_released_status     => l_released_status)
                        ) THEN
                  FND_MESSAGE.SET_NAME('WSH', 'WSH_OPM_LOT_INDIVISIBLE');
                  IF p_action_prms.caller = 'WSH_FSTRX' THEN
                    wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
                END IF;
           END IF;

-- If caller is form, return. We are done
           IF(p_action_prms.caller = 'WSH_FSTRX') THEN
             --Change made during Bugfix 4070732
             --Raise end of api so that handling of return status, reset flags are done there
             RAISE e_end_of_api;
           END IF;

        END IF;


       IF(p_action_prms.caller = 'WSH_FSTRX' AND nvl(p_action_prms.phase,1) = 1 )AND
            (p_action_prms.action_code ='PACK') THEN
            --Change made during Bugfix 4070732
             --Raise end of api so that handling of return status, reset flags are done there
             RAISE e_end_of_api;
        END IF;
-- HW end of BUG#:2677054

        IF p_action_prms.action_code IN('SPLIT-LINE', 'CYCLE-COUNT', 'PICK-RELEASE-UI', 'RESOLVE-EXCEPTIONS-UI') THEN
           IF(p_rec_attr_tab.count > 1) THEN
              FND_MESSAGE.SET_NAME('WSH','WSH_UI_MULTI_SELECTION');
            wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
              IF l_debug_on THEN
                wsh_debug_sv.logmsg(l_module_name,'WSH_UI_MULTI_SELECTION');
              END IF;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;

        IF  l_debug_on THEN
           wsh_debug_sv.log(l_module_name, 'Id Tab Count', l_id_tab.count);
        END IF;

        IF p_action_prms.action_code IN('ASSIGN', 'UNASSIGN') THEN

           IF(p_action_prms.action_code = 'ASSIGN' AND nvl(p_action_prms.phase,1) = 1) THEN
             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'Delivery Id', p_action_prms.delivery_id);
                WSH_DEBUG_SV.log(l_module_name, 'Delivery Name', p_action_prms.delivery_name);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_ASSIGN_DEL_MULTI',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

               wsh_details_validations.check_assign_del_multi(
      p_detail_rows   => l_id_tab,
      x_del_params    => l_detail_group_params,
      x_return_status   => l_return_status);

             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'return status after calling check_assign_del_multi', l_return_status);
                WSH_DEBUG_SV.log(l_module_name, 'group id', l_detail_group_params.group_id);
            END IF;
               wsh_util_core.api_post_call(
                   p_return_status => l_return_status,
                   x_num_warnings  => l_number_of_warnings,
                   x_num_errors    => l_number_of_errors,
                   p_msg_data      => l_msg_data
                   );

               IF p_action_prms.caller = 'WSH_FSTRX' THEN
                  x_defaults.detail_group_params := l_detail_group_params;
                       l_attr_tab(1) := l_detail_group_params;
                       l_attr_tab(1).entity_type := 'DELIVERY_DETAIL';

                       l_target_rec.entity_type := 'DELIVERY';
                       l_action_rec.output_format_type := 'TEMP_TAB';
                       l_action_rec.action := 'MATCH_GROUPS';


                        wsh_delivery_autocreate.Find_Matching_Groups(
                        p_attr_tab => l_attr_tab,
                        p_action_rec => l_action_rec,
                        p_target_rec => l_target_rec,
                        p_group_tab  => l_group_info,
                        x_matched_entities => l_matched_entities,
                        x_out_rec => l_out_rec,
                        x_return_status => l_return_status);

                        wsh_util_core.api_post_call(
                            p_return_status => l_return_status,
                            x_num_warnings  => l_number_of_warnings,
                            x_num_errors    => l_number_of_errors,
                            p_msg_data      => l_msg_data
                            );

                   --Change made during Bugfix 4070732
                   --Raise end of api so that handling of return status, reset flags are done there
                   RAISE e_end_of_api;
               END IF;
            END IF; -- if check for phase

           /*Since the existing procedure Detail_To_Delivery has its own id_tab_type, need to map the id tab */
           l_index := l_id_tab.FIRST;
           WHILE l_index IS NOT NULL LOOP
              l_det_id_tab(l_index) := l_id_tab(l_index);
              l_index := l_id_tab.NEXT(l_index);
           END LOOP;
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_GRP.DETAIL_TO_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_DELIVERY_DETAILS_GRP.detail_to_delivery(
                p_api_version        =>    l_api_version,
                p_init_msg_list      =>    FND_API.G_FALSE,
                p_commit             =>    FND_API.G_FALSE,
                p_validation_level   =>    l_validation_level,
                x_return_status      =>    l_return_status,
                x_msg_count          =>    l_msg_count,
                x_msg_data           =>    l_msg_data,
                p_TabOfDelDets       =>    l_det_id_tab,
                p_action             =>    p_action_prms.action_code,
                p_delivery_id        =>    p_action_prms.delivery_id,
                p_delivery_name      =>    p_action_prms.delivery_name,
                p_action_prms        =>    p_action_prms);


            --
            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );

             IF (l_return_status in (WSH_UTIL_CORE.G_RET_STS_SUCCESS, WSH_UTIL_CORE.G_RET_STS_WARNING)
                 AND p_action_prms.action_code = 'ASSIGN' ) THEN
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.ASSIGN_DELIVERY_UPDATE',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;

                wsh_new_delivery_actions.assign_delivery_update(
        p_delivery_id  => p_action_prms.delivery_id,
        p_del_params   => l_detail_group_params,
        x_return_status => l_return_status);

                    wsh_util_core.api_post_call(
                       p_return_status => l_return_status,
                       x_num_warnings  => l_number_of_warnings,
                       x_num_errors    => l_number_of_errors,
                       p_msg_data      => l_msg_data
                       );

                    -- deliveryMerge
                    -- populate x_action_out_rec.result_id_tab with
                    -- assigned delivery details
                    x_action_out_rec.result_id_tab := l_det_id_tab ;
             END IF;

        --
        ELSIF p_action_prms.action_code = 'SPLIT-LINE' THEN
            --
            --
           IF(nvl(p_action_prms.split_quantity,0) =0) THEN
              FND_MESSAGE.SET_NAME('WSH', 'WSH_NO_ZERO_NUM');
            wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
              IF l_debug_on THEN
                wsh_debug_sv.logmsg(l_module_name,'Zero or Null split quantity');
              END IF;
              RAISE FND_API.G_EXC_ERROR;
           END IF;

            --
            IF l_debug_on THEN
               wsh_debug_sv.log(l_module_name, 'Split Quantity', p_action_prms.split_quantity);
            END IF;

            l_split_quantity := p_action_prms.split_quantity;
            l_split_quantity2 := p_action_prms.split_quantity2;
            --
            --
-- HW Harmonization project for OPM .Need to add converted_flag for OPM
-- Need to check if caller is from STF or not. If call from STF, make l_converted_quantity ='Y'

-- HW OPMCONV - 1) Changed name of cursor
--            - 2) Fetch requested_uom2
            OPEN  det_line(l_id_tab(l_id_tab.first));
            FETCH det_line INTO l_line_direction,l_requested_quantity_uom2;
            CLOSE det_line;

-- HW OPMCONV - 1) No need to check for process_org
--            - 2) check for value of UOM2 before calling the validation
           IF  ( l_requested_quantity_uom2 IS NOT NULL
                AND l_requested_quantity_uom2 <> FND_API.G_MISS_CHAR) THEN

            --{
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.validate_secondary_quantity',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                -- J-IB-NPARIKH-{
															--
-- HW OPMCONV - Added p_caller to validate_secondary_quantity
-- Check that secondary quantity is within tolerance of primary quantity
															--
               IF  l_inventory_item_id is not null
               AND ( p_action_prms.caller like 'FTE%' or l_line_direction not in ('IO','O') )
               THEN
               --{
                   WSH_DETAILS_VALIDATIONS.validate_secondary_quantity
                        (
                            p_delivery_detail_id =>    l_id_tab(l_id_tab.first),
                            x_quantity           =>    l_split_quantity,
                            x_quantity2          =>    l_split_quantity2,
                            p_caller             =>    p_action_prms.caller,
                            x_return_status      =>    l_return_status,
                            x_msg_count          =>    l_msg_count,
                            x_msg_data           =>    l_msg_data
                        );
                   --
                    wsh_util_core.api_post_call(
                       p_return_status => l_return_status,
                       x_num_warnings  => l_number_of_warnings,
                       x_num_errors    => l_number_of_errors,
                       p_msg_data      => l_msg_data
                       );
                   --
                   l_converted_flag := 'Y';
               --}
               -- J-IB-NPARIKH-}
               ELSIF(p_action_prms.caller = 'WSH_FSTRX' AND p_action_prms.phase = 2 )
               THEN
                    l_converted_flag := 'Y';
               ELSE
                    l_converted_flag := NULL;
               END IF;
            --}

          END IF;  -- of UOM2

-- HW Harmonization project forOPM. Added p_manual_split parameter
-- HW added p_converted_flag
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_GRP.SPLIT_LINE',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            WSH_DELIVERY_DETAILS_GRP.split_line(
                p_api_version        =>    l_api_version,
                p_init_msg_list      =>    FND_API.G_FALSE,
                p_commit             =>    FND_API.G_FALSE,
                p_validation_level   =>    l_validation_level,
                x_return_status      =>    l_return_status,
                x_msg_count          =>    l_msg_count,
                x_msg_data           =>    l_msg_data,
                p_from_detail_id     =>    l_id_tab(l_id_tab.first),
                x_new_detail_id      =>    x_action_out_rec.result_id_tab(1),
                x_split_quantity     =>    l_split_quantity,
                x_split_quantity2    =>    l_split_quantity2,
                p_manual_split       =>    l_manual_split,
                p_converted_flag     =>    l_converted_flag);

             x_action_out_rec.split_quantity := l_split_quantity;
             x_action_out_rec.split_quantity2 := l_split_quantity2;

            --
            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );

        --
        ELSIF p_action_prms.action_code = 'AUTOCREATE-DEL' THEN
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_GRP.AUTOCREATE_DELIVERIES',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            --Compatibility Changes
            IF wsh_util_core.fte_is_installed = 'Y' AND l_cc_line_groups.COUNT>0 THEN

              --1. get the group ids by which the constraints API has grouped the lines
              l_cc_count_group_ids:=1;
              FOR i in l_cc_line_groups.FIRST..l_cc_line_groups.LAST LOOP
                b_cc_groupidexists:=FALSE;

                IF l_cc_group_ids.COUNT>0 THEN
                 FOR j in l_cc_group_ids.FIRST..l_cc_group_ids.LAST LOOP
                  IF (l_cc_line_groups(i).line_group_id=l_cc_group_ids(j)) THEN
                    b_cc_groupidexists:=TRUE;
                  END IF;
                 END LOOP;
                END IF;
                IF (NOT(b_cc_groupidexists)) THEN
                  l_cc_group_ids(l_cc_count_group_ids):=l_cc_line_groups(i).line_group_id;
                  l_cc_count_group_ids:=l_cc_count_group_ids+1;
                END IF;
              END LOOP;

              --2. from the group id table above, loop thru lines table to get the lines which belong
              --to each group and call autocreate_del for each group
              FOR i in l_cc_group_ids.FIRST..l_cc_group_ids.LAST LOOP
                l_cc_count_rec:=1;
                FOR j in l_cc_line_groups.FIRST..l_cc_line_groups.LAST LOOP
                  IF l_cc_line_groups(j).line_group_id=l_cc_group_ids(i) THEN
                    l_id_tab_temp(l_cc_count_rec):=l_cc_line_groups(j).entity_line_id;
                    l_cc_count_rec:=l_cc_count_rec+1;
                  END IF;
                END LOOP;

                IF l_debug_on THEN
                  wsh_debug_sv.log(l_module_name,'id_tab_temp count ',l_id_tab_temp.COUNT);
                END IF;

                WSH_DELIVERY_DETAILS_GRP.Autocreate_Deliveries(
                        p_api_version_number  =>  l_api_version,
                        p_init_msg_list       =>  FND_API.G_FALSE,
                        p_commit              =>  FND_API.G_FALSE,
                        p_caller              =>  p_action_prms.caller,
                        x_return_status       =>  l_return_status ,
                        x_msg_count           =>  l_msg_count,
                        x_msg_data            =>  l_msg_data,
                        p_line_rows           =>  l_id_tab_temp,
                        p_group_by_header_flag => p_action_prms.group_by_header_flag,
                        x_del_rows            =>  x_action_out_rec.delivery_id_tab);


                --set the intermediate ship to, ship method to null if group rec from constraint validation has these as 'N'
                l_cc_upd_dlvy_intmed_ship_to:='Y';
                l_cc_upd_dlvy_ship_method:='Y';
                IF l_cc_group_info.COUNT>0 THEN
                 FOR j in l_cc_group_info.FIRST..l_cc_group_info.LAST LOOP
                  IF l_cc_group_info(j).line_group_id=l_cc_group_ids(i) THEN
                  l_cc_upd_dlvy_intmed_ship_to:=l_cc_group_info(j).upd_dlvy_intmed_ship_to;
                  l_cc_upd_dlvy_ship_method:=l_cc_group_info(j).upd_dlvy_ship_method;
                  END IF;
                 END LOOP;
                END IF;

                IF l_debug_on THEN
                  wsh_debug_sv.log(l_module_name,'l_cc_upd_dlvy_intmed_ship_to ',l_cc_upd_dlvy_intmed_ship_to);
                  wsh_debug_sv.log(l_module_name,'l_cc_upd_dlvy_ship_method ',l_cc_upd_dlvy_ship_method);
                  wsh_debug_sv.log(l_module_name,'x_action_out_rec.delivery_id_tab.COUNT ',x_action_out_rec.delivery_id_tab.COUNT);
                  wsh_debug_sv.log(l_module_name,'l_return_status after calling autocreate_del in comp ',l_return_status);
                END IF;

                IF l_cc_upd_dlvy_intmed_ship_to='N' OR l_cc_upd_dlvy_ship_method='N' THEN
                 IF x_action_out_rec.delivery_id_tab.COUNT>0 THEN

                   FOR i in x_action_out_rec.delivery_id_tab.FIRST..x_action_out_rec.delivery_id_tab.LAST LOOP
                    FOR delcurtemp in c_delcur(x_action_out_rec.delivery_id_tab(i)) LOOP
                      l_cc_dlvy_intmed_ship_to:=delcurtemp.INTMED_SHIP_TO_LOCATION_ID;
                      l_cc_dlvy_ship_method:=delcurtemp.SHIP_METHOD_CODE;
                      IF l_cc_upd_dlvy_intmed_ship_to='N' and l_cc_dlvy_intmed_ship_to IS NOT NULL THEN
                        update wsh_new_deliveries set INTMED_SHIP_TO_LOCATION_ID=null
                        where delivery_id=x_action_out_rec.delivery_id_tab(i);
                      END IF;
                      --IF l_cc_upd_dlvy_ship_method='N' and l_cc_dlvy_ship_method IS NOT NULL THEN
                      IF l_cc_upd_dlvy_ship_method='N' THEN

                        -- OTM R12 : update delivery
                        -- no code changes are needed for the following update
                        -- since it reaches here only when FTE is installed

                        update wsh_new_deliveries
                        set SHIP_METHOD_CODE=null,
                                CARRIER_ID = null,
                                MODE_OF_TRANSPORT = null,
                                SERVICE_LEVEL = null
                        where delivery_id=x_action_out_rec.delivery_id_tab(i);
                      END IF;
                    END LOOP;
                   END LOOP;
                 END IF;
                END IF;
                  --set the intermediate ship to, ship method to null if group rec from constraint validation has these as 'N'
                IF l_cc_del_rows.COUNT=0 THEN
                  l_cc_del_rows:=x_action_out_rec.delivery_id_tab;
                ELSE
                  l_cc_count_del_rows:=l_cc_del_rows.COUNT;
                  IF x_action_out_rec.delivery_id_tab.COUNT>0 THEN
                    FOR i in x_action_out_rec.delivery_id_tab.FIRST..x_action_out_rec.delivery_id_tab.LAST LOOP
                      l_cc_del_rows(l_cc_count_del_rows+i):=x_action_out_rec.delivery_id_tab(i);
                    END LOOP;
                  END IF;
                END IF;

                IF (l_cc_return_status is not null AND l_cc_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                  l_return_status:=l_cc_return_status;
                ELSIF (l_cc_return_status is not null AND l_cc_return_status=WSH_UTIL_CORE.G_RET_STS_WARNING AND l_return_status=WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                  l_return_status:=l_cc_return_status;
                ELSE
                  l_cc_return_status:=l_return_status;
                END IF;

              END LOOP;
              l_return_status:=l_cc_return_status;
              x_action_out_rec.delivery_id_tab:=l_cc_del_rows;

              IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name,'x_action_out_rec.delivery_id_tab.COUNT after loop ',x_action_out_rec.delivery_id_tab.COUNT);
              END IF;

            ELSE

              WSH_DELIVERY_DETAILS_GRP.Autocreate_Deliveries(
                  p_api_version_number  =>  l_api_version,
                  p_init_msg_list       =>  FND_API.G_FALSE,
                  p_commit              =>  FND_API.G_FALSE,
                  p_caller              =>  p_action_prms.caller,
                  x_return_status       =>  l_return_status ,
                  x_msg_count           =>  l_msg_count,
                  x_msg_data            =>  l_msg_data,
                  p_line_rows           =>  l_id_tab,
                  p_group_by_header_flag => p_action_prms.group_by_header_flag,
                  x_del_rows            =>  x_action_out_rec.delivery_id_tab);

            END IF;
            --Compatibility Changes

            --
            IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name,'Return Status After Calling Autocreate_Deliveries',l_return_status);
            END IF;

            --
            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );

            -- deliveryMerge
            wsh_new_delivery_actions.Adjust_Planned_Flag(
               p_delivery_ids           => x_action_out_rec.delivery_id_tab,
               p_caller                 => 'WSH_DLMG',
               p_force_appending_limit  => 'N',
               p_call_lcss              => 'Y',
               x_return_status          => l_return_status);

            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );
        --
        ELSIF p_action_prms.action_code = 'AUTOCREATE-TRIP' THEN
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_GRP.AUTOCREATE_DEL_TRIP',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_DELIVERY_DETAILS_GRP.Autocreate_del_trip(
                p_api_version_number  =>  l_api_version,
                p_init_msg_list       => FND_API.G_FALSE,
                p_commit              => FND_API.G_FALSE,
                x_return_status       => l_return_status,
                x_msg_count           => l_msg_count,
                x_msg_data            => l_msg_data,
                p_line_rows           => l_id_tab,
                x_del_rows            => x_action_out_rec.delivery_id_tab,
                x_trip_rows           => x_action_out_rec.result_id_tab);

            --
            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );
        --
        ELSIF p_action_prms.action_code in ('IGNORE_PLAN', 'INCLUDE_PLAN') then
           Wsh_tp_release.change_ignoreplan_status
                   (p_entity        =>'DLVB',
                    p_in_ids        => l_id_tab,
                    p_action_code   => p_action_prms.action_code,
                    x_return_status => l_return_status);
           --
           IF l_debug_on THEN
               wsh_debug_sv.log(l_module_name,'Return Status After Calling change_ignoreplan_status ',l_return_status);
           END IF;
           --
           wsh_util_core.api_post_call(
              p_return_status    => l_return_status,
              x_num_warnings     => l_number_of_warnings,
              x_num_errors       => l_number_of_errors);
         --

        ELSIF p_action_prms.action_code = 'PICK-RELEASE' THEN
            --
        IF  l_debug_on THEN
           wsh_debug_sv.log(l_module_name, 'Id Tab Count', l_id_tab.count);
        END IF;

      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PICK_LIST.LAUNCH_PICK_RELEASE',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --

      wsh_pick_list.launch_pick_release(
                p_trip_ids           => l_dummy_ids,
                p_stop_ids           => l_dummy_ids,
                p_delivery_ids       => l_dummy_ids,
                p_detail_ids         => l_id_tab,
		p_batch_id           => p_action_prms.batch_id, -- bug# 6719369 (replenishment project)
                x_request_ids        => l_request_ids,
                x_return_status      => l_return_status);

            --
            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );
        --
        ELSIF p_action_prms.action_code = 'PICK-PACK-SHIP' THEN
            --
        IF  l_debug_on THEN
           wsh_debug_sv.log(l_module_name, 'Id Tab Count', l_id_tab.count);
        END IF;

      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PICK_LIST.LAUNCH_PICK_RELEASE',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_pick_list.launch_pick_release(
                p_trip_ids           => l_dummy_ids,
                p_stop_ids           => l_dummy_ids,
                p_delivery_ids       => l_dummy_ids,
                p_detail_ids         => l_id_tab,
                x_request_ids      => l_request_ids,
                x_return_status      => l_return_status,
                p_auto_pack_ship     => 'PS');

            --
            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );
        --
        ELSIF p_action_prms.action_code = 'PICK-SHIP' THEN
            --
        IF  l_debug_on THEN
           wsh_debug_sv.log(l_module_name, 'Id Tab Count', l_id_tab.count);
        END IF;

      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PICK_LIST.LAUNCH_PICK_RELEASE',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_pick_list.launch_pick_release(
                p_trip_ids           => l_dummy_ids,
                p_stop_ids           => l_dummy_ids,
                p_delivery_ids       => l_dummy_ids,
                p_detail_ids         => l_id_tab,
                x_request_ids      => l_request_ids,
                x_return_status      => l_return_status,
                p_auto_pack_ship     => 'SC');

            --
            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );
        --
        ELSIF p_action_prms.action_code = 'WT-VOL' THEN
            --

            -- OTM R12 : packing ECO
            -- This change was introduced to mark the G_RESET_WV flag
            -- before calling detail_weight_volume so the procedure will know
            -- to invoke update tms_interface_flag process.

            l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;
            IF l_gc3_is_installed IS NULL THEN
              l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
            END IF;

            IF l_gc3_is_installed = 'Y' THEN
              WSH_WV_UTILS.G_RESET_WV := 'Y'; -- set to Y to enable the update
            END IF;
            -- End of OTM R12 : packing ECO

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DETAIL_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_wv_utils.detail_weight_volume (
                p_detail_rows       => l_id_tab ,
                p_override_flag     => 'Y', -- Need to see if we can Use p_action_prms.wv_override_flag
                x_return_status     => l_return_status);

            --
            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );

            -- OTM R12 : packing ECO
            IF l_gc3_is_installed = 'Y' THEN
              WSH_WV_UTILS.G_RESET_WV := 'N'; -- after call, set it back to 'N'
            END IF;
            -- End of OTM R12 : packing ECO

        --
        ELSIF p_action_prms.action_code  = 'PACK' THEN
            --
            -- we just have to call the container group api here
            l_cont_flag :=  'N';
            l_delivery_flag := 'N';

            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'Container Name', p_action_prms.container_name);
                WSH_DEBUG_SV.log(l_module_name, 'Container Instance Id', p_action_prms.container_instance_id);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_GRP.CONTAINER_ACTIONS',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            wsh_container_grp.Container_Actions(
                p_api_version    => l_api_version,
                p_init_msg_list    => FND_API.G_FALSE,
                p_commit           => FND_API.G_FALSE,
                p_validation_level => wsh_container_grp.C_DELIVERY_DETAIL_CALL,
                x_return_status    => l_return_status,
                x_msg_count        => l_msg_count,
                x_msg_data         => l_msg_data,
                p_detail_tab       => l_id_tab,
                p_container_name   => p_action_prms.container_name,
                p_cont_instance_id => p_action_prms.container_instance_id,
                p_container_flag   => l_cont_flag,
                p_delivery_flag    => l_delivery_flag,
                p_action_code      => 'PACK',
                p_caller           => p_action_prms.caller);

            --
            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );
            --

            -- deliveryMerge add the call to Adjust_Planned_Flag with delivery detail ids

            FOR i in l_id_tab.FIRST .. l_id_tab.LAST LOOP
              OPEN get_delivery(l_id_tab(i));
              FETCH get_delivery into l_delivery_id;
              IF get_delivery%NOTFOUND THEN
                 CLOSE get_delivery;
                 goto end_of_detail_loop_1;
              END IF;
              CLOSE get_delivery;

              l_delivery_already_included := false;
              IF l_delivery_ids.count > 0 THEN
                 FOR j in l_delivery_ids.FIRST .. l_delivery_ids.LAST LOOP
                    IF l_delivery_ids(j) = l_delivery_id THEN
                       l_delivery_already_included := true;
                    END IF;
                 END LOOP;
              END IF;

              IF NOT l_delivery_already_included THEN
                 l_delivery_ids(l_delivery_ids.count+1) := l_delivery_id;
              END IF;
              <<end_of_detail_loop_1>>
              null;
            END LOOP;

            IF l_delivery_ids.count > 0 THEN
              WSH_NEW_DELIVERY_ACTIONS.Adjust_Planned_Flag(
                  p_delivery_ids          => l_delivery_ids,
                  p_caller                => 'WSH_DLMG',
                  p_force_appending_limit => 'N',
                  p_call_lcss             => 'Y',
                  x_return_status         => l_return_status);

               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'Adjust_Planned_Flag returns ',l_return_status);
               END IF;
            END IF;

            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );

        ELSIF p_action_prms.action_code = 'AUTO-PACK' THEN
            --
            -- we just have to call the container group api here
      l_entity_type := 'L';

            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_GRP.AUTO_PACK',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            wsh_container_grp.Auto_Pack (
                p_api_version    => l_api_version,
                p_init_msg_list    => FND_API.G_FALSE,
                p_commit           => FND_API.G_FALSE,
                p_validation_level => l_validation_level,
                x_return_status    => l_return_status,
                x_msg_count        => l_msg_count,
                x_msg_data         => l_msg_data,
                p_entity_tab     =>  l_id_tab,
                p_entity_type    =>  l_entity_type,
                p_group_id_tab     => l_group_id_tab,
                p_pack_cont_flag   => 'N' ,
                x_cont_inst_tab    => x_action_out_rec.result_id_tab);

            --
            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );

        --
        ELSIF p_action_prms.action_code = 'AUTO-PACK-MASTER' THEN
            --
      -- we just have to call the container group api here
      -- set the flag p_pack_cont_flagto Y to do auto-pack-master.
      l_entity_type := 'L';

            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_GRP.AUTO_PACK',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
           wsh_container_grp.Auto_Pack (
         p_api_version    => p_api_version_number,
               p_init_msg_list    => FND_API.G_FALSE,
               p_commit           => FND_API.G_FALSE,
               p_validation_level => l_validation_level,
               x_return_status    => l_return_status,
               x_msg_count        => l_msg_count,
               x_msg_data         => l_msg_data ,
               p_entity_tab       => l_id_tab,
               p_entity_type      => l_entity_type,
               p_group_id_tab     => l_group_id_tab,
               p_pack_cont_flag   => 'Y',
               x_cont_inst_tab    => x_action_out_rec.result_id_tab);

            -- Handle return status
            --
            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );
        --

        ELSIF p_action_prms.action_code = 'UNPACK'  THEN
            --
            -- we just have to call the container group api here
            l_cont_flag := 'Y'; -- need to set this to Y if action is Unpack

            -- deliveryMerge
            -- get the delivery associated with the delivery details
            FOR i in l_id_tab.FIRST .. l_id_tab.LAST LOOP
              OPEN get_delivery(l_id_tab(i));
              FETCH get_delivery into l_delivery_id;
              IF l_delivery_id is NULL OR get_delivery%NOTFOUND THEN
                 CLOSE get_delivery;
                 goto end_of_detail_loop_2;
              END IF;
              CLOSE get_delivery;

              l_delivery_already_included := false;

              IF l_delivery_ids.count > 0 THEN
                 FOR j in l_delivery_ids.FIRST .. l_delivery_ids.LAST LOOP
                   IF l_delivery_ids(j) = l_delivery_id THEN
                      l_delivery_already_included := true;
                   END IF;
                 END LOOP;
              END IF;

              IF NOT l_delivery_already_included THEN
                 l_delivery_ids(l_delivery_ids.count+1) := l_delivery_id;
              END IF;
              <<end_of_detail_loop_2>>
              null;
            END LOOP;


            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_GRP.CONTAINER_ACTIONS',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
           wsh_container_grp.Container_Actions(
               p_api_version    => l_api_version,
               p_init_msg_list    => FND_API.G_FALSE,
               p_commit           => FND_API.G_FALSE,
               p_validation_level => wsh_container_grp.C_DELIVERY_DETAIL_CALL,
               x_return_status    => l_return_status,
               x_msg_count        => l_msg_count,
               x_msg_data         => l_msg_data ,
               p_detail_tab       => l_id_tab,
               p_container_name   => p_action_prms.container_name,
               p_cont_instance_id => p_action_prms.container_instance_id,
               p_container_flag   => l_cont_flag,
               p_delivery_flag    => l_delivery_flag,
               p_action_code      => 'UNPACK',
               p_caller           => p_action_prms.caller);

            --
            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );

            -- deliveryMerge
            IF l_delivery_ids.count > 0 THEN
               WSH_NEW_DELIVERY_ACTIONS.Adjust_Planned_Flag(
                  p_delivery_ids          => l_delivery_ids,
                  p_caller                => 'WSH_DLMG',
                  p_force_appending_limit => 'N',
                  p_call_lcss             => 'Y',
                  x_return_status         => l_return_status);

               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'Adjust_Planned_Flag returns ',l_return_status);
               END IF;
            END IF;

            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data);

        --
        ELSIF p_action_prms.action_code = 'CYCLE-COUNT' THEN

            --
            -- Note: This action is only for one record. It is enforced by STF.
            --
            OPEN  cycle_count_cur(l_id_tab(l_id_tab.first));
            FETCH cycle_count_cur
            INTO l_released_status
               , l_requested_quantity
               , l_requested_quantity2
               , l_picked_quantity
               , l_picked_quantity2
               , l_shipped_quantity
               , l_shipped_quantity2
               , l_organization_id
               , l_inv_item_id
               ;

            IF cycle_count_cur%NOTFOUND THEN
                CLOSE cycle_count_cur;
                IF l_debug_on THEN
                   wsh_debug_sv.logmsg(l_module_name,'Detail not found');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            CLOSE cycle_count_cur;
            --
            --
            IF l_released_status = 'Y' AND NVL(l_picked_quantity, l_requested_quantity) > NVL(l_shipped_quantity, 0) THEN
               NULL;
            ELSE
                IF l_debug_on THEN
                   wsh_debug_sv.logmsg(l_module_name,'Incorrect Released status or incorrect quantities');
                END IF;
               fnd_message.set_name('WSH', 'WSH_CC_RSV_INSUFF');
            wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
               raise FND_API.G_EXC_ERROR;
            END IF;
            --
            --


-- HW OPM BUG#:2677054
-- HW OPMCONV - 1) No need to branch code
--            - 2) Relace call is_line_allocated with new WSH API
-- HW OPMCONV - New WSH API to check if split is allowed

               l_delivery_detail_id := l_id_tab(l_id_tab.first);

                IF (NOT WSH_DETAILS_VALIDATIONS.is_cycle_count_allowed
                      ( p_delivery_detail_id  => l_delivery_detail_id,
                        p_organization_id     => l_organization_id,
                        p_inventory_item_id   => l_inv_item_id,
                        p_released_status     => l_released_status,
                        p_picked_qty          => l_picked_quantity,
                        p_cycle_qty           => p_action_prms.quantity_to_split)
                        ) THEN
                  FND_MESSAGE.SET_NAME('WSH', 'WSH_NO_PARTIAL_CYCLE_COUNT');

                  IF p_action_prms.caller = 'WSH_FSTRX'  THEN
                     wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
                END IF;

-- HW end of 2677054


            IF p_action_prms.caller = 'WSH_FSTRX' AND p_action_prms.phase = 1 THEN
               -- return to Form so that the Cycle Count Dialog is shown to enter quantities
               --
               x_defaults.quantity_to_cc :=  nvl(l_picked_quantity, l_requested_quantity) - nvl(l_shipped_quantity,0);
               x_defaults.quantity2_to_cc := nvl(l_picked_quantity2, l_requested_quantity2) - nvl(l_shipped_quantity2,0);

               IF l_debug_on THEN
                   wsh_debug_sv.log(l_module_name, 'Default cc qty', x_defaults.quantity_to_cc);
               END IF;
               --
                   --Change made during Bugfix 4070732
                   --Raise end of api so that handling of return status, reset flags are done there
                   RAISE e_end_of_api;

            END IF;
            --
            -- Check if  cycle-count quantity is less than (picked or requested qty) - shipped qty
            -- Check if cycle_count quantity is greater than zero
            --Bug 2650617, nvl(l_shipped_quantity,0)
            IF (( p_action_prms.quantity_to_split > (NVL(l_picked_quantity, l_requested_quantity) - nvl(l_shipped_quantity,0)))
                  OR p_action_prms.quantity_to_split <= 0) THEN

                IF l_debug_on THEN
                   wsh_debug_sv.logmsg(l_module_name,'Incorrect quantities');
                END IF;
                FND_MESSAGE.SET_NAME('WSH', 'WSH_DET_SPLIT_EXCEED');
            wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
               raise FND_API.G_EXC_ERROR;

            END IF;

            -- Calculate the quantities to be passed to backorder API
            --
            l_req_qtys(1) :=  l_requested_quantity;
            l_overpick_qtys(1) :=    LEAST(p_action_prms.quantity_to_split,
                                          NVL(l_picked_quantity,  l_requested_quantity) - l_requested_quantity);

            l_overpick_qtys2(1) :=  LEAST(p_action_prms.quantity2_to_split,
                                         NVL(l_picked_quantity2,  l_requested_quantity2) - l_requested_quantity2);

            l_bo_qtys(1)  := p_action_prms.quantity_to_split - l_overpick_qtys(1);
            l_bo_qtys2(1) := p_action_prms.quantity2_to_split - l_overpick_qtys2(1);

          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name, 'Overpick Qty' , l_overpick_qtys(1));
            wsh_debug_sv.log(l_module_name, 'BO qty', l_bo_qtys(1));
          END IF;


            IF l_validation_level_tab(wsh_actions_levels.C_DECIMAL_QUANTITY_LVL)= 1 THEN
               --
               --
               OPEN  det_cur(l_id_tab(l_id_tab.first));
               FETCH det_cur
               INTO l_inv_item_id
                  , l_organization_id
                  , l_requested_quantity_uom
                  , l_line_direction
                  , l_released_status;
               CLOSE det_cur;

-- HW Harmonization project for OPM. Added p_organization_id
-- HW OPMCONV - Removed branching

         -- this needs to be called only for Discrete Org
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_DECIMAL_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;
                  --
                  WSH_DETAILS_VALIDATIONS.check_decimal_quantity(
                      p_item_id         => l_inv_item_id,
                      p_organization_id => l_organization_id,
                      p_input_quantity  => p_action_prms.quantity_to_split,
                      p_uom_code        => l_requested_quantity_uom,
                      x_output_quantity => l_output_quantity,
                      x_return_status   => l_return_status);

                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;
                  --

                IF l_return_status <> wsh_util_core.g_ret_sts_success THEN
                   raise FND_API.G_EXC_ERROR;
                END IF;

            --
            END IF;


            IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name, 'BO rows count', l_id_tab.count);
                wsh_debug_sv.log(l_module_name, 'BO qtys count', l_bo_qtys.count);
                wsh_debug_sv.log(l_module_name, 'Req qtys count', l_req_qtys.count);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIP_CONFIRM_ACTIONS2.BACKORDER',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_ship_confirm_actions2.Backorder(
                p_detail_ids     => l_id_tab,
                p_line_ids       => l_line_ids,         -- Consolidation of BO Delivery details project
                p_bo_qtys        => l_bo_qtys ,
                p_req_qtys       => l_req_qtys ,
                p_bo_qtys2       => l_bo_qtys2 ,
                p_overpick_qtys  => l_overpick_qtys ,
                p_overpick_qtys2 => l_overpick_qtys2 ,
                p_bo_mode        => 'CYCLE_COUNT' ,
                x_out_rows       => x_action_out_rec.result_id_tab ,
                x_cons_flags     => l_cons_flags,       -- Consolidation of BO Delivery details project
                x_return_status  => l_return_status);

            -- Handle return status
            -- set message if necessary
            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );

         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Backorder Result tab count', x_action_out_rec.result_id_tab.count);
         END IF;

	 --
	 -- Consolidation of BO Delivery details project
  	 --
  	 -- Debug Statements
  	 --
  	 IF l_debug_on THEN
       	   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters',WSH_DEBUG_SV.C_PROC_LEVEL);
  	 END IF;
  	 --
	 WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters(l_global_param_rec, l_return_status);

	 -- Handle return status
         -- set message if necessary
         wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );

	 -- x_action_out_rec.result_id_tab contains the original delivery_detail_id, for complete cycle-count.
	 -- x_action_out_rec.result_id_tab contains the newly created delivery_detail_id, for
	 -- partial cycle-count(split happens in this case).
	 --
	 -- Pass back the original delivery_detail_id, if it was merged into some other delivery detail
    	 IF (l_global_param_rec.consolidate_bo_lines = 'Y' AND l_cons_flags(1) = 'Y') THEN
            x_action_out_rec.result_id_tab(1) := l_id_tab(1);
  	 END IF;
	 --

        --
        ELSIF p_action_prms.action_code IN ('PACKING-WORKBENCH',  'PICK-RELEASE-UI', 'RESOLVE-EXCEPTIONS-UI', 'FREIGHT-COSTS-UI') AND p_action_prms.caller = 'WSH_FSTRX' THEN
            -- do nothing. return
            -- These actions are supported only for UI(STF).
            -- Not applicable for other callers

            --Change made during Bugfix 4070732
            --Raise end of api so that handling of return status, reset flags are done there
            RAISE e_end_of_api;

        --
	--Bug 3326794: Added code for the DELETE action.
	ELSIF  p_action_prms.action_code = 'DELETE' THEN
	--{
            IF l_debug_on THEN
	    --{
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Delete',WSH_DEBUG_SV.C_PROC_LEVEL);
            --}
	    END IF;
            --
            WSH_UTIL_CORE.Delete(
                   p_type          => 'DLVB',
                   p_rows          => l_id_tab,
                   x_return_status => l_return_status);
            --
            IF l_debug_on THEN
	    --{
               wsh_debug_sv.log(l_module_name,'Return Status After Calling Delete',l_return_status);
            --}
	    END IF;
            --
            wsh_util_core.api_post_call(
             p_return_status    => l_return_status,
             x_num_warnings     => l_number_of_warnings,
             x_num_errors       => l_number_of_errors);

        --}  -- End  Bug 3326794

        ELSE
            --
           FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_ACTION_CODE');
           FND_MESSAGE.SET_TOKEN('ACT_CODE',p_action_prms.action_code );
            wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
           IF l_debug_on THEN
              wsh_debug_sv.logmsg(l_module_name,'WSH_INVALID_ACTION_CODE');
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        --
        END IF;
        --
        --
        --Call to DCP
        --If profile is turned on.
     BEGIN
     --{
       --
       IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name, 'l_check_dcp', l_check_dcp);
          wsh_debug_sv.log(l_module_name, 'g_call_dcp_check', WSH_DCP_PVT.G_CALL_DCP_CHECK);
       END IF;
       --
       IF NVL(l_check_dcp, -99) IN (1,2)
          AND NVL(WSH_DCP_PVT.G_CALL_DCP_CHECK, 'Y') = 'Y'
       THEN
       --{
        IF p_action_prms.action_code IN ('SPLIT-LINE', 'CYCLE-COUNT', 'PACK', 'AUTO-PACK')
        THEN
        --{
           IF l_debug_on THEN
              WSH_DEBUG_SV.LOGMSG(L_MODULE_NAME, 'CALLING DCP ');
           END IF;

           wsh_dcp_pvt.check_detail(
                     p_action_code => p_action_prms.action_code,
                     p_dtl_table => p_rec_attr_tab);
         --}
         END IF;
       --}
       END IF;
      EXCEPTION
      WHEN wsh_dcp_pvt.data_inconsistency_exception THEN
        if NOT l_debug_on OR l_debug_on is null then
           l_debug_on := wsh_debug_sv.is_debug_enabled;
        end if;
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'data_inconsistency_exception');
        END IF;
        ROLLBACK TO DELIVERY_DETAIL_ACTION_GRP;
        GOTO api_start;
      WHEN OTHERS THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'When Others');
        END IF;
        null;
      --}
      END;
      --
        RAISE e_end_of_api;   -- J-IB-NPARIKH


  EXCEPTION
        WHEN e_end_of_api THEN

            IF del_cur%ISOPEN THEN
              CLOSE del_cur;
            END IF;

            --
            -- K LPN CONV. rv
            --
            IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
            THEN
            --{
                IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;

                WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                  (
                    p_in_rec             => l_lpn_in_sync_comm_rec,
                    x_return_status      => l_return_status,
                    x_out_rec            => l_lpn_out_sync_comm_rec
                  );
                --
                --
                IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
                END IF;
                --
                --
                WSH_UTIL_CORE.API_POST_CALL
                  (
                    p_return_status    => l_return_status,
                    x_num_warnings     => l_number_of_warnings,
                    x_num_errors       => l_number_of_errors,
                    p_raise_error_flag => false
                  );
            --}
            END IF;
            --
            -- K LPN CONV. rv
            --

            IF l_number_of_warnings > 0 THEN
               IF l_debug_on THEN
                  wsh_debug_sv.log (l_module_name,'Number of warnings', l_number_of_warnings);
               END IF;
               -- RAISE WSH_UTIL_CORE.G_EXC_WARNING;
                l1_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
            ELSE
                l1_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
            END IF;
            --
           -- Standard check of p_commit.
           IF FND_API.To_Boolean( p_commit ) THEN
              IF(l_debug_on) THEN
                 wsh_debug_sv.logmsg(l_module_name, 'Commit Work');
              END IF;
               --
               -- Start code for Bugfix 4070732
               --
              IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;

                 l_reset_flags := FALSE;
                 WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => l_reset_flags,
						       x_return_status => l_return_status);

                 IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                 END IF;

                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                    l1_return_status := l_return_status;
                 END IF;

              END IF;
             --
             -- End of code for Bugfix 4070732
             --

              COMMIT WORK;
           END IF;

           --bug 4070732
           --End of the API handling of calls to process_stops_for_load_tender
          IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
          --{
             IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
             --{

               IF FND_API.To_Boolean( p_commit ) THEN
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;

                 WSH_UTIL_CORE.reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);

               ELSE
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;

                 WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);

               END IF;

                 IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                 END IF;

                 IF l1_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                      IF l1_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
                        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                          l1_return_status := l_return_status;
			END IF;
		      ELSE
                         l1_return_status := l_return_status;
		      END IF;
                   END IF;
                 END IF;
               --}
              END IF;
           --}
          END IF;

          x_return_status := l1_return_status;
    --bug 4070732

            FND_MSG_PUB.Count_And_Get
               (
                p_count  => x_msg_count,
                p_data  =>  x_msg_data,
                p_encoded => FND_API.G_FALSE
               );


            IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
        WHEN FND_API.G_EXC_ERROR THEN
                -- ROLLBACK TO DELIVERY_DETAIL_ACTION_GRP;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                --
                IF del_cur%ISOPEN THEN
                  CLOSE del_cur;
                END IF;
                -- K LPN CONV. rv
                --
                IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
                THEN
                --{
                    IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;

                    WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                      (
                        p_in_rec             => l_lpn_in_sync_comm_rec,
                        x_return_status      => l_return_status,
                        x_out_rec            => l_lpn_out_sync_comm_rec
                      );
                    --
                    --
                    IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
                    END IF;
                    --
                    --
                    IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                      x_return_status := l_return_status;
                    END IF;
                    --
                --}
                END IF;
                --
                -- K LPN CONV. rv
                --
             --
             -- Start code for Bugfix 4070732
             --
             IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name)
             THEN
             --{
                IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
                --{
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;

                  WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                     x_return_status => l_return_status);

                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                  END IF;

                  IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                     x_return_status := l_return_status;
                  END IF;
                --}
                END IF;
              --}
             END IF;
             --
             -- End of Code Bugfix 4070732
             --
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
                -- ROLLBACK TO DELIVERY_DETAIL_ACTION_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF del_cur%ISOPEN THEN
                  CLOSE del_cur;
                END IF;

                --
                -- K LPN CONV. rv
                --
                IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
                THEN
                --{
                    IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;

                    WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                      (
                        p_in_rec             => l_lpn_in_sync_comm_rec,
                        x_return_status      => l_return_status,
                        x_out_rec            => l_lpn_out_sync_comm_rec
                      );
                    --
                    --
                    IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
                    END IF;
                    --
                    --
                --}
                END IF;
                --
                -- K LPN CONV. rv
                --
             --
             -- Start code for Bugfix 4070732
             --
             IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name)
             THEN
             --{
                IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
                --{
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;

                  WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                     x_return_status => l_return_status);

                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                  END IF;
                --}
                END IF;
              --}
             END IF;
             --
             -- End of Code Bugfix 4070732
             --
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );


                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
                  END IF;
                  --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
          IF del_cur%ISOPEN THEN
            CLOSE del_cur;
          END IF;

          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR) and x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
      --
      -- Start code for Bugfix 4070732
      --
       IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name)
       THEN
       --{
          IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API)
          THEN
          --{
             IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;

             WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => TRUE,
                                                         x_return_status => l_return_status);

             IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
             END IF;

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                x_return_status := l_return_status;
             END IF;
          --}
          END IF;
      ---}
      END IF;
     --
     -- End of Code Bugfix 4070732
     --
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
        WHEN OTHERS THEN
                IF del_cur%ISOPEN THEN
                  CLOSE del_cur;
                END IF;

                -- ROLLBACK TO DELIVERY_DETAIL_ACTION_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF cycle_count_cur%ISOPEN THEN
                   Close cycle_count_cur;
                END IF;
              wsh_util_core.add_message(x_return_status, l_module_name);
               WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_GRP.Delivery_Detail_Action');
                --
                -- K LPN CONV. rv
                --
                IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
                THEN
                --{
                    IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;

                    WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                      (
                        p_in_rec             => l_lpn_in_sync_comm_rec,
                        x_return_status      => l_return_status,
                        x_out_rec            => l_lpn_out_sync_comm_rec
                      );
                    --
                    --
                    IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
                    END IF;
                    --
                    --
                --}
                END IF;
                --
                -- K LPN CONV. rv
                --
             --
             -- Start code for Bugfix 4070732
             --
             IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name)
             THEN
             --{
                IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
                --{
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;

                  WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                     x_return_status => l_return_status);

                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                  END IF;
                --}
                END IF;
              --}
             END IF;
             --
             -- End of Code Bugfix 4070732
             --
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
    END Delivery_Detail_Action;


    -- ---------------------------------------------------------------------
    -- Procedure: Create_Update_Delivery_Detail
    --
    -- Parameters:        --
    -- Description:  This procedure is the new API for wrapping the logic of CREATE/UPDATE of delivery details
    -- Created:   Harmonization Project. Patchset I
    -- -----------------------------------------------------------------------

    PROCEDURE Create_Update_Delivery_Detail
    (
       -- Standard Parameters
       p_api_version_number  IN  NUMBER,
       p_init_msg_list           IN    VARCHAR2,
       p_commit                  IN    VARCHAR2,
       x_return_status           OUT NOCOPY  VARCHAR2,
       x_msg_count               OUT NOCOPY  NUMBER,
       x_msg_data                OUT NOCOPY  VARCHAR2,

       -- Procedure Specific Parameters
       p_detail_info_tab         IN WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type,
       p_IN_rec                  IN   WSH_GLBL_VAR_STRCT_GRP.detailInRecType,
       x_OUT_rec                 OUT NOCOPY   WSH_GLBL_VAR_STRCT_GRP.detailOutRecType
    ) IS

        l_api_name              CONSTANT VARCHAR2(30)   := 'Create_Update_Delivery_Detail';
        l_api_version           CONSTANT NUMBER         := 1.0;
        --
  --
  l_return_status             VARCHAR2(32767);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(32767);
  l_program_name              VARCHAR2(32767);
        --
  l_number_of_errors    NUMBER := 0;
  l_number_of_warnings  NUMBER := 0;
  --
        l_loop_num_error      NUMBER := 0;
        l_loop_num_warn       NUMBER := 0;
        --
        l_counter             NUMBER := 0;
        l_index               NUMBER;

        l_detail_info_tab     WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type;
        l_valid_index_tab     wsh_util_core.id_tab_type;
        l_delivery_id         NUMBER;
        l_delivery_detail_rec WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type;
        l_validation_tab      wsh_util_core.id_tab_type;
  --
        l_details_marked        WSH_UTIL_CORE.Id_Tab_Type;
        l_dummy_ser_range_tab   WSH_GLBL_VAR_STRCT_GRP.ddSerialRangeTabType;
        mark_reprice_error      EXCEPTION;

        --
        CURSOR det_to_del_cur(p_detail_id NUMBER) IS
           SELECT wda.delivery_id
           FROM wsh_delivery_assignments_v wda
           WHERE wda.delivery_detail_id = p_detail_id;

-- anxsharm for Load Tender
        l_detail_tender_tab wsh_util_core.id_tab_type;
        l_trip_id_tab wsh_util_core.id_tab_type;

        --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_DELIVERY_DETAIL';
  --

  BEGIN

        -- Standard Start of API savepoint
        --
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
        --
        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;
        --
        SAVEPOINT   CREATE_UPDATE_DEL_DETAIL_GRP;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            --
            WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
            WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
            WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
            WSH_DEBUG_SV.log(l_module_name, 'Caller', p_In_rec.caller);
            WSH_DEBUG_SV.log(l_module_name, 'Action Code', p_In_rec.action_code);
            WSH_DEBUG_SV.log(l_module_name,'Input Table count', p_detail_info_tab.count);
        END IF;
        --

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status       := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        l_number_of_errors    := 0;
        l_number_of_warnings := 0;

      /* Call the New Overloaded API */

        create_update_delivery_detail(
            p_api_version_number      =>  p_api_version_number,
            p_init_msg_list           =>  FND_API.G_FALSE,
            p_commit                  =>  FND_API.G_FALSE,
            x_return_status           =>  l_return_status,
            x_msg_count               =>  l_msg_count,
            x_msg_data                =>  l_msg_data,
            p_detail_info_tab         =>  p_detail_info_tab,
            p_IN_rec                  =>  p_in_rec,
            x_OUT_rec                 =>  x_out_rec,
            p_serial_range_tab        =>  l_dummy_ser_range_tab
            );

              wsh_util_core.api_post_call(
                            p_return_status  =>l_return_status,
                            x_num_warnings     =>l_number_of_warnings,
                            x_num_errors       =>l_number_of_errors);

    IF l_number_of_warnings > 0 THEN
       IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Number of warnings', l_number_of_warnings);
       END IF;
       RAISE WSH_UTIL_CORE.G_EXC_WARNING;
    END IF;


       -- Standard check of p_commit.
       IF FND_API.To_Boolean( p_commit ) THEN
          IF(l_debug_on) THEN
             wsh_debug_sv.logmsg(l_module_name, 'Commit Work');
          END IF;
          COMMIT WORK;
       END IF;

       FND_MSG_PUB.Count_And_Get
         (
          p_count  => x_msg_count,
          p_data  =>  x_msg_data,
          p_encoded => FND_API.G_FALSE
         );

      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
--
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO CREATE_UPDATE_DEL_DETAIL_GRP;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
                  END IF;
                  --
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO CREATE_UPDATE_DEL_DETAIL_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
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
        WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
             x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
             FND_MSG_PUB.Count_And_Get
              (
                p_count  => x_msg_count,
                p_data  =>  x_msg_data,
                p_encoded => FND_API.G_FALSE
              );
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
       END IF;
--
        WHEN mark_reprice_error then
                FND_MESSAGE.Set_Name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
                wsh_util_core.add_message(x_return_status, l_module_name);
                x_return_status := l_return_status;
                 FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );
    --

                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'MARK_REPRICE_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:MARK_REPRICE_ERROR');
                END IF;
                --
        WHEN OTHERS THEN
                ROLLBACK TO CREATE_UPDATE_DEL_DETAIL_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
               wsh_util_core.add_message(x_return_status, l_module_name);
               WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_GRP.Create_Update_Delivery_Detail');
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
  END Create_Update_Delivery_Detail;


/* ----------------------------------------------------
  PROCEDURE  Create_containers
  ----------------------------------------------------*/
    -- lpn conv
    PROCEDURE  Create_containers(
                p_detail_info_tab     IN WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type ,
                p_detail_IN_rec       IN  WSH_GLBL_VAR_STRCT_GRP.detailInRecType,
                x_container_ids   OUT NOCOPY  WSH_UTIL_CORE.ID_TAB_TYPE,
                x_return_status       OUT NOCOPY  varchar2
                )
      IS
      l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME ||
                                              '.' || 'CREATE_CONTAINERS';
      l_generate boolean := FALSE;
      l_create_for_wms boolean := FALSE;
      l_create_one_record boolean := FALSE;
      l_lpn_out_tab           WMS_Data_Type_Definitions_pub.LPNTableType;
      l_gen_lpn_rec           WMS_Data_Type_Definitions_pub.AutoCreateLPNRecordType;
      l_verify_org_level     NUMBER;
      l_verify_cont_item     NUMBER;
      l_organization_id NUMBER    := NULL;
      l_organization_code VARCHAR2(240) := NULL;
      l_cont_item_id    NUMBER    := NULL;
      l_cont_item_seg   FND_FLEX_EXT.SegmentArray;
      l_cont_item_name  VARCHAR2(30)  := NULL;
      l_wms_return_status       VARCHAR2(10);
      l_wms_msg_count           NUMBER;
      l_wms_msg_data            VARCHAR2(2000);
      l_wms_organization_id     NUMBER;
      l_total_length            NUMBER;
      l_name_prefix             VARCHAR2(30);
      l_name_suffix             VARCHAR2(30);
      l_base_number             NUMBER;
      l_base_number_dummy       NUMBER;
      l_container_names         WSH_GLBL_VAR_STRCT_GRP.v50_Tbl_Type;
      l_lpn_ids                 wsh_util_core.id_tab_type;
      i                         NUMBER;
      j                         NUMBER;
      l_orig_value              varchar2(2);
      l_update_container_orig   VARCHAR2(2) := WSH_WMS_LPN_GRP.g_update_to_container;
-- bmso
      l_lpn_table             WMS_Data_Type_Definitions_pub.LPNTableType;
      l_container_info_rec        WSH_GLBL_VAR_STRCT_GRP.ContInfoRectype;
      l_container_rec       WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type;
      l_cont_dummy_tab  WSH_UTIL_CORE.id_tab_type;
      l_del_assg_rec        WSH_DELIVERY_DETAILS_PKG.Delivery_Assignments_Rec_Type;
      l_assignment_dummy_tab  WSH_UTIL_CORE.id_tab_type;
      l_wms_enabled             BOOLEAN;
      l_return_status           VARCHAR2(2);
      l_number_of_warnings      NUMBER := 0;
      l_number_of_errors        NUMBER := 0;
      l_suffix_length           NUMBER;
      l_additional_cont_attr    wsh_glbl_var_strct_grp.LPNRecordType;

      l_new_session BOOLEAN := TRUE;

      CURSOR c_get_default_parameters (v_organization_id NUMBER) IS
      SELECT LPN_STARTING_NUMBER
      FROM mtl_parameters
      WHERE ORGANIZATION_ID = v_organization_id;

      CURSOR c_get_wms_next_seq IS
      SELECT  WMS_LICENSE_PLATE_NUMBERS_S2.nextval
      FROM DUAL;
      CURSOR c_get_wms_curr_seq IS
      SELECT  WMS_LICENSE_PLATE_NUMBERS_S2.currval
      FROM DUAL;

      l_lpn_starting_num NUMBER;
      l_wms_sequence  NUMBER;

      e_lpn_count_invalid           EXCEPTION;
      e_NO_INV_ITEM           EXCEPTION;



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
            WSH_DEBUG_SV.log(l_module_name, 'p_detail_info_tab.count',
                                                   p_detail_info_tab.count);
        END IF;

        SAVEPOINT   s_create_containers_DDGPB;

        l_orig_value := WSH_WMS_LPN_GRP.g_call_group_api;

        IF p_detail_info_tab.COUNT > 0 THEN
           l_create_for_wms := TRUE;
        ELSIF p_detail_IN_rec.quantity = 1
          AND ( p_detail_IN_rec.container_name IS NOT NULL) THEN
           l_create_one_record := TRUE;
        ELSIF NVL(p_detail_IN_rec.quantity,0) <=0 THEN
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,
                               'Invalid quantity', p_detail_IN_rec.quantity);
           END IF;
           raise fnd_api.g_exc_error;
        ELSE
           l_generate := TRUE;
        END IF;

        IF l_generate OR l_create_one_record THEN --{

           -- This portion creates or generates containers for non-wms callers

           --validate the container item, and org bmso

           l_verify_org_level := WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_CONTAINER_ORG_LVL);

           l_verify_cont_item := WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_CONT_ITEM_LVL);

             l_organization_id := p_detail_IN_rec.organization_id;
             l_organization_code := p_detail_IN_rec.organization_code;
             --
             IF l_verify_org_level = 1 THEN --{
                --
                WSH_UTIL_VALIDATE.Validate_Org (l_organization_id,
                           l_organization_code,
                           l_return_status);
                IF l_return_status NOT IN ( wsh_util_core.g_ret_sts_success ,WSH_UTIL_CORE.G_RET_STS_WARNING)
                THEN
                   fnd_message.set_name('WSH', 'WSH_OI_INVALID_ORG');
                   wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
                END IF;

                wsh_util_core.api_post_call(
                    p_return_status => l_return_status,
                    x_num_warnings  => l_number_of_warnings,
                    x_num_errors    => l_number_of_errors
                );

             END IF; --}
             --
             -- validate item
             l_cont_item_id := p_detail_IN_rec.container_item_id;
             l_cont_item_seg := p_detail_IN_rec.container_item_seg;
             l_cont_item_name := p_detail_IN_rec.container_item_name;
             --
             IF l_verify_cont_item = 1 THEN --{
                -- wms change:  Validate Item check is to be skipped if the
                -- Org. is WMS enabled

                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_INSTALL.CHECK_INSTALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;

                l_wms_enabled := WMS_INSTALL.check_install(
                                    l_wms_return_status,
                                    l_wms_msg_count,
                                    l_wms_msg_data,
                                    l_organization_id);

                wsh_util_core.api_post_call(
                             p_return_status => l_wms_return_status,
                             x_num_warnings  => l_number_of_warnings,
                             x_num_errors    => l_number_of_errors
                );

                IF l_debug_on THEN
                   wsh_debug_sv.log(l_module_name, 'wms enabled',
                                                            l_wms_enabled);
                END IF;
                IF (l_wms_enabled = FALSE) THEN --{
                   IF (l_cont_item_id IS NULL
                     AND l_cont_item_name IS NULL
                     AND l_cont_item_seg.count = 0) then --{
                      fnd_message.set_name('WSH', 'WSH_CONT_INVALID_ITEM');
                      WSH_UTIL_CORE.ADD_MESSAGE(wsh_util_core.g_ret_sts_error, l_module_name);
                      RAISE e_NO_INV_ITEM;
                   ELSE --}{
                      --
                      WSH_UTIL_VALIDATE.Validate_Item
                         (p_inventory_item_id => l_cont_item_id,
                          p_inventory_item   => l_cont_item_name,
                          p_organization_id   => l_organization_id,
                          p_seg_array      => l_cont_item_seg,
                          x_return_status     => l_return_status,
                          p_item_type      => 'CONT_ITEM');
                      IF l_return_status NOT IN ( WSH_UTIL_CORE.G_RET_STS_SUCCESS, WSH_UTIL_CORE.G_RET_STS_WARNING)
                      THEN
                         fnd_message.set_name('WSH', 'WSH_CONT_INVALID_ITEM');
                         WSH_UTIL_CORE.ADD_MESSAGE(wsh_util_core.g_ret_sts_error, l_module_name);
                         wsh_util_core.api_post_call(
                             p_return_status => l_return_status,
                             x_num_warnings  => l_number_of_warnings,
                             x_num_errors    => l_number_of_errors
                         );
                      END IF;
                  END IF; --}
               ELSE --}{
                  fnd_message.set_name('WSH', 'WSH_INCORRECT_ORG');
                  fnd_message.set_token('ORG_CODE', l_organization_code);
                  wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
                  RAISE FND_API.G_EXC_ERROR;
               END IF;  -- wms_enabled }
            END IF; -- verify item}
            --

           IF l_generate  THEN --{
             IF c_wms_code_present = 'Y' THEN --{

             -- calculating the parameter needed to generate container name

             IF (p_detail_IN_rec.name_suffix IS NOT NULL)
               AND (NVL(p_detail_IN_rec.ucc_128_suffix_flag,2) = 1)
             THEN
                IF l_debug_on THEN
                   wsh_debug_sv.log(l_module_name, 'Error ucc_128_suffix_flag is set to 1 and name_suffix is set to ',p_detail_IN_rec.name_suffix);
                END IF;
                FND_MESSAGE.SET_NAME('WSH', 'WSH_UCC128_ERROR'); --bmso new
                wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
                RAISE FND_API.G_EXC_ERROR;
             END IF;

             IF p_detail_IN_rec.ucc_128_suffix_flag = 1 THEN
                l_suffix_length := 1;
                -- Also the prefix should be integer
                BEGIN
                   IF TRUNC(NVL(p_detail_IN_rec.name_prefix,0))
                        <> NVL(p_detail_IN_rec.name_prefix,0)
                      OR TRUNC(NVL(p_detail_IN_rec.name_prefix,0)) < 0
                   THEN
                      FND_MESSAGE.SET_NAME('WSH', 'WSH_UCC128_PREFIX_ERR'); --bmso new
                      wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);

                   END IF;
                EXCEPTION
                   WHEN OTHERS THEN
                      FND_MESSAGE.SET_NAME('WSH', 'WSH_UCC128_PREFIX_ERR'); --bmso new
                      wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
                END;
             ELSE
                l_suffix_length := NVL(LENGTH(p_detail_IN_rec.name_suffix),0);
             END IF;

             OPEN c_get_default_parameters(l_organization_id);
             FETCH c_get_default_parameters INTO l_lpn_starting_num;
             CLOSE c_get_default_parameters;

             l_base_number_dummy := NVL(p_detail_IN_rec.base_number,
                                                   l_lpn_starting_num);
             l_new_session := TRUE;
             IF l_base_number_dummy IS NULL THEN --{
                BEGIN
                   OPEN c_get_wms_curr_seq ;
                   fetch c_get_wms_curr_seq INTO l_wms_sequence;
                   CLOSE c_get_wms_curr_seq;
                   l_base_number_dummy := l_wms_sequence + 1;
                EXCEPTION
                   WHEN OTHERS THEN
                      l_new_session := FALSE;
                      OPEN c_get_wms_next_seq ;
                      fetch c_get_wms_next_seq INTO l_wms_sequence;
                      CLOSE c_get_wms_next_seq;
                      l_base_number_dummy := l_wms_sequence;
                END ;
             END IF; --}

             IF l_new_session THEN
                l_base_number_dummy := l_base_number_dummy + p_detail_IN_rec.quantity - 1;
             ELSE
                l_base_number_dummy := l_base_number_dummy + p_detail_IN_rec.quantity ;
             END IF;


             IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name, 'l_lpn_starting_num',l_lpn_starting_num);
                wsh_debug_sv.log(l_module_name, 'l_wms_sequence',l_wms_sequence);
                wsh_debug_sv.log(l_module_name, 'l_base_number_dummy',l_base_number_dummy);
             END IF;

             IF p_detail_IN_rec.num_digits IS NOT NULL THEN
                l_total_length := NVL(length(p_detail_IN_rec.name_prefix),0)
                    + l_suffix_length
                    + GREATEST(p_detail_IN_rec.num_digits,NVL(LENGTH(l_base_number_dummy),0));
             END IF;


             l_total_length := NVL(l_total_length,FND_API.G_MISS_NUM);
             l_name_prefix := NVL(p_detail_IN_rec.name_prefix,FND_API.G_MISS_CHAR);
             l_name_suffix := NVL(p_detail_IN_rec.name_suffix,FND_API.G_MISS_CHAR);

             l_gen_lpn_rec.container_item_id := l_cont_item_id;
             l_gen_lpn_rec.organization_id :=  l_organization_id;
             l_gen_lpn_rec.lpn_prefix:=  l_name_prefix;
             l_gen_lpn_rec.lpn_suffix := l_name_suffix;
             l_gen_lpn_rec.starting_num :=  p_detail_IN_rec.base_number;
             IF p_detail_IN_rec.base_number IS NOT NULL THEN --{
                IF p_detail_IN_rec.base_number <> FND_API.G_MISS_NUM THEN
                   IF l_lpn_starting_num = p_detail_IN_rec.base_number THEN
                      l_gen_lpn_rec.starting_num := NULL;
                   END IF;
                END IF;
             END IF ; --}
             l_gen_lpn_rec.total_lpn_length :=  l_total_length;
             l_gen_lpn_rec.quantity:= p_detail_IN_rec.quantity;
             --l_gen_lpn_rec.caller :=  p_detail_IN_rec.caller;
             l_gen_lpn_rec.ucc_128_suffix_flag :=  p_detail_IN_rec.ucc_128_suffix_flag;

             WSH_WMS_LPN_GRP.g_call_group_api := 'N';
             WSH_WMS_LPN_GRP.g_update_to_container := 'N';

             IF l_debug_on THEN
                wsh_debug_sv.logmsg(l_module_name, 'Calling wms_container_grp.Auto_Create_LPNs');
             END IF;
             wms_container_grp.Auto_Create_LPNs (
                p_api_version         => 1.0
               , p_init_msg_list      => fnd_api.g_false
               , p_commit             => fnd_api.g_false
               , x_return_status      => l_return_status
               , x_msg_count          => l_wms_msg_count
               , x_msg_data           => l_wms_msg_data
               , p_caller               => 'WSH_GENERATE'
               , p_gen_lpn_rec        => l_gen_lpn_rec
               , p_lpn_table          => l_lpn_out_tab
             );

             WSH_WMS_LPN_GRP.g_call_group_api := l_orig_value;
             WSH_WMS_LPN_GRP.g_update_to_container := l_update_container_orig;

             wsh_util_core.api_post_call(
                 p_return_status => l_return_status,
                 x_num_warnings  => l_number_of_warnings,
                 x_num_errors    => l_number_of_errors,
                 p_msg_data      => l_wms_msg_data
             );
             --bms get the names
             i := l_lpn_out_tab.FIRST;
             --if i null then error out bmso
             j := 1;
             IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name, 'l_lpn_out_tab.count',l_lpn_out_tab.count);
             END IF;
             WHILE i IS NOT NULL LOOP --{
                l_container_info_rec.lpn_ids(j) := l_lpn_out_tab(i).lpn_id;
                l_container_info_rec.container_names(j) :=
                                       l_lpn_out_tab(i).license_plate_number;
                IF l_debug_on THEN
                   wsh_debug_sv.log(l_module_name, 'name',
                                      l_container_info_rec.container_names(j));
                   wsh_debug_sv.log(l_module_name, 'lpn_id',
                                              l_container_info_rec.lpn_ids(j));
                END IF;

                IF l_container_info_rec.lpn_ids(j) IS NULL THEN
                   FND_MESSAGE.SET_NAME('WSH', 'WSH_REQUIRED_FIELD_NULL');
                   FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'LPN_ID');
                   wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
                   RAISE FND_API.G_EXC_ERROR;

                ELSIF l_container_info_rec.container_names(j) IS NULL THEN
                   FND_MESSAGE.SET_NAME('WSH', 'WSH_REQUIRED_FIELD_NULL');
                   FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'CONTAINER_NAME');
                   wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
                   RAISE FND_API.G_EXC_ERROR;

                END IF;

                i := l_lpn_out_tab.NEXT(i);
                j := j + 1;

             END LOOP; --}

             l_container_rec.weight_uom_code :=
                                     l_lpn_out_tab(1).GROSS_WEIGHT_UOM_CODE;
             l_container_rec.gross_weight :=
                                       l_lpn_out_tab(1).GROSS_WEIGHT;
             l_additional_cont_attr.tare_weight :=
                                       l_lpn_out_tab(1).TARE_WEIGHT;
             l_additional_cont_attr.tare_weight_uom_code :=
                                       l_lpn_out_tab(1).TARE_WEIGHT_UOM_CODE;
             l_container_rec.volume_uom_code :=
                       l_lpn_out_tab(1).CONTAINER_VOLUME_UOM;
             l_container_rec.volume := l_lpn_out_tab(1).CONTAINER_VOLUME;
             l_additional_cont_attr.filled_volume_uom_code :=
                       l_lpn_out_tab(1).CONTENT_VOLUME_UOM_CODE;
             l_container_rec.filled_volume := l_lpn_out_tab(1).CONTENT_VOLUME;
             l_container_rec.locator_id := l_lpn_out_tab(1).locator_id;
             l_container_rec.subinventory := l_lpn_out_tab(1).SUBINVENTORY_CODE;
             l_container_rec.inventory_item_id := l_cont_item_id;
             l_container_rec.organization_id := l_organization_id;

             -- uncomment when the column is there
             --l_container_rec.volume := l_lpn_out_tab(1).CONTAINER_VOLUME;
             ELSE --}{
             /* bmso comment out this protion when WMS code is there */
             wsh_container_actions.Create_Multiple_Cont_name (
                  p_cont_name     => p_detail_IN_rec.container_name,
                  p_cont_name_pre => p_detail_IN_rec.name_prefix,
                  p_cont_name_suf => p_detail_IN_rec.name_suffix,
                  p_cont_name_num => p_detail_IN_rec.base_number,
                  p_cont_name_dig => p_detail_IN_rec.num_digits,
                  p_quantity      => p_detail_IN_rec.quantity,
                  x_cont_names    => l_container_info_rec.container_names,
                  x_return_status => l_return_status
             );
             wsh_util_core.api_post_call(
                 p_return_status => l_return_status,
                 x_num_warnings  => l_number_of_warnings,
                 x_num_errors    => l_number_of_errors
             );
             i := l_container_info_rec.container_names.FIRST;
             WHILE i IS NOT NULL LOOP --{
                l_container_info_rec.lpn_ids(i) := NULL;
                i := l_container_info_rec.container_names.NEXT(i);
             END LOOP; --} comment out till here
             l_container_rec.inventory_item_id := l_cont_item_id;
             l_container_rec.organization_id := l_organization_id;
             END IF; --}
             IF l_container_info_rec.lpn_ids.COUNT <> p_detail_IN_rec.quantity
             THEN
                RAISE e_lpn_count_invalid;
             END IF;

           ELSIF  l_create_one_record THEN --}{
             --bmso
             IF c_wms_code_present = 'Y' THEN --{
             IF l_debug_on THEN
                wsh_debug_sv.logmsg(l_module_name, 'Calling wms_container_grp.create_lpns');
             END IF;
             l_lpn_table(1).license_plate_number :=
                                               p_detail_IN_rec.container_name;
             l_lpn_table(1).inventory_item_id := l_cont_item_id;
             l_lpn_table(1).organization_id := l_organization_id;
             --l_lpn_table(1).ucc_128_suffix_flag :=
                                        --p_detail_IN_rec.ucc_128_suffix_flag;

             WSH_WMS_LPN_GRP.g_call_group_api := 'N';
             WSH_WMS_LPN_GRP.g_update_to_container := 'N';

             wms_container_grp.create_lpns(
                   p_api_version           => 1.0,
                   p_init_msg_list         => fnd_api.g_false,
                   p_commit                => fnd_api.g_false,
                   x_return_status         => l_return_status,
                   x_msg_count             => l_wms_msg_count,
                   x_msg_data              => l_wms_msg_data,
                   p_caller                => 'WSH_CREATE',
                   p_lpn_table             => l_lpn_table
             );
             WSH_WMS_LPN_GRP.g_call_group_api := l_orig_value;
             WSH_WMS_LPN_GRP.g_update_to_container := l_update_container_orig;

             wsh_util_core.api_post_call(
                 p_return_status => l_return_status,
                 x_num_warnings  => l_number_of_warnings,
                 x_num_errors    => l_number_of_errors,
                 p_msg_data      => l_wms_msg_data
             );
             l_container_info_rec.container_names(1) := l_lpn_table(1).license_plate_number;
             l_container_info_rec.lpn_ids(1) := l_lpn_table(1).lpn_id;

             IF l_container_info_rec.lpn_ids(1) IS NULL THEN
                FND_MESSAGE.SET_NAME('WSH', 'WSH_REQUIRED_FIELD_NULL');
                FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'LPN_ID');
                wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
                RAISE FND_API.G_EXC_ERROR;

             ELSIF l_container_info_rec.container_names(1) IS NULL THEN
                FND_MESSAGE.SET_NAME('WSH', 'WSH_REQUIRED_FIELD_NULL');
                FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'CONTAINER_NAME');
                wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
                RAISE FND_API.G_EXC_ERROR;

             END IF;

             l_container_rec.weight_uom_code :=
                                       l_lpn_table(1).GROSS_WEIGHT_UOM_CODE;
             l_container_rec.gross_weight :=
                                       l_lpn_table(1).GROSS_WEIGHT;
             l_additional_cont_attr.tare_weight :=
                                       l_lpn_table(1).TARE_WEIGHT;
             l_additional_cont_attr.tare_weight_uom_code :=
                                       l_lpn_table(1).TARE_WEIGHT_UOM_CODE;

             l_container_rec.locator_id := l_lpn_table(1).locator_id;
             l_container_rec.subinventory := l_lpn_table(1).SUBINVENTORY_CODE;
             l_container_rec.volume_uom_code :=
                       l_lpn_table(1).CONTAINER_VOLUME_UOM;
             l_additional_cont_attr.filled_volume_uom_code :=
                       l_lpn_table(1).CONTENT_VOLUME_UOM_CODE;
             l_container_rec.filled_volume := l_lpn_table(1).CONTENT_VOLUME;
             l_container_rec.volume := l_lpn_table(1).CONTAINER_VOLUME;
             l_container_rec.inventory_item_id := l_cont_item_id;
             l_container_rec.organization_id := l_organization_id;

             ELSE --}{
             /* COMMENT THIS PART ONCE WMS CODE IS AVAILABLE */
             wsh_container_actions.Create_Multiple_Cont_name (
                  p_cont_name     => p_detail_IN_rec.container_name,
                  p_cont_name_pre => NULL,
                  p_cont_name_suf => NULL,
                  p_cont_name_num => NULL,
                  p_cont_name_dig => NULL,
                  p_quantity      => p_detail_IN_rec.quantity,
                  x_cont_names    => l_container_info_rec.container_names,
                  x_return_status => l_return_status
             );
             wsh_util_core.api_post_call(
                 p_return_status => l_return_status,
                 x_num_warnings  => l_number_of_warnings,
                 x_num_errors    => l_number_of_errors
             );
             l_container_info_rec.lpn_ids(1) := NULL;
             l_container_rec.inventory_item_id := l_cont_item_id;
             l_container_rec.organization_id := l_organization_id;
             END IF; --}
           END IF; --}
           wsh_container_actions.default_container_attr(l_container_rec,
                                                        l_additional_cont_attr,
                                                        p_detail_IN_rec.caller,
                                                        l_return_status);
           wsh_util_core.api_post_call(
                 p_return_status => l_return_status,
                 x_num_warnings  => l_number_of_warnings,
                 x_num_errors    => l_number_of_errors
           );
           WSH_DELIVERY_DETAILS_PKG.create_delivery_details_bulk
           ( p_delivery_details_info    => l_container_rec,
                p_num_of_rec            => p_detail_IN_rec.quantity,
                p_container_info_rec    => l_container_info_rec,
                x_return_status         => l_return_status,
                x_dd_id_tab             => l_cont_dummy_tab
           );

           IF l_return_status IN
              (WSH_UTIL_CORE.G_RET_STS_ERROR,
               WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR  ) THEN
              --
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR CREATING CONTAINER');
              END IF;
              --
              FND_MESSAGE.SET_NAME('WSH','WSH_CONT_CREATE_ERROR');
              WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
              RAISE FND_API.G_EXC_ERROR;
           END IF;

           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'COUNT OF WDD RECORDS',
                                                      l_cont_dummy_tab.count);
           END IF;

           wsh_util_core.api_post_call(
                 p_return_status => l_return_status,
                 x_num_warnings  => l_number_of_warnings,
                 x_num_errors    => l_number_of_errors
           );

           WSH_DELIVERY_DETAILS_PKG.create_deliv_assignment_bulk
               ( p_delivery_assignments_info => l_del_assg_rec,
                 p_num_of_rec => p_detail_IN_rec.quantity,
                 p_dd_id_tab  =>  l_cont_dummy_tab,
                 x_da_id_tab => l_assignment_dummy_tab,
                 x_return_status => l_return_status
           );

           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'COUNT OF WDA RECORDS',
                                               l_assignment_dummy_tab.count);
              WSH_DEBUG_SV.log(l_module_name,'Return Status',l_return_status);
           END IF;

           IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                             WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_CONT_CREATE_ERROR');
                WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
                RAISE FND_API.G_EXC_ERROR;
           END IF;


           wsh_util_core.api_post_call(
                    p_return_status => l_return_status,
                    x_num_warnings  => l_number_of_warnings,
                    x_num_errors    => l_number_of_errors
                );

        ELSIF l_create_for_wms THEN --}{
           -- Create container for WMS callers
           i := p_detail_info_tab.FIRST;
           WHILE i IS NOT NULL LOOP --{
              IF p_detail_info_tab(i).organization_id IS NULL THEN --{
                 FND_MESSAGE.SET_NAME('WSH', 'WSH_REQUIRED_FIELD_NULL');
                 FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'ORGANIZATION_ID');
                 wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
                 IF l_debug_on THEN
                   wsh_debug_sv.log(l_module_name,'ERROR organization id is null for', p_detail_info_tab(i).lpn_id);
                 END IF;

                 raise FND_API.G_EXC_ERROR;

              END IF; --}
              IF p_detail_info_tab(i).lpn_id IS NULL THEN
                 FND_MESSAGE.SET_NAME('WSH', 'WSH_REQUIRED_FIELD_NULL');
                 FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'LPN_ID');
                 wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
                 RAISE FND_API.G_EXC_ERROR;

              ELSIF p_detail_info_tab(i).container_name IS NULL THEN
                 FND_MESSAGE.SET_NAME('WSH', 'WSH_REQUIRED_FIELD_NULL');
                 FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'CONTAINER_NAME');
                 wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
                 RAISE FND_API.G_EXC_ERROR;

              END IF;

              l_container_info_rec.lpn_ids(1) := p_detail_info_tab(i).lpn_id;
              l_container_info_rec.container_names(1) := p_detail_info_tab(i).container_name;
              l_container_rec := p_detail_info_tab(i);
              l_additional_cont_attr.filled_volume_uom_code := p_detail_info_tab(i).volume_uom_code;

              /*IF l_container_rec.organization_id IS NULL THEN

                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,
                                          'organization is not passed');
                 END IF;
                 RAISE FND_API.G_EXC_ERROR;
              END IF; */

              wsh_container_actions.default_container_attr(l_container_rec,
                                                      l_additional_cont_attr,
                                                      p_detail_IN_rec.caller,
                                                      l_return_status);
              wsh_util_core.api_post_call(
                    p_return_status => l_return_status,
                    x_num_warnings  => l_number_of_warnings,
                    x_num_errors    => l_number_of_errors
              );
              WSH_DELIVERY_DETAILS_PKG.create_delivery_details_bulk
              ( p_delivery_details_info    => l_container_rec,
                   p_num_of_rec            => 1,
                   p_container_info_rec    => l_container_info_rec,
                   x_return_status         => l_return_status,
                   x_dd_id_tab             => l_cont_dummy_tab
              );

              IF l_return_status IN
                 (WSH_UTIL_CORE.G_RET_STS_ERROR,
                  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR  ) THEN
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR CREATING CONTAINER');
                 END IF;
                 --
                 FND_MESSAGE.SET_NAME('WSH','WSH_CONT_CREATE_ERROR');
                 WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
                 RAISE FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'COUNT OF WDD RECORDS',
                                                      l_cont_dummy_tab.count);
              END IF;

              wsh_util_core.api_post_call(
                    p_return_status => l_return_status,
                    x_num_warnings  => l_number_of_warnings,
                    x_num_errors    => l_number_of_errors
              );

              WSH_DELIVERY_DETAILS_PKG.create_deliv_assignment_bulk
                  ( p_delivery_assignments_info => l_del_assg_rec,
                    p_num_of_rec => 1,
                    p_dd_id_tab  =>  l_cont_dummy_tab,
                    x_da_id_tab => l_assignment_dummy_tab,
                    x_return_status => l_return_status
              );

              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'COUNT OF WDA RECORDS',
                                                  l_assignment_dummy_tab.count);
                 WSH_DEBUG_SV.log(l_module_name,'Return Status',l_return_status);
              END IF;

              IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                             WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                   FND_MESSAGE.SET_NAME('WSH','WSH_CONT_CREATE_ERROR');
                   WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
                   RAISE FND_API.G_EXC_ERROR;
              END IF;
              --
              wsh_util_core.api_post_call(
                    p_return_status => l_return_status,
                    x_num_warnings  => l_number_of_warnings,
                    x_num_errors    => l_number_of_errors
              );

              i:= p_detail_info_tab.NEXT(i);

           END LOOP; --}
        END IF; --}


        x_container_ids       := l_cont_dummy_tab;

        IF l_number_of_errors > 0
        THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        ELSIF l_number_of_warnings > 0
        THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        ELSE
            x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;

    EXCEPTION
        WHEN e_NO_INV_ITEM then
           WSH_WMS_LPN_GRP.g_call_group_api := l_orig_value;
           WSH_WMS_LPN_GRP.g_update_to_container := l_update_container_orig;

           rollback to s_create_containers_DDGPB;
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:e_NO_INV_ITEM');
           END IF;
        WHEN e_lpn_count_invalid then
           WSH_WMS_LPN_GRP.g_call_group_api := l_orig_value;
           WSH_WMS_LPN_GRP.g_update_to_container := l_update_container_orig;

           rollback to s_create_containers_DDGPB;
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fnd_message.set_name('WSH', 'WSH_LPN_COUNT_INVALID');
           WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
           IF l_debug_on THEN
               WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:e_lpn_count_invalid');
           END IF;
           --

        WHEN FND_API.G_EXC_ERROR THEN
                WSH_WMS_LPN_GRP.g_call_group_api := l_orig_value;
                WSH_WMS_LPN_GRP.g_update_to_container := l_update_container_orig;

                rollback to s_create_containers_DDGPB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,
                    'FND_API.G_EXC_ERROR exception has occured.',
                     WSH_DEBUG_SV.C_EXCEP_LEVEL);
                     WSH_DEBUG_SV.pop(l_module_name,
                                     'EXCEPTION:FND_API.G_EXC_ERROR');
                END IF;
                --
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                WSH_WMS_LPN_GRP.g_call_group_api := l_orig_value;
                rollback to s_create_containers_DDGPB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name
                      ,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.'
                      ,WSH_DEBUG_SV.C_EXCEP_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name
                       ,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
                END IF;
                  --
        WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
                WSH_WMS_LPN_GRP.g_call_group_api := l_orig_value;
                WSH_WMS_LPN_GRP.g_update_to_container := l_update_container_orig;

             x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name
                   ,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured '
                   ,WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name
                   ,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
            END IF;
        WHEN OTHERS THEN
            WSH_WMS_LPN_GRP.g_call_group_api := l_orig_value;
            rollback to s_create_containers_DDGPB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            wsh_util_core.add_message(x_return_status, l_module_name);
            WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_GRP.Create_containers');
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
            END IF;

    END Create_containers;

    -- ---------------------------------------------------------------------
    -- Procedure: Create_Delivery_Detail
    --
    -- Parameters:
    --
    -- Description:  This local procedure is the new API for wrapping the logic of CREATE of delivery details
    -- Created:   Harmonization Project. Patchset I
    -- -----------------------------------------------------------------------

    PROCEDURE  Create_Delivery_Detail(
                p_detail_info_tab     IN WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type ,
                p_detail_IN_rec       IN  WSH_GLBL_VAR_STRCT_GRP.detailInRecType,
                p_valid_index_tab     IN  wsh_util_core.id_tab_type,
                x_detail_OUT_rec      OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.detailOutRecType,
                x_return_status       OUT NOCOPY  varchar2,
                x_msg_count           OUT NOCOPY      NUMBER,
                x_msg_data            OUT NOCOPY      VARCHAR2)
  IS

  l_api_name              	CONSTANT VARCHAR2(30)   := 'Create_Delivery_Detail';
  l_api_version           	CONSTANT NUMBER         := 1.0;
  l_init_msg_list         	VARCHAR2(100);
  l_commit                	VARCHAR2(100);

  --
  l_return_status             	VARCHAR2(32767);
  l_msg_count                 	NUMBER;
  l_msg_data                  	VARCHAR2(32767);
  l_program_name              	VARCHAR2(32767);

  l_number_of_errors    	NUMBER := 0;
  l_number_of_warnings  	NUMBER := 0;
  --
  l_index                  	NUMBER;
  l_new_detail_id          	NUMBER;
  l_dummy_rowid            	VARCHAR2(32767);
  l_dummy_assgn_rowid      	VARCHAR2(32767);
  l_delivery_assignment_id 	NUMBER;
  l_delivery_assignments_info   WSH_DELIVERY_DETAILS_PKG.Delivery_Assignments_Rec_Type;
  l_item_type              	VARCHAR2(30);

  l_validation_level       	NUMBER;

  --OTM R12
  l_delivery_detail_tab		WSH_ENTITY_INFO_TAB;
  l_delivery_detail_rec		WSH_ENTITY_INFO_REC;
  l_item_quantity_uom_tab	WSH_UTIL_CORE.COLUMN_TAB_TYPE;
  l_gc3_is_installed            VARCHAR2(1);
  l_counter                     NUMBER;
  --

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_DELIVERY_DETAIL';

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
        SAVEPOINT CREATE_DEL_DETAIL_GRP;

        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            WSH_DEBUG_SV.log(l_module_name, 'container_item_id',p_detail_IN_rec.container_item_id);
            WSH_DEBUG_SV.log(l_module_name, 'container_item_name',p_detail_IN_rec.container_item_name);
            WSH_DEBUG_SV.log(l_module_name, 'organization_id', p_detail_IN_rec.organization_id);
            WSH_DEBUG_SV.log(l_module_name, 'organization_code',p_detail_IN_rec.organization_code);
            WSH_DEBUG_SV.log(l_module_name, 'name_prefix', p_detail_IN_rec.name_prefix);
            WSH_DEBUG_SV.log(l_module_name, 'name_suffix', p_detail_IN_rec.name_suffix);
            WSH_DEBUG_SV.log(l_module_name, 'base number', p_detail_IN_rec.base_number);
            WSH_DEBUG_SV.log(l_module_name, 'Num Digits', p_detail_IN_rec.num_digits);
            WSH_DEBUG_SV.log(l_module_name, 'Quantity', p_detail_IN_rec.quantity);
            WSH_DEBUG_SV.log(l_module_name, 'Container Name', p_detail_IN_rec.container_name);
            WSH_DEBUG_SV.log(l_module_name, 'Lpn Ids Count', p_detail_In_rec.lpn_ids.count);
            WSH_DEBUG_SV.log(l_module_name, 'Caller', p_detail_in_rec.caller);
        END IF;
        --

        --  Initialize API return status to success
        x_return_status       := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        l_number_of_errors := 0;
        l_number_of_warnings := 0;

	--OTM R12 initialize
        l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

        IF (l_gc3_is_installed IS NULL) THEN
          l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
        END IF;

        IF (l_gc3_is_installed = 'Y') THEN
          l_delivery_detail_tab := WSH_ENTITY_INFO_TAB();
        END IF;
        l_counter := 1;
	--

         l_index := p_valid_index_tab.FIRST;

         IF(l_index IS NULL) OR nvl(WSH_WMS_LPN_GRP.g_caller,'WSH') like 'WMS%' THEN --{

            -- logic for creating containers
             IF nvl(WSH_WMS_LPN_GRP.g_caller,'WSH') NOT LIKE 'WMS%' THEN --{
                IF( p_detail_IN_rec.organization_id IS NULL and p_detail_IN_rec.organization_code IS NULL) THEN
                    FND_MESSAGE.SET_NAME('WSH', 'WSH_CONT_ORG_NULL');
                    wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
                    IF l_debug_on THEN
                       wsh_debug_sv.logmsg(l_module_name,'Null Organization');
                    END IF;
                    raise FND_API.G_EXC_ERROR;
                ELSIF(p_detail_IN_rec.container_item_id IS NULL
                   AND p_detail_IN_rec.container_item_name IS NULL
                   AND p_detail_IN_rec.container_item_seg.count = 0) THEN
                   FND_MESSAGE.SET_NAME('WSH', 'WSH_REQUIRED_FIELD_NULL');
                   FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'CONTAINER_ITEM');
                   wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
                     IF l_debug_on THEN
                       wsh_debug_sv.logmsg(l_module_name,'Null Container item');
                     END IF;

                     raise FND_API.G_EXC_ERROR;

                END IF;
             END IF; --}

            Create_containers(
                p_detail_info_tab  => p_detail_info_tab,
                p_detail_IN_rec  => p_detail_IN_rec,
                x_container_ids  => x_detail_out_rec.detail_ids,
                x_return_status => l_return_status
            );
            wsh_util_core.api_post_call(
                      p_return_status => l_return_status,
                      x_num_warnings  => l_number_of_warnings,
                      x_num_errors    => l_number_of_errors
            );
         ELSE --}{
            WHILE  l_index IS NOT NULL
            LOOP --{
               --
               IF(p_detail_info_tab(l_index).container_flag in ('Y', 'C')) THEN
                  IF l_debug_on THEN
                     wsh_debug_sv.logmsg(l_module_name,'Container Flag Yes ');
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;

               IF  p_detail_info_tab(l_index).inventory_item_id  IS NOT NULL THEN --{
                   -- Validate Item and see if this is container item
                    -- Error out if this is a container item

                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.FIND_ITEM_TYPE',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;

                  WSH_UTIL_VALIDATE.Find_Item_Type
                   (
                     p_inventory_item_id => p_detail_info_tab(l_index).inventory_item_id,
                     p_organization_id   => p_detail_info_tab(l_index).organization_id,
                     x_item_type         => l_item_type,
                     x_return_status     => l_return_status
                   );

                  IF l_debug_on THEN
                     wsh_debug_sv.log(l_module_name, 'Item Type', l_item_type);
                  END IF;
                  --
                  wsh_util_core.api_post_call(
                         p_return_status => l_return_status,
                         x_num_warnings  => l_number_of_warnings,
                         x_num_errors    => l_number_of_errors,
                         p_msg_data      => l_msg_data
                         );

                  IF(nvl(l_item_type, 'FND_API.G_MISS_CHAR') = 'CONT_ITEM') THEN
                      IF l_debug_on THEN
                         wsh_debug_sv.logmsg(l_module_name,'Container Item');
                      END IF;
                     RAISE FND_API.G_EXC_ERROR;
                   END IF;
                END IF; --}


                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.CREATE_DELIVERY_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_DELIVERY_DETAILS_PKG.create_delivery_details(
                 p_delivery_details_info  =>   p_detail_info_tab(l_index),
                 x_rowid                =>   l_dummy_rowid,
                 x_delivery_detail_id     =>   l_new_detail_id,
                 x_return_status          =>   l_return_status);

                IF l_debug_on THEN
                   wsh_debug_sv.log(l_module_name, 'New Detail Created', l_new_detail_id);
                END IF;

                --
                wsh_util_core.api_post_call(
                      p_return_status => l_return_status,
                      x_num_warnings  => l_number_of_warnings,
                      x_num_errors    => l_number_of_errors,
                      p_msg_data      => l_msg_data,
                      p_raise_error_flag  => FALSE
                      );
                --
                IF l_return_status <> wsh_util_core.g_ret_sts_success THEN
                   FND_MESSAGE.SET_NAME('WSH', 'WSH_DET_CREATE_DET_FAILED');
                   wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
                l_delivery_assignments_info.delivery_id               := NULL;
                l_delivery_assignments_info.parent_delivery_id        := NULL;
                l_delivery_assignments_info.delivery_detail_id        := l_new_detail_id;
                l_delivery_assignments_info.parent_delivery_detail_id := NULL;


                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.CREATE_DELIVERY_ASSIGNMENTS',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_DELIVERY_DETAILS_PKG.Create_Delivery_Assignments(
                  p_delivery_assignments_info    =>   l_delivery_assignments_info,
                  x_rowid                        =>   l_dummy_assgn_rowid,
                  x_delivery_assignment_id       =>   l_delivery_assignment_id,
                  x_return_status                =>   l_return_status);

                  x_detail_out_Rec.detail_ids(l_index) := l_new_detail_id;

                wsh_util_core.api_post_call(
                      p_return_status => l_return_status,
                      x_num_warnings  => l_number_of_warnings,
                      x_num_errors    => l_number_of_errors,
                      p_msg_data      => l_msg_data,
                      p_raise_error_flag  => FALSE
                      );

                IF l_return_status <> wsh_util_core.g_ret_sts_success THEN
                   FND_MESSAGE.SET_NAME('WSH', 'WSH_DET_CREATE_AS_FAILED');
                   wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
                   RAISE FND_API.G_EXC_ERROR;
                END IF;

		--OTM R12, calling delivery detail splitter
		IF (l_gc3_is_installed = 'Y') THEN

                  IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'Delivery detail number',l_index);
                    WSH_DEBUG_SV.log(l_module_name,'Delivery detail count',l_counter);
                    WSH_DEBUG_SV.log(l_module_name,'delivery detail id',l_new_detail_id);
                    WSH_DEBUG_SV.log(l_module_name,'inventory item id',p_detail_info_tab(l_index).inventory_item_id);
                    WSH_DEBUG_SV.log(l_module_name,'net weight',p_detail_info_tab(l_index).net_weight);
                    WSH_DEBUG_SV.log(l_module_name,'organization id',p_detail_info_tab(l_index).organization_id);
                    WSH_DEBUG_SV.log(l_module_name,'weight uom code',p_detail_info_tab(l_index).weight_uom_code);
                    WSH_DEBUG_SV.log(l_module_name,'requested quantity',p_detail_info_tab(l_index).requested_quantity);
                    WSH_DEBUG_SV.log(l_module_name,'ship from location id',p_detail_info_tab(l_index).ship_from_location_id);
                    WSH_DEBUG_SV.log(l_module_name,'requested quantity uom',p_detail_info_tab(l_index).requested_quantity_uom);
                  END IF;

                  --prepare table of delivery detail information to call splitter
		  l_delivery_detail_tab.EXTEND;
		  l_delivery_detail_tab(l_counter) := WSH_ENTITY_INFO_REC(l_new_detail_id,
					NULL,
				     	p_detail_info_tab(l_index).inventory_item_id,
				     	p_detail_info_tab(l_index).net_weight,
					0,
					p_detail_info_tab(l_index).organization_id,
					p_detail_info_tab(l_index).weight_uom_code,
					p_detail_info_tab(l_index).requested_quantity,
					p_detail_info_tab(l_index).ship_from_location_id,
					NULL);
	          l_item_quantity_uom_tab(l_counter)   := p_detail_info_tab(l_index).requested_quantity_uom;
                  l_counter := l_counter + 1;
		END IF;
		--END OTM R12

                l_index := p_valid_index_tab.NEXT(l_index);
                --
             END LOOP; -- while l_index is not null }

             --OTM R12, after loop call split with all the data
             IF (l_counter > 1) THEN

               IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_SPLITTER.tms_delivery_detail_split',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;

               WSH_DELIVERY_DETAILS_SPLITTER.tms_delivery_detail_split(
                 p_detail_tab => l_delivery_detail_tab,
                 p_item_quantity_uom_tab => l_item_quantity_uom_tab,
                 x_return_status => l_return_status);

               IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_DELIVERY_DETAILS_SPLITTER.tms_delivery_detail_split: ' || l_return_status);
               END IF;

               -- we will not fail based on l_return_status here because
               -- we do not want to stop the flow
               -- if the detail doesn't split, it will be caught later in
               -- delivery splitting and will have exception on the detail
               IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                 IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'Delivery detail split failed for ' || l_new_detail_id );
                 END IF;
               END IF;
             END IF;
             --END OTM R12
          END IF; --}
       FND_MSG_PUB.Count_And_Get
         (
          p_count  => x_msg_count,
          p_data  =>  x_msg_data,
          p_encoded => FND_API.G_FALSE
         );

    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK to CREATE_DEL_DETAIL_GRP;
                x_return_status := FND_API.G_RET_STS_ERROR ;
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
                ROLLBACK to CREATE_DEL_DETAIL_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );

                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
                  END IF;
                  --
        WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
             x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
             FND_MSG_PUB.Count_And_Get
              (
                p_count  => x_msg_count,
                p_data  =>  x_msg_data,
                p_encoded => FND_API.G_FALSE
              );
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
       END IF;
--
        WHEN OTHERS THEN

                ROLLBACK to CREATE_DEL_DETAIL_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
               wsh_util_core.add_message(x_return_status, l_module_name);
               WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_GRP.Create_Delivery_Detail');
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
    END Create_Delivery_Detail;

-- anxsharm for Load Tender
-- added a new out parameter x_detail_tender_tab
-- This table of id will have the delivery detail ids
-- for which the weight or volume or delivery or parent_detail
-- or picked/shipped quantity have changed.
    -- ---------------------------------------------------------------------
    -- Procedure: Validate_Delivery_Detail
    --
    -- Parameters:
    --
    -- Description:  This local procedure is the new API for wrapping the logic of VALIDATE of delivery details
    -- Created:   Harmonization Project. Patchset I
    -- -----------------------------------------------------------------------

    -- frontport bug 5055682
    -- ---------------------------------------------------------------------
    -- Behavior for Serial Numbers :
    -- 1) If single serial number is passed as part of p_in_detail_rec, then
    --    serial number will be stamped on wdd table.
    -- 2) If single/multiple serial number(s) is passed as p_serial_range_tab,
    --    then serial number(s) will be inserted into msnt table and
    --    transaction_temp_id will be stamped on wdd table.
    -- 3) If multiple serial numbers are passed as part of p_in_detail_rec,
    --    then serial numbers will be inserted into msnt table and
    --    transaction_temp_id will be stamped on wdd table.
    -- -----------------------------------------------------------------------

    PROCEDURE  Validate_Delivery_Detail(
                x_detail_info_tab  IN  OUT NOCOPY  WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type,
                p_in_detail_tab    IN   WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type,
                p_action           IN  VARCHAR2,
                p_validation_tab   IN  wsh_util_core.id_tab_type,
                p_caller           IN  VARCHAR2,
                x_valid_index_tab  OUT  NOCOPY WSH_UTIL_CORE.Id_Tab_Type,
                x_details_marked   OUT NOCOPY WSH_UTIL_CORE.Id_Tab_Type,
                x_detail_tender_tab OUT NOCOPY wsh_util_core.id_tab_type,
                x_return_status    OUT NOCOPY VARCHAR2,
                x_msg_count        OUT NOCOPY      NUMBER,
                x_msg_data         OUT NOCOPY      VARCHAR2,
                p_in_rec           IN  WSH_GLBL_VAR_STRCT_GRP.detailInRecType,
                p_serial_range_tab IN  WSH_GLBL_VAR_STRCT_GRP.ddSerialRangeTabType
               ) IS


        l_api_name              CONSTANT VARCHAR2(30)   := 'Validate_Delivery_Detail';
        l_api_version           CONSTANT NUMBER         := 1.0;
        l_init_msg_list         VARCHAR2(32767);
        l_commit                VARCHAR2(32767);
        --
  --
  l_return_status             VARCHAR2(32767);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(32767);
  l_program_name              VARCHAR2(32767);
        --
  l_number_of_errors    NUMBER := 0;
  l_number_of_warnings  NUMBER := 0;
  --

        l_index                  NUMBER;
        l_new_detail_id          NUMBER;
        l_dummy_rowid            NUMBER;
        l_dummy_assgn_rowid      NUMBER;
        l_delivery_assignment_id NUMBER;
        l_delivery_assignments_info     WSH_DELIVERY_DETAILS_PKG.Delivery_Assignments_Rec_Type;
        l_required_field        VARCHAR2(32767);

        l_validation_level       NUMBER;
        l_org_id               NUMBER;
        l_isWshLocation         BOOLEAN DEFAULT FALSE;

        /* H projects: pricing integration csun */
        l_mark_reprice_flag            VARCHAR2(1) := 'N';
        m NUMBER := 0;
        l_details_marked        WSH_UTIL_CORE.Id_Tab_Type;
        mark_reprice_error  EXCEPTION;

        l_original_detail_rec c_original_detail_cur%ROWTYPE;
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_DELIVERY_DETAIL';
  -- OPM Bug 3055126
  l_check_status         NUMBER;
  --

    --
    uom_conversion_failed       EXCEPTION;
    e_required_field_null       EXCEPTION;
    e_ib_create_error           EXCEPTION;
    -- PK Bug 3055126 OPM Exceptions
-- HW OPMCONV - Removed OPM variables

-- anxsharm for Load Tender
-- remove this cursor not being used

    CURSOR c_original_line(p_counter NUMBER)
    IS
    SELECT source_line_id,
           organization_id,
           inventory_item_id,
           serial_number,
           transaction_temp_id,
           locator_id,
           revision,
           subinventory,
           lot_number,
           released_status,
           requested_quantity_uom
    FROM wsh_delivery_details
    WHERE delivery_detail_id = x_detail_info_tab(p_counter).delivery_detail_id;
    -- AND source_code = p_source_code;

    l_old_delivery_detail_rec c_original_line%ROWTYPE;

    CURSOR c_inventory_item_info(p_inventory_item_id number, p_organization_id number) is
    SELECT  primary_uom_code,
    description,
    hazard_class_id,
    weight_uom_code,
    unit_weight,
    volume_uom_code,
    unit_volume
     FROM mtl_system_items
     WHERE inventory_item_id = p_inventory_item_id
     AND   organization_id  = p_organization_id;

     l_inventory_item_info c_inventory_item_info%ROWTYPE;

-- anxsharm for Load tender
     l_old_table wsh_interface.deliverydetailtab;
     l_new_table wsh_interface.deliverydetailtab;
     l_count_old NUMBER;
     l_count_new NUMBER;
     l_fte_installed VARCHAR2(1);

    BEGIN
        --
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
        --
        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;
        --
        SAVEPOINT VALIDATE_DEL_DETAIL_GRP;

        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            --
            WSH_DEBUG_SV.log(l_module_name,'P_ACTION',P_ACTION);
            WSH_DEBUG_SV.log(l_module_name,'p_caller',p_caller);
        END IF;
        --
        --  Initialize API return status to success
  x_return_status       := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_number_of_errors := 0;
  l_number_of_warnings := 0;

        IF p_caller IN ( 'WSH_FSTRX' , 'WSH_TPW_INBOUND')
          OR p_caller LIKE 'FTE%' THEN
            l_isWshLocation := TRUE;
        END IF;

        l_index := x_detail_info_tab.FIRST;

        IF wsh_util_core.fte_is_installed = 'Y' THEN
          l_fte_installed := 'Y';
        END IF;

        --
        WHILE l_index IS NOT NULL
        LOOP
           --
           BEGIN
             SAVEPOINT validate_det_loop_grp;
             --
             IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name, 'Index', l_index);
             END IF;
             IF(p_action = 'CREATE') THEN
                      --
                      -- J-IB-NPARIKH-{
                      --
                      IF NVL(x_detail_info_tab(l_index).line_direction,'O') NOT IN ('O','IO')
                      THEN
                        --
                        -- Cannot create inbound lines through group APIs
                        --
                        RAISE e_ib_create_error;
                      END IF;
                      --
                      -- J-IB-NPARIKH-}
                      --
                      IF (x_detail_info_tab(l_index).source_code is NULL) THEN
                          l_required_field := 'SOURCE_CODE';
                    RAISE e_required_field_null;
                      ELSIF (x_detail_info_tab(l_index).source_header_id is NULL) THEN
                          l_required_field := 'SOURCE_HEADER_ID';
                    RAISE e_required_field_null;
                      ELSIF (x_detail_info_tab(l_index).source_line_id is NULL) THEN
                          l_required_field := 'SOURCE_LINE_ID';
                    RAISE e_required_field_null;
                      ELSIF (x_detail_info_tab(l_index).src_requested_quantity is NULL) THEN
                          l_required_field := 'SRC_REQ_QTY';
                    RAISE e_required_field_null;
                      ELSIF (x_detail_info_tab(l_index).src_requested_quantity_uom is NULL) THEN
                          l_required_field := 'SRC_REQ_QTY_UOM';
                    RAISE e_required_field_null;

                     /* if item is not setup in the inventory system yet.
                    The required fields
                          Item_Description,
                           Weight_UOM_Code,
                           Volume_UOM_Code,
                          Net_Weight,
                           Volume */
                      --
                      ELSIF (x_detail_info_tab(l_index).inventory_item_id is NULL) THEN

                          if (x_detail_info_tab(l_index).item_description is NULL) THEN
                            l_required_field := 'ITEM';
                            raise e_required_field_null;
                    end if;

              /* you need to either have inventory_item_id or item_description */
                  if (x_detail_info_tab(l_index).item_description is not NULL) then

            -- bug 2398865
                    IF ( nvl(x_detail_info_tab(l_index).requested_quantity,fnd_api.g_miss_num) = fnd_api.g_miss_num ) THEN
                   x_detail_info_tab(l_index).requested_quantity_uom := x_detail_info_tab(l_index).src_requested_quantity_uom;
                 x_detail_info_tab(l_index).requested_quantity := x_detail_info_tab(l_index).src_requested_quantity;
                END IF;
            -- bug 2398865
               if (x_detail_info_tab(l_index).weight_uom_code is NULL) THEN
                                     l_required_field := 'WEIGHT_UOM';
             raise e_required_field_null;
                    end if;

              if (x_detail_info_tab(l_index).volume_uom_code is NULL) THEN
                                     l_required_field := 'VOLUME_UOM';
             raise e_required_field_null;
                  end if;

              if (x_detail_info_tab(l_index).net_weight is NULL) THEN
                                        l_required_field := 'NET_WEIGHT';
                raise e_required_field_null;
                    end if;

              if (x_detail_info_tab(l_index).volume is NULL) THEN
                                        l_required_field := 'VOLUME';
                raise e_required_field_null;
              end if;

              end if; -- if item_description is not null

                         /* Bug 2177410, skip inventory interface for non-item */
                         x_detail_info_tab(l_index).inv_interfaced_flag := 'X';
                      --
                     ELSIF (x_detail_info_tab(l_index).organization_id is NULL) THEN
                        l_required_field := 'ORGANIZATION_ID';
            raise e_required_field_null;
                     ELSIF (x_detail_info_tab(l_index).source_header_number is NULL) THEN
                        l_required_field := 'SOURCE_HEADER_NUMBER';
            raise e_required_field_null;
                     ELSIF (x_detail_info_tab(l_index).org_id is NULL) THEN
                        l_required_field := 'ORG_ID';
            raise e_required_field_null;
                     ELSIF (x_detail_info_tab(l_index).source_line_number is NULL) THEN
                        l_required_field := 'SOURCE_LINE_NUMBER';
            raise e_required_field_null;
                     END IF;

                     IF x_detail_info_tab(l_index).ship_from_location_id is NULL THEN
                          l_required_field := 'SHIP_FROM_LOCATION_ID';
                          raise e_required_field_null;
                     ELSE
                           IF l_debug_on THEN
                              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_LOCATION',WSH_DEBUG_SV.C_PROC_LEVEL);
                           END IF;
                          wsh_util_validate.validate_location(
                              p_location_id   => x_detail_info_tab(l_index).ship_from_location_id,
                              x_return_status => l_return_status,
                              p_isWshLocation => l_isWshLocation);

                       wsh_util_core.api_post_call(
                           p_return_status => l_return_status,
                           x_num_warnings  => l_number_of_warnings,
                           x_num_errors    => l_number_of_errors,
                           p_msg_data      => l_msg_data
                           );
                     END IF;

                     IF x_detail_info_tab(l_index).ship_to_location_id is NULL THEN
                            l_required_field := 'SHIP_TO_LOCATION_ID';
                            raise e_required_field_null;
                     ELSE
                           IF l_debug_on THEN
                              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_LOCATION',WSH_DEBUG_SV.C_PROC_LEVEL);
                           END IF;
                          wsh_util_validate.validate_location(
                              p_location_id   => x_detail_info_tab(l_index).ship_to_location_id,
                              x_return_status => l_return_status,
                              p_isWshLocation => l_isWshLocation);

                       wsh_util_core.api_post_call(
                           p_return_status => l_return_status,
                           x_num_warnings  => l_number_of_warnings,
                           x_num_errors    => l_number_of_errors,
                           p_msg_data      => l_msg_data
                           );
                     END IF;

                      --
                     IF (x_detail_info_tab(l_index).inventory_item_id is not null) THEN
                        --
              open c_inventory_item_info(x_detail_info_tab(l_index).inventory_item_id, x_detail_info_tab(l_index).organization_id);
            fetch c_inventory_item_info into l_inventory_item_info;
            close c_inventory_item_info;

            x_detail_info_tab(l_index).item_description := l_inventory_item_info.description;
            x_detail_info_tab(l_index).requested_quantity_uom := l_inventory_item_info.primary_uom_code;

                        --
            if (x_detail_info_tab(l_index).requested_quantity_uom is NULL) THEN
                            l_required_field := 'PRIMARY_UOM';
          raise e_required_field_null;
            end if;

            -- bug 2398865
                        --
            IF ( nvl(x_detail_info_tab(l_index).requested_quantity,fnd_api.g_miss_num) = fnd_api.g_miss_num ) THEN

               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;

                 x_detail_info_tab(l_index).requested_quantity := wsh_wv_utils.convert_uom(
         x_detail_info_tab(l_index).src_requested_quantity_uom,
         l_inventory_item_info.primary_uom_code,
         x_detail_info_tab(l_index).src_requested_quantity,
         x_detail_info_tab(l_index).inventory_item_id);

                       wsh_util_core.api_post_call(
                           p_return_status => l_return_status,
                           x_num_warnings  => l_number_of_warnings,
                           x_num_errors    => l_number_of_errors,
                           p_msg_data      => l_msg_data
                           );
                        --
           END IF;
           -- bug 2398865
                        --
                  if (x_detail_info_tab(l_index).requested_quantity is NULL) THEN
                raise UOM_CONVERSION_FAILED;
            end if;
                        --
            x_detail_info_tab(l_index).weight_uom_code := l_inventory_item_info.weight_uom_code;
            x_detail_info_tab(l_index).volume_uom_code := l_inventory_item_info.volume_uom_code;

                     END IF;

                        --
                        /* make it not applicable for pick release */
                        IF (x_detail_info_tab(l_index).source_code = 'OKE' ) THEN
                x_detail_info_tab(l_index).released_status := 'X';
                        END IF;
                        --
                       IF (x_detail_info_tab(l_index).container_flag is NULL) THEN
                 x_detail_info_tab(l_index).container_flag := 'N';
                       END IF;

                        --
                        /* Bug 2212025 default date_requested to date_scheduled */
                        x_detail_info_tab(l_index).date_requested := NVL(x_detail_info_tab(l_index).date_requested, x_detail_info_tab(l_index).date_scheduled);

             --
             ELSIF p_action = 'UPDATE' THEN

               OPEN c_original_detail_cur(x_detail_info_tab(l_index).delivery_detail_id);
               FETCH c_original_detail_cur INTO l_original_detail_rec;

               IF c_original_detail_cur%NOTFOUND THEN
                     CLOSE c_original_detail_cur;
                     IF l_debug_on THEN
                       wsh_debug_sv.logmsg(l_module_name,'No Original Detail Record ');
                     END IF;
                     l_number_of_errors := l_number_of_errors + 1;
                     FND_MESSAGE.SET_NAME('WSH', 'WSH_DET_INVALID_DETAIL');
                     FND_MESSAGE.SET_TOKEN('DETAIL_ID', x_detail_info_tab(l_index).delivery_detail_id);
                     wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
                     RAISE FND_API.G_EXC_ERROR;
               END IF;

               CLOSE c_original_detail_cur;

               -- Bug 3382932: If caller is WMS, default the shipped_quantity2 to be the picked_quantity2.

               IF p_caller like 'WMS%' THEN

                  x_detail_info_tab(l_index).shipped_quantity2 :=  x_detail_info_tab(l_index).picked_quantity2;

               END IF;


               Validate_Detail_Common(
                    x_detail_rec        => x_detail_info_tab(l_index),
                    p_original_rec           => l_original_detail_rec,
                    p_validation_tab    => p_validation_tab,
                    x_mark_reprice_flag => l_mark_reprice_flag,
                    x_return_status     => l_return_status,
                    x_msg_count         => l_msg_count,
                    x_msg_data          => l_msg_data
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

                 IF(l_original_detail_rec.container_flag in ('Y', 'C')) THEN

                  Validate_Detail_Container(
                    x_detail_rec        => x_detail_info_tab(l_index),
                    p_original_rec           => l_original_detail_rec,
                    p_validation_tab    => p_validation_tab,
                    x_mark_reprice_flag => l_mark_reprice_flag,
                    x_return_status     => l_return_status,
                    x_msg_count         => l_msg_count,
                    x_msg_data          => l_msg_data
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

                ELSIF(l_original_detail_rec.container_flag = 'N') THEN

                 Validate_Detail_Line(
                    x_detail_rec        => x_detail_info_tab(l_index),
                    p_in_detail_rec     => p_in_detail_tab(l_index),
                    p_original_rec      => l_original_detail_rec,
                    p_validation_tab    => p_validation_tab,
                    x_mark_reprice_flag => l_mark_reprice_flag,
                    x_return_status     => l_return_status,
                    x_msg_count         => l_msg_count,
                    x_msg_data          => l_msg_data,
                    p_in_rec            => p_in_rec,
                    p_serial_range_tab  => p_serial_range_tab
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
              END IF; -- if check for container_flag

               IF(l_mark_reprice_flag = 'Y' ) THEN
                  x_details_marked(x_details_marked.count+1) := x_detail_info_tab(l_index).delivery_detail_id;
               END IF;


-- anxsharm for Load Tender
               IF l_fte_installed = 'Y' THEN

-- this is for action code of UPDATE only
-- track changes to quantity or weight or volume
-- do not pass delivery id and parent_delivery_detail_id from here

-- number of records already populated in table
               l_count_old := l_old_table.count + 1;
               l_count_new := l_new_table.count + 1;

--
-- Current Values in Database
--
               l_old_table(l_count_old).requested_quantity := l_original_detail_rec.requested_quantity;
               l_old_table(l_count_old).picked_quantity := l_original_detail_rec.picked_quantity;
               l_old_table(l_count_old).shipped_quantity := l_original_detail_rec.shipped_quantity;
               l_old_table(l_count_old).gross_weight := l_original_detail_rec.gross_weight;
               l_old_table(l_count_old).net_weight := l_original_detail_rec.net_weight;
               l_old_table(l_count_old).weight_uom_code := l_original_detail_rec.weight_uom_code;
               l_old_table(l_count_old).volume := l_original_detail_rec.volume;
               l_old_table(l_count_old).volume_uom_code := l_original_detail_rec.volume_uom_code;
-- Old record must have delivery detail id, which is same
-- as the new record
               l_old_table(l_count_old).delivery_detail_id := x_detail_info_tab(l_index).delivery_detail_id;

--
-- New Record
--
               l_new_table(l_count_new).requested_quantity := x_detail_info_tab(l_index).requested_quantity;
               l_new_table(l_count_new).picked_quantity := x_detail_info_tab(l_index).picked_quantity;
               l_new_table(l_count_new).shipped_quantity := x_detail_info_tab(l_index).shipped_quantity;
               l_new_table(l_count_new).gross_weight := x_detail_info_tab(l_index).gross_weight;
               l_new_table(l_count_new).net_weight := x_detail_info_tab(l_index).net_weight;
               l_new_table(l_count_new).weight_uom_code := x_detail_info_tab(l_index).weight_uom_code;
               l_new_table(l_count_new).volume := x_detail_info_tab(l_index).volume;
               l_new_table(l_count_new).volume_uom_code := x_detail_info_tab(l_index).volume_uom_code;

               END IF; -- fte is installed
-- anxsharm , end of code for Load Tender

             END IF; -- if p_action = create

-- HW OPMCONV - Removed checking for process
             -- PK Bug 3055126 Begin OPM Changes for validation of quantities
             IF  ( p_caller = 'WSH_PUB') THEN
               IF (nvl(x_detail_info_tab(l_index).shipped_quantity,fnd_api.g_miss_num) <> fnd_api.g_miss_num OR
                   nvl(x_detail_info_tab(l_index).shipped_quantity2,fnd_api.g_miss_num) <> fnd_api.g_miss_num) THEN

-- HW OPMCONV - Use this API instead of GMI_RESERVATION_UTIL.validate_opm_quantities

                  WSH_DETAILS_VALIDATIONS.validate_secondary_quantity
                  (
                  p_delivery_detail_id => x_detail_info_tab(l_index).delivery_detail_id,
                  x_quantity          => x_detail_info_tab(l_index).shipped_quantity,
                  x_quantity2         => x_detail_info_tab(l_index).shipped_quantity2,
                  p_caller             =>    p_caller,
                  x_return_status      => l_return_status,
                  x_msg_count          =>    l_msg_count,
                  x_msg_data           =>    l_msg_data
                  );
                   --
                   wsh_util_core.api_post_call(
                       p_return_status => l_return_status,
                       x_num_warnings  => l_number_of_warnings,
                       x_num_errors    => l_number_of_errors,
                       p_msg_data      => l_msg_data
                       );


               END IF;

-- HW OPMCONV - Needed to add check for "0". Some cases cycle_count values
-- had values of zeroes due to initialization issues
             IF ( ( nvl(x_detail_info_tab(l_index).cycle_count_quantity,fnd_api.g_miss_num) <> fnd_api.g_miss_num
               OR  nvl(x_detail_info_tab(l_index).cycle_count_quantity2,fnd_api.g_miss_num) <> fnd_api.g_miss_num )
               AND ( x_detail_info_tab(l_index).cycle_count_quantity <> 0
                OR   x_detail_info_tab(l_index).cycle_count_quantity2 <> 0) )
                    THEN

                    IF l_debug_on THEN
                        wsh_debug_sv.push(l_module_name);
                        wsh_debug_sv.LOG(l_module_name, 'x_detail_info_tab(l_index).cycle_count_quantity', x_detail_info_tab(l_index).cycle_count_quantity);
                        wsh_debug_sv.LOG(l_module_name, 'x_detail_info_tab(l_index).cycle_count_quantity2', x_detail_info_tab(l_index).cycle_count_quantity2);

                    END IF;

                 WSH_DETAILS_VALIDATIONS.validate_secondary_quantity
                  (
                  p_delivery_detail_id => x_detail_info_tab(l_index).delivery_detail_id,
                  x_quantity           => x_detail_info_tab(l_index).cycle_count_quantity,
                  x_quantity2          => x_detail_info_tab(l_index).cycle_count_quantity2,
                  p_caller             => p_caller,
                  x_return_status      => l_return_status,
                  x_msg_count          => l_msg_count,
                  x_msg_data           => l_msg_data
                  );


                  wsh_util_core.api_post_call(
                       p_return_status => l_return_status,
                       x_num_warnings  => l_number_of_warnings,
                       x_num_errors    => l_number_of_errors,
                       p_msg_data      => l_msg_data
                       );

              END IF;

           END IF;
             -- PK Bug 3055126 End OPM Changes

             -- Added for bug 4399278, 4418754
             x_valid_index_tab(l_index) := l_index;

           --
           EXCEPTION -- for the local begin
              WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO validate_det_loop_grp;
                IF l_debug_on THEN
                   wsh_debug_sv.log(l_module_name, 'Validation failure for detail', x_detail_info_tab(l_index).delivery_detail_id);
                END IF;

              WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO validate_det_loop_grp;
                IF l_debug_on THEN
                   wsh_debug_sv.logmsg(l_module_name, 'Unexpected error within loop');
                END IF;
             WHEN e_required_field_null THEN
                ROLLBACK TO validate_det_loop_grp;
                l_number_of_errors := l_number_of_errors + 1;
                FND_MESSAGE.SET_NAME('WSH', 'WSH_REQUIRED_FIELD_NULL');
                FND_MESSAGE.SET_TOKEN('FIELD_NAME', l_required_field);
                WSH_UTIL_CORE.ADD_MESSAGE(wsh_util_core.g_ret_sts_error, l_module_name);
                IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'E_REQUIRED_FIELD_NULL  exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
               END IF;
               -- J-IB-NPARIKH-{
             WHEN e_ib_create_error THEN
                ROLLBACK TO validate_det_loop_grp;
                l_number_of_errors := l_number_of_errors + 1;
                FND_MESSAGE.SET_NAME('WSH', 'WSH_IB_CREATE_LINE_ERROR');
                WSH_UTIL_CORE.ADD_MESSAGE(wsh_util_core.g_ret_sts_error, l_module_name);
                IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'e_ib_create_error  exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
               END IF;
               -- J-IB-NPARIKH-}

             when uom_conversion_failed then
                FND_MESSAGE.SEt_NAME('WSH','UOM_CONVERSION_FAILED');
                WSH_UTIL_CORE.ADD_MESSAGE(wsh_util_core.g_ret_sts_error, l_module_name);

                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'UOM_CONVERSION_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
               END IF;

              WHEN OTHERS THEN
                ROLLBACK TO validate_det_loop_grp;
                IF l_debug_on THEN
                   wsh_debug_sv.logmsg(l_module_name, 'Others exception  within loop');
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END; -- for the local begin

             -- Commented for bug 4399278, 4418754
             --x_valid_index_tab(l_index) := l_index;
             --
             l_index := x_detail_info_tab.NEXT(l_index);
        --
        END LOOP; -- while l_index is not null

-- anxsharm for Load Tender
-- new API added for comparison of attributes
-- but has different record structure.
-- Use Compare_detail_attributes API
        IF l_fte_installed = 'Y' THEN
          WSH_DETAILS_VALIDATIONS.compare_detail_attributes
                 (p_old_table     => l_old_table,
                  p_new_table     => l_new_table,
                  p_action_code   => p_action,
                  p_phase         => 1,
                  p_caller        => 'WSH',
                  x_changed_id_tab => x_detail_tender_tab,
                  x_return_status => l_return_status
                 );
          wsh_util_core.api_post_call(
                      p_return_status => l_return_status,
                      x_num_warnings  => l_number_of_warnings,
                      x_num_errors    => l_number_of_errors,
                      p_msg_data      => l_msg_data
                      );
        END IF; --l_fte_installed = 'Y'
-- anxsharm end for Load Tender


      IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name, 'Number of errors', l_number_of_errors);
         wsh_debug_sv.log(l_module_name, 'Number of warnings', l_number_of_warnings);
      END IF;

      IF x_detail_info_tab.count > 0 THEN
        IF l_number_of_errors >= x_detail_info_tab.count THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_number_of_errors >0 THEN
           RAISE WSH_UTIL_CORE.G_EXC_WARNING;
        ELSIF l_number_of_warnings > 0 THEN
           RAISE WSH_UTIL_CORE.G_EXC_WARNING;
        END IF;
      END IF;

       FND_MSG_PUB.Count_And_Get
         (
          p_count  => x_msg_count,
          p_data  =>  x_msg_data,
          p_encoded => FND_API.G_FALSE
         );

    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK to VALIDATE_DEL_DETAIL_GRP;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
                  END IF;
                  --
        --
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK to VALIDATE_DEL_DETAIL_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
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
        --
        WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
             x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
             FND_MSG_PUB.Count_And_Get
              (
                p_count  => x_msg_count,
                p_data  =>  x_msg_data,
                p_encoded => FND_API.G_FALSE
              );
        --
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
           END IF;
 --


        WHEN OTHERS THEN

                ROLLBACK to VALIDATE_DEL_DETAIL_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
               wsh_util_core.add_message(x_return_status, l_module_name);
               WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_GRP.Validate_Delivery_Detail');

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
    END Validate_Delivery_Detail;

    -- ---------------------------------------------------------------------
    -- Procedure: Update_Delivery_Detail
    --
    -- Parameters:
    --
    -- Description:  This local procedure is the new API for wrapping the logic of UPDATE of delivery details
    -- Created:   Harmonization Project. Patchset I
    -- -----------------------------------------------------------------------

    PROCEDURE  Update_Delivery_Detail(
                p_detail_info_tab     IN        WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type ,
                p_valid_index_tab     IN  wsh_util_core.id_tab_type,
                x_return_status       OUT NOCOPY  VARCHAR2,
                x_msg_count           OUT NOCOPY      NUMBER,
                x_msg_data            OUT NOCOPY      VARCHAR2,
                p_caller              IN              VARCHAR2 DEFAULT NULL)
      IS

        cursor lock_delivery_details(p_del_det IN NUMBER) is
        select delivery_detail_id
        from wsh_delivery_details
        where delivery_detail_id = p_del_det
        for update nowait;


        l_api_name              CONSTANT VARCHAR2(30)   := 'Update_Delivery_Detail';
        l_api_version           CONSTANT NUMBER         := 1.0;
        --
  --
  l_return_status             VARCHAR2(32767);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(32767);
  l_program_name              VARCHAR2(32767);
        --
  l_number_of_errors    NUMBER := 0;
  l_number_of_warnings  NUMBER := 0;
  --
        l_index                  NUMBER;
        l_delivery_detail        NUMBER;
  --lpn conv
  l_in_rec             WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
  l_out_rec            WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;

  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_DELIVERY_DETAIL';
        delivery_detail_locked EXCEPTION;
        PRAGMA EXCEPTION_INIT(delivery_detail_locked, -00054);



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
        SAVEPOINT UPDATE_DEL_DETAIL_GRP;
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            WSH_DEBUG_SV.log(l_module_name,'count of p_valid_index_tab is', p_valid_index_tab.count);
            WSH_DEBUG_SV.log(l_module_name,'count of p_detail_info_tab is', p_detail_info_tab.count);
        END IF;
        --

        --  Initialize API return status to success
  x_return_status       := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_number_of_errors := 0;
  l_number_of_warnings := 0;

        l_index := p_valid_index_tab.FIRST;

        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'first index of p_detail_info_tab is', l_index);
        END IF;

        WHILE l_index IS NOT NULL
        LOOP
            IF (p_caller like 'WMS%') OR (p_caller = 'WSH_USA') THEN
            -- Bug 3292364
            -- Lock the container being updated during OM changes.
               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name, 'lock delivery detail '||p_detail_info_tab(l_index).delivery_detail_id);
               END IF;

               OPEN lock_delivery_details(p_detail_info_tab(l_index).delivery_detail_id);
               FETCH lock_delivery_details into l_delivery_detail;

            END IF;


            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.UPDATE_DELIVERY_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_delivery_details_pkg.Update_Delivery_Details(
                p_rowid                   => p_detail_info_tab(l_index).rowid,
                p_delivery_details_info   => p_detail_info_tab(l_index),
                x_return_status           =>  l_return_status);

                  --
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

              IF lock_delivery_details%isopen THEN
                 CLOSE lock_delivery_details;
              END IF;


           l_index := p_valid_index_tab.NEXT(l_index);

       END LOOP; -- while l_index is not null

       --{ lpn conv
       IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y' THEN
          WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED := 'N';

          WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS( --bmso dependency
                     p_in_rec        => l_in_rec,
                     x_return_status => l_return_status,
                     x_out_rec       => l_out_rec
          );

          wsh_util_core.api_post_call(
                      p_return_status => l_return_status,
                      x_num_warnings  => l_number_of_warnings,
                      x_num_errors    => l_number_of_errors
          );

          WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED := 'Y';
          WSH_WMS_LPN_GRP.g_update_to_container := 'N';

       END IF;
       --} lpn conv

       FND_MSG_PUB.Count_And_Get
         (
          p_count  => x_msg_count,
          p_data  =>  x_msg_data,
          p_encoded => FND_API.G_FALSE
         );

    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK to UPDATE_DEL_DETAIL_GRP;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED := 'Y';
                WSH_WMS_LPN_GRP.g_update_to_container := 'N';
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );
                  --

                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
                  END IF;
                  --
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              IF lock_delivery_details%isopen THEN
                 CLOSE lock_delivery_details;
              END IF;
                ROLLBACK to UPDATE_DEL_DETAIL_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED := 'Y';
                WSH_WMS_LPN_GRP.g_update_to_container := 'N';
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );
                  --
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
                  END IF;
                  --
        WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
              IF lock_delivery_details%isopen THEN
                 CLOSE lock_delivery_details;
              END IF;
             x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
             --
             -- K LPN CONV. rv
             --
             IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
             THEN
             --{
                 IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;

                 WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                   (
                     p_in_rec             => l_in_rec,
                     x_return_status      => l_return_status,
                     x_out_rec            => l_out_rec
                   );
                 --
                 --
                 IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
                 END IF;
                 --
                 --
                 IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR) and x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                   x_return_status := l_return_status;
                 END IF;
                 --
             --}
             END IF;
             --
             -- K LPN CONV. rv
             --
                WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED := 'Y';
                WSH_WMS_LPN_GRP.g_update_to_container := 'N';
             FND_MSG_PUB.Count_And_Get
              (
                p_count  => x_msg_count,
                p_data  =>  x_msg_data,
                p_encoded => FND_API.G_FALSE
              );
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
       END IF;
--
        WHEN delivery_detail_locked THEN
              IF lock_delivery_details%isopen THEN
                 CLOSE lock_delivery_details;
              END IF;
              --
              -- K LPN CONV. rv
              --
              IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
              THEN
              --{
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;

                  WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                    (
                      p_in_rec             => l_in_rec,
                      x_return_status      => l_return_status,
                      x_out_rec            => l_out_rec
                    );
                  --
                  --
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
                  END IF;
                  --
                  --
                  IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR) and x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                    x_return_status := l_return_status;
                  END IF;
                  --
              --}
              END IF;
              --
              -- K LPN CONV. rv
              --
                WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED := 'Y';
                WSH_WMS_LPN_GRP.g_update_to_container := 'N';
              l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              FND_MESSAGE.Set_Name('WSH', 'WSH_NO_LOCK');
              wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
             IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:delivery_detail_locked');
             END IF;

        WHEN OTHERS THEN
              IF lock_delivery_details%isopen THEN
                 CLOSE lock_delivery_details;
              END IF;

                ROLLBACK to UPDATE_DEL_DETAIL_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED := 'Y';
                WSH_WMS_LPN_GRP.g_update_to_container := 'N';
               wsh_util_core.add_message(x_return_status, l_module_name);
               WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_GRP.Update_Delivery_Detail');

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
    END Update_Delivery_Detail;




    -- ---------------------------------------------------------------------
    -- Procedure: Cancel_Delivery_Detail
    --
    -- Parameters:
    --
    -- Description:  This local procedure is the new API for wrapping the logic of CANCEL of delivery details
    -- Created:   Harmonization Project. Patchset I
    -- -----------------------------------------------------------------------

    PROCEDURE  Cancel_Delivery_Detail(
                p_detail_info_tab     IN  WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type ,
                x_return_status       OUT NOCOPY      VARCHAR2,
                x_msg_count           OUT NOCOPY      NUMBER,
                x_msg_data            OUT NOCOPY      VARCHAR2,
                p_caller              IN              VARCHAR2 DEFAULT NULL)
      IS

        l_api_name              CONSTANT VARCHAR2(30)   := 'Cancel_Delivery_Detail';
        l_api_version           CONSTANT NUMBER         := 1.0;
        --
  --
  l_return_status             VARCHAR2(32767);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(32767);
  l_program_name              VARCHAR2(32767);
        --
  l_number_of_errors    NUMBER := 0;
  l_number_of_warnings  NUMBER := 0;
  --
        l_index                  NUMBER;

  --jckwok
  l_changed_attr_tab      wsh_interface.ChangedAttributeTabType;

  --
  l_debug_on BOOLEAN;
  --
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CANCEL_DELIVERY_DETAIL';



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
        SAVEPOINT CANCEL_DEL_DETAIL_GRP;
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
        END IF;
        --

  --  Initialize API return status to success
  x_return_status       := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_number_of_errors := 0;
  l_number_of_warnings := 0;


      l_index := p_detail_info_tab.FIRST;
      WHILE l_index IS NOT NULL
  LOOP
   l_changed_attr_tab(l_index).action_flag         :=  'U';
   l_changed_attr_tab(l_index).source_code         :=  p_detail_info_tab(l_index).source_code;
         l_changed_attr_tab(l_index).container_flag                        :=  p_detail_info_tab(l_index).container_flag;
   l_changed_attr_tab(l_index).delivery_detail_id                    :=   p_detail_info_tab(l_index).delivery_detail_id;
   l_changed_attr_tab(l_index).ordered_quantity                      :=   0 ;
   l_changed_attr_tab(l_index).order_quantity_uom                  :=   p_detail_info_tab(l_index).requested_quantity_uom;
         l_changed_attr_tab(l_index).source_line_id                        :=   p_detail_info_tab(l_index).source_line_id;
   l_index := p_detail_info_tab.NEXT(l_index);
  END LOOP;


       --
       IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTERFACE.Update_Shipping_Attributes',WSH_DEBUG_SV.C_PROC_LEVEL);
                WSH_DEBUG_SV.log(l_module_name, 'l_changed_attr_tab.count', l_changed_attr_tab.count);
                WSH_DEBUG_SV.log(l_module_name, 'Delivery Detail Id', l_changed_attr_tab(1).delivery_detail_id);

                WSH_DEBUG_SV.log(l_module_name, 'Ordered Quantity ', l_changed_attr_tab(1).ordered_quantity);
                WSH_DEBUG_SV.log(l_module_name, 'Ord qty uom ', l_changed_attr_tab(1).order_quantity_uom);
                WSH_DEBUG_SV.log(l_module_name, 'Source Line Id', l_changed_attr_tab(1).Source_Line_id);
                wsh_debug_sv.log(l_module_name, 'Source_Code', p_detail_info_tab(1).source_code);
       END IF;
       --



       WSH_INTERFACE.Update_Shipping_Attributes(
    p_source_code            =>  'WSH',
                p_changed_attributes  => l_changed_attr_tab,
    x_return_status          => l_return_status
       );

                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;
                  --
      --
                  wsh_util_core.api_post_call(
                      p_return_status => l_return_status,
                      x_num_warnings  => l_number_of_warnings,
                      x_num_errors    => l_number_of_errors,
                      p_msg_data      => l_msg_data
                      );

      --

                  IF l_number_of_warnings > 0 THEN
                        IF l_debug_on THEN
                               wsh_debug_sv.log(l_module_name, 'Number of warnings', l_number_of_warnings);
                        END IF;

                        RAISE wsh_util_core.g_exc_warning;
                  END IF;



       FND_MSG_PUB.Count_And_Get
         (
          p_count  => x_msg_count,
          p_data  =>  x_msg_data,
          p_encoded => FND_API.G_FALSE
         );

    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --



--
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK to CANCEL_DEL_DETAIL_GRP;
                x_return_status := FND_API.G_RET_STS_ERROR ;
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
                ROLLBACK to CANCEL_DEL_DETAIL_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE
                  );

                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
                  END IF;
                  --
        WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
             x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
             FND_MSG_PUB.Count_And_Get
              (
                p_count  => x_msg_count,
                p_data  =>  x_msg_data,
                p_encoded => FND_API.G_FALSE
              );
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
        END IF;
--
        WHEN OTHERS THEN

                ROLLBACK to CANCEL_DEL_DETAIL_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                wsh_util_core.add_message(x_return_status, l_module_name);
                WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_GRP.Delete_Delivery_Detail');
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






END Cancel_Delivery_Detail;





    -- ---------------------------------------------------------------------
    -- Procedure: Validate_Detail_Line
    --
    -- Parameters:
    --
    -- Description:  This local procedure is the new API for wrapping the logic of VALIDATE of Non Containers
    -- Created:   Harmonization Project. Patchset I
    -- -----------------------------------------------------------------------
/*
   PLEASE READ BEFORE CHANGING THIS PROCEDURE
   For inbound lines, this procedure returns back to caller, right at the beginning.
   If you are adding any validation, which may be applicable for inbound line as well, please
   evaluate against that.
*/
PROCEDURE validate_detail_line(
   x_detail_rec          IN OUT NOCOPY   WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
   p_in_detail_rec       IN              WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
   p_original_rec        IN              c_original_detail_cur%ROWTYPE,
   p_validation_tab      IN              wsh_util_core.id_tab_type,
   x_mark_reprice_flag   OUT NOCOPY      VARCHAR2,
   x_return_status       OUT NOCOPY      VARCHAR2,
   x_msg_count           OUT NOCOPY      NUMBER,
   x_msg_data            OUT NOCOPY      VARCHAR2,
   p_in_rec              IN              WSH_GLBL_VAR_STRCT_GRP.detailInRecType,
   p_serial_range_tab    IN              WSH_GLBL_VAR_STRCT_GRP.ddSerialRangeTabType
) IS
   l_api_name           CONSTANT VARCHAR2(30) := 'Validate_Detail_Line';
   l_api_version        CONSTANT NUMBER := 1.0;
   --
   l_return_status               VARCHAR2(32767);
   l_msg_count                   NUMBER;
   l_msg_data                    VARCHAR2(32767);
   l_program_name                VARCHAR2(32767);
   --
   l_number_of_errors            NUMBER := 0;
   l_number_of_warnings          NUMBER := 0;
   --
   l_org_id                      NUMBER;                     /***Bug 1813496*/
   l_subinventory                VARCHAR2(30);               /***Bug 1813496*/
   l_locator                     NUMBER;                     /***Bug 1813496*/
   l_revision                    VARCHAR2(30);
              /***Bug 1813496*/
-- HW OPMCONV - Increased length to 80
   l_lot                         VARCHAR2(80);
   l_result                      BOOLEAN;
   l_quantity                    NUMBER;
   l_inv_controls                wsh_delivery_details_inv.inv_control_flag_rec;
   l_ship_method_name            VARCHAR2(32767);
-- HW Harmonization project for OPM. Added l_process flag variable
-- HW OPMCONV - Removed OPM variables

   l_det_qty_rec                 wsh_details_validations.validatequantityattrrectype;
   -- Bug fix  1578114
   l_transaction_id              NUMBER;
   l_prefix                      VARCHAR2(240);
   v1                            NUMBER;
   v2                            DATE;
   v3                            NUMBER;
   v4                            DATE;
   v5                            NUMBER;
   v6                            NUMBER;
   v7                            NUMBER;
   v8                            NUMBER;
   v9                            NUMBER;
   v10                           DATE;
   v11                           VARCHAR2(30);
-- HW OPMCONV - Increased to 80 to hold lot_number
   v12                           VARCHAR2(80);
   v13                           VARCHAR2(30);
   v14                           VARCHAR2(30);
   v15                           VARCHAR2(30);
   v16                           VARCHAR2(30);
   v17                           NUMBER;
   v18                           VARCHAR2(30);
   v19                           VARCHAR2(30);
   v20                           VARCHAR2(150);
   v21                           VARCHAR2(150);
   v22                           VARCHAR2(150);
   v23                           VARCHAR2(150);
   v24                           VARCHAR2(150);
   v25                           VARCHAR2(150);
   v26                           VARCHAR2(150);
   v27                           VARCHAR2(150);
   v28                           VARCHAR2(150);
   v29                           VARCHAR2(150);
   v30                           VARCHAR2(150);
   v31                           VARCHAR2(150);
   v32                           VARCHAR2(150);
   v33                           VARCHAR2(150);
   v34                           VARCHAR2(150);
   v35                           VARCHAR2(3);
   l_index                       NUMBER;
   l_det_index                   NUMBER;
   l_detail_ser_count            NUMBER;
   l_detail_ser_qty              NUMBER;
   l_det_ser_range_tab           WSH_GLBL_VAR_STRCT_GRP.ddSerialRangeTabType;
   l_update_attributes           BOOLEAN;
   l_stamp_ser_wdd               BOOLEAN; -- frontport bug 5055682

   -- bug 4766908
   l_reservable_flag        VARCHAR2(1);
   -- end bug 4766908
   l_trx_type_id                 NUMBER;
   CURSOR get_group_mark_id (v_serial_number IN VARCHAR2, v_item_id IN NUMBER) IS
   SELECT group_mark_id
   FROM mtl_serial_numbers
   WHERE serial_number = v_serial_number
   AND inventory_item_id = v_item_id;
   --
   l_debug_on                    BOOLEAN;
   --
   l_module_name        CONSTANT VARCHAR2(100)
               := 'wsh.plsql.' || g_pkg_name || '.' || 'VALIDATE_DETAIL_LINE';
--
BEGIN
   --
   l_debug_on := wsh_debug_interface.g_debug;

   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;

   --
   SAVEPOINT validate_det_line_grp;

   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.LOG(l_module_name, 'Delivery Detail Id', x_detail_rec.delivery_detail_id);
      WSH_DEBUG_SV.LOG(l_module_name, 'Serial table count', p_serial_range_tab.COUNT);
      WSH_DEBUG_SV.LOG(l_module_name, 'SQ', x_detail_rec.shipped_quantity);
   END IF;

   --  Initialize API return status to success --
   x_return_status := wsh_util_core.g_ret_sts_success;
   l_number_of_errors := 0;
   l_number_of_warnings := 0;

   --
   -- J-IB-NPARIKH-{
   IF NVL(x_detail_rec.line_direction,'O') NOT IN ('O','IO')
   THEN
   --{
        --
        -- None of the validations are applicable for inbound lines. So, return
        --
        IF l_debug_on
        THEN
            wsh_debug_sv.pop(l_module_name);
        END IF;
        --
        RETURN;
   --}
   END IF;
   -- J-IB-NPARIKH-}
   --

-- HW Harmonization project for OPM. Need to check if org is discrete or process
-- HW OPMCONV - Removed checking for process org

   IF (p_validation_tab(wsh_actions_levels.c_tol_above_lvl) = 1) THEN
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Ship Tolerance Above', x_detail_rec.ship_tolerance_above);
         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_NEGATIVE',
            WSH_DEBUG_SV.c_proc_level);
      END IF;

  --Bug # 3266333
      wsh_util_validate.validate_negative(
         p_value          =>  x_detail_rec.ship_tolerance_above,
	 p_field_name     => 'ship_tolerance_above',
	 x_return_status  => l_return_status );
  --

      wsh_util_core.api_post_call(
         p_return_status      => l_return_status,
         x_num_warnings       => l_number_of_warnings,
         x_num_errors         => l_number_of_errors,
         p_msg_data           => l_msg_data
      );
   END IF;

   IF (p_validation_tab(wsh_actions_levels.c_tol_below_lvl) = 1) THEN
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Ship Tolerance Below', x_detail_rec.ship_tolerance_below);
         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_NEGATIVE',WSH_DEBUG_SV.c_proc_level);
      END IF;

  --Bug # 3266333
      wsh_util_validate.validate_negative(
         p_value          =>  x_detail_rec.ship_tolerance_below,
	 p_field_name     => 'ship_tolerance_below',
	 x_return_status  => l_return_status );
  --

      wsh_util_core.api_post_call(
         p_return_status      => l_return_status,
         x_num_warnings       => l_number_of_warnings,
         x_num_errors         => l_number_of_errors,
         p_msg_data           => l_msg_data
      );
   END IF;

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_detail_rec.org_id', x_detail_rec.org_id);
      WSH_DEBUG_SV.log(l_module_name, 'x_detail_rec.locator_id', x_detail_rec.locator_id);
      WSH_DEBUG_SV.log(l_module_name, 'x_detail_rec.revision', x_detail_rec.revision);
      WSH_DEBUG_SV.log(l_module_name, 'x_detail_rec.subinventory', x_detail_rec.subinventory);
      WSH_DEBUG_SV.log(l_module_name, 'x_detail_rec.lot_number', x_detail_rec.lot_number);
   END IF;

   l_org_id := p_original_rec.organization_id;

   /***************Material Status Impact***********/
   WSH_DELIVERY_DETAILS_INV.get_trx_type_id(
     p_source_line_id => p_in_detail_rec.source_line_id,
     p_source_code    => p_in_detail_rec.source_code,
     x_transaction_type_id    => l_trx_type_id,
     x_return_status  => l_return_status);
   --
   wsh_util_core.api_post_call(
     p_return_status      => l_return_status,
     x_num_warnings       => l_number_of_warnings,
     x_num_errors         => l_number_of_errors,
     p_msg_data           => l_msg_data);
   /***************Material Status Impact***********/

   IF x_detail_rec.locator_id <> fnd_api.g_miss_num THEN
      l_locator := x_detail_rec.locator_id;
   -- Modified Else condition for bug 4399278, 4418754
   ELSIF ( x_detail_rec.subinventory = p_original_rec.subinventory ) THEN
      l_locator := p_original_rec.locator_id;
   END IF;

   IF x_detail_rec.revision <> fnd_api.g_miss_char THEN
      l_revision := x_detail_rec.revision;
   ELSE
      l_revision := p_original_rec.revision;
   END IF;

   IF x_detail_rec.subinventory <> fnd_api.g_miss_char THEN
      l_subinventory := x_detail_rec.subinventory;
   ELSE
      l_subinventory := p_original_rec.subinventory;
   END IF;

   IF x_detail_rec.lot_number <> fnd_api.g_miss_char THEN
      l_lot := x_detail_rec.lot_number;
   ELSE
      l_lot := p_original_rec.lot_number;
   END IF;

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'l_org_id', l_org_id);
      WSH_DEBUG_SV.log(l_module_name, 'l_locator', l_locator);
      WSH_DEBUG_SV.log(l_module_name, 'l_revision', l_revision);
      WSH_DEBUG_SV.log(l_module_name, 'l_subinventory', l_subinventory);
      WSH_DEBUG_SV.log(l_module_name, 'l_lot_number', l_lot);
   END IF;

   -- UT bug fix 2657367
   IF    p_validation_tab(wsh_actions_levels.c_ship_qty_lvl) = 1
      OR p_validation_tab(wsh_actions_levels.c_revision_lvl) = 1
      OR p_validation_tab(wsh_actions_levels.c_locator_lvl) = 1
      OR p_validation_tab(wsh_actions_levels.c_lot_number_lvl) = 1
      OR p_validation_tab(wsh_actions_levels.c_serial_num_lvl) = 1
   THEN
   --(
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_DELIVERY_DETAILS_INV.FETCH_INV_CONTROLS', WSH_DEBUG_SV.c_proc_level);
      END IF;

      wsh_delivery_details_inv.fetch_inv_controls(
         p_delivery_detail_id      => x_detail_rec.delivery_detail_id,
         p_inventory_item_id       => p_original_rec.inventory_item_id,
         p_organization_id         => l_org_id,
         p_subinventory            => l_subinventory,
         x_inv_controls_rec        => l_inv_controls,
         x_return_status           => l_return_status
      );

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Return Status', l_return_status);
         WSH_DEBUG_SV.log(l_module_name, 'Lot Flag', l_inv_controls.lot_flag);
         WSH_DEBUG_SV.log(l_module_name, 'Revision Flag', l_inv_controls.rev_flag);
         WSH_DEBUG_SV.log(l_module_name, 'Locator Flag', l_inv_controls.loc_flag);
         WSH_DEBUG_SV.log(l_module_name, 'Serial Control Code', l_inv_controls.serial_code);
      END IF;

      wsh_util_core.api_post_call(
         p_return_status      => l_return_status,
         x_num_warnings       => l_number_of_warnings,
         x_num_errors         => l_number_of_errors,
         p_msg_data           => l_msg_data
      );
   --)
   END IF;

   -- UT bug fix 2657367

   IF (p_validation_tab(wsh_actions_levels.c_ship_qty_lvl) = 1) THEN
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Shipped Qty', x_detail_rec.shipped_quantity);
         WSH_DEBUG_SV.log(l_module_name, 'Existing Shipped Qty', p_original_rec.shipped_quantity);
      END IF;
      -- BugFix 4519867: Validate shipped qty only when it's not equal to fnd_api.g_miss_num.
      IF ((p_in_detail_rec.shipped_quantity IS NULL )
          OR (p_in_detail_rec.shipped_quantity <> fnd_api.g_miss_num))
      THEN
              l_det_qty_rec.delivery_detail_id := x_detail_rec.delivery_detail_id;
              l_det_qty_rec.requested_quantity := x_detail_rec.requested_quantity;
              l_det_qty_rec.requested_quantity2 := x_detail_rec.requested_quantity2;
              l_det_qty_rec.picked_quantity := x_detail_rec.picked_quantity;
              l_det_qty_rec.picked_quantity2 := x_detail_rec.picked_quantity2;
              l_det_qty_rec.shipped_quantity := x_detail_rec.shipped_quantity;
              l_det_qty_rec.shipped_quantity2 := x_detail_rec.shipped_quantity2;
              l_det_qty_rec.cycle_count_quantity := x_detail_rec.cycle_count_quantity;
              l_det_qty_rec.cycle_count_quantity2 :=
                                                    x_detail_rec.cycle_count_quantity2;
              l_det_qty_rec.requested_quantity_uom :=
                                                   x_detail_rec.requested_quantity_uom;
              l_det_qty_rec.requested_quantity_uom2 :=
                                                  x_detail_rec.requested_quantity_uom2;
              l_det_qty_rec.ship_tolerance_above := x_detail_rec.ship_tolerance_above;
              l_det_qty_rec.inventory_item_id := x_detail_rec.inventory_item_id;
              l_det_qty_rec.organization_id := x_detail_rec.organization_id;
              l_det_qty_rec.serial_number := p_original_rec.serial_number;
              l_det_qty_rec.transaction_temp_id := p_original_rec.transaction_temp_id; -- Bug fix 2652300
              l_det_qty_rec.top_model_line_id := p_original_rec.top_model_line_id; -- Bug fix 2652300
              l_det_qty_rec.inv_ser_control_code := l_inv_controls.serial_code;               -- Bug fix 2652300
        -- HW Harmonization for OPM. Use l_process_flag
        -- HW OPMCONV - Removed checking for process org and population of
        -- process org variable

                get_serial_quantity(
                 p_transaction_temp_id      => p_original_rec.transaction_temp_id,
                 p_serial_number            => p_original_rec.serial_number,
                 p_to_serial_number         => p_original_rec.to_serial_number,
                 p_shipped_quantity         => x_detail_rec.shipped_quantity,
                 x_serial_qty               => l_det_qty_rec.serial_quantity,
                 x_return_status            => l_return_status
                 );

                IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name, 'get serial qty status', l_return_status);
                   WSH_DEBUG_SV.log(l_module_name, 'Serial qty', l_det_qty_rec.serial_quantity);
                   WSH_DEBUG_SV.log(l_module_name, 'Serial Number', l_det_qty_rec.serial_number);
                   WSH_DEBUG_SV.log(l_module_name, 'Trans temp id', l_det_qty_rec.transaction_temp_id);
                   WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_DETAILS_VALIDATIONS.VALIDATE_SHIPPED_CC_QUANTITY', WSH_DEBUG_SV.c_proc_level);
                END IF;

              --
              wsh_details_validations.validate_shipped_cc_quantity(
                 p_flag               => 'SQ',
                 x_det_rec            => l_det_qty_rec,
                 x_return_status      => l_return_status,
                 x_msg_count          => l_msg_count,
                 x_msg_data           => l_msg_data
              );
              x_detail_rec.shipped_quantity := l_det_qty_rec.shipped_quantity;
              -- x_detail_rec.cycle_count_quantity := l_det_qty_rec.cycle_count_quantity;

              -- Bug 5466481: First consider the passed cycle count qty,
              -- If it is not passed then take the system calculated value.
              IF (p_in_detail_rec.cycle_count_quantity = fnd_api.g_miss_num) THEN
              --{
                x_detail_rec.cycle_count_quantity := l_det_qty_rec.cycle_count_quantity;
              ELSE
                x_detail_rec.cycle_count_quantity := p_in_detail_rec.cycle_count_quantity;
              --}
              END IF;

              --
              wsh_util_core.api_post_call(
                 p_return_status      => l_return_status,
                 x_num_warnings       => l_number_of_warnings,
                 x_num_errors         => l_number_of_errors,
                 p_msg_data           => l_msg_data
              );
      END IF; -- End of code BugFix 4519867
   END IF;

-- HW Harmonization project for OPM.
-- HW OPMCONV - Removed checking for process_flag

      IF (p_validation_tab(wsh_actions_levels.c_ship_qty2_lvl) = 1) THEN
         IF (x_detail_rec.shipped_quantity2 <> fnd_api.g_miss_num) THEN
            l_det_qty_rec.delivery_detail_id :=
                                              x_detail_rec.delivery_detail_id;
            l_det_qty_rec.requested_quantity :=
                                              x_detail_rec.requested_quantity;
            l_det_qty_rec.requested_quantity2 :=
                                             x_detail_rec.requested_quantity2;
            l_det_qty_rec.picked_quantity := x_detail_rec.picked_quantity;
            l_det_qty_rec.picked_quantity2 := x_detail_rec.picked_quantity2;
            l_det_qty_rec.shipped_quantity := x_detail_rec.shipped_quantity;
            l_det_qty_rec.shipped_quantity2 := x_detail_rec.shipped_quantity2;
            l_det_qty_rec.cycle_count_quantity :=
                                            x_detail_rec.cycle_count_quantity;
            l_det_qty_rec.cycle_count_quantity2 :=
                                           x_detail_rec.cycle_count_quantity2;
            l_det_qty_rec.requested_quantity_uom :=
                                          x_detail_rec.requested_quantity_uom;
            l_det_qty_rec.requested_quantity_uom2 :=
                                         x_detail_rec.requested_quantity_uom2;
            l_det_qty_rec.ship_tolerance_above :=
                                            x_detail_rec.ship_tolerance_above;
            l_det_qty_rec.inventory_item_id := x_detail_rec.inventory_item_id;
            l_det_qty_rec.organization_id := x_detail_rec.organization_id;
            l_det_qty_rec.serial_number := x_detail_rec.serial_number;
            l_det_qty_rec.transaction_temp_id :=
                                             x_detail_rec.transaction_temp_id;
            l_det_qty_rec.top_model_line_id := x_detail_rec.top_model_line_id;
-- HW use l_process_flag
-- HW OPMCONV - Removed population of  process_flag

            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_DETAILS_VALIDATIONS.VALIDATE_SHIPPED_CC_QUANTITY2', WSH_DEBUG_SV.c_proc_level);
            END IF;

            --

            wsh_details_validations.validate_shipped_cc_quantity2(
               p_flag               => 'SQ',
               x_det_rec            => l_det_qty_rec,
               x_return_status      => l_return_status,
               x_msg_count          => l_msg_count,
               x_msg_data           => l_msg_data
            );
            x_detail_rec.shipped_quantity2 := l_det_qty_rec.shipped_quantity2;
            --PK added for Bug 3055126 Next line.
            x_detail_rec.cycle_count_quantity2 := l_det_qty_rec.cycle_count_quantity2;
            --
            wsh_util_core.api_post_call(
               p_return_status      => l_return_status,
               x_num_warnings       => l_number_of_warnings,
               x_num_errors         => l_number_of_errors,
               p_msg_data           => l_msg_data
            );
         END IF; -- of shipped_quantity2
      END IF; -- of C_SHIP_QTY2_LVL

-- HW OPM end of changes

   IF (p_validation_tab(wsh_actions_levels.c_cc_qty_lvl) = 1) THEN
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Cycle_Count Qty', x_detail_rec.cycle_count_quantity);
         WSH_DEBUG_SV.log(l_module_name, 'Existing Cycle_Count Qty', p_original_rec.cycle_count_quantity);
      END IF;
      -- BugFix 4519867: Validate cycle count qty only when it's not equal to fnd_api.g_miss_num.
      IF ( (p_in_detail_rec.cycle_count_quantity IS NULL)
         OR (p_in_detail_rec.cycle_count_quantity <> fnd_api.g_miss_num))
      THEN
              l_det_qty_rec.delivery_detail_id := x_detail_rec.delivery_detail_id;
              l_det_qty_rec.requested_quantity := x_detail_rec.requested_quantity;
              l_det_qty_rec.requested_quantity2 := x_detail_rec.requested_quantity2;
              l_det_qty_rec.picked_quantity := x_detail_rec.picked_quantity;
              l_det_qty_rec.picked_quantity2 := x_detail_rec.picked_quantity2;
              l_det_qty_rec.shipped_quantity := x_detail_rec.shipped_quantity;
              l_det_qty_rec.shipped_quantity2 := x_detail_rec.shipped_quantity2;
              l_det_qty_rec.cycle_count_quantity := x_detail_rec.cycle_count_quantity;
              l_det_qty_rec.cycle_count_quantity2 :=
                                                    x_detail_rec.cycle_count_quantity2;
              l_det_qty_rec.requested_quantity_uom :=
                                                   x_detail_rec.requested_quantity_uom;
              l_det_qty_rec.requested_quantity_uom2 :=
                                                  x_detail_rec.requested_quantity_uom2;
              l_det_qty_rec.ship_tolerance_above := x_detail_rec.ship_tolerance_above;
              l_det_qty_rec.inventory_item_id := x_detail_rec.inventory_item_id;
              l_det_qty_rec.organization_id := x_detail_rec.organization_id;
              l_det_qty_rec.serial_number := x_detail_rec.serial_number;
              l_det_qty_rec.transaction_temp_id := x_detail_rec.transaction_temp_id;
              l_det_qty_rec.top_model_line_id := x_detail_rec.top_model_line_id;
        -- HW Harmonization project for OPM.Use l_process_flag
        -- HW OPMCONV - Removed populatation of process_flag

              --
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_DETAILS_VALIDATIONS.VALIDATE_SHIPPED_CC_QUANTITY', WSH_DEBUG_SV.c_proc_level);
              END IF;

              --
              wsh_details_validations.validate_shipped_cc_quantity(
                 p_flag               => 'CCQ',
                 x_det_rec            => l_det_qty_rec,
                 x_return_status      => l_return_status,
                 x_msg_count          => l_msg_count,
                 x_msg_data           => l_msg_data
              );
              x_detail_rec.cycle_count_quantity := l_det_qty_rec.cycle_count_quantity;

              --
              wsh_util_core.api_post_call(
                 p_return_status      => l_return_status,
                 x_num_warnings       => l_number_of_warnings,
                 x_num_errors         => l_number_of_errors,
                 p_msg_data           => l_msg_data
              );
      END IF; -- BugFix 4519867
   END IF;

-- HW Harmonization project for OPM. Added cycle_count_qty2
-- HW OPMCONV - Removed checking for process_flag

      IF (p_validation_tab(wsh_actions_levels.c_cc_qty2_lvl) = 1) THEN
         IF (x_detail_rec.cycle_count_quantity2 <> fnd_api.g_miss_num) THEN
            l_det_qty_rec.delivery_detail_id :=
                                              x_detail_rec.delivery_detail_id;
            l_det_qty_rec.requested_quantity :=
                                              x_detail_rec.requested_quantity;
            l_det_qty_rec.requested_quantity2 :=
                                             x_detail_rec.requested_quantity2;
            l_det_qty_rec.picked_quantity := x_detail_rec.picked_quantity;
            l_det_qty_rec.picked_quantity2 := x_detail_rec.picked_quantity2;
            l_det_qty_rec.shipped_quantity := x_detail_rec.shipped_quantity;
            l_det_qty_rec.shipped_quantity2 := x_detail_rec.shipped_quantity2;
            l_det_qty_rec.cycle_count_quantity :=
                                            x_detail_rec.cycle_count_quantity;
            l_det_qty_rec.cycle_count_quantity2 :=
                                           x_detail_rec.cycle_count_quantity2;
            l_det_qty_rec.requested_quantity_uom :=
                                          x_detail_rec.requested_quantity_uom;
            l_det_qty_rec.requested_quantity_uom2 :=
                                         x_detail_rec.requested_quantity_uom2;
            l_det_qty_rec.ship_tolerance_above :=
                                            x_detail_rec.ship_tolerance_above;
            l_det_qty_rec.inventory_item_id := x_detail_rec.inventory_item_id;
            l_det_qty_rec.organization_id := x_detail_rec.organization_id;
            l_det_qty_rec.serial_number := x_detail_rec.serial_number;
            l_det_qty_rec.transaction_temp_id :=
                                             x_detail_rec.transaction_temp_id;
            l_det_qty_rec.top_model_line_id := x_detail_rec.top_model_line_id;
-- HW Harmonization project for OPM. Use l_process_flag
-- HW OPMCONV - Removed population of process_flag

            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_DETAILS_VALIDATIONS.VALIDATE_SHIPPED_CC_QUANTITY2', WSH_DEBUG_SV.c_proc_level);
            END IF;

            --
            wsh_details_validations.validate_shipped_cc_quantity2(
               p_flag               => 'CCQ',
               x_det_rec            => l_det_qty_rec,
               x_return_status      => l_return_status,
               x_msg_count          => l_msg_count,
               x_msg_data           => l_msg_data
            );
            x_detail_rec.cycle_count_quantity2 :=
                                           l_det_qty_rec.cycle_count_quantity2;
            --
            wsh_util_core.api_post_call(
               p_return_status      => l_return_status,
               x_num_warnings       => l_number_of_warnings,
               x_num_errors         => l_number_of_errors,
               p_msg_data           => l_msg_data
            );
         END IF; -- of cycle_count_quantity2
      END IF; -- of C_CC_QTY2_LVL

-- HW OPM end of changes

   IF (p_validation_tab(wsh_actions_levels.c_smc_lvl) = 1) THEN
      IF (x_detail_rec.ship_method_code <> fnd_api.g_miss_char) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Ship Method', x_detail_rec.ship_method_code);
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_SHIP_METHOD', WSH_DEBUG_SV.c_proc_level);
         END IF;

         --
         wsh_util_validate.validate_ship_method(
            p_ship_method_code => x_detail_rec.ship_method_code,
            p_ship_method_name      => l_ship_method_name,
            x_return_status         => l_return_status);
         --
         wsh_util_core.api_post_call(
            p_return_status      => l_return_status,
            x_num_warnings       => l_number_of_warnings,
            x_num_errors         => l_number_of_errors,
            p_msg_data           => l_msg_data
         );
      END IF;
   END IF;

   IF (p_validation_tab(wsh_actions_levels.c_dep_plan_lvl) = 1) THEN
      IF (x_detail_rec.dep_plan_required_flag <> fnd_api.g_miss_char) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Departure Plan Flag', x_detail_rec.dep_plan_required_flag);
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_BOOLEAN', WSH_DEBUG_SV.c_proc_level);
         END IF;

         --
         wsh_util_validate.validate_boolean(
            p_flag => x_detail_rec.dep_plan_required_flag,
            x_return_status      => l_return_status);
         --
         wsh_util_core.api_post_call(
            p_return_status      => l_return_status,
            x_num_warnings       => l_number_of_warnings,
            x_num_errors         => l_number_of_errors,
            p_msg_data           => l_msg_data
         );
      END IF;
   END IF;

   IF (p_validation_tab(wsh_actions_levels.c_ship_mod_comp_lvl) = 1) THEN
      IF (x_detail_rec.ship_model_complete_flag <> fnd_api.g_miss_char) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Ship Model Complete Flag', x_detail_rec.ship_model_complete_flag);
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_BOOLEAN', WSH_DEBUG_SV.c_proc_level);
         END IF;

         --
         wsh_util_validate.validate_boolean(
            p_flag => x_detail_rec.ship_model_complete_flag,
            x_return_status      => l_return_status);
         --
         wsh_util_core.api_post_call(
            p_return_status      => l_return_status,
            x_num_warnings       => l_number_of_warnings,
            x_num_errors         => l_number_of_errors,
            p_msg_data           => l_msg_data
         );
      END IF;
   END IF;

   IF (p_validation_tab(wsh_actions_levels.c_sub_inv_lvl) = 1) THEN
      IF (x_detail_rec.subinventory <> fnd_api.g_miss_char) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Subinventory', x_detail_rec.subinventory);
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_DELIVERY_DETAILS_INV.VALIDATE_SUBINVENTORY', WSH_DEBUG_SV.c_proc_level);
         END IF;

         --
         wsh_delivery_details_inv.validate_subinventory(
            p_subinventory           => x_detail_rec.subinventory,
            p_organization_id        => l_org_id,
            p_inventory_item_id      => p_original_rec.inventory_item_id,
	    p_transaction_type_id    => l_trx_type_id,
	    p_object_type            => 'A',
	    x_return_status          => l_return_status,
            x_result                 => l_result
         );
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Result after validate subinventory', l_result);
            WSH_DEBUG_SV.log(l_module_name, 'Return status after validate subinventory', l_return_status);
         END IF;

         IF NOT l_result THEN
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Invalid subinventory');
            END IF;

            l_return_status := wsh_util_core.g_ret_sts_error;
         END IF;

         wsh_util_core.api_post_call(
            p_return_status      => l_return_status,
            x_num_warnings       => l_number_of_warnings,
            x_num_errors         => l_number_of_errors,
            p_msg_data           => l_msg_data
         );
         x_mark_reprice_flag := 'Y';
      END IF;
   END IF;

   IF (p_validation_tab(wsh_actions_levels.c_revision_lvl) = 1)
   THEN
   -- {
      IF (x_detail_rec.revision <> fnd_api.g_miss_char)
      THEN
      -- {
         -- UT bug fix 2657367
         IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name, 'Pickable Flag', p_original_rec.pickable_flag);
            wsh_debug_sv.log(l_module_name, 'Rev Flag', l_inv_controls.rev_flag);
         END IF;
         --
         IF p_original_rec.pickable_flag = 'N'
         THEN
         -- {
             IF l_inv_controls.rev_flag = 'N'
                AND x_detail_rec.revision IS NOT NULL
             THEN
               l_number_of_errors := l_number_of_errors + 1;
               RAISE FND_API.G_EXC_ERROR;
             END IF;
         ELSE
             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name, 'Revision', x_detail_rec.revision);
               WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_DELIVERY_DETAILS_INV.VALIDATE_REVISION', WSH_DEBUG_SV.c_proc_level);
             END IF;

             wsh_delivery_details_inv.validate_revision(
               p_revision               => x_detail_rec.revision,
               p_organization_id        => l_org_id,
               p_inventory_item_id      => p_original_rec.inventory_item_id,
               x_return_status          => l_return_status,
               x_result                 => l_result
               );

         -- Bug fix   2657367. Need to check l_result
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Result after validate revision', l_result);
            WSH_DEBUG_SV.log(l_module_name, 'Return status after validate revision', l_return_status);
         END IF;

         IF NOT l_result THEN
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Invalid Revision');
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         wsh_util_core.api_post_call(
            p_return_status      => l_return_status,
            x_num_warnings       => l_number_of_warnings,
            x_num_errors         => l_number_of_errors,
            p_msg_data           => l_msg_data
         );
         -- }
         END IF;
      -- }
      END IF;
   -- }
   END IF;

   IF (p_validation_tab(wsh_actions_levels.c_locator_lvl) = 1) THEN
      IF (x_detail_rec.locator_id <> fnd_api.g_miss_num)
      THEN
      -- {
          -- UT bug fix 2657367
         IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name, 'Pickable Flag', p_original_rec.pickable_flag);
            wsh_debug_sv.log(l_module_name, 'Locator Flag', l_inv_controls.loc_flag);
         END IF;
         --
          IF  p_original_rec.pickable_flag  = 'N'
          THEN
          -- {
             IF l_inv_controls.loc_flag = 'N'
                AND x_detail_rec.locator_id IS NOT NULL
             THEN
                l_number_of_errors := l_number_of_errors + 1;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
          ELSE

             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'Locator Id', x_detail_rec.locator_id);
                WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_DELIVERY_DETAILS_INV.VALIDATE_LOCATOR', WSH_DEBUG_SV.c_proc_level);
            END IF;
            wsh_delivery_details_inv.validate_locator(
               p_locator_id             => x_detail_rec.locator_id,
               p_organization_id        => l_org_id,
               p_inventory_item_id      => p_original_rec.inventory_item_id,
               p_subinventory           => l_subinventory,
	       p_transaction_type_id    => l_trx_type_id,
	       p_object_type            => 'A',
               x_return_status          => l_return_status,
               x_result                 => l_result
               );

            -- Bug fix   2657367. Need to check l_result
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name, 'Result after validate locator', l_result);
               WSH_DEBUG_SV.log(l_module_name, 'Return status after validate locator', l_return_status);
            END IF;

            IF NOT l_result THEN
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name, 'Invalid Locator');
              END IF;

              RAISE fnd_api.g_exc_error;
            END IF;

            --
            wsh_util_core.api_post_call(
               p_return_status      => l_return_status,
               x_num_warnings       => l_number_of_warnings,
               x_num_errors         => l_number_of_errors,
               p_msg_data           => l_msg_data
               );
          -- }
          END IF;
      -- }
      END IF;
    END IF;

   IF (p_validation_tab(wsh_actions_levels.c_lot_number_lvl) = 1) THEN
      IF (x_detail_rec.lot_number <> fnd_api.g_miss_char) THEN
-- HW Harmonization project for OPM. Need to branch
-- HW OPMCONV - Removed branching

            -- UT bug fix 2657367
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name, 'Lot Number', x_detail_rec.lot_number);
                    wsh_debug_sv.log(l_module_name, 'Pickable Flag', p_original_rec.pickable_flag);
                    wsh_debug_sv.log(l_module_name, 'Lot Flag', l_inv_controls.lot_flag);
                 END IF;
                  --
                  IF nvl(p_original_rec.pickable_flag, 'N') = 'N'
                  THEN
                  -- {
                      IF l_inv_controls.lot_flag = 'N'
                         AND x_detail_rec.lot_number IS NOT NULL
                      THEN
                         -- For non-transactable items, lot number cannot be updated if item is not under lot control
                          l_number_of_errors := l_number_of_errors + 1;
                          RAISE FND_API.G_EXC_ERROR;
                     END IF;
                  ELSE
                    -- bug 4766908 get the reservable_flag
                    IF p_original_rec.released_status = 'Y' THEN
                      l_reservable_flag := WSH_DELIVERY_DETAILS_INV.get_reservable_flag(
                                               x_item_id         => p_original_rec.inventory_item_id,
                                               x_organization_id => p_original_rec.organization_id,
                                               x_pickable_flag   => p_original_rec.pickable_flag);
                    END IF;
                    IF (nvl(l_reservable_flag, 'Y') = 'Y') THEN
                      IF l_debug_on THEN
                         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_DELIVERY_DETAILS_INV.VALIDATE_LOT_NUMBER', WSH_DEBUG_SV.c_proc_level);
                      END IF;

                      wsh_delivery_details_inv.validate_lot_number(
                          p_lot_number             => x_detail_rec.lot_number,
                          p_organization_id        => l_org_id,
                          p_inventory_item_id      => p_original_rec.inventory_item_id,
                          p_revision               => l_revision,
                          p_subinventory           => l_subinventory,
                          p_locator_id             => l_locator,
	  	          p_transaction_type_id    => l_trx_type_id,
	                  p_object_type            => 'A',
                          x_return_status          => l_return_status,
                          x_result                 => l_result
                           );

                       -- Bug fix   2657367. Need to check l_result
                      IF l_debug_on THEN
                          WSH_DEBUG_SV.log(l_module_name, 'Result after validate lot', l_result);
                          WSH_DEBUG_SV.log(l_module_name, 'Return status after validate lot', l_return_status);
                      END IF;

                      IF NOT l_result THEN
                         IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name, 'Invalid Lot Number');
                         END IF;

                         RAISE fnd_api.g_exc_error;
                      END IF;
                    END IF;
                  -- }
                  END IF;
-- HW OPMCONV - Removed branching

-- HW OPM end of changes

         --
         wsh_util_core.api_post_call(
            p_return_status      => l_return_status,
            x_num_warnings       => l_number_of_warnings,
            x_num_errors         => l_number_of_errors,
            p_msg_data           => l_msg_data
         );
      END IF;
   END IF;

/* Since we are updating by delivery_detail, make sure source_line_id is populated */
   x_detail_rec.source_line_id := p_original_rec.source_line_id;

   IF (p_validation_tab(wsh_actions_levels.c_sold_contact_lvl) = 1) THEN
      IF (x_detail_rec.sold_to_contact_id <> fnd_api.g_miss_num) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Sold to Contact', x_detail_rec.sold_to_contact_id);
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_CONTACT', WSH_DEBUG_SV.c_proc_level);
         END IF;

         --
         wsh_util_validate.validate_contact(
            p_contact_id => x_detail_rec.sold_to_contact_id,
            x_return_status      => l_return_status);
         wsh_util_core.api_post_call(
            p_return_status      => l_return_status,
            x_num_warnings       => l_number_of_warnings,
            x_num_errors         => l_number_of_errors,
            p_msg_data           => l_msg_data
         );
      END IF;
   END IF;

   IF (p_validation_tab(wsh_actions_levels.c_ship_contact_lvl) = 1) THEN
      IF (x_detail_rec.ship_to_contact_id <> fnd_api.g_miss_num) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Ship to Contact Id', x_detail_rec.ship_to_contact_id);
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_CONTACT', WSH_DEBUG_SV.c_proc_level);
         END IF;

         --
         wsh_util_validate.validate_contact(
            p_contact_id => x_detail_rec.ship_to_contact_id,
            x_return_status      => l_return_status);
         --
         wsh_util_core.api_post_call(
            p_return_status      => l_return_status,
            x_num_warnings       => l_number_of_warnings,
            x_num_errors         => l_number_of_errors,
            p_msg_data           => l_msg_data
         );
      END IF;
   END IF;

   IF (p_validation_tab(wsh_actions_levels.c_deliver_contact_lvl) = 1) THEN
      IF (x_detail_rec.deliver_to_contact_id <> fnd_api.g_miss_num) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Deliver To Contact', x_detail_rec.deliver_to_contact_id);
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_CONTACT', WSH_DEBUG_SV.c_proc_level);
         END IF;

         --
         wsh_util_validate.validate_contact(
            p_contact_id => x_detail_rec.deliver_to_contact_id,
            x_return_status      => l_return_status);
         --
         wsh_util_core.api_post_call(
            p_return_status      => l_return_status,
            x_num_warnings       => l_number_of_warnings,
            x_num_errors         => l_number_of_errors,
            p_msg_data           => l_msg_data
         );
      END IF;
   END IF;

   IF (p_validation_tab(wsh_actions_levels.c_intmed_ship_contact_lvl) = 1) THEN
      IF (x_detail_rec.intmed_ship_to_contact_id <> fnd_api.g_miss_num) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Intmed Ship To Contact', x_detail_rec.intmed_ship_to_contact_id);
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_CONTACT', WSH_DEBUG_SV.c_proc_level);
         END IF;

         --
         wsh_util_validate.validate_contact(
            p_contact_id => x_detail_rec.intmed_ship_to_contact_id,
            x_return_status      => l_return_status);
         --
         wsh_util_core.api_post_call(
            p_return_status      => l_return_status,
            x_num_warnings       => l_number_of_warnings,
            x_num_errors         => l_number_of_errors,
            p_msg_data           => l_msg_data
         );
      END IF;
   END IF;

-- HW Harmonization project for OPM. This is applicable for discrete only
-- added a check for l_process_flag
   IF (p_validation_tab(wsh_actions_levels.c_serial_num_lvl) = 1) THEN
      l_detail_ser_count := 0;
      l_detail_ser_qty := 0;
      l_index := p_serial_range_tab.FIRST;
      l_det_index := 1;
      l_update_attributes := FALSE;
      l_stamp_ser_wdd     := FALSE;
      WHILE l_index IS NOT NULL LOOP
         IF p_serial_range_tab(l_index).delivery_detail_id =
                                              x_detail_rec.delivery_detail_id THEN


            l_det_ser_range_tab(l_det_index).delivery_detail_id := p_serial_range_tab(l_index).delivery_detail_id;
            l_det_ser_range_tab(l_det_index).from_serial_number := p_serial_range_tab(l_index).from_serial_number;

            -- If to_serial_number is null or is g_miss_char,
            -- then default it to from_serial_number
            IF ( p_serial_range_tab(l_index).to_serial_number IS NULL ) OR
               ( p_serial_range_tab(l_index).to_serial_number =
                                  fnd_api.g_miss_char ) THEN
                 l_det_ser_range_tab(l_det_index).to_serial_number
                           := p_serial_range_tab(l_index).from_serial_number;
            ELSE
                 l_det_ser_range_tab(l_det_index).to_serial_number
                           := p_serial_range_tab(l_index).to_serial_number;
            END IF;

            l_det_ser_range_tab(l_det_index).quantity           := p_serial_range_tab(l_index).quantity;

            l_detail_ser_qty := l_detail_ser_qty + p_serial_range_tab(l_index).quantity;
            -- Bug 3628620, populate msnt flexfield attributes if the from/to serial numbers
            -- are the same.
            IF NVL(l_det_ser_range_tab(l_det_index).to_serial_number, l_det_ser_range_tab(l_det_index).from_serial_number)  =
               l_det_ser_range_tab(l_det_index).from_serial_number
            THEN
               l_det_ser_range_tab(l_det_index).attribute_category := p_serial_range_tab(l_index).attribute_category;
               l_det_ser_range_tab(l_det_index).attribute1 := p_serial_range_tab(l_index).attribute1;
               l_det_ser_range_tab(l_det_index).attribute2 := p_serial_range_tab(l_index).attribute2;
               l_det_ser_range_tab(l_det_index).attribute3 := p_serial_range_tab(l_index).attribute3;
               l_det_ser_range_tab(l_det_index).attribute4 := p_serial_range_tab(l_index).attribute4;
               l_det_ser_range_tab(l_det_index).attribute5 := p_serial_range_tab(l_index).attribute5;
               l_det_ser_range_tab(l_det_index).attribute6 := p_serial_range_tab(l_index).attribute6;
               l_det_ser_range_tab(l_det_index).attribute7 := p_serial_range_tab(l_index).attribute7;
               l_det_ser_range_tab(l_det_index).attribute8 := p_serial_range_tab(l_index).attribute8;
               l_det_ser_range_tab(l_det_index).attribute9 := p_serial_range_tab(l_index).attribute9;
               l_det_ser_range_tab(l_det_index).attribute10 := p_serial_range_tab(l_index).attribute10;
               l_det_ser_range_tab(l_det_index).attribute11 := p_serial_range_tab(l_index).attribute11;
               l_det_ser_range_tab(l_det_index).attribute12 := p_serial_range_tab(l_index).attribute12;
               l_det_ser_range_tab(l_det_index).attribute13 := p_serial_range_tab(l_index).attribute13;
               l_det_ser_range_tab(l_det_index).attribute14 := p_serial_range_tab(l_index).attribute14;
               l_det_ser_range_tab(l_det_index).attribute15 := p_serial_range_tab(l_index).attribute15;
            END IF;
            l_det_index := l_det_index +1;
         END IF;

         l_index := p_serial_range_tab.NEXT(l_index);
      END LOOP;

      l_detail_ser_count := l_det_ser_range_tab.count;

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Current detail count', l_detail_ser_count);
         WSH_DEBUG_SV.log(l_module_name, 'Total serial qty in table', l_detail_ser_qty);
      END IF;

      IF l_detail_ser_count >= 1
      THEN
      -- (
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'input from serial number', p_in_detail_rec.serial_number);
            WSH_DEBUG_SV.log(l_module_name, 'input to_serial_number', p_in_detail_rec.to_serial_number);
         END IF;

         IF    (
                    p_in_detail_rec.serial_number IS NOT NULL
                AND p_in_detail_rec.serial_number <> fnd_api.g_miss_char
               )
            OR (
                    p_in_detail_rec.to_serial_number IS NOT NULL
                AND p_in_detail_rec.to_serial_number <> fnd_api.g_miss_char
               )
         THEN
         -- (
            -- Error case. Inputs should be mutually exclusive
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Serial number input not mutually exclusive');
            END IF;

            RAISE fnd_api.g_exc_error;
         -- )
         END IF;
      ELSIF l_detail_ser_count = 0
      THEN
         IF     p_in_detail_rec.serial_number IS NOT NULL
            AND p_in_detail_rec.serial_number <> fnd_api.g_miss_char
         THEN
         -- (
            l_det_ser_range_tab(1).delivery_detail_id := x_detail_rec.delivery_detail_id;
            l_det_ser_range_tab(1).from_serial_number := p_in_detail_rec.serial_number;

            IF p_in_detail_rec.to_serial_number <> fnd_api.g_miss_char
            THEN
            -- (
               l_det_ser_range_tab(1).to_serial_number := p_in_detail_rec.to_serial_number;
            -- )
            END IF;

            l_det_ser_range_tab(1).quantity := x_detail_rec.shipped_quantity;
            l_detail_ser_count := l_detail_ser_count + 1;
            l_detail_ser_qty := l_detail_ser_qty + x_detail_rec.shipped_quantity;

            -- If From and To Serial Number is same,
            -- then stamp serial number on wdd and do not
            -- generate transaction_temp_id
            IF l_det_ser_range_tab(1).from_serial_number
                      = NVL(l_det_ser_range_tab(1).to_serial_number,
                            l_det_ser_range_tab(1).from_serial_number) THEN
             IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'Stamp serial number on wdd');
             END IF;
             l_stamp_ser_wdd := TRUE;
            END IF;

         ELSE
            IF     p_in_detail_rec.to_serial_number IS NOT NULL
               AND p_in_detail_rec.to_serial_number <> fnd_api.g_miss_char
            THEN
            -- (
               -- To serial number cannot exist with a from serial number
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'From serial number is null');
               END IF;

               RAISE fnd_api.g_exc_error;
            -- )
            END IF;
         -- )
         END IF;
      -- )
      END IF;


      IF l_detail_ser_count >= 1
      THEN
      -- (
          --bug 4365589
          IF p_in_rec.caller = 'WSH_PUB'
             AND l_inv_controls.serial_code IN (2,5)
          THEN --{
             IF (wsh_util_validate.Check_Wms_Org(l_org_id)='Y') THEN --{
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name, 'Cannot modify the serial numbers for WMS organizationx ');
                 END IF;

                 RAISE fnd_api.g_exc_error;
             END IF; --}
          END IF;--}

            -- Check 1: When serial number is input, Released Status should be Y or X
            IF p_original_rec.released_status NOT IN('Y', 'X')
            THEN
            -- (
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'Released Status Not in X,Y');
               END IF;

               RAISE fnd_api.g_exc_error;
            -- )
            END IF;

          -- Check 2: When serial number is input, Shipped Qty should not be null or Zero. Bug 2652300
          IF nvl(x_detail_rec.shipped_quantity, nvl(p_original_rec.shipped_quantity,0)) = 0
          THEN
          -- (
              -- Bug 2652300. Cannot update serial number if shipped qty is null or zero
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name, 'Shipped qty zero or null. Not null serial number');
                 END IF;
                 raise FND_API.G_EXC_ERROR;
          ELSIF  nvl(x_detail_rec.shipped_quantity, nvl(p_original_rec.shipped_quantity,0)) > 1
          THEN
            -- Check 3: If shipped qty is greater than one,
            --          if table count is one, then to_serial_number should exist. Bug 2652319
              IF l_detail_ser_count = 1
                     AND l_det_ser_range_tab(l_det_ser_range_tab.first).to_serial_number IS NULL
              THEN
              -- (
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name, 'Shipped qty greater than one. No to_serial_number');
                 END IF;
                 raise FND_API.G_EXC_ERROR;
              -- )
              END IF;
          -- )
          END IF;

         -- Check 3: Sum of Serial number qty should not be greater than shipped qty
         IF l_detail_ser_qty > x_detail_rec.shipped_quantity
         THEN
         -- (
            -- Total quantity in serial table should not be greater than shipped qty
            -- Error case.
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Serial table qty greater than shipped qty');
            END IF;
            RAISE fnd_api.g_exc_error;
         ELSIF l_detail_ser_qty = 1
         THEN
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name, 'table from serial num', l_det_ser_range_tab(1).from_serial_number);
               WSH_DEBUG_SV.log(l_module_name, 'table to seral num', l_det_ser_range_tab(1).to_serial_number);
            END IF;

            IF l_det_ser_range_tab(1).from_serial_number IS NOT NULL
            THEN
            -- (
                  x_detail_rec.serial_number := l_det_ser_range_tab(1).from_serial_number;
            ELSE
               -- Record cannot exist without a from serial number
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'From serial number is null');
               END IF;

               RAISE fnd_api.g_exc_error;
            -- )
            END IF;
         ELSIF l_detail_ser_qty > 1
         THEN
            SELECT mtl_material_transactions_s.NEXTVAL
            INTO l_transaction_id
            FROM DUAL;
         END IF;

         -- Bug 3628620. We allow update of serial number attributes only if the
         -- serial number exists (implies shipped qty = 1) in wdd and the user is
         -- not attempting to change the serial number.
         -- If the transaction temp id exists in wdd, then the record exists in
         -- msnt, and the user can update msnt using the INV API.

         l_index := l_det_ser_range_tab.first;
         IF     l_det_ser_range_tab.count = 1
            AND l_det_ser_range_tab(l_index).quantity = 1 THEN
          --{
             IF l_det_ser_range_tab(l_index).from_serial_number =
                NVL(l_det_ser_range_tab(l_index).to_serial_number,
                    l_det_ser_range_tab(l_index).from_serial_number)
             AND (l_det_ser_range_tab(l_index).from_serial_number =
                    p_original_rec.serial_number) AND (NOT l_stamp_ser_wdd) THEN  --Bug 8858812
               --{
               -- We are not changing the serial number, we are only updating
               -- the serial number attributes.
               -- create new record in msnt using the group_mark_id from msn.
               -- Bug 4016863 : We generate a new transaction_temp_id and call
               -- Update_Marked_serial API later
               --
               IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,
                         'Generating txn temp ID for existing serial number');
               END IF;
               --
               SELECT mtl_material_transactions_s.NEXTVAL
               INTO l_transaction_id
               FROM DUAL;
               --
               l_update_attributes := TRUE;
               --}
	     ELSE
               --{
               IF NOT l_stamp_ser_wdd THEN
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,
                                        'generate transaction temp id');
                 END IF;
                 SELECT mtl_material_transactions_s.NEXTVAL
                 INTO l_transaction_id
                 FROM DUAL;
               END IF;
               --}
             END IF;
          --}
         END IF;

     -- )
     END IF; -- if l_detail_ser_count >=1

         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Transaction id created', l_transaction_id);
         END IF;

-- HW OPMCONV - Removed checking for l_process_flag
      IF (
              (
                  (x_detail_rec.serial_number <> fnd_api.g_miss_char)
               OR x_detail_rec.serial_number IS NULL
               OR l_detail_ser_count > 0
              )
--          AND l_process_flag = '0'
         )
      THEN
      -- (

         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Serial Number', x_detail_rec.serial_number);
            WSH_DEBUG_SV.log(l_module_name, 'To Serial Number', x_detail_rec.to_serial_number);
         END IF;

         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'inv control ser flag', l_inv_controls.ser_flag);
         END IF;

         -- Fix added to check the serial number before setting the message.
         -- If Serial Flag is N, need to set the message only if serial numbers are populated
         IF    x_detail_rec.serial_number IS NOT NULL
            OR x_detail_rec.to_serial_number IS NOT NULL
            OR l_detail_ser_count > 0
         THEN
         -- (
             IF l_inv_controls.ser_flag = 'N'
             THEN
             -- (
                 l_return_status := wsh_util_core.g_ret_sts_error;
                 fnd_message.set_name('WSH', 'WSH_INV_INVALID');
                 fnd_message.set_token('INV_ATTRIBUTE', 'Serial Number Code');
                 wsh_util_core.add_message(l_return_status);
                 RAISE fnd_api.g_exc_error;
             -- )
             END IF;
         -- )
         END IF;

         /* Bug fix: 2652300. Removed the code to call unmark serial numbers.
            Unmarking of serial numbers is now done in the api
            wsh_details_validations.validate_shipped_cc_qty , based on the shipped quantity and the serial quantity.
            It is no longer done here in the group API.*/

         -- Bug 3628620
         -- Handle Unmark Serial Number for Public API
         IF p_in_rec.caller = 'WSH_PUB' THEN

           -- Serial Number is being modified from Not null to Null/Not Null value,
           -- Unmark using serial number
           IF p_original_rec.serial_number IS NOT NULL AND
              l_detail_ser_qty = 1 AND l_update_attributes = FALSE AND
              x_detail_rec.serial_number <> fnd_api.g_miss_char
              -- AND (x_detail_rec.serial_number IS NULL OR
              -- x_detail_rec.serial_number <> p_original_rec.serial_number)
             THEN

             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.UNMARK_SERIAL_NUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
               WSH_DEBUG_SV.log(l_module_name,'Case1',p_original_rec.serial_number);
             END IF;
             wsh_delivery_details_inv.unmark_serial_number(
               p_delivery_detail_id  => p_in_detail_rec.delivery_detail_id,
               p_serial_number_code  => l_inv_controls.serial_code,
               p_serial_number          => p_original_rec.serial_number,
               p_transaction_temp_id => NULL,
               x_return_status          => l_return_status,
               p_inventory_item_id   => p_original_rec.inventory_item_id);

             IF l_debug_on THEN
               wsh_debug_sv.log(l_module_name, 'Return status after Unmark ', l_return_status);
             END IF;

             IF l_return_status <> wsh_util_core.g_ret_sts_success THEN
               RAISE fnd_api.g_exc_error;
             END IF;

           -- Transaction temp id exists in WDD,now 1 serial number is being
           -- specified, unmark using transaction temp id
           ELSIF (p_original_rec.transaction_temp_id IS NOT NULL AND
                  x_detail_rec.serial_number <> fnd_api.g_miss_char AND
                  l_detail_ser_qty = 1 AND l_update_attributes = FALSE)
                 OR
                 (p_original_rec.transaction_temp_id IS NOT NULL AND
                  l_det_ser_range_tab.count > 0 AND
                  l_detail_ser_qty > 1)
           THEN
             -- derive serial number from MSNT for this transaction temp id
             -- compare with x_detail_rec.serial_number

             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.UNMARK_SERIAL_NUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
               WSH_DEBUG_SV.log(l_module_name,'Case2',p_original_rec.transaction_temp_id);
             END IF;
             wsh_delivery_details_inv.unmark_serial_number(
               p_delivery_detail_id  => p_in_detail_rec.delivery_detail_id,
               p_serial_number_code  => l_inv_controls.serial_code,
               p_serial_number          => NULL,
               p_transaction_temp_id => p_original_rec.transaction_temp_id,
               x_return_status          => l_return_status,
               p_inventory_item_id   => p_original_rec.inventory_item_id);

             IF l_debug_on THEN
               wsh_debug_sv.log(l_module_name, 'Return status after Unmark ', l_return_status);
             END IF;

             IF l_return_status <> wsh_util_core.g_ret_sts_success THEN
               RAISE fnd_api.g_exc_error;
             END IF;

           END IF;
         END IF;
         -- End of Bug 3628620

         l_det_index := l_det_ser_range_tab.FIRST;

         WHILE l_det_index IS NOT NULL
         LOOP
         -- (
            --
               IF l_det_ser_range_tab(l_det_index).from_serial_number IS NOT NULL THEN
                  -- Bug 3628620. Skip validation if we are only updating the serial number flexfield attributes.
                  IF NOT l_update_attributes THEN
                    IF l_inv_controls.ser_flag = 'Y' THEN
                       IF l_det_ser_range_tab(l_det_index).to_serial_number IS NOT NULL THEN -- bug 1578114 condition added
                          IF l_debug_on THEN
                             WSH_DEBUG_SV.log(l_module_name, 'To Serial Number', l_det_ser_range_tab(l_det_index).to_serial_number);
                             WSH_DEBUG_SV.log(l_module_name, 'Transaction Id', l_transaction_id);
                             WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_DELIVERY_DETAILS_INV.VALIDATE_SERIAL_RANGE', WSH_DEBUG_SV.c_proc_level);
                          END IF;

                          --
                          -- Validates the Range of Serial Number
                          wsh_delivery_details_inv.validate_serial_range(
                             p_from_serial_number      => l_det_ser_range_tab(l_det_index).from_serial_number,
                             p_to_serial_number        => l_det_ser_range_tab(l_det_index).to_serial_number,
                             p_lot_number              => l_lot,
                             p_organization_id         => l_org_id,
                             p_inventory_item_id       => p_original_rec.inventory_item_id,
                             p_subinventory            => l_subinventory,
                             p_revision                => l_revision,
                             p_locator_id              => l_locator,
                             p_quantity                => l_det_ser_range_tab(l_det_index).quantity,
     	                     p_transaction_type_id    => l_trx_type_id,
	                     p_object_type            => 'A',
			     x_prefix                  => l_prefix,
                             x_return_status           => l_return_status,
                             x_result                  => l_result
                          );

                          --
                          IF l_debug_on THEN
                             WSH_DEBUG_SV.log(l_module_name, 'Prefix',l_prefix);
                             WSH_DEBUG_SV.log(l_module_name, 'Result',l_result);
                             WSH_DEBUG_SV.log(l_module_name, 'Return Status',l_return_status);
                          END IF;

                          IF NOT l_result THEN
                             l_return_status := wsh_util_core.g_ret_sts_error;
                          END IF;

                          wsh_util_core.api_post_call(
                           p_return_status      => l_return_status,
                           x_num_warnings       => l_number_of_warnings,
                           x_num_errors         => l_number_of_errors,
                           p_msg_data           => l_msg_data
                          );
                       ELSE
                          IF l_debug_on THEN
                             WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_DELIVERY_DETAILS_INV.VALIDATE_SERIAL', WSH_DEBUG_SV.c_proc_level);
                          END IF;

                          --
                          wsh_delivery_details_inv.validate_serial(
                           p_serial_number          => l_det_ser_range_tab(l_det_index).from_serial_number,
                           p_lot_number             => l_lot,
                           p_organization_id        => l_org_id,
                           p_inventory_item_id      => p_original_rec.inventory_item_id,
                           p_subinventory           => l_subinventory,
                           p_revision               => l_revision,
                           p_locator_id             => l_locator,
  	                   p_transaction_type_id    => l_trx_type_id,
	                   p_object_type            => 'A',
                           x_return_status          => l_return_status,
                           x_result                 => l_result
                          );
                          --
                          IF l_debug_on THEN
                             WSH_DEBUG_SV.log(l_module_name, 'Result',l_result);
                             WSH_DEBUG_SV.log(l_module_name, 'Return Status',l_return_status);
                          END IF;
                          --
                          IF NOT l_result THEN
                             l_return_status := wsh_util_core.g_ret_sts_error;
                          END IF;
                          --
                          wsh_util_core.api_post_call(
                             p_return_status      => l_return_status,
                             x_num_warnings       => l_number_of_warnings,
                             x_num_errors         => l_number_of_errors,
                             p_msg_data           => l_msg_data
                          );
                       END IF; -- if to_serial_number is not null


                    ELSIF l_inv_controls.ser_flag = 'D' THEN
                       IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name, 'to serial number', l_det_ser_range_tab(l_det_index).to_serial_number);
                       END IF;

                       IF     (
                             l_det_ser_range_tab(l_det_index).to_serial_number <>
                                                           fnd_api.g_miss_char
                            )
                          AND l_det_ser_range_tab(l_det_index).to_serial_number IS NOT NULL THEN -- bug 1578114 condition added
                          IF l_debug_on THEN
                             WSH_DEBUG_SV.log(l_module_name, 'Transaction id created', l_transaction_id);
                             WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_DELIVERY_DETAILS_INV.CREATE_DYNAMIC_SERIAL_RANGE', WSH_DEBUG_SV.c_proc_level);
                          END IF;

                          --
                          -- Creates/Validates the Range of Serial Number
                          wsh_delivery_details_inv.create_dynamic_serial_range(
                           p_from_number             => l_det_ser_range_tab(l_det_index).from_serial_number,
                           p_to_number               => l_det_ser_range_tab(l_det_index).to_serial_number,
--  Earlier l_transaction_id was being passed to p_delivery_detail below (frontport from 1159) -  jckwok
                           p_delivery_detail_id      => x_detail_rec.delivery_detail_id,
                           p_source_line_id          => p_original_rec.source_line_id,
                           p_lot_number              => l_lot,
                           p_organization_id         => l_org_id,
                           p_inventory_item_id       => p_original_rec.inventory_item_id,
                           p_subinventory            => l_subinventory,
                           p_revision                => l_revision,
                           p_locator_id              => l_locator,
                           p_quantity                => l_det_ser_range_tab(l_det_index).quantity,
                           x_prefix                  => l_prefix,
                           x_return_status           => l_return_status
                          );
                          --
                          wsh_util_core.api_post_call(
                           p_return_status      => l_return_status,
                           x_num_warnings       => l_number_of_warnings,
                           x_num_errors         => l_number_of_errors,
                           p_msg_data           => l_msg_data
                          );
                       ELSE
                          IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_DELIVERY_DETAILS_INV.CREATE_DYNAMIC_SERIAL', WSH_DEBUG_SV.c_proc_level);
                          END IF;

                          --
                          wsh_delivery_details_inv.create_dynamic_serial(
                           p_from_number             => l_det_ser_range_tab(l_det_index).from_serial_number,
                           p_to_number               => l_det_ser_range_tab(l_det_index).from_serial_number,
                           p_delivery_detail_id      => x_detail_rec.delivery_detail_id,
                           p_source_line_id          => p_original_rec.source_line_id,
                           p_lot_number              => l_lot,
                           p_organization_id         => l_org_id,
                           p_inventory_item_id       => p_original_rec.inventory_item_id,
                           p_subinventory            => l_subinventory,
                           p_revision                => l_revision,
                           p_locator_id              => l_locator,
                           x_return_status           => l_return_status
                          );
                          --
                          wsh_util_core.api_post_call(
                             p_return_status      => l_return_status,
                             x_num_warnings       => l_number_of_warnings,
                             x_num_errors         => l_number_of_errors,
                             p_msg_data           => l_msg_data
                          );
                       END IF; -- if to_serial_number is not null
                    END IF; -- IF l_controls.ser_flag = 'D'/'Y'

                  END IF; -- IF NOT l_update_attributes THEN


                  IF     l_transaction_id IS NOT NULL
                     AND l_det_ser_range_tab(l_det_index).to_serial_number IS NOT NULL THEN --bug 1578114 condition added
                     v1 := l_transaction_id;
                     v2 := SYSDATE;
                     v3 := fnd_global.user_id;
                     v4 := SYSDATE;
                     v5 := fnd_global.user_id;
                     v6 := fnd_global.login_id;
                     v7 := NULL;
                     v8 := NULL;
                     v9 := NULL;
                     v10 := SYSDATE;
                     v11 := NULL;
                     v12 := l_lot;
                     v13 :=
                           l_det_ser_range_tab(l_det_index).from_serial_number;
                     v14 := l_det_ser_range_tab(l_det_index).to_serial_number;
                     v15 := l_det_ser_range_tab(l_det_index).quantity;
                     v16 := NULL;
                     v17 := l_transaction_id;
                     v18 := NULL;
                     v19 := l_det_ser_range_tab(l_det_index).attribute_category;
                     v20 := l_det_ser_range_tab(l_det_index).attribute1;
                     v21 := l_det_ser_range_tab(l_det_index).attribute2;
                     v22 := l_det_ser_range_tab(l_det_index).attribute3;
                     v23 := l_det_ser_range_tab(l_det_index).attribute4;
                     v24 := l_det_ser_range_tab(l_det_index).attribute5;
                     v25 := l_det_ser_range_tab(l_det_index).attribute6;
                     v26 := l_det_ser_range_tab(l_det_index).attribute7;
                     v27 := l_det_ser_range_tab(l_det_index).attribute8;
                     v28 := l_det_ser_range_tab(l_det_index).attribute9;
                     v29 := l_det_ser_range_tab(l_det_index).attribute10;
                     v30 := l_det_ser_range_tab(l_det_index).attribute11;
                     v31 := l_det_ser_range_tab(l_det_index).attribute12;
                     v32 := l_det_ser_range_tab(l_det_index).attribute13;
                     v33 := l_det_ser_range_tab(l_det_index).attribute14;
                     v34 := l_det_ser_range_tab(l_det_index).attribute15;
                     -- Bug 3628620: INV wants DFF_UPDATED_FLAG to be populated
                     -- to 'Y' if there are dff attributes in msnt
                     IF v20 IS NOT NULL OR
                        v21 IS NOT NULL OR
                        v22 IS NOT NULL OR
                        v23 IS NOT NULL OR
                        v24 IS NOT NULL OR
                        v25 IS NOT NULL OR
                        v26 IS NOT NULL OR
                        v27 IS NOT NULL OR
                        v28 IS NOT NULL OR
                        v29 IS NOT NULL OR
                        v30 IS NOT NULL OR
                        v31 IS NOT NULL OR
                        v32 IS NOT NULL OR
                        v33 IS NOT NULL OR
                        v34 IS NOT NULL
                     THEN
                        v35 := 'Y';
                     ELSE
                        v35 := 'N';
                     END IF;

                     IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name, 'Inserting record into msnt');
                     END IF;

                     INSERT INTO mtl_serial_numbers_temp
                                 (
                                  transaction_temp_id, last_update_date,
                                  last_updated_by, creation_date,
                                  created_by, last_update_login, request_id,
                                  program_application_id, program_id,
                                  program_update_date, vendor_serial_number,
                                  vendor_lot_number, fm_serial_number,
                                  to_serial_number, serial_prefix,
                                  ERROR_CODE, group_header_id,
                                  parent_serial_number,
                                  attribute_category,
                                  attribute1,
                                  attribute2,
                                  attribute3,
                                  attribute4,
                                  attribute5,
                                  attribute6,
                                  attribute7,
                                  attribute8,
                                  attribute9,
                                  attribute10,
                                  attribute11,
                                  attribute12,
                                  attribute13,
                                  attribute14,
                                  attribute15,
                                  dff_updated_flag
                                 )
                          VALUES (
                                  v1, v2,
                                  v3, v4,
                                  v5, v6, v7,
                                  v8, v9,
                                  v10, v11,
                                  v12, v13,
                                  v14, v15,
                                  v16, v17,
                                  v18,
                                  v19,
                                  v20,
                                  v21,
                                  v22,
                                  v23,
                                  v24,
                                  v25,
                                  v26,
                                  v27,
                                  v28,
                                  v29,
                                  v30,
                                  v31,
                                  v32,
                                  v33,
                                  v34,
                                  v35
                                 );
                  END IF; -- if l_transaction_id is not null
               END IF; -- If new serial number is not null

            l_det_index := l_det_ser_range_tab.NEXT(l_det_index);
         -- )
         END LOOP; -- while l_det_index of serial_range_tab is not null

         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name, 'Transaction Id', l_transaction_id);
         END IF;

         IF NOT l_update_attributes THEN
          --{
            IF l_transaction_id IS NOT NULL
            THEN
            -- (
               wsh_delivery_details_inv.mark_serial_number(
                  p_delivery_detail_id       => x_detail_rec.delivery_detail_id,
                  p_serial_number            => NULL,
                  p_transaction_temp_id      => l_transaction_id,
                  x_return_status            => l_return_status
               );
               wsh_util_core.api_post_call(
                  p_return_status      => l_return_status,
                  x_num_warnings       => l_number_of_warnings,
                  x_num_errors         => l_number_of_errors,
                  p_msg_data           => l_msg_data
               );
            ELSIF p_in_detail_rec.serial_number IS NOT NULL
                  AND p_in_detail_rec.serial_number <> FND_API.G_MISS_CHAR
            THEN
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_DELIVERY_DETAILS_INV.MARK_SERIAL_NUMBER', WSH_DEBUG_SV.c_proc_level);
               END IF;

               --
               wsh_delivery_details_inv.mark_serial_number(
                  p_delivery_detail_id       => x_detail_rec.delivery_detail_id,
                  p_serial_number            => p_in_detail_rec.serial_number,
                  p_transaction_temp_id      => l_transaction_id,
                  x_return_status            => l_return_status
               );
               wsh_util_core.api_post_call(
                  p_return_status      => l_return_status,
                  x_num_warnings       => l_number_of_warnings,
                  x_num_errors         => l_number_of_errors,
                  p_msg_data           => l_msg_data
               );
               -- Since only single serial number exists, transaction_temp_id if exists, should be nulled
               x_detail_rec.transaction_temp_id := NULL;
            --)
            END IF;
          --}
         ELSE
          --{
          -- Bug 4016863 : Need to mark existing serial number with
          -- newly generated transaction_temp_id in the scenario where
          -- only the serial attributes are updated and not the serial #
          --
          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.UPDATE_MARKED_SERIAL',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          WSH_DELIVERY_DETAILS_INV.Update_Marked_Serial(
             p_from_serial_number  => p_original_rec.serial_number,
             p_to_serial_number    => NULL, -- always pass NULL for single serial number
             p_inventory_item_id   => p_original_rec.inventory_item_id,
             p_organization_id     => l_org_id,
             p_transaction_temp_id => l_transaction_id,
             x_return_status       => l_return_status);
          --
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name, 'Return status after Update_Marked_Serial ', l_return_status);
          END IF;
          --
          IF l_return_status <> wsh_util_core.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;
          --}
         END IF; -- l_update_attributes;
       -- )
      END IF; -- serial number g_miss_num

      IF l_transaction_id IS NOT NULL THEN
         x_detail_rec.transaction_temp_id := l_transaction_id;
         x_detail_rec.serial_number := NULL;
         x_detail_rec.to_serial_number := NULL;
      END IF;

      IF NVL(x_detail_rec.shipped_quantity, 0) = 0 THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Zero or Null shipped qty');
         END IF;

         x_detail_rec.serial_number := NULL;
         x_detail_rec.to_serial_number := NULL;
         x_detail_rec.transaction_temp_id := NULL;
      END IF;

      -- If from serial number = to serial number, only from serial number should be populated
      IF x_detail_rec.serial_number = x_detail_rec.to_serial_number THEN
         x_detail_rec.to_serial_number := NULL;
      END IF;

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'transaction temp id', x_detail_rec.transaction_temp_id);
         WSH_DEBUG_SV.log(l_module_name, 'serial number', x_detail_rec.serial_number);
         WSH_DEBUG_SV.log(l_module_name, 'to_serial_number', x_detail_rec.to_serial_number);
      END IF;
   END IF; -- if check for validation level

   fnd_msg_pub.count_and_get(
      p_count => x_msg_count,
      p_data => x_msg_data,
      p_encoded      => fnd_api.g_false);

   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
--
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO validate_det_line_grp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'FND_API.G_EXC_ERROR exception has occured.', WSH_DEBUG_SV.c_excep_level);
         WSH_DEBUG_SV.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
--
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO validate_det_line_grp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
         p_count => x_msg_count,
         p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.', WSH_DEBUG_SV.c_excep_level);
         WSH_DEBUG_SV.pop(l_module_name,
            'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
--
   WHEN wsh_util_core.g_exc_warning THEN
      x_return_status := wsh_util_core.g_ret_sts_warning;
      fnd_msg_pub.count_and_get(
         p_count => x_msg_count,
         p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,
            'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',
            WSH_DEBUG_SV.c_excep_level);
         WSH_DEBUG_SV.pop(l_module_name,
            'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
--
   WHEN OTHERS THEN
      ROLLBACK TO validate_det_line_grp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      wsh_util_core.add_message(x_return_status, l_module_name);
      wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_GRP.Validate_Detail_Line');
      fnd_msg_pub.count_and_get(
         p_count => x_msg_count,
         p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);

      --

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,
               'Unexpected error has occured. Oracle error message is '
            || SQLERRM,
            WSH_DEBUG_SV.c_unexpec_err_level);
         WSH_DEBUG_SV.pop(l_module_name, 'EXCEPTION:OTHERS');
      END IF;
--
END validate_detail_line;


    -- ---------------------------------------------------------------------
    -- Procedure: Validate_Detail_Container
    --
    -- Parameters:
    --
    -- Description:  This local procedure is the new API for wrapping the logic of VALIDATE of Containers
    -- Created:   Harmonization Project. Patchset I
    -- -----------------------------------------------------------------------
    PROCEDURE Validate_Detail_Container(
                x_detail_rec          IN OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
                p_original_rec        IN   c_original_detail_cur%ROWTYPE,
                p_validation_tab      IN   wsh_util_core.id_tab_type,
                x_mark_reprice_flag   OUT  NOCOPY VARCHAR2,
                x_return_status       OUT  NOCOPY VARCHAR2,
                x_msg_count           OUT  NOCOPY NUMBER,
                x_msg_data            OUT  NOCOPY VARCHAR2
                ) IS

        l_api_name              CONSTANT VARCHAR2(30)   := 'Validate_Detail_Container';
        l_api_version           CONSTANT NUMBER         := 1.0;

  --
  l_return_status             VARCHAR2(32767);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(32767);
  l_program_name              VARCHAR2(32767);
        --
  l_number_of_errors    NUMBER := 0;
  l_number_of_warnings  NUMBER := 0;
  --
        l_cont_item_seg         FND_FLEX_EXT.SegmentArray;
        l_cont_item_name        VARCHAR2(30)    := NULL;

        --
l_debug_on BOOLEAN;
        --
        l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_DETAIL_CONTAINER';
        --
e_invalid_delivered_qty EXCEPTION; --lpn SyNCH uP samanna
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
        SAVEPOINT  VALIDATE_DET_CONTAINER_GRP;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            WSH_DEBUG_SV.log(l_module_name, 'Delivery Detail Id', x_detail_rec.delivery_detail_id);
        END IF;
        --  Initialize API return status to success
  x_return_status       := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_number_of_errors := 0;
  l_number_of_warnings := 0;

        IF(p_validation_tab(WSH_ACTIONS_LEVELS.C_CONT_ITEM_LVL) = 1 ) THEN
           IF (x_detail_rec.inventory_item_id <> FND_API.G_MISS_NUM) THEN
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name, 'Inventory Item Id', x_detail_rec.inventory_item_id);
                    WSH_DEBUG_SV.log(l_module_name, 'Organization Id', x_detail_rec.organization_id);
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_ITEM',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_UTIL_VALIDATE.Validate_Item(
                     p_inventory_item_id => x_detail_rec.inventory_item_id,
                     p_inventory_item    => l_cont_item_name,
                     p_organization_id   => p_original_rec.organization_id,
                     p_seg_array         => l_cont_item_seg,
                     p_item_type         => 'CONT_ITEM',
                     x_return_status     => l_return_status);

                  --
                  wsh_util_core.api_post_call(
                      p_return_status => l_return_status,
                      x_num_warnings  => l_number_of_warnings,
                      x_num_errors    => l_number_of_errors,
                      p_msg_data      => l_msg_data
                      );

           END IF;
        END IF;
	--
	--lpn CONV.. samanna
	IF (x_detail_rec.delivered_quantity <> FND_API.G_MISS_NUM) THEN
	   IF p_original_rec.shipped_quantity IS NOT NULL THEN
	      IF x_detail_rec.delivered_quantity > p_original_rec.shipped_quantity THEN
	         RAISE e_invalid_delivered_qty;
	      END IF;
	   ELSE
	      IF p_original_rec.picked_quantity IS NOT NULL THEN
	         IF x_detail_rec.delivered_quantity > p_original_rec.picked_quantity THEN
		    RAISE e_invalid_delivered_qty;
		 END IF;
	      ELSE
	         IF p_original_rec.requested_quantity IS NOT NULL THEN
		    IF x_detail_rec.delivered_quantity > p_original_rec.requested_quantity THEN
		       RAISE e_invalid_delivered_qty;
		    END IF;
		 END IF;
	      END IF;
	   END IF;
	END IF;
      --
    FND_MSG_PUB.Count_And_Get
      (
        p_count  => x_msg_count,
        p_data  =>  x_msg_data,
        p_encoded => FND_API.G_FALSE
      );

        IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
        END IF;

    EXCEPTION
	  WHEN e_invalid_delivered_qty THEN
                ROLLBACK TO VALIDATE_DET_CONTAINER_GRP;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MESSAGE.SET_NAME('WSH', 'WSH_INVALID_DELIVERED_QTY');
                WSH_UTIL_CORE.ADD_MESSAGE(wsh_util_core.g_ret_sts_error, l_module_name);
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE
                  );
                IF l_debug_on THEN
		   WSH_DEBUG_SV.logmsg(l_module_name,'E_INVALID_DELIVERED_QTY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION: E_INVALID_DELIVERED_QTY');
                END IF;


        WHEN FND_API.G_EXC_ERROR THEN
                 ROLLBACK TO VALIDATE_DET_CONTAINER_GRP;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );
                  --

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
            END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                 ROLLBACK TO VALIDATE_DET_CONTAINER_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
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
        WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
             x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
             FND_MSG_PUB.Count_And_Get
              (
                p_count  => x_msg_count,
                p_data  =>  x_msg_data,
                p_encoded => FND_API.G_FALSE
              );
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
       END IF;
--
        WHEN OTHERS THEN
                 ROLLBACK TO VALIDATE_DET_CONTAINER_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
               wsh_util_core.add_message(x_return_status, l_module_name);
               WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_GRP.Validate_Detail_Container');
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
    END Validate_Detail_Container;


    -- ---------------------------------------------------------------------
    -- Procedure: Validate_Detail_Common
    --
    -- Parameters:
    --
    -- Description:  This local procedure is the new API for wrapping the logic of VALIDATE of both
    --                 Containers and Non Containers(Lines)
    -- Created:   Harmonization Project. Patchset I
    -- -----------------------------------------------------------------------

    PROCEDURE Validate_Detail_Common(
                x_detail_rec          IN OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
                p_original_rec        IN   c_original_detail_cur%ROWTYPE,
                p_validation_tab      IN   wsh_util_core.id_tab_type,
                x_mark_reprice_flag   OUT  NOCOPY VARCHAR2,
                x_return_status       OUT  NOCOPY VARCHAR2,
                x_msg_count           OUT  NOCOPY NUMBER,
                x_msg_data            OUT  NOCOPY VARCHAR2
                ) IS

        l_api_name              CONSTANT VARCHAR2(30)   := 'Validate_Detail_Common';
        l_api_version           CONSTANT NUMBER         := 1.0;
  --
  l_return_status             VARCHAR2(32767);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(32767);
  l_program_name              VARCHAR2(32767);
        --
  l_number_of_errors    NUMBER := 0;
  l_number_of_warnings  NUMBER := 0;
  --
        l_parent_detail_id    NUMBER;
        l_cont_item_seg         FND_FLEX_EXT.SegmentArray;
        l_cont_item_name        VARCHAR2(30)    := NULL;
  --

        CURSOR parent_detail_cur(p_detail_id NUMBER) IS
           SELECT parent_delivery_detail_id
           FROM wsh_delivery_assignments_v
           WHERE delivery_detail_id = p_detail_id;
           --
-- HW OPMCONV - Removed OPM variables

l_debug_on BOOLEAN;
           --
           l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_DETAIL_COMMON';
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
        SAVEPOINT VALIDATE_DET_COMMON_GRP;

        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            WSH_DEBUG_SV.log(l_module_name, 'Delivery Detail Id', x_detail_rec.delivery_detail_id);
        END IF;
        --

        --  Initialize API return status to success
  x_return_status       := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_number_of_errors := 0;
  l_number_of_warnings := 0;

--HW OPMCONV - Removed checking for process org

        IF(p_validation_tab(WSH_ACTIONS_LEVELS.C_GROSS_WEIGHT_LVL) = 1 ) THEN
               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name, 'Gross Weight', x_detail_rec.gross_weight);
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_NEGATIVE',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
	  --Bug # 3266333
	       wsh_util_validate.validate_negative(
		    p_value          =>  x_detail_rec.gross_weight,
	  	    p_field_name     => 'gross_weight',
		    x_return_status  => l_return_status );
          --
                  wsh_util_core.api_post_call(
                      p_return_status => l_return_status,
                      x_num_warnings  => l_number_of_warnings,
                      x_num_errors    => l_number_of_errors,
                      p_msg_data      => l_msg_data
                      );

                x_mark_reprice_flag := 'Y';
        END IF;

        IF(p_validation_tab(WSH_ACTIONS_LEVELS.C_NET_WEIGHT_LVL) = 1 ) THEN
              --
              IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name, 'Net Weight', x_detail_rec.net_weight);
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_NEGATIVE',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
	  --Bug # 3266333
	       wsh_util_validate.validate_negative(
		    p_value          =>  x_detail_rec.net_weight,
	  	    p_field_name     => 'net_weight',
		    x_return_status  => l_return_status );
          --
               wsh_util_core.api_post_call(
                    p_return_status => l_return_status,
                    x_num_warnings  => l_number_of_warnings,
                    x_num_errors    => l_number_of_errors,
                    p_msg_data      => l_msg_data
                     );

                  x_mark_reprice_flag := 'Y';
        END IF;


        IF(p_validation_tab(WSH_ACTIONS_LEVELS.C_VOLUME_LVL) = 1 ) THEN
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name, 'Volume', x_detail_rec.volume);
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_NEGATIVE',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
	     --Bug # 3266333
	       wsh_util_validate.validate_negative(
		    p_value          =>  x_detail_rec.volume,
	  	    p_field_name     => 'volume',
		    x_return_status  => l_return_status );
              --
                  wsh_util_core.api_post_call(
                      p_return_status => l_return_status,
                      x_num_warnings  => l_number_of_warnings,
                      x_num_errors    => l_number_of_errors,
                      p_msg_data      => l_msg_data
                      );

               x_mark_reprice_flag := 'Y';
        END IF;

     IF(p_validation_tab(WSH_ACTIONS_LEVELS.C_MASTER_SER_NUM_LVL) = 1 ) THEN
        IF(x_detail_rec.master_serial_number IS NOT NULL) THEN
               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name, 'Original container Flag', p_original_rec.container_flag);
                   WSH_DEBUG_SV.log(l_module_name, 'Master Serial Number', x_detail_rec.master_serial_number);
               END IF;

            -- Update of master serial number is allowed only if detail is a container
            -- And if the container is the top most container

	    -- R12 MDC: For container_flag 'C' does not need additional logic because
	    -- it is always topmost container. Only replaced ELSE condition with ELSIF
	    -- to skip check for container flag 'C'

            IF(p_original_rec.container_flag = 'Y') THEN
	       -- Verify if this is the top most container
               OPEN parent_detail_cur(x_detail_rec.delivery_detail_id);
               FETCH parent_detail_cur INTO l_parent_detail_id;
               CLOSE parent_detail_cur;

               IF(l_parent_detail_id IS NOT NULL) THEN
                  x_detail_rec.master_serial_number := p_original_rec.master_serial_number;
                  FND_MESSAGE.SET_NAME('WSH', 'WSH_UPDATE_MASTER_SERIAL');
                  wsh_util_core.add_message(wsh_util_core.g_ret_sts_warning, l_module_name);
                  RAISE WSH_UTIL_CORE.G_EXC_WARNING;
               END IF;
            ELSIF (p_original_rec.container_flag = 'N') THEN -- R12 MDC
               x_detail_rec.master_serial_number := p_original_rec.master_serial_number;
               FND_MESSAGE.SET_NAME('WSH', 'WSH_UPDATE_MASTER_SERIAL');
               wsh_util_core.add_message(wsh_util_core.g_ret_sts_warning, l_module_name);
               RAISE WSH_UTIL_CORE.G_EXC_WARNING;
            END IF;
        END IF;

     END IF;

     IF(p_validation_tab(WSH_ACTIONS_LEVELS.C_DET_INSPECT_FLAG_LVL) = 1 ) THEN
         -- Cannot set the inspection_Flag to N if it is already I or R

         IF x_detail_rec.inspection_flag IS NOT NULL THEN
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name, 'Original Inspec Flag', p_original_rec.inspection_flag);
               WSH_DEBUG_SV.log(l_module_name, 'Inspection Flag', x_detail_rec.inspection_flag);
            END IF;

            IF(x_detail_rec.inspection_flag = 'N' AND p_original_rec.inspection_flag IN ('I', 'R')) THEN
              x_detail_rec.inspection_flag := p_original_rec.inspection_flag;
              FND_MESSAGE.SET_NAME('WSH', 'WSH_UPDATE_INSPECT_FLAG');
            wsh_util_core.add_message(wsh_util_core.g_ret_sts_warning, l_module_name);
              RAISE WSH_UTIL_CORE.G_EXC_WARNING;
            END IF;

         END IF;

     END IF;

     IF(p_validation_tab(WSH_ACTIONS_LEVELS.C_MASTER_LPN_ITEM_LVL) = 1) THEN
        IF x_detail_rec.master_container_item_id IS NOT NULL THEN

               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name, 'Master cont item id', x_detail_rec.master_container_item_id);
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_ITEM',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;

           WSH_UTIL_VALIDATE.Validate_Item(
                     p_inventory_item_id => x_detail_rec.master_container_item_id,
                     p_inventory_item    => l_cont_item_name,
                     p_organization_id   => p_original_rec.organization_id,
                     p_seg_array         => l_cont_item_seg,
                     p_item_type         => 'CONT_ITEM',
                     x_return_status     => l_return_status);

                  --
                  wsh_util_core.api_post_call(
                      p_return_status => l_return_status,
                      x_num_warnings  => l_number_of_warnings,
                      x_num_errors    => l_number_of_errors,
                      p_msg_data      => l_msg_data
                      );
        END IF;
     END IF;

     IF(p_validation_tab(WSH_ACTIONS_LEVELS.C_DETAIL_LPN_ITEM_LVL) = 1) THEN
        IF x_detail_rec.detail_container_item_id IS NOT NULL THEN

               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name, 'Detail cont item id', x_detail_rec.Detail_container_item_id);
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_ITEM',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;

           WSH_UTIL_VALIDATE.Validate_Item(
                     p_inventory_item_id => x_detail_rec.detail_container_item_id,
                     p_inventory_item    => l_cont_item_name,
                     p_organization_id   => p_original_rec.organization_id,
                     p_seg_array         => l_cont_item_seg,
                     p_item_type         => 'CONT_ITEM',
                     x_return_status     => l_return_status);

                  --
                  wsh_util_core.api_post_call(
                      p_return_status => l_return_status,
                      x_num_warnings  => l_number_of_warnings,
                      x_num_errors    => l_number_of_errors,
                      p_msg_data      => l_msg_data
                      );
        END IF;
     END IF;
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'x_detail_rec.delivered_quantity',x_detail_rec.delivered_quantity);
     END IF;
-- HW OPMCONV - Removed branching

     --{
       IF (nvl(x_detail_rec.delivered_quantity, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM) THEN
       --{
         x_detail_rec.delivered_quantity := round(x_detail_rec.delivered_quantity,wsh_util_core.c_max_decimal_digits_inv);
       --}
       END IF;
     --}



    FND_MSG_PUB.Count_And_Get
      (
        p_count  => x_msg_count,
        p_data  =>  x_msg_data,
        p_encoded => FND_API.G_FALSE
      );

      IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
      END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO VALIDATE_DET_COMMON_GRP;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );
                  --
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
              END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO VALIDATE_DET_COMMON_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
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

        WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
             x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
             FND_MSG_PUB.Count_And_Get
              (
                p_count  => x_msg_count,
                p_data  =>  x_msg_data,
                p_encoded => FND_API.G_FALSE
              );
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
       END IF;

        WHEN OTHERS THEN
                ROLLBACK TO VALIDATE_DET_COMMON_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               wsh_util_core.add_message(x_return_status, l_module_name);
               WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_GRP.Validate_Detail_Common');
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

    END Validate_Detail_Common;

/* ---------------------------------------------------------------------
   Procedure: Get_Serial_Quantity

   Parameters:

   Description:  This procedure is used to derive the serial quantity.
                 Procedure is created based on the function get_serial_qty
                 in WSHFSTRX.
   Created:   Harmonization Project. Patchset I. Bug fix 2652300
   ----------------------------------------------------------------------- */

PROCEDURE get_serial_quantity(
          p_transaction_temp_id  IN  NUMBER,
          p_serial_number        IN  VARCHAR2,
          p_to_serial_number     IN  VARCHAR2,
          p_shipped_quantity     IN  VARCHAR2,
          x_serial_qty           OUT NOCOPY NUMBER,
          x_return_status        OUT NOCOPY VARCHAR2)
IS

  cursor c_serial_qty(p_transaction_temp_id number) is
  SELECT   sum(nvl(msnt.serial_prefix, 0)) serial_qty
  FROM     mtl_serial_numbers_temp msnt
  WHERE    msnt.transaction_temp_id = p_transaction_temp_id
  GROUP BY msnt.transaction_temp_id;

  l_serial_qty c_serial_qty%ROWTYPE;

  l_debug_on Boolean;

  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_SERIAL_QUANTITY';

begin

      l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
      --
      IF l_debug_on IS NULL THEN
          l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
      END IF;
      --
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            WSH_DEBUG_SV.log(l_module_name, 'Transaction Temp Id', p_transaction_temp_id);
            WSH_DEBUG_SV.log(l_module_name, 'Serial Number', p_serial_number);
            WSH_DEBUG_SV.log(l_module_name, 'To Serial Number', p_to_serial_number);
            WSH_DEBUG_SV.log(l_module_name, 'Shipped Qty', p_shipped_quantity);
        END IF;
        --

  x_return_status       := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  if p_transaction_temp_id is not null then

    open c_serial_qty(p_transaction_temp_id);
    fetch c_serial_qty into l_serial_qty;
    if c_serial_qty%NOTFOUND then
       l_serial_qty.serial_qty := 0;
    end if;
    close c_serial_qty;
  elsif p_serial_number IS NOT NULL AND p_to_serial_number IS NOT NULL THEN
    l_serial_qty.serial_qty := p_shipped_quantity;
  elsif p_serial_number IS NOT NULL THEN
    l_serial_qty.serial_qty := 1;
  else
    l_serial_qty.serial_qty := 0;
  end if;

  x_serial_qty := NVL(l_serial_qty.serial_qty, 0);

      IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name, 'Serial Qty', x_serial_qty);
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;


EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR ;
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
              END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
           END IF;

        WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
             x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
       END IF;

        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               wsh_util_core.add_message(x_return_status, l_module_name);
               WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_GRP.Get_Serial_Quantity');
    --

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
            END IF;

END get_serial_quantity;

/*    ---------------------------------------------------------------------
    Procedure: Create_Update_Delivery_Detail (OVERLOADED)

    Parameters:

    Description:  This procedure is the new API for wrapping the logic of CREATE/UPDATE of delivery details
                     This OVERLOADED procedure has the additional parameter 'p_serial_range_tab'
    Created :   Patchset I
    ----------------------------------------------------------------------- */

    PROCEDURE Create_Update_Delivery_Detail
    (
       -- Standard Parameters
       p_api_version_number  IN  NUMBER,
       p_init_msg_list           IN    VARCHAR2,
       p_commit                  IN    VARCHAR2,
       x_return_status           OUT     NOCOPY  VARCHAR2,
       x_msg_count               OUT   NOCOPY  NUMBER,
       x_msg_data                OUT   NOCOPY  VARCHAR2,

       -- Procedure Specific Parameters
       p_detail_info_tab         IN   WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type,
       p_IN_rec                  IN   WSH_GLBL_VAR_STRCT_GRP.detailInRecType,
       x_OUT_rec                 OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.detailOutRecType,
       p_serial_range_tab        IN  WSH_GLBL_VAR_STRCT_GRP.ddSerialRangeTabType
    ) IS

        l_api_name              CONSTANT VARCHAR2(30)   := 'Create_Update_Delivery_Detail2';
        l_api_version           CONSTANT NUMBER         := 1.0;
        --
  --
  --
  l_return_status             VARCHAR2(32767);
  l1_return_status             VARCHAR2(32767);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(32767);
  l_program_name              VARCHAR2(32767);
        --
  l_number_of_errors    NUMBER := 0;
  l_number_of_warnings  NUMBER := 0;
  --
        l_loop_num_error      NUMBER := 0;
        l_loop_num_warn       NUMBER := 0;
        --
        l_counter             NUMBER := 0;
        l_index               NUMBER;

        l_detail_info_tab     WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type;
        l_valid_index_tab     wsh_util_core.id_tab_type;
        l_delivery_id         NUMBER;
        l_delivery_detail_rec WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type;
        l_validation_tab      wsh_util_core.id_tab_type;
  --
        l_details_marked        WSH_UTIL_CORE.Id_Tab_Type;
        mark_reprice_error      EXCEPTION;

        --
        CURSOR det_to_del_cur(p_detail_id NUMBER) IS
           SELECT wda.delivery_id
           FROM wsh_delivery_assignments_v wda
           WHERE wda.delivery_detail_id = p_detail_id;

-- anxsharm for Load Tender
        l_detail_tender_tab wsh_util_core.id_tab_type;
        l_trip_id_tab wsh_util_core.id_tab_type;

        --
        l_weight_uom_code     VARCHAR2(10);
        l_volume_uom_code     VARCHAR2(10);
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_DELIVERY_DETAIL2';
  --
  -- Following 4 variables are added for bugfix #4070732
  l_api_session_name CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
  l_reset_flags BOOLEAN;
  --
  BEGIN
	-- Bugfix 4070732
	IF WSH_UTIL_CORE.G_START_OF_SESSION_API is null
	THEN
		WSH_UTIL_CORE.G_START_OF_SESSION_API     := l_api_session_name;
		WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API := FALSE;
	END IF;
	-- End of Code Bugfix 4070732

        -- Standard Start of API savepoint
        SAVEPOINT   CREATE_UPDATE_DEL_DETAIL_GRP2;
        --
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
        --
        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;
        --

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            --
            WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
            WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
            WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
            WSH_DEBUG_SV.log(l_module_name, 'Caller', p_In_rec.caller);
            WSH_DEBUG_SV.log(l_module_name, 'Action Code', p_In_rec.action_code);
            WSH_DEBUG_SV.log(l_module_name,'Input Table count', p_detail_info_tab.count);
        END IF;
        --

        -- Initialize message list if p_init_msg_list is set to TRUE.
  --
  --
        IF FND_API.to_Boolean( p_init_msg_list )
  THEN
                FND_MSG_PUB.initialize;
        END IF;
  --
  --
        --  Initialize API return status to success
  x_return_status       := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_number_of_errors := 0;
  l_number_of_warnings := 0;

        -- Check for generic mandatory parameters
        IF p_In_rec.caller IS NULL THEN
            FND_MESSAGE.SET_NAME('WSH', 'WSH_REQUIRED_FIELD_NULL');
            FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'CALLER');
            wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
           IF l_debug_on THEN
              wsh_debug_sv.logmsg(l_module_name,'Null Caller');
           END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF p_In_rec.action_code IS NULL THEN
            FND_MESSAGE.SET_NAME('WSH', 'WSH_REQUIRED_FIELD_NULL');
            FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'ACTION_CODE');
            wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
           IF l_debug_on THEN
              wsh_debug_sv.logmsg(l_module_name,'Null Action Code');
           END IF;
            RAISE FND_API.G_EXC_ERROR;
        ELSIF(p_In_rec.action_code NOT IN('CREATE', 'UPDATE', 'CANCEL')
              OR (p_In_rec.action_code = 'CANCEL' AND p_In_rec.caller <> 'WSH_INBOUND')) THEN
           FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_ACTION_CODE');
           FND_MESSAGE.SET_TOKEN('ACT_CODE',p_In_rec.action_code );
            wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
           IF l_debug_on THEN
              wsh_debug_sv.logmsg(l_module_name,'WSH_INVALID_ACTION_CODE');
           END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Set Validation Level

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ACTIONS_LEVELS.SET_VALIDATION_LEVEL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_actions_levels.set_validation_level(
            p_entity           => 'DLVB',
            p_caller           => p_In_rec.caller,
            p_phase            => p_In_rec.phase,
            p_action           => p_In_rec.action_code,
            x_return_status    => l_return_status
        );

                  --
                  wsh_util_core.api_post_call(
                      p_return_status => l_return_status,
                      x_num_warnings  => l_number_of_warnings,
                      x_num_errors    => l_number_of_errors,
                      p_msg_data      => l_msg_data
                      );
               --
        l_validation_tab := WSH_ACTIONS_LEVELS.G_VALIDATION_LEVEL_TAB;

        -- Get Disabled List
        --
      IF(l_validation_tab(WSH_ACTIONS_LEVELS.C_DISABLED_LIST_LVL) = 1) THEN
        l_index := p_detail_info_tab.FIRST;
        WHILE l_index IS NOT NULL
        LOOP
            --
          BEGIN
            SAVEPOINT before_det_disabled_grp;

            OPEN det_to_del_cur(p_detail_info_tab(l_index).delivery_detail_id);
            FETCH det_to_del_Cur INTO l_delivery_id;
            CLOSE det_to_del_Cur;

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.GET_DISABLED_LIST',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --

            IF p_In_rec.caller LIKE 'WMS%' AND p_in_rec.action_code ='UPDATE'
            THEN
               l_weight_uom_code := p_detail_info_tab(l_index).weight_uom_code;
               l_volume_uom_code := p_detail_info_tab(l_index).volume_uom_code;
               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'l_weight_uom_code',
                                                            l_weight_uom_code);
                  WSH_DEBUG_SV.log(l_module_name,'l_volume_uom_code',
                                                            l_volume_uom_code);
               END IF;

            END IF;

            wsh_details_validations.get_disabled_list(
                --
                p_delivery_detail_rec   =>   p_detail_info_tab(l_index),
                p_delivery_id           =>   l_delivery_id,
                p_in_rec                =>   p_In_rec,
                x_return_status         =>   l_return_status,
                x_msg_count             =>   l_msg_count,
                x_msg_data              =>   l_msg_data,
                x_delivery_detail_rec   =>   l_delivery_detail_rec
                 );


                  --
                  wsh_util_core.api_post_call(
                      p_return_status => l_return_status,
                      x_num_warnings  => l_loop_num_warn,
                      x_num_errors    => l_loop_num_error,
                      p_msg_data      => l_msg_data
                      );

                -- lpn conv
                -- IF WMS passes different UOM then convert
                IF p_In_rec.caller LIKE 'WMS%'
                  AND p_in_rec.action_code ='UPDATE'
                  AND l_delivery_detail_rec.container_flag in ('Y', 'C')
                THEN
                   IF l_weight_uom_code <>
                                   l_delivery_detail_rec.weight_uom_code
                     AND l_weight_uom_code <> FND_API.G_MISS_CHAR
                   THEN
                      l_delivery_detail_rec.gross_weight :=
                              WSH_WV_UTILS.Convert_Uom_core (
                                     from_uom => l_weight_uom_code,
                                     to_uom => l_delivery_detail_rec.weight_uom_code,
                                     quantity => l_delivery_detail_rec.gross_weight,
                                     item_id => l_delivery_detail_rec.inventory_item_id,
                                     x_return_status => l_return_status );

                      wsh_util_core.api_post_call(
                         p_return_status => l_return_status,
                         x_num_warnings  => l_loop_num_warn,
                         x_num_errors    => l_loop_num_error
                         );

                      l_delivery_detail_rec.net_weight :=
                              WSH_WV_UTILS.Convert_Uom_core (
                                     from_uom => l_weight_uom_code,
                                     to_uom => l_delivery_detail_rec.weight_uom_code,
                                     quantity => l_delivery_detail_rec.net_weight,
                                     item_id => l_delivery_detail_rec.inventory_item_id,
                                     x_return_status => l_return_status);

                              wsh_util_core.api_post_call(
                                 p_return_status => l_return_status,
                                 x_num_warnings  => l_loop_num_warn,
                                 x_num_errors    => l_loop_num_error
                                 );
                      IF l_debug_on THEN
                         WSH_DEBUG_SV.log(l_module_name,'net_weight',
                                         l_delivery_detail_rec.net_weight);
                         WSH_DEBUG_SV.log(l_module_name,'gross_weight',
                                      l_delivery_detail_rec.gross_weight);
                         WSH_DEBUG_SV.log(l_module_name,'database uom',
                                   l_delivery_detail_rec.weight_uom_code);
                         WSH_DEBUG_SV.log(l_module_name,'item_id',
                                 l_delivery_detail_rec.inventory_item_id);
                      END IF;

                   END IF;
                   IF l_volume_uom_code <>
                                    l_delivery_detail_rec.volume_uom_code
                     AND l_volume_uom_code <> FND_API.G_MISS_CHAR
                   THEN

                      l_delivery_detail_rec.volume :=
                              WSH_WV_UTILS.Convert_Uom_core (
                                     from_uom => l_volume_uom_code,
                                     to_uom => l_delivery_detail_rec.volume_uom_code,
                                     quantity => l_delivery_detail_rec.volume,
                                     item_id => l_delivery_detail_rec.inventory_item_id,
                                     x_return_status => l_return_status);

                      wsh_util_core.api_post_call(
                                 p_return_status => l_return_status,
                                 x_num_warnings  => l_loop_num_warn,
                                 x_num_errors    => l_loop_num_error
                                 );

                      l_delivery_detail_rec.filled_volume :=
                           WSH_WV_UTILS.Convert_Uom_core (
                                  from_uom => l_volume_uom_code,
                                  to_uom => l_delivery_detail_rec.volume_uom_code,
                                  quantity => l_delivery_detail_rec.filled_volume,
                                  item_id => l_delivery_detail_rec.inventory_item_id,
                                  x_return_status => l_return_status);
                      wsh_util_core.api_post_call(
                                 p_return_status => l_return_status,
                                 x_num_warnings  => l_loop_num_warn,
                                 x_num_errors    => l_loop_num_error
                                 );
                      IF l_debug_on THEN
                         WSH_DEBUG_SV.log(l_module_name,'volume',
                                            l_delivery_detail_rec.volume);
                         WSH_DEBUG_SV.log(l_module_name,'filled_volume',
                                      l_delivery_detail_rec.filled_volume);
                         WSH_DEBUG_SV.log(l_module_name,'database uom',
                                   l_delivery_detail_rec.volume_uom_code);
                         WSH_DEBUG_SV.log(l_module_name,'item_id',
                                 l_delivery_detail_rec.inventory_item_id);
                      END IF;
                   END IF;

                END IF;
                l_detail_info_tab(l_index) := l_delivery_detail_rec;
          EXCEPTION
             WHEN FND_API.G_EXC_ERROR THEN
                 ROLLBACK TO  before_det_disabled_grp;
                 IF l_debug_on THEN
                    wsh_debug_sv.logmsg(l_module_name, 'g exc error');
                 END IF;
             WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                 ROLLBACK TO before_det_disabled_grp;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             WHEN OTHERS THEN
                 ROLLBACK TO before_det_disabled_grp;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

          END;
          l_weight_uom_code := NULL;
          l_volume_uom_code := NULL;
          l_index := p_detail_info_tab.NEXT(l_index);
        END LOOP;

          IF l_debug_on THEN
             wsh_debug_sv.log(l_module_name, 'Number of errors after loop', l_loop_num_error);
             wsh_debug_sv.log(l_module_name, 'New table count', l_detail_info_tab.count);
          END IF;

       -- For create container, the table count will be zero
       -- Should not set error for that container case
--bmso check the case where container is created and the detail_info_tab > 0
        IF p_detail_info_tab.count > 0 THEN
          IF l_loop_num_error = p_detail_info_tab.count THEN
             IF l_debug_on THEN
                    wsh_debug_sv.logmsg(l_module_name, 'get disabled list fail all records');
             END IF;
             RAISE FND_API.G_EXC_ERROR;
          ELSE
             l_number_of_warnings := l_loop_num_error;
          END IF;
        END IF;

       ELSE
           -- if the validation level for disabled list is turned off
           -- then we initialize the local table using the input table directly
           -- this will be applicable when caller is WSHFSTRX.
           IF l_debug_on THEN
              wsh_debug_sv.logmsg(l_module_name, 'Get Disabled turned off');
           END IF;
           l_detail_info_tab := p_detail_info_tab;
       --
       END IF; -- if check for C_DISABLED_LIST_LVL

       IF(p_in_rec.action_code ='UPDATE' AND l_detail_info_tab.count < 1) THEN
           -- Should not proceed further
           IF l_debug_on THEN
              wsh_debug_sv.logmsg(l_module_name,'Table Count Zero');
           END IF;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

-- anxsharm for Load Tender
          IF(l_validation_tab(WSH_ACTIONS_LEVELS.C_WMS_CONTAINERS_LVL) = 1) THEN--{ lpn conv
             Validate_Delivery_Detail(
                x_detail_info_tab  => l_detail_info_tab,
                p_in_detail_tab    =>  p_detail_info_tab,
                p_action           => p_In_rec.action_code,
                p_validation_tab   => l_validation_tab,
                p_caller           => p_In_rec.caller,
                x_valid_index_tab  => l_valid_index_tab,
                x_details_marked   => l_details_marked,
                x_detail_tender_tab =>l_detail_tender_tab,
                x_return_status    => l_return_status,
                x_msg_count        =>  l_msg_count,
                x_msg_data         => l_msg_data,
                p_in_rec           => p_in_rec,
                p_serial_range_tab => p_serial_range_tab);

                  --
                  wsh_util_core.api_post_call(
                      p_return_status => l_return_status,
                      x_num_warnings  => l_number_of_warnings,
                      x_num_errors    => l_number_of_errors,
                      p_msg_data      => l_msg_data
                      );
       END IF; --} lpn conv
       IF(p_In_rec.action_code = 'CREATE') THEN
            --
            Create_Delivery_Detail(
                p_detail_info_tab => l_detail_info_tab,
                p_detail_IN_rec   => p_in_rec ,
                p_valid_index_tab => l_valid_index_tab,
                x_detail_OUT_rec        => x_out_rec,
                x_return_status   => l_return_status,
                x_msg_count            =>  l_msg_count,
                x_msg_data             => l_msg_data);

                  --
                  wsh_util_core.api_post_call(
                      p_return_status => l_return_status,
                      x_num_warnings  => l_number_of_warnings,
                      x_num_errors    => l_number_of_errors,
                      p_msg_data      => l_msg_data
                      );


       ELSIF(p_In_rec.action_code = 'UPDATE') THEN

             IF( WSH_UTIL_CORE.FTE_Is_Installed = 'Y') THEN
    IF l_details_marked.count > 0 THEN
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
         p_entity_type => 'DELIVERY_DETAIL',
         p_entity_ids   => l_details_marked,
         x_return_status => l_return_status);

                  --
                  wsh_util_core.api_post_call(
                      p_return_status => l_return_status,
                      x_num_warnings  => l_number_of_warnings,
                      x_num_errors    => l_number_of_errors,
                      p_msg_data      => l_msg_data
                      );

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         raise mark_reprice_error;
      END IF;
    END IF;
              END IF;

            IF nvl(WSH_WMS_LPN_GRP.g_caller,'WSH') like 'WMS%' THEN --{
               --
               IF l_valid_index_tab.COUNT <> l_detail_info_tab.COUNT THEN
                  --
                  IF l_debug_on THEN
                      --
                      WSH_DEBUG_SV.logmsg(l_module_name,'ERROR not all line are validated successfully',WSH_DEBUG_SV.C_PROC_LEVEL);
                      WSH_DEBUG_SV.log(l_module_name,'valid count',l_valid_index_tab.COUNT);
                      WSH_DEBUG_SV.log(l_module_name,'total count',l_detail_info_tab.COUNT);
                      --
                  END IF;
                  --
                  RAISE FND_API.G_EXC_ERROR;
                  --
               END IF;
               --
            END IF; --}

            Update_Delivery_Detail(
                p_detail_info_tab      => l_detail_info_tab,
                p_valid_index_tab      => l_valid_index_tab,
                x_return_status        => l_return_status,
                x_msg_count            => l_msg_count,
                x_msg_data             => l_msg_data,
                p_caller               => p_in_rec.caller);

                  --
                  wsh_util_core.api_post_call(
                      p_return_status => l_return_status,
                      x_num_warnings  => l_number_of_warnings,
                      x_num_errors    => l_number_of_errors,
                      p_msg_data      => l_msg_data
                      );

-- jckwok: code for action_code = 'CANCEL'
  ELSIF (p_in_rec.action_code = 'CANCEL') THEN

      Cancel_Delivery_Detail(
                p_detail_info_tab     =>  l_detail_info_tab,
                x_return_status       =>  l_return_status,
                x_msg_count           =>  l_msg_count,
                x_msg_data            =>  l_msg_data,
                p_caller              =>  p_in_rec.caller);

            wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                  x_num_warnings     =>l_number_of_warnings,
                                  x_num_errors       =>l_number_of_errors);

-- jckwok

       END IF;

       IF l_number_of_warnings > 0 THEN
         IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name, 'Number of warnings', l_number_of_warnings);
         END IF;

         RAISE wsh_util_core.g_exc_warning;
      END IF;

       -- Standard check of p_commit.
       IF FND_API.To_Boolean( p_commit ) THEN
          IF(l_debug_on) THEN
             wsh_debug_sv.logmsg(l_module_name, 'Commit Work');
          END IF;
               --
               -- Start code for Bugfix 4070732
               --
              IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;

                 l_reset_flags := FALSE;

                 WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => l_reset_flags,
						       x_return_status => l_return_status);

                 IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                 END IF;

                 IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                 ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    RAISE WSH_UTIL_CORE.G_EXC_WARNING;
                 END IF;

              END IF;
             --
             -- End of code for Bugfix 4070732
             --
          COMMIT WORK;
       END IF;

           --bug 4070732
           --End of the API handling of calls to process_stops_for_load_tender
          IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
          --{
             IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
             --{

                IF FND_API.TO_BOOLEAN(p_commit) THEN

                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;

                 WSH_UTIL_CORE.reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);
		ELSE

                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;

                 WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);
		END IF;

                 IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                 END IF;


                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                    x_return_status := l_return_status;

                    IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                   WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                    THEN
                       IF NOT(FND_API.TO_BOOLEAN(p_commit)) THEN
                        ROLLBACK TO CREATE_UPDATE_DEL_DETAIL_GRP2;
		       END IF;
                    END IF;
                 END IF;
               --}
              END IF;
           --}
          END IF;

    --bug 4070732
       FND_MSG_PUB.Count_And_Get
         (
          p_count  => x_msg_count,
          p_data  =>  x_msg_data,
          p_encoded => FND_API.G_FALSE
         );


      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
--
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO CREATE_UPDATE_DEL_DETAIL_GRP2;
                x_return_status := FND_API.G_RET_STS_ERROR ;
             --
             -- Start code for Bugfix 4070732
             --
             IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name)
             THEN
             --{
                IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
                --{
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;

                  WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                     x_return_status => l_return_status);

                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                  END IF;

                  IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                     x_return_status := l_return_status;
                  END IF;
                --}
                END IF;
              --}
             END IF;
             --
             -- End of Code Bugfix 4070732
             --
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );



                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
                  END IF;
                  --
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO CREATE_UPDATE_DEL_DETAIL_GRP2;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             --
             -- Start code for Bugfix 4070732
             --
             IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name)
             THEN
             --{
                IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
                --{
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;

                  WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                     x_return_status => l_return_status);

                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                  END IF;
                --}
                END IF;
              --}
             END IF;
             --
             -- End of Code Bugfix 4070732
             --
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
        WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
             x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
             --
             -- Start code for Bugfix 4070732
             --
            IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
              IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;

                  WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => TRUE,
                                                         x_return_status => l_return_status);

                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                  END IF;

                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                      x_return_status := l_return_status;

                    IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                   WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                    THEN
                        ROLLBACK TO CREATE_UPDATE_DEL_DETAIL_GRP2;
                    END IF;
                  END IF;

               END IF;
            END IF;
            --
            -- End of Code Bugfix 4070732
            --
             FND_MSG_PUB.Count_And_Get
              (
                p_count  => x_msg_count,
                p_data  =>  x_msg_data,
                p_encoded => FND_API.G_FALSE
              );



        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
       END IF;
--
        WHEN mark_reprice_error then
                FND_MESSAGE.Set_Name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
                wsh_util_core.add_message(x_return_status, l_module_name);
                x_return_status := l_return_status;
             --
             -- Start code for Bugfix 4070732
             --
            IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
              IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;

                  WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => TRUE,
                                                         x_return_status => l1_return_status);

                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'l1_return_status',l1_return_status);
                  END IF;

                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                   IF l1_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
                        IF l1_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                          l_return_status := l1_return_status;
			END IF;
		      ELSE
                         l_return_status := l1_return_status;
		      END IF;
                   END IF;
                 END IF;

                 x_return_status := l_return_status;
                    IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                   WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                    THEN
                        ROLLBACK TO CREATE_UPDATE_DEL_DETAIL_GRP2;
                    END IF;

               END IF;
            END IF;
            --
            -- End of Code Bugfix 4070732
            --
                 FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );
    --

                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'MARK_REPRICE_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:MARK_REPRICE_ERROR');
                END IF;
                --
        WHEN OTHERS THEN
                ROLLBACK TO CREATE_UPDATE_DEL_DETAIL_GRP2;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
               wsh_util_core.add_message(x_return_status, l_module_name);
               WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_GRP.Create_Update_Delivery_Detail');
             --
             -- Start code for Bugfix 4070732
             --
             IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name)
             THEN
             --{
                IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
                --{
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;

                  WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                     x_return_status => l_return_status);

                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                  END IF;
                --}
                END IF;
              --}
             END IF;
             --
             -- End of Code Bugfix 4070732
             --
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
  END Create_Update_Delivery_Detail;

-- ---------------------------------------------------------------------
-- Procedure: Get_Carton_Grouping
--
-- Parameters:
--
-- Description:  This procedure is the new API for wrapping the logic of autcreate_deliveries.
-- Usage: Called by WMS code to return carton grouping table.
-- Bug 6790938 :
-- Calling Find_Matching_Groups api instead of calling Autocreate_deliveries
-- -----------------------------------------------------------------------
-- Added for Bug 4295161
PROCEDURE Get_Carton_Grouping (p_line_rows             IN          WSH_UTIL_CORE.id_tab_type,
                               x_grouping_rows         OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
                               x_return_status         OUT NOCOPY  VARCHAR2) IS

  l_attr_tab          wsh_delivery_autocreate.grp_attr_tab_type;
  l_group_tab         wsh_delivery_autocreate.grp_attr_tab_type;
  l_action_rec        wsh_delivery_autocreate.action_rec_type;
  l_target_rec        wsh_delivery_autocreate.grp_attr_rec_type;
  l_matched_entities  wsh_util_core.id_tab_type;
  l_out_rec           wsh_delivery_autocreate.out_rec_type;

  l_debug_on Boolean;

  --bug 7171766
  l_match_found BOOLEAN;
  l_group_match_seq_tbl    WSH_PICK_LIST.group_match_seq_tab_type;
  K NUMBER ;

  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CARTON_GROUPING';

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.LOG(l_module_name, 'Count of p_line_rows-', p_line_rows.count);
  END IF;
  --
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  FOR i in 1..p_line_rows.count
  LOOP
     l_attr_tab(i).entity_id   := p_line_rows(i);
     l_attr_tab(i).entity_type := 'DELIVERY_DETAIL';
  END LOOP;
  l_action_rec.action := 'MATCH_GROUPS';

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_AUTOCREATE.Find_Matching_Groups', WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  WSH_DELIVERY_AUTOCREATE.Find_Matching_Groups (
               p_attr_tab          =>  l_attr_tab,
               p_action_rec        =>  l_action_rec,
               p_target_rec        =>  l_target_rec,
               p_group_tab         =>  l_group_tab,
               x_matched_entities  =>  l_matched_entities,
               x_out_rec           =>  l_out_rec,
               x_return_status     =>  x_return_status );

 --bug 7171766
  l_group_match_seq_tbl.delete;

  FOR i in 1.. l_attr_tab.count LOOP
  --{
      l_match_found :=FALSE;
      IF l_group_match_seq_tbl.count > 0 THEN
      --{
          FOR k in l_group_match_seq_tbl.FIRST..l_group_match_seq_tbl.LAST LOOP
          --{
	      IF l_attr_tab(i).group_id = l_group_match_seq_tbl(k).match_group_id THEN
	      --{
	          l_group_match_seq_tbl(i).delivery_group_id := l_group_match_seq_tbl(k).delivery_group_id ;
	          l_match_found := TRUE;
	          EXIT;
              --}
              End IF;
          --}
         END LOOP;
     --}
     END IF ;

     IF NOT l_match_found THEN
     --{
         l_group_match_seq_tbl(i).match_group_id :=l_attr_tab(i).group_id;
         select WSH_DELIVERY_GROUP_S.nextval into l_group_match_seq_tbl(i).delivery_group_id  from dual;
     --}
     End IF;

     x_grouping_rows(i) := l_group_match_seq_tbl(i).delivery_group_id;
  --}
  END LOOP;
  --bug 7171766 till here

  IF l_debug_on THEN
    WSH_DEBUG_SV.LOG(l_module_name, 'Count of x_grouping_rows -', x_grouping_rows.count);
    WSH_DEBUG_SV.LOG(l_module_name, 'x_return_status', x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
    END IF;

  WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
    END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.add_message(x_return_status, l_module_name);
    WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_GRP.Get_Carton_Grouping');
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
END Get_Carton_Grouping;

END WSH_DELIVERY_DETAILS_GRP;

/
