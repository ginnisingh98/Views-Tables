--------------------------------------------------------
--  DDL for Package Body AR_POSTBATCH_PARALLEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_POSTBATCH_PARALLEL" AS
/* $Header: ARPBMPB.pls 120.0.12010000.3 2008/11/12 14:40:27 mgaleti noship $ */
PG_DEBUG	varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
G_ERROR		varchar2(1) := 'N';
G_USER_ID   	number;
G_CONC_PROGRAM_ID   number;
G_CONC_REQUEST_ID   number;
G_PROG_APPL_ID      number;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   submit_postbatch_parallel() - Submit child requests for the processing  |
 |                    of postbatch through submit_subrequest(). It makes a   |
 |                    call to update_batch_after_process() to update the     |
 |                    batch status after all the child requests are completed|
 | DESCRIPTION                                                               |
 |      Submits child requests.                                              |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |      arp_standard.debug() - debug procedure                               |
 |      FND_REQUEST.wait_for_request                                         |
 | ARGUMENTS  : IN:                     				     |
 |                 p_org_id - Org ID                                         |
 |                 p_batch_id - Batch Id                                     |
 |                 p_transmission_id - Lockbox transmission ID               |
 |                 p_total_workers - Number of workers                       |
 |                                                                           |
 |              OUT:  P_ERRBUF                                               |
 |                    P_RETCODE                                              |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY -  09/01/2008 - Created by AGHORAKA	     	     |
 |                         01/02/2008 - Modified parameter list.             |
 +===========================================================================*/

PROCEDURE submit_postbatch_parallel(
          P_ERRBUF                          OUT NOCOPY VARCHAR2,
	  P_RETCODE                         OUT NOCOPY NUMBER,
	  p_org_id                          IN NUMBER,
	  p_batch_id                        IN NUMBER,
	  p_transmission_id                 IN NUMBER,
	  p_total_workers                   IN NUMBER DEFAULT 1 ) AS

  l_worker_number 		NUMBER ;
  l_complete      		BOOLEAN := FALSE;
  l_batch_applied_status    	ar_batches.batch_applied_status%TYPE := 'POSTBATCH_WAITING';
  l_ct_cnt        		NUMBER;
  l_ct_amt	  		NUMBER;
  l_locked_status		VARCHAR2(10);
  l_batch_id			ar_batches.batch_id%TYPE;
  l_excep_code			NUMBER(2);
  l_matched_claim_creation	VARCHAR2(2);
  l_matched_claim_excl_cm	VARCHAR2(2);
  l_return_status		VARCHAR2(1);
  l_status			ar_batches.status%TYPE;

  CURSOR  qcbatch IS
       SELECT	ab.name batch_name,
		abs.name batch_source_name,
		ab.batch_date,
		ab.gl_date,
		ab.deposit_date,
		ab.status,
		ab.comments,
		ab.batch_applied_status,
		ab.control_count,
		ab.control_amount,
		cba.bank_account_name,
		cba.bank_account_num,
		ab.currency_code,
		to_number(to_char(ab.gl_date, 'J')),
		to_number(to_char(ab.deposit_date, 'J'))
	FROM	ar_batches ab,
                ar_batch_sources abs,
	        ce_bank_accounts cba,
                ce_bank_acct_uses_all ba
	WHERE	ab.batch_source_id = abs.batch_source_id
	AND	ab.remit_bank_acct_use_id
		= ba.bank_acct_use_id (+)
	AND     ba.bank_account_id = cba.bank_account_id (+)
        AND     ab.org_id = ba.org_id
	AND	ab.batch_id = p_batch_id;


  CURSOR lbbatch IS
        SELECT	ab.name batch_name,
		abs.name batch_source_name,
		ab.batch_date,
		ab.gl_date,
		ab.deposit_date,
		ab.status,
		ab.comments,
		ab.batch_applied_status,
		ab.control_count,
		ab.control_amount,
		cba.bank_account_name,
		cba.bank_account_num,
		ab.currency_code,
		to_number(to_char(ab.gl_date, 'J')),
		to_number(to_char(ab.deposit_date, 'J')),
		ab.batch_id
	FROM	ar_batches ab,
                ar_batch_sources abs,
	        ce_bank_accounts cba,
                ce_bank_acct_uses_all ba
	WHERE	ab.batch_source_id = abs.batch_source_id
	AND	ab.remit_bank_acct_use_id
		= ba.bank_acct_use_id
        AND     cba.bank_account_id = ba.bank_account_id
	AND	ab.batch_applied_status = l_batch_applied_status
        AND     ab.org_id = ba.org_id
	AND	ab.transmission_id = p_transmission_id
	ORDER BY ab.batch_id;

  lbr lbbatch%ROWTYPE;
  qcr qcbatch%ROWTYPE;

  TYPE req_status_typ  IS RECORD (
    request_id       NUMBER(15),
    dev_phase        VARCHAR2(255),
    dev_status       VARCHAR2(255),
    message          VARCHAR2(2000),
    phase            VARCHAR2(255),
    status           VARCHAR2(255));


  TYPE req_status_tab_typ   IS TABLE OF req_status_typ INDEX BY BINARY_INTEGER;

  l_req_status_tab   req_status_tab_typ;

 /*===========================================================================+
 | PROCEDURE                                                                 |
 |   submit_subrequest() - This process submits Postbatch process            |
 | DESCRIPTION                                                               |
 |      Submits postbatch requests.                                          |
 |									     |
 | SCOPE -                                                                   |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |      FND_REQUEST.submit_request                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_worker_number - Worker Number                           |
 |                 p_org_id - Org_id                                         |
 |                                                                           |
 |              OUT:     None                                                |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY -  09/01/2008 - Created by AGHORAKA	     	     |
 +===========================================================================*/

  PROCEDURE submit_subrequest (p_worker_number IN NUMBER,
                               p_org_id IN NUMBER) IS
    l_request_id NUMBER(15);
    BEGIN
	fnd_file.put_line(FND_FILE.LOG, 'submit_subrequest()+');

	FND_REQUEST.SET_ORG_ID(p_org_id);

	l_request_id := FND_REQUEST.submit_request( 'AR', 'ARCABP',
                                                'Submit Post Batch',
                                                SYSDATE,
                                                FALSE,
                                                '1',
                                                NVL(p_batch_id, -1),
                                                arp_standard.sysparm.set_of_books_id,
                                                p_worker_number,
                                                p_total_workers,
                                                NVL(p_transmission_id, -1),
                                                p_org_id);

	IF (l_request_id = 0) THEN
	    arp_util.debug('Can not start for worker_id: ' ||p_worker_number );
	    P_ERRBUF := fnd_Message.get;
	    P_RETCODE := 2;
	    return;
	ELSE
	    commit;
	    arp_util.debug('child request id: ' ||l_request_id || ' started for worker_id: ' ||p_worker_number );
	END IF;

	 l_req_status_tab(p_worker_number).request_id := l_request_id;
	 arp_util.debug('submit_subrequest()-');

    END submit_subrequest;

 /*===========================================================================+
 | PROCEDURE                                                                 |
 |   update_batch_after_process() -This process updates the batch status     |
 |   after all the receipts in the batch are processed by ARCABP.            |
 | DESCRIPTION                                                               |
 |   Updates the batch_applied_status of the batch to "PROCESSED'            |
 |   and status to 'CL'/'OP' 						     |
 | SCOPE -                                                                   |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_batch_id - Batch ID                                     |
 |                 p_batch_applied_status - Batch Applied Status             |
 |                 p_ct_cnt - Control Count                                  |
 |                 p_ct_amt - Control Amount                                 |
 |              OUT:     None                                                |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY -  09/01/2008 - Created by AGHORAKA	     	     |
 +===========================================================================*/


    PROCEDURE update_batch_after_process( p_batch_id ar_batches.batch_id%TYPE,
					p_batch_applied_status ar_batches.batch_applied_status%TYPE,
					p_ct_cnt	       NUMBER,
					p_ct_amt	       NUMBER
				      ) AS
    l_act_app_cnt		NUMBER;
    l_act_app_amt		NUMBER;
    l_err_receipt_cnt		NUMBER;
    BEGIN
    fnd_file.put_line( FND_FILE.LOG, 'Process_batch_for_update()+');

    IF ( p_batch_applied_status <> 'PROCESSED' AND
         p_batch_applied_status <> 'POSTBATCH_WAITING') THEN


           fnd_file.put_line(FND_FILE.LOG, 'Batch_id : '||p_batch_id||' : Control count : '||p_ct_cnt||' : Control Amount : '||p_ct_amt);

		fnd_file.put_line( FND_FILE.LOG, ' Getting the applied count and applied amount');

		SELECT count(*), nvl(sum(cr.amount),0)
		INTO   l_act_app_cnt, l_act_app_amt
		FROM   ar_cash_receipts cr,
		       ar_cash_receipt_history crh
	        WHERE  cr.cash_receipt_id = crh.cash_receipt_id
		AND    crh.batch_id = p_batch_id
		AND    cr.status = 'APP';

		IF (( l_act_app_cnt = p_ct_cnt ) AND ( l_act_app_amt = p_ct_amt )) THEN
			l_status := 'CL';
		ELSE
			l_status := 'OP';
		END IF;

		SELECT COUNT(1)
		INTO l_err_receipt_cnt
		FROM ar_interim_cash_receipts
		WHERE batch_id = p_batch_id;

		IF ( l_err_receipt_cnt = 0) THEN
			fnd_file.put_line( FND_FILE.LOG, 'Updating batch_applied_status to PROCESSED.' );
			UPDATE  ar_batches
			SET	batch_applied_status = 'PROCESSED',
    			status = l_status,
    			last_updated_by = G_USER_ID,
    			last_update_date = sysdate,
   		    	program_id = G_CONC_PROGRAM_ID,
        		request_id = G_CONC_REQUEST_ID,
        		program_application_id = G_PROG_APPL_ID,
        		program_update_date = sysdate
			WHERE	batch_id = p_batch_id;
		ELSE
			fnd_file.put_line( FND_FILE.LOG, 'Updating batch_applied_status to POSTBATCH_WAITING.' );
			update_batch_for_rerun( l_status, p_batch_id);
		END IF;

		commit;
		fnd_file.put_line( FND_FILE.LOG, 'End of Posting');

    END IF;
    END update_batch_after_process;

BEGIN
    fnd_file.put_line( FND_FILE.LOG, 'submit_postbatch_parallel()+');
    /* Initialize the global values */
    G_USER_ID   := FND_GLOBAL.user_id;
    G_CONC_PROGRAM_ID := FND_GLOBAL.conc_program_id;
    G_CONC_REQUEST_ID := FND_GLOBAL.conc_request_id;
    G_PROG_APPL_ID  := FND_GLOBAL.prog_appl_id;

    mo_global.init('AR');

    IF p_org_id is not null THEN
    	mo_global.set_policy_context('S', p_org_id);
    	arp_standard.init_standard(p_org_id);
    END IF;

    IF p_batch_id IS NULL AND p_transmission_id IS NULL THEN
	 FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
     APP_EXCEPTION.raise_exception;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
	 arp_standard.debug(   'Org_id = '||p_org_id );
	 arp_standard.debug(   'Batch Id = '||p_batch_id );
     arp_standard.debug(   'Transmission_id = '||p_transmission_id );
	 arp_standard.debug(   'Total Workers = '||p_total_workers );
    END IF;

    -- Validate batches supplied in the parameters.
    IF NVL(p_transmission_id,-1) <> -1 THEN
    -- This is a Lockbox batch.
	FOR lbr IN lbbatch LOOP
		IF lbr.batch_applied_status = 'PROCESSED' THEN
			fnd_file.put( FND_FILE.OUTPUT, '***' || lbr.batch_name ||' : ');
			fnd_file.put_line( FND_FILE.OUTPUT, fnd_message.get_string('AR', 'ARCABP_BEEN_PROCESSED'));
		ELSIF lbr.batch_applied_status <> 'POSTBATCH_WAITING' THEN
			fnd_file.put( FND_FILE.OUTPUT, '***' || lbr.batch_name ||' : ');
			fnd_file.put_line( FND_FILE.OUTPUT, fnd_message.get_string('AR', 'ARCABP_NOT_VALID_BATCH'));
		ELSE
			  SELECT 'locked'
			  INTO   l_locked_status
	                  FROM   ar_batches
			  WHERE  batch_id = lbr.batch_id
			  FOR UPDATE OF	batch_applied_status, status,
				last_update_date, last_updated_by;
			 UPDATE  ar_batches
			 SET  batch_applied_status = 'IN_PROCESS',
			      last_update_date = sysdate,
			      last_updated_by  = G_USER_ID,
			      program_id = G_CONC_PROGRAM_ID,
			      request_id = G_CONC_REQUEST_ID,
			      program_application_id = G_PROG_APPL_ID,
			      program_update_date = sysdate
		         WHERE  batch_id = lbr.batch_id;
			 l_batch_applied_status := 'IN_PROCESS';
		END IF;
	END LOOP;
	IF l_batch_applied_status <> 'IN_PROCESS' THEN
		fnd_file.put_line( FND_FILE.OUTPUT, '**** No Batches To Process ****');
		goto leave_program;
	END IF;
    ELSE
    -- This is a Quick cash batch.
	FOR qcr IN qcbatch LOOP
		IF qcr.batch_applied_status = 'PROCESSED' THEN
			fnd_file.put( FND_FILE.OUTPUT, '***' || qcr.batch_name ||' : ');
			fnd_file.put_line( FND_FILE.OUTPUT, fnd_message.get_string('AR', 'ARCABP_BEEN_PROCESSED'));
			goto leave_program;
		ELSIF qcr.batch_applied_status <> 'POSTBATCH_WAITING' THEN
			fnd_file.put( FND_FILE.OUTPUT, '***' || qcr.batch_name ||' : ');
			fnd_file.put_line( FND_FILE.OUTPUT, fnd_message.get_string('AR', 'ARCABP_NOT_VALID_BATCH'));
			goto leave_program;
		ELSE
			SELECT 'locked'
			INTO   l_locked_status
			FROM   ar_batches
			WHERE  batch_id = p_batch_id
			FOR UPDATE OF	batch_applied_status, status,
					last_update_date, last_updated_by;
			UPDATE  ar_batches
			SET  batch_applied_status = 'IN_PROCESS',
			      last_update_date = sysdate,
			      last_updated_by  = G_USER_ID,
			      program_id = G_CONC_PROGRAM_ID,
			      request_id = G_CONC_REQUEST_ID,
			      program_application_id = G_PROG_APPL_ID,
			      program_update_date = sysdate
		         WHERE  batch_id = p_batch_id;
		END IF;
	END LOOP;

    END IF;
    /* ------------------------------------------------------------- *
     *                  Added for Bug 7141803                        *
     * We may need to gather stats on interim tables based on the    *
     * profile option 'AR_LB_QC_GATHER_STATS'. By default stats will *
     * always be gathered unless the profile option is set to 'NO'   *
     * ------------------------------------------------------------- */
    IF nvl(fnd_profile.value_specific('AR_LB_QC_GATHER_STATS',
                                        G_USER_ID), 'Y') <> 'N' THEN
      DECLARE
      	l_schema      VARCHAR2(30);
	l_status      VARCHAR2(1);
	l_industry    VARCHAR2(1);
	l_tname1      VARCHAR2(30) := 'AR_INTERIM_CASH_RECEIPTS_ALL';
	l_tname2      VARCHAR2(30) := 'AR_INTERIM_CASH_RCPT_LINES_ALL';
	no_product_info exception;
      BEGIN
      	IF (NOT fnd_installation.get_app_info(
		 application_short_name=>'AR'
		, status => l_status
		, industry => l_industry
		, oracle_schema => l_schema)) THEN
		fnd_file.put_line(fnd_file.log, 'EXCEPTION:Failed to get information for AR');
		RAISE no_product_info;
	END IF;

        fnd_stats.gather_table_stats(ownname=>l_schema,
                                    tabname=>l_tname1);
        fnd_stats.gather_table_stats(ownname=>l_schema,
                                    tabname=>l_tname2);
      EXCEPTION
	      WHEN OTHERS THEN
         	fnd_file.put_line(fnd_file.log, 'Error in Gather stats' || SQLERRM(SQLCODE));
         	RAISE;
      END;
      fnd_file.put_line(fnd_file.LOG, 'AR:ARPBMPB Gathered Stats on Interim Tables');
    END IF;
    --Invoke the child programs
    FOR l_worker_number IN 1..p_total_workers LOOP
	fnd_file.put_line(FND_FILE.LOG, 'worker # : ' || l_worker_number );
	submit_subrequest (l_worker_number,p_org_id);
    END LOOP;

    IF PG_DEBUG in ('Y', 'C') THEN
	arp_standard.debug ( 'The Master program waits for child processes');
    END IF;

    -- Wait for the completion of the submitted requests
    FOR i in 1..p_total_workers LOOP

	l_complete := FND_CONCURRENT.WAIT_FOR_REQUEST(
		   request_id   => l_req_status_tab(i).request_id,
		   interval     => 30,
		   max_wait     =>144000,
		   phase        =>l_req_status_tab(i).phase,
		   status       =>l_req_status_tab(i).status,
		   dev_phase    =>l_req_status_tab(i).dev_phase,
		   dev_status   =>l_req_status_tab(i).dev_status,
		   message      =>l_req_status_tab(i).message);

	IF l_req_status_tab(i).dev_phase <> 'COMPLETE' THEN
	    P_RETCODE := 2;
	    fnd_file.put_line( FND_FILE.LOG, 'Worker # '|| i||' has a phase '||l_req_status_tab(i).dev_phase);
	ELSIF l_req_status_tab(i).dev_phase = 'COMPLETE'
	       AND l_req_status_tab(i).dev_status <> 'NORMAL' THEN
	    P_RETCODE := 2;
	    fnd_file.put_line( FND_FILE.LOG, 'Worker # '|| i||' completed with status '||l_req_status_tab(i).dev_status);
	ELSE
	    fnd_file.put_line( FND_FILE.LOG, 'Worker # '|| i||' completed successfully');
	END IF;

    END LOOP;

    fnd_file.put( FND_FILE.LOG, 'Return Code : ' || p_retcode);

   IF NVL( p_retcode, -1) = 2 THEN
	fnd_file.put_line( FND_FILE.LOG, ' - Child program failed.' );
   ELSE
	fnd_file.put_line( FND_FILE.LOG, ' - Child programs completed successfully' );
   END IF;

   IF NVL(p_transmission_id, -1) <> -1 THEN	/* Lockbox batch */
    FOR lbr IN lbbatch LOOP
	update_batch_after_process( lbr.batch_id,
				  lbr.batch_applied_status,
				  lbr.control_count,
				  lbr.control_amount );
    END LOOP;
   ELSE
    FOR qcr IN qcbatch LOOP			/* Quick cash batch */
	update_batch_after_process( p_batch_id,
				  qcr.batch_applied_status,
				  qcr.control_count,
				  qcr.control_amount );
    END LOOP;
   END IF;

   IF NVL( p_transmission_id, -1) <> -1 THEN

	fnd_file.put_line( FND_FILE.LOG, 'Updating transmission status.');

	UPDATE	ar_transmissions t
	SET	status = 'CL',
		last_updated_by = G_USER_ID,
		last_update_date = trunc(sysdate)
	WHERE	transmission_id = p_transmission_id
	AND	NOT EXISTS (	SELECT	'pending post'
				FROM	ar_batches b
				WHERE	b.transmission_id =
					t.transmission_id
				AND	batch_applied_status
					= 'POSTBATCH_WAITING' )
	AND	NOT EXISTS (	SELECT	'pending transfer'
				FROM	ar_payments_interface pi
				WHERE	pi.transmission_id =
					t.transmission_id);
    END IF;

    AR_BUS_EVENT_COVER.Raise_PostBatch_Run_Event( G_CONC_REQUEST_ID );

    <<leave_program>>
	commit;
        fnd_file.put_line( FND_FILE.LOG, 'submit_postbatch_parallel()-');

EXCEPTION

  WHEN OTHERS THEN
    RAISE ;

END submit_postbatch_parallel;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   update_batch_for_rerun() - If any error occurs during the postbatch     |
 |   process, the batch_applied_status is put back to 'POSTBATCH_WAITING'    |
 |   for rerun at later time.                                                |
 | DESCRIPTION                                                               |
 |     Updates batch_applied_Status to 'POSTBATCH_WAITING'                   |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 | ARGUMENTS  : IN:                     				     |
 |                 p_status - Batch Status                                   |
 |                 p_batch_id - Batch Id                                     |
 |                                                                           |
 |              OUT:     None                                                |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY -  09/01/2008 - Created by AGHORAKA	     	     |
 +===========================================================================*/


PROCEDURE update_batch_for_rerun( p_status    IN ar_batches.status%TYPE,
				  p_batch_id  IN NUMBER) AS
BEGIN
	fnd_file.put_line( FND_FILE.LOG, 'update_batch_for_rerun()+');

	UPDATE ar_batches
	SET    batch_applied_status = 'POSTBATCH_WAITING',
	       status = p_status,
	       last_updated_by = G_USER_ID,
	       last_update_date = sysdate,
               program_id = G_CONC_PROGRAM_ID,
               request_id = G_CONC_REQUEST_ID,
               program_application_id = G_PROG_APPL_ID,
               program_update_date = sysdate
	WHERE batch_id = p_batch_id;

	commit;

	fnd_file.put_line( FND_FILE.LOG, 'update_batch_for_rerun()-');
END update_batch_for_rerun;

END AR_POSTBATCH_PARALLEL;

/
