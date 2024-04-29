--------------------------------------------------------
--  DDL for Package Body PSA_MF_CREATE_DISTRIBUTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_MF_CREATE_DISTRIBUTIONS" AS
/* $Header: PSAMFCRB.pls 120.15 2006/09/13 12:32:39 agovil ship $ */

  /*
  ## A new parameter p_mode is being added to branch the processing
  ## based on Activity - Transaction / Miscellaneous Receipt.
  ## If Activity is (T)ransaction, Multifund Transaction, Cash Receipts and Adjustments
  ## will be processed
  ## If Activity is (M)iscellanous Receipt, Misc. receipts will be processed
  ## If Activity is (A)ll, all the Multifund distributions will be processed.
  */

  --===========================FND_LOG.START=====================================
  g_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
  g_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
  g_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
  g_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
  g_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
  g_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
  g_path        VARCHAR2(50)  := 'PSA.PLSQL.PSAMFCRB.PSA_MF_CREATE_DISTRIBUTIONS.';
  --===========================FND_LOG.END=======================================

  FUNCTION create_distributions (
                                 errbuf           OUT NOCOPY  VARCHAR2,
                                 retcode          OUT NOCOPY  VARCHAR2,
                                 p_mode            IN         VARCHAR2,
                                 p_document_id     IN         NUMBER,
                                 p_set_of_books_id IN         NUMBER,
                                 run_num          OUT NOCOPY  NUMBER,
                                 p_error_message  OUT NOCOPY  VARCHAR2,
                                 p_report_only     IN         VARCHAR2 DEFAULT 'N')
  RETURN BOOLEAN
  IS

      CURSOR a (cust_trx_id in number)
      IS
	 SELECT trx.customer_trx_id
         FROM   ra_customer_trx trx, psa_trx_types_all psa
         WHERE  trx.customer_trx_id   = nvl(cust_trx_id,trx.customer_trx_id)
         AND    trx.cust_trx_type_id  = psa.psa_trx_type_id
         AND    set_of_books_id       = p_set_of_books_id;


     CURSOR b (cust_trx_id in number)
     IS
       SELECT b.receivable_application_id
       FROM  ar_receivable_applications b
       WHERE b.applied_customer_trx_id = cust_trx_id ;

     CURSOR c (cust_trx_id in number)
     IS
       SELECT c.adjustment_id
       FROM   ar_Adjustments c
       WHERE  c.customer_trx_id = cust_trx_id;

     CURSOR d (c_cash_receipt_id IN NUMBER)
     IS
       SELECT cash_receipt_id,receipt_method_id,receivables_trx_id
       FROM   ar_cash_receipts arc, psa_receivables_trx_all psa
       WHERE  arc.cash_receipt_id     = NVL(c_cash_receipt_id, arc.cash_receipt_id)
       AND    arc.receivables_trx_id  = psa.psa_receivables_trx_id
       AND    arc.set_of_books_id     = p_set_of_books_id;

     l_mfar_implemented     VARCHAR2(1);
     l_org_id               NUMBER;
     cash_receipt_rec       d%ROWTYPE;
     l_set_of_books_id      NUMBER;

     MFAR_DIST_EXCEP       EXCEPTION;
     MFAR_NOT_IMPLEMENTED  EXCEPTION;

     -- ========================= FND LOG ===========================
        l_full_path VARCHAR2(100) := g_path || 'create_distributions';
     -- ========================= FND LOG ===========================

  BEGIN

     SAVEPOINT PSA_PSAMFCRB;

     l_set_of_books_id := p_set_of_books_id;
     FND_PROFILE.GET ('ORG_ID', l_org_id);

     -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' Inside Create_distribution ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' ========== ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_mode            --> ' || p_mode);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_document_id     --> ' || p_document_id);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_set_of_books_id --> ' || p_set_of_books_id);
     psa_utils.debug_other_string(g_state_level,l_full_path,' l_org_id          --> ' || l_org_id);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_report_only     --> ' || p_report_only );
     psa_utils.debug_other_string(g_state_level,l_full_path,'   ');
     -- ========================= FND LOG ===========================

     /* checking whether MFAR is available */
     IF (NOT (PSA_IMPLEMENTATION.GET (l_org_id, 'MFAR', l_mfar_implemented)) OR
             (l_mfar_implemented <> 'Y')) THEN
          -- ========================= FND LOG ===========================
             psa_utils.debug_other_string(g_error_level,l_full_path,
                                         ' MFAR not implemented !');
          -- ========================= FND LOG ===========================
         RAISE MFAR_NOT_IMPLEMENTED ;
     ELSE
          -- ========================= FND LOG ===========================
             psa_utils.debug_other_string(g_state_level,l_full_path,' MFAR is implemented ');
          -- ========================= FND LOG ===========================
     END IF;


     /* getting the sequence number */
       BEGIN
         SELECT psa_mf_error_log_s.NEXTVAL INTO run_num
         FROM sys.dual;

         -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
                                       ' Sequence number -> ' || run_num);
         -- ========================= FND LOG ===========================

       EXCEPTION
         WHEN OTHERS THEN
           FND_MESSAGE.SET_NAME ('AR', 'GENERIC_MESSAGE');
           FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',
                                 'PSA_MF_CREATE_DISTRIBUTIONS - '
                                 || 'Cannot create run number');
           -- ========================= FND LOG ===========================
           psa_utils.debug_other_msg(g_excep_level,l_full_path,FALSE);
           -- ========================= FND LOG ===========================
           p_error_message := FND_MESSAGE.GET;
           -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_excep_level,l_full_path,
                                          ' PSAMFCRB: ' || p_error_message);
           psa_utils.debug_other_string(g_excep_level,l_full_path,
                                          ' PSAMFCRB: ' || sqlcode || sqlerrm);
           -- ========================= FND LOG ===========================
           RETURN FALSE;
       END;

       IF p_mode IN ('A','T') THEN
         -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
                                         ' p_mode in A or T');
         -- ========================= FND LOG ===========================

          FOR a_row IN a(p_document_id)
          LOOP
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,
                                          ' Customer trx id --> ' || a_row.customer_trx_id);
              psa_utils.debug_other_string(g_state_level,l_full_path,
                                          ' CAlling PSA_MFAR_VAL_PKG.ar_mfar_validate_check');
           -- ========================= FND LOG ===========================

            IF PSA_MFAR_VAL_PKG.ar_mfar_validate_check
               (a_row.customer_trx_id,'TRX', p_set_of_books_id) = 'Y' THEN

               -- ========================= FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path,
                                              ' calling PSA_MFAR_TRANSACTIONS.create_distributions ');
               -- ========================= FND LOG ===========================

               IF NOT (PSA_MFAR_TRANSACTIONS.create_distributions (errbuf            => errbuf,
                                                                   retcode           => retcode,
                                                                   p_cust_trx_id     => a_row.customer_trx_id,
                                                                   p_set_of_books_id => p_set_of_books_id,
                                                                   p_run_id          => run_num,
                                                                   p_error_message   => p_error_message)) THEN

                   -- ========================= FND LOG ===========================
                   psa_utils.debug_other_string(g_error_level,l_full_path,
                                                  ' PSA_MFAR_TRANSACTIONS.create_distributions --> FALSE ');
                   -- ========================= FND LOG ===========================

                  IF p_error_message IS NOT NULL OR retcode = 'F' THEN
                     -- ========================= FND LOG ===========================
                     psa_utils.debug_other_string(g_error_level,l_full_path,
                                                    ' Error Message --> '
                                                           || p_error_message);
                     -- ========================= FND LOG ===========================

                     IF NVL(p_report_only,'N') = 'N' THEN
                        -- ========================= FND LOG ===========================
                        psa_utils.debug_other_string(g_error_level,l_full_path,
                                                       ' p_report_only --> N : ' ||
                                                       ' This is not for reporting purpose so end processing. ');
                        -- ========================= FND LOG ===========================
                        Raise MFAR_DIST_EXCEP ;
                     END IF;
                  END IF;

               ELSE
                  -- ========================= FND LOG ===========================
                  psa_utils.debug_other_string(g_state_level,l_full_path,
                                                ' PSA_MFAR_TRANSACTIONS.create_distributions --> ' || a_row.customer_trx_id);
                  -- ========================= FND LOG ===========================
               END IF;

                /* RECEIPTS */
                FOR b_row IN b(a_row.customer_trx_id)
                LOOP
                 -- ========================= FND LOG ===========================
                 psa_utils.debug_other_string(g_state_level,l_full_path,
                                                ' calling PSA_MFAR_RECEIPTS.create_distributions '
                                                   || ' -- ' || b_row.receivable_application_id);
                 -- ========================= FND LOG ===========================

                 IF NOT (PSA_MFAR_RECEIPTS.create_distributions (errbuf               => errbuf,
                                                                 retcode              => retcode,
                                                                 p_receivable_app_id  => b_row.receivable_application_id,
                                                                 p_set_of_books_id    => p_set_of_books_id,
                                                                 p_run_id             => run_num,
                                                                 p_error_message      => p_error_message)) THEN

                    -- ========================= FND LOG ===========================
                       psa_utils.debug_other_string(g_state_level,l_full_path,
                                                 ' PSA_MFAR_RECEIPTS.create_distributions --> FALSE ');
                    -- ========================= FND LOG ===========================

                    IF p_error_message IS NOT NULL OR retcode = 'F' THEN
                       -- ========================= FND LOG ===========================
                          psa_utils.debug_other_string(g_excep_level,l_full_path,
                                                          ' Error Message --> '|| p_error_message);
                       -- ========================= FND LOG ===========================

                       IF NVL(p_report_only,'N') = 'N' THEN
                          -- ========================= FND LOG ===========================
                             psa_utils.debug_other_string(g_excep_level,l_full_path,
                                                            ' p_report_only --> : This is not for reporting purpose so end processing. ');
                          -- ========================= FND LOG ===========================
                          Raise MFAR_DIST_EXCEP ;
                       END IF;
                    END IF;

                  ELSE
                    -- ========================= FND LOG ===========================
                       psa_utils.debug_other_string(g_state_level,l_full_path,
                                                 ' PSA_MFAR_RECEIPTS.create_distributions TRUE --> ' || b_row.receivable_application_id);
                    -- ========================= FND LOG ===========================

                  END IF;

                END LOOP;

                /* ADJUSTMENTS */
                FOR c_row IN c(a_row.customer_trx_id)
                LOOP

                 -- ========================= FND LOG ===========================
                 psa_utils.debug_other_string(g_state_level,l_full_path,
                                                ' calling PSA_MFAR_ADJUSTMENTS.create_distributions '
                                                    || ' -- ' || c_row.adjustment_id );
                 -- ========================= FND LOG ===========================

                  IF NOT (PSA_MFAR_ADJUSTMENTS.create_distributions (
                                                             errbuf               => errbuf,
                                                             retcode              => retcode,
                                                             p_adjustment_id      => c_row.adjustment_id,
                                                             p_set_of_books_id    => p_set_of_books_id,
                                                             p_run_id             => run_num,
                                                             p_error_message      => p_error_message)) THEN

                   -- ========================= FND LOG ===========================
                   psa_utils.debug_other_string(g_error_level,l_full_path,
                                                  ' PSA_MFAR_TRANSACTIONS.create_distributions --> FALSE ');
                   -- ========================= FND LOG ===========================

                    IF p_error_message IS NOT NULL OR retcode = 'F' THEN
                         -- ========================= FND LOG ===========================
                         psa_utils.debug_other_string(g_excep_level,l_full_path,
                                                        ' Error Message --> '
                                                        || p_error_message);
                         -- ========================= FND LOG ===========================

                       IF NVL(p_report_only,'N') = 'N' THEN
                          -- ========================= FND LOG ===========================
                          psa_utils.debug_other_string(g_excep_level,l_full_path,
                                                         ' p_report_only --> N : This is not for reporting purpose so end processing. ');
                          -- ========================= FND LOG ===========================
                          Raise MFAR_DIST_EXCEP ;
                       END IF;

                    END IF;

                  ELSE
                     -- ========================= FND LOG ===========================
                     psa_utils.debug_other_string(g_state_level,l_full_path,
                                                    ' PSA_MFAR_ADJUSTMENTS.create_distributions TRUE --> ' || c_row.adjustment_id);
                     -- ========================= FND LOG ===========================
                  END IF;

                END LOOP;
           END IF; -- AR_MFAR_VALIDATE_CHECK
         END LOOP;

      END IF;


      IF p_mode IN ('A','R') THEN
         -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' p_mode in A or R');
         -- ========================= FND LOG ===========================

         OPEN d(p_document_id);
         LOOP

           FETCH d INTO cash_receipt_rec;
           EXIT WHEN d%notfound;

           -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
                                          ' calling PSA_MF_MISC_PKG.generate_distributions '
                                             || ' -- ' || cash_receipt_rec.cash_receipt_id);
           -- ========================= FND LOG ===========================

           IF NOT (PSA_MF_MISC_PKG.generate_distributions (
                                                            errbuf               => errbuf,
                                                            retcode              => retcode,
                                                            p_cash_receipt_id    => cash_receipt_rec.cash_receipt_id,
                                                            p_set_of_books_id    => l_set_of_books_id,
                                                            p_run_id             => run_num,
                                                            p_error_message      => p_error_message,
                                                            p_report_only        => p_report_only)) THEN

                   -- ========================= FND LOG ===========================
                      psa_utils.debug_other_string(g_error_level,l_full_path,
                                                  ' PSA_MF_MISC_PKG.generate_distributions --> FALSE ');
                   -- ========================= FND LOG ===========================

                  IF p_error_message IS NOT NULL OR retcode = 'F' THEN
                     -- ========================= FND LOG ===========================
                     psa_utils.debug_other_string(g_excep_level,l_full_path,
                                                    ' Error Message --> '|| p_error_message);
                     -- ========================= FND LOG ===========================

                     IF NVL(p_report_only,'N') = 'N' THEN
                        -- ========================= FND LOG ===========================
                        psa_utils.debug_other_string(g_excep_level,l_full_path,
                                        ' p_report_only --> N : This is not for reporting purpose so end processing. ');
                        -- ========================= FND LOG ===========================
                        Raise MFAR_DIST_EXCEP ;
                     END IF;
                  END IF;
           ELSE
                  -- ========================= FND LOG ===========================
                  psa_utils.debug_other_string(g_state_level,l_full_path,
                                                 ' PSA_MF_MISC_PKG.generate_distributions TRUE --> '
                                                 || cash_receipt_rec.cash_receipt_id);
                  -- ========================= FND LOG ===========================
           END IF;

        END LOOP;
        CLOSE d;
     END IF;

  IF NVL(p_report_only,'N') = 'Y' THEN
     retcode := 'F';
      -- have to check with sanjay if report_only is YES then should we have to pass
      --  as F so the records will be removed from gl_interface
  END IF;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' RETURNING TRUE ');
  -- ========================= FND LOG ===========================

  RETURN TRUE;

  EXCEPTION
     WHEN MFAR_DIST_EXCEP THEN
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_excep_level,l_full_path,
                                'EXCEPTION - MFAR_NOT_IMPLEMENTED PACKAGE - PSA_MF_CREATE_DISTRIBUTIONS.CREATE_DISTRIBUTIONS');
           psa_utils.debug_other_string(g_excep_level,l_full_path, p_error_message);
        -- ========================= FND LOG ===========================

        BEGIN
          -- ========================= FND LOG ===========================
             psa_utils.debug_other_string(g_excep_level,l_full_path, 'Rolling back to PSA_PSAMFCRB');
          -- ========================= FND LOG ===========================
          ROLLBACK TO PSA_PSAMFCRB;
        EXCEPTION
          WHEN OTHERS THEN
               -- ========================= FND LOG ===========================
                  psa_utils.debug_other_string(g_excep_level,l_full_path,
                                        'EXCEPTION - OTHERS : SAVEPOINT PSA_PSAMFCRB ERASED.');
               -- ========================= FND LOG ===========================
        END;

        retcode := 'F';
        RETURN FALSE;

     WHEN MFAR_NOT_IMPLEMENTED THEN
        fnd_message.set_name ('PSA','PSA_MF_NOT_IMPLEMENTED');
        p_error_message := fnd_message.get;
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_excep_level,l_full_path,
                                'EXCEPTION - MFAR_NOT_IMPLEMENTED PACKAGE - PSA_MF_CREATE_DISTRIBUTIONS.CREATE_DISTRIBUTIONS');
           psa_utils.debug_other_string(g_excep_level,l_full_path, p_error_message);
        -- ========================= FND LOG ===========================
        retcode := 'S';
        RETURN FALSE;

   WHEN OTHERS THEN
        p_error_message := 'EXCEPTION - OTHERS PACKAGE - PSA_MF_CREATE_DISTRIBUTIONS.CREATE_DISTRIBUTIONS - '||sqlerrm;
        -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_excep_level,l_full_path,p_error_message);
        psa_utils.debug_unexpected_msg(l_full_path);
        -- ========================= FND LOG ===========================
        retcode := 'F';
        RETURN FALSE;

  END create_distributions;


 /****************************** SUBMIT_CREATE_DISTRIBUTIONS *****************************/

  /*
  ## This procedure is a wrapper around create_distributions,
  ## because procedures with out parameters cannot be used in SRS
  */

  PROCEDURE submit_create_distributions (
                                         errbuf           OUT NOCOPY VARCHAR2,
                                         retcode          OUT NOCOPY VARCHAR2,
                                         p_mode            IN        VARCHAR2,
                                         p_document_id     IN        NUMBER,
                                         p_set_of_books_id IN        NUMBER,
                                         p_report_only     IN        VARCHAR2 DEFAULT 'N')
  IS
     run_num         NUMBER;
     p_error_message VARCHAR2(3000);
     -- ========================= FND LOG ===========================
     l_full_path VARCHAR2(100) := g_path || 'submit_create_distributions';
     -- ========================= FND LOG ===========================

  BEGIN

     -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,
                                    ' submit_create_distribution --> START ');
     -- ========================= FND LOG ===========================

     IF NOT (create_distributions (
                                   errbuf,
                                   retcode,
                                   p_mode,
                                   p_document_id ,
                                   p_set_of_books_id ,
                                   run_num,
                                   p_error_message,
                                   p_report_only)) THEN

        -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,
                                      ' submit_create_distribution --> Document id --> ' || p_document_id
                                          || ' Number --> ' || run_num);
        psa_utils.debug_other_string(g_state_level,l_full_path,
                                      ' submit_create_distribution --> Error Message : ' || p_error_message);
        psa_utils.debug_other_string(g_state_level,l_full_path,'  ');
        -- ========================= FND LOG ===========================

     END IF;

     -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,
                                    ' submit_create_distribution --> END ');
     -- ========================= FND LOG ===========================

  EXCEPTION
  WHEN OTHERS THEN
     -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_excep_level,l_full_path,'submit_create_distributions: '
                                     || 'PSAMFCRB: Exception Main in submit_create..');
     psa_utils.debug_other_string(g_excep_level,l_full_path,'submit_create_distributions: '
                                     || 'PSAMFCRB ' || sqlcode || sqlerrm);
     psa_utils.debug_unexpected_msg(l_full_path);
     -- ========================= FND LOG ===========================
  END submit_create_distributions;

FUNCTION create_distributions_rpt (
                                 errbuf           OUT NOCOPY  VARCHAR2,
                                 retcode          OUT NOCOPY  VARCHAR2,
                                 p_mode            IN         VARCHAR2,
                                 p_document_id     IN         NUMBER,
                                 p_set_of_books_id IN         NUMBER,
                                 run_num          OUT NOCOPY  NUMBER,
                                 p_error_message  OUT NOCOPY  VARCHAR2,
                                 p_report_only     IN         VARCHAR2 DEFAULT 'N',
				 p_gl_date_from    IN	      DATE,
				 p_gl_date_to      IN	      DATE )
  RETURN BOOLEAN
  IS

  CURSOR c_selected_trx IS
   SELECT distinct trx.customer_trx_id document_id
   FROM   ra_customer_trx trx,
 	  psa_trx_types_all psa,
	  ra_cust_trx_line_gl_dist gd
   WHERE  trx.cust_trx_type_id  = psa.psa_trx_type_id
   AND    trx.set_of_books_id   = p_set_of_books_id
   AND    trx.customer_trx_id   = gd.customer_trx_id
   AND    gd.gl_date between nvl(p_gl_date_from, gd.gl_date) and nvl(p_gl_date_to, gd.gl_date);

   TYPE trx_id_type IS TABLE OF ra_customer_trx.customer_trx_id%TYPE;
   l_trx_id_tab trx_id_type;

BEGIN

  OPEN c_selected_trx;

  FETCH c_selected_trx BULK COLLECT INTO l_trx_id_tab;

  CLOSE c_selected_trx;

  FOR i IN 1..l_trx_id_tab.count
  LOOP
  	IF NOT (PSA_MF_CREATE_DISTRIBUTIONS.CREATE_DISTRIBUTIONS
       	                                           ( ERRBUF            => errbuf,
               	                                     RETCODE           => retcode,
                       	                             P_MODE            => p_mode,
                               	                     P_DOCUMENT_ID     => l_trx_id_tab(i),
                                       	             P_SET_OF_BOOKS_ID => p_set_of_books_id,
                                               	     RUN_NUM           => run_num,
                                                     P_ERROR_MESSAGE   => p_error_message,
       	                                             P_REPORT_ONLY     => p_report_only)) THEN
     		return (FALSE);
  	END IF;

	IF (MOD(i, 100) = 0) THEN
		COMMIT;
	END IF;
  END LOOP;

  return (TRUE);

END create_distributions_rpt;

END psa_mf_create_distributions;

/
