--------------------------------------------------------
--  DDL for Package Body HXC_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_DRT_PKG" as
/* $Header: hxcdrt.pkb 120.0.12010000.11 2018/07/19 05:22:40 rpakalap noship $ */
  PROCEDURE add_to_results
    (person_id   IN            number
    ,entity_type IN            varchar2
    ,status      IN            varchar2
    ,msgcode     IN            varchar2
    ,msgaplid    IN            number
    ,result_tbl  IN OUT NOCOPY per_drt_pkg.result_tbl_type) IS
    n number(15);
  BEGIN
    n := result_tbl.count + 1;

    result_tbl (n).person_id := person_id;

    result_tbl (n).entity_type := entity_type;

    result_tbl (n).status := status;

    result_tbl (n).msgcode := msgcode;

    result_tbl (n).msgaplid := msgaplid;
  END add_to_results;

  PROCEDURE hxc_hr_drc
    (p_person_id  IN         number
    ,p_result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) IS
  BEGIN
    timecards_drc (p_person_id
                  ,p_result_tbl);
  END hxc_hr_drc;

  PROCEDURE hxc_hr_post
    (p_person_id IN number) IS
  BEGIN
    remove_timecards (p_person_id);
  END hxc_hr_post;

  PROCEDURE timecards_drc
    (p_person_id  IN         number
    ,p_result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) IS
    CURSOR get_pending_tc IS
      SELECT  'Y'
      FROM    hxc_latest_details hld
             ,hxc_retrieval_processes hrp
      WHERE   hld.resource_id = p_person_id
      AND     hld.approval_status = 'SUBMITTED'
      AND     (
                      EXISTS
                      (
                      SELECT  'Y'
                      FROM    hxc_transaction_details htd
                             ,hxc_transactions ht
                      WHERE   htd.time_building_block_id = hld.time_building_block_id
                      AND     htd.status = 'SUCCESS'
                      AND     ht.transaction_id = htd.transaction_id
                      AND     ht.status = 'SUCCESS'
                      AND     ht.transaction_process_id = hrp.retrieval_process_id
                      AND     hld.object_version_number > htd.time_building_block_ovn
                      )
              AND     NOT EXISTS
                          (
                          SELECT  'Y'
                          FROM    hxc_transaction_details htd
                                 ,hxc_transactions ht
                          WHERE   htd.time_building_block_id = hld.time_building_block_id
                          AND     htd.status = 'SUCCESS'
                          AND     ht.transaction_id = htd.transaction_id
                          AND     ht.status = 'SUCCESS'
                          AND     ht.transaction_process_id = hrp.retrieval_process_id
                          AND     hld.object_version_number = htd.time_building_block_ovn
                          )
              )
    ;
    l_flag varchar2(5);
    l_return_code varchar2(5);
  BEGIN
    OPEN get_pending_tc;

    FETCH get_pending_tc
      INTO    l_flag;

    CLOSE get_pending_tc;

    IF l_flag IS NOT NULL THEN
      hr_utility.trace ('Pending timecards for the user');

      add_to_results
                      (person_id   => p_person_id
                      ,entity_type => 'HR'
                      ,status      => 'E'
                      ,msgcode     => 'HXC_DRT_DRC_ERR1'
                      ,msgaplid    => 809
                      ,result_tbl  => p_result_tbl );
    ELSE
      l_return_code := 'S';

      add_to_results
                      (person_id   => p_person_id
                      ,entity_type => 'HR'
                      ,status      => 'S'
                      ,msgcode     => NULL
                      ,msgaplid    => NULL
                      ,result_tbl  => p_result_tbl );
    END IF;
  EXCEPTION
    WHEN others THEN
      hr_utility.trace ('Error in Timecards DRC');

      hr_utility.trace (sqlerrm);

      hr_utility.trace (dbms_utility.format_error_backtrace);

      add_to_results
                      (person_id   => p_person_id
                      ,entity_type => 'HR'
                      ,status      => 'E'
                      ,msgcode     => 'HXC_DRT_DRC_ERR1'
                      ,msgaplid    => 809
                      ,result_tbl  => p_result_tbl );
  END timecards_drc;

  PROCEDURE remove_timecards
    (p_person_id IN number) IS
    l_act_tc_tbb numtab;
    l_act_tc_stt datetab;
    l_act_tc_spt datetab;
    l_arc_tc_tbb numtab;
    l_arc_tc_stt datetab;
    l_arc_tc_spt datetab;
    l_return_code varchar2(5);
    CURSOR get_active_tc IS
      SELECT  DISTINCT
              time_building_block_id
             ,trunc (start_time)
             ,trunc (stop_time)
      FROM    hxc_time_building_blocks
      WHERE   resource_id = p_person_id
      AND     scope = 'TIMECARD';
	  --28355886
    CURSOR get_archive_tc IS
      SELECT  DISTINCT
              tim_summ.timecard_id
             ,trunc (tim_summ.start_time)
             ,trunc (tim_summ.stop_time)
      FROM    hxc_time_building_blocks_ar ar
             ,hxc_timecard_summary tim_summ
      WHERE   tim_summ.resource_id = p_person_id
      AND     tim_summ.timecard_id = ar.time_building_block_id;
  BEGIN
    OPEN get_active_tc;

    FETCH get_active_tc
      BULK COLLECT INTO l_act_tc_tbb
                       ,l_act_tc_stt
                       ,l_act_tc_spt;

    CLOSE get_active_tc;

    IF l_act_tc_tbb.count > 0 THEN
      FOR i IN l_act_tc_tbb.first .. l_act_tc_tbb.last LOOP
        delete_act_tc (p_person_id
                      ,l_act_tc_stt (i)
                      ,l_act_tc_spt (i)
                      ,l_act_tc_tbb (i));
      END LOOP;
    ELSE
      hr_utility.trace ('No active timecards');
    END IF;

    OPEN get_archive_tc;

    FETCH get_archive_tc
      BULK COLLECT INTO l_arc_tc_tbb
                       ,l_arc_tc_stt
                       ,l_arc_tc_spt;

    CLOSE get_archive_tc;

    IF l_arc_tc_tbb.count > 0 THEN
      FOR k IN l_arc_tc_tbb.first .. l_arc_tc_tbb.last LOOP
        delete_arc_tc (p_person_id
                      ,l_arc_tc_stt (k)
                      ,l_arc_tc_spt (k)
                      ,l_arc_tc_tbb (k));
      END LOOP;
    ELSE
      hr_utility.trace ('No archived timecards');
    END IF;

    delete_otlr_tc (p_person_id);
  END remove_timecards;

  PROCEDURE delete_act_tc
    (p_resource_id IN number
    ,p_start_time  IN date
    ,p_stop_time   IN date
    ,p_timecard_id IN number) IS
    CURSOR building_block_id_csr
      (c_resource_id            IN number
      ,c_time_building_block_id IN number) IS
      SELECT  time_building_block_id
      FROM    hxc_time_building_blocks
      START WITH resource_id = c_resource_id
      AND     time_building_block_id = c_time_building_block_id
      CONNECT BY PRIOR time_building_block_id = parent_building_block_id
      AND     PRIOR object_version_number = parent_building_block_ovn
      ORDER BY time_building_block_id;
    CURSOR app_period_csr
      (c_resource_id            IN number
      ,c_time_building_block_id IN number) IS
      SELECT  time_building_block_id
      FROM    hxc_time_building_blocks
      WHERE   scope = 'APPLICATION_PERIOD'
      AND     resource_id IN (c_resource_id)
      AND     time_building_block_id = c_time_building_block_id;
    tbb_id_tab numtab;
    app_period_tab numtab;
    l_resource_id number;
    l_start_time date;
    l_stop_time date;
    l_item_key wf_items.item_key%TYPE;
    l_time_building_block_id number;
  BEGIN
    hr_utility.trace ('Start processing...');

    l_resource_id := p_resource_id;

    l_start_time := p_start_time;

    l_stop_time := p_stop_time;

    l_time_building_block_id := p_timecard_id;

    OPEN app_period_csr (l_resource_id
                        ,l_time_building_block_id);

    FETCH app_period_csr
      BULK COLLECT INTO app_period_tab;

    CLOSE app_period_csr;

    OPEN building_block_id_csr (l_resource_id
                               ,l_time_building_block_id);

    FETCH building_block_id_csr
      BULK COLLECT INTO tbb_id_tab;

    CLOSE building_block_id_csr;

    hr_utility.trace ('tbb_id_tab.COUNT = '
                      || tbb_id_tab.count);

    IF (tbb_id_tab.count > 0) THEN
      FORALL i IN tbb_id_tab.first .. tbb_id_tab.last
        DELETE
        FROM    hxc_time_building_blocks
        WHERE   time_building_block_id = tbb_id_tab (i);

      hr_utility.trace ('Deleted from hxc_time_building_blocks... ');

      FORALL i IN tbb_id_tab.first .. tbb_id_tab.last
        DELETE
        FROM    hxt_det_hours_worked_f
        WHERE   parent_id IN
                (
                SELECT  id
                FROM    hxt_sum_hours_worked_f
                WHERE   time_building_block_id = tbb_id_tab (i)
                );

      hr_utility.trace ('Deleted from hxt_det_hours_worked_f.. ');

      FORALL i IN tbb_id_tab.first .. tbb_id_tab.last
        DELETE
        FROM    hxt_sum_hours_worked_f
        WHERE   time_building_block_id = tbb_id_tab (i);

      hr_utility.trace ('Deleted from hxt_sum_hours_worked_f.. ');

      FORALL i IN tbb_id_tab.first .. tbb_id_tab.last
        DELETE
        FROM    hxc_time_attributes
        WHERE   time_attribute_id IN
                (
                SELECT  time_attribute_id
                FROM    hxc_time_attribute_usages
                WHERE   time_building_block_id = tbb_id_tab (i)
                );

      hr_utility.trace ('Deleted from hxc_time_attributes... ');

      FORALL i IN tbb_id_tab.first .. tbb_id_tab.last
        DELETE
        FROM    hxc_time_attribute_usages
        WHERE   time_building_block_id = tbb_id_tab (i);

      hr_utility.trace ('Deleted from hxc_time_attribute_usages... ');

      FORALL i IN tbb_id_tab.first .. tbb_id_tab.last
        DELETE
        FROM    hxc_tc_ap_links
        WHERE   timecard_id = tbb_id_tab (i);

      hr_utility.trace ('Deleted from hxc_tc_ap_links... ');

      FORALL i IN tbb_id_tab.first .. tbb_id_tab.last
        DELETE
        FROM    hxc_latest_details
        WHERE   time_building_block_id = tbb_id_tab (i);

      hr_utility.trace ('Deleted from hxc_latest_details... ');

      FORALL i IN tbb_id_tab.first .. tbb_id_tab.last
        DELETE
        FROM    hxc_ap_detail_links
        WHERE   time_building_block_id = tbb_id_tab (i);

      hr_utility.trace ('Deleted from hxc_ap_detail_links... ');

      FORALL i IN tbb_id_tab.first .. tbb_id_tab.last
        DELETE
        FROM    hxc_pa_latest_details
        WHERE   time_building_block_id = tbb_id_tab (i);

      hr_utility.trace ('Deleted from hxc_pa_latest_details... ');

      FORALL i IN tbb_id_tab.first .. tbb_id_tab.last
        DELETE
        FROM    hxc_pay_latest_details
        WHERE   time_building_block_id = tbb_id_tab (i);

      hr_utility.trace ('Deleted from hxc_pay_latest_details... ');

      BEGIN
        FOR i IN tbb_id_tab.first .. tbb_id_tab.last LOOP
          SELECT  approval_item_key
          INTO    l_item_key
          FROM    hxc_timecard_summary
          WHERE   timecard_id = tbb_id_tab (i);

          wf_engine.abortprocess ('HXCEMP'
                                 ,l_item_key);

          wf_purge.items ('HXCEMP'
                         ,l_item_key
                         ,sysdate
                         ,FALSE);
        END LOOP;
      EXCEPTION
        WHEN no_data_found THEN
          hr_utility.trace ('There is no workflow found');
        WHEN others THEN
          hr_utility.trace ('Workflow not found');
      END;

      FORALL i IN tbb_id_tab.first .. tbb_id_tab.last
        DELETE
        FROM    hxc_timecard_summary
        WHERE   timecard_id = tbb_id_tab (i);

      hr_utility.trace ('Deleted from hxc_timecard_summary... ');
    END IF;

    hr_utility.trace ('Process the application periods... ');

    hr_utility.trace ('app_period_tab.COUNT = '
                      || app_period_tab.count);

    IF (app_period_tab.count > 0) THEN
      BEGIN
        FOR i IN app_period_tab.first .. app_period_tab.last LOOP
          SELECT  approval_item_key
          INTO    l_item_key
          FROM    hxc_app_period_summary
          WHERE   application_period_id = app_period_tab (i);

          wf_engine.abortprocess ('HXCEMP'
                                 ,l_item_key);

          wf_purge.items ('HXCEMP'
                         ,l_item_key
                         ,sysdate
                         ,FALSE);
        END LOOP;
      EXCEPTION
        WHEN no_data_found THEN
          hr_utility.trace ('There is no workflow found1');
        WHEN others THEN
          hr_utility.trace ('Workflow not found1');
      END;

      FORALL i IN app_period_tab.first .. app_period_tab.last
        DELETE
        FROM    hxc_app_period_summary
        WHERE   application_period_id = app_period_tab (i);

      hr_utility.trace ('Deleted from hxc_app_period_summary... ');
    END IF;

    DELETE
    FROM    hxc_rpt_tc_details_all
    WHERE   resource_id = p_resource_id;

    DELETE
    FROM    hxc_rpt_tc_hist_log
    WHERE   resource_id = p_resource_id;

    DELETE
    FROM    hxc_rdb_pre_details
    WHERE   resource_id = p_resource_id;

    DELETE
    FROM    hxc_rdb_pre_hrs_pm
    WHERE   resource_id = p_resource_id;

    DELETE
    FROM    hxc_rdb_pre_skipped
    WHERE   resource_id = p_resource_id;

    DELETE
    FROM    hxc_rdb_pre_timecards
    WHERE   resource_id = p_resource_id;

    DELETE
    FROM    hxc_rdb_pre_updated
    WHERE   resource_id = p_resource_id;

    DELETE
    FROM    hxc_rdb_process_timecards
    WHERE   resource_id = p_resource_id;

    DELETE
    FROM    hxc_rdb_post_hrs_pm
    WHERE   resource_id = p_resource_id;

    DELETE
    FROM    hxc_rdb_post_timecards
    WHERE   resource_id = p_resource_id;

    DELETE
    FROM    hxc_rdb_post_details
    WHERE   resource_id = p_resource_id;

    DELETE
    FROM    hxc_rdb_process_details
    WHERE   resource_id = p_resource_id;

    BEGIN
      EXECUTE IMMEDIATE
        'DELETE
    FROM    hxc_tcd_timecards
    WHERE   resource_id = :1 '
      USING p_resource_id;
    EXCEPTION
      WHEN table_not_found THEN
        BEGIN
          hr_utility.trace (' hxc_tcd_timecards Table not found exception. Hence ignoring');
        END;
    END;

    BEGIN
      EXECUTE IMMEDIATE
        'DELETE
    FROM    hxc_tcd_status_count
    WHERE   supervisor_id = :1 '
      USING p_resource_id;
    EXCEPTION
      WHEN table_not_found THEN
        BEGIN
          hr_utility.trace (' hxc_tcd_status_count Table not found exception. Hence ignoring');
        END;
    END;

    BEGIN
      EXECUTE IMMEDIATE
        'DELETE
    FROM    hxc_mob_transit_details
    WHERE   resource_id = :1 '
      USING p_resource_id;
    EXCEPTION
      WHEN table_not_found THEN
        BEGIN
          hr_utility.trace (' hxc_mob_transit_details Table not found exception. Hence ignoring');
        END;
    END;

    BEGIN
      EXECUTE IMMEDIATE
        'DELETE
    FROM    hxc_mob_transit_timecards
    WHERE   resource_id = :1 '
      USING p_resource_id;
    EXCEPTION
      WHEN table_not_found THEN
        BEGIN
          hr_utility.trace (' hxc_mob_transit_timecards Table not found exception. Hence ignoring');
        END;
    END;

    BEGIN
      EXECUTE IMMEDIATE
        'DELETE
    FROM    hxc_rdb_pre_missing_tc
    WHERE   person_id  = :1 '
      USING p_resource_id;
    EXCEPTION
      WHEN table_not_found THEN
        BEGIN
          hr_utility.trace (' hxc_rdb_pre_missing_tc Table not found exception. Hence ignoring');
        END;
    END;

    BEGIN
      EXECUTE IMMEDIATE
        'DELETE
    FROM    hxc_auth_delegate_person_list
    WHERE   resourceid   = :1 '
      USING p_resource_id;
    EXCEPTION
      WHEN table_not_found THEN
        BEGIN
          hr_utility.trace (' hxc_auth_delegate_person_list Table not found exception. Hence ignoring');
        END;
    END;
  END delete_act_tc;

  PROCEDURE delete_arc_tc
    (p_resource_id IN number
    ,p_start_time  IN date
    ,p_stop_time   IN date
    ,p_timecard_id IN number) IS
    CURSOR building_block_id_csr
      (c_resource_id            IN number
      ,c_time_building_block_id IN number) IS
      SELECT  time_building_block_id
      FROM    hxc_time_building_blocks_ar
      START WITH resource_id = c_resource_id
      AND     time_building_block_id = c_time_building_block_id
      CONNECT BY PRIOR time_building_block_id = parent_building_block_id
      AND     PRIOR object_version_number = parent_building_block_ovn
      ORDER BY time_building_block_id;
    CURSOR app_period_csr
      (c_resource_id            IN number
      ,c_time_building_block_id IN number) IS
      SELECT  time_building_block_id
      FROM    hxc_time_building_blocks_ar
      WHERE   scope = 'APPLICATION_PERIOD'
      AND     resource_id IN (c_resource_id)
      AND     time_building_block_id = c_time_building_block_id;
    TYPE numtab IS TABLE OF number INDEX BY binary_integer;
    tbb_id_tab numtab;
    app_period_tab numtab;
    l_resource_id number;
    l_start_time date;
    l_stop_time date;
    l_item_key wf_items.item_key%TYPE;
    l_time_building_block_id number;
  BEGIN
    hr_utility.trace ('Start processing...');

    l_resource_id := p_resource_id;

    l_start_time := p_start_time;

    l_stop_time := p_stop_time;

    l_time_building_block_id := p_timecard_id;

    OPEN app_period_csr (l_resource_id
                        ,l_time_building_block_id);

    FETCH app_period_csr
      BULK COLLECT INTO app_period_tab;

    CLOSE app_period_csr;

    OPEN building_block_id_csr (l_resource_id
                               ,l_time_building_block_id);

    FETCH building_block_id_csr
      BULK COLLECT INTO tbb_id_tab;

    CLOSE building_block_id_csr;

    hr_utility.trace ('tbb_id_tab.COUNT = '
                      || tbb_id_tab.count);

    IF (tbb_id_tab.count > 0) THEN
      FORALL i IN tbb_id_tab.first .. tbb_id_tab.last
        DELETE
        FROM    hxc_time_building_blocks_ar
        WHERE   time_building_block_id = tbb_id_tab (i);

      hr_utility.trace ('Deleted from hxc_time_building_blocks_ar... ');

      FORALL i IN tbb_id_tab.first .. tbb_id_tab.last
        DELETE
        FROM    hxt_det_hours_worked_f_ar
        WHERE   parent_id IN
                (
                SELECT  id
                FROM    hxt_sum_hours_worked_f_ar
                WHERE   time_building_block_id = tbb_id_tab (i)
                );

      hr_utility.trace ('Deleted from hxt_det_hours_worked_f.. ');

      FORALL i IN tbb_id_tab.first .. tbb_id_tab.last
        DELETE
        FROM    hxt_sum_hours_worked_f_ar
        WHERE   time_building_block_id = tbb_id_tab (i);

      hr_utility.trace ('Deleted from hxt_sum_hours_worked_f.. ');

      FORALL i IN tbb_id_tab.first .. tbb_id_tab.last
        DELETE
        FROM    hxc_time_attributes_ar
        WHERE   time_attribute_id IN
                (
                SELECT  time_attribute_id
                FROM    hxc_time_attribute_usages_ar
                WHERE   time_building_block_id = tbb_id_tab (i)
                );

      hr_utility.trace ('Deleted from hxc_time_attributes_ar... ');

      FORALL i IN tbb_id_tab.first .. tbb_id_tab.last
        DELETE
        FROM    hxc_time_attribute_usages_ar
        WHERE   time_building_block_id = tbb_id_tab (i);

      hr_utility.trace ('Deleted from hxc_time_attribute_usages_ar... ');

      FORALL i IN tbb_id_tab.first .. tbb_id_tab.last
        DELETE
        FROM    hxc_tc_ap_links_ar
        WHERE   timecard_id = tbb_id_tab (i);

      hr_utility.trace ('Deleted from hxc_tc_ap_links... ');

      hr_utility.trace ('Deleted from hxc_latest_details_ar... ');

      FORALL i IN tbb_id_tab.first .. tbb_id_tab.last
        DELETE
        FROM    hxc_ap_detail_links_ar
        WHERE   time_building_block_id = tbb_id_tab (i);

      hr_utility.trace ('Deleted from hxc_ap_detail_links_ar... ');
    END IF;

    hr_utility.trace ('Process the application periods... ');

    hr_utility.trace ('app_period_tab.COUNT = '
                      || app_period_tab.count);

    IF (app_period_tab.count > 0) THEN
      BEGIN
        FOR i IN app_period_tab.first .. app_period_tab.last LOOP
          SELECT  approval_item_key
          INTO    l_item_key
          FROM    hxc_app_period_summary_ar
          WHERE   application_period_id = app_period_tab (i);

          wf_engine.abortprocess ('HXCEMP'
                                 ,l_item_key);

          wf_purge.items ('HXCEMP'
                         ,l_item_key
                         ,sysdate
                         ,FALSE);
        END LOOP;
      EXCEPTION
        WHEN no_data_found THEN
          hr_utility.trace ('There is no workflow found1');
        WHEN others THEN
          hr_utility.trace ('Workflow not found1');
      END;

      FORALL i IN app_period_tab.first .. app_period_tab.last
        DELETE
        FROM    hxc_app_period_summary_ar
        WHERE   application_period_id = app_period_tab (i);

      hr_utility.trace ('Deleted from hxc_app_period_summary_ar... ');
    END IF;
  END delete_arc_tc;

  PROCEDURE delete_otlr_tc
    (p_resource_id IN number) IS
    CURSOR get_otlr_tc IS
      SELECT  id
      FROM    hxt_timecards_f
      WHERE   for_person_id = p_resource_id;
    id_tab numtab;
  BEGIN
    OPEN get_otlr_tc;

    FETCH get_otlr_tc
      BULK COLLECT INTO id_tab;

    CLOSE get_otlr_tc;

    IF id_tab.count > 0 THEN
      FOR i IN id_tab.first .. id_tab.last LOOP
        DELETE
        FROM    hxt_sum_hours_worked_f
        WHERE   id IN
                (
                SELECT  parent_id
                FROM    hxt_det_hours_worked_f
                WHERE   tim_id = id_tab (i)
                );

        DELETE
        FROM    hxt_det_hours_worked_f
        WHERE   tim_id = id_tab (i);

        DELETE
        FROM    hxt_timecards_f
        WHERE   id = id_tab (i);
      END LOOP;
    ELSE
      hr_utility.trace ('No OTLR Timecards');
    END IF;
  END delete_otlr_tc;
END hxc_drt_pkg;

/
