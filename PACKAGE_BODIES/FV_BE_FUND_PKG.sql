--------------------------------------------------------
--  DDL for Package Body FV_BE_FUND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_BE_FUND_PKG" AS
--$Header: FVBEFDCB.pls 120.20.12010000.2 2009/10/08 20:32:14 snama ship $

g_module_name		 VARCHAR2(100);
g_sob_id		 gl_ledgers.ledger_id%TYPE;
g_mode 			 gl_bc_packets.status_code%TYPE;
g_errbuf  		 VARCHAR2(1000);
g_retcode 		 NUMBER := 0;
g_user_id       	 NUMBER(15);
g_resp_id       	 NUMBER(15);
g_log_msg 		 VARCHAR2(1);
g_approver_id     	 NUMBER(15);


PROCEDURE log_message(p_module VARCHAR2, p_message VARCHAR2);
PROCEDURE reset_doc_status (p_doc_id NUMBER);


/******************************************************************************
			Procedure conc_main
This procedure is called from the Funds Reservation concurrent program which
in turn is called from the Enter Appropriation, Enter Fund Distribution and
BE Transaction Summary forms when workflow is turned off.
If the workflow is turned off then all documents except reprogramming
transactions will be submitted for Funds reservation through the concurrent
program
******************************************************************************/

PROCEDURE conc_main (errbuf        OUT NOCOPY VARCHAR2,
		     retcode       OUT NOCOPY VARCHAR2,
		     p_mode      	      VARCHAR2,
		     p_sob_id          	      NUMBER,
		     p_approval_id     	      NUMBER)
IS

	l_module_name VARCHAR2(200) ;
	l_doc_id      NUMBER(15);
	l_approver_id NUMBER(15);
        l_return_status VARCHAR2(1);
        l_status_code   VARCHAR2(30);
        l_doc_type      VARCHAR2(30);
        l_event_type    VARCHAR2(30);

CURSOR fetch_doc_id IS
	SELECT  doc_id, transaction_date, budget_level_id, source
	FROM    fv_be_trx_hdrs
	WHERE   approval_id = p_approval_id
	AND     doc_status  = DECODE(p_mode, 'C', doc_status, 'IP')
	AND     NVL(approved_by_user_id,g_user_id) = g_user_id;

BEGIN
	l_module_name  := g_module_name || 'conc_main';
	IF (p_mode NOT IN ('C', 'R')) THEN
		retcode := 2;
		errbuf := 'Invalid Mode for Funds Checking or Reservation ';
		Fv_Utility.Log_mesg(Fnd_Log.LEVEL_ERROR, l_module_name||
						'.message1',errbuf);
	RETURN;
	END IF;
	l_approver_id := Fnd_Global.user_id;
	g_user_id 	  := Fnd_Global.user_id;
	g_resp_id 	  := Fnd_Global.resp_id;
	g_log_msg 	  := 'Y';

	FOR doc_rec IN fetch_doc_id LOOP

            IF doc_rec.source = 'RPR' then

                l_doc_type := 'BE_RPR_TRANSACTIONS';

                      IF doc_rec.budget_level_id = 1 THEN

                            l_event_type := 'RPR_BA_RESERVE';

                      ELSE

                            l_event_type := 'RPR_FD_RESERVE';

                      END IF;

            ELSE

                l_doc_type := 'BE_TRANSACTIONS';

                      IF doc_rec.budget_level_id = 1 THEN

                           l_event_type := 'BA_RESERVE';

                      ELSE

                           l_event_type := 'FD_RESERVE';

                      END IF;

            END IF;

		Main ( errbuf,
                       retcode,
                       p_mode,
                       p_sob_id ,
         	       doc_rec.doc_id,
                       NULL,
                       l_approver_id,
                       l_doc_type,
                       l_event_type,
                       doc_rec.transaction_date,
                       l_return_status,
                       l_status_code,
	   	       g_user_id,
                       g_resp_id);

	END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    retcode := 2;
    errbuf := SQLERRM;
    Fv_Utility.Log_mesg(Fnd_Log.LEVEL_UNEXPECTED, l_module_name||
			  '.final_exception',errbuf);
    RAISE;
END conc_main;

/******************************************************************************
			Procedure main
This procedure is called from the workflow process for reserving funds for
each document. It is also called from the Reprogramming Document Creation
and Approval process for reserving the RPR from and to documents in pair.
It is also called for checking funds from the Enter Appropriations and
Enter Fund distributions form when Funds Check button is pressed.
******************************************************************************/

PROCEDURE main (errbuf              OUT NOCOPY VARCHAR2,
     		retcode             OUT NOCOPY VARCHAR2,
     		p_mode            	       VARCHAR2,
     		p_sob_id          	       NUMBER,
     		p_doc_id                       NUMBER,
     		p_rpr_to_doc_id   	       NUMBER,
     		p_approver_id                  NUMBER,
                p_doc_type                     VARCHAR2,
                p_event_type                   VARCHAR2,
                p_accounting_date              DATE,
                p_return_status     OUT NOCOPY VARCHAR2,
                p_status_code       OUT NOCOPY VARCHAR2,
     		p_user_id                      NUMBER,
     		p_resp_id         	       NUMBER)
IS

 l_module_name 	  VARCHAR2(200);
BEGIN
	l_module_name    := g_module_name || 'main';
	retcode 		 := 0;
	g_retcode 	 	 := 0;
	g_sob_id 		 := p_sob_id;

  --Check if procedure is called from concurrent request
	IF (g_log_msg <> 'Y') THEN
		 g_log_msg := 'N';
	END IF;

	log_message(l_module_name, 'Start of Funds Reservation Main Process ');
	log_message(l_module_name, 'p_mode is ' ||p_mode);
	log_message(l_module_name, 'p_doc_id is ' ||TO_CHAR(p_doc_id));
	log_message(l_module_name, 'p_sob_id is ' ||TO_CHAR(p_sob_id));
	log_message(l_module_name, 'p_rpr_to_doc_id is '|| p_rpr_to_doc_id);
	log_message(l_module_name, 'p_approver_id is ' 	|| p_approver_id);
        log_message(l_module_name, 'p_doc_type is '  || p_doc_type);
        log_message(l_module_name, 'p_event_type is '  || p_event_type);
        log_message(l_module_name, 'p_accounting_date is '  || p_accounting_date);

	IF (p_mode NOT IN ('C', 'R')) THEN
		retcode := 2;
		errbuf := 'Invalid Mode for Funds Checking or Reservation ';
		Fv_Utility.Log_mesg(Fnd_Log.LEVEL_ERROR, l_module_name||
					'.message1',errbuf);
		RETURN;
	END IF;

	g_mode            := p_mode;
	g_user_id 	  := p_user_id;
	g_resp_id 	  := p_resp_id;
	g_approver_id     := p_approver_id;


	process_document(p_doc_id,
                         p_doc_type,
                         p_event_type,
                         p_accounting_date,
                         p_return_status,
                         p_status_code,
                         'FV_BE_FUND_PKG.Main');

	IF g_retcode = 2 THEN
		reset_doc_status(p_doc_id);
	END IF;

  	--Process To RPR document if provided

	IF (p_rpr_to_doc_id IS NOT NULL) THEN

	      log_message(l_module_name, 'Inside if rpr_to_doc_id is Not Null');

                IF g_retcode <> 0 THEN

      			delete_rpr_docs(p_doc_id,p_rpr_to_doc_id);
                ELSE
	           IF (g_mode = 'R') THEN
		      update_doc_status(p_rpr_to_doc_id, g_retcode);
	           END IF;
                END IF;

         END IF;

	 errbuf  := g_errbuf;
	 retcode := g_retcode;

         log_message(l_module_name, 'End of Funds Reservation Main Process ');

         COMMIT;

EXCEPTION WHEN OTHERS THEN
    retcode := 2;
    errbuf:= 'Error in main procedure. SQL Error is '||SQLERRM;
    Fv_Utility.Log_mesg(Fnd_Log.LEVEL_UNEXPECTED, l_module_name||
						'.final_exception',errbuf);


END; -- main


PROCEDURE process_document(p_doc_id                       NUMBER,
                           p_doc_type                     VARCHAR2,
                           p_event_type                   VARCHAR2,
                           p_accounting_date              DATE,
                           x_return_status     OUT NOCOPY VARCHAR2,
                           x_status_code       OUT NOCOPY VARCHAR2,
                           p_calling_sequence             VARCHAR2)

IS
	l_module_name   VARCHAR2(200);
        l_doc_id        NUMBER;

  cursor c_doc_id is
        select  fvr.transaction_id
               into l_doc_id
               from fv_be_rpr_transactions fvr,
                    fv_be_trx_hdrs fvh
               where substr(fvh.doc_number, 1, length(fvh.doc_number) -4) = fvr.doc_number
               and fvh.doc_id = p_doc_id;

BEGIN
	l_module_name  := g_module_name || 'process_document';

	IF (g_retcode <> 2) THEN

              --if rpr transaction then pass transaction id instead of doc id else pass doc id
             IF P_doc_type = 'BE_RPR_TRANSACTIONS' THEN

              OPEN c_doc_id;
              Fetch c_doc_id into l_doc_id;
              IF C_Doc_Id%NOTFOUND THEN
                  l_doc_id := p_doc_id;
              END IF;

              CLOSE c_doc_id;

               IF l_doc_id is null then

                      l_doc_id := p_doc_id;

               END IF;
	    ELSE
                    l_doc_id := p_doc_id;

	    END IF;

             -- call FV Budgetary Control API to do funds check/reservation

             fv_be_xla_pkg.Budgetary_Control(
                          p_ledger_id       => g_sob_id,
                          p_doc_id          => l_doc_id,
                          p_doc_type        => p_doc_type,
                          p_event_type      => p_event_type,
                          p_accounting_date => p_accounting_date,
                          p_bc_mode         => g_mode,
                          p_calling_sequence=> 'FV_BE_FUND_PKG.Main',
                          x_return_status   => x_return_status,
                          x_status_code     => x_status_code);


		IF  x_return_status = 'S' THEN

     			log_message(l_module_name,
			 'Funds Checker Program completed successfully '||
			'with a status code of '||x_status_code);

			SELECT
			DECODE(x_status_code,'SUCCESS', 0,'ADVISORY',0,'FAIL', 1, 'RFAIL',1, 'PARTIAL', 2, 'FATAL',2,'XLA_ERROR',2)
	         	INTO   g_retcode
	         	FROM   dual;
		ELSE
      			log_message(l_module_name, 'Funds Check Errored Out');
			g_retcode := 2;
	        END IF;

		log_message(l_module_name, 'g_errbuf is '||g_errbuf);

  	ELSE -- g_retcode = 2

		Fv_Utility.Log_mesg(Fnd_Log.LEVEL_UNEXPECTED, l_module_name,
				'Error mesg of Else '  ||
				 g_retcode ||  ' - '  || g_errbuf );
		RETURN;

	END IF; --g_retcode is 2

	IF (g_mode = 'R') THEN
		update_doc_status(p_doc_id, g_retcode);
	END IF;

EXCEPTION WHEN OTHERS THEN
    g_retcode := 2;
    g_errbuf:= 'Error in process_document procedure. SQL Error is '||SQLERRM;
    Fv_Utility.Log_mesg(Fnd_Log.LEVEL_UNEXPECTED, l_module_name||
			'.final_exception',g_errbuf);
END; --procedure process_document


PROCEDURE  update_doc_status(p_doc_id NUMBER,
			     p_retcode NUMBER)
IS
  l_module_name VARCHAR2(200);
  l_status fv_be_trx_hdrs.doc_status%TYPE;

BEGIN
   l_module_name:= g_module_name || 'update_doc_status';
   SELECT DECODE(p_retcode, 0, 'AR', 1, 'NR', 'IN')
   INTO   l_status
   FROM   dual;

   UPDATE fv_be_trx_hdrs
   SET    doc_status = l_status,
          internal_revision_num = DECODE(l_status, 'AR', revision_num,
					internal_revision_num),
	  distribution_amount = NULL
   WHERE  doc_id = p_doc_id
   AND    doc_status = 'IP';

   UPDATE fv_be_trx_dtls
   SET    transaction_status = l_status,
          approved_by_user_id = DECODE(l_status, 'AR',g_approver_id, NULL),
          approval_date       = DECODE(l_status,'AR',SYSDATE,NULL)
   WHERE  doc_id = p_doc_id
   --AND    transaction_status = 'IP'
   AND    transaction_status IN ('IP', 'RD')
   AND    revision_num IN (SELECT revision_num
			   FROM fv_be_trx_hdrs
			   WHERE doc_id = p_doc_id);

  EXCEPTION WHEN OTHERS THEN
    g_retcode := 2;
    g_errbuf := 'Error in update_doc_status procedure. SQL Error is ' ||SQLERRM;
    Fv_Utility.Log_mesg(Fnd_Log.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_errbuf);

END; --update_doc_status


PROCEDURE delete_rpr_docs (p_doc_id NUMBER,
			   p_rpr_to_doc_id NUMBER)
IS
  l_module_name VARCHAR2(200) ;
  l_doc_id fv_be_trx_hdrs.doc_id%TYPE;
  l_doc_num fv_be_rpr_transactions.doc_number%TYPE;

  CURSOR get_docnum_c IS
	SELECT SUBSTR(doc_number,1,INSTR(doc_number,'-RPF') - 1) doc_num,
		set_of_books_id sob,budget_level_id id
	FROM fv_be_trx_hdrs
	WHERE doc_id = p_doc_id;
BEGIN
  l_module_name := g_module_name || 'delete_rpr_docs';
  log_message(l_module_name, 'Updating the RPR transaction status to ' ||
							' Not Reserved');

  FOR l_getdoc IN get_docnum_c LOOP
      UPDATE fv_be_rpr_transactions
      SET transaction_status = 'NR'
      WHERE doc_number = l_getdoc.doc_num
      AND set_of_books_id = l_getdoc.sob
      AND budget_level_id =  l_getdoc.id;
  END LOOP;

  log_message(l_module_name, 'Deleting the RPR from and to documents created ');
  FOR i IN 1..2
  LOOP
	IF (i = 1) THEN
	   l_doc_id := p_doc_id;
	ELSE
	   l_doc_id := p_rpr_to_doc_id;
	END IF;

  	DELETE FROM fv_be_trx_dtls
  	WHERE doc_id = l_doc_id;

  	DELETE FROM fv_be_trx_hdrs
  	WHERE doc_id = l_doc_id;
  END LOOP;

  COMMIT;
EXCEPTION WHEN OTHERS THEN
    g_retcode := 2;
    g_errbuf := 'Error in delete_rpr_docs procedure. SQL Error is ' ||SQLERRM;
    Fv_Utility.Log_mesg(Fnd_Log.LEVEL_UNEXPECTED, l_module_name||
						'.final_exception',g_errbuf);
END delete_rpr_docs;

PROCEDURE log_message(p_message VARCHAR2)
IS
BEGIN
  log_message(NULL, p_message);
END;

PROCEDURE log_message(p_module VARCHAR2, p_message VARCHAR2)
IS
  l_module_name VARCHAR2(200);
BEGIN
  l_module_name := g_module_name || 'log_message';

  IF ( Fnd_Log.LEVEL_STATEMENT >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
    Fv_Utility.DEBUG_MESG(Fnd_Log.LEVEL_STATEMENT, p_module,p_message);
  END IF;

EXCEPTION WHEN OTHERS THEN
    g_retcode := 2;
    g_errbuf := 'Error in delete_rpr_docs procedure. SQL Error is ' ||SQLERRM;
    Fv_Utility.Log_mesg(Fnd_Log.LEVEL_UNEXPECTED, l_module_name||
					'.final_exception',g_errbuf);
    RAISE;
END; --log_message

-- +===========================================================================+
-- This procedure will reset the status of the doc to 'InComplete' if the
-- Revision Num is is 0 else 'Require Re approval'.
-- +===========================================================================+
PROCEDURE reset_doc_status(p_doc_id NUMBER) IS
	l_module_name VARCHAR2(200);
BEGIN
	l_module_name := g_module_name || 'reset_doc_status';
	UPDATE   Fv_Be_Trx_hdrs
	SET	 doc_status = DECODE(revision_num,0,'IN','RA')
	WHERE	 doc_id =  p_doc_id
	AND   	 doc_status = 'IP';

	UPDATE 	Fv_Be_Trx_Dtls
	SET 	transaction_status = 'IN'
	WHERE	doc_id = p_doc_id
	AND   	transaction_status = 'IP'
	AND     revision_num IN(SELECT revision_num
					FROM fv_be_trx_hdrs
					WHERE doc_id = p_doc_id);
EXCEPTION WHEN OTHERS THEN
    g_retcode := 2;
    g_errbuf := 'Error reset_doc_status SQL Error is ' ||SQLERRM;
    Fv_Utility.Log_mesg(Fnd_Log.LEVEL_UNEXPECTED, l_module_name||
					'.final_exception',g_errbuf);
    RAISE;
END reset_doc_status;
-- +===========================================================================+
-- Global Variable Initilization
-- +===========================================================================+
BEGIN
	g_module_name := 'fv.plsql.FV_BE_FUND_PKG.';
	g_log_msg     := 'N';
END Fv_Be_Fund_Pkg; -- Package body

/
