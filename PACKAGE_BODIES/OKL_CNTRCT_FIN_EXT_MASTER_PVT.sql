--------------------------------------------------------
--  DDL for Package Body OKL_CNTRCT_FIN_EXT_MASTER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CNTRCT_FIN_EXT_MASTER_PVT" AS
/* $Header: OKLRFECB.pls 120.0.12010000.7 2009/09/25 22:03:57 sechawla noship $*/

  -- -------------------------------------------------
  -- To print log messages
  -- -------------------------------------------------


  PROCEDURE write_to_log(
                         p_message IN VARCHAR2
                        ) IS
  BEGIN

    fnd_file.put_line(fnd_file.log, p_message);
  END write_to_log;


  PROCEDURE write_to_output(
                         p_message IN VARCHAR2
                        ) IS
  BEGIN

    fnd_file.put_line(fnd_file.output, p_message);
  END write_to_output;


  /*========================================================================
 | PUBLIC PROCEDURE Process_Spawner
 |
 | DESCRIPTION
 |    This procedure identifies contracts for Contract Financial Report, based
 |    upon a few primary input paramaters, inserts these contracts into a temp table and
 |    assigns a worker to each contract. It then spawns child request(s), based upon
 |    the parameter 'p_num_processes'. Once child requests complete, it launches
 |    request for Contract Financial Report
 |
 | CALLED FROM
 |    Concurrent Program "Master Program -- Contract Financial Report"
 |
 | CALLS PROCEDURES/FUNCTIONS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 19-Sep-2008           SECHAWLA           Created
 *=======================================================================*/

  PROCEDURE Process_Spawner (

  							errbuf             		OUT NOCOPY VARCHAR2,
                            retcode            		OUT NOCOPY NUMBER,
                            P_OPERATING_UNIT       	IN NUMBER,
                            --P_REPORT_DATE			IN VARCHAR2, sechawla 25-sep-09 8890513
                            P_DATA_SOURCE_CODE      IN VARCHAR2,
                            P_REPORT_TEMPLATE_NAME  IN VARCHAR2,
							P_REPORT_LANGUAGE		IN VARCHAR2,
                            P_REPORT_FORMAT			IN VARCHAR2,
                            P_START_DATE_FROM  	    IN VARCHAR2,
                            P_START_DATE_TO    	    IN VARCHAR2,
                            P_AR_INFO_YN			IN VARCHAR2,
                            P_BOOK_CLASS			IN VARCHAR2,
                            P_LEASE_PRODUCT			IN VARCHAR2,
                            P_CONTRACT_STATUS		IN VARCHAR2,
                            P_CUSTOMER_NUMBER		IN VARCHAR2,
							P_CUSTOMER_NAME			IN VARCHAR2,
							P_SIC_CODE				IN VARCHAR2,
							P_VENDOR_NUMBER			IN VARCHAR2,
							P_VENDOR_NAME			IN VARCHAR2,
							P_SALES_CHANNEL			IN VARCHAR2,
							P_GEN_ACCRUAL			IN VARCHAR2,
							P_END_DATE_FROM		    IN VARCHAR2,
                            P_END_DATE_TO			IN VARCHAR2,
                            P_TERMINATE_DATE_FROM   IN VARCHAR2,
							P_TERMINATE_DATE_TO		IN VARCHAR2,
							P_DELETE_DATA_YN		IN VARCHAR2,
                            p_num_processes    		IN NUMBER


                         ) IS


   CURSOR l_parallel_worker_csr(cp_assigned_process IN VARCHAR2) IS
   SELECT object_value, khr_id, assigned_process
   FROM   OKL_PARALLEL_PROCESSES
   WHERE  object_type = 'CONTRACT_FIN_EXTRACT'
   AND    assigned_process = cp_assigned_process
   AND    process_status = 'PENDING_ASSIGNMENT';

   CURSOR parent_sts_csr(p_request_id NUMBER) IS
	SELECT count(*)
		from fnd_concurrent_requests req,
		     fnd_concurrent_programs pgm
		where req.PRIORITY_REQUEST_ID = p_request_id
		and req.concurrent_program_id = pgm.concurrent_program_id
		and req.PHASE_CODE = 'C'
		and request_id <> p_request_id
		and STATUS_CODE = 'E';

  CURSOR parent_warn_sts_csr(p_request_id NUMBER) IS
	SELECT count(*)
        from fnd_concurrent_requests req,
             fnd_concurrent_programs pgm
        where req.priority_request_id = p_request_id
        and req.concurrent_program_id = pgm.concurrent_program_id
        and req.phase_code = 'C'
        and request_id <> p_request_id
        and status_code = 'G';

  l_int_counter       			INTEGER;
  l_init_loop         			BOOLEAN := TRUE;
  l_seq_next          			NUMBER;
  l_char_seq_num				VARCHAR2(30);
  l_data_found        			BOOLEAN := FALSE;
  lp_k_start_date_from        	DATE;
  lp_k_start_date_to          	DATE;
  lp_k_end_date_from        	DATE;
  lp_k_end_date_to          	DATE;
  l_req_data          			VARCHAR2(10);
  l_req_counter       			NUMBER;
  request_id 					NUMBER := 0;
  l_last_worker_used			NUMBER;
  TYPE parallel_worker_tbl_type IS TABLE OF l_parallel_worker_csr%ROWTYPE INDEX BY BINARY_INTEGER;

  l_parallel_worker_tbl			parallel_worker_tbl_type;
  l_parallel_worker_temp_tbl	parallel_worker_tbl_type;

  l_fetch_size                  NUMBER := 10000;
  l_total_rows 					NUMBER := 0;
  l_this_row					NUMBER;
  l_max_worker_used				NUMBER;

  -- Org Id and standard who columns
  l_last_updated_by     		okl_parallel_processes.last_updated_by%TYPE := Fnd_Global.USER_ID;
  l_last_update_login   		okl_parallel_processes.last_update_login%TYPE := Fnd_Global.LOGIN_ID;
  l_request_id          		okl_parallel_processes.request_id%TYPE := Fnd_Global.CONC_REQUEST_ID;
  l_program_id          		okl_parallel_processes.program_id%TYPE := Fnd_Global.CONC_PROGRAM_ID;
  l_org_id              		okl_parallel_processes.org_id%type;

  l_child_in_error       		NUMBER;
  l_child_in_warn       		NUMBER;

  i								NUMBER;
  report_request_id				NUMBER := 0;
  l_row_count					NUMBER;
  p_ret_add_layout 				BOOLEAN := true;
  --lp_report_date				DATE; --sechawla 25-sep-09 8890513

begin


  -- The following block is added to control the sub-request program
  -- submission. It ensures that this program is not executed recurrsively.
  l_req_data := fnd_conc_global.request_data;
  -- If l_req_data has a value within this session, the program is attempting to
  -- run again, therefore break out of the loop.


   -- Add couple of blank lines
  fnd_file.new_line(fnd_file.log,2);
  fnd_file.new_line(fnd_file.output,2);


  write_to_log('l_req_data : '||l_req_data);

  MO_GLOBAL.set_policy_context('S',p_operating_unit);

  if l_req_data is not null and l_req_data = '1' then


    l_child_in_error := 0;
    OPEN  parent_sts_csr( l_request_id );
    FETCH parent_sts_csr INTO l_child_in_error;
    CLOSE parent_sts_csr;

    write_to_log('l_child_in_error : '||l_child_in_error);
    l_child_in_warn := 0;
    OPEN  parent_warn_sts_csr( l_request_id );
    FETCH parent_warn_sts_csr INTO l_child_in_warn;
    CLOSE parent_warn_sts_csr;

    write_to_log('l_child_in_warn : '||l_child_in_warn);

    if l_child_in_error > 0 then
        errbuf := 'Done, but with error!';
        retcode := 2;
        return;
    end if;

    if l_child_in_warn > 0 then
        errbuf := 'Done, but with warning(s)!';
        retcode := 1;
        return;
    end if;



    FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request

    --P_REPORT_TEMPLATE_NAME <-> value set 'OKL_XDO_REP_TEMPLATE' <-> stores the template code (in ID column)
    --P_REPORT_LANGUAGE <-> value set 'OKL_XDO_REP_LANGUAGE' <-> stores language code e.g 'en' (in ID column)
    --P_REPORT_FORMAT <-> value set 'OKL_XDO_REP_FORMAT' <-> stores format code e.g 'RTF' (in ID column)
    p_ret_add_layout := FND_REQUEST.add_layout(	template_appl_name=>'OKL',
																template_code=> P_REPORT_TEMPLATE_NAME, --'OKLFINEXTR',
																template_language=> P_REPORT_LANGUAGE, --'en', --sechawla 7628379
																template_territory=>'00',
																output_format=>P_REPORT_FORMAT); --'RTF');--sechawla 7628379
	IF 	p_ret_add_layout THEN
	    write_to_log('p_ret_add_layout = TRUE');
	ELSE
	    write_to_log('p_ret_add_layout = FALSE');
	END IF;

    report_request_id := FND_REQUEST.SUBMIT_REQUEST(
                          application => 'OKL',
                          program     => 'OKLFINEXTR',
                          sub_request => TRUE,
                          argument1   => P_OPERATING_UNIT,
                          --argument2   => P_REPORT_DATE, sechawla 25-sep-09 8890513 : removed report_date and re sequenced following paramaters
                          argument2   => P_START_DATE_FROM,
                          argument3   => P_START_DATE_TO,
                          argument4   => P_AR_INFO_YN,
                          argument5   => P_BOOK_CLASS,
                          argument6   => P_LEASE_PRODUCT,
                          argument7   => P_CONTRACT_STATUS,
                          argument8   => P_CUSTOMER_NUMBER,
             			  argument9  => P_CUSTOMER_NAME,
             			  argument10  => P_SIC_CODE,
             			  argument11  => P_VENDOR_NUMBER,
             			  argument12  => P_VENDOR_NAME,
             			  argument13  => P_SALES_CHANNEL,
             			  argument14  => P_GEN_ACCRUAL,
             			  argument15  => P_END_DATE_FROM,
             			  argument16  => P_END_DATE_TO,
             			  argument17  => P_TERMINATE_DATE_FROM,
             			  argument18  => P_TERMINATE_DATE_TO,
             			  argument19  => P_DELETE_DATA_YN

                         );


    write_to_log('Launching Report with Request ID '||report_request_id);

    if (report_request_id = 0) then


    	write_to_log('Request submission failed. ');
        write_to_log('Exiting with error... ');

        -- If request submission failed, exit with error
        errbuf := fnd_message.get;
        retcode := 2;
    else
        write_to_log('Report Sub-Request submitted, putting master into PAUSED mode');
        --Set the globals to put the master into PAUSED mode
        fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                     	request_data => to_char(2));
        errbuf := 'Sub-Request submitted!';
        retcode := 0;
    end if;

elsif  l_req_data is not null and l_req_data = '2' then
    l_child_in_error := 0;
    OPEN  parent_sts_csr( l_request_id );
    FETCH parent_sts_csr INTO l_child_in_error;
    CLOSE parent_sts_csr;

    write_to_log('l_child_in_error : '||l_child_in_error);
    l_child_in_warn := 0;
    OPEN  parent_warn_sts_csr( l_request_id );
    FETCH parent_warn_sts_csr INTO l_child_in_warn;
    CLOSE parent_warn_sts_csr;

    write_to_log('l_child_in_warn : '||l_child_in_warn);

    if l_child_in_error > 0 then
        errbuf := 'Done, but with error!';
        retcode := 2;
        return;
    end if;

    if l_child_in_warn > 0 then
        errbuf := 'Done, but with warning(s)!';
        retcode := 1;
        return;
    end if;

    write_to_log('Returning Successfully');
    errbuf := 'Done!';
    retcode := 0;
    return;

  end if;

IF l_req_data IS NULL THEN



	write_to_log('P_OPERATING_UNIT = '||P_OPERATING_UNIT);
--	write_to_log('P_REPORT_DATE = '||P_REPORT_DATE); sechawla 25-sep-09 8890513
	write_to_log('P_DATA_SOURCE_CODE = '||P_DATA_SOURCE_CODE);
	write_to_log('P_REPORT_TEMPLATE_NAME ='|| P_REPORT_TEMPLATE_NAME);
	write_to_log('P_REPORT_LANGUAGE ='|| P_REPORT_LANGUAGE);
	write_to_log('P_REPORT_FORMAT ='|| P_REPORT_FORMAT);
	write_to_log('P_START_DATE_FROM = '||P_START_DATE_FROM);
	write_to_log('P_START_DATE_TO = '||P_START_DATE_TO);
	write_to_log('P_AR_INFO_YN = '||P_AR_INFO_YN);
	write_to_log('P_BOOK_CLASS = '||P_BOOK_CLASS);
	write_to_log('P_LEASE_PRODUCT = '||P_LEASE_PRODUCT);
	write_to_log('P_CONTRACT_STATUS = '||P_CONTRACT_STATUS);
	write_to_log('P_CUSTOMER_NUMBER = '||P_CUSTOMER_NUMBER);
	write_to_log('P_CUSTOMER_NAME = '||P_CUSTOMER_NAME);
	write_to_log('P_SIC_CODE = '||P_SIC_CODE);
	write_to_log('P_VENDOR_NUMBER = '||P_VENDOR_NUMBER);
	write_to_log('P_VENDOR_NAME = '||P_VENDOR_NAME);
	write_to_log('P_SALES_CHANNEL = '||P_SALES_CHANNEL);
	write_to_log('P_GEN_ACCRUAL = '||P_GEN_ACCRUAL);
	write_to_log('P_END_DATE_FROM = '||P_END_DATE_FROM);
	write_to_log('P_END_DATE_TO = '||P_END_DATE_TO);
	write_to_log('P_TERMINATE_DATE_FROM = '||P_TERMINATE_DATE_FROM);
	write_to_log('P_TERMINATE_DATE_TO = '||P_TERMINATE_DATE_TO);
	write_to_log('P_DELETE_DATA_YN '||P_DELETE_DATA_YN);
	write_to_log('p_num_processes = '||p_num_processes);





--  lp_report_date := FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE);   sechawla 25-sep-09 8890513



  ---- Paramater validations -----
  /* --sechawla 25-sep-09 8890513
  IF trunc(lp_report_date) <>  trunc(sysdate) THEN
     write_to_log('Report Date should be today''s date');
     return;
  END IF;
  */

  -- If p_num_processes is 0 then no need to go through the algorithm.
  -- p_num_processes can be 1
  if ( nvl(p_num_processes,0) = 0 OR nvl(p_num_processes,0) < 0 )then
    write_to_log('No workers specified');
    return;
  end if;

  lp_k_start_date_from := FND_DATE.CANONICAL_TO_DATE(P_START_DATE_FROM);
  lp_k_start_date_to   := FND_DATE.CANONICAL_TO_DATE(P_START_DATE_TO);


  IF P_END_DATE_FROM IS NOT NULL THEN
     lp_k_end_date_from := FND_DATE.CANONICAL_TO_DATE(P_END_DATE_FROM);
  END IF;

  IF P_END_DATE_TO IS NOT NULL THEN
     lp_k_end_date_to   := FND_DATE.CANONICAL_TO_DATE(P_END_DATE_TO);
  END IF;

  -- Select sequence for marking processes
  select okl_opp_seq.nextval
  into l_seq_next
  from dual ;

  l_char_seq_num := to_char(l_seq_next);

  WRITE_TO_LOG('Sequence Number : '||l_seq_next);

  -- mark records for processing

  l_org_id := mo_global.get_current_org_id();
  WRITE_TO_LOG('org id:: '||l_org_id);


  INSERT INTO OKL_PARALLEL_PROCESSES
    (
     object_type, object_value, assigned_process, process_status, start_date, khr_id,
     ORG_ID,CREATED_BY,CREATION_DATE,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN,
     REQUEST_ID,PROGRAM_ID,PROGRAM_UPDATE_DATE
    )
  SELECT 'CONTRACT_FIN_EXTRACT', chr.contract_number, l_char_seq_num, 'PENDING_ASSIGNMENT', sysdate, chr.id ,
          l_org_id,l_last_updated_by,sysdate,sysdate,l_last_updated_by,l_last_update_login,
          l_request_id,l_program_id,sysdate
  FROM   okc_k_headers_all_b chr,
         OKL_K_HEADERS khr
  WHERE  chr.id = khr.id
  AND    chr.SCS_CODE = 'LEASE'
  AND    chr.sts_code IN ('BANKRUPTCY_HOLD','ENTERED','BOOKED', 'COMPLETE', 'EVERGREEN', 'EXPIRED', 'INCOMPLETE',
                          'LITIGATION_HOLD', 'NEW', 'PASSED', 'REVERSED', 'TERMINATED') --sechawla 13-jan-09 7693771
  AND    chr.AUTHORING_ORG_ID = P_OPERATING_UNIT
  AND    (chr.start_date IS NOT NULL AND chr.START_DATE >= lp_k_start_date_from)
  AND    (chr.start_date IS NOT NULL AND chr.START_DATE <= lp_k_start_date_to)
  AND    nvl(khr.DEAL_TYPE,'XXX') = nvl(P_BOOK_CLASS, nvl(khr.DEAL_TYPE,'XXX'))
  AND    nvl(khr.pdt_id,-9999) = nvl(P_LEASE_PRODUCT,nvl(khr.pdt_id,-9999))
  AND    chr.sts_code = nvl(P_CONTRACT_STATUS, chr.sts_code)
  AND    ( (lp_k_end_date_from IS NULL) OR (chr.END_DATE IS NOT NULL AND chr.END_DATE >= lp_k_end_date_from) )
  AND    ( (lp_k_end_date_to IS NULL  ) OR (chr.END_DATE IS NOT NULL AND chr.END_DATE <= lp_k_end_date_to)   )
  AND    NOT EXISTS
		       (SELECT '1'
			    FROM OKL_PARALLEL_PROCESSES opp
		        WHERE chr.contract_number = opp.object_value
		        AND opp.object_type = 'CONTRACT_FIN_EXTRACT'
		        AND opp.process_status in ('PENDING_ASSIGNMENT', 'ASSIGNED'));

 l_row_count := SQL%ROWCOUNT;

 write_to_log('Number of rows inserted in OKL_PARALLEL_PROCESSES :'||l_row_count);

  IF l_row_count > 0 THEN
      l_data_found := TRUE;

  END IF;


  COMMIT;


  if l_data_found then

    write_to_log('l_fetch_size : '||l_fetch_size);


     i := 1;
     l_parallel_worker_tbl.DELETE;
     OPEN l_parallel_worker_csr(l_char_seq_num);
     LOOP
        l_parallel_worker_temp_tbl.DELETE;
        FETCH l_parallel_worker_csr BULK COLLECT INTO l_parallel_worker_temp_tbl LIMIT l_fetch_size;


        IF l_parallel_worker_temp_tbl.COUNT > 0 THEN
           FOR k IN l_parallel_worker_temp_tbl.FIRST..l_parallel_worker_temp_tbl.LAST LOOP
               l_parallel_worker_tbl(i).object_value := l_parallel_worker_temp_tbl(k).object_value;
               l_parallel_worker_tbl(i).khr_id := l_parallel_worker_temp_tbl(k).khr_id;
               l_parallel_worker_tbl(i).assigned_process := l_parallel_worker_temp_tbl(k).assigned_process;

               i := i + 1;
            END LOOP;

        END IF;

        EXIT WHEN l_parallel_worker_csr%NOTFOUND;
     END LOOP;
     CLOSE l_parallel_worker_csr;

	 l_total_rows :=  l_parallel_worker_tbl.count;

	 write_to_log('l_parallel_worker_tbl.count :'||l_total_rows);


     IF l_total_rows > 0 THEN
        -- p_num_processes is > 0
           l_this_row := 1;

           l_max_worker_used := 0;

           WHILE l_this_row <= l_total_rows LOOP
              FOR j in 1..p_num_processes LOOP
                  IF l_this_row <= l_total_rows THEN
                     l_parallel_worker_tbl(l_this_row).assigned_process := l_parallel_worker_tbl(l_this_row).assigned_process||'-'||j ;

                     l_last_worker_used := j;

                     l_this_row := l_this_row + 1;
                  ELSE
                     EXIT;
                  END IF;
              END LOOP;

              if l_last_worker_used > l_max_worker_used then
                 l_max_worker_used :=l_last_worker_used;
              end if;

            END LOOP;

	        write_to_log('l_max_worker_used :'||l_max_worker_used);

	  		-- At this point, l_parallel_worker_tbl has all the contracts with an assigned process
	  		FOR k IN l_parallel_worker_tbl.FIRST..l_parallel_worker_tbl.LAST LOOP


				write_to_log('contract # : '||l_parallel_worker_tbl(k).object_value||': worker # '||l_parallel_worker_tbl(k).assigned_process);
	      		UPDATE OKL_PARALLEL_PROCESSES
          		SET assigned_process = l_parallel_worker_tbl(k).assigned_process,
              		process_status = 'ASSIGNED'
	      		WHERE object_Type = 'CONTRACT_FIN_EXTRACT'
          		AND   object_value = l_parallel_worker_tbl(k).object_value
          		AND   process_status = 'PENDING_ASSIGNMENT';

          		COMMIT;
	  		END LOOP;

	        write_to_log('OKL_PARALLEL_PROCESSES Updated with worker assignment');

	  		FOR j in 1..l_max_worker_used LOOP

	      		l_req_data := fnd_conc_global.request_data;


          		if (l_req_data is not null) then
          			l_req_counter := l_req_counter + to_number(l_req_data);
          		else
          			l_req_counter := 1;
          		end if;

                -- l_req_counter = number of workers used ?
          		write_to_log('Worker # :'||j||' l_req_data  : '||l_req_data||' l_req_counter : '||l_req_counter);
          		if l_req_counter < (p_num_processes+1) then
          			FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request


          			request_id := FND_REQUEST.SUBMIT_REQUEST(
                          application => 'OKL',
                          program     => 'OKL_CNTRCT_FIN_REP_CHILD', --short name for child conc program
                          sub_request => TRUE,
                          argument1   => P_OPERATING_UNIT,
                          --argument2   => P_REPORT_DATE, --sechawla 25-sep-09 8890513
                          argument2   => P_START_DATE_FROM,
                          argument3   => P_START_DATE_TO,
                          argument4   => P_AR_INFO_YN,
                          argument5   => P_BOOK_CLASS,
                          argument6   => P_LEASE_PRODUCT,
                          argument7   => P_CONTRACT_STATUS,
                          argument8   => P_CUSTOMER_NUMBER,
             			  argument9  => P_CUSTOMER_NAME,
             			  argument10  => P_SIC_CODE,
             			  argument11  => P_VENDOR_NUMBER,
             			  argument12  => P_VENDOR_NAME,
             			  argument13  => P_SALES_CHANNEL,
             			  argument14  => P_GEN_ACCRUAL,
             			  argument15  => P_END_DATE_FROM,
             			  argument16  => P_END_DATE_TO,
             			  argument17  => P_TERMINATE_DATE_FROM,
             			  argument18  => P_TERMINATE_DATE_TO,
             			  argument19  => P_DELETE_DATA_YN,
             			  argument20  => p_num_processes,
             			  argument21  => l_seq_next||'-'||j
                         );


          			write_to_log('Launching Process '||l_seq_next||'-'||j ||' with Request ID '||request_id);

          			if (request_id = 0) then

          			    write_to_log('Request submission failed.');
          			    write_to_log('Exiting with error... ');

          			    DELETE OKL_PARALLEL_PROCESSES
    					WHERE   assigned_process like l_char_seq_num||'%' ;

                        l_row_count := sql%rowcount;
                        IF l_row_count > 0 THEN
    					   write_to_log('Deleted '||l_row_count||' rows from OKL_PARALLEL_PROCESSES.');
    					END IF;

					    COMMIT;
             			-- If request submission failed, exit with error
             			errbuf := fnd_message.get;
             			retcode := 2;
          			else
          			    write_to_log('Sub-Request submitted, putting master into PAUSED mode');
             			-- Set the globals to put the master into PAUSED mode
             			fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                     					request_data => to_char(1));
             			errbuf := 'Sub-Request submitted!';
             			retcode := 0;
          			end if;
        		end if;


	  		END LOOP;

	 END IF;  --IF l_total_rows > 0 THEN

  else  --if l_data_found then
    write_to_log('No workers assigned due to no data found for prcocesing');

  end if;
end if;
  exception
  when others then
    write_to_log('Unhandled Exception '||sqlcode||':'||sqlerrm);

    DELETE OKL_PARALLEL_PROCESSES
    WHERE assigned_process like l_char_seq_num||'%' ;

    l_row_count := sql%rowcount;

    IF l_row_count > 0 THEN
       write_to_log('Deleted '||sql%rowcount||' rows from OKL_PARALLEL_PROCESSES.');
    END IF;

    COMMIT;

END Process_Spawner;



END OKL_CNTRCT_FIN_EXT_MASTER_PVT;

/
