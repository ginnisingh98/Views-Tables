--------------------------------------------------------
--  DDL for Package Body PSA_MF_MISC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_MF_MISC_PKG" AS
/* $Header: PSAMFMXB.pls 120.14 2006/09/13 13:39:16 agovil ship $ */


   -- declare global variables
   g_cash_receipt_id ar_cash_receipts_all.cash_receipt_id%TYPE;
   g_set_of_books_id gl_sets_of_books.set_of_books_id%TYPE;
   g_run_id NUMBER(15);
   --===========================FND_LOG.START=====================================
   g_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
   g_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
   g_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
   g_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
   g_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
   g_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
   g_path        VARCHAR2(50)  := 'PSA.PLSQL.PSAMFMXB.psa_mf_misc_pkg.';
   --===========================FND_LOG.END=======================================


   -- Local functions

   FUNCTION misc_rct_changed(p_status IN VARCHAR2 ) RETURN boolean;

   FUNCTION create_distributions   (
                                     errbuf                 OUT NOCOPY VARCHAR2,
                                     retcode                OUT NOCOPY VARCHAR2,
                                     p_mode                 IN         VARCHAR2,
				     p_error_message        OUT NOCOPY VARCHAR2,
				     x_status               IN  VARCHAR2,
				     x_cash_receipt_hist_id IN NUMBER)
   RETURN BOOLEAN;

   FUNCTION generate_distributions (
                                     errbuf             OUT NOCOPY VARCHAR2,
                                     retcode            OUT NOCOPY VARCHAR2,
                                     p_cash_receipt_id   IN        NUMBER,
                                     p_set_of_books_id   IN        NUMBER,
                                     p_run_id            IN        NUMBER,
                                     p_error_message    OUT NOCOPY VARCHAR2,
                                     p_report_only       IN        VARCHAR2 DEFAULT 'N') RETURN BOOLEAN
  IS

     CURSOR c_crh_status
     IS
	SELECT cash_receipt_history_id,status, reversal_cash_receipt_hist_id,
	       prv_stat_cash_receipt_hist_id
        FROM   ar_cash_receipt_history
        WHERE  cash_receipt_id = p_cash_receipt_id
        ORDER BY cash_receipt_history_id;

     CURSOR c_match_ccid (p_status IN varchar2)
     IS
	SELECT
             mf.misc_cash_distribution_id,
             mf.distribution_ccid,
             ar.code_combination_id
        FROM
             psa_mf_misc_dist_all mf,
             ar_misc_cash_distributions ar
        WHERE
             mf.reference1 = p_status
        AND  mf.misc_cash_distribution_id = ar.misc_cash_distribution_id
        AND  ar.cash_receipt_id = g_cash_receipt_id ;

     match_ccid_rec   c_match_ccid%ROWTYPE;
     mf_dist_count    NUMBER;
     -- ========================= FND LOG ===========================
     l_full_path VARCHAR2(100) := g_path || 'generate_distributions';
     -- ========================= FND LOG ===========================

   BEGIN

-- All processing will be checked for the Receipt history status since it is possible to
-- have multiple MFAR accounts for every core distribution.
-- When Receipt is remitted, a MFAR Remittance A/c is created.
-- When Receipt is cleared, a MFAR Cash A/c is created.


   /*
   ## Iniitialize global variables.
   */

   g_cash_receipt_id := p_cash_receipt_id;
   g_set_of_books_id := p_set_of_books_id;
   g_run_id          := p_run_id;
   retcode           := 'F';

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' Inside Generate_distributions ');
      psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS: ');
      psa_utils.debug_other_string(g_state_level,l_full_path,' =========== ');
      psa_utils.debug_other_string(g_state_level,l_full_path,' p_cash_receipt_id --> ' || p_cash_receipt_id);
      psa_utils.debug_other_string(g_state_level,l_full_path,' p_set_of_books_id --> ' || p_set_of_books_id);
      psa_utils.debug_other_string(g_state_level,l_full_path,' p_run_id          --> ' || p_run_id);
      psa_utils.debug_other_string(g_state_level,l_full_path,'   ');
   -- ========================= FND LOG ===========================


   /*
   ## Check if Distribution lines already exist in MF Tables
   */

   FOR I IN c_crh_status
   LOOP

-- Changes for Cash Mgt
-- Before checking for existence of records, the status should also be used to classify the
-- records in psa_mf_misc_dist_all

     SELECT COUNT(*) INTO mf_dist_count
     FROM   psa_mf_misc_dist_all           psa,
            ar_misc_cash_distributions ar
     WHERE  psa.misc_cash_distribution_id = ar.misc_cash_distribution_id
     AND    ar.cash_receipt_id = g_cash_receipt_id
     AND    psa.reference1 = I.status;


     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,
                                   ' Generate_distributions --> mf_dist_count ' || mf_dist_count);
     -- ========================= FND LOG ===========================


     IF (mf_dist_count > 0) THEN    -- 1 IF
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
	                              ' Generate_distributions --> mf_dist_count > 0 ');
        -- ========================= FND LOG ===========================

        /*
        ## MF lines already created
	## check if they have been modified:
        */

	IF misc_rct_changed(I.status) THEN 	 -- 2 IF

	   /*
	   ## There is count mismatch between core and MF Distribution
	   ## delete all mf distributions and re-create them.
	   */

	   IF NOT (PSA_MF_MISC_PKG.create_distributions (
	                                                 errbuf                 => errbuf,
	                                                 retcode                => retcode,
	                                                 p_mode                 => 'R',
	                                                 p_error_message        => p_error_message,
				                         x_status               => i.status,
				                         x_cash_receipt_hist_id => i.cash_receipt_history_id )) THEN  -- 3 IF

              IF p_error_message IS NOT NULL OR retcode = 'F' THEN -- 4 IF
                 -- ========================= FND LOG ===========================
                    psa_utils.debug_other_string(g_excep_level,l_full_path,
		                               ' Generate_distributions --> Error Message --> '
					       || p_error_message);
                 -- ========================= FND LOG ===========================

                     IF NVL(p_report_only,'N') = 'N' THEN  -- 5 IF
                        -- ========================= FND LOG ===========================
                           psa_utils.debug_other_string(g_excep_level,l_full_path,
			                              ' Generate_distributions --> p_report_only --> N'
                                                    ||' : This is not for reporting purpose so end processing. ');
                        -- ========================= FND LOG ===========================
                        RETURN FALSE;
                     END IF; -- 5 END IF
              END IF; -- 4 END IF
           ELSE
              -- ========================= FND LOG ===========================
                 psa_utils.debug_other_string(g_state_level,l_full_path,
	                                    ' Generate_distributions -> PSA_MF_MISC_PKG.create_distributions --> TRUE ');
              -- ========================= FND LOG ===========================
           END IF; -- 3 END IF

	 ELSE

	   /*
	   ## There is no count mismatch
	   ## check if the CCID for original lines were altered
           */

	   OPEN c_match_ccid(I.status);
	   LOOP

	       FETCH c_match_ccid INTO match_ccid_rec;
	       EXIT WHEN c_match_ccid%NOTFOUND;

	       IF (match_ccid_rec.distribution_ccid <> match_ccid_rec.code_combination_id) THEN
                  -- ========================= FND LOG ===========================
                     psa_utils.debug_other_string(g_state_level,l_full_path,
		                                   ' Generate_distributions --> match_ccid_rec.distribution_ccid'
                                                || ' <> match_ccid_rec.code_combination_id');
                  -- ========================= FND LOG ===========================

	          IF NOT (PSA_MF_MISC_PKG.create_distributions (
	                                                 errbuf                 => errbuf,
	                                                 retcode                => retcode,
	                                                 p_mode                 => 'R',
	                                                 p_error_message        => p_error_message,
  				                         x_status               => i.status,
				                         x_cash_receipt_hist_id => i.cash_receipt_history_id )) THEN
                     IF p_error_message IS NOT NULL OR retcode = 'F' THEN
                        -- ========================= FND LOG ===========================
                           psa_utils.debug_other_string(g_excep_level,l_full_path,
			                              ' Generate_distributions --> Error Message --> '
						      || p_error_message);
                        -- ========================= FND LOG ===========================

                        IF NVL(p_report_only,'N') = 'N' THEN
                           -- ========================= FND LOG ===========================
                              psa_utils.debug_other_string(g_excep_level,l_full_path,
			                                 ' Generate_distributions --> p_report_only --> N :'
                                                     ||' This is not for reporting purpose so end processing. ');
                           -- ========================= FND LOG ===========================
                           RETURN FALSE;
                        END IF;
                    END IF;

                 ELSE
                    -- ========================= FND LOG ===========================
                       psa_utils.debug_other_string(g_state_level,l_full_path,
		                                  ' Generate_distributions -> PSA_MF_MISC_PKG.create_distributions --> TRUE ');
                    -- ========================= FND LOG ===========================
                 END IF;
              END IF;

	    END LOOP;

          CLOSE c_match_ccid;
	  END IF; -- 2 END IF

   ELSE

        /*
        ## mf_dist_count = 0 .
        ## Distribution will be created for the first time.
	*/

	   IF NOT (PSA_MF_MISC_PKG.create_distributions (
	                                                  errbuf                 => errbuf,
	                                                  retcode                => retcode,
	                                                  p_mode                 => 'C',
						          p_error_message        => p_error_message,
				                          x_status               => i.status,
				                          x_cash_receipt_hist_id => i.cash_receipt_history_id )) THEN

              IF p_error_message IS NOT NULL OR retcode = 'F' THEN
                 -- ========================= FND LOG ===========================
                    psa_utils.debug_other_string(g_excep_level,l_full_path,
		                               ' Generate_distributions --> Error Message --> '
					       || p_error_message);
                 -- ========================= FND LOG ===========================

                 IF NVL(p_report_only,'N') = 'N' THEN
                       -- ========================= FND LOG ===========================
                          psa_utils.debug_other_string(g_excep_level,l_full_path,
		                                     ' Generate_distributions --> p_report_only --> N:'
                                                     ||' This is not for reporting purpose so end processing. ');
                       -- ========================= FND LOG ===========================
                       RETURN FALSE;
                 END IF;
              END IF;

          ELSE
              -- ========================= FND LOG ===========================
                 psa_utils.debug_other_string(g_state_level,l_full_path,
	                                    ' Generate_distributions -> PSA_MF_MISC_PKG.create_distributions --> FALSE ');
              -- ========================= FND LOG ===========================
          END IF;

     END IF; -- 1 END IF
   END LOOP;

   -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
                                   ' Generate_distributions -> END ');
   -- ========================= FND LOG ===========================

   retcode := 'S';
   RETURN TRUE;

 EXCEPTION
   WHEN OTHERS THEN -- here
        p_error_message:= 'EXCEPTION - OTHERS PACKAGE - PSA_MF_MISC_PKG.GENERATE_DISTRIBUTIONS - '||SQLERRM;
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_excep_level,l_full_path,p_error_message);
           psa_utils.debug_unexpected_msg(l_full_path);
        -- ========================= FND LOG ===========================
        retcode := 'F';
        RETURN FALSE;

 END Generate_distributions;

 /********************************** CREATE DISTRIBUTIONS ************************************/

 FUNCTION create_distributions (
                                 errbuf                 OUT NOCOPY VARCHAR2,
                                 retcode                OUT NOCOPY VARCHAR2,
                                 p_mode                 IN         VARCHAR2,
	                         p_error_message        OUT NOCOPY VARCHAR2,
		                 x_status               IN         VARCHAR2,
		                 x_cash_receipt_hist_id IN NUMBER) RETURN BOOLEAN

 IS

   CURSOR c_misc_dist (p_cash_rct_id IN  NUMBER)
   IS
     SELECT   m.misc_cash_distribution_id,
	      m.code_combination_id,m.amount,
	      m.gl_date,status,reversal_date
     FROM
	      ar_misc_cash_distributions m,
	      ar_cash_receipts cr
       WHERE  m.created_from LIKE DECODE(x_status,'REVERSED','%REVERSE%','%ARRERCT%') AND
       m.cash_receipt_id = cr.cash_receipt_id AND
       cr.cash_receipt_id = p_cash_rct_id;


   CURSOR c_misc_dist_new (p_cash_rect_id IN NUMBER)
   IS
     SELECT
	      m.misc_cash_distribution_id,
	      m.code_combination_id,
	      m.amount,
	      m.gl_date,
	      status,
	      reversal_date
     FROM
	      ar_misc_cash_distributions m,
	      ar_cash_receipts cr
     WHERE
	      m.cash_receipt_id = cr.cash_receipt_id
     AND      m.gl_posted_date IS NOT  NULL
     AND      cr.cash_receipt_id = p_cash_rect_id;


   CURSOR c_cash_ccid(p_cr_id IN NUMBER)
   IS
     SELECT cash_ccid , remittance_ccid
     FROM
            ar_receipt_method_accounts acc,
            ar_receipt_methods rm,
            ar_cash_receipts cr
     WHERE
            acc.receipt_method_id = rm.receipt_method_id
     AND    rm.receipt_method_id = cr.receipt_method_id
     AND    cr.cash_receipt_id = p_cr_id
     AND    cr.remittance_bank_account_id = acc.remit_bank_acct_use_id;


     -- Bug3963328
     -- AND    SYSDATE BETWEEN NVL(acc.start_date, SYSDATE) AND NVL(acc.end_date, SYSDATE);

-- Cash Mgt - c_cash_ccid is modified to choose the A/c from ar_cash_receipt_history_all
-- This table  stores the ccid  based on the activity - Remittance A/c or Cash A/c

 CURSOR c_mfar_dist_rec IS
    SELECT crh.status curstatus, crh1.status prevstatus
     FROM  ar_cash_receipt_history crh, ar_cash_receipt_history crh1
      WHERE crh.cash_receipt_history_id = x_cash_receipt_hist_id AND
      crh.cash_receipt_history_id = crh1.reversal_cash_receipt_hist_id(+);

 CURSOR c_reversal_ccid(p_misc_dist_id in number) IS
        SELECT cash_ccid FROM psa_mf_misc_dist_all
        WHERE reference1 = 'REMITTED'
        AND misc_cash_distribution_id = p_misc_dist_id;

     l_reversal_ccid NUMBER;
    l_bank_cash_ccid   NUMBER;
    l_mfar_ccid_rec c_cash_ccid%ROWTYPE;
    l_misc_dist_rec    c_misc_dist%ROWTYPE;
    misc_dist_new_rec  c_misc_dist_new%ROWTYPE;
    l_distribution_ccid            NUMBER(15); -- core distribution
    l_mf_cash_ccid                 NUMBER(15); -- Multi-fund cash A/c
    x_dummy                        VARCHAR2(250);
    l_count                        NUMBER;
    cr_status                      VARCHAR2(15);
    create_dist_flag               VARCHAR2(1);
    psa_count                      NUMBER(15);
    first_rec_flag                 VARCHAR2(1);
    flex_build_error               EXCEPTION;
    ccid_rec  c_cash_ccid%ROWTYPE;
    l_mfar_dist_rec c_mfar_dist_rec%ROWTYPE;
    l_primary_ccid NUMBER(15);
    -- ========================= FND LOG ===========================
    l_full_path VARCHAR2(100) := g_path || 'create_distributions';
    -- ========================= FND LOG ===========================

      BEGIN

      retcode := 'F';

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' Inside Create_distributions ');
         psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS: ');
         psa_utils.debug_other_string(g_state_level,l_full_path,' =========== ');
         psa_utils.debug_other_string(g_state_level,l_full_path,' p_mode  --> ' || p_mode);
         psa_utils.debug_other_string(g_state_level,l_full_path,'   ');
      -- ========================= FND LOG ===========================

	 OPEN  c_cash_ccid (g_cash_receipt_id);
 	 FETCH c_cash_ccid INTO ccid_rec;
	 CLOSE c_cash_ccid;

	 create_dist_flag := p_mode;

    FOR I IN c_cash_ccid(g_cash_receipt_id)
    LOOP

      /*========================================================================
	  If mode = 'R' Count of core and distribution lines are not equal.
	  If this condition happens before POSTING, the possibilities are
	  -- User creates a new Core distribution
	  -- User deletes a core distribution
	  THEN we delete all MFAR entries and re-create them based on latest core distributions.

	  If count mismatch happens after posting,
	  the ONLY possibility is REVERSAL of Misc. Receipt since user cannot update/delete/insert
	  core distributions after posting.
	  When REVERSAL occurs, one reversing line is created for each original line.
	  Multi-Fund logic should CREATE MF lines ONLY FOR THESE NEW REVERSING LINES
	  because the MF entrie corresponding to the original core distributions have
	  already been posted. Deleting and re-creating them will result in duplication
	  when they get posted to GL.
	  The cursor identifies the Core distribution rows that are reversing lines.
     =====================================================================================*/

         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,
	                               ' Create_distributions --> g_cash_receipt_id  --> '
				       || g_cash_receipt_id);
         -- ========================= FND LOG ===========================

	 IF create_dist_flag = 'R' THEN

	    SELECT status INTO cr_status
	    FROM   ar_cash_receipts
	    WHERE  cash_receipt_id = g_cash_receipt_id;

            -- ========================= FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path,
	                                  ' Create_distributions --> cr_status  --> ' || cr_status);
            -- ========================= FND LOG ===========================

	    IF cr_status IN ('NSF','STOP','REV') THEN

	       -- we delete records from psa_mf_misc_dist_all when the Dist records
	       --have not yet been posted and the Receipt has been reversed.
	       --These records are re-created by the code written below.

	       DELETE FROM psa_mf_misc_dist_all
	       WHERE  reference5 = g_cash_receipt_id
    	       AND    posting_control_id = -3;

               -- ========================= FND LOG ===========================
                  psa_utils.debug_other_string(g_state_level,l_full_path,
	                                     ' Create_distributions --> deleting from pas_mf_misc_dist_all for pstctrl -> -3 ');
                  psa_utils.debug_other_string(g_state_level,l_full_path,
	                                     ' Create_distributions --> records deleted --> ' || SQL%ROWCOUNT);
               -- ========================= FND LOG ===========================

               OPEN c_misc_dist_new(g_cash_receipt_id);
	       LOOP

		    FETCH c_misc_dist_new INTO misc_dist_new_rec;
		    EXIT WHEN c_misc_dist_new%NOTFOUND;

                    SELECT COUNT(*) INTO psa_count
                    FROM   psa_mf_misc_dist_all
                    WHERE  misc_cash_distribution_id = misc_dist_new_rec.misc_cash_distribution_id
		    AND    posting_control_id >0;

		    -- ========================= FND LOG ===========================
		       psa_utils.debug_other_string(g_state_level,l_full_path,
		                                  ' Create_distributions --> psa_count --> ' || psa_count);
		    -- ========================= FND LOG ===========================

		   IF psa_count = 0 THEN
                      -- ========================= FND LOG ===========================
                         psa_utils.debug_other_string(g_state_level,l_full_path,
		                                   ' Create_distributions --> calling PSA_MFAR_UTILS.override_segments ');
                      -- ========================= FND LOG ===========================

                      OPEN c_mfar_dist_rec;
                      FETCH c_mfar_dist_rec INTO l_mfar_dist_rec;
                      EXIT WHEN c_mfar_dist_rec%NOTFOUND;

                      IF    l_mfar_dist_rec.curstatus = 'REMITTED' THEN
                            l_primary_ccid := ccid_rec.remittance_ccid;
                      ELSIF l_mfar_dist_rec.curstatus = 'CLEARED' THEN
                            l_primary_ccid := ccid_rec.cash_ccid;
                      ELSIF l_mfar_dist_rec.curstatus = 'REVERSED' AND l_mfar_dist_rec.curstatus = 'CLEARED' THEN
                            l_primary_ccid := ccid_rec.cash_ccid;
                      ELSIF l_mfar_dist_rec.curstatus = 'REVERSED' AND l_mfar_dist_rec.curstatus = 'REMITTED' THEN
                            l_primary_ccid := ccid_rec.remittance_ccid;
                      END IF;

                      CLOSE c_mfar_dist_rec;

                      -- ========================= FND LOG ===========================
                         psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' Create_distributions --> l_primary_ccid --> ' || l_primary_ccid);
                         psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' Create_distributions --> l_misc_dist_rec.code_combination_id --> '
                                           || l_misc_dist_rec.code_combination_id);
                         psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' Create_distributions --> g_set_of_books_id --> ' || g_set_of_books_id);
                         psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' Create_distributions --> l_mf_cash_ccid --> ' || l_mf_cash_ccid);
                     -- ========================= FND LOG ===========================

		     IF NOT (PSA_MFAR_UTILS.override_segments ( p_primary_ccid    =>  l_primary_ccid,
			                                        p_override_ccid   =>  misc_dist_new_rec.code_combination_id,
			                                        p_set_of_books_id =>  g_set_of_books_id,
			                                        p_trx_type        =>  'MISC',
			                                        p_ccid            =>  l_mf_cash_ccid)) THEN

                        -- ========================= FND LOG ===========================
                           psa_utils.debug_other_string(g_state_level,l_full_path,
			                              ' Create_distributions --> calling PSA_MFAR_UTILS.override_segments --> FALSE');
                        -- ========================= FND LOG ===========================
		        RAISE FLEX_BUILD_ERROR;
                     ELSE
                      -- ========================= FND LOG ===========================
                         psa_utils.debug_other_string(g_state_level,l_full_path,
		                                    ' Create_distributions --> calling PSA_MFAR_UTILS.override_segments --> TRUE');
                      -- ========================= FND LOG ===========================

		     END IF;

                     -- ========================= FND LOG ===========================
                        psa_utils.debug_other_string(g_state_level,l_full_path,
		                                   ' Create_distributions --> calling psa_mf_misc_dist_all_pkg.insert_row ');
                     -- ========================= FND LOG ===========================

		  psa_mf_misc_dist_all_pkg.insert_row
		    (
		     X_ROWID                     => x_dummy,
		     X_MISC_MF_CASH_DIST_ID      => 1001,
		     X_MISC_CASH_DISTRIBUTION_ID => misc_dist_new_rec.misc_cash_distribution_id,
		     X_DISTRIBUTION_CCID         => misc_dist_new_rec.code_combination_id,
		     X_CASH_CCID                 => l_mf_cash_ccid,
		     X_COMMENTS                  => NULL, --'Insert',
		     X_POSTING_CONTROL_ID        => -3,
		     X_GL_DATE                   => misc_dist_new_rec.gl_date,
		     X_ATTRIBUTE_CATEGORY        => NULL,
		     X_ATTRIBUTE1                => NULL,
		     x_attribute2                => NULL,
		     X_ATTRIBUTE3                => NULL,
		     X_ATTRIBUTE4                => NULL,
		     X_ATTRIBUTE5                => NULL,
		     X_ATTRIBUTE6                => NULL,
		     X_ATTRIBUTE7                => NULL,
		     X_ATTRIBUTE8                => NULL,
		     X_ATTRIBUTE9                => NULL,
		     X_ATTRIBUTE10               => NULL,
		     X_ATTRIBUTE11               => NULL,
		     X_ATTRIBUTE12               => NULL ,
		     X_ATTRIBUTE13               => NULL,
		     X_ATTRIBUTE14               => NULL,
		     X_ATTRIBUTE15               => NULL,
		     X_REFERENCE1                => x_status,
		     X_REFERENCE2                => NULL,
		     X_REFERENCE3                => misc_dist_new_rec.reversal_date,
		     X_REFERENCE4                => misc_dist_new_rec.status,
	 	     X_REFERENCE5                => g_cash_receipt_id,
		     x_reversal_ccid             => null
					    	   );

		  END IF;

               END LOOP;
               CLOSE c_misc_dist_new;

	     ELSE
	                -- cr_status NOT IN ('NSF','STOP','REV')
                        -- No reversal scenario
                        -- count mismatch

               -- ========================= FND LOG ===========================
                  psa_utils.debug_other_string(g_state_level,l_full_path,
	                                     ' Create_distributions --> cr_status NOT IN (NSF,STOP,REV)');
                  psa_utils.debug_other_string(g_state_level,l_full_path,
	                                     ' Create_distributions --> delete from psa_mf_misc_dist_all ');
               -- ========================= FND LOG ===========================

               DELETE FROM psa_mf_misc_dist_all
               WHERE  misc_cash_distribution_id IN
		      (SELECT misc_cash_distribution_id
		       FROM   ar_misc_cash_distributions
		       WHERE  reference5 = g_cash_receipt_id);

               -- ========================= FND LOG ===========================
                  psa_utils.debug_other_string(g_state_level,l_full_path,
	                                     ' Create_distributions --> create_dist_flag - C');
               -- ========================= FND LOG ===========================

	       create_dist_flag := 'C';

	    END IF;
	 END IF;


      IF create_dist_flag = 'C' THEN

         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,
	                               ' Create_distributions --> create_dist_flag is C then');
         -- ========================= FND LOG ===========================

         IF c_misc_dist%ISOPEN THEN
            CLOSE c_misc_dist;
         END IF;

         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,
	                               ' Create_distributions --> Opening c_misc_dist');
         -- ========================= FND LOG ===========================

         OPEN c_misc_dist(g_cash_receipt_id);
         LOOP

              FETCH c_misc_dist INTO l_misc_dist_rec;
              EXIT WHEN c_misc_dist%NOTFOUND;

              -- ========================= FND LOG ===========================
                 psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' Create_distributions --> Calling PSA_MFAR_UTILS.OVERRIDE_SEGMENTS');
              -- ========================= FND LOG ===========================

              OPEN c_mfar_dist_rec;
              FETCH c_mfar_dist_rec INTO l_mfar_dist_rec;

              IF    l_mfar_dist_rec.curstatus = 'REMITTED' THEN
                    l_primary_ccid := ccid_rec.remittance_ccid;
              ELSIF l_mfar_dist_rec.curstatus = 'CLEARED' THEN
                    l_primary_ccid := ccid_rec.cash_ccid;
              ELSIF l_mfar_dist_rec.curstatus = 'REVERSED' AND l_mfar_dist_rec.prevstatus = 'CLEARED' THEN
                    l_primary_ccid := ccid_rec.cash_ccid;
              ELSIF l_mfar_dist_rec.curstatus = 'REVERSED' AND l_mfar_dist_rec.prevstatus = 'REMITTED' THEN
                    l_primary_ccid := ccid_rec.remittance_ccid;
              END IF;

              CLOSE c_mfar_dist_rec;

              -- ========================= FND LOG ===========================
                 psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' Create_distributions --> l_primary_ccid --> ' || l_primary_ccid);
                 psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' Create_distributions --> l_misc_dist_rec.code_combination_id --> '
                                           || l_misc_dist_rec.code_combination_id);
                 psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' Create_distributions --> g_set_of_books_id --> ' || g_set_of_books_id);
                 psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' Create_distributions --> l_mf_cash_ccid --> ' || l_mf_cash_ccid);
              -- ========================= FND LOG ===========================

             IF NOT (PSA_MFAR_UTILS.OVERRIDE_SEGMENTS(
 	                                              p_primary_ccid    =>  l_primary_ccid,
	                                              p_override_ccid   =>  l_misc_dist_rec.code_combination_id,
	                                              p_set_of_books_id =>  g_set_of_books_id,
                                                      p_trx_type        =>  'MISC',
	                                              p_ccid            =>  l_mf_cash_ccid)) THEN

                -- ========================= FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path,
		                              ' Create_distributions --> Calling PSA_MFAR_UTILS.OVERRIDE_SEGMENTS -- FALSE');
                -- ========================= FND LOG ===========================
                RAISE FLEX_BUILD_ERROR;
             ELSE
                -- ========================= FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path,
		                              ' Create_distributions --> Calling PSA_MFAR_UTILS.OVERRIDE_SEGMENTS -- TRUE');
                -- ========================= FND LOG ===========================
             END IF;

          -- ========================= FND LOG ===========================
                psa_utils.debug_other_string(g_state_level,l_full_path,
                                          ' Create_distributions --> Calling psa_mf_misc_dist_all_pkg.insert_row ');
          -- ========================= FND LOG ===========================

          SELECT first_posted_record_flag INTO first_rec_flag
          FROM   ar_cash_receipt_history
          WHERE cash_receipt_history_id = x_cash_receipt_hist_id;

          IF first_rec_flag = 'N' AND x_status = 'CLEARED' THEN
             OPEN c_reversal_ccid(l_misc_dist_rec.misc_cash_distribution_id);
             FETCH c_reversal_ccid INTO l_reversal_ccid;
             EXIT WHEN c_reversal_ccid%NOTFOUND;
             CLOSE c_reversal_ccid;
          END IF;

	 psa_mf_misc_dist_all_pkg.insert_row
	   (
	   X_ROWID                     => x_dummy,
	   X_MISC_MF_CASH_DIST_ID      => 1001,
	   X_MISC_CASH_DISTRIBUTION_ID => l_misc_dist_rec.misc_cash_distribution_id,
	   X_DISTRIBUTION_CCID         => l_misc_dist_rec.code_combination_id,
	   X_CASH_CCID                 => l_mf_cash_ccid,
	   X_COMMENTS                  => NULL, --'Insert',
	   X_POSTING_CONTROL_ID        => -3,
	   X_GL_DATE                   => l_misc_dist_rec.gl_date,
	   X_ATTRIBUTE_CATEGORY        => NULL,
	   X_ATTRIBUTE1                => NULL,
	   X_ATTRIBUTE2                => NULL,
	   X_ATTRIBUTE3                => NULL,
	   X_ATTRIBUTE4                => NULL,
           X_ATTRIBUTE5                => NULL,
           X_ATTRIBUTE6                => NULL,
           X_ATTRIBUTE7                => NULL,
           X_ATTRIBUTE8                => NULL,
           X_ATTRIBUTE9                => NULL,
           X_ATTRIBUTE10               => NULL,
           X_ATTRIBUTE11               => NULL,
           X_ATTRIBUTE12               => NULL ,
           X_ATTRIBUTE13               => NULL,
	   X_ATTRIBUTE14               => NULL,
	   X_ATTRIBUTE15               => NULL,
	   X_REFERENCE1                => x_status,
	   X_REFERENCE2                => NULL,
	   X_REFERENCE3                => l_misc_dist_rec.reversal_date,
	   X_REFERENCE4                => l_misc_dist_rec.status,
	   X_REFERENCE5                => g_cash_receipt_id,
	   x_reversal_ccid             => l_reversal_ccid);

     END LOOP;
     CLOSE c_misc_dist;
    END IF;
   END LOOP;
   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' Create_distributions --> End ');
   -- ========================= FND LOG ===========================

   retcode := 'S';
   RETURN TRUE;

 EXCEPTION
   WHEN FLEX_BUILD_ERROR THEN
        p_error_message:= 'EXCEPTION - FLEX_BUILD_ERROR PACKAGE - PSA_MF_MISC_PKG.CREATE_DISTRIBUTIONS - '||FND_MESSAGE.GET;
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_excep_level,l_full_path,p_error_message);
        -- ========================= FND LOG ===========================
        retcode := 'F';
        RETURN FALSE;

   WHEN OTHERS THEN
        p_error_message:= 'EXCEPTION - OTHERS PACKAGE - PSA_MF_MISC_PKG.CREATE_DISTRIBUTIONS - '||sqlerrm;
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_excep_level,l_full_path,p_error_message);
           psa_utils.debug_unexpected_msg(l_full_path);
        -- ========================= FND LOG ===========================
        retcode := 'F';
        RETURN FALSE;

 END create_distributions;

/********************************* MISC_RCT_CHANGED ********************************/

   FUNCTION misc_rct_changed(p_status IN VARCHAR2) RETURN BOOLEAN IS
   ar_dist_count   NUMBER := 0;
   psa_dist_count  NUMBER := 0;
   -- ========================= FND LOG ===========================
   l_full_path VARCHAR2(100) := g_path || 'misc_rct_changed';
   -- ========================= FND LOG ===========================

 BEGIN
  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' Misc_rct_changed --> start ');
  -- ========================= FND LOG ===========================

  IF p_status IN ('CLEARED','REMITTED') then
    SELECT count(misc_cash_distribution_id) INTO ar_dist_count
    FROM   ar_misc_cash_distributions
    WHERE  cash_receipt_id = g_cash_receipt_id AND amount>0;
  ELSE
    SELECT
	COUNT(misc_cash_distribution_id) INTO ar_dist_count
	FROM ar_misc_cash_distributions
	WHERE cash_receipt_id = g_cash_receipt_id
    AND  amount < 0;
  END IF;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,
                                ' Misc_rct_changed --> ar_dist_count -- ' || ar_dist_count);
  -- ========================= FND LOG ===========================


      SELECT COUNT(MISC_MF_CASH_DIST_ID) INTO psa_dist_count
      FROM   psa_mf_misc_dist_all           psa,
             ar_misc_cash_distributions     ar
      WHERE     psa.reference1 = p_status
      AND    psa.misc_cash_distribution_id = ar.misc_cash_distribution_id
      AND    ar.cash_receipt_id = g_cash_receipt_id;

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
                                    ' Misc_rct_changed --> psa_dist_count ' || psa_dist_count);
      -- ========================= FND LOG ===========================



     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,
                                   ' Misc_rct_changed -->  delete psa_mf_misc_dist_all ' || SQL%ROWCOUNT);
     -- ========================= FND LOG ===========================

     IF ar_dist_count = psa_dist_count THEN
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
	                              ' Misc_rct_changed --> ar_dist_count = psa_dist_count RETURN FALSE');
        -- ========================= FND LOG ===========================
        RETURN FALSE;

     ELSE
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
	                              ' Misc_rct_changed -->ar_dist_count != psa_dist_count RETURN TRUE');
        -- ========================= FND LOG ===========================
      	RETURN TRUE;
     END IF;

   EXCEPTION
      WHEN OTHERS THEN
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_excep_level,l_full_path,
	                          'EXCEPTION - OTHERS PACKAGE - PSA_MF_MISC_PKG.MISC_RCT_CHANGED - '||sqlerrm);
           psa_utils.debug_unexpected_msg(l_full_path);
        -- ========================= FND LOG ===========================
        RETURN FALSE;

   END misc_rct_changed;


END psa_mf_misc_pkg;

/
