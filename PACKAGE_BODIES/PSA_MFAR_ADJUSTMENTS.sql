--------------------------------------------------------
--  DDL for Package Body PSA_MFAR_ADJUSTMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_MFAR_ADJUSTMENTS" AS
/* $Header: PSAMFADB.pls 120.22 2006/09/13 12:14:12 agovil ship $ */

--
-- global variables
--
g_adjustment_id		ar_adjustments_all.adjustment_id%type;
g_set_of_books_id	ra_customer_trx_all.set_of_books_id%type;
g_customer_trx_id 	ra_cust_trx_line_gl_dist_all.customer_trx_id%type;
g_cust_trx_line_id	ra_cust_trx_line_gl_dist_all.customer_trx_line_id%type;
g_adj_ccid		ar_adjustments_all.code_combination_id%type;
g_adj_amount		ar_adjustments_all.amount%type;
g_adj_type		ar_adjustments_all.type%type;
g_run_id		NUMBER;

--===========================FND_LOG.START=====================================
g_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(50)  := 'PSA.PLSQL.PSAMFADB.PSA_MFAR_ADJUSTMENTS.';
--===========================FND_LOG.END=======================================

--
-- Local Procedures
--


FUNCTION is_reverse_entry(l_index IN NUMBER) return BOOLEAN
IS

    -- ========================= FND LOG ===========================
       l_full_path VARCHAR2(100) := g_path || 'is_reverse_entry.';
    -- ========================= FND LOG ===========================
BEGIN
  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' Inside is_reverse_entry');
     psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS: ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' =========== ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' l_index           --> ' || l_index);
  -- ========================= FND LOG ===========================


    For I IN 1..ccid_info.count
    LOOP
  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' I -> ' || I);
  -- ========================= FND LOG ===========================

	IF (ccid_info(I).code_combination_id=ccid_info(l_index).code_combination_id) and
         ccid_info(I).amount_due <> 0  and ccid_info(l_index).amount_due <> 0 and
         (ccid_info(I).amount_due= -1* ccid_info(l_index).amount_due) and
         (ccid_info(I).cust_trx_line_id=ccid_info(l_INDEX).cust_trx_line_id) then


  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' Return->  TRUE');
  -- ========================= FND LOG ===========================

           RETURN TRUE;
        END IF;
    END LOOP;
  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' Return-> False');
  -- ========================= FND LOG ===========================
   RETURN FALSE;
 EXCEPTION
    WHEN OTHERS THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path,'EXCEPTION - OTHERS : ERROR IN PSA_MFAR_UTILS.is_ccid_exists');
            psa_utils.debug_other_string(g_excep_level,l_full_path,'RETURN -> FALSE');
            psa_utils.debug_other_string(g_excep_level,l_full_path, sqlcode || sqlerrm);
            psa_utils.debug_unexpected_msg(l_full_path);
         -- ========================= FND LOG ===========================
   RETURN FALSE;
END   is_reverse_entry;


FUNCTION generate_adj_dist
		(errbuf                OUT NOCOPY  VARCHAR2,
                 retcode               OUT NOCOPY  VARCHAR2,
 		 p_error_message       OUT NOCOPY  VARCHAR2) RETURN BOOLEAN;

FUNCTION create_distributions
		(errbuf                OUT NOCOPY VARCHAR2,
		 retcode               OUT NOCOPY VARCHAR2,
		 p_adjustment_id	IN NUMBER,
		 p_set_of_books_id	IN NUMBER,
		 p_run_id		IN NUMBER,
		 p_error_message       OUT NOCOPY VARCHAR2)

RETURN BOOLEAN
IS

	-- Bug 2982757
	-- Modified c_adjustments to pick code_combination_id
	-- from ar_distribtuions_all

	Cursor c_adjustments Is
                Select  adj.customer_trx_id             cust_trx_id,
                        adj.customer_trx_line_id        cust_trx_line_id,
                        ard.code_combination_id         adj_ccid,
                        adj.amount                      adj_amount,
                        adj.type                        adj_type
                  From  ar_adjustments                  adj,
                        ar_distributions                ard
                  Where adj.adjustment_id		= g_adjustment_id
                    and adj.adjustment_id 		= ard.source_id
                    and ard.source_table  		= 'ADJ'
                    and ard.source_type   		IN ('ADJ', 'FINCHRG');

	Cursor c_adj_dist Is
		Select	B.mf_receivables_ccid		mf_rec_ccid,
			C.mf_adjustment_ccid		mf_adj_ccid,
			C.prev_mf_adjustment_ccid       prev_mf_adj_ccid,
			C.prev_cust_trx_line_id		prev_cust_trx_line_id
		  From 	ra_cust_trx_line_gl_dist        A,
		  	psa_mf_trx_dist_all             B,
		  	psa_mf_adj_dist_all             C
		 Where 	C.adjustment_id			= g_adjustment_id
		 And	A.customer_trx_id		= g_customer_trx_id
                 And    A.CUST_TRX_LINE_GL_DIST_ID      = B.CUST_TRX_LINE_GL_DIST_ID
		 And	B.cust_trx_line_gl_dist_id	= C.cust_trx_line_gl_dist_id
		 FOR    UPDATE;

	l_adjustments_rec	c_adjustments%rowtype;
	l_adj_dist_rec		c_adj_dist%rowtype;
	l_temp_rec_ccid		gl_code_combinations.code_combination_id%type;

	-- EXCEPTION

	l_exception_error       VARCHAR2(2000);
	l_errbuf                VARCHAR2(100);
	l_retcode               VARCHAR2(100);

	FLEX_COMPARE_ERROR      EXCEPTION;
        GENERATE_ADJ_DIST_EXCEP EXCEPTION;

      -- ========================= FND LOG ===========================
         l_full_path VARCHAR2(100);
      -- ========================= FND LOG ===========================
BEGIN

      -- GSCC defaulting local variables
      l_full_path :=  g_path || 'create_distributions';

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path, ' START Create_distributions ');
         psa_utils.debug_other_string(g_state_level,l_full_path, ' PARAMETERS ');
         psa_utils.debug_other_string(g_state_level,l_full_path, ' ========== ');
         psa_utils.debug_other_string(g_state_level,l_full_path, ' p_adjustment_id   -> ' || p_adjustment_id);
         psa_utils.debug_other_string(g_state_level,l_full_path, ' p_set_of_books_id -> ' || p_set_of_books_id);
         psa_utils.debug_other_string(g_state_level,l_full_path, ' p_run_id          -> ' || p_run_id );
         psa_utils.debug_other_string(g_state_level,l_full_path, ' Starting the process ');
      -- ========================= FND LOG ===========================

      retcode := 'F';

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path, ' Setting retcode to -> ' || retcode);
         psa_utils.debug_other_string(g_state_level,l_full_path, ' arp_global.sysparam.accounting_method -> '
                                      || arp_global.sysparam.accounting_method );
      -- ========================= FND LOG ===========================

      IF arp_global.sysparam.accounting_method = 'CASH' THEN
         retcode := 'S';
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path, ' Retcode -> ' || retcode);
            psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN  -> TRUE ');
         -- ========================= FND LOG ===========================
         RETURN TRUE;
      END IF;

	--
	-- Initialize global variables
	--

	g_adjustment_id   := p_adjustment_id;
	g_set_of_books_id := p_set_of_books_id;
	g_run_id          := p_run_id;

	OPEN	c_adjustments;
	FETCH	c_adjustments INTO l_adjustments_rec;
	CLOSE	c_adjustments;

	g_customer_trx_id 	:= l_adjustments_rec.cust_trx_id;
	g_cust_trx_line_id	:= l_adjustments_rec.cust_trx_line_id;
	g_adj_ccid              := l_adjustments_rec.adj_ccid;
	g_adj_amount		:= l_adjustments_rec.adj_amount;
	g_adj_type              := l_adjustments_rec.adj_type;

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path, ' g_customer_trx_id  -> ' || g_customer_trx_id);
         psa_utils.debug_other_string(g_state_level,l_full_path, ' g_cust_trx_line_id -> ' || g_cust_trx_line_id);
         psa_utils.debug_other_string(g_state_level,l_full_path, ' g_adj_ccid         -> ' || g_adj_ccid);
         psa_utils.debug_other_string(g_state_level,l_full_path, ' g_adj_amount       -> ' || g_adj_amount);
         psa_utils.debug_other_string(g_state_level,l_full_path, ' g_adj_type         -> ' || g_adj_type);
      -- ========================= FND LOG ===========================

	--
	-- Check if distributions already created
	--

	OPEN  c_adj_dist;
	FETCH c_adj_dist INTO l_adj_dist_rec;
	CLOSE c_adj_dist;

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path, ' l_adj_dist_rec.mf_adj_ccid  -> ' || l_adj_dist_rec.mf_adj_ccid );
      -- ========================= FND LOG ===========================


	IF (l_adj_dist_rec.mf_adj_ccid Is Not Null)  THEN -- Adjustment Distributions already created

            -- ========================= FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path, ' Inside if - l_adj_dist_rec.mf_adj_ccid  -> is not null ');
            -- ========================= FND LOG ===========================

		OPEN c_adj_dist;
		LOOP

		    FETCH c_adj_dist INTO l_adj_dist_rec;
		    EXIT WHEN c_adj_dist%NOTFOUND;

                -- ========================= FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling PSA_MFAR_UTILS.OVERRIDE_SEGMENTS ');
                -- ========================= FND LOG ===========================

                IF NOT ( PSA_MFAR_UTILS.OVERRIDE_SEGMENTS ( P_PRIMARY_CCID         => g_adj_ccid,
                                                            P_OVERRIDE_CCID        => l_adj_dist_rec.mf_rec_ccid,
                                                            P_SET_OF_BOOKS_ID      => g_set_of_books_id,
                                                            P_TRX_TYPE             => 'ADJ',
                                                            P_CCID                 => l_temp_rec_ccid))          -- OUT
                THEN
                   -- ========================= FND LOG ===========================
                      psa_utils.debug_other_string(g_state_level,l_full_path, ' Raising FLEX_COMPARE_ERROR');
                   -- ========================= FND LOG ===========================
			 RAISE FLEX_COMPARE_ERROR;
                ELSE
                   -- ========================= FND LOG ===========================
                      psa_utils.debug_other_string(g_state_level,l_full_path, ' l_temp_rec_ccid --> ' || l_temp_rec_ccid);
                   -- ========================= FND LOG ===========================
		    END IF;

                -- ========================= FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path, ' l_temp_rec_ccid                 --> '
                                                || l_temp_rec_ccid );
                   psa_utils.debug_other_string(g_state_level,l_full_path, ' l_adj_dist_rec.prev_mf_adj_ccid --> '
                                                || l_adj_dist_rec.prev_mf_adj_ccid);
                   psa_utils.debug_other_string(g_state_level,l_full_path, ' nvl(g_cust_trx_line_id, -1)     --> '
                                                || nvl(g_cust_trx_line_id, -1));
                   psa_utils.debug_other_string(g_state_level,l_full_path, ' nvl(l_adj_dist_rec.prev_cust_trx_line_id, -1) --> '
                                                || nvl(l_adj_dist_rec.prev_cust_trx_line_id, -1));
                -- ========================= FND LOG ===========================

		    IF NOT (l_temp_rec_ccid = l_adj_dist_rec.prev_mf_adj_ccid) OR
		       NOT (nvl(g_cust_trx_line_id, -1) = nvl(l_adj_dist_rec.prev_cust_trx_line_id, -1)) THEN

                   -- ========================= FND LOG ===========================
                      psa_utils.debug_other_string(g_state_level,l_full_path, ' Inside IF ');
                   -- ========================= FND LOG ===========================

		       DELETE FROM psa_mf_adj_dist_all
		       WHERE adjustment_id = g_adjustment_id;

                   -- ========================= FND LOG ===========================
                      psa_utils.debug_other_string(g_state_level,l_full_path, ' DELETE FROM psa_mf_adj_dist_all --> ' || SQL%ROWCOUNT);
                   -- ========================= FND LOG ===========================

                   IF NOT (GENERATE_ADJ_DIST ( ERRBUF          => l_errbuf,               -- OUT
                                               RETCODE         => l_retcode,              -- OUT
                                               P_ERROR_MESSAGE => l_exception_error))     -- OUT
                   THEN
                      -- ========================= FND LOG ===========================
                         psa_utils.debug_other_string(g_state_level,l_full_path, ' Raising GENERATE_ADJ_DIST_EXCEP');
                      -- ========================= FND LOG ===========================
                      RAISE GENERATE_ADJ_DIST_EXCEP;
                   END IF;
                   -- ========================= FND LOG ===========================
                      psa_utils.debug_other_string(g_state_level,l_full_path, ' Exiting ');
                   -- ========================= FND LOG ===========================
		       EXIT;
		    END IF;
		END LOOP;
            CLOSE c_adj_dist;

	ELSE						-- New adjustment distributions to be created

           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path, ' Else part - l_adj_dist_rec.mf_adj_ccid  -> is null ');
           -- ========================= FND LOG ===========================
            IF NOT (GENERATE_ADJ_DIST ( ERRBUF          => l_errbuf,               -- OUT
                                        RETCODE         => l_retcode,              -- OUT
                                        P_ERROR_MESSAGE => l_exception_error))     -- OUT
            THEN
               -- ========================= FND LOG ===========================
                  psa_utils.debug_other_string(g_state_level,l_full_path, ' Raising GENERATE_ADJ_DIST_EXCEP ');
               -- ========================= FND LOG ===========================
               RAISE  GENERATE_ADJ_DIST_EXCEP;
            ELSE
               -- ========================= FND LOG ===========================
                  psa_utils.debug_other_string(g_state_level,l_full_path, ' l_temp_rec_ccid --> ' || l_temp_rec_ccid);
               -- ========================= FND LOG ===========================
            END IF;
	END IF;

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path, ' Setting retcode to --> ' || retcode);
         psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN TRUE ');
      -- ========================= FND LOG ===========================
      retcode := 'S';
      RETURN TRUE;

EXCEPTION
	WHEN GENERATE_ADJ_DIST_EXCEP THEN
	  PSA_MFAR_UTILS.INSERT_DISTRIBUTIONS_LOG (g_run_id, 'ADJUSTMENT', g_customer_trx_id, g_adjustment_id, l_exception_error);
	  p_error_message := l_exception_error;
	  retcode := 'F';
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_excep_level,l_full_path,l_exception_error);
        -- ========================= FND LOG ===========================
	  RETURN FALSE;

	WHEN FLEX_COMPARE_ERROR THEN
	  l_exception_error := 'EXCEPTION - FLEX_COMPARE_ERROR PACKAGE - PSA_MFAR_ADJUSTMENTS.CREATE_DISTRIBUTIONS - '||FND_MESSAGE.GET;
	  PSA_MFAR_UTILS.INSERT_DISTRIBUTIONS_LOG (g_run_id, 'ADJUSTMENT', g_customer_trx_id, g_adjustment_id, l_exception_error);
	  p_error_message := l_exception_error;
	  retcode := 'F';
          -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_excep_level,l_full_path,l_exception_error);
          -- ========================= FND LOG ===========================
	  RETURN FALSE;

	WHEN OTHERS THEN
	  l_exception_error := 'EXCEPTION - OTHERS PACKAGE - PSA_MFAR_ADJUSTMENTS.CREATE_DISTRIBUTIONS - '||SQLCODE || ' - ' || SQLERRM;
	  PSA_MFAR_UTILS.INSERT_DISTRIBUTIONS_LOG (g_run_id, 'ADJUSTMENT', g_customer_trx_id, g_adjustment_id, l_exception_error);
	  p_error_message := l_exception_error;
	  retcode := 'F';
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_excep_level,l_full_path,l_exception_error);
           psa_utils.debug_unexpected_msg(l_full_path);
        -- ========================= FND LOG ===========================
	  RETURN FALSE;

END create_distributions;

/******************************** GENERATE_ADJ_DEST ********************************/

FUNCTION generate_adj_dist
		(errbuf                OUT NOCOPY  VARCHAR2,
                 retcode               OUT NOCOPY  VARCHAR2,
 		 p_error_message       OUT NOCOPY  VARCHAR2) RETURN BOOLEAN
IS

 /*
   Bug 3140981.
   code_combination_id included in c_mf_adjustments.
 */
	l_customer_trx_line_id  ra_cust_trx_line_gl_dist_all.customer_trx_line_id%TYPE;

	Cursor c_mf_adjustments (c_sum_adr in number) Is
	Select	A.customer_trx_line_id		cust_trx_line_id,
		A.line_type			line_type,
		B.cust_trx_line_gl_dist_id	cust_trx_line_gl_dist_id,
		C.mf_receivables_ccid		mf_rec_ccid,
                b.code_combination_id           code_combination_id,
                decode (c_sum_adr,
			0, D.amount_due_original,
                        D.amount_due_remaining) amount_due,
		B.percent	-- panatara
        From 	ra_customer_trx_lines           A,
		ra_cust_trx_line_gl_dist        B,
		psa_mf_trx_dist_all		C,
		psa_mf_balances_view		D
	Where 	A.customer_trx_id		= g_customer_trx_id
            and A.customer_trx_line_id		= B.customer_trx_line_id
            and B.account_class <> 'REC'
            and	B.cust_trx_line_gl_dist_id	= C.cust_trx_line_gl_dist_id
	    and	C.cust_trx_line_gl_dist_id	= D.cust_trx_line_gl_dist_id
            and B.customer_trx_line_id 		= DECODE(g_adj_type,
					  		 'LINE', nvl(l_customer_trx_line_id, B.customer_trx_line_id),
					  		 B.customer_trx_line_id);

-- Bug 3140981: c_adj_gl_source to identify the adjustment type's GL Account source

    	CURSOR c_adj_gl_source IS
                   SELECT gl_account_source
                   FROM   ar_receivables_trx r, ar_adjustments a
                   WHERE  r.receivables_trx_id = a.receivables_trx_id
                   AND    a.adjustment_id = g_adjustment_id;


	l_mf_adjustments_rec		c_mf_adjustments%rowtype;
	p_ccid				psa_mf_adj_dist_all.mf_adjustment_ccid%type;
	l_temp_adj_type			ar_adjustments_all.type%type;
	l_flexbuild_error_reason	VARCHAR2(2000);
	l_total_amount_due		NUMBER;
	l_row_id		            VARCHAR2(100);

	-- Variables for calculating amount/percent

	l_amount			NUMBER;
	l_percent			NUMBER;
	l_amount_adjusted 	NUMBER;
	l_running_amount 		NUMBER;
	l_running_total_amount_due 	NUMBER;

	-- EXCEPTION
	l_exception_error		VARCHAR2(2000);
	FLEX_BUILD_ERROR		EXCEPTION;

        sum_amt_due_rem         NUMBER;
        l_adj_gl_source         ar_receivables_trx_all.gl_account_source%TYPE;
        l_adj_ccid              NUMBER(15);

        l_distr_line_count      NUMBER;
        l_count number := 0; /*for temporary table*/


      -- ========================= FND LOG ===========================
         l_full_path VARCHAR2(100);
      -- ========================= FND LOG ===========================

BEGIN

    -- GSCC defaulting local variables.
    l_full_path  := g_path || 'generate_adj_dist';

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' START generate_adj_dist');
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Starting the process ');
    -- ========================= FND LOG ===========================

    -- Bug 3140981:  store the Adjustment type's gl account source
    OPEN c_adj_gl_source;
    FETCH c_adj_gl_source INTO l_adj_gl_source;
    CLOSE c_adj_gl_source;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' l_adj_gl_source --> ' || l_adj_gl_source);
    -- ========================= FND LOG ===========================

    Select decode (sum(mf_balances.amount_due_remaining), 0, sum(mf_balances.amount_due_original),
                   sum(mf_balances.amount_due_remaining)) total_amount_due,
                   sum(mf_balances.amount_due_remaining) sum_amt_due_rem
    Into  l_total_amount_due, sum_amt_due_rem
    From  ra_customer_trx_lines	      trx_lines,
          ra_cust_trx_line_gl_dist	trx_dist,
          psa_mf_balances_view		mf_balances
    Where trx_lines.customer_trx_id             = g_customer_trx_id
    And   trx_lines.customer_trx_line_id        = trx_dist.customer_trx_line_id
    And   trx_dist.cust_trx_line_gl_dist_id     = mf_balances.cust_trx_line_gl_dist_id
    And   trx_lines.customer_trx_line_id        = nvl(g_cust_trx_line_id, trx_dist.customer_trx_line_id)
    And   trx_lines.line_type                   = decode(g_adj_type, 'LINE', 'LINE',
                                                                     'TAX', FIND_TAX_FREIGHT_LINES('TAX', trx_lines.line_type),
                                                                     'FREIGHT', FIND_TAX_FREIGHT_LINES('FREIGHT', trx_lines.line_type),
                                                                     'INVOICE', trx_lines.line_type, trx_lines.line_type);

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' l_total_amount_due --> ' || l_total_amount_due);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' sum_amt_due_rem    --> ' || sum_amt_due_rem);
    -- ========================= FND LOG ===========================

	--
	-- Initailize variables for running total
	--

	l_running_amount 	   := 0;
	l_running_total_amount_due := l_total_amount_due;

	-- Bug 3739491 .. Start
	-- Select the customer_trx_line_id if adjustment type is LINE

	IF (g_adj_type = 'LINE') THEN

		SELECT customer_trx_line_id INTO l_customer_trx_line_id
		FROM ar_adjustments
		WHERE adjustment_id = g_adjustment_id;

	END IF;

        IF (l_total_amount_due = 0) THEN
		IF (l_customer_trx_line_id IS NOT NULL) THEN
        		l_distr_line_count := 1;
        	ELSE
			SELECT	count(*) INTO    l_distr_line_count
        		FROM 	ra_customer_trx_lines           A,
				ra_cust_trx_line_gl_dist        B,
				psa_mf_trx_dist_all		C,
				psa_mf_balances_view		D
			WHERE 	A.customer_trx_id		= g_customer_trx_id
            		    and A.customer_trx_line_id		= B.customer_trx_line_id
            		    and B.account_class <> 'REC'
            		    and	B.cust_trx_line_gl_dist_id	= C.cust_trx_line_gl_dist_id
	    		    and	C.cust_trx_line_gl_dist_id	= D.cust_trx_line_gl_dist_id;



        	END IF;
	END IF;


          -- ========================= FND LOG ===========================
             psa_utils.debug_other_string(g_state_level,l_full_path, ' l_distr_line_count -> '||l_distr_line_count );
          -- ========================= FND LOG ===========================

	-- Bug 3739491 .. End


    OPEN c_mf_adjustments(sum_amt_due_rem);
    LOOP

	   FETCH c_mf_adjustments INTO l_mf_adjustments_rec;
	   Exit When c_mf_adjustments%NOTFOUND;

           l_count := nvl(ccid_info.count,0) + 1;
           ccid_info(l_count).cust_trx_line_id :=l_mf_adjustments_rec.cust_trx_line_id;
	     ccid_info(l_count).line_type := l_mf_adjustments_rec.line_type;
	     ccid_info(l_count).cust_trx_line_gl_dist_id := l_mf_adjustments_rec.cust_trx_line_gl_dist_id;
           ccid_info(l_count).mf_rec_ccid := l_mf_adjustments_rec.mf_rec_ccid;
           ccid_info(l_count).code_combination_id := l_mf_adjustments_rec.code_combination_id;
           ccid_info(l_count).amount_due := l_mf_adjustments_rec.amount_due;
           ccid_info(l_count).percent := l_mf_adjustments_rec.percent;

          -- ========================= FND LOG ===========================
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' Inside count --> '|| l_count );
          -- ========================= FND LOG ===========================


    END LOOP;
    CLOSE c_mf_adjustments;


    FOR I IN 1..l_count
    LOOP
     IF is_reverse_entry(I) THEN

         l_amount  := 0;
         l_percent := 0;

     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path, ' Reverse entry.');
     -- ========================= FND LOG ===========================


     ELSE




         -- Bug 3140981: Identify the appropriate adjustment ccid based on gl account source.
         -- For 'Revenue on Invoice', use ccid from ra_cust_trx_line_gl_dist_all
         -- For other gl account source, use the ccid from ar_distributions directly.

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' ccid_info(i).code_combination_id --> '
                                        || ccid_info(i).code_combination_id);
           psa_utils.debug_other_string(g_state_level,l_full_path, ' g_adj_ccid --> ' || g_adj_ccid);
        -- ========================= FND LOG ===========================

        IF l_adj_gl_source = 'REVENUE_ON_INVOICE' THEN
           l_adj_ccid :=  ccid_info(i).code_combination_id;
        ELSE
           l_adj_ccid := g_adj_ccid;
        END IF;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' l_adj_ccid  --> ' || l_adj_ccid );
        -- ========================= FND LOG ===========================

        IF NOT ( PSA_MFAR_UTILS.OVERRIDE_SEGMENTS ( P_PRIMARY_CCID         => l_adj_ccid,
	                                            P_OVERRIDE_CCID        =>  ccid_info(i).mf_rec_ccid,
                                                    P_SET_OF_BOOKS_ID      => g_set_of_books_id,
                                                    P_TRX_TYPE             => 'ADJ',
                                                    P_CCID                 => p_ccid))                  -- OUT
        THEN
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path, ' Raising FLEX_COMPARE_ERROR');
           -- ========================= FND LOG ===========================
           RAISE FLEX_BUILD_ERROR;
        ELSE
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path, ' p_ccid --> ' || p_ccid);
           -- ========================= FND LOG ===========================
        END IF;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' g_cust_trx_line_id  --> ' || g_cust_trx_line_id );
        -- ========================= FND LOG ===========================

        IF  g_cust_trx_line_id Is NOT NULL THEN

            -- ========================= FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path, ' Inside if - g_cust_trx_line_id Is NOT NULL ' );
            -- ========================= FND LOG ===========================

 		IF  (g_cust_trx_line_id =  ccid_info(i).cust_trx_line_id )
		AND  NOT (l_running_total_amount_due = 0 OR NVL(g_adj_amount, 0) = 0) THEN 	-- to avoid divide by zero error

                 -- ========================= FND LOG ===========================
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' Inside Second if ' );
                 -- ========================= FND LOG ===========================

		    l_amount_adjusted 		:= g_adj_amount - l_running_amount;
		    l_amount 			:= ROUND((l_amount_adjusted* ccid_info(i).amount_due/l_running_total_amount_due), 2);
		    l_percent 			:= ROUND((l_amount/g_adj_amount*100), 4);
		    l_running_amount 		:= l_running_amount + l_amount;
		    l_running_total_amount_due 	:= l_running_total_amount_due -  ccid_info(i).amount_due;


                 -- ========================= FND LOG ===========================
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' l_amount_adjusted --> ' || l_amount_adjusted );
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' l_amount          --> ' || l_amount );
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' l_percent         --> ' || l_percent );
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' l_running_amount  --> ' || l_running_amount );
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' l_running_total_amount_due --> ' || l_running_total_amount_due );
                 -- ========================= FND LOG ===========================
	        ELSIF ((g_adj_amount - l_running_amount) <> 0) AND (l_running_total_amount_due = 0) THEN
			--l_amount := ROUND(g_adj_amount * l_mf_adjustments_rec.percent/100, 2);
			--l_percent:= l_mf_adjustments_rec.percent;
                    l_amount  := ROUND(g_adj_amount/l_distr_line_count, 2);
                    l_percent := ROUND((l_amount/g_adj_amount*100), 4);
		ELSE
                 -- ========================= FND LOG ===========================
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' Inside Second else ' );
                 -- ========================= FND LOG ===========================

		    l_amount  := 0;
		    l_percent := 0;

                 -- ========================= FND LOG ===========================
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' l_amount          --> ' || l_amount );
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' l_percent         --> ' || l_percent );
                 -- ========================= FND LOG ===========================
		END IF;
	   ELSE

            -- ========================= FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path, ' Inside else - g_cust_trx_line_id Is NULL ' );
            -- ========================= FND LOG ===========================

		 Select DECODE(g_adj_type, 'LINE',    'LINE',
					   'TAX',     FIND_TAX_FREIGHT_LINES('TAX',      ccid_info(i).line_type),
					   'FREIGHT', FIND_TAX_FREIGHT_LINES('FREIGHT', ccid_info(i).line_type),
					   'INVOICE', ccid_info(i).line_type, ccid_info(i).line_type)
		  Into l_temp_adj_type From Dual;

            -- ========================= FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path, ' l_temp_adj_type --> ' || l_temp_adj_type  );
            -- ========================= FND LOG ===========================

		IF  ccid_info(i).line_type = l_temp_adj_type
		AND NOT (l_running_total_amount_due = 0)
		AND NOT (g_adj_amount = 0) THEN 	-- to avoid divide by zero error, Bug 3739491

                -- ========================= FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path, ' Inside third if ' );
                -- ========================= FND LOG ===========================

		    l_amount_adjusted 		:= g_adj_amount - l_running_amount;
		    l_amount 			:= ROUND((l_amount_adjusted*ccid_info(i).amount_due/l_running_total_amount_due), 2);
		    l_percent 			:= ROUND((l_amount/g_adj_amount*100), 4);
		    l_running_amount 		:= l_running_amount + l_amount;
		    l_running_total_amount_due 	:= l_running_total_amount_due - ccid_info(i).amount_due;

                 -- ========================= FND LOG ===========================
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' l_amount_adjusted --> ' || l_amount_adjusted );
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' l_amount          --> ' || l_amount );
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' l_percent         --> ' || l_percent );
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' l_running_amount  --> ' || l_running_amount );
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' l_running_total_amount_due --> ' || l_running_total_amount_due );
                 -- ========================= FND LOG ===========================
	        ELSIF ((g_adj_amount - l_running_amount) <> 0) AND (l_running_total_amount_due = 0) THEN
			/*l_amount := ROUND(g_adj_amount * l_mf_adjustments_rec.percent/100, 2);
			l_percent := l_mf_adjustments_rec.percent;*/

                 -- ========================= FND LOG ===========================
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' Inside else if' );
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' l_distr_line_count --> '|| l_distr_line_count );
                     psa_utils.debug_other_string(g_state_level,l_full_path, 'g_adj_amount  --> '|| g_adj_amount);
                 -- ========================= FND LOG ===========================


                    l_amount  := ROUND(g_adj_amount/l_distr_line_count, 2);
                    l_percent := ROUND((l_amount/g_adj_amount*100), 4);
		ELSE

                 -- ========================= FND LOG ===========================
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' Inside third else ' );
                 -- ========================= FND LOG ===========================

                 l_percent := 0;
		     l_amount  := 0;

                 -- ========================= FND LOG ===========================
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' l_amount          --> ' || l_amount );
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' l_percent         --> ' || l_percent );
                 -- ========================= FND LOG ===========================
		END IF;
	   END IF;


	   --
	   -- Insert into psa_mf_adj_dist_all
	   --

         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling PSA_MF_ADJ_DIST_ALL_PKG.INSERT_ROW ');
         -- ========================= FND LOG ===========================

	   PSA_MF_ADJ_DIST_ALL_PKG.INSERT_ROW
				   ( X_ROWID 			=> l_row_id,
				     X_ADJUSTMENT_ID		=> g_adjustment_id,
				     X_CUST_TRX_LINE_GL_DIST_ID	=> ccid_info(i).cust_trx_line_gl_dist_id,
				     X_MF_ADJUSTMENT_CCID	=> p_ccid,
				     X_AMOUNT			=> l_amount,
				     X_PERCENT			=> l_percent,
				     X_PREV_CUST_TRX_LINE_ID 	=> g_cust_trx_line_id,
				     X_PREV_MF_ADJUSTMENT_CCID  => p_ccid,
				     X_POSTING_CONTROL_ID 	=> -3,
				     X_MODE 			=> 'R' );

         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling PSA_MF_ADJ_DIST_ALL_PKG.INSERT_ROW --> ' || SQL%ROWCOUNT);
         -- ========================= FND LOG ===========================

   END IF;
   END LOOP;


      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path, ' Setting retcode --> ' || retcode);
         psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN TRUE ');
      -- ========================= FND LOG ===========================

	RETCODE := 'S';
      RETURN TRUE;

EXCEPTION
	WHEN FLEX_BUILD_ERROR THEN
	  l_exception_error := 'EXCEPTION - FLEX_BUILD_ERROR PACKAGE - PSA_MFAR_ADJUSTMENTS.GENERATE_ADJ_DIST '||FND_MESSAGE.GET;
	  PSA_MFAR_UTILS.INSERT_DISTRIBUTIONS_LOG (g_run_id, 'ADJUSTMENT', g_customer_trx_id, g_adjustment_id, l_exception_error);
        p_error_message := l_exception_error;
        RETCODE := 'F';
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_excep_level,l_full_path,l_exception_error);
        -- ========================= FND LOG ===========================
        RETURN FALSE;

	WHEN OTHERS THEN
	  l_exception_error := 'EXCEPTION - OTHERS PACKAGE - PSA_MFAR_ADJUSTMENTS.GENERATE_ADJ_DIST '||SQLCODE || ' - ' || SQLERRM;
	  PSA_MFAR_UTILS.INSERT_DISTRIBUTIONS_LOG (g_run_id, 'ADJUSTMENT', g_customer_trx_id, g_adjustment_id, l_exception_error);
        p_error_message := l_exception_error;
        RETCODE := 'F';
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_excep_level,l_full_path,l_exception_error);
           psa_utils.debug_unexpected_msg(l_full_path);
        -- ========================= FND LOG ===========================
        RETURN FALSE;

END generate_adj_dist;

 /*********************************  FIND_TAX_FREIGHT_LINES   ************************************/

FUNCTION FIND_TAX_FREIGHT_LINES (p_adjustment_type VARCHAR2,
				         p_line_type	   VARCHAR2 )
RETURN VARCHAR2 IS

   -- for bug 2756530
   -- modify the cursor to check if line_type exist to improve performance

   CURSOR c_tax_freight
   IS
    SELECT line_type
    FROM   ra_customer_trx_lines
    WHERE  line_type = p_adjustment_type
    AND    rownum = 1;

   l_line_type_rec c_tax_freight%rowtype;

   -- ========================= FND LOG ===========================
      l_full_path VARCHAR2(100);
   -- ========================= FND LOG ===========================

BEGIN

    -- GSCC defaulting local variables.
    l_full_path := g_path || 'find_tax_freight_lines';

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' START Tax_freight_lines ');
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Starting the process ');
    -- ========================= FND LOG ===========================

	OPEN  c_tax_freight;
	FETCH c_tax_freight INTO l_line_type_rec;
	CLOSE c_tax_freight;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' l_line_type_rec.line_type  --> ' || l_line_type_rec.line_type );
    -- ========================= FND LOG ===========================

	IF l_line_type_rec.line_type IS NULL THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN --> ' || p_line_type);
         -- ========================= FND LOG ===========================
         RETURN p_line_type;
	ELSE
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN --> ' || p_adjustment_type);
         -- ========================= FND LOG ===========================
         RETURN p_adjustment_type;
	END IF;

END FIND_TAX_FREIGHT_LINES;

END PSA_MFAR_ADJUSTMENTS;

/
