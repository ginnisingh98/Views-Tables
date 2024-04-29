--------------------------------------------------------
--  DDL for Package WMS_COSTGROUPENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_COSTGROUPENGINE_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSVPPGS.pls 115.7 2004/07/07 00:46:10 grao ship $*/
--

--Input Type
--	Assign_cost_group takes two types of input: move order lines
--	and material transaction lines.  The input type differentiates
--	between the two.

g_input_mmtt	NUMBER := 1;
g_input_mtrl	NUMBER := 2;

--Current Input Type
-- This variable holds the current input type passed to the function
-- The value is used by WMS_COST_GROUPS_INPUT_V to build the view
g_current_input_type	NUMBER;

-- Simulation Mode
-- This parameter is used by the rules simulation form to simulate
-- cost group rules.
g_no_simulation		NUMBER := 0;
g_strategy_mode		NUMBER := 1;
g_rule_mode		NUMBER := 2;

-- Global variable to hold counter values for each rule type which would be used to buffer the counter
-- for a given session
g_rule_list_cg_ctr   	NUMBER;


/*assign_cost_group
 */
PROCEDURE  assign_cost_group(
   p_api_version                  IN   NUMBER
  ,p_init_msg_list                IN   VARCHAR2 DEFAULT fnd_api.g_false
  ,p_commit                       IN   VARCHAR2 DEFAULT fnd_api.g_false
  ,p_validation_level             IN   NUMBER   DEFAULT fnd_api.g_valid_level_full
  ,x_return_status                OUT  NOCOPY VARCHAR2
  ,x_msg_count                    OUT  NOCOPY NUMBER
  ,x_msg_data                     OUT  NOCOPY VARCHAR2
  ,p_line_id                      IN   NUMBER
  ,p_input_type                   IN   NUMBER
  ,p_simulation_mode		  IN   NUMBER DEFAULT 0
  ,p_simulation_id                IN   NUMBER DEFAULT NULL
);

--Current Input Type
FUNCTION GetCurrentInputType RETURN NUMBER;

END WMS_CostGroupEngine_PVT;

 

/
