--------------------------------------------------------
--  DDL for Package Body PSA_XFR_TO_GL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_XFR_TO_GL_PKG" AS
/* $Header: PSAMFG2B.pls 120.3 2006/09/13 12:49:36 agovil noship $ */

 /* ################################## GLOBAL VARIABLES DECLARE START ################################## */

 l_summary_flag            VARCHAR2(1);
 l_batch_prefix            VARCHAR2(100);         /* REFERENCE1 */
 l_func_curr               VARCHAR2(40);

 l_trade_cat_name          VARCHAR2(25);
 l_ccurr_cat_name          VARCHAR2(25);
 l_user_cm_cat_name        VARCHAR2(25);
 l_misc_cat_name           VARCHAR2(25);         /* CATEGORY */
 l_adj_cat_name            VARCHAR2(25);
 l_cm_cat_name             VARCHAR2(25);
 l_dm_cat_name             VARCHAR2(25);
 l_cb_cat_name             VARCHAR2(25);
 l_inv_cat_name            VARCHAR2(25);

 l_class_cb                VARCHAR2(2000);
 l_class_cm                VARCHAR2(2000);
 l_class_dep               VARCHAR2(2000);
 l_class_dm                VARCHAR2(2000);        /* CLASS */
 l_class_guar              VARCHAR2(2000);
 l_class_inv               VARCHAR2(2000);
 l_class_br                VARCHAR2(2000);

 l_pre_tradeapp            VARCHAR2(2000);
 l_app_onacc               VARCHAR2(2000);
 l_app_unapp               VARCHAR2(2000);
 l_app_unid                VARCHAR2(2000);
 l_app_applied             VARCHAR2(2000);

 l_pre_erdisc              VARCHAR2(2000);
 l_pre_rec_erdisc_nrtax    VARCHAR2(2000);
 l_pre_undisc              VARCHAR2(2000);
 l_pre_rec_undisc_nrtax    VARCHAR2(2000);
 l_pre_rec_gain            VARCHAR2(2000);
 l_pre_rec_loss            VARCHAR2(2000);
 l_pre_rec_curr_round      VARCHAR2(2000);
 l_pre_rec_deftax          VARCHAR2(2000);
 l_post_general            VARCHAR2(2000);
 l_pre_rec_tax             VARCHAR2(2000);

 l_pre_adj_nrtax           VARCHAR2(2000);
 l_pre_adj_finchrg         VARCHAR2(2000);
 l_pre_adj_finchrg_nrtax   VARCHAR2(2000);
 l_pre_adj_tax             VARCHAR2(2000);
 l_pre_adj_deftax          VARCHAR2(2000);

 l_pre_adjdr_ar            VARCHAR2(2000);
 l_pre_adjcr_ar            VARCHAR2(2000);
 l_pre_adjdr_adj           VARCHAR2(2000);
 l_pre_adjcr_adj           VARCHAR2(2000);
 l_pre_adjdr               VARCHAR2(2000);
 l_pre_adjcr               VARCHAR2(2000);
 l_pre_ct_line             VARCHAR2(2000);
 l_post_ct_line            VARCHAR2(2000);
 l_sob_id                  NUMBER(15);                              -- Sob_id
 l_user_id                 NUMBER(15);                              -- Created_by
 l_pst_ctrl_id             NUMBER(15);                              -- Group_id
 l_parent_request_id       NUMBER(15);  -- used in posting control cursor
 l_gl_start_date           VARCHAR2(20);
 l_post_through_date       VARCHAR2(20);
 l_source                  gl_je_sources.user_je_source_name%TYPE;        -- Source_name
 l_status                  VARCHAR2(30);                                  -- Status
 l_actual_flag             VARCHAR2(1);                                   -- Actual_flag

 -- Profile option FV: Post Detailed Receipt Accounting

 l_post_det_acct_flag	VARCHAR2(1) := 'Y';
 l_rct_post_det_flag	VARCHAR2(1) := 'Y';
 l_resp_appl_id         fnd_application.application_id%TYPE;
 l_user_resp_id         fnd_responsibility.responsibility_id%TYPE;
 l_error_message        VARCHAR2(3000);
 l_errbuf               VARCHAR2(30);
 l_retcode              VARCHAR2(30);
 INVALID_DISTRIBUTION    EXCEPTION;

 l_run_num		NUMBER(15);

 /* ################################## GLOBAL VARIABLES DECLARE END ################################## */

 --===========================FND_LOG.START=====================================
 g_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
 g_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
 g_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
 g_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
 g_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
 g_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
 g_path        VARCHAR2(50)  := 'PSA.PLSQL.PSAMFG2B.PSA_XFR_TO_GL_PKG.';
 --===========================FND_LOG.END=======================================

PROCEDURE Transfer_to_gl ( errbuf               OUT NOCOPY VARCHAR2,
                            retcode              OUT NOCOPY VARCHAR2,
                            p_set_of_books_id    IN  NUMBER,
                            p_gl_date_from       IN  VARCHAR2,
                            p_gl_date_to         IN  VARCHAR2,
                            p_gl_posted_date     IN  VARCHAR2,
                            p_parent_req_id      IN  NUMBER,
                            p_summary_flag       IN  VARCHAR2,
                            p_pst_ctrl_id        IN  NUMBER)

 IS

   MFAR_PROC_EXCEPTION  EXCEPTION;
   -- ========================= FND LOG ===========================
      l_full_path VARCHAR2(100) := g_path || 'Transfer_to_gl';
   -- ========================= FND LOG ===========================

 BEGIN

   -- ========================= FND LOG ===========================
   psa_utils.debug_other_string(g_state_level,l_full_path,
                                     ' ########################## ');
   psa_utils.debug_other_string(g_state_level,l_full_path,
                                     ' ## Transfer to gl START ## ');
   psa_utils.debug_other_string(g_state_level,l_full_path,
                                     ' ########################## ');
   psa_utils.debug_other_string(g_state_level,l_full_path,   '   '
                                || to_char (sysdate, 'DD/MM/YYYY HH:MI:SS'));
   psa_utils.debug_other_string(g_state_level,l_full_path,    '           ');
   psa_utils.debug_other_string(g_state_level,l_full_path,    ' PROCESS : ');
   psa_utils.debug_other_string(g_state_level,l_full_path,    ' ========= ');
   -- ========================= FND LOG ===========================

 /*
 ## This procedure will call the procedures in the following order
 ## 1. Transaction
 ## 2. Receipts
 ## 3. Miscellaneous receipts
 ## 4. Adjustments
 */

   retcode             := 'S';
   l_sob_id            := p_set_of_books_id;
   l_parent_request_id := p_parent_req_id;

   -- Bug 3767919 (Tpradhan)
   -- Assigning the value of p_pst_ctrl_id to variable l_pst_ctrl_id here.
   -- Assignment from populate_global_variables has been removed.

   l_pst_ctrl_id := p_pst_ctrl_id;

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,
                                     ' ##> value of l_pst_ctrl_id set to '||p_pst_ctrl_id);
      psa_utils.debug_other_string(g_state_level,l_full_path,
                                     ' ##> setting savepoint PSA_PSAMFG2B ');
   -- ========================= FND LOG ===========================
    SAVEPOINT PSA_PSAMFG2B;

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,
                                     ' ##> Now populating global variables ');
   -- ========================= FND LOG ===========================
   Populate_global_variables;

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,
                                   ' ##> Trasferring data to GL interface ');
   -- ========================= FND LOG ===========================

   IF arp_global.sysparam.accounting_method = 'ACCRUAL' THEN

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
                                      ' arp_global.sysparam.accounting_method ==> ACCRUAL ');
         psa_utils.debug_other_string(g_state_level,l_full_path,
                                       ' --> Calling Reverse_core_entries_if_any');
      -- ========================= FND LOG ===========================

      -- Bug 3621280.
      -- reversing Core CM applications if they dont balance by fund or Balance.
      Reverse_core_entries_if_any (errbuf,
                                   retcode,
                                   p_set_of_books_id,
                                   l_error_message);

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
                                      ' retcode ==> ' || retcode);
      -- ========================= FND LOG ===========================

      IF retcode = 'F' THEN
         RAISE MFAR_PROC_EXCEPTION;
      END IF;

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
                                      ' Calling MFAR_Trx_to_gl ');
      -- ========================= FND LOG ===========================

      MFAR_Trx_to_gl ( errbuf,
                       retcode,
                       p_set_of_books_id,
                       p_gl_date_from,
                       p_gl_date_to,
                       p_gl_posted_date,
                       p_summary_flag);

     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,
                                     ' retcode ==> ' || retcode);
     -- ========================= FND LOG ===========================

     IF retcode = 'F' THEN
        RAISE MFAR_PROC_EXCEPTION;
     END IF;

     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,
                                     ' Calling MFAR_Rcpt_to_gl ');
     -- ========================= FND LOG ===========================

     MFAR_Rcpt_to_gl (errbuf,
                      retcode,
                      p_set_of_books_id,
                      p_gl_date_from ,
                      p_gl_date_to,
                      p_gl_posted_date,
                      p_summary_flag);

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
                                    ' retcode ==> ' || retcode);
    -- ========================= FND LOG ===========================

    IF retcode = 'F' THEN
       RAISE MFAR_PROC_EXCEPTION;
    END IF;

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,
                                   ' Calling Misc_rct_to_gl ');
   -- ========================= FND LOG ===========================

   Misc_rct_to_gl( errbuf,
                   retcode,
                   p_set_of_books_id,
                   p_gl_date_from,
                   p_gl_date_to ,
                   p_gl_posted_date);

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,
                                   ' retcode ==> ' || retcode);
   -- ========================= FND LOG ===========================

   IF retcode = 'F' THEN
      RAISE MFAR_PROC_EXCEPTION;
   END IF;

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,
                                   ' Calling MFAR_Adj_to_gl ');
   -- ========================= FND LOG ===========================

   MFAR_Adj_to_gl ( errbuf,
                   retcode,
                   p_set_of_books_id,
                   p_gl_date_from,
                   p_gl_date_to,
                   p_gl_posted_date,
                   p_summary_flag);

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,
                                     ' retcode ==> ' || retcode);
   -- ========================= FND LOG ===========================

   IF retcode = 'F' THEN
      RAISE MFAR_PROC_EXCEPTION;
   END IF;

 ELSIF arp_global.sysparam.accounting_method = 'CASH' THEN

   -- ========================= FND LOG ===========================
   psa_utils.debug_other_string(g_state_level,l_full_path,
                                     ' arp_global.sysparam.accounting_method ==> CASH ');
   psa_utils.debug_other_string(g_state_level,l_full_path,
                                     ' Calling MFAR_Rcpt_to_gl_CB ');
   -- ========================= FND LOG ===========================

  MFAR_Rcpt_to_gl_CB
		  (errbuf,
                   retcode,
                   p_set_of_books_id,
                   p_gl_date_from ,
                   p_gl_date_to,
                   p_gl_posted_date,
                   p_summary_flag);

   -- ========================= FND LOG ===========================
   psa_utils.debug_other_string(g_state_level,l_full_path,
                                     ' retcode ==> ' || retcode);
   -- ========================= FND LOG ===========================

  IF retcode = 'F' THEN
     RAISE MFAR_PROC_EXCEPTION;
  END IF;

   -- ========================= FND LOG ===========================
   psa_utils.debug_other_string(g_state_level,l_full_path,
                                     ' Calling Misc_rct_to_gl_CB ');
   -- ========================= FND LOG ===========================

  Misc_rct_to_gl_CB
		  (errbuf,
                   retcode,
                   p_set_of_books_id,
                   p_gl_date_from,
                   p_gl_date_to ,
                   p_gl_posted_date);

   -- ========================= FND LOG ===========================
   psa_utils.debug_other_string(g_state_level,l_full_path,
                                     ' retcode ==> ' || retcode);
   -- ========================= FND LOG ===========================

  IF retcode = 'F' THEN
     RAISE MFAR_PROC_EXCEPTION;
  END IF;

END IF;

    IF psa_mfar_utils.g_invalid_index > 0 THEN
        FND_MESSAGE.SET_NAME ('PSA', 'PSA_INVALID_CODE_COMBINATION');
  	    psa_utils.debug_other_msg(p_level => g_error_level,
		  	p_full_path => l_full_path,
		  	p_remove_from_stack => FALSE);
            fnd_file.put_line(fnd_file.log, fnd_message.get);
            fnd_file.put_line(fnd_file.log, ' ');

        FOR i IN 1..psa_mfar_utils.g_invalid_index LOOP
            fnd_file.put_line(fnd_file.log, psa_mfar_utils.g_invalid_combinations(i).combination );
            fnd_file.put_line(fnd_file.log, psa_mfar_utils.g_invalid_combinations(i).error_message);
            fnd_file.put_line(fnd_file.log, ' ');
        END LOOP;
        RAISE MFAR_PROC_EXCEPTION;
    END IF;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,
                                   ' ##> Updating GL interface with proper segments ');
  -- ========================= FND LOG ===========================

  Upd_seg_in_gl_interface;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,   '            ');
     psa_utils.debug_other_string(g_state_level,l_full_path,
                                    '           ############################## ');
     psa_utils.debug_other_string(g_state_level,l_full_path,
                                   '           #### Transfer to gl END   #### ');
     psa_utils.debug_other_string(g_state_level,l_full_path,
                                   '           ############################## ');
     psa_utils.debug_other_string(g_state_level,l_full_path,
                                   '               ' || to_char (sysdate, 'DD/MM/YYYY HH:MI:SS'));
  -- ========================= FND LOG ===========================

 EXCEPTION
    WHEN MFAR_PROC_EXCEPTION THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path,
	                                'EXCEPTION - MFAR_PROC_EXCEPTION : ERROR IN PSA_TRANSFER_TO_GL_PKG.TRANSFER_TO_GL');
         -- ========================= FND LOG ===========================

        BEGIN
          -- ========================= FND LOG ===========================
             psa_utils.debug_other_string(g_excep_level,l_full_path,'Rolling back');
          -- ========================= FND LOG ===========================
          ROLLBACK TO PSA_PSAMFG2B;
        EXCEPTION
          WHEN OTHERS THEN
               -- ========================= FND LOG ===========================
                  psa_utils.debug_other_string(g_excep_level,l_full_path,
                                        'EXCEPTION - MFAR_PROC_EXCEPTION : SAVEPOINT ERASED.');
               -- ========================= FND LOG ===========================
        END;
        retcode := 'F';

    WHEN OTHERS THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path,'EXCEPTION - OTHERS : ERROR IN PSA_TRANSFER_TO_GL_PKG.TRANSFER_TO_GL');
            psa_utils.debug_other_string(g_excep_level,l_full_path,   sqlcode || sqlerrm);
            psa_utils.debug_unexpected_msg(l_full_path);
         -- ========================= FND LOG ===========================

        BEGIN
          -- ========================= FND LOG ===========================
             psa_utils.debug_other_string(g_excep_level,l_full_path, 'Rolling back');
          -- ========================= FND LOG ===========================
          ROLLBACK TO PSA_PSAMFG2B;
        EXCEPTION
          WHEN OTHERS THEN
               -- ========================= FND LOG ===========================
                  psa_utils.debug_other_string(g_excep_level,l_full_path,
                                        'EXCEPTION - OTHERS : SAVEPOINT ERASED.');
               -- ========================= FND LOG ===========================
        END;
        retcode := 'F';

 END Transfer_to_gl;

/*###################################### MISC_RCT_TO_GL ###########################################*/

 PROCEDURE Misc_rct_to_gl (errbuf               OUT NOCOPY VARCHAR2,
                           retcode              OUT NOCOPY VARCHAR2,
                           p_set_of_books_id    IN  NUMBER,
                           p_gl_date_from       IN  VARCHAR2,
                           p_gl_date_to         IN  VARCHAR2,
                           p_gl_posted_date     IN  VARCHAR2)
 IS

   CURSOR c_crh_post
   IS
          SELECT cash_receipt_history_id FROM ar_cash_receipt_history
	  WHERE  posting_control_id   = l_pst_ctrl_id
          AND    cash_receipt_history_id NOT IN
	         (SELECT cash_receipt_history_id FROM psa_misc_posting);

   CURSOR c_create_dist
   IS
          SELECT cr.cash_receipt_id FROM ar_cash_receipts cr, ar_cash_receipt_history crh
	  WHERE  cr.cash_receipt_id = crh.cash_receipt_id
          AND    crh.posting_control_id = l_pst_ctrl_id;


-- GL Transfer will have 4 cursors
-- cursor 1 inserts records into gl_interface for a simple misc receipt and its reversal entries.
-- Cursor 2 inserts records that reverse core entries
-- Cursor 3 inserts records for MFAR Entries resulting from more activties on the receipt (like clearing, unclearing..)

   CURSOR Cur_MFAR_mrct_lines
   IS
          SELECT
           mfd.gl_date                                             gl_date,
           cr.doc_sequence_id                                      doc_seqid,
           cr.doc_sequence_value                                   doc_num,
           ard.currency_code                                       currency,
     	   decode(to_number(l1.lookup_code),
                                 1, mfd.cash_ccid, 2, ard2.code_combination_id)
                                                                    ccid,
           decode(to_number(l1.lookup_code), 1, ard.amount_cr, 2, ard.amount_dr)  entered_dr,
           decode(to_number(l1.lookup_code),1, ard.amount_dr, 2, ard.amount_cr)    entered_cr,
           decode(to_number(l1.lookup_code),1, ard.acctd_amount_cr,	2, ard.acctd_amount_dr)  accounted_dr,
           decode(to_number(l1.lookup_code),1, ard.acctd_amount_dr,	2, ard.acctd_amount_cr)  accounted_cr,
           l_batch_prefix || TO_CHAR(l_pst_ctrl_id)                ref1,
           DECODE(to_number(l1.lookup_code),1, ('MFAR Misc. Receipt ' || cr.receipt_number),
                                            2,('Receipt ' || cr.receipt_number||'(MFAR)'))  ref10,
           TO_CHAR (mcd.posting_control_id)                        ref21,
           TO_CHAR (cr.cash_receipt_id)                            ref22,
           TO_CHAR (ard.line_id)			           ref23,
           cr.receipt_number                                       ref24,
           TO_CHAR (mcd.misc_cash_distribution_id)                 ref25,
           NULL                                                    ref26,
           'c1'                                                    ref27,
           'MISC'                                                  ref28,
           'MISC_' || ard.source_type                              ref29,
	   'PSA_MF_MISC_DIST_ALL'                                  ref30
	FROM
	   psa_mf_misc_dist_all           mfd,
           psa_lookup_codes               l1,
           ar_misc_cash_distributions     mcd,
	   ar_distributions               ard,
	   ar_cash_receipts               cr,
           ar_cash_receipt_history        crh,
           ar_distributions               ard2
        WHERE
             l1.lookup_type                = 'PSA_CARTESIAN_JOIN'
        AND  l1.lookup_code IN ('1','2')
        AND  mfd.misc_cash_distribution_id = mcd.misc_cash_distribution_id
        AND  nvl(mfd.posting_control_id,-3)= -3
        AND  crh.status                    = mfd.reference1
        AND  mcd.posting_control_id        = l_pst_ctrl_id
        AND  mcd.set_of_books_id           = l_sob_id
        AND  mcd.cash_receipt_id           = cr.cash_receipt_id
        AND  ard.source_table              = 'MCD'
        AND  ard.source_id                 = mcd.misc_cash_distribution_id
        AND  cr.cash_receipt_id            = crh.cash_receipt_id
        AND  crh.posting_control_id        = l_pst_ctrl_id
        AND  ((crh.first_posted_record_flag = 'Y') OR (crh.current_record_flag = 'Y' AND crh.status = 'REVERSED'))
        AND  crh.cash_receipt_history_id = ard2.source_id
        AND  ard2.source_table = 'CRH'
        AND  (ard2.amount_cr is null or ard2.amount_cr > 0);


   CURSOR Cur_MFAR_crct_hist_lines
   IS
        SELECT
           crh.gl_date                                                     gl_date,
           cr.doc_sequence_id                                              doc_seqid,
           cr.doc_sequence_value                                           doc_num,
           cr.currency_code                                                currency,
           ard.code_combination_id                                         ccid,
           to_number(ard.amount_cr)                                        entered_dr,
           to_number(ard.amount_dr)                                        entered_cr,
           to_number(ard.acctd_amount_cr)                                  accounted_dr,
           to_number(ard.acctd_amount_dr)                                  accounted_cr,
           l_batch_prefix || TO_CHAR (l_pst_ctrl_id)                       ref1,
           ('Receipt ' || cr.receipt_number||'(MFAR)')    ref10,
           TO_CHAR (l_pst_ctrl_id)                                         ref21,
           DECODE(cr.type,
                  'CASH',TO_CHAR(cr.cash_receipt_id)||'C'||
                         TO_CHAR(crh.cash_receipt_history_id),
                  'MISC',TO_CHAR(cr.cash_receipt_id))                      ref22,
           TO_CHAR(ard.line_id)                                            ref23,
           cr.receipt_number                                               ref24,
           DECODE(cr.type,
                  'CASH',TO_CHAR(NULL),
                  'MISC',TO_CHAR(crh.cash_receipt_history_id))             ref25,
           TO_CHAR(NULL)                                                   ref26,
           'c2'                                                            ref27,
           DECODE( cr.type,
                  'MISC', 'MISC',
                  'TRADE')                                                 ref28,
           DECODE( cr.type,
                  'MISC', 'MISC_',
                  'TRADE_') || ard.source_type                             ref29,
           'AR_CASH_RECEIPT_HISTORY'                                      ref30
        FROM
            ar_cash_receipt_history     crh,
	    psa_receivables_trx_all     psa,
	    ar_distributions            ard,
            ar_cash_receipts            cr
        WHERE
	     crh.status <> 'REVERSED'
        AND  crh.posting_control_id      = l_pst_ctrl_id
        AND  crh.cash_receipt_id         = cr.cash_receipt_id
	AND  cr.receivables_trx_id       = psa.psa_receivables_trx_id
        AND  cr.set_of_books_id          = l_sob_id
        AND  ard.source_table            = 'CRH'
        AND  ard.source_id               = crh.cash_receipt_history_id
        AND  nvl(crh.first_posted_record_flag, 'N')          = 'N';



   CURSOR Cur_MFAR_LINES
   IS
        SELECT
           mfd.gl_date                                                     gl_date,
           cr.doc_sequence_id                                              doc_seqid,
           cr.doc_sequence_value                                           doc_num,
           cr.currency_code                                                currency,
      	   decode(to_number(l1.lookup_code), 1, mfd.cash_ccid)             ccid,
                                             -- 2, mfd.reversal_ccid)  ccid, -- rgopalan
           decode(crh.status, 'CLEARED', decode(to_number(l1.lookup_code),1, mcd.amount, null),
		                      'REMITTED',decode(to_number(l1.lookup_code),2, mcd.amount, null))  entered_dr,
           decode(crh.status, 'CLEARED', decode(to_number(l1.lookup_code),2, mcd.amount, null),
		                      'REMITTED',decode(to_number(l1.lookup_code),1, mcd.amount, null))  entered_cr,
           decode(crh.status, 'CLEARED', decode(to_number(l1.lookup_code),1, mcd.amount, null),
		                      'REMITTED',decode(to_number(l1.lookup_code),2, mcd.amount, null))  accounted_dr,
           decode(crh.status, 'CLEARED', decode(to_number(l1.lookup_code),2, mcd.amount, null),
		                      'REMITTED',decode(to_number(l1.lookup_code),1, mcd.amount, null))  accounted_cr,
           l_batch_prefix || TO_CHAR (l_pst_ctrl_id)                       ref1,
           DECODE(l1.lookup_code,1, ('MFAR Cash ' || cr.receipt_number),
                                 2,('MFAR Remittance ' || cr.receipt_number))  ref10,
           TO_CHAR (l_pst_ctrl_id)                                         ref21,
           DECODE(cr.type,
                  'CASH',TO_CHAR(cr.cash_receipt_id)||'C'||
                         TO_CHAR(crh.cash_receipt_history_id),
                  'MISC',TO_CHAR(cr.cash_receipt_id))                      ref22,
--           TO_CHAR(mfd.misc_cash_distribution_id)                                            ref23,
	   nvl( get_misc_ard_id(mfd.misc_cash_distribution_id),
                to_char(mfd.misc_cash_distribution_id) )                   ref23,
           cr.receipt_number                                               ref24,
           DECODE(cr.type,
                  'CASH',TO_CHAR(NULL),
                  'MISC',TO_CHAR(crh.cash_receipt_history_id))             ref25,
           TO_CHAR(NULL)                                                   ref26,
           'c3'                                   ref27,
           DECODE( cr.type,
                  'MISC', 'MISC',
                  'TRADE')                                                 ref28,
           DECODE( cr.type,
                  'MISC', 'MISC_',
                  'TRADE_')                                      ref29,
           'PSA_MF_MISC_DIST_ALL'                                      ref30
        FROM
	   psa_mf_misc_dist_all           mfd,
           psa_lookup_codes               l1,
	   ar_misc_cash_distributions     mcd,
	   ar_cash_receipts               cr,
           ar_cash_receipt_history        crh,
           ar_cash_receipt_history        crhold
       WHERE
              mfd.reference1 = 'CLEARED'
	AND   l1.lookup_type                = 'PSA_CARTESIAN_JOIN'
        AND   l1.lookup_code IN (1,2)
        AND   mfd.misc_cash_distribution_id = mcd.misc_cash_distribution_id
        AND   mcd.set_of_books_id           = l_sob_id
        AND   mcd.cash_receipt_id           = cr.cash_receipt_id
        AND   cr.cash_receipt_id            = crh.cash_receipt_id
        AND   crh.posting_control_id        = l_pst_ctrl_id
        AND   crh.cash_receipt_history_id   = crhold.reversal_cash_receipt_hist_id
        AND   nvl(crh.first_posted_record_flag, 'N')          = 'N'
        AND   ((crh.STATUS <> 'REVERSED'));


   PSA_MISC_GLX_FAIL EXCEPTION;
   -- ========================= FND LOG ===========================
   l_full_path VARCHAR2(100) := g_path || 'misc_rc_to_gl';
   -- ========================= FND LOG ===========================

 BEGIN

  -- ========================= FND LOG ===========================
  psa_utils.debug_other_string(g_state_level,l_full_path,   '                ');
  psa_utils.debug_other_string(g_state_level,l_full_path,
                                   '                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
  psa_utils.debug_other_string(g_state_level,l_full_path,
	                           '                   (TRANSFERRING MISCELLANEOUS RECEIPTS) '
				   || to_char (sysdate, 'DD/MM/YYYY HH:MI:SS'));
  psa_utils.debug_other_string(g_state_level,l_full_path,
                                   '                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
  psa_utils.debug_other_string(g_state_level,l_full_path,   '                ');
  -- ========================= FND LOG ===========================

  retcode := 'S';

  l_gl_start_date        := p_gl_date_from;
  l_post_through_date    := p_gl_date_to;
  l_sob_id               := p_set_of_books_id;

  -- ========================= FND LOG ===========================
  psa_utils.debug_other_string(g_state_level,l_full_path,   '             ');
  psa_utils.debug_other_string(g_state_level,l_full_path,   ' PARAMETERS :');
  psa_utils.debug_other_string(g_state_level,l_full_path,   ' ============');
  psa_utils.debug_other_string(g_state_level,l_full_path,
                                    ' p_gl_date_from    -->' || p_gl_date_from );
  psa_utils.debug_other_string(g_state_level,l_full_path,
                                    ' p_gl_date_to      -->' || p_gl_date_to );
  psa_utils.debug_other_string(g_state_level,l_full_path,
                                    ' p_set_of_books_id -->' || p_set_of_books_id);
  psa_utils.debug_other_string(g_state_level,l_full_path,   '             ');
  psa_utils.debug_other_string(g_state_level,l_full_path,   ' OTHER VALUES :');
  psa_utils.debug_other_string(g_state_level,l_full_path,   ' =============  ');
  psa_utils.debug_other_string(g_state_level,l_full_path,
                                    ' l_gl_start_date     -->' || l_gl_start_date);
  psa_utils.debug_other_string(g_state_level,l_full_path,
                                    ' l_post_through_date -->' || l_post_through_date);
  psa_utils.debug_other_string(g_state_level,l_full_path,
                                    ' l_sob_id            -->' || l_sob_id);
  psa_utils.debug_other_string(g_state_level,l_full_path,   '          ');
  psa_utils.debug_other_string(g_state_level,l_full_path,   ' PROCESS :');
  psa_utils.debug_other_string(g_state_level,l_full_path,   ' =========');
  psa_utils.debug_other_string(g_state_level,l_full_path,   '          ');
  -- ========================= FND LOG ===========================

  BEGIN

    /*
    ##  Call Create Misc Distributions program to create Multi-fund Distributions
    ##  for receipts that fall within the GL DATE parameters.
    */

    -- ========================= FND LOG ===========================
    psa_utils.debug_other_string(g_state_level,l_full_path,
                                     ' --> Creating Distributions for Misc Receipts');
    -- ========================= FND LOG ===========================

    FOR I IN c_create_dist
    LOOP

       IF (I.cash_receipt_id IS NOT NULL) THEN

          IF NOT (PSA_MF_CREATE_DISTRIBUTIONS.create_distributions (errbuf             => l_errbuf,
                                                                    retcode            => l_retcode,
                                                                    p_mode             => 'R',
                                                                    p_document_id      => I.cash_receipt_id,
                                                                    p_set_of_books_id  => l_sob_id,
                                                                    run_num            => l_run_num,
                                                                    p_error_message    => l_error_message,
                                                                    p_report_only      => 'N')) THEN

                  -- ========================= FND LOG ===========================
                     psa_utils.debug_other_string(g_excep_level,l_full_path,
                                  ' --> PSA_MF_CREATE_DISTRIBUTIONS.create_distributions -> FALSE');
                  -- ========================= FND LOG ===========================

                  IF l_error_message IS NOT NULL OR l_retcode = 'F' THEN
                     -- ========================= FND LOG ===========================
                        psa_utils.debug_other_string(g_excep_level,l_full_path,
		                                   ' --> Raising  invalid_distribution');
                     -- ========================= FND LOG ===========================
                    Raise INVALID_DISTRIBUTION;
                  END IF;
          ELSE
                 -- ========================= FND LOG ===========================
                    psa_utils.debug_other_string(g_state_level,l_full_path,
		                                 ' --> Cash receipt id --> ' || I.cash_receipt_id);
                 -- ========================= FND LOG ===========================
          END IF;
       END IF;

    END LOOP;
  END;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,
				 ' --> Inserting into GL INTERFACE foor - PSA_MF_MISC_DIST_ALL');
  -- ========================= FND LOG ===========================

   FOR J IN Cur_MFAR_mrct_lines
   LOOP

      INSERT INTO gl_interface
	        (created_by,
	         date_created,
	         status,
	         actual_flag,
	         group_id,
	         set_of_books_id,
	         user_je_source_name,
	         user_je_category_name,
	         accounting_date,
	         subledger_doc_sequence_id,
	         subledger_doc_sequence_value,
	         currency_code,
	         code_combination_id,
	         entered_dr,
	         entered_cr,
	         accounted_dr,
	         accounted_cr,
	         reference1,
	         reference10,
	         reference21,
	         reference22,
	         reference23,
	         reference24,
	         reference25,
	         reference26,
	         reference27,
	         reference28,
	         reference29,
	         reference30)
        VALUES  (l_user_id,
                 trunc(sysdate),
                 l_status,
                 l_actual_flag,
                 l_pst_ctrl_id,
                 l_sob_id,
                 l_source,
                 l_misc_cat_name,
                 J.gl_date,
	         J.doc_seqid,
	         J.doc_num,
	         J.currency,
	         J.ccid,
	         J.entered_dr,
	         J.entered_cr,
	         J.accounted_dr,
	         J.accounted_cr,
	         J.ref1,
	         J.ref10,
	         J.ref21,
	         J.ref22,
	         J.ref23,
	         J.ref24,
	         J.ref25,
	         J.ref26,
	         J.ref27,
	         J.ref28,
	         J.ref29,
	         J.ref30);

         IF (SQL%FOUND) THEN
            -- ========================= FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path,
	                                     ' --> Receipt Number ==> ' || J.ref24 );
               psa_utils.debug_other_string(g_state_level,l_full_path,
	                                     ' CCID   => ' || J.ccid
                                          || ' DEBIT  => ' || J.entered_dr
                                          || ' CREDIT => ' || J.entered_cr);
            -- ========================= FND LOG ===========================
         END IF;

   END LOOP;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,
                                  ' --> Inserting into GL INTERFACE for - PSA_MF_REVERSE_OF_AR_CRH');
  -- ========================= FND LOG ===========================

   FOR J IN Cur_MFAR_crct_hist_lines
   LOOP

     /*
     ## For each misc_cash_distribution_id the record will be inserted.
     */

      INSERT INTO gl_interface
	        (created_by,
	         date_created,
	         status,
	         actual_flag,
	         group_id,
	         set_of_books_id,
	         user_je_source_name,
	         user_je_category_name,
	         accounting_date,
	         subledger_doc_sequence_id,
	         subledger_doc_sequence_value,
	         currency_code,
	         code_combination_id,
	         entered_dr,
	         entered_cr,
	         accounted_dr,
	         accounted_cr,
	         reference1,
	         reference10,
	         reference21,
	         reference22,
	         reference23,
	         reference24,
	         reference25,
	         reference26,
	         reference27,
	         reference28,
	         reference29,
	         reference30)
        VALUES  (l_user_id,
                 trunc(sysdate),
                 l_status,
                 l_actual_flag,
                 l_pst_ctrl_id,
                 l_sob_id,
                 l_source,
                 l_misc_cat_name,
                 J.gl_date,
	         J.doc_seqid,
	         J.doc_num,
	         J.currency,
	         J.ccid,
	         J.entered_dr,
	         J.entered_cr,
	         J.accounted_dr,
	         J.accounted_cr,
	         J.ref1,
	         J.ref10,
	         J.ref21,
	         J.ref22,
	         J.ref23,
	         J.ref24,
	         J.ref25,
	         J.ref26,
	         J.ref27,
	         J.ref28,
	         J.ref29,
	         J.ref30);

         IF (SQL%FOUND) THEN
            -- ========================= FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path,
	                                     ' --> Receipt Number ==> ' || J.ref24);
               psa_utils.debug_other_string(g_state_level,l_full_path,
	                                     ' CCID   => ' || J.ccid
					   ||' DEBIT  => ' || J.entered_dr
                                           ||' CREDIT => ' || J.entered_cr );
            -- ========================= FND LOG ===========================
         END IF;
   END LOOP;

   FOR K IN Cur_MFAR_LINES
   LOOP

      INSERT INTO gl_interface
	        (created_by,
	         date_created,
	         status,
	         actual_flag,
	         group_id,
	         set_of_books_id,
	         user_je_source_name,
	         user_je_category_name,
	         accounting_date,
	         subledger_doc_sequence_id,
	         subledger_doc_sequence_value,
	         currency_code,
	         code_combination_id,
	         entered_dr,
	         entered_cr,
	         accounted_dr,
	         accounted_cr,
	         reference1,
	         reference10,
	         reference21,
	         reference22,
	         reference23,
	         reference24,
	         reference25,
	         reference26,
	         reference27,
	         reference28,
	         reference29,
	         reference30)
        VALUES  (l_user_id,
                 trunc(sysdate),
                 l_status,
                 l_actual_flag,
                 l_pst_ctrl_id,
                 l_sob_id,
                 l_source,
                 l_misc_cat_name,
                 K.gl_date,
	         K.doc_seqid,
	         K.doc_num,
	         K.currency,
	         K.ccid,
	         K.entered_dr,
	         K.entered_cr,
	         K.accounted_dr,
	         K.accounted_cr,
	         K.ref1,
	         K.ref10,
	         K.ref21,
	         K.ref22,
	         K.ref23,
	         K.ref24,
	         K.ref25,
	         K.ref26,
	         K.ref27,
	         K.ref28,
	         K.ref29,
	         K.ref30);

         IF (SQL%FOUND) THEN
            -- ========================= FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path,
	                                    ' --> Receipt Number ==> ' || K.ref24);
               psa_utils.debug_other_string(g_state_level,l_full_path,
		                            ' CCID   => ' || K.ccid
				         || ' DEBIT  => ' || K.entered_dr
					 || ' CREDIT => ' || K.entered_cr );
            -- ========================= FND LOG ===========================
         END IF;

  END LOOP;

 /*
 ## Insert a record into psa_misc_posting to keep track of
 ## each reversing record of AR_CASH_RECEIPT_HISTORY, that we insert into GL_INTERFACE
 */

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,
                                    ' --> Inserting into psa_misc_posting ');
  -- ========================= FND LOG ===========================

  FOR J IN c_crh_post
  LOOP

      INSERT INTO psa_misc_posting (cash_receipt_history_id,   posting_control_id)
                            VALUES (J.cash_receipt_history_id, l_pst_ctrl_id);

     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,
                                     ' --> Cash receipt hist id --> ' || J.cash_receipt_history_id);
     -- ========================= FND LOG ===========================

  END LOOP;

     UPDATE psa_mf_misc_dist_all
     SET    posting_control_id = l_pst_ctrl_id
     WHERE  misc_cash_distribution_id IN
           (SELECT misc_cash_distribution_id FROM ar_misc_cash_distributions
            WHERE  posting_control_id = l_pst_ctrl_id);

     IF (SQL%FOUND) THEN
         -- ====================== FND LOG ==========================
            psa_utils.debug_other_string(g_state_level,l_full_path,
	                                ' --> (PSA_MF_MISC_DIST_ALL) Updated Posting control id for '
					|| (SQL%ROWCOUNT));
	 -- ====================== FND LOG ==========================
     END IF;

     -- Bug3967158
     -- delete all such records in psa_mf_misc_dist_all that
     -- do not have the matching records on core distributions

     DELETE FROM psa_mf_misc_dist_all
     WHERE  posting_control_id = l_pst_ctrl_id
     AND    misc_cash_distribution_id NOT IN
            (SELECT misc_cash_distribution_id
             FROM   ar_misc_cash_distributions
             WHERE  posting_control_id = l_pst_ctrl_id);

     IF (SQL%FOUND) THEN
         -- ====================== FND LOG ==========================
            psa_utils.debug_other_string(g_state_level,l_full_path,
                                        ' --> (PSA_MF_MISC_DIST_ALL) Deleted --> '
                                        || (SQL%ROWCOUNT));
         -- ====================== FND LOG ==========================
     END IF;

     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,
                                       ' --> END of MISC TRANSACTIONS '
				    || to_char (sysdate, 'DD/MM/YYYY HH:MI:SS'));
     -- ========================= FND LOG ===========================

 EXCEPTION
    WHEN INVALID_DISTRIBUTION THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                     ' --> EXCEPTION - INVALID_DISTRIBUTION raised during PSA_TRANSFER_TO_GL_PKG.Misc_rct_to_gl ');
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                         ' --> p_error_message  --> ' || l_error_message);
         -- ========================= FND LOG ===========================
         retcode  := 'F';

   WHEN OTHERS THEN
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_excep_level,l_full_path,
                                     ' --> EXCEPTION - OTHERS raised during PSA_TRANSFER_TO_GL_PKG.Misc_rct_to_gl ');
           psa_utils.debug_other_string(g_excep_level,l_full_path,   sqlcode || sqlerrm);
           psa_utils.debug_unexpected_msg(l_full_path);
        -- ========================= FND LOG ===========================
        errbuf  := 2;
        retcode := 'F';

 END  Misc_rct_to_gl;

 /*########################################## MFAR_TRX_TO_GL  ###########################################*/

 PROCEDURE Mfar_trx_to_gl (errbuf               OUT NOCOPY VARCHAR2,
                           retcode              OUT NOCOPY VARCHAR2,
                           p_set_of_books_id    IN  NUMBER,
                           p_gl_date_from       IN  VARCHAR2,
                           p_gl_date_to         IN  VARCHAR2,
                           p_gl_posted_date     IN  VARCHAR2,
                           p_summary_flag       IN  VARCHAR2)
 IS

  v_customer_trx_id NUMBER(15);

  /*
  ## This procedure will Transfer transactions to gl_interface table like CREDIT MEMO, DEBIT MEMO, CHARGE BACKS.
  */

  /* The l_ variables used in this cursor are Global variables in this package */
  CURSOR Cur_MFAR_cust_trx_id
  IS
	-- Bug 3757993 (Tpradhan) .. Start
	-- Added UNION clauses to select transactions associated with receipts and adjustments
 	SELECT ctlgd.customer_trx_id  customer_trx_id
	FROM   ra_cust_trx_line_gl_dist ctlgd
	WHERE  ctlgd.posting_control_id   =  l_pst_ctrl_id
	AND    DECODE (PSA_MFAR_VAL_PKG.ar_mfar_validate_check (ctlgd.customer_trx_id, 'TRX', l_sob_id),
			'Y', 'MFAR_TYPE', 'NOT_MFAR_TYPE') =  'MFAR_TYPE'
	UNION
	SELECT customer_trx_id
	FROM   ar_adjustments adj
	WHERE  adj.posting_control_id  = l_pst_ctrl_id
	AND    DECODE (PSA_MFAR_VAL_PKG.ar_mfar_validate_check (adj.adjustment_id, 'ADJ', l_sob_id),
 	               'Y', 'MFAR_TYPE', 'NOT_MFAR_TYPE') = 'MFAR_TYPE'
	AND    arp_global.sysparam.accounting_method = 'ACCRUAL'
	UNION
	SELECT applied_customer_trx_id
	FROM   ar_receivable_applications ra
	WHERE  ra.status = 'APP'
	AND    ra.posting_control_id  = l_pst_ctrl_id
	AND    DECODE (PSA_MFAR_VAL_PKG.ar_mfar_validate_check (ra.receivable_application_id, 'RCT', l_sob_id),
			'Y', 'MFAR_TYPE', 'NOT_MFAR_TYPE') = 'MFAR_TYPE'
	UNION
	SELECT ra.applied_customer_trx_id
	FROM   ar_receivable_applications ra,
	       ar_cash_receipt_history crh,
	       ar_cash_receipt_history crho
 	WHERE crh.posting_control_id = l_pst_ctrl_id
	AND   crh.cash_receipt_history_id = crho.reversal_cash_receipt_hist_id
 	AND   crh.cash_receipt_id = ra.cash_receipt_id
 	AND   DECODE (PSA_MFAR_VAL_PKG.ar_mfar_validate_check (ra.receivable_application_id, 'RCT', l_sob_id),
		      'Y', 'MFAR_TYPE', 'NOT_MFAR_TYPE') = 'MFAR_TYPE'
 	AND ra.status = 'APP';
	-- Bug 3757993 .. End

   CURSOR Cur_MFAR_trx_lines (p_customer_trx_id NUMBER)
   IS
        SELECT
        DECODE (ctt.type, 'CM', l_cm_cat_name,
                          'DM', l_dm_cat_name,
                          'CB', l_cb_cat_name,  l_inv_cat_name)                                                  category,
        ctlgd.gl_date                                                                                            gl_date,
        ct.doc_sequence_id                                                                                       doc_seqid,
        ct.doc_sequence_value                                                                                    doc_num,
        ct.invoice_currency_code                                                                                 currency,
        DECODE (l1.lookup_code,
                '1', psa_trx_dist.mf_receivables_ccid,                       /* DEBIT  A/C FROM PSA_TRX_DIST  */
                '2', psa_mfar_utils.get_rec_ccid (null,p_customer_trx_id))        /* CREDIT A/C FROM CORE TRX_DIST */  ccid,
        DECODE (l1.lookup_code,
                '1', DECODE (SIGN (ctlgd.amount), -1, NULL,          ctlgd.amount),
                '2', DECODE (SIGN (ctlgd.amount), -1, -ctlgd.amount, NULL))                                      entered_dr,
        DECODE (l1.lookup_code,
                '1', DECODE (SIGN (ctlgd.amount), -1, -ctlgd.amount, NULL),
                '2', DECODE (SIGN (ctlgd.amount), -1, NULL,          ctlgd.amount))                              entered_cr,
        DECODE (l1.lookup_code,
                '1', DECODE (SIGN (ctlgd.amount), -1, NULL,          ctlgd.amount),
                '2', DECODE (SIGN (ctlgd.amount), -1, -ctlgd.amount, NULL))                                      accounted_dr,
        DECODE (l1.lookup_code,
                '1', DECODE (SIGN (ctlgd.amount), -1, -ctlgd.amount, NULL),
                '2', DECODE (SIGN (ctlgd.amount), -1, NULL,          ctlgd.amount))                              accounted_cr,
        l_batch_prefix || TO_CHAR(l_pst_ctrl_id)                                                                 ref1,
        DECODE (l1.lookup_code,
                '1', 'MFAR Receivable' ,
                '2', 'MFAR Reversal of Receivable' ) || ' ' || l_pre_ct_line ||
                     ' ' || 'Invoice ' || ct.trx_number || l_post_ct_line                                        ref10,
        TO_CHAR(l_pst_ctrl_id)                                                                                   ref21,
        TO_CHAR(ct.customer_trx_id)                                                                              ref22,
        TO_CHAR(ctlgd.cust_trx_line_gl_dist_id)                                                                  ref23,
        ct.trx_number                                                                                            ref24,
        hca.account_number                                                                                       ref25,
        'CUSTOMER'                                                                                               ref26,
        TO_CHAR(ct.bill_to_customer_id)                                                                          ref27,
        DECODE (ctt.type, 'CM', 'CM',
                          'DM', 'DM',
                          'CB', 'CB', 'INV')                                                                     ref28,
        DECODE (ctt.type, 'CM', 'CM_',
                          'DM', 'DM_',
                          'CB', 'CB_', 'INV_') || ctlgd.account_class                                            ref29,
--      'PSA_TRX_DIST'                                                                                           ref30
	'RA_CUST_TRX_LINE_GL_DIST'										 ref30
        FROM
              ar_lookups                        l,
              ra_customer_trx                   ct,
              ra_cust_trx_line_gl_dist          ctlgd,
              ra_cust_trx_types                 ctt,
              hz_cust_accounts                  hca,
              psa_lookup_codes                  l1,
              psa_mf_trx_dist_all               psa_trx_dist
        WHERE
              ctlgd.customer_trx_id                 =  p_customer_trx_id
        AND   ctlgd.customer_trx_id                 =  ct.customer_trx_id
        AND   l.lookup_type                         =  'AUTOGL_TYPE'
        AND   l.lookup_code                         =  nvl(ctlgd.account_class,'REV')
        AND   l1.lookup_type                        =  'PSA_CARTESIAN_JOIN'
        AND   l1.lookup_code in
        		(1, decode(ctt.type, 'INV', decode(l_post_det_acct_flag, 'N', -1, 2),
        				     'DM',  decode(l_post_det_acct_flag, 'N', -1, 2), 2))
        AND   ct.bill_to_customer_id                =  hca.cust_account_id   -- cust.customer_id
        AND   ct.cust_trx_type_id                   =  ctt.cust_trx_type_id
        AND   ctlgd.account_Class                   <> 'REC'
        AND   psa_trx_dist.cust_trx_line_gl_dist_id =  ctlgd.cust_trx_line_gl_dist_id
        AND   nvl(ctlgd.amount,0)                   <> 0
        AND   ctlgd.posting_control_id              =  l_pst_ctrl_id
        AND   nvl(psa_trx_dist.posting_control_id, -3) = -3;

        -- ========================= FND LOG ===========================
        l_full_path VARCHAR2(100) := g_path || 'Mfar_trx_to_gl';
        -- ========================= FND LOG ===========================

BEGIN

   -- ========================= FND LOG ===========================
   psa_utils.debug_other_string(g_state_level,l_full_path,
                                '                                                           ');
   psa_utils.debug_other_string(g_state_level,l_full_path,
                                '                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' );
   psa_utils.debug_other_string(g_state_level,l_full_path,
                                '                       (TRANSFERRING TRANSACTIONS) '
			        || to_char (sysdate, 'DD/MM/YYYY HH:MI:SS'));
   psa_utils.debug_other_string(g_state_level,l_full_path,
                                '                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
   psa_utils.debug_other_string(g_state_level,l_full_path,
                                '                                                           ');
   -- ========================= FND LOG ===========================

  retcode := 'S';

  l_gl_start_date        := p_gl_date_from;
  l_post_through_date    := p_gl_date_to;
  l_sob_id               := p_set_of_books_id;

  -- ========================= FND LOG ===========================
  psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS :');
  psa_utils.debug_other_string(g_state_level,l_full_path,' ============');
  psa_utils.debug_other_string(g_state_level,l_full_path,' p_gl_date_from    -->' || p_gl_date_from );
  psa_utils.debug_other_string(g_state_level,l_full_path,' p_gl_date_to      -->' || p_gl_date_to  );
  psa_utils.debug_other_string(g_state_level,l_full_path,' p_summary_flag    -->' || p_summary_flag);
  psa_utils.debug_other_string(g_state_level,l_full_path,' p_set_of_books_id -->' || p_set_of_books_id );
  psa_utils.debug_other_string(g_state_level,l_full_path,'          ');
  psa_utils.debug_other_string(g_state_level,l_full_path,' OTHER VALUES :');
  psa_utils.debug_other_string(g_state_level,l_full_path,' =============  ');
  psa_utils.debug_other_string(g_state_level,l_full_path,' GL start date     -->' || l_gl_start_date);
  psa_utils.debug_other_string(g_state_level,l_full_path,' Post through_date -->' || l_post_through_date);
  psa_utils.debug_other_string(g_state_level,l_full_path,' Set of Books ID   -->' || l_sob_id);
  psa_utils.debug_other_string(g_state_level,l_full_path,' Posting Control ID -->' || l_pst_ctrl_id);
  psa_utils.debug_other_string(g_state_level,l_full_path,'        ');
  psa_utils.debug_other_string(g_state_level,l_full_path,' PROCESS :');
  psa_utils.debug_other_string(g_state_level,l_full_path,' =========');
  psa_utils.debug_other_string(g_state_level,l_full_path,'           ');
  -- ========================= FND LOG ===========================

  FOR I IN Cur_MFAR_cust_trx_id
  LOOP

      BEGIN
          -- ========================= FND LOG ===========================
             psa_utils.debug_other_string(g_state_level,l_full_path,
                                          ' --> Creating distribution for Cust trx id ==> '
                                          || l_run_num || ' -- ' || I.customer_trx_id );
          -- ========================= FND LOG ===========================

          IF NOT (PSA_MFAR_TRANSACTIONS.create_distributions (
                                                     errbuf            => l_errbuf,
                                                     retcode           => l_retcode,
                                                     p_cust_trx_id     => I.customer_trx_id,
                                                     p_set_of_books_id => l_sob_id,
                                                     p_run_id          => l_run_num,
                                                     p_error_message   => l_error_message)) THEN

                  -- ========================= FND LOG ===========================
                     psa_utils.debug_other_string(g_excep_level,l_full_path,
                                                  ' --> PSA_MFAR_TRANSACTIONS.create_distributions --> FALSE');
                  -- ========================= FND LOG ===========================
                  IF l_error_message IS NOT NULL OR l_retcode = 'F' THEN
                     -- ========================= FND LOG ===========================
                        psa_utils.debug_other_string(g_excep_level,l_full_path,
		                                     ' --> Raising  invalid_distribution');
                     -- ========================= FND LOG ===========================
                     Raise invalid_distribution;
                  END IF;

          ELSE
                 -- ========================= FND LOG ===========================
                    psa_utils.debug_other_string(g_state_level,l_full_path,
		                                 ' --> Customer trx id --> ' || I.customer_trx_id);
                 -- ========================= FND LOG ===========================
          END IF;
      END;

      --
      -- Delete core receivables account line (INV_REC) from gl_interface
      -- when profile FV: Post Detailed Receipt Accounting = 'N'
      --

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
                                       ' --> l_post_det_acct_flag ==> ' || l_post_det_acct_flag );
      -- ========================= FND LOG ===========================

      IF l_post_det_acct_flag = 'N' THEN

	      DELETE FROM GL_INTERFACE GI
	       WHERE GI.user_je_source_name = 'Receivables'
                 AND GI.set_of_books_id     = l_sob_id
	         AND GI.group_id    	    = l_pst_ctrl_id
	         AND GI.reference29         IN ('INV_REC', 'DM_REC')
	         AND GI.reference30         = 'RA_CUST_TRX_LINE_GL_DIST'
	         AND GI.reference22         = to_char(I.customer_trx_id);

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
                                       ' --> DELETE FROM GL_INTERFACE ' || SQL%ROWCOUNT);
      -- ========================= FND LOG ===========================

      END IF;

      FOR J IN Cur_MFAR_trx_lines (I.customer_trx_id)
      LOOP

      /*
      ## For each Cutomer trax id the record will be inserted.
      */

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
                                       ' --> Customer trx id ==> ' || I.customer_trx_id );
      -- ========================= FND LOG ===========================


      INSERT INTO gl_interface
	        (created_by,
	         date_created,
	         status,
	         actual_flag,
	         group_id,
	         set_of_books_id,
	         user_je_source_name,
	         user_je_category_name,
	         accounting_date,
	         subledger_doc_sequence_id,
	         subledger_doc_sequence_value,
	         currency_code,
	         code_combination_id,
	         entered_dr,
	         entered_cr,
	         accounted_dr,
	         accounted_cr,
	         reference1,
	         reference10,
	         reference21,
	         reference22,
	         reference23,
	         reference24,
	         reference25,
	         reference26,
	         reference27,
	         reference28,
	         reference29,
	         reference30)
        VALUES  (l_user_id,
                 trunc(sysdate),
                 l_status,
                 l_actual_flag,
                 l_pst_ctrl_id,
                 l_sob_id,
                 l_source,
                 J.category,
                 J.gl_date,
	         J.doc_seqid,
	         J.doc_num,
	         J.currency,
	         J.ccid,
	         J.entered_dr,
	         J.entered_cr,
	         J.accounted_dr,
	         J.accounted_cr,
	         J.ref1,
	         J.ref10,
	         J.ref21,
	         J.ref22,
	         J.ref23,
	         J.ref24,
	         J.ref25,
	         J.ref26,
	         J.ref27,
	         J.ref28,
	         J.ref29,
	         J.ref30);

         IF (SQL%FOUND) THEN
            -- ========================= FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path,
	                                     ' --> Inserting into GL INTERFACE for ==> '
					  || I.customer_trx_id );
               psa_utils.debug_other_string(g_state_level,l_full_path,
	                                     ' CCID   => ' || J.ccid
					  || ' DEBIT  => ' || J.entered_dr
                                          || ' CREDIT => ' || J.entered_cr );
            -- ========================= FND LOG ===========================
         END IF;

       END LOOP;

  END LOOP;


   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,
                                   ' --> updating psa_mf_trx_dist_all with posting control id ');
   -- ========================= FND LOG ===========================

   UPDATE psa_mf_trx_dist_all ptda
   SET    ptda.posting_control_id = l_pst_ctrl_id
   WHERE  ptda.cust_trx_line_gl_dist_id IN
          (SELECT cust_trx_line_gl_dist_id FROM ra_cust_trx_line_gl_dist rct
           WHERE  rct.posting_control_id = l_pst_ctrl_id);

     IF (SQL%FOUND) THEN
        -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,
	                             ' --> (PSA_MF_TRX_DIST_ALL) Updated Posting control id for '
				     || SQL%ROWCOUNT);
        -- ========================= FND LOG ===========================
     END IF;

   -- Bug 3671841, making the call to delete stray records.

   DELETE FROM psa_mf_trx_dist_all
   WHERE  posting_control_id = l_pst_ctrl_id
   AND    cust_trx_line_gl_dist_id NOT IN
          ( SELECT cust_trx_line_gl_dist_id FROM ra_cust_trx_line_gl_dist rct
            WHERE  rct.posting_control_id = l_pst_ctrl_id);

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,
                                   ' --> DELETE FROM psa_mf_trx_dist_all ==> ' || SQL%ROWCOUNT);
      psa_utils.debug_other_string(g_state_level,l_full_path,
                                   ' --> END of TRANSACTIONS '
                                   || to_char (sysdate, 'DD/MM/YYYY HH:MI:SS'));
   -- ========================= FND LOG ===========================

 EXCEPTION
    WHEN INVALID_DISTRIBUTION THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                     ' --> EXCEPTION - INVALID_DISTRIBUTION raised during PSA_XFR_TO_GL_PKG.Mfar_trx_to_gl ');
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                         ' --> p_error_message  --> ' || l_error_message);
         -- ========================= FND LOG ===========================
         retcode  := 'F';

    WHEN OTHERS THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                      ' --> EXCEPTION - OTHERS raised during PSA_XFR_TO_GL_PKG.Mfar_trx_to_gl ');
            psa_utils.debug_other_string(g_excep_level,l_full_path,   sqlcode || sqlerrm);
            psa_utils.debug_unexpected_msg(l_full_path);
         -- ========================= FND LOG ===========================
         errbuf  := 2;
         retcode := 'F';

 END  Mfar_trx_to_gl;

 /* ################################## MFAR_RCTS_TO_GL ################################## */

/* Bug 3117907 - Create journal lines in gl_interface for on A/c credit memo
cur_mfar_rcpt_lines_cm : creates reversal or CM's revenue A/c
                      creates MFAR revenue account to match the invoice applied.
The following entries created:
1. Reverse On A/c credit memo's revenue Account
2. Reassign the amount to Multi-fund revenue accounts                 */

 PROCEDURE Mfar_rcpt_to_gl (errbuf               OUT NOCOPY VARCHAR2,
                            retcode              OUT NOCOPY VARCHAR2,
                            p_set_of_books_id    IN  NUMBER,
                            p_gl_date_from       IN  VARCHAR2,
                            p_gl_date_to         IN  VARCHAR2,
                            p_gl_posted_date     IN  VARCHAR2,
                            p_summary_flag       IN  VARCHAR2)
 IS

  /*
  ## This procedure will transfer Receipts to GL INTERFACE.
  */

  /* The l_ variables used IN this cursor are Global variables in this package */

  -- use c_crh_posted to identify the number of transactions that have been posted.
  -- Loop the GL_INTERFACE insertion for each record in HISTORY table
  -- This helps us create accounting lines for each status change of the receipt.

  Cursor c_crh_posted
  IS
       SELECT h1.cash_receipt_history_id, h1.status
       FROM   ar_cash_receipt_history h1,
              ar_cash_receipt_history h2
       WHERE  h1.posting_control_id = l_pst_ctrl_id
       AND    h1.cash_receipt_history_id = h2.reversal_cash_receipt_hist_id
       ORDER BY h1.cash_receipt_history_id ;

  CURSOR Cur_MFAR_rct_app_id
  IS
        SELECT distinct  ra.receivable_application_id     receivable_application_id
	FROM   ar_receivable_applications ra
        WHERE  ra.status = 'APP'
        AND    ra.posting_control_id       = l_pst_ctrl_id
        AND    DECODE (PSA_MFAR_VAL_PKG.ar_mfar_validate_check
              (ra.receivable_application_id, 'RCT', l_sob_id) , 'Y', 'MFAR_TYPE', 'NOT_MFAR_TYPE') = 'MFAR_TYPE';

   -- selects app_id if original cash receipt status had been reversed.
   CURSOR Cur_Clr_MFAR_rct_app_id
     IS
        SELECT distinct  ra.receivable_application_id     receivable_application_id
        FROM   ar_receivable_applications ra, ar_cash_receipt_history crh, ar_cash_receipt_history crho
        WHERE crh.posting_control_id = l_pst_ctrl_id
        AND   crh.cash_receipt_history_id = crho.reversal_cash_receipt_hist_id
        AND   crh.cash_receipt_id = ra.cash_receipt_id
        AND   DECODE (PSA_MFAR_VAL_PKG.ar_mfar_validate_check
                     (ra.receivable_application_id, 'RCT', p_set_of_books_id) , 'Y', 'MFAR_TYPE', 'NOT_MFAR_TYPE') = 'MFAR_TYPE'
        AND ra.status = 'APP';

   --
   -- Bug 2784180
   -- Added ussgl_transaction_code to cursor cur_mfar_rct_lines and subsequent insert to gl_interface.
   --

/*
   ###############################################################################
   Cash management Enhancements:
   ----------------------------------
   CURSOR mfar_rcpt_lines will insert thw following categories of records in gl_interface
   If Payment Method has staus = 'CLEARED'  ( No Remittance involved in Receipt processing)
   1. MFAR Receivable Account
   2. MFAR Reversal of Core Receivable Account
   3. MFAR Cash Account
   4. MFAR Reversal of Core Cash Account ( derived from Transaction Dist A/c)
   (OR)
   If Payment Method has staus = 'REMITTED'  ( Remittance in Receipt processing - Receipt cleared through Cash Mgt.)
   1. MFAR Receivable Account
   2. MFAR Reversal of Core Receivable Account
   3. MFAR Remittance Account
   4. MFAR reversal of Core Remittance Account ( derived from Transaction Dist A/c)

   In AR_CASH_RECEIPT_HISTORY_ALL, account_code_combination_id stores remittance account if status = 'REMITTED'
   account_code_combination_id stores Cash account if status = 'CLEARED'
   For MFAR Entries, the description should be appropriately changed based on Remittance requirement.
   ###############################################################################
*/

   CURSOR Cur_mfar_rct_lines (p_receivable_application_id NUMBER)
   IS
        SELECT
        DECODE(to_number(l1.lookup_code), '4',  ra.ussgl_transaction_code,
                			  '8',  ra.ussgl_transaction_code,
                			  '12', ra.ussgl_transaction_code, NULL)   		    ussgl,
        DECODE (ra.application_type, 'CASH', DECODE(ra.amount_applied_from,  NULL, l_trade_cat_name, l_ccurr_cat_name),
                                     'CM',   l_cm_cat_name )                                     category,
        ra.gl_date                                                                                  gl_date,
        DECODE (ra.application_type, 'CASH', cr.doc_sequence_id,
                                     'CM',   ctcm.doc_sequence_id)                                  doc_seqid,
        DECODE (ra.application_type, 'CASH', cr.doc_sequence_value,
                                     'CM',   ctcm.doc_sequence_value)                               doc_num,
        DECODE (ra.application_type, 'CASH', DECODE(ra.status, 'APP',
                                                    DECODE( SUBSTR(ard.source_type,1,5),
                                                            'EXCH_', DECODE (cr.currency_code, l_func_curr, ctinv.invoice_currency_code, cr.currency_code), ctinv.invoice_currency_code),  cr.currency_code),
                                                            'CM',    ctcm.invoice_currency_code)     currency,
        DECODE (to_NUMBER(l1.lookup_code),   1, psa_rct_dist.mf_cash_ccid,
                                             2, DECODE(ra.application_type, 'CM', psa_mfar_utils.get_rec_ccid (ra.applied_customer_trx_id, ra.customer_trx_id), crh.account_code_combINation_id),
                                             3, ra.code_combINation_id,
                                             4, psa_trx_dist.mf_receivables_ccid,
                                             5, psa_rct_dist.discount_ccid,
                                             6, ra.earned_discount_ccid,
                                             7, ra.code_combINation_id,
                                             8, psa_trx_dist.mf_receivables_ccid,
                                             9, psa_rct_dist.ue_discount_ccid,
                                            10, ra.unearned_discount_ccid,
                                            11, ra.code_combINation_id,
                                            12, psa_trx_dist.mf_receivables_ccid)                    ccid,
        DECODE (ra.application_type, 'CM', get_entered_dr_crm (l1.lookup_code, psa_rct_dist.amount),
                                           get_entered_dr_rct (l1.lookup_code, psa_rct_dist.amount,
                                                               psa_rct_dist.discount_amount,
                                                               psa_rct_dist.ue_discount_amount))     entered_dr,
        DECODE (ra.application_type, 'CM', get_entered_cr_crm (l1.lookup_code, psa_rct_dist.amount),
                                           get_entered_cr_rct (l1.lookup_code, psa_rct_dist.amount,
                                                               psa_rct_dist.discount_amount,
                                                               psa_rct_dist.ue_discount_amount))     entered_cr,
        DECODE (ra.application_type, 'CM', get_entered_dr_crm (l1.lookup_code, psa_rct_dist.amount),
                                           get_entered_dr_rct (l1.lookup_code, psa_rct_dist.amount,
                                                               psa_rct_dist.discount_amount,
                                                               psa_rct_dist.ue_discount_amount))     accounted_dr,
        DECODE (ra.application_type, 'CM', get_entered_cr_crm (l1.lookup_code, psa_rct_dist.amount),
                                           get_entered_cr_rct (l1.lookup_code, psa_rct_dist.amount,
                                                               psa_rct_dist.discount_amount,
                                                               psa_rct_dist.ue_discount_amount))     accounted_cr,
        DECODE(ard.source_type, 'EXCH_GAIN',  TO_CHAR(ra.code_combINation_id),
                                'EXCH_LOSS',  TO_CHAR(ra.code_combINation_id),
                                'CURR_ROUND', TO_CHAR(ra.code_combINation_id),
                                 l_batch_prefix || TO_CHAR(l_pst_ctrl_id))                           ref1,
        SUBSTRB (DECODE (l1.lookup_code, '1', DECODE (ra.application_type, 'CM', 'MFAR'|| DECODE (sign (ra.amount_applied),-1, '-UNAPP','') || ' Receivable account for credit memo' || ctcm.trx_NUMBER || '.',
                                                                                 'MFAR'|| DECODE (sign (ra.amount_applied),-1, '-UNAPP','') || DECODE(crh.status,'CLEARED', 'Cash Account for ', 'REMITTED', ' Remittance Account for ')),
                                         '2', DECODE (ra.application_type, 'CM',
						'MFAR'|| DECODE (sign (ra.amount_applied),-1, '-UNAPP','') || ' Reversal of Receivable account for credit memo '|| ctcm.trx_NUMBER || '.',
                                                'MFAR'|| DECODE (sign (ra.amount_applied),-1, '-UNAPP','') || DECODE(crh.status, 'CLEARED', ' Reversal of Cash Account for ' , 'REMITTED', ' Reversal of Remittance Account for ')),
                                         '3', 'MFAR'  || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' Reversal of AR for ',
                                         '4', 'MFAR'  || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' Receivable Account for ',
                                         '5', 'MFAR'  || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Correct earn-disc): ',
                                         '6', 'MFAR'  || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Reverse core earn-disc):' ,
                                         '7', 'MFAR'  || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Reverse core rec):' ,
                                         '8', 'MFAR'  || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Correct rec):' ,
                                         '9',  'MFAR' || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Correct unearn-disc):',
                                         '10', 'MFAR' || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Reverse core unearn-disc):',
                                         '11', 'MFAR' || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Reverse core rec):',
                                         '12', 'MFAR' || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Correct rec):' )
                                                      || DECODE (l_summary_flag, 'Y', NULL, DECODE(ra.application_type,
                                                                                                        /* Cash Receipt application */
                                                                                                         'CASH', DECODE (ard.source_type, 'REC',   l_pre_tradeapp ||' '|| cr.receipt_NUMBER ||
                                                                                                                                          DECODE (ra.status, 'ACC',   l_app_onacc,
                                                                                                                                                             'UNAPP', l_app_unapp,
                                                                                                                                                             'UNID',  l_app_unid,
                                                                                                                                                             'APP',   l_app_applied, NULL),
                                                                                                                                          'EDISC',               l_pre_erdisc           ||' '|| cr.receipt_NUMBER || l_app_applied,
                                                                                                                                          'EDISC_NON_REC_TAX',   l_pre_rec_erdisc_nrtax ||' '|| cr.receipt_NUMBER || l_app_applied,
                                                                                                                                          'UNEDISC',             l_pre_undisc           ||' '|| cr.receipt_NUMBER || l_app_applied,
                                                                                                                                          'UNEDISC_NON_REC_TAX', l_pre_rec_undisc_nrtax ||' '|| cr.receipt_NUMBER || l_app_applied,
                                                                                                                                          'EXCH_GAIN',           l_pre_rec_gain         ||' '|| cr.receipt_NUMBER || l_app_applied,
                                                                                                                                          'EXCH_LOSS',           l_pre_rec_loss         ||' '|| cr.receipt_NUMBER || l_app_applied,
                                                                                                                                          'CURR_ROUND',          l_pre_rec_curr_round   ||' '|| cr.receipt_NUMBER || l_app_applied,
                                                                                                                                          'TAX',                 l_pre_rec_tax          ||' '|| cr.receipt_NUMBER || l_app_applied,
                                                                                                                                          'DEFERRED_TAX',        l_pre_rec_deftax       ||' '|| cr.receipt_NUMBER || l_app_applied) ||
                                                                                                                                           DECODE(ctt.type,      'CB',  l_class_cb,
                                                                                                                                                                 'CM',  l_class_cm,
                                                                                                                                                                 'DEP', l_class_dep,
                                                                                                                                                                 'DM',  l_class_dm,
                                                                                                                                                                 'GUAR',l_class_guar,
                                                                                                                                                                 'INV', l_class_inv,NULL) ||
                                                                                                                                                                  ' ' || ctinv.trx_NUMBER || l_post_general)),1,240) ref10,
        TO_CHAR(l_pst_ctrl_id)                                                                  ref21,
        DECODE (ra.application_type, 'CASH',TO_CHAR(cr.cash_receipt_id) || 'C' || TO_CHAR(ra.receivable_application_id),
                                     'CM',  TO_CHAR(ra.receivable_application_id))              ref22,
--        psa_rct_dist.CUST_TRX_LINE_GL_DIST_ID                                                   ref23,
        DECODE(ra.application_type,  'CASH', ard.line_id,
                                     'CM',   psa_rct_dist.CUST_TRX_LINE_GL_DIST_ID)             ref23,
--        nvl(ard.line_id, psa_rct_dist.CUST_TRX_LINE_GL_DIST_ID)					ref23,
        DECODE (ra.application_type, 'CASH', cr.receipt_NUMBER,
                                     'CM', ctcm.trx_NUMBER)                                     ref24,
        ctinv.trx_NUMBER                                                                        ref25,
        ctt.type                                                                                ref26,
        DECODE (ra.application_type, 'CASH', TO_CHAR(cr.pay_from_customer),
                                     'CM',   TO_CHAR(ctcm.bill_to_customer_id))                 ref27,
        DECODE (ra.application_type, 'CASH', DECODE(ra.amount_applied_from, NULL,'TRADE','CCURR'),
                                     'CM',   'CM')                                          ref28,
        DECODE(ra.application_type,  'CASH', DECODE (ra.amount_applied_from, NULL,'TRADE_' ||ard.source_type, 'CCURR_' ||ard.source_type),
                                     'CM',   'CM_'||ard.source_type)                        ref29,
        DECODE(ra.application_type,  'CASH', 'PSA_RCT_DIST',
				     'CM',   'RA_CUST_TRX_LINE_GL_DIST')                       ref30
        FROM
              ar_receivable_applications      ra,
              ar_cash_receipts                cr,
              (SELECT * FROM ar_distributions
               WHERE source_table = 'RA'
               AND   source_id = p_receivable_application_id
               AND   rownum = 1)              ard,
              ra_customer_trx                 ctcm,
              ra_customer_trx                 ctinv,
              ra_cust_trx_types               ctt,
              ar_cash_receipt_history         crh,
              psa_mf_rct_dist_all             psa_rct_dist,
              psa_mf_trx_dist_all             psa_trx_dist,
              psa_lookup_codes                l1
        WHERE
              psa_rct_dist.receivable_application_id = p_receivable_application_id
        AND   psa_rct_dist.ue_discount_ccid IS NULL
        AND   psa_rct_dist.receivable_application_id = ra.receivable_application_id
        AND   psa_trx_dist.cust_trx_line_gl_dist_id  = psa_rct_dist.cust_trx_line_gl_dist_id
              /* For MFAR we consider only thr APP rows */
        AND   'APP' = DECODE(ra.application_type, 'CASH',ra.status, 'CM','APP')
        AND   ra.cash_receipt_id                    = cr.cash_receipt_id(+)
        AND   ra.customer_trx_id                    = ctcm.customer_trx_id(+)
        AND   ra.applied_customer_trx_id            = ctinv.customer_trx_id(+)
        AND   ctinv.cust_trx_type_id                = ctt.cust_trx_type_id(+)
        AND   ra.cash_receipt_id                    = crh.cash_receipt_id(+)
        AND   l1.lookup_type                        = 'PSA_CARTESIAN_JOIN'
        AND   l1.lookup_code IN ('1','4','5','7','8','9','12',
                                 decode(l_rct_post_det_flag, 'N', -1, 2),
                                 decode(l_rct_post_det_flag, 'N', -1, 3),
				 decode(l_rct_post_det_flag, 'N', -1, 6),
                                 decode(l_rct_post_det_flag, 'N', -1, 10),
                                 decode(l_rct_post_det_flag, 'N', -1, 11))
        AND   DECODE (ceil(to_NUMBER(l1.lookup_code)/4), 1, nvl(psa_rct_dist.amount,0),
                                                         2, nvl(psa_rct_dist.discount_amount,0),
                                                         3, nvl(psa_rct_dist.ue_discount_amount,0), 0) <> 0
        AND   l1.lookup_code                       <= DECODE(ra.application_type, 'CM', 2, l1.lookup_code)
        AND   ra.posting_control_id                 = l_pst_ctrl_id
        AND   nvl(psa_rct_dist.posting_control_id, -3) = -3
              /* For bug 3397563, NVL in case there is no crh record */
        AND   NVL(crh.status, 'CLEARED') IN                          ('CLEARED','REMITTED')
        AND   NVL(crh.first_posted_record_flag,'Y')        = 'Y';


-- Cursor to process journal lines related to On A/c credit memo
-- For each revenue distribution on the Invoice applied, a pair of journal lines are created
-- All the journal lines created will have category = 'Credit Memos' and they should be tied to
-- the AR batch holding all journal lines with category = 'Credit Memos'

   CURSOR Cur_mfar_rct_lines_cm (p_receivable_application_id NUMBER)
   IS
        SELECT
        DECODE(to_number(l1.lookup_code), '4',  ra.ussgl_transaction_code,
                			  '8',  ra.ussgl_transaction_code,
                			  '12', ra.ussgl_transaction_code, NULL)   		    ussgl,
        DECODE (ra.application_type, 'CASH', DECODE(ra.amount_applied_from,  NULL, l_trade_cat_name, l_ccurr_cat_name),
                                     'CM',   l_cm_cat_name )                                     category,
        ra.gl_date                                                                                  gl_date,
        ctcm.doc_sequence_id                                  doc_seqid,
        ctcm.doc_sequence_value                               doc_num,
        ctcm.invoice_currency_code     currency,
        DECODE (to_NUMBER(l1.lookup_code),   1, gld_inv.code_combination_id,
                                             2, gld.code_combination_id) ccid,
        get_entered_cr_crm (l1.lookup_code, psa_rct_dist.amount)     entered_dr,
        get_entered_dr_crm (l1.lookup_code, psa_rct_dist.amount)     entered_cr,
        get_entered_cr_crm (l1.lookup_code, psa_rct_dist.amount)     accounted_dr,
        get_entered_dr_crm (l1.lookup_code, psa_rct_dist.amount)     accounted_cr,
        DECODE(ard.source_type, 'EXCH_GAIN',  TO_CHAR(ra.code_combINation_id),
                                'EXCH_LOSS',  TO_CHAR(ra.code_combINation_id),
                                'CURR_ROUND', TO_CHAR(ra.code_combINation_id),
                                 l_batch_prefix || TO_CHAR(l_pst_ctrl_id))                           ref1,
        SUBSTRB (DECODE (l1.lookup_code, '1',  'Revenue account for Credit Memo' || ctcm.trx_NUMBER || '.',
                                         '2',  'MFAR Reversal of Revenue account for credit memo '|| ctcm.trx_NUMBER || '.'),1,240) ref10,
        TO_CHAR(l_pst_ctrl_id)                                                                  ref21,
        TO_CHAR(ra.receivable_application_id)              ref22,
--        psa_rct_dist.CUST_TRX_LINE_GL_DIST_ID                                                   ref23,
--        nvl(ard.line_id, psa_rct_dist.CUST_TRX_LINE_GL_DIST_ID)					ref23,
        DECODE(ra.application_type,  'CASH', ard.line_id,
                                     'CM',   psa_rct_dist.CUST_TRX_LINE_GL_DIST_ID)             ref23,
        ctcm.trx_NUMBER                                     ref24,
        ctinv.trx_NUMBER                                                                        ref25,
        ctt.type                                                                                ref26,
        TO_CHAR(ctcm.bill_to_customer_id)                 ref27,
        DECODE (ra.application_type, 'CASH', DECODE(ra.amount_applied_from, NULL,'TRADE','CCURR'),
                                     'CM',   'CMAPP')                                          ref28,
        DECODE(ra.application_type,  'CASH', DECODE (ra.amount_applied_from, NULL,'TRADE_' ||ard.source_type, 'CCURR_' ||ard.source_type),
                                     'CM',   'CMAPP_'||ard.source_type)                        ref29,
--        'PSA_RCT_DIST'                                                                         ref30
        DECODE(ra.application_type,  'CASH', 'PSA_RCT_DIST',
				     'CM',   'RA_CUST_TRX_LINE_GL_DIST')                       ref30
        FROM
              ar_receivable_applications      ra,
              (SELECT * FROM ar_distributions
               WHERE source_table = 'RA'
               AND   source_id = p_receivable_application_id
               AND   rownum = 1)              ard,
              ra_customer_trx                 ctcm,
              ra_cust_trx_line_gl_dist        gld,
              ra_cust_trx_line_gl_dist        gld_inv,
              ra_customer_trx                 ctinv,
              ra_cust_trx_types               ctt,
              ar_cash_receipt_history         crh,
              psa_mf_rct_dist_all             psa_rct_dist,
              psa_mf_trx_dist_all             psa_trx_dist,
              psa_lookup_codes                l1
        WHERE
              psa_rct_dist.receivable_application_id = p_receivable_application_id
        AND   psa_rct_dist.receivable_application_id = ra.receivable_application_id
        AND   psa_trx_dist.cust_trx_line_gl_dist_id  = psa_rct_dist.cust_trx_line_gl_dist_id
        AND   psa_rct_dist.cust_trx_line_gl_dist_id = gld_inv.cust_trx_line_gl_dist_id
        AND   gld_inv.ACCOUNT_class = 'REV'                /* For MFAR we consider only thr APP rows */
        AND   'APP' = DECODE(ra.application_type, 'CASH',ra.status, 'CM','APP')
        AND   ra.customer_trx_id                    = ctcm.customer_trx_id(+)
              /* Bug 3397563, check for On Account Credit Memo */
        AND   ctcm.previous_customer_trx_id IS NULL
        AND   ctcm.customer_trx_id =   gld.customer_trx_id
        AND   gld.account_class = 'REV'
        AND   ra.customer_trx_id                    = ctcm.customer_trx_id(+)
        AND   ra.applied_customer_trx_id            = ctinv.customer_trx_id(+)
        AND   ctinv.cust_trx_type_id                = ctt.cust_trx_type_id(+)
        AND   ra.cash_receipt_id                    = crh.cash_receipt_id(+)
        AND   l1.lookup_type                        = 'PSA_CARTESIAN_JOIN'
        AND   l1.lookup_code IN ('1','2')
        AND   ra.posting_control_id                 = l_pst_ctrl_id
        AND   nvl(psa_rct_dist.posting_control_id, -3) = -3
        AND   crh.status(+)                         = 'CLEARED';


 /* ###############################################################################
    This cursor will take care of MFAR Entries after a Receipt has been cleared from Cash Management.
    1. Reverse MFAR Remittance A/c
    2. Reverse 'Reversal of Core Remittance Account
    3. MFAR Cash Account
    4. Reversal Core Cash Account
    ###############################################################################
 */

   CURSOR Cur_clr_mfar_rct_lines (p_receivable_application_id NUMBER, p_crhid IN number)
   IS
        SELECT
        DECODE(ra.amount_applied_from,  NULL, l_trade_cat_name, l_ccurr_cat_name)    category,
        crhnew.gl_date                                                                 gl_date,
        cr.doc_sequence_id                                  doc_seqid,
        cr.doc_sequence_value                               doc_num,
        crhnew.status newstatus,
        crhold.status oldstatus,
        DECODE(ra.status, 'APP',  DECODE( SUBSTR(ard.source_type,1,5),
                 'EXCH_', DECODE (cr.currency_code, l_func_curr, ctinv.invoice_currency_code, cr.currency_code),
                       ctinv.invoice_currency_code),  cr.currency_code)   currency,
        DECODE (to_NUMBER(l1.lookup_code),   1, psa_rct_dist.ue_discount_ccid,       -- mfar remittance (CR)-- check remittance/cash
                                             2, decode(crhnew.status,'REMITTED',crhnew.account_code_combination_id,crhold.account_code_combination_id),                                       -- Core Remittance (DB)
                                             3, decode(crhnew.status,'REMITTED',crhold.account_code_combination_id,crhnew.account_code_combination_id),                                       -- Core Cash (CR)
                                             4, decode(psa_rct_dist.attribute1,'CLEARED',psa_rct_dist.mf_cash_ccid))         -- MFAR Cash (DB)
                                                                                      ccid,
             get_entered_dr_rct_clear(l1.lookup_code, psa_rct_dist.amount,crhnew.status,crhold.status)  entered_dr,
             get_entered_cr_rct_clear(l1.lookup_code, psa_rct_dist.amount,crhnew.status,crhold.status)     entered_cr,
             get_entered_dr_rct_clear(to_number(l1.lookup_code), psa_rct_dist.amount,crhnew.status,crhold.status)     accounted_dr,
             get_entered_cr_rct_clear(l1.lookup_code, psa_rct_dist.amount,crhnew.status,crhold.status)     accounted_cr,
        DECODE(ard.source_type, 'EXCH_GAIN',  TO_CHAR(ra.code_combINation_id),
                                'EXCH_LOSS',  TO_CHAR(ra.code_combINation_id),
                                'CURR_ROUND', TO_CHAR(ra.code_combINation_id),
                                 l_batch_prefix || TO_CHAR(l_pst_ctrl_id))                           ref1,
        SUBSTRB (DECODE (l1.lookup_code, '1', 'CSH MFAR'|| DECODE (sign (ra.amount_applied),-1, '-UNAPP','') || 'Remittance Reversal for ',
                                         '2', 'CSH MFAR'|| DECODE (sign (ra.amount_applied),-1, '-UNAPP','') ||  'Reversal of Core Remittance for ',
                                         '3', 'CSH MFAR'  || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' Reversal of Core Cash A/c ',
                                         '4', 'CSH MFAR'  || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' Cash Account for ',
                                         '5', 'MFAR'  || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Correct earn-disc): ',
                                         '6', 'MFAR'  || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Reverse core earn-disc):' ,
                                         '7', 'MFAR'  || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Reverse core rec):' ,
                                         '8', 'MFAR'  || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Correct rec):' ,
                                         '9',  'MFAR' || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Correct unearn-disc):',
                                         '10', 'MFAR' || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Reverse core unearn-disc):',
                                         '11', 'MFAR' || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Reverse core rec):',
                                         '12', 'MFAR' || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Correct rec):' )
                                                      || DECODE (l_summary_flag, 'Y', NULL, DECODE(ra.application_type,
                                                                                                        /* Cash Receipt application */
                                                                                                         'CASH', DECODE (ard.source_type, 'REC',   l_pre_tradeapp ||' '|| cr.receipt_NUMBER ||
                                                                                                                                          DECODE (ra.status, 'ACC',   l_app_onacc,
                                                                                                                                                             'UNAPP', l_app_unapp,
                                                                                                                                                             'UNID',  l_app_unid,
                                                                                                                                                             'APP',   l_app_applied, NULL),
                                                                                                                                          'EDISC',               l_pre_erdisc           ||' '|| cr.receipt_NUMBER || l_app_applied,
                                                                                                                                          'EDISC_NON_REC_TAX',   l_pre_rec_erdisc_nrtax ||' '|| cr.receipt_NUMBER || l_app_applied,
                                                                                                                                          'UNEDISC',             l_pre_undisc           ||' '|| cr.receipt_NUMBER || l_app_applied,
                                                                                                                                          'UNEDISC_NON_REC_TAX', l_pre_rec_undisc_nrtax ||' '|| cr.receipt_NUMBER || l_app_applied,
                                                                                                                                          'EXCH_GAIN',           l_pre_rec_gain         ||' '|| cr.receipt_NUMBER || l_app_applied,
                                                                                                                                          'EXCH_LOSS',           l_pre_rec_loss         ||' '|| cr.receipt_NUMBER || l_app_applied,
                                                                                                                                          'CURR_ROUND',          l_pre_rec_curr_round   ||' '|| cr.receipt_NUMBER || l_app_applied,
                                                                                                                                          'TAX',                 l_pre_rec_tax          ||' '|| cr.receipt_NUMBER || l_app_applied,
                                                                                                                                          'DEFERRED_TAX',        l_pre_rec_deftax       ||' '|| cr.receipt_NUMBER || l_app_applied) ||
                                                                                                                                           DECODE(ctt.type,      'CB',  l_class_cb,
                                                                                                                                                                 'CM',  l_class_cm,
                                                                                                                                                                 'DEP', l_class_dep,
                                                                                                                                                                 'DM',  l_class_dm,
                                                                                                                                                                 'GUAR',l_class_guar,
                                                                                                                                                                 'INV', l_class_inv,NULL) ||
                                                                                                                                                                  ' ' || ctinv.trx_NUMBER || l_post_general)),1,240)
                                                                                       ref10,
        TO_CHAR(l_pst_ctrl_id)                                                                  ref21,
        TO_CHAR(cr.cash_receipt_id) || 'C' || TO_CHAR(ra.receivable_application_id)             ref22,
--        psa_rct_dist.CUST_TRX_LINE_GL_DIST_ID                                                   ref23,
        nvl(ard.line_id, psa_rct_dist.CUST_TRX_LINE_GL_DIST_ID)					ref23,
         cr.receipt_NUMBER                                                                      ref24,
        ctinv.trx_NUMBER                                                                        ref25,
        ctt.type                                                                                ref26,
        to_char(cr.pay_from_customer)                                                          ref27,
        DECODE(ra.amount_applied_from, NULL,'TRADE','CCURR')                                    ref28,
        DECODE (ra.amount_applied_from, NULL,'TRADE_' ||ard.source_type, 'CCURR_' ||ard.source_type)
                                                                                                ref29,
        'PSA_RCT_DIST'                                                                          ref30
        FROM
              ar_receivable_applications      ra,
              ar_cash_receipts                cr,
              (SELECT * FROM ar_distributions
               WHERE source_table = 'RA'
               AND   source_id = p_receivable_application_id
               AND   rownum = 1)              ard,
              ra_customer_trx                 ctinv,
              ra_cust_trx_types               ctt,
              ar_cash_receipt_history         crhnew,
              ar_cash_receipt_history         crhold,
              psa_mf_rct_dist_all             psa_rct_dist,
              psa_mf_trx_dist_all             psa_trx_dist,
              psa_lookup_codes                l1
        WHERE
              psa_rct_dist.receivable_application_id = p_receivable_application_id
              AND psa_rct_dist.ue_discount_ccid IS NOT NULL
        AND   psa_rct_dist.attribute1 = 'CLEARED'
        AND   psa_rct_dist.receivable_application_id = ra.receivable_application_id
        AND   psa_trx_dist.cust_trx_line_gl_dist_id  = psa_rct_dist.cust_trx_line_gl_dist_id
              /* For MFAR we consider only thr APP rows */
        AND   'APP' = DECODE(ra.application_type, 'CASH',ra.status, 'CM','APP')
        AND   ra.cash_receipt_id                    = cr.cash_receipt_id(+)
        AND   ra.applied_customer_trx_id            = ctinv.customer_trx_id(+)
        AND   ctinv.cust_trx_type_id                = ctt.cust_trx_type_id(+)
        AND   ra.cash_receipt_id                    = crhnew.cash_receipt_id     --outer joinremoved
        AND   l1.lookup_type                        = 'PSA_CARTESIAN_JOIN'
        AND   l1.lookup_code IN ('1','2','3','4') --,'5','6','7','8','9','10','11','12')
        AND   crhnew.posting_control_id                 = l_pst_ctrl_id
        AND   crhnew.cash_receipt_history_id  =  p_crhid
        AND   crhold.reversal_cash_receipt_hist_id   = crhnew.cash_receipt_history_id
        AND   nvl(crhnew.first_posted_record_flag, 'N')          = 'N';


	CURSOR c_fv_balance_check (c_sob_id NUMBER, c_group_id NUMBER, c_rcv_app_id NUMBER) IS
		SELECT to_number(substr(gl.reference22, 1, instr(gl.reference22, 'C')-1)) cash_receipt_id,
		       sum(accounted_dr) sum_acctd_dr,
		       sum(accounted_cr) sum_acctd_cr
		  FROM gl_interface gl
                 WHERE gl.user_je_source_name = 'Receivables'
                   AND gl.set_of_books_id     = c_sob_id
                   AND gl.group_id            = c_group_id
		   AND substr(gl.reference29, 7) IN ('CASH', 'REC')
		   AND gl.reference10 NOT LIKE 'MFAR%'
		   AND to_number(substr(gl.reference22, 1, instr(gl.reference22, 'C')-1)) IN
		        (select cash_receipt_id from ar_receivable_applications where receivable_application_id = c_rcv_app_id)
		 GROUP BY to_number(substr(gl.reference22, 1, instr(gl.reference22, 'C')-1))
		HAVING sum(accounted_dr) =  sum(accounted_cr);

	l_fv_balance_check  c_fv_balance_check%rowtype;

        -- ========================= FND LOG ===========================
           l_full_path VARCHAR2(100) := g_path || 'mfar_rcpt_to_gl';
        -- ========================= FND LOG ===========================

BEGIN

 retcode := 'S';

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,
                                  '                                                           ' );
     psa_utils.debug_other_string(g_state_level,l_full_path,
                                  '                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' );
     psa_utils.debug_other_string(g_state_level,l_full_path,
                                  '                          (TRANSFERRING RECEIPTS) '
				|| to_char (sysdate, 'DD/MM/YYYY HH:MI:SS'));
     psa_utils.debug_other_string(g_state_level,l_full_path,
                                  '                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' );
     psa_utils.debug_other_string(g_state_level,l_full_path,
                                  '                                                           ' );
  -- ========================= FND LOG ===========================

  l_gl_start_date        := p_gl_date_from;
  l_post_through_date    := p_gl_date_to;
  l_summary_flag         := p_summary_flag;
  l_sob_id               := p_set_of_books_id;

  -- ========================= FND LOG ===========================
  psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS :');
  psa_utils.debug_other_string(g_state_level,l_full_path,' ============');
  psa_utils.debug_other_string(g_state_level,l_full_path,' p_gl_date_from    -->' || p_gl_date_from );
  psa_utils.debug_other_string(g_state_level,l_full_path,' p_gl_date_to      -->' || p_gl_date_to  );
  psa_utils.debug_other_string(g_state_level,l_full_path,' p_summary_flag    -->' || p_summary_flag );
  psa_utils.debug_other_string(g_state_level,l_full_path,' p_set_of_books_id -->' || p_set_of_books_id);
  psa_utils.debug_other_string(g_state_level,l_full_path,'             ');
  psa_utils.debug_other_string(g_state_level,l_full_path,' OTHER VALUES :');
  psa_utils.debug_other_string(g_state_level,l_full_path,' =============  ');
  psa_utils.debug_other_string(g_state_level,l_full_path,' l_gl_start_date     -->' || l_gl_start_date);
  psa_utils.debug_other_string(g_state_level,l_full_path,' l_post_through_date -->' || l_post_through_date);
  psa_utils.debug_other_string(g_state_level,l_full_path,' l_summary_flag      -->' || l_summary_flag);
  psa_utils.debug_other_string(g_state_level,l_full_path,' l_sob_id            -->' || l_sob_id);
  psa_utils.debug_other_string(g_state_level,l_full_path,' l_pst_ctrl_id       -->' || l_pst_ctrl_id );
  psa_utils.debug_other_string(g_state_level,l_full_path,'          ');
  psa_utils.debug_other_string(g_state_level,l_full_path,' PROCESS :');
  psa_utils.debug_other_string(g_state_level,l_full_path,' =========');
  psa_utils.debug_other_string(g_state_level,l_full_path,'           ');
  -- ========================= FND LOG ===========================

 -- Begin processing of Cleared Receipts - Cash Management

 FOR K IN   c_crh_posted
  LOOP

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,
                                ' in to cursor c_crh_posted ');
   -- ========================= FND LOG ===========================

   FOR I IN Cur_Clr_MFAR_rct_app_id
    LOOP
       /*
       ## Creating distributions for Receipts.
       Bug 2780195 - Before calling the API, sequence psa_mf_error_log_s is initialized
       */

       -- select psa_mf_error_log_s.nextval into l_run_num from dual;
       -- This is now set in the initialization routine

      BEGIN
          -- ========================= FND LOG ===========================
             psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' --> inside Cur_Clr_MFAR_rct_app_id ');
             psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' --> Creating distribution for receivable_application_id ==> '
				        || l_run_num || ' -- ' || I.receivable_application_id );
          -- ========================= FND LOG ===========================

          IF NOT (PSA_MFAR_RECEIPTS.create_distributions (
                                                     errbuf              => l_errbuf,
                                                     retcode             => l_retcode,
                                                     p_receivable_app_id => I.receivable_application_id,
                                                     p_set_of_books_id   => l_sob_id,
                                                     p_run_id            => l_run_num,
                                                     p_error_message     => l_error_message)) THEN

                  -- ========================= FND LOG ===========================
                     psa_utils.debug_other_string(g_state_level,l_full_path,
	                                            ' --> PSA_MFAR_RECEIPTS.create_distributions  ==> FALSE ');
                  -- ========================= FND LOG ===========================

                  IF l_error_message IS NOT NULL OR l_retcode = 'F' THEN
                     -- ========================= FND LOG ===========================
                     psa_utils.debug_other_string(g_excep_level,l_full_path,
		                                   ' --> Raising  invalid_distribution');
                     -- ========================= FND LOG ===========================
                     Raise invalid_distribution;
                  END IF;

          ELSE
                 -- ========================= FND LOG ===========================
                    psa_utils.debug_other_string(g_state_level,l_full_path,
		                                '     Receivable Application id --> '
					        || I.receivable_application_id);
                 -- ========================= FND LOG ===========================
          END IF;
      END;

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
	                              ' --> Before cursor cur_clr_mfar_rct_lines ');
         psa_utils.debug_other_string(g_state_level,l_full_path,
                                      ' --> Receivable Application id ==> ' || I.receivable_application_id );
         psa_utils.debug_other_string(g_state_level,l_full_path,
                                      ' --> cash_receipt_history_id ==> ' || K.cash_receipt_history_id);
      -- ========================= FND LOG ===========================

      FOR J IN cur_clr_mfar_rct_lines (I.receivable_application_id, K.cash_receipt_history_id)
      LOOP

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
                                      ' --> inside cur_clr_mfar_rct_lines ');
           psa_utils.debug_other_string(g_state_level,l_full_path,
                                      ' --> J.newstatus ' || J.newstatus || ' and ' ||
                                      ' --> J.oldstatus ' || J.oldstatus );
        -- ========================= FND LOG ===========================

        IF (J.newstatus = 'REVERSED') AND (J.oldstatus = 'REMITTED') THEN
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,' --> Exiting ');
           -- ========================= FND LOG ===========================
           EXIT;
        END IF;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
                                        ' --> Inserting into gl interface ');
        -- ========================= FND LOG ===========================

     INSERT INTO gl_interface
	        (created_by,
	         date_created,
	         status,
	         actual_flag,
	         group_id,
	         set_of_books_id,
	         user_je_source_name,
	         user_je_category_name,
	         accounting_date,
	         subledger_doc_sequence_id,
	         subledger_doc_sequence_value,
	         currency_code,
	         code_combINation_id,
	         entered_dr,
	         entered_cr,
	         accounted_dr,
	         accounted_cr,
	         reference1,
	         reference10,
	         reference21,
	         reference22,
	         reference23,
	         reference24,
	         reference25,
	         reference26,
	         reference27,
	         reference28,
	         reference29,
	         reference30,
	         ussgl_transaction_code)
        VALUES  (l_user_id,
                 trunc(sysdate),
                 l_status,
                 l_actual_flag,
                 l_pst_ctrl_id,
                 l_sob_id,
                 l_source,
                 J.category,
                 J.gl_date,
	         J.doc_seqid,
	         J.doc_num,
	         J.currency,
	         J.ccid,
	         J.entered_dr,
	         J.entered_cr,
	         J.accounted_dr,
	         J.accounted_cr,
	         J.ref1,
	         J.ref10,
	         J.ref21,
	         J.ref22,
	         J.ref23,
	         J.ref24,
	         J.ref25,
	         J.ref26,
	         J.ref27,
	         J.ref28,
	         J.ref29,
	         J.ref30,
	         NULL);

         IF (SQL%FOUND) THEN
            -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' --> Inserting into GL INTERFACE for Receipts (Cash Cleared) '||
                                         ' - Receivable Application id ==> ' || I.receivable_application_id);
            psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' CCID   => ' || J.ccid
	                              || ' DEBIT  => ' || J.entered_dr
                                      || ' CREDIT => ' || J.entered_cr );
            -- ========================= FND LOG ===========================
         END IF;

       END LOOP;

  END LOOP;
 END LOOP;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,
	                          ' --> Calling PSA_MFAR_RECEIPTS.PURGE_ORPHAN_DISTRIBUTIONS ');
  -- ========================= FND LOG ===========================

  -- Bug 3671841, issuing a call to purge orphan distributions
  PSA_MFAR_RECEIPTS.PURGE_ORPHAN_DISTRIBUTIONS;

  UPDATE psa_mf_rct_dist_all pda
  SET    pda.posting_control_id = l_pst_ctrl_id
  WHERE  pda.attribute1 = 'CLEARED'
  AND  pda.receivable_application_id IN
         (SELECT receivable_application_id FROM ar_receivable_applications ara, ar_cash_receipt_history crh
         WHERE  ara.cash_receipt_id = crh.cash_receipt_id AND crh.status = 'CLEARED'
         AND crh.posting_control_id = l_pst_ctrl_id) ;

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,
                                ' UPDATE psa_mf_rct_dist_all '|| SQL%ROWCOUNT);
   -- ========================= FND LOG ===========================

  FOR I IN Cur_MFAR_rct_app_id
  LOOP

      /*
      ## Creating distributions for Receipts.
      Bug 2780195 - Before calling the API, sequence psa_mf_error_log_s is initialized
      */

      -- select psa_mf_error_log_s.nextval into l_run_num from dual;
      -- This is now set in the initialization routine.

      BEGIN
          -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,
                                           ' --> inside cursor Cur_MFAR_rct_app_id ');
              psa_utils.debug_other_string(g_state_level,l_full_path,
	                                   ' --> Creating distribution for receivable_application_id ==> '
					   || l_run_num || ' -- ' || I.receivable_application_id );
          -- ========================= FND LOG ===========================

          IF NOT (PSA_MFAR_RECEIPTS.create_distributions (
                                                     errbuf              => l_errbuf,
                                                     retcode             => l_retcode,
                                                     p_receivable_app_id => I.receivable_application_id,
                                                     p_set_of_books_id   => l_sob_id,
                                                     p_run_id            => l_run_num,
                                                     p_error_message     => l_error_message)) THEN

                  -- ========================= FND LOG ===========================
                     psa_utils.debug_other_string(g_state_level,l_full_path,
	                                            ' --> PSA_MFAR_RECEIPTS.create_distributions  ==> FALSE ');
                  -- ========================= FND LOG ===========================

                  IF l_error_message IS NOT NULL OR l_retcode = 'F' THEN
                     -- ========================= FND LOG ===========================
                     psa_utils.debug_other_string(g_excep_level,l_full_path,
		                                  ' --> Raising  invalid_distribution');
                     -- ========================= FND LOG ===========================
                     Raise invalid_distribution;
                  END IF;
          ELSE
                  -- ========================= FND LOG ===========================
                     psa_utils.debug_other_string(g_state_level,l_full_path,
	                                          ' --> Receivable Application id --> '
						  || I.receivable_application_id);
                    -- ========================= FND LOG ===========================
          END IF;
       END;

       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,
				       ' --> l_post_det_acct_flag  ==> ' || l_post_det_acct_flag );
       -- ========================= FND LOG ===========================
/* -- Bug 4178626
      IF l_post_det_acct_flag = 'N' THEN

	OPEN  c_fv_balance_check (l_sob_id, l_pst_ctrl_id, I.receivable_application_id);
        FETCH c_fv_balance_check INTO l_fv_balance_check;
        CLOSE c_fv_balance_check;

        IF (l_fv_balance_check.sum_acctd_dr IS NOT NULL AND
	    l_fv_balance_check.sum_acctd_cr IS NOT NULL   ) THEN

                -- ========================= FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path,
                                                ' --> inside if ' );
                -- ========================= FND LOG ===========================

		l_rct_post_det_flag := 'N';

		DELETE FROM gl_interface gl
                 WHERE gl.user_je_source_name = 'Receivables'
                   AND gl.set_of_books_id     = l_sob_id
                   AND gl.group_id            = l_pst_ctrl_id
		   AND substr(gl.reference29, 7) IN ('CASH', 'REC')
		   AND gl.reference10 NOT LIKE 'MFAR%'
		   AND to_number(substr(gl.reference22, 1, instr(gl.reference22, 'C')-1)) = l_fv_balance_check.cash_receipt_id;

                -- ========================= FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path,
                                                ' --> DELETE FROM gl_interface -> ' || SQL%ROWCOUNT);
                -- ========================= FND LOG ===========================
        ELSE
		l_rct_post_det_flag := 'Y';
	END IF;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
                                        ' --> l_rct_post_det_flag -> ' || l_rct_post_det_flag);
        -- ========================= FND LOG ===========================
      END IF;
-- Bug 4178626 */

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
                                      ' --> Before cursor Cur_mfar_rct_lines ');
      -- ========================= FND LOG ===========================

      FOR J IN Cur_mfar_rct_lines (I.receivable_application_id)
      LOOP

      /*
      ## For each receivable app id the record will be INserted.
      */

      -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,
                                   ' --> inside cursor Cur_mfar_rct_lines ');
      psa_utils.debug_other_string(g_state_level,l_full_path,
                                   ' --> Receivable Application id ==> ' || I.receivable_application_id);
      psa_utils.debug_other_string(g_state_level,l_full_path,
                                   ' --> inserting into gl_interface ');
      -- ========================= FND LOG ===========================

      INSERT INTO gl_interface
	        (created_by,
	         date_created,
	         status,
	         actual_flag,
	         group_id,
	         set_of_books_id,
	         user_je_source_name,
	         user_je_category_name,
	         accounting_date,
	         subledger_doc_sequence_id,
	         subledger_doc_sequence_value,
	         currency_code,
	         code_combINation_id,
	         entered_dr,
	         entered_cr,
	         accounted_dr,
	         accounted_cr,
	         reference1,
	         reference10,
	         reference21,
	         reference22,
	         reference23,
	         reference24,
	         reference25,
	         reference26,
	         reference27,
	         reference28,
	         reference29,
	         reference30,
	         ussgl_transaction_code)
        VALUES  (l_user_id,
                 trunc(sysdate),
                 l_status,
                 l_actual_flag,
                 l_pst_ctrl_id,
                 l_sob_id,
                 l_source,
                 J.category,
                 J.gl_date,
	         J.doc_seqid,
	         J.doc_num,
	         J.currency,
	         J.ccid,
	         J.entered_dr,
	         J.entered_cr,
	         J.accounted_dr,
	         J.accounted_cr,
	         J.ref1,
	         J.ref10,
	         J.ref21,
	         J.ref22,
	         J.ref23,
	         J.ref24,
	         J.ref25,
	         J.ref26,
	         J.ref27,
	         J.ref28,
	         J.ref29,
	         J.ref30,
	         J.ussgl);

         IF (SQL%FOUND) THEN
            -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' --> Inserting into GL INTERFACE for Receipts ' ||
                                         ' - Receivable Application id ==> ' || I.receivable_application_id );
            psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' CCID   => ' || J.ccid
			              || ' DEBIT  => ' || J.entered_dr
                                      || ' CREDIT => ' || J.entered_cr );
            -- ========================= FND LOG ===========================
         END IF;

       END LOOP;

      -- Insert accounting lines into gl_interface for on account credit memo
      -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,
                                   ' --> Before cursor Cur_mfar_rct_lines_cm  ');
      -- ========================= FND LOG ===========================


      FOR J IN Cur_mfar_rct_lines_cm (I.receivable_application_id)
      LOOP

      /*
      ## For each receivable app id the record will be INserted.
      */

      -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,
                                   ' --> Inside cursor Cur_mfar_rct_lines_cm  ');
      psa_utils.debug_other_string(g_state_level,l_full_path,
                                   ' --> Receivable Application id ==> ' || I.receivable_application_id );
      -- ========================= FND LOG ===========================

      INSERT INTO gl_interface
	        (created_by,
	         date_created,
	         status,
	         actual_flag,
	         group_id,
	         set_of_books_id,
	         user_je_source_name,
	         user_je_category_name,
	         accounting_date,
	         subledger_doc_sequence_id,
	         subledger_doc_sequence_value,
	         currency_code,
	         code_combINation_id,
	         entered_dr,
	         entered_cr,
	         accounted_dr,
	         accounted_cr,
	         reference1,
	         reference10,
	         reference21,
	         reference22,
	         reference23,
	         reference24,
	         reference25,
	         reference26,
	         reference27,
	         reference28,
	         reference29,
	         reference30,
	         ussgl_transaction_code)
        VALUES  (l_user_id,
                 trunc(sysdate),
                 l_status,
                 l_actual_flag,
                 l_pst_ctrl_id,
                 l_sob_id,
                 l_source,
                 J.category,
                 J.gl_date,
	         J.doc_seqid,
	         J.doc_num,
	         J.currency,
	         J.ccid,
	         J.entered_dr,
	         J.entered_cr,
	         J.accounted_dr,
	         J.accounted_cr,
	         J.ref1,
	         J.ref10,
	         J.ref21,
	         J.ref22,
	         J.ref23,
	         J.ref24,
	         J.ref25,
	         J.ref26,
	         J.ref27,
	         J.ref28,
	         J.ref29,
	         J.ref30,
	         J.ussgl);

         IF (SQL%FOUND) THEN
            -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' --> Inserting into GL INTERFACE for Receipts ' ||
                                         ' - Receivable Application id ==> ' || I.receivable_application_id );
            psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' CCID   => ' || J.ccid
				      || ' DEBIT  => ' || J.entered_dr
                                      || ' CREDIT => ' || J.entered_cr );
            -- ========================= FND LOG ===========================
         END IF;

       END LOOP;

  END LOOP;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,
	                          ' --> Calling PSA_MFAR_RECEIPTS.PURGE_ORPHAN_DISTRIBUTIONS ');
  -- ========================= FND LOG ===========================

  -- Bug 3671841, issuing a call to purge orphan distributions
  PSA_MFAR_RECEIPTS.PURGE_ORPHAN_DISTRIBUTIONS;

  UPDATE psa_mf_rct_dist_all pda
  SET    pda.posting_control_id = l_pst_ctrl_id
  WHERE  pda.receivable_application_id IN
        (SELECT receivable_application_id FROM ar_receivable_applications ara
         WHERE  ara.posting_control_id = l_pst_ctrl_id);

  IF (SQL%FOUND) THEN
      -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,
                                   ' --> (PSA_MF_RCT_DIST_ALL) Posting control id updated for '
		                   || (SQL%ROWCOUNT) );
      -- ========================= FND LOG ===========================
  END IF;
  -- ========================= FND LOG ===========================
  psa_utils.debug_other_string(g_event_level,l_full_path,
                                 ' --> End of Receipts Transfer '|| to_char(sysdate, 'DD/MM/YYYY HH:MI:SS'));
  -- ========================= FND LOG ===========================

 EXCEPTION
    WHEN INVALID_DISTRIBUTION THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                     ' --> EXCEPTION - INVALID_DISTRIBUTION raised during PSA_XFR_TO_GL_PKG.Mfar_rct_to_gl ');
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                         ' --> p_error_message  --> ' || l_error_message);
         -- ========================= FND LOG ===========================
         retcode  := 'F';

    WHEN OTHERS THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                      ' --> EXCEPTION - OTHERS raised during PSA_XFR_TO_GL_PKG.Mfar_rct_to_gl ');
            psa_utils.debug_other_string(g_excep_level,l_full_path,   sqlcode || sqlerrm);
            psa_utils.debug_unexpected_msg(l_full_path);
         -- ========================= FND LOG ===========================
         errbuf  := 2;
         retcode := 'F';

 END  Mfar_rcpt_to_gl;

 /* ################################## MFAR_ADJ_TO_GL ################################## */

PROCEDURE Mfar_adj_to_gl  (errbuf               OUT NOCOPY VARCHAR2,
                           retcode              OUT NOCOPY VARCHAR2,
                           p_set_of_books_id    IN  NUMBER,
                           p_gl_date_from       IN  VARCHAR2,
                           p_gl_date_to         IN  VARCHAR2,
                           p_gl_posted_date     IN  VARCHAR2,
                           p_summary_flag       IN  VARCHAR2)
IS

  /*
  ## This will transfer adjustments to gl_interface.
  */

  /* The l_ variables used in this cursor are Global variables in this package */
  CURSOR Cur_lines_to_be_processed
  IS
        SELECT distinct adj.adjustment_id   adjustment_id
        FROM   ar_adjustments adj
        WHERE  adj.posting_control_id  = l_pst_ctrl_id
        AND    DECODE (PSA_MFAR_VAL_PKG.ar_mfar_validate_check (adj.adjustment_id, 'ADJ', l_sob_id)
               , 'Y', 'MFAR_TYPE', 'NOT_MFAR_TYPE') = 'MFAR_TYPE';

    -- Bug 2982757
    -- Modified cursor to fetch adjustment ccid from ar_distributions
    -- New function created get_adj_ccid

    -- Bug 3168282 (Tpradhan)
    -- Selected the value ussgl_transaction_code in the Cursor below. Also inserted the same value into gl_interface table.

   CURSOR Cur_mfar_lines (p_adjustment_id NUMBER)
   IS
          SELECT
	          adj.gl_date                                                                      gl_date,
	          adj.doc_sequence_id                                                              doc_seqid,
	          adj.doc_sequence_value                                                           doc_num,
	          ct.invoice_currency_code                                                         currency,
	          DECODE(l.lookup_code,	'1', psa_adj_dist.mf_adjustment_ccid,
	          	                '2', get_adj_ccid (p_adjustment_id),
	          	                '3', PSA_MFAR_UTILS.get_rec_ccid (null, adj.customer_trx_id),
	          	                '4', psa_trx_dist.mf_receivables_ccid)			   ccid,
	          get_entered_dr_adj (l.lookup_code, psa_adj_dist.amount)                          entered_dr,
	          get_entered_cr_adj (l.lookup_code, psa_adj_dist.amount)                          entered_cr,
	          get_entered_dr_adj (l.lookup_code, psa_adj_dist.amount)                          accounted_dr,
	          get_entered_cr_adj (l.lookup_code, psa_adj_dist.amount)                          accounted_cr,
	          adj.ussgl_transaction_code,
	          l_batch_prefix || TO_CHAR(l_pst_ctrl_id)		                           ref1,
                  DECODE (l.lookup_code, '1', 'MFAR ',
                                         '2', 'MFAR Reversal of ' ,
                                         '3', 'MFAR Reversal of ' ,
                                         '4', 'MFAR ' ) ||
                                         DECODE( l_summary_flag,'Y',NULL,
                                                 DECODE( l.lookup_code,
                                                             '4', DECODE(sign(psa_adj_dist.amount), -1,
                                                                         l_pre_adjcr_ar || DECODE(ctt.type, 'CB',   l_class_cb,
                                                                                                            'CM',   l_class_cm,
                                                                                                            'DEP',  l_class_dep,
                                                                                                            'DM',   l_class_dm,
                                                                                                            'GUAR', l_class_guar,
                                                                                                            'INV',  l_class_inv,NULL) || ' ' || ct.trx_number || l_post_general,
                                                                         l_pre_adjdr_ar || DECODE(ctt.type, 'CB',   l_class_cb,                                                                                                       'CM',   l_class_cm,
                                                                                                            'DEP',  l_class_dep,
                                                                                                            'DM',   l_class_dm,
                                                                                                            'GUAR', l_class_guar,
                                                                                                            'INV',  l_class_inv,NULL) || ' ' || ct.trx_number || l_post_general),
                                                             '3', DECODE(sign(psa_adj_dist.amount), -1,
                                                                         l_pre_adjcr_ar || DECODE(ctt.type, 'CB',   l_class_cb,
                                                                                                            'CM',   l_class_cm,
                                                                                                            'DEP',  l_class_dep,
                                                                                                            'DM',   l_class_dm,
                                                                                                            'GUAR', l_class_guar,
                                                                                                            'INV',  l_class_inv,NULL) || ' ' || ct.trx_number || l_post_general,
                                                                         l_pre_adjdr_ar || DECODE(ctt.type, 'CB',   l_class_cb,
                                                                                                            'CM',   l_class_cm,
                                                                                                            'DEP',  l_class_dep,
                                                                                                            'DM',   l_class_dm,
                                                                                                            'GUAR', l_class_guar,
                                                                                                            'INV',  l_class_inv,NULL) || ' ' || ct.trx_number || l_post_general),
                                                             '2', DECODE(sign(psa_adj_dist.amount),  -1,
                                                                        l_pre_adjdr_adj || DECODE(ctt.type, 'CB',   l_class_cb,
                                                                                                            'CM',   l_class_cm,
                                                                                                            'DEP',  l_class_dep,
                                                                                                            'DM',   l_class_dm,
                                                                                                            'GUAR', l_class_guar,
                                                                                                            'INV',  l_class_inv,NULL) || ' ' || ct.trx_number || l_post_general,
                                                                        l_pre_adjcr_adj || DECODE(ctt.type, 'CB',   l_class_cb,
                                                                                                            'CM',   l_class_cm,
                                                                                                            'DEP',  l_class_dep,
                                                                                                            'DM',   l_class_dm,
                                                                                                            'GUAR', l_class_guar,
                                                                                                            'INV',  l_class_inv,NULL) || ' ' || ct.trx_number || l_post_general),
                                                             '1', DECODE(sign(psa_adj_dist.amount), -1,
                                                                       l_pre_adjdr_adj ||  DECODE(ctt.type, 'CB',   l_class_cb,
                                                                                                            'CM',   l_class_cm,
                                                                                                            'DEP',  l_class_dep,
                                                                                                            'DM',   l_class_dm,
                                                                                                            'GUAR', l_class_guar,
                                                                                                            'INV',  l_class_inv,NULL) || ' ' || ct.trx_number|| l_post_general,
                                                                       l_pre_adjcr_adj ||  DECODE(ctt.type, 'CB',   l_class_cb,
                                                                                                            'CM',   l_class_cm,
                                                                                                            'DEP',  l_class_dep,
                                                                                                            'DM',   l_class_dm,
                                                                                                            'GUAR', l_class_guar,
                                                                                                            'INV',  l_class_inv,NULL) || ' ' || ct.trx_number|| l_post_general)))     ref10,
	          TO_CHAR(l_pst_ctrl_id)                                ref21,
	          TO_CHAR(psa_adj_dist.adjustment_id)                   ref22,
--	          TO_CHAR(psa_adj_dist.cust_trx_line_gl_dist_id)        ref23,
		  nvl(get_adj_ard_id(adj.adjustment_id),
		      to_char(psa_adj_dist.cust_trx_line_gl_dist_id) )  ref23,
	          ct.trx_number                                         ref24,
	          adj.adjustment_number                                 ref25,
                  ctt.type                                              ref26,
	          ct.bill_to_customer_id                                ref27,
	          'ADJ'                                                 ref28,
	          DECODE(l.lookup_code, '1', 'ADJ_REC',
	          	                '2', 'ADJ_ADJ',
                                        '3', 'ADJ_FINCHRG')                 ref29,
	          'PSA_ADJ_DIST'                                        ref30
	  FROM   ar_adjustments adj,
	         psa_mf_adj_dist_all psa_adj_dist,
	         psa_mf_trx_dist_all psa_trx_dist,
	         ra_customer_trx ct,
	         ra_cust_trx_line_gl_dist ctlgd,
	         ra_cust_trx_types ctt,
	         psa_lookup_codes l
	  WHERE  psa_adj_dist.adjustment_id              = adj.adjustment_id
	  AND    adj.adjustment_id                       = p_adjustment_id
	  AND    psa_trx_dist.cust_trx_line_gl_dist_id   = psa_adj_dist.cust_trx_line_gl_dist_id
          AND    adj.customer_trx_id                     = ct.customer_trx_id
	  AND    ct.cust_trx_type_id                     = ctt.cust_trx_type_id
	  AND    psa_adj_dist.cust_trx_line_gl_dist_id   = ctlgd.cust_trx_line_gl_dist_id
	  AND    l.lookup_type                           = 'PSA_CARTESIAN_JOIN'
--	  AND    l.lookup_code in ('1','2','3','4')
	  AND    l.lookup_code in ('1','4')
--          AND    nvl(psa_adj_dist.amount, 0) <> 0	-- Bug 3739491, commented this condition
          AND    adj.posting_control_id                   = l_pst_ctrl_id
	  AND    nvl(psa_adj_dist.posting_control_id, -3) = -3;

        -- ========================= FND LOG ===========================
           l_full_path VARCHAR2(100) := g_path || 'mfar_adj_to_gl';
        -- ========================= FND LOG ===========================

BEGIN

  -- ========================= FND LOG ===========================
  psa_utils.debug_other_string(g_state_level,l_full_path,
                               '                                                           ' );
  psa_utils.debug_other_string(g_state_level,l_full_path,
                               '                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
  psa_utils.debug_other_string(g_state_level,l_full_path,
                               '                         (TRANSFERRING ADJUSTMENTS) '
			       || to_char (sysdate, 'DD/MM/YYYY HH:MI:SS'));
  psa_utils.debug_other_string(g_state_level,l_full_path,
                               '                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
  psa_utils.debug_other_string(g_state_level,l_full_path,
                               '                                                           ');
  -- ========================= FND LOG ===========================
  retcode                := 'S';
  l_gl_start_date        := p_gl_date_from;
  l_post_through_date    := p_gl_date_to;
  l_summary_flag         := p_summary_flag;
  l_sob_id               := p_set_of_books_id;

  -- ========================= FND LOG ===========================
  psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS :');
  psa_utils.debug_other_string(g_state_level,l_full_path,' ============');
  psa_utils.debug_other_string(g_state_level,l_full_path,' p_gl_date_from    -->' || p_gl_date_from);
  psa_utils.debug_other_string(g_state_level,l_full_path,' p_gl_date_to      -->' || p_gl_date_to  );
  psa_utils.debug_other_string(g_state_level,l_full_path,' p_summary_flag    -->' || p_summary_flag );
  psa_utils.debug_other_string(g_state_level,l_full_path,' p_set_of_books_id -->' || p_set_of_books_id );
  psa_utils.debug_other_string(g_state_level,l_full_path,'             ');
  psa_utils.debug_other_string(g_state_level,l_full_path,' OTHER VALUES :');
  psa_utils.debug_other_string(g_state_level,l_full_path,' =============  ');
  psa_utils.debug_other_string(g_state_level,l_full_path,' l_gl_start_date     -->' || l_gl_start_date);
  psa_utils.debug_other_string(g_state_level,l_full_path,' l_post_through_date -->' || l_post_through_date);
  psa_utils.debug_other_string(g_state_level,l_full_path,' l_summary_flag      -->' || l_summary_flag);
  psa_utils.debug_other_string(g_state_level,l_full_path,' l_sob_id            -->' || l_sob_id);
  psa_utils.debug_other_string(g_state_level,l_full_path,'          ');
  psa_utils.debug_other_string(g_state_level,l_full_path,' PROCESS :');
  psa_utils.debug_other_string(g_state_level,l_full_path,' =========');
  psa_utils.debug_other_string(g_state_level,l_full_path,'           ');
  -- ========================= FND LOG ===========================

  FOR I IN Cur_lines_to_be_processed
  LOOP

        BEGIN
          -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,
                                       ' --> Creating distribution for adjustment id ==> ' || l_run_num
				       || ' -- ' || I.adjustment_id);
          -- ========================= FND LOG ===========================

          IF NOT (PSA_MFAR_ADJUSTMENTS.create_distributions (
                                                     errbuf            => l_errbuf,
                                                     retcode           => l_retcode,
                                                     p_adjustment_id   => I.adjustment_id,
                                                     p_set_of_books_id => l_sob_id,
                                                     p_run_id          => l_run_num,
                                                     p_error_message   => l_error_message)) THEN

                  IF l_error_message IS NOT NULL OR l_retcode = 'F' THEN
                     -- ========================= FND LOG ===========================
                     psa_utils.debug_other_string(g_state_level,l_full_path,
		                                   'Mfar_adj_to_gl:  Raising  invalid_distribution');
                     -- ========================= FND LOG ===========================
                     Raise invalid_distribution;
                  END IF;

          ELSE
                  -- ========================= FND LOG ===========================
                  psa_utils.debug_other_string(g_state_level,l_full_path,
		                                'Mfar_adj_to_gl:  '
						||  '     Adjustment id --> ' || I.adjustment_id);
                  -- ========================= FND LOG ===========================
          END IF;
      END;

      -- Bug 3817595 .. Start
      DELETE FROM GL_INTERFACE GI
       WHERE GI.user_je_source_name = 'Receivables'
         AND GI.set_of_books_id     = l_sob_id
         AND GI.group_id    	    = l_pst_ctrl_id
	 AND GI.reference28	    =  'ADJ'
	 AND GI.reference29	    IN ('ADJ_ADJ', 'ADJ_REC', 'ADJ_FINCHRG')
	 AND GI.reference10	    NOT LIKE '%MFAR%'
         AND GI.reference22	    = to_char(I.adjustment_id);
      -- Bug 3817595 .. End

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
                                      '     Deleting rows from Gl interface ' || SQL%ROWCOUNT);
      -- ========================= FND LOG ===========================

     FOR J IN Cur_mfar_lines (I.adjustment_id)
      LOOP

      /*
      ## For each adjustments id the record will be inserted.
      */

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
                                       ' --> adjustment id ==> ' || I.adjustment_id );
      -- ========================= FND LOG ===========================

      INSERT INTO gl_interface
	        (created_by,
	         date_created,
	         status,
	         actual_flag,
	         group_id,
	         set_of_books_id,
	         user_je_source_name,
	         user_je_category_name,
	         accounting_date,
	         subledger_doc_sequence_id,
	         subledger_doc_sequence_value,
	         currency_code,
	         code_combination_id,
	         entered_dr,
	         entered_cr,
	         accounted_dr,
	         accounted_cr,
	         ussgl_transaction_code,
	         reference1,
	         reference10,
	         reference21,
	         reference22,
	         reference23,
	         reference24,
	         reference25,
	         reference26,
	         reference27,
	         reference28,
	         reference29,
	         reference30)
        VALUES  (l_user_id,
                 trunc(sysdate),
                 l_status,
                 l_actual_flag,
                 l_pst_ctrl_id,
                 l_sob_id,
                 l_source,
                 l_adj_cat_name,
                 J.gl_date,
	         J.doc_seqid,
	         J.doc_num,
	         J.currency,
	         J.ccid,
	         J.entered_dr,
	         J.entered_cr,
	         J.accounted_dr,
	         J.accounted_cr,
	         J.ussgl_transaction_code,
	         J.ref1,
	         J.ref10,
	         J.ref21,
	         J.ref22,
	         J.ref23,
	         J.ref24,
	         J.ref25,
	         J.ref26,
	         J.ref27,
	         J.ref28,
	         J.ref29,
	         J.ref30);

        IF (SQL%FOUND) THEN
                -- ========================= FND LOG ===========================
                psa_utils.debug_other_string(g_state_level,l_full_path,
		                             ' --> Inserting into GL INTERFACE for adjustment id ==> '
					     || I.adjustment_id );
                psa_utils.debug_other_string(g_state_level,l_full_path,
		                             ' CCID   => ' || J.ccid
					  || ' DEBIT  => ' || J.entered_dr
					  || ' CREDIT => ' || J.entered_cr );
                psa_utils.debug_other_string(g_state_level,l_full_path,
		                             '     USSGL_TRANSACTION_CODE => '|| J.ussgl_transaction_code);
                -- ========================= FND LOG ===========================
        END IF;
     END LOOP;

  END LOOP;

    UPDATE psa_mf_adj_dist_all pada
    SET    pada.posting_control_id = l_pst_ctrl_id
    WHERE  pada.adjustment_id IN
          (SELECT adjustment_id FROM ar_adjustments aa
           WHERE  aa.posting_control_id = l_pst_ctrl_id);

    IF (SQL%FOUND) THEN
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
	                                ' --> (PSA_MF_ADJ_DIST_ALL) Posting control id updated for '
				        || (SQL%ROWCOUNT));
        -- ========================= FND LOG ===========================
    END IF;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_event_level,l_full_path,
                                    ' --> End of Adjustments transfer '
				    || to_char (sysdate, 'DD/MM/YYYY HH:MI:SS'));
    -- ========================= FND LOG ===========================

 EXCEPTION
    WHEN INVALID_DISTRIBUTION THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                     ' --> EXCEPTION - INVALID_DISTRIBUTION raised during PPSA_XFR_TO_GL_PKG.Mfar_adj_to_gl ');
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                         ' --> p_error_message  --> ' || l_error_message);
         -- ========================= FND LOG ===========================
         retcode  := 'F';

    WHEN OTHERS THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                      ' --> EXCEPTION - OTHERS raised during PSA_XFR_TO_GL_PKG.Mfar_adj_to_gl ');
            psa_utils.debug_other_string(g_excep_level,l_full_path,   sqlcode || sqlerrm);
            psa_utils.debug_unexpected_msg(l_full_path);
         -- ========================= FND LOG ===========================
         errbuf  := 2;
         retcode := 'F';

 END  Mfar_adj_to_gl;

 /* ########################################## REVERSE_CORE_ENTRIES_IF_ANY ################################# */

 -- Bug 3621280.
 -- Flow :
 -- Get the Balancing or Natural segment based in the Allocation method
 -- Check whether any CM application is there in gl_interface for any core entries
 -- IF exists then check whether its balanced based on Allocation method
 --    IF not balanced then create reversal entry.
 --
 -- This procedure will be called from transfer_to_gl.
 -- And it will process all the CM app records in gl_interface for a group_id.
 --
 -- When you modify the procedure please make sure you modify the debug statements as well.
 --

 PROCEDURE Reverse_core_entries_if_any (errbuf               OUT NOCOPY VARCHAR2,
                                        retcode              OUT NOCOPY VARCHAR2,
                                        p_set_of_books_id    IN  NUMBER,
                                        p_error_message      OUT NOCOPY VARCHAR2)
 IS

  -- Getting chart of account id.
  CURSOR Cur_coa_id (p_sob_id NUMBER)
  IS
    SELECT chart_of_accounts_id FROM gl_sets_of_books
    WHERE set_of_books_id = p_sob_id;

  CURSOR Cur_cust_trx_id
  IS
   SELECT distinct reference22 FROM gl_interface
   WHERE  group_id = l_pst_ctrl_id
   AND    reference28 = 'CMAPP'
   AND    reference29 = 'CMAPP_REC'
   AND    reference30 = 'AR_RECEIVABLE_APPLICATIONS';

  CURSOR Cur_CM_dets (p_cust_trx_id NUMBER)
  IS
   SELECT  accounting_date                gl_date,
	   subledger_doc_sequence_id      doc_seqid,
	   subledger_doc_sequence_value   doc_num,
	   currency_code                  currency,
	   code_combination_id            ccid,
	   entered_dr                     entered_dr,
	   entered_cr                     entered_cr,
	   accounted_dr                   accounted_dr,
	   accounted_cr                   accounted_cr,
	   reference1                     ref1,
	   'MFAR reversal for' || Substr(reference10,19) ref10,
	   reference21                   ref21,
	   reference22                   ref22,
	   reference23                   ref23,
	   reference24                   ref24,
	   reference25                   ref25,
	   reference26                   ref26,
	   reference27                   ref27,
	   reference28                   ref28,
	   reference29                   ref29,
	   reference30                   ref30
   FROM   gl_interface
   WHERE  group_id    = l_pst_ctrl_id
   AND    reference22 = p_cust_trx_id
   AND    reference28 = 'CMAPP'
   AND    reference29 = 'CMAPP_REC'
   AND    reference30 = 'AR_RECEIVABLE_APPLICATIONS';

   l_chart_of_accounts_id        NUMBER;
   l_org_details	         PSA_IMPLEMENTATION_ALL%ROWTYPE;
   l_qual_name                   VARCHAR2(20);
   l_acct_seg_num                NUMBER;
   l_select                      VARCHAR2(3000);
   l_count                       NUMBER;

   TYPE gl_rec_type IS RECORD (Segment VARCHAR2(25), Debit NUMBER, Credit NUMBER);
   TYPE gl_tab_type IS TABLE OF gl_rec_type INDEX BY Binary_integer;
   gl_int_dets      gl_tab_type;
   gl_int_dets_null gl_tab_type;

  GET_QUALIFIER_SEGNUM_EXCEP    EXCEPTION;

  -- ========================= FND LOG ===========================
     l_full_path VARCHAR2(100) := g_path || 'Reverse_core_entries_if_any';
  -- ========================= FND LOG ===========================

 BEGIN

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' START Reverse_core_entries_if_any ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS :');
     psa_utils.debug_other_string(g_state_level,l_full_path,' ============');
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_set_of_books_id -->' || p_set_of_books_id );
     psa_utils.debug_other_string(g_state_level,l_full_path,'             ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' PROCESS :');
     psa_utils.debug_other_string(g_state_level,l_full_path,' =========');
     psa_utils.debug_other_string(g_state_level,l_full_path,'           ');
  -- ========================= FND LOG ===========================

  retcode := 'S';

  OPEN  Cur_coa_id (p_set_of_books_id);
  FETCH Cur_coa_id INTO l_chart_of_accounts_id;
  CLOSE Cur_coa_id;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' l_chart_of_accounts_id --> ' || l_chart_of_accounts_id);
     psa_utils.debug_other_string(g_state_level,l_full_path,' Getting org details ');
  -- ========================= FND LOG ===========================

  PSA_MFAR_UTILS.PSA_MF_ORG_DETAILS (l_org_details);

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' l_org_details.allocation_method --> ' || l_org_details.allocation_method);
  -- ========================= FND LOG ===========================

  IF (l_org_details.allocation_method = 'BAL') THEN
     l_qual_name := 'GL_BALANCING';
  ELSE -- ## 'ACC'
     l_qual_name := 'GL_ACCOUNT';
  END IF;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' l_qual_name --> ' || l_qual_name);
     psa_utils.debug_other_string(g_state_level,l_full_path,' Calling FND_FLEX_APIS.GET_QUALIFIER_SEGNUM ' );
  -- ========================= FND LOG ===========================

  IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                                             APPL_ID                => 101,
                                             KEY_FLEX_CODE          => 'GL#',
                                             STRUCTURE_NUMBER       => l_chart_of_accounts_id,
                                             FLEX_QUAL_NAME         => l_qual_name,
                                             SEGMENT_NUMBER         => l_acct_seg_num))  THEN   -- OUT
      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' l_acct_seg_num --> ' || l_acct_seg_num );
         psa_utils.debug_other_string(g_state_level,l_full_path,' Raising GET_QUALIFIER_SEGNUM_EXCEP ');
      -- ========================= FND LOG ===========================
         RAISE GET_QUALIFIER_SEGNUM_EXCEP;
  ELSE
      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' l_acct_seg_num --> ' || l_acct_seg_num );
      -- ========================= FND LOG ===========================
  END IF;

  -- Picking up details from gl_interface.
  FOR C_cust_trx_dets IN Cur_cust_Trx_id
  LOOP

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' Inside Cur_cust_Trx_id');
    -- ========================= FND LOG ===========================

    gl_int_dets := gl_int_dets_null;

    l_select := ' SELECT segment' || l_acct_seg_num || ' Segment, SUM(accounted_dr) Debit, SUM(accounted_cr) Credit' ||
                ' FROM   gl_interface ' ||
                ' WHERE  reference22 = :1' ||
                ' AND    reference30 = :2' ||
                ' GROUP BY segment' || l_acct_seg_num ||
                ' HAVING SUM(nvl(accounted_dr,0)) <> SUM(nvl(accounted_cr,0))' ;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' C_cust_trx_dets.reference22 --> ' || C_cust_trx_dets.reference22);
       psa_utils.debug_other_string(g_state_level,l_full_path,' l_select --> ' || l_select);
    -- ========================= FND LOG ===========================

    EXECUTE IMMEDIATE l_select BULK COLLECT INTO gl_int_dets USING C_cust_trx_dets.reference22, 'AR_RECEIVABLE_APPLICATIONS';

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' Execute immediate ');
    -- ========================= FND LOG ===========================

    l_count := gl_int_dets.count;

    IF (l_count <> 0)
    THEN
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' l_count --> ' || l_count);
       -- ========================= FND LOG ===========================

       FOR C_int_dets IN Cur_CM_dets (C_cust_trx_dets.reference22)
       LOOP

         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,' Inserting into gl_interface');
         -- ========================= FND LOG ===========================

        INSERT INTO gl_interface
	        (created_by,
	         date_created,
	         status,
	         actual_flag,
	         group_id,
	         set_of_books_id,
	         user_je_source_name,
	         user_je_category_name,
	         accounting_date,
	         subledger_doc_sequence_id,
	         subledger_doc_sequence_value,
	         currency_code,
	         code_combination_id,
	         entered_dr,
	         entered_cr,
	         accounted_dr,
	         accounted_cr,
	         reference1,
	         reference10,
	         reference21,
	         reference22,
	         reference23,
	         reference24,
	         reference25,
	         reference26,
	         reference27,
	         reference28,
	         reference29,
	         reference30)
        VALUES  (l_user_id,
                 trunc(sysdate),
                 l_status,
                 l_actual_flag,
                 l_pst_ctrl_id,
                 l_sob_id,
                 l_source,
                 l_user_cm_cat_name,
                 C_int_dets.gl_date,
	         C_int_dets.doc_seqid,
	         C_int_dets.doc_num,
	         C_int_dets.currency,
	         C_int_dets.ccid,
	         C_int_dets.entered_cr,     -- reversal so interchanged DB and CR.
	         C_int_dets.entered_dr,
	         C_int_dets.accounted_cr,
	         C_int_dets.accounted_dr,
	         C_int_dets.ref1,
	         C_int_dets.ref10,
	         C_int_dets.ref21,
	         C_int_dets.ref22,
	         C_int_dets.ref23,
	         C_int_dets.ref24,
	         C_int_dets.ref25,
	         C_int_dets.ref26,
	         C_int_dets.ref27,
	         C_int_dets.ref28,
	         C_int_dets.ref29,
	         C_int_dets.ref30);

         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,' Inserting into gl_interface --> ' || SQL%ROWCOUNT);
         -- ========================= FND LOG ===========================

      END LOOP;
    ELSE
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' l_count --> ' || l_count);
          psa_utils.debug_other_string(g_state_level,l_full_path,' BALANCED ');
       -- ========================= FND LOG ===========================
    END IF;

  END LOOP;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' END Reverse_core_entries_if_any ');
  -- ========================= FND LOG ===========================

 EXCEPTION

   WHEN GET_QUALIFIER_SEGNUM_EXCEP THEN
         p_error_message := fnd_message.get;
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                      ' --> EXCEPTION - GET_QUALIFIER_SEGNUM_EXCEP - ' || p_error_message);
         -- ========================= FND LOG ===========================
         retcode := 'F';

   WHEN OTHERS THEN
         p_error_message := sqlcode || sqlerrm;
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                      ' --> EXCEPTION - OTHERS raised during PSA_XFR_TO_GL_PKG.Reverse_core_entries_if_any ');
            psa_utils.debug_other_string(g_excep_level,l_full_path,   p_error_message);
            psa_utils.debug_unexpected_msg(l_full_path);
         -- ========================= FND LOG ===========================
         errbuf  := 2;
         retcode := 'F';

 END Reverse_core_entries_if_any;

 /* ########################################## POPULATE_GLOBAL_VARIABLES ################################# */

 /*
 ##  This procedure will populate all the variables that is required for this package before calling the
 ##  procedure that transfers RECEIPTS, ADJUSTMENTS, MISC TRANS, TRANSACTIONS.
 ##  This procedure is called only from  Transfer_to_gl procedure and the variables that this procedure
 ##  populates are declared in the starting of the package.
 */

 PROCEDURE Populate_global_variables
 IS

   /* getting the message text based on name AND lang */
   CURSOR Cur_message (p_message_name varchar2)
   IS
          SELECT Message_text FROM Fnd_new_messages
          WHERE  language_code = USERENV('LANG')
          AND    message_name  = p_message_name;

   CURSOR Cur_js_cat  (p_category_name VARCHAR2)
   IS
          SELECT user_je_category_name FROM gl_je_categories
          WHERE  je_category_name = p_category_name ;

   CURSOR Cur_je_source_name
   IS
          SELECT user_je_source_name FROM gl_je_sources
	    WHERE  je_source_name  = 'Receivables';

   CURSOR Cur_func_curr
   IS
          SELECT currency_code from gl_sets_of_books
          WHERE  Set_of_books_id = l_sob_id;

   l_fv_profile_defined  BOOLEAN;
   -- ========================= FND LOG ===========================
   l_full_path VARCHAR2(100) := g_path || 'Populate_global_variables';
   -- ========================= FND LOG ===========================

 BEGIN

  -- ========================= FND LOG ===========================
  psa_utils.debug_other_string(g_state_level,l_full_path,
                               '      --> Populate_global_variables - START '
			       || to_char(sysdate, 'DD/MM/YYYY HH:MI:SS'));
  -- ========================= FND LOG ===========================

  l_batch_prefix         := 'AR ';  -- Padded with a single space so that REFERENCE1 is correctly set as AR 3241
				    -- where 3241 is the posting_control_id
  l_user_id              := fnd_global.user_id;
  l_actual_flag          := 'A';
  l_status               := 'NEW';

  OPEN  Cur_func_curr;
  FETCH Cur_func_curr INTO l_func_curr;
  CLOSE Cur_func_curr;

  OPEN  Cur_message ('AR_NLS_GLTP_PRE_CT_LINE');
  FETCH Cur_message INTO l_pre_ct_line;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_GLTP_POST_CT_LINE');
  FETCH Cur_message INTO l_post_ct_line;
  CLOSE Cur_message;

  OPEN  Cur_js_cat ('Sales Invoices');
  FETCH Cur_js_cat INTO l_inv_cat_name;
  CLOSE Cur_js_cat;

  OPEN  Cur_js_cat ('Credit Memos');
  FETCH Cur_js_cat INTO l_cm_cat_name;
  CLOSE Cur_js_cat;

  -- Bug 3018452 (Tpradhan), Initialized the value of l_user_cm_cat_name
  -- using the cursor below (...Start...)

  OPEN  Cur_js_cat ('Credit Memo Applications');
  FETCH Cur_js_cat INTO l_user_cm_cat_name;
  CLOSE Cur_js_cat;

  -- Bug 3018452 (...End...)

  OPEN  Cur_js_cat ('Debit Memos');
  FETCH Cur_js_cat INTO l_dm_cat_name;
  CLOSE Cur_js_cat;

  OPEN  Cur_js_cat ('Chargebacks');
  FETCH Cur_js_cat INTO l_cb_cat_name;
  CLOSE Cur_js_cat;

  OPEN  Cur_js_cat ('Trade Receipts');
  FETCH Cur_js_cat INTO l_trade_cat_name;
  CLOSE Cur_js_cat;

  OPEN  Cur_js_cat ('Cross Currency');
  FETCH Cur_js_cat INTO l_ccurr_cat_name;
  CLOSE Cur_js_cat;

  OPEN  Cur_js_cat ('Adjustment');
  FETCH Cur_js_cat INTO l_adj_cat_name;
  CLOSE Cur_js_cat;

  OPEN  Cur_js_cat ('Misc Receipts');
  FETCH Cur_js_cat INTO l_misc_cat_name;
  CLOSE Cur_js_cat;

  OPEN  Cur_je_source_name;
  FETCH Cur_je_source_name INTO l_source;
  CLOSE Cur_je_source_name;

  OPEN  Cur_message ('AR_NLS_CLASS_CB');
  FETCH Cur_message INTO l_class_cb;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_CLASS_CM');
  FETCH Cur_message INTO l_class_cm;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_CLASS_DEP');
  FETCH Cur_message INTO l_class_dep;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_CLASS_DM');
  FETCH Cur_message INTO l_class_dm;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_CLASS_GUAR');
  FETCH Cur_message INTO l_class_guar;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_CLASS_INV');
  FETCH Cur_message INTO l_class_inv;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_GLTP_PRE_TRADEAPP');
  FETCH Cur_message INTO l_pre_tradeapp;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_APP_ONACC');
  FETCH Cur_message INTO l_app_onacc;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_APP_UNAPP');
  FETCH Cur_message INTO l_app_unapp;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_APP_UNID');
  FETCH Cur_message INTO l_app_unid;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_APP_APPLIED');
  FETCH Cur_message INTO l_app_applied;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_GLTP_PRE_ERDISC');
  FETCH Cur_message INTO l_pre_erdisc;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_GLTP_PRE_RCPT_EDISC_NRT');
  FETCH Cur_message INTO l_pre_rec_erdisc_nrtax;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_GLTP_PRE_UNDISC');
  FETCH Cur_message INTO l_pre_undisc;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_GLTP_PRE_RCPT_UDISC_NRT');
  FETCH Cur_message INTO l_pre_rec_undisc_nrtax;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_GLTP_PRE_RCPT_TAX');
  FETCH Cur_message INTO l_pre_rec_tax;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_GLTP_PRE_RCPT_GAIN');
  FETCH Cur_message INTO l_pre_rec_gain;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_GLTP_PRE_RCPT_LOSS');
  FETCH Cur_message INTO l_pre_rec_loss;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_GLTP_PRE_RCPT_CURROUND');
  FETCH Cur_message INTO l_pre_rec_curr_round;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_GLTP_PRE_RCPT_DEFTAX');
  FETCH Cur_message INTO l_pre_rec_deftax;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_GLTP_POST_GENERAL');
  FETCH Cur_message INTO l_post_general;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_GLTP_PRE_ADJCR_ADJ');
  FETCH Cur_message INTO l_pre_adjcr_adj;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_GLTP_PRE_ADJDR_ADJ');
  FETCH Cur_message INTO l_pre_adjdr_adj;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_GLTP_PRE_ADJCR_AR');
  FETCH Cur_message INTO l_pre_adjcr_ar;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_GLTP_PRE_ADJDR_AR');
  FETCH Cur_message INTO l_pre_adjdr_ar;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_GLTP_PRE_ADJCR');
  FETCH Cur_message INTO l_pre_adjcr;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_GLTP_PRE_ADJDR');
  FETCH Cur_message INTO l_pre_adjdr;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_GLTP_PRE_ADJ_DEFTAX');
  FETCH Cur_message INTO l_pre_adj_deftax;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_GLTP_PRE_ADJ_FINCHG');
  FETCH Cur_message INTO l_pre_adj_finchrg;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_GLTP_PRE_ADJ_FINCHG_NRT');
  FETCH Cur_message INTO l_pre_adj_finchrg_nrtax;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_GLTP_PRE_ADJ_NRT');
  FETCH Cur_message INTO l_pre_adj_nrtax;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_GLTP_PRE_ADJ_TAX');
  FETCH Cur_message INTO l_pre_adj_tax;
  CLOSE Cur_message;

  OPEN  Cur_message ('AR_NLS_CLASS_BR');
  FETCH Cur_message INTO l_class_br;
  CLOSE Cur_message;

  --
  -- Fetch profile option value for FV: Post Detailed Receipt Accounting
  --

  l_resp_appl_id := FND_GLOBAL.resp_appl_id;
  l_user_resp_id := FND_GLOBAL.RESP_ID;

  FND_PROFILE.GET_SPECIFIC('FV_POST_DETAIL_REC_ACCOUNTING',
                           l_user_id,
                           l_user_resp_id,
                           l_resp_appl_id,
                           l_post_det_acct_flag,
                           l_fv_profile_defined);

  IF not l_fv_profile_defined THEN
	l_post_det_acct_flag := 'Y';
  END IF;

  select psa_mf_error_log_s.nextval into l_run_num from dual;

  -- ========================= FND LOG ===========================
  psa_utils.debug_other_string(g_state_level,l_full_path,'                                                ');
  psa_utils.debug_other_string(g_state_level,l_full_path,'     LISTING THE VARIABLES AND VALUES :');
  psa_utils.debug_other_string(g_state_level,l_full_path,'     ==================================');
  psa_utils.debug_other_string(g_state_level,l_full_path,'     l_batch_prefix        -->' || l_batch_prefix);
  psa_utils.debug_other_string(g_state_level,l_full_path,'     l_user_id             -->' || l_user_id);
  psa_utils.debug_other_string(g_state_level,l_full_path,'     l_actual_flag         -->' || l_actual_flag);
  psa_utils.debug_other_string(g_state_level,l_full_path,'     l_status              -->' || l_status);
  psa_utils.debug_other_string(g_state_level,l_full_path,'     l_inv_cat_name        -->' || l_inv_cat_name);
  psa_utils.debug_other_string(g_state_level,l_full_path,'     l_cm_cat_name         -->' || l_cm_cat_name);
  psa_utils.debug_other_string(g_state_level,l_full_path,'     l_dm_cat_name         -->' || l_dm_cat_name);
  psa_utils.debug_other_string(g_state_level,l_full_path,'     l_cb_cat_name         -->' || l_cb_cat_name);
  psa_utils.debug_other_string(g_state_level,l_full_path,'     l_trade_cat_name      -->' || l_trade_cat_name);
  psa_utils.debug_other_string(g_state_level,l_full_path,'     l_ccurr_cat_name      -->' || l_ccurr_cat_name);
  psa_utils.debug_other_string(g_state_level,l_full_path,'     l_adj_cat_name        -->' || l_adj_cat_name);
  psa_utils.debug_other_string(g_state_level,l_full_path,'     l_misc_cat_name       -->' || l_misc_cat_name);
  psa_utils.debug_other_string(g_state_level,l_full_path,'     l_source              -->' || l_source);
  psa_utils.debug_other_string(g_state_level,l_full_path,'     l_func_curr           -->' || l_func_curr);
  psa_utils.debug_other_string(g_state_level,l_full_path,'     l_post_det_acct_flag  -->' || l_post_det_acct_flag);
  psa_utils.debug_other_string(g_state_level,l_full_path,'     l_user_resp_id        -->' || l_user_resp_id);
  psa_utils.debug_other_string(g_state_level,l_full_path,'     l_resp_appl_id        -->' || l_resp_appl_id);
  psa_utils.debug_other_string(g_state_level,l_full_path,'     l_pst_ctrl_id         -->' || l_pst_ctrl_id);
  psa_utils.debug_other_string(g_state_level,l_full_path,'                                                 ');
  psa_utils.debug_other_string(g_state_level,l_full_path, '         ** REST ARE MESSAGES **                ');
  psa_utils.debug_other_string(g_state_level,l_full_path,'                                                 ');
  psa_utils.debug_other_string(g_state_level,l_full_path,'      --> Populate_global_variables - END '
                                                           || to_char(sysdate, 'DD/MM/YYYY HH:MI:SS'));
  -- ========================= FND LOG ===========================

 EXCEPTION

    WHEN OTHERS THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                      ' --> EXCEPTION - OTHERS raised during PSA_TRANSFER_TO_GL_PKG.Populate_global_variables ');
            psa_utils.debug_other_string(g_excep_level,l_full_path,   sqlcode || sqlerrm);
            psa_utils.debug_unexpected_msg(l_full_path);
         -- ========================= FND LOG ===========================
         app_exception.raise_exception;

 END Populate_global_variables;

 /* ########################################## GET_ENTERED_DR_RCT ################################# */

 FUNCTION Get_entered_dr_rct (p_lookup_code IN NUMBER,
                              p_amount      IN NUMBER,
                              p_discount    IN NUMBER,
                              p_ue_discount IN NUMBER) RETURN NUMBER
 IS
    l_return_amount NUMBER;
 BEGIN

    IF    p_lookup_code IN (1,2,3,4) THEN
          l_return_amount := p_amount;
    ELSIF p_lookup_code IN (5,6,7,8) THEN
          l_return_amount := p_discount;
    ELSIF p_lookup_code IN (9,10,11,12) THEN
          l_return_amount := p_ue_discount;
    END IF;

    IF (l_return_amount >= 0)  THEN                            /* POSITIVE */
          IF p_lookup_code IN (2,4,6,8,10,12) THEN             /* EVEN (CR) LINES */
             l_return_amount := NULL;
          END IF;
    ELSIF (l_return_amount < 0)  THEN                          /* NEGATIVE */
          IF    p_lookup_code IN (1,3,5,7,9,11)  THEN          /* ODD (DR) LINES */
                l_return_amount := NULL;
          ELSIF p_lookup_code IN (2,4,6,8,10,12) THEN          /* EVEN (CR) LINES */
                l_return_amount := -1 * l_return_amount ;
          END IF;
    END IF;

    RETURN l_return_amount;
  END Get_entered_dr_rct;

 /* ########################################## GET_ENTERED_CR_RCT ################################# */

 FUNCTION Get_entered_cr_rct (p_lookup_code IN NUMBER,
                              p_amount      IN NUMBER,
                              p_discount    IN NUMBER,
                              p_ue_discount IN NUMBER)  RETURN NUMBER
 IS
    l_return_amount NUMBER;
 BEGIN

    IF    p_lookup_code IN (1,2,3,4) THEN
          l_return_amount := p_amount;
    ELSIF p_lookup_code IN (5,6,7,8) THEN
          l_return_amount := p_discount;
    ELSIF p_lookup_code IN (9,10,11,12) THEN
          l_return_amount := p_ue_discount;
    END IF;

    IF    (l_return_amount >= 0) THEN                            /* POSITIVE */
          IF p_lookup_code IN (1,3,5,7,9,11) THEN                /* ODD (DR) LINES */
             l_return_amount := NULL;
          END IF;
    ELSIF (l_return_amount < 0)  THEN                            /* NEGATIVE */
          IF    p_lookup_code IN (2,4,6,8,10,12)  THEN           /* EVEN (CR) LINES */
                l_return_amount := NULL;
          ELSIF p_lookup_code IN (1,3,5,7,9,11) THEN             /* ODD (DR) LINES */
                l_return_amount := -1 * l_return_amount ;
          END IF;
    END IF;

   RETURN l_return_amount;
 END Get_entered_cr_rct ;

 /* ########################################## GET_ENTERED_CR_CRM ################################# */

  FUNCTION Get_entered_cr_crm (p_lookup_code IN NUMBER,
                               p_amount      IN NUMBER) RETURN NUMBER
  IS
    l_return_amount NUMBER := NULL;
  BEGIN
     IF p_lookup_code in (1)  THEN
        l_return_amount := p_amount * -1;
     END IF;
     RETURN l_return_amount;
  END Get_entered_cr_crm;

 /* ########################################## GET_ENTERED_DR_CRM ################################# */

  FUNCTION Get_entered_dr_crm (p_lookup_code IN NUMBER,
                               p_amount      IN NUMBER) RETURN NUMBER
  IS
    l_return_amount NUMBER := NULL;
  BEGIN
    IF p_lookup_code in (2)  THEN
       l_return_amount := p_amount * -1;
    END IF;
    RETURN l_return_amount;
  END Get_entered_dr_crm;

 /* ########################################## GET_ENTERED_DR_ADJ ################################# */

 FUNCTION get_entered_dr_adj (p_lookup_code IN NUMBER, p_amount IN NUMBER) RETURN NUMBER
 IS
  l_return_amount NUMBER;
 BEGIN
  l_return_amount := p_amount;
  IF   (l_return_amount < 0)  THEN                        /* NEGATIVE */
       IF    p_lookup_code IN (1,3) THEN                  /* Odd (Dr) Lines */
             l_return_amount := -1 * l_return_amount ;
       ELSIF p_lookup_code IN (2,4) THEN                  /* Even (Cr) Lines */
             l_return_amount := NULL;
       END IF;

  ELSIF (l_return_amount >= 0)  THEN                      /* POSITIVE */
        IF p_lookup_code in (1,3)  THEN                   /* Odd (Dr) Lines */
           l_return_amount := NULL;
        END IF;
  END IF;

  RETURN l_return_amount;
 END get_entered_dr_adj;

 /* ########################################## GET_ENTERED_CR_ADJ ################################# */

 FUNCTION Get_entered_cr_adj (p_lookup_code IN NUMBER, p_amount IN NUMBER) RETURN NUMBER
 IS
  l_return_amount NUMBER;
 BEGIN
  l_return_amount := p_amount;
  IF (l_return_amount < 0) THEN                           /* NEGATIVE */
      IF    p_lookup_code IN (1,3) THEN                   /* Odd (Dr) Lines */
            l_return_amount := NULL;
      ELSIF p_lookup_code in (2,4) THEN                   /* Even (Cr) Lines */
            l_return_amount := -1 * l_return_amount ;
      END IF;

  ELSIF (l_return_amount >= 0)  THEN                      /* POSITIVE */
        IF p_lookup_code in (2,4)  THEN                   /* Even (Cr)  Lines */
           l_return_amount := NULL;
        END IF;

  END IF;

  RETURN l_return_amount;
 END get_entered_cr_adj;

 /* ##########################################UPD_SEG_IN_GL_INTERFACE ################################# */

 PROCEDURE Upd_seg_in_gl_interface
 IS
   -- ========================= FND LOG ===========================
   l_full_path VARCHAR2(100) := g_path || 'Upd_seg_in_gl_interface';
   -- ========================= FND LOG ===========================
 BEGIN
         -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
                                       '      --> Upd_seg_in_gl_interface - START '
	                               || to_char (sysdate, 'DD/MM/YYYY HH:MI:SS'));
         -- ========================= FND LOG ===========================

         UPDATE gl_interface gi
         SET (
              gi.segment1 , gi.segment2 , gi.segment3 , gi.segment4 , gi.segment5 , gi.segment6 ,
              gi.segment7 , gi.segment8 , gi.segment9 , gi.segment10, gi.segment11, gi.segment12,
              gi.segment13, gi.segment14, gi.segment15, gi.segment16, gi.segment17, gi.segment18,
              gi.segment19, gi.segment20, gi.segment21, gi.segment22, gi.segment23, gi.segment24,
              gi.segment25, gi.segment26, gi.segment27, gi.segment28, gi.segment29, gi.segment30) =
             (SELECT
                 cc.segment1 , cc.segment2 , cc.segment3 , cc.segment4 , cc.segment5 , cc.segment6 ,
                 cc.segment7 , cc.segment8 , cc.segment9 , cc.segment10, cc.segment11, cc.segment12,
                 cc.segment13, cc.segment14, cc.segment15, cc.segment16, cc.segment17, cc.segment18,
                 cc.segment19, cc.segment20, cc.segment21, cc.segment22, cc.segment23, cc.segment24,
                 cc.segment25, cc.segment26, cc.segment27, cc.segment28, cc.segment29, cc.segment30
              FROM  gl_code_combinations cc
              WHERE cc.code_combination_id = gi.code_combination_id)
         WHERE gi.group_id = l_pst_ctrl_id
         AND   reference10 like '%MFAR%';

         -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
	                               '      --> Upd_seg_in_gl_interface - END '
				       || to_char (sysdate, 'DD/MM/YYYY HH:MI:SS'));
         -- ========================= FND LOG ===========================

 END Upd_seg_in_gl_interface;


 /* ########################################## GET_ADJ_CCID ################################# */

 FUNCTION Get_adj_ccid (p_adjustment_id IN NUMBER) RETURN NUMBER
 IS

   CURSOR c_adj_ccid (c_adjustment_id NUMBER)
   IS
     SELECT ard.code_combination_id         adj_ccid
     FROM   ar_adjustments_all              adj,
            ar_distributions_all            ard
     WHERE adj.adjustment_id		= c_adjustment_id
     AND adj.adjustment_id 		= ard.source_id
     AND ard.source_table  		= 'ADJ'
     AND ard.source_type   		IN ('ADJ', 'FINCHRG');

   l_adj_ccid	c_adj_ccid%ROWTYPE;

 BEGIN

   OPEN  c_adj_ccid (p_adjustment_id);
   FETCH c_adj_ccid INTO l_adj_ccid;
   CLOSE c_adj_ccid;

   RETURN l_adj_ccid.adj_ccid;

 END Get_adj_ccid;

 /* ########################################## GET_ADJ_ARD_ID ################################# */

 FUNCTION Get_adj_ard_id (p_adjustment_id IN NUMBER) RETURN NUMBER
 IS

   CURSOR c_adj_ard_id (c_adjustment_id NUMBER)
   IS
     SELECT ard.line_id         	adj_ard_id
       FROM ar_adjustments_all		adj,
            ar_distributions_all        ard
      WHERE adj.adjustment_id		= c_adjustment_id
        AND adj.adjustment_id 		= ard.source_id
        AND ard.source_table  		= 'ADJ'
        AND ard.source_type   		IN ('ADJ', 'FINCHRG');

   l_adj_ard_id	c_adj_ard_id%ROWTYPE;

 BEGIN

   OPEN  c_adj_ard_id (p_adjustment_id);
   FETCH c_adj_ard_id INTO l_adj_ard_id;
   CLOSE c_adj_ard_id;

   RETURN l_adj_ard_id.adj_ard_id;

 END Get_adj_ard_id;

 /* ########################################## GET_MISC_ARD_ID ################################# */

 FUNCTION Get_misc_ard_id (p_misc_cash_dist_id IN NUMBER) RETURN NUMBER
 IS

   CURSOR c_misc_ard_id (c_misc_cash_dist_id NUMBER)
   IS
     SELECT ard.line_id         		misc_ard_id
       FROM ar_misc_cash_distributions_all 	mcd,
            ar_distributions_all        	ard
      WHERE mcd.misc_cash_distribution_id	= c_misc_cash_dist_id
        AND mcd.misc_cash_distribution_id	= ard.source_id
        AND ard.source_table		  	= 'MCD';

   l_misc_ard_id	c_misc_ard_id%ROWTYPE;

 BEGIN

   OPEN  c_misc_ard_id (p_misc_cash_dist_id);
   FETCH c_misc_ard_id INTO l_misc_ard_id;
   CLOSE c_misc_ard_id;

   RETURN l_misc_ard_id.misc_ard_id;

 END Get_misc_ard_id;

 /* ########################################## GET_ENTERED_DR_RCT ################################# */

 FUNCTION Get_entered_dr_rct_clear (p_lookup_code IN NUMBER,
                                   p_amount      IN NUMBER,
                                   p_curr_status IN VARCHAR2,
                                   p_prev_status IN VARCHAR2) RETURN NUMBER  IS
    l_return_amount NUMBER;
 BEGIN

   l_return_amount := p_amount;
        IF l_return_amount > 0 THEN
          IF p_lookup_code IN (1,3) THEN             /*  (CR) LINES */
             if p_curr_status = 'CLEARED' and p_prev_status = 'REMITTED' then
               l_return_amount := NULL;
              ELSIF p_curr_status = 'REMITTED' and p_prev_status = 'CLEARED' THEN
               l_return_amount := 1* l_return_amount ;
--               NULL;
             END IF;
          END IF;
          IF    p_lookup_code IN (2,4)  THEN                     /* ODD (DR) LINES */
             if p_curr_status = 'CLEARED' and p_prev_status = 'REMITTED' then
                l_return_amount := 1* l_return_amount ;
             ELSIF p_curr_status = 'REMITTED' and p_prev_status = 'CLEARED' THEN
                l_return_amount := NULL;
             END IF;
          END IF;
        ELSIF l_return_amount < 0 THEN
          IF p_lookup_code IN (1,3) THEN             /*  (CR) LINES */
             l_return_amount := -1* l_return_amount;
          END IF;
          IF p_lookup_code IN (2,4) THEN             /*  (CR) LINES */
             l_return_amount := NULL; ---1* l_return_amount;
          END IF;
        END IF;

    RETURN l_return_amount;
  END Get_entered_dr_rct_clear;

 /* ########################################## GET_ENTERED_CR_RCT ################################# */

 FUNCTION Get_entered_cr_rct_clear (p_lookup_code IN NUMBER,
                                    p_amount      IN NUMBER,
                                    p_curr_status IN VARCHAR2,
                                    p_prev_status IN VARCHAR2) RETURN NUMBER  IS
    l_return_amount NUMBER;
 BEGIN

   l_return_amount := p_amount;
        IF l_return_amount > 0 THEN
          IF p_lookup_code IN (2,4)  THEN             /*  (CR) LINES */
             if p_curr_status = 'CLEARED' and p_prev_status = 'REMITTED' then
                l_return_amount := NULL;
             ELSIF p_curr_status = 'REMITTED' and p_prev_status = 'CLEARED' THEN
                l_return_amount := 1* l_return_amount ;
             END IF;
          END IF;
          IF    p_lookup_code IN (1,3)  THEN          /* ODD (DR) LINES */
             if p_curr_status = 'CLEARED' and p_prev_status = 'REMITTED' then
                l_return_amount := 1* l_return_amount ;
               ELSIF p_curr_status = 'REMITTED' and p_prev_status = 'CLEARED' THEN
                l_return_amount := NULL;
             END IF;
          END IF;
        ELSIF l_return_amount < 0 THEN
          IF p_lookup_code IN (2,4)  THEN             /*  (CR) LINES */
             l_return_amount := -1*l_return_amount;
          END IF;
          IF p_lookup_code IN (1,3)  THEN             /*  (CR) LINES */
             l_return_amount := null;
          END IF;

       END if;

    RETURN l_return_amount;
  END Get_entered_cr_rct_clear;

 /* For a Cash Receipt - remitted and then cleared and then reversed - in that order
 MFAR generated reversal for any remittance account (core or Multi-fund) is not required. */

 FUNCTION clear_reversal_lines(p_lookup_code IN NUMBER,
                               p_amount IN NUMBER,
                               p_crh_status IN VARCHAR2,
                               p_crh_first_record_flag IN VARCHAR2,
                               p_rev_crh_id IN NUMBER) RETURN varchar2 IS
  CURSOR c_crh_parent IS SELECT status FROM ar_cash_receipt_history WHERE
       cash_receipt_history_id = p_rev_crh_id;
   l_status VARCHAR2(30);
   BEGIN
    IF p_amount < 0 THEN
      IF p_crh_first_record_flag = 'Y' then
        if p_crh_status = 'CLEARED' THEN
          RETURN 'T';
         ELSIF p_crh_status = 'REMITTED' THEN
          OPEN c_crh_parent;
           FETCH c_crh_parent INTO l_status;
          CLOSE c_crh_parent;
           IF l_status = 'REVERSED' THEN
             RETURN 'T';
            ELSIF l_status = 'CLEARED' THEN
              IF p_lookup_code IN (1,2) then
                RETURN 'F';
              END IF;
           END IF;
        END IF;
      ELSIF nvl(p_crh_first_record_flag,'N') = 'N' THEN
       IF p_crh_status = 'CLEARED' THEN
        IF p_lookup_code in (1,2) then
         RETURN 'F';
        END IF;
       END IF;
     END IF;
   END IF;
 END;

 PROCEDURE Mfar_rcpt_to_gl_CB
			   (errbuf               OUT NOCOPY VARCHAR2,
                            retcode              OUT NOCOPY VARCHAR2,
                            p_set_of_books_id    IN  NUMBER,
                            p_gl_date_from       IN  VARCHAR2,
                            p_gl_date_to         IN  VARCHAR2,
                            p_gl_posted_date     IN  VARCHAR2,
                            p_summary_flag       IN  VARCHAR2) IS

  /* The l_ variables used IN this cursor are Global variables in this package */

  CURSOR Cur_MFAR_rct_app_id
  IS
	SELECT distinct ra.receivable_application_id receivable_application_id
	  FROM ar_receivable_applications ra
         WHERE ra.status 		= 'APP'
	   AND ra.posting_control_id	= l_pst_ctrl_id
           AND DECODE(PSA_MFAR_VAL_PKG.ar_mfar_validate_check
			(ra.receivable_application_id, 'RCT', l_sob_id) , 'Y', 'MFAR_TYPE', 'NOT_MFAR_TYPE') = 'MFAR_TYPE';

   CURSOR Cur_mfar_rct_lines (p_receivable_application_id NUMBER)
   IS
        SELECT
        DECODE(to_number(l1.lookup_code), '4',  ra.ussgl_transaction_code,
                			  '8',  ra.ussgl_transaction_code,
                			  '12', ra.ussgl_transaction_code, NULL)   		    ussgl,
        DECODE (ra.application_type, 'CASH', DECODE(ra.amount_applied_from,  NULL, l_trade_cat_name, l_ccurr_cat_name),
                                     'CM',   l_user_cm_cat_name )                                     category,
        ra.gl_date                                                                                  gl_date,
        DECODE (ra.application_type, 'CASH', cr.doc_sequence_id,
                                     'CM',   ctcm.doc_sequence_id)                                  doc_seqid,
        DECODE (ra.application_type, 'CASH', cr.doc_sequence_value,
                                     'CM',   ctcm.doc_sequence_value)                               doc_num,
	cr.currency_code									    currency,
        DECODE (to_NUMBER(l1.lookup_code),   1, psa_rct_dist.mf_cash_ccid,
                                             2, DECODE(ra.application_type, 'CM', psa_mfar_utils.get_rec_ccid (ra.applied_customer_trx_id, ra.customer_trx_id), crh.account_code_combINation_id),
                                             3, ar_trx_dist.code_combINation_id,
                                             4, ar_trx_dist.code_combINation_id,
                                             5, psa_rct_dist.discount_ccid,
                                             6, ra.earned_discount_ccid,
                                             7, ra.code_combINation_id,
                                             8, psa_trx_dist.mf_receivables_ccid,
                                             9, psa_rct_dist.ue_discount_ccid,
                                            10, ra.unearned_discount_ccid,
                                            11, ra.code_combINation_id,
                                            12, psa_trx_dist.mf_receivables_ccid)                    ccid,
        DECODE (ra.application_type, 'CM', get_entered_dr_crm (l1.lookup_code, psa_rct_dist.amount),
                                           get_entered_dr_rct (l1.lookup_code, psa_rct_dist.amount,
                                                               psa_rct_dist.discount_amount,
                                                               psa_rct_dist.ue_discount_amount))     entered_dr,
        DECODE (ra.application_type, 'CM', get_entered_cr_crm (l1.lookup_code, psa_rct_dist.amount),
                                           get_entered_cr_rct (l1.lookup_code, psa_rct_dist.amount,
                                                               psa_rct_dist.discount_amount,
                                                               psa_rct_dist.ue_discount_amount))     entered_cr,
        DECODE (ra.application_type, 'CM', get_entered_dr_crm (l1.lookup_code, psa_rct_dist.amount),
                                           get_entered_dr_rct (l1.lookup_code, psa_rct_dist.amount,
                                                               psa_rct_dist.discount_amount,
                                                               psa_rct_dist.ue_discount_amount))     accounted_dr,
        DECODE (ra.application_type, 'CM', get_entered_cr_crm (l1.lookup_code, psa_rct_dist.amount),
                                           get_entered_cr_rct (l1.lookup_code, psa_rct_dist.amount,
                                                               psa_rct_dist.discount_amount,
                                                               psa_rct_dist.ue_discount_amount))     accounted_cr,
	'AR ' || TO_CHAR(l_pst_ctrl_id)                           				     ref1,
        SUBSTRB (DECODE (l1.lookup_code, '1', DECODE (ra.application_type, 'CM', 'MFAR'|| DECODE (sign (ra.amount_applied),-1, '-UNAPP','') || ' Receivable account for credit memo' || ctcm.trx_NUMBER || '.',
                                                                                 'MFAR'|| DECODE (sign (ra.amount_applied),-1, '-UNAPP','') || DECODE(crh.status,'CLEARED', ' Cash Account for ', 'REMITTED', ' Remittance Account for ')),
                                         '2', DECODE (ra.application_type, 'CM',
						'MFAR'|| DECODE (sign (ra.amount_applied),-1, '-UNAPP','') || ' Reversal of Receivable account for credit memo '|| ctcm.trx_NUMBER || '.',
                                                'MFAR'|| DECODE (sign (ra.amount_applied),-1, '-UNAPP','') || DECODE(crh.status, 'CLEARED', ' Reversal of Cash Account for ' , 'REMITTED', ' Reversal of Remittance Account for ')),
                                         '3', 'MFAR'  || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' Reversal of Revenue Account for ',
                                         '4', 'MFAR'  || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' Receipt ',
                                         '5', 'MFAR'  || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Correct earn-disc): ',
                                         '6', 'MFAR'  || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Reverse core earn-disc):' ,
                                         '7', 'MFAR'  || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Reverse core rec):' ,
                                         '8', 'MFAR'  || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Correct rec):' ,
                                         '9',  'MFAR' || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Correct unearn-disc):',
                                         '10', 'MFAR' || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Reverse core unearn-disc):',
                                         '11', 'MFAR' || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Reverse core rec):',
                                         '12', 'MFAR' || DECODE (sign(ra.amount_applied),-1, '-UNAPP','') || ' (Correct rec):' )
                                                      || DECODE (l_summary_flag, 'Y', NULL, DECODE(ra.application_type,
                                                                                                        /* Cash Receipt application */
                                                                                                         'CASH', ' '|| cr.receipt_NUMBER || l_app_applied ||
                                                                                                                                           DECODE(ctt.type,      'CB',  l_class_cb,
                                                                                                                                                                 'CM',  l_class_cm,
                                                                                                                                                                 'DEP', l_class_dep,
                                                                                                                                                                 'DM',  l_class_dm,
                                                                                                                                                                 'GUAR',l_class_guar,
                                                                                                                                                                 'INV', l_class_inv,NULL) || ' ' || ctinv.trx_NUMBER || l_post_general)),1,240) ref10,
        TO_CHAR(l_pst_ctrl_id)                                                                  ref21,
        DECODE (ra.application_type, 'CASH',TO_CHAR(cr.cash_receipt_id), -- || 'C' || TO_CHAR(ra.receivable_application_id),
                                     'CM',  TO_CHAR(ra.receivable_application_id))              ref22,
        psa_rct_dist.CUST_TRX_LINE_GL_DIST_ID                                                   ref23,
        DECODE (ra.application_type, 'CASH', cr.receipt_NUMBER,
                                     'CM', ctcm.trx_NUMBER)                                     ref24,
        ctinv.trx_NUMBER                                                                        ref25,
        ctt.type                                                                                ref26,
        DECODE (ra.application_type, 'CASH', TO_CHAR(cr.pay_from_customer),
                                     'CM',   TO_CHAR(ctcm.bill_to_customer_id))                 ref27,
        DECODE (ra.application_type, 'CASH', DECODE(ra.amount_applied_from, NULL,'TRADE','CCURR'),
                                     'CM',   'CMAPP')                                           ref28,
        DECODE(ra.application_type,  'CASH', DECODE (ra.amount_applied_from, NULL,'TRADE_' ||ar_trx_dist.account_class, 'CCURR_' ||ar_trx_dist.account_class),
                                     'CM',   'CMAPP_'||ar_trx_dist.account_class)               ref29,
        DECODE(ra.application_type,  'CASH', 'PSA_RCT_DIST',
				     'CM',   'RA_CUST_TRX_LINE_GL_DIST')                        ref30
        FROM
              ar_receivable_applications      ra,
              ar_cash_receipts                cr,
              ra_customer_trx                 ctcm,
              ra_customer_trx                 ctinv,
              ra_cust_trx_types               ctt,
              ar_cash_receipt_history         crh,
              psa_mf_rct_dist_all             psa_rct_dist,
              psa_mf_trx_dist_all             psa_trx_dist,
	      ra_cust_trx_line_gl_dist	      ar_trx_dist,
              psa_lookup_codes                l1
        WHERE
              psa_rct_dist.receivable_application_id = p_receivable_application_id
        AND   psa_rct_dist.ue_discount_ccid IS NULL
        AND   psa_rct_dist.receivable_application_id = ra.receivable_application_id
        AND   psa_trx_dist.cust_trx_line_gl_dist_id  = psa_rct_dist.cust_trx_line_gl_dist_id
	AND   ar_trx_dist.cust_trx_line_gl_dist_id  = psa_trx_dist.cust_trx_line_gl_dist_id
	AND   ar_trx_dist.cust_trx_line_gl_dist_id  = psa_rct_dist.cust_trx_line_gl_dist_id
              /* For MFAR we consider only thr APP rows */
        AND   ra.status 			    = 'APP'
        AND   ra.cash_receipt_id                    = cr.cash_receipt_id(+)
        AND   ra.customer_trx_id                    = ctcm.customer_trx_id(+)
        AND   ra.applied_customer_trx_id            = ctinv.customer_trx_id(+)
        AND   ctinv.cust_trx_type_id                = ctt.cust_trx_type_id(+)
        AND   ra.cash_receipt_id                    = crh.cash_receipt_id(+)
        AND   l1.lookup_type                        = 'PSA_CARTESIAN_JOIN'
        AND   l1.lookup_code IN ('1','4','5','7','8','9','12',
                                 decode(l_rct_post_det_flag, 'N', -1, 2),
				 -- decode(l_rct_post_det_flag, 'N', -1, 3),
				 decode(l_rct_post_det_flag, 'N', -1, 6),
                                 decode(l_rct_post_det_flag, 'N', -1, 10),
                                 decode(l_rct_post_det_flag, 'N', -1, 11))
        AND   DECODE (ceil(to_NUMBER(l1.lookup_code)/4), 1, nvl(psa_rct_dist.amount,0),
                                                         2, nvl(psa_rct_dist.discount_amount,0),
                                                         3, nvl(psa_rct_dist.ue_discount_amount,0), 0) <> 0
        AND   l1.lookup_code                       <= DECODE(ra.application_type, 'CM', 2, l1.lookup_code)
        AND   ra.posting_control_id                 = l_pst_ctrl_id
        AND   nvl(psa_rct_dist.posting_control_id, -3) = -3
        AND   crh.status IN                          ('CLEARED','REMITTED')
        AND   crh.first_posted_record_flag          = 'Y';

	CURSOR c_fv_balance_check (c_sob_id NUMBER, c_group_id NUMBER, c_rcv_app_id NUMBER) IS
		SELECT to_number(substr(gl.reference22, 1, instr(gl.reference22, 'C')-1)) cash_receipt_id,
		       sum(accounted_dr) sum_acctd_dr,
		       sum(accounted_cr) sum_acctd_cr
		  FROM gl_interface gl
                 WHERE gl.user_je_source_name = 'Receivables'
                   AND gl.set_of_books_id     = c_sob_id
                   AND gl.group_id            = c_group_id
		   AND substr(gl.reference29, 7) IN ('CASH', 'REC')
		   AND gl.reference10 NOT LIKE 'MFAR%'
		   AND to_number(substr(gl.reference22, 1, instr(gl.reference22, 'C')-1)) IN
		        (select cash_receipt_id from ar_receivable_applications where receivable_application_id = c_rcv_app_id)
		 GROUP BY to_number(substr(gl.reference22, 1, instr(gl.reference22, 'C')-1))
		HAVING sum(accounted_dr) =  sum(accounted_cr);

--        l_run_num           NUMBER(15);

	l_fv_balance_check  c_fv_balance_check%rowtype;
        -- ========================= FND LOG ===========================
        l_full_path VARCHAR2(100) := g_path || 'Mfar_rcpt_to_gl_CB';
        -- ========================= FND LOG ===========================
BEGIN

  retcode := 'F';

  l_gl_start_date        := p_gl_date_from;
  l_post_through_date    := p_gl_date_to;
  l_summary_flag         := p_summary_flag;
  l_sob_id               := p_set_of_books_id;

  FOR I IN Cur_MFAR_rct_app_id
  LOOP

      BEGIN
          IF NOT (PSA_MFAR_RECEIPTS.create_distributions
				(errbuf              => l_errbuf,
                                 retcode             => l_retcode,
                                 p_receivable_app_id => I.receivable_application_id,
                                 p_set_of_books_id   => l_sob_id,
                                 p_run_id            => l_run_num,
                                 p_error_message     => l_error_message)) THEN

                  IF l_error_message IS NOT NULL OR l_retcode = 'F' THEN
                     Raise invalid_distribution;
                  END IF;
          END IF;

      EXCEPTION
       WHEN INVALID_DISTRIBUTION THEN
         -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_excep_level,l_full_path,
	                               ' PSA_XFR_TO_GL_PKG.Mfar_rct_to_gl: Unable to create Multi-Fund distributions for Receivable Application ID: ' || I.receivable_application_id);
         psa_utils.debug_other_string(g_excep_level,l_full_path,' Error Message : ' || l_error_message);
         -- ========================= FND LOG ===========================
         retcode  := 'F';

       WHEN OTHERS THEN
        -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_excep_level,l_full_path,
	                              ' PSA_XFR_TO_GL_PKG.Mfar_rct_to_gl: Unable to create Multi-Fund distributions for Receivable Application ID: ' || I.receivable_application_id);
        psa_utils.debug_other_string(g_excep_level,l_full_path,' Error Message : ' || sqlerrm);
        psa_utils.debug_unexpected_msg(l_full_path);
        -- ========================= FND LOG ===========================
        retcode := 'F';

      END;
/* -- 4178626
      IF l_post_det_acct_flag = 'N' THEN

	 OPEN c_fv_balance_check (l_sob_id, l_pst_ctrl_id, I.receivable_application_id);
        FETCH c_fv_balance_check
         INTO l_fv_balance_check;
        CLOSE c_fv_balance_check;

        IF (l_fv_balance_check.sum_acctd_dr IS NOT NULL AND
	    l_fv_balance_check.sum_acctd_cr IS NOT NULL   ) THEN

		l_rct_post_det_flag := 'N';

		DELETE FROM gl_interface gl
                 WHERE gl.user_je_source_name = 'Receivables'
                   AND gl.set_of_books_id     = l_sob_id
                   AND gl.group_id            = l_pst_ctrl_id
		   AND substr(gl.reference29, 7) IN ('CASH', 'REC')
		   AND gl.reference10 NOT LIKE 'MFAR%'
		   AND to_number(substr(gl.reference22, 1, instr(gl.reference22, 'C')-1)) = l_fv_balance_check.cash_receipt_id;
	ELSE
		l_rct_post_det_flag := 'Y';
	END IF;
      END IF;
-- 4178626 */
      FOR J IN Cur_mfar_rct_lines (I.receivable_application_id)
      LOOP

	  DELETE FROM gl_interface gl
           WHERE gl.user_je_source_name = 'Receivables'
             AND gl.set_of_books_id     = l_sob_id
             AND gl.group_id            = l_pst_ctrl_id
	     AND gl.reference29	        = 'TRADE_APP_INV_GL_LINE'
	     AND gl.reference30	        = 'AR_CASH_BASIS_DISTRIBUTIONS'
	     AND gl.reference10 NOT LIKE '%MFAR%'
	     AND to_number(gl.reference22) =
			(select cash_receipt_id
			   from ar_receivable_applications
			  where receivable_application_id = I.receivable_application_id);

          INSERT INTO gl_interface
	        (created_by,
	         date_created,
	         status,
	         actual_flag,
	         group_id,
	         set_of_books_id,
	         user_je_source_name,
	         user_je_category_name,
	         accounting_date,
	         subledger_doc_sequence_id,
	         subledger_doc_sequence_value,
	         currency_code,
	         code_combINation_id,
	         entered_dr,
	         entered_cr,
	         accounted_dr,
	         accounted_cr,
	         reference1,
	         reference10,
	         reference21,
	         reference22,
	         reference23,
	         reference24,
	         reference25,
	         reference26,
	         reference27,
	         reference28,
	         reference29,
	         reference30,
	         ussgl_transaction_code)
          VALUES
                (l_user_id,
                 trunc(sysdate),
                 l_status,
                 l_actual_flag,
                 l_pst_ctrl_id,
                 l_sob_id,
                 l_source,
                 J.category,
                 J.gl_date,
	         J.doc_seqid,
	         J.doc_num,
	         J.currency,
	         J.ccid,
	         J.entered_dr,
	         J.entered_cr,
	         J.accounted_dr,
	         J.accounted_cr,
	         J.ref1,
	         J.ref10,
	         J.ref21,
	         J.ref22,
	         J.ref23,
	         J.ref24,
	         J.ref25,
	         J.ref26,
	         J.ref27,
	         J.ref28,
	         J.ref29,
	         J.ref30,
	         J.ussgl);

      END LOOP;
  END LOOP;

  UPDATE psa_mf_rct_dist_all pda
     SET pda.posting_control_id = l_pst_ctrl_id
   WHERE pda.receivable_application_id IN
        (SELECT receivable_application_id
	   FROM ar_receivable_applications ara
          WHERE ara.posting_control_id = l_pst_ctrl_id);

  retcode := 'S';

EXCEPTION
    WHEN OTHERS THEN
        -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_excep_level,l_full_path,
	                              ' PSA_XFR_TO_GL_PKG.Mfar_rct_to_gl: Exception : OTHERS ');
        psa_utils.debug_other_string(g_excep_level,l_full_path,' Error Message : ' || sqlerrm);
        psa_utils.debug_unexpected_msg(l_full_path);
        -- ========================= FND LOG ===========================
	retcode := 'F';

END Mfar_rcpt_to_gl_CB;

/*###################################### MISC_RCT_TO_GL_CB ###########################################*/

 PROCEDURE Misc_rct_to_gl_CB
			  (errbuf               OUT NOCOPY VARCHAR2,
                           retcode              OUT NOCOPY VARCHAR2,
                           p_set_of_books_id    IN  NUMBER,
                           p_gl_date_from       IN  VARCHAR2,
                           p_gl_date_to         IN  VARCHAR2,
                           p_gl_posted_date     IN  VARCHAR2)
 IS

   CURSOR c_crh_post
   IS
          SELECT cash_receipt_history_id FROM ar_cash_receipt_history_all
	  WHERE  posting_control_id   = l_pst_ctrl_id
          AND    cash_receipt_history_id NOT IN
	         (SELECT cash_receipt_history_id FROM psa_misc_posting);

   CURSOR c_create_dist
   IS
          SELECT cr.cash_receipt_id FROM ar_cash_receipts_all cr, ar_cash_receipt_history_all crh
	  WHERE  cr.cash_receipt_id = crh.cash_receipt_id
--	  AND    crh.status         = 'CLEARED'
	  AND    fnd_date.date_to_canonical (crh.gl_date) BETWEEN  fnd_date.date_to_canonical (TO_DATE (l_gl_start_date     ||' 00:00:00','YYYY/MM/DD HH24:MI:SS'))
                                                          AND      fnd_date.date_to_canonical (TO_DATE (l_post_through_date ||' 00:00:00','YYYY/MM/DD HH24:MI:SS'));

   CURSOR Cur_MFAR_mrct_lines
   IS
          SELECT
           mfd.gl_date                                             gl_date,
           cr.doc_sequence_id                                      doc_seqid,
           cr.doc_sequence_value                                   doc_num,
           ard.currency_code                                       currency,
     	   decode(to_number(l1.lookup_code),
                                 1, mfd.cash_ccid, 2, ard.code_combination_id)
                                                                   ccid,
           decode(to_number(l1.lookup_code), 1, mcd.amount, 2, Null)  		 		 entered_dr,
           decode(to_number(l1.lookup_code), 1, Null, 2, mcd.amount)  		 		 entered_cr,
           decode(to_number(l1.lookup_code), 1, mcd.acctd_amount, 2, Null)  		 	 accounted_dr,
           decode(to_number(l1.lookup_code), 1, Null, 2, mcd.acctd_amount)  		 	 accounted_cr,
           l_batch_prefix || TO_CHAR(l_pst_ctrl_id)                ref1,
           DECODE(to_number(l1.lookup_code),1, ('MFAR Misc. Receipt ' || cr.receipt_number),
                                    2,('Receipt ' || cr.receipt_number||'(MFAR)'))  ref10,
           TO_CHAR (mcd.posting_control_id)                        ref21,
           TO_CHAR (cr.cash_receipt_id)                            ref22,
           TO_CHAR (ard.line_id)			           ref23,
           cr.receipt_number                                       ref24,
           TO_CHAR (mcd.misc_cash_distribution_id)                 ref25,
           NULL                                                    ref26,
           'c1'                                                    ref27,
           'MISC'                                                  ref28,
           'MISC_' || ard.source_type                              ref29,
	   'PSA_MF_MISC_DIST_ALL'                                  ref30
	FROM
	   psa_mf_misc_dist_all           mfd,
	   psa_lookup_codes               l1,
	   ar_misc_cash_distributions_all mcd,
	   ar_distributions_all           ard,
	   ar_cash_receipts_all           cr,
	   ar_cash_receipt_history_all	  crh
       WHERE
            l1.lookup_type                  = 'PSA_CARTESIAN_JOIN'
        AND l1.lookup_code                  IN ('1','2')
	AND mfd.misc_cash_distribution_id   = mcd.misc_cash_distribution_id
        AND fnd_date.date_to_canonical (mfd.gl_date) BETWEEN fnd_date.date_to_canonical (TO_DATE (l_gl_start_date     ||' 00:00:00','YYYY/MM/DD HH24:MI:SS'))
                                                         AND fnd_date.date_to_canonical (TO_DATE (l_post_through_date ||' 00:00:00','YYYY/MM/DD HH24:MI:SS'))
        AND nvl(mfd.posting_control_id,-3) = -3
	AND crh.status                     = mfd.reference1
        AND mcd.posting_control_id         = l_pst_ctrl_id
        AND mcd.set_of_books_id            = l_sob_id
        AND mcd.cash_receipt_id            = cr.cash_receipt_id
        AND cr.cash_receipt_id             = crh.cash_receipt_id
        AND crh.posting_control_id         = l_pst_ctrl_id
        AND ((crh.first_posted_record_flag = 'Y') OR (crh.current_record_flag = 'Y' AND crh.status = 'REVERSED'))
        AND ard.source_table               = 'CRH'
        AND ard.source_id 		   = crh.cash_receipt_history_id
        AND (ard.amount_cr is null or ard.amount_cr > 0);

   PSA_MISC_GLX_FAIL EXCEPTION;
   -- ========================= FND LOG ===========================
   l_full_path VARCHAR2(100) := g_path || 'Misc_rct_to_gl_CB';
   -- ========================= FND LOG ===========================

 BEGIN

  l_gl_start_date        := p_gl_date_from;
  l_post_through_date    := p_gl_date_to;
  l_sob_id               := p_set_of_books_id;

  BEGIN

    /*
    ##  Call Create Misc Distributions program to create Multi-fund Distributions
    ##  for receipts that fall within the GL DATE parameters.
    */

    FOR I IN c_create_dist
    LOOP
       IF (I.cash_receipt_id IS NOT NULL) THEN

          IF NOT (PSA_MF_CREATE_DISTRIBUTIONS.create_distributions (errbuf             => l_errbuf,
                                                                    retcode            => l_retcode,
                                                                    p_mode             => 'R',
                                                                    p_document_id      => I.cash_receipt_id,
                                                                    p_set_of_books_id  => l_sob_id,
                                                                    run_num            => l_run_num,
                                                                    p_error_message    => l_error_message,
                                                                    p_report_only      => 'N')) THEN


                  IF l_error_message IS NOT NULL OR l_retcode = 'F' THEN
                     -- ========================= FND LOG ===========================
                     psa_utils.debug_other_string(g_excep_level,l_full_path,
		                                   'Misc_rct_to_gl: Raising  invalid_distribution');
                     -- ========================= FND LOG ===========================
                    Raise invalid_distribution;
                  END IF;

          END IF;
       END IF;

    END LOOP;

  EXCEPTION
    WHEN INVALID_DISTRIBUTION THEN
     -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_excep_level,l_full_path,
                                      '     p_error_message  --> ' || l_error_message);
     -- ========================= FND LOG ===========================
     retcode  := 'F';

    WHEN OTHERS THEN
      -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_excep_level,l_full_path,
                                       'EXCEPTION - OTHERS raised during PSA_MF_CREATE_DISTRIBUTIONS.create_distributions ' || 'in PSA_TRANSFER_TO_GL_PKG.Misc_rct_to_gl ');
      psa_utils.debug_unexpected_msg(l_full_path);
      -- ========================= FND LOG ===========================
      errbuf  := 2;
      retcode := 'F';

  END;

  /*
  ## Insert into GL_INTERFACE Select from psa_mf_misc_dist_all
  */

   FOR J IN Cur_MFAR_mrct_lines
   LOOP

     /*
     ## For each misc_cash_distribution_id the record will be inserted.
     */

      INSERT INTO gl_interface
	        (created_by,
	         date_created,
	         status,
	         actual_flag,
	         group_id,
	         set_of_books_id,
	         user_je_source_name,
	         user_je_category_name,
	         accounting_date,
	         subledger_doc_sequence_id,
	         subledger_doc_sequence_value,
	         currency_code,
	         code_combination_id,
	         entered_dr,
	         entered_cr,
	         accounted_dr,
	         accounted_cr,
	         reference1,
	         reference10,
	         reference21,
	         reference22,
	         reference23,
	         reference24,
	         reference25,
	         reference26,
	         reference27,
	         reference28,
	         reference29,
	         reference30)
        VALUES  (l_user_id,
                 trunc(sysdate),
                 l_status,
                 l_actual_flag,
                 l_pst_ctrl_id,
                 l_sob_id,
                 l_source,
                 l_misc_cat_name,
                 J.gl_date,
	         J.doc_seqid,
	         J.doc_num,
	         J.currency,
	         J.ccid,
	         J.entered_dr,
	         J.entered_cr,
	         J.accounted_dr,
	         J.accounted_cr,
	         J.ref1,
	         J.ref10,
	         J.ref21,
	         J.ref22,
	         J.ref23,
	         J.ref24,
	         J.ref25,
	         J.ref26,
	         J.ref27,
	         J.ref28,
	         J.ref29,
	         J.ref30);

   END LOOP;

 /*
 ## Insert a record into psa_misc_posting to keep track of
 ## each reversing record of AR_CASH_RECEIPT_HISTORY, that we insert into GL_INTERFACE
 */

  FOR J IN c_crh_post
  LOOP
      INSERT INTO psa_misc_posting (cash_receipt_history_id,   posting_control_id)
                            VALUES (J.cash_receipt_history_id, l_pst_ctrl_id);

  END LOOP;

  UPDATE psa_mf_misc_dist_all
  SET    posting_control_id = l_pst_ctrl_id
  WHERE  misc_cash_distribution_id IN
         (SELECT misc_cash_distribution_id FROM ar_misc_cash_distributions_all
          WHERE  posting_control_id = l_pst_ctrl_id);

 EXCEPTION
   WHEN OTHERS THEN
      -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_excep_level,l_full_path,
                                    'EXCEPTION - OTHERS raised during in PSA_TRANSFER_TO_GL_PKG.Misc_rct_to_gl - rolling back ');
      psa_utils.debug_other_string(g_excep_level,l_full_path,   sqlcode || sqlerrm);
      psa_utils.debug_unexpected_msg(l_full_path);
      -- ========================= FND LOG ===========================
      errbuf  := 2;
      retcode := 'F';

 END  Misc_rct_to_gl_CB;

 /* ########################################## END OF PSA_TRSNAFER_TO_GL_PKG ################################# */

END psa_xfr_to_gl_pkg;

/
