--------------------------------------------------------
--  DDL for Package MSD_FCST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_FCST_PUB" AUTHID CURRENT_USER AS
    /* $Header: msdfpshs.pls 115.11 2003/10/08 03:36:42 dkang ship $ */

procedure MSDFPUSH_execute(
  errbuf out NOCOPY varchar2,
  retcode out NOCOPY varchar2,
  p_demand_plan_id in number,
  p_scenario_id in number,
  p_revision in varchar2,
  p_instance_id in number,
  p_forecast_designator in varchar2,
  p_forecast_set in varchar2,
  p_demand_class in varchar2,
  p_level_id in number,
  p_value_id in number,
  p_customer_id in number,
  p_location_id in number,
  p_use_baseline_fcst in number,
  p_workday_control in number);

function get_result(
  v_sql_stmt in varchar2)
return varchar2;

END msd_fcst_pub;

 

/
