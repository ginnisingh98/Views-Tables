--------------------------------------------------------
--  DDL for Package Body INV_RCV_MOBILE_PROCESS_TXN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RCV_MOBILE_PROCESS_TXN" AS
/* $Header: INVRCVPB.pls 120.6.12010000.3 2009/06/24 07:06:40 aditshar ship $*/

--  Global constant holding the package name
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'INV_RCV_MOBILE_PROCESS_TXN';

PROCEDURE print_debug(p_err_msg VARCHAR2,
		      p_level NUMBER)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      inv_mobile_helper_functions.tracelog
     (p_err_msg => p_err_msg,
      p_module => 'INV_RCV_MOBILE_PROCESS_TXN',
      p_level => p_level);
   END IF;

--   dbms_output.put_line(p_err_msg);
END print_debug;


FUNCTION check_group_id(p_group_id IN NUMBER)
  RETURN BOOLEAN
  IS
     l_rec_count NUMBER := 0;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   SELECT   COUNT(1)
     INTO   l_rec_count
     FROM   RCV_TRANSACTIONS_INTERFACE
    WHERE   group_id = p_group_id;

    IF (l_rec_count = 0) THEN
       IF (l_debug = 1) THEN
          print_debug('check_group_id 10 Did not find the row with group id in RTI',4);
       END IF;
       return (FALSE);
     ELSE
       IF (l_debug = 1) THEN
          print_debug('check_group_id 20 Found the row with group id in RTI',4);
       END IF;
       return (TRUE);
    END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       IF (l_debug = 1) THEN
          print_debug('check_group_id 30 Did not find the row with group id in RTI',4);
       END IF;
      RETURN(FALSE);
   WHEN OTHERS THEN
      NULL;
END check_group_id;


PROCEDURE rcv_print_traveller
  IS
     v_req_id NUMBER;
     v_qty_precision VARCHAR2(4);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_org_id NUMBER;
BEGIN

   /*
   ** Check if we need to print receipt traveller
   */
     IF Upper(inv_rcv_common_apis.g_po_startup_value.receipt_traveller) = 'Y' THEN -- ?
        v_qty_precision := fnd_profile.value('REPORT_QUANTITY_PRECISION');
	v_req_id :=
	  fnd_request.submit_request('PO',
				     'RCVDLPDT',
				     null,
				     null,
				     false,
				     'P_group_id=' || inv_rcv_common_apis.g_rcv_global_var.interface_group_id,
				     'P_qty_precision='||v_qty_precision,
				     'P_org_id=' || inv_rcv_common_apis.g_po_startup_value.inv_org_id,--NULL, --fnd_char.local_chr(0),----bug 5195963
				     NULL,
				     NULL,
				     NULL,
				     NULL,
				     NULL,
				     NULL, NULL,
				     NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				     NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				     NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				     NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				     NULL, NULL, NULL, NULL, NULL, NULL, NULL,

				     NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				     NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				     NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				     NULL, NULL, NULL, NULL, NULL, NULL, NULL,

				     NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				     NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				     NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				     NULL, NULL, NULL, NULL, NULL, NULL);

	-- This error handling is useless
	-- if print_traveller follows commit
	-- It will be useful if it is called as stand alone
	-- so leave it here
       if (v_req_id <= 0 or v_req_id is null) then
	  NULL;
	ELSE
	  COMMIT;
       end if;
     END IF;
END rcv_print_traveller;


PROCEDURE rcv_immediate_transaction(x_return_status OUT nocopy VARCHAR2,
				   x_msg_data       OUT nocopy VARCHAR2)
  IS
     v_req_id NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   v_req_id :=
     fnd_request.submit_request('PO',
				'RVCTP',
				null,
				null,
				false,
				'IMMEDIATE',
				inv_rcv_common_apis.g_rcv_global_var.interface_group_id,
				NULL, --fnd_char.local_chr(0), ?
				NULL,
				NULL,
				NULL,
				NULL,
				NULL, NULL,
				NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				NULL, NULL, NULL, NULL, NULL, NULL, NULL,

				NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				NULL, NULL, NULL, NULL, NULL, NULL, NULL,

				NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				NULL, NULL, NULL, NULL, NULL, NULL, NULL);

   if (v_req_id <= 0 or v_req_id is null) then
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data := FND_MESSAGE.get;
    ELSE
      COMMIT;
   end if;
END rcv_immediate_transaction;


PROCEDURE rcv_online_request (x_return_status OUT nocopy VARCHAR2,
			      x_msg_data       OUT nocopy VARCHAR2)
  IS
   rc NUMBER;
   l_timeout NUMBER ;
   l_outcome VARCHAR2(200) := NULL;
   l_message VARCHAR2(2000) := NULL;
   l_return_status VARCHAR2(5) := fnd_api.g_ret_sts_success;
   l_msg_count NUMBER;
   x_str varchar2(6000) := NULL;
   DELETE_ROWS   BOOLEAN := FALSE;
   r_val1 varchar2(300) := NULL;
   r_val2 varchar2(300) := NULL;
   r_val3 varchar2(300) := NULL;
   r_val4 varchar2(300) := NULL;
   r_val5 varchar2(300) := NULL;
   r_val6 varchar2(300) := NULL;
   r_val7 varchar2(300) := NULL;
   r_val8 varchar2(300) := NULL;
   r_val9 varchar2(300) := NULL;
   r_val10 varchar2(300) := NULL;
   r_val11 varchar2(300) := NULL;
   r_val12 varchar2(300) := NULL;
   r_val13 varchar2(300) := NULL;
   r_val14 varchar2(300) := NULL;
   r_val15 varchar2(300) := NULL;
   r_val16 varchar2(300) := NULL;
   r_val17 varchar2(300) := NULL;
   r_val18 varchar2(300) := NULL;
   r_val19 varchar2(300) := NULL;
   r_val20 varchar2(300) := NULL;
   l_progress VARCHAR2(10) := '10';
   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_group_id NUMBER := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   -- Bug 5046328
   -- Get the timeout value from profile

   l_timeout := fnd_profile.value('INV_RPC_TIMEOUT');

   IF (l_timeout is NULL) THEN
      l_timeout := 300;
   END IF;
--bug 7034252
   IF (l_debug = 1) THEN
      print_debug('rcv_online_request - timeout : '|| l_timeout, 1);
   END IF;
    Begin
         print_debug('updating proceesing mode in rti  for group id'||inv_rcv_common_apis.g_rcv_global_var.interface_group_id,1);
         UPDATE RCV_TRANSACTIONS_INTERFACE
         SET PROCESSING_MODE_CODE =  'ONLINE'
         WHERE GROUP_ID = inv_rcv_common_apis.g_rcv_global_var.interface_group_id
         AND  PROCESSING_MODE_CODE <> 'ONLINE';
         COMMIT;
      EXCEPTION
      WHEN OTHERS THEN
        print_debug('no record found in rti which requires update  ',1);
  END;
  --end of bug 7034252


   rc := fnd_transaction.synchronous
     (
      l_timeout, l_outcome, l_message, 'PO', 'RCVTPO',
      'ONLINE',  inv_rcv_common_apis.g_rcv_global_var.interface_group_id,
      NULL, NULL, NULL, NULL, NULL, NULL,
      NULL, NULL, NULL, NULL, NULL, NULL,
      NULL, NULL, NULL, NULL, NULL, NULL);

   l_progress := '20';

   IF (l_debug = 1) THEN
      print_debug('rcv_online_request :value of l_outcome:'||l_outcome|| to_char(sysdate,
                  'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('rcv_online_request :value of rc:'||rc|| to_char(sysdate,
                  'YYYY-MM-DD HH:DD:SS'), 1);
   END IF;

   IF (rc = 0 and (l_outcome NOT IN ('WARNING', 'ERROR'))) THEN
      l_progress := '30';
      BEGIN
	 SELECT 'ERROR'
	   INTO l_outcome
	   FROM dual
	   WHERE EXISTS (SELECT 1
			 FROM   rcv_transactions_interface
			 WHERE  group_id = l_group_id
			 AND    (transaction_status_code = 'ERROR' OR
				 processing_status_code = 'ERROR'));
      EXCEPTION
	 WHEN OTHERS THEN
	    -- If no row is found, then leave l_outcome as it is returned
	    -- from fnd_transaction.synchronous
	    NULL;
      END;

      IF (l_outcome = 'ERROR') THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 IF (l_debug = 1) THEN
	    print_debug('rcv_online_request 29.99 finished with error at: '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
	 END IF;
       ELSE
	 IF (l_debug = 1) THEN
	    print_debug('rcv_online_request 30 finished without error at: '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
	 END IF;
      END IF;
    ELSIF (rc = 1) THEN
      l_progress := '40';
      IF (l_debug = 1) THEN
         print_debug('rcv_online_request 40 finished with error rc = 1 at: '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
      IF (check_group_id(inv_rcv_common_apis.g_rcv_global_var.interface_group_id)) THEN
	 fnd_message.set_name('FND', 'TM-TIMEOUT');
	 --x_str := fnd_message.get;
	 --fnd_message.clear;
	 FND_MESSAGE.set_name('FND','CONC-Error running standalone');
	 fnd_message.set_token('PROGRAM', 'Receiving Transaction Manager - RCVOLTM');
	 fnd_message.set_token('REQUEST', inv_rcv_common_apis.g_rcv_global_var.interface_group_id);
	 fnd_message.set_token('REASON', x_str);
	 --fnd_message.clear;
	 fnd_msg_pub.ADD;

         /* See the commnets below from ATG for timeout */
	 --DELETE_ROWS := TRUE;

      END IF;

      l_progress := '50';
      x_return_status := fnd_api.g_ret_sts_error;

      --x_msg_data := FND_MESSAGE.get;

      -- Since IF TIMEOUT Happens the Return comes back to client
      -- But server Process (i,e TM) may be still working in the Background and
      -- eventually commit
      --
      -- Update from ATG
      /* Rolling back on the client side after a timeout will have no effect on what
          the transaction manager is processing on the server.
          Remember that the client side process sends the transaction to the transaction
          manager and then waits for a response. If the response does not come within
          the timeout period, the client returns a timeout error. However this does not
          affect the server-side transaction, which will continue to process data until
          it finishes.
          If you have a heavy load and are seeing too many timeouts, you should increase
          the timeout value you are using.
      */

      -- inv_receiving_transaction.txn_complete
      -- (p_group_id => inv_rcv_common_apis.g_rcv_global_var.interface_group_id,
      -- p_txn_status => 'FALSE',
      -- p_txn_mode => 'ONLINE',
      -- x_return_status => l_return_status,
      -- x_msg_data => l_message,
      -- x_msg_count => l_msg_count);

      l_progress := '60';

    ELSIF (rc = 2) THEN
      --	    txn_failure_clean_up;
      l_progress := '70';
      IF (l_debug = 1) THEN
         print_debug('rcv_online_request 70 finished with error rc = 2 at: '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
      IF (check_group_id(inv_rcv_common_apis.g_rcv_global_var.interface_group_id)) THEN
	 fnd_message.set_name('FND', 'TM-SVC LOCK HANDLE FAILED');
	 --x_str := fnd_message.get;
	 --fnd_message.clear;
	 FND_MESSAGE.set_name('FND','CONC-Error running standalone');
	 fnd_message.set_token('PROGRAM', 'Receiving Transaction Manager - RCVOLTM');
	 fnd_message.set_token('REQUEST', inv_rcv_common_apis.g_rcv_global_var.interface_group_id);
	 fnd_message.set_token('REASON', x_str);
	 --fnd_message.clear;
	 fnd_msg_pub.ADD;
	 DELETE_ROWS := TRUE;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
      --x_msg_data := FND_MESSAGE.get;
      l_progress := '80';

      inv_receiving_transaction.txn_complete
	(p_group_id => inv_rcv_common_apis.g_rcv_global_var.interface_group_id,
	 p_txn_status => 'FALSE',
	 p_txn_mode => 'ONLINE',
	 x_return_status => l_return_status,
	 x_msg_data => l_message,
	 x_msg_count => l_msg_count);

    END IF;
    /* Bug 4901912 -Modified the ELSIF condition by ending the previous IF clause
                    so that both the cases of rc=3 or l_outcome warning or error is handled.*/
    IF (rc = 3 or (l_outcome IN ('WARNING', 'ERROR'))) THEN
      l_progress := '90';
      IF (l_debug = 1) THEN
         print_debug('rcv_online_request 90 finished with error rc = 3 for:'||inv_rcv_common_apis.g_rcv_global_var.interface_group_id||' AT : '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      --	    txn_failure_clean_up;
      IF (check_group_id(inv_rcv_common_apis.g_rcv_global_var.interface_group_id)) THEN
	 IF (l_debug = 1) THEN
   	 print_debug('rcv_online_request 90.01 found the group id',4);
	 END IF;
	 l_progress := '95';
	 rc := fnd_transaction.get_values
	   (
	    r_val1, r_val2, r_val3, r_val4, r_val5,
	    r_val6, r_val7, r_val8, r_val9, r_val10,
	    r_val11, r_val12, r_val13, r_val14, r_val15,
	    r_val16, r_val17, r_val18, r_val19, r_val20
	    );

	 l_progress := '100';
	 x_str := r_val1;
	 --	       FND_MESSAGE.SET_STRING(x_str);
	 --FND_MESSAGE.CLEAR;
	 IF (r_val2 IS NOT NULL)  THEN x_str := x_str || fnd_global.local_chr(10) || r_val2;  END IF;
	 IF (r_val3 IS NOT NULL)  THEN x_str := x_str || fnd_global.local_chr(10) || r_val3;  END IF;
	 IF (r_val4 IS NOT NULL)  THEN x_str := x_str || fnd_global.local_chr(10) || r_val4;  END IF;
	 IF (r_val5 IS NOT NULL)  THEN x_str := x_str || fnd_global.local_chr(10) || r_val5;  END IF;
	 IF (r_val6 IS NOT NULL)  THEN x_str := x_str || fnd_global.local_chr(10) || r_val6;  END IF;
	 IF (r_val7 IS NOT NULL)  THEN x_str := x_str || fnd_global.local_chr(10) || r_val7;  END IF;
	 IF (r_val8 IS NOT NULL)  THEN x_str := x_str || fnd_global.local_chr(10) || r_val8;  END IF;
	 IF (r_val9 IS NOT NULL)  THEN x_str := x_str || fnd_global.local_chr(10) || r_val9;  END IF;
	 l_progress := '105';
	 IF (r_val10 IS NOT NULL) THEN x_str := x_str || fnd_global.local_chr(10) || r_val10; END IF;
	 IF (r_val11 IS NOT NULL) THEN x_str := x_str || fnd_global.local_chr(10) || r_val11; END IF;
	 IF (r_val12 IS NOT NULL) THEN x_str := x_str || fnd_global.local_chr(10) || r_val12; END IF;
	 IF (r_val13 IS NOT NULL) THEN x_str := x_str || fnd_global.local_chr(10) || r_val13; END IF;
	 IF (r_val14 IS NOT NULL) THEN x_str := x_str || fnd_global.local_chr(10) || r_val14; END IF;
	 IF (r_val15 IS NOT NULL) THEN x_str := x_str || fnd_global.local_chr(10) || r_val15; END IF;
	 IF (r_val16 IS NOT NULL) THEN x_str := x_str || fnd_global.local_chr(10) || r_val16; END IF;
	 IF (r_val17 IS NOT NULL) THEN x_str := x_str || fnd_global.local_chr(10) || r_val17; END IF;
	 IF (r_val18 IS NOT NULL) THEN x_str := x_str || fnd_global.local_chr(10) || r_val18; END IF;
	 IF (r_val19 IS NOT NULL) THEN x_str := x_str || fnd_global.local_chr(10) || r_val19; END IF;
	 IF (r_val20 IS NOT NULL) THEN x_str := x_str || fnd_global.local_chr(10) || r_val20; END IF;

	 l_progress := '107';
	 IF (l_debug = 1) THEN
   	 print_debug('rcv_online_request 90.1 finished with error :'||x_str, 1);
	 END IF;
	 l_progress := '108';

	 DELETE_ROWS := TRUE;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
      --x_msg_data := FND_MESSAGE.get;

      l_progress := '109';
      inv_receiving_transaction.txn_complete
	(p_group_id => inv_rcv_common_apis.g_rcv_global_var.interface_group_id,
	 p_txn_status => 'FALSE',
	 p_txn_mode => 'ONLINE',
	 x_return_status => l_return_status,
	 x_msg_data => l_message,
	 x_msg_count => l_msg_count);

      l_progress := '110';

   END IF;

   IF (DELETE_ROWS) THEN
     BEGIN

       /* Bug# 6081470
        * Commented out the below update statement as the same record set
        * is getting deleted below
        */
/*      UPDATE rcv_transactions_interface
          SET processing_status_code = 'COMPLETED'
            , transaction_status_code = 'ERROR'
        WHERE group_id = inv_RCV_COMMON_APIS.g_rcv_global_var.interface_group_id;
*/

        --No need to delete the record in RTI. FPJ enhancement
        --delete from rcv_transactions_interface
        --where group_id = inv_RCV_COMMON_APIS.g_rcv_global_var.interface_group_id;

        /* Bug 4901912 -Deleting the errored RTIs */
        IF (l_debug = 1) THEN
          print_debug('INV_RCV_MOBILE_PROCESS_TXN.rcv_online_request in delete rows for group_id:'
                          || inv_RCV_COMMON_APIS.g_rcv_global_var.interface_group_id,4);
        END IF;

        delete from rcv_transactions_interface
        where group_id = inv_RCV_COMMON_APIS.g_rcv_global_var.interface_group_id;

        /* Bug# 6081470
         * Added code to also delete the rcv_headers_interface records as the
         * corresponding rcv_transactions_interface records are being deleted above.
         * Hence this becomes an orphan RHI record and there is no use of this record.
         */
        delete from rcv_headers_interface
        where group_id = inv_RCV_COMMON_APIS.g_rcv_global_var.interface_group_id;

        /* End of fix for Bug 4901912 */

      EXCEPTION
        WHEN OTHERS THEN NULL;
     END;
   END IF;
   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      IF SQLCODE IS NOT NULL THEN
          inv_mobile_helper_functions.sql_error('INV_RCV_MOBILE_PROCESS_TXN.rcv_online_request', l_progress, SQLCODE);
      END IF;
      IF (l_debug = 1) THEN
         print_debug('INV_RCV_MOBILE_PROCESS_TXN.rcv_online_request exception:'||l_progress,4);
      END IF;
END rcv_online_request;


PROCEDURE rcv_process_receive_txn(x_return_status OUT nocopy VARCHAR2,
				  x_msg_data      OUT nocopy VARCHAR2)
  IS
     l_return_status VARCHAR2(1) := FND_API.g_ret_sts_success;
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(400);
     l_progress VARCHAR2(10);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
   IF (l_debug = 1) THEN
      print_debug('rcv_process_receive_txn 10: '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
   END IF;
   l_progress := '10';

   -- calling lpn_pack_complete api to clear the LPN weight/volume pl/sql table
   IF wms_install.check_install(l_return_status, l_msg_count, l_msg_data, NULL) THEN
      IF wms_container_pub.lpn_pack_complete(0) THEN
	 NULL;
      END IF;
   END IF;


   -- We will remove this later ??
   --inv_rcv_common_apis.g_po_startup_value.transaction_mode := 'ONLINE';

   IF Upper(inv_rcv_common_apis.g_po_startup_value.transaction_mode) = 'IMMEDIATE' OR
      Upper(inv_rcv_common_apis.g_po_startup_value.transaction_mode) =  'BATCH' THEN

     -- Call rma API First
     -- This API returns without doing anything if the source is not customer

-- *****************************
-- This call is commented in patchsetJ as this is not needed anymore
-- because Receiving TM would call it for immediate and batch mode also.
--
--rcv_update_rma_info(inv_rcv_common_apis.g_rcv_global_var.interface_group_id,
--                  x_return_status ,
--                       x_msg_data );
--     l_progress := '10.1';

--IF l_return_status = FND_API.g_ret_sts_error THEN
--	 FND_MESSAGE.SET_NAME('INV', 'INV_RCV_IMMEDIATE_TXN_FAIL');
--	 FND_MSG_PUB.ADD;
--	 IF (l_debug = 1) THEN
--  	 print_debug('rcv_process_receive_txn 10.1: rcv_immediate_transaction RAISE FND_API.G_EXC_ERROR;'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 4);
--	 END IF;
--	 RAISE FND_API.G_EXC_ERROR;
--     END IF;
--
--     IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
--	 FND_MESSAGE.SET_NAME('INV', 'INV_RCV_IMMEDIATE_TXN_FAIL');
--	 FND_MSG_PUB.ADD;
--	 IF (l_debug = 1) THEN
--  	 print_debug('rcv_process_receive_txn 10.2: rcv_immediate_transaction RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 4);
--	 END IF;
--	 RAISE FND_API.g_exc_unexpected_error;
--     END IF;
-- ************************************


      /*Bug#8293126.Need to make sure all RTIs are with mode IMMEDIATE  */
       IF ( NVL(inv_rcv_common_apis.g_rcv_global_var.interface_group_id,-999) <> -999 ) THEN
          UPDATE RCV_TRANSACTIONS_INTERFACE
           SET PROCESSING_MODE_CODE =  'IMMEDIATE'
          WHERE GROUP_ID = inv_rcv_common_apis.g_rcv_global_var.interface_group_id
          AND  PROCESSING_MODE_CODE <> 'IMMEDIATE';
       END IF;

      rcv_immediate_transaction
	(x_return_status => l_return_status,
	 x_msg_data      => l_msg_data);

      l_progress := '20';

      IF l_return_status = FND_API.g_ret_sts_error THEN
	 FND_MESSAGE.SET_NAME('INV', 'INV_RCV_IMMEDIATE_TXN_FAIL');
	 FND_MSG_PUB.ADD;
	 IF (l_debug = 1) THEN
   	 print_debug('rcv_process_receive_txn 20.1: rcv_immediate_transaction RAISE FND_API.G_EXC_ERROR;'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 4);
	 END IF;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;


      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 FND_MESSAGE.SET_NAME('INV', 'INV_RCV_IMMEDIATE_TXN_FAIL');
	 FND_MSG_PUB.ADD;
	 IF (l_debug = 1) THEN
   	 print_debug('rcv_process_receive_txn 20.2: rcv_immediate_transaction RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 4);
	 END IF;
	 RAISE FND_API.g_exc_unexpected_error;
      END IF;

    ELSE
      l_progress := '30';
      COMMIT;
      rcv_online_request(x_return_status => l_return_status,
			 x_msg_data      => l_msg_data);

      IF l_return_status = FND_API.g_ret_sts_error THEN
	 FND_MESSAGE.SET_NAME('INV', 'INV_RCV_ONLINE_TXN_FAIL');
	 FND_MSG_PUB.ADD;
	 IF (l_debug = 1) THEN
   	 print_debug('rcv_process_receive_txn 30.1: rcv_online_request RAISE FND_API.G_EXC_ERROR;'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 4);
	 END IF;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;


      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 FND_MESSAGE.SET_NAME('INV', 'INV_RCV_ONLINE_TXN_FAIL');
	 FND_MSG_PUB.ADD;
	 IF (l_debug = 1) THEN
   	 print_debug('rcv_process_receive_txn 30.2: rcv_online_request RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 4);
	 END IF;
	 RAISE FND_API.g_exc_unexpected_error;
      END IF;

      COMMIT;
   END IF;

   IF l_return_status = fnd_api.g_ret_sts_success THEN
      rcv_print_traveller;
   END IF;
   inv_rcv_common_apis.g_rcv_global_var.interface_group_id := '';

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      rcv_print_traveller;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get
	(p_encoded	=> FND_API.g_false,
	 p_count  => l_msg_count,
	 p_data   => x_msg_data
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
      rcv_print_traveller;

      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      fnd_msg_pub.count_and_get
	(p_encoded	=> FND_API.g_false,
	 p_count  => l_msg_count,
	 p_data   => x_msg_data
	 );

   WHEN OTHERS THEN
      rcv_print_traveller;

      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF SQLCODE IS NOT NULL THEN
	 inv_mobile_helper_functions.sql_error('INV_RCV_MOBILE_PROCESS_TXN.rcv_process_receive_txn', l_progress, SQLCODE);
      END IF;
      fnd_msg_pub.count_and_get
	(p_encoded	=> FND_API.g_false,
	 p_count  => l_msg_count,
	 p_data   => x_msg_data
	 );

END rcv_process_receive_txn;
--start of 8539263 changes
Procedure lot_uom_conversion( p_org_id              IN  NUMBER
   ,  p_itemid                IN   NUMBER
   ,  p_from_uom_code         IN  VARCHAR2
   ,  p_to_uom_code           IN  VARCHAR2
   ,  p_lot_number            IN  VARCHAR2
   ,  p_user_response         IN  NUMBER
   ,  p_create_lot_uom_conv   IN NUMBER
   ,  p_conversion_rate       IN NUMBER
   , x_return_status OUT nocopy VARCHAR2,
				   x_msg_data       OUT nocopy VARCHAR2

   ) IS
    l_action_type              VARCHAR2(1);
    l_create_lot_uom_conv  INTEGER := 0;
    l_from_unit_of_measure VARCHAR2(25);
    l_from_uom_class       VARCHAR2(10);
    l_to_unit_of_measure   VARCHAR2(25);
    l_to_uom_class         VARCHAR2(10);
    l_go                   BOOLEAN := FALSE;
    l_sequence                 NUMBER;
    l_lot_uom_conv_rec         mtl_lot_uom_class_conversions%ROWTYPE;
    l_qty_update_tbl           MTL_LOT_UOM_CONV_PUB.quantity_update_rec_type;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_return_status              VARCHAR2(1);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    l_lot_exist    NUMBER;
    BEGIN
        IF (l_debug = 1) THEN
          print_debug('In  create_lot_uom_conversion,calling check existing lot', 1);
        END IF;


           BEGIN
               SELECT   unit_of_measure_tl, uom_class
               INTO     l_from_unit_of_measure, l_from_uom_class
               FROM     MTL_UNITS_OF_MEASURE
               WHERE    UOM_CODE = p_from_uom_code;
            EXCEPTION
               WHEN OTHERS THEN
                  l_from_unit_of_measure := NULL;
                  l_from_uom_class := NULL;
            END;
            BEGIN
               SELECT   unit_of_measure_tl, uom_class
               INTO     l_to_unit_of_measure, l_to_uom_class
               FROM     MTL_UNITS_OF_MEASURE
               WHERE    UOM_CODE = p_to_uom_code;
            EXCEPTION
               WHEN OTHERS THEN
                  l_to_unit_of_measure := NULL;
                  l_to_uom_class := NULL;
            END;

            IF NVL(p_create_lot_uom_conv, 2 ) IN (1,3) THEN
                     IF NVL(p_create_lot_uom_conv, 2 ) = 1
                     AND l_from_uom_class <> l_to_uom_class THEN
                          l_go := TRUE;
                     ELSIF NVL(p_create_lot_uom_conv,2 ) = 3
                        AND l_from_uom_class <> l_to_uom_class THEN
                           IF p_user_response = 0 THEN
                              l_go := TRUE;
                           ELSE
                              l_go := FALSE;
                           END IF;
                     END IF;
              ELSE
                     l_go := FALSE;
              END IF;
             IF l_go THEN
                  l_lot_uom_conv_rec.conversion_id          :=       NULL;
                  l_lot_uom_conv_rec.lot_number             :=       p_lot_number;
                  l_lot_uom_conv_rec.organization_id        :=       p_org_id;
                  l_lot_uom_conv_rec.inventory_item_id      :=       p_itemid;
                  l_lot_uom_conv_rec.from_unit_of_measure   :=       l_from_unit_of_measure;
                  l_lot_uom_conv_rec.from_uom_code          :=       p_from_uom_code;
                  l_lot_uom_conv_rec.from_uom_class         :=       l_from_uom_class;
                  l_lot_uom_conv_rec.to_unit_of_measure     :=       l_to_unit_of_measure;
                  l_lot_uom_conv_rec.to_uom_code            :=       p_to_uom_code;
                  l_lot_uom_conv_rec.to_uom_class           :=       l_to_uom_class;
                  l_lot_uom_conv_rec.conversion_rate        :=       p_conversion_rate;
                  l_lot_uom_conv_rec.disable_date           :=       NULL;
                  l_lot_uom_conv_rec.event_spec_disp_id     :=       NULL;
                  l_lot_uom_conv_rec.created_by             :=       FND_GLOBAL.user_id;
                  l_lot_uom_conv_rec.creation_date          :=       SYSDATE;
                  l_lot_uom_conv_rec.last_updated_by        :=       FND_GLOBAL.user_id;
                  l_lot_uom_conv_rec.last_update_date       :=       SYSDATE;
                  l_lot_uom_conv_rec.last_update_login      :=       FND_GLOBAL.login_id;
                  l_lot_uom_conv_rec.request_id             :=       NULL;
                  l_lot_uom_conv_rec.program_application_id :=       NULL;
                  l_lot_uom_conv_rec.program_id             :=       NULL;
                  l_lot_uom_conv_rec.program_update_date    :=       NULL;
                  l_action_type := 'I';

        	  MTL_LOT_UOM_CONV_PUB.CREATE_LOT_UOM_CONVERSION
                  (
                    p_api_version             =>          1.0
                  , p_init_msg_list          =>          'T'
                  , p_commit                 =>          'F'
                  , p_validation_level       =>          100
                  , p_action_type            =>          l_action_type
                  , p_update_type_indicator  =>          5
                  , p_reason_id              =>          NULL
                  , p_batch_id               =>          0
                  , p_process_data           =>          'Y'
                  , p_lot_uom_conv_rec       =>          l_lot_uom_conv_rec
                  , p_qty_update_tbl         =>          l_qty_update_tbl
                  , x_return_status          =>          l_return_status
                  , x_msg_count              =>          l_msg_count
                  , x_msg_data               =>          l_msg_data
                  , x_sequence               =>          l_sequence
                  );
                IF x_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
                ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
                ELSE
                  l_return_status:= fnd_api.g_ret_sts_success;
                END IF;
          END IF;

   x_return_status:= l_return_status;


EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

END lot_uom_conversion;
PROCEDURE check_existing_lot
 (  p_org_id      IN NUMBER
  , p_item_id     IN NUMBER
  , p_lot_number  IN VARCHAR2
  , x_lot_exist   OUT NOCOPY NUMBER
  , x_return_status OUT NOCOPY VARCHAR2
  , x_msg_data OUT NOCOPY VARCHAR2
) IS
      l_exists NUMBER := 0;
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN
        IF (l_debug = 1) THEN
          print_debug('In  check_existing_lot', 1);
        END IF;
      IF  p_lot_number IS NOT NULL THEN

         BEGIN
            SELECT 1
            INTO l_exists
            FROM mtl_lot_numbers
            WHERE inventory_item_id = p_item_id
            AND organization_id = p_org_id
            AND lot_number = p_lot_number
            AND  ROWNUM = 1;
         EXCEPTION
            WHEN no_data_found THEN
               BEGIN
                  SELECT 1
                  INTO l_exists
                  FROM mtl_transaction_lots_temp a
                     , mtl_material_transactions_temp b
                  WHERE b.inventory_item_id = p_item_id
                  AND a.lot_number = p_lot_number
                  AND a.transaction_temp_id = b.transaction_temp_id
                  AND rownum = 1
                  AND b.organization_id = p_org_id;
               EXCEPTION
                  WHEN no_data_found THEN
                     BEGIN
                        SELECT 1
                        INTO l_exists
                           FROM mtl_material_transactions_temp mtl
                           WHERE mtl.inventory_item_id <> p_item_id
                           AND mtl.lot_number = p_lot_number
                           AND mtl.organization_id = p_org_id
                           AND rownum = 1;
                     EXCEPTION
                        WHEN no_data_found THEN
                           l_exists := 0;
                     END;
               END;
         END;
         IF l_exists <> 0 THEN
               x_lot_exist := 1;
         ELSE
               x_lot_exist := 0;
         END IF;
      END IF;
      x_return_status := fnd_api.g_ret_sts_success;
   END check_existing_lot;
--end of 8539263 changes
END INV_RCV_MOBILE_PROCESS_TXN;


/
