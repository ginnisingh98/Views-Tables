--------------------------------------------------------
--  DDL for Package CN_SCENARIOS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SCENARIOS_PVT" AUTHID CURRENT_USER AS
/*$Header: cnvscns.pls 120.0 2007/07/26 01:11:11 appldev noship $*/


/*
   1. Pass p_role_plan_id when you are dis associating a role from the plan or plan to a role
   2. Pass p_comp_plan_id when you are about to delete a compensation plan
*/

PROCEDURE delete_scenario_plans
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_role_plan_id               IN      CN_SCENARIO_PLANS_ALL.ROLE_PLAN_ID%TYPE  := NULL,
   p_comp_plan_id               IN      CN_SCENARIO_PLANS_ALL.COMP_PLAN_ID%TYPE  := NULL,
   p_role_id                    IN      CN_SCENARIO_PLANS_ALL.ROLE_ID%TYPE  := NULL,
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        );

END CN_SCENARIOS_PVT;

/
