--------------------------------------------------------
--  DDL for Package Body CSI_TRANSACTION_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_TRANSACTION_IMPORT_PVT" as
/* $Header: CSIVTXPB.pls 120.0.12000000.2 2007/07/11 17:03:00 ngoutam noship $*/

   -- Start of comments
   -- API name : PROCESS_TRANSACTION_ROWS
   -- Type     : Private
   -- Function :
   -- Pre-reqs : None.
   -- Parameters :
   -- IN       p_max_worker_number         IN      NUMBER := 10

   -- OUT      ERRBUF OUT VARCHAR2,
   --          RETCODE OUT VARCHAR2
   --
   -- Version  Initial version    1.0     Himal Karmacharya
   --
   -- End of comments

 procedure debug(p_message in varchar2) is
 begin
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       --csi_t_gen_utility_pvt.add(p_message);
       fnd_log.string(fnd_log.level_statement, 'csi.plsql.csi_transaction_import_pvt.process_transaction_rows',p_message);
  END IF;
 end debug;

FUNCTION group_rows(p_num_workers in number) RETURN NUMBER IS
  l_num_rows NUMBER;
  l_seq NUMBER := 0;
  l_seq_incr NUMBER;
  l_header_count number;
  l_old_sequence_val	number := 0;
  l_schema 	varchar2(30);
  l_status 	varchar2(1);
  l_industry 	varchar2(1);

  TYPE header_id_array_type is TABLE OF CSI_BATCH_TXN_LINES.ORDER_HEADER_ID%TYPE ;
  l_header_id header_id_array_type;
  l_limit	number;

  CURSOR l_header_cur IS
      SELECT DISTINCT cbtl.order_header_id
      FROM   csi_batch_txn_lines cbtl
      WHERE  batch_id = -1
      AND NOT EXISTS (SELECT 'x' --do not assign a batch_id to an order that is
                     -- being processed
              FROM csi_batch_txn_lines cbtl2
              WHERE cbtl2.order_header_id = cbtl.order_header_id
              AND cbtl2.processed_flag IN (1,2)
              AND cbtl2.batch_id <> -1)
    ORDER BY order_header_id;

BEGIN

	SELECT csi_batch_txn_lines_s.nextval
	INTO l_seq
	FROM dual;

	OPEN  l_header_cur;
	FETCH l_header_cur BULK COLLECT INTO l_header_id LIMIT 100*p_num_workers;
	CLOSE l_header_cur;

	debug('Order Headers that will be batched: ' || l_header_id.count);
	if (l_header_id.count > 0) then

		FORALL i in l_header_id.first..l_header_id.last
		UPDATE csi_batch_txn_lines cbtl
		SET batch_id = l_seq + MOD(l_header_id(i), p_num_workers)
		WHERE order_header_id = l_header_id(i);

		debug('Assigned batch_id to ' || SQL%ROWCOUNT || ' order lines');

		commit;
		debug(' Old Sequence Value '||l_seq);
		l_old_sequence_val := l_seq;

		IF NOT FND_INSTALLATION.GET_APP_INFO('CSI', l_status, l_industry, l_schema) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		--Adjust sequence
		l_seq_incr := p_num_workers;
		EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.CSI_BATCH_TXN_LINES_S INCREMENT BY '||TO_CHAR(l_seq_incr);
		SELECT csi_batch_txn_lines_s.nextval
		INTO l_seq
		FROM dual;
		EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.CSI_BATCH_TXN_LINES_S INCREMENT BY 1';

		debug(' New Sequence Value '||l_seq);
	end if;

    RETURN l_old_sequence_val;

 exception
    	when no_data_found then
    		return l_old_sequence_val;
END group_rows;

PROCEDURE PROCESS_TRANSACTION_ROWS
    (ERRBUF OUT NOCOPY VARCHAR2,
     RETCODE OUT NOCOPY VARCHAR2,
     p_max_worker_number IN NUMBER := 10
     ,p_purge_option IN VARCHAR2
     ) IS

    	l_retcode Number;
    	CONC_STATUS BOOLEAN;
	l_process boolean := FALSE;
	l_num_workers number := 0;
	l_req_id number;
	l_request_id number;
	l_target_num number;
	l_active_num number;
	l_method varchar2(100);
	l_message varchar2(100);
	l_max_worker_number number;
	l_batch_lower_limit number;

	CURSOR worker_batch_cur(cp_workers_available in number,p_batch_lower_limit in number) IS
		select * from (
		    SELECT DISTINCT ctl.batch_id
	            FROM csi_batch_txn_lines CTL
		    WHERE ctl.processed_flag = 0
	            AND batch_id >= p_batch_lower_limit
	            )
	            where ROWNUM <= cp_workers_available
	            ;

BEGIN

   	debug('BEGIN CSI_TRANSACTION_IMPORT_PVT.process_transaction_rows');

   	if (p_max_worker_number < 1) then
   		l_max_worker_number := 1;
   	else
   		l_max_worker_number := p_max_worker_number;
   	end if;

	SELECT COUNT(*)
	INTO l_active_num
	FROM FND_CONCURRENT_REQUESTS FCR,
	     fnd_concurrent_programs FCP
	WHERE FCR.concurrent_program_id  = FCP.concurrent_program_id
	AND FCR.program_application_id = FCP.application_id
	AND FCP.application_id = 542
	AND FCP.concurrent_program_name = 'CSITXIMW'
	AND FCR.phase_code IN ('I','P','R');

	fnd_file.put_line(fnd_file.log, 'Number of Active Workers '||l_active_num);
	--check number of workers currently running
	if l_max_worker_number <= l_active_num then
		debug('Requested '||l_max_worker_number||' workers, but there are already '||l_active_num||' active workers');
		RETCODE := 'Success';
    		CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',Current_Error_Code);
		l_num_workers := 0;
		return;
	else
		l_num_workers := l_max_worker_number - l_active_num;
	end if;

	-- setting maximum num of workers that can be launched to 30
	if (l_num_workers > 30) then
		l_num_workers := 30;
	end if;

	debug('Number of Workers Available '||l_num_workers);
	fnd_file.put_line(fnd_file.log, 'Number of Workers Available '||l_num_workers);
	--batch rows
   	l_batch_lower_limit := group_rows(l_num_workers);
   	debug('Function Group_Rows returns with value '||l_batch_lower_limit);

   	if (l_batch_lower_limit = 0) then
   		debug(' No Rows to Process..Exiting CSI_TRANSACTION_IMPORT_PVT.process_transaction_rows ');
   		return;
   	end if;

   	for cur_batch in worker_batch_cur(l_num_workers,l_batch_lower_limit) loop

  		l_request_id := FND_REQUEST.submit_request(
                              'CSI',
                              'CSITXIMW',
                              NULL,
                              NULL,
                              FALSE,
                              cur_batch.batch_id
                              ,p_purge_option
                              );

                debug('Request Id '|| l_request_id || ' for batch ID '|| cur_batch.batch_id);
   		--fnd_file.put_line(fnd_file.log,'Request Id '|| l_request_id || ' for batch ID '|| cur_batch.batch_id);

  		IF ((l_request_id = 0) OR (l_request_id IS NULL)) then

  			--FND_MESSAGE.RETREIVE;
  			--FND_MESSAGE.ERROR;
  			debug('Error: Submit Request failed by returning Request Id '||l_request_id);
			RETCODE := 'Error';
        		CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);

        		-- unmark rows in csi_batch_txn_lines
        		update csi_batch_txn_lines
        		set batch_id = -1,last_update_date = sysdate,last_updated_by = fnd_global.user_id
        		where batch_id = cur_batch.batch_id;

      			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  		end if;

  		-- set the processed flag to 1 so that the next run of this program
  		-- will not process the rows
  		update CSI_BATCH_TXN_LINES
		set processed_flag = 1,last_update_date = sysdate,last_updated_by = fnd_global.user_id
		where batch_id = cur_batch.batch_id
        	and processed_flag = 0;

   	end loop;

	debug('END CSI_TRANSACTION_IMPORT_PVT.process_transaction_rows');
	COMMIT;
   	RETCODE := 'Success';

   	CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',Current_Error_Code);

EXCEPTION
	WHEN OTHERS THEN
    		IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level THEN
			fnd_log.string(fnd_log.level_unexpected,'csi.plsql.csi_transaction_import_pvt.process_transaction_rows', 'WHEN OTHERS: ' ||SQLERRM);
		END IF;

    		update csi_batch_txn_lines
    		set batch_id = -1,last_update_date = sysdate,last_updated_by = fnd_global.user_id
    		where processed_flag = 0;

    		commit;
    		RAISE;

END PROCESS_TRANSACTION_ROWS;

END CSI_TRANSACTION_IMPORT_PVT;


/
