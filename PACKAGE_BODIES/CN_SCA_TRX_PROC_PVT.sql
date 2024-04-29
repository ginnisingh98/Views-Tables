--------------------------------------------------------
--  DDL for Package Body CN_SCA_TRX_PROC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SCA_TRX_PROC_PVT" AS
-- $Header: cnvstrpb.pls 120.7.12010000.2 2009/01/29 06:44:42 gmarwah ship $
-- +======================================================================+
-- |                Copyright (c) 1994 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- +======================================================================+


-- Package Name
--   cn_sca_trx_proc_pvt
-- Purpose
--   Procedures TO populate transactions from CN_COMM_LINES_API into SCA interface tables and
--   transfer results back to CN_COMM_LINES_API from SCA output tables after credit allocation
-- History
--   06/02/03   Mike Ting 	Created
--  Nov 17, 2005     vensrini    add call to fnd_request.set_org_id to call_populate_resuts
--                                   before calling fnd_request.submit_request
--  Mar 31, 2005     vensrini    Bug fix 5125980
--


-- Global Variable
G_PKG_NAME                  	CONSTANT VARCHAR2(30) := 'CN_SCA_TRX_PROC_PVT';

no_trx_lines	    EXCEPTION;
no_trx              EXCEPTION;
conc_fail           EXCEPTION;
api_call_failed     EXCEPTION;
fail_populate       EXCEPTION;
g_cn_debug          VARCHAR2(1) := fnd_profile.value('CN_DEBUG');

FUNCTION get_adjusted_by
   RETURN VARCHAR2 IS
   l_adjusted_by 	VARCHAR2(100) := '0';
BEGIN
   SELECT user_name
     INTO l_adjusted_by
     FROM fnd_user
    WHERE user_id  = fnd_profile.value('USER_ID');
   RETURN l_adjusted_by;
EXCEPTION
   WHEN OTHERS THEN
      RETURN l_adjusted_by;
END;

-- Local Procedure for showing debug msg

PROCEDURE debugmsg(msg VARCHAR2) IS
BEGIN

    IF g_cn_debug = 'Y' THEN
        cn_message_pkg.debug(substr(msg,1,254));
	fnd_file.put_line(fnd_file.Log, msg);  -- Bug fix 5125980
    END IF;
   -- comment out dbms_output before checking in file
   -- dbms_output.put_line(substr(msg,1,254));
END debugmsg;

-- Procedure for submitting concurrent requests

PROCEDURE Conc_Submit(x_conc_program		VARCHAR2
		       ,x_parent_proc_audit_id  NUMBER
		       ,x_process	            VARCHAR2
		       ,x_physical_batch_id 	NUMBER
		       ,x_start_date            DATE
		       ,x_end_date              DATE
			,x_request_id 	 IN OUT NOCOPY NUMBER) IS

   l_org_id cn_sca_process_batches.org_id%TYPE;

 BEGIN

    debugmsg('Conc_Submit : x_process = '|| x_process);
    debugmsg('Conc_Submit : x_start_date = '|| x_start_date);
    debugmsg('Conc_Submit : x_end_date = '|| x_end_date);
    debugmsg('Conc_Submit : x_physical_batch_id = '|| x_physical_batch_id);

    SELECT org_id
      INTO l_org_id
      FROM cn_sca_process_batches
      WHERE sca_process_batch_id = x_physical_batch_id;

    fnd_request.set_org_id( l_org_id );

    x_request_id := fnd_request.submit_request
      (
       application 		=> 'CN'
       ,program     		=> x_conc_program
       ,argument1              => x_parent_proc_audit_id
       ,argument2  		       => x_process
       ,argument3 		       => x_physical_batch_id
       ,argument4               => x_start_date
      ,argument5               => x_end_date
      ,argument6               => l_org_id);

    debugmsg('Conc_Submit : x_request_id = ' || x_request_id);

    IF x_request_id = 0 THEN
       debugmsg('Loader : Conc_Submit : Submit failure for phys batch '
		|| x_physical_batch_id);
       debugmsg('Loader : Conc_Submit: ' || fnd_message.get);
       debugmsg('Loader : Conc_Submit : Submit failure for phys batch '
		|| x_physical_batch_id);
     ELSE
       cn_message_pkg.flush;
       commit; -- Commit for each concurrent program i.e. runner
    END IF;

  END conc_submit;


-- Procedure for submitting one request for each physical batch within a logical batch

PROCEDURE conc_dispatch(x_parent_proc_audit_id NUMBER,
			  x_start_date           DATE,
			  x_end_date             DATE,
			  x_logical_batch_id     NUMBER,
              x_process                VARCHAR2
			  ) IS

     TYPE requests IS TABLE of NUMBER(15) INDEX BY BINARY_INTEGER;
     TYPE batches  IS TABLE of NUMBER(15) INDEX BY BINARY_INTEGER;

     l_primary_request_stack   	REQUESTS;
     l_primary_batch_stack	BATCHES;
     l_empty_request_stack 	REQUESTS;
     l_empty_batch_stack	BATCHES;

     x_batch_total	 	NUMBER       := 0;
     l_temp_id 	 		NUMBER       := 0;
     l_temp_phys_batch_id	NUMBER;

     primary_ptr		NUMBER := 1; -- Must start at 1

     l_dev_phase    		VARCHAR2(80);
     l_dev_status   		VARCHAR2(80);
     l_request_id 		NUMBER      ;

     l_completed_batch_count 	NUMBER :=0  ;
     l_call_status		BOOLEAN     ;

     l_next_process	  	VARCHAR2(30);
     l_dummy		  	VARCHAR2(500);
     unfinished 		BOOLEAN := TRUE;

     l_user_id  		NUMBER(15) := fnd_global.user_id;
     l_resp_id  		NUMBER(15) := fnd_global.resp_id;
     l_login_id 		NUMBER(15) := fnd_global.login_id;
     l_conc_prog_id 	        NUMBER(15) := fnd_global.conc_program_id;
     l_conc_request_id 	        NUMBER(15) := fnd_global.conc_request_id;
     l_prog_appl_id 	        NUMBER(15) := fnd_global.prog_appl_id;

     x_debug number;
     debug_v number;

     conc_status boolean;

     l_sleep_time	number := 180;
     l_sleep_time_char	varchar2(30);

     -- Get individual physical batch id's for the entire logical batch
    CURSOR physical_batches IS

    SELECT distinct sca_process_batch_id
    FROM cn_sca_process_batches
    WHERE logical_batch_id = x_logical_batch_id;

    physical_rec physical_batches%ROWTYPE;

 BEGIN

    debugmsg('Conc_Dispatch : Start of Conc_Dispatch');
    debugmsg('Conc_Dispatch : Logical Batch ID = '|| x_logical_batch_id);

    WHILE unfinished LOOP
       l_primary_request_stack := l_empty_request_stack;
       l_primary_batch_stack   := l_empty_batch_stack  ;

       primary_ptr 	     := 1; -- Start at element one not element zero
       l_completed_batch_count := 0;
       x_batch_total 	     := 0;

       FOR physical_rec IN physical_batches LOOP
       	  debugmsg('Conc_Dispatch : Calling conc_submit. '
	   	   ||'physical_rec.sca_process_batch_id = '
		   || physical_rec.sca_process_batch_id );

	       debugmsg('Conc_Dispatch : call SCA_BATCH_RUNNER');

	       conc_submit(x_conc_program	      => 'SCA_BATCH_RUNNER'
		      ,x_parent_proc_audit_id     => x_parent_proc_audit_id
		      ,x_process                  => x_process
		      ,x_physical_batch_id        => physical_rec.sca_process_batch_id
		      ,x_start_date               => x_start_date
		      ,x_end_date                 => x_end_date
		      ,x_request_id               => l_temp_id);

	        debugmsg('Conc_Dispatch : done SCA_BATCH_RUNNER');

            x_batch_total := x_batch_total + 1;

            l_primary_request_stack(x_batch_total) := l_temp_id;
            l_primary_batch_stack(x_batch_total) := physical_rec.sca_process_batch_id;

        	-- If submission failed update the batch record and bail

            IF l_temp_id = 0 THEN
	           --cn_debug.print_msg('conc disp submit failed',1);
	           l_temp_phys_batch_id := physical_rec.sca_process_batch_id;
	        RAISE conc_fail;
    	    END IF;

       END LOOP;

        debugmsg('Conc_Dispatch : Total conc requests submitted : '||x_batch_total);

        debug_v := l_primary_request_stack(primary_ptr);

        l_sleep_time_char := fnd_profile.value('CN_SLEEP_TIME');

        IF l_sleep_time_char IS NOT NULL THEN
	       l_sleep_time := to_number(l_sleep_time_char);
        END IF;

        dbms_lock.sleep(l_sleep_time);

        WHILE l_completed_batch_count <= x_batch_total LOOP

         IF l_primary_request_stack(primary_ptr) IS NOT NULL THEN

             l_call_status := fnd_concurrent.get_request_status(
                        request_id     => l_primary_request_stack(primary_ptr)
                       ,phase          => l_dummy
                       ,status         => l_dummy
                       ,dev_phase      => l_dev_phase
                       ,dev_status     => l_dev_status
                       ,message        => l_dummy);

	         IF (NOT l_call_status)  THEN

                debugmsg('Conc_Dispatch : request_id is '
		          ||l_primary_request_stack(primary_ptr));
	         RAISE conc_fail;
	         END IF;

	         IF l_dev_phase = 'COMPLETE' THEN

        	     debug_v := l_primary_request_stack(primary_ptr);
	             l_temp_phys_batch_id := l_primary_batch_stack(primary_ptr);

	             l_primary_batch_stack(primary_ptr)   := null;
	             l_primary_request_stack(primary_ptr) := null;
	             l_completed_batch_count := l_completed_batch_count +1;

	             IF l_dev_status = 'ERROR' THEN
		              debugmsg('Conc_Dispatch : '
                    			 ||'Request completed with error for '
                    			 ||debug_v);
		              raise conc_fail;

                 ELSIF l_dev_status = 'NORMAL' THEN
		              x_debug := l_primary_batch_stack(primary_ptr);
	             END IF; -- If error
	         END IF; -- If complete
         END IF; -- If null ptr

         primary_ptr := primary_ptr+1;

         IF l_completed_batch_count = x_batch_total THEN

        	  -- Get out of the loop by adding 1
        	  l_completed_batch_count := l_completed_batch_count + 1;

        	  debugmsg('Conc_Dispatch :  All requests complete for '||
		         'logical process : '|| x_process);
        	  unfinished := FALSE;

       	ELSE
          -- Made a complete pass through the srp_periods in this physical
          -- batch and some conc requests have not completed.
          -- Give the conc requests a few minutes to run before
          -- checking their status
	           IF primary_ptr > x_batch_total THEN
	               dbms_lock.sleep(l_sleep_time);
	               primary_ptr := 1;
               END IF;
        END IF;
     END LOOP;
   END LOOP;
 EXCEPTION
    WHEN no_data_found THEN
       debugmsg('Conc_Dispatch : no rows for process '
		||x_process);
       -- conc_status := fnd_concurrent.set_completion_status(
		--	status 	=> 'ERROR',
        --                message => '');
       -- cn_message_pkg.end_batch(x_parent_proc_audit_id);
    WHEN conc_fail THEN
       -- update_error(l_temp_phys_batch_id);
       debugmsg('Conc_Dispatch : Exception conc_fail');
       -- cn_message_pkg.end_batch(x_parent_proc_audit_id);
       conc_status := fnd_concurrent.set_completion_status(
			status 	=> 'ERROR',
                        message => '');
       RAISE;
    WHEN OTHERS THEN
       debugmsg('Conc_Dispatch : Unexpected Exception');
       RAISE;
 END conc_dispatch;


PROCEDURE ASSIGN(p_logical_batch_id NUMBER,
                 p_start_date	DATE,
		 p_end_date	DATE,
		 batch_type		VARCHAR2,
		 p_org_id    NUMBER,
		 x_size OUT NOCOPY NUMBER) IS


   l_sql_stmt		VARCHAR2(10000);
   l_sql_stmt_count		VARCHAR2(10000);
   l_sql_stmt_id		VARCHAR2(10000);
   l_sql_stmt_divider		VARCHAR2(10000);
   l_sql_stmt_resource		VARCHAR2(10000);
   l_no_trx                 BOOLEAN;
   l_sca_process_batch_id   cn_sca_process_batches.sca_process_batch_id%TYPE;

    TYPE rc IS REF CURSOR;
    TYPE divider_type IS TABLE OF NUMBER;

    query_cur         	rc;
    i NUMBER;
    l_header_rec    cn_comm_lines_api%ROWTYPE;
    l_lines_output_id   cn_sca_lines_output.sca_lines_output_id%TYPE;
    l_header_interface_id   cn_sca_headers_interface.sca_headers_interface_id%TYPE;
    l_comm_lines_api_id     cn_comm_lines_api.comm_lines_api_id%TYPE;
    l_source_id             cn_sca_headers_interface.source_id%TYPE;
    l_order_number          cn_comm_lines_api.order_number%TYPE;
    l_invoice_number        cn_comm_lines_api.invoice_number%TYPE;
    l_id                    cn_sca_process_batches.start_id%TYPE;

    l_logical_batch_size   NUMBER;
    l_worker_num           NUMBER;
    l_physical_batch_size   NUMBER;
    l_divider_size          NUMBER;
    divider                 divider_type := divider_type();
    loop_count              NUMBER;
    l_start_id              cn_sca_process_batches.start_id%TYPE;
    l_end_id                cn_sca_process_batches.end_id%TYPE;

    l_user_id  		NUMBER(15) := fnd_global.user_id;
    l_login_id 		NUMBER(15) := fnd_global.login_id;

BEGIN

    debugmsg(batch_type || ': Assign : Start ');
    debugmsg(batch_type || ': Assign : Start Date = ' || p_start_date);
    debugmsg(batch_type || ': Assign : End Date = ' || p_end_date);

    -- Get the number of transactions that needs to be processed, i.e. the logical batch size

    if (batch_type = 'SCA_ORD') then

        l_sql_stmt_count :=

		      'select count(distinct(source_id)) from cn_sca_headers_interface ';

        l_sql_stmt :=

		      'where trunc(processed_date) between trunc(:p_start_date) and trunc(:p_end_date) ' ||
		      'and ((transaction_status is null) or (transaction_status not in ''ADJUSTED'')) ' ||
              'and source_type = :p_source_type ' ||
              'order by source_id asc ';


    	l_sql_stmt_count := l_sql_stmt_count || l_sql_stmt;

    end if;

    if (batch_type = 'SCA_INV') then

        l_sql_stmt_count :=

              'select count(distinct(source_id)) from cn_sca_headers_interface ';

        l_sql_stmt :=

              'where trunc(processed_date) between trunc(:p_start_date) and trunc(:p_end_date) ' ||
		      'and ((transaction_status is null) or (transaction_status not in ''ADJUSTED'')) ' ||
              'and source_type = :p_source_type ' ||
              'order by source_id asc ';

	    l_sql_stmt_count := l_sql_stmt_count || l_sql_stmt;

    end if;


    if (batch_type = 'ORD') then

	   l_sql_stmt_count :=

        	   'select count(distinct(order_number)) from cn_comm_lines_api ';

       l_sql_stmt :=

               'where trunc(processed_date) between trunc(:p_start_date) and trunc(:p_end_date) ' ||
		       'and load_status = ''UNLOADED'' ' ||
		       'and ( --(adjust_status is null) or
 (adjust_status not in (''SCA_PENDING'', ''SCA_ALLOCATED'', ''SCA_NO_RULE'', ''SCA_NOT_ALLOCATED'', ' ||
               '''SCA_NOT_ELIGIBLE'', ''REVERSAL'', ''FROZEN''))) ' ||
               'and ((trx_type = ''ORD'') or (trx_type = ''MAN''))' ||
               'and order_number is not null ' ||
               'and line_number is not null ' ||
               'and invoice_number is null ' ||
               'order by order_number asc ';

	   l_sql_stmt_count := l_sql_stmt_count || l_sql_stmt;

       /*dbms_output.put_line(substr(l_sql_stmt_count, 1, 100));
       dbms_output.put_line(substr(l_sql_stmt_count, 101, 150));
       dbms_output.put_line(substr(l_sql_stmt_count, 151, 200));
       dbms_output.put_line(substr(l_sql_stmt_count, 201, 250));
       dbms_output.put_line(' ');
*/
    end if;

    if (batch_type = 'INV') then

        l_sql_stmt_count :=

                'select count(distinct(invoice_number)) from cn_comm_lines_api ';

        l_sql_stmt :=

    		    'where trunc(processed_date) between trunc(:p_start_date) and trunc(:p_end_date) ' ||
        		'and load_status = ''UNLOADED'' ' ||
        		'and (--(adjust_status is null) or
(adjust_status not in (''SCA_PENDING'', ''SCA_ALLOCATED'', ''SCA_NO_RULE'', ''SCA_NOT_ALLOCATED'', ' ||
                '''SCA_NOT_ELIGIBLE'', ''REVERSAL'', ''FROZEN''))) ' ||
                'and ((trx_type = ''INV'') or (trx_type = ''MAN''))' ||
                'and invoice_number is not null ' ||
                'and line_number is not null ' ||
                'order by invoice_number asc ';

        l_sql_stmt_count := l_sql_stmt_count || l_sql_stmt;

    end if;

    if (batch_type = 'CSHI') then

        l_sql_stmt_count :=

                'select count(1) from cn_sca_headers_interface CSHI, cn_sca_lines_interface CSLI ';

    	l_sql_stmt :=

        		'where trunc(CSHI.processed_date) between trunc(:p_start_date) and trunc(:p_end_date) ' ||
    	   	    'and CSHI.process_status <> ''SCA_UNPROCESSED'' ' ||
                'and CSHI.transaction_status = ''SCA_UNPROCESSED'' ' ||
    	       	'and CSHI.sca_headers_interface_id = CSLI.sca_headers_interface_id ' ||
                'order by CSLI.sca_lines_interface_id ';

        l_sql_stmt_count := l_sql_stmt_count || l_sql_stmt;

    end if;

    if (batch_type = 'CSLO') then

  	    l_sql_stmt_count :=

                'select count(1) from cn_sca_headers_interface CSHI, cn_sca_lines_output CSLO ';

     	l_sql_stmt :=

        		'where trunc(CSHI.processed_date) between trunc(:p_start_date) and trunc(:p_end_date) ' ||
                'and CSHI.sca_headers_interface_id = CSLO.sca_headers_interface_id ' ||
    	       	'and CSHI.process_status <> ''SCA_UNPROCESSED'' ' ||
                'and CSHI.transaction_status = ''SCA_UNPROCESSED'' ' ||
                'order by CSLO.sca_lines_output_id ' ;

        l_sql_stmt_count := l_sql_stmt_count || l_sql_stmt;

    end if;

    if (batch_type = 'SCA_ORD') then

	OPEN query_cur FOR l_sql_stmt_count
	USING
	        p_start_date,
	    	p_end_date,
                'ORD';

    elsif (batch_type = 'SCA_INV')  then

	OPEN query_cur FOR l_sql_stmt_count
	USING
	        p_start_date,
	    	  p_end_date,
                'INV';

    else

	OPEN query_cur FOR l_sql_stmt_count
	USING
	        p_start_date,
	    	p_end_date;

    end if;

    FETCH query_cur INTO l_logical_batch_size;
    x_size := l_logical_batch_size;

    l_worker_num := NVL(fnd_profile.value('CN_NUMBER_OF_WORKERS'), 1);

    if (l_worker_num < 1) then

        l_worker_num := 1;

    end if;

    debugmsg(batch_type || ': Assign : Logical Batch Size = ' || to_char(l_logical_batch_size));
    debugmsg(batch_type || ': Assign : Number of Workers = ' || to_char(l_worker_num));

    -- calculate the minimas and maximas of the physical batches

    if (l_logical_batch_size > l_worker_num) then
        l_physical_batch_size := floor(l_logical_batch_size/l_worker_num);
        l_divider_size := l_worker_num * 2;

        divider.EXTEND;
        divider(1):= 1;
        divider.EXTEND;
        divider(2):= divider(1) + l_physical_batch_size - 1;

        debugmsg(batch_type || ': Assign : Minima1 = ' || to_char(divider(1)));
        debugmsg(batch_type || ': Assign : Maxima1 = ' || to_char(divider(2)));

        for counter in 2..l_worker_num  LOOP

            divider.EXTEND;
            divider(2*counter-1) := divider(2*counter-2) + 1;
            divider.EXTEND;
            divider(2*counter) := divider(2*counter-1) + l_physical_batch_size - 1;

            debugmsg(batch_type || ': Assign : Minima' || counter || ' = ' || to_char(divider(2*counter-1)));

            if (counter <> l_worker_num) then
                debugmsg(batch_type || ': Assign : Maxima' || counter || ' = ' || to_char(divider(2*counter)));
            end if;

        END LOOP;

        divider(l_divider_size) := l_logical_batch_size;
        debugmsg(batch_type || ': Assign : Maxima' || l_worker_num || ' = ' || to_char(divider(l_divider_size)));

    else

	l_physical_batch_size := 0;

        for counter in 1..l_logical_batch_size LOOP

            divider.EXTEND;
            divider(2*counter-1) := counter;
            divider.EXTEND;
            divider(2*counter) := counter;

            debugmsg(batch_type || ': Assign : Minima' || counter || ' = ' || to_char(divider(2*counter-1)));
            debugmsg(batch_type || ': Assign : Maxima' || counter || ' = ' || to_char(divider(2*counter)));

         END LOOP;

    end if;

    if (divider.count = 0) then

        l_no_trx := true;
        RAISE no_trx;

    else

        l_no_trx := false;
        l_sql_stmt_divider :=
            '(''' || divider(divider.FIRST) || '''';

        i := divider.NEXT(divider.FIRST);

        while i IS NOT NULL LOOP

		    l_sql_stmt_divider := l_sql_stmt_divider || ', ''' || divider(i) || '''';
		    i := divider.NEXT(i);

	    END LOOP;

	    l_sql_stmt_divider := l_sql_stmt_divider || ')';

    end if;

    if (not l_no_trx) then

    if ((batch_type = 'SCA_ORD') or (batch_type = 'SCA_INV')) then

        l_sql_stmt_id :=
	       	'select distinct(source_id) from cn_sca_headers_interface ';

        l_sql_stmt_id := l_sql_stmt_id || l_sql_stmt;

        l_sql_stmt_id :=

            'select source_id from ' ||
            '(select rownum row_number, source_id from ' ||
		    '(' || l_sql_stmt_id || ')) sca_table ' ||
            'where sca_table.row_number in ' ||
            l_sql_stmt_divider;

    end if;

     if (batch_type = 'ORD') then

       l_sql_stmt_id := 'select distinct(order_number) from cn_comm_lines_api ';
       l_sql_stmt_id := l_sql_stmt_id || l_sql_stmt;

       l_sql_stmt_id :=

            'select order_number from ' ||
            '(select rownum row_number, order_number from ' ||
		    '(' || l_sql_stmt_id || ')) api_ord_table ' ||
            'where api_ord_table.row_number in ' ||
            l_sql_stmt_divider;

    end if;

    if (batch_type = 'INV') then

       l_sql_stmt_id := 'select distinct(invoice_number) from cn_comm_lines_api ';
       l_sql_stmt_id := l_sql_stmt_id || l_sql_stmt;

       l_sql_stmt_id :=

            'select invoice_number from ' ||
            '(select rownum row_number, invoice_number from ' ||
		    '(' || l_sql_stmt_id || ')) api_inv_table ' ||
            'where api_inv_table.row_number in ' ||
            l_sql_stmt_divider;

    END IF;

    if (batch_type = 'CSHI') then

        l_sql_stmt_id := 'select CSLI.sca_lines_interface_id from cn_sca_headers_interface CSHI, cn_sca_lines_interface CSLI ';
        l_sql_stmt_id := l_sql_stmt_id || l_sql_stmt;

        l_sql_stmt_id :=

            'select sca_lines_interface_id from ' ||
            '(select rownum row_number, sca_lines_interface_id from ' ||
		    '(' || l_sql_stmt_id || ')) sca_lines_table ' ||
            'where sca_lines_table.row_number in '||
            l_sql_stmt_divider;

    end if;

    if (batch_type = 'CSLO') then

        l_sql_stmt_id := 'select CSLO.sca_lines_output_id from cn_sca_headers_interface CSHI, cn_sca_lines_output CSLO ';
        l_sql_stmt_id := l_sql_stmt_id || l_sql_stmt;

        l_sql_stmt_id :=

            'select sca_lines_output_id from ' ||
            '(select rownum row_number, sca_lines_output_id from ' ||
		    '(' || l_sql_stmt_id || ')) sca_output_table ' ||
            'where sca_output_table.row_number in ' ||
            l_sql_stmt_divider;

    end if;

    if (batch_type = 'SCA_ORD') then

	OPEN query_cur FOR l_sql_stmt_id
	USING
	        p_start_date,
	    	p_end_date,
                'ORD';

    elsif (batch_type = 'SCA_INV')  then

	OPEN query_cur FOR l_sql_stmt_id
	USING
	        p_start_date,
	    	p_end_date,
                'INV';

    else

	OPEN query_cur FOR l_sql_stmt_id
	USING
	        p_start_date,
	    	p_end_date;

    end if;

    loop_count := 1;

    debugmsg(batch_type || ': Assign : Insert into CN_SCA_PROCESS_BATCHES ');

   if (l_physical_batch_size >= 2) then

	LOOP
        	FETCH query_cur INTO l_id;
        	EXIT WHEN query_cur%NOTFOUND;

        	if ((loop_count mod 2) = 1) then
            		l_start_id := l_id;
        	end if;

        	if ((loop_count mod 2) = 0) then
            		l_end_id := l_id;

            	SELECT cn_sca_process_batches_s.NEXTVAL
            	INTO l_sca_process_batch_id
            	FROM sys.dual;

            	insert into CN_SCA_PROCESS_BATCHES
                (   sca_process_batch_id,
                    start_id,
                    end_id,
                    type,
                    logical_batch_id,
                    creation_date,
                    created_by,
		    last_update_date,
		    last_updated_by,
		    last_update_login,
		    org_id)
		  values
                    ( l_sca_process_batch_id,
                      l_start_id,
                      l_end_id,
                      batch_type,
                      p_logical_batch_id,
                      sysdate,
           	          l_user_id,
                      sysdate,
	                  l_user_id,
		  l_login_id,
		    p_org_id);

                debugmsg(batch_type || ': Assign : sca_process_batch_id = ' || to_char(l_sca_process_batch_id));
                debugmsg(batch_type || ': Assign : start_id = ' || l_start_id);
                debugmsg(batch_type || ': Assign : end_id = ' || l_end_id);
                debugmsg(batch_type || ': Assign : logical_batch_id = ' || to_char(p_logical_batch_id));
                debugmsg(batch_type || ': Assign : batch_type = ' || batch_type);

        	end if;

		loop_count := loop_count + 1;

    	END LOOP;

    else

	LOOP
        	FETCH query_cur INTO l_id;
        	EXIT WHEN query_cur%NOTFOUND;

        	if (loop_count = l_worker_num and l_physical_batch_size = 1) then
            		l_start_id := l_id;
        	end if;

        	if (loop_count > l_worker_num and l_physical_batch_size = 1) then
            		l_end_id := l_id;

            		SELECT cn_sca_process_batches_s.NEXTVAL
            		INTO l_sca_process_batch_id
            		FROM sys.dual;

            		insert into CN_SCA_PROCESS_BATCHES
                	(   sca_process_batch_id,
                    	    start_id,
                    	    end_id,
                    	    type,
                    	    logical_batch_id,
                    	    creation_date,
                    	    created_by,
		    	    last_update_date,
		    	    last_updated_by,
			  last_update_login,
			org_id)
                	values
                    	( l_sca_process_batch_id,
                      	  l_start_id,
                      	  l_end_id,
                      	  batch_type,
                      	  p_logical_batch_id,
                      	  sysdate,
           	          l_user_id,
                      	  sysdate,
	                  l_user_id,
			  l_login_id,
			p_org_id);

                	debugmsg(batch_type || ': Assign : sca_process_batch_id = ' || to_char(l_sca_process_batch_id));
                	debugmsg(batch_type || ': Assign : start_id = ' || l_start_id);
                	debugmsg(batch_type || ': Assign : end_id = ' || l_end_id);
                	debugmsg(batch_type || ': Assign : logical_batch_id = ' || to_char(p_logical_batch_id));
                	debugmsg(batch_type || ': Assign : batch_type = ' || batch_type);

        	end if;


		if (loop_count < l_worker_num or (loop_count = l_worker_num and l_physical_batch_size < 1)) then

			SELECT cn_sca_process_batches_s.NEXTVAL
            		INTO l_sca_process_batch_id
            		FROM sys.dual;

            		insert into CN_SCA_PROCESS_BATCHES
                	(   sca_process_batch_id,
                    	    start_id,
                    	    end_id,
                    	    type,
                    	    logical_batch_id,
                    	    creation_date,
                    	    created_by,
		    	    last_update_date,
		    	    last_updated_by,
			  last_update_login,
			org_id)
                	values
                    	( l_sca_process_batch_id,
                      	  l_id,
                      	  l_id,
                      	  batch_type,
                      	  p_logical_batch_id,
                      	  sysdate,
           	          l_user_id,
                      	  sysdate,
	                  l_user_id,
			  l_login_id,
			p_org_id);

                	debugmsg(batch_type || ': Assign : sca_process_batch_id = ' || to_char(l_sca_process_batch_id));
                	debugmsg(batch_type || ': Assign : start_id = ' || l_id);
                	debugmsg(batch_type || ': Assign : end_id = ' || l_id);
                	debugmsg(batch_type || ': Assign : logical_batch_id = ' || to_char(p_logical_batch_id));
                	debugmsg(batch_type || ': Assign : batch_type = ' || batch_type);

        	end if;

		loop_count := loop_count + 1;

    	END LOOP;

    end if;

    end if;

    EXCEPTION
    WHEN no_trx THEN
      debugmsg(batch_type || ': Assign : No transactions to process ');

    WHEN OTHERS THEN
       debugmsg(batch_type || ': Assign : Unexpected Exception');
       RAISE;

 END assign;

PROCEDURE create_trx (
            p_start_date    DATE,
            p_end_date      DATE,
            p_physical_batch_id     NUMBER) IS

        l_start_id    cn_sca_process_batches.start_id%TYPE;
        l_end_id      cn_sca_process_batches.end_id%TYPE;
        l_adjusted_by                  VARCHAR2(30);
        conc_status BOOLEAN;

        CURSOR sca_lines_cur (start_id VARCHAR2, end_id VARCHAR2) IS

            select CSLO.sca_lines_output_id from cn_sca_headers_interface CSHI, cn_sca_lines_output CSLO
            where CSLO.sca_headers_interface_id = CSHI.sca_headers_interface_id
            and trunc(CSHI.processed_date) between trunc(p_start_date) and trunc(p_end_date)
            and CSHI.process_status <> 'SCA_UNPROCESSED'
            and CSHI.transaction_status = 'SCA_UNPROCESSED'
            and CSLO.sca_lines_output_id between start_id and end_id;

        TYPE sca_lines_tbl IS TABLE OF cn_sca_lines_output.sca_lines_output_id%TYPE;
        sca_lines sca_lines_tbl;

BEGIN

    select start_id, end_id into
           l_start_id, l_end_id
    from cn_sca_process_batches
    where sca_process_batch_id = p_physical_batch_id;

    debugmsg('Populate results back to API: Creating Transactions ');
    debugmsg('Populate results back to API: Start ID = ' || l_start_id);
    debugmsg('Populate results back to API: End ID = ' || l_end_id);

    l_adjusted_by := get_adjusted_by;

    OPEN    sca_lines_cur (l_start_id, l_end_id);
    FETCH   sca_lines_cur BULK COLLECT INTO sca_lines limit 1000;

    FORALL j IN 1..sca_lines.COUNT

    INSERT into CN_COMM_LINES_API
      ( SALESREP_ID,
        PROCESSED_DATE,
        PROCESSED_PERIOD_ID,
        TRANSACTION_AMOUNT,
        TRX_TYPE,
        REVENUE_CLASS_ID,
        LOAD_STATUS,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        ATTRIBUTE16,
        ATTRIBUTE17,
        ATTRIBUTE18,
        ATTRIBUTE19,
        ATTRIBUTE20,
        ATTRIBUTE21,
        ATTRIBUTE22,
        ATTRIBUTE23,
        ATTRIBUTE24,
        ATTRIBUTE25,
        ATTRIBUTE26,
        ATTRIBUTE27,
        ATTRIBUTE28,
        ATTRIBUTE29,
        ATTRIBUTE30,
        ATTRIBUTE31,
        ATTRIBUTE32,
        ATTRIBUTE33,
        ATTRIBUTE34,
        ATTRIBUTE35,
        ATTRIBUTE36,
        ATTRIBUTE37,
        ATTRIBUTE38,
        ATTRIBUTE39,
        ATTRIBUTE40,
        ATTRIBUTE41,
        ATTRIBUTE42,
        ATTRIBUTE43,
        ATTRIBUTE44,
        ATTRIBUTE45,
        ATTRIBUTE46,
        ATTRIBUTE47,
        ATTRIBUTE48,
        ATTRIBUTE49,
        ATTRIBUTE50,
        ATTRIBUTE51,
        ATTRIBUTE52,
        ATTRIBUTE53,
        ATTRIBUTE54,
        ATTRIBUTE55,
        ATTRIBUTE56,
        ATTRIBUTE57,
        ATTRIBUTE58,
        ATTRIBUTE59,
        ATTRIBUTE60,
        ATTRIBUTE61,
        ATTRIBUTE62,
        ATTRIBUTE63,
        ATTRIBUTE64,
        ATTRIBUTE65,
        ATTRIBUTE66,
        ATTRIBUTE67,
        ATTRIBUTE68,
        ATTRIBUTE69,
        ATTRIBUTE70,
        ATTRIBUTE71,
        ATTRIBUTE72,
        ATTRIBUTE73,
        ATTRIBUTE74,
        ATTRIBUTE75,
        ATTRIBUTE76,
        ATTRIBUTE77,
        ATTRIBUTE78,
        ATTRIBUTE79,
        ATTRIBUTE80,
        ATTRIBUTE81,
        ATTRIBUTE82,
        ATTRIBUTE83,
        ATTRIBUTE84,
        ATTRIBUTE85,
        ATTRIBUTE86,
        ATTRIBUTE87,
        ATTRIBUTE88,
        ATTRIBUTE89,
        ATTRIBUTE90,
        ATTRIBUTE91,
        ATTRIBUTE92,
        ATTRIBUTE93,
        ATTRIBUTE94,
        ATTRIBUTE95,
        ATTRIBUTE96,
        ATTRIBUTE97,
        ATTRIBUTE98,
        ATTRIBUTE99,
        ATTRIBUTE100,
        COMM_LINES_API_ID,
        CONC_BATCH_ID,
        PROCESS_BATCH_ID,
        SALESREP_NUMBER,
        ROLLUP_DATE,
        SOURCE_DOC_ID,
        SOURCE_DOC_TYPE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        TRANSACTION_CURRENCY_CODE,
        EXCHANGE_RATE,
        ACCTD_TRANSACTION_AMOUNT,
        TRX_ID,
        TRX_LINE_ID,
        TRX_SALES_LINE_ID,
        QUANTITY,
        SOURCE_TRX_NUMBER,
        DISCOUNT_PERCENTAGE,
        MARGIN_PERCENTAGE,
        SOURCE_TRX_ID,
        SOURCE_TRX_LINE_ID,
        SOURCE_TRX_SALES_LINE_ID,
        NEGATED_FLAG,
        CUSTOMER_ID,
        INVENTORY_ITEM_ID,
        ORDER_NUMBER,
        BOOKED_DATE,
        INVOICE_NUMBER,
        INVOICE_DATE,
        ADJUST_DATE,
        ADJUSTED_BY,
        REVENUE_TYPE,
        ADJUST_ROLLUP_FLAG,
        ADJUST_COMMENTS,
        ADJUST_STATUS,
        LINE_NUMBER,
        BILL_TO_ADDRESS_ID,
        SHIP_TO_ADDRESS_ID,
        BILL_TO_CONTACT_ID,
        SHIP_TO_CONTACT_ID,
        ADJ_COMM_LINES_API_ID,
        PRE_DEFINED_RC_FLAG,
        ROLLUP_FLAG,
        FORECAST_ID,
        UPSIDE_QUANTITY,
        UPSIDE_AMOUNT,
        UOM_CODE,
        REASON_CODE,
        TYPE,
        PRE_PROCESSED_CODE,
        QUOTA_ID,
        SRP_PLAN_ASSIGN_ID,
        ROLE_ID,
        COMP_GROUP_ID,
        COMMISSION_AMOUNT,
        EMPLOYEE_NUMBER,
        REVERSAL_FLAG,
        REVERSAL_HEADER_ID,
        SALES_CHANNEL,
        OBJECT_VERSION_NUMBER,
        SPLIT_PCT,
      SPLIT_status,
      ORG_ID)

    (select
        CS.SALESREP_ID,
        CCLA.PROCESSED_DATE,
        CCLA.PROCESSED_PERIOD_ID,
        (CSLO.allocation_percentage/100) * NVL(CSHI.transaction_amount, 0),
        CCLA.TRX_TYPE,
        CCLA.REVENUE_CLASS_ID,
        'UNLOADED',
        CCLA.ATTRIBUTE_CATEGORY,
        CCLA.ATTRIBUTE1,
        CCLA.ATTRIBUTE2,
        CCLA.ATTRIBUTE3,
        CCLA.ATTRIBUTE4,
        CCLA.ATTRIBUTE5,
        CCLA.ATTRIBUTE6,
        CCLA.ATTRIBUTE7,
        CCLA.ATTRIBUTE8,
        CCLA.ATTRIBUTE9,
        CCLA.ATTRIBUTE10,
        CCLA.ATTRIBUTE11,
        CCLA.ATTRIBUTE12,
        CCLA.ATTRIBUTE13,
        CCLA.ATTRIBUTE14,
        CCLA.ATTRIBUTE15,
        CCLA.ATTRIBUTE16,
        CCLA.ATTRIBUTE17,
        CCLA.ATTRIBUTE18,
        CCLA.ATTRIBUTE19,
        CCLA.ATTRIBUTE20,
        CCLA.ATTRIBUTE21,
        CCLA.ATTRIBUTE22,
        CCLA.ATTRIBUTE23,
        CCLA.ATTRIBUTE24,
        CCLA.ATTRIBUTE25,
        CCLA.ATTRIBUTE26,
        CCLA.ATTRIBUTE27,
        CCLA.ATTRIBUTE28,
        CCLA.ATTRIBUTE29,
        CCLA.ATTRIBUTE30,
        CCLA.ATTRIBUTE31,
        CCLA.ATTRIBUTE32,
        CCLA.ATTRIBUTE33,
        CCLA.ATTRIBUTE34,
        CCLA.ATTRIBUTE35,
        CCLA.ATTRIBUTE36,
        CCLA.ATTRIBUTE37,
        CCLA.ATTRIBUTE38,
        CCLA.ATTRIBUTE39,
        CCLA.ATTRIBUTE40,
        CCLA.ATTRIBUTE41,
        CCLA.ATTRIBUTE42,
        CCLA.ATTRIBUTE43,
        CCLA.ATTRIBUTE44,
        CCLA.ATTRIBUTE45,
        CCLA.ATTRIBUTE46,
        CCLA.ATTRIBUTE47,
        CCLA.ATTRIBUTE48,
        CCLA.ATTRIBUTE49,
        CCLA.ATTRIBUTE50,
        CCLA.ATTRIBUTE51,
        CCLA.ATTRIBUTE52,
        CCLA.ATTRIBUTE53,
        CCLA.ATTRIBUTE54,
        CCLA.ATTRIBUTE55,
        CCLA.ATTRIBUTE56,
        CCLA.ATTRIBUTE57,
        CCLA.ATTRIBUTE58,
        CCLA.ATTRIBUTE59,
        CCLA.ATTRIBUTE60,
        CCLA.ATTRIBUTE61,
        CCLA.ATTRIBUTE62,
        CCLA.ATTRIBUTE63,
        CCLA.ATTRIBUTE64,
        CCLA.ATTRIBUTE65,
        CCLA.ATTRIBUTE66,
        CCLA.ATTRIBUTE67,
        CCLA.ATTRIBUTE68,
        CCLA.ATTRIBUTE69,
        CCLA.ATTRIBUTE70,
        CCLA.ATTRIBUTE71,
        CCLA.ATTRIBUTE72,
        CCLA.ATTRIBUTE73,
        CCLA.ATTRIBUTE74,
        CCLA.ATTRIBUTE75,
        CCLA.ATTRIBUTE76,
        CCLA.ATTRIBUTE77,
        CCLA.ATTRIBUTE78,
        CCLA.ATTRIBUTE79,
        CCLA.ATTRIBUTE80,
        CCLA.ATTRIBUTE81,
        CCLA.ATTRIBUTE82,
        CCLA.ATTRIBUTE83,
        CCLA.ATTRIBUTE84,
        CCLA.ATTRIBUTE85,
        CCLA.ATTRIBUTE86,
        CCLA.ATTRIBUTE87,
        CCLA.ATTRIBUTE88,
        CCLA.ATTRIBUTE89,
        CCLA.ATTRIBUTE90,
        CCLA.ATTRIBUTE91,
        CCLA.ATTRIBUTE92,
        CCLA.ATTRIBUTE93,
        CCLA.ATTRIBUTE94,
        CCLA.ATTRIBUTE95,
        CCLA.ATTRIBUTE96,
        CCLA.ATTRIBUTE97,
        CCLA.ATTRIBUTE98,
        CCLA.ATTRIBUTE99,
        CCLA.ATTRIBUTE100,
        cn_comm_lines_api_s.NEXTVAL,
        CCLA.CONC_BATCH_ID,
        CCLA.PROCESS_BATCH_ID,
        NULL,
        CCLA.ROLLUP_DATE,
        CCLA.SOURCE_DOC_ID,
        CCLA.SOURCE_DOC_TYPE,
        fnd_global.user_id,
        Sysdate,
        fnd_global.user_id,
        Sysdate,
        fnd_global.login_id,
        CCLA.TRANSACTION_CURRENCY_CODE,
        CCLA.EXCHANGE_RATE,
        NULL,
        CCLA.TRX_ID,
        CCLA.TRX_LINE_ID,
        CCLA.TRX_SALES_LINE_ID,
        CCLA.QUANTITY,
        CCLA.SOURCE_TRX_NUMBER,
        CCLA.DISCOUNT_PERCENTAGE,
        CCLA.MARGIN_PERCENTAGE,
        CCLA.SOURCE_TRX_ID,
        CCLA.SOURCE_TRX_LINE_ID,
        CCLA.SOURCE_TRX_SALES_LINE_ID,
        CCLA.NEGATED_FLAG,
        CCLA.CUSTOMER_ID,
        CCLA.INVENTORY_ITEM_ID,
        CCLA.ORDER_NUMBER,
        CCLA.BOOKED_DATE,
        CCLA.INVOICE_NUMBER,
        CCLA.INVOICE_DATE,
        SYSDATE,
        l_adjusted_by,
        CSLO.REVENUE_TYPE,
        CCLA.ADJUST_ROLLUP_FLAG,
        'Created by SCA',
        'SCA_ALLOCATED',
        CCLA.LINE_NUMBER,
        CCLA.BILL_TO_ADDRESS_ID,
        CCLA.SHIP_TO_ADDRESS_ID,
        CCLA.BILL_TO_CONTACT_ID,
        CCLA.SHIP_TO_CONTACT_ID,
        CSLO.SOURCE_TRX_ID,
        CCLA.PRE_DEFINED_RC_FLAG,
        CCLA.ROLLUP_FLAG,
        CCLA.FORECAST_ID,
        CCLA.UPSIDE_QUANTITY,
        CCLA.UPSIDE_AMOUNT,
        CCLA.UOM_CODE,
        CCLA.REASON_CODE,
        CCLA.TYPE,
        CCLA.PRE_PROCESSED_CODE,
        CCLA.QUOTA_ID,
        CCLA.SRP_PLAN_ASSIGN_ID,
        CSLO.ROLE_ID,
        CCLA.COMP_GROUP_ID,
        CCLA.COMMISSION_AMOUNT,
        CS.EMPLOYEE_NUMBER,
        CCLA.REVERSAL_FLAG,
        CCLA.REVERSAL_HEADER_ID,
        CCLA.SALES_CHANNEL,
        CCLA.OBJECT_VERSION_NUMBER,
        CCLA.SPLIT_PCT,
        CCLA.SPLIT_status,
        ccla.org_id
      from
        cn_sca_lines_output CSLO, cn_salesreps CS, cn_comm_lines_api CCLA, cn_sca_headers_interface CSHI
      where CS.resource_id = CSLO.resource_id -- added org_id join, since one resource can belong to more than one org
      and cslo.org_id = cs.org_id
      and ccla.org_id = cslo.org_id
      and CCLA.comm_lines_api_id = CSLO.source_trx_id
      and CSHI.sca_headers_interface_id = CSLO.sca_headers_interface_id
      and CSLO.sca_lines_output_id = sca_lines(j));

    debugmsg('Populate results back to API: Done with Creating Transactions ');

    EXCEPTION

        WHEN OTHERS THEN

        debugmsg('Populate results back to API : Unexpected exception');
        debugmsg('Populate results back to API : Done with Creating Transactions ');

        conc_status := fnd_concurrent.set_completion_status(
			status 	=> 'ERROR',
            message => '');

	    RAISE;

END create_trx;

PROCEDURE negate_trx (
            p_start_date    DATE,
            p_end_date      DATE,
            p_physical_batch_id     NUMBER) IS

        CURSOR sca_lines_cur (start_id VARCHAR2, end_id VARCHAR2) IS

           select CSLI.source_trx_id from cn_sca_headers_interface CSHI, cn_sca_lines_interface CSLI
           where trunc(CSHI.processed_date) between trunc(p_start_date) and trunc(p_end_date)
	   	   and CSHI.process_status <> 'SCA_UNPROCESSED'
           and CSHI.transaction_status = 'SCA_UNPROCESSED'
	       and CSHI.sca_headers_interface_id = CSLI.sca_headers_interface_id
           and CSLI.sca_lines_interface_id between start_id and end_id;

        CURSOR sca_no_rule_lines_cur (start_id VARCHAR2, end_id VARCHAR2) IS

            select CSLI.source_trx_id from cn_sca_headers_interface CSHI, cn_sca_lines_interface CSLI
            where trunc(CSHI.processed_date) between trunc(p_start_date) and trunc(p_end_date)
            and CSHI.process_status = 'NO RULE'
            and CSHI.transaction_status = 'SCA_UNPROCESSED'
            and CSHI.sca_headers_interface_id = CSLI.sca_headers_interface_id
            and CSLI.sca_lines_interface_id between start_id and end_id;

	CURSOR sca_not_allocate_lines_cur (start_id VARCHAR2, end_id VARCHAR2) IS

            select CSLI.source_trx_id from cn_sca_headers_interface CSHI, cn_sca_lines_interface CSLI
            where trunc(CSHI.processed_date) between trunc(p_start_date) and trunc(p_end_date)
            and CSHI.process_status = 'NOT ALLOCATED'
            and CSHI.transaction_status = 'SCA_UNPROCESSED'
            and CSHI.sca_headers_interface_id = CSLI.sca_headers_interface_id
            and CSLI.sca_lines_interface_id between start_id and end_id;

        TYPE sca_lines_tbl IS TABLE OF cn_sca_lines_interface.source_trx_id%TYPE;
        TYPE sca_no_rule_lines_tbl IS TABLE OF cn_sca_lines_interface.source_trx_id%TYPE;
 	TYPE sca_not_allocate_lines_tbl IS TABLE OF cn_sca_lines_interface.source_trx_id%TYPE;

        sca_lines sca_lines_tbl;
        sca_no_rule_lines sca_no_rule_lines_tbl;
	sca_not_allocate_lines sca_not_allocate_lines_tbl;

        l_start_id    cn_sca_process_batches.start_id%TYPE;
        l_end_id      cn_sca_process_batches.end_id%TYPE;

        l_adjusted_by   VARCHAR2(30);
        conc_status BOOLEAN;

BEGIN

    l_adjusted_by := get_adjusted_by;

    select start_id, end_id into
           l_start_id, l_end_id
    from cn_sca_process_batches
    where sca_process_batch_id = p_physical_batch_id;

    debugmsg('Populate results back to API: Negating Transactions ');
    debugmsg('Populate results back to API: Start ID = ' || l_start_id);
    debugmsg('Populate results back to API: End ID = ' || l_end_id);

    OPEN sca_lines_cur (l_start_id, l_end_id);
    FETCH   sca_lines_cur BULK COLLECT INTO sca_lines limit 1000;

    OPEN    sca_no_rule_lines_cur (l_start_id, l_end_id);
    FETCH   sca_no_rule_lines_cur BULK COLLECT INTO sca_no_rule_lines limit 1000;

    OPEN    sca_not_allocate_lines_cur (l_start_id, l_end_id);
    FETCH   sca_not_allocate_lines_cur BULK COLLECT INTO sca_not_allocate_lines limit 1000;

    debugmsg('Populate results back to API: Inserting Transactions into API for ''No Rules'', ''No Credit'' headers');

    FORALL j IN 1..sca_lines.COUNT

        UPDATE cn_comm_lines_api  api
        SET load_status 		= 'OBSOLETE',
            adjust_status 	    = 'FROZEN',
		    adjust_date   	    = sysdate,
		    adjusted_by   	    = l_adjusted_by,
		    adjust_comments 	= 'Negated for SCA'
        WHERE comm_lines_api_id = sca_lines(j);



    FORALL j IN 1..sca_not_allocate_lines.COUNT

    INSERT into CN_COMM_LINES_API
      ( SALESREP_ID,
        PROCESSED_DATE,
        PROCESSED_PERIOD_ID,
        TRANSACTION_AMOUNT,
        TRX_TYPE,
        REVENUE_CLASS_ID,
        LOAD_STATUS,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        ATTRIBUTE16,
        ATTRIBUTE17,
        ATTRIBUTE18,
        ATTRIBUTE19,
        ATTRIBUTE20,
        ATTRIBUTE21,
        ATTRIBUTE22,
        ATTRIBUTE23,
        ATTRIBUTE24,
        ATTRIBUTE25,
        ATTRIBUTE26,
        ATTRIBUTE27,
        ATTRIBUTE28,
        ATTRIBUTE29,
        ATTRIBUTE30,
        ATTRIBUTE31,
        ATTRIBUTE32,
        ATTRIBUTE33,
        ATTRIBUTE34,
        ATTRIBUTE35,
        ATTRIBUTE36,
        ATTRIBUTE37,
        ATTRIBUTE38,
        ATTRIBUTE39,
        ATTRIBUTE40,
        ATTRIBUTE41,
        ATTRIBUTE42,
        ATTRIBUTE43,
        ATTRIBUTE44,
        ATTRIBUTE45,
        ATTRIBUTE46,
        ATTRIBUTE47,
        ATTRIBUTE48,
        ATTRIBUTE49,
        ATTRIBUTE50,
        ATTRIBUTE51,
        ATTRIBUTE52,
        ATTRIBUTE53,
        ATTRIBUTE54,
        ATTRIBUTE55,
        ATTRIBUTE56,
        ATTRIBUTE57,
        ATTRIBUTE58,
        ATTRIBUTE59,
        ATTRIBUTE60,
        ATTRIBUTE61,
        ATTRIBUTE62,
        ATTRIBUTE63,
        ATTRIBUTE64,
        ATTRIBUTE65,
        ATTRIBUTE66,
        ATTRIBUTE67,
        ATTRIBUTE68,
        ATTRIBUTE69,
        ATTRIBUTE70,
        ATTRIBUTE71,
        ATTRIBUTE72,
        ATTRIBUTE73,
        ATTRIBUTE74,
        ATTRIBUTE75,
        ATTRIBUTE76,
        ATTRIBUTE77,
        ATTRIBUTE78,
        ATTRIBUTE79,
        ATTRIBUTE80,
        ATTRIBUTE81,
        ATTRIBUTE82,
        ATTRIBUTE83,
        ATTRIBUTE84,
        ATTRIBUTE85,
        ATTRIBUTE86,
        ATTRIBUTE87,
        ATTRIBUTE88,
        ATTRIBUTE89,
        ATTRIBUTE90,
        ATTRIBUTE91,
        ATTRIBUTE92,
        ATTRIBUTE93,
        ATTRIBUTE94,
        ATTRIBUTE95,
        ATTRIBUTE96,
        ATTRIBUTE97,
        ATTRIBUTE98,
        ATTRIBUTE99,
        ATTRIBUTE100,
        COMM_LINES_API_ID,
        CONC_BATCH_ID,
        PROCESS_BATCH_ID,
        SALESREP_NUMBER,
        ROLLUP_DATE,
        SOURCE_DOC_ID,
        SOURCE_DOC_TYPE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        TRANSACTION_CURRENCY_CODE,
        EXCHANGE_RATE,
        ACCTD_TRANSACTION_AMOUNT,
        TRX_ID,
        TRX_LINE_ID,
        TRX_SALES_LINE_ID,
        QUANTITY,
        SOURCE_TRX_NUMBER,
        DISCOUNT_PERCENTAGE,
        MARGIN_PERCENTAGE,
        SOURCE_TRX_ID,
        SOURCE_TRX_LINE_ID,
        SOURCE_TRX_SALES_LINE_ID,
        NEGATED_FLAG,
        CUSTOMER_ID,
        INVENTORY_ITEM_ID,
        ORDER_NUMBER,
        BOOKED_DATE,
        INVOICE_NUMBER,
        INVOICE_DATE,
        ADJUST_DATE,
        ADJUSTED_BY,
        REVENUE_TYPE,
        ADJUST_ROLLUP_FLAG,
        ADJUST_COMMENTS,
        ADJUST_STATUS,
        LINE_NUMBER,
        BILL_TO_ADDRESS_ID,
        SHIP_TO_ADDRESS_ID,
        BILL_TO_CONTACT_ID,
        SHIP_TO_CONTACT_ID,
        ADJ_COMM_LINES_API_ID,
        PRE_DEFINED_RC_FLAG,
        ROLLUP_FLAG,
        FORECAST_ID,
        UPSIDE_QUANTITY,
        UPSIDE_AMOUNT,
        UOM_CODE,
        REASON_CODE,
        TYPE,
        PRE_PROCESSED_CODE,
        QUOTA_ID,
        SRP_PLAN_ASSIGN_ID,
        ROLE_ID,
        COMP_GROUP_ID,
        COMMISSION_AMOUNT,
        EMPLOYEE_NUMBER,
        REVERSAL_FLAG,
        REVERSAL_HEADER_ID,
        SALES_CHANNEL,
        OBJECT_VERSION_NUMBER,
        SPLIT_PCT,
        SPLIT_status,
        org_id)
    (select
        CCLA.SALESREP_ID,
        CCLA.PROCESSED_DATE,
        CCLA.PROCESSED_PERIOD_ID,
        CCLA.TRANSACTION_AMOUNT,
        CCLA.TRX_TYPE,
        CCLA.REVENUE_CLASS_ID,
        'UNLOADED',
        CCLA.ATTRIBUTE_CATEGORY,
        CCLA.ATTRIBUTE1,
        CCLA.ATTRIBUTE2,
        CCLA.ATTRIBUTE3,
        CCLA.ATTRIBUTE4,
        CCLA.ATTRIBUTE5,
        CCLA.ATTRIBUTE6,
        CCLA.ATTRIBUTE7,
        CCLA.ATTRIBUTE8,
        CCLA.ATTRIBUTE9,
        CCLA.ATTRIBUTE10,
        CCLA.ATTRIBUTE11,
        CCLA.ATTRIBUTE12,
        CCLA.ATTRIBUTE13,
        CCLA.ATTRIBUTE14,
        CCLA.ATTRIBUTE15,
        CCLA.ATTRIBUTE16,
        CCLA.ATTRIBUTE17,
        CCLA.ATTRIBUTE18,
        CCLA.ATTRIBUTE19,
        CCLA.ATTRIBUTE20,
        CCLA.ATTRIBUTE21,
        CCLA.ATTRIBUTE22,
        CCLA.ATTRIBUTE23,
        CCLA.ATTRIBUTE24,
        CCLA.ATTRIBUTE25,
        CCLA.ATTRIBUTE26,
        CCLA.ATTRIBUTE27,
        CCLA.ATTRIBUTE28,
        CCLA.ATTRIBUTE29,
        CCLA.ATTRIBUTE30,
        CCLA.ATTRIBUTE31,
        CCLA.ATTRIBUTE32,
        CCLA.ATTRIBUTE33,
        CCLA.ATTRIBUTE34,
        CCLA.ATTRIBUTE35,
        CCLA.ATTRIBUTE36,
        CCLA.ATTRIBUTE37,
        CCLA.ATTRIBUTE38,
        CCLA.ATTRIBUTE39,
        CCLA.ATTRIBUTE40,
        CCLA.ATTRIBUTE41,
        CCLA.ATTRIBUTE42,
        CCLA.ATTRIBUTE43,
        CCLA.ATTRIBUTE44,
        CCLA.ATTRIBUTE45,
        CCLA.ATTRIBUTE46,
        CCLA.ATTRIBUTE47,
        CCLA.ATTRIBUTE48,
        CCLA.ATTRIBUTE49,
        CCLA.ATTRIBUTE50,
        CCLA.ATTRIBUTE51,
        CCLA.ATTRIBUTE52,
        CCLA.ATTRIBUTE53,
        CCLA.ATTRIBUTE54,
        CCLA.ATTRIBUTE55,
        CCLA.ATTRIBUTE56,
        CCLA.ATTRIBUTE57,
        CCLA.ATTRIBUTE58,
        CCLA.ATTRIBUTE59,
        CCLA.ATTRIBUTE60,
        CCLA.ATTRIBUTE61,
        CCLA.ATTRIBUTE62,
        CCLA.ATTRIBUTE63,
        CCLA.ATTRIBUTE64,
        CCLA.ATTRIBUTE65,
        CCLA.ATTRIBUTE66,
        CCLA.ATTRIBUTE67,
        CCLA.ATTRIBUTE68,
        CCLA.ATTRIBUTE69,
        CCLA.ATTRIBUTE70,
        CCLA.ATTRIBUTE71,
        CCLA.ATTRIBUTE72,
        CCLA.ATTRIBUTE73,
        CCLA.ATTRIBUTE74,
        CCLA.ATTRIBUTE75,
        CCLA.ATTRIBUTE76,
        CCLA.ATTRIBUTE77,
        CCLA.ATTRIBUTE78,
        CCLA.ATTRIBUTE79,
        CCLA.ATTRIBUTE80,
        CCLA.ATTRIBUTE81,
        CCLA.ATTRIBUTE82,
        CCLA.ATTRIBUTE83,
        CCLA.ATTRIBUTE84,
        CCLA.ATTRIBUTE85,
        CCLA.ATTRIBUTE86,
        CCLA.ATTRIBUTE87,
        CCLA.ATTRIBUTE88,
        CCLA.ATTRIBUTE89,
        CCLA.ATTRIBUTE90,
        CCLA.ATTRIBUTE91,
        CCLA.ATTRIBUTE92,
        CCLA.ATTRIBUTE93,
        CCLA.ATTRIBUTE94,
        CCLA.ATTRIBUTE95,
        CCLA.ATTRIBUTE96,
        CCLA.ATTRIBUTE97,
        CCLA.ATTRIBUTE98,
        CCLA.ATTRIBUTE99,
        CCLA.ATTRIBUTE100,
        cn_comm_lines_api_s.NEXTVAL,
        CCLA.CONC_BATCH_ID,
        CCLA.PROCESS_BATCH_ID,
        NULL,
        CCLA.ROLLUP_DATE,
        CCLA.SOURCE_DOC_ID,
        CCLA.SOURCE_DOC_TYPE,
        fnd_global.user_id,
        Sysdate,
        fnd_global.user_id,
        Sysdate,
        fnd_global.login_id,
        CCLA.TRANSACTION_CURRENCY_CODE,
        CCLA.EXCHANGE_RATE,
        CCLA.ACCTD_TRANSACTION_AMOUNT,
        CCLA.TRX_ID,
        CCLA.TRX_LINE_ID,
        CCLA.TRX_SALES_LINE_ID,
        CCLA.QUANTITY,
        CCLA.SOURCE_TRX_NUMBER,
        CCLA.DISCOUNT_PERCENTAGE,
        CCLA.MARGIN_PERCENTAGE,
        CCLA.SOURCE_TRX_ID,
        CCLA.SOURCE_TRX_LINE_ID,
        CCLA.SOURCE_TRX_SALES_LINE_ID,
        CCLA.NEGATED_FLAG,
        CCLA.CUSTOMER_ID,
        CCLA.INVENTORY_ITEM_ID,
        CCLA.ORDER_NUMBER,
        CCLA.BOOKED_DATE,
        CCLA.INVOICE_NUMBER,
        CCLA.INVOICE_DATE,
        SYSDATE,
        l_adjusted_by,
        CCLA.REVENUE_TYPE,
        CCLA.ADJUST_ROLLUP_FLAG,
        'Created by SCA',
        'SCA_NOT_ALLOCATED',
        CCLA.LINE_NUMBER,
        CCLA.BILL_TO_ADDRESS_ID,
        CCLA.SHIP_TO_ADDRESS_ID,
        CCLA.BILL_TO_CONTACT_ID,
        CCLA.SHIP_TO_CONTACT_ID,
        CCLA.COMM_LINES_API_ID,
        CCLA.PRE_DEFINED_RC_FLAG,
        CCLA.ROLLUP_FLAG,
        CCLA.FORECAST_ID,
        CCLA.UPSIDE_QUANTITY,
        CCLA.UPSIDE_AMOUNT,
        CCLA.UOM_CODE,
        CCLA.REASON_CODE,
        CCLA.TYPE,
        CCLA.PRE_PROCESSED_CODE,
        CCLA.QUOTA_ID,
        CCLA.SRP_PLAN_ASSIGN_ID,
        CCLA.ROLE_ID,
        CCLA.COMP_GROUP_ID,
        CCLA.COMMISSION_AMOUNT,
        CCLA.EMPLOYEE_NUMBER,
        CCLA.REVERSAL_FLAG,
        CCLA.REVERSAL_HEADER_ID,
        CCLA.SALES_CHANNEL,
        CCLA.OBJECT_VERSION_NUMBER,
        CCLA.SPLIT_PCT,
        CCLA.SPLIT_status,
        ccla.org_id
      from
        cn_comm_lines_api CCLA
      where  CCLA.comm_lines_api_id = sca_not_allocate_lines(j));

    FORALL j IN 1..sca_no_rule_lines.COUNT

    INSERT into CN_COMM_LINES_API
      ( SALESREP_ID,
        PROCESSED_DATE,
        PROCESSED_PERIOD_ID,
        TRANSACTION_AMOUNT,
        TRX_TYPE,
        REVENUE_CLASS_ID,
        LOAD_STATUS,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        ATTRIBUTE16,
        ATTRIBUTE17,
        ATTRIBUTE18,
        ATTRIBUTE19,
        ATTRIBUTE20,
        ATTRIBUTE21,
        ATTRIBUTE22,
        ATTRIBUTE23,
        ATTRIBUTE24,
        ATTRIBUTE25,
        ATTRIBUTE26,
        ATTRIBUTE27,
        ATTRIBUTE28,
        ATTRIBUTE29,
        ATTRIBUTE30,
        ATTRIBUTE31,
        ATTRIBUTE32,
        ATTRIBUTE33,
        ATTRIBUTE34,
        ATTRIBUTE35,
        ATTRIBUTE36,
        ATTRIBUTE37,
        ATTRIBUTE38,
        ATTRIBUTE39,
        ATTRIBUTE40,
        ATTRIBUTE41,
        ATTRIBUTE42,
        ATTRIBUTE43,
        ATTRIBUTE44,
        ATTRIBUTE45,
        ATTRIBUTE46,
        ATTRIBUTE47,
        ATTRIBUTE48,
        ATTRIBUTE49,
        ATTRIBUTE50,
        ATTRIBUTE51,
        ATTRIBUTE52,
        ATTRIBUTE53,
        ATTRIBUTE54,
        ATTRIBUTE55,
        ATTRIBUTE56,
        ATTRIBUTE57,
        ATTRIBUTE58,
        ATTRIBUTE59,
        ATTRIBUTE60,
        ATTRIBUTE61,
        ATTRIBUTE62,
        ATTRIBUTE63,
        ATTRIBUTE64,
        ATTRIBUTE65,
        ATTRIBUTE66,
        ATTRIBUTE67,
        ATTRIBUTE68,
        ATTRIBUTE69,
        ATTRIBUTE70,
        ATTRIBUTE71,
        ATTRIBUTE72,
        ATTRIBUTE73,
        ATTRIBUTE74,
        ATTRIBUTE75,
        ATTRIBUTE76,
        ATTRIBUTE77,
        ATTRIBUTE78,
        ATTRIBUTE79,
        ATTRIBUTE80,
        ATTRIBUTE81,
        ATTRIBUTE82,
        ATTRIBUTE83,
        ATTRIBUTE84,
        ATTRIBUTE85,
        ATTRIBUTE86,
        ATTRIBUTE87,
        ATTRIBUTE88,
        ATTRIBUTE89,
        ATTRIBUTE90,
        ATTRIBUTE91,
        ATTRIBUTE92,
        ATTRIBUTE93,
        ATTRIBUTE94,
        ATTRIBUTE95,
        ATTRIBUTE96,
        ATTRIBUTE97,
        ATTRIBUTE98,
        ATTRIBUTE99,
        ATTRIBUTE100,
        COMM_LINES_API_ID,
        CONC_BATCH_ID,
        PROCESS_BATCH_ID,
        SALESREP_NUMBER,
        ROLLUP_DATE,
        SOURCE_DOC_ID,
        SOURCE_DOC_TYPE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        TRANSACTION_CURRENCY_CODE,
        EXCHANGE_RATE,
        ACCTD_TRANSACTION_AMOUNT,
        TRX_ID,
        TRX_LINE_ID,
        TRX_SALES_LINE_ID,
        QUANTITY,
        SOURCE_TRX_NUMBER,
        DISCOUNT_PERCENTAGE,
        MARGIN_PERCENTAGE,
        SOURCE_TRX_ID,
        SOURCE_TRX_LINE_ID,
        SOURCE_TRX_SALES_LINE_ID,
        NEGATED_FLAG,
        CUSTOMER_ID,
        INVENTORY_ITEM_ID,
        ORDER_NUMBER,
        BOOKED_DATE,
        INVOICE_NUMBER,
        INVOICE_DATE,
        ADJUST_DATE,
        ADJUSTED_BY,
        REVENUE_TYPE,
        ADJUST_ROLLUP_FLAG,
        ADJUST_COMMENTS,
        ADJUST_STATUS,
        LINE_NUMBER,
        BILL_TO_ADDRESS_ID,
        SHIP_TO_ADDRESS_ID,
        BILL_TO_CONTACT_ID,
        SHIP_TO_CONTACT_ID,
        ADJ_COMM_LINES_API_ID,
        PRE_DEFINED_RC_FLAG,
        ROLLUP_FLAG,
        FORECAST_ID,
        UPSIDE_QUANTITY,
        UPSIDE_AMOUNT,
        UOM_CODE,
        REASON_CODE,
        TYPE,
        PRE_PROCESSED_CODE,
        QUOTA_ID,
        SRP_PLAN_ASSIGN_ID,
        ROLE_ID,
        COMP_GROUP_ID,
        COMMISSION_AMOUNT,
        EMPLOYEE_NUMBER,
        REVERSAL_FLAG,
        REVERSAL_HEADER_ID,
        SALES_CHANNEL,
        OBJECT_VERSION_NUMBER,
        SPLIT_PCT,
        SPLIT_status,
        org_id)

    (select
        CCLA.SALESREP_ID,
        CCLA.PROCESSED_DATE,
        CCLA.PROCESSED_PERIOD_ID,
        CCLA.TRANSACTION_AMOUNT,
        CCLA.TRX_TYPE,
        CCLA.REVENUE_CLASS_ID,
        'UNLOADED',
        CCLA.ATTRIBUTE_CATEGORY,
        CCLA.ATTRIBUTE1,
        CCLA.ATTRIBUTE2,
        CCLA.ATTRIBUTE3,
        CCLA.ATTRIBUTE4,
        CCLA.ATTRIBUTE5,
        CCLA.ATTRIBUTE6,
        CCLA.ATTRIBUTE7,
        CCLA.ATTRIBUTE8,
        CCLA.ATTRIBUTE9,
        CCLA.ATTRIBUTE10,
        CCLA.ATTRIBUTE11,
        CCLA.ATTRIBUTE12,
        CCLA.ATTRIBUTE13,
        CCLA.ATTRIBUTE14,
        CCLA.ATTRIBUTE15,
        CCLA.ATTRIBUTE16,
        CCLA.ATTRIBUTE17,
        CCLA.ATTRIBUTE18,
        CCLA.ATTRIBUTE19,
        CCLA.ATTRIBUTE20,
        CCLA.ATTRIBUTE21,
        CCLA.ATTRIBUTE22,
        CCLA.ATTRIBUTE23,
        CCLA.ATTRIBUTE24,
        CCLA.ATTRIBUTE25,
        CCLA.ATTRIBUTE26,
        CCLA.ATTRIBUTE27,
        CCLA.ATTRIBUTE28,
        CCLA.ATTRIBUTE29,
        CCLA.ATTRIBUTE30,
        CCLA.ATTRIBUTE31,
        CCLA.ATTRIBUTE32,
        CCLA.ATTRIBUTE33,
        CCLA.ATTRIBUTE34,
        CCLA.ATTRIBUTE35,
        CCLA.ATTRIBUTE36,
        CCLA.ATTRIBUTE37,
        CCLA.ATTRIBUTE38,
        CCLA.ATTRIBUTE39,
        CCLA.ATTRIBUTE40,
        CCLA.ATTRIBUTE41,
        CCLA.ATTRIBUTE42,
        CCLA.ATTRIBUTE43,
        CCLA.ATTRIBUTE44,
        CCLA.ATTRIBUTE45,
        CCLA.ATTRIBUTE46,
        CCLA.ATTRIBUTE47,
        CCLA.ATTRIBUTE48,
        CCLA.ATTRIBUTE49,
        CCLA.ATTRIBUTE50,
        CCLA.ATTRIBUTE51,
        CCLA.ATTRIBUTE52,
        CCLA.ATTRIBUTE53,
        CCLA.ATTRIBUTE54,
        CCLA.ATTRIBUTE55,
        CCLA.ATTRIBUTE56,
        CCLA.ATTRIBUTE57,
        CCLA.ATTRIBUTE58,
        CCLA.ATTRIBUTE59,
        CCLA.ATTRIBUTE60,
        CCLA.ATTRIBUTE61,
        CCLA.ATTRIBUTE62,
        CCLA.ATTRIBUTE63,
        CCLA.ATTRIBUTE64,
        CCLA.ATTRIBUTE65,
        CCLA.ATTRIBUTE66,
        CCLA.ATTRIBUTE67,
        CCLA.ATTRIBUTE68,
        CCLA.ATTRIBUTE69,
        CCLA.ATTRIBUTE70,
        CCLA.ATTRIBUTE71,
        CCLA.ATTRIBUTE72,
        CCLA.ATTRIBUTE73,
        CCLA.ATTRIBUTE74,
        CCLA.ATTRIBUTE75,
        CCLA.ATTRIBUTE76,
        CCLA.ATTRIBUTE77,
        CCLA.ATTRIBUTE78,
        CCLA.ATTRIBUTE79,
        CCLA.ATTRIBUTE80,
        CCLA.ATTRIBUTE81,
        CCLA.ATTRIBUTE82,
        CCLA.ATTRIBUTE83,
        CCLA.ATTRIBUTE84,
        CCLA.ATTRIBUTE85,
        CCLA.ATTRIBUTE86,
        CCLA.ATTRIBUTE87,
        CCLA.ATTRIBUTE88,
        CCLA.ATTRIBUTE89,
        CCLA.ATTRIBUTE90,
        CCLA.ATTRIBUTE91,
        CCLA.ATTRIBUTE92,
        CCLA.ATTRIBUTE93,
        CCLA.ATTRIBUTE94,
        CCLA.ATTRIBUTE95,
        CCLA.ATTRIBUTE96,
        CCLA.ATTRIBUTE97,
        CCLA.ATTRIBUTE98,
        CCLA.ATTRIBUTE99,
        CCLA.ATTRIBUTE100,
        cn_comm_lines_api_s.NEXTVAL,
        CCLA.CONC_BATCH_ID,
        CCLA.PROCESS_BATCH_ID,
        NULL,
        CCLA.ROLLUP_DATE,
        CCLA.SOURCE_DOC_ID,
        CCLA.SOURCE_DOC_TYPE,
        fnd_global.user_id,
        Sysdate,
        fnd_global.user_id,
        Sysdate,
        fnd_global.login_id,
        CCLA.TRANSACTION_CURRENCY_CODE,
        CCLA.EXCHANGE_RATE,
        CCLA.ACCTD_TRANSACTION_AMOUNT,
        CCLA.TRX_ID,
        CCLA.TRX_LINE_ID,
        CCLA.TRX_SALES_LINE_ID,
        CCLA.QUANTITY,
        CCLA.SOURCE_TRX_NUMBER,
        CCLA.DISCOUNT_PERCENTAGE,
        CCLA.MARGIN_PERCENTAGE,
        CCLA.SOURCE_TRX_ID,
        CCLA.SOURCE_TRX_LINE_ID,
        CCLA.SOURCE_TRX_SALES_LINE_ID,
        CCLA.NEGATED_FLAG,
        CCLA.CUSTOMER_ID,
        CCLA.INVENTORY_ITEM_ID,
        CCLA.ORDER_NUMBER,
        CCLA.BOOKED_DATE,
        CCLA.INVOICE_NUMBER,
        CCLA.INVOICE_DATE,
        SYSDATE,
        l_adjusted_by,
        CCLA.REVENUE_TYPE,
        CCLA.ADJUST_ROLLUP_FLAG,
        'Created by SCA',
        'SCA_NO_RULE',
        CCLA.LINE_NUMBER,
        CCLA.BILL_TO_ADDRESS_ID,
        CCLA.SHIP_TO_ADDRESS_ID,
        CCLA.BILL_TO_CONTACT_ID,
        CCLA.SHIP_TO_CONTACT_ID,
        CCLA.COMM_LINES_API_ID,
        CCLA.PRE_DEFINED_RC_FLAG,
        CCLA.ROLLUP_FLAG,
        CCLA.FORECAST_ID,
        CCLA.UPSIDE_QUANTITY,
        CCLA.UPSIDE_AMOUNT,
        CCLA.UOM_CODE,
        CCLA.REASON_CODE,
        CCLA.TYPE,
        CCLA.PRE_PROCESSED_CODE,
        CCLA.QUOTA_ID,
        CCLA.SRP_PLAN_ASSIGN_ID,
        CCLA.ROLE_ID,
        CCLA.COMP_GROUP_ID,
        CCLA.COMMISSION_AMOUNT,
        CCLA.EMPLOYEE_NUMBER,
        CCLA.REVERSAL_FLAG,
        CCLA.REVERSAL_HEADER_ID,
        CCLA.SALES_CHANNEL,
        CCLA.OBJECT_VERSION_NUMBER,
        CCLA.SPLIT_PCT,
        CCLA.SPLIT_status,
        ccla.org_id
      from
        cn_comm_lines_api CCLA
      where  CCLA.comm_lines_api_id = sca_no_rule_lines(j));


    debugmsg('Populate results back to API: Done with Negating Transactions ');

    EXCEPTION

        WHEN OTHERS THEN

        debugmsg('Populate results back to API : Unexpected exception');
        debugmsg('Populate results back to API : Done with Negating Transactions ');

        conc_status := fnd_concurrent.set_completion_status(
			status 	=> 'ERROR',
            message => '');

	    RAISE;

END negate_trx;

PROCEDURE populate_results (
                errbuf         OUT 	NOCOPY VARCHAR2,
                retcode        OUT 	NOCOPY NUMBER,
                pp_start_date    	VARCHAR2,
                pp_end_date      	VARCHAR2,
		p_org_id	IN	VARCHAR2) IS


    CURSOR sca_update_headers_cur (p_start_date DATE, p_end_date DATE) IS

        select CSHI.sca_headers_interface_id from cn_sca_headers_interface CSHI
        where trunc(CSHI.processed_date) between trunc(p_start_date) and trunc(p_end_date)
	   	and CSHI.process_status <> 'SCA_UNPROCESSED'
	  and CSHI.transaction_status = 'SCA_UNPROCESSED'
	  AND cshi.org_id = p_org_id;

    TYPE sca_update_headers_tbl IS TABLE OF cn_sca_headers_interface.sca_headers_interface_id%TYPE;

    sca_update_headers sca_update_headers_tbl;

    p_start_date    DATE;
    p_end_date      DATE;
    l_process_audit_id   NUMBER;
    l_create_logical_batch_id   NUMBER;
    l_negate_logical_batch_id   NUMBER;
    conc_status     boolean;
    x_negate_size   NUMBER;
    x_create_size   NUMBER;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT	populate_results_savepoint;

    -- Convert the dates for the varchar2 parameters passed in from concurrent program
    p_start_date := fnd_date.canonical_to_date(pp_start_date);
    p_end_date   := fnd_date.canonical_to_date(pp_end_date);

    SELECT cn_sca_logical_batches_s.NEXTVAL
    INTO l_create_logical_batch_id
    FROM sys.dual;

    SELECT cn_sca_logical_batches_s.NEXTVAL
    INTO l_negate_logical_batch_id
    FROM sys.dual;

    assign(l_negate_logical_batch_id,
           p_start_date,
           p_end_date,
           'CSHI',
           p_org_id,
           x_negate_size);

    assign(l_create_logical_batch_id,
           p_start_date,
           p_end_date,
           'CSLO',
           p_org_id,
           x_create_size);

    --+
    --+ Call begin_batch to get process_audit_id for debug log file
    --+

    cn_message_pkg.begin_batch
	(x_process_type	         => 'RESULTS_TRANSFER',
	 x_parent_proc_audit_id  => null,
	 x_process_audit_id	 => l_process_audit_id,
	 x_request_id		 => fnd_global.conc_request_id,
	 p_org_id	         => p_org_id);

    debugmsg('Results Transfer : Start of Transfer');
    debugmsg('Results Transfer : process_audit_id is ' || l_process_audit_id );
    debugmsg('Results Transfer : negate_logical_batch_id is ' || l_negate_logical_batch_id );
    debugmsg('Results Transfer : negate logical batch size = ' || x_negate_size );
    debugmsg('Results Transfer : create_logical_batch_id is ' || l_create_logical_batch_id );
    debugmsg('Results Transfer : create logical batch size = ' || x_create_size );

    if (x_create_size > 0) then

        debugmsg('Result Transfer : Start of Create Transactions Batch');

        conc_dispatch(
            x_parent_proc_audit_id  => l_process_audit_id,
            x_start_date            => p_start_date,
            x_end_date              => p_end_date,
            x_logical_batch_id      => l_create_logical_batch_id,
            x_process               => 'Create_trx');

        debugmsg('Result Transfer : End of Create Transactions Batch');

    end if;

     if (x_negate_size > 0) then

        debugmsg('Result Transfer : Start of Negate Transactions Batch');

        conc_dispatch(
            x_parent_proc_audit_id  => l_process_audit_id,
            x_start_date            => p_start_date,
            x_end_date              => p_end_date,
            x_logical_batch_id      => l_negate_logical_batch_id,
            x_process               => 'Negate_trx');

        debugmsg('Result Transfer : End of Negate Transactions Batch');

    end if;

    debugmsg('Results Transfer : Updating Headers to ''Populated''');

    OPEN sca_update_headers_cur (p_start_date, p_end_date);
    FETCH   sca_update_headers_cur BULK COLLECT INTO sca_update_headers;

    if (sca_update_headers.COUNT = 0) then

        raise no_trx_lines;

    end if;

    FORALL j IN 1..sca_update_headers.COUNT

        UPDATE cn_sca_headers_interface
        SET transaction_status = 'SCA_POPULATED'
        WHERE sca_headers_interface_id = sca_update_headers(j);

    debugmsg('Results Transfer : End of Transfer');

    cn_message_pkg.end_batch(l_process_audit_id);

EXCEPTION

        WHEN no_trx_lines THEN

        ROLLBACK TO populate_results_savepoint;

	    -- Call end_batch to end debug log file
        debugmsg('Results Transfer : No transactions to transfer');
        debugmsg('Results Transfer : End of Transfer');

        conc_status := fnd_concurrent.set_completion_status(
			status 	=> 'ERROR',
            message => '');

	    cn_message_pkg.end_batch(l_process_audit_id);

        WHEN OTHERS THEN

        ROLLBACK TO populate_results_savepoint;

        debugmsg('Results Transfer : Unexpected exception');
        debugmsg('Results Transfer : End of Transfer');

        conc_status := fnd_concurrent.set_completion_status(
			status 	=> 'ERROR',
            message => '');

	    cn_message_pkg.end_batch(l_process_audit_id);

END populate_results;


PROCEDURE call_populate_results (
        p_api_version   	IN	NUMBER,
     	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
        p_commit	        IN      VARCHAR2 	:= FND_API.G_FALSE,
     	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
        p_start_date            IN      DATE,
        p_end_date              IN      DATE,
        p_org_id	        IN      NUMBER,
        x_return_status         OUT NOCOPY     VARCHAR2,
     	x_msg_count             OUT NOCOPY     NUMBER,
     	x_msg_data              OUT NOCOPY     VARCHAR2,
     	x_process_audit_id      OUT NOCOPY     NUMBER) IS

        l_api_name	CONSTANT VARCHAR2(30) := 'call_populate_results';
        l_api_version   CONSTANT NUMBER := 1.0;

        p_errbuf    VARCHAR2(1000);
        p_retcode   NUMBER;
        i       NUMBER;
        x_size          NUMBER;


BEGIN

    -- Standard Start of API savepoint
   SAVEPOINT call_populate_results;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   fnd_request.set_org_id( p_org_id );  -- vensrini

    x_process_audit_id :=

         FND_REQUEST.SUBMIT_REQUEST(
            application   => 'CN',
            program       => 'CN_SCA_POPULATE_RESULTS',
            argument1     => TO_CHAR(p_start_date,'YYYY/MM/DD HH24:MI:SS'),
    	    argument2     => TO_CHAR(p_end_date,'YYYY/MM/DD HH24:MI:SS'),
            argument3     => p_org_id);
    commit;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO call_populate_results;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO call_populate_results;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO call_populate_results;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(
         FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);

END call_populate_results;


PROCEDURE populate_data (
                errbuf         		OUT NOCOPY VARCHAR2,
                retcode        		OUT NOCOPY NUMBER,
                pp_start_date    	VARCHAR2,
                pp_end_date      	VARCHAR2,
                p_checkbox_value    	VARCHAR2) IS

    p_start_date    DATE;
    p_end_date      DATE;
    l_process_audit_id   NUMBER;

    l_logical_batch_id      NUMBER;
    x_size_inv          NUMBER;
    x_size_ord          NUMBER;
    x_size              NUMBER;
    conc_status boolean;
   p_org_id         number;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT	populate_data_savepoint;

    p_org_id := mo_global.get_current_org_id();

    -- Convert the dates for the varchar2 parameters passed in from concurrent program

    p_start_date := fnd_date.canonical_to_date(pp_start_date);
    p_end_date   := fnd_date.canonical_to_date(pp_end_date);

    --+
    --+ Call begin_batch to get process_audit_id for debug log file
    --+

    cn_message_pkg.begin_batch
	(x_process_type	         => 'ALLOCATION_TRANSFER',
	 x_parent_proc_audit_id  => null,
	 x_process_audit_id	 => l_process_audit_id,
	 x_request_id		 => fnd_global.conc_request_id,
	 p_org_id		 => p_org_id);

    SELECT cn_sca_logical_batches_s.NEXTVAL
    INTO l_logical_batch_id
    FROM sys.dual;

    debugmsg('Allocation Transfer : Start of Transfer');
    debugmsg('Allocation Transfer : process_audit_id is ' || l_process_audit_id );
    debugmsg('Allocation Transfer : logical_batch_id is ' || l_logical_batch_id );
    debugmsg('Allocation Transfer : mo_global.get_current_org_id is - ' || p_org_id);

    assign(l_logical_batch_id,
            p_start_date,
            p_end_date,
            'ORD',
            p_org_id,
            x_size);

    assign(l_logical_batch_id,
            p_start_date,
            p_end_date,
            'INV',
            p_org_id,
            x_size);

    conc_dispatch(
            x_parent_proc_audit_id  => l_process_audit_id,
            x_start_date            => p_start_date,
            x_end_date              => p_end_date,
            x_logical_batch_id      => l_logical_batch_id,
            x_process               => 'Check_comm_lines_api_adjusted');


    if (p_checkbox_value = 'Y') then

        SELECT cn_sca_logical_batches_s.NEXTVAL
        INTO l_logical_batch_id
        FROM sys.dual;

        debugmsg('Allocation Transfer : Need to Rerun ');
        debugmsg('Allocation Transfer : Rerun: Logical batch id = ' || l_logical_batch_id);

        assign(l_logical_batch_id,
               p_start_date,
               p_end_date,
	  'SCA_ORD',
	  p_org_id,
               x_size);

        assign(l_logical_batch_id,
               p_start_date,
               p_end_date,
	  'SCA_INV',
	  p_org_id,
               x_size);

        conc_dispatch(
            x_parent_proc_audit_id  => l_process_audit_id,
            x_start_date            => p_start_date,
            x_end_date              => p_end_date,
            x_logical_batch_id      => l_logical_batch_id,
            x_process               => 'Rollback_data');

    end if;

    SELECT cn_sca_logical_batches_s.NEXTVAL
    INTO l_logical_batch_id
    FROM sys.dual;

    debugmsg('Allocation Transfer : Get the set of transactions that needs to be transferred ');
    debugmsg('Allocation Transfer : Logical batch id = ' || l_logical_batch_id);

    assign(l_logical_batch_id,
           p_start_date,
           p_end_date,
      'ORD',
      p_org_id,
           x_size_ord);

    assign(l_logical_batch_id,
           p_start_date,
           p_end_date,
      'INV',
      p_org_id,
           x_size_inv);

    if ((x_size_inv > 0) or (x_size_ord > 0)) then

        conc_dispatch(
            x_parent_proc_audit_id  => l_process_audit_id,
            x_start_date            => p_start_date,
            x_end_date              => p_end_date,
            x_logical_batch_id      => l_logical_batch_id,
            x_process               => 'Populate_data');

    else

        raise no_trx_lines;

    end if;

    cn_message_pkg.end_batch(l_process_audit_id);

    EXCEPTION

        WHEN no_trx_lines THEN

	ROLLBACK TO populate_data_savepoint;

	    -- Call end_batch to end debug log file
        debugmsg('Allocation Transfer : No transactions to transfer');
        debugmsg('Allocation Transfer : End of Transfer');

        conc_status := fnd_concurrent.set_completion_status(
			status 	=> 'ERROR',
            message => '');

	    cn_message_pkg.end_batch(l_process_audit_id);

        WHEN OTHERS THEN

	ROLLBACK TO populate_data_savepoint;

        debugmsg('Allocation Transfer : Unexpected exception');
        debugmsg('Allocation Transfer : End of Transfer');

        conc_status := fnd_concurrent.set_completion_status(
			status 	=> 'ERROR',
            message => '');

	    cn_message_pkg.end_batch(l_process_audit_id);

END populate_data;


PROCEDURE call_populate_data (
        p_api_version   	IN	NUMBER,
     	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
        p_commit	        IN      VARCHAR2 	:= FND_API.G_FALSE,
     	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
        p_start_date            IN      DATE,
        p_end_date              IN      DATE,
        p_checkbox_value        IN      VARCHAR2,
        x_return_status         OUT NOCOPY     VARCHAR2,
     	x_msg_count             OUT NOCOPY     NUMBER,
     	x_msg_data              OUT NOCOPY     VARCHAR2,
     	x_process_audit_id      OUT NOCOPY     NUMBER) IS

        l_api_name		CONSTANT VARCHAR2(30) := 'call_populate_data';
        l_api_version      	CONSTANT NUMBER := 1.0;
        l_checkbox_value 	CHAR(1)	:= 'Y';
        l_gen_status            CN_REPOSITORIES.SCA_MAPPING_STATUS%TYPE;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT call_populate_data;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (p_checkbox_value <> 'Y') THEN
      l_checkbox_value := 'N';
   END IF;

   select sca_mapping_status into
          l_gen_status
    from cn_repositories;

    IF (l_gen_status <> 'GENERATED') THEN

    	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_DYNAMIC_PKG_NOT_GEN');
	    FND_MSG_PUB.Add;
	END IF;
	RAISE FND_API.G_EXC_ERROR ;

    END IF;

    x_process_audit_id :=
         FND_REQUEST.SUBMIT_REQUEST(
            application   => 'CN',
            program       => 'CN_SCA_POPULATE_DATA',
            argument1     => TO_CHAR(p_start_date,'YYYY/MM/DD HH24:MI:SS'),
    	    argument2     => TO_CHAR(p_end_date,'YYYY/MM/DD HH24:MI:SS'),
            argument3     => l_checkbox_value);
    commit;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO call_populate_data;

      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO call_populate_data;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO call_populate_data;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(
         FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);

END call_populate_data;

Procedure   check_api_adjusted (
                p_start_date           DATE,
                p_end_date             DATE,
                p_physical_batch_id    NUMBER)   IS

    l_batch_type    cn_sca_process_batches.type%TYPE;
    l_start_id      cn_sca_process_batches.start_id%TYPE;
    l_end_id        cn_sca_process_batches.end_id%TYPE;

    conc_status boolean;

    cursor api_adjust_lines_inv_cur (l_start_id VARCHAR2, l_end_id VARCHAR2) IS

        select CCLA.comm_lines_api_id from cn_comm_lines_api CCLA
        where trunc(CCLA.processed_date) between trunc(p_start_date) and trunc(p_end_date)
		and CCLA.load_status = 'UNLOADED'
		and (--(CCLA.adjust_status is null) or
             (CCLA.adjust_status not in ('SCA_PENDING', 'SCA_ALLOCATED', 'SCA_NO_RULE', 'SCA_NOT_ALLOCATED',
              'SCA_NOT_ELIGIBLE', 'REVERSAL', 'FROZEN')))
        and ((CCLA.trx_type = 'INV') or (CCLA.trx_type = 'MAN'))
        and CCLA.line_number is not null
        and CCLA.invoice_number is not null
        and CCLA.invoice_number between l_start_id and l_end_id
        and exists

            	(SELECT 1
                 from cn_sca_headers_interface CSHI
                 where CSHI.transaction_status = 'ADJUSTED'
              			    and CSHI.source_id = CCLA.invoice_number
              			    and CSHI.source_type = 'INV');

    cursor sca_adjust_headers_inv_cur (l_start_id VARCHAR2, l_end_id VARCHAR2) IS

        select sca_headers_interface_id
        from cn_sca_headers_interface
        where source_type = 'INV'
        and source_id in
           (select invoice_number
            from
               (select distinct(invoice_number) invoice_number from cn_comm_lines_api CCLA
                where trunc(CCLA.processed_date) between trunc(p_start_date) and trunc(p_end_date)
		        and CCLA.load_status = 'UNLOADED'
		        and (--(CCLA.adjust_status is null) or
                     (CCLA.adjust_status not in ('SCA_PENDING', 'SCA_ALLOCATED', 'SCA_NO_RULE', 'SCA_NOT_ALLOCATED',
                      'SCA_NOT_ELIGIBLE', 'REVERSAL', 'FROZEN')))
                and ((CCLA.trx_type = 'INV') or (CCLA.trx_type = 'MAN'))
                and CCLA.line_number is not null
                and CCLA.invoice_number is not null
                and CCLA.invoice_number between l_start_id and l_end_id)      SCA_SOURCE_ID

            where exists
            	(SELECT 1
             	 FROM cn_comm_lines_api CCLA_ORIG
             	 where CCLA_ORIG.adj_comm_lines_api_id in

                           (SELECT CSLI.source_trx_id
              	            from cn_sca_lines_interface CSLI, cn_sca_headers_interface CSHI
              			    where CSLI.sca_headers_interface_id = CSHI.sca_headers_interface_id
              			    and CSHI.source_id = SCA_SOURCE_ID.invoice_number
              			    and CSHI.source_type = 'INV')

                  and ((CCLA_ORIG.adjust_status = 'FROZEN' and CCLA_ORIG.load_status = 'OBSOLETE'
                        and (CCLA_ORIG.adjust_comments is null or CCLA_ORIG.adjust_comments <> 'SCA_ROLLBACK')) or
                       (CCLA_ORIG.load_status = 'LOADED' and exists

                            (select 1 from cn_comm_lines_api CCLA
                             where CCLA.adj_comm_lines_api_id = CCLA_ORIG.comm_lines_api_id
                             and CCLA.adjust_status = 'REVERSAL'
		             and (CCLA.adjust_comments is null or CCLA.adjust_comments <> 'SCA_ROLLBACK')
			)))));

    CURSOR sca_rollback_headers_inv_cur (l_start_id VARCHAR2, l_end_id VARCHAR2) IS

        select sca_headers_interface_id
        from cn_sca_headers_interface
        where ((transaction_status is null) or (transaction_status <> 'ADJUSTED'))
        and source_type = 'INV'
        and source_id in

               (select distinct(invoice_number) invoice_number from cn_comm_lines_api CCLA
                where trunc(CCLA.processed_date) between trunc(p_start_date) and trunc(p_end_date)
		        and CCLA.load_status = 'UNLOADED'
		        and (--(CCLA.adjust_status is null) or
                     (CCLA.adjust_status not in ('SCA_PENDING', 'SCA_ALLOCATED', 'SCA_NO_RULE', 'SCA_NOT_ALLOCATED',
                      'SCA_NOT_ELIGIBLE', 'REVERSAL', 'FROZEN')))
                and ((CCLA.trx_type = 'INV') or (CCLA.trx_type = 'MAN'))
                and CCLA.line_number is not null
                and CCLA.invoice_number is not null
                and CCLA.invoice_number between l_start_id and l_end_id);

    CURSOR sca_rollback_lines_inv_cur (l_start_id VARCHAR2, l_end_id VARCHAR2) IS

        select CSLI.source_trx_id
        from cn_sca_headers_interface CSHI, cn_sca_lines_interface CSLI
        where CSHI.sca_headers_interface_id = CSLI.sca_headers_interface_id
        and ((CSHI.transaction_status is null) or (CSHI.transaction_status <> 'ADJUSTED'))
        and CSHI.source_type = 'INV'
        and CSHI.source_id in

               (select distinct(invoice_number) invoice_number from cn_comm_lines_api CCLA
                where trunc(CCLA.processed_date) between trunc(p_start_date) and trunc(p_end_date)
		        and CCLA.load_status = 'UNLOADED'
		        and (--(CCLA.adjust_status is null) or
                     (CCLA.adjust_status not in ('SCA_PENDING', 'SCA_ALLOCATED', 'SCA_NO_RULE', 'SCA_NOT_ALLOCATED',
                      'SCA_NOT_ELIGIBLE', 'REVERSAL', 'FROZEN')))
                and ((CCLA.trx_type = 'INV') or (CCLA.trx_type = 'MAN'))
                and CCLA.line_number is not null
                and CCLA.invoice_number is not null
                and CCLA.invoice_number between l_start_id and l_end_id);

    cursor api_adjust_lines_ord_cur (l_start_id VARCHAR2, l_end_id VARCHAR2) IS

        select CCLA.comm_lines_api_id from cn_comm_lines_api CCLA
        where trunc(CCLA.processed_date) between trunc(p_start_date) and trunc(p_end_date)
		and CCLA.load_status = 'UNLOADED'
		and (--(CCLA.adjust_status is null) or
             (CCLA.adjust_status not in ('SCA_PENDING', 'SCA_ALLOCATED', 'SCA_NO_RULE', 'SCA_NOT_ALLOCATED',
              'SCA_NOT_ELIGIBLE', 'REVERSAL', 'FROZEN')))
        and ((CCLA.trx_type = 'ORD') or (CCLA.trx_type = 'MAN'))
        and CCLA.line_number is not null
        and CCLA.invoice_number is null
        and CCLA.order_number is not null
        and CCLA.order_number between l_start_id and l_end_id
        and exists

            (SELECT 1
             from cn_sca_headers_interface CSHI
             where CSHI.transaction_status = 'ADJUSTED'
             and CSHI.source_id = CCLA.order_number
             and CSHI.source_type = 'ORD');

    cursor sca_adjust_headers_ord_cur (l_start_id VARCHAR2, l_end_id VARCHAR2) IS

        select sca_headers_interface_id
        from cn_sca_headers_interface
        where source_type = 'ORD'
        and source_id in
           (select order_number
            from
               (select distinct(order_number) order_number from cn_comm_lines_api CCLA
                where trunc(CCLA.processed_date) between trunc(p_start_date) and trunc(p_end_date)
		        and CCLA.load_status = 'UNLOADED'
		        and (--(CCLA.adjust_status is null) or
                     (CCLA.adjust_status not in ('SCA_PENDING', 'SCA_ALLOCATED', 'SCA_NO_RULE', 'SCA_NOT_ALLOCATED',
                     'SCA_NOT_ELIGIBLE', 'REVERSAL', 'FROZEN')))
                and ((CCLA.trx_type = 'ORD') or (CCLA.trx_type = 'MAN'))
                and CCLA.line_number is not null
                and CCLA.invoice_number is null
                and CCLA.order_number is not null
                and CCLA.order_number between l_start_id and l_end_id)      SCA_SOURCE_ID

            where exists
            	(SELECT 1
             	 FROM cn_comm_lines_api CCLA_ORIG
             	 where CCLA_ORIG.adj_comm_lines_api_id in

                           (SELECT CSLI.source_trx_id
              	            from cn_sca_lines_interface CSLI, cn_sca_headers_interface CSHI
              			    where CSLI.sca_headers_interface_id = CSHI.sca_headers_interface_id
              			    and CSHI.source_id = SCA_SOURCE_ID.order_number
              			    and CSHI.source_type = 'ORD')

                  and ((CCLA_ORIG.adjust_status = 'FROZEN' and CCLA_ORIG.load_status = 'OBSOLETE'
			and (CCLA_ORIG.adjust_comments is null or CCLA_ORIG.adjust_comments <> 'SCA_ROLLBACK')) or
                       (CCLA_ORIG.load_status = 'LOADED' and exists

                            (select 1 from cn_comm_lines_api CCLA
                             where CCLA.adj_comm_lines_api_id = CCLA_ORIG.comm_lines_api_id
                             and CCLA.adjust_status = 'REVERSAL'
			     and (CCLA.adjust_comments is null or CCLA.adjust_comments <> 'SCA_ROLLBACK')
			)))));

    CURSOR sca_rollback_headers_ord_cur (start_id VARCHAR2, end_id VARCHAR2) IS

        select sca_headers_interface_id
        from cn_sca_headers_interface
        where ((transaction_status is null) or (transaction_status <> 'ADJUSTED'))
        and source_type = 'ORD'
        and source_id in

               (select distinct(order_number) order_number from cn_comm_lines_api CCLA
                where trunc(CCLA.processed_date) between trunc(p_start_date) and trunc(p_end_date)
		        and CCLA.load_status = 'UNLOADED'
		        and (--(CCLA.adjust_status is null) or
                     (CCLA.adjust_status not in ('SCA_PENDING', 'SCA_ALLOCATED', 'SCA_NO_RULE', 'SCA_NOT_ALLOCATED',
                      'SCA_NOT_ELIGIBLE', 'REVERSAL', 'FROZEN')))
                and ((CCLA.trx_type = 'ORD') or (CCLA.trx_type = 'MAN'))
                and CCLA.line_number is not null
                and CCLA.invoice_number is null
                and CCLA.order_number is not null
                and CCLA.order_number between l_start_id and l_end_id);

    CURSOR sca_rollback_lines_ord_cur (start_id VARCHAR2, end_id VARCHAR2) IS

        select CSLI.source_trx_id
        from cn_sca_headers_interface CSHI, cn_sca_lines_interface CSLI
        where CSHI.sca_headers_interface_id = CSLI.sca_headers_interface_id
        and ((CSHI.transaction_status is null) or (CSHI.transaction_status <> 'ADJUSTED'))
        and CSHI.source_type = 'ORD'
        and CSHI.source_id in

               (select distinct(order_number) order_number from cn_comm_lines_api CCLA
                where trunc(CCLA.processed_date) between trunc(p_start_date) and trunc(p_end_date)
		        and CCLA.load_status = 'UNLOADED'
		        and (--(CCLA.adjust_status is null) or
                     (CCLA.adjust_status not in ('SCA_PENDING', 'SCA_ALLOCATED', 'SCA_NO_RULE', 'SCA_NOT_ALLOCATED',
                      'SCA_NOT_ELIGIBLE', 'REVERSAL', 'FROZEN')))
                and ((CCLA.trx_type = 'ORD') or (CCLA.trx_type = 'MAN'))
                and CCLA.line_number is not null
                and CCLA.invoice_number is null
                and CCLA.order_number is not null
                and CCLA.order_number between l_start_id and l_end_id);

    TYPE sca_adjust_headers_tbl IS TABLE OF cn_sca_headers_interface.sca_headers_interface_id%TYPE;
    TYPE api_adjust_lines_tbl IS TABLE OF cn_comm_lines_api.comm_lines_api_id%TYPE;
    TYPE sca_rollback_lines_tbl IS TABLE OF cn_sca_lines_interface.source_trx_id%TYPE;
    TYPE sca_rollback_headers_tbl IS TABLE OF cn_sca_headers_interface.sca_headers_interface_id%TYPE;

    sca_adjust_headers      sca_adjust_headers_tbl;
    api_adjust_lines        api_adjust_lines_tbl;
    sca_rollback_lines      sca_rollback_lines_tbl;
    sca_rollback_headers    sca_rollback_headers_tbl;
    l_adjusted_by           VARCHAR2(30);

BEGIN

    l_adjusted_by := get_adjusted_by;

    select start_id, end_id, type into
           l_start_id, l_end_id, l_batch_type
    from cn_sca_process_batches
    where sca_process_batch_id = p_physical_batch_id;

    debugmsg('Check_comm_lines_api_adjusted : Check if the transactions are eligible for SCA');

     if (l_batch_type = 'INV') then

        OPEN sca_adjust_headers_inv_cur (l_start_id, l_end_id);
        FETCH sca_adjust_headers_inv_cur BULK COLLECT INTO sca_adjust_headers limit 1000;

     end if;

     if (l_batch_type = 'ORD') then

        OPEN sca_adjust_headers_ord_cur (l_start_id, l_end_id);
        FETCH sca_adjust_headers_ord_cur BULK COLLECT INTO sca_adjust_headers limit 1000;

     end if;

     FORALL j IN 1..sca_adjust_headers.COUNT

        UPDATE cn_sca_headers_interface
        SET transaction_status = 'ADJUSTED'
        WHERE sca_headers_interface_id = sca_adjust_headers(j);

    debugmsg('Check_comm_lines_api_adjusted : Update the adjust_status of transactions that are not eligible for SCA');

     if (l_batch_type = 'INV') then

        OPEN api_adjust_lines_inv_cur (l_start_id, l_end_id);
        FETCH api_adjust_lines_inv_cur BULK COLLECT INTO api_adjust_lines limit 1000;

        OPEN sca_rollback_headers_inv_cur (l_start_id, l_end_id);
        FETCH sca_rollback_headers_inv_cur BULK COLLECT INTO sca_rollback_headers limit 1000;

        OPEN sca_rollback_lines_inv_cur (l_start_id, l_end_id);
        FETCH sca_rollback_lines_inv_cur BULK COLLECT INTO sca_rollback_lines limit 1000;

    end if;

    if (l_batch_type = 'ORD') then

        OPEN api_adjust_lines_ord_cur (l_start_id, l_end_id);
        FETCH api_adjust_lines_ord_cur BULK COLLECT INTO api_adjust_lines limit 1000;

        OPEN sca_rollback_headers_ord_cur (l_start_id, l_end_id);
        FETCH sca_rollback_headers_ord_cur BULK COLLECT INTO sca_rollback_headers limit 1000;

        OPEN sca_rollback_lines_ord_cur (l_start_id, l_end_id);
        FETCH sca_rollback_lines_ord_cur BULK COLLECT INTO sca_rollback_lines limit 1000;

    end if;

    FORALL j IN 1..api_adjust_lines.COUNT

        UPDATE cn_comm_lines_api
        SET adjust_status       = 'SCA_NOT_ELIGIBLE',
            adjust_date   	    = sysdate,
		    adjusted_by   	    = l_adjusted_by,
		    adjust_comments 	= 'SCA Check'
        WHERE comm_lines_api_id = api_adjust_lines(j);

    debugmsg('Check_comm_lines_api_adjusted : Update the adjust_status of transactions that are not eligible for SCA');

    debugmsg('Check_comm_lines_api_adjusted : Roll back previous SCA results ');

    FORALL j IN 1..sca_rollback_lines.COUNT

        UPDATE cn_comm_lines_api API
        SET load_status 	= DECODE(API.load_status, 'UNLOADED', 'OBSOLETE', API.load_status),
		   adjust_status 	= NVL(DECODE(API.load_status, 'UNLOADED', 'FROZEN', API.adjust_status),'NEW'),
		   adjust_date   	= DECODE(API.load_status, 'UNLOADED', sysdate, API.adjust_date),
		   adjusted_by   	= DECODE(API.load_status, 'UNLOADED', l_adjusted_by, API.adjusted_by),
		   adjust_comments 	= DECODE(API.load_status, 'UNLOADED', 'SCA_ROLLBACK', API.adjust_comments)
        WHERE adj_comm_lines_api_id = sca_rollback_lines(j);

    debugmsg('Check_comm_lines_api_adjusted : Obsoleting unloaded transactions that have been created for previous SCA results');

    FORALL j IN 1..sca_rollback_lines.COUNT

    INSERT into CN_COMM_LINES_API
      ( SALESREP_ID,
        PROCESSED_DATE,
        PROCESSED_PERIOD_ID,
        TRANSACTION_AMOUNT,
        TRX_TYPE,
        REVENUE_CLASS_ID,
        LOAD_STATUS,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        ATTRIBUTE16,
        ATTRIBUTE17,
        ATTRIBUTE18,
        ATTRIBUTE19,
        ATTRIBUTE20,
        ATTRIBUTE21,
        ATTRIBUTE22,
        ATTRIBUTE23,
        ATTRIBUTE24,
        ATTRIBUTE25,
        ATTRIBUTE26,
        ATTRIBUTE27,
        ATTRIBUTE28,
        ATTRIBUTE29,
        ATTRIBUTE30,
        ATTRIBUTE31,
        ATTRIBUTE32,
        ATTRIBUTE33,
        ATTRIBUTE34,
        ATTRIBUTE35,
        ATTRIBUTE36,
        ATTRIBUTE37,
        ATTRIBUTE38,
        ATTRIBUTE39,
        ATTRIBUTE40,
        ATTRIBUTE41,
        ATTRIBUTE42,
        ATTRIBUTE43,
        ATTRIBUTE44,
        ATTRIBUTE45,
        ATTRIBUTE46,
        ATTRIBUTE47,
        ATTRIBUTE48,
        ATTRIBUTE49,
        ATTRIBUTE50,
        ATTRIBUTE51,
        ATTRIBUTE52,
        ATTRIBUTE53,
        ATTRIBUTE54,
        ATTRIBUTE55,
        ATTRIBUTE56,
        ATTRIBUTE57,
        ATTRIBUTE58,
        ATTRIBUTE59,
        ATTRIBUTE60,
        ATTRIBUTE61,
        ATTRIBUTE62,
        ATTRIBUTE63,
        ATTRIBUTE64,
        ATTRIBUTE65,
        ATTRIBUTE66,
        ATTRIBUTE67,
        ATTRIBUTE68,
        ATTRIBUTE69,
        ATTRIBUTE70,
        ATTRIBUTE71,
        ATTRIBUTE72,
        ATTRIBUTE73,
        ATTRIBUTE74,
        ATTRIBUTE75,
        ATTRIBUTE76,
        ATTRIBUTE77,
        ATTRIBUTE78,
        ATTRIBUTE79,
        ATTRIBUTE80,
        ATTRIBUTE81,
        ATTRIBUTE82,
        ATTRIBUTE83,
        ATTRIBUTE84,
        ATTRIBUTE85,
        ATTRIBUTE86,
        ATTRIBUTE87,
        ATTRIBUTE88,
        ATTRIBUTE89,
        ATTRIBUTE90,
        ATTRIBUTE91,
        ATTRIBUTE92,
        ATTRIBUTE93,
        ATTRIBUTE94,
        ATTRIBUTE95,
        ATTRIBUTE96,
        ATTRIBUTE97,
        ATTRIBUTE98,
        ATTRIBUTE99,
        ATTRIBUTE100,
        COMM_LINES_API_ID,
        CONC_BATCH_ID,
        PROCESS_BATCH_ID,
        SALESREP_NUMBER,
        ROLLUP_DATE,
        SOURCE_DOC_ID,
        SOURCE_DOC_TYPE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        TRANSACTION_CURRENCY_CODE,
        EXCHANGE_RATE,
        ACCTD_TRANSACTION_AMOUNT,
        TRX_ID,
        TRX_LINE_ID,
        TRX_SALES_LINE_ID,
        QUANTITY,
        SOURCE_TRX_NUMBER,
        DISCOUNT_PERCENTAGE,
        MARGIN_PERCENTAGE,
        SOURCE_TRX_ID,
        SOURCE_TRX_LINE_ID,
        SOURCE_TRX_SALES_LINE_ID,
        NEGATED_FLAG,
        CUSTOMER_ID,
        INVENTORY_ITEM_ID,
        ORDER_NUMBER,
        BOOKED_DATE,
        INVOICE_NUMBER,
        INVOICE_DATE,
        ADJUST_DATE,
        ADJUSTED_BY,
        REVENUE_TYPE,
        ADJUST_ROLLUP_FLAG,
        ADJUST_COMMENTS,
        ADJUST_STATUS,
        LINE_NUMBER,
        BILL_TO_ADDRESS_ID,
        SHIP_TO_ADDRESS_ID,
        BILL_TO_CONTACT_ID,
        SHIP_TO_CONTACT_ID,
        ADJ_COMM_LINES_API_ID,
        PRE_DEFINED_RC_FLAG,
        ROLLUP_FLAG,
        FORECAST_ID,
        UPSIDE_QUANTITY,
        UPSIDE_AMOUNT,
        UOM_CODE,
        REASON_CODE,
        TYPE,
        PRE_PROCESSED_CODE,
        QUOTA_ID,
        SRP_PLAN_ASSIGN_ID,
        ROLE_ID,
        COMP_GROUP_ID,
        COMMISSION_AMOUNT,
        EMPLOYEE_NUMBER,
        REVERSAL_FLAG,
        REVERSAL_HEADER_ID,
        SALES_CHANNEL,
        OBJECT_VERSION_NUMBER,
        SPLIT_PCT,
      SPLIT_status,
      org_id)

    (select
        CCH.DIRECT_SALESREP_ID,
        CCH.PROCESSED_DATE,
        CCH.PROCESSED_PERIOD_ID,
        -1 * NVL(CCH.TRANSACTION_AMOUNT_ORIG, 0),
        CCH.TRX_TYPE,
        CCH.REVENUE_CLASS_ID,
        'UNLOADED',
        CCH.ATTRIBUTE_CATEGORY,
        CCH.ATTRIBUTE1,
        CCH.ATTRIBUTE2,
        CCH.ATTRIBUTE3,
        CCH.ATTRIBUTE4,
        CCH.ATTRIBUTE5,
        CCH.ATTRIBUTE6,
        CCH.ATTRIBUTE7,
        CCH.ATTRIBUTE8,
        CCH.ATTRIBUTE9,
        CCH.ATTRIBUTE10,
        CCH.ATTRIBUTE11,
        CCH.ATTRIBUTE12,
        CCH.ATTRIBUTE13,
        CCH.ATTRIBUTE14,
        CCH.ATTRIBUTE15,
        CCH.ATTRIBUTE16,
        CCH.ATTRIBUTE17,
        CCH.ATTRIBUTE18,
        CCH.ATTRIBUTE19,
        CCH.ATTRIBUTE20,
        CCH.ATTRIBUTE21,
        CCH.ATTRIBUTE22,
        CCH.ATTRIBUTE23,
        CCH.ATTRIBUTE24,
        CCH.ATTRIBUTE25,
        CCH.ATTRIBUTE26,
        CCH.ATTRIBUTE27,
        CCH.ATTRIBUTE28,
        CCH.ATTRIBUTE29,
        CCH.ATTRIBUTE30,
        CCH.ATTRIBUTE31,
        CCH.ATTRIBUTE32,
        CCH.ATTRIBUTE33,
        CCH.ATTRIBUTE34,
        CCH.ATTRIBUTE35,
        CCH.ATTRIBUTE36,
        CCH.ATTRIBUTE37,
        CCH.ATTRIBUTE38,
        CCH.ATTRIBUTE39,
        CCH.ATTRIBUTE40,
        CCH.ATTRIBUTE41,
        CCH.ATTRIBUTE42,
        CCH.ATTRIBUTE43,
        CCH.ATTRIBUTE44,
        CCH.ATTRIBUTE45,
        CCH.ATTRIBUTE46,
        CCH.ATTRIBUTE47,
        CCH.ATTRIBUTE48,
        CCH.ATTRIBUTE49,
        CCH.ATTRIBUTE50,
        CCH.ATTRIBUTE51,
        CCH.ATTRIBUTE52,
        CCH.ATTRIBUTE53,
        CCH.ATTRIBUTE54,
        CCH.ATTRIBUTE55,
        CCH.ATTRIBUTE56,
        CCH.ATTRIBUTE57,
        CCH.ATTRIBUTE58,
        CCH.ATTRIBUTE59,
        CCH.ATTRIBUTE60,
        CCH.ATTRIBUTE61,
        CCH.ATTRIBUTE62,
        CCH.ATTRIBUTE63,
        CCH.ATTRIBUTE64,
        CCH.ATTRIBUTE65,
        CCH.ATTRIBUTE66,
        CCH.ATTRIBUTE67,
        CCH.ATTRIBUTE68,
        CCH.ATTRIBUTE69,
        CCH.ATTRIBUTE70,
        CCH.ATTRIBUTE71,
        CCH.ATTRIBUTE72,
        CCH.ATTRIBUTE73,
        CCH.ATTRIBUTE74,
        CCH.ATTRIBUTE75,
        CCH.ATTRIBUTE76,
        CCH.ATTRIBUTE77,
        CCH.ATTRIBUTE78,
        CCH.ATTRIBUTE79,
        CCH.ATTRIBUTE80,
        CCH.ATTRIBUTE81,
        CCH.ATTRIBUTE82,
        CCH.ATTRIBUTE83,
        CCH.ATTRIBUTE84,
        CCH.ATTRIBUTE85,
        CCH.ATTRIBUTE86,
        CCH.ATTRIBUTE87,
        CCH.ATTRIBUTE88,
        CCH.ATTRIBUTE89,
        CCH.ATTRIBUTE90,
        CCH.ATTRIBUTE91,
        CCH.ATTRIBUTE92,
        CCH.ATTRIBUTE93,
        CCH.ATTRIBUTE94,
        CCH.ATTRIBUTE95,
        CCH.ATTRIBUTE96,
        CCH.ATTRIBUTE97,
        CCH.ATTRIBUTE98,
        CCH.ATTRIBUTE99,
        CCH.ATTRIBUTE100,
        cn_comm_lines_api_s.NEXTVAL,
        NULL,
        NULL,
        NULL,
        CCH.ROLLUP_DATE,
        NULL,
        CCH.SOURCE_DOC_TYPE,
        fnd_global.user_id,
        Sysdate,
        fnd_global.user_id,
        Sysdate,
        fnd_global.login_id,
        CCH.ORIG_CURRENCY_CODE,
        CCH.EXCHANGE_RATE,
        -1 * NVL(CCH.TRANSACTION_AMOUNT, 0),
        NULL,  -- CCH.TRX_ID,
        NULL,  -- CCH.TRX_LINE_ID,
        NULL,  -- CCH.TRX_SALES_LINE_ID,
        -1 * CCH.QUANTITY,
        CCH.SOURCE_TRX_NUMBER,
        CCH.DISCOUNT_PERCENTAGE,
        CCH.MARGIN_PERCENTAGE,
        CCH.SOURCE_TRX_ID,
        CCH.SOURCE_TRX_LINE_ID,
        CCH.SOURCE_TRX_SALES_LINE_ID,
        'Y',
        CCH.CUSTOMER_ID,
        CCH.INVENTORY_ITEM_ID,
        CCH.ORDER_NUMBER,
        CCH.BOOKED_DATE,
        CCH.INVOICE_NUMBER,
        CCH.INVOICE_DATE,
        SYSDATE,
        l_adjusted_by,
        CCH.REVENUE_TYPE,
        CCH.ADJUST_ROLLUP_FLAG,
        'SCA_ROLLBACK',
        'REVERSAL',
        CCH.LINE_NUMBER,
        CCH.BILL_TO_ADDRESS_ID,
        CCH.SHIP_TO_ADDRESS_ID,
        CCH.BILL_TO_CONTACT_ID,
        CCH.SHIP_TO_CONTACT_ID,
        CCH.COMM_LINES_API_ID,
        NULL, -- CCH.PRE_DEFINED_RC_FLAG,
        NULL, -- CCH.ROLLUP_FLAG,
        CCH.FORECAST_ID,
        CCH.UPSIDE_QUANTITY,
        CCH.UPSIDE_AMOUNT,
        CCH.UOM_CODE,
        CCH.REASON_CODE,
        CCH.TYPE,
        CCH.PRE_PROCESSED_CODE,
        CCH.QUOTA_ID,
        CCH.SRP_PLAN_ASSIGN_ID,
        CCH.ROLE_ID,
        CCH.COMP_GROUP_ID,
        CCH.COMMISSION_AMOUNT,
        CS.EMPLOYEE_NUMBER,
        'Y',
        CCH.COMMISSION_HEADER_ID,
        CCH.SALES_CHANNEL,
        CCH.OBJECT_VERSION_NUMBER,
        CCH.SPLIT_PCT,
        CCH.SPLIT_status,
        cch.org_id
    FROM cn_commission_headers CCH, cn_salesreps CS
    WHERE CCH.adj_comm_lines_api_id = sca_rollback_lines(j)
    AND CS.salesrep_id = CCH.direct_salesrep_id
    AND (--(CCH.adjust_status IS NULL) or
 (CCH.adjust_status <> 'FROZEN')));

    debugmsg('Check_comm_lines_api_adjusted : Creating reversals for loaded transactions that have been created for previous SCA results');

    FORALL j IN 1..sca_rollback_lines.COUNT

        UPDATE cn_commission_headers CSH
        SET adjust_status 	= 'FROZEN',
           reversal_header_id 	= CSH.commission_header_id,
		   reversal_flag 	= 'Y',
		   adjust_date   	= sysdate,
		   adjusted_by   	= l_adjusted_by,
		   adjust_comments 	= 'SCA_ROLLBACK'
        WHERE adj_comm_lines_api_id = sca_rollback_lines(j)
        AND (--(adjust_status IS NULL) or
(adjust_status <> 'FROZEN'));

    debugmsg('Check_comm_lines_api_adjusted : Obsoleting loaded transactions that have been created for previous SCA results');

    FORALL j IN 1..sca_rollback_lines.COUNT

        UPDATE cn_comm_lines_api
        SET adjust_status       = 'NEW', --NULL,
            load_status         = 'UNLOADED',
            adjust_date   	    = sysdate,
		    adjusted_by   	    = l_adjusted_by,
		    adjust_comments 	= 'SCA_ROLLBACK'
        WHERE comm_lines_api_id = sca_rollback_lines(j);

    debugmsg('Check_comm_lines_api_adjusted : Set the original transactions back to active');

    FORALL j IN 1..sca_rollback_headers.COUNT

        DELETE FROM cn_sca_lines_interface
        WHERE sca_headers_interface_id = sca_rollback_headers(j);

    FORALL j IN 1..sca_rollback_headers.COUNT

        DELETE FROM cn_sca_lines_output
        WHERE sca_headers_interface_id = sca_rollback_headers(j);

    FORALL j IN 1..sca_rollback_headers.COUNT

        DELETE FROM cn_sca_headers_interface
        WHERE sca_headers_interface_id = sca_rollback_headers(j);

    debugmsg('Check_comm_lines_api_adjusted : Removing records from SCA headers, lines and output table');
    debugmsg('Check_comm_lines_api_adjusted : End of checking if transactions are eligible for SCA');

EXCEPTION

        WHEN OTHERS THEN

        debugmsg('Check_comm_lines_api_adjusted : Checking if transactions are eligible for SCA : Unexpected exception');
        debugmsg('Check_comm_lines_api_adjusted : End of checking if transactions are eligible for SCA');

        conc_status := fnd_concurrent.set_completion_status(
			status 	=> 'ERROR',
            message => '');

	    RAISE;

end check_api_adjusted;


Procedure   check_adjusted (
                p_start_date           DATE,
                p_end_date             DATE,
                p_physical_batch_id    NUMBER)   IS

    cursor sca_headers_adjust_cur (l_trx_type VARCHAR2, l_start_id VARCHAR2, l_end_id VARCHAR2) IS

        select sca_headers_interface_id
        from cn_sca_headers_interface
        where source_type = l_trx_type
        and source_id in
           (select source_id
            from
               (select distinct(source_id) source_id
                from cn_sca_headers_interface
                where source_type = l_trx_type
                and trunc(processed_date) between trunc(p_start_date) and trunc(p_end_date)
                and ((transaction_status is null) or (transaction_status <> 'ADJUSTED'))
                and source_id between l_start_id and l_end_id)      SCA_SOURCE_ID

            where exists
            	(SELECT 1
             	 FROM cn_comm_lines_api CCLA_ORIG
             	 where CCLA_ORIG.adj_comm_lines_api_id in

                           (SELECT CSLI.source_trx_id
              	            from cn_sca_lines_interface CSLI, cn_sca_headers_interface CSHI
              			    where CSLI.sca_headers_interface_id = CSHI.sca_headers_interface_id
              			    and CSHI.source_id = SCA_SOURCE_ID.source_id
              			    and CSHI.source_type = l_trx_type)

                  and ((CCLA_ORIG.adjust_status = 'FROZEN' and CCLA_ORIG.load_status = 'OBSOLETE'
                        and (CCLA_ORIG.adjust_comments is null or CCLA_ORIG.adjust_comments <> 'SCA_ROLLBACK')) or
                       (CCLA_ORIG.load_status = 'LOADED' and exists

                            (select 1 from cn_comm_lines_api CCLA
                             where CCLA.adj_comm_lines_api_id = CCLA_ORIG.comm_lines_api_id
                             and CCLA.adjust_status = 'REVERSAL'
			     and (CCLA.adjust_comments is null or CCLA.adjust_comments <> 'SCA_ROLLBACK')
			)))));


    cursor sca_headers_rollback_cur (l_trx_type VARCHAR2, l_start_id VARCHAR2, l_end_id VARCHAR2) IS

        select sca_headers_interface_id
        from cn_sca_headers_interface
        where source_type = l_trx_type
        and trunc(processed_date) between trunc(p_start_date) and trunc(p_end_date)
        and ((transaction_status is null) or (transaction_status <> 'ADJUSTED'))
        and source_id between l_start_id and l_end_id;

    cursor sca_lines_rollback_cur (l_trx_type VARCHAR2, l_start_id VARCHAR2, l_end_id VARCHAR2) IS

        select CSLI.source_trx_id
        from cn_sca_headers_interface CSHI, cn_sca_lines_interface CSLI
        where CSHI.source_type = l_trx_type
        and trunc(CSHI.processed_date) between trunc(p_start_date) and trunc(p_end_date)
        and ((CSHI.transaction_status is null) or (CSHI.transaction_status <> 'ADJUSTED'))
        and CSHI.source_id between l_start_id and l_end_id
        and CSHI.sca_headers_interface_id = CSLI.sca_headers_interface_id;


    TYPE sca_headers_adjust_tbl IS TABLE OF cn_sca_headers_interface.sca_headers_interface_id%TYPE;
    TYPE sca_headers_rollback_tbl IS TABLE OF cn_sca_headers_interface.sca_headers_interface_id%TYPE;
    TYPE sca_lines_rollback_tbl IS TABLE OF cn_sca_lines_interface.source_trx_id%TYPE;

    sca_headers_adjust      sca_headers_adjust_tbl;
    sca_headers_rollback    sca_headers_rollback_tbl;
    sca_lines_rollback      sca_lines_rollback_tbl;

    l_sql_stmt      VARCHAR2(1000);
    l_trx_type      VARCHAR2(10);

    l_batch_type    cn_sca_process_batches.type%TYPE;
    l_start_id      cn_sca_process_batches.start_id%TYPE;
    l_end_id        cn_sca_process_batches.end_id%TYPE;
    l_source_id     cn_sca_headers_interface.source_id%TYPE;

    l_adjusted_by                       VARCHAR2(30);
    conc_status boolean;

BEGIN

    l_adjusted_by := get_adjusted_by;

    select start_id, end_id, type into
           l_start_id, l_end_id, l_batch_type
    from cn_sca_process_batches
    where sca_process_batch_id = p_physical_batch_id;

    if (l_batch_type = 'SCA_ORD') then

        l_batch_type := 'ORD';

    end if;

    if (l_batch_type = 'SCA_INV') then

        l_batch_type := 'INV';

    end if;

    debugmsg('Allocation Transfer : Start of checking if headers can be rerun ');
    debugmsg('Allocation Transfer : Rerun : Batch Type = ' || l_batch_type);

    OPEN sca_headers_adjust_cur (l_batch_type, l_start_id, l_end_id);
    FETCH sca_headers_adjust_cur BULK COLLECT INTO sca_headers_adjust limit 1000;

    debugmsg('Allocation Transfer : Rerun : Mark those headers that have been populated and adjusted');

    FORALL j IN 1..sca_headers_adjust.COUNT

       UPDATE cn_sca_headers_interface
       SET transaction_status = 'ADJUSTED'
	   WHERE sca_headers_interface_id  = sca_headers_adjust(j);

    OPEN sca_headers_rollback_cur (l_batch_type, l_start_id, l_end_id);
    FETCH sca_headers_rollback_cur BULK COLLECT INTO sca_headers_rollback limit 1000;

    OPEN sca_lines_rollback_cur (l_batch_type, l_start_id, l_end_id);
    FETCH sca_lines_rollback_cur BULK COLLECT INTO sca_lines_rollback limit 1000;

    debugmsg('Allocation Transfer : Rerun : Obsoleting unloaded transactions that have been created for previous SCA results');

    FORALL j IN 1..sca_lines_rollback.COUNT

        UPDATE cn_comm_lines_api API
        SET load_status 	= DECODE(API.load_status, 'UNLOADED', 'OBSOLETE', API.load_status),
		   adjust_status 	= NVL(DECODE(API.load_status, 'UNLOADED', 'FROZEN', API.adjust_status),'NEW'),
		   adjust_date   	= DECODE(API.load_status, 'UNLOADED', sysdate, API.adjust_date),
		   adjusted_by   	= DECODE(API.load_status, 'UNLOADED', l_adjusted_by, API.adjusted_by),
		   adjust_comments 	= DECODE(API.load_status, 'UNLOADED', 'SCA_ROLLBACK', API.adjust_comments)
        WHERE adj_comm_lines_api_id = sca_lines_rollback(j);

    debugmsg('Allocation Transfer : Rerun : Creating reversals for loaded transactions that have been created for previous SCA results');

    FORALL j IN 1..sca_lines_rollback.COUNT

    INSERT into CN_COMM_LINES_API
      ( SALESREP_ID,
        PROCESSED_DATE,
        PROCESSED_PERIOD_ID,
        TRANSACTION_AMOUNT,
        TRX_TYPE,
        REVENUE_CLASS_ID,
        LOAD_STATUS,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        ATTRIBUTE16,
        ATTRIBUTE17,
        ATTRIBUTE18,
        ATTRIBUTE19,
        ATTRIBUTE20,
        ATTRIBUTE21,
        ATTRIBUTE22,
        ATTRIBUTE23,
        ATTRIBUTE24,
        ATTRIBUTE25,
        ATTRIBUTE26,
        ATTRIBUTE27,
        ATTRIBUTE28,
        ATTRIBUTE29,
        ATTRIBUTE30,
        ATTRIBUTE31,
        ATTRIBUTE32,
        ATTRIBUTE33,
        ATTRIBUTE34,
        ATTRIBUTE35,
        ATTRIBUTE36,
        ATTRIBUTE37,
        ATTRIBUTE38,
        ATTRIBUTE39,
        ATTRIBUTE40,
        ATTRIBUTE41,
        ATTRIBUTE42,
        ATTRIBUTE43,
        ATTRIBUTE44,
        ATTRIBUTE45,
        ATTRIBUTE46,
        ATTRIBUTE47,
        ATTRIBUTE48,
        ATTRIBUTE49,
        ATTRIBUTE50,
        ATTRIBUTE51,
        ATTRIBUTE52,
        ATTRIBUTE53,
        ATTRIBUTE54,
        ATTRIBUTE55,
        ATTRIBUTE56,
        ATTRIBUTE57,
        ATTRIBUTE58,
        ATTRIBUTE59,
        ATTRIBUTE60,
        ATTRIBUTE61,
        ATTRIBUTE62,
        ATTRIBUTE63,
        ATTRIBUTE64,
        ATTRIBUTE65,
        ATTRIBUTE66,
        ATTRIBUTE67,
        ATTRIBUTE68,
        ATTRIBUTE69,
        ATTRIBUTE70,
        ATTRIBUTE71,
        ATTRIBUTE72,
        ATTRIBUTE73,
        ATTRIBUTE74,
        ATTRIBUTE75,
        ATTRIBUTE76,
        ATTRIBUTE77,
        ATTRIBUTE78,
        ATTRIBUTE79,
        ATTRIBUTE80,
        ATTRIBUTE81,
        ATTRIBUTE82,
        ATTRIBUTE83,
        ATTRIBUTE84,
        ATTRIBUTE85,
        ATTRIBUTE86,
        ATTRIBUTE87,
        ATTRIBUTE88,
        ATTRIBUTE89,
        ATTRIBUTE90,
        ATTRIBUTE91,
        ATTRIBUTE92,
        ATTRIBUTE93,
        ATTRIBUTE94,
        ATTRIBUTE95,
        ATTRIBUTE96,
        ATTRIBUTE97,
        ATTRIBUTE98,
        ATTRIBUTE99,
        ATTRIBUTE100,
        COMM_LINES_API_ID,
        CONC_BATCH_ID,
        PROCESS_BATCH_ID,
        SALESREP_NUMBER,
        ROLLUP_DATE,
        SOURCE_DOC_ID,
        SOURCE_DOC_TYPE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        TRANSACTION_CURRENCY_CODE,
        EXCHANGE_RATE,
        ACCTD_TRANSACTION_AMOUNT,
        TRX_ID,
        TRX_LINE_ID,
        TRX_SALES_LINE_ID,
        QUANTITY,
        SOURCE_TRX_NUMBER,
        DISCOUNT_PERCENTAGE,
        MARGIN_PERCENTAGE,
        SOURCE_TRX_ID,
        SOURCE_TRX_LINE_ID,
        SOURCE_TRX_SALES_LINE_ID,
        NEGATED_FLAG,
        CUSTOMER_ID,
        INVENTORY_ITEM_ID,
        ORDER_NUMBER,
        BOOKED_DATE,
        INVOICE_NUMBER,
        INVOICE_DATE,
        ADJUST_DATE,
        ADJUSTED_BY,
        REVENUE_TYPE,
        ADJUST_ROLLUP_FLAG,
        ADJUST_COMMENTS,
        ADJUST_STATUS,
        LINE_NUMBER,
        BILL_TO_ADDRESS_ID,
        SHIP_TO_ADDRESS_ID,
        BILL_TO_CONTACT_ID,
        SHIP_TO_CONTACT_ID,
        ADJ_COMM_LINES_API_ID,
        PRE_DEFINED_RC_FLAG,
        ROLLUP_FLAG,
        FORECAST_ID,
        UPSIDE_QUANTITY,
        UPSIDE_AMOUNT,
        UOM_CODE,
        REASON_CODE,
        TYPE,
        PRE_PROCESSED_CODE,
        QUOTA_ID,
        SRP_PLAN_ASSIGN_ID,
        ROLE_ID,
        COMP_GROUP_ID,
        COMMISSION_AMOUNT,
        EMPLOYEE_NUMBER,
        REVERSAL_FLAG,
        REVERSAL_HEADER_ID,
        SALES_CHANNEL,
        OBJECT_VERSION_NUMBER,
        SPLIT_PCT,
      SPLIT_status,
      org_id)

    (select
        CCH.DIRECT_SALESREP_ID,
        CCH.PROCESSED_DATE,
        CCH.PROCESSED_PERIOD_ID,
        -1 * NVL(CCH.TRANSACTION_AMOUNT_ORIG, 0),
        CCH.TRX_TYPE,
        CCH.REVENUE_CLASS_ID,
        'UNLOADED',
        CCH.ATTRIBUTE_CATEGORY,
        CCH.ATTRIBUTE1,
        CCH.ATTRIBUTE2,
        CCH.ATTRIBUTE3,
        CCH.ATTRIBUTE4,
        CCH.ATTRIBUTE5,
        CCH.ATTRIBUTE6,
        CCH.ATTRIBUTE7,
        CCH.ATTRIBUTE8,
        CCH.ATTRIBUTE9,
        CCH.ATTRIBUTE10,
        CCH.ATTRIBUTE11,
        CCH.ATTRIBUTE12,
        CCH.ATTRIBUTE13,
        CCH.ATTRIBUTE14,
        CCH.ATTRIBUTE15,
        CCH.ATTRIBUTE16,
        CCH.ATTRIBUTE17,
        CCH.ATTRIBUTE18,
        CCH.ATTRIBUTE19,
        CCH.ATTRIBUTE20,
        CCH.ATTRIBUTE21,
        CCH.ATTRIBUTE22,
        CCH.ATTRIBUTE23,
        CCH.ATTRIBUTE24,
        CCH.ATTRIBUTE25,
        CCH.ATTRIBUTE26,
        CCH.ATTRIBUTE27,
        CCH.ATTRIBUTE28,
        CCH.ATTRIBUTE29,
        CCH.ATTRIBUTE30,
        CCH.ATTRIBUTE31,
        CCH.ATTRIBUTE32,
        CCH.ATTRIBUTE33,
        CCH.ATTRIBUTE34,
        CCH.ATTRIBUTE35,
        CCH.ATTRIBUTE36,
        CCH.ATTRIBUTE37,
        CCH.ATTRIBUTE38,
        CCH.ATTRIBUTE39,
        CCH.ATTRIBUTE40,
        CCH.ATTRIBUTE41,
        CCH.ATTRIBUTE42,
        CCH.ATTRIBUTE43,
        CCH.ATTRIBUTE44,
        CCH.ATTRIBUTE45,
        CCH.ATTRIBUTE46,
        CCH.ATTRIBUTE47,
        CCH.ATTRIBUTE48,
        CCH.ATTRIBUTE49,
        CCH.ATTRIBUTE50,
        CCH.ATTRIBUTE51,
        CCH.ATTRIBUTE52,
        CCH.ATTRIBUTE53,
        CCH.ATTRIBUTE54,
        CCH.ATTRIBUTE55,
        CCH.ATTRIBUTE56,
        CCH.ATTRIBUTE57,
        CCH.ATTRIBUTE58,
        CCH.ATTRIBUTE59,
        CCH.ATTRIBUTE60,
        CCH.ATTRIBUTE61,
        CCH.ATTRIBUTE62,
        CCH.ATTRIBUTE63,
        CCH.ATTRIBUTE64,
        CCH.ATTRIBUTE65,
        CCH.ATTRIBUTE66,
        CCH.ATTRIBUTE67,
        CCH.ATTRIBUTE68,
        CCH.ATTRIBUTE69,
        CCH.ATTRIBUTE70,
        CCH.ATTRIBUTE71,
        CCH.ATTRIBUTE72,
        CCH.ATTRIBUTE73,
        CCH.ATTRIBUTE74,
        CCH.ATTRIBUTE75,
        CCH.ATTRIBUTE76,
        CCH.ATTRIBUTE77,
        CCH.ATTRIBUTE78,
        CCH.ATTRIBUTE79,
        CCH.ATTRIBUTE80,
        CCH.ATTRIBUTE81,
        CCH.ATTRIBUTE82,
        CCH.ATTRIBUTE83,
        CCH.ATTRIBUTE84,
        CCH.ATTRIBUTE85,
        CCH.ATTRIBUTE86,
        CCH.ATTRIBUTE87,
        CCH.ATTRIBUTE88,
        CCH.ATTRIBUTE89,
        CCH.ATTRIBUTE90,
        CCH.ATTRIBUTE91,
        CCH.ATTRIBUTE92,
        CCH.ATTRIBUTE93,
        CCH.ATTRIBUTE94,
        CCH.ATTRIBUTE95,
        CCH.ATTRIBUTE96,
        CCH.ATTRIBUTE97,
        CCH.ATTRIBUTE98,
        CCH.ATTRIBUTE99,
        CCH.ATTRIBUTE100,
        cn_comm_lines_api_s.NEXTVAL,
        NULL,
        NULL,
        NULL,
        CCH.ROLLUP_DATE,
        NULL,
        CCH.SOURCE_DOC_TYPE,
        fnd_global.user_id,
        Sysdate,
        fnd_global.user_id,
        Sysdate,
        fnd_global.login_id,
        CCH.ORIG_CURRENCY_CODE,
        CCH.EXCHANGE_RATE,
        -1 * NVL(CCH.TRANSACTION_AMOUNT, 0),
        NULL,  -- CCH.TRX_ID,
        NULL,  -- CCH.TRX_LINE_ID,
        NULL,  -- CCH.TRX_SALES_LINE_ID,
        -1 * CCH.QUANTITY,
        CCH.SOURCE_TRX_NUMBER,
        CCH.DISCOUNT_PERCENTAGE,
        CCH.MARGIN_PERCENTAGE,
        CCH.SOURCE_TRX_ID,
        CCH.SOURCE_TRX_LINE_ID,
        CCH.SOURCE_TRX_SALES_LINE_ID,
        'Y',
        CCH.CUSTOMER_ID,
        CCH.INVENTORY_ITEM_ID,
        CCH.ORDER_NUMBER,
        CCH.BOOKED_DATE,
        CCH.INVOICE_NUMBER,
        CCH.INVOICE_DATE,
        SYSDATE,
        l_adjusted_by,
        CCH.REVENUE_TYPE,
        CCH.ADJUST_ROLLUP_FLAG,
        'SCA_ROLLBACK',
        'REVERSAL',
        CCH.LINE_NUMBER,
        CCH.BILL_TO_ADDRESS_ID,
        CCH.SHIP_TO_ADDRESS_ID,
        CCH.BILL_TO_CONTACT_ID,
        CCH.SHIP_TO_CONTACT_ID,
        CCH.COMM_LINES_API_ID,
        NULL, -- CCH.PRE_DEFINED_RC_FLAG,
        NULL, -- CCH.ROLLUP_FLAG,
        CCH.FORECAST_ID,
        CCH.UPSIDE_QUANTITY,
        CCH.UPSIDE_AMOUNT,
        CCH.UOM_CODE,
        CCH.REASON_CODE,
        CCH.TYPE,
        CCH.PRE_PROCESSED_CODE,
        CCH.QUOTA_ID,
        CCH.SRP_PLAN_ASSIGN_ID,
        CCH.ROLE_ID,
        CCH.COMP_GROUP_ID,
        CCH.COMMISSION_AMOUNT,
        CS.EMPLOYEE_NUMBER,
        'Y',
        CCH.COMMISSION_HEADER_ID,
        CCH.SALES_CHANNEL,
        CCH.OBJECT_VERSION_NUMBER,
        CCH.SPLIT_PCT,
      CCH.SPLIT_status,
      cch.org_id
    FROM cn_commission_headers CCH, cn_salesreps CS
    WHERE CCH.adj_comm_lines_api_id = sca_lines_rollback(j)
    AND CS.salesrep_id = CCH.direct_salesrep_id
    AND (--(CCH.adjust_status IS NULL) or
(CCH.adjust_status <> 'FROZEN')));

    debugmsg('Allocation Transfer : Rerun : Obsoleting loaded transactions that have been created for previous SCA results');

    FORALL j IN 1..sca_lines_rollback.COUNT

        UPDATE cn_commission_headers CSH
        SET adjust_status 	= 'FROZEN',
           reversal_header_id 	= CSH.commission_header_id,
		   reversal_flag 	= 'Y',
		   adjust_date   	= sysdate,
		   adjusted_by   	= l_adjusted_by,
		   adjust_comments 	= 'SCA_ROLLBACK'
        WHERE adj_comm_lines_api_id = sca_lines_rollback(j)
        AND (--(adjust_status IS NULL) or
 (adjust_status <> 'FROZEN'));

    debugmsg('Allocation Transfer : Rerun : Obsoleting loaded transactions that have been created for previous error SCA results');

    FORALL j IN 1..sca_lines_rollback.COUNT

        UPDATE cn_comm_lines_api api
        SET load_status 		= 'UNLOADED',
		   adjust_status 	    = 'NEW', --NULL,
		   adjust_date   	    = sysdate,
		   adjusted_by   	    = l_adjusted_by,
		   adjust_comments 	      = 'SCA_ROLLBACK'
	     WHERE comm_lines_api_id  = sca_lines_rollback(j);

    debugmsg('Allocation Transfer : Rerun : Deleting all headers and lines for previous SCA');

    FORALL j IN 1..sca_headers_rollback.COUNT

        DELETE FROM cn_sca_lines_output
        where sca_headers_interface_id = sca_headers_rollback(j);

    FORALL j IN 1..sca_headers_rollback.COUNT

        DELETE FROM cn_sca_lines_interface
        where sca_headers_interface_id = sca_headers_rollback(j);

    FORALL j IN 1..sca_headers_rollback.COUNT

        DELETE FROM cn_sca_headers_interface
        WHERE sca_headers_interface_id = sca_headers_rollback(j);

    debugmsg('Allocation Transfer : Rerun : End');

EXCEPTION

        WHEN OTHERS THEN

        debugmsg('Allocation Transfer : Rerun : Unexpected exception');
        debugmsg('Allocation Transfer : Rerun : End');

        conc_status := fnd_concurrent.set_completion_status(
			status 	=> 'ERROR',
            message => '');

	    RAISE;

END check_adjusted;


--+ Procedure Name
--+   Assign
--+ Purpose : Split the logical batch into smaller physical batches
--+           populate the physical_batch_id in cn_process_batches


 PROCEDURE sca_batch_runner( errbuf       OUT NOCOPY     VARCHAR2
		   ,retcode      OUT NOCOPY     NUMBER
		   ,p_parent_proc_audit_id      NUMBER
		   ,p_process  	              VARCHAR2
		   ,p_physical_batch_id 	NUMBER
		   ,p_start_date                DATE     := NULL
		   ,p_end_date                  DATE     := NULL
		   ,p_org_id		IN	NUMBER) IS


  l_request_id		 NUMBER(15) := NULL;
  l_process_audit_id     NUMBER(15);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);
  l_return_status VARCHAR2(30);

  l_org_id                INTEGER;
  l_org_append            varchar2(100);

  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);


 BEGIN

    l_request_id 	  := fnd_global.conc_request_id;

    cn_message_pkg.begin_batch(
            x_process_type         => 'SCA Batch Runner'
		   ,x_parent_proc_audit_id => p_parent_proc_audit_id
		   ,x_process_audit_id	   => l_process_audit_id
		   ,x_request_id	   => l_request_id
		   ,p_org_id               => p_org_id);

    debugmsg(p_process || ' : SCA Batch Runner : Start ');

    IF (p_process = 'Create_trx') THEN

        create_trx (
            p_start_date    =>      p_start_date,
            p_end_date      =>      p_end_date,
            p_physical_batch_id     =>  p_physical_batch_id);

    ELSIF (p_process = 'Negate_trx') THEN

        negate_trx (
            p_start_date    =>      p_start_date,
            p_end_date      =>      p_end_date,
            p_physical_batch_id     =>  p_physical_batch_id);

    ElSIF (p_process = 'Populate_data') THEN

--        select    NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL,
--                         SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
--        into l_org_id
       --        from dual;

       l_org_id := p_org_id; -- replaced the able select statement with the assignment statement

        if l_org_id = -99 then
            l_org_append := '_M99';
        else
            l_org_append := '_' || l_org_id;
        end if;

          --+
          -- Construct the call to the collect procedure of the package
          --+

          c := dbms_sql.open_cursor;

          statement := 'begin cn_sca_map_cn'||l_org_append||
                       '.map(:sca_proc_batch_id, :start_date, :end_date, :api_version, :init_msg_list, :commit, :validation_level, '||
                       ':org_id, :return_status, :msg_count, :msg_data); end;';

          dbms_sql.parse(c, statement, dbms_sql.native);

          dbms_sql.bind_variable(c,'sca_proc_batch_id', p_physical_batch_id, 30);
          dbms_sql.bind_variable(c,'start_date', p_start_date);
          dbms_sql.bind_variable(c,'end_date', p_end_date);
          dbms_sql.bind_variable(c,'api_version', 1.0);
          dbms_sql.bind_variable(c,'init_msg_list', FND_API.G_FALSE);
          dbms_sql.bind_variable(c,'commit', FND_API.G_FALSE);
	  dbms_sql.bind_variable(c,'validation_level', FND_API.G_VALID_LEVEL_FULL);
          dbms_sql.bind_variable(c,'org_id', p_org_id);
          dbms_sql.bind_variable(c,'return_status', l_return_status, 50);
          dbms_sql.bind_variable(c,'msg_count', l_msg_count);
          dbms_sql.bind_variable(c,'msg_data', l_msg_data, 200);

          rows_processed := dbms_sql.execute(c);

          dbms_sql.variable_value(c,'return_status', l_return_status);
          dbms_sql.variable_value(c,'msg_count', l_msg_count);
          dbms_sql.variable_value(c,'msg_data', l_msg_data);
          dbms_sql.close_cursor(c);

          if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then

            RAISE fail_populate;

          end if;

    ELSIF (p_process = 'Rollback_data') THEN

        check_adjusted (
            p_start_date    =>  p_start_date,
            p_end_date      =>  p_end_date,
            p_physical_batch_id =>  p_physical_batch_id);

    ELSIF (p_process = 'Check_comm_lines_api_adjusted') THEN

        check_api_adjusted (
                p_start_date           =>   p_start_date,
                p_end_date             =>   p_end_date,
                p_physical_batch_id    =>   p_physical_batch_id);

    END IF;

    debugmsg(p_process || ' : SCA Batch Runner : Completed over physical batch : ' || p_physical_batch_id);
    debugmsg(p_process || ' : SCA Batch Runner : End ');

--    cn_message_pkg.flush;
--    COMMIT;

--    cn_message_pkg.set_name('CN','ALL_PROCESS_DONE_OK');
    cn_message_pkg.end_batch(l_process_audit_id);

    retcode := 0;
    errbuf := 'Successful.';


 EXCEPTION

    WHEN fail_populate THEN

       retcode := 2;
       debugmsg(p_process || ' : SCA Batch Runner : Failed in populating : ' || p_physical_batch_id);
       debugmsg(p_process || ' : SCA Batch Runner : End ');
       cn_message_pkg.end_batch(l_process_audit_id);

    WHEN others THEN

       retcode := 2;
       debugmsg(p_process || ' : SCA Batch Runner : Unexpected Exception : ' || p_physical_batch_id);
       debugmsg(p_process || ' : SCA Batch Runner : End ');
       cn_message_pkg.end_batch(l_process_audit_id);

 END sca_batch_runner;


END cn_sca_trx_proc_pvt;

/
