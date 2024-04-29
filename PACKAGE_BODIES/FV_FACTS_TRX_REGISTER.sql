--------------------------------------------------------
--  DDL for Package Body FV_FACTS_TRX_REGISTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_FACTS_TRX_REGISTER" AS
/* $Header: FVFCTRGB.pls 120.69.12010000.5 2009/08/19 15:37:14 snama ship $*/
--    l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('FV_DEBUG_FLAG'),'N');
  g_module_name VARCHAR2(100);
-- -------------------------------------------------------------
--    	        GLOBAL VARIABLES
-- -------------------------------------------------------------
  g_error_buf            VARCHAR2(600);
  g_error_code           NUMBER := 0;
  g_set_of_books_id    	 NUMBER;
  g_treasury_symbol    	 Fv_Treasury_Symbols.treasury_symbol%TYPE;
  g_treasury_symbol_id 	 Fv_Treasury_Symbols.treasury_symbol_id%TYPE;
  g_period_year          Gl_Balances.period_year%TYPE;
  g_period_num_low       Gl_Balances.period_num%TYPE;
  g_period_num_high      Gl_Balances.period_num%TYPE;
  g_from_period_name     Gl_Period_Statuses.period_name%TYPE;
  g_to_period_name       Gl_Period_Statuses.period_name%TYPE;
  g_cohort_seg_name      FV_FACTS_FEDERAL_ACCOUNTS.cohort_segment_name%TYPE;
  g_bal_segment_name     VARCHAR2(25);
  g_acct_segment_name    VARCHAR2(25);
  g_reimb_agree_seg_name   VARCHAR2(25);
  g_acc_value_set_id     NUMBER;
  g_adjustment_flag      VARCHAR2(1);
  g_coa_id               Gl_Code_Combinations.chart_of_accounts_id%TYPE;
  g_apps_id          	 Fnd_Id_Flex_Structures.application_id%TYPE;
  g_id_flex_code     	 Fnd_Id_Flex_Structures.id_flex_code%TYPE;
  g_currency_code        Gl_Sets_Of_Books.currency_code%TYPE;
  g_start_date	         Gl_Period_Statuses.start_date%TYPE;
  g_end_date	         Gl_Period_Statuses.end_date%TYPE;
  g_source		 VARCHAR2(25);
  g_category		 VARCHAR2(25);
  g_attributes_found     VARCHAR2(1);
  g_req_date_seg	 VARCHAR2(15) := NULL;
  g_pur_order_date_seg   VARCHAR2(15) := NULL;
  g_rec_trxn_date_seg    VARCHAR2(15) := NULL;
  g_from_gl_posted_date  gl_je_headers.posted_date%TYPE;
  g_to_gl_posted_date    gl_je_headers.posted_date%TYPE;


  g_funds_count		NUMBER;

  TYPE segment_rec IS RECORD
  (
      segment VARCHAR2(10),
      fund_value VARCHAR2(25),
      prc_flag   VARCHAR2(1),
      prc_header_id NUMBER,
      code_type VARCHAR2(1)
  );

  TYPE segment_tab IS TABLE OF segment_rec INDEX BY BINARY_INTEGER;
  g_segs_array    segment_tab;

    ---  FACTS II ATTRIBUTES--
  g_balance_type_flag 		VARCHAR2(1)	;
  g_public_law_code_flag  	VARCHAR2(1)	;
  g_reimburseable_flag 		VARCHAR2(1)	;
  g_bea_category_flag    	VARCHAR2(1)	;
  g_advance_flag                VARCHAR2(1)	;
  g_appor_cat_flag	 	VARCHAR2(1)	;
  g_borrowing_source_flag	VARCHAR2(1)	;
  g_def_indef_flag		VARCHAR2(1)	;
  g_budget_function_val         VARCHAR2(3)	;
  g_legis_ind_flag	    	VARCHAR2(1)	;
  g_pya_flag              VARCHAR2(1);
  g_authority_type_flag		VARCHAR2(1)	;
  g_function_flag		VARCHAR2(1)	;
  g_availability_flag		VARCHAR2(1)	;
  g_def_liquid_flag		VARCHAR2(1)	;
  g_deficiency_flag		VARCHAR2(1)	;
  g_transaction_partner_val	VARCHAR2(1)	;
  g_def_indef_val		VARCHAR2(1)	;
  --g_appor_cat_b_dtl		VARCHAR2(3)	;
  --g_appor_cat_b_txt		VARCHAR2(25)	;
  g_public_law_code_val		VARCHAR2(7)	;
  g_appor_cat_val		VARCHAR2(1)	;
  g_authority_type_val		VARCHAR2(1)	;
  g_reimburseable_val  		VARCHAR2(1)	;
  g_bea_category_val     	VARCHAR2(5)	;
  g_borrowing_source_val	VARCHAR2(6)	;
  --g_deficiency_val		VARCHAR2(1)	;
  g_legis_ind_val		VARCHAR2(1)	;
  g_pya_val VARCHAR2(1);
  g_balance_type_val		VARCHAR2(1)	;
  g_advance_type_val            VARCHAR2(1)	;
  g_transfer_ind                VARCHAR2(1)	;
  g_year_budget_auth            VARCHAR2(6)	;
  g_transfer_dept_id            fv_be_trx_dtls.dept_id%TYPE ;
  g_transfer_main_acct          fv_be_trx_dtls.main_account%TYPE ;
  g_availability_val            VARCHAR2(6)	;
  --g_prn_num                     VARCHAR2(3);
  --g_prn_txt                     VARCHAR2(25);

  g_facts_attributes_setup      BOOLEAN ;
  g_src_flag			VARCHAR2(1);
  -- g_fund_category               VARCHAR2(1);
 ---  FACTS I ATTRIBUTES--

  g_govt_non_govt_ind 		VARCHAR2(2);
  g_govt_non_govt_val 		VARCHAR2(2);
  g_exch_non_exch_ind     	VARCHAR2(1);
  g_exch_non_exch_val     	VARCHAR2(1);
  g_budget_subfunction_ind 	VARCHAR2(3);
  g_budget_subfunction_val 	VARCHAR2(3);
  g_cust_non_cust_ind     	VARCHAR2(1);
  g_cust_non_cust_val     	VARCHAR2(1);


--------------------------------------------------------------------------------
PROCEDURE load_program_seg;
PROCEDURE get_prc_val(p_ccid IN NUMBER,
                      p_fund_value IN VARCHAR2,
                      p_catb_val OUT NOCOPY VARCHAR2,
                      p_catb_desc OUT NOCOPY VARCHAR2,
                      p_prn_val OUT NOCOPY VARCHAR2,
                      p_prn_desc OUT NOCOPY VARCHAR2);
PROCEDURE populate_table
              ( p_treasury_symbol_id 	NUMBER ,
 	  	p_set_of_books_id 	NUMBER ,
	 	p_code_combination_id   NUMBER ,
 		p_fund_value 		VARCHAR2,
 		p_account_number 	VARCHAR2,
		p_document_source 	VARCHAR2,
		p_document_category 	VARCHAR2,
 		p_document_number 	VARCHAR2,
 		p_transaction_date 	DATE,
 		p_creation_date_time 	DATE,
 		p_entry_user		VARCHAR2,
 		p_fed_non_fed 		VARCHAR2,
 		p_trading_partner 	VARCHAR2,
 		p_exch_non_exch 	VARCHAR2,
 		p_cust_non_cust 	VARCHAR2,
		p_budget_subfunction 	VARCHAR2,
 		p_debit 		NUMBER,
 		p_credit 		NUMBER,
 		p_transfer_dept_id 	VARCHAR2,
 		p_transfer_main_acct 	VARCHAR2,
 		p_year_budget_auth 	VARCHAR2,
 		p_budget_function 	VARCHAR2,
 		p_advance_flag 		VARCHAR2,
 		p_cohort 		VARCHAR2,
 		p_begin_end 		VARCHAR2,
 		p_indef_def_flag 	VARCHAR2,
 		p_appor_cat_b_dtl 	VARCHAR2,
 		p_appor_cat_b_txt 	VARCHAR2,
		p_prn_num               VARCHAR2,
                p_prn_txt               VARCHAR2,
                p_public_law 		VARCHAR2,
		p_appor_cat_code 	VARCHAR2,
 		p_authority_type 	VARCHAR2,
 		p_transaction_partner   VARCHAR2,
		p_reimburseable_flag 	VARCHAR2,
 		p_bea_category 		VARCHAR2,
 		p_borrowing_source 	VARCHAR2,
		p_def_liquid_flag 	VARCHAR2,
 		p_deficiency_flag	VARCHAR2,
 		p_availability_flag	VARCHAR2,
 		p_legislation_flag 	VARCHAR2,
    p_pya_flag VARCHAR2,
                p_je_line_creation_date DATE,
                p_je_line_modified_date DATE,
                p_je_line_period_name   VARCHAR2,
		p_gl_date		DATE,
		p_gl_posted_date	DATE,
    p_reversal_flag   VARCHAR2,
    p_sla_hdr_event_id NUMBER,
    p_sla_hdr_creation_date DATE,
    p_sla_entity_id NUMBER);
PROCEDURE GET_DOC_INFO (p_je_header_id 		IN Number,
			p_je_source_name 	IN Varchar2,
			p_je_category_name 	IN Varchar2,
			p_name			IN Varchar2,
			p_date			IN Date,
		        p_creation_date		IN Date,
		        p_created_by		IN Number,
			p_reference1		IN Varchar2,
			p_reference2		IN Varchar2,
			p_reference3		IN Varchar2,
			p_reference4		IN Varchar2,
			p_reference5    	IN Varchar2,
			p_reference9    	IN Varchar2,
			p_ref2 			IN Varchar2,
			p_doc_num	       OUT NOCOPY Varchar2,
			p_doc_date	       OUT NOCOPY Date,
			p_doc_creation_date    OUT NOCOPY Date,
			p_doc_created_by       OUT NOCOPY Number,
                        p_gl_date              IN OUT NOCOPY DATE,
                        p_rec_public_law_code_col IN VARCHAR2,
      p_gl_sl_link_id       IN NUMBER,
			p_rec_public_law_code OUT NOCOPY Varchar2,
      p_reversed       OUT NOCOPY VARCHAR2,
      p_sla_entity_id IN NUMBER);

PROCEDURE group_po_rec_lines;

PROCEDURE group_payables_lines;

PROCEDURE get_trx_part_from_reimb(p_reimb_agree_seg_val IN VARCHAR2);
PROCEDURE get_fnf_from_reimb(p_reimb_agree_seg_val IN VARCHAR2);
--------------------------------------------------------------------------------
--    	        PROCEDURE MAIN
--------------------------------------------------------------------------------
-- Called from following procedures:
-- This is called from the concurrent program to execute FACTS
-- transaction register process
-- Purpose:
-- This calls all subsequent procedures
--------------------------------------------------------------------------------

PROCEDURE MAIN(p_errbuf          OUT NOCOPY     VARCHAR2,
               p_retcode         OUT NOCOPY     NUMBER,
               p_set_of_books_id     	        NUMBER,
               p_coa_id	   	   	        NUMBER,
               p_currency_code                  VARCHAR2,
               p_treasury_symbol_low            VARCHAR2,
               p_treasury_symbol_high           VARCHAR2,
               p_from_period_name	        VARCHAR2,
               p_to_period_name                 VARCHAR2,
               p_from_gl_posted_date            VARCHAR2,
               p_to_gl_posted_date              VARCHAR2,
               p_source      	                VARCHAR2,
               p_category                       VARCHAR2,
               p_report_id                      VARCHAR2,
               p_attribute_set                  VARCHAR2,
               p_output_format                  VARCHAR2) IS
  l_module_name VARCHAR2(200);

       CURSOR treasury_symbol_range_cur IS
       SELECT treasury_symbol_id,
              treasury_symbol
         FROM fv_treasury_symbols
        WHERE set_of_books_id = g_set_of_books_id
          AND Treasury_symbol
              BETWEEN NVL(p_treasury_symbol_low,treasury_symbol)
                AND  NVL(p_treasury_symbol_high,treasury_symbol)
     ORDER BY Treasury_symbol ;

  --l_exists	    NUMBER;
  l_req_id 	    NUMBER;
  l_call_status     BOOLEAN;
  l_rphase          VARCHAR2(30);
  l_rstatus         VARCHAR2(30);
  l_dphase          VARCHAR2(30);
  l_dstatus         VARCHAR2(30);
  l_message         VARCHAR2(240);
  l_count           NUMBER;

  l_prc_map_count   NUMBER;

BEGIN
  l_module_name  := g_module_name || 'MAIN';
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'STARTING THE FACTS TRANSACTION REGISTER '||
                         'Main Process ...');
 END IF;
   --Set SLA security context
   xla_security_pkg.set_security_context(602);

   g_set_of_books_id  := p_set_of_books_id;
   g_coa_id           := p_coa_id;
   g_currency_code    := p_currency_code;
   g_source           := p_source;
   g_category         := p_category;
   g_from_period_name := p_from_period_name;
   g_to_period_name   := p_to_period_name ;
   g_from_gl_posted_date := NULL;
   IF (p_from_gl_posted_date IS NOT NULL) THEN
     g_from_gl_posted_date := FND_DATE.CANONICAL_TO_DATE(p_from_gl_posted_date);
   ELSE
     g_from_gl_posted_date := TO_DATE('01/01/1900', 'DD/MM/RRRR');
   END IF;
   g_to_gl_posted_date := NULL;
   IF (p_to_gl_posted_date IS NOT NULL) THEN
     g_to_gl_posted_date   := TO_DATE(TO_CHAR(FND_DATE.CANONICAL_TO_DATE(p_to_gl_posted_date), 'DD/MM/RRRR')||' 23:59:59', 'DD/MM/RRRR HH24:MI:SS');
    ELSE
     g_to_gl_posted_date := TO_DATE('31/12/9999', 'DD/MM/RRRR');
   END IF;




   -- Check whether program reporting code mapping has
   -- been done for set of books. If not, then write error
   -- message and exit process.
   SELECT count(*)
   INTO   l_prc_map_count
   FROM   fv_facts_prc_hdr
   WHERE  set_of_books_id = g_set_of_books_id;

   IF l_prc_map_count = 0 THEN
      g_error_code := -1;
      g_error_buf := 'Program Reporting Code Mapping has not been done! '||
                'Please map the Program Reporting Code and resubmit!';
   END IF;


   -- Get Period Year
   IF (g_error_code  = 0)
   THEN
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,' ');
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'DERIVING THE PERIOD YEAR.....');
      END IF;
      GET_PERIOD_YEAR (p_from_period_name, p_to_period_name);
   END IF;

   -- Process Input start_date and end_date
   IF (g_error_code = 0)
   THEN
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'GET THE PERIOD INFO ...');
      END IF;
      PROCESS_PERIOD_INFO;
   END IF;

   -- Get Account and Balancing Segment values
   IF (g_error_code = 0)
   THEN
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'GET THE QUALIFIER SEGMENTS ...');
     END IF;
     GET_QUALIFIER_SEGMENTS;
   END IF;

   -- Purge the data IF any for the Treasury Symbol
       IF (g_error_code  = 0)THEN
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'PURGING EXISTING DATA OF ');
         END IF;
         PURGE_FACTS_TRANSACTIONS ;
       END IF ;

   -- Process Journal Lines for each Treasury Symbol

    FOR treasury_symbol_range_rec IN treasury_symbol_range_cur
    LOOP
      EXIT WHEN treasury_symbol_range_cur%NOTFOUND;
       g_treasury_symbol_id :=
              treasury_symbol_range_rec.treasury_symbol_id;
       g_treasury_symbol :=
              treasury_symbol_range_rec.treasury_symbol;


      IF (g_error_code = 0) THEN
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,' ');
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'PROCESS JOURNAL LINES  ...');
        END IF;
           JOURNAL_PROCESS;
      END IF;

    END LOOP;

   IF treasury_symbol_range_cur%ISOPEN THEN
      CLOSE treasury_symbol_range_cur;
   END IF;


    IF (g_error_code <> 0 ) THEN
      -- Check for errors
      p_retcode := g_error_code ;
      p_errbuf  := g_error_buf ;
      ROLLBACK;
      RETURN ;
    END IF;

    -- Submit the RXi Report
   BEGIN
      SELECT count(*)
        INTO l_count
        FROM FV_FACTS_TRX_TEMP;

      IF l_count >0 THEN

         --group the PO receiving lines, bug7253838
         group_po_rec_lines;
             IF (g_error_code <> 0 ) THEN
                p_retcode := g_error_code ;
                p_errbuf  := g_error_buf ;
                ROLLBACK;
                RETURN ;
             END IF;

         --group the payables lines
         group_payables_lines;
         IF (g_error_code <> 0 ) THEN
                p_retcode := g_error_code ;
                p_errbuf  := g_error_buf ;
                ROLLBACK;
                RETURN ;
         END IF;

         l_req_id :=
                    FND_REQUEST.SUBMIT_REQUEST ('FV','RXFVFTXR','','',FALSE,
                     'DIRECT', p_report_id,p_attribute_set, p_output_format,
		     p_set_of_books_id,
		     p_currency_code,
		     p_treasury_symbol_low ,
                     p_treasury_symbol_high,
                     p_from_period_name,
                     p_to_period_name,
                     p_source,
                     p_category);
         COMMIT;

        IF l_req_id = 0 THEN
            p_errbuf := 'Error submitting RX Report ';
            p_retcode := -1 ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,p_errbuf);
            RETURN;
        ELSE
            -- if concurrent request submission failed then abort process
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                  'Concurrent Request Id for RX Report - ' ||l_req_id);
            END IF;
        END IF;

         -- Check status of completed concurrent program
         -- and if complete exit
             l_call_status := Fnd_Concurrent.Wait_For_Request(
                                               l_req_id, 20, 0, l_rphase, l_rstatus,
                                               l_dphase, l_dstatus, l_message);

             IF (l_call_status = FALSE) THEN
                   p_errbuf := 'Cannot wait for the status of  RX Report.';
                   p_retcode := 1;
                     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,p_errbuf);
                   PURGE_FACTS_TRANSACTIONS ;
             END IF;


      ELSE
        p_retcode := 1;
        p_errbuf  := '** No Data Found for the Transaction Register Process **';
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,p_errbuf);
        RETURN;
      END IF;
   END;

  IF (g_error_code <> 0 )
   THEN
      -- Check for errors
      p_retcode := g_error_code ;
      p_errbuf  := g_error_buf ;
      ROLLBACK;
      RETURN ;
   ELSE
      -- if facts attribute columns are not setup in the system
      -- parameters form then complete the process with a warning.
      IF NOT g_facts_attributes_setup
        THEN
         p_retcode := 1;
         p_errbuf := 'Transaction Register Process completed with warning because the Public Law, Advance,
                      and Transfer attribute columns are not established on the Define System Parameters Form.';
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,p_errbuf);
         COMMIT;
         RETURN;
       ELSE
         p_retcode := 0;
         p_errbuf := '** Transaction Register Process  completed Successfully **';
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,p_errbuf);
         END IF;
         COMMIT;
         RETURN;
      END IF ;
   END IF;

EXCEPTION
 WHEN OTHERS
   THEN
      p_errbuf  := '** Transaction Register Process Failed ** '||SQLERRM;
      p_retcode := 2;
      ROLLBACK;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_buf);
END main;

-- ------------------------------------------------------------------
--			PROCEDURE GET_PERIOD_YEAR
-- ------------------------------------------------------------------
-- Get_Period_Year procedure is called from the Main procedure.
-- This procedure gets the accounting calender name(period set name)
-- based on the set of books parameter that is passed and then gets
-- the period year based on period from and period to parameters.
-- It then gets the start date of the from period and end date of the
-- to period, which are used in the Journal_Process Procedure.
-- ------------------------------------------------------------------
PROCEDURE get_period_year (p_period_from VARCHAR2,
			   p_period_to	 VARCHAR2)
IS
  l_module_name VARCHAR2(200);
  l_period_set_name Gl_Periods.period_set_name%TYPE;
BEGIN
  l_module_name := g_module_name || 'get_period_year';
   BEGIN
	SELECT 	period_set_name
	INTO	l_period_set_name
	FROM 	gl_sets_of_books
	WHERE	set_of_books_id	= g_set_of_books_id;
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    g_error_code := 2;
	    g_error_buf  := 'Period Set name not found for set of books '
                             ||to_char(g_set_of_books_id);
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,g_error_buf);
            RETURN;
	WHEN OTHERS THEN
            g_error_code := SQLCODE ;
            g_error_buf  := SQLERRM  ||
                ' -- Error in Get_Period_Year procedure,while getting the '
                          ||'period set name.' ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,g_error_buf);
            RETURN;
   END;

   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       PERIOD SET NAME IS '||L_PERIOD_SET_NAME);
   END IF;

   BEGIN
	SELECT 	period_year,adjustment_period_flag
	INTO	g_period_year,g_adjustment_flag
	FROM 	gl_periods
	WHERE	period_set_name = l_period_set_name
	AND	period_name	= p_period_from;
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
            g_error_code := 2;
            g_error_buf  := 'Period Year not found for the set of books '
                            ||to_char(g_set_of_books_id) ||
			    ' and the period set name '||l_period_set_name;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,g_error_buf);
            RETURN;
	WHEN OTHERS THEN
            g_error_code := SQLCODE ;
            g_error_buf  := SQLERRM  ||
                              ' -- Error in Get_Period_Year procedure,'||
                              ' while getting the period year.' ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,g_error_buf);
            RETURN;
   END;

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       PERIOD YEAR IS '||TO_CHAR(G_PERIOD_YEAR));
 END IF;

   BEGIN	-- From Period Start Date
	SELECT  start_date
	INTO	g_start_date
	FROM	gl_period_statuses
	WHERE	ledger_id = g_set_of_books_id
	AND	application_id = 101
	AND	period_year = g_period_year
	AND	period_name = p_period_from;
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
            g_error_code := 2;
            g_error_buf  := 'Start Date not defined for the period name '
                            ||p_period_from;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,g_error_buf);
            RETURN;
        WHEN OTHERS THEN
            g_error_code := SQLCODE ;
            g_error_buf  := SQLERRM  ||
                            ' -- Error in Get_Period_Year procedure, '||
                            'while getting the start date for the from period '
                            ||p_period_from ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,g_error_buf);
            RETURN;
   END;

   -- From Period Start Date
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       PERIOD START DATE IS '||TO_CHAR(G_START_DATE, 'MM/DD/YYYY'));
 END IF;
   BEGIN        -- To Period End Date
        SELECT  end_date
        INTO    g_end_date
        FROM    gl_period_statuses
        WHERE   ledger_id = g_set_of_books_id
        AND     application_id = 101
        AND     period_year = g_period_year
        AND     period_name = p_period_to;
   EXCEPTION
        WHEN NO_DATA_FOUND THEN
            g_error_code := 2;
            g_error_buf  := 'End Date not defined for the period name '
                             ||p_period_to;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,g_error_buf);
            RETURN;
        WHEN OTHERS THEN
            g_error_code := SQLCODE ;
            g_error_buf  := SQLERRM  ||
                            ' -- Error in Get_Period_Year procedure, '||
                            'while getting the end date for the to period '||
                             p_period_to ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,g_error_buf);
           RETURN;
   END;         -- To Period End Date

   -- Setting up the retcode
   g_error_code := 0;

EXCEPTION
     WHEN OTHERS THEN
            g_error_code := SQLCODE ;
            g_error_buf  := SQLERRM  ||
                              ' -- Error in Get_Period_Year procedure.' ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_buf);
            RETURN;
END get_period_year;

-- -------------------------------------------------------------
-- 		PROCEDURE PRCOESS PERIOD INFO
-- -------------------------------------------------------------
-- Process_Period_Info procedure is called from the Main procedure.
-- This procedure loads global variables 'g_period_num_low'
-- and 'g_period_num_high' with the derived period num range.
-- -------------------------------------------------------------
PROCEDURE process_period_info
IS
  l_module_name VARCHAR2(200);
BEGIN
  l_module_name := g_module_name || 'process_period_info';
   -- IF g_adjustment_flag = 'Y' THEN
        -- Select Period Information for Beginning Period
     BEGIN
        SELECT MIN(period_num)
        INTO   g_period_num_low
        FROM   gl_period_statuses
        WHERE  period_name = g_from_period_name
        AND application_id = 101
        AND ledger_id = g_set_of_books_id
        AND period_year = g_period_year;
     EXCEPTION
   	WHEN NO_DATA_FOUND THEN
       		g_error_code := 2;
       		g_error_buf  := 'PROCESS PERIOD INFO - period_num corresponding '||
               		        'to From Period Name ' || g_from_period_name ||
                       		' not found.';
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,g_error_buf);
       		RETURN;
   	WHEN OTHERS THEN
       		g_error_code := SQLCODE ;
       		g_error_buf  := SQLERRM  ||
               		          'PROCESS PERIOD INFO -  Error when getting '||
                                  'min(period_num) from gl_period_statuses '||
                                  'for From Period Name '|| g_from_period_name;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,g_error_buf);
       	RETURN;
     END;

     BEGIN
        SELECT  max(period_num)
        INTO    g_period_num_high
        FROM    gl_period_statuses
        WHERE period_name = g_to_period_name
        AND application_id = 101
        AND ledger_id = g_set_of_books_id
        AND period_year = g_period_year;
     EXCEPTION
   	WHEN NO_DATA_FOUND THEN
       		g_error_code := 2;
       		g_error_buf  := 'PROCESS PERIOD INFO - period corresponding '||
                       		'to To Period Name ' || g_to_period_name ||
                       		' not found.';
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,g_error_buf);
       RETURN;
   	WHEN OTHERS THEN
       		g_error_code := SQLCODE ;
       		g_error_buf  := SQLERRM  ||
                          'PROCESS PERIOD INFO -  Error when getting '||
                          'max(period_num) from gl_period_statuses for '||
                          'To Period Name '|| g_to_period_name;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,g_error_buf);
       RETURN;
     END;
--  END IF;
   -- Setting up the retcode
   g_error_code := 0;
EXCEPTION
     WHEN OTHERS THEN
            g_error_code := SQLCODE ;
            g_error_buf  := SQLERRM  ||
                              ' -- Error in Process_Period_Info procedure.' ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_buf);
            RETURN;
END process_period_info;
-- -------------------------------------------------------------
-- 		PROCEDURE GET QUALIFIER SEGMENTS
-- -------------------------------------------------------------
-- Get_QualIFier_Segments procedure is called from the Main
-- procedure.
-- This procedure gets the accounting and the balancing segments.
-- -------------------------------------------------------------
PROCEDURE get_qualifier_segments IS
  l_module_name VARCHAR2(200);
  l_error_code BOOLEAN;
BEGIN
  l_module_name := g_module_name || 'get_qualifier_segments';

    fv_utility.get_segment_col_names
    (
      chart_of_accounts_id	=> g_coa_id,
      acct_seg_name         => g_acct_segment_name,
      balance_seg_name      => g_bal_segment_name,
      error_code            => l_error_code,
      error_message         => g_error_buf
    );

    IF (l_error_code) THEN
       g_error_code := 2 ;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,g_error_buf);
       RETURN;
    END IF;

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       BALANCING SEGMENT IS '||G_BAL_SEGMENT_NAME);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       NATURAL ACCOUNTING SEGMENT IS '
                               ||g_acct_segment_name);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,' ');
 END IF;
   BEGIN
      -- Determine the Flex Value Set Id for the Acct segment
      SELECT  flex_value_set_id
      INTO    g_acc_value_set_id
      FROM    fnd_id_flex_segments
      WHERE   application_column_name = g_acct_segment_name
      AND     application_id          = g_apps_id
      AND     id_flex_code            = g_id_flex_code
      AND     id_flex_num             = g_coa_id ;
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       FLEX VALUE SET ID IS '||
                                 to_char(g_acc_value_set_id));
      END IF;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
       g_error_code := 2 ;
       g_error_buf  := 'GET QUALIFIER SEGMENTS - flex_value_set_id not found';
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,g_error_buf);
       RETURN;
     WHEN TOO_MANY_ROWS THEN
       g_error_code := 2 ;
       g_error_buf  := 'GET QUALIFIER SEGMENTS - More than one ' ||
                         'row returned while getting flex_value_set_id';
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,g_error_buf);
       RETURN;
    WHEN OTHERS THEN
       g_error_code := SQLCODE;
       g_error_buf  := SQLERRM ||
                         '-- GET QUALIFIER SEGMENTS Error '||
                         'when getting acct_value_set_id';
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,g_error_buf);
       RETURN;
   END;

   -- Setting up the retcode
   g_error_code := 0;
EXCEPTION
     WHEN OTHERS THEN
         g_error_code := SQLCODE ;
         g_error_buf  := SQLERRM  ||
                           ' -- Error in Get_QualIFier_Segments procedure.' ;
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_buf);
         RETURN;
END get_qualifier_segments;


-- -------------------------------------------------------------------
--	         PROCEDURE JOURNAL_PROCESS
-- -------------------------------------------------------------------
-- Journal_Process procedure is called from the Main procedure.
-- Its primary purpose is to derive values to populate
-- 'FV_FACTS_TRX_TEMP' table from the rows derived from INVOICES,
-- PAYMENTS etc. It uses  dynamimic SQL to dynamically set
-- the select statement for the cursor.
-- It uses the argument 'p_jrnl_type' to find whether the journal
-- type is Invoice or payment, etc. The valid journal type values
-- INV-Invoice, PMT-Payment, REC-Receivable, ORD-Purchase Order
-- -------------------------------------------------------------------
PROCEDURE journal_process
IS
--  TYPE jrnl_cursor IS REF CURSOR ;
  l_module_name VARCHAR2(200);
counter             NUMBER;
--l_ret_val	    BOOLEAN := TRUE;
l_jrnl 		    VARCHAR2(250);
--l_cat_str           VARCHAR2(3000);
l_src		    VARCHAR2(250);
l_cat	    	    VARCHAR2(250);
l_jrnl_cursor	    INTEGER;
l_jrnl_select_gl	    VARCHAR2(3000);
l_jrnl_select_xla  VARCHAR2(5000);
l_jrnl_select	    VARCHAR2(10000);
l_jrnl_att	    VARCHAR2(25) := NULL;
l_jrnl_fetch	    INTEGER;
l_exec_ret	    INTEGER;
l_vendor_id	    NUMBER(15);
l_vendor_type	    VARCHAR2(30);
l_account_number    VARCHAR2(25);
l_sgl_acct_num 	    VARCHAR2(25);
l_jrnl_att_value    VARCHAR2(240);
l_entered_dr	    NUMBER;
l_entered_cr	    NUMBER;
l_ccid		    NUMBER(15);
l_eliminations_id   VARCHAR2(150);
l_je_header_id      NUMBER(15);
l_date_created      DATE;
l_doc_num 	    VARCHAR2(240);
l_doc_date	    DATE;
l_doc_creation_date DATE;
l_doc_created_by    NUMBER(15);
l_creation_date	    DATE;
l_created_by	    NUMBER(15);
l_entry_user	    VARCHAR2(100);
l_fund_group	    NUMBER(4);
l_dept_id	    VARCHAR2(2);
l_bureau_id	    VARCHAR2(2);
l_bal_segment	    VARCHAR2(30);
--l_amount	    NUMBER;
l_reference_1 	    VARCHAR2(80);
l_refer2 	    VARCHAR2(80);
l_reference_2 	    VARCHAR2(80);
l_reference_3 	    VARCHAR2(80);
l_reference_4 	    VARCHAR2(80);
l_reference_5 	    VARCHAR2(80);
l_reference_6 	    VARCHAR2(80);
l_reference_7 	    VARCHAR2(80);
l_reference_8 	    VARCHAR2(80);
l_reference_9 	    VARCHAR2(80);
l_reference_10 	    VARCHAR2(80);
l_gl_sl_link_id  gl_je_lines.gl_sl_link_id%TYPE;
l_category 	    VARCHAR2(80);
l_source 	    VARCHAR2(80);
l_name 		    VARCHAR2(150);
l_valid_flag  	    VARCHAR2(2);
l_feeder_flag  	    VARCHAR2(1);
l_stage  	    NUMBER(2);
--l_balance_type_flag FV_FACTS_ATTRIBUTES.balance_type%TYPE;
l_sob 		    NUMBER(15);
l_coa 		    NUMBER(15);
--l_period_num_low    NUMBER(15);
--l_period_num_high   NUMBER(15);
l_period_year 	    NUMBER(15);
l_cohort_year       VARCHAR2(10);
l_disbursements_flag 	VARCHAR2(1);
l_time_frame            fv_treasury_symbols.time_frame%TYPE ;
l_financing_acct        fv_facts_federal_accounts.financing_account%TYPE ;
l_cohort_select         VARCHAR2(100) ;
l_cohort		VARCHAR2(2)	;
l_cohort_num_year       NUMBER;
l_fyr_segment_value     fv_pya_fiscalyear_map.fyr_segment_value%TYPE;
l_fyr_segment_name      fv_pya_fiscalyear_segment.application_column_name%TYPE;
l_seg_fiscal_yr		fv_pya_fiscalyear_map.fyr_segment_value%type;
l_je_from_sla_flag gl_je_headers.je_from_sla_flag%TYPE;
l_source_distribution_id_num_1 xla_distribution_links.source_distribution_id_num_1%TYPE;
l_applied_to_source_id_num_1 xla_distribution_links.applied_to_source_id_num_1%TYPE;
l_applied_to_dist_id_num_1 xla_distribution_links.applied_to_dist_id_num_1%TYPE;
l_source_distribution_type xla_distribution_links.source_distribution_type%TYPE;
l_event_type_code xla_ae_headers.event_type_code%TYPE;
l_ar_source_id ar_distributions_all.source_id%TYPE;
l_ar_source_table ar_distributions_all.source_table%TYPE;
l_ar_source_type ar_distributions_all.source_type%TYPE;
l_reimb_act_select    VARCHAR2(100) ;
l_reimb_agree_seg_val       VARCHAR2(30) ;


l_cat_b_seg_val_set_id NUMBER;
l_cat_b_seg_value      VARCHAR2(200);
--l_cat_b_seg            VARCHAR2(200);
l_cat_b_text           VARCHAR2(100);
l_prn_num              VARCHAR2(100);
l_prn_text             VARCHAR2(100);
--l_proj                 VARCHAR2(1000);
--l_p_cbs                VARCHAR2(1000);
--l_cbs_no               NUMBER;

--type rec is RECORD (prog_seg VARCHAR2(30),seq NUMBER);
--type tab is TABLE of rec index by binary_integer;
--l_tab  tab;
--l_ctrl                NUMBER;
--l_found               NUMBER:=0;
--l_p_cbs_no            NUMBER:=0;
l_cbs_num             VARCHAR2(3);

l_exists 	      VARCHAR2(1);
i		      NUMBER := 0;
l_tran_type           fv_be_trx_dtls.transaction_type_id%TYPE;

l_pl_code_col      VARCHAR2(25);
l_advance_type_col VARCHAR2(25);
l_tr_dept_id_col   VARCHAR2(25);
l_tr_main_acct_col VARCHAR2(25);
l_pl_code          VARCHAR2(150);
l_tr_main_acct     VARCHAR2(150);
l_tr_dept_id       VARCHAR2(150);
l_advance_type     VARCHAR2(150);
l_factsii_pub_law_rec_col VARCHAR2(25);
l_factsii_pub_law_rec  VARCHAR2(150);


l_je_line_creation_date DATE;
l_je_line_modified_date DATE;
l_je_line_period_name   VARCHAR2(15);

l_fund_value 	VARCHAR2(25);

l_gl_date DATE;
l_gl_posted_date DATE;

l_reversal_flag VARCHAR2(1);

l_sla_hdr_event_id NUMBER;
l_sla_hdr_creation_date DATE;
l_sla_entity_id NUMBER;
l_account_class ra_cust_trx_line_gl_dist_all.account_class%TYPE;
l_get_trx_part_from_reimb BOOLEAN;

BEGIN
  l_module_name := g_module_name || 'journal_process';
  l_sob := g_set_of_books_id;
  l_coa := g_coa_id ;
  --l_period_num_low := g_period_num_low;
  --l_period_num_high := g_period_num_high;
  l_period_year := g_period_year;
  --l_p_cbs :='~';
   g_error_code := 0 ;
   g_error_buf  := NULL ;

   BEGIN
     l_jrnl_cursor := DBMS_SQL.OPEN_CURSOR;
   EXCEPTION
   WHEN OTHERS THEN
      g_error_code := SQLCODE;
      g_error_buf  := SQLERRM ||
                      ' -- Error in Journal_Process'||
                      ' procedure due to Open_Cursor.';
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,g_error_buf);
      RETURN;
   END;
   BEGIN
      SELECT 'X', factsI_journal_attribute,
	     factsII_pub_law_code_attribute,
             factsII_advance_type_attribute,
             factsII_tr_main_acct_attribute,
             factsII_tr_dept_id_attribute,
             req_date_seg, pur_order_date_seg,
	     rec_trxn_date_seg, factsii_pub_law_rec_attribute
      INTO   l_exists, l_jrnl_att,
             l_pl_code_col, l_advance_type_col,
             l_tr_main_acct_col, l_tr_dept_id_col,
	     g_req_date_seg, g_pur_order_date_seg,
	     g_rec_trxn_date_seg, l_factsii_pub_law_rec_col
      FROM fv_system_parameters;
      IF (l_jrnl_att IS NULL) THEN
         l_jrnl := NULL;
         g_error_code := 1;
         g_error_buf  := 'Warning in Journal_Process procedure ' ||
                         '- Journal Trading Partner not defined on'||
                         ' System Parameter form';
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,g_error_buf);
      ELSE
         l_jrnl := ' ,gjl.' || l_jrnl_att;
         g_error_code := 0;
         g_error_buf := NULL;
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'JOURNAL ATTRIBUTE COLUMN = '
                                         || l_jrnl_att);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'PLAW COLUMN = '||L_PL_CODE_COL);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'ADV TYPE COLUMN = '||L_ADVANCE_TYPE_COL);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TR MAIN A/C COLUMN = '||L_TR_MAIN_ACCT_COL);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TR DEPT ID COLUMN = '||L_TR_DEPT_ID_COL);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'REQ DATE SEG = '||G_REQ_DATE_SEG);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'PO DATE SEG = '||G_PUR_ORDER_DATE_SEG);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'REC TXN DATE SEG = '||G_REC_TRXN_DATE_SEG);
         END IF;
      END IF;

      -- Set the global variable to false if facts
      -- attributes columns have not been setup else set it to true.
      IF (l_pl_code_col IS NULL OR
          l_advance_type_col IS NULL OR
          l_tr_main_acct_col IS NULL OR
          l_tr_dept_id_col IS NULL)
        THEN
          g_facts_attributes_setup := FALSE ;
       ELSE
          g_facts_attributes_setup := TRUE ;
      END IF;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
       g_error_code := SQLCODE;
       g_error_buf  := 'Error in Journal_Process procedure - Journal '||
                       'Trading Partner and other Parameters not '||
                       'defined on System Parameter form';
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,g_error_buf);
       RETURN;
   WHEN OTHERS THEN
      g_error_code := SQLCODE;
      g_error_buf  := SQLERRM ||
                        ' -- Error in Journal_Process procedure.' ;
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,g_error_buf);
      RETURN;
   END;

   IF (g_source IS NOT NULL)
   THEN
      l_src := ' AND gjh.je_source = '||''''|| g_source ||'''';
   ELSE
      l_src := NULL;
   END IF;

   IF (g_category IS NOT NULL)
   THEN
      l_cat := ' AND gjh.je_category = '||''''|| g_category ||'''';
   ELSE
      l_cat := NULL;
   END IF;

   -- Get cohort Info
     GET_COHORT_INFO ;

    IF g_cohort_seg_name IS NOT NULL Then
	     l_cohort_select := ', GLC.' || g_cohort_seg_name ;
    Else
	     l_cohort_select := ' ' ;
    End IF ;

    --Added for bug 7324241
    IF g_reimb_agree_seg_name IS NOT NULL Then
	     l_reimb_act_select := ', GLC.' || g_reimb_agree_seg_name ;
    Else
	     l_reimb_act_select := ' ' ;
    End IF ;

     -- Get Fiscal year segment name from fv_pya_fiscal_year_segment
   Begin

    SELECT application_column_name
    INTO l_fyr_segment_name
    FROM fv_pya_fiscalyear_segment
    WHERE set_of_books_id = g_set_of_books_id;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FISCAL YR SEGMENT   '||L_FYR_SEGMENT_NAME);
    END IF;

    Exception

    WHEN Others THEN
      g_error_code := SQLCODE;
      g_error_buf  := SQLERRM ;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.select1',g_error_buf);
      RETURN;
    End;

    -- Load segments array table
    load_program_seg;
    IF g_error_code <> 0 THEN
       RETURN;
    END IF;

    IF l_pl_code_col IS NOT NULL THEN
       l_pl_code_col :=  ', gjl.'||l_pl_code_col;
    END IF;
    IF l_tr_main_acct_col IS NOT NULL THEN
       l_tr_main_acct_col := ', gjl.'||l_tr_main_acct_col;
    END IF;
    IF l_tr_dept_id_col IS NOT NULL THEN
       l_tr_dept_id_col := ', gjl.'||l_tr_dept_id_col;
    END IF;
    IF l_advance_type_col IS NOT NULL THEN
       l_advance_type_col := ', gjl.'||l_advance_type_col;
    END IF;

   l_jrnl_select_gl:=
        'SELECT gjl.entered_dr ENTERED_DR,
                gjl.entered_cr ENTERED_CR,
                NVL(gjl.reference_1, ''-100''),
                NVL(gjl.reference_2, ''-100''),
                NVL(gjl.reference_3, ''-100''),
                NVL(gjl.reference_4, ''-100''),
                NVL(gjl.reference_5, ''-100''),
                NVL(gjl.reference_6, ''-100''),
                NVL(gjl.reference_7, ''-100''),
                NVL(gjl.reference_8, ''-100''),
                NVL(gjl.reference_9, ''-100''),
                NVL(gjl.reference_10,''-100''),
                gjl.gl_sl_link_id,
                gjh.je_from_sla_flag,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                gjb.name' || ',
                glc.' || g_acct_segment_name ||
                ', glc.' ||l_fyr_segment_name ||','||
                'gjh.je_category ,
                gjh.je_source ,
                gjl.code_combination_id,
                gjl.je_header_id,
                gjl.creation_date,
                gjl.last_update_date,
                gjl.period_name,
                gjh.date_created,
                gjh.creation_date,
                gjh.created_by ,
                ffp.fund_value,
		            gjl.effective_date,
		            gjh.posted_date,
                gjl.je_header_id,
                gjl.creation_date,
                NULL '||
                l_jrnl ||
                l_cohort_select ||
                l_reimb_act_select ||
                l_pl_code_col || l_advance_type_col ||
                l_tr_dept_id_col || l_tr_main_acct_col ||
              ' FROM  gl_je_batches        gjb,
                gl_je_headers        gjh,
                gl_je_lines          gjl,
                gl_code_combinations glc,
                fv_treasury_symbols  fts,
                fv_fund_parameters   ffp
         WHERE  gjl.code_combination_id = glc.code_combination_id
           AND   gjl.ledger_id    =  :sob_id
           AND   glc.chart_of_accounts_id= :coa_id
           AND   gjh.je_header_id       = gjl.je_header_id
           AND   gjh.je_batch_id        = gjb.je_batch_id
           AND   gjh.currency_code      = :currency_code
           AND   gjh.actual_flag        = :actual_flag
           AND   gjh.posted_date BETWEEN :from_posted_date AND :to_posted_date
           AND   gjl.status             = :status
           AND   gjl.period_name IN
                 (SELECT period_name
                    FROM gl_period_statuses
                   WHERE application_id = 101
                     AND ledger_id  = :sob_id
                     AND period_num BETWEEN :period_num_low
                                    AND :period_num_high
                     AND period_year    = :period_year)
           AND   glc.template_id IS NULL
           AND   fts.treasury_symbol_id = :treasury_symbol_id
           AND   fts.treasury_symbol_id = ffp.treasury_symbol_id
           AND   glc.'||g_bal_segment_name||' = ffp.fund_value
           AND   ffp.set_of_books_id =  :sob_id
           AND   fts.set_of_books_id =  :sob_id
            AND NVL(gjh.je_from_sla_flag, ''N'') = ''N''
           '|| l_src || l_cat ;

   l_jrnl_select_xla :=
        'SELECT xdl.unrounded_accounted_dr ENTERED_DR,
                xdl.unrounded_accounted_cr ENTERED_CR,
                ''-100'',
                ''-100'',
                ''-100'',
                ''-100'',
                ''-100'',
                ''-100'',
                ''-100'',
                ''-100'',
                ''-100'',
                ''-100'',
                gjl.gl_sl_link_id,
                gjh.je_from_sla_flag,
                xdl.source_distribution_id_num_1,
                xdl.source_distribution_type,
                xdl.applied_to_source_id_num_1,
                xdl.applied_to_dist_id_num_1,
                xah.event_type_code,
                gjb.name' || ',
                glc.' || g_acct_segment_name ||
                ', glc.' ||l_fyr_segment_name ||','||
                'gjh.je_category ,
                gjh.je_source ,
                gjl.code_combination_id,
                gjl.je_header_id,
                gjl.creation_date,
                gjl.last_update_date,
                gjl.period_name,
                gjh.date_created,
                gjh.creation_date,
                gjh.created_by ,
                ffp.fund_value,
		            gjl.effective_date,
		            gjh.posted_date,
                xah.event_id,
                xah.creation_date,
                xah.entity_id '||
                l_jrnl ||
                l_cohort_select ||
                l_reimb_act_select ||
                l_pl_code_col || l_advance_type_col ||
                l_tr_dept_id_col || l_tr_main_acct_col ||
              ' FROM  gl_je_batches        gjb,
                gl_je_headers        gjh,
                gl_je_lines          gjl,
                gl_code_combinations glc,
                fv_treasury_symbols  fts,
                fv_fund_parameters   ffp,
                xla_ae_lines         xal,
                xla_ae_headers       xah,
                xla_distribution_links xdl,
                gl_import_references gir
         WHERE  gjl.code_combination_id = glc.code_combination_id
           AND   gjl.ledger_id    =  :sob_id
           AND   glc.chart_of_accounts_id= :coa_id
           AND   gjh.je_header_id       = gjl.je_header_id
           AND   gjh.je_batch_id        = gjb.je_batch_id
           AND   gjh.currency_code      = :currency_code
           AND   gjh.actual_flag        = :actual_flag
           AND   gjh.posted_date BETWEEN :from_posted_date AND :to_posted_date
           AND   gjl.status             = :status
           AND   gjl.period_name IN
                 (SELECT period_name
                    FROM gl_period_statuses
                   WHERE application_id = 101
                     AND ledger_id  = :sob_id
                     AND period_num BETWEEN :period_num_low
                                    AND :period_num_high
                     AND period_year    = :period_year)
           AND   glc.template_id IS NULL
           AND   fts.treasury_symbol_id = :treasury_symbol_id
           AND   fts.treasury_symbol_id = ffp.treasury_symbol_id
           AND   glc.'||g_bal_segment_name||' = ffp.fund_value
           AND   ffp.set_of_books_id =  :sob_id
           AND   fts.set_of_books_id =  :sob_id
           AND   gir.je_batch_id = gjb.je_batch_id
           AND   gir.je_header_id = gjh.je_header_id
           AND   gir.je_line_num = gjl.je_line_num
           AND   xal.gl_sl_link_id = gir.gl_sl_link_id
           AND   xal.gl_sl_link_table = gir.gl_sl_link_table
           AND   xdl.ae_line_num = xal.ae_line_num
           AND   xdl.ae_header_id = xal.ae_header_id
           AND   xah.ae_header_id = xal.ae_header_id
and (NVL(gjl.entered_dr,0) <> 0 OR
     NVL(gjl.entered_cr,0) <> 0)
and (NVL(xal.entered_dr,0) <> 0 OR
     NVL(xal.entered_cr,0) <> 0)
and xdl.accounting_line_code NOT LIKE ''FV_REQ_ADJ%'''||
           ' AND gjh.je_from_sla_flag = ''Y''
           '|| l_src || l_cat ||
           ' ORDER BY  fund_value , ' || g_acct_segment_name ;

  fnd_file.put_line (fnd_file.log, ':sob_id='|| l_sob);
   fnd_file.put_line (fnd_file.log, ':coa_id='|| l_coa);
   fnd_file.put_line (fnd_file.log, ':currency_code='|| g_currency_code);
   fnd_file.put_line (fnd_file.log, ':actual_flag='|| 'A');
   fnd_file.put_line (fnd_file.log, ':from_posted_date='|| g_from_gl_posted_date);
   fnd_file.put_line (fnd_file.log, ':to_posted_date='|| g_to_gl_posted_date);
   fnd_file.put_line (fnd_file.log, ':status='|| 'P');
   fnd_file.put_line (fnd_file.log, ':period_num_low='|| g_period_num_low);
   fnd_file.put_line (fnd_file.log, ':period_num_high='|| g_period_num_high);
   fnd_file.put_line (fnd_file.log, ':period_year='|| l_period_year);
   fnd_file.put_line (fnd_file.log, ':treasury_symbol_id='|| g_treasury_symbol_id);

   BEGIN
      l_jrnl_select := l_jrnl_select_gl||' UNION ALL '||l_jrnl_select_xla;
      DBMS_SQL.PARSE(l_jrnl_cursor, l_jrnl_select, DBMS_SQL.V7);

   EXCEPTION
   WHEN OTHERS THEN
      g_error_code := SQLCODE;
      g_error_buf  := SQLERRM ||
      		      ' -- Error in Journal_Process procedure due '||
                      'to cursor Parse.';
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.select1',g_error_buf);
      RETURN;
   END;

--   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
--     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,L_JRNL_SELECT);
--   END IF;

   -- Bind the variables
   dbms_sql.bind_variable(l_jrnl_cursor, ':sob_id', l_sob);
   dbms_sql.bind_variable(l_jrnl_cursor, ':coa_id', l_coa);
   dbms_sql.bind_variable(l_jrnl_cursor, ':currency_code', g_currency_code);
   dbms_sql.bind_variable(l_jrnl_cursor, ':actual_flag', 'A');
   dbms_sql.bind_variable(l_jrnl_cursor, ':from_posted_date', g_from_gl_posted_date);
   dbms_sql.bind_variable(l_jrnl_cursor, ':to_posted_date', g_to_gl_posted_date);
   dbms_sql.bind_variable(l_jrnl_cursor, ':status', 'P');
   dbms_sql.bind_variable(l_jrnl_cursor, ':sob_id', l_sob);
   dbms_sql.bind_variable(l_jrnl_cursor, ':period_num_low', g_period_num_low);
   dbms_sql.bind_variable(l_jrnl_cursor, ':period_num_high', g_period_num_high);
   dbms_sql.bind_variable(l_jrnl_cursor, ':period_year', l_period_year);
   dbms_sql.bind_variable(l_jrnl_cursor, ':treasury_symbol_id', g_treasury_symbol_id);
   dbms_sql.bind_variable(l_jrnl_cursor, ':sob_id', l_sob);
   dbms_sql.bind_variable(l_jrnl_cursor, ':sob_id', l_sob);
   dbms_sql.bind_variable(l_jrnl_cursor, ':sob_id', l_sob);

   counter := 1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter, l_entered_dr);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter, l_entered_cr);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter, l_reference_1, 80);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter, l_reference_2, 80);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter, l_reference_3, 80);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter, l_reference_4, 80);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter, l_reference_5, 80);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter, l_reference_6, 80);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter, l_reference_7, 80);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_reference_8, 80);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_reference_9, 80);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_reference_10,80);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_gl_sl_link_id);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_je_from_sla_flag, 1);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_source_distribution_id_num_1);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_source_distribution_type, 30);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_applied_to_source_id_num_1);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_applied_to_dist_id_num_1);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_event_type_code, 30);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_name, 150);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_account_number, 25);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_seg_fiscal_yr,4);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_category, 80);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_source, 80);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_ccid);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_je_header_id);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_je_line_creation_date);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_je_line_modified_date);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_je_line_period_name, 15);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_date_created);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_creation_date);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_created_by);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_fund_value,25);
   -- DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, 27,l_proj,90);

   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_gl_date);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_gl_posted_date);
   counter := counter+1;

   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_sla_hdr_event_id);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_sla_hdr_creation_date);
   counter := counter+1;
   DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,l_sla_entity_id);
   counter := counter+1;


   IF (l_jrnl_att IS NOT NULL) THEN
      DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor, counter,
                             l_jrnl_att_value, 240);
      counter := counter+1;
   END IF;

   IF g_cohort_seg_name IS NOT NULL Then
     DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor,
                            counter,l_cohort_year, 25);
      counter := counter+1;
   END IF;

   IF g_reimb_agree_seg_name IS NOT NULL Then
     DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor,
                            counter,l_reimb_agree_seg_val, 25);
      counter := counter+1;
   END IF;


   IF l_pl_code_col IS NOT NULL Then
     DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor,
                            counter,l_pl_code, 150);
      counter := counter+1;
   END IF;

   IF l_advance_type_col IS NOT NULL Then
     DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor,
                            counter,l_advance_type, 150);
      counter := counter+1;
   END IF;

   IF l_tr_dept_id_col IS NOT NULL Then
     DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor,
                            counter,l_tr_dept_id, 150);
      counter := counter+1;
   END IF;

   IF l_tr_main_acct_col IS NOT NULL Then
     DBMS_SQL.DEFINE_COLUMN(l_jrnl_cursor,
                            counter,l_tr_main_acct, 150);
      counter := counter+1;
   END IF;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'SOB_ID: '|| L_SOB);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'COA_ID: '|| L_COA);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CURRENCY_CODE: '|| G_CURRENCY_CODE);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'ACTUAL_FLAG: '|| 'A');
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'STATUS: '|| 'P');
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'PERIOD_NUM_LOW: '|| G_PERIOD_NUM_LOW);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'PERIOD_NUM_HIGH: '|| G_PERIOD_NUM_HIGH);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'PERIOD_YEAR: '|| L_PERIOD_YEAR);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TREASURY_SYMBOL_ID: '|| G_TREASURY_SYMBOL_ID);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,substr(l_jrnl_select,1,1000));
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,substr(l_jrnl_select,1001,1000));
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,substr(l_jrnl_select,2001,1000));
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,substr(l_jrnl_select,3001,1000));
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,substr(l_jrnl_select,4001,1000));
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,substr(l_jrnl_select,5001,1000));
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,substr(l_jrnl_select,6001,1000));
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,substr(l_jrnl_select,7001,1000));
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,substr(l_jrnl_select,8001,1000));
    END IF;



   BEGIN
      l_exec_ret := dbms_sql.execute(l_jrnl_cursor);
   EXCEPTION
   WHEN OTHERS THEN
       g_error_code := SQLCODE;
       g_error_buf := SQLERRM ||
      		      ' -- Error in Journal_Process procedure due '||
                      'to cursor Execute.';
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.message1',G_ERROR_BUF);
      RETURN;
   END;
      i := 0;
   LOOP
     -- Reset The FACTS Attributes
       RESET_FACTS_ATTRIBUTES ;

      l_account_number 		:= NULL;
      l_bal_segment 		:= NULL;
      l_sgl_acct_num 		:= NULL;
      l_fund_group  		:= NULL;
      l_dept_id     		:= NULL;
      l_bureau_id   		:= NULL;
      l_bal_segment 		:= NULL;
      l_vendor_id 	 	:= NULL;
      l_vendor_type 	 	:= NULL;
      l_eliminations_id  	:= NULL;
      l_entered_dr		:= NULL;
      l_entered_cr		:= NULL;
      l_je_header_id		:= NULL;
      l_source			:= NULL;
      l_category	      	:= NULL;
      l_name			:= NULL;
      l_date_created		:= NULL;
      l_reference_1 		:= NULL;
      l_refer2 			:= NULL;
      l_reference_2 		:= NULL;
      l_reference_3 		:= NULL;
      l_reference_4		:= NULL;
      l_reference_5 		:= NULL;
      l_reference_6 		:= NULL;
      l_reference_7 		:= NULL;
      l_reference_8 		:= NULL;
      l_reference_9 		:= NULL;
      l_reference_10 		:= NULL;
      l_doc_num			:= NULL;
      l_doc_date	      	:= NULL;
      l_doc_creation_date	:= NULL;
      l_doc_created_by	        := NULL;
      l_ccid			:= NULL;
      l_creation_date		:= NULL;
      l_created_by		:= NULL;
      l_entry_user		:= NULL;
      l_cat_b_seg_val_set_id 	:= NULL;
      l_cat_b_seg_value     	:= NULL;
      l_cat_b_text          	:= NULL;
      l_prn_num                 := NULL;
      l_prn_text                := NULL;
      l_je_line_creation_date   := NULL;
      l_je_line_modified_date   := NULL;
      l_je_line_period_name     := NULL;

      g_public_law_code_val     := NULL;
      g_src_flag		:= NULL;

      l_fund_value		:= NULL;
      l_gl_date			:= NULL;
      l_gl_posted_date		:= NULL;

      l_sla_hdr_event_id := NULL;
      l_sla_hdr_creation_date := NULL;
      l_sla_entity_id := NULL;
      l_account_class := NULL;
      l_reimb_agree_seg_val := NULL;
      l_get_trx_part_from_reimb := FALSE;

      l_jrnl_fetch := DBMS_SQL.FETCH_ROWS(l_jrnl_cursor);

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'L_JRNL_FETCH '||L_JRNL_FETCH);
      END IF;

      IF (l_jrnl_fetch = 0)
      THEN
	 IF (i = 0)
	 THEN
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'NO JOURNAL TRANSACTIONS'||
                              ' to process for '||g_treasury_symbol||' !!!');
     END IF;
	 END IF;
         EXIT;  --  Exit the loop
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'MUST EXIT THE LOOP');
        END IF;
      END IF;

      -- Fetch the records into variables
      counter := 1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter, l_entered_dr);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter, l_entered_cr);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter, l_reference_1);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter, l_reference_2);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter, l_reference_3);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter, l_reference_4);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter, l_reference_5);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter, l_reference_6);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter, l_reference_7);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_reference_8);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_reference_9);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_reference_10);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_gl_sl_link_id);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_je_from_sla_flag);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_source_distribution_id_num_1);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_source_distribution_type);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_applied_to_source_id_num_1);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_applied_to_dist_id_num_1);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_event_type_code);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_name);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_account_number);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_seg_fiscal_yr);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_category);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_source);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_ccid);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_je_header_id);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_je_line_creation_date);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_je_line_modified_date);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_je_line_period_name);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_date_created);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_creation_date);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_created_by);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_fund_value);
      counter := counter+1;
      -- DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, 27,l_proj);
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_gl_date);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_gl_posted_date);
      counter := counter+1;

      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_sla_hdr_event_id);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_sla_hdr_creation_date);
      counter := counter+1;
      DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor, counter,l_sla_entity_id);
      counter := counter+1;



      IF (l_jrnl_att IS NOT NULL)
      THEN
  	 DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor,
                               counter, l_jrnl_att_value);
        counter := counter+1;
      ELSE
  	 l_jrnl_att_value := NULL;
      END IF;

      IF g_cohort_seg_name IS NOT NULL THEN
   	     DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor,
                              counter,l_cohort_year);
        counter := counter+1;
      ELSE
        l_cohort_year := NULL;
      END IF;

      IF g_reimb_agree_seg_name IS NOT NULL THEN
        	DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor,
                              counter,l_reimb_agree_seg_val);
        counter := counter+1;
      ELSE
        l_reimb_agree_seg_val := NULL;
      END IF;


      IF l_pl_code_col IS NOT NULL THEN
        DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor,
                              counter,l_pl_code);
        counter := counter+1;
      END IF;

      IF l_advance_type_col IS NOT NULL THEN
        DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor,
                              counter,l_advance_type);
        counter := counter+1;
      END IF;

      IF l_tr_dept_id_col IS NOT NULL THEN
        DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor,
                              counter,l_tr_dept_id);
        counter := counter+1;
      END IF;

      IF l_tr_main_acct_col IS NOT NULL THEN
        DBMS_SQL.COLUMN_VALUE(l_jrnl_cursor,
                              counter,l_tr_main_acct);
      END IF;

      l_valid_flag  := 'Y';
      l_feeder_flag := 'Y';
      i := 1;
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'');
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'PROCESSING ACCOUNT NUMBER - '
                                     || l_account_number);
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'------------------------');
fv_utility.debug_mesg(FND_LOG.LEVEL_STATEMENT, l_module_name,'****g_transaction_partner_val:'||g_transaction_partner_val);
      END IF;

      -- Get Fund Group, Dept_id, Bureau_code and Balancing Segment.
      GET_FUND_GROUP_INFO (l_ccid,
                           l_fund_group,
                           l_dept_id,
                           l_bureau_id,
                           l_bal_segment);
      IF (g_error_code <> 0)
      THEN
         RETURN;
      END IF;

      -- Get the account or the parent account
      BEGIN
          SELECT  'X'
            INTO   l_exists
            FROM   FV_FACTS_ATTRIBUTES
           WHERE   facts_acct_number = l_account_number
             AND   set_of_books_id = g_set_of_books_id;
--             AND   EXISTS (SELECT 'X'
--                             FROM fv_facts_ussgl_accounts
--                            WHERE ussgl_account = l_account_number);

	 -- Account Number exists in FV_FACTS_ATTRIBUTES table
	 -- and can be used to get FACTS attributes.
         -- l_sgl_acct_num := l_account_number;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'LOADING FACTS ATTRIBUTES '||
                                  'for the child account -'||l_account_number);
      END IF;
	    LOAD_FACTS_ATTRIBUTES (l_account_number, l_bal_segment)  ;

	 -- l_sgl_acct_num := Null;
 	 -- GET_SGL_PARENT(l_account_number,  l_sgl_acct_num) ;
       EXCEPTION
          WHEN NO_DATA_FOUND Then

            --Reset the SGl Account number

	    l_sgl_acct_num := Null;
	    GET_SGL_PARENT(l_account_number,  l_sgl_acct_num) ;

	    IF l_sgl_acct_num IS NOT NULL Then
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'LOADING FACTS ATTRIBUTES '||
                                             'for the parent account -'||l_sgl_acct_num);
      END IF;
		LOAD_FACTS_ATTRIBUTES (l_sgl_acct_num, l_bal_segment)  ;
	    END IF;
        END ;

      -- Get the USSGL/Parent account
      BEGIN
	  SELECT  'X'
	  INTO l_exists
	  FROM fv_facts_ussgl_accounts
	  WHERE ussgl_account = l_account_number;

	  l_sgl_acct_num := l_account_number;
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CHILD ACCOUNT IS A USSGL: '|| L_SGL_ACCT_NUM);
      END IF;
      EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	     l_sgl_acct_num := Null;
	     GET_SGL_PARENT(l_account_number,  l_sgl_acct_num);
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'PARENT ACCOUNT: '|| L_SGL_ACCT_NUM);
      END IF;
      END;

      IF (g_error_code <> 0)
      THEN
         RETURN;
      END IF;

       -------------------------------------------------------------
       -- Deriving the Cohort Value
       -------------------------------------------------------------
       BEGIN
         IF l_cohort_year IS NOT NULL THEN
          BEGIN
            l_cohort_num_year := l_cohort_year;
            IF l_cohort_num_year < 10 THEN
               l_cohort_year := g_period_year;
            END IF;

          EXCEPTION
            WHEN INVALID_NUMBER THEN
              l_cohort_year := g_period_year;
            WHEN VALUE_ERROR THEN
              l_cohort_year := g_period_year;
          END;


          IF (LENGTH(l_cohort_year) > 2) THEN
            l_cohort := substr(l_cohort_year,3,2);
          ELSE
            l_cohort := substr(l_cohort_year,1,2);
          END IF;
        END IF;
      END ;

       ------------------------------------------------------------
       -- Deriving the Category Text and Sequence
       -------------------------------------------------------------
      IF g_appor_cat_val IN ('A', 'B') THEN
         get_prc_val(l_ccid, l_fund_value,
                     l_cbs_num, l_cat_b_text,l_prn_num,l_prn_text);


     /*       -- 2005 FACTS II Enhancemnt to include category C
      ELSIF g_appor_cat_val = 'C' THEN
             l_cat_b_text := 'Default Cat B Code';
             l_cbs_num :=  '000';
             l_prn_num := '000';
             l_prn_text := 'Default PRN Code'; */

      ELSE
             l_cat_b_text :=' ';
             l_cbs_num := '';
             l_prn_num := '';
             l_prn_text := '';

      END IF;
/*
   -------------------------------------------------
   -- Default the Reporting codes when the
   -- Apportionment Category Code is N
   -------------------------------------------------
  IF NVL(g_appor_cat_flag,'N') = 'N' THEN
     IF g_fund_category IN ('A','S','B','T','R','C') THEN

            l_cat_b_text := 'Default Cat B Code';
            l_cbs_num    := '000';
            l_prn_num    := '000';
            l_prn_text   := 'Default PRN Code';


      IF ( FND_LOG.LEVEL_STATEMENT >=
         FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                    l_module_name, 'Defaulting the Reporting'
                                ||'codes as the apportionment '
                                   ||'Category flag is N ') ;
       End If ;

    END IF;

  END IF;   */


       ---- End FACTS Trial Balance CBT code.

      IF (l_je_from_sla_flag = 'Y') THEN
        IF (l_source = 'Payables' AND l_category <> 'Treasury Confirmation') THEN
          IF (l_source_distribution_type IN ( 'AP_INV_DIST', 'AP_PREPAY')) THEN
            BEGIN
              SELECT aid.invoice_id,
                     aid.distribution_line_number
                INTO l_reference_2,
                     l_reference_8
                FROM ap_invoice_distributions_all aid
               WHERE aid.invoice_distribution_id = l_source_distribution_id_num_1;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                fnd_file.put_line (fnd_file.log, 'No data found for distribution id(1) '||l_source_distribution_id_num_1);
            END;
          ELSIF (l_source_distribution_type IN ('AP_PMT_DIST')) THEN
            BEGIN
              SELECT aid.invoice_id,
                     aid.distribution_line_number
                INTO l_reference_2,
                     l_reference_8
                FROM ap_invoice_distributions_all aid
               WHERE aid.invoice_distribution_id = l_applied_to_dist_id_num_1;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                fnd_file.put_line (fnd_file.log, 'No data found for distribution id(1a) '||l_applied_to_dist_id_num_1);
            END;

            BEGIN
              SELECT aip.check_id,
                     aid.invoice_id,
                     aid.accounting_date
                INTO l_reference_3,
                     l_reference_4,
                     l_reference_6
                FROM ap_payment_hist_dists aphd,
                     ap_invoice_distributions_all aid,
                     ap_invoice_payments_all aip
               WHERE aphd.payment_hist_dist_id = l_source_distribution_id_num_1
                  AND aid.invoice_distribution_id = aphd.invoice_distribution_id
                  AND aip.invoice_payment_id = aphd.invoice_payment_id;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                fnd_file.put_line (fnd_file.log, 'No data found for distribution id(1b) '||l_source_distribution_id_num_1);
            END;

          END IF;
        ELSIF (l_source = 'Purchasing' AND l_category = 'Purchases') THEN
          IF (l_source_distribution_type ='PO_DISTRIBUTIONS_ALL') THEN
            l_reference_1 := 'PO';
            l_reference_3 := l_source_distribution_id_num_1;
            BEGIN
              SELECT poh.po_header_id,
                     poh.segment1
                INTO l_reference_2,
                     l_reference_4
                FROM po_distributions_all pod,
                     po_headers_all poh
               WHERE pod.po_distribution_id = l_source_distribution_id_num_1
                 AND pod.po_header_id = poh.po_header_id;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                fnd_file.put_line (fnd_file.log, 'No data found for distribution id(2) '||l_source_distribution_id_num_1);
            END;
          ELSIF (l_source_distribution_type ='PO_REQ_DISTRIBUTIONS_ALL') THEN
            l_reference_1 := 'REQ';
            l_reference_3 := l_source_distribution_id_num_1;
            BEGIN
              --Modified for bug 7253838
              --Get the po number instead of the requisition number
              --for a requisition liquidation line
              SELECT poh.requisition_header_id
                     --, poh.segment1
                INTO l_reference_2
                     --, l_reference_4
                FROM po_req_distributions_all pod,
                     po_requisition_headers_all poh,
                     po_requisition_lines_all pol
               WHERE pod.distribution_id = l_source_distribution_id_num_1
                 AND pol.requisition_header_id = poh.requisition_header_id
                 AND pod.requisition_line_id = pol.requisition_line_id;

                 fv_utility.log_mesg('l_sla_entity_id: '||l_sla_entity_id);
                 SELECT transaction_number
                 INTO   l_reference_4
                 FROM   xla_transaction_entities
                 WHERE  entity_id = l_sla_entity_id;
                 fv_utility.log_mesg('l_reference_4: '||l_reference_4);

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                fnd_file.put_line (fnd_file.log, 'No data found for distribution id(3) '||l_source_distribution_id_num_1);
            END;
          END IF;
        ELSIF (l_source = 'Purchasing' AND l_category = 'Requisitions') THEN
            l_reference_1 := 'REQ';
            l_reference_3 := l_source_distribution_id_num_1;
            BEGIN
              SELECT poh.requisition_header_id,
                     poh.segment1
                INTO l_reference_2,
                     l_reference_4
                FROM po_req_distributions_all pod,
                     po_requisition_headers_all poh,
                     po_requisition_lines_all pol
               WHERE pod.distribution_id = l_source_distribution_id_num_1
                 AND pol.requisition_header_id = poh.requisition_header_id
                 AND pod.requisition_line_id = pol.requisition_line_id;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                fnd_file.put_line (fnd_file.log, 'No data found for distribution id(4) '||l_source_distribution_id_num_1);
            END;
	      ELSIF (l_source = 'Budgetary Transaction') THEN
          IF (l_source_distribution_type ='FV_TREASURY_CONFIRMATIONS_ALL') THEN
            l_source := 'Payables';
            l_category := 'Treasury Confirmation';
            l_reference_1 := l_applied_to_source_id_num_1;
            IF (l_event_type_code = 'TREASURY_VOID') THEN
              l_name := 'VOID '||l_name;
            END IF;
            BEGIN

              SELECT aip.check_id,
                     aid.invoice_id,
                     aid.accounting_date
                INTO l_reference_3,
                     l_reference_4,
                     l_reference_6
                FROM ap_payment_hist_dists aphd,
                     ap_invoice_distributions_all aid,
                     ap_invoice_payments_all aip
               WHERE aphd.payment_hist_dist_id = l_source_distribution_id_num_1
                  AND aid.invoice_distribution_id = aphd.invoice_distribution_id
                  AND aip.invoice_payment_id = aphd.invoice_payment_id;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                fnd_file.put_line (fnd_file.log, 'No data found for distribution id(5) '||l_source_distribution_id_num_1);
            END;
          ELSE
            l_reference_1 := l_source_distribution_id_num_1;
          END IF;
	      ELSIF (l_source = 'Cost Management' AND l_category = 'Receiving') THEN
          l_source := 'Purchasing';
          l_reference_1 := 'PO';
          l_reference_3 := l_source_distribution_id_num_1;
          BEGIN
            SELECT poh.po_header_id,
                   poh.segment1
              INTO l_reference_2,
                   l_reference_4
              FROM po_distributions_all pod,
                   po_headers_all poh
             WHERE pod.po_distribution_id = l_applied_to_dist_id_num_1
               AND pod.po_header_id = poh.po_header_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              fnd_file.put_line (fnd_file.log, 'No data found for distribution id(6a) '||l_applied_to_dist_id_num_1);
          END;
          BEGIN
            SELECT rcv_transaction_id
              INTO l_reference_5
              FROM rcv_receiving_sub_ledger
             WHERE rcv_sub_ledger_id = l_source_distribution_id_num_1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              fnd_file.put_line (fnd_file.log, 'No data found for distribution id(6b) '||l_source_distribution_id_num_1);
          END;
	      ELSIF (l_source = 'Receivables' AND l_category = 'Receipts') THEN
          BEGIN
            fnd_file.put_line (fnd_file.log, 'l_source_distribution_id_num_1='||l_source_distribution_id_num_1);
            SELECT source_id,
                   source_table,
                   source_type
              INTO l_ar_source_id,
                   l_ar_source_table,
                   l_ar_source_type
              FROM ar_distributions_all
             WHERE line_id = l_source_distribution_id_num_1;
            fnd_file.put_line (fnd_file.log, 'l_ar_source_id='||l_ar_source_id);
            fnd_file.put_line (fnd_file.log, 'l_ar_source_table='||l_ar_source_table);
            fnd_file.put_line (fnd_file.log, 'l_ar_source_type='||l_ar_source_type);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              fnd_file.put_line (fnd_file.log, 'No data found for distribution id(7a) '||l_source_distribution_id_num_1);
          END;
          IF (l_ar_source_table = 'RA') THEN
            BEGIN
              l_reference_2 := l_ar_source_id;
              SELECT receipt_number,
                     --hca.party_id
                     hca.cust_account_id
                INTO l_reference_4,
                     l_reference_7
                FROM ar_receivable_applications_all ara,
                     ar_cash_receipts_all acr,
                     hz_cust_site_uses_all hcsu,
                     hz_cust_acct_sites_all hcas,
                     hz_cust_accounts hca
               WHERE ara.receivable_application_id = l_ar_source_id
                 AND ara.cash_receipt_id = acr.cash_receipt_id
                 AND hcsu.site_use_id = acr.customer_site_use_id
                 AND hcas.cust_acct_site_id = hcsu.cust_acct_site_id
                 AND hca.cust_account_id = hcas.cust_account_id;

            fnd_file.put_line (fnd_file.log, 'l_reference_4='||l_reference_4);
            fnd_file.put_line (fnd_file.log, 'l_reference_7='||l_reference_7);
            fnd_file.put_line (fnd_file.log, 'l_reference_2='||l_reference_2);

              l_reference_5 := l_reference_4;
              l_category := 'Trade Receipts';
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                fnd_file.put_line (fnd_file.log, 'No data found for distribution id(7b) '||l_applied_to_dist_id_num_1);
            END;
          ELSIF (l_ar_source_table = 'CRH') THEN
              l_reference_2 := l_ar_source_id;
            BEGIN
              SELECT receipt_number,
                     --hca.party_id
                     hca.cust_account_id
                INTO l_reference_4,
                     l_reference_7
                FROM ar_cash_receipt_history_all ara,
                     ar_cash_receipts_all acr,
                     hz_cust_site_uses_all hcsu,
                     hz_cust_acct_sites_all hcas,
                     hz_cust_accounts hca
               WHERE ara.cash_receipt_history_id = l_ar_source_id
                 AND ara.cash_receipt_id = acr.cash_receipt_id
                 AND hcsu.site_use_id = acr.customer_site_use_id
                 AND hcas.cust_acct_site_id = hcsu.cust_acct_site_id
                 AND hca.cust_account_id = hcas.cust_account_id;

            --fnd_file.put_line (fnd_file.log, 'l_reference_4='||l_reference_4);
            --fnd_file.put_line (fnd_file.log, 'l_reference_7='||l_reference_7);
            --fnd_file.put_line (fnd_file.log, 'l_reference_2='||l_reference_2);

              l_reference_5 := l_reference_4;
              l_category := 'Trade Receipts';
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                fnd_file.put_line (fnd_file.log, 'No data found for distribution id(7c) '||l_applied_to_dist_id_num_1);
            END;
          ELSIF (l_ar_source_table = 'ADJ') THEN
              l_reference_2 := l_ar_source_id;
            BEGIN
              SELECT receipt_number,
                     --hca.party_id
                     hca.cust_account_id
                INTO l_reference_4,
                     l_reference_7
                FROM ar_adjustments_all ara,
                     ar_cash_receipts_all acr,
                     hz_cust_site_uses_all hcsu,
                     hz_cust_acct_sites_all hcas,
                     hz_cust_accounts hca
               WHERE ara.adjustment_id = l_ar_source_id
                 AND ara.associated_cash_receipt_id = acr.cash_receipt_id
                 AND hcsu.site_use_id = acr.customer_site_use_id
                 AND hcas.cust_acct_site_id = hcsu.cust_acct_site_id
                 AND hca.cust_account_id = hcas.cust_account_id;

            --fnd_file.put_line (fnd_file.log, 'l_reference_4='||l_reference_4);
            --fnd_file.put_line (fnd_file.log, 'l_reference_7='||l_reference_7);
            --fnd_file.put_line (fnd_file.log, 'l_reference_2='||l_reference_2);

              l_reference_5 := l_reference_4;
              l_category := 'Trade Receipts';
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                fnd_file.put_line (fnd_file.log, 'No data found for distribution id(7d) '||l_applied_to_dist_id_num_1);
            END;
          ELSIF (l_ar_source_table = 'MCD') THEN
              l_reference_2 := l_ar_source_id;
            BEGIN
              SELECT receipt_number,
                     --hca.party_id
                     hca.cust_account_id
                INTO l_reference_4,
                     l_reference_7
                FROM ar_misc_cash_distributions_all ara,
                     ar_cash_receipts_all acr,
                     hz_cust_site_uses_all hcsu,
                     hz_cust_acct_sites_all hcas,
                     hz_cust_accounts hca
               WHERE ara.misc_cash_distribution_id = l_ar_source_id
                 AND ara.cash_receipt_id = acr.cash_receipt_id
                 AND hcsu.site_use_id = acr.customer_site_use_id
                 AND hcas.cust_acct_site_id = hcsu.cust_acct_site_id
                 AND hca.cust_account_id = hcas.cust_account_id;

            --fnd_file.put_line (fnd_file.log, 'l_reference_4='||l_reference_4);
            --fnd_file.put_line (fnd_file.log, 'l_reference_7='||l_reference_7);
            --fnd_file.put_line (fnd_file.log, 'l_reference_2='||l_reference_2);

              l_reference_5 := l_reference_4;
              l_category := 'Trade Receipts';
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                fnd_file.put_line (fnd_file.log, 'No data found for distribution id(7e) '||l_applied_to_dist_id_num_1);
            END;
          ELSIF (l_ar_source_table = 'TH') THEN
              l_reference_2 := l_ar_source_id;
            BEGIN
              SELECT rcth.trx_number,
                     rcth.bill_to_customer_id
                INTO l_reference_4,
                     l_reference_7
                FROM ar_transaction_history_all ara,
                     ra_customer_trx_all rcth
               WHERE ara.transaction_history_id = l_ar_source_id
                 AND ara.customer_trx_id = rcth.customer_trx_id;

            --fnd_file.put_line (fnd_file.log, 'l_reference_4='||l_reference_4);
            --fnd_file.put_line (fnd_file.log, 'l_reference_7='||l_reference_7);
            --fnd_file.put_line (fnd_file.log, 'l_reference_2='||l_reference_2);

              l_reference_5 := l_reference_4;
              l_category := 'Trade Receipts';
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                fnd_file.put_line (fnd_file.log, 'No data found for distribution id(7f) '||l_applied_to_dist_id_num_1);
            END;
          END IF;
	      ELSIF (l_source = 'Receivables' AND
                      (l_category = 'Sales Invoices' OR
                       l_category = 'Debit Memos')
                    ) THEN
          BEGIN
            --Bug 7121539
	          --customer_trx_line_id will be null in ra_cust_trx_line_gl_dist_all
	          --for account class 'REC', hence using customer_trx_id to get
	          --details instead of customer_trx_line_id for these distributions
            SELECT account_class
            INTO   l_account_class
            FROM   ra_cust_trx_line_gl_dist_all
            WHERE  cust_trx_line_gl_dist_id = l_source_distribution_id_num_1;

            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                   'Account class: '||l_account_class);
            END IF;

            IF l_account_class <> 'REC' THEN
               SELECT rcth.trx_number,
                   rcth.bill_to_customer_id,
                   rcth.customer_trx_id
               INTO l_reference_4,
                   l_reference_7,
                   l_reference_2
               FROM ra_cust_trx_line_gl_dist_all rctgl,
                   ra_customer_trx_lines_all rctl,
                   ra_customer_trx_all rcth
               WHERE rctgl.cust_trx_line_gl_dist_id = l_source_distribution_id_num_1
               AND rctl.customer_trx_line_id = rctgl.customer_trx_line_id
               AND rcth.customer_trx_id = rctl.customer_trx_id;
             ELSE
               SELECT rcth.trx_number,
                   rcth.bill_to_customer_id,
                   rcth.customer_trx_id
               INTO l_reference_4,
                   l_reference_7,
                   l_reference_2
               FROM ra_cust_trx_line_gl_dist_all rctgl,
                   ra_customer_trx_all rcth
               WHERE rctgl.cust_trx_line_gl_dist_id = l_source_distribution_id_num_1
               AND rcth.customer_trx_id = rctgl.customer_trx_id;
            END IF;

          fnd_file.put_line (fnd_file.log, 'l_reference_4='||l_reference_4);
          fnd_file.put_line (fnd_file.log, 'l_reference_7='||l_reference_7);
          fnd_file.put_line (fnd_file.log, 'l_reference_2='||l_reference_2);

            l_reference_5 := l_reference_4;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              fnd_file.put_line (fnd_file.log, 'No data found for distribution id(8a) '||l_source_distribution_id_num_1);
          END;
    ELSIF (l_source = 'Receivables' AND l_category = 'Misc Receipts') THEN
          BEGIN
            fnd_file.put_line (fnd_file.log, 'l_source_distribution_id_num_1='||l_source_distribution_id_num_1);
            SELECT source_id,
                   source_table,
                   source_type
              INTO l_ar_source_id,
                   l_ar_source_table,
                   l_ar_source_type
              FROM ar_distributions_all
             WHERE line_id = l_source_distribution_id_num_1;
            fnd_file.put_line (fnd_file.log, 'l_ar_source_id='||l_ar_source_id);
            fnd_file.put_line (fnd_file.log, 'l_ar_source_table='||l_ar_source_table);
            fnd_file.put_line (fnd_file.log, 'l_ar_source_type='||l_ar_source_type);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              fnd_file.put_line (fnd_file.log, 'No data found for distribution id(7a) '||l_source_distribution_id_num_1);
          END;

          IF (l_ar_source_table = 'MCD' ) THEN
            BEGIN
              --Bug8808218. Cash receipt history could bring
	      --multiple rows based on cash reversal.
	      --Restricting the select to fetch the most recent
	      --row from cash receipt history.
              SELECT acr.cash_receipt_id,
                     max(acrh.cash_receipt_history_id),
                     acr.receipt_number
                INTO l_reference_2,
                     l_reference_5,
                     l_reference_4
                FROM ar_misc_cash_distributions_all ara,
                     ar_cash_receipt_history_all acrh,
                     ar_cash_receipts_all acr
               WHERE ara.misc_cash_distribution_id = l_ar_source_id
                 AND ara.cash_receipt_id = acr.cash_receipt_id
                 AND ara.cash_receipt_id = acrh.cash_receipt_id
                 group by acr.cash_receipt_id, acr.receipt_number;

            fnd_file.put_line (fnd_file.log, 'l_reference_5='||l_reference_5);
            fnd_file.put_line (fnd_file.log, 'l_reference_2='||l_reference_2);
            fnd_file.put_line (fnd_file.log, 'l_reference_4='||l_reference_4);

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                fnd_file.put_line (fnd_file.log, 'No data found for distribution id(7e) '||l_applied_to_dist_id_num_1);
            END;
          END IF;
        END IF;
      END IF;

      l_refer2 := l_reference_2;

      SELECT SUBSTR(l_refer2, 0, decode(INSTR(l_refer2, 'C'), 0,
                       LENGTH(l_refer2),INSTR(l_refer2,'C')-1))
      INTO   l_reference_2
      FROM   dual;

   -- Added to handle 3131834 for deobligated invoices in final match
   -- and reversal requisitions created by autocreate PO.
   --
      IF (l_source = 'Purchasing' AND l_category = 'Purchases')
        THEN
          IF l_reference_6 = 'SRCDOC' AND l_reference_10 <> -100
            THEN
              l_reference_2 := l_reference_10 ;
              l_category := 'Purchase Invoices';
              l_source := 'Payables';
	      g_src_flag := '1';
          END IF;
      END IF;

      IF (l_source = 'Purchasing' AND l_category = 'Requisitions')
        THEN
          IF l_reference_6 = 'SRCDOC' AND l_reference_10 <> -100
            THEN
              l_reference_2 := l_reference_10 ;
              l_category := 'Purchases';
	      g_src_flag := '2';
          END IF;
      END IF;

      -- Get the Document Name and its Creation Date
      GET_DOC_INFO (l_je_header_id, l_source, l_category, l_name,
                    l_date_created,l_creation_date, l_created_by,
	            l_reference_1, l_reference_2,l_reference_3,
	            l_reference_4, l_reference_5, l_reference_9,
		    l_refer2, l_doc_num, l_doc_date, l_doc_creation_date,
		    l_doc_created_by, l_gl_date,
                    l_factsii_pub_law_rec_col,
                    l_gl_sl_link_id,
                    l_factsii_pub_law_rec,
                    l_reversal_flag, l_sla_entity_id);

      IF (g_error_code <> 0) THEN
         RETURN;
      END IF;

      -- Get the User Name who created the Document
      GET_DOC_USER (l_doc_created_by, l_entry_user);

      IF (g_error_code <> 0)
      THEN
         RETURN;
      END IF;
      IF (g_govt_non_govt_ind = 'N') THEN
         g_govt_non_govt_val := 'N';
         l_eliminations_id := '';
       ELSIF (NVL(g_govt_non_govt_ind,'X') = 'X')  THEN
         g_govt_non_govt_val := '';
         l_eliminations_id := '';
      END IF;
      --Modified for bug 7256357. Modified to get transaction
      --partner value irrespective of g_govt_non_govt_ind
      --ELSE
        BEGIN
           -------------------------------------------------------------------
           -- Get the vendor id from Payables (Includes invoice and Payments)
           -------------------------------------------------------------------
   	   IF (l_source = 'Payables' AND l_category <> 'Treasury Confirmation')
           THEN
   	     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   SOURCE: '|| L_SOURCE);
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   REFERENCE 2: '|| L_REFERENCE_2);
   	     END IF;
             IF (l_reference_2 IS NOT NULL)
      	     THEN
                BEGIN
	          l_feeder_flag := 'Y';
		  SELECT v.vendor_id vendor_id,
               	   	 v.vendor_type_lookup_code vendor_type,
	       		 fvv.eliminations_id
		  INTO   l_vendor_id, l_vendor_type, l_eliminations_id
		  FROM   ap_invoices_all i,
	       		 po_vendors v,
	       		 fv_facts_vendors_v fvv
	 	  WHERE  i.invoice_id	=  to_number(l_reference_2)
    	   	  AND    i.vendor_id	=  v.vendor_id
	   	  AND    fvv.vendor_id  =  v.vendor_id;
       	       EXCEPTION
               WHEN NO_DATA_FOUND THEN
                     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.select_1','   NO DATA FOUND !!');
	        WHEN INVALID_NUMBER THEN
	         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'Invalid Number passed to REFERENCE_2');
               END;

            ELSE
              IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   REFERENCE_2 I.E. INVOICE_ID IS NULL');
              END IF;
            END IF;
           -------------------------------------------------------------------
           -- Get the Vendor ID for Purchasing Inventory Records
           ------------------------------------------------------------------
           ELSIF (l_source = 'Purchasing') THEN
            IF (l_category = 'Receiving') THEN

   	       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   NAME: '|| L_NAME);
             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   REFERENCE 2: '|| L_REFERENCE_2);
             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   REFERENCE 5: '|| L_REFERENCE_5);
   	      END IF;
              IF (l_reference_2 IS NOT NULL AND
                              l_reference_5 IS NOT NULL)  THEN
               BEGIN
         	  l_feeder_flag := 'Y';
		  SELECT  v.vendor_id VENDOR_ID,
		 	  v.vendor_type_lookup_code VENDOR_TYPE,
			  fvv.eliminations_id
		  INTO   l_vendor_id,l_vendor_type,l_eliminations_id
		  FROM 	 rcv_transactions rt,
			 po_vendors v,
			 po_headers_all ph,
			 fv_facts_vendors_v fvv
	  	  WHERE rt.po_header_id       = to_number(l_reference_2)
	  	  AND   rt.transaction_id     = to_number(l_reference_5)
	  	  AND   rt.po_header_id	     = ph.po_header_id
	  	  AND   v.vendor_id 	     = ph.vendor_id
	  	  AND   fvv.vendor_id	     = ph.vendor_id;
       	        EXCEPTION
                WHEN NO_DATA_FOUND THEN
		     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'NO DATA FOUND WHEN SOURCE'||
                                                        ' is Purchasing and category'||
                                                        ' is Receiving!!');
                     END IF;

               WHEN INVALID_NUMBER THEN
	         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'Invalid Number passed to REFERENCE_5');
       	       END;
            ELSE
	       IF (l_reference_2 IS NULL)     THEN
                  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   REFERENCE_2 I.E. PO_HEADER_ID '||
                                                               'is NULL');
                  END IF;
	       ELSE
                  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   REFERENCE_5 I.E.'||
                                                           ' Transaction_id is NULL');
                  END IF;
	       END IF;
            END IF;

         ELSIF (l_category = 'Purchases') THEN
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'REFERENCE 2: '|| L_REFERENCE_2);
            END IF;

            IF (l_reference_2 IS NOT NULL) THEN
               BEGIN
                  l_feeder_flag := 'Y';

                  SELECT pov.vendor_id,
                         pov.vendor_type_lookup_code,
                         fvv.eliminations_id
                  INTO   l_vendor_id,
                         l_vendor_type,
                         l_eliminations_id
                  FROM   po_vendors pov, po_headers_all poh,
                         fv_facts_vendors_v fvv
                  WHERE poh.po_header_id = to_number(l_reference_2)
                  AND   pov.vendor_id = poh.vendor_id
                  AND   fvv.vendor_id = poh.vendor_id;
              EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'NO DATA FOUND WHEN SOURCE IS'||
                                           ' Purchasing and category'||
                                           ' is Purchases!!');
                  END IF;
                WHEN INVALID_NUMBER THEN
                FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'Invalid Number passed to REFERENCE_2');
               END;
            ELSE

                 IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'REFERENCE_2 I.E. PO HEADER ID'||
                                            ' is NULL');
                 END IF;
            END IF;
         END IF;

           -----------------------------------------------------------
           -- Customer id for Receivables transactions
           -----------------------------------------------------------
           ELSIF (l_source = 'Receivables') THEN
   	    	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                   '   NAME: '||L_NAME);
             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                   '   REFERENCE 7: '|| L_REFERENCE_7);

   	    	END IF;
	    	IF (l_reference_7 IS NOT NULL)   	THEN
	       		l_vendor_id := to_number(l_reference_7);
       	   BEGIN
	          	l_feeder_flag := 'Y';
	          	SELECT hzca.customer_class_code, fcv.eliminations_id
	          	INTO   l_vendor_type, l_eliminations_id
	          	FROM   hz_cust_accounts hzca, fv_facts_customers_v fcv
	          	WHERE  hzca.cust_account_id = to_number(l_reference_7)
	          	AND    fcv.customer_id = hzca.cust_account_id;

              -- Added for bug 7256357
              IF (g_transaction_partner_val <> 'N' AND
                  l_vendor_type IS NOT NULL) THEN
                    IF l_vendor_type = 'FEDERAL' THEN
                       g_transaction_partner_val := 'F';
                     ELSIF l_vendor_type <> 'FEDERAL' THEN
                       g_transaction_partner_val := 'X';
                     END IF;
               END IF;

               IF l_vendor_type IS NULL THEN
                  fv_utility.log_mesg('Customer class code not found');
               END IF;
               /*
               --Added for bug 7324241
               --If customer class cannot be found then get the
               --class code based on the Reimbursable Agreement val
               --only if the segment 'Reimbursable Agreement' has
               --been set up.
               IF (g_transaction_partner_val IS NOT NULL AND
                  l_vendor_type IS NULL AND
                  g_reimb_agree_seg_name IS NOT NULL) THEN
                  l_get_trx_part_from_reimb := TRUE;
                END IF;
               */
	          EXCEPTION
	   	       WHEN NO_DATA_FOUND THEN
   		         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                '   NO DATA FOUND !!');
   		         END IF;
               /*
               fv_utility.log_mesg('Customer class code not found');
               IF g_reimb_agree_seg_name IS NOT NULL THEN
                  l_get_trx_part_from_reimb := TRUE;
               END IF;
               */
              WHEN INVALID_NUMBER THEN
                FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,
                'Invalid Number passed to REFERENCE_7');
	       	 END;
           /*
           IF l_get_trx_part_from_reimb then
              fv_utility.debug_mesg('Getting class based on reimb val');
              get_trx_part_from_reimb(l_reimb_agree_seg_val);
           END IF;

           IF (g_error_code <> 0) THEN
              RETURN;
           END IF;
           */
	        ELSE
	       		IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
               '   REFERENCE_7 I.E. '|| 'customer_id is NULL');
		        END IF;
	        END IF;
           --------------------------------------------------------------------
           -- Vendor id for TC transactions
           --------------------------------------------------------------------
           ELSIF (l_source = 'Payables' AND
                  l_category = 'Treasury Confirmation')   THEN
   	    l_stage := 4;
   	    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
             '   SOURCE: '|| L_SOURCE);
             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
             '   REFERENCE 3: '|| L_REFERENCE_3);
   	    END IF;
      	    IF (l_reference_3 IS NOT NULL) THEN
               BEGIN
		             l_feeder_flag := 'Y';
		             SELECT  v.vendor_id vendor_id,
			                   v.vendor_type_lookup_code vendor_type,
			                   fvv.eliminations_id
		             INTO l_vendor_id,l_vendor_type,l_eliminations_id
		             FROM ap_checks_all apc,
    	     	          po_vendors v,
	     	              fv_facts_vendors_v fvv
		             WHERE  apc.vendor_id = v.vendor_id
	  	           AND    apc.check_id  = to_number(l_reference_3)
	  	           AND    fvv.vendor_id = v.vendor_id;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name||
                            '.message_22','   NO DATA FOUND !!');
                   END IF;
	               WHEN INVALID_NUMBER THEN
                      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,
                      'Invalid Number passed to REFERENCE_3');
               END;
            ELSE
               IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                '   REFERENCE_3 I.E. CHECK_ID IS NULL');
               END IF;
            END IF;
        -------------------------------------------------------------
        --   Budgetary Transaction
        -------------------------------------------------------------
	  ELSIF l_source = 'Budgetary Transaction' THEN
      	 DECLARE
          --Modified for bug 7256357
       		CURSOR dept_cur IS
          SELECT h.doc_number, d.dept_id||d.main_account
          FROM fv_be_trx_hdrs h,
               fv_be_trx_dtls d
          WHERE d.transaction_id = to_number(l_reference_1)
          AND h.doc_id = d.doc_id;
      	 	--SELECT dept_id||main_account
      	 	--FROM fv_be_trx_dtls
      		--WHERE transaction_id = to_number(l_reference_1);
          l_doc_number fv_be_trx_hdrs.doc_number%TYPE;
          l_cust_class_code hz_cust_accounts_all.customer_class_code%TYPE;
     	 BEGIN
         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
              'BUDGETARY TRANSACTION');
         END IF;
            l_feeder_flag := 'Y';
            OPEN dept_cur ;
            FETCH dept_cur INTO  l_doc_number, l_eliminations_id ;
            fv_utility.log_mesg('l_doc_number:'||l_doc_number);
            IF dept_cur%FOUND THEN
   		         IF (l_eliminations_id IS NOT NULL)  THEN
               		l_vendor_id := l_eliminations_id;
               		l_vendor_tYpe := 'FEDERAL';
               END IF;
               --Added for bug 7256357
               SELECT hzca.customer_class_code
               INTO   l_cust_class_code
               FROM   ra_customer_trx rct,
                      hz_cust_accounts hzca
               WHERE  rct.trx_number = l_doc_number
               AND    rct.set_of_books_id = g_set_of_books_id
               AND    hzca.cust_account_id = rct.bill_to_customer_id;

               IF (g_transaction_partner_val <> 'N' AND
                  l_cust_class_code IS NOT NULL) THEN
                    IF l_cust_class_code = 'FEDERAL' THEN
                       g_transaction_partner_val := 'F';
                     ELSIF l_cust_class_code <> 'FEDERAL' THEN
                       g_transaction_partner_val := 'X';
                     END IF;
               END IF;

              ELSE
	 	            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'NO DATA FOUND WHEN source = '||l_source);
                END IF;

             END IF ;
           CLOSE dept_cur ;
         END;
     ELSE  -- Journale entered manually

       IF (g_govt_non_govt_ind = 'Y') 	 THEN
   	     IF (l_jrnl_att_value is NOT NULL) THEN
	          l_eliminations_id := l_jrnl_att_value;
               g_govt_non_govt_val := 'F';
	        ELSE
	           l_eliminations_id := NULL;
              g_govt_non_govt_val := 'N';
	        END IF;

	         l_feeder_flag := 'N';

        ELSIF (g_govt_non_govt_ind = 'F')THEN
            IF (l_jrnl_att_value is NOT NULL) THEN
               l_eliminations_id := l_jrnl_att_value;
             ELSE
	             l_eliminations_id := '00';
	          END IF;
	          l_feeder_flag := 'N';
            g_govt_non_govt_val := 'F';
        ELSE
	           l_valid_flag := 'N';
       END IF;

    END IF; /* journale source */
      EXCEPTION
	 WHEN NO_DATA_FOUND  THEN
             l_valid_flag := 'Y';
	 WHEN INVALID_NUMBER OR VALUE_ERROR THEN
	     l_valid_flag := 'Y';


     END;
 --END IF;  /*  before BEGIN */

 IF l_valid_flag = 'Y'  THEN  -- valid Flag
        IF (l_feeder_flag = 'Y')  THEN
	       IF (l_vendor_id IS NULL)   THEN
	          IF (l_jrnl_att IS NOT NULL)   THEN
	              l_eliminations_id := l_jrnl_att_value;
	          END IF;
         END IF;
        END IF;

	      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
            '   FEEDER FLAG:'||L_FEEDER_FLAG);
	      END IF;
         IF (l_vendor_id IS NULL) THEN
            IF ((g_govt_non_govt_ind = 'F' AND
                 l_feeder_flag = 'Y') OR
	              (g_govt_non_govt_ind = 'F' AND
	               l_feeder_flag = 'N' AND
                 l_eliminations_id = '00')) THEN
       	       IF (l_eliminations_id IS NULL OR
                   l_eliminations_id = '00') THEN
  	 	             g_govt_non_govt_val := 'F';
                   l_eliminations_id := '00';
                ELSE
                  g_govt_non_govt_val := 'F';
	              END IF;
            -- Govt Non Govt Indicator = Y
              ELSIF ((g_govt_non_govt_ind = 'Y' AND l_feeder_flag = 'Y')
	    	          OR (g_govt_non_govt_ind = 'Y' AND l_feeder_flag = 'N')) THEN
       	          --IF (l_eliminations_id IS NULL)
                  --Bug 7150443
       	          IF (l_eliminations_id IS NULL OR
                      l_eliminations_id = '  ') THEN
                  	  g_govt_non_govt_val := 'N';
                  	  l_eliminations_id  := '  ';
	       	         ELSE
                      g_govt_non_govt_val := 'F';
	                END IF;
            END IF;  -- Govt Non Govt = F or Y
         ELSE  -- l_vendor_id IS NOT NULL
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                     '   VENDOR ID IS NOT NULL');
            END IF;
            IF (l_feeder_flag = 'Y') THEN
                  IF (g_govt_non_govt_val = 'F' AND
                      UPPER(l_vendor_type) <> 'FEDERAL') THEN
                        IF (l_eliminations_id IS NULL) THEN
                            l_eliminations_id := '00';
                        END IF;
                        g_govt_non_govt_val := 'F';
                    ELSIF (g_govt_non_govt_ind = 'F') THEN
                        IF l_eliminations_id IS NULL THEN
                           l_eliminations_id := '00';
                         END IF;
                        g_govt_non_govt_val := 'F';
                    ELSIF (g_govt_non_govt_ind = 'Y' AND
                           UPPER(l_vendor_type) <> 'FEDERAL') THEN
                          g_govt_non_govt_val := 'N';
                          l_eliminations_id := ' ';
                    ELSIF (g_govt_non_govt_ind = 'Y') THEN
                        IF l_eliminations_id IS NULL THEN
                         l_eliminations_id := '00';
                        END IF;
                        g_govt_non_govt_val := 'F';
	                  END IF;  /* (L_vendor_type <> FEDERAL */
             END IF; -- Feeder Flag
        END IF; -- l_vendor_id
         --END IF; -- l_feeder_system
       END IF; -- l_valid_flag

    ------------------------------------------------------------
    -- Deriving the Public Law Code value
    ------------------------------------------------------------
    IF g_public_law_code_flag = 'N' THEN
       g_public_law_code_val := '       ';
    END IF;

    -- If the public law code is required then check the journal source.
    -- If the journal source is YE Close and Budgetary Transaction then
    -- get the public law code from BE details table.  If the journal
    -- source is not these two, then get the public law code from the
    -- corresponding attribute field on the je line.

    IF  g_public_law_code_flag = 'Y' THEN
      --Bug#3225337
      --IF l_reference_1 IS NOT NULL
      IF (NVL(l_reference_1, '-100') <> '-100')
         THEN
	    BEGIN
	        SELECT  public_law_code
	        INTO    g_public_law_code_val
	        FROM    fv_be_trx_dtls
	        WHERE   transaction_id  = to_number(l_reference_1)
	        AND     set_of_books_id = g_set_of_books_id ;
	    EXCEPTION
	         WHEN NO_DATA_FOUND THEN NULL;
	        WHEN INVALID_NUMBER THEN
               NULL;
	    END;
       ELSE -- reference_1 is null
           IF  l_pl_code_col IS NULL THEN
               g_public_law_code_val := '       ' ;
            ELSE
               g_public_law_code_val := SUBSTR(l_pl_code,1,7);
           END IF;
      END IF ;

       IF l_source = 'Receivables' THEN
         IF (l_factsii_pub_law_rec_col IS NOT NULL) THEN
           IF (l_factsii_pub_law_rec IS NOT NULL) THEN
               g_public_law_code_val := SUBSTR(l_factsii_pub_law_rec,1,7);
           ELSE
               g_public_law_code_val := '       ' ;
           END IF;
         END IF;
       END IF;

    END IF ;
    ------------------------------------------------------------
    -- Deriving the Legislation Indicator Value
    -------------------------------------------------------------
    IF g_legis_Ind_flag = 'Y' THEN
      BEGIN
	SELECT  transaction_type_id
	INTO    l_tran_type
	FROM    Fv_be_trx_dtls
	WHERE  transaction_id  = to_number(l_reference_1)
	AND     set_of_books_id = g_set_of_books_id ;

	-- Get the Legislation Indicator Value from
	-- fv_be_transaction_types table.
	SELECT legislative_indicator
	INTO   g_legis_ind_val
	FROM   FV_be_transaction_types
	WHERE  apprn_transaction_type = l_tran_type
	AND    set_of_books_id  = g_set_of_books_id ;
      EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  g_legis_ind_val := 'A' ;
	WHEN INVALID_NUMBER THEN
	  g_legis_ind_val := 'A' ;
      END ;
   END IF;
   ------------------------------------------------------------
   -- Deriving the Advance Type Value
   ------------------------------------------------------------

     IF g_advance_flag = 'Y' THEN
      --Bug#3225337
      --IF l_reference_1 IS NOT NULL
      IF (NVL(l_reference_1, '-100') <> '-100')
        THEN
           BEGIN
             SELECT  advance_type
               INTO  g_advance_type_val
               FROM  fv_be_trx_dtls
	      WHERE   transaction_id  = to_number(l_reference_1)
                AND  set_of_books_id = g_set_of_books_id ;
            -- IF the advance_type value is null then set it to 'X'
               IF g_advance_type_val IS NULL THEN
                   g_advance_type_val := 'X';
  	       END IF;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 g_advance_type_val := 'X';
             WHEN INVALID_NUMBER THEN
                 g_advance_type_val := 'X';
           END;
       ELSE
          -- l_reference_1 is null
          -- If an attribute column is not set up for advance type
          -- then report blank.  If a column is setup but
          -- the journal line does not contain a value, then
          -- report 'X'
          IF  l_advance_type_col IS NULL THEN
              g_advance_type_val := 'X';
           ELSE
              IF l_advance_type IS NULL THEN
                 g_advance_type_val := 'X';
               ELSE
                 g_advance_type_val := SUBSTR(l_advance_type,1,1);
              END IF;
          END IF;
       END IF;

     END IF;
     ------------------------------------------------------------
     -- Deriving the Dept ID and Main Account
     -------------------------------------------------------------
     -- Transfer Acct specific processing
     IF g_transfer_ind = 'Y' THEN
        --Bug#3225337
        --IF l_reference_1 IS NOT NULL THEN
        IF (NVL(l_reference_1, '-100') <> '-100') THEN
            BEGIN
	        SELECT  dept_id,
                        main_account
                 INTO   g_transfer_dept_id,
                        g_transfer_main_acct
                 FROM   fv_be_trx_dtls
		 WHERE   transaction_id  = to_number(l_reference_1)
                   AND  set_of_books_id = g_set_of_books_id ;

             -- IF the Transfer values are null then set default values
             -- Since both dept_id and main_acct are null or both have
             -- values test IF one of them is null

               IF g_transfer_dept_id IS NULL THEN
                     --bug#3219352
                     g_transfer_dept_id   := '  ';
                     g_transfer_main_acct := '    ';
                     --g_transfer_dept_id   := '00';
                     --g_transfer_main_acct := '0000';
               END IF;
              EXCEPTION
               WHEN NO_DATA_FOUND THEN
		    -- This Exception fires when
                    -- the transfer info
                    -- cannot be found.
                     --bug#3219352
                     g_transfer_dept_id   := '  ';
                     g_transfer_main_acct := '    ';
                  --g_transfer_dept_id   := '00';
                  --g_transfer_main_acct := '0000';
		   WHEN INVALID_NUMBER THEN
                g_transfer_dept_id   := '  ';
                g_transfer_main_acct := '    ';
                FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'Invalid Number passed to REFERENCE_1');
              END;
         ELSE
             -- l_reference_1 is null
             -- If an attribute column is not set up for transfer
             -- info then report blanks.
             IF  l_tr_main_acct_col IS NULL THEN
                 g_transfer_dept_id   := '  ';
                 g_transfer_main_acct := '    ';
              ELSE
                 g_transfer_main_acct := SUBSTR(l_tr_main_acct,1,4);
                 g_transfer_dept_id   := SUBSTR(l_tr_dept_id,1,2);
             END IF;
         END IF;

      END IF;

   ----------------------------------------------------------------
   -- Processing Budget Year Authority attribute
   ----------------------------------------------------------------

      IF l_sgl_acct_num IS NULL THEN
         BEGIN
           SELECT 'X'
             INTO l_exists
             FROM fv_facts_ussgl_accounts
            WHERE ussgl_account = l_account_number;
            l_sgl_acct_num := l_account_number;
         EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                 NULL;
         END;
        END IF;

    IF l_sgl_acct_num IS NOT NULL THEN
	      g_year_budget_auth := NULL;

      		BEGIN
           		SELECT disbursements_flag
        		  INTO   l_disbursements_flag
			        FROM   fv_facts_ussgl_accounts
			        WHERE  ussgl_account = l_sgl_acct_num;

		       EXCEPTION
			          WHEN OTHERS THEN
		    		       g_error_code := sqlcode ;
		    		       g_error_buf := sqlerrm ||
					         ' [ JOURNAL_PROCESS '||
                                        ' l_disbursements_flag - ' ||
                                         l_sgl_acct_num||' ] ' ;
                   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name
                        ||'.exception_1',g_error_buf);
			        RETURN ;
		      END;

            BEGIN
 	             SELECT  FTS.Time_Frame, FFFA.financing_account
    	         INTO  l_time_frame, l_financing_acct
    	         FROM  FV_FACTS_FEDERAL_ACCOUNTS	FFFA,
	   	               FV_TREASURY_SYMBOLS 		FTS
    	         WHERE  FFFA.Federal_acct_symbol_id = FTS.Federal_acct_symbol_id
    	          AND  FTS.treasury_symbol_id      = g_treasury_symbol_id
    		        AND  FTS.set_of_books_id	   = g_set_of_books_id
    		        AND  FFFA.set_of_books_id	   = g_set_of_books_id ;

    		     EXCEPTION
	   		        WHEN OTHERS THEN
		    		         g_error_code := sqlcode ;
		    		         g_error_buf := sqlerrm ||
				         	' [JOURNAL_PROCESS   '||
                                                '- v_time_frame ] ' ;
                  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name
                   ||'.exception_2',g_error_buf);
			            RETURN ;
    		     END;

        	IF  l_time_frame             = 'NO_YEAR'
                  	AND l_financing_acct      = 'N'
	         	AND l_disbursements_flag = 'Y'
	        	AND (l_entered_dr <> 0 OR l_entered_cr <> 0) THEN
                  BEGIN
                     SELECT fyr_segment_value
	               INTO l_fyr_segment_value
	               FROM fv_pya_fiscalyear_map
	              WHERE period_year = g_period_year
	                AND set_of_books_id = g_set_of_books_id;

	          EXCEPTION
                     WHEN OTHERS THEN
	              g_error_code := sqlcode ;
		      g_error_buf := sqlerrm ||
		                     ' [JOURNAL_PROCESS '||
                                     ' l_fyr_segment_value -  ] ' ;
               FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception_3',g_error_buf);
                  END;

        	IF l_fyr_segment_value IS NOT NULL THEN
        	    IF l_fyr_segment_value = l_seg_fiscal_yr THEN
  			         g_year_budget_auth := 'NEW';
       		    ELSE
 			            g_year_budget_auth := 'BAL';
		          END IF;
	        END IF;
         END IF;
    END IF;

   ----------------------------------------------------------------
   -- Bug7324241
   -- Processing Transaction Partner attribute
   --If the transaction partner value has not been found above,
   --then derive using the Reimbursable Agreement segment value
   --if the segment has been setup or has a value, irrespective
   --of the journal source.
   ----------------------------------------------------------------
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
             '****g_transaction_partner_val:'||g_transaction_partner_val);
   END IF;

   IF (g_transaction_partner_val NOT IN ('N', 'F', 'X') AND
       g_reimb_agree_seg_name IS NOT NULL) THEN
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
         'Getting trx prtnr value based on reimb val');
       END IF;
       get_trx_part_from_reimb(l_reimb_agree_seg_val);

       IF (g_error_code <> 0) THEN
          RETURN;
       END IF;
       --IF the trx partnr val still cannot be found then default to 0
       IF g_transaction_partner_val NOT IN ('F', 'X') THEN
          g_transaction_partner_val := 0;
       END IF;
   END IF;

   ---Added for FSIO Demo bug 8498437
   ---For Misc Receipts get gng indicator using customer class
   ---If class is Federal then gng indicator is F else N
   IF (l_source = 'Receivables' AND l_category = 'Misc Receipts') THEN
     IF g_govt_non_govt_ind = 'Y' THEN
        --Set default value to N
        g_govt_non_govt_val := 'N';
        IF g_reimb_agree_seg_name IS NOT NULL THEN
           get_fnf_from_reimb(l_reimb_agree_seg_val);
        END IF;
      END IF;
      fv_utility.log_mesg(l_module_name||' g_govt_non_govt_ind: '||g_govt_non_govt_ind);
      fv_utility.log_mesg(l_module_name||' g_govt_non_govt_val: '||g_govt_non_govt_val);
   END IF;
   ----------------------------------------------------------------
   --All process ends here
   ----------------------------------------------------------------

       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   IN VIEW');
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'     VENDOR ID: '||L_VENDOR_ID);
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'     ELIMINATIONS ID: '|| L_ELIMINATIONS_ID);
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       GNG: '||G_GOVT_NON_GOVT_VAL);
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       CCID: '|| L_CCID);
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       ACCT#: '|| L_ACCOUNT_NUMBER);
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       DEBIT: '|| L_ENTERED_DR);
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       CREDIT: '|| L_ENTERED_CR);
       END IF;

                IF g_src_flag = 1 THEN
                   l_source := 'Purchasing';
                END IF;

                POPULATE_TABLE ( g_treasury_symbol_id 	    ,
 	  			 g_set_of_books_id 	    ,
	 			 l_ccid                     ,
 				 l_bal_segment		    ,
 				 l_account_number 	    ,
				 l_source	            ,
				 l_category	            ,
 				 l_doc_num 	            ,
                		 l_doc_date                 ,
 	 			 l_doc_creation_date 	    ,
 				 l_entry_user	            ,
            			 g_govt_non_govt_val        ,
            			 l_eliminations_id          ,
 				 g_exch_non_exch_val 	    ,
 				 g_cust_non_cust_val  	    ,
            			 g_budget_subfunction_val   ,
				 NVL(l_entered_dr,0)        ,
 				 NVL(l_entered_cr,0)        ,
 				 g_transfer_dept_id 	    ,
 				 g_transfer_main_acct 	    ,
 				 g_year_budget_auth 	    ,
 				 g_budget_function_val      ,
 				 g_advance_type_val 	    ,
 				 l_cohort 		    ,
                        	 ''                         ,
 			--	 p_begin_end 		    ,
 				 g_def_indef_val	    ,
                                 LPAD(l_cbs_num,3,'0'),
            			 l_cat_b_text               ,
                                 LPAD(l_prn_num,3,'0'),
                                 l_prn_text                 ,
				 g_public_law_code_val      ,
				 g_appor_cat_val 	    ,
 				 g_authority_type_val 	    ,
         g_transaction_partner_val  ,
				 g_reimburseable_val 	    ,
 				 g_bea_category_val	    ,
 				 g_borrowing_source_val     ,
            			 g_def_liquid_flag 	    ,
            			 g_deficiency_flag          ,
 				 g_availability_val	    ,
 				 g_legis_ind_val 	    ,
         g_pya_val        ,
				 l_je_line_creation_date    ,
				 l_je_line_modified_date    ,
				 l_je_line_period_name      ,
		                 l_gl_date		    ,
                		 l_gl_posted_date,
                     l_reversal_flag,
                     l_sla_hdr_event_id ,
                     l_sla_hdr_creation_date,
                     l_sla_entity_id   );

               IF (g_error_code <> 0)
      	       THEN
               	  return;
               END IF;
   END LOOP;
   DBMS_SQL.CLOSE_CURSOR(l_jrnl_cursor);
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'LEAVING JOURNAL PROCESSES ...');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
       DBMS_SQL.CLOSE_CURSOR(l_jrnl_cursor);
       g_error_code := 2 ;
       g_error_buf := 'JOURNAL PROCESSES - Exception Main (Others) - ' ||
			 to_char(sqlcode) || ' - ' || SQLERRM;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_buf);
END JOURNAL_PROCESS;

-- -------------------------------------------------------------------
--                   PROCEDURE GET_DOC_INFO
-- -------------------------------------------------------------------
-- Get_Doc_Info procedure is called from the Journal_Process procedure.
-- Its purpose is to find the document related information like
-- document number, its creation date and created by.
-- -------------------------------------------------------------------
PROCEDURE GET_DOC_INFO (p_je_header_id 		IN Number,
			p_je_source_name 	IN Varchar2,
			p_je_category_name 	IN Varchar2,
			p_name			IN Varchar2,
			p_date			IN Date,
		        p_creation_date		IN Date,
		        p_created_by		IN Number,
			p_reference1		IN Varchar2,
			p_reference2		IN Varchar2,
			p_reference3		IN Varchar2,
			p_reference4		IN Varchar2,
			p_reference5    	IN Varchar2,
			p_reference9    	IN Varchar2,
			p_ref2 			IN Varchar2,
			p_doc_num	       OUT NOCOPY Varchar2,
			p_doc_date	       OUT NOCOPY Date,
			p_doc_creation_date    OUT NOCOPY Date,
			p_doc_created_by       OUT NOCOPY Number,
                        p_gl_date              IN OUT NOCOPY DATE,
                        p_rec_public_law_code_col IN VARCHAR2,
      p_gl_sl_link_id       IN NUMBER,
			p_rec_public_law_code OUT NOCOPY Varchar2,
      p_reversed       OUT NOCOPY VARCHAR2,
      p_sla_entity_id IN NUMBER)
IS
  l_module_name VARCHAR2(200);
l_refer2   	       Varchar2(240);
l_refer4	       Varchar2(240);
l_cash_receipt_hist_id Varchar2(240);
l_temp_cr_hist_id      Varchar2(240);
l_rev_exists           Varchar2(1);
l_document_num	       Varchar2(240);
l_doc_date	       Date;
l_doc_creation_date    Date;
l_doc_created_by       Number;
--l_doc_date_d 	       Date;
l_doc_creation_date_d  Date;
l_doc_created_by_d     Number;
l_void_date	       Date;
l_check_date	       Date;
l_inv_payment_id       Number;
l_gl_date              Date;
l_rec_public_law_code  VARCHAR2(150);
l_parent_reversal_id ap_invoice_distributions.parent_reversal_id%TYPE;
l_event_type_code    ap_accounting_events.event_type_code%TYPE;
l_receipt_hist_status ar_cash_receipt_history_all.status%TYPE;
l_dummy_rev_exists VARCHAR2(1);


TYPE common_ref_type IS REF CURSOR ;
pur_req common_ref_type;
pur_pur common_ref_type;
pur_rec common_ref_type;
Receivables_Distrib  common_ref_type;
Receivables_Misc common_ref_type;


l_select      VARCHAR2(1000);
l_temp_doc_date	      VARCHAR2(25) ;

/*
CURSOR	pur_Rec IS
	SELECT 	 rt.transaction_date,
		 rcv.receipt_num,
		 rt.creation_date,
		 rt.created_by
	FROM	 rcv_transactions rt,
		 rcv_shipment_headers rcv
	WHERE    rt.shipment_header_id = rcv.shipment_header_Id
	AND      TO_CHAR(rt.transaction_id) = p_reference5;
*/
CURSOR	Pay_Pur IS
	SELECT 	 inv.invoice_num,
		 inv.invoice_date,
		 inv.creation_date,
		 inv.created_by
	FROM  	 ap_invoices_all inv
        WHERE    inv.invoice_id = to_number(p_reference2);
CURSOR	Pay_Pay IS
	SELECT 	DISTINCT api.invoice_num,
                DECODE(apc.payment_type_flag,'A',apc.check_date,
		NVL(apc.treasury_pay_date, apc.check_date)) check_date,
		apip.creation_date,
		apip.created_by
	FROM	ap_checks_all apc,
		ap_invoices_all api,
		ap_invoice_payments_all apip
        WHERE   apc.check_id = to_number(p_reference3)
	AND	api.invoice_id = to_number(p_reference2)
	AND	apc.check_id = apip.check_id
	AND	api.invoice_id = apip.invoice_id;
CURSOR	Receivables IS
	SELECT 	 DECODE(l_rev_exists, 'Y', reversal_date, receipt_date),
	         DECODE(l_rev_exists, 'Y', l_doc_creation_date_d,creation_date),
		 DECODE(l_rev_exists, 'Y', l_doc_created_by_d, created_by)
	FROM	 ar_cash_receipts_all
	WHERE	 cash_receipt_id = to_number(l_refer2);
CURSOR Receivables_Exists IS
        SELECT 'Y'
        FROM   ar_cash_receipt_history_all
        WHERE  cash_receipt_history_id =  TO_NUMBER(l_cash_receipt_hist_id);
CURSOR Receivables_Applications IS
	SELECT cash_receipt_history_id
	FROM   ar_receivable_applications_all
	WHERE receivable_application_id = TO_NUMBER(l_cash_receipt_hist_id);
CURSOR Receivables_Hist
(
  c_cash_receipt_hist_id NUMBER,
  c_cash_receipt_id VARCHAR2
)
IS
        SELECT 'Y', status
        FROM   ar_cash_receipt_history_all
        WHERE  cash_receipt_history_id =  c_cash_receipt_hist_id
          AND cash_receipt_id = c_cash_receipt_id;
CURSOR Receivables_History
(
  c_cash_receipt_hist_id NUMBER
)
IS
        SELECT 'Y', creation_date, created_by
        FROM   ar_cash_receipt_history_all
        WHERE  reversal_cash_receipt_hist_id =  c_cash_receipt_hist_id;
--CURSOR Receivables_Misc IS
--	SELECT 'Y', creation_date, created_by
--	FROM   ar_misc_cash_distributions_all
--	WHERE  misc_cash_distribution_id = l_cash_receipt_hist_id
--	AND    created_from = 'ARP_REVERSE_RECEIPT.REVERSE';
--CURSOR Receivables_Distrib IS
--	SELECT 'Y'
--	FROM   ar_misc_cash_distributions_all
--	WHERE  misc_cash_distribution_id = to_number(l_cash_receipt_hist_id);
CURSOR  Pay_Treas_Check IS
	SELECT  void_date, checkrun_name
	FROM    ap_checks_all
	WHERE	check_id = p_reference3;
CURSOR	Pay_Treas_Void  IS
	SELECT  creation_date, created_by
	FROM    ap_invoice_payments_all
	WHERE   check_id = p_reference3
	AND     invoice_payment_id = (SELECT max(invoice_payment_id)
	                              FROM   ap_invoice_payments_all
           	                      WHERE  check_id = p_reference3);
CURSOR  Pay_Treas  IS
        SELECT  ftc.checkrun_name,
                ftc.treasury_doc_date,
                ftc.creation_date,
                ftc.created_by
        FROM    fv_treasury_confirmations_all ftc
        WHERE   ftc.treasury_confirmation_id = to_number(p_reference1);
CURSOR  Pay_Pay_Check IS
	SELECT  void_date,
		DECODE(payment_type_flag,'A',check_date,
                        NVL(treasury_pay_date,check_date)) check_date
	FROM    ap_checks_all
	WHERE	check_id = p_reference3;
CURSOR  Pay_Pay_Void IS
        SELECT NVL(MAX(invoice_payment_id),0)
        FROM   ap_invoice_payments_all
        WHERE  invoice_id = NVL(p_reference2, 0)
        AND    check_id = NVL(p_reference3,0)
        AND    invoice_payment_id > p_reference9;
CURSOR Pay_Pay_Void_Values IS
	SELECT api.invoice_num, apip.creation_date,
               apip.created_by
	FROM  ap_invoice_payments_all apip,
	      ap_invoices_all api
	WHERE api.invoice_id = NVL(p_reference2, 0)
	AND   api.invoice_id = apip.invoice_id
        AND   apip.check_id = NVL(p_reference3,0)
        AND   apip.invoice_payment_id = p_reference9;
CURSOR  Pay_Pay_Non_Void IS
        SELECT  api.invoice_num, apc.creation_date,
                apc.created_by
        FROM    ap_checks_all apc,
                ap_invoices_all api,
                ap_invoice_payments_all apip
	WHERE   apc.check_id = to_number(p_reference3)
        AND     api.invoice_id = to_number(p_reference2)
        AND     apc.check_id = apip.check_id
        AND     api.invoice_id = apip.invoice_id;
CURSOR	Budget_Transac  IS
	SELECT	 h.doc_number, d.gl_date, d.creation_date,
                 d.created_by
	FROM 	 fv_be_trx_dtls d, fv_be_trx_hdrs h
	WHERE 	 d.transaction_id = to_number(p_reference1)
	AND	 h.doc_id = d.doc_id;
/*
CURSOR	Pur_Req IS
	SELECT 	start_date_active, creation_date, created_by
	FROM	po_requisition_headers_all
	WHERE	to_char(requisition_header_id) =  p_reference2;

CURSOR	Pur_Req IS
	SELECT 	gl_encumbered_date, creation_date, created_by
	FROM	po_req_distributions
	WHERE	to_char(distribution_id) =  p_reference3;

CURSOR	Pur_Pur IS
	SELECT 	start_date, creation_date, created_by
	FROM	po_headers_all
	WHERE	segment1 = p_reference2;

CURSOR	Pur_Pur IS
	SELECT 	gl_encumbered_date, creation_date, created_by
	FROM	po_distributions_all
	WHERE	to_char(po_distribution_id) = p_reference3;
*/
CURSOR Manual IS
	SELECT  default_effective_date
        FROM    gl_je_headers
	WHERE   je_header_id = p_je_header_id;
CURSOR Receivables_Adjustment IS
	SELECT apply_date, creation_date, created_by
	FROM ar_adjustments_all
	WHERE adjustment_id = l_refer2;
CURSOR Receivables_CMA IS
	SELECT apply_date, creation_date, created_by
	FROM ar_receivable_applications_all
	WHERE receivable_application_id = l_refer2;
CURSOR Receivables_Memos_Inv IS
	SELECT trx_date, creation_date, created_by
	FROM ra_customer_trx_all
	WHERE customer_trx_id = l_refer2;
BEGIN
fnd_file.put_line (fnd_file.log, 'BEGIN GET_DOC_INFO');
fnd_file.put_line (fnd_file.log, 'p_je_header_id='||p_je_header_id);
fnd_file.put_line (fnd_file.log, 'p_je_source_name='||p_je_source_name);
fnd_file.put_line (fnd_file.log, 'p_je_category_name='||p_je_category_name);
fnd_file.put_line (fnd_file.log, 'p_name='||p_name);
fnd_file.put_line (fnd_file.log, 'p_date='||p_date);
fnd_file.put_line (fnd_file.log, 'p_creation_date='||p_creation_date);
fnd_file.put_line (fnd_file.log, 'p_created_by='||p_created_by);
fnd_file.put_line (fnd_file.log, 'p_reference1='||p_reference1);
fnd_file.put_line (fnd_file.log, 'p_reference2='||p_reference2);
fnd_file.put_line (fnd_file.log, 'p_reference3='||p_reference3);
fnd_file.put_line (fnd_file.log, 'p_reference4='||p_reference4);
fnd_file.put_line (fnd_file.log, 'p_reference5='||p_reference5);
fnd_file.put_line (fnd_file.log, 'p_reference9='||p_reference9);
fnd_file.put_line (fnd_file.log, 'p_ref2='||p_ref2);
fnd_file.put_line (fnd_file.log, 'p_gl_date='||p_gl_date);
fnd_file.put_line (fnd_file.log, 'p_rec_public_law_code_col='||p_rec_public_law_code_col);
fnd_file.put_line (fnd_file.log, 'p_gl_sl_link_id='||p_gl_sl_link_id);


  l_module_name := g_module_name || 'GET_DOC_INFO';
  l_rev_exists  := 'N';
  p_reversed := NULL;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'');
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'ENTERING GET DOC INFO ...');
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'  REF1: '||P_REFERENCE1);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'  REF2: '||P_REFERENCE2);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'  REF3: '||P_REFERENCE3);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'  REF4: '||P_REFERENCE4);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'  REF5: '||P_REFERENCE5);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'  REF9: '||P_REFERENCE9);
   END IF;
   -- Set the values to Null
   l_document_num      := NULL;
   l_doc_date	       := NULL;
   l_doc_creation_date := NULL;
   l_doc_created_by    := NULL;
   p_rec_public_law_code := NULL;
   l_rec_public_law_code := NULL;


   -- Added to handle 3131834 for deobligated invoices in final match
   -- and reversal requisitions created by autocreate PO.
   --





   -- Code for Purchasing
   IF p_je_source_name = 'Purchasing'   THEN
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'  PURCHASING ...');
      END IF;

	    IF p_je_category_name = 'Requisitions' 	THEN
 	        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   REQUISITIONS ...');
 	        END IF;

		l_document_num := p_reference4;

    -- If an attribute col has been defined in
		-- system parameters form, then select that
		-- column's value from req headers. If that value
		-- is not a date, then select creation date as the
		-- doc date.  If an attribute col has not been
		-- defined, then select creation date as the doc
		-- date.
		IF g_req_date_seg IS NOT NULL
                 THEN
	            l_select :=
                     'SELECT '||g_req_date_seg||', creation_date, created_by
		      FROM    po_requisition_headers_all
		      WHERE   requisition_header_id =  '||to_number(p_reference2) ;


		    OPEN pur_req FOR l_select ;
                    FETCH pur_req INTO l_temp_doc_date,
                                     l_doc_creation_date,
                                     l_doc_created_by;
		    CLOSE   pur_req;
                    BEGIN
                        --gscc fix
                        SELECT to_date(l_temp_doc_date, 'mm/dd/yyrr')
                        INTO   l_doc_date
		        FROM   DUAL;

		     EXCEPTION WHEN OTHERS THEN
                        l_select :=
                          'SELECT creation_date, creation_date, created_by
                           FROM    po_requisition_headers_all
			   WHERE   requisition_header_id =  '||to_number(p_reference2) ;

                        OPEN pur_req FOR l_select ;
                        FETCH pur_req INTO l_doc_date,
                                     l_doc_creation_date,
                                     l_doc_created_by;
                        CLOSE pur_req;
                    END ;

		 ELSE -- g_req_date_seg is null
                    l_select :=
                     'SELECT creation_date, creation_date, created_by
                      FROM    po_requisition_headers_all
		      WHERE   requisition_header_id =  '||to_number(p_reference2) ;

                    OPEN pur_req FOR l_select ;
                    FETCH pur_req INTO l_doc_date,
                                     l_doc_creation_date,
                                     l_doc_created_by;
		    CLOSE pur_req;
		END IF;

	ELSIF p_je_category_name = 'Purchases' THEN
 	        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   PURCHASES ...');
 	        END IF;
		      l_document_num := p_reference4;

                IF g_pur_order_date_seg IS NOT NULL THEN
                    l_gl_date := NULL;
                    l_select :=
                     'SELECT h.'||g_pur_order_date_seg||', h.creation_date, h.created_by, d.gl_encumbered_date
                      FROM    po_headers_all h,
                              po_distributions_all d
                      WHERE   h.po_header_id = '||p_reference2 ||'
                        AND   h.po_header_id = d.po_header_id
                        AND   d.po_distribution_id = '||p_reference3;

                    OPEN pur_pur FOR l_select ;
                    FETCH pur_pur INTO l_temp_doc_date,
                                     l_doc_creation_date,
                                     l_doc_created_by,
                                     l_gl_date;
                    CLOSE pur_pur;

                    BEGIN
                        --gscc fix
                        SELECT to_date(l_temp_doc_date, 'mm/dd/yyrr')
                        INTO   l_doc_date
                        FROM   DUAL;

                     EXCEPTION WHEN OTHERS THEN
                        l_gl_date := NULL;
                        l_select :=
                         'SELECT h.creation_date, h.creation_date, h.created_by, d.gl_encumbered_date
                          FROM    po_headers_all h,
                                  po_distributions_all d
                          WHERE   h.po_header_id = '||p_reference2 ||'
                            AND   h.po_header_id = d.po_header_id
                            AND   d.po_distribution_id = '||p_reference3;

                        OPEN pur_pur FOR l_select ;
                        FETCH pur_pur INTO l_doc_date,
                                     l_doc_creation_date,
                                     l_doc_created_by,
                                     l_gl_date;
                        CLOSE pur_pur;
                    END ;

                 ELSE -- g_pur_order_date_seg is null
                    l_gl_date := NULL;
                    l_select :=
                     'SELECT  h.creation_date, h.creation_date, h.created_by, d.gl_encumbered_date
                      FROM    po_headers_all h,
                              po_distributions_all d
                      WHERE   h.po_header_id = '||p_reference2 ||'
                        AND   h.po_header_id = d.po_header_id
                        AND   d.po_distribution_id = '||p_reference3;

                    OPEN pur_pur FOR l_select ;
                    FETCH pur_pur INTO l_doc_date,
                                     l_doc_creation_date,
                                     l_doc_created_by,
                                     l_gl_date;
                    CLOSE pur_pur;
                END IF;
          IF (l_gl_date IS NOT NULL) THEN
            p_gl_date := l_gl_date;
          END IF;

	ELSIF p_je_category_name = 'Receiving'
	THEN
 	        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   RECEIVING ...');
 	        END IF;
                IF g_rec_trxn_date_seg IS NOT NULL
                 THEN
                    l_select :=
        	      'SELECT rt.'||g_rec_trxn_date_seg||',
                 	       rcv.receipt_num,
                 	       rt.creation_date,
                 	       rt.created_by
        	      FROM     rcv_transactions rt,
                 	       rcv_shipment_headers rcv
        	      WHERE    rt.shipment_header_id = rcv.shipment_header_Id
                      AND      rt.transaction_id = '||to_number(p_reference5) ;

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,L_SELECT);
 END IF;

                    OPEN pur_rec FOR l_select ;
                    FETCH pur_rec INTO l_temp_doc_date,
                                     l_document_num,
                                     l_doc_creation_date,
                                     l_doc_created_by;
                    CLOSE pur_rec;
                    BEGIN
                        --gscc fix
                        SELECT to_date(l_temp_doc_date, 'mm/dd/yyrr')
                        INTO   l_doc_date
                        FROM   DUAL;

                     EXCEPTION WHEN OTHERS THEN
                        l_select :=
        		 'SELECT   rt.transaction_date,
                 		   rcv.receipt_num,
                 		   rt.creation_date,
                 		   rt.created_by
        		  FROM     rcv_transactions rt,
                 		   rcv_shipment_headers rcv
        		  WHERE    rt.shipment_header_id = rcv.shipment_header_Id
			 AND      rt.transaction_id = '||to_number(p_reference5);

                        OPEN pur_rec FOR l_select ;
                        FETCH pur_rec INTO l_doc_date,
                                     l_document_num,
                                     l_doc_creation_date,
                                     l_doc_created_by;
                        CLOSE pur_rec;
                    END ;

                 ELSE -- g_rec_trxn_date_seg is null
                    l_select :=
                         'SELECT   rt.transaction_date,
			           rcv.receipt_num,
                                   rt.creation_date,
                                   rt.created_by
                          FROM     rcv_transactions rt,
                                   rcv_shipment_headers rcv
                          WHERE    rt.shipment_header_id = rcv.shipment_header_Id
                          AND      rt.transaction_id = '||to_number(p_reference5) ;
                    OPEN pur_rec FOR l_select ;
                    FETCH pur_rec INTO l_doc_date,
                                     l_document_num,
                                     l_doc_creation_date,
                                     l_doc_created_by;
                    CLOSE pur_rec;
                END IF;

	ELSE
 	        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   OTHERS ...');
 	        END IF;
		l_document_num      := p_name;
		l_doc_date	    := p_date;
		l_doc_creation_date := p_creation_date;
		l_doc_created_by    := p_created_by;
	END IF;
   -- Code for Payables
   ELSIF p_je_source_name = 'Payables'
   THEN
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'  PAYABLES ...');
        END IF;
	IF p_je_category_name = 'Purchase Invoices'
	THEN
 	        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   PURCHASE INVOICES ...');
 	        END IF;
		OPEN 	Pay_Pur;
		FETCH	Pay_Pur INTO l_document_num,
				     l_doc_date,
			             l_doc_creation_date,
				     l_doc_created_by;
                if g_src_flag = '1' then
                   l_document_num := p_reference4;
                End if;

		CLOSE   Pay_Pur;

    IF (NVL(p_reference3, '-100') = '-100') THEN
      BEGIN
        l_event_type_code := NULL;
        SELECT e.event_type_code
          INTO l_event_type_code
          FROM ap_ae_lines_all l,
               ap_ae_headers_all h,
               ap_accounting_events_all e
         WHERE l.source_table = 'AP_INVOICES'
           AND l.source_id = p_reference2
           AND l.ae_header_id = h.ae_header_id
           AND l.gl_sl_link_id = p_gl_sl_link_id
           AND e.accounting_event_id = h.accounting_event_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_event_type_code := NULL;
      END;
      IF (l_event_type_code = 'INVOICE CANCELLATION') THEN
        p_reversed := 'R';
      END IF;
    ELSE
      BEGIN
        l_parent_reversal_id := NULL;
        SELECT a.parent_reversal_id
          INTO l_parent_reversal_id
          FROM ap_invoice_distributions a
         WHERE a.invoice_id = p_reference2
           AND a.distribution_line_number = p_reference3;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_parent_reversal_id := NULL;
      END;

      IF (l_parent_reversal_id IS NOT NULL) THEN
        p_reversed := 'R';
      END IF;
    END IF;

	ELSIF p_je_category_name = 'Payments'
	THEN
                OPEN    Pay_Pay_Check;
                FETCH   Pay_Pay_Check INTO l_void_date, l_check_date;
                CLOSE   Pay_Pay_Check;
		IF (l_void_date IS NULL)
		THEN
 	           IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   PAYMENTS ...');
 	           END IF;
        	   OPEN    Pay_Pay;
   		   FETCH   Pay_Pay INTO l_document_num, l_doc_date,
							l_doc_creation_date,
							l_doc_created_by;
   		   CLOSE   Pay_Pay;
		ELSE
 	           IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   PAYMENTS VOID HANDLING ...');
 	           END IF;
                   OPEN    Pay_Pay_Void;
                   FETCH   Pay_Pay_Void INTO l_inv_payment_id;
                   CLOSE   Pay_Pay_Void;
		   IF (l_inv_payment_id <> 0)
		   THEN
 	              IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    PAYMENTS NON-VOID ...');
 	              END IF;
                      OPEN    Pay_Pay_Non_Void;
                      FETCH   Pay_Pay_Non_Void INTO l_document_num,
                                                    l_doc_creation_date,
                                                    l_doc_created_by;
                      CLOSE   Pay_Pay_Non_Void;
		      l_doc_date := l_check_date;
		   ELSIF (l_inv_payment_id = 0)
		   THEN
 	              IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    PAYMENTS VOID ...');
 	              END IF;
        	      OPEN    Pay_Pay_Void_Values;
   		      FETCH   Pay_Pay_Void_Values INTO l_document_num,
                                                       l_doc_creation_date,
                                                       l_doc_created_by;
   		      CLOSE   Pay_Pay_Void_Values;
		      l_doc_date := l_void_date;
		   END IF;
		END IF;

    IF (NVL(p_reference3, '-100') <> '-100') THEN
      BEGIN
        l_event_type_code := NULL;
        SELECT e.event_type_code
          INTO l_event_type_code
          FROM ap_ae_lines_all l,
               ap_ae_headers_all h,
               ap_accounting_events_all e
         WHERE l.source_table = 'AP_INVOICE_PAYMENTS'
           AND l.source_id = p_reference9
           AND l.ae_header_id = h.ae_header_id
           AND l.gl_sl_link_id = p_gl_sl_link_id
           AND e.accounting_event_id = h.accounting_event_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_event_type_code := NULL;
      END;
      IF (l_event_type_code = 'PAYMENT CANCELLATION') THEN
        p_reversed := 'R';
      END IF;
    END IF;

        ELSIF p_je_category_name = 'Treasury Confirmation'
                     AND upper(p_name) not like '%VOID%'  THEN
 	        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   TREASURY CONFIRMATION ...');
 	        END IF;
                OPEN    Pay_Treas;
                FETCH   Pay_Treas INTO l_document_num,
                                       l_doc_date,
                                       l_doc_creation_date,
                                       l_doc_created_by;
                CLOSE   Pay_Treas;

                --Modified for FSIO demo  ----Bug 8498437
                --Need to get invoice number of the treasury confirmation
                --Using reference4 as invoice id
                SELECT invoice_num
                INTO l_document_num
                FROM ap_invoices_all
                WHERE invoice_id = p_reference4;

	ELSIF p_je_category_name = 'Treasury Confirmation'
                            AND upper(p_name) like '%VOID%' THEN
 	        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   TREASURY CONFIRMATION VOID ...');
 	        END IF;
		OPEN    Pay_Treas_Check;
		FETCH   Pay_Treas_Check INTO l_doc_date, l_document_num;
		CLOSE   Pay_Treas_Check;
		OPEN 	Pay_Treas_Void;
		FETCH	Pay_Treas_Void INTO l_doc_creation_date,
                                            l_doc_created_by;
		CLOSE   Pay_Treas_Void;
	ELSE
 	        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   OTHERS ...');
 	        END IF;
		l_document_num      := p_name;
		l_doc_date	    := p_date;
		l_doc_creation_date := p_creation_date;
		l_doc_created_by    := p_created_by;
	END IF;
   -- Code for Receivables
   ELSIF p_je_source_name = 'Receivables'
   THEN
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'  RECEIVABLES ...');
      END IF;
      l_refer2 := p_reference2;
      l_document_num := p_reference4;
      IF (p_reference2 is null)
      THEN
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    REF2 IS NULL ...');
         END IF;
	 l_document_num := l_refer4;
      ELSE
	 IF (p_je_category_name = 'Adjustment')
   	 THEN
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    ADJUSTMENT ...');
            END IF;
   	    OPEN    Receivables_Adjustment;
   	    FETCH   Receivables_Adjustment INTO l_doc_date,
                                                l_doc_creation_date,
                                                l_doc_created_by;
   	    CLOSE   Receivables_Adjustment;
	 ELSIF (p_je_category_name = 'Credit Memo Applications')
   	 THEN
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    CREDIT MEMO APPLICATIONS ...');
            END IF;
   	    OPEN    Receivables_CMA;
   	    FETCH   Receivables_CMA INTO l_doc_date,
                                         l_doc_creation_date,
                                         l_doc_created_by;
   	    CLOSE   Receivables_CMA;
	 ELSIF (p_je_category_name IN ('Credit Memos',
                                     'Debit Memos', 'Sales Invoices'))
   	 THEN
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    CREDIT MEMOS/'||
                                     'Debit Memos/ Sales Invoices ...');
            END IF;
   	    OPEN    Receivables_Memos_Inv;
    	    FETCH   Receivables_Memos_Inv INTO l_doc_date,
                                               l_doc_creation_date,
                                               l_doc_created_by;
	    CLOSE   Receivables_Memos_Inv;
         ELSE
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TRADE RECEIPTS/ MISC RECEIPTS/ '||
                                     'Reversals/ Others ...');
            END IF;
	    l_cash_receipt_hist_id :=  SUBSTR(p_ref2, INSTR(p_ref2,'C')+1,
                                                LENGTH(p_ref2));

            IF (p_je_category_name = 'Misc Receipts')
            THEN
               IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'     PROCESSING A MISC RECEIPT');
               END IF;
               l_refer2 := p_ref2;
               l_cash_receipt_hist_id := p_reference5;
            ELSE
               IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'     PROCESSING A TRADE RECEIPT '||
                                        'or Other');
               END IF;
               l_refer2 := p_reference2;
               l_cash_receipt_hist_id := SUBSTR(p_ref2, INSTR(p_ref2,'C')+1,
                                                  LENGTH(p_ref2));
            END IF;
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'     CASH RECEIPT ID = '||L_REFER2);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'     CASH RECEIPT HIST ID = ' ||
                                                  l_cash_receipt_hist_id);
            END IF;
            l_receipt_hist_status := NULL;
      	    OPEN    Receivables_Hist (TO_NUMBER(l_cash_receipt_hist_id),
                  TO_NUMBER(l_refer2));
   	    FETCH   Receivables_Hist INTO l_rev_exists, l_receipt_hist_status;
   	    CLOSE   Receivables_Hist;
        IF (l_receipt_hist_status = 'REVERSED') THEN
          p_reversed := 'R';
        END IF;

  	    IF (l_rev_exists = 'N')
   	    THEN
	       l_doc_creation_date_d := NULL;
	       l_doc_created_by_d := NULL;
	       IF (p_je_category_name = 'Misc Receipts')
	       THEN
	          l_rev_exists := 'M';
	       ELSE
	          l_rev_exists := 'C';
	       END IF;
  	    ELSE
	       l_rev_exists := 'N';
               OPEN    Receivables_History  (TO_NUMBER(l_cash_receipt_hist_id));
               FETCH   Receivables_History into l_rev_exists,
                                                l_doc_creation_date_d,
                                                l_doc_created_by_d;
               CLOSE   Receivables_History;

	       IF (l_rev_exists = 'Y')
	       THEN
	          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'     CASH RECEIPT HIST ID EXITS IN'||
                                  ' Ar_Cash_Receipt_History_All ... REVERSAL');
	          END IF;
	       END IF;
	    END IF;
            IF (p_je_category_name <> 'Misc Receipts') AND (l_rev_exists = 'C')
            THEN

	       -- Find out IF Reference_2 contains Receivable_Application_Id
	       OPEN    Receivables_Applications;
	       FETCH   Receivables_Applications into l_temp_cr_hist_id;
	       CLOSE   Receivables_Applications;
	       IF (l_temp_cr_hist_id IS NOT NULL)
	       THEN
	          l_cash_receipt_hist_id := l_temp_cr_hist_id;
	          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'      CASH RECEIPT HIST ID EXITS IN'
                                        ||' Ar_Receivable_Applications_All: '
                                        ||l_cash_receipt_hist_id);
	          END IF;
		  -- Use cash_receipt_history_id obtained above to find
                  -- IF a row exits in Ar_Cash_Receipts_All
	          OPEN    Receivables_Exists;
                  FETCH   Receivables_Exists INTO l_rev_exists;
                  CLOSE   Receivables_Exists;
	          IF (l_rev_exists = 'Y')
	          THEN
	 	     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'      CASH RECEIPT HIST ID EXITS IN'
                                           ||' Ar_Cash_Receipt_History_All: '
                                           ||l_cash_receipt_hist_id);
	 	     END IF;
		     l_rev_exists := 'N';

      	    OPEN    Receivables_Hist (TO_NUMBER(l_cash_receipt_hist_id),
                  TO_NUMBER(l_refer2));
   	    FETCH   Receivables_Hist INTO l_dummy_rev_exists, l_receipt_hist_status;
   	    CLOSE   Receivables_Hist;
        IF (l_receipt_hist_status = 'REVERSED') THEN
          p_reversed := 'R';
        END IF;

		     -- Select the document info from
                     -- AR_CASH_RECEIPT_HISTORY_All table
		     OPEN    Receivables_History  (TO_NUMBER(l_cash_receipt_hist_id));
		     FETCH   Receivables_History into l_rev_exists,
                                                      l_doc_creation_date_d,
                                                      l_doc_created_by_d;
		     CLOSE   Receivables_History;
		     IF (l_rev_exists = 'Y')
		     THEN
	 	        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'      REVERSAL CASH RECEIPT '||
                                              'Hist Id'||
                                              ' exists ... REVERSAL');
	 	        END IF;
		     END IF;
	          END IF;
	       END IF;	-- End IF for l_temp_cr_hist_id
 	    ELSIF (p_je_category_name = 'Misc Receipts')
                            AND (l_rev_exists = 'M')
	    THEN
	       -- Find out IF Reference_2 contains Misc_Cash_Distribution_Id
         IF (p_rec_public_law_code_col IS NOT NULL) THEN
         l_rec_public_law_code := NULL;
         l_select := 'SELECT ''Y'', '||p_rec_public_law_code_col||'
	                      FROM   ar_misc_cash_distributions_all
	                     WHERE  misc_cash_distribution_id = '||to_number(l_cash_receipt_hist_id);
	       OPEN    Receivables_Distrib FOR l_select;
	       FETCH   Receivables_Distrib into l_rev_exists, l_rec_public_law_code;
	       CLOSE   Receivables_Distrib;
         p_rec_public_law_code := l_rec_public_law_code;
         ELSE
         p_rec_public_law_code := NULL;
         l_select := 'SELECT ''Y''
	                      FROM   ar_misc_cash_distributions_all
	                     WHERE  misc_cash_distribution_id = '||to_number(l_cash_receipt_hist_id);
	       OPEN    Receivables_Distrib FOR l_select;
	       FETCH   Receivables_Distrib into l_rev_exists;
	       CLOSE   Receivables_Distrib;
         END IF;

	       IF (l_rev_exists = 'Y')
	       THEN
	          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'      CASH RECEIPT HIST ID EXITS IN '
                                        ||'Ar_Misc_Cash_Distributions_All: '
                                        ||l_cash_receipt_hist_id);
	          END IF;
	          l_rev_exists := 'N';
		  -- Select the document info
                  -- from Ar_Misc_Cash_Distributions_All table
         IF (p_rec_public_law_code_col IS NOT NULL) THEN
         l_rec_public_law_code := NULL;
         l_select := '	SELECT ''Y'', creation_date, created_by, '||p_rec_public_law_code_col||'
	                        FROM   ar_misc_cash_distributions_all
                        	WHERE  misc_cash_distribution_id = '||l_cash_receipt_hist_id||'
                          	AND    created_from = ''ARP_REVERSE_RECEIPT.REVERSE''';
	       OPEN    Receivables_Misc FOR l_select;
	       FETCH   Receivables_Misc into l_rev_exists,
                                       l_doc_creation_date_d,
                                       l_doc_created_by_d,
                                       l_rec_public_law_code;
	       CLOSE   Receivables_Misc;
         IF (p_rec_public_law_code IS NULL) THEN
           p_rec_public_law_code := l_rec_public_law_code;
         END IF;
         ELSE
         p_rec_public_law_code := NULL;
         l_select := '	SELECT ''Y'', creation_date, created_by
	                        FROM   ar_misc_cash_distributions_all
                        	WHERE  misc_cash_distribution_id = '||l_cash_receipt_hist_id||'
                          	AND    created_from = ''ARP_REVERSE_RECEIPT.REVERSE''';
	       OPEN    Receivables_Misc FOR l_select;
	       FETCH   Receivables_Misc into l_rev_exists,
                                       l_doc_creation_date_d,
                                       l_doc_created_by_d;
	       CLOSE   Receivables_Misc;
         END IF;

		  IF (l_rev_exists = 'Y')
		  THEN
         p_reversed := 'R';
	 	     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'      MISC CASH DISC ID HAS'||
                                           ' Reverse value in created ' ||
                                           'from ... REVERSAL');
	 	     END IF;
		  END IF;
	       END IF;
 	    END IF; -- End IF for l_rev_exists = C/M
    	    OPEN    Receivables;
   	    FETCH   Receivables INTO l_doc_date,
                                     l_doc_creation_date_d,
                                     l_doc_created_by_d;
	    CLOSE   Receivables;
	    l_doc_creation_date := l_doc_creation_date_d;
   	    l_doc_created_by    := l_doc_created_by_d;
   	 END IF; -- End IF for p_je_category_name
      END IF; -- End IF for p_reference2
      IF (p_je_category_name = 'Misc Receipts') THEN
         IF ((p_rec_public_law_code_col IS NOT NULL) AND (p_rec_public_law_code IS NULL)) THEN
           l_rec_public_law_code := NULL;
           l_select := 'SELECT '||p_rec_public_law_code_col||'
  	                      FROM   ar_misc_cash_distributions_all
  	                     WHERE  misc_cash_distribution_id = '||to_number(l_cash_receipt_hist_id);
  	       OPEN    Receivables_Distrib FOR l_select;
  	       FETCH   Receivables_Distrib into l_rec_public_law_code;

  	       CLOSE   Receivables_Distrib;
           IF (p_rec_public_law_code IS NULL) THEN
             p_rec_public_law_code := l_rec_public_law_code;
           END IF;
         END IF;
     END IF;

   -- Code for Budgetary Transaction
   ELSIF p_je_source_name = 'Budgetary Transaction'
   THEN
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'  BUDGETARY TRANSACTION ...');
        END IF;
        fnd_file.put_line (fnd_file.log, 'Budget p_reference_1 = '||p_reference1);
        OPEN    Budget_Transac;
        FETCH   Budget_Transac INTO l_document_num,
                                    l_doc_date,
                                    l_doc_creation_date,
                                    l_doc_created_by;
        CLOSE   Budget_Transac;
        fnd_file.put_line (fnd_file.log, 'Budget l_document_num = '||l_document_num);
        p_gl_date := l_doc_date;
   -- Code for Manual
   ELSIF p_je_source_name = 'Manual'
   THEN
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'  MANUAL ...');
        END IF;
        OPEN    Manual;
        FETCH   Manual INTO l_doc_date;
        CLOSE   Manual;
        --Bug#3225337
	--IF (p_reference4 IS NOT NULL)
	IF (NVL(p_reference4, '-100') <> '-100')
	THEN
	   l_document_num      := p_reference4;
	ELSE
	   l_document_num      := p_name;
	END IF;
	l_doc_creation_date := p_creation_date;
	l_doc_created_by    := p_created_by;
   -- Code for Misc
   ELSE
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'  OTHERS ...');
        END IF;
        --Bug#3225337
	--IF (p_reference4 IS NOT NULL)
	IF (NVL(p_reference4, '-100') <> '-100')
	THEN
	   l_document_num      := p_reference4;
	ELSE
	   l_document_num      := p_name;
	END IF;
	l_doc_date          := p_date;
	l_doc_creation_date := p_creation_date;
	l_doc_created_by    := p_created_by;
   END IF; -- End IF for p_je_source_name
   -- Check for values. IF not put default
   IF l_document_num IS NULL
   THEN
      l_document_num := p_name;
   END IF;
   IF l_doc_date IS NULL
   THEN
      l_doc_date := p_date;
   END IF;
   IF l_doc_creation_date IS NULL
   THEN
      l_doc_creation_date := p_creation_date;
   END IF;
   IF l_doc_created_by IS NULL
   THEN
      l_doc_created_by := p_created_by;
   END IF;
   -- Set the out varibales
   p_doc_num 	       := l_document_num;
   p_doc_date	       := l_doc_date;
   p_doc_creation_date := l_doc_creation_date;
   p_doc_created_by    := l_doc_created_by;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'      DOCUMENT NUMBER - '||L_DOCUMENT_NUM);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'      DOCUMENT DATE   - '||L_DOC_DATE);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'      DOCUMENT CREATION DATE - '||
                                               l_doc_creation_date);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'      DOCUMENT CREATED BY - '||L_DOC_CREATED_BY);


FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'<<<<<<OUT>>>>>>');
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'p_doc_num='||p_doc_num);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'p_doc_date='||p_doc_date);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'p_doc_creation_date='||p_doc_creation_date);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'p_doc_created_by='||p_doc_created_by);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'p_gl_date='||p_gl_date);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'p_rec_public_law_code='||p_rec_public_law_code);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'p_reversed='||p_reversed);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'END GET_DOC_INFO');
END IF;

EXCEPTION
  WHEN OTHERS THEN
      g_error_code :=	SQLCODE;
      g_error_buf  := SQLERRM ||
      			' Error in Get_Doc_Info Procedure.' ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_buf);
      RETURN;
END GET_DOC_INFO;
-- -------------------------------------------------------------------
--                   PROCEDURE GET_DOC_USER
-- -------------------------------------------------------------------
-- Called from following procedures:
-- Journal_Process
-- Purpose:
-- Determine the user who created the journal line being processed
-- Also format the creation_date
-- -------------------------------------------------------------------
PROCEDURE GET_DOC_USER (p_created_by	       IN Number,
                        p_entry_user          OUT NOCOPY Varchar2)
IS
  l_module_name VARCHAR2(200);
BEGIN
  l_module_name := g_module_name || 'GET_DOC_USER';
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'');
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'ENTERING GET DOC USER ...');
   END IF;
   BEGIN
      SELECT user_name
      INTO   p_entry_user
      FROM   fnd_user
      WHERE  user_id = p_created_by;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
	p_entry_user := NULL;
   END;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'      DOCUMENT CREATED BY - '||P_ENTRY_USER);
   END IF;
   -- Setting up the retcode
   g_error_code := 0;
EXCEPTION
     WHEN OTHERS THEN
            g_error_code := SQLCODE ;
            g_error_buf  := SQLERRM  ||
                ' -- Error in Get_Doc_User procedure.' ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_buf);
            RETURN;
END GET_DOC_USER;
-- -------------------------------------------------------------------
--		 PROCEDURE RESET_ATTRIBUTES
--  The Process resets the values of all the FACTS Attributes
-- -------------------------------------------------------------------
-- ------------------------------------------------------------------
Procedure RESET_FACTS_ATTRIBUTES IS
  l_module_name VARCHAR2(200);
Begin
  l_module_name := g_module_name || 'RESET_FACTS_ATTRIBUTES';
   -- Reset all the Attribute Variable
     g_balance_type_flag            :=      Null    ;
     g_public_law_code_flag         :=      Null    ;
     g_reimburseable_flag           :=      Null    ;
     g_availability_flag            :=      Null    ;
     g_bea_category_flag            :=      Null    ;
     g_appor_cat_flag               :=      Null    ;
     g_transaction_partner_val      :=      Null    ;
     g_borrowing_source_flag        :=      Null    ;
     g_def_indef_flag               :=      Null    ;
     g_legis_ind_flag               :=      Null    ;
     g_pya_flag                     :=      Null    ;
     g_authority_type_flag          :=      Null    ;
     g_year_budget_auth             :=      Null    ;
     g_deficiency_flag              :=      Null    ;
     g_function_flag                :=      Null    ;
     g_balance_type_val             :=      Null    ;
     g_def_indef_val                :=      Null    ;
     g_public_law_code_val          :=      Null    ;
     g_appor_cat_val                :=      Null    ;
     g_authority_type_val           :=      Null    ;
     g_reimburseable_val            :=      Null    ;
     g_bea_category_val             :=      Null    ;
     g_borrowing_source_val         :=      Null    ;
     g_availability_val             :=      Null    ;
     g_legis_ind_val                :=      Null    ;
     g_pya_val                      :=      Null    ;
     g_function_flag                :=      NULL    ;
     g_transfer_ind                 :=      NULL    ;
     g_transfer_dept_id             :=      NULL    ;
     g_transfer_main_acct           :=      NULL    ;
     g_budget_function_val          :=      NULL    ;
     g_advance_type_val             :=      NULL    ;
     g_govt_non_govt_val            :=	    NULL    ;
     g_govt_non_govt_ind            :=      NULL    ;
     g_exch_non_exch_val            :=	    NULL    ;
     g_exch_non_exch_ind            :=      NULL    ;
     g_cust_non_cust_val 	    :=      NULL    ;
     g_cust_non_cust_ind            :=      NULL    ;
     g_budget_subfunction_ind       :=      NULL    ;
     g_budget_subfunction_val 	    :=      NULL    ;
     g_attributes_found             :=      NULL    ;

EXCEPTION
  WHEN OTHERS THEN
    g_error_code := SQLCODE ;
	  g_error_buf  := SQLERRM;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_buf);
    RAISE;

END reset_facts_attributes ;
-- -------------------------------------------------------------------
--                       PROCEDURE GET_USSGL_INFO
-- -------------------------------------------------------------------
--    Gets the information like enabled flag and reporting type
--    for the passed account number.
-- -------------------------------------------------------------------
PROCEDURE  GET_USSGL_INFO (p_ussgl_acct_num   IN VARCHAR2,
                           p_enabled_flag     IN OUT NOCOPY VARCHAR2,
                           p_reporting_type   IN OUT NOCOPY VARCHAR2)
IS
  l_module_name VARCHAR2(200);
 l_enabled_flag   VARCHAR2(1);
 l_reporting_type VARCHAR2(1);
BEGIN
  l_module_name := g_module_name || 'GET_USSGL_INFO';
  SELECT ussgl_enabled_flag,
         reporting_type
  INTO   l_enabled_flag,
         l_reporting_type
  FROM   fv_facts_ussgl_accounts
  WHERE  ussgl_account = p_ussgl_acct_num;

  p_enabled_flag   := l_enabled_flag;
  p_reporting_type := l_reporting_type;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- Account Number not found in FV_FACTS_USSGL_ACCOUNTS table.
    -- Return Nulls.
    p_enabled_flag    := NULL;
    p_reporting_type  := NULL;
  WHEN OTHERS THEN
    g_error_code := sqlcode ;
    g_error_buf := sqlerrm ;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_buf);
    RETURN ;
END get_ussgl_info ;
-- --------------------------------------------------------------------
--          PROCEDURE GET_FUND_GROUP_INFO
-- --------------------------------------------------------------------
-- Its primary purpose get the fund Group, Dept Id, bureau Id and
-- balancing segment from the fv_fund_parameters table for the
-- passed Code Combination Id.
-- --------------------------------------------------------------------
PROCEDURE get_fund_group_info (p_ccid     gl_balances.code_combination_id%TYPE,
			       p_fund_group    IN OUT NOCOPY VARCHAR2,
			       p_dept_id       IN OUT NOCOPY VARCHAR2,
			       p_bureau_id     IN OUT NOCOPY VARCHAR2,
			       p_bal_segment   IN OUT NOCOPY VARCHAR2)
IS
  l_module_name VARCHAR2(200);
l_ret_val     BOOLEAN := TRUE;
l_fund_cursor INTEGER;
l_fund_select VARCHAR2(2000);
--l_fund_fetchn INTEGER;
l_exec_ret    INTEGER;
l_row_exists  VARCHAR2(1) := NULL;
BEGIN
  l_module_name := g_module_name || 'get_fund_group_info';
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'');
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'ENTERING GET FUND GROUP INFO ...');
  END IF;
  g_error_code := 0;
  g_error_buf  := NULL;

  l_fund_select := 'SELECT ''X'', fts.fund_group_code, fts.department_id, ' ||
                           'fts.bureau_id, ' ||
                           'glc.' || g_bal_segment_name  || ' ' ||
                   'FROM gl_code_combinations glc, fv_fund_parameters ffp, ' ||
                         'fv_treasury_symbols fts ' ||
                   'WHERE glc.code_combination_id  = :ccid
                      AND glc.chart_of_accounts_id = :coa_id
                      AND ffp.treasury_symbol_id = fts.treasury_symbol_id
                      AND ffp.set_of_books_id = :set_of_books_id
                      AND glc.' || g_bal_segment_name || ' = ffp.fund_value';

  BEGIN
    EXECUTE IMMEDIATE l_fund_select INTO l_row_exists, p_fund_group,
                                         p_dept_id, p_bureau_id,
                                         p_bal_segment
                  USING p_ccid, g_coa_id, g_set_of_books_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	  NULL;
    WHEN OTHERS THEN
      g_error_code := sqlcode;
      g_error_buf := sqlerrm;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception_1',g_error_buf);
  END;

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   L_ROW_EXISTS: '||L_ROW_EXISTS);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   P_FUND_GROUP:  '||P_FUND_GROUP);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   P_DEPT_ID:  '||P_DEPT_ID);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   P_BUREAU_ID: '||P_BUREAU_ID);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   P_BAL_SEGMENT: '||P_BAL_SEGMENT);
  END IF;
  IF (l_row_exists IS NULL)
  THEN
    p_fund_group := NULL;
    p_dept_id    := NULL;
    p_bureau_id  := NULL;
    DECLARE
      l_ret_val	Boolean := TRUE;
      l_bal_select	Varchar2(2000);
      --l_bal_fetch	Integer;
      l_exec_ret	Integer;
    BEGIN
      l_bal_select := 'SELECT glc.' || g_bal_segment_name || ' '
      ||'FROM gl_code_combinations glc '
      ||'WHERE glc.code_combination_id = ' || to_char(p_ccid);
      BEGIN
	EXECUTE IMMEDIATE l_bal_select INTO p_bal_segment;
      EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  NULL;
	WHEN OTHERS THEN
	  g_error_code := sqlcode;
	  g_error_buf := sqlerrm;
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception_2',g_error_buf);
      END;
    EXCEPTION
      WHEN OTHERS THEN
	g_error_code := sqlcode;
	g_error_buf := sqlerrm;
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception_3',g_error_buf);
    END;
  ELSIF p_bureau_id IS NULL THEN
    p_bureau_id := '00';
  END IF ;
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'LEAVING GET FUND GROUP INFO ...');
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
   g_error_buf  := 'Get Fund Group Info: NO DATA FOUND for ccid : ' || p_ccid;
  WHEN OTHERS THEN
   DBMS_SQL.CLOSE_CURSOR(l_fund_cursor);
   g_error_code := 2 ;
   g_error_buf  := 'GET FUND GROUP INFO - Exception (Others) - ' ||
	 to_char(sqlcode) || ' - ' || sqlerrm ;
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_buf);
END get_fund_group_info ;
-- --------------------------------------------------------------------
--          	PROCEDURE POPULATE_TABLE
-- --------------------------------------------------------------------
-- This procedure gets called from procedure Journal_Process.
-- Its main purpose is to insert records in FV_FACTS_TRX_TEMP table.
-- --------------------------------------------------------------------
PROCEDURE populate_table
              ( p_treasury_symbol_id 	NUMBER ,
 	  	p_set_of_books_id 	NUMBER ,
	 	p_code_combination_id   NUMBER ,
 		p_fund_value 		VARCHAR2,
 		p_account_number 	VARCHAR2,
		p_document_source 	VARCHAR2,
		p_document_category	VARCHAR2,
 		p_document_number 	VARCHAR2,
 		p_transaction_date 	DATE,
 		p_creation_date_time 	DATE,
 		p_entry_user		VARCHAR2,
 		p_fed_non_fed 		VARCHAR2,
 		p_trading_partner 	VARCHAR2,
 		p_exch_non_exch 	VARCHAR2,
 		p_cust_non_cust 	VARCHAR2,
		p_budget_subfunction 	VARCHAR2,
 		p_debit 		NUMBER,
 		p_credit 		NUMBER,
 		p_transfer_dept_id 	VARCHAR2,
 		p_transfer_main_acct 	VARCHAR2,
 		p_year_budget_auth 	VARCHAR2,
 		p_budget_function 	VARCHAR2,
 		p_advance_flag 		VARCHAR2,
 		p_cohort 		VARCHAR2,
 		p_begin_end 		VARCHAR2,
 		p_indef_def_flag 	VARCHAR2,
 		p_appor_cat_b_dtl 	VARCHAR2,
 		p_appor_cat_b_txt 	VARCHAR2,
		p_prn_num               VARCHAR2,
    p_prn_txt               VARCHAR2,
    p_public_law 		VARCHAR2,
		p_appor_cat_code 	VARCHAR2,
 		p_authority_type 	VARCHAR2,
 		p_transaction_partner   VARCHAR2,
		p_reimburseable_flag 	VARCHAR2,
 		P_bea_category 		VARCHAR2,
 		p_borrowing_source 	VARCHAR2,
		p_def_liquid_flag 	VARCHAR2,
 		p_deficiency_flag	VARCHAR2,
 		p_availability_flag	VARCHAR2,
 		p_legislation_flAg 	VARCHAR2,
    p_pya_flag VARCHAR2,
		p_je_line_creation_date DATE,
		p_je_line_modified_date DATE,
		p_je_line_period_name   VARCHAR2,
		p_gl_date 		DATE,
        	p_gl_posted_date 	DATE,
          p_reversal_flag VARCHAR2,
          p_sla_hdr_event_id NUMBER,
          p_sla_hdr_creation_date DATE,
          p_sla_entity_id NUMBER ) IS
  l_module_name VARCHAR2(200);
BEGIN
  l_module_name := g_module_name || 'populate_table';
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,' POPULATING FV_FACTS_TRX_TEMP TABLE ...');
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    TREASURY SYMBOL ID :'||P_TREASURY_SYMBOL_ID);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    SET OF BOOKS ID    :'||P_SET_OF_BOOKS_ID);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    CCID               :'||P_CODE_COMBINATION_ID);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    FUND VALUE         :'||P_FUND_VALUE);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    ACCOUNT NUMBER     :'||P_ACCOUNT_NUMBER);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    DOC SOURCE         :'||P_DOCUMENT_SOURCE);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    DOC NUMBER         :'||P_DOCUMENT_NUMBER);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    TXN DATE           :'||P_TRANSACTION_DATE);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    CREATION DATE/TIME :'||P_CREATION_DATE_TIME);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    ENTRY USER         :'||P_ENTRY_USER);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    FED/NON-FED        :'||P_FED_NON_FED);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    TRADING PARTNER    :'||SUBSTR(P_TRADING_PARTNER,1,6));
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    EXCH/NON-EXCH      :'||P_EXCH_NON_EXCH);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    CUST/NON-CUST      :'||P_CUST_NON_CUST);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    BUDGET SUB FUNCTION:'||P_BUDGET_SUBFUNCTION);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    DEBIT              :'||P_DEBIT);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    CREDIT             :'||P_CREDIT);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    TRANSFER DEPT ID   :'||P_TRANSFER_DEPT_ID);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    TRANSFER MAIN ACCT :'||P_TRANSFER_MAIN_ACCT);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    YEAR BUDGET AUTH   :'||P_YEAR_BUDGET_AUTH);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    ADVANCE FLAG       :'||P_BUDGET_FUNCTION);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    COHORT             :'||P_COHORT);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    BEGIN/END          :'||P_BEGIN_END);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    INDEF/DEF FLAG     :'||P_INDEF_DEF_FLAG);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    APPOR CAT B DTL    :'||P_APPOR_CAT_B_DTL);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    APPOR CAT B TXT    :'||P_APPOR_CAT_B_TXT);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    PRN  NUM           :'||P_PRN_NUM);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    PRN TEXT           :'||P_PRN_TXT);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    PUBLIC LAW         :'||P_PUBLIC_LAW);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    APPOR CAT CODE     :'||P_APPOR_CAT_CODE);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    AUTHORITY TYPE     :'||P_AUTHORITY_TYPE);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    TRANSACTION PARTNER:'||P_TRANSACTION_PARTNER);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    REIMBURSEABLE FLAG :'||P_REIMBURSEABLE_FLAG);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    BEA CATEGORY       :'||P_BEA_CATEGORY);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    BORROWING SOURCE   :'||P_BORROWING_SOURCE);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    DEF LIQUID FLAG    :'||P_DEF_LIQUID_FLAG);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    DEFICIENCY FLAG    :'||P_DEFICIENCY_FLAG);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    AVAILABILITY FLAG  :'||P_AVAILABILITY_FLAG);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    LEGISLATION FLAG   :'||P_LEGISLATION_FLAG);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    PYA_FLAG   :'||P_PYA_FLAG);

     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    TRUNCATED APPOR CAT B TXT:'||SUBSTR(P_APPOR_CAT_B_TXT,1,25));
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    LINE CREATION DATE :'||P_JE_LINE_CREATION_DATE);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    LINE MODIFIED DATE :'||P_JE_LINE_MODIFIED_DATE);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    LINE PERIOD NAME   :'||P_JE_LINE_PERIOD_NAME);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    GL DATE            :'||P_GL_DATE);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    GL POSTED DATE     :'||P_GL_POSTED_DATE);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    SLA HEADER EVENT ID     :'||P_SLA_HDR_EVENT_ID);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    SLA HEADER CREATON DATE :'||P_SLA_HDR_CREATION_DATE);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    SLA ENTITY ID     :'||P_SLA_ENTITY_ID);

   END IF;

   INSERT INTO fv_facts_trx_temp
	               (treasury_symbol_id   	 ,
			set_of_books_id 	 ,
 			code_combination_id      ,
 			fund_value               ,
 			account_number		 ,
 			document_source 	 ,
 			document_category        ,
 			document_number	 	 ,
 			transaction_date 	 ,
 			creation_date_time 	 ,
 			entry_user      	 ,
 			fed_non_fed   		 ,
 			trading_partner		 ,
 			exch_non_exch   	 ,
 			cust_non_cust     	 ,
 			budget_subfunction  	 ,
 			debit              	 ,
 			credit             	 ,
 			transfer_dept_id   	 ,
 			transfer_main_acct 	 ,
 			year_budget_auth   	 ,
 			budget_function    	 ,
 			advance_flag        	 ,
 			cohort             	 ,
 			begin_end          	 ,
 			indef_def_flag     	 ,
 			appor_cat_b_dtl 	 ,
 			appor_cat_b_txt 	 ,
                        PROGRAM_RPT_CAT_NUM      ,
                        PROGRAM_RPT_CAT_TXT      ,
 			public_law        	 ,
 			appor_cat_code   	 ,
 			authority_type    	 ,
 			transaction_partner 	 ,
 			reimburseable_flag       ,
 			bea_category             ,
 			borrowing_source         ,
 			def_liquid_flag          ,
 			deficiency_flag          ,
 			availability_flag        ,
 			legislation_flag         ,
      pya_flag                 ,
                        journal_creation_date    ,
			journal_modified_date    ,
			period_name              ,
			gl_date                  ,
            		gl_posted_date,
                reversal_flag ,
                sla_hdr_event_id,
                sla_hdr_creation_date,
                sla_entity_id 	 )
 		 VALUES
                   (   	p_treasury_symbol_id 	 ,
                       	p_set_of_books_id	 ,
                       	p_code_combination_id  	 ,
                       	p_fund_value 		 ,
			p_account_number 	 ,
			p_document_source 	 ,
			p_document_category      ,
			p_document_number	 ,
 			p_transaction_date 	 ,
 			p_creation_date_time 	 ,
 			p_entry_user      	 ,
			p_fed_non_fed   	 ,
			--Modified for bug 7324241
      --SUBSTR(p_trading_partner,1,6),
      --populate trading partner only if fed non fed is F
      DECODE(p_fed_non_fed, 'F', SUBSTR(p_trading_partner,1,6), NULL),
 			p_exch_non_exch   	 ,
 			p_cust_non_cust      	 ,
 			p_budget_subfunction 	 ,
 			p_debit                  ,
 			p_credit                 ,
 			p_transfer_dept_id       ,
 			p_transfer_main_acct     ,
 			p_year_budget_auth       ,
 			p_budget_function        ,
			p_advance_flag           ,
 			p_cohort                 ,
 			p_begin_end              ,
 			p_indef_def_flag         ,
 			p_appor_cat_b_dtl 	 ,
 			SUBSTR(p_appor_cat_b_txt,1,25),
                        p_prn_num                ,
                        SUBSTR(p_prn_txt,1,25)   ,
 			p_public_law             ,
 			p_appor_cat_code   	 ,
 			p_authority_type    	 ,
 			--p_transaction_partner 	 , bug 7324241
      DECODE(p_transaction_partner,'N',NULL,p_transaction_partner)  ,
		 	p_reimburseable_flag     ,
 			p_bea_category           ,
 			p_borrowing_source       ,
 			p_def_liquid_flag        ,
 			p_deficiency_flag        ,
 			p_availability_flag      ,
 			p_legislation_flag       ,
      p_pya_flag,
                        p_je_line_creation_date  ,
                        p_je_line_modified_date  ,
                        p_je_line_period_name    ,
			p_gl_date                ,
		        p_gl_posted_date,
            NVL(p_reversal_flag, ' ') ,
            p_sla_hdr_event_id,
            p_sla_hdr_creation_date,
            p_sla_entity_id        );

   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   POPULATED FV_FACTS_TRX_TEMP TABLE ...');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
       g_error_code := SQLCODE ;
       g_error_buf := 'POPULATE TABLE procedure, Error Occured -- ' || SQLERRM;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_buf);
END populate_table;


-- -------------------------------------------------------------------
--		 PROCEDURE LOAD_FACTS_ATTRIBUTES
-- -------------------------------------------------------------------
-- This procedure selects the attributes for the Account number
-- segment from FV_FACTS_ATTRIBUTES table and load them into global
-- variables for usage in the FACTS Main process. It also calculates
-- one time pull up values for the account number that does not
-- require drill down into GL transactions.
-- ------------------------------------------------------------------
PROCEDURE load_facts_attributes 	(acct_num VARCHAR2,
			 		 fund_val VARCHAR2)
IS
  l_module_name VARCHAR2(200);
	--l_financing_acct_flag  	VARCHAR2(1) 	;
	--l_established_fy        NUMBER 		;
	l_resource_type		VARCHAR2(80) 	;
	l_fund_category		VARCHAR2(1)	;
        l_ussgl_enabled         VARCHAR2(1)	;
        l_reporting_type        VARCHAR2(1)	;
        l_budget_sub         fv_fund_parameters.budget_subfunction %TYPE;
        l_cnc                fv_treasury_symbols.cust_non_cust%TYPE;
BEGIN
  l_module_name := g_module_name || 'load_facts_attributes';
    BEGIN
        SELECT 	balance_type,
		public_law_code,
		reimburseable_flag,
		availability_time,
		bea_category,
		apportionment_category,
		SUBSTR(transaction_partner,1,1),
		borrowing_source,
		definite_indefinite_flag,
		legislative_indicator,
    pya_flag,
		authority_type,
		deficiency_flag,
		function_flag,
		advance_flag,
		transfer_flag,
                govt_non_govt,
		exch_non_exch,
		cust_non_cust,
		budget_subfunction
    	INTO	g_balance_type_flag,
		g_public_law_code_flag,
		g_reimburseable_flag,
		g_availability_flag,
		g_bea_category_flag,
		g_appor_cat_flag,
		g_transaction_partner_val,
		g_borrowing_source_flag,
		g_def_indef_flag,
		g_legis_ind_flag,
    g_pya_flag,
		g_authority_type_flag,
		g_deficiency_flag,
		g_function_flag,
		g_advance_flag,
		g_transfer_ind ,
                g_govt_non_govt_ind,
                g_exch_non_exch_ind,
                g_cust_non_cust_ind,
                g_budget_subfunction_ind
    	FROM	FV_FACTS_ATTRIBUTES
       WHERE    Facts_Acct_Number = acct_num
         AND    set_of_books_id = g_set_of_books_id;
         g_attributes_found :='Y';
    EXCEPTION
	WHEN NO_DATA_FOUND THEN
 FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, 'NO ATTRIBUTES DEFINIED FOR THE ACCOUNT - ' ||
			           acct_num );
             g_attributes_found := 'N';
             RETURN;
	WHEN OTHERS THEN
	    g_error_code := sqlcode ;
	    g_error_buf  := sqlerrm ;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception_3',g_error_buf);
          RETURN;
    END ;


 IF g_attributes_found ='Y' THEN
    BEGIN
    	SELECT 	UPPER(fts.resource_type),
			def_indef_flag,
			ffp.fund_category
    	INTO 		l_resource_type,
			g_def_indef_val,
			l_fund_category
    	FROM    	fv_treasury_symbols	  fts,
			fv_fund_parameters	  ffp
    	WHERE   	ffp.treasury_symbol_id 	= fts.treasury_symbol_id
    	AND     	ffp.fund_value		= fund_val
	AND		fts.treasury_symbol_id	= g_treasury_symbol_id
    	AND 		fts.set_of_books_id 	= g_set_of_books_id
    	AND 		ffp.set_of_books_id 	= g_set_of_books_id  ;

        -- g_fund_category := l_fund_category;
    EXCEPTION
	When NO_DATA_FOUND Then
	    g_error_code := -1 ;
	    g_error_buf := 'Error getting Fund Category value for the fund - '||
			  fund_val || ' [LOAD_FACTS_ATTRIBURES]' ;
           RETURN;
	WHEN OTHERS THEN
	    g_error_code := sqlcode ;
	    g_error_buf  := sqlerrm  || ' [LOAD_FACTS_ATTRIBURES]' ;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception_4',g_error_buf);
         RETURN;
    END ;
    ------------------------------------------------
    -- Deriving Indefinite Definite Flag
    ------------------------------------------------
    IF NVL(g_def_indef_flag,'X') <> 'Y' THEN
	 g_def_indef_val := NULL;
    END IF ;
    ------------------------------------------------
    -- Deriving Public Law Code Flag
    ------------------------------------------------
    IF    g_public_law_code_flag = 'N' THEN
	    g_public_law_code_val := NULL ;
    END IF ;
    IF     g_availability_flag = 'N' THEN
	   g_availability_val := NULL;
    ELSE
           g_availability_val := g_availability_flag;
    END IF ;
   --Modified for bug 7324241
   --If tp val is anything other than N
   --set it to a temporary value
   IF g_transaction_partner_val <> 'N' THEN
	    g_transaction_partner_val := '9';
   END IF ;
    ------------------------------------------------
    -- Deriving Apportionment Category Code
    ------------------------------------------------
    IF g_appor_cat_flag = 'Y' THEN
	IF l_fund_category IN ('A','S') THEN
	    g_appor_cat_val := 'A' ;
	ElSIF l_fund_category IN ('B','T') THEN
	    g_appor_cat_val := 'B' ;
	ElSIF l_fund_category in ('R','C')  THEN
	    g_appor_cat_val := 'C' ;
	ElSE
	    g_appor_cat_val := NUll;
	END IF ;
    ELSE
        g_appor_cat_val := NULL;
    END IF ;


    ------------------------------------------------
    -- Deriving Authority Type
    ------------------------------------------------
    IF NVL(g_authority_type_flag,'N') <> 'N' THEN
        g_authority_type_val := g_authority_type_flag;
    ELSE
	g_authority_type_val := ' ' ;
    END IF ;
    --------------------------------------------------------------------
    -- Deriving Reimburseable Flag Value
    --------------------------------------------------------------------
    IF g_reimburseable_flag = 'Y' THEN
    	IF l_fund_category IN ('A', 'B','C') THEN
	    g_reimburseable_val := 'D' ;
	ELSIF l_fund_category in ('R','S','T') THEN
	    g_reimburseable_val := 'R' ;
	ELSE
	    g_reimburseable_val := NULL;
	END IF ;
    ELSE
	g_reimburseable_val := NULL;
    END IF ;
    --------------------------------------------------------------------
    -- Deriving BEA Category and Borrowing Source Values
    --------------------------------------------------------------------
    IF g_bea_category_flag = 'Y' OR g_borrowing_source_flag = 'Y' THEN
	BEGIN
	    SELECT RPAD(SUBSTR(ffba.borrowing_source,1,6), 6)
	    INTO   g_borrowing_source_val
	    FROM   fv_facts_budget_accounts	ffba,
		     fv_facts_federal_accounts	fffa,
		     fv_treasury_symbols		fts ,
		     fv_facts_bud_fed_accts	ffbfa
	    WHERE  fts.federal_acct_symbol_id  = fffa.federal_acct_symbol_id
	    AND    fffa.federal_acct_symbol_id = ffbfa.federal_acct_symbol_id
	    AND    ffbfa.budget_acct_code_id   = ffba.budget_acct_code_id
	    AND    fts.treasury_symbol_id      = g_treasury_symbol_id
	    AND    fts.set_of_books_id         = g_set_of_books_id
	    AND    fffa.set_of_books_id        = g_set_of_books_id
	    AND    ffbfa.set_of_books_id       = g_set_of_books_id
	    AND    ffba.set_of_books_id        = g_set_of_books_id ;

	    SELECT RPAD(SUBSTR(bea_category,1,5), 5)
	    INTO   g_bea_category_val
	    FROM   fv_fund_parameters
	    WHERE  treasury_symbol_id      = g_treasury_symbol_id
	    AND    set_of_books_id         = g_set_of_books_id
      AND    fund_category           = l_fund_category;

	    IF g_bea_category_flag = 'N' THEN
		g_bea_category_val 	:= NULL;
	    END IF ;
	    IF g_borrowing_source_flag = 'N' THEN
		g_borrowing_source_val := NULL;
	    END IF ;
	EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	        g_bea_category_val 	:= Null;
	        g_borrowing_source_val  := Null;
	END ;
    ELSE
	g_bea_category_val 	:= Null;
	g_borrowing_source_val  := Null;
    END IF ;
    g_def_liquid_flag := ' ' ;
    g_deficiency_flag := ' ' ;
    --------------------------------------------------------------------
    -- Deriving Budget Function
    --------------------------------------------------------------------
    IF g_function_flag = 'Y'  THEN
        BEGIN
            SELECT RPAD(SUBSTR(ffba.budget_function,1,3), 3)
            INTO   g_budget_function_val
            FROM   fv_facts_budget_accounts     ffba,
                   fv_facts_federal_accounts    fffa,
                   fv_treasury_symbols          fts ,
                   fv_facts_bud_fed_accts       ffbfa
            WHERE  fts.federal_acct_symbol_id  = fffa.federal_acct_symbol_id
            AND    fffa.federal_acct_symbol_id = ffbfa.federal_acct_symbol_id
            AND    ffbfa.budget_acct_code_id   = ffba.budget_acct_code_id
            AND    fts.treasury_symbol_id      = g_treasury_symbol_id
            AND    fts.set_of_books_id         = g_set_of_books_id
            AND    fffa.set_of_books_id        = g_set_of_books_id
            AND    ffbfa.set_of_books_id       = g_set_of_books_id
            AND    ffba.set_of_books_id        = g_set_of_books_id ;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
 		g_budget_function_val      := RPAD(' ', 3);
        END ;
    ELSE
        g_budget_function_val      := RPAD(' ', 3);
    END IF ;

    GET_USSGL_INFO (acct_num, l_ussgl_enabled, l_reporting_type);
    IF g_error_code <> 0  THEN
        RETURN;
    END IF;

    -- Account on USSGL_ACCOUNTS
/*
      IF l_ussgl_enabled IS NOT NULL  THEN
         IF l_ussgl_enabled = 'N' THEN
           	g_govt_non_govt_ind   := 'X';
           	RETURN;
         ELSIF l_reporting_type = '2' THEN
     	  Account Number is not a valid FACTS II Account
     	  skip the transaction and go ahead with the next.
     		 g_govt_non_govt_ind   := 'X';
     		 RETURN ;
   	 ELSE
*/

    	    BEGIN
       	 --  	g_govt_non_govt_val	   := 'X';
       	        ----------------------------------------------
      		--  Deriving Budget Sub Function value
      		----------------------------------------------
       		IF (g_budget_subfunction_ind = 'Y')   THEN
         		SELECT  budget_subfunction
          		INTO   l_budget_sub
          		FROM   fv_fund_parameters
          		WHERE  fund_value      = FUND_VAL
          		AND    set_of_books_id = g_set_of_books_id;

           		IF (l_budget_sub IS NOT NULL)  THEN
      	     			g_budget_subfunction_val  := l_budget_sub;
          		END IF;
       		ELSE
           		g_budget_subfunction_val	:= NULL;
       		END IF;
      		---------------------------------------------------
      		--  Deriving Exchange Non Exchange Indicator value
      		---------------------------------------------------
       		IF (g_exch_non_exch_ind <> 'Y') THEN
			IF (g_exch_non_exch_ind = 'N') THEN
	   			g_exch_non_exch_val	:= NULL;
			ELSE
      	   			g_exch_non_exch_val := g_exch_non_exch_ind;
			END IF;
       		END IF;
          --------------------------------------------------
      		--  Deriving PYA value
      		---------------------------------------------------
       		IF (g_pya_flag ='Y') THEN
            g_pya_val	:= 'X';
          ELSE
            g_pya_val := ' ';
       		END IF;
      		----------------------------------------------
      		--  Deriving Custodial Non Custodial Value
      		----------------------------------------------
     		IF (g_cust_non_cust_ind = 'Y')  THEN
        		SELECT fts.cust_non_cust
        		INTO    l_cnc
        		FROM   fv_treasury_symbols fts, fv_fund_parameters ffp
        		WHERE  fts.treasury_symbol_id = ffp.treasury_symbol_id
        		AND    ffp.set_of_books_id = g_set_of_books_id
			AND    ffp.fund_value = fund_val;

			IF (l_cnc IS NOT NULL) 	THEN
      	   			g_cust_non_cust_val  := l_cnc ;
     			ELSE
	   			g_cust_non_cust_val  := NULL;
     			END IF;
    		END IF;
              END;
         END IF;
--    END IF; --  -- l_ussgl_enabled
--  END IF;

EXCEPTION
    When Others Then
	g_error_code := sqlcode ;
	g_error_buf := sqlerrm || ' [LOAD_FACTS_ATTRIBUTES]' ;
   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_buf);
	return;

END load_facts_attributes ;
-- -------------------------------------------------------------------
--		 PROCEDURE PURGE_FACTS_TRANSACTIONS
-- -------------------------------------------------------------------
--    Purges all FACTS transactions from the FV_FACTS_TRX_TEMP table for
--    the passed Treasaury Symbol.
-- ------------------------------------------------------------------
PROCEDURE purge_facts_transactionS
IS
  l_module_name VARCHAR2(200);
BEGIN
  l_module_name := g_module_name || 'purge_facts_transactionS';
	DELETE FROM fv_facts_trx_temp;
	COMMIT ;
EXCEPTION
	-- Exception Processing
	WHEN NO_DATA_FOUND THEN
	    NULL ;
	WHEN OTHERS THEN
	    g_error_code := sqlcode ;
	    g_error_buf  := sqlerrm  ||
                          'PURGE DATA';
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_buf);
            RETURN ;
END purge_facts_transactions ;
-- -------------------------------------------------------------------
--		 PROCEDURE GET_SGL_PARENT
-- -------------------------------------------------------------------
--    Gets the SGL Parent Account for the passed account number
-- ------------------------------------------------------------------
PROCEDURE get_sgl_parent(
                        Acct_num                   VARCHAR2,
                        sgl_acct_num   OUT NOCOPY  VARCHAR2)
IS
  l_module_name VARCHAR2(200);
    l_exists		VARCHAR2(1)		;
    l_acc_val_set_id	NUMBER		;
  BEGIN
  l_module_name := g_module_name || 'get_sgl_parent';
    -- Getting the Value Set Id for the Account Segment
    Begin
        -- Getting the Value set Id for finding hierarchies
        SELECT  flex_value_set_id
        INTO    l_acc_val_set_id
        FROM    fnd_id_flex_segments
        WHERE   application_column_name = g_acct_segment_name
        AND     id_flex_code            = 'GL#'
        AND     id_flex_num             = g_coa_id ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            g_error_code := -1 ;
            g_error_buf := 'Error getting Value Set Id '||
                           'for segment' ||g_acct_segment_name ||
                           ' [GET_SGL_PARENT]' ;
            RETURN;
    END ;

    -- Finding the parent of the Account Number in GL
    BEGIN
        SELECT parent_flex_value
        Into   sgl_acct_num
        From   fnd_flex_value_hierarchies
        WHERE  (acct_num BETWEEN child_flex_value_low
                      AND child_flex_value_high)
        AND    parent_flex_value <> 'T'
        AND    flex_value_set_id = l_acc_val_set_id
        AND    parent_flex_value IN
                        (SELECT ussgl_account
                         FROM   fv_facts_ussgl_accounts
                         WHERE  ussgl_account = parent_flex_value);

		BEGIN
	  	  -- Look for parent in FV_FACTS_ATTRIBUTES table
	   		SELECT 'X'
	   	 	INTO l_exists
	    		FROM fv_facts_attributes
	    		WHERE facts_acct_number = sgl_acct_num
                        AND   set_of_books_id = g_set_of_books_id;
	    	-- Return the account Number
IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'SGL PARENT ACCOUNT:'||
                                               sgl_acct_num||'-'||
                                               acct_num) ;
END IF;
	    		RETURN ;
		EXCEPTION
	    		WHEN NO_DATA_FOUND THEN
				sgl_acct_num := NULL 	;
				RETURN			;
		END ;
    EXCEPTION
	WHEN NO_DATA_FOUND or TOO_MANY_ROWS THEN
	  -- No Parent Exists or Too Many Parents. Return Nulls
 		 RETURN ;
        WHEN OTHERS THEN
          g_error_code := SQLCODE ;
      	  g_error_buf  := SQLERRM;
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_buf);
          RETURN;
END;
End get_sgl_parent ;
-- -------------------------------------------------------------------
--		 PROCEDURE GET_COHORT_INFO
-- -------------------------------------------------------------------
--    Gets the cohort segment name based on the Financing Acct value
-- ------------------------------------------------------------------
PROCEDURE get_cohort_info
IS
  l_module_name VARCHAR2(200);
    l_financing_acct	VARCHAR2(1)	;
BEGIN
  l_module_name := g_module_name || 'get_cohort_info';

    SELECT 	FFFA.financing_account,
		FFFA.cohort_segment_name
    INTO  	l_financing_acct,
		g_cohort_seg_name
    FROM        FV_FACTS_FEDERAL_ACCOUNTS	FFFA,
   		FV_TREASURY_SYMBOLS 		FTS
    WHERE  	FFFA.Federal_acct_symbol_id 	= FTS.Federal_acct_symbol_id
    AND		FTS.treasury_symbol_id		= g_treasury_symbol_id
    AND    	FTS.set_of_books_id		= g_set_of_books_id
    AND    	FFFA.set_of_books_id		= g_set_of_books_id ;
    ------------------------------------------------
    --	Deriving COHORT Value
    ------------------------------------------------
    IF l_financing_acct NOT IN ('D', 'G') THEN
	-- Consider COHORT value only for 'D' and 'G' financing Accounts
           g_cohort_seg_name := NULL 	;

    END IF ;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
    	g_error_code := -1 ;
    	g_error_buf := 'No Financing Account found for the passed Treasury Symbol [GET_COHORT_INFO] ' ;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.exception1',g_error_buf);
        RETURN;
    WHEN TOO_MANY_ROWS THEN
        g_error_code := -1 ;
    	  g_error_buf  := 'More than one Financing Account returned for the passed Treasury Symbol [GET_COHORT_INFO]'  ;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.exception2',g_error_buf);
	 RETURN;
    WHEN OTHERS THEN
        g_error_code := SQLCODE ;
    	  g_error_buf  :=  'WHEN OTHERS IN [GET_COHORT_INFO]'||SQLERRM;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_buf);
 	 RETURN;
END get_cohort_info ;
--------------------------------------------------------------------------------
-- Get program segments, for all fund values of the given treasury_symbol, from
-- the prc table.
-- Save the fund values, segment names and prc flag in a table for later use.

PROCEDURE load_program_seg
IS

l_module_name VARCHAR2(200);

CURSOR fund_cur IS
     SELECT fund_value,
            DECODE(fund_category,'S','A','T','B',fund_category) fund_category
     FROM   fv_fund_parameters ffp
     WHERE  ffp.treasury_symbol_id = g_treasury_symbol_id
     AND    ffp.set_of_books_id = g_set_of_books_id
     AND    ffp.fund_category IN ('A', 'B', 'S', 'T');

vl_prg_seg    fv_facts_prc_hdr.program_segment%TYPE;
vl_prc_flag   fv_facts_prc_hdr.prc_mapping_flag%TYPE;
vl_prc_header_id   NUMBER;
vl_status	VARCHAR2(10);
l_code_type VARCHAR2(1);

BEGIN

l_module_name := g_module_name || 'load_program_seg';
  g_funds_count := 0;

   FOR fund_rec IN fund_cur
    LOOP

    FOR Type in 1..2
    LOOP
     If Type = 1 THEN
        l_code_type := 'B';
     ELSE
       l_code_type := 'N';
     END IF;
       vl_status := 'PASS';
      LOOP

       vl_prg_seg := NULL;
       vl_prc_flag := NULL;
       vl_prc_header_id := NULL;

       BEGIN
        SELECT program_segment,
               prc_mapping_flag, prc_header_id
        INTO   vl_prg_seg, vl_prc_flag, vl_prc_header_id
        FROM   fv_facts_prc_hdr ffh
        WHERE  ffh.treasury_symbol_id = g_treasury_symbol_id
        AND    ffh.set_of_books_id = g_set_of_books_id
        AND    ffh.code_type = l_code_type
        AND    ffh.fund_value = fund_rec.fund_value;
        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
       END;

        IF vl_prg_seg IS NOT NULL THEN EXIT; END IF;

        BEGIN
          SELECT program_segment,
                 prc_mapping_flag, prc_header_id
          INTO   vl_prg_seg, vl_prc_flag, vl_prc_header_id
          FROM   fv_facts_prc_hdr ffh
          WHERE  ffh.treasury_symbol_id = g_treasury_symbol_id
          AND    ffh.set_of_books_id = g_set_of_books_id
          AND    ffh.code_type = l_code_type
          AND    ffh.fund_value = 'ALL-A'
          AND    fund_rec.fund_category = 'A';
        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;

        IF vl_prg_seg IS NOT NULL THEN EXIT; END IF;

        BEGIN
          SELECT program_segment,
                 prc_mapping_flag, prc_header_id
          INTO   vl_prg_seg, vl_prc_flag, vl_prc_header_id
          FROM   fv_facts_prc_hdr ffh
          WHERE  ffh.treasury_symbol_id = g_treasury_symbol_id
          AND    ffh.set_of_books_id = g_set_of_books_id
          AND    ffh.code_type = l_code_type
          AND    ffh.fund_value = 'ALL-B'
          AND    fund_rec.fund_category = 'B';
        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;

        IF vl_prg_seg IS NOT NULL THEN EXIT; END IF;

        BEGIN
          SELECT program_segment,
                 prc_mapping_flag, prc_header_id
          INTO   vl_prg_seg, vl_prc_flag, vl_prc_header_id
          FROM   fv_facts_prc_hdr ffh
          WHERE  ffh.treasury_symbol_id = g_treasury_symbol_id
          AND    ffh.set_of_books_id = g_set_of_books_id
          AND    ffh.code_type = l_code_type
          AND    ffh.fund_value = 'ALL-FUNDS';
        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;

        IF vl_prg_seg IS NOT NULL THEN EXIT; END IF;

        BEGIN
          SELECT program_segment,
                 prc_mapping_flag, prc_header_id
          INTO   vl_prg_seg, vl_prc_flag, vl_prc_header_id
          FROM   fv_facts_prc_hdr ffh
          WHERE  ffh.treasury_symbol_id = -1
          AND    ffh.set_of_books_id = g_set_of_books_id
          AND    ffh.code_type = l_code_type
          AND    ffh.fund_value = 'ALL-A'
          AND    fund_rec.fund_category = 'A';
        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;

        IF vl_prg_seg IS NOT NULL THEN EXIT; END IF;

        BEGIN
          SELECT program_segment,
                 prc_mapping_flag, prc_header_id
          INTO   vl_prg_seg, vl_prc_flag, vl_prc_header_id
          FROM   fv_facts_prc_hdr ffh
          WHERE  ffh.treasury_symbol_id = -1
          AND    ffh.set_of_books_id = g_set_of_books_id
          AND    ffh.code_type = l_code_type
          AND    ffh.fund_value = 'ALL-B'
          AND    fund_rec.fund_category = 'B';
        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;

        IF vl_prg_seg IS NOT NULL THEN EXIT; END IF;

        BEGIN
          SELECT program_segment,
                 prc_mapping_flag, prc_header_id
          INTO   vl_prg_seg, vl_prc_flag, vl_prc_header_id
          FROM   fv_facts_prc_hdr ffh
          WHERE  ffh.treasury_symbol_id = -1
          AND    ffh.set_of_books_id = g_set_of_books_id
          AND    ffh.code_type = l_code_type
          AND    ffh.fund_value = 'ALL-FUNDS';
        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;

        IF vl_prg_seg IS NOT NULL THEN EXIT; END IF;

        vl_status := 'FAIL';
        EXIT;

      END LOOP;


      IF vl_status <> 'FAIL' THEN

      	 g_funds_count := g_funds_count + 1;

     	  g_segs_array(g_funds_count).fund_value := fund_rec.fund_value;
          g_segs_array(g_funds_count).segment := vl_prg_seg;
          g_segs_array(g_funds_count).prc_flag := vl_prc_flag;
          g_segs_array(g_funds_count).prc_header_id := vl_prc_header_id;
          g_segs_array(g_funds_count).code_type := l_code_type;
      END IF;

    END LOOP;
    END LOOP;
 EXCEPTION
    WHEN OTHERS THEN
      g_error_buf := SQLERRM;
      g_error_code := -1;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
          l_module_name||'.final_exception',g_error_buf);

END load_program_seg;
--------------------------------------------------------------------------------
PROCEDURE get_prc_val(p_ccid IN NUMBER,
                      p_fund_value IN VARCHAR2,
                      p_catb_val OUT NOCOPY VARCHAR2,
                      p_catb_desc OUT NOCOPY VARCHAR2,
                      p_prn_val OUT NOCOPY VARCHAR2,
                      p_prn_desc OUT NOCOPY VARCHAR2)

IS

l_module_name VARCHAR2(200);

vl_prc_found    VARCHAR2(1);
vl_prg_seg_name VARCHAR2(10);
vl_prc_flag     VARCHAR2(1);
vl_prc_header_id NUMBER;
vl_program_sel   VARCHAR2(150);
vl_program_value VARCHAR2(25);
vl_prg_value_set_id VARCHAR2(25);
--vl_code_type  VARCHAR2(1);
vl_prc_val VARCHAR2(5);
vl_prc_desc VARCHAR2(100);
BEGIN
l_module_name := g_module_name || 'get_prc_val';
vl_prc_found  := 'N';

  -- If fund value is found in the pl/sql table, then get
  -- the segment name, prc flag and header id.
  FOR i IN 1..g_funds_count
   LOOP
     vl_prc_found := 'N';
     IF g_segs_array(i).fund_value = p_fund_value THEN
      IF g_segs_array(i).code_type = 'B' THEN
        vl_prg_seg_name :=  g_segs_array(i).segment;
        vl_prc_flag := g_segs_array(i).prc_flag;
        vl_prc_header_id := g_segs_array(i).prc_header_id;
      ELSIF g_segs_array(i).code_type = 'N' THEN
        vl_prg_seg_name :=  g_segs_array(i).segment;
        vl_prc_flag := g_segs_array(i).prc_flag;
        vl_prc_header_id := g_segs_array(i).prc_header_id;
     END IF;


   IF vl_prg_seg_name is NOT NULL THEN

   -- If program segment name is found in the pl/sql table, then
   -- get the program segment value using the ccid
   vl_program_sel := 'SELECT gcc.'||vl_prg_seg_name||
               ' FROM  gl_code_combinations gcc
                 WHERE  gcc.code_combination_id = '||p_ccid;

   EXECUTE IMMEDIATE vl_program_sel INTO vl_program_value;

   -- IF prc flag is Y, get the program reporting code and
   -- program description from the prc mapping form(prc tables).
   IF vl_prc_flag = 'Y' THEN

      BEGIN

          SELECT reporting_code, reporting_desc
          INTO   vl_prc_val, vl_prc_desc
          FROM   fv_facts_prc_dtl
          WHERE  prc_header_id = vl_prc_header_id
          AND    program_value = vl_program_value
          AND    set_of_books_id = g_set_of_books_id;

          vl_prc_found := 'Y';

       EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
      END;

      IF vl_prc_found = 'N' THEN
          BEGIN

            SELECT reporting_code, reporting_desc
            INTO   vl_prc_val, vl_prc_desc
            FROM   fv_facts_prc_dtl
            WHERE  prc_header_id = vl_prc_header_id
            AND    program_value = 'ALL'
            AND    set_of_books_id = g_set_of_books_id;

            vl_prc_found := 'Y';

           EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
          END;
      END IF;
   END IF;
END IF;



 --   IF the prc flag is N
 --   get the program reporting code and description from
 --   the segment value.

   IF vl_prc_flag = 'N' THEN

      -- Get the program value set id
    SELECT flex_value_set_id
      INTO   vl_prg_value_set_id
      FROM   fnd_id_flex_segments
      WHERE  application_column_name = vl_prg_seg_name
      AND    application_id     = 101
      AND    id_flex_code  = 'GL#'
      AND    id_flex_num   = g_coa_id ;

      -- Get the program value description
      SELECT SUBSTR(description, 1, 25)
      INTO   vl_prc_desc
      FROM   fnd_flex_values_tl ffvt,fnd_flex_values ffv
      WHERE  ffvt.flex_value_id = ffv.flex_value_id
      AND    ffv.flex_value_set_id = vl_prg_value_set_id
      AND    ffv.flex_value = vl_program_value
      AND    ffvt.language = userenv('LANG');

      vl_prc_val := LPAD(TO_CHAR(TO_NUMBER(vl_program_value)),3,'0');


   ELSIF vl_prc_flag = 'Y' AND vl_prc_found = 'N' THEN

         vl_prc_val := NULL;
         vl_prc_desc := NULL;

      IF  g_segs_array(i).code_type = 'N' THEN
         vl_prc_val := '099';
         vl_prc_desc := 'PRC not Assigned';
      END IF;

   END IF;

      IF vl_prc_val IS NOT NULL THEN
         vl_prc_val := LPAD(TO_CHAR(TO_NUMBER(vl_prc_val)),3,'0');
      END IF;

             IF g_segs_array(i).code_type = 'B' THEN
               IF g_appor_cat_val = 'A' THEN
                  --p_catb_val := '000';
                 p_catb_desc := 'Default Cat B Code';
               ELSIF g_appor_cat_val = 'B' THEN
                 p_catb_val := vl_prc_val;
                 p_catb_desc := vl_prc_desc;
               END IF ;
              ELSE
               p_prn_val := vl_prc_val;
               p_prn_desc := vl_prc_desc;
             END IF;
    END IF;

 END LOOP;
          IF g_appor_cat_val = 'A' THEN
                 --p_catb_val := '000';
                 p_catb_desc := 'Default Cat B Code';

         END IF;
 EXCEPTION
    WHEN OTHERS THEN
      g_error_buf := SQLERRM;
      g_error_code := -1;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
          l_module_name||'.final_exception',g_error_buf);
      RAISE;

END get_prc_val;
--------------------------------------------------------------------------------
PROCEDURE group_po_rec_lines IS
l_module_name VARCHAR2(200);
l_select      VARCHAR2(32767);
l_var1 VARCHAR2(50);
l_var2 VARCHAR2(50);

    CURSOR merge_po_recpt IS

    SELECT    document_number,
          min(transaction_date)  transaction_date  ,
          min(creation_date_time)   creation_date_time ,
          min(journal_creation_date) journal_creation_date   ,
    			min(journal_modified_date) journal_modified_date   ,
    			min(gl_date)    gl_date              ,
          min(gl_posted_date) gl_posted_date,
          min(sla_hdr_event_id) sla_hdr_event_id,
          min(sla_hdr_creation_date) sla_hdr_creation_date,
          min(sla_entity_id) sla_entity_id
         FROM fv_facts_trx_temp
         WHERE document_source = 'Purchasing'
         AND document_category = 'Receiving'
        GROUP BY document_number;

BEGIN
  l_module_name := g_module_name || 'group_po_rec_lines';

   --Added for bug 7253838
   --For PO receipts merge events having the
   --same receipt number
   FOR pur_recpt IN merge_po_recpt LOOP
       UPDATE fv_facts_trx_temp
       SET    transaction_date = pur_recpt.transaction_date,
                 creation_date_time = pur_recpt.creation_date_time,
                 journal_creation_date = pur_recpt.journal_creation_date,
                 journal_modified_date = pur_recpt.journal_modified_date,
                 gl_date = pur_recpt.gl_date,
                 gl_posted_date = pur_recpt.gl_posted_date,
                 sla_hdr_event_id = pur_recpt.sla_hdr_event_id,
                 sla_hdr_creation_date = pur_recpt.sla_hdr_creation_date,
                 sla_entity_id = pur_recpt.sla_entity_id
        WHERE document_source = 'Purchasing'
        AND   document_category = 'Receiving'
        AND   document_number = pur_recpt.document_number;
    END LOOP;

  /* --Solution modified as above
  INSERT INTO fv_facts_trx_temp (
      treasury_symbol_id   	 ,
			set_of_books_id 	 ,
 			code_combination_id      ,
 			fund_value               ,
 			account_number		 ,
 			document_source 	 ,
 			document_category        ,
 			document_number	 	 ,
 			transaction_date 	 ,
 			creation_date_time 	 ,
 			entry_user      	 ,
 			fed_non_fed   		 ,
 			trading_partner		 ,
 			exch_non_exch   	 ,
 			cust_non_cust     	 ,
 			budget_subfunction  	 ,
 			debit              	 ,
 			credit             	 ,
 			transfer_dept_id   	 ,
 			transfer_main_acct 	 ,
 			year_budget_auth   	 ,
 			budget_function    	 ,
 			advance_flag        	 ,
 			cohort             	 ,
 			begin_end          	 ,
 			indef_def_flag     	 ,
 			appor_cat_b_dtl 	 ,
 			appor_cat_b_txt 	 ,
      PROGRAM_RPT_CAT_NUM      ,
      PROGRAM_RPT_CAT_TXT      ,
 			public_law        	 ,
 			appor_cat_code   	 ,
 			authority_type    	 ,
 			transaction_partner 	 ,
 			reimburseable_flag       ,
 			bea_category             ,
 			borrowing_source         ,
 			def_liquid_flag          ,
 			deficiency_flag          ,
 			availability_flag        ,
 			legislation_flag         ,
      journal_creation_date    ,
			journal_modified_date    ,
			period_name              ,
			gl_date                  ,
      gl_posted_date,
      reversal_flag ,
      sla_hdr_event_id,
      sla_hdr_creation_date,
      sla_entity_id, period_activity 	 )
  SELECT
      treasury_symbol_id   	 ,
			set_of_books_id 	 ,
 			code_combination_id      ,
 			fund_value               ,
 			account_number		 ,
 			document_source 	 ,
 			document_category        ,
 			document_number	 	 ,
 			min(transaction_date) 	 ,
 			min(creation_date_time) 	 ,
 			entry_user      	 ,
 			fed_non_fed   		 ,
 			trading_partner		 ,
 			exch_non_exch   	 ,
 			cust_non_cust     	 ,
 			budget_subfunction  	 ,
 			sum(debit)              	 ,
 			sum(credit)             	 ,
 			transfer_dept_id   	 ,
 			transfer_main_acct 	 ,
 			year_budget_auth   	 ,
 			budget_function    	 ,
 			advance_flag        	 ,
 			cohort             	 ,
 			begin_end          	 ,
 			indef_def_flag     	 ,
 			appor_cat_b_dtl 	 ,
 			appor_cat_b_txt 	 ,
      PROGRAM_RPT_CAT_NUM      ,
      PROGRAM_RPT_CAT_TXT      ,
 			public_law        	 ,
 			appor_cat_code   	 ,
 			authority_type    	 ,
 			transaction_partner 	 ,
 			reimburseable_flag       ,
 			bea_category             ,
 			borrowing_source         ,
 			def_liquid_flag          ,
 			deficiency_flag          ,
 			availability_flag        ,
 			legislation_flag         ,
      min(journal_creation_date)    ,
			min(journal_modified_date)    ,
			period_name              ,
			min(gl_date)                  ,
      min(gl_posted_date),
      reversal_flag ,
      min(sla_hdr_event_id),
      min(sla_hdr_creation_date),
      min(sla_entity_id),
      -9999
  FROM fv_facts_trx_temp
  WHERE document_source = 'Purchasing'
  AND document_category = 'Receiving'
  GROUP BY treasury_symbol_id   	 ,
			set_of_books_id 	 ,
 			code_combination_id      ,
 			fund_value               ,
 			account_number		 ,
 			document_source 	 ,
 			document_category        ,
 			document_number	 	 ,
 			entry_user      	 ,
 			fed_non_fed   		 ,
 			trading_partner		 ,
 			exch_non_exch   	 ,
 			cust_non_cust     	 ,
 			budget_subfunction  	 ,
 			transfer_dept_id   	 ,
 			transfer_main_acct 	 ,
 			year_budget_auth   	 ,
 			budget_function    	 ,
 			advance_flag        	 ,
 			cohort             	 ,
 			begin_end          	 ,
 			indef_def_flag     	 ,
 			appor_cat_b_dtl 	 ,
 			appor_cat_b_txt 	 ,
      PROGRAM_RPT_CAT_NUM      ,
      PROGRAM_RPT_CAT_TXT      ,
 			public_law        	 ,
 			appor_cat_code   	 ,
 			authority_type    	 ,
 			transaction_partner 	 ,
 			reimburseable_flag       ,
 			bea_category             ,
 			borrowing_source         ,
 			def_liquid_flag          ,
 			deficiency_flag          ,
 			availability_flag        ,
 			legislation_flag         ,
			period_name              ,
      reversal_flag ,
      -9999                    ;

   DELETE FROM fv_facts_trx_temp
   WHERE document_source = 'Purchasing'
   AND document_category = 'Receiving'
   AND nvl(period_activity,-3333) <> -9999;

   UPDATE fv_facts_trx_temp
   SET period_activity =  null
   WHERE period_activity = -9999;
   */
   --To create separate records for debit and credit amounts
   --We are doing this only for sources other than Receivables and
   --category other than Receipts
   FOR i in 1..2 LOOP

     IF i = 1 THEN
        l_var1 := ' sum(debit) , 0 ';
        l_var2 := ' debit ';
       ELSE
        l_var1 := ' 0, sum(credit) ';
        l_var2 := ' credit ';
     END IF;

     l_select :=
     ' insert into fv_facts_trx_temp (
      treasury_symbol_id   	 ,
			set_of_books_id 	 ,
 			code_combination_id      ,
 			fund_value               ,
 			account_number		 ,
 			document_source 	 ,
 			document_category        ,
 			document_number	 	 ,
 			transaction_date 	 ,
 			creation_date_time 	 ,
 			entry_user      	 ,
 			fed_non_fed   		 ,
 			trading_partner		 ,
 			exch_non_exch   	 ,
 			cust_non_cust     	 ,
 			budget_subfunction  	 ,
 			debit              	 ,
 			credit             	 ,
 			transfer_dept_id   	 ,
 			transfer_main_acct 	 ,
 			year_budget_auth   	 ,
 			budget_function    	 ,
 			advance_flag        	 ,
 			cohort             	 ,
 			begin_end          	 ,
 			indef_def_flag     	 ,
 			appor_cat_b_dtl 	 ,
 			appor_cat_b_txt 	 ,
      PROGRAM_RPT_CAT_NUM      ,
      PROGRAM_RPT_CAT_TXT      ,
 			public_law        	 ,
 			appor_cat_code   	 ,
 			authority_type    	 ,
 			transaction_partner 	 ,
 			reimburseable_flag       ,
 			bea_category             ,
 			borrowing_source         ,
 			def_liquid_flag          ,
 			deficiency_flag          ,
 			availability_flag        ,
 			legislation_flag         ,
      pya_flag                 ,
      journal_creation_date    ,
			journal_modified_date    ,
			period_name              ,
			gl_date                  ,
      gl_posted_date,
      reversal_flag ,
      sla_hdr_event_id,
      sla_hdr_creation_date,
      sla_entity_id, period_activity 	 )

      SELECT
      treasury_symbol_id   	 ,
			set_of_books_id 	 ,
 			code_combination_id      ,
 			fund_value               ,
 			account_number		 ,
 			document_source 	 ,
 			document_category        ,
 			document_number	 	 ,
 			transaction_date 	 ,
 			creation_date_time 	 ,
 			entry_user      	 ,
 			fed_non_fed   		 ,
 			trading_partner		 ,
 			exch_non_exch   	 ,
 			cust_non_cust     	 ,
 			budget_subfunction  	 , '||
 			l_var1 ||' ,
 			transfer_dept_id   	 ,
 			transfer_main_acct 	 ,
 			year_budget_auth   	 ,
 			budget_function    	 ,
 			advance_flag        	 ,
 			cohort             	 ,
 			begin_end          	 ,
 			indef_def_flag     	 ,
 			appor_cat_b_dtl 	 ,
 			appor_cat_b_txt 	 ,
      PROGRAM_RPT_CAT_NUM      ,
      PROGRAM_RPT_CAT_TXT      ,
 			public_law        	 ,
 			appor_cat_code   	 ,
 			authority_type    	 ,
 			transaction_partner 	 ,
 			reimburseable_flag       ,
 			bea_category             ,
 			borrowing_source         ,
 			def_liquid_flag          ,
 			deficiency_flag          ,
 			availability_flag        ,
 			legislation_flag         ,
      pya_flag                      ,
      journal_creation_date    ,
			journal_modified_date    ,
			period_name              ,
			gl_date                  ,
      gl_posted_date,
      reversal_flag ,
      sla_hdr_event_id,
      sla_hdr_creation_date,
      sla_entity_id,
      -1111
  FROM fv_facts_trx_temp
  WHERE '||l_var2 || '  <> 0
  and --(document_source <> ''Receivables'' and
       document_category <> ''Trade Receipts''
  GROUP BY treasury_symbol_id      ,
      set_of_books_id    ,
       code_combination_id      ,
       fund_value               ,
       account_number     ,
       document_source    ,
       document_category        ,
       document_number      ,
       entry_user         ,
       fed_non_fed        ,
       trading_partner     ,
       exch_non_exch      ,
       cust_non_cust        ,
       budget_subfunction     ,
       transfer_dept_id      ,
       transfer_main_acct    ,
       year_budget_auth      ,
       budget_function       ,
       advance_flag           ,
       cohort                ,
       begin_end             ,
       indef_def_flag        ,
       appor_cat_b_dtl    ,
       appor_cat_b_txt    ,
      PROGRAM_RPT_CAT_NUM      ,
      PROGRAM_RPT_CAT_TXT      ,
       public_law           ,
       appor_cat_code      ,
       authority_type       ,
       transaction_partner    ,
       reimburseable_flag       ,
       bea_category             ,
       borrowing_source         ,
       def_liquid_flag          ,
       deficiency_flag          ,
       availability_flag        ,
       legislation_flag         ,
       pya_flag                 ,
      period_name              ,
      reversal_flag ,
      -1111                    ,
      transaction_date 	 ,
 			creation_date_time 	 ,			gl_date                  ,
      gl_posted_date,      journal_creation_date    ,
			journal_modified_date,      sla_hdr_event_id,
      sla_hdr_creation_date,
      sla_entity_id ';

      fv_utility.log_mesg('l_var1: '||l_var1);
      fv_utility.log_mesg('l_var2: '||l_var2);

      EXECUTE IMMEDIATE l_select;

  END LOOP;

      -- update with -1111 so that the rows
      -- are retained for reporting
      UPDATE fv_facts_trx_temp
      SET     period_activity = -1111
      WHERE  --document_source  = 'Receivables'
      --AND
      document_category = 'Trade Receipts';

      -- Delete the grouped rows and retain
      -- rows required for the report
      DELETE FROM fv_facts_trx_temp
      WHERE NVL(period_activity, -0000) <> -1111;
    EXCEPTION
    WHEN OTHERS THEN
      g_error_buf := SQLERRM;
      g_error_code := -1;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
          l_module_name||'.final_exception',g_error_buf);
END group_po_rec_lines ;
--------------------------------------------------------------------------------
PROCEDURE get_trx_part_from_reimb
                  (p_reimb_agree_seg_val IN VARCHAR2) IS

l_module_name VARCHAR2(200) := g_module_name || 'get_trx_part_from_reimb';
l_cust_class_code VARCHAR2(25);
BEGIN
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
          'BEGIN '||l_module_name);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
           'p_reimb_agree_seg_val:'||p_reimb_agree_seg_val);
   END IF;
   SELECT hzca.customer_class_code
   INTO   l_cust_class_code
   FROM   ra_customer_trx_all rct,
          hz_cust_accounts_all hzca
   WHERE  rct.trx_number =  p_reimb_agree_seg_val
   AND    rct.set_of_books_id = g_set_of_books_id
   AND    hzca.cust_account_id = rct.bill_to_customer_id;

   IF l_cust_class_code = 'FEDERAL' THEN
      g_transaction_partner_val := 'F';
     ELSIF l_cust_class_code <> 'FEDERAL' THEN
      g_transaction_partner_val := 'X';
   END IF;

   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
     'g_transaction_partner_val:'||g_transaction_partner_val);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
     'END '||l_module_name);
   END IF;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
       fv_utility.log_mesg
           ('No record found for trx number: '||p_reimb_agree_seg_val);
    WHEN OTHERS THEN
      g_error_buf := SQLERRM;
      g_error_code := -1;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
          l_module_name||'.final_exception',g_error_buf);
END get_trx_part_from_reimb;
--------------------------------------------------------------------------------
PROCEDURE get_fnf_from_reimb
                  (p_reimb_agree_seg_val IN VARCHAR2) IS

l_module_name VARCHAR2(200) := g_module_name || 'get_fnf_from_reimb';
l_cust_class_code VARCHAR2(25);
BEGIN
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
          'BEGIN '||l_module_name);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
           'p_reimb_agree_seg_val:'||p_reimb_agree_seg_val);
   END IF;
   SELECT hzca.customer_class_code
   INTO   l_cust_class_code
   FROM   ra_customer_trx_all rct,
          hz_cust_accounts_all hzca
   WHERE  rct.trx_number =  p_reimb_agree_seg_val
   AND    rct.set_of_books_id = g_set_of_books_id
   AND    hzca.cust_account_id = rct.bill_to_customer_id;

   IF l_cust_class_code = 'FEDERAL' THEN
      g_govt_non_govt_val := 'F';
     ELSIF l_cust_class_code <> 'FEDERAL' THEN
      g_govt_non_govt_val := 'N';
   END IF;

   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
     'g_transaction_partner_val:'||g_transaction_partner_val);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
     'END '||l_module_name);
   END IF;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
       fv_utility.log_mesg
           ('No record found for trx number: '||p_reimb_agree_seg_val);
       fv_utility.log_mesg('Setting fnf to N.');
       g_govt_non_govt_val := 'N';
    WHEN OTHERS THEN
      g_error_buf := SQLERRM;
      g_error_code := -1;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
          l_module_name||'.final_exception',g_error_buf);
END get_fnf_from_reimb;
--------------------------------------------------------------------------------
PROCEDURE group_payables_lines IS

l_module_name VARCHAR2(100) := g_module_name||'group_payables_lines.';

BEGIN
  --Group payables lines so that any duplicate lines
  --with different credit and debit amounts are
  --reported on one line with net amount
  INSERT INTO fv_facts_trx_temp (
      treasury_symbol_id      ,
      set_of_books_id    ,
       code_combination_id      ,
       fund_value               ,
       account_number     ,
       document_source    ,
       document_category        ,
       document_number      ,
       transaction_date    ,
       creation_date_time    ,
       entry_user         ,
       fed_non_fed        ,
       trading_partner     ,
       exch_non_exch      ,
       cust_non_cust        ,
       budget_subfunction     ,
       debit                 ,
       credit                ,
       transfer_dept_id      ,
       transfer_main_acct    ,
       year_budget_auth      ,
       budget_function       ,
       advance_flag           ,
       cohort                ,
       begin_end             ,
       indef_def_flag        ,
       appor_cat_b_dtl    ,
       appor_cat_b_txt    ,
      PROGRAM_RPT_CAT_NUM      ,
      PROGRAM_RPT_CAT_TXT      ,
       public_law           ,
       appor_cat_code      ,
       authority_type       ,
       transaction_partner    ,
       reimburseable_flag       ,
       bea_category             ,
       borrowing_source         ,
       def_liquid_flag          ,
       deficiency_flag          ,
       availability_flag        ,
       legislation_flag         ,
       pya_flag                   ,
      journal_creation_date    ,
      journal_modified_date    ,
      period_name              ,
      gl_date                  ,
      gl_posted_date,
      reversal_flag ,
      sla_hdr_event_id,
      sla_hdr_creation_date,
      sla_entity_id, period_activity    )
select
treasury_symbol_id      ,
      set_of_books_id    ,
       code_combination_id      ,
       fund_value               ,
       account_number     ,
       document_source    ,
       document_category        ,
       document_number      ,
       (transaction_date)    ,
       (creation_date_time)    ,
       entry_user         ,
       fed_non_fed        ,
       trading_partner     ,
       exch_non_exch      ,
       cust_non_cust        ,
       budget_subfunction     ,
(case when (debit-credit) >= 0 then (debit-credit) else 0 end) debit,
(case when (debit-credit) < 0 then abs(debit-credit) else 0 end) credit,
       transfer_dept_id      ,
       transfer_main_acct    ,
       year_budget_auth      ,
       budget_function       ,
       advance_flag           ,
       cohort                ,
       begin_end             ,
       indef_def_flag        ,
       appor_cat_b_dtl    ,
       appor_cat_b_txt    ,
      PROGRAM_RPT_CAT_NUM      ,
      PROGRAM_RPT_CAT_TXT      ,
       public_law           ,
       appor_cat_code      ,
       authority_type       ,
       transaction_partner    ,
       reimburseable_flag       ,
       bea_category             ,
       borrowing_source         ,
       def_liquid_flag          ,
       deficiency_flag          ,
       availability_flag        ,
       legislation_flag         ,
       pya_flag                 ,
      (journal_creation_date)    ,
      (journal_modified_date)    ,
      period_name              ,
      (gl_date)                  ,
      (gl_posted_date),
      reversal_flag ,
      (sla_hdr_event_id),
      (sla_hdr_creation_date),
      (sla_entity_id) ,
      -8888
 from (
SELECT
      treasury_symbol_id,
      set_of_books_id 	 ,
 			code_combination_id      ,
 			fund_value               ,
 			account_number		 ,
 			document_source 	 ,
 			document_category        ,
 			document_number	 	 ,
 			(transaction_date) 	 ,
 			(creation_date_time) 	 ,
 			entry_user      	 ,
 			fed_non_fed   		 ,
 			trading_partner		 ,
 			exch_non_exch   	 ,
 			cust_non_cust     	 ,
 			budget_subfunction  	 ,
 			sum(debit) debit,
      sum(credit) credit    ,
 			transfer_dept_id   	 ,
 			transfer_main_acct 	 ,
 			year_budget_auth   	 ,
 			budget_function    	 ,
 			advance_flag        	 ,
 			cohort             	 ,
 			begin_end          	 ,
 			indef_def_flag     	 ,
 			appor_cat_b_dtl 	 ,
       appor_cat_b_txt    ,
      PROGRAM_RPT_CAT_NUM      ,
      PROGRAM_RPT_CAT_TXT      ,
       public_law           ,
       appor_cat_code      ,
       authority_type       ,
       transaction_partner    ,
       reimburseable_flag       ,
       bea_category             ,
       borrowing_source         ,
       def_liquid_flag          ,
       deficiency_flag          ,
       availability_flag        ,
       legislation_flag         ,
       pya_flag                 ,
      (journal_creation_date)    ,
      (journal_modified_date)    ,
      period_name              ,
      (gl_date)                  ,
      (gl_posted_date),
      reversal_flag ,
      (sla_hdr_event_id),
      (sla_hdr_creation_date),
      (sla_entity_id)
  FROM fv_facts_trx_temp
  WHERE document_source = 'Payables'
  AND document_category = 'Purchase Invoices'
  GROUP BY treasury_symbol_id      ,
      set_of_books_id    ,
       code_combination_id      ,
       fund_value               ,
       account_number     ,
       document_source    ,
       document_category        ,
       document_number      ,
       entry_user         ,
       fed_non_fed        ,
       trading_partner     ,
       exch_non_exch      ,
       cust_non_cust        ,
       budget_subfunction     ,
       transfer_dept_id      ,
       transfer_main_acct    ,
       year_budget_auth      ,
       budget_function       ,
       advance_flag           ,
       cohort                ,
       begin_end             ,
       indef_def_flag        ,
       appor_cat_b_dtl    ,
       appor_cat_b_txt    ,
      PROGRAM_RPT_CAT_NUM      ,
      PROGRAM_RPT_CAT_TXT      ,
       public_law           ,
       appor_cat_code      ,
       authority_type       ,
       transaction_partner    ,
       reimburseable_flag       ,
       bea_category             ,
       borrowing_source         ,
       def_liquid_flag          ,
       deficiency_flag          ,
       availability_flag        ,
       legislation_flag         ,
       pya_flag                 ,
      period_name              ,
      reversal_flag ,
      transaction_date 	 ,
 			creation_date_time 	 ,
      journal_creation_date    ,
      journal_modified_date   ,
      gl_date                  ,
      gl_posted_date ,
      sla_hdr_event_id,
      sla_hdr_creation_date,
      sla_entity_id
      );

      DELETE from fv_facts_trx_temp
      WHERE document_source = 'Payables'
      AND document_category = 'Purchase Invoices'
      and period_activity <> -8888;

    EXCEPTION
    WHEN OTHERS THEN
      g_error_buf := SQLERRM;
      g_error_code := -1;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
          l_module_name||'.final_exception',g_error_buf);
END;
--------------------------------------------------------------------------------

BEGIN
  g_module_name  := 'fv.plsql.FV_FACTS_TRANSACTIONS.';
  g_apps_id      := 101;
  g_id_flex_code := 'GL#';
END fv_facts_trx_register;

/
