--------------------------------------------------------
--  DDL for Package EAM_WB_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WB_UTILS" AUTHID CURRENT_USER AS
/* $Header: EAMWBUTS.pls 120.8 2006/09/19 14:30:10 kmurthy noship $ */

  type t_WorkBenchIdTable is table of NUMBER index by binary_integer ;

  -- declare a PL/SQL table to record pm_forecast_id's
  current_forecasts_index system.eam_wipid_tab_type;
  current_forecasts_index2 t_WorkBenchIdTable;
  current_forecasts t_WorkBenchIdTable;

  empty_id_list t_WorkBenchIdTable; -- to clear current_forecasts

  -- declare 2 PL/SQL tables to record wip_entity_id's
  -- one fore Draft (not_ready under WPS), one for others
  work_orders_not_ready t_WorkBenchIdTable;
  work_orders_unreleased t_WorkBenchIdTable;
  work_orders_released t_WorkBenchIdTable;

  -- processes for manipulating forecast table
  procedure add_forecast(p_pm_forecast_id number);
  procedure remove_forecast(p_pm_forecast_id number);
  procedure clear_forecasts;
  function get_forecast_total return number;

  --  Procedure for autonomously converting work orders through concurrent P
  procedure convert_work_orders(p_pm_group_id number,x_request_id OUT NOCOPY number);

  --  Procedure for autonomously converting work orders through WO Business Object API
  procedure convert_work_orders2(p_pm_group_id number,
                                 p_project_id IN NUMBER DEFAULT NULL,
                                 p_task_id IN NUMBER DEFAULT NULL,
                                 p_parent_wo_id IN NUMBER DEFAULT NULL,
                                 p_return_status OUT NOCOPY VARCHAR2,
                                 p_msg OUT NOCOPY VARCHAR2);

  procedure convert_work_orders3(p_pm_group_id number,
                                 p_project_id IN NUMBER DEFAULT NULL,
                                 p_task_id IN NUMBER DEFAULT NULL,
                                 p_parent_wo_id IN NUMBER DEFAULT NULL,
                                 p_return_status OUT NOCOPY VARCHAR2,
                                 p_msg OUT NOCOPY VARCHAR2);

  -- wrapper for autonomous commit in pm scheduler
  function run_pm_scheduler(
			p_view_non_scheduled IN varchar2,
			p_start_date IN date,
			p_end_date IN date,
			p_org_id IN number,
			p_user_id IN number,
			p_stmt IN varchar2,
			p_setname_id IN number,
			p_combine_default IN varchar2) return number;

 -- wrapper for autonomous commit in pm scheduler
  procedure run_pm_scheduler2(
			p_view_non_scheduled IN varchar2,
			p_start_date IN date,
			p_end_date IN date,
			p_org_id IN number,
			p_user_id IN number,
			p_stmt IN varchar2,
			p_setname_id IN number,
			p_combine_default IN varchar2,
            p_forecast_set_id IN number,
	    p_source IN varchar2);

  -- clear eam_forecasted_work_orders table before exiting form
  procedure clear_forecasted_work_orders(p_group_id number);

  -- processes for manipulating work order tables
  procedure add_work_order(p_wip_entity_id number,wo_type number);
  procedure remove_work_order(p_wip_entity_id number,wo_type number);
  procedure clear_work_orders;
procedure clear_released_work_orders;
  function get_work_order_total return number;
    function get_work_order_release_total return number;

  --  Procedure for autonomously releasing work orders through concurrent P
  --  when there are Draft work orders under WPS installed
  procedure release_work_orders(p_group_id number,p_org_id number, p_auto_firm_flag varchar2);

  procedure complete_work_orders(p_org_id number);

  --function to check whether the previous sequnce suggesitions are implemnted or not.
  FUNCTION check_previous_implements(p_pm_group_id number)
  return boolean;

   --Function to return the default owning department
 	   function  get_owning_dept_default(
 	                                  p_organization_id         IN number,
 	                                  p_maintenance_object_type IN number,
 	                                  p_maintenance_object_id   IN number,
 	                                  p_rebuild_item_id         IN number,
 	                                  p_primary_item_id         IN number
 	                                  )    return number;

END eam_wb_utils;


 

/
