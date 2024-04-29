--------------------------------------------------------
--  DDL for Package WIP_WICTPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WICTPG" AUTHID CURRENT_USER as
/* $Header: wiptpgs.pls 120.1.12000000.1 2007/01/18 22:22:36 appldev ship $ */

  -- Args:
  --   p_report_key       identifier used in query for delete report
  --   p_org_id           organization ID to delete from
  --   p_cutoff_date      date to start purge from (goes backward)
  --   p_primary_item_id  item ID to delete (finds jobs with this assembly)
  --   p_conf_flag        delete configuration item job data
  --   p_header_flag      delete job header record
  --   p_detail_flag      delete job details
  --   p_move_trx_flag    delete move transactions associated with job
  --   p_cost_trx_flag    delete resource transactions associated with job
  --   p_option           purge and report(1), or report(2), purge only(3)
  --   p_commit_flag      perform commits to prevent full rollback segments
  --
  -- Notes:
  --   1) For the data types of each parameter, refer to the specification
  --      declaration of purge_job().
  --   2) Use p_report => 1 to get a report with the count of records
  --      affected by the purge. It is highly recommended that you run the
  --      report option w/o delete to get an idea of what is being purge
  --      before actually running with p_option => 3 or 2.
  --   3) After the purge run, enter the following SQL to get the report:
  --        SELECT DESCRIPTION
  --        FROM   WIP_TEMP_REPORTS
  --        WHERE  ATTRIBUTE1 = <REPORT KEY>
  --        ORDER  BY KEY1
  --      where <REPORT KEY> is the value you entered for p_report_key.
  --      Be sure to delete these records using
  --        DELETE FROM WIP_TEMP_REPORTS WHERE ATTRIBUTE1 = <REPORT KEY>
  --   4) Conditions checked are:
  --      o Org must be valid
  --      o Cutoff date must be after the first recorded period and before
  --        most recent closed period date
  --      o If primary item ID is not null, then it must be valid
  --      o You must delete details and transactions if deleting job header
  --      o If deleting job headers then
  --        o WIP_PERIOD_BALANCES must be zero charges
  --        o no sales order can be linked to the job
  --        o no foreign key references to WIP_ENTITY_ID in tables listed
  --          at the end of this spec
  --   5) You may modify the internal function delete_job_header() to
  --      customize whatever checks you need to delete the job header record.

  PURGE_JOBS   constant number := 1;
  PURGE_SCHEDS constant number := 2;
  PURGE_ALL    constant number := 4;

  /* Added for osfm purge job */

  PURGE_LOTBASED   constant number := 5;

  type purge_report_type is record (
    group_id        number,
    org_id          number,
    wip_entity_id   number,
    schedule_id     number,
    primary_item_id number,
    line_id         number,
    start_date      date,
    complete_date   date,
    close_date      date,
    table_name      varchar2(30),
    info_type       number,
    info            varchar2(240),
    entity_name     varchar2(240),
    line_code       varchar2(10)
  );

  cursor get_purge_requests(
    c_purge_type number,
    c_group_id   number) is
  select tmp.organization_id,
         tmp.wip_entity_id,
         we.entity_type,
         tmp.repetitive_schedule_id,
         tmp.primary_item_id,
         tmp.line_id,
         tmp.start_date,
         tmp.complete_date,
         tmp.close_date,
         tmp.status_type,
         decode(we.entity_type, 1, we.wip_entity_name,
                                3, we.wip_entity_name,
                                8, we.wip_entity_name,
                                2, NULL) wip_entity_name ,
         wl.line_code
  from   Wip_Purge_Temp tmp,
         wip_entities we,
         wip_lines wl
  where  tmp.group_id = c_group_id
  and    we.wip_entity_id = tmp.wip_entity_id
  and    wl.line_id (+) = tmp.line_id
  and    ((tmp.repetitive_schedule_id is NULL
           and
           c_purge_type in (PURGE_JOBS, PURGE_LOTBASED, PURGE_ALL))
           or
          (tmp.repetitive_schedule_id is NOT NULL
           and
           c_purge_type in (PURGE_SCHEDS, PURGE_ALL)));

  REPORT_ONLY      constant number := 1;
  PURGE_AND_REPORT constant number := 2;
  PURGE_ONLY       constant number := 3;

  -- Info type
  EXCEPTIONS    constant number := 1;
  ROWS_AFFECTED constant number := 2;


  -- Bug 5129924
  -- Added a new parameter
  -- p_days_before_cutoff to the
  -- function
  -- ntungare Thu May 25 11:41:12 PDT 2006
  --
  function purge(
    p_purge_type      in number,
    p_group_id        in number,
    p_org_id          in number,
    p_cutoff_date     in date,
    p_days_before_cutoff in number,
    p_from_job        in varchar2,
    p_to_job          in varchar2,
    p_primary_item_id in number,
    p_line_id         in number,
    p_option          in number default NULL,
    p_conf_flag       in boolean default NULL,
    p_header_flag     in boolean default NULL,
    p_detail_flag     in boolean default NULL,
    p_move_trx_flag   in boolean default NULL,
    p_cost_trx_flag   in boolean default NULL,
    p_err_num	      in out NOCOPY number,
    p_error_text      in out NOCOPY varchar2
    ) return number  ;


  -- Below are non-WIP tables that have foreign key references to WIP_ENTITY_ID
  -- (note that WIP tables also have foreign key references to WIP_ENTITY_ID
  --  of WIP_DISCRETE_JOBS/WIP_ENTITIES.  Please refer to the WIP Technical
  --  Reference Manual for a list of those tables).
  --
  -- cst_std_cost_adj_values
  --   (wip_entity_id)
  -- cst_wip_entity_find
  --   (wip_entity_id)
  -- po_distributions
  --   (wip_entity_id)
  -- po_requisition_lines
  --   (wip_entity_id)
  -- qa_results
  --   (wip_entity_id)
  -- rcv_transactions
  --   (wip_entity_id)
  -- mtl_demand
  --   (supply_source_type = 5, supply_source_header_id)
  -- mtl_user_supply
  --   (source_type_id = 5, source_id)
  -- mtl_user_demand
  --   (source_type_id = 5, source_id)
  -- mtl_serial_numbers
  --   (original_wip_entity_id)
  -- mtl_material_transactions
  --   (transaction_source_type_id = 5, transaction_source_id)
  -- mtl_transaction_accounts
  --   (transaction_source_type_id = 5, transaction_source_id)
  -- mtl_transaction_lot_numbers
  --   (transaction_source_type_id = 5, transaction_source_id)
  -- mtl_unit_transactions
  --   (transaction_source_type_id = 5, transaction_source_id)
  --
  -- Below are interface tables that have foreign key references to
  -- WIP_ENTITY_ID.  However, purge will not check against these table when
  -- delete the job header.
  --
  -- cst_period_value_temp
  --   (wip_entity_id)
  -- cst_std_cost_adj_temp
  --   (wip_entity_id)
  -- po_requisitions_interface
  --   (wip_entity_id)
  -- rcv_transactions_interface
  --   (wip_entity_id)
  -- mrp_relief_interface
  --   (dispostion_type = 1, disposition_id)
  -- mtl_demand_interface
  --   (supply_source_type = 5, supply_header_id)
  -- mtl_material_transactions_temp
  --   (transaction_source_type_id = 5, transaction_source_id)
  -- mtl_transactions_interface
  --   (transaction_source_type_id = 5, transaction_source_id)

end wip_wictpg;

 

/
