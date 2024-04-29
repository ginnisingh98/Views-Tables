--------------------------------------------------------
--  DDL for Package INV_PICK_RELEASE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_PICK_RELEASE_PUB" AUTHID CURRENT_USER AS
/* $Header: INVPPICS.pls 120.5.12010000.5 2010/01/22 16:35:04 mporecha ship $ */

--Expired lots custom hook
g_pick_expired_lots  BOOLEAN := FALSE;

-------------------------------------------------------------------------------
-- Data Types
-------------------------------------------------------------------------------
--
-- The Release Status table will notify the caller as to which Move Order Lines were
-- successfully detailed, which ones were only partially detailed, and which ones
-- failed to be processed at all.
--
-- A table of this type will be returned by the Pick Release API to specify the
-- status of the records it attempts to release.
--
-- The records of this table (of type INV_RELEASE_STATUS_REC_TYPE) will consist of
-- the following fields:
--	mo_line_id 	=> The Move Order Line ID that this status is for.
--   	return_status	=> The standard return status for an API.  The return_status
--		can also be 'P', which designates that the move order line was only
--		partially detailed (but otherwise successful).

TYPE INV_Release_Status_Rec_Type IS RECORD
(
	mo_line_id	 NUMBER,
        detail_rec_count NUMBER,
	return_status	 VARCHAR2(1)
);


TYPE INV_Release_Status_Tbl_Type IS TABLE OF INV_Release_Status_Rec_Type
	INDEX BY BINARY_INTEGER;


-------------------------------------------------------------------------------
-- Procedures and Functions
-------------------------------------------------------------------------------
PROCEDURE test_sort(p_trolin_tbl IN OUT NOCOPY INV_Move_Order_Pub.Trolin_Tbl_Type);

--
-- Name
--   PROCEDURE Pick_Release
--
-- Purpose
--   Pick releases the move order lines passed in.
--
-- Input Parameters
--   p_api_version_number
--	   API version number (current version is 1.0)
--   p_init_msg_list (optional, default FND_API.G_FALSE)
--	   Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
--                           if set to FND_API.G_TRUE
--                                   initialize error message list
--                           if set to FND_API.G_FALSE - not initialize error
--                                   message list
--   p_commit (optional, default FND_API.G_FALSE)
--	   whether or not to commit the changes to database
--
--   p_mo_line_tbl
--       Table of Move Order Line records to pick release
--	p_auto_pick_confirm (optional, default 2)
--       Overrides org-level parameter for whether to automatically call
--		pick confirm after release
--	    Valid values: 1 (yes) or 2 (no)
--   p_grouping_rule_id
--       Overrides org-level and Move Order header-level grouping rule for
--		generating pick slip numbers
--   p_allow_partial_pick
--	    TRUE if the pick release process should continue after a line fails to
--		be detailed completely.  FALSE if the process should stop and roll
--		back all changes if a line cannot be fully detailed.
--	    NOTE: Printing pick slips as the lines are detailed is only supported if
--		this parameter is TRUE, since a commit must be done before printing.
--
-- Output Parameters
--   x_return_status
--       if the pick release process succeeds, the value is
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
--   (See fnd_api package for more details about the above output parameters)
--	x_pick_release_status
--	    This output parameter is a table of records (of type
-- 		INV_Release_Status_Tbl_Type) which specifies the pick release status
--		for each move order line that is passed in.
--
PROCEDURE Pick_Release
  (
   p_api_version		IN  	NUMBER
   ,p_init_msg_list		IN  	VARCHAR2 := NULL
   ,p_commit			IN	VARCHAR2 := NULL
   ,x_return_status        	OUT 	NOCOPY VARCHAR2
   ,x_msg_count            	OUT 	NOCOPY NUMBER
   ,x_msg_data             	OUT 	NOCOPY VARCHAR2
   ,p_mo_line_tbl		IN  	INV_Move_Order_PUB.TROLIN_TBL_TYPE
   ,p_auto_pick_confirm	        IN  	NUMBER := NULL
   ,p_grouping_rule_id	        IN  	NUMBER := NULL
   ,p_allow_partial_pick	IN	VARCHAR2 DEFAULT fnd_api.g_true
   ,x_pick_release_status	OUT	NOCOPY INV_Release_Status_Tbl_Type
   ,p_plan_tasks                IN      BOOLEAN := FALSE
   ,p_skip_cartonization        IN      BOOLEAN := FALSE
   ,p_mo_transact_date          IN      DATE := fnd_api.g_miss_date
   );


-- Changes for R12 Planned Crossdocking project.
-- Added the following three IN OUT parameters similar to the Crossdock Pegging API,
-- WMS_XDock_Pegging_Pub.Planned_Cross_Dock.  These parameters are needed in case allocation
-- mode uses crossdocking (either Prioritize Inventory or Prioritize Crossdock).  The parameters
-- are also used to keep data in sync with shipping's code in the WSH_PICK_LIST package.  This API
-- will be overloaded so any caller to Pick_Release with the old signature does not error out.
--
--      IN OUT parameters:
--       p_wsh_release_table        Table of valid demand lines to pick release against.
--                                  Assume that all WDD records are for the same org, p_organization_id.
--                                  API will only process WDD lines with released_status of
--                                  'R' (Ready to Release) or 'B' (Backordered).
--                                  Shipping should pass in WSH_PR_CRITERIA.release_table in the
--                                  WSH_PICK_LIST.Release_Batch API when pick release is run.
--       p_trolin_delivery_ids      Table of delivery IDs for transactable demand lines.
--                                  Crossdocked lines needs to keep this table updated so crossdocked
--                                  or split WDD lines can be picked up to autocreate/merge deliveries.
--                                  Shipping should pass in local variable 'l_trolin_delivery_ids' from
--                                  the Release_Batch API.  This table has a one to one relationship
--                                  with p_del_detail_id and stores the delivery_id for the corresponding
--                                  delivery_detail_id in p_del_detail_id.
--       p_del_detail_id            Table of delivery detail IDs for transactable demand lines.
--                                  Crossdocked lines needs to keep this table updated so crossdocked
--                                  or split WDD lines can be picked up to autocreate/merge deliveries.
--                                  Shipping should pass in local variable 'l_del_detail_id' from
--                                  the Release_Batch API.  This table has a one to one relationship
--                                  with p_trolin_delivery_ids and stores a list of delivery_detail_id
--                                  values for all of the transactable WDD lines in p_wsh_release_table.
PROCEDURE Pick_Release
  (
   p_api_version		IN  	NUMBER
   ,p_init_msg_list		IN  	VARCHAR2 := NULL
   ,p_commit			IN	VARCHAR2 := NULL
   ,x_return_status        	OUT 	NOCOPY VARCHAR2
   ,x_msg_count            	OUT 	NOCOPY NUMBER
   ,x_msg_data             	OUT 	NOCOPY VARCHAR2
   ,p_mo_line_tbl		IN  	INV_Move_Order_PUB.TROLIN_TBL_TYPE
   ,p_auto_pick_confirm	        IN  	NUMBER := NULL
   ,p_grouping_rule_id	        IN  	NUMBER := NULL
   ,p_allow_partial_pick	IN	VARCHAR2 DEFAULT fnd_api.g_true
   ,x_pick_release_status	OUT	NOCOPY INV_Release_Status_Tbl_Type
   ,p_plan_tasks                IN      BOOLEAN := FALSE
   ,p_skip_cartonization        IN      BOOLEAN := FALSE
   ,p_wsh_release_table         IN OUT  NOCOPY WSH_PR_CRITERIA.relRecTabTyp
   ,p_trolin_delivery_ids       IN OUT  NOCOPY WSH_UTIL_CORE.Id_Tab_Type
   ,p_del_detail_id             IN OUT  NOCOPY WSH_PICK_LIST.DelDetTabTyp
   ,p_mo_transact_date          IN      DATE := NULL
   ,p_dynamic_replenishment     IN VARCHAR2 DEFAULT NULL
   );


   --
   -- Name
   --   PROCEDURE Reserve_Unconfirmed_Quantity
   --
   -- Purpose
   --   Transfers a reservation on material which is missing or damaged to an
   -- 	    appropriate demand source.
   --
   -- Input Parameters
   --   p_missing_quantity
   --       The quantity to be transferred to a Cycle Count reservation, in the primary
   --	    UOM for the item.
   --	p_organization_id
   --	    The organization in which the reservation(s) should be created
   --	p_reservation_id
   --	    The reservation to transfer quantity from (not required if demand source
   --	    parameters are given).
   --	p_demand_source_type_id
   --	    The demand source type ID for the reservation to be transferred
   --   p_demand_source_header_id
   --	    The demand source header ID for the reservation to be transferred
   --	p_demand_source_line_id
   --	    The demand source line ID for the reservation to be transferred
   --	p_inventory_item_id
   --	    The item which is missing or damaged.
   --	p_subinventory_code
   --	    The subinventory in which the material is missing or damaged.
   --   p_locator_id
   --	    The locator in which the material is missing or damaged.
   --	p_revision
   --	    The revision of the item which is missing or damaged.
   --	p_lot_number
   --	    The lot number of the item which is missing or damaged.
   --
   -- Output Parameters
   --   x_return_status
   --       if the pick release process succeeds, the value is
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
   --   (See fnd_api package for more details about the above output parameters)
   --
-- HW INVCONV added p_missing_quantity2
   PROCEDURE Reserve_Unconfirmed_Quantity
     (
      p_api_version			IN  	NUMBER
      ,p_init_msg_list			IN  	VARCHAR2 DEFAULT fnd_api.g_false
      ,p_commit				IN	VARCHAR2 DEFAULT fnd_api.g_false
      ,x_return_status        		OUT 	NOCOPY VARCHAR2
      ,x_msg_count            		OUT 	NOCOPY NUMBER
      ,x_msg_data             		OUT 	NOCOPY VARCHAR2
      ,p_missing_quantity		IN	NUMBER
      ,p_missing_quantity2		IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_reservation_id			IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_demand_source_header_id	IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_demand_source_line_id		IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_organization_id		IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_inventory_item_id		IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_subinventory_code		IN	VARCHAR2 DEFAULT fnd_api.g_miss_char
      ,p_locator_id			IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_revision			IN	VARCHAR2 DEFAULT fnd_api.g_miss_char
      ,p_lot_number			IN	VARCHAR2 DEFAULT fnd_api.g_miss_char
    );

PROCEDURE assign_pick_slip_number(
                     x_return_status        OUT   NOCOPY VARCHAR2,
                    x_msg_count             OUT   NOCOPY NUMBER,
                    x_msg_data              OUT   NOCOPY VARCHAR2,
                    p_move_order_header_id  IN    NUMBER   DEFAULT  0,
                    p_ps_mode               IN    VARCHAR2,
                    p_grouping_rule_id IN    NUMBER,
                    p_allow_partial_pick    IN    VARCHAR2);


PROCEDURE call_cartonization (
         p_api_version             IN   NUMBER
         ,p_init_msg_list          IN   VARCHAR2 := NULL
         ,p_commit                 IN   VARCHAR2 := NULL
         ,p_validation_level       IN   NUMBER
         ,x_return_status          OUT  NOCOPY VARCHAR2
         ,x_msg_count              OUT  NOCOPY NUMBER
         ,x_msg_data               OUT  NOCOPY VARCHAR2
         ,p_out_bound              IN   VARCHAR2
         ,p_org_id                 IN   NUMBER
         ,p_move_order_header_id   IN   NUMBER
         ,p_grouping_rule_id	   IN  	NUMBER := NULL
         ,p_allow_partial_pick	   IN	VARCHAR2 DEFAULT fnd_api.g_true
);

/* Bug 7504490 - Added the procedure Reserve_Unconfqty_lpn. This procedure transfers the reservation
   of the remaining quantity (task qty-picked qty) to cycle count reservation and ensures that the
   lpn_id is stamped on the reservation if the task was for an allocated lpn. */

  PROCEDURE Reserve_Unconfqty_lpn
     (
      p_api_version			IN  	NUMBER
      ,p_init_msg_list			IN  	VARCHAR2 DEFAULT fnd_api.g_false
      ,p_commit				IN	VARCHAR2 DEFAULT fnd_api.g_false
      ,x_return_status        		OUT 	NOCOPY VARCHAR2
      ,x_msg_count            		OUT 	NOCOPY NUMBER
      ,x_msg_data             		OUT 	NOCOPY VARCHAR2
      ,x_new_rsv_id                     OUT     NOCOPY NUMBER -- bug 8301348
      ,p_missing_quantity		IN	NUMBER
      ,p_secondary_missing_quantity     IN      NUMBER DEFAULT NULL /*9251210*/
      ,p_reservation_id			IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_demand_source_header_id	IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_demand_source_line_id		IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_organization_id		IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_inventory_item_id		IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_subinventory_code		IN	VARCHAR2 DEFAULT fnd_api.g_miss_char
      ,p_locator_id			IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_revision			IN	VARCHAR2 DEFAULT fnd_api.g_miss_char
      ,p_lot_number			IN	VARCHAR2 DEFAULT fnd_api.g_miss_char
      ,p_lpn_id                         IN	NUMBER DEFAULT fnd_api.g_miss_num
    );



END INV_Pick_Release_PUB;

/
