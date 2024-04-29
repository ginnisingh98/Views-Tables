--------------------------------------------------------
--  DDL for Package WMS_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_ENGINE_PVT" AUTHID CURRENT_USER as
/* $Header: WMSVPPES.pls 120.5.12010000.2 2009/07/31 13:59:10 mitgupta ship $ */
-- File        : WMSVPPES.pls
-- Content     : WMS_Engine_PVT package specification
-- Description : wms rules engine private API's
-- Notes       :
-- Modified    : 30/10/98 ckuenzel created
--               02/08/99 mzeckzer changed


--changed by jcearley on 11/22/99 from nested table to table indexed
-- by binary integer.  was causing error in insert_detail_temp_records
TYPE g_number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

-- Static values used for p_simulation_mode parameter
g_full_simulation            NUMBER := 0;
g_pick_strategy_mode         NUMBER := 1;
g_pick_rule_mode             NUMBER := 2;
g_put_strategy_mode          NUMBER := 3;
g_put_rule_mode              NUMBER := 4;
g_pick_full_mode             NUMBER := 5;
g_available_inventory        NUMBER := 10;
g_put_full_mode              NUMBER := 20;
g_no_simulation              NUMBER := -1;

g_mo_quantity                NUMBER ;
g_Is_xdock                   BOOLEAN;
--
-- API name  : Create_Suggestions
-- Type      : Private
-- Function  : Creates pick / put away suggestions according to provided
--             transaction or reservation input parameters and set up master
--             data.
-- Notes
--   1. Integration with reservations
--      If table p_reservations passed by the calling is not empty, the
--      engine will detailing based on a combination of the info in the
--      move order line (the record that represents detailing request),
--      and the info in p_reservations. For example, a sales order line
--      can have two reservations, one for revision A in quantity of 10,
--      and one for revision B in quantity of 5, and the line quantity
--      can be 15; so when the pick release api calls the engine
--      p_reservations will have two records of the reservations. So
--      if the move order line based on the sales order line does not
--      specify a revision, the engine will merge the information from
--      move order line and p_reservations to create the input for
--      detailing as two records, one for revision A, and one for revision
--      B. Please see documentation for the pick release API for more
--      details.
--
--  2.  Serial Number Detailing in Picking
--      Currently the serial number detailing is quite simple. If the caller
--      gives a range (start, and end) serial numbers in the move order line
--      and pass p_suggest_serial as fnd_api.true, the engine will filter
--      the locations found from a rule, and suggest unused serial numbers
--      in the locator. If p_suggest_serial is passed as fnd_api.g_false
--      (default), the engine will not give serial numbers in the output.
--
-- Input Parameters
--   p_api_version_number   standard input parameter
--   p_init_msg_lst         standard input parameter
--   p_commit               standard input parameter
--   p_validation_level     standard input parameter
--   p_transaction_temp_id  equals to the move order line id
--                          for the detailing request
--   p_reservations         reservations for the demand source
--                          as the transaction source
--                          in the move order line.
--   p_suggest_serial       whether or not the engine should suggest
--                          serial numbers in the detailing
--   p_simulation_mode	    indicates whether engine is being called
-- 			    from the simulation forms or not, and
--			    whether the simulation is on the rule
--			    or the strategy; if simulating the entire
--			    rules engine run, then set = 0;
--   p_simulation_id	    If simulation_mode = 1, this should be
--			    the strategy_id to simulate
--			    IF simulation mode = 2, this should be
--			    the id of the rule to simulate
--   p_quick_pick_flag      in   varchar2 default 'N'  The other value is 'Y'
--                          'Y' is passed in patchset 'J' onwards for Inventory Moves
--                           when the lpn_request_context is 1
--
-- Output Parameters
--   x_return_status        standard output parameters
--   x_msg_count            standard output parameters
--   x_msg_data             standard output parameters
--
-- Version     :  Current version 1.0
PROCEDURE create_suggestions
  (p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 DEFAULT fnd_api.g_false,
   p_commit                IN  VARCHAR2 DEFAULT fnd_api.g_false,
   p_validation_level      IN  NUMBER DEFAULT fnd_api.g_valid_level_none,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   p_transaction_temp_id   IN  NUMBER,
   p_reservations          IN  inv_reservation_global.mtl_reservation_tbl_type,
   p_suggest_serial        IN  VARCHAR2 DEFAULT fnd_api.g_false,
   p_simulation_mode	   IN  NUMBER DEFAULT -1,
   p_simulation_id	   IN  NUMBER DEFAULT NULL,
   p_plan_tasks            IN  BOOLEAN DEFAULT FALSE,
   p_quick_pick_flag       IN   VARCHAR2 DEFAULT 'N',
   p_wave_simulation_mode IN VARCHAR2 DEFAULT 'N'
   );


--Global variable.  If the move order type is Pick Wave, then
--pick detailing can pick from the destination sub/locator, and this
--is set to 1. Set in this package, but used in WMS_RULE_PVT.apply
g_dest_sub_pick_allowed NUMBER;

--Global variable for locator code of from_sub, to_sub, and item
--Bug #3051649 /Grao : Org locator control
--Set in this package, but used in wms_rule_pvt.apply for determining
--if from sub/loc = to sub/loc.

g_org_loc_control NUMBER;
g_sub_loc_control NUMBER;
g_item_loc_control NUMBER;

--Global variables used for debug trace
g_trace_header_id NUMBER;
g_business_object_id NUMBER;

--Bug 2400549
--these values are used in wms_rule_pvt.Apply
g_move_order_type NUMBER;
g_transaction_action_id NUMBER;

--bug 2589499
--this value used in wms_rule_pvt.Apply
g_reservable_putaway_sub_only BOOLEAN;

--bug 2778814
--this value used in wms_rule_pvt.Apply
g_serial_number_control_code NUMBER;

-- LG convergence add
G_inventory_availability_tbl    wms_search_order_globals_pvt.pre_suggestions_record_tbl;
-- END of LG convergence add

-- patchset 'J' : to populate more meaningful error messages during inventory moves and Rules Simulator
-- This global variable would be updated from WMS_ENGINE_PVT.create_suggestions, WMS_STRATEGY_PVT.APPLY(),
--  and WMS_RULES_PVT.APPLY() and WMS_RULES_PVT,QUICK_PICK().
-- At the end of the create suggestion call, the contents of this variable would be pushed to message stack.
-- This message would be retrived from Rules Simulator and Putaway drop /load  pages.


 g_sugg_failure_message  VARCHAR2(4000);
--

END wms_engine_pvt;

/
