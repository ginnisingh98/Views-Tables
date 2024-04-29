--------------------------------------------------------
--  DDL for Package Body PSA_MFAR_RECEIPTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_MFAR_RECEIPTS" AS
/* $Header: PSAMFRTB.pls 120.29 2006/09/13 13:45:49 agovil ship $ */

g_set_of_books_id	 	gl_sets_of_books.set_of_books_id%type;
g_cust_trx_id			ar_receivable_applications.applied_customer_trx_id%type;
g_receivable_application_id	ar_receivable_applications.receivable_application_id%type;
g_inventory_item_profile	NUMBER;
g_run_id			NUMBER;
l_exception_message		VARCHAR2(3000);

TYPE TrxLinesTyp IS TABLE OF ra_customer_trx_lines.customer_trx_line_id%TYPE
	INDEX BY BINARY_INTEGER;

TrxLinesTab	 TrxLinesTyp;
--===========================FND_LOG.START=====================================
g_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(50)  := 'PSA.PLSQL.PSAMFRTB.PSA_MFAR_RECEIPTS.';
--===========================FND_LOG.END=======================================


-- Variables for currency code

 g_precision    NUMBER;
 g_ext_precision NUMBER;
 g_min_acct_unit NUMBER;


  /*
  ##################################
  ## PRIVATE PROCEDURES/FUNCTIONS ##
  ##################################
  */


FUNCTION distributions_exist_and_valid(p_receivable_app_id IN NUMBER) RETURN BOOLEAN;
FUNCTION CASH_CLR_DIST_EXIST_VALID(p_receivable_app_id IN NUMBER, p_amount in NUMBER, p_crh_status IN varchar2) RETURN BOOLEAN;

FUNCTION generate_rct_dist
		        (errbuf                        OUT NOCOPY VARCHAR2,
		         retcode                       OUT NOCOPY VARCHAR2,
			 p_rcv_app_id			IN	NUMBER,
			 p_cash_ccid			IN 	NUMBER,
			 p_cust_trx_id			IN 	NUMBER,
			 p_cust_trx_line_id		IN	NUMBER,
			 p_amount_applied		IN	NUMBER,
			 p_earned_discount		IN	NUMBER,
			 p_unearned_discount		IN	NUMBER,
			 p_earned_discount_ccid		IN	NUMBER,
			 p_unearned_discount_ccid	IN	NUMBER,
			 p_document_type		IN	VARCHAR2,
                         p_crh_status                   IN      VARCHAR2 DEFAULT 'OTHER',
                         p_error_message               OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

FUNCTION generate_rct_dist_cm
		        (errbuf                        OUT NOCOPY VARCHAR2,
		         retcode                       OUT NOCOPY VARCHAR2,
			 p_rcv_app_id			IN	NUMBER,
			 p_cash_ccid			IN 	NUMBER,
			 p_cust_trx_id			IN 	NUMBER,
			 p_cust_trx_line_id		IN	NUMBER,
			 p_amount_applied1		IN	NUMBER,
			 p_earned_discount		IN	NUMBER,
			 p_unearned_discount		IN	NUMBER,
			 p_earned_discount_ccid		IN	NUMBER,
			 p_unearned_discount_ccid	IN	NUMBER,
			 p_document_type		IN	VARCHAR2,
                         p_crh_status                   IN      VARCHAR2 DEFAULT 'OTHER',
                         p_error_message               OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

PROCEDURE populate_discount_lines_cache (p_customer_trx_id IN NUMBER);

PROCEDURE manual_transaction (p_customer_trx_id IN NUMBER,
			      discount_basis	IN VARCHAR2);

PROCEDURE imported_transaction (p_customer_trx_id IN NUMBER,
				p_discount_basis  IN VARCHAR2);

FUNCTION  line_in_discount_cache (p_customer_trx_line_id IN NUMBER) RETURN BOOLEAN;

PROCEDURE reset_discount_cache;

  /*
  ##########################
  ##  END OF DECLARATION  ##
  ##########################
  */

FUNCTION create_distributions
		(errbuf                OUT NOCOPY VARCHAR2,
		 retcode               OUT NOCOPY VARCHAR2,
		 p_receivable_app_id 	IN NUMBER,
		 p_set_of_books_id 	IN NUMBER,
		 p_run_id		IN NUMBER,
		 p_error_message       OUT NOCOPY VARCHAR2) RETURN BOOLEAN
IS

 CURSOR c_crh
 IS
   SELECT distinct crh.status , crh.cash_receipt_id
   FROM   ar_cash_receipt_history_all    crh,
          ar_receivable_applications_all ra
   WHERE  crh.cash_receipt_id  = ra.cash_receipt_id
   AND    ra.receivable_application_id = p_receivable_app_id
   ORDER BY crh.status desc;

 CURSOR c_rcpt_application
 IS
  SELECT app.applied_customer_trx_id		cust_trx_id,
         app.applied_customer_trx_line_id	cust_trx_line_id,
	 app.code_combination_id			rec_ccid,
	 app.cash_receipt_id			cash_receipt_id,
	 app.amount_applied			amount_applied,
	 app.earned_discount_taken		earned_discount,
	 app.unearned_discount_taken		unearned_discount,
	 app.earned_discount_ccid		earned_discount_ccid,
	 app.unearned_discount_ccid		unearned_discount_ccid,
	 app.customer_trx_id			cm_trx_id
  FROM   ar_receivable_applications_all		app
  WHERE  app.receivable_application_id	= p_receivable_app_id
  AND	 app.status		 	= 'APP'
  FOR  UPDATE;

 CURSOR c_cash_ccid (c_cash_receipt_id NUMBER, c_status IN varchar2)
 IS
   SELECT crh.account_code_combination_id	cash_ccid, crh.status
   FROM   ar_cash_receipts_all		cr,
          ar_cash_receipt_history_all	crh
   WHERE  cr.cash_receipt_id 		= c_cash_receipt_id
   AND    cr.cash_receipt_id 		= crh.cash_receipt_id
   AND    crh.status                    = c_status
   AND    NOT (cr.type                  = 'MISC');

 CURSOR c_credit_memo_type (c_cust_trx_id NUMBER)
 IS
   SELECT previous_customer_trx_id
   FROM   ra_customer_trx_all
   WHERE  customer_trx_id = c_cust_trx_id;

      --
	-- Bug 2515944
	-- Modified the select list in cursor c_direct_cm
	-- From: lines.previous_customer_trx_line_id trx_line_id, dist.amount amount
	-- To  : distinct lines.previous_customer_trx_line_id trx_line_id
	--

 CURSOR c_direct_cm (c_cust_trx_id NUMBER)
 IS
  SELECT distinct lines.previous_customer_trx_line_id trx_line_id
  FROM   ra_customer_trx_lines lines, ra_cust_trx_line_gl_dist dist
  WHERE  lines.customer_trx_id        = c_cust_trx_id
  AND    lines.customer_trx_line_id   = dist.customer_trx_line_id
  AND    dist.account_class           <> 'REC'
  AND    lines.extended_amount        <> 0;

 CURSOR c_direct_cm_line_amount (c_cust_trx_id NUMBER, c_trx_line_id NUMBER)
 IS
  Select sum(dist.amount) line_amount
  From  ra_customer_trx_lines lines,
        ra_cust_trx_line_gl_dist dist
  Where lines.customer_trx_id                 = c_cust_trx_id
  And   lines.previous_customer_trx_line_id   = c_trx_line_id
  And   lines.customer_trx_line_id            = dist.customer_trx_line_id
  And   dist.account_class                    <> 'REC'
  And   lines.extended_amount                 <> 0;

	l_rcpt_application_rec		c_rcpt_application%rowtype;
    	c_crh_rec  			c_crh%ROWTYPE;
	l_credit_memo_type		c_credit_memo_type%rowtype;
	l_direct_cm			c_direct_cm%rowtype;
	l_cash_ccid			c_cash_ccid%rowtype;
	l_ccid				ar_receivable_applications.code_combination_id%type;

  l_direct_cm_line_amount c_direct_cm_line_amount%rowtype;
  l_currency_code       VARCHAR2(15);

  generate_rct_dist_excep       EXCEPTION;

  -- ========================= FND LOG ===========================
  l_full_path VARCHAR2(100) := g_path || 'create_distributions';
  -- ========================= FND LOG ===========================

BEGIN

 -- ========================= FND LOG ===========================
    psa_utils.debug_other_string(g_state_level,l_full_path,'  ');
    psa_utils.debug_other_string(g_state_level,l_full_path,' Starting create_distributions');
    psa_utils.debug_other_string(g_state_level,l_full_path,'  ');
    psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS :');
    psa_utils.debug_other_string(g_state_level,l_full_path,' ============');
    psa_utils.debug_other_string(g_state_level,l_full_path,' p_receivable_app_id  -->' || p_receivable_app_id);
    psa_utils.debug_other_string(g_state_level,l_full_path,' p_set_of_books_id    -->' || p_set_of_books_id);
    psa_utils.debug_other_string(g_state_level,l_full_path,' p_run_id             -->' || p_run_id);
    psa_utils.debug_other_string(g_state_level,l_full_path,' Starting the process ');
 -- ========================= FND LOG ===========================

 --
 -- Initialize Global Variables
 --

 retcode := 'F';



 -- get the precisison for the currency code

     	SELECT currency_code
         INTO l_currency_code
         FROM  gl_sets_of_books
       WHERE set_of_books_id = p_set_of_books_id;


   fnd_currency.get_info(  l_currency_code,
			   g_precision    ,
	                   g_ext_precision,
	                   g_min_acct_unit);

 -- ========================= FND LOG ===========================
    psa_utils.debug_other_string(g_state_level,l_full_path,' Setting retcode to --> ' || retcode);
 -- ========================= FND LOG ===========================

 g_set_of_books_id 		:= p_set_of_books_id;
 g_receivable_application_id	:= p_receivable_app_id;
 g_run_id			      := p_run_id;

 -- Bug 3671841, commenting out this call and placing it in PSAMFG2B.pls
 -- PURGE_ORPHAN_DISTRIBUTIONS;

 OPEN  c_rcpt_application;
 FETCH c_rcpt_application INTO l_rcpt_application_rec;
 CLOSE c_rcpt_application;

 --
 -- Each receipt application has a unique receivable_application_id.
 -- Any change to the receipt application (ccid/amount/discount/...)
 -- will create a record with a new receivable_application_id.
 -- If psa_mf_rct_dist_all does not have corresponding records,
 -- multi-fund distributions are either not created or invalid.
 --

 --
 -- Cash Mgt : the function should check for existence of Cash
 -- and/or remittance MFAR distributions
 --

 -- ========================= FND LOG ===========================
    psa_utils.debug_other_string(g_state_level,l_full_path,' Calling distributions_exist_and_valid ');
 -- ========================= FND LOG ===========================

 IF NOT (distributions_exist_and_valid (p_receivable_app_id)) THEN  -- 1

    -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,' Inside first if ' );
        psa_utils.debug_other_string(g_state_level,l_full_path,' distributions_exist_and_valid -> TRUE ');
    -- ========================= FND LOG ===========================

    -- Initialize global variable
    g_cust_trx_id := l_rcpt_application_rec.cust_trx_id;

    -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,' g_cust_trx_id -> ' || g_cust_trx_id );
        psa_utils.debug_other_string(g_state_level,l_full_path,' l_rcpt_application_rec.cash_receipt_id -> ' || l_rcpt_application_rec.cash_receipt_id );
    -- ========================= FND LOG ===========================

    IF l_rcpt_application_rec.cash_receipt_id IS NULL THEN		-- CREDIT MEMO APPLICATION
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' Inside Second if');
       -- ========================= FND LOG ===========================

       l_ccid := l_rcpt_application_rec.rec_ccid;
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' l_ccid --> ' || l_ccid);
       -- ========================= FND LOG ===========================

       OPEN  c_credit_memo_type (l_rcpt_application_rec.cm_trx_id);
       FETCH c_credit_memo_type INTO l_credit_memo_type;
       CLOSE c_credit_memo_type;

       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' Credit memo type --> ' || l_credit_memo_type.previous_customer_trx_id);
       -- ========================= FND LOG ===========================

       IF l_credit_memo_type.previous_customer_trx_id IS NOT NULL THEN -- Direct Credit Memo if

          -- ========================= FND LOG ===========================
             psa_utils.debug_other_string(g_state_level,l_full_path,' Inside third if');
             psa_utils.debug_other_string(g_state_level,l_full_path,' l_rcpt_application_rec.cm_trx_id --> ' || l_rcpt_application_rec.cm_trx_id);
          -- ========================= FND LOG ===========================

          OPEN c_direct_cm (l_rcpt_application_rec.cm_trx_id);
          LOOP

            FETCH c_direct_cm INTO l_direct_cm;
            EXIT WHEN c_direct_cm%NOTFOUND;

            -- ========================= FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path,' l_direct_cm.trx_line_id --> ' || l_direct_cm.trx_line_id);
            -- ========================= FND LOG ===========================

            OPEN c_direct_cm_line_amount(l_rcpt_application_rec.cm_trx_id,
                                         l_direct_cm.trx_line_id);
            FETCH c_direct_cm_line_amount INTO l_direct_cm_line_amount;
            CLOSE c_direct_cm_line_amount;

            -- ========================= FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path,' l_direct_cm_line_amount --> ' ||l_direct_cm_line_amount.line_amount);
               psa_utils.debug_other_string(g_state_level,l_full_path,' Calling GENERATE_RCT_DIST ');
            -- ========================= FND LOG ===========================

              IF NOT (GENERATE_RCT_DIST_CM
			        (errbuf                      => errbuf,
                                 retcode                     => retcode,
	                         p_rcv_app_id                => p_receivable_app_id,
			         p_cash_ccid                 => l_ccid,
				 p_cust_trx_id               => l_rcpt_application_rec.cust_trx_id,
				 p_cust_trx_line_id          => l_direct_cm.trx_line_id,
                                                          -- Bug 2515944: l_direct_cm.amount,
				-- p_amount_applied            => l_direct_cm_line_amount.line_amount,
                                 p_amount_applied1            =>  -1*l_rcpt_application_rec.amount_applied,
				 p_earned_discount           => l_rcpt_application_rec.earned_discount,
				 p_unearned_discount         => l_rcpt_application_rec.unearned_discount,
				 p_earned_discount_ccid      => l_rcpt_application_rec.earned_discount_ccid,
				 p_unearned_discount_ccid    => l_rcpt_application_rec.unearned_discount_ccid,
				 p_document_type             => 'CM',
                                 p_crh_status                => NULL,
			         p_error_message             => l_exception_message)) THEN

                     -- ========================= FND LOG ===========================
                        psa_utils.debug_other_string(g_state_level,l_full_path,' Generate_rct_dist --> FALSE ');
                        psa_utils.debug_other_string(g_state_level,l_full_path,' Raising  generate_rct_dist_excep');
                     -- ========================= FND LOG ===========================
                     RAISE generate_rct_dist_excep;
              ELSE
                     -- ========================= FND LOG ===========================
                        psa_utils.debug_other_string(g_state_level,l_full_path,' Generate_rct_dist --> TRUE ');
                     -- ========================= FND LOG ===========================
	      END IF;
	    END LOOP;

          -- ========================= FND LOG ===========================
             psa_utils.debug_other_string(g_state_level,l_full_path,' out of c_direct_cm loop');
          -- ========================= FND LOG ===========================
          CLOSE c_direct_cm;

       ELSE									-- On Account Credit Memo

          -- ========================= FND LOG ===========================
             psa_utils.debug_other_string(g_state_level,l_full_path,' Inside third else');
             psa_utils.debug_other_string(g_state_level,l_full_path,' On Account Credit memo (cust_trx_line_id) --> ' || l_rcpt_application_rec.cust_trx_line_id);
             psa_utils.debug_other_string(g_state_level,l_full_path,' Calling GENERATE_RCT_DIST ');
          -- ========================= FND LOG ===========================

          -- Bug 3107904 amount_applied*-1 for parameter : p_amount_applied of GENERATE_RCT_DIST

           IF NOT (GENERATE_RCT_DIST
			        (errbuf                      => errbuf,
		                 retcode                     => retcode,
	                         p_rcv_app_id                => p_receivable_app_id,
				 p_cash_ccid                 => l_ccid,
				 p_cust_trx_id               => l_rcpt_application_rec.cust_trx_id,
				 p_cust_trx_line_id          => l_rcpt_application_rec.cust_trx_line_id,
				 p_amount_applied            => (l_rcpt_application_rec.amount_applied)*-1,
				 p_earned_discount           => l_rcpt_application_rec.earned_discount,
				 p_unearned_discount         => l_rcpt_application_rec.unearned_discount,
				 p_earned_discount_ccid      => l_rcpt_application_rec.earned_discount_ccid,
				 p_unearned_discount_ccid    => l_rcpt_application_rec.unearned_discount_ccid,
				 p_document_type             => 'CM',
                                 p_crh_status                => NULL,
			         p_error_message             => l_exception_message)) THEN

                     -- ========================= FND LOG ===========================
                        psa_utils.debug_other_string(g_state_level,l_full_path,' Generate_rct_dist --> FALSE ');
                        psa_utils.debug_other_string(g_state_level,l_full_path,' Raising  generate_rct_dist_excep');
                     -- ========================= FND LOG ===========================
                     RAISE generate_rct_dist_excep;
           ELSE
                     -- ========================= FND LOG ===========================
                     psa_utils.debug_other_string(g_state_level,l_full_path,' Generate_rct_dist --> TRUE ');
                     -- ========================= FND LOG ===========================
	     END IF;

      END IF;   -- Direct Credit Memo end if

     ELSE
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' Inside second else ');
          psa_utils.debug_other_string(g_state_level,l_full_path,' l_rcpt_application_rec.cash_receipt_id IS NULL');
       -- ========================= FND LOG ===========================
     END IF;    -- Credit memo application end if

   ELSE
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' Inside first else ');
          psa_utils.debug_other_string(g_state_level,l_full_path,' distributions_exist_and_valid -> FALSE ');
       -- ========================= FND LOG ===========================
   END IF;      -- 1 end if


    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' Cash receipt - Cash Management ');
    -- ========================= FND LOG ===========================

    -- ## Cash receipt - Cash Management ##
    IF (l_rcpt_application_rec.cash_receipt_id IS NOT NULL) THEN      -- 2 if

       OPEN c_crh;
       LOOP

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,' l_rcpt_application_rec.cash_receipt_id -> ' || l_rcpt_application_rec.cash_receipt_id);
        -- ========================= FND LOG ===========================

        FETCH c_crh INTO c_crh_rec;
        EXIT WHEN c_crh%NOTFOUND;

         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,' Calling CASH_CLR_DIST_EXIST_VALID ');
         -- ========================= FND LOG ===========================

         -- CASH RECEIPT APPLICATION
         IF (CASH_CLR_DIST_EXIST_VALID ( p_receivable_app_id,
                                         l_rcpt_application_rec.amount_applied,
                                         c_crh_rec.status))
         THEN

            -- ========================= FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path,' CASH_CLR_DIST_EXIST_VALID -> TRUE');
            -- ========================= FND LOG ===========================
            OPEN  c_cash_ccid (l_rcpt_application_rec.cash_receipt_id,
                               c_crh_rec.status);
            FETCH c_cash_ccid INTO l_cash_ccid;
            CLOSE c_cash_ccid;

 	      l_ccid := l_cash_ccid.cash_ccid;
            -- ========================= FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path,' cash_ccid - l_ccid -> ' || l_ccid);
            -- ========================= FND LOG ===========================

            IF l_ccid IS NOT NULL THEN

              -- ========================= FND LOG ===========================
                 psa_utils.debug_other_string(g_state_level,l_full_path,' Inside if - l_ccid is not null');
                 psa_utils.debug_other_string(g_state_level,l_full_path,' Calling generate_rct_dist ');
              -- ========================= FND LOG ===========================

	        IF NOT (GENERATE_RCT_DIST
		                (errbuf                      => errbuf,
		                 retcode                     => retcode,
	                         p_rcv_app_id                => p_receivable_app_id,
				 p_cash_ccid                 => l_ccid,
				 p_cust_trx_id               => l_rcpt_application_rec.cust_trx_id,
				 p_cust_trx_line_id          => l_rcpt_application_rec.cust_trx_line_id,
				 p_amount_applied            => l_rcpt_application_rec.amount_applied,
				 p_earned_discount           => l_rcpt_application_rec.earned_discount,
				 p_unearned_discount         => l_rcpt_application_rec.unearned_discount,
				 p_earned_discount_ccid      => l_rcpt_application_rec.earned_discount_ccid,
				 p_unearned_discount_ccid    => l_rcpt_application_rec.unearned_discount_ccid,
				 p_document_type             => 'RCT',
                                 p_crh_status                => c_crh_rec.status,
                                 p_error_message             => l_exception_message)) THEN

                     -- ========================= FND LOG ===========================
                        psa_utils.debug_other_string(g_state_level,l_full_path,' Generate_rct_dist --> FALSE ');
                        psa_utils.debug_other_string(g_state_level,l_full_path,' Raising  generate_rct_dist_excep');
                     -- ========================= FND LOG ===========================
                     RAISE generate_rct_dist_excep;
             ELSE
                     -- ========================= FND LOG ===========================
                     psa_utils.debug_other_string(g_state_level,l_full_path,' Generate_rct_dist --> TRUE ');
                     -- ========================= FND LOG ===========================
             END IF;
           ELSE
              -- ========================= FND LOG ===========================
                 psa_utils.debug_other_string(g_state_level,l_full_path,' Inside else - l_ccid is NULL');
              -- ========================= FND LOG ===========================
           END IF;

         ELSE
              -- ========================= FND LOG ===========================
                 psa_utils.debug_other_string(g_state_level,l_full_path,' CASH_CLR_DIST_EXIST_VALID -> FALSE ');
              -- ========================= FND LOG ===========================
         END IF;
      END LOOP;
      CLOSE c_crh;

     ELSE
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' Cash_receipt_id -> l_rcpt_application_rec.cash_receipt_id is null');
       -- ========================= FND LOG ===========================
     END IF;

     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,' retcode --> ' || retcode);
        psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN TRUE ');
     -- ========================= FND LOG ===========================

     retcode := 'S';
     RETURN TRUE;

EXCEPTION
        WHEN generate_rct_dist_excep THEN
	  retcode := 'F';
 	  PSA_MFAR_UTILS.INSERT_DISTRIBUTIONS_LOG (g_run_id, 'RECEIPT', g_cust_trx_id, g_receivable_application_id, l_exception_message);
	  p_error_message := l_exception_message;
          -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_excep_level,l_full_path,p_error_message);
          -- ========================= FND LOG ===========================
	  RETURN FALSE;

	WHEN OTHERS THEN
	  retcode := 'F';
	  p_error_message := 'EXCEPTION - OTHERS PACKAGE - PSA_MFAR_TRANSACTIONS.CREATE_DISTRIBUTIONS - ' || SQLERRM;
 	  PSA_MFAR_UTILS.INSERT_DISTRIBUTIONS_LOG (g_run_id, 'RECEIPT', g_cust_trx_id, g_receivable_application_id,
	  					   p_error_message);
          -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_excep_level,l_full_path,p_error_message);
          psa_utils.debug_unexpected_msg(l_full_path);
          -- ========================= FND LOG ===========================
	  RETURN FALSE;

END create_distributions;

/**************************************** DISTRIBUTIONS_EXIST_AND_VALID ************************************/

FUNCTION distributions_exist_and_valid(p_receivable_app_id IN NUMBER) RETURN BOOLEAN
IS
	l_rct_dist_count	NUMBER;
        -- ========================= FND LOG ===========================
        l_full_path VARCHAR2(100) := g_path || 'distributions_exist_and_valid';
        -- ========================= FND LOG ===========================
BEGIN

        -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,' Distributions_exist_and_valid --> START');
        -- ========================= FND LOG ===========================

	SELECT count(rct.receivable_application_id)
	INTO   l_rct_dist_count
	FROM	 psa_mf_rct_dist_all rct
	WHERE	 rct.receivable_application_id = p_receivable_app_id;

        -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,' Distributions_exist_and_valid -> l_rct_dist_count ' || l_rct_dist_count);
        -- ========================= FND LOG ===========================

	IF l_rct_dist_count > 0 THEN
            -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,' Distributions_exist_and_valid --> RETURN TRUE');
            -- ========================= FND LOG ===========================
	      RETURN TRUE;
	ELSE
            -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,' Distributions_exist_and_valid --> RETURN FALSE');
            -- ========================= FND LOG ===========================
	      RETURN FALSE;
	END IF;

EXCEPTION
 WHEN OTHERS THEN
          -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_excep_level,l_full_path,' Distributions_exist_and_valid -> EXCEPTION WHEN OTHERS ' || SQLERRM );
          psa_utils.debug_unexpected_msg(l_full_path);
          -- ========================= FND LOG ===========================
	  RETURN FALSE;

END distributions_exist_and_valid;

/**************************************** CASH_CLR_DIST_EXIST_VALID ************************************/

--
-- Function checks Distribution records for Cleared and remitted lines
--

FUNCTION cash_clr_dist_exist_valid(
                                   p_receivable_app_id IN NUMBER,
                                   p_amount            IN NUMBER,
                                   p_crh_status        IN VARCHAR2) RETURN BOOLEAN
IS
  l_rct_dist_count	NUMBER;
  -- ========================= FND LOG ===========================
  l_full_path VARCHAR2(100) := g_path || 'cash_clr_dist_exist_valid';
  -- ========================= FND LOG ===========================
BEGIN

  -- ========================= FND LOG ===========================
  psa_utils.debug_other_string(g_state_level,l_full_path,' Cash_clr_dist_exist_valid -> START');
  -- ========================= FND LOG ===========================

  SELECT count(rct.receivable_application_id)
  INTO   l_rct_dist_count
  FROM   psa_mf_rct_dist_all rct
  WHERE  rct.receivable_application_id = p_receivable_app_id;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_amount         -> ' || p_amount );
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_crh_status     -> ' || p_crh_status );
     psa_utils.debug_other_string(g_state_level,l_full_path,' l_rct_dist_count -> ' || l_rct_dist_count);
  -- ========================= FND LOG ===========================

  IF (p_amount < 0)  AND (p_crh_status IN ('REMITTED','CLEARED')) THEN
     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,' Inside first if ');
     -- ========================= FND LOG ===========================
    IF (l_rct_dist_count > 0) THEN
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN FALSE ');
       -- ========================= FND LOG ===========================
       RETURN FALSE;
    ELSE
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN TRUE ');
       -- ========================= FND LOG ===========================
       RETURN TRUE;
    END IF;
  END IF;

  IF (p_amount > 0) AND (p_crh_status = 'REVERSED') THEN
     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,' Inside second if ');
     -- ========================= FND LOG ===========================
    IF (l_rct_dist_count > 0) THEN
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN FALSE ');
       -- ========================= FND LOG ===========================
       RETURN FALSE;
    ELSE
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN TRUE ');
       -- ========================= FND LOG ===========================
       RETURN TRUE;
    END IF;
  END IF;

  IF l_rct_dist_count > 0 THEN
     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,' Inside third if ');
        psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN FALSE');
     -- ========================= FND LOG ===========================
     RETURN FALSE;
  ELSE
     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,' Inside third else ');
        psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN TRUE');
     -- ========================= FND LOG ===========================
     RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
       -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' Cash_clr_dist_exist_valid -> EXCEPTION WHEN OTHERS ' || SQLERRM);
       psa_utils.debug_unexpected_msg(l_full_path);
       -- ========================= FND LOG ===========================
       RETURN FALSE;

END cash_clr_dist_exist_valid;

/**************************************** GENERATE_RCT_DIST ************************************/

FUNCTION generate_rct_dist
		        (errbuf                         OUT NOCOPY VARCHAR2,
		         retcode                        OUT NOCOPY VARCHAR2,
			 p_rcv_app_id			IN	   NUMBER,
			 p_cash_ccid			IN 	   NUMBER,
			 p_cust_trx_id			IN 	   NUMBER,
			 p_cust_trx_line_id		IN	   NUMBER,
			 p_amount_applied		IN	   NUMBER,
			 p_earned_discount		IN	   NUMBER,
			 p_unearned_discount		IN	   NUMBER,
			 p_earned_discount_ccid		IN	   NUMBER,
			 p_unearned_discount_ccid	IN	   NUMBER,
			 p_document_type		IN	   VARCHAR2,
                         p_crh_status                   IN         VARCHAR2 DEFAULT 'OTHER',
                         p_error_message                OUT NOCOPY VARCHAR2) RETURN BOOLEAN

IS

   CURSOR c_remit_reversal_account(p_gl_dist_id IN NUMBER) IS
    SELECT
     mf_cash_ccid
     FROM psa_mf_rct_dist_all
     WHERE receivable_application_id = p_rcv_app_id
     AND cust_trx_line_gl_dist_id = p_gl_dist_id;
--   AND reference1 = 'REMITTED';
/*
	-- Parameter added by RM for 1604281
	-- Order By condition added by Tpradhan for One-off Fix 3075090
	Cursor c_accrual (sum_adr in number)
	Is
			Select mf_trx_dist.mf_receivables_ccid		rcv_ccid,
				 mf_trx_dist.cust_trx_line_gl_dist_id	trx_line_dist_id,
				 trx_line.customer_trx_line_id		trx_line_id,
				 trx_line.link_to_cust_trx_line_id	      link_trx_line_id,
				 -- column below changed by RM for 1604281
				 decode (sum_adr, 0, mf_balances.amount_due_original,
						    mf_balances.amount_due_remaining)	amount_due
			  From  ra_customer_trx_lines_all		trx_line,
			  	  ra_cust_trx_line_gl_dist_all		trx_dist,
			  	  psa_mf_trx_dist_all			mf_trx_dist,
			  	  psa_mf_balances_view			mf_balances
			  Where trx_line.customer_trx_id	  	= p_cust_trx_id
			  And   mf_balances.customer_trx_id		= p_cust_trx_id
			  And	  trx_line.customer_trx_line_id	  	= trx_dist.customer_trx_line_id
			  And	  trx_dist.cust_trx_line_gl_dist_id 	= mf_trx_dist.cust_trx_line_gl_dist_id
			  And	  mf_trx_dist.cust_trx_line_gl_dist_id 	= mf_balances.cust_trx_line_gl_dist_id
			  and   trx_line.customer_trx_line_id	  	= nvl (p_cust_trx_line_id,trx_line.customer_trx_line_id)
                          AND EXISTS (SELECT 1 FROM ra_customer_trx_lines_all x
                                      WHERE x.customer_trx_line_id = trx_line.customer_trx_line_id
                                      AND NVL(extended_amount, 0) <> 0)
                          ORDER BY 2 DESC;

	Cursor c_cash Is
			Select trx_dist.code_combination_id	       rev_ccid,
				 trx_dist.cust_trx_line_gl_dist_id   trx_line_dist_id
			  From ra_customer_trx_all		trx,
				 ra_customer_trx_lines_all	trx_line,
			  	 ra_cust_trx_line_gl_dist_all	trx_dist
			  Where trx.customer_trx_id	  	= p_cust_trx_id
			  And	  trx.customer_trx_id		= trx_line.customer_trx_id
			  And	  trx_line.customer_trx_line_id	= trx_dist.customer_trx_line_id
			  And	  trx_dist.account_class		= 'REV';
*/

--	l_accrual_rec			c_accrual%rowtype;
--	l_cash_rec			c_cash%rowtype;
	p_ccid				psa_mf_rct_dist_all.mf_cash_ccid%type;
	p_mf_earned_discount_ccid       ar_receivable_applications.earned_discount_ccid%type;
	p_mf_unearned_discount_ccid     ar_receivable_applications.unearned_discount_ccid%type;
	l_rowid				ROWID;
        run_num	                        number(15);

	l_c_accrual_stmt		VARCHAR2(6000);

	l_c_cash_stmt			VARCHAR2(6000);

	TYPE AccrualTyp IS RECORD (rcv_ccid		NUMBER(15),
				   trx_line_dist_id	NUMBER(15),
				   trx_line_id		NUMBER(15),
				   link_trx_line_id	NUMBER(15),
				   amount_due		NUMBER);

      TYPE var_cur IS REF CURSOR;

      c_accrual_cur VAR_CUR;
	l_accrual_rec AccrualTyp;

-- Variables for calculating amount and percent

	l_amount_applied		NUMBER;
	l_running_amount 		NUMBER;
	l_running_total_amount_due	NUMBER;
	l_total_amount_due		NUMBER;
	l_amount			NUMBER;
	l_percent			NUMBER;

-- Variables for calculating earned discount

    	l_earn_discount_applied		NUMBER;
    	l_earned_discount	    	NUMBER;
    	l_running_earned_discount	NUMBER;
    	l_running_total_amount_earn	NUMBER;

-- Variables for calculating unearned discount

    	l_unearn_discount_applied     	NUMBER;
    	l_unearned_discount	      	NUMBER;
    	l_running_unearn_discount     	NUMBER;
    	l_running_total_amount_unearn 	NUMBER;

	-- var added below by RM for 1604281
      sum_amt_due_rem number;
      l_remit_reversal_ccid NUMBER(15);

      l_exception_message varchar2(3000);
      l_retcode varchar2(1);
      l_errbuf  varchar2(100);
      l_zero_amt_flag NUMBER(1);

      FLEX_BUILD_ERROR		EXCEPTION;
      INVALID_DISTRIBUTION            EXCEPTION;

      -- ========================= FND LOG ===========================
         l_full_path VARCHAR2(100) := g_path || 'generate_rct_dist';
      -- ========================= FND LOG ===========================

BEGIN

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' Start Generate_rct_dist ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS');
     psa_utils.debug_other_string(g_state_level,l_full_path,' ==========');
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_rcv_app_id             -> ' || p_rcv_app_id);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_cash_ccid              -> ' || p_cash_ccid);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_cust_trx_id            -> ' || p_cust_trx_id);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_cust_trx_line_id       -> ' || p_cust_trx_line_id);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_amount_applied         -> ' || p_amount_applied);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_earned_discount        -> ' || p_earned_discount);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_unearned_discount      -> ' || p_unearned_discount);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_earned_discount_ccid   -> ' || p_earned_discount_ccid);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_unearned_discount_ccid -> ' || p_unearned_discount_ccid);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_document_type          -> ' || p_document_type);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_crh_status             -> ' || p_crh_status);
     psa_utils.debug_other_string(g_state_level,l_full_path,' Starting the process ');
  -- ========================= FND LOG ===========================

  -- Bug 2609367
  -- call psa_mfar_transactions.create_distributions
  -- When 'Create Distributions is run as a Conc. program OR invoked from the Action of opening MFAR Form,
  -- PSA_MF_CREATE_DISTRIBUTIONS package is called. This makes sure that MFAR distributions for a Transaction
  --  is created before proceeding to create Distributions for Receipts etc.
  -- However, MFAR dist. for a Trx is not created when GL Xfr is executed for a Cash Receipt whose GL Date is
  -- different from the transaction AND when MFAR for the Trx has not been created through the other means.

    select psa_mF_error_log_s.currval
    into run_num
    from sys.dual;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' Creating distribution for Cust trx id ==> ' || run_num || ' -- ' || p_cust_trx_id);
    -- ========================= FND LOG ===========================

    IF NOT (PSA_MFAR_TRANSACTIONS.create_distributions (
                                                     errbuf            => l_errbuf,
                                                     retcode           => l_retcode,
                                                     p_cust_trx_id     => p_cust_trx_id,
                                                     p_set_of_books_id => g_set_of_books_id,
                                                     p_run_id          => run_num,
                                                     p_error_message   => l_exception_message)) THEN

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,' PSA_MFAR_TRANSACTIONS.create_distributions --> FALSE');
        -- ========================= FND LOG ===========================
        IF l_exception_message IS NOT NULL OR l_retcode = 'F' THEN
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,' Raising  invalid_distribution');
           -- ========================= FND LOG ===========================
           Raise invalid_distribution;
        END IF;
     ELSE
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,' cust_trx_id --> ' || p_cust_trx_id);
           -- ========================= FND LOG ===========================
     END IF;

     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,' p_earned_discount   --> ' || p_earned_discount );
        psa_utils.debug_other_string(g_state_level,l_full_path,' p_unearned_discount --> ' || p_unearned_discount );
     -- ========================= FND LOG ===========================

     IF (p_earned_discount <> 0 OR p_unearned_discount <> 0) THEN
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,' Calling populate_discount_cache --> ' || p_cust_trx_id);
        -- ========================= FND LOG ===========================
	  POPULATE_DISCOUNT_LINES_CACHE (p_cust_trx_id);
     END IF;



    l_zero_amt_flag := 0;

         -- Check to see if a trx is a zero dollar invoice
    BEGIN

       SELECT 1
         INTO l_zero_amt_flag
         FROM DUAL
 WHERE EXISTS (SELECT 1
                 FROM ra_customer_trx_lines_all
                WHERE customer_trx_id = p_cust_trx_id
                  AND extended_amount <> 0 );
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_zero_amt_flag := 0;
     END;

      -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,
                        ' l_zero_amt_flag --> ' || l_zero_amt_flag );

     -- ========================= FND LOG ===========================



      SELECT
             decode (sum(mf_balances.amount_due_remaining),0,
                   sum(mf_balances.amount_due_original),
                decode (l_zero_amt_flag,1,sum(mf_balances.amount_due_original),
                   sum(mf_balances.amount_due_remaining))) total_amount_due,
             decode (l_zero_amt_flag,1,sum(mf_balances.amount_due_original),
                  sum(mf_balances.amount_due_remaining)) sum_amt_due_rem
     INTO  l_total_amount_due,
           sum_amt_due_rem
     FROM  ra_customer_trx_lines_all	 trx_line,
           ra_cust_trx_line_gl_dist_all     trx_dist,
           psa_mf_balances_view	         mf_balances
     WHERE trx_line.customer_trx_id	           = p_cust_trx_id
     AND   mf_balances.customer_trx_id	     = p_cust_trx_id
     AND	trx_line.customer_trx_line_id      = trx_dist.customer_trx_line_id
     AND	trx_dist.cust_trx_line_gl_dist_id  = mf_balances.cust_trx_line_gl_dist_id
     AND   trx_line.customer_trx_line_id       = nvl(p_cust_trx_line_id, trx_line.customer_trx_line_id);

     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,' l_total_amount_due --> ' || l_total_amount_due );
        psa_utils.debug_other_string(g_state_level,l_full_path,' sum_amt_due_rem    --> ' || sum_amt_due_rem    );
     -- ========================= FND LOG ===========================


     --
     -- Initailize variables for running total
     --

                l_running_amount 	         := 0;
		l_running_total_amount_due :=  l_total_amount_due ;

	    	l_running_earned_discount   := 0;
	    	l_running_total_amount_earn := l_total_amount_due;

	    	l_running_unearn_discount     := 0;
	    	l_running_total_amount_unearn := l_total_amount_due;


                -- ========================= FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path,' l_running_total_amount_due    --> ' || l_running_total_amount_due );
                   psa_utils.debug_other_string(g_state_level,l_full_path,' l_running_total_amount_earn   --> ' || l_running_total_amount_earn);
                   psa_utils.debug_other_string(g_state_level,l_full_path,' l_running_total_amount_unearn --> ' || l_running_total_amount_unearn);
               -- ========================= FND LOG ===========================

		l_c_accrual_stmt :=
		'Select	mf_trx_dist.mf_receivables_ccid		rcv_ccid,							' ||
		'	mf_trx_dist.cust_trx_line_gl_dist_id	trx_line_dist_id,                      				' ||
		'	trx_line.customer_trx_line_id		trx_line_id,                                 			' ||
		'	trx_line.link_to_cust_trx_line_id	link_trx_line_id,						' ||
		'	decode (:l_zero_amt_flag, 1, mf_balances.amount_due_original, mf_balances.amount_due_remaining)	amount_due	' ||
		'  From ra_customer_trx_lines			trx_line,                              				' ||
		'  	ra_cust_trx_line_gl_dist		trx_dist,                                   			' ||
		'  	psa_mf_trx_dist_all			mf_trx_dist,							' ||
		'  	psa_mf_balances_view			mf_balances							' ||
		' Where trx_line.customer_trx_id	  	= :p_cust_trx_id_1                           			' ||
		' And   mf_balances.customer_trx_id		= :p_cust_trx_id_2						' ||
		' And	trx_line.customer_trx_line_id	  	= trx_dist.customer_trx_line_id        				' ||
		' And	trx_dist.cust_trx_line_gl_dist_id 	= mf_trx_dist.cust_trx_line_gl_dist_id				' ||
		' And	mf_trx_dist.cust_trx_line_gl_dist_id 	= mf_balances.cust_trx_line_gl_dist_id				' ||
		' And   trx_line.customer_trx_line_id	  	= nvl(:p_cust_trx_line_id,trx_line.customer_trx_line_id) ';
      /*	' ||
		' And   EXISTS (SELECT 1 FROM ra_customer_trx_lines_all x							' ||
		'                WHERE x.customer_trx_line_id = trx_line.customer_trx_line_id AND NVL(extended_amount, 0) <> 0)	'; */

		l_c_cash_stmt :=
		'Select	trx_dist.code_combination_id		rcv_ccid,							' ||
		'	trx_dist.cust_trx_line_gl_dist_id	trx_line_dist_id,                      				' ||
		'	trx_line.customer_trx_line_id		trx_line_id,                                 			' ||
		'	trx_line.link_to_cust_trx_line_id	link_trx_line_id,						' ||
		'	decode (:l_zero_amt_flag, 1, mf_balances.amount_due_original, mf_balances.amount_due_remaining)	amount_due	' ||
		'  From ra_customer_trx_lines			trx_line,                              				' ||
		'  	ra_cust_trx_line_gl_dist		trx_dist,                                   			' ||
		'  	psa_mf_balances_view			mf_balances							' ||
		' Where trx_line.customer_trx_id	  	= :p_cust_trx_id_1                           			' ||
		' And   mf_balances.customer_trx_id		= :p_cust_trx_id_2						' ||
		' And	trx_line.customer_trx_line_id	  	= trx_dist.customer_trx_line_id        				' ||
		' And	trx_dist.cust_trx_line_gl_dist_id 	= mf_balances.cust_trx_line_gl_dist_id				' ||
		' And   trx_dist.account_class		       <> '''||'REC'||'''                                               ' ||
		' And   trx_line.customer_trx_line_id	  	= nvl(:p_cust_trx_line_id,trx_line.customer_trx_line_id) ';
    /*	' ||
		' And   EXISTS (SELECT 1 FROM ra_customer_trx_lines_all x							' ||
		'                WHERE x.customer_trx_line_id = trx_line.customer_trx_line_id AND NVL(extended_amount, 0) <> 0)	'; */


		IF l_total_amount_due < 0 THEN
		   l_c_accrual_stmt := l_c_accrual_stmt || ' order by 5 desc ';
		   l_c_cash_stmt    := l_c_cash_stmt || ' order by 5 desc ';

		ELSE
                   l_c_accrual_stmt := l_c_accrual_stmt || ' order by 5 asc ';
                   l_c_cash_stmt    := l_c_cash_stmt || ' order by 5 asc ';
		END IF;

                -- ========================= FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path,'  arp_global.sysparam.accounting_method --> '
                                                                ||  arp_global.sysparam.accounting_method);
                -- ========================= FND LOG ===========================

		IF arp_global.sysparam.accounting_method = 'ACCRUAL' THEN
		   OPEN c_accrual_cur FOR l_c_accrual_stmt USING l_zero_amt_flag, p_cust_trx_id, p_cust_trx_id, p_cust_trx_line_id;
		ELSIF arp_global.sysparam.accounting_method = 'CASH' THEN
		   OPEN c_accrual_cur FOR l_c_cash_stmt USING l_zero_amt_flag, p_cust_trx_id, p_cust_trx_id, p_cust_trx_line_id;
		END IF;


		LOOP
		   FETCH c_accrual_cur INTO l_accrual_rec;
		   EXIT WHEN c_accrual_cur%NOTFOUND;

                   -- ========================= FND LOG ===========================
                      psa_utils.debug_other_string(g_state_level,l_full_path,' l_accrual_rec.trx_line_dist_id --> ' || l_accrual_rec.trx_line_dist_id );
                   -- ========================= FND LOG ===========================

                   --
                   -- If Remittance MFAR distributions have already been created
                   -- applicable only for Receipts cleared by CashMgt
                   --

                   IF p_crh_status = 'CLEARED' AND NOT CASH_CLR_DIST_EXIST_VALID (p_rcv_app_id, p_amount_applied, 'REMITTED') THEN

                      OPEN   c_remit_reversal_account (l_accrual_rec.trx_line_dist_id);
                      FETCH  c_remit_reversal_account INTO l_remit_reversal_ccid;
                      CLOSE  c_remit_reversal_account;
                      -- ========================= FND LOG ===========================
                         psa_utils.debug_other_string(g_state_level,l_full_path,' l_remit_reversal_ccid --> ' || l_remit_reversal_ccid);
                      -- ========================= FND LOG ===========================
                   END IF;

                 -- ========================= FND LOG ===========================
                    psa_utils.debug_other_string(g_state_level,l_full_path,' p_document_type --> ' || p_document_type );
                 -- ========================= FND LOG ===========================

	           IF p_document_type  = 'CM' THEN
                      p_ccid := l_accrual_rec.rcv_ccid;
                      -- ========================= FND LOG ===========================
                         psa_utils.debug_other_string(g_state_level,l_full_path,' if cond - document type is CM --> ' ||  p_ccid);
                      -- ========================= FND LOG ===========================
	           ELSE
	              -- ========================= FND LOG ===========================
                         psa_utils.debug_other_string(g_state_level,l_full_path,' else cond - calling PSA_MFAR_UTILS.OVERRIDE_SEGMENTS ');
                      -- ========================= FND LOG ===========================

                      IF NOT ( PSA_MFAR_UTILS.OVERRIDE_SEGMENTS ( P_PRIMARY_CCID         => p_cash_ccid,
							          P_OVERRIDE_CCID        => l_accrual_rec.rcv_ccid,
							          P_SET_OF_BOOKS_ID      => g_set_of_books_id,
							          P_TRX_TYPE             => 'RCT',
							          P_CCID                 => p_ccid))   -- OUT
                      THEN
			 -- ========================= FND LOG ===========================
                            psa_utils.debug_other_string(g_state_level,l_full_path,' PSA_MFAR_UTILS.OVERRIDE_SEGMENTS -> FALSE ');
                         -- ========================= FND LOG ===========================
			       RAISE FLEX_BUILD_ERROR;
                      ELSE
			 -- ========================= FND LOG ===========================
                            psa_utils.debug_other_string(g_state_level,l_full_path,' p_ccid -> ' || p_ccid);
                         -- ========================= FND LOG ===========================
                      END IF;
		   END IF;

		   --
		   -- Prorate amount applied
		   --

		   IF  p_cust_trx_line_id Is NOT NULL THEN
                   -- ========================= FND LOG ===========================
                       psa_utils.debug_other_string(g_state_level,l_full_path,' p_cust_trx_line_id Is NOT NULL');
                   -- ========================= FND LOG ===========================

			IF  (p_cust_trx_line_id = l_accrual_rec.trx_line_id)
			AND NOT (l_running_total_amount_due = 0) THEN                 -- to avoid divide by zero error

			    l_amount_applied 		:= p_amount_applied - l_running_amount;
                            l_amount 			:= ROUND((l_amount_applied*l_accrual_rec.amount_due/l_running_total_amount_due), g_precision);

                            IF NVL(p_amount_applied,0) <> 0 THEN             --  Bug3884271
                               l_percent 		:= ROUND((l_amount/p_amount_applied*100), 4);
                            ELSE
                               l_percent                := 0;
                            END IF;

			    l_running_amount 		:= l_running_amount + l_amount;
			    l_running_total_amount_due 	:= l_running_total_amount_due - l_accrual_rec.amount_due;

                      -- ========================= FND LOG ===========================
                            psa_utils.debug_other_string(g_state_level,l_full_path,'  IF part ' ||
                                                                  ' ##l_amount_applied --> ' || l_amount_applied ||
                                                                  ' ##l_amount         --> ' || l_amount         ||
                                                                  ' ##l_percent        --> ' || l_percent        ||
                                                                  ' ##l_running_amount --> ' || l_running_amount ||
                                                                  ' ##l_running_total_amount_due --> ' || l_running_total_amount_due);
                      -- ========================= FND LOG ===========================

			ELSE

			    l_amount 	:= 0;
			    l_percent 	:= 0;
                      -- ========================= FND LOG ===========================
                         psa_utils.debug_other_string(g_state_level,l_full_path,'  ##l_amount  --> ' || l_amount || ' ##l_percent --> ' || l_percent);
                      -- ========================= FND LOG ===========================
                  END IF;
		 ELSE
                  -- ========================= FND LOG ===========================
                     psa_utils.debug_other_string(g_state_level,l_full_path,' p_cust_trx_line_id Is NULL');
                  -- ========================= FND LOG ===========================

			IF NOT (l_running_total_amount_due = 0) THEN -- to avoid divide by zero error

				l_amount_applied 		:= p_amount_applied - l_running_amount;
				l_amount 			:= ROUND((l_amount_applied*l_accrual_rec.amount_due/l_running_total_amount_due), g_precision);

                                IF NVL(p_amount_applied,0) <> 0 THEN   --  Bug3884271
                                   l_percent 	                := ROUND((l_amount/p_amount_applied*100), 4);
                                ELSE
                                   l_percent                    := 0;
                                END IF;

				l_running_amount 		:= l_running_amount + l_amount;
				l_running_total_amount_due 	:= l_running_total_amount_due - l_accrual_rec.amount_due;

                               -- ========================= FND LOG ===========================
                               psa_utils.debug_other_string(g_state_level,l_full_path,'  ELSE part ' ||
                                                          ' ##l_amount_applied --> ' || l_amount_applied   ||
                                                          ' ##l_amount         --> ' || l_amount           ||
                                                          ' ##l_percent        --> ' || l_percent          ||
                                                          ' ##l_running_amount --> ' || l_running_amount   ||
                                                          ' ##l_running_total_amount_due --> ' || l_running_total_amount_due);
                               -- ========================= FND LOG ===========================
                        END IF;
		   END IF;

		   --
		   -- Prorate earned/unearned discount
		   --

		   IF (p_earned_discount <> 0 OR p_unearned_discount <> 0) THEN

			IF  LINE_IN_DISCOUNT_CACHE (l_accrual_rec.trx_line_id) THEN

                           -- ========================= FND LOG ===========================
                           psa_utils.debug_other_string(g_state_level,l_full_path,' calling LINE_IN_DISCOUNT_CACHE --> ' || l_accrual_rec.trx_line_id);
                           psa_utils.debug_other_string(g_state_level,l_full_path,' prorate earned discount ');
                           -- ========================= FND LOG ===========================

			    --
			    -- Prorate Earned Discount
			    --

			    IF  (p_earned_discount <> 0)
			    AND NOT (l_running_total_amount_earn = 0) THEN  -- to avoid divide by zero error

			    	l_earn_discount_applied     := p_earned_discount - l_running_earned_discount;
			    	l_earned_discount	    := ROUND((l_earn_discount_applied*l_accrual_rec.amount_due/l_running_total_amount_earn),g_precision);
			    	l_running_earned_discount   := l_running_earned_discount + l_earned_discount;
			    	l_running_total_amount_earn := l_running_total_amount_earn - l_accrual_rec.amount_due;

                               -- ========================= FND LOG ===========================
                               psa_utils.debug_other_string(g_state_level,l_full_path,'  IF part ' ||
                                                                  ' ##l_earn_discount_applied     --> ' || l_earn_discount_applied   ||
                                                                  ' ##l_earned_discount           --> ' || l_earned_discount         ||
                                                                  ' ##l_running_earned_discount   --> ' || l_running_earned_discount ||
                                                                  ' ##l_running_total_amount_earn --> ' || l_running_total_amount_earn);
                               -- ========================= FND LOG ===========================

			    ELSE
			    	l_earned_discount := 0;
                        -- ========================= FND LOG ===========================
                           psa_utils.debug_other_string(g_state_level,l_full_path,
                                     '  ELSE part ##l_earned_discount           --> ' || l_earned_discount);
                        -- ========================= FND LOG ===========================
			    END IF;

			    --
			    -- Prorate Unearned Discount
			    --

                      -- ========================= FND LOG ===========================
                         psa_utils.debug_other_string(g_state_level,l_full_path,' prorate unearned discount ');
                      -- ========================= FND LOG ===========================

			    IF  p_unearned_discount <> 0
			    AND NOT (l_running_total_amount_unearn = 0) 	THEN -- to avoid divide by zero error

			    	l_unearn_discount_applied     := p_unearned_discount - l_running_unearn_discount;
			    	l_unearned_discount	      := ROUND((l_unearn_discount_applied*l_accrual_rec.amount_due/l_running_total_amount_unearn),g_precision);
			    	l_running_unearn_discount     := l_running_unearn_discount + l_unearned_discount;
			    	l_running_total_amount_unearn := l_running_total_amount_unearn - l_accrual_rec.amount_due;

                               -- ========================= FND LOG ===========================
                               psa_utils.debug_other_string(g_state_level,l_full_path,'  IF part ' ||
                                         ' ##l_earn_discount_applied     --> ' || l_earn_discount_applied    ||
                                         ' ##l_earned_discount           --> ' || l_earned_discount          ||
                                         ' ##l_running_earned_discount   --> ' || l_running_earned_discount  ||
                                         ' ##l_running_total_amount_earn --> ' || l_running_total_amount_earn);
                               -- ========================= FND LOG ===========================
			    ELSE
		                l_unearned_discount := 0;
                                -- ========================= FND LOG ===========================
                                psa_utils.debug_other_string(g_state_level,l_full_path,'  ELSE part ##l_unearned_discount           --> ' || l_unearned_discount);
                                -- ========================= FND LOG ===========================

			    END IF;

			    IF  p_earned_discount_ccid IS NOT NULL THEN
                                -- ========================= FND LOG ===========================
                                psa_utils.debug_other_string(g_state_level,l_full_path,
                                          '  calling  PSA_MFAR_UTILS.OVERRIDE_SEGMENTS for earned discount');
                                psa_utils.debug_other_string(g_state_level,l_full_path,'  p_earned_discount_ccid IS NOT NULL ');
                                psa_utils.debug_other_string(g_state_level,l_full_path,
                                          ' ##p_unearned_discount_ccid --> ' || p_unearned_discount_ccid  ||
                                          ' ##rcv_ccid  --> '                || l_accrual_rec.rcv_ccid    ||
                                          ' ##g_set_of_books_id --> '        || g_set_of_books_id         ||
                                          ' ##p_mf_earned_discount_ccid --> ' || p_mf_earned_discount_ccid);
                                -- ========================= FND LOG ===========================

				IF NOT ( PSA_MFAR_UTILS.OVERRIDE_SEGMENTS (p_earned_discount_ccid,
									   l_accrual_rec.rcv_ccid,
									   g_set_of_books_id,'RCT',
									   p_mf_earned_discount_ccid) )	THEN

                                   -- ========================= FND LOG ===========================
                                   psa_utils.debug_other_string(g_state_level,l_full_path,'  PSA_MFAR_UTILS.OVERRIDE_SEGMENTS -> FALSE');
                                   -- ========================= FND LOG ===========================
				   RAISE FLEX_BUILD_ERROR;
				END IF;
	                    ELSE
                                -- ========================= FND LOG ===========================
                                psa_utils.debug_other_string(g_state_level,l_full_path,'  p_earned_discount_ccid IS NULL ');
                                -- ========================= FND LOG ===========================
			    END IF;

			    IF  p_unearned_discount_ccid IS NOT NULL THEN
                          -- ========================= FND LOG ===========================
                             psa_utils.debug_other_string(g_state_level,l_full_path,
                                       '  calling  PSA_MFAR_UTILS.OVERRIDE_SEGMENTS for unearned discount');
                             psa_utils.debug_other_string(g_state_level,l_full_path,
                                       '  p_earned_discount_ccid IS NOT NULL ');
                             psa_utils.debug_other_string(g_state_level,l_full_path,
                                       '  ##p_unearned_discount_ccid --> ' || p_unearned_discount_ccid  ||
                                       '  ##rcv_ccid  --> '                || l_accrual_rec.rcv_ccid    ||
                                       '  ##g_set_of_books_id --> '        || g_set_of_books_id         ||
                                       '  ##p_mf_unearned_discount_ccid --> ' || p_mf_unearned_discount_ccid);
                          -- ========================= FND LOG ===========================

                          IF NOT ( PSA_MFAR_UTILS.OVERRIDE_SEGMENTS ( P_PRIMARY_CCID         => p_unearned_discount_ccid,
	                                                              P_OVERRIDE_CCID        => l_accrual_rec.rcv_ccid,
							              P_SET_OF_BOOKS_ID      => g_set_of_books_id,
							              P_TRX_TYPE             => 'RCT',
							              P_CCID                 => p_mf_unearned_discount_ccid))   -- OUT
                          THEN
			     -- ========================= FND LOG ===========================
                                psa_utils.debug_other_string(g_state_level,l_full_path,' PSA_MFAR_UTILS.OVERRIDE_SEGMENTS -> FALSE ');
                                psa_utils.debug_other_string(g_state_level,l_full_path,' Raising flex_build_error ');
                             -- ========================= FND LOG ===========================
			           RAISE FLEX_BUILD_ERROR;
                          ELSE
			     -- ========================= FND LOG ===========================
                                psa_utils.debug_other_string(g_state_level,l_full_path,
                                          ' p_mf_unearned_discount_ccid -> ' || p_mf_unearned_discount_ccid);
                             -- ========================= FND LOG ===========================
                          END IF;
                      END IF;
                  END IF;
		   END IF;

                   -- ========================= FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path,'  calling PSA_MFAR_RECEIPTS_COVER_PKG.INSERT_ROW');
                   -- ========================= FND LOG ===========================

		   --
		   -- Insert into psa_mf_rct_dist_all
		   --

		   PSA_MFAR_RECEIPTS_COVER_PKG.INSERT_ROW
		     (
		      x_rowid                     => l_rowid,
		      x_receivable_application_id => p_rcv_app_id,
		      x_cust_trx_line_gl_dist_id  => l_accrual_rec.trx_line_dist_id,
                      x_attribute_category        => NULL,
	   	      x_mf_cash_ccid 		  => p_ccid,
		      x_amount 		          => nvl(l_amount, 0),
		      x_percent			  => nvl(l_percent,0),
		      x_discount_ccid 		  => p_mf_earned_discount_ccid,
		      x_ue_discount_ccid          => p_mf_unearned_discount_ccid,
		      x_discount_amount           => nvl(l_earned_discount,0),
		      x_ue_discount_amount 	  => nvl(l_unearned_discount,0),
		      x_comments 		  => NULL,
                      x_posting_control_id        => NULL,
		      x_attribute1                => NULL,
		      x_attribute2                => NULL,
		      x_attribute3                => NULL,
		      x_attribute4                => NULL,
		      x_attribute5                => NULL,
		      x_attribute6                => NULL,
		      x_attribute7                => NULL,
		      x_attribute8                => NULL,
		      x_attribute9                => NULL,
		      x_attribute10               => NULL,
                      x_attribute11               => NULL,
		      x_attribute12               => NULL,
		      x_attribute13               => NULL,
		      x_attribute14               => NULL,
		      x_attribute15               => NULL,
              	      X_REFERENCE4                => NULL,
              	      X_REFERENCE5                => NULL,
              	      X_REFERENCE2                => NULL,
              	      X_REFERENCE1                => p_crh_status,
              	      X_REFERENCE3                => NULL,
              	      X_REVERSAL_CCID             => l_remit_reversal_ccid,
		      x_mode			  => 'R' );


		END LOOP;
		CLOSE c_accrual_cur;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,'  retcode --> ' || retcode );
           psa_utils.debug_other_string(g_state_level,l_full_path,'  RETURN TRUE ');
        -- ========================= FND LOG ===========================

        retcode := 'S';
        RETURN TRUE;


EXCEPTION
      -- Bug 3672756
      WHEN INVALID_DISTRIBUTION THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                         ' --> EXCEPTION - INVALID_DISTRIBUTION raised during PSA_MFAR_RECEIPTS.generate_rct_dist ');
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                         ' --> p_error_message  --> ' || l_exception_message);
         -- ========================= FND LOG ===========================
          p_error_message := l_exception_message;
          retcode := 'F';
          RETURN FALSE;

	WHEN FLEX_BUILD_ERROR THEN
         l_exception_message := fnd_message.get;
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                         ' --> EXCEPTION - FLEX_BUILD_ERROR raised during PSA_MFAR_RECEIPTS.generate_rct_dist ');
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                         ' --> p_error_message  --> ' || l_exception_message);
         -- ========================= FND LOG ===========================
          p_error_message := l_exception_message;
          retcode := 'F';
          RETURN FALSE;

	WHEN OTHERS THEN
          l_exception_message := l_exception_message || SQLCODE || ' - ' || SQLERRM;
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                         ' --> EXCEPTION - OTHERS raised during PSA_MFAR_RECEIPTS.generate_rct_dist ');
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                         ' --> p_error_message  --> ' || l_exception_message);
            psa_utils.debug_unexpected_msg(l_full_path);
         -- ========================= FND LOG ===========================
          p_error_message := l_exception_message;
          retcode := 'F';
          RETURN FALSE;

END generate_rct_dist;

/**************************************** GENERATE_RCT_DIST_CM ************************************/

FUNCTION generate_rct_dist_cm
		        (errbuf                         OUT NOCOPY VARCHAR2,
		         retcode                        OUT NOCOPY VARCHAR2,
			 p_rcv_app_id			IN	   NUMBER,
			 p_cash_ccid			IN 	   NUMBER,
			 p_cust_trx_id			IN 	   NUMBER,
			 p_cust_trx_line_id		IN	   NUMBER,
			 p_amount_applied1		IN	   NUMBER,
			 p_earned_discount		IN	   NUMBER,
			 p_unearned_discount		IN	   NUMBER,
			 p_earned_discount_ccid		IN	   NUMBER,
			 p_unearned_discount_ccid	IN	   NUMBER,
			 p_document_type		IN	   VARCHAR2,
                         p_crh_status                   IN         VARCHAR2 DEFAULT 'OTHER',
                         p_error_message                OUT NOCOPY VARCHAR2) RETURN BOOLEAN

IS

   CURSOR c_remit_reversal_account(p_gl_dist_id IN NUMBER) IS
    SELECT
     mf_cash_ccid
     FROM psa_mf_rct_dist_all
     WHERE receivable_application_id = p_rcv_app_id
     AND cust_trx_line_gl_dist_id = p_gl_dist_id;

--	l_accrual_rec			c_accrual%rowtype;
--	l_cash_rec			c_cash%rowtype;
	p_ccid				psa_mf_rct_dist_all.mf_cash_ccid%type;
	p_mf_earned_discount_ccid       ar_receivable_applications.earned_discount_ccid%type;
	p_mf_unearned_discount_ccid     ar_receivable_applications.unearned_discount_ccid%type;
	l_rowid				ROWID;
        run_num	                        number(15);

	l_c_accrual_stmt		VARCHAR2(6000);

	l_c_cash_stmt			VARCHAR2(6000);

	TYPE AccrualTyp IS RECORD (rcv_ccid		NUMBER(15),
				   trx_line_dist_id	NUMBER(15),
				   trx_line_id		NUMBER(15),
				   link_trx_line_id	NUMBER(15),
				   amount_due		NUMBER,
				   ACCOUNT_CLASS varchar2(100));

      TYPE var_cur IS REF CURSOR;

      c_accrual_cur VAR_CUR;
	l_accrual_rec AccrualTyp;

-- Variables for calculating amount and percent
    p_amount_applied		NUMBER;
	l_amount_applied		NUMBER;
	l_running_amount 		NUMBER;
	l_running_total_amount_due	NUMBER;
	l_total_amount_due		NUMBER;
	l_amount			NUMBER;
	l_percent			NUMBER;
	l_line_amount			NUMBER;
	l_tax_amount			NUMBER;

-- Variables for calculating earned discount

    	l_earn_discount_applied		NUMBER;
    	l_earned_discount	    	NUMBER;
    	l_running_earned_discount	NUMBER;
    	l_running_total_amount_earn	NUMBER;

-- Variables for calculating unearned discount

    	l_unearn_discount_applied     	NUMBER;
    	l_unearned_discount	      	NUMBER;
    	l_running_unearn_discount     	NUMBER;
    	l_running_total_amount_unearn 	NUMBER;
        l_count                         NUMBER;


	-- var added below by RM for 1604281
      sum_amt_due_rem number;
      l_remit_reversal_ccid NUMBER(15);

      l_exception_message varchar2(3000);
      l_retcode varchar2(1);
      l_errbuf  varchar2(100);

      FLEX_BUILD_ERROR		EXCEPTION;
      INVALID_DISTRIBUTION            EXCEPTION;

      -- ========================= FND LOG ===========================
         l_full_path VARCHAR2(100) := g_path || 'generate_rct_dist_cm';
      -- ========================= FND LOG ===========================

BEGIN

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' Start Generate_rct_dist_cm ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS');
     psa_utils.debug_other_string(g_state_level,l_full_path,' ==========');
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_rcv_app_id             -> ' || p_rcv_app_id);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_cash_ccid              -> ' || p_cash_ccid);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_cust_trx_id            -> ' || p_cust_trx_id);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_cust_trx_line_id       -> ' || p_cust_trx_line_id);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_amount_applied         -> ' || p_amount_applied);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_earned_discount        -> ' || p_earned_discount);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_unearned_discount      -> ' || p_unearned_discount);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_earned_discount_ccid   -> ' || p_earned_discount_ccid);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_unearned_discount_ccid -> ' || p_unearned_discount_ccid);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_document_type          -> ' || p_document_type);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_crh_status             -> ' || p_crh_status);
     psa_utils.debug_other_string(g_state_level,l_full_path,' Starting the process ');
  -- ========================= FND LOG ===========================

  -- Bug 2609367
  -- call psa_mfar_transactions.create_distributions
  -- When 'Create Distributions is run as a Conc. program OR invoked from the Action of opening MFAR Form,
  -- PSA_MF_CREATE_DISTRIBUTIONS package is called. This makes sure that MFAR distributions for a Transaction
  --  is created before proceeding to create Distributions for Receipts etc.
  -- However, MFAR dist. for a Trx is not created when GL Xfr is executed for a Cash Receipt whose GL Date is
  -- different from the transaction AND when MFAR for the Trx has not been created through the other means.

    select psa_mF_error_log_s.currval
    into run_num
    from sys.dual;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' Creating distribution for Cust trx id ==> ' || run_num || ' -- ' || p_cust_trx_id);
    -- ========================= FND LOG ===========================

    IF NOT (PSA_MFAR_TRANSACTIONS.create_distributions (
                                                     errbuf            => l_errbuf,
                                                     retcode           => l_retcode,
                                                     p_cust_trx_id     => p_cust_trx_id,
                                                     p_set_of_books_id => g_set_of_books_id,
                                                     p_run_id          => run_num,
                                                     p_error_message   => l_exception_message)) THEN

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,' PSA_MFAR_TRANSACTIONS.create_distributions --> FALSE');
        -- ========================= FND LOG ===========================
        IF l_exception_message IS NOT NULL OR l_retcode = 'F' THEN
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,' Raising  invalid_distribution');
           -- ========================= FND LOG ===========================
           Raise invalid_distribution;
        END IF;
     ELSE
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,' cust_trx_id --> ' || p_cust_trx_id);
           -- ========================= FND LOG ===========================
     END IF;

     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,' p_earned_discount   --> ' || p_earned_discount );
        psa_utils.debug_other_string(g_state_level,l_full_path,' p_unearned_discount --> ' || p_unearned_discount );
     -- ========================= FND LOG ===========================

     IF (p_earned_discount <> 0 OR p_unearned_discount <> 0) THEN
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,' Calling populate_discount_cache --> ' || p_cust_trx_id);
        -- ========================= FND LOG ===========================
	  POPULATE_DISCOUNT_LINES_CACHE (p_cust_trx_id);
     END IF;

     SELECT
	     decode (sum(mf_balances.amount_due_remaining),0,
                   sum(mf_balances.amount_due_original),
                   sum(mf_balances.amount_due_original)) total_amount_due,
	             sum(mf_balances.amount_due_original) sum_amt_due_rem
     INTO  l_total_amount_due,
           sum_amt_due_rem
     FROM  ra_customer_trx_lines_all	 trx_line,
           ra_cust_trx_line_gl_dist_all     trx_dist,
           psa_mf_balances_view	         mf_balances
     WHERE trx_line.customer_trx_id	           = p_cust_trx_id
     AND   mf_balances.customer_trx_id	     = p_cust_trx_id
     AND   trx_line.customer_trx_line_id      = trx_dist.customer_trx_line_id
     AND   trx_dist.cust_trx_line_gl_dist_id  = mf_balances.cust_trx_line_gl_dist_id
     AND   trx_line.customer_trx_line_id       = nvl(p_cust_trx_line_id, trx_line.customer_trx_line_id);

     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,' l_total_amount_due --> ' || l_total_amount_due );
        psa_utils.debug_other_string(g_state_level,l_full_path,' sum_amt_due_rem    --> ' || sum_amt_due_rem    );
     -- ========================= FND LOG ===========================

     --
     -- Initailize variables for running total
     --

                l_running_amount 	         := 0;
		l_running_total_amount_due :=  l_total_amount_due ;

	    	l_running_earned_discount   := 0;
	    	l_running_total_amount_earn := l_total_amount_due;

	    	l_running_unearn_discount     := 0;
	    	l_running_total_amount_unearn := l_total_amount_due;

	--Adi --


   -- get the line amount and tax amount seperately
   -- for each receivable application ids

	 SELECT  -1*LINE_Applied , -1*TAX_Applied
	   INTO  l_line_amount, l_tax_amount
       FROM  ar_receivable_applications_all		app
      WHERE  app.receivable_application_id	= p_rcv_app_id
        AND	 app.status		 	= 'APP';


                -- ========================= FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path,' l_running_total_amount_due    --> ' || l_running_total_amount_due );
                   psa_utils.debug_other_string(g_state_level,l_full_path,' l_running_total_amount_earn   --> ' || l_running_total_amount_earn);
                   psa_utils.debug_other_string(g_state_level,l_full_path,' l_running_total_amount_unearn --> ' || l_running_total_amount_unearn);
               -- ========================= FND LOG ===========================

		l_c_accrual_stmt :=
		'Select	mf_trx_dist.mf_receivables_ccid		rcv_ccid,							' ||
		'	mf_trx_dist.cust_trx_line_gl_dist_id	trx_line_dist_id,                      				' ||
		'	trx_line.customer_trx_line_id		trx_line_id,                                 			' ||
		'	trx_line.link_to_cust_trx_line_id	link_trx_line_id,						' ||
	--	'	decode (:sum_adr, 0, mf_balances.amount_due_original, mf_balances.amount_due_remaining)	amount_due,	' ||
		'	decode (:sum_adr, 0, mf_balances.amount_due_original, mf_balances.amount_due_original)	amount_due,	'||
			'   trx_dist.account_class  account_class ' ||
		'  From ra_customer_trx_lines			trx_line,                              				' ||
		'  	ra_cust_trx_line_gl_dist		trx_dist,                                   			' ||
		'  	psa_mf_trx_dist_all			mf_trx_dist,							' ||
		'  	psa_mf_balances_view			mf_balances							' ||
		' Where trx_line.customer_trx_id	  	= :p_cust_trx_id_1                           			' ||
		' And   mf_balances.customer_trx_id		= :p_cust_trx_id_2						' ||
		' And	trx_line.customer_trx_line_id	  	= trx_dist.customer_trx_line_id        				' ||
		' And	trx_dist.cust_trx_line_gl_dist_id 	= mf_trx_dist.cust_trx_line_gl_dist_id				' ||
		' And	mf_trx_dist.cust_trx_line_gl_dist_id 	= mf_balances.cust_trx_line_gl_dist_id				' ||
		' And   trx_line.customer_trx_line_id	  	= nvl(:p_cust_trx_line_id,trx_line.customer_trx_line_id) ';

		l_c_cash_stmt :=
		'Select	trx_dist.code_combination_id		rcv_ccid,							' ||
		'	trx_dist.cust_trx_line_gl_dist_id	trx_line_dist_id,                      				' ||
		'	trx_line.customer_trx_line_id		trx_line_id,                                 			' ||
		'	trx_line.link_to_cust_trx_line_id	link_trx_line_id,						' ||
--		'	decode (:sum_adr, 0, mf_balances.amount_due_original, mf_balances.amount_due_remaining)	amount_due,	'||
		'	decode (:sum_adr, 0, mf_balances.amount_due_original, mf_balances.amount_due_original)	amount_due,	'||
		'   trx_dist.account_class  account_class' ||
		'  From ra_customer_trx_lines			trx_line,                              				' ||
		'  	ra_cust_trx_line_gl_dist		trx_dist,                                   			' ||
		'  	psa_mf_balances_view			mf_balances							' ||
		' Where trx_line.customer_trx_id	  	= :p_cust_trx_id_1                           			' ||
		' And   mf_balances.customer_trx_id		= :p_cust_trx_id_2						' ||
		' And	trx_line.customer_trx_line_id	  	= trx_dist.customer_trx_line_id        				' ||
		' And	trx_dist.cust_trx_line_gl_dist_id 	= mf_balances.cust_trx_line_gl_dist_id				' ||
		' And   trx_dist.account_class		       <> '''||'REC'||'''                                               ' ||
		' And   trx_line.customer_trx_line_id	  	= nvl(:p_cust_trx_line_id,trx_line.customer_trx_line_id) ';


		IF l_total_amount_due < 0 THEN
		   l_c_accrual_stmt := l_c_accrual_stmt || ' order by 6,5 desc ';
		   l_c_cash_stmt    := l_c_cash_stmt || ' order by 6,5 desc ';

		ELSE
                   l_c_accrual_stmt := l_c_accrual_stmt || ' order by 6,5 asc ';
                   l_c_cash_stmt    := l_c_cash_stmt || ' order by 6,5 asc ';
		END IF;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,'  arp_global.sysparam.accounting_method --> '
                                                                ||  arp_global.sysparam.accounting_method);
        -- ========================= FND LOG ===========================

		IF arp_global.sysparam.accounting_method = 'ACCRUAL' THEN
		   OPEN c_accrual_cur FOR l_c_accrual_stmt
                  USING sum_amt_due_rem, p_cust_trx_id, p_cust_trx_id, p_cust_trx_line_id;
		ELSIF arp_global.sysparam.accounting_method = 'CASH' THEN
		   OPEN c_accrual_cur FOR l_c_cash_stmt
                  USING sum_amt_due_rem, p_cust_trx_id, p_cust_trx_id, p_cust_trx_line_id;
		END IF;



        -- Get the count of REVENUE lines

          SELECT  count(1)
            INTO  l_count
            FROM  ra_customer_trx_lines                   trx_line,
                  ra_cust_trx_line_gl_dist                trx_dist,
                  psa_mf_trx_dist_all                     mf_trx_dist
           WHERE  trx_line.customer_trx_id              = p_cust_trx_id
             AND  trx_dist.account_class                = 'REV'
             AND  trx_line.customer_trx_line_id         = trx_dist.customer_trx_line_id
             AND  trx_dist.cust_trx_line_gl_dist_id     = mf_trx_dist.cust_trx_line_gl_dist_id
             AND  trx_line.customer_trx_line_id         = nvl(p_cust_trx_line_id,trx_line.customer_trx_line_id);



		LOOP
		   FETCH c_accrual_cur INTO l_accrual_rec;
		   EXIT WHEN c_accrual_cur%NOTFOUND;

		   IF l_accrual_rec.ACCOUNT_CLASS = 'REV' THEN
		       p_amount_applied := l_line_amount;
		   ELSIF l_accrual_rec.ACCOUNT_CLASS = 'TAX' THEN
                       p_amount_applied := l_tax_amount;
                   END IF;

                   -- ========================= FND LOG ===========================
                      psa_utils.debug_other_string(g_state_level,l_full_path,
                        ' l_accrual_rec.trx_line_dist_id --> ' || l_accrual_rec.trx_line_dist_id );
                   -- ========================= FND LOG ===========================

                   --
                   -- If Remittance MFAR distributions have already been created
                   -- applicable only for Receipts cleared by CashMgt
                   --

                   IF p_crh_status = 'CLEARED' AND NOT
			CASH_CLR_DIST_EXIST_VALID (p_rcv_app_id, p_amount_applied, 'REMITTED') THEN

                      OPEN   c_remit_reversal_account (l_accrual_rec.trx_line_dist_id);
                      FETCH  c_remit_reversal_account INTO l_remit_reversal_ccid;
                      CLOSE  c_remit_reversal_account;
                      -- ========================= FND LOG ===========================
                         psa_utils.debug_other_string(g_state_level,l_full_path,
				' l_remit_reversal_ccid --> ' || l_remit_reversal_ccid);
                      -- ========================= FND LOG ===========================
                   END IF;

                 -- ========================= FND LOG ===========================
                    psa_utils.debug_other_string(g_state_level,l_full_path,' p_document_type -->
			' || p_document_type );
                 -- ========================= FND LOG ===========================

                      p_ccid := l_accrual_rec.rcv_ccid;
                      -- ========================= FND LOG ===========================
                         psa_utils.debug_other_string(g_state_level,l_full_path,
				' if cond - document type is CM --> ' ||  p_ccid);
                      -- ========================= FND LOG ===========================
		   --
		   -- Prorate amount applied
		   --

		   IF  p_cust_trx_line_id Is NOT NULL THEN
                   -- ========================= FND LOG ===========================
                       psa_utils.debug_other_string(g_state_level,l_full_path,' p_cust_trx_line_id Is NOT NULL');
                   -- ========================= FND LOG ===========================

			IF  (p_cust_trx_line_id = l_accrual_rec.trx_line_id)
			AND NOT (l_running_total_amount_due = 0) THEN        -- to avoid divide by zero error



		--	    l_amount_applied 		:= p_amount_applied - l_running_amount;
                            l_amount 			:= ROUND((p_amount_applied*l_accrual_rec.amount_due/l_running_total_amount_due), g_precision);

			      -- ========================= FND LOG ===========================
                            psa_utils.debug_other_string(g_state_level,l_full_path,' In IF  ' ||
                                   ' ##p_amount_applied --> ' || p_amount_applied ||
                                   ' ##l_amount_applied --> ' || l_amount_applied ||
                                   ' ##l_amount         --> ' || l_amount         ||
                                   ' ##l_accrual_rec.amount_due --> ' || l_accrual_rec.amount_due ||
                                   ' ##l_running_total_amount_due --> ' || l_running_total_amount_due);
                      -- ========================= FND LOG ===========================
                            IF NVL(p_amount_applied,0) <> 0 THEN             --  Bug3884271
                           l_percent 		:= ROUND((l_amount/p_amount_applied*100), 4);


                            ELSE
                               l_percent                := 0;
                            END IF;

			    l_running_amount 		:= l_running_amount + l_amount;
			--    l_running_total_amount_due 	:= l_running_total_amount_due - l_accrual_rec.amount_due;

                      -- ========================= FND LOG ===========================
                            psa_utils.debug_other_string(g_state_level,l_full_path,'  IF part ' ||
                                    ' ##l_amount_applied --> ' || l_amount_applied ||
                                    ' ##l_amount         --> ' || l_amount         ||
                                    ' ##l_percent        --> ' || l_percent        ||
                                    ' ##l_running_amount --> ' || l_running_amount ||
                                    ' ##l_running_total_amount_due --> ' || l_running_total_amount_due);
                      -- ========================= FND LOG ===========================

			ELSE

			    l_amount 	:= 0;
			    l_percent 	:= 0;
                      -- ========================= FND LOG ===========================
                         psa_utils.debug_other_string(g_state_level,l_full_path,'  ##l_amount  --> ' || l_amount || ' ##l_percent --> ' || l_percent);
                      -- ========================= FND LOG ===========================
                  END IF;
		 ELSE
                  -- ========================= FND LOG ===========================
                     psa_utils.debug_other_string(g_state_level,l_full_path,' p_cust_trx_line_id Is NULL');
                  -- ========================= FND LOG ===========================

			IF NOT (l_running_total_amount_due = 0) THEN -- to avoid divide by zero error

			--	l_amount_applied 		:= p_amount_applied - l_running_amount;
				l_amount 			:= ROUND((p_amount_applied*l_accrual_rec.amount_due/l_running_total_amount_due), g_precision);

                                IF NVL(p_amount_applied,0) <> 0 THEN   --  Bug3884271
                                   l_percent 	                := ROUND((l_amount/p_amount_applied*100), 4);
                                ELSE
                                   l_percent                    := 0;
                                END IF;

				l_running_amount 		:= l_running_amount + l_amount;
		--		l_running_total_amount_due 	:= l_running_total_amount_due - l_accrual_rec.amount_due;

                               -- ========================= FND LOG ===========================
                               psa_utils.debug_other_string(g_state_level,l_full_path,'  ELSE part ' ||
                                        ' ##l_amount_applied --> ' || l_amount_applied   ||
                                        ' ##l_amount         --> ' || l_amount           ||
                                        ' ##l_percent        --> ' || l_percent          ||
                                        ' ##l_running_amount --> ' || l_running_amount   ||
                                        ' ##l_running_total_amount_due --> ' || l_running_total_amount_due);
                               -- ========================= FND LOG ===========================
                        END IF;
		   END IF;

		   --
		   -- Prorate earned/unearned discount
		   --

		   IF (p_earned_discount <> 0 OR p_unearned_discount <> 0) THEN

			IF  LINE_IN_DISCOUNT_CACHE (l_accrual_rec.trx_line_id) THEN

                           -- ========================= FND LOG ===========================
                           psa_utils.debug_other_string(g_state_level,l_full_path,' calling LINE_IN_DISCOUNT_CACHE --> ' || l_accrual_rec.trx_line_id);
                           psa_utils.debug_other_string(g_state_level,l_full_path,' prorate earned discount ');
                           -- ========================= FND LOG ===========================

			    --
			    -- Prorate Earned Discount
			    --

			    IF  (p_earned_discount <> 0)
			    AND NOT (l_running_total_amount_earn = 0) THEN  -- to avoid divide by zero error

			--    	l_earn_discount_applied     := p_earned_discount - l_running_earned_discount;
			    --	l_earned_discount	    := ROUND((l_earn_discount_applied*l_accrual_rec.amount_due/l_running_total_amount_earn),4);
			    l_earned_discount	    := ROUND((p_earned_discount*l_accrual_rec.amount_due/l_running_total_amount_earn),g_precision);
			 --   	l_running_earned_discount   := l_running_earned_discount + l_earned_discount;
			 --   	l_running_total_amount_earn := l_running_total_amount_earn - l_accrual_rec.amount_due;

                               -- ========================= FND LOG ===========================
                               psa_utils.debug_other_string(g_state_level,l_full_path,'  IF part ' ||
                                         ' ##l_earn_discount_applied     --> ' || l_earn_discount_applied   ||
                                         ' ##l_earned_discount           --> ' || l_earned_discount         ||
                                         ' ##l_running_earned_discount   --> ' || l_running_earned_discount ||
                                         ' ##l_running_total_amount_earn --> ' || l_running_total_amount_earn);
                               -- ========================= FND LOG ===========================

			    ELSE
			    	l_earned_discount := 0;
                        -- ========================= FND LOG ===========================
                           psa_utils.debug_other_string(g_state_level,l_full_path,
                                     '  ELSE part ##l_earned_discount           --> ' || l_earned_discount);
                        -- ========================= FND LOG ===========================
			    END IF;

			    --
			    -- Prorate Unearned Discount
			    --

                      -- ========================= FND LOG ===========================
                         psa_utils.debug_other_string(g_state_level,l_full_path,' prorate unearned discount ');
                      -- ========================= FND LOG ===========================

			    IF  p_unearned_discount <> 0
			    AND NOT (l_running_total_amount_unearn = 0) 	THEN -- to avoid divide by zero error

    --			    l_unearn_discount_applied     := p_unearned_discount - l_running_unearn_discount;
	--		    l_unearned_discount	      := ROUND((l_unearn_discount_applied*l_accrual_rec.amount_due/l_running_total_amount_unearn),2);
			    l_unearned_discount	      := ROUND((p_unearned_discount*l_accrual_rec.amount_due/l_running_total_amount_unearn),g_precision);
	--		    l_running_unearn_discount     := l_running_unearn_discount + l_unearned_discount;
	--		    l_running_total_amount_unearn := l_running_total_amount_unearn - l_accrual_rec.amount_due;

                               -- ========================= FND LOG ===========================
                               psa_utils.debug_other_string(g_state_level,l_full_path,'  IF part ' ||
                                         ' ##l_earn_discount_applied     --> ' || l_earn_discount_applied    ||
                                         ' ##l_earned_discount           --> ' || l_earned_discount          ||
                                         ' ##l_running_earned_discount   --> ' || l_running_earned_discount  ||
                                         ' ##l_running_total_amount_earn --> ' || l_running_total_amount_earn);
                               -- ========================= FND LOG ===========================
			    ELSE
		                l_unearned_discount := 0;
                                -- ========================= FND LOG ===========================
                                psa_utils.debug_other_string(g_state_level,l_full_path,'  ELSE part ##l_unearned_discount           --> ' || l_unearned_discount);
                                -- ========================= FND LOG ===========================

			    END IF;

			    IF  p_earned_discount_ccid IS NOT NULL THEN
                                -- ========================= FND LOG ===========================
                                psa_utils.debug_other_string(g_state_level,l_full_path,
                                          '  calling  PSA_MFAR_UTILS.OVERRIDE_SEGMENTS for earned discount');
                                psa_utils.debug_other_string(g_state_level,l_full_path,'  p_earned_discount_ccid IS NOT NULL ');
                                psa_utils.debug_other_string(g_state_level,l_full_path,
                                          ' ##p_unearned_discount_ccid --> ' || p_unearned_discount_ccid  ||
                                          ' ##rcv_ccid  --> '                || l_accrual_rec.rcv_ccid    ||
                                          ' ##g_set_of_books_id --> '        || g_set_of_books_id         ||
                                          ' ##p_mf_earned_discount_ccid --> ' || p_mf_earned_discount_ccid);
                                -- ========================= FND LOG ===========================

				IF NOT ( PSA_MFAR_UTILS.OVERRIDE_SEGMENTS (p_earned_discount_ccid,
									   l_accrual_rec.rcv_ccid,
									   g_set_of_books_id,'RCT',
									   p_mf_earned_discount_ccid) )	THEN

                                   -- ========================= FND LOG ===========================
                                   psa_utils.debug_other_string(g_state_level,l_full_path,'  PSA_MFAR_UTILS.OVERRIDE_SEGMENTS -> FALSE');
                                   -- ========================= FND LOG ===========================
				   RAISE FLEX_BUILD_ERROR;
				END IF;
	                    ELSE
                                -- ========================= FND LOG ===========================
                                psa_utils.debug_other_string(g_state_level,l_full_path,'  p_earned_discount_ccid IS NULL ');
                                -- ========================= FND LOG ===========================
			    END IF;

			    IF  p_unearned_discount_ccid IS NOT NULL THEN
                          -- ========================= FND LOG ===========================
                             psa_utils.debug_other_string(g_state_level,l_full_path,
                                       '  calling  PSA_MFAR_UTILS.OVERRIDE_SEGMENTS for unearned discount');
                             psa_utils.debug_other_string(g_state_level,l_full_path,
                                       '  p_earned_discount_ccid IS NOT NULL ');
                             psa_utils.debug_other_string(g_state_level,l_full_path,
                                       '  ##p_unearned_discount_ccid --> ' || p_unearned_discount_ccid  ||
                                       '  ##rcv_ccid  --> '                || l_accrual_rec.rcv_ccid    ||
                                       '  ##g_set_of_books_id --> '        || g_set_of_books_id         ||
                                       '  ##p_mf_unearned_discount_ccid --> ' || p_mf_unearned_discount_ccid);
                          -- ========================= FND LOG ===========================

                          IF NOT ( PSA_MFAR_UTILS.OVERRIDE_SEGMENTS ( P_PRIMARY_CCID         => p_unearned_discount_ccid,
	                                                              P_OVERRIDE_CCID        => l_accrual_rec.rcv_ccid,
							              P_SET_OF_BOOKS_ID      => g_set_of_books_id,
							              P_TRX_TYPE             => 'RCT',
							              P_CCID                 => p_mf_unearned_discount_ccid))   -- OUT
                          THEN
			     -- ========================= FND LOG ===========================
                                psa_utils.debug_other_string(g_state_level,l_full_path,' PSA_MFAR_UTILS.OVERRIDE_SEGMENTS -> FALSE ');
                                psa_utils.debug_other_string(g_state_level,l_full_path,' Raising flex_build_error ');
                             -- ========================= FND LOG ===========================
			           RAISE FLEX_BUILD_ERROR;
                          ELSE
			     -- ========================= FND LOG ===========================
                                psa_utils.debug_other_string(g_state_level,l_full_path,
                                          ' p_mf_unearned_discount_ccid -> ' || p_mf_unearned_discount_ccid);
                             -- ========================= FND LOG ===========================
                          END IF;
                      END IF;
                  END IF;
		   END IF;

                   -- ========================= FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path,'  calling PSA_MFAR_RECEIPTS_COVER_PKG.INSERT_ROW');
                   -- ========================= FND LOG ===========================

		   --
		   -- Insert into psa_mf_rct_dist_all
		   --

                        IF l_count = 1 THEN

				l_amount := -1*(-1*p_amount_applied - (-1*l_running_amount - (-1*l_amount)));

                           -- ========================= FND LOG ===========================
                              psa_utils.debug_other_string(g_state_level,l_full_path,
                                    '  l_amount -> ' ||l_amount);
                           -- ========================= FND LOG ===========================
                        END IF;

   IF nvl(l_amount, 0) <> 0  THEN
		   PSA_MFAR_RECEIPTS_COVER_PKG.INSERT_ROW
		     (
		      x_rowid                     => l_rowid,
		      x_receivable_application_id => p_rcv_app_id,
		      x_cust_trx_line_gl_dist_id  => l_accrual_rec.trx_line_dist_id,
                      x_attribute_category        => NULL,
	   	      x_mf_cash_ccid 		  => p_ccid,
		      x_amount 		          => nvl(l_amount, 0),
		      x_percent			  => nvl(l_percent,0),
		      x_discount_ccid 		  => p_mf_earned_discount_ccid,
		      x_ue_discount_ccid          => p_mf_unearned_discount_ccid,
		      x_discount_amount           => nvl(l_earned_discount,0),
		      x_ue_discount_amount 	  => nvl(l_unearned_discount,0),
		      x_comments 		  => NULL,
                      x_posting_control_id        => NULL,
		      x_attribute1                => NULL,
		      x_attribute2                => NULL,
		      x_attribute3                => NULL,
		      x_attribute4                => NULL,
		      x_attribute5                => NULL,
		      x_attribute6                => NULL,
		      x_attribute7                => NULL,
		      x_attribute8                => NULL,
		      x_attribute9                => NULL,
		      x_attribute10               => NULL,
                      x_attribute11               => NULL,
		      x_attribute12               => NULL,
		      x_attribute13               => NULL,
		      x_attribute14               => NULL,
		      x_attribute15               => NULL,
              	      X_REFERENCE4                => NULL,
              	      X_REFERENCE5                => NULL,
              	      X_REFERENCE2                => NULL,
              	      X_REFERENCE1                => p_crh_status,
              	      X_REFERENCE3                => NULL,
              	      X_REVERSAL_CCID             => l_remit_reversal_ccid,
		      x_mode			  => 'R' );

                   IF l_count > 0  THEN
                      l_count := l_count - 1;
                   END IF;
   END IF;

		END LOOP;
		CLOSE c_accrual_cur;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,'  retcode --> ' || retcode );
           psa_utils.debug_other_string(g_state_level,l_full_path,'  RETURN TRUE ');
        -- ========================= FND LOG ===========================

        retcode := 'S';
        RETURN TRUE;


EXCEPTION
      -- Bug 3672756
      WHEN INVALID_DISTRIBUTION THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                         ' --> EXCEPTION - INVALID_DISTRIBUTION raised during PSA_MFAR_RECEIPTS.generate_rct_dist ');
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                         ' --> p_error_message  --> ' || l_exception_message);
         -- ========================= FND LOG ===========================
          p_error_message := l_exception_message;
          retcode := 'F';
          RETURN FALSE;

	WHEN FLEX_BUILD_ERROR THEN
         l_exception_message := fnd_message.get;
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                         ' --> EXCEPTION - FLEX_BUILD_ERROR raised during PSA_MFAR_RECEIPTS.generate_rct_dist ');
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                         ' --> p_error_message  --> ' || l_exception_message);
         -- ========================= FND LOG ===========================
          p_error_message := l_exception_message;
          retcode := 'F';
          RETURN FALSE;

	WHEN OTHERS THEN
          l_exception_message := l_exception_message || SQLCODE || ' - ' || SQLERRM;
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                         ' --> EXCEPTION - OTHERS raised during PSA_MFAR_RECEIPTS.generate_rct_dist ');
            psa_utils.debug_other_string(g_excep_level,l_full_path,
                                         ' --> p_error_message  --> ' || l_exception_message);
            psa_utils.debug_unexpected_msg(l_full_path);
         -- ========================= FND LOG ===========================
          p_error_message := l_exception_message;
          retcode := 'F';
          RETURN FALSE;

END generate_rct_dist_cm;


/**************************** PURGE_ORPHAN_DISTRIBUTIONS *******************************************/

PROCEDURE purge_orphan_distributions
IS

 CURSOR c_invalid_distributions
 IS
  SELECT distinct app.receivable_application_id	rcv_app_id
  FROM   ar_receivable_applications	app,
         psa_mf_rct_dist_all		mf_dist
  WHERE	 app.receivable_application_id 	= mf_dist.receivable_application_id
  AND    (NOT(app.status = 'APP'));
  -- Commented out by RM to fix 1604281
  -- OR not(app.display = 'Y')


  l_invalid_distributions_rec	c_invalid_distributions%rowtype;
  -- ========================= FND LOG ===========================
  l_full_path VARCHAR2(100) := g_path || 'purge_orphan_distributions';
  -- ========================= FND LOG ===========================

BEGIN

  -- ========================= FND LOG ===========================
  psa_utils.debug_other_string(g_state_level,l_full_path,' Purge_orphan_distributions : --> START');
  -- ========================= FND LOG ===========================

  OPEN c_invalid_distributions;
  LOOP
    FETCH c_invalid_distributions INTO l_invalid_distributions_rec;
    EXIT WHEN c_invalid_distributions%NOTFOUND;

    -- ========================= FND LOG ===========================
    psa_utils.debug_other_string(g_state_level,l_full_path,' Purge_orphan_distributions : --> deleting ' || l_invalid_distributions_rec.rcv_app_id);
    -- ========================= FND LOG ===========================

    DELETE FROM psa_mf_rct_dist_all
    WHERE  receivable_application_id = l_invalid_distributions_rec.rcv_app_id;

    -- ========================= FND LOG ===========================
    psa_utils.debug_other_string(g_state_level,l_full_path,' Purge_orphan_distributions : --> rows ' || SQL%ROWCOUNT);
    -- ========================= FND LOG ===========================

  END LOOP;
  CLOSE c_invalid_distributions;

  -- ========================= FND LOG ===========================
  psa_utils.debug_other_string(g_state_level,l_full_path,' Purge_orphan_distributions : --> END');
  -- ========================= FND LOG ===========================

EXCEPTION
  WHEN OTHERS THEN
    l_exception_message := 'EXCEPTION - OTHERS PACKAGE - PSA_MFAR_RECEIPTS.PURGE_ORPHAN_DISTRIBUTIONS: '||sqlerrm;
    PSA_MFAR_UTILS.INSERT_DISTRIBUTIONS_LOG (g_run_id, 'RECEIPT', g_cust_trx_id, g_receivable_application_id,
	  			             l_exception_message);
    -- ========================= FND LOG ===========================
    psa_utils.debug_other_string(g_excep_level,l_full_path,l_exception_message);
    psa_utils.debug_unexpected_msg(l_full_path);
    -- ========================= FND LOG ===========================

END purge_orphan_distributions;

/**************************** POPULATE_DISCOUNT_LINES_CACHE *******************************************/

PROCEDURE populate_discount_lines_cache (p_customer_trx_id IN NUMBER)
IS

 CURSOR c_variables
 IS
  SELECT terms.calc_discount_on_lines_flag	discount_basis,
         trx.created_from			created_from
  FROM   ra_customer_trx trx,
	 ra_terms_b terms
  WHERE  trx.customer_trx_id = p_customer_trx_id
  AND	 trx.term_id	     = terms.term_id;

  l_variables_rec c_variables%rowtype;
  -- ========================= FND LOG ===========================
  l_full_path VARCHAR2(100) := g_path || 'populate_discount_lines_cache';
  -- ========================= FND LOG ===========================

BEGIN


  -- ========================= FND LOG ===========================
  psa_utils.debug_other_string(g_state_level,l_full_path,' Populate_discount_lines_cache : --> START');
  -- ========================= FND LOG ===========================

  OPEN  c_variables;
  FETCH c_variables INTO l_variables_rec;
  CLOSE c_variables;

  -- ========================= FND LOG ===========================
  psa_utils.debug_other_string(g_state_level,l_full_path,' Populate_discount_lines_cache : Created form --> ' || l_variables_rec.created_from);
  -- ========================= FND LOG ===========================

	--
	-- For a transaction created manually, "discount basis" is taken into
	-- account while prorating the discount amount among the distributions
	--
	-- Discount Basis: 'I' - Invoice Amount
	--		   'L' - Lines Only
	--		   'T' - Lines, Freight Items and Tax
	--		   'F' - Lines and Tax, not freight items and tax
	--
	-- For an imported transaction,
	-- 	a. "discount basis"
	-- 	b. Order Entry (OE) profile "TAX: Inventory Item for Freight"
	-- Example:
	-- If "TAX: Inventory Item for Freight" is not defined or null
	-- The freight item line created by autoinvoice is not included while
	-- prorating the discount amount.
	--

   IF l_variables_rec.created_from = 'RAXTRX' THEN		-- IMPORTED THRU' AUTOINVOICE
      IMPORTED_TRANSACTION (p_customer_trx_id, l_variables_rec.discount_basis);
      -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' Populate_discount_lines_cache : imported trans  --> ##p_customer_trx_id --> ' || p_customer_trx_id || ' ##discount_basis --> ' || l_variables_rec.discount_basis);
      -- ========================= FND LOG ===========================

   ELSE
      MANUAL_TRANSACTION (p_customer_trx_id, l_variables_rec.discount_basis);
      -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' Populate_discount_lines_cache : manual trans  --> ##p_customer_trx_id --> ' || p_customer_trx_id || ' ##discount_basis --> ' || l_variables_rec.discount_basis);
      -- ========================= FND LOG ===========================
   END IF;

EXCEPTION
	WHEN OTHERS THEN
          l_exception_message := 'EXCEPTION - OTHERS PACKAGE - PSA_MFAR_RECEIPTS.POPULATE_DISCOUNT_LINES_CACHE: '||sqlerrm;
	  PSA_MFAR_UTILS.INSERT_DISTRIBUTIONS_LOG (g_run_id, 'RECEIPT', g_cust_trx_id, g_receivable_application_id,
	  			                   l_exception_message);
          -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_excep_level,l_full_path,l_exception_message);
          psa_utils.debug_unexpected_msg(l_full_path);
          -- ========================= FND LOG ===========================

END populate_discount_lines_cache;

/**************************** MANUAL_TRANSACTION *******************************************/

PROCEDURE manual_transaction (	p_customer_trx_id IN NUMBER,
				discount_basis	  IN VARCHAR2 ) IS

   CURSOR c_manual_trx
   IS
      SELECT customer_trx_line_id, link_to_cust_trx_line_id, line_type
      FROM   ra_customer_trx_lines
      WHERE  customer_trx_id = p_customer_trx_id
      AND    include_manual_line (discount_basis, link_to_cust_trx_line_id, line_type) = 'Y';

   l_manual_trx_rec c_manual_trx%ROWTYPE;
   l_index          NUMBER := 1;
   -- ========================= FND LOG ===========================
   l_full_path VARCHAR2(100) := g_path || 'manual_transaction';
   -- ========================= FND LOG ===========================

BEGIN

   -- ========================= FND LOG ===========================
   psa_utils.debug_other_string(g_state_level,l_full_path,' Manual_transaction : START ');
   psa_utils.debug_other_string(g_state_level,l_full_path,' Manual_transaction : calling RESET_DISCOUNT_CACHE ');
   -- ========================= FND LOG ===========================

   RESET_DISCOUNT_CACHE;

   OPEN  c_manual_trx;
   LOOP

     FETCH c_manual_trx INTO l_manual_trx_rec;
     EXIT WHEN c_manual_trx%NOTFOUND;

     -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' Manual_transaction : customer_trx_line_id --> '  || l_manual_trx_rec.customer_trx_line_id);
     -- ========================= FND LOG ===========================

     TrxLinesTab(l_index) := l_manual_trx_rec.customer_trx_line_id;
     l_index := l_index + 1;

   END LOOP;
   CLOSE c_manual_trx;

   -- ========================= FND LOG ===========================
   psa_utils.debug_other_string(g_state_level,l_full_path,' Manual_transaction : END ');
   -- ========================= FND LOG ===========================

EXCEPTION
  WHEN OTHERS THEN
    l_exception_message := 'EXCEPTION - OTHERS PACKAGE - PSA_MFAR_RECEIPTS.MANUAL_TRANSACTION: '||sqlerrm;
    PSA_MFAR_UTILS.INSERT_DISTRIBUTIONS_LOG (g_run_id, 'RECEIPT', g_cust_trx_id, g_receivable_application_id,
	  			             l_exception_message);
   -- ========================= FND LOG ===========================
   psa_utils.debug_other_string(g_excep_level,l_full_path,l_exception_message);
   psa_utils.debug_unexpected_msg(l_full_path);
   -- ========================= FND LOG ===========================
END manual_transaction;


/**************************** INCLUDE_MANUAL_LINE *******************************************/

FUNCTION include_manual_line ( 	p_discount_basis	   IN VARCHAR2,
				p_link_to_cust_trx_line_id IN NUMBER,
				p_line_type		   IN VARCHAR2 ) RETURN VARCHAR2
IS
  CURSOR c_tax_line
  IS
   SELECT line_type
   FROM   ra_customer_trx_lines
   WHERE  customer_trx_line_id = p_link_to_cust_trx_line_id;

   l_tax_line	c_tax_line%rowtype;
   -- ========================= FND LOG ===========================
   l_full_path VARCHAR2(100) := g_path || 'include_manual_line';
   -- ========================= FND LOG ===========================

BEGIN

   -- ========================= FND LOG ===========================
   psa_utils.debug_other_string(g_state_level,l_full_path,' Include_manual_line : START');
   -- ========================= FND LOG ===========================

  IF     p_discount_basis = 'I' THEN
         RETURN 'Y';

  ELSIF  p_discount_basis = 'L' THEN
         IF p_line_type = 'LINE' THEN
            RETURN 'Y';
         END IF;

  ELSIF  p_discount_basis = 'T' THEN
         IF  p_line_type In ( 'LINE', 'TAX', 'FREIGHT' ) THEN
             RETURN 'Y';
         END IF;

  ELSIF  p_discount_basis = 'F' THEN
         IF  p_line_type = 'LINE' THEN
             RETURN 'Y';
         END IF;

  ELSIF  p_line_type = 'TAX' THEN

         OPEN  c_tax_line;
         FETCH c_tax_line INTO l_tax_line;
         CLOSE c_tax_line;

         IF l_tax_line.line_type = 'LINE' THEN
            RETURN 'Y';
         END IF;
  END IF;

  RETURN 'Y';

EXCEPTION
  WHEN OTHERS THEN
       l_exception_message := 'EXCEPTION - OTHERS PACKAGE - PSA_MFAR_RECEIPTS.INCLUDE_MANUAL_LINE: '|| sqlerrm;
       PSA_MFAR_UTILS.INSERT_DISTRIBUTIONS_LOG (g_run_id, 'RECEIPT', g_cust_trx_id, g_receivable_application_id,
	                                        l_exception_message);
       -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_excep_level,l_full_path,l_exception_message);
       psa_utils.debug_unexpected_msg(l_full_path);
       -- ========================= FND LOG ===========================

END include_manual_line;

/**************************** IMPORTED_TRANSACTION *******************************************/

PROCEDURE imported_transaction ( p_customer_trx_id IN NUMBER,
				 p_discount_basis  IN VARCHAR2 )
IS

  CURSOR c_imported_trx
  IS
    SELECT line_type, customer_trx_line_id, link_to_cust_trx_line_id, inventory_item_id
    FROM  ra_customer_trx_lines
    WHERE customer_trx_id       = p_customer_trx_id
    AND	include_imported_line
        (p_discount_basis, link_to_cust_trx_line_id, line_type, inventory_item_id) = 'Y';

  l_inventory_item_profile NUMBER;
  l_imported_trx_rec	   c_imported_trx%ROWTYPE;
  l_index		   NUMBER := 1;
  -- ========================= FND LOG ===========================
  l_full_path VARCHAR2(100) := g_path || 'imported_transaction';
  -- ========================= FND LOG ===========================

BEGIN

     -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' Imported_transaction : START');
     -- ========================= FND LOG ===========================

     --
     -- Profile Option - TAX: Inventory Item for Freight
     --

     OE_PROFILE.GET ('SO_INVENTORY_ITEM_FOR_FREIGHT', g_inventory_item_profile);

     -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' Imported_transaction : calling RESET_DISCOUNT_CACHE');
     -- ========================= FND LOG ===========================

     RESET_DISCOUNT_CACHE;

     OPEN  c_imported_trx;
     LOOP
	 FETCH c_imported_trx INTO l_imported_trx_rec;
	 EXIT WHEN c_imported_trx%NOTFOUND;

         -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' Manual_transaction : customer_trx_line_id --> '  || l_imported_trx_rec.customer_trx_line_id);
         -- ========================= FND LOG ===========================

	 TrxLinesTab(l_index) := l_imported_trx_rec.customer_trx_line_id;
     END LOOP;
     CLOSE c_imported_trx;

EXCEPTION
	WHEN OTHERS THEN
          l_exception_message := 'EXCEPTION - OTHERS PACKAGE - PSA_MFAR_RECEIPTS.IMPORTED_TRANSACTION: '|| sqlerrm;
	  PSA_MFAR_UTILS.INSERT_DISTRIBUTIONS_LOG (g_run_id, 'RECEIPT', g_cust_trx_id, g_receivable_application_id,
	  			                   l_exception_message);
          -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_excep_level,l_full_path,l_exception_message);
          psa_utils.debug_unexpected_msg(l_full_path);
          -- ========================= FND LOG ===========================

END imported_transaction;

/**************************** INCLUDE_IMPORTED_TRANSACTION *******************************************/


FUNCTION include_imported_line ( p_discount_basis		IN VARCHAR2,
		  		 p_link_to_cust_trx_line_id	IN NUMBER,
		  		 p_line_type			IN NUMBER,
		  		 p_inventory_item_id		IN NUMBER )
RETURN VARCHAR2 IS

	CURSOR c_inventory_item IS
		Select  inventory_item_id
		  From  ra_customer_trx_lines
		  Where customer_trx_line_id =  p_link_to_cust_trx_line_id;

	CURSOR c_tax_line IS
	       Select  line_type
	         From  ra_customer_trx_lines
	         Where customer_trx_line_id = p_link_to_cust_trx_line_id;

	l_inventory_item_rec	c_inventory_item%rowtype;
	l_tax_line_rec		c_tax_line%rowtype;
        -- ========================= FND LOG ===========================
        l_full_path VARCHAR2(100) := g_path || 'include_imported_line';
        -- ========================= FND LOG ===========================

BEGIN

    -- ========================= FND LOG ===========================
    psa_utils.debug_other_string(g_state_level,l_full_path,' Include_imported_transaction : START');
    -- ========================= FND LOG ===========================

    IF p_discount_basis = 'F' THEN
       IF g_inventory_item_profile IS NOT NULL  THEN
          IF p_line_type = 'LINE' THEN
             IF NOT ( nvl(p_inventory_item_id, -1) = g_inventory_item_profile) THEN
                RETURN 'Y';
             END IF;
          ELSIF p_line_type = 'TAX' THEN

                OPEN  c_inventory_item;
                FETCH c_inventory_item INTO l_inventory_item_rec;
		CLOSE c_inventory_item;

                IF NOT ( nvl(l_inventory_item_rec.inventory_item_id, -1) = g_inventory_item_profile) THEN
                    RETURN 'Y';
                END IF;
	  END IF;
      ELSE
	    --
	    -- inventory item id = null, discount basis = 'F' is not a correct combination
	    -- treat as if discount basis = 'T'
	    --

        IF    p_line_type = 'LINE' THEN
              RETURN 'Y';
        ELSIF p_line_type = 'TAX' THEN

              OPEN  c_tax_line;
              FETCH c_tax_line INTO l_tax_line_rec;
	      CLOSE c_tax_line;

              IF l_tax_line_rec.line_type = 'LINE' THEN
                 RETURN 'Y';
              END IF;
	END IF;
      END IF;

    ELSIF p_discount_basis = 'T' THEN
	IF p_line_type In ( 'LINE', 'TAX', 'FREIGHT' ) THEN
           RETURN 'Y';
	END IF;

    ELSIF p_discount_basis = 'L' THEN
    	IF p_line_type = 'LINE' THEN
    	   RETURN 'Y';
    	END IF;

    ELSIF p_discount_basis = 'I' THEN
    	   RETURN 'Y';
    END IF;

    RETURN 'Y';

EXCEPTION
    WHEN OTHERS THEN
    l_exception_message := 'EXCEPTION - OTHERS PACKAGE - PSA_MFAR_RECEIPTS.INCLUDE_IMPORTED_LINE: '|| sqlerrm;
    PSA_MFAR_UTILS.INSERT_DISTRIBUTIONS_LOG (g_run_id, 'RECEIPT', g_cust_trx_id, g_receivable_application_id,
                                             l_exception_message);
    -- ========================= FND LOG ===========================
    psa_utils.debug_other_string(g_excep_level,l_full_path,l_exception_message);
    psa_utils.debug_unexpected_msg(l_full_path);
    -- ========================= FND LOG ===========================

END include_imported_line;

 /******************************* LINE_IN_DISCOUNT_CACHE **************************/

FUNCTION line_in_discount_cache (p_customer_trx_line_id IN NUMBER) RETURN BOOLEAN IS
 -- ========================= FND LOG ===========================
 l_full_path VARCHAR2(100) := g_path || 'line_in_discount_cache';
 -- ========================= FND LOG ===========================
BEGIN
     -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' Line_in_discount_cache : START');
     -- ========================= FND LOG ===========================
     FOR i IN 1..TrxLinesTab.COUNT LOOP
       IF TrxLinesTab(i) = p_customer_trx_line_id THEN
          RETURN TRUE;
       END IF;
     END LOOP;

EXCEPTION
     WHEN OTHERS THEN
     l_exception_message := 'EXCEPTION - OTHERS PACKAGE - PSA_MFAR_RECEIPTS.LINE_IN_DISCOUNT_CACHE: '|| sqlerrm;
     PSA_MFAR_UTILS.INSERT_DISTRIBUTIONS_LOG (g_run_id, 'RECEIPT', g_cust_trx_id, g_receivable_application_id,
	  			              l_exception_message);
     -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_excep_level,l_full_path,l_exception_message);
     psa_utils.debug_unexpected_msg(l_full_path);
     -- ========================= FND LOG ===========================

END line_in_discount_cache;

 /******************************* RESET_DISCOUNT_CACHE **************************/

PROCEDURE reset_discount_cache IS
  -- ========================= FND LOG ===========================
  l_full_path VARCHAR2(100) := g_path || 'reset_discount_cache';
  -- ========================= FND LOG ===========================
BEGIN
     -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' Reset_discount_cache : START');
     -- ========================= FND LOG ===========================

	FOR i IN 1..TrxLinesTab.COUNT LOOP
		TrxLinesTab.DELETE(i);
	END LOOP;

EXCEPTION
     WHEN OTHERS THEN
      l_exception_message := 'EXCEPTION - OTHERS PACKAGE - PSA_MFAR_RECEIPTS.RESET_DISCOUNT_CACHE: '|| sqlerrm;
      PSA_MFAR_UTILS.INSERT_DISTRIBUTIONS_LOG (g_run_id, 'RECEIPT', g_cust_trx_id, g_receivable_application_id,
         	  			              l_exception_message);
      -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_excep_level,l_full_path,l_exception_message);
      psa_utils.debug_unexpected_msg(l_full_path);
      -- ========================= FND LOG ===========================

END reset_discount_cache;


END psa_mfar_receipts;

/
