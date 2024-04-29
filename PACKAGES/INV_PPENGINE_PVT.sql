--------------------------------------------------------
--  DDL for Package INV_PPENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_PPENGINE_PVT" AUTHID CURRENT_USER as
/* $Header: INVVPPES.pls 120.1.12010000.2 2009/08/03 12:18:58 mitgupta ship $ */

-- File        : INVVPPES.pls
-- Content     : INV_PPEngine_PVT package specification
-- Description : Pick / put away engine private API's
-- Notes       :
-- Modified    : 30/10/98 ckuenzel created
--               02/08/99 mzeckzer changed
--               07/30/03 grao     changed
--
TYPE g_number_tbl_type IS TABLE OF NUMBER;
--
-- API name  : Create_Suggestions
-- Type      : Private
-- Function  : Creates pick and/or put away suggestions
--             The program will use WMS pick/put rules/strategies
--             if Oracle WMS is installed; otherwise, rules in
--             mtl_picking_rules will be used.
--
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

--   p_quick_pick_flag      This flag is used to call quick pick functionality for the Inventory Move
--                          If the value is 'Y' in Patch set 'J' onwords, Picking rule validation will
--                          not be called. The Default Value is 'N'
-- Output Parameters
--   x_return_status        standard output parameters
--   x_msg_count            standard output parameters
--   x_msg_data             standard output parameters
--
-- Version     :  Current version 1.0
--
-- Bug8757642. Added p_wave_simulation_mode with default vale 'N' for WavePlanning Project.
-- This project is available only in for R121 and mainline. To retain dual maintenance INV code changes are made in branchline, however it will not affect any existing flow.
PROCEDURE create_suggestions
  (
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 DEFAULT fnd_api.g_false,
   p_commit                IN  VARCHAR2 DEFAULT fnd_api.g_false,
   p_validation_level      IN  NUMBER DEFAULT fnd_api.g_valid_level_none,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   p_transaction_temp_id   IN  NUMBER,
   p_reservations          IN  inv_reservation_global.mtl_reservation_tbl_type,
   p_suggest_serial        IN  VARCHAR2 DEFAULT fnd_api.g_false,
   p_plan_tasks            IN  BOOLEAN DEFAULT FALSE,
   p_quick_pick_flag       IN  VARCHAR2  DEFAULT 'N',
   p_wave_simulation_mode  IN  VARCHAR2 DEFAULT 'N'
   ) ;
-- API name  : Create_Suggestions
-- Type      : Private
-- Function  : Creates pick and/or put away suggestions
--             The program will use WMS pick/put rules/strategies
--             if Oracle WMS is installed; otherwise, rules in
--             mtl_picking_rules will be used.
--             Overloaded to add a new parameter p_organization_id for Performance bug 5264987
PROCEDURE create_suggestions
  (
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 DEFAULT fnd_api.g_false,
   p_commit                IN  VARCHAR2 DEFAULT fnd_api.g_false,
   p_validation_level      IN  NUMBER DEFAULT fnd_api.g_valid_level_none,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   p_transaction_temp_id   IN  NUMBER,
   p_reservations          IN  inv_reservation_global.mtl_reservation_tbl_type,
   p_suggest_serial        IN  VARCHAR2 DEFAULT fnd_api.g_false,
   p_plan_tasks            IN  BOOLEAN DEFAULT FALSE,
   p_quick_pick_flag       IN  VARCHAR2  DEFAULT 'N',
   p_organization_id	   IN  NUMBER,
   p_wave_simulation_mode  IN  VARCHAR2 DEFAULT 'N'
   ) ;
END inv_ppengine_pvt;

/
