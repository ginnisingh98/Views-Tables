--------------------------------------------------------
--  DDL for Package Body WMS_INSERT_WDTH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_INSERT_WDTH_PVT" AS
  /* $Header: WMSWDTHB.pls 120.2 2006/12/05 06:38:35 vpushpa noship $ */

  g_pkg_body_ver  CONSTANT VARCHAR2(100) := '$Header: WMSWDTHB.pls 120.2 2006/12/05 06:38:35 vpushpa noship $';
  g_newline       CONSTANT VARCHAR2(10)  := fnd_global.newline;

  PROCEDURE print_debug
  ( p_msg      IN VARCHAR2
  , p_api_name IN VARCHAR2
  ) IS
  BEGIN
    inv_log_util.trace
    ( p_message => p_msg
    , p_module  => g_pkg_name || '.' || p_api_name
    , p_level   => 4
    );
  END print_debug;



  PROCEDURE print_version_info
    IS
  BEGIN
    print_debug ('Spec::  ' || g_pkg_spec_ver, 'print_version_info');
    print_debug ('Body::  ' || g_pkg_body_ver, 'print_version_info');
  END print_version_info;

  PROCEDURE insert_into_wdth
  ( x_return_status          OUT NOCOPY   VARCHAR2,
    p_txn_header_id          IN           NUMBER,
    p_transaction_temp_id    IN           NUMBER,
    p_transaction_batch_id   IN           NUMBER,
    p_transaction_batch_seq  IN           NUMBER,
    p_transfer_lpn_id        IN           NUMBER) IS
  BEGIN
      insert_into_wdth
        (x_return_status             => x_return_status,
         p_txn_header_id             => p_txn_header_id,
         p_transaction_temp_id       => p_transaction_temp_id,
         p_transaction_batch_id      => p_transaction_batch_id,
         p_transaction_batch_seq     => p_transaction_batch_seq,
         p_transfer_lpn_id           => p_transfer_lpn_id,
         p_status                    => 6);
  END;


  PROCEDURE insert_into_wdth
  ( x_return_status          OUT NOCOPY   VARCHAR2,
    p_txn_header_id          IN           NUMBER,
    p_transaction_temp_id    IN           NUMBER,
    p_transaction_batch_id   IN           NUMBER,
    p_transaction_batch_seq  IN           NUMBER,
    p_transfer_lpn_id        IN           NUMBER,
    p_status                 IN           NUMBER) IS

    l_api_name  VARCHAR2(30) := 'insert_into_wdth';
    l_debug     NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       print_version_info;
       print_debug
       ( 'Entered with parameters:   ' || g_newline                        ||
         'p_txn_header_id         => ' || to_char(p_txn_header_id)         || g_newline ||
         'p_transaction_temp_id   => ' || to_char(p_transaction_temp_id)   || g_newline ||
         'p_transaction_batch_id  => ' || to_char(p_transaction_batch_id)  || g_newline ||
         'p_transaction_batch_seq => ' || to_char(p_transaction_batch_seq) || g_newline ||
         'p_transfer_lpn_id       => ' || to_char(p_transfer_lpn_id)
       , l_api_name
       );
    END IF;

    INSERT INTO wms_dispatched_tasks_history
                ( task_id
                , transaction_id
                , organization_id
                , transaction_batch_id
                , transaction_batch_seq
                , user_task_type
                , person_id
                , effective_start_date
                , effective_end_date
                , equipment_id
                , equipment_instance
                , person_resource_id
                , machine_resource_id
                , status
                , dispatched_time
                , last_update_date
                , last_updated_by
                , creation_date
                , created_by
                , task_type
                , loaded_time
                , drop_off_time
                , suggested_dest_subinventory
                , suggested_dest_locator_id
                , operation_plan_id
                , move_order_line_id
                , transfer_lpn_id
                , inventory_item_id
                , revision
                , transaction_type_id
                , transaction_source_type_id
                , transaction_action_id
                , source_subinventory_code
                , source_locator_id
                , dest_subinventory_code
                , dest_locator_id
                , lpn_id
                , content_lpn_id
                , transaction_temp_id
                , priority                  -- For bug 5401222
                )
    (SELECT wdt.task_id
          , p_txn_header_id
          , wdt.organization_id
          , p_transaction_batch_id
          , p_transaction_batch_seq
          , wdt.user_task_type
          , wdt.person_id
          , SYSDATE	-- wdt.effective_start_date  (for bug#5412974)
          , SYSDATE	-- wdt.effective_end_date    (for bug#5412974)
          , wdt.equipment_id
          , wdt.equipment_instance
          , wdt.person_resource_id
          , wdt.machine_resource_id
          , p_status
          , wdt.dispatched_time
          , SYSDATE
          , fnd_global.user_id
          , SYSDATE
          , fnd_global.user_id
          , wdt.task_type
          , wdt.loaded_time
          , SYSDATE
          , wdt.suggested_dest_subinventory
          , wdt.suggested_dest_locator_id
          , wdt.operation_plan_id
          , wdt.move_order_line_id
          , p_transfer_lpn_id
          , mmtt.inventory_item_id
          , mmtt.revision
          , mmtt.transaction_type_id
          , mmtt.transaction_source_type_id
          , mmtt.transaction_action_id
          , mmtt.subinventory_code
          , mmtt.locator_id
          , mmtt.transfer_subinventory
          , mmtt.transfer_to_location
          , mmtt.lpn_id
          , mmtt.content_lpn_id
          , mmtt.transaction_temp_id
          , nvl(wdt.priority,mmtt.task_priority)                 -- For bug 5401222
       FROM wms_dispatched_tasks            wdt
          , mtl_material_transactions_temp  mmtt
      WHERE wdt.transaction_temp_id = p_transaction_temp_id
        AND wdt.transaction_temp_id = mmtt.transaction_temp_id
    );
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END insert_into_wdth;

END wms_insert_wdth_pvt;

/
