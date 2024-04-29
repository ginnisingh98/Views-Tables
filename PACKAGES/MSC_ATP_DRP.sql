--------------------------------------------------------
--  DDL for Package MSC_ATP_DRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ATP_DRP" AUTHID CURRENT_USER AS
/* $Header: MSCATDRS.pls 120.0 2005/05/25 20:15:08 appldev noship $  */

-- Procedure that nets supplies and demands for DRP plan.
PROCEDURE Get_Mat_Avail_Drp (
   p_item_id            IN NUMBER,
   p_org_id             IN NUMBER,
   p_instance_id        IN NUMBER,
   p_plan_id            IN NUMBER,
   p_itf                IN DATE,
   x_atp_dates          OUT NoCopy MRP_ATP_PUB.date_arr,
   x_atp_qtys           OUT NoCopy MRP_ATP_PUB.number_arr
);

-- Procedure that nets supplies and demand details  for DRP plan.
PROCEDURE Get_Mat_Avail_Drp_dtls (
   p_item_id            IN NUMBER,
   p_request_item_id    IN NUMBER,
   p_org_id             IN NUMBER,
   p_instance_id        IN NUMBER,
   p_plan_id            IN NUMBER,
   p_itf                IN DATE,
   p_level              IN NUMBER,
   p_scenario_id        IN NUMBER,
   p_identifier         IN NUMBER
);

-- procedure for full summation of
-- supply/demand for DRP plans.

PROCEDURE LOAD_SD_FULL_DRP(p_plan_id  IN NUMBER,
                           p_sys_date IN DATE);

-- summary enhancement : procedure for net summation of supply/demand
--                       for DRP cases.

PROCEDURE LOAD_SD_NET_DRP  (p_plan_id             IN NUMBER,
                            p_last_refresh_number IN NUMBER,
                            p_new_refresh_number  IN NUMBER,
                            p_sys_date            IN DATE);

-- Procedure that nets supplies and demands for DRP plan when summary is enabled.
PROCEDURE get_mat_avail_drp_summ (
    p_item_id           IN NUMBER,
    p_org_id            IN NUMBER,
    p_instance_id       IN NUMBER,
    p_plan_id           IN NUMBER,
    p_itf               IN DATE,
    p_refresh_number    IN NUMBER,   -- For summary enhancement
    x_atp_dates         OUT NoCopy MRP_ATP_PUB.date_arr,
    x_atp_qtys          OUT NoCopy MRP_ATP_PUB.number_arr);

END MSC_ATP_DRP;

 

/
