--------------------------------------------------------
--  DDL for Package MSC_ATP_PEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ATP_PEG" AUTHID CURRENT_USER AS
/* $Header: MSCAPEGS.pls 120.1 2007/12/12 10:19:02 sbnaik ship $  */
/* Procedures for CTO Re-architecture and Resource Capacity Enhancements */

-- Some global variables used during processing.
G_SUCCESS                    CONSTANT NUMBER := 0;
G_WARNING                    CONSTANT NUMBER := 1;
G_ERROR                      CONSTANT NUMBER := 2;

-- These procedures serve as interfaces between ATP Simplified Pegging
-- and other modules. This is called after the plan run.

PROCEDURE post_plan_pegging(
        ERRBUF          OUT     NoCopy VARCHAR2,
        RETCODE         OUT     NoCopy NUMBER,
        p_plan_id       IN      NUMBER);

-- This procedure is still being retained as a public procedure
-- until testing is completed.
-- This procedure is the main procedure that creates the ATP simplified pegging
-- after plan run.

PROCEDURE Generate_Simplified_Pegging(p_plan_id   IN         NUMBER,
                               p_share_partition  IN         VARCHAR2,
                               p_applsys_schema   IN         VARCHAR2,
                               RETCODE           OUT  NoCopy NUMBER
                               );
 -- x_return_status is not used as it is redundant.
 -- Here the convention corresponds to procedures that
 -- run as a part of post plan process.

-- Procedure that creates offset demands, supplies and resource_requirements
-- during ATP process when dealing with pre-scheduled ATO models, configuration items.
PROCEDURE Add_Offset_Data (
                     p_identifier         IN NUMBER,
                     p_config_line_id     IN NUMBER,
                     p_plan_id            IN NUMBER,
                     p_refresh_number     IN NUMBER,
                     p_order_number       IN NUMBER,
                     p_demand_source_type  IN NUMBER,--cmro
                     x_inv_item_id        OUT NoCopy MRP_ATP_PUB.Number_Arr,
                     x_demand_id          OUT NoCopy MRP_ATP_PUB.Number_Arr,
                     x_supply_id          OUT NoCopy MRP_ATP_PUB.Number_Arr,
                     x_res_transactions   OUT NoCopy MRP_ATP_PUB.Number_Arr,
                     x_demand_instance_id OUT NoCopy MRP_ATP_PUB.Number_Arr, --Bug 3629191
                     x_supply_instance_id OUT NoCopy MRP_ATP_PUB.Number_Arr, --Bug 3629191
                     x_res_instance_id    OUT NoCopy MRP_ATP_PUB.Number_Arr, --Bug 3629191
                     x_return_status      OUT NoCopy VARCHAR2
                     );

-- Procedure that removes offset demands, supplies and resource_requirements
-- during ATP process when dealing with pre-scheduled ATO models, configuration items.
PROCEDURE Remove_Offset_Data (
                    --p_identifiers      IN         MRP_ATP_PUB.Number_Arr,
                    --p_plan_ids         IN         MRP_ATP_PUB.Number_Arr,
                    p_inv_item_ids     IN         MRP_ATP_PUB.Number_Arr,
                    p_del_demand_ids   IN         MRP_ATP_PUB.Number_Arr,
                    p_del_supply_ids   IN         MRP_ATP_PUB.Number_Arr,
                    p_del_resrc_reqs   IN         MRP_ATP_PUB.Number_Arr,
                    p_demand_source_type IN       MRP_ATP_PUB.Number_Arr,--cmro
                    p_atp_peg_demands_plan_ids  IN MRP_ATP_PUB.Number_Arr, --Bug 3629191
                    p_atp_peg_supplies_plan_ids IN MRP_ATP_PUB.Number_Arr, --Bug 3629191
                    p_atp_peg_res_reqs_plan_ids IN MRP_ATP_PUB.Number_Arr, --Bug 3629191
                    x_return_status    OUT NoCopy VARCHAR2
                    );

-- Creates the simplified ATP Pegging for
-- ATP scheduling, un_scheduling,re-scheduling request.

PROCEDURE Create_Atp_Pegging(
  p_identifier             IN      NUMBER,
  p_instance_id            IN      NUMBER,
  p_old_plan_id            IN      NUMBER,
  p_model_order_line_id    IN      NUMBER,
  p_config_order_line_id   IN      NUMBER,
  p_demand_source_type     IN      NUMBER,--cmro
  x_return_status          OUT     NoCopy VARCHAR2
);


END MSC_ATP_PEG;

/
