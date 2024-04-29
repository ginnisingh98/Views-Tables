--------------------------------------------------------
--  DDL for Package MSC_SDA_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_SDA_UTILS" AUTHID CURRENT_USER as
/* $Header: MSCSDAUS.pls 120.10 2008/03/05 23:02:45 pabram noship $ */

   --constants DataStructures
   TYPE char20Tbl IS TABLE OF varchar2(20) index by binary_integer;
   TYPE char80Tbl IS TABLE OF varchar2(80) index by binary_integer;
   TYPE numberTbl IS TABLE OF number index by binary_integer;
   TYPE longCharTbl IS TABLE of varchar2(200) index by binary_integer;
   TYPE maxCharTbl IS TABLE of varchar2(32000);

   TYPE date_arr IS TABLE OF date;
   TYPE number_arr IS TABLE OF number;
   TYPE char_arr IS TABLE OF varchar2(300);

   g_log_flag boolean := true;
   g_log_row number := 0;
   g_log_file_dir varchar2(250);
   g_log_file_name varchar2(250);
   g_log_file_handle utl_file.file_type;

   c_field_seperator CONSTANT VARCHAR2(5) := '|';
   c_record_seperator CONSTANT VARCHAR2(5) := '&';
   c_bang_separator CONSTANT VARCHAR2(20) := '!';
   c_comma_separator CONSTANT VARCHAR2(20) := ',';
   c_field_seperator_ESC CONSTANT VARCHAR2(10) := '%pipe;';
   c_record_seperator_esc CONSTANT VARCHAR2(10) := '%amp;';
   c_mbp_null_value CONSTANT NUMBER := -23453;
   c_mbp_not_null_value CONSTANT NUMBER := -23454;
   c_date_format CONSTANT VARCHAR2(20) := 'MM/DD/YYYY';
   c_datetime_format CONSTANT VARCHAR2(20) :='MM/DD/YYYY HH24:MI';
   c_null_space constant varchar2(1):= ' ';
   c_sys_yes constant INTEGER := 1;
   c_sys_no constant INTEGER := 2;

   c_comment_entity_type constant varchar2(50) := 'ITEM';

   --item part condition id and values from msc tables
   c_part_cond_id constant integer := 401; --part-condition-id
   c_part_good constant integer := 1; --good item
   c_part_bad constant integer := 2; --bad item


   -- relationship type values in msc_item_substitutes table
   c_mis_substitute_type constant number := 2; --substitution
   c_mis_supersession_type constant number := 8; --supersession
   c_mis_repair_to_type constant number := 18; --repair-to
   c_mis_service_type constant number := 5; --service

   --constants folders
   c_item_folder constant varchar2(50) := 'MSC_SDA_ITEMS';
   c_comments_folder constant varchar2(50) := 'MSC_SDA_COMMENTS';
   c_excp_folder constant varchar2(50) := 'MSC_SDA_EXCP_SUMMARY';

   --mfg_lookups lookup_type for supplydemand view and forecast view
   c_sdview_rowtype_lookup constant varchar2(80) := 'MSC_SD_VIEW_ROW_TYPE';
   c_fcstview_rowtype_lookup constant varchar2(80) := 'MSC_FCST_VIEW_ROW_TYPE';
   c_histview_rowtype_lookup constant varchar2(80) := 'MSC_HIST_VIEW_ROW_TYPE';

   --constants p_region_type
   c_reg_list_view constant number := 1;
   c_reg_view constant number := 2;

   --constants p_org_type
   c_org_list_view constant number :=1;
   c_org_view constant number := 2;

   --constant for regions
   c_all_region_type constant number := -100;
   c_all_org_type constant number := -200;
   c_global_reg_type constant number := -300;
   c_local_reg_type constant number := -400;

   c_global_reg_type_text varchar2(300) := 'Global';
   c_local_reg_type_text varchar2(300) := 'Local';
   c_all_region_type_text varchar2(300) := 'All Zones';
   c_all_org_type_text varchar2(300) := 'All Orgs';

   --constants p_item_view_type
   c_item_view constant number := 1;
   c_prime_view constant number := 2;
   c_supersession_view constant number := 3;

   --constants row-types count
   c_sd_total_row_types constant number := 45;
   c_fcst_total_row_types constant number := 16;
   c_hist_total_row_types constant number := 2;

   --c_sdview_items_count constant number := 74;
   --c_sdview_comments_count constant number := 4;
   --c_sdview_excp_count constant number := 3;

   --constants forms tokens
   c_sdview_rowtypes constant varchar2(80) := 'SDVIEW_ROWTYPES';
   c_fcstview_rowtypes constant varchar2(80) := 'FCSTVIEW_ROWTYPES';
   c_histview_rowtypes constant varchar2(80) := 'HISTVIEW_ROWTYPES';
   c_fcstview_rowtypes_show constant varchar2(80) := 'FCSTVIEW_ROWTYPES_SHOW';
   c_fcstview_rowtypes_rel constant varchar2(80) := 'FCSTVIEW_ROWTYPES_RELATION';

   c_sdview_nls_messages constant varchar2(80) := 'SDVIEW_NLS_MESSAGES';

   c_sdview_comments_data constant varchar2(80) := 'SDVIEW_COMMENTS_DATA';
   c_sdview_comments_data_ref constant varchar2(80) := 'SDVIEW_COMMENTS_DATA_REFRESH';
   c_sdview_items_data constant varchar2(80) := 'SDVIEW_ITEMS_DATA';
   c_sdview_excp_data constant varchar2(80) := 'SDVIEW_EXCP_DATA';
   c_sdview_prefset_data constant varchar2(80) := 'SDVIEW_PREFSET_DATA';
   c_sdview_prefset_data_ref constant varchar2(80) := 'SDVIEW_PREFSET_DATA_REFRESH';

   c_sdview_bucket_data constant varchar2(80) := 'SDVIEW_BUCKET_DATA';
   c_sdview_week_data constant varchar2(80) := 'SDVIEW_WEEK_DATA';
   c_sdview_period_data constant varchar2(80) := 'SDVIEW_PERIOD_DATA';
   c_sdview_rheader_data constant varchar2(80) := 'SDVIEW_RHEADER_DATA';
   c_sdview_data constant varchar2(80) := 'SDVIEW_DATA';

   c_fcstview_bucket_data constant varchar2(80) := 'FCSTVIEW_BUCKET_DATA';
   c_fcstview_week_data constant varchar2(80) := 'FCSTVIEW_WEEK_DATA';
   c_fcstview_period_data constant varchar2(80) := 'FCSTVIEW_PERIOD_DATA';
   c_fcstview_rheader_data constant varchar2(80) := 'FCSTVIEW_RHEADER_DATA';
   c_fcstview_data constant varchar2(80) := 'FCSTVIEW_DATA';
   c_fcstview_addl_data constant varchar2(80) := 'FCSTVIEW_DATA_ADDL';

   c_histview_bucket_data constant varchar2(80) := 'HISTVIEW_BUCKET_DATA';
   c_histview_rheader_data constant varchar2(80) := 'HISTVIEW_RHEADER_DATA';
   c_histview_data constant varchar2(80) := 'HISTVIEW_DATA';

   c_sdview_items_messages constant varchar2(80) := 'SDA_ITEMS_MESSAGES';
   c_sdview_comments_messages constant varchar2(80) := 'SDA_COMMENTS_MESSAGES';
   c_sdview_excp_messages constant varchar2(80) := 'SDA_EXCP_MESSAGES';

   c_sda_save_item_folder  constant varchar2(50) := 'SDA_SAVE_ITEM_FOLDER';
   c_sda_save_settings  constant varchar2(50) := 'SDA_SAVE_SETTINGS';

   --worksheet preferences
   SET_FROM_LIST constant varchar2(50) := 'SET_FROM_LIST';
   SET_TO_LIST constant varchar2(50) := 'SET_TO_LIST';
   c_sda_pref_set constant varchar2(80) := 'SDA_PREF_SET';

   c_keys_days constant varchar2(80) := 'DISPLAY_DAYS';
   c_keys_weeks constant varchar2(80) := 'DISPLAY_WEEKS';
   c_keys_periods constant varchar2(80) := 'DISPLAY_PERIODS';
   c_keys_factor constant varchar2(80) := 'DISPLAY_FACTOR';
   c_keys_decimals constant varchar2(80) := 'DECIMAL_PLACES';
   c_keys_sd constant varchar2(80) := 'SD_VIEW_ROW_TYPE';
   c_keys_fcst constant varchar2(80) := 'FCST_VIEW_ROW_TYPE';


  procedure println(p_msg varchar2);

  function check_row_exists(p_query_id number, p_row_index number,
    p_org_list_id number, p_inst_id number, p_org_id number,
    p_top_item_id number, p_item_id number, p_orglist_action number, p_itemlist_action number) return number;

  function getRepairItem(p_plan_id number, p_lower_item_id number, p_highest_item_id number) return number;
  function flushSupersessionChain(p_plan number, p_item number) return number;

  --misc apis
  function escapeSplChars(p_value varchar2) return varchar2;
  function getNewFormQueryId return number;
  function getNewAnalysisQueryId return number;

  procedure addRecordToOutStream(p_one_record varchar2,
    p_out_data_index in out nocopy number,
    p_out_data in out nocopy msc_sda_utils.maxchartbl) ;

  procedure addToOutStream(p_one_record varchar2,
    p_out_data_index in out nocopy number,
    p_out_data in out nocopy msc_sda_utils.maxchartbl,
    p_debug_flag number default null);

  procedure flushRegsOrgsIntoMfq(p_plan_id number, p_region_type number, p_region_list number,
    p_org_type number, p_org_list varchar2,
    p_region_query_id out nocopy number, p_org_query_id out nocopy number);

  function flushOrgsIntoMfq(p_query_id number, p_row_index number, p_org_type number) return number;

  function flushChainIntoMfq(p_query_id number, p_plan_id number,
    p_item_view_type number, p_item_id number) return number;

  function getRegionName(p_region_id number) return varchar2;
  function getOrgList(p_query_id number) return varchar2;

  procedure  getRegListValues(p_region_list varchar2, p_region_type number,
    p_reg_list_id out nocopy number, p_reg_list out nocopy varchar2,
    p_region_id out nocopy number, p_region_code out nocopy varchar2);

  procedure  getOrgListValues(p_orglist varchar2, p_org_type number,
    p_org_list_id out nocopy number, p_org_list out nocopy varchar2,
    p_inst_id out nocopy number, p_org_id out nocopy number,
    p_org_code out nocopy varchar2);

  procedure  getItemListValues(p_cur_item_id number, p_item_view_type number,
    p_top_item_id out nocopy number, p_top_item_name out nocopy varchar2,
    p_item_id out nocopy number, p_item_name out nocopy varchar2);

  procedure  getItemPrimeSS(p_plan_id number, p_item_id number,
    p_prime_item_id out nocopy number, p_ss_item_id out nocopy number);

  function createHistCalInMfq(p_start_date date, p_end_date date) return number;

  procedure getCommentsData(p_plan_id number, p_chain_query_id number,
    p_out_data in out nocopy msc_sda_utils.maxCharTbl, p_stream_label varchar2);
  procedure getItemsData(p_plan_id number, p_org_query_id number, p_chain_query_id number, p_out_data in out nocopy maxCharTbl);
  procedure getExceptionsData(p_plan_id number, p_chain_query_id number, p_org_query_id number,
    p_out_data in out nocopy maxCharTbl);
  procedure getWorkSheetPrefData(p_out_data in out nocopy maxCharTbl, p_refresh_flag number);

  procedure sendSDRowTypes(p_out_data IN OUT NOCOPY msc_sda_utils.maxCharTbl);
  procedure sendFcstRowTypes(p_out_data IN OUT NOCOPY msc_sda_utils.maxCharTbl);
  procedure sendHistRowTypes(p_out_data IN OUT NOCOPY msc_sda_utils.maxCharTbl);

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

  procedure update_close_settings (p_event varchar2, p_event_list varchar2);
  procedure send_close_settings(p_item_folder_save_list out nocopy varchar2,
    p_save_settings_list out nocopy varchar2);

end MSC_SDA_UTILS;

/
