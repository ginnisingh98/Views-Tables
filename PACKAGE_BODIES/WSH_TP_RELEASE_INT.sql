--------------------------------------------------------
--  DDL for Package Body WSH_TP_RELEASE_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_TP_RELEASE_INT" as
/* $Header: WSHTPREB.pls 120.7 2006/01/18 09:52:43 parkhj noship $ */

G_TP_RELEASE_CODE CONSTANT VARCHAR2(30) := WSH_TP_RELEASE_GRP.G_TP_RELEASE_CODE;

G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_TP_RELEASE_INT';


TYPE date_tab_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE planned_flag_tab_type IS TABLE OF WSH_TRIPS.PLANNED_FLAG%TYPE INDEX BY BINARY_INTEGER;


-- This cursor c_map_lines is used by generate_lock_candidates
-- It needs to be internally global because of reference
-- in an internal API attributes_match.
-- choice 1 : SE lines in SE deliveries matching the plan's lines
-- and their deliveries that were firm at time of snapshot
-- (which may or may not be currently firmed)
-- choice 2 : unassigned SE lines
-- choice 3 : SE lines in other SE deliveries that are not firmed
CURSOR c_map_lines(x_plan_delivery_detail_id    IN NUMBER,
                   x_plan_delivery_id           IN NUMBER,
                   x_plan_source_code           IN VARCHAR2,
                   x_plan_source_header_id      IN NUMBER,
                   x_plan_source_line_id        IN NUMBER,
                   x_plan_source_line_set_id    IN NUMBER,
                   x_plan_po_shipment_line_id   IN NUMBER, -- inbound/drop
                   x_plan_ship_from_location_id IN NUMBER,
                   x_plan_ship_to_location_id   IN NUMBER) IS
SELECT
     decode(wda.delivery_id, x_plan_delivery_id,1,null, 2, 3) choice,
     decode(wdd.delivery_detail_id,
               x_plan_delivery_detail_id, 1,
               decode(wdd.source_line_id,
                         x_plan_source_line_id, 2,
                         3)) scope,
     wdd.delivery_detail_id,
     nvl(wdd.shipped_quantity, nvl(wdd.picked_quantity, wdd.requested_quantity)) quantity,
     wdd.requested_quantity_uom quantity_uom,
     wdd.source_code,
     wdd.source_header_id,
     wdd.source_line_set_id,
     wdd.source_line_id,
     wdd.ship_from_location_id,
     wdd.ship_to_location_id,
     wdd.inventory_item_id,
     wdd.released_status,
     wdd.move_order_line_id,
     wdd.line_direction,
     wdd.ship_set_id,
     wdd.po_shipment_line_id,  -- inbound/drop
     wdd.top_model_line_id,
     wdd.ato_line_id,
     wdd.ship_model_complete_flag,
     wdd.organization_id,
     wdd.customer_id,
     wdd.fob_code,
     wdd.freight_terms_code,
     wdd.intmed_ship_to_location_id,
     wdd.ship_method_code,
     wdd.mode_of_transport,
     wdd.service_level,
     wdd.carrier_id,
     wda.parent_delivery_detail_id parent_cont_id,
     wda.delivery_id,
     wdd.src_requested_quantity,
     wdd.src_requested_quantity_uom,
     wdd.shipping_control,
     wdd.vendor_id,
     wdd.party_id,
     wdd.wv_frozen_flag -- WV changes
FROM   wsh_delivery_details wdd,
       wsh_delivery_assignments_v wda
WHERE
     (
          wdd.source_code = x_plan_source_code
      AND wdd.source_header_id = x_plan_source_header_id
      AND (   wdd.source_line_set_id = x_plan_source_line_set_id
           OR wdd.source_line_id     = x_plan_source_line_id)
      AND (   x_plan_po_shipment_line_id IS NULL   -- inbound/drop
           OR wdd.po_shipment_line_id = x_plan_po_shipment_line_id)
     )
     AND wdd.ship_from_location_id = x_plan_ship_from_location_id
     AND wdd.ship_to_location_id = x_plan_ship_to_location_id
     AND wdd.released_status IN ('N', 'R', 'B', 'S', 'Y', 'X')
     AND nvl(wdd.ignore_for_planning,'N') = 'N'
     AND wda.delivery_detail_id = wdd.delivery_detail_id
     AND wdd.container_flag = 'N'
     AND (
          (wda.delivery_id IS NOT NULL
           AND wda.delivery_id = x_plan_delivery_id
           AND x_plan_delivery_id IS NOT NULL
          )
          OR
          (wda.delivery_id IS NULL
          )
          OR
          (exists ( select 'x'
                from wsh_new_deliveries       wnd
                where  wnd.delivery_id = wda.delivery_id
                AND wnd.planned_flag = 'N'
                AND wnd.status_code IN ('OP', 'SA')
                AND wnd.delivery_id <> NVL(x_plan_delivery_id, 0)
                )
          )
         )
ORDER BY choice ASC, scope ASC, quantity DESC;


PROCEDURE init_context(
           x_context                  IN OUT NOCOPY context_rec_type,
           x_plan_details             IN OUT NOCOPY plan_detail_tab_type,
           x_track_conts              IN OUT NOCOPY track_cont_tab_type,
           x_plan_deliveries          IN OUT NOCOPY plan_delivery_tab_type,
           x_plan_legs                IN OUT NOCOPY plan_leg_tab_type,
           x_plan_stops               IN OUT NOCOPY plan_stop_tab_type,
           x_plan_trips               IN OUT NOCOPY plan_trip_tab_type,
           x_plan_trip_moves          IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.plan_trip_move_tab_type,
           x_plan_moves               IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.plan_move_tab_type,
           x_used_details             IN OUT NOCOPY used_details_tab_type,
           x_delivery_unassigns       IN OUT NOCOPY delivery_unassign_tab_type,
           x_trip_unassigns           IN OUT NOCOPY trip_unassign_tab_type,
           x_obsoleted_stops          IN OUT NOCOPY obsoleted_stop_tab_type,
           x_obsoleted_trip_moves     IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.obsoleted_trip_move_tab_type,
           x_errors_tab               IN OUT NOCOPY interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          );

PROCEDURE resync_interface_tables(
           x_context                  IN OUT NOCOPY context_rec_type,
           x_errors_tab               IN OUT NOCOPY interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          );

PROCEDURE generate_lock_candidates(
           x_context                  IN OUT NOCOPY context_rec_type,
           x_plan_details             IN OUT NOCOPY plan_detail_tab_type,
           x_track_conts              IN OUT NOCOPY track_cont_tab_type,
           x_plan_deliveries          IN OUT NOCOPY plan_delivery_tab_type,
           x_plan_legs                IN OUT NOCOPY plan_leg_tab_type,
           x_plan_stops               IN OUT NOCOPY plan_stop_tab_type,
           x_plan_trips               IN OUT NOCOPY plan_trip_tab_type,
           x_plan_trip_moves          IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.plan_trip_move_tab_type,
           x_plan_moves               IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.plan_move_tab_type,
           x_used_details             IN OUT NOCOPY used_details_tab_type,
           x_delivery_unassigns       IN OUT NOCOPY delivery_unassign_tab_type,
           x_trip_unassigns           IN OUT NOCOPY trip_unassign_tab_type,
           x_obsoleted_stops          IN OUT NOCOPY obsoleted_stop_tab_type,
           x_obsoleted_trip_moves     IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.obsoleted_trip_move_tab_type,
           x_errors_tab               IN OUT NOCOPY interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
);

PROCEDURE validate_plan(
           x_context                  IN OUT NOCOPY context_rec_type,
           x_plan_details             IN OUT NOCOPY plan_detail_tab_type,
           x_track_conts              IN OUT NOCOPY track_cont_tab_type,
           x_plan_deliveries          IN OUT NOCOPY plan_delivery_tab_type,
           x_plan_legs                IN OUT NOCOPY plan_leg_tab_type,
           x_plan_stops               IN OUT NOCOPY plan_stop_tab_type,
           x_plan_trips               IN OUT NOCOPY plan_trip_tab_type,
           x_used_details             IN OUT NOCOPY used_details_tab_type,
           x_delivery_unassigns       IN OUT NOCOPY delivery_unassign_tab_type,
           x_trip_unassigns           IN OUT NOCOPY trip_unassign_tab_type,
           x_obsoleted_stops          IN OUT NOCOPY obsoleted_stop_tab_type,
           x_errors_tab               IN OUT NOCOPY interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          );

PROCEDURE reconciliate_plan(
           x_context                  IN OUT NOCOPY context_rec_type,
           x_plan_details             IN OUT NOCOPY plan_detail_tab_type,
           x_track_conts              IN OUT NOCOPY track_cont_tab_type,
           x_plan_deliveries          IN OUT NOCOPY plan_delivery_tab_type,
           x_plan_legs                IN OUT NOCOPY plan_leg_tab_type,
           x_plan_stops               IN OUT NOCOPY plan_stop_tab_type,
           x_plan_trips               IN OUT NOCOPY plan_trip_tab_type,
           x_plan_trip_moves          IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.plan_trip_move_tab_type,
           x_plan_moves               IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.plan_move_tab_type,
           x_used_details             IN OUT NOCOPY used_details_tab_type,
           x_delivery_unassigns       IN OUT NOCOPY delivery_unassign_tab_type,
           x_trip_unassigns           IN OUT NOCOPY trip_unassign_tab_type,
           x_obsoleted_stops          IN OUT NOCOPY obsoleted_stop_tab_type,
           x_obsoleted_trip_moves     IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.obsoleted_trip_move_tab_type,
           x_errors_tab               IN OUT NOCOPY interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          );

PROCEDURE plan_cleanup(
           x_context                  IN OUT NOCOPY context_rec_type,
           x_plan_details             IN OUT NOCOPY plan_detail_tab_type,
           x_plan_deliveries          IN OUT NOCOPY plan_delivery_tab_type,
           x_plan_stops               IN OUT NOCOPY plan_stop_tab_type,
           x_plan_trips               IN OUT NOCOPY plan_trip_tab_type,
           x_trip_unassigns           IN OUT NOCOPY trip_unassign_tab_type,
           x_obsoleted_trip_moves     IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.obsoleted_trip_move_tab_type,
           x_errors_tab               IN OUT NOCOPY interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          );


FUNCTION attributes_match(
           x_attributes IN plan_detail_rec_type,
           x_values     IN c_map_lines%ROWTYPE)
RETURN BOOLEAN;


PROCEDURE flush_used_details(
              x_context              IN OUT NOCOPY context_rec_type,
              x_current_used_details IN OUT NOCOPY used_details_tab_type,
              x_used_details         IN OUT NOCOPY used_details_tab_type,
              x_errors_tab           IN OUT NOCOPY interface_errors_tab_type,
              x_return_status           OUT NOCOPY VARCHAR2);


PROCEDURE map_dangling_containers(
           x_context                  IN OUT NOCOPY context_rec_type,
           p_delivery_index           IN            NUMBER,
           x_plan_deliveries          IN OUT NOCOPY plan_delivery_tab_type,
           x_errors_tab               IN OUT NOCOPY interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          );


PROCEDURE match_deliveries(
           x_context                  IN OUT NOCOPY context_rec_type,
           x_plan_details             IN OUT NOCOPY plan_detail_tab_type,
           x_track_conts              IN OUT NOCOPY track_cont_tab_type,
           x_plan_deliveries          IN OUT NOCOPY plan_delivery_tab_type,
           x_used_details             IN OUT NOCOPY used_details_tab_type,
           x_delivery_unassigns       IN OUT NOCOPY delivery_unassign_tab_type,
           x_errors_tab               IN OUT NOCOPY interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          );


PROCEDURE validate_wms(
           x_context                  IN OUT NOCOPY context_rec_type,
           x_plan_details             IN OUT NOCOPY plan_detail_tab_type,
           x_plan_deliveries          IN OUT NOCOPY plan_delivery_tab_type,
           x_delivery_unassigns       IN OUT NOCOPY delivery_unassign_tab_type,
           x_errors_tab               IN OUT NOCOPY interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          );



PROCEDURE match_trips(
           x_context                  IN OUT NOCOPY context_rec_type,
           x_plan_deliveries          IN OUT NOCOPY plan_delivery_tab_type,
           x_plan_stops               IN OUT NOCOPY plan_stop_tab_type,
           x_plan_trips               IN OUT NOCOPY plan_trip_tab_type,
           x_trip_unassigns           IN OUT NOCOPY trip_unassign_tab_type,
           x_obsoleted_stops          IN OUT NOCOPY obsoleted_stop_tab_type,
           x_errors_tab               IN OUT NOCOPY interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          );


PROCEDURE debug_dump_context(
           x_context                  IN context_rec_type,
           x_plan_details             IN plan_detail_tab_type,
           x_track_conts              IN track_cont_tab_type,
           x_plan_deliveries          IN plan_delivery_tab_type,
           x_plan_legs                IN plan_leg_tab_type,
           x_plan_stops               IN plan_stop_tab_type,
           x_plan_trips               IN plan_trip_tab_type,
           x_plan_trip_moves          IN WSH_FTE_TP_INTEGRATION.plan_trip_move_tab_type,
           x_plan_moves               IN WSH_FTE_TP_INTEGRATION.plan_move_tab_type,
           x_used_details             IN used_details_tab_type,
           x_delivery_unassigns       IN delivery_unassign_tab_type,
           x_trip_unassigns           IN trip_unassign_tab_type,
           x_obsoleted_stops          IN obsoleted_stop_tab_type,
           x_obsoleted_trip_moves     IN WSH_FTE_TP_INTEGRATION.obsoleted_trip_move_tab_type
          );


PROCEDURE copy_delivery_record(
           p_plan_delivery_rec   IN            plan_delivery_rec_type,
           x_delivery_attrs_rec     OUT NOCOPY wsh_new_deliveries_pvt.delivery_rec_type,
           x_return_status          OUT NOCOPY VARCHAR2
          );

PROCEDURE copy_trip_record(
           p_plan_trip_rec   IN            plan_trip_rec_type,
           x_trip_attrs_rec     OUT NOCOPY wsh_trips_pvt.trip_rec_type
          );

PROCEDURE copy_stop_record(
           p_plan_stop_rec   IN            plan_stop_rec_type,
           p_plan_trips      IN            plan_trip_tab_type,
           x_stop_attrs_rec     OUT NOCOPY wsh_trip_stops_pvt.trip_stop_rec_type
          );

PROCEDURE create_update_plan_trips(
           p_phase                    IN            NUMBER,
           x_context                  IN OUT NOCOPY context_rec_type,
           x_plan_trips               IN OUT NOCOPY plan_trip_tab_type,
           x_errors_tab               IN OUT NOCOPY interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          );


PROCEDURE insert_interface_errors(
            p_errors_tab    IN         interface_errors_tab_type,
            x_return_status OUT NOCOPY VARCHAR2);

FUNCTION get_plan_trip_num(
             p_context      IN         context_rec_type)
RETURN VARCHAR2;

PROCEDURE Log_WV_Exceptions(
          p_details_loc_tab in wsh_util_core.id_tab_type,
          p_deliveries_loc_tab in wsh_util_core.id_tab_type,
          p_stops_loc_tab in wsh_util_core.id_tab_type,
          x_return_status out NOCOPY varchar2);


--
--  Procedure:          release_plan
--  Parameters:
--               p_group_ids           list of group_ids to process their
--                                     WSH_TRIPS_INTERFACE records and
--                                     their associated tables' records.
--               p_commit_flag         FND_API.G_TRUE - commit changes; FND_API.G_FALSE - do not commit
--               x_return_status       return status
--                                        success means all groups have been released.
--                                        warning means at least one group is released and at least one
--                                                      group failed.
--                                        error   means all groups failed.
--                                        caller needs to look at WSH_INTERFACE_ERRORS
--                                        to check for groups that failed.
--
--  Description:
--               Reconciliate shipping data with the transportation
--               plan populated in the WSH and FTE interface tables.
--
--
PROCEDURE release_plan(
  p_group_ids              IN            WSH_TP_RELEASE_GRP.id_tab_type,
  p_commit_flag            IN            VARCHAR2,
  x_return_status          OUT NOCOPY    VARCHAR2)
IS
  l_index BINARY_INTEGER := NULL;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'RELEASE_PLAN';
  --
  l_debug_on BOOLEAN;
  --
  l_savepoint_set BOOLEAN := FALSE;

  l_context                  context_rec_type;
  l_plan_details             plan_detail_tab_type;
  l_track_conts              track_cont_tab_type;
  l_plan_deliveries          plan_delivery_tab_type;
  l_plan_legs                plan_leg_tab_type;
  l_plan_stops               plan_stop_tab_type;
  l_plan_trips               plan_trip_tab_type;
  l_plan_trip_moves          WSH_FTE_TP_INTEGRATION.plan_trip_move_tab_type;
  l_plan_moves               WSH_FTE_TP_INTEGRATION.plan_move_tab_type;
  l_used_details             used_details_tab_type;
  l_delivery_unassigns       delivery_unassign_tab_type;
  l_trip_unassigns           trip_unassign_tab_type;
  l_obsoleted_stops          obsoleted_stop_tab_type;
  l_obsoleted_trip_moves     WSH_FTE_TP_INTEGRATION.obsoleted_trip_move_tab_type;
  l_errors_tab               interface_errors_tab_type;
  l_return_status            VARCHAR2(1);
  l_group_error_count        NUMBER := 0;

BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  l_index := p_group_ids.FIRST;
  WHILE l_index IS NOT NULL LOOP
    SAVEPOINT before_group;
    l_savepoint_set := TRUE;

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'looping group_id', p_group_ids(l_index));
    END IF;

    l_context.group_id     := p_group_ids(l_index);
    l_context.wms_in_group := FALSE;

    -- reset the variables before mapping each group.
    Init_Context(
       x_context                  => l_context,
       x_plan_details             => l_plan_details,
       x_track_conts              => l_track_conts,
       x_plan_deliveries          => l_plan_deliveries,
       x_plan_legs                => l_plan_legs,
       x_plan_stops               => l_plan_stops,
       x_plan_trips               => l_plan_trips,
       x_plan_trip_moves          => l_plan_trip_moves,
       x_plan_moves               => l_plan_moves,
       x_used_details             => l_used_details,
       x_delivery_unassigns       => l_delivery_unassigns,
       x_trip_unassigns           => l_trip_unassigns,
       x_obsoleted_stops          => l_obsoleted_stops,
       x_obsoleted_trip_moves     => l_obsoleted_trip_moves,
       x_errors_tab               => l_errors_tab,
       x_return_status            => l_return_status
    );

    IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR))  THEN
      GOTO group_error;
    END IF;


    -- update wsh_del_details_interface
    -- with current source_line_set and source_line_id of
    -- delivery details that were snapshot or their associated details.
    Resync_Interface_Tables(
       x_context                  => l_context,
       x_errors_tab               => l_errors_tab,
       x_return_status => l_return_status
    );

    IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR))  THEN
      GOTO group_error;
    END IF;


    -- map the interface records to shipping records
    -- and lock the shipping records and their associations.
    Generate_Lock_Candidates(
       x_context                  => l_context,
       x_plan_details             => l_plan_details,
       x_track_conts              => l_track_conts,
       x_plan_deliveries          => l_plan_deliveries,
       x_plan_legs                => l_plan_legs,
       x_plan_stops               => l_plan_stops,
       x_plan_trips               => l_plan_trips,
       x_plan_trip_moves          => l_plan_trip_moves,
       x_plan_moves               => l_plan_moves,
       x_used_details             => l_used_details,
       x_delivery_unassigns       => l_delivery_unassigns,
       x_trip_unassigns           => l_trip_unassigns,
       x_obsoleted_stops          => l_obsoleted_stops,
       x_obsoleted_trip_moves     => l_obsoleted_trip_moves,
       x_errors_tab               => l_errors_tab,
       x_return_status => l_return_status
    );

    IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR))  THEN
      GOTO group_error;
    END IF;

    -- identify shipping records that need to be
    -- unassigned from the mapped shipping records
    -- and perform other validations not done by above calls.
    Validate_Plan(
       x_context                  => l_context,
       x_plan_details             => l_plan_details,
       x_track_conts              => l_track_conts,
       x_plan_deliveries          => l_plan_deliveries,
       x_plan_legs                => l_plan_legs,
       x_plan_stops               => l_plan_stops,
       x_plan_trips               => l_plan_trips,
       x_used_details             => l_used_details,
       x_delivery_unassigns       => l_delivery_unassigns,
       x_trip_unassigns           => l_trip_unassigns,
       x_obsoleted_stops          => l_obsoleted_stops,
       x_errors_tab               => l_errors_tab,
       x_return_status => l_return_status
    );

    IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR))  THEN
      GOTO group_error;
    END IF;

    -- execute the actions to split, create, unassign, update
    -- and assign shipping records as per the plan.
    Reconciliate_Plan(
       x_context                  => l_context,
       x_plan_details             => l_plan_details,
       x_track_conts              => l_track_conts,
       x_plan_deliveries          => l_plan_deliveries,
       x_plan_legs                => l_plan_legs,
       x_plan_stops               => l_plan_stops,
       x_plan_trips               => l_plan_trips,
       x_plan_trip_moves          => l_plan_trip_moves,
       x_plan_moves               => l_plan_moves,
       x_used_details             => l_used_details,
       x_delivery_unassigns       => l_delivery_unassigns,
       x_trip_unassigns           => l_trip_unassigns,
       x_obsoleted_stops          => l_obsoleted_stops,
       x_obsoleted_trip_moves     => l_obsoleted_trip_moves,
       x_errors_tab               => l_errors_tab,
       x_return_status => l_return_status
    );

    IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR))  THEN
      GOTO group_error;
    END IF;



    -- remove deliveries and trips that have become empty
    -- and log exceptions against plan's delivery details
    -- whose dates do not agree with the dates of
    -- their initial pick up and ultimate drop off stops.
    Plan_Cleanup(
       x_context                  => l_context,
       x_plan_details             => l_plan_details,
       x_plan_deliveries          => l_plan_deliveries,
       x_plan_stops               => l_plan_stops,
       x_plan_trips               => l_plan_trips,
       x_trip_unassigns           => l_trip_unassigns,
       x_obsoleted_trip_moves     => l_obsoleted_trip_moves,
       x_errors_tab               => l_errors_tab,
       x_return_status => l_return_status
    );

    IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR))  THEN
      GOTO group_error;
    END IF;

    IF l_debug_on THEN
      -- dump will help troubleshoot issues with successful release.
      debug_dump_Context(
       x_context                  => l_context,
       x_plan_details             => l_plan_details,
       x_track_conts              => l_track_conts,
       x_plan_deliveries          => l_plan_deliveries,
       x_plan_legs                => l_plan_legs,
       x_plan_stops               => l_plan_stops,
       x_plan_trips               => l_plan_trips,
       x_plan_trip_moves          => l_plan_trip_moves,
       x_plan_moves               => l_plan_moves,
       x_used_details             => l_used_details,
       x_delivery_unassigns       => l_delivery_unassigns,
       x_trip_unassigns           => l_trip_unassigns,
       x_obsoleted_stops          => l_obsoleted_stops,
       x_obsoleted_trip_moves     => l_obsoleted_trip_moves
      );
    END IF;

    GOTO next_record;

<<group_error>>
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'return_status failing group', l_return_status);
    END IF;
    l_savepoint_set := FALSE;
    ROLLBACK TO before_group;

    IF l_debug_on THEN
      -- dump will help troubleshoot the plan failure.
      debug_dump_Context(
       x_context                  => l_context,
       x_plan_details             => l_plan_details,
       x_track_conts              => l_track_conts,
       x_plan_deliveries          => l_plan_deliveries,
       x_plan_legs                => l_plan_legs,
       x_plan_stops               => l_plan_stops,
       x_plan_trips               => l_plan_trips,
       x_plan_trip_moves          => l_plan_trip_moves,
       x_plan_moves               => l_plan_moves,
       x_used_details             => l_used_details,
       x_delivery_unassigns       => l_delivery_unassigns,
       x_trip_unassigns           => l_trip_unassigns,
       x_obsoleted_stops          => l_obsoleted_stops,
       x_obsoleted_trip_moves     => l_obsoleted_trip_moves
      );
    END IF;

    IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
       -- unexpected error needs to set a TP failure message,
       -- so that we can pull the detail messages.
       stamp_interface_error(p_group_id => l_context.group_id,
                              p_entity_table_name => 'NONE',
                              p_entity_interface_id => -1,
                              p_message_name => 'WSH_TP_F_UNEXP_ERROR',  -- new message
                              x_errors_tab => l_errors_tab,
                              x_return_status => l_return_status);
    END IF;

    IF l_errors_tab.count > 0 THEN
      insert_interface_errors(
           p_errors_tab    => l_errors_tab,
           x_return_status => l_return_status);
    END IF;
    l_group_error_count := l_group_error_count + 1;

<<next_record>>
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'finished group_id', p_group_ids(l_index));
    END IF;

    l_savepoint_set := FALSE;
    IF p_commit_flag = FND_API.G_TRUE THEN
      COMMIT;
    END IF;

    -- before we go on to the next group, clear the errors.
    l_errors_tab.DELETE;
    l_index := p_group_ids.NEXT(l_index);

  END LOOP;


  IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_group_error_count', l_group_error_count);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF      l_group_error_count > 0
      AND l_group_error_count < p_group_ids.COUNT THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  ELSIF l_group_error_count = p_group_ids.COUNT THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF l_savepoint_set THEN
        ROLLBACK TO before_group;
      END IF;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TP_RELEASE.RELEASE_PLAN',
                        l_module_name);

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END release_plan;




--
--  Procedure:          purge_interface_tables
--  Parameters:
--               p_group_ids           list of group_ids to purge their
--                                     WSH_TRIPS_INTERFACE records and
--                                     their associated tables' records.
--                                     WSH_INTERFACE_ERRORS will be purged.
--               p_commit_flag         FND_API.G_TRUE - commit changes; FND_API.G_FALSE - do not commit
--               x_return_status       return status
--
--  Description:
--               Delete the records from WSH and FTE interface tables.
--
PROCEDURE purge_interface_tables(
  p_group_ids              IN            WSH_TP_RELEASE_GRP.id_tab_type,
  p_commit_flag            IN            VARCHAR2,
  x_return_status          OUT NOCOPY    VARCHAR2)
IS
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PURGE_INTERFACE_TABLES';
  --
  l_debug_on BOOLEAN;
  --
BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;
  --
  --

  SAVEPOINT before_purge;

  -- Purge wsh_del_details interface.
  -- Remove usage of distinct in code for Bug 3821688 from each Bulk Delete

  FORALL i in p_group_ids.FIRST ..p_group_ids.LAST
    delete from wsh_del_details_interface wddi
    where wddi.delivery_detail_interface_id in (
    select wdai.delivery_detail_interface_id
    from   wsh_trips_interface wti,
         wsh_trip_stops_interface wtsi,
         wsh_del_legs_interface wdli,
         wsh_del_assgn_interface wdai
    where  wti.group_id = p_group_ids(i)
    and    wti.trip_interface_id = wtsi.trip_interface_id
    and    wti.interface_action_code = G_TP_RELEASE_CODE
    and    wtsi.stop_interface_id = wdli.pick_up_stop_interface_id
    and    wtsi.interface_action_code = G_TP_RELEASE_CODE
    and    wdli.delivery_interface_id = wdai.delivery_interface_id
    and    wdli.interface_action_code = G_TP_RELEASE_CODE
    and    wdai.delivery_interface_id is not null
    and    wdai.interface_action_code = G_TP_RELEASE_CODE)
    and    wddi.interface_action_code = G_TP_RELEASE_CODE;

  -- Purge wsh_del_assgn_interface

  FORALL i in p_group_ids.FIRST ..p_group_ids.LAST
    delete from wsh_del_assgn_interface wdai
    where  wdai.delivery_interface_id in (
    select wdli.delivery_interface_id
    from   wsh_trips_interface wti,
           wsh_trip_stops_interface wtsi,
           wsh_del_legs_interface wdli
    where  wti.group_id = p_group_ids(i)
    and    wti.trip_interface_id = wtsi.trip_interface_id
    and    wti.interface_action_code = G_TP_RELEASE_CODE
    and    wtsi.stop_interface_id = wdli.pick_up_stop_interface_id
    and    wtsi.interface_action_code = G_TP_RELEASE_CODE
    and    wdli.interface_action_code = G_TP_RELEASE_CODE)
    and    wdai.interface_action_code = G_TP_RELEASE_CODE;


  -- Purge wsh_new_del_interface

  FORALL i in p_group_ids.FIRST ..p_group_ids.LAST
    delete from wsh_new_del_interface wndi
    where  wndi.delivery_interface_id in (
    select wdli.delivery_interface_id
    from   wsh_trips_interface wti,
           wsh_trip_stops_interface wtsi,
           wsh_del_legs_interface wdli
    where  wti.group_id = p_group_ids(i)
    and    wti.trip_interface_id = wtsi.trip_interface_id
    and    wti.interface_action_code = G_TP_RELEASE_CODE
    and    wtsi.stop_interface_id = wdli.pick_up_stop_interface_id
    and    wtsi.interface_action_code = G_TP_RELEASE_CODE
    and    wdli.interface_action_code = G_TP_RELEASE_CODE)
    and    wndi.interface_action_code = G_TP_RELEASE_CODE;

  -- Purge wsh_del_legs_interface

  FORALL i in p_group_ids.FIRST ..p_group_ids.LAST
    delete from wsh_del_legs_interface wdli
    where wdli.pick_up_stop_interface_id in (
    select wtsi.stop_interface_id
    from   wsh_trips_interface wti,
           wsh_trip_stops_interface wtsi
    where  wti.group_id = p_group_ids(i)
    and    wti.trip_interface_id = wtsi.trip_interface_id
    and    wti.interface_action_code = G_TP_RELEASE_CODE
    and    wtsi.interface_action_code = G_TP_RELEASE_CODE)
    and    wdli.interface_action_code = G_TP_RELEASE_CODE;

  -- Purge wsh_trip_stops_interface

  FORALL i in p_group_ids.FIRST ..p_group_ids.LAST
    delete from wsh_trip_stops_interface wtsi
    where wtsi.trip_interface_id in (
    select wtsi.stop_interface_id
    from   wsh_trips_interface wti
    where  wti.group_id = p_group_ids(i)
    and    wti.interface_action_code = G_TP_RELEASE_CODE)
    and    wtsi.interface_action_code = G_TP_RELEASE_CODE;


  -- Purge continuous moves in FTE interface tables

  WSH_FTE_TP_INTEGRATION.purge_interface_tables(
    p_group_ids     => p_group_ids,
    x_return_status => x_return_status);

  IF x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                         WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'FTE interface tables failed: x_return_status', x_return_status);
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     RETURN;
  END IF;


  -- Purge wsh_trips_interface
  -- (Trips have to be the last entity interface table purged
  --  because this is the only entity interface table having GROUP_ID.)

  FORALL i in p_group_ids.FIRST ..p_group_ids.LAST
    delete from wsh_trips_interface wti
    where wti.group_id = p_group_ids(i)
    and wti.INTERFACE_ACTION_CODE = G_TP_RELEASE_CODE;


  -- Purge wsh_interface_errors

  FORALL i in p_group_ids.FIRST ..p_group_ids.LAST
    delete from wsh_interface_errors wie
    where wie.interface_error_group_id = p_group_ids(i)
    and wie.interface_action_code = G_TP_RELEASE_CODE;


  IF p_commit_flag = FND_API.G_TRUE THEN
     commit;
  END IF;


  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  --
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TP_RELEASE.PURGE_INTERFACE_TABLES',
                        l_module_name);

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    ROLLBACK TO before_purge;

END purge_interface_tables;




--
--  Procedure:          init_context
--  Parameters:
--               x_context             context in this session
--               x_plan_details        list of delivery details mapped to interface lines
--               x_track_conts         list of topmost containers to track
--               x_plan_deliveries     list of deliveries mapped to interface deliveries
--               x_plan_legs           list of delivery legs mapped to interface legs
--               x_plan_stops          list of stops mapped to interface stops
--               x_plan_trips          list of trips mapped to interface trips
--               x_plan_trip_moves     list of trip moves mapped to interface trip moves (FTE)
--               x_plan_moves          list of moves mapped to interface moves (FTE)
--               x_used_details        list of delivery details partially used by the plan
--               x_delivery_unassigns  list of delivery lines to unassign from their deliveries
--               x_trip_unassigns      list of deliveries to unassign from their trips
--               x_obsoleted_stops     list of mapped trips' stops that are not mapped in the plan
--               x_obsoleted_trip_moves  list of mapped trips' moves that are not mapped in the plan
--               x_errors_tab          list of errors to insert into wsh_interface_errors at the end
--               x_return_status       return status
--
--  Description:
--               Clears the message stack and context at the beginning
--               before processing a group's release plan.
--
PROCEDURE init_context(
           x_context                  IN OUT NOCOPY context_rec_type,
           x_plan_details             IN OUT NOCOPY plan_detail_tab_type,
           x_track_conts              IN OUT NOCOPY track_cont_tab_type,
           x_plan_deliveries          IN OUT NOCOPY plan_delivery_tab_type,
           x_plan_legs                IN OUT NOCOPY plan_leg_tab_type,
           x_plan_stops               IN OUT NOCOPY plan_stop_tab_type,
           x_plan_trips               IN OUT NOCOPY plan_trip_tab_type,
           x_plan_trip_moves          IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.plan_trip_move_tab_type,
           x_plan_moves               IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.plan_move_tab_type,
           x_used_details             IN OUT NOCOPY used_details_tab_type,
           x_delivery_unassigns       IN OUT NOCOPY delivery_unassign_tab_type,
           x_trip_unassigns           IN OUT NOCOPY trip_unassign_tab_type,
           x_obsoleted_stops          IN OUT NOCOPY obsoleted_stop_tab_type,
           x_obsoleted_trip_moves     IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.obsoleted_trip_move_tab_type,
           x_errors_tab               IN OUT NOCOPY interface_errors_tab_type,
           x_return_status   OUT NOCOPY VARCHAR2
          )
IS
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INIT_CONTEXT';
  --
  l_debug_on BOOLEAN;
BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;
  --
  --

  -- Bug 3283987, initialize mesg stack for each group.
  FND_MSG_PUB.initialize;

  x_plan_details.DELETE;
  x_track_conts.DELETE;
  x_plan_deliveries.DELETE;
  x_plan_legs.DELETE;
  x_plan_stops.DELETE;
  x_plan_trips.DELETE;
  x_plan_trip_moves.DELETE;
  x_plan_moves.DELETE;
  x_used_details.DELETE;
  x_delivery_unassigns.DELETE;
  x_trip_unassigns.DELETE;
  x_obsoleted_stops.DELETE;
  x_obsoleted_trip_moves.DELETE;
  x_context.wv_exception_details.delete;
  x_context.wv_exception_dels.delete;
  x_context.wv_exception_stops.delete;

  -- J+ project, TP owns this profile
  -- If profile is set then auto tender the trips
  IF  fnd_profile.value('MST_AUTO_TENDER_ON') = 'Y' THEN
    x_context.auto_tender_flag := 'Y';
  ELSE
    x_context.auto_tender_flag := 'N';
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'Auto Tender Flag', x_context.auto_tender_flag);
  END IF;

  x_context.linked_trip_count := 0;

  --
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TP_RELEASE.INIT_CONTEXT',
                        l_module_name);

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END init_context;




--
--  Procedure:          resync_interface_tables
--  Parameters:
--               x_context             context in this session
--               x_errors_tab          list of errors to insert into wsh_interface_errors at the end
--               x_return_status       return status
--
--  Description:
--               Resynchronizes the interface tables' records with their base table records'
--               values that may have been changed since the snapshot:
--               Outbound:
--               * fail plan if lines are completely canceled or shipped
--               * refresh the delivery detail's source_line_id, source_line_set_id
--               Inbound/Drop:
--               * fail plan if lines are completely closed (L) or shipped (C) or purged (P).
--               * refresh the delivery detail's po_shipment_line_id and its number
--                    (TP releases only po_shipment_line_number)
--
PROCEDURE resync_interface_tables(
           x_context                  IN OUT NOCOPY context_rec_type,
           x_errors_tab               IN OUT NOCOPY interface_errors_tab_type,
           x_return_status   OUT NOCOPY VARCHAR2
          )
IS
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'RESYNC_INTERFACE_TABLES';
  --
  l_debug_on BOOLEAN;

  -- this cursor list the interface lines
  cursor c_tp_released_lines (p_group_id in number,
                              p_dir1     in varchar2,
                              p_dir2     in varchar2) is
  select distinct wddi.delivery_detail_interface_id delivery_detail_interface_id,
         wddi.delivery_detail_id delivery_detail_id,
         wddi.split_from_delivery_detail_id split_from_delivery_detail_id,
         wddi.source_code,
         wddi.source_header_id,
         wddi.source_line_id,
         wddi.source_line_set_id,
         wndi.tp_delivery_number
  from   wsh_trips_interface wti,
         wsh_trip_stops_interface wtsi,
         wsh_del_legs_interface wdli,
         wsh_del_assgn_interface wdai,
         wsh_del_details_interface wddi,
         wsh_new_del_interface wndi
  where  wti.group_id = p_group_id
  and    wti.trip_interface_id = wtsi.trip_interface_id
  and    wti.interface_action_code = G_TP_RELEASE_CODE
  and    wtsi.stop_interface_id = wdli.pick_up_stop_interface_id
  and    wtsi.interface_action_code = G_TP_RELEASE_CODE
  and    wdli.delivery_interface_id = wdai.delivery_interface_id
  and    wdli.interface_action_code = G_TP_RELEASE_CODE
  and    wdai.delivery_interface_id is not null
  and    wdai.interface_action_code = G_TP_RELEASE_CODE
  and    wddi.delivery_detail_interface_id = wdai.delivery_detail_interface_id
  and    wddi.interface_action_code = G_TP_RELEASE_CODE
  and    wddi.container_flag = 'N'
  and    wddi.requested_quantity <> 0 -- bug 4322654
  and    wndi.delivery_interface_id = wdli.delivery_interface_id
  and    wndi.interface_action_code = G_TP_RELEASE_CODE
  and    NVL(wddi.line_direction, 'O') IN (p_dir1, p_dir2);

  -- outbound: this cursor checks if the delivery detail or other delivery
  -- details in its order line are available (not canceled or shipped).
  cursor c_check_detail_valid (p_delivery_detail_id in number) is
  select a.released_status, a.delivery_detail_id
  from wsh_delivery_details a,
       wsh_delivery_details b
  where b.delivery_detail_id  = p_delivery_detail_id
  and b.released_status = 'D'
  and a.source_code    = b.source_code
  and a.source_line_id = b.source_line_id
  and a.delivery_detail_id <> b.delivery_detail_id
  and a.released_status NOT IN ('C', 'D')
  and rownum = 1
  UNION
  select released_status, delivery_detail_id
  from wsh_delivery_details
  where released_status NOT IN ('C', 'D')
  and delivery_detail_id = p_delivery_detail_id;

  -- outbound: this cursor checks if the line set can be found
  -- for the delivery detail where delivery
  -- details in this set are available (not canceled or shipped).
  cursor c_check_set_valid (p_delivery_detail_id in number) is
  select a.released_status, a.delivery_detail_id
  from wsh_delivery_details a,
       wsh_delivery_details b
  where b.delivery_detail_id  = p_delivery_detail_id
  and a.source_code      = b.source_code
  and a.source_header_id = b.source_header_id
  and a.source_line_set_id IN (
           SELECT c.source_line_set_id
           FROM WSH_DELIVERY_DETAILS c
           WHERE c.source_code = b.source_code
           AND   c.source_line_id = b.source_line_id
           AND   c.source_line_set_id IS NOT NULL)
  and a.delivery_detail_id <> b.delivery_detail_id
  and a.released_status NOT IN ('C', 'D')
  and rownum = 1;

  -- outbound: this cursor looks for valid details within the source line to resync
  -- if delivery detail is deleted.
  cursor c_find_line (p_source_code in varchar2,
                      p_source_header_id in number,
                      p_source_line_id in number) is
  select wdd.delivery_detail_id
  from wsh_delivery_details wdd
  where wdd.source_code = p_source_code
  and wdd.source_header_id = p_source_header_id
  and wdd.source_line_id = p_source_line_id
  and wdd.container_flag = 'N'
  and wdd.released_status NOT IN ('C', 'D')
  and rownum = 1;

  -- outbound: look for any delivery line to get the source line set
  -- when original delivery detail is deleted and source line is not eligible.
  cursor c_get_line_set (p_source_code in varchar2,
                         p_source_header_id in number,
                         p_source_line_id in number) is
  select wdd.source_line_set_id
  from wsh_delivery_details wdd
  where wdd.source_code = p_source_code
  and wdd.source_header_id = p_source_header_id
  and wdd.source_line_id = p_source_line_id
  and wdd.container_flag = 'N'
  and wdd.source_line_set_id IS NOT NULL
  and rownum = 1;

  -- outbound: this cursor looks for available details within source line set to resync
  -- if delivery detail is deleted and line is unavailable
  cursor c_find_set (p_source_code in varchar2,
                     p_source_header_id in number,
                     p_source_line_set_id in number) is
  select wdd.delivery_detail_id
  from wsh_delivery_details wdd
  where wdd.source_code = p_source_code
  and wdd.source_header_id = p_source_header_id
  and wdd.source_line_set_id = p_source_line_set_id
  and wdd.container_flag = 'N'
  and wdd.released_status NOT IN ('C', 'D')
  and rownum = 1;


  -- inbound/drop: this cursor checks if the delivery detail or other delivery
  -- details in its order line are available (viz., po line shipment has
  -- a detail with released status 'X')
  cursor c_check_inbound_detail_valid (p_delivery_detail_id in number) is
  select a.delivery_detail_id
  from wsh_delivery_details a,
       wsh_delivery_details b
  where b.delivery_detail_id  = p_delivery_detail_id
  and a.source_code    = b.source_code
  and a.source_line_id = b.source_line_id
  and a.po_shipment_line_id = b.po_shipment_line_id
  and a.delivery_detail_id <> b.delivery_detail_id
  and a.released_status = 'X'
  and rownum = 1
  UNION
  select delivery_detail_id
  from wsh_delivery_details
  where released_status = 'X'
  and delivery_detail_id = p_delivery_detail_id;



  -- this cursor checks for existence of interface (dangling) containers
  -- Bug 4274651: It also checks for existence of cancelled lines.
  cursor c_tp_dangling_conts (p_group_id in number) is
  select wddi.delivery_detail_id
  from   wsh_trips_interface wti,
         wsh_trip_stops_interface wtsi,
         wsh_del_legs_interface wdli,
         wsh_del_assgn_interface wdai,
         wsh_del_details_interface wddi,
         wsh_new_del_interface wndi
  where  wti.group_id = p_group_id
  and    wti.trip_interface_id = wtsi.trip_interface_id
  and    wti.interface_action_code = G_TP_RELEASE_CODE
  and    wtsi.stop_interface_id = wdli.pick_up_stop_interface_id
  and    wtsi.interface_action_code = G_TP_RELEASE_CODE
  and    wdli.delivery_interface_id = wdai.delivery_interface_id
  and    wdli.interface_action_code = G_TP_RELEASE_CODE
  and    wdai.delivery_interface_id is not null
  and    wdai.interface_action_code = G_TP_RELEASE_CODE
  and    wddi.delivery_detail_interface_id = wdai.delivery_detail_interface_id
  and    wddi.interface_action_code = G_TP_RELEASE_CODE
  and    ((wddi.container_flag = 'Y') OR
         (wddi.container_flag = 'N' and wddi.requested_quantity = 0))
  and    wndi.delivery_interface_id = wdli.delivery_interface_id
  and    wndi.interface_action_code = G_TP_RELEASE_CODE
  and    rownum = 1;

  l_released_status  VARCHAR2(1);
  l_dd_id            WSH_UTIL_CORE.ID_TAB_TYPE;
  l_split_from_dd_id WSH_UTIL_CORE.ID_TAB_TYPE;
  l_dd_interface_id  WSH_UTIL_CORE.ID_TAB_TYPE;
  l_source_codes     WSH_UTIL_CORE.COLUMN_TAB_TYPE;
  l_source_headers   WSH_UTIL_CORE.ID_TAB_TYPE;
  l_source_lines     WSH_UTIL_CORE.ID_TAB_TYPE;
  l_source_line_sets WSH_UTIL_CORE.ID_TAB_TYPE;
  l_tp_del_numbers   WSH_UTIL_CORE.COLUMN_TAB_TYPE;
  l_delivery_detail  NUMBER;
  l_count            NUMBER := 0;
  l_return_status    VARCHAR2(1);
  l_notfound         BOOLEAN;
  l_outbound_count   NUMBER;
  l_inbound_count    NUMBER;

  WSH_INV_REL_STATUS_ERROR EXCEPTION;

BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;
  --
  --

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'Bulk collect outbound interface lines in group', x_context.group_id);
  END IF;

  OPEN c_tp_released_lines (x_context.group_id, 'O', 'IO');
  FETCH  c_tp_released_lines BULK COLLECT INTO
         l_dd_interface_id,
         l_dd_id,
         l_split_from_dd_id,
         l_source_codes,
         l_source_headers,
         l_source_lines,
         l_source_line_sets,
         l_tp_del_numbers;
  CLOSE c_tp_released_lines;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'l_dd_interface_id.COUNT (outbound)', l_dd_interface_id.COUNT);
  END IF;

  l_outbound_count := l_dd_interface_id.COUNT;


  IF l_outbound_count > 0 THEN

    -- Check for shipped or deleted lines (stamp interface error and fail if found).

    FOR i in l_dd_interface_id.FIRST .. l_dd_interface_id.LAST LOOP
       l_delivery_detail := NVL(l_dd_id(i),
                                l_split_from_dd_id(i));

       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'resync looping: dd_id', l_delivery_detail);
       END IF;

       OPEN  c_check_detail_valid(l_delivery_detail);
       -- we should use valid delivery_detail_id to refresh source_line_set_id.
       FETCH c_check_detail_valid INTO l_released_status, l_delivery_detail;
       l_notfound := c_check_detail_valid%NOTFOUND;
       CLOSE c_check_detail_valid;

       IF l_notfound THEN
          OPEN c_check_set_valid(l_delivery_detail);
          FETCH c_check_set_valid INTO l_released_status, l_delivery_detail;
          l_notfound := c_check_set_valid%NOTFOUND;
          CLOSE c_check_set_valid;
       END IF;

       IF l_notfound THEN
          -- look for any valid detail within the source line.
          OPEN c_find_line(p_source_code      => l_source_codes(i),
                           p_source_header_id => l_source_headers(i),
                           p_source_line_id   => l_source_lines(i));
          FETCH c_find_line INTO l_delivery_detail;
          l_notfound := c_find_line%NOTFOUND;
          CLOSE c_find_line;
       END IF;

       IF l_notfound AND l_source_line_sets(i) IS NULL THEN
          -- check if the source line has been split since the snapshot.
          OPEN c_get_line_set(p_source_code      => l_source_codes(i),
                              p_source_header_id => l_source_headers(i),
                              p_source_line_id   => l_source_lines(i));
          FETCH c_get_line_set INTO l_source_line_sets(i);
          CLOSE c_get_line_set;
       END IF;

       IF l_notfound AND l_source_line_sets(i) IS NOT NULL THEN
          -- look for any valid detail within the source line set
          OPEN c_find_set(p_source_code        => l_source_codes(i),
                           p_source_header_id   => l_source_headers(i),
                           p_source_line_set_id => l_source_line_sets(i));
          FETCH c_find_set INTO l_delivery_detail;
          l_notfound := c_find_set%NOTFOUND;
          CLOSE c_find_set;
       END IF;

       IF l_notfound THEN
         -- if still not found, this line cannot be mapped or handled.
         stamp_interface_error(p_group_id => x_context.group_id,
                              p_entity_table_name => 'WSH_DEL_DETAILS_INTERFACE',
                              p_entity_interface_id => l_dd_interface_id(i),
                              p_message_name => 'WSH_TP_F_INVALID_DETAIL',
                              p_token_1_name => 'DETAIL_ID',
                              p_token_1_value => NVL(l_dd_id(i), l_split_from_dd_id(i)),
                              p_token_2_name  => 'PLAN_DEL_NUM',
                              p_token_2_value => l_tp_del_numbers(i),
                              x_errors_tab => x_errors_tab,
                              x_return_status => l_return_status);
          RAISE WSH_INV_REL_STATUS_ERROR;
       END IF;

       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'to be refreshed by dd_id', l_delivery_detail);
       END IF;

       l_dd_id(i) := l_delivery_detail;
    END LOOP;

    -- Resync released lines' source_line_id, source_line_set_id.
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Resync lines');
    END IF;


    FORALL i in 1..l_dd_interface_id.count
    UPDATE wsh_del_details_interface
    SET (source_line_id, source_line_set_id, source_header_id) =
        (select wdd.source_line_id, wdd.source_line_set_id, wdd.source_header_id
         from wsh_delivery_details wdd
         where wdd.delivery_detail_id = l_dd_id(i))
    WHERE  delivery_detail_interface_id = l_dd_interface_id(i);

  END IF;



  -- inbound/drop: resync the interface records' po_shipment_line_id and po_shipment_line_number
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'Bulk collect inbound/drop interface lines in group', x_context.group_id);
  END IF;

  OPEN c_tp_released_lines (x_context.group_id, 'I', 'D');
  FETCH  c_tp_released_lines BULK COLLECT INTO
         l_dd_interface_id,
         l_dd_id,
         l_split_from_dd_id,
         l_source_codes,
         l_source_headers,
         l_source_lines,
         l_source_line_sets,
         l_tp_del_numbers;
  CLOSE c_tp_released_lines;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'l_dd_interface_id.COUNT (inbound)', l_dd_interface_id.COUNT);
  END IF;

  l_inbound_count := l_dd_interface_id.COUNT;


  IF l_inbound_count > 0 THEN

    FOR i in l_dd_interface_id.FIRST .. l_dd_interface_id.LAST LOOP
       l_delivery_detail := NVL(l_dd_id(i), l_split_from_dd_id(i));
       OPEN  c_check_inbound_detail_valid(l_delivery_detail);
       FETCH c_check_inbound_detail_valid INTO l_delivery_detail;
       l_notfound := c_check_inbound_detail_valid%NOTFOUND;
       CLOSE c_check_inbound_detail_valid;

       IF l_notfound THEN
         -- if not found, this po line shipment cannot be mapped or handled.
         stamp_interface_error(p_group_id => x_context.group_id,
                              p_entity_table_name => 'WSH_DEL_DETAILS_INTERFACE',
                              p_entity_interface_id => l_dd_interface_id(i),
                              p_message_name => 'WSH_TP_F_INVALID_DETAIL_IB',  -- new message
                              p_token_1_name => 'DETAIL_ID',
                              p_token_1_value => NVL(l_dd_id(i), l_split_from_dd_id(i)),
                              p_token_2_name  => 'PLAN_DEL_NUM',
                              p_token_2_value => l_tp_del_numbers(i),
                              x_errors_tab => x_errors_tab,
                              x_return_status => l_return_status);
/*
 !!! create new message WSH_TP_F_INVALID_DETAIL_IB for inbound: canceled, shipped, purged, or closed.
 "The delivery line DETAIL_ID that is required to be assigned to plan delivery PLAN_DEL_NUM has been shipped, purged, closed or canceled."
*/
          RAISE WSH_INV_REL_STATUS_ERROR;
       END IF;
    END LOOP;

    FORALL i in 1..l_dd_interface_id.count
    UPDATE wsh_del_details_interface
    SET (source_line_id, source_line_set_id, source_header_id, po_shipment_line_id, po_shipment_line_number) =
        (select wdd.source_line_id, wdd.source_line_set_id, wdd.source_header_id, po_shipment_line_id, po_shipment_line_number
         from wsh_delivery_details wdd
         where wdd.delivery_detail_id = l_dd_id(i))
    WHERE  delivery_detail_interface_id = l_dd_interface_id(i);

  END IF;

  IF (l_outbound_count + l_inbound_count) = 0 THEN
    -- at this point, there is no interface line to release.
    --
    -- we need to check whether we will release
    -- deliveries with only dangling containers
    -- before we raise this error.
    OPEN  c_tp_dangling_conts(x_context.group_id);
    FETCH c_tp_dangling_conts INTO l_delivery_detail;
    IF c_tp_dangling_conts%NOTFOUND THEN
      l_delivery_detail := NULL;
    END IF;
    CLOSE c_tp_dangling_conts;

    IF l_delivery_detail IS NULL THEN
      stamp_interface_error(p_group_id            => x_context.group_id,
                            p_entity_table_name   => 'NONE',
                            p_entity_interface_id => -1,
                            p_message_name        => 'WSH_TP_F_NO_INT_LINES',
                            x_errors_tab          => x_errors_tab,
                            x_return_status       => l_return_status);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      RETURN;
    END IF;
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  --
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION
    WHEN WSH_INV_REL_STATUS_ERROR THEN
      IF c_check_detail_valid%ISOPEN THEN
         CLOSE c_check_detail_valid;
      END IF;
      IF c_check_set_valid%ISOPEN THEN
         CLOSE c_check_set_valid;
      END IF;
      IF c_find_line%ISOPEN THEN
         CLOSE c_find_line;
      END IF;
      IF c_get_line_set%ISOPEN THEN
         CLOSE c_get_line_set;
      END IF;
      IF c_find_set%ISOPEN THEN
         CLOSE c_find_set;
      END IF;
      IF c_check_inbound_detail_valid%ISOPEN THEN
         CLOSE c_check_inbound_detail_valid;
      END IF;
      IF c_tp_dangling_conts%ISOPEN THEN
         CLOSE c_tp_dangling_conts;
      END IF;
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INV_REL_STATUS_ERROR');
      END IF;

    WHEN OTHERS THEN
      IF c_check_detail_valid%ISOPEN THEN
         CLOSE c_check_detail_valid;
      END IF;
      IF c_check_set_valid%ISOPEN THEN
         CLOSE c_check_set_valid;
      END IF;
      IF c_find_line%ISOPEN THEN
         CLOSE c_find_line;
      END IF;
      IF c_get_line_set%ISOPEN THEN
         CLOSE c_get_line_set;
      END IF;
      IF c_find_set%ISOPEN THEN
         CLOSE c_find_set;
      END IF;
       IF c_check_inbound_detail_valid%ISOPEN THEN
         CLOSE c_check_inbound_detail_valid;
      END IF;
      IF c_tp_dangling_conts%ISOPEN THEN
         CLOSE c_tp_dangling_conts;
      END IF;
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TP_RELEASE.RESYNC_INTERFACE_TABLES',
                        l_module_name);

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END resync_interface_tables;





--
--  Procedure:          generate_lock_candidates
--  Parameters:
--               x_context             context in this session
--               x_plan_details        list of delivery details mapped to interface lines
--               x_track_conts         list of topmost containers to track
--               x_plan_deliveries     list of deliveries mapped to interface deliveries
--               x_plan_legs           list of delivery legs mapped to interface legs
--               x_plan_stops          list of stops mapped to interface stops
--               x_plan_trips          list of trips mapped to interface trips
--               x_plan_trip_moves     list of trip moves mapped to interface trip moves (FTE)
--               x_plan_moves          list of moves mapped to interface moves (FTE)
--               x_used_details        list of delivery details partially used by the plan
--               x_delivery_unassigns  list of delivery lines to unassign from their deliveries
--               x_trip_unassigns      list of deliveries to unassign from their trips
--               x_obsoleted_stops     list of mapped trips' stops that are not mapped in the plan
--               x_obsoleted_trip_moves     list of mapped trips' moves that are not mapped in the plan
--               x_errors_tab          list of errors to insert into wsh_interface_errors at the end
--               x_return_status       return status
--
--  Description:
--               Maps the interface records to their base records and locks them:
--               1. set up list of interface deliveries, so they can be referenced by lines
--               2. Map and lock delivery details and their topmost LPNs,
--                  using l_current_used_details to track partially and fully used details,
--                        x_track_conts and l_cont_contents to track topmost LPN configurations
--                     * validate grouping attributes (inbound and outbound)
--                     * validate that splitting is allowed
--                     * validate the order line quantity has not increased if it is still ready to release.
--                     * add topmost LPNs to x_delivery_unassigns when they need to be unassigned from current delivery.
--                  partially used details in l_current_used_details will be flushed into x_used_details
--               3. check outcome of mapping lines and deliveries.
--                     * validate that lines have been mapped
--                     * validate deliveries are not empty
--                     * validate LPNs are not broken
--                     * validate partially split details can be unassigned from plan deliveries
--               4. Map and lock trips and stops
--               5. Map and lock legs; reuse existing trips and stops whenever possible
--               6. Map and lock continuous moves (FTE), also matching their segments.
--
--               NOTE: Above tasks have been placed in a specific order in order to build up
--               the mapping.
--
PROCEDURE generate_lock_candidates(
           x_context                  IN OUT NOCOPY context_rec_type,
           x_plan_details             IN OUT NOCOPY plan_detail_tab_type,
           x_track_conts              IN OUT NOCOPY track_cont_tab_type,
           x_plan_deliveries          IN OUT NOCOPY plan_delivery_tab_type,
           x_plan_legs                IN OUT NOCOPY plan_leg_tab_type,
           x_plan_stops               IN OUT NOCOPY plan_stop_tab_type,
           x_plan_trips               IN OUT NOCOPY plan_trip_tab_type,
           x_plan_trip_moves          IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.plan_trip_move_tab_type,
           x_plan_moves               IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.plan_move_tab_type,
           x_used_details             IN OUT NOCOPY used_details_tab_type,
           x_delivery_unassigns       IN OUT NOCOPY delivery_unassign_tab_type,
           x_trip_unassigns           IN OUT NOCOPY trip_unassign_tab_type,
           x_obsoleted_stops          IN OUT NOCOPY obsoleted_stop_tab_type,
           x_obsoleted_trip_moves     IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.obsoleted_trip_move_tab_type,
           x_errors_tab               IN OUT NOCOPY interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
)
IS
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GENERATE_LOCK_CANDIDATES';
  --
  l_debug_on BOOLEAN;

  l_current_source_code  WSH_DELIVERY_DETAILS.SOURCE_CODE%TYPE := NULL;
  l_current_line_set_id  NUMBER := NULL;
  l_current_line_id      NUMBER := NULL;
  l_current_po_shipment_line_id  NUMBER := NULL;
  l_current_used_details used_details_tab_type;
  l_used_index           NUMBER := 0;
  l_new_index            NUMBER := 1;
  l_match_found          BOOLEAN;
  l_working_quantity     NUMBER := NULL;
  l_current_attributes   plan_detail_rec_type;
  l_original_quantity    NUMBER;
  l_candidates_count     NUMBER;
  l_first_line_map       BOOLEAN;
  l_deliveries_populated NUMBER := 0;
  l_interface_lines_count NUMBER := 0;
  l_return_status        VARCHAR2(1);
  l_plan_dd_index        NUMBER := 0;
  l_plan_del_index       NUMBER := 0;
  l_mapped_quantity      NUMBER;
  l_map_split_flag       VARCHAR2(1);
  l_target_delivery_index NUMBER := 0;
  l_target_delivery_interface_id NUMBER := 0;
  l_dummy_dd_id          NUMBER;

-- HW OPMCONV - Removed OPM local variables and added l_item_info
  l_item_info            WSH_DELIVERY_DETAILS_INV.mtl_system_items_rec;
  l_msg_data             VARCHAR2(4000);
  l_msg_count            NUMBER;
  l_last_interface_id    NUMBER;
  l_stop_index           NUMBER;

  -- variables to track topmost LPNs' configuration
  --              and assignments to deliveries.
  l_cont_index NUMBER    := 1;
  l_new_cont   BOOLEAN   := TRUE;
  l_cont_contents        track_cont_content_tab_type;


  -- variable to track grouping violation for the current interface line
  l_group_not_matched    BOOLEAN;


  -- Candidates are grouped by source line set or source line and
  -- ordered by quantity descending.
  --
  CURSOR c_tp_interface_lines (p_group_id IN NUMBER) IS
  SELECT DISTINCT
         wddi.delivery_detail_interface_id dd_interface_id,
         wddi.delivery_detail_id delivery_detail_id,
         wddi.split_from_delivery_detail_id split_from_delivery_detail_id,
         wddi.tp_delivery_detail_id,
         wddi.source_code,
         wddi.source_header_id,
         wddi.source_line_id,
         wddi.source_line_set_id,
         wddi.po_shipment_line_id,
         wddi.ship_from_location_id,
         wddi.ship_to_location_id,
         wddi.requested_quantity     quantity,
         wddi.requested_quantity_uom quantity_uom,
         wddi.src_requested_quantity,
         wddi.src_requested_quantity_uom,
         wndi.delivery_id,
         wndi.delivery_interface_id
  FROM   wsh_trips_interface          wti,
         wsh_trip_stops_interface     wtsi,
         wsh_del_legs_interface       wdli,
         wsh_new_del_interface        wndi,
         wsh_del_assgn_interface      wdai,
         wsh_del_details_interface    wddi
  WHERE  wti.group_id = p_group_id
  AND    wti.interface_action_code  = G_TP_RELEASE_CODE
  AND    wti.trip_interface_id      = wtsi.trip_interface_id
  AND    wtsi.stop_interface_id     = wdli.pick_up_stop_interface_id
  AND    wtsi.interface_action_code = G_TP_RELEASE_CODE
  AND    wndi.delivery_interface_id = wdli.delivery_interface_id
  AND    wdai.delivery_interface_id = wndi.delivery_interface_id
  AND    wdai.delivery_interface_id IS NOT NULL
  AND    wdai.interface_action_code = G_TP_RELEASE_CODE
  AND    wddi.delivery_detail_interface_id = wdai.delivery_detail_interface_id
  AND    wddi.interface_action_code = G_TP_RELEASE_CODE
  AND    wddi.container_flag = 'N'
  AND    wddi.requested_quantity <> 0 -- Bug 4322654
  ORDER BY
  -- outbound: group by line sets and order lines
  -- inbound/drop: group by po line shipments
           wddi.source_code,
           wddi.source_line_set_id,
           DECODE(wddi.source_line_set_id,
                  NULL, 0,
                  wddi.requested_quantity) DESC,
           wddi.source_line_id,
           wddi.po_shipment_line_id,
           wddi.requested_quantity DESC
  ;




  -- c_tp_interface_dels lists the interface deliveries
  -- and has outer-join to map the shipping deliveries that
  -- were snapshot; the code will later validate whether
  -- the existing shipping delivery can be mapped.
  --    If the plan specifies an existing TE delivery, use its grouping attribute values (via NVL)
  --    for outbound/inbound/drop to validate the candidate lines can be grouped/assigned:
  --         ship method components, fob, freight terms, intermediate ship to,
  --         customer, shipping control, vendor, and party
  --            TP must always pass organization_id, shipment_direction and other columns
  --            which are not NVL'd. below.  As of 2/10/2004, TP does not populate these
  --            grouping attributes being NVL'd.
  CURSOR c_tp_interface_dels (p_group_id IN NUMBER) IS
  SELECT DISTINCT
         wndi.delivery_id original_delivery_id,
         wndi.delivery_interface_id,
         wndi.tp_delivery_number,
         wndi.tp_plan_name,
         wndi.planned_flag,
         wnd.delivery_id,  -- if delivery has been deleted, we can create a new record.
         wnd.name wsh_name,
         wnd.status_code,
         nvl(wnd.ignore_for_planning, 'N') ignore_for_planning,
         wnd.planned_flag                 wsh_planned_flag,
         wnd.initial_pickup_location_id   wsh_initial_pu_loc_id,
         wnd.ultimate_dropoff_location_id wsh_ultimate_do_loc_id,
         wndi.initial_pickup_location_id,
         wndi.initial_pickup_date,
         wndi.ultimate_dropoff_location_id,
         wndi.ultimate_dropoff_date,
         NVL(wnd.ship_method_code, wndi.ship_method_code)     ship_method_code,
         NVL(wnd.mode_of_transport, wndi.mode_of_transport)   mode_of_transport,
         NVL(wnd.service_level, wndi.service_level)           service_level,
         NVL(wnd.freight_terms_code, wndi.freight_terms_code) freight_terms_code,
         wndi.name,
         wndi.loading_sequence,
         wndi.loading_order_flag,
         NVL(wnd.fob_code, wndi.fob_code)                     fob_code,
         NVL(wnd.fob_location_id, wndi.fob_location_id)       fob_location_id,
         wndi.waybill,
         wndi.currency_code,
         NVL(wnd.party_id, wndi.party_id)                     party_id,
         NVL(wnd.shipping_control, wndi.shipping_control)     shipping_control,
         NVL(wnd.vendor_id, wndi.vendor_id)                   vendor_id,
         wndi.organization_id,
         wndi.customer_id,
         NVL(wnd.intmed_ship_to_location_id, wndi.intmed_ship_to_location_id)
                                                              intmed_ship_to_location_id,
         NVL(wnd.carrier_id, wndi.carrier_id)                 carrier_id,
         NVL(wnd.shipment_direction, wndi.shipment_direction) shipment_direction,
         wndi.additional_shipment_info,
         wndi.gross_weight,
         wndi.net_weight,
         wndi.weight_uom_code,
         wndi.volume,
         wndi.volume_uom_code,
         wndi.pooled_ship_to_location_id,
         wndi.dock_code,
         wnd.wv_frozen_flag -- WV changes
  FROM   wsh_trips_interface          wti,
         wsh_trip_stops_interface     wtsi,
         wsh_del_legs_interface       wdli,
         wsh_new_del_interface        wndi,
         wsh_new_deliveries           wnd
  WHERE  wti.group_id = p_group_id
  AND    wti.interface_action_code  = G_TP_RELEASE_CODE
  AND    wti.trip_interface_id      = wtsi.trip_interface_id
  AND    wtsi.stop_interface_id     = wdli.pick_up_stop_interface_id
  AND    wtsi.interface_action_code = G_TP_RELEASE_CODE
  AND    wndi.delivery_interface_id = wdli.delivery_interface_id
  AND    wndi.interface_action_code = G_TP_RELEASE_CODE
  AND    wnd.delivery_id(+)         = wndi.delivery_id
  ORDER BY wndi.delivery_interface_id
  ;

  -- c_tp_interface_trips makes a list of interface trips,
  -- mapping shipping trips that were snapshot;
  -- code will later validate these shipping trips can be mapped.
  CURSOR c_tp_interface_trips (p_group_id IN NUMBER) IS
  SELECT
         wti.trip_interface_id,
         wti.planned_flag,
         wti.tp_trip_number,
         wti.tp_plan_name,
         wt.trip_id,
         wt.status_code                       wsh_status_code,
         wt.planned_flag                      wsh_planned_flag,
         nvl(wt.ignore_for_planning, 'N')     wsh_ignore_for_planning,
         wt.carrier_id                        wsh_carrier_id,
         wt.mode_of_transport                 wsh_mode_of_transport,
         wt.service_level                     wsh_service_level,
         wt.vehicle_organization_id           wsh_vehicle_org_id,
         wt.vehicle_item_id                   wsh_vehicle_item_id,
         wt.lane_id                           wsh_lane_id,
         wti.name,
         wti.vehicle_item_id,
         wti.vehicle_organization_id,
         wti.vehicle_num_prefix,
         wti.vehicle_number,
         wti.carrier_id,
         wti.ship_method_code,
         wti.route_id,
         wti.routing_instructions,
         wti.service_level,
         wti.mode_of_transport,
         wti.freight_terms_code,
         wti.schedule_id,
         wti.consolidation_allowed,
         wti.route_lane_id,
         wti.lane_id,
         wti.seal_code,
         wti.shipments_type_flag,
         wti.booking_number,
         wti.vessel,
         wti.voyage_number,
         wti.port_of_loading,
         wti.port_of_discharge,
         wti.carrier_contact_id,
         wti.shipper_wait_time,
         wti.wait_time_uom,
         wti.carrier_response,
         wti.operator
  FROM   wsh_trips_interface          wti,
         wsh_trips                    wt
  WHERE  wti.group_id = p_group_id
  AND    wti.interface_action_code  = G_TP_RELEASE_CODE
  AND    wt.trip_id(+)              = wti.trip_id
  ORDER BY wti.trip_interface_id
  ;

  -- c_tp_interface_stops makes a list of interface stops.
  -- there is no outer-join; the information will be used
  -- to match shipping stops selected by c_map_stop
  CURSOR c_tp_interface_stops (p_trip_interface_id IN NUMBER) IS
  SELECT
         wtsi.stop_interface_id,
         wtsi.stop_id,
         wtsi.tp_stop_id,
         wtsi.stop_location_id,
         wtsi.stop_sequence_number,
         wtsi.planned_arrival_date,
         wtsi.planned_departure_date,
         wtsi.departure_gross_weight,
         wtsi.departure_net_weight,
         wtsi.weight_uom_code,
         wtsi.departure_volume,
         wtsi.volume_uom_code,
         wtsi.departure_seal_code,
         wtsi.departure_fill_percent,
         wtsi.wkend_layover_stops,
         wtsi.wkday_layover_stops,
         wtsi.shipments_type_flag
  FROM   wsh_trip_stops_interface     wtsi
  WHERE  wtsi.trip_interface_id      = p_trip_interface_id
  AND    wtsi.interface_action_code  = G_TP_RELEASE_CODE
  ORDER BY wtsi.stop_sequence_number
  ;

  -- c_map_stop finds a shipping stop that matches the
  -- essential stop attributes of the interface stop.
  --    select the physical stop or the unlinked dummy stop
  --    at the physical stop location with same dates.
  CURSOR c_map_stop(p_trip_id                IN NUMBER,
                    p_stop_location_id       IN NUMBER,
                    p_planned_arrival_date   IN DATE,
                    p_planned_departure_date IN DATE)  IS
  SELECT wts.stop_id,
         wv_frozen_flag  -- WV changes
  FROM   wsh_trip_stops    wts
  WHERE  wts.trip_id                = p_trip_id
  AND    wts.stop_location_id       = p_stop_location_id
  AND    wts.planned_arrival_date   = p_planned_arrival_date
  AND    wts.planned_departure_date = p_planned_departure_date
  AND    wts.status_code = 'OP'
  UNION
  SELECT wts.stop_id, wv_frozen_flag
  FROM   wsh_trip_stops   wts
  WHERE  wts.trip_id                = p_trip_id
  AND    wts.physical_location_id   = p_stop_location_id
  AND    wts.physical_stop_id       IS NULL
  AND    wts.planned_arrival_date   = p_planned_arrival_date
  AND    wts.planned_departure_date = p_planned_departure_date
  AND    wts.status_code = 'OP'
  ;

  l_map_stop_rec  c_map_stop%ROWTYPE;

  -- c_snapshot_legs generates a list of delivery legs
  -- of the delivery being mapped.
  CURSOR c_snapshot_legs(p_delivery_id IN NUMBER) IS
  SELECT wdl.delivery_leg_id           delivery_leg_id,
         wt.trip_id                    trip_id,
         wt.planned_flag               trip_planned_flag,
         wt.carrier_id                 carrier_id,
         wt.mode_of_transport          mode_of_transport,
         wt.service_level              service_level,
         wt.vehicle_organization_id    vehicle_org_id,
         wt.vehicle_item_id            vehicle_item_id,
         wt.lane_id                    lane_id,
         wts_pu.stop_id                pu_stop_id,
         wts_pu.stop_location_id       pu_stop_location_id,
         wts_pu.planned_arrival_date   pu_planned_arrival_date,
         wts_pu.planned_departure_date pu_planned_departure_date,
         wts_pu.wv_frozen_flag         pu_wv_flag,
         NVL(wts_do.physical_stop_id, wts_do.stop_id) do_stop_id,
         NVL(wts_do.physical_location_id, wts_do.stop_location_id)
                                       do_stop_location_id,
         wts_do.physical_stop_id       do_physical_stop_id,
         wts_do.planned_arrival_date   do_planned_arrival_date,
         wts_do.planned_departure_date do_planned_departure_date,
         wts_do.wv_frozen_flag         do_wv_flag
  FROM   wsh_delivery_legs wdl,
         wsh_trip_stops wts_pu,
         wsh_trip_stops wts_do,
         wsh_trips      wt
  WHERE  wdl.delivery_id = p_delivery_id
  AND    wts_pu.stop_id  = wdl.pick_up_stop_id
  AND    wts_do.stop_id  = wdl.drop_off_stop_id
  AND    wt.trip_id      = wts_pu.trip_id
  ORDER BY wdl.delivery_leg_id;

  l_snapshot_leg_ids          wsh_util_core.id_tab_type;
  l_snapshot_trip_ids         wsh_util_core.id_tab_type;
  l_snapshot_trip_plan_flags  planned_flag_tab_type;
  l_snapshot_pu_stop_ids      wsh_util_core.id_tab_type;
  l_snapshot_pu_seq_nums      wsh_util_core.id_tab_type;
  l_snapshot_pu_loc_ids       wsh_util_core.id_tab_type;
  l_snapshot_pu_arrive_dates  date_tab_type;
  l_snapshot_pu_depart_dates  date_tab_type;
  l_snapshot_pu_wv_flag       planned_flag_tab_type;
  l_snapshot_do_stop_ids      wsh_util_core.id_tab_type;
  l_snapshot_do_phys_stop_ids wsh_util_core.id_tab_type;
  l_snapshot_do_seq_nums      wsh_util_core.id_tab_type;
  l_snapshot_do_loc_ids       wsh_util_core.id_tab_type;
  l_snapshot_do_arrive_dates  date_tab_type;
  l_snapshot_do_depart_dates  date_tab_type;
  l_snapshot_do_wv_flag       planned_flag_tab_type;
  l_snapshot_carrier_ids      wsh_util_core.id_tab_type;
  l_snapshot_modes            wsh_util_core.column_tab_type;
  l_snapshot_service_levels   wsh_util_core.column_tab_type;
  l_snapshot_veh_org_ids      wsh_util_core.id_tab_type;
  l_snapshot_veh_item_ids     wsh_util_core.id_tab_type;
  l_snapshot_lane_ids         wsh_util_core.id_tab_type;

  -- c_physical_stop looks up the physical stop's dates for matching plan
  CURSOR c_physical_stop(p_stop_id  IN NUMBER)  IS
  SELECT planned_arrival_date,
         planned_departure_date,
         wv_frozen_flag
  FROM   wsh_trip_stops    wts
  WHERE  wts.stop_id = p_stop_id;


  -- c_tp_interface_legs makes a list of interface legs.
  CURSOR c_tp_interface_legs (p_delivery_interface_id IN NUMBER) IS
  SELECT wdli.delivery_leg_interface_id,
         wdli.delivery_leg_id,
         wdli.pick_up_stop_interface_id,
         wdli.drop_off_stop_interface_id,
         wtsi_pu.trip_interface_id
  FROM   wsh_del_legs_interface       wdli,
         wsh_trip_stops_interface     wtsi_pu
  WHERE  wdli.delivery_interface_id    = p_delivery_interface_id
  AND    wdli.interface_action_code    = G_TP_RELEASE_CODE
  AND    wtsi_pu.stop_interface_id     = wdli.pick_up_stop_interface_id
  AND    wtsi_pu.interface_action_code = G_TP_RELEASE_CODE
  ORDER BY wdli.sequence_number, wdli.delivery_leg_interface_id
  ;


  -- c_being_staged is used to verify whether the order line
  -- is ready to release (status 'Backordered' implies the
  -- order line had been staged sometime).
  -- This is to meet the requirement of failing the plan
  -- if the order line's quantity has been increased and
  -- it is not yet staged.
  CURSOR c_being_staged(p_source_code IN VARCHAR2,
                  p_source_line_id IN VARCHAR2) IS
    SELECT wdd.delivery_detail_id
    FROM   WSH_DELIVERY_DETAILS wdd
    WHERE  wdd.source_code    = p_source_code
    AND    wdd.source_line_id = p_source_line_id
    AND    wdd.released_status IN ('B', 'S', 'Y', 'C')
    AND    rownum = 1;

  -- c_location_change is used to validate that
  -- the order line's ship-from and ship-to locations have
  -- not been changed in the event that no candidates have
  -- been found for the interface line; otherwise, the plan will fail.
  CURSOR c_location_change(p_source_code           IN VARCHAR2,
                           p_source_header_id      IN VARCHAR2,
                           p_source_line_id        IN NUMBER,
                           p_ship_from_location_id IN NUMBER,
                           p_ship_to_location_id   IN NUMBER) IS
    SELECT wdd.delivery_detail_id
    FROM   wsh_delivery_details wdd
    WHERE
         (
              wdd.source_code      = p_source_code
          AND wdd.source_header_id = p_source_header_id
          AND wdd.source_line_id   = p_source_line_id
         )
         AND (   wdd.ship_from_location_id <> p_ship_from_location_id
              OR wdd.ship_to_location_id <> p_ship_to_location_id)
         AND wdd.released_status IN ('N', 'R', 'B', 'S', 'Y', 'X')
         AND nvl(wdd.ignore_for_planning, 'N') = 'N'
         AND rownum = 1;

  -- c_ignored is to validate whether the order line has become
  -- ignored for planning, in the event that no candidates
  -- have been found for the interface line; if so, the plan will fail.
  CURSOR c_ignored(p_source_code           IN VARCHAR2,
                   p_source_header_id      IN VARCHAR2,
                   p_source_line_id        IN NUMBER) IS
    SELECT wdd.delivery_detail_id
    FROM   wsh_delivery_details wdd
    WHERE
         (
              wdd.source_code      = p_source_code
          AND wdd.source_header_id = p_source_header_id
          AND wdd.source_line_id   = p_source_line_id
         )
         AND wdd.released_status IN ('N', 'R', 'B', 'S', 'Y', 'X')
         AND wdd.ignore_for_planning = 'Y'
         AND NOT EXISTS (SELECT 'planning'
                         FROM   wsh_delivery_details wdd2
                         WHERE  wdd2.source_code      = p_source_code
                         AND    wdd2.source_header_id = p_source_header_id
                         AND    wdd2.source_line_id   = p_source_line_id
                         AND    nvl(wdd2.ignore_for_planning, 'N') = 'N')
         AND rownum = 1;

  l_phys_ult_do_mapped BOOLEAN;  -- track whether internal customer location mapping is unchanged
  l_last_do_stop_index NUMBER;   -- track each delivery's last drop off stop


BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;
  --
  --

  -- 1. set up list of interface deliveries, so they can be referenced by lines

  -- Bug 3555487 initialize message stack for each major action point.
  FND_MSG_PUB.initialize;

  l_new_index := 0;
  FOR idel IN c_tp_interface_dels(p_group_id => x_context.group_id)  LOOP

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,
                       'idel looping: delivery_interface_id',
                       idel.delivery_interface_id);
    END IF;

    l_new_index := l_new_index + 1;
    x_plan_deliveries(l_new_index).del_interface_id := idel.delivery_interface_id;
    x_plan_deliveries(l_new_index).delivery_id      := idel.delivery_id;
    x_plan_deliveries(l_new_index).tp_delivery_number  := idel.tp_delivery_number;
    x_plan_deliveries(l_new_index).tp_plan_name     := idel.tp_plan_name;
    x_plan_deliveries(l_new_index).planned_flag     := idel.planned_flag;
    x_plan_deliveries(l_new_index).wsh_planned_flag := idel.wsh_planned_flag;
    x_plan_deliveries(l_new_index).initial_pickup_location_id  := idel.initial_pickup_location_id;
    x_plan_deliveries(l_new_index).ultimate_dropoff_location_id := idel.ultimate_dropoff_location_id;
    x_plan_deliveries(l_new_index).initial_pickup_date        := idel.initial_pickup_date;
    x_plan_deliveries(l_new_index).ultimate_dropoff_date      := idel.ultimate_dropoff_date;
    x_plan_deliveries(l_new_index).ship_method_code           := idel.ship_method_code;
    x_plan_deliveries(l_new_index).mode_of_transport          := idel.mode_of_transport;
    x_plan_deliveries(l_new_index).service_level              := idel.service_level;
    x_plan_deliveries(l_new_index).freight_terms_code         := idel.freight_terms_code;
    x_plan_deliveries(l_new_index).name                       := idel.name;
    x_plan_deliveries(l_new_index).loading_sequence           := idel.loading_sequence;
    x_plan_deliveries(l_new_index).loading_order_flag         := idel.loading_order_flag;
    x_plan_deliveries(l_new_index).fob_code                   := idel.fob_code;
    x_plan_deliveries(l_new_index).fob_location_id            := idel.fob_location_id;
    x_plan_deliveries(l_new_index).waybill                    := idel.waybill;
    x_plan_deliveries(l_new_index).currency_code              := idel.currency_code;
    x_plan_deliveries(l_new_index).party_id                   := idel.party_id;
    x_plan_deliveries(l_new_index).shipping_control           := idel.shipping_control;
    x_plan_deliveries(l_new_index).vendor_id                  := idel.vendor_id;
    x_plan_deliveries(l_new_index).organization_id            := idel.organization_id;
    x_plan_deliveries(l_new_index).customer_id                := idel.customer_id;
    x_plan_deliveries(l_new_index).intmed_ship_to_location_id := idel.intmed_ship_to_location_id;
    x_plan_deliveries(l_new_index).carrier_id                 := idel.carrier_id;
    x_plan_deliveries(l_new_index).shipment_direction         := idel.shipment_direction;
    x_plan_deliveries(l_new_index).additional_shipment_info   := idel.additional_shipment_info;
    x_plan_deliveries(l_new_index).gross_weight               := idel.gross_weight;
    x_plan_deliveries(l_new_index).net_weight                 := idel.net_weight;
    x_plan_deliveries(l_new_index).weight_uom_code            := idel.weight_uom_code;
    x_plan_deliveries(l_new_index).volume                     := idel.volume;
    x_plan_deliveries(l_new_index).volume_uom_code            := idel.volume_uom_code;
    x_plan_deliveries(l_new_index).pooled_ship_to_location_id := idel.pooled_ship_to_location_id;
    x_plan_deliveries(l_new_index).dock_code                  := idel.dock_code;
    x_plan_deliveries(l_new_index).ilines_count               := 0;
    x_plan_deliveries(l_new_index).lines_count                := 0;
    x_plan_deliveries(l_new_index).s_lines_count              := 0;
    x_plan_deliveries(l_new_index).dangling_conts_count       := 0;
    x_plan_deliveries(l_new_index).assign_details_count       := 0;
    x_plan_deliveries(l_new_index).wv_frozen_flag             := idel.wv_frozen_flag;   -- WV changes

    x_plan_deliveries(l_new_index).wms_org_flag :=
            wsh_util_validate.Check_Wms_Org(idel.organization_id);
    IF x_plan_deliveries(l_new_index).wms_org_flag = 'Y' THEN
      x_context.wms_in_group := TRUE;
    END IF;
    x_plan_deliveries(l_new_index).leg_base_index := NULL;
    IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'delivery_wv_frozen_flag', idel.wv_frozen_flag);
          WSH_DEBUG_SV.log(l_module_name, 'delivery_id', idel.delivery_id);
    END IF;

    WSH_LOCATIONS_PKG.convert_internal_cust_location(
            p_internal_cust_location_id => x_plan_deliveries(l_new_index).ultimate_dropoff_location_id,
            x_internal_org_location_id  => x_plan_deliveries(l_new_index).physical_ultimate_do_loc_id,
            x_return_status             => l_return_status);
    IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR))  THEN
        stamp_interface_error(
          p_group_id            => x_context.group_id,
          p_entity_table_name   => 'WSH_NEW_DELIVERIES_INTERFACE',
          p_entity_interface_id => idel.delivery_interface_id,
          p_message_name        => 'WSH_TP_F_CONVERT_LOC', --!!! new message
          p_token_1_name        => 'PLAN_DEL_NUM',
          p_token_1_value       => idel.tp_delivery_number,
          x_errors_tab          => x_errors_tab,
          x_return_status       => l_return_status);
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       RETURN;
    END IF;


    -- if the existing delivery is firmed, key attributes need to match.
    IF      idel.wsh_planned_flag IN ('Y', 'F')
       AND  (   idel.wsh_initial_pu_loc_id <> idel.initial_pickup_location_id
             OR idel.wsh_ultimate_do_loc_id <> idel.ultimate_dropoff_location_id) THEN

        stamp_interface_error(
          p_group_id            => x_context.group_id,
          p_entity_table_name   => 'WSH_NEW_DELIVERIES_INTERFACE',
          p_entity_interface_id => idel.delivery_interface_id,
          p_message_name        => 'WSH_TP_F_DEL_DIFF_ATTR',
          p_token_1_name        => 'DELIVERY_NAME',
          p_token_1_value       => idel.wsh_name,
          x_errors_tab          => x_errors_tab,
          x_return_status       => l_return_status);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'delivery key attributes do not match', x_return_status);
          WSH_DEBUG_SV.log(l_module_name, 'delivery_interface_id', idel.delivery_interface_id);
          WSH_DEBUG_SV.log(l_module_name, 'delivery_id', idel.delivery_id);
          WSH_DEBUG_SV.log(l_module_name, 'wsh_planned_flag', idel.wsh_planned_flag);
          WSH_DEBUG_SV.log(l_module_name, 'wsh_initial_pu_loc_id', idel.wsh_initial_pu_loc_id);
          WSH_DEBUG_SV.log(l_module_name, 'wsh_initial_do_loc_id', idel.wsh_ultimate_do_loc_id);
          WSH_DEBUG_SV.log(l_module_name, 'initial_pickup_location_id', idel.initial_pickup_location_id);
          WSH_DEBUG_SV.log(l_module_name, 'ultimate_dropoff_location_id', idel.ultimate_dropoff_location_id);
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
    END IF;

    IF idel.delivery_id IS NOT NULL THEN
      IF idel.status_code NOT IN ('OP', 'SA') THEN
        stamp_interface_error(
          p_group_id            => x_context.group_id,
          p_entity_table_name   => 'WSH_NEW_DELIVERIES_INTERFACE',
          p_entity_interface_id => idel.delivery_interface_id,
          p_message_name        => 'WSH_TP_F_DEL_NOT_OPEN',
          p_token_1_name        => 'DELIVERY_NAME',
          p_token_1_value       => idel.wsh_name,
          x_errors_tab          => x_errors_tab,
          x_return_status       => l_return_status);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      END IF;

      IF idel.ignore_for_planning = 'Y' THEN
        stamp_interface_error(
          p_group_id            => x_context.group_id,
          p_entity_table_name   => 'WSH_NEW_DELIVERIES_INTERFACE',
          p_entity_interface_id => idel.delivery_interface_id,
          p_message_name        => 'WSH_TP_F_DEL_IGNORED',
          p_token_1_name        => 'DELIVERY_NAME',
          p_token_1_value       => idel.wsh_name,
          p_token_2_name        => 'PLAN_TRIP_NUM',
          p_token_2_value       =>  get_plan_trip_num(x_context),
          p_token_3_name        => 'PLAN_DEL_NUM',
          p_token_3_value       => idel.tp_delivery_number,
          x_errors_tab          => x_errors_tab,
          x_return_status       => l_return_status);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      END IF;

      BEGIN
        wsh_new_deliveries_pvt.lock_dlvy_no_compare(
               p_delivery_id => idel.delivery_id);
      EXCEPTION
        WHEN OTHERS THEN
               stamp_interface_error(
                   p_group_id            => x_context.group_id,
                   p_entity_table_name   => 'WSH_NEW_DELIVERIES_INTERFACE',
                   p_entity_interface_id => idel.delivery_interface_id,
                   p_message_name        => 'WSH_TP_F_NO_LOCK_DEL',
                   p_token_1_name        => 'DELIVERY_NAME',
                   p_token_1_value       => idel.wsh_name,
                   x_errors_tab          => x_errors_tab,
                   x_return_status       => l_return_status);
               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               IF l_debug_on THEN
                 WSH_DEBUG_SV.pop(l_module_name);
               END IF;
               RETURN;
      END;

      BEGIN
        wsh_delivery_details_pkg.lock_detail_no_compare(
               p_delivery_id => idel.delivery_id);
      EXCEPTION
        WHEN OTHERS THEN
               stamp_interface_error(
                   p_group_id            => x_context.group_id,
                   p_entity_table_name   => 'WSH_NEW_DELIVERIES_INTERFACE',
                   p_entity_interface_id => idel.delivery_interface_id,
                   p_message_name        => 'WSH_TP_F_NO_LOCK_DEL_CONTENTS',
                   p_token_1_name        => 'DELIVERY_NAME',
                   p_token_1_value       => idel.wsh_name,
                   x_errors_tab          => x_errors_tab,
                   x_return_status       => l_return_status);
               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               IF l_debug_on THEN
                 WSH_DEBUG_SV.pop(l_module_name);
               END IF;
               RETURN;
      END;
    END IF;

  END LOOP;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'x_plan_deliveries.COUNT', x_plan_deliveries.COUNT);
  END IF;

  IF x_plan_deliveries.COUNT = 0 THEN
      stamp_interface_error(
           p_group_id            => x_context.group_id,
           p_entity_table_name   => 'NONE',
           p_entity_interface_id => -1,
           p_message_name        => 'WSH_TP_F_NO_DELS',
           p_token_1_name        => 'PLAN_TRIP_NUM',
           p_token_1_value       => get_plan_trip_num(x_context),
           x_errors_tab          => x_errors_tab,
           x_return_status       => l_return_status);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      RETURN;
  END IF;


  -- 2. Map and lock delivery details and their topmost LPNs

  -- Bug 3555487 initialize message stack for each major action point.
  FND_MSG_PUB.initialize;

  FOR iline IN c_tp_interface_lines(p_group_id => x_context.group_id)  LOOP

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,
                       'iline looping: dd_interface_id',
                       iline.dd_interface_id);
    END IF;

    l_original_quantity                      := iline.quantity;
    l_candidates_count                       := 0;
    l_current_attributes.mapped_quantity     := iline.quantity;
    l_current_attributes.mapped_quantity_uom := iline.quantity_uom;
    l_group_not_matched                      := FALSE;
    l_interface_lines_count                  := l_interface_lines_count + 1;

    -- find the mapped delivery index if it has changed.
    IF l_target_delivery_interface_id <> iline.delivery_interface_id THEN

      l_target_delivery_interface_id := iline.delivery_interface_id;
      l_new_index := x_plan_deliveries.FIRST;

      WHILE l_new_index IS NOT NULL LOOP
        IF x_plan_deliveries(l_new_index).del_interface_id = iline.delivery_interface_id THEN
          l_target_delivery_index := l_new_index;
          EXIT;
        END IF;
        l_new_index := x_plan_deliveries.NEXT(l_new_index);
      END LOOP;

    END IF;

    -- count the interface lines mapped to this delivery.
    x_plan_deliveries(l_target_delivery_index).ilines_count :=
            x_plan_deliveries(l_target_delivery_index).ilines_count  + 1;

    -- We need to check grouping depending on whether this is the first line
    -- being mapped for the interface delivery.
    -- Otherwise, the first interface line being successfully mapped will set the delivery's
    -- grouping attributes.
    l_first_line_map := (x_plan_deliveries(l_target_delivery_index).lines_count = 0);

    -- The line should be compatible with this delivery's shipping attributes when enforced;
    -- some of the grouping attributes are passed from the interface delivery and must be validated,
    -- so we always do these assignments.
    l_current_attributes.line_direction     := x_plan_deliveries(l_target_delivery_index).shipment_direction;
    l_current_attributes.ship_from_location_id := x_plan_deliveries(l_target_delivery_index).initial_pickup_location_id;
    l_current_attributes.ship_to_location_id := x_plan_deliveries(l_target_delivery_index).ultimate_dropoff_location_id;
    l_current_attributes.organization_id    := x_plan_deliveries(l_target_delivery_index).organization_id;
    l_current_attributes.customer_id        := x_plan_deliveries(l_target_delivery_index).customer_id;
    l_current_attributes.fob_code           := x_plan_deliveries(l_target_delivery_index).fob_code;
    l_current_attributes.freight_terms_code := x_plan_deliveries(l_target_delivery_index).freight_terms_code;
    l_current_attributes.intmed_ship_to_location_id := x_plan_deliveries(l_target_delivery_index).intmed_ship_to_location_id;
    l_current_attributes.ship_method_code   := x_plan_deliveries(l_target_delivery_index).ship_method_code;
    l_current_attributes.mode_of_transport  := x_plan_deliveries(l_target_delivery_index).mode_of_transport;
    l_current_attributes.service_level      := x_plan_deliveries(l_target_delivery_index).service_level;
    l_current_attributes.carrier_id         := x_plan_deliveries(l_target_delivery_index).carrier_id;
    l_current_attributes.shipping_control   := x_plan_deliveries(l_target_delivery_index).shipping_control;
    l_current_attributes.vendor_id          := x_plan_deliveries(l_target_delivery_index).vendor_id;
    l_current_attributes.party_id           := x_plan_deliveries(l_target_delivery_index).party_id;

    -- if new source line set or source line,
    --  flush temp list to used list (clear fully used and keep partially used)
    --    inbound/drop: track po_shipment_line_id change as well
    --      assumption: only inbound/drop will have po_shipment_line_id populated.
    IF       (NVL(l_current_source_code, 'NEW') <> iline.source_code)
          OR (l_current_line_set_id IS NULL AND l_current_line_id IS NULL)
          OR (iline.source_line_set_id <> l_current_line_set_id)
          OR (iline.source_line_set_id IS NULL     AND l_current_line_set_id IS NOT NULL)
          OR (iline.source_line_set_id IS NOT NULL AND l_current_line_set_id IS NULL)
          OR (iline.source_line_id <> l_current_line_id)
          OR (NVL(iline.po_shipment_line_id, -1) <> NVL(l_current_po_shipment_line_id, -1))
    THEN

       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'flushing iline.source_code', iline.source_code);
          WSH_DEBUG_SV.log(l_module_name, 'iline.source_line_set_id', iline.source_line_set_id);
          WSH_DEBUG_SV.log(l_module_name, 'iline.source_line_id', iline.source_line_id);
          WSH_DEBUG_SV.log(l_module_name, 'iline.po_shipment_line_id', iline.po_shipment_line_id);
          WSH_DEBUG_SV.log(l_module_name, 'l_current_source_code', l_current_source_code);
          WSH_DEBUG_SV.log(l_module_name, 'l_current_line_set_id', l_current_line_set_id);
          WSH_DEBUG_SV.log(l_module_name, 'l_current_line_id', l_current_line_id);
          WSH_DEBUG_SV.log(l_module_name, 'l_current_po_shipment_line_id', l_current_po_shipment_line_id);
       END IF;

       l_current_source_code         := iline.source_code;
       l_current_po_shipment_line_id := iline.po_shipment_line_id;

       IF iline.source_line_set_id IS NOT NULL THEN
         l_current_line_set_id := iline.source_line_set_id;
         l_current_line_id     := NULL;
       ELSE
         l_current_line_set_id := NULL;
         l_current_line_id     := iline.source_line_id;
       END IF;


       IF (l_current_used_details.COUNT > 0) THEN
         flush_used_details(
             x_context              => x_context,
             x_current_used_details => l_current_used_details,
             x_used_details         => x_used_details,
             x_errors_tab           => x_errors_tab,
             x_return_status        => l_return_status);
         IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR))  THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           RETURN;
         END IF;
       END IF;

    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'iline.source_code', iline.source_code);
      WSH_DEBUG_SV.log(l_module_name, 'iline.delivery_detail_id', iline.delivery_detail_id);
      WSH_DEBUG_SV.log(l_module_name, 'iline.split_from_delivery_detail_id', iline.split_from_delivery_detail_id);
      WSH_DEBUG_SV.log(l_module_name, 'l_target_delivery_index', l_target_delivery_index);
      WSH_DEBUG_SV.log(l_module_name, 'x_plan_deliveries->delivery_id', x_plan_deliveries(l_target_delivery_index).delivery_id);
      WSH_DEBUG_SV.log(l_module_name, 'iline.source_code', iline.source_code);
      WSH_DEBUG_SV.log(l_module_name, 'iline.source_header_id', iline.source_header_id);
      WSH_DEBUG_SV.log(l_module_name, 'iline.source_line_id', iline.source_line_id);
      WSH_DEBUG_SV.log(l_module_name, 'iline.source_line_set_id', iline.source_line_set_id);
      WSH_DEBUG_SV.log(l_module_name, 'iline.ship_from_location_id', iline.ship_from_location_id);
      WSH_DEBUG_SV.log(l_module_name, 'iline.ship_to_location_id', iline.ship_to_location_id);
      WSH_DEBUG_SV.log(l_module_name, 'iline.src_requested_quantity', iline.src_requested_quantity);
      WSH_DEBUG_SV.log(l_module_name, 'iline.src_requested_quantity_uom', iline.src_requested_quantity_uom);
      WSH_DEBUG_SV.log(l_module_name, 'iline.quantity', iline.quantity);
      WSH_DEBUG_SV.log(l_module_name, 'iline.quantity_uom', iline.quantity_uom);
    END IF;

<<candidates_loop>>
    FOR candidate IN c_map_lines (
        x_plan_delivery_detail_id    => NVL(iline.delivery_detail_id,
                                          iline.split_from_delivery_detail_id),
        x_plan_delivery_id           => x_plan_deliveries(l_target_delivery_index).delivery_id,
        x_plan_source_code           => iline.source_code,
        x_plan_source_header_id      => iline.source_header_id,
        x_plan_source_line_id        => iline.source_line_id,
        x_plan_source_line_set_id    => iline.source_line_set_id,
        x_plan_po_shipment_line_id   => iline.po_shipment_line_id,
        x_plan_ship_from_location_id => iline.ship_from_location_id,
        x_plan_ship_to_location_id   => iline.ship_to_location_id) LOOP

      l_candidates_count := l_candidates_count + 1;

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,
                         'candidate looping: delivery_detail_id',
                         candidate.delivery_detail_id);

        WSH_DEBUG_SV.log(l_module_name, 'candidate.choice', candidate.choice);
        WSH_DEBUG_SV.log(l_module_name, 'candidate.scope', candidate.scope);
        WSH_DEBUG_SV.log(l_module_name, 'candidate.delivery_id', candidate.delivery_id);
        WSH_DEBUG_SV.log(l_module_name, 'candidate.source_line_id', candidate.source_line_id);
        WSH_DEBUG_SV.log(l_module_name, 'candidate.released_status', candidate.released_status);
        WSH_DEBUG_SV.log(l_module_name, 'candidate.line_direction', candidate.line_direction);
        WSH_DEBUG_SV.log(l_module_name, 'candidate.src_requested_quantity', candidate.src_requested_quantity);
        WSH_DEBUG_SV.log(l_module_name, 'candidate.src_requested_quantity_uom', candidate.src_requested_quantity_uom);
        WSH_DEBUG_SV.log(l_module_name, 'candidate.quantity', candidate.quantity);
        WSH_DEBUG_SV.log(l_module_name, 'candidate.quantity_uom', candidate.quantity_uom);
      END IF;


      IF     (x_plan_deliveries(l_target_delivery_index).delivery_id IS NOT NULL)
         AND (x_plan_deliveries(l_target_delivery_index).wsh_planned_flag <> 'N') THEN
        IF (candidate.delivery_id IS NULL
            OR candidate.delivery_id <> x_plan_deliveries(l_target_delivery_index).delivery_id)  THEN
          -- since delivery is firmed, its shipping attributes cannot be updated (ship method should not be overwritten)
          -- and its contents cannot be changed.
          -- That means we cannot assign this candidate to the mapped delivery.
          stamp_interface_error(
               p_group_id            => x_context.group_id,
               p_entity_table_name   => 'WSH_NEW_DELIVERIES_INTERFACE',
               p_entity_interface_id => iline.dd_interface_id,
               p_message_name        => 'WSH_TP_I_LINE_NOT_ASSIGNED',
               p_token_1_name        => 'DETAIL_ID',
               p_token_1_value       => candidate.delivery_detail_id,
               x_errors_tab          => x_errors_tab,
               x_return_status       => l_return_status);
          GOTO next_candidate;
        END IF;
      END IF;

      -- assume that we need to add the new candidate to l_current_used_details
      -- unless we find it in l_current_used_details.
      l_match_found := FALSE;

      -- is this delivery detail fully or partialy used?
      IF l_current_used_details.COUNT > 0 THEN
        l_new_index := l_current_used_details.FIRST;

<<used_loop>>
        WHILE l_new_index IS NOT NULL LOOP
          IF (candidate.delivery_detail_id = l_current_used_details(l_new_index).delivery_detail_id)  THEN
            l_match_found := TRUE;
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'l_current_used_details found: l_new_index', l_new_index);
            END IF;
            EXIT used_loop;
          END IF;
          l_new_index := l_current_used_details.NEXT(l_new_index);
        END LOOP;
      END IF;

      IF     l_match_found
         AND l_current_used_details(l_new_index).available_quantity = 0 THEN
        -- this candidate has been used up.
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'candidate is used up: delivery_detail_id', l_current_used_details(l_new_index).delivery_detail_id);
        END IF;
        GOTO next_candidate;
      END IF;

      -- if necessary, make sure candidate's essential grouping attributes match before we map
      IF l_first_line_map THEN
        -- we need to make sure the first line match
        -- the interface delivery's grouping attributes that are passed by TP (and
        -- cannot be overwritten by data protection if delivery already has lines assigned):
        --   shipment_direction, ship_from_location_id, ship_to_location_id, organization_id, customer_id

        -- line can update these grouping attributes;
        --    if we can map the line we will update the plan delivery later.
        l_current_attributes.fob_code              := candidate.fob_code;
        l_current_attributes.freight_terms_code    := candidate.freight_terms_code;
        l_current_attributes.intmed_ship_to_location_id := candidate.intmed_ship_to_location_id;
        l_current_attributes.ship_method_code      := candidate.ship_method_code;
        l_current_attributes.mode_of_transport     := candidate.mode_of_transport;
        l_current_attributes.service_level         := candidate.service_level;
        l_current_attributes.carrier_id            := candidate.carrier_id;
        l_current_attributes.vendor_id             := candidate.vendor_id;
        l_current_attributes.party_id              := candidate.party_id;
        l_current_attributes.shipping_control      := candidate.shipping_control;
      ELSE
        -- these ship method components need to stay current to support generic carrier.
        -- (interface line may map to delivery details within an order line set).
        l_current_attributes.ship_method_code   := x_plan_deliveries(l_target_delivery_index).ship_method_code;
        l_current_attributes.mode_of_transport  := x_plan_deliveries(l_target_delivery_index).mode_of_transport;
        l_current_attributes.service_level      := x_plan_deliveries(l_target_delivery_index).service_level;
        l_current_attributes.carrier_id         := x_plan_deliveries(l_target_delivery_index).carrier_id;
      END IF;

      IF NOT attributes_match(
             x_attributes => l_current_attributes,
             x_values     => candidate)  THEN
        l_group_not_matched := TRUE;
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'attributes_match returns FALSE');
        END IF;
        GOTO next_candidate;
      END IF;


      IF NOT l_match_found THEN  --{
        -- delivery detail is new. Lock it and add it to the list of used details.
        BEGIN
          wsh_delivery_details_pkg.lock_detail_no_compare(
                 p_delivery_detail_id => candidate.delivery_detail_id);
        EXCEPTION
          WHEN OTHERS THEN
               stamp_interface_error(
                   p_group_id            => x_context.group_id,
                   p_entity_table_name   => 'WSH_DEL_DETAILS_INTERFACE',
                   p_entity_interface_id => iline.dd_interface_id,
                   p_message_name        => 'WSH_TP_I_NO_LOCK_DD',
                   p_token_1_name        => 'DETAIL_ID',
                   p_token_1_value       => candidate.delivery_detail_id,
                   x_errors_tab          => x_errors_tab,
                   x_return_status       => l_return_status);
               GOTO next_candidate;
        END;

        -- Lock its delivery if it will be unassigned
        IF     candidate.delivery_id IS NOT NULL
           AND candidate.delivery_id <> NVL(x_plan_deliveries(l_target_delivery_index).delivery_id,0) THEN
          BEGIN
            wsh_new_deliveries_pvt.lock_dlvy_no_compare(
                p_delivery_id => candidate.delivery_id);
          EXCEPTION
            WHEN OTHERS THEN
              stamp_interface_error(
                    p_group_id            => x_context.group_id,
                    p_entity_table_name   => 'WSH_DEL_DETAILS_INTERFACE',
                    p_entity_interface_id => iline.dd_interface_id,
                    p_message_name        => 'WSH_TP_I_NO_LOCK_DEL',
                    p_token_1_name        => 'DELIVERY_NAME',
                    p_token_1_value       => WSH_NEW_DELIVERIES_PVT.get_name(candidate.delivery_id),
                    x_errors_tab          => x_errors_tab,
                    x_return_status       => l_return_status);
              GOTO next_candidate;
          END;
        END IF;

        -- if this is the same order line mapped and its order line is not yet picked,
        -- validate that the ordered quantity has not been increased.
        -- inbound/drop: this validation applies only to outbound and internal outbound lines.
        IF     candidate.source_line_id = iline.source_line_id
           AND candidate.released_status IN ('N', 'R', 'X')
           AND NVL(candidate.line_direction, 'O') IN ('O', 'IO') THEN

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Validating ordered quantity increase');
          END IF;

          -- if the order line has been split, its quantity will generally be reduced.
          IF candidate.src_requested_quantity >
                  WSH_WV_UTILS.Convert_Uom(
                    from_uom => iline.src_requested_quantity_uom,
                    to_uom   => candidate.src_requested_quantity_uom,
                    quantity => iline.src_requested_quantity,
                    item_id  => candidate.inventory_item_id)  THEN

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'candidate.src_requested_quantity', candidate.src_requested_quantity);
              WSH_DEBUG_SV.log(l_module_name, 'candidate.src_requested_quantity_uom', candidate.src_requested_quantity_uom);

              WSH_DEBUG_SV.log(l_module_name, 'iline.src_requested_quantity',     iline.src_requested_quantity);
              WSH_DEBUG_SV.log(l_module_name, 'iline.src_requested_quantity_uom', iline.src_requested_quantity_uom);
            END IF;

            -- order line quantity has been increased;
            -- check if order line is in process of being staged
            l_dummy_dd_id := NULL;
            OPEN c_being_staged(p_source_code => candidate.source_code,
                                    p_source_line_id => candidate.source_line_id);
            FETCH c_being_staged INTO l_dummy_dd_id;
            IF c_being_staged%NOTFOUND THEN
               l_dummy_dd_id := NULL;
            END IF;
            CLOSE c_being_staged;

            IF l_dummy_dd_id IS NULL THEN
              -- order line has not been staged; fail the plan.
              stamp_interface_error(
                 p_group_id            => x_context.group_id,
                 p_entity_table_name   => 'WSH_DEL_DETAILS_INTERFACE',
                 p_entity_interface_id => iline.dd_interface_id,
                 p_message_name        => 'WSH_TP_F_QTY_INCREASE',
                 p_token_1_name        => 'DETAIL_ID',
                 p_token_1_value       => candidate.delivery_detail_id,
                 x_errors_tab          => x_errors_tab,
                 x_return_status       => l_return_status);
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              RETURN;
            END IF;
          END IF;
        END IF;

        -- add to l_current_used_details
        IF (l_current_used_details.COUNT = 0)  THEN
          l_new_index := 1;
        ELSE
          l_new_index := l_current_used_details.LAST + 1;
        END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'adding to l_current_used_details: l_new_index', l_new_index);
        END IF;



        l_current_used_details(l_new_index).delivery_detail_id  := candidate.delivery_detail_id;
        l_current_used_details(l_new_index).dd_interface_id     := iline.dd_interface_id;
        l_current_used_details(l_new_index).available_quantity  := candidate.quantity;
        l_current_used_details(l_new_index).available_quantity_uom := candidate.quantity_uom;
        l_current_used_details(l_new_index).current_delivery_id := candidate.delivery_id;
        l_current_used_details(l_new_index).topmost_cont_id     := wsh_container_utilities.get_master_cont_id(candidate.delivery_detail_id);
        l_current_used_details(l_new_index).target_delivery_index := l_target_delivery_index;
        l_current_used_details(l_new_index).track_cont_content_found := FALSE;
        l_current_used_details(l_new_index).released_status     := candidate.released_status;
        l_current_used_details(l_new_index).move_order_line_id  := candidate.move_order_line_id;
        l_current_used_details(l_new_index).split_count         := 0;
        l_current_used_details(l_new_index).need_unassignment   := FALSE;
        l_current_used_details(l_new_index).organization_id     := candidate.organization_id;
        l_current_used_details(l_new_index).line_direction      := candidate.line_direction;
      END IF; --}


      -- at this point, l_new_index points to the record in l_current_used_details
      -- we need to finish the mapping:
      --    * check conditions when line is split:
      --         it is in WMS org and released to warehouse or it is packed,
      --         and it goes into different deliveries, fail because
      --         it will break LPN configuration.
      --    * add the line to x_plan_details
      --    * track delivery associated with delivery lines
      --           if delivery is new, lock delivery and add to x_plan_deliveries

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'quantity left to map',  l_current_attributes.mapped_quantity);
        WSH_DEBUG_SV.log(l_module_name, 'current used detail available quantity',  l_current_used_details(l_new_index).available_quantity);
      END IF;

      -- make sure that if line has been split and lines packed in the same container,
      -- the remaining quantity will not go into a different delivery.
      IF     l_current_used_details(l_new_index).split_count > 0
         AND l_current_used_details(l_new_index).topmost_cont_id IS NOT NULL
         AND x_plan_deliveries(l_current_used_details(l_new_index).target_delivery_index).del_interface_id
             <> iline.delivery_interface_id THEN
        stamp_interface_error(
            p_group_id            => x_context.group_id,
            p_entity_table_name   => 'WSH_DEL_DETAILS_INTERFACE',
            p_entity_interface_id => iline.dd_interface_id,
            p_message_name        => 'WSH_TP_I_LPN_BREAK',
            p_token_1_name        => 'DETAIL_ID',
            p_token_1_value       => candidate.delivery_detail_id,
            x_errors_tab          => x_errors_tab,
            x_return_status       => l_return_status);
         GOTO next_candidate;
      END IF;


      IF l_current_used_details(l_new_index).available_quantity > l_current_attributes.mapped_quantity THEN
        -- this line has to be split.

        l_mapped_quantity := l_current_attributes.mapped_quantity;
        l_map_split_flag  := 'Y';

        -- if line is released to warehouse, it cannot be split.
        IF candidate.released_status = 'S' THEN
          stamp_interface_error(
              p_group_id            => x_context.group_id,
              p_entity_table_name   => 'WSH_DEL_DETAILS_INTERFACE',
              p_entity_interface_id => iline.dd_interface_id,
              p_message_name        => 'WSH_TP_I_SPLIT_RELEASED',
              p_token_1_name        => 'DETAIL_ID',
              p_token_1_value       => candidate.delivery_detail_id,
              x_errors_tab          => x_errors_tab,
              x_return_status       => l_return_status);
           GOTO next_candidate;
        END IF;

-- HW OPMCONV - Removed branching and replaced old OPM API call
-- to check for item with new WSH API

       WSH_DELIVERY_DETAILS_INV.Get_item_information
          (
               p_organization_id       => candidate.organization_id
              , p_inventory_item_id    => candidate.inventory_item_id
              , x_mtl_system_items_rec => l_item_info
              , x_return_status        => l_return_status
            );
-- HW OPMCONV - check for lot_divisible using new variable
           IF (  l_item_info.lot_divisible_flag = 'N' AND
                 l_item_info.lot_control_code= 2)
             AND (l_current_used_details(l_new_index).released_status
                    IN ('Y', 'B'))  THEN
             stamp_interface_error(
                 p_group_id            => x_context.group_id,
                 p_entity_table_name   => 'WSH_DEL_DETAILS_INTERFACE',
                 p_entity_interface_id => iline.dd_interface_id,
                 p_message_name        => 'WSH_TP_I_SPLIT_OPM_IND_LOT',
                 p_token_1_name        => 'DETAIL_ID',
                 p_token_1_value       => candidate.delivery_detail_id,
                 x_errors_tab          => x_errors_tab,
                 x_return_status       => l_return_status);
            GOTO next_candidate;
          END IF;


        -- line will be split.
        l_current_used_details(l_new_index).split_count :=
               l_current_used_details(l_new_index).split_count + 1;

      ELSE
        l_mapped_quantity := l_current_used_details(l_new_index).available_quantity;
        l_map_split_flag  := 'N';
      END IF;

      -- if line is packed in the container, make sure they go into the same target delivery.
      -- l_cont_index and l_new_cont will be used later to track LPN configuration
      IF l_current_used_details(l_new_index).topmost_cont_id IS NOT NULL THEN --{
        IF (x_track_conts.COUNT > 0)  THEN

          l_cont_index := x_track_conts.FIRST;
          l_new_cont   := TRUE;

          WHILE l_cont_index <= x_track_conts.COUNT LOOP
            IF (x_track_conts(l_cont_index).topmost_cont_id =
                    l_current_used_details(l_new_index).topmost_cont_id) THEN
              l_new_cont := FALSE;
              EXIT;
            END IF;
            l_cont_index := l_cont_index + 1;
          END LOOP;

          IF NOT l_new_cont THEN
            IF (x_track_conts(l_cont_index).target_delivery_index <> l_target_delivery_index) THEN
              -- we should not break the LPN.
              GOTO next_candidate;
            END IF;
          END IF;
        ELSE
          l_cont_index := 1;
          l_new_cont   := TRUE;
        END IF;
      END IF; --}

      -- check if the interface delivery needs mapping
      IF     x_plan_deliveries(l_target_delivery_index).delivery_id IS NULL
         AND candidate.delivery_id IS NOT NULL THEN

        -- first, verify delivery_id has not already been mapped.
        DECLARE
          i NUMBER;
        BEGIN
          i := x_plan_deliveries.FIRST;
<<deliveries_loop>>
          WHILE i IS NOT NULL LOOP
            IF (x_plan_deliveries(i).delivery_id = candidate.delivery_id)  THEN
              EXIT deliveries_loop;
            END IF;
            i := x_plan_deliveries.NEXT(i);
          END LOOP;

          IF i IS NULL THEN
            -- this delivery is now mapped.
            x_plan_deliveries(l_target_delivery_index).delivery_id := candidate.delivery_id;
          END IF;
        END;
      END IF;

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'mapping delivery_detail_id: ', l_current_used_details(l_new_index).delivery_detail_id);
        WSH_DEBUG_SV.log(l_module_name,'l_mapped_quantity: ', l_mapped_quantity);
        WSH_DEBUG_SV.log(l_module_name,'l_map_split_flag: ', l_map_split_flag);
      END IF;

      l_plan_dd_index := l_plan_dd_index + 1;

      x_plan_details(l_plan_dd_index).delivery_detail_id    := l_current_used_details(l_new_index).delivery_detail_id;
      x_plan_details(l_plan_dd_index).dd_interface_id       := iline.dd_interface_id;
      x_plan_details(l_plan_dd_index).tp_delivery_detail_id := iline.tp_delivery_detail_id;
      x_plan_details(l_plan_dd_index).mapped_quantity       := l_mapped_quantity;
      x_plan_details(l_plan_dd_index).mapped_quantity_uom   := candidate.quantity_uom;
      x_plan_details(l_plan_dd_index).map_split_flag        := l_map_split_flag;
      x_plan_details(l_plan_dd_index).released_status       := candidate.released_status;
      x_plan_details(l_plan_dd_index).move_order_line_id    := candidate.move_order_line_id;
      x_plan_details(l_plan_dd_index).line_direction        := candidate.line_direction;
      x_plan_details(l_plan_dd_index).source_code           := candidate.source_code;
      x_plan_details(l_plan_dd_index).source_header_id      := candidate.source_header_id;
      x_plan_details(l_plan_dd_index).source_line_set_id    := candidate.source_line_set_id;
      x_plan_details(l_plan_dd_index).source_line_id        := candidate.source_line_id;
      x_plan_details(l_plan_dd_index).ship_set_id           := candidate.ship_set_id;
      x_plan_details(l_plan_dd_index).top_model_line_id     := candidate.top_model_line_id;
      x_plan_details(l_plan_dd_index).ato_line_id           := candidate.ato_line_id;
      x_plan_details(l_plan_dd_index).ship_model_complete_flag   := candidate.ship_model_complete_flag;
      x_plan_details(l_plan_dd_index).ship_from_location_id := candidate.ship_from_location_id;
      x_plan_details(l_plan_dd_index).ship_to_location_id   := candidate.ship_to_location_id;
      x_plan_details(l_plan_dd_index).organization_id       := candidate.organization_id;
      x_plan_details(l_plan_dd_index).customer_id           := candidate.customer_id;
      x_plan_details(l_plan_dd_index).fob_code              := candidate.fob_code;
      x_plan_details(l_plan_dd_index).freight_terms_code    := candidate.freight_terms_code;
      x_plan_details(l_plan_dd_index).intmed_ship_to_location_id   := candidate.intmed_ship_to_location_id;
      x_plan_details(l_plan_dd_index).ship_method_code      := candidate.ship_method_code;
      x_plan_details(l_plan_dd_index).mode_of_transport     := candidate.mode_of_transport;
      x_plan_details(l_plan_dd_index).service_level         := candidate.service_level;
      x_plan_details(l_plan_dd_index).carrier_id            := candidate.carrier_id;
      x_plan_details(l_plan_dd_index).topmost_cont_id       := l_current_used_details(l_new_index).topmost_cont_id;
      x_plan_details(l_plan_dd_index).current_delivery_id   := candidate.delivery_id;
      x_plan_details(l_plan_dd_index).target_delivery_index := l_target_delivery_index;
      x_plan_details(l_plan_dd_index).wv_frozen_flag        := candidate.wv_frozen_flag;  -- WV changes


      IF (l_first_line_map) THEN
        -- in this context, make sure the delivery's grouping attributes match
        -- those of the first line mapped.
        -- (per data protection, only currency, organization, customer, ship-from
        --  and ship-to cannot be updated)
        l_first_line_map := FALSE;

        x_plan_deliveries(l_target_delivery_index).fob_code := candidate.fob_code;
        x_plan_deliveries(l_target_delivery_index).freight_terms_code := candidate.freight_terms_code;
        x_plan_deliveries(l_target_delivery_index).intmed_ship_to_location_id := candidate.intmed_ship_to_location_id;
        x_plan_deliveries(l_target_delivery_index).ship_method_code := candidate.ship_method_code;
        x_plan_deliveries(l_target_delivery_index).mode_of_transport := candidate.mode_of_transport;
        x_plan_deliveries(l_target_delivery_index).service_level := candidate.service_level;
        x_plan_deliveries(l_target_delivery_index).carrier_id := candidate.carrier_id;
        x_plan_deliveries(l_target_delivery_index).vendor_id := candidate.vendor_id;
        x_plan_deliveries(l_target_delivery_index).party_id := candidate.party_id;
        x_plan_deliveries(l_target_delivery_index).shipping_control := candidate.shipping_control;

        x_plan_deliveries(l_target_delivery_index).wms_org_flag :=
                 wsh_util_validate.Check_Wms_Org(candidate.organization_id);

      END IF;

      -- support generic carrier by updating NULL values with non-NULL values
      --  we will later create/update the delivery with components;
      --     ship_method_code is not used.
      x_plan_deliveries(l_target_delivery_index).ship_method_code :=
                  NVL(x_plan_deliveries(l_target_delivery_index).ship_method_code, candidate.ship_method_code);
      x_plan_deliveries(l_target_delivery_index).mode_of_transport :=
                  NVL(x_plan_deliveries(l_target_delivery_index).mode_of_transport, candidate.mode_of_transport);
      x_plan_deliveries(l_target_delivery_index).service_level :=
                  NVL(x_plan_deliveries(l_target_delivery_index).service_level, candidate.service_level);
      x_plan_deliveries(l_target_delivery_index).carrier_id :=
                  NVL(x_plan_deliveries(l_target_delivery_index).carrier_id, candidate.carrier_id);



      IF (x_plan_deliveries(l_target_delivery_index).lines_count = 0)  THEN
        -- count the deliveries that have at least one line mapped.
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'l_target_delivery_index for delivery is populated: ', l_target_delivery_index);
        END IF;
        l_deliveries_populated := l_deliveries_populated + 1;
      END IF;

      x_plan_deliveries(l_target_delivery_index).lines_count :=
                     x_plan_deliveries(l_target_delivery_index).lines_count + 1;
      IF l_current_used_details(l_new_index).released_status = 'S' THEN
        x_plan_deliveries(l_target_delivery_index).s_lines_count :=
                     x_plan_deliveries(l_target_delivery_index).s_lines_count + 1;
      END IF;

      l_current_used_details(l_new_index).available_quantity :=
                     l_current_used_details(l_new_index).available_quantity - l_mapped_quantity;
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'l_current_used_details(' || l_new_index || ').available_quantity is now',
                  l_current_used_details(l_new_index).available_quantity);
      END IF;

      l_current_attributes.mapped_quantity := l_current_attributes.mapped_quantity - l_mapped_quantity;

      -- next, track LPN configuration associated with that delivery detail being mapped
      --     For new topmost LPNs, we build sublist of non-container contents
      --     As we go through the interface lines that are packed, we will remove them from these sublists.
      --     LPN configuration will be broken only if the sublists remain after we complete the interface lines.
      IF     (x_plan_details(l_plan_dd_index).topmost_cont_id IS NOT NULL)
         AND (NOT l_current_used_details(l_new_index).track_cont_content_found) THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'tracking topmost_cont_id', x_plan_details(l_plan_dd_index).topmost_cont_id);
        END IF;

        DECLARE
          l_content_index NUMBER := NULL;

          -- make a flat list of contents within the topmost container.
          CURSOR c_contents(p_topmost_cont_id IN NUMBER) IS
             SELECT wda.delivery_detail_id
             FROM   wsh_delivery_assignments_v wda
             START WITH wda.delivery_detail_id = p_topmost_cont_id
             CONNECT BY PRIOR wda.delivery_detail_id = wda.parent_delivery_detail_id;

          -- another cursor to look up the attributes
          -- because CONNECT BY does not support joins.
          CURSOR c_detail(p_detail_id IN NUMBER) IS
             SELECT wdd.delivery_detail_id,
                    wdd.container_flag,
                    wdd.lpn_id,
                    wdd.released_status,
                    wdd.source_code
             FROM   wsh_delivery_details wdd
             WHERE  delivery_detail_id = p_detail_id;

        BEGIN
          -- l_cont_index and l_cont_found have been set up
          -- to ensure that the outermost LPN can be used for this candidate.

          IF l_new_cont THEN
            -- add this new topmost container to x_track_conts list.
            -- and build a sublist of container contents that are not yet mapped in l_cont_contents.
            --   do not add this mapped line to that sublist because it is accounted for.
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'new container: l_cont_index', l_cont_index);
            END IF;

            x_track_conts(l_cont_index).topmost_cont_id         := x_plan_details(l_plan_dd_index).topmost_cont_id;
            x_track_conts(l_cont_index).plan_dd_index           := l_plan_dd_index;
            x_track_conts(l_cont_index).current_delivery_id     := x_plan_details(l_plan_dd_index).current_delivery_id;
            x_track_conts(l_cont_index).target_delivery_index   := x_plan_details(l_plan_dd_index).target_delivery_index;
            x_track_conts(l_cont_index).organization_id         := x_plan_details(l_plan_dd_index).organization_id;
            x_track_conts(l_cont_index).cont_content_base_index := NULL;

            -- lock all details in the LPN configuration and build sublist of non-container contents
            FOR content IN c_contents(x_track_conts(l_cont_index).topmost_cont_id) LOOP --[
              FOR c IN c_detail(content.delivery_detail_id) LOOP --{

                IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'looping c_contents: delivery_detail_id', c.delivery_detail_id);
                END IF;

                IF (c.delivery_detail_id = x_track_conts(l_cont_index).topmost_cont_id)  THEN
                  -- cache this topmost container details for future reference
                  x_track_conts(l_cont_index).lpn_id          := c.lpn_id;
                  x_track_conts(l_cont_index).released_status := c.released_status;
                  x_track_conts(l_cont_index).source_code     := c.source_code;
                END IF;

                BEGIN
                  wsh_delivery_details_pkg.lock_detail_no_compare(
                       p_delivery_detail_id => c.delivery_detail_id);
                EXCEPTION
                  WHEN OTHERS THEN
                     stamp_interface_error(
                       p_group_id            => x_context.group_id,
                       p_entity_table_name   => 'WSH_NEW_DELIVERIES_INTERFACE',
                       p_entity_interface_id => x_plan_details(x_track_conts(l_cont_index).plan_dd_index).dd_interface_id,
                       p_message_name        => 'WSH_TP_F_NO_LOCK_LPN_CONTENTS',
                       p_token_1_name        => 'CONTAINER_NAME',
                       p_token_1_value       => wsh_container_utilities.get_cont_name(x_track_conts(l_cont_index).topmost_cont_id),
                       x_errors_tab          => x_errors_tab,
                       x_return_status       => l_return_status);
                   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                   IF l_debug_on THEN
                     WSH_DEBUG_SV.pop(l_module_name);
                   END IF;
                   RETURN;
                 END;

                 IF c.container_flag = 'N' THEN --{
                   IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'topmost_cont_id: content line status', c.released_status);
                   END IF;

                   x_track_conts(l_cont_index).lines_staged :=
                           x_track_conts(l_cont_index).lines_staged OR (c.released_status IN ('Y', 'C'));
                   IF c.delivery_detail_id = x_plan_details(l_plan_dd_index).delivery_detail_id  THEN --[
                      l_current_used_details(l_new_index).track_cont_content_found := TRUE;
                   ELSE
                      IF l_content_index IS NULL THEN --(
                        IF l_cont_contents.COUNT = 0 THEN
                          l_content_index := 1;
                        ELSE
                          l_content_index := l_cont_contents.LAST + 1;
                        END IF;
                        x_track_conts(l_cont_index).cont_content_base_index := l_content_index;
                      ELSE
                        l_content_index := l_content_index + 1;
                      END IF; --)

                      IF l_debug_on THEN
                       WSH_DEBUG_SV.log(l_module_name,'topmost_cont_id: l_content_index', l_content_index);
                      END IF;

                      l_cont_contents(l_content_index).track_cont_index   := l_cont_index;
                      l_cont_contents(l_content_index).delivery_detail_id := c.delivery_detail_id;
                   END IF; --]
                 END IF;  --}
              END LOOP; --}
            END LOOP; --]

            -- check if this LPN will need unassignment from current delivery
            IF (x_plan_deliveries(x_track_conts(l_cont_index).target_delivery_index).delivery_id
                  <> x_track_conts(l_cont_index).current_delivery_id) THEN
              x_delivery_unassigns(x_delivery_unassigns.COUNT + 1).delivery_detail_id := x_track_conts(l_cont_index).topmost_cont_id;
              x_delivery_unassigns(x_delivery_unassigns.COUNT).delivery_id            := x_track_conts(l_cont_index).current_delivery_id;
              x_delivery_unassigns(x_delivery_unassigns.COUNT).organization_id        := x_track_conts(l_cont_index).organization_id;
              x_delivery_unassigns(x_delivery_unassigns.COUNT).container_flag         := 'Y';
              x_delivery_unassigns(x_delivery_unassigns.COUNT).lines_staged           := x_track_conts(l_cont_index).lines_staged;
              x_delivery_unassigns(x_delivery_unassigns.COUNT).wms_org_flag           := wsh_util_validate.Check_Wms_Org(x_track_conts(l_cont_index).organization_id);
              x_delivery_unassigns(x_delivery_unassigns.COUNT).source_code            := x_track_conts(l_cont_index).source_code;
              x_delivery_unassigns(x_delivery_unassigns.COUNT).released_status        := x_track_conts(l_cont_index).released_status;
              x_delivery_unassigns(x_delivery_unassigns.COUNT).lpn_id                 := x_track_conts(l_cont_index).lpn_id;
              x_delivery_unassigns(x_delivery_unassigns.COUNT).plan_dd_index          := l_plan_dd_index;
              x_delivery_unassigns(x_delivery_unassigns.COUNT).plan_del_index         := NULL;
            END IF;

          ELSE
            -- look for this delivery detail to remove from the sublist.
            l_content_index := x_track_conts(l_cont_index).cont_content_base_index;

            WHILE l_content_index IS NOT NULL LOOP
               IF (l_cont_contents(l_content_index).delivery_detail_id = x_plan_details(l_plan_dd_index).delivery_detail_id) THEN

                 -- now that the content is found, remove it from the topmost container's sublist.
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,
                                     'cont content is found for dd_id: ',
                                     l_cont_contents(l_content_index).delivery_detail_id);
                 END IF;
                 l_current_used_details(l_new_index).track_cont_content_found := TRUE;

                 IF (l_content_index <> x_track_conts(l_cont_index).cont_content_base_index)  THEN
                    l_cont_contents.DELETE(l_content_index);
                 ELSE
                    -- base index needs to be updated.
                    x_track_conts(l_cont_index).cont_content_base_index := l_cont_contents.NEXT(l_content_index);
                    l_cont_contents.DELETE(l_content_index);
                    l_content_index := x_track_conts(l_cont_index).cont_content_base_index;
                    IF l_content_index IS NOT NULL THEN
                      -- make sure this new base index is for the same topmost container.
                      IF (l_cont_contents(l_content_index).track_cont_index <> l_cont_index)  THEN
                         l_content_index := NULL;
                         x_track_conts(l_cont_index).cont_content_base_index := NULL;
                         IF l_debug_on THEN
                           WSH_DEBUG_SV.log(l_module_name, 'sublist is empty for l_cont_index: ', l_cont_index);
                         END IF;
                      END IF;
                    END IF;
                 END IF;

                 EXIT;

               END IF;
               l_content_index := l_cont_contents.NEXT(l_content_index);
               IF l_content_index IS NOT NULL THEN
                 IF l_cont_contents(l_content_index).track_cont_index <> l_cont_index THEN
                   -- end of the container sublist has been reached.
                   EXIT;
                 END IF;
               END IF;
            END LOOP;

          END IF;

        EXCEPTION
          WHEN OTHERS THEN
            IF c_contents%ISOPEN THEN
              CLOSE c_contents;
            END IF;
            IF c_detail%ISOPEN THEN
              CLOSE c_detail;
            END IF;
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
            WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TP_RELEASE.GENERATE_LOCK_CANDIDATES(nested)',
                        l_module_name);

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured in nested block. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
            END IF;
            RETURN;
        END;

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'finished tracking topmost_cont_id: ', x_plan_details(l_plan_dd_index).topmost_cont_id);
        END IF;

      END IF;

      IF l_current_attributes.mapped_quantity <= 0 THEN
        -- at this point, interface line is now fully mapped.
        EXIT candidates_loop;
      END IF;

<<next_candidate>>
      NULL;

    END LOOP; -- candidate

    IF l_current_attributes.mapped_quantity > 0 THEN --{
      -- the interface line has not been fully mapped.
      -- Possible reasons:
      --    -  order line quantity has been split or reduced (this is OK)
      --    -  no candidate available
      --              * enforced grouping attributes not matched (should fail)
      --              * in firmed deliveries
      --              * ignored for planning
      --    -  ship-from and ship-to location changes (this should fail)
      --    -  order line has become ignored for planning (this should fail)

      IF l_candidates_count > 0 THEN --[

        stamp_interface_error(
            p_group_id            => x_context.group_id,
            p_entity_table_name   => 'WSH_DEL_DETAILS_INTERFACE',
            p_entity_interface_id => iline.dd_interface_id,
            p_message_name        => 'WSH_TP_I_LINE_LEFTOVER',
            p_token_1_name        => 'QUANTITY',
            p_token_1_value       => l_current_attributes.mapped_quantity,
            p_token_2_name        => 'QTY_UOM',
            p_token_2_value       => l_current_attributes.mapped_quantity_uom,
            x_errors_tab          => x_errors_tab,
            x_return_status       => l_return_status);

      ELSE
        -- since no candidate was found for the line,
        --  check location changes and ignore_for_planning.
        --   Note: if the line is completely ignored or has location changes,
        --         we would not find any candidate to try matching the group.

        l_dummy_dd_id := NULL;
        FOR c IN c_location_change(p_source_code           => iline.source_code,
                                   p_source_header_id      => iline.source_header_id,
                                   p_source_line_id        => iline.source_line_id,
                                   p_ship_from_location_id => iline.ship_from_location_id,
                                   p_ship_to_location_id   => iline.ship_to_location_id) LOOP
          -- this loop runs at most once.
          l_dummy_dd_id := c.delivery_detail_id;
        END LOOP;
        IF l_dummy_dd_id IS NOT NULL THEN
          stamp_interface_error(
              p_group_id            => x_context.group_id,
              p_entity_table_name   => 'WSH_DEL_DETAILS_INTERFACE',
              p_entity_interface_id => iline.dd_interface_id,
              p_message_name        => 'WSH_TP_F_LOC_CHANGE',
              x_errors_tab          => x_errors_tab,
              x_return_status       => l_return_status);
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          RETURN;
        END IF;

        l_dummy_dd_id := NULL;
        FOR c IN c_ignored(p_source_code           => iline.source_code,
                           p_source_header_id      => iline.source_header_id,
                           p_source_line_id        => iline.source_line_id)  LOOP
          -- this loop runs at most once.
          l_dummy_dd_id := c.delivery_detail_id;
        END LOOP;
        IF l_dummy_dd_id IS NOT NULL THEN
          stamp_interface_error(
              p_group_id            => x_context.group_id,
              p_entity_table_name   => 'WSH_DEL_DETAILS_INTERFACE',
              p_entity_interface_id => iline.dd_interface_id,
              p_message_name        => 'WSH_TP_F_IGNORED',
              p_token_1_name        => 'DETAIL_ID',
              p_token_1_value       => l_dummy_dd_id,
              x_errors_tab          => x_errors_tab,
              x_return_status       => l_return_status);
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          RETURN;
        END IF;

      END IF; --]

      -- if the line is fully unmapped, check if that is due to grouping
      -- this condition is not as serious as the above conditions
      -- becuause usually you can disable grouping attributes in
      -- shipping parameters for outbound lines.
      IF     (l_current_attributes.mapped_quantity = iline.quantity)
         AND l_group_not_matched THEN
        stamp_interface_error(
              p_group_id            => x_context.group_id,
              p_entity_table_name   => 'WSH_DEL_DETAILS_INTERFACE',
              p_entity_interface_id => iline.dd_interface_id,
              p_message_name        => 'WSH_TP_F_NOT_IN_GROUP',
              p_token_1_name        => 'PLAN_DEL_NUM',
              p_token_1_value       => x_plan_deliveries(l_target_delivery_index).tp_delivery_number,
              x_errors_tab          => x_errors_tab,
              x_return_status       => l_return_status);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      END IF;

    END IF; --}

    l_last_interface_id := iline.delivery_detail_id;

  END LOOP; -- iline

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'end of iline loop: l_current_used_details.COUNT: ', l_current_used_details.COUNT);
  END IF;

  IF (l_current_used_details.COUNT > 0)  THEN
    flush_used_details(
       x_context              => x_context,
       x_current_used_details => l_current_used_details,
       x_used_details         => x_used_details,
       x_errors_tab           => x_errors_tab,
       x_return_status        => l_return_status);
    IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR))  THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      RETURN;
    END IF;
  END IF;

  -- 3. check outcome of mapping lines and deliveries.

  -- Bug 3555487 initialize message stack for each major action points.
  FND_MSG_PUB.initialize;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_plan_details.COUNT', x_plan_details.COUNT);
  END IF;

  IF     (l_interface_lines_count > 0)
     AND (x_plan_details.COUNT = 0)     THEN
    -- we fail the plan if none of the plan lines got mapped.
    --
    -- We are allowed to release a plan with only dangling containers
    -- (in case that TP captures the firm deliveries with only containers),
    -- which we will check in the next step.

    stamp_interface_error(
          p_group_id            => x_context.group_id,
          p_entity_table_name   => 'NONE',
          p_entity_interface_id => -1,
          p_message_name        => 'WSH_TP_F_NO_LINES',
          p_token_1_name        => 'PLAN_TRIP_NUM',
          p_token_1_value       => get_plan_trip_num(x_context),
          x_errors_tab          => x_errors_tab,
          x_return_status       => l_return_status);
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
  END IF;


  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'l_deliveries_populated', l_deliveries_populated);
    WSH_DEBUG_SV.log(l_module_name, 'x_plan_deliveries.COUNT', x_plan_deliveries.COUNT);
  END IF;

  IF l_deliveries_populated < x_plan_deliveries.COUNT THEN
    -- we need to check for these deliveries:
    --      a) delivery without lines mapped (fail the plan)
    --      b) delivery with dangling containers
    --             (fail the plan if the delivery is not found or firm
    --              or if the dangling containers do not match the
    --              plan containers).

    l_new_index := x_plan_deliveries.FIRST;
    WHILE l_new_index IS NOT NULL LOOP

      IF x_plan_deliveries(l_new_index).ilines_count > 0
         AND x_plan_deliveries(l_new_index).lines_count = 0 THEN
        -- fail the plan because this delivery has plan lines
        -- and none of them has been mapped.
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        stamp_interface_error(
            p_group_id            => x_context.group_id,
            p_entity_table_name   => 'WSH_NEW_DEL_INTERFACE',
            p_entity_interface_id => x_plan_deliveries(l_new_index).del_interface_id,
            p_message_name        => 'WSH_TP_F_EMPTY_DEL',
            p_token_1_name        => 'PLAN_DEL_NUM',
            p_token_1_value       => x_plan_deliveries(l_new_index).tp_delivery_number,
            p_token_2_name        => 'PLAN_TRIP_NUM',
            p_token_2_value       => get_plan_trip_num(x_context),
            x_errors_tab          => x_errors_tab,
            x_return_status       => l_return_status);
        -- ignore return status
      ELSIF x_plan_deliveries(l_new_index).ilines_count = 0 THEN

        -- TE delivery must exist for the plan delivery
        -- and their firm states must match.
        IF    (x_plan_deliveries(l_new_index).delivery_id IS NULL)
           OR (x_plan_deliveries(l_new_index).wsh_planned_flag <>
                 x_plan_deliveries(l_new_index).planned_flag)  THEN
          -- fail the plan because this empty delivery with dangling
          -- containers does not exist or does not have the original firm status.
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          stamp_interface_error(
              p_group_id            => x_context.group_id,
              p_entity_table_name   => 'WSH_NEW_DEL_INTERFACE',
              p_entity_interface_id => x_plan_deliveries(l_new_index).del_interface_id,
              p_message_name        => 'WSH_TP_F_DANGLING_DEL_DIFF',  -- new message
              p_token_1_name        => 'PLAN_DEL_NUM',
              p_token_1_value       => x_plan_deliveries(l_new_index).tp_delivery_number,
              p_token_2_name        => 'PLAN_TRIP_NUM',
              p_token_2_value       => get_plan_trip_num(x_context),
              x_errors_tab          => x_errors_tab,
              x_return_status       => l_return_status);
          -- ignore return status
        END IF;

        map_dangling_containers(
            x_context              => x_context,
            p_delivery_index       => l_new_index,
            x_plan_deliveries      => x_plan_deliveries,
            x_errors_tab           => x_errors_tab,
            x_return_status        => l_return_status);

        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
           AND x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          EXIT;  -- stop processing as soon as we know release will fail.
        ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
          EXIT;  -- unexpected error should stop the loop.
        END IF;

      END IF;

      l_new_index := x_plan_deliveries.NEXT(l_new_index);
    END LOOP;

    IF x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                           WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      RETURN;
    END IF;

  END IF;


  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'l_cont_contents.COUNT', l_cont_contents.COUNT);
  END IF;

  IF l_cont_contents.COUNT > 0 THEN
    -- LPN configuration is broken if sublists have not been completely mapped/deleted.

    l_new_index := x_track_conts.FIRST;
    WHILE l_new_index IS NOT NULL LOOP

      IF x_track_conts(l_new_index).cont_content_base_index IS NOT NULL THEN
        stamp_interface_error(
            p_group_id            => x_context.group_id,
            p_entity_table_name   => 'WSH_NEW_DEL_DETAILS_INTERFACE',
            p_entity_interface_id => x_plan_details(x_track_conts(l_new_index).plan_dd_index).dd_interface_id,
            p_message_name        => 'WSH_TP_F_BROKEN_LPN',
            p_token_1_name        => 'CONTAINER_NAME',
            p_token_1_value       => wsh_container_utilities.get_cont_name(x_track_conts(l_new_index).topmost_cont_id),
            p_token_2_name        => 'PLAN_TRIP_NUM',
            p_token_2_value       => get_plan_trip_num(x_context),
            x_errors_tab          => x_errors_tab,
            x_return_status       => l_return_status);
        -- ignore return status
      END IF;

      l_new_index := x_track_conts.NEXT(l_new_index);
    END LOOP;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;

  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'x_used_details.COUNT', x_used_details.COUNT);
  END IF;

  IF x_used_details.COUNT > 0 THEN
    -- validate we can unassign partially unused details from their current deliveries.

    l_new_index := x_used_details.FIRST;
    WHILE l_new_index IS NOT NULL LOOP
      l_target_delivery_index := x_used_details(l_new_index).target_delivery_index;

      IF     (x_used_details(l_new_index).current_delivery_id
               = x_plan_deliveries(l_target_delivery_index).delivery_id)
          AND
             (x_plan_deliveries(l_target_delivery_index).wsh_planned_flag <> 'N') THEN
        stamp_interface_error(
            p_group_id            => x_context.group_id,
            p_entity_table_name   => 'WSH_DEL_DETAILS_INTERFACE',
            p_entity_interface_id => x_used_details(l_new_index).dd_interface_id,
            p_message_name        => 'WSH_TP_F_FIRM_DEL_UNUSED',
            p_token_1_name        => 'DELIVERY_NAME',
            p_token_1_value       => WSH_NEW_DELIVERIES_PVT.get_name(
                                         x_plan_deliveries(l_target_delivery_index).delivery_id),
            p_token_2_name        => 'PLAN_TRIP_NUM',
            p_token_2_value       => get_plan_trip_num(x_context),
            p_token_3_name        => 'PLAN_DEL_NUM',
            p_token_3_value       => x_plan_deliveries(l_target_delivery_index).tp_delivery_number,
            x_errors_tab          => x_errors_tab,
            x_return_status       => l_return_status);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'unused line in firmed del: x_return_status', x_return_status);
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      END IF;
      l_new_index := x_used_details.NEXT(l_new_index);
    END LOOP;

  END IF;



  -- 4. Map and lock trips and stops

  -- Bug 3555487 initialize message stack for each major action point.
  FND_MSG_PUB.initialize;

  l_new_index := 0;
  FOR itrip IN c_tp_interface_trips(p_group_id => x_context.group_id)  LOOP  --{

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,
                       'itrip looping: trip_interface_id',
                       itrip.trip_interface_id);
      WSH_DEBUG_SV.log(l_module_name, 'itrip.trip_id', itrip.trip_id);
    END IF;

    l_new_index := l_new_index + 1;
    x_plan_trips(l_new_index).trip_interface_id   := itrip.trip_interface_id;
    x_plan_trips(l_new_index).trip_id             := itrip.trip_id;
    x_plan_trips(l_new_index).tp_plan_name        := itrip.tp_plan_name;
    x_plan_trips(l_new_index).tp_trip_number      := itrip.tp_trip_number;
    x_plan_trips(l_new_index).planned_flag        := itrip.planned_flag;
    x_plan_trips(l_new_index).wsh_planned_flag    := itrip.wsh_planned_flag;
    x_plan_trips(l_new_index).name                := itrip.name;
    x_plan_trips(l_new_index).vehicle_item_id     := itrip.vehicle_item_id;
    x_plan_trips(l_new_index).vehicle_organization_id := itrip.vehicle_organization_id;
    x_plan_trips(l_new_index).vehicle_num_prefix  := itrip.vehicle_num_prefix;
    x_plan_trips(l_new_index).vehicle_number      := itrip.vehicle_number;
    x_plan_trips(l_new_index).carrier_id          := itrip.carrier_id;
    x_plan_trips(l_new_index).ship_method_code    := itrip.ship_method_code;
    x_plan_trips(l_new_index).route_id            := itrip.route_id;
    x_plan_trips(l_new_index).routing_instructions := itrip.routing_instructions;
    x_plan_trips(l_new_index).service_level       := itrip.service_level;
    x_plan_trips(l_new_index).mode_of_transport   := itrip.mode_of_transport;
    x_plan_trips(l_new_index).freight_terms_code  := itrip.freight_terms_code;
    x_plan_trips(l_new_index).seal_code           := itrip.seal_code;
    x_plan_trips(l_new_index).shipments_type_flag := itrip.shipments_type_flag;
    x_plan_trips(l_new_index).consolidation_allowed := itrip.consolidation_allowed;
    x_plan_trips(l_new_index).schedule_id         := itrip.schedule_id;
    x_plan_trips(l_new_index).route_lane_id       := itrip.route_lane_id;
    x_plan_trips(l_new_index).lane_id             := itrip.lane_id;
    x_plan_trips(l_new_index).booking_number      := itrip.booking_number;
    x_plan_trips(l_new_index).vessel              := itrip.vessel;
    x_plan_trips(l_new_index).voyage_number       := itrip.voyage_number;
    x_plan_trips(l_new_index).port_of_loading     := itrip.port_of_loading;
    x_plan_trips(l_new_index).port_of_discharge   := itrip.port_of_discharge;
    x_plan_trips(l_new_index).carrier_contact_id  := itrip.carrier_contact_id;
    x_plan_trips(l_new_index).shipper_wait_time   := itrip.shipper_wait_time;
    x_plan_trips(l_new_index).wait_time_uom       := itrip.wait_time_uom;
    x_plan_trips(l_new_index).carrier_response    := itrip.carrier_response;
    x_plan_trips(l_new_index).operator            := itrip.operator;
    x_plan_trips(l_new_index).stop_base_index     := x_plan_stops.COUNT + 1;
    x_plan_trips(l_new_index).linked_stop_count   := 0;

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,
                         'itrip.lane_id: ',
                         itrip.lane_id);
        WSH_DEBUG_SV.log(l_module_name,
                         'x_plan_trips(l_new_index).lane_id: ',
                         x_plan_trips(l_new_index).lane_id);
    END IF;

    IF     itrip.wsh_ignore_for_planning = 'Y'
       OR  itrip.wsh_status_code IN ('IT', 'CL') THEN

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,
                         'itrip.wsh_ignore_for_planning: ',
                         itrip.wsh_ignore_for_planning);
        WSH_DEBUG_SV.log(l_module_name,
                         'itrip.wsh_status_code: ',
                         itrip.wsh_status_code);
      END IF;

      -- create a new trip if it is ignored or no longer eligible.
      x_plan_trips(l_new_index).trip_id          := NULL;
      x_plan_trips(l_new_index).wsh_planned_flag := NULL;
    ELSIF    itrip.wsh_planned_flag = 'N'
         AND (itrip.wsh_lane_id IS NOT NULL)
         AND (
                  (NVL(itrip.wsh_carrier_id, FND_API.G_MISS_NUM)
                   <> NVL(itrip.carrier_id, FND_API.G_MISS_NUM))
               OR
                  (NVL(itrip.wsh_mode_of_transport, FND_API.G_MISS_CHAR)
                   <> NVL(itrip.mode_of_transport, FND_API.G_MISS_CHAR))
               OR
                  (NVL(itrip.wsh_service_level, FND_API.G_MISS_CHAR)
                   <> NVL(itrip.service_level, FND_API.G_MISS_CHAR))
               OR
                  (itrip.wsh_lane_id <> NVL(itrip.lane_id, FND_API.G_MISS_NUM))
              )  THEN
      -- bug 3295628: FTE does not allow existing trip's ship method components
      --  to be changed if the trip has a lane.
      --  In this case, we should create a new trip
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,
                         'not mapping trip because of lane/ship method changes: ',
                         itrip.trip_id);
      END IF;

      x_plan_trips(l_new_index).trip_id          := NULL;
      x_plan_trips(l_new_index).wsh_planned_flag := NULL;
    ELSE
      -- fail plan if the firmed trip's attributes do not match the plan trip's.
      -- Bug 3507047: Allow the lane_id to be updated on a firmed trip
      -- without failing the plan.
      IF     itrip.wsh_planned_flag IN ('Y', 'F')
         AND (
                  (NVL(itrip.wsh_carrier_id, FND_API.G_MISS_NUM)
                   <> NVL(itrip.carrier_id, FND_API.G_MISS_NUM))
               OR
                  (NVL(itrip.wsh_mode_of_transport, FND_API.G_MISS_CHAR)
                   <> NVL(itrip.mode_of_transport, FND_API.G_MISS_CHAR))
               OR
                  (NVL(itrip.wsh_service_level, FND_API.G_MISS_CHAR)
                   <> NVL(itrip.service_level, FND_API.G_MISS_CHAR))
               OR
                  (NVL(itrip.wsh_vehicle_org_id, FND_API.G_MISS_NUM)
                   <> NVL(itrip.vehicle_organization_id, FND_API.G_MISS_NUM))
               OR
                  (NVL(itrip.wsh_vehicle_item_id, FND_API.G_MISS_NUM)
                   <> NVL(itrip.vehicle_item_id, FND_API.G_MISS_NUM))
             ) THEN
        stamp_interface_error(
                  p_group_id            => x_context.group_id,
                  p_entity_table_name   => 'WSH_TRIPS_INTERFACE',
                  p_entity_interface_id => itrip.trip_interface_id,
                  p_message_name        => 'WSH_TP_F_TRIP_DIFF_ATTR',
                  p_token_1_name        => 'TRIP_NAME',
                  p_token_1_value       => WSH_TRIPS_PVT.get_name(x_plan_trips(l_new_index).trip_id),
                  x_errors_tab          => x_errors_tab,
                  x_return_status       => l_return_status);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'firmed trip not matched: x_return_status', x_return_status);
          WSH_DEBUG_SV.log(l_module_name, 'trip_interface_id', itrip.trip_interface_id);
          WSH_DEBUG_SV.log(l_module_name, 'trip_id', itrip.trip_id);
          WSH_DEBUG_SV.log(l_module_name, 'wsh_carrier_id', itrip.wsh_carrier_id);
          WSH_DEBUG_SV.log(l_module_name, 'wsh_mode_of_transport', itrip.wsh_mode_of_transport);
          WSH_DEBUG_SV.log(l_module_name, 'wsh_service_level', itrip.wsh_service_level);
          WSH_DEBUG_SV.log(l_module_name, 'wsh_vehicle_org_id', itrip.wsh_vehicle_org_id);
          WSH_DEBUG_SV.log(l_module_name, 'wsh_vehicle_item_id', itrip.wsh_vehicle_item_id);
          WSH_DEBUG_SV.log(l_module_name, 'wsh_lane_id', itrip.wsh_lane_id);
          WSH_DEBUG_SV.log(l_module_name, 'carrier_id', itrip.carrier_id);
          WSH_DEBUG_SV.log(l_module_name, 'mode_of_transport', itrip.mode_of_transport);
          WSH_DEBUG_SV.log(l_module_name, 'service_level', itrip.service_level);
          WSH_DEBUG_SV.log(l_module_name, 'vehicle_organization_id', itrip.vehicle_organization_id);
          WSH_DEBUG_SV.log(l_module_name, 'vehicle_item_id', itrip.vehicle_item_id);
          WSH_DEBUG_SV.log(l_module_name, 'lane_id', itrip.lane_id);
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      END IF;
    END IF;

    IF x_plan_trips(l_new_index).trip_id IS NOT NULL THEN
      -- lock trip
      BEGIN
        wsh_trips_pvt.lock_trip_no_compare(
              p_trip_id => x_plan_trips(l_new_index).trip_id);
      EXCEPTION
          WHEN OTHERS THEN
            stamp_interface_error(
                  p_group_id            => x_context.group_id,
                  p_entity_table_name   => 'WSH_TRIPS_INTERFACE',
                  p_entity_interface_id => itrip.trip_interface_id,
                  p_message_name        => 'WSH_TP_F_NO_LOCK_TRIP',
                  p_token_1_name        => 'TRIP_NAME',
                  p_token_1_value       => WSH_TRIPS_PVT.get_name(x_plan_trips(l_new_index).trip_id),
                  x_errors_tab          => x_errors_tab,
                  x_return_status       => l_return_status);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'trip not locked: x_return_status', x_return_status);
              WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            RETURN;
      END;

    END IF;

    -- TP always releases ship method components
    -- They need to be validated and ship_method_code will be populated.
    DECLARE
      l_ship_method_name FND_LOOKUP_VALUES_VL.meaning%TYPE;
      l_carrier_name     PO_VENDORS.VENDOR_NAME%TYPE;
    BEGIN -- validate freight carrier

      -- TP must pass valid freight carrier

      WSH_UTIL_VALIDATE.Validate_Freight_carrier(
            p_ship_method_name  => l_ship_method_name,
            x_ship_method_code  => x_plan_trips(l_new_index).ship_method_code,
            p_carrier_name      => l_carrier_name,
            x_carrier_id        => x_plan_trips(l_new_index).carrier_id,
            x_service_level     => x_plan_trips(l_new_index).service_level,
            x_mode_of_transport => x_plan_trips(l_new_index).mode_of_transport,
            p_entity_type       => 'TRIP',
            p_entity_id         => x_plan_trips(l_new_index).trip_id,
            x_return_status     => l_return_status,
            p_caller            => 'WSH_TP_RELEASE');


      -- warning means something could not be looked up even if some values are valid.
      IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_WARNING,
                             WSH_UTIL_CORE.G_RET_STS_ERROR,
                             WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
            stamp_interface_error(
                  p_group_id            => x_context.group_id,
                  p_entity_table_name   => 'WSH_TRIPS_INTERFACE',
                  p_entity_interface_id => itrip.trip_interface_id,
                  p_message_name        => 'WSH_TP_F_INVALID_FC',
                  p_token_1_name        => 'PLAN_TRIP_NUM',
                  p_token_1_value       => itrip.tp_trip_number,
                  p_token_2_name        => 'CARRIER',
                  p_token_2_value       => itrip.carrier_id,  --!!! lookup
                  p_token_3_name        => 'MODE_OF_TRANSPORT',
                  p_token_3_value       => itrip.mode_of_transport, --!!! lookup
                  p_token_4_name        => 'SERVICE_LEVEL',
                  p_token_4_value       => itrip.service_level, --!!! lookup
                  x_errors_tab          => x_errors_tab,
                  x_return_status       => l_return_status);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'invalid freight carrier: x_return_status', x_return_status);
              WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            RETURN;
          END IF;
    END; -- validate freight carrier

    l_stop_index := x_plan_trips(l_new_index).stop_base_index;

    FOR istop IN c_tp_interface_stops(p_trip_interface_id => itrip.trip_interface_id)  LOOP  --[

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,
                         'istop looping: stop_interface_id',
                         istop.stop_interface_id);
        WSH_DEBUG_SV.log(l_module_name, 'istop.stop_id', istop.stop_id);
      END IF;

      x_plan_stops(l_stop_index).stop_interface_id      := istop.stop_interface_id;
      x_plan_stops(l_stop_index).stop_id                := NULL;  -- to be updated
      x_plan_stops(l_stop_index).tp_stop_id             := istop.tp_stop_id;
      x_plan_stops(l_stop_index).trip_index             := l_new_index;
      x_plan_stops(l_stop_index).stop_location_id       := istop.stop_location_id;
      x_plan_stops(l_stop_index).stop_sequence_number   := istop.stop_sequence_number;
      x_plan_stops(l_stop_index).planned_arrival_date   := istop.planned_arrival_date;
      x_plan_stops(l_stop_index).planned_departure_date := istop.planned_departure_date;
      x_plan_stops(l_stop_index).departure_gross_weight := istop.departure_gross_weight;
      x_plan_stops(l_stop_index).departure_net_weight   := istop.departure_net_weight;
      x_plan_stops(l_stop_index).weight_uom_code        := istop.weight_uom_code;
      x_plan_stops(l_stop_index).departure_volume       := istop.departure_volume;
      x_plan_stops(l_stop_index).volume_uom_code        := istop.volume_uom_code;
      x_plan_stops(l_stop_index).departure_seal_code    := istop.departure_seal_code;
      x_plan_stops(l_stop_index).departure_fill_percent := istop.departure_fill_percent;
      x_plan_stops(l_stop_index).wkend_layover_stops    := istop.wkend_layover_stops;
      x_plan_stops(l_stop_index).wkday_layover_stops    := istop.wkday_layover_stops;
      x_plan_stops(l_stop_index).shipments_type_flag    := istop.shipments_type_flag;
      x_plan_stops(l_stop_index).wv_frozen_flag         := NULL;  -- to be updated, WV changes
      x_plan_stops(l_stop_index).internal_do_count      := 0;
      x_plan_stops(l_stop_index).external_pd_count      := 0;

      IF x_plan_trips(l_new_index).trip_id IS NOT NULL THEN --(
        -- since this trip is mapped, try to map the stop.

        OPEN c_map_stop(p_trip_id                => x_plan_trips(l_new_index).trip_id,
                        p_stop_location_id       => istop.stop_location_id,
                        p_planned_arrival_date   => istop.planned_arrival_date,
                        p_planned_departure_date => istop.planned_departure_date);
        FETCH c_map_stop INTO l_map_stop_rec;
        l_match_found := c_map_stop%FOUND;
        CLOSE c_map_stop;

        IF l_match_found THEN  --{

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'matched stop_id', l_map_stop_rec.stop_id);
          END IF;

          -- wsh trip has a stop mapped.
          x_plan_stops(l_stop_index).stop_id := l_map_stop_rec.stop_id;
          x_plan_stops(l_stop_index).wv_frozen_flag := l_map_stop_rec.wv_frozen_flag; -- WV changes

          -- lock stop
          BEGIN
            wsh_trip_stops_pvt.lock_trip_stop_no_compare(
               p_stop_id => x_plan_stops(l_stop_index).stop_id);
          EXCEPTION
              WHEN OTHERS THEN
                stamp_interface_error(
                      p_group_id            => x_context.group_id,
                      p_entity_table_name   => 'WSH_TRIP_STOPS_INTERFACE',
                      p_entity_interface_id => istop.stop_interface_id,
                      p_message_name        => 'WSH_TP_F_NO_LOCK_STOP',
                      p_token_1_name        => 'TRIP_NAME',
                      p_token_1_value       => WSH_TRIPS_PVT.get_name(x_plan_trips(l_new_index).trip_id),
                      x_errors_tab          => x_errors_tab,
                      x_return_status       => l_return_status);
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name, 'stop not locked: x_return_status', x_return_status);
                  WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                RETURN;
          END;

        ELSE

          x_plan_stops(l_stop_index).stop_id := NULL;
          -- if wsh trip is firmed and plan does not find matching stop, fail plan
          IF itrip.wsh_planned_flag IN ('Y', 'F')  THEN  --[
            stamp_interface_error(
                 p_group_id            => x_context.group_id,
                 p_entity_table_name   => 'WSH_TRIPS_INTERFACE',
                 p_entity_interface_id => x_plan_trips(l_new_index).trip_interface_id,
                 p_message_name        => 'WSH_TP_F_TRIP_FIRM_NO_STOP',
                 p_token_1_name        => 'TRIP_NAME',
                 p_token_1_value       => WSH_TRIPS_PVT.get_name(x_plan_trips(l_new_index).trip_id),
                 p_token_2_name        => 'PLAN_TRIP_NUM',
                 p_token_2_value       => x_plan_trips(l_new_index).tp_trip_number,
                 x_errors_tab          => x_errors_tab,
                 x_return_status       => l_return_status);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'stop not mapped: x_return_status', x_return_status);
              WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            RETURN;
          END IF; --]

        END IF; --}

      END IF; --)

      l_stop_index := l_stop_index + 1;

    END LOOP;  --] istop

  END LOOP;  --} itrip


  -- 5. Map and lock legs; reuse existing trips and stops whenever possible

  -- Bug 3555487 initialize message stack for each major action point.
  FND_MSG_PUB.initialize;

  FOR l_plan_del_index IN x_plan_deliveries.FIRST .. x_plan_deliveries.LAST LOOP

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'looping l_plan_del_index: ', l_plan_del_index);
    END IF;

    -- take snapshot of legs in shipping datamodel
    l_snapshot_leg_ids.DELETE;
    l_snapshot_trip_ids.DELETE;
    l_snapshot_trip_plan_flags.DELETE;
    l_snapshot_pu_stop_ids.DELETE;
    l_snapshot_pu_seq_nums.DELETE;
    l_snapshot_pu_loc_ids.DELETE;
    l_snapshot_pu_arrive_dates.DELETE;
    l_snapshot_pu_depart_dates.DELETE;
    l_snapshot_pu_wv_flag.DELETE;
    l_snapshot_do_stop_ids.DELETE;
    l_snapshot_do_phys_stop_ids.DELETE;
    l_snapshot_do_seq_nums.DELETE;
    l_snapshot_do_loc_ids.DELETE;
    l_snapshot_do_arrive_dates.DELETE;
    l_snapshot_do_depart_dates.DELETE;
    l_snapshot_do_wv_flag.DELETE;

    l_snapshot_carrier_ids.DELETE;
    l_snapshot_modes.DELETE;
    l_snapshot_service_levels.DELETE;
    l_snapshot_veh_org_ids.DELETE;
    l_snapshot_veh_item_ids.DELETE;
    l_snapshot_lane_ids.DELETE;


    IF x_plan_deliveries(l_plan_del_index).delivery_id IS NOT NULL THEN

      -- lock legs in this delivery
      BEGIN
        wsh_delivery_legs_pvt.lock_dlvy_leg_no_compare(
           p_delivery_id => x_plan_deliveries(l_plan_del_index).delivery_id);
      EXCEPTION
          WHEN OTHERS THEN
            stamp_interface_error(
                  p_group_id            => x_context.group_id,
                  p_entity_table_name   => 'WSH_NEW_DEL_INTERFACE',
                  p_entity_interface_id => x_plan_deliveries(l_plan_del_index).del_interface_id,
                  p_message_name        => 'WSH_TP_F_NO_LOCK_LEGS',
                  p_token_1_name        => 'DELIVERY_NAME',
                  p_token_1_value       =>
                       WSH_NEW_DELIVERIES_PVT.get_name(x_plan_deliveries(l_plan_del_index).delivery_id),
                  x_errors_tab          => x_errors_tab,
                  x_return_status       => l_return_status);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'stop not locked: x_return_status', x_return_status);
              WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            RETURN;
      END;

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'snapshot legs for delivery_id: ',
                         x_plan_deliveries(l_plan_del_index).delivery_id);
      END IF;

      OPEN  c_snapshot_legs(p_delivery_id => x_plan_deliveries(l_plan_del_index).delivery_id);
      FETCH c_snapshot_legs BULK COLLECT INTO
               l_snapshot_leg_ids,
               l_snapshot_trip_ids,
               l_snapshot_trip_plan_flags,
               l_snapshot_carrier_ids,
               l_snapshot_modes,
               l_snapshot_service_levels,
               l_snapshot_veh_org_ids,
               l_snapshot_veh_item_ids,
               l_snapshot_lane_ids,
               l_snapshot_pu_stop_ids,
               l_snapshot_pu_loc_ids,
               l_snapshot_pu_arrive_dates,
               l_snapshot_pu_depart_dates,
               l_snapshot_pu_wv_flag,
               l_snapshot_do_stop_ids,
               l_snapshot_do_phys_stop_ids,
               l_snapshot_do_loc_ids,
               l_snapshot_do_arrive_dates,
               l_snapshot_do_depart_dates,
               l_snapshot_do_wv_flag;
      CLOSE c_snapshot_legs;


      -- look up physical stop dates to match the plan.
      DECLARE
        i NUMBER;
      BEGIN
        FOR i IN 1..l_snapshot_do_phys_stop_ids.COUNT LOOP
          IF l_snapshot_do_phys_stop_ids(i) IS NOT NULL THEN
             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name, 'mapping physical stop id',
                               l_snapshot_do_phys_stop_ids(i));
             END IF;

             OPEN c_physical_stop(l_snapshot_do_phys_stop_ids(i));
             FETCH c_physical_stop INTO
                   l_snapshot_do_arrive_dates(i),
                   l_snapshot_do_arrive_dates(i),
                   l_snapshot_do_wv_flag(i);
             CLOSE c_physical_stop;
          END IF;
        END LOOP;
      END;

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'count of existing legs: ',
                         l_snapshot_leg_ids.COUNT);
      END IF;

    END IF;

    -- build the plan list of legs

    l_new_index := x_plan_legs.COUNT;
    x_plan_deliveries(l_plan_del_index).leg_base_index := l_new_index;

    l_phys_ult_do_mapped := FALSE;

    FOR ileg IN c_tp_interface_legs(
                     p_delivery_interface_id => x_plan_deliveries(l_plan_del_index).del_interface_id)
    LOOP --[ ileg

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'ileg looping: delivery_leg_interface_id',
                         ileg.delivery_leg_interface_id);
      END IF;

      l_new_index := l_new_index + 1;
      x_plan_legs(l_new_index).leg_interface_id   := ileg.delivery_leg_interface_id;
      x_plan_legs(l_new_index).delivery_index     := l_plan_del_index;

      x_plan_legs(l_new_index).delivery_leg_id    := NULL;
      x_plan_legs(l_new_index).trip_index         := NULL;
      x_plan_legs(l_new_index).pickup_stop_index  := NULL;
      x_plan_legs(l_new_index).dropoff_stop_index := NULL;

      DECLARE
        l_trip_index         NUMBER;
        l_pu_stop_index      NUMBER;
        l_do_stop_index      NUMBER;
      BEGIN

        l_phys_ult_do_mapped := FALSE;
        l_last_do_stop_index := NULL;

        -- find plan trip
        l_trip_index := x_plan_trips.FIRST;
        WHILE x_plan_trips(l_trip_index).trip_interface_id <> ileg.trip_interface_id LOOP
          l_trip_index := x_plan_trips.NEXT(l_trip_index);
        END LOOP;

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'l_trip_index', l_trip_index);
        END IF;

        -- find plan pick up stop
        l_pu_stop_index := x_plan_trips(l_trip_index).stop_base_index;
        WHILE x_plan_stops(l_pu_stop_index).stop_interface_id <> ileg.pick_up_stop_interface_id LOOP
          l_pu_stop_index := x_plan_stops.NEXT(l_pu_stop_index);
        END LOOP;

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'l_pu_stop_index: ', l_pu_stop_index);
        END IF;

        -- track external pick ups
        IF x_plan_stops(l_pu_stop_index).stop_location_id
              = x_plan_deliveries(l_plan_del_index).initial_pickup_location_id  THEN
          -- external pick-ups can trigger linking
          IF x_plan_stops(l_pu_stop_index).external_pd_count = 0
             AND x_plan_stops(l_pu_stop_index).internal_do_count > 0 THEN
             IF x_plan_trips(l_trip_index).linked_stop_count = 0 THEN
               x_context.linked_trip_count := x_context.linked_trip_count + 1;
             END IF;
             x_plan_trips(l_trip_index).linked_stop_count := x_plan_trips(l_trip_index).linked_stop_count + 1;
          END IF;
          x_plan_stops(l_pu_stop_index).external_pd_count :=
                x_plan_stops(l_pu_stop_index).external_pd_count + 1;
        END IF;

        -- find plan drop off stop
        l_do_stop_index := x_plan_stops.NEXT(l_pu_stop_index);
        WHILE x_plan_stops(l_do_stop_index).stop_interface_id <> ileg.drop_off_stop_interface_id LOOP
          l_do_stop_index := x_plan_stops.NEXT(l_do_stop_index);
        END LOOP;

        -- since legs are sequenced (by TP), assume that the last leg will
        -- have the ultimate drop off.
        l_last_do_stop_index := l_do_stop_index;

        -- track internal drop offs
        IF x_plan_stops(l_do_stop_index).stop_location_id
              = x_plan_deliveries(l_plan_del_index).physical_ultimate_do_loc_id  THEN
          -- internal drop-offs can trigger linking
          l_phys_ult_do_mapped := TRUE;
          IF x_plan_stops(l_do_stop_index).internal_do_count = 0
             AND x_plan_stops(l_do_stop_index).external_pd_count > 0 THEN
             IF x_plan_trips(l_trip_index).linked_stop_count = 0 THEN
               x_context.linked_trip_count := x_context.linked_trip_count + 1;
             END IF;
             x_plan_trips(l_trip_index).linked_stop_count := x_plan_trips(l_trip_index).linked_stop_count + 1;
          END IF;
          x_plan_stops(l_do_stop_index).internal_do_count :=
                x_plan_stops(l_do_stop_index).internal_do_count + 1;
        ELSE
          -- external drop-offs can trigger linking
          IF x_plan_stops(l_do_stop_index).external_pd_count = 0
             AND x_plan_stops(l_do_stop_index).internal_do_count > 0 THEN
             IF x_plan_trips(l_trip_index).linked_stop_count = 0 THEN
               x_context.linked_trip_count := x_context.linked_trip_count + 1;
             END IF;
             x_plan_trips(l_trip_index).linked_stop_count := x_plan_trips(l_trip_index).linked_stop_count + 1;
          END IF;
          x_plan_stops(l_do_stop_index).external_pd_count :=
                x_plan_stops(l_do_stop_index).external_pd_count + 1;
        END IF;


        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'l_do_stop_index: ', l_do_stop_index);
        END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'l_pu_stop_index', l_pu_stop_index);
          WSH_DEBUG_SV.log(l_module_name, 'l_do_stop_index', l_do_stop_index);
        END IF;

        x_plan_legs(l_new_index).trip_index         := l_trip_index;
        x_plan_legs(l_new_index).pickup_stop_index  := l_pu_stop_index;
        x_plan_legs(l_new_index).dropoff_stop_index := l_do_stop_index;

        -- try to match interface leg with snapshot leg
        IF l_snapshot_leg_ids.COUNT > 0 THEN

          l_used_index := l_snapshot_leg_ids.FIRST;
          WHILE l_used_index IS NOT NULL  LOOP  --{ looking for a snapshot leg to match this interface leg.

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'snapshot leg: looping l_used_index', l_used_index);
            END IF;

            IF     x_plan_trips(l_trip_index).trip_id    = l_snapshot_trip_ids(l_used_index)
               AND x_plan_stops(l_pu_stop_index).stop_id = l_snapshot_pu_stop_ids(l_used_index)
               AND x_plan_stops(l_do_stop_index).stop_id = l_snapshot_do_stop_ids(l_used_index)  THEN
              -- when the existing IDs match, keep leg_id
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'existing leg is mapped: l_used_index: ', l_used_index);
              END IF;
              x_plan_legs(l_new_index).delivery_leg_id := l_snapshot_leg_ids(l_used_index);

              EXIT;
            ELSIF  (x_plan_trips(l_trip_index).trip_id IS NULL)
                  AND
                  (    x_plan_stops(l_pu_stop_index).stop_location_id =
                          l_snapshot_pu_loc_ids(l_used_index)
                   AND x_plan_stops(l_pu_stop_index).planned_arrival_date =
                          l_snapshot_pu_arrive_dates(l_used_index)
                   AND x_plan_stops(l_pu_stop_index).planned_departure_date =
                          l_snapshot_pu_depart_dates(l_used_index))
                  AND
                  (    x_plan_stops(l_do_stop_index).stop_location_id =
                          l_snapshot_do_loc_ids(l_used_index)
                   AND x_plan_stops(l_do_stop_index).planned_arrival_date =
                          l_snapshot_do_arrive_dates(l_used_index)
                   AND x_plan_stops(l_do_stop_index).planned_departure_date =
                          l_snapshot_do_depart_dates(l_used_index))
                  AND
                   (
                       (
                        -- if trip is not firmed, use it unless it has a lane
                        --    and ship method components will be changed (bug 3295628).
                             (l_snapshot_trip_plan_flags(l_used_index) = 'N')
                        AND  (   (l_snapshot_lane_ids(l_used_index) IS NULL)
                              OR (
                                  -- if trip has lane, lane and ship method must match.
                                      (NVL(l_snapshot_lane_ids(l_used_index), FND_API.G_MISS_NUM)
                                          = NVL(x_plan_trips(l_trip_index).lane_id,
                                                FND_API.G_MISS_NUM))
                                  AND (NVL(l_snapshot_carrier_ids(l_used_index),
                                             FND_API.G_MISS_NUM)
                                        = NVL(x_plan_trips(l_trip_index).carrier_id,
                                               FND_API.G_MISS_NUM))
                                  AND (NVL(l_snapshot_modes(l_used_index),
                                           FND_API.G_MISS_CHAR)
                                        = NVL(x_plan_trips(l_trip_index).mode_of_transport,
                                             FND_API.G_MISS_CHAR))
                                  AND (NVL(l_snapshot_service_levels(l_used_index),
                                           FND_API.G_MISS_CHAR)
                                        = NVL(x_plan_trips(l_trip_index).service_level,
                                              FND_API.G_MISS_CHAR))
                                 )
                             )
                       )
                   OR  (
                        -- if trip is firmed, trip attributes must match the plan's attributes
                             (NVL(l_snapshot_carrier_ids(l_used_index),
                                  FND_API.G_MISS_NUM)
                              = NVL(x_plan_trips(l_trip_index).carrier_id,
                                    FND_API.G_MISS_NUM))
                         AND (NVL(l_snapshot_modes(l_used_index),
                                  FND_API.G_MISS_CHAR)
                              = NVL(x_plan_trips(l_trip_index).mode_of_transport,
                                    FND_API.G_MISS_CHAR))
                         AND (NVL(l_snapshot_service_levels(l_used_index),
                                  FND_API.G_MISS_CHAR)
                              = NVL(x_plan_trips(l_trip_index).service_level,
                                    FND_API.G_MISS_CHAR))
                         AND (NVL(l_snapshot_veh_org_ids(l_used_index),
                                  FND_API.G_MISS_NUM)
                              = NVL(x_plan_trips(l_trip_index).vehicle_organization_id,
                                    FND_API.G_MISS_NUM))
                         AND (NVL(l_snapshot_veh_item_ids(l_used_index),
                                  FND_API.G_MISS_NUM)
                              = NVL(x_plan_trips(l_trip_index).vehicle_item_id,
                                    FND_API.G_MISS_NUM))
                         AND (NVL(l_snapshot_lane_ids(l_used_index),
                                  FND_API.G_MISS_NUM)
                              = NVL(x_plan_trips(l_trip_index).lane_id,
                                    FND_API.G_MISS_NUM))
                       )
                   )
                 THEN
              -- stop information match and we can map these plan records to existing trip/stops
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'mapping existing leg and trip: l_used_index: ', l_used_index);
              END IF;
              x_plan_trips(l_trip_index).trip_id       := l_snapshot_trip_ids(l_used_index);
              x_plan_trips(l_trip_index).wsh_planned_flag := l_snapshot_trip_plan_flags(l_used_index);
              x_plan_stops(l_pu_stop_index).stop_id    := l_snapshot_pu_stop_ids(l_used_index);
              x_plan_stops(l_pu_stop_index).wv_frozen_flag := l_snapshot_pu_wv_flag(l_used_index);
              x_plan_stops(l_do_stop_index).stop_id    := l_snapshot_do_stop_ids(l_used_index);
              x_plan_stops(l_do_stop_index).wv_frozen_flag := l_snapshot_do_wv_flag(l_used_index);
              x_plan_legs(l_new_index).delivery_leg_id := l_snapshot_leg_ids(l_used_index);

              -- lock the newly mapped trip and map the plan stops to the trip's existing stops.
              BEGIN
                wsh_trips_pvt.lock_trip_no_compare(
                  p_trip_id => x_plan_trips(l_trip_index).trip_id);
                EXCEPTION
                WHEN OTHERS THEN
                  stamp_interface_error(
                     p_group_id            => x_context.group_id,
                     p_entity_table_name   => 'WSH_TRIPS_INTERFACE',
                     p_entity_interface_id => x_plan_trips(l_trip_index).trip_interface_id,
                     p_message_name        => 'WSH_TP_F_NO_LOCK_TRIP',
                     p_token_1_name        => 'TRIP_NAME',
                     p_token_1_value       => WSH_TRIPS_PVT.get_name(x_plan_trips(l_trip_index).trip_id),
                     x_errors_tab          => x_errors_tab,
                     x_return_status       => l_return_status);
                  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name, 'leg: trip not locked: x_return_status', x_return_status);
                    WSH_DEBUG_SV.pop(l_module_name);
                  END IF;
                  RETURN;
              END;

              l_stop_index := x_plan_trips(l_trip_index).stop_base_index;

              WHILE l_stop_index IS NOT NULL LOOP --(

                IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name, 'looping to map stops', l_stop_index);
                END IF;

                OPEN c_map_stop(p_trip_id                => x_plan_trips(l_trip_index).trip_id,
                                p_stop_location_id       => x_plan_stops(l_stop_index).stop_location_id,
                                p_planned_arrival_date   => x_plan_stops(l_stop_index).planned_arrival_date,
                                p_planned_departure_date => x_plan_stops(l_stop_index).planned_departure_date);
                FETCH c_map_stop INTO l_map_stop_rec;
                l_match_found := c_map_stop%FOUND;
                CLOSE c_map_stop;

                IF l_match_found THEN  --{

                  IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name, 'plan stop matches shipping stop', l_map_stop_rec.stop_id);
                  END IF;

                  -- wsh trip has a stop mapped.
                  x_plan_stops(l_stop_index).stop_id := l_map_stop_rec.stop_id;

                  -- lock stop
                  BEGIN
                    wsh_trip_stops_pvt.lock_trip_stop_no_compare(
                         p_stop_id => x_plan_stops(l_stop_index).stop_id);
                  EXCEPTION
                    WHEN OTHERS THEN
                      stamp_interface_error(
                        p_group_id            => x_context.group_id,
                        p_entity_table_name   => 'WSH_TRIP_STOPS_INTERFACE',
                        p_entity_interface_id => x_plan_stops(l_stop_index).stop_interface_id,
                        p_message_name        => 'WSH_TP_F_NO_LOCK_STOP',
                        p_token_1_name        => 'TRIP_NAME',
                        p_token_1_value       => WSH_TRIPS_PVT.get_name(x_plan_trips(l_trip_index).trip_id),
                        p_token_2_name        => 'STOP_SEQUENCE',
                        p_token_2_value       => x_plan_stops(l_stop_index).stop_sequence_number,
                        x_errors_tab          => x_errors_tab,
                        x_return_status       => l_return_status);
                      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                      IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name, 'leg: stop not locked: x_return_status', x_return_status);
                        WSH_DEBUG_SV.pop(l_module_name);
                      END IF;
                      RETURN;
                  END;

                ELSE

                  -- plan does not find the matching stop or the trip does not match:
                  -- if wsh trip is routing firmed, this trip cannot be mapped.
                  -- if wsh trip is routing and contents firmed, fail plan
                  IF x_plan_trips(l_trip_index).wsh_planned_flag = 'Y'  THEN  --[
                     -- if flag = 'Y', clear the plan trip and stops' shipping IDs
                     -- clear l_used_index and exit.
                     IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name, 'stop not matched on routing-firmed trip; undo the mapping');
                     END IF;
                     x_plan_trips(l_trip_index).trip_id := NULL;
                     x_plan_trips(l_trip_index).wsh_planned_flag := NULL;

                     l_stop_index := x_plan_trips(l_trip_index).stop_base_index;
                     WHILE l_stop_index IS NOT NULL LOOP
                        x_plan_stops(l_stop_index).stop_id := NULL;
                        l_stop_index := x_plan_stops.NEXT(l_stop_index);
                        IF l_stop_index IS NOT NULL THEN
                           IF x_plan_stops(l_stop_index).trip_index <> l_trip_index THEN
                             l_stop_index := NULL;
                           END IF;
                        END IF;
                     END LOOP;
                     EXIT;

                  ELSIF (x_plan_trips(l_trip_index).wsh_planned_flag = 'F')  THEN  --[
                      stamp_interface_error(
                        p_group_id            => x_context.group_id,
                        p_entity_table_name   => 'WSH_TRIPS_INTERFACE',
                        p_entity_interface_id => x_plan_trips(l_trip_index).trip_interface_id,
                        p_message_name        => 'WSH_TP_F_TRIP_FIRM_NO_STOP',
                        p_token_1_name        => 'TRIP_NAME',
                        p_token_1_value       => WSH_TRIPS_PVT.get_name(x_plan_trips(l_trip_index).trip_id),
                        x_errors_tab          => x_errors_tab,
                        x_return_status       => l_return_status);
                        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                      IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name, 'leg: stop not mapped: x_return_status', x_return_status);
                        WSH_DEBUG_SV.pop(l_module_name);
                      END IF;
                      RETURN;
                  END IF; --]

                END IF; --}

                l_stop_index := x_plan_stops.NEXT(l_stop_index);
                IF l_stop_index IS NOT NULL THEN
                  -- clear index if we finished going through the sublist of stops for this trip.
                  IF x_plan_stops(l_stop_index).trip_index <> l_trip_index  THEN
                    l_stop_index := NULL;
                  END IF;
                END IF;

              END LOOP; --)

              EXIT; -- exit when leg is mapped

            END IF;

            l_used_index := l_snapshot_leg_ids.NEXT(l_used_index);
          END LOOP; --}

          -- l_used_index being not null means we found a match.
          IF l_used_index IS NOT NULL THEN
            l_snapshot_leg_ids.DELETE(l_used_index);
            l_snapshot_leg_ids.DELETE(l_used_index);
            l_snapshot_trip_ids.DELETE(l_used_index);
            l_snapshot_trip_plan_flags.DELETE(l_used_index);
            l_snapshot_pu_stop_ids.DELETE(l_used_index);
            l_snapshot_pu_seq_nums.DELETE(l_used_index);
            l_snapshot_pu_loc_ids.DELETE(l_used_index);
            l_snapshot_pu_arrive_dates.DELETE(l_used_index);
            l_snapshot_pu_depart_dates.DELETE(l_used_index);
            l_snapshot_do_stop_ids.DELETE(l_used_index);
            l_snapshot_do_seq_nums.DELETE(l_used_index);
            l_snapshot_do_loc_ids.DELETE(l_used_index);
            l_snapshot_do_arrive_dates.DELETE(l_used_index);
            l_snapshot_do_depart_dates.DELETE(l_used_index);
          END IF;

        END IF;

      END;

    END LOOP; --] ileg

    -- verify the internal customer location mapping has not changed
    IF (NOT l_phys_ult_do_mapped)
       AND (x_plan_deliveries(l_plan_del_index).physical_ultimate_do_loc_id IS NOT NULL)  THEN
        stamp_interface_error(
            p_group_id            => x_context.group_id,
            p_entity_table_name   => 'WSH_NEW_DEL_INTERFACE',
            p_entity_interface_id => x_plan_deliveries(l_plan_del_index).del_interface_id,
            p_message_name        => 'WSH_TP_F_INT_LOC_CHANGED',  --!!! new message
            p_token_1_name        => 'PLAN_DEL_NUM',
            p_token_1_value       => x_plan_deliveries(l_plan_del_index).tp_delivery_number,
            p_token_2_name        => 'PHYS_LOC_CODE',
            p_token_2_value       => WSH_UTIL_CORE.Get_Location_Description(
                                       p_location_id => x_plan_stops(l_last_do_stop_index).stop_location_id,
                                       p_format      => 'NEW UI CODE'),
            p_token_3_name        => 'INT_LOC_CODE',
            p_token_3_value       => WSH_UTIL_CORE.Get_Location_Description(
                                       p_location_id => x_plan_deliveries(l_plan_del_index).ultimate_dropoff_location_id,
                                       p_format      => 'NEW UI CODE'),
            x_errors_tab          => x_errors_tab,
            x_return_status       => l_return_status);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'firmed delivery with extra leg: x_return_status', x_return_status);
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
    END IF;

    IF l_snapshot_leg_ids.COUNT > 0 THEN

      -- fail plan if delivery is routing/contents firmed
      IF x_plan_deliveries(l_plan_del_index).wsh_planned_flag = 'F'  THEN
        stamp_interface_error(
            p_group_id            => x_context.group_id,
            p_entity_table_name   => 'WSH_TRIPS_INTERFACE',
            p_entity_interface_id => x_plan_deliveries(l_plan_del_index).del_interface_id,
            p_message_name        => 'WSH_TP_F_DEL_FIRM_LEG_DIFF',
            p_token_1_name        => 'DELIVERY_NAME',
            p_token_1_value       => wsh_new_deliveries_pvt.get_name(x_plan_deliveries(l_plan_del_index).delivery_id),
            p_token_2_name        => 'PLAN_TRIP_NUM',
            p_token_2_value       => x_plan_trips(1).tp_trip_number,
            x_errors_tab          => x_errors_tab,
            x_return_status       => l_return_status);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'firmed delivery with extra leg: x_return_status', x_return_status);
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      END IF;

      -- otherwise, add these unmapped legs to x_trip_unassigns if not routing/contents firmed
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'count of legs to unassign: ',
                         l_snapshot_leg_ids.COUNT);
      END IF;


      l_used_index := l_snapshot_trip_ids.FIRST;
      WHILE l_used_index IS NOT NULL LOOP

        IF l_snapshot_trip_plan_flags(l_used_index) = 'F' THEN
          -- cannot unassign delivery from this routing/contents firmed trip
          stamp_interface_error(
              p_group_id            => x_context.group_id,
              p_entity_table_name   => 'WSH_NEW_DEL_INTERFACE',
              p_entity_interface_id => x_plan_deliveries(l_plan_del_index).del_interface_id,
              p_message_name        => 'WSH_TP_F_TRIP_FIRM_NO_UNASSIGN',
              p_token_1_name        => 'DELIVERY_NAME',
              p_token_1_value       => wsh_new_deliveries_pvt.get_name(x_plan_deliveries(l_plan_del_index).delivery_id),
              p_token_2_name        => 'PLAN_TRIP_NUM',
              p_token_2_value       => x_plan_trips(1).tp_trip_number,
              x_errors_tab          => x_errors_tab,
              x_return_status       => l_return_status);
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'delivery with extra firmed leg: x_return_status', x_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          RETURN;
        END IF;

        x_trip_unassigns( x_trip_unassigns.COUNT + 1 ).delivery_id := x_plan_deliveries(l_plan_del_index).delivery_id;
        x_trip_unassigns( x_trip_unassigns.COUNT ).organization_id := x_plan_deliveries(l_plan_del_index).organization_id;
        x_trip_unassigns( x_trip_unassigns.COUNT ).trip_id         := l_snapshot_trip_ids(l_used_index);
        x_trip_unassigns( x_trip_unassigns.COUNT ).delivery_leg_id := l_snapshot_leg_ids(l_used_index);
        x_trip_unassigns( x_trip_unassigns.COUNT ).pickup_stop_id  := l_snapshot_pu_stop_ids(l_used_index);
        x_trip_unassigns( x_trip_unassigns.COUNT ).dropoff_stop_id := l_snapshot_do_stop_ids(l_used_index);

        l_used_index := l_snapshot_trip_ids.NEXT(l_used_index);

      END LOOP;

    END IF;

  END LOOP;


  -- 6. Map and lock continuous moves (FTE), also matching their segments.

  -- Bug 3555487 initialize message stack for each major action point.
  FND_MSG_PUB.initialize;


  WSH_FTE_TP_INTEGRATION.map_moves(
           x_context                 => x_context,
           x_plan_trips              => x_plan_trips,
           x_plan_trip_moves         => x_plan_trip_moves,
           x_plan_moves              => x_plan_moves,
           x_obsoleted_trip_moves    => x_obsoleted_trip_moves,
           x_errors_tab              => x_errors_tab,
           x_return_status           => l_return_status
          );

  IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                         WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
     x_return_status := l_return_status;
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'map_moves failed: x_return_status', x_return_status);
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     RETURN;
  END IF;


  --
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TP_RELEASE.GENERATE_LOCK_CANDIDATES',
                        l_module_name);

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

    IF c_being_staged%ISOPEN THEN
      CLOSE c_being_staged;
    END IF;
    IF c_map_stop%ISOPEN THEN
      CLOSE c_map_stop;
    END IF;
    IF c_snapshot_legs%ISOPEN THEN
      CLOSE c_snapshot_legs;
    END IF;
    IF c_physical_stop%ISOPEN THEN
      CLOSE c_physical_stop;
    END IF;

END generate_lock_candidates;





--
--  Procedure:          validate_plan
--  Parameters:
--               x_context             context in this session
--               x_plan_details        list of delivery details mapped to interface lines
--               x_track_conts         list of topmost containers to track
--               x_plan_deliveries     list of deliveries mapped to interface deliveries
--               x_plan_legs           list of delivery legs mapped to interface legs
--               x_plan_stops          list of stops mapped to interface stops
--               x_plan_trips          list of trips mapped to interface trips
--               x_used_details        list of delivery details partially used by the plan
--               x_delivery_unassigns  list of delivery lines to unassign from their deliveries
--               x_trip_unassigns      list of deliveries to unassign from their trips
--               x_obsoleted_stops     list of mapped trips' stops that are not mapped in the plan
--               x_errors_tab          list of errors to insert into wsh_interface_errors at the end
--               x_return_status       return status
--
--  Description:
--               *  Perform general validation checks on the plan not
--                  covered by other APIs (resync_interface_tables,
--                  generate_lock_candidates, reconciliate_plan, and
--                  plan_cleanup); for performance reason, the validation checks are done in
--                  these other APIs as part of the code flow..
--               *  Identify shipping records that need to be unassigned or deleted
--                  to implement the plan.
--
--               1. Deliveries:
--                 *  calls match_deliveries to identify what detail needs to be unassigned
--                    from delivery
--                       + if delivery is firmed, fail if there is anything to unassign.
--               2. Lines/LPNs:
--                     call validate_wms to check WMS conditions
--                     Note: Deliveries must be validated first, as match_deliveries
--                           may update x_delivery_unassigns with LPNs
--               3. Trips:
--                 *  calls match_trips to identify deliveries to be unassigned
--                    and the stops to be deleted.
--                       + if trip is firmed, fail if there is anything to unassign or delete.
--
PROCEDURE validate_plan(
           x_context                  IN OUT NOCOPY context_rec_type,
           x_plan_details             IN OUT NOCOPY plan_detail_tab_type,
           x_track_conts              IN OUT NOCOPY track_cont_tab_type,
           x_plan_deliveries          IN OUT NOCOPY plan_delivery_tab_type,
           x_plan_legs                IN OUT NOCOPY plan_leg_tab_type,
           x_plan_stops               IN OUT NOCOPY plan_stop_tab_type,
           x_plan_trips               IN OUT NOCOPY plan_trip_tab_type,
           x_used_details             IN OUT NOCOPY used_details_tab_type,
           x_delivery_unassigns       IN OUT NOCOPY delivery_unassign_tab_type,
           x_trip_unassigns           IN OUT NOCOPY trip_unassign_tab_type,
           x_obsoleted_stops          IN OUT NOCOPY obsoleted_stop_tab_type,
           x_errors_tab               IN OUT NOCOPY interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          )
IS
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_PLAN';
  --
  l_debug_on BOOLEAN;

  l_return_status VARCHAR2(1);

  l_del_index NUMBER;
  l_indexes   WSH_UTIL_CORE.ID_TAB_TYPE;

  l_discard_rs    VARCHAR2(1);
  l_msg_data      VARCHAR2(2000);
  l_msg_count     NUMBER;

BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;
  --
  --

  --  1. Deliveries:
  --    *  calls match_deliveries to identify what detail needs to be unassigned
  --       from delivery
  --          + if delivery is firmed, fail if there is anything to unassign.

  -- Bug 3555487 initialize message stack for each major action point.
  FND_MSG_PUB.initialize;

  match_deliveries(
           x_context             => x_context,
           x_plan_details        => x_plan_details,
           x_track_conts         => x_track_conts,
           x_plan_deliveries     => x_plan_deliveries,
           x_used_details        => x_used_details,
           x_delivery_unassigns  => x_delivery_unassigns,
           x_errors_tab          => x_errors_tab,
           x_return_status       => l_return_status
         );

  IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                         WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
  END IF;



  -- 2. Lines/LPNs:
  --      call validate_wms to check WMS conditions
  --    Note: Deliveries must be validated first, as match_deliveries
  --          may update x_delivery_unassigns with LPNs

  IF x_context.wms_in_group THEN
    -- Bug 3555487 initialize message stack for each major action point.
    FND_MSG_PUB.initialize;

    validate_wms(
        x_context                  => x_context,
        x_plan_details             => x_plan_details,
        x_plan_deliveries          => x_plan_deliveries,
        x_delivery_unassigns       => x_delivery_unassigns,
        x_errors_tab               => x_errors_tab,
        x_return_status            => l_return_status
    );

    IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                           WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      RETURN;
    END IF;
  END IF;



  --  3. Trips:
  --    *  calls match_trips to identify deliveries to be unassigned
  --       and the stops to be deleted.
  --          + if trip is firmed, fail if there is anything to unassign or delete.

  -- Bug 3555487 initialize message stack for each major action point.
  FND_MSG_PUB.initialize;

  match_trips(
           x_context               => x_context,
           x_plan_deliveries       => x_plan_deliveries,
           x_plan_stops            => x_plan_stops,
           x_plan_trips            => x_plan_trips,
           x_trip_unassigns        => x_trip_unassigns,
           x_obsoleted_stops       => x_obsoleted_stops,
           x_errors_tab            => x_errors_tab,
           x_return_status         => l_return_status
         );

  IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                         WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  --
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TP_RELEASE.VALIDATE_PLAN',
                        l_module_name);

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END validate_plan;





--
--  Procedure:          reconciliate_plan
--  Parameters:
--               x_context             context in this session
--               x_plan_details        list of delivery details mapped to interface lines
--               x_track_conts         list of topmost containers to track
--               x_plan_deliveries     list of deliveries mapped to interface deliveries
--               x_plan_legs           list of delivery legs mapped to interface legs
--               x_plan_stops          list of stops mapped to interface stops
--               x_plan_trips          list of trips mapped to interface trips
--               x_plan_trip_moves     list of trip moves mapped to interface trip moves (FTE)
--               x_plan_moves          list of moves mapped to interface moves (FTE)
--               x_used_details        list of delivery details partially used by the plan
--               x_delivery_unassigns  list of delivery lines to unassign from their deliveries
--               x_trip_unassigns      list of deliveries to unassign from their trips
--               x_obsoleted_stops     list of mapped trips' stops that are not mapped in the plan
--               x_obsoleted_trip_moves     list of mapped trips' moves that are not mapped in the plan
--               x_errors_tab          list of errors to insert into wsh_interface_errors at the end
--               x_return_status       return status
--
--  Description:
--               Implement the plan by calling group APIs:
--               These activities will happen based on the plan lists:
--                1. unassign non-plan lines and all LPNs in x_delivery_unassigns
--                      inbound/drop: add non-plan lines and non-plan LPNs to split-delivery list.
--                2. unassign delivieres in x_trip_unassigns
--                3. create new deliveries and update existing deliveries
--                4.0 create new trips and update existing trips with NULL lane_id
--                         per bug 3580374, stops should be manipulated
--                         when their trips have NULL lane_id to skip
--                         unneeded stop validation that raised errors.
--                4.1 delete stops in x_obsoleted_stops
--                4.2 create new stops and update existing stops
--                4.3 update trips to have lane_id from the plan
--                5. split lines in x_plan_details
--                6. unassign lines in x_used_details and x_plan_details if need_unassignment is TRUE
--                   inbound/drop: add x_used_details to the split-delivery list if needed and invoke SPLIT-DELIVERY
--                                 and skip unassignment of x_plan_details
--                7. assign details in x_plan_details and x_track_conts to plan deliveries (if different from
--                   current deliveries).
--                   plan lines are unassigned if needed (topmost containers are covered in step 1).
--                     inbound/drop: plan lines and plan topmost containers in x_delivery_unassigns
--                     will use SPLIT-DELIVERY instead of ASSIGN.
--                   * validate that ship sets and SMC are completed in each delivery
--                   (if enforced in shipping parameters)
--                8. update delivery details with TP attributes
--                9. assign deliveries to trips
--               10. reconciliate continuous moves (FTE)
--               11. upgrade deliveries' planned_flag per the plan
--               12. upgrade trips' planned_flag per the plan
--               13. upgrade moves' planned_flag per the plan (FTE)
--               14. call the rating API
--               [HIDING PROJECT] 14.5 call the rank list API
--               15. call the Trip_Action API for Auto-Tender, context variable added
--                   auto_tender_flag
--
--               Note: it is important to keep these activities in the proper order
--                     because later activities will depend on outcome of earlier activities.
--                     For example, splitting details too soon would require tracking all the
--                     new delivery details to be unassigned/assigned, etc.
--
PROCEDURE reconciliate_plan(
           x_context                  IN OUT NOCOPY context_rec_type,
           x_plan_details             IN OUT NOCOPY plan_detail_tab_type,
           x_track_conts              IN OUT NOCOPY track_cont_tab_type,
           x_plan_deliveries          IN OUT NOCOPY plan_delivery_tab_type,
           x_plan_legs                IN OUT NOCOPY plan_leg_tab_type,
           x_plan_stops               IN OUT NOCOPY plan_stop_tab_type,
           x_plan_trips               IN OUT NOCOPY plan_trip_tab_type,
           x_plan_trip_moves          IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.plan_trip_move_tab_type,
           x_plan_moves               IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.plan_move_tab_type,
           x_used_details             IN OUT NOCOPY used_details_tab_type,
           x_delivery_unassigns       IN OUT NOCOPY delivery_unassign_tab_type,
           x_trip_unassigns           IN OUT NOCOPY trip_unassign_tab_type,
           x_obsoleted_stops          IN OUT NOCOPY obsoleted_stop_tab_type,
           x_obsoleted_trip_moves     IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.obsoleted_trip_move_tab_type,
           x_errors_tab               IN OUT NOCOPY interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          )
IS
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'RECONCILIATE_PLAN';
  --
  l_debug_on BOOLEAN;

  l_index      NUMBER;
  l_next_index NUMBER;
  l_work_index NUMBER;

  l_message_name       VARCHAR2(30);
  l_return_status      VARCHAR2(1);
  l_number_of_warnings NUMBER;
  l_number_of_errors   NUMBER;
  l_msg_data           VARCHAR2(32767);
  l_msg_count          NUMBER;
  l_interface_entity   WSH_INTERFACE_ERRORS.INTERFACE_TABLE_NAME%TYPE;
  l_interface_id       NUMBER;

  l_temp_delivery_index NUMBER;

  l_dd_attrs         WSH_GLBL_VAR_STRCT_GRP.delivery_details_attr_tbl_type;
  l_dd_action_prms   WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
  l_dd_defaults      WSH_GLBL_VAR_STRCT_GRP.dd_default_parameters_rec_type;
  l_dd_action_rec    WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type;

  -- inbound/drop: track unmapped delivery details for action SPLIT-DELIVERY.
  l_sd_dd_attrs      WSH_GLBL_VAR_STRCT_GRP.delivery_details_attr_tbl_type;
  l_sd_dd_count      NUMBER := 0;
  l_skip_step        BOOLEAN;
  l_is_inbound       BOOLEAN;

  l_del_attrs        WSH_NEW_DELIVERIES_PVT.delivery_attr_tbl_type;
  l_del_action_prms  WSH_DELIVERIES_GRP.action_parameters_rectype;
  l_del_action_rec   WSH_DELIVERIES_GRP.delivery_action_out_rec_type;
  l_del_defaults     WSH_DELIVERIES_GRP.default_parameters_rectype;
  l_del_in_rec       WSH_DELIVERIES_GRP.DEL_IN_REC_TYPE;
  l_del_out_tab      WSH_DELIVERIES_GRP.DEL_OUT_TBL_TYPE;

  l_stop_attrs       WSH_TRIP_STOPS_PVT.stop_attr_tbl_type;
  l_stop_action_prms WSH_TRIP_STOPS_GRP.action_parameters_rectype;
  l_stop_action_rec  WSH_TRIP_STOPS_GRP.StopActionOutRecType;
  l_stop_defaults    WSH_TRIP_STOPS_GRP.default_parameters_rectype;
  l_stop_in_rec      WSH_TRIP_STOPS_GRP.stopInRecType;
  l_stop_out_tab     WSH_TRIP_STOPS_GRP.stop_out_tab_type;
  l_stop_wt_vol_out_tab WSH_TRIP_STOPS_GRP.stop_wt_vol_tab_type;

  l_trip_attrs       WSH_TRIPS_PVT.trip_attr_tbl_type;
  l_trip_action_prms WSH_TRIPS_GRP.action_parameters_rectype;
  l_trip_in_rec      WSH_TRIPS_GRP.TripInRecType;
  l_trip_defaults    WSH_TRIPS_GRP.default_parameters_rectype;
  l_trip_out_rec     WSH_TRIPS_GRP.tripActionOutRecType;
  l_trip_out_tab     WSH_TRIPS_GRP.trip_out_tab_type;

  -- WV changes
  -- Checks if the delivery has wv_frozen flag set to 'Y'
  -- Used when unassigning from delivery not in plan.
  cursor c_check_del_wv_frozen(p_delivery_id in NUMBER) IS
  select initial_pickup_location_id
  from wsh_new_deliveries
  where wv_frozen_flag = 'Y'
  and delivery_id = p_delivery_id;

  -- Checks if the stop has wv_frozen flag set to 'Y'.
  -- Looks at all the stops on the delivery leg.
  -- Used when unassigning from a trip not in plan.
  cursor c_check_stop_wv_frozen(p_trip_id in NUMBER,
                                p_pickup_stop_id in NUMBER,
                                p_dropoff_stop_id in NUMBER) IS
  select s.stop_id, s.stop_location_id
  from wsh_trip_stops s,
       wsh_trip_stops spu,
       wsh_trip_stops sdo
  where s.wv_frozen_flag = 'Y'
  and   (s.stop_sequence_number between
         spu.stop_sequence_number
         and
         sdo.stop_sequence_number)
  and  spu.stop_id = p_pickup_stop_id
  and  sdo.stop_id = p_dropoff_stop_id
  and  s.trip_id = p_trip_id;


  -- Checks if the stops on the delivery
  -- have their wv frozen, even if the
  -- delivery does not have its wv frozen.
  -- Used when unassigning from delivery.
  cursor c_check_del_stop_wv_frozen(p_delivery_id in number) IS
  select wts.stop_id, wts.stop_location_id
  from wsh_delivery_legs wdl,
       wsh_trip_stops wts,
       wsh_trip_stops wtspu,
       wsh_trip_stops wtsdo
  where wdl.delivery_id = p_delivery_id
  and   (wts.stop_sequence_number between
         wtspu.stop_sequence_number
         and
         wtsdo.stop_sequence_number)
  and   wdl.pick_up_stop_id = wtspu.stop_id
  and   wdl.drop_off_stop_id = wtsdo.stop_id
  and   wts.trip_id  = wtspu.trip_id
  and  wts.wv_frozen_flag = 'Y';


  -- Checks if the intermediate stops to the
  -- given pickup and dropoff stops of the
  -- trip have their wv flags frozen.
  -- Used when unassigning from a trip in plan.
  cursor c_check_intmed_stop_wv_frozen
         (p_trip_id in number,
          p_pickup_seq_number in number,
          p_dropoff_seq_number in number) is
  select wts.stop_id, wts.stop_location_id
  from   wsh_trip_stops wts
  where  wts.stop_sequence_number < p_dropoff_seq_number
  and    wts.stop_sequence_number > p_pickup_seq_number
  and    wts.trip_id = p_trip_id
  and    wts.wv_frozen_flag = 'Y';

  l_wv_frozen_flag VARCHAR2(1);
  l_location_id NUMBER;


BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;
  --
  --

  --  1. unassign non-plan lines and all LPNs in x_delivery_unassigns
  --       inbound/drop: add non-plan lines and non-plan LPNs to split-delivery list.


  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'1. Unassign lines/LPNs: x_delivery_unassigns.COUNT', x_delivery_unassigns.COUNT);
  END IF;

  IF (x_delivery_unassigns.COUNT > 0)  THEN

    l_dd_attrs.DELETE;
    l_index := x_delivery_unassigns.FIRST;
    l_work_index := 0;
    WHILE l_index IS NOT NULL LOOP
      -- x_delivery_unassigns entity is one of the below kinds:
      --     a) plan line to unassign from a different delivery mapped in the plan
      --          outcome:  Skip this entity in this step; step 8 will take care of its unassignment.
      --     b) topmost container associated with a plan line to unassign from a different delivery (mapped or not)
      --          outcome:  Unassign in this step if outbound; otherwise, step 8 will take care of it.
      --     c) unmapped line or topmost container to unassign from the mapped plan delivery
      --          outcome:  Unassign in this step if outbound; otherwise, add to l_sd_dd_attrs for step 7.
      IF x_delivery_unassigns(l_index).plan_dd_index IS NOT NULL THEN
        -- this entity is part of the plan.
        l_is_inbound := (x_plan_details(x_delivery_unassigns(l_index).plan_dd_index).line_direction IN ('I', 'D'));
        l_skip_step  :=    (x_delivery_unassigns(l_index).container_flag = 'N')
                        OR (l_is_inbound);
      ELSE
        -- this unmapped entity is to be unassigned from the mapped plan delivery.
        l_is_inbound := (x_plan_deliveries(x_delivery_unassigns(l_index).plan_del_index).shipment_direction IN ('I', 'D'));
        l_skip_step := FALSE;
      END IF;

      IF NOT l_skip_step THEN --{
        IF l_is_inbound THEN
          l_sd_dd_count := l_sd_dd_count + 1;
          l_sd_dd_attrs(l_sd_dd_count).delivery_detail_id := x_delivery_unassigns(l_index).delivery_detail_id;
          l_sd_dd_attrs(l_sd_dd_count).organization_id    := x_delivery_unassigns(l_index).organization_id;
        ELSE
          l_work_index := l_work_index + 1;
          l_dd_attrs(l_work_index).delivery_detail_id := x_delivery_unassigns(l_index).delivery_detail_id;
          l_dd_attrs(l_work_index).organization_id    := x_delivery_unassigns(l_index).organization_id;
        END IF;

        -- WV changes
        -- Keep track of deliveries that have WV frozen, but
        -- would have their WV changed due to unassignments.
        -- Need the ship from locations to log exceptions.

        IF x_delivery_unassigns(l_index).wv_frozen_flag = 'Y' THEN
           IF NOT x_context.wv_exception_dels.exists(x_delivery_unassigns(l_index).delivery_id) THEN
              x_context.wv_exception_dels(x_delivery_unassigns(l_index).delivery_id) := x_delivery_unassigns(l_index).initial_pickup_location_id;

              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'Log WV exception against del', x_delivery_unassigns(l_index).delivery_id);
              END IF;
           END IF;

        END IF;

        -- Handles the case where the delivery wv may not be frozen, but it may
        -- have a stop that might have its wv frozen.

        FOR stop in c_check_del_stop_wv_frozen(x_delivery_unassigns(l_index).delivery_id) LOOP
            IF NOT x_context.wv_exception_stops.exists(stop.stop_id) THEN
               x_context.wv_exception_stops(stop.stop_id) := stop.stop_location_id;
               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'Log WV exception against stop', stop.stop_id);
               END IF;
            END IF;
        END LOOP;

      END IF; --} NOT l_skip_step

      l_index := x_delivery_unassigns.NEXT(l_index);

    END LOOP;

    IF l_work_index > 0 THEN
      -- invoke unassignment only if there are outbound details
      l_dd_action_prms.caller      := 'WSH_TP_RELEASE';
      l_dd_action_prms.action_code := 'UNASSIGN';

      WSH_DELIVERY_DETAILS_GRP.delivery_detail_action(
        p_api_version_number => 1.0,
        p_init_msg_list      => FND_API.G_TRUE,
        p_commit             => FND_API.G_FALSE,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data,
        p_rec_attr_tab       => l_dd_attrs,
        p_action_prms        => l_dd_action_prms,
        x_defaults           => l_dd_defaults,
        x_action_out_rec     => l_dd_action_rec);

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'l_return_status', l_return_status);
        WSH_DEBUG_SV.log(l_module_name, 'l_dd_action_rec.valid_id_tab.COUNT', l_dd_action_rec.valid_id_tab.COUNT);
        WSH_DEBUG_SV.log(l_module_name, 'l_dd_attrs.COUNT', l_dd_attrs.COUNT);
      END IF;

      -- convert warning to error if the count of valid ids does not match.
      IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
          AND l_dd_action_rec.valid_id_tab.COUNT < l_dd_attrs.COUNT) THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.LOG(l_module_name, 'converting return status', WSH_UTIL_CORE.G_RET_STS_ERROR);
        END IF;
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      END IF;

      l_interface_entity := 'NONE';
      l_interface_id     := -1;
      l_message_name     := 'WSH_TP_F_DEL_UNASSIGNS';
      wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_number_of_warnings,
           x_num_errors    => l_number_of_errors);
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'after x_delivery_unassigns, l_sd_dd_count', l_sd_dd_count);
    END IF;

  END IF;



  --  2. unassign delivieres in x_trip_unassigns

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'2. Unassign deliveries: x_trip_unassigns.COUNT: ', x_trip_unassigns.COUNT);
  END IF;

  IF (x_trip_unassigns.COUNT > 0)  THEN

    l_index := x_trip_unassigns.FIRST;

    l_del_attrs.DELETE;
    l_del_action_prms.caller      := 'WSH_TP_RELEASE';
    l_del_action_prms.action_code := 'UNASSIGN-TRIP';

    WHILE l_index IS NOT NULL LOOP

      IF x_trip_unassigns(l_index).delivery_id IS NOT NULL THEN
        l_del_attrs(1).delivery_id     := x_trip_unassigns(l_index).delivery_id;
        l_del_attrs(1).organization_id := x_trip_unassigns(l_index).organization_id;
        l_del_action_prms.trip_id  := x_trip_unassigns(l_index).trip_id;

        -- WV changes
        -- Keep track of stops that have WV frozen, but
        -- would have their WV changed due to unassignments.
        -- Need the stop locations to log exceptions.

        FOR stop in c_check_stop_wv_frozen(p_trip_id => x_trip_unassigns(l_index).trip_id,
                                           p_pickup_stop_id => x_trip_unassigns(l_index).pickup_stop_id,
                                           p_dropoff_stop_id => x_trip_unassigns(l_index).dropoff_stop_id)
        LOOP

           IF NOT x_context.wv_exception_stops.exists(stop.stop_id) THEN
              x_context.wv_exception_stops(stop.stop_id) :=  stop.stop_location_id;

              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'Log WV exception against stop', stop.stop_id);
              END IF;
           END IF;
        END LOOP;


        WSH_DELIVERIES_GRP.delivery_action(
          p_api_version_number => 1.0,
          p_init_msg_list      => FND_API.G_TRUE,
          p_commit             => FND_API.G_FALSE,
          p_action_prms        => l_del_action_prms,
          p_rec_attr_tab       => l_del_attrs,
          x_delivery_out_rec   => l_del_action_rec,
          x_defaults_rec       => l_del_defaults,
          x_return_status      => l_return_status,
          x_msg_count          => l_msg_count,
          x_msg_data           => l_msg_data);

        l_interface_entity := 'NONE';
        l_interface_id     := -1;
        l_message_name     := 'WSH_TP_F_TRIP_UNASSIGNS';
        wsh_util_core.api_post_call(
             p_return_status => l_return_status,
             x_num_warnings  => l_number_of_warnings,
             x_num_errors    => l_number_of_errors);

        l_index := x_trip_unassigns.NEXT(l_index);
      END IF;

    END LOOP;

  END IF;



  --  3. create new deliveries and update existing deliveries

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'3. Create/update deliveries: x_plan_deliveries.COUNT: ', x_plan_deliveries.COUNT);
  END IF;

  l_del_attrs.DELETE;
  l_del_in_rec.caller      := 'WSH_TP_RELEASE';
  l_del_in_rec.action_code := 'CREATE';

  l_index := x_plan_deliveries.FIRST;
  WHILE l_index IS NOT NULL LOOP

    -- Bug 3555487 initialize message stack for each major action point.
    FND_MSG_PUB.initialize;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'create/update deliveries: l_index', l_index);
    END IF;

    IF x_plan_deliveries(l_index).delivery_id IS NULL THEN
      l_del_in_rec.action_code := 'CREATE';
      l_message_name     := 'WSH_TP_F_CREATE_DEL';
    ELSE
      l_del_in_rec.action_code := 'UPDATE';
      l_message_name     := 'WSH_TP_F_UPDATE_DEL';
    END IF;

    copy_delivery_record(
            p_plan_delivery_rec  => x_plan_deliveries(l_index),
            x_delivery_attrs_rec => l_del_attrs(1),
            x_return_status      => l_return_status
    );

    -- bug 3593690: fail release if delivery cannot be populated
    -- usually because shipping parameters are missing.
    l_interface_entity := 'WSH_NEW_DEL_INTERFACE';
    l_interface_id     := x_plan_deliveries(l_index).del_interface_id;
    wsh_util_core.api_post_call(
             p_return_status => l_return_status,
             x_num_warnings  => l_number_of_warnings,
             x_num_errors    => l_number_of_errors);


    wsh_deliveries_grp.create_update_delivery (
        p_api_version_number     =>    1.0,
        p_init_msg_list          =>    FND_API.G_FALSE, -- bug 3593690: retain messages from copy_delivery_record
        p_commit                 =>    FND_API.G_FALSE,
        p_in_rec                 =>    l_del_in_rec,
        p_rec_attr_tab           =>    l_del_attrs,
        x_del_out_rec_tab        =>    l_del_out_tab,
        x_return_status          =>    l_return_status,
        x_msg_count              =>    l_msg_count,
        x_msg_data               =>    l_msg_data);

    l_interface_entity := 'WSH_NEW_DEL_INTERFACE';
    l_interface_id     := x_plan_deliveries(l_index).del_interface_id;
    wsh_util_core.api_post_call(
             p_return_status => l_return_status,
             x_num_warnings  => l_number_of_warnings,
             x_num_errors    => l_number_of_errors);

    IF l_del_in_rec.action_code = 'CREATE' THEN
      x_plan_deliveries(l_index).delivery_id := l_del_out_tab(l_del_out_tab.FIRST).delivery_id;
    END IF;

    l_index := x_plan_deliveries.NEXT(l_index);

  END LOOP;



  --  4.0 create new trips and update existing trips with NULL lane_id

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'4.0. Create/update trips: x_plan_trips.COUNT: ', x_plan_trips.COUNT);
  END IF;

  create_update_plan_trips(
           p_phase        => 1,
           x_context      => x_context,
           x_plan_trips   => x_plan_trips,
           x_errors_tab   => x_errors_tab,
           x_return_status => l_return_status
          );
  IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                         WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
     x_return_status := l_return_status;
     RETURN;
  END IF;


  --  4.1. delete stops in x_obsoleted_stops

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'4.1. Delete stops: x_obsoleted_stops.COUNT: ', x_obsoleted_stops.COUNT);
  END IF;

  IF (x_obsoleted_stops.COUNT > 0)  THEN

    l_stop_attrs.DELETE;
    l_index := x_obsoleted_stops.FIRST;
    l_work_index := 0;
    WHILE l_index IS NOT NULL LOOP
      l_work_index := l_work_index + 1;
      l_stop_attrs(l_work_index).stop_id := x_obsoleted_stops(l_index).stop_id;
      l_stop_attrs(l_work_index).trip_id := x_obsoleted_stops(l_index).trip_id;
      l_index := x_obsoleted_stops.NEXT(l_index);
    END LOOP;

    l_stop_action_prms.caller      := 'WSH_TP_RELEASE';
    l_stop_action_prms.action_code := 'DELETE';

    WSH_TRIP_STOPS_GRP.stop_action(
      p_api_version_number => 1.0,
      p_init_msg_list      => FND_API.G_TRUE,
      p_commit             => FND_API.G_FALSE,
      p_action_prms        => l_stop_action_prms,
      p_rec_attr_tab       => l_stop_attrs,
      x_stop_out_rec       => l_stop_action_rec,
      x_def_rec            => l_stop_defaults,
      x_return_status      => l_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data);

    l_interface_entity := 'NONE';
    l_interface_id     := -1;
    l_message_name     := 'WSH_TP_F_OBSOLETED_STOPS';
    wsh_util_core.api_post_call(
         p_return_status => l_return_status,
         x_num_warnings  => l_number_of_warnings,
         x_num_errors    => l_number_of_errors);

  END IF;



  --  4.2 create new stops and update existing stops
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'4.2 Create/update stops: x_plan_stops.COUNT: ', x_plan_stops.COUNT);
  END IF;

  l_stop_attrs.DELETE;
  l_stop_in_rec.caller      := 'WSH_TP_RELEASE';

  l_index := x_plan_stops.FIRST;
  WHILE l_index IS NOT NULL LOOP

    -- Bug 3555487 initialize message stack for each major action point.
    FND_MSG_PUB.initialize;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'create/update stops: l_index', l_index);
    END IF;

    copy_stop_record(
          p_plan_stop_rec  => x_plan_stops(l_index),
          p_plan_trips     => x_plan_trips,
          x_stop_attrs_rec => l_stop_attrs(1)
    );

    IF x_plan_stops(l_index).stop_id IS NULL THEN
      l_stop_in_rec.action_code := 'CREATE';
      l_message_name     := 'WSH_TP_F_CREATE_STOP';
    ELSE
      l_stop_in_rec.action_code := 'UPDATE';
      l_message_name     := 'WSH_TP_F_UPDATE_STOP';
    END IF;

    wsh_trip_stops_grp.Create_Update_Stop(
        p_api_version_number     =>    1.0,
        p_init_msg_list          =>    FND_API.G_FALSE,
        p_commit                 =>    FND_API.G_FALSE,
        p_in_rec                 =>    l_stop_in_rec,
        p_rec_attr_tab           =>    l_stop_attrs,
        x_stop_out_tab           =>    l_stop_out_tab,
        x_return_status          =>    l_return_status,
        x_msg_count              =>    l_msg_count,
        x_msg_data               =>    l_msg_data,
        x_stop_wt_vol_out_tab    =>    l_stop_wt_vol_out_tab
      );

    l_interface_entity := 'WSH_TRIP_STOPS_INTERFACE';
    l_interface_id     := x_plan_stops(l_index).stop_interface_id;

    wsh_util_core.api_post_call(
             p_return_status => l_return_status,
             x_num_warnings  => l_number_of_warnings,
             x_num_errors    => l_number_of_errors);

    IF l_stop_in_rec.action_code = 'CREATE' THEN
        x_plan_stops(l_index).stop_id := l_stop_out_tab(l_stop_out_tab.FIRST).stop_id;
    END IF;

    l_index := x_plan_stops.NEXT(l_index);
  END LOOP;


  --  4.3 update trips to have lane_id from the plan

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'4.3 update lane_id on trips: x_plan_trips.COUNT: ', x_plan_trips.COUNT);
  END IF;

  create_update_plan_trips(
           p_phase        => 2,
           x_context      => x_context,
           x_plan_trips   => x_plan_trips,
           x_errors_tab   => x_errors_tab,
           x_return_status => l_return_status
          );
  IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                         WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
     x_return_status := l_return_status;
     RETURN;
  END IF;



  --  5. split lines in x_plan_details
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'5. Split lines in x_plan_details');
  END IF;

  l_index := x_plan_details.FIRST;
  WHILE l_index IS NOT NULL LOOP

    IF x_plan_details(l_index).map_split_flag = 'Y' THEN

      l_dd_attrs.DELETE;
      l_dd_attrs(1).delivery_detail_id := x_plan_details(l_index).delivery_detail_id;
      l_dd_attrs(1).organization_id := x_plan_details(l_index).organization_id;

      l_dd_action_prms.caller      := 'WSH_TP_RELEASE';
      l_dd_action_prms.action_code := 'SPLIT-LINE';
      l_dd_action_prms.split_quantity := x_plan_details(l_index).mapped_quantity;

      -- WV changes
      -- Keep track of details that have WV frozen, but
      -- may have their WV changed due to splits.
      -- Need the ship from locations to log exceptions.

      IF x_plan_details(l_index).wv_frozen_flag = 'Y' THEN
         IF NOT x_context.wv_exception_details.exists(x_plan_details(l_index).delivery_detail_id) THEN
            x_context.wv_exception_details(x_plan_details(l_index).delivery_detail_id)
              := x_plan_details(l_index).ship_from_location_id;
              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'Log WV exception against detail', x_plan_details(l_index).delivery_detail_id);
              END IF;
         END IF;
      END IF;


      WSH_DELIVERY_DETAILS_GRP.delivery_detail_action(
        p_api_version_number => 1.0,
        p_init_msg_list      => FND_API.G_TRUE,
        p_commit             => FND_API.G_FALSE,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data,
        p_rec_attr_tab       => l_dd_attrs,
        p_action_prms        => l_dd_action_prms,
        x_defaults           => l_dd_defaults,
        x_action_out_rec     => l_dd_action_rec);

      l_interface_entity := 'WSH_DEL_DETAILS_INTERFACE';
      l_interface_id     := x_plan_details(l_index).dd_interface_id;
      l_message_name     := 'WSH_TP_F_LINE_SPLIT';
      wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_number_of_warnings,
           x_num_errors    => l_number_of_errors);

      x_plan_details(l_index).delivery_detail_id := l_dd_action_rec.result_id_tab(1);

    END IF;

    l_index := x_plan_details.NEXT(l_index);
  END LOOP;



  --  6. unassign lines in x_used_details and x_plan_details if need_unassignment is TRUE
  --      inbound/drop: add x_used_details to the split-delivery list if needed and invoke SPLIT-DELIVERY
  --                    and skip unassignment of x_plan_details

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'6. Unassign used details: x_used_details.COUNT: ', x_used_details.COUNT);
  END IF;

  l_dd_attrs.DELETE;
  l_work_index := 0;

  IF x_used_details.COUNT > 0 THEN
    l_index := x_used_details.FIRST;
    WHILE l_index IS NOT NULL LOOP
      IF x_used_details(l_index).need_unassignment THEN
        IF x_used_details(l_index).line_direction IN ('I', 'D') THEN
          -- inbound/drop
          l_sd_dd_count := l_sd_dd_count + 1;
          l_sd_dd_attrs(l_sd_dd_count).delivery_detail_id := x_used_details(l_index).delivery_detail_id;
          l_sd_dd_attrs(l_sd_dd_count).organization_id    := x_used_details(l_index).organization_id;
        ELSE
          -- outbound
          l_work_index := l_work_index + 1;
          l_dd_attrs(l_work_index).delivery_detail_id := x_used_details(l_index).delivery_detail_id;
          l_dd_attrs(l_work_index).organization_id    := x_used_details(l_index).organization_id;
        END IF;
      END IF;

      l_index := x_used_details.NEXT(l_index);
    END LOOP;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'after used details, l_dd_attrs.COUNT', l_dd_attrs.COUNT);
      WSH_DEBUG_SV.log(l_module_name,'after used details, l_sd_dd_count', l_sd_dd_count);
    END IF;
  END IF;

  l_index := x_plan_details.FIRST;
  WHILE l_index IS NOT NULL LOOP
    IF x_plan_details(l_index).current_delivery_id <>
         NVL(x_plan_deliveries(x_plan_details(l_index).target_delivery_index).delivery_id, -1) THEN

      -- inbound/drop lines will be taken care of in step 8 with SPLIT-DELIVERY.
      IF NVL(x_plan_details(l_index).line_direction, 'O') IN ('O', 'IO') THEN
        l_work_index := l_work_index + 1;
        l_dd_attrs(l_work_index).delivery_detail_id := x_plan_details(l_index).delivery_detail_id;
        l_dd_attrs(l_work_index).organization_id    := x_plan_details(l_index).organization_id;
      END IF;

      -- WV changes
      -- Keep track of deliveries that have WV frozen, but
      -- would have their WV changed due to unassignments.
      -- Need the ship from locations to log exceptions.


      IF NOT x_context.wv_exception_dels.exists(x_plan_details(l_index).current_delivery_id) THEN

         l_location_id := NULL;
         OPEN c_check_del_wv_frozen(x_plan_details(l_index).current_delivery_id);
         FETCH c_check_del_wv_frozen INTO l_location_id;
         CLOSE c_check_del_wv_frozen;

         IF l_location_id IS NOT NULL THEN
            x_context.wv_exception_dels(x_plan_details(l_index).current_delivery_id) :=  l_location_id;
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Log WV exception against delivery', x_plan_details(l_index).current_delivery_id);
            END IF;
          END IF;

      END IF;

      -- Handles the case where the delivery wv may not be frozen, but it may
      -- have a stop that might have its wv frozen.

      FOR stop in c_check_del_stop_wv_frozen(x_plan_details(l_index).current_delivery_id) LOOP
          IF NOT x_context.wv_exception_stops.exists(stop.stop_id) THEN
             x_context.wv_exception_stops(stop.stop_id) := stop.stop_location_id;
             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Log WV exception against stop', stop.stop_id);
             END IF;
          END IF;
      END LOOP;

    END IF;
    l_index := x_plan_details.NEXT(l_index);
  END LOOP;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'after plan details, l_dd_attrs.COUNT', l_dd_attrs.COUNT);
  END IF;

  IF l_dd_attrs.COUNT > 0 THEN
      l_dd_action_prms.caller      := 'WSH_TP_RELEASE';
      l_dd_action_prms.action_code := 'UNASSIGN';
      l_dd_action_prms.split_quantity := NULL;

      WSH_DELIVERY_DETAILS_GRP.delivery_detail_action(
        p_api_version_number => 1.0,
        p_init_msg_list      => FND_API.G_TRUE,
        p_commit             => FND_API.G_FALSE,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data,
        p_rec_attr_tab       => l_dd_attrs,
        p_action_prms        => l_dd_action_prms,
        x_defaults           => l_dd_defaults,
        x_action_out_rec     => l_dd_action_rec);


      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'l_return_status', l_return_status);
        WSH_DEBUG_SV.log(l_module_name, 'l_dd_action_rec.valid_id_tab.COUNT', l_dd_action_rec.valid_id_tab.COUNT);
        WSH_DEBUG_SV.log(l_module_name, 'l_dd_attrs.COUNT', l_dd_attrs.COUNT);
      END IF;

      -- convert warning to error if the count of valid ids does not match.
      IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
          AND l_dd_action_rec.valid_id_tab.COUNT < l_dd_attrs.COUNT) THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.LOG(l_module_name, 'converting return status', WSH_UTIL_CORE.G_RET_STS_ERROR);
        END IF;
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      END IF;

      l_interface_entity := 'NONE';
      l_interface_id     := -1;
      l_message_name     := 'WSH_TP_F_UNASSIGN_UNUSED';
      wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_number_of_warnings,
           x_num_errors    => l_number_of_errors);
  END IF;

  IF l_sd_dd_count > 0 THEN
      -- Inbound/drop: invoke SPLIT-DELIVERY on the unmapped lines/containers.
      l_dd_action_prms.caller         := 'WSH_TP_RELEASE';
      l_dd_action_prms.action_code    := 'SPLIT_DELIVERY';
      l_dd_action_prms.split_quantity := NULL;
      l_dd_action_prms.delivery_id    := NULL;

      WSH_DELIVERY_DETAILS_GRP.delivery_detail_action(
        p_api_version_number => 1.0,
        p_init_msg_list      => FND_API.G_TRUE,
        p_commit             => FND_API.G_FALSE,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data,
        p_rec_attr_tab       => l_sd_dd_attrs,
        p_action_prms        => l_dd_action_prms,
        x_defaults           => l_dd_defaults,
        x_action_out_rec     => l_dd_action_rec);


      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'l_return_status', l_return_status);
        WSH_DEBUG_SV.log(l_module_name, 'l_dd_action_rec.valid_id_tab.COUNT', l_dd_action_rec.valid_id_tab.COUNT);
        WSH_DEBUG_SV.log(l_module_name, 'l_sd_dd_attrs.COUNT', l_sd_dd_attrs.COUNT);
      END IF;

      -- convert warning to error if the count of valid ids does not match.
      IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
          AND l_dd_action_rec.valid_id_tab.COUNT < l_sd_dd_attrs.COUNT) THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.LOG(l_module_name, 'converting return status', WSH_UTIL_CORE.G_RET_STS_ERROR);
        END IF;
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      END IF;

      l_interface_entity := 'NONE';
      l_interface_id     := -1;
      l_message_name     := 'WSH_TP_F_SPLITDEL_UNUSED';
      wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_number_of_warnings,
           x_num_errors    => l_number_of_errors);
  END IF;


  --  7. assign details in x_plan_details and x_track_conts to plan deliveries (if different from
  --     current deliveries)
  --     plan lines are unassigned if needed (topmost containers are covered in step 1).
  --       inbound/drop: plan lines and plan topmost containers in x_delivery_unassigns
  --       will use SPLIT-DELIVERY instead of ASSIGN.
  --     * validate that ship sets and SMC are completed in each delivery
  --       (if enforced in shipping parameters)

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'7. Assign details to deliveries (unassigning as needed)');
  END IF;

  DECLARE
    l_work_details     plan_detail_tab_type;
    l_next_index   NUMBER;
    l_count        NUMBER;
    l_ship_params  wsh_shipping_params_pvt.parameter_rec_typ;
    l_valid_flag   BOOLEAN;
    l_unassign_index NUMBER := 0;
    l_unassign_details WSH_GLBL_VAR_STRCT_GRP.delivery_details_attr_tbl_type;
    l_unassign_deliveries WSH_UTIL_CORE.id_tab_type;

  BEGIN
    -- make a working copy of details that need assignments
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'build working list of details to assign and unassign');
    END IF;

    l_index := x_plan_details.FIRST;
    l_work_index := 0;

    -- go through unpacked lines to be unassigned and assigned
    WHILE l_index IS NOT NULL LOOP
      IF (x_plan_details(l_index).topmost_cont_id IS NULL)
         AND (
                 (x_plan_details(l_index).current_delivery_id IS NULL)
              OR (x_plan_details(l_index).current_delivery_id
                  <> x_plan_deliveries(x_plan_details(l_index).target_delivery_index).delivery_id))  THEN
        l_work_index := l_work_index + 1;
        l_work_details(l_work_index) := x_plan_details(l_index);
        x_plan_deliveries(x_plan_details(l_index).target_delivery_index).assign_details_count :=
            x_plan_deliveries(x_plan_details(l_index).target_delivery_index).assign_details_count + 1;

        IF x_plan_details(l_index).current_delivery_id IS NOT NULL THEN
          -- if assigned, add to the list to be unassigned
          -- this will loop at most once.
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'check whether to unassign delivery_detail_id', x_plan_details(l_index).delivery_detail_id);
          END IF;

          IF x_plan_details(l_index).line_direction IN ('O', 'IO') THEN
            -- only outbound lines need to be unassigned
            l_unassign_index := l_unassign_index + 1;
            l_unassign_details(l_unassign_index).delivery_detail_id := x_plan_details(l_index).delivery_detail_id;
            l_unassign_details(l_unassign_index).organization_id := x_plan_details(l_index).organization_id;
          END IF;

          -- WV changes
          -- Keep track of deliveries that have WV frozen, but
          -- would have their WV changed due to unassignments.
          -- Need the ship from locations to log exceptions.


          IF NOT x_context.wv_exception_dels.exists(x_plan_details(l_index).current_delivery_id) THEN

               l_location_id := NULL;
               OPEN c_check_del_wv_frozen(x_plan_details(l_index).current_delivery_id);
               FETCH c_check_del_wv_frozen INTO l_location_id;
               CLOSE c_check_del_wv_frozen;

               IF l_location_id IS NOT NULL THEN
                  x_context.wv_exception_dels(x_plan_details(l_index).current_delivery_id) :=  l_location_id;
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'Log WV exception against delivery', x_plan_details(l_index).current_delivery_id);
                  END IF;

               END IF;
            END IF;

            -- Handles the case where the delivery wv may not be frozen, but it may
            -- have a stop that might have its wv frozen.

            FOR stop in c_check_del_stop_wv_frozen(x_plan_details(l_index).current_delivery_id) LOOP
                IF NOT x_context.wv_exception_stops.exists(stop.stop_id) THEN
                   x_context.wv_exception_stops(stop.stop_id) := stop.stop_location_id;
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,'Log WV exception against stop', stop.stop_location_id);
                   END IF;
                END IF;
            END LOOP;

        END IF;

      END IF;
      l_index := x_plan_details.NEXT(l_index);
    END LOOP;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'unassign: l_unassign_details.COUNT', l_unassign_details.COUNT);
    END IF;

    -- unassign lines that need to be unassigned
    IF l_unassign_details.COUNT > 0 THEN
      -- there are details to unassign before we can assign them to the delivery mapped by plan.
      l_dd_action_prms.caller      := 'WSH_TP_RELEASE';
      l_dd_action_prms.action_code := 'UNASSIGN';
      l_dd_action_prms.split_quantity := NULL;
      l_dd_action_prms.delivery_id     := NULL;

      WSH_DELIVERY_DETAILS_GRP.delivery_detail_action(
          p_api_version_number => 1.0,
          p_init_msg_list      => FND_API.G_TRUE,
          p_commit             => FND_API.G_FALSE,
          x_return_status      => l_return_status,
          x_msg_count          => l_msg_count,
          x_msg_data           => l_msg_data,
          p_rec_attr_tab       => l_unassign_details,
          p_action_prms        => l_dd_action_prms,
          x_defaults           => l_dd_defaults,
          x_action_out_rec     => l_dd_action_rec);

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'l_return_status', l_return_status);
        WSH_DEBUG_SV.log(l_module_name, 'l_dd_action_rec.valid_id_tab.COUNT', l_dd_action_rec.valid_id_tab.COUNT);
        WSH_DEBUG_SV.log(l_module_name, 'l_unassign_details.COUNT', l_unassign_details.COUNT);
      END IF;

      -- convert warning to error if the count of valid ids does not match.
      IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
          AND l_dd_action_rec.valid_id_tab.COUNT < l_unassign_details.COUNT) THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.LOG(l_module_name, 'converting return status', WSH_UTIL_CORE.G_RET_STS_ERROR);
        END IF;
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      END IF;

      l_interface_entity := 'NONE';
      l_interface_id     := -1;
      l_message_name     := 'WSH_TP_F_UNASSIGNMENTS';
      wsh_util_core.api_post_call(
             p_return_status => l_return_status,
             x_num_warnings  => l_number_of_warnings,
             x_num_errors    => l_number_of_errors);
    END IF;



    -- go through containers if they exist
    -- (containers will already have been unassigned if outbound and needed)
    IF x_track_conts.COUNT > 0 THEN

      l_index := x_track_conts.FIRST;
      WHILE l_index IS NOT NULL LOOP
        IF   (x_track_conts(l_index).current_delivery_id IS NULL)
          OR (x_track_conts(l_index).current_delivery_id
                  <> x_plan_deliveries(x_track_conts(l_index).target_delivery_index).delivery_id)  THEN
          l_work_index := l_work_index + 1;
          l_work_details(l_work_index).delivery_detail_id    := x_track_conts(l_index).topmost_cont_id;
          l_work_details(l_work_index).target_delivery_index := x_track_conts(l_index).target_delivery_index;
          l_work_details(l_work_index).organization_id       := x_track_conts(l_index).organization_id;

          x_plan_deliveries(x_track_conts(l_index).target_delivery_index).assign_details_count :=
              x_plan_deliveries(x_track_conts(l_index).target_delivery_index).assign_details_count + 1;

        END IF;
        l_index := x_track_conts.NEXT(l_index);
      END LOOP;

    END IF;


    -- start assigning
    l_index := x_plan_deliveries.FIRST;
    WHILE l_index IS NOT NULL LOOP
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'check for assignments in delivery', x_plan_deliveries(l_index).delivery_id);
        WSH_DEBUG_SV.log(l_module_name, 'count of details to assign', x_plan_deliveries(l_index).assign_details_count);
      END IF;

      IF x_plan_deliveries(l_index).assign_details_count > 0 THEN
        -- there are details to assign to this delivery
        l_dd_attrs.DELETE;

        l_dd_action_prms.caller      := 'WSH_TP_RELEASE';
        IF x_plan_deliveries(l_index).shipment_direction IN ('I', 'D')  THEN
          -- this action will unassign inbound/drop details from old deliveries to the mapped delivery
          -- without resetting their ship_from_location_id, ignore_for_planning, routing_request_id, etc.
          l_dd_action_prms.action_code := 'SPLIT_DELIVERY';
        ELSE
          l_dd_action_prms.action_code := 'ASSIGN';
        END IF;
        l_dd_action_prms.split_quantity := NULL;
        l_dd_action_prms.delivery_id := x_plan_deliveries(l_index).delivery_id;

        -- WV changes
        -- Keep track of deliveries that have WV frozen, but
        -- would have their WV changed due to assignments.
        -- Need the ship from locations to log exceptions.

        IF x_plan_deliveries(l_index).wv_frozen_flag = 'Y' THEN
           IF NOT x_context.wv_exception_dels.exists(x_plan_deliveries(l_index).delivery_id) THEN
              x_context.wv_exception_dels(x_plan_deliveries(l_index).delivery_id) := x_plan_deliveries(l_index).initial_pickup_location_id;
              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'Log WV exception against delivery', x_plan_deliveries(l_index).delivery_id);
              END IF;
           END IF;
        END IF;
        -- Handles the case where the delivery wv may not be frozen, but it may
        -- have a stop that might have its wv frozen.

        FOR stop in c_check_del_stop_wv_frozen(x_plan_deliveries(l_index).delivery_id) LOOP
            IF NOT x_context.wv_exception_stops.exists(stop.stop_id) THEN
               x_context.wv_exception_stops(stop.stop_id) := stop.stop_location_id;
               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'Log WV exception against stop', stop.stop_id);
               END IF;
            END IF;
        END LOOP;

        l_count      := 0;
        l_work_index := l_work_details.FIRST;
        WHILE     (l_work_index IS NOT NULL)
              AND (l_count < x_plan_deliveries(l_index).assign_details_count) LOOP

          l_next_index := l_work_details.NEXT(l_work_index);

          IF l_work_details(l_work_index).target_delivery_index = l_index THEN
             l_dd_attrs(l_dd_attrs.COUNT + 1).delivery_detail_id := l_work_details(l_work_index).delivery_detail_id;
             l_dd_attrs(l_dd_attrs.COUNT).organization_id := l_work_details(l_work_index).organization_id;
             l_count := l_count + 1;
             l_work_details.DELETE(l_work_index);
          END IF;

          l_work_index := l_next_index;
        END LOOP;

        WSH_DELIVERY_DETAILS_GRP.delivery_detail_action(
          p_api_version_number => 1.0,
          p_init_msg_list      => FND_API.G_TRUE,
          p_commit             => FND_API.G_FALSE,
          x_return_status      => l_return_status,
          x_msg_count          => l_msg_count,
          x_msg_data           => l_msg_data,
          p_rec_attr_tab       => l_dd_attrs,
          p_action_prms        => l_dd_action_prms,
          x_defaults           => l_dd_defaults,
          x_action_out_rec     => l_dd_action_rec);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'l_return_status', l_return_status);
          WSH_DEBUG_SV.log(l_module_name, 'l_dd_action_rec.valid_id_tab.COUNT', l_dd_action_rec.valid_id_tab.COUNT);
          WSH_DEBUG_SV.log(l_module_name, 'l_dd_attrs.COUNT', l_dd_attrs.COUNT);
        END IF;

        -- convert warning to error if the count of valid ids does not match.
        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
            AND l_dd_action_rec.valid_id_tab.COUNT < l_dd_attrs.COUNT) THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.LOG(l_module_name, 'converting return status', WSH_UTIL_CORE.G_RET_STS_ERROR);
          END IF;
          l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        END IF;

        l_interface_entity := 'WSH_NEW_DEL_INTERFACE';
        l_interface_id     := x_plan_deliveries(l_index).del_interface_id;
        l_message_name     := 'WSH_TP_F_ASSIGN_DEL';
        wsh_util_core.api_post_call(
             p_return_status => l_return_status,
             x_num_warnings  => l_number_of_warnings,
             x_num_errors    => l_number_of_errors);
      END IF;

      -- validate ship sets and smc are completed if enforced
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'check if we enforce ship sets and SMC in organization', x_plan_deliveries(l_index).organization_id);
      END IF;

      wsh_shipping_params_pvt.get(
                   p_organization_id => x_plan_deliveries(l_index).organization_id,
                   x_param_info      => l_ship_params,
                   x_return_status   => l_return_status);

      l_interface_entity := 'WSH_NEW_DEL_INTERFACE';
      l_interface_id     := x_plan_deliveries(l_index).del_interface_id;
      l_message_name     := 'WSH_TP_F_SHIP_PARAMS';
      wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_number_of_warnings,
           x_num_errors    => l_number_of_errors);


      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'l_ship_params.enforce_ship_set_and_smc', l_ship_params.enforce_ship_set_and_smc);
      END IF;

      IF l_ship_params.enforce_ship_set_and_smc = 'Y' THEN

        wsh_tpa_delivery_pkg.check_ship_set(
               p_delivery_id   => x_plan_deliveries(l_index).delivery_id,
               x_valid_flag    => l_valid_flag,
               x_return_status => l_return_status);

        IF NOT l_valid_flag THEN
          l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          l_interface_entity := 'WSH_NEW_DEL_INTERFACE';
          l_interface_id     := x_plan_deliveries(l_index).del_interface_id;
          l_message_name     := 'WSH_TP_F_BROKEN_SHIP_SET';
          wsh_util_core.api_post_call(
             p_return_status => l_return_status,
             x_num_warnings  => l_number_of_warnings,
             x_num_errors    => l_number_of_errors);
        END IF;

        wsh_tpa_delivery_pkg.check_smc(
               p_delivery_id   => x_plan_deliveries(l_index).delivery_id,
               x_valid_flag    => l_valid_flag,
               x_return_status => l_return_status);

        IF NOT l_valid_flag THEN
          l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          l_interface_entity := 'WSH_NEW_DEL_INTERFACE';
          l_interface_id     := x_plan_deliveries(l_index).del_interface_id;
          l_message_name     := 'WSH_TP_F_BROKEN_SMC';
          wsh_util_core.api_post_call(
             p_return_status => l_return_status,
             x_num_warnings  => l_number_of_warnings,
             x_num_errors    => l_number_of_errors);
        END IF;

      END IF;

      l_index := x_plan_deliveries.NEXT(l_index);
    END LOOP;

  END;



  --  8. update delivery details with TP attributes

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'8. update delivery details with TP attributes: x_plan_details.COUNT: ', x_plan_details.COUNT);
  END IF;

    -- avoid overhead of calling group API to update one column
    l_index := x_plan_details.FIRST;
    WHILE l_index IS NOT NULL LOOP
      UPDATE wsh_delivery_details
      SET tp_delivery_detail_id  = x_plan_details(l_index).tp_delivery_detail_id,
          last_update_date       = SYSDATE,
          last_updated_by        = FND_GLOBAL.USER_ID
      WHERE delivery_detail_id = x_plan_details(l_index).delivery_detail_id;
      l_index := x_plan_details.NEXT(l_index);
    END LOOP;


  -- 9. assign deliveries to trips

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'9. Assign deliveries to trips: x_plan_legs.COUNT: ', x_plan_legs.COUNT);
  END IF;

  l_index := x_plan_legs.FIRST;
  WHILE l_index IS NOT NULL LOOP

    IF (x_plan_legs(l_index).delivery_leg_id IS NULL)  THEN

      l_del_attrs.DELETE;
      l_del_action_prms.caller      := 'WSH_TP_RELEASE';
      l_del_action_prms.action_code := 'ASSIGN-TRIP';

      l_del_attrs(1).delivery_id        := x_plan_deliveries( x_plan_legs(l_index).delivery_index     ).delivery_id;
      l_del_attrs(1).organization_id    := x_plan_deliveries( x_plan_legs(l_index).delivery_index     ).organization_id;

      l_del_action_prms.trip_id          := x_plan_trips( x_plan_legs(l_index).trip_index         ).trip_id;
      l_del_action_prms.pickup_stop_id   := x_plan_stops( x_plan_legs(l_index).pickup_stop_index  ).stop_id;
      l_del_action_prms.pickup_loc_id    := x_plan_stops( x_plan_legs(l_index).pickup_stop_index  ).stop_location_id;
      l_del_action_prms.pickup_stop_seq  := x_plan_stops( x_plan_legs(l_index).pickup_stop_index  ).stop_sequence_number;
      l_del_action_prms.pickup_arr_date  := x_plan_stops( x_plan_legs(l_index).pickup_stop_index  ).planned_arrival_date;
      l_del_action_prms.pickup_dep_date  := x_plan_stops( x_plan_legs(l_index).pickup_stop_index  ).planned_departure_date;
      l_del_action_prms.pickup_stop_status := 'OP';
      l_del_action_prms.dropoff_stop_id  := x_plan_stops( x_plan_legs(l_index).dropoff_stop_index ).stop_id;
      l_del_action_prms.dropoff_loc_id   := x_plan_stops( x_plan_legs(l_index).dropoff_stop_index  ).stop_location_id;
      l_del_action_prms.dropoff_stop_seq := x_plan_stops( x_plan_legs(l_index).dropoff_stop_index  ).stop_sequence_number;
      l_del_action_prms.dropoff_arr_date := x_plan_stops( x_plan_legs(l_index).dropoff_stop_index  ).planned_arrival_date;
      l_del_action_prms.dropoff_dep_date := x_plan_stops( x_plan_legs(l_index).dropoff_stop_index  ).planned_departure_date;
      l_del_action_prms.dropoff_stop_status := 'OP';

      -- WV changes
      -- Keep track of stops that have WV frozen, but
      -- would have their WV changed due to assignments.
      -- Need the stop locations to log exceptions.

      IF x_plan_stops(x_plan_legs(l_index).pickup_stop_index).wv_frozen_flag = 'Y' THEN
         IF NOT x_context.wv_exception_stops.exists(x_plan_stops(x_plan_legs(l_index).pickup_stop_index).stop_id) THEN
            x_context.wv_exception_stops(x_plan_stops(x_plan_legs(l_index).pickup_stop_index).stop_id) :=
             x_plan_stops(x_plan_legs(l_index).pickup_stop_index).stop_location_id;
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Log WV exception against stop', x_plan_stops(x_plan_legs(l_index).pickup_stop_index).stop_id);
            END IF;
         END IF;
      END IF;
      IF x_plan_stops(x_plan_legs(l_index).dropoff_stop_index).wv_frozen_flag = 'Y' THEN
         IF NOT x_context.wv_exception_stops.exists(x_plan_stops(x_plan_legs(l_index).dropoff_stop_index).stop_id) THEN
            x_context.wv_exception_stops(x_plan_stops(x_plan_legs(l_index).dropoff_stop_index).stop_id) :=
             x_plan_stops(x_plan_legs(l_index).dropoff_stop_index).stop_location_id;
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Log WV exception against stop', x_plan_stops(x_plan_legs(l_index).dropoff_stop_index).stop_id);
            END IF;
         END IF;
      END IF;

      -- Also check the intermediate stops on the trip since they too would be affected by the assignment.

      FOR stop in c_check_intmed_stop_wv_frozen(p_trip_id => l_del_action_prms.trip_id,
                                                      p_pickup_seq_number  => l_del_action_prms.pickup_stop_seq,
                                                      p_dropoff_seq_number => l_del_action_prms.dropoff_stop_seq)
      LOOP

         IF NOT x_context.wv_exception_stops.exists(stop.stop_id) THEN
            x_context.wv_exception_stops(stop.stop_id) :=  stop.stop_location_id;

            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Log WV exception against stop', stop.stop_id);
            END IF;
         END IF;
      END LOOP;

      WSH_DELIVERIES_GRP.delivery_action(
        p_api_version_number => 1.0,
        p_init_msg_list      => FND_API.G_TRUE,
        p_commit             => FND_API.G_FALSE,
        p_action_prms        => l_del_action_prms,
        p_rec_attr_tab       => l_del_attrs,
        x_delivery_out_rec   => l_del_action_rec,
        x_defaults_rec       => l_del_defaults,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data);

      l_interface_entity := 'WSH_DEL_LEGS_INTERFACE';
      l_interface_id     := x_plan_legs(l_index).leg_interface_id;
      l_message_name     := 'WSH_TP_F_ASSIGN_TRIP';
      wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_number_of_warnings,
           x_num_errors    => l_number_of_errors);

    END IF;

    l_index := x_plan_legs.NEXT(l_index);
  END LOOP;



  -- 10. reconciliate continuous moves (FTE)

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'10. reconciliate continuous moves: x_plan_moves.COUNT', x_plan_moves.COUNT);
    WSH_DEBUG_SV.log(l_module_name,'x_plan_trip_moves.COUNT', x_plan_trip_moves.COUNT);
    WSH_DEBUG_SV.log(l_module_name,'x_obsoleted_trip_moves.COUNT', x_obsoleted_trip_moves.COUNT);
  END IF;

  -- Bug 3555487 initialize message stack for each major action point.
  FND_MSG_PUB.initialize;

  WSH_FTE_TP_INTEGRATION.reconciliate_moves(
           x_context              => x_context,
           x_plan_trips           => x_plan_trips,
           x_plan_trip_moves      => x_plan_trip_moves,
           x_plan_moves           => x_plan_moves,
           x_obsoleted_trip_moves => x_obsoleted_trip_moves,
           x_errors_tab           => x_errors_tab,
           x_return_status        => l_return_status
          );

  IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                         WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
     x_return_status := l_return_status;
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'reconcilate_moves failed: x_return_status', x_return_status);
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     RETURN;
  END IF;


  -- 11. upgrade deliveries' planned_flag per the plan

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'11. Firm deliveries: x_plan_deliveries.COUNT', x_plan_deliveries.COUNT);
  END IF;

  DECLARE
     -- list of deliveries to become contents firmed.
     l_cf_dels   WSH_NEW_DELIVERIES_PVT.delivery_attr_tbl_type;
     -- list of deliveries to become routing and contents firmed.
     l_rcf_dels  WSH_NEW_DELIVERIES_PVT.delivery_attr_tbl_type;
     l_discard_return_status VARCHAR2(1);
  BEGIN  --{

    l_index := x_plan_deliveries.FIRST;
    WHILE l_index IS NOT NULL LOOP
      -- make lists of deliveries that need to be firmed without downgrading.

      IF     (x_plan_deliveries(l_index).planned_flag = 'Y')
         AND (NVL(x_plan_deliveries(l_index).wsh_planned_flag, 'N') = 'N') THEN
        copy_delivery_record(
            p_plan_delivery_rec  => x_plan_deliveries(l_index),
            x_delivery_attrs_rec => l_cf_dels(l_cf_dels.COUNT+1),
            x_return_status      => l_discard_return_status
        );
      ELSIF (x_plan_deliveries(l_index).planned_flag = 'F')
         AND (NVL(x_plan_deliveries(l_index).wsh_planned_flag, 'N') <> 'F') THEN
        copy_delivery_record(
            p_plan_delivery_rec  => x_plan_deliveries(l_index),
            x_delivery_attrs_rec => l_rcf_dels(l_rcf_dels.COUNT+1),
            x_return_status      => l_discard_return_status
        );
      END IF;

      l_index := x_plan_deliveries.NEXT(l_index);
    END LOOP;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Contents Firm deliveries: l_cf_dels.COUNT', l_cf_dels.COUNT);
    END IF;

    IF l_cf_dels.COUNT > 0 THEN

      l_del_action_prms.caller      := 'WSH_TP_RELEASE';
      l_del_action_prms.action_code := 'PLAN';

      l_del_action_prms.trip_id         := NULL;
      l_del_action_prms.pickup_stop_id  := NULL;
      l_del_action_prms.dropoff_stop_id := NULL;

      WSH_DELIVERIES_GRP.delivery_action(
        p_api_version_number => 1.0,
        p_init_msg_list      => FND_API.G_TRUE,
        p_commit             => FND_API.G_FALSE,
        p_action_prms        => l_del_action_prms,
        p_rec_attr_tab       => l_cf_dels,
        x_delivery_out_rec   => l_del_action_rec,
        x_defaults_rec       => l_del_defaults,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data);

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'l_return_status', l_return_status);
         WSH_DEBUG_SV.log(l_module_name, 'l_del_action_rec.valid_ids_tab.COUNT', l_del_action_rec.valid_ids_tab.COUNT);
         WSH_DEBUG_SV.log(l_module_name, 'l_cf_dels.COUNT', l_cf_dels.COUNT);
      END IF;

      -- convert warning to error if the count of valid ids does not match.
      IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
          AND l_del_action_rec.valid_ids_tab.COUNT < l_cf_dels.COUNT) THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.LOG(l_module_name, 'converting return status', WSH_UTIL_CORE.G_RET_STS_ERROR);
        END IF;
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      END IF;

      l_interface_entity := 'NONE';
      l_interface_id     := -1;
      l_message_name     := 'WSH_TP_F_CF_DEL_FAILED';
      wsh_util_core.api_post_call(
             p_return_status => l_return_status,
             x_num_warnings  => l_number_of_warnings,
             x_num_errors    => l_number_of_errors);
    END IF;


    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Routing and Contents Firm deliveries: l_rcf_dels.COUNT', l_rcf_dels.COUNT);
    END IF;

    IF l_rcf_dels.COUNT > 0 THEN

      l_del_action_prms.caller      := 'WSH_TP_RELEASE';
      l_del_action_prms.action_code := 'FIRM';

      l_del_action_prms.trip_id         := NULL;
      l_del_action_prms.pickup_stop_id  := NULL;
      l_del_action_prms.dropoff_stop_id := NULL;

      WSH_DELIVERIES_GRP.delivery_action(
        p_api_version_number => 1.0,
        p_init_msg_list      => FND_API.G_TRUE,
        p_commit             => FND_API.G_FALSE,
        p_action_prms        => l_del_action_prms,
        p_rec_attr_tab       => l_rcf_dels,
        x_delivery_out_rec   => l_del_action_rec,
        x_defaults_rec       => l_del_defaults,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data);

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'l_return_status', l_return_status);
         WSH_DEBUG_SV.log(l_module_name, 'l_del_action_rec.valid_ids_tab.COUNT', l_del_action_rec.valid_ids_tab.COUNT);
         WSH_DEBUG_SV.log(l_module_name, 'l_rcf_dels.COUNT', l_rcf_dels.COUNT);
      END IF;

      -- convert warning to error if the count of valid ids does not match.
      IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
          AND l_del_action_rec.valid_ids_tab.COUNT < l_rcf_dels.COUNT) THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.LOG(l_module_name, 'converting return status', WSH_UTIL_CORE.G_RET_STS_ERROR);
        END IF;
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      END IF;

      l_interface_entity := 'NONE';
      l_interface_id     := -1;
      l_message_name     := 'WSH_TP_F_RCF_DEL_FAILED';
      wsh_util_core.api_post_call(
             p_return_status => l_return_status,
             x_num_warnings  => l_number_of_warnings,
             x_num_errors    => l_number_of_errors);
    END IF;

  END;  --}



  -- 12. upgrade trips' planned_flag per the plan

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'12. Firm trips: x_plan_trips.COUNT', x_plan_trips.COUNT);
  END IF;

  DECLARE
     -- list of trips to become routing firmed.
     l_rf_trips   WSH_TRIPS_PVT.trip_attr_tbl_type;
     -- list of trips to become routing and contents firmed.
     l_rcf_trips  WSH_TRIPS_PVT.trip_attr_tbl_type;
  BEGIN  --{

    l_index := x_plan_trips.FIRST;
    WHILE l_index IS NOT NULL LOOP
      -- make lists of deliveries that need to be firmed without downgrading.

      IF     (x_plan_trips(l_index).planned_flag = 'Y')
         AND (NVL(x_plan_trips(l_index).wsh_planned_flag, 'N') = 'N') THEN
        copy_trip_record(
            p_plan_trip_rec  => x_plan_trips(l_index),
            x_trip_attrs_rec => l_rf_trips(l_rf_trips.COUNT+1)
        );
      ELSIF (x_plan_trips(l_index).planned_flag = 'F')
         AND (NVL(x_plan_trips(l_index).wsh_planned_flag, 'N') <> 'F') THEN
        copy_trip_record(
            p_plan_trip_rec  => x_plan_trips(l_index),
            x_trip_attrs_rec => l_rcf_trips(l_rcf_trips.COUNT+1)
        );
      END IF;

      l_index := x_plan_trips.NEXT(l_index);
    END LOOP;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Contents Firm trips: l_rf_trips.COUNT', l_rf_trips.COUNT);
    END IF;

    IF l_rf_trips.COUNT > 0 THEN

      l_trip_action_prms.caller      := 'WSH_TP_RELEASE';
      l_trip_action_prms.action_code := 'PLAN';

      wsh_trips_grp.trip_action(
         p_api_version_number =>  1.0,
         p_init_msg_list      =>  FND_API.G_TRUE,
         p_commit             =>  FND_API.G_FALSE,
         p_action_prms        =>  l_trip_action_prms,
         p_rec_attr_tab       =>  l_rf_trips,
         x_trip_out_rec       =>  l_trip_out_rec,
         x_def_rec            =>  l_trip_defaults,
         x_return_status      =>  l_return_status,
         x_msg_count          =>  l_msg_count,
         x_msg_data           =>  l_msg_data);

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'l_return_status', l_return_status);
         WSH_DEBUG_SV.log(l_module_name, 'l_trip_out_rec.valid_ids_tab.COUNT', l_trip_out_rec.valid_ids_tab.COUNT);
         WSH_DEBUG_SV.log(l_module_name, 'l_rf_trips.COUNT', l_rf_trips.COUNT);
      END IF;

      -- convert warning to error if the count of valid ids does not match.
      IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
          AND l_trip_out_rec.valid_ids_tab.COUNT < l_rf_trips.COUNT) THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.LOG(l_module_name, 'converting return status', WSH_UTIL_CORE.G_RET_STS_ERROR);
        END IF;
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      END IF;

      l_interface_entity := 'NONE';
      l_interface_id     := -1;
      l_message_name     := 'WSH_TP_F_RF_TRIP_FAILED';
      wsh_util_core.api_post_call(
             p_return_status => l_return_status,
             x_num_warnings  => l_number_of_warnings,
             x_num_errors    => l_number_of_errors);
    END IF;


    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Routing and Contents Firm deliveries: l_rcf_trips.COUNT', l_rcf_trips.COUNT);
    END IF;

    IF l_rcf_trips.COUNT > 0 THEN

      l_trip_action_prms.caller      := 'WSH_TP_RELEASE';
      l_trip_action_prms.action_code := 'FIRM';

      wsh_trips_grp.trip_action(
         p_api_version_number =>  1.0,
         p_init_msg_list      =>  FND_API.G_TRUE,
         p_commit             =>  FND_API.G_FALSE,
         p_action_prms        =>  l_trip_action_prms,
         p_rec_attr_tab       =>  l_rcf_trips,
         x_trip_out_rec       =>  l_trip_out_rec,
         x_def_rec            =>  l_trip_defaults,
         x_return_status      =>  l_return_status,
         x_msg_count          =>  l_msg_count,
         x_msg_data           =>  l_msg_data);

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'l_return_status', l_return_status);
         WSH_DEBUG_SV.log(l_module_name, 'l_trip_out_rec.valid_ids_tab.COUNT', l_trip_out_rec.valid_ids_tab.COUNT);
         WSH_DEBUG_SV.log(l_module_name, 'l_rcf_trips.COUNT', l_rcf_trips.COUNT);
      END IF;

      -- convert warning to error if the count of valid ids does not match.
      IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
          AND l_trip_out_rec.valid_ids_tab.COUNT < l_rcf_trips.COUNT) THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.LOG(l_module_name, 'converting return status', WSH_UTIL_CORE.G_RET_STS_ERROR);
        END IF;
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      END IF;

      l_interface_entity := 'NONE';
      l_interface_id     := -1;
      l_message_name     := 'WSH_TP_F_RCF_TRIP_FAILED';
      wsh_util_core.api_post_call(
             p_return_status => l_return_status,
             x_num_warnings  => l_number_of_warnings,
             x_num_errors    => l_number_of_errors);
    END IF;

  END;  --}



  -- 13. upgrade moves' planned_flag per the plan (FTE)

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'13. firm moves: x_plan_moves.COUNT', x_plan_moves.COUNT);
  END IF;

  WSH_FTE_TP_INTEGRATION.tp_firm_moves(
           x_context              => x_context,
           x_plan_moves           => x_plan_moves,
           x_errors_tab           => x_errors_tab,
           x_return_status        => l_return_status
          );

  IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                         WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'tp_firm_moves failed: l_return_status', l_return_status);
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     RETURN;
  END IF;


  -- 14. call the rating API

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'14. call rating API: x_plan_trips.COUNT', x_plan_trips.COUNT);
  END IF;

  DECLARE
    l_rating_action_params WSH_FTE_INTEGRATION.rating_action_param_rec;
    -- [HIDING PROJECT] comment the table used for building the rank list.
    --l_trip_id_tab          WSH_UTIL_CORE.ID_TAB_TYPE;
    l_index                NUMBER;
    l_tab_index            NUMBER;
    l_return_status        VARCHAR2(1);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(32767);
  BEGIN
     l_tab_index := 0;

     l_rating_action_params.caller := 'WSH';
     l_rating_action_params.event  := 'TP-RELEASE';
     l_rating_action_params.action := 'RATE';

     l_index := x_plan_trips.FIRST;
     WHILE l_index IS NOT NULL LOOP
       l_tab_index := l_tab_index + 1;
       l_rating_action_params.trip_id_list(l_tab_index) := x_plan_trips(l_index).trip_id;
       --l_trip_id_tab(l_tab_index) := x_plan_trips(l_index).trip_id;
       l_index := x_plan_trips.NEXT(l_index);
     END LOOP;

     WSH_FTE_INTEGRATION.Rate_Trip (
             p_api_version   => 1.0,
             p_init_msg_list => FND_API.G_TRUE,
             p_action_params => l_rating_action_params,
             p_commit        => FND_API.G_FALSE,
             x_return_status => l_return_status,
             x_msg_count     => l_msg_count,
             x_msg_data      => l_msg_data);


    -- Do not return or fail the plan if we cannot rate.
    -- If something goes wrong later, We may need to know about this one.
    IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                           WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'rate_trip failed: l_return_status', l_return_status);
       END IF;

       stamp_interface_error(
              p_group_id            => x_context.group_id,
              p_entity_table_name   => 'NONE',
              p_entity_interface_id => -1,
              p_message_name        => 'WSH_TP_I_TRIP_RATE_FAILED',
              x_errors_tab          => x_errors_tab,
              x_return_status       => l_return_status);
    END IF;


    --[HIDING PROJECT] start
    -- below code is commented.
    -- 14.5 call the rank list API
    --
    --IF l_debug_on THEN
    --  WSH_DEBUG_SV.log(l_module_name,'14.5 call rank list API: l_trip_id_tab.COUNT', l_trip_id_tab.COUNT);
    --END IF;
    --
    --WSH_FTE_INTEGRATION.CREATE_RANK_LIST_BULK(
    --    p_api_version_number => 1,
    --    p_init_msg_list      => FND_API.G_TRUE,
    --    x_return_status      => l_return_status,
    --    x_msg_count          => l_msg_count,
    --    x_msg_data           => l_msg_data,
    --    p_source             => WSH_FTE_INTEGRATION.C_RANKLIST_SOURCE_TP,
    --    p_trip_id_tab        => l_trip_id_tab
    --);
    --
    ---- Do not return or fail the plan if we cannot rank.
    ---- If something goes wrong later, We may need to know about this one.
    --IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
    --                       WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
    --   IF l_debug_on THEN
    --     WSH_DEBUG_SV.log(l_module_name, 'create_rank_list_bulk failed: l_return_status', l_return_status);
    --   END IF;
    --
    --
    --   stamp_interface_error(
    --          p_group_id            => x_context.group_id,
    --          p_entity_table_name   => 'NONE',
    --          p_entity_interface_id => -1,
    --          p_message_name        => 'WSH_TP_I_TRIP_RANK_FAILED', --!!! new message
    --          x_errors_tab          => x_errors_tab,
    --          x_return_status       => l_return_status);
    --END IF;
    --[HIDING PROJECT] end



    l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;  -- deliberately ignore rating outcome


  END;



  --
  -- J+ , call for Tendering Trips
  -- 15. call the Trip_Action API for tendering selected trips

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'15. call Auto Tender API: x_plan_trips.COUNT', x_plan_trips.COUNT);
    WSH_DEBUG_SV.log(l_module_name,'15. Auto Tender Flag: ', x_context.auto_tender_flag||'-'||x_return_status);
  END IF;

  -- Check if Profile Option is set
  -- TP owns this profile - "MST : Auto-tender on"
  -- Profile Value is cached in x_context.auto_tender_flag
  IF x_context.auto_tender_flag = 'Y' THEN

    DECLARE
      l_trip_action_params  WSH_FTE_INTEGRATION.wsh_trip_action_param_rec;
      l_trip_action_out_rec WSH_FTE_INTEGRATION.wsh_trip_action_out_rec;
      l_trip_id_tab         WSH_UTIL_CORE.id_tab_type;
      l_index                NUMBER;
      l_return_status        VARCHAR2(1);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(32767);
    BEGIN
       l_trip_action_params.action_code := 'TENDER';

       l_index := x_plan_trips.FIRST;
       WHILE l_index IS NOT NULL LOOP
         l_trip_id_tab(l_trip_id_tab.count + 1) := x_plan_trips(l_index).trip_id;
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Trip id-',x_plan_trips(l_index).trip_id);
         END IF;
         l_index := x_plan_trips.NEXT(l_index);
       END LOOP;

       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Trip Count', l_trip_id_tab.count);
       END IF;

       WSH_FTE_INTEGRATION.Trip_Action (
             p_api_version              => 1.0,
             p_init_msg_list            => FND_API.G_TRUE,  --??? or FALSE
             p_trip_id_tab              => l_trip_id_tab,
             p_action_params            => l_trip_action_params,
             p_commit                   => FND_API.G_FALSE,
             x_action_out_rec           => l_trip_action_out_rec,
             x_return_status            => l_return_status,
             x_msg_count                => l_msg_count,
             x_msg_data                 => l_msg_data);

       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'After Trip Action Tender: l_return_status', l_return_status);
       END IF;

      -- If tendering process completed successfully or had a warning
      -- Always Log summarized information
      WSH_UTIL_CORE.Enable_Concurrent_Log_Print;
      -- New Messages to be Added as per DLD
      -- Number of Input = Number of Output --> Success
      IF l_trip_id_tab.count = l_trip_action_out_rec.valid_ids_tab.count THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_ALL_TRIPS_TENDERED');
        FND_MESSAGE.SET_TOKEN('TOTAL_TRIPS',l_trip_id_tab.count);
        FND_MESSAGE.SET_TOKEN('SUCCESS_TRIPS',l_trip_action_out_rec.valid_ids_tab.count);
        WSH_UTIL_CORE.PrintMsg(fnd_message.get);
        -- Message type is set as error to make sure that this gets populated
        -- TP wants to see this log message for all return statuses
        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'Total Input Trips', l_trip_id_tab.count);
          WSH_DEBUG_SV.log(l_module_name, 'Successfully Tendered',l_trip_action_out_rec.valid_ids_tab.count);
        END IF;
      ELSE -- Number of Input <> Number of Output --> Error, partial success
        FND_MESSAGE.SET_NAME('WSH','WSH_PARTIAL_TRIPS_TENDERED');
        FND_MESSAGE.SET_TOKEN('TOTAL_TRIPS',l_trip_id_tab.count);
        FND_MESSAGE.SET_TOKEN('SUCCESS_TRIPS',l_trip_action_out_rec.valid_ids_tab.count);
        WSH_UTIL_CORE.PrintMsg(fnd_message.get);
        wsh_util_core.add_message(l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'Total Input Trips', l_trip_id_tab.count);
          WSH_DEBUG_SV.log(l_module_name, 'Trips could not be Tendered');
        END IF;
      END IF;

      -- Do not return or fail the plan if we cannot Tender.
      IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                           WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
         -- do not set x_return_status as per l_return_status purposely

         stamp_interface_error(
              p_group_id            => x_context.group_id,
              p_entity_table_name   => 'NONE',
              p_entity_interface_id => -1,
              p_message_name        => 'WSH_TP_I_AUTOTENDER', --***** new message required
              x_errors_tab          => x_errors_tab,
              x_return_status       => l_return_status);
      END IF;

      l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;  -- deliberately ignore Auto Tender outcome
      -- this is not set above

    END;

  END IF;  -- profile MST_AUTO_TENDER_ON is set
  -- End of J+ code

  --
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get(
          p_count   => l_msg_count,
          p_data    => l_msg_data,
          p_encoded => fnd_api.g_false);
      --
      stamp_interface_error(
          p_group_id            => x_context.group_id,
          p_entity_table_name   => l_interface_entity,
          p_entity_interface_id => l_interface_id,
          p_message_name        => l_message_name,
          x_errors_tab          => x_errors_tab,
          x_return_status       => l_return_status);
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'FND_API.G_EXC_ERROR exception has occured.', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --



    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get(
         p_count    => l_msg_count,
         p_data     => l_msg_data,
         p_encoded  => fnd_api.g_false);
      --
      stamp_interface_error(
          p_group_id            => x_context.group_id,
          p_entity_table_name   => l_interface_entity,
          p_entity_interface_id => l_interface_id,
          p_message_name        => l_message_name,
          x_errors_tab          => x_errors_tab,
          x_return_status       => l_return_status);
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;


    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TP_RELEASE.RECONCILIATE_PLAN',
                        l_module_name);

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

END reconciliate_plan;





--
--  Procedure:          plan_cleanup
--  Parameters:
--               x_context              context in this session
--               x_plan_details         list of delivery details mapped to interface lines
--               x_plan_deliveries      list of deliveries mapped to interface deliveries
--               x_plan_stops           list of stops mapped to interface stops
--               x_plan_trips           list of trips mapped to interface trips
--               x_trip_unassigns       list of trip unassignments to check for empty stops/trips to delete
--               x_obsoleted_trip_moves list of obsoleted moves that might have empty trips
--                                      belonging to an obsoleted move.
--               x_errors_tab           list of errors to insert into wsh_interface_errors at the end
--               x_return_status        return status
--
--  Description:
--               Clean up the shipping data not used by the plan and log exceptions as needed:
--               1. delete empty deliveries; their trip assignments go into x_trip_unassigns.
--                  We look at the deliveries from which we unassigned the plan lines.
--                    Note: since we start with x_plan_details, we will not find the
--                          trips that are deliberately empty per the plan (as part of
--                          continuous moves) because at this time, the delivery unassignments
--                          and unmatched stops' deletions will already have been performed.
--               2. log exceptions against the lines where their dates do not agree with
--                  their initial pick up stops or ultimate drop off stops' dates.
--               3. clean up trip unassignments that result in empty stops/trips not used by plan,
--                  and empty trips that may belong to obsoleted moves.
--               4. refresh the plan stops' stop_id where they have linked stops, to ensure
--                  that the interface stop records will point to the physical stops.
--               5. update interface tables for details, deliveries, stops and trips
--                  so that TP can identify the TE records mapped.
--               6. Log exceptions against lines, deliveries, and stops that
--                  have their weights and volumes frozen, but may have their
--                  weights and volumes updated.
PROCEDURE plan_cleanup(
           x_context                  IN OUT NOCOPY context_rec_type,
           x_plan_details             IN OUT NOCOPY plan_detail_tab_type,
           x_plan_deliveries          IN OUT NOCOPY plan_delivery_tab_type,
           x_plan_stops               IN OUT NOCOPY plan_stop_tab_type,
           x_plan_trips               IN OUT NOCOPY plan_trip_tab_type,
           x_trip_unassigns           IN OUT NOCOPY trip_unassign_tab_type,
           x_obsoleted_trip_moves     IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.obsoleted_trip_move_tab_type,
           x_errors_tab               IN OUT NOCOPY interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          )
IS
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PLAN_CLEANUP';
  --
  l_debug_on BOOLEAN;

  -- validate whether the delivery has a delivery detail.
  cursor c_empty_dels (p_del_id IN NUMBER) is
  select delivery_detail_id
  from wsh_delivery_assignments_v
  where delivery_id = p_del_id
  and delivery_id is not null
  and rownum = 1;

  -- look up delivery's legs/stops/trips
  cursor c_legs (p_del_id in number) is
  select wdl.delivery_leg_id,
         wdl.pick_up_stop_id,
         wdl.drop_off_stop_id,
         wts.trip_id
  from wsh_delivery_legs wdl,
       wsh_trip_stops wts
  where wdl.delivery_id = p_del_id
  and   wts.stop_id = wdl.pick_up_stop_id;

  l_del_checked_flag VARCHAR2(1);
  l_empty_dels WSH_UTIL_CORE.ID_TAB_TYPE;
  l_org_ids    WSH_UTIL_CORE.ID_TAB_TYPE;
  l_assigned_dels WSH_UTIL_CORE.ID_TAB_TYPE;
  l_empty_stops WSH_UTIL_CORE.ID_TAB_TYPE;
  l_empty_trips WSH_UTIL_CORE.ID_TAB_TYPE;

  -- look up initial pick up stop's departure date for the delivery.
  cursor c_initial_pu_date (p_delivery_id in number,
                            p_init_pu_loc_id in number) is
  select s.planned_departure_date
  from   wsh_trip_stops s,
         wsh_delivery_legs l
  where  s.stop_location_id = p_init_pu_loc_id
  and    s.stop_id = l.pick_up_stop_id
  and    l.delivery_id = p_delivery_id;

  -- look up ultimate drop off stop's arrival date for the delivery.
  cursor c_final_do_date(p_delivery_id in number,
                         p_ult_do_loc_id in number) is
  select s.planned_arrival_date
  from   wsh_trip_stops s,
         wsh_delivery_legs l
  where  s.stop_location_id = p_ult_do_loc_id
  and    s.stop_id = l.drop_off_stop_id
  and    l.delivery_id = p_delivery_id;

  -- look up the primary stop's arrival date for the delivery
  -- when its ultimate drop off location is dummy.
  cursor c_final_do_date_dummy(p_delivery_id in number,
                          p_ult_do_loc_id in number) is
  select s.planned_arrival_date
  from   wsh_trip_stops s,
         wsh_delivery_legs l
  where  s.stop_location_id = p_ult_do_loc_id
  and    s.stop_id = l.drop_off_stop_id
  and    l.delivery_id = p_delivery_id
  and    s.physical_stop_id IS NOT NULL
  UNION
  select phys_s.planned_arrival_date
  from   wsh_trip_stops s,
         wsh_trip_stops phys_s,
         wsh_delivery_legs l
  where  s.stop_location_id = p_ult_do_loc_id
  and    s.stop_id = l.drop_off_stop_id
  and    l.delivery_id = p_delivery_id
  and    phys_s.stop_id = s.physical_stop_id
  ;

  -- look for delivery lines in a delivery where
  -- their earliest pick up date is after the initial pick up date
  -- or their latest drop off date is before the ultimate drop off date.
  cursor c_dd_date_range (p_delivery_id in number, p_initial_pu_date in date, p_final_do_date in date) is
  select wdd.delivery_detail_id,
         wdd.ship_from_location_id,
         wdd.earliest_pickup_date,
         wdd.latest_dropoff_date
  from   wsh_delivery_details wdd,
         wsh_new_deliveries wnd,
         wsh_delivery_assignments_v wda
  where  wdd.delivery_detail_id = wda.delivery_detail_id
  and    wda.delivery_id = wnd.delivery_id
  and    wnd.delivery_id is not null
  and    (wdd.earliest_pickup_date > p_initial_pu_date or
          wdd.latest_dropoff_date  < p_final_do_date)
  and    wnd.delivery_id = p_delivery_id;

  -- check if trip has at least one remaining stop
  CURSOR c_exist_stop(p_trip_id NUMBER) IS
  SELECT wts.stop_id
  FROM WSH_TRIP_STOPS wts
  WHERE wts.trip_id = p_trip_id
  AND rownum = 1;

  -- check if trip has deliveries assigned.
  CURSOR c_exist_dels(p_trip_id NUMBER) IS
  SELECT wdl.delivery_leg_id
  FROM WSH_DELIVERY_LEGS wdl,
       WSH_TRIP_STOPS    wts
  WHERE wdl.pick_up_stop_id = wts.stop_id
  AND   wts.trip_id = p_trip_id
  AND rownum = 1
  UNION
  SELECT wdl.delivery_leg_id
  FROM WSH_DELIVERY_LEGS wdl,
       WSH_TRIP_STOPS    wts
  WHERE wdl.drop_off_stop_id = wts.stop_id
  AND   wts.trip_id = p_trip_id
  AND rownum = 1;

  -- WV changes
  -- Look for stops that have their wv frozen.
  CURSOR c_check_stop_wv_frozen(p_stop_id in NUMBER) IS
  select stop_location_id
  from wsh_trip_stops
  where wv_frozen_flag = 'Y'
  and stop_id = p_stop_id;

  -- CM Cleanup
  -- Look for stops on this trip
  CURSOR c_trip_stops(p_trip_id in NUMBER) IS
  SELECT stop_id
  FROM wsh_trip_stops
  WHERE trip_id = p_trip_id;


  -- physical stop lookup to use primary stop
  CURSOR c_lookup_physical_stop(p_stop_id IN NUMBER) IS
  SELECT NVL(wts.physical_stop_id, wts.stop_id)
  FROM   WSH_TRIP_STOPS wts
  WHERE  wts.stop_id = p_stop_id;


  l_location_id NUMBER;

  l_initial_pu_date DATE;
  l_final_do_date DATE;
  l_delivery_name VARCHAR2(30);
  l_msg VARCHAR2(2000);
  l_exception_error_message  VARCHAR2(2000) := NULL;
  l_exception_msg_count NUMBER;
  l_dummy_exception_id NUMBER;
  l_exception_msg_data VARCHAR2(4000) := NULL;
  l_return_status      VARCHAR2(1);
  l_temp_id            NUMBER;
  i                    NUMBER;
  j                    NUMBER;
  l_found              BOOLEAN;


  l_message_name       VARCHAR2(30);
  l_msg_data           VARCHAR2(32767);
  l_msg_count          NUMBER;

  l_del_attrs        WSH_NEW_DELIVERIES_PVT.delivery_attr_tbl_type;
  l_del_action_prms  WSH_DELIVERIES_GRP.action_parameters_rectype;
  l_del_action_rec   WSH_DELIVERIES_GRP.delivery_action_out_rec_type;
  l_del_defaults     WSH_DELIVERIES_GRP.default_parameters_rectype;

  l_stop_attrs       WSH_TRIP_STOPS_PVT.stop_attr_tbl_type;
  l_stop_action_prms WSH_TRIP_STOPS_GRP.action_parameters_rectype;
  l_stop_action_rec  WSH_TRIP_STOPS_GRP.StopActionOutRecType;
  l_stop_defaults    WSH_TRIP_STOPS_GRP.default_parameters_rectype;

  l_trip_attrs       WSH_TRIPS_PVT.trip_attr_tbl_type;
  l_trip_action_prms WSH_TRIPS_GRP.action_parameters_rectype;
  l_trip_in_rec      WSH_TRIPS_GRP.TripInRecType;
  l_trip_defaults    WSH_TRIPS_GRP.default_parameters_rectype;
  l_trip_out_rec     WSH_TRIPS_GRP.tripActionOutRecType;
  l_trip_out_tab     WSH_TRIPS_GRP.trip_out_tab_type;

  WSH_EMPTY_TRIP EXCEPTION;


  --
  --  Procedure:         examine_stop
  --  Parameters:
  --             p_stop_id             stop_id to examine
  --             p_trip_id             stop's trip_id
  --
  --  Description:
  --       Updates l_empty_stops and l_empty_trips:
  --         If this stop is empty, it is added to l_empty_stops.
  --         If the trip is new, add it to l_empty_trips to be examined later.
  PROCEDURE examine_stop(p_stop_id IN NUMBER,
                         p_trip_id IN NUMBER) IS
    -- check if stop has any delivery to pick up or drop off
    CURSOR c_stop_dels(p_stop_id NUMBER) IS
    SELECT wdl.delivery_leg_id
    FROM WSH_DELIVERY_LEGS wdl
    WHERE wdl.pick_up_stop_id = p_stop_id
    AND rownum = 1
    UNION
    SELECT wdl.delivery_leg_id
    FROM WSH_DELIVERY_LEGS wdl
    WHERE  wdl.drop_off_stop_id = p_stop_id
    AND rownum = 1;

    l_temp_id NUMBER;
    j       NUMBER;
    l_found BOOLEAN;
  BEGIN
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'entering examine_stop: p_stop_id', p_stop_id);
      WSH_DEBUG_SV.log(l_module_name, 'p_trip_id', p_trip_id);
    END IF;

    -- check that this stop is not already in list of empty stops
    IF l_empty_stops.COUNT = 0 THEN
      j := 1;
      l_found := FALSE;
    ELSE
      l_found := FALSE;
      j := l_empty_stops.FIRST;
      WHILE j IS NOT NULL AND NOT l_found LOOP
        l_found := (l_empty_stops(j) = p_stop_id);
        j := l_empty_stops.NEXT(j);
      END LOOP;
    END IF;

    IF NOT l_found THEN
      -- check whether this stop is empty
      OPEN c_stop_dels(p_stop_id);
      FETCH c_stop_dels INTO l_temp_id;
      l_found := c_stop_dels%FOUND;
      CLOSE c_stop_dels;

      IF NOT l_found THEN
        -- this stop is empty.
        IF l_empty_stops.COUNT = 0 THEN
          l_empty_stops(1) := p_stop_id;
        ELSE
          l_empty_stops( l_empty_stops.LAST+1 ) := p_stop_id;
        END IF;

        -- add trip to list of possibly empty trips if not there already
        IF l_empty_trips.COUNT = 0 THEN
          l_empty_trips(1) := x_trip_unassigns(i).trip_id;
        ELSE
          j := l_empty_trips.FIRST;
          WHILE j IS NOT NULL AND NOT l_found LOOP
            l_found := (l_empty_trips(j) = p_trip_id);
            j := l_empty_trips.NEXT(j);
          END LOOP;
          IF NOT l_found THEN
            j := l_empty_trips.LAST + 1;
            l_empty_trips(j) := p_trip_id;
          END IF;
        END IF;
      END IF;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'exiting examine_stop');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF c_stop_dels%ISOPEN THEN
         CLOSE  c_stop_dels;
      END IF;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'exiting examine_stop exception handler');
      END IF;
      RAISE;
  END examine_stop;


BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;
  --
  --

  -- Bug 3555487 initialize message stack for each major action point.
  FND_MSG_PUB.initialize;


  --
  -- 1. DELETE EMPTY DELIVERIES FROM WHICH PLAN LINES ARE UNASSIGNED.
  --    If empty deliveries are assigned to trips, add them to x_trip_unassigns.
  --

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name, '1. purge empty deliveries');
  END IF;

  IF x_plan_details.COUNT > 0 THEN
    -- Find distinct empty deliveries and add them to l_empty_dels.
    --   We use l_assigned_dels to list the deliveries that we know have lines,
    --   so we do not have to keep querying them.

    FOR i in x_plan_details.FIRST.. x_plan_details.LAST LOOP
        l_del_checked_flag := 'N';
        IF x_plan_details(i).current_delivery_id <>
           x_plan_deliveries(x_plan_details(i).target_delivery_index).delivery_id
        THEN

           FOR j in 1.. l_empty_dels.count LOOP
             IF l_empty_dels(j) =  x_plan_details(i).current_delivery_id THEN
                l_del_checked_flag := 'Y';
                EXIT;
             END IF;
           END LOOP;

           IF l_del_checked_flag <> 'Y' THEN
              FOR j in 1.. l_assigned_dels.count LOOP
                IF l_assigned_dels(j) =  x_plan_details(i).current_delivery_id THEN
                   l_del_checked_flag := 'Y';
                   EXIT;
                END IF;
              END LOOP;
           END IF;

           IF l_del_checked_flag <> 'Y' THEN
              OPEN c_empty_dels (x_plan_details(i).current_delivery_id);
              FETCH c_empty_dels INTO l_temp_id;
              IF c_empty_dels%NOTFOUND THEN
                 l_empty_dels(l_empty_dels.count + 1) := x_plan_details(i).current_delivery_id;
                 l_org_ids(l_empty_dels.LAST)         := x_plan_details(i).organization_id;
              ELSE
                 l_assigned_dels(l_assigned_dels.count + 1) := x_plan_details(i).current_delivery_id;
              END IF;
              CLOSE c_empty_dels;
           END IF;

        END IF;

    END LOOP;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'Compiled lists: l_empty_dels.COUNT', l_empty_dels.COUNT);
    WSH_DEBUG_SV.log(l_module_name, 'l_assigned_dels.COUNT', l_assigned_dels.COUNT);
  END IF;

  --
  -- Go through the list of empty deliveries to unassign from trips and populate x_trip_unassigns.
  --

  l_del_action_prms.caller      := 'WSH_TP_RELEASE';
  l_del_action_prms.action_code := 'UNASSIGN-TRIP';

  FOR i in 1 .. l_empty_dels.count LOOP -- {

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'looping empty delivery', l_empty_dels(i));
    END IF;

    FOR leg IN c_legs( l_empty_dels(i) ) LOOP

        l_del_attrs(1).delivery_id     := l_empty_dels(i);
        l_del_attrs(1).organization_id := l_org_ids(i);
        l_del_action_prms.trip_id := leg.trip_id;

        WSH_DELIVERIES_GRP.delivery_action(
          p_api_version_number => 1.0,
          p_init_msg_list      => FND_API.G_TRUE,
          p_commit             => FND_API.G_FALSE,
          p_action_prms        => l_del_action_prms,
          p_rec_attr_tab       => l_del_attrs,
          x_delivery_out_rec   => l_del_action_rec,
          x_defaults_rec       => l_del_defaults,
          x_return_status      => l_return_status,
          x_msg_count          => l_msg_count,
          x_msg_data           => l_msg_data);
        -- ignore return status

        IF x_trip_unassigns.COUNT = 0 THEN
          j := 1;
        ELSE
          j := x_trip_unassigns.LAST + 1;
        END IF;
        x_trip_unassigns(j).delivery_leg_id := leg.delivery_leg_id;
        x_trip_unassigns(j).trip_id         := leg.trip_id;
        x_trip_unassigns(j).pickup_stop_id  := leg.pick_up_stop_id;
        x_trip_unassigns(j).dropoff_stop_id := leg.drop_off_stop_id;
        x_trip_unassigns(j).delivery_id     := l_empty_dels(i);
        x_trip_unassigns(j).organization_id := l_org_ids(i);

        -- WV changes
        -- Add the stops with WV frozen that have deliveries unassigned from, to
        -- the list of stops to log wv exceptions.

        IF NOT x_context.wv_exception_stops.exists(x_trip_unassigns(j).pickup_stop_id) THEN

           l_location_id := NULL;
           OPEN c_check_stop_wv_frozen(x_trip_unassigns(j).pickup_stop_id);
           FETCH c_check_stop_wv_frozen INTO l_location_id;
           CLOSE c_check_stop_wv_frozen;

           IF l_location_id IS NOT NULL THEN
              x_context.wv_exception_stops(x_trip_unassigns(j).pickup_stop_id) :=  l_location_id;
              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'Log WV exception against stop', x_trip_unassigns(j).pickup_stop_id);
              END IF;
           END IF;
        END IF;

        IF NOT x_context.wv_exception_stops.exists(x_trip_unassigns(j).dropoff_stop_id) THEN

           l_location_id := NULL;
           OPEN c_check_stop_wv_frozen(x_trip_unassigns(j).dropoff_stop_id);
           FETCH c_check_stop_wv_frozen INTO l_location_id;
           CLOSE c_check_stop_wv_frozen;

           IF l_location_id IS NOT NULL THEN
              x_context.wv_exception_stops(x_trip_unassigns(j).dropoff_stop_id) :=  l_location_id;
              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'Log WV exception against stop', x_trip_unassigns(j).dropoff_stop_id);
              END IF;
           END IF;
        END IF;

        -- WV changes
        -- Remove the empty deliveries (to be deleted) from
        -- from the WV exceptions list.

        IF x_context.wv_exception_dels.exists(l_empty_dels(i)) THEN
           x_context.wv_exception_dels.delete(l_empty_dels(i));
        END IF;



    END LOOP;


  END LOOP;

  -- Delete the list of empty deliveries.

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'before DELETE: l_empty_dels.COUNT', l_empty_dels.COUNT);
  END IF;
  WSH_UTIL_CORE.Delete(p_type => 'DLVY',
                       p_rows => l_empty_dels,
                       x_return_status => l_return_status);
  -- ignore return status

  --
  -- 2. LOG EXCEPTIONS IF DATES ARE OUT OF SYNC.
  --

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name, '2. log exceptions if dates are out of sync');
  END IF;

  --
  -- Go through list of deliveries in plan comparing the dates and log
  -- exceptions in the following cases.
  -- dd.earliest_pickup_date > initial stop.planned_departure_date or
  -- dd.latest_drop_off_date < final stop.planned_arrival_date.
  --

  FOR i in 1..x_plan_deliveries.count LOOP

      OPEN c_initial_pu_date(x_plan_deliveries(i).delivery_id,
                             x_plan_deliveries(i).initial_pickup_location_id);
      FETCH c_initial_pu_date INTO l_initial_pu_date;
      CLOSE c_initial_pu_date;

      IF x_plan_deliveries(i).physical_ultimate_do_loc_id IS NULL THEN
        OPEN c_final_do_date(x_plan_deliveries(i).delivery_id,
                             x_plan_deliveries(i).ultimate_dropoff_location_id);
        FETCH c_final_do_date INTO l_final_do_date;
        CLOSE c_final_do_date;
      ELSE
        OPEN c_final_do_date_dummy(x_plan_deliveries(i).delivery_id,
                             x_plan_deliveries(i).ultimate_dropoff_location_id);
        FETCH c_final_do_date_dummy INTO l_final_do_date;
        CLOSE c_final_do_date_dummy;
      END IF;

      l_delivery_name := NULL;


      FOR dd IN c_dd_date_range(x_plan_deliveries(i).delivery_id, l_initial_pu_date, l_final_do_date) LOOP

         IF dd.earliest_pickup_date > l_initial_pu_date THEN
            -- Log exception.
            IF l_delivery_name is null THEN
               l_delivery_name := wsh_new_deliveries_pvt.get_name(x_plan_deliveries(i).delivery_id);
            END IF;
            FND_MESSAGE.SET_NAME('WSH', 'WSH_TP_EARLY_PICKUP');
            FND_MESSAGE.SET_TOKEN('SHIP_DATE',FND_DATE.DATE_TO_DISPLAYDT(l_initial_pu_date));
            FND_MESSAGE.SET_TOKEN('PICK_DATE',FND_DATE.DATE_TO_DISPLAYDT(dd.earliest_pickup_date));
            FND_MESSAGE.SET_TOKEN('DETAIL_ID',dd.delivery_detail_id);
            FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',l_delivery_name);

            l_msg := FND_MESSAGE.GET;

            l_dummy_exception_id := NULL;

            wsh_xc_util.log_exception(p_api_version => 1.0,
               x_return_status => l_return_status,
               x_msg_count => l_exception_msg_count,
               x_msg_data => l_exception_msg_data,
               x_exception_id => l_dummy_exception_id,
               p_exception_location_id => dd.ship_from_location_id,
               p_logged_at_location_id => dd.ship_from_location_id,
               p_logging_entity => 'SHIPPER',
               p_logging_entity_id => FND_GLOBAL.USER_ID,
               p_exception_name => 'WSH_TP_EARLY_PICKUP',
               p_message => l_msg,
               p_delivery_detail_id => dd.delivery_detail_id,
               p_error_message => l_exception_error_message);
         END IF;

         IF dd.latest_dropoff_date < l_final_do_date THEN
            -- Log exception.
            IF l_delivery_name is null THEN
               l_delivery_name := wsh_new_deliveries_pvt.get_name(x_plan_deliveries(i).delivery_id);
            END IF;
            FND_MESSAGE.SET_NAME('WSH', 'WSH_TP_LATE_DROPOFF');
            FND_MESSAGE.SET_TOKEN('DROP_DATE',FND_DATE.DATE_TO_DISPLAYDT(l_final_do_date));
            FND_MESSAGE.SET_TOKEN('DELIVER_DATE',FND_DATE.DATE_TO_DISPLAYDT(dd.latest_dropoff_date));
            FND_MESSAGE.SET_TOKEN('DETAIL_ID',dd.delivery_detail_id);
            FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',l_delivery_name);

            l_msg := FND_MESSAGE.GET;

            l_dummy_exception_id := NULL;

            wsh_xc_util.log_exception(p_api_version => 1.0,
               x_return_status => l_return_status,
               x_msg_count => l_exception_msg_count,
               x_msg_data => l_exception_msg_data,
               x_exception_id => l_dummy_exception_id,
               p_exception_location_id => dd.ship_from_location_id,
               p_logged_at_location_id => dd.ship_from_location_id,
               p_logging_entity => 'SHIPPER',
               p_logging_entity_id => FND_GLOBAL.USER_ID,
               p_exception_name => 'WSH_TP_LATE_DROPOFF',
               p_message => l_msg,
               p_delivery_detail_id => dd.delivery_detail_id,
               p_error_message => l_exception_error_message);
         END IF;
      END LOOP;

  END LOOP;

  --
  --  3. clean up trip unassignments that result in empty stops/trips not used by plan.
  --

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name, '3. purge empty stops/trips');
  END IF;

  -- Add the obsoleted move trips to trip unassignment.
  -- Leave the pickup and dropoff stops null
  IF x_obsoleted_trip_moves.COUNT > 0 THEN
    FOR i in x_obsoleted_trip_moves.FIRST .. x_obsoleted_trip_moves.LAST LOOP

      IF   x_obsoleted_trip_moves(i).trip_id IS NOT NULL THEN

           x_trip_unassigns(x_trip_unassigns.count + 1).trip_id := x_obsoleted_trip_moves(i).trip_id;

      END IF;

    END LOOP;
  END IF;

  IF x_trip_unassigns.COUNT > 0 THEN

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Clean up trip unassignments: x_trip_unassigns.COUNT', x_trip_unassigns.COUNT);
    END IF;

    l_empty_stops.DELETE;
    l_empty_trips.DELETE;

    i := x_trip_unassigns.FIRST;
    WHILE i IS NOT NULL LOOP

      -- If unassignment is due to matching plan trips, the trip is part of the plan.
      -- Therefore, we look at only the trip unassignments
      -- that involve stops/trips not part of the plan.
      -- We want to track trip unassignments created by matching the delivery's legs to the plan.

      IF x_trip_unassigns(i).trip_index IS NULL THEN

        -- make sure trip is not mapped to plan
        -- (if trip is in the plan, its stops would be cleaned up as needed.)
        j := x_plan_trips.FIRST;
        l_found := (x_plan_trips(j).trip_id = x_trip_unassigns(i).trip_id);
        WHILE j IS NOT NULL AND NOT l_found LOOP
          l_found := (x_plan_trips(j).trip_id = x_trip_unassigns(i).trip_id);
          IF NOT l_found THEN
            j := x_plan_trips.NEXT(j);
          END IF;
        END LOOP;

	IF NOT l_found THEN
           -- trip is not in plan; find out if its stops should be deleted.

           -- If the pickup and drop off stops are populated, then
           -- trips are not from obsoleted moves.

           IF x_trip_unassigns(i).pickup_stop_id IS NOT NULL
           OR x_trip_unassigns(i).dropoff_stop_id IS NOT NULL THEN

              examine_stop(p_stop_id => x_trip_unassigns(i).pickup_stop_id,
                           p_trip_id => x_trip_unassigns(i).trip_id);

              examine_stop(p_stop_id => x_trip_unassigns(i).dropoff_stop_id,
                           p_trip_id => x_trip_unassigns(i).trip_id);

            ELSE

              FOR trip in c_trip_stops(x_trip_unassigns(i).trip_id) LOOP

                  BEGIN
                    -- Lock the stop
                    WSH_TRIP_STOPS_PVT.lock_trip_stop_no_compare(trip.stop_id);
                    examine_stop(p_stop_id => trip.stop_id,
                                 p_trip_id => x_trip_unassigns(i).trip_id);
                  EXCEPTION
                    WHEN OTHERS THEN
                    -- Do nothing. If the stop has been locked by another
                    -- process, unlikely that it will need to be deleted.

                    IF l_debug_on THEN
                       WSH_DEBUG_SV.log(l_module_name, 'Could not lock Stop: ', trip.stop_id);
                    END IF;
                  END;

              END LOOP;

            END IF;

        END IF;

      END IF;

      i := x_trip_unassigns.NEXT(i);
    END LOOP;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'l_empty_stops.COUNT', l_empty_stops.COUNT);
      WSH_DEBUG_SV.log(l_module_name, 'l_empty_trips.COUNT', l_empty_trips.COUNT);
    END IF;

    IF l_empty_stops.COUNT > 0 THEN

      -- A. delete empty stops

      i := l_empty_stops.FIRST;
      j := 0;
      WHILE i IS NOT NULL LOOP
       j := j + 1;
       l_stop_attrs(j).stop_id := l_empty_stops(i);

        -- WV changes
        -- Remove the empty stops (to be deleted) from
        -- from the WV exceptions list.

        IF x_context.wv_exception_stops.exists(l_empty_stops(i)) THEN
           x_context.wv_exception_stops.delete(l_empty_stops(i));
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Do not Log WV exception against stop', l_empty_stops(i));
           END IF;
        END IF;


       i:= l_empty_stops.NEXT(i);
      END LOOP;

      l_stop_action_prms.caller      := 'WSH_TP_RELEASE';
      l_stop_action_prms.action_code := 'DELETE';

      WSH_TRIP_STOPS_GRP.stop_action(
        p_api_version_number => 1.0,
        p_init_msg_list      => FND_API.G_TRUE,
        p_commit             => FND_API.G_FALSE,
        p_action_prms        => l_stop_action_prms,
        p_rec_attr_tab       => l_stop_attrs,
        x_stop_out_rec       => l_stop_action_rec,
        x_def_rec            => l_stop_defaults,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data);

      -- discard return status here; errors deleting stops will not fail the plan.
      -- sometimes, deleting a stop will fail but deleting its trip will succeed
      -- (for example, FTE validates that a trip has at least 2 stops).

      -- B. delete trips that have no stops or deliveries assigned.

      i := l_empty_trips.FIRST;
      j := 0;
      WHILE i IS NOT NULL LOOP
        OPEN c_exist_stop(l_empty_trips(i));
        FETCH c_exist_stop INTO l_temp_id;
        IF c_exist_stop%NOTFOUND THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'no stops for trip', l_empty_trips(i));
          END IF;
          j := j + 1;
          l_trip_attrs(j).trip_id := l_empty_trips(i);
        ELSE
          OPEN c_exist_dels(l_empty_trips(i));
          FETCH c_exist_dels INTO l_temp_id;
          IF c_exist_dels%NOTFOUND THEN
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'no deliveries for trip', l_empty_trips(i));
            END IF;
            j := j + 1;
            l_trip_attrs(j).trip_id := l_empty_trips(i);
          END IF;
          CLOSE c_exist_dels;
        END IF;
        CLOSE c_exist_stop;

        i := l_empty_trips.NEXT(i);
      END LOOP;

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'l_trip_attrs.COUNT', l_trip_attrs.COUNT);
      END IF;

      IF l_trip_attrs.COUNT > 0 THEN

        l_trip_action_prms.caller      := 'WSH_TP_RELEASE';
        l_trip_action_prms.action_code := 'DELETE';

        wsh_trips_grp.trip_action(
           p_api_version_number =>  1.0,
           p_init_msg_list      =>  FND_API.G_TRUE,
           p_commit             =>  FND_API.G_FALSE,
           p_action_prms        =>  l_trip_action_prms,
           p_rec_attr_tab       =>  l_trip_attrs,
           x_trip_out_rec       =>  l_trip_out_rec,
           x_def_rec            =>  l_trip_defaults,
           x_return_status      =>  l_return_status,
           x_msg_count          =>  l_msg_count,
           x_msg_data           =>  l_msg_data);

        -- discard return status here; errors deleting trips will not fail the plan.

      END IF;

    END IF;

  END IF;


  --
  --  4. refresh the plan stops' stop_id where they have linked stops, to ensure
  --     that the interface stop records will point to the physical stops.
  --

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name, '4. refresh physical stop ids');
    WSH_DEBUG_SV.log(l_module_name, 'x_context.linked_trip_count', x_context.linked_trip_count);
  END IF;

  IF x_context.linked_trip_count > 0 THEN
    DECLARE
      l_trip_count NUMBER;
      l_trip_index NUMBER;

      l_stop_count NUMBER;
      l_stop_index NUMBER;
      l_stop_id    NUMBER;
    BEGIN
      l_trip_count := x_context.linked_trip_count;
      l_trip_index := x_plan_trips.FIRST;

      WHILE l_trip_count > 0 LOOP

         IF x_plan_trips(l_trip_index).linked_stop_count > 0 THEN

           l_stop_count := x_plan_trips(l_trip_index).linked_stop_count;
           l_stop_index := x_plan_trips(l_trip_index).stop_base_index;

           WHILE l_stop_count > 0 LOOP
              IF     x_plan_stops(l_stop_index).internal_do_count > 0
                 AND x_plan_stops(l_stop_index).external_pd_count > 0 THEN

               OPEN c_lookup_physical_stop(x_plan_stops(l_stop_index).stop_id);
               FETCH c_lookup_physical_stop INTO l_stop_id;
               IF c_lookup_physical_stop%FOUND
                  AND l_stop_id <> x_plan_stops(l_stop_index).stop_id  THEN
                 IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name, 'physical stop('||l_stop_index||') looked up',
                                    x_plan_stops(l_stop_index).stop_id || ' -> ' || l_stop_id);
                 END IF;
                 x_plan_stops(l_stop_index).stop_id := l_stop_id;
               END IF;
               CLOSE c_lookup_physical_stop;

               l_stop_count := l_stop_count - 1;
              END IF;

            l_stop_index := x_plan_stops.NEXT(l_stop_index);
           END LOOP;

           l_trip_count := l_trip_count - 1;
         END IF;

         l_trip_index := x_plan_trips.NEXT(l_trip_index);
      END LOOP;
    END;
  END IF;


  --
  --  5. update interface tables for details, deliveries, stops and trips
  --     so that TP can identify the TE records mapped.
  --

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name, '5. update interface tables');
  END IF;


  DECLARE
    l_interface_ids  WSH_UTIL_CORE.id_tab_type;
    l_ids            WSH_UTIL_CORE.id_tab_type;
    l_qtys           WSH_UTIL_CORE.id_tab_type;
    l_p_index          NUMBER;
    l_i_index          NUMBER;
  BEGIN

    -- update trips
    l_i_index := 0;
    l_p_index := x_plan_trips.FIRST;
    WHILE l_p_index IS NOT NULL LOOP
      l_i_index := l_i_index + 1;
      l_interface_ids(l_i_index) := x_plan_trips(l_p_index).trip_interface_id;
      l_ids(l_i_index)           := x_plan_trips(l_p_index).trip_id;
      l_p_index := x_plan_trips.NEXT(l_p_index);
    END LOOP;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Bulk update trips: count', l_interface_ids.COUNT);
    END IF;

    FORALL i in 1..l_interface_ids.count
    UPDATE wsh_trips_interface
    SET trip_id = l_ids(i)
    WHERE trip_interface_id = l_interface_ids(i);

    -- update stops
    l_interface_ids.DELETE;
    l_ids.DELETE;
    l_i_index := 0;
    l_p_index := x_plan_stops.FIRST;
    WHILE l_p_index IS NOT NULL LOOP
      l_i_index := l_i_index + 1;
      l_interface_ids(l_i_index) := x_plan_stops(l_p_index).stop_interface_id;
      l_ids(l_i_index)           := x_plan_stops(l_p_index).stop_id;
      l_p_index := x_plan_stops.NEXT(l_p_index);
    END LOOP;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Bulk update stops: count', l_interface_ids.COUNT);
    END IF;

    FORALL i in 1..l_interface_ids.count
    UPDATE wsh_trip_stops_interface
    SET stop_id = l_ids(i)
    WHERE stop_interface_id = l_interface_ids(i);



    -- update deliveries
    l_interface_ids.DELETE;
    l_ids.DELETE;
    l_i_index := 0;
    l_p_index := x_plan_deliveries.FIRST;
    WHILE l_p_index IS NOT NULL LOOP
      l_i_index := l_i_index + 1;
      l_interface_ids(l_i_index) := x_plan_deliveries(l_p_index).del_interface_id;
      l_ids(l_i_index)           := x_plan_deliveries(l_p_index).delivery_id;
      l_p_index := x_plan_deliveries.NEXT(l_p_index);
    END LOOP;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Bulk update deliveries: count', l_interface_ids.COUNT);
    END IF;

    FORALL i in 1..l_interface_ids.count
    UPDATE wsh_new_del_interface
    SET delivery_id = l_ids(i)
    WHERE delivery_interface_id = l_interface_ids(i);



    -- update delivery details
    --  question: what happens if one interface line is mapped to multiple details?
    --    answer: TE, TP PM and Development had discussed this question; for now,
    --            the interface line will get one of these details' IDs because the
    --            interface delivery gets their delivery_id which will be first choice
    --            in the plan's next re-release.
    l_interface_ids.DELETE;
    l_ids.DELETE;
    l_i_index := 0;
    l_p_index := x_plan_details.FIRST;
    WHILE l_p_index IS NOT NULL LOOP
      l_i_index := l_i_index + 1;
      l_interface_ids(l_i_index) := x_plan_details(l_p_index).dd_interface_id;
      l_ids(l_i_index)           := x_plan_details(l_p_index).delivery_detail_id;
      l_qtys(l_i_index)          := x_plan_details(l_p_index).mapped_quantity;
      l_p_index := x_plan_details.NEXT(l_p_index);
    END LOOP;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Bulk update details: count', l_interface_ids.COUNT);
    END IF;

    FORALL i in 1..l_interface_ids.count
    UPDATE wsh_del_details_interface
    SET delivery_detail_id = l_ids(i),
        requested_quantity = l_qtys(i)
    WHERE delivery_detail_interface_id = l_interface_ids(i);



  END;

  --
  -- 6. Log exceptions against lines, deliveries, and stops that
  --    have their weights and volumes frozen, but may have their
  --    weights and volumes updated.
  --    WV changes
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name, '6.  Log exceptions against lines, deliveries, and stops');
  END IF;

  Log_WV_Exceptions(
          p_details_loc_tab => x_context.wv_exception_details,
          p_deliveries_loc_tab => x_context.wv_exception_dels,
          p_stops_loc_tab => x_context.wv_exception_stops,
          x_return_status => x_return_status);

  x_context.wv_exception_details.delete;
  x_context.wv_exception_dels.delete;
  x_context.wv_exception_stops.delete;

  --
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION

    WHEN OTHERS THEN
      IF c_empty_dels%isopen THEN
         CLOSE  c_empty_dels;
      END IF;
      IF c_legs%isopen THEN
         CLOSE  c_legs;
      END IF;
      IF c_initial_pu_date%ISOPEN THEN
         CLOSE c_initial_pu_date;
      END IF;
      IF c_final_do_date%ISOPEN THEN
         CLOSE c_final_do_date;
      END IF;
      IF c_final_do_date_dummy%ISOPEN THEN
         CLOSE c_final_do_date_dummy;
      END IF;
      IF c_dd_date_range%ISOPEN THEN
         CLOSE c_dd_date_range;
      END IF;
      IF c_exist_stop%ISOPEN THEN
         CLOSE  c_exist_stop;
      END IF;
      IF c_exist_dels%ISOPEN THEN
         CLOSE  c_exist_dels;
      END IF;
      IF c_lookup_physical_stop%ISOPEN THEN
         CLOSE c_lookup_physical_stop;
      END IF;

      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TP_RELEASE.PLAN_CLEANUP',
                        l_module_name);

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END plan_cleanup;




--
--  Procedure:          attributes_match
--  Parameters:
--               x_attributes          reference attribute values
--               x_values              line's attribute values
--
--  Description:
--               Returns TRUE if the grouping attributes match (for inbound
--               and outbound).
--               This is called by generate_lock_candidates.
--
FUNCTION attributes_match(
           x_attributes IN plan_detail_rec_type,
           x_values     IN c_map_lines%ROWTYPE)
RETURN BOOLEAN
IS
  l_module_name   CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ATTRIBUTES_MATCH';
  l_debug_on      BOOLEAN;
  --
  l_attr_tab         WSH_DELIVERY_AUTOCREATE.grp_attr_tab_type;
  l_action_rec       WSH_DELIVERY_AUTOCREATE.action_rec_type;
  l_target_rec       WSH_DELIVERY_AUTOCREATE.grp_attr_rec_type;
  l_group_tab        WSH_DELIVERY_AUTOCREATE.grp_attr_tab_type;
  l_matched_entities WSH_UTIL_CORE.id_tab_type;
  l_out_rec          WSH_DELIVERY_AUTOCREATE.out_rec_type;
  l_return_status    VARCHAR2(1);

  l_match_flag       BOOLEAN := FALSE;

BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name, 'x_attributes.line_direction',             x_attributes.line_direction);
    WSH_DEBUG_SV.log(l_module_name, 'x_attributes.ship_from_location_id',      x_attributes.ship_from_location_id);
    WSH_DEBUG_SV.log(l_module_name, 'x_attributes.ship_to_location_id',        x_attributes.ship_to_location_id);
    WSH_DEBUG_SV.log(l_module_name, 'x_attributes.organization_id',            x_attributes.organization_id);
    WSH_DEBUG_SV.log(l_module_name, 'x_attributes.customer_id',                x_attributes.customer_id);
    WSH_DEBUG_SV.log(l_module_name, 'x_attributes.freight_terms_code',         x_attributes.freight_terms_code);
    WSH_DEBUG_SV.log(l_module_name, 'x_attributes.intmed_ship_to_location_id', x_attributes.intmed_ship_to_location_id);
    WSH_DEBUG_SV.log(l_module_name, 'x_attributes.ship_method_code',           x_attributes.ship_method_code);
    WSH_DEBUG_SV.log(l_module_name, 'x_attributes.mode_of_transport',          x_attributes.mode_of_transport);
    WSH_DEBUG_SV.log(l_module_name, 'x_attributes.service_level',              x_attributes.service_level);
    WSH_DEBUG_SV.log(l_module_name, 'x_attributes.carrier_id',                 x_attributes.carrier_id);
    WSH_DEBUG_SV.log(l_module_name, 'x_attributes.shipping_control',           x_attributes.shipping_control);
    WSH_DEBUG_SV.log(l_module_name, 'x_attributes.vendor_id',                  x_attributes.vendor_id);
    WSH_DEBUG_SV.log(l_module_name, 'x_attributes.party_id',                   x_attributes.party_id);
    WSH_DEBUG_SV.log(l_module_name, 'x_values.line_direction',             x_values.line_direction);
    WSH_DEBUG_SV.log(l_module_name, 'x_values.ship_from_location_id',      x_values.ship_from_location_id);
    WSH_DEBUG_SV.log(l_module_name, 'x_values.ship_to_location_id',        x_values.ship_to_location_id);
    WSH_DEBUG_SV.log(l_module_name, 'x_values.organization_id',            x_values.organization_id);
    WSH_DEBUG_SV.log(l_module_name, 'x_values.customer_id',                x_values.customer_id);
    WSH_DEBUG_SV.log(l_module_name, 'x_values.freight_terms_code',         x_values.freight_terms_code);
    WSH_DEBUG_SV.log(l_module_name, 'x_values.intmed_ship_to_location_id', x_values.intmed_ship_to_location_id);
    WSH_DEBUG_SV.log(l_module_name, 'x_values.ship_method_code',           x_values.ship_method_code);
    WSH_DEBUG_SV.log(l_module_name, 'x_values.mode_of_transport',          x_values.mode_of_transport);
    WSH_DEBUG_SV.log(l_module_name, 'x_values.service_level',              x_values.service_level);
    WSH_DEBUG_SV.log(l_module_name, 'x_values.carrier_id',                 x_values.carrier_id);
    WSH_DEBUG_SV.log(l_module_name, 'x_values.shipping_control',           x_values.shipping_control);
    WSH_DEBUG_SV.log(l_module_name, 'x_values.vendor_id',                  x_values.vendor_id);
    WSH_DEBUG_SV.log(l_module_name, 'x_values.party_id',                   x_values.party_id);
  END IF;


  l_action_rec.caller                 := 'WSH_TP_RELEASE';
  l_action_rec.action                 := 'MATCH_GROUPS';
  l_action_rec.group_by_header_flag   := 'N';
  l_action_rec.group_by_delivery_flag := 'N';
  l_action_rec.output_format_type     := NULL;
  l_action_rec.output_entity_type     := NULL;
  l_action_rec.check_single_grp       := 'Y';

  l_attr_tab(1).entity_id                  := NULL;
  l_attr_tab(1).entity_type                := 'DLVB';
  l_attr_tab(1).ship_to_location_id        := x_attributes.ship_to_location_id;
  l_attr_tab(1).ship_from_location_id      := x_attributes.ship_from_location_id;
  l_attr_tab(1).customer_id                := x_attributes.customer_id;
  l_attr_tab(1).intmed_ship_to_location_id := x_attributes.intmed_ship_to_location_id;
  l_attr_tab(1).fob_code                   := x_attributes.fob_code;
  l_attr_tab(1).freight_terms_code         := x_attributes.freight_terms_code;
  l_attr_tab(1).ship_method_code           := x_attributes.ship_method_code;
  l_attr_tab(1).carrier_id                 := x_attributes.carrier_id;
  l_attr_tab(1).service_level              := x_attributes.service_level;
  l_attr_tab(1).mode_of_transport          := x_attributes.mode_of_transport;
  l_attr_tab(1).source_header_id           := x_attributes.source_header_id;
  l_attr_tab(1).organization_id            := x_attributes.organization_id;
  l_attr_tab(1).ignore_for_planning        := 'N';
  l_attr_tab(1).line_direction             := x_attributes.line_direction;
  l_attr_tab(1).shipping_control           := x_attributes.shipping_control;
  l_attr_tab(1).vendor_id                  := x_attributes.vendor_id;
  l_attr_tab(1).party_id                   := x_attributes.party_id;
  l_attr_tab(1).container_flag             := 'N';

  l_attr_tab(2).entity_id                  := NULL;
  l_attr_tab(2).entity_type                := 'DLVB';
  l_attr_tab(2).ship_to_location_id        := x_values.ship_to_location_id;
  l_attr_tab(2).ship_from_location_id      := x_values.ship_from_location_id;
  l_attr_tab(2).customer_id                := x_values.customer_id;
  l_attr_tab(2).intmed_ship_to_location_id := x_values.intmed_ship_to_location_id;
  l_attr_tab(2).fob_code                   := x_values.fob_code;
  l_attr_tab(2).freight_terms_code         := x_values.freight_terms_code;
  l_attr_tab(2).ship_method_code           := x_values.ship_method_code;
  l_attr_tab(2).carrier_id                 := x_values.carrier_id;
  l_attr_tab(2).service_level              := x_values.service_level;
  l_attr_tab(2).mode_of_transport          := x_values.mode_of_transport;
  l_attr_tab(2).source_header_id           := x_values.source_header_id;
  l_attr_tab(2).organization_id            := x_values.organization_id;
  l_attr_tab(2).ignore_for_planning        := 'N';
  l_attr_tab(2).line_direction             := x_values.line_direction;
  l_attr_tab(2).shipping_control           := x_values.shipping_control;
  l_attr_tab(2).vendor_id                  := x_values.vendor_id;
  l_attr_tab(2).party_id                   := x_values.party_id;
  l_attr_tab(2).container_flag             := 'N';


  WSH_DELIVERY_AUTOCREATE.Find_Matching_Groups(
           p_attr_tab         => l_attr_tab,
           p_action_rec       => l_action_rec,
           p_target_rec       => l_target_rec,
           p_group_tab        => l_group_tab,
           x_matched_entities => l_matched_entities,
           x_out_rec          => l_out_rec,
           x_return_status    => l_return_status);

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'find_matching_groups: l_return_status', l_return_status);
    WSH_DEBUG_SV.log(l_module_name, 'l_out_rec.single_group', l_out_rec.single_group);
  END IF;

  IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                         WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
    l_match_flag := (l_out_rec.single_group = 'Y');
  ELSE
    l_match_flag := FALSE;
  END IF;

  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  RETURN l_match_flag;
END attributes_match;


--
--  Procedure:          flush_used_details
--  Parameters:
--               x_context             context in this session
--               x_current_used_details  current list of fully and partially used details
--                                       which will be deleted when the procedure returns.
--               x_used_details          master list of partially used details
--               x_errors_tab            list of errors to insert into wsh_interface_errors at the end
--               x_return_status         return status
--  Description:
--               Flushes the current list, adding only partially used details
--               to the master list.
--               * It also checks for possibility of breaking LPN configuration
--                 because the partially used detail will definitely not stay in the plan's deliveries.
--               The current list will be deleted.
--               This is called by generate_lock_candidates.
--
PROCEDURE flush_used_details(
              x_context              IN OUT NOCOPY context_rec_type,
              x_current_used_details IN OUT NOCOPY used_details_tab_type,
              x_used_details         IN OUT NOCOPY used_details_tab_type,
              x_errors_tab           IN OUT NOCOPY interface_errors_tab_type,
              x_return_status           OUT NOCOPY VARCHAR2)
IS
  l_module_name   CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'FLUSH_USED_DETAILS';
  l_debug_on      BOOLEAN;
  l_new_index     NUMBER;
  l_used_index    NUMBER;
  l_return_status VARCHAR2(1);
BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;

  IF x_current_used_details.COUNT > 0 THEN
    -- there are records to flush.
    l_used_index := x_current_used_details.FIRST;
    IF x_used_details.COUNT > 0 THEN
      l_new_index  := x_used_details.LAST + 1;
    ELSE
      l_new_index  := 1;
    END IF;

    WHILE l_used_index IS NOT NULL LOOP

      IF x_current_used_details(l_used_index).available_quantity > 0 THEN

        -- track these partially used lines;
        -- also check whether LPN configuration would be broken.
        IF x_current_used_details(l_used_index).topmost_cont_id IS NOT NULL THEN
          stamp_interface_error(
              p_group_id            => x_context.group_id,
              p_entity_table_name   => 'WSH_DEL_DETAILS_INTERFACE',
              p_entity_interface_id => x_current_used_details(l_used_index).dd_interface_id,
              p_message_name        => 'WSH_TP_F_LPN_BREAK',
              p_token_1_name        => 'CONTAINER_NAME',
              p_token_1_value       => wsh_container_utilities.get_cont_name(
                                               x_current_used_details(l_used_index).topmost_cont_id),
              p_token_2_name        => 'PLAN_TRIP_NUM',
              p_token_2_value       => get_plan_trip_num(x_context),
              x_errors_tab          => x_errors_tab,
              x_return_status       => l_return_status);
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'broken lpn: x_return_status', x_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          RETURN;
        END IF;

        x_used_details(l_new_index) := x_current_used_details(l_used_index);
        l_new_index := l_new_index + 1;
      END IF;

      l_used_index := x_current_used_details.NEXT(l_used_index);
    END LOOP;

    x_current_used_details.DELETE;

  END IF;


  -- Bug 3555487 initialize message stack for each major action point
  -- Messages should be flushed before each new set of plan lines.
  FND_MSG_PUB.initialize;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;

END flush_used_details;




--
--  Procedure:          map_dangling_containers
--  Parameters:
--               x_context             context in this session
--               p_delivery_index      index into x_plan_deliveries to map dangling containers
--               x_plan_deliveries     list of deliveries mapped to interface deliveries
--               x_errors_tab          list of errors to insert into wsh_interface_errors at the end
--               x_return_status       return status
--
--  Description:
--               Maps and locks all containers of a delivery that have no plan lines.
--
--               This is the only time the process looks at plan containers in wsh_del_details_interface.
--               This is to allow TP to release what they snapshot because they may have to
--               capture firm deliveries that have only dangling containers.
--
--               * fail the plan if the contents of TE delivery does not match the plan delivery's contents.
PROCEDURE map_dangling_containers(
           x_context                  IN OUT NOCOPY context_rec_type,
           p_delivery_index           IN            NUMBER,
           x_plan_deliveries          IN OUT NOCOPY plan_delivery_tab_type,
           x_errors_tab               IN OUT NOCOPY interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          )
IS
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MAP_DANGLING_CONTAINERS';
  --
  l_debug_on BOOLEAN;

  -- check for any line in this delivery
  CURSOR c_has_line(p_delivery_id IN NUMBER) IS
  SELECT d.delivery_detail_id
  FROM   wsh_delivery_assignments_v a, wsh_delivery_details d
  WHERE  a.parent_delivery_detail_id is NULL
  AND    a.delivery_id = p_delivery_id
  AND    a.delivery_id IS NOT NULL
  AND    a.delivery_detail_id = d.delivery_detail_id
  AND    d.released_status <> 'D' -- 4322654
  AND    d.container_flag = 'N'
  AND    rownum = 1;

  -- compare all containers in delivery with plan.
  CURSOR c_dangling_lpns(p_delivery_id IN NUMBER) IS
  SELECT d.delivery_detail_id,
         d.container_name,
         a.parent_delivery_detail_id
  FROM   wsh_delivery_assignments_v a, wsh_delivery_details d
  WHERE  a.delivery_id = p_delivery_id
  AND    a.delivery_id IS NOT NULL
  AND    a.delivery_detail_id = d.delivery_detail_id
  AND    d.container_flag = 'Y'
  FOR UPDATE NOWAIT;

  -- count containers in plan
  -- currently, TP captures all LPNs within the delivery.
  CURSOR c_plan_lpn_count(x_delivery_interface_id IN NUMBER) IS
  SELECT count(wddi.delivery_detail_id)
  FROM   wsh_del_assgn_interface      wdai,
         wsh_del_details_interface    wddi
  WHERE  wdai.delivery_interface_id = x_delivery_interface_id
  AND    wdai.delivery_interface_id IS NOT NULL
  AND    wdai.interface_action_code = G_TP_RELEASE_CODE
  AND    wddi.delivery_detail_interface_id = wdai.delivery_detail_interface_id
  AND    wddi.interface_action_code = G_TP_RELEASE_CODE
  AND    wddi.container_flag = 'Y';

  -- verify that this TE container is mentioned in plan
  CURSOR c_plan_lpn(x_delivery_interface_id IN NUMBER,
                    x_delivery_detail_id    IN NUMBER) IS
  SELECT wddi.delivery_detail_interface_id
  FROM   wsh_del_assgn_interface      wdai,
         wsh_del_details_interface    wddi
  WHERE  wdai.delivery_interface_id = x_delivery_interface_id
  AND    wdai.delivery_interface_id IS NOT NULL
  AND    wdai.interface_action_code = G_TP_RELEASE_CODE
  AND    wddi.delivery_detail_interface_id = wdai.delivery_detail_interface_id
  AND    wddi.interface_action_code = G_TP_RELEASE_CODE
  AND    wddi.delivery_detail_id = x_delivery_detail_id
  AND    wddi.container_flag = 'Y'
  AND    rownum = 1;


  l_detail_id        NUMBER;
  l_found            BOOLEAN;
  l_scanning_lpns    BOOLEAN := FALSE;
  l_plan_lpn_count   NUMBER  := 0;
  l_te_lpn_count     NUMBER  := 0;
  l_return_status    VARCHAR2(1);

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- Bug 3555487 initialize message stack for each major action point.
  FND_MSG_PUB.initialize;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name, 'p_delivery_index', p_delivery_index);
  END IF;

  OPEN c_has_line(x_plan_deliveries(p_delivery_index).delivery_id);
  FETCH c_has_line INTO l_detail_id;
  l_found := c_has_line%FOUND;
  CLOSE c_has_line;

  IF l_found THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    stamp_interface_error(
      p_group_id            => x_context.group_id,
      p_entity_table_name   => 'WSH_NEW_DELIVERIES_INTERFACE',
      p_entity_interface_id => x_plan_deliveries(p_delivery_index).del_interface_id,
      p_message_name        => 'WSH_TP_F_DEL_LINE',  -- new message
      p_token_1_name        => 'PLAN_DEL_NUM',
      p_token_1_value       => x_plan_deliveries(p_delivery_index).tp_delivery_number,
      p_token_2_name        => 'DELIVERY_NAME',
      p_token_2_value       => x_plan_deliveries(p_delivery_index).name,
      x_errors_tab          => x_errors_tab,
      x_return_status       => l_return_status);
  ELSE
    -- count plan LPNs
    OPEN c_plan_lpn_count(x_plan_deliveries(p_delivery_index).del_interface_id);
    FETCH c_plan_lpn_count INTO l_plan_lpn_count;
    IF c_plan_lpn_count%NOTFOUND THEN
      l_plan_lpn_count := 0;
    END IF;
    CLOSE c_plan_lpn_count;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'l_plan_lpn_count', l_plan_lpn_count);
    END IF;

    IF l_plan_lpn_count = 0 THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      stamp_interface_error(
        p_group_id            => x_context.group_id,
        p_entity_table_name   => 'WSH_NEW_DELIVERIES_INTERFACE',
        p_entity_interface_id => x_plan_deliveries(p_delivery_index).del_interface_id,
        p_message_name        => 'WSH_TP_F_NO_PLAN_LPNS',  -- new message
        p_token_1_name        => 'PLAN_DEL_NUM',
        p_token_1_value       => x_plan_deliveries(p_delivery_index).tp_delivery_number,
        p_token_2_name        => 'DELIVERY_NAME',
        p_token_2_value       => x_plan_deliveries(p_delivery_index).name,
        x_errors_tab          => x_errors_tab,
        x_return_status       => l_return_status);
    ELSE

      -- check that all dangling containers in TE and plan are matched.
      l_scanning_lpns := TRUE;
      l_found := TRUE;
      FOR lpn_rec IN c_dangling_lpns(x_plan_deliveries(p_delivery_index).delivery_id)  LOOP
        l_te_lpn_count := l_te_lpn_count + 1;

        IF lpn_rec.parent_delivery_detail_id IS NULL THEN
          x_plan_deliveries(p_delivery_index).dangling_conts_count := x_plan_deliveries(p_delivery_index).dangling_conts_count + 1;
        END IF;

        OPEN c_plan_lpn(x_plan_deliveries(p_delivery_index).del_interface_id,
                        lpn_rec.delivery_detail_id);
        FETCH c_plan_lpn INTO l_detail_id;
        l_found := c_plan_lpn%FOUND;
        CLOSE c_plan_lpn;

        IF NOT l_found THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          stamp_interface_error(
            p_group_id            => x_context.group_id,
            p_entity_table_name   => 'WSH_NEW_DELIVERIES_INTERFACE',
            p_entity_interface_id => x_plan_deliveries(p_delivery_index).del_interface_id,
            p_message_name        => 'WSH_TP_F_NEW_LPN',  -- new message
            p_token_1_name        => 'PLAN_DEL_NUM',
            p_token_1_value       => x_plan_deliveries(p_delivery_index).tp_delivery_number,
            p_token_2_name        => 'DELIVERY_NAME',
            p_token_2_value       => x_plan_deliveries(p_delivery_index).name,
            p_token_3_name        => 'CONTAINER_NAME',
            p_token_3_value       => lpn_rec.container_name,
            x_errors_tab          => x_errors_tab,
            x_return_status       => l_return_status);
          -- at this point, l_found will be FALSE so we will not get the next message.
          EXIT;
        END IF;

      END LOOP;
      l_scanning_lpns := FALSE;

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'l_te_lpn_count', l_te_lpn_count);
      END IF;

      IF l_found AND l_plan_lpn_count <> l_te_lpn_count THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        stamp_interface_error(
          p_group_id            => x_context.group_id,
          p_entity_table_name   => 'WSH_NEW_DELIVERIES_INTERFACE',
          p_entity_interface_id => x_plan_deliveries(p_delivery_index).del_interface_id,
          p_message_name        => 'WSH_TP_F_LPN_MISMATCH',  -- new message
          p_token_1_name        => 'PLAN_DEL_NUM',
          p_token_1_value       => x_plan_deliveries(p_delivery_index).tp_delivery_number,
          p_token_2_name        => 'DELIVERY_NAME',
          p_token_2_value       => x_plan_deliveries(p_delivery_index).name,
          x_errors_tab          => x_errors_tab,
          x_return_status       => l_return_status);
      END IF;
    END IF;
  END IF;

  --
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF c_has_line%ISOPEN THEN
         CLOSE c_has_line;
      END IF;
      IF c_dangling_lpns%ISOPEN THEN
         CLOSE c_dangling_lpns;
      END IF;
      IF c_plan_lpn_count%ISOPEN THEN
         CLOSE c_plan_lpn_count;
      END IF;
      IF c_plan_lpn%ISOPEN THEN
         CLOSE c_plan_lpn;
      END IF;

      IF l_scanning_lpns THEN
        -- probably error due to lock on LPN.
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        stamp_interface_error(
          p_group_id            => x_context.group_id,
          p_entity_table_name   => 'WSH_NEW_DELIVERIES_INTERFACE',
          p_entity_interface_id => x_plan_deliveries(p_delivery_index).del_interface_id,
          p_message_name        => 'WSH_TP_F_DANGL_LPN_NO_LOCK',  -- new message
          p_token_1_name        => 'PLAN_DEL_NUM',
          p_token_1_value       => x_plan_deliveries(p_delivery_index).tp_delivery_number,
          p_token_2_name        => 'DELIVERY_NAME',
          p_token_2_value       => x_plan_deliveries(p_delivery_index).name,
          x_errors_tab          => x_errors_tab,
          x_return_status       => l_return_status);
      ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        WSH_UTIL_CORE.DEFAULT_HANDLER(
                          'WSH_TP_RELEASE.MAP_DANGLING_CONTAINERS',
                          l_module_name);
      END IF;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END map_dangling_containers;






--
--  Procedure:          match_deliveries
--  Parameters:
--               x_context             context in this session
--               x_plan_details        list of delivery details mapped to interface lines
--               x_track_conts         list of topmost containers to track
--               x_plan_deliveries     list of deliveries mapped to interface deliveries
--               x_used_details        list of delivery details partially used by the plan
--               x_delivery_unassigns  list of delivery lines to unassign from their deliveries
--               x_errors_tab          list of errors to insert into wsh_interface_errors at the end
--               x_return_status       return status
--
--  Description:
--               Goes through each mapped delivery (with lines) to identify details
--               that need to be unassigned so that it will match the plan's delivery.
--               Note: dangling containers will be ignored and allowed to stay
--                 with the delivery (TE user may be in middle of packing or TP may have
--                 snapshot a firm itinerary having a delivery with dangling containers and no lines).
--               Also processes x_used_details to mark partially split details that
--               need to be unassigned if their current deliveries are in the plan.
--                      Dangling container is a container that may have nested containers
--                      but does not have any line packed within.
--
--               x_delivery_unassigns will have the unassignments for lines and LPNs not in plan.
--               x_used_details will have need_unassignment set TRUE.
--
PROCEDURE match_deliveries(
           x_context                  IN OUT NOCOPY context_rec_type,
           x_plan_details             IN OUT NOCOPY plan_detail_tab_type,
           x_track_conts              IN OUT NOCOPY track_cont_tab_type,
           x_plan_deliveries          IN OUT NOCOPY plan_delivery_tab_type,
           x_used_details             IN OUT NOCOPY used_details_tab_type,
           x_delivery_unassigns       IN OUT NOCOPY delivery_unassign_tab_type,
           x_errors_tab               IN OUT NOCOPY interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          )
IS
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MATCH_DELIVERIES';
  --
  l_debug_on BOOLEAN;

  -- list the topmost containers and loose lines in the delivery
  CURSOR c_assigned_details(p_delivery_id IN NUMBER) IS
  SELECT d.delivery_detail_id,
         d.organization_id,
         d.container_flag,
         d.source_code,
         d.released_status,
         d.lpn_id
  FROM   wsh_delivery_assignments_v a, wsh_delivery_details d
  WHERE  a.parent_delivery_detail_id is NULL
  AND    a.delivery_id = p_delivery_id
  AND    a.delivery_id IS NOT NULL
  AND    a.delivery_detail_id = d.delivery_detail_id
  AND    d.released_status <> 'D'; -- Bug 4322654

  l_assigned_rec c_assigned_details%ROWTYPE;

  -- x_delivery_unassigns may have elements from mapping LPNs in generate_lock_candidates.
  -- we need to screen LPNs against these elements.
  l_last_mapped_lpn      NUMBER                := x_delivery_unassigns.COUNT;
  l_count                NUMBER                := x_delivery_unassigns.COUNT;
  l_index                NUMBER;
  l_detail_matches       VARCHAR2(1);
  l_du_index             NUMBER;
  l_dummy_id             NUMBER;
  l_flag                 VARCHAR2(1);
  l_working_used_details used_details_tab_type := x_used_details;
  l_next_index           NUMBER;
  l_plan_dd_index        NUMBER;


  -- check if topmost container has content which means it is not dangling.

  -- bug 4891939, sql 15039839
  -- removed rownum = 1
  -- since it causes 2 full table scan on wsh_delivery_assignments

  CURSOR c_has_content(p_container_id IN NUMBER) IS
  SELECT wdd.delivery_detail_id
  FROM   wsh_delivery_details wdd
  WHERE wdd.container_flag = 'N'
  AND   wdd.released_status <> 'D' -- 4322654
  AND   wdd.delivery_detail_id IN
        (SELECT  wda.delivery_detail_id
         FROM  wsh_delivery_assignments_v wda
         START WITH parent_delivery_detail_id = p_container_id
         CONNECT BY prior delivery_detail_id = parent_delivery_detail_id);


  -- WMS LPNs need to be checked for staged contents.

  -- bug 4891939, sql 15039851
  -- removed rownum = 1
  -- since it causes 2 full table scan on wsh_delivery_assignments

  CURSOR c_staged_content(p_container_id IN NUMBER) IS
  SELECT wdd.delivery_detail_id
  FROM   wsh_delivery_details wdd
  WHERE wdd.container_flag = 'N'
  AND   wdd.released_status = 'Y'
  AND   wdd.delivery_detail_id IN
        (SELECT  wda.delivery_detail_id
         FROM  wsh_delivery_assignments_v wda
         START WITH parent_delivery_detail_id = p_container_id
         CONNECT BY prior delivery_detail_id = parent_delivery_detail_id);

  WSH_PLANNED_DEL_NOT_MATCH EXCEPTION;

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;
  --
  --
  -- Go through list of deliveries in plan.

  FOR i in 1.. x_plan_deliveries.count LOOP

      -- Skip if the delivery in plan is not mapped to an existing delivery
      -- or the delivery has only dangling containers (which has already been validated).

      IF    (x_plan_deliveries(i).delivery_id IS NOT NULL)
         OR (x_plan_deliveries(i).dangling_conts_count = 0)        THEN --{

        -- Go through list of loose details and containers in this delivery to check for unassignments.
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'looping x_plan_deliveries(i).delivery_id', x_plan_deliveries(i).delivery_id);
        END IF;

        OPEN c_assigned_details(x_plan_deliveries(i).delivery_id);
        LOOP
           FETCH c_assigned_details INTO l_assigned_rec;
           EXIT WHEN c_assigned_details%NOTFOUND;

           IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name, 'looping assigned_details: delivery_detail_id', l_assigned_rec.delivery_detail_id);
           END IF;

           l_detail_matches := 'N';
           l_plan_dd_index  := NULL;

           IF NVL(l_assigned_rec.container_flag, 'N') = 'N' THEN

              FOR j in 1.. x_plan_details.count LOOP

                  IF (x_plan_details(j).delivery_detail_id = l_assigned_rec.delivery_detail_id)  THEN
                     l_plan_dd_index := j;
                     IF (x_plan_details(j).target_delivery_index = i) THEN
                       l_detail_matches := 'Y';
                     END IF;
                     -- stop scanning because the record is found in plan.
                     EXIT;
                  END IF;

              END LOOP;

           ELSE

              -- check if we've already added this container to x_delivery_unassigns
              FOR j IN 1..l_last_mapped_lpn LOOP
                 IF x_delivery_unassigns(j).delivery_detail_id = l_assigned_rec.delivery_detail_id THEN
                   l_detail_matches := 'Y';
                   EXIT;
                 END IF;
              END LOOP;

              IF l_detail_matches = 'N' THEN
                -- if not yet found, then check the containers mapped in plan.

                FOR j in 1.. x_track_conts.count LOOP

                    IF (x_track_conts(j).topmost_cont_id = l_assigned_rec.delivery_detail_id)  THEN
                       l_plan_dd_index := x_track_conts(j).plan_dd_index;
                       IF (x_track_conts(j).target_delivery_index = i) THEN
                         l_detail_matches := 'Y';
                       END IF;
                       -- stop scanning because the record is found in plan.
                       EXIT;
                    END IF;

                 END LOOP;
              END IF;

              IF l_detail_matches = 'N' THEN
                -- if still not found, check that this container is dangling.
                --  We consider dangling containers to match the plan because
                -- the TE user may be in the middle of packing or TP may have
                -- snapshot a firm delivery with dangling containers.
                OPEN c_has_content(l_assigned_rec.delivery_detail_id);
                FETCH c_has_content INTO l_dummy_id;
                IF c_has_content%NOTFOUND THEN
                  -- automatically match this dangling container.
                  l_detail_matches := 'Y';
                  x_plan_deliveries(i).dangling_conts_count := x_plan_deliveries(i).dangling_conts_count + 1;
                END IF;
                CLOSE c_has_content;
              END IF;

           END IF;


           IF l_detail_matches = 'N' THEN

              -- Fail Plan if the delivery is planned or firmed.
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'not matched in plan');
              END IF;

              IF NVL(x_plan_deliveries(i).wsh_planned_flag, 'N') <> 'N' THEN
                 Stamp_Interface_Error(p_group_id => x_context.group_id,
                                       p_entity_table_name => 'WSH_NEW_DEL_INTERFACE',
                                       p_entity_interface_id => x_plan_deliveries(i).del_interface_id,
                                       p_message_name => 'WSH_TP_F_PLAN_DEL_NOT_MATCH',
                                       p_token_1_name    => 'DELIVERY_NAME',
                                       p_token_1_value       => WSH_NEW_DELIVERIES_PVT.get_name(
                                                      x_plan_deliveries(i).delivery_id),
                                       p_token_2_name        => 'PLAN_TRIP_NUM',
                                       p_token_2_value       => get_plan_trip_num(x_context),
                                       p_token_3_name        => 'PLAN_DEL_NUM',
                                       p_token_3_value       => x_plan_deliveries(i).tp_delivery_number,
                                       x_errors_tab => x_errors_tab,
                                       x_return_status => x_return_status);

                 RAISE WSH_PLANNED_DEL_NOT_MATCH;

              END IF;

              -- Add to table of unassigns

              l_count := l_count + 1;

              x_delivery_unassigns(l_count).delivery_id        := x_plan_deliveries(i).delivery_id;
              x_delivery_unassigns(l_count).delivery_detail_id := l_assigned_rec.delivery_detail_id;
              x_delivery_unassigns(l_count).organization_id    := l_assigned_rec.organization_id;
              x_delivery_unassigns(l_count).container_flag     := l_assigned_rec.container_flag;
              x_delivery_unassigns(l_count).lines_staged       := NULL;
              x_delivery_unassigns(l_count).wms_org_flag       := wsh_util_validate.Check_Wms_Org(l_assigned_rec.organization_id);
              x_delivery_unassigns(l_count).source_code        := l_assigned_rec.source_code;
              x_delivery_unassigns(l_count).released_status    := l_assigned_rec.released_status;
              x_delivery_unassigns(l_count).lpn_id             := l_assigned_rec.lpn_id;
              x_delivery_unassigns(l_count).plan_dd_index      := l_plan_dd_index;
              x_delivery_unassigns(l_count).plan_del_index     := i;
              x_delivery_unassigns(l_count).wv_frozen_flag     := x_plan_deliveries(i).wv_frozen_flag;  -- WV changes
              x_delivery_unassigns(l_count).initial_pickup_location_id     := x_plan_deliveries(i).initial_pickup_location_id;

              IF     x_delivery_unassigns(l_count).wms_org_flag = 'Y'
                 AND x_delivery_unassigns(l_count).container_flag = 'Y' THEN

                 IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name, 'WMS container to be unassigned', x_delivery_unassigns(l_count).delivery_detail_id);
                 END IF;

                 OPEN c_staged_content(x_delivery_unassigns(l_count).delivery_detail_id);
                 FETCH c_staged_content INTO l_dummy_id;
                 IF c_staged_content%FOUND THEN
                   l_flag := 'Y';
                 ELSE
                   l_flag := 'N';
                 END IF;
                 CLOSE c_staged_content;

                 IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name, 'lines_staged', l_flag);
                 END IF;

                 x_delivery_unassigns(l_count).lines_staged := (l_flag = 'Y');
              END IF;


           END IF;

        END LOOP;

        CLOSE c_assigned_details;

        -- look for partially used details that need to be unassigned
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'l_working_used_details.COUNT', l_working_used_details.COUNT);
        END IF;

        IF l_working_used_details.COUNT > 0 THEN --[
          l_index := l_working_used_details.FIRST;

          WHILE l_index IS NOT NULL LOOP

            l_next_index := l_working_used_details.NEXT(l_index);

            IF    l_working_used_details(l_index).current_delivery_id IS NULL
               OR l_working_used_details(l_index).topmost_cont_id IS NOT NULL THEN
              -- remove from working list to reduce the list for future iterations,
              -- as this line is not assigned or it is packed in a container.
              l_working_used_details.DELETE(l_index);
            ELSIF l_working_used_details(l_index).current_delivery_id =
                    x_plan_deliveries(i).delivery_id  THEN

              -- Fail Plan if the delivery is planned or firmed.
              -- (backup for the logic in flush_details to set WSH_TP_F_FIRM_DEL_UNUSED)

              IF NVL(x_plan_deliveries(i).wsh_planned_flag, 'N') <> 'N' THEN
                 Stamp_Interface_Error(p_group_id => x_context.group_id,
                                       p_entity_table_name => 'WSH_NEW_DEL_INTERFACE',
                                       p_entity_interface_id => x_plan_deliveries(i).del_interface_id,
                                       p_message_name => 'WSH_TP_F_PLAN_DEL_NOT_MATCH',
                                       x_errors_tab => x_errors_tab,
                                       x_return_status => x_return_status);

                 RAISE WSH_PLANNED_DEL_NOT_MATCH;

              END IF;

              x_used_details(l_index).need_unassignment := TRUE;

              -- remove from working list to reduce the list for future iterations.
              l_working_used_details.DELETE(l_index);

            END IF;

            l_index := l_next_index;

          END LOOP;

        END IF; --]

      END IF;  --}

  END LOOP;


  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  --
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION
    WHEN WSH_PLANNED_DEL_NOT_MATCH THEN
      IF c_assigned_details%isopen THEN
         CLOSE c_assigned_details;
      END IF;
      IF c_has_content%ISOPEN THEN
         CLOSE c_has_content;
      END IF;
      IF c_staged_content%ISOPEN THEN
         CLOSE c_staged_content;
      END IF;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_PLANNED_DEL_NOT_MATCH');
      END IF;

    WHEN OTHERS THEN
      IF c_assigned_details%isopen THEN
         CLOSE c_assigned_details;
      END IF;
      IF c_has_content%ISOPEN THEN
         CLOSE c_has_content;
      END IF;
      IF c_staged_content%ISOPEN THEN
         CLOSE c_staged_content;
      END IF;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TP_RELEASE.MATCH_DELIVERIES',
                        l_module_name);

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END match_deliveries;



--
--  Procedure:          validate_wms
--  Parameters:
--               x_context             context in this session
--               x_plan_details        list of delivery details mapped to interface lines
--               x_plan_deliveries     list of deliveries mapped to interface deliveries
--               x_delivery_unassigns  list of details to unassign in order to validate LPN unassignments
--               x_errors_tab          list of errors to insert into wsh_interface_errors at the end
--               x_return_status       return status
--
--  Description: Validate that the plan will not affect WMS data.
--                 1.  call WMS to validate the lines released to warehouse that will go into each
--                       delivery can be assigned to that delivery and will not break LPN configuration.
--                 2.  call WMS to validate the staged LPNs in x_delivery_unassigns can be unassigned
--
PROCEDURE validate_wms(
           x_context                  IN OUT NOCOPY context_rec_type,
           x_plan_details             IN OUT NOCOPY plan_detail_tab_type,
           x_plan_deliveries          IN OUT NOCOPY plan_delivery_tab_type,
           x_delivery_unassigns       IN OUT NOCOPY delivery_unassign_tab_type,
           x_errors_tab               IN OUT NOCOPY interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          )
IS
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_WMS';
  --
  l_debug_on BOOLEAN;

  l_return_status VARCHAR2(1);

  l_wms_table WMS_SHIPPING_INTERFACE_GRP.g_delivery_detail_tbl;
  l_del_index NUMBER;
  l_dd_index  NUMBER;
  l_dd_count  NUMBER;
  l_indexes   WSH_UTIL_CORE.ID_TAB_TYPE;
  l_unassign_index NUMBER;

  l_discard_rs    VARCHAR2(1);
  l_msg_data      VARCHAR2(2000);
  l_msg_count     NUMBER;

BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;
  --
  --

  --  1.  call WMS to validate the lines released to warehouse that will go into each
  --          delivery can be assigned to that delivery and will not break LPN configuration.

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'1. call WMS to validate lines released to warehouse: x_plan_deliveries.COUNT: ', x_plan_deliveries.COUNT);
  END IF;

  l_del_index := x_plan_deliveries.FIRST;
  WHILE l_del_index IS NOT NULL LOOP

    IF x_plan_deliveries(l_del_index).wms_org_flag = 'Y' THEN --[

      IF x_plan_deliveries(l_del_index).s_lines_count > 0  THEN

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Validating S lines in WMS: l_del_index: ', l_del_index);
        END IF;

        l_wms_table.DELETE;
        l_indexes.DELETE;
        l_dd_count := 0;
        l_dd_index := x_plan_details.FIRST;

        WHILE     (l_dd_index IS NOT NULL)
              AND (l_dd_count < x_plan_deliveries(l_del_index).s_lines_count) LOOP
          -- make a list of lines released to warehouse to be validated by WMS

          IF     (x_plan_details(l_dd_index).target_delivery_index = l_del_index)
             AND (x_plan_details(l_dd_index).released_status = 'S')  THEN
             l_dd_count := l_dd_count + 1;

             -- track index so we can look up interface lines in case of errors
             l_indexes(l_dd_count) := l_dd_index;

             l_wms_table(l_dd_count).delivery_detail_id := x_plan_details(l_dd_index).delivery_detail_id;
             l_wms_table(l_dd_count).organization_id    := x_plan_details(l_dd_index).organization_id;
             l_wms_table(l_dd_count).released_status    := x_plan_details(l_dd_index).released_status;
             l_wms_table(l_dd_count).container_flag     := 'N';
             l_wms_table(l_dd_count).source_code        := x_plan_details(l_dd_index).source_code;
             l_wms_table(l_dd_count).move_order_line_id := x_plan_details(l_dd_index).move_order_line_id;
             l_wms_table(l_dd_count).lpn_id             := NULL;
          END IF;

          l_dd_index := x_plan_details.NEXT(l_dd_index);
        END LOOP;


        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_wms_table.COUNT: ', l_wms_table.COUNT);
        END IF;


        IF l_wms_table.COUNT > 0 THEN

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling WMS_SHIPPING_INTERFACE_GRP.process_delivery_details',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WMS_SHIPPING_INTERFACE_GRP.process_delivery_details (
                 p_api_version          => 1.0,
                 p_action               => WMS_SHIPPING_INTERFACE_GRP.g_action_unassign_delivery,
                 p_delivery_detail_tbl  => l_wms_table,
                 x_return_status        => l_return_status,
                 x_msg_count            => l_msg_count,
                 x_msg_data             => l_msg_data);

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'WMS_SHIPPING_INTERFACE_GRP.process_delivery_details return_status',
                                           l_return_status);
          END IF;

          IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
            -- at least one line is breaking LPN configurations in WMS

            -- bug 4552612: issue #3
            -- WMS API is setting the same message that is returned below,
            -- so it should be purged to avoid repetition.
            FND_MSG_PUB.initialize;

            -- per discussion with WMS, this action will not mark lines as
            -- having errors, and the message does not have a token.
            stamp_interface_error(
                      p_group_id            => x_context.group_id,
                      p_entity_table_name   => 'WSH_NEW_DEL_INTERFACE',
                      p_entity_interface_id => x_plan_deliveries(l_del_index).del_interface_id,
                      p_message_name        => l_wms_table(1).r_message_code,
                      p_message_appl        => l_wms_table(1).r_message_appl,
                      p_message_text        => l_wms_table(1).r_message_text,
                      x_errors_tab          => x_errors_tab,
                      x_return_status       => l_discard_rs);

            stamp_interface_error(
                    p_group_id            => x_context.group_id,
                    p_entity_table_name   => 'WSH_NEW_DEL_INTERFACE',
                    p_entity_interface_id => x_plan_deliveries(l_del_index).del_interface_id,
                    p_message_name        => 'WSH_TP_F_WMS_REL_LPN_BREAK',
                    p_token_1_name        => 'PLAN_TRIP_NUM',
                    p_token_1_value       => get_plan_trip_num(x_context),
                    x_errors_tab          => x_errors_tab,
                    x_return_status       => l_discard_rs);
          END IF;
        END IF;

        l_wms_table.DELETE;
        l_indexes.DELETE;

        IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                               WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
             WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          RETURN;
        END IF;

      END IF;

    END IF; --]

    l_del_index := x_plan_deliveries.NEXT(l_del_index);

  END LOOP;


  --  2.  go through x_delivery_unassigns, look for staged LPNs to call WMS to validate they
  --      can be unassigned from deliveries.

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'2. go through x_delivery_unassigns: x_delivery_unassigns.COUNT', x_delivery_unassigns.COUNT);
  END IF;

  -- Bug 3555487 initialize message stack for each major action point.
  FND_MSG_PUB.initialize;

  IF x_delivery_unassigns.COUNT > 0 THEN --[

    l_wms_table.DELETE;
    l_dd_count  := 0;
    l_indexes.DELETE;
    l_unassign_index := x_delivery_unassigns.FIRST;

    WHILE l_unassign_index IS NOT NULL LOOP
       IF     x_delivery_unassigns(l_unassign_index).wms_org_flag = 'Y'
          AND x_delivery_unassigns(l_unassign_index).container_flag = 'Y'
          AND x_delivery_unassigns(l_unassign_index).lines_staged  THEN

         l_dd_count := l_dd_count + 1;

         -- track index so we can look up interface lines in case of errors
         l_indexes(l_dd_count) := l_unassign_index;

         l_wms_table(l_dd_count).delivery_detail_id := x_delivery_unassigns(l_unassign_index).delivery_detail_id;
         l_wms_table(l_dd_count).organization_id    := x_delivery_unassigns(l_unassign_index).organization_id;
         l_wms_table(l_dd_count).released_status    := x_delivery_unassigns(l_unassign_index).released_status;
         l_wms_table(l_dd_count).container_flag     := x_delivery_unassigns(l_unassign_index).container_flag;
         l_wms_table(l_dd_count).source_code        := x_delivery_unassigns(l_unassign_index).source_code;
         l_wms_table(l_dd_count).lpn_id             := x_delivery_unassigns(l_unassign_index).lpn_id;
       END IF;

       l_unassign_index := x_delivery_unassigns.NEXT(l_unassign_index);
    END LOOP;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_wms_table.COUNT: ', l_wms_table.COUNT);
    END IF;

    IF l_wms_table.COUNT > 0 THEN  --{
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling WMS_SHIPPING_INTERFACE_GRP.process_delivery_details',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WMS_SHIPPING_INTERFACE_GRP.process_delivery_details (
               p_api_version          => 1.0,
               p_action               => WMS_SHIPPING_INTERFACE_GRP.g_action_unassign_delivery,
               p_delivery_detail_tbl  => l_wms_table,
               x_return_status        => l_return_status,
               x_msg_count            => l_msg_count,
               x_msg_data             => l_msg_data);

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'WMS_SHIPPING_INTERFACE_GRP.process_delivery_details return_status',
                                       l_return_status);
      END IF;

      -- bug 4552612: issue #4
      -- fixed error-handling to correctly handle the results:
      --   API returning success means to check the list for specific errors.
      IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                              WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
        NULL;  -- here, internal issues have happened.
               -- We will error out below.
               -- We will also keep the messages on stack to be stamped.
      ELSE
        -- check the list to find out
        -- whether any LPN cannot be unassigned in WMS.
        -- If so, set l_return_status to ERROR.

        -- bug 4552612: issue #3
        -- if WMS API has set messages for failed validation,
        -- they need to be purged to avoid repetition
        -- because the same messages will be set below.
        FND_MSG_PUB.initialize;

        l_dd_index := l_wms_table.FIRST;
        WHILE l_dd_index IS NOT NULL LOOP
          IF (l_wms_table(l_dd_index).return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                                        WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
            l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            IF x_delivery_unassigns(l_indexes(l_dd_index)).plan_dd_index IS NOT NULL THEN
              stamp_interface_error(
                      p_group_id            => x_context.group_id,
                      p_entity_table_name   => 'WSH_DEL_DETAILS_INTERFACE',
                      p_entity_interface_id => x_plan_details(x_delivery_unassigns(l_indexes(l_dd_index)).plan_dd_index).dd_interface_id,
                      p_message_name        => l_wms_table(l_dd_index).r_message_code,
                      p_message_appl        => l_wms_table(l_dd_index).r_message_appl,
                      p_message_text        => l_wms_table(l_dd_index).r_message_text,
                      p_token_1_name        => 'LPN_NAME',
                      p_token_1_value       => l_wms_table(l_dd_index).r_message_token,
                      x_errors_tab          => x_errors_tab,
                      x_return_status       => l_discard_rs);
            ELSIF x_delivery_unassigns(l_indexes(l_dd_index)).plan_del_index IS NOT NULL THEN
              stamp_interface_error(
                      p_group_id            => x_context.group_id,
                      p_entity_table_name   => 'WSH_NEW_DEL_INTERFACE',
                      p_entity_interface_id => x_plan_deliveries(x_delivery_unassigns(l_indexes(l_dd_index)).plan_del_index).del_interface_id,
                      p_message_name        => l_wms_table(l_dd_index).r_message_code,
                      p_message_appl        => l_wms_table(l_dd_index).r_message_appl,
                      p_message_text        => l_wms_table(l_dd_index).r_message_text,
                      p_token_1_name        => 'LPN_NAME',
                      p_token_1_value       => l_wms_table(l_dd_index).r_message_token,
                      x_errors_tab          => x_errors_tab,
                      x_return_status       => l_discard_rs);
            ELSE
              stamp_interface_error(
                      p_group_id            => x_context.group_id,
                      p_entity_table_name   => 'NONE',
                      p_entity_interface_id => -1,
                      p_message_name        => l_wms_table(l_dd_index).r_message_code,
                      p_message_appl        => l_wms_table(l_dd_index).r_message_appl,
                      p_message_text        => l_wms_table(l_dd_index).r_message_text,
                      p_token_1_name        => 'LPN_NAME',
                      p_token_1_value       => l_wms_table(l_dd_index).r_message_token,
                      x_errors_tab          => x_errors_tab,
                      x_return_status       => l_discard_rs);
            END IF;
          END IF;

          l_dd_index := l_wms_table.NEXT(l_dd_index);
        END LOOP;

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_return status after scanning wms list',
                                          l_return_status);
        END IF;

      END IF;

      IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                              WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
        stamp_interface_error(
                      p_group_id            => x_context.group_id,
                      p_entity_table_name   => 'NONE',
                      p_entity_interface_id => -1,
                      p_message_name        => 'WSH_TP_F_WMS_LPN_BREAK',
                      p_token_1_name        => 'PLAN_TRIP_NUM',
                      p_token_1_value       => get_plan_trip_num(x_context),
                      x_errors_tab          => x_errors_tab,
                      x_return_status       => l_discard_rs);
      END IF;

      l_wms_table.DELETE;
      l_indexes.DELETE;

      IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                             WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      END IF;

    END IF; --}

  END IF;  --]

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  --
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TP_RELEASE.VALIDATE_WMS',
                        l_module_name);

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END validate_wms;




--
--  Procedure:          match_trips
--  Parameters:
--               x_context             context in this session
--               x_plan_deliveries     list of deliveries mapped to interface deliveries
--               x_plan_stops          list of stops mapped to interface stops
--               x_plan_trips          list of trips mapped to interface trips
--               x_trip_unassigns      list of deliveries to unassign from their trips
--               x_obsoleted_stops     list of mapped trips' stops that are not mapped in the plan
--               x_errors_tab          list of errors to insert into wsh_interface_errors at the end
--               x_return_status       return status
--
--  Description:
--               Goes through each mapped trip to identify deliveries
--               that need to be unassigned and stops that need to be removed
--               so that it will match the plan's trip.
--               Linked stops count as one stop.
--               x_trip_unassigns will have the unassignments.
--               x_obsoleted_stops will have the unassignments.
--
PROCEDURE match_trips(
           x_context                  IN OUT NOCOPY context_rec_type,
           x_plan_deliveries          IN OUT NOCOPY plan_delivery_tab_type,
           x_plan_stops               IN OUT NOCOPY plan_stop_tab_type,
           x_plan_trips               IN OUT NOCOPY plan_trip_tab_type,
           x_trip_unassigns           IN OUT NOCOPY trip_unassign_tab_type,
           x_obsoleted_stops          IN OUT NOCOPY obsoleted_stop_tab_type,
           x_errors_tab               IN OUT NOCOPY interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          )
IS
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MATCH_TRIPS';
  --
  l_debug_on BOOLEAN;

  -- list the open stops in a trip in sequence
  CURSOR c_stops_in_trip(p_trip_id IN NUMBER) IS
  SELECT ts.stop_id,
         ts.physical_location_id,
         ts.physical_stop_id,
         ts.planned_arrival_date
  FROM   wsh_trip_stops ts
  WHERE  ts.trip_id = p_trip_id
  AND    ts.status_code = 'OP'
  ORDER BY ts.stop_sequence_number;

  -- find deliveries associated with each stop
  -- as a pick up or drop off.
  CURSOR c_legs_in_trip(p_stop_id IN NUMBER) IS
  SELECT l.delivery_id,
         d.organization_id,
         l.pick_up_stop_id,
         l.drop_off_stop_id
  FROM   wsh_delivery_legs l,
         wsh_new_deliveries d
  WHERE  l.pick_up_stop_id = p_stop_id
  AND    d.delivery_id = l.delivery_id
  UNION
  SELECT l.delivery_id,
         d.organization_id,
         l.pick_up_stop_id,
         l.drop_off_stop_id
  FROM   wsh_delivery_legs l,
         wsh_new_deliveries d
  WHERE  l.drop_off_stop_id = p_stop_id
  AND    d.delivery_id = l.delivery_id;

  l_trip_count NUMBER;
  l_stop_count NUMBER;
  l_stop_id NUMBER;
  l_stop_matches VARCHAR2(1);
  l_leg_id NUMBER;
  l_delivery_matches VARCHAR2(1);
  l_stops_start_index NUMBER;
  l_stop_index NUMBER;
  l_temp_unassigned_dels WSH_UTIL_CORE.ID_TAB_TYPE;
  l_delivery_unassigned VARCHAR2(1);
  l_tmp_entity_name VARCHAR2(30);

  l_unassign_mark NUMBER;
  l_index         NUMBER;

  WSH_PLANNED_TRIP_NOT_MATCH EXCEPTION;

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;
  --
  --

  l_trip_count :=  x_trip_unassigns.count;
  l_stop_count :=  x_obsoleted_stops.count;

  -- bug 3303766: mark the last x_trip_unassigns record that was created
  --  by the leg mapping process in API generate_lock_candidates
  l_unassign_mark := x_trip_unassigns.COUNT;
  IF l_unassign_mark > 0 THEN
    l_unassign_mark := x_trip_unassigns.LAST;
  END IF;


  -- Loop through the list of trips in the plan.

  FOR i in 1.. x_plan_trips.count LOOP

    -- Skip if trip is not mapped to an existing trip.

    IF x_plan_trips(i).trip_id IS NOT NULL THEN -- {

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'looping x_plan_trips(i).trip_id', x_plan_trips(i).trip_id);
      END IF;

      l_stops_start_index := x_plan_trips(i).stop_base_index;

      FOR  s IN c_stops_in_trip(x_plan_trips(i).trip_id)
      LOOP

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'looping stop_id to match plan', s.stop_id);
        END IF;

        l_stop_matches := 'N';
        l_stop_index := l_stops_start_index;

        -- l_stops_start_index becomes NULL when the last plan stop is mapped.
        -- The last trip being mapped might have extra stops that need to be removed.
        IF l_stop_index IS NOT NULL THEN
          LOOP
          EXIT WHEN (x_plan_stops(l_stop_index).trip_index <> i);

            IF (x_plan_stops(l_stop_index).stop_id = s.stop_id)
            AND (x_plan_stops(l_stop_index).planned_arrival_date = s.planned_arrival_date) THEN

               l_stop_matches := 'Y';
               l_stops_start_index := x_plan_stops.NEXT(l_stop_index);
               IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name, 'stop matches index', l_stop_index);
                 WSH_DEBUG_SV.log(l_module_name, 'l_stops_start_index', l_stops_start_index);
               END IF;
               EXIT;

            ELSIF (x_plan_stops(l_stop_index).planned_arrival_date >  s.planned_arrival_date) THEN
               EXIT;
            END IF;
            l_stop_index := x_plan_stops.NEXT(l_stop_index);

            IF l_stop_index IS NULL THEN
               EXIT;
            END IF;

          END LOOP;
        END IF;


        IF     l_stop_matches = 'N' THEN
          IF l_stop_index IS NOT NULL AND NVL(s.physical_stop_id, -1) = x_plan_stops(l_stop_index).stop_id THEN
            -- linked stops are considered to match the physical stop
            l_stop_matches := 'Y';

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'matching linked stop', s.stop_id);
            END IF;

            BEGIN
              wsh_trip_stops_pvt.lock_trip_stop_no_compare(
                    p_stop_id => s.stop_id);
            EXCEPTION
              WHEN OTHERS THEN
                   stamp_interface_error(
                               p_group_id            => x_context.group_id,
                               p_entity_table_name   => 'WSH_TRIP_INTERFACE',
                               p_entity_interface_id => x_plan_trips(i).trip_interface_id,
                               p_message_name        => 'WSH_TP_F_NO_LOCK_STOP',
                               p_token_1_name        => 'TRIP_NAME',
                               p_token_1_value       => WSH_TRIPS_PVT.get_name(x_plan_trips(i).trip_id),
                               x_errors_tab          => x_errors_tab,
                               x_return_status       => x_return_status);
                   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                   IF l_debug_on THEN
                     WSH_DEBUG_SV.pop(l_module_name);
                   END IF;
                   RETURN;
            END;

          ELSE

            -- Fail plan if a stop in a firmed or planned trip does not match

            IF NVL(x_plan_trips(i).wsh_planned_flag,'N') <> 'N' THEN

               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'plan does not match firmed trip having stop_id', s.stop_id);
               END IF;

               Stamp_Interface_Error(p_group_id => x_context.group_id,
                                     p_entity_table_name => 'WSH_TRIPS_INTERFACE',
                                     p_entity_interface_id => x_plan_trips(i).trip_interface_id,
                                     p_message_name => 'WSH_TP_F_PLAN_TRIP_NOT_MATCH',
                                     p_token_1_name => 'PLAN_TRIP_NUM',
                                     p_token_1_value => x_plan_trips(i).tp_trip_number,
                                     p_token_2_name => 'TRIP_NAME',
                                     p_token_2_value => WSH_TRIPS_PVT.get_name(x_plan_trips(i).trip_id),
                                     x_errors_tab => x_errors_tab,
                                     x_return_status => x_return_status);

               RAISE WSH_PLANNED_TRIP_NOT_MATCH;

            END IF;

            -- Lock the stop.
            BEGIN
              wsh_trip_stops_pvt.lock_trip_stop_no_compare(
                    p_stop_id => s.stop_id);
              EXCEPTION
                WHEN OTHERS THEN
                    stamp_interface_error(
                                p_group_id            => x_context.group_id,
                                p_entity_table_name   => 'WSH_TRIP_INTERFACE',
                                p_entity_interface_id => x_plan_trips(i).trip_interface_id,
                                p_message_name        => 'WSH_TP_F_NO_LOCK_STOP_UNASSIGN',
                                p_token_1_name        => 'TRIP_NAME',
                                p_token_1_value       => WSH_TRIPS_PVT.get_name(x_plan_trips(i).trip_id),
                                x_errors_tab          => x_errors_tab,
                                x_return_status       => x_return_status);
                    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    IF l_debug_on THEN
                      WSH_DEBUG_SV.pop(l_module_name);
                    END IF;
                    RETURN;
            END;

            -- Add to list of obsoleted stops.

            l_stop_count := l_stop_count + 1;
            x_obsoleted_stops(l_stop_count).trip_id := x_plan_trips(i).trip_id;
            x_obsoleted_stops(l_stop_count).stop_id := s.stop_id;
          END IF;

        END IF;

        FOR leg in c_legs_in_trip(s.stop_id) LOOP

          -- Check if this delivery has already been added to the unassigned list.
          -- This can happen as the delivery is attached to both the pickup as
          -- well as the dropoff stop, and we are looping through all the stops for
          -- that trip.

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'looping leg to match trip: delivery_id', leg.delivery_id);
          END IF;

          l_delivery_unassigned := 'N';

          FOR k in 1.. l_temp_unassigned_dels.count LOOP

              IF l_temp_unassigned_dels(k) = leg.delivery_id THEN

                 l_delivery_unassigned := 'Y';
                 EXIT;

              END IF;

          END LOOP;


          IF l_delivery_unassigned = 'N' THEN

            l_delivery_matches := 'N';

            IF l_stop_matches = 'Y' THEN

               FOR j in 1..x_plan_deliveries.count LOOP

                   IF (x_plan_deliveries(j).delivery_id = leg.delivery_id) THEN

                      l_delivery_matches := 'Y';

                      EXIT;

                   END IF;

               END LOOP;

            END IF;



            IF l_delivery_matches = 'N' THEN

                -- Fail plan if a delivery in a firmed trip does not match.
                IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'plan does not match trip having delivery_id', leg.delivery_id);
                END IF;

                IF NVL(x_plan_trips(i).wsh_planned_flag,'N') =  'F' THEN
                   Stamp_Interface_Error(p_group_id => x_context.group_id,
                                         p_entity_table_name => 'WSH_TRIPS_INTERFACE',
                                         p_entity_interface_id => x_plan_trips(i).trip_interface_id,
                                         p_message_name => 'WSH_TP_F_PLAN_TRIP_NOT_MATCH',
                                         x_errors_tab => x_errors_tab,
                                         x_return_status => x_return_status);

                   RAISE WSH_PLANNED_TRIP_NOT_MATCH;

                END IF;

                -- bug 3303766: make sure x_trip_unassigns does not already have this unassignment
                --  which would be populated at time of mapping the delivery's leg.
                --  Possible scenario: This delivery may need to be unassigned from the TE trip because
                --    its plan stops do not match the TE stops but another delivery may reuse that
                --    TE trip which is to carry both deliveries.
                --
                --  Scan only the x_trip_unassigns records created by the leg mapping process
                --  in the API generate_lock_candidates.
                IF l_unassign_mark > 0 THEN
                  l_index := x_trip_unassigns.FIRST;
                  WHILE l_index <= l_unassign_mark LOOP
                     IF     x_trip_unassigns(l_index).trip_id     = x_plan_trips(i).trip_id
                        AND x_trip_unassigns(l_index).delivery_id = leg.delivery_id THEN
                       l_delivery_matches := 'Y';
                       EXIT;
                     END IF;
                     l_index := x_trip_unassigns.NEXT(l_index);
                   END LOOP;
                END IF;

                IF l_delivery_matches = 'N' THEN
                  -- Lock the delivery.
                  BEGIN
                    wsh_new_deliveries_pvt.lock_dlvy_no_compare(
                           p_delivery_id => leg.delivery_id);
                    EXCEPTION
                      WHEN OTHERS THEN
                          l_tmp_entity_name :=  WSH_NEW_DELIVERIES_PVT.Get_Name(leg.delivery_id);
                          stamp_interface_error(
                                 p_group_id            => x_context.group_id,
                                 p_entity_table_name   => 'WSH_TRIP_INTERFACE',
                                 p_entity_interface_id => x_plan_trips(i).trip_interface_id,
                                 p_message_name        => 'WSH_TP_F_NO_LOCK_DEL_UNASSIGN',
                                 p_token_1_name        => 'DELIVERY_NAME',
                                 p_token_1_value       => l_tmp_entity_name,
                                 x_errors_tab          => x_errors_tab,
                                 x_return_status       => x_return_status);
                          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                          IF l_debug_on THEN
                            WSH_DEBUG_SV.pop(l_module_name);
                          END IF;
                          RETURN;
                  END;

                  -- Add to list of deliveries to be unassigned.

                  l_trip_count := l_trip_count + 1;
                  x_trip_unassigns(l_trip_count).delivery_id     := leg.delivery_id;
                  x_trip_unassigns(l_trip_count).organization_id := leg.organization_id;
                  x_trip_unassigns(l_trip_count).trip_id         := x_plan_trips(i).trip_id;
                  x_trip_unassigns(l_trip_count).trip_index      := i;
                  x_trip_unassigns(l_trip_count).pickup_stop_id  := leg.pick_up_stop_id;
                  x_trip_unassigns(l_trip_count).dropoff_stop_id := leg.drop_off_stop_id;

                END IF;

                -- track this delivery internally so we can skip it when we find its drop off stop.
                l_temp_unassigned_dels(l_temp_unassigned_dels.count + 1) := leg.delivery_id;

            END IF;

          END IF;

        END LOOP;

      END LOOP;

      -- Refresh this list for each trip.

      l_temp_unassigned_dels.delete;

    END IF; --}

  END LOOP;

  --
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION
    WHEN WSH_PLANNED_TRIP_NOT_MATCH THEN
      IF c_stops_in_trip%isopen THEN
         CLOSE c_stops_in_trip;
      END IF;
      IF c_legs_in_trip%isopen THEN
         CLOSE c_legs_in_trip;
      END IF;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_PLANNED_DEL_NOT_MATCH');
      END IF;
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TP_RELEASE.MATCH_TRIPS',
                        l_module_name);

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END match_trips;


--
--  Procedure:          debug_dump_context
--  Parameters:
--               x_context             context in this session
--               x_plan_details        list of delivery details mapped to interface lines
--               x_track_conts         list of topmost containers to track
--               x_plan_deliveries     list of deliveries mapped to interface deliveries
--               x_plan_legs           list of delivery legs mapped to interface legs
--               x_plan_stops          list of stops mapped to interface stops
--               x_plan_trips          list of trips mapped to interface trips
--               x_plan_trip_moves     list of trip moves mapped to interface trip moves (FTE)
--               x_plan_moves          list of moves mapped to interface moves (FTE)
--               x_used_details        list of delivery details partially used by the plan
--               x_delivery_unassigns  list of delivery lines to unassign from their deliveries
--               x_trip_unassigns      list of deliveries to unassign from their trips
--               x_obsoleted_stops     list of mapped trips' stops that are not mapped in the plan
--               x_obsoleted_trip_moves  list of mapped trips' moves that are not mapped in the plan
--
--  Description:
--               Dump the state for debugging purposes.
--

PROCEDURE debug_dump_context(
           x_context                  IN context_rec_type,
           x_plan_details             IN plan_detail_tab_type,
           x_track_conts              IN track_cont_tab_type,
           x_plan_deliveries          IN plan_delivery_tab_type,
           x_plan_legs                IN plan_leg_tab_type,
           x_plan_stops               IN plan_stop_tab_type,
           x_plan_trips               IN plan_trip_tab_type,
           x_plan_trip_moves          IN WSH_FTE_TP_INTEGRATION.plan_trip_move_tab_type,
           x_plan_moves               IN WSH_FTE_TP_INTEGRATION.plan_move_tab_type,
           x_used_details             IN used_details_tab_type,
           x_delivery_unassigns       IN delivery_unassign_tab_type,
           x_trip_unassigns           IN trip_unassign_tab_type,
           x_obsoleted_stops          IN obsoleted_stop_tab_type,
           x_obsoleted_trip_moves     IN WSH_FTE_TP_INTEGRATION.obsoleted_trip_move_tab_type
          )
IS
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DEBUG_DUMP_CONTEXT';
  --
  l_debug_on BOOLEAN;
  --
  l_index NUMBER;
  l_string VARCHAR2(2000);
BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
       --
  IF l_debug_on IS NULL THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);


    WSH_DEBUG_SV.logmsg(l_module_name, '------- start of dump -----------');

    -- dump x_context
    WSH_DEBUG_SV.log(l_module_name, 'x_context.group_id', x_context.group_id);

    IF x_context.wms_in_group THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_context.wms_in_group', 'TRUE');
    ELSE
      WSH_DEBUG_SV.log(l_module_name, 'x_context.wms_in_group', 'FALSE');
    END IF;
    WSH_DEBUG_SV.log(l_module_name, 'x_context.auto_tender_flag', x_context.auto_tender_flag);
    WSH_DEBUG_SV.log(l_module_name, 'x_context.linked_trip_count', x_context.linked_trip_count);


    -- dump x_plan_details
    WSH_DEBUG_SV.log(l_module_name, 'x_plan_details.COUNT', x_plan_details.COUNT);
    IF x_plan_details.COUNT > 0  THEN
      l_index := x_plan_details.FIRST;
      WHILE l_index IS NOT NULL LOOP
       --
       l_string :=              'dd_interface_id=' || x_plan_details(l_index).dd_interface_id;
       l_string := l_string || ', dd=' || x_plan_details(l_index).delivery_detail_id;
       l_string := l_string || ', tp_dd=' || x_plan_details(l_index).tp_delivery_detail_id;
       l_string := l_string || ', map_qty=' || x_plan_details(l_index).mapped_quantity || ' ' || x_plan_details(l_index).mapped_quantity_uom;
       l_string := l_string || ', split=' || x_plan_details(l_index).map_split_flag;
       l_string := l_string || ', RS=' || x_plan_details(l_index).released_status;
       l_string := l_string || ', LD=' || x_plan_details(l_index).line_direction;
       l_string := l_string || ', top_cont_id=' || x_plan_details(l_index).topmost_cont_id;
       l_string := l_string || ', cur_del_id=' || x_plan_details(l_index).current_delivery_id;
       l_string := l_string || ', target_del_index=' || x_plan_details(l_index).target_delivery_index;
       --
       WSH_DEBUG_SV.log(l_module_name, 'iline(' || l_index || ')', l_string);
       l_index := x_plan_details.NEXT(l_index);
      END LOOP;
    END IF;

    -- dump x_track_conts
    WSH_DEBUG_SV.log(l_module_name, 'x_track_conts.COUNT', x_track_conts.COUNT);
    IF x_track_conts.COUNT > 0  THEN
      l_index := x_track_conts.FIRST;
      WHILE l_index IS NOT NULL LOOP
       --
       l_string := 'topmost_cont_id=' || x_track_conts(l_index).topmost_cont_id;
       l_string := l_string || ', current_delivery_id=' || x_track_conts(l_index).current_delivery_id;
       l_string := l_string || ', target_delivery_index=' || x_track_conts(l_index).target_delivery_index;
       IF x_track_conts(l_index).lines_staged THEN
         l_string := l_string || ', lines_staged=TRUE';
       ELSE
         l_string := l_string || ', lines_staged=FALSE';
       END IF;
       l_string := l_string || ', lpn_id=' || x_track_conts(l_index).lpn_id;
       --
       WSH_DEBUG_SV.log(l_module_name, 'tcont(' || l_index || ')', l_string);
       l_index := x_track_conts.NEXT(l_index);
      END LOOP;
    END IF;

    -- dump x_plan_deliveries
    WSH_DEBUG_SV.log(l_module_name, 'x_plan_deliveries.COUNT', x_plan_deliveries.COUNT);
    IF x_plan_deliveries.COUNT > 0  THEN
      l_index := x_plan_deliveries.FIRST;
      WHILE l_index IS NOT NULL LOOP
       --
       l_string := 'del_interface_id=' || x_plan_deliveries(l_index).del_interface_id;
       l_string := l_string || ', del=' || x_plan_deliveries(l_index).delivery_id;
       l_string := l_string || ', tp_del=' || x_plan_deliveries(l_index).tp_delivery_number;
       l_string := l_string || ', planned=' || x_plan_deliveries(l_index).planned_flag;
       l_string := l_string || ', wsh_planned=' || x_plan_deliveries(l_index).wsh_planned_flag;
       l_string := l_string || ', SD=' || x_plan_deliveries(l_index).shipment_direction;
       l_string := l_string || ', IPU=' || x_plan_deliveries(l_index).initial_pickup_location_id;
       l_string := l_string || '-' || FND_DATE.DATE_TO_CANONICAL(x_plan_deliveries(l_index).initial_pickup_date);
       l_string := l_string || ', UDO=' ||  x_plan_deliveries(l_index).ultimate_dropoff_location_id;
       l_string := l_string || ', P_UDO=' ||  x_plan_deliveries(l_index).physical_ultimate_do_loc_id;
       l_string := l_string || '-' || FND_DATE.DATE_TO_CANONICAL(x_plan_deliveries(l_index).ultimate_dropoff_date);
       l_string := l_string || ', ilines_count=' || x_plan_deliveries(l_index).ilines_count;
       l_string := l_string || ', lines_count=' || x_plan_deliveries(l_index).lines_count;
       l_string := l_string || ', s_lines_count=' || x_plan_deliveries(l_index).s_lines_count;
       l_string := l_string || ', d_conts_count=' || x_plan_deliveries(l_index).dangling_conts_count;
       l_string := l_string || ', wms_org_flag=' || x_plan_deliveries(l_index).wms_org_flag;
       l_string := l_string || ', leg_base_index=' || x_plan_deliveries(l_index).leg_base_index;
       --
       WSH_DEBUG_SV.log(l_module_name, 'idel(' || l_index || ')', l_string);
       l_index := x_plan_deliveries.NEXT(l_index);
      END LOOP;
    END IF;

    -- dump x_plan_legs
    WSH_DEBUG_SV.log(l_module_name, 'x_plan_legs.COUNT', x_plan_legs.COUNT);
    IF x_plan_legs.COUNT > 0  THEN
      l_index := x_plan_legs.FIRST;
      WHILE l_index IS NOT NULL LOOP
       --
       l_string := 'leg_interface_id=' || x_plan_legs(l_index).leg_interface_id;
       l_string := l_string || ', leg_id=' || x_plan_legs(l_index).delivery_leg_id;
       l_string := l_string || ', del_interface_id=' || x_plan_legs(l_index).del_interface_id;
       l_string := l_string || ', delivery_index=' || x_plan_legs(l_index).delivery_index;
       l_string := l_string || ', pickup_stop_index=' || x_plan_legs(l_index).pickup_stop_index;
       l_string := l_string || ', dropoff_stop_index=' || x_plan_legs(l_index).dropoff_stop_index;
       l_string := l_string || ', trip_index=' || x_plan_legs(l_index).trip_index;
       --
       WSH_DEBUG_SV.log(l_module_name, 'ileg(' || l_index || ')', l_string);
       l_index := x_plan_legs.NEXT(l_index);
      END LOOP;
    END IF;

    -- dump x_plan_stops
    WSH_DEBUG_SV.log(l_module_name, 'x_plan_stops.COUNT', x_plan_stops.COUNT);
    IF x_plan_stops.COUNT > 0  THEN
      l_index := x_plan_stops.FIRST;
      WHILE l_index IS NOT NULL LOOP
       l_string := '';
       --
       l_string := 'stop_interface_id=' || x_plan_stops(l_index).stop_interface_id;
       l_string := l_string || ', stop=' || x_plan_stops(l_index).stop_id;
       l_string := l_string || ', tp_stop=' || x_plan_stops(l_index).tp_stop_id;
       l_string := l_string || ', trip_index=' || x_plan_stops(l_index).trip_index;
       l_string := l_string || ', stop_location_id=' || x_plan_stops(l_index).stop_location_id;
       l_string := l_string || ', stop_sequence=' || x_plan_stops(l_index).stop_sequence_number;
       l_string := l_string || ', planned_arr=' || FND_DATE.DATE_TO_CANONICAL(x_plan_stops(l_index).planned_arrival_date);
       l_string := l_string || ', planned_dep=' || FND_DATE.DATE_TO_CANONICAL(x_plan_stops(l_index).planned_departure_date);
       l_string := l_string || ', shipments_type_flag=' || x_plan_stops(l_index).shipments_type_flag;
       l_string := l_string || ', int_do_count=' || x_plan_stops(l_index).internal_do_count;
       l_string := l_string || ', ext_pd_count=' || x_plan_stops(l_index).external_pd_count;
       l_string := l_string || ', wsh_phys_loc=' || x_plan_stops(l_index).wsh_physical_location_id;
       --
       WSH_DEBUG_SV.log(l_module_name, 'istop(' || l_index || ')', l_string);
       l_index := x_plan_stops.NEXT(l_index);
      END LOOP;
    END IF;

    -- dump x_plan_trips
    WSH_DEBUG_SV.log(l_module_name, 'x_plan_trips.COUNT', x_plan_trips.COUNT);
    IF x_plan_trips.COUNT > 0  THEN
      l_index := x_plan_trips.FIRST;
      WHILE l_index IS NOT NULL LOOP
       --
       l_string := 'trip_interface_id=' || x_plan_trips(l_index).trip_interface_id;
       l_string := l_string || ', trip=' || x_plan_trips(l_index).trip_id;
       l_string := l_string || ', tp_trip=' || x_plan_trips(l_index).tp_trip_number;
       l_string := l_string || ', planned=' || x_plan_trips(l_index).planned_flag;
       l_string := l_string || ', wsh_planned=' || x_plan_trips(l_index).wsh_planned_flag;
       l_string := l_string || ', stop_base_index=' || x_plan_trips(l_index).stop_base_index;
       l_string := l_string || ', shipments_type_flag=' || x_plan_trips(l_index).shipments_type_flag;
       l_string := l_string || ', lane_id=' || x_plan_trips(l_index).lane_id;
       l_string := l_string || ', linked_stop_count=' || x_plan_trips(l_index).linked_stop_count;
       --
       WSH_DEBUG_SV.log(l_module_name, 'itrip(' || l_index || ')', l_string);
       l_index := x_plan_trips.NEXT(l_index);
      END LOOP;
    END IF;

    -- dump x_plan_trip_moves
    WSH_DEBUG_SV.log(l_module_name, 'x_plan_trip_moves.COUNT', x_plan_trip_moves.COUNT);
    IF x_plan_trip_moves.COUNT > 0  THEN
      l_index := x_plan_trip_moves.FIRST;
      WHILE l_index IS NOT NULL LOOP
       --
       l_string := 'trip_move_interface_id=' || x_plan_trip_moves(l_index).trip_move_interface_id;
       l_string := l_string || ', trip_move_id=' || x_plan_trip_moves(l_index).trip_move_id;
       l_string := l_string || ', move_interface=' || x_plan_trip_moves(l_index).move_interface_id;
       l_string := l_string || ', move_index=' || x_plan_trip_moves(l_index).move_index;
       l_string := l_string || ', trip_interface=' || x_plan_trip_moves(l_index).trip_interface_id;
       l_string := l_string || ', trip_index=' || x_plan_trip_moves(l_index).trip_index;
       l_string := l_string || ', sequence_number=' || x_plan_trip_moves(l_index).sequence_number;
       --
       WSH_DEBUG_SV.log(l_module_name, 'itripmove(' || l_index || ')', l_string);
       l_index := x_plan_trip_moves.NEXT(l_index);
      END LOOP;
    END IF;

    -- dump x_plan_moves
    WSH_DEBUG_SV.log(l_module_name, 'x_plan_moves.COUNT', x_plan_moves.COUNT);
    IF x_plan_moves.COUNT > 0  THEN
      l_index := x_plan_moves.FIRST;
      WHILE l_index IS NOT NULL LOOP
       --
       l_string := 'move_interface_id=' || x_plan_moves(l_index).move_interface_id;
       l_string := l_string || ', move_id=' || x_plan_moves(l_index).move_id;
       l_string := l_string || ', move_type_code=' || x_plan_moves(l_index).move_type_code;
       l_string := l_string || ', lane_id=' || x_plan_moves(l_index).lane_id;
       l_string := l_string || ', service_level=' || x_plan_moves(l_index).service_level;
       l_string := l_string || ', planned=' || x_plan_moves(l_index).planned_flag;
       l_string := l_string || ', fte_planned=' || x_plan_moves(l_index).fte_planned_flag;
       l_string := l_string || ', cm_trip_number=' || x_plan_moves(l_index).cm_trip_number;
       l_string := l_string || ', trip_move_base_index=' || x_plan_moves(l_index).trip_move_base_index;
       --
       WSH_DEBUG_SV.log(l_module_name, 'imove(' || l_index || ')', l_string);
       l_index := x_plan_moves.NEXT(l_index);
      END LOOP;
    END IF;

    -- dump x_used_details
    WSH_DEBUG_SV.log(l_module_name, 'x_used_details.COUNT', x_used_details.COUNT);
    IF x_used_details.COUNT > 0  THEN
      l_index := x_used_details.FIRST;
      WHILE l_index IS NOT NULL LOOP
       l_string := '';
       --
       l_string := 'delivery_detail_id=' || x_used_details(l_index).delivery_detail_id;
       l_string := l_string || ', dd_interface_id=' || x_used_details(l_index).dd_interface_id;
       l_string := l_string || ', available_qty=' || x_used_details(l_index).available_quantity || ' ' || x_used_details(l_index).available_quantity_uom;
       l_string := l_string || ', current_del=' || x_used_details(l_index).current_delivery_id;
       l_string := l_string || ', split_count=' || x_used_details(l_index).split_count;
       --
       WSH_DEBUG_SV.log(l_module_name, 'used_details(' || l_index || ')', l_string);
       l_index := x_used_details.NEXT(l_index);
      END LOOP;
    END IF;

    -- dump x_delivery_unassigns
    WSH_DEBUG_SV.log(l_module_name, 'x_delivery_unassigns.COUNT', x_delivery_unassigns.COUNT);
    IF x_delivery_unassigns.COUNT > 0  THEN
      l_index := x_delivery_unassigns.FIRST;
      WHILE l_index IS NOT NULL LOOP
       l_string := '';
       --
       l_string := 'delivery_detail_id=' || x_delivery_unassigns(l_index).delivery_detail_id;
       l_string := l_string || ', delivery_id=' || x_delivery_unassigns(l_index).delivery_id;
       l_string := l_string || ', wms_org_flag=' || x_delivery_unassigns(l_index).wms_org_flag;
       l_string := l_string || ', source=' || x_delivery_unassigns(l_index).source_code;
       l_string := l_string || ', RS=' || x_delivery_unassigns(l_index).released_status;
       l_string := l_string || ', lpn_id=' || x_delivery_unassigns(l_index).lpn_id;
       l_string := l_string || ', plan_dd_index=' || x_delivery_unassigns(l_index).plan_dd_index;
       l_string := l_string || ', plan_del_index=' || x_delivery_unassigns(l_index).plan_del_index;
       --
       WSH_DEBUG_SV.log(l_module_name, 'del_unassigns(' || l_index || ')', l_string);
       l_index := x_delivery_unassigns.NEXT(l_index);
      END LOOP;
    END IF;

    -- dump x_trip_unassigns
    WSH_DEBUG_SV.log(l_module_name, 'x_trip_unassigns.COUNT', x_trip_unassigns.COUNT);
    IF x_trip_unassigns.COUNT > 0  THEN
      l_index := x_trip_unassigns.FIRST;
      WHILE l_index IS NOT NULL LOOP
       --
       l_string := 'delivery_id=' || x_trip_unassigns(l_index).delivery_id;
       l_string := l_string || ', trip_id=' || x_trip_unassigns(l_index).trip_id;
       l_string := l_string || ', trip_index=' || x_trip_unassigns(l_index).trip_index;
       l_string := l_string || ', delivery_leg_id=' || x_trip_unassigns(l_index).delivery_leg_id;
       l_string := l_string || ', pickup_stop_id=' || x_trip_unassigns(l_index).pickup_stop_id;
       l_string := l_string || ', dropoff_stop_id=' || x_trip_unassigns(l_index).dropoff_stop_id;
       --
       WSH_DEBUG_SV.log(l_module_name, 'trip_unassigns(' || l_index || ')', l_string);
       l_index := x_trip_unassigns.NEXT(l_index);
      END LOOP;
    END IF;

    -- dump x_obsoleted_stops
    WSH_DEBUG_SV.log(l_module_name, 'x_obsoleted_stops.COUNT', x_obsoleted_stops.COUNT);
    IF x_obsoleted_stops.COUNT > 0  THEN
      l_index := x_obsoleted_stops.FIRST;
      WHILE l_index IS NOT NULL LOOP
       --
       l_string := 'trip_id=' || x_obsoleted_stops(l_index).trip_id;
       l_string := l_string || ', stop_id=' || x_obsoleted_stops(l_index).stop_id;
       --
       WSH_DEBUG_SV.log(l_module_name, 'obs_stops(' || l_index || ')', l_string);
       l_index := x_obsoleted_stops.NEXT(l_index);
      END LOOP;
    END IF;

    -- dump x_obsoleted_trip_moves
    WSH_DEBUG_SV.log(l_module_name, 'x_obsoleted_trip_moves.COUNT', x_obsoleted_trip_moves.COUNT);
    IF x_obsoleted_trip_moves.COUNT > 0  THEN
      l_index := x_obsoleted_trip_moves.FIRST;
      WHILE l_index IS NOT NULL LOOP
       --
       l_string := 'trip_move_id=' || x_obsoleted_trip_moves(l_index).trip_move_id;
       l_string := l_string || ', move_id=' || x_obsoleted_trip_moves(l_index).move_id;
       l_string := l_string || ', trip_id=' || x_obsoleted_trip_moves(l_index).trip_id;
       l_string := l_string || ', sequence_number=' || x_obsoleted_trip_moves(l_index).sequence_number;
       --
       WSH_DEBUG_SV.log(l_module_name, 'obs_t_moves(' || l_index || ')', l_string);
       l_index := x_obsoleted_trip_moves.NEXT(l_index);
      END LOOP;
    END IF;

    WSH_DEBUG_SV.logmsg(l_module_name, '------- end of dump -----------');

    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'WSH_TP_RELEASE.debug_dump_context',
                      l_module_name);

    IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    RETURN;
END debug_dump_context;



--
--  Procedure:          copy_delivery_record
--  Parameters:
--               p_plan_delivery_rec   plan delivery record
--               x_delivery_attrs_rec  output delivery attributes record
--               x_return_status       standard return status
--  Description:
--               transforms plan data structure into group api data structure for delivery.
--
PROCEDURE copy_delivery_record(
           p_plan_delivery_rec   IN            plan_delivery_rec_type,
           x_delivery_attrs_rec     OUT NOCOPY wsh_new_deliveries_pvt.delivery_rec_type,
           x_return_status          OUT NOCOPY VARCHAR2
          ) IS
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'COPY_DELIVERY_RECORD';
  --
  l_debug_on BOOLEAN;
  --
  CURSOR c_del_info(x_delivery_id NUMBER) IS
     SELECT name,
            gross_weight,
            net_weight,
            weight_uom_code,
            volume,
            volume_uom_code,
            customer_id,
            intmed_ship_to_location_id,
            fob_code,
            freight_terms_code,
            ship_method_code,
            carrier_id,
            service_level,
            mode_of_transport,
            vendor_id,
            party_id,
            shipping_control,
            shipment_direction
     FROM   wsh_new_deliveries
     WHERE  delivery_id = x_delivery_id;

  l_group_flags wsh_delivery_autocreate.group_by_flags_rec_type;
  l_return_status VARCHAR2(1);
  l_del_info c_del_info%ROWTYPE;
BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
       --
  IF l_debug_on IS NULL THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  x_delivery_attrs_rec.DELIVERY_ID                  := p_plan_delivery_rec.delivery_id;

  IF     p_plan_delivery_rec.delivery_id IS NOT NULL THEN
     -- look up delivery info if it exists and key values are missing.
    OPEN   c_del_info(p_plan_delivery_rec.delivery_id);
    FETCH  c_del_info INTO l_del_info;
    IF c_del_info%NOTFOUND THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'delivery_id is not found', p_plan_delivery_rec.delivery_id);
      END IF;
      -- setting this value to NULL will cause an error.
      x_delivery_attrs_rec.DELIVERY_ID := NULL;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    END IF;
    CLOSE  c_del_info;
    IF x_delivery_attrs_rec.DELIVERY_ID IS NULL THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      RETURN;
    END IF;
  END IF;


  -- if delivery is outbound, determine which enforced attributes
  -- we need to set when creating or update the delivery.
  --  At this point, this should succeed because we have already matched groups.
  IF NVL(p_plan_delivery_rec.shipment_direction, 'O') IN ('O', 'IO') THEN
    WSH_DELIVERY_AUTOCREATE.get_group_by_attr (
                p_organization_id => p_plan_delivery_rec.organization_id,
                x_group_by_flags  => l_group_flags,
                x_return_status   => l_return_status);

    IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                         WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
       x_return_status := l_return_status;
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,
                          'create/update del will fail because grouping attrs could not be found for org',
                          p_plan_delivery_rec.organization_id);
         WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       RETURN;
    END IF;
  ELSE
    -- inbound or drop
    IF p_plan_delivery_rec.shipment_direction = 'D' THEN
      l_group_flags.customer := 'Y';
    ELSE
      l_group_flags.customer := 'N';
    END IF;
    l_group_flags.intmed        := 'N';
    l_group_flags.fob           := 'N';
    l_group_flags.freight_terms := 'N';
    l_group_flags.ship_method   := 'N';
    -- carrier is not used (it is part of ship method)
  END IF;


  x_delivery_attrs_rec.NAME                         := NVL(p_plan_delivery_rec.name, l_del_info.name);
  x_delivery_attrs_rec.LOADING_SEQUENCE             := p_plan_delivery_rec.loading_sequence;
  x_delivery_attrs_rec.LOADING_ORDER_FLAG           := p_plan_delivery_rec.loading_order_flag;
  x_delivery_attrs_rec.INITIAL_PICKUP_DATE          := p_plan_delivery_rec.initial_pickup_date;
  x_delivery_attrs_rec.INITIAL_PICKUP_LOCATION_ID   := p_plan_delivery_rec.initial_pickup_location_id;
  x_delivery_attrs_rec.ORGANIZATION_ID              := p_plan_delivery_rec.organization_id;
  x_delivery_attrs_rec.ULTIMATE_DROPOFF_LOCATION_ID := p_plan_delivery_rec.ultimate_dropoff_location_id;
  x_delivery_attrs_rec.ULTIMATE_DROPOFF_DATE        := p_plan_delivery_rec.ultimate_dropoff_date;
  x_delivery_attrs_rec.POOLED_SHIP_TO_LOCATION_ID   := p_plan_delivery_rec.pooled_ship_to_location_id;
  x_delivery_attrs_rec.FOB_LOCATION_ID              := p_plan_delivery_rec.fob_location_id;
  x_delivery_attrs_rec.WAYBILL                      := p_plan_delivery_rec.waybill;
  x_delivery_attrs_rec.dock_code                    := p_plan_delivery_rec.dock_code;
  x_delivery_attrs_rec.TP_DELIVERY_NUMBER           := p_plan_delivery_rec.tp_delivery_number;
  x_delivery_attrs_rec.TP_PLAN_NAME                 := p_plan_delivery_rec.tp_plan_name;
  x_delivery_attrs_rec.IGNORE_FOR_PLANNING          := 'N';


  x_delivery_attrs_rec.WEIGHT_UOM_CODE              := p_plan_delivery_rec.weight_uom_code;
  x_delivery_attrs_rec.VOLUME_UOM_CODE              := p_plan_delivery_rec.volume_uom_code;

  IF p_plan_delivery_rec.delivery_id IS NOT NULL THEN
    -- W/V: existing delivery has W/V; convert W/V to the plan UOMs
    x_delivery_attrs_rec.GROSS_WEIGHT := WSH_WV_UTILS.Convert_Uom(
                                           from_uom => l_del_info.weight_uom_code,
                                           to_uom   => p_plan_delivery_rec.weight_uom_code,
                                           quantity => l_del_info.gross_weight);

    x_delivery_attrs_rec.NET_WEIGHT   := WSH_WV_UTILS.Convert_Uom(
                                           from_uom => l_del_info.weight_uom_code,
                                           to_uom   => p_plan_delivery_rec.weight_uom_code,
                                           quantity => l_del_info.net_weight);
    x_delivery_attrs_rec.VOLUME       := WSH_WV_UTILS.Convert_Uom(
                                           from_uom => l_del_info.volume_uom_code,
                                           to_uom   => p_plan_delivery_rec.volume_uom_code,
                                           quantity => l_del_info.volume);

    -- See if UOM conversion is successful. If not, revert back to the old UOM.
    IF (NVL(x_delivery_attrs_rec.GROSS_WEIGHT, 0))  = 0 and (NVL(l_del_info.gross_weight, 0) <> 0) THEN

       x_delivery_attrs_rec.GROSS_WEIGHT := l_del_info.gross_weight;
       x_delivery_attrs_rec.NET_WEIGHT := l_del_info.net_weight;
       x_delivery_attrs_rec.WEIGHT_UOM_CODE := l_del_info.weight_uom_code;

    END IF;
    IF (NVL(x_delivery_attrs_rec.VOLUME, 0))  = 0 and (NVL(l_del_info.volume, 0) <> 0) THEN

       x_delivery_attrs_rec.VOLUME := l_del_info.volume;
       x_delivery_attrs_rec.VOLUME_UOM_CODE := l_del_info.volume_uom_code;

    END IF;



    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'l_del_info.GROSS_WEIGHT', l_del_info.GROSS_WEIGHT);
      WSH_DEBUG_SV.log(l_module_name, 'l_del_info.NET_WEIGHT', l_del_info.NET_WEIGHT);
      WSH_DEBUG_SV.log(l_module_name, 'l_del_info.VOLUME', l_del_info.VOLUME);
      WSH_DEBUG_SV.log(l_module_name, 'x_delivery_attrs_rec.GROSS_WEIGHT', x_delivery_attrs_rec.GROSS_WEIGHT);
      WSH_DEBUG_SV.log(l_module_name, 'x_delivery_attrs_rec.NET_WEIGHT', x_delivery_attrs_rec.NET_WEIGHT);
      WSH_DEBUG_SV.log(l_module_name, 'x_delivery_attrs_rec.VOLUME', x_delivery_attrs_rec.VOLUME);
    END IF;
  ELSE
    -- W/V: new delivery is empty; therefore W/V = 0.
    x_delivery_attrs_rec.GROSS_WEIGHT := 0;
    x_delivery_attrs_rec.NET_WEIGHT   := 0;
    x_delivery_attrs_rec.VOLUME       := 0;
  END IF;
  x_delivery_attrs_rec.ADDITIONAL_SHIPMENT_INFO     := p_plan_delivery_rec.additional_shipment_info;
  x_delivery_attrs_rec.CURRENCY_CODE                := p_plan_delivery_rec.currency_code;
  x_delivery_attrs_rec.NUMBER_OF_LPN	            := NULL;


  -- populate grouping attributes:
  --    Update grouping attributes from lines if enforced;
  --    otherwise, use values from the existing delivery or NULL.

  IF l_group_flags.customer = 'Y' THEN
    x_delivery_attrs_rec.CUSTOMER_ID                  := p_plan_delivery_rec.customer_id;
  ELSE
   -- TP gives us customer_id, so we may want to update the delivery with that value if not NULL.
    x_delivery_attrs_rec.CUSTOMER_ID                  := NVL(p_plan_delivery_rec.customer_id, l_del_info.customer_id);
  END IF;

  IF l_group_flags.intmed = 'Y' THEN
    x_delivery_attrs_rec.INTMED_SHIP_TO_LOCATION_ID   := p_plan_delivery_rec.intmed_ship_to_location_id;
  ELSE
    x_delivery_attrs_rec.INTMED_SHIP_TO_LOCATION_ID   := l_del_info.intmed_ship_to_location_id;
  END IF;

  IF l_group_flags.fob = 'Y' THEN
    x_delivery_attrs_rec.FOB_CODE                     := p_plan_delivery_rec.fob_code;
  ELSE
    x_delivery_attrs_rec.FOB_CODE                     := l_del_info.fob_code;
  END IF;

  IF l_group_flags.freight_terms = 'Y' THEN
    x_delivery_attrs_rec.FREIGHT_TERMS_CODE           := p_plan_delivery_rec.freight_terms_code;
  ELSE
    x_delivery_attrs_rec.FREIGHT_TERMS_CODE           := l_del_info.freight_terms_code;
  END IF;

  IF l_group_flags.ship_method = 'Y' THEN
    x_delivery_attrs_rec.SHIP_METHOD_CODE             := NULL; -- to be derived from its components
    x_delivery_attrs_rec.CARRIER_ID                   := p_plan_delivery_rec.carrier_id;
    x_delivery_attrs_rec.service_level                := p_plan_delivery_rec.service_level;
    x_delivery_attrs_rec.mode_of_transport            := p_plan_delivery_rec.mode_of_transport;
  ELSE
    x_delivery_attrs_rec.SHIP_METHOD_CODE             := l_del_info.ship_method_code;
    x_delivery_attrs_rec.CARRIER_ID                   := l_del_info.carrier_id;
    x_delivery_attrs_rec.service_level                := l_del_info.service_level;
    x_delivery_attrs_rec.mode_of_transport            := l_del_info.mode_of_transport;
  END IF;

  -- inbound grouping attributes are mandatory (customer is covered for Drop):
  IF p_plan_delivery_rec.shipment_direction IN ('I', 'D')  THEN
    x_delivery_attrs_rec.party_id                     := p_plan_delivery_rec.party_id;
    x_delivery_attrs_rec.shipping_control             := p_plan_delivery_rec.shipping_control;
    x_delivery_attrs_rec.vendor_id                    := p_plan_delivery_rec.vendor_id;
  ELSE
    x_delivery_attrs_rec.party_id                     := l_del_info.party_id;
    x_delivery_attrs_rec.shipping_control             := l_del_info.shipping_control;
    x_delivery_attrs_rec.vendor_id                    := l_del_info.vendor_id;
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    IF c_del_info%ISOPEN THEN
      CLOSE c_del_info;
    END IF;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'WSH_TP_RELEASE.copy_delivery_record',
                      l_module_name);

    IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END copy_delivery_record;



--
--  Procedure:          copy_trip_record
--  Parameters:
--               p_plan_trip_rec   plan trip record
--               x_trip_attrs_rec  output trip attributes record
--  Description:
--               transforms plan data structure into group api data structure for trip.
--
PROCEDURE copy_trip_record(
           p_plan_trip_rec   IN            plan_trip_rec_type,
           x_trip_attrs_rec     OUT NOCOPY wsh_trips_pvt.trip_rec_type
          ) IS
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'COPY_TRIP_RECORD';
  --
  l_debug_on BOOLEAN;
  --
  CURSOR c_trip_info(x_trip_id NUMBER) IS
     SELECT name,
            operator,
            load_tender_status,
            load_tender_number
     FROM   wsh_trips
     WHERE  trip_id = x_trip_id;

  l_trip_info c_trip_info%ROWTYPE;
BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
       --
  IF l_debug_on IS NULL THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
  END IF;

  x_trip_attrs_rec.TRIP_ID                      := p_plan_trip_rec.trip_id;

  IF     p_plan_trip_rec.trip_id IS NOT NULL
     AND p_plan_trip_rec.name IS NULL THEN
     -- look up trip info if it exists and key values are missing.
    OPEN   c_trip_info(p_plan_trip_rec.trip_id);
    FETCH  c_trip_info INTO l_trip_info;
    IF c_trip_info%NOTFOUND THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'trip_id is not found', p_plan_trip_rec.trip_id);
      END IF;
      -- setting this value to NULL will cause an error.
      x_trip_attrs_rec.TRIP_ID := NULL;
    END IF;
    CLOSE  c_trip_info;
    IF x_trip_attrs_rec.TRIP_ID IS NULL THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      RETURN;
    END IF;
  END IF;

  x_trip_attrs_rec.NAME                         := NVL(p_plan_trip_rec.name, l_trip_info.name);
  x_trip_attrs_rec.VEHICLE_ITEM_ID              := p_plan_trip_rec.vehicle_item_id;
  x_trip_attrs_rec.VEHICLE_ORGANIZATION_ID      := p_plan_trip_rec.vehicle_organization_id;
  x_trip_attrs_rec.VEHICLE_NUM_PREFIX           := p_plan_trip_rec.vehicle_num_prefix;
  x_trip_attrs_rec.VEHICLE_NUMBER               := p_plan_trip_rec.vehicle_number;
  x_trip_attrs_rec.CARRIER_ID                   := p_plan_trip_rec.carrier_id;
  x_trip_attrs_rec.SHIP_METHOD_CODE             := p_plan_trip_rec.ship_method_code;
  x_trip_attrs_rec.ROUTE_ID                     := p_plan_trip_rec.route_id;
  x_trip_attrs_rec.ROUTING_INSTRUCTIONS         := p_plan_trip_rec.routing_instructions;
  x_trip_attrs_rec.SERVICE_LEVEL                := p_plan_trip_rec.service_level;
  x_trip_attrs_rec.MODE_OF_TRANSPORT            := p_plan_trip_rec.mode_of_transport;
  x_trip_attrs_rec.FREIGHT_TERMS_CODE           := p_plan_trip_rec.freight_terms_code;
  x_trip_attrs_rec.SEAL_CODE                    := p_plan_trip_rec.seal_code;
  x_trip_attrs_rec.TP_PLAN_NAME                 := p_plan_trip_rec.tp_plan_name;
  x_trip_attrs_rec.TP_TRIP_NUMBER               := p_plan_trip_rec.tp_trip_number;
  x_trip_attrs_rec.SHIPMENTS_TYPE_FLAG          := p_plan_trip_rec.shipments_type_flag;
  x_trip_attrs_rec.CONSOLIDATION_ALLOWED        := p_plan_trip_rec.consolidation_allowed;
  x_trip_attrs_rec.SCHEDULE_ID                  := p_plan_trip_rec.schedule_id;
  x_trip_attrs_rec.ROUTE_LANE_ID                := p_plan_trip_rec.route_lane_id;
  x_trip_attrs_rec.LANE_ID                      := p_plan_trip_rec.lane_id;
  x_trip_attrs_rec.BOOKING_NUMBER               := p_plan_trip_rec.booking_number;
  x_trip_attrs_rec.VESSEL                       := p_plan_trip_rec.vessel;
  x_trip_attrs_rec.VOYAGE_NUMBER                := p_plan_trip_rec.voyage_number;
  x_trip_attrs_rec.PORT_OF_LOADING              := p_plan_trip_rec.port_of_loading;
  x_trip_attrs_rec.PORT_OF_DISCHARGE            := p_plan_trip_rec.port_of_discharge;
  x_trip_attrs_rec.CARRIER_CONTACT_ID           := p_plan_trip_rec.carrier_contact_id;
  x_trip_attrs_rec.SHIPPER_WAIT_TIME            := p_plan_trip_rec.shipper_wait_time;
  x_trip_attrs_rec.WAIT_TIME_UOM                := p_plan_trip_rec.wait_time_uom;
  x_trip_attrs_rec.CARRIER_RESPONSE             := p_plan_trip_rec.carrier_response;
  x_trip_attrs_rec.OPERATOR                     := NVL(p_plan_trip_rec.operator, l_trip_info.operator);
  x_trip_attrs_rec.LOAD_TENDER_STATUS           := l_trip_info.load_tender_status;
  x_trip_attrs_rec.LOAD_TENDER_NUMBER           := l_trip_info.load_tender_number;  -- J+ auto tender
  x_trip_attrs_rec.IGNORE_FOR_PLANNING          := 'N';

  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF c_trip_info%ISOPEN THEN
      CLOSE c_trip_info;
    END IF;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'WSH_TP_RELEASE.copy_trip_record',
                      l_module_name);

    IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    RAISE;

END copy_trip_record;



--
--  Procedure:          copy_stop_record
--  Parameters:
--               p_plan_stop_rec   plan stop record
--               p_plan_trips      list of plan trips to look up trip_id
--               x_stop_attrs_rec  output stop attributes record
--  Description:
--               transforms plan data structure into group api data structure for trip stop.
--

PROCEDURE copy_stop_record(
           p_plan_stop_rec   IN            plan_stop_rec_type,
           p_plan_trips      IN            plan_trip_tab_type,
           x_stop_attrs_rec     OUT NOCOPY wsh_trip_stops_pvt.trip_stop_rec_type
          ) IS
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'COPY_STOP_RECORD';
  --
  l_debug_on BOOLEAN;
  --
  CURSOR c_stop_info(x_stop_id NUMBER) IS
     SELECT departure_gross_weight,
            departure_net_weight,
            weight_uom_code,
            departure_volume,
            volume_uom_code,
            departure_fill_percent
     FROM   wsh_trip_stops
     WHERE  stop_id = x_stop_id;

  l_stop_info c_stop_info%ROWTYPE;

BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
       --
  IF l_debug_on IS NULL THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
     WSH_DEBUG_SV.log(l_module_name, 'p_plan_stop_rec.trip_index', p_plan_stop_rec.trip_index);
  END IF;

  IF p_plan_stop_rec.stop_id IS NOT NULL THEN
    OPEN  c_stop_info(p_plan_stop_rec.stop_id);
    FETCH c_stop_info INTO l_stop_info;
    IF c_stop_info%NOTFOUND THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'stop_id is not found', p_plan_stop_rec.stop_id);
      END IF;
      -- setting this value to NULL will cause an error.
      x_stop_attrs_rec.STOP_ID := NULL;
    END IF;
    CLOSE c_stop_info;
  END IF;

  x_stop_attrs_rec.STOP_ID                  := p_plan_stop_rec.stop_id;
  x_stop_attrs_rec.TP_STOP_ID               := p_plan_stop_rec.tp_stop_id;
  x_stop_attrs_rec.TRIP_ID                  := p_plan_trips(p_plan_stop_rec.trip_index).trip_id;
  x_stop_attrs_rec.STOP_LOCATION_ID         := p_plan_stop_rec.stop_location_id;
  x_stop_attrs_rec.STOP_SEQUENCE_NUMBER     := p_plan_stop_rec.stop_sequence_number;
  x_stop_attrs_rec.PLANNED_ARRIVAL_DATE     := p_plan_stop_rec.planned_arrival_date;
  x_stop_attrs_rec.PLANNED_DEPARTURE_DATE   := p_plan_stop_rec.planned_departure_date;
  x_stop_attrs_rec.WEIGHT_UOM_CODE          := p_plan_stop_rec.weight_uom_code;
  x_stop_attrs_rec.VOLUME_UOM_CODE          := p_plan_stop_rec.volume_uom_code;
  IF p_plan_stop_rec.stop_id IS NOT NULL THEN
    -- W/V: existing stop has W/V; convert W/V to the plan UOMs
    x_stop_attrs_rec.DEPARTURE_GROSS_WEIGHT := WSH_WV_UTILS.Convert_Uom(
                                           from_uom => l_stop_info.weight_uom_code,
                                           to_uom   => p_plan_stop_rec.weight_uom_code,
                                           quantity => l_stop_info.departure_gross_weight);
    x_stop_attrs_rec.DEPARTURE_NET_WEIGHT := WSH_WV_UTILS.Convert_Uom(
                                           from_uom => l_stop_info.weight_uom_code,
                                           to_uom   => p_plan_stop_rec.weight_uom_code,
                                           quantity => l_stop_info.departure_net_weight);
    x_stop_attrs_rec.DEPARTURE_VOLUME := WSH_WV_UTILS.Convert_Uom(
                                           from_uom => l_stop_info.volume_uom_code,
                                           to_uom   => p_plan_stop_rec.volume_uom_code,
                                           quantity => l_stop_info.departure_volume);
    -- See if UOM conversion is successful. If not, revert back to the old UOM.
    IF (NVL(x_stop_attrs_rec.DEPARTURE_GROSS_WEIGHT, 0))  = 0 and (NVL(l_stop_info.departure_gross_weight, 0) <> 0) THEN

       x_stop_attrs_rec.DEPARTURE_GROSS_WEIGHT := l_stop_info.departure_gross_weight;
       x_stop_attrs_rec.DEPARTURE_NET_WEIGHT := l_stop_info.departure_net_weight;
       x_stop_attrs_rec.WEIGHT_UOM_CODE := l_stop_info.weight_uom_code;

    END IF;
    IF (NVL(x_stop_attrs_rec.DEPARTURE_VOLUME, 0))  = 0 and (NVL(l_stop_info.departure_volume, 0) <> 0) THEN

       x_stop_attrs_rec.DEPARTURE_VOLUME := l_stop_info.departure_volume;
       x_stop_attrs_rec.VOLUME_UOM_CODE := l_stop_info.volume_uom_code;

    END IF;
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'p_plan_stop_rec.weight_uom_code', p_plan_stop_rec.weight_uom_code);
      WSH_DEBUG_SV.log(l_module_name, 'p_plan_stop_rec.volume_uom_code', p_plan_stop_rec.volume_uom_code);
      WSH_DEBUG_SV.log(l_module_name, 'x_stop_attrs_rec.DEPARTURE_GROSS_WEIGHT', x_stop_attrs_rec.DEPARTURE_GROSS_WEIGHT);
      WSH_DEBUG_SV.log(l_module_name, 'x_stop_attrs_rec.DEPARTURE_NET_WEIGHT', x_stop_attrs_rec.DEPARTURE_NET_WEIGHT);
      WSH_DEBUG_SV.log(l_module_name, 'x_stop_attrs_rec.DEPARTURE_VOLUME', x_stop_attrs_rec.DEPARTURE_VOLUME);
    END IF;

  ELSE
    -- new stop is empty; assume W/V = 0.
    --!!! W/V: issue: if we create a stop that is in middle of trip, it may need calculating.
    x_stop_attrs_rec.DEPARTURE_GROSS_WEIGHT := 0;
    x_stop_attrs_rec.DEPARTURE_NET_WEIGHT   := 0;
    x_stop_attrs_rec.DEPARTURE_VOLUME       := 0;
  END IF;
  x_stop_attrs_rec.DEPARTURE_SEAL_CODE      := p_plan_stop_rec.departure_seal_code;
  x_stop_attrs_rec.DEPARTURE_FILL_PERCENT   := NVL(l_stop_info.departure_fill_percent,
                                                   p_plan_stop_rec.departure_fill_percent);
  x_stop_attrs_rec.WKEND_LAYOVER_STOPS      := p_plan_stop_rec.wkend_layover_stops;
  x_stop_attrs_rec.WKDAY_LAYOVER_STOPS      := p_plan_stop_rec.wkday_layover_stops;
  x_stop_attrs_rec.SHIPMENTS_TYPE_FLAG      := p_plan_stop_rec.shipments_type_flag;

  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF c_stop_info%ISOPEN THEN
      CLOSE c_stop_info;
    END IF;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'WSH_TP_RELEASE.copy_stop_record',
                      l_module_name);

    IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    RAISE;

END copy_stop_record;


--
--  Procedure:          create_update_plan_trips
--  Parameters:
--               p_phase           value 1 = create or update with NULL lane_id
--                                 value 2 = update with lane_id
--               x_plan_trips      list of plan trips
--               x_errors_tab      list of errors to insert into wsh_interface_errors at the end
--               x_return_status   return status
--  Description:
--               in phase 1, create or update trips with NULL lane_id.
--               in phase 2, update trips with lane_id.
--               This API was created to resolve bug 3580374
--

PROCEDURE create_update_plan_trips(
           p_phase                    IN            NUMBER,  -- 1 to create/update trips with NULL lane_id
                                                             -- 2 to update trips with lane_id populated
           x_context                  IN OUT NOCOPY context_rec_type,
           x_plan_trips               IN OUT NOCOPY plan_trip_tab_type,
           x_errors_tab               IN OUT NOCOPY interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          )
IS
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_PLAN_TRIPS';
  --
  l_debug_on BOOLEAN;
  --
  l_index            NUMBER;
  l_message_name       VARCHAR2(30);
  l_return_status      VARCHAR2(1);
  l_number_of_warnings NUMBER;
  l_number_of_errors   NUMBER;
  l_msg_data           VARCHAR2(32767);
  l_msg_count          NUMBER;
  l_interface_entity   WSH_INTERFACE_ERRORS.INTERFACE_TABLE_NAME%TYPE;
  l_interface_id       NUMBER;
  --
  l_trip_attrs       WSH_TRIPS_PVT.trip_attr_tbl_type;
  l_trip_action_prms WSH_TRIPS_GRP.action_parameters_rectype;
  l_trip_in_rec      WSH_TRIPS_GRP.TripInRecType;
  l_trip_defaults    WSH_TRIPS_GRP.default_parameters_rectype;
  l_trip_out_rec     WSH_TRIPS_GRP.tripActionOutRecType;
  l_trip_out_tab     WSH_TRIPS_GRP.trip_out_tab_type;

BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
       --
  IF l_debug_on IS NULL THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
     WSH_DEBUG_SV.log(l_module_name, 'p_phase', p_phase);
  END IF;
  --
  --

  l_trip_attrs.DELETE;
  l_trip_in_rec.caller      := 'WSH_TP_RELEASE';

  l_index := x_plan_trips.FIRST;
  WHILE l_index IS NOT NULL LOOP
    -- Bug 3555487 initialize message stack for each major action point.
    FND_MSG_PUB.initialize;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'create/update trips: l_index', l_index);
      IF (p_phase = 2) THEN
        WSH_DEBUG_SV.log(l_module_name, 'x_plan_trips(l_index).lane_id',  x_plan_trips(l_index).lane_id);
      END IF;
    END IF;

    copy_trip_record(
              p_plan_trip_rec  => x_plan_trips(l_index),
              x_trip_attrs_rec => l_trip_attrs(1)
    );
    IF (p_phase = 1) THEN
      -- bug 3580374: always create/update trip with NULL lane_id
      -- so that stops can be created/updated without location validation.
      l_trip_attrs(1).lane_id   := NULL;
    END IF;

    IF x_plan_trips(l_index).trip_id IS NULL THEN
      -- creation happens only in phase 1
      l_trip_in_rec.action_code := 'CREATE';
      l_message_name     := 'WSH_TP_F_CREATE_TRIP';
    ELSE
      l_trip_in_rec.action_code := 'UPDATE';
      IF (p_phase = 1) THEN
        l_message_name     := 'WSH_TP_F_UPDATE_TRIP';
      ELSE
        l_message_name     := 'WSH_TP_F_UPDATE_LANE';
      END IF;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'l_trip_attrs(1).lane_id', l_trip_attrs(1).lane_id );
    END IF;

    IF (p_phase = 1)
       OR (p_phase = 2 AND x_plan_trips(l_index).lane_id IS NOT NULL) THEN
      -- phase 1: always call this API
      -- phase 2: call this API only if lane_id needs to be populated.

      wsh_trips_grp.Create_Update_Trip(
          p_api_version_number     =>    1.0,
          p_init_msg_list          =>    FND_API.G_FALSE,
          p_commit                 =>    FND_API.G_FALSE,
          p_trip_info_tab          =>    l_trip_attrs,
          p_In_rec                 =>    l_trip_in_rec,
          x_Out_Tab                =>    l_trip_out_tab,
          x_return_status          =>    l_return_status,
          x_msg_count              =>    l_msg_count,
          x_msg_data               =>    l_msg_data);

      l_interface_entity := 'WSH_TRIPS_INTERFACE';
      l_interface_id     := x_plan_trips(l_index).trip_interface_id;
      wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_number_of_warnings,
           x_num_errors    => l_number_of_errors);
    END IF;

    IF l_trip_in_rec.action_code = 'CREATE' THEN
      x_plan_trips(l_index).trip_id := l_trip_out_tab(1).trip_id;
    END IF;

    l_index := x_plan_trips.NEXT(l_index);

  END LOOP;

  --
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;


EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get(
          p_count   => l_msg_count,
          p_data    => l_msg_data,
          p_encoded => fnd_api.g_false);
      --
      stamp_interface_error(
          p_group_id            => x_context.group_id,
          p_entity_table_name   => l_interface_entity,
          p_entity_interface_id => l_interface_id,
          p_message_name        => l_message_name,
          x_errors_tab          => x_errors_tab,
          x_return_status       => l_return_status);
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'FND_API.G_EXC_ERROR exception has occured.', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get(
         p_count    => l_msg_count,
         p_data     => l_msg_data,
         p_encoded  => fnd_api.g_false);
      --
      stamp_interface_error(
          p_group_id            => x_context.group_id,
          p_entity_table_name   => l_interface_entity,
          p_entity_interface_id => l_interface_id,
          p_message_name        => l_message_name,
          x_errors_tab          => x_errors_tab,
          x_return_status       => l_return_status);
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'WSH_TP_RELEASE.create_update_plan_trips',
                      l_module_name);

    IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END create_update_plan_trips;




--
--  Procedure:          stamp_interface_error
--  Parameters:
--               p_group_id            group identifier where the error is found
--               p_entity_table_name   entity table where the error is found
--               p_entity_interface_id record where the error is found
--               p_message_name        message name identifying the error
--               p_message_appl        message application name (NULL means 'WSH')
--               p_message_text        optional text for output to the user-
--               p_token_1_name        optional token 1 name
--               p_token_1_value       optional token 1 value
--               p_token_2_name        optional token 2 name
--               p_token_2_value       optional token 2 value
--               p_token_3_name        optional token 3 name
--               p_token_3_value       optional token 3 value
--               p_token_4_name        optional token 4 name
--               p_token_4_value       optional token 4 value
--               p_errors_tab          list of errors to insert into wsh_interface_errors at the end
--               x_return_status       return status
--
--  Description:
--               puts the error information into the list p_errors_tab
--
PROCEDURE stamp_interface_error(
            p_group_id           IN            NUMBER,
            p_entity_table_name  IN            VARCHAR2,
            p_entity_interface_id   IN         NUMBER,
            p_message_name       IN            VARCHAR2,
            p_message_appl       IN            VARCHAR2 DEFAULT NULL,
            p_message_text       IN            VARCHAR2 DEFAULT NULL,
            p_token_1_name       IN            VARCHAR2 DEFAULT NULL,
            p_token_1_value      IN            VARCHAR2 DEFAULT NULL,
            p_token_2_name       IN            VARCHAR2 DEFAULT NULL,
            p_token_2_value      IN            VARCHAR2 DEFAULT NULL,
            p_token_3_name       IN            VARCHAR2 DEFAULT NULL,
            p_token_3_value      IN            VARCHAR2 DEFAULT NULL,
            p_token_4_name       IN            VARCHAR2 DEFAULT NULL,
            p_token_4_value      IN            VARCHAR2 DEFAULT NULL,
            x_errors_tab         IN OUT NOCOPY interface_errors_tab_type,
            x_return_status         OUT NOCOPY VARCHAR2)
IS
  l_index BINARY_INTEGER := NULL;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'STAMP_INTERFACE_ERROR';
  --
  l_debug_on BOOLEAN;
  --
  l_message_appl VARCHAR2(30) := p_message_appl;
  c NUMBER;
  l_buffer VARCHAR2(4000);
  l_index_out NUMBER;

BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
       --
  IF l_debug_on IS NULL THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
     WSH_DEBUG_SV.log(l_module_name,'p_group_id', p_group_id);
     WSH_DEBUG_SV.log(l_module_name,'p_entity_table_name', p_entity_table_name);
     WSH_DEBUG_SV.log(l_module_name,'p_entity_interface_id', p_entity_interface_id);
     WSH_DEBUG_SV.log(l_module_name,'p_message_appl', p_message_appl);
     WSH_DEBUG_SV.log(l_module_name,'p_message_name', p_message_name);
     WSH_DEBUG_SV.log(l_module_name,'p_message_text', p_message_text);
     WSH_DEBUG_SV.log(l_module_name,'p_token_1_name', p_token_1_name);
     WSH_DEBUG_SV.log(l_module_name,'p_token_1_value', p_token_1_value);
     WSH_DEBUG_SV.log(l_module_name,'p_token_2_name', p_token_2_name);
     WSH_DEBUG_SV.log(l_module_name,'p_token_2_value', p_token_2_value);
     WSH_DEBUG_SV.log(l_module_name,'p_token_3_name', p_token_3_name);
     WSH_DEBUG_SV.log(l_module_name,'p_token_3_value', p_token_3_value);
     WSH_DEBUG_SV.log(l_module_name,'p_token_4_name', p_token_4_name);
     WSH_DEBUG_SV.log(l_module_name,'p_token_4_value', p_token_4_value);
  END IF;

  l_index := x_errors_tab.COUNT + 1;

  IF p_message_text IS NULL THEN

     l_message_appl := NVL(l_message_appl, 'WSH');

     FND_MESSAGE.SET_NAME(l_message_appl, p_message_name);
     IF p_token_1_name IS NOT NULL THEN
        FND_MESSAGE.SET_TOKEN(p_token_1_name, p_token_1_value);
        IF p_token_2_name IS NOT NULL THEN
           FND_MESSAGE.SET_TOKEN(p_token_2_name, p_token_2_value);
           IF p_token_3_name IS NOT NULL THEN
             FND_MESSAGE.SET_TOKEN(p_token_3_name, p_token_3_value);
               IF  p_token_4_name IS NOT NULL THEN
                 FND_MESSAGE.SET_TOKEN(p_token_4_name, p_token_4_value);
               END IF;
           END IF;
        END IF;
     END IF;

     fnd_msg_pub.add;

  ELSE

     x_errors_tab(l_index).ERROR_MESSAGE            := p_message_text;
     x_errors_tab(l_index).INTERFACE_TABLE_NAME     := p_entity_table_name;
     x_errors_tab(l_index).INTERFACE_ID             := p_entity_interface_id;
     x_errors_tab(l_index).INTERFACE_ERROR_GROUP_ID := p_group_id;
     x_errors_tab(l_index).MESSAGE_NAME             := p_message_name;

     l_index := l_index +1;

  END IF;


  c := FND_MSG_PUB.count_msg;
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'COUNT--',c);
  END IF;
  FOR i in 1..c LOOP
      FND_MSG_PUB.get(p_encoded => FND_API.G_FALSE,
          p_msg_index => i,
          p_data => l_buffer,
          p_msg_index_out => l_index_out);


      x_errors_tab(l_index).ERROR_MESSAGE            := l_buffer;
      x_errors_tab(l_index).INTERFACE_TABLE_NAME     := p_entity_table_name;
      x_errors_tab(l_index).INTERFACE_ID             := p_entity_interface_id;
      x_errors_tab(l_index).INTERFACE_ERROR_GROUP_ID := p_group_id;
      IF (i = 1) AND (p_message_text IS NULL)  THEN
         x_errors_tab(l_index).MESSAGE_NAME          := p_message_name;
      ELSE
         x_errors_tab(l_index).MESSAGE_NAME          := 'WSH_TP_I_GENERIC';
      END IF;

      l_index := l_index + 1;

  END LOOP;

  -- bug 4552612: issue #3
  -- since all messages in stack are already pulled into x_errors_tab,
  -- the stack should be purged before the next call to stamp_interface_error
  -- to avoid repeating the same messages.
  FND_MSG_PUB.initialize;


  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_index--',l_index);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'WSH_TP_RELEASE.stamp_interface_error',
                      l_module_name);

    IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

END stamp_interface_error;





--
--  Procedure:          insert_interface_errors
--  Parameters:
--               p_errors_tab          list of errors to insert into wsh_interface_errors[
--               x_return_status       return status
--
--  Description:
--               does a bulk-insert of error records into wsh_interface_errors
--
PROCEDURE insert_interface_errors(
            p_errors_tab    IN         interface_errors_tab_type,
            x_return_status OUT NOCOPY VARCHAR2)
IS
  TYPE text_tab_type IS TABLE OF WSH_INTERFACE_ERRORS.ERROR_MESSAGE%TYPE INDEX BY BINARY_INTEGER;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_INTERFACE_ERRORS';
  --
  l_debug_on BOOLEAN;
  --
  l_groups        WSH_UTIL_CORE.ID_TAB_TYPE;
  l_table_names   WSH_UTIL_CORE.COLUMN_TAB_TYPE;
  l_interface_ids WSH_UTIL_CORE.ID_TAB_TYPE;
  l_message_names WSH_UTIL_CORE.COLUMN_TAB_TYPE;
  l_messages      text_tab_type;

BEGIN


  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;

  SAVEPOINT before_insert;

  -- decompose the table of records into tables that can be used by FORALL.
  FOR i IN p_errors_tab.FIRST .. p_errors_tab.LAST LOOP
    l_groups(i)        := p_errors_tab(i).INTERFACE_ERROR_GROUP_ID;
    l_table_names(i)   := p_errors_tab(i).INTERFACE_TABLE_NAME;
    l_interface_ids(i) := p_errors_tab(i).INTERFACE_ID;
    l_message_names(i) := p_errors_tab(i).MESSAGE_NAME;
    l_messages(i)      := p_errors_tab(i).ERROR_MESSAGE;
  END LOOP;

  FORALL i IN l_groups.FIRST .. l_groups.LAST
         INSERT INTO WSH_INTERFACE_ERRORS (
          INTERFACE_ERROR_ID,
          INTERFACE_ERROR_GROUP_ID,
          INTERFACE_TABLE_NAME,
          INTERFACE_ID,
          INTERFACE_ACTION_CODE,
          MESSAGE_NAME,
          ERROR_MESSAGE,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY)
          VALUES (
          WSH_INTERFACE_ERRORS_S.nextval,
          l_groups(i),
          l_table_names(i),
          l_interface_ids(i),
          G_TP_RELEASE_CODE,
          l_message_names(i),
          l_messages(i),
          SYSDATE,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.USER_ID);

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'WSH_TP_RELEASE.insert_interface_errors',
                      l_module_name);
    ROLLBACK TO before_insert;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END insert_interface_errors;


--
--  Function:          get_plan_trip_num
--  Parameters:
--               p_context             plan release context
--               x_return_status       return status
--
--  Description:
--               looks up a plan trip num for purpose
--               of populating the error messages (to be used
--               only if the trips have not yet been mapped).
FUNCTION get_plan_trip_num(
             p_context      IN         context_rec_type)
RETURN VARCHAR2 IS
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_PLAN_TRIP_NUM';
  --
  l_debug_on BOOLEAN;
  --
  l_plan_trip_num WSH_TRIPS.TP_TRIP_NUMBER%TYPE := '';

  -- c_tp_interface_trips makes a list of interface trips,
  -- mapping shipping trips that were snapshot;
  -- code will later validate these shipping trips can be mapped.
  CURSOR c_name(p_group_id IN NUMBER) IS
  SELECT wti.tp_trip_number
  FROM   wsh_trips_interface          wti
  WHERE  wti.group_id = p_group_id
  AND    wti.interface_action_code  = G_TP_RELEASE_CODE
  AND    rownum = 1
  ;

BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name, 'p_context.group_id', p_context.group_id);
  END IF;
  --
  --
  OPEN c_name(p_context.group_id);
  FETCH c_name INTO l_plan_trip_num;
  IF c_name%NOTFOUND THEN
    l_plan_trip_num := '';
  END IF;
  CLOSE c_name;

  --
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'l_plan_trip_num', l_plan_trip_num);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  RETURN l_plan_trip_num;

EXCEPTION
  WHEN OTHERS THEN
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'WSH_TP_RELEASE.get_plan_trip_num',
                      l_module_name);
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    IF c_name%ISOPEN THEN
      CLOSE c_name;
    END IF;
    RETURN l_plan_trip_num;

END get_plan_trip_num;

--
--  Procedure: Log_WV_Exceptions
--  Parameters:
--               p_details_loc_tab  table of locations of delivery details (indexed by delivery_detail_id).
--               p_deliveries_loc_tab  table of locations of deliveries (indexed by delivery_id).
--               p_stops_loc_tab  table of locations of stops (indexed by stop_id).
--               x_return_status       return status
--
--  Description:
--               Logs exceptions against lines, deliveries, and stops that
--               have their Weights/Volume frozen, but may have their W/V changed.
--               WV changes



PROCEDURE Log_WV_Exceptions(
          p_details_loc_tab in wsh_util_core.id_tab_type,
          p_deliveries_loc_tab in wsh_util_core.id_tab_type,
          p_stops_loc_tab in wsh_util_core.id_tab_type,
          x_return_status out NOCOPY varchar2) IS

i NUMBER;

l_exception_msg_count NUMBER;
l_exception_msg_data varchar2(2000);
l_dummy_exception_id NUMBER;
l_msg varchar2(2000);

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Log_WV_Exceptions';
--
l_debug_on BOOLEAN;


BEGIN

l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL THEN
  l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
  WSH_DEBUG_SV.push(l_module_name);
  WSH_DEBUG_SV.logmsg(l_module_name, 'line exceptions count: '|| p_details_loc_tab.count);
  WSH_DEBUG_SV.logmsg(l_module_name, 'delivery exceptions count: '|| p_deliveries_loc_tab.count);
  WSH_DEBUG_SV.logmsg(l_module_name, 'stop exceptions count: '|| p_stops_loc_tab.count);
END IF;

x_return_status :=  WSH_UTIL_CORE.G_RET_STS_SUCCESS;


IF p_details_loc_tab.count > 0 THEN

   l_msg := FND_MESSAGE.Get_String('WSH', 'WSH_TP_DET_WV_FROZEN');
   i := p_details_loc_tab.FIRST;

   WHILE i is NOT NULL LOOP

     l_dummy_exception_id := NULL;
     wsh_xc_util.log_exception(
                    p_api_version             => 1.0,
                    x_return_status           => x_return_status,
                    x_msg_count               => l_exception_msg_count,
                    x_msg_data                => l_exception_msg_data,
                    x_exception_id            => l_dummy_exception_id ,
                    p_logged_at_location_id   => p_details_loc_tab(i),
                    p_exception_location_id   => p_details_loc_tab(i),
                    p_logging_entity          => 'SHIPPER',
                    p_logging_entity_id       => FND_GLOBAL.USER_ID,
                    p_exception_name          => 'WSH_TP_WV_FROZEN',
                    p_message                 => l_msg,
                    p_delivery_detail_id      => i
                     );

     i := p_details_loc_tab.next(i);

   END LOOP;

END IF;

IF p_deliveries_loc_tab.count > 0 THEN

   l_msg := FND_MESSAGE.Get_String('WSH', 'WSH_TP_DEL_WV_FROZEN');
   i := p_deliveries_loc_tab.FIRST;

   WHILE i is NOT NULL LOOP

     l_dummy_exception_id := NULL;
     wsh_xc_util.log_exception(
                    p_api_version             => 1.0,
                    x_return_status           => x_return_status,
                    x_msg_count               => l_exception_msg_count,
                    x_msg_data                => l_exception_msg_data,
                    x_exception_id            => l_dummy_exception_id ,
                    p_logged_at_location_id   => p_deliveries_loc_tab(i),
                    p_exception_location_id   => p_deliveries_loc_tab(i),
                    p_logging_entity          => 'SHIPPER',
                    p_logging_entity_id       => FND_GLOBAL.USER_ID,
                    p_exception_name          => 'WSH_TP_WV_FROZEN',
                    p_message                 => l_msg,
                    p_delivery_id             => i
                     );

     i := p_deliveries_loc_tab.next(i);

   END LOOP;

END IF;

IF p_stops_loc_tab.count > 0 THEN

   l_msg := FND_MESSAGE.Get_String('WSH', 'WSH_TP_STOP_WV_FROZEN');
   i := p_stops_loc_tab.FIRST;

   WHILE i is NOT NULL LOOP

     l_dummy_exception_id := NULL;
     wsh_xc_util.log_exception(
                    p_api_version             => 1.0,
                    x_return_status           => x_return_status,
                    x_msg_count               => l_exception_msg_count,
                    x_msg_data                => l_exception_msg_data,
                    x_exception_id            => l_dummy_exception_id ,
                    p_logged_at_location_id   => p_stops_loc_tab(i),
                    p_exception_location_id   => p_stops_loc_tab(i),
                    p_logging_entity          => 'SHIPPER',
                    p_logging_entity_id       => FND_GLOBAL.USER_ID,
                    p_exception_name          => 'WSH_TP_WV_FROZEN',
                    p_message                 => l_msg,
                    p_trip_stop_id            => i
                     );

     i := p_stops_loc_tab.next(i);

   END LOOP;

END IF;

IF l_debug_on THEN
  WSH_DEBUG_SV.pop(l_module_name);
END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status :=  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_TP_RELEASE.log_wv_exception', l_module_name);
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END Log_WV_Exceptions;

END WSH_TP_RELEASE_INT;

/
