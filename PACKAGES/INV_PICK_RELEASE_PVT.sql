--------------------------------------------------------
--  DDL for Package INV_PICK_RELEASE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_PICK_RELEASE_PVT" AUTHID CURRENT_USER AS
/* $Header: INVVPICS.pls 120.5.12010000.5 2009/08/03 12:36:51 mitgupta ship $ */

g_min_tolerance    NUMBER := 0.0;
g_max_tolerance    NUMBER := 0;
g_prf_pick_nonrsv_lots NUMBER; --Bug 8560030
g_pick_nonrsv_lots NUMBER := 2; --Bug 8560030

-------------------------------------------------------------------------------
-- Procedures and Functions
-------------------------------------------------------------------------------
-- Start of Comments
--
-- Name
--   PROCEDURE Process_Line
--
-- Package
--   INV_Pick_Release_PVT
--
-- Purpose
--   Pick releases the move order line passed in.  Any necessary validation is
--   assumed to have been done by the caller.
--
-- Input Parameters
--   p_mo_line_rec
--       The Move Order Line record to pick release
--   p_grouping_rule_id
--       The grouping rule to use for generating pick slip numbers
--   p_allow_partial_pick
--	    TRUE if the pick release process should continue after a line fails to
--		be detailed completely.  FALSE if the process should stop and roll
--		back all changes if a line cannot be fully detailed.
--	    NOTE: Printing pick slips as the lines are detailed is only supported if
--		this parameter is TRUE, since a commit must be done before printing.
--   p_print_mode
--	 Whether the pick slips should be printed as they are generated or not.
--	 If this is 'I' (immediate) then after a pick slip number has been returned a
--	 specified number of times (given in the shipping parameters), that pick
--	 slip will be printed immediately.
--	 If this is 'E' (deferred) then the pick slips will not be printed until the
--	 pick release process is complete.
--
-- Output Parameters
--   x_return_status
--       if the process succeeds, the value is
--			fnd_api.g_ret_sts_success;
--       if there is an expected error, the value is
--             fnd_api.g_ret_sts_error;
--       if there is an unexpected error, the value is
--             fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--       if there is one or more errors, the number of error messages
--       	in the buffer
--   x_msg_data
--       if there is one and only one error, the error message
--   	(See fnd_api package for more details about the above output parameters)
--
-- Bug8757642. Added p_wave_simulation_mode with default vale 'N' for WavePlanning Project.
-- This project is available only in for R121 and mainline. To retain dual maintenance INV code changes are made in branchline, however it will not affect any existing flow.

PROCEDURE Process_Line
    (
	p_api_version		IN  	NUMBER
	,p_init_msg_list	IN  	VARCHAR2 DEFAULT fnd_api.g_false
	,p_commit		IN	VARCHAR2 DEFAULT fnd_api.g_false
	,x_return_status        OUT 	NOCOPY VARCHAR2
   	,x_msg_count            OUT 	NOCOPY NUMBER
   	,x_msg_data             OUT 	NOCOPY VARCHAR2
   	,p_mo_line_rec		IN OUT 	NOCOPY INV_Move_Order_PUB.TROLIN_REC_TYPE
	,p_grouping_rule_id	IN  	NUMBER
	,p_allow_partial_pick	IN	VARCHAR2 DEFAULT fnd_api.g_true
	,p_print_mode		IN	VARCHAR2
	,x_detail_rec_count	OUT 	NOCOPY NUMBER
   	,p_plan_tasks IN BOOLEAN DEFAULT FALSE
	,p_wave_simulation_mode IN VARCHAR2 DEFAULT 'N'
    );


--
-- Start of Comments
-- Name
--   PROCEDURE process_prj_dynamic_locator
--
-- Package
--   INV_Pick_Release_PVT
--
-- Purpose
--   Creates dynamic locators for project manufacturing.  If the org or sub has dynamic
--   locator control and the move order line being pick released has project and task
--   specified then a new locator ID needs to be generated for the project and task.
--
-- Input Parameters
--   p_mo_line_rec
--       The Move Order Line record being pick released
--
--   p_mold_temp_id
--       Transaction temp ID being processed
--
--   p_mold_sub_code
--       Source subinventory on MMTT
--
--   p_from_locator_id
--       Source locator on MMTT
--
--   p_to_locator_id
--       Destination locator on MMTT
--
--
-- Output Parameters
--   x_return_status
--       if the process succeeds, the value is
--                      fnd_api.g_ret_sts_success;
--       if there is an expected error, the value is
--             fnd_api.g_ret_sts_error;
--       if there is an unexpected error, the value is
--             fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--       if there is one or more errors, the number of error messages
--              in the buffer
--   x_msg_data
--       if there is one and only one error, the error message
--      (See fnd_api package for more details about the above output parameters)
--

PROCEDURE process_prj_dynamic_locator
(
    p_mo_line_Rec       IN OUT NOCOPY  INV_MOVE_ORDER_PUB.Trolin_rec_type
  , p_mold_temp_id      IN  NUMBER
  , p_mold_sub_code     IN  VARCHAR2
  , p_from_locator_id   IN  NUMBER
  , p_to_locator_id     IN  NUMBER
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count         OUT NOCOPY NUMBER
  , x_msg_data          OUT NOCOPY VARCHAR2
  , x_to_locator_id 	OUT NOCOPY NUMBER
  , p_to_subinventory   IN  VARCHAR2 DEFAULT NULL
);

/* FP-J PAR Replenishment Counts: 4 new input parameters are introduced viz.,
   p_dest_subinv, p_dest_locator_id, p_project_id, p_task_id. This is as a result
   of moving Supply Subinv, Supply Locator, Project and Task to 'Common' group
   from 'Manufacturing' group in Grouping Rule form. */
  PROCEDURE get_pick_slip_number(
    p_ps_mode                   VARCHAR2
  , p_pick_grouping_rule_id     NUMBER
  , p_org_id                    NUMBER
  , p_header_id                 NUMBER
  , p_customer_id               NUMBER
  , p_ship_method_code          VARCHAR2
  , p_ship_to_loc_id            NUMBER
  , p_shipment_priority         VARCHAR2
  , p_subinventory              VARCHAR2
  , p_trip_stop_id              NUMBER
  , p_delivery_id               NUMBER
  , x_pick_slip_number      OUT NOCOPY NUMBER
  , x_ready_to_print        OUT NOCOPY VARCHAR2
  , x_api_status            OUT NOCOPY VARCHAR2
  , x_error_message         OUT NOCOPY VARCHAR2
  , x_call_mode             OUT NOCOPY VARCHAR2
  , p_dest_subinv               VARCHAR2 DEFAULT NULL
  , p_dest_locator_id           NUMBER   DEFAULT NULL
  , p_project_id                NUMBER   DEFAULT NULL
  , p_task_id                   NUMBER   DEFAULT NULL
  , p_inventory_item_id         NUMBER   DEFAULT NULL
  , p_locator_id                NUMBER   DEFAULT NULL
  , p_revision                  VARCHAR2 DEFAULT NULL
);

  PROCEDURE process_reservations(
    x_return_status       OUT    NOCOPY VARCHAR2
  , x_msg_count           OUT    NOCOPY NUMBER
  , x_msg_data            OUT    NOCOPY VARCHAR2
  , p_demand_info         IN     wsh_inv_delivery_details_v%ROWTYPE
  , p_mo_line_rec         IN     inv_move_order_pub.trolin_rec_type
  , p_mso_line_id         IN     NUMBER
  , p_demand_source_type  IN     VARCHAR2
  , p_demand_source_name  IN     VARCHAR2
  , p_allow_partial_pick  IN     VARCHAR2 DEFAULT fnd_api.g_true
  , x_demand_rsvs_ordered OUT    NOCOPY inv_reservation_global.mtl_reservation_tbl_type
  , x_rsv_qty_available   OUT    NOCOPY NUMBER
  ,x_rsv_qty2_available   OUT    NOCOPY NUMBER --7377744
  );

  FUNCTION check_backorder_cache	(
	p_org_id                 NUMBER
	,p_inventory_item_id     NUMBER
        ,p_ignore_reservations   BOOLEAN
        ,p_demand_line_id        NUMBER)
  return BOOLEAN;

  PROCEDURE clear_backorder_cache;

  PROCEDURE release_mo_tasks (p_header_id    NUMBER);

  PROCEDURE get_tolerance(
        p_mo_line_id  NUMBER
      , x_return_status OUT NOCOPY VARCHAR2
      , x_msg_count OUT NOCOPY VARCHAR2
      , x_msg_data OUT NOCOPY VARCHAR2
      , x_max_tolerance OUT NOCOPY NUMBER
      , x_min_tolerance OUT NOCOPY NUMBER);

END INV_Pick_Release_PVT;

/
