--------------------------------------------------------
--  DDL for Package Body CSE_RCVTXN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_RCVTXN_PKG" AS
/* $Header: CSEPOEXB.pls 120.1 2006/06/07 21:15:16 brmanesh noship $  */

  l_debug varchar2(1) := NVL(fnd_profile.value('CSE_DEBUG_OPTION'),'N');

  PROCEDURE debug(
    p_message IN varchar2)
  IS
  BEGIN
    IF l_debug = 'Y' THEN
      cse_debug_pub.add(p_message);
      IF nvl(fnd_global.conc_request_id, -1) <> -1 THEN
        fnd_file.put_line(fnd_file.log, p_message);
      END IF;
    END IF;
  EXCEPTION
    WHEN others THEN
      null;
  END debug;

  PROCEDURE PostTransaction_Exit(
    p_transaction_id    IN NUMBER,
    p_interface_trx_id  IN NUMBER,
    p_return_status        OUT NOCOPY VARCHAR2)
  IS
    l_eib_installed       VARCHAR2(1) := 'N';
    l_ib_tracked_flag     VARCHAR2(1);
    l_message_id          NuMBER ;
    l_error_code          NUMBER;
    l_error_message       VARCHAR2(2000);
    l_return_status       VARCHAR2(100);
    l_file                VARCHAR2(500);
    l_api_version         NUMBER  DEFAULT 1.0;
    l_commit              VARCHAR2(1) DEFAULT fnd_api.g_false;
    l_init_msg_list       VARCHAR2(1) DEFAULT fnd_api.g_true;
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_trx_error_rec       csi_datastructures_pub.transaction_error_rec;
    l_Validation_Level    NUMBER   := fnd_api.g_valid_level_full;
    l_Txn_Error_Id        NUMBER;
    l_xml_string          VARCHAR2(2000);

    CURSOR rcv_txn_cur IS
      SELECT rt.transaction_id,
             pla.item_id,
             pda.project_id,
             rt.organization_id,
             rt.transaction_type,
             rt.destination_type_code
      FROM   rcv_transactions     rt ,
             po_lines_all         pla ,
             po_distributions_all pda
      WHERE  rt.transaction_id      = p_transaction_id
      AND    pda.po_distribution_id = rt.po_distribution_id
      AND    pla.po_line_id         = rt.po_line_id;

  BEGIN

    savepoint rcv_hook;

    p_return_status := fnd_api.g_ret_sts_success;
    l_eib_installed := cse_util_pkg.is_eib_installed;

    IF l_eib_installed = 'Y'  THEN

      cse_util_pkg.build_error_string(l_xml_string,'RCV_TRANSACTION_ID',p_transaction_id);

      cse_util_pkg.set_debug;

      debug('Inside cse_rcvtxn_pkg.posttransaction_exit');
      debug('  transaction_id         : '||p_transaction_id);

      FOR rcv_txn_rec IN rcv_txn_cur
      LOOP

        debug('  transaction_type       : '||rcv_txn_rec.transaction_type);
        debug('  destination_type_code  : '||rcv_txn_rec.destination_type_code);
        debug('  item_id                : '||rcv_txn_rec.item_id);
        debug('  project_id             : '||rcv_txn_rec.project_id);

        IF rcv_txn_rec.transaction_type = 'DELIVER'
           AND
           rcv_txn_rec.destination_type_code = 'EXPENSE'
           AND
           rcv_txn_rec.project_id is not null
           AND
           rcv_txn_rec.item_id is not null
        THEN

          SELECT nvl(comms_nl_trackable_flag, 'N')
          INTO   l_ib_tracked_flag
          FROM   mtl_system_items
          WHERE  inventory_item_id = rcv_txn_rec.item_id
          AND    organization_id   = rcv_txn_rec.organization_id;

          debug('  ib_tracked_flag        : '||l_ib_tracked_flag);

          IF l_ib_tracked_flag = 'Y' THEN

            IF NOT cse_util_pkg.bypass_event_queue THEN

              xnp_cseporcv_u.publish(
                xnp$rcv_transaction_id => p_transaction_id ,
                x_message_id           => l_message_id ,
                x_error_code           => l_error_code ,
                x_error_message        => l_error_message);

              IF l_error_code <> 0 THEN
                RAISE fnd_api.g_exc_error;
              END IF;

            ELSE
              cse_po_noqueue_pvt.process_noqueue_txn(
                p_ref_id        => p_transaction_id,
                p_txn_type      => 'PO_RECEIPT_INTO_PROJECT',
                x_return_status => l_return_Status,
                x_msg_count     => l_msg_count,
                x_msg_data      => l_msg_data);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                l_error_message := l_msg_data;
                RAISE fnd_api.g_exc_error;
              END IF;

            END IF; -- bypass/publish
          END IF; -- ib tracked
        END IF; -- deliver expense item into project
      END LOOP;

    END IF; -- eib installed

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO rcv_hook;
      p_return_Status := fnd_api.g_ret_sts_unexp_error;
      l_error_Message := nvl(l_error_message, sqlerrm);
      IF l_eib_installed = 'Y' THEN
        l_trx_error_rec.error_text    := l_error_message;
        l_trx_error_rec.source_type   := 'CSEPORCV';
        l_trx_error_rec.source_id     := p_transaction_id;
        l_Trx_Error_Rec.Transaction_Type_ID   := 102;
        l_Trx_Error_Rec.message_string := l_xml_string;
        l_Trx_Error_Rec.error_stage   := cse_datastructures_pub.g_ib_update;
        csi_transactions_pvt.create_txn_error(
          l_api_version,l_init_msg_list,l_commit,1,l_trx_error_rec,
          l_return_status,l_msg_count,l_msg_data,l_txn_error_id);
      END IF;
  END PostTransaction_Exit;

END cse_rcvtxn_pkg;

/
