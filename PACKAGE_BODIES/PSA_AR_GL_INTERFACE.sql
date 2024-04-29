--------------------------------------------------------
--  DDL for Package Body PSA_AR_GL_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_AR_GL_INTERFACE" AS
/* $Header: PSAARTCB.pls 120.12 2006/09/13 11:47:25 agovil ship $ */

 --===========================FND_LOG.START=====================================
   g_state_level NUMBER   :=      FND_LOG.LEVEL_STATEMENT;
   g_proc_level  NUMBER   :=      FND_LOG.LEVEL_PROCEDURE;
   g_event_level NUMBER   :=      FND_LOG.LEVEL_EVENT;
   g_excep_level NUMBER   :=      FND_LOG.LEVEL_EXCEPTION;
   g_error_level NUMBER   :=      FND_LOG.LEVEL_ERROR;
   g_unexp_level NUMBER   :=      FND_LOG.LEVEL_UNEXPECTED;
   g_path        VARCHAR2(50)  := 'PSA.PLSQL.PSAARTCB.PSA_AR_GL_INTERFACE.';
 --===========================FND_LOG.END=======================================

PROCEDURE reset_transaction_codes
                (err_buf             OUT NOCOPY VARCHAR2,
                 ret_code            OUT NOCOPY VARCHAR2,
                 p_pstctrl_id        IN  VARCHAR2)
IS

 Cursor c_mfar_enabled (c_org_id IN NUMBER) IS
        Select status
        From psa_implementation_all
        Where org_id = c_org_id;

 l_org_id 	NUMBER:=arp_global.sysparam.org_id;
 l_sob_id	NUMBER:=arp_global.sysparam.set_of_books_id;
 l_enabled	psa_implementation_all.status%type;
 l_group_id	gl_interface.group_id%type;

 -- ========================= FND LOG ===========================
    l_full_path VARCHAR2(100) := g_path || 'Reset_transaction_codes';
 -- ========================= FND LOG ===========================

BEGIN

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,
                                       ' ########################## ');
     psa_utils.debug_other_string(g_state_level,l_full_path,
                                       ' ## Reset Transaction Codes START ## ');
     psa_utils.debug_other_string(g_state_level,l_full_path,
                                       ' ########################## ');
     psa_utils.debug_other_string(g_state_level,l_full_path,   '   '
                                  || to_char (sysdate, 'DD/MM/YYYY HH:MI:SS'));
     psa_utils.debug_other_string(g_state_level,l_full_path,'           ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS :');
     psa_utils.debug_other_string(g_state_level,l_full_path,' ============');
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_pstctrl_id -->' || p_pstctrl_id );
     psa_utils.debug_other_string(g_state_level,l_full_path,' Setting save point PSA_PSAARTCB' );
  -- ========================= FND LOG ===========================

  SAVEPOINT PSA_PSAARTCB;
  ret_code   := 'S';
  l_group_id := p_pstctrl_id;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' l_group_id  -->' || l_group_id );
     psa_utils.debug_other_string(g_state_level,l_full_path,'           ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' PROCESS : ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' ========= ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' l_sob_id    -->' || l_sob_id );
     psa_utils.debug_other_string(g_state_level,l_full_path,' l_org_id    -->' || l_org_id );
     psa_utils.debug_other_string(g_state_level,l_full_path,'           ');
  -- ========================= FND LOG ===========================

	UPDATE GL_INTERFACE
	   SET ussgl_transaction_code = NULL
	 WHERE user_je_source_name    = 'Receivables'
	   AND set_of_books_id	      = l_sob_id
   	   AND group_id               = l_group_id
	   AND ussgl_transaction_code IS NOT NULL
           AND ( (reference29 = 'MISC_CASH' AND reference30 = 'AR_CASH_RECEIPT_HISTORY')
  	         OR
                 (reference29 IN ('INV_REC','CB_REC','CM_REC','DM_REC','TRADE_CASH','TRADE_UNAPP','ADJ_REC'))
		 OR
		 ( arp_global.sysparam.accounting_method = 'CASH' AND
		   reference29 = 'TRADE_APP' 			  AND
		   reference30 = 'AR_RECEIVABLE_APPLICATIONS' ) );

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,' UPDATE GL_INTERFACE ## 1 -->'
                                                                  || SQL%ROWCOUNT );
        -- ========================= FND LOG ===========================

	--
	-- Bug 2805101: Update TC from cash receipt header on TRADE_UNAPP
	--              rows for unapplied receipts.
	--

	UPDATE GL_INTERFACE gl
	   SET gl.ussgl_transaction_code =
	   	( SELECT ussgl_transaction_code
	   	    FROM ar_cash_receipts cr
	   	   WHERE cr.cash_receipt_id = TO_NUMBER(SUBSTR(gl.reference22, 1, INSTR(gl.reference22, 'C')-1)))
	 WHERE gl.user_je_source_name    = 'Receivables'
	   AND gl.set_of_books_id	 = l_sob_id
   	   AND gl.group_id             	 = l_group_id
	   AND gl.reference29		 = 'TRADE_UNAPP'
	   AND gl.reference30		 = 'AR_RECEIVABLE_APPLICATIONS'
	   AND EXISTS
	   	( SELECT 'Cash Receipt Unapplied'
	   	    FROM ar_cash_receipts ar
	   	   WHERE ar.cash_receipt_id = TO_NUMBER(SUBSTR(gl.reference22, 1, INSTR(gl.reference22, 'C')-1))
	   	     AND status = 'UNAPP' );

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,' UPDATE GL_INTERFACE ## 2 -->'
                                                                  || SQL%ROWCOUNT );
        -- ========================= FND LOG ===========================

	--
	-- Bug 2805101: Update TC from cash receipt header on TRADE_UNAPP
	--              rows if receipt is applied after the unapplied receipt
	--              has been transferred previously.
	--

	UPDATE GL_INTERFACE gl
	   SET gl.ussgl_transaction_code =
	   	( SELECT ussgl_transaction_code
	   	    FROM ar_cash_receipts cr
	   	   WHERE cr.cash_receipt_id = TO_NUMBER(SUBSTR(gl.reference22, 1, INSTR(gl.reference22, 'C')-1)))
	 WHERE gl.user_je_source_name    = 'Receivables'
	   AND gl.set_of_books_id	 = l_sob_id
   	   AND gl.group_id             	 = l_group_id
	   AND gl.reference29		 = 'TRADE_UNAPP'
	   AND gl.reference30		 = 'AR_RECEIVABLE_APPLICATIONS'
	   AND NOT EXISTS
	   	( SELECT 'Cash Receipt Unapplied'
	   	    FROM ar_cash_receipts ar
	   	   WHERE ar.cash_receipt_id = TO_NUMBER(SUBSTR(gl.reference22, 1, INSTR(gl.reference22, 'C')-1))
	   	     AND status = 'UNAPP' )
	   AND NOT EXISTS
	          	( SELECT 'Receipt Applied In This Posting Run'
	          	    FROM gl_interface ar
	          	   WHERE ar.user_je_source_name	= 'Receivables'
			     AND ar.set_of_books_id	= l_sob_id
			     AND ar.group_id            = l_group_id
			     AND ar.reference29		= 'TRADE_CASH'
			     AND ar.reference30		= 'AR_CASH_RECEIPT_HISTORY'
			     AND SUBSTR(ar.reference22, 1, INSTR(ar.reference22, 'C')-1) =
			     		SUBSTR(gl.reference22, 1, INSTR(gl.reference22, 'C')-1) );


        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,' UPDATE GL_INTERFACE ## 3 -->'
                                                                  || SQL%ROWCOUNT );
        -- ========================= FND LOG ===========================


	IF l_org_id IS NOT NULL THEN

	   OPEN  c_mfar_enabled (l_org_id);
	   FETCH c_mfar_enabled INTO l_enabled;
	   CLOSE c_mfar_enabled;

           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,' l_enabled    -->' || l_enabled );
           -- ========================= FND LOG ===========================

	   IF l_enabled = 'Y' THEN

        	UPDATE GL_INTERFACE
        	   SET USSGL_TRANSACTION_CODE = NULL
        	 WHERE user_je_source_name    = 'Receivables'
		   AND set_of_books_id	      = l_sob_id
		   AND group_id               = l_group_id
       	 	   AND ussgl_transaction_code IS NOT NULL
        	   AND reference29     = 'TRADE_REC'
                   AND reference30     = 'AR_RECEIVABLE_APPLICATIONS'
		   AND is_mfar_transaction
		   		(TO_NUMBER(SUBSTR(reference22, INSTR(reference22, 'C')+1)), l_sob_id) = 'Y';

               -- ========================= FND LOG ===========================
                  psa_utils.debug_other_string(g_state_level,l_full_path,' UPDATE GL_INTERFACE ## 4 -->'
                                                                  || SQL%ROWCOUNT );
               -- ========================= FND LOG ===========================

	   END IF;
	END IF;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
                                       ' ########################## ');
       psa_utils.debug_other_string(g_state_level,l_full_path,
                                       ' ## Reset Transaction Codes END ## ');
       psa_utils.debug_other_string(g_state_level,l_full_path,
                                       ' ########################## ');
       psa_utils.debug_other_string(g_state_level,l_full_path,   '   '
                                  || to_char (sysdate, 'DD/MM/YYYY HH:MI:SS'));
       psa_utils.debug_other_string(g_state_level,l_full_path,'           ');
    -- ========================= FND LOG ===========================

EXCEPTION
 WHEN OTHERS THEN
      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_excep_level,l_full_path,
                                   ' --> EXCEPTION - OTHERS raised during PSA_AR_GL_INTERFACE.reset_transaction_codes ');
         psa_utils.debug_other_string(g_excep_level,l_full_path,   sqlcode || sqlerrm);
         psa_utils.debug_unexpected_msg(l_full_path);
      -- ========================= FND LOG ===========================

      BEGIN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path,'Rolling back');
         -- ========================= FND LOG ===========================
         ROLLBACK TO PSA_PSAARTCB;
      EXCEPTION
         WHEN OTHERS THEN
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_excep_level,l_full_path,
                     'EXCEPTION - OTHERS : SAVEPOINT ERASED.');
           -- ========================= FND LOG ===========================
      END;

      err_buf  :=  2;
      ret_code := 'F';

END reset_transaction_codes;

/* ################################ IS_MFAR_TRANSACTION ###################################### */

FUNCTION is_mfar_transaction (p_doc_id NUMBER, p_sob_id NUMBER) RETURN VARCHAR2
IS

 Cursor c_trx_id (c_doc_id IN NUMBER)
 IS
   Select applied_customer_trx_id
   From ar_receivable_applications
   Where receivable_application_id = c_doc_id;

 l_cust_trx_id 	NUMBER;
 l_mfar_type	VARCHAR2(1);


 -- ========================= FND LOG ===========================
    l_full_path VARCHAR2(100) := g_path || 'is_mfar_transaction';
 -- ========================= FND LOG ===========================

BEGIN

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,
                                       ' ## is_mfar_transaction START ## ');
     psa_utils.debug_other_string(g_state_level,l_full_path,'           ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS :');
     psa_utils.debug_other_string(g_state_level,l_full_path,' ============');
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_doc_id    -->' || p_doc_id );
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_sob_id    -->' || p_sob_id );
  -- ========================= FND LOG ===========================

 OPEN  c_trx_id(p_doc_id);
 FETCH c_trx_id INTO l_cust_trx_id;
 CLOSE c_trx_id;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' l_cust_trx_id    -->' || l_cust_trx_id );
  -- ========================= FND LOG ===========================

  IF PSA_MFAR_VAL_PKG.AR_MFAR_VALIDATE_CHECK (l_cust_trx_id, 'TRX', p_sob_id) = 'Y' THEN
     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN Y' );
     -- ========================= FND LOG ===========================
     RETURN 'Y';
  END IF;
  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,'  RETURN N ' );
  -- ========================= FND LOG ===========================
 RETURN 'N';

EXCEPTION
 WHEN OTHERS THEN
      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_excep_level,l_full_path,
                                   ' --> EXCEPTION - OTHERS raised during PSA_AR_GL_INTERFACE.is_mfar_transaction ');
         psa_utils.debug_other_string(g_excep_level,l_full_path,   sqlcode || sqlerrm);
         psa_utils.debug_unexpected_msg(l_full_path);
      -- ========================= FND LOG ===========================
      RETURN 'N';

END is_mfar_transaction;

END PSA_AR_GL_INTERFACE;

/
