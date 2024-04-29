--------------------------------------------------------
--  DDL for Package Body CSI_RESUBMIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_RESUBMIT_PUB" AS
/* $Header: csiprshb.pls 120.1 2006/01/05 22:20:54 srsarava noship $ */

  PROCEDURE debug(
    p_message               IN  VARCHAR2)
  IS
  BEGIN

    csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csi',
      p_file_segment2 => to_char(sysdate,'DDMONYYYY'));

    csi_t_gen_utility_pvt.add(p_message);

    IF fnd_profile.value('CONC_REQUEST_ID') is not null THEN
      fnd_file.put_line(fnd_file.log, p_message);
    END IF;

  END debug;

  PROCEDURE process_failed_in_q
  IS
    CURSOR stuck_cur IS
      SELECT msg_id,
             msg_code,
             msg_status,
             body_text,
             description
      FROM   xnp_msgs
      WHERE  msg_code like 'CSI%'
      AND    msg_status in ('FAILED', 'REJECTED');

    -- variables for decode
    l_amount          integer;
    l_msg_text        varchar2(32767);
    l_element_name    varchar2(80);
    l_element_value   varchar2(200);

    -- other variables
    l_fixed_flag      varchar2(1) := 'N';
    l_failure_message varchar2(2000);

  BEGIN

    FOR stuck_rec in stuck_cur
    LOOP

      l_failure_message := null;

      BEGIN

        l_amount   := null;
        l_amount   := dbms_lob.getlength(stuck_rec.body_text);
        l_msg_text := null;

        dbms_lob.read(
          lob_loc => stuck_rec.body_text,
          amount  => l_amount,
          offset  => 1,
          buffer  => l_msg_text );

        l_element_value := null;

        IF stuck_rec.msg_code in ('CSISOFUL', 'CSIRMAFL') THEN
          l_element_name := 'ORDER_LINE_ID';
          xnp_xml_utils.decode(l_msg_text, 'ORDER_LINE_ID', l_element_value);
        ELSE
          l_element_name := 'MTL_TRANSACTION_ID';
          xnp_xml_utils.decode(l_msg_text, 'MTL_TRANSACTION_ID', l_element_value);
        END IF;

        BEGIN
          l_fixed_flag := 'N';
          xnp_message.fix(
            p_msg_id => stuck_rec.msg_id);
          l_fixed_flag := 'Y';
        EXCEPTION
          WHEN others THEN
            l_failure_message := 'Failed in xnp_message.fix : '||sqlerrm;
        END;

      EXCEPTION
        WHEN others THEN
          l_failure_message := 'Failed to decode : '||sqlerrm;
      END;

      debug('sfm message queue record # '||stuck_cur%rowcount);
      debug('  msg_code          '||stuck_rec.msg_code);
      debug('  msg_id            '||stuck_rec.msg_id);
      debug('  msg_status        '||stuck_rec.msg_status);
      debug('  description       '||stuck_rec.description);
      debug('  msg_element_name  '||l_element_name);
      debug('  msg_element_value '||l_element_value);
      debug('  re_queued_flag    '||l_fixed_flag);
      debug('  failure_message   '||l_failure_message);

    END LOOP;

  EXCEPTION
    WHEN others THEN
      null;
  END process_failed_in_q;

  PROCEDURE resubmit_interface(
    errbuf        OUT nocopy varchar2,
    retcode       OUT nocopy number,
    p_option      IN         varchar2)
  IS
  BEGIN

    debug('  ');
    debug('START resubmit_errors-'||p_option||'-'||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

    IF p_option    = 'SELECTED' THEN
      -- process only the records in csi_txn_errors with processed_flag = 'R'
      resubmit_error_txns(errbuf,retcode,p_option);
    ELSIF p_option = 'ALL' THEN
      -- process all records in csi_txn_errors processed_flag in ('E', 'R')
      resubmit_error_txns(errbuf,retcode,p_option);
    ELSIF p_option = 'WAITING' THEN
      -- process only the records in csi_txn_errors with processed_flag = 'W'
      resubmit_error_txns(errbuf,retcode,'W');
    ELSIF p_option = 'FAILED_IN_Q' THEN
      -- dequeueus the CSI messages in SFM queue with the status in (FAILED, REJECTED)
      process_failed_in_q;
    END IF;

    debug('END   resubmit_errors-'||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

  END resubmit_interface;

  PROCEDURE resubmit_waiting_txns(
    errbuf        OUT nocopy varchar2,
    retcode       OUT nocopy number)
  IS
  BEGIN
    resubmit_error_txns(errbuf,retcode,'W');
  END Resubmit_Waiting_Txns;

  PROCEDURE resubmit(
    p_error_rec     IN         csi_txn_errors%rowtype,
    x_return_status OUT nocopy varchar2,
    x_error_message OUT nocopy varchar2)
  IS
    l_trx_error_rec     csi_datastructures_pub.transaction_error_rec;
    l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message     varchar2(2000);

  CURSOR c_txn_info (pc_txn_type_id IN NUMBER) is
    SELECT seeded_flag,source_application_id
    FROM   csi_txn_types
    WHERE  transaction_type_id = pc_txn_type_id;

  r_txn_info        c_txn_info%rowtype;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    fnd_msg_pub.initialize;

    UPDATE csi_txn_errors
    SET    processed_flag = 'Y'
    WHERE  transaction_error_id = p_error_rec.transaction_error_id;

    OPEN c_txn_info(p_error_rec.transaction_type_id);
    FETCH c_txn_info into r_txn_info;
    CLOSE c_txn_info;

    -- First check to see if this is a CSE Error

    IF p_error_rec.transaction_type_id in (106,107,108,109,110,111,103,104,105) THEN

      cse_redo_pkg.redo_logic(
        p_txn_type_id    => p_error_rec.transaction_type_id,
        p_stage          => p_error_rec.error_stage,
        p_body_text      => p_error_rec.message_string,
        x_return_status  => l_return_status,
        x_error_message  => l_error_message);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    -- Second check if its seeded then it must be a CSI error so process thru
    -- CSI reprocess logic.

    ELSIF r_txn_info.seeded_flag  = 'Y' AND
          r_txn_info.source_application_id NOT IN (873,140) AND
          p_error_rec.transaction_type_id <> 105 THEN

      csi_inv_txnstub_pkg.execute_trx_dpl(
        p_transaction_type  => p_error_rec.source_type,
        p_transaction_id    => p_error_rec.source_id,
        x_trx_return_status => l_return_status,
        x_trx_error_rec     => l_trx_error_rec);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        l_error_message := l_trx_error_rec.error_text;
        RAISE fnd_api.g_exc_error;
      END IF;

    ELSE

      /* Neither a core EIB trackable transaction Nor a CSI Core Transaction.
         Call client extension to check against additional transaction types. */

      csi_client_ext_pub.csi_error_resubmit(
        p_transaction_id => p_error_rec.transaction_type_id,
        x_return_status  => l_return_status,
        x_error_message  => l_error_message);

      -- If no custom code exists this will return an error so that the error
      -- is retained for the custom defined transaction. After code is entered
      -- to reprocess then the transaction should get processed.

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        l_error_message := l_trx_error_rec.error_text;
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := l_error_message;
    WHEN others THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := 'Error in resubmit: '||substr(sqlerrm, 1, 540);
  END resubmit;


PROCEDURE resubmit_error_txns(
    errbuf        OUT nocopy varchar2,
    retcode       OUT nocopy number,
    process_flag  IN         varchar2)
  IS

    l_error_message    varchar2(2000);
    l_return_status    varchar2(1):= fnd_api.g_ret_sts_success;

    process_success    exception;
    process_failure    exception;

    --Fix for bug 4907969
    l_val_1 varchar2(1);
    l_val_2 varchar2(1);

    CURSOR resubmit_csr IS
      SELECT cte.*
      FROM   csi_txn_errors cte,
             mtl_material_transactions mmt
      WHERE  cte.processed_flag IN (l_val_1,l_val_2)
      AND    cte.inv_material_transaction_id = mmt.transaction_id(+)
      ORDER BY mmt.creation_date asc , mmt.transaction_id asc;


  BEGIN
  --Fix for bug 4907969
     IF process_flag = 'ALL' THEN
        l_val_1 := 'E';
	l_val_2 := 'R';
     ELSIF process_flag = 'SELECTED' THEN
        l_val_1 := 'R';
	l_val_2 := 'R';
     ELSIF process_flag = 'W' THEN
        l_val_1 := 'W';
	l_val_2 := 'W';
     END IF;

    FOR error_rec IN resubmit_csr
    LOOP

      BEGIN

        debug('  START '||error_rec.source_type||'-'||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
        debug('    txn_type_id : '||error_rec.transaction_type_id);
        debug('    source_type : '||error_rec.source_type);
        debug('    source_id   : '||error_rec.source_id);

        resubmit(
          p_error_rec     => error_rec,
          x_return_status => l_return_status,
          x_error_message => l_error_message);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE process_failure;
        ELSE
          RAISE process_success;
        END IF;

      EXCEPTION
        WHEN process_success THEN

          debug('    status      : SUCCESS');
          debug('  END   '||error_rec.source_type||'-'||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

          /* Added by epajaril for 11.5.10 enhancement */
          DELETE from csi_txn_errors
          WHERE  transaction_error_id = error_rec.transaction_error_id;

        WHEN process_failure THEN

          IF nvl(l_error_message, fnd_api.g_miss_char) = fnd_api.g_miss_char THEN
            l_error_message := error_rec.error_text;
          END IF;

          debug('    status      : FAILED AGAIN');
          debug('    error       : '||l_error_message);
          debug('  END   '||error_rec.source_type||'-'||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

          UPDATE csi_txn_errors
          SET    processed_flag       = 'E',
                 error_text           = l_error_message ,
                 last_update_date     = sysdate,
                 last_update_login    = fnd_global.login_id,
                 last_updated_by      = fnd_global.user_id
          WHERE  transaction_error_id = error_rec.transaction_error_id;

      END;
      commit;
    END LOOP;
  EXCEPTION
   WHEN OTHERS THEN
     null;
     --will put code here
  END resubmit_error_txns;

END csi_resubmit_pub;

/
