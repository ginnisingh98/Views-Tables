--------------------------------------------------------
--  DDL for Package Body CSI_TRANSACTION_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_TRANSACTION_LINES_PVT" as
/* $Header: CSIVTLWB.pls 120.0.12000000.2 2007/07/11 16:32:16 ngoutam noship $ */
 -- Start of comments

 -- HISTORY

 -- End of comments

 procedure debug(p_message in varchar2) is
 begin
 	IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
 		--csi_t_gen_utility_pvt.add(p_message);
 	        fnd_log.string(fnd_log.level_statement,'csi.plsql.csi_transaction_lines_pvt.process_txn_lines' ,p_message);
  	END IF;
 end debug;


  PROCEDURE process_txn_lines
  (
    errbuf                      OUT NOCOPY     VARCHAR2,
    retcode                     OUT NOCOPY     NUMBER,
    p_batch_id        IN      NUMBER
    ,p_purge_option IN VARCHAR2
   )  IS
    	l_return_status       varchar2(1);
    	l_error_code          number;
    	l_error_message       varchar2(4000);
    	l_error_rec           csi_datastructures_pub.transaction_error_rec;
    	L_CONC_STATUS BOOLEAN;
    	l_worker_start_date date;
    	l_start_date date;
    	l_request_id	NUMBER;
    	l_start_timestamp TIMESTAMP;
	l_end_timestamp TIMESTAMP;

    	TYPE header_id_array_type is TABLE OF CSI_BATCH_TXN_LINES.ORDER_HEADER_ID%TYPE ;
	TYPE line_id_array_type is TABLE OF CSI_BATCH_TXN_LINES.ORDER_LINE_ID%TYPE ;
	TYPE transaction_id_type is TABLE of CSI_BATCH_TXN_LINES.transaction_id%type;
   	TYPE transaction_type   is TABLE of CSI_BATCH_TXN_LINES.transaction_type%type;

	l_header_id_tbl header_id_array_type;
	l_line_id_tbl   line_id_array_type;
	l_transaction_id_tbl transaction_id_type;
    	l_transaction_type_tbl transaction_type;

   	CURSOR transaction_lines_cur IS
        	SELECT transaction_type,transaction_id,order_header_id,order_line_id
        	FROM  CSI_BATCH_TXN_LINES
        	WHERE batch_id = p_batch_id
        	AND processed_flag = 2
        	order by order_header_id,order_line_id;
	--l_txn_lines_rec transaction_lines_cur%rowtype;

  BEGIN

	--EXECUTE IMMEDIATE 'ALTER SESSION SET TRACEFILE_IDENTIFIER = ''HIMAL'' ';
	--EXECUTE IMMEDIATE 'alter session set events=''10046 trace name context forever, level 12'' ';

	l_worker_start_date := SYSDATE;
    	l_request_id	:= FND_GLOBAL.conc_request_id;

  	debug('BEGIN CSI_TRANSACTION_LINES_PVT.Process_Txn_Lines, Batch : '||p_batch_id);

	-- mark the rows as being processed by worker
        update CSI_BATCH_TXN_LINES
        set processed_flag = 2,last_update_date = sysdate,last_updated_by = fnd_global.user_id
        where batch_id = p_batch_id
        and processed_flag = 1;

        debug(' Updated '||SQL%ROWCOUNT ||' rows with batch id '||p_batch_id);
        commit;

        SAVEPOINT process_txn_lines;

        --store all rows to be processed in an array
        Open transaction_lines_cur;

        -- Fetch LIMIT is implicitly given by the number of order lines assigned in CSIVTXPB (main program)
	Fetch transaction_lines_cur bulk collect into l_transaction_type_tbl,l_transaction_id_tbl,l_header_id_tbl,l_line_id_tbl;
	debug(l_line_id_tbl.count || ' order lines fetched');

	For i in l_line_id_tbl.first..l_line_id_tbl.count Loop
			l_start_date := SYSDATE;
			l_start_timestamp := SYSTIMESTAMP;
			debug('Started Processing Order Line: '||l_line_id_tbl(i)||' and Transaction: '||l_transaction_type_tbl(i));

			if l_transaction_type_tbl(i) = 'CSISOFUL' then
		  		debug(' Calling  csi_inv_txnstub_pkg.execute_trx_dpl for Order Line '||l_line_id_tbl(i));
		        	csi_inv_txnstub_pkg.execute_trx_dpl(
				       p_transaction_type  => l_transaction_type_tbl(i),
				       p_transaction_id    => l_line_id_tbl(i),
				       x_trx_return_status => l_return_status,
				       x_trx_error_rec     => l_error_rec);

				debug(' After Calling csi_inv_txnstub_pkg.execute_trx_dpl for Order Line '||l_line_id_tbl(i)||' with Return Status '||l_return_status);
				IF (l_return_status is null OR l_return_status <> fnd_api.g_ret_sts_success) THEN

					fnd_file.put_line(fnd_file.log,'Error Occured while processing Order Line '||l_line_id_tbl(i));
					debug('Call to csi_inv_txnstub_pkg.execute_trx_dpl fails with status '||l_return_status);

					UPDATE CSI_BATCH_TXN_LINES
					SET processed_flag = 4,last_update_date = sysdate,last_updated_by = fnd_global.user_id
					WHERE batch_id = p_batch_id
					AND processed_flag = 2
					and order_line_id = l_line_id_tbl(i);

					l_error_rec.inv_material_transaction_id := null;
					csi_inv_trxs_pkg.log_csi_error(l_error_rec);

				  END IF;
			elsif (l_transaction_type_tbl(i) = 'CSISOSHP') then

		        	debug(' Calling  csi_order_ship_pub.order_shipment for Order Line '||l_line_id_tbl(i));
		          	csi_order_ship_pub.order_shipment(
					        p_mtl_transaction_id => l_transaction_id_tbl(i),
				         	p_message_id         => NULL,
					        x_return_status      => l_return_status,
					        px_trx_error_rec     => l_error_rec);

				debug(' After Calling csi_order_ship_pub.order_shipment for Order Line: '||l_line_id_tbl(i)||' with Return Status '||l_return_status);
				IF (l_return_status is null OR l_return_status <> fnd_api.g_ret_sts_success) THEN
					fnd_file.put_line(fnd_file.log,'Error Occured while processing Order Line '||l_line_id_tbl(i));
					debug('Call to csi_order_ship_pub.order_shipment fails with status '||l_return_status);

					UPDATE CSI_BATCH_TXN_LINES
					SET processed_flag = 4,last_update_date = sysdate,last_updated_by = fnd_global.user_id
					WHERE batch_id = p_batch_id
					AND processed_flag = 2
			     		AND order_line_id = l_line_id_tbl(i);

	    		 	END IF;
	    		else
	    		 	 debug('Error! Transaction type ' || l_transaction_type_tbl(i) || ' is not supported by CSI_TRANSACTION_LINES_PVT.Process_Txn_Lines');
	    			 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	        	end if;
	        	l_end_timestamp := SYSTIMESTAMP;

			IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN

				--debug('Timing information for order line '||l_line_id_tbl(i)||': '|| (SYSDATE - l_start_date)*(60*60*24) || ' seconds.');
				debug('Timing information for order line '||l_line_id_tbl(i)||' using Timestamp: '||TO_CHAR(l_end_timestamp - l_start_timestamp));

				--INSERT INTO csi_batch_processing_times (worker_id, order_header_id, order_line_id, start_date, end_date,request_id,creation_date,created_by,last_update_date,last_updated_by)
				--VALUES( p_batch_id, l_header_id_tbl(i), l_line_id_tbl(i), l_start_date, sysdate,l_request_id,sysdate,fnd_global.user_id,sysdate,fnd_global.user_id);
	      		end if;

  	END Loop;
	close transaction_lines_cur;
  	--COMMIT;

   	if p_purge_option = 'Y' then

		--delete processed rows from the table
		delete from csi_batch_txn_lines
		where batch_id = p_batch_id
		AND processed_flag = 2;
   	else

   		-- mark the processed rows as success
   		UPDATE csi_batch_txn_lines
		SET processed_flag = 3,last_update_date = sysdate,last_updated_by = fnd_global.user_id
		where batch_id = p_batch_id
		and processed_flag = 2;

   	end if;

  	l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL', null);
  	debug('END CSI_TRANSACTION_LINES_PVT.Process_Txn_Lines, Batch : '||p_batch_id);

  	/* commenting as timing information was introduced for prototyping purpose only
  	IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
    		INSERT INTO csi_batch_processing_times
   		 (worker_id, start_date, end_date,creation_date,created_by,last_update_date,last_updated_by)
    		VALUES
    		(p_batch_id, l_worker_start_date, sysdate,sysdate,fnd_global.user_id,sysdate,fnd_global.user_id);
  	END IF;*/

	--EXECUTE IMMEDIATE 'alter session set events=''10046 trace name context OFF'' ';

  EXCEPTION
    WHEN txn_line_error THEN
      csi_t_gen_utility_pvt.build_file_name(
        p_file_segment1 => 'csiinv',
        p_file_segment2 => 'hook');
      l_error_rec.inv_material_transaction_id := null;
      csi_inv_trxs_pkg.log_csi_error(l_error_rec);

    WHEN OTHERS THEN
    	IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level THEN
		fnd_log.string(fnd_log.level_unexpected,'csi.plsql.csi_transaction_lines_pvt.process_txn_lines', 'WHEN OTHERS: ' ||SQLERRM);
	END IF;


    	ROLLBACK TO process_txn_lines;

    	update csi_batch_txn_lines
	set batch_id = -1,processed_flag = 0,last_update_date = sysdate,last_updated_by = fnd_global.user_id
    	where batch_id = p_batch_id;

    	commit;
    	RAISE;
END process_txn_lines;

END CSI_TRANSACTION_LINES_PVT;

/
