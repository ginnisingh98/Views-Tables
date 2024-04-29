--------------------------------------------------------
--  DDL for Package WMS_STRATEGY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_STRATEGY_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSVPPSS.pls 120.1.12010000.2 2009/07/31 13:42:18 mitgupta ship $ */
--
-- File        : WMSVPPSS.pls
-- Content     : WMS_Strategy_PVT package specification
-- Description : WMS private API's
-- Notes       :
-- Modified    : 02/08/99 mzeckzer created
-- Modified    : 05/17/02 Grao
-- Modified    : 05/12/05 Grao - added p_rule_id  / 'K'
--
g_allocated_quantity    NUMBER;
g_over_allocation_mode  NUMBER;
g_tolerance_value       NUMBER;

-- API name    : Search
-- Type        : Private
-- Function    : Searches for a WMS strategy according to
--               provided transaction/reservation input and set up strategy
--               assignments to business objects.
--               Calls stub procedure to search for strategy assignments in a
--               customer-defined manner before actually following his own
--               algorithm to determine the valid strategy.
-- Pre-reqs    : transaction record in WMS_STRATEGY_MAT_TXN_TMP_V uniquely
--               identified by parameters p_transaction_temp_id (which
--               is the move order line id) and
--               p_type_code ( base table MTL_TXN_REQUEST_LINES)
-- Input Parameters  :
--   p_api_version          Standard Input Parameter
--   p_init_msg_list        Standard Input Parameter
--   p_validation_level     Standard Input Parameter
--   x_return_status        Standard Output Parameter
--   x_msg_count            Standard Output Parameter
--   x_msg_data             Standard Output Parameter
--   p_transaction_temp_id  equals the move order line id
--                          for the request
--   p_type_code            1 - put away; 2 - pick
--
-- Output Parameter :
--   x_strategy_id          found strategy id
--
-- Version     :
--  Current version 1.0
-- Notes       : calls stub procedure WMS_Custom_PUB.SearchForStrategy
--               and API's of WMS_Common_PVT
--
procedure Search
  ( p_api_version          IN   NUMBER
   ,p_init_msg_list        IN   VARCHAR2 DEFAULT fnd_api.g_false
   ,p_validation_level     IN   NUMBER   DEFAULT fnd_api.g_valid_level_full
   ,x_return_status        OUT NOCOPY   VARCHAR2
   ,x_msg_count            OUT NOCOPY   NUMBER
   ,x_msg_data             OUT NOCOPY  VARCHAR2
   ,p_transaction_temp_id  IN   NUMBER   DEFAULT NULL
   ,p_type_code            IN   NUMBER   DEFAULT NULL
   ,x_strategy_id          OUT NOCOPY  NUMBER
   ,p_organization_id	   IN	NUMBER	 DEFAULT NULL
   );
--
-- API name    : Apply
-- Type        : Private
-- Function    : Applies a WMS strategy to the given transaction
--               or reservation input parameters and creates recommendations
-- Pre-reqs    : transaction record in WMS_STRATEGY_MAT_TXN_TMP_V uniquely
--               identified by parameters p_transaction_temp_id and
--               p_type_code ( base table MTL_TXN_REQUEST_LINES)
--               at least one transaction detail record in
--               WMS_TRX_DETAILS_TMP_V identified by line type code = 1
--               and parameters p_transaction_temp_id and p_type_code
--               ( base tables MTL_TXN_REQUEST_LINES and
--               WMS_TRANSACTIONS_TEMP )
--               strategy record in WMS_STRATEGIES_B uniquely identified by
--               parameter p_strategy_id
--               at least one strategy member record in
--               WMS_STRATEGY_MEMBERS identified by parameter
--               p_strategy_id
-- Parameters  :
--  p_api_version
--  p_init_msg_list
--  p_commit
--  p_validation_level
--
--  x_return_status
--  x_msg_count
--  x_msg_data
--  p_transaction_temp_id
--  p_type_code
--  p_strategy_id
-- ,p_quick_pick_flag      in   varchar2 default 'N'  The other value is 'Y'
--                               'Y' is passed in patchset 'J' onwards for Inventory Moves
--                                when the lpn_request_context is 1
-- Version     :  Current version 1.0
-- Version     :  Current version 1.0
--
--                    Changed ...
--               Previous version
--
--                Initial version 1.0
-- Notes       : calls API's of WMS_Common_PVT, WMS_Rule_PVT
--                and INV_Quantity_Tree_PVT
--               This API must be called internally by
--                WMS_Engine_PVT.Create_Suggestions only !
-- End of comments

procedure Apply (
          p_api_version          in   number
         ,p_init_msg_list        in   varchar2 DEFAULT fnd_api.g_false
         ,p_commit               in   varchar2 DEFAULT fnd_api.g_false
         ,p_validation_level     in   number   DEFAULT fnd_api.g_valid_level_full
         ,x_return_status        out  NOCOPY  varchar2
         ,x_msg_count            out  NOCOPY number
         ,x_msg_data             out  NOCOPY varchar2
         ,p_transaction_temp_id  in   number   DEFAULT NULL
         ,p_type_code            in   number   DEFAULT NULL
         ,p_strategy_id          in   number   DEFAULT NULL
         ,p_rule_id     	 in   number   DEFAULT NULL         -- [ Added new column p_rule_id ]
         ,p_detail_serial        in   BOOLEAN  DEFAULT FALSE
         ,p_from_serial          IN   VARCHAR2 DEFAULT NULL
         ,p_to_serial            IN   VARCHAR2 DEFAULT NULL
         ,p_detail_any_serial    IN   NUMBER   DEFAULT NULL
         ,p_unit_volume          IN   NUMBER   DEFAULT NULL
         ,p_volume_uom_code      IN   VARCHAR2 DEFAULT NULL
         ,p_unit_weight          IN   NUMBER   DEFAULT NULL
         ,p_weight_uom_code      IN   VARCHAR2 DEFAULT NULL
         ,p_base_uom_code        IN   VARCHAR2 DEFAULT NULL
         ,p_lpn_id               IN   NUMBER   DEFAULT NULL
         ,p_unit_number          IN   VARCHAR2 DEFAULT NULL
         ,p_allow_non_partial_rules IN  BOOLEAN DEFAULT TRUE
         ,p_simulation_mode	 IN   NUMBER   DEFAULT 0
         ,p_simulation_id	 IN   NUMBER   DEFAULT NULL
         ,p_project_id		 IN   NUMBER   DEFAULT NULL
         ,p_task_id		 IN   NUMBER   DEFAULT NULL
         ,p_quick_pick_flag      IN   VARCHAR2 DEFAULT 'N'
	 ,p_wave_simulation_mode IN VARCHAR2 DEFAULT 'N'
                );

  -- Name        : InitStrategyRules
  -- Function    : Initializes internal table of strategy members ( = rules ).
  -- Pre-reqs    : none
  -- Parameters  :
  --  x_return_status              out varchar2(1)
  --  x_msg_count                  out number
  --  x_msg_data                   out varchar2(2000)
  --  p_strategy_id                in  number   required
  -- Notes       : private procedure for internal use only
  -- End of comments

  procedure InitStrategyRules (
            x_return_status                out  NOCOPY varchar2
           ,x_msg_count                    out  NOCOPY number
           ,x_msg_data                     out  NOCOPY varchar2
           ,p_strategy_id                  in   number);

g_debug      NUMBER;

end wms_strategy_pvt;

/
