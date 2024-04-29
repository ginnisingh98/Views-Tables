--------------------------------------------------------
--  DDL for Package Body ARP_RUN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_RUN" AS
-- $Header: ARTERRPB.pls 120.10 2006/06/16 18:58:16 hyu arrt008.sql $
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

  g_debug_flag     VARCHAR2(4):= NVL(arp_standard.pg_prf_enable_debug, 'N');

  g_no_more_msgs   EXCEPTION;

  PRAGMA EXCEPTION_INIT(g_no_more_msgs, -25228);

  SUCCESS          CONSTANT NUMBER:=0;
  WARNING          CONSTANT NUMBER:=1;
  FAILURE          CONSTANT NUMBER:=2;

PROCEDURE enq_trans AS
  CURSOR c01 IS
  SELECT
     DISTINCT ctl.customer_trx_id,
     ct.trx_number
  FROM
     ra_customer_trx ct,
     ra_customer_trx_lines ctl
  WHERE
     ctl.autorule_complete_flag = 'N'
  AND ct.customer_trx_id         = ctl.customer_trx_id
  AND ct.complete_flag           = 'Y';

BEGIN
   --
   arp_util.print_fcn_label('arp_run.enq_trans()+');
   --
   FOR c01_rec IN c01 LOOP
      -- Put the message in the queue
      arp_queue.enqueue(system.ar_rev_rec_typ(c01_rec.customer_trx_id,
      NVL(arp_global.sysparam.org_id, 0), 'ARTERRPB', c01_rec.trx_number));
      --
   END LOOP;
   --
   arp_util.print_fcn_label('arp_run.enq_trans()-');
   --
EXCEPTION
   WHEN OTHERS THEN
      arp_standard.debug('EXCEPTION: ' ||SQLERRM(SQLCODE));
      RAISE;
END enq_trans;


PROCEDURE revenue_recognition(errbuf           OUT NOCOPY VARCHAR2,
			      retcode          OUT NOCOPY NUMBER,
			      p_worker_number  IN  NUMBER,
			      p_report_mode    IN VARCHAR2,
			      p_org_id	       IN NUMBER) AS
   l_msg            SYSTEM.AR_REV_REC_TYP;
   l_reqid          NUMBER := 0;
   l_req_data       VARCHAR2(2000);
--
   l_nq_opts        DBMS_AQ.ENQUEUE_OPTIONS_T;
   l_msg_prop       DBMS_AQ.MESSAGE_PROPERTIES_T;
--
   l_recipients     DBMS_AQ.AQ$_RECIPIENT_LIST_T;
--
   l_msg_id         RAW(16);
   l_dq_success     BOOLEAN :=FALSE;


   i                NUMBER := 1;
   l_total_dists    NUMBER := 0;

   l_org_id         NUMBER;

BEGIN

   arp_util.print_fcn_label('arp_run.revenue_recognition()+');

   select org_id
   into l_org_id
   from ar_system_parameters;

   retcode := SUCCESS;

   l_req_data := fnd_conc_global.request_data;

   IF l_req_data IS NULL THEN -- First Time

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('My worker number is ' || p_worker_number);
      END IF;

      <<rev_rec_loop>>
      LOOP

         l_dq_success := FALSE;

         arp_queue.dequeue(p_msg=>l_msg);

         l_dq_success := TRUE;

         -- And print it.

         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('revenue_recognition: ' || i || '> Processing Trx number : <' || l_msg.trx_number || '> Trx Id <' ||
         l_msg.customer_trx_id || '> Created From : <' || l_msg.created_from || ' ' ||l_msg.org_id );
         END IF;
         --
         i := i + 1;
         --
	 <<create_dists>>
         BEGIN
            /* Bug 2649674 - added p_continue_on_error set to 'Y' */
            l_total_dists :=  l_total_dists +
                arp_auto_rule.create_distributions(p_commit=>'Y',
        	                                   p_debug =>g_debug_flag,
					           p_trx_id=>l_msg.customer_trx_id,
                                                   p_suppress_round=>NULL,
                                                   p_continue_on_error=>'Y');
         EXCEPTION
	    WHEN OTHERS THEN
	       IF PG_DEBUG in ('Y', 'C') THEN
	          arp_standard.debug('EXCEPTION: Could not create distribution for Trx no.' || l_msg.trx_number);
                  arp_standard.debug(SQLERRM(SQLCODE));
               END IF;
         END create_dists;
         --
         --
         commit;
         --
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug(' Total dists created so far : ' || l_total_dists);
         END IF;

      END LOOP rev_rec_loop;

   ELSE
      errbuf := 'Completed the report..';
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('revenue_recognition: ' || errbuf);
      END IF;
   END IF;

   arp_util.print_fcn_label('arp_run.revenue_recognition()-');

EXCEPTION
   WHEN g_no_more_msgs THEN
      -- End of the queue reached.
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('No More messages left. Shutting down the worker..');
         arp_standard.debug('Submitting the report..');
      END IF;
      fnd_request.set_org_id(l_org_id);
      l_reqid :=  FND_REQUEST.SUBMIT_REQUEST (
                              application=>'AR',
                              program=>'ARBARL_NON_SRS2',
                              sub_request=>TRUE,
			      argument1=>'P_COA=' ||
			      arp_standard.gl_chart_of_accounts_id ,     -- P_COA
			      argument2=>'P_RUN_AUTO_RULE=N',            -- P_RUN_AUTO_RULE
			      argument3=>'P_COMMIT_AT_END=Y',            -- P_COMMIT_AT_END
			      argument4=>'P_DEBUG_FLAG='|| g_debug_flag ,-- P_DEBUG_FLAG
                              argument5=>'P_CONTINUE_ON_ERROR=Y',        -- P_CONTINUE_ON_ERROR
			      argument6=>'P_USER_ID=' ||
			      arp_standard.profile.user_id,              -- P_USER_ID
			      argument7=>'CONC_REQUEST_ID=' ||
			      arp_standard.profile.request_id,           -- P_CONC_REQUEST_ID
			      argument8=>'P_REPORT_MODE=' ||
			      p_report_mode                              -- P_REPORT_MODE
                         ) ;
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Request Id :' || l_reqid);
      END IF;

      fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
				      request_data => to_char(l_reqid)) ;

      --
      commit;
      --
      --
      errbuf := 'Report submitted!';

   WHEN OTHERS THEN
      ROLLBACK;
      errbuf := 'EXCEPTION:' ||SQLERRM(SQLCODE);
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('revenue_recognition: ' || errbuf);
      END IF;
      retcode := WARNING;
      --
      -- Put the dequeued message back in the queue
      --
      IF l_dq_success THEN
	 BEGIN
	 --
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_standard.debug('Putting the last message back in the queue');
	    END IF;
	 --
	    arp_queue.enqueue(p_msg=>l_msg);
	 --
            commit;
	 --
         EXCEPTION
	    WHEN OTHERS THEN
	       IF PG_DEBUG in ('Y', 'C') THEN
	          arp_standard.debug('EXCEPTION:' || SQLERRM(SQLCODE));
	          arp_standard.debug('Unable to enqueue the message last message');
	       END IF;
               retcode := FAILURE;
	       RAISE;
	 END;
	  --
      END IF;

END revenue_recognition;

PROCEDURE rev_rec_master      (errbuf           OUT NOCOPY VARCHAR2,
			       retcode          OUT NOCOPY NUMBER,
			       p_report_mode    IN  VARCHAR2 := 'S',
	                       p_max_workers    IN  NUMBER := 2,
			       p_interval       IN  NUMBER :=60,
			       p_max_wait       IN  NUMBER := 180,
			       p_org_id		IN  NUMBER) AS

-- Constants

   MAX_WORKERS      CONSTANT NUMBER := 15; -- Limitation because of size of request_data (255)
   MIN_WORKERS      CONSTANT NUMBER := 2;
   MIN_WORKERS_1    CONSTANT NUMBER := MIN_WORKERS + 1;

-- Variables

   l_total_workers  NUMBER := LEAST(p_max_workers, MAX_WORKERS);  -- total number of workers
   l_req_data       VARCHAR2(2000);
   l_msg            system.AR_REV_REC_TYP;
   worker_error     EXCEPTION;
   l_org_id         NUMBER;
   l_max_workers    NUMBER;
-- Functions

   FUNCTION submit_control (
                              p_total_workers  IN NUMBER  := MIN_WORKERS,
                              p_org_id IN NUMBER
			      ) RETURN INTEGER IS
      l_worker_number  NUMBER;
      l_reqid          NUMBER;
      l_program        VARCHAR2(30) := 'ARTERRPW' ;
      l_appl_short     VARCHAR2(30) := 'AR' ;
      l_complete       BOOLEAN := FALSE;

      TYPE req_status_typ  IS RECORD (
	 request_id       NUMBER(15),
	 dev_phase        VARCHAR2(255),
	 dev_status       VARCHAR2(255),
	 message          VARCHAR2(2000),
	 phase            VARCHAR2(255),
	 status           VARCHAR2(255));

      TYPE req_status_tab_typ   IS TABLE OF req_status_typ INDEX BY BINARY_INTEGER;

      l_req_status_tab   req_status_tab_typ;

      PROCEDURE submit_subrequest (p_worker_num IN NUMBER,
                                   p_org_id IN NUMBER ) AS

      BEGIN
	 --
         arp_util.print_fcn_label('submit_subrequest()+');

         fnd_request.set_org_id(p_org_id);
         l_reqid :=  FND_REQUEST.SUBMIT_REQUEST (
                              application=>l_appl_short,
                              program=>l_program,
                              sub_request=>FALSE,
			      argument1=>p_worker_num,
			      argument2=>p_report_mode,
			      argument3=>p_org_id
                         ) ;

         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('Submitted child request no. ['|| p_worker_num ||'] : ' || l_reqid);
         END IF;

	 commit;

	 l_req_data := l_req_data || l_reqid;

	 IF p_worker_num < p_total_workers THEN
	    l_req_data := l_req_data || ',';
	 END IF;

	 l_req_status_tab(p_worker_num).request_id := l_reqid;

         arp_util.print_fcn_label('submit_subrequest()-');

      END submit_subrequest;

   BEGIN -- Submit_control

      --
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('submit_control()+');
      END IF;

      --
      -- Wait for 1 Sec to check for messages
      --
      BEGIN
         arp_queue.dequeue(p_msg=>l_msg,
			   p_browse=>TRUE,
			   p_first=>TRUE);
      EXCEPTION
         WHEN g_no_more_msgs THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('No More messages left. Check for any unprocessed Transactions.');
            END IF;
            enq_trans;
	    commit;
            arp_queue.dequeue(p_msg=>l_msg,
			      p_browse=>TRUE,
			      p_first=>TRUE);
         WHEN OTHERS THEN
            RAISE;
      END;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Found some messages..');
      END IF;

      l_req_data := NULL;

      l_req_status_tab.DELETE;

      --
      -- Submit Minimum possible workers
      --

      FOR l_worker_number IN 1..MIN_WORKERS LOOP

	 submit_subrequest (l_worker_number, p_org_id);

      END LOOP;

      --
      -- Based on the load startup additional workers
      --

      <<add_worker>>
      FOR l_worker_number IN MIN_WORKERS_1..p_total_workers
      LOOP
	 -- Check the status of Worker no 1

	 l_complete := FND_CONCURRENT.WAIT_FOR_REQUEST(
		       request_id=>l_req_status_tab(1).request_id,
		       interval=>p_interval,
		       max_wait=>p_max_wait,
		       phase=>l_req_status_tab(1).phase,
		       status=>l_req_status_tab(1).status,
		       dev_phase=>l_req_status_tab(1).dev_phase,
		       dev_status=>l_req_status_tab(1).dev_status,
		       message=>l_req_status_tab(1).message);

         IF l_req_status_tab(1).dev_phase <> 'COMPLETE' THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_standard.debug('Starting additional workers..');
	    END IF;
	    submit_subrequest (l_worker_number, p_org_id);
         ELSE
	    IF l_req_status_tab(1).dev_status IN ('TERMINATED', 'CANCELLED', 'ERROR') THEN
	       IF PG_DEBUG in ('Y', 'C') THEN
	          arp_standard.debug('Worker was terminated / cancelled / errored out..');
	          arp_standard.debug('Shutting down the master process.');
	       END IF;

	       RAISE worker_error;
	    ELSE
	       IF PG_DEBUG in ('Y', 'C') THEN
	          arp_standard.debug(  'Continue..');
	       END IF;
	    END IF;
         END IF;

      END LOOP add_worker;

--{BUG#5336931  - All REVREC sub requests have to end before the Master finishes
     l_max_workers  := l_req_status_tab.COUNT;

      FOR i IN 1 .. l_max_workers LOOP
        LOOP
            l_complete := FND_CONCURRENT.WAIT_FOR_REQUEST(
               request_id=>l_req_status_tab(i).request_id,
               interval=>p_interval,
               max_wait=>p_max_wait,
               phase=>l_req_status_tab(i).phase,
               status=>l_req_status_tab(i).status,
               dev_phase=>l_req_status_tab(i).dev_phase,
               dev_status=>l_req_status_tab(i).dev_status,
               message=>l_req_status_tab(i).message);
            EXIT WHEN (l_req_status_tab(i).dev_phase = 'COMPLETE');
        END LOOP;
        EXIT WHEN i = p_max_workers;
      END LOOP;
--}
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug(  'Req Data : ' || l_req_data);
         arp_standard.debug(  'submit_control()-');
      END IF;

      RETURN SUCCESS ;

   EXCEPTION
      WHEN g_no_more_msgs THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug(  'No More messages left. Shutting down the master.');
         END IF;
         RETURN SUCCESS;
      WHEN worker_error THEN
	 IF PG_DEBUG in ('Y', 'C') THEN
	    arp_standard.debug(  'Worker was terminated / cancelled');
	 END IF;
         RETURN SUCCESS ;
      WHEN OTHERS THEN
	 IF PG_DEBUG in ('Y', 'C') THEN
	    arp_standard.debug(  'ARXRRSPW:' || SQLERRM(SQLCODE));
	 END IF;
         RETURN FAILURE ;
   END submit_control;

/*--------------------------------------------------------------------------*
 | Processing cycle                                                         |
 *--------------------------------------------------------------------------*/
BEGIN
  select org_id
  into l_org_id
  from ar_system_parameters;

   --
   retcode := SUCCESS;
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_run.rev_rec_master()+');
   END IF;
   --
   l_req_data := fnd_conc_global.request_data;
   --
   IF l_req_data IS NULL THEN -- First Time
   --
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug(  'First Time..');
      END IF;
      --
      -- Refresh AR Periods
      --
      arp_auto_rule.refresh(errbuf, retcode);
   --
   ELSE
   --
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug(  'Completed Requests :' || l_req_data);
      END IF;
   --
   END IF;

   retcode := submit_control (l_total_workers, l_org_id);

   commit;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_run.rev_rec_master()-');
   END IF;


EXCEPTION
   WHEN OTHERS THEN
      errbuf := 'EXCEPTION:' || SQLERRM(SQLCODE);
      retcode := FAILURE;
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug(  errbuf);
      END IF;

END rev_rec_master;

/* Bug 2217161 - This routine is called behind the scenes of the
   Credit Transactions form as a submitted job.  This is to resolve
   some significant performance problems related to invoice accounting
   when crediting invoices with rules.  The procedure will delete
   all non-posted REV/UNEARN/UNBILL lines (non-model ones).  It will
   then call the arp_credit_memo_module.credit_transactions function
   to rebuild them (correctly) based on the invoice's distributions. */

PROCEDURE build_credit_distributions (errbuf             OUT NOCOPY VARCHAR2,
			              retcode            OUT NOCOPY NUMBER,
                                      p_customer_trx_id  IN NUMBER,
                                      p_prev_trx_id      IN NUMBER) AS

   l_failure_count NUMBER;

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_run.build_credit_distributions()+');
   END IF;

   retcode := SUCCESS;

               arp_credit_memo_module.credit_transactions(
                         p_customer_trx_id,
                         null,
                         p_prev_trx_id,
                         null,
                         null,
                         l_failure_count);

   /* Gotta commit the results */
   commit;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_run.build_credit_distributions()-');
   END IF;

EXCEPTION
   WHEN arp_credit_memo_module.no_ccid THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('EXCEPTION: credit memo module exception : no_ccid');
        END IF;
        RAISE;
   WHEN NO_DATA_FOUND THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('EXCEPTION: credit memo module exception : no_data_found');
        END IF;
        null;
   WHEN app_exception.application_exception THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('build_credit_distributions: ' || 'credit memo module exception : app_exception ');
        END IF;
        RAISE;
   WHEN OTHERS THEN
        RAISE;

END build_credit_distributions;

/* Bug 2967037 - Added logic to submit reporting sets of books based on the
   primary sob defined by/for this operating unit.  This routine submits
   all associated rsobs for a given psob_id.  The remaining parameters
   are all fed directly into the call to ARGLTP */

PROCEDURE submit_mrc_posting (p_psob_id                IN NUMBER,
                              p_gl_start_date          IN DATE,
                              p_gl_end_date            IN DATE,
                              p_gl_posted_date         IN DATE,
                              p_summary_flag           IN VARCHAR2,
                              p_journal_import         IN VARCHAR2,
                              p_posting_days_per_cycle IN NUMBER,
                              p_posting_control_id     IN NUMBER,
                              p_debug_flag             IN VARCHAR2,
                              p_org_id                 IN NUMBER,
                              retcode                  OUT NOCOPY NUMBER) AS

  l_acctg_sob_list              gl_ca_utility_pkg.r_sob_list;
  l_req_id                      NUMBER;
  l_sob_type                    VARCHAR2(1);
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_run.submit_mrc_posting()+');
      arp_standard.debug('  Submitting for primary sob : ' ||
           arp_global.sysparam.set_of_books_id);

   END IF;

      /* Initialize list */
      l_acctg_sob_list := gl_ca_utility_pkg.r_sob_list();

      gl_ca_utility_pkg.get_associated_sobs(
                      p_sob_id   => arp_global.sysparam.set_of_books_id,
                      p_appl_id  => 222,
                      p_org_id   => arp_global.sysparam.org_id,
                      p_sob_list => l_acctg_sob_list);

      /* Initialize retcode */
      retcode := 0;

      FOR l_index IN 1 .. l_acctg_sob_list.COUNT LOOP

         gl_ca_utility_pkg.get_sob_type(
              l_acctg_sob_list(l_index).r_sob_id,
              l_sob_type);

         IF (l_sob_type = 'R')
         THEN

            /* Submit for RSOB
               NOTE:  For clarity, I converted all parameters to their
               correct types in ARXPRGLP.  However, some of them
               must be converted back to char for the pro*C call */

            l_req_id := fnd_request.submit_request('AR', 'ARGLTP',
                                               NULL, NULL, FALSE,
                fnd_date.date_to_canonical(p_gl_start_date),
                fnd_date.date_to_canonical(p_gl_end_date),
                fnd_date.date_to_canonical(p_gl_posted_date),
                'N',
                p_summary_flag,
                p_journal_import,
                to_char(p_posting_days_per_cycle),
                '',
                p_debug_flag,
                to_char(p_org_id),
                to_char(l_acctg_sob_list(l_index).r_sob_id),
                chr(0),
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','');

             IF (l_req_id IS NOT NULL AND l_req_id <> 0)
             THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  arp_standard.debug(' SUCCESS:  sob_id = ' ||
                          l_acctg_sob_list(l_index).r_sob_id ||
                                     ' req_id = ' || l_req_id);
               END IF;

             ELSE
                  /* Set retcode to -1 to indicate that at least
                     one submission failed */
                  retcode := -1;
                  arp_standard.debug(' EXCEPTION: sob_id = ' ||
                          l_acctg_sob_list(l_index).r_sob_id);
             END IF;

         END IF;

      END LOOP;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_run.submit_mrc_posting()-');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
        arp_standard.debug('EXCEPTION:  arp_run.submit_mrc_posting()');
        /* retcode to -1 means ARGLTP will end in WARNING */
        retcode := -1;
END submit_mrc_posting;

END arp_run;

/
