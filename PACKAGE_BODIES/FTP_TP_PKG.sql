--------------------------------------------------------
--  DDL for Package Body FTP_TP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTP_TP_PKG" AS
/* $Header: FTPEFTPB.pls 120.16 2007/01/17 06:06:45 rknanda noship $ */
  -- record type for objects
  type OBJ_INFO_TYPE is record (
    obj_id number,
    value_set_id number,
    eff_start_date date,
    eff_end_date date
  );
  -- type used for get_min_range to find minimum effective_date
  -- range for a set of object definitions
  type obj_info_array is varray (10) of obj_info_type;
  -- PACKAGE CONSTANTS
  c_api_version	CONSTANT NUMBER := 1;
  c_stmt_type		CONSTANT VARCHAR2(6) := 'INSERT'; --INSERT
  c_prg_running    CONSTANT  VARCHAR2(20) := 'RUNNING';
  c_prg_success    CONSTANT  VARCHAR2(20) := 'SUCCESS';
  c_prg_err_rerun  CONSTANT  VARCHAR2(20) := 'ERROR_RERUN';
  c_prg_err_undo   CONSTANT  VARCHAR2(20) := 'ERROR_UNDO';
  c_prg_cnl_rerun  CONSTANT  VARCHAR2(20) := 'CANCELLED_RERUN';
  c_prg_cnl_undo   CONSTANT  VARCHAR2(20) := 'CANCELLED_UNDO';
  c_app               CONSTANT VARCHAR2(3) := 'FTP';
  c_ecoloss_method CONSTANT NUMBER := 4;
  -- table used to lookup dimension_id
  MAIN_DIM_COL_NAME varchar2(30) := 'LINE_ITEM_ID';
  MAIN_DIM_ID number;
  ACCT_TYPE_ATTR_ID number := 1234;
  -- dim types for account type
  EXT_ACCOUNT_TYPE_NAME varchar2(30) := 'EXTENDED_ACCOUNT_TYPE';
  EXT_ACCOUNT_TYPE_ID number;
  ASSET_FLAG_NAME varchar2(30) := 'ASSET_FLAG';
  ASSET_FLAG_ID number;
  OFF_BAL_NAME varchar2(30) := 'OFF_BALANCE_SHEET_FLAG';
  OFF_BAL_FLAG_ID number;
  OBJECT_ID  number;
  REQUEST_ID number;
  -- Praveen Attaluri (Bug Fix)
  LEDGER_NAME varchar2(30) := 'FEM_BALANCES';

  -- Tina Dasgupta (R12 FTP Enhancements)
  -- Record type for FTP_RATE_OUTPUT_MAPPING_RULE
    type t_alt_rate_obj is record (
	obj_def_id number,
	Account_Table_Name varchar2(2000),
	TRANSFER_RATE_COL_NAME varchar2(2000),
	MATCHED_SPREAD_COL_NAME varchar2(2000),
	REMAINING_TERM_COL_NAME varchar2(2000),
	HISTORIC_OPTION_COL_NAME varchar2(2000),
	ADJ_RATE_COL_NAME varchar2(2000),
	HISTORIC_STAT_SPREAD_COL_NAME varchar2(2000),
	CURRENT_STAT_SPREAD_COL_NAME varchar2(2000),
	ADJ_AMOUNT_COL_NAME varchar2(2000),
	CURRENT_OPTION_COL_NAME varchar2(2000),
        ADJ_MKT_VALUE varchar2(2000)
	);
    -- Table for records of t_alt_rate_obj
    TYPE t_alt_rate_obj_list IS TABLE OF t_alt_rate_obj;
    g_alt_rate_obj t_alt_rate_obj_list := t_alt_rate_obj_list();

    -- Globals that indicate whether the the global varb exists or not
    g_alt_rate_obj_exists BOOLEAN := FALSE;

    -- Global List of table names that have valid mappings defined in FTP_RATE_OUTPUT_MAPPING_RULE
    valid_table_list varchar2(3000);
    g_block VARCHAR2(1000) := 'ftp.plsql.FTP_PKG.';


  -- Praveen Attaluri (Bug Fix)
  -- return min start/end date range in obj_info_list
  -- assumes list is non-empty
  procedure get_min_range(obj_info_list in obj_info_array,
                          s_date out nocopy date,
                          e_date out nocopy date)
  is
  begin
    s_date := obj_info_list(obj_info_list.first).eff_start_date;
    e_date := obj_info_list(obj_info_list.first).eff_end_date;
    for i in obj_info_list.first+1..obj_info_list.last loop
      if obj_info_list(i).eff_start_date is not null then
        if s_date is null or s_date < obj_info_list(i).eff_start_date then
           s_date := obj_info_list(i).eff_start_date;
        end if;
      end if;
      if obj_info_list(i).eff_end_date is not null then
        if e_date is null or e_date > obj_info_list(i).eff_end_date then
          e_date := obj_info_list(i).eff_end_date;
        end if;
      end if;
    end loop;
  end get_min_range;
   -- Get the object definition id for a given obj_id, effective date,
  procedure GET_OBJ_DEF(
    OBJ_ID in number,
    EFFECTIVE_DATE in date,
    OBJ_INFO out nocopy OBJ_INFO_TYPE) is
  begin
    select a.object_definition_id,
           c.value_set_id,
           a.effective_start_date,
           a.effective_end_date
      into OBJ_INFO
    from fem_object_definition_b a,
         fem_object_catalog_b b,
         fem_global_vs_combo_defs c
    where a.object_id = OBJ_ID
      and a.old_approved_copy_flag = 'N'
      and trunc(EFFECTIVE_DATE) between a.effective_start_date
                                    and nvl(a.effective_end_date,
                                            to_date('99991231', 'YYYYMMDD'))
      and a.object_id = b.object_id
      and b.local_vs_combo_id = c.global_vs_combo_id(+)
      and c.dimension_id(+) = main_dim_id;
  end GET_OBJ_DEF;


  /*********************************************
  CRDT: 18-July-2003
  PGMR: Praveen Attaluri
  DESC: Method return the value set id of line item
        and offset org unit based on the tranfer
        price rule local valuset combo and object id of
        the process rule
  *********************************************/
  PROCEDURE GET_VALUESETS_INFO(
     OBJ_ID in number,
     EFFECTIVE_DATE in date,
     LN_ITEM_VAL_SET out NOCOPY number,
     ORG_VAL_SET     out NOCOPY number,
     SOURCE_SYS_CD   out NOCOPY number
  ) IS
    process_info obj_info_type;
    tp_obj_id number;
    pp_obj_id number;
    combo_id  number;
  begin
    -- Get the object definition id of the process
    get_obj_def(OBJ_ID, EFFECTIVE_DATE, process_info);

    -- Now get the transfer price and prepayment object -d
    select transfer_price_object_id, prepay_object_id
      into tp_obj_id, pp_obj_id
      from ftp_tp_process_rule
     where object_definition_id = process_info.obj_id;

    -- Get the local value combo of the tp_object_id;
    select local_vs_combo_id into combo_id
    from fem_object_catalog_b where object_id = tp_obj_id;

    -- Now the valuset id of the line item and org unitl.
    select value_set_id into ORG_VAL_SET
    from fem_global_vs_combo_defs where dimension_id = 8 and
    global_vs_combo_id = combo_id;

    -- Now the valuset id of the line item and org unitl.
    select value_set_id into LN_ITEM_VAL_SET
    from fem_global_vs_combo_defs where dimension_id = 14 and
    global_vs_combo_id = combo_id;

    -- Get Source System Code
    EXECUTE IMMEDIATE 'select source_system_code from fem_source_systems_vl
    where source_system_display_code = :1' into SOURCE_SYS_CD USING c_app;

  END GET_VALUESETS_INFO;


  procedure GET_HIER_INFO(
    obj_id in number,
    effective_date in date,
    obj_info out nocopy obj_info_type) is
    hier_id number := NULL;
/*
	******* Commenting for Bug 4185961 Waiting for the base bug 3484006 to be closed *******
	cursor c(id number) is
      select hierarchy_id
        from fem_rule_hierarchies
       where object_id = id
         and dimension_id = main_dim_id;
*/
  cursor c(id number,eff_date date) is
      select
      cat.object_id hierarchy_id
      from
       fem_object_catalog_b cat,
       fem_object_dependencies dep,
       fem_object_definition_b def
       where
          def.object_id = id and
          eff_date between def.effective_start_date and def.effective_end_date and
          def.object_definition_id = dep.object_definition_id  and
          dep.required_object_id = cat.object_id and
          cat.object_type_code = 'HIERARCHY';
  begin
  hier_id := NULL;

    for cur in c(obj_id,effective_date) loop
      hier_id := cur.hierarchy_id;
    end loop;
    -- if heirarchy id is found, look up appropriate definition
    if hier_id is not null then
      get_obj_def(hier_id, effective_date, obj_info);
    end if;

  end GET_HIER_INFO;
  -- procedure to populate tp nodes on ftp_tp_pp_node_map for the situation
  -- where there is no hierarchy
  procedure populate_non_hier_tp(map_id in number,
                                 tp_obj_def in number,
                                 l_value_set_id in number) is
    user_id number;
    login_id number;
  begin
    user_id := fnd_global.user_id;
    login_id := fnd_global.login_id;
    delete ftp_tp_pp_node_map where map_id = node_map_id;
    insert into ftp_tp_pp_node_map
           (node_map_id, line_item_id, value_set_id,
            currency, tp_node,
            pp_node,
            creation_date, created_by, last_updated_by,
            last_update_date, last_update_login,
            created_by_object_id,created_by_request_id,
            last_updated_by_object_id,last_updated_by_request_id)
      select distinct map_id, line_item_id, l_value_set_id,
             currency, line_item_id,
             null, sysdate,
             user_id, user_id, sysdate, login_id,
             OBJECT_ID,REQUEST_ID,OBJECT_ID,REQUEST_ID from ftp_transfer_price_rule
      where object_definition_id = tp_obj_def;
  end populate_non_hier_tp;
  -- procedure to populate pp nodes on ftp_tp_node_map when there is
  -- no hierarchy used for prepayment
  procedure populate_non_hier_pp(map_id in number,
                                 pp_obj_def in number,
                                 l_value_set_id in number) is
    user_id number;
    login_id number;
  begin
    user_id := fnd_global.user_id;
    login_id := fnd_global.login_id;
    update ftp_tp_pp_node_map a set pp_node =
       (select distinct line_item_id from ftp_prepayment_rule p
         where p.object_definition_id = pp_obj_def
           and p.line_item_id = a.line_item_id
           and p.currency  = a.currency),
             -- The object id will always be the same.
             created_by_request_id = REQUEST_ID,
             last_updated_by_request_id = REQUEST_ID
     where a.node_map_id = map_id;
  end populate_non_hier_pp;

 /***************************************************************************
 Desc  : Procedure to populate adj nodes on ftp_tp_node_map when there is
         no hierarchy used for adjustment.
 Pgmr  : Raghuram K Nanda
 Date  : 16-Oct-2006
 ***************************************************************************/
  procedure populate_non_hier_adj(map_id in number,
                                 adj_obj_def in number,
                                 l_value_set_id in number) is
    user_id number;
    login_id number;
  begin
    user_id := fnd_global.user_id;
    login_id := fnd_global.login_id;

    --Merge into Node map table
    --When found means TP assumptions exists and we need to update adjustment
    --assumptions
    --When not found means TP assumptions doesn't exists for the line_item,
    --currency combo and we need to insert adjustment assumptions
    MERGE INTO ftp_tp_pp_node_map nm USING
    (select distinct line_item_id, currency from ftp_adjustment_rule
      where object_definition_id = adj_obj_def) adj
    ON (nm.line_item_id =adj.line_item_id and nm.currency=adj.currency
        and nm.node_map_id = map_id)
    WHEN MATCHED THEN
      update set adj_node=adj.line_item_id
    WHEN NOT MATCHED THEN
      insert (node_map_id, line_item_id, value_set_id,
            currency, adj_node, tp_node, pp_node,
            creation_date, created_by, last_updated_by,
            last_update_date, last_update_login,
            created_by_object_id,created_by_request_id,
            last_updated_by_object_id,last_updated_by_request_id) values
      (map_id, adj.line_item_id, l_value_set_id, adj.currency, adj.line_item_id,
       NULL, NULL, sysdate, user_id, user_id, sysdate, login_id,
       OBJECT_ID,REQUEST_ID,OBJECT_ID,REQUEST_ID);

  end populate_non_hier_adj;
  -- procedure to populate fep_tp_pp_node_map when a hierarchy is used for
  -- transfer pricing rule
  procedure populate_hierarchical_tp(map_id in number,
                                     tp_obj_def in number,
                                     l_value_set_id in number,
                                     hier_id in number) is
    user_id number;
    login_id number;
    cursor c is select distinct currency from ftp_transfer_price_rule
     where object_definition_id = tp_obj_def;
  begin
    user_id := fnd_global.user_id;
    login_id := fnd_global.login_id;
    delete ftp_tp_pp_node_map where map_id = node_map_id;
    -- move things currency by currency
    for cur in c loop
       insert into ftp_tp_pp_node_map
              (node_map_id, line_item_id,
               value_set_id,
               currency,
               tp_node,
               pp_node,
               creation_date, created_by, last_updated_by,
               last_update_date, last_update_login,
               created_by_object_id,created_by_request_id,
               last_updated_by_object_id,last_updated_by_request_id)
        select map_id, h.child_id, l_value_set_id,
               cur.currency, h.parent_id,
               null, sysdate,
               user_id, user_id, sysdate, login_id,
               OBJECT_ID,REQUEST_ID,OBJECT_ID,REQUEST_ID
          from fem_ln_items_hier h
         where h.hierarchy_obj_def_id = hier_id
           /* restrict to this value set */
           and l_value_set_id = h.parent_value_set_id
           and l_value_set_id = h.child_value_set_id
           /* restrict to parents in tp id */
           and exists (select null from ftp_transfer_price_rule tp
                        where tp.object_definition_id = tp_obj_def
                          and tp.line_item_id = h.parent_id
                          and tp.currency = cur.currency)
           /* restrict to leaves in hierarchy */
           and not exists (select null from fem_ln_items_hier h1
                            where h1.hierarchy_obj_def_id
                                  = hier_id
                              and h1.parent_id = h.child_id
                              and h1.parent_value_set_id = l_value_set_id
                              and h1.child_value_set_id = l_value_set_id
                              and h1.child_id <> h.child_id)
           /* restrict to lowest level when overrides exist */
           /* select max level num parent existing for given child within ID */
           and h.parent_depth_num = (select max(h1.parent_depth_num)
                                      from fem_ln_items_hier h1,
                                           ftp_transfer_price_rule q
                                     where h1.hierarchy_obj_def_id
                                           = hier_id
                                       and q.object_definition_id = tp_obj_def
                                       and q.line_item_id = h1.parent_id
                                       and h1.parent_value_set_id
                                           = l_value_set_id
                                       and h1.child_value_set_id
                                           = l_value_set_id
                                       and q.currency = cur.currency
                                       and h1.child_id = h.child_id);
     end loop;
  end populate_hierarchical_tp;
  -- procedure to populate fep_tp_pp_node_map when a hierarchy is used for
  -- transfer pricing rule
  procedure populate_hierarchical_pp(map_id in number,
                                     pp_obj_def in number,
                                     l_value_set_id in number,
                                     hier_id in number) is
    user_id number;
    login_id number;
    cursor c is select distinct currency from ftp_prepayment_rule
     where object_definition_id = pp_obj_def;
  begin
    user_id := fnd_global.user_id;
    login_id := fnd_global.login_id;
    -- move things currency by currency
    for cur in c loop
       update ftp_tp_pp_node_map a set pp_node =
         (select h.parent_id
            from fem_ln_items_hier h
           where h.hierarchy_obj_def_id = hier_id
             and h.parent_value_set_id = l_value_set_id
             /* restrict to leaves in hierarchy */
             and a.line_item_id = h.child_id
             and h.child_value_set_id = l_value_set_id
              /* restrict to parents in pp id */
             and exists (select null from ftp_prepayment_rule pp
                          where pp.object_definition_id = pp_obj_def
                            and pp.line_item_id = h.parent_id
                            and pp.currency = cur.currency)
             /* restrict to lowest level when overrides exist */
             /* select max level num parent existing for given */
             /* child within ID */
             and h.parent_depth_num = (select max(h1.parent_depth_num)
                                        from fem_ln_items_hier h1,
                                             ftp_prepayment_rule q
                                       where h1.hierarchy_obj_def_id
                                             = hier_id
                                         and q.object_definition_id
                                             = pp_obj_def
                                         and q.line_item_id = h1.parent_id
                                         and l_value_set_id
                                             = h1.parent_value_set_id
                                         and q.currency = cur.currency
                                         and h1.child_id = h.child_id
                                         and h1.child_value_set_id
                                           = l_value_set_id)),
             -- The object id will always be the same.
             created_by_request_id = REQUEST_ID,
             last_updated_by_request_id = REQUEST_ID
          where a.node_map_id = map_id and a.currency = cur.currency;
     end loop;
  end populate_hierarchical_pp;

/***************************************************************************
 Desc  : Procedure to populate ftp_tp_pp_node_map when a hierarchy is used for
         adjustment rule.
 Pgmr  : Raghuram K Nanda
 Date  : 16-Oct-2006
 ***************************************************************************/
  procedure populate_hierarchical_adj(map_id in number,
                                     adj_obj_def in number,
                                     l_value_set_id in number,
                                     hier_id in number) is
    user_id number;
    login_id number;
    cursor c is select distinct currency from ftp_adjustment_rule
     where object_definition_id = adj_obj_def;
     --l_count number;
  begin
    user_id := fnd_global.user_id;
    login_id := fnd_global.login_id;

    --Merge into Node map table
    --When found means TP assumptions exists and we need to update adjustment
    --assumptions
    --When not found means TP assumptions doesn't exists for the line_item,
    --currency combo and we need to insert adjustment assumptions

    -- move things currency by currency
    for cur in c loop
      MERGE INTO ftp_tp_pp_node_map nm USING
        (select  h.child_id, cur.currency, h.parent_id
          from fem_ln_items_hier h
          where h.hierarchy_obj_def_id = hier_id
           /* restrict to this value set */
           and l_value_set_id = h.parent_value_set_id
           and l_value_set_id = h.child_value_set_id
           /* restrict to parents in adjustment id */
           and exists (select null from ftp_adjustment_rule adj
                        where adj.object_definition_id = adj_obj_def
                          and adj.line_item_id = h.parent_id
                          and adj.currency = cur.currency)
           /* restrict to leaves in hierarchy */
           and not exists (select null from fem_ln_items_hier h1
                            where h1.hierarchy_obj_def_id
                                  = hier_id
                              and h1.parent_id = h.child_id
                              and h1.parent_value_set_id = l_value_set_id
                              and h1.child_value_set_id = l_value_set_id
                              and h1.child_id <> h.child_id)
           /* restrict to lowest level when overrides exist */
           /* select max level num parent existing for given child within ID */
           and h.parent_depth_num = (select max(h1.parent_depth_num)
                                      from fem_ln_items_hier h1,
                                           ftp_adjustment_rule q
                                     where h1.hierarchy_obj_def_id
                                           = hier_id
                                       and q.object_definition_id = adj_obj_def
                                       and q.line_item_id = h1.parent_id
                                       and h1.parent_value_set_id
                                           = l_value_set_id
                                       and h1.child_value_set_id
                                           = l_value_set_id
                                       and q.currency = cur.currency
                                       and h1.child_id = h.child_id)) adj
      ON (nm.line_item_id = adj.child_id and nm.currency=cur.currency
          and node_map_id = map_id)
      WHEN MATCHED THEN
        update set adj_node = adj.parent_id
      WHEN NOT MATCHED THEN
        insert (node_map_id, line_item_id,value_set_id,currency,
               adj_node, tp_node, pp_node,
               creation_date, created_by, last_updated_by,
               last_update_date, last_update_login,
               created_by_object_id,created_by_request_id,
               last_updated_by_object_id,last_updated_by_request_id) values
               (map_id, adj.child_id, l_value_set_id,
               cur.currency,adj.parent_id,null,
               null, sysdate,
               user_id, user_id, sysdate, login_id,
               OBJECT_ID,REQUEST_ID,OBJECT_ID,REQUEST_ID);
               --l_count := SQL%ROWCOUNT;
               --DBMS_OUTPUT.PUT_LINE('Merge Insert:'||l_count);
    end loop;

  end populate_hierarchical_adj;
  -- builds node map given tp, pp and adj object IDs and associated hierarchies
  -- if they exist.
  procedure build_node_map(map_id in number,
                           l_value_set_id in number,
                           tp_obj_def in number,
                           tp_hier_id in number,
                           pp_obj_def in number,
                           pp_hier_id in number,
                           l_adj_valueset_id in number,
                           adj_obj_def in number,
                           adj_hier_id in number) is
  begin

    --Look for Transfer Price rule
    if tp_obj_def is not null then
      if tp_hier_id is null then
        populate_non_hier_tp(map_id, tp_obj_def, l_value_set_id);
      else
        populate_hierarchical_tp(map_id, tp_obj_def,
                               l_value_set_id, tp_hier_id);
      end if;
    end if;

    --Look for Prepayment rule
    if pp_obj_def is not null then
       if pp_hier_id is null then
         populate_non_hier_pp(map_id, pp_obj_def, l_value_set_id);
       else
         populate_hierarchical_pp(map_id, pp_obj_def,
                                  l_value_set_id, pp_hier_id);
       end if;
    end if;

    --Look for Adjustment rule
    if adj_obj_def is not null then
       if adj_hier_id is null then
         populate_non_hier_adj(map_id, adj_obj_def, l_adj_valueset_id);
       else
         populate_hierarchical_adj(map_id, adj_obj_def,
                                  l_adj_valueset_id, adj_hier_id);
       end if;
    end if;
  end build_node_map;
  -- Creates a Node Map Header entry for the given processing ID
  -- returns map_id
  function create_new_map_header(proc_def_id in number,
                                 tp_def_id in number,
                                 pp_def_id in number,
                                 adj_def_id in number,
                                 e_s_date in date,
                                 e_e_date in date) return number
  is
    map_id number;
  begin
    select ftp_node_map_id_seq.nextval into map_id from dual;
    insert into ftp_tp_pp_node_header (
      node_map_id,
      tp_process_object_def_id,
      tp_object_def_id,
      pp_object_def_id,
      adj_object_def_id,
      effective_start_date,
      effective_end_date,
      creation_date,
      created_by,
      last_updated_by,
      last_update_date,
      last_update_login,
      created_by_object_id,
      created_by_request_id,
      last_updated_by_object_id,
      last_updated_by_request_id
    ) values (
      map_id,
      proc_def_id,
      tp_def_id,
      pp_def_id,
      adj_def_id,
      e_s_date,
      e_e_date,
      sysdate,
      fnd_global.user_id,
      fnd_global.user_id,
      sysdate,
      fnd_global.login_id,
      OBJECT_ID,
      REQUEST_ID,
      OBJECT_ID,
      REQUEST_ID
    );
    return map_id;
  end create_new_map_header;
  procedure get_tp_info(
    proc_def_id in number,
    e_date in date,
    tp_info out nocopy obj_info_type,
    tp_hier_info out nocopy obj_info_type,
    pp_info out nocopy obj_info_type,
    pp_hier_info out nocopy obj_info_type,
    adj_info out nocopy obj_info_type,
    adj_hier_info out nocopy obj_info_type)
  is
    tp_obj_id number;                    -- tp object/object_def
    pp_obj_id number;                    -- pp object/object_def
    adj_obj_id number;                   -- adj object/object_def
  begin
    select transfer_price_object_id, prepay_object_id, adjustment_object_id
      into tp_obj_id, pp_obj_id, adj_obj_id
      from ftp_tp_process_rule
     where object_definition_id = proc_def_id;

    -- convert object ids to obj_def_id
    --get Transfer Price obj def if used for this rule
    if tp_obj_id is not null and tp_obj_id > 0 then
      get_obj_def(tp_obj_id,
                  e_date,
                  tp_info);
      get_hier_info(tp_obj_id,
                    e_date,
                    tp_hier_info);
    end if;

    -- get prepayment def id if used for this rule
    if pp_obj_id is not null and pp_obj_id > 0 then
       get_obj_def(pp_obj_id,
                   e_date,
                   pp_info);
       get_hier_info(pp_obj_id,
                     e_date,
                     pp_hier_info);
    end if;

    -- get adjustment def id if used for this rule
    if adj_obj_id is not null and adj_obj_id > 0 then
       get_obj_def(adj_obj_id,
                   e_date,
                   adj_info);
       get_hier_info(adj_obj_id,
                     e_date,
                     adj_hier_info);
    end if;
  end get_tp_info;
  --Check for hierarchy updates
  procedure check_hier_update (map_id in number,
  proc_def_id in number,
  tp_def_id in number,
  pp_def_id in number,
  adj_def_id in number,
  e_date in date,
  tp_hier_def_id in number,
  pp_hier_def_id in number,
  adj_hier_def_id in number,
  hier_updated out nocopy boolean
  )
  is
  l_tp_hier_date DATE;
  l_pp_hier_date DATE := NULL;
  l_adj_hier_date DATE := NULL;
  l_node_map_date DATE;
  begin
  --get the latest last_update_date
  select max(last_update_date) into l_tp_hier_date from fem_ln_items_hier h
  where h.hierarchy_obj_def_id = tp_hier_def_id group by h.hierarchy_obj_def_id;

  if pp_def_id is not null then
   if pp_hier_def_id is not null then
      select max(last_update_date) into l_pp_hier_date from fem_ln_items_hier h
      where h.hierarchy_obj_def_id = pp_hier_def_id group by h.hierarchy_obj_def_id;
   end if;
  end if;

  if adj_def_id is not null then
   if adj_hier_def_id is not null then
      select max(last_update_date) into l_adj_hier_date from fem_ln_items_hier h
      where h.hierarchy_obj_def_id = adj_hier_def_id group by h.hierarchy_obj_def_id;
   end if;
  end if;

  --get the last_update_date of node map table
  select last_update_date into l_node_map_date from ftp_tp_pp_node_header where
  tp_process_object_def_id = proc_def_id
  and (tp_object_def_id = tp_def_id
      or tp_object_def_id is null and tp_def_id is null)
  and (pp_object_def_id = pp_def_id
       or pp_object_def_id is null and pp_def_id is null)
  and (adj_object_def_id = adj_def_id
       or adj_object_def_id is null and adj_def_id is null)
  and trunc(e_date) between effective_start_date and
                                           nvl(effective_end_date,
                                               to_date('99991231',
                                                       'YYYYMMDD'));

  --check tp hier date
  if(l_tp_hier_date > l_node_map_date)then
   hier_updated := TRUE;
  else
   hier_updated := FALSE;
  end if;
  --check pp hier date
  if(l_pp_hier_date is not null)then
   if(l_pp_hier_date > l_node_map_date)then
    hier_updated := TRUE;
   else
    hier_updated := FALSE;
   end if;
  end if;
  --check adj hier date
  if(l_adj_hier_date is not null)then
   if(l_adj_hier_date > l_node_map_date)then
    hier_updated := TRUE;
   else
    hier_updated := FALSE;
   end if;
  end if;
  --update the header table to set last_update_date.
  if hier_updated then
    update ftp_tp_pp_node_header a
       set last_updated_by = fnd_global.user_id,
           last_update_date = sysdate,
           last_update_login = fnd_global.login_id
     where a.node_map_id = map_id;
  end if;

  exception
   when others then
      hier_updated := FALSE;
  end check_hier_update;

  -- updates end date for node_map_id
  procedure fix_end_date(map_id in number,
                         process_info in obj_info_type)
  is
    tp_info obj_info_type;
    pp_info obj_info_type;
    adj_info obj_info_type;
    tp_hier_info obj_info_type;
    pp_hier_info obj_info_type;
    adj_hier_info obj_info_type;
    s_date date;
    e_date date;
  begin
    -- get start date
    select effective_start_date into s_date
      from ftp_tp_pp_node_header
      where node_map_id = map_id;
    get_tp_info(process_info.obj_id,
                s_date,
                tp_info,
                tp_hier_info,
                pp_info,
                pp_hier_info,
                adj_info,
                adj_hier_info);
    get_min_range(obj_info_array(process_info,
                                 tp_info,
                                 pp_info,
                                 adj_info,
                                 tp_hier_info,
                                 pp_hier_info,
                                 adj_hier_info),
                  s_date,
                  e_date);
    -- set end date to end date from previous.
    update ftp_tp_pp_node_header a
       set effective_end_date = e_date,
           last_updated_by = fnd_global.user_id,
           last_update_date = sysdate,
           last_update_login = fnd_global.login_id
     where a.node_map_id = map_id;
  end fix_end_date;
  procedure VALIDATE_NODE_MAP(
    OBJ_ID IN NUMBER,
    REQ_ID IN NUMBER,
    EFFECTIVE_DATE IN DATE,
    NODE_MAP_ID OUT NOCOPY NUMBER,
    DIM_COL_NAME OUT NOCOPY VARCHAR2)
  is
    process_info obj_info_type;
    tp_info obj_info_type;
    pp_info obj_info_type;
    adj_info obj_info_type;
    tp_hier_info obj_info_type;
    pp_hier_info obj_info_type;
    adj_hier_info obj_info_type;
    map_id obj_info_type;
    s_date date;
    e_date date;
    hier_updated boolean;
  begin
    -- Save the object id and request id
    OBJECT_ID := OBJ_ID;
    REQUEST_ID := REQ_ID;

    get_obj_def(OBJ_ID, EFFECTIVE_DATE, process_info);
    get_tp_info(process_info.obj_id,
                effective_date,
                tp_info,
                tp_hier_info,
                pp_info,
                pp_hier_info,
                adj_info,
                adj_hier_info);
    -- Could check here to verify that if there is a prepayment ID,
    -- the value_set_id for both of them match.
    get_min_range(obj_info_array(process_info,
                                 tp_info,
                                 pp_info,
                                 adj_info,
                                 tp_hier_info,
                                 pp_hier_info,
                                 adj_hier_info),
                  s_date,
                  e_date);
    begin
      select node_map_id,
             effective_start_date,
             effective_end_date
        into map_id.obj_id,
             map_id.eff_start_date,
             map_id.eff_end_date
        from ftp_tp_pp_node_header
       where tp_process_object_def_id = process_info.obj_id
         and (tp_object_def_id = tp_info.obj_id
              or tp_object_def_id is null and tp_info.obj_id is null)
         and (pp_object_def_id = pp_info.obj_id
              or pp_object_def_id is null and pp_info.obj_id is null)
         and (adj_object_def_id = adj_info.obj_id
              or adj_object_def_id is null and adj_info.obj_id is null)
         and trunc(effective_date) between effective_start_date and
                                           nvl(effective_end_date,
                                               to_date('99991231',
                                                       'YYYYMMDD'));
      node_map_id := map_id.obj_id;
      -- verify that we do indeed have the correct version.
      if s_date <> map_id.eff_start_date then
         -- there is been a change (i.e., a hierarchy or underlying ID has
         -- changed).  Fix the end date for the map_id so it doesn't
         -- show up again.
         fix_end_date(node_map_id, process_info);
         node_map_id := null;
      end if;

      if node_map_id is not null then
         --check for hier update
         check_hier_update(node_map_id,
          process_info.obj_id,
          tp_info.obj_id,
          pp_info.obj_id,
          adj_info.obj_id,
          effective_date,
          tp_hier_info.obj_id,
          pp_hier_info.obj_id,
          adj_hier_info.obj_id,
          hier_updated
         );
      end if;
      exception when NO_DATA_FOUND then null; -- no obj_id
    end;
    if node_map_id is null then
      -- need new ID
      node_map_id := create_new_map_header(process_info.obj_id,
                                           tp_info.obj_id,
                                           pp_info.obj_id,
                                           adj_info.obj_id,
                                           s_date,
                                           e_date);
      build_node_map(node_map_id,
                     tp_info.value_set_id,
                     tp_info.obj_id,
                     tp_hier_info.obj_id,
                     pp_info.obj_id,
                     pp_hier_info.obj_id,
                     adj_info.value_set_id,
                     adj_info.obj_id,
                     adj_hier_info.obj_id);
    else
      if e_date <> map_id.eff_end_date then
        -- effective end date has changed, update it.
        update ftp_tp_pp_node_header a
           set effective_end_date = e_date,
               last_updated_by = fnd_global.user_id,
               last_update_date = sysdate,
               last_update_login = fnd_global.login_id,
               -- The object id will always be the same.
               created_by_request_id = REQUEST_ID,
               last_updated_by_request_id = REQUEST_ID
         where a.node_map_id = validate_node_map.node_map_id;
      end if;

      --if hierarchy updated, update the node map detail table
      if hier_updated then
         --delete existing details and recreate them
         delete ftp_tp_pp_node_map a where a.node_map_id = node_map_id;
         build_node_map(node_map_id,
                     tp_info.value_set_id,
                     tp_info.obj_id,
                     tp_hier_info.obj_id,
                     pp_info.obj_id,
                     pp_hier_info.obj_id,
                     adj_info.value_set_id,
                     adj_info.obj_id,
                     adj_hier_info.obj_id);
      end if;
    end if;
    -- set dim_col_name
    dim_col_name := main_dim_col_name;
  end VALIDATE_NODE_MAP;
  -- return the appropirate instrument table columns
  -- to update given the tp process id (to allow for
  -- future expansion to support multiple transfer rate
  -- columns.
  procedure GET_TP_OUT_COLS(
    obj_id in number,
    data_set_id in number,
    jobid  in number,
    effective_date in date,
    TRATE_COL out nocopy varchar2,
    MSPREAD_COL out nocopy varchar2,
    OAS_COL out nocopy varchar2,
    SS_COL out nocopy varchar2,
    LAST_OBJID_COL out nocopy varchar2,
    LAST_REQID_COL out nocopy varchar2
  ) is
    process_info OBJ_INFO_TYPE;
    remain_term_flag FTP_TP_PROCESS_RULE.CALC_MODE_CODE%TYPE;
    magic_val varchar2(2000);
  begin
    get_obj_def(obj_id, effective_date, process_info);
    --modified to read from ftp_tp_proc_stoch_params from earlier ftp_tp_process_rule

    select calc_mode_code into remain_term_flag from ftp_tp_proc_stoch_params
    where object_definition_id = process_info.obj_id and job_id = jobid;
    -- this allows us more flexibility later, if we want we can
    -- vary these by having the process record them or using
    -- some other mechanism.
    if remain_term_flag = 0 then
      TRATE_COL := 'transfer_rate';
      MSPREAD_COL := 'matched_spread'; --Changed from matched_spread_c
      OAS_COL := 'historic_oas';
      SS_COL := 'historic_static_spread';
    else -- remaining term
      TRATE_COL := 'tran_rate_rem_term';
      MSPREAD_COL := '';
      OAS_COL := 'cur_oas';
      SS_COL := 'cur_static_spread';
    end if;
    LAST_OBJID_COL := 'last_updated_by_object_id';
    LAST_REQID_COL := 'last_updated_by_request_id';
    -- this here simplifies my debug situation
    begin
       fnd_profile.get('MAGIC_DATA_SET_TRAN_RATE', magic_val);
       exception when others then magic_val := null;
    end;
    if (data_set_id > 0 and magic_val = 'MAGIC') then
       trate_col := trate_col || '_' || data_set_id;
       if mspread_col is not null then
          mspread_col := mspread_col || '_' || data_set_id;
       end if;
       oas_col := oas_col || '_' || data_set_id;
       ss_col := ss_col || '_' || data_set_id;
    end if;

 exception
   when others then NULL;

  end GET_TP_OUT_COLS;
  -- return information for joining ftp_pp_node_map to
  -- attribute table to get account type.
  -- aliases needed to properly generate where clause.
  procedure ACCT_TYPE_JOIN_INFO(
    TBL_ALIAS in varchar2, -- alias of main table
    TBL_JOIN_ALIAS in varchar2, -- alias of attribute table
    JOIN_TBL_NAME out NOCOPY varchar2, -- table to join to
    ATTR_COL_NAME out NOCOPY varchar2, -- attribute column to select
    IS_ASSET_DECODE out NOCOPY varchar2, -- decode to determine if asset/liab
    WHERE_CLAUSE out NOCOPY varchar2   -- where clause for join
  )
  is
  begin
    select attribute_table_name into join_tbl_name
      from fem_xdim_dimensions
     where dimension_id = main_dim_id;
    select attribute_value_column_name into attr_col_name
      from fem_dim_attributes_b
     where dimension_id = main_dim_id
       and attribute_id = acct_type_attr_id;
    where_clause := tbl_alias || '.line_item_id'
      || '=' || tbl_join_alias || '.' || main_dim_col_name
      || '(+) and '
      || tbl_alias || '.value_set_id'
      || '=' || tbl_join_alias || '.value_set_id(+)'
      || ' and '
      || tbl_join_alias || '.attribute_id(+)='
      || acct_type_attr_id;
    -- populate IS_ASSET_DECODE -- 1 if asset, 0 liability
    -- second bit if off balance sheet
    is_asset_decode := 'decode(' || tbl_join_alias || '.' || attr_col_name;
    declare
       -- this is really ugly because the FEM data modeling group refuses
       -- to do anything in the most straightforward way
       -- I refuse to look up the dim_attriube_name column
       cursor c is
         select ext.ext_account_type_code,
                (decode(af.dim_attribute_varchar_member, 'Y', 1, 0)
                 + decode(obf.dim_attribute_varchar_member, 'Y', 2, 0)) flags
         from fem_ext_account_types_b ext,
              fem_ext_acct_types_attr af,
              fem_ext_acct_types_attr obf
        where ext.ext_account_type_code = af.ext_account_type_code
          and af.attribute_id = ASSET_FLAG_ID
          and ext.ext_account_type_code = obf.ext_account_type_code
          and obf.attribute_id = OFF_BAL_FLAG_ID;
    begin
      for cur in c loop
        is_asset_decode := is_asset_decode || ','''
                        || cur.ext_account_type_code || ''',' || cur.flags;
      end loop;
    -- second to last case is null case, last case is unknown
    -- third bit set means there was none defined,
    -- fourth bit set means the type was invalid
    is_asset_decode := is_asset_decode || ',null,5,9)';
    end;
  end ACCT_TYPE_JOIN_INFO;
  -- this is not yet complete (nor are we sure it will even be used)
  procedure REGISTER_TP_PROCESS(
    OBJ_ID in number,
    LEDGER_ID in number,
    EFFECTIVE_DATE in date,
    PROCESS_PARAM_ID out NOCOPY number
  ) is
  begin
    -- register with fem_dimensions_pkg
    fem_dimension_util_pkg.fem_initialize(ledger_id);
    process_param_id := -1;
  end REGISTER_TP_PROCESS;
  -- return information for joining ftp_pp_node_map to
  -- attribute table to get account type.
  -- aliases needed to properly generate where clause.
  procedure CHG_CRDT_ACC_BASIS_JOIN(
    TBL_ALIAS in varchar2, -- alias of main table
    TBL_JOIN_ALIAS in varchar2, -- alias of attribute table
    JOIN_TBL_NAME out NOCOPY varchar2, -- table to join to
    Attr_COL_NAME out NOCOPY varchar2, -- attribute column to select
    ACCR_DECODE out NOCOPY varchar2, -- decode to determine if asset/liab
    WHERE_CLAUSE out NOCOPY varchar2   -- where clause for join
  )
  is
  begin
    join_tbl_name := 'FTP_LN_ITEM_CURRENCIES'; -- Changed to FTP_LN_ITEM_CURRENCIES since used only by FTP -Mallica
    attr_col_name := 'TP_CHG_CRD_ACCRUAL_BASIS_CODE';
    where_clause := tbl_alias || '.line_item_id'
                 || '=' || tbl_join_alias || '.line_item_id(+)'
                 || ' and '
                 || tbl_alias || '.value_set_id'
                 || '=' || tbl_join_alias || '.value_set_id'
                 || ' and '
                 || tbl_alias || '.currency'
                 || '=' || tbl_join_alias || '.currency_code(+)';
    -- this will probably change
    accr_decode := tbl_join_alias || '.' || attr_col_name;
  end CHG_CRDT_ACC_BASIS_JOIN;

/***************************************************************************
 Desc  : Procedure queries the list of input data set codes.  Provides a list
         of input dataset codes in the form a string.
 Pgmr  : Raghuram K Nanda
 Date  : 16-Aug-2005
 **************************************************************************/
PROCEDURE get_input_datasets(
   p_io_def_id     IN   NUMBER,
   x_datasets      IN OUT NOCOPY VARCHAR2
)
IS

BEGIN

FOR indx IN (select input_dataset_code from fem_ds_input_lists
            where dataset_io_obj_def_id = p_io_def_id)
LOOP

   x_datasets := x_datasets || indx.input_dataset_code ||',';

END LOOP;

IF (x_datasets IS NULL)
THEN
   RAISE FND_API.G_EXC_ERROR;
END IF;

x_datasets := '(' || RTRIM(x_datasets,',') || ')';

END get_input_datasets;

/***************************************************************************
 Desc  : Procedure to initiate creation of process locks metadata required
         for the process run.
 Pgmr  : Raghuram K Nanda
 Date  : 16-Aug-2005
 -- Parameters
 -- OUT
   --    x_exec_lock_exists            OUT   VARCHAR2
   --       Indicates whether an execution lock exists.
   --       Returns 'T' if an execution lock exists, and 'F' if an execution
   --       lock does not exist.
   --    x_return_status               OUT   VARCHAR2
   --       Possible return status:
   --          FND_API.G_RET_STS_SUCCESS     -  Call was successful, msgs may
   --                                           still be present (check x_msg_count)
   --          FND_API.G_RET_STS_ERROR       -  Call was not successful, msgs should
   --                                           be present (check x_msg_count)
   --          FND_API.G_RET_STS_UNEXP_ERROR -  Unexpected errors occurred which are
   --                                           unrecoverable (check x_msg_count)
   --
   --    x_msg_count                   OUT   NUMBER
   --       Count of messages returned.  If x_msg_count = 1, then the message is returned
   --       in x_msg_data.  If x_msg_count > 1, then messages are returned via FND_MSG_PUB.
   --
   --    x_msg_data                    OUT   VARCHAR2
   --       Error message returned.
 **************************************************************************/
PROCEDURE START_PROCESS_LOCKS(
   p_request_id               IN    NUMBER,
   p_object_id                IN    NUMBER,
   p_cal_period_id            IN    NUMBER,
   p_ledger_id                IN    NUMBER,
   p_dataset_def_id           IN    NUMBER,
   p_job_id                   IN    NUMBER,
   p_condition_id             IN    NUMBER,
   p_effective_date           IN    DATE,
   p_user_id                  IN    NUMBER,
   p_last_update_login        IN    NUMBER,
   p_program_id               IN    NUMBER,
   p_program_login_id         IN    NUMBER,
   p_program_application_id   IN    NUMBER,
   x_exec_lock_exists         OUT NOCOPY VARCHAR2,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
process_info      obj_info_type;
l_output_ds       NUMBER;
l_data_table      VARCHAR2(30);
l_exception_code  VARCHAR2(80);
l_msg             VARCHAR2(300);
l_tbl_alias       VARCHAR2(1);
l_condition_id    NUMBER;
l_condition_sql   VARCHAR2(4000) := NULL;
l_exec_state      VARCHAR2(30); -- normal, restart, rerun
l_prev_request_id NUMBER;
l_date_str        VARCHAR2(26);
l_stmt_type       VARCHAR2(10);

TYPE varchar_std_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
l_table_names  varchar_std_type;

-- cursor that retrieves the tables that should be used as source
CURSOR l_cur_tables IS select table_name from ftp_tp_proc_tabls_params
where object_definition_id = process_info.obj_id and job_id = p_job_id;

BEGIN
/*FEM_ENGINES_PKG.Put_Message(
 p_app_name => 'FTP',
 p_msg_name => 'START_PROCESS_LOCKS.BEGIN',
 p_token1   => 'OBJ_ID',
 p_value1   => p_object_id,
 p_token2   => 'EFF_DATE',
 p_value2   => p_effective_date
);*/
-- initialize our status to 'we are good!'
x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Initialize FND message queue
FND_MSG_PUB.Initialize;

savepoint register_request_pub;

-- Get the object definition id of the process
get_obj_def(p_object_id, p_effective_date, process_info);

--Get the output dataset code for the given IODD
select output_dataset_code into l_output_ds from fem_ds_input_output_defs
where dataset_io_obj_def_id = p_dataset_def_id;

/*FEM_ENGINES_PKG.Put_Message(
             p_app_name => 'FTP',
             p_msg_name => 'START_PROCESS_LOCKS',
             p_token1   => 'OUT_DS',
             p_value1   => l_output_ds
            );*/
BEGIN
select filter_object_id into l_condition_id from ftp_tp_proc_stoch_params where
object_definition_id = process_info.obj_id and job_id = p_job_id;
EXCEPTION
   when others then
      -- when no condition id, still fine
      NULL;
END;

IF l_condition_id = 0 THEN
   l_condition_id := NULL;
END IF;

/*FEM_ENGINES_PKG.Put_Message(
             p_app_name => 'FTP',
             p_msg_name => 'START_PROCESS_LOCKS',
             p_token1   => 'COND_ID',
             p_value1   => l_condition_id
            );*/

--Do the request registration
FEM_PL_PKG.register_request(
	p_api_version => c_api_version,
	p_commit => FND_API.G_FALSE,
	p_request_id => p_request_id,
	p_cal_period_id => p_cal_period_id,
	p_ledger_id => p_ledger_id,
	p_dataset_io_obj_def_id => p_dataset_def_id,
	p_output_dataset_code => l_output_ds,
	p_effective_date => trunc(p_effective_date),
	p_rule_set_obj_def_id => 0 /*process_info.obj_id*/, --<< FIX IT >>
	p_user_id => p_user_id,
	p_last_update_login => p_last_update_login,
	p_program_id => p_program_id,
	p_program_login_id => p_program_login_id,
   p_program_application_id => p_program_application_id,
	x_msg_count => x_msg_count,
   x_msg_data => x_msg_data,
   x_return_status => x_return_status
);

/*FEM_ENGINES_PKG.Put_Message(
 p_app_name => 'FTP',
 p_msg_name => 'AFTER REGISTER REQUEST',
 p_token1   => 'MSG_COUNT',
 p_value1   => x_msg_count,
 p_token2   => 'MSG_DATA',
 p_value2   => x_msg_data
);*/

IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   RAISE FND_API.G_EXC_ERROR;
END IF;

-- Read the rule to retieve the names of the tables to process
OPEN l_cur_tables;
FETCH l_cur_tables BULK COLLECT INTO l_table_names;
CLOSE l_cur_tables;

l_date_str := FND_DATE.date_to_canonical(p_effective_date);

/*FEM_ENGINES_PKG.Put_Message(
 p_app_name => 'FTP',
 p_msg_name => 'IN START PROCESS LOCK',
 p_token1   => 'DATE_STR',
 p_value1   => l_date_str
);*/

FOR i IN 1..l_table_names.COUNT
LOOP
   -- Get the table name to be processed.
   l_data_table := l_table_names(i);
   IF (l_condition_id IS NOT NULL)
   THEN
      l_condition_sql := NULL;
      /*FEM_ENGINES_PKG.Put_Message(
       p_app_name => 'FTP',
       p_msg_name => 'IN START PROCESS LOCK',
       p_token1   => 'TABLE_NAME',
       p_value1   => l_data_table,
       p_token2   => 'ALIAS',
       p_value2   => l_tbl_alias
      );*/
      /*FEM_CONDITIONS_API.generate_condition_predicate(
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_return_status => x_return_status,
         p_condition_obj_id => l_condition_id,
         p_rule_effective_date => l_date_str,
         p_input_fact_table_name => l_data_table,
         p_table_alias => l_tbl_alias,
         p_display_predicate => 'N',
         p_return_predicate_type => 'BOTH',
         p_logging_turned_on => 'N',
         x_predicate_string => l_condition_sql);*/
         BEGIN
         FEM_CONDITIONS_API.GENERATE_CONDITION_PREDICATE(
             x_msg_count, x_msg_data, l_condition_id,
             l_date_str,
             l_data_table,
             l_tbl_alias, 'N', 'BOTH', 'Y',
             l_condition_sql  );
         EXCEPTION
            when others then
               FEM_ENGINES_PKG.Put_Message(
                p_app_name => 'FTP',
                p_msg_name => 'WCLAUSE EXCEPTION',
                p_token1   => 'TABLE_NAME',
                p_value1   => l_data_table,
                p_token2   => 'MSG_DATA',
                p_value2   => x_msg_data
               );
         END;

   END IF;
   /*FEM_ENGINES_PKG.Put_Message(
    p_app_name => 'FTP',
    p_msg_name => 'AFTER CALL TO CONDITIONS API',
    p_token1   => 'OBJ_ID',
    p_value1   => p_object_id,
    p_token2   => 'condition',
    p_value2   => l_condition_sql,
    p_token3   => 'TABLE',
    p_value3   => l_data_table
   );*/
   --Check to see if chaining exists
   chaining_exists(
      p_request_id      => p_request_id,
      p_object_id       => p_object_id,
      p_cal_period_id   => p_cal_period_id,
      p_ledger_id       => p_ledger_id,
      p_dataset_def_id  => p_dataset_def_id,
      p_condition_str   => l_condition_sql,
      p_effective_date  => p_effective_date,
      p_table_name      => l_data_table,
      x_exec_lock_exists  => x_exec_lock_exists
   );


   IF x_exec_lock_exists = 'T' THEN
      /*FEM_ENGINES_PKG.Put_Message(
       p_app_name => 'FTP',
       p_msg_name => 'AFTER CHAINING EXISTS',
       p_token1   => 'CAL_ID',
       p_value1   => p_cal_period_id
      );*/
      --undo request registration
      rollback to register_request_pub;
      l_table_names.DELETE;
      RETURN;
   END IF;

END LOOP;

--Check if object executions exists. If not then register
FEM_PL_PKG.register_object_execution(
  p_api_version => c_api_version,
  p_request_id => p_request_id,
  p_object_id => p_object_id,
  p_exec_object_definition_id => process_info.obj_id,
  p_user_id => p_user_id,
  p_last_update_login => p_last_update_login,
  x_exec_state => l_exec_state,
  x_prev_request_id => l_prev_request_id,
  x_msg_count => x_msg_count,
  x_msg_data => x_msg_data,
  x_return_status => x_return_status
);

IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   RAISE FND_API.G_EXC_ERROR;
END IF;

/*--Register all obj defs read during processing
FEM_PL_PKG.register_object_def(
   p_api_version => c_api_version,
   p_request_id => p_request_id,
   p_object_id => p_object_id,
   p_object_definition_Id => process_info.obj_id,
   p_user_id => p_user_id,
   p_last_update_login => p_last_update_login,
   x_msg_count => x_msg_count,
   x_msg_data => x_msg_data,
   x_return_status => x_return_status
);

IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   RAISE FND_API.G_EXC_ERROR;
END IF;*/

-- Register all dependent object definitions
FEM_PL_PKG.register_dependent_objdefs(
   p_api_version => c_api_version,
   p_request_id => p_request_id,
   p_object_id => p_object_id,
   p_exec_object_definition_id => process_info.obj_id,
   p_effective_date => trunc(p_effective_date),
   p_user_id => p_user_id,
   p_last_update_login => p_last_update_login,
   x_msg_count => x_msg_count,
   x_msg_data => x_msg_data,
   x_return_status => x_return_status
);
IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   RAISE FND_API.G_EXC_ERROR;
END IF;

--Register all the selected tables that are written to, during processing
FOR i IN 1 .. l_table_names.COUNT LOOP
   -- Set the statement typ
   IF (l_table_names(i) <> 'FEM_BALANCES')
   THEN
      l_stmt_type := 'UPDATE';
   ELSE
      l_stmt_type := c_stmt_type;
   END IF;
   FEM_PL_PKG.register_table(
      p_api_version => c_api_version,
      p_request_id => p_request_id,
      p_object_id => p_object_id,
      p_table_name => l_table_names(i),
      p_statement_type => l_stmt_type,
      p_num_of_output_rows => 0,
      p_user_id  => p_user_id,
      p_last_update_login => p_last_update_login,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      x_return_status => x_return_status
   );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
END LOOP;

-- Register the Node Map Tables as well
-- Register FTP_TP_PP_NODE_HEADER and FTP_TP_PP_NODE_MAP
FEM_PL_PKG.register_table(
      p_api_version => c_api_version,
      p_request_id => p_request_id,
      p_object_id => p_object_id,
      p_table_name => 'FTP_TP_PP_NODE_HEADER',
      p_statement_type => c_stmt_type,
      p_num_of_output_rows => 0,
      p_user_id  => p_user_id,
      p_last_update_login => p_last_update_login,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      x_return_status => x_return_status
   );

IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   RAISE FND_API.G_EXC_ERROR;
END IF;

FEM_PL_PKG.register_table(
      p_api_version => c_api_version,
      p_request_id => p_request_id,
      p_object_id => p_object_id,
      p_table_name => 'FTP_TP_PP_NODE_MAP',
      p_statement_type => c_stmt_type,
      p_num_of_output_rows => 0,
      p_user_id  => p_user_id,
      p_last_update_login => p_last_update_login,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      x_return_status => x_return_status
   );

IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   RAISE FND_API.G_EXC_ERROR;
END IF;

/*FEM_ENGINES_PKG.Put_Message(
 p_app_name => 'FTP',
 p_msg_name => 'AFTER register_table END',
 p_token1   => 'MSG_COUNT',
 p_value1   => x_msg_count,
 p_token2   => 'MSG_DATA',
 p_value2   => x_msg_data,
 p_token3   => 'RETURN_STATUS',
 p_value3   => x_return_status
);*/
l_table_names.DELETE;
FND_MSG_PUB.Count_And_Get
            (p_encoded => 'F',
             p_count => x_msg_count,
             p_data  => x_msg_data);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get
            (p_encoded => 'F',
             p_count => x_msg_count,
             p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
      rollback to register_request_pub;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      l_msg := SUBSTR(SQLERRM, 1, 300);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FEM_ENGINES_PKG.Put_Message(
       p_app_name => 'FTP',
       p_msg_name => 'UNEXP EXCEPTION',
       p_token1   => 'SQLERRM',
       p_value1   => l_msg
      );
      FND_MSG_PUB.Count_And_Get
            (p_encoded => 'F',
             p_count => x_msg_count,
             p_data  => x_msg_data);
      rollback to register_request_pub;

   WHEN OTHERS THEN
      l_msg := SUBSTR(SQLERRM, 1, 300);

      --DBMS_OUTPUT.PUT_LINE(l_msg);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FEM_ENGINES_PKG.Put_Message(
       p_app_name => 'FTP',
       p_msg_name => 'UNEXP EXCEPTION',
       p_token1   => 'DATE',
       p_value1   => trunc(p_effective_date),
       p_token2   => 'SQLERRM',
       p_value2   => SQLERRM
      );
      FND_MSG_PUB.Count_And_Get
            (p_encoded => 'F',
             p_count => x_msg_count,
             p_data  => x_msg_data);

      rollback to register_request_pub;

END START_PROCESS_LOCKS;

/***************************************************************************
 Desc  : Procedure to stop process locking.
 Pgmr  : Raghuram K Nanda
 Date  : 16-Aug-2005
 **************************************************************************/
PROCEDURE STOP_PROCESS_LOCKS(
   p_request_id      IN    NUMBER,
   p_object_id       IN    NUMBER,
   p_cal_period_id   IN    NUMBER,
   p_ledger_id       IN    NUMBER,
   p_dataset_def_id  IN    NUMBER,
   p_exec_status_code IN   VARCHAR2,
   p_job_id          IN    NUMBER,
   p_condition_id    IN    NUMBER,
   p_effective_date  IN    DATE,
   p_user_id         IN    NUMBER,
   p_last_update_login        IN    NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
)
IS

l_input_cnt       NUMBER;
l_total_inp       NUMBER;
l_output_cnt      NUMBER;
l_total_out       NUMBER;
process_info      obj_info_type;
l_select_stmt     VARCHAR2(4000);
l_input_ds        VARCHAR2(1000);
l_exception_code  VARCHAR2(80);
l_msg             VARCHAR2(4000);
l_tbl_alias       VARCHAR2(1);
l_condition_sql   VARCHAR2(4000);
l_condition_id    NUMBER;
l_exec_status_code   VARCHAR2(30);
l_date_str         VARCHAR2(26);
l_stmt_type       VARCHAR2(10);

l_b_data_location boolean;
l_output_ds       NUMBER;
l_ss_code         NUMBER;

f_set_status boolean;

TYPE varchar_std_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

l_table_names  varchar_std_type;
l_col_names    varchar_std_type;

/*TYPE number_std_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_input_ds  number_std_type;*/

-- cursor that retrieves the tables that should be used as source
CURSOR l_cur_tables IS select table_name from ftp_tp_proc_tabls_params
where object_definition_id = process_info.obj_id and job_id = p_job_id;

-- set up the flags
trate_prop_flg  ftp_tp_proc_stoch_params.trans_rate_propagate_flg%TYPE;
trate_calc_flg  ftp_tp_proc_stoch_params.trans_rate_calc_flg%TYPE;
ocost_prop_flg  ftp_tp_proc_stoch_params.option_cost_propagate_flg%TYPE;
ocost_calc_flg  ftp_tp_proc_stoch_params.option_cost_calc_flg%TYPE;

-- tdasgupt : Added for R12 Enhancements
l_adj_calc_flag ftp_tp_proc_stoch_params.adj_calc_flg%TYPE;
calcmode_flg ftp_tp_proc_stoch_params.calc_mode_code%TYPE;
pos number;
len number ;
len2 number := 5;
modify_valid_table_list varchar2(3000);
token varchar2(300);
i number;


BEGIN

-- initialize our status to 'we are good!'
x_return_status := FND_API.G_RET_STS_SUCCESS;
FND_MSG_PUB.Delete_Msg();
--Initialize sum variables
l_total_inp := 0;
l_total_out := 0;
l_input_cnt := 0;
l_output_cnt := 0;
l_b_data_location := FALSE;


FEM_ENGINES_PKG.TECH_MESSAGE(
   p_severity => fnd_log.level_error,
   p_module => g_block || '.STOP_PROCESS_LOCKS',
   p_msg_text => 'valid_table_list= '|| valid_table_list ||' g_alt_rate_obj.COUNT=' || g_alt_rate_obj.COUNT
);

-- Get the object definition id of the process
get_obj_def(p_object_id, p_effective_date, process_info);

--Get input dataset codes
get_input_datasets(
   p_io_def_id  => p_dataset_def_id,
   x_datasets   => l_input_ds
);

BEGIN
select filter_object_id into l_condition_id from ftp_tp_proc_stoch_params where
object_definition_id = process_info.obj_id and job_id = p_job_id;
EXCEPTION
   when others then
      -- when no condition id, still fine
      NULL;
END;

IF l_condition_id = 0 THEN
   l_condition_id := NULL;
END IF;

IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   RAISE FND_API.G_EXC_ERROR;
END IF;

If (valid_table_list IS NOT NULL) THEN
  modify_valid_table_list := valid_table_list || ',';
  i := 1;
  while( len2 > 0) LOOP
    select INSTR(modify_valid_table_list,',') into pos from dual;
    select length(modify_valid_table_list) into len from dual;
    select substr(modify_valid_table_list,0,pos-1) into token from dual;
    select LTRIM(RTRIM(token,''''),'''') into token from dual;

    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => fnd_log.level_error,
      p_module => g_block || '.tokens_generation',
      p_msg_text => 'token =' || token
      );

     l_table_names(i) := token;

     FEM_ENGINES_PKG.TECH_MESSAGE(
       p_severity => fnd_log.level_error,
       p_module => g_block || '.tokens_generation',
       p_msg_text => 'Before substr modify_valid_table_list= '|| modify_valid_table_list
       );

     select substr(modify_valid_table_list,pos+1,len) into modify_valid_table_list from dual;

     FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => fnd_log.level_error,
        p_module => g_block || '.tokens_generation',
        p_msg_text => 'After substr modify_valid_table_list= '|| modify_valid_table_list
        );

    select length(modify_valid_table_list) into len2 from dual;
    i := i + 1;
  END LOOP;
ELSE
  OPEN l_cur_tables;
  FETCH l_cur_tables BULK COLLECT INTO l_table_names;
  CLOSE l_cur_tables;
END IF;

l_date_str := FND_DATE.date_to_canonical(p_effective_date);

FEM_ENGINES_PKG.TECH_MESSAGE(
   p_severity => fnd_log.level_error,
   p_module => g_block || '.l_table_names preparation ready',
   p_msg_text => 'l_table_names.COUNT = '|| l_table_names.COUNT || 'l_table_names(1) =' || l_table_names(1)
);

FOR i IN 1..l_table_names.COUNT
LOOP

   FEM_ENGINES_PKG.TECH_MESSAGE(
     p_severity => fnd_log.level_error,
     p_module => g_block || '.after tokenizing iterating in l_table_names',
     p_msg_text => 'l_table_names(i) =' || l_table_names(i)
     );

   IF (l_condition_id IS NOT NULL)
   THEN
      /*FEM_CONDITIONS_API.generate_condition_predicate(
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_return_status => x_return_status,
         p_condition_obj_id => l_condition_id,
         p_rule_effective_date => FND_DATE.date_to_canonical(p_effective_date),
         p_input_fact_table_name => l_table_names(i),
         p_table_alias => l_tbl_alias,
         p_display_predicate => 'N',
         p_return_predicate_type => 'BOTH',
         p_logging_turned_on => 'N',
         x_predicate_string => l_condition_sql);*/
         BEGIN
         FEM_CONDITIONS_API.GENERATE_CONDITION_PREDICATE(
             x_msg_count, x_msg_data, l_condition_id,
             l_date_str,
             l_table_names(i),
             l_tbl_alias, 'N', 'BOTH', 'Y',
             l_condition_sql  );
         EXCEPTION
            when others then
               FEM_ENGINES_PKG.Put_Message(
                p_app_name => 'FTP',
                p_msg_name => 'WCLAUSE EXCEPTION',
                p_token1   => 'TABLE_NAME',
                p_value1   => l_table_names(i),
                p_token2   => 'MSG_DATA',
                p_value2   => x_msg_data
               );
         END;

   END IF;

   IF l_condition_sql IS NOT NULL THEN
     --get the l_input_cnt
     l_select_stmt := 'select count(*) from '|| l_table_names(i) ||
     ' where (ledger_id = :1) and (cal_period_id = :2) and dataset_code in '||
     l_input_ds||' and '||l_condition_sql;
   ELSE
     l_select_stmt := 'select count(*) from '|| l_table_names(i) ||
     ' where (ledger_id = :1) and (cal_period_id = :2) and dataset_code in '||
     l_input_ds;
   END IF;

   EXECUTE IMMEDIATE l_select_stmt INTO l_input_cnt USING p_ledger_id,p_cal_period_id;

   --do the summation of input rows across all tables
   l_total_inp := l_total_inp + l_input_cnt;

   --get the l_output_cnt
   l_select_stmt := 'select count(*) from '||l_table_names(i) ||
   ' where last_updated_by_object_id = :1 and last_updated_by_request_id = :2';

   EXECUTE IMMEDIATE l_select_stmt INTO l_output_cnt USING p_object_id,p_request_id;

   --Register updated columns
   IF l_table_names(i) <> 'FEM_BALANCES' THEN
   -- R12 Enh : Commenting out call to FTP_TP_PKG.GET_TP_OUT_COLS
   /*    FTP_TP_PKG.GET_TP_OUT_COLS(
         obj_id => p_object_id,
         data_set_id => p_dataset_def_id,
         jobid => p_job_id,
         effective_date =>p_effective_date,
         TRATE_COL => l_col_names(1),
         MSPREAD_COL => l_col_names(2),
         OAS_COL =>l_col_names(3),
         SS_COL => l_col_names(4),
         LAST_OBJID_COL => l_col_names(5),
         LAST_REQID_COL => l_col_names(6)
      ); */

      --  Get the transfer rate and calculate flag
      -- R12 Enh : Get the calc_mode_code,adj_calc_flg
      select trans_rate_propagate_flg,trans_rate_calc_flg,
      option_cost_propagate_flg,option_cost_calc_flg,calc_mode_code,adj_calc_flg
      into trate_prop_flg,trate_calc_flg,ocost_prop_flg,ocost_calc_flg,
      calcmode_flg,l_adj_calc_flag
      from ftp_tp_proc_stoch_params
      where object_definition_id = process_info.obj_id and job_id = p_job_id;

      FOR j IN 1..g_alt_rate_obj.COUNT
      LOOP
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => fnd_log.level_error,
          p_module => g_block || '.accessing g_alt_rate_obj',
          p_msg_text => 'g_alt_rate_obj(j).Account_Table_Name = ' || g_alt_rate_obj(j).Account_Table_Name
          );

        if ( g_alt_rate_obj(j).Account_Table_Name = l_table_names(i) ) THEN
          if ( calcmode_flg = 0 ) THEN --STANDARD
            l_col_names(1) := g_alt_rate_obj(j).TRANSFER_RATE_COL_NAME;
            l_col_names(2) := g_alt_rate_obj(j).MATCHED_SPREAD_COL_NAME;
            l_col_names(3) := g_alt_rate_obj(j).HISTORIC_OPTION_COL_NAME;
            l_col_names(4) := g_alt_rate_obj(j).HISTORIC_STAT_SPREAD_COL_NAME;
          ELSE
            l_col_names(1) := g_alt_rate_obj(j).REMAINING_TERM_COL_NAME;
            l_col_names(2) := g_alt_rate_obj(j).MATCHED_SPREAD_COL_NAME;
            l_col_names(3) := g_alt_rate_obj(j).CURRENT_OPTION_COL_NAME;
            l_col_names(4) := g_alt_rate_obj(j).CURRENT_STAT_SPREAD_COL_NAME;
          end if;
          l_col_names(5) := g_alt_rate_obj(j).ADJ_RATE_COL_NAME;
          l_col_names(6) := g_alt_rate_obj(j).ADJ_AMOUNT_COL_NAME;
          l_col_names(7) := g_alt_rate_obj(j).ADJ_MKT_VALUE;
        end if;
    END LOOP;

      l_col_names(8) := 'last_updated_by_object_id';
      l_col_names(9) := 'last_updated_by_request_id';

      -- Null out the cols that are not required.
      IF ((trate_prop_flg IS NULL) OR (trate_prop_flg = 0)) AND
         ((trate_calc_flg IS NULL) OR (trate_calc_flg = 0))
      THEN
         l_col_names(1) := NULL;
         l_col_names(2) := NULL;
      END IF;

      IF ((ocost_prop_flg IS NULL) OR (ocost_prop_flg = 0)) AND
         ((ocost_calc_flg IS NULL) OR (ocost_calc_flg = 0))
      THEN
         l_col_names(3) := NULL;
         l_col_names(4) := NULL;
      END IF;

      IF ((l_adj_calc_flag IS NULL) OR (l_adj_calc_flag = 0))
      THEN
         l_col_names(5) := NULL;
         l_col_names(6) := NULL;
         l_col_names(7) := NULL;
      END IF;

      -- Null the last cols
      l_col_names(8) := NULL;
      l_col_names(9) := NULL;

      -- Set the statement type
      l_stmt_type := 'UPDATE';
      FOR j IN 1..9 LOOP

      FEM_ENGINES_PKG.TECH_MESSAGE(
         p_severity => fnd_log.level_error,
         p_module => g_block || '.REGISTER_UPDATED_COLUMN',
         p_msg_text => 'before REGISTER_UPDATED_COLUMN j = ' || j ||' l_col_names(j)=' ||l_col_names(j)
         );

         IF l_col_names(j) IS NOT NULL THEN
            --Register updated columns
            fem_pl_pkg.REGISTER_UPDATED_COLUMN(
               p_api_version => c_api_version,
               p_request_id => p_request_id,
               p_object_id => p_object_id,
               p_table_name => l_table_names(i),
               p_statement_type => l_stmt_type,
               p_column_name => UPPER(l_col_names(j)),
               p_user_id => p_user_id,
               p_last_update_login => p_last_update_login,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data,
               x_return_status => x_return_status
            );
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;--end of is col name null
      END LOOP;--end of column names loop
   ELSE
      l_b_data_location := (l_output_cnt > 0);
      -- Set the statement type
      l_stmt_type := c_stmt_type;
   END IF;--end of if not fem_balances

   FEM_PL_PKG.update_num_of_output_rows(
      p_api_version => c_api_version,
      p_request_id => p_request_id,
      p_object_id => p_object_id,
      p_table_name => l_table_names(i),
      p_statement_type => l_stmt_type,
      p_num_of_output_rows => l_output_cnt,
      p_user_id => p_user_id,
      p_last_update_login => p_last_update_login,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      x_return_status => x_return_status
   );

   FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => fnd_log.level_error,
      p_module => g_block || '.debugg error',
      p_msg_text => 'Error Mesg 1'
      );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   l_total_out := l_total_out + l_output_cnt;

END LOOP;

-- Register teh FTP_TP_PP_NODE_MAP and FTP_TP_PP_NODE_HEADER info
select count(*) into l_output_cnt from FTP_TP_PP_NODE_HEADER
where created_by_object_id = OBJECT_ID and created_by_request_id = REQUEST_ID;

FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => fnd_log.level_error,
      p_module => g_block || '.debugg error',
      p_msg_text => 'Error Mesg 2'
      );

FEM_PL_PKG.update_num_of_output_rows(
      p_api_version => c_api_version,
      p_request_id => p_request_id,
      p_object_id => p_object_id,
      p_table_name => 'FTP_TP_PP_NODE_HEADER',
      p_statement_type => c_stmt_type,
      p_num_of_output_rows => l_output_cnt,
      p_user_id => p_user_id,
      p_last_update_login => p_last_update_login,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      x_return_status => x_return_status
   );

   FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => fnd_log.level_error,
      p_module => g_block || '.debugg error',
      p_msg_text => 'Error Mesg 3'
      );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

select count(*) into l_output_cnt from FTP_TP_PP_NODE_MAP
where created_by_object_id = OBJECT_ID and created_by_request_id = REQUEST_ID;

FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => fnd_log.level_error,
      p_module => g_block || '.debugg error',
      p_msg_text => 'Error Mesg 4'
      );

FEM_PL_PKG.update_num_of_output_rows(
      p_api_version => c_api_version,
      p_request_id => p_request_id,
      p_object_id => p_object_id,
      p_table_name => 'FTP_TP_PP_NODE_MAP',
      p_statement_type => c_stmt_type,
      p_num_of_output_rows => l_output_cnt,
      p_user_id => p_user_id,
      p_last_update_login => p_last_update_login,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      x_return_status => x_return_status
   );

   FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => fnd_log.level_error,
      p_module => g_block || '.debugg error',
      p_msg_text => 'Error Mesg 5'
      );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

--Update the number of input rows
FEM_PL_PKG.update_num_of_input_rows (
   p_api_version       => c_api_version,
   p_commit            => FND_API.G_FALSE,
   p_request_id        => p_request_id,
   p_object_id         => p_object_id,
   p_num_of_input_rows => l_total_inp,
   p_user_id           => p_user_id,
   p_last_update_login => p_last_update_login,
   x_msg_count         => x_msg_count,
   x_msg_data          => x_msg_data,
   x_return_status     => x_return_status
);

FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => fnd_log.level_error,
      p_module => g_block || '.debugg error',
      p_msg_text => 'Error Mesg 6'
      );

-- Update the data locations table
IF (l_b_data_location)
THEN
   -- Get Source System Code
   EXECUTE IMMEDIATE 'select source_system_code from fem_source_systems_vl
    where source_system_display_code = :1' into l_ss_code USING c_app;
   -- Get Output dataset code
   select output_dataset_code into l_output_ds from fem_ds_input_output_defs
   where dataset_io_obj_def_id = p_dataset_def_id;

   FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => fnd_log.level_error,
      p_module => g_block || '.debugg error',
      p_msg_text => 'Error Mesg 7'
      );

   -- Register the data location
   FEM_DIMENSION_UTIL_PKG.Register_Data_Location (
      p_request_id  => p_request_id,
      p_object_id  => p_object_id,
      p_table_name => 'FEM_BALANCES',
      p_ledger_id  => p_ledger_id,
      p_cal_per_id => p_cal_period_id,
      p_dataset_cd => l_output_ds,
      p_source_cd  => l_ss_code,
      p_load_status => NULL,
      p_avg_bal_flag => NULL,
      p_trans_curr => NULL
   );

   FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => fnd_log.level_error,
      p_module => g_block || '.debugg error',
      p_msg_text => 'Error Mesg 8'
      );

END IF;

IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   RAISE FND_API.G_EXC_ERROR;
END IF;

IF l_total_inp = 0 THEN
   FEM_ENGINES_PKG.Put_Message(
    p_app_name => 'FTP',
    p_msg_name => 'FTP_ZERO_REC_ERR'
   );
END IF;

IF l_total_out = 0 THEN
   l_exec_status_code := c_prg_err_rerun;
   f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',null);
ELSE
   l_exec_status_code := c_prg_success;
   f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('SUCCESS',null);
END IF;

FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => fnd_log.level_error,
      p_module => g_block || '.debugg error',
      p_msg_text => 'Error Mesg 9'
      );

fem_pl_pkg.UPDATE_OBJ_EXEC_STATUS(
   p_api_version => c_api_version,
   p_request_id => p_request_id,
   p_object_id => p_object_id,
   p_exec_status_code => l_exec_status_code,
   p_user_id => p_user_id,
   p_last_update_login => p_last_update_login,
   x_msg_count => x_msg_count,
   x_msg_data => x_msg_data,
   x_return_status => x_return_status
);

FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => fnd_log.level_error,
      p_module => g_block || '.debugg error',
      p_msg_text => 'Error Mesg 10'
      );

--update status of the request
FEM_PL_PKG.update_request_status(
   p_api_version => c_api_version,
   p_request_id => p_request_id,
   p_exec_status_code => l_exec_status_code,
   p_user_id  => p_user_id,
   p_last_update_login => p_last_update_login,
   x_msg_count => x_msg_count,
   x_msg_data => x_msg_data,
   x_return_status => x_return_status
);

FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => fnd_log.level_error,
      p_module => g_block || '.debugg error',
      p_msg_text => 'Error Mesg 11'
      );

IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   RAISE FND_API.G_EXC_ERROR;
END IF;

l_table_names.DELETE;
FND_MSG_PUB.Count_And_Get
            (p_encoded => 'F',
             p_count => x_msg_count,
             p_data  => x_msg_data);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get
            (p_encoded => 'F',
             p_count => x_msg_count,
             p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;

FEM_ENGINES_PKG.TECH_MESSAGE(
   p_severity => fnd_log.level_error,
   p_module => g_block || 'FND_API.G_EXC_ERROR',
   p_msg_text => 'sqlerrm =' || sqlerrm
);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fem_pl_pkg.UPDATE_OBJ_EXEC_STATUS(
         p_api_version => c_api_version,
         p_request_id => p_request_id,
         p_object_id => p_object_id,
         p_exec_status_code => c_prg_err_undo,
         p_user_id => p_user_id,
         p_last_update_login => p_last_update_login,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_return_status => x_return_status

      );
      f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',null);

FEM_ENGINES_PKG.TECH_MESSAGE(
   p_severity => fnd_log.level_error,
   p_module => g_block || 'FND_API.G_EXC_UNEXPECTED_ERROR',
   p_msg_text => 'sqlerrm =' || sqlerrm
);

      --update status of the request
      FEM_PL_PKG.update_request_status(
         p_api_version => c_api_version,
         p_request_id => p_request_id,
         p_exec_status_code => c_prg_err_undo,
         p_user_id  => p_user_id,
         p_last_update_login => p_last_update_login,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_return_status => x_return_status
      );
      FND_MSG_PUB.Count_And_Get
            (p_encoded => 'F',
             p_count => x_msg_count,
             p_data  => x_msg_data);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

FEM_ENGINES_PKG.TECH_MESSAGE(
   p_severity => fnd_log.level_error,
   p_module => g_block || 'OTHERS',
   p_msg_text => 'sqlerrm =' || sqlerrm
);

      fem_pl_pkg.UPDATE_OBJ_EXEC_STATUS(
         p_api_version => c_api_version,
         p_request_id => p_request_id,
         p_object_id => p_object_id,
         p_exec_status_code
          => c_prg_err_undo,
         p_user_id => p_user_id,
         p_last_update_login => p_last_update_login,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_return_status => x_return_status

      );
      f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',null);

      --update status of the request
      FEM_PL_PKG.update_request_status(
         p_api_version => c_api_version,
         p_request_id => p_request_id,
         p_exec_status_code => c_prg_err_undo,
         p_user_id  => p_user_id,
         p_last_update_login => p_last_update_login,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_return_status => x_return_status
      );
      FND_MSG_PUB.Count_And_Get
            (p_encoded => 'F',
             p_count => x_msg_count,
             p_data  => x_msg_data);



END STOP_PROCESS_LOCKS;

/***************************************************************************
 Desc  : Procedure to initiate ledger migration or calculation process.
 Pgmr  : Raghuram K Nanda
 Date  : 16-Aug-2005
 **************************************************************************/
PROCEDURE LEDGER_PROCESSING(
   p_request_id      IN    NUMBER,
   p_object_id       IN    NUMBER,
   p_cal_period_id   IN    NUMBER,
   p_ledger_id       IN    NUMBER,
   p_dataset_def_id  IN    NUMBER,
   p_job_id          IN    NUMBER,
   p_condition_id    IN    NUMBER,
   p_effective_date  IN    DATE,
   p_user_id         IN    NUMBER,
   p_last_update_login        IN    NUMBER,
   x_exec_lock_exists   OUT NOCOPY  VARCHAR2,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2
)
IS

TYPE t_obj_id_tbl IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
TYPE cv_curs IS REF CURSOR;

l_output_ds       NUMBER;
process_info      obj_info_type;
l_exception_code  VARCHAR2(80);
l_msg             VARCHAR2(4000);
l_tbl_alias       VARCHAR2(1);
l_condition_sql   VARCHAR2(4000);
--l_migrate_flg     BOOLEAN;
--l_trate_migr      VARCHAR2(1);
--l_ocost_migr      VARCHAR2(1);
l_uow_cursor      cv_curs;
l_sql_stmt        VARCHAR2(4000);
l_date_str         VARCHAR2(26);
l_created_by_obj_tbl t_obj_id_tbl;
l_created_by_req_tbl t_obj_id_tbl;

-- Praveen Attaluri (Bug Fix)
-- cursor that retrieves the tables that should be used as source
CURSOR l_cur_tables IS select table_name from ftp_tp_proc_tabls_params
where object_definition_id = process_info.obj_id and job_id = p_job_id;

TYPE varchar_std_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
l_table_names  varchar_std_type;
-- Praveen Attaluri (Bug Fix)

BEGIN

-- initialize our status to 'we are good!'
x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Get the object definition id of the process
get_obj_def(p_object_id, p_effective_date, process_info);

--Get the output dataset code for the given IODD
select output_dataset_code into l_output_ds from fem_ds_input_output_defs
where dataset_io_obj_def_id = p_dataset_def_id;

x_exec_lock_exists := 'F';

/*--Get the migrate option
select trans_rate_migrate_flg,option_cost_migrate_flg into l_trate_migr,l_ocost_migr
from ftp_tp_proc_stoch_params where object_definition_id = process_info.obj_id
and job_id = p_job_id;

IF (l_trate_migr = 1 OR l_ocost_migr = 1) THEN
   l_migrate_flg := TRUE;
ELSE
   l_migrate_flg := FALSE;
END IF;*/
l_date_str := FND_DATE.date_to_canonical(p_effective_date);


--Check to see if chaining exists before we move any further.
--IF l_migrate_flg
--THEN
   /*chaining_exists(
      p_request_id      => p_request_id,
      p_object_id       => p_object_id,
      p_cal_period_id   => p_cal_period_id,
      p_ledger_id       => p_ledger_id,
      p_dataset_def_id  => p_dataset_def_id,
      p_condition_str   => l_condition_sql,
      p_effective_date  => p_effective_date,
      p_table_name      => LEDGER_NAME,
      x_exec_lock_exists  => x_exec_lock_exists
   );


   IF x_exec_lock_exists = 'T' THEN
      RETURN;
   END IF;*/
--END IF;
--Chaining exists is now handled by following FEM
--x_exec_lock_exists is no longer required..
FEM_UD_PKG.Delete_Balances (
     p_api_version     => c_api_version,
     p_init_msg_list   => FND_API.G_TRUE,
     p_commit          => FND_API.G_FALSE,
     p_encoded         => FND_API.G_FALSE,
     x_return_status   => x_return_status,
     x_msg_count       => x_msg_count,
     x_msg_data        => x_msg_data,
     p_current_request_id => p_request_id,
     p_object_id       => p_object_id,
     p_cal_period_id   => p_cal_period_id,
     p_ledger_id       => p_ledger_id,
     p_dataset_code    => l_output_ds
);

IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   RAISE FND_API.G_EXC_ERROR;
END IF;

--- Praveen Attaluri (Bug Fix)
-- Get the tables that should be processed.  Chaining must be implemented
-- even if only calculation is selected on FEM_BALANCES.

-- Read the rule to retieve the names of the tables to process
OPEN l_cur_tables;
FETCH l_cur_tables BULK COLLECT INTO l_table_names;
CLOSE l_cur_tables;

-- Go through all the tables
FOR i IN 1..l_table_names.COUNT
LOOP

   IF (p_condition_id IS NOT NULL AND p_condition_id <> 0)
   THEN
      BEGIN
         FEM_CONDITIONS_API.GENERATE_CONDITION_PREDICATE(
             x_msg_count, x_msg_data, p_condition_id,
             l_date_str,
             l_table_names(i),
             l_tbl_alias, 'N', 'BOTH', 'Y',
             l_condition_sql  );
      EXCEPTION
         when others then
               FEM_ENGINES_PKG.Put_Message(
                p_app_name => 'FTP',
                p_msg_name => 'WCLAUSE EXCEPTION',
                p_token1   => 'TABLE_NAME',
                p_value1   => l_table_names(i),
                p_token2   => 'MSG_DATA',
                p_value2   => x_msg_data
               );
      END;
   END IF;

   -- Add the condition if necessary.  We have to add a separate condition to
   -- not include the previous runs of the calculation.  For FEM_BALANCES we only
   -- have to include the F140 so that we don't include the calculated results
   -- of the another rule using the same cal period and ledger_id.
   l_sql_stmt := 'select distinct CREATED_BY_OBJECT_ID,CREATED_BY_REQUEST_ID
      from ' || l_table_names(i) ||
      ' where ledger_id=:1 and cal_period_id = :2 and created_by_object_id <> :3';
   IF l_condition_sql IS NOT NULL THEN
      l_sql_stmt := l_sql_stmt || ' and '||l_condition_sql;
   END IF;

   IF (l_table_names(i) = LEDGER_NAME)
   THEN
      l_sql_stmt := l_sql_stmt || ' and financial_elem_id=140';
   END IF;

   OPEN l_uow_cursor FOR l_sql_stmt USING p_ledger_id,p_cal_period_id,p_object_id;
   FETCH l_uow_cursor BULK COLLECT INTO l_created_by_obj_tbl,l_created_by_req_tbl;
   CLOSE l_uow_cursor;

   FOR i in 1 .. l_created_by_obj_tbl.COUNT LOOP
      -- Call the FEM_PL_PKG.Register_Chain API procedure to register
      -- the specified chain.
      FEM_PL_PKG.Register_Chain (
         p_api_version                  => c_api_version,
         p_commit                       => FND_API.G_FALSE,
         p_request_id                   => p_request_id,
         p_object_id                    => p_object_id,
         p_source_created_by_request_id => l_created_by_req_tbl(i),
         p_source_created_by_object_id  => l_created_by_obj_tbl(i),
         p_user_id                      => p_user_id,
         p_last_update_login            => p_last_update_login,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         x_return_status                => x_return_status
      );

   END LOOP;


   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
END IF;

END LOOP;

--delete the previous run data
--IF l_migrate_flg THEN
   /*DELETE from fem_balances where created_by_object_id = p_object_id AND
   (DATASET_CODE = l_output_ds) AND (LEDGER_ID = p_ledger_id) AND
   (CAL_PERIOD_ID = p_cal_period_id);*/
--END IF;
FND_MSG_PUB.Count_And_Get
            (p_encoded => 'F',
             p_count => x_msg_count,
             p_data  => x_msg_data);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get
            (p_encoded => 'F',
             p_count => x_msg_count,
             p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MSG_PUB.Count_And_Get
            (p_encoded => 'F',
             p_count => x_msg_count,
             p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
      FND_MSG_PUB.Count_And_Get
            (p_encoded => 'F',
             p_count => x_msg_count,
             p_data  => x_msg_data);

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END LEDGER_PROCESSING;

/***************************************************************************
 Desc  : Procedure to check if any chaining dependency exists on the data
         that rule is going to process.
 Pgmr  : Raghuram K Nanda
 Date  : 16-Aug-2005
 **************************************************************************/
PROCEDURE CHAINING_EXISTS(
   p_request_id      IN    NUMBER,
   p_object_id       IN    NUMBER,
   p_cal_period_id   IN    NUMBER,
   p_ledger_id       IN    NUMBER,
   p_dataset_def_id  IN    NUMBER,
   p_condition_str   IN    VARCHAR2,
   p_effective_date  IN    DATE,
   p_table_name      IN    VARCHAR2,
   x_exec_lock_exists   OUT NOCOPY  VARCHAR2
)
IS

l_chain_count     PLS_INTEGER;

BEGIN

-- Check if the object id exists in pl chains table
select count(*) into l_chain_count from fem_pl_chains
where source_created_by_object_id = p_object_id;

IF (l_chain_count > 0) THEN
   x_exec_lock_exists := 'T';
   RETURN;
ELSE
   x_exec_lock_exists := 'F';
END IF;

EXCEPTION
   WHEN others THEN
      x_exec_lock_exists := 'T';
   return;

END CHAINING_EXISTS;

/***************************************************************************
 Desc  : Procedure to return the valid list of table names present in the
         FTP_RATE_OUTPUT_MAPPING_RULE.
 Pgmr  : Tina Dasgupta
 Date  : 25-Oct-2006
**************************************************************************/
procedure GET_VALID_TABLE_LIST(
    obj_id in number,
    jobid  in number,
    effective_date in date,
    new_valid_table_list out nocopy varchar2,
    LAST_OBJID_COL out nocopy varchar2,
    LAST_REQID_COL out nocopy varchar2,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_msg_count       OUT NOCOPY NUMBER,
    x_msg_data        OUT NOCOPY VARCHAR2
)
is
    process_info OBJ_INFO_TYPE;

    indx NUMBER;
    rate_output_rule_obj_id FTP_TP_PROCESS_RULE.ALT_RATE_OP_OBJECT_ID%TYPE;
    adj_object_id FTP_TP_PROCESS_RULE.adjustment_object_id%TYPE;
    adj_type_code ftp_adjustment_rule.adjustment_type_code%TYPE;
    ecoloss_meth_count NUMBER;
    TYPE varchar_std_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    rate_map_info OBJ_INFO_TYPE;
    adj_rule_info OBJ_INFO_TYPE;
    valid_flg       BOOLEAN;
    l_table_names  varchar_std_type;
    cnt NUMBER;

    -- cursor that retrieves the tables that should be used as source
        CURSOR l_cur_tables IS select table_name from ftp_tp_proc_tabls_params
        where object_definition_id = process_info.obj_id and job_id = jobid;

  begin

    -- initialize our status to 'we are good!'
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FND_MSG_PUB.Delete_Msg();
    adj_type_code := '';

    get_obj_def(obj_id, effective_date, process_info);

    -- From TP Process Rule Info to chk if new Alternate Rate Output Mapping
    -- Rule,Adjustment Rule exists or not.
    select ALT_RATE_OP_OBJECT_ID,adjustment_object_id
    into rate_output_rule_obj_id,adj_object_id
    from ftp_tp_process_rule
    where object_definition_id = process_info.obj_id ;

    IF ( adj_object_id IS NOT NULL ) THEN
        -- For rate_output_rule get detail info
	get_obj_def(adj_object_id, effective_date, adj_rule_info);

        select distinct(adjustment_type_code) into adj_type_code
        from ftp_adjustment_rule
        where object_definition_id = adj_rule_info.obj_id; --11762;
    END IF;

    IF ( rate_output_rule_obj_id IS NULL ) THEN
	valid_table_list := '';
        LAST_OBJID_COL := 'last_updated_by_object_id';
        LAST_REQID_COL := 'last_updated_by_request_id';
        FND_MSG_PUB.Count_And_Get
            (p_encoded => 'F',
             p_count => x_msg_count,
             p_data  => x_msg_data);

        -- Load into global varb standard output colm names
        g_alt_rate_obj := t_alt_rate_obj_list();
        indx := 1;

        -- Read the rule to retieve the names of the tables to process
        OPEN l_cur_tables;
        FETCH l_cur_tables BULK COLLECT INTO l_table_names;
        CLOSE l_cur_tables;

        FOR i IN 1..l_table_names.COUNT
        LOOP
          g_alt_rate_obj.extend();
	  g_alt_rate_obj(i).Account_Table_Name := l_table_names(i);
          g_alt_rate_obj(i).TRANSFER_RATE_COL_NAME := 'transfer_rate';
	  g_alt_rate_obj(i).MATCHED_SPREAD_COL_NAME := 'matched_spread';
	  g_alt_rate_obj(i).REMAINING_TERM_COL_NAME := 'tran_rate_rem_term';
	  g_alt_rate_obj(i).HISTORIC_OPTION_COL_NAME := 'historic_oas';
	  g_alt_rate_obj(i).HISTORIC_STAT_SPREAD_COL_NAME := 'historic_static_spread';
	  g_alt_rate_obj(i).CURRENT_STAT_SPREAD_COL_NAME := 'cur_static_spread';
          g_alt_rate_obj(i).CURRENT_OPTION_COL_NAME := 'cur_oas';

          -- Based on the adjustment_type_code initialize ADJ_RATE_COL_NAME and
          -- ADJ_AMOUNT_COL_NAME
          IF ( adj_type_code = '1' ) THEN
	      g_alt_rate_obj(i).ADJ_RATE_COL_NAME := 'liquidity_premium_rate';
              g_alt_rate_obj(i).ADJ_AMOUNT_COL_NAME := 'liquidity_premium_amt';
          ELSIF ( adj_type_code = '2' ) THEN
              g_alt_rate_obj(i).ADJ_RATE_COL_NAME := 'basis_risk_cost_rate';
              g_alt_rate_obj(i).ADJ_AMOUNT_COL_NAME := 'basis_risk_cost_amt';
           ELSIF ( adj_type_code = '3' ) THEN
              g_alt_rate_obj(i).ADJ_RATE_COL_NAME := 'pricing_incentive_rate';
              g_alt_rate_obj(i).ADJ_AMOUNT_COL_NAME := 'pricing_incentive_amt';
          ELSIF ( adj_type_code = '4' ) THEN
              g_alt_rate_obj(i).ADJ_RATE_COL_NAME := 'other_adjustments_rate';
              g_alt_rate_obj(i).ADJ_AMOUNT_COL_NAME := 'other_adjustments_amt';
          ELSIF ( adj_type_code IS NULL ) THEN
              g_alt_rate_obj(i).ADJ_RATE_COL_NAME := NULL;
              g_alt_rate_obj(i).ADJ_AMOUNT_COL_NAME := NULL;
          END IF;

          -- If table has classification_code as 'FTP_BREAK_FUND' populate
          -- BREAK_FUNDING_RATE,BREAK_FUNDING_AMT,BREAK_FUNDING_MV
          select count(*) into cnt from FEM_TABLE_CLASS_ASSIGNMT
          where table_name = l_table_names(i) --'FEM_BREAK_FUNDING'
          and table_classification_code ='FTP_BREAK_FUND';

          if ( cnt > 0 ) THEN
            g_alt_rate_obj(i).ADJ_RATE_COL_NAME := 'BREAK_FUNDING_RATE';
            g_alt_rate_obj(i).ADJ_AMOUNT_COL_NAME := 'BREAK_FUNDING_AMT';

            --Check for Eco Loss method to register MV Column
            select  count(calc_method_code) into ecoloss_meth_count
            from ftp_adjustment_rule where
            object_definition_id = adj_rule_info.obj_id and
            calc_method_code = c_ecoloss_method;

            if(ecoloss_meth_count > 0) THEN
              g_alt_rate_obj(i).ADJ_MKT_VALUE := 'BREAK_FUNDING_MV';
            else
              g_alt_rate_obj(i).ADJ_MKT_VALUE := NULL;
            end if;

          else
            g_alt_rate_obj(i).ADJ_RATE_COL_NAME := NULL;
            g_alt_rate_obj(i).ADJ_AMOUNT_COL_NAME := NULL;
            g_alt_rate_obj(i).ADJ_MKT_VALUE := NULL;
          End If;
        END LOOP;
      return;
    END IF;

    -- Verify the exception condition for Valid Rule Version
    begin
	-- For rate_output_rule get detail info
	get_obj_def(rate_output_rule_obj_id, effective_date, rate_map_info);
    exception
      when NO_DATA_FOUND then
      FEM_ENGINES_PKG.Put_Message(
                p_app_name => 'FTP',
                p_msg_name => 'RATE_MAP_VERSN_EXCEPTION',
                p_token1   => 'OBJ_ID',
                p_value1   => rate_output_rule_obj_id,
                p_token2   => 'EFFECTIVE_DATE',
                p_value2   => effective_date
               );
     end;

     IF (g_alt_rate_obj IS NULL)  OR (NOT g_alt_rate_obj_exists) THEN
        --dbms_output.put_line('IF (g_alt_rate_obj IS NULL)  OR (NOT g_alt_rate_obj_exists) THEN');
        g_alt_rate_obj := t_alt_rate_obj_list();
	valid_table_list := '';
        indx := 1;

        FOR ids IN (SELECT
		i.table_name,
		max (DECODE (TRANSFER_RATE_COL_NAME, column_name, TRANSFER_RATE_COL_NAME,NULL,NULL, -1)) as trate,
		max (DECODE (MATCHED_SPREAD_COL_NAME, column_name, MATCHED_SPREAD_COL_NAME, NULL,NULL, -1)) as match_spread,
		max (DECODE (REMAINING_TERM_COL_NAME, column_name, REMAINING_TERM_COL_NAME, NULL,NULL, -1)) as rem_term,
		max (DECODE (HIST_OAS_COL_NAME, column_name, HIST_OAS_COL_NAME, NULL,NULL, -1)) as hist_option,
		max (DECODE (ADJUSTMENT_SPRD_COL_NAME, column_name, ADJUSTMENT_SPRD_COL_NAME, NULL,NULL, -1)) as adj_rate,
		max(DECODE(HIST_STAT_SPREAD_COL_NAME, column_name,  HIST_STAT_SPREAD_COL_NAME, NULL,NULL, -1)) as hist_stat_spr,
		max(DECODE(CUR_STAT_SPREAD_COL_NAME, column_name,  CUR_STAT_SPREAD_COL_NAME, NULL,NULL, -1)) as cur_stat_spr,
		max(DECODE(ADJUSTMENT_AMOUNT_COL_NAME, column_name, ADJUSTMENT_AMOUNT_COL_NAME, NULL,NULL, -1)) as adj_amt,
		max(DECODE(CUR_OAS_COL_NAME, column_name, CUR_OAS_COL_NAME, NULL,NULL, -1)) as cur_option
	  FROM fem_tab_columns_v i, FTP_RATE_OUTPUT_MAPPING_RULE  j, ftp_tp_proc_tabls_params k
	  WHERE i.table_name = j. FTP_ACCOUNT_TABLE_NAME
              AND j. FTP_ACCOUNT_TABLE_NAME = k.table_name
              AND job_id = jobid
              AND k.object_definition_id = process_info.obj_id
              AND j.object_definition_id = rate_map_info.obj_id
              GROUP BY i.table_name) LOOP

              g_alt_rate_obj.extend();

              g_alt_rate_obj(indx).obj_def_id := rate_map_info.obj_id;
              g_alt_rate_obj(indx).Account_Table_Name := ids.table_name;

              valid_flg := true;
              VERIFY_VALID_COLUMN(rate_output_rule_obj_id,'TRANSFER_RATE_COL_NAME',ids.trate,ids.table_name,valid_flg);
              VERIFY_VALID_COLUMN(rate_output_rule_obj_id,'MATCHED_SPREAD_COL_NAME',ids.match_spread,ids.table_name,valid_flg);
              VERIFY_VALID_COLUMN(rate_output_rule_obj_id,'REMAINING_TERM_COL_NAME',ids.rem_term,ids.table_name,valid_flg);
              VERIFY_VALID_COLUMN(rate_output_rule_obj_id,'HIST_OAS_COL_NAME',ids.hist_option,ids.table_name,valid_flg);
              VERIFY_VALID_COLUMN(rate_output_rule_obj_id,'ADJUSTMENT_SPRD_COL_NAME',ids.adj_rate,ids.table_name,valid_flg);
              VERIFY_VALID_COLUMN(rate_output_rule_obj_id,'HIST_STAT_SPREAD_COL_NAME',ids.hist_stat_spr,ids.table_name,valid_flg);
              VERIFY_VALID_COLUMN(rate_output_rule_obj_id,'CUR_STAT_SPREAD_COL_NAME',ids.cur_stat_spr,ids.table_name,valid_flg);
              VERIFY_VALID_COLUMN(rate_output_rule_obj_id,'ADJUSTMENT_AMOUNT_COL_NAME',ids.adj_amt,ids.table_name,valid_flg);
              VERIFY_VALID_COLUMN(rate_output_rule_obj_id,'CUR_OAS_COL_NAME',ids.cur_option,ids.table_name,valid_flg);

              g_alt_rate_obj(indx).TRANSFER_RATE_COL_NAME := ids.trate;
              g_alt_rate_obj(indx).MATCHED_SPREAD_COL_NAME := ids.match_spread;
              g_alt_rate_obj(indx).REMAINING_TERM_COL_NAME := ids.rem_term;
              g_alt_rate_obj(indx).HISTORIC_OPTION_COL_NAME := ids.hist_option;
              g_alt_rate_obj(indx).ADJ_RATE_COL_NAME := ids.adj_rate;
              g_alt_rate_obj(indx).HISTORIC_STAT_SPREAD_COL_NAME := ids.hist_stat_spr;
              g_alt_rate_obj(indx).CURRENT_STAT_SPREAD_COL_NAME := ids.cur_stat_spr;
              g_alt_rate_obj(indx).ADJ_AMOUNT_COL_NAME := ids.adj_amt;
              g_alt_rate_obj(indx).CURRENT_OPTION_COL_NAME := ids.cur_option;
              g_alt_rate_obj(indx).ADJ_MKT_VALUE := NULL;

              if (valid_flg) AND (indx=1) THEN
                valid_table_list := '''' || ids.table_name || '''' || ',';
              END IF;

              if (valid_flg) AND (indx <> 1) THEN
                valid_table_list := valid_table_list || '''' || ids.table_name || '''' || ',';
              END IF;

	      indx := indx + 1;

           END LOOP;
         END IF;

         IF (NOT g_alt_rate_obj_exists) AND (indx > 1)
         THEN
            g_alt_rate_obj_exists := TRUE;
         END IF;

         LAST_OBJID_COL := 'last_updated_by_object_id';
         LAST_REQID_COL := 'last_updated_by_request_id';

         select RTRIM(valid_table_list,',') into new_valid_table_list from dual;
         valid_table_list := new_valid_table_list;

         FND_MSG_PUB.Count_And_Get
            (p_encoded => 'F',
             p_count => x_msg_count,
             p_data  => x_msg_data);


END GET_VALID_TABLE_LIST;


/***************************************************************************
 Desc  : Procedure to verify if column is valid or NULL.
 Pgmr  : Tina Dasgupta
 Date  : 01-Sept-2006
 **************************************************************************/
PROCEDURE VERIFY_VALID_COLUMN(
   rate_output_rule_obj_id IN NUMBER,
   p_col_name IN   VARCHAR2,
   p_col_value IN   VARCHAR2,
   p_table_name  IN    VARCHAR2,
   valid_flg IN OUT NOCOPY BOOLEAN
)
IS
  cnt NUMBER;
BEGIN

    select count(*) into cnt from fem_table_class_assignmt
    where table_name = p_table_name
    and table_classification_code = 'FTP_OPTION_COST';

    if ( cnt <> 0 ) OR (( cnt = 0 ) and NOT(p_col_name = 'HIST_OAS_COL_NAME' or p_col_name = 'HIST_STAT_SPREAD_COL_NAME' or
        p_col_name = 'CUR_STAT_SPREAD_COL_NAME' or p_col_name = 'CUR_OAS_COL_NAME'))  THEN
    	if ( p_col_value IS NULL ) THEN
		valid_flg := false;
		FEM_ENGINES_PKG.Put_Message(
		p_app_name => 'FTP',
		p_msg_name => 'FTP_ALL_COLS_NOT_MAPPED',
		p_token1   => 'OBJ_ID',
		p_value1   => rate_output_rule_obj_id,
		p_token2   => 'TABLE_NAME',
		p_value2  => p_table_name
		);
	end if;
    end if;

    if ( cnt <> 0 ) OR (( cnt = 0 ) and NOT(p_col_name = 'HIST_OAS_COL_NAME' or p_col_name = 'HIST_STAT_SPREAD_COL_NAME' or
        p_col_name = 'CUR_STAT_SPREAD_COL_NAME' or p_col_name = 'CUR_OAS_COL_NAME'))  THEN
        if ( p_col_value = '-1') THEN
		valid_flg := false;
		FEM_ENGINES_PKG.Put_Message(
                p_app_name => 'FTP',
                p_msg_name => 'FTP_INVALID_COL',
		p_token1   => 'OBJ_ID',
                p_value1   => rate_output_rule_obj_id,
                p_token2   => 'TABLE_NAME',
                p_value2   => p_table_name,
                p_token3   => 'COLUMN_NAME',
                p_value3   => p_col_name
                );
	end if;
      end if;

END VERIFY_VALID_COLUMN;


begin
  -- initialize dimension_id
  select dimension_id into main_dim_id from fem_dimensions_b
   where dimension_varchar_label = 'LINE_ITEM';
  select attribute_id into ACCT_TYPE_ATTR_ID from fem_dim_attributes_b
   where attribute_varchar_label = 'EXTENDED_ACCOUNT_TYPE'
     and dimension_id = main_dim_id;
  -- ext_accuont_types values
  select dimension_id into ext_account_type_id from fem_dimensions_b
   where dimension_varchar_label = EXT_ACCOUNT_TYPE_NAME;
  -- asset flag attribute id
  select attribute_id into asset_flag_id from fem_dim_attributes_b
   where dimension_id = ext_account_type_id
     and attribute_varchar_label = ASSET_FLAG_NAME;
  -- off_bal attribute
  select attribute_id into off_bal_flag_id from fem_dim_attributes_b
   where dimension_id = ext_account_type_id
     and attribute_varchar_label = OFF_BAL_NAME;
end FTP_TP_PKG;

/
