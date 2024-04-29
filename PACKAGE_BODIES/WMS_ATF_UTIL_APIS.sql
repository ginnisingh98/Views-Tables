--------------------------------------------------------
--  DDL for Package Body WMS_ATF_UTIL_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_ATF_UTIL_APIS" AS
/* $Header: WMSOPUTB.pls 115.8 2004/02/05 01:39:47 lezhang noship $ */

g_ret_sts_success        VARCHAR2(1)  := fnd_api.g_ret_sts_success;
g_ret_sts_unexp_error    VARCHAR2(1)  := fnd_api.g_ret_sts_unexp_error;
g_ret_sts_error          VARCHAR2(1)  := fnd_api.g_ret_sts_error;
G_ACTION_RECEIPT CONSTANT NUMBER := inv_globals.g_action_receipt ;
G_ACTION_INTRANSITRECEIPT CONSTANT NUMBER := inv_globals.G_ACTION_INTRANSITRECEIPT;
G_ACTION_SUBXFR CONSTANT NUMBER := inv_globals.g_action_subxfr;
G_SOURCETYPE_MOVEORDER CONSTANT NUMBER := inv_globals.g_sourcetype_moveorder;
G_SOURCETYPE_PURCHASEORDER CONSTANT NUMBER := inv_globals.G_SOURCETYPE_PURCHASEORDER;
G_SOURCETYPE_INTREQ CONSTANT NUMBER := inv_globals.G_SOURCETYPE_INTREQ;
G_SOURCETYPE_RMA CONSTANT NUMBER := inv_globals.G_SOURCETYPE_RMA;
G_SOURCETYPE_INVENTORY CONSTANT NUMBER := inv_globals.G_SOURCETYPE_INVENTORY;

PROCEDURE print_debug(p_err_msg VARCHAR2,
		      p_level NUMBER)
  IS
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   inv_mobile_helper_functions.tracelog
     (p_err_msg => p_err_msg,
      p_module => 'WMS_ATF_Util_APIs',
      p_level => p_level);


   --   dbms_output.put_line(p_err_msg);
END print_debug;

PROCEDURE assign_operation_plan
  (
   p_api_version                  IN   NUMBER,
   p_init_msg_list                IN   VARCHAR2 DEFAULT 'F',
   p_commit                       IN   VARCHAR2 DEFAULT 'F',
   p_validation_level             IN   NUMBER   DEFAULT 100,
   x_return_status                OUT  NOCOPY VARCHAR2,
   x_msg_count                    OUT  NOCOPY NUMBER,
   x_msg_data                     OUT  NOCOPY VARCHAR2,
   p_task_id                      IN   NUMBER,
   p_activity_type_id             IN   NUMBER   DEFAULT NULL,
   p_organization_id              IN   NUMBER   DEFAULT NULL
   )
  IS
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     l_return_status       VARCHAR2(1);
     l_msg_count           NUMBER;
     l_msg_data            VARCHAR2(400);
     l_progress NUMBER;
BEGIN

   x_return_status  := g_ret_sts_success;


   IF (l_debug = 1) THEN
      print_debug('Entering assign_operation_plan ', 1);
      print_debug('p_api_version = '||p_api_version, 1);
      print_debug('p_init_msg_list = '||p_init_msg_list, 1);
      print_debug('p_commit = '||p_commit, 1);
      print_debug('p_validation_level = '||p_validation_level, 1);
      print_debug('p_task_id = '||p_task_id, 1);
      print_debug('p_activity_type_id = '||p_activity_type_id, 1);
      print_debug('p_organization_id = '||p_organization_id, 1);

      print_debug('Before calling wms_rule_pvt_ext_psetj.assign_operation_plan_psetj ', 1);

   END IF;

   l_progress := 10;
   SAVEPOINT sp_assign_operation_plan_intf;

   wms_rule_pvt_ext_psetj.assign_operation_plan_psetj
     (
      p_api_version          =>    p_api_version,
      p_init_msg_list        =>    p_init_msg_list,
      p_commit               =>    p_commit,
      p_validation_level     =>    p_validation_level,
      x_return_status        =>    l_return_status,
      x_msg_count            =>    l_msg_count,
      x_msg_data             =>    l_msg_data,
      p_task_id              =>    p_task_id,
      p_activity_type_id     =>    p_activity_type_id,
      p_organization_id      =>    p_organization_id
      );

   l_progress := 20;

   IF (l_debug = 1) THEN

      print_debug('After calling wms_rule_pvt_ext_psetj.assign_operation_plan_psetj ', 1);

      print_debug('x_return_status = '||l_return_status, 4);
      print_debug('x_msg_count = '||l_msg_count, 4);
      print_debug('x_msg_data = '||l_msg_data, 4);
   END IF;

   IF x_return_status <>FND_API.g_ret_sts_success THEN
      IF (l_debug=1) THEN
	 print_debug('wms_rule_pvt_ext_psetj.assign_operation_plan_psetj finished with error. l_return_status = ' || l_return_status,4);
      END IF;

      RAISE FND_API.G_EXC_ERROR;
   END IF;


   IF (l_debug = 1) THEN

      print_debug('Exiting assign_operation_plan ', 1);

   END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:=FND_API.G_RET_STS_ERROR;
      IF (l_debug=1) THEN
	 print_debug('assign_operation_plan expected Error Obtained at'||l_progress,1);
      END IF;
      ROLLBACK TO sp_assign_operation_plan_intf;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
      IF (l_debug=1) THEN
	 print_debug('assign_operation_plan Unexpected Error Obtained at'||l_progress,1);
      END IF;
      ROLLBACK TO sp_assign_operation_plan_intf;

   WHEN OTHERS THEN
      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
      IF (l_debug=1) THEN
	 print_debug('assign_operation_plan OTHER Error Obtained at'||l_progress,1);
	 IF SQLCODE IS NOT NULL THEN
	    print_debug('With SQL error : ' || SQLERRM(SQLCODE), 1);
	 END IF;
      END IF;
      ROLLBACK TO sp_assign_operation_plan_intf;

END assign_operation_plan;



  /**
  *   complete_tm_processing
  *
  *   <p>This API conlcudes the exeuction of an operation plan.</P>
  *
  *   <p>Inventory transaction manager should call this API:
  *      1. After processing a transaction;
  *      2. Before deleting the MMTT record;
  *      3. WHen MMTT.operation_plan_ID IS NOT NULL. </P>
  *
  *
  *  @param x_return_status          -Return Status
  *  @param x_msg_data               -Returns the Error message Data
  *  @param x_msg_count              -Returns the message count
  *  @param p_organization_id        -Organization ID
  *  @param p_txn_header_id          -MMTT.transaction_header_id (passed when TM fails to process one MMTT within a batch)
  *  @param p_txn_batch_id           -MMTT.transaction_batch_id (passed when TM fails to process one MMTT within a batch)
  *  @param p_transaction_temp_id    -MMTT.transaction_temp_id (passed when TM successfully processed one MMTT)
  *  @param p_tm_complete_status     -Return status of TM processing: 0 - success, else failure
  *  @param p_txn_processing_mode    -Mode in which TM was called: 1 - online, 2 - background, 3 - concurrent

  **/

    PROCEDURE complete_tm_processing
    (
     x_return_status                OUT  NOCOPY VARCHAR2,
     x_msg_count                    OUT  NOCOPY NUMBER,
     x_msg_data                     OUT  NOCOPY VARCHAR2,
     p_organization_id              IN   NUMBER,
     p_txn_header_id                IN   NUMBER DEFAULT NULL,
     p_txn_batch_id                 IN   NUMBER DEFAULT NULL,
     p_transaction_temp_id          IN   NUMBER DEFAULT NULL,
     p_tm_complete_status           IN   NUMBER,
     p_txn_processing_mode          IN   NUMBER
     )
    IS
       l_debug               NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
       l_progress            NUMBER;
       l_return_status       VARCHAR2(1);
       l_msg_count           NUMBER;
       l_msg_data            VARCHAR2(400);
       l_atf_error_code      NUMBER;
       l_proc_mode           NUMBER := p_txn_processing_mode;
       l_transaction_temp_id NUMBER;
       l_is_deliver_txn_flag VARCHAR2(1) := 'N';
       l_rcv_routing         NUMBER;
       l_wdt_exists          NUMBER :=0;


       CURSOR c_txn_batch_inbound_mmtts
	 IS
	    SELECT
	      transaction_temp_id,
	      transaction_action_id,
	      transaction_source_type_id,
	      parent_line_id,
	      rcv_transaction_id
	      FROM mtl_material_transactions_temp
	      WHERE transaction_header_id = p_txn_header_id
	      AND Nvl(transaction_batch_id, -999) = Nvl(p_txn_batch_id,  Nvl(transaction_batch_id, -999))
--	      AND transaction_temp_id = Nvl(p_transaction_temp_id, transaction_temp_id
	      AND wms_task_type IN (2, -1) -- putaway
	      ;

       -- IMPORTANT
       -- Need return exatly same columns as c_txn_batch_inbound_mmtts but transaction temp ID passed

       CURSOR c_inbound_mmtts_tmp_id
	 IS
	    SELECT
	      transaction_temp_id,
	      transaction_action_id,
	      transaction_source_type_id,
	      parent_line_id,
	      rcv_transaction_id
	      FROM mtl_material_transactions_temp
--	      WHERE transaction_header_id = p_txn_header_id
--	      AND Nvl(transaction_batch_id, -999) = Nvl(p_txn_batch_id, Nvl(transaction_batch_id, -999))
	      WHERE transaction_temp_id = p_transaction_temp_id
	      AND wms_task_type IN (2, -1) -- putaway
	      ;

       l_txn_batch_inbound_mmtt_rec c_txn_batch_inbound_mmtts%ROWTYPE;

       CURSOR c_rcv_routing (v_rt_transaction_id NUMBER )
	 IS
	    SELECT routing_header_id
	      FROM rcv_transactions
	      WHERE transaction_id = v_rt_transaction_id;

       -- For those non-ATF transactions
       -- if the transaction happens (pack/unpack, misc. txn) to an LPN that contains mmtt belongs to operation plan
       -- need to cancel these operation plans.

       CURSOR c_lpns_to_cancel
	 IS
	    SELECT lpn_id, content_lpn_id, transfer_lpn_id
	      FROM mtl_material_transactions_temp
	      WHERE transaction_temp_id = p_transaction_temp_id
	      AND (wms_task_type NOT IN (2, -1)
		   OR wms_task_type IS NULL);
	l_lpns_to_cancel_rec   c_lpns_to_cancel%ROWTYPE;

	CURSOR c_mmtts_in_lpn(v_lpn_id NUMBER)
	  IS
	     SELECT transaction_temp_id
	       FROM mtl_material_transactions_temp
	       WHERE lpn_id = v_lpn_id
	       AND operation_plan_id IS NOT NULL
		 AND wms_task_type IN (2, -1);

	 l_mmtt_to_cancel_rec       c_mmtts_in_lpn%ROWTYPE;


    BEGIN

       x_return_status  := g_ret_sts_success;

       IF (l_debug = 1) THEN
	  print_debug('Entering complete_tm_processing ', 1);
	  print_debug('p_organization_id = '||p_organization_id, 4);
	  print_debug('p_txn_header_id = '||p_txn_header_id, 4);
	  print_debug('p_txn_batch_id = '||p_txn_batch_id, 4);
	  print_debug('p_tm_complete_status = '||p_tm_complete_status, 4);
	  print_debug('p_txn_processing_mode = '||p_txn_processing_mode, 4);
    	  print_debug('p_transaction_temp_id= '||p_transaction_temp_id, 4);
       END IF;

       l_progress := 10;
       SAVEPOINT sp_complete_tm_processing;
       l_progress := 20;


       -- For those non-ATF transactions
       -- if the transaction happens (pack/unpack, misc. txn) to an LPN that contains mmtts belongs to operation plan
       -- need to cancel those operation plans.

       IF p_transaction_temp_id IS NOT NULL THEN
	  OPEN c_lpns_to_cancel;
	  LOOP
	     FETCH c_lpns_to_cancel
	       INTO l_lpns_to_cancel_rec;
	     EXIT WHEN c_lpns_to_cancel%notfound;
	     l_progress := 20.001;
	     IF (l_debug = 1) THEN
		print_debug('This is a normal MMTT, need to make sure operation plan affected by LPN being cancelled. ', 4);
		print_debug('l_lpns_to_cancel_rec.transfer_lpn_id = '||l_lpns_to_cancel_rec.transfer_lpn_id , 4);
		print_debug('l_lpns_to_cancel_rec.content_lpn_id = '||l_lpns_to_cancel_rec.content_lpn_id , 4);
		print_debug('l_lpns_to_cancel_rec.lpn_id = '||l_lpns_to_cancel_rec.lpn_id , 4);
	     END IF;

	     IF l_lpns_to_cancel_rec.transfer_lpn_id IS NOT NULL THEN
		OPEN c_mmtts_in_lpn(l_lpns_to_cancel_rec.transfer_lpn_id);
		LOOP
		   FETCH c_mmtts_in_lpn
		     INTO l_mmtt_to_cancel_rec;
		   EXIT WHEN c_mmtts_in_lpn%notfound;
		   l_progress := 20.002;

		   IF (l_debug = 1) THEN
		      print_debug('Need to cancel plan for transfer_lpn_id '||l_lpns_to_cancel_rec.transfer_lpn_id, 4);
		      print_debug('Before calling WMS_ATF_RUNTIME_PUB_APIS.Cancel_operation_Plan with following params:', 4);
		      print_debug('p_source_task_id => '|| l_mmtt_to_cancel_rec.transaction_temp_id, 4);
		      print_debug('p_activity_type_id => '|| 1, 4);
		   END IF;

		   wms_atf_runtime_pub_apis.cancel_operation_plan
		     (
		      x_return_status     => l_return_status,
		      x_msg_data          => l_msg_data,
		      x_msg_count         => l_msg_count,
		      x_error_code        => l_atf_error_code,
		      p_source_task_id    => l_mmtt_to_cancel_rec.transaction_temp_id,
		      p_activity_type_id  => 1);

		   IF (l_debug = 1) THEN
		      print_debug('After calling WMS_ATF_RUNTIME_PUB_APIS.Cancel_operation_Plan:', 4);
		      print_debug('l_return_status => '||l_return_status, 4);
		      print_debug('l_msg_data => '||l_msg_data, 4);
		      print_debug('l_msg_count => '||l_msg_count, 4);
		   END IF;

		   IF l_return_status <>FND_API.g_ret_sts_success THEN
		      IF (l_debug=1) THEN
			 print_debug('wms_atf_runtime_pub_apis.Cancel_operation_Plan - transfer_lpn_id finished with error. l_return_status = ' || l_return_status, 4);
		      END IF;

		      RAISE FND_API.G_EXC_ERROR;
		   END IF;
		   l_progress := 20.003;

		END LOOP;
		CLOSE c_mmtts_in_lpn;

	     END IF;

	     IF l_lpns_to_cancel_rec.content_lpn_id IS NOT NULL THEN
		OPEN c_mmtts_in_lpn(l_lpns_to_cancel_rec.content_lpn_id);
		LOOP
		   FETCH c_mmtts_in_lpn
		     INTO l_mmtt_to_cancel_rec;
		   EXIT WHEN c_mmtts_in_lpn%notfound;
		   l_progress := 20.005;
		   IF (l_debug = 1) THEN
		      print_debug('Need to cancel plan for content_lpn_id '||l_lpns_to_cancel_rec.content_lpn_id, 4);
		      print_debug('Before calling WMS_ATF_RUNTIME_PUB_APIS.Cancel_operation_Plan with following params:', 4);
		      print_debug('p_source_task_id => '|| l_mmtt_to_cancel_rec.transaction_temp_id, 4);
		      print_debug('p_activity_type_id => '|| 1, 4);
		   END IF;

		   wms_atf_runtime_pub_apis.cancel_operation_plan
		     (
		      x_return_status     => l_return_status,
		      x_msg_data          => l_msg_data,
		      x_msg_count         => l_msg_count,
		      x_error_code        => l_atf_error_code,
		      p_source_task_id    => l_mmtt_to_cancel_rec.transaction_temp_id,
		      p_activity_type_id  => 1);

		   IF (l_debug = 1) THEN
		      print_debug('After calling WMS_ATF_RUNTIME_PUB_APIS.Cancel_operation_Plan:', 4);
		      print_debug('l_return_status => '||l_return_status, 4);
		      print_debug('l_msg_data => '||l_msg_data, 4);
		      print_debug('l_msg_count => '||l_msg_count, 4);
		   END IF;

		   IF l_return_status <>FND_API.g_ret_sts_success THEN
		      IF (l_debug=1) THEN
			 print_debug('wms_atf_runtime_pub_apis.Cancel_operation_Plan - content_lpn_id finished with error. l_return_status = ' || l_return_status, 4);
		      END IF;

		      RAISE FND_API.G_EXC_ERROR;
		   END IF;
		   l_progress := 20.006;

		END LOOP;
		CLOSE c_mmtts_in_lpn;
	     END IF;

	     IF l_lpns_to_cancel_rec.lpn_id IS NOT NULL THEN
		OPEN c_mmtts_in_lpn(l_lpns_to_cancel_rec.lpn_id);
		LOOP
		   FETCH c_mmtts_in_lpn
		     INTO l_mmtt_to_cancel_rec;
		   EXIT WHEN c_mmtts_in_lpn%notfound;
		   l_progress := 20.007;

		   IF (l_debug = 1) THEN
		      print_debug('Need to cancel plan for lpn_id '||l_lpns_to_cancel_rec.lpn_id, 4);
		      print_debug('Before calling WMS_ATF_RUNTIME_PUB_APIS.Cancel_operation_Plan with following params:', 4);
		      print_debug('p_source_task_id => '|| l_mmtt_to_cancel_rec.transaction_temp_id, 4);
		      print_debug('p_activity_type_id => '|| 1, 4);
		   END IF;

		   wms_atf_runtime_pub_apis.cancel_operation_plan
		     (
		      x_return_status     => l_return_status,
		      x_msg_data          => l_msg_data,
		      x_msg_count         => l_msg_count,
		      x_error_code        => l_atf_error_code,
		      p_source_task_id    => l_mmtt_to_cancel_rec.transaction_temp_id,
		      p_activity_type_id  => 1);

		   IF (l_debug = 1) THEN
		      print_debug('After calling WMS_ATF_RUNTIME_PUB_APIS.Cancel_operation_Plan:', 4);
		      print_debug('l_return_status => '||l_return_status, 4);
		      print_debug('l_msg_data => '||l_msg_data, 4);
		      print_debug('l_msg_count => '||l_msg_count, 4);
		   END IF;

		   IF l_return_status <>FND_API.g_ret_sts_success THEN
		      IF (l_debug=1) THEN
			 print_debug('wms_atf_runtime_pub_apis.Cancel_operation_Plan - lpn_id finished with error. l_return_status = ' || l_return_status, 4);
		      END IF;

		      RAISE FND_API.G_EXC_ERROR;
		   END IF;

		   l_progress := 20.008;
		END LOOP;
		CLOSE c_mmtts_in_lpn;
	     END IF;

	     -- if it ever enters this single LOOP, it is a non-ATF mmtt, simply return from here.
	     IF c_lpns_to_cancel%isopen THEN
		CLOSE c_lpns_to_cancel;
	     END IF;
	     l_progress := 20.009;
	     IF (l_debug = 1) THEN
		print_debug('This is a normal MMTT, Return without ATF processing. ', 4);
	     END IF;
	     RETURN;
	  END LOOP;
	  CLOSE c_lpns_to_cancel;
       END IF;


       l_proc_mode := FND_PROFILE.VALUE('TRANSACTION_PROCESS_MODE');
       IF (l_debug = 1) THEN
	  print_debug('l_proc_mode = '||l_proc_mode, 4);
       END IF;

       -- Need to add logic to determine processing mode
       -- As of now Prashat has not decided the approach to do so,
       -- i.e. call API or copy/paste TM code to here.

       IF l_proc_mode = 4 THEN
	  l_proc_mode := 1;
       END IF;

       IF p_transaction_temp_id IS NULL THEN
	  OPEN c_txn_batch_inbound_mmtts;
	ELSE
	  OPEN c_inbound_mmtts_tmp_id;
       END if;

       LOOP
	  IF p_transaction_temp_id IS NULL THEN
	     FETCH c_txn_batch_inbound_mmtts
	       INTO l_txn_batch_inbound_mmtt_rec;

	     EXIT WHEN c_txn_batch_inbound_mmtts%notfound;

	   ELSE
	     FETCH c_inbound_mmtts_tmp_id
	       INTO l_txn_batch_inbound_mmtt_rec;

	     EXIT WHEN c_inbound_mmtts_tmp_id%notfound;

	  END IF;


	  IF (l_debug = 1) THEN
	     print_debug('l_txn_batch_inbound_mmtt_rec.transaction_temp_id = '||l_txn_batch_inbound_mmtt_rec.transaction_temp_id ,4);
	     print_debug('l_txn_batch_inbound_mmtt_rec.transaction_action_id = '||l_txn_batch_inbound_mmtt_rec.transaction_action_id ,4);
	     print_debug('l_txn_batch_inbound_mmtt_rec.transaction_source_type_id = '||l_txn_batch_inbound_mmtt_rec.transaction_source_type_id ,4);
	     print_debug('l_txn_batch_inbound_mmtt_rec.parent_line_id = '||l_txn_batch_inbound_mmtt_rec.parent_line_id ,4);
	     print_debug('l_txn_batch_inbound_mmtt_rec.rcv_transaction_id = '||l_txn_batch_inbound_mmtt_rec.rcv_transaction_id ,4);

	  END IF;


	  --Bug 3164504
	  -- Complete operation instance need not be called if WDT lines do
	  -- not exist. This is for rcv or wip transactions from the
	  -- desktop AND for all subtransfer transactions

	  print_debug('Before checking existence of WDT' ,4);

          BEGIN

	     SELECT 1
	       INTO l_wdt_exists
	       FROM DUAL
	       WHERE EXISTS(SELECT 1
                      FROM wms_dispatched_tasks
			    WHERE task_type=2
			    AND (transaction_temp_id = l_txn_batch_inbound_mmtt_rec.transaction_temp_id
				 OR transaction_temp_id =
				 l_txn_batch_inbound_mmtt_rec.parent_line_id));

	  EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		l_wdt_exists  := 0;
	  END;

	  print_debug('After checking existence of WDT' ,4);
	  print_debug('l_wdt_exists='||l_wdt_exists ,4);


	  IF l_wdt_exists=0 THEN
	     print_debug('WDT does not exist. Returning' ,4);

	     IF c_txn_batch_inbound_mmtts%isopen THEN
		CLOSE c_txn_batch_inbound_mmtts;
	     END IF;

	     IF c_inbound_mmtts_tmp_id%isopen THEN
		CLOSE c_inbound_mmtts_tmp_id;
	     END IF;

	     RETURN;

	  END IF;

	  -- End Bug fix 3164504


	  IF (l_txn_batch_inbound_mmtt_rec.transaction_action_id = G_ACTION_RECEIPT
	      AND l_txn_batch_inbound_mmtt_rec.transaction_source_type_id = g_sourcetype_purchaseorder
	      -- PO receipt (1, 27)
	      ) OR
	    (l_txn_batch_inbound_mmtt_rec.transaction_action_id = G_ACTION_RECEIPT
	     AND l_txn_batch_inbound_mmtt_rec.transaction_source_type_id = g_sourcetype_rma
	     -- RMA receipt (12, 27)
	     ) OR
	    (l_txn_batch_inbound_mmtt_rec.transaction_action_id = G_ACTION_INTRANSITRECEIPT
	     AND l_txn_batch_inbound_mmtt_rec.transaction_source_type_id = g_sourcetype_intreq
	     -- Internal REQ
	     )OR
	    (l_txn_batch_inbound_mmtt_rec.transaction_action_id = G_ACTION_INTRANSITRECEIPT
	     AND l_txn_batch_inbound_mmtt_rec.transaction_source_type_id = G_SOURCETYPE_INVENTORY
	     -- Intransit shipment
	     )
	    THEN
	     IF (l_debug = 1) THEN
		print_debug('complete_tm_processing - this is a deliver transaction ', 4);
	     END IF;

	     OPEN c_rcv_routing (l_txn_batch_inbound_mmtt_rec.rcv_transaction_id);
	     FETCH c_rcv_routing INTO l_rcv_routing;
	     CLOSE c_rcv_routing;


	     IF (l_debug = 1) THEN
		print_debug('complete_tm_processing -  l_rcv_routing = ' || l_rcv_routing, 4);

	     END IF;

	     IF l_rcv_routing = 3 THEN

		IF (l_debug = 1) THEN
		   print_debug('complete_tm_processing - Direct routing, simply return w/o calling complete_operation_instance ', 4);
		END IF;

		IF c_txn_batch_inbound_mmtts%isopen THEN
		   CLOSE c_txn_batch_inbound_mmtts;
		END IF;

		IF c_inbound_mmtts_tmp_id%isopen THEN
		   CLOSE c_inbound_mmtts_tmp_id;
		END IF;

		RETURN;
	     END IF;


	     l_transaction_temp_id := l_txn_batch_inbound_mmtt_rec.parent_line_id;
	     l_is_deliver_txn_flag := 'Y';
	   ELSE
	     IF (l_debug = 1) THEN
		print_debug('complete_tm_processing - this is NOT a deliver transaction ', 4);
	     END IF;

	     l_transaction_temp_id := l_txn_batch_inbound_mmtt_rec.transaction_temp_id;
	     l_is_deliver_txn_flag := 'N';
	  END IF;


	  IF p_tm_complete_status = 0 THEN  -- TM completes successfully


   	     IF (l_debug = 1) THEN
		print_debug('complete_tm_processing - Before calling wms_atf_runtime_pub_apis.complete_operation_instance ', 4);

		print_debug('l_transaction_temp_id = '||l_transaction_temp_id, 4);
		print_debug('p_activity_id = '||1, 4);
		print_debug('p_operation_type_id = '||2, 4);
	     END IF;


	     wms_atf_runtime_pub_apis.complete_operation_instance
	       (
		x_return_status       => l_return_status
		,x_msg_data           => l_msg_data
		,x_msg_count          => l_msg_count
		,x_error_code         => l_atf_error_code
		,p_source_task_id     => l_transaction_temp_id
		,p_activity_id        => 1 -- inbound
		,p_operation_type_id  => 2 -- drop INV TM is always called for a drop operation
		);

	     IF (l_debug = 1) THEN

		print_debug('complete_tm_processing - After calling wms_atf_runtime_pub_apis.complete_operation_instance ', 4);

		print_debug('x_return_status = '||x_return_status, 4);
		print_debug('x_msg_count = '||x_msg_count, 4);
		print_debug('x_msg_data = '||x_msg_data, 4);

	     END IF;

	     IF l_return_status <>FND_API.g_ret_sts_success THEN
		IF (l_debug=1) THEN
		   print_debug('wms_atf_runtime_pub_apis.complete_operation_instance  finished with error. l_return_status = ' || l_return_status, 4);
		END IF;

		RAISE FND_API.G_EXC_ERROR;
	     END IF;

	   ELSE -- TM failed
	     IF l_proc_mode <> 1 -- TM processing mode is NOT online
	       AND l_is_deliver_txn_flag <> 'Y' -- not receiving deliver transaction
	       THEN

		-- Delivery transaction will call cleanup_operation_instance
		-- from txn_complete of receiving code.
		-- Because receiving TM calls inventory TM one MMTT after another,
		-- but if any of them fails, should cleanup the entire batch.

		IF (l_debug = 1) THEN
		   print_debug('complete_tm_processing - Before calling wms_atf_runtime_pub_apis.cleanup_operation_instance ', 4);

		   print_debug('l_transaction_temp_id = '||l_transaction_temp_id, 4);
		   print_debug('p_activity_id = '||1, 4);

		END IF;

		wms_atf_runtime_pub_apis.cleanup_operation_instance
		  (
		   x_return_status       => l_return_status
		   , x_msg_data          => l_msg_data
		   , x_msg_count         => l_msg_count
		   , x_error_code        => l_atf_error_code
		   , p_source_task_id    => l_transaction_temp_id
		   , p_activity_type_id  => 1 -- inbound
		   );

		IF (l_debug = 1) THEN

		   print_debug('complete_tm_processing - After calling wms_atf_runtime_pub_apis.cleanup_operation_instance ', 4);

		   print_debug('x_return_status = '||x_return_status, 4);
		   print_debug('x_msg_count = '||x_msg_count, 4);
		   print_debug('x_msg_data = '||x_msg_data, 4);

		END IF;

		IF l_return_status <>FND_API.g_ret_sts_success THEN
		   IF (l_debug=1) THEN
		      print_debug('wms_atf_runtime_pub_apis.cleanup_operation_instance  finished with error. l_return_status = ' || l_return_status, 4);
		   END IF;

		   RAISE FND_API.G_EXC_ERROR;
		END IF;

	     END IF; -- IF l_proc_mode <> 1

	  END IF;  -- IF p_tm_complete_status = 0



       END LOOP;  -- c_txn_batch_inbound_mmtts loop

       IF c_txn_batch_inbound_mmtts%isopen THEN
	  CLOSE c_txn_batch_inbound_mmtts;
       END IF;

       IF c_inbound_mmtts_tmp_id%isopen THEN
	  CLOSE c_inbound_mmtts_tmp_id;
       END IF;

       IF (l_debug = 1) THEN

	  print_debug('x_return_status = '||x_return_status, 4);
	  print_debug('x_msg_count = '||x_msg_count, 4);
	  print_debug('x_msg_data = '||x_msg_data, 4);

	  print_debug('Exiting complete_tm_processing ', 1);

       END IF;


    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
	  x_return_status:=FND_API.G_RET_STS_ERROR;
	  IF (l_debug=1) THEN
	     print_debug('complete_tm_processing expected Error Obtained at'||l_progress,1);
	  END IF;
	  ROLLBACK TO sp_complete_tm_processing;

	  IF c_txn_batch_inbound_mmtts%isopen THEN
	     CLOSE c_txn_batch_inbound_mmtts;
	  END IF;

	  IF c_inbound_mmtts_tmp_id%isopen THEN
	     CLOSE c_inbound_mmtts_tmp_id;
	  END IF;

 	  IF c_rcv_routing%isopen THEN
	     CLOSE c_rcv_routing;
	  END IF;

	  IF c_lpns_to_cancel%isopen THEN
	     CLOSE c_lpns_to_cancel;
	  END IF;

	  IF c_mmtts_in_lpn%isopen THEN
	     CLOSE c_mmtts_in_lpn;
	  END IF;


       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	  x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
	  IF (l_debug=1) THEN
	     print_debug('complete_tm_processing Unexpected Error Obtained at'||l_progress,1);
	  END IF;
	  ROLLBACK TO sp_complete_tm_processing;

 	  IF c_txn_batch_inbound_mmtts%isopen THEN
	     CLOSE c_txn_batch_inbound_mmtts;
	  END IF;

	  IF c_inbound_mmtts_tmp_id%isopen THEN
	     CLOSE c_inbound_mmtts_tmp_id;
	  END IF;

 	  IF c_rcv_routing%isopen THEN
	     CLOSE c_rcv_routing;
	  END IF;

	  IF c_lpns_to_cancel%isopen THEN
	     CLOSE c_lpns_to_cancel;
	  END IF;

	  IF c_mmtts_in_lpn%isopen THEN
	     CLOSE c_mmtts_in_lpn;
	  END IF;


       WHEN OTHERS THEN
	  x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
	  IF (l_debug=1) THEN
	     print_debug('complete_tm_processing OTHER Error Obtained at'||l_progress,1);
	     IF SQLCODE IS NOT NULL THEN
		print_debug('With SQL error : ' || SQLERRM(SQLCODE), 1);
	     END IF;
	  END IF;
	  ROLLBACK TO sp_complete_tm_processing;

	  IF c_txn_batch_inbound_mmtts%isopen THEN
	     CLOSE c_txn_batch_inbound_mmtts;
	  END IF;

	  IF c_inbound_mmtts_tmp_id%isopen THEN
	     CLOSE c_inbound_mmtts_tmp_id;
	  END IF;

 	  IF c_rcv_routing%isopen THEN
	     CLOSE c_rcv_routing;
	  END IF;

	  IF c_lpns_to_cancel%isopen THEN
	     CLOSE c_lpns_to_cancel;
	  END IF;

	  IF c_mmtts_in_lpn%isopen THEN
	     CLOSE c_mmtts_in_lpn;
	  END IF;

    END complete_tm_processing;

END WMS_ATF_Util_APIs;

/
