--------------------------------------------------------
--  DDL for Package Body INV_PPENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_PPENGINE_PVT" AS
/* $Header: INVVPPEB.pls 120.1.12010000.2 2009/08/03 12:21:15 mitgupta ship $ */
--
-- File        : INVVPPEB.pls
-- Content     : INV_PPEngine_PVT package body
-- Description : Pick / put away engine private API's
-- Notes       :
-- Modified    : 30/10/98 ckuenzel created
--               02/08/99 mzeckzer changed
--               04/05/99 bitang   changed
--               07/28/99 bitang   changed
--               07/31/99 bitang   moved some procedures to inv_pp_util_pvt
--                                 packages
--               07/30/03 grao     changed
--
g_pkg_name constant varchar2(30) := 'INV_PPEngine_PVT';
--
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
--
-- Output Parameters
--   x_return_status        standard output parameters
--   x_msg_count            standard output parameters
--   x_msg_data             standard output parameters
--
-- Version     :  Current version 1.0

-- Create_suggestions api is overloaded for Performance bug fix 5264987
-- Added a new IN Parameter p_organization_id
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
   p_plan_tasks            IN  BOOLEAN,
   p_quick_pick_flag       IN  VARCHAR2  DEFAULT 'N',
   p_organization_id       IN  NUMBER,
   p_wave_simulation_mode  IN  VARCHAR2 DEFAULT 'N'
   ) is
     l_api_version         CONSTANT NUMBER := 1.0;
     l_api_name            CONSTANT VARCHAR2(30) := 'Create_Suggestions';
     l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_msg_count           NUMBER;
     l_msg_data            VARCHAR2(2000);
     l_wms_installed       BOOLEAN;
     l_org_id	           NUMBER;
     l_return_value BOOLEAN := TRUE;   -- for Bug #3153166

     -- Rules J Project Variables

   l_current_release_level        NUMBER      :=  INV_CONTROL.G_CURRENT_RELEASE_LEVEL;
   l_j_release_level              NUMBER      :=  110510;
   l_k_release_level              NUMBER      :=  110511;

---
BEGIN
   --
   -- debugging section
   -- can be commented out for final code
   IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe(' '); -- new line
      inv_pp_debug.send_message_to_pipe
	('********************** Pick and Put Away Engine Testing Trace **********************');
      inv_pp_debug.send_message_to_pipe('enter '||g_pkg_name||'.'||l_api_name);
   END IF;
   -- end of debugging section
   --
   -- Standard Call to check for call compatibility
   IF NOT fnd_api.Compatible_API_Call(l_api_version
                                      , p_api_version
                                      , l_api_name
                                      , g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   --
   -- Initialize message list if p_init_msg_list is set to true
   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;
   --
   -- Initialisize API return status to access
   x_return_status := fnd_api.g_ret_sts_success;
   --
   -- Detailing starts here
   --
   -- Fix 5264987 : Query DB only if p_organization_id is not passed/-9999
   l_org_id := p_organization_id;

   IF l_org_id = -9999 THEN
      --get organization id so we can find out if wms is installed;
      SELECT organization_id
      INTO l_org_id
      FROM mtl_txn_request_lines
      WHERE line_id = p_transaction_temp_id;
   END IF;
   -------------------------------------------------------------------
   -- Important:
   --     If Oracle WMS is not installed, the program will
   --  call inv_autodetail to use pick rules in mtl_picking_rules;
   --  otherwise call wms_engine_pvt to detail using wms rules/strategies
   -------------------------------------------------------------------
   --
   --for Bug#3153166: Performace Issue, Will Check the cache before
   --calling wms_install.check_install, to check wms installed
   --or not
   /*l_wms_installed :=
     wms_install.check_install(
	  x_return_status       => l_return_status,
	  x_msg_count           => l_msg_count,
	  x_msg_data            => l_msg_data,
	  p_organization_id	=> l_org_id); */
   l_return_value := INV_CACHE.set_wms_installed(l_org_id);
   If NOT l_return_value Then
          RAISE fnd_api.g_exc_unexpected_error;
   End If;
   l_wms_installed := INV_CACHE.wms_installed;
   --End of Changes for Bug#3153166

   gmi_reservation_util.println('getting crreate_sugg');
   /* as part of inventory convergence, all allocations will converge
    * in common WMS create_suggenstions logic after 11.5.11
    */
   IF l_wms_installed = FALSE
        AND (l_current_release_level < l_k_release_level )
   THEN
      gmi_reservation_util.println('calling inv crreate_sugg');
      inv_autodetail.create_suggestions
              ( p_api_version         => 1.0,
                 p_init_msg_list       => fnd_api.g_false,
                 p_commit              => fnd_api.g_false,
                 p_validation_level    => p_validation_level,
                 x_return_status       => l_return_status,
                 x_msg_count           => l_msg_count,
                 x_msg_data            => l_msg_data,
                 p_transaction_temp_id => p_transaction_temp_id,
                 p_reservations        => p_reservations,
                 p_suggest_serial      => p_suggest_serial
              );
   ELSE
       IF (l_current_release_level >= l_j_release_level ) THEN
           gmi_reservation_util.println(' calling >=J wms create_sugg, 11511 is included');
              wms_engine_pvt.create_suggestions
                 ( p_api_version        => 1.0,
                    p_init_msg_list       => fnd_api.g_false,
                    p_commit              => fnd_api.g_false,
                    p_validation_level    => p_validation_level,
                    x_return_status       => l_return_status,
                    x_msg_count           => l_msg_count,
                    x_msg_data            => l_msg_data,
                    p_transaction_temp_id => p_transaction_temp_id,
                    p_reservations        => p_reservations,
                    p_suggest_serial      => p_suggest_serial,
                    p_plan_tasks          => p_plan_tasks,
                    p_quick_pick_flag     => p_quick_pick_flag,
		    p_wave_simulation_mode       => p_wave_simulation_mode
                 );
        ELSE
           gmi_reservation_util.println(' calling <J wms create_sugg');
              wms_engine_pvt.create_suggestions
                 ( p_api_version        => 1.0,
                    p_init_msg_list       => fnd_api.g_false,
                    p_commit              => fnd_api.g_false,
                    p_validation_level    => p_validation_level,
                    x_return_status       => l_return_status,
                    x_msg_count           => l_msg_count,
                    x_msg_data            => l_msg_data,
                    p_transaction_temp_id => p_transaction_temp_id,
                    p_reservations        => p_reservations,
                    p_suggest_serial      => p_suggest_serial,
                    p_plan_tasks          => p_plan_tasks
                 );
        END IF;
   END IF;

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   -- Standard check of p_commit
   IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
   END IF;
   --
   -- debugging section
   -- can be commented out for final code
   IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('exit '||g_pkg_name||'.'||l_api_name);
   END IF;
   -- end of debugging section
   --
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.Count_And_Get
        ( p_count => x_msg_count
         ,p_data => x_msg_data);
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.Count_And_Get
        ( p_count => x_msg_count
         ,p_data => x_msg_data);
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.Check_Msg_Level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.Add_Exc_Msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get
        ( p_count => x_msg_count
         ,p_data => x_msg_data);
END create_suggestions;

-- Create_suggestions api is overloaded for Performance bug fix 5264987
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
   p_plan_tasks            IN  BOOLEAN,
   p_quick_pick_flag       IN  VARCHAR2  DEFAULT 'N',
   p_wave_simulation_mode  IN  VARCHAR2 DEFAULT 'N'
   ) is
   l_organization_id NUMBER := -9999;

BEGIN
	create_suggestions(
   		 p_api_version        => p_api_version
		,p_init_msg_list      => p_init_msg_list
		,p_commit             => p_commit
		,p_validation_level   => p_validation_level
		,x_return_status      => x_return_status
		,x_msg_count          => x_msg_count
		,x_msg_data           => x_msg_data
		,p_transaction_temp_id=> p_transaction_temp_id
		,p_reservations       => p_reservations
		,p_suggest_serial     => p_suggest_serial
		,p_plan_tasks	     => p_plan_tasks
		,p_quick_pick_flag    => p_quick_pick_flag
		,p_organization_id    => l_organization_id
		,p_wave_simulation_mode => p_wave_simulation_mode);
END create_suggestions;
--
end inv_ppengine_pvt;

/
