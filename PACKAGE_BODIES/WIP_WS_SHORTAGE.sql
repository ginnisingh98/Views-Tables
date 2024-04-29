--------------------------------------------------------
--  DDL for Package Body WIP_WS_SHORTAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WS_SHORTAGE" AS
/* $Header: wipwsshb.pls 120.16.12010000.3 2010/04/05 01:35:40 hliew ship $ */







/*
 * UTIL PROCEDURE This procedure converts time provided in hour min and secs into secs
 */
FUNCTION get_time_in_secs(hour NUMBER, minutes NUMBER, sec NUMBER) RETURN NUMBER IS
BEGIN
  return(nvl(hour,0)*24*60 + nvl(minutes,0)*60 + nvl(sec,0));
END get_time_in_secs;


/*
 * UTIL PROCEDURE This procedure converts time provided in date to secs
 */
FUNCTION get_time_in_secs (p_date DATE) return NUMBER IS
BEGIN
  --get the time part till mins only
  return get_time_in_secs(to_number(to_char(p_date,'HH24')),
                           to_number(to_char(p_date, 'MI')), 0);
END get_time_in_secs;


/*
 * This procedure get the component shortage preference values for a given org and stores in package variables
 * Returns Y if preference exist for an org, otherwise N
 */
PROCEDURE get_org_comp_calc_param(
            p_org_id IN NUMBER,
            x_pref_exists OUT NOCOPY VARCHAR2) IS

  l_returnStatus varchar2(1);
  l_params wip_logger.param_tbl_t;
  l_row_seq_num NUMBER;
  l_cutoff_hr NUMBER;
  l_cutoff_min NUMBER;
  l_dtl_row_seq_num NUMBER;
  l_comp_calc_type NUMBER;

  CURSOR cat_set_id_csr IS
    select wpv.attribute_value_code
      from wip_preference_values wpv
     where wpv.preference_id = g_pref_id_comp_short
       and wpv.level_id = g_pref_level_id_site
       and wpv.attribute_name = g_pref_val_comp_type_cset_att;

BEGIN
  x_pref_exists := 'Y';
  if (g_logLevel <= wip_constants.trace_logging) then
    l_params(1).paramName := 'p_org_id';
    l_params(1).paramValue := p_org_id;
    wip_logger.entryPoint(p_procName => 'WIP_WS_SHORTAGE.get_org_comp_calc_param',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
    if(l_returnStatus <> fnd_api.g_ret_sts_success) then
      raise fnd_api.g_exc_unexpected_error;
    end if;
  end if;

  for c_cat_set_id_csr in cat_set_id_csr loop
    g_org_comp_calc_rec.category_set_id := c_cat_set_id_csr.attribute_value_code;
  end loop;

  l_row_seq_num := wip_ws_util.get_multival_pref_seq(
    g_pref_id_comp_short, g_pref_level_id_site, g_pref_val_mast_org_att, to_char(p_org_id));

  if(l_row_seq_num is null) then
    x_pref_exists := 'N';
    return;
  end if;

  g_org_comp_calc_rec.org_id              := p_org_id;
  g_org_comp_calc_rec.shortage_calc_level := wip_ws_util.get_multival_pref_val_code(
    g_pref_id_comp_short, g_pref_level_id_site, l_row_seq_num, g_pref_val_calclevel_att);
  g_org_comp_calc_rec.inc_expected_rcpts  := wip_ws_util.get_multival_pref_val_code(
    g_pref_id_comp_short, g_pref_level_id_site, l_row_seq_num, g_pref_val_inc_rcpts_att);
  g_org_comp_calc_rec.inc_released_jobs   := wip_ws_util.get_multival_pref_val_code(
    g_pref_id_comp_short, g_pref_level_id_site, l_row_seq_num, g_pref_val_inc_release_att);
  g_org_comp_calc_rec.inc_unreleased_jobs := wip_ws_util.get_multival_pref_val_code(
    g_pref_id_comp_short, g_pref_level_id_site, l_row_seq_num, g_pref_val_inc_unreleased_att);
  g_org_comp_calc_rec.inc_onhold_jobs     := wip_ws_util.get_multival_pref_val_code(
    g_pref_id_comp_short, g_pref_level_id_site, l_row_seq_num, g_pref_val_inc_onhold_att);

  if(g_org_comp_calc_rec.inc_expected_rcpts = g_pref_val_calclevel_org) then
    g_org_comp_calc_rec.supply_cutoff_hr := wip_ws_util.get_multival_pref_val_code(
      g_pref_id_comp_short, g_pref_level_id_site, l_row_seq_num, g_pref_val_cutoff_hr_att );
    g_org_comp_calc_rec.supply_cutoff_min := wip_ws_util.get_multival_pref_val_code(
      g_pref_id_comp_short, g_pref_level_id_site, l_row_seq_num, g_pref_val_cutoff_min_att );
    g_org_comp_calc_rec.supply_cutoff_time_in_sec := get_time_in_secs(g_org_comp_calc_rec.supply_cutoff_hr, g_org_comp_calc_rec.supply_cutoff_min, 0);
  end if;

/* Finding the critical components has moved to separate procedures
  --now find out the components to be included in calculations
  --User can setup three types of preferences
  --preference attribute "type", possible values are: 1(All), 2(Item), 3(category)
  --first find the org seq number

  l_dtl_row_seq_num := wip_ws_util.get_multival_pref_seq(
    g_pref_id_comp_short, g_pref_level_id_site, g_pref_val_dtl_org_att, to_char(p_org_id));


  l_comp_calc_type := wip_ws_util.get_multival_pref_val_code(
    g_pref_id_comp_short, g_pref_level_id_site, l_dtl_row_seq_num, g_pref_val_inc_onhold_att);
*/

/*
  --test code, remove after actual implementation
  g_org_comp_calc_rec.org_id              := 207;
  g_org_comp_calc_rec.shortage_calc_level := 1;
  g_org_comp_calc_rec.inc_expected_rcpts  := 2;
  g_org_comp_calc_rec.supply_cutoff_hr    := null;
  g_org_comp_calc_rec.supply_cutoff_min   := null;
  g_org_comp_calc_rec.inc_released_jobs   := 1;
  g_org_comp_calc_rec.inc_unreleased_jobs := 1;
  g_org_comp_calc_rec.inc_onhold_jobs     := 2;
*/
  if (g_logLevel <= wip_constants.trace_logging) then
    wip_logger.exitPoint(p_procName => 'WIP_WS_SHORTAGE.get_org_comp_calc_param',
                         p_procReturnStatus => l_returnStatus,
                         p_msg => 'Request processed successfully!',
                         x_returnStatus => l_returnStatus);
  end if;

  EXCEPTION
    WHEN OTHERS THEN
      if (g_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'WIP_WS_SHORTAGE.get_org_comp_calc_param',
                             p_procReturnStatus => l_returnStatus,
                             p_msg => 'unexpected error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus);
      end if;

END get_org_comp_calc_param;


/*
 * This procedure gets the end time for last shift
 */
FUNCTION get_period_end_time(p_org_id NUMBER) RETURN DATE IS
  l_first_work_day DATE;
  l_last_shift_end_time DATE;
  CURSOR shift_time_csr IS
  select bsd.seq_num || '.' || bsd.shift_num shift_id,
         wip_ws_util.get_appended_date( bsd.shift_date, t.from_time) from_date,
         wip_ws_util.get_appended_date( bsd.shift_date, t.to_time) to_date,
         t.shift_num,
         bsd.seq_num,
         wip_ws_util.get_shift_info_for_display(mp.organization_id, bsd.seq_num, t.shift_num) as display
    from mtl_parameters mp, bom_shift_dates bsd,
         (select bst.calendar_code,
                 bst.shift_num,
                 min(bst.from_time) from_time,
                 max(decode(sign(bst.to_time - bst.from_time), -1, 24*60*60, 0) + bst.to_time) to_time
            from bom_shift_times bst
            group by bst.calendar_code, bst.shift_num ) t
   where mp.organization_id = p_org_id
     and mp.calendar_code = bsd.calendar_code
     and bsd.calendar_code = t.calendar_code
     and bsd.shift_num = t.shift_num
     and bsd.exception_set_id = -1
     and bsd.shift_date + t.to_time / (24*60*60) > sysdate
     and bsd.shift_date between l_first_work_day and wip_ws_util.get_next_work_date_by_org_id(p_org_id,
       wip_ws_util.get_next_work_date_by_org_id(p_org_id,l_first_work_day)) --fix bug 9484419
     and bsd.seq_num is not null
     order by to_date; --fix bug 9484419

BEGIN
  --:1 - Org_id
  --:2 - null (code will assume sysdate)
  l_first_work_day := wip_ws_util.get_first_workday(p_org_id, null, null);

  for c_shift_time_csr in shift_time_csr loop
    l_last_shift_end_time := c_shift_time_csr.to_date;
  end loop;

  return l_last_shift_end_time;

END get_period_end_time;


/*
 * This procedure returns the string for applicable job statuses
 */
FUNCTION get_pref_job_statuses RETURN VARCHAR2 IS
  status_str VARCHAR2(240) := null;
BEGIN
  if(g_org_comp_calc_rec.inc_released_jobs = 1) then
    status_str := to_char(wip_constants.RELEASED);
  end if;

  if(g_org_comp_calc_rec.inc_unreleased_jobs = 1) then
    if(status_str is not null) then
      status_str := status_str|| ' , ';
    end if;
    status_str := status_str || to_char(wip_constants.UNRELEASED);
  end if;

  if(g_org_comp_calc_rec.inc_onhold_jobs = 1) then
    if(status_str is not null) then
      status_str := status_str|| ' , ';
    end if;
    status_str := status_str || to_char(wip_constants.HOLD);
  end if;
  return status_str;
END get_pref_job_statuses ;


/*
 * This procedure returns the string for applicable job types - right now it includes only standard jobs
 */
FUNCTION get_job_types RETURN VARCHAR2 IS
  job_type_str VARCHAR2(240) := null;
BEGIN
  job_type_str := to_char(wip_constants.STANDARD);
  return job_type_str;
END get_job_types;


/*
 * This procedure returns the string for all the component category selected in preferences for this org
 */
FUNCTION get_pref_comp_cat(p_org_id NUMBER) return VARCHAR2 IS
  cat_string VARCHAR2(1048);
  CURSOR pref_cat_csr IS
  select wpv.attribute_value_code
    from wip_preference_values wpv
   where wpv.preference_id = g_pref_id_comp_short
     and wpv.level_id = g_pref_level_id_site
     and wpv.attribute_name = g_pref_val_comp_type_cat_att
     and wpv.sequence_number in  (
       select wpv1.sequence_number
         from wip_preference_values wpv1
        where wpv1.preference_id = g_pref_id_comp_short
          and wpv1.level_id = g_pref_level_id_site
          and wpv1.attribute_name = g_pref_val_comp_type_att
          and wpv1.attribute_value_code = to_char(g_pref_val_comp_type_cat)
          and wpv1.sequence_number in (
            select wpv2.sequence_number
              from wip_preference_values wpv2
             where wpv2.preference_id = g_pref_id_comp_short
               and wpv2.level_id = g_pref_level_id_site
               and wpv2.attribute_name = g_pref_val_dtl_org_att
               and wpv2.attribute_value_code = to_char(p_org_id)));
BEGIN
  for c_pref_cat_csr in pref_cat_csr loop
    if cat_string is not null then
      cat_string := cat_string || ',';
    end if;
    cat_string := cat_string || c_pref_cat_csr.attribute_value_code;
  end loop;
  return cat_string;
END get_pref_comp_cat;


/*
 * This procedure returns the string for all the components selected in preference for this org
 */
FUNCTION get_pref_comp_id(p_org_id NUMBER) return VARCHAR2 IS
  comp_string VARCHAR2(1048);
  CURSOR pref_itm_csr IS
  select wpv.attribute_value_code
    from wip_preference_values wpv
   where wpv.preference_id = g_pref_id_comp_short
     and wpv.level_id = g_pref_level_id_site
     and wpv.attribute_name = g_pref_val_comp_type_item_att
     and wpv.sequence_number in  (
       select wpv1.sequence_number
         from wip_preference_values wpv1
        where wpv1.preference_id = g_pref_id_comp_short
          and wpv1.level_id = g_pref_level_id_site
          and wpv1.attribute_name = g_pref_val_comp_type_att
          and wpv1.attribute_value_code = to_char(g_pref_val_comp_type_item)
          and wpv1.sequence_number in (
            select wpv2.sequence_number
              from wip_preference_values wpv2
             where wpv2.preference_id = g_pref_id_comp_short
               and wpv2.level_id = g_pref_level_id_site
               and wpv2.attribute_name = g_pref_val_dtl_org_att
               and wpv2.attribute_value_code = to_char(p_org_id)));

BEGIN
  wip_ws_util.trace_log('WIPWSSHB:get_pref_comp_id:Execution cursor to get item ids');
  for c_pref_itm_csr in pref_itm_csr loop
    if comp_string is not null then
      comp_string := comp_string || ',';
    end if;
    comp_string := comp_string || 'to_number(c_pref_itm_csr.attribute_value_code)';
  end loop;


/*
  --TODO: test code, remove after testing
  if(comp_string is null) then
    comp_string := '249';
  end if;
*/
  wip_ws_util.trace_log('WIPWSSHB:get_pref_comp_id: item id string='||comp_string);
  return comp_string;

END get_pref_comp_id;


/*
 * This procedure finds out the onhand quantity (available to transact) of an item in org or subinv based on parameter
 */
FUNCTION get_subinv_component_onhand(
         p_org_id       NUMBER,
         p_subinv_code  VARCHAR2 ,
         p_component_id NUMBER)RETURN NUMBER IS

  l_is_revision_control boolean;
  l_is_lot_control boolean;
  l_is_serial_control boolean;
  l_lot_control_code number;
  l_revision_control_code number;
  l_serial_control_code number;

  x_qoh number;
  x_rqoh number;
  x_qr number;
  x_qs number;
  x_att number;
  x_atr number;

  x_return_status varchar2(2);
  x_msg_count number;
  x_msg_data varchar2(256);

  CURSOR item_ctrl_csr IS
    select msi.revision_qty_control_code,
           msi.lot_control_code,
           msi.serial_number_control_code
      from mtl_system_items_b msi
     where msi.organization_id = p_org_id
       and msi.inventory_item_id = p_component_id;

BEGIN
  wip_ws_util.trace_log('WIPWSSHB.get_subinv_component_onhand: Begin '||
    '; p_org_id '||p_org_id||
    '; p_subinv_code '||p_subinv_code||
    '; p_component_id '||p_component_id);

  for c_item_ctrl_csr in item_ctrl_csr loop
    l_revision_control_code := c_item_ctrl_csr.revision_qty_control_code;
    l_lot_control_code      := c_item_ctrl_csr.lot_control_code;
    l_serial_control_code   := c_item_ctrl_csr.serial_number_control_code;
  end loop;

  --bug 7045337 since lot number is passed as null, l_is_lot_control should be passed as false
  --based on Inv team's suggestion passing null for l_is_revision_control and l_is_serial_control
  --also since we are not calculating att at revision/serial
  /**************
  if ( l_lot_control_code =  WIP_CONSTANTS.LOT ) then
    l_is_lot_control := true;
  else
    l_is_lot_control := false;
  end if;

  if( l_revision_control_code =  WIP_CONSTANTS.REV ) then
    l_is_revision_control := true;
  else
   l_is_revision_control := false;
  end if;

  if( l_serial_control_code in (WIP_CONSTANTS.FULL_SN, WIP_CONSTANTS.DYN_RCV_SN) ) then
    l_is_serial_control := true;
  else
    l_is_serial_control := false;
  end if;
  **************/

  l_is_lot_control := false;
  l_is_revision_control := false;
  l_is_serial_control := false;

  fnd_msg_pub.Delete_Msg;
  inv_quantity_tree_pub.query_quantities(
        p_api_version_number  => 1.0,
        p_init_msg_lst        => 'T',
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_organization_id     => p_org_id,
        p_inventory_item_id   => p_component_id,
        p_tree_mode           => 2,
        p_is_revision_control => l_is_revision_control,
        p_is_lot_control      => l_is_lot_control,
        p_is_serial_control   => l_is_serial_control,
        p_lot_expiration_date => sysdate,
        p_revision            => null,
        p_lot_number          => null,
        p_subinventory_code   => p_subinv_code,
        p_locator_id          => null,
        p_onhand_source       => 3,
        x_qoh                 => x_qoh,
        x_rqoh                => x_rqoh,
        x_qr                  => x_qr,
        x_qs                  => x_qs,
        x_att                 => x_att,
        x_atr                 => x_atr
      );

   --call to clear the in memory cache
  inv_quantity_tree_pub.clear_quantity_cache;

  wip_ws_util.trace_log('WIPWSSHB.get_subinv_component_onhand: '||
      '; x_msg_count '||x_msg_count||
      '; x_msg_data '||x_msg_data||
      '; x_qoh '||x_qoh||
      '; x_rqoh '||x_rqoh||
      '; x_qr '||x_qr||
      '; x_qs '||x_qs||
      '; x_att '||x_att||
      '; x_atr '||x_atr);

  return x_att;

END get_subinv_component_onhand;


/*
 *This procedure finds out the onhand qty (available to transact) of a component in org
 */
FUNCTION get_org_component_onhand(
         p_org_id NUMBER,
         p_component_id NUMBER) RETURN NUMBER IS
BEGIN
  return (get_subinv_component_onhand(p_org_id, to_char(null), p_component_id));
END get_org_component_onhand;


/*
 * This procedure inserts a component record in shortages temp table
 */
PROCEDURE insert_critical_component(p_org_id NUMBER,
                                    p_inv_item_id NUMBER,
                                    p_subinv_code VARCHAR2 ,
                                    p_locator_id NUMBER,
                                    p_avail_qty NUMBER) IS
BEGIN
  insert into wip_ws_critical_comp_temp
  (organization_id,
   inventory_item_id,
   supply_subinventory,
   supply_locator_id,
   onhand_qty,
   projected_avail_qty
  )values
  (p_org_id,
   p_inv_item_id,
   p_subinv_code,
   p_locator_id,
   p_avail_qty,
   p_avail_qty
  );
END insert_critical_component;

FUNCTION is_all_component_selected(p_org_id NUMBER) RETURN BOOLEAN IS
  CURSOR all_item_pref_csr IS
    select wpv.attribute_value_code
      from wip_preference_values wpv
     where wpv.preference_id = g_pref_id_comp_short
       and wpv.level_id = g_pref_level_id_site
       and wpv.attribute_name = g_pref_val_comp_type_att
       and wpv.sequence_number in  (
         select wpv1.sequence_number
           from wip_preference_values wpv1
          where wpv1.preference_id = g_pref_id_comp_short
            and wpv1.level_id = g_pref_level_id_site
            and wpv1.attribute_name = g_pref_val_dtl_org_att
            and wpv1.attribute_value_code = to_char(p_org_id));
  l_found BOOLEAN := FALSE;
BEGIN
  for c_all_item_pref_csr in all_item_pref_csr loop
    if(c_all_item_pref_csr.attribute_value_code = g_pref_val_comp_type_all) then
      l_found := TRUE;
      exit;
    end if;
  end loop;
  return l_found;

END is_all_component_selected;

/*
 * This procedure finds out the critical components based on preferences and usage in jobs.
 * Call the procedure to insert the critical component into temp table
 * It inserts a record for org component, and if subinv calc is selected in preference, then
 * another record is inserted for subinv
 */
PROCEDURE get_pref_critical_components (p_org_id NUMBER, p_end_time DATE) IS
  l_job_status_clause VARCHAR2(240);
  l_job_statuses VARCHAR2(240);
  l_job_type_clause VARCHAR2(240);
  l_sql VARCHAR2(4000);
  l_cursor integer;
  l_dummy integer;
  l_inv_item_id NUMBER;
  l_subinv_code VARCHAR2(10);
  l_old_inv_item_id NUMBER := -1;
  l_comp_avail NUMBER;
  l_item_ids VARCHAR2(1048);
  l_cat_ids VARCHAR2(1048);
  l_item_clause VARCHAR2(4000);
  l_cat_clause VARCHAR2(1048);
  l_temp_where VARCHAR2(4000);
  l_all_clause VARCHAR2(240);

BEGIN
  wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_pref_critical_components: Entered' );
  l_job_status_clause := ' and wdj.status_type in ('|| get_pref_job_statuses() || ')';
  wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_pref_critical_components: l_job_status_clause='||l_job_status_clause );
  l_job_type_clause := ' and wdj.job_type in ('||get_job_types() || ')';
  wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_pref_critical_components: l_job_type_clause='||l_job_type_clause );

  l_sql := l_sql || 'select distinct wro.inventory_item_id, ';
  l_sql := l_sql || '       decode(wro.supply_subinventory, null, ';
  l_sql := l_sql || '         (decode(msi.wip_supply_subinventory, null, wp.default_pull_supply_subinv, msi.wip_supply_subinventory)),';
  l_sql := l_sql || '         wro.supply_subinventory) supply_subinventory ';
  l_sql := l_sql || '  from wip_discrete_jobs wdj,  ';
  l_sql := l_sql || '       wip_requirement_operations wro, ';
  l_sql := l_sql || '       mtl_system_items msi, ';
  l_sql := l_sql || '       wip_parameters wp ';
  l_sql := l_sql || '  where wdj.organization_id = :org_id ';
  l_sql := l_sql || '  and wdj.start_quantity - wdj.quantity_completed - wdj.quantity_scrapped > 0  ';
  l_sql := l_sql || '  and wdj.scheduled_start_date < :shift_end_time  ';
  l_sql := l_sql || '  and wro.organization_id = wdj.organization_id ';
  l_sql := l_sql || '  and wro.wip_entity_id = wdj.wip_entity_id ';
  l_sql := l_sql || '  and wp.organization_id = wdj.organization_id ';
  l_sql := l_sql || '  and msi.organization_id = wdj.organization_id ';
  l_sql := l_sql || '  and msi.inventory_item_id = wro.inventory_item_id ';
  l_sql := l_sql || l_job_status_clause;
  l_sql := l_sql || l_job_type_clause;

  l_cat_ids := get_pref_comp_cat(p_org_id);
  l_item_ids := get_pref_comp_id(p_org_id);

  if(is_all_component_selected(p_org_id)) then
    l_all_clause := ' 1=1 ';
  end if;

  if(l_cat_ids is not null) then
    l_cat_clause := '   exists (select inventory_item_id ' ||
                    '               from mtl_item_categories ' ||
                    '              where inventory_item_id = wro.inventory_item_id '||
                    '                and organization_id = wdj.organization_id '||
                    '                and category_set_id = :cat_set_id '||
                    '                and category_id in (:cat_ids))';
    --l_sql := l_sql || l_cat_clause;
  end if;

  if(l_item_ids is not null) then
    --l_item_clause := '   msi.inventory_item_id in (:inv_item_ids)';
    --l_sql := l_sql || l_item_clause;
     l_item_clause := 'msi.inventory_item_id in ( '||
  '  select wpv.attribute_value_code ' ||
  '    from wip_preference_values wpv ' ||
  '   where wpv.preference_id = :pref_id_comp_short1 ' ||
  '     and wpv.level_id = :pref_level_id_site1 ' ||
  '     and wpv.attribute_name = :pref_val_comp_type_item_att1 ' ||
  '     and wpv.sequence_number in  ( ' ||
  '       select wpv1.sequence_number ' ||
  '         from wip_preference_values wpv1 ' ||
  '        where wpv1.preference_id = :pref_id_comp_short2 ' ||
  '          and wpv1.level_id = :pref_level_id_site2 ' ||
  '          and wpv1.attribute_name = :pref_val_comp_type_att2 ' ||
  '          and wpv1.attribute_value_code = to_char(:pref_val_comp_type_item2) ' ||
  '          and wpv1.sequence_number in ( ' ||
  '            select wpv2.sequence_number ' ||
  '              from wip_preference_values wpv2 ' ||
  '             where wpv2.preference_id = :pref_id_comp_short3 ' ||
  '               and wpv2.level_id = :pref_level_id_site3 ' ||
  '               and wpv2.attribute_name = :pref_val_dtl_org_att3 ' ||
  '               and wpv2.attribute_value_code = to_char(wro.organization_id))) )';

  end if;

  if(l_all_clause is not null OR l_cat_clause is not null OR l_item_clause is not null) then
    l_temp_where := l_temp_where || '  and ( ';

    if(l_all_clause is not null) then
      l_temp_where := l_temp_where || '1 = 1';
    end if;

    if(l_cat_clause is not null) then
      if(l_all_clause is not null) then
        l_temp_where := l_temp_where || '    OR ';
      end if;
      l_temp_where := l_temp_where || l_cat_clause;
    end if;

    if(l_item_clause is not null) then
      if(l_all_clause is not null OR l_cat_clause is not null) then
        l_temp_where := l_temp_where || '    OR ';
      end if;
      l_temp_where := l_temp_where || l_item_clause;
    end if;

    l_temp_where := l_temp_where || ')';
  else
    l_temp_where := l_temp_where || 'and 1 = 2';
  end if;

  l_sql := l_sql || l_temp_where;

  l_sql := l_sql || '  order by inventory_item_id ';

  wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_pref_critical_components: l_sql='||l_sql );

  l_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);
  dbms_sql.define_column(l_cursor, 1, l_inv_item_id);
  dbms_sql.define_column(l_cursor, 2, l_subinv_code,10);
  dbms_sql.bind_variable(l_cursor, ':org_id', p_org_id);
  dbms_sql.bind_variable(l_cursor, ':shift_end_time', p_end_time);
  if(l_cat_ids is not null) then
    dbms_sql.bind_variable(l_cursor, ':cat_set_id', g_org_comp_calc_rec.category_set_id);
    dbms_sql.bind_variable(l_cursor, ':cat_ids', l_cat_ids);
  end if;

  if(l_item_ids is not null) then
    --dbms_sql.bind_variable(l_cursor, ':inv_item_ids', l_item_ids);
        dbms_sql.bind_variable(l_cursor, ':pref_id_comp_short1', g_pref_id_comp_short );
        dbms_sql.bind_variable(l_cursor, ':pref_level_id_site1', g_pref_level_id_site);
        dbms_sql.bind_variable(l_cursor, ':pref_val_comp_type_item_att1', g_pref_val_comp_type_item_att);
        dbms_sql.bind_variable(l_cursor, ':pref_id_comp_short2', g_pref_id_comp_short);
        dbms_sql.bind_variable(l_cursor, ':pref_level_id_site2', g_pref_level_id_site);
        dbms_sql.bind_variable(l_cursor, ':pref_val_comp_type_att2', g_pref_val_comp_type_att);
        dbms_sql.bind_variable(l_cursor, ':pref_val_comp_type_item2', g_pref_val_comp_type_item);
        dbms_sql.bind_variable(l_cursor, ':pref_id_comp_short3', g_pref_id_comp_short);
        dbms_sql.bind_variable(l_cursor, ':pref_level_id_site3', g_pref_level_id_site);
        dbms_sql.bind_variable(l_cursor, ':pref_val_dtl_org_att3', g_pref_val_dtl_org_att);

  end if;

  l_dummy := dbms_sql.execute(l_cursor);

  LOOP
    EXIT WHEN DBMS_SQL.FETCH_ROWS (l_cursor) = 0;
    dbms_sql.column_value(l_cursor, 1, l_inv_item_id);
    dbms_sql.column_value(l_cursor, 2, l_subinv_code);
    wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_pref_critical_components: component='||l_inv_item_id||', subinv_code='||l_subinv_code );
    if(l_inv_item_id <> l_old_inv_item_id) then
      wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_pref_critical_components: calling orgonhand for component='||l_inv_item_id );
      l_comp_avail :=  get_org_component_onhand(p_org_id, l_inv_item_id);
      wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_pref_critical_components: back from orgcomponent onhand, component ='||l_inv_item_id||', onhand='||l_comp_avail );
      insert_critical_component(p_org_id, l_inv_item_id, null, null, l_comp_avail);
      wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_pref_critical_components: back from insert_critical_component, org='||p_org_id||', item ='||l_inv_item_id||', onhand='||l_comp_avail );
    end if;

    if(g_org_comp_calc_rec.shortage_calc_level = 2) then
      wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_pref_critical_components: shortage calc=subinv, calling subinv onhand, org='||p_org_id||', item ='||l_inv_item_id||', subinv='||l_subinv_code);
      l_comp_avail := get_subinv_component_onhand(p_org_id, l_subinv_code, l_inv_item_id);
      wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_pref_critical_components: shortage calc=subinv, back from subinv onhand, org='||p_org_id||', item ='||l_inv_item_id||', subinv='||l_subinv_code||', subinv onhand='||l_comp_avail);
      insert_critical_component(p_org_id, l_inv_item_id, l_subinv_code, null, l_comp_avail);
      wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_pref_critical_components: shortage calc=subinv, back from insert_critical_component, org='||p_org_id||', item ='||l_inv_item_id);
    end if;
    l_old_inv_item_id := l_inv_item_id;
  END LOOP;
  dbms_sql.close_cursor(l_cursor);


  EXCEPTION
    WHEN OTHERS THEN
      dbms_sql.close_cursor(l_cursor);

END get_pref_critical_components;


/**
 * This procedure finds out the job ops to be considered based on timeline job statuses selected in preferences
 * It stores the job ops in global pl/sql table for later use
 */
PROCEDURE get_job_ops(p_org_id NUMBER, p_end_time DATE) IS
  l_job_status_clause VARCHAR2(240);
  l_job_type_clause VARCHAR2(240);
  l_job_statuses VARCHAR2(240);
  l_sql VARCHAR2(2048);
  l_cursor integer;
  l_dummy integer;
  l_org_id NUMBER;
  l_wip_ent_id NUMBER;
  l_dept_id NUMBER;
  l_op_seq_num NUMBER;
  l_op_fusd DATE;
  l_op_sch_qty NUMBER;
  l_op_start_qty NUMBER;
  l_op_open_qty NUMBER;
  l_return_status VARCHAR2(1);
  l_return_code NUMBER;
  i NUMBER;
BEGIN
  wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_ops:Entered');
  l_job_status_clause := 'and wdj.status_type in ('|| get_pref_job_statuses() || ')';
  l_job_type_clause := 'and wdj.job_type in ('||get_job_types() || ')';

  l_sql := l_sql || 'SELECT wo.organization_id, ';
  l_sql := l_sql || 'wo.wip_entity_id, ';
  l_sql := l_sql || 'wo.department_id, ';
  l_sql := l_sql || 'wo.operation_seq_num, ';
  l_sql := l_sql || 'wo.first_unit_start_date, ';
  l_sql := l_sql || 'wo.scheduled_quantity, ';
  l_sql := l_sql || 'wo.scheduled_quantity-wo.cumulative_scrap_quantity as start_qty, ';
  l_sql := l_sql || 'wo.scheduled_quantity-wo.cumulative_scrap_quantity as open_qty ';
  l_sql := l_sql || 'FROM wip_discrete_jobs wdj, ';
  l_sql := l_sql || 'wip_operations wo ';
  l_sql := l_sql || 'WHERE wdj.organization_id = :org_id ';
  l_sql := l_sql || 'AND wdj.scheduled_start_date < :shift_end_time ';
  l_sql := l_sql || 'AND wo.organization_id = wdj.organization_id ';
  l_sql := l_sql || 'AND wo.wip_entity_id = wdj.wip_entity_id ';
  l_sql := l_sql || 'AND wo.first_unit_start_date < :shift_end_time2 ';
  l_sql := l_sql || 'AND wo.scheduled_quantity -wo.quantity_completed -wo.cumulative_scrap_quantity > 0 ';
  l_sql := l_sql || l_job_status_clause;
  l_sql := l_sql || l_job_type_clause;
  l_sql := l_sql || 'ORDER BY wo.first_unit_start_date, ';
  l_sql := l_sql || '  wdj.scheduled_start_date, ';
  l_sql := l_sql || '  wo.operation_seq_num ';

  wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_ops:l_sql='||l_sql);

  l_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);
  dbms_sql.define_column(l_cursor, 1, l_org_id);
  dbms_sql.define_column(l_cursor, 2, l_wip_ent_id);
  dbms_sql.define_column(l_cursor, 3, l_dept_id);
  dbms_sql.define_column(l_cursor, 4, l_op_seq_num);
  dbms_sql.define_column(l_cursor, 5, l_op_fusd );
  dbms_sql.define_column(l_cursor, 6, l_op_sch_qty );
  dbms_sql.define_column(l_cursor, 7, l_op_start_qty );
  dbms_sql.define_column(l_cursor, 8, l_op_open_qty );

  dbms_sql.bind_variable(l_cursor, ':org_id', p_org_id);
  dbms_sql.bind_variable(l_cursor, ':shift_end_time', p_end_time);
  dbms_sql.bind_variable(l_cursor, ':shift_end_time2', p_end_time);

  l_dummy := dbms_sql.execute(l_cursor);
  i := 0;
  LOOP
    EXIT WHEN DBMS_SQL.FETCH_ROWS (l_cursor) = 0;
    dbms_sql.column_value(l_cursor, 1, l_org_id);
    dbms_sql.column_value(l_cursor, 2, l_wip_ent_id);
    dbms_sql.column_value(l_cursor, 3, l_dept_id);
    dbms_sql.column_value(l_cursor, 4, l_op_seq_num);
    dbms_sql.column_value(l_cursor, 5, l_op_fusd);
    dbms_sql.column_value(l_cursor, 6, l_op_sch_qty);
    dbms_sql.column_value(l_cursor, 7, l_op_start_qty);
    dbms_sql.column_value(l_cursor, 8, l_op_open_qty);

    wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_ops:Adding job op, l_org_id='||l_org_id||',l_wip_ent_id='||l_wip_ent_id||
      ',l_op_seq_num='||l_op_seq_num||',l_dept_id='||l_dept_id||',l_op_fusd='||l_op_fusd||',l_op_start_qty='||l_op_start_qty||
      ',l_op_open_qty='||l_op_open_qty||',l_op_sch_qty='||l_op_sch_qty);

    g_wip_job_op_tbl(i).ORGANIZATION_ID       := l_org_id;
    g_wip_job_op_tbl(i).WIP_ENTITY_ID         := l_wip_ent_id;
    g_wip_job_op_tbl(i).OPERATION_SEQ_NUM     := l_op_seq_num;
    g_wip_job_op_tbl(i).DEPARTMENT_ID         := l_dept_id;
    g_wip_job_op_tbl(i).FIRST_UNIT_START_DATE := l_op_fusd;
    g_wip_job_op_tbl(i).START_QTY             := l_op_start_qty;
    g_wip_job_op_tbl(i).OPEN_QTY              := l_op_open_qty;
    g_wip_job_op_tbl(i).SCHEDULED_QTY         := l_op_sch_qty;
    i := i+1;
  END LOOP;
  dbms_sql.close_cursor(l_cursor);

  --call custom hook procedure to reorder operations if necessary
  begin
    wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_ops:Calling custom procedure for reordering operations');
    wip_ws_custom.reorder_ops_for_shortage(g_wip_job_op_tbl, l_return_status, l_return_code);
    wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_ops:back from custom procedure for reordering operations with status='||l_return_status);

    if(l_return_status <> 'S') then
      raise fnd_api.g_exc_unexpected_error;
    end if;
  exception
    when others then
    raise;
  end;

  EXCEPTION
  WHEN OTHERS THEN
    dbms_sql.close_cursor(l_cursor);


END get_job_ops;




/**
 * This procedure finds out the critical components used in job ops and stores them in global pl/sql table
 * These components are ordered by requirement date (operation start date)
 *
 */
PROCEDURE get_job_critical_components(p_org_id NUMBER, p_end_time DATE) IS
  l_job_status_clause VARCHAR2(240);
  l_job_statuses VARCHAR2(240);
  l_sql VARCHAR2(4000);
  l_cursor integer;
  l_dummy integer;
  l_org_id NUMBER;
  l_wip_ent_id NUMBER;
  l_dept_id NUMBER;
  l_op_seq_num NUMBER;
  l_op_fusd DATE;
  l_op_sch_qty NUMBER;
  l_op_start_qty NUMBER;
  l_op_open_qty NUMBER;
  l_cat_ids VARCHAR2(1024);
  l_item_ids VARCHAR2(2048);
  l_subinv_code VARCHAR2(10);
  l_uom_code VARCHAR2(3);
  l_inv_item_id NUMBER;
  l_req_qty NUMBER;
  l_qty_issued NUMBER;
  l_qpa NUMBER;
  l_qty_allocated NUMBER;
  l_wip_supply_type NUMBER;
  l_basis_type NUMBER;
  l_item_clause VARCHAR2(4000);
  l_cat_clause VARCHAR2(1048);
  l_all_clause VARCHAR2(240);
  l_temp_where VARCHAR2(4000);
  i NUMBER;
  j NUMBER;
  l_qty_open NUMBER;
  l_yield NUMBER;
BEGIN

  wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_critical_components:Entered');

  l_sql := l_sql || 'select wro.inventory_item_id, ';
  l_sql := l_sql || '       decode(wro.supply_subinventory, null, ';
  l_sql := l_sql || '       (decode(msi.wip_supply_subinventory, null, wp.default_pull_supply_subinv, msi.wip_supply_subinventory)),';
  l_sql := l_sql || '       wro.supply_subinventory) supply_subinventory, ';
  l_sql := l_sql || '       nvl(wro.required_quantity,0), ';
  l_sql := l_sql || '       nvl(wro.quantity_issued,0), ';
  l_sql := l_sql || '       nvl(wro.quantity_per_assembly,0), ';
  l_sql := l_sql || '       nvl(wro.quantity_allocated,0), ';
  l_sql := l_sql || '       wro.basis_type, ';
  l_sql := l_sql || '       wro.wip_supply_type, ';
  l_sql := l_sql || '       msi.primary_uom_code, ';
  l_sql := l_sql || '       decode(wp.include_component_yield, 1, nvl(wro.component_yield_factor, 1), 1) ';
  l_sql := l_sql || '  from wip_requirement_operations wro, ';
  l_sql := l_sql || '       mtl_system_items msi, ';
  l_sql := l_sql || '       wip_parameters wp ';
  l_sql := l_sql || ' where wro.organization_id = :l_org_id ';
  l_sql := l_sql || '   and wro.wip_entity_id = :l_wip_ent_id ';
  l_sql := l_sql || '   and wro.operation_seq_num = :l_operation_seq_num ';
  --bug 6983119 - Added the condition wro.quantity_per_assembly > 0
  l_sql := l_sql || '   and wro.quantity_per_assembly > 0 ';
  l_sql := l_sql || '   and wp.organization_id = wro.organization_id ';
  l_sql := l_sql || '   and msi.organization_id = wro.organization_id ';
  l_sql := l_sql || '   and msi.inventory_item_id = wro.inventory_item_id ';

/*
  l_cat_ids := get_pref_comp_cat(p_org_id);
  wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_critical_components:l_cat_ids='||l_cat_ids);
  l_item_ids := get_pref_comp_id(p_org_id);
  wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_critical_components:l_item_ids='||l_item_ids);

  if(l_cat_ids is not null) then
    l_cat_clause := '  and exists (select inventory_item_id ' ||
                    '               from mtl_item_categories ' ||
                    '              where inventory_item_id = wro.inventory_item_id '||
                    '                and organization_id = wro.organization_id '||
                    '                and category_set_id = :cat_set_id '||
                    '                and category_id in (:cat_ids))';
    l_sql := l_sql || l_cat_clause;
  end if;

  if(l_item_ids is not null) then
    l_item_clause := '  and msi.inventory_item_id in (:inv_item_ids)';
    l_sql := l_sql || l_item_clause;
  end if;
*/

  l_cat_ids := get_pref_comp_cat(p_org_id);
  wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_critical_components:l_cat_ids='||l_cat_ids);
  l_item_ids := get_pref_comp_id(p_org_id);
  wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_critical_components:l_item_ids='||l_item_ids);

  if(is_all_component_selected(p_org_id)) then
    l_all_clause := ' 1=1 ';
  end if;

  if(l_cat_ids is not null) then
    l_cat_clause := '   exists (select inventory_item_id ' ||
                    '               from mtl_item_categories ' ||
                    '              where inventory_item_id = wro.inventory_item_id '||
                    '                and organization_id = wro.organization_id '||
                    '                and category_set_id = :cat_set_id '||
                    '                and category_id in (:cat_ids))';
    --l_sql := l_sql || l_cat_clause;
  end if;

  if(l_item_ids is not null) then
    --l_item_clause := '   msi.inventory_item_id in (:inv_item_ids)';
      l_item_clause := 'msi.inventory_item_id in ( '||
  '  select wpv.attribute_value_code ' ||
  '    from wip_preference_values wpv ' ||
  '   where wpv.preference_id = :pref_id_comp_short1 ' ||
  '     and wpv.level_id = :pref_level_id_site1 ' ||
  '     and wpv.attribute_name = :pref_val_comp_type_item_att1 ' ||
  '     and wpv.sequence_number in  ( ' ||
  '       select wpv1.sequence_number ' ||
  '         from wip_preference_values wpv1 ' ||
  '        where wpv1.preference_id = :pref_id_comp_short2 ' ||
  '          and wpv1.level_id = :pref_level_id_site2 ' ||
  '          and wpv1.attribute_name = :pref_val_comp_type_att2 ' ||
  '          and wpv1.attribute_value_code = to_char(:pref_val_comp_type_item2) ' ||
  '          and wpv1.sequence_number in ( ' ||
  '            select wpv2.sequence_number ' ||
  '              from wip_preference_values wpv2 ' ||
  '             where wpv2.preference_id = :pref_id_comp_short3 ' ||
  '               and wpv2.level_id = :pref_level_id_site3 ' ||
  '               and wpv2.attribute_name = :pref_val_dtl_org_att3 ' ||
  '               and wpv2.attribute_value_code = to_char(wro.organization_id))) )';

    --l_sql := l_sql || l_item_clause;
  end if;

  if(l_all_clause is not null OR l_cat_clause is not null OR l_item_clause is not null) then
    l_temp_where := l_temp_where || '  and ( ';

    if(l_all_clause is not null) then
      l_temp_where := l_temp_where || '1 = 1';
    end if;

    if(l_cat_clause is not null) then
      if(l_all_clause is not null) then
        l_temp_where := l_temp_where || '    OR ';
      end if;
      l_temp_where := l_temp_where || l_cat_clause;
    end if;

    if(l_item_clause is not null) then
      if(l_all_clause is not null OR l_cat_clause is not null) then
        l_temp_where := l_temp_where || '    OR ';
      end if;
      l_temp_where := l_temp_where || l_item_clause;
    end if;

    l_temp_where := l_temp_where || ')';
  else
    l_temp_where := l_temp_where || 'and 1 = 2';
  end if;

  l_sql := l_sql || l_temp_where;




  wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_critical_components:l_sql='||l_sql);

  IF (g_wip_job_op_tbl.COUNT > 0) THEN
    wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_critical_components:g_wip_job_op_tbl.count>0');
    FOR i in g_wip_job_op_tbl.FIRST .. g_wip_job_op_tbl.LAST LOOP
      wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_critical_components:Entered in for loop for org_id='||g_wip_job_op_tbl(i).ORGANIZATION_ID||
      ',wip_ent_id='||g_wip_job_op_tbl(i).WIP_ENTITY_ID||',op_seq_num='||g_wip_job_op_tbl(i).OPERATION_SEQ_NUM);


      l_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);
      dbms_sql.define_column(l_cursor, 1, l_inv_item_id);
      dbms_sql.define_column(l_cursor, 2, l_subinv_code, 10);
      dbms_sql.define_column(l_cursor, 3, l_req_qty);
      dbms_sql.define_column(l_cursor, 4, l_qty_issued);
      dbms_sql.define_column(l_cursor, 5, l_qpa);
      dbms_sql.define_column(l_cursor, 6, l_qty_allocated);
      dbms_sql.define_column(l_cursor, 7, l_basis_type);
      dbms_sql.define_column(l_cursor, 8, l_wip_supply_type);
      dbms_sql.define_column(l_cursor, 9, l_uom_code, 3);
      dbms_sql.define_column(l_cursor, 10, l_yield);

      dbms_sql.bind_variable(l_cursor, ':l_org_id', g_wip_job_op_tbl(i).ORGANIZATION_ID);
      dbms_sql.bind_variable(l_cursor, ':l_wip_ent_id', g_wip_job_op_tbl(i).WIP_ENTITY_ID);
      dbms_sql.bind_variable(l_cursor, ':l_operation_seq_num', g_wip_job_op_tbl(i).OPERATION_SEQ_NUM);

      if(l_cat_ids is not null) then
        dbms_sql.bind_variable(l_cursor, ':cat_set_id', g_org_comp_calc_rec.category_set_id);
        dbms_sql.bind_variable(l_cursor, ':cat_ids', l_cat_ids);
      end if;
      if(l_item_ids is not null) then
        --dbms_sql.bind_variable(l_cursor, ':inv_item_ids', l_item_ids);
        dbms_sql.bind_variable(l_cursor, ':pref_id_comp_short1', g_pref_id_comp_short );
        dbms_sql.bind_variable(l_cursor, ':pref_level_id_site1', g_pref_level_id_site);
        dbms_sql.bind_variable(l_cursor, ':pref_val_comp_type_item_att1', g_pref_val_comp_type_item_att);
        dbms_sql.bind_variable(l_cursor, ':pref_id_comp_short2', g_pref_id_comp_short);
        dbms_sql.bind_variable(l_cursor, ':pref_level_id_site2', g_pref_level_id_site);
        dbms_sql.bind_variable(l_cursor, ':pref_val_comp_type_att2', g_pref_val_comp_type_att);
        dbms_sql.bind_variable(l_cursor, ':pref_val_comp_type_item2', g_pref_val_comp_type_item);
        dbms_sql.bind_variable(l_cursor, ':pref_id_comp_short3', g_pref_id_comp_short);
        dbms_sql.bind_variable(l_cursor, ':pref_level_id_site3', g_pref_level_id_site);
        dbms_sql.bind_variable(l_cursor, ':pref_val_dtl_org_att3', g_pref_val_dtl_org_att);

      end if;

      wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_critical_components: point 10 - before dbms_sql.execute');
      l_dummy := dbms_sql.execute(l_cursor);
      wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_critical_components: point 20 - after dbms_sql.execute');
      LOOP
        EXIT WHEN DBMS_SQL.FETCH_ROWS (l_cursor) = 0;
        wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_critical_components: point 50');
        dbms_sql.column_value(l_cursor, 1, l_inv_item_id);
        dbms_sql.column_value(l_cursor, 2, l_subinv_code);
        dbms_sql.column_value(l_cursor, 3, l_req_qty);
        dbms_sql.column_value(l_cursor, 4, l_qty_issued);
        dbms_sql.column_value(l_cursor, 5, l_qpa);
        dbms_sql.column_value(l_cursor, 6, l_qty_allocated);
        dbms_sql.column_value(l_cursor, 7, l_basis_type);
        dbms_sql.column_value(l_cursor, 8, l_wip_supply_type);
        dbms_sql.column_value(l_cursor, 9, l_uom_code);
        dbms_sql.column_value(l_cursor, 10, l_yield);

        wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_critical_components:add_critical_component=l_inv_item_id='||l_inv_item_id||
        ',l_qpa='||l_qpa||',l_req_qty='||l_req_qty||',l_qty_issued='||l_qty_issued||
        ',l_op_open_qty='||g_wip_job_op_tbl(i).OPEN_QTY||
        ',l_qty_allocated='||l_qty_allocated||',l_comp_open_qty='||to_char((g_wip_job_op_tbl(i).OPEN_QTY * l_qpa) - l_qty_issued - l_qty_allocated));


        --add record for org level component information
        j := g_wip_job_critical_comp_tbl.LAST;
        if (j is NULL) then j:= 0; end if; j := j+1;
        g_wip_job_critical_comp_tbl(j).ORGANIZATION_ID     := p_org_id;
        g_wip_job_critical_comp_tbl(j).WIP_ENTITY_ID       := g_wip_job_op_tbl(i).WIP_ENTITY_ID;
        g_wip_job_critical_comp_tbl(j).OPERATION_SEQ_NUM   := g_wip_job_op_tbl(i).OPERATION_SEQ_NUM;
        g_wip_job_critical_comp_tbl(j).INVENTORY_ITEM_ID   := l_inv_item_id;
        g_wip_job_critical_comp_tbl(j).DEPARTMENT_ID       := g_wip_job_op_tbl(i).DEPARTMENT_ID;
        g_wip_job_critical_comp_tbl(j).DATE_REQUIRED       := g_wip_job_op_tbl(i).FIRST_UNIT_START_DATE;
        g_wip_job_critical_comp_tbl(j).QTY_PER_ASSEMBLY    := l_qpa;
        g_wip_job_critical_comp_tbl(j).REQUIRED_QTY        := l_req_qty;
        g_wip_job_critical_comp_tbl(j).QUANTITY_ISSUED     := l_qty_issued;
        --g_wip_job_critical_comp_tbl(j).QUANTITY_OPEN       := (g_wip_job_op_tbl(i).OPEN_QTY * l_qpa) - l_qty_issued - l_qty_allocated;
        if(nvl(l_basis_type, 1) = 1) then --item basis type
          l_qty_open := (g_wip_job_op_tbl(i).OPEN_QTY * l_qpa)/l_yield - l_qty_issued - l_qty_allocated;
        else --basis type = lot
          l_qty_open := l_qpa/l_yield - l_qty_issued - l_qty_allocated;
        end if;
        if(l_qty_open < 0) then l_qty_open := 0; end if;
        g_wip_job_critical_comp_tbl(j).QUANTITY_OPEN       := nvl(l_qty_open , 0);
        g_wip_job_critical_comp_tbl(j).WIP_SUPPLY_TYPE     := l_wip_supply_type;
        g_wip_job_critical_comp_tbl(j).BASIS_TYPE          := l_basis_type;
        g_wip_job_critical_comp_tbl(j).SUPPLY_SUBINVENOTRY := null; --for org record
        g_wip_job_critical_comp_tbl(j).PRIMARY_UOM_CODE    := l_uom_code;

        --add another record for subinv if preference is set
        if(g_org_comp_calc_rec.shortage_calc_level = 2) then
          wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_critical_components:add_critical_component=l_inv_item_id='||l_inv_item_id||', l_subinv='||l_subinv_code);
          j := g_wip_job_critical_comp_tbl.LAST;
          if (j is NULL) then j:= 0; end if; j := j+1;
          g_wip_job_critical_comp_tbl(j).ORGANIZATION_ID     := p_org_id;
          g_wip_job_critical_comp_tbl(j).WIP_ENTITY_ID       := g_wip_job_op_tbl(i).WIP_ENTITY_ID;
          g_wip_job_critical_comp_tbl(j).OPERATION_SEQ_NUM   := g_wip_job_op_tbl(i).OPERATION_SEQ_NUM;
          g_wip_job_critical_comp_tbl(j).INVENTORY_ITEM_ID   := l_inv_item_id;
          g_wip_job_critical_comp_tbl(j).DEPARTMENT_ID       := g_wip_job_op_tbl(i).DEPARTMENT_ID;
          g_wip_job_critical_comp_tbl(j).DATE_REQUIRED       := g_wip_job_op_tbl(i).FIRST_UNIT_START_DATE;
          g_wip_job_critical_comp_tbl(j).QTY_PER_ASSEMBLY    := l_qpa;
          g_wip_job_critical_comp_tbl(j).REQUIRED_QTY        := l_req_qty;
          g_wip_job_critical_comp_tbl(j).QUANTITY_ISSUED     := l_qty_issued;
          --g_wip_job_critical_comp_tbl(j).QUANTITY_OPEN       := (g_wip_job_op_tbl(i).OPEN_QTY * l_qpa) - (l_qty_issued - l_qty_allocated);
          if(nvl(l_basis_type, 1) = 1) then --item basis type
            l_qty_open := (g_wip_job_op_tbl(i).OPEN_QTY * l_qpa)/l_yield - l_qty_issued - l_qty_allocated;
          else --basis type = lot
            l_qty_open := l_qpa/l_yield - l_qty_issued - l_qty_allocated;
          end if;
          if(l_qty_open < 0) then l_qty_open := 0; end if;
          g_wip_job_critical_comp_tbl(j).QUANTITY_OPEN       := nvl(l_qty_open , 0);
          g_wip_job_critical_comp_tbl(j).WIP_SUPPLY_TYPE     := l_wip_supply_type;
          g_wip_job_critical_comp_tbl(j).BASIS_TYPE          := l_basis_type;
          g_wip_job_critical_comp_tbl(j).SUPPLY_SUBINVENOTRY := l_subinv_code; --for subinv record
          g_wip_job_critical_comp_tbl(j).PRIMARY_UOM_CODE    := l_uom_code;
        end if;
      END LOOP;


      dbms_sql.close_cursor(l_cursor);

    END LOOP;
  END IF;
  --EXCEPTION
  --  WHEN OTHERS THEN
  --    dbms_sql.close_cursor(l_cursor);

END get_job_critical_components;


/**
 * This procedure finds out the critical resources used in jobs based on preference and stores these
 * in global pl/sql table for later use. These job op resources are ordered by required date (operation start date)
 */
PROCEDURE get_job_critical_resources(p_org_id NUMBER, p_end_time DATE) IS
  l_job_status_clause VARCHAR2(240);
  l_job_statuses VARCHAR2(240);
  l_sql VARCHAR2(2048);
  l_cursor integer;
  l_dummy integer;
  l_org_id NUMBER;
  l_wip_ent_id NUMBER;
  l_dept_id NUMBER;
  l_op_seq_num NUMBER;
  l_op_fusd NUMBER;
  l_op_sch_qty NUMBER;
  l_op_start_qty NUMBER;
  l_op_open_qty NUMBER;
  i NUMBER;
  j NUMBER;
  CURSOR res_req_csr(p_org_id NUMBER, p_wip_ent_id NUMBER, p_op_seq_num NUMBER) IS
    select distinct
           wor.wip_entity_id,
           wor.operation_seq_num,
           wor.resource_id,
           nvl(wip_ws_dl_util.get_col_res_usage_req(wor.wip_entity_id, wor.operation_seq_num,wo.department_id, wor.resource_id, null),0) open_quantity,
           wor.uom_code,
           decode( wip_ws_time_entry.is_time_uom(wor.uom_code), 'Y',
               inv_convert.inv_um_convert(-1,
                                  38,
                                  wor.usage_rate_or_amount,
                                  wor.uom_code,
                                  fnd_profile.value('BOM:HOUR_UOM_CODE'),
                                  NULL,
                                  NULL),
               null) usage,
           wor.applied_resource_units ,
           wor.basis_type,
           decode(wp.include_resource_efficiency, 1, nvl(bdr.efficiency, 1), 1) efficiency
      from wip_operation_resources wor,
           wip_operations wo,
           wip_parameters wp,
           bom_department_resources bdr
     where wor.organization_id = p_org_id
       and wor.wip_entity_id = p_wip_ent_id
       and wor.operation_seq_num = p_op_seq_num
       and wo.wip_entity_id = wor.wip_entity_id
       and wo.organization_id = wor.organization_id
       and wp.organization_id = wor.organization_id
       and wo.operation_seq_num = wor.operation_seq_num
       and bdr.resource_id = wor.resource_id
       and bdr.department_id = nvl(wor.department_id, wo.department_id)
       and wor.resource_id in (
         select distinct to_number(wpv.attribute_value_code) resource_id
           from wip_preference_values wpv
          where wpv.preference_id = g_pref_id_res_short
            and wpv.attribute_name = 'resource'
            and wpv.level_id = 1
            and wpv.sequence_number in (
              select wpv_org.sequence_number
                from wip_preference_values wpv_org
               where wpv_org.preference_id = g_pref_id_res_short
                 and wpv_org.attribute_name = 'organization'
                 and to_number(wpv_org.attribute_value_code) = p_org_id))
       order by resource_id;

l_shift_seq NUMBER;
l_shift_num NUMBER;
l_shift_start_date DATE;
l_shift_end_date DATE;
l_shift_string VARCHAR2(240);
l_req_date DATE;
l_res_req NUMBER;
prev_res_id NUMBER;

cursor critical_res_csr IS
select organization_id, resource_id, department_id from wip_ws_critical_res_temp;


BEGIN
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:get_job_critical_resources:Entered ');

  IF (g_wip_job_op_tbl.COUNT > 0) THEN
      FOR i in g_wip_job_op_tbl.FIRST .. g_wip_job_op_tbl.LAST LOOP
      wip_ws_util.trace_log('WIP_WS_SHORTAGE:get_job_critical_resources: Check critical resources in operation  ');
      wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_critical_resources:Entered in operation for loop for org_id='||g_wip_job_op_tbl(i).ORGANIZATION_ID||
      ',wip_ent_id='||g_wip_job_op_tbl(i).WIP_ENTITY_ID||',op_seq_num='||g_wip_job_op_tbl(i).OPERATION_SEQ_NUM);
      prev_res_id := null;
      FOR c_res_req_csr in res_req_csr(p_org_id,g_wip_job_op_tbl(i).WIP_ENTITY_ID, g_wip_job_op_tbl(i).OPERATION_SEQ_NUM) LOOP
        IF(c_res_req_csr.resource_id <> nvl(prev_res_id , -1)) THEN
          prev_res_id := c_res_req_csr.resource_id;
          wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_critical_resources:Entered in resource for loop for resource id='||c_res_req_csr.RESOURCE_ID||
          ',qty_open='||c_res_req_csr.open_quantity);

          j := g_wip_job_critical_res_tbl.LAST;
          if (j is NULL) then j:=0; end if; j:=j+1;
          g_wip_job_critical_res_tbl(j).ORGANIZATION_ID     := p_org_id;
          g_wip_job_critical_res_tbl(j).WIP_ENTITY_ID       := g_wip_job_op_tbl(i).WIP_ENTITY_ID;
          g_wip_job_critical_res_tbl(j).OPERATION_SEQ_NUM   := g_wip_job_op_tbl(i).OPERATION_SEQ_NUM;
          g_wip_job_critical_res_tbl(j).RESOURCE_ID         := c_res_req_csr.RESOURCE_ID;
          g_wip_job_critical_res_tbl(j).DEPARTMENT_ID       := g_wip_job_op_tbl(i).DEPARTMENT_ID;
          g_wip_job_critical_res_tbl(j).DATE_REQUIRED       := g_wip_job_op_tbl(i).FIRST_UNIT_START_DATE;
          g_wip_job_critical_res_tbl(j).QUANTITY_OPEN       := c_res_req_csr.open_quantity;
          g_wip_job_critical_res_tbl(j).PRIMARY_UOM_CODE    := c_res_req_csr.uom_code;
          g_wip_job_critical_res_tbl(j).QUANTITY_ISSUED     := c_res_req_csr.applied_resource_units;
          if(nvl(c_res_req_csr.basis_type, 1) = 1) then --item basis type
            l_res_req := c_res_req_csr.usage * g_wip_job_op_tbl(i).OPEN_QTY;
          else
            l_res_req := c_res_req_csr.usage;
          end if;

          l_res_req := nvl(l_res_req, 0) / nvl(c_res_req_csr.efficiency, 1);
          g_wip_job_critical_res_tbl(j).REQUIRED_QTY      := l_res_req;
          l_req_date := g_wip_job_critical_res_tbl(j).DATE_REQUIRED; -- bug 9484419
          if(g_wip_job_critical_res_tbl(j).DATE_REQUIRED < sysdate) then
            l_req_date := sysdate;
          end if;
          wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_critical_resources:calling wip_ws_util.retrive_first_shift');
          --get shift id for each resource
          wip_ws_util.retrieve_first_shift(
            p_org_id           => g_wip_job_critical_res_tbl(j).ORGANIZATION_ID,
            p_dept_id          => g_wip_job_critical_res_tbl(j).DEPARTMENT_ID,
            p_resource_id      => g_wip_job_critical_res_tbl(j).RESOURCE_ID ,
            p_date             => l_req_date,
            x_shift_seq        => l_shift_seq,
            x_shift_num        => l_shift_num,
            x_shift_start_date => l_shift_start_date,
            x_shift_end_date   => l_shift_end_date,
            x_shift_string     => l_shift_string
          );

          wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_critical_resources:back from retrieve_first_shift with shift_num='||
          l_shift_num||',shift_seq='||l_shift_seq);

          g_wip_job_critical_res_tbl(j).SHIFT_NUM := l_shift_num;
          g_wip_job_critical_res_tbl(j).SHIFT_SEQ := l_shift_seq;
          --insert a record for dept resource
          begin
            insert into wip_ws_critical_res_temp
            (organization_id,
             resource_id,
             department_id)
            values
            (
             g_wip_job_critical_res_tbl(j).ORGANIZATION_ID,
             g_wip_job_critical_res_tbl(j).RESOURCE_ID,
             g_wip_job_critical_res_tbl(j).DEPARTMENT_ID
            );

          exception when others then --ignore duplicate exception
            null;
          end;
        END IF;
      END LOOP;
    END LOOP;
  END IF;

  wip_ws_util.trace_log( 'Printing critical job op resources');
  IF (g_wip_job_critical_res_tbl.COUNT > 0) THEN
    FOR j in g_wip_job_critical_res_tbl.FIRST .. g_wip_job_critical_res_tbl.LAST LOOP
        wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_critical_resources:Critical Resource:'||
        'org_id='||g_wip_job_critical_res_tbl(j).ORGANIZATION_ID ||
        ',wip_ent_id='||g_wip_job_critical_res_tbl(j).WIP_ENTITY_ID ||
        ',op_seq_num='||g_wip_job_critical_res_tbl(j).OPERATION_SEQ_NUM ||
        'res_id,='||g_wip_job_critical_res_tbl(j).RESOURCE_ID ||
        ',dept_id='||g_wip_job_critical_res_tbl(j).DEPARTMENT_ID ||
        ',date_req='||g_wip_job_critical_res_tbl(j).DATE_REQUIRED ||
        ',qty_req='||g_wip_job_critical_res_tbl(j).REQUIRED_QTY ||
        ',qty_issued='||g_wip_job_critical_res_tbl(j).QUANTITY_ISSUED ||
        ',qty_open='||g_wip_job_critical_res_tbl(j).QUANTITY_OPEN ||
        ',uom='||g_wip_job_critical_res_tbl(j).PRIMARY_UOM_CODE||
        ',shift_num='||g_wip_job_critical_res_tbl(j).SHIFT_NUM||
        ',shift_seq='||g_wip_job_critical_res_tbl(j).SHIFT_SEQ);
    END LOOP;
  END IF;

  wip_ws_util.trace_log( 'Printing critical resources');
  for c_critical_res_csr in critical_res_csr loop
    wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:get_job_critical_resources:Critical Resource in temp table:'||
    'org_id='||c_critical_res_csr.ORGANIZATION_ID ||
    ',res_id='||c_critical_res_csr.RESOURCE_ID ||
    ',dept_id='||c_critical_res_csr.DEPARTMENT_ID);

  end loop;

END get_job_critical_resources;


/*
 * This procedure finds out the supply from discrete jobs for a particular subassy on a given date
 * The returned qty does not include the qty that is already reserved
 */
FUNCTION get_wip_supply(p_org_id NUMBER, p_inv_item_id NUMBER, p_rcpt_date DATE) RETURN NUMBER IS
  CURSOR job_csr (p_org_id NUMBER, p_inv_item_id NUMBER, p_rcpt_date DATE) IS
    select wdj.organization_id,
           wdj.primary_item_id inventory_item_id,
           wdj.scheduled_completion_date receipt_date,
           GREATEST(0, (wdj.start_quantity - wdj.quantity_completed
             - wdj.quantity_scrapped)) item_qty,
           (select sum(mr.reservation_quantity)
              from mtl_reservations mr
             where mr.supply_source_type_id = 5 --wip supply
               and mr.supply_source_header_id = wdj.wip_entity_id
               and mr.organization_id = wdj.organization_id) reservation_qty,
           wdj.wip_entity_id --added for bug 6886708 for logging
    from wip_discrete_jobs wdj
   where wdj.organization_id = p_org_id
     and wdj.primary_item_id = p_inv_item_id
     and trunc(wdj.scheduled_completion_date) = trunc(p_rcpt_date)
     and wdj.status_type IN (WIP_CONSTANTS.UNRELEASED, WIP_CONSTANTS.RELEASED,
                             WIP_CONSTANTS.COMP_CHRG, WIP_CONSTANTS.HOLD)
     and (wdj.start_quantity - wdj.quantity_completed - wdj.quantity_scrapped) > 0
     and wdj.job_type in (WIP_CONSTANTS.STANDARD, WIP_CONSTANTS.NONSTANDARD);
  l_qty NUMBER := 0;
BEGIN
  for c_job_csr in job_csr(p_org_id, p_inv_item_id, p_rcpt_date) loop
    l_qty := l_qty + (c_job_csr.item_qty - nvl(c_job_csr.reservation_qty,0));
    wip_ws_util.trace_log('WIP_WS_SHORTAGE:get_wip_supply: '||
    'c_job_csr.wip_entity_id = '||c_job_csr.wip_entity_id||
    'c_job_csr.item_qty = '||c_job_csr.item_qty||
    'c_job_csr.reservation_qty = '||c_job_csr.reservation_qty);
  end loop;
  if(l_qty < 0 or l_qty is null) then l_qty := 0; end if;
  return l_qty;

  EXCEPTION when others then
    return 0;
END get_wip_supply;

/*
 * This procedure finds out the supply from flow schedules for a particular subassy on a given date
 *
 */
FUNCTION get_flow_supply(p_org_id NUMBER, p_inv_item_id NUMBER, p_rcpt_date DATE) RETURN NUMBER IS
  CURSOR flow_sched_csr(p_org_id NUMBER, p_inv_item_id NUMBER, p_rcpt_date DATE) IS
    select SUM(GREATEST( 0, (wfs.planned_quantity - wfs.quantity_completed
             - wfs.quantity_scrapped))) item_qty,
    wfs.wip_entity_id --added for bug 6886708 for logging
    from WIP_FLOW_SCHEDULES wfs
   where wfs.status = 1
     and wfs.SCHEDULED_FLAG = 1
     and wfs.organization_id = p_org_id
     and wfs.primary_item_id = p_inv_item_id
     and trunc(wfs.scheduled_completion_date) = trunc(p_rcpt_date)
     and (wfs.planned_quantity - wfs.quantity_completed - quantity_scrapped) > 0
     and wfs.demand_source_header_id is null
     and wfs.demand_source_line is null;
  l_qty NUMBER := 0;
BEGIN
  for c_flow_sched_csr in flow_sched_csr(p_org_id, p_inv_item_id, p_rcpt_date) loop
    l_qty := c_flow_sched_csr.item_qty;
    wip_ws_util.trace_log('WIP_WS_SHORTAGE:get_flow_supply: '||
        'flow_sched_csr.wip_entity_id = '||c_flow_sched_csr.wip_entity_id||
      'flow_sched_csr.item_qty = '||c_flow_sched_csr.item_qty);
  end loop;
  if (l_qty < 0 or l_qty is null) then l_qty := 0; end if;
  return l_qty;

  EXCEPTION when others then
    return 0;

END get_flow_supply;


/*
 * This procedure finds out the supply from discrete jobs negative requirements
 * for a particular subassy on a given date
 */
FUNCTION get_wip_negreq_supply(p_org_id NUMBER, p_inv_item_id NUMBER, p_rcpt_date DATE) RETURN NUMBER IS
  CURSOR wip_negreq_csr(p_org_id NUMBER, p_inv_item_id NUMBER, p_rcpt_date DATE) IS
    select SUM(-1*wro.required_quantity) item_qty
      from wip_requirement_operations wro,
           wip_discrete_jobs wdj
     where wro.organization_id = p_org_id
       and wro.inventory_item_id = p_inv_item_id
       and trunc(wro.date_required) = trunc(p_rcpt_date)
       and wro.organization_id = wdj.organization_id
       and wro.wip_entity_id = wdj.wip_entity_id
       and wro.wip_supply_type <> wip_constants.PHANTOM
       and wro.required_quantity < 0
       and wro.operation_seq_num > 0
       and wdj.job_type in (WIP_CONSTANTS.STANDARD, WIP_CONSTANTS.NONSTANDARD)
       and wdj.status_type IN (WIP_CONSTANTS.UNRELEASED, WIP_CONSTANTS.RELEASED,
                               WIP_CONSTANTS.COMP_CHRG, WIP_CONSTANTS.HOLD);
  l_qty NUMBER := 0;
BEGIN
  for c_wip_negreq_csr in wip_negreq_csr(p_org_id, p_inv_item_id, p_rcpt_date) loop
    l_qty := c_wip_negreq_csr.item_qty;
    wip_ws_util.trace_log('WIP_WS_SHORTAGE:get_wip_negreq_supply: '||
      'wip_negreq_csr.item_qty = '||c_wip_negreq_csr.item_qty);
  end loop;
  if (l_qty < 0 or l_qty is null) then l_qty := 0; end if;
  return l_qty;

  EXCEPTION when others then
    return 0;
END get_wip_negreq_supply;


/*
 * This procedure finds out the supply from repetitive schedule for a particular subassy on a given date
 */
FUNCTION get_rep_sch_supply(p_org_id NUMBER, p_inv_item_id NUMBER, p_rcpt_date DATE) RETURN NUMBER IS
  CURSOR rep_sched_csr(p_org_id NUMBER, p_inv_item_id NUMBER, p_rcpt_date DATE)IS
SELECT
        SUM(MRP_HORIZONTAL_PLAN_SC.compute_daily_rate_t(dates.calendar_code, dates.exception_set_id,
                               sched.daily_production_rate, sched.quantity_completed,
                               sched.first_unit_completion_date, dates.calendar_date ))  item_qty
FROM    bom_calendar_dates dates,
        mtl_parameters param,
        wip_repetitive_schedules sched,
        wip_repetitive_items rep_items
WHERE   rep_items.primary_item_id = p_inv_item_id
and     rep_items.organization_id = p_org_id
and     rep_items.wip_entity_id = sched.wip_entity_id
and     rep_items.line_id = sched.line_id
and     sched.organization_id = rep_items.organization_id
and     sched.status_type IN (WIP_CONSTANTS.UNRELEASED,
           WIP_CONSTANTS.RELEASED, WIP_CONSTANTS.COMP_CHRG, WIP_CONSTANTS.HOLD)
and     dates.seq_num is not null
and     TRUNC(dates.calendar_date) >= TRUNC(sched.first_unit_completion_date)
and     TRUNC(dates.calendar_date)
                <= (select trunc(cal.calendar_date - 1)
                    from bom_calendar_dates cal
                    where cal.exception_set_id = dates.exception_set_id
                    and   cal.calendar_code    = dates.calendar_code
                    and   cal.seq_num =  (select cal1.prior_seq_num +  ceil(sched.processing_work_days)
                                          from bom_calendar_dates cal1
                                          where cal1.exception_set_id = dates.exception_set_id
                                          and cal1.calendar_code    = dates.calendar_code
                                          and cal1.calendar_date = TRUNC(sched.first_unit_completion_date)) )
and     dates.calendar_date = trunc(p_rcpt_date)
and     dates.exception_set_id = param.calendar_exception_set_id
and     dates.calendar_code = param.calendar_code
and     param.organization_id = rep_items.organization_id;
  l_qty NUMBER := 0;
BEGIN
  for c_rep_sched_csr in rep_sched_csr(p_org_id, p_inv_item_id, p_rcpt_date) loop
    l_qty := c_rep_sched_csr.item_qty;
    wip_ws_util.trace_log('WIP_WS_SHORTAGE:get_rep_sch_supply: '||
      'rep_sched_csr.item_qty = '||c_rep_sched_csr.item_qty);
  end loop;
  if (l_qty < 0 or l_qty is null) then l_qty := 0; end if;
  return l_qty;

  EXCEPTION when others then
    return 0;
END get_rep_sch_supply;


/*
 * This procedure finds out the supply from purchase order for a particular item on a given date
 * The returned qty does not include the qty that is already reserved
 */
FUNCTION get_po_supply(p_org_id NUMBER, p_inv_item_id NUMBER, p_rcpt_date DATE) RETURN NUMBER IS
  CURSOR po_csr(p_org_id NUMBER, p_inv_item_id NUMBER, p_rcpt_date DATE) IS
  SELECT
     ms.to_org_primary_quantity item_qty,
     (select sum(mr.reservation_quantity)
        from mtl_reservations mr
       where mr.supply_source_type_id = 1 --po supply
         and mr.supply_source_header_id = ms.po_header_id
         and mr.supply_source_line_id = ms.po_line_id ) reservation_qty,
         pd.PO_HEADER_ID --added for bug 6886708 for logging
  FROM    po_distributions_all pd,
          mtl_supply ms
  WHERE   ms.item_id = p_inv_item_id
  AND     ms.to_organization_id = p_org_id
  AND      ( ms.supply_type_code = 'PO' or
             ms.supply_type_code = 'ASN')
  AND      ms.destination_type_code = 'INVENTORY'
  AND      trunc(ms.expected_delivery_date) = trunc(p_rcpt_date)
  AND      pd.po_distribution_id = ms.po_distribution_id
  AND      ms.po_line_id is not null
  AND      ms.item_id is not null
  AND      ms.to_org_primary_quantity > 0
  AND    NOT EXISTS (select 'y'  FROM   OE_DROP_SHIP_SOURCES ODSS
                     WHERE  ms.po_line_location_id  = ODSS.line_location_id);

  l_qty NUMBER := 0;
BEGIN
  for c_po_csr in po_csr(p_org_id, p_inv_item_id, p_rcpt_date) loop
    l_qty := l_qty + (nvl(c_po_csr.item_qty,0) - nvl(c_po_csr.reservation_qty,0));
    wip_ws_util.trace_log('WIP_WS_SHORTAGE:get_po_supply: '||
        'po_csr.PO_HEADER_ID = '||c_po_csr.PO_HEADER_ID||
        'po_csr.item_qty = '||c_po_csr.item_qty||
      'po_csr.reservation_qty = '||c_po_csr.reservation_qty);
  end loop;
  if(l_qty < 0 or l_qty is null) then l_qty := 0; end if;
  return l_qty;

  EXCEPTION when others then
    return 0;
END get_po_supply;


/*
 * This procedure finds out the supply from purchase req for a particular item on a given date
 * The returned qty does not include the qty that is already reserved
 */
FUNCTION get_req_supply(p_org_id NUMBER, p_inv_item_id NUMBER, p_rcpt_date DATE) RETURN NUMBER IS
  CURSOR req_csr(p_org_id NUMBER, p_inv_item_id NUMBER, p_rcpt_date DATE) IS
  SELECT
      (nvl(ms.to_org_primary_quantity,0) *
        pd.req_line_quantity/prl.quantity) item_qty,
      (select sum(mr.reservation_quantity)
        from mtl_reservations mr
       where mr.supply_source_type_id = 18 --po req supply
         and mr.supply_source_header_id = ms.req_header_id
         and mr.supply_source_line_id = ms.req_line_id ) reservation_qty,
        pd.requisition_line_id, --added for bug 6886708 for logging
        prl.REQUISITION_HEADER_ID --added for bug 6886708 for logging
  FROM po_req_distributions_all pd,
       po_requisition_lines_all prl,
       mtl_supply ms
  WHERE    ms.item_id = p_inv_item_id
  AND      ms.to_organization_id = p_org_id
  AND      ms.supply_type_code = 'REQ'
  AND      ms.destination_type_code = 'INVENTORY'
  AND      trunc(ms.expected_delivery_date) = trunc(p_rcpt_date)
  AND      pd.requisition_line_id = prl.requisition_line_id
  AND      prl.requisition_line_id = ms.req_line_id
  AND      ms.to_org_primary_quantity > 0
  AND      ms.req_line_id is not null
  AND      ms.item_id is not null
  AND    NOT EXISTS (select 'y'  FROM   OE_DROP_SHIP_SOURCES ODSS
                     WHERE  ms.req_line_id  = ODSS.requisition_line_id);
  l_qty NUMBER := 0;
BEGIN
  for c_req_csr in req_csr(p_org_id, p_inv_item_id, p_rcpt_date) loop
    l_qty := l_qty + (c_req_csr.item_qty - nvl(c_req_csr.reservation_qty,0));
    wip_ws_util.trace_log('WIP_WS_SHORTAGE:get_req_supply: '||
        'req_csr.requisition_line_id = '||c_req_csr.requisition_line_id||
        'req_csr.REQUISITION_HEADER_ID = '||c_req_csr.REQUISITION_HEADER_ID||
        'req_csr.item_qty = '||c_req_csr.item_qty||
      'req_csr.reservation_qty = '||c_req_csr.reservation_qty);
  end loop;
  if(l_qty < 0 or l_qty is null) then l_qty := 0; end if;
  return l_qty;

  EXCEPTION when others then
    return 0;
END get_req_supply;

/*
 * This procedure finds out the supply from instransit shipment for a particular item on a given date
 * The returned qty does not include the qty that is already reserved
 */
FUNCTION get_intransit_ship_supply(p_org_id NUMBER, p_inv_item_id NUMBER, p_rcpt_date DATE) RETURN NUMBER IS
  CURSOR intransit_ship_csr(p_org_id NUMBER, p_inv_item_id NUMBER, p_rcpt_date DATE) IS
  SELECT
      SUM(nvl(ms.to_org_primary_quantity, 0) * pd.req_line_quantity/pl.quantity)
             item_qty,
     (select sum(mr.reservation_quantity)
        from mtl_reservations mr
       where mr.supply_source_type_id = 18 --todo, need to check source type id
         and mr.supply_source_header_id = ms.shipment_header_id
         and mr.supply_source_line_id = ms.shipment_line_id ) reservation_qty,
        pd.requisition_line_id, --added for bug 6886708 for logging
        pl.REQUISITION_HEADER_ID --added for bug 6886708 for logging
  FROM    po_req_distributions_all pd,
          po_requisition_lines_all pl,
          mtl_supply ms
  WHERE    ms.item_id = p_inv_item_id
  AND      ms.to_organization_id = p_org_id
  AND      ms.supply_type_code = 'SHIPMENT'
  AND      ms.destination_type_code = 'INVENTORY'
  AND      pd.requisition_line_id = pl.requisition_line_id
  AND      pl.quantity > 0
  AND      pl.requisition_line_id = ms.req_line_id
  AND      trunc(ms.expected_delivery_date) = trunc(p_rcpt_date)
  --AND      ms.req_line_id is not null
  AND      ms.shipment_line_id is not null
  AND      ms.item_id is not null
  AND      ms.to_org_primary_quantity > 0;
 l_qty NUMBER := 0;
BEGIN
  for c_intransit_ship_csr in intransit_ship_csr(p_org_id, p_inv_item_id, p_rcpt_date) loop
    l_qty := l_qty + (c_intransit_ship_csr.item_qty - nvl(c_intransit_ship_csr.reservation_qty,0));
    wip_ws_util.trace_log('WIP_WS_SHORTAGE:get_intransit_ship_supply: '||
        'intransit_ship_csr.requisition_line_id = '||c_intransit_ship_csr.requisition_line_id||
        'intransit_ship_csr.REQUISITION_HEADER_ID = '||c_intransit_ship_csr.REQUISITION_HEADER_ID||
        'intransit_ship_csr.item_qty = '||c_intransit_ship_csr.item_qty||
      'intransit_ship_csr.reservation_qty = '||c_intransit_ship_csr.reservation_qty);
  end loop;
  if(l_qty < 0 or l_qty is null) then l_qty := 0; end if;
  return l_qty;

  EXCEPTION when others then
    return 0;
END get_intransit_ship_supply;


/*
 * This procedure finds out the supply from intransit receipt for a particular item on a given date
 * The returned qty does not include the qty that is already reserved
 */
FUNCTION get_intransit_receipt_supply(p_org_id NUMBER, p_inv_item_id NUMBER, p_rcpt_date DATE) RETURN NUMBER IS
  CURSOR intransit_receipt_csr(p_org_id NUMBER, p_inv_item_id NUMBER, p_rcpt_date DATE) IS

  SELECT
    nvl(ms.TO_ORG_PRIMARY_QUANTITY, 0) * pd.req_line_quantity /
                                             pl.quantity item_qty,
     (select sum(mr.reservation_quantity)
        from mtl_reservations mr
       where mr.supply_source_type_id = 18 --todo, need to check source type id
         and mr.supply_source_header_id = ms.shipment_header_id
         and mr.supply_source_line_id = ms.shipment_line_id ) reservation_qty
  FROM po_requisition_lines_all pl,
       po_req_distributions_all pd,
       mtl_supply ms
  WHERE    ms.item_id = p_inv_item_id
  AND      ms.to_organization_id = p_org_id
  AND      ms.supply_type_code = 'RECEIVING'
  AND      ms.destination_type_code = 'INVENTORY'
  AND      pd.requisition_line_id = pl.requisition_line_id
  AND      trunc(ms.expected_delivery_date) = trunc(p_rcpt_date)
  AND      pl.quantity > 0
  AND      ms.req_line_id = pl.requisition_line_id
  AND      ms.po_distribution_id is  null
  AND      ms.item_id is not null
  AND      ms.to_org_primary_quantity > 0
  AND    NOT EXISTS (select 'y'  FROM   OE_DROP_SHIP_SOURCES ODSS
                     WHERE  ms.req_line_id = ODSS.requisition_line_id)
  UNION ALL
  SELECT
      SUM(ms.to_org_primary_quantity) item_qty,
     (select sum(mr.reservation_quantity)
        from mtl_reservations mr
       where mr.supply_source_type_id = 18 --todo, need to check source type id
         and mr.supply_source_header_id = ms.shipment_header_id
         and mr.supply_source_line_id = ms.shipment_line_id ) reservation_qty
  FROM   mtl_secondary_inventories msub,
         mtl_supply ms
  WHERE    ms.item_id = p_inv_item_id
  AND      ms.to_organization_id = p_org_id
  AND      ms.supply_type_code = 'RECEIVING'
  AND      ms.destination_type_code = 'INVENTORY'
  AND      ms.to_organization_id = msub.organization_id(+)
  AND      ms.to_subinventory =  msub.secondary_inventory_name(+)
  AND      trunc(ms.expected_delivery_date) = trunc(p_rcpt_date)
  AND      ms.req_line_id is  null
  AND      ms.po_distribution_id is null
  AND      ms.item_id is not null
  AND      ms.to_org_primary_quantity > 0;
 l_qty NUMBER := 0;
BEGIN
  for c_intransit_receipt_csr in intransit_receipt_csr(p_org_id, p_inv_item_id, p_rcpt_date) loop
    l_qty := l_qty + (c_intransit_receipt_csr.item_qty - nvl(c_intransit_receipt_csr.reservation_qty,0));
    wip_ws_util.trace_log('WIP_WS_SHORTAGE:get_intransit_receipt_supply: '||
        'c_intransit_receipt_csr.item_qty = '||c_intransit_receipt_csr.item_qty||
      'c_intransit_receipt_csr.reservation_qty = '||c_intransit_receipt_csr.reservation_qty);
  end loop;
  if(l_qty < 0 or l_qty is null) then l_qty := 0; end if;
  return l_qty;

  EXCEPTION when others then
    return 0;
END get_intransit_receipt_supply;


/*
 * This procedure finds out the supply from po in rcvng for a particular item on a given date
 * The returned qty does not include the qty that is already reserved
 */
FUNCTION get_po_rcv_supply(p_org_id NUMBER, p_inv_item_id NUMBER, p_rcpt_date DATE) RETURN NUMBER IS
  CURSOR po_rcv_csr(p_org_id NUMBER, p_inv_item_id NUMBER, p_rcpt_date DATE) IS
  SELECT
     ms.to_org_primary_quantity item_qty,
     (select sum(mr.reservation_quantity)
        from mtl_reservations mr
       where mr.supply_source_type_id = 18 --todo, need to check source type id
         and mr.supply_source_header_id = ms.shipment_header_id
         and mr.supply_source_line_id = ms.shipment_line_id ) reservation_qty,
        pd.PO_HEADER_ID --added for bug 6886708 for logging
  FROM    po_distributions_all pd,
          mtl_supply  ms
  WHERE    ms.item_id = p_inv_item_id
  AND      ms.to_organization_id = p_org_id
  AND      ms.supply_type_code = 'RECEIVING'
  AND      ms.destination_type_code = 'INVENTORY'
  AND      trunc(ms.expected_delivery_date) = trunc(p_rcpt_date)
  AND      pd.po_distribution_id = ms.po_distribution_id
  and      ms.item_id is not null
  AND      ms.to_org_primary_quantity > 0
  AND    NOT EXISTS (select 'y'  FROM   OE_DROP_SHIP_SOURCES ODSS
                     WHERE  ms.po_line_location_id  = ODSS.line_location_id);
 l_qty NUMBER := 0;
BEGIN
  for c_po_rcv_csr in po_rcv_csr(p_org_id, p_inv_item_id, p_rcpt_date) loop
    l_qty := l_qty + (c_po_rcv_csr.item_qty - nvl(c_po_rcv_csr.reservation_qty,0));
    wip_ws_util.trace_log('WIP_WS_SHORTAGE:get_po_rcv_supply: '||
  'c_po_rcv_csr.PO_HEADER_ID = '||c_po_rcv_csr.PO_HEADER_ID||
  'c_po_rcv_csr.item_qty = '||c_po_rcv_csr.item_qty||
  'c_po_rcv_csr.reservation_qty = '||c_po_rcv_csr.reservation_qty);
  end loop;
  if(l_qty < 0 or l_qty is null) then l_qty := 0; end if;
  return l_qty;

  EXCEPTION when others then
    return 0;
END get_po_rcv_supply;


/*
 * This functions finds out the expected rcpt qty for an item on a given
 * date. The qty is in primary uom. This procedure will include only loose
 * qty as expected receipt. If supply is tied with some reservation,
 * then its not considered as supply
 */
FUNCTION calc_expected_receipts(p_org_id NUMBER, p_inv_item_id NUMBER, p_rcpt_date DATE) RETURN NUMBER IS
  wip_supply               NUMBER := 0;
  neg_wip_supply           NUMBER := 0;
  flow_supply              NUMBER := 0;
  rep_sch_supply           NUMBER := 0;
  po_supply                NUMBER := 0;
  intransit_ship_supply    NUMBER := 0;
  req_supply               NUMBER := 0;
  intransit_receipt_supply NUMBER := 0;
  po_rcv_supply            NUMBER := 0;
BEGIN
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_expected_receipts: '||
    'p_org_id = '||p_org_id||
    'p_inv_item_id = '||p_inv_item_id||
    'p_rcpt_date = '||p_rcpt_date);

  wip_supply               := get_wip_supply(p_org_id, p_inv_item_id, p_rcpt_date);
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_expected_receipts: wip_supply = '||wip_supply);
  neg_wip_supply           := get_wip_negreq_supply(p_org_id, p_inv_item_id, p_rcpt_date);
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_expected_receipts: neg_wip_supply = '||neg_wip_supply);
  flow_supply              := get_flow_supply(p_org_id, p_inv_item_id, p_rcpt_date);
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_expected_receipts: flow_supply = '||flow_supply);
  rep_sch_supply           := get_rep_sch_supply(p_org_id, p_inv_item_id, p_rcpt_date);
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_expected_receipts: rep_sch_supply = '||rep_sch_supply);
  po_supply                := get_po_supply(p_org_id, p_inv_item_id, p_rcpt_date);
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_expected_receipts: po_supply = '||po_supply);
  intransit_ship_supply    := get_intransit_ship_supply(p_org_id, p_inv_item_id, p_rcpt_date);
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_expected_receipts: intransit_ship_supply = '||intransit_ship_supply);
  req_supply               := get_req_supply(p_org_id, p_inv_item_id, p_rcpt_date);
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_expected_receipts: req_supply = '||req_supply);
  intransit_receipt_supply := get_intransit_receipt_supply(p_org_id, p_inv_item_id, p_rcpt_date);
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_expected_receipts: intransit_receipt_supply = '||intransit_receipt_supply);
  po_rcv_supply            := get_po_rcv_supply(p_org_id, p_inv_item_id, p_rcpt_date);
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_expected_receipts: po_rcv_supply = '||po_rcv_supply);

  return (wip_supply + neg_wip_supply + flow_supply + rep_sch_supply + po_supply +
    intransit_ship_supply + req_supply + intransit_receipt_supply + po_rcv_supply);

END calc_expected_receipts;


/*
 * This procedure finds out the expected rcpt for each component in component temp table
 * for a given date and bumps up the projected available qty with rcpt qty
 */
PROCEDURE calc_expected_receipts(p_org_id NUMBER, p_rcpt_date DATE) IS
CURSOR comp IS
  select inventory_item_id
    from wip_ws_critical_comp_temp
   where organization_id = p_org_id
     and supply_subinventory is null;
   l_rcpt NUMBER;

BEGIN
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_expected_receipts:Entered');
  for c_comp in comp LOOP
    l_rcpt := calc_expected_receipts(p_org_id, c_comp.inventory_item_id, p_rcpt_date);
    if(nvl(l_rcpt, -1) < 0) then l_rcpt := 0; end if;
    update wip_ws_critical_comp_temp
    set PROJECTED_AVAIL_QTY = PROJECTED_AVAIL_QTY + l_rcpt
    where organization_id = p_org_id
      and inventory_item_id = c_comp.inventory_item_id
      and supply_subinventory is null;
  END LOOP;
END calc_expected_receipts;


/*
 * This procedure update the resource information in resource temp table
 */
PROCEDURE update_res_shift_avail(p_org_id NUMBER, p_dept_id NUMBER, p_resource_id NUMBER,
                           p_res_avail_date DATE, p_shift_num NUMBER,
                           p_onhand_qty NUMBER, p_proj_onhand NUMBER) IS
BEGIN
  update
    wip_ws_critical_res_temp
  set
    resource_avail_date = p_res_avail_date,
    resource_shift_num = p_shift_num,
    onhand_qty = p_onhand_qty,
    projected_avail_qty = p_proj_onhand
  where
    organization_id = p_org_id and
    department_id = p_dept_id and
    resource_id = p_resource_id;

END update_res_shift_avail;


/*
 * Loops over the critical job op components pl/sql table  and inserts each record into component
 * shortage table
 */
PROCEDURE insert_components IS
BEGIN
  wip_ws_util.log_time('insert_components: Inserting component shortage records');
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:insert_components:Entered: Number of records to insert='||g_wip_job_critical_comp_tbl.COUNT);
  --FOR i in 1..g_wip_job_critical_comp_tbl.COUNT LOOP
  IF(g_wip_job_critical_comp_tbl.COUNT > 0) THEN
    FOR i in g_wip_job_critical_comp_tbl.FIRST..g_wip_job_critical_comp_tbl.LAST LOOP
      wip_ws_util.trace_log('WIP_WS_SHORTAGE:insert_components:inv_item='||g_wip_job_critical_comp_tbl(i).INVENTORY_ITEM_ID||
      ',org_id='||g_wip_job_critical_comp_tbl(i).ORGANIZATION_ID||
      ',wip_entity_id='||g_wip_job_critical_comp_tbl(i).WIP_ENTITY_ID||
      ',operation_seq_num='||g_wip_job_critical_comp_tbl(i).OPERATION_SEQ_NUM);
      insert into wip_ws_comp_shortage(
        ORGANIZATION_ID,
        WIP_ENTITY_ID,
        OPERATION_SEQ_NUM,
        INVENTORY_ITEM_ID,
        DEPARTMENT_ID,
        PRIMARY_UOM_CODE,
        DATE_REQUIRED,
        REQUIRED_QTY,
        QUANTITY_ISSUED,
        QUANTITY_OPEN,
        WIP_SUPPLY_TYPE,
        SUPPLY_SUBINVENOTRY,
        SUPPLY_LOCATOR_ID,
        ONHAND_QTY,
        PROJ_AVAIL_QTY,
        SHORTAGE_QTY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        OBJECT_VERSION_NUMBER,
        PROGRAM_RUN_DATE
      )values(
        g_wip_job_critical_comp_tbl(i).ORGANIZATION_ID,
        g_wip_job_critical_comp_tbl(i).WIP_ENTITY_ID,
        g_wip_job_critical_comp_tbl(i).OPERATION_SEQ_NUM,
        g_wip_job_critical_comp_tbl(i).INVENTORY_ITEM_ID,
        g_wip_job_critical_comp_tbl(i).DEPARTMENT_ID,
        g_wip_job_critical_comp_tbl(i).PRIMARY_UOM_CODE,
        g_wip_job_critical_comp_tbl(i).DATE_REQUIRED,
        g_wip_job_critical_comp_tbl(i).REQUIRED_QTY,
        g_wip_job_critical_comp_tbl(i).QUANTITY_ISSUED,
        g_wip_job_critical_comp_tbl(i).QUANTITY_OPEN,
        g_wip_job_critical_comp_tbl(i).WIP_SUPPLY_TYPE,
        g_wip_job_critical_comp_tbl(i).SUPPLY_SUBINVENOTRY,
        g_wip_job_critical_comp_tbl(i).SUPPLY_LOCATOR_ID,
        g_wip_job_critical_comp_tbl(i).ONHAND_QTY,
        g_wip_job_critical_comp_tbl(i).PROJ_AVAIL_QTY,
        g_wip_job_critical_comp_tbl(i).SHORTAGE_QTY,
        sysdate,
        g_user_id,
        sysdate,
        g_user_id,
        g_login_id,
        g_request_id,
        g_prog_appid,
        g_prog_id,
        g_init_obj_ver,
        g_prog_run_date
      );
    END LOOP;
  END IF;
  wip_ws_util.log_time('insert_components: Done with inserting components');

END insert_components;


/*
 * Loops over the critical job op resources pl/sql table  and inserts each record into resource
 * shortage table
 */
PROCEDURE insert_resources IS
BEGIN
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:insert_resources:Entered: Number of records to insert='||g_wip_job_critical_res_tbl.COUNT);
  wip_ws_util.log_time('insert_resources: Inserting resource shortage records');
  --FOR i in 1..g_wip_job_critical_res_tbl.COUNT LOOP
  IF(g_wip_job_critical_res_tbl.COUNT > 0) THEN
    FOR i in g_wip_job_critical_res_tbl.FIRST..g_wip_job_critical_res_tbl.LAST LOOP
      wip_ws_util.trace_log('WIP_WS_SHORTAGE:insert_resources:resource'||g_wip_job_critical_res_tbl(i).RESOURCE_ID||
      ',org_id='||g_wip_job_critical_res_tbl(i).ORGANIZATION_ID||
      ',wip_entity_id='||g_wip_job_critical_res_tbl(i).WIP_ENTITY_ID||
      ',operation_seq_num='||g_wip_job_critical_res_tbl(i).OPERATION_SEQ_NUM);

      insert into wip_ws_res_shortage(
        ORGANIZATION_ID,
        WIP_ENTITY_ID,
        OPERATION_SEQ_NUM,
        RESOURCE_ID,
        DEPARTMENT_ID,
        DATE_REQUIRED,
        REQUIRED_QTY,
        QUANTITY_ISSUED,
        QUANTITY_OPEN,
        RESOURCE_AVAIL,
        RESOURCE_PROJ_AVAIL,
        RESOURCE_SHORTAGE,
        PRIMARY_UOM_CODE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        OBJECT_VERSION_NUMBER,
        PROGRAM_RUN_DATE
      )values(
        g_wip_job_critical_res_tbl(i).ORGANIZATION_ID,
        g_wip_job_critical_res_tbl(i).WIP_ENTITY_ID,
        g_wip_job_critical_res_tbl(i).OPERATION_SEQ_NUM,
        g_wip_job_critical_res_tbl(i).RESOURCE_ID,
        g_wip_job_critical_res_tbl(i).DEPARTMENT_ID,
        g_wip_job_critical_res_tbl(i).DATE_REQUIRED,
        g_wip_job_critical_res_tbl(i).REQUIRED_QTY,
        g_wip_job_critical_res_tbl(i).QUANTITY_ISSUED,
        g_wip_job_critical_res_tbl(i).QUANTITY_OPEN,
        g_wip_job_critical_res_tbl(i).RESOURCE_AVAIL,
        g_wip_job_critical_res_tbl(i).RESOURCE_PROJ_AVAIL,
        g_wip_job_critical_res_tbl(i).RESOURCE_SHORTAGE,
        g_wip_job_critical_res_tbl(i).PRIMARY_UOM_CODE,
        sysdate,
        g_user_id,
        sysdate,
        g_user_id,
        g_login_id,
        g_request_id,
        g_prog_appid,
        g_prog_id,
        g_init_obj_ver,
        g_prog_run_date
      );
    END LOOP;
  END IF;
  wip_ws_util.log_time('insert_resources: Done with resource insertion');
/*
  exception when others then
    null;
*/
END insert_resources;


/*
 * Delete all component records from comp shortage table for a given org
 */
PROCEDURE delete_components (p_org_id NUMBER) IS
BEGIN
  wip_ws_util.log_time('delete_components: Starting to delete org components');
  delete from wip_ws_comp_shortage
   where organization_id = p_org_id;
  wip_ws_util.log_time('delete_components: Done with deleting org components');
END delete_components;


/*
 * Delete all resource records from res shortage table for a given org
 */
PROCEDURE delete_resources(p_org_id NUMBER) IS
BEGIN
  wip_ws_util.log_time('delete_resources: Starting to delete org resources');
  delete from wip_ws_res_shortage
   where organization_id = p_org_id;
  wip_ws_util.log_time('delete_resources: Done with deleting org resources');
END delete_resources;


/*
 * This procedure is responsible for deleting the old records from comp and res shortage tables
 * and populate the newly calculted data present in pl/sql tables
 */
PROCEDURE write_db(p_org_id NUMBER) IS
BEGIN
  wip_ws_util.log_time('write_db: Entering write_db');
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:write_db:Entered');
  delete_components(p_org_id);
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:write_db:done with delete_components');
  insert_components;
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:write_db:done with insert_components');
  delete_resources(p_org_id);
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:write_db:done with delete_resources');
  insert_resources;

  wip_ws_util.trace_log('WIP_WS_SHORTAGE:write_db:Finished');
  wip_ws_util.log_time('write_db: Done with write_db');
END write_db;


/*
 * This is the main procedure for calculating resource shortage. It first find out the
 * critical resources. Then it loop over the job ops and find out the critical job op
 * resources. Then it loops over the critical job op resources and calcultes the availability
 * and shortage numbers for each job op resource
 */
PROCEDURE calc_res_shortage (p_org_id NUMBER) IS
i NUMBER;
l_item_project_avail_qty NUMBER;
current_res_req_date DATE;
current_res_shift_num NUMBER;
l_res_remain_qty NUMBER;
l_res_shortage NUMBER;
l_res_onhand_qty NUMBER;
l_res_avail_date DATE;
l_res_avail_shift NUMBER;
l_res_project_avail_qty NUMBER;

CURSOR critical_res_csr (p_org_id NUMBER, p_dept_id NUMBER, p_res_id NUMBER) IS
  select department_id,
         resource_id,
         onhand_qty,
         projected_avail_qty,
         resource_avail_date,
         resource_shift_num
    from wip_ws_critical_res_temp
   where organization_id = p_org_id
     and department_id = p_dept_id
     and resource_id = p_res_id;

BEGIN
  wip_ws_util.log_time('calc_res_shortage: Entering calc_res_shortage');
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_res_shortage:Entered');
  get_job_critical_resources(p_org_id, g_period_end_time);
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_res_shortage:Done with get_job_critical_resources ');

  IF(g_wip_job_critical_res_tbl.COUNT > 0) THEN
    FOR i in g_wip_job_critical_res_tbl.FIRST .. g_wip_job_critical_res_tbl.LAST LOOP
      current_res_req_date  := g_wip_job_critical_res_tbl(i).DATE_REQUIRED;
      current_res_shift_num := g_wip_job_critical_res_tbl(i).shift_num;
      --if this resource req is in past, make it work in current shift
      --shift num is already reflecting the current shift from get_job_critical_resources procedure
      if(current_res_req_date < sysdate) then
        current_res_req_date := sysdate;
      end if;

    wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_res_shortage:Point 20: Enter loop for: '||
    'wip_ent_id='||g_wip_job_critical_res_tbl(i).WIP_ENTITY_ID||
    ',op_seq_num='||g_wip_job_critical_res_tbl(i).OPERATION_SEQ_NUM||
    ',dept_id='||g_wip_job_critical_res_tbl(i).DEPARTMENT_ID||
    ',res_id='||g_wip_job_critical_res_tbl(i).RESOURCE_ID
    );
      for c_critical_res_csr in critical_res_csr(p_org_id,
        g_wip_job_critical_res_tbl(i).DEPARTMENT_ID,
        g_wip_job_critical_res_tbl(i).RESOURCE_ID) loop
        l_res_avail_date        := c_critical_res_csr.resource_avail_date;
        l_res_avail_shift       := c_critical_res_csr.resource_shift_num;
        l_res_project_avail_qty := c_critical_res_csr.projected_avail_qty;
        l_res_onhand_qty        := c_critical_res_csr.onhand_qty;

        wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_res_shortage:Point 30: Found resource in temp table: '||
        'l_res_avail_date='||l_res_avail_date||
        ',l_res_avail_shift='||l_res_avail_shift||
        ',l_res_project_avail_qty='||l_res_project_avail_qty||
        ',l_res_onhand_qty='||l_res_onhand_qty
        );

      end loop;

      --first time this row is accessed
      if((l_res_avail_date is NULL) OR (l_res_avail_shift is null)) then
        l_res_onhand_qty := wip_ws_dl_util.get_shift_capacity(
                              p_org_id,
                              g_wip_job_critical_res_tbl(i).DEPARTMENT_ID,
                              g_wip_job_critical_res_tbl(i).RESOURCE_ID,
                              g_wip_job_critical_res_tbl(i).SHIFT_SEQ,
                              g_wip_job_critical_res_tbl(i).SHIFT_NUM);

        wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_res_shortage:Point 40: resource accessed first time:'||
        'l_res_onhand_qty='||l_res_onhand_qty
        );
      end if;

      if(
         trunc(l_res_avail_date) = trunc(current_res_req_date) AND
         l_res_avail_shift = g_wip_job_critical_res_tbl(i).SHIFT_NUM) then
        --found a job resource working in the same day and shift as critical res record
         l_res_onhand_qty := l_res_project_avail_qty;

        wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_res_shortage:Point 50: resource working in same day and shift as critical res found'||
        'l_res_onhand_qty='||l_res_onhand_qty
        );

      else
        --found a job resource that is working on a different date or shift then critical record
        --in this case we need to refill the resource availability
        l_res_onhand_qty := wip_ws_dl_util.get_shift_capacity(
                              p_org_id,
                              g_wip_job_critical_res_tbl(i).DEPARTMENT_ID,
                              g_wip_job_critical_res_tbl(i).RESOURCE_ID,
                              g_wip_job_critical_res_tbl(i).SHIFT_SEQ,
                              g_wip_job_critical_res_tbl(i).SHIFT_NUM);

        wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_res_shortage:Point 60: resource working in difference day or shift as critical res found'||
        'l_res_onhand_qty='||l_res_onhand_qty
        );

      end if;

      if(l_res_onhand_qty >= g_wip_job_critical_res_tbl(i).QUANTITY_OPEN) then
        l_res_shortage := 0;
      else
        l_res_shortage := g_wip_job_critical_res_tbl(i).QUANTITY_OPEN - l_res_onhand_qty;
      end if;
      l_res_remain_qty := l_res_onhand_qty - g_wip_job_critical_res_tbl(i).QUANTITY_OPEN;

        wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_res_shortage:Point 70:'||
        ',l_res_onhand_qty='||l_res_onhand_qty||
        ',l_res_shortage='||l_res_shortage||
        ',l_res_remain_qty='||l_res_remain_qty
        );

      if(l_res_remain_qty < 0) then l_res_remain_qty := 0; end if;

      --update job resource record with availability/shortage info
      g_wip_job_critical_res_tbl(i).RESOURCE_AVAIL      := l_res_onhand_qty;
      --g_wip_job_critical_res_tbl(i).RESOURCE_PROJ_AVAIL := l_res_remain_qty;
      g_wip_job_critical_res_tbl(i).RESOURCE_PROJ_AVAIL := l_res_onhand_qty;
      g_wip_job_critical_res_tbl(i).RESOURCE_SHORTAGE   := l_res_shortage;

     wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_res_shortage:Point 80:Calling update in temp table');

      --update critical resource record with availability info
      update_res_shift_avail(p_org_id, g_wip_job_critical_res_tbl(i).DEPARTMENT_ID,
                             g_wip_job_critical_res_tbl(i).RESOURCE_ID, trunc(current_res_req_date),
                             g_wip_job_critical_res_tbl(i).SHIFT_NUM, l_res_onhand_qty, l_res_remain_qty);

     wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_res_shortage:Point 90:Done update in temp table');
    END LOOP;
  END IF;
END calc_res_shortage;


/*
 * This is the main procedure for calculating component shortage. It first find out the
 * critical components. Then it calls the procedure to find out job ops that are within this
 * date range and based on job status preferences. Then it loop over the job ops and find out
 * the critical job op components. Then it loops over the critical job op components and calculates
 * the availability and shortage numbers for each job op component
 */
PROCEDURE calc_comp_shortage (p_org_id NUMBER) IS
previous_jobop_comp_start_time DATE;
current_jobop_comp_start_time DATE;
l_inv_item_id NUMBER;
l_supply_subinv VARCHAR2(10);
l_item_onhand_qty NUMBER;
l_item_project_avail_qty NUMBER;
i NUMBER;


CURSOR critical_comp_csr IS
  select rowid,
         organization_id,
         inventory_item_id,
         supply_subinventory,
         nvl(onhand_qty,0) onhand_qty,
         nvl(projected_avail_qty,0) projected_avail_qty
    from wip_ws_critical_comp_temp
   where organization_id = p_org_id
     and inventory_item_id = l_inv_item_id
     and nvl(supply_subinventory, 'NULL') = nvl(l_supply_subinv, 'NULL');

BEGIN
  --this is the main procedure responsible for calculating component shortages
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_comp_shortage:Entered');

  get_pref_critical_components (p_org_id, g_period_end_time);
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_comp_shortage:Returned from get_pref_critical_components');
  get_job_ops(p_org_id, g_period_end_time);
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_comp_shortage:Returned from get_job_ops');
  get_job_critical_components(p_org_id, g_period_end_time);
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_comp_shortage:Returned from get_job_critical_components');

  previous_jobop_comp_start_time := null;
  current_jobop_comp_start_time := null;
  IF(g_wip_job_critical_comp_tbl.COUNT > 0) THEN
    FOR i in g_wip_job_critical_comp_tbl.FIRST .. g_wip_job_critical_comp_tbl.LAST LOOP
      wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_comp_shortage:job_critical_comp_loop point1, inv_item_id='||
      g_wip_job_critical_comp_tbl(i).INVENTORY_ITEM_ID||
      ',date_req='||g_wip_job_critical_comp_tbl(i).DATE_REQUIRED||
      ',subinv='||g_wip_job_critical_comp_tbl(i).SUPPLY_SUBINVENOTRY||
      ',quantity_open='||g_wip_job_critical_comp_tbl(i).QUANTITY_OPEN);

      current_jobop_comp_start_time := g_wip_job_critical_comp_tbl(i).DATE_REQUIRED;
      if(g_org_comp_calc_rec.inc_expected_rcpts = 1) then
          wip_ws_util.trace_log('WIP_WS_SHORTAGE:ks_debug, inc exp receipt=1');
          wip_ws_util.trace_log('WIP_WS_SHORTAGE:ks_debug, previous_jobop_comp_start_date='||to_char(previous_jobop_comp_start_time, 'DD-MON-YYYY HH24:MI:SS'));
          wip_ws_util.trace_log('WIP_WS_SHORTAGE:ks_debug, previous_jobop_comp_start_time='||get_time_in_secs(previous_jobop_comp_start_time));
          wip_ws_util.trace_log('WIP_WS_SHORTAGE:ks_debug, current_jobop_comp_start_date='||to_char(current_jobop_comp_start_time, 'DD-MON-YYYY HH24:MI:SS'));
          wip_ws_util.trace_log('WIP_WS_SHORTAGE:ks_debug, current_jobop_comp_start_time='||get_time_in_secs(current_jobop_comp_start_time));
          wip_ws_util.trace_log('WIP_WS_SHORTAGE:ks_debug, supply_cutoff_time='||g_org_comp_calc_rec.supply_cutoff_time_in_sec);

        --previous job op and current job op are on same day
        if(trunc(previous_jobop_comp_start_time) = trunc(current_jobop_comp_start_time)) then
          if(get_time_in_secs(previous_jobop_comp_start_time) < g_org_comp_calc_rec.supply_cutoff_time_in_sec AND
             get_time_in_secs(current_jobop_comp_start_time) >= g_org_comp_calc_rec.supply_cutoff_time_in_sec) then
         wip_ws_util.trace_log('WIP_WS_SHORTAGE:ks_debug, include expected receipt code called for same day');
             calc_expected_receipts(p_org_id, trunc(current_jobop_comp_start_time));
          end if;
        end if;

        --no previous job op and current job start time is past rcpt time, should happen for first jobop in list only
        if(previous_jobop_comp_start_time is null) then
          if (get_time_in_secs(current_jobop_comp_start_time) >= g_org_comp_calc_rec.supply_cutoff_time_in_sec) then
            wip_ws_util.trace_log('WIP_WS_SHORTAGE:ks_debug, include expected receipt code called for prev day = null');
            calc_expected_receipts(p_org_id, trunc(current_jobop_comp_start_time));
          end if;
        end if;

        --previous job op was on previous day and current job op is current day, this would be executed for first job of day only
        if (trunc(previous_jobop_comp_start_time) < trunc(current_jobop_comp_start_time)) then
          if (get_time_in_secs(current_jobop_comp_start_time) >= g_org_comp_calc_rec.supply_cutoff_time_in_sec) then
            wip_ws_util.trace_log('WIP_WS_SHORTAGE:ks_debug, include expected receipt code called for first job of day');
      calc_expected_receipts(p_org_id, trunc(current_jobop_comp_start_time));
    end if;
        end if;

      end if;
      l_inv_item_id := g_wip_job_critical_comp_tbl(i).INVENTORY_ITEM_ID;
      l_supply_subinv := g_wip_job_critical_comp_tbl(i).SUPPLY_SUBINVENOTRY;

      wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_comp_shortage:opening critical comp avail csr');
      for c_critical_comp_csr in critical_comp_csr loop
        l_item_project_avail_qty := c_critical_comp_csr.projected_avail_qty;
        l_item_onhand_qty        := c_critical_comp_csr.onhand_qty;
        wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_comp_shortage:projected_avail='||l_item_project_avail_qty||', onhand='||l_item_onhand_qty||', rowid='||c_critical_comp_csr.rowid);
      end loop;

      if(l_item_project_avail_qty < 0) then l_item_project_avail_qty := 0; end if;
      g_wip_job_critical_comp_tbl(i).ONHAND_QTY := l_item_onhand_qty;
      g_wip_job_critical_comp_tbl(i).PROJ_AVAIL_QTY := l_item_project_avail_qty;
      if(g_wip_job_critical_comp_tbl(i).PROJ_AVAIL_QTY < 0 ) then
        g_wip_job_critical_comp_tbl(i).SHORTAGE_QTY := g_wip_job_critical_comp_tbl(i).QUANTITY_OPEN;
      elsif(g_wip_job_critical_comp_tbl(i).PROJ_AVAIL_QTY >= g_wip_job_critical_comp_tbl(i).QUANTITY_OPEN) then
        g_wip_job_critical_comp_tbl(i).SHORTAGE_QTY := 0;
      elsif(g_wip_job_critical_comp_tbl(i).PROJ_AVAIL_QTY < g_wip_job_critical_comp_tbl(i).QUANTITY_OPEN) then
        g_wip_job_critical_comp_tbl(i).SHORTAGE_QTY := g_wip_job_critical_comp_tbl(i).QUANTITY_OPEN - g_wip_job_critical_comp_tbl(i).PROJ_AVAIL_QTY;
      end if;

      if(l_item_project_avail_qty < 0) then
        l_item_project_avail_qty := 0;
      else
        l_item_project_avail_qty := l_item_project_avail_qty - g_wip_job_critical_comp_tbl(i).QUANTITY_OPEN;
        if(l_item_project_avail_qty < 0 ) then
          l_item_project_avail_qty := 0;
        end if;
      end if;
      wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_comp_shortage: after consumption projected_avail='||l_item_project_avail_qty||', onhand='||l_item_onhand_qty);

      update wip_ws_critical_comp_temp
      set projected_avail_qty = l_item_project_avail_qty
      where organization_id = p_org_id
      and inventory_item_id = l_inv_item_id
      and nvl(supply_subinventory, 'NULL') = nvl(l_supply_subinv, 'NULL');

      previous_jobop_comp_start_time := current_jobop_comp_start_time;
    END LOOP;
  END IF;
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_comp_shortage:Point 100, total critical comp to be inserted='||g_wip_job_critical_comp_tbl.COUNT);

END calc_comp_shortage;


/*
 * This is the main procedure that contains the concurrent program for component and resource
 * shortage. Calculation is done for a particular org.
 * calculation type is always 1, which mean both component and resource calculation
 */
PROCEDURE calc_shortage (
          errbuf      OUT NOCOPY VARCHAR2,
          retcode     OUT NOCOPY NUMBER,
          p_org_id    IN NUMBER,
          p_calc_type IN NUMBER DEFAULT 1) IS

  l_return_status VARCHAR2(1);
  l_returnStatus VARCHAR2(1);
  l_params wip_logger.param_tbl_t;
  l_msg_data VARCHAR2(1000);
  l_msg_count NUMBER;
  l_lock_status NUMBER;
  x_return_status NUMBER;
  l_pref_exists    varchar2(1);

  l_concurrent_count NUMBER;
  l_conc_status boolean;

BEGIN
  retcode := 0;

  wip_ws_util.trace_log('WIPWSSHB:calc_shortage: setting up savepoint WIP_SHORT_CALC_START');
  SAVEPOINT WIP_SHORT_CALC_START;
  wip_ws_util.trace_log('WIPWSSHB:calc_shortage: savepoint WIP_SHORT_CALC_START successful');

  if (g_logLevel <= wip_constants.trace_logging) then
    l_params(1).paramName := 'p_org_id';
    l_params(1).paramValue := p_org_id;
    wip_logger.entryPoint(p_procName => 'WIP_WS_SHORTAGE.calc_shortage',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
    if(l_returnStatus <> fnd_api.g_ret_sts_success) then
      raise fnd_api.g_exc_unexpected_error;
    end if;
  end if;

    l_concurrent_count := wip_ws_util.get_no_of_running_concurrent(
    p_program_application_id => fnd_global.prog_appl_id,
    p_concurrent_program_id  => fnd_global.conc_program_id,
    p_org_id                 => p_org_id);

    if l_concurrent_count > 1 then
        wip_ws_util.log_for_duplicate_concurrent (
            p_org_id       => p_org_id,
            p_program_name => 'Component Shortage');
        l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', 'Errors encountered in calculation program, please check the log file.');
        return;
    end if;

  wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_shortage:calling get_org_comp_calc_param');
  get_org_comp_calc_param(p_org_id, l_pref_exists);
  wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_shortage: returned from get_org_comp_calc_param with '||l_pref_exists);
  if(l_pref_exists = 'N') then
    wip_ws_util.trace_log('WIP_WS_SHORTAGE:calc_shortage:No Preference exists for this organization');
    fnd_message.set_name('WIP','WIP_WS_SHORTAGE_NOPREF');
    raise FND_API.G_EXC_ERROR;
  end if;

  wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:calc_shortage: calling get_period_end_time' );
  g_period_end_time := get_period_end_time(p_org_id);
  wip_ws_util.trace_log( 'WIP_WS_SHORTAGE:calc_shortage:g_period_end_time='||to_char(g_period_end_time));


  wip_ws_util.log_time('WIPWSSHB:calc_shortage:Calling calc_comp_shortage');
  wip_ws_util.trace_log('WIPWSSHB:calc_shortage:Calling calc_comp_shortage');
  calc_comp_shortage (p_org_id);
  wip_ws_util.log_time('WIPWSSHB:calc_shortage:Done with calc_comp_shortage');
  wip_ws_util.trace_log('WWIPWSSHB:calc_shortage:Done with calc_comp_shortage');

  wip_ws_util.log_time('WIPWSSHB:calc_shortage:Calling calc_res_shortage');
  wip_ws_util.trace_log('WIPWSSHB:calc_shortage:Calling calc_res_shortage');
  calc_res_shortage (p_org_id);
  wip_ws_util.log_time('WIPWSSHB:calc_shortage:Done with calc_res_shortage');
  wip_ws_util.trace_log('WIPWSSHB:calc_shortage:Done with calc_res_shortage');

  wip_ws_util.log_time('WIPWSSHB:calc_shortage:Calling write_db');
  wip_ws_util.trace_log('WIPWSSHB:calc_shortage:Calling write_db');
  write_db (p_org_id);
  wip_ws_util.log_time('WIPWSSHB:calc_shortage:Done with write_db');
  wip_ws_util.trace_log('WIPWSSHB:calc_shortage:Done with write_db');
  commit;
  wip_ws_util.log_time('WIPWSSHB:calc_shortage:Done with db commit');
  wip_ws_util.trace_log('WIPWSSHB:calc_shortage:Done with db commit');

  if (g_logLevel <= wip_constants.trace_logging) then
    wip_logger.exitPoint(p_procName => 'WIP_WS_SHORTAGE.calc_shortage',
                         p_procReturnStatus => retcode,
                         p_msg => 'Request processed successfully!',
                         x_returnStatus => l_returnStatus);
  end if;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      wip_ws_util.trace_log('WIPWSSHB:calc_shortage: Exception: Unexpected error');
      ROLLBACK TO WIP_SHORT_CALC_START;
      retcode := 2;  -- End with error
      fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
      fnd_message.set_token('ERROR_TEXT', 'wip_ws_shortage.calc_shortage: ' || SQLERRM);
      errbuf := fnd_message.get;
      if (g_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'WIP_WS_SHORTAGE.calc_shortage',
                             p_procReturnStatus => retcode,
                             p_msg => 'unexpected error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus);
      end if;

    WHEN FND_API.G_EXC_ERROR THEN
      retcode := 1;
      wip_ws_util.trace_log('WIPWSSHB:calc_shortage: Exception: Expected Error');
      ROLLBACK TO WIP_SHORT_CALC_START;
      --bug 6756693 Get the message and write it
      errbuf := fnd_message.get;
      fnd_file.put_line(fnd_file.log, errbuf);
      --end bug 6756693
      if (g_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'WIP_WS_SHORTAGE.calc_shortage',
                             p_procReturnStatus => retcode,
                             p_msg => 'expected error: ' || errbuf,
                             x_returnStatus => l_returnStatus);
      end if;

    WHEN OTHERS THEN
      wip_ws_util.trace_log('WIPWSSHB:calc_shortage: Others Exception: '|| SQLERRM);
      ROLLBACK TO WIP_SHORT_CALC_START;
      retcode := 2; --End with error
      if (g_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'WIP_WS_SHORTAGE.calc_shortage',
                             p_procReturnStatus => retcode,
                             p_msg => 'error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus);
      end if;
      fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
      fnd_message.set_token('ERROR_TEXT', 'wip_ws_shortage.calc_shortage: ' || SQLERRM);
      errbuf := fnd_message.get;

END calc_shortage;



END WIP_WS_SHORTAGE;

/
