--------------------------------------------------------
--  DDL for Package MSC_GET_GANTT_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_GET_GANTT_DATA" AUTHID CURRENT_USER AS
/* $Header: MSCGNTDS.pls 120.1 2005/06/17 15:36:31 appldev  $  */

   END_DEMAND_NODE CONSTANT number :=0;
   JOB_NODE CONSTANT number :=1;
   OP_NODE CONSTANT number :=2;
   RES_NODE CONSTANT number :=3;
   END_JOB_NODE CONSTANT number :=4;
   PREV_NODE CONSTANT number :=-1;
   NEXT_NODE CONSTANT number :=-2;

  TYPE char20Tbl IS TABLE OF varchar2(20) index by binary_integer;
  TYPE char80Tbl IS TABLE OF varchar2(80) index by binary_integer;
  TYPE numberTbl IS TABLE OF number index by binary_integer;

  TYPE Child_REC_TYPE is RECORD (
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

   TYPE longCharTbl IS TABLE of varchar2(200) index by binary_integer;
   TYPE maxCharTbl IS TABLE of varchar2(32000);

   TYPE PEG_REC_TYPE is RECORD (
      parent_index numberTbl,
      next_record numberTbl,
      org_id numberTbl,
      department_id numberTbl,
      transaction_id numberTbl,
      instance_id numberTbl,
      op_seq numberTbl,
      type numberTbl,
      path longCharTbl,
      name longCharTbl,
      firm_flag numberTbl,
      start_date char20Tbl,
      end_date char20Tbl,
      status numberTbl,
      applied numberTbl,
      res_firm_flag numberTbl,
      late_flag numberTbl,
      early_start_date char20Tbl,
      early_end_date char20Tbl,
      latest_start_date char20Tbl,
      latest_end_date char20Tbl,
      u_early_start_date char20Tbl,
      u_early_end_date char20Tbl,
      min_start_date char20Tbl,
      critical_flag numberTbl,
      supply_type numberTbl,
      new_path longCharTbl
   );

FUNCTION get_debug_mode return varchar2;

FUNCTION replace_seperator(old_string varchar2) return varchar2 ;

Procedure setFetchRow(p_supply_limit number,
                      p_resource_limit number);

Function fetchDeptResCode(p_plan_id number,
                            v_instance_id number,
                            v_org_id number,
                            v_dept_id number,
                            v_res_id number) RETURN varchar2;

Procedure fetchAllResource(p_plan_id number,
                           p_where varchar2,
                                   v_name OUT NOCOPY varchar2);

Procedure fetchResourceData(p_plan_id number,
                                   p_res_list varchar2,
                                   p_fetch_type varchar2 default null,
                                   v_require_data OUT NOCOPY Child_REC_TYPE,
                                   v_name OUT NOCOPY varchar2);

Procedure fetchLoadData(p_plan_id number,
                                   p_res_list varchar2,
                                   p_start varchar2 DEFAULT NULL,
                                   p_end varchar2 DEFAULT NULL,
                                   v_require_data  IN OUT NOCOPY maxCharTbl,
                                   v_avail_data OUT NOCOPY varchar2);

Function loadAltResource(p_plan_id number,
                             p_transaction_id number,
                             p_instance_id number,
                             p_alt_resource number,
                             p_alt_num number)
        return Varchar2;

Function firmResource(p_plan_id number,
                             p_transaction_id number,
                             p_instance_id number,
                             p_firm_type number,
                             p_start varchar2,
                             p_end varchar2) return Varchar2;

PROCEDURE fetchAltResource(p_plan_id number,
                             p_transaction_id number,
                             p_instance_id number,
                             v_name OUT NOCOPY varchar2,
                             v_id OUT NOCOPY varchar2);

PROCEDURE fetchSimultaneousRes(p_plan_id number,
                             p_transaction_id number,
                             p_instance_id number,
                             v_name OUT NOCOPY varchar2,
                             v_id OUT NOCOPY varchar2);

PROCEDURE fetchPropertyData(p_plan_id number,
                             p_transaction_id number,
                             p_instance_id number,
                             v_job OUT NOCOPY varchar2,
                             v_demand OUT NOCOPY varchar2);

Procedure fetchDemandData( p_plan_id number,
                           p_instance_id number,
                           v_transaction_id number,
                           v_org_id number,
                           v_demand out NOCOPY varchar2) ;

Procedure fetchRescheduleData(p_plan_id number,
                            p_instance_id number,
                            p_org_id number,
                            p_dept_id number,
                            p_res_id number,
                            p_time varchar2,
                            v_require_data OUT NOCOPY varchar2);

Procedure fetchRescheduleData(p_plan_id number,
                            p_instance_id number,
                            p_transaction_id number,
                            v_require_data OUT NOCOPY varchar2);

Function get_MTQ_time(p_transaction_id number,
                           p_plan_id number,
                           p_instance_id number) return number;

Procedure ValidateTime(p_plan_id number,
                             p_transaction_id number,
                             p_instance_id number,
                             p_start varchar2,
                             p_end varchar2,
                             p_return_status OUT NOCOPY varchar2,
                             p_out OUT NOCOPY varchar2);

FUNCTION IsTimeFenceCrossed(p_plan_id number,
                             p_transaction_id number,
                             p_instance_id number,
                             p_start varchar2)
RETURN varchar2;

Procedure ValidateAndMove(p_plan_id number,
                             p_transaction_id number,
                             p_instance_id number,
                             p_start varchar2,
                             p_end varchar2,
                             p_return_status OUT NOCOPY varchar2,
                             p_out OUT NOCOPY varchar2,
                             p_out2 OUT NOCOPY boolean);

Function usingBatchableRes(p_plan_id number,
                             p_transaction_id number,
                             p_instance_id number) return boolean;

Procedure MoveResource(p_plan_id number,
                             p_transaction_id number,
                             p_instance_id number,
                             p_start varchar2,
                             p_end varchar2,
                             p_return_status OUT NOCOPY varchar2,
                             p_out OUT NOCOPY varchar2);

Function get_start_date(p_plan_id number,
                           p_transaction_id number,
                           p_instance_id number)
return date;

Function get_end_date(p_plan_id number,
                           p_transaction_id number,
                           p_instance_id number)
return date;

Procedure findRequest(p_plan_id number,
                           p_where varchar2,
                           v_resource_list OUT NOCOPY varchar2,
                           v_supply_list OUT NOCOPY varchar2);

FUNCTION constructSupplyRequest(p_from_block varchar2,
                           p_plan_id number,
                           p_where varchar2) Return varchar2;

FUNCTION constructResourceRequest(p_from_block varchar2,
                           p_plan_id number,
                           p_where varchar2) RETURN varchar2;

FUNCTION constructRequest(p_type varchar2,
                           p_plan_id number,
                           p_where varchar2,
                           p_from_block varchar2) RETURN varchar2;

Function get_result(start_index IN number, v_return_data OUT NOCOPY varchar2,
                              next_index OUT NOCOPY number)
 return boolean;

Procedure explode_children(p_plan_id number,
                           p_critical number default -1);

Procedure get_end_pegging(p_plan_id number);

Procedure get_property(p_plan_id number, p_instance_id number,
                       p_transaction_id number,
                       p_type number, v_pro out NOCOPY varchar2,
                       v_demand out NOCOPY varchar2)
;

Procedure init;

Function print_one_record(i number) Return varchar2;

Procedure fetchSupplyData(p_plan_id number, p_supply_list varchar2,
                          p_fetch_type varchar2 default null);

Function get_plan_time (p_plan_id number) return varchar2;

Procedure validate_and_move_end_job (p_plan_id number,
                             p_supply_id number,
                             p_end varchar2,
                             p_return_status OUT NOCOPY varchar2,
                             p_out out NOCOPY varchar2);

Procedure fetchSupplierLoadData(p_plan_id number,
                                   p_supplier_list varchar2,
                                   p_start varchar2 default null,
                                   p_end varchar2 default null,
                                   v_require_data IN OUT NOCOPY maxCharTbl,
                                   v_avail_data IN OUT NOCOPY maxCharTbl);

Procedure fetchLateDemandData(p_plan_id number, p_demand_id number,
                              p_critical number default -1);

Procedure fetchAllSupplier(p_plan_id number,
                                   v_name OUT NOCOPY varchar2);

Procedure fetchAllLateDemand(p_plan_id number,
                             p_demand_id number,
                                   v_name OUT NOCOPY varchar2);

Function isCriticalSupply(p_plan_id number,
                          p_end_demand_id number,
                          p_transaction_id number,
                          p_inst_id number) Return number;

Function isCriticalRes(p_plan_id number,
                          p_end_demand_id number,
                          p_transaction_id number,
                          p_inst_id number,
                          p_operation_seq_id number,
                          p_routing_seq_id number) Return number;

Function supplyType(p_order_type number, p_make_buy_code number,
                    p_org_id number,p_source_org_id number) return number;

Function actualStartDate(p_order_type number, p_make_buy_code number,
                         p_org_id number,p_source_org_id number,
                         p_dock_date date, p_wip_start_date date,
                         p_ship_date date, p_schedule_date date)
  return varchar2 ;

Function fetchSupplierPriority(p_plan_id number,
                               p_instance_id number,
                               p_org_id number,
                               p_item_id number,
                               p_supplier_id number,
                               p_start varchar2,
                               p_end varchar2) return varchar2;

Function fetchResourcePriority(p_plan_id number,
                               p_instance_id number,
                               p_org_id number,
                               p_dept_id number,
                               p_resource_id number,
                               p_start varchar2,
                               p_end varchar2) return varchar2;

Function get_dmd_priority(p_plan_id number,
                          p_instance_id number,
                          p_transaction_id number) return number;
Function get_new_result(start_index IN number,
                        v_return_data OUT NOCOPY varchar2,
                        next_index OUT NOCOPY number)
 return boolean;

Procedure start_fetch(p_fetch_type IN varchar2,
                      v_return_data OUT NOCOPY varchar2,
                      start_index OUT NOCOPY number);
Function modify_parent_path(i number) return varchar2;

FUNCTION isSupplyLate(p_plan_id number,
                      p_instance_id number,
                      p_organization_id number,
                      p_inventory_item_id number,
                      p_transaction_id number) RETURN NUMBER;

Function order_number(p_order_type number, p_order_number varchar2,
                      p_plan_id number, p_inst_id number,
                      p_transaction_id number, p_disposition_id number)
return varchar2;

END Msc_Get_GANTT_DATA;

 

/
