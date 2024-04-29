--------------------------------------------------------
--  DDL for Package Body FV_AR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_AR_PKG" AS
    /* $Header: FVARPDRB.pls 115.4 2003/12/17 21:19:43 ksriniva noship $ */
  g_module_name VARCHAR2(100) := 'fv.plsql.FV_AR_PKG.';

PROCEDURE delete_offsetting_unapp(p_posting_control_id IN NUMBER,
	                          p_sob_id IN NUMBER,
				  p_status OUT NOCOPY NUMBER) IS
  l_module_name VARCHAR2(200) := g_module_name || 'delete_offsetting_unapp';
  l_errbuf VARCHAR2(1024);

-- This cursor identifies the cash_receipts where the total UNAPP debit
-- and UNAPP credit are equal and net out.
CURSOR 	get_unapp_amt(pcid IN NUMBER,
	              sob_id IN NUMBER) IS
	SELECT SUBSTR(reference22,1,INSTR(reference22,'C')-1) cash_receipt_id,
	       accounting_date,
	       SUM(entered_dr) entered_dr,
	       SUM(entered_cr) entered_cr,
	       SUM(accounted_dr) accounted_dr,
	       SUM(accounted_cr) accounted_cr
	FROM   gl_interface gi,
	       ar_cash_receipts cr
	WHERE gi.reference30 = 'AR_RECEIVABLE_APPLICATIONS'
	AND   gi.group_id = pcid
	AND   gi.user_je_source_name = 'Receivables'
	AND   gi.set_of_books_id = sob_id
	AND   substr(gi.reference29,7) = 'UNAPP'
	AND   cr.cash_receipt_id = substr(gi.reference22,1,instr(gi.reference22,'C')-1)
	GROUP BY SUBSTR(gi.reference22,1,INSTR(gi.reference22,'C')-1),
	          cr.amount, cr.status, gi.accounting_date
	HAVING SUM(entered_dr) =  SUM(entered_cr)
	   AND SUM(accounted_dr) =  SUM(accounted_cr)
	   AND cr.amount <> 0 ;

	TYPE NumTab IS TABLE OF NUMBER;
	TYPE DateTab IS TABLE OF DATE;
	cash_receipt_id_t  NumTab;
	entered_dr_t       NumTab;
	entered_cr_t       NumTab;
	accounted_dr_t     NumTab;
	accounted_cr_t     NumTab;
	accounting_date_t  DateTab;

	l_last_fetch BOOLEAN := FALSE;
--        g_debug VARCHAR2(1) :=  NVL(fnd_profile.value('FV_DEBUG_FLAG'),'N');

	BEGIN

           p_status := 0;

	   OPEN get_unapp_amt(p_posting_control_id, p_sob_id);
	   LOOP
	      FETCH get_unapp_amt BULK COLLECT INTO
	            cash_receipt_id_t,
	            accounting_date_t,
	            entered_dr_t,
	            entered_cr_t,
	            accounted_dr_t,
	            accounted_cr_t
	            LIMIT 1000;

	      IF get_unapp_amt%NOTFOUND THEN
	         l_last_fetch := TRUE;
	      END IF;

	      IF cash_receipt_id_t.COUNT = 0 and l_last_fetch
	         THEN
	          EXIT;
	      END IF;

	      FORALL j IN cash_receipt_id_t.FIRST..cash_receipt_id_t.LAST
	          DELETE FROM gl_interface
	          WHERE reference30 = 'AR_RECEIVABLE_APPLICATIONS'
	            AND group_id = p_posting_control_id
	            AND substr(reference29,7) = 'UNAPP'
	            AND substr(reference22,1,instr(reference22,'C')-1) =
						    cash_receipt_id_t(j)
	            AND accounting_date = accounting_date_t(j);

	      IF l_last_fetch THEN
	        EXIT;
	      END IF;

	   END LOOP;
     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FV_AR_PKG successfully completed.');
     END IF;

	 EXCEPTION WHEN OTHERS THEN
	     p_status := 1;
       l_errbuf := SQLERRM;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,'FV_AR_PKG COMPLETED WITH THE FOLLOWING ERROR:');
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,l_errbuf);

	END delete_offsetting_unapp;
END fv_ar_pkg;

/
