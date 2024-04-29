--------------------------------------------------------
--  DDL for Package Body PA_ONESTEP_STREAMLINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ONESTEP_STREAMLINE_PKG" AS
/* $Header: PAOSTRMB.pls 120.4.12000000.2 2007/12/07 08:51:33 rdegala ship $ */
PROCEDURE update_request_state(tbl IN OUT NOCOPY strm_request_id_table)

IS

   r_phase VARCHAR2(30);
   r_status VARCHAR2(30);
   v_phase VARCHAR2(30);
   v_status VARCHAR2(30);
   message VARCHAR2(240);
   retval BOOLEAN;

BEGIN

   pa_debug.set_err_stack('update_request_table');
   pa_debug.g_err_stage := 'Entering update_request_table()';
   pa_debug.write_file('LOG',pa_debug.g_err_stage);

   FOR i IN 1..tbl.count LOOP

      IF (tbl(i).request_id <> 0) THEN

	       retval := fnd_concurrent.get_request_status(tbl(i).request_id, '','', r_phase, r_status, v_phase, v_status, message);

	       IF retval THEN

	            tbl(i).phase := v_phase;
	            tbl(i).status := v_status;
	            tbl(i).u_phase := r_phase;
	            tbl(i).u_status := r_status;

	       ELSE

	            pa_debug.g_err_stage := 'fnd_concurrent.get_request_status return FALSE for Request ID ' ||to_char(tbl(i).request_id);
	            pa_debug.write_file('LOG',pa_debug.g_err_stage);

	       END IF;

      END IF;

   END LOOP;

   pa_debug.g_err_stage := 'Leaving update_request_table()';
   pa_debug.write_file('LOG',pa_debug.g_err_stage);
   pa_debug.reset_err_stack;

EXCEPTION
   WHEN OTHERS THEN
     pa_debug.write_file('LOG','update_request_table() exception: Others');
     pa_debug.write_file('LOG',pa_debug.g_err_stack);
     pa_debug.write_file('LOG',pa_debug.g_err_stage);
     RAISE;

END update_request_state;

/* Added Acct_date for bug 6655250*/
PROCEDURE submit_strmln_request(tbl IN OUT NOCOPY strm_request_id_table,
				                strm_option IN VARCHAR2,
						acct_date   IN DATE)

IS

   -- Cursor for selecting Interface Streamline Options
   cursor c_strmln_opt (p_strm_opt IN VARCHAR2) IS
     SELECT LOOKUP_code
       FROM (SELECT LOOKUP_code
       FROM pa_lookups
       WHERE lookup_type = 'INTERFACE STREAMLINE OPTIONS'
       AND lookup_code IN ('ETBC-ATBC', 'EBTC-ABTC', 'EBL-ABL', 'EINV-AINV', 'ELAB-ALAB', 'EPJ-APJ',
                           'EPC-APC', 'EDR-ADR', 'ESC-ASC', 'EUSG-AUSG', 'EWIP-AWIP'))
       WHERE LOOKUP_CODE =
       decode(p_strm_opt,'ALL-STRMLN',LOOKUP_CODE,p_strm_opt);

     v_cnt NUMBER := 0;
     v_request_id NUMBER := -1;
     v_phase VARCHAR(30) := 'PENDING';
     v_status VARCHAR2(30) := 'NORMAL';
     L_org_id  NUMBER := PA_MOAC_UTILS.GET_CURRENT_ORG_ID ;

BEGIN

   pa_debug.set_err_stack('submit_strmln_request');
   pa_debug.g_err_stage := 'Entering submit_strmln_request()';
   pa_debug.write_file('LOG',pa_debug.g_err_stage);

     FOR strmln_opt IN c_strmln_opt(strm_option) LOOP

       /* Setting print options bug 2816916 */
        l_result_print := FND_REQUEST.SET_PRINT_OPTIONS(l_printer,l_print_style,l_number_of_copies, l_save_op_flag_bool,'Y');

        -- MOAC changes for R12
        fnd_request.set_org_id(l_org_id);

	-- Call fnd_request.submit_request
         /* Modified for bug 6655250*/
	v_request_id := fnd_request.submit_request('PA','PASTRM',NULL,NULL,
	  FALSE,strmln_opt.lookup_code,'','','','','','',g_debug_mode,FND_DATE.DATE_TO_CANONICAL(acct_date),
	  '','','','','','','','','','','','','','','','','','','','',
	  '','','','','','','','','','','','','','','','','','','','',
	  '','','','','','','','','','','','','','','','','','','','',
	  '','','','','','','','','','','','','','','','','','','','',
	  '','','','','','','','','','');
	-- Insert request ID into PL/SQL table
	commit;

	IF (v_request_id = 0) THEN
           v_phase:= 'COMPLETE';
	   v_status := 'ERROR';
	END IF;

	v_cnt := tbl.count+1;

	SELECT v_request_id,strmln_opt.lookup_code,v_phase,v_status
	  INTO tbl(v_cnt).request_id,tbl(v_cnt).lookup_code,
	  tbl(v_cnt).phase,tbl(v_cnt).status
	  FROM dual;

	pa_debug.g_err_stage := 'Request ID='||to_char(tbl(v_cnt).request_id)||
	  ', Streamline Option='||tbl(v_cnt).lookup_code;
	pa_debug.write_file('LOG',pa_debug.g_err_stage);
	pa_debug.g_err_stage := '     SOB ID='||to_char(tbl(v_cnt).sob_id)||
	 ', Phase='||tbl(v_cnt).phase||', Status='||tbl(v_cnt).status;
	pa_debug.write_file('LOG',pa_debug.g_err_stage);

     END LOOP;
     pa_debug.g_err_stage := 'Leaving submit_strmln_request() with success';
     pa_debug.write_file('LOG',pa_debug.g_err_stage);
     pa_debug.reset_err_stack;

EXCEPTION
   WHEN OTHERS THEN
     pa_debug.write_file('LOG','submit_strmln_request() exception: Others');
     pa_debug.write_file('LOG',pa_debug.g_err_stack);
     pa_debug.write_file('LOG',pa_debug.g_err_stage);
     RAISE;

END submit_strmln_request;

PROCEDURE show_final_status(tbl IN strm_request_id_table,
			                v_opt IN VARCHAR2,
                            errbuf IN OUT NOCOPY VARCHAR2)

IS

   cursor c_strmln_opt (p_strm_opt IN VARCHAR2) IS
     SELECT LOOKUP_code, meaning
       FROM (SELECT LOOKUP_code, meaning
       FROM pa_lookups
       WHERE lookup_type = 'INTERFACE STREAMLINE OPTIONS'
       AND lookup_code IN ('ETBC-ATBC', 'EBTC-ABTC', 'EBL-ABL', 'EINV-AINV', 'ELAB-ALAB', 'EPJ-APJ',
                           'EPC-APC', 'EDR-ADR', 'ESC-ASC', 'EUSG-AUSG', 'EWIP-AWIP'))
       WHERE LOOKUP_CODE =
       decode(p_strm_opt,'ALL-STRMLN',LOOKUP_CODE,p_strm_opt);

     v_length NUMBER;

BEGIN

   pa_debug.set_err_stack('show_final_status');
   pa_debug.g_err_stage := 'Entering show_final_status()';
   pa_debug.write_file('LOG',pa_debug.g_err_stage);

   FOR strmln_opt IN c_strmln_opt(v_opt) LOOP
      v_length := trunc((130-length(strmln_opt.meaning))/2+
      length(strmln_opt.meaning));

    FOR i IN 1..tbl.count LOOP
	 IF (strmln_opt.lookup_code = tbl(i).lookup_code) THEN
	    pa_debug.g_err_stage := 'Request='||tbl(i).request_id||
	      ', lookup-code='||tbl(i).lookup_code||', SOB ID='||
	      tbl(i).sob_id;
	    pa_debug.write_file('LOG',pa_debug.g_err_stage);

	    pa_debug.g_err_stage := '     u_phase='||tbl(i).u_phase||
	      ', u_status='||tbl(i).u_status||', PHASE='||tbl(i).phase||
	      ', STATUS='||tbl(i).status;
	    pa_debug.write_file('LOG',pa_debug.g_err_stage);

	    IF (tbl(i).status <> 'NORMAL') THEN
	       errbuf := errbuf||'request id '||to_char(tbl(i).request_id)||
		 ': '||tbl(i).phase||' '||tbl(i).status;
	    END IF;

	 END IF;
    END LOOP;
   END LOOP;

   pa_debug.g_err_stage := 'Leaving show_final_status() with success';
   pa_debug.write_file('LOG',pa_debug.g_err_stage);
   pa_debug.reset_err_stack;

EXCEPTION
   WHEN OTHERS THEN
     pa_debug.write_file('LOG','show_final_status() exception: Others');
     pa_debug.write_file('LOG',pa_debug.g_err_stack);
     pa_debug.write_file('LOG',pa_debug.g_err_stage);
     RAISE;

END show_final_status;

PROCEDURE PAOSTRM(
		  errbuf OUT NOCOPY VARCHAR2,
		  retcode OUT NOCOPY VARCHAR2,
		  debug_mode IN VARCHAR2 ,
		  strm_opt IN VARCHAR2,
		  acct_date IN VARCHAR2) IS

    /* Added acct_date for bug 6655250*/
     -- PL/SQL Record and Table to keep track of streamline process
     strm_request_table strm_request_id_table;
     v_user_id NUMBER;
     v_application_id NUMBER;
     v_psob_id NUMBEr(15);
     v_org_id NUMBER(15);
     v_responsibility_id fnd_user_resp_groups.responsibility_id%TYPE;
     v_completed_r BOOLEAN := true; -- for checking completed primary requests
     v_execute_flag BOOLEAN;
     v_temp VARCHAR2(80);
     /*******/
     v_sleep_interval NUMBER := 60;
     /*******/
     v_acct_date	date; /* Bug 6655250*/

  BEGIN

     retcode := '0';
     g_debug_mode := debug_mode;
     pa_debug.init_err_stack('PAOSTRM');
     pa_debug.set_process('PLSQL', 'LOG', debug_mode);
     pa_debug.g_err_stage := 'Entering PAOSTRM()';
     pa_debug.write_file('LOG',pa_debug.g_err_stage);
     pa_debug.g_err_stage := '     Current system time is '||
       to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS');
     pa_debug.write_file('LOG',pa_debug.g_err_stage);

     pa_debug.g_err_stage := 'Current Acct Date is '||acct_date;
     pa_debug.write_file('LOG',pa_debug.g_err_stage);
     v_user_id := fnd_global.user_id;
     v_application_id := fnd_global.resp_appl_id;

     /* added for bug 2816916 */
     l_request_id   := FND_GLOBAL.CONC_REQUEST_ID();
     l_result_print := FND_CONCURRENT.GET_REQUEST_PRINT_OPTIONS(l_request_id,l_number_of_copies, l_print_style,l_printer, l_save_output_flag);

     IF upper(l_save_output_flag) = 'N' THEN
         l_save_op_flag_bool := FALSE;
     ELSE
         l_save_op_flag_bool := TRUE;
     END IF;

     /* end of addition  for bug 2816916 */
     v_acct_date := NVL(FND_DATE.CANONICAL_TO_DATE(acct_date),sysdate); /* Bug 6655250*/

     SELECT set_of_books_id, org_id
       INTO v_psob_id, v_org_id
       FROM pa_implementations;

     -- Get Primary Responsibility ID
     v_responsibility_id := fnd_global.resp_id;
     -- Get Sleep Interval
     v_sleep_interval :=
       nvl(3*to_number(fnd_profile.value('PA_STRMLN_SLEEP_INTERVAL')), 180);

     pa_debug.g_err_stage := 'User ID: '||to_char(v_user_id)||', PSOB ID: '||
       to_char(v_psob_id)||', ORG ID: '||to_char(v_org_id);
     pa_debug.write_file('LOG',pa_debug.g_err_stage);
     pa_debug.g_err_stage := 'Strmln Opt: '||strm_opt||', Resp ID: '||
       v_responsibility_id||', Sleep Interval: '||v_sleep_interval||' Date:'||v_acct_date;
     pa_debug.write_file('LOG',pa_debug.g_err_stage);
	-- Start process for primary set of books
	submit_strmln_request(strm_request_table, strm_opt,v_acct_date);


     pa_debug.g_err_stage := 'All ' ||strm_request_table.count||
       ' processes submitted; check completion status.';
     pa_debug.write_file('LOG',pa_debug.g_err_stage);


     LOOP -- check if all primary and reporting processes have completed
	v_completed_r := true;
	dbms_lock.sleep(v_sleep_interval); -- sleep
	update_request_state(strm_request_table);
	FOR i IN 1..strm_request_table.count LOOP
	   IF (strm_request_table(i).phase <> 'COMPLETE') THEN
	      v_completed_r := false;
	   ELSIF (strm_request_table(i).phase = 'COMPLETE') AND
	     (strm_request_table(i).status = 'WARNING') AND
	     (retcode <> '-1') THEN

	      pa_debug.g_err_stage := strm_request_table(i).status||' '||
		strm_request_table(i).phase;
	      pa_debug.write_file('LOG',pa_debug.g_err_stage);

	      retcode := '1';
	   ELSIF (strm_request_table(i).phase = 'COMPLETE') AND
	     (strm_request_table(i).status = 'DELETED') AND
	     (retcode <> '-1') THEN

	      pa_debug.g_err_stage := strm_request_table(i).status||' '||
		strm_request_table(i).phase;
	      pa_debug.write_file('LOG',pa_debug.g_err_stage);

	      retcode := '1';
	   ELSIF (strm_request_table(i).phase = 'COMPLETE') AND
	     (strm_request_table(i).status <> 'NORMAL') THEN

	      pa_debug.g_err_stage := strm_request_table(i).status||' '||
		strm_request_table(i).phase;
	      pa_debug.write_file('LOG',pa_debug.g_err_stage);

	      retcode := '-1';
	   END IF;
	END LOOP;
	EXIT WHEN (v_completed_r);
     END LOOP;
     show_final_status(strm_request_table, strm_opt, errbuf);
     pa_debug.g_err_stage := 'Leaving PAOSTRM() with success';
     pa_debug.write_file('LOG',pa_debug.g_err_stage);
     pa_debug.reset_err_stack;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
     pa_debug.write_file('LOG','PAOSTRM() exception: No data found');
     pa_debug.write_file('LOG',pa_debug.g_err_stack);
     pa_debug.write_file('LOG',pa_debug.g_err_stage);

   WHEN OTHERS THEN
     show_final_status(strm_request_table, strm_opt, errbuf);
     errbuf := errbuf||'errbuf: '||sqlerrm;
     pa_debug.write_file('LOG','PAOSTRM() exception: Others');
     pa_debug.write_file('LOG',pa_debug.g_err_stack);
     pa_debug.write_file('LOG',pa_debug.g_err_stage);

END PAOSTRM;

END PA_ONESTEP_STREAMLINE_PKG;

/
