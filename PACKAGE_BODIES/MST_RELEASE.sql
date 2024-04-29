--------------------------------------------------------
--  DDL for Package Body MST_RELEASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MST_RELEASE" AS
/* $Header: MSTRELPB.pls 115.37 2004/05/13 09:27:40 atsrivas noship $ */

  type varchar2_tab_type is table of varchar2(100) index by binary_integer;
  g_release_type                number; -- being used in MSTEXCEP.pld
  g_tp_release_code             varchar2(30);

  g_cnt_group_released          pls_integer;
  g_cnt_group_failed            pls_integer;
  g_cnt_group_not_attempted     pls_integer;
  g_cnt_trip_released           pls_integer;
  g_cnt_trip_failed             pls_integer;
  g_cnt_trip_not_attempted      pls_integer;
  g_cnt_truck_released          pls_integer;
  g_cnt_truck_failed            pls_integer;
  g_cnt_truck_not_attempted     pls_integer;
  g_cnt_ltl_released            pls_integer;
  g_cnt_ltl_failed              pls_integer;
  g_cnt_ltl_not_attempted       pls_integer;
  g_cnt_parcel_released         pls_integer;
  g_cnt_parcel_failed           pls_integer;
  g_cnt_parcel_not_attempted    pls_integer;
  g_cnt_cm_released             pls_integer;
  g_cnt_cm_failed               pls_integer;
  g_cnt_cm_selected             pls_integer;
  g_cnt_deadhead_released       pls_integer;
  g_cnt_deadhead_failed         pls_integer;
  g_cnt_deadhead_not_attempted  pls_integer;
  g_cnt_etrip_not_attempted     pls_integer;

  g_release_debug_flag_set      boolean;
  g_log_must_message            pls_integer;
  g_house_keeping               pls_integer;
  g_apply_to_te                 pls_integer;
  g_purge_interface_table       pls_integer;
  g_update_tp_tables            pls_integer;
  g_log_flow_of_control         pls_integer;
  g_log_failed_data             pls_integer;
  g_log_released_data           pls_integer;
  g_purge_mst_release_temp      pls_integer;
  g_log_statistics              pls_integer;
  g_log_ruleset_where_clause    pls_integer;
  g_truncate_mrt                pls_integer;
  g_delete_record_count         pls_integer;
  g_delete_record_count_loop    pls_integer;

  g_where_clause                varchar2(4000); -- where clause is stored for auto release with rule set
  g_auto_release                pls_integer; -- used only in release with rule set
  g_release_data                varchar2(4);

  g_str_truck_tl                varchar2(80);
  g_str_ltl_tl                  varchar2(80);
  g_str_parcel_tl               varchar2(80);

  function get_cond(p_condition varchar2) return varchar2;
  procedure print_info(p_release_debug_control in number, p_info_str in varchar2);

  procedure initialize_package_variables is
    cursor cur_mode_of_transport (l_mode_of_transport in varchar2)
    is
    select meaning
    from wsh_lookups
    where lookup_type = 'WSH_MODE_OF_TRANSPORT'
    and lookup_code = l_mode_of_transport;

    l_mode_of_transport varchar2(30);
  begin
    --g_release_type
    g_tp_release_code           := wsh_tp_release_grp.G_TP_RELEASE_CODE;

    g_cnt_group_released         := 0;
    g_cnt_group_failed           := 0;
    g_cnt_group_not_attempted    := 0;
    g_cnt_trip_released          := 0;
    g_cnt_trip_failed            := 0;
    g_cnt_trip_not_attempted     := 0;
    g_cnt_truck_released         := 0;
    g_cnt_truck_failed           := 0;
    g_cnt_truck_not_attempted    := 0;
    g_cnt_ltl_released           := 0;
    g_cnt_ltl_failed             := 0;
    g_cnt_ltl_not_attempted      := 0;
    g_cnt_parcel_released        := 0;
    g_cnt_parcel_failed          := 0;
    g_cnt_parcel_not_attempted   := 0;
    g_cnt_cm_released            := 0;
    g_cnt_cm_failed              := 0;
    g_cnt_cm_selected            := 0;
    g_cnt_deadhead_released      := 0;
    g_cnt_deadhead_failed        := 0;
    g_cnt_deadhead_not_attempted := 0;
    g_cnt_etrip_not_attempted    := 0;

    g_release_debug_flag_set     := FALSE;
    g_log_must_message           := 1;
    g_house_keeping              := 0;
    g_apply_to_te                := 1;
    g_purge_interface_table      := 1;
    g_update_tp_tables           := 1;
    g_log_flow_of_control        := 0;
    g_log_failed_data            := 1;
    g_log_released_data          := 0;
    g_purge_mst_release_temp     := 1;
    g_log_statistics             := 1;
    g_log_ruleset_where_clause   := 0;
    g_truncate_mrt               := 1;
    g_delete_record_count        := 1;
    g_delete_record_count_loop   := 1;

    g_where_clause               := null; -- where clause is stored for auto release with rule set
    g_auto_release               := null; -- used only in release with rule set
    g_release_data               := 'TRIP';

    open cur_mode_of_transport ('TRUCK');
    fetch cur_mode_of_transport into g_str_truck_tl;
    close cur_mode_of_transport;

    open cur_mode_of_transport ('LTL');
    fetch cur_mode_of_transport into g_str_ltl_tl;
    close cur_mode_of_transport;

    open cur_mode_of_transport ('PARCEL');
    fetch cur_mode_of_transport into g_str_parcel_tl;
    close cur_mode_of_transport;
  end initialize_package_variables;

  procedure set_concurrent_status(p_status in varchar2, p_message in varchar2) is
    l_flag boolean := false;
  begin
    l_flag := fnd_concurrent.set_completion_status(p_status, p_message);
  end set_concurrent_status;

  function get_seeded_message(p_seeded_string in varchar2)
  return varchar2 is
    l_Message_Text varchar2(1000);
  begin
    fnd_message.set_name('MST',p_seeded_string);
    l_Message_Text := fnd_message.get;
    return l_Message_Text;
  exception
    when others then
      return null;
  end get_seeded_message;

  procedure log_statistics is
    l_Message_Text varchar2(1000);
  begin
    if g_log_statistics = 1 then

      print_info(g_log_must_message,'*****************************************************************************************************************');
      fnd_message.set_name('MST','MST_REL_BK_MESSAGE_1');
      fnd_message.set_token('N1',to_char(g_cnt_group_released+g_cnt_group_failed+g_cnt_group_not_attempted));
      fnd_message.set_token('N2',to_char(g_cnt_group_released+g_cnt_group_failed));
      fnd_message.set_token('N3',to_char(g_cnt_group_released));
      fnd_message.set_token('N4',to_char(g_cnt_group_failed));
      fnd_message.set_token('N5',to_char(g_cnt_group_not_attempted));
      l_Message_Text := fnd_message.get;
      print_info(g_log_must_message,l_Message_Text);

      fnd_message.set_name('MST','MST_REL_BK_MESSAGE_2');
      fnd_message.set_token('N1',to_char(g_cnt_trip_released+g_cnt_trip_failed+g_cnt_trip_not_attempted));
      fnd_message.set_token('N2',to_char(g_cnt_trip_released+g_cnt_trip_failed));
      fnd_message.set_token('N3',to_char(g_cnt_trip_released));
      fnd_message.set_token('N4',to_char(g_cnt_trip_failed));
      fnd_message.set_token('N5',to_char(g_cnt_trip_not_attempted));
      l_Message_Text := fnd_message.get;
      print_info(g_log_must_message,l_Message_Text);

      fnd_message.set_name('MST','MST_REL_BK_MESSAGE_50');
      fnd_message.set_token('MODEOFTRANSPORT',g_str_truck_tl||'    ');
      fnd_message.set_token('N1',to_char(g_cnt_truck_released+g_cnt_truck_failed+g_cnt_truck_not_attempted));
      fnd_message.set_token('N2',to_char(g_cnt_truck_released+g_cnt_truck_failed));
      fnd_message.set_token('N3',to_char(g_cnt_truck_released));
      fnd_message.set_token('N4',to_char(g_cnt_truck_failed));
      fnd_message.set_token('N5',to_char(g_cnt_truck_not_attempted));
      l_Message_Text := fnd_message.get;
      print_info(g_log_must_message,l_Message_Text);

      fnd_message.set_name('MST','MST_REL_BK_MESSAGE_50');
      fnd_message.set_token('MODEOFTRANSPORT',g_str_ltl_tl||'   ');
      fnd_message.set_token('N1',to_char(g_cnt_ltl_released+g_cnt_ltl_failed+g_cnt_ltl_not_attempted));
      fnd_message.set_token('N2',to_char(g_cnt_ltl_released+g_cnt_ltl_failed));
      fnd_message.set_token('N3',to_char(g_cnt_ltl_released));
      fnd_message.set_token('N4',to_char(g_cnt_ltl_failed));
      fnd_message.set_token('N5',to_char(g_cnt_ltl_not_attempted));
      l_Message_Text := fnd_message.get;
      print_info(g_log_must_message,l_Message_Text);

      fnd_message.set_name('MST','MST_REL_BK_MESSAGE_50');
      fnd_message.set_token('MODEOFTRANSPORT',g_str_parcel_tl);
      fnd_message.set_token('N1',to_char(g_cnt_parcel_released+g_cnt_parcel_failed+g_cnt_parcel_not_attempted));
      fnd_message.set_token('N2',to_char(g_cnt_parcel_released+g_cnt_parcel_failed));
      fnd_message.set_token('N3',to_char(g_cnt_parcel_released));
      fnd_message.set_token('N4',to_char(g_cnt_parcel_failed));
      fnd_message.set_token('N5',to_char(g_cnt_parcel_not_attempted));
      l_Message_Text := fnd_message.get;
      print_info(g_log_must_message,l_Message_Text);

      fnd_message.set_name('MST','MST_REL_BK_MESSAGE_3');
      fnd_message.set_token('N1',to_char(g_cnt_cm_selected));
      fnd_message.set_token('N2',to_char(g_cnt_cm_released+g_cnt_cm_failed));
      fnd_message.set_token('N3',to_char(g_cnt_cm_released));
      fnd_message.set_token('N4',to_char(g_cnt_cm_failed));
      fnd_message.set_token('N5',to_char(g_cnt_cm_selected-g_cnt_cm_released-g_cnt_cm_failed));
      l_Message_Text := fnd_message.get;
      print_info(g_log_must_message,l_Message_Text);

      fnd_message.set_name('MST','MST_REL_BK_MESSAGE_49');
      fnd_message.set_token('N1',to_char(g_cnt_deadhead_released+g_cnt_deadhead_failed+g_cnt_deadhead_not_attempted));
      fnd_message.set_token('N2',to_char(g_cnt_deadhead_released+g_cnt_deadhead_failed));
      fnd_message.set_token('N3',to_char(g_cnt_deadhead_released));
      fnd_message.set_token('N4',to_char(g_cnt_deadhead_failed));
      fnd_message.set_token('N5',to_char(g_cnt_deadhead_not_attempted));
      l_Message_Text := fnd_message.get;
      print_info(g_log_must_message,l_Message_Text);
      print_info(g_log_must_message,'*****************************************************************************************************************');
    end if;
    --print_info(g_log_must_message,'Note :');
    print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_4'));
    if g_house_keeping = 1 then
      --print_info(g_log_must_message,' + House keeping done');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_5'));
    else
      --print_info(g_log_must_message,' - House keeping NOT done');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_6'));
    end if;
    if g_apply_to_te = 1 then
      --print_info(g_log_must_message,' + TP data applied to TE');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_7'));
    else
      --print_info(g_log_must_message,' - TP data NOT applied to TE');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_8'));
    end if;
    if g_purge_interface_table = 1 then
      --print_info(g_log_must_message,' + Interface table purged');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_9'));
    else
      --print_info(g_log_must_message,' - Interface table NOT purged');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_10'));
    end if;
    if g_update_tp_tables = 1 then
      --print_info(g_log_must_message,' + TP tables updated');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_11'));
    else
      --print_info(g_log_must_message,' - TP tables NOT updated');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_12'));
    end if;
    if g_log_flow_of_control = 1 then
      --print_info(g_log_must_message,' + Flow of control info logged');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_13'));
    else
      --print_info(g_log_must_message,' - Flow of control info NOT logged');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_14'));
    end if;
    if g_log_must_message = 1 then
      --print_info(g_log_must_message,' + Mendatory messages logged');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_15'));
    else
      --print_info(g_log_must_message,' - Mendatory messages NOT logged');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_16'));
    end if;
    if g_log_failed_data = 1 then
      --print_info(g_log_must_message,' + Failed release data logged');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_17'));
    else
      --print_info(g_log_must_message,' - Failed release data NOT logged');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_18'));
    end if;
    if g_log_released_data = 1 then
      --print_info(g_log_must_message,' + Successful release data logged');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_19'));
    else
      --print_info(g_log_must_message,' - Successful release data NOT logged');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_20'));
    end if;
    if g_purge_mst_release_temp = 1 then
      --print_info(g_log_must_message,' + TP release temporary table purged');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_21'));
    else
      --print_info(g_log_must_message,' - TP release temporary table NOT purged');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_22'));
    end if;
    if g_log_statistics = 1 then
      --print_info(g_log_must_message,' + Release statistics logged');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_23'));
    else
      --print_info(g_log_must_message,' - Release statistics NOT logged');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_24'));
    end if;
    if g_cnt_group_failed > 0 then
      if g_cnt_trip_not_attempted < 1 then
        --set_concurrent_status('WARNING', g_cnt_group_failed ||' Groups failed. '|| g_cnt_trip_failed ||' Trips failed. All Trips attempted.');
        fnd_message.set_name('MST','MST_REL_BK_MESSAGE_25');
        fnd_message.set_token('N1',to_char(g_cnt_group_failed));
        fnd_message.set_token('N2',to_char(g_cnt_trip_failed));
        l_Message_Text := fnd_message.get;
        set_concurrent_status('WARNING', l_Message_Text);
      else
        --set_concurrent_status('WARNING', g_cnt_group_failed ||' Groups failed. '|| g_cnt_trip_failed ||' Trips failed. '||g_cnt_trip_not_attempted||' Trips not attempted to release.');
        fnd_message.set_name('MST','MST_REL_BK_MESSAGE_26');
        fnd_message.set_token('N1',to_char(g_cnt_group_failed));
        fnd_message.set_token('N2',to_char(g_cnt_trip_failed));
        fnd_message.set_token('N3',to_char(g_cnt_trip_not_attempted));
        l_Message_Text := fnd_message.get;
        set_concurrent_status('WARNING', l_Message_Text);
      end if;
    elsif g_cnt_trip_not_attempted > 0 then
      --set_concurrent_status('WARNING', g_cnt_group_released ||' Groups released. '|| g_cnt_trip_released ||' Trips released. '||g_cnt_trip_not_attempted||' Trips not attempted to release.' );
      fnd_message.set_name('MST','MST_REL_BK_MESSAGE_27');
      fnd_message.set_token('N1',to_char(g_cnt_group_released));
      fnd_message.set_token('N2',to_char(g_cnt_trip_released));
      fnd_message.set_token('N3',to_char(g_cnt_trip_not_attempted));
      l_Message_Text := fnd_message.get;
      set_concurrent_status('WARNING', l_Message_Text);
    else
      --set_concurrent_status('NORMAL', g_cnt_group_released ||' Groups released. '|| g_cnt_trip_released ||' Trips released.');
      fnd_message.set_name('MST','MST_REL_BK_MESSAGE_28');
      fnd_message.set_token('N1',to_char(g_cnt_group_released));
      fnd_message.set_token('N2',to_char(g_cnt_trip_released));
      l_Message_Text := fnd_message.get;
      set_concurrent_status('NORMAL', l_Message_Text);
    end if;
  end log_statistics;

  procedure set_release_debug_flags is
    l_profile_mst_release_debug varchar2(100);
  begin
    if not g_release_debug_flag_set then
      l_profile_mst_release_debug := nvl(fnd_profile.value('MST_RELEASE_DEBUG'),'0111010110');
      g_house_keeping             := substr(l_profile_mst_release_debug,1,1);
      g_apply_to_te               := substr(l_profile_mst_release_debug,2,1);
      g_purge_interface_table     := substr(l_profile_mst_release_debug,3,1);
      g_update_tp_tables          := substr(l_profile_mst_release_debug,4,1);
      g_log_flow_of_control       := substr(l_profile_mst_release_debug,5,1);
      g_log_failed_data           := substr(l_profile_mst_release_debug,6,1);
      g_log_released_data         := substr(l_profile_mst_release_debug,7,1);
      g_purge_mst_release_temp    := substr(l_profile_mst_release_debug,8,1);
      g_log_statistics            := substr(l_profile_mst_release_debug,9,1);
      g_log_ruleset_where_clause  := substr(l_profile_mst_release_debug,10,1);
      g_truncate_mrt              := substr(l_profile_mst_release_debug,11,1);
      g_delete_record_count_loop  := substr(l_profile_mst_release_debug,12,1);
      g_delete_record_count       := substr(l_profile_mst_release_debug,13);
      g_release_debug_flag_set    := TRUE;
    end if;
  exception
    when others then
      null;
  end set_release_debug_flags;

  procedure log_group_trip_data (p_log_data in pls_integer
                               , p_group_id in pls_integer
                               , p_status   in varchar2) is

    cursor cur_trip_info (l_group_id in pls_integer)
    is
    select substr('   '||tp_plan_name||' '||tp_trip_number||' '||decode(mode_of_transport,'TRUCK',g_str_truck_tl,'LTL',g_str_ltl_tl,'PARCEL',g_str_parcel_tl,mode_of_transport),1,100)
    from wsh_trips_interface
    where interface_action_code = g_tp_release_code
    and group_id = l_group_id
    order by tp_trip_number;

    type varchar2_tab_type is table of varchar2(100) index by binary_integer;

    l_trip_info_tab varchar2_tab_type;
    l_Message_Text varchar2(1000);
  begin
    if p_log_data = 1 then
      --print_info(p_log_data,'  Trips in this group are :');

      open cur_trip_info (p_group_id);
      fetch cur_trip_info bulk collect into l_trip_info_tab;
      close cur_trip_info;

      if nvl(l_trip_info_tab.last,0) > 0 then
        fnd_message.set_name('MST','MST_REL_BK_MESSAGE_29');
        fnd_message.set_token('N1',to_char(l_trip_info_tab.last));
        l_Message_Text := fnd_message.get;
        print_info(g_log_must_message,l_Message_Text);
        for i in 1..l_trip_info_tab.last loop
          print_info(p_log_data,l_trip_info_tab(i)||' '||p_status);
        end loop;
      end if;

    end if;
  end log_group_trip_data;

  procedure insert_trips (p_plan_id    in number
                        , p_release_id in number
                        , p_load_tab   in number_tab_type
                        , p_load_type  in varchar2) is
  begin
    print_info(g_log_flow_of_control,'insert_trips : Program started');
    if nvl(p_load_tab.last,0) > 0 then
      if p_load_type = 'CM' then
        forall i in 1..p_load_tab.last
        insert into mst_release_temp
        (
         release_id
        , group_id
        , plan_id
        , trip_id
        , sr_trip_id
        , trip_number
        , planned_flag
        , release_status
        , trip_start_date
        , cm_id_of_trip
        , continuous_move_sequence
        , out_of_scope
        , trip_process_flag
        , selected_trips
        , trip_id_iface
        , status_code
        , inventory_item_id
        , organization_id
        , carrier_id
        , ship_method_code
        , compile_designator
        , mode_of_transport
        , load_tender_status
        , lane_id
        , service_level
        )
        (
        select p_release_id
        , null
        , mt.plan_id
        , mt.trip_id
        , mt.sr_trip_id
        , mt.trip_number
        , mt.planned_flag
        , mt.release_status
        , mt.trip_start_date
        , mt.continuous_move_id
        , mt.continuous_move_sequence
        , mt.out_of_scope
        , null
        , 1
        , wsh_trips_interface_s.nextval
        , mt.status_code
        , fvt.inventory_item_id
        , fvt.organization_id
        , mt.carrier_id
        , mt.ship_method_code
        , mp.compile_designator
        , mt.mode_of_transport
        , mt.load_tender_status
        , mt.lane_id
        , mt.service_level
        from mst_plans mp
        , mst_trips mt
        , fte_vehicle_types fvt
        where mt.plan_id = p_plan_id
        and mt.plan_id = mp.plan_id
        and mt.vehicle_type_id = fvt.vehicle_type_id (+)
        and mt.continuous_move_id = p_load_tab(i)
        );
      elsif p_load_type = 'TRIP' then
        forall i in 1..p_load_tab.last
        insert into mst_release_temp
        (
         release_id
        , group_id
        , plan_id
        , trip_id
        , sr_trip_id
        , trip_number
        , planned_flag
        , release_status
        , trip_start_date
        , cm_id_of_trip
        , continuous_move_sequence
        , out_of_scope
        , trip_process_flag
        , selected_trips
        , trip_id_iface
        , status_code
        , inventory_item_id
        , organization_id
        , carrier_id
        , ship_method_code
        , compile_designator
        , mode_of_transport
        , load_tender_status
        , lane_id
        , service_level
        )
        (
        select p_release_id
        , null
        , mt.plan_id
        , mt.trip_id
        , mt.sr_trip_id
        , mt.trip_number
        , mt.planned_flag
        , mt.release_status
        , mt.trip_start_date
        , mt.continuous_move_id
        , mt.continuous_move_sequence
        , mt.out_of_scope
        , null
        , 1
        , wsh_trips_interface_s.nextval
        , mt.status_code
        , fvt.inventory_item_id
        , fvt.organization_id
        , mt.carrier_id
        , mt.ship_method_code
        , mp.compile_designator
        , mt.mode_of_transport
        , mt.load_tender_status
        , mt.lane_id
        , mt.service_level
        from mst_plans mp
        , mst_trips mt
        , fte_vehicle_types fvt
        where mt.plan_id = p_plan_id
        and mt.plan_id = mp.plan_id
        and mt.vehicle_type_id = fvt.vehicle_type_id (+)
        and mt.trip_id = p_load_tab(i)
        );
      end if;
      commit;
    end if;

    print_info(g_log_flow_of_control,'insert_trips : Program ended');
  end insert_trips;

  procedure remove_unqualified_trips (x_return_status out nocopy varchar2
                                    , p_plan_id       in         pls_integer
                                    , p_release_id    in         pls_integer) is

    -- cursor to retrieve out of scope trips and trips in TE
    cursor cur_trips (l_release_id in pls_integer, l_plan_id in pls_integer)
    is
    select mrt.trip_id, mrt.trip_number, mrt.out_of_scope, mrt.planned_flag, mrt.release_status, decode(mrt.mode_of_transport,'TRUCK',g_str_truck_tl,'LTL',g_str_ltl_tl,'PARCEL',g_str_parcel_tl,mrt.mode_of_transport)
    from mst_release_temp_gt mrt
    where mrt.release_id = l_release_id
    and mrt.trip_id is not null
    and mrt.out_of_scope = 1;

    -- cursor to retrieve empty trips and not part of continuous move
    cursor cur_trips_1 (l_release_id in pls_integer, l_plan_id in pls_integer)
    is
    select mrt.trip_id, mrt.trip_number, decode(mrt.mode_of_transport,'TRUCK',g_str_truck_tl,'LTL',g_str_ltl_tl,'PARCEL',g_str_parcel_tl,mrt.mode_of_transport)
    from mst_release_temp_gt mrt
    where mrt.release_id = l_release_id
    and mrt.cm_id_of_trip is null
    and mrt.trip_id not in (select mdl.trip_id
                            from mst_delivery_legs mdl
                            where mdl.plan_id = l_plan_id);

    l_trip_id_tab        number_tab_type;
    l_trip_number_tab    number_tab_type;
    l_out_of_scope_tab   number_tab_type;
    l_planned_flag_tab   number_tab_type;
    l_release_status_tab number_tab_type;
    l_mode_of_transport_tl_tab varchar2_tab_type;
    l_Message_Text       varchar2(1000);
  begin
    print_info(g_log_flow_of_control,'remove_unqualified_trips : Program started');
    if g_release_data <> 'PLAN' then
      -- remove the out of scope trips
      open cur_trips (p_release_id, p_plan_id);
      fetch cur_trips bulk collect into l_trip_id_tab, l_trip_number_tab, l_out_of_scope_tab, l_planned_flag_tab, l_release_status_tab, l_mode_of_transport_tl_tab;
      close cur_trips;

      if nvl(l_trip_id_tab.last,0) >= 1 then
        for i in 1..l_trip_id_tab.last loop
          --print_info(g_log_must_message,'Trip '||l_trip_number_tab(i)||' was out of scope so can not be released directly');
          fnd_message.set_name('MST','MST_REL_BK_MESSAGE_30');
          fnd_message.set_token('N1',to_char(l_trip_number_tab(i))||' [ '||l_mode_of_transport_tl_tab(i)||' ]');
          l_Message_Text := fnd_message.get;
          print_info(g_log_must_message,l_Message_Text);
        end loop;
        print_info(g_log_must_message,'');

        forall i in 1..l_trip_id_tab.last
        update mst_release_temp_gt
        set planned_flag = -1111
        where release_id = p_release_id
        and trip_id = l_trip_id_tab(i);
      end if;
    end if;

    -- remove the empty trips which are not part of continuous move
    open cur_trips_1 (p_release_id, p_plan_id);
    fetch cur_trips_1 bulk collect into l_trip_id_tab, l_trip_number_tab, l_mode_of_transport_tl_tab;
    close cur_trips_1;

    if nvl(l_trip_id_tab.last,0) >= 1 then
      for i in 1..l_trip_id_tab.last loop
        --print_info(g_log_must_message,'Trip '||l_trip_number_tab(i)||' was an empty trip and not part of continuous move. So can not be released.');
        fnd_message.set_name('MST','MST_REL_BK_MESSAGE_31');
        fnd_message.set_token('N1',to_char(l_trip_number_tab(i))||' [ '||l_mode_of_transport_tl_tab(i)||' ]');
        l_Message_Text := fnd_message.get;
        print_info(g_log_must_message,l_Message_Text);
      end loop;
      print_info(g_log_must_message,'');

      forall i in 1..l_trip_id_tab.last
      update mst_release_temp_gt
      set planned_flag = -2222
      where release_id = p_release_id
      and trip_id = l_trip_id_tab(i);
    end if;

    x_return_status := fnd_api.g_ret_sts_success;
    print_info(g_log_flow_of_control,'remove_unqualified_trips : Program ended');
  exception
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      print_info(g_log_flow_of_control,'remove_unqualified_trips : Unexpected error ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end remove_unqualified_trips;

  procedure populate_related_trip_thru_cm (x_return_status out nocopy varchar2
                                         , p_plan_id       in         number
                                         , p_release_id    in         pls_integer
                                         , p_cm_id_of_trip in         number
                                         , p_planned_flag  in         number
                                         , p_group_id      in         pls_integer) is

    cursor cur_cm (l_release_id in pls_integer, l_cm_id in number)
    is
    select 1
    from mst_release_temp_gt
    where release_id = l_release_id
    and continuous_move_id = l_cm_id;

    l_cm_exist number := 0;

    cursor cur_cm_trips (l_plan_id in number, l_cm_id in number)
    is
    select mct.planned_flag, mct.sr_cm_trip_id, mct.lane_id, mct.service_level, mp.compile_designator, mct.cm_trip_number
    from mst_cm_trips mct
    , mst_plans mp
    where mp.plan_id = l_plan_id
    and mct.plan_id = l_plan_id
    and mct.continuous_move_id = l_cm_id;

    l_cm_planned_flag number;
    l_sr_cm_trip_id number;
    l_lane_id number;
    l_service_level varchar2(30);
    l_compile_designator varchar2(10);
    l_cm_trip_number number;

  begin
    print_info(g_log_flow_of_control,'populate_related_trip_thru_cm for CM = '||p_cm_id_of_trip||' : Program started');

    open cur_cm (p_release_id, p_cm_id_of_trip);
    fetch cur_cm into l_cm_exist;

    if cur_cm%notfound then -- means its data are not available in mst_release_temp_gt
      g_cnt_cm_selected := g_cnt_cm_selected + 1;
      -- get the planned flag of cm
      open cur_cm_trips(p_plan_id, p_cm_id_of_trip);
      fetch cur_cm_trips into l_cm_planned_flag, l_sr_cm_trip_id, l_lane_id, l_service_level, l_compile_designator, l_cm_trip_number;
      close cur_cm_trips;

      -- insert continuous moves data into permanent temporary table
      insert into mst_release_temp_gt
      (
        release_id
      , plan_id
      , group_id
      , planned_flag
      , continuous_move_id
      , sr_cm_trip_id
      , continuous_move_id_iface
      , lane_id
      , service_level
      , compile_designator
      , cm_trip_number
      )
      values
      (
        p_release_id
      , p_plan_id
      , p_group_id
      , l_cm_planned_flag
      , p_cm_id_of_trip
      , l_sr_cm_trip_id
      , fte_moves_interface_s.nextval
      , l_lane_id
      , l_service_level
      , l_compile_designator
      , l_cm_trip_number
      );

      -- insert trips corresponding to this continuous move into mst_release_temp_gt if it is not available
      insert into mst_release_temp_gt
      (
        release_id
      , group_id
      , plan_id
      , trip_id
      , sr_trip_id
      , trip_number
      , planned_flag
      , release_status
      , trip_start_date
      , cm_id_of_trip
      , continuous_move_sequence
      , out_of_scope
      , trip_process_flag
      , trip_id_iface
      , status_code
      , inventory_item_id
      , organization_id
      , carrier_id
      , ship_method_code
      , compile_designator
      , mode_of_transport
      , load_tender_status
      , lane_id
      , service_level
      )
      (
        select p_release_id
      , null
      , mt.plan_id
      , mt.trip_id
      , mt.sr_trip_id
      , mt.trip_number
      , mt.planned_flag
      , mt.release_status
      , mt.trip_start_date
      , mt.continuous_move_id
      , mt.continuous_move_sequence
      , mt.out_of_scope
      , null
      , wsh_trips_interface_s.nextval
      , mt.status_code
      , fvt.inventory_item_id
      , fvt.organization_id
      , mt.carrier_id
      , mt.ship_method_code
      , mp.compile_designator
      , mt.mode_of_transport
      , mt.load_tender_status
      , mt.lane_id
      , mt.service_level
      from mst_plans mp
      , mst_trips mt
      , fte_vehicle_types fvt
      where mt.plan_id = p_plan_id
      and mt.continuous_move_id = p_cm_id_of_trip
      and mt.plan_id = mp.plan_id
      and mt.vehicle_type_id = fvt.vehicle_type_id (+)
      and mt.trip_id not in (select mrt1.trip_id
                             from mst_release_temp_gt mrt1
                             where mrt1.release_id = p_release_id
                             and mrt1.trip_id is not null)
      );

      --assign same group_id and set planned_flag of trip under this cm minimum as 2 (routing) if cm is firm

      update mst_release_temp_gt mrt
      Set mrt.group_id = p_group_id
      , mrt.planned_flag = decode(p_planned_flag,-1111,-1111,decode(l_cm_planned_flag, 1, decode(nvl(mrt.planned_flag,3),3,2,mrt.planned_flag), mrt.planned_flag))
      where release_id = p_release_id
      and cm_id_of_trip = p_cm_id_of_trip;

    end if;
    close cur_cm;

    x_return_status := fnd_api.g_ret_sts_success;
    print_info(g_log_flow_of_control,'populate_related_trip_thru_cm for CM = '||p_cm_id_of_trip||' Program ended');
  exception
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      print_info(g_log_flow_of_control,'populate_related_trip_thru_cm : Unexpected error ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end populate_related_trip_thru_cm;

  procedure populate_related_trip_thru_del (x_return_status out nocopy varchar2
                                          , p_plan_id       in         number
                                          , p_release_id    in         pls_integer
                                          , p_trip_id       in         number
                                          , p_planned_flag  in         number
                                          , p_group_id      in         pls_integer) is
    l_count pls_integer := 0;
  begin
    print_info(g_log_flow_of_control,'populate_related_trip_thru_del for trip = '||p_trip_id||' : Program started');
    if g_release_data <> 'PLAN' then
      -- insert related trip ids into mst_release_temp_gt with same group_id
      insert into mst_release_temp_gt
      (
        release_id
      , group_id
      , plan_id
      , sr_trip_id
      , trip_id
      , trip_number
      , planned_flag
      , release_status
      , trip_start_date
      , cm_id_of_trip
      , continuous_move_sequence
      , out_of_scope
      --, trip_id_iface                   bug # 3509717 moving to update section below
      , trip_process_flag
      , status_code
      , inventory_item_id
      , organization_id
      , carrier_id
      , ship_method_code
      , compile_designator
      , mode_of_transport
      , load_tender_status
      , lane_id
      , service_level
      )
      (
        select distinct p_release_id      -- distinct added to remove repeatation of trips
      , null
      , mt.plan_id
      , mt.sr_trip_id
      , mt.trip_id
      , mt.trip_number
      , mt.planned_flag
      , mt.release_status
      , mt.trip_start_date
      , mt.continuous_move_id
      , mt.continuous_move_sequence
      , mt.out_of_scope
      --, wsh_trips_interface_s.nextval    bug # 3509717 moving to update section below
      , null
      , mt.status_code
      , fvt.inventory_item_id
      , fvt.organization_id
      , mt.carrier_id
      , mt.ship_method_code
      , mp.compile_designator
      , mt.mode_of_transport
      , mt.load_tender_status
      , mt.lane_id
      , mt.service_level
      from mst_delivery_legs mdl
      , mst_delivery_legs mdl1
      , mst_trips mt
      , mst_plans mp
      , fte_vehicle_types fvt
      where mdl.plan_id = p_plan_id
      and mdl.trip_id = p_trip_id
      and mdl1.plan_id = mdl.plan_id
      and mdl1.delivery_id = mdl.delivery_id
      and mdl1.trip_id <> mdl.trip_id
      and mt.plan_id = mdl1.plan_id
      and mt.trip_id = mdl1.trip_id
      and mt.plan_id = mp.plan_id
      and mt.vehicle_type_id = fvt.vehicle_type_id (+)
      and mt.trip_id not in (select mrt.trip_id
                             from mst_release_temp_gt mrt
                             where release_id = p_release_id)
      );
      l_count := sql%rowcount;
    end if;
    --assign same group_id and set planned_flag of trip which are related to current trip thru delivery
    update mst_release_temp_gt mrt
    Set mrt.group_id = p_group_id
    , trip_id_iface = wsh_trips_interface_s.nextval -- bug # 3509717 moved here from insert section
    , mrt.planned_flag = decode(p_planned_flag,-1111,-1111,
                                               decode(mrt.out_of_scope,1,mrt.planned_flag
                                                                      ,decode(p_planned_flag,1,decode(nvl(mrt.planned_flag,0),3,2,mrt.planned_flag),mrt.planned_flag)))
    where mrt.release_id = p_release_id
    and mrt.trip_id in (select mdl_rel.trip_id
                        from mst_delivery_legs mdl
                        , mst_delivery_legs mdl_rel
                        where mdl_rel.plan_id = mdl.plan_id
                        and mdl_rel.delivery_id = mdl.delivery_id
                        and mdl_rel.trip_id <> mdl.trip_id
                        and mdl.plan_id = p_plan_id
                        and mdl.trip_id = p_trip_id);

    x_return_status := fnd_api.g_ret_sts_success;
    print_info(g_log_flow_of_control,'populate_related_trip_thru_del for trip = '||p_trip_id||' : Program ended');
  exception
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      print_info(g_log_flow_of_control,'populate_related_trip_thru_del : Unexpected error ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end populate_related_trip_thru_del;

  procedure populate_related_trips (x_return_status out nocopy varchar2
                                  , p_plan_id       in         number
                                  , p_release_id    in         pls_integer) is

    cursor cur_trips(l_release_id in pls_integer)
    is
    select trip_id
    , group_id
    , planned_flag
    , cm_id_of_trip
    from mst_release_temp_gt
    where release_id = l_release_id
    and trip_id is not null
    and trip_process_flag is null
    order by group_id;

    l_trip_id number;
    l_group_id number;
    l_planned_flag number;
    l_cm_id_of_trip number;

    l_counter number;

    l_return_status varchar2(1);
    l_error_from_called_procedure exception;
  begin
    print_info(g_log_flow_of_control,'populate_related_trips : Program started');

    loop
      l_counter := 0;
      open cur_trips(p_release_id);
      fetch cur_trips into l_trip_id, l_group_id, l_planned_flag, l_cm_id_of_trip;
      if cur_trips%notfound then
        l_counter := 1;
      end if;
      close cur_trips;

      if l_counter = 1 then
        exit;
      end if;

      if l_group_id is null then
        select mst_release_seq.nextval
        into l_group_id
        from dual;
      end if;

      --update mst_release_temp_gt so that it would not be selected during next round of cursor opening
      update mst_release_temp_gt
      set group_id = l_group_id
      , trip_process_flag = 1
      where release_id = p_release_id
      and trip_id = l_trip_id;

      if l_cm_id_of_trip is not null then -- means this trips is part of a continuous move
        populate_related_trip_thru_cm(l_return_status, p_plan_id, p_release_id, l_cm_id_of_trip, l_planned_flag, l_group_id);
        if l_return_status <> fnd_api.g_ret_sts_success then
          raise l_error_from_called_procedure;
        end if;
      end if;

      populate_related_trip_thru_del(l_return_status, p_plan_id, p_release_id, l_trip_id, l_planned_flag, l_group_id);
      if l_return_status <> fnd_api.g_ret_sts_success then
        raise l_error_from_called_procedure;
      end if;
    end loop;

    x_return_status := fnd_api.g_ret_sts_success;
    print_info(g_log_flow_of_control,'populate_related_trips : Program ended');
  exception
    when l_error_from_called_procedure then
      x_return_status := fnd_api.g_ret_sts_error;
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      print_info(g_log_flow_of_control,'populate_related_trips : Unexpected error ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end populate_related_trips;

  procedure remove_grp_of_passed_dep_dt (x_return_status      out nocopy varchar2
                                       , p_release_id         in         number
                                       , p_release_start_date in         date) is

    cursor cur_trips (l_release_id in pls_integer, l_release_start_date in date)
    is
    select mrt.group_id, mrt.trip_number, decode(mrt.mode_of_transport,'TRUCK',g_str_truck_tl,'LTL',g_str_ltl_tl,'PARCEL',g_str_parcel_tl,mrt.mode_of_transport)
    from mst_release_temp_gt mrt
    where mrt.release_id = l_release_id
    and mrt.trip_start_date < l_release_start_date;

    l_group_id_tab number_tab_type;
    l_trip_number_tab  number_tab_type;
    l_mode_of_transport_tl_tab varchar2_tab_type;
    l_Message_Text varchar2(1000);
  begin
    print_info(g_log_flow_of_control,'remove_grp_of_passed_dep_dt : Program started');

    open cur_trips (p_release_id, p_release_start_date);
    fetch cur_trips bulk collect into l_group_id_tab, l_trip_number_tab, l_mode_of_transport_tl_tab;
    close cur_trips;

    if nvl(l_group_id_tab.last,0) > 0 then
      -- mark entire group for delete in temporary table
      forall i in 1..l_group_id_tab.last
      update mst_release_temp_gt mrt
      set mrt.planned_flag = -3333
      where mrt.release_id = p_release_id
      and mrt.group_id = l_group_id_tab(i);

      for i in 1..l_trip_number_tab.last loop
        --print_info(g_log_must_message,'Group of trip '||l_trip_number_tab(i)||' is not being released as departure date of this trip has been passed');
        fnd_message.set_name('MST','MST_REL_BK_MESSAGE_32');
        fnd_message.set_token('N1',to_char(l_trip_number_tab(i))||' [ '||l_mode_of_transport_tl_tab(i)||' ]');
        l_Message_Text := fnd_message.get;
        print_info(g_log_must_message,l_Message_Text);
      end loop;
      print_info(g_log_must_message,'');
    end if;

    x_return_status := fnd_api.g_ret_sts_success;
    print_info(g_log_flow_of_control,'remove_grp_of_passed_dep_dt : Program ended');
  exception
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      print_info(g_log_flow_of_control,'remove_grp_of_passed_dep_dt : Unexpected error ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end remove_grp_of_passed_dep_dt;

  procedure remove_grp_of_exceptions (x_return_status out nocopy varchar2
                                    , p_plan_id       in         number
                                    , p_release_id    in         pls_integer
                                    , p_release_mode  in         number) is

    -- cursor to retrieve group_ids in current release
    cursor cur_group_trips (l_release_id in pls_integer) is
    select group_id, trip_id, trip_number, decode(mode_of_transport,'TRUCK',g_str_truck_tl,'LTL',g_str_ltl_tl,'PARCEL',g_str_parcel_tl,mode_of_transport)
    from mst_release_temp_gt
    where release_id = l_release_id
    and trip_id is not null
    order by group_id;

    l_group_id_tab number_tab_type;
    l_trip_id_tab number_tab_type;
    l_trip_number_tab number_tab_type;
    l_mode_of_transport_tl_tab varchar2_tab_type;

    l_group_id_tobedeleted_tab number_tab_type;

    l_previous_group_id pls_integer := -1;

    -- cursor to get the release option corresponding to the current trip/cm/delivery's exception
    cursor cur_excep (l_plan_id in number, l_trip_id in number)
    is
    select mep.release_option
    from mst_excep_preferences mep
    , mst_exception_details med
    where mep.user_id = -9999
    and mep.release_option = 1
    and mep.exception_type = med.exception_type
    and med.plan_id = l_plan_id
    and (med.trip_id1 = l_trip_id                                    -- trip_id2 is not being checked since
      or med.delivery_id in (select mdl.delivery_id                  -- it can not exists without trip_id1.
                             from mst_delivery_legs mdl              -- continuous_move_id is not being checked
                             where mdl.plan_id = l_plan_id           -- since it is not being populated without trip_id1
                             and mdl.trip_id = l_trip_id)
      or med.location_id in (select mts.stop_location_id
                             from mst_trip_stops mts
                             where mts.plan_id = l_plan_id
                             and mts.trip_id = l_trip_id));

    l_release_option number;
    l_Message_Text varchar2(1000);
  begin
    print_info(g_log_flow_of_control,'remove_grp_of_exceptions : Program started');

    open cur_group_trips (p_release_id);
    fetch cur_group_trips bulk collect into l_group_id_tab, l_trip_id_tab, l_trip_number_tab, l_mode_of_transport_tl_tab;
    close cur_group_trips;

    if nvl(l_trip_id_tab.last,0) > 0 then
      for i in 1..l_trip_id_tab.last loop
        if l_previous_group_id <> l_group_id_tab(i) then

          open cur_excep(p_plan_id, l_trip_id_tab(i));
          fetch cur_excep into l_release_option;
          if not cur_excep%notfound then
            --if l_release_option = 1 and nvl(p_release_mode,2) = 2 then
            --  print_info(g_log_must_message,'Group of trip '||l_trip_number_tab(i)||' is being selected for release but this trip has exception');
            --elsif l_release_option = 1 and p_release_mode = 1 then
            if p_release_mode = 1 then
              l_group_id_tobedeleted_tab(nvl(l_group_id_tobedeleted_tab.last,0) + 1) := l_group_id_tab(i);
              l_previous_group_id := l_group_id_tab(i);
              --print_info(g_log_must_message,'Group of trip '||l_trip_number_tab(i)||' is not being released as this trip has restricted exception.');
              fnd_message.set_name('MST','MST_REL_BK_MESSAGE_33');
              fnd_message.set_token('N1',to_char(l_trip_number_tab(i))||' [ '||l_mode_of_transport_tl_tab(i)||' ]');
              l_Message_Text := fnd_message.get;
              print_info(g_log_must_message,l_Message_Text);
            end if;
          end if;
          close cur_excep;
        end if;
      end loop;

      if nvl(l_group_id_tobedeleted_tab.last,0) > 0 then
        print_info(g_log_must_message,'');
        -- fail group since its one trip disqualified due to exception
        forall i in 1..l_group_id_tobedeleted_tab.last
        update mst_release_temp_gt
        set planned_flag = -4444
        where release_id = p_release_id
        and group_id = l_group_id_tobedeleted_tab(i);
      end if;
    end if;

    x_return_status := fnd_api.g_ret_sts_success;
    print_info(g_log_flow_of_control,'remove_grp_of_exceptions : Program ended');
  exception
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      print_info(g_log_flow_of_control,'remove_grp_of_exceptions : Unexpected error ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end remove_grp_of_exceptions;

/*
  procedure remove_grp_of_unwanted_trip (x_return_status out nocopy varchar2
                                       , p_plan_id       in         number
                                       , p_release_id    in         pls_integer
                                       , p_release_mode  in         number) is

    -- cursor to retrieve group_ids in current release
    cursor cur_group_trips (l_release_id in pls_integer) is
    select group_id, trip_id, trip_number, decode(mrt.mode_of_transport,'TRUCK',g_str_truck_tl,'LTL',g_str_ltl_tl,'PARCEL',g_str_parcel_tl,mrt.mode_of_transport)
    from mst_release_temp_gt
    where release_id = l_release_id
    and trip_id is not null
    and selected_trips is null;

    l_group_id_tab number_tab_type;
    l_trip_id_tab number_tab_type;
    l_trip_number_tab number_tab_type;
    l_mode_of_transport_tl_tab varchar2_tab_type;

    l_group_id_tobedeleted_tab number_tab_type;
    l_previous_group_id pls_integer := -1;
    l_Message_Text varchar2(1000);
  begin
    print_info(g_log_flow_of_control,'remove_grp_of_unwanted_trip : Program started');

    if nvl(p_release_mode,2) = 1 and g_auto_release = 3 and g_where_clause is not null then -- only for auto release
      open cur_group_trips (p_release_id);
      fetch cur_group_trips bulk collect into l_group_id_tab, l_trip_id_tab, l_trip_number_tab, l_mode_of_transport_tl_tab;
      close cur_group_trips;

      if nvl(l_trip_id_tab.last,0) > 0 then
        for i in 1..l_trip_id_tab.last loop
          if l_previous_group_id <> l_group_id_tab(i) then
            l_group_id_tobedeleted_tab(nvl(l_group_id_tobedeleted_tab.last,0) + 1) := l_group_id_tab(i);
            l_previous_group_id := l_group_id_tab(i);
            --print_info(g_log_must_message,'Group of trip '||l_trip_number_tab(i)||' is not being released as this trip does not obey rule set');
            fnd_message.set_name('MST','MST_REL_BK_MESSAGE_34');
            fnd_message.set_token('N1',to_char(l_trip_number_tab(i))||' [ '||l_mode_of_transport_tl_tab(i)||' ]');
            l_Message_Text := fnd_message.get;
            print_info(g_log_must_message,l_Message_Text);
          end if;
        end loop;

        if nvl(l_group_id_tobedeleted_tab.last,0) > 0 then
          print_info(g_log_must_message,'');
          -- fail group since its one trip disqualified due to rule set
          forall i in 1..l_group_id_tobedeleted_tab.last
          update mst_release_temp_gt
          set planned_flag = -5555
          where release_id = p_release_id
          and group_id = l_group_id_tobedeleted_tab(i);
        end if;
      end if;
    end if;

    x_return_status := fnd_api.g_ret_sts_success;
    print_info(g_log_flow_of_control,'remove_grp_of_unwanted_trip : Program ended');
  exception
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      print_info(g_log_flow_of_control,'remove_grp_of_unwanted_trip : Unexpected error ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end remove_grp_of_unwanted_trip;
*/

  procedure reset_grp_ids_in_sequence_of_1(x_return_status out nocopy varchar2
                                         , p_group_tab     out nocopy wsh_tp_release_grp.id_tab_type
                                         , p_plan_id       in         pls_integer
                                         , p_release_id    in         pls_integer) is
    l_count pls_integer;
    l_group_id pls_integer;

    cursor cur_groups (l_release_id in pls_integer, l_plan_id in pls_integer)
    is
    select distinct group_id
    from mst_release_temp_gt
    where release_id = l_release_id
    and plan_id = l_plan_id
    and trip_id is not null
    and group_id is not null
    order by group_id;

  begin
    print_info(g_log_flow_of_control,'reset_grp_ids_in_sequence_of_1 : Program started');

    -- populate l_group_tab with the distinct group_id in mst_release_temp_gt
    open cur_groups (p_release_id, p_plan_id);
    fetch cur_groups bulk collect into p_group_tab;
    close cur_groups;

    -- reset group_id such that it could be in a sequence with difference of 1 (demanded by william)
    l_count := nvl(p_group_tab.last,0);

    loop
      if l_count < 2 then
        exit;
      end if;
      l_group_id := p_group_tab(l_count);
      l_count := l_count - 1;
      if l_group_id - p_group_tab(l_count) > 1 then
        update mst_release_temp_gt
        set group_id = l_group_id-1
        where release_id = p_release_id
        and group_id = p_group_tab(l_count);

        p_group_tab(l_count) := l_group_id-1;

      end if;
    end loop;

    x_return_status := fnd_api.g_ret_sts_success;
    print_info(g_log_flow_of_control,'reset_grp_ids_in_sequence_of_1 : Program ended');
  exception
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      print_info(g_log_flow_of_control,'reset_grp_ids_in_sequence_of_1 : Unexpected error ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end reset_grp_ids_in_sequence_of_1;

  procedure populate_deliveries (x_return_status out nocopy varchar2
                               , p_release_id    in         pls_integer) is
  begin
    print_info(g_log_flow_of_control,'populate_deliveries : Program started');

    -- insert deliveries corresponding to the trips being released into permanent temporary table
    insert into mst_release_temp_gt
    (
      release_id
    , group_id
    , plan_id
    , planned_flag
    , delivery_id
    , sr_delivery_id
    , out_of_scope
--    , delivery_id_iface
    , status_code
    , pickup_date
    , dropoff_date
    , pickup_location_id
    , dropoff_location_id
    , customer_id
    , gross_weight
    , net_weight
    , weight_uom
    , volume
    , volume_uom
    , currency_uom
    , organization_id
    , shipment_direction
    , delivery_number
    , compile_designator
    , earliest_pickup_date
    , latest_pickup_date
    , earliest_acceptable_date
    , latest_acceptable_date
    , supplier_id
    , party_id
    )
    (
    select DISTINCT mrt.release_id
    , mrt.group_id
    , mrt.plan_id
    , DECODE(md.planned_flag, 1, 1
                            , 2, decode(md.preserve_grouping_flag, 1, 2
                                                                 , 2, 3
                                                                    , 3
                                       )
                               , 3
            )
    , md.delivery_id
    , md.sr_delivery_id
    , md.out_of_scope
--    , wsh_new_del_interface_s.nextval
    , nvl(md.status_code,1) status_code
    , md.pickup_date
    , md.dropoff_date
    , md.pickup_location_id
    , md.dropoff_location_id
    , md.customer_id
    , md.gross_weight
    , md.net_weight
    , mp.weight_uom
    , md.volume
    , mp.volume_uom
    , mp.currency_uom
    , nvl(md.organization_id,mst_wb_util.get_org_id(md.plan_id,md.delivery_id))
    , decode(md.shipment_direction ,1,'I',2,'O',3,'D',4,'IO','O')
    , md.delivery_number
    , mp.compile_designator
    , md.earliest_pickup_date
    , md.latest_pickup_date
    , md.earliest_acceptable_date
    , md.latest_acceptable_date
    , md.supplier_id
    , hzr.object_id
      from mst_release_temp_gt mrt
    , mst_deliveries md
    , mst_delivery_legs mdl
    , mst_plans mp
    , hz_relationships hzr
      where mrt.release_id = p_release_id
      and mrt.plan_id = mdl.plan_id
      and mrt.trip_id = mdl.trip_id
      and mdl.plan_id = md.plan_id
      and mdl.delivery_id = md.delivery_id
      and md.plan_id = mp.plan_id
      and hzr.relationship_type (+) = 'POS_VENDOR_PARTY'
      and hzr.object_table_name (+) = 'PO_VENDORS'
      and hzr.object_type (+) = 'POS_VENDOR'
      and hzr.subject_table_name (+) = 'HZ_PARTIES'
      and hzr.subject_type (+) = 'ORGANIZATION'
      and hzr.status (+) = 'A'
      and hzr.subject_id (+) = md.supplier_id
    );

    -- update delivery_id_iface and planned_flag for deliveries in mst_release_temp_gt
    UPDATE mst_release_temp_gt mrt
    SET mrt.delivery_id_iface = wsh_new_del_interface_s.nextval
    WHERE mrt.release_id = p_release_id
    AND mrt.delivery_id IS NOT NULL;

    -- update planned_flag for deliveries of RCF trips
    UPDATE mst_release_temp_gt mrt
    SET mrt.planned_flag = 1
    WHERE mrt.release_id = p_release_id
    AND mrt.delivery_id IN (SELECT mdl.delivery_id
                            FROM mst_delivery_legs mdl
                            , mst_release_temp_gt mrt1
                            WHERE mdl.plan_id = mrt1.plan_id
                            AND mdl.trip_id = mrt1.trip_id
                            AND mrt1.release_id = p_release_id
                            AND mrt1.trip_id IS NOT NULL
                            AND mrt1.planned_flag = 1);

    x_return_status := fnd_api.g_ret_sts_success;
    print_info(g_log_flow_of_control,'populate_deliveries : Program ended');
  exception
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      print_info(g_log_flow_of_control,'populate_deliveries : Unexpected error ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end populate_deliveries;

  procedure update_ids_in_wdd_iface_tab (p_release_id in pls_integer) is
    cursor cur_wdd_ids (l_release_id in pls_integer)
    is
    select wdd_iface.delivery_detail_interface_id, min(wdd.source_header_id), min(wdd.source_line_id), min(wdd.source_line_set_id)
    from wsh_delivery_details wdd
    , mst_release_temp_gt mrt
    , wsh_del_details_interface wdd_iface
    where wdd.source_code = wdd_iface.source_code
    and wdd.source_header_number = wdd_iface.source_header_number
    and substr(wdd.source_line_number,1,instr(wdd.source_line_number||'.','.',1,1)-1) = substr(wdd_iface.source_line_number,1,instr(wdd_iface.source_line_number||'.','.',1,1)-1)
    and (wdd_iface.source_header_id is null or wdd_iface.source_line_id = FND_API.G_MISS_NUM or wdd_iface.source_line_set_id is null)
    and wdd_iface.delivery_detail_interface_id = mrt.delivery_detail_id_iface
    and mrt.release_id = l_release_id
    group by wdd_iface.delivery_detail_interface_id;

    l_delivery_detail_iface_id_tab number_tab_type;
    l_source_header_id_tab         number_tab_type;
    l_source_line_id_tab           number_tab_type;
    l_source_line_set_id_tab       number_tab_type;
  begin
    print_info(g_log_flow_of_control,'update_ids_in_wdd_iface_tab : Program started');
    open cur_wdd_ids (p_release_id);
    fetch cur_wdd_ids bulk collect into l_delivery_detail_iface_id_tab, l_source_header_id_tab, l_source_line_id_tab, l_source_line_set_id_tab;
    close cur_wdd_ids;

    if nvl(l_delivery_detail_iface_id_tab.last,0) > 0 then
      forall i in 1..l_delivery_detail_iface_id_tab.last
      update wsh_del_details_interface
      set source_header_id = l_source_header_id_tab(i)
      , source_line_id = l_source_line_id_tab(i)
      , source_line_set_id = l_source_line_set_id_tab(i)
      where delivery_detail_interface_id = l_delivery_detail_iface_id_tab(i);
    end if;
    print_info(g_log_flow_of_control,'update_ids_in_wdd_iface_tab : Program ended');
  end update_ids_in_wdd_iface_tab;

  procedure update_loc_id_in_iface_tab (p_release_id in pls_integer) is
    cursor cur_wdd_loc_ids (l_release_id in pls_integer)
    is
    select wda_iface.delivery_interface_id, wdd_iface.delivery_detail_interface_id, mplav.cust_location_id
    from mst_po_location_asso_v mplav
    , wsh_del_details_interface wdd_iface
    , wsh_del_assgn_interface wda_iface
    , wsh_delivery_details wdd
    , mst_release_temp_gt mrt
    where mplav.location_id = wdd_iface.ship_to_location_id
    and wdd_iface.delivery_detail_id = wdd.delivery_detail_id
    and wdd.ship_to_location_id <> wdd_iface.ship_to_location_id
    and wda_iface.delivery_detail_interface_id = wdd_iface.delivery_detail_interface_id
    and wdd_iface.delivery_detail_interface_id = mrt.delivery_detail_id_iface
    and mrt.release_id = l_release_id;

    l_delivery_iface_id_tab        number_tab_type;
    l_delivery_detail_iface_id_tab number_tab_type;
    l_ship_to_location_id_tab      number_tab_type;
  begin
    print_info(g_log_flow_of_control,'update_loc_id_in_wdd_iface_tab : Program started');
    open cur_wdd_loc_ids (p_release_id);
    fetch cur_wdd_loc_ids bulk collect into l_delivery_iface_id_tab, l_delivery_detail_iface_id_tab, l_ship_to_location_id_tab;
    close cur_wdd_loc_ids;

    if nvl(l_delivery_iface_id_tab.last,0) > 0 then
      forall i in 1..l_delivery_iface_id_tab.last
      update wsh_new_del_interface
      set ultimate_dropoff_location_id = l_ship_to_location_id_tab(i)
      where delivery_interface_id = l_delivery_iface_id_tab(i);
    end if;

    if nvl(l_delivery_detail_iface_id_tab.last,0) > 0 then
      forall i in 1..l_delivery_detail_iface_id_tab.last
      update wsh_del_details_interface
      set ship_to_location_id = l_ship_to_location_id_tab(i)
      where delivery_detail_interface_id = l_delivery_detail_iface_id_tab(i);
    end if;
    print_info(g_log_flow_of_control,'update_loc_id_in_wdd_iface_tab : Program ended');
  end update_loc_id_in_iface_tab;

  procedure populate_interface_tables(x_return_status out nocopy varchar2
                                    , p_release_id    in         pls_integer) is
    l_date date   := sysdate;
    l_user number := fnd_global.user_id;
  begin
    print_info(g_log_flow_of_control,'populate_interface_tables : Program started');

    insert into wsh_trips_interface
    ( trip_interface_id
    , trip_id
    , planned_flag
    , status_code
    , vehicle_item_id
    , vehicle_organization_id
    , carrier_id
    , ship_method_code
    , interface_action_code
    , tp_plan_name
    , tp_trip_number
    , group_id
    , mode_of_transport
    , load_tender_status
    , lane_id
    , service_level
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    )
    (
    select mrt.trip_id_iface
    , mrt.sr_trip_id
    , decode(mrt.planned_flag,1,'F',2,'Y',3,'N','N')
    , decode(mrt.status_code,1,'OP',2,'IT',3,'CL','OP')
    , mrt.inventory_item_id
    , mrt.organization_id
    , mrt.carrier_id
    , mrt.ship_method_code
    , g_tp_release_code
    , mrt.compile_designator
    , mrt.trip_number
    , mrt.group_id
    , mrt.mode_of_transport
    , mrt.load_tender_status
    , mrt.lane_id
    , mrt.service_level
    , l_date
    , l_user
    , l_date
    , l_user
    , l_user
    from mst_release_temp_gt mrt
    where mrt.release_id = p_release_id
    and mrt.trip_id is not null
    );

    insert into fte_moves_interface
    ( move_interface_id
    , move_id
    , lane_id
    , service_level
    , planned_flag
    , tp_plan_name
    , cm_trip_number
    , interface_action_code
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    )
    (
    select mrt.continuous_move_id_iface
    , mrt.sr_cm_trip_id
    , mrt.lane_id
    , mrt.service_level
    , decode(mrt.planned_flag,1,'Y',2,'N','N')
    , mrt.compile_designator
    , mrt.cm_trip_number
    , g_tp_release_code
    , l_date
    , l_user
    , l_date
    , l_user
    , l_user
    from mst_release_temp_gt mrt
    where mrt.release_id = p_release_id
    and mrt.continuous_move_id is not null
    );

    insert into fte_trip_moves_interface
    ( trip_move_interface_id
    , trip_move_id
    , move_interface_id
    , move_id
    , trip_interface_id
    , trip_id
    , sequence_number
    , interface_action_code
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    )
    (
    select fte_trip_moves_interface_s.nextval
    , null
    , mrt1.continuous_move_id_iface
    , mrt1.sr_cm_trip_id
    , mrt2.trip_id_iface
    , mrt2.sr_trip_id
    , mrt2.continuous_move_sequence
    , g_tp_release_code
    , l_date
    , fnd_global.user_id
    , l_date
    , l_user
    , l_user
    from mst_release_temp_gt mrt1
    , mst_release_temp_gt mrt2
    where mrt1.release_id = mrt2.release_id
    and mrt1.continuous_move_id = mrt2.cm_id_of_trip
    and mrt2.release_id = p_release_id
    );

    --generate interface ids for stops
    insert into mst_release_temp_gt
    (
      release_id
    , group_id
    , plan_id
    , stop_id
    , trip_id_iface
    , stop_id_iface
    , sr_trip_id
    , status_code
    , sr_stop_id
    , stop_location_id
    , stop_sequence_number
    , planned_arrival_date
    , planned_departure_date
    , departure_gross_weight
    , departure_net_weight
    , weight_uom
    , departure_volume
    , volume_uom
    , departure_fill_percent
    , wkend_layover_stops
    , wkday_layover_stops
    , pln_loading_start_time
    , pln_loading_end_time
    , pln_unloading_start_time
    , pln_unloading_end_time
    )
    (
    select p_release_id
    , mrt.group_id
    , mts.plan_id
    , mts.stop_id
    , mrt.trip_id_iface
    , wsh_trip_stops_interface_s.nextval
    , mrt.sr_trip_id
    , mrt.status_code
    , mts.sr_stop_id
    , mts.stop_location_id
    , mts.stop_sequence_number
    , mts.planned_arrival_date
    , mts.planned_departure_date
    , mts.departure_gross_weight
    , mts.departure_net_weight
    , mp.weight_uom
    , mts.departure_volume
    , mp.volume_uom
    , mts.departure_fill_percent
    , mts.wkend_layover_stops
    , mts.wkday_layover_stops
    , mts.pln_loading_start_time
    , mts.pln_loading_end_time
    , mts.pln_unloading_start_time
    , mts.pln_unloading_end_time
    from mst_plans mp
    , mst_trip_stops mts
    , mst_release_temp_gt mrt
    where mrt.release_id = p_release_id
      and mrt.plan_id = mts.plan_id
      and mrt.trip_id = mts.trip_id
      and mrt.plan_id = mp.plan_id
    );

    insert into wsh_trip_stops_interface
    ( stop_interface_id
    , stop_id
    , trip_id
    , tp_stop_id
    , trip_interface_id
    , stop_location_id
    , status_code
    , stop_sequence_number
    , planned_arrival_date
    , planned_departure_date
    , departure_gross_weight
    , departure_net_weight
    , weight_uom_code
    , departure_volume
    , volume_uom_code
    , departure_fill_percent
    , wkend_layover_stops
    , wkday_layover_stops
    , loading_start_datetime
    , loading_end_datetime
    , unloading_start_datetime
    , unloading_end_datetime
    , interface_action_code
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    )
    (
    select mrt.stop_id_iface
    , mrt.sr_stop_id
    , mrt.sr_trip_id
    , mrt.stop_id
    , mrt.trip_id_iface
    , mrt.stop_location_id
    , decode(mrt.status_code,1,'OP',2,'IT',3,'CL','OP')
    , mrt.stop_sequence_number
    , mrt.planned_arrival_date
    , mrt.planned_departure_date
    , mrt.departure_gross_weight
    , mrt.departure_net_weight
    , mrt.weight_uom
    , mrt.departure_volume
    , mrt.volume_uom
    , mrt.departure_fill_percent
    , mrt.wkend_layover_stops
    , mrt.wkday_layover_stops
    , mrt.pln_loading_start_time
    , mrt.pln_loading_end_time
    , mrt.pln_unloading_start_time
    , mrt.pln_unloading_end_time
    , g_tp_release_code
    , l_date
    , fnd_global.user_id
    , l_date
    , l_user
    , l_user
    from mst_release_temp_gt mrt
    where mrt.release_id = p_release_id
    and mrt.stop_id is not null
    );

    insert into wsh_new_del_interface
    ( delivery_interface_id
    , delivery_id
    , planned_flag
    , status_code
    , initial_pickup_date
    , initial_pickup_location_id
    , ultimate_dropoff_location_id
    , ultimate_dropoff_date
    , customer_id
    , gross_weight
    , net_weight
    , weight_uom_code
    , volume
    , volume_uom_code
    , currency_code
    , organization_id
    , shipment_direction
    , tp_delivery_number
    , tp_plan_name
    , earliest_pickup_date
    , latest_pickup_date
    , earliest_dropoff_date
    , latest_dropoff_date
    , delivery_type
    , interface_action_code
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    )
    (
    select mrt.delivery_id_iface
    , mrt.sr_delivery_id
    , decode(mrt.planned_flag,1,'F',2,'Y',3,'N','N')
    , decode(mrt.status_code,1,'OP',2,'IT',3,'CL','OP')
    , mrt.pickup_date
    , mrt.pickup_location_id
    , mrt.dropoff_location_id
    , mrt.dropoff_date
    , mrt.customer_id
    , mrt.gross_weight
    , mrt.net_weight
    , mrt.weight_uom
    , mrt.volume
    , mrt.volume_uom
    , mrt.currency_uom
    , mrt.organization_id
    , mrt.shipment_direction
    , mrt.delivery_number
    , mrt.compile_designator
    , mrt.earliest_pickup_date
    , mrt.latest_pickup_date
    , mrt.earliest_acceptable_date
    , mrt.latest_acceptable_date
    , 'STANDARD'
    , g_tp_release_code
    , l_date
    , l_user
    , l_date
    , l_user
    , l_user
    from mst_release_temp_gt mrt
    where mrt.release_id = p_release_id
    and mrt.delivery_id is not null
    );

    insert into wsh_del_legs_interface
    ( delivery_leg_interface_id
    , delivery_leg_id
    , delivery_id
    , delivery_interface_id
    , sequence_number
    , pick_up_stop_id
    , pick_up_stop_interface_id
    , drop_off_stop_id
    , drop_off_stop_interface_id
    , gross_weight
    , net_weight
    , weight_uom_code
    , volume
    , volume_uom_code
    , interface_action_code
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    )
    (
    select wsh_del_legs_interface_s.nextval
    , mdl.sr_delivery_leg_id
    , mrt1.sr_delivery_id
    , mrt1.delivery_id_iface
    , mdl.sequence_number
    , mrt2.sr_stop_id
    , mrt2.stop_id_iface
    , mrt3.sr_stop_id
    , mrt3.stop_id_iface
    , mrt1.gross_weight
    , mrt1.net_weight
    , mrt1.weight_uom
    , mrt1.volume
    , mrt1.volume_uom
    , g_tp_release_code
    , l_date
    , l_user
    , l_date
    , l_user
    , l_user
    from mst_release_temp_gt mrt1
    , mst_release_temp_gt mrt2
    , mst_release_temp_gt mrt3
    , mst_delivery_legs mdl
    where mrt1.plan_id= mdl.plan_id
    and mrt1.delivery_id = mdl.delivery_id
    and mrt1.release_id = p_release_id
    and mrt2.stop_id = mdl.pick_up_stop_id
    and mrt2.release_id = p_release_id
    and mrt3.stop_id = mdl.drop_off_stop_id
    and mrt3.release_id = p_release_id
    );

--inserting the splitted TE lines
    insert into mst_release_temp_gt
    ( release_id
    , group_id
    , plan_id
    , sr_delivery_id
    , delivery_id_iface
    , sr_delivery_assignment_id
    , delivery_detail_id
    , delivery_detail_id_iface
    , sr_delivery_detail_id
    , source_code
    , customer_id
    , inventory_item_id
    , ship_from_location_id
    , ship_to_location_id
    , requested_quantity
    , gross_weight
    , net_weight
    , weight_uom
    , volume
    , volume_uom
    , source_header_number
    , ship_set_id
    , arrival_set_id
    , organization_id
    , org_id
    , container_flag
    , source_line_number
    , split_from_delivery_detail_id
    , earliest_pickup_date
    , latest_pickup_date
    , earliest_acceptable_date
    , latest_acceptable_date
    , line_direction
    , po_shipment_line_number
    , src_requested_quantity
    , src_requested_quantity_uom
    , supplier_id
    , party_id
    )
    (
    select p_release_id
    , mrt.group_id
    , mrt.plan_id
    , mrt.sr_delivery_id
    , mrt.delivery_id_iface
    , mda.sr_delivery_assignment_id
    , mda.delivery_detail_id
    , wsh_del_details_interface_s.nextval
    , mdd1.sr_delivery_detail_id
    , mdd.source_code
    , mdd.customer_id
    , mdd.inventory_item_id
    , mdd.ship_from_location_id
    , mdd.ship_to_location_id
    , mdd.requested_quantity
    , mdd.gross_weight
    , mdd.net_weight
    , mp.weight_uom
    , mdd.volume
    , mp.volume_uom
    , mdd.source_header_number
    , mdd.ship_set_id
    , mdd.arrival_set_id
    , mdd.organization_id
    , mdd.org_id
    , mdd.container_flag
    , mdd.source_line_number
    , mdd.split_from_delivery_detail_id
    , mdd.earliest_pickup_date
    , mdd.latest_pickup_date
    , mdd.earliest_acceptable_date
    , mdd.latest_acceptable_date
    , mdd.line_direction
    , mdd.po_shipment_line_number
    , mdd.src_requested_quantity
    , mdd.src_requested_quantity_uom
    , mdd.supplier_id
    , hzr.object_id
    from mst_plans mp
    , mst_release_temp_gt mrt
    , mst_delivery_assignments mda
    , mst_delivery_details mdd
    , mst_delivery_details mdd1
    , hz_relationships hzr
    where mrt.plan_id = mp.plan_id
    and mrt.plan_id = mda.plan_id
    and mrt.delivery_id = mda.delivery_id
    and mda.plan_id = mdd.plan_id
    and mda.delivery_detail_id = mdd.delivery_detail_id
    and mdd.plan_id = mdd1.plan_id
    and mdd.split_from_delivery_detail_id = mdd1.delivery_detail_id
    and mdd.split_from_delivery_detail_id is not null
    and mrt.release_id = p_release_id
    and hzr.relationship_type (+) = 'POS_VENDOR_PARTY'
    and hzr.object_table_name (+) = 'PO_VENDORS'
    and hzr.object_type (+) = 'POS_VENDOR'
    and hzr.subject_table_name (+) = 'HZ_PARTIES'
    and hzr.subject_type (+) = 'ORGANIZATION'
    and hzr.status (+) = 'A'
    and hzr.subject_id (+) = mdd.supplier_id
    );

--inserting the unsplitted TE lines
    insert into mst_release_temp_gt
    ( release_id
    , group_id
    , plan_id
    , sr_delivery_id
    , delivery_id_iface
    , sr_delivery_assignment_id
    , delivery_detail_id
    , delivery_detail_id_iface
    , sr_delivery_detail_id
    , source_code
    , customer_id
    , inventory_item_id
    , ship_from_location_id
    , ship_to_location_id
    , requested_quantity
    , gross_weight
    , net_weight
    , weight_uom
    , volume
    , volume_uom
    , source_header_number
    , ship_set_id
    , arrival_set_id
    , organization_id
    , org_id
    , container_flag
    , source_line_number
    , split_from_delivery_detail_id
    , earliest_pickup_date
    , latest_pickup_date
    , earliest_acceptable_date
    , latest_acceptable_date
    , line_direction
    , po_shipment_line_number
    , src_requested_quantity
    , src_requested_quantity_uom
    , supplier_id
    , party_id
    )
    (
    select p_release_id
    , mrt.group_id
    , mrt.plan_id
    , mrt.sr_delivery_id
    , mrt.delivery_id_iface
    , mda.sr_delivery_assignment_id
    , mda.delivery_detail_id
    , wsh_del_details_interface_s.nextval
    , mdd.sr_delivery_detail_id
    , mdd.source_code
    , mdd.customer_id
    , mdd.inventory_item_id
    , mdd.ship_from_location_id
    , mdd.ship_to_location_id
    , mdd.requested_quantity
    , mdd.gross_weight
    , mdd.net_weight
    , mp.weight_uom
    , mdd.volume
    , mp.volume_uom
    , mdd.source_header_number
    , mdd.ship_set_id
    , mdd.arrival_set_id
    , mdd.organization_id
    , mdd.org_id
    , mdd.container_flag
    , mdd.source_line_number
    , mdd.split_from_delivery_detail_id
    , mdd.earliest_pickup_date
    , mdd.latest_pickup_date
    , mdd.earliest_acceptable_date
    , mdd.latest_acceptable_date
    , mdd.line_direction
    , mdd.po_shipment_line_number
    , mdd.src_requested_quantity
    , mdd.src_requested_quantity_uom
    , mdd.supplier_id
    , hzr.object_id
    from mst_plans mp
    , mst_release_temp_gt mrt
    , mst_delivery_assignments mda
    , mst_delivery_details mdd
    , hz_relationships hzr
    where mrt.plan_id = mp.plan_id
    and mrt.plan_id = mda.plan_id
    and mrt.delivery_id = mda.delivery_id
    and mda.plan_id = mdd.plan_id
    and mda.delivery_detail_id = mdd.delivery_detail_id
    and mdd.split_from_delivery_detail_id is null
    and mrt.release_id = p_release_id
    and hzr.relationship_type (+) = 'POS_VENDOR_PARTY'
    and hzr.object_table_name (+) = 'PO_VENDORS'
    and hzr.object_type (+) = 'POS_VENDOR'
    and hzr.subject_table_name (+) = 'HZ_PARTIES'
    and hzr.subject_type (+) = 'ORGANIZATION'
    and hzr.status (+) = 'A'
    and hzr.subject_id (+) = mdd.supplier_id
    );

    insert into wsh_del_assgn_interface
    ( del_assgn_interface_id
    , delivery_assignment_id
    , delivery_interface_id
    , delivery_id
    , delivery_detail_interface_id
    , delivery_detail_id
    , interface_action_code
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    )
    (
    select wsh_del_assgn_interface_s.nextval
    , null -- mrt.sr_delivery_assignment_id commented as not need in TE (william)
    , mrt.delivery_id_iface
    , mrt.sr_delivery_id
    , mrt.delivery_detail_id_iface
    , mrt.sr_delivery_detail_id
    , g_tp_release_code
    , l_date
    , l_user
    , l_date
    , l_user
    , l_user
    from mst_release_temp_gt mrt
    where mrt.release_id = p_release_id
    and mrt.delivery_detail_id_iface is not null
    );

    insert into wsh_del_details_interface
    ( delivery_detail_interface_id
    , delivery_detail_id
    , source_code
    , customer_id
    , inventory_item_id
    , ship_from_location_id
    , ship_to_location_id
    , requested_quantity
    , gross_weight
    , net_weight
    , weight_uom_code
    , volume
    , volume_uom_code
    , source_header_number
    , ship_set_id
    , arrival_set_id
    , organization_id
    , org_id
    , source_line_id
    , container_flag
    , source_line_number
    , split_from_delivery_detail_id
    , earliest_pickup_date
    , latest_pickup_date
    , earliest_dropoff_date
    , latest_dropoff_date
    , tp_delivery_detail_id
    , line_direction
    , po_shipment_line_number
    , requested_quantity_uom
    , source_header_id
    , source_line_set_id
    , src_requested_quantity
    , src_requested_quantity_uom
    , requested_quantity2
    , requested_quantity_uom2
    , src_requested_quantity2
    , src_requested_quantity_uom2
    , interface_action_code
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    )
    (
    select mrt.delivery_detail_id_iface --wsh_del_details_interface_s.nextval
    , mrt.sr_delivery_detail_id
    , mrt.source_code
    , mrt.customer_id
    , mrt.inventory_item_id
    , mrt.ship_from_location_id
    , mrt.ship_to_location_id
    , mrt.requested_quantity
    , mrt.gross_weight
    , mrt.net_weight
    , mrt.weight_uom
    , mrt.volume
    , mrt.volume_uom
    , mrt.source_header_number
    , mrt.ship_set_id
    , mrt.arrival_set_id
    , mrt.organization_id
    , mrt.org_id
    , nvl(wdd.source_line_id,FND_API.G_MISS_NUM)
    , decode(mrt.container_flag,1,'Y','N')
    , mrt.source_line_number
    , mrt.split_from_delivery_detail_id
    , mrt.earliest_pickup_date
    , mrt.latest_pickup_date
    , mrt.earliest_acceptable_date
    , mrt.latest_acceptable_date
    , mrt.delivery_detail_id
    , decode(mrt.line_direction,1,'I',2,'O',3,'D',4,'IO','O')
    , mrt.po_shipment_line_number
    , wdd.requested_quantity_uom
    , wdd.source_header_id
    , wdd.source_line_set_id
    , mrt.src_requested_quantity
    , mrt.src_requested_quantity_uom
    , wdd.requested_quantity2
    , wdd.requested_quantity_uom2
    , wdd.src_requested_quantity2
    , wdd.src_requested_quantity_uom2
    , g_tp_release_code
    , l_date
    , l_user
    , l_date
    , l_user
    , l_user
    from mst_release_temp_gt mrt
    , wsh_delivery_details wdd
    where mrt.release_id = p_release_id
    and mrt.sr_delivery_detail_id = wdd.delivery_detail_id (+)
    and mrt.delivery_detail_id is not null
    );

    update_ids_in_wdd_iface_tab (p_release_id);
    update_loc_id_in_iface_tab (p_release_id);

    x_return_status := fnd_api.g_ret_sts_success;
    print_info(g_log_flow_of_control,'populate_interface_tables : Program ended');
  exception
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      print_info(g_log_flow_of_control,'populate_interface_tables : Unexpected error ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end populate_interface_tables;

  procedure update_mst_cm_trips (x_return_status out nocopy varchar2
                               , p_group_id      in         pls_integer
                               , p_plan_id       in         number
                               , p_release_id    in         pls_integer
                               , p_release_mode  in         number
                               , p_date          in         date
                               , p_error_found   in         number) is

    --cursor to retrieve the continuous moves in a group to update TP tables
    cursor cur_continuous_moves (l_release_id in pls_integer, l_group_id in pls_integer)
    is
    select continuous_move_id, planned_flag
    from mst_release_temp_gt
    where release_id = l_release_id
    and group_id = l_group_id
    and continuous_move_id is not null;

    l_continuous_move_id_tab number_tab_type;
    l_planned_flag_tab number_tab_type;

    l_release_mode pls_integer := nvl(p_release_mode,2);
    l_plan_id number := p_plan_id;
    l_date date := p_date;
  begin
    print_info(g_log_flow_of_control,'update_mst_cm_trips for group '||p_group_id||' : Program started');

    open cur_continuous_moves(p_release_id, p_group_id);
    fetch cur_continuous_moves bulk collect into l_continuous_move_id_tab, l_planned_flag_tab;
    close cur_continuous_moves;

    if nvl(l_continuous_move_id_tab.last,0) > 0 then
      if p_error_found = 0 then -- group was successful
        forall i in 1..l_continuous_move_id_tab.last
        update mst_cm_trips
        set planned_flag = l_planned_flag_tab(i)
        , release_status = l_planned_flag_tab(i)
        , release_date = l_date -- sysdate since successful
        , auto_release_flag = l_release_mode
        , selected_for_release = null
        where plan_id = l_plan_id
        and continuous_move_id = l_continuous_move_id_tab(i);
        g_cnt_cm_released := g_cnt_cm_released + nvl(l_continuous_move_id_tab.last,0);
      else -- group was not successful
        forall i in 1..l_continuous_move_id_tab.last
        update mst_cm_trips
        set release_status = 3 -- failed
        , release_date = l_date -- datetime at start of process since unsuccessful
        , auto_release_flag = l_release_mode
        , selected_for_release = null
        where plan_id = l_plan_id
        and continuous_move_id = l_continuous_move_id_tab(i);
        g_cnt_cm_failed := g_cnt_cm_failed + nvl(l_continuous_move_id_tab.last,0);
      end if;
    end if;

    x_return_status := fnd_api.g_ret_sts_success;
    print_info(g_log_flow_of_control,'update_mst_cm_trips for group '||p_group_id||' : Program ended');
  exception
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      print_info(g_log_flow_of_control,'update_mst_cm_trips : Unexpected error ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end update_mst_cm_trips;

  function get_statistics (p_release_id   in number
                         , p_plan_id      in number
                         , p_group_id     in number
                         , p_mode_or_type in varchar2) return number is

    --cursor to count trips of a certain mode of transport in a group
    cursor cur_trips_mode (l_release_id in pls_integer, l_group_id in pls_integer, l_mode_of_transport in varchar2)
    is
    select count(1)
    from mst_release_temp_gt
    where release_id = l_release_id
    and group_id = l_group_id
    and trip_id is not null
    and mode_of_transport = l_mode_of_transport;

    --cursor to count deadhead trips in a group
    cursor cur_deadheads (l_release_id in pls_integer, l_plan_id in pls_integer, l_group_id in pls_integer)
    is
    select count(1)
    from mst_release_temp_gt mrt_gt
    where mrt_gt.release_id = l_release_id
    and mrt_gt.group_id = l_group_id
    and mrt_gt.plan_id = l_plan_id
    and mrt_gt.trip_id is not null
    and mrt_gt.cm_id_of_trip is not null
    and mrt_gt.trip_id not in (select mdl.trip_id
                               from mst_delivery_legs mdl
                               where mdl.plan_id = l_plan_id);

    l_count pls_integer := 0;

  begin
    if p_mode_or_type = 'DEADHEAD' then
      open cur_deadheads(p_release_id, p_plan_id, p_group_id);
      fetch cur_deadheads into l_count;
      close cur_deadheads;
    else -- for TRUCK, LTL, PARCEL
      open cur_trips_mode(p_release_id, p_group_id, p_mode_or_type);
      fetch cur_trips_mode into l_count;
      close cur_trips_mode;
    end if;

    return nvl(l_count,0);
  exception
    when others then
      return 0;
  end get_statistics;

  procedure update_mst_trips (x_return_status out nocopy varchar2
                            , p_group_id      in         pls_integer
                            , p_plan_id       in         number
                            , p_release_id    in         pls_integer
                            , p_release_mode  in         number
                            , p_date          in         date
                            , p_error_found   in         number) is

    --cursor to retrieve the trips in a group to update TP tables
    cursor cur_trips (l_release_id in pls_integer, l_group_id in pls_integer)
    is
    select trip_id, planned_flag
    from mst_release_temp_gt
    where release_id = l_release_id
    and group_id = l_group_id
    and trip_id is not null;

    l_trip_id_tab number_tab_type;
    l_planned_flag_tab number_tab_type;

    l_release_mode pls_integer := nvl(p_release_mode,2);
    l_plan_id number := p_plan_id;
    l_date date := p_date;
  begin
    print_info(g_log_flow_of_control,'update_mst_trips for group '||p_group_id||' : Program started');

    open cur_trips(p_release_id, p_group_id);
    fetch cur_trips bulk collect into l_trip_id_tab, l_planned_flag_tab;
    close cur_trips;

    if nvl(l_trip_id_tab.last,0) > 0 then
      if p_error_found = 0 then -- group was successful
        forall i in 1..l_trip_id_tab.last
        update mst_trips
        set planned_flag = l_planned_flag_tab(i)
        , release_status = l_planned_flag_tab(i)
        , release_date = l_date
        , auto_release_flag = l_release_mode
        , selected_for_release = null
        where plan_id = l_plan_id
        and trip_id = l_trip_id_tab(i);
        g_cnt_trip_released := g_cnt_trip_released + nvl(l_trip_id_tab.last,0);

        g_cnt_truck_released := g_cnt_truck_released + get_statistics(p_release_id, p_plan_id, p_group_id, 'TRUCK');
        g_cnt_ltl_released := g_cnt_ltl_released + get_statistics(p_release_id, p_plan_id, p_group_id, 'LTL');
        g_cnt_parcel_released := g_cnt_parcel_released + get_statistics(p_release_id, p_plan_id, p_group_id, 'PARCEL');
        g_cnt_deadhead_released := g_cnt_deadhead_released + get_statistics(p_release_id, p_plan_id, p_group_id, 'DEADHEAD');

      else -- group was not successful
        forall i in 1..l_trip_id_tab.last
        update mst_trips
        set release_status = 4
        , release_date = l_date -- datetime at start process, it is coming as parameter to this procedure
        , auto_release_flag = l_release_mode
        , selected_for_release = null
        where plan_id = l_plan_id
        and trip_id = l_trip_id_tab(i) ;
        g_cnt_trip_failed := g_cnt_trip_failed + nvl(l_trip_id_tab.last,0);

        g_cnt_truck_failed := g_cnt_truck_failed + get_statistics(p_release_id, p_plan_id, p_group_id, 'TRUCK');
        g_cnt_ltl_failed := g_cnt_ltl_failed + get_statistics(p_release_id, p_plan_id, p_group_id, 'LTL');
        g_cnt_parcel_failed := g_cnt_parcel_failed + get_statistics(p_release_id, p_plan_id, p_group_id, 'PARCEL');
        g_cnt_deadhead_failed := g_cnt_deadhead_failed + get_statistics(p_release_id, p_plan_id, p_group_id, 'DEADHEAD');
      end if;
    end if;

    x_return_status := fnd_api.g_ret_sts_success;
    print_info(g_log_flow_of_control,'update_mst_trips for group '||p_group_id||' : Program ended');
  exception
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      print_info(g_log_flow_of_control,'update_mst_trips : Unexpected error ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end update_mst_trips;

  procedure update_mst_deliveries (x_return_status out nocopy varchar2
                                 , p_group_id      in         pls_integer
                                 , p_plan_id       in         number
                                 , p_release_id    in         pls_integer
                                 , p_error_found   in         pls_integer) is

    --cursor to retrieve the deliveries in a group to update TP tables
    cursor cur_deliveries (l_release_id in pls_integer, l_group_id in pls_integer)
    is
    select delivery_id, planned_flag
    from mst_release_temp_gt
    where release_id = l_release_id
    and group_id = l_group_id
    and delivery_id is not null;

    l_delivery_id_tab number_tab_type;
    l_planned_flag_tab number_tab_type;

    l_error_found pls_integer := p_error_found;
    l_plan_id number := p_plan_id;
  begin
    print_info(g_log_flow_of_control,'update_mst_deliveries for group '||p_group_id||' : Program started');
    if l_error_found = 0 then
      open cur_deliveries(p_release_id, p_group_id);
      fetch cur_deliveries bulk collect into l_delivery_id_tab, l_planned_flag_tab;
      close cur_deliveries;

      if nvl(l_delivery_id_tab.last,0) > 0 then
        forall i in 1..l_delivery_id_tab.last
        update mst_deliveries  -- remember l_error_found = 0 => successful and l_error_found = 1 => unsuccessful
        set planned_flag = decode(l_planned_flag_tab(i),1,1,2)
        , preserve_grouping_flag = decode(l_planned_flag_tab(i),1,null,2,1,2)
        , known_te_firm_status = l_planned_flag_tab(i)
        where plan_id = l_plan_id
        and delivery_id = l_delivery_id_tab(i);
      end if;
    end if;

    x_return_status := fnd_api.g_ret_sts_success;
    print_info(g_log_flow_of_control,'update_mst_deliveries for group '||p_group_id||' : Program ended');
  exception
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      print_info(g_log_flow_of_control,'update_mst_deliveries : Unexpected error ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end update_mst_deliveries;

  procedure update_sr_ids_in_mt (x_return_status out nocopy varchar2
                               , p_group_id      in         pls_integer
                               , p_plan_id       in         number
                               , p_release_id    in         pls_integer
                               , p_error_found   in         pls_integer) is

    --cursor to retrieve the trips in a group to update mst_trips
    cursor cur_trips (l_release_id in pls_integer, l_group_id in pls_integer)
    is
    select mrt.trip_id, wti.trip_id
    from mst_release_temp_gt mrt
    , wsh_trips_interface wti
    where mrt.release_id = l_release_id
    and mrt.group_id = l_group_id
    and mrt.trip_id is not null
    and mrt.trip_id_iface = wti.trip_interface_id;

    l_trip_id_tab    number_tab_type;
    l_sr_trip_id_tab number_tab_type;

    l_error_found pls_integer := p_error_found;
    l_plan_id number := p_plan_id;
  begin
    print_info(g_log_flow_of_control,'update_sr_ids_in_mt for group '||p_group_id||' : Program started');
    if l_error_found = 0 then -- remember l_error_found = 0 => successful and l_error_found = 1 => unsuccessful
      open cur_trips(p_release_id, p_group_id);
      fetch cur_trips bulk collect into l_trip_id_tab, l_sr_trip_id_tab;
      close cur_trips;

      if nvl(l_trip_id_tab.last,0) > 0 then
        forall i in 1..l_trip_id_tab.last
        update mst_trips
        set sr_trip_id = l_sr_trip_id_tab(i)
        where plan_id = l_plan_id
        and trip_id = l_trip_id_tab(i);
      end if;
    end if;

    x_return_status := fnd_api.g_ret_sts_success;
    print_info(g_log_flow_of_control,'update_sr_ids_in_mt for group '||p_group_id||' : Program ended');
  exception
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      print_info(g_log_flow_of_control,'update_sr_ids_in_mt : Unexpected error ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end update_sr_ids_in_mt;

  procedure update_sr_ids_in_md (x_return_status out nocopy varchar2
                               , p_group_id      in         pls_integer
                               , p_plan_id       in         number
                               , p_release_id    in         pls_integer
                               , p_error_found   in         pls_integer) is

    --cursor to retrieve the trips in a group to update mst_trips
    cursor cur_deliveries (l_release_id in pls_integer, l_group_id in pls_integer)
    is
    select mrt.delivery_id, wndi.delivery_id
    from mst_release_temp_gt mrt
    , wsh_new_del_interface wndi
    where mrt.release_id = l_release_id
    and mrt.group_id = l_group_id
    and mrt.delivery_id is not null
    and mrt.delivery_id_iface = wndi.delivery_interface_id;

    l_delivery_id_tab    number_tab_type;
    l_sr_delivery_id_tab number_tab_type;

    l_error_found pls_integer := p_error_found;
    l_plan_id number := p_plan_id;
  begin
    print_info(g_log_flow_of_control,'update_sr_ids_in_md for group '||p_group_id||' : Program started');
    if l_error_found = 0 then -- remember l_error_found = 0 => successful and l_error_found = 1 => unsuccessful
      open cur_deliveries(p_release_id, p_group_id);
      fetch cur_deliveries bulk collect into l_delivery_id_tab, l_sr_delivery_id_tab;
      close cur_deliveries;

      if nvl(l_delivery_id_tab.last,0) > 0 then
        forall i in 1..l_delivery_id_tab.last
        update mst_deliveries
        set sr_delivery_id = l_sr_delivery_id_tab(i)
        where plan_id = l_plan_id
        and delivery_id = l_delivery_id_tab(i);
      end if;
    end if;

    x_return_status := fnd_api.g_ret_sts_success;
    print_info(g_log_flow_of_control,'update_sr_ids_in_md for group '||p_group_id||' : Program ended');
  exception
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      print_info(g_log_flow_of_control,'update_sr_ids_in_md : Unexpected error ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end update_sr_ids_in_md;

  procedure update_sr_ids_in_mdd (x_return_status out nocopy varchar2
                                , p_group_id      in         pls_integer
                                , p_plan_id       in         number
                                , p_release_id    in         pls_integer
                                , p_error_found   in         pls_integer) is

    --cursor to retrieve the trips in a group to update mst_trips
    cursor cur_delivery_details (l_release_id in pls_integer, l_group_id in pls_integer)
    is
    select mrt.delivery_detail_id, wddi.delivery_detail_id
    from mst_release_temp_gt mrt
    , wsh_del_details_interface wddi
    where mrt.release_id = l_release_id
    and mrt.group_id = l_group_id
    and mrt.delivery_detail_id is not null
    and mrt.delivery_detail_id_iface = wddi.delivery_detail_interface_id;

    l_delivery_detail_id_tab    number_tab_type;
    l_sr_delivery_detail_id_tab number_tab_type;

    l_error_found pls_integer := p_error_found;
    l_plan_id number := p_plan_id;
  begin
    print_info(g_log_flow_of_control,'update_sr_ids_in_mdd for group '||p_group_id||' : Program started');
    if l_error_found = 0 then -- remember l_error_found = 0 => successful and l_error_found = 1 => unsuccessful
      open cur_delivery_details(p_release_id, p_group_id);
      fetch cur_delivery_details bulk collect into l_delivery_detail_id_tab, l_sr_delivery_detail_id_tab;
      close cur_delivery_details;

      if nvl(l_delivery_detail_id_tab.last,0) > 0 then
        forall i in 1..l_delivery_detail_id_tab.last
        update mst_delivery_details
        set sr_delivery_detail_id = l_sr_delivery_detail_id_tab(i)
        where plan_id = l_plan_id
        and delivery_detail_id = l_delivery_detail_id_tab(i);
      end if;
    end if;

    x_return_status := fnd_api.g_ret_sts_success;
    print_info(g_log_flow_of_control,'update_sr_ids_in_mdd for group '||p_group_id||' : Program ended');
  exception
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      print_info(g_log_flow_of_control,'update_sr_ids_in_mdd : Unexpected error ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end update_sr_ids_in_mdd;

  procedure update_tp_tables (x_return_status      out nocopy varchar2
                            , p_group_tab          in         wsh_tp_release_grp.id_tab_type
                            , p_plan_id            in         number
                            , p_release_id         in         pls_integer
                            , p_release_mode       in         number
                            , p_release_start_date in         date) is

    --cursor to check whether a group_id has failed or successful
    cursor cur_check_error (l_group_id in pls_integer)
    is
    select 1
    from wsh_interface_errors wie
    where wie.interface_error_group_id = l_group_id
    and wie.interface_action_code = wsh_tp_release_grp.G_TP_RELEASE_CODE;

    --cursor to log error message into log file after pulling from wsh_interface_errors
    cursor cur_log_error (l_group_id in pls_integer)
    is
    select error_message
    from wsh_interface_errors wie
    where wie.interface_error_group_id = l_group_id
    and wie.interface_action_code = wsh_tp_release_grp.G_TP_RELEASE_CODE
    order by wie.interface_error_id;

    l_dummy pls_integer;
    l_error_found pls_integer := 0;
    l_date date;

    type varchar2_tab_type is table of varchar2(4000) index by binary_integer;
    l_message_tab varchar2_tab_type;

    l_return_status varchar2(1);
    l_error_from_called_procedure exception;
    l_Message_Text varchar2(1000);
  begin
    print_info(g_log_flow_of_control,'update_tp_tables : Program started');

    if nvl(p_group_tab.last,0) > 0 then
      for i in 1..p_group_tab.last loop
        -- check for error for current group_id
        open cur_check_error(p_group_tab(i));
        fetch cur_check_error into l_dummy;
        if cur_check_error%notfound then
          l_error_found := 0; -- release was successful
          select sysdate
          into l_date
          from dual;
          g_cnt_group_released := g_cnt_group_released + 1;
        else
          l_error_found := 1; -- release was failed
          l_date := p_release_start_date; -- release start datetime
          g_cnt_group_failed := g_cnt_group_failed + 1;
        end if;
        close cur_check_error;

        update_mst_cm_trips (l_return_status, p_group_tab(i), p_plan_id, p_release_id, p_release_mode, l_date, l_error_found);
        if l_return_status <> fnd_api.g_ret_sts_success then
          raise l_error_from_called_procedure;
        else
          update_mst_trips (l_return_status, p_group_tab(i), p_plan_id, p_release_id, p_release_mode, l_date, l_error_found);
          if l_return_status <> fnd_api.g_ret_sts_success then
            raise l_error_from_called_procedure;
          else
            if l_error_found = 0 then -- if successful only proceed
              update_mst_deliveries (l_return_status, p_group_tab(i), p_plan_id, p_release_id, l_error_found);
              if l_return_status <> fnd_api.g_ret_sts_success then
                raise l_error_from_called_procedure;
              else
                update_sr_ids_in_mt (l_return_status, p_group_tab(i), p_plan_id, p_release_id, l_error_found);
                if l_return_status <> fnd_api.g_ret_sts_success then
                  raise l_error_from_called_procedure;
                else
                  update_sr_ids_in_md (l_return_status, p_group_tab(i), p_plan_id, p_release_id, l_error_found);
                  if l_return_status <> fnd_api.g_ret_sts_success then
                    raise l_error_from_called_procedure;
                  else
                    update_sr_ids_in_mdd (l_return_status, p_group_tab(i), p_plan_id, p_release_id, l_error_found);
                    if l_return_status <> fnd_api.g_ret_sts_success then
                      raise l_error_from_called_procedure;
                    end if;
                  end if;
                end if;
              end if;
            end if;
          end if;
        end if;

        -- log error messages into log file
        if l_error_found = 1 then -- release was failed
          open cur_log_error(p_group_tab(i));
          fetch cur_log_error bulk collect into l_message_tab;
          close cur_log_error;
          if nvl(l_message_tab.last,0) > 0 then
            --print_info(g_log_must_message,'Group '||p_group_tab(i)||' failed');
            fnd_message.set_name('MST','MST_REL_BK_MESSAGE_35');
            fnd_message.set_token('N1',to_char(p_group_tab(i)));
            l_Message_Text := fnd_message.get;
            print_info(g_log_must_message,l_Message_Text);
            for j in 1..l_message_tab.last loop
              print_info(g_log_must_message,' '||l_message_tab(j));
            end loop;
            log_group_trip_data(g_log_failed_data,p_group_tab(i),'[ failed ]');
          end if;
        else
          --print_info(g_log_released_data,'Group '||p_group_tab(i)||' released');
          fnd_message.set_name('MST','MST_REL_BK_MESSAGE_36');
          fnd_message.set_token('N1',to_char(p_group_tab(i)));
          l_Message_Text := fnd_message.get;
          print_info(g_log_must_message,l_Message_Text);
          log_group_trip_data(g_log_released_data,p_group_tab(i),'[ released ]');
        end if;
      end loop;
    end if;

    x_return_status := fnd_api.g_ret_sts_success;
    print_info(g_log_flow_of_control,'update_tp_tables : Program ended');
  exception
    when l_error_from_called_procedure then
      x_return_status := fnd_api.g_ret_sts_error;
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      print_info(g_log_flow_of_control,'update_tp_tables : Unexpected error ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end update_tp_tables;

  procedure pull_into_global_temp_table (x_return_status out nocopy varchar2
                                       , p_release_id    in         number) is
  begin
    print_info(g_log_flow_of_control,'pull_into_global_temp_table : Program started');
    insert into mst_release_temp_gt
    ( release_id
    , group_id
    , plan_id
    , trip_id
    , trip_number
    , planned_flag
    , release_status
    , trip_start_date
    , cm_id_of_trip
    , continuous_move_id
    , delivery_id
    , out_of_scope
    , trip_process_flag
    , selected_trips
    , trip_id_iface
    , continuous_move_id_iface
    , delivery_id_iface
    , stop_id_iface
    , continuous_move_sequence
    , sr_cm_trip_id
    , sr_trip_id
    , stop_id
    , sr_delivery_id
    , delivery_detail_id_iface
    , delivery_detail_id
    , sr_delivery_detail_id
    , sr_delivery_assignment_id
    , sr_stop_id, status_code
    , pickup_date
    , dropoff_date
    , pickup_location_id
    , dropoff_location_id
    , customer_id
    , gross_weight
    , net_weight
    , weight_uom
    , volume
    , volume_uom
    , currency_uom
    , organization_id
    , delivery_number
    , compile_designator
    , earliest_pickup_date
    , latest_pickup_date
    , earliest_acceptable_date
    , latest_acceptable_date
    , inventory_item_id
    , carrier_id
    , ship_method_code
    , mode_of_transport
    , load_tender_status
    , lane_id, service_level
    , cm_trip_number
    , stop_location_id
    , stop_sequence_number
    , planned_arrival_date
    , planned_departure_date
    , departure_gross_weight
    , departure_net_weight
    , departure_volume
    , departure_fill_percent
    , wkend_layover_stops
    , wkday_layover_stops
    , distance_to_next_stop
    , pln_loading_start_time
    , pln_loading_end_time
    , pln_unloading_start_time
    , pln_unloading_end_time
    , source_code
    , ship_from_location_id
    , ship_to_location_id
    , requested_quantity
    , source_header_number
    , ship_set_id
    , arrival_set_id
    , org_id
    , container_flag
    , source_line_number
    , split_from_delivery_detail_id
    , line_direction
    , po_shipment_number
    , po_shipment_line_number
    , src_requested_quantity_uom
    , src_requested_quantity
    , shipment_direction
    , supplier_id
    , party_id
    )
    (
    select release_id
    , group_id
    , plan_id
    , trip_id
    , trip_number
    , planned_flag
    , release_status
    , trip_start_date
    , cm_id_of_trip
    , continuous_move_id
    , delivery_id
    , out_of_scope
    , trip_process_flag
    , selected_trips
    , trip_id_iface
    , continuous_move_id_iface
    , delivery_id_iface
    , stop_id_iface
    , continuous_move_sequence
    , sr_cm_trip_id
    , sr_trip_id
    , stop_id
    , sr_delivery_id
    , delivery_detail_id_iface
    , delivery_detail_id
    , sr_delivery_detail_id
    , sr_delivery_assignment_id
    , sr_stop_id, status_code
    , pickup_date
    , dropoff_date
    , pickup_location_id
    , dropoff_location_id
    , customer_id
    , gross_weight
    , net_weight
    , weight_uom
    , volume
    , volume_uom
    , currency_uom
    , organization_id
    , delivery_number
    , compile_designator
    , earliest_pickup_date
    , latest_pickup_date
    , earliest_acceptable_date
    , latest_acceptable_date
    , inventory_item_id
    , carrier_id
    , ship_method_code
    , mode_of_transport
    , load_tender_status
    , lane_id, service_level
    , cm_trip_number
    , stop_location_id
    , stop_sequence_number
    , planned_arrival_date
    , planned_departure_date
    , departure_gross_weight
    , departure_net_weight
    , departure_volume
    , departure_fill_percent
    , wkend_layover_stops
    , wkday_layover_stops
    , distance_to_next_stop
    , pln_loading_start_time
    , pln_loading_end_time
    , pln_unloading_start_time
    , pln_unloading_end_time
    , source_code
    , ship_from_location_id
    , ship_to_location_id
    , requested_quantity
    , source_header_number
    , ship_set_id
    , arrival_set_id
    , org_id
    , container_flag
    , source_line_number
    , split_from_delivery_detail_id
    , line_direction
    , po_shipment_number
    , po_shipment_line_number
    , src_requested_quantity_uom
    , src_requested_quantity
    , shipment_direction
    , supplier_id
    , party_id
    from mst_release_temp
    where release_id = p_release_id
    );

    x_return_status := fnd_api.g_ret_sts_success;
    print_info(g_log_flow_of_control,'pull_into_global_temp_table : Program ended');
  exception
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      print_info(g_log_flow_of_control,'pull_into_global_temp_table : Unexpected error ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end pull_into_global_temp_table;

  procedure compute_statistics (x_return_status out nocopy varchar2
                              , p_plan_id    in number
                              , p_release_id in number) is

    -- cursor to compute the count of unattempted group
    cursor cur_group_counts (l_plan_id in number, l_release_id in number)
    is
    select count(distinct mrt_gt.group_id)
    from mst_release_temp_gt mrt_gt
    where mrt_gt.release_id = l_release_id
    and mrt_gt.plan_id = l_plan_id
    and mrt_gt.trip_id is not null
    and mrt_gt.planned_flag in (-1111,-2222,-3333,-4444,-5555);

    -- cursor to compute the count of unattempted trips, tls, ltls and parcels
    cursor cur_trip_counts (l_plan_id in number, l_release_id in number, l_mode_of_transport in varchar2)
    is
    select count(1)
    from mst_release_temp_gt mrt_gt
    where mrt_gt.release_id = l_release_id
    and mrt_gt.plan_id = l_plan_id
    and mrt_gt.trip_id is not null
    and mrt_gt.planned_flag in (-1111,-2222,-3333,-4444,-5555)
    and mrt_gt.mode_of_transport = l_mode_of_transport;

    -- cursor to compute the count of unattempted deadheads
    cursor cur_deadhead_counts (l_plan_id in number, l_release_id in number)
    is
    select count(1)
    from mst_release_temp_gt mrt_gt
    where mrt_gt.release_id = l_release_id
    and mrt_gt.trip_id is not null
    and mrt_gt.planned_flag in (-1111,-2222,-3333,-4444,-5555)
    and mrt_gt.cm_id_of_trip is not null
    and mrt_gt.trip_id not in (select mdl.trip_id
                               from mst_delivery_legs mdl
                               where plan_id = l_plan_id);

    -- cursor to compute the count of unattempted empty trips which are not part of any continuous move
    cursor cur_non_cm_empty_trip_counts (l_plan_id in number, l_release_id in number)
    is
    select count(1)
    from mst_release_temp_gt mrt_gt
    where mrt_gt.release_id = l_release_id
    and mrt_gt.trip_id is not null
    and mrt_gt.planned_flag in (-1111,-2222,-3333,-4444,-5555)
    and mrt_gt.cm_id_of_trip is null
    and mrt_gt.trip_id not in (select mdl.trip_id
                               from mst_delivery_legs mdl
                               where plan_id = l_plan_id);

    -- cursor to compute the statistics of unattempted empty trips
    cursor cur_statistics_of_unattempted (l_plan_id in number, l_release_id in number)
    is
    select mrt_gt.planned_flag, count(*)
    from mst_release_temp_gt mrt_gt
    where mrt_gt.release_id = l_release_id
    and mrt_gt.trip_id is not null
    and mrt_gt.planned_flag in (-1111,-2222,-3333,-4444,-5555)
    group by mrt_gt.planned_flag;

    l_planned_flag_tab number_tab_type;
    l_count_tab        number_tab_type;
    l_Message_Text     varchar2(1000);
  begin
    print_info(g_log_flow_of_control,'compute_statistics : Program started');
    open cur_group_counts (p_plan_id, p_release_id);
    fetch cur_group_counts into g_cnt_group_not_attempted;
    close cur_group_counts;

    open cur_trip_counts (p_plan_id, p_release_id, 'TRUCK');
    fetch cur_trip_counts into g_cnt_truck_not_attempted;
    close cur_trip_counts;

    open cur_trip_counts (p_plan_id, p_release_id, 'LTL');
    fetch cur_trip_counts into g_cnt_ltl_not_attempted;
    close cur_trip_counts;

    open cur_trip_counts (p_plan_id, p_release_id, 'PARCEL');
    fetch cur_trip_counts into g_cnt_parcel_not_attempted;
    close cur_trip_counts;

    g_cnt_trip_not_attempted := g_cnt_truck_not_attempted + g_cnt_ltl_not_attempted + g_cnt_parcel_not_attempted;

    open cur_deadhead_counts (p_plan_id, p_release_id);
    fetch cur_deadhead_counts into g_cnt_deadhead_not_attempted;
    close cur_deadhead_counts;

    open cur_non_cm_empty_trip_counts (p_plan_id, p_release_id);
    fetch cur_non_cm_empty_trip_counts into g_cnt_etrip_not_attempted;
    close cur_non_cm_empty_trip_counts;

    open cur_statistics_of_unattempted (p_plan_id, p_release_id);
    fetch cur_statistics_of_unattempted bulk collect into l_planned_flag_tab, l_count_tab;
    close cur_statistics_of_unattempted;

    if nvl(l_planned_flag_tab.last,0) >= 1 then
      for i in 1..l_planned_flag_tab.last loop
        if l_planned_flag_tab(i) = -1111 then
          fnd_message.set_name('MST','MST_REL_BK_MESSAGE_53');
        elsif l_planned_flag_tab(i) = -2222 then
          fnd_message.set_name('MST','MST_REL_BK_MESSAGE_54');
        elsif l_planned_flag_tab(i) = -3333 then
          fnd_message.set_name('MST','MST_REL_BK_MESSAGE_55');
        elsif l_planned_flag_tab(i) = -4444 then
          fnd_message.set_name('MST','MST_REL_BK_MESSAGE_56');
        elsif l_planned_flag_tab(i) = -5555 then
          fnd_message.set_name('MST','MST_REL_BK_MESSAGE_57');
        end if;
        fnd_message.set_token('N1',to_char(l_count_tab(i)));
        l_Message_Text := fnd_message.get;
        print_info(g_log_must_message,l_Message_Text);
        print_info(g_log_must_message,'');
      end loop;
    end if;

    delete from mst_release_temp_gt mrt_gt
    where mrt_gt.release_id = p_release_id
    and mrt_gt.plan_id = p_plan_id
    and mrt_gt.planned_flag in (-1111,-2222,-3333,-4444,-5555);

    x_return_status := fnd_api.g_ret_sts_success;
    print_info(g_log_flow_of_control,'compute_statistics : Program ended');
  exception
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      print_info(g_log_flow_of_control,'compute_statistics : Unexpected error ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end compute_statistics;

  procedure do_release (p_plan_id      in         number
                      , p_release_id   in         number
                      , p_release_mode in         number) is

    cursor cur_check_trips (l_release_id in pls_integer)
    is
    select 1
    from mst_release_temp_gt
    where release_id = l_release_id;

    l_dummy pls_integer := null;

    l_group_tab wsh_tp_release_grp.id_tab_type;
    l_input_rec wsh_tp_release_grp.input_rec_type;
    l_output_rec wsh_tp_release_grp.output_rec_type;

    l_return_status varchar2(1);
    l_release_start_date date;
    l_Message_Text varchar2(1000);
  begin
    print_info(g_log_flow_of_control,'do_release : Release Id = ' ||p_release_id|| ' Program started');

    open cur_check_trips (p_release_id);
    fetch cur_check_trips into l_dummy;
    close cur_check_trips;

    if l_dummy is null then
      --print_info(g_log_must_message,'Not even a single trip was found to release.');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_37'));
      log_statistics;
      --set_concurrent_status('WARNING', 'Zero Groups attempted to release.');
      set_concurrent_status('WARNING', get_seeded_message('MST_REL_BK_MESSAGE_38'));
    else
      select sysdate
      into l_release_start_date
      from dual;

      remove_unqualified_trips(l_return_status, p_plan_id, p_release_id);
      if l_return_status = fnd_api.g_ret_sts_success then
        populate_related_trips(l_return_status, p_plan_id, p_release_id);
        if l_return_status = fnd_api.g_ret_sts_success then
          remove_grp_of_passed_dep_dt (l_return_status, p_release_id,l_release_start_date);
          if l_return_status = fnd_api.g_ret_sts_success then
            remove_grp_of_exceptions(l_return_status, p_plan_id, p_release_id, p_release_mode);
            if l_return_status = fnd_api.g_ret_sts_success then
              --remove_grp_of_unwanted_trip(l_return_status, p_plan_id, p_release_id, p_release_mode);
              compute_statistics (l_return_status, p_plan_id, p_release_id);
              if l_return_status = fnd_api.g_ret_sts_success then
                reset_grp_ids_in_sequence_of_1(l_return_status, l_group_tab, p_plan_id, p_release_id);
                if l_return_status = fnd_api.g_ret_sts_success then
                  populate_deliveries(l_return_status, p_release_id);
                  if l_return_status = fnd_api.g_ret_sts_success then
                    populate_interface_tables(l_return_status, p_release_id);
                    if l_return_status = fnd_api.g_ret_sts_success then
                      if g_apply_to_te = 1 then
                        print_info(g_log_flow_of_control,'g_apply_to_te : ' ||g_apply_to_te);
                        l_input_rec.ACTION_CODE := wsh_tp_release_grp.G_ACTION_RELEASE;
                        l_input_rec.COMMIT_FLAG := fnd_api.G_FALSE;

                        wsh_tp_release_grp.action( l_group_tab -- list of group ids created in release process above
                                                 , l_input_rec
                                                 , l_output_rec
                                                 , l_return_status);
                        -- l_return_status -> fnd_api.g_ret_sts_success ---> all group released to TE
                        -- l_return_status -> WSH_UTIL_CORE.G_RET_STS_WARNING ---> at least one group failed and at least one successful
                        -- l_return_status -> fnd_api.g_ret_sts_error ---> all groups failed
                        -- l_return_status -> fnd_api.g_ret_sts_unexp_error ---> unexpected error occured in TE
                      end if;
                      if l_return_status = fnd_api.g_ret_sts_unexp_error then
                        rollback;
                      else
                        if g_update_tp_tables = 1 then
                          print_info(g_log_flow_of_control,'g_update_tp_tables : ' ||g_update_tp_tables);
                          update_tp_tables (l_return_status, l_group_tab, p_plan_id, p_release_id, p_release_mode, l_release_start_date);
                          if l_return_status <> fnd_api.g_ret_sts_success then
                            rollback;
                          end if;
                        end if;
                        print_info(g_log_flow_of_control,'g_purge_interface_table : ' ||g_purge_interface_table);
                        if g_purge_interface_table = 1 then
                          l_input_rec.ACTION_CODE := wsh_tp_release_grp.G_ACTION_PURGE;
                          l_input_rec.COMMIT_FLAG := fnd_api.G_FALSE;

                          wsh_tp_release_grp.action( l_group_tab -- list of group ids created in release process above
                                                   , l_input_rec
                                                   , l_output_rec
                                                   , l_return_status);
                        end if;
                      end if;
                    end if;
                  end if;
                end if;
              end if;
            end if;
          end if;
        end if;
      end if;
      log_statistics;
      -- delete records of current release_id
      print_info(g_log_flow_of_control,'g_purge_mst_release_temp : ' ||g_purge_mst_release_temp);
      if g_release_data = 'TRIP' then
        delete from mst_release_temp
        where release_id = p_release_id;
      end if;
      if g_purge_mst_release_temp = 0 then
        insert into mst_release_temp
        ( release_id
        , group_id
        , plan_id
        , trip_id
        , trip_number
        , planned_flag
        , release_status
        , trip_start_date
        , cm_id_of_trip
        , continuous_move_id
        , delivery_id
        , out_of_scope
        , trip_process_flag
        , selected_trips
        , trip_id_iface
        , continuous_move_id_iface
        , delivery_id_iface
        , stop_id_iface
        , continuous_move_sequence
        , sr_cm_trip_id
        , sr_trip_id
        , stop_id
        , sr_delivery_id
        , delivery_detail_id_iface
        , delivery_detail_id
        , sr_delivery_detail_id
        , sr_delivery_assignment_id
        , sr_stop_id, status_code
        , pickup_date
        , dropoff_date
        , pickup_location_id
        , dropoff_location_id
        , customer_id
        , gross_weight
        , net_weight
        , weight_uom
        , volume
        , volume_uom
        , currency_uom
        , organization_id
        , delivery_number
        , compile_designator
        , earliest_pickup_date
        , latest_pickup_date
        , earliest_acceptable_date
        , latest_acceptable_date
        , inventory_item_id
        , carrier_id
        , ship_method_code
        , mode_of_transport
        , load_tender_status
        , lane_id, service_level
        , cm_trip_number
        , stop_location_id
        , stop_sequence_number
        , planned_arrival_date
        , planned_departure_date
        , departure_gross_weight
        , departure_net_weight
        , departure_volume
        , departure_fill_percent
        , wkend_layover_stops
        , wkday_layover_stops
        , distance_to_next_stop
        , pln_loading_start_time
        , pln_loading_end_time
        , pln_unloading_start_time
        , pln_unloading_end_time
        , source_code
        , ship_from_location_id
        , ship_to_location_id
        , requested_quantity
        , source_header_number
        , ship_set_id
        , arrival_set_id
        , org_id
        , container_flag
        , source_line_number
        , split_from_delivery_detail_id
        , line_direction
        , po_shipment_number
        , po_shipment_line_number
        , src_requested_quantity_uom
        , src_requested_quantity
        , shipment_direction
        , supplier_id
        , party_id
        )
        (
        select release_id
        , group_id
        , plan_id
        , trip_id
        , trip_number
        , planned_flag
        , release_status
        , trip_start_date
        , cm_id_of_trip
        , continuous_move_id
        , delivery_id
        , out_of_scope
        , trip_process_flag
        , selected_trips
        , trip_id_iface
        , continuous_move_id_iface
        , delivery_id_iface
        , stop_id_iface
        , continuous_move_sequence
        , sr_cm_trip_id
        , sr_trip_id
        , stop_id
        , sr_delivery_id
        , delivery_detail_id_iface
        , delivery_detail_id
        , sr_delivery_detail_id
        , sr_delivery_assignment_id
        , sr_stop_id, status_code
        , pickup_date
        , dropoff_date
        , pickup_location_id
        , dropoff_location_id
        , customer_id
        , gross_weight
        , net_weight
        , weight_uom
        , volume
        , volume_uom
        , currency_uom
        , organization_id
        , delivery_number
        , compile_designator
        , earliest_pickup_date
        , latest_pickup_date
        , earliest_acceptable_date
        , latest_acceptable_date
        , inventory_item_id
        , carrier_id
        , ship_method_code
        , mode_of_transport
        , load_tender_status
        , lane_id, service_level
        , cm_trip_number
        , stop_location_id
        , stop_sequence_number
        , planned_arrival_date
        , planned_departure_date
        , departure_gross_weight
        , departure_net_weight
        , departure_volume
        , departure_fill_percent
        , wkend_layover_stops
        , wkday_layover_stops
        , distance_to_next_stop
        , pln_loading_start_time
        , pln_loading_end_time
        , pln_unloading_start_time
        , pln_unloading_end_time
        , source_code
        , ship_from_location_id
        , ship_to_location_id
        , requested_quantity
        , source_header_number
        , ship_set_id
        , arrival_set_id
        , org_id
        , container_flag
        , source_line_number
        , split_from_delivery_detail_id
        , line_direction
        , po_shipment_number
        , po_shipment_line_number
        , src_requested_quantity_uom
        , src_requested_quantity
        , shipment_direction
        , supplier_id
        , party_id
        from mst_release_temp_gt
        where release_id = p_release_id
        );
      end if;
      commit;
    end if;
    print_info(g_log_flow_of_control,'do_release : Release Id = ' ||p_release_id|| ' Program ended');
  exception
    when others then
      print_info(g_log_flow_of_control,'do_release : Release Id = ' ||p_release_id|| ' Unexpected error ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end do_release;

  procedure release_load (p_err_code     out nocopy varchar2
                        , p_err_buff     out nocopy varchar2
                        , p_plan_id      in         number
                        , p_release_id   in         number
                        , p_release_mode in         number) is

    l_return_status varchar2(1);
  begin
    initialize_package_variables;
    set_release_debug_flags;
    print_info(g_log_flow_of_control,'release_load : Release Id = ' ||p_release_id|| ' Program started');
    g_release_data := 'TRIP';
    pull_into_global_temp_table (l_return_status, p_release_id);
    if l_return_status = fnd_api.g_ret_sts_success then
      do_release (p_plan_id, p_release_id, p_release_mode);
    end if;

    print_info(g_log_flow_of_control,'release_load : Release Id = ' ||p_release_id|| ' Program ended');
  exception
    when others then
      delete from mst_release_temp
      where release_id = p_release_id;
      commit;
      log_statistics;
      print_info(g_log_flow_of_control,'release_load : Release Id = ' ||p_release_id|| ' Unexpected error ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end release_load;

  function get_cond (p_condition in varchar2)
  return varchar2 is
    l_str_cond varchar2(30) := '=';
  begin
    if p_condition = 1 then
      l_str_cond := '=';
    elsif p_condition = 2 then
      l_str_cond := '<>';
    elsif p_condition = 3 then
      l_str_cond := '<';
    elsif p_condition = 4 then
      l_str_cond := '<=';
    elsif p_condition = 5 then
      l_str_cond := '>=';
    elsif p_condition = 6 then
      l_str_cond := '>';
    elsif p_condition = 7 then
      l_str_cond := 'between';
    end if;
    return l_str_cond;
  exception
    when others then
      return '=';
  end get_cond;

  procedure insert_plan_trips_ruleset(x_return_status out nocopy varchar2, p_plan_id in number, p_release_id in pls_integer) is

    AREL_CARRIER_CODE  	     constant number := 1;
    AREL_SUPPLIER_CODE       constant number := 2;
    AREL_CUSTOMER_CODE       constant number := 3;
    AREL_UTILIZATION_CODE    constant number := 4;
    AREL_REMAINING_TIME_CODE constant number := 5;
    AREL_CIRCUITY_CODE       constant number := 6;
    AREL_MODE_CODE           constant number := 7;

    l_rule_id                  mst_rel_rule_associations.rule_id%type;
    l_rule_set_id              mst_auto_rel_rule_sets.rule_set_id%type;
    l_auto_release_restriction mst_auto_rel_rule_sets.auto_release_restriction%type;
    l_attribute_code           mst_rel_rule_conditions.attribute_code%type;
    l_condition                mst_rel_rule_conditions.condition%type;
    l_from_number_value        mst_rel_rule_conditions.from_number_value%type;
    l_to_number_value          mst_rel_rule_conditions.to_number_value%type;
    l_from_char_value          mst_rel_rule_conditions.from_char_value%type;
    l_to_char_value            mst_rel_rule_conditions.to_char_value%type;
    l_from_date_value          mst_rel_rule_conditions.from_date_value%type;
    l_to_date_value            mst_rel_rule_conditions.to_date_value%type;

    cursor cur_rules (l_plan_id in number)
    is
    select marrs.rule_set_id
    , marrs.auto_release_restriction
    , mrra.rule_id
    from mst_plans mp
    , mst_auto_rel_rule_sets marrs
    , mst_rel_rule_associations mrra
    where mp.plan_id = l_plan_id
    and mp.auto_rel_rule_set_id = marrs.rule_set_id
    and marrs.rule_set_id = mrra.rule_set_id;

    cursor cur_rule_condition (l_rule_id in number)
    is
    select mrrc.attribute_code
    , mrrc.condition
    , mrrc.from_number_value
    , mrrc.to_number_value
    , mrrc.from_char_value
    , mrrc.to_char_value
    , mrrc.from_date_value
    , mrrc.to_date_value
    from mst_rel_rule_conditions mrrc
    where mrrc.rule_id = l_rule_id;

    l_where_clause varchar2(4000) := null;

  begin
    print_info(g_log_flow_of_control,'insert_plan_trips_ruleset : Program started');
    open cur_rules(p_plan_id);
    loop
      fetch cur_rules into l_rule_set_id
                         , l_auto_release_restriction
                         , l_rule_id;
      exit when cur_rules%notfound;
      l_where_clause := l_where_clause || ' ( 1 = 1 ';
      open cur_rule_condition(l_rule_id);
      loop
        fetch cur_rule_condition into l_attribute_code
                                    , l_condition
                                    , l_from_number_value
                                    , l_to_number_value
                                    , l_from_char_value
                                    , l_to_char_value
                                    , l_from_date_value
                                    , l_to_date_value;
        exit when cur_rule_condition%notfound;

        if (l_attribute_code = AREL_CARRIER_CODE) then
          -- CARRIER  (=, !=)
          l_where_clause := l_where_clause || ' and ' || ' mt.carrier_id ' || get_cond(l_condition) || ' ' || nvl(l_from_number_value,0);
        elsif (l_attribute_code = AREL_SUPPLIER_CODE) then
          -- SUPPLIER (=, !=)
          l_where_clause := l_where_clause || ' and ' || ' exists (select 1 from mst_deliveries md, mst_delivery_legs mdl';
          l_where_clause := l_where_clause || ' where mt.plan_id = mdl.plan_id and mt.trip_id = mdl.trip_id and mdl.plan_id = md.plan_id';
          l_where_clause := l_where_clause || ' and mdl.delivery_id = md.delivery_id and md.supplier_id ' || get_cond(l_condition);
          l_where_clause := l_where_clause || ' ' || nvl(l_from_number_value,0) || ')';
        elsif (l_attribute_code = AREL_CUSTOMER_CODE) then
          -- CUSTOMER (=, !=)
          l_where_clause := l_where_clause || ' and ' || ' exists (select 1 from mst_deliveries md, mst_delivery_legs mdl';
          l_where_clause := l_where_clause || ' where mt.plan_id = mdl.plan_id and mt.trip_id = mdl.trip_id and mdl.plan_id = md.plan_id';
          l_where_clause := l_where_clause || ' and mdl.delivery_id = md.delivery_id and md.customer_id ' || get_cond(l_condition);
          l_where_clause := l_where_clause || ' ' || nvl(l_from_number_value,0) || ')';
        elsif (l_attribute_code = AREL_MODE_CODE) then
          -- MODE (=, !=)
          if l_from_number_value = 1 then
            l_from_char_value := 'TRUCK';
          elsif l_from_number_value = 2 then
            l_from_char_value := 'LTL';
          else
            l_from_char_value := 'PARCEL';
          end if;
          l_where_clause := l_where_clause || ' and ' || ' mt.mode_of_transport '|| get_cond(l_condition)|| ' ''' || l_from_char_value || '''';
        elsif (l_attribute_code = AREL_UTILIZATION_CODE) then
          -- UTILIZATION (=, !=, <, <=, >, >=, is between)
          if (l_condition = 7) then -- between
            l_where_clause := l_where_clause || ' and ' || ' (greatest(mt.peak_weight_utilization,mt.peak_volume_utilization,mt.peak_pallet_utilization)*100 ' || get_cond(l_condition) || ' ' || l_from_number_value || ' and ' || l_to_number_value || ')';
          else -- all other conditions
            l_where_clause := l_where_clause || ' and ' || ' greatest(mt.peak_weight_utilization,mt.peak_volume_utilization,mt.peak_pallet_utilization)*100 ' || get_cond(l_condition) || ' ' || l_from_number_value;
          end if;
        elsif (l_attribute_code = AREL_REMAINING_TIME_CODE) then
          -- REMAINING_TIME (=, !=, <, <=, >, >=, is between)
          if (l_condition = 7) then -- between
            l_where_clause := l_where_clause || ' and ' || ' ((mt.trip_start_date-sysdate)*24 ' || get_cond(l_condition) || ' ' || l_from_number_value || ' and ' || l_to_number_value || ')';
          else
            l_where_clause := l_where_clause || ' and ' || ' (mt.trip_start_date-sysdate)*24 ' || get_cond(l_condition) || ' ' || l_from_number_value;
          end if;
        elsif (l_attribute_code = AREL_CIRCUITY_CODE) then
          -- CIRCUITY (=, !=, <, <=, >, >=, is between)
          if (l_condition = 7) then -- between
            l_where_clause := l_where_clause || ' and ' || ' (((mt.total_trip_distance/mt.total_direct_distance -1)*100) ' || get_cond(l_condition) || ' ' || l_from_number_value || ' and ' || l_to_number_value || ')';
          else
            l_where_clause := l_where_clause || ' and ' || ' ((mt.total_trip_distance/mt.total_direct_distance -1)*100) ' || get_cond(l_condition) || ' ' || l_from_number_value;
          end if;
        end if;

      end loop;
      close cur_rule_condition;
      l_where_clause := l_where_clause || ' ) OR ';
    end loop;

    l_where_clause := substr(l_where_clause,1,length(l_where_clause)-3);
    if l_where_clause is null or l_where_clause = ' ( 1 = 1  ) ' then
      --print_info(g_log_must_message,'Rule set / rule / rule condition not defined to auto-release this plan. No trip eligible for release.');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_39'));
      x_return_status := fnd_api.g_ret_sts_error;
      log_statistics;
      --set_concurrent_status('WARNING', 'Zero Groups attempted to release.');
      set_concurrent_status('WARNING', get_seeded_message('MST_REL_BK_MESSAGE_39'));
    else
      print_info(g_log_ruleset_where_clause,l_where_clause);

      -- insert qualified trips into mst_release_temp_gt
      execute immediate
      'insert into mst_release_temp_gt
      (
      release_id
      , group_id
      , plan_id
      , trip_id
      , sr_trip_id
      , trip_number
      , planned_flag
      , release_status
      , trip_start_date
      , cm_id_of_trip
      , continuous_move_sequence
      , out_of_scope
      , trip_process_flag
      , selected_trips
      , trip_id_iface
      , status_code
      , inventory_item_id
      , organization_id
      , carrier_id
      , ship_method_code
      , compile_designator
      , mode_of_transport
      , load_tender_status
      , lane_id
      , service_level
      )
      (
      select '||p_release_id||'
      , null
      , mt.plan_id
      , mt.trip_id
      , mt.sr_trip_id
      , mt.trip_number
      , decode(nvl('||l_auto_release_restriction||',3),1,1,2,decode(mt.planned_flag,3,2,mt.planned_flag),mt.planned_flag)
      , mt.release_status
      , mt.trip_start_date
      , mt.continuous_move_id
      , mt.continuous_move_sequence
      , mt.out_of_scope
      , null
      , 1
      , wsh_trips_interface_s.nextval
      , mt.status_code
      , fvt.inventory_item_id
      , fvt.organization_id
      , mt.carrier_id
      , mt.ship_method_code
      , mp.compile_designator
      , mt.mode_of_transport
      , mt.load_tender_status
      , mt.lane_id
      , mt.service_level
      from mst_plans mp
      , mst_trips mt
      , fte_vehicle_types fvt
      where mt.plan_id = '||p_plan_id||'
      and mt.plan_id = mp.plan_id
      and mt.vehicle_type_id = fvt.vehicle_type_id (+) and ( '||l_where_clause||' ))';

      g_where_clause := l_where_clause; -- to use in procedure remove_grp_of_unwanted_trip to eliminate groups of disqualified trips
      x_return_status := fnd_api.g_ret_sts_success;
    end if;
    print_info(g_log_flow_of_control,'insert_plan_trips_ruleset : Program ended');
  exception
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      print_info(g_log_flow_of_control,'insert_plan_trips_ruleset : ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end insert_plan_trips_ruleset;

  procedure insert_plan_trips (x_return_status out nocopy varchar2, p_plan_id in number, p_release_id in number) is
  begin
    print_info(g_log_flow_of_control,'insert_plan_trips : Program started');
    insert into mst_release_temp_gt
    (
     release_id
    , group_id
    , plan_id
    , trip_id
    , sr_trip_id
    , trip_number
    , planned_flag
    , release_status
    , trip_start_date
    , cm_id_of_trip
    , continuous_move_sequence
    , out_of_scope
    , trip_process_flag
    , selected_trips
    , trip_id_iface
    , status_code
    , inventory_item_id
    , organization_id
    , carrier_id
    , ship_method_code
    , compile_designator
    , mode_of_transport
    , load_tender_status
    , lane_id
    , service_level
    )
    (
      select p_release_id
    , null
    , mt.plan_id
    , mt.trip_id
    , mt.sr_trip_id
    , mt.trip_number
    , mt.planned_flag
    , mt.release_status
    , mt.trip_start_date
    , mt.continuous_move_id
    , mt.continuous_move_sequence
    , mt.out_of_scope
    , null
    , 1
    , wsh_trips_interface_s.nextval
    , mt.status_code
    , fvt.inventory_item_id
    , fvt.organization_id
    , mt.carrier_id
    , mt.ship_method_code
    , mp.compile_designator
    , mt.mode_of_transport
    , mt.load_tender_status
    , mt.lane_id
    , mt.service_level
    from mst_plans mp
    , mst_trips mt
    , fte_vehicle_types fvt
    where mt.plan_id = p_plan_id
    and mt.plan_id = mp.plan_id
    and mt.vehicle_type_id = fvt.vehicle_type_id (+)
    );

    x_return_status := fnd_api.g_ret_sts_success;
    print_info(g_log_flow_of_control,'insert_plan_trips : Program ended');
  exception
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      print_info(g_log_flow_of_control,'insert_plan_trips : ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end insert_plan_trips;

  procedure truncate_mst_table( p_table_name in varchar2) is
    l_retval boolean;
    l_dummy1 varchar2(32);
    l_dummy2 varchar2(32);
    l_mst_schema varchar2(32);
  begin
    l_retval := FND_INSTALLATION.GET_APP_INFO('MST', l_dummy1, l_dummy2, l_mst_schema);
    execute immediate 'truncate table '||l_mst_schema||'.'||p_table_name;
    commit;
  end truncate_mst_table;

  procedure do_house_keeping is
    l_Message_Text varchar2(1000);
  begin
    --print_info(g_log_must_message,'do_house_keeping : Program started');
    print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_40'));
    print_info(g_log_must_message,'');
    --print_info(g_log_must_message,g_delete_record_count||' number of records will be deleted in one loop');
    fnd_message.set_name('MST','MST_REL_BK_MESSAGE_41');
    fnd_message.set_token('N1',to_char(g_delete_record_count));
    l_Message_Text := fnd_message.get;
    print_info(g_log_must_message,l_Message_Text);
    --print_info(g_log_must_message,'Total number of loops for one delete attempt are '||g_delete_record_count_loop);
    fnd_message.set_name('MST','MST_REL_BK_MESSAGE_42');
    fnd_message.set_token('N1',to_char(g_delete_record_count_loop));
    l_Message_Text := fnd_message.get;
    print_info(g_log_must_message,l_Message_Text);
    print_info(g_log_must_message,'');

    if g_truncate_mrt = 1 then
      truncate_mst_table('mst_release_temp');
      --print_info(g_log_must_message,'mst_release_temp truncated.');
      fnd_message.set_name('MST','MST_REL_BK_MESSAGE_43');
      fnd_message.set_token('TABLE_NAME','MST_RELEASE_TEMP');
      l_Message_Text := fnd_message.get;
      print_info(g_log_must_message,l_Message_Text);
    else -- delete from table
      for i in 1..g_delete_record_count_loop loop
        delete from mst_release_temp
        where rownum < g_delete_record_count;
        --print_info(g_log_must_message,'Attempted to delete '||sql%rowcount||' records from mst_release_temp.');
        fnd_message.set_name('MST','MST_REL_BK_MESSAGE_44');
        fnd_message.set_token('N1',to_char(sql%rowcount));
        fnd_message.set_token('TABLE_NAME','MST_RELEASE_TEMP');
        l_Message_Text := fnd_message.get;
        print_info(g_log_must_message,l_Message_Text);
        commit;
      end loop;
    end if;
    print_info(g_log_must_message,'');

    for i in 1..g_delete_record_count_loop loop
      delete from wsh_trips_interface
      where interface_action_code = g_tp_release_code
      and rownum < g_delete_record_count;
      --print_info(g_log_must_message,'Attempted to delete '||sql%rowcount||' records from wsh_trips_interface.');
      fnd_message.set_name('MST','MST_REL_BK_MESSAGE_44');
      fnd_message.set_token('N1',to_char(sql%rowcount));
      fnd_message.set_token('TABLE_NAME','WSH_TRIPS_INTERFACE');
      l_Message_Text := fnd_message.get;
      print_info(g_log_must_message,l_Message_Text);
      commit;
    end loop;
    print_info(g_log_must_message,'');

    for i in 1..g_delete_record_count_loop loop
      delete from fte_moves_interface
      where interface_action_code = g_tp_release_code
      and rownum < g_delete_record_count;
      --print_info(g_log_must_message,'Attempted to delete '||sql%rowcount||' records from fte_moves_interface.');
      fnd_message.set_name('MST','MST_REL_BK_MESSAGE_44');
      fnd_message.set_token('N1',to_char(sql%rowcount));
      fnd_message.set_token('TABLE_NAME','FTE_MOVES_INTERFACE');
      l_Message_Text := fnd_message.get;
      print_info(g_log_must_message,l_Message_Text);
      commit;
    end loop;
    print_info(g_log_must_message,'');

    for i in 1..g_delete_record_count_loop loop
      delete from fte_trip_moves_interface
      where interface_action_code = g_tp_release_code
      and rownum < g_delete_record_count;
      --print_info(g_log_must_message,'Attempted to delete '||sql%rowcount||' records from fte_trip_moves_interface.');
      fnd_message.set_name('MST','MST_REL_BK_MESSAGE_44');
      fnd_message.set_token('N1',to_char(sql%rowcount));
      fnd_message.set_token('TABLE_NAME','FTE_TRIP_MOVES_INTERFACE');
      l_Message_Text := fnd_message.get;
      print_info(g_log_must_message,l_Message_Text);
      commit;
    end loop;
    print_info(g_log_must_message,'');

    for i in 1..g_delete_record_count_loop loop
      delete from wsh_trip_stops_interface
      where interface_action_code = g_tp_release_code
      and rownum < g_delete_record_count;
      print_info(g_log_must_message,'Attempted to delete '||sql%rowcount||' records from wsh_trip_stops_interface.');
      fnd_message.set_name('MST','MST_REL_BK_MESSAGE_44');
      fnd_message.set_token('N1',to_char(sql%rowcount));
      fnd_message.set_token('TABLE_NAME','WSH_TRIP_STOPS_INTERFACE');
      l_Message_Text := fnd_message.get;
      print_info(g_log_must_message,l_Message_Text);
      commit;
    end loop;
    print_info(g_log_must_message,'');

    for i in 1..g_delete_record_count_loop loop
      delete from wsh_new_del_interface
      where interface_action_code = g_tp_release_code
      and rownum < g_delete_record_count;
      print_info(g_log_must_message,'Attempted to delete '||sql%rowcount||' records from wsh_new_del_interface.');
      fnd_message.set_name('MST','MST_REL_BK_MESSAGE_44');
      fnd_message.set_token('N1',to_char(sql%rowcount));
      fnd_message.set_token('TABLE_NAME','WSH_NEW_DEL_INTERFACE');
      l_Message_Text := fnd_message.get;
      print_info(g_log_must_message,l_Message_Text);
      commit;
    end loop;
    print_info(g_log_must_message,'');

    for i in 1..g_delete_record_count_loop loop
      delete from wsh_del_legs_interface
      where interface_action_code = g_tp_release_code
      and rownum < g_delete_record_count;
      --print_info(g_log_must_message,'Attempted to delete '||sql%rowcount||' records from wsh_del_legs_interface.');
      fnd_message.set_name('MST','MST_REL_BK_MESSAGE_44');
      fnd_message.set_token('N1',to_char(sql%rowcount));
      fnd_message.set_token('TABLE_NAME','WSH_DEL_LEGS_INTERFACE');
      l_Message_Text := fnd_message.get;
      print_info(g_log_must_message,l_Message_Text);
      commit;
    end loop;
    print_info(g_log_must_message,'');

    for i in 1..g_delete_record_count_loop loop
      delete from wsh_del_assgn_interface
      where interface_action_code = g_tp_release_code
      and rownum < g_delete_record_count;
      --print_info(g_log_must_message,'Attempted to delete '||sql%rowcount||' records from wsh_del_assgn_interface.');
      fnd_message.set_name('MST','MST_REL_BK_MESSAGE_44');
      fnd_message.set_token('N1',to_char(sql%rowcount));
      fnd_message.set_token('TABLE_NAME','WSH_DEL_ASSGN_INTERFACE');
      l_Message_Text := fnd_message.get;
      print_info(g_log_must_message,l_Message_Text);
      commit;
    end loop;
    print_info(g_log_must_message,'');

    for i in 1..g_delete_record_count_loop loop
      delete from wsh_del_details_interface
      where interface_action_code = g_tp_release_code
      and rownum < g_delete_record_count;
      --print_info(g_log_must_message,'Attempted to delete '||sql%rowcount||' records from wsh_del_details_interface.');
      fnd_message.set_name('MST','MST_REL_BK_MESSAGE_44');
      fnd_message.set_token('N1',to_char(sql%rowcount));
      fnd_message.set_token('TABLE_NAME','WSH_DEL_DETAILS_INTERFACE');
      l_Message_Text := fnd_message.get;
      print_info(g_log_must_message,l_Message_Text);
      commit;
    end loop;
    print_info(g_log_must_message,'');

    for i in 1..g_delete_record_count_loop loop
      delete from wsh_interface_errors
      where interface_action_code = g_tp_release_code
      and rownum < g_delete_record_count;
      --print_info(g_log_must_message,'Attempted to delete '||sql%rowcount||' records from wsh_interface_errors.');
      fnd_message.set_name('MST','MST_REL_BK_MESSAGE_44');
      fnd_message.set_token('N1',to_char(sql%rowcount));
      fnd_message.set_token('TABLE_NAME','WSH_INTERFACE_ERRORS');
      l_Message_Text := fnd_message.get;
      print_info(g_log_must_message,l_Message_Text);
      commit;
    end loop;
    print_info(g_log_must_message,'');

    --print_info(g_log_must_message,'do_house_keeping : Program ended');
    print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_45'));
  end do_house_keeping;

  procedure release_plan (p_err_code out nocopy varchar2
                        , p_err_buff out nocopy varchar2
                        , p_plan_id in number
                        , p_release_id in number
                        , p_release_mode in number) is
    -- cursor to check the auto_release flag
    cursor c_auto_rel (l_plan_id in number)
    is
    select auto_release
    from mst_plans
    where plan_id = l_plan_id;

    l_auto_release number;

    l_return_status varchar2(1) := 'U';
    l_Message_Text varchar2(1000);
  begin
    initialize_package_variables;
    set_release_debug_flags;
    if g_house_keeping = 1 then
      do_house_keeping;
      print_info(g_log_must_message,'...................................................................................');
      --print_info(g_log_must_message,'Plan NOT released. ONLY house keeping done.');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_46'));
      --print_info(g_log_must_message,'Now make change in profile "tp:release debug" to release plan.');
      print_info(g_log_must_message,get_seeded_message('MST_REL_BK_MESSAGE_48'));
    elsif g_house_keeping = 2 then -- Manual-release with ruleset mode will be run. This is not for customer.
      print_info(g_log_must_message,'Simulated Auto-Release with Ruleset: Manual-release with ruleset mode will be run. This is not for customer.');
      g_release_data := 'TRIP';
      g_auto_release := 3;
      insert_plan_trips_ruleset(l_return_status, p_plan_id, p_release_id);
      if l_return_status = fnd_api.g_ret_sts_success then
        do_release (p_plan_id, p_release_id, 1);
      end if;
    elsif g_house_keeping = 3 then -- Manual-release as auto-release will be run. This is not for customer.
      print_info(g_log_must_message,'Simulated Auto-Release of Entire Plan: Manual-release as auto-release will be run. This is not for customer.');
      g_release_data := 'PLAN';
      insert_plan_trips (l_return_status, p_plan_id, p_release_id);
      if l_return_status = fnd_api.g_ret_sts_success then
        do_release (p_plan_id, p_release_id, 1);
      end if;
    else
      print_info(g_log_flow_of_control,'release_plan : Release Id = ' ||p_release_id|| ' Program started');

      if nvl(p_release_mode,2) = 2 then -- called from ui (manual release entire plan)
        g_release_data := 'PLAN';
        insert_plan_trips (l_return_status, p_plan_id, p_release_id);
        if l_return_status = fnd_api.g_ret_sts_success then
          do_release (p_plan_id, p_release_id, p_release_mode);
        end if;
      elsif p_release_mode = 3 then  -- called from ui (manual release entire plan with ruleset)
        g_release_data := 'TRIP'; -- added this portion of elsif due to bug 3570370
        g_auto_release := 3;
        insert_plan_trips_ruleset(l_return_status, p_plan_id, p_release_id);
        if l_return_status = fnd_api.g_ret_sts_success then
          do_release (p_plan_id, p_release_id, 1); -- making release mode (third parameter) to 1 to simulate auto-release
        end if;
      elsif p_release_mode = 1 then -- called from engine for auto release

        open c_auto_rel (p_plan_id);
        fetch c_auto_rel into l_auto_release;
        close c_auto_rel;

        if l_auto_release = 1 then  -- no auto release
          null;
        elsif l_auto_release = 2 then -- release entire plan as per planned-flag in tables
          g_release_data := 'PLAN';
          insert_plan_trips (l_return_status, p_plan_id, p_release_id);
          if l_return_status = fnd_api.g_ret_sts_success then
            do_release (p_plan_id, p_release_id, p_release_mode);
          end if;
        elsif l_auto_release = 3 then -- release plan as per the rule set defined in plan option
          g_auto_release := 3;
          g_release_data := 'TRIP';
          insert_plan_trips_ruleset(l_return_status, p_plan_id, p_release_id);
          if l_return_status = fnd_api.g_ret_sts_success then
            do_release (p_plan_id, p_release_id, p_release_mode);
          end if;
        end if;
      end if;
      print_info(g_log_flow_of_control,'release_plan : Release Id = ' ||p_release_id|| ' Program ended');
    end if;
  exception
    when others then
      log_statistics;
      print_info(g_log_flow_of_control,'release_plan : Release Id = ' ||p_release_id|| ' Unexpected error ' || to_char(sqlcode) || ':' || SQLERRM);
      set_concurrent_status('ERROR',get_seeded_message('MST_REL_BK_MESSAGE_47') || to_char(sqlcode) || ':' || SQLERRM);
  end release_plan;

  procedure submit_release_request ( p_request_id         OUT NOCOPY NUMBER
                                   , p_release_type       IN         VARCHAR2  -- 'LOAD' or 'PLAN'
                                   , p_plan_id            IN         NUMBER
                                   , p_release_id         IN         NUMBER
                                   , p_release_mode       IN         NUMBER DEFAULT NULL) is
    l_CP_name VARCHAR2(80);
    l_status  NUMBER;
    l_errbuf  VARCHAR2(1000);
    l_retcode NUMBER;
  begin
    if p_release_type = 'LOAD' then
      l_CP_name := 'MSTRELLD';
    elsif p_release_type = 'PLAN' then
      l_CP_name := 'MSTRELPL';
    end if;
    p_request_id := fnd_request.submit_request('MST', l_CP_name, NULL, NULL, NULL, p_plan_id, p_release_id, p_release_mode);
    if p_request_id = 0 then
      l_errbuf := fnd_message.get;
    else
      commit;
    end if;
  end submit_release_request;

  ------- used in exception summary screen to set the release type ---------------
  --  p_release_type = 1  => auto released, 2 => released, 3 => flagged for release, 4 => unreleased
  procedure set_release_type (p_release_type IN NUMBER) is
  begin
    g_release_type := p_release_type;
  end set_release_type;

  -- used in views of all tls, all ltls, all parcels, all continuous moves
  function get_release_type RETURN NUMBER is
    l_temp  number;
  begin
    l_temp := g_release_type;
    g_release_type := 0;
    return l_temp;
  end get_release_type;

  procedure print_info(p_release_debug_control in number, p_info_str in varchar2) is
  begin
    if p_release_debug_control = 1 then
      fnd_file.put_line(fnd_file.log, p_info_str);
      --dbms_output.put_line(p_info_str);
      --abc123pro(p_info_str);
    end if;
  end print_info;

END MST_RELEASE;

/
