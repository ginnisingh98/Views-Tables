--------------------------------------------------------
--  DDL for Package Body INV_PARENT_MMTT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_PARENT_MMTT_PVT" AS
  /* $Header: INVVPMTB.pls 115.1 2004/05/19 01:18:56 stdavid noship $ */

  g_pkg_body_ver  CONSTANT VARCHAR2(100) := '$Header: INVVPMTB.pls 115.1 2004/05/19 01:18:56 stdavid noship $';
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



  PROCEDURE process_parent
  ( x_return_status   OUT NOCOPY  VARCHAR2
  , p_parent_temp_id  IN          NUMBER
  ) IS

    l_api_name             VARCHAR2(30) := 'process_parent';
    l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_api_return_status    VARCHAR2(1);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);

    l_dummy                VARCHAR2(1);
    l_child_wdth_exists    BOOLEAN;
    l_txn_header_id        NUMBER;
    l_parent_txn_id        NUMBER;


    CURSOR c_get_parent_details
    ( p_temp_id  IN  NUMBER
    ) IS
      SELECT mmtt.organization_id
           , mmtt.transfer_lpn_id
           , wdt.task_id
        FROM mtl_material_transactions_temp  mmtt
           , wms_dispatched_tasks            wdt
       WHERE mmtt.transaction_temp_id = p_temp_id
         AND wdt.transaction_temp_id  = mmtt.transaction_temp_id;

    parent_rec  c_get_parent_details%ROWTYPE;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    SAVEPOINT process_parent_sp;

    print_version_info;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline                 ||
         'p_parent_temp_id => '      || to_char(p_parent_temp_id)
       , l_api_name
       );
    END IF;

    l_child_wdth_exists := FALSE;
    BEGIN
       SELECT 'x'
         INTO l_dummy
         FROM dual
        WHERE EXISTS
            ( SELECT 'x'
                FROM wms_dispatched_tasks_history
               WHERE parent_transaction_id = p_parent_temp_id
                 AND is_parent             = 'N'
            );

       IF l_debug = 1 THEN
          print_debug ('Child record exists', l_api_name);
       END IF;

       l_child_wdth_exists := TRUE;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          l_child_wdth_exists := FALSE;
       WHEN OTHERS THEN
          IF l_debug = 1 THEN
             print_debug
             ( 'Exception checking if child WDTH rec exists: ' || sqlerrm
             , l_api_name
             );
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    OPEN c_get_parent_details (p_parent_temp_id);
    FETCH c_get_parent_details INTO parent_rec;
    CLOSE c_get_parent_details;

    IF l_debug = 1 THEN
       print_debug
       ( 'Org ID: '        || to_char(parent_rec.organization_id) ||
         ', xfer LPN ID: ' || to_char(parent_rec.transfer_lpn_id) ||
         ', task ID: '     || to_char(parent_rec.task_id)
       , l_api_name
       );
    END IF;

    IF l_child_wdth_exists
       AND
       parent_rec.transfer_lpn_id IS NOT NULL
    THEN
       SELECT mtl_material_transactions_s.NEXTVAL
         INTO l_txn_header_id
         FROM dual;

       IF l_debug = 1 THEN
          print_debug
          ( 'Generated header ID: ' || to_char(l_txn_header_id)
          , l_api_name
          );
       END IF;

       l_api_return_status := fnd_api.g_ret_sts_success;
       wms_task_dispatch_put_away.archive_task
       ( p_temp_id           => p_parent_temp_id
       , p_org_id            => parent_rec.organization_id
       , x_return_status     => l_api_return_status
       , x_msg_count         => l_msg_count
       , x_msg_data          => l_msg_data
       , p_delete_mmtt_flag  => 'Y'
       , p_txn_header_id     => l_txn_header_id
       , p_transfer_lpn_id   => parent_rec.transfer_lpn_id
       );

       IF l_api_return_status <> fnd_api.g_ret_sts_success
       THEN
          IF l_debug = 1 THEN
             print_debug
             ( 'Error from wms_task_dispatch_put_away.archive_task: '
               || l_msg_data
             , l_api_name
             );
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       --
       -- Update parent_transaction_id in WDTH
       --
       BEGIN
          UPDATE wms_dispatched_tasks_history  wdth
             SET wdth.parent_transaction_id = wdth.transaction_id
               , wdth.is_parent = 'Y'
           WHERE wdth.task_id = parent_rec.task_id
                 RETURNING wdth.transaction_id INTO l_parent_txn_id;

          IF l_debug = 1 AND SQL%FOUND
          THEN
             print_debug
             ( 'Updated WDTH.  Parent transaction ID is: '
               || to_char(l_parent_txn_id)
             , l_api_name
             );
          END IF;

       EXCEPTION
          WHEN OTHERS THEN
             IF l_debug = 1 THEN
                print_debug
                ( 'Exception updating WDTH: ' || sqlerrm
                , l_api_name
                );
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END;

       --
       -- Update child lines
       --
       BEGIN
          UPDATE wms_dispatched_tasks_history  wdth
             SET wdth.parent_transaction_id = l_parent_txn_id
           WHERE wdth.parent_transaction_id = p_parent_temp_id;

          IF l_debug = 1 AND SQL%FOUND
          THEN
             print_debug
             ( 'Updated WDTH for child records.'
             , l_api_name
             );
          END IF;

       EXCEPTION
          WHEN OTHERS THEN
             IF l_debug = 1 THEN
                print_debug
                ( 'Exception updating WDTH: ' || sqlerrm
                , l_api_name
                );
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END;
    ELSE
       DELETE wms_dispatched_tasks
        WHERE transaction_temp_id = p_parent_temp_id;

       DELETE mtl_material_transactions_temp
        WHERE transaction_temp_id = p_parent_temp_id;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO process_parent_sp;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );

      IF l_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO process_parent_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END process_parent;


END inv_parent_mmtt_pvt;

/
