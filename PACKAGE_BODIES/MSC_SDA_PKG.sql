--------------------------------------------------------
--  DDL for Package Body MSC_SDA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_SDA_PKG" as
/*  $Header: MSCSDAPB.pls 120.48.12010000.8 2010/05/07 20:46:30 pabram ship $ */

   --constants
   c_field_seperator constant varchar2(5) := msc_sda_utils.c_field_seperator;
   c_record_seperator constant varchar2(5) := msc_sda_utils.c_record_seperator;
   c_bang_separator constant varchar2(20) := msc_sda_utils.c_bang_separator;
   c_comma_separator CONSTANT VARCHAR2(20) := msc_sda_utils.c_comma_separator;
   c_field_seperator_esc constant varchar2(10) := msc_sda_utils.c_field_seperator_esc;
   c_record_seperator_esc constant varchar2(10) := msc_sda_utils.c_record_seperator_esc;
   c_date_format constant varchar2(20) := msc_sda_utils.c_date_format;
   c_datetime_format constant varchar2(20) := msc_sda_utils.c_datetime_format;
   c_mbp_null_value constant number := msc_sda_utils.c_mbp_null_value;
   c_mbp_not_null_value constant number := msc_sda_utils.c_mbp_not_null_value;
   c_null_space constant varchar2(1):= msc_sda_utils.c_null_space;
   c_sys_yes constant integer := msc_sda_utils.c_sys_yes;
   c_sys_no constant integer := msc_sda_utils.c_sys_no;


   c_field_tech_org constant integer := 2;

   --item part condition id and values from msc tables
   c_part_cond_id constant integer := msc_sda_utils.c_part_cond_id;
   c_part_good constant integer := msc_sda_utils.c_part_good;
   c_part_bad constant integer := msc_sda_utils.c_part_bad;

   -- relationship type values in msc_item_substitutes table
   c_mis_substitute_type constant number := msc_sda_utils.c_mis_substitute_type;
   c_mis_supersession_type constant number := msc_sda_utils.c_mis_supersession_type;
   c_mis_repair_to_type constant number := msc_sda_utils.c_mis_repair_to_type;
   c_mis_service_type constant number := msc_sda_utils.c_mis_service_type;


   --forms tokens
   c_sdview_rowtypes constant varchar2(80) := msc_sda_utils.c_sdview_rowtypes;
   c_fcstview_rowtypes constant varchar2(80) := msc_sda_utils.c_fcstview_rowtypes;
   c_histview_rowtypes constant varchar2(80) := msc_sda_utils.c_histview_rowtypes;
   c_sdview_prefset_data constant varchar2(80) := msc_sda_utils.c_sdview_prefset_data;
   c_sdview_nls_messages constant varchar2(80) := msc_sda_utils.c_sdview_nls_messages;

   c_sdview_comments_data constant varchar2(80) := msc_sda_utils.c_sdview_comments_data;
   c_sdview_comments_data_ref constant varchar2(80) := msc_sda_utils.c_sdview_comments_data_ref;
   c_sdview_items_data constant varchar2(80) := msc_sda_utils.c_sdview_items_data;
   c_sdview_excp_data constant varchar2(80) := msc_sda_utils.c_sdview_excp_data;

   c_sdview_bucket_data constant varchar2(80) := msc_sda_utils.c_sdview_bucket_data;
   c_sdview_week_data constant varchar2(80) := msc_sda_utils.c_sdview_week_data;
   c_sdview_period_data constant varchar2(80) := msc_sda_utils.c_sdview_period_data;
   c_sdview_rheader_data constant varchar2(80) := msc_sda_utils.c_sdview_rheader_data;
   c_sdview_data constant varchar2(80) := msc_sda_utils.c_sdview_data;

   c_fcstview_bucket_data constant varchar2(80) := msc_sda_utils.c_fcstview_bucket_data;
   c_fcstview_week_data constant varchar2(80) := msc_sda_utils.c_fcstview_week_data;
   c_fcstview_period_data constant varchar2(80) := msc_sda_utils.c_fcstview_period_data;
   c_fcstview_rheader_data constant varchar2(80) := msc_sda_utils.c_fcstview_rheader_data;
   c_fcstview_data constant varchar2(80) := msc_sda_utils.c_fcstview_data;
   c_fcstview_addl_data constant varchar2(80) := msc_sda_utils.c_fcstview_addl_data;

   c_histview_bucket_data constant varchar2(80) := msc_sda_utils.c_histview_bucket_data;
   c_histview_rheader_data constant varchar2(80) := msc_sda_utils.c_histview_rheader_data;
   c_histview_data constant varchar2(80) := msc_sda_utils.c_histview_data;

   c_sdview_items_messages constant varchar2(80) := msc_sda_utils.c_sdview_items_messages;
   c_sdview_comments_messages constant varchar2(80) := msc_sda_utils.c_sdview_comments_messages;
   c_sdview_excp_messages constant varchar2(80) := msc_sda_utils.c_sdview_excp_messages;

   --msc_demands table will be populated with following values for global region data
   c_global_reg_id constant number := -1;
   c_global_inst_id constant number := -1;
   c_global_org_id constant number := -1;

   c_sda_save_item_folder  constant varchar2(50) := msc_sda_utils.c_sda_save_item_folder;
   c_sda_save_settings  constant varchar2(50) := msc_sda_utils.c_sda_save_settings;

   --calendar types to show
   c_owning_org_cal constant number := 1;
   c_profile_cal constant number := 2;

  --plan bucket type
   c_day_bucket constant number := 1;
   c_week_bucket constant number := 2;
   c_period_bucket constant number := 3;

   --constants for supply or demand
   c_supply_type constant number := 1;
   c_demand_type constant number := 2;

   --constants for view type
   c_sdview constant number := 1;
   c_fcstview constant number := 2;
   c_histview constant number := 3;

   --constants p_region_type
   c_reg_list_view constant number := msc_sda_utils.c_reg_list_view;
   c_reg_view constant number := msc_sda_utils.c_reg_view;

   --constants p_org_type
   c_org_list_view constant number := msc_sda_utils.c_org_list_view;
   c_org_view constant number := msc_sda_utils.c_org_view;

   --constants p_item_view_type
   c_item_view constant number := msc_sda_utils.c_item_view;
   c_prime_view constant number := msc_sda_utils.c_prime_view;
   c_supersession_view constant number := msc_sda_utils.c_supersession_view;

   --constants for node type
   c_region_node constant number := 1;
   c_org_node constant number := 2;
   c_item_node constant number := 3;
   c_regionlist_node constant number := 4;
   c_orglist_node constant number := 5;
   c_itemlist_node constant number := 6;
   c_all_regs_node constant number := 7;
   c_all_orgs_node constant number := 8;

   --constant for regions
   c_all_region_type constant number := msc_sda_utils.c_all_region_type;
   c_all_org_type constant number := msc_sda_utils.c_all_org_type;
   c_global_reg_type constant number := msc_sda_utils.c_global_reg_type;
   c_local_reg_type constant number := msc_sda_utils.c_local_reg_type;

   c_global_reg_type_text varchar2(300) := msc_sda_utils.c_global_reg_type_text;
   c_local_reg_type_text varchar2(300) := msc_sda_utils.c_local_reg_type_text;
   c_all_region_type_text varchar2(300) := msc_sda_utils.c_all_region_type_text;
   c_all_org_type_text varchar2(300) := msc_sda_utils.c_all_org_type_text;

   --constants for p_souce_type
   c_msc_supplies constant number := 1;
   c_msc_demands constant number := 2;

   --constants for p_type_flag
   c_row_type_flag constant number := 1;
   c_offset_flag constant number := 2;

   --constants misc
   c_first_row_index constant number := 1;
   c_dflt_groupby_num constant number := null;
   c_dflt_groupby_char constant varchar2(10) := null;

   --constants row-types count
   c_sd_total_row_types constant number := msc_sda_utils.c_sd_total_row_types;
   c_fcst_total_row_types constant number := msc_sda_utils.c_fcst_total_row_types;
   c_hist_total_row_types constant number := msc_sda_utils.c_hist_total_row_types;

   --constants node_state
   c_expanded_state constant number := 1;
   c_collapsed_state constant number := 2;
   c_nodrill_state constant number := 3;

   c_discard constant integer := -99; --supplies which will not be shown
   c_row_discard constant integer := -99; --supplies which will not be shown

   --
   -- supply/demand view begins
   --
   --supply order types
   c_sup_intrnst_shpmt constant integer := 11; -- Intransit shipment
   c_sup_intrnst_rec constant integer := 12; -- Intransit receipt
   c_sup_onhand constant integer := 18; -- On Hand
   c_sup_plnd_inbnd_ship constant integer := 51; --Planned Inbound shipment
   c_sup_new_buy_po constant integer := 1; --New Buy Purchase Order
   c_sup_new_buy_po_req constant integer := 2; --New Buy Purchase Requisitions
   c_sup_intrnl_rpr_ordr constant integer := 73; --Internal Repair Order
   c_sup_xtrnl_rpr_ordr constant integer := 74; --External Repair Order
   c_sup_rpr_wo constant integer := 75; --Repair Work Order-Internal Depot Org
   c_sup_plnd_new_buy_ordr constant integer := 76; --Planned New Buy Order
   c_sup_plnd_intrnl_rpr_ordr constant integer := 77; --Planned Internal Repair Order
   c_sup_plnd_xtrnl_rpr_ordr constant integer := 78; --Planned External Repair Order
   c_sup_plnd_rpr_wo constant integer := 79; --Planned Repair Work Order
   c_sup_rpr_wo_ext_rep_supp constant integer := 86; --Repair Work Order-External Repair Supplier
   c_sup_ext_rep_req constant integer := 87; --External Repair Requisition

   c_sup_defc_onhand constant integer := 18; --defective on hand (bad)
   c_sup_defc_returns constant integer := 81; --defective returns (bad)
				--changed the order type from 32 to 81, bug 6501264
				--will show returns forecast in returns row type
   c_sup_defc_inbnd_ship constant integer := c_sup_new_buy_po_req; --Defective Inbound shipment (bad)
   c_sup_defc_plnd_inbnd_ship constant integer := 51; --planned Defective Inbound shipment (bad)
   c_sup_defc_transit constant integer := 11; --Defectives in-transit (bad)
   c_sup_defc_rec constant integer := 12; --Defective in-receiving (bad)

   --supply rowtypes
   c_srow_intrnst_shpmt constant integer := 10;
   c_srow_intrnst_rec constant integer := 20;
   c_srow_onhand constant integer := 30;
   c_srow_plnd_inbnd_ship constant integer := 40;
   c_srow_new_buy_po constant integer := 50;
   c_srow_new_buy_po_req constant integer := 60;
   c_srow_intrnl_rpr_ordr constant integer := 70;
   c_srow_xtrnl_rpr_ordr constant integer := 80;
   c_srow_rpr_wo constant integer := 90;
   c_srow_plnd_new_buy_ordr constant integer := 100;
   c_srow_plnd_intrnl_rpr_ordr constant integer := 110;
   c_srow_plnd_xtrnl_rpr_ordr constant integer := 120;
   c_srow_plnd_rpr_wo constant integer := 130;
   c_srow_inbnd_ship constant integer := 200;

   c_srow_defc_onhand constant integer := 140;
   c_srow_defc_returns constant integer := 150;
   c_srow_defc_inbnd_ship constant integer := 160;
   c_srow_defc_plnd_inbnd_ship constant integer := 170;
   c_srow_defc_transit constant integer := 180;
   c_srow_defc_rec constant integer := 190;

   --demand order types
   c_dmd_pod constant integer := 1; -- Planned order demand
   c_dmd_so_mds constant integer := 6; -- Sales order MDS
   c_dmd_manual_mds constant integer := 8; -- Manual MDS
   c_dmd_mps constant integer := 12; -- MPS demand
   c_dmd_fcst constant integer := 29; -- Forecast
   c_dmd_so constant integer := 30; -- Sales Orders
   c_dmd_defc_iso constant integer := 30; --ISO, bad, defective outbound shipment
   c_dmd_defc_pod constant integer := 1; --Planned order demand, bad
   c_dmd_defc_part_dmd constant integer := 77; --Defective Part demand, bad
   c_dmd_defc_plnd_part_dmd constant integer := 78; --Defective planned Part demand, bad

   --demand rowtypes
   c_drow_fcst constant integer := 500;
   c_drow_so constant integer := 510;
   c_drow_iso_field_org constant integer := 520;
   c_drow_iso constant integer := 540;
   c_drow_pod constant integer := 550;
   c_drow_other_dmd constant integer := 570;
   c_drow_defc_iso constant integer := 580;
   c_drow_defc_pod integer := 590;
   c_drow_defc_part_dmd integer := 600;

   --misc order types
   c_max_level constant integer := 1000; --max level
   c_ss_supply constant integer:= 1010;  --Safety Stock (Days of Supply)
   c_ss_level constant integer:= 1020;  --Safety Stock Level
   c_target_level constant integer:= 1030;  --Target Level

   -- pivot row types
   c_row_net_fcst constant integer:= 1;
	-- Net Forecast, demand-order-types 29
   c_row_so constant integer:= 2;
	--Sales Orders, demand-order-types 6,30
   c_row_iso_field_org constant integer:= 3;
	--Internal Sales Order (Field Org), demand-order-types 6,30
   c_row_indepndt_dmd constant integer:= 4;
	--Independent Demand, sum of pivot-row-types 1,2,3
   c_row_iso constant integer:= 5;
	--Internal Sales Order, demand-order-types  6,30
   c_row_pod constant integer:= 6;
	--Planned Outbound shipment, (planned order demand) demand-order-types 1
   c_row_dependnt_dmd constant integer:= 7;
	--Dependent Demand, sum of pivot-row-types 5,6
   c_row_other_dmd constant integer:= 8;
	--Other Demand, demand-order-types 8,12
   c_row_total_dmd constant integer:= 9;
	--Total Demand, sum of pivot-row-types 4,7,8
   c_row_onhand constant integer:= 10;
	--Beginning On-hand, supply-order-types 18(good)
   c_row_transit constant integer:= 11;
	--In - Transit, supply-order-types 11(good)
   c_row_receiving constant integer:= 12;
	--In - Receiving, supply-order-types 12(good)
   c_row_new_buy_po constant integer:= 13;
	--New Buy Purchase Order, supply-order-types 71(good)
   c_row_new_buy_po_req constant integer:= 14;
	--New Buy Purchase Requisitions, supply-order-types 72(good)
   c_row_intrnl_rpr_ordr constant integer:= 15;
	--Internal Repair Order, supply-order-types 73(good)
   c_row_xtrnl_rpr_ordr constant integer:= 16;
	--External Repair Order, supply-order-types 74(good)
   c_row_inbnd_ship constant integer:= 17;
	--Inbound shipment, supply-order-types 11(good)
	--same as c_row_transit
	-- pabram 05072010 will contain internal reqs
   c_row_rpr_wo constant integer:= 18;
	--Repair Work Order, supply-order-types 75(good)
   c_row_plnd_new_buy_ordr constant integer:= 19;
	--Planned New Buy Order, supply-order-types 76(good)
   c_row_plnd_intrnl_rpr_ordr constant integer:= 20;
	--Planned Internal Repair Order, supply-order-types 77(good)
   c_row_plnd_xtrnl_rpr_ordr constant integer:= 21;
	--Planned External Repair Order, supply-order-types 78(good)
   c_row_plnd_inbnd_ship constant integer:= 22;
	--Planned Inbound shipment, supply-order-types 51(good)
   c_row_plnd_rpr_wo constant integer:= 23;
	--Planned Repair Work Order, supply-order-types 79(good)
   c_row_plnd_warr_ordr constant integer:= 24;
	--Planned Warranty order, ?pabram....????????
   c_row_total_supply constant integer:= 25;
	--Total Supply, sum of pivot-row-types 11 thru 24
   c_row_ss_supply constant integer:= 26;
	--Safety Stock (Days of Supply), msc_safety_stocks.achieved_days_of_supply
   --c_row_total_uncons_dmd constant integer:= 27;
	--Total unconstrained demand --out of design
   c_row_ss_level constant integer:= 28;
	--Safety Stock Level, msc_safety_stocks.achieved_service_level
   c_row_target_level constant integer:= 29;
	--Target Level, msc_safety_stocks.target_service_level
   c_row_max_level constant integer:= 30;
	--Maximum Level, msc_inventory_levels.max_quantity
   c_row_pab constant integer:= 31;
	--Projected Available Balance,
	--pivot-row-types c_row_pab(i-1) + c_row_total_supply(i) - c_row_total_dmd(i)
   c_row_poh constant integer:= 32;
	--Projected On Hand,
	--pivot-row-types c_row_poh(i-1) + c_row_onhand(i)+ supply-order-type 13 - c_row_total_dmd(i)
	--pabram..need to verify
   c_row_defc_iso constant integer:= 33;
	--Defective Outbound shipment, Defective ISO, demand-order-types 54(bad)
   c_row_plnd_defc_pod constant integer:= 34;
	--Planned Defective outbound shipment, (planned order demand) demand-order-types 1(bad)
   c_row_defc_part_dmd constant integer:= 35;
	--Defective Part demand, demand-order-types 77(bad)
   c_row_total_defc_part_dmd constant integer:= 36;
	--Total Defective Part demand, sum of pivot-row-types c_row_defc_part_dmd
	--pabram..need to check, this is a duplicate
   c_row_defc_onhand constant integer:= 37;
	--Defective On-hand, supply-order-types 18(bad)
   c_row_returns constant integer:= 38;
	--Returns, supply-order-types 32(bad)
   c_row_defc_inbnd_ship constant integer:= 39;
	--Defective Inbound shipment, supply-order-types 11(bad)
   c_row_defc_plnd_inbnd_ship constant integer:= 40;
	--Planned defective Inbound shipment, supply-order-types 51(bad)
   c_row_defc_transit constant integer:= 41;
	--Defectives in transit, supply-order-types 11(bad)
   c_row_defc_rec constant integer:= 42;
	--Defectives in receiving, supply-order-types 12(bad)
   c_row_total_defc_supply constant integer:= 43;
	--Total Defective Supply, pivot-row-types sum of 38 thru 42
   c_row_defc_pab constant integer:= 44;
	--Projected Available Balance (Defective)
	--pivot-row-types c_row_defc_pab(i-1) + c_row_total_defc_supply(i) - ( 33,34,35,36)
   c_row_ss_qty constant integer:= 45;
	--safety stock qty

--
-- supply/demand view ends
--

--
-- forecast view begins -- pabram need to work on this
--

  --demand order types
  c_dmd2_orig_fcst constant integer := 29; -- original forecast
  c_dmd2_net_fcst constant integer := 29; -- net forecast
  c_dmd2_manual_fcst constant integer := 63; -- manual fcst
  c_dmd2_dmd_schd constant integer := 29; -- demand schedule
  c_dmd2_bestfit_fcst constant integer := 65; -- bestfit forecast
  c_dmd2_consm_qty constant integer := -1; -- consumed_qty
  c_dmd2_overconsm_qty constant integer := -2; -- over consumed_qty
  c_dmd2_popu_fcst constant integer := 29; -- population based forecast
  c_dmd2_usage_fcst constant integer := 29; -- usage forecast

  c_sup2_rtns_fcst constant integer := 81; -- Returns Forecast
  c_sup2_rtns_manual_fcst constant integer := 83; -- Returns Manual Forecast
  c_sup2_rtns_dmd_schd constant integer := 82; -- Returns Demand Schedule
  c_sup2_rtns_bestfit_fcst constant integer := 84; -- Returns Best Fit Forecast

  --demand rowtypes
  c_drow2_net_fcst constant integer := 500;
  c_drow2_manual_fcst constant integer := 510;
  c_drow2_dmd_schd constant integer := 520;
  c_drow2_bestfit_fcst constant integer := 530;
  c_drow2_consm_qty constant integer := 540;
  c_drow2_overconsm_qty constant integer := 550;
  c_drow2_popu_fcst constant integer := 560;
  c_drow2_usage_fcst constant integer := 570;

  c_drow2_rtns_fcst constant integer := 600;
  c_drow2_rtns_manual_fcst constant integer := 610;
  c_drow2_rtns_dmd_schd constant integer := 620;
  c_drow2_rtns_bestfit_fcst constant integer := 630;


  -- pivot row types
  c_row2_total_fcst constant integer:= 1;
	-- nvl(manual forecast, net forecast + demand schedule)
  c_row2_orig_fcst constant integer:= 2;
	-- msc_demands --old_using_requirement_quantity, old_demand_quantity, original_quantity //pabram..need to check
  c_row2_consumed_fcst constant integer:= 3;
	-- msc_forecast_updates.consumed_qty //pabram..need to check
  c_row2_net_fcst constant integer:= 4;
	-- msc_demands origination_type 29  //pabram..need to check
  c_row2_over_consmptn constant integer:= 5;
	-- msc_forecast_updates.overconsumption_qty  //pabram..need to check
  c_row2_manual_fcst constant integer:= 6;
	-- msc_demands origination_type 63 //pabram..need to check
  c_row2_dmd_schd constant integer:= 7;
	-- msc_demands origination_type 64 //pabram..need to check
  c_row2_bestfit_fcst constant integer:= 8;
	-- msc_demands origination_type 65 //pabram..need to check
  c_row2_total_ret_fcst constant integer:= 9;
	-- nvl(returns manual forecast, returns fcst + returns dmd schedule)  //pabram..need to check
  c_row2_ret_fcst constant integer:= 10;
	-- msc_supplies order type 81
  c_row2_ret_dmd_schd constant integer:= 11;
	-- msc_supplies order type 82
  c_row2_ret_manual_fcst constant integer:= 12;
	-- msc_supplies order type 83
  c_row2_ret_bestfit_fcst constant integer:= 13;
	-- msc_supplies order type 84
  c_row2_usage_fcst constant integer:= 14;
	-- Usage Forecast
  c_row2_popultn_fcst constant integer:= 15;
	-- Population based Forecast
  c_row2_type_16 constant integer:= 16;
         -- dummy
  c_row2_type_17 constant integer:= 17;
         -- dummy 2
--
-- forecast view ends
--


--
-- history view begins -- pabram need to work on this
--
  c_dmd_hist constant integer := 67; -- Demand History
  c_returns_hist constant integer := 66; -- Returns History

  c_drow_dmd_hist constant integer := 20;
  c_drow_returns_hist constant integer := 10;

  -- pivot row types
  c_row_dmd_hist constant integer:= 1;
	-- demand history  ,msc_demands
  c_row_returns_hist constant integer:= 2;
	-- returns history ,msc_supplies
--
-- history view ends
--

-- global
g_sd_query_id number;
g_fcst_query_id number;
g_hist_query_id number;
g_hist_cal_query_id number;
g_view_type number;
g_region_query_id number;
g_chain_query_id number;
g_org_query_id number;
g_plan_bkts_query_id number;
g_region_type number;
g_region_list varchar2(250);
g_region_list_name varchar2(250);
g_org_type number;
g_org_list varchar2(250);
g_item_list number;
g_item_list_name varchar2(250);
g_item_view_type number;
g_row_index number := 1;
g_next_rowset_index number := 1;
g_fcst_bkt_mfq_id number;

g_md_dup_rows_qid number;
g_ms_dup_rows_qid number;

g_plan_id number;
g_plan_type number;
g_plan_name varchar2(80);
g_owning_inst_id number;
g_owning_org_id number;
g_plan_start_date date;
g_plan_end_date  date;

g_day_buckets number;
g_week_buckets number;
g_period_buckets number;
g_week_start_date date;
g_period_start_date date;

g_bkt_start_date msc_sda_utils.date_arr;
g_bkt_end_date msc_sda_utils.date_arr;
g_bkt_type msc_sda_utils.number_arr;
g_week_start_dates msc_sda_utils.date_arr;
g_period_start_dates msc_sda_utils.date_arr;

g_num_of_buckets number;
g_sd_num_of_buckets number;
g_fcst_num_of_buckets number;
g_hist_num_of_buckets number;

type bkttype_data is table of varchar2(80) index by binary_integer;
type rowtype_data is table of bkttype_data index by binary_integer;

g_data_grid rowtype_data;

--preferences
g_pref_id number;
g_pref_hist_start_date date;

--------
-------- cursors begin
--------
  cursor c_row_values_cur (p_query_id number, p_row_index number, p_next_rowset_index number) is
   select
    row_index,
    region_list_id,
    region_list,
    region_list_state,
    region_id,
    region_code,
    org_list_id,
    org_list,
    org_list_state,
    inst_id,
    org_id,
    org_code,
    top_item_id,
    top_item_name,
    top_item_name_state,
    item_id,
    item_name
   from msc_analysis_query maq
   where maq.query_id = p_query_id
     and ( (p_row_index is not null and maq.row_index = p_row_index) or
             (p_next_rowset_index is not null and maq.parent_row_index = p_next_rowset_index) )
    order by row_index;

   cursor c_next_rowset_index_cur (p_query_id number) is
   select nvl(max(parent_row_index),0)
   from msc_analysis_query
   where query_id = p_query_id;

    cursor c_child_row_count (p_query_id number, p_next_rowset_index number)  is
    select count(*)
    from msc_analysis_query
    where query_id = p_query_id
      and parent_row_index = p_next_rowset_index;
--------
-------- cursors end...
--------

  procedure setUserPrefInfo is
  begin
    --pabram..need to change this later based on user pref code/values
    g_pref_id := -1;
    g_pref_hist_start_date := sysdate - 700;
  end setUserPrefInfo;

  procedure setPlanInfo is
    cursor c_plan_info_cur is
    select
      compile_designator,
      sr_instance_id,
      organization_id,
      decode(plan_id, -1, sysdate, trunc(curr_start_date)) curr_start_date,
      decode(plan_id, -1, sysdate+365, trunc(curr_cutoff_date)) curr_cutoff_date
    from msc_plans
    where plan_id = g_plan_id;

    cursor c_plan_bucket_info_cur is
    select sum(decode(bucket_type, 1, 1,0)) day_buckets,
      sum(decode(bucket_type, 2, 1,0)) week_buckets,
      sum(decode(bucket_type, 3, 1,0)) period_buckets,
      min(decode(bucket_type, 2, bkt_start_date)) week_start_date,
      min(decode(bucket_type, 3, bkt_start_date)) pr_start_date
    from msc_plan_buckets
    where plan_id = g_plan_id
      and  sr_instance_id = g_owning_inst_id
      and  organization_id = g_owning_org_id;

  cursor c_plan_bucket_dates_cur is
  select bkt_start_date,
    bkt_end_date,
    bucket_type
  from msc_plan_buckets
  where plan_id = g_plan_id
     and  sr_instance_id = g_owning_inst_id
     and  organization_id = g_owning_org_id
  union all
  select trunc(curr_start_date)-1,
    trunc(curr_start_date)-1,
    -99
  from msc_plans
  where plan_id = g_plan_id
  union all
  select trunc(curr_cutoff_date)+1,
    trunc(curr_cutoff_date)+1,
    -99
  from msc_plans
  where plan_id = g_plan_id
  order by 1;

  cursor c_week_start_dates_cur(p_cal_type number, p_cal_code varchar2) is
  select week_start_date
  from msc_trading_partners mtp,
	msc_cal_week_start_dates wsd
  where p_cal_type = c_owning_org_cal
    and mtp.sr_tp_id = g_owning_org_id
    and mtp.sr_instance_id = g_owning_inst_id
    and mtp.partner_type = 3
    and mtp.calendar_code = wsd.calendar_code
    and mtp.calendar_exception_set_id = wsd.exception_set_id
    and mtp.sr_instance_id = wsd.sr_instance_id
    and wsd.week_start_date >= g_plan_start_date
    and wsd.week_start_date <= g_plan_end_date
  union all
  select mcwsd.week_start_date
  from msc_cal_week_start_dates mcwsd
  where p_cal_type =  c_profile_cal
    and mcwsd.calendar_code = p_cal_code
    and mcwsd.week_start_date >= g_plan_start_date
    and mcwsd.week_start_date <= g_plan_end_date
  order by 1;

  cursor c_period_start_dates_cur(p_cal_type number, p_cal_code varchar2) is
  select mpsd.period_start_date
  from  msc_trading_partners mtp,
    msc_period_start_dates mpsd
  where p_cal_type = c_owning_org_cal
    and mpsd.calendar_code = mtp.calendar_code
    and mpsd.sr_instance_id = mtp.sr_instance_id
    and mpsd.exception_set_id = mtp.calendar_exception_set_id
    and mtp.sr_instance_id = g_owning_inst_id
    and mtp.sr_tp_id = g_owning_org_id
    and mtp.partner_type =3
    and mpsd.period_start_date >= g_plan_start_date
    and mpsd.period_start_date <= g_plan_end_date
  union all
  select mpsd.period_start_date
  from  msc_period_start_dates mpsd
  where p_cal_type =  c_profile_cal
    and mpsd.calendar_code = p_cal_code
    and mpsd.period_start_date >= g_plan_start_date
    and mpsd.period_start_date <= g_plan_end_date
  order by 1;

  l_cal_code varchar2(250) := fnd_profile.value('MSC_BKT_REFERENCE_CALENDAR');
  l_cal_type number;

  l_date1 date;
  l_date2 date;

  begin
  if (g_view_type = c_sdview) then
    l_cal_type := c_owning_org_cal;
  else
    if (l_cal_code is not null) then
      l_cal_type := c_profile_cal;
    else
      l_cal_type := c_owning_org_cal;
    end if;
  end if;

  --get plan info
  open c_plan_info_cur;
  fetch c_plan_info_cur into g_plan_name, g_owning_inst_id, g_owning_org_id,
    g_plan_start_date, g_plan_end_date;
  close c_plan_info_cur;

  --get plan buckets info
  open c_plan_bucket_info_cur;
  fetch c_plan_bucket_info_cur into g_day_buckets, g_week_buckets,
    g_period_buckets, g_week_start_date, g_period_start_date;
  close c_plan_bucket_info_cur;

  -- 2 is to store past and future values which are not part of current plan buckets
  g_num_of_buckets := g_day_buckets + g_week_buckets + g_period_buckets + 1;

  msc_sda_utils.println('setPlanInfo buckets - day week period total '||
    g_day_buckets ||'-'|| g_week_buckets ||'-'|| g_period_buckets ||'-'|| g_num_of_buckets);

  --get plan bucket dates
  open c_plan_bucket_dates_cur;
  fetch c_plan_bucket_dates_cur bulk collect
    into g_bkt_start_date, g_bkt_end_date, g_bkt_type;
  close c_plan_bucket_dates_cur;

  --populate plan buckets into mfq
  g_plan_bkts_query_id := msc_sda_utils.getNewFormQueryId;
  for bktIndex in 1..g_bkt_type.count
  loop
    if ( g_bkt_type(bktIndex) = -99 and trunc(g_bkt_end_date(bktIndex)) = trunc(g_plan_start_date-1) ) then
      l_date1 := g_plan_start_date - 1000; --approx 3 years from plan start
      l_date2 := g_plan_start_date -1;
    elsif ( g_bkt_type(bktIndex) = -99 and trunc(g_bkt_start_date(bktIndex)) = trunc(g_plan_end_date+1) ) then
      l_date1 := g_plan_end_date + 1;
      l_date2 := g_plan_end_date + 1000; --approx 3 years from plan end;
    else
      l_date1 := g_bkt_start_date(bktIndex);
      l_date2 := g_bkt_end_date(bktIndex);
    end if;
    insert into msc_form_query (query_id, last_update_date, last_updated_by, creation_date, created_by, number1, date1, date2 )
    values (g_plan_bkts_query_id , sysdate, -1, sysdate, -1, g_bkt_type(bktIndex), l_date1, l_date2);
  end loop;

   --get week dates
   open c_week_start_dates_cur(l_cal_type, l_cal_code);
   fetch c_week_start_dates_cur bulk collect into g_week_start_dates;
   close c_week_start_dates_cur;

   --get period dates
   open c_period_start_dates_cur(l_cal_type, l_cal_code);
   fetch c_period_start_dates_cur bulk collect into g_period_start_dates;
   close c_period_start_dates_cur;

  end setPlanInfo;

  function isRowChanged(p_row_index number, p_prev_row_index number) return boolean is
    l_flag boolean := true;
  begin
     if (p_row_index = p_prev_row_index ) then
       l_flag := false;
     end if;
     return l_flag;
  end isRowChanged;

  function getFcstStartDate(p_bkt_start_date date, p_plan_start_date date, p_plan_end_date date, p_sd_date date) return date is
  begin
    if ( trunc(p_sd_date) < trunc(p_plan_start_date) ) then
      return  trunc(p_plan_start_date)-1;
    elsif ( trunc(p_sd_date) > trunc(p_plan_end_date) ) then
      return  trunc(p_plan_end_date)+1;
    end if;
    return trunc(p_bkt_start_date);
  end getFcstStartDate;

  function getFcstEndDate(p_bkt_end_date date, p_plan_start_date date, p_plan_end_date date, p_sd_date date) return date is
  begin
    if ( trunc(p_sd_date) < trunc(p_plan_start_date) ) then
      return  trunc(p_plan_start_date)-1;
    elsif ( trunc(p_sd_date) > trunc(p_plan_end_date) ) then
      return  trunc(p_plan_end_date)+1;
    end if;
    return trunc(p_bkt_end_date);
  end getFcstEndDate;

  function getFcstRowTypeOffset(p_supply_demand_flag number, p_order_type number,
    p_item_type_id number, p_item_type_value number, p_type_flag number,
    p_inst_id number, p_org_id number, p_region_id number, p_schedule_designator_id number, p_item_id number) return number is
      l_row_type number;
      l_offset number;
    cursor c_usage_based_fcst_cur is
    select count(*)
    from msc_system_items msi,
       msc_forecast_rules mfr
    where msi.plan_id = g_plan_id
     and msi.sr_instance_id = p_inst_id
     and msi.organization_id = p_org_id
     and msi.inventory_item_id = p_item_id
     and msi.forecast_rule_for_demands = mfr.forecast_rule_id
     and nvl(mfr.enable_usage_ship_fcst, 2) = 1
     and nvl(mfr.history_basis,-1) in  (3,4);
   l_usage_type number;
  begin
    if (p_supply_demand_flag = c_demand_type) then --{
      if (p_order_type = c_dmd2_dmd_schd and p_schedule_designator_id is not null) then  --{
        l_row_type := c_drow2_dmd_schd;
        l_offset := c_row2_dmd_schd;
      elsif (p_order_type = c_dmd2_manual_fcst ) then
        l_row_type := c_drow2_manual_fcst;
        l_offset := c_row2_manual_fcst;
      elsif (p_order_type = c_dmd2_net_fcst) then
        if (p_region_id is not null) then
          l_row_type := c_drow2_usage_fcst;
          l_offset := c_row2_usage_fcst;
        elsif (p_region_id is null) then
	  open c_usage_based_fcst_cur;
	  fetch c_usage_based_fcst_cur into l_usage_type;
	  close c_usage_based_fcst_cur;
	  if (l_usage_type = 0) then
            l_row_type := c_drow2_popu_fcst;
            l_offset := c_row2_popultn_fcst;
	  else
            l_row_type := c_drow2_usage_fcst;
            l_offset := c_row2_usage_fcst;
	  end if;
        else
          l_row_type := c_drow2_net_fcst;
          l_offset := c_row2_net_fcst;
	end if;
      elsif (p_order_type = c_dmd2_bestfit_fcst) then
        --removed from the row type
        l_row_type := c_drow2_bestfit_fcst;
        l_offset := c_row2_bestfit_fcst;
      else
        l_row_type := c_discard;
        l_offset := c_discard;
      end if;  --}
    end if;  --}

    if (p_supply_demand_flag = c_supply_type) then --{
      if (p_order_type = c_sup2_rtns_fcst) then  --{
        l_row_type := c_drow2_rtns_fcst;
        l_offset := c_row2_ret_fcst;
      elsif (p_order_type = c_sup2_rtns_manual_fcst) then  --{
        l_row_type := c_drow2_rtns_manual_fcst;
        l_offset := c_row2_ret_manual_fcst;
      elsif (p_order_type = c_sup2_rtns_dmd_schd) then  --{
        l_row_type := c_drow2_rtns_dmd_schd;
        l_offset := c_row2_ret_dmd_schd;
      elsif (p_order_type = c_sup2_rtns_bestfit_fcst) then  --{
        l_row_type := c_drow2_rtns_bestfit_fcst;
        l_offset := c_row2_ret_bestfit_fcst;
      else
        l_row_type := c_discard;
        l_offset := c_discard;
      end if;  --}
    end if;  --}

    if (p_type_flag = c_row_type_flag) then
      return l_row_type;
    else
      return l_offset;
    end if;
  end getFcstRowTypeOffset;

  function getHistStartDate(p_bkt_start_date date, p_plan_start_date date, p_plan_end_date date, p_sd_date date) return date is
  begin
    if ( trunc(p_sd_date) < trunc(p_plan_start_date) ) then
      return  trunc(p_plan_start_date)-1;
    elsif ( trunc(p_sd_date) > trunc(p_plan_end_date) ) then
      return  trunc(p_plan_end_date)+1;
    end if;
    return trunc(p_bkt_start_date);
  end getHistStartDate;

  function getHistEndDate(p_bkt_end_date date, p_plan_start_date date, p_plan_end_date date, p_sd_date date) return date is
  begin
    if ( trunc(p_sd_date) < trunc(p_plan_start_date) ) then
      return  trunc(p_plan_start_date)-1;
    elsif ( trunc(p_sd_date) > trunc(p_plan_end_date) ) then
      return  trunc(p_plan_end_date)+1;
    end if;
    return trunc(p_bkt_end_date);
  end getHistEndDate;

  function getHistRowTypeOffset(p_order_type number, p_item_type_id number, p_item_type_value number,
    p_type_flag number) return number is
      l_row_type number;
      l_offset number;
  begin
      if (p_order_type = c_returns_hist) then  --{
        l_row_type := c_drow_returns_hist;
        l_offset := c_row_returns_hist;
      elsif (p_order_type = c_dmd_hist) then  --{
        l_row_type := c_drow_dmd_hist;
        l_offset := c_row_dmd_hist;
      else
        l_row_type := c_discard;
        l_offset := c_discard;
      end if;  --}
      if (p_type_flag = c_row_type_flag) then
        return l_row_type;
      else
        return l_offset;
      end if;
  end getHistRowTypeOffset;

  function getSDStartDate(p_bkt_start_date date, p_plan_start_date date, p_plan_end_date date, p_sd_date date) return date is
  begin
    if ( trunc(p_sd_date) < trunc(p_plan_start_date) ) then
      return  trunc(p_plan_start_date)-1;
    elsif ( trunc(p_sd_date) > trunc(p_plan_end_date) ) then
      return  trunc(p_plan_end_date)+1;
    end if;
    return trunc(p_bkt_start_date);
  end getSDStartDate;

  function getSDEndDate(p_bkt_end_date date, p_plan_start_date date, p_plan_end_date date, p_sd_date date) return date is
  begin
    if ( trunc(p_sd_date) < trunc(p_plan_start_date) ) then
      return  trunc(p_plan_start_date)-1;
    elsif ( trunc(p_sd_date) > trunc(p_plan_end_date) ) then
      return  trunc(p_plan_end_date)+1;
    end if;
    return trunc(p_bkt_end_date);
  end getSDEndDate;

  function getSupplyRowTypeOffset(p_order_type number, p_item_type_id number, p_item_type_value number,
    p_type_flag number, p_source_organization_id number) return number is
      l_row_type number;
      l_offset number;
  begin
      if (p_order_type = c_sup_onhand
        and nvl(p_item_type_id,c_part_cond_id)=c_part_cond_id and nvl(p_item_type_value,c_part_good)=c_part_good ) then  --{
        l_row_type := c_srow_onhand;
        l_offset := c_row_onhand;
      elsif (p_order_type = c_sup_intrnst_shpmt
        and nvl(p_item_type_id,c_part_cond_id)=c_part_cond_id and nvl(p_item_type_value,c_part_good)=c_part_good ) then
        l_row_type := c_srow_intrnst_shpmt;
        l_offset := c_row_transit;
      elsif (p_order_type = c_sup_intrnst_rec
        and nvl(p_item_type_id,c_part_cond_id)=c_part_cond_id and nvl(p_item_type_value,c_part_good)=c_part_good ) then
        l_row_type := c_srow_intrnst_rec;
        l_offset := c_row_receiving;
      elsif (p_order_type = c_sup_new_buy_po
        and nvl(p_item_type_id,c_part_cond_id)=c_part_cond_id and nvl(p_item_type_value,c_part_good)=c_part_good ) then
        l_row_type := c_srow_new_buy_po;
        l_offset := c_row_new_buy_po;
      elsif (p_order_type = c_sup_new_buy_po_req
        and nvl(p_item_type_id,c_part_cond_id)=c_part_cond_id and nvl(p_item_type_value,c_part_good) in (c_part_good, c_part_bad) ) then
	if (p_source_organization_id is null and nvl(p_item_type_value,c_part_good) = c_part_good ) then
          l_row_type := c_srow_new_buy_po_req;
          l_offset := c_row_new_buy_po_req;
        elsif (p_source_organization_id is not null and nvl(p_item_type_value,c_part_good) = c_part_good ) then
          l_row_type := c_srow_inbnd_ship;
          l_offset := c_row_inbnd_ship;
        --elsif (p_source_organization_id is null and nvl(p_item_type_value,c_part_good) = c_part_bad ) then
          --l_row_type := c_srow_defc_inbnd_ship;
          --l_offset := c_row_defc_inbnd_ship;
	  -- defective items will not have new buy purchase reqs
	elsif (p_source_organization_id is not null and nvl(p_item_type_value,c_part_good) = c_part_bad ) then
          l_row_type := c_srow_defc_inbnd_ship;
          l_offset := c_row_defc_inbnd_ship;
	else
          l_row_type := c_discard;
          l_offset := c_discard;
	end if;
      elsif (p_order_type in (c_sup_intrnl_rpr_ordr)
        and nvl(p_item_type_id,c_part_cond_id)=c_part_cond_id and nvl(p_item_type_value,c_part_good)=c_part_good ) then
        l_row_type := c_srow_intrnl_rpr_ordr;
        l_offset := c_row_intrnl_rpr_ordr;
      elsif (p_order_type in (c_sup_xtrnl_rpr_ordr, c_sup_ext_rep_req)
        and nvl(p_item_type_id,c_part_cond_id)=c_part_cond_id and nvl(p_item_type_value,c_part_good)=c_part_good ) then
        l_row_type := c_srow_xtrnl_rpr_ordr;
        l_offset := c_row_xtrnl_rpr_ordr;
      elsif (p_order_type in ( c_sup_rpr_wo, c_sup_rpr_wo_ext_rep_supp)
        and nvl(p_item_type_id,c_part_cond_id)=c_part_cond_id and nvl(p_item_type_value,c_part_good)=c_part_good ) then
        l_row_type := c_srow_rpr_wo;
        l_offset := c_row_rpr_wo;
      elsif (p_order_type = c_sup_plnd_new_buy_ordr
        and nvl(p_item_type_id,c_part_cond_id)=c_part_cond_id and nvl(p_item_type_value,c_part_good)=c_part_good ) then
        l_row_type := c_srow_plnd_new_buy_ordr;
        l_offset := c_row_plnd_new_buy_ordr;
      elsif (p_order_type = c_sup_plnd_intrnl_rpr_ordr
        and nvl(p_item_type_id,c_part_cond_id)=c_part_cond_id and nvl(p_item_type_value,c_part_good)=c_part_good ) then
        l_row_type := c_srow_plnd_intrnl_rpr_ordr;
        l_offset := c_row_plnd_intrnl_rpr_ordr;
      elsif (p_order_type = c_sup_plnd_xtrnl_rpr_ordr
        and nvl(p_item_type_id,c_part_cond_id)=c_part_cond_id and nvl(p_item_type_value,c_part_good)=c_part_good ) then
        l_row_type := c_srow_plnd_xtrnl_rpr_ordr;
        l_offset := c_row_plnd_xtrnl_rpr_ordr;
      elsif (p_order_type = c_sup_plnd_inbnd_ship
        and nvl(p_item_type_id,c_part_cond_id)=c_part_cond_id and nvl(p_item_type_value,c_part_good)=c_part_good ) then
        l_row_type := c_srow_plnd_inbnd_ship;
        l_offset := c_row_plnd_inbnd_ship;
      elsif (p_order_type = c_sup_plnd_rpr_wo
        and nvl(p_item_type_id,c_part_cond_id)=c_part_cond_id and nvl(p_item_type_value,c_part_good)=c_part_good ) then
        l_row_type := c_srow_plnd_rpr_wo;
        l_offset := c_row_plnd_rpr_wo;
      elsif (p_order_type = c_sup_defc_plnd_inbnd_ship
        and nvl(p_item_type_id,c_part_cond_id) = c_part_cond_id and p_item_type_value = c_part_bad) then
        l_row_type := c_srow_defc_plnd_inbnd_ship;
        l_offset := c_row_defc_plnd_inbnd_ship;
      elsif (p_order_type = c_sup_defc_onhand
        and nvl(p_item_type_id,c_part_cond_id) = c_part_cond_id and p_item_type_value = c_part_bad) then
        l_row_type := c_srow_defc_onhand;
        l_offset := c_row_defc_onhand;
      elsif (p_order_type = c_sup_defc_returns
        and nvl(p_item_type_id,c_part_cond_id) = c_part_cond_id and p_item_type_value = c_part_bad) then
        l_row_type := c_srow_defc_returns;
        l_offset := c_row_returns;
      --elsif (p_order_type = c_sup_defc_inbnd_ship
        --and nvl(p_item_type_id,c_part_cond_id) = c_part_cond_id and p_item_type_value = c_part_bad) then
        --l_row_type := c_srow_defc_inbnd_ship;
        --l_offset := c_row_defc_inbnd_ship;
      elsif (p_order_type = c_sup_defc_transit
        and nvl(p_item_type_id,c_part_cond_id) = c_part_cond_id and p_item_type_value = c_part_bad) then
        l_row_type := c_srow_defc_transit;
        l_offset := c_row_defc_transit;
      elsif (p_order_type = c_sup_defc_rec
        and nvl(p_item_type_id,c_part_cond_id) = c_part_cond_id and p_item_type_value = c_part_bad) then
        l_row_type := c_srow_defc_rec;
        l_offset := c_row_defc_rec;
      else
        l_row_type := c_discard;
        l_offset := c_discard;
      end if;  --}
      if (p_type_flag = c_row_type_flag) then
        return l_row_type;
      else
        return l_offset;
      end if;
  end getSupplyRowTypeOffset;

  function getDemandRowTypeOffset(p_order_type number, p_item_type_id number, p_item_type_value number,
	p_type_flag number, p_disposition_id number, p_org_type number) return number is
      l_row_type number;
      l_offset number;
  begin
      if (p_order_type = c_dmd_fcst
              and nvl(p_item_type_id,c_part_cond_id)=c_part_cond_id and nvl(p_item_type_value,c_part_good)=c_part_good) then  --{
        l_row_type := c_drow_fcst;
        l_offset := c_row_net_fcst;
      elsif (p_order_type in (c_dmd_so, c_dmd_so_mds)
        and nvl(p_item_type_id,c_part_cond_id)=c_part_cond_id and nvl(p_item_type_value,c_part_good)=c_part_good ) then
        if (p_disposition_id is null) then
          l_row_type := c_drow_so;
          l_offset := c_row_so;
	else
          --6737751 bugfix, no dependency
	  if ( nvl(p_org_type,-1) = c_field_tech_org ) then
            l_row_type := c_drow_iso_field_org;
            l_offset := c_row_iso_field_org;
	  else
            l_row_type := c_drow_iso;
            l_offset := c_row_iso;
	  end if;
	end if;
      elsif (p_order_type  in (c_dmd_mps, c_dmd_manual_mds)
        and nvl(p_item_type_id,c_part_cond_id)=c_part_cond_id and nvl(p_item_type_value,c_part_good)=c_part_good ) then
        l_row_type := c_drow_other_dmd;
        l_offset := c_row_other_dmd;
      elsif (p_order_type  = c_dmd_pod
        and nvl(p_item_type_id,c_part_cond_id)=c_part_cond_id and nvl(p_item_type_value,c_part_good)=c_part_good ) then
        l_row_type := c_drow_pod;
        l_offset := c_row_pod;
      elsif (p_order_type  = c_dmd_defc_iso
	and nvl(p_item_type_id,c_part_cond_id) = c_part_cond_id and p_item_type_value = c_part_bad) then
        l_row_type := c_drow_defc_iso;
        l_offset := c_row_defc_iso;
      elsif (p_order_type  = c_dmd_defc_pod
        and nvl(p_item_type_id,c_part_cond_id) = c_part_cond_id and p_item_type_value = c_part_bad) then
        l_row_type := c_drow_defc_pod;
        l_offset := c_row_plnd_defc_pod;
      elsif (p_order_type  in (c_dmd_defc_part_dmd, c_dmd_defc_plnd_part_dmd)
        and nvl(p_item_type_id,c_part_cond_id) = c_part_cond_id and p_item_type_value = c_part_bad) then
        l_row_type := c_drow_defc_part_dmd;
        l_offset := c_row_defc_part_dmd;
      else
        l_row_type := c_discard;
        l_offset := c_discard;
      end if;  --}
      if (p_type_flag = c_row_type_flag) then --{
        return l_row_type;
      else
        return l_offset;
      end if; --}
  end getDemandRowTypeOffset;

  procedure getTotalRowTypesBuckets(p_view_type number,
    p_total_row_types out nocopy number, p_total_buckets out nocopy number) is
  begin
    if (p_view_type = c_sdview) then
      p_total_row_types := c_sd_total_row_types;
      p_total_buckets := g_sd_num_of_buckets;
    elsif (p_view_type = c_fcstview) then
      p_total_row_types := c_fcst_total_row_types;
      p_total_buckets := g_fcst_num_of_buckets;
    elsif (p_view_type = c_histview) then
      p_total_row_types := c_hist_total_row_types;
      p_total_buckets := g_hist_num_of_buckets;
    end if;
  end getTotalRowTypesBuckets;

  function getAnalysisQueryId(p_view_type number) return number is
    l_query_id number;
  begin
    if (p_view_type = c_sdview) then
      l_query_id := g_sd_query_id;
    elsif (p_view_type = c_fcstview) then
      l_query_id := g_fcst_query_id;
    elsif (p_view_type = c_histview) then
      l_query_id := g_hist_query_id;
    end if;
    return l_query_id;
  end getAnalysisQueryId;

  procedure getDataStreamLabel(p_view_type number, p_stream_name out nocopy varchar2) is
  begin
    if (p_view_type = c_sdview) then
      p_stream_name := c_sdview_data;
    elsif (p_view_type = c_fcstview) then
      p_stream_name := c_fcstview_data;
    elsif (p_view_type = c_histview) then
      p_stream_name := c_histview_data;
    end if;
  end getDataStreamLabel;

  procedure initGrid (p_view_type number) is
    l_total_row_types number;
    l_total_buckets number;
  begin
     getTotalRowTypesBuckets(p_view_type, l_total_row_types, l_total_buckets);
     -- initialize the bucket to zeros for new item
     for rowTypeIndex in 1..l_total_row_types
     loop --{
	for bktIndex in 1..l_total_buckets
	loop
          g_data_grid(rowTypeIndex)(bktIndex) := to_number(null);
	end loop;
     end loop; --}
  end initGrid;

  procedure addDataToGrid(p_grid_row_index number, p_grid_column_index number, p_qty number,
    p_view_type number) is
    l_cur_qty number;
    l_total_row_types number;
    l_total_buckets number;
  begin
    msc_sda_utils.println(' addDataToGrid p_grid_row_index p_grid_column_index '
	|| p_grid_row_index ||' - '|| p_grid_column_index );

    getTotalRowTypesBuckets(p_view_type, l_total_row_types, l_total_buckets);

    --6606958 there was data beyond plan end_date, stopping that here
    if (p_grid_column_index >l_total_buckets) then
      return;
    end if;
    l_cur_qty := g_data_grid(p_grid_row_index)(p_grid_column_index);
    if (l_cur_qty is not null or  p_qty is not null) then
      g_data_grid(p_grid_row_index)(p_grid_column_index) :=
        nvl(g_data_grid(p_grid_row_index)(p_grid_column_index), 0) + nvl(p_qty, 0);
    end if;
  end addDataToGrid;

  procedure flushToStream(p_row_index number, p_out_data_index in out nocopy number,
    p_out_data in out nocopy msc_sda_utils.maxCharTbl, p_view_type number) is

    l_one_record varchar2(32000) := null;
    l_total_row_types number;
    l_total_buckets number;
    l_stream_name varchar2(100);

  begin
    msc_sda_utils.println('flushToStream in');

    getTotalRowTypesBuckets(p_view_type, l_total_row_types, l_total_buckets);
    getDataStreamLabel(p_view_type, l_stream_name);

     --prepare the data stream
     for bktIndex in 1..l_total_buckets
     loop --{
	for rowTypeIndex in 1..l_total_row_types
	loop
	  declare
	    ll_grid_data_char varchar2(200);
	  begin
	    ll_grid_data_char := nvl(to_char(fnd_number.number_to_canonical(g_data_grid(rowTypeIndex)(bktIndex))), c_null_space);

	    if (l_one_record is null) then
              l_one_record := p_row_index || c_field_seperator || ll_grid_data_char;
	    else
	      if ( nvl(length(l_one_record || c_field_seperator || ll_grid_data_char),0)  < 31980 ) then
                l_one_record := l_one_record || c_field_seperator || ll_grid_data_char;
	      end if;
	    end if;

	  if ( nvl(length(l_one_record || c_field_seperator || ll_grid_data_char),0)  >= 31980
	       or (rowTypeIndex =  l_total_row_types and bktIndex = l_total_buckets) ) then
            if (nvl(length(p_out_data(1)),0) = 1) then
              l_one_record := l_stream_name || c_bang_separator || c_record_seperator || l_one_record;
	    else
              l_one_record := c_record_seperator || l_one_record;
	    end if;
            msc_sda_utils.addToOutStream(l_one_record, p_out_data_index, p_out_data, 1);
	  end if;
	  end;
	end loop;
     end loop; --}
    msc_sda_utils.println('flushToStream out');
  end flushToStream;

  procedure calculateFcstTotals is
    l_total_row_types number;
    l_total_buckets number;
    l_row2_manual_fcst number;
    l_row2_net_fcst number;

    l_row2_ret_manual_fcst number;
    l_row2_ret_fcst number;
  begin
    msc_sda_utils.println('calculateFcstTotals in');
    getTotalRowTypesBuckets(c_fcstview, l_total_row_types, l_total_buckets);

    for bktIndex in 1..l_total_buckets
    loop --{

      -- calculate totals

      -- total forecast
      l_row2_manual_fcst := g_data_grid(c_row2_manual_fcst)(bktIndex);
      l_row2_net_fcst := nvl(g_data_grid(c_row2_net_fcst)(bktIndex), 0)
	+ nvl(g_data_grid(c_row2_dmd_schd)(bktIndex), 0)
	+ nvl(g_data_grid(c_row2_usage_fcst)(bktIndex), 0)
	+ nvl(g_data_grid(c_row2_popultn_fcst)(bktIndex), 0);

      --6904437 bugfix..
      g_data_grid(c_row2_net_fcst)(bktIndex) := l_row2_net_fcst;

      --if ( nvl(l_row2_manual_fcst, l_row2_net_fcst) <> 0 ) then
        g_data_grid(c_row2_total_fcst)(bktIndex) := nvl(l_row2_manual_fcst, l_row2_net_fcst);
      --end if;
    msc_sda_utils.println('c_row2_total_fcst l_row2_manual_fcst, l_row2_net_fcst'||c_row2_total_fcst||' - '||l_row2_manual_fcst||' - '||l_row2_net_fcst);

      -- total returns forecast
     l_row2_ret_manual_fcst := g_data_grid(c_row2_ret_manual_fcst)(bktIndex);
     l_row2_ret_fcst := nvl(g_data_grid(c_row2_ret_fcst)(bktIndex), 0)
	+ nvl(g_data_grid(c_row2_ret_dmd_schd)(bktIndex), 0);

      --if ( nvl(l_row2_ret_manual_fcst, l_row2_ret_fcst) <> 0 ) then
        g_data_grid(c_row2_total_ret_fcst)(bktIndex) := nvl(l_row2_ret_manual_fcst, l_row2_ret_fcst);
      --end if;

    end loop; --}
    msc_sda_utils.println('calculateFcstTotals out');
  end calculateFcstTotals;

  procedure calculateSDTotals is
    l_total_row_types number;
    l_total_buckets number;
    l_ss_last_bucket_index number;
  begin
    msc_sda_utils.println('calculateSDTotals in');

    getTotalRowTypesBuckets(c_sdview, l_total_row_types, l_total_buckets);

    for bktIndex in 1..l_total_buckets
    loop --{

      -- calculate totals

      -- demand totals

      -- Independent Demand -- ISO-field org + Sales orders + Net forecast
      g_data_grid(c_row_indepndt_dmd)(bktIndex) :=
        nvl(g_data_grid(c_row_net_fcst)(bktIndex), 0)
	+ nvl(g_data_grid(c_row_so)(bktIndex), 0)
	+ nvl(g_data_grid(c_row_iso_field_org)(bktIndex), 0);

      -- Dependent Demand -- ISO + planned order demand
      g_data_grid(c_row_dependnt_dmd)(bktIndex) :=
        nvl(g_data_grid(c_row_iso)(bktIndex), 0)
	+ nvl(g_data_grid(c_row_pod)(bktIndex), 0);

      -- Total Demand -- c_row_indepndt_dmd + c_row_dependnt_dmd + c_row_other_dmd
      g_data_grid(c_row_total_dmd)(bktIndex) :=
        nvl(g_data_grid(c_row_indepndt_dmd)(bktIndex), 0)
        + nvl(g_data_grid(c_row_dependnt_dmd)(bktIndex), 0)
	+ nvl(g_data_grid(c_row_other_dmd)(bktIndex), 0);

      -- Total supply -- row-types 11 thru 24
      g_data_grid(c_row_total_supply)(bktIndex) :=
        nvl(g_data_grid(c_row_transit)(bktIndex), 0)
        + nvl(g_data_grid(c_row_receiving)(bktIndex), 0)
        + nvl(g_data_grid(c_row_new_buy_po)(bktIndex), 0)
        + nvl(g_data_grid(c_row_new_buy_po_req)(bktIndex), 0)
        + nvl(g_data_grid(c_row_intrnl_rpr_ordr)(bktIndex), 0)
        + nvl(g_data_grid(c_row_xtrnl_rpr_ordr)(bktIndex), 0)
        + nvl(g_data_grid(c_row_inbnd_ship)(bktIndex), 0)
        + nvl(g_data_grid(c_row_rpr_wo)(bktIndex), 0)
        + nvl(g_data_grid(c_row_plnd_new_buy_ordr)(bktIndex), 0)
        + nvl(g_data_grid(c_row_plnd_intrnl_rpr_ordr)(bktIndex), 0)
        + nvl(g_data_grid(c_row_plnd_xtrnl_rpr_ordr)(bktIndex), 0)
        + nvl(g_data_grid(c_row_plnd_inbnd_ship)(bktIndex), 0)
        + nvl(g_data_grid(c_row_plnd_rpr_wo)(bktIndex), 0)
        + nvl(g_data_grid(c_row_plnd_warr_ordr)(bktIndex), 0)
        + nvl(g_data_grid(c_row_onhand)(bktIndex), 0);

      --Total Defective Part demand - c_row_defc_part_dmd pabram..need to check
      g_data_grid(c_row_total_defc_part_dmd)(bktIndex) :=
        nvl(g_data_grid(c_row_defc_part_dmd)(bktIndex), 0);

      --Total Defective Supply, pivot-row-types sum of 38 thru 42
      g_data_grid(c_row_total_defc_supply)(bktIndex) :=
        nvl(g_data_grid(c_row_returns)(bktIndex), 0)
        + nvl(g_data_grid(c_row_defc_inbnd_ship)(bktIndex), 0)
        + nvl(g_data_grid(c_row_defc_plnd_inbnd_ship)(bktIndex), 0)
        + nvl(g_data_grid(c_row_defc_transit)(bktIndex), 0)
        + nvl(g_data_grid(c_row_defc_rec)(bktIndex), 0)
        + nvl(g_data_grid(c_row_defc_onhand)(bktIndex), 0);

      --PAB - PAB(i-1) + onhand(i) + total-supply(i) - total-demand(i)
      if (bktIndex = 1) then
        g_data_grid(c_row_pab)(bktIndex) :=
	  nvl(g_data_grid(c_row_total_supply)(bktIndex), 0)
	  - nvl(g_data_grid(c_row_total_dmd)(bktIndex), 0);

          -- nvl(g_data_grid(c_row_onhand)(bktIndex), 0) +
	  --c_row_onhand is already part of c_row_total_supply
	  --bug 6527725 fix
      else
        g_data_grid(c_row_pab)(bktIndex) :=
          nvl(g_data_grid(c_row_pab)(bktIndex-1), 0)
	  + nvl(g_data_grid(c_row_total_supply)(bktIndex), 0)
	  - nvl(g_data_grid(c_row_total_dmd)(bktIndex), 0);

          -- + nvl(g_data_grid(c_row_onhand)(bktIndex), 0)
	  --c_row_onhand is already part of c_row_total_supply
	  --bug 6527725 fix
      end if;

      --POH - POH(i-1) + onhand(i) + total-supply-without-planned-order-types(i) - total-demand(i)
      if (bktIndex = 1) then
        g_data_grid(c_row_poh)(bktIndex) :=
          nvl(g_data_grid(c_row_onhand)(bktIndex), 0)
          + nvl(g_data_grid(c_row_transit)(bktIndex), 0)
          + nvl(g_data_grid(c_row_receiving)(bktIndex), 0)
          + nvl(g_data_grid(c_row_new_buy_po)(bktIndex), 0)
          + nvl(g_data_grid(c_row_new_buy_po_req)(bktIndex), 0)
          + nvl(g_data_grid(c_row_intrnl_rpr_ordr)(bktIndex), 0)
          + nvl(g_data_grid(c_row_xtrnl_rpr_ordr)(bktIndex), 0)
          + nvl(g_data_grid(c_row_inbnd_ship)(bktIndex), 0)
          + nvl(g_data_grid(c_row_rpr_wo)(bktIndex), 0)
	  - nvl(g_data_grid(c_row_total_dmd)(bktIndex), 0);
      else
        g_data_grid(c_row_poh)(bktIndex) :=
          nvl(g_data_grid(c_row_poh)(bktIndex-1), 0)
          + nvl(g_data_grid(c_row_onhand)(bktIndex), 0)
          + nvl(g_data_grid(c_row_transit)(bktIndex), 0)
          + nvl(g_data_grid(c_row_receiving)(bktIndex), 0)
          + nvl(g_data_grid(c_row_new_buy_po)(bktIndex), 0)
          + nvl(g_data_grid(c_row_new_buy_po_req)(bktIndex), 0)
          + nvl(g_data_grid(c_row_intrnl_rpr_ordr)(bktIndex), 0)
          + nvl(g_data_grid(c_row_xtrnl_rpr_ordr)(bktIndex), 0)
          + nvl(g_data_grid(c_row_inbnd_ship)(bktIndex), 0)
          + nvl(g_data_grid(c_row_rpr_wo)(bktIndex), 0)
	  - nvl(g_data_grid(c_row_total_dmd)(bktIndex), 0);
      end if;

      --PAB (Defective) - pab-defc(i-1) + onhand-defc(i) + total-supply-defc(i)
        -- - (c_row_defc_iso + c_row_plnd_defc_pod + c_row_defc_part_dmd + c_row_total_defc_part_dmd),
      if (bktIndex = 1) then
        g_data_grid(c_row_defc_pab)(bktIndex) :=
	  nvl(g_data_grid(c_row_total_defc_supply)(bktIndex), 0)
	  - (nvl(g_data_grid(c_row_defc_iso)(bktIndex), 0)
	     + nvl(g_data_grid(c_row_plnd_defc_pod)(bktIndex), 0)
	     + nvl(g_data_grid(c_row_total_defc_part_dmd)(bktIndex), 0));
      else
        g_data_grid(c_row_defc_pab)(bktIndex) :=
          nvl(g_data_grid(c_row_defc_pab)(bktIndex-1), 0)
	  + nvl(g_data_grid(c_row_total_defc_supply)(bktIndex), 0)
	  - (nvl(g_data_grid(c_row_defc_iso)(bktIndex), 0)
	     + nvl(g_data_grid(c_row_plnd_defc_pod)(bktIndex), 0)
	     + nvl(g_data_grid(c_row_total_defc_part_dmd)(bktIndex), 0));
      end if;

/*
      --find the valid safety stock qty entered by user
      if (g_data_grid(c_row_ss_qty)(bktIndex) is not null) then
        l_ss_last_bucket_index := bktIndex;
      end if;
*/
     --6400965 bugfix
     --6867580 bugfix, if the qty 0, show prev bucket value
     if (bktIndex > 1) then
/*
        if ( nvl(g_data_grid(c_row_ss_qty)(bktIndex),0) = 0) then
	  g_data_grid(c_row_ss_qty)(bktIndex) := g_data_grid(c_row_ss_qty)(bktIndex-1);
	end if;
*/
        if ( g_data_grid(c_row_ss_qty)(bktIndex) is null
             and g_data_grid(c_row_ss_qty)(bktIndex-1) <> 0 ) then
	  g_data_grid(c_row_ss_qty)(bktIndex) := g_data_grid(c_row_ss_qty)(bktIndex-1);
	end if;

     end if;

    end loop; --}

/*
    if ( nvl(l_ss_last_bucket_index,c_mbp_null_value) > 0) then
    --special logic for safety stock qty - filling in the gaps
    for bktIndex in 1..l_ss_last_bucket_index
    loop --{
      if (bktIndex > 1) then
        if ( nvl(g_data_grid(c_row_ss_qty)(bktIndex),c_mbp_null_value) = c_mbp_null_value ) then
	  g_data_grid(c_row_ss_qty)(bktIndex) := g_data_grid(c_row_ss_qty)(bktIndex-1);
	end if;
      end if;
    end loop; --}
    end if;
*/

    msc_sda_utils.println('calculateSDTotals out');
  end calculateSDTotals;

  function get_fcst_bucket_index(p_bucket_date date) return number is
    l_bkt_index number := -1;
    l_found boolean := false;
  begin
   for bktIndex in 2..(g_bkt_start_date.count-1)
   loop
     msc_sda_utils.println('get_fcst_bucket_index bktIndex '||bktIndex
       ||' :: bucket_date '|| to_char(p_bucket_date,c_datetime_format)
       ||' :: bkt_start_date '|| to_char(g_bkt_start_date(bktIndex),c_datetime_format) );

     if bktIndex = 2 and trunc(p_bucket_date) <= g_bkt_start_date(bktIndex) then
       l_found := true;
       l_bkt_index := 1;
     end if;
     if bktIndex = (g_bkt_start_date.count-1) and trunc(p_bucket_date) >= g_bkt_start_date(bktIndex) then
       l_found := true;
       l_bkt_index := g_bkt_start_date.count;
     end if;
     if trunc(p_bucket_date) >= g_bkt_start_date(bktIndex) and trunc(p_bucket_date) < g_bkt_start_date(bktIndex+1) then
       l_found := true;
       l_bkt_index := bktIndex;
     end if;
     if (l_found) then
       msc_sda_utils.println(' found index '||l_bkt_index);
       exit;
     end if;
   end loop;
   return l_bkt_index;
  end get_fcst_bucket_index;

/*
  procedure populate_fcst_bkts_to_mfq is
    l_start_date date;
    l_end_date date;
    l_bkt_index number := 1;
  begin
    g_fcst_bkt_mfq_id := msc_sda_utils.getNewFormQueryId;
    msc_sda_utils.println('populate_fcst_bkts_to_mfq query_id '||g_fcst_bkt_mfq_id);

    for bktIndex in 1..g_bkt_start_date.count
    loop
      if l_start_date is null then
        l_start_date := g_bkt_start_date(bktIndex);
      else
        l_end_date := g_bkt_start_date(bktIndex);
        insert into msc_form_query (query_id, last_update_date, last_updated_by, creation_date, created_by, number1, date1, date2 )
        values (g_fcst_bkt_mfq_id , sysdate, -1, sysdate, -1, l_bkt_index, l_start_date, l_end_date);
	l_start_date := l_end_date;
	l_bkt_index := l_bkt_index + 1;
      end if;
    end loop;

    if l_end_date is not null then
        insert into msc_form_query (query_id, last_update_date, last_updated_by, creation_date, created_by, number1, date1, date2 )
        values (g_fcst_bkt_mfq_id , sysdate, -1, sysdate, -1, l_bkt_index, l_start_date, l_end_date);
    end if;
  end populate_fcst_bkts_to_mfq;
*/

  procedure flushAndSendAddlData(p_view_type number, p_query_id number,
    p_out_data in out nocopy msc_sda_utils.maxCharTbl) is

    --------------------------------------
    --- FORECAST VIEW ADDL ROWS CUSROR ---
    --------------------------------------
    cursor fcst_addl_snapshot_cur is
    select
       maq.row_index,
       c_row2_type_16 row_type,
       md.using_assembly_demand_date new_date,
       md.original_item_id due_item_id,
       msc_get_name.item_name(md.original_item_id, null, null, null) due_item_name,
       sum(decode(md.assembly_demand_comp_date,
                           null, decode(md.origination_type,
					      29,(nvl(md.probability,1)* md.using_requirement_quantity),
                                              31, 0,
                                              md.using_requirement_quantity),
                           decode(md.origination_type,
                                       29,(nvl(md.probability,1)* md.daily_demand_rate),
                                       31, 0,
                                       md.daily_demand_rate)))/
             decode(nvl(least(sum(decode(md.origination_type,
                                                       29,nvl(md.probability,0),
                                                       null)),
			     1) ,1),
               0,1,
               nvl(least(sum(decode(md.origination_type,
                                    29,nvl(md.probability,0),
                                    null)) ,1) ,1)) new_quantity
    from
       msc_demands md,
       msc_analysis_query maq,
       msc_form_query mfq2,  -- item-list
       msc_plans mp,
       msc_form_query mfq3 --g_plan_bkts_query_id
    where maq.query_id = p_query_id
       and maq.region_id = c_global_reg_type
       and mfq2.query_id = g_chain_query_id
       and nvl(mfq2.number1,mfq2.number2) = nvl(maq.top_item_id, mfq2.number2)
       and mfq2.number2 = nvl(maq.item_id, mfq2.number2)
       and md.plan_id = g_plan_id
       --and md.sr_instance_id = c_global_inst_id
       and md.organization_id = c_global_org_id
       and md.inventory_item_id = mfq2.number2
       and md.zone_id = c_global_reg_id
       and md.plan_id = mp.plan_id
       and mfq3.query_id = g_plan_bkts_query_id
       and ( trunc(md.using_assembly_demand_date) between trunc(mfq3.date1) and trunc(mfq3.date2) )
     and md.origination_type in (c_dmd2_popu_fcst)
    group by
       maq.row_index,
       c_row2_type_16,
       md.using_assembly_demand_date,
       md.original_item_id,
       msc_get_name.item_name(md.original_item_id, null, null, null)
    order by 1,2,3,4;

    l_one_record varchar2(2000);
    l_out_data_index number := 1;

    ll_row_index msc_sda_utils.number_arr;
    ll_row_type msc_sda_utils.number_arr;
    ll_new_date msc_sda_utils.date_arr;
    ll_due_item_id msc_sda_utils.number_arr;
    ll_due_item_name msc_sda_utils.char_arr;
    ll_new_quantity msc_sda_utils.number_arr;

    l_cur_row_index number := c_mbp_null_value;
    hasRowChanged boolean;
    firstRecord boolean := false;

    l_bkt_index number;
  begin
     open fcst_addl_snapshot_cur;
       fetch fcst_addl_snapshot_cur bulk collect into ll_row_index,
         ll_row_type, ll_new_date, ll_due_item_id, ll_due_item_name, ll_new_quantity;
       close fcst_addl_snapshot_cur;

    for rIndex in 1 .. ll_row_index.count
    loop --{
      l_bkt_index := get_fcst_bucket_index(ll_new_date(rIndex));
      l_one_record := nvl(to_char(ll_row_index(rIndex)),c_null_space)
       || c_field_seperator || nvl(to_char(ll_row_type(rIndex)),c_null_space)
       --|| c_field_seperator || nvl(to_char(ll_new_date(rIndex), c_date_format), c_null_space)
       || c_field_seperator || nvl(to_char(l_bkt_index), c_null_space)
       || c_field_seperator || nvl(to_char(ll_new_quantity(rIndex)), c_null_space)
       || c_field_seperator || nvl(to_char(ll_due_item_id(rIndex)), c_null_space)
       || c_field_seperator || nvl(msc_sda_utils.escapeSplChars(ll_due_item_name(rIndex)), c_null_space);

      msc_sda_utils.println(' l_one_record '||l_one_record);
      if (rIndex = 1) then --{
        if (l_cur_row_index = c_mbp_null_value) then
          l_cur_row_index := ll_row_index(rIndex);
        end if;
	l_one_record := c_fcstview_addl_data || c_bang_separator || c_record_seperator || l_one_record;
        msc_sda_utils.addRecordToOutStream(l_one_record, l_out_data_index, p_out_data);
      else
        hasRowChanged := isRowChanged(ll_row_index(rIndex), l_cur_row_index);
        if (hasRowChanged ) then
	  l_one_record := ll_row_index(rIndex) || c_record_seperator || l_one_record;
	  msc_sda_utils.addRecordToOutStream(l_one_record, l_out_data_index, p_out_data);
	  l_cur_row_index := ll_row_index(rIndex);
        else
	  msc_sda_utils.addRecordToOutStream(l_one_record, l_out_data_index, p_out_data);
	end if;
      end if; --}
    end loop; --}
  end flushAndSendAddlData;

  procedure flushAndSendData(p_view_type number, p_query_id number,
    p_out_data in out nocopy msc_sda_utils.maxCharTbl) is

    cursor rowcount_cur is
    select
       count(*)
    from
       msc_analysis_query maq
    where maq.query_id = p_query_id
       and maq.parent_row_index = g_next_rowset_index;
     l_row_count number;

    ---------------------------
    --- SUPPLY  VIEW CUSROR ---
    ---------------------------
    cursor sd_snapshot_cur is
    select
       maq.row_index,
       msc_sda_pkg.getSupplyRowTypeOffset(ms.order_type, ms.item_type_id, ms.item_type_value, c_row_type_flag, ms.source_organization_id) row_type,
       msc_sda_pkg.getSupplyRowTypeOffset(ms.order_type, ms.item_type_id, ms.item_type_value, c_offset_flag, ms.source_organization_id) offset,
       msc_sda_pkg.getSDStartDate(mfq3.date1, mp.curr_start_date, mp.curr_cutoff_date, ms.new_schedule_date) new_date,
       msc_sda_pkg.getSDEndDate(mfq3.date2, mp.curr_start_date, mp.curr_cutoff_date, ms.new_schedule_date) old_date,
       sum(decode(msi.base_item_id,
	                  null, decode(ms.disposition_status_type,
			                     2, 0,
	                                     decode(ms.last_unit_completion_date,
					                 null, ms.new_order_quantity,
							 ms.daily_rate) ),
                          decode(ms.last_unit_completion_date,
			              null, ms.new_order_quantity,
				      ms.daily_rate) )) new_quantity,
       sum(nvl(ms.old_order_quantity,0)) old_quantity
    from
       msc_supplies ms,
       msc_analysis_query maq,
       msc_form_query mfq1, -- org-list
       msc_form_query mfq2, -- item-list
       msc_plans mp,
       msc_form_query mfq3, --g_plan_bkts_query_id
       msc_system_items msi
    where maq.query_id = p_query_id
       and maq.parent_row_index = g_next_rowset_index
       and mfq1.query_id = g_org_query_id
       and nvl(mfq1.number1,c_mbp_null_value) = nvl(maq.org_list_id,c_mbp_null_value)
       and mfq1.number2 = nvl(maq.inst_id, mfq1.number2)
       and mfq1.number3 = nvl(maq.org_id, mfq1.number3)
       and mfq2.query_id = g_chain_query_id
       and nvl(mfq2.number1,c_mbp_null_value) = nvl(maq.top_item_id,c_mbp_null_value)
       and mfq2.number2 = nvl(maq.item_id, mfq2.number2)
       and ms.plan_id = g_plan_id
       and ms.sr_instance_id = mfq1.number2
       and ms.organization_id = mfq1.number3
       and ms.inventory_item_id = mfq2.number2
       and ms.plan_id = msi.plan_id
       and ms.inventory_item_id = msi.inventory_item_id
       and ms.organization_id = msi.organization_id
       and ms.sr_instance_id = msi.sr_instance_id
       and ms.plan_id = mp.plan_id
       and mfq3.query_id = g_plan_bkts_query_id
       and ( trunc(ms.new_schedule_date) between trunc(mfq3.date1) and trunc(mfq3.date2) )
    group by
       maq.row_index,
       msc_sda_pkg.getSupplyRowTypeOffset(ms.order_type, ms.item_type_id, ms.item_type_value, c_row_type_flag, ms.source_organization_id),
       msc_sda_pkg.getSupplyRowTypeOffset(ms.order_type, ms.item_type_id, ms.item_type_value, c_offset_flag, ms.source_organization_id),
       msc_sda_pkg.getSDStartDate(mfq3.date1, mp.curr_start_date, mp.curr_cutoff_date, ms.new_schedule_date),
       msc_sda_pkg.getSDEndDate(mfq3.date2, mp.curr_start_date, mp.curr_cutoff_date, ms.new_schedule_date)
    union all
    select
       maq.row_index,
       msc_sda_pkg.getDemandRowTypeOffset(md.origination_type, md.item_type_id, md.item_type_value, c_row_type_flag, md.disposition_id, mio.organization_type) row_type,
       msc_sda_pkg.getDemandRowTypeOffset(md.origination_type, md.item_type_id, md.item_type_value, c_offset_flag, md.disposition_id, mio.organization_type) offset,
       msc_sda_pkg.getSDStartDate(mfq3.date1, mp.curr_start_date, mp.curr_cutoff_date, md.using_assembly_demand_date) new_date,
       msc_sda_pkg.getSDEndDate(mfq3.date2, mp.curr_start_date, mp.curr_cutoff_date, md.using_assembly_demand_date) old_date,
        sum(decode(md.assembly_demand_comp_date,
                           null, decode(md.origination_type,
					      29,(nvl(md.probability,1)* md.using_requirement_quantity),
                                              31, 0,
                                              md.using_requirement_quantity),
                           decode(md.origination_type,
                                       29,(nvl(md.probability,1)* md.daily_demand_rate),
                                       31, 0,
                                       md.daily_demand_rate)))/
             decode(nvl(least(sum(decode(md.origination_type,
                                                       29,nvl(md.probability,0),
                                                       null)),
			     1) ,1),
               0,1,
               nvl(least(sum(decode(md.origination_type,
                                    29,nvl(md.probability,0),
                                    null)) ,1) ,1)) new_quantity,
       0 old_quantity
    from
       msc_demands md,
       msc_analysis_query maq,
       msc_form_query mfq1,  -- org-list
       msc_form_query mfq2,  -- item-list
       msc_plans mp,
       msc_form_query mfq3, --g_plan_bkts_query_id
       msc_instance_orgs mio,
       msc_system_items msi
    where maq.query_id = p_query_id
       and maq.parent_row_index = g_next_rowset_index
       and mfq1.query_id = g_org_query_id
       and nvl(mfq1.number1,c_mbp_null_value) = nvl(maq.org_list_id,c_mbp_null_value)
       and mfq1.number2 = nvl(maq.inst_id, mfq1.number2)
       and mfq1.number3 = nvl(maq.org_id, mfq1.number3)
       and mfq2.query_id = g_chain_query_id
       and nvl(mfq2.number1,c_mbp_null_value) = nvl(maq.top_item_id,c_mbp_null_value)
       and mfq2.number2 = nvl(maq.item_id, mfq2.number2)
       and md.plan_id = g_plan_id
       and md.sr_instance_id = mfq1.number2
       and md.organization_id = mfq1.number3
       and md.inventory_item_id = mfq2.number2
       and md.plan_id = msi.plan_id
       and md.inventory_item_id = msi.inventory_item_id
       and md.organization_id = msi.organization_id
       and md.sr_instance_id = msi.sr_instance_id
       and md.plan_id = mp.plan_id
       and mfq3.query_id = g_plan_bkts_query_id
       and ( trunc(md.using_assembly_demand_date) between trunc(mfq3.date1) and trunc(mfq3.date2))
       and md.sr_instance_id = mio.sr_instance_id
       and md.organization_id = mio.organization_id
    group by
       maq.row_index,
       msc_sda_pkg.getDemandRowTypeOffset(md.origination_type, md.item_type_id, md.item_type_value, c_row_type_flag, md.disposition_id, mio.organization_type),
       msc_sda_pkg.getDemandRowTypeOffset(md.origination_type, md.item_type_id, md.item_type_value, c_offset_flag, md.disposition_id, mio.organization_type),
       msc_sda_pkg.getSDStartDate(mfq3.date1, mp.curr_start_date, mp.curr_cutoff_date, md.using_assembly_demand_date),
       msc_sda_pkg.getSDEndDate(mfq3.date2, mp.curr_start_date, mp.curr_cutoff_date, md.using_assembly_demand_date)
    union all
    select
       maq.row_index,
       c_max_level row_type,
       c_row_max_level offset,
       mil.inventory_date new_date,
       mil.inventory_date old_date,
       max(mil.max_quantity) new_quantity,
       0 old_quantity
    from
       msc_inventory_levels mil,
       msc_analysis_query maq,
       msc_form_query mfq1, -- org-list
       msc_form_query mfq2 -- item-list
    where maq.query_id = p_query_id
       and maq.parent_row_index = g_next_rowset_index
       and mfq1.query_id = g_org_query_id
       and nvl(mfq1.number1,c_mbp_null_value) = nvl(maq.org_list_id,c_mbp_null_value)
       and mfq1.number2 = nvl(maq.inst_id, mfq1.number2)
       and mfq1.number3 = nvl(maq.org_id, mfq1.number3)
       and mfq2.query_id = g_chain_query_id
       and nvl(mfq2.number1,c_mbp_null_value) = nvl(maq.top_item_id,c_mbp_null_value)
       and mfq2.number2 = nvl(maq.item_id, mfq2.number2)
       and mil.plan_id = g_plan_id
       and mil.sr_instance_id = mfq1.number2
       and mil.organization_id = mfq1.number3
       and mil.inventory_item_id = mfq2.number2
       and mil.inventory_date <= g_plan_end_date
       and nvl(mil.max_quantity,mil.max_quantity_dos) is not null
    group by
       maq.row_index,
       c_max_level,
       c_row_max_level,
       mil.inventory_date,
       mil.inventory_date
  union all
  select
       maq.row_index,
       c_ss_supply row_type,
       c_row_ss_supply offset,
       mss.period_start_date new_date,
       mss.period_start_date old_date,
       sum(mss.achieved_days_of_supply) new_quantity,
       sum(mss.safety_stock_quantity) old_quantity
    from
       msc_safety_stocks mss,
       msc_analysis_query maq,
       msc_form_query mfq1, -- org-list
       msc_form_query mfq2 -- item-list
    where maq.query_id = p_query_id
       and maq.parent_row_index = g_next_rowset_index
       and mfq1.query_id = g_org_query_id
       and nvl(mfq1.number1,c_mbp_null_value) = nvl(maq.org_list_id,c_mbp_null_value)
       and mfq1.number2 = nvl(maq.inst_id, mfq1.number2)
       and mfq1.number3 = nvl(maq.org_id, mfq1.number3)
       and mfq2.query_id = g_chain_query_id
       and nvl(mfq2.number1,c_mbp_null_value) = nvl(maq.top_item_id,c_mbp_null_value)
       and mfq2.number2 = nvl(maq.item_id, mfq2.number2)
       and mss.plan_id = g_plan_id
       and mss.sr_instance_id = mfq1.number2
       and mss.organization_id = mfq1.number3
       and mss.inventory_item_id = mfq2.number2
       and mss.period_start_date <= g_plan_end_date
    group by
       maq.row_index,
       c_ss_supply,
       c_row_ss_supply,
       mss.period_start_date,
       mss.period_start_date
  union all
  select
       maq.row_index,
       c_target_level row_type,
       c_row_target_level offset,
       nvl(maa.week_start_date, maa.period_start_date) new_date,
       nvl(maa.week_start_date, maa.period_start_date) old_date,
       avg(maa.target_service_level) new_quantity,
       0 old_quantity
    from
       msc_analysis_aggregate maa,
       msc_analysis_query maq,
       msc_plan_buckets mpb,
       msc_form_query mfq1, -- org-list
       msc_form_query mfq2 -- item-list
    where maq.query_id = p_query_id
       and maq.parent_row_index = g_next_rowset_index
       and mfq1.query_id = g_org_query_id
       and nvl(mfq1.number1,c_mbp_null_value) = nvl(maq.org_list_id,c_mbp_null_value)
       and mfq1.number2 = nvl(maq.inst_id, mfq1.number2)
       and mfq1.number3 = nvl(maq.org_id, mfq1.number3)
       and mfq2.query_id = g_chain_query_id
       and nvl(mfq2.number1,c_mbp_null_value) = nvl(maq.top_item_id,c_mbp_null_value)
       and mfq2.number2 = nvl(maq.item_id, mfq2.number2)
       and maa.plan_id = g_plan_id
       and maa.sr_instance_id = mfq1.number2
       and maa.organization_id = mfq1.number3
       and maa.inventory_item_id = mfq2.number2
       and maa.record_type = 3
       and maa.period_type = 1
       and mpb.plan_id = maa.plan_id
       and ( (mpb.bucket_type = 2 and maa.week_start_date   = mpb.bkt_start_date) or
          (mpb.bucket_type = 3 and maa.period_start_date = mpb.bkt_start_date))
    group by
       maq.row_index,
       c_target_level,
       c_row_target_level,
       nvl(maa.week_start_date, maa.period_start_date),
       nvl(maa.week_start_date, maa.period_start_date)
  union all
  select
       maq.row_index,
       c_ss_level row_type,
       c_row_ss_level offset,
       nvl(maa.week_start_date, maa.period_start_date) new_date,
       nvl(maa.week_start_date, maa.period_start_date) old_date,
       sum(maa.achieved_service_level_qty1)
		/ sum(decode(maa.achieved_service_level_qty2,
			0, 1, maa.achieved_service_level_qty2)) new_quantity,
       0 old_quantity
    from
       msc_analysis_aggregate maa,
       msc_analysis_query maq,
       msc_plan_buckets mpb,
       msc_form_query mfq1, -- org-list
       msc_form_query mfq2 -- item-list
    where maq.query_id = p_query_id
       and maq.parent_row_index = g_next_rowset_index
       and mfq1.query_id = g_org_query_id
       and nvl(mfq1.number1,c_mbp_null_value) = nvl(maq.org_list_id,c_mbp_null_value)
       and mfq1.number2 = nvl(maq.inst_id, mfq1.number2)
       and mfq1.number3 = nvl(maq.org_id, mfq1.number3)
       and mfq2.query_id = g_chain_query_id
       and nvl(mfq2.number1,c_mbp_null_value) = nvl(maq.top_item_id,c_mbp_null_value)
       and mfq2.number2 = nvl(maq.item_id, mfq2.number2)
       and maa.plan_id = g_plan_id
       and maa.sr_instance_id = mfq1.number2
       and maa.organization_id = mfq1.number3
       and maa.inventory_item_id = mfq2.number2
       and maa.record_type = 3
       and maa.period_type = 1
       and mpb.plan_id = maa.plan_id
       and ( (mpb.bucket_type = 2 and maa.week_start_date   = mpb.bkt_start_date) or
          (mpb.bucket_type = 3 and maa.period_start_date = mpb.bkt_start_date))
    group by
       maq.row_index,
       c_target_level,
       c_row_target_level,
       nvl(maa.week_start_date, maa.period_start_date),
       nvl(maa.week_start_date, maa.period_start_date)
    order by 1;

    ----------------------------
    --- FORECAST VIEW CUSROR ---
    ----------------------------
    cursor fcst_snapshot_cur is
    --for region based demands
    select
       maq.row_index,
       msc_sda_pkg.getFcstRowTypeOffset(c_demand_type, md.origination_type, md.item_type_id, md.item_type_value, c_row_type_flag,
	 md.sr_instance_id, md.organization_id, md.zone_id, md.schedule_designator_id, md.inventory_item_id) row_type,
       msc_sda_pkg.getFcstRowTypeOffset(c_demand_type, md.origination_type, md.item_type_id, md.item_type_value, c_offset_flag,
	 md.sr_instance_id, md.organization_id, md.zone_id, md.schedule_designator_id, md.inventory_item_id) offset,
       msc_sda_pkg.getFcstStartDate(mfq3.date1, mp.curr_start_date, mp.curr_cutoff_date,
         md.using_assembly_demand_date) new_date,
       msc_sda_pkg.getFcstEndDate(mfq3.date2, mp.curr_start_date, mp.curr_cutoff_date,
         md.using_assembly_demand_date) old_date,
       sum(decode(md.assembly_demand_comp_date,
                           null, decode(md.origination_type,
					      29,(nvl(md.probability,1)* md.using_requirement_quantity),
                                              31, 0,
                                              md.using_requirement_quantity),
                           decode(md.origination_type,
                                       29,(nvl(md.probability,1)* md.daily_demand_rate),
                                       31, 0,
                                       md.daily_demand_rate)))/
             decode(nvl(least(sum(decode(md.origination_type,
                                                       29,nvl(md.probability,0),
                                                       null)),
			     1) ,1),
               0,1,
               nvl(least(sum(decode(md.origination_type,
                                    29,nvl(md.probability,0),
                                    null)) ,1) ,1)) new_quantity,
       sum(nvl(md.original_quantity, md.using_requirement_quantity)) old_quantity
    from
       msc_demands md,
       msc_analysis_query maq,
       msc_form_query mfq1,  -- region-to-org-list
       msc_form_query mfq2,  -- item-list
       msc_plans mp,
       msc_form_query mfq3 --g_plan_bkts_query_id
    where maq.query_id = p_query_id
       and maq.parent_row_index = g_next_rowset_index
       and mfq1.query_id = g_org_query_id
       and mfq1.number1 = nvl(nvl(decode(maq.region_id,
					c_global_reg_type, mfq1.number1, maq.region_id),
			mfq1.number1), mfq1.number1)
       and nvl(mfq1.number2, c_mbp_null_value) = nvl(maq.inst_id, nvl(mfq1.number2, c_mbp_null_value))
       and mfq1.number3 = nvl(maq.org_id, mfq1.number3)
       and mfq2.query_id = g_chain_query_id
       and nvl(mfq2.number1,mfq2.number2) = nvl(maq.top_item_id, mfq2.number2)
       and mfq2.number2 = nvl(maq.item_id, mfq2.number2)
       and md.plan_id = g_plan_id
       and md.sr_instance_id = nvl(maq.inst_id, nvl(mfq1.number2, md.sr_instance_id))
       and md.organization_id = nvl(maq.org_id, nvl(mfq1.number3, md.organization_id))
       and md.inventory_item_id = mfq2.number2
       and nvl(md.zone_id, c_mbp_null_value) = nvl(mfq1.number1, c_mbp_null_value)
       and md.plan_id = mp.plan_id
       and mfq3.query_id = g_plan_bkts_query_id
       and ( trunc(md.using_assembly_demand_date) between trunc(mfq3.date1) and trunc(mfq3.date2) )
       and md.origination_type in (c_dmd2_net_fcst)
       and nvl(maq.region_id, -1) not in (c_global_reg_type, c_local_reg_type)
       and ( ( nvl(maq.region_id,-1) = -1
	          and (md.organization_id = -1
		       or (nvl(maq.org_id, c_mbp_null_value) = md.organization_id
		           and (md.original_demand_id is null
			        or md.original_demand_id in (select demand_id
					   from msc_demands md2
					   where md2.plan_id = g_plan_id
					   and md2.origination_type = c_dmd2_net_fcst
					   and md2.organization_id = -1
					   and md2.inventory_item_id = md.inventory_item_id))
			   )))
           or (nvl(maq.region_id,-1) <> -1 and md.organization_id <> -1) )
       --and md.organization_id <> -1
    group by
       maq.row_index,
       msc_sda_pkg.getFcstRowTypeOffset(c_demand_type, md.origination_type, md.item_type_id, md.item_type_value, c_row_type_flag,
       	 md.sr_instance_id, md.organization_id, md.zone_id, md.schedule_designator_id, md.inventory_item_id),
       msc_sda_pkg.getFcstRowTypeOffset(c_demand_type, md.origination_type, md.item_type_id, md.item_type_value, c_offset_flag,
       	 md.sr_instance_id, md.organization_id, md.zone_id, md.schedule_designator_id, md.inventory_item_id),
       msc_sda_pkg.getFcstStartDate(mfq3.date1, mp.curr_start_date, mp.curr_cutoff_date, md.using_assembly_demand_date),
       msc_sda_pkg.getFcstEndDate(mfq3.date2, mp.curr_start_date, mp.curr_cutoff_date, md.using_assembly_demand_date)
    union all
    --for global based demands
    select
       maq.row_index,
       msc_sda_pkg.getFcstRowTypeOffset(c_demand_type, md.origination_type, md.item_type_id, md.item_type_value, c_row_type_flag,
	 md.sr_instance_id, md.organization_id, md.zone_id, md.schedule_designator_id, md.inventory_item_id) row_type,
       msc_sda_pkg.getFcstRowTypeOffset(c_demand_type, md.origination_type, md.item_type_id, md.item_type_value, c_offset_flag,
	 md.sr_instance_id, md.organization_id, md.zone_id, md.schedule_designator_id, md.inventory_item_id) offset,
       msc_sda_pkg.getFcstStartDate(mfq3.date1, mp.curr_start_date, mp.curr_cutoff_date,
         md.using_assembly_demand_date) new_date,
       msc_sda_pkg.getFcstEndDate(mfq3.date2, mp.curr_start_date, mp.curr_cutoff_date,
         md.using_assembly_demand_date) old_date,
       sum(decode(md.assembly_demand_comp_date,
                           null, decode(md.origination_type,
					      29,(nvl(md.probability,1)* md.using_requirement_quantity),
                                              31, 0,
                                              md.using_requirement_quantity),
                           decode(md.origination_type,
                                       29,(nvl(md.probability,1)* md.daily_demand_rate),
                                       31, 0,
                                       md.daily_demand_rate)))/
             decode(nvl(least(sum(decode(md.origination_type,
                                                       29,nvl(md.probability,0),
                                                       null)),
			     1) ,1),
               0,1,
               nvl(least(sum(decode(md.origination_type,
                                    29,nvl(md.probability,0),
                                    null)) ,1) ,1)) new_quantity,
       sum(nvl(md.original_quantity, md.using_requirement_quantity)) old_quantity
    from
       msc_demands md,
       msc_analysis_query maq,
       msc_form_query mfq1,  -- region-to-org-list
       msc_form_query mfq2,  -- item-list
       msc_plans mp,
       msc_form_query mfq3 --g_plan_bkts_query_id
    where maq.query_id = p_query_id
       and maq.parent_row_index = g_next_rowset_index
       and mfq1.query_id = g_org_query_id
       and mfq1.number1 = nvl(nvl(decode(maq.region_id,
					c_global_reg_type, mfq1.number1, maq.region_id),
			mfq1.number1), mfq1.number1)
       and nvl(mfq1.number2, c_mbp_null_value) = nvl(maq.inst_id, nvl(mfq1.number2, c_mbp_null_value))
       and mfq1.number3 = nvl(maq.org_id, mfq1.number3)
       and mfq2.query_id = g_chain_query_id
       and nvl(mfq2.number1,mfq2.number2) = nvl(maq.top_item_id, mfq2.number2)
       and mfq2.number2 = nvl(maq.item_id, mfq2.number2)
       and md.plan_id = g_plan_id
       and md.sr_instance_id = nvl(maq.inst_id, nvl(mfq1.number2, md.sr_instance_id))
       and md.organization_id = nvl(maq.org_id, nvl(mfq1.number3, md.organization_id))
       and md.inventory_item_id = mfq2.number2
       and nvl(md.zone_id, c_mbp_null_value) = nvl(mfq1.number1, c_mbp_null_value)
       and md.zone_id is null
       and md.plan_id = mp.plan_id
       and mfq3.query_id = g_plan_bkts_query_id
       and ( trunc(md.using_assembly_demand_date) between trunc(mfq3.date1) and trunc(mfq3.date2) )
       and md.origination_type in (c_dmd2_net_fcst)
       and nvl(maq.region_id, -1) in (c_global_reg_type)
       and ( nvl(maq.org_id,-1) = md.organization_id)
       and ( nvl(maq.org_id,-1) = -1
             or (md.original_demand_id is null or
	         md.original_demand_id in (select demand_id
					   from msc_demands md2
					   where md2.plan_id = g_plan_id
					   and md2.origination_type = c_dmd2_net_fcst
					   and md2.organization_id = -1
					   and md2.inventory_item_id = md.inventory_item_id)) )
    group by
       maq.row_index,
       msc_sda_pkg.getFcstRowTypeOffset(c_demand_type, md.origination_type, md.item_type_id, md.item_type_value, c_row_type_flag,
       	 md.sr_instance_id, md.organization_id, md.zone_id, md.schedule_designator_id, md.inventory_item_id),
       msc_sda_pkg.getFcstRowTypeOffset(c_demand_type, md.origination_type, md.item_type_id, md.item_type_value, c_offset_flag,
       	 md.sr_instance_id, md.organization_id, md.zone_id, md.schedule_designator_id, md.inventory_item_id),
       msc_sda_pkg.getFcstStartDate(mfq3.date1, mp.curr_start_date, mp.curr_cutoff_date, md.using_assembly_demand_date),
       msc_sda_pkg.getFcstEndDate(mfq3.date2, mp.curr_start_date, mp.curr_cutoff_date, md.using_assembly_demand_date)
    union all
    --for local based demands
    select
       maq.row_index,
       msc_sda_pkg.getFcstRowTypeOffset(c_demand_type, mfq4.number2, md.item_type_id, md.item_type_value, c_row_type_flag,
	 md.sr_instance_id, md.organization_id, md.zone_id, md.schedule_designator_id, md.inventory_item_id) row_type,
       msc_sda_pkg.getFcstRowTypeOffset(c_demand_type, mfq4.number2, md.item_type_id, md.item_type_value, c_offset_flag,
	 md.sr_instance_id, md.organization_id, md.zone_id, md.schedule_designator_id, md.inventory_item_id) offset,
       msc_sda_pkg.getFcstStartDate(mfq3.date1, mp.curr_start_date, mp.curr_cutoff_date,
         decode(mfq4.number2, c_dmd2_manual_fcst, md.firm_date, md.using_assembly_demand_date)) new_date,
       msc_sda_pkg.getFcstEndDate(mfq3.date2, mp.curr_start_date, mp.curr_cutoff_date,
         decode(mfq4.number2, c_dmd2_manual_fcst, md.firm_date, md.using_assembly_demand_date)) old_date,
      decode(mfq4.number2, c_dmd2_manual_fcst, sum(nvl(md.firm_quantity,0)),
       (sum(decode(md.assembly_demand_comp_date,
                           null, decode(md.origination_type,
					      29,(nvl(md.probability,1)* md.using_requirement_quantity),
                                              31, 0,
                                              md.using_requirement_quantity),
                           decode(md.origination_type,
                                       29,(nvl(md.probability,1)* md.daily_demand_rate),
                                       31, 0,
                                       md.daily_demand_rate)))/
             decode(nvl(least(sum(decode(md.origination_type,
                                                       29,nvl(md.probability,0),
                                                       null)),
			     1) ,1),
               0,1,
               nvl(least(sum(decode(md.origination_type,
                                    29,nvl(md.probability,0),
                                    null)) ,1) ,1)))) new_quantity,
       sum(nvl(md.original_quantity, md.using_requirement_quantity)) old_quantity
    from
       msc_demands md,
       msc_analysis_query maq,
       msc_form_query mfq1,  -- region-to-org-list
       msc_form_query mfq2,  -- item-list
       msc_form_query mfq4,  -- msc_demands duplicate rows
       msc_plans mp,
       msc_form_query mfq3 --g_plan_bkts_query_id
    where maq.query_id = p_query_id
       and maq.parent_row_index = g_next_rowset_index
       and mfq1.query_id = g_org_query_id
       and mfq1.number1 = nvl(maq.region_id, mfq1.number1)
       and nvl(mfq1.number2, c_mbp_null_value) = nvl(maq.inst_id, nvl(mfq1.number2, c_mbp_null_value))
       and mfq1.number3 = nvl(maq.org_id, mfq1.number3)
       and mfq2.query_id = g_chain_query_id
       and nvl(mfq2.number1,mfq2.number2) = nvl(maq.top_item_id, mfq2.number2)
       and mfq2.number2 = nvl(maq.item_id, mfq2.number2)
       and md.plan_id = g_plan_id
       and md.sr_instance_id = nvl(maq.inst_id, nvl(mfq1.number2, md.sr_instance_id))
       and md.organization_id = nvl(maq.org_id, nvl(mfq1.number3, md.organization_id))
       and md.inventory_item_id = mfq2.number2
       --and nvl(md.zone_id, c_mbp_null_value) = nvl(mfq1.number1, c_mbp_null_value)
       and md.zone_id is null
       and md.plan_id = mp.plan_id
       and mfq3.query_id = g_plan_bkts_query_id
       and ( trunc(md.using_assembly_demand_date) between trunc(mfq3.date1) and trunc(mfq3.date2) )
       and md.origination_type in (c_dmd2_net_fcst)
       and nvl(maq.region_id, -1) in (c_local_reg_type, -1)
       and mfq1.number1 = c_local_reg_type
       and md.organization_id <> -1
       and ( nvl(maq.region_id, -1) in (-1,c_local_reg_type) )
       --and ( nvl(maq.region_id, -1) = c_local_reg_type or (maq.region_id is null and maq.org_id is null) )
       and ( (md.original_demand_id is null or
	         md.original_demand_id not in (select demand_id
					   from msc_demands md2
					   where md2.plan_id = g_plan_id
					   and md2.origination_type = c_dmd2_net_fcst
					   and md2.organization_id = -1
					   and md2.inventory_item_id = md.inventory_item_id)) )
       and mfq4.query_id = g_md_dup_rows_qid
       and mfq4.number1 = md.origination_type
       and ((mfq4.number2 = c_dmd2_net_fcst) or (mfq4.number2 = c_dmd2_manual_fcst and firm_date is not null))
    group by
       maq.row_index,
       msc_sda_pkg.getFcstRowTypeOffset(c_demand_type, mfq4.number2, md.item_type_id, md.item_type_value, c_row_type_flag,
	 md.sr_instance_id, md.organization_id, md.zone_id, md.schedule_designator_id, md.inventory_item_id),
       msc_sda_pkg.getFcstRowTypeOffset(c_demand_type, mfq4.number2, md.item_type_id, md.item_type_value, c_offset_flag,
	 md.sr_instance_id, md.organization_id, md.zone_id, md.schedule_designator_id, md.inventory_item_id),
       msc_sda_pkg.getFcstStartDate(mfq3.date1, mp.curr_start_date, mp.curr_cutoff_date,
         decode(mfq4.number2, c_dmd2_manual_fcst, md.firm_date, md.using_assembly_demand_date)),
       msc_sda_pkg.getFcstEndDate(mfq3.date2, mp.curr_start_date, mp.curr_cutoff_date,
         decode(mfq4.number2, c_dmd2_manual_fcst, md.firm_date, md.using_assembly_demand_date)),
	 mfq4.number2
    union all
    --for region based demands - consumption
    select
       maq.row_index,
       c_drow2_consm_qty row_type,
       c_row2_consumed_fcst offset,
       msc_sda_pkg.getFcstStartDate(mfq3.date1, mp.curr_start_date, mp.curr_cutoff_date, mfu.consumption_date) new_date,
       msc_sda_pkg.getFcstEndDate(mfq3.date2, mp.curr_start_date, mp.curr_cutoff_date, mfu.consumption_date) old_date,
       sum(mfu.consumed_qty) new_quantity,
       sum(mfu.overconsumption_qty) old_quantity
    from
       msc_demands md,
       msc_analysis_query maq,
       msc_form_query mfq1,  -- region-to-org-list
       msc_form_query mfq2,  -- item-list
       msc_plans mp,
       msc_forecast_updates mfu,
       msc_form_query mfq3 --g_plan_bkts_query_id
    where maq.query_id = p_query_id
       and maq.parent_row_index = g_next_rowset_index
       and mfq1.query_id = g_org_query_id
       and mfq1.number1 = nvl(nvl(decode(maq.region_id,
					c_global_reg_type, mfq1.number1, maq.region_id),
			mfq1.number1), mfq1.number1)
       and nvl(mfq1.number2, c_mbp_null_value) = nvl(maq.inst_id, nvl(mfq1.number2, c_mbp_null_value))
       and mfq1.number3 = nvl(maq.org_id, mfq1.number3)
       and mfq2.query_id = g_chain_query_id
       and nvl(mfq2.number1,mfq2.number2) = nvl(maq.top_item_id, mfq2.number2)
       and mfq2.number2 = nvl(maq.item_id, mfq2.number2)
       and md.plan_id = g_plan_id
       and md.sr_instance_id = nvl(maq.inst_id, nvl(mfq1.number2, md.sr_instance_id))
       and md.organization_id = nvl(maq.org_id, nvl(mfq1.number3, md.organization_id))
       and md.inventory_item_id = mfq2.number2
       and nvl(md.zone_id, c_mbp_null_value) = nvl(mfq1.number1, c_mbp_null_value)
       and md.plan_id = mp.plan_id
       and mfq3.query_id = g_plan_bkts_query_id
       and ( trunc(md.using_assembly_demand_date) between trunc(mfq3.date1) and trunc(mfq3.date2) )
       and md.origination_type in (c_dmd2_net_fcst)
       and nvl(maq.region_id, -1) not in (c_global_reg_type, c_local_reg_type)
       and ( ( nvl(maq.region_id,-1) = -1
	          and (md.organization_id = -1
		       or (nvl(maq.org_id, c_mbp_null_value) = md.organization_id
		           and (md.original_demand_id is null
			        or md.original_demand_id in (select demand_id
					   from msc_demands md2
					   where md2.plan_id = g_plan_id
					   and md2.origination_type = c_dmd2_net_fcst
					   and md2.organization_id = -1
					   and md2.inventory_item_id = md.inventory_item_id))
			   )))
           or (nvl(maq.region_id,-1) <> -1 and md.organization_id <> -1) )
       and md.plan_id = mfu.plan_id
       and md.demand_id = mfu.forecast_demand_id
       --and md.organization_id <> -1
    group by
       maq.row_index,
       c_drow2_consm_qty,
       c_row2_consumed_fcst,
       msc_sda_pkg.getFcstStartDate(mfq3.date1, mp.curr_start_date, mp.curr_cutoff_date, mfu.consumption_date),
       msc_sda_pkg.getFcstEndDate(mfq3.date2, mp.curr_start_date, mp.curr_cutoff_date, mfu.consumption_date)
    union all
    --for global based demands - consumption
    select
       maq.row_index,
       c_drow2_consm_qty row_type,
       c_row2_consumed_fcst offset,
       msc_sda_pkg.getFcstStartDate(mfq3.date1, mp.curr_start_date, mp.curr_cutoff_date, mfu.consumption_date) new_date,
       msc_sda_pkg.getFcstEndDate(mfq3.date2, mp.curr_start_date, mp.curr_cutoff_date, mfu.consumption_date) old_date,
       sum(mfu.consumed_qty) new_quantity,
       sum(mfu.overconsumption_qty) old_quantity
    from
       msc_demands md,
       msc_analysis_query maq,
       msc_form_query mfq1,  -- region-to-org-list
       msc_form_query mfq2,  -- item-list
       msc_plans mp,
       msc_forecast_updates mfu,
       msc_form_query mfq3 --g_plan_bkts_query_id
    where maq.query_id = p_query_id
       and maq.parent_row_index = g_next_rowset_index
       and mfq1.query_id = g_org_query_id
       and mfq1.number1 = nvl(nvl(decode(maq.region_id,
					c_global_reg_type, mfq1.number1, maq.region_id),
			mfq1.number1), mfq1.number1)
       and nvl(mfq1.number2, c_mbp_null_value) = nvl(maq.inst_id, nvl(mfq1.number2, c_mbp_null_value))
       and mfq1.number3 = nvl(maq.org_id, mfq1.number3)
       and mfq2.query_id = g_chain_query_id
       and nvl(mfq2.number1,mfq2.number2) = nvl(maq.top_item_id, mfq2.number2)
       and mfq2.number2 = nvl(maq.item_id, mfq2.number2)
       and md.plan_id = g_plan_id
       and md.sr_instance_id = nvl(maq.inst_id, nvl(mfq1.number2, md.sr_instance_id))
       and md.organization_id = nvl(maq.org_id, nvl(mfq1.number3, md.organization_id))
       and md.inventory_item_id = mfq2.number2
       and nvl(md.zone_id, c_mbp_null_value) = nvl(mfq1.number1, c_mbp_null_value)
       and md.zone_id is null
       and md.plan_id = mp.plan_id
       and mfq3.query_id = g_plan_bkts_query_id
       and ( trunc(md.using_assembly_demand_date) between trunc(mfq3.date1) and trunc(mfq3.date2) )
       and md.origination_type in (c_dmd2_net_fcst)
       and nvl(maq.region_id, -1) in (c_global_reg_type)
       and ( nvl(maq.org_id,-1) = md.organization_id)
       and ( nvl(maq.org_id,-1) = -1
             or (md.original_demand_id is null or
	         md.original_demand_id in (select demand_id
					   from msc_demands md2
					   where md2.plan_id = g_plan_id
					   and md2.origination_type = c_dmd2_net_fcst
					   and md2.organization_id = -1
					   and md2.inventory_item_id = md.inventory_item_id)) )
       and md.plan_id = mfu.plan_id
       and md.demand_id = mfu.forecast_demand_id
    group by
       maq.row_index,
       c_drow2_consm_qty,
       c_row2_consumed_fcst,
       msc_sda_pkg.getFcstStartDate(mfq3.date1, mp.curr_start_date, mp.curr_cutoff_date, mfu.consumption_date),
       msc_sda_pkg.getFcstEndDate(mfq3.date2, mp.curr_start_date, mp.curr_cutoff_date, mfu.consumption_date)
    union all
    --for local based demands - consumption
    select
       maq.row_index,
       c_drow2_consm_qty row_type,
       c_row2_consumed_fcst offset,
       msc_sda_pkg.getFcstStartDate(mfq3.date1, mp.curr_start_date, mp.curr_cutoff_date, mfu.consumption_date) new_date,
       msc_sda_pkg.getFcstEndDate(mfq3.date2, mp.curr_start_date, mp.curr_cutoff_date, mfu.consumption_date) old_date,
       sum(mfu.consumed_qty) new_quantity,
       sum(mfu.overconsumption_qty) old_quantity
    from
       msc_demands md,
       msc_analysis_query maq,
       msc_form_query mfq1,  -- region-to-org-list
       msc_form_query mfq2,  -- item-list
       msc_plans mp,
       msc_forecast_updates mfu,
       msc_form_query mfq3 --g_plan_bkts_query_id
    where maq.query_id = p_query_id
       and maq.parent_row_index = g_next_rowset_index
       and mfq1.query_id = g_org_query_id
       and mfq1.number1 = nvl(maq.region_id, mfq1.number1)
       and nvl(mfq1.number2, c_mbp_null_value) = nvl(maq.inst_id, nvl(mfq1.number2, c_mbp_null_value))
       and mfq1.number3 = nvl(maq.org_id, mfq1.number3)
       and mfq2.query_id = g_chain_query_id
       and nvl(mfq2.number1,mfq2.number2) = nvl(maq.top_item_id, mfq2.number2)
       and mfq2.number2 = nvl(maq.item_id, mfq2.number2)
       and md.plan_id = g_plan_id
       and md.sr_instance_id = nvl(maq.inst_id, nvl(mfq1.number2, md.sr_instance_id))
       and md.organization_id = nvl(maq.org_id, nvl(mfq1.number3, md.organization_id))
       and md.inventory_item_id = mfq2.number2
       --and nvl(md.zone_id, c_mbp_null_value) = nvl(mfq1.number1, c_mbp_null_value)
       and md.zone_id is null
       and md.plan_id = mp.plan_id
       and mfq3.query_id = g_plan_bkts_query_id
       and ( trunc(md.using_assembly_demand_date) between trunc(mfq3.date1) and trunc(mfq3.date2) )
       and md.origination_type in (c_dmd2_net_fcst)
       and nvl(maq.region_id, -1) in (c_local_reg_type, -1)
       and mfq1.number1 = c_local_reg_type
       and md.organization_id <> -1
       and ( nvl(maq.region_id, -1) in (-1,c_local_reg_type) )
       --and ( nvl(maq.region_id, -1) = c_local_reg_type or (maq.region_id is null and maq.org_id is null) )
       and ( (md.original_demand_id is null or
	         md.original_demand_id not in (select demand_id
					   from msc_demands md2
					   where md2.plan_id = g_plan_id
					   and md2.origination_type = c_dmd2_net_fcst
					   and md2.organization_id = -1
					   and md2.inventory_item_id = md.inventory_item_id)) )
       and md.plan_id = mfu.plan_id
       and md.demand_id = mfu.forecast_demand_id
    group by
       maq.row_index,
       c_drow2_consm_qty,
       c_row2_consumed_fcst,
       msc_sda_pkg.getFcstStartDate(mfq3.date1, mp.curr_start_date, mp.curr_cutoff_date, mfu.consumption_date),
       msc_sda_pkg.getFcstEndDate(mfq3.date2, mp.curr_start_date, mp.curr_cutoff_date, mfu.consumption_date)
    union all
    --for region based supplies
    select
       maq.row_index,
       msc_sda_pkg.getFcstRowTypeOffset(c_supply_type, ms.order_type, ms.item_type_id, ms.item_type_value, c_row_type_flag,
	 c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value) row_type,
       msc_sda_pkg.getFcstRowTypeOffset(c_supply_type, ms.order_type, ms.item_type_id, ms.item_type_value, c_offset_flag,
	 c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value) offset,
       msc_sda_pkg.getFcstStartDate(mfq3.date1, mp.curr_start_date, mp.curr_cutoff_date,
         ms.new_schedule_date) new_date,
       msc_sda_pkg.getFcstEndDate(mfq3.date2, mp.curr_start_date, mp.curr_cutoff_date,
         ms.new_schedule_date) old_date,
       sum(decode(msi.base_item_id,
	                  null, decode(ms.disposition_status_type,
			                     2, 0,
	                                     decode(ms.last_unit_completion_date,
					                 null, ms.new_order_quantity,
							 ms.daily_rate) ),
                          decode(ms.last_unit_completion_date,
			              null, ms.new_order_quantity,
				      ms.daily_rate) )) new_quantity,
       0 old_quantity
    from
       msc_supplies ms,
       msc_analysis_query maq,
       msc_form_query mfq1,  -- region-to-org-list
       msc_form_query mfq2,  -- item-list
       msc_plans mp,
       msc_system_items msi,
       msc_form_query mfq3 --g_plan_bkts_query_id
    where maq.query_id = p_query_id
       and maq.parent_row_index = g_next_rowset_index
       and mfq1.query_id = g_org_query_id
       and mfq1.number1 = nvl(nvl(decode(maq.region_id,
					c_global_reg_type, mfq1.number1, maq.region_id),
			mfq1.number1), mfq1.number1)
       and nvl(mfq1.number2, c_mbp_null_value) = nvl(maq.inst_id, nvl(mfq1.number2, c_mbp_null_value))
       and mfq1.number3 = nvl(maq.org_id, mfq1.number3)
       and mfq2.query_id = g_chain_query_id
       and nvl(mfq2.number1,mfq2.number2) = nvl(maq.top_item_id, mfq2.number2)
       and mfq2.number2 = nvl(maq.item_id, mfq2.number2)
       and ms.plan_id = g_plan_id
       and ms.sr_instance_id = nvl(maq.inst_id, nvl(mfq1.number2, ms.sr_instance_id))
       and ms.organization_id = nvl(maq.org_id, nvl(mfq1.number3, ms.organization_id))
       and ms.inventory_item_id = mfq2.number2
       and nvl(ms.zone_id, c_mbp_null_value) = nvl(mfq1.number1, c_mbp_null_value)
       and ms.plan_id = mp.plan_id
       and mfq3.query_id = g_plan_bkts_query_id
       and ( trunc(ms.new_schedule_date) between trunc(mfq3.date1) and trunc(mfq3.date2) )
       and ms.order_type in (c_sup2_rtns_fcst,
		               c_sup2_rtns_dmd_schd,
		               c_sup2_rtns_bestfit_fcst)
       and nvl(maq.region_id, -1) not in (c_global_reg_type, c_local_reg_type)
       and ms.plan_id = msi.plan_id
       and ms.sr_instance_id = msi.sr_instance_id
       and decode(ms.organization_id,-1, mp.organization_id, ms.organization_id) = msi.organization_id
       and ms.inventory_item_id = msi.inventory_item_id
       --and ms.organization_id <> -1
       and ( ( nvl(maq.region_id,-1) = -1
	          and (ms.organization_id = -1 or (nvl(maq.org_id, -23453) = ms.organization_id ))
		  )
           or (nvl(maq.region_id,-1) <> -1 and ms.organization_id <> -1)
	   )
    group by
       maq.row_index,
       msc_sda_pkg.getFcstRowTypeOffset(c_supply_type, ms.order_type, ms.item_type_id, ms.item_type_value, c_row_type_flag,
       c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value),
       msc_sda_pkg.getFcstRowTypeOffset(c_supply_type, ms.order_type, ms.item_type_id, ms.item_type_value, c_offset_flag,
       c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value),
       msc_sda_pkg.getFcstStartDate(mfq3.date1, mp.curr_start_date, mp.curr_cutoff_date, ms.new_schedule_date),
       msc_sda_pkg.getFcstEndDate(mfq3.date2, mp.curr_start_date, mp.curr_cutoff_date, ms.new_schedule_date)
    union all
    --for global based supplies
    select
       maq.row_index,
       msc_sda_pkg.getFcstRowTypeOffset(c_supply_type, ms.order_type, ms.item_type_id, ms.item_type_value, c_row_type_flag,
	 c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value) row_type,
       msc_sda_pkg.getFcstRowTypeOffset(c_supply_type, ms.order_type, ms.item_type_id, ms.item_type_value, c_offset_flag,
	 c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value) offset,
       msc_sda_pkg.getFcstStartDate(mfq3.date1, mp.curr_start_date, mp.curr_cutoff_date,
         ms.new_schedule_date) new_date,
       msc_sda_pkg.getFcstEndDate(mfq3.date2, mp.curr_start_date, mp.curr_cutoff_date,
         ms.new_schedule_date) old_date,
       sum(decode(msi.base_item_id,
	                  null, decode(ms.disposition_status_type,
			                     2, 0,
	                                     decode(ms.last_unit_completion_date,
					                 null, ms.new_order_quantity,
							 ms.daily_rate) ),
                          decode(ms.last_unit_completion_date,
			              null, ms.new_order_quantity,
				      ms.daily_rate) )) new_quantity,
       0 old_quantity
    from
       msc_supplies ms,
       msc_analysis_query maq,
       msc_form_query mfq1,  -- region-to-org-list
       msc_form_query mfq2,  -- item-list
       msc_plans mp,
       msc_system_items msi,
       msc_form_query mfq3 --g_plan_bkts_query_id
    where maq.query_id = p_query_id
       and maq.parent_row_index = g_next_rowset_index
       and mfq1.query_id = g_org_query_id
       and mfq1.number1 = nvl(nvl(decode(maq.region_id,
					c_global_reg_type, mfq1.number1, maq.region_id),
			mfq1.number1), mfq1.number1)
       and nvl(mfq1.number2, c_mbp_null_value) = nvl(maq.inst_id, nvl(mfq1.number2, c_mbp_null_value))
       and mfq1.number3 = nvl(maq.org_id, mfq1.number3)
       and mfq2.query_id = g_chain_query_id
       and nvl(mfq2.number1,mfq2.number2) = nvl(maq.top_item_id, mfq2.number2)
       and mfq2.number2 = nvl(maq.item_id, mfq2.number2)
       and ms.plan_id = g_plan_id
       and ms.sr_instance_id = nvl(maq.inst_id, nvl(mfq1.number2, ms.sr_instance_id))
       and ms.organization_id = nvl(maq.org_id, nvl(mfq1.number3, ms.organization_id))
       and ms.inventory_item_id = mfq2.number2
       and nvl(ms.zone_id, c_mbp_null_value) = nvl(mfq1.number1, c_mbp_null_value)
       and ms.zone_id is null
       and ms.plan_id = mp.plan_id
       and mfq3.query_id = g_plan_bkts_query_id
       and ( trunc(ms.new_schedule_date) between trunc(mfq3.date1) and trunc(mfq3.date2) )
       and ms.order_type in (c_sup2_rtns_fcst,
		               c_sup2_rtns_dmd_schd,
		               c_sup2_rtns_bestfit_fcst)
       and nvl(maq.region_id, -1) in (c_global_reg_type)
       and ( nvl(maq.org_id,-1) = ms.organization_id)
       and ms.plan_id = msi.plan_id
       and ms.sr_instance_id = msi.sr_instance_id
       and decode(ms.organization_id,-1, mp.organization_id, ms.organization_id) = msi.organization_id
       and ms.inventory_item_id = msi.inventory_item_id
    group by
       maq.row_index,
       msc_sda_pkg.getFcstRowTypeOffset(c_supply_type, ms.order_type, ms.item_type_id, ms.item_type_value, c_row_type_flag,
       c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value),
       msc_sda_pkg.getFcstRowTypeOffset(c_supply_type, ms.order_type, ms.item_type_id, ms.item_type_value, c_offset_flag,
       c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value),
       msc_sda_pkg.getFcstStartDate(mfq3.date1, mp.curr_start_date, mp.curr_cutoff_date, ms.new_schedule_date),
       msc_sda_pkg.getFcstEndDate(mfq3.date2, mp.curr_start_date, mp.curr_cutoff_date, ms.new_schedule_date)
    union all
    --for local based supplies
    select
       maq.row_index,
       msc_sda_pkg.getFcstRowTypeOffset(c_supply_type, mfq4.number2, ms.item_type_id, ms.item_type_value, c_row_type_flag,
	 c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value) row_type,
       msc_sda_pkg.getFcstRowTypeOffset(c_supply_type, mfq4.number2, ms.item_type_id, ms.item_type_value, c_offset_flag,
	 c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value) offset,
       msc_sda_pkg.getFcstStartDate(mfq3.date1, mp.curr_start_date, mp.curr_cutoff_date,
         decode(mfq4.number2, c_sup2_rtns_manual_fcst, ms.firm_date, ms.new_schedule_date)) new_date,
       msc_sda_pkg.getFcstEndDate(mfq3.date2, mp.curr_start_date, mp.curr_cutoff_date,
         decode(mfq4.number2, c_sup2_rtns_manual_fcst, ms.firm_date, ms.new_schedule_date)) old_date,
       sum( decode(mfq4.number2, c_sup2_rtns_manual_fcst, nvl(ms.firm_quantity,0),
       decode(msi.base_item_id,
	                  null, decode(ms.disposition_status_type,
			                     2, 0,
	                                     decode(ms.last_unit_completion_date,
					                 null, ms.new_order_quantity,
							 ms.daily_rate) ),
                          decode(ms.last_unit_completion_date,
			              null, ms.new_order_quantity,
				      ms.daily_rate) ))) new_quantity,
       0 old_quantity
    from
       msc_supplies ms,
       msc_analysis_query maq,
       msc_form_query mfq1,  -- region-to-org-list
       msc_form_query mfq2,  -- item-list
       msc_form_query mfq4,  -- msc_supplies duplicate rows
       msc_plans mp,
       msc_system_items msi,
       msc_form_query mfq3 --g_plan_bkts_query_id
    where maq.query_id = p_query_id
       and maq.parent_row_index = g_next_rowset_index
       and mfq1.query_id = g_org_query_id
       and mfq1.number1 = nvl(maq.region_id, mfq1.number1)
       and nvl(mfq1.number2, c_mbp_null_value) = nvl(maq.inst_id, nvl(mfq1.number2, c_mbp_null_value))
       and mfq1.number3 = nvl(maq.org_id, mfq1.number3)
       and mfq2.query_id = g_chain_query_id
       and nvl(mfq2.number1,mfq2.number2) = nvl(maq.top_item_id, mfq2.number2)
       and mfq2.number2 = nvl(maq.item_id, mfq2.number2)
       and ms.plan_id = g_plan_id
       and ms.sr_instance_id = nvl(maq.inst_id, nvl(mfq1.number2, ms.sr_instance_id))
       and ms.organization_id = nvl(maq.org_id, nvl(mfq1.number3, ms.organization_id))
       and ms.inventory_item_id = mfq2.number2
       --and nvl(ms.zone_id, c_mbp_null_value) = nvl(mfq1.number1, c_mbp_null_value)
       and ms.zone_id is null
       and ms.plan_id = mp.plan_id
       and mfq3.query_id = g_plan_bkts_query_id
       and ( trunc(ms.new_schedule_date) between trunc(mfq3.date1) and trunc(mfq3.date2) )
       and ms.order_type in (c_sup2_rtns_fcst,
		               c_sup2_rtns_dmd_schd,
		               c_sup2_rtns_bestfit_fcst)
       and nvl(maq.region_id, -1) in (c_local_reg_type, -1)
       and mfq1.number1 = c_local_reg_type
       and ms.organization_id <> -1
       and ( nvl(maq.region_id, -1) in (-1,c_local_reg_type) )
       --and ( nvl(maq.region_id, -1) = c_local_reg_type or (maq.region_id is null and maq.org_id is null) )
       and ms.plan_id = msi.plan_id
       and ms.sr_instance_id = msi.sr_instance_id
       and decode(ms.organization_id,-1, mp.organization_id, ms.organization_id) = msi.organization_id
       and ms.inventory_item_id = msi.inventory_item_id
       and mfq4.query_id = g_ms_dup_rows_qid
       and mfq4.number1 = ms.order_type
       and ((mfq4.number2 = c_sup2_rtns_fcst) or (mfq4.number2 = c_sup2_rtns_manual_fcst and firm_date is not null))
    group by
       maq.row_index,
       msc_sda_pkg.getFcstRowTypeOffset(c_supply_type, mfq4.number2, ms.item_type_id, ms.item_type_value, c_row_type_flag,
	 c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value),
       msc_sda_pkg.getFcstRowTypeOffset(c_supply_type, mfq4.number2, ms.item_type_id, ms.item_type_value, c_offset_flag,
	 c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value, c_mbp_null_value),
       msc_sda_pkg.getFcstStartDate(mfq3.date1, mp.curr_start_date, mp.curr_cutoff_date,
         decode(mfq4.number2, c_sup2_rtns_manual_fcst, ms.firm_date, ms.new_schedule_date)),
       msc_sda_pkg.getFcstEndDate(mfq3.date2, mp.curr_start_date, mp.curr_cutoff_date,
         decode(mfq4.number2, c_sup2_rtns_manual_fcst, ms.firm_date, ms.new_schedule_date))
    order by 1;

    cursor hist_min_max_dates is
    select min(date1), max(date2)
    from msc_form_query
    where query_id = g_hist_cal_query_id;

    l_min_date date;
    l_max_date date;

    cursor hist_bucket_dates is
    select date1, date2
    from msc_form_query
    where query_id = g_hist_cal_query_id
    order by 1;

    ll_bkt_start_date msc_sda_utils.date_arr;
    ll_bkt_end_date msc_sda_utils.date_arr;

    ---------------------------
    --- HISTORY VIEW CUSROR ---
    ---------------------------

    --engine will not flush demand history and returns history into msc_supplies/msc_demands
    --ui needs to look at msd views to get this information
    cursor hist_snapshot_cur is
    select
       maq.row_index,
       msc_sda_pkg.getHistRowTypeOffset(mmhv.row_type, c_mbp_null_value, c_mbp_null_value, c_row_type_flag) row_type,
       msc_sda_pkg.getHistRowTypeOffset(mmhv.row_type, c_mbp_null_value, c_mbp_null_value, c_offset_flag) offset,
       msc_sda_pkg.getHistStartDate(mfq3.date1, l_min_date, l_max_date, mmhv.anchor_date) new_date,
       msc_sda_pkg.getHistEndDate(mfq3.date2, l_min_date, l_max_date, mmhv.anchor_date) old_date,
       sum(mmhv.quantity) new_quantity,
       0 old_quantity
    from
       msc_msd_history_v mmhv,
       msc_analysis_query maq,
       msc_form_query mfq1,  -- region-to-org-list
       msc_form_query mfq2,  -- item-list
       msc_form_query mfq3  -- history calendar
    where maq.query_id = p_query_id
       and maq.parent_row_index = g_next_rowset_index
       and mfq1.query_id = g_org_query_id
       and mfq1.number1 = nvl(maq.region_id, mfq1.number1)
       and nvl(mfq1.number2, c_mbp_not_null_value) = nvl(maq.inst_id, nvl(mfq1.number2, c_mbp_not_null_value))
       and nvl(mfq1.number3, -1) = nvl(maq.org_id,  nvl(mfq1.number3, -1))
       and mfq2.query_id = g_chain_query_id
       and nvl(mfq2.number1,mfq2.number2) = nvl(maq.top_item_id, mfq2.number2)
       and mfq2.number2 = nvl(maq.item_id, mfq2.number2)
       and nvl(mmhv.sr_instance_id, c_mbp_not_null_value) = nvl(maq.inst_id, nvl(mfq1.number2, c_mbp_not_null_value))
       and nvl(mmhv.organization_id, -1) = nvl(maq.org_id, nvl(mfq1.number3, -1))
       and mmhv.inventory_item_id = mfq2.number2
       and nvl(mmhv.zone_id, c_local_reg_type) = mfq1.number1
       and mfq3.query_id = g_hist_cal_query_id
       and trunc(mmhv.anchor_date) between mfq3.date1 and mfq3.date2
    group by
       maq.row_index,
       msc_sda_pkg.getHistRowTypeOffset(mmhv.row_type, c_mbp_null_value, c_mbp_null_value, c_row_type_flag),
       msc_sda_pkg.getHistRowTypeOffset(mmhv.row_type, c_mbp_null_value, c_mbp_null_value, c_offset_flag),
       msc_sda_pkg.getHistStartDate(mfq3.date1, l_min_date, l_max_date, mmhv.anchor_date),
       msc_sda_pkg.getHistEndDate(mfq3.date2, l_min_date, l_max_date, mmhv.anchor_date)
     order by 1;

/*
    cursor hist_snapshot_cur is
    select
       maq.row_index,
       msc_sda_pkg.getHistRowTypeOffset(ms.order_type, ms.item_type_id, ms.item_type_value, c_row_type_flag) row_type,
       msc_sda_pkg.getHistRowTypeOffset(ms.order_type, ms.item_type_id, ms.item_type_value, c_offset_flag) offset,
       msc_sda_pkg.getHistStartDate(mfq3.date1, l_min_date, l_max_date, ms.new_schedule_date) new_date,
       msc_sda_pkg.getHistEndDate(mfq3.date2, l_min_date, l_max_date, ms.new_schedule_date) old_date,
       sum(ms.new_order_quantity) new_quantity,
       0 old_quantity
    from
       msc_supplies ms,
       msc_analysis_query maq,
       msc_form_query mfq1,  -- region-to-org-list
       msc_form_query mfq2,  -- item-list
       msc_form_query mfq3  -- history calendar
    where maq.query_id = p_query_id
       and maq.parent_row_index = g_next_rowset_index
       and mfq1.query_id = g_org_query_id
       and mfq1.number1 = nvl(maq.region_id, mfq1.number1)
       and mfq1.number2 = nvl(maq.inst_id, mfq1.number2)
       and mfq1.number3 = nvl(maq.org_id, mfq1.number3)
       and mfq2.query_id = g_chain_query_id
       and nvl(mfq2.number1,mfq2.number2) = nvl(maq.top_item_id, mfq2.number2)
       and mfq2.number2 = nvl(maq.item_id, mfq2.number2)
       and ms.plan_id = g_plan_id
       and ms.sr_instance_id = nvl(maq.inst_id, mfq1.number2)
       and ms.organization_id = nvl(maq.org_id, mfq1.number3)
       and ms.inventory_item_id = mfq2.number2
       and nvl(ms.zone_id, c_local_reg_type) = mfq1.number1
       and mfq3.query_id = g_hist_cal_query_id
       and trunc(ms.new_schedule_date) between mfq3.date1 and mfq3.date2
       and ms.order_type = c_returns_hist
    group by
       maq.row_index,
       msc_sda_pkg.getHistRowTypeOffset(ms.order_type, ms.item_type_id, ms.item_type_value, c_row_type_flag),
       msc_sda_pkg.getHistRowTypeOffset(ms.order_type, ms.item_type_id, ms.item_type_value, c_offset_flag),
       msc_sda_pkg.getHistStartDate(mfq3.date1, l_min_date, l_max_date, ms.new_schedule_date),
       msc_sda_pkg.getHistEndDate(mfq3.date2, l_min_date, l_max_date, ms.new_schedule_date)
    union all
    select
       maq.row_index,
       msc_sda_pkg.getHistRowTypeOffset(md.origination_type, md.item_type_id, md.item_type_value, c_row_type_flag) row_type,
       msc_sda_pkg.getHistRowTypeOffset(md.origination_type, md.item_type_id, md.item_type_value, c_offset_flag) offset,
       msc_sda_pkg.getHistStartDate(mfq3.date1, l_min_date, l_max_date, md.using_assembly_demand_date) new_date,
       msc_sda_pkg.getHistEndDate(mfq3.date2, l_min_date, l_max_date, md.using_assembly_demand_date) old_date,
       sum(md.using_requirement_quantity) new_quantity,
       0 old_quantity
    from
       msc_demands md,
       msc_analysis_query maq,
       msc_form_query mfq1,  -- region-to-org-list
       msc_form_query mfq2,  -- item-list
       msc_form_query mfq3  -- history calendar
    where maq.query_id = p_query_id
       and maq.parent_row_index = g_next_rowset_index
       and mfq1.query_id = g_org_query_id
       and mfq1.number1 = nvl(maq.region_id, mfq1.number1)
       and mfq1.number2 = nvl(maq.inst_id, mfq1.number2)
       and mfq1.number3 = nvl(maq.org_id, mfq1.number3)
       and mfq2.query_id = g_chain_query_id
       and nvl(mfq2.number1,mfq2.number2) = nvl(maq.top_item_id, mfq2.number2)
       and mfq2.number2 = nvl(maq.item_id, mfq2.number2)
       and md.plan_id = g_plan_id
       and md.sr_instance_id = nvl(maq.inst_id, mfq1.number2)
       and md.organization_id = nvl(maq.org_id, mfq1.number3)
       and md.inventory_item_id = mfq2.number2
       and nvl(md.zone_id, md.schedule_designator_id, c_local_reg_type) = mfq1.number1
       and mfq3.query_id = g_hist_cal_query_id
       and trunc(md.using_assembly_demand_date) between mfq3.date1 and mfq3.date2
       and md.origination_type = c_dmd_hist
    group by
       maq.row_index,
       msc_sda_pkg.getHistRowTypeOffset(md.origination_type, md.item_type_id, md.item_type_value, c_row_type_flag),
       msc_sda_pkg.getHistRowTypeOffset(md.origination_type, md.item_type_id, md.item_type_value, c_offset_flag),
       msc_sda_pkg.getHistStartDate(mfq3.date1, l_min_date, l_max_date, md.using_assembly_demand_date),
       msc_sda_pkg.getHistEndDate(mfq3.date2, l_min_date, l_max_date, md.using_assembly_demand_date)
     order by 1;
*/
/*
 QUERY_ID    NUMBER1    NUMBER2    NUMBER3
---------- ---------- ---------- ----------
    235631       -400         21        207 --org_reg-query
    235631       -300         21        207 --org_reg-query
    235631        407         21        207 --org_reg-query

QUERY RIDX PIDX  RLID   RID       OLID INST  ORG TOP_ITEM_ID    ITEM_ID
----- ---- ---- ----- ----- ---------- ---- ---- ----------- ----------  -- msc_analysis_query

  755    1    1  -100             -200                            49956  -- allRegions-allOrgs

  755    2    2  -100   407       -200                            49956  -- validRegion-allOrgs
  755    3    2  -100  -400       -200                            49956  -- localRegion-allOrgs

  755    4    3  -100   407       -200   21  207                  49956  -- validRegion-validOrgs

  755    5    4  -100             -200   21  207                  49956  --allRegions-validOrgs

  755    6    5  -100  -400       -200   21  207                  49956  --localRegion-validOrgs
*/

    ll_row_index msc_sda_utils.number_arr;
    ll_row_type msc_sda_utils.number_arr;
    ll_offset msc_sda_utils.number_arr;
    ll_new_date msc_sda_utils.date_arr;
    ll_old_date msc_sda_utils.date_arr;
    ll_new_quantity msc_sda_utils.number_arr;
    ll_old_quantity msc_sda_utils.number_arr;

    l_cur_row_index number := c_mbp_null_value;
    hasRowChanged boolean;

    l_out_data_index number := 1;
  begin
     msc_sda_utils.println('flushAndSendData in');
     msc_sda_utils.println('g_plan_id p_query_id g_next_rowset_index g_org_query_id g_chain_query_id '||
      g_plan_id ||' - '|| p_query_id ||' - '|| g_next_rowset_index ||' - '|| g_org_query_id ||' - '|| g_chain_query_id );

     --fetch rows from snapshot cursor
     if (p_view_type = c_sdview) then
       open sd_snapshot_cur;
       fetch sd_snapshot_cur bulk collect into ll_row_index,
         ll_row_type, ll_offset, ll_new_date, ll_old_date,
         ll_new_quantity, ll_old_quantity;
       close sd_snapshot_cur;
	msc_sda_utils.println('sd view row count '||ll_row_index.count);
     elsif (p_view_type = c_fcstview) then
       open fcst_snapshot_cur;
       fetch fcst_snapshot_cur bulk collect into ll_row_index,
         ll_row_type, ll_offset, ll_new_date, ll_old_date,
         ll_new_quantity, ll_old_quantity;
       close fcst_snapshot_cur;
	msc_sda_utils.println('fcst view row count '||ll_row_index.count);
     elsif (p_view_type = c_histview) then
       open hist_min_max_dates;
       fetch hist_min_max_dates into l_min_date, l_max_date;
       close hist_min_max_dates;

       open hist_bucket_dates;
       fetch hist_bucket_dates bulk collect into ll_bkt_start_date, ll_bkt_end_date;
       close hist_bucket_dates;

       open hist_snapshot_cur;
       fetch hist_snapshot_cur bulk collect into ll_row_index,
         ll_row_type, ll_offset, ll_new_date, ll_old_date,
         ll_new_quantity, ll_old_quantity;
       close hist_snapshot_cur;
	msc_sda_utils.println('hist view row count '||ll_row_index.count||' - bucket count '||ll_bkt_start_date.count);
     end if;

     if (msc_sda_utils.g_log_flag) then
       msc_sda_utils.println('snapshot_cur row_index row_type offset new_date old_date new_qty old_qty ');
       for rIndex in 1 .. ll_row_index.count
       loop --{
	 msc_sda_utils.println(ll_row_index(rIndex)
	  || ' - '|| ll_row_type(rIndex)
          || ' - '|| ll_offset(rIndex)
          || ' - '|| to_char(ll_new_date(rIndex), c_date_format)
	  || ' - '|| to_char(ll_old_date(rIndex), c_date_format)
	  || ' - '|| ll_new_quantity(rIndex)
	  || ' - '|| ll_old_quantity(rIndex) );
       end loop;
     end if;

     --for all items fetched from snapshot_cur, flush to bucket and then flush to table
     for rIndex in 1 .. ll_row_index.count
     loop --{
	msc_sda_utils.println('snapshot_cur row_index '|| ll_row_index(rIndex)
	  || ' bktdate '|| to_char(ll_new_date(rIndex), c_date_format) ||' qty '
	  || ll_new_quantity(rIndex) ||' offset '|| ll_offset(rIndex) );

	if (rIndex = 1) then
	   initGrid(p_view_type);  -- init/reinit grid to zeros
	   if (l_cur_row_index = c_mbp_null_value) then
	     l_cur_row_index := ll_row_index(rIndex);
	   end if;
	else
          hasRowChanged := isRowChanged(ll_row_index(rIndex), l_cur_row_index);
	   if (hasRowChanged ) then
	      msc_sda_utils.println('row has changed ');
	     if (p_view_type = c_sdview) then
	       calculateSDTotals;
	       flushToStream(l_cur_row_index, l_out_data_index, p_out_data, p_view_type);
	     elsif (p_view_type = c_fcstview) then
	       calculateFcstTotals;
	       flushToStream(l_cur_row_index, l_out_data_index, p_out_data, p_view_type);
	     elsif (p_view_type = c_histview) then
	       --calculateHistTotals;
	       flushToStream(l_cur_row_index, l_out_data_index, p_out_data, p_view_type);
	     end if;
	     initGrid(p_view_type);  -- init/reinit grid to zeros
	     l_cur_row_index := ll_row_index(rIndex);
	   end if;
	end if;

        --flush the values to right bucket
	if (p_view_type in (c_sdview, c_fcstview)) then
          for bktIndex in 1..g_bkt_start_date.count
	  loop --{
	    if ( trunc(ll_new_date(rIndex)) >= g_bkt_start_date(bktIndex)
	       and trunc(ll_new_date(rIndex)) <= g_bkt_end_date(bktIndex)
	       and ( ll_new_quantity(rIndex) <> 0  or ll_old_quantity(rIndex) <> 0
	             or (p_view_type = c_sdview and ll_offset(rIndex) = c_row_ss_supply) )
	       and ll_offset(rIndex) <> c_row_discard ) then
	      addDataToGrid(ll_offset(rIndex), bktIndex, ll_new_quantity(rIndex), p_view_type);

	      msc_sda_utils.println('safety stock qty '|| ll_offset(rIndex) ||' - '|| c_row_ss_supply);
	      if (ll_offset(rIndex) = c_row_ss_supply) then
	        addDataToGrid(c_row_ss_qty, bktIndex, ll_old_quantity(rIndex), p_view_type);
	      end if;

	      if (p_view_type = c_fcstview) then
	        if (ll_offset(rIndex) = c_row2_consumed_fcst) then
	          addDataToGrid(c_row2_over_consmptn, bktIndex, ll_old_quantity(rIndex), p_view_type);
		end if;
	        if (ll_offset(rIndex) in (c_row2_net_fcst, c_row2_dmd_schd, c_row2_usage_fcst, c_row2_popultn_fcst) ) then
	          addDataToGrid(c_row2_orig_fcst, bktIndex, ll_old_quantity(rIndex), p_view_type);
		end if;
	      end if;
	    end if;
	  end loop; --}

	elsif (p_view_type = c_histview) then
          for bktIndex in 1..ll_bkt_start_date.count
	  loop --{
	    if ( trunc(ll_new_date(rIndex)) >= ll_bkt_start_date(bktIndex)
	       and trunc(ll_new_date(rIndex)) <= ll_bkt_end_date(bktIndex)
	       and ll_new_quantity(rIndex) <> 0
	       and ll_offset(rIndex) <> c_row_discard ) then
	      addDataToGrid(ll_offset(rIndex), bktIndex, ll_new_quantity(rIndex), p_view_type);
	      msc_sda_utils.println('addDataToGrid rindex bktindex qty '||ll_row_index(rIndex)||' - '||bktIndex||' - '||ll_new_quantity(rIndex));
	    end if;
	  end loop; --}
	end if;

        if (rIndex = ll_row_index.count) then --{
	   if (rIndex = ll_row_index.count) then
	     msc_sda_utils.println(' last row');
	     if (p_view_type = c_sdview) then
	       calculateSDTotals;
	       flushToStream(ll_row_index(rIndex), l_out_data_index, p_out_data, p_view_type);
	     elsif (p_view_type = c_fcstview) then
	       calculateFcstTotals;
	       flushToStream(l_cur_row_index, l_out_data_index, p_out_data, p_view_type);
	     elsif (p_view_type = c_histview) then
	       --calculateHistTotals;
	       flushToStream(l_cur_row_index, l_out_data_index, p_out_data, p_view_type);
	     end if;
	   end if;
	end if; --}

        l_cur_row_index := ll_row_index(rIndex);
     end loop; --}

     msc_sda_utils.println('flushAndSendData out');
  end flushAndSendData;

  procedure flushSDRows(p_query_id number, p_row_index number,
    p_orglist_action number, p_itemlist_action number, p_action_node number) is

   l_orglist_action number;
   l_itemlist_action number;
   l_row c_row_values_cur%rowtype;

   cursor c_orgs_cur is
   select distinct
     mfq.number1 org_list_id,
     mfq.char1 org_list,
     mfq.number2 inst_id,
     mfq.number3 org_id,
     mfq.char4 org_code,
     mfq.number4 sort_column
   from msc_form_query mfq
   where mfq.query_id = g_org_query_id
   order by sort_column;

   cursor c_items_cur is
   select distinct
     number1 top_item_id,
     char1 top_item_name,
     number2 item_id,
     char2 item_name,
     number3 sort_column
   from msc_form_query
   where query_id = g_chain_query_id
   order by sort_column desc;

  l_row_check number;
begin
    msc_sda_utils.println('flushSDRows in');
    --msc_sda_utils.println('p_row_index - p_orglist_action - p_itemlist_action '|| p_row_index
    --||' -'|| p_orglist_action ||' -'|| p_itemlist_action );

  if (p_row_index = 1 and p_action_node is null ) then
    msc_sda_utils.println('flushSDRows out 1');
    return;
  end if;

  open c_row_values_cur(p_query_id, p_row_index, to_number(null));
  fetch c_row_values_cur into l_row;
  close c_row_values_cur;

  if (l_row.item_id is null) then
    l_itemlist_action := c_collapsed_state;
  else
    l_itemlist_action := p_itemlist_action;
  end if;

  if (l_row.org_id is null) then
    l_orglist_action := c_collapsed_state;
  else
    l_orglist_action := p_orglist_action;
  end if;

  open c_next_rowset_index_cur(p_query_id);
  fetch c_next_rowset_index_cur into g_next_rowset_index;
  close c_next_rowset_index_cur;
  g_next_rowset_index := g_next_rowset_index + 1;

  if (p_action_node = c_org_node) then --{
      for c_orgs in c_orgs_cur --{
      loop
       msc_sda_utils.println(' orgs +');
  	g_row_index := g_row_index +1;
         insert into msc_analysis_query
          (query_id, row_index, parent_row_index,
             org_list_id, org_list, inst_id, org_id, org_code, org_list_state,
	     top_item_id, top_item_name, item_id, item_name, top_item_name_state)
          values (p_query_id, g_row_index, g_next_rowset_index,
	     c_orgs.org_list_id, c_orgs.org_list, c_orgs.inst_id, c_orgs.org_id, c_orgs.org_code, l_orglist_action,
	     l_row.top_item_id, l_row.top_item_name, l_row.item_id, l_row.item_name, l_itemlist_action);
      end loop; -- }
  end if; -- }

  if (p_action_node = c_item_node) then --{
        for c_item in c_items_cur --{
	loop
         msc_sda_utils.println(' items +');
  	  g_row_index := g_row_index +1;
          insert into msc_analysis_query
          (query_id, row_index, parent_row_index,
             org_list_id, org_list, inst_id, org_id, org_code, org_list_state,
	     top_item_id, top_item_name, item_id, item_name, top_item_name_state)
          values (p_query_id, g_row_index, g_next_rowset_index,
	     l_row.org_list_id, l_row.org_list, l_row.inst_id, l_row.org_id, l_row.org_code, l_orglist_action,
	     c_item.top_item_id, c_item.top_item_name, c_item.item_id, c_item.item_name, l_itemlist_action);
	end loop; --}
  end if; -- }

  msc_sda_utils.println('flushSDRows out');
  end flushSDRows;

  procedure flushFcstHistoryRows(p_view_type number, p_query_id number, p_row_index number,
    p_reglist_action number, p_orglist_action number, p_itemlist_action number, p_action_node number) is

   l_reglist_action number;
   l_orglist_action number;
   l_itemlist_action number;
   l_row c_row_values_cur%rowtype;

   cursor c_regs_cur is
   select distinct
     mfq.number2 region_id,
     mfq.char2 region_code,
     mfq.number3 sort_column
   from msc_form_query mfq
   where mfq.query_id = g_region_query_id
   and (   (p_view_type = c_fcstview)
	or (p_view_type = c_histview and mfq.number2 <> c_global_reg_type))
   order by sort_column desc;

   cursor c_orgs_cur(p_region_id number) is
   select distinct
     mfq.number2 inst_id,
     mfq.number3 org_id,
     mfq.char1 org_code,
     mfq.number4 sort_column
   from msc_form_query mfq
   where mfq.query_id = g_org_query_id
   and mfq.number3 <> -1
   and (   (p_view_type = c_fcstview and nvl(p_region_id, c_mbp_null_value) <> c_local_reg_type)
        or (p_view_type = c_fcstview and nvl(p_region_id, c_mbp_null_value) = c_local_reg_type
	    and nvl(mfq.number2,c_mbp_null_value) <> c_mbp_null_value)
	or (p_view_type = c_histview and nvl(mfq.number2,c_mbp_null_value) <> c_mbp_null_value))
   order by sort_column;

   cursor c_items_cur is
   select distinct
     number1 top_item_id,
     char1 top_item_name,
     number2 item_id,
     char2 item_name,
     number3 sort_column
   from msc_form_query
   where query_id = g_chain_query_id
   order by sort_column desc;

  l_row_check number;
begin
    msc_sda_utils.println('flushFcstHistoryRows in');

  if (p_row_index = 1 and p_action_node is null ) then
    return;
  end if;

  open c_row_values_cur(p_query_id, p_row_index, to_number(null));
  fetch c_row_values_cur into l_row;
  close c_row_values_cur;

  if (l_row.region_id is null) then
    l_reglist_action := c_collapsed_state;
  else
    l_reglist_action := p_reglist_action;
  end if;

  if (l_row.org_id is null) then
    l_orglist_action := c_collapsed_state;
  else
    l_orglist_action := p_orglist_action;
  end if;

  if (l_row.item_id is null) then
    l_itemlist_action := c_collapsed_state;
  else
    l_itemlist_action := p_itemlist_action;
  end if;

  open c_next_rowset_index_cur(p_query_id);
  fetch c_next_rowset_index_cur into g_next_rowset_index;
  close c_next_rowset_index_cur;
  g_next_rowset_index := g_next_rowset_index + 1;

  if (p_action_node = c_region_node) then --{
      for c_regs in c_regs_cur --{
      loop
  	g_row_index := g_row_index +1;
         insert into msc_analysis_query
          (query_id, row_index, parent_row_index,
	    region_list_id, region_list, region_id, region_code, region_list_state,
             org_list_id, org_list, inst_id, org_id, org_code, org_list_state,
	     top_item_id, top_item_name, item_id, item_name, top_item_name_state)
          values (p_query_id, g_row_index, g_next_rowset_index,
	     l_row.region_list_id, l_row.region_list, c_regs.region_id, c_regs.region_code, l_reglist_action,
	     l_row.org_list_id, l_row.org_list, l_row.inst_id, l_row.org_id, l_row.org_code, l_orglist_action,
	     l_row.top_item_id, l_row.top_item_name, l_row.item_id, l_row.item_name, l_itemlist_action);
      end loop; -- }
  end if; -- }

  if (p_action_node = c_org_node) then --{
      for c_orgs in c_orgs_cur(l_row.region_id) --{
      loop
  	g_row_index := g_row_index +1;
        --msc_sda_utils.println(	'row_index '||g_row_index ||' - '|| c_orgs.org_list_id ||'  '|| c_orgs.org_list ||'  '|| c_orgs.inst_id ||'  '|| c_orgs.org_id ||'  '|| c_orgs.org_code ||'  '|| c_orgs.sort_column);
         insert into msc_analysis_query
          (query_id, row_index, parent_row_index,
	    region_list_id, region_list, region_id, region_code, region_list_state,
             org_list_id, org_list, inst_id, org_id, org_code, org_list_state,
	     top_item_id, top_item_name, item_id, item_name, top_item_name_state)
          values (p_query_id, g_row_index, g_next_rowset_index,
	     l_row.region_list_id, l_row.region_list, l_row.region_id, l_row.region_code, l_reglist_action,
	     l_row.org_list_id, l_row.org_list, c_orgs.inst_id, c_orgs.org_id, c_orgs.org_code, l_orglist_action,
	     l_row.top_item_id, l_row.top_item_name, l_row.item_id, l_row.item_name, l_itemlist_action);
      end loop; -- }
  end if; -- }

  if (p_action_node = c_item_node) then --{
        for c_item in c_items_cur --{
	loop
  	  g_row_index := g_row_index +1;
          --msc_sda_utils.println('row_index '||g_row_index ||' - '|| c_item.top_item_id ||'  '|| c_item.top_item_name ||'  '|| c_item.item_id ||'  '|| c_item.item_name);
          insert into msc_analysis_query
          (query_id, row_index, parent_row_index,
	    region_list_id, region_list, region_id, region_code, region_list_state,
             org_list_id, org_list, inst_id, org_id, org_code, org_list_state,
	     top_item_id, top_item_name, item_id, item_name, top_item_name_state)
          values (p_query_id, g_row_index, g_next_rowset_index,
	     l_row.region_list_id, l_row.region_list, l_row.region_id, l_row.region_code, l_reglist_action,
	     l_row.org_list_id, l_row.org_list, l_row.inst_id, l_row.org_id, l_row.org_code, l_orglist_action,
	     c_item.top_item_id, c_item.top_item_name, c_item.item_id, c_item.item_name, l_itemlist_action);
	end loop; --}
  end if; -- }

  msc_sda_utils.println('flushFcstHistoryRows out');
  end flushFcstHistoryRows;

  procedure SdFCSTHistoryView(p_query_id in out nocopy number,
    p_view_type number,
    p_plan_id number,
    p_org_type number, p_org_list varchar2,
    p_region_type number, p_region_list varchar2,
    p_item_list number, p_item_view_type number,
    p_refresh_view boolean default false,
    p_error_code out nocopy varchar2,
    p_item_folder number,
    p_items_data IN OUT NOCOPY msc_sda_utils.maxCharTbl,
    p_comments_data IN OUT NOCOPY msc_sda_utils.maxCharTbl,
    p_excp_data  IN OUT NOCOPY msc_sda_utils.maxCharTbl)  is

    ll_reg_list_id number;
    ll_reg_list varchar2(250);
    ll_region_id number;
    ll_region_code varchar2(250);
    ll_org_list_id number;
    ll_org_list varchar2(250);
    ll_inst_id number;
    ll_org_id number;
    ll_org_code varchar2(10);
    ll_top_item_id number;
    ll_top_item_name varchar2(250);
    ll_item_id number;
    ll_item_name varchar2(250);

    ll_reglist_action number;
    ll_orglist_action number;
    ll_itemlist_action number;
  begin
    msc_sda_utils.println('SdFCSTHistoryView in');
    msc_sda_utils.println('p_query_id - p_view_type - p_plan_id - '
        || ' p_org_type - p_org_list - p_region_type - p_region_list - '
	|| ' p_item_list - p_item_view_type - p_item_folder ');
    msc_sda_utils.println(p_query_id ||' - '|| p_view_type  ||' - '||  p_plan_id  ||' - '||
		p_org_type  ||' - '||  p_org_list   ||' - '|| p_region_type  ||' - '||  p_region_list  ||' - '||
		p_item_list  ||' - '||  p_item_view_type  ||' - '||  p_item_folder );

    g_view_type := p_view_type;
    g_plan_id := p_plan_id;

    --capture region info in global variables
    g_region_type  := p_region_type;
    g_region_list := p_region_list;

    --capture org info in global variables
    g_org_type := p_org_type;
    g_org_list := p_org_list;

    --capture item info in global variables
    g_item_list := p_item_list;
    g_item_view_type := p_item_view_type;

    setPlanInfo;
    setUserPrefInfo;

    g_row_index := 1;  --initialize row_index to 1

     if (g_view_type = c_sdview) then -- SD VIEW
        g_sd_query_id := msc_sda_utils.getNewAnalysisQueryId;

        msc_sda_utils.getOrgListValues(g_org_list, g_org_type, ll_org_list_id, ll_org_list, ll_inst_id, ll_org_id, ll_org_code);
        if (g_org_type = c_org_view) then
          ll_orglist_action := c_nodrill_state;
        else
          ll_orglist_action := c_collapsed_state;
        end if;

        msc_sda_utils.getItemListValues(g_item_list, g_item_view_type, ll_top_item_id, ll_top_item_name, ll_item_id, ll_item_name);
        g_item_list_name := ll_top_item_name;

        if (g_item_view_type = c_item_view) then
          ll_itemlist_action := c_nodrill_state;
	  msc_sda_utils.println(' item no drill state ');
        else
          ll_itemlist_action := c_collapsed_state;
	  msc_sda_utils.println(' item collapsed state ');
        end if;

        insert into msc_analysis_query
          (query_id, row_index, parent_row_index, org_list_id, org_list, inst_id, org_id, org_code,
          top_item_id, top_item_name, item_id, item_name, org_list_state, top_item_name_state)
        values (g_sd_query_id, c_first_row_index, g_next_rowset_index, ll_org_list_id, ll_org_list, ll_inst_id, ll_org_id, ll_org_code,
         ll_top_item_id, ll_top_item_name, ll_item_id, ll_item_name, ll_orglist_action, ll_itemlist_action);

        g_org_query_id := msc_sda_utils.flushOrgsIntoMfq(g_sd_query_id, g_row_index, g_org_type);
        msc_sda_utils.println('g_org_query_id '||g_org_query_id);

        g_chain_query_id := msc_sda_utils.flushChainIntoMfq(g_sd_query_id, g_plan_id,  g_item_view_type, g_item_list);
        msc_sda_utils.println('g_chain_query_id '||g_chain_query_id);

     else  -- FORECAST VIEW AND HISTORY VIEW
      g_fcst_query_id := msc_sda_utils.getNewAnalysisQueryId;
      g_hist_query_id := msc_sda_utils.getNewAnalysisQueryId;

      msc_sda_utils.getRegListValues(g_region_list, g_region_type, ll_reg_list_id, ll_reg_list, ll_region_id, ll_region_code);
      ll_reglist_action := c_collapsed_state;
      ll_orglist_action := c_collapsed_state;

        msc_sda_utils.getItemListValues(g_item_list, g_item_view_type, ll_top_item_id, ll_top_item_name, ll_item_id, ll_item_name);
        g_item_list_name := ll_top_item_name;
        if (g_item_view_type = c_item_view) then
          ll_itemlist_action := c_nodrill_state;
        else
          ll_itemlist_action := c_collapsed_state;
        end if;

      insert into msc_analysis_query
       (query_id, row_index, parent_row_index,
         region_list_id, region_list, region_id, region_code,region_list_state,
         org_list_id, org_list, inst_id, org_id, org_code, org_list_state,
         top_item_id, top_item_name, item_id, item_name, top_item_name_state)
       values (g_fcst_query_id, c_first_row_index, g_next_rowset_index,
         c_all_region_type, c_all_region_type_text, to_number(null), null, c_collapsed_state,
         c_all_org_type, c_all_org_type_text, to_number(null), to_number(null), null, c_collapsed_state,
         ll_top_item_id, ll_top_item_name, ll_item_id, ll_item_name, ll_itemlist_action);

      insert into msc_analysis_query
       (query_id, row_index, parent_row_index,
         region_list_id, region_list, region_id, region_code,region_list_state,
         org_list_id, org_list, inst_id, org_id, org_code, org_list_state,
         top_item_id, top_item_name, item_id, item_name, top_item_name_state)
       values (g_hist_query_id, c_first_row_index, g_next_rowset_index,
         c_all_region_type, c_all_region_type_text, to_number(null), null, c_collapsed_state,
         c_all_org_type, c_all_org_type_text, to_number(null), to_number(null), null, c_collapsed_state,
         ll_top_item_id, ll_top_item_name, ll_item_id, ll_item_name, ll_itemlist_action);

	--flush regions/orgs into mfq
	--flush supersession chain into mfq..pabram..this needs to be region specific
	msc_sda_utils.flushRegsOrgsIntoMfq(g_plan_id, g_region_type, g_region_list,
	g_org_type, g_org_list, g_region_query_id, g_org_query_id);

        g_chain_query_id := msc_sda_utils.flushChainIntoMfq(to_number(null), g_plan_id,  g_item_view_type, g_item_list);
        msc_sda_utils.println(' query-ids region org item '|| g_region_query_id ||' - '|| g_org_query_id ||' - '||g_chain_query_id);


        --we need to duplicate forecast rows into msc_demands, so we can get manual forecast also from one select in forecast view cursor
	g_md_dup_rows_qid := msc_sda_utils.getNewFormQueryId;

        insert into msc_form_query (query_id, creation_date, created_by, last_updated_by, last_update_date, number1, number2)
        values (g_md_dup_rows_qid, sysdate, -1, -1, sysdate, c_dmd2_net_fcst, c_dmd2_net_fcst);

        insert into msc_form_query (query_id, creation_date, created_by, last_updated_by, last_update_date, number1, number2)
        values (g_md_dup_rows_qid, sysdate, -1, -1, sysdate, c_dmd2_net_fcst, c_dmd2_manual_fcst);

        --we need to duplicate returns forecast rows into msc_supplies, so we can get returns manual forecast also from one select in forecast view cursor
	g_ms_dup_rows_qid := msc_sda_utils.getNewFormQueryId;

        insert into msc_form_query (query_id, creation_date, created_by, last_updated_by, last_update_date, number1, number2)
        values (g_ms_dup_rows_qid, sysdate, -1, -1, sysdate, c_sup2_rtns_fcst, c_sup2_rtns_fcst);

        insert into msc_form_query (query_id, creation_date, created_by, last_updated_by, last_update_date, number1, number2)
        values (g_ms_dup_rows_qid, sysdate, -1, -1, sysdate, c_sup2_rtns_fcst, c_sup2_rtns_manual_fcst);


     end if;

    msc_sda_utils.getItemsData(g_plan_id, g_org_query_id, g_chain_query_id, p_items_data);
    msc_sda_utils.getCommentsData(g_plan_id, g_chain_query_id, p_comments_data, c_sdview_comments_data);
    msc_sda_utils.getExceptionsData(g_plan_id, g_chain_query_id, g_org_query_id, p_excp_data);

    msc_sda_utils.println('query-ids sd- fcst- hist '||g_sd_query_id||'-'||g_fcst_query_id||'-'||g_hist_query_id);

    p_query_id := g_sd_query_id;
    msc_sda_utils.println('SdFCSTHistoryView out');
  end SdFCSTHistoryView;

-----
----- send apis
-----

  procedure sendSdFcstTimeBucket(p_view_type number,
    p_bucket_data IN OUT NOCOPY msc_sda_utils.maxCharTbl,
    p_week_data IN OUT NOCOPY msc_sda_utils.maxCharTbl,
    p_period_data IN OUT NOCOPY msc_sda_utils.maxCharTbl,
    p_bucket_count out nocopy number) is
    l_one_record varchar2(32000) := null;
    l_token varchar2(1000);
    l_out_data_index number := 1;
  begin
      --days
      for i in 1..g_bkt_start_date.count
      loop
         l_token := g_bkt_type(i) || c_field_seperator || to_char(g_bkt_start_date(i), c_date_format);
         if (l_one_record is null) then
	  if (p_view_type = c_sdview) then
            l_one_record := c_sdview_bucket_data || c_bang_separator || g_bkt_start_date.count || c_record_seperator || l_token;
	  elsif (p_view_type = c_fcstview) then
            l_one_record := c_fcstview_bucket_data || c_bang_separator || g_bkt_start_date.count || c_record_seperator || l_token;
	  end if;
	else
          l_one_record := c_record_seperator || l_token;
	end if;
        msc_sda_utils.addToOutStream(l_one_record, l_out_data_index, p_bucket_data);
      end loop;

    --weeks
     l_one_record := null;
     l_out_data_index := 1;
      for i in 1..g_week_start_dates.count
      loop
         l_token := to_char(g_week_start_dates(i), c_date_format);
         if (l_one_record is null) then
	  if (p_view_type = c_sdview) then
            l_one_record := c_sdview_week_data || c_bang_separator || g_week_start_dates.count || c_record_seperator || l_token;
       	  elsif (p_view_type = c_fcstview) then
            l_one_record := c_fcstview_week_data || c_bang_separator || g_week_start_dates.count || c_record_seperator || l_token;
	  end if;
	else
          l_one_record := c_record_seperator || l_token;
	end if;
        msc_sda_utils.addToOutStream(l_one_record, l_out_data_index, p_week_data);
      end loop;

    --periods
     l_one_record := null;
     l_out_data_index := 1;
      for i in 1..g_period_start_dates.count
      loop
         l_token := to_char(g_period_start_dates(i), c_date_format);
         if (l_one_record is null) then
	  if (p_view_type = c_sdview) then
            l_one_record := c_sdview_period_data || c_bang_separator || g_period_start_dates.count || c_record_seperator || l_token;
       	  elsif (p_view_type = c_fcstview) then
            l_one_record := c_fcstview_period_data || c_bang_separator || g_period_start_dates.count || c_record_seperator || l_token;
	  end if;
	else
          l_one_record := c_record_seperator || l_token;
	end if;
        msc_sda_utils.addToOutStream(l_one_record, l_out_data_index, p_period_data);
      end loop;

      if (p_view_type = c_sdview) then
        g_sd_num_of_buckets := g_num_of_buckets;
        p_bucket_count := g_sd_num_of_buckets;
      elsif (p_view_type = c_fcstview) then
        g_fcst_num_of_buckets := g_num_of_buckets;
        p_bucket_count := g_fcst_num_of_buckets;
      end if;
  end sendSdFcstTimeBucket;

  procedure sentHistTimeBucket(p_start_date date, p_end_date date,
    p_bucket_data IN OUT NOCOPY msc_sda_utils.maxCharTbl, p_bucket_count out nocopy number) is

    cursor c_hist_date_cur is
    select date1
    from msc_form_query
    where query_id = g_hist_cal_query_id
    order by 1;

    cursor c_hist_date_count_cur is
    select count(*)
    from msc_form_query
    where query_id = g_hist_cal_query_id;
    l_count number;
    l_out_data_index number := 1;
    l_one_record varchar2(2000) := null;
    l_token varchar2(2000);
  begin
    g_hist_cal_query_id := msc_sda_utils.createHistCalInMfq(g_pref_hist_start_date, g_plan_start_date);

    open c_hist_date_count_cur;
    fetch c_hist_date_count_cur into l_count;
    close c_hist_date_count_cur;

    l_one_record := null;
    l_out_data_index := 1;
    for c_hist_date in c_hist_date_cur
    loop
         l_token := to_char(c_hist_date.date1, c_date_format);
         if (l_one_record is null) then
            l_one_record := c_histview_bucket_data || c_bang_separator || l_count || c_record_seperator || l_token;
	else
          l_one_record := c_record_seperator || l_token;
	end if;
        msc_sda_utils.addToOutStream(l_one_record, l_out_data_index, p_bucket_data);
    end loop;
    p_bucket_count := l_count;
  end sentHistTimeBucket;

  procedure sendTimeBucket(p_view_type number,
    p_bucket_data IN OUT NOCOPY msc_sda_utils.maxCharTbl,
    p_week_data IN OUT NOCOPY msc_sda_utils.maxCharTbl,
    p_period_data IN OUT NOCOPY msc_sda_utils.maxCharTbl) is
  begin
    if (p_view_type = c_sdview) then
      sendSdFcstTimeBucket(p_view_type, p_bucket_data, p_week_data, p_period_data, g_sd_num_of_buckets);
    elsif (p_view_type = c_fcstview) then
      sendSdFcstTimeBucket(p_view_type, p_bucket_data, p_week_data, p_period_data, g_fcst_num_of_buckets);
    elsif (p_view_type = c_histview) then
      sentHistTimeBucket(g_pref_hist_start_date, g_plan_start_date, p_bucket_data, g_hist_num_of_buckets);
    end if;
    msc_sda_utils.println('g_hist_cal_query_id '||g_hist_cal_query_id);
  end sendTimeBucket;

  procedure sendTimeBucketEng(p_plan_id number, p_view_type number,
    p_bucket_data IN OUT NOCOPY msc_sda_utils.maxCharTbl,
    p_week_data IN OUT NOCOPY msc_sda_utils.maxCharTbl,
    p_period_data IN OUT NOCOPY msc_sda_utils.maxCharTbl) is
  begin
    g_view_type := p_view_type;
    g_plan_id := p_plan_id;
    setPlanInfo;
    setUserPrefInfo;
    sendTimeBucket(p_view_type, p_bucket_data, p_week_data, p_period_data);
  end sendTimeBucketEng;


  procedure sendRows(p_view_type number, p_query_id number, p_row_index number, p_parent_row_index number,
    p_rheader_data in out nocopy msc_sda_utils.maxCharTbl) is

    l_out_data_index number := 1;
    l_one_record varchar2(2000) := null;
    l_token varchar2(2000);
    l_token1 varchar2(2000);
    l_token2 varchar2(2000);
    l_count number;

    l_org_list_id number;
    l_org_list varchar2(200);
    l_org_list_state number;
    l_inst_id number;
    l_org_id number;
    l_org_code varchar2(100);
  begin
    msc_sda_utils.println('sendRows in ');
      open c_child_row_count(p_query_id, g_next_rowset_index);
      fetch c_child_row_count into l_count;
      close c_child_row_count;

      for c_child_row in c_row_values_cur(p_query_id, to_number(null), g_next_rowset_index)
      loop
        l_org_list_id := c_child_row.org_list_id;
        l_org_list := c_child_row.org_list;
        l_org_list_state := c_child_row.org_list_state;
        l_inst_id := c_child_row.inst_id;
        l_org_id := c_child_row.org_id;
        l_org_code := c_child_row.org_code;

	--6736491 bugfix, global will also contain orgs now
/*
	if (p_view_type = c_fcstview and c_child_row.region_id = c_global_reg_type) then
          l_org_list_id := c_mbp_null_value;
          l_org_list := c_null_space;
          l_org_list_state := c_nodrill_state;
          l_inst_id := null;
          l_org_id := null;
          l_org_code := null;
	end if;
*/
	l_token := to_char(c_child_row.row_index);
	l_token1 := c_field_seperator || nvl(to_char(c_child_row.region_list_id), c_null_space)
          || c_field_seperator || nvl(to_char(c_child_row.region_list), c_null_space)
          || c_field_seperator || nvl(to_char(c_child_row.region_list_state), c_null_space)
          || c_field_seperator || nvl(to_char(c_child_row.region_id), c_null_space)
          || c_field_seperator || nvl(to_char(c_child_row.region_code), c_null_space);
	l_token2 := c_field_seperator || nvl(to_char(l_org_list_id), c_null_space)
          || c_field_seperator || nvl(l_org_list, c_null_space)
          || c_field_seperator || nvl(to_char(l_org_list_state), c_null_space)
          || c_field_seperator || nvl(to_char(l_inst_id), c_null_space)
          || c_field_seperator || nvl(to_char(l_org_id), c_null_space)
          || c_field_seperator || nvl(l_org_code, c_null_space)
          || c_field_seperator || nvl(to_char(c_child_row.top_item_id), c_null_space)
          || c_field_seperator || nvl(c_child_row.top_item_name, c_null_space)
          || c_field_seperator || nvl(to_char(c_child_row.top_item_name_state), c_null_space)
          || c_field_seperator || nvl(to_char(c_child_row.item_id), c_null_space)
          || c_field_seperator || nvl(c_child_row.item_name, c_null_space);

        if (g_view_type = c_sdview) then
	  l_token := l_token || l_token2;
        elsif (p_view_type = c_fcstview) then
	  l_token := l_token || l_token1 || l_token2;
        elsif (p_view_type = c_histview) then
	  l_token := l_token || l_token1 || l_token2;
	end if;

	 if (l_one_record is null) then
	  if (p_view_type = c_sdview) then
	    l_one_record := c_sdview_rheader_data || c_bang_separator || l_count || c_record_seperator || l_token;
	  elsif (p_view_type = c_fcstview) then
	    l_one_record := c_fcstview_rheader_data || c_bang_separator || l_count || c_record_seperator || l_token;
	  elsif (p_view_type = c_histview) then
	    l_one_record := c_histview_rheader_data || c_bang_separator || l_count || c_record_seperator || l_token;
	  end if;
	else
          l_one_record := c_record_seperator || l_token;
	end if;
        msc_sda_utils.addToOutStream(l_one_record, l_out_data_index, p_rheader_data);
      end loop;
    msc_sda_utils.println('sendRows out');
  end sendRows;

  procedure sendSDData(p_row_index number,
    p_orglist_action number, p_itemlist_action number, p_action_node number,
    p_rheader_data in out nocopy msc_sda_utils.maxCharTbl,
    p_out_data in out nocopy msc_sda_utils.maxCharTbl) is
  begin
      --flushs msc_analysis_query with row_header_information
      flushSDRows(g_sd_query_id, p_row_index, p_orglist_action, p_itemlist_action, p_action_node);

      if ( p_orglist_action = c_expanded_state or p_itemlist_action = c_expanded_state ) then
         sendRows(c_sdview, g_sd_query_id, null, p_row_index, p_rheader_data);
         flushAndSendData(c_sdview, g_sd_query_id, p_out_data);
      else
         sendRows(c_sdview, g_sd_query_id, p_row_index, null, p_rheader_data);
         flushAndSendData(c_sdview, g_sd_query_id, p_out_data);
      end if;
      --p_out_data := msc_sda_utils.maxCharTbl(0); --pabram..testing purpose only..need to remove later
  end sendSDData;

  procedure sendFCSTHistoryData(p_view_type number, p_row_index number,
    p_reglist_action number, p_orglist_action number, p_itemlist_action number, p_action_node number,
    p_rheader_data in out nocopy msc_sda_utils.maxCharTbl,
    p_out_data in out nocopy msc_sda_utils.maxCharTbl,
    p_out_data2 in out nocopy msc_sda_utils.maxCharTbl) is

    l_query_id number;
  begin
      if (p_view_type =  c_fcstview) then
        l_query_id := g_fcst_query_id;
      elsif (p_view_type =  c_histview) then
        l_query_id := g_hist_query_id;
      end if;
      --flushes msc_analysis_query with row_header_information
      flushFcstHistoryRows(p_view_type, l_query_id, p_row_index, p_reglist_action, p_orglist_action, p_itemlist_action, p_action_node);

      if ( p_reglist_action = c_expanded_state or p_orglist_action = c_expanded_state or p_itemlist_action = c_expanded_state ) then
         sendRows(p_view_type, l_query_id, null, p_row_index, p_rheader_data);
         flushAndSendData(p_view_type, l_query_id, p_out_data);
      else
         sendRows(p_view_type, l_query_id, p_row_index, null, p_rheader_data);
         flushAndSendData(p_view_type, l_query_id, p_out_data);
      end if;

      if ( p_view_type =  c_fcstview and p_row_index = c_first_row_index and p_reglist_action = c_expanded_state) then
        flushAndSendAddlData(p_view_type, l_query_id, p_out_data2);
      end if;

      --delete from msc_analysis_query_temp; insert into msc_analysis_query_temp select * from msc_analysis_query; commit;
      --delete from msc_form_query_temp; insert into msc_form_query_temp select * from msc_form_query; commit;
  end sendFCSTHistoryData;

  procedure sendRowTypes(p_sd_data IN OUT NOCOPY msc_sda_utils.maxCharTbl,
    p_fcst_data IN OUT NOCOPY msc_sda_utils.maxCharTbl,
    p_hist_data IN OUT NOCOPY msc_sda_utils.maxCharTbl) is
  begin
      msc_sda_utils.sendSDRowTypes(p_sd_data);
      msc_sda_utils.sendFcstRowTypes(p_fcst_data);
      msc_sda_utils.sendHistRowTypes(p_hist_data);
  end sendRowTypes;

  procedure getWorkSheetPrefData(p_out_data IN OUT NOCOPY msc_sda_utils.maxCharTbl, p_refresh_flag number) is
  begin
    msc_sda_utils.getWorkSheetPrefData(p_out_data, p_refresh_flag);
  end getWorkSheetPrefData;

  procedure sendNlsMessages(p_out_data IN OUT NOCOPY msc_sda_utils.maxCharTbl) is
  begin
    msc_sda_utils.sendNlsMessages(p_out_data);
  end sendNlsMessages;

  procedure spreadTableMessages(p_out_data in out nocopy msc_sda_utils.maxCharTbl) is
  begin
    msc_sda_utils.spreadTableMessages(p_out_data);
  end spreadTableMessages;

  procedure set_shuttle_from_to(p_lookup_type varchar2, p_lookup_code_list varchar2,
    p_from_list out nocopy varchar2, p_to_list out nocopy varchar2) is
  begin
    msc_sda_utils.set_shuttle_from_to(p_lookup_type, p_lookup_code_list, p_from_list, p_to_list);
  end set_shuttle_from_to;

  procedure update_pref_set (p_name varchar2, p_desc varchar2,
    p_days number, p_weeks number, p_periods number,
    p_factor number, p_decimal_places number,
    p_sd_row_list varchar2, p_fcst_row_list varchar2) is
  begin
    msc_sda_utils.update_pref_set(p_name, p_desc, p_days, p_weeks, p_periods,
      p_factor, p_decimal_places, p_sd_row_list, p_fcst_row_list);
  end update_pref_set;

  procedure save_item_folder(p_folder_name varchar, p_folder_value varchar,
    p_default_flag number, p_public_flag number) is
  begin
    msc_sda_utils.save_item_folder(p_folder_name, p_folder_value,
      p_default_flag, p_public_flag);
  end save_item_folder;

  procedure update_close_settings (p_event varchar2, p_event_list varchar2) is
  begin
    msc_sda_utils.update_close_settings(p_event, p_event_list);
  end update_close_settings;

  procedure send_close_settings(p_item_folder_save_list out nocopy varchar2,
    p_save_settings_list out nocopy varchar2) is
  begin
    msc_sda_utils.send_close_settings(p_item_folder_save_list, p_save_settings_list);
  end send_close_settings;

  procedure getCommentsData(p_out_data in out nocopy msc_sda_utils.maxCharTbl) is
  begin
    msc_sda_utils.getCommentsData(g_plan_id, g_chain_query_id, p_out_data, c_sdview_comments_data_ref);
  end getCommentsData;

  procedure getRegionList(p_out_data out nocopy varchar2) is
   cursor c_regions_cur is
   select distinct
     number2 region_id
   from msc_form_query
   where query_id = g_region_query_id;
  begin
    for c_regions in c_regions_cur
    loop
      if p_out_data is null then
        p_out_data := to_char(c_regions.region_id);
      else
	p_out_data := p_out_data || c_comma_separator|| to_char(c_regions.region_id);
      end if;
    end loop;
  end getRegionList;

  procedure getOrgList(p_out_data out nocopy varchar2) is
   cursor c_orgs_cur is
   select distinct
     '('||number2||','||number3||')' org_id
   from msc_form_query
   where query_id = g_org_query_id
     and number2 is not null
     and number3 is not null;
  begin
    for c_orgs in c_orgs_cur
    loop
      if p_out_data is null then
        p_out_data := to_char(c_orgs.org_id);
      else
	p_out_data := p_out_data || c_comma_separator|| to_char(c_orgs.org_id);
      end if;
    end loop;
  end getOrgList;

  procedure getItemList(p_out_data out nocopy varchar2) is
   cursor c_items_cur is
   select distinct
     number2 item_id
   from msc_form_query
   where query_id = g_chain_query_id;
  begin
    for c_items in c_items_cur
    loop
      if p_out_data is null then
        p_out_data := to_char(c_items.item_id);
      else
	p_out_data := p_out_data || c_comma_separator|| to_char(c_items.item_id);
      end if;
    end loop;
  end getItemList;

  procedure getOrderTypesList(p_view_type number, p_row_offset number,
    p_order_type_list out nocopy varchar2, p_from_table out nocopy varchar2,
    p_part_condition out nocopy number) is
  begin
    if (p_view_type = c_histview) then --{
      p_from_table := 'msc_demands';
      if (p_row_offset = c_row_returns_hist) then
        p_order_type_list := c_returns_hist;
      elsif (p_row_offset = c_row_dmd_hist) then
        p_order_type_list := c_dmd_hist;
      end if;
      return;
    end if; --}

    if (p_view_type = c_fcstview) then --{
        if (p_row_offset = c_row2_total_fcst) then
          p_from_table := 'msc_demands';
          p_order_type_list := to_char(c_dmd2_net_fcst) ||','|| to_char(c_dmd2_dmd_schd);
	elsif (p_row_offset = c_row2_orig_fcst) then
          p_from_table := 'msc_demands';
          p_order_type_list := c_dmd2_net_fcst;
        elsif (p_row_offset = c_row2_consumed_fcst) then
         p_from_table := 'msc_forecast_updates';
         p_order_type_list := null;
        elsif (p_row_offset = c_row2_net_fcst) then
          p_from_table := 'msc_demands';
          p_order_type_list := c_dmd2_net_fcst;
        elsif (p_row_offset = c_row2_over_consmptn) then
         p_from_table := 'msc_forecast_updates';
         p_order_type_list := null;
        elsif (p_row_offset = c_row2_manual_fcst) then
          p_from_table := 'msc_demands';
          p_order_type_list := c_dmd2_net_fcst;
	elsif (p_row_offset = c_row2_dmd_schd) then
          p_from_table := 'msc_demands';
          p_order_type_list := c_dmd2_dmd_schd;
        elsif (p_row_offset = c_row2_bestfit_fcst) then
          p_from_table := 'msc_demands';
          p_order_type_list := c_dmd2_bestfit_fcst;
        elsif (p_row_offset = c_row2_total_ret_fcst) then
          p_from_table := 'msc_supplies';
          p_order_type_list := to_char(c_sup2_rtns_fcst) ||','|| to_char(c_sup2_rtns_dmd_schd);
        elsif (p_row_offset = c_row2_ret_fcst) then
          p_from_table := 'msc_supplies';
          p_order_type_list := c_sup2_rtns_fcst;
        elsif (p_row_offset = c_row2_ret_dmd_schd) then
          p_from_table := 'msc_supplies';
          p_order_type_list := c_sup2_rtns_dmd_schd;
	elsif (p_row_offset = c_row2_ret_manual_fcst) then
          p_from_table := 'msc_supplies';
          p_order_type_list := c_sup2_rtns_fcst;
        elsif (p_row_offset = c_row2_ret_bestfit_fcst) then
          p_from_table := 'msc_supplies';
          p_order_type_list := c_sup2_rtns_bestfit_fcst;
	elsif (p_row_offset = c_row2_usage_fcst) then
          p_from_table := 'msc_demands';
          p_order_type_list := c_dmd2_usage_fcst;
        elsif (p_row_offset = c_row2_popultn_fcst) then
          p_from_table := 'msc_demands';
          p_order_type_list := c_dmd2_popu_fcst;
        elsif (p_row_offset = c_row2_type_16) then
          p_from_table := 'msc_demands';
          p_order_type_list := c_dmd2_popu_fcst;
        end if;
	return;
    end if; --}

    if (p_view_type = c_sdview) then --{
      if (p_row_offset = c_row_net_fcst) then --1;
        p_from_table := 'msc_demands';
	p_order_type_list := c_dmd_fcst;
      elsif (p_row_offset = c_row_so) then --2;
        p_from_table := 'msc_demands';
	p_order_type_list := to_char(c_dmd_so) ||', '|| to_char(c_dmd_so_mds);
      elsif (p_row_offset = c_row_iso_field_org) then --3;
        p_from_table := 'msc_demands';
	p_order_type_list := to_char(c_dmd_so) ||', '|| to_char(c_dmd_so_mds);
      elsif (p_row_offset = c_row_indepndt_dmd) then --4;
        p_from_table := 'msc_demands';
	p_order_type_list := to_char(c_dmd_fcst) ||', '|| to_char(c_dmd_so) ||', '|| to_char(c_dmd_so_mds);
      elsif (p_row_offset = c_row_iso) then --5;
        p_from_table := 'msc_demands';
	p_order_type_list := to_char(c_dmd_so) ||', '|| to_char(c_dmd_so_mds);
      elsif (p_row_offset = c_row_pod) then --6;
        p_from_table := 'msc_demands';
	p_order_type_list := c_dmd_pod;
      elsif (p_row_offset = c_row_dependnt_dmd) then --7;
        p_from_table := 'msc_demands';
	p_order_type_list := to_char(c_dmd_pod);
      elsif (p_row_offset = c_row_other_dmd) then --8;
        p_from_table := 'msc_demands';
	p_order_type_list := to_char(c_dmd_mps) ||', '|| to_char(c_dmd_manual_mds);
      elsif (p_row_offset = c_row_total_dmd) then --9;
        p_from_table := 'msc_demands';
	p_order_type_list := to_char(c_dmd_fcst) ||', '|| to_char(c_dmd_so) ||', '|| to_char(c_dmd_so_mds)
	  ||', '|| to_char(c_dmd_pod)
	  ||', '|| to_char(c_dmd_mps) ||', '|| to_char(c_dmd_manual_mds);
      elsif (p_row_offset = c_row_onhand) then --10;
        p_from_table := 'msc_supplies';
	p_order_type_list := c_sup_onhand;
      elsif (p_row_offset = c_row_transit) then --11;
        p_from_table := 'msc_supplies';
	p_order_type_list := c_sup_intrnst_shpmt;
      elsif (p_row_offset = c_row_receiving) then --12;
        p_from_table := 'msc_supplies';
	p_order_type_list := c_sup_intrnst_rec;
      elsif (p_row_offset = c_row_new_buy_po) then --13;
        p_from_table := 'msc_supplies';
	p_order_type_list := c_sup_new_buy_po;
      elsif (p_row_offset = c_row_new_buy_po_req) then --14;
        p_from_table := 'msc_supplies';
	p_order_type_list := c_sup_new_buy_po_req;
      elsif (p_row_offset = c_row_intrnl_rpr_ordr) then --15;
        p_from_table := 'msc_supplies';
	p_order_type_list := to_char(c_sup_intrnl_rpr_ordr);
      elsif (p_row_offset = c_row_xtrnl_rpr_ordr) then --16;
        p_from_table := 'msc_supplies';
	p_order_type_list := to_char(c_sup_xtrnl_rpr_ordr)||', '|| to_char(c_sup_ext_rep_req);
      elsif (p_row_offset = c_row_inbnd_ship) then --17;
        p_from_table := 'msc_supplies';
	p_order_type_list := c_sup_new_buy_po_req;
      elsif (p_row_offset = c_row_rpr_wo) then --18;
        p_from_table := 'msc_supplies';
	p_order_type_list := c_sup_rpr_wo ||', '|| to_char(c_sup_rpr_wo_ext_rep_supp) ;
      elsif (p_row_offset = c_row_plnd_new_buy_ordr) then --19;
        p_from_table := 'msc_supplies';
	p_order_type_list := c_sup_plnd_new_buy_ordr;
      elsif (p_row_offset = c_row_plnd_intrnl_rpr_ordr) then --20;
        p_from_table := 'msc_supplies';
	p_order_type_list := c_sup_plnd_intrnl_rpr_ordr;
      elsif (p_row_offset = c_row_plnd_xtrnl_rpr_ordr) then --21;
        p_from_table := 'msc_supplies';
	p_order_type_list := c_sup_plnd_xtrnl_rpr_ordr;
      elsif (p_row_offset = c_row_plnd_inbnd_ship) then --22;
        p_from_table := 'msc_supplies';
	p_order_type_list := c_sup_plnd_inbnd_ship;
      elsif (p_row_offset = c_row_plnd_rpr_wo) then --23;
        p_from_table := 'msc_supplies';
	p_order_type_list := c_sup_plnd_rpr_wo;
      elsif (p_row_offset = c_row_plnd_warr_ordr) then --24;
        p_from_table := null;
	p_order_type_list := null;
      elsif (p_row_offset = c_row_total_supply) then --25;
        p_from_table := 'msc_supplies';
	p_order_type_list := to_char(c_sup_intrnst_shpmt) ||','|| to_char(c_sup_intrnst_rec) ||','|| to_char(c_sup_new_buy_po) ||','||
	  to_char(c_sup_new_buy_po_req) ||','|| to_char(c_sup_intrnl_rpr_ordr) ||','|| to_char(c_sup_xtrnl_rpr_ordr) ||','||
	  to_char(c_sup_rpr_wo) ||','|| to_char(c_row_plnd_new_buy_ordr) ||','|| to_char(c_sup_plnd_intrnl_rpr_ordr) ||','||
	  to_char(c_sup_plnd_xtrnl_rpr_ordr)  ||','|| to_char(c_sup_plnd_inbnd_ship)  ||','|| to_char(c_sup_plnd_rpr_wo)
	  ||','|| to_char(c_sup_plnd_new_buy_ordr) ||','|| to_char(c_sup_onhand)
	  ||','|| to_char(c_sup_rpr_wo) ||', '|| to_char(c_sup_rpr_wo_ext_rep_supp) ||', '|| to_char(c_sup_ext_rep_req);
      elsif (p_row_offset = c_row_ss_supply) then --26;
        p_from_table := null;
	p_order_type_list :=  '-1';
      --elsif (p_row_offset = c_row_total_uncons_dmd) then --27;
        --p_from_table := null;
	--p_order_type_list :=  '-1';
      elsif (p_row_offset = c_row_ss_level) then --28;
        p_from_table := null;
	p_order_type_list :=  '-1';
      elsif (p_row_offset = c_row_target_level) then --29;
        p_from_table := 'msc_demands';
	p_order_type_list := c_dmd_fcst;
        p_part_condition := c_part_good;
      elsif (p_row_offset = c_row_max_level) then --30;
        p_from_table := null;
	p_order_type_list :=  '-1';
      elsif (p_row_offset = c_row_pab) then --31;
        p_from_table := 'msc_orders_v';
	p_order_type_list := c_mbp_null_value;
        p_part_condition := c_part_good;
      elsif (p_row_offset = c_row_poh) then --32;
        p_from_table := 'msc_orders_v';
	p_order_type_list := c_mbp_null_value;
        p_part_condition := c_part_good;
      elsif (p_row_offset = c_row_defc_iso) then --33;
        p_from_table := 'msc_demands';
	p_order_type_list := c_dmd_defc_iso;
        p_part_condition := c_part_bad;
      elsif (p_row_offset = c_row_plnd_defc_pod) then --34;
        p_from_table := 'msc_demands';
	p_order_type_list := c_dmd_defc_pod;
        p_part_condition := c_part_bad;
      elsif (p_row_offset = c_row_defc_part_dmd) then --35;
        p_from_table := 'msc_demands';
	p_order_type_list := to_char(c_dmd_defc_part_dmd)||','||to_char(c_dmd_defc_plnd_part_dmd);
        p_part_condition := c_part_bad;
      elsif (p_row_offset = c_row_total_defc_part_dmd) then --36;
        p_from_table := 'msc_demands';
	p_order_type_list := to_char(c_dmd_defc_part_dmd)||','||to_char(c_dmd_defc_plnd_part_dmd);
        p_part_condition := c_part_bad;
      elsif (p_row_offset = c_row_defc_onhand) then --37;
        p_from_table := 'msc_supplies';
	p_order_type_list := c_sup_defc_onhand;
        p_part_condition := c_part_bad;
      elsif (p_row_offset = c_row_returns) then --38;
        p_from_table := 'msc_supplies';
	p_order_type_list := c_sup_defc_returns;
        p_part_condition := c_part_bad;
      elsif (p_row_offset = c_row_defc_inbnd_ship) then --39;
        p_from_table := 'msc_supplies';
	p_order_type_list := c_sup_defc_inbnd_ship;
        p_part_condition := c_part_bad;
      elsif (p_row_offset = c_row_defc_plnd_inbnd_ship) then --40;
        p_from_table := 'msc_supplies';
	p_order_type_list := c_sup_defc_plnd_inbnd_ship;
        p_part_condition := c_part_bad;
      elsif (p_row_offset = c_row_defc_transit) then --41;
        p_from_table := 'msc_supplies';
	p_order_type_list := c_sup_defc_transit;
        p_part_condition := c_part_bad;
      elsif (p_row_offset = c_row_defc_rec) then --42;
        p_from_table := 'msc_supplies';
	p_order_type_list := c_sup_defc_rec;
        p_part_condition := c_part_bad;
      elsif (p_row_offset = c_row_total_defc_supply) then --43;
        p_from_table := 'msc_supplies';
	p_order_type_list := to_char(c_sup_defc_returns) ||','|| to_char(c_sup_defc_inbnd_ship) ||','|| to_char(c_sup_defc_onhand)
	  ||','|| to_char(c_row_defc_plnd_inbnd_ship) ||','|| to_char(c_sup_defc_transit) ||','|| to_char(c_sup_defc_rec);
        p_part_condition := c_part_bad;
      elsif (p_row_offset = c_row_defc_pab) then --44;
        p_from_table := 'msc_orders_v';
	p_order_type_list := c_mbp_null_value;
        p_part_condition := c_part_bad;
      end if;

    end if; -- }

    return;
  end getOrderTypesList;

  procedure getDrillDownDetails(p_view_type number, p_row_index number, p_row_offset number,
    p_date1 varchar2, p_date2 varchar2, p_from_table out nocopy varchar2, p_mfq_id out nocopy number) is
    l_row c_row_values_cur%rowtype;
    l_query_id number;
    l_order_type_list varchar2(1000);

    l_reg_id_list varchar2(1000);
    l_org_id_list varchar2(1000);
    l_item_id_list varchar2(1000);
    sql_stmt varchar2(10000);

    l_date1 date;
    l_date2 date;
    l_part_condition number;
  begin
    msc_sda_utils.println(' getDrillDownDetails in');

    l_date1 := to_date(p_date1,c_date_format);
    l_date2 := to_date(p_date2,c_date_format);

    l_query_id := getAnalysisQueryId(p_view_type);
    open c_row_values_cur(l_query_id, p_row_index, to_number(null));
    fetch c_row_values_cur into l_row;
    close c_row_values_cur;

    if l_row.region_id is null then
      --getRegionList(l_reg_id_list);
      if ( l_row.region_list_id = c_all_region_type) then
        l_reg_id_list  := ' and 1=1 ';
      end if;
    else
      l_reg_id_list := l_row.region_id;
      if ( l_row.region_id = c_global_reg_type) then
        l_reg_id_list  := ' and organization_id in ('|| c_global_org_id ||') ';
      elsif ( l_row.region_id = c_local_reg_type) then
        l_reg_id_list  := ' and zone_id is null ';
      else
        l_reg_id_list  := ' and zone_id in ('|| l_reg_id_list ||') ';
      end if;
    end if;

    if (l_row.inst_id is null) then
      getOrgList(l_org_id_list);
    else
      l_org_id_list := '('||l_row.inst_id||','||l_row.org_id||')';
    end if;

    if (l_row.item_id is null) then
      getItemList(l_item_id_list);
    else
      l_item_id_list := l_row.item_id;
    end if;

    getOrderTypesList(p_view_type, p_row_offset , l_order_type_list, p_from_table, l_part_condition);
/*    if (l_part_condition is null) then
      l_part_condition := c_part_good;
    end if;
*/
    if (p_from_table  = 'msc_forecast_updates')  then
      return;
    end if;

    p_mfq_id := msc_sda_utils.getNewFormQueryId;
    sql_stmt := 'insert into msc_form_query ('||
      ' query_id, last_update_date, last_updated_by, creation_date, created_by,number1) '||
      ' select distinct '|| p_mfq_id ||', sysdate, 1,  sysdate, 1, ';

    if (p_from_table = 'msc_supplies') then
      sql_stmt := sql_stmt || ' transaction_id from '|| p_from_table;
    elsif (p_from_table in ('msc_demands', 'msc_forecast_updates') ) then
      sql_stmt := sql_stmt || ' demand_id from '|| p_from_table;
    elsif (p_from_table = 'msc_orders_v') then
      sql_stmt := sql_stmt || ' transaction_id from '|| p_from_table;
    end if;

    sql_stmt := sql_stmt || ' where plan_id = '||g_plan_id ;
    if (l_reg_id_list is not null) then
      sql_stmt := sql_stmt || l_reg_id_list ; --special handling for region
    end if;
    if (l_org_id_list is not null) then
      if l_row.region_id = c_global_reg_type then
         null;
      else
        sql_stmt := sql_stmt || ' and (sr_instance_id,organization_id) in ('|| l_org_id_list ||') ';
      end if;
    end if;
    if (l_item_id_list is not null) then
      sql_stmt := sql_stmt || ' and inventory_item_id in ('|| l_item_id_list ||') ';
    end if;

    if (p_from_table = 'msc_supplies') then
      sql_stmt := sql_stmt || ' and order_type in ('|| l_order_type_list ||')';
      sql_stmt := sql_stmt || ' and trunc(new_schedule_date) between trunc(:l_date1) and  trunc(:l_date2) ';
      sql_stmt := sql_stmt || ' and nvl(item_type_id, '||c_part_cond_id ||')= '|| c_part_cond_id ;
        if l_part_condition is not null then
        	sql_stmt := sql_stmt||' and nvl(item_type_value, '|| c_part_good ||' )= '|| l_part_condition ;
        end if;

      msc_sda_utils.println('msc_supplies '||sql_stmt);
      execute immediate sql_stmt using l_date1, l_date2;
    elsif (p_from_table in ('msc_demands', 'msc_forecast_updates') ) then
      sql_stmt := sql_stmt || ' and origination_type in ('|| l_order_type_list ||')';
      sql_stmt := sql_stmt || ' and trunc(using_assembly_demand_date) between trunc(:l_date1) and  trunc(:l_date2) ';
      sql_stmt := sql_stmt || ' and nvl(item_type_id, '||c_part_cond_id ||')= '|| c_part_cond_id ;
        if l_part_condition is not null then
        	sql_stmt := sql_stmt||' and nvl(item_type_value, '|| c_part_good ||' )= '|| l_part_condition ;
        end if;

      if (p_view_type = c_sdview) then
        if (p_row_offset = c_row_so) then
          sql_stmt := sql_stmt || ' and disposition_id is null ';
        elsif (p_row_offset = c_row_iso_field_org) then
          sql_stmt := sql_stmt || ' and disposition_id is not null ';
        elsif (p_row_offset = c_row_iso) then
          sql_stmt := sql_stmt || ' and disposition_id is not null ';
	end if;
      end if;

      msc_sda_utils.println('msc_demands, msc_forecast_updates '||sql_stmt);
      execute immediate sql_stmt using l_date1, l_date2;
    elsif (p_from_table = 'msc_orders_v') then
      sql_stmt := sql_stmt || ' and nvl(item_type_id, '||c_part_cond_id ||')= '|| c_part_cond_id ;
          if l_part_condition is not null then
        	sql_stmt := sql_stmt||' and nvl(item_type_value, '|| c_part_good ||' )= '|| l_part_condition ;
        end if;
      if (l_order_type_list = c_mbp_null_value) then
        sql_stmt := sql_stmt || ' and trunc(new_due_date) <= trunc(:l_date2) ';

        msc_sda_utils.println('msc_orders_v '||sql_stmt);
        execute immediate sql_stmt using l_date2;
      else
        sql_stmt := sql_stmt || ' and order_type in ('|| l_order_type_list ||')';
        sql_stmt := sql_stmt || ' and trunc(new_due_date) between trunc(:l_date1) and  trunc(:l_date2) ';
        msc_sda_utils.println('msc_orders_v 2 '||sql_stmt);
        execute immediate sql_stmt using l_date1, l_date2;
      end if;
    else
      msc_sda_utils.println(' getDrillDownDetails error: p_from_table is null');
      return;
    end if;
    msc_sda_utils.println('out '||sql_stmt);
    msc_sda_utils.println(' getDrillDownDetails out');
  end getDrillDownDetails;

-----
----- send apis done
-----

  function populateSupersessionChain(p_plan number, p_item number) return number is
    l_query_id number;
  begin
    l_query_id := msc_sda_utils.flushSupersessionChain(p_plan, p_item);
    return l_query_id;
  end populateSupersessionChain;
end MSC_SDA_PKG;

/
