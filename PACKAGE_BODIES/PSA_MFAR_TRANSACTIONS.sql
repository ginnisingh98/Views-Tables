--------------------------------------------------------
--  DDL for Package Body PSA_MFAR_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_MFAR_TRANSACTIONS" AS
/* $Header: PSAMFTXB.pls 120.15 2006/09/13 14:00:54 agovil ship $ */

g_cust_trx_id		ra_customer_trx_all.customer_trx_id%type;
g_set_of_books_id	ra_customer_trx_all.set_of_books_id%type;
g_receivables_ccid	ra_cust_trx_line_gl_dist_all.code_combination_id%type;
g_run_id		NUMBER;
--===========================FND_LOG.START=====================================
g_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(50)  := 'PSA.PLSQL.PSAMFTXB.PSA_MFAR_TRANSACTIONS.';
--===========================FND_LOG.END=======================================

--
-- LOCAL PROCEDURES
--

FUNCTION generate_trx_dist
		(errbuf                OUT NOCOPY  VARCHAR2,
                 retcode               OUT NOCOPY  VARCHAR2,
 		 p_error_message       OUT NOCOPY  VARCHAR2) RETURN BOOLEAN;

FUNCTION  transaction_is_complete RETURN BOOLEAN;
FUNCTION  transaction_modified    RETURN BOOLEAN;

-- for debug messages.
l_exception_error      VARCHAR2(3000);

FUNCTION create_distributions
		(errbuf                OUT NOCOPY  VARCHAR2,
                 retcode               OUT NOCOPY  VARCHAR2,
                 p_cust_trx_id		IN NUMBER,
		 p_set_of_books_id	IN NUMBER,
		 p_run_id		IN NUMBER,
		 p_error_message       OUT NOCOPY  VARCHAR2) RETURN BOOLEAN
IS

	CURSOR c_trx_dist
	IS
	  SELECT A.cust_trx_line_gl_dist_id	gl_dist_id,
		 A.code_combination_id		rev_ccid,
		 B.mf_receivables_ccid		mf_ccid,
	         B.prev_mf_receivables_ccid     prev_mf_ccid
	 FROM 	 ra_cust_trx_line_gl_dist_all 	A,
	  	 psa_mf_trx_dist_all 		B
	 WHERE 	 A.cust_trx_line_gl_dist_id	= B.cust_trx_line_gl_dist_id
	 AND 	 A.customer_trx_id		= g_cust_trx_id;
         /* bug 2737029
         AND EXISTS
                (SELECT 1 FROM ra_customer_trx_lines_all x
                 WHERE x.customer_trx_line_id = A.customer_trx_line_id
                 AND NVL(extended_amount,0) <> 0);
            bug 2737029 */

	CURSOR c_trx_type
	IS
	SELECT	A.rowid row_id
	 FROM	ra_customer_trx_all	A,
	  	ra_cust_trx_types_all	B
	 WHERE	A.customer_trx_id 	= g_cust_trx_id
	 AND	A.cust_trx_type_id	= B.cust_trx_type_id
                 And    (B.type = 'INV' OR B.type = 'DM')
	 FOR UPDATE;

	l_trx_dist_rec			c_trx_dist%rowtype;
	l_trx_type			c_trx_type%rowtype;
	l_temp_rec_ccid 		ra_cust_trx_line_gl_dist_all.code_combination_id%type;

        l_errbuf		        VARCHAR2(2000);
        l_retcode                       VARCHAR2(1);

	-- EXCEPTION
	FLEX_COMPARE_ERROR		EXCEPTION;
        generate_trx_dist_excep         EXCEPTION;
        -- ========================= FND LOG ===========================
        l_full_path VARCHAR2(100) := g_path || 'create_distributions';
        -- ========================= FND LOG ===========================
BEGIN

   retcode := 'F';

   -- ========================= FND LOG ===========================
   psa_utils.debug_other_string(g_state_level,l_full_path,'  ');
   psa_utils.debug_other_string(g_state_level,l_full_path,' Create_distributions ');
   psa_utils.debug_other_string(g_state_level,l_full_path,'  ');
   psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS : ');
   psa_utils.debug_other_string(g_state_level,l_full_path,' ============ ');
   psa_utils.debug_other_string(g_state_level,l_full_path,' p_cust_trx_id         -->' || p_cust_trx_id);
   psa_utils.debug_other_string(g_state_level,l_full_path,' p_set_of_books_id     -->' || p_set_of_books_id);
   psa_utils.debug_other_string(g_state_level,l_full_path,' p_run_id              -->' || p_run_id);
   psa_utils.debug_other_string(g_state_level,l_full_path,'  ');
   -- ========================= FND LOG ===========================

--	IF arp_global.sysparam.accounting_method = 'CASH' THEN

--	   retcode := 'S';
--	   RETURN TRUE;

--	END IF;

	--
	-- Initialize global variables
	--

	g_cust_trx_id     := p_cust_trx_id;
	g_set_of_books_id := p_set_of_books_id;
	g_run_id	  := p_run_id;

        -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,
	                              ' Create_distribution --> Is transaction compelete ? ');
        -- ========================= FND LOG ===========================

	IF (transaction_is_complete) THEN
        -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,
	                              ' Create_distribution --> Transaction is complete ');
        -- ========================= FND LOG ===========================

	   SELECT  code_combination_id
	     INTO  g_receivables_ccid
	     FROM  ra_cust_trx_line_gl_dist_all
	     WHERE customer_trx_id = g_cust_trx_id
	     AND   account_class = 'REC'
	     AND   account_set_flag = 'N';

        -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,
	                            '  Create_distribution --> g_receivables_ccid --> ' || g_receivables_ccid);
        -- ========================= FND LOG ===========================

	   --
	   -- Check if distributions already created
	   --

	   OPEN  c_trx_dist;
	   FETCH c_trx_dist INTO l_trx_dist_rec;
	   CLOSE c_trx_dist;

           -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' #cust_trx_line_gl_dist_id --> ' || l_trx_dist_rec.gl_dist_id
					 || ' #code_combination_id      --> ' || l_trx_dist_rec.rev_ccid
					 || ' #mf_receivables_ccid      --> ' || l_trx_dist_rec.mf_ccid
					 || ' #prev_mf_receivables_ccid --> ' || l_trx_dist_rec.prev_mf_ccid);
           -- ========================= FND LOG ===========================

	   IF l_trx_dist_rec.gl_dist_id Is Not Null  THEN	-- Transaction Distributions already created
 	      IF (transaction_modified) THEN

                 IF NOT (GENERATE_TRX_DIST (l_errbuf, l_retcode, l_exception_error)) THEN
                    -- ========================= FND LOG ===========================
                    psa_utils.debug_other_string(g_state_level,l_full_path,
		                                  ' Create_distribution --> GENERATE_TRX_DIST -> FALSE');
                    -- ========================= FND LOG ===========================
                    RAISE generate_trx_dist_excep;
                 ELSE
                    -- ========================= FND LOG ===========================
                    psa_utils.debug_other_string(g_state_level,l_full_path,
		                                  ' Create_distribution --> GENERATE_TRX_DIST -> TRUE');
                    -- ========================= FND LOG ===========================
                 END IF;

	      ELSE

		OPEN c_trx_dist;
		LOOP
		    FETCH c_trx_dist INTO  l_trx_dist_rec;
		    EXIT WHEN c_trx_dist%NOTFOUND;

                    -- ========================= FND LOG ===========================
                    psa_utils.debug_other_string(g_state_level,l_full_path,
		                                  ' Create_distribution --> calling  PSA_MFAR_UTILS.OVERRIDE_SEGMENTS');
                    -- ========================= FND LOG ===========================

		    IF NOT (PSA_MFAR_UTILS.OVERRIDE_SEGMENTS (
		                                              p_primary_ccid    => g_receivables_ccid,
		    					      p_override_ccid   => l_trx_dist_rec.rev_ccid,
							      p_set_of_books_id => g_set_of_books_id,
							      p_trx_type        => 'TRX',
							      p_ccid            => l_temp_rec_ccid)) THEN

                       -- ========================= FND LOG ===========================
                       psa_utils.debug_other_string(g_state_level,l_full_path,
		                                     ' Create_distribution --> Raising FLEX_COMPARE_ERROR ');
                       -- ========================= FND LOG ===========================
                       RAISE FLEX_COMPARE_ERROR;
		    END IF;

		   IF NOT (l_temp_rec_ccid = l_trx_dist_rec.prev_mf_ccid) THEN

                      IF NOT (GENERATE_TRX_DIST (l_errbuf, l_retcode, l_exception_error)) THEN
                         -- ========================= FND LOG ===========================
                         psa_utils.debug_other_string(g_state_level,l_full_path,
			                               ' Create_distribution --> GENERATE_TRX_DIST -> FALSE');
                         -- ========================= FND LOG ===========================
                         RAISE generate_trx_dist_excep;
                      ELSE
                         -- ========================= FND LOG ===========================
                         psa_utils.debug_other_string(g_state_level,l_full_path,
			                               ' Create_distribution --> GENERATE_TRX_DIST -> TRUE');
                         -- ========================= FND LOG ===========================
                      END IF;

                      EXIT;
		   END IF;

		END LOOP;
		CLOSE c_trx_dist;
	     END IF;

	   ELSE						-- New transaction distributions to be created

		OPEN	c_trx_type;
		FETCH	c_trx_type INTO l_trx_type;
		CLOSE	c_trx_type;

                -- ========================= FND LOG ===========================
                psa_utils.debug_other_string(g_state_level,l_full_path,
		                              ' Create_distribution --> Else part --> Type - Invoice OR DM');
                -- ========================= FND LOG ===========================

		IF l_trx_type.row_id Is Not Null THEN	-- Transaction is an invoice or a debit memo
                      IF NOT (GENERATE_TRX_DIST (l_errbuf, l_retcode, l_exception_error)) THEN
                         -- ========================= FND LOG ===========================
                         psa_utils.debug_other_string(g_state_level,l_full_path,
			                               ' Create_distribution --> GENERATE_TRX_DIST -> FALSE');
                         -- ========================= FND LOG ===========================
                         RAISE generate_trx_dist_excep;
                      ELSE
                        -- ========================= FND LOG ===========================
                        psa_utils.debug_other_string(g_state_level,l_full_path,
			                              ' Create_distribution --> GENERATE_TRX_DIST -> TRUE');
                        -- ========================= FND LOG ===========================
                      END IF;
		END IF;

	   END IF;
	END IF;

     retcode := 'S';
     RETURN TRUE;

EXCEPTION
	WHEN GENERATE_TRX_DIST_EXCEP THEN
	  PSA_MFAR_UTILS.INSERT_DISTRIBUTIONS_LOG (g_run_id, 'TRANSACTION',
	                                            g_cust_trx_id, Null, l_exception_error);
	  p_error_message := l_exception_error;
	  retcode := 'F';
          -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_excep_level,l_full_path,p_error_message);
          -- ========================= FND LOG ===========================
	  RETURN FALSE;

	WHEN FLEX_COMPARE_ERROR THEN
	  l_exception_error := 'EXCEPTION - FLEX_COMPARE_ERROR PACKAGE - PSA_MFAR_TRANSACTIONS.CREATE_DISTRIBUTIONS: '||FND_MESSAGE.GET;
	  PSA_MFAR_UTILS.INSERT_DISTRIBUTIONS_LOG (g_run_id, 'TRANSACTION',
	                                            g_cust_trx_id, Null, l_exception_error);

	  p_error_message := l_exception_error;
	  retcode := 'F';
          -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_excep_level,l_full_path,p_error_message);
          -- ========================= FND LOG ===========================
	  RETURN FALSE;

	WHEN OTHERS THEN
	  l_exception_error := 'EXCEPTION - OTHERS PACKAGE - PSA_MFAR_TRANSACTIONS.CREATE_DISTRIBUTIONS: '
	                         || sqlerrm;
	  PSA_MFAR_UTILS.INSERT_DISTRIBUTIONS_LOG (g_run_id, 'TRANSACTION',
	                                            g_cust_trx_id, Null, l_exception_error);

	  retcode := 'F';
	  p_error_message := l_exception_error;
          -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_excep_level,l_full_path,p_error_message);
          psa_utils.debug_unexpected_msg(l_full_path);
          -- ========================= FND LOG ===========================
          RETURN FALSE;

END create_distributions;

/****************************************** GENERATE_TRX_DIST ****************************************/

FUNCTION generate_trx_dist
		(errbuf                OUT NOCOPY  VARCHAR2,
                 retcode               OUT NOCOPY  VARCHAR2,
 		 p_error_message       OUT NOCOPY  VARCHAR2) RETURN BOOLEAN
IS

  -- Bug 3671841, query modified to improve performance
  CURSOR c_trx_gl_dist
  IS
    SELECT cust_trx_line_gl_dist_id,
	   code_combination_id
    FROM   ra_cust_trx_line_gl_dist_all y
    WHERE  customer_trx_id  = g_cust_trx_id
    AND    account_class <> 'REC'
    AND    NOT EXISTS ( SELECT 'x'
                        FROM  psa_mf_trx_dist_all psa
			WHERE psa.cust_trx_line_gl_dist_id = y.cust_trx_line_gl_dist_id
                      );
   /* bug 2737029
    AND EXISTS
           ( SELECT 1 FROM ra_customer_trx_lines_all x
             WHERE  x.customer_trx_line_id = y.customer_trx_line_id
             AND    NVL(extended_amount, 0) <> 0);
      bug 2737029 */

	l_revenue_ccid		ra_cust_trx_line_gl_dist_all.code_combination_id%type;
	l_ccid			ra_cust_trx_line_gl_dist_all.code_combination_id%type;
	l_trx_gl_dist_rec	c_trx_gl_dist%rowtype;
	l_rowid			ROWID;
        -- ========================= FND LOG ===========================
        l_full_path VARCHAR2(100) := g_path || 'generate_trx_dist';
        -- ========================= FND LOG ===========================

	-- EXCEPTION

	l_exception_error	VARCHAR2(2000);
	FLEX_BUILD_ERROR	EXCEPTION;

BEGIN
	--
	-- Delete existing records if any
	--

	Delete FROM psa_mf_trx_dist_all
	WHERE  cust_trx_line_gl_dist_id In
			(SELECT	cust_trx_line_gl_dist_id
			   FROM ra_cust_trx_line_gl_dist_all
			  WHERE	customer_trx_id = g_cust_trx_id)
	AND  posting_control_id IS NULL;

        -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,
	                              ' Generate_trx_dist --> delete from psa_mf_trx_dist_all -->'
				      || SQL%ROWCOUNT);
        -- ========================= FND LOG ===========================

	--
	-- Get revenue/tax/freight ccid's and create
	-- corresponding receivable ccid
	--

	OPEN   c_trx_gl_dist;
	LOOP

	   FETCH  c_trx_gl_dist INTO l_trx_gl_dist_rec;
	   EXIT WHEN c_trx_gl_dist%notfound;

	   l_revenue_ccid := l_trx_gl_dist_rec.code_combination_id;

	   --
	   -- Retrieve/Generate receivable ccid
	   --

           -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' Generate_trx_dist --> psa_mfar_utils.override_segments : ');
           psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' Generate_trx_dist --> g_receivables_ccid  --> '
					 || g_receivables_ccid);
           psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' Generate_trx_dist --> l_revenue_ccid      --> ' || l_revenue_ccid);
           psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' Generate_trx_dist --> g_set_of_books_id   --> '
					 || g_set_of_books_id);
           psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' Generate_trx_dist --> transaction type    --> ' || 'TRX');
           psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' Generate_trx_dist --> l_ccid              --> ' || l_ccid);
           -- ========================= FND LOG ===========================


	   IF NOT (PSA_MFAR_UTILS.OVERRIDE_SEGMENTS (g_receivables_ccid,
						     l_revenue_ccid,
						     g_set_of_books_id,
						     'TRX',
						     l_ccid))	THEN

             -- ========================= FND LOG ===========================
             psa_utils.debug_other_string(g_state_level,l_full_path,
	                                  ' Generate_trx_dist --> PSA_MFAR_UTILS.OVERRIDE_SEGMENTS --> FALSE');
             -- ========================= FND LOG ===========================
             RAISE FLEX_BUILD_ERROR;
	   END IF;

	   --
	   -- Insert into psa_mf_trx_dist_all table
	   --

	   PSA_MFAR_TRANSACTION_COVER_PKG.INSERT_ROW
	   	(X_ROWID 		    => l_rowid,
		 X_CUST_TRX_LINE_GL_DIST_ID => l_trx_gl_dist_rec.cust_trx_line_gl_dist_id,
		 X_RECEIVABLES_CCID	    => l_ccid,
		 X_PREV_MF_RECEIVABLES_CCID => l_ccid,
		 X_MODE			    => 'R');

           -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
	                                 ' Generate_trx_dist --> PSA_MFAR_TRANSACTION_COVER_PKG.INSERT_ROW ');
           -- ========================= FND LOG ===========================

	END LOOP;
	CLOSE c_trx_gl_dist;
        retcode := 'S';
        RETURN TRUE;

EXCEPTION
	WHEN FLEX_BUILD_ERROR THEN
	  p_error_message := 'EXCEPTION - FLEX_BUILD_ERROR PACKAGE - PSA_MFAR_TRANSACTIONS.GENERATE_TRX_DIST: '||FND_MESSAGE.GET;
	  PSA_MFAR_UTILS.INSERT_DISTRIBUTIONS_LOG (g_run_id, 'TRANSACTION',
	                                            g_cust_trx_id, Null, p_error_message);
          retcode := 'F';
          -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_excep_level,l_full_path,p_error_message);
          -- ========================= FND LOG ===========================
          RETURN FALSE;

	WHEN OTHERS THEN
          p_error_message := 'EXCEPTION - WHEN OTHERS - PSA_MFAR_TRANSACTIONS.GENERATE_TRX_DIST: '|| SQLERRM;
	  PSA_MFAR_UTILS.INSERT_DISTRIBUTIONS_LOG (g_run_id, 'TRANSACTION',
	                                            g_cust_trx_id, Null, p_error_message);
          retcode := 'F';
          -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_excep_level,l_full_path,p_error_message);
          psa_utils.debug_unexpected_msg(l_full_path);
          -- ========================= FND LOG ===========================
	  RETURN FALSE;

END generate_trx_dist;

 /****************************************** TRANSCTION_IS_COMPLETE ****************************************/

FUNCTION transaction_is_complete RETURN BOOLEAN IS

   CURSOR c_trx_complete
   IS
      SELECT complete_flag
      FROM   ra_customer_trx_all
      WHERE  customer_trx_id = g_cust_trx_id;

      l_trx_complete_rec	c_trx_complete%rowtype;
      -- ========================= FND LOG ===========================
      l_full_path VARCHAR2(100) := g_path || 'transaction_is_complete';
      -- ========================= FND LOG ===========================

BEGIN

     OPEN  c_trx_complete;
     FETCH c_trx_complete INTO l_trx_complete_rec;
     CLOSE c_trx_complete;

     IF l_trx_complete_rec.complete_flag = 'Y' THEN
        -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,' Transaction_is_complete -->  return TRUE');
        -- ========================= FND LOG ===========================
  	RETURN TRUE;
     ELSE
        -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,' Transaction_is_complete -->  return FALSE');
        -- ========================= FND LOG ===========================
     	RETURN FALSE;
     END IF;

EXCEPTION
	WHEN OTHERS THEN
	  l_exception_error := 'EXCEPTION - OTHERS PACKAGE - PSA_MFAR_TRANSACTIONS.TRANSACTION_IS_COMPLETE: '
	                          || SQLERRM;
	  PSA_MFAR_UTILS.INSERT_DISTRIBUTIONS_LOG (g_run_id, 'TRANSACTION', g_cust_trx_id, Null,
	  					   l_exception_error);
          -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_excep_level,l_full_path,l_exception_error);
          psa_utils.debug_unexpected_msg(l_full_path);
          -- ========================= FND LOG ===========================
          RETURN FALSE;

END transaction_is_complete;

 /****************************************** TRANSACTION_MODIFIED ****************************************/

FUNCTION transaction_modified RETURN BOOLEAN IS

	CURSOR c_core_trx_count IS
		SELECT 	count(cust_trx_line_gl_dist_id) core_count
		  FROM 	ra_cust_trx_line_gl_dist_all
		 WHERE 	customer_trx_id  = g_cust_trx_id
		   AND 	account_class <> 'REC';

	CURSOR c_mf_trx_count IS
		SELECT	count(B.cust_trx_line_gl_dist_id) mf_dist_count
		  FROM 	ra_cust_trx_line_gl_dist_all 	A,
		  	psa_mf_trx_dist_all 		B
		 WHERE 	A.cust_trx_line_gl_dist_id	= B.cust_trx_line_gl_dist_id
		   AND 	A.customer_trx_id		= g_cust_trx_id;

	l_core_count	NUMBER;
	l_mf_dist_count NUMBER;
        -- ========================= FND LOG ===========================
        l_full_path VARCHAR2(100) := g_path || 'transaction_modified';
        -- ========================= FND LOG ===========================
BEGIN
	OPEN  c_core_trx_count;
	FETCH c_core_trx_count INTO l_core_count;
	CLOSE c_core_trx_count;

        -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,
	                              ' Transaction_modified --> l_core_count --> ' || l_core_count);
        -- ========================= FND LOG ===========================

	OPEN  c_mf_trx_count;
	FETCH c_mf_trx_count INTO l_mf_dist_count;
	CLOSE c_mf_trx_count;

        -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,
	                              ' Transaction_modified --> l_mf_dist_count --> ' || l_mf_dist_count);
        -- ========================= FND LOG ===========================

        -- Bug 3671841, Delete statement commented and now placed in PSAMFG2B.pls
        /*
	DELETE FROM psa_mf_trx_dist_all
	WHERE  cust_trx_line_gl_dist_id Not In
	 ( SELECT cust_trx_line_gl_dist_id FROM ra_cust_trx_line_gl_dist_all );
        */

        -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,
	                              ' Transaction_modified --> delete psa_mf_trx_dist_all --> '
				      || SQL%ROWCOUNT);
        -- ========================= FND LOG ===========================

	IF l_core_count <> l_mf_dist_count THEN
	   RETURN TRUE;
	ELSE
	   RETURN FALSE;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	  l_exception_error := 'EXCEPTION - OTHERS PACKAGE - PSA_MFAR_TRANSACTIONS.TRANSACTION_MODIFIED: '
	                         || SQLERRM;
	  PSA_MFAR_UTILS.INSERT_DISTRIBUTIONS_LOG (g_run_id, 'TRANSACTION',
	                                            g_cust_trx_id, Null,l_exception_error);
          -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_excep_level,l_full_path,l_exception_error);
          psa_utils.debug_unexpected_msg(l_full_path);
          -- ========================= FND LOG ===========================
	  RETURN FALSE;

END  transaction_modified;

END PSA_MFAR_TRANSACTIONS;

/
