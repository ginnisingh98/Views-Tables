--------------------------------------------------------
--  DDL for Package MSD_ASCP_FLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_ASCP_FLOW" AUTHID CURRENT_USER AS
/* $Header: msdxscps.pls 120.1 2005/12/19 01:25:33 amitku noship $ */

  PROCEDURE LAUNCH_ASCP_PLAN
  ( itemtype  in varchar2
  , itemkey   in varchar2
  , actid     in number
  , funcmode  in varchar2
  , resultout out NOCOPY varchar2
  );

  function get_priority(p_demand_plan_id in number,
                      p_scenario_id in number,
                      p_sr_instance_id in number,
                      p_bucket_type in number,
                      p_start_time in date,
                      p_end_time in date,
                      p_inventory_item_id in number,
                      p_demand_class in varchar2)
  return number;

  PROCEDURE populate_denorm_tables(p_demand_plan_id  number);

  END MSD_ASCP_FLOW;

 

/
