--------------------------------------------------------
--  DDL for Package MSC_SDA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_SDA_PKG" AUTHID CURRENT_USER as
/* $Header: MSCSDAPS.pls 120.12 2008/03/13 23:18:43 pabram noship $ */

  -- p_view_type - 1 sdview, 2 fcst view
  -- p_plan_id - plan_id
  -- p_region_type - 1 region_list, 2 region_id
  -- p_org_type - 1 org_list, 2 org_id
  -- p_org_list - org_list_id, (inst_id-org-id)
  -- p_item_id - inventory_item_id
  -- p_item_view_type - 1 item, 2 prime, 3 supersession
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
    p_excp_data  IN OUT NOCOPY msc_sda_utils.maxCharTbl) ;

  procedure sendSDData(p_row_index number,
    p_orglist_action number, p_itemlist_action number, p_action_node number,
    p_rheader_data in out nocopy msc_sda_utils.maxCharTbl,
    p_out_data in out nocopy msc_sda_utils.maxCharTbl);

  procedure sendTimeBucket(p_view_type number,
    p_bucket_data IN OUT NOCOPY msc_sda_utils.maxCharTbl,
    p_week_data IN OUT NOCOPY msc_sda_utils.maxCharTbl,
    p_period_data IN OUT NOCOPY msc_sda_utils.maxCharTbl);

  procedure sendRowTypes(p_sd_data IN OUT NOCOPY msc_sda_utils.maxCharTbl,
    p_fcst_data IN OUT NOCOPY msc_sda_utils.maxCharTbl,
    p_hist_data IN OUT NOCOPY msc_sda_utils.maxCharTbl);

  procedure sendFCSTHistoryData(p_view_type number, p_row_index number,
    p_reglist_action number, p_orglist_action number, p_itemlist_action number, p_action_node number,
    p_rheader_data in out nocopy msc_sda_utils.maxCharTbl,
    p_out_data in out nocopy msc_sda_utils.maxCharTbl,
    p_out_data2 in out nocopy msc_sda_utils.maxCharTbl);

  function getSDStartDate(p_bkt_start_date date, p_plan_start_date date, p_plan_end_date date, p_sd_date date) return date;
  function getSDEndDate(p_bkt_end_date date, p_plan_start_date date, p_plan_end_date date, p_sd_date date) return date;
  function getSupplyRowTypeOffset(p_order_type number, p_item_type_id number,
    p_item_type_value number, p_type_flag number, p_source_organization_id number) return number;
  function getDemandRowTypeOffset(p_order_type number, p_item_type_id number, p_item_type_value number, p_type_flag number,
    p_disposition_id number, p_org_type number) return number;

  function getHistStartDate(p_bkt_start_date date, p_plan_start_date date, p_plan_end_date date, p_sd_date date) return date;
  function getHistEndDate(p_bkt_end_date date, p_plan_start_date date, p_plan_end_date date, p_sd_date date) return date;
  function getHistRowTypeOffset(p_order_type number, p_item_type_id number, p_item_type_value number, p_type_flag number) return number;

  function getFcstStartDate(p_bkt_start_date date, p_plan_start_date date, p_plan_end_date date, p_sd_date date) return date;
  function getFcstEndDate(p_bkt_end_date date, p_plan_start_date date, p_plan_end_date date, p_sd_date date) return date;
  function getFcstRowTypeOffset(p_supply_demand_flag number, p_order_type number, p_item_type_id number, p_item_type_value number, p_type_flag number,
    p_inst_id number, p_org_id number, p_region_id number, p_schedule_designator_id number, p_item_id number) return number;

  procedure sendNlsMessages(p_out_data IN OUT NOCOPY msc_sda_utils.maxCharTbl);
  procedure spreadTableMessages(p_out_data in out nocopy msc_sda_utils.maxCharTbl);

  procedure set_shuttle_from_to(p_lookup_type varchar2, p_lookup_code_list varchar2,
    p_from_list out nocopy varchar2, p_to_list out nocopy varchar2);

  procedure update_pref_set (p_name varchar2, p_desc varchar2,
    p_days number, p_weeks number, p_periods number,
    p_factor number, p_decimal_places number,
    p_sd_row_list varchar2, p_fcst_row_list varchar2);

  procedure save_item_folder(p_folder_name varchar, p_folder_value varchar,
    p_default_flag number, p_public_flag number);

  procedure update_close_settings(p_event varchar2, p_event_list varchar2);
  procedure send_close_settings(p_item_folder_save_list out nocopy varchar2,
    p_save_settings_list out nocopy varchar2);

  procedure getCommentsData(p_out_data in out nocopy msc_sda_utils.maxCharTbl);
  procedure getItemList(p_out_data out nocopy varchar2);
  procedure getOrgList(p_out_data out nocopy varchar2);
  procedure getWorkSheetPrefData(p_out_data IN OUT NOCOPY msc_sda_utils.maxCharTbl, p_refresh_flag number);

  procedure getDrillDownDetails(p_view_type number, p_row_index number, p_row_offset number,
    p_date1 varchar2, p_date2 varchar2, p_from_table out nocopy varchar2, p_mfq_id out nocopy number);

--for supersession window
function populateSupersessionChain(p_plan number, p_item number) return number;

--for engine
  procedure sendTimeBucketEng(p_plan_id number, p_view_type number,
    p_bucket_data IN OUT NOCOPY msc_sda_utils.maxCharTbl,
    p_week_data IN OUT NOCOPY msc_sda_utils.maxCharTbl,
    p_period_data IN OUT NOCOPY msc_sda_utils.maxCharTbl);

end MSC_SDA_PKG;

/
