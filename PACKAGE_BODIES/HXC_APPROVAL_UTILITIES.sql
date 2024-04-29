--------------------------------------------------------
--  DDL for Package Body HXC_APPROVAL_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_APPROVAL_UTILITIES" AS
		/* $Header: hxcaprutil.pkb 120.7.12010000.10 2016/03/15 13:31:16 bkalla ship $ */

         TYPE approval_notification IS RECORD (time_building_block_id  hxc_time_building_blocks.time_building_block_id%TYPE
                                       ,object_version_number   hxc_time_building_blocks.object_version_number%TYPE
                                       ,start_time              hxc_time_building_blocks.start_time%TYPE
                                       ,stop_time               hxc_time_building_blocks.stop_time%TYPE
                                       ,approval_status         hxc_time_building_blocks.approval_status%TYPE
                                       ,employee_name           per_all_people_f.full_name%TYPE
                                       ,comment_text            hxc_time_building_blocks.comment_text%TYPE
                                       ,application_name        fnd_application_tl.application_name%TYPE
                                       ,resource_id             hxc_time_building_blocks.resource_id%TYPE
                                       ,total_hours             number(15,3)
                                       ,premium_hours           number(15,3)
                                       ,non_worked_hours        number(15,3)
                                       ,time_recipient_id       number(15)
                                       ,employee_number         varchar2(30)
                                       ,transferred_to          varchar2(400));

  TYPE cur_type IS REF CURSOR;

  g_transaction_id number DEFAULT NULL;

  g_package varchar2(100) DEFAULT 'hxc_approval_utilities.';

  g_debug boolean DEFAULT hr_utility.debug_enabled;

  FUNCTION is_selected
    (p_selected_ids IN hxc_deposit_wrapper_utilities.t_simple_table
    ,p_block_id     IN hxc_time_building_blocks.time_building_block_id%TYPE) RETURN boolean IS
    l_proc varchar2(100);
  BEGIN
    IF g_debug THEN
      l_proc := 'is_selected';

      hr_utility.set_location (g_package
                               || l_proc
                              ,10);
    END IF;

    FOR l_index IN p_selected_ids.first .. p_selected_ids.last LOOP
      IF p_selected_ids (l_index) = to_char (p_block_id) THEN
        RETURN TRUE;
      END IF;
    END LOOP;

    RETURN FALSE;
  END is_selected;

  PROCEDURE add_records
    (p_approval_array IN OUT NOCOPY hxc_notification_table_type
    ,p_record         IN            hxc_notification_type) IS
    l_index number;
    l_proc varchar2(100);
  BEGIN
    IF g_debug THEN
      l_proc := 'add_records';

      hr_utility.set_location (g_package
                               || l_proc
                              ,10);
    END IF;

    l_index := p_approval_array.count;

    p_approval_array.extend;

    p_approval_array (l_index + 1) := p_record;
  END add_records;

  FUNCTION get_block_ids
    (p_approval_array IN hxc_notification_table_type) RETURN varchar2 IS
    l_block_ids varchar2(32767) DEFAULT NULL;
    l_proc varchar2(100);
  BEGIN
    IF g_debug THEN
      l_proc := 'get_block_ids';

      hr_utility.set_location (g_package
                               || l_proc
                              ,10);
    END IF;

    FOR l_block_index IN p_approval_array.first .. p_approval_array.last LOOP
      IF l_block_ids IS NOT NULL THEN
        l_block_ids := l_block_ids
                       || ', ';
      END IF;

      l_block_ids := l_block_ids
                     || p_approval_array (l_block_index).time_building_block_id;
    END LOOP;

    RETURN l_block_ids;
  END get_block_ids;

  FUNCTION has_comment
    (p_block_id  IN hxc_time_building_blocks.time_building_block_id%TYPE
    ,p_block_ovn IN hxc_time_building_blocks.object_version_number%TYPE
    ,p_operator  IN varchar2
    ,p_comment   IN varchar2) RETURN varchar2 IS
    l_like_string varchar2(1);
    l_yes varchar2(1);
    l_sql varchar2(32767);
    c_sql cur_type;
  BEGIN
    IF instr (p_operator
             ,'LIKE') <> 0 THEN
      l_like_string := '%';
    ELSE
      l_like_string := '';
    END IF;

    l_sql := 'SELECT ''Y'''
             || '  FROM hxc_time_building_blocks htbb,'
             || '       hxc_time_building_blocks htbb_tc'
             || ' WHERE htbb.time_building_block_id = '
             || p_block_id
             || '   AND htbb.object_version_number = '
             || p_block_ovn
             || '   AND htbb_tc.scope = ''TIMECARD'''
             || '   AND htbb_tc.resource_id = htbb.resource_id'
             || '   AND TRUNC(htbb_tc.start_time) >= TRUNC(htbb.start_time)'
             || '   AND TRUNC(htbb_tc.stop_time)  <= TRUNC(htbb.stop_time)'
             || '   AND htbb_tc.date_to = hr_general.end_of_time'
             || '   AND NVL(htbb_tc.comment_text, '' '') '
             || p_operator
             || ' '''
             || l_like_string
             || p_comment
             || l_like_string
             || '''';

    OPEN c_sql
    FOR l_sql;

    FETCH c_sql
      INTO    l_yes;

    IF c_sql%NOTFOUND THEN
      RETURN 'N';
    END IF;

    RETURN 'Y';
  END has_comment;

  FUNCTION has_detail_comment
    (p_block_id  IN hxc_time_building_blocks.time_building_block_id%TYPE
    ,p_block_ovn IN hxc_time_building_blocks.object_version_number%TYPE
    ,p_operator  IN varchar2
    ,p_comment   IN varchar2) RETURN varchar2 IS
    l_like_string varchar2(1);
    l_yes varchar2(1);
    l_sql varchar2(32767);
    c_sql cur_type;
  BEGIN
    IF instr (p_operator
             ,'LIKE') <> 0 THEN
      l_like_string := '%';
    ELSE
      l_like_string := '';
    END IF;

    l_sql := 'SELECT ''Y'''
             || '  FROM hxc_ap_detail_links aplinks,'
             || '       hxc_time_building_blocks htbb_detail'
             || ' WHERE aplinks.application_period_id = '
             || p_block_id
             || '   AND aplinks.time_building_block_id = htbb_detail.time_building_block_id '
             || '   AND aplinks.time_building_block_ovn = htbb_detail.object_version_number '
             || '   AND htbb_detail.date_to = hr_general.end_of_time'
             || '   AND NVL(htbb_detail.comment_text, '' '') '
             || p_operator
             || ' '''
             || l_like_string
             || p_comment
             || l_like_string
             || '''';

    OPEN c_sql
    FOR l_sql;

    FETCH c_sql
      INTO    l_yes;

    IF c_sql%NOTFOUND THEN
      RETURN 'N';
    END IF;

    RETURN 'Y';
  END has_detail_comment;

  PROCEDURE get_mapping_component
    (p_field_name           IN         varchar2
    ,p_context              OUT NOCOPY varchar2
    ,p_segment              OUT NOCOPY varchar2
    ,p_bld_blk_info_type_id OUT NOCOPY number) IS
    CURSOR c_mapping_segment
      (p_field_name IN varchar2) IS
      SELECT  context
             ,segment
             ,bld_blk_info_type_id
      FROM    hxc_mapping_attributes_v
      WHERE   map = 'OTL Deposit Process Mapping'
      AND     upper (field_name) = upper (p_field_name);
  BEGIN
    OPEN c_mapping_segment (p_field_name);

    FETCH c_mapping_segment
      INTO    p_context
             ,p_segment
             ,p_bld_blk_info_type_id;

    IF c_mapping_segment%NOTFOUND THEN
      CLOSE c_mapping_segment;

      fnd_message.set_name ('HXC'
                           ,'HXC_NO_MAPPING_COMPONENT');

      fnd_message.raise_error;
    END IF;

    CLOSE c_mapping_segment;
  END get_mapping_component;

  FUNCTION attribute_search
    (p_block_id        IN hxc_time_building_blocks.time_building_block_id%TYPE
    ,p_block_ovn       IN hxc_time_building_blocks.object_version_number%TYPE
    ,p_search_by       IN varchar2
    ,p_search_value    IN varchar2
    ,p_search_operator IN varchar2
    ,p_resource_id     IN varchar2) RETURN varchar2 IS
    l_context varchar2(100);
    l_segment varchar2(100);
    l_bld_blk_info_type_id number;
    l_flex_search_value varchar2(32767);
    c_sql cur_type;
    l_sql varchar2(32767) DEFAULT NULL;
    l_yes varchar2(1);
    l_like_string varchar2(1);
    l_dummy number(15);
  BEGIN
    l_dummy := hxc_timecard_properties.setup_mo_global_params (p_resource_id);

    get_mapping_component
                           (p_field_name           => p_search_by
                           ,p_context              => l_context
                           ,p_segment              => l_segment
                           ,p_bld_blk_info_type_id => l_bld_blk_info_type_id );

    l_flex_search_value := hxc_timecard_search_pkg.get_attributes
                                                                   (p_search_by              => p_search_by
                                                                   ,p_search_value           => p_search_value
                                                                   ,p_flex_segment           => l_segment
                                                                   ,p_flex_context           => l_context
                                                                   ,p_flex_name              => 'OTC Information Types'
                                                                   ,p_application_short_name => 'HXC'
                                                                   ,p_operator               => p_search_operator
                                                                   ,p_resource_id            => p_resource_id
                                                                   ,p_field_name             => p_search_by );

    IF l_flex_search_value
          = hxc_timecard_search_pkg.c_no_valueset_attached THEN
      IF instr (p_search_operator
               ,'LIKE') <> 0 THEN
        l_like_string := '%';
      ELSE
        l_like_string := '';
      END IF;

      l_sql := 'SELECT ''Y'''
               || '  FROM hxc_ap_detail_links aplinks,'
               || '       hxc_time_building_blocks htbb_detail,'
               || '       hxc_time_attribute_usages htau,'
               || '       hxc_time_attributes hta'
               || ' WHERE aplinks.application_period_id = '
               || p_block_id
               || '   AND aplinks.time_building_block_id = htbb_detail.time_building_block_id '
               || '   AND aplinks.time_building_block_ovn = htbb_detail.object_version_number '
               || '   AND htbb_detail.date_to = hr_general.end_of_time'
               || '   AND htau.time_building_block_id = htbb_detail.time_building_block_id'
               || '   AND htau.time_building_block_ovn = htbb_detail.object_version_number'
               || '   AND htau.time_attribute_id = hta.time_attribute_id'
               || '   AND hta.attribute_category = '
               || ''''
               || l_context
               || ''''
               || '   AND hta.'
               || l_segment
               || ' '
               || p_search_operator
               || ' '
               || ''''
               || l_like_string
               || p_search_value
               || l_like_string
               || '''';
    ELSE
      l_sql := 'SELECT ''Y'''
               || '  FROM hxc_ap_detail_links aplinks,'
               || '       hxc_time_building_blocks htbb_detail,'
               || '       hxc_time_attribute_usages htau,'
               || '       hxc_time_attributes hta'
               || ' WHERE aplinks.application_period_id = '
               || p_block_id
               || '   AND aplinks.time_building_block_id = htbb_detail.time_building_block_id '
               || '   AND aplinks.time_building_block_ovn = htbb_detail.object_version_number '
               || '   AND htbb_detail.date_to = hr_general.end_of_time'
               || '   AND htau.time_building_block_id = htbb_detail.time_building_block_id'
               || '   AND htau.time_building_block_ovn = htbb_detail.object_version_number'
               || '   AND htau.time_attribute_id = hta.time_attribute_id'
               || '   AND hta.attribute_category = '
               || ''''
               || l_context
               || ''''
               || '   AND hta.'
               || l_segment
               || ' IN ('
               || l_flex_search_value
               || ')';
    END IF;

    OPEN c_sql
    FOR l_sql;

    FETCH c_sql
      INTO    l_yes;

    IF c_sql%NOTFOUND THEN
      RETURN 'N';
    END IF;

    RETURN 'Y';
  END attribute_search;

  PROCEDURE adv_search
    (p_block_ids    IN         varchar2
    ,p_adv_search   IN         varchar2
    ,p_selected_ids OUT NOCOPY hxc_deposit_wrapper_utilities.t_simple_table) IS
    l_adv_table hxc_deposit_wrapper_utilities.t_simple_table;
    l_search_by varchar2(100);
    l_search_operator varchar2(30);
    l_search_value varchar2(1000);
    l_search_connector varchar2(5);
    l_detail_join_flag boolean DEFAULT FALSE;
    l_attribute_flag boolean DEFAULT FALSE;
    l_like_string varchar2(1);
    l_sql_select varchar2(1000);
    l_sql_from varchar2(1000);
    l_flex_search_value varchar2(32767);
    l_sql_where varchar2(32767);
    l_additional_where varchar2(32767);
    l_one_where varchar2(32767);
    l_complete_sql varchar2(32767);
    l_adv_table_index number;
    l_selected_id_index number;
    l_context varchar2(100);
    l_segment varchar2(100);
    l_bld_blk_info_type_id number;
    l_temp_search_by varchar2(100);
    c_sql cur_type;
    l_proc varchar2(100);
  BEGIN
    IF g_debug THEN
      l_proc := 'adv_search';

      hr_utility.set_location (g_package
                               || l_proc
                              ,10);
    END IF;

    hxc_deposit_wrapper_utilities.string_to_table
                                                   (p_separator => '|'
                                                   ,p_string    => p_adv_search
                                                   ,p_table     => l_adv_table );

    IF g_debug THEN
      hr_utility.set_location (g_package
                               || l_proc
                              ,20);
    END IF;

    l_sql_select := 'SELECT time_building_block_id';

    l_sql_from := 'FROM hxc_time_building_blocks htbb';

    l_sql_where := 'WHERE htbb.time_building_block_id IN ('
                   || p_block_ids
                   || ')'
                   || ' AND htbb.date_to = hr_general.end_of_time';

    IF g_debug THEN
      hr_utility.set_location (g_package
                               || l_proc
                              ,30);
    END IF;

    l_additional_where := NULL;

    l_adv_table_index := 0;

    LOOP
      EXIT WHEN NOT l_adv_table.exists (l_adv_table_index);

      IF g_debug THEN
        hr_utility.set_location (g_package
                                 || l_proc
                                ,40);
      END IF;

      l_search_by := l_adv_table (l_adv_table_index);

      l_search_operator := l_adv_table (l_adv_table_index + 1);

      l_search_value := l_adv_table (l_adv_table_index + 2);

      l_search_connector := l_adv_table (l_adv_table_index + 3);

      IF instr (l_search_operator
               ,'LIKE') <> 0 THEN
        l_like_string := '%';
      ELSE
        l_like_string := '';
      END IF;

      IF l_search_by = 'PERIOD_STARTS' THEN
        IF g_debug THEN
          hr_utility.set_location (g_package
                                   || l_proc
                                  ,50);
        END IF;

        l_one_where := 'TRUNC(htbb.start_time) '
                       || l_search_operator
                       || ' TO_DATE('
                       || ''''
                       || l_search_value
                       || ''''
                       || ', ''RRRR/MM/DD'')';
      ELSIF l_search_by = 'PERIOD_ENDS' THEN
        IF g_debug THEN
          hr_utility.set_location (g_package
                                   || l_proc
                                  ,60);
        END IF;

        l_one_where := 'TRUNC(htbb.stop_time) '
                       || l_search_operator
                       || ' TO_DATE('
                       || ''''
                       || l_search_value
                       || ''''
                       || ', ''RRRR/MM/DD'')';
      ELSIF l_search_by = 'SUBMISSION_DATE' THEN
        IF g_debug THEN
          hr_utility.set_location (g_package
                                   || l_proc
                                  ,70);
        END IF;

        l_one_where := 'TRUNC(htbb.creation_date) '
                       || l_search_operator
                       || ' TO_DATE('
                       || ''''
                       || l_search_value
                       || ''''
                       || ', ''RRRR/MM/DD'')';
      ELSIF l_search_by = 'TIMECARD_COMMENT' THEN
        l_one_where := 'hxc_approval_utilities.has_comment(htbb.time_building_block_id, htbb.object_version_number,'''
                       || l_search_operator
                       || ''','''
                       || l_search_value
                       || ''') = ''Y''';
      ELSIF l_search_by = 'DETAIL_COMMENT' THEN
        l_one_where := 'hxc_approval_utilities.has_detail_comment(htbb.time_building_block_id, htbb.object_version_number, '''
                       || l_search_operator
                       || ''','''
                       || l_search_value
                       || ''') = ''Y''';
      ELSIF l_search_by = 'STATUS_CODE' THEN
        l_one_where := 'hr_general.decode_lookup(''HXC_APPROVAL_STATUS'', htbb.approval_status)'
                       || l_search_operator
                       || ' '''
                       || l_like_string
                       || l_search_value
                       || l_like_string
                       || '''';
      ELSIF l_search_by = 'HOURS_WORKED' THEN
        l_one_where := 'hxc_time_category_utils_pkg.category_app_period_tc_hrs(htbb.start_time,
         htbb.stop_time, htbb.resource_id, '''', htbb.time_building_block_id) '
                       || l_search_operator
                       || l_search_value;
      ELSIF l_search_by = 'PERSON_TYPE' THEN
        l_one_where := 'htbb.resource_id in (select p.person_id
               					from per_people_f p,per_person_types ppt,
               					per_person_type_usages_f pptu
               					where pptu.person_id = p.person_id and
               					ppt.person_type_id = pptu.person_type_id and
               					ppt.user_person_type '
                       || l_search_operator
                       || ''''
                       || l_like_string
                       || l_search_value
                       || l_like_string
                       || ''''
                       || ')';
      ELSIF l_search_by = 'SUPPLIER' THEN
        l_temp_search_by := 'PO Line Id';

        get_mapping_component
                               (p_field_name           => l_temp_search_by
                               ,p_context              => l_context
                               ,p_segment              => l_segment
                               ,p_bld_blk_info_type_id => l_bld_blk_info_type_id );

        l_one_where := 'htbb.time_building_block_id in (select distinct hadl.APPLICATION_PERIOD_ID
              						from hxc_time_attributes hta, hxc_time_attribute_usages htau,
              						po_vendors pv, po_headers_all pha, hxc_time_building_blocks detail,
              						hxc_ap_detail_links hadl, po_lines_all pla
              						where hta.attribute_category ='
                       || ''''
                       || l_context
                       || ''''
                       || ' and  hta.'
                       || l_segment
                       || '= pla.po_line_id and pv.vendor_name '
                       || l_search_operator
                       || ''''
                       || l_like_string
                       || l_search_value
                       || l_like_string
                       || ''''
                       || ' and pha.vendor_id=pv.VENDOR_ID
              									and pla.po_header_id= pha.po_header_id
              									and htau.TIME_ATTRIBUTE_ID = hta.time_attribute_id
              									and htau.time_building_block_id = detail.time_building_block_id
              									and detail.date_to = hr_general.end_of_time
              									and hadl.time_building_block_id = detail.time_building_block_id
              									and hadl.time_building_block_ovn = detail.object_version_number
              									and hta.bld_blk_info_type_id ='
                       || l_bld_blk_info_type_id
                       || ')';
      ELSE
        l_one_where := 'hxc_approval_utilities.attribute_search(htbb.time_building_block_id, htbb.object_version_number,'
                       || ''''
                       || l_search_by
                       || ''','''
                       || l_search_value
                       || ''','''
                       || l_search_operator
                       || ''', htbb.resource_id) = ''Y''';
      END IF;

      IF g_debug THEN
        hr_utility.set_location (g_package
                                 || l_proc
                                ,100);
      END IF;

      l_additional_where := l_additional_where
                            || ' '
                            || l_search_connector
                            || ' '
                            || l_one_where;

      l_adv_table_index := l_adv_table_index + 4;
    END LOOP;

    IF g_debug THEN
      hr_utility.set_location (g_package
                               || l_proc
                              ,110);
    END IF;

    IF l_additional_where IS NOT NULL THEN
      IF g_debug THEN
        hr_utility.set_location (g_package
                                 || l_proc
                                ,120);
      END IF;

      l_sql_where := l_sql_where
                     || ' AND ('
                     || l_additional_where
                     || '     )';
    END IF;

    IF g_debug THEN
      hr_utility.set_location (g_package
                               || l_proc
                              ,130);
    END IF;

    l_complete_sql := l_sql_select
                      || ' '
                      || l_sql_from
                      || ' '
                      || l_sql_where;

    IF g_debug THEN
      hr_utility.set_location (g_package
                               || l_proc
                              ,140);
    END IF;

    l_selected_id_index := 0;

    OPEN c_sql
    FOR l_complete_sql;

    LOOP
      FETCH c_sql
        INTO    p_selected_ids (l_selected_id_index);

      EXIT WHEN c_sql%NOTFOUND;

      IF g_debug THEN
        hr_utility.trace ('selected id='
                          || p_selected_ids (l_selected_id_index));
      END IF;

      l_selected_id_index := l_selected_id_index + 1;
    END LOOP;

    CLOSE c_sql;

    IF g_debug THEN
      hr_utility.set_location (g_package
                               || l_proc
                              ,150);
    END IF;
  END adv_search;

  PROCEDURE release_locks IS
    l_success boolean;
  BEGIN
    IF g_transaction_id IS NOT NULL THEN
      hxc_lock_api.release_lock
                                 (p_row_lock_id         => NULL
                                 ,p_process_locker_type => hxc_lock_util.c_ss_approval_action
                                 ,p_transaction_lock_id => g_transaction_id
                                 ,p_released_success    => l_success );

      g_transaction_id := NULL;
    END IF;
  END release_locks;

  FUNCTION get_name
    (p_person_id IN per_all_people_f.person_id%TYPE) RETURN varchar2 IS
    CURSOR c_name
      (p_person_id IN per_all_people_f.person_id%TYPE) IS
      SELECT  full_name
      FROM    per_all_people_f
      WHERE   person_id = p_person_id
      AND     sysdate BETWEEN effective_start_date
                      AND     effective_end_date;
    l_name per_all_people_f.full_name%TYPE;
  BEGIN
    OPEN c_name (p_person_id);

    FETCH c_name
      INTO    l_name;

    CLOSE c_name;

    RETURN l_name;
  END get_name;

  PROCEDURE get_open_notifications
    (p_approver_id    IN         number
    ,p_approval_array OUT NOCOPY hxc_notification_table_type
    ,p_resource_id    IN         varchar2
    ,p_from_date      IN         varchar2
    ,p_to_date        IN         varchar2
    ,p_adv_search     IN         varchar2) IS
    l_item_type wf_item_activity_statuses.item_type%TYPE DEFAULT 'HXCEMP';
    l_item_key wf_item_activity_statuses.item_key%TYPE;
    l_app_bb_id hxc_time_building_blocks.time_building_block_id%TYPE;
    l_app_bb_ovn hxc_time_building_blocks.object_version_number%TYPE;
    l_approval_record approval_notification;
    l_array_index number DEFAULT 0;
    l_match boolean;
    l_resource_id number DEFAULT - 1;
    l_start_date date;
    l_end_date date;
    l_approval_array hxc_notification_table_type;
    l_selected_ids hxc_deposit_wrapper_utilities.t_simple_table;
    l_index number;
    l_messages hxc_message_table_type;
    l_lock_id rowid;
    l_success boolean;
    l_proc varchar2(100);
    l_approval_status varchar2(100);

     l_true varchar2(1);   -- 22811468
     cursor check_lock (p_app_bb_id  IN hxc_time_building_blocks.time_building_block_id%TYPE
            ,p_app_bb_ovn IN hxc_time_building_blocks.object_version_number%TYPE )IS
     select 'Y'
       from hxc_locks hl,
            hxc_locker_types hlt
          where attribute1 = fnd_global.employee_id
          AND hlt.PROCESS_TYPE = 'APPROVAL_ACTION'
          AND hl.LOCKER_TYPE_ID = hl.LOCKER_TYPE_ID
          AND TIME_BUILDING_BLOCK_ID = p_app_bb_id
          AND TIME_BUILDING_BLOCK_OVN = p_app_bb_ovn
          AND lock_date > (sysdate-(1/24/60)*10);

    CURSOR c_notification_item_keys
      (p_item_type   IN wf_item_activity_statuses.item_type%TYPE
      ,p_approver_id IN number) IS
      SELECT  wias.item_key
      FROM    wf_notifications wn
             ,wf_item_activity_statuses wias
             ,fnd_user fu
      WHERE   wn.recipient_role = fu.user_name
      AND     wn.status = 'OPEN'
      AND     wn.message_name IN ('TIMECARD_APPROVAL','TIMECARD_APPROVAL_INLINE','TIMECARD_APPROVAL_INLINE_ABS')
      AND     wias.notification_id = wn.notification_id
      AND     wias.activity_status = 'NOTIFIED'
      AND     wias.item_type = p_item_type
      AND     fu.employee_id = p_approver_id
      ORDER BY from_user DESC;
    CURSOR c_approval_periods
      (p_app_bb_id  IN hxc_time_building_blocks.time_building_block_id%TYPE
      ,p_app_bb_ovn IN hxc_time_building_blocks.object_version_number%TYPE) IS
      SELECT  /*+ leading(apsum) */
              apsum.application_period_id
             ,apsum.application_period_ovn
             ,apsum.start_time
             ,apsum.stop_time
             ,'' approval_status
             ,ppf.full_name
             ,htbb.comment_text
             ,favtl.application_name
             ,apsum.resource_id
             ,hxc_time_category_utils_pkg.category_app_period_tc_hrs (apsum.start_time
                                                                     ,apsum.stop_time
                                                                     ,apsum.resource_id
                                                                     ,''
                                                                     ,apsum.application_period_id)
             ,hxc_time_category_utils_pkg.category_app_period_tc_hrs (apsum.start_time
                                                                     ,apsum.stop_time
                                                                     ,apsum.resource_id
                                                                     ,'Total2'
                                                                     ,apsum.application_period_id)
             ,hxc_time_category_utils_pkg.category_app_period_tc_hrs (apsum.start_time
                                                                     ,apsum.stop_time
                                                                     ,apsum.resource_id
                                                                     ,'Total3'
                                                                     ,apsum.application_period_id)
             ,apsum.time_recipient_id
             ,nvl (ppf.employee_number
                  ,ppf.npw_number)
             ,get_translated_name (hts.transferred_to) transferred_to
      FROM    hxc_app_period_summary apsum
             ,hxc_time_building_blocks htbb
             ,fnd_application_tl favtl
             ,per_all_people_f ppf
             ,hxc_time_recipients htr
             ,hxc_tc_ap_links htal
             ,hxc_timecard_summary hts
      WHERE   apsum.application_period_id = p_app_bb_id
      AND     apsum.application_period_ovn = p_app_bb_ovn
      AND     htal.application_period_id = apsum.application_period_id
      AND     hts.timecard_id = htal.timecard_id
      AND     apsum.resource_id = ppf.person_id
      AND     trunc (sysdate) BETWEEN ppf.effective_start_date
                              AND     ppf.effective_end_date
      AND     htbb.time_building_block_id = apsum.application_period_id
      AND     htbb.object_version_number = apsum.application_period_ovn
      AND     favtl.application_id = htr.application_id
      AND     htr.time_recipient_id = apsum.time_recipient_id
      AND     favtl.language = userenv ('LANG');
  BEGIN
    IF g_debug THEN
      l_proc := 'get_approval_notifications';

      hr_utility.set_location (g_package
                               || l_proc
                              ,10);
    END IF;

    release_locks;

    SELECT  hxc_transaction_lock_s.nextval
    INTO    g_transaction_id
    FROM    dual;

    p_approval_array := hxc_notification_table_type ();

    l_approval_array := hxc_notification_table_type ();

    IF g_debug THEN
      hr_utility.set_location (g_package
                               || l_proc
                              ,20);
    END IF;

    OPEN c_notification_item_keys
                                   (p_item_type   => l_item_type
                                   ,p_approver_id => p_approver_id );

    LOOP
      FETCH c_notification_item_keys
        INTO    l_item_key;

      EXIT WHEN c_notification_item_keys%NOTFOUND;

      l_match := TRUE;

      IF p_resource_id IS NOT NULL THEN
        SELECT  number_value
        INTO    l_resource_id
        FROM    wf_item_attribute_values
        WHERE   item_type = l_item_type
        AND     item_key = l_item_key
        AND     name = 'RESOURCE_ID';

        IF l_resource_id IS NOT NULL
           AND l_resource_id = to_number (p_resource_id) THEN
          NULL;
        ELSE
          l_match := FALSE;
        END IF;
      END IF;

      IF g_debug THEN
        hr_utility.set_location (g_package
                                 || l_proc
                                ,30);
      END IF;

      IF l_match THEN
        IF p_from_date IS NOT NULL THEN
          SELECT  date_value
          INTO    l_end_date
          FROM    wf_item_attribute_values
          WHERE   item_type = l_item_type
          AND     item_key = l_item_key
          AND     name = 'APP_END_DATE';

          IF trunc (l_end_date) < to_date (p_from_date
                                          ,'YYYY/MM/DD') THEN
            l_match := FALSE;
          END IF;
        END IF;
      END IF;

      IF g_debug THEN
        hr_utility.set_location (g_package
                                 || l_proc
                                ,40);
      END IF;

      IF l_match THEN
        IF p_to_date IS NOT NULL THEN
          SELECT  date_value
          INTO    l_start_date
          FROM    wf_item_attribute_values
          WHERE   item_type = l_item_type
          AND     item_key = l_item_key
          AND     name = 'APP_START_DATE';

          IF trunc (l_start_date) > to_date (p_to_date
                                            ,'YYYY/MM/DD') THEN
            l_match := FALSE;
          END IF;
        END IF;
      END IF;

      IF g_debug THEN
        hr_utility.set_location (g_package
                                 || l_proc
                                ,50);
      END IF;

      IF l_match THEN
        SELECT  number_value
        INTO    l_app_bb_id
        FROM    wf_item_attribute_values
        WHERE   item_type = l_item_type
        AND     item_key = l_item_key
        AND     name = 'APP_BB_ID';

        SELECT  number_value
        INTO    l_app_bb_ovn
        FROM    wf_item_attribute_values
        WHERE   item_type = l_item_type
        AND     item_key = l_item_key
        AND     name = 'APP_BB_OVN';

        IF g_debug THEN
          hr_utility.set_location (g_package
                                   || l_proc
                                  ,60);
        END IF;

        l_approval_status := hr_general.decode_lookup ('HXC_APPROVAL_MODE'
                                                      ,'PENDING');

        OPEN c_approval_periods
                                 (p_app_bb_id  => l_app_bb_id
                                 ,p_app_bb_ovn => l_app_bb_ovn );

        FETCH c_approval_periods
          INTO    l_approval_record;

        IF c_approval_periods%NOTFOUND THEN
          NULL;
        ELSE
          l_lock_id := NULL;

           -- 22811468
          l_true := 'N';

          OPEN check_lock(l_app_bb_id,l_app_bb_ovn);
          FETCH check_lock into l_true;
          CLOSE check_lock;

           IF l_true = 'N' THEN
          hxc_lock_api.request_lock
                                     (p_process_locker_type     => hxc_lock_util.c_ss_approval_action
                                     ,p_time_building_block_id  => l_app_bb_id
                                     ,p_time_building_block_ovn => l_app_bb_ovn
                                     ,p_transaction_lock_id     => g_transaction_id
                                     ,p_messages                => l_messages
                                     ,p_row_lock_id             => l_lock_id
                                     ,p_locked_success          => l_success );
          ELSE
          l_success := true;
         END IF;

          IF l_success THEN
            IF g_debug THEN
              hr_utility.set_location (g_package
                                       || l_proc
                                      ,70);
            END IF;

            l_approval_array.extend;

            l_array_index := l_array_index + 1;

            l_approval_array (l_array_index) := hxc_notification_type (l_approval_record.time_building_block_id
                                                                      ,l_approval_record.object_version_number
                                                                      ,l_approval_record.start_time
                                                                      ,l_approval_record.stop_time
                                                                      ,l_approval_status
                                                                      ,l_approval_record.employee_name
                                                                      ,l_approval_record.comment_text
                                                                      ,get_name (p_approver_id)
                                                                      ,l_approval_record.application_name
                                                                      ,l_item_key
                                                                      ,l_approval_record.resource_id
                                                                      ,l_approval_record.total_hours
                                                                      ,l_approval_record.premium_hours
                                                                      ,l_approval_record.non_worked_hours
                                                                      ,l_approval_record.time_recipient_id
                                                                      ,l_approval_record.employee_number
                                                                      ,l_approval_record.transferred_to);
          END IF;
        END IF;

        CLOSE c_approval_periods;
      END IF;
    END LOOP;

    CLOSE c_notification_item_keys;

    IF g_debug THEN
      hr_utility.set_location (g_package
                               || l_proc
                              ,80);
    END IF;

    IF l_approval_array.count = 0 THEN
      RETURN;
    END IF;

    IF p_adv_search IS NOT NULL THEN
      IF g_debug THEN
        hr_utility.set_location (g_package
                                 || l_proc
                                ,90);
      END IF;

      adv_search
                  (p_block_ids    => get_block_ids (l_approval_array)
                  ,p_adv_search   => p_adv_search
                  ,p_selected_ids => l_selected_ids );

      IF g_debug THEN
        hr_utility.set_location (g_package
                                 || l_proc
                                ,100);
      END IF;

      IF l_selected_ids.count > 0 THEN
        IF g_debug THEN
          hr_utility.set_location (g_package
                                   || l_proc
                                  ,110);
        END IF;

        l_index := l_approval_array.first;

        LOOP
          EXIT WHEN NOT l_approval_array.exists (l_index);

          IF is_selected (l_selected_ids
                         ,l_approval_array (l_index).time_building_block_id) THEN
            add_records (p_approval_array
                        ,l_approval_array (l_index));
          END IF;

          l_index := l_approval_array.next (l_index);
        END LOOP;

        IF g_debug THEN
          hr_utility.set_location (g_package
                                   || l_proc
                                  ,120);
        END IF;
      END IF;
    ELSE
      IF g_debug THEN
        hr_utility.set_location (g_package
                                 || l_proc
                                ,130);
      END IF;

      p_approval_array := l_approval_array;

      IF g_debug THEN
        hr_utility.set_location (g_package
                                 || l_proc
                                ,140);
      END IF;
    END IF;

    IF g_debug THEN
      hr_utility.set_location (g_package
                               || l_proc
                              ,150);
    END IF;
  END get_open_notifications;

  PROCEDURE get_approval_history
    (p_approver_id    IN         number
    ,p_approval_array OUT NOCOPY hxc_notification_table_type
    ,p_resource_id    IN         varchar2
    ,p_from_date      IN         varchar2
    ,p_to_date        IN         varchar2
    ,p_adv_search     IN         varchar2) IS
    CURSOR c_app_periods
      (p_approver_id IN hxc_time_building_blocks.time_building_block_id%TYPE) IS
      SELECT  /*+ leading(apsum) */
              apsum.application_period_id
             ,apsum.application_period_ovn
             ,apsum.start_time
             ,apsum.stop_time
             ,hr_general.decode_lookup ('HXC_APPROVAL_STATUS'
                                       ,apsum.approval_status)
             ,ppf.full_name
             ,htbb.comment_text
             ,favtl.application_name
             ,apsum.resource_id
             ,hxc_time_category_utils_pkg.category_app_period_tc_hrs (apsum.start_time
                                                                     ,apsum.stop_time
                                                                     ,apsum.resource_id
                                                                     ,''
                                                                     ,apsum.application_period_id)
             ,hxc_time_category_utils_pkg.category_app_period_tc_hrs (apsum.start_time
                                                                     ,apsum.stop_time
                                                                     ,apsum.resource_id
                                                                     ,'Total2'
                                                                     ,apsum.application_period_id)
             ,hxc_time_category_utils_pkg.category_app_period_tc_hrs (apsum.start_time
                                                                     ,apsum.stop_time
                                                                     ,apsum.resource_id
                                                                     ,'Total3'
                                                                     ,apsum.application_period_id)
             ,apsum.time_recipient_id
             ,nvl (ppf.employee_number
                  ,ppf.npw_number)
             ,get_translated_name (hts.transferred_to) transferred_to
      FROM    hxc_app_period_summary apsum
             ,hxc_time_building_blocks htbb
             ,fnd_application_tl favtl
             ,per_all_people_f ppf
             ,hxc_time_recipients htr
             ,hxc_tc_ap_links htal
             ,hxc_timecard_summary hts
      WHERE   apsum.approver_id = p_approver_id
      AND     apsum.approval_status <> 'SUBMITTED'
      AND     htal.application_period_id = apsum.application_period_id
      AND     hts.timecard_id = htal.timecard_id
      AND     apsum.resource_id = ppf.person_id
      AND     trunc (sysdate) BETWEEN ppf.effective_start_date
                              AND     ppf.effective_end_date
      AND     htbb.time_building_block_id = apsum.application_period_id
      AND     htbb.object_version_number = apsum.application_period_ovn
      AND     favtl.application_id = htr.application_id
      AND     htr.time_recipient_id = apsum.time_recipient_id
      AND     favtl.language = userenv ('LANG')
      AND     nvl (p_resource_id
                  ,apsum.resource_id) = apsum.resource_id
      AND     nvl (p_from_date
                  ,to_char (apsum.stop_time
                           ,'YYYY/MM/DD')) <= to_char (apsum.stop_time
                                                      ,'YYYY/MM/DD')
      AND     nvl (p_to_date
                  ,to_char (apsum.start_time
                           ,'YYYY/MM/DD')) >= to_char (apsum.start_time
                                                      ,'YYYY/MM/DD')
      ORDER BY ppf.full_name DESC
              ,apsum.start_time DESC;
    l_approval_record approval_notification;
    l_approval_array hxc_notification_table_type;
    l_array_index number DEFAULT 0;
    l_selected_ids hxc_deposit_wrapper_utilities.t_simple_table;
    l_index number;
    l_proc varchar2(500);
  BEGIN
    p_approval_array := hxc_notification_table_type ();

    l_approval_array := hxc_notification_table_type ();

    OPEN c_app_periods (p_approver_id);

    LOOP
      FETCH c_app_periods
        INTO    l_approval_record;

      EXIT WHEN c_app_periods%NOTFOUND;

      IF g_debug THEN
        l_proc := 'get_approval_history';

        hr_utility.set_location (g_package
                                 || l_proc
                                ,70);
      END IF;

      l_approval_array.extend;

      l_array_index := l_array_index + 1;

      l_approval_array (l_array_index) := hxc_notification_type (l_approval_record.time_building_block_id
                                                                ,l_approval_record.object_version_number
                                                                ,l_approval_record.start_time
                                                                ,l_approval_record.stop_time
                                                                ,l_approval_record.approval_status
                                                                ,l_approval_record.employee_name
                                                                ,l_approval_record.comment_text
                                                                ,get_name (p_approver_id)
                                                                ,l_approval_record.application_name
                                                                ,''
                                                                ,l_approval_record.resource_id
                                                                ,l_approval_record.total_hours
                                                                ,l_approval_record.premium_hours
                                                                ,l_approval_record.non_worked_hours
                                                                ,l_approval_record.time_recipient_id
                                                                ,l_approval_record.employee_number
                                                                ,l_approval_record.transferred_to);
    END LOOP;

    CLOSE c_app_periods;

    IF l_approval_array.count = 0 THEN
      RETURN;
    END IF;

    IF p_adv_search IS NOT NULL THEN
      IF g_debug THEN
        hr_utility.set_location (g_package
                                 || l_proc
                                ,90);
      END IF;

      adv_search
                  (p_block_ids    => get_block_ids (l_approval_array)
                  ,p_adv_search   => p_adv_search
                  ,p_selected_ids => l_selected_ids );

      IF g_debug THEN
        hr_utility.set_location (g_package
                                 || l_proc
                                ,100);
      END IF;

      IF l_selected_ids.count > 0 THEN
        IF g_debug THEN
          hr_utility.set_location (g_package
                                   || l_proc
                                  ,110);
        END IF;

        l_index := l_approval_array.first;

        LOOP
          EXIT WHEN NOT l_approval_array.exists (l_index);

          IF is_selected (l_selected_ids
                         ,l_approval_array (l_index).time_building_block_id) THEN
            add_records (p_approval_array
                        ,l_approval_array (l_index));
          END IF;

          l_index := l_approval_array.next (l_index);
        END LOOP;

        IF g_debug THEN
          hr_utility.set_location (g_package
                                   || l_proc
                                  ,120);
        END IF;
      END IF;
    ELSE
      IF g_debug THEN
        hr_utility.set_location (g_package
                                 || l_proc
                                ,130);
      END IF;

      p_approval_array := l_approval_array;

      IF g_debug THEN
        hr_utility.set_location (g_package
                                 || l_proc
                                ,140);
      END IF;
    END IF;

    IF g_debug THEN
      hr_utility.set_location (g_package
                               || l_proc
                              ,150);
    END IF;
  END get_approval_history;

  PROCEDURE get_approval_notifications
    (p_approver_id    IN         number
    ,p_approval_array OUT NOCOPY hxc_notification_table_type
    ,p_resource_id    IN         varchar2
    ,p_from_date      IN         varchar2
    ,p_to_date        IN         varchar2
    ,p_adv_search     IN         varchar2
    ,p_mode           IN         varchar2                    DEFAULT 'PENDING') IS
  BEGIN
    IF p_mode = 'PENDING' THEN
      get_open_notifications
                              (p_approver_id    => p_approver_id
                              ,p_approval_array => p_approval_array
                              ,p_resource_id    => p_resource_id
                              ,p_from_date      => p_from_date
                              ,p_to_date        => p_to_date
                              ,p_adv_search     => p_adv_search );
    ELSE
      get_approval_history
                            (p_approver_id    => p_approver_id
                            ,p_approval_array => p_approval_array
                            ,p_resource_id    => p_resource_id
                            ,p_from_date      => p_from_date
                            ,p_to_date        => p_to_date
                            ,p_adv_search     => p_adv_search );
    END IF;
  END get_approval_notifications;

  FUNCTION get_application_name
    (p_application_name IN varchar2
    ,p_session_lang     IN varchar2) RETURN varchar2 IS
    CURSOR translated_name
      (p_application_name IN varchar2
      ,p_session_lang     IN varchar2) IS
      SELECT  /*+ RESULT_CACHE */
              tl.application_name
      FROM    fnd_application_tl tl
             ,hxc_time_recipients tr
      WHERE   tr.application_id = tl.application_id
      AND     tr.name = p_application_name
      AND     tl.language = p_session_lang;
    v_translated_name varchar2(80) DEFAULT NULL;
  BEGIN
    IF g_debug THEN
      hr_utility.trace ('Test Translation:Splitted eng Name '
                        || p_application_name);
    END IF;

    IF p_application_name IS NOT NULL THEN
      OPEN translated_name (p_application_name
                           ,p_session_lang);

      FETCH translated_name
        INTO    v_translated_name;

      IF v_translated_name IS NULL THEN
        v_translated_name := p_application_name;
      END IF;

      CLOSE translated_name;
    END IF;

    IF p_application_name IS NULL THEN
      v_translated_name := p_application_name;
    END IF;

    IF g_debug THEN
      hr_utility.trace ('Test Translation:Splitted TL Name '
                        || v_translated_name);
    END IF;

    RETURN v_translated_name;
  END get_application_name;

  FUNCTION get_translated_name
  (p_concatenated_name IN varchar2) RETURN varchar2 IS
  CURSOR translated_name_cur IS
    SELECT  /*+ RESULT_CACHE */
            regexp_substr (p_concatenated_name
                          ,'[^,]+'
                          ,1
                          ,level)
    FROM    dual
    CONNECT BY regexp_substr (p_concatenated_name
                          ,'[^,]+'
                          ,1
                          ,level) IS NOT NULL;
  v_splitted_english_name varchar2(100);
  v_translated_name varchar2(500) DEFAULT '';
  l_index varchar2(150) DEFAULT p_concatenated_name
                                || '#'
                                || userenv ('LANG');
BEGIN
  IF g_debug THEN
    hr_utility.trace ('Test Translation:Concated eng name '
                      || p_concatenated_name);

    hr_utility.trace ('Test Translation:Session id '
                      || userenv ('sessionid'));
  END IF;

  IF g_translated_name.exists (l_index) THEN
    IF g_debug THEN
      hr_utility.trace ('Test Translation:Returning from cache '
                        || g_translated_name (l_index));
    END IF;

    RETURN g_translated_name (l_index);
  ELSE
    IF p_concatenated_name IS NULL THEN
      v_translated_name := hr_general.decode_lookup ('HXC_DISCONNECTED_ENTRY'
                                                    ,'NONE');

      IF g_debug THEN
        hr_utility.trace ('Test Translation:Giving it as none '
                          || v_translated_name);
      END IF;
    ELSE
      OPEN translated_name_cur;

      LOOP
        FETCH translated_name_cur
          INTO    v_splitted_english_name;

        EXIT WHEN translated_name_cur%NOTFOUND;

        IF v_translated_name IS NULL THEN
          v_translated_name := get_application_name (v_splitted_english_name
                                                    ,userenv ('LANG'));
        ELSE
          v_translated_name := v_translated_name
                               || ','
                               || get_application_name (v_splitted_english_name
                                                       ,userenv ('LANG'));
        END IF;
      END LOOP;

      CLOSE translated_name_cur;

      IF g_debug THEN
        hr_utility.trace ('Test Translation:Concated tl name '
                          || v_translated_name);
      END IF;
    END IF;

    g_translated_name (l_index) := v_translated_name;

    RETURN v_translated_name;
  END IF;
END get_translated_name;
END hxc_approval_utilities;

/
