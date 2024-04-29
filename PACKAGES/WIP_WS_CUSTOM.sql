--------------------------------------------------------
--  DDL for Package WIP_WS_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WS_CUSTOM" AUTHID CURRENT_USER as
/* $Header: wipwscts.pls 120.3 2008/01/02 09:16:42 ksuleman ship $ */

  function get_orderby_attribute_1(p_wip_entity_id number, p_op_seq number) return varchar2;
  function get_orderby_attribute_2(p_wip_entity_id number, p_op_seq number) return varchar2;
  function get_related_jobs(p_wip_entity_id number) return varchar2;

  function get_custom_ready_status(
    wip_entity_id in number,
    operation_seq_num in number,
    serial_number in varchar2,
    attribute1 in varchar2,
    attribute2 in varchar2,
    attribute3 in varchar2
  ) return varchar2;

  procedure validate_transaction(
    wip_entity_id in number,
    mtl_header_id in number,
    txn_type in varchar2,
    from_op_seq in number,
    from_step in varchar2,
    to_op_seq in number,
    to_step in varchar2,
    txn_quantity in number,
    txn_uom in varchar2,
    scrap_quantity in number,
    reject_quantity in number,
    subinv in varchar2,
    locator_id in number,
    assembly_lot in varchar2,
    assembly_serial in varchar2,
    reason_id in number,
    reference_str in varchar2,
    sales_order_id in varchar2,
    sales_order_line_id in number,
    overcompletion in string,
    project_id in number,
    task_id in number,
    scrap_acct_id in number,
    kanban_id in number,
    attribute1 in varchar2,
    attribute2 in varchar2,
    attribute3 in varchar2,
    attribute4 in varchar2,
    attribute5 in varchar2,
    return_status out NOCOPY varchar2,
    return_message out NOCOPY varchar2,
    return_attribute1 out NOCOPY varchar2,
    return_attribute2 out NOCOPY varchar2
  );

procedure reorder_ops_for_shortage (
  p_wip_job_op_tbl  IN OUT NOCOPY  WIP_WS_SHORTAGE.wip_job_op_tbl_type,
  p_return_status   OUT NOCOPY VARCHAR2,
  p_retcode         OUT NOCOPY NUMBER);


end WIP_WS_CUSTOM;


/
