--------------------------------------------------------
--  DDL for Package MSC_GANTT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_GANTT_PKG" AUTHID CURRENT_USER AS
/* $Header: MSCGNTPS.pls 120.2 2006/09/18 20:51:16 pabram noship $  */


  -- p_query_id is null for just orders, demands,
	-- will be the parent_query_id in case of peg up/down.
  -- p_filter_type, filter_type_list 1, filter_type_mfq 2,
	-- filter_type_folder_id 3, filter_type_where_stmt 4, filter_type_among 5..
  -- p_view_type, demand_view 1, order_view 2..
  -- p_peg_type, 0 just orders, 1  peg down, -1 peg up, 2 peg_up_and_down..
  -- p_refresh true/false to refresh the view with new data

  function orderView(p_query_id in number,
    p_plan_id number, p_list varchar2, p_filter_type number,
    p_view_type number, p_peg_type number,
    p_node_count out nocopy varchar2,
    p_refresh boolean default false) return number;

procedure updateResUnitsDirectly(p_query_id number,
  p_node_type number, p_inst_id number, p_trx_id number,
  p_assigned_units_hours number,
  p_return_status OUT NOCOPY varchar2,
  p_out OUT NOCOPY varchar2);

procedure updateResHoursDirectly(p_query_id number,
  p_node_type number, p_inst_id number, p_trx_id number,
  p_resource_hours number, p_return_status OUT NOCOPY varchar2,
  p_out OUT NOCOPY varchar2);

  function addSimuAltResToView(p_query_id number,
    p_view_type number, p_node_type number, p_node_list varchar2,
    p_out out nocopy varchar2) return number;

  function addResToResView(p_from_query_id number, p_to_query_id in out nocopy number,
    p_from_index number, p_critical number) return number;

  function addSuppToSuppView(p_from_query_id number, p_to_query_id in out nocopy number,
    p_from_index number) return number;

function AddToOrdersView(p_from_query_id number, p_to_query_id in out nocopy number,
  p_from_index number, p_from_view_type number,
  p_context_value varchar2, p_context_value2 varchar2 default null) return number;

  -- p_query_id is null for initial calculation,
	-- will be passed to fetch next set using p_from_index, p_to_index..
  -- p_filter_type, filter_type_list 1, filter_type_mfq 2,
	-- filter_type_folder_id 3, filter_type_where_stmt 4, filter_type_among 5..
  -- p_view_type, RES_ACTIVITIES_VIEW 3, RES_UNITS_VIEW 4, RES_HOURS_VIEW 5;
  -- p_from_index number, p_to_index number row_index range to show
  -- p_name_data contains the hgrid data
  -- p_require_data contains the req data for res/supp
  -- p_setup_data contains the setup data for res
  -- p_avail_data contains the avail data for res/supp
  -- p_batched_res_act boolean default false, <individual vs batched >
	--   RES_ACT_INDIVIDUAL null or 1, RES_ACT_BATCHED 2;
  -- p_display_type number default null,
	--  DISPLAY_NONE 1, DISPLAY_LATE 2, DISPLAY_EARLY 3, DISPLAY_FIRM 4, DISPLAY_OVERLOAD 5;
  -- p_refresh true/false to refresh the view with new data

  function resourceView (p_query_id in out nocopy number,
    p_plan_id number, p_list varchar2,
    p_filter_type number, p_view_type number,
    p_from_index number, p_to_index number,
    p_name_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
    p_require_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
    p_avail_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
    p_batched_res_act number default null,
    p_display_type number default null,
    p_refresh boolean default false,
    p_sort_column varchar2 default null,
    p_sort_order varchar2 default null,
    p_change_view boolean default false,
    p_folder_id number default null) return number;

  -- p_query_id is null for initial calculation,
	-- will be passed to fetch next set using p_from_index, p_to_index..
  -- p_filter_type, filter_type_list 1, filter_type_mfq 2,
	-- filter_type_folder_id 3, filter_type_where_stmt 4, filter_type_among 5..
  -- p_view_type, RES_ACTIVITIES_VIEW 3, RES_UNITS_VIEW 4, RES_HOURS_VIEW 5;
  -- p_from_index number, p_to_index number row_index range to show
  -- p_name_data contains the hgrid data
  -- p_avail_data - avail stream
  -- p_net_cum_avail_data - net cumulative avail stream
  -- p_consume_curr_data - consumed in current bucket stream
  -- p_consume_future_data - consumed in future bucket stream
  -- p_overload_data - overload stream
  -- p_refresh true/false to refresh the view with new data

  function supplierView(p_query_id in out nocopy number,
    p_plan_id number, p_list varchar2,
    p_filter_type number, p_view_type number,
    p_from_index number, p_to_index number,
    p_name_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
    p_supp_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
    p_refresh boolean default false,
    p_sort_column varchar2 default null,
    p_sort_order varchar2 default null) return number;

  procedure sortResSuppView(p_query_id number,
    p_view_type number, p_from_index number, p_to_index number,
    p_name_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
    p_sort_column varchar2 default null,
    p_sort_order varchar2 default null);

  -- p_query_id
  -- p_view_type, ORDER_VIEW 2, RES_ACTIVITIES_VIEW 3
  -- p_node_type <JOB_NODE, RES_NODE, COPROD_NODE>
  -- p_firm_type <firm, unfirm for supply>, <8 firm types for res req>
  -- p_start_date, p_end_date <firm start and firm end dates>
  -- p_row_index_list is (inst_id, trx id),(inst_id, trx_id)
  -- p_return_status 'OK' or 'ERROR'
  -- p_out the error type
  -- p_out_data the sequence list <group seq id, group seq number>, ...
  -- p_res_firm_seq if true will be sequence firmed.

  procedure firmUnfirm(p_query_id number,
    p_view_type number, p_node_type number,
    p_firm_type number,
    p_start_date date, p_end_date date,
    p_trx_list varchar2,
    p_return_status OUT NOCOPY varchar2,
    p_out OUT NOCOPY varchar2,
    p_out_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
    p_validate_flag boolean default true,
    p_res_firm_seq boolean default false,
    p_batched_res_act boolean default false);

  -- p_query_id
  -- p_view_type, ORDER_VIEW 2, RES_ACTIVITIES_VIEW 3
  -- p_from_node_type, p_to_node_type is not null between 2 rows
  -- p_from_trx_list, p_to_trx_list is not null between 2 rows
  -- p_start_date, p_end_date start and end dates of node
  -- p_duration for sequence firming move
  -- p_return_status 'OK' or 'ERROR'
  -- p_out the error type

  procedure moveNode(p_query_id number, p_view_type number,
    p_node_type number, p_to_node_type number,
    p_trx_list varchar2, p_to_trx_list varchar2,
    p_start_date date, p_end_date date, p_duration varchar2,
    p_return_status OUT NOCOPY varchar2,
    p_out OUT NOCOPY varchar2,
    p_out_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
    p_validate_flag boolean default true,
    p_res_firm_seq boolean default false,
    p_batched_res_act boolean default false);

  -- p_node_type - valid values RES_NODE, RES_INST_NODE
  -- p_to_node_type - valid values RES_NODE, RES_INST_NODE,
	--   is not null between 2 rows
  -- p_firm_type 0..7 for res req
  -- p_trx_list is (inst_id, trx id),(inst_id, trx_id)
  -- p_to_trx_list is (res_id,res_inst_id, serial_number, alt_number)
  -- p_start_date, p_end_date <firm start and firm end dates>
  -- p_duration in long type for sequence firming move, is it supported from form
  -- p_return_status 'OK' or 'ERROR'
  -- p_out the error type
  -- p_out_data the sequence list <group seq id, group seq number>, ...
  -- p_validate_flag boolean default true,
  -- p_res_firm_seq boolean default false,

  procedure moveAndFirm(p_node_type number, p_to_node_type number,
    p_firm_type number, p_trx_list varchar2, p_to_trx_list varchar2,
    p_start_date date, p_end_date date, p_duration varchar2,
    p_return_status OUT NOCOPY varchar2, p_out OUT NOCOPY varchar2,
    p_out_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
    p_validate_flag boolean default true,
    p_res_firm_seq boolean default false);

  --p_trx_list is (inst_id, trx id),(inst_id, trx_id)
  procedure resCharges(p_query_id number,
    p_trx_list varchar2, p_out_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl);

  --p_row_indexes is list of row_indexes separated by commas
  -- output. from_row_index, from_start_date, from_end_date
  --to_row_index, to_start_date, to_end_date, dependency_type

  procedure segmentPegging(p_query_id number,
    p_trx_list varchar2, p_out_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl);

--wrapper

--sets the user perference id and will be used thereafter
procedure getUserPref(p_pref_id number);

function getPlanInfo(p_plan_id number) return varchar2;

function isPlanGanttEnabled(p_plan_id number) return boolean;
function isPlanDSEnabled(p_plan_id number) return boolean;

procedure getSimuResource(p_plan_id number,
  p_transaction_id number, p_instance_id number,
  p_name OUT NOCOPY varchar2, p_id OUT NOCOPY varchar2,
  p_node_type number default null);

procedure getAltResource(p_plan_id number,
  p_transaction_id number, p_instance_id number,
  p_name OUT NOCOPY varchar2, p_id OUT NOCOPY varchar2,
  p_node_type number default null,
  p_from_form number default null);

function getResult(p_query_id number,
  p_from_index number, p_to_index number,
  p_out_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
  p_node_level number default null,
  p_sort_node number default null,
  p_sort_column varchar2 default null,
  p_sort_order varchar2 default null,
  p_res_nodes_only varchar2 default null) return number;

function getEndDemandIds(p_plan_id number, p_view_type number, p_node_type number,
  p_trx_list varchar2, p_date1 date default null, p_date2 date default null) return number;

procedure getProperty(p_plan_id number, p_instance_id number,
  p_transaction_id number, p_type number, p_view_type number,
  v_pro out NOCOPY varchar2, v_demand out NOCOPY varchar2);

--5516790 bugfix
function getNewViewStartDate(p_node_type number, p_trx_id number, p_to_view_type number) return date;

function getDebugProfile return varchar2;

END MSC_GANTT_PKG;

 

/
