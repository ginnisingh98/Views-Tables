--------------------------------------------------------
--  DDL for Package MSC_GANTT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_GANTT_UTILS" AUTHID CURRENT_USER AS
/* $Header: MSCGNTUS.pls 120.8 2006/05/03 16:17:24 pabram noship $  */

-- CONSTANTS +
   --separators
   FIELD_SEPERATOR CONSTANT VARCHAR2(5) := '|';
   RECORD_SEPERATOR CONSTANT VARCHAR2(5) := '&';
   RESOURCE_SEPERATOR CONSTANT VARCHAR2(5) := '~';
   FORMAT_MASK CONSTANT VARCHAR2(20) :='MM/DD/YYYY HH24:MI';
   COMMA_SEPARATOR constant varchar2(20) := ',';
   COLON_SEPARATOR constant varchar2(20) := ':';

   FIELD_SEPERATOR_ESC CONSTANT VARCHAR2(10) := '%pipe;';
   RECORD_SEPERATOR_ESC CONSTANT VARCHAR2(10) := '%amp;';

   --view types
   ORDER_VIEW  CONSTANT INTEGER := 0;
   RES_ACTIVITIES_VIEW CONSTANT INTEGER := 1;
   RES_HOURS_VIEW CONSTANT INTEGER := 2;
   RES_UNITS_VIEW CONSTANT INTEGER := 3;
   SUPPLIER_VIEW CONSTANT INTEGER := 4;
   DEMAND_VIEW CONSTANT INTEGER := 5;

   --node types
   END_DEMAND_NODE CONSTANT INTEGER := 0;
   JOB_NODE CONSTANT INTEGER := 1;
   OP_NODE CONSTANT INTEGER := 2;
   RES_NODE CONSTANT INTEGER := 3;
   -- END_JOB_NODE CONSTANT INTEGER :=4;
   COPROD_NODE CONSTANT INTEGER := 5;
   RES_INST_NODE CONSTANT INTEGER := 6;

   --orders view types
   PEG_ORDERS constant integer := 0;
   PEG_DOWN constant integer := 1;
   PEG_UP   constant integer := -1;
   PEG_UP_AND_DOWN constant integer := 2;
   SHOW_CHILDREN constant integer := 3;
   SHOW_PARENT constant integer := 4;
   SHOW_PARENT_CHILDREN constant integer := 5;

   --res row types
   RES_SETUP_ROW_TYPE constant INTEGER := 0;
   RES_REQ_ROW_TYPE constant INTEGER := 1;
   RES_AVAIL_ROW_TYPE constant INTEGER := 2;
   RES_CHARGES_ROW_TYPE constant INTEGER := 3;
   RES_ACT_BATCHED_ROW_TYPE constant INTEGER := 4;
   RES_SETUP_FIXED_ROW_TYPE constant INTEGER := 5;
   SEGMENT_PEG_ROW_TYPE constant INTEGER := 6;
   RES_REQ_DISPLAY_ROW_TYPE constant INTEGER := 7;  --only for the backend....
   RES_REQ_SDS_ROW_TYPE constant INTEGER := 9;

   --res row types
   SUPP_ALL_ROW_TYPE constant INTEGER := 0;
   SUPP_AVAIL_ROW_TYPE constant INTEGER := 1;
   SUPP_OVERLOAD_ROW_TYPE constant INTEGER := 2;
   SUPP_CONSUME_ROW_TYPE constant INTEGER := 3;
   -- SUPP_NET_CUM_AVAIL_ROW_TYPE constant INTEGER := 5;

   --parent id
   SUMMARY_DATA constant INTEGER := 1;
   DETAIL_DATA constant INTEGER := 2;

   --diff peg vs same peg orders view
   SAME_PEG  constant INTEGER := 1;
   ALL_PEG  constant INTEGER := 2;

   --critical vs non critical orders view
   NON_CRITICAL_PATH constant INTEGER := -1;
   CRITICAL_PATH constant INTEGER := 1;

   -- res schedule_flag
   SCHEDULE_FLAG_YES constant integer := 1;
   SCHEDULE_FLAG_NO constant integer := 2;
   SCHEDULE_FLAG_PRIOR constant integer := 3;
   SCHEDULE_FLAG_NEXT constant integer := 4;

   -- res firm types
   NO_FIRM        CONSTANT INTEGER :=0;
   FIRM_START     CONSTANT INTEGER :=1;
   FIRM_END       CONSTANT INTEGER :=2;
   FIRM_RESOURCE  CONSTANT INTEGER :=3;
   FIRM_START_END CONSTANT INTEGER :=4;
   FIRM_START_RES CONSTANT INTEGER :=5;
   FIRM_END_RES   CONSTANT INTEGER :=6;
   FIRM_ALL       CONSTANT INTEGER :=7;

   --supply item types
   ON_HAND CONSTANT INTEGER :=1;
   BUY_SUPPLY CONSTANT INTEGER :=2;
   MAKE_SUPPLY CONSTANT INTEGER :=3;
   TRANSFER_SUPPLY CONSTANT INTEGER :=4;

   --updateSupplies types
   TOUCH_SUPPLY CONSTANT INTEGER := 1;
   FIRM_SUPPLY CONSTANT INTEGER := 2;
   FIRM_ALL_SUPPLY CONSTANT INTEGER := 3;

   --updateMRR types
   TOUCH_MRR CONSTANT INTEGER := 1;
   FIRM_MRR CONSTANT INTEGER := 2;
   FIRM_ALL_MRR CONSTANT INTEGER := 3;
   MOVE_MRR constant number := 4;

   --filter types
   FILTER_TYPE_LIST constant integer := 1;
   FILTER_TYPE_MFQ constant integer := 2;
   FILTER_TYPE_FOLDER_ID constant integer := 3;
   FILTER_TYPE_WHERE_STMT constant integer := 4;
   FILTER_TYPE_AMONG constant integer := 5;
   FILTER_TYPE_QUERY_ID constant integer := 6;

   --display types for res activities /hours view
   DISPLAY_NONE constant integer := 1;
   DISPLAY_LATE constant integer := 2;
   DISPLAY_EARLY constant integer := 3;
   DISPLAY_FIRM constant integer := 4;
   DISPLAY_OVERLOAD constant integer := 5;

   --misc
   MBP_NULL_VALUE constant integer := -23453;
   MBP_NULL_VALUE_CHAR constant varchar2(30) := '-23453';

   NULL_SPACE constant varchar2(1):= ' ';

   ROUND_FACTOR INTEGER := 6;
   SYS_YES constant INTEGER := 1;
   SYS_NO constant INTEGER := 2;

   ASCEND_ORDER constant INTEGER := 1;
   DESCEND_ORDER constant INTEGER := 2;

   -- BOM_ITEM_TYPE
   BOM_ITEM_MODEL constant integer := 1; -- Model, base_item_id is null
   BOM_ITEM_OPTION constant integer := 2; -- Option class, base_item_id is null
   BOM_ITEM_PLANNING constant integer := 3; -- Planning, base_item_id is null
   BOM_ITEM_STANDARD constant integer := 4; -- Standard, base_item_id is not null
   BOM_ITEM_PF constant integer := 5; -- Product family, base_item_id is null

-- CONSTANTS -

-- Data Structures +
  TYPE char20Tbl IS TABLE OF varchar2(20) index by binary_integer;
  TYPE char80Tbl IS TABLE OF varchar2(80) index by binary_integer;
  TYPE numberTbl IS TABLE OF number index by binary_integer;
  TYPE longCharTbl IS TABLE of varchar2(200) index by binary_integer;
  TYPE maxCharTbl IS TABLE of varchar2(32000);
  TYPE date_arr IS TABLE OF date;
  TYPE number_arr IS TABLE OF number;
  TYPE char_arr IS TABLE OF varchar2(300);

  TYPE child_rec_type is RECORD (
    record_count numberTbl,
    start_date char20Tbl,
    end_date char20Tbl,
    name char80Tbl,
    transaction_id numberTbl,
    status numberTbl,
    applied numberTbl,
    supply_type char80Tbl,
    instance_id numberTbl,
    res_firm_flag numberTbl,
    sup_firm_flag numberTbl,
    late_flag numberTbl
  );
-- Data Structures -

-- get functions +
function isCriticalSupply(p_plan_id number,
  p_end_demand_id number,  p_transaction_id number,
  p_inst_id number) Return number;

function getDmdPriority(p_plan_id number,
  p_instance_id number, p_transaction_id number) return number;

function isResChargeable(p_plan_id number,
  p_instance_id number, p_org_id number,
  p_dept_id number, p_res_id number,
  p_res_instance_id number) return number ;

function isCriticalRes(p_plan_id number,
  p_end_demand_id number,  p_transaction_id number,
  p_inst_id number,  p_operation_seq_id number,
  p_routing_seq_id number) return number;

function isSupplyLate(p_plan_id number,
  p_instance_id number, p_organization_id number,
  p_inventory_item_id number, p_transaction_id number) return number;

function getActualStartDate(p_order_type number, p_make_buy_code number,
  p_org_id number,p_source_org_id number,
  p_dock_date date, p_wip_start_date date,
  p_ship_date date, p_schedule_date date,
  p_source_supp_id number) return varchar2 ;

function isResConstraint(p_plan_id number,
  p_instance_id number, p_organization_id number, p_inventory_item_id number,
  p_department_id number, p_resource_id number,
  p_transaction_id number) return number;

function isResOverload(p_plan_id number,
  p_instance_id number, p_organization_id number, p_inventory_item_id number,
  p_department_id number, p_resource_id number,
  p_transaction_id number) return number;

function isExcpExists(p_plan_id number, p_instance_id number, p_organization_id number,
  p_department_id number, p_resource_id number, p_exception_type number) return number;

function getSupplyType(p_order_type number, p_make_buy_code number,
  p_org_id number,p_source_org_id number) return number;

function getPlanInfo(p_plan_id number,
  p_first_date out nocopy date, p_last_date out nocopy date,
  p_hour_bkt_start_date out nocopy date, p_day_bkt_start_date out nocopy date,
  p_plan_start_date out nocopy date, p_plan_end_date out nocopy date,
  p_plan_type out nocopy number) return varchar2;

function getDisplayType(p_display_type number, p_end_date date,
  p_ulpsd date, p_res_firm_flag number, p_overload_flag number,
  p_days_early number, p_days_late number) return number;

function getResReqType(p_plan_id number,
  p_schedule_flag number, p_parent_seq_num number, p_setup_id number) return number;

function getSetupCode(p_plan_id number, p_inst_id number,
  p_resource_id number, p_setup_id number) return varchar2 ;

function getResReqStartDate(p_firm_flag number,
  p_start_date date, p_end_date date,
  p_firm_start_date date, p_firm_end_date date, p_status number, p_applied number) return date;

function getResReqEndDate(p_firm_flag number,
  p_start_date date, p_end_date date,
  p_firm_start_date date, p_firm_end_date date, p_status number, p_applied number) return date;

function getDependencyType(p_plan_id number, p_trans_id number, p_inst_id number,
  p_op_seq_id number, p_op_seq_num number, p_res_seq_num number,
  c_trans_id number, c_inst_id number,
  c_op_seq_id number, c_op_seq_num number, c_res_seq_num number) return number;

procedure getBatchValues(p_plan_id number, p_instance_id number, p_batch_number number,
  p_res_desc out nocopy varchar2, p_min_capacity out nocopy number, p_max_capacity out nocopy number,
  p_capacity_used out nocopy number);

function getTansitionValue(p_plan_id number, p_instance_id number,
  p_org_id number, p_dept_id number, p_res_id number, p_from_setup_id number,
  p_to_setup_id number, p_value_code varchar2) return varchar2;

function getDeptResInstCode(p_plan_id number,
  p_instance_id number, p_org_id number,
  p_dept_id number, p_res_id number,
  p_res_instance_id number, p_serial_number varchar2) RETURN varchar2 ;

function getOrderNumber(p_plan_id number, p_inst_id number, p_trx_id number, p_disposition_id number,
  p_order_type number, p_order_number varchar2) return varchar2;

function getMFQSequence (p_query_id in number default null) Return number;

function getGanttSequence (p_query_id in number default null) Return number;

function usingBatchableRes(p_plan_id number,
  p_transaction_id number, p_instance_id number) return boolean;

function isBatchable(p_plan_id number, p_inst_id number, p_org_id number,
  p_dept_id number, p_res_id number ) return number;


function isTimeFenceCrossed(p_plan_id number,
  p_transaction_id number, p_instance_id number,
  p_start_date date) RETURN varchar2;

function getMTQTime(p_transaction_id number,
  p_plan_id number, p_instance_id number) return number;
-- get functions -

-- prepare Data +
procedure prepareResHoursGantt(p_query_id in number, p_plan_id number,
  p_start_date date, p_end_date date, p_display_type number default null);

procedure prepareSupplierGantt(p_query_id in number,
  p_plan_id number, p_start_date date, p_end_date date);

-- prepare Data -

-- populate msc_form_query proc's +
procedure populateEndPegsMFQ(p_plan_id in number,
  p_end_demand_id in number, p_query_id in number);

procedure populateOrdersIntoMFQ(p_inst_id in number,
  p_trx_id in number, p_query_id in number,
  p_one_record varchar2 default null);
-- populate msc_form_query proc's -

-- populate msc_gantt_query / msc_gantt_other_query proc's +
procedure populateOrdersIntoGantt(p_plan_id number,
  p_query_id number, p_mfq_query_id number);

procedure populateRowKeysIntoGantt(p_query_id number,
  p_index number, p_node_path varchar2, p_node_type number,
  p_transaction_id number, p_inst_id number, p_org_id number,
  p_dept_id number default null, p_res_id number default null,
  p_op_seq_num varchar2 default null, p_op_seq_id number default null,
  p_op_desc varchar2 default null,
  p_critical_flag number default null,
  p_parent_link varchar2 default null,
  p_node_level number default null);

procedure populateResDtlIntoGantt(p_query_id number,
 p_row_type number, p_row_index number,
 p_start_date date, p_end_date date,
 p_resource_units number, p_resource_hours number,
 p_schedule_flag number, p_detail_type number,
 p_display_type number default null);

procedure populateResReqGanttNew(p_query_id number, p_start_date date, p_end_date date,
  p_display_type number default null);

procedure populateResAvailGantt(p_query_id number,p_start_date date, p_end_date date);

procedure populateResActGantt(p_query_id number,
  p_start_date date, p_end_date date,
  p_batched_res_act number,
  p_require_data IN out nocopy msc_gantt_utils.maxCharTbl,
  p_display_type number);

procedure populateSupplierGantt(p_query_id number, p_plan_id number,
  p_start_date date, p_end_date date);

procedure populateResIntoGantt(p_query_id number,
  p_row_index in out nocopy number, p_one_record in out nocopy varchar2,
  p_plan_id number,
  p_inst_id number default null, p_org_id number default null,
  p_dept_id number default null, p_res_id number default null,
  p_res_instance_id number default null,
  p_serial_number varchar2 default null,
  p_add_nodes number default null);

procedure populateResIntoGanttFromMfq(p_query_id number,
  p_list varchar2, p_plan_id number);

procedure populateSuppIntoGantt(p_query_id number,
  p_row_index number, p_one_record in out nocopy varchar2, p_plan_id number,
  p_inst_id number default null, p_org_id number default null,
  p_item_id number default null, p_supplier_id number default null,
  p_supplier_site_id number default null);

procedure populateSuppIntoGanttFromMfq(p_query_id number,
  p_list varchar2, p_plan_id number);

procedure populateListIntoGantt(p_query_id number,
  p_plan_id number, p_list varchar2,
  p_filter_type number, p_view_type number,
  p_folder_id number default null);

-- populate msc_gantt_query / msc_gantt_other_query proc's -

-- res charges and segmentPegging +

procedure resCharges(p_query_id number, p_plan_id number,
  p_trx_list varchar2, p_out_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl);

--p_trx_list is (inst_id, node_type, trx id),(inst_id, node_type, trx_id)
procedure segmentPegging(p_query_id number, p_plan_id number,
  p_trx_list varchar2, p_out_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl);

-- res charges and segmentPegging -

--move.resize validation...alternate.simul resource +

function insertReqFromAlt(p_plan_id number, p_inst_id number,
  p_simu_res_trx number,
  p_alt_res_id number,
  p_alt_res_hours number,
  p_alt_res_alt_num number,
  p_alt_res_basis_type number,
  p_alt_orig_res_seq_num number) return number;

procedure updateReqFromAlt(p_plan_id number, p_inst_id number, p_simu_res_trx number,
  p_alt_res_id number, p_alt_res_hours number, p_alt_res_alt_num number, p_alt_res_basis_type number,
  p_alt_orig_res_seq_num number);

procedure updateReqInstFromAlt(p_plan_id number, p_inst_id number, p_simu_res_trx number,
  p_alt_res_id number, p_alt_res_instance_id number, p_serial_number varchar2,
  p_alt_res_hours number, p_alt_res_alt_num number,
  p_alt_orig_res_seq_num number);

procedure DeleteReqFromAlt(p_plan_id number, p_inst_id number, p_simu_res_trx number);

function insertReqInstFromAlt(p_plan_id number, p_inst_id number,
  p_simu_res_inst_trx number,
  p_alt_res_id number,
  p_alt_res_instance_id number,
  p_serial_number varchar2,
  p_alt_res_hours number,
  p_alt_res_alt_num number,
  p_from_node number,
  p_alt_orig_res_seq_num number) return number;

procedure DeleteReqInstFromAlt(p_plan_id number,
  p_inst_id number, p_res_inst_trx number);

procedure validateTime(p_plan_id number,
  p_transaction_id number, p_instance_id number,
  p_start_date date, p_end_date date,
  p_plan_start_date date, p_plan_end_date date,
  p_return_status in OUT NOCOPY varchar2,
  p_out in OUT NOCOPY varchar2,
  p_node_type number);

procedure getSimuResource(p_plan_id number,
  p_transaction_id number, p_instance_id number,
  p_name OUT NOCOPY varchar2, p_id OUT NOCOPY varchar2,
  p_node_type number default null);

procedure getAltResource(p_plan_id number,
  p_transaction_id number, p_instance_id number,
  p_name OUT NOCOPY varchar2, p_id OUT NOCOPY varchar2,
  p_node_type number default null,
  p_from_form number default null);

procedure loadAltResource(p_plan_id number, p_transaction_id number,
  p_instance_id number, p_alt_resource number, p_alt_resource_inst number,
  p_serial_number varchar2, p_alt_num number,
  p_node_type number, p_to_node_type number,
  p_return_trx_id out nocopy number,
  p_return_status OUT NOCOPY varchar2,
  p_out OUT NOCOPY varchar2
  );

procedure loadAltResourceBatch(p_plan_id number, p_transaction_id number,
  p_instance_id number, p_alt_resource number, p_alt_resource_inst number,
  p_serial_number varchar2, p_alt_num number,
  p_node_type number, p_to_node_type number,
  p_return_trx_id out nocopy number,
  p_return_status OUT NOCOPY varchar2,
  p_out OUT NOCOPY varchar2
  );

procedure firmResourcePub(p_plan_id number,
  p_transaction_id number, p_instance_id number, p_firm_type number,
  p_return_status OUT NOCOPY varchar2,
  p_out OUT NOCOPY varchar2,
  p_node_type number);

procedure firmResourceSeqPub(p_plan_id number,
  p_trx_list varchar2, p_firm_type number,
  p_return_status OUT NOCOPY varchar2,
  p_out OUT NOCOPY varchar2,
  p_node_type number);

procedure firmResourceBatchPub(p_plan_id number,
  p_transaction_id number, p_instance_id number, p_firm_type number,
  p_return_status OUT NOCOPY varchar2,
  p_out OUT NOCOPY varchar2,
  p_node_type number);

procedure firmSupplyPub(p_plan_id number,
  p_transaction_id number, p_instance_id number,
  p_firm_type number,
  p_start_date date, p_end_date date,
  p_plan_start_date date, p_plan_end_date date,
  p_return_status OUT NOCOPY varchar2,
  p_out OUT NOCOPY varchar2,
  p_validate_flag boolean default true,
  p_node_type number);

procedure moveResourcePub(p_plan_id number,
  p_transaction_id number, p_instance_id number,
  p_start_date date, p_end_date date,
  p_duration varchar2,
  p_plan_start_date date, p_plan_end_date date,
  p_return_status OUT NOCOPY varchar2,
  p_out OUT NOCOPY varchar2,
  p_validate_flag boolean,
  p_res_firm_seq boolean,
  p_batched_res_act boolean,
  p_node_type number);

procedure moveSupplyPub (p_plan_id number,
  p_supply_id number, p_start_date date, p_end_date date,
  p_plan_start_date date, p_plan_end_date date,
  p_return_status OUT NOCOPY varchar2,
  p_out out NOCOPY varchar2 );

procedure rescheduleData(p_plan_id number,
  p_instance_id number, p_transaction_id number,
  p_plan_end_date date,
  v_require_data OUT NOCOPY varchar2);

procedure updateReq(p_plan_id number, p_inst_id number, p_trx_id number,
  p_firm_type number, p_start_date date, p_end_date date,
  p_firm_start_date date, p_firm_end_date date,
  p_update_mode number);

procedure updateReqInst(p_plan_id number, p_inst_id number, p_trx_id number,
  p_start_date date, p_end_date date);

procedure updateSupplies(p_plan_id number,
  p_trx_id number, p_update_type number,
  p_firm_type number default null,
  p_firm_date date default null,
  p_firm_qty number default null);

procedure updateReqSimu(p_plan_id number, p_inst_id number, p_trx_id number,
  p_firm_type number, p_start_date in out nocopy date, p_end_date in out nocopy date,
  p_firm_start_date date, p_firm_end_date date,
  p_update_mode number,
  p_return_status in out nocopy varchar2,
  p_out in out nocopy varchar2);

procedure moveOneResource(p_plan_id number,
  p_transaction_id number, p_instance_id number,
  p_start_date date, p_end_date date,
  p_return_status in OUT NOCOPY varchar2,
  p_out in OUT NOCOPY varchar2,
  p_node_type number) ;

procedure rescheduleData(p_plan_id number,
  p_instance_id number, p_org_id number,
  p_dept_id number, p_res_id number,
  p_time varchar2,
  p_plan_end_date date,
  v_require_data OUT NOCOPY varchar2);

--move.resize validation...alternate.simul resource -

--property Data +
procedure getProperty(p_plan_id number, p_instance_id number,
  p_transaction_id number, p_type number, p_view_type number,
  p_end_demand_id number,
  v_pro out NOCOPY varchar2, v_demand out NOCOPY varchar2);

procedure demandPropertyData( p_plan_id number,
  p_instance_id number, v_transaction_id number,
  v_org_id number, p_end_demand_id number,
  v_demand out NOCOPY varchar2);

procedure resPropertyData(p_plan_id number,
  p_transaction_id number, p_instance_id number,
  p_end_demand_id number,
  v_job OUT NOCOPY varchar2, v_demand OUT NOCOPY varchar2);
--property Data -


-- find and folder list +
procedure findRequest(p_plan_id number,
  p_where varchar2, p_query_id number,
  p_view_type varchar2 default null,
  p_filter_type number default null,
  p_folder_id number default null) ;

procedure constructSupplyRequest(p_query_id number,
  p_from_block varchar2, p_plan_id number,
  p_plan_end_date date, p_where varchar2);

procedure constructResourceRequest(p_query_id number,
  p_from_block varchar2, p_plan_id number,
  p_plan_end_date date,  p_where varchar2);

procedure constructRequest(p_query_id number,
  p_type varchar2, p_plan_id number, p_plan_end_date date,
  p_where varchar2, p_from_block varchar2);

-- find and folder list -

-- sends to client +
procedure sendResourceNames(p_query_id number,
  p_from_index number, p_to_index number,
  p_name_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
  p_sort_column varchar2 default null,
  p_sort_order varchar2 default null);

procedure sendSupplierNames(p_query_id number,
  p_from_index number, p_to_index number,
  p_name_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
  p_sort_column varchar2 default null,
  p_sort_order varchar2 default null);

procedure sendSupplierGantt(p_query_id number,
  p_supp_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl);

procedure sendResourceGantt(p_query_id number, p_view_type number, p_isBucketed number,
  p_require_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
  p_avail_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
  p_onlyAvailData boolean, p_display_type number);
-- sends to client -

procedure parseResString(p_one_record in varchar2,
  p_inst_id out nocopy number, p_org_id out nocopy number,
  p_dept_id out nocopy number, p_res_id out nocopy number,
  p_res_instance_id out nocopy number,
  p_serial_number out nocopy varchar2);

procedure parseSuppString(p_one_record in varchar2,
  p_inst_id out nocopy number, p_org_id out nocopy number,
  p_item_id out nocopy number, p_supplier_id out nocopy number,
  p_supplier_site_id out nocopy number);

function countStrOccurence (p_string_in in varchar2,
  p_substring_in in varchar2) return number;

procedure getBucketDates(p_start_date date, p_end_date date,
  v_bkt_start in out nocopy msc_gantt_utils.date_arr,
  v_bkt_end in out nocopy msc_gantt_utils.date_arr,
  p_query_id in out nocopy number);

function getResult(p_query_id number,
  p_from_index number, p_to_index number, p_plan_id number,
  p_out_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
  p_node_level number default null,
  p_sort_node number default null,
  p_sort_column varchar2 default null,
  p_sort_order varchar2 default null,
  p_res_nodes_only varchar2 default null) return number;

procedure getUserPref(p_pref_id number);

function getResBatchNodeLabel(p_res_req_type varchar2, p_org varchar2,
  p_batch_qty varchar2, p_batch_number varchar2, p_batch_util_pct varchar2) return varchar2;

function getResActResNodeLabel(p_plan_id number, p_inst_id number, p_trx_id number) return varchar2;
function getOrderViewResNodeLabel(p_plan_id number, p_inst_id number, p_trx_id number) return varchar2;

function getOpNodeLabel(p_op_seq varchar2,
  p_dept varchar2, p_op_desc varchar2, p_plan_id number) return varchar2;

function getJobNodeLabel(p_item_name varchar2, p_org_code varchar2,
  p_order_number varchar2, p_order_type varchar2, p_qty number) return varchar2;

function getResReqUlpsd(p_plan number, p_inst number, p_org number, p_dept number,
  p_res number, p_supply number, p_op_seq number, p_res_seq number,
  p_orig_res_seq number, p_parent_seq number) return date;

--function isResRowInGantt(p_query_id number,
--  p_res_instance_id number, p_batchable number, p_ignore_batch_flag number default null) return number;

function isBtchResWithoutBatch(p_plan_id number, p_instance_id number, p_organization_id number,
  p_department_id number, p_resource_id number, p_res_inst_id number) return number;

procedure isResRowInGantt(p_query_id number,
  p_res_rows out nocopy number,
  p_res_inst_rows out nocopy number,
  p_res_batch_rows out nocopy number,
  p_res_inst_batch_rows out nocopy number,
  p_batch_flag number default null);

function isResRowInGantt(p_query_id number, p_plan_id number,
  p_inst_id number, p_org_id number, p_dept_id number, p_res_id number,
  p_res_inst_id number, p_serial_number varchar2) return number;

function isResRowValidforResActView(p_plan number, p_inst number, p_org number,
  p_dept number, p_res number, p_start_date date, p_end_date date) return number;

END MSC_GANTT_UTILS;

 

/
