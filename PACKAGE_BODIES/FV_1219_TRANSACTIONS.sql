--------------------------------------------------------
--  DDL for Package Body FV_1219_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_1219_TRANSACTIONS" as
/* $Header: FVX1219B.pls 120.29.12010000.1 2008/07/28 06:32:28 appldev ship $ */
  g_module_name VARCHAR2(100) := 'fv.plsql.fv_1219_transactions.';

	flex_num		number;
	period_type		varchar2(25) := NULL;
	bl_seg_name		varchar2(40);
	gl_seg_name		varchar2(40);
	transaction_count	number	:= 0;
	p_set_bks_id 		number;
	p_gl_period		varchar2(25);
	p_alc_code		ce_bank_accounts.agency_location_code%TYPE;
	p_delete_corrections	varchar2(1);
	p_error_code		number;
	p_error_msg		varchar2(150);

	l_start_date1		GL_PERIODS.start_date%TYPE;
	l_end_date1		GL_PERIODS.end_date%TYPE;
	l_gl_period		GL_PERIODS.period_name%TYPE;
	l_start_date2		GL_PERIODS.start_date%TYPE;
	l_end_date2		GL_PERIODS.end_date%TYPE;
	l_period_year		GL_PERIODS.period_year%TYPE;

	l_rowid			varchar2(25);

	l_fund_code 		FV_SF1219_TEMP.fund_code%TYPE;
	l_name	 		FV_SF1219_TEMP.name%TYPE;
	l_name_keep 		FV_SF1219_TEMP.name%TYPE;
	l_set_of_books_id 	FV_SF1219_TEMP.set_of_books_id%TYPE;
	l_sf1219_type_code	FV_SF1219_TEMP.sf1219_type_code%TYPE;
	l_reported_month	FV_SF1219_TEMP.reported_month%TYPE;
	l_posted_date 		FV_SF1219_TEMP.posted_date%TYPE;
	l_reported_gl_period	FV_SF1219_TEMP.reported_gl_period%TYPE;
	l_amount		FV_SF1219_TEMP.amount%TYPE;
	l_batch_id		FV_SF1219_TEMP.batch_id%TYPE;

	l_je_header_id		gl_je_headers.je_header_id%TYPE;
	l_je_line_num		gl_je_lines.je_line_num%TYPE;
	l_currency_code		gl_ledgers_public_v.currency_code%TYPE;

	l_reference_1		FV_SF1219_TEMP.reference_1%TYPE;
	l_reference_2		FV_SF1219_TEMP.reference_2%TYPE;
	l_reference_3		FV_SF1219_TEMP.reference_3%TYPE;
	l_reference_4		FV_SF1219_TEMP.reference_4%TYPE;
	l_reference_5		FV_SF1219_TEMP.reference_5%TYPE;
	l_reference_6		FV_SF1219_TEMP.reference_6%TYPE;
	l_reference_9		FV_SF1219_TEMP.reference_9%TYPE;
	l_exception_category	FV_SF1219_TEMP.exception_category%TYPE;
	l_accomplish_month 	FV_SF1219_TEMP.accomplish_month%TYPE;
	l_default_period_name 	FV_SF1219_TEMP.default_period_name%TYPE;
	l_obligation_date	FV_SF1219_TEMP.obligation_date%TYPE;
	l_inter_agency_flag	FV_SF1219_TEMP.inter_agency_flag%TYPE;
	l_treasury_symbol	FV_SF1219_TEMP.treasury_symbol%TYPE;

	l_treasury_symbol_id	FV_SF1219_TEMP.treasury_symbol_id%TYPE;
	l_record_type		FV_SF1219_TEMP.record_type%TYPE;
	l_alc_code		FV_SF1219_TEMP.alc_code%TYPE;
	l_temp_alc_code		FV_SF1219_TEMP.alc_code%TYPE;
	l_org_id		FV_SF1219_TEMP.org_id%TYPE := mo_global.get_current_org_id;
	l_group_name		FV_SF1219_TEMP.group_name%TYPE;
	l_accomplish_date 	FV_SF1219_TEMP.accomplish_date%TYPE;
	l_ref6_date_check 	FV_SF1219_TEMP.accomplish_date%TYPE;
	l_update_type	 	FV_SF1219_TEMP.update_type%TYPE;
	l_type		 	FV_SF1219_TEMP.type%TYPE;
	l_gl_period_name 	FV_SF1219_TEMP.gl_period_name%TYPE;
	l_processed_flag 	FV_SF1219_TEMP.processed_flag%TYPE;
	l_lines_exist	 	FV_SF1219_TEMP.lines_exist%TYPE;

	l_invoice_id		AP_INVOICES_ALL.invoice_id%TYPE;
	l_vendor_id		AP_INVOICES_ALL.vendor_id%TYPE;
	l_payables_ia_paygroup	FV_OPERATING_UNITS_ALL.payables_ia_paygroup%TYPE;
	l_cb_flag	        FV_INTERAGENCY_FUNDS_ALL.chargeback_flag%TYPE;
	l_billing_agency_fund   FV_INTERAGENCY_FUNDS_ALL.billing_agency_fund%TYPE;
	l_dit_flag		varchar2(2);
	l_error_stage 		number;
	l_inv_amount		number;
	l_yr_start_date		date;
	l_yr_end_date		date;
	l_check_date		date;
	l_void_date		date;

	x_amount		number;
	l_cash_receipt_id	number;
	null_var		varchar2(2);
	l_invoice_date		date;
--	g_debug 		BOOLEAN := FALSE;

	l_cash_receipt_hist_id  NUMBER;
	l_temp_cr_hist_id       NUMBER;
	p_def_org_id        	NUMBER(15) := l_org_id;
        l_je_from_sla_flag      VARCHAR2(1);
        l_appl_reference        NUMBER;

CURSOR temp_cursor IS
	SELECT	rowid,
		batch_id,
		fund_code,
		name,
		posted_date,
		gl_period,
		amount,
		sf1219_type_code,
		reference_1,
		reference_2,
		reference_3,
		reference_4,
		reference_5,
		reference_6,
		reference_9,
		reported_month,
		exception_category,
		accomplish_month,
		accomplish_date,
		obligation_date,
		inter_agency_flag,
		treasury_symbol,
		treasury_symbol_id,
		record_type,
		lines_exist,
		alc_code,
		org_id,
		update_type,
		type,
		gl_period_name,
		processed_flag,
            	je_header_id,
            	je_line_num,
                NVL(je_from_sla_flag,'N')
	FROM	FV_SF1219_TEMP
	WHERE   record_type not in ('P', 'N')
	ORDER BY batch_id;

CURSOR refund_cursor IS
	SELECT obligation_date, refund_amount
	FROM  fv_refunds_voids_all
	WHERE cash_receipt_id = l_cash_receipt_id
	AND type = 'AP_REFUND'
	AND fund_value = l_fund_code
	AND org_id = p_def_org_id;

CURSOR	void_cursor IS
	SELECT 	name, gl_period, amount, sf1219_type_code,
		reference_2, reference_3,
		reported_month, accomplish_date,
		obligation_date, inter_agency_flag,
		record_type, lines_exist, alc_code
	FROM 	fv_sf1219_temp
	WHERE 	name = 'Check for Void';

PROCEDURE purge_temp_transactions;
PROCEDURE get_balance_account_segments;
PROCEDURE get_period_info;
PROCEDURE insert_batches;
PROCEDURE process_1219_transactions;
PROCEDURE set_exception_category;
PROCEDURE insert_exceptions(x_amount IN	NUMBER);
PROCEDURE assign_group_name;
PROCEDURE process_void_transactions;

/* PROCEDURE get_reference_column (p_entity_code IN VARCHAR2,
                                p_batch_id IN NUMBER,
                                p_je_header_id IN NUMBER,
                                p_je_line_num IN NUMBER,
                                p_reference  OUT  NOCOPY NUMBER,
                                p_appl_reference OUT NOCOPY NUMBER,
                                p_history_reference OUT NOCOPY NUMBER,
                                p_application_id IN NUMBER ); */

-----------------------------------------------------------------------------
--      		PROCEDURE MAIN
-----------------------------------------------------------------------------
-- This procedure is called from FMS Form 1219/1220 Process, a concurrent
-- program. This procedure calls all the subsequent procedures in the
-- 1219/1220 process.
----------------------------------------------------------------------------
PROCEDURE MAIN_1219(
		error_msg  	   OUT NOCOPY VARCHAR2,
		error_code	   OUT NOCOPY NUMBER,
		set_bks_id  	   IN NUMBER,
		gl_period 	   IN VARCHAR2,
		alc_code	   IN VARCHAR2,
		delete_corrections IN VARCHAR2)
IS
  l_module_name VARCHAR2(200) := g_module_name || 'MAIN_1219';
  v_alc_count NUMBER;
BEGIN


     p_set_bks_id  	:= set_bks_id;
     p_gl_period   	:= gl_period;
     p_alc_code	        := alc_code;
     p_delete_corrections := delete_corrections;
     p_error_code	:= 0;
     p_error_msg	:= '** FORM 1219 PROCESS COMPLETED SUCCESSFULLY **';

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                          'INPUT PARAMETERS: ');
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                          '  SET OF BOOKS ID: '||P_SET_BKS_ID);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                          '  GL PERIOD: '||P_GL_PERIOD);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                          '  ALC CODE : '||P_ALC_CODE);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                            '  DELETE CORRECTIONS: '||P_DELETE_CORRECTIONS);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'');
 END IF;

     -- Check whether alc_code has been defined for all records
     -- in the fv_1219_definitions_accts table.  If not, the abort process.
     SELECT COUNT(*)
     INTO   v_alc_count
     FROM   fv_sf1219_definitions_accts
     WHERE  agency_location_code IS NULL
     AND    set_of_books_id = p_set_bks_id;

     IF v_alc_count > 0
        THEN
          error_code := -1;
          error_msg  := 'Agency Location Code is not defined for all the '||
			'records FMS Form 1219/1220 Report Definitions. '||
                        'Please provide Agency Location Code '||
                        'for all records and re-submit the process.';
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
                                      l_module_name||'.error1',error_msg);
          RETURN;
     END IF;

     SELECT currency_code
     INTO   l_currency_code
     FROM   gl_ledgers_public_v
     WHERE  ledger_id = p_set_bks_id;

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                        '  CURRENCY CODE: '|| L_CURRENCY_CODE);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                              'PURGING TEMP TABLE ...');
     END IF;
     purge_temp_transactions;

     IF p_error_code = 0 THEN
	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                        'GETTING SEGMENT NAMES ...');
	END IF;
	get_balance_account_segments;
     ELSE
	error_code := p_error_code;
	error_msg  := p_error_msg;
	RETURN;
     END IF;

     IF p_error_code = 0 THEN
	 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                        'GETTING PERIOD INFO ...');
	 END IF;
        get_period_info;
     ELSE
        error_code := p_error_code;
        error_msg  := p_error_msg;
        RETURN;
     END IF;

     IF p_error_code = 0 THEN
	 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
  	    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                      'INSERTING JOURNAL LINES ...');
	 END IF;
	insert_batches;
     ELSE
	error_code := p_error_code;
	error_msg  := p_error_msg;
	RETURN;
     END IF;

     IF p_error_code = 0 THEN
 	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                    'PROCESSING 1219 TRANSACTIONS ...');
	 END IF;
	process_1219_transactions;
     ELSE
	error_code := p_error_code;
	error_msg  := p_error_msg;
	RETURN;
     END IF;

     IF p_error_code = 0 THEN
 	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                  'PROCESSING VOID TRANSACTIONS ...');
	END IF;
	process_void_transactions ;
     ELSE
	error_code := p_error_code;
	error_msg  := p_error_msg;
	RETURN;
     END IF;

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                                    'ENDING MAIN_1219 ...');
     END IF;
EXCEPTION
     WHEN OTHERS THEN
	p_error_code := 2;
	p_error_msg := SQLERRM || ' -- Error in MAIN procedure.';
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
                                               '.final_exception',p_error_msg);
	IF TEMP_CURSOR%ISOPEN THEN
   	   CLOSE TEMP_CURSOR;
	END IF;

	IF REFUND_CURSOR%ISOPEN THEN
	   CLOSE REFUND_CURSOR;
	END IF;

	IF VOID_CURSOR%ISOPEN THEN
           CLOSE VOID_CURSOR;
	END IF;


END MAIN_1219 ;


----------------------------------------------------------------------------
--	PROCEDURE PURGE_TEMP_TRANSACTIONS
----------------------------------------------------------------------------
-- If the delete_corrections parameter is 'Y' delete all records of
-- FV_SF1219_TEMP as well as FV_SF1219_MANUAL_LINES  tables
-- Otherwise delete records from FV_SF1219_TEMP other than record
-- type 'M' and 'N'. Records types of 'M' and 'N' are not deleted as
-- they have been assigned report lines and should be retained.
----------------------------------------------------------------------------
PROCEDURE PURGE_TEMP_TRANSACTIONS IS
  l_module_name VARCHAR2(200) := g_module_name || 'PURGE_TEMP_TRANSACTIONS';
BEGIN
	IF p_delete_corrections = 'Y'
	THEN
	   DELETE FROM fv_sf1219_temp;
	   DELETE FROM fv_sf1219_manual_lines;
	ELSE
	   DELETE FROM fv_sf1219_temp
	   WHERE record_type <> 'N';

	   DELETE FROM fv_sf1219_manual_lines
	   WHERE temp_record_id NOT IN
			(SELECT temp_record_id
			 FROM fv_sf1219_temp);
	END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      NULL ;
   WHEN OTHERS THEN
    p_error_code := 2;
    p_error_msg := SQLERRM || ' -- Error in MAIN procedure.';
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
                                            '.final_exception',p_error_msg);
    RAISE;

END PURGE_TEMP_TRANSACTIONS;


----------------------------------------------------------------------------
--		PROCEDURE GET_BALANCE_ACCOUNT_SEGMENTS
----------------------------------------------------------------------------
-- Get name of the Balance and Account Segment of the Accounting Flexfield
-- for which the Report is generated.
----------------------------------------------------------------------------
PROCEDURE GET_BALANCE_ACCOUNT_SEGMENTS IS
  l_module_name VARCHAR2(200) := g_module_name || 'GET_BALANCE_ACCOUNT_SEGMENTS';
  l_error_code BOOLEAN;
BEGIN
	SELECT chart_of_accounts_id
	INTO flex_num
	FROM gl_ledgers_public_v
	WHERE ledger_id = p_set_bks_id ;

      fv_utility.get_segment_col_names(flex_num,
				       gl_seg_name		,
				        bl_seg_name	,
			                l_error_code		,
				        p_error_msg	);

      IF L_ERROR_CODE then
        p_error_code := -1;
         RETURN;
      END IF;


 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                  'ACCOUNTING SEGMENT: '||GL_SEG_NAME);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                    'BALANCING SEGMENT: '||BL_SEG_NAME);
 END IF;

EXCEPTION
   WHEN OTHERS THEN
	p_error_code := sqlcode ;
	p_error_msg := SQLERRM || ' -- Error in '||
                         'GET_BALANCE_ACCOUNT_SEGMENTS procedure.';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                    l_module_name||'.final_exception',p_error_msg);
	ROLLBACK ;
	RETURN ;
END GET_BALANCE_ACCOUNT_SEGMENTS;


----------------------------------------------------------------------------
-- 		PROCEDURE GET_PERIOD_INFO
----------------------------------------------------------------------------
-- Derive start_date and end_date date for the reporting period. Which is
-- used in deriving reported month and exception category.
----------------------------------------------------------------------------
PROCEDURE GET_PERIOD_INFO IS
  l_module_name VARCHAR2(200) := g_module_name || 'GET_PERIOD_INFO';
l_error_stage Number:=0;
BEGIN
	l_error_stage := 1;

       	SELECT distinct year_start_date
        INTO l_yr_start_date
        FROM gl_periods glp,
             gl_ledgers_public_v gsob
        WHERE gsob.ledger_id = p_set_bks_id
        AND gsob.period_set_name   = glp.period_set_name
        AND gsob.chart_of_accounts_id = flex_num
        AND period_name = p_gl_period;

	l_error_stage := 2;

        SELECT distinct period_type
        INTO   period_type
        FROM   gl_period_statuses
        WHERE  application_id  = '101'
        AND    ledger_id = p_set_bks_id;

	l_error_stage := 3;

        SELECT start_date, end_date, period_year
        INTO l_start_date1, l_end_date1, l_period_year
        FROM gl_periods glp,
             gl_ledgers_public_v gsob
        WHERE glp.period_name = p_gl_period
	AND   glp.period_type = period_type
        AND   gsob.ledger_id      = p_set_bks_id
        AND   gsob.chart_of_accounts_id = flex_num
        AND   glp.period_set_name       = gsob.period_set_name;

	l_error_stage := 4;

	-- Determine the last date of the period year
        SELECT MAX(glp.end_date)
        INTO  l_yr_end_date
        FROM  gl_periods glp, gl_ledgers_public_v gsob
        WHERE glp.period_year = l_period_year
	AND   gsob.ledger_id = p_set_bks_id
	AND   glp.period_set_name = gsob.period_set_name;

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                    'YEAR START DATE: '||L_YR_START_DATE);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                    'YEAR END DATE: '||L_YR_END_DATE);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                    'PERIOD START DATE: '||L_START_DATE1);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                    'PERIOD END DATE: '||L_END_DATE1);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                    'PERIOD YEAR: '||L_PERIOD_YEAR);
 END IF;
EXCEPTION
   WHEN OTHERS THEN
    p_error_code := 2;
    p_error_msg := SQLERRM || ' -- Error in GET_PERIOD_INFO procedure.';
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
                                  '.final_exception',p_error_msg);
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                                  'ERROR STAGE: '||L_ERROR_STAGE);
    RETURN;
END GET_PERIOD_INFO;


----------------------------------------------------------------------------
--			PROCEDURE INSERT_BATCHES
----------------------------------------------------------------------------
-- JE Batches are inserted into FV_SF1219_TEMP table from JE Batches/Lines.
-- JE Batches, which exists in Audit table, are omitted. Also, only those
-- accounts of JE lines are selected which have been setup by user in the
-- Accounts setup table.
-- Update_type and type are required to set 'processed flag' in
-- fv_interagency_funds_all and fv_refunds_voids_all tables.
----------------------------------------------------------------------------
PROCEDURE INSERT_BATCHES IS
  l_module_name VARCHAR2(200) := g_module_name || 'INSERT_BATCHES';
  no_of_tran  number  := 0;
  l_string    varchar2(10000);
  l_string1   varchar2(10000);
  l_string2   varchar2(10000);
  l_string3   varchar2(1000);

  l_cur       number;
  l_row       number;

BEGIN


   l_string1 := 'INSERT INTO fv_sf1219_temp(
		temp_record_id,
		batch_id,
		fund_code,
		name,
		set_of_books_id,
		posted_date,
		gl_period,
		reported_gl_period,
		amount,
		sf1219_type_code,
		reference_1,
		reference_2,
		reference_3,
		reference_4,
		reference_5,
		reference_6,
		reference_9,
		reported_month,
		default_period_name,
		exception_category,
		accomplish_month,
		accomplish_date,
		obligation_date,
		inter_agency_flag,
		treasury_symbol,
		treasury_symbol_id,
		record_type,
		lines_exist,
		alc_code,
		org_id,
		group_name,
		update_type,
		type,
		gl_period_name,
		processed_flag,
		creation_date,
		created_by,
		last_update_date,
		last_updated_by,
		last_update_login,
		je_header_id,
		je_line_num,
                je_from_sla_flag)';



   l_string3 := 'AND NOT EXISTS
                (SELECT ''X''
                 FROM  fv_sf1219_audits fvs
                 WHERE fvs.batch_id     = glb.je_batch_id
                 AND   fvs.je_header_id = gll.je_header_id
                 AND   fvs.je_line_num  = gll.je_line_num
                 AND   fvs.record_type <> ''B'')';

   /* Start for non-sla, upgraded 11i data */

   l_string2 := 'SELECT
		fv_sf1219_temp_s.NEXTVAL,
		glb.je_batch_id,
		ffp.fund_value,
		NVL(glb.name,''Manual''),
		--glb.set_of_books_id,
                --NULL,
                :b_sob,
		glb.posted_date,
		gll.period_name,
		TO_CHAR(:b_start_date1,''MMYYYY''), -- reported_gl_period updated
		NVL(gll.entered_dr,0) - NVL(gll.entered_cr,0),
		''MANUAL'',				-- default value
		LTRIM(RTRIM(gll.reference_1)),
		LTRIM(RTRIM(gll.reference_2)),
		LTRIM(RTRIM(gll.reference_3)),
		LTRIM(RTRIM(gll.reference_4)),
		LTRIM(RTRIM(gll.reference_5)),
		LTRIM(RTRIM(gll.reference_6)),
		LTRIM(RTRIM(gll.reference_9)),
		NULL,		-- reported month used for exceptions
		glb.default_period_name,
		NULL,	-- exception_category updated when exception occurred
		NULL,	-- accomplish_month derived during the process
		:b_end_date1,		-- accomplish date
		NULL,	-- obligation_date derived during the process
		NULL,		-- ia flag updated during the process
		fts.treasury_symbol,	-- no fund_value for null value(06/15)
		ffp.treasury_symbol_id, -- Added to fix Bug 1575992
		''M'',			-- Default record type as Manual
		''N'',			-- Default value for lines exist
		fda.agency_location_code,
		-1, --glb.org_id,
		NULL,		-- Group name assigned during the process
		NULL,		-- update type assigned during the process
		NULL,		-- type assigned during the process
		:b_gl_period,		-- gl period for which process is run
		''N'',			-- default processed flag
		SYSDATE,
		fnd_global.user_id,
		SYSDATE,
		fnd_global.user_id,
		fnd_global.login_id,
		gll.je_header_id,
		gll.je_line_num,
                glh.je_from_sla_flag
	FROM	gl_je_batches			glb,
 		gl_je_headers			glh,
 		gl_je_lines			gll,
		gl_code_combinations	  	gcc,
		fv_sf1219_definitions_accts	fda,
		fv_fund_parameters		ffp,
		fv_treasury_symbols		fts

        WHERE   gll.effective_date <= :b_end_date1
	AND     glh.currency_code = :b_currency_code
	AND	glb.status	= ''P''
	AND 	glb.actual_flag	= ''A''
	AND 	glb.je_batch_id = glh.je_batch_id
	AND 	glh.je_header_id = gll.je_header_id
	AND 	gll.code_combination_id = gcc.code_combination_id
	--AND 	gll.set_of_books_id	= p_set_bks_id
	AND 	gll.ledger_id	= :b_sob
	AND 	fda.set_of_books_id 	= :b_sob
	AND 	ffp.set_of_books_id 	= :b_sob
	AND 	fts.treasury_symbol_id 	= ffp.treasury_symbol_id
	AND 	fts.set_of_books_id 	= :b_sob
	AND     NVL(glh.je_from_sla_flag, ''N'')  IN (''N'', ''U'')
        AND     decode(:b_bl_seg_name,''SEGMENT1'', gcc.segment1,
                                   ''SEGMENT2'', gcc.segment2,
                                   ''SEGMENT3'', gcc.segment3,
                                   ''SEGMENT4'', gcc.segment4,
                                   ''SEGMENT5'', gcc.segment5,
                                   ''SEGMENT6'', gcc.segment6,
                                   ''SEGMENT7'', gcc.segment7,
                                   ''SEGMENT8'', gcc.segment8,
                                   ''SEGMENT9'', gcc.segment9,
                                   ''SEGMENT10'', gcc.segment10,
                                   ''SEGMENT11'', gcc.segment11,
                                   ''SEGMENT12'', gcc.segment12,
                                   ''SEGMENT13'', gcc.segment13,
                                   ''SEGMENT14'', gcc.segment14,
                                   ''SEGMENT15'', gcc.segment15,
                                   ''SEGMENT16'', gcc.segment16,
                                   ''SEGMENT17'', gcc.segment17,
                                   ''SEGMENT18'', gcc.segment18,
                                   ''SEGMENT19'', gcc.segment19,
                                   ''SEGMENT20'', gcc.segment20,
                                   ''SEGMENT21'', gcc.segment21,
                                   ''SEGMENT22'', gcc.segment22,
                                   ''SEGMENT23'', gcc.segment23,
                                   ''SEGMENT24'', gcc.segment24,
                                   ''SEGMENT25'', gcc.segment25,
                                   ''SEGMENT26'', gcc.segment26,
                                   ''SEGMENT27'', gcc.segment27,
                                   ''SEGMENT28'', gcc.segment28,
                                   ''SEGMENT29'', gcc.segment29,
                                 ''SEGMENT30'', gcc.segment30) = ffp.fund_value
  and nvl(fda.segment1,''-1'') = decode(fda.segment1,null, ''-1'', gcc.segment1)
  and nvl(fda.segment2,''-1'') = decode(fda.segment2,null, ''-1'', gcc.segment2)
  and nvl(fda.segment3,''-1'') = decode(fda.segment3,null, ''-1'', gcc.segment3)
  and nvl(fda.segment4,''-1'') = decode(fda.segment4,null, ''-1'', gcc.segment4)
  and nvl(fda.segment5,''-1'') = decode(fda.segment5,null, ''-1'', gcc.segment5)
  and nvl(fda.segment6,''-1'') = decode(fda.segment6,null, ''-1'', gcc.segment6)
  and nvl(fda.segment7,''-1'') = decode(fda.segment7,null, ''-1'', gcc.segment7)
  and nvl(fda.segment8,''-1'') = decode(fda.segment8,null, ''-1'', gcc.segment8)
  and nvl(fda.segment9,''-1'') = decode(fda.segment9,null, ''-1'', gcc.segment9)
 and nvl(fda.segment10,''-1'') = decode(fda.segment10,null,''-1'',gcc.segment10)
 and nvl(fda.segment11,''-1'') = decode(fda.segment11,null,''-1'',gcc.segment11)
 and nvl(fda.segment12,''-1'') = decode(fda.segment12,null,''-1'',gcc.segment12)
 and nvl(fda.segment13,''-1'') = decode(fda.segment13,null,''-1'',gcc.segment13)
 and nvl(fda.segment14,''-1'') = decode(fda.segment14,null,''-1'',gcc.segment14)
 and nvl(fda.segment15,''-1'') = decode(fda.segment15,null,''-1'',gcc.segment15)
 and nvl(fda.segment16,''-1'') = decode(fda.segment16,null,''-1'',gcc.segment16)
 and nvl(fda.segment17,''-1'') = decode(fda.segment17,null,''-1'',gcc.segment17)
 and nvl(fda.segment18,''-1'') = decode(fda.segment18,null,''-1'',gcc.segment18)
 and nvl(fda.segment19,''-1'') = decode(fda.segment19,null,''-1'',gcc.segment19)
 and nvl(fda.segment20,''-1'') = decode(fda.segment20,null,''-1'',gcc.segment20)
 and nvl(fda.segment21,''-1'') = decode(fda.segment21,null,''-1'',gcc.segment21)
 and nvl(fda.segment22,''-1'') = decode(fda.segment22,null,''-1'',gcc.segment22)
 and nvl(fda.segment23,''-1'') = decode(fda.segment23,null,''-1'',gcc.segment23)
 and nvl(fda.segment24,''-1'') = decode(fda.segment24,null,''-1'',gcc.segment24)
 and nvl(fda.segment25,''-1'') = decode(fda.segment25,null,''-1'',gcc.segment25)
 and nvl(fda.segment26,''-1'') = decode(fda.segment26,null,''-1'',gcc.segment26)
 and nvl(fda.segment27,''-1'') = decode(fda.segment27,null,''-1'',gcc.segment27)
 and nvl(fda.segment28,''-1'') = decode(fda.segment28,null,''-1'',gcc.segment28)
 and nvl(fda.segment29,''-1'') = decode(fda.segment29,null,''-1'',gcc.segment29)
 and nvl(fda.segment30,''-1'') = decode(fda.segment30,null,''-1'',
gcc.segment30)';

  l_string := l_string1 || l_string2 || l_string3 ;
  l_cur:= dbms_sql.open_cursor;
  dbms_sql.parse(l_cur, l_string, DBMS_SQL.V7);

  dbms_sql.bind_variable(l_cur,':b_sob',p_set_bks_id);
  dbms_sql.bind_variable(l_cur,':b_start_date1',l_start_date1);
  dbms_sql.bind_variable(l_cur,':b_end_date1',l_end_date1);
  dbms_sql.bind_variable(l_cur,':b_gl_period',p_gl_period);
  dbms_sql.bind_variable(l_cur,':b_currency_code',l_currency_code);
  dbms_sql.bind_variable(l_cur,':b_bl_seg_name',bl_seg_name);

  l_row := dbms_sql.EXECUTE(l_cur);
  dbms_sql.close_cursor(l_cur);
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                l_module_name,'1. l_end_date1 : '||l_end_date1);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                  l_module_name,'1. NUMBER OF ROWS INSERTED: '||l_row);
 END IF;

  /* END for non-sla, upgraded 11i data */

   fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'End of Insert
for upgraded 11i data ');

   /* Start for je_source is payables and je_category is non treasury  */

l_string2 := 'SELECT
                fv_sf1219_temp_s.NEXTVAL,
                glb.je_batch_id,
                ffp.fund_value,
                glb.name,
                :b_sob,
                glb.posted_date,
                gll.period_name,
                TO_CHAR(:b_start_date1,''MMYYYY''), -- reported_gl_period
                NVL(xal.unrounded_accounted_dr,0) - NVL(xal.unrounded_accounted_cr,0),       --NVL(gll.entered_dr,0) - NVL(gll.entered_cr,0),
                ''MANUAL'',                               -- default value
                NULL,
                LTRIM(RTRIM(aid.invoice_id)),
                LTRIM(RTRIM(aip.check_id)),
                NULL,
                NULL,
                NULL,
                LTRIM(RTRIM(aip.invoice_payment_id)),
                NULL,           -- reported month used for exceptions
                glb.default_period_name,
                NULL,   -- exception_category updated when exception occurred
                NULL,   -- accomplish_month derived during the process
                :b_end_date1,            -- accomplish date
                NULL,   -- obligation_date derived during the process
                NULL,           -- ia flag updated during the process
                fts.treasury_symbol,    -- no fund_value for null value(06/15)
                ffp.treasury_symbol_id, -- Added to fix Bug 1575992
                ''M'',                    -- Default record type as Manual
                ''N'',                    -- Default value for lines exist
                fda.agency_location_code,
                -1, --glb.org_id,
                NULL,           -- Group name assigned during the process
                NULL,           -- update type assigned during the process
                NULL,           -- type assigned during the process
                :b_gl_period,            -- gl period for which process is run
                ''N'',                    -- default processed flag
                SYSDATE,
                fnd_global.user_id,
                SYSDATE,
                fnd_global.user_id,
                fnd_global.login_id,
                gll.je_header_id,
                gll.je_line_num,
                glh.je_from_sla_flag
        FROM    gl_je_batches                   glb,
                gl_je_headers                   glh,
                gl_je_lines                     gll,
                gl_code_combinations            gcc,
                fv_sf1219_definitions_accts     fda,
                fv_fund_parameters              ffp,
                fv_treasury_symbols             fts,
                ap_invoices_all ai,
                ap_invoice_distributions_all    aid,
                ap_invoice_payments_all         aip,
                ap_payment_hist_dists          aphd,
                gl_import_references            glir,
                xla_ae_headers                  xah,
                xla_ae_lines                    xal,
                xla_events                      xet,
                xla_distribution_links          xdl

        WHERE   gll.effective_date <= :b_end_date1
        AND     glh.currency_code = :b_currency_code
        AND     glb.status      = ''P''
        AND     glb.actual_flag = ''A''
        AND     glb.je_batch_id = glh.je_batch_id
        AND     glh.je_header_id = gll.je_header_id
        AND     gll.code_combination_id = gcc.code_combination_id
        --AND   gll.set_of_books_id     = p_set_bks_id
        AND     gll.ledger_id   = :b_sob
        AND     fda.set_of_books_id     = :b_sob
        AND     ffp.set_of_books_id     = :b_sob
        AND     fts.treasury_symbol_id  = ffp.treasury_symbol_id
        AND     aip.invoice_payment_id = aphd.invoice_payment_id
        AND     fts.set_of_books_id     = :b_sob
        AND     glh.je_source=''Payables''
        AND     glh.je_category <> ''Treasury Confirmation''
        AND     glh.je_from_sla_flag = ''Y''
        AND     ai.invoice_id = aid.invoice_id
        AND     aip.invoice_id = ai.invoice_id
        AND     glir.je_header_id = gll.je_header_id
        AND     glir.je_line_num = gll.je_line_num
        AND 	xal.gl_sl_link_id = glir.gl_sl_link_id
        AND 	xal.gl_sl_link_table = glir.gl_sl_link_table
        AND 	xal.ae_header_id = xah.ae_header_id
	AND 	xet.event_id = xah.event_id
	AND 	xdl.event_id = xet.event_id
        AND 	xdl.ae_header_id = xah.ae_header_id
        AND 	xdl.ae_line_num = xal.ae_line_num
        AND 	xdl.source_distribution_type IN ( ''AP_PMT_DIST'')
        AND     xdl.source_distribution_id_num_1 = aphd.payment_hist_dist_id
        AND     aphd.invoice_distribution_id = aid.invoice_distribution_id
        AND 	xdl.application_id = 200
        AND     decode(:b_bl_seg_name,''SEGMENT1'', gcc.segment1,
                                   ''SEGMENT2'', gcc.segment2,
                                   ''SEGMENT3'', gcc.segment3,
                                   ''SEGMENT4'', gcc.segment4,
                                   ''SEGMENT5'', gcc.segment5,
                                   ''SEGMENT6'', gcc.segment6,
                                   ''SEGMENT7'', gcc.segment7,
                                   ''SEGMENT8'', gcc.segment8,
                                   ''SEGMENT9'', gcc.segment9,
                                   ''SEGMENT10'', gcc.segment10,
                                   ''SEGMENT11'', gcc.segment11,
                                   ''SEGMENT12'', gcc.segment12,
                                   ''SEGMENT13'', gcc.segment13,
                                   ''SEGMENT14'', gcc.segment14,
                                   ''SEGMENT15'', gcc.segment15,
                                   ''SEGMENT16'', gcc.segment16,
                                   ''SEGMENT17'', gcc.segment17,
                                   ''SEGMENT18'', gcc.segment18,
                                   ''SEGMENT19'', gcc.segment19,
                                   ''SEGMENT20'', gcc.segment20,
                                   ''SEGMENT21'', gcc.segment21,
                                   ''SEGMENT22'', gcc.segment22,
                                   ''SEGMENT23'', gcc.segment23,
                                   ''SEGMENT24'', gcc.segment24,
                                   ''SEGMENT25'', gcc.segment25,
                                   ''SEGMENT26'', gcc.segment26,
                                   ''SEGMENT27'', gcc.segment27,
                                   ''SEGMENT28'', gcc.segment28,
                                   ''SEGMENT29'', gcc.segment29,
                                 ''SEGMENT30'', gcc.segment30) = ffp.fund_value
  and nvl(fda.segment1,''-1'') = decode(fda.segment1,null, ''-1'', gcc.segment1)
  and nvl(fda.segment2,''-1'') = decode(fda.segment2,null, ''-1'', gcc.segment2)
  and nvl(fda.segment3,''-1'') = decode(fda.segment3,null, ''-1'', gcc.segment3)
  and nvl(fda.segment4,''-1'') = decode(fda.segment4,null, ''-1'', gcc.segment4)
  and nvl(fda.segment5,''-1'') = decode(fda.segment5,null, ''-1'', gcc.segment5)
  and nvl(fda.segment6,''-1'') = decode(fda.segment6,null, ''-1'', gcc.segment6)
  and nvl(fda.segment7,''-1'') = decode(fda.segment7,null, ''-1'', gcc.segment7)
  and nvl(fda.segment8,''-1'') = decode(fda.segment8,null, ''-1'', gcc.segment8)
  and nvl(fda.segment9,''-1'') = decode(fda.segment9,null, ''-1'', gcc.segment9)
 and nvl(fda.segment10,''-1'') = decode(fda.segment10,null,''-1'',gcc.segment10)
 and nvl(fda.segment11,''-1'') = decode(fda.segment11,null,''-1'',gcc.segment11)
 and nvl(fda.segment12,''-1'') = decode(fda.segment12,null,''-1'',gcc.segment12)
 and nvl(fda.segment13,''-1'') = decode(fda.segment13,null,''-1'',gcc.segment13)
 and nvl(fda.segment14,''-1'') = decode(fda.segment14,null,''-1'',gcc.segment14)
 and nvl(fda.segment15,''-1'') = decode(fda.segment15,null,''-1'',gcc.segment15)
 and nvl(fda.segment16,''-1'') = decode(fda.segment16,null,''-1'',gcc.segment16)
 and nvl(fda.segment17,''-1'') = decode(fda.segment17,null,''-1'',gcc.segment17)
 and nvl(fda.segment18,''-1'') = decode(fda.segment18,null,''-1'',gcc.segment18)
 and nvl(fda.segment19,''-1'') = decode(fda.segment19,null,''-1'',gcc.segment19)
 and nvl(fda.segment20,''-1'') = decode(fda.segment20,null,''-1'',gcc.segment20)
 and nvl(fda.segment21,''-1'') = decode(fda.segment21,null,''-1'',gcc.segment21)
 and nvl(fda.segment22,''-1'') = decode(fda.segment22,null,''-1'',gcc.segment22)
 and nvl(fda.segment23,''-1'') = decode(fda.segment23,null,''-1'',gcc.segment23)
 and nvl(fda.segment24,''-1'') = decode(fda.segment24,null,''-1'',gcc.segment24)
 and nvl(fda.segment25,''-1'') = decode(fda.segment25,null,''-1'',gcc.segment25)
 and nvl(fda.segment26,''-1'') = decode(fda.segment26,null,''-1'',gcc.segment26)
 and nvl(fda.segment27,''-1'') = decode(fda.segment27,null,''-1'',gcc.segment27)
 and nvl(fda.segment28,''-1'') = decode(fda.segment28,null,''-1'',gcc.segment28)
 and nvl(fda.segment29,''-1'') = decode(fda.segment29,null,''-1'',gcc.segment29)
 and nvl(fda.segment30,''-1'') = decode(fda.segment30,null,''-1'',
gcc.segment30)';

  l_string := l_string1 || l_string2 || l_string3 ;
  l_cur:= dbms_sql.open_cursor;
  dbms_sql.parse(l_cur, l_string, DBMS_SQL.V7);

  dbms_sql.bind_variable(l_cur,':b_sob',p_set_bks_id);
  dbms_sql.bind_variable(l_cur,':b_start_date1',l_start_date1);
  dbms_sql.bind_variable(l_cur,':b_end_date1',l_end_date1);
  dbms_sql.bind_variable(l_cur,':b_gl_period',p_gl_period);
  dbms_sql.bind_variable(l_cur,':b_currency_code',l_currency_code);
  dbms_sql.bind_variable(l_cur,':b_bl_seg_name',bl_seg_name);

  l_row := dbms_sql.EXECUTE(l_cur);
  dbms_sql.close_cursor(l_cur);
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                l_module_name,'1. l_end_date1 : '||l_end_date1);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                  l_module_name,'1. NUMBER OF ROWS INSERTED: '||l_row);
  END IF;

  /* END for  je_source is payables and je_category is non treasury*/

/* Start for je_source is payables and je_category is non treasury  */

l_string2 := 'SELECT
                fv_sf1219_temp_s.NEXTVAL,
                glb.je_batch_id,
                ffp.fund_value,
                glb.name,
                :b_sob,
                glb.posted_date,
                gll.period_name,
                TO_CHAR(:b_start_date1,''MMYYYY''), -- reported_gl_period
                NVL(xal.unrounded_accounted_dr,0) - NVL(xal.unrounded_accounted_cr,0),    --NVL(gll.entered_dr,0) - NVL(gll.entered_cr,0),
                ''MANUAL'',                               -- default value
                NULL,
                LTRIM(RTRIM(aid.invoice_id)),
                LTRIM(RTRIM(aip.check_id)),
                NULL,
                NULL,
                NULL,
                LTRIM(RTRIM(aip.invoice_payment_id)),
                NULL,           -- reported month used for exceptions
                glb.default_period_name,
                NULL,   -- exception_category updated when exception occurred
                NULL,   -- accomplish_month derived during the process
                :b_end_date1,            -- accomplish date
                NULL,   -- obligation_date derived during the process
                NULL,           -- ia flag updated during the process
                fts.treasury_symbol,    -- no fund_value for null value(06/15)
                ffp.treasury_symbol_id, -- Added to fix Bug 1575992
                ''M'',                    -- Default record type as Manual
                ''N'',                    -- Default value for lines exist
                fda.agency_location_code,
                -1, --glb.org_id,
                NULL,           -- Group name assigned during the process
                NULL,           -- update type assigned during the process
                NULL,           -- type assigned during the process
                :b_gl_period,            -- gl period for which process is run
                ''N'',                    -- default processed flag
                SYSDATE,
                fnd_global.user_id,
                SYSDATE,
                fnd_global.user_id,
                fnd_global.login_id,
                gll.je_header_id,
                gll.je_line_num,
                glh.je_from_sla_flag
        FROM    gl_je_batches                   glb,
                gl_je_headers                   glh,
                gl_je_lines                     gll,
                gl_code_combinations            gcc,
                fv_sf1219_definitions_accts     fda,
                fv_fund_parameters              ffp,
                fv_treasury_symbols             fts,
                ap_invoices_all ai,
                ap_invoice_distributions_all    aid,
                ap_invoice_payments_all         aip,
                gl_import_references            glir,
                xla_ae_headers                  xah,
                xla_ae_lines                    xal,
                xla_events                      xet,
                xla_distribution_links          xdl

        WHERE   gll.effective_date <= :b_end_date1
        AND     glh.currency_code = :b_currency_code
        AND     glb.status      = ''P''
        AND     glb.actual_flag = ''A''
        AND     glb.je_batch_id = glh.je_batch_id
        AND     glh.je_header_id = gll.je_header_id
        AND     gll.code_combination_id = gcc.code_combination_id
        --AND   gll.set_of_books_id     = p_set_bks_id
        AND     gll.ledger_id   = :b_sob
        AND     fda.set_of_books_id     = :b_sob
        AND     ffp.set_of_books_id     = :b_sob
        AND     fts.treasury_symbol_id  = ffp.treasury_symbol_id
        AND     fts.set_of_books_id     = :b_sob
        AND     glh.je_source=''Payables''
        AND     glh.je_category <> ''Treasury Confirmation''
        AND     glh.je_from_sla_flag = ''Y''
        AND     ai.invoice_id = aid.invoice_id
        AND     aip.invoice_id = ai.invoice_id
        AND     glir.je_header_id = gll.je_header_id
        AND     glir.je_line_num = gll.je_line_num
        AND 	xal.gl_sl_link_id = glir.gl_sl_link_id
        AND 	xal.gl_sl_link_table = glir.gl_sl_link_table
        AND 	xal.ae_header_id = xah.ae_header_id
	AND 	xet.event_id = xah.event_id
	AND 	xdl.event_id = xet.event_id
        AND 	xdl.ae_header_id = xah.ae_header_id
        AND 	xdl.ae_line_num = xal.ae_line_num
        AND 	xdl.source_distribution_type IN (''AP_INV_DIST'',''AP_PREPAY'')
        AND 	xdl.source_distribution_id_num_1 = aid.invoice_distribution_id
        AND 	xdl.application_id = 200
        AND     decode(:b_bl_seg_name,''SEGMENT1'', gcc.segment1,
                                   ''SEGMENT2'', gcc.segment2,
                                   ''SEGMENT3'', gcc.segment3,
                                   ''SEGMENT4'', gcc.segment4,
                                   ''SEGMENT5'', gcc.segment5,
                                   ''SEGMENT6'', gcc.segment6,
                                   ''SEGMENT7'', gcc.segment7,
                                   ''SEGMENT8'', gcc.segment8,
                                   ''SEGMENT9'', gcc.segment9,
                                   ''SEGMENT10'', gcc.segment10,
                                   ''SEGMENT11'', gcc.segment11,
                                   ''SEGMENT12'', gcc.segment12,
                                   ''SEGMENT13'', gcc.segment13,
                                   ''SEGMENT14'', gcc.segment14,
                                   ''SEGMENT15'', gcc.segment15,
                                   ''SEGMENT16'', gcc.segment16,
                                   ''SEGMENT17'', gcc.segment17,
                                   ''SEGMENT18'', gcc.segment18,
                                   ''SEGMENT19'', gcc.segment19,
                                   ''SEGMENT20'', gcc.segment20,
                                   ''SEGMENT21'', gcc.segment21,
                                   ''SEGMENT22'', gcc.segment22,
                                   ''SEGMENT23'', gcc.segment23,
                                   ''SEGMENT24'', gcc.segment24,
                                   ''SEGMENT25'', gcc.segment25,
                                   ''SEGMENT26'', gcc.segment26,
                                   ''SEGMENT27'', gcc.segment27,
                                   ''SEGMENT28'', gcc.segment28,
                                   ''SEGMENT29'', gcc.segment29,
                                 ''SEGMENT30'', gcc.segment30) = ffp.fund_value
  and nvl(fda.segment1,''-1'') = decode(fda.segment1,null, ''-1'', gcc.segment1)
  and nvl(fda.segment2,''-1'') = decode(fda.segment2,null, ''-1'', gcc.segment2)
  and nvl(fda.segment3,''-1'') = decode(fda.segment3,null, ''-1'', gcc.segment3)
  and nvl(fda.segment4,''-1'') = decode(fda.segment4,null, ''-1'', gcc.segment4)
  and nvl(fda.segment5,''-1'') = decode(fda.segment5,null, ''-1'', gcc.segment5)
  and nvl(fda.segment6,''-1'') = decode(fda.segment6,null, ''-1'', gcc.segment6)
  and nvl(fda.segment7,''-1'') = decode(fda.segment7,null, ''-1'', gcc.segment7)
  and nvl(fda.segment8,''-1'') = decode(fda.segment8,null, ''-1'', gcc.segment8)
  and nvl(fda.segment9,''-1'') = decode(fda.segment9,null, ''-1'', gcc.segment9)
 and nvl(fda.segment10,''-1'') = decode(fda.segment10,null,''-1'',gcc.segment10)
 and nvl(fda.segment11,''-1'') = decode(fda.segment11,null,''-1'',gcc.segment11)
 and nvl(fda.segment12,''-1'') = decode(fda.segment12,null,''-1'',gcc.segment12)
 and nvl(fda.segment13,''-1'') = decode(fda.segment13,null,''-1'',gcc.segment13)
 and nvl(fda.segment14,''-1'') = decode(fda.segment14,null,''-1'',gcc.segment14)
 and nvl(fda.segment15,''-1'') = decode(fda.segment15,null,''-1'',gcc.segment15)
 and nvl(fda.segment16,''-1'') = decode(fda.segment16,null,''-1'',gcc.segment16)
 and nvl(fda.segment17,''-1'') = decode(fda.segment17,null,''-1'',gcc.segment17)
 and nvl(fda.segment18,''-1'') = decode(fda.segment18,null,''-1'',gcc.segment18)
 and nvl(fda.segment19,''-1'') = decode(fda.segment19,null,''-1'',gcc.segment19)
 and nvl(fda.segment20,''-1'') = decode(fda.segment20,null,''-1'',gcc.segment20)
 and nvl(fda.segment21,''-1'') = decode(fda.segment21,null,''-1'',gcc.segment21)
 and nvl(fda.segment22,''-1'') = decode(fda.segment22,null,''-1'',gcc.segment22)
 and nvl(fda.segment23,''-1'') = decode(fda.segment23,null,''-1'',gcc.segment23)
 and nvl(fda.segment24,''-1'') = decode(fda.segment24,null,''-1'',gcc.segment24)
 and nvl(fda.segment25,''-1'') = decode(fda.segment25,null,''-1'',gcc.segment25)
 and nvl(fda.segment26,''-1'') = decode(fda.segment26,null,''-1'',gcc.segment26)
 and nvl(fda.segment27,''-1'') = decode(fda.segment27,null,''-1'',gcc.segment27)
 and nvl(fda.segment28,''-1'') = decode(fda.segment28,null,''-1'',gcc.segment28)
 and nvl(fda.segment29,''-1'') = decode(fda.segment29,null,''-1'',gcc.segment29)
 and nvl(fda.segment30,''-1'') = decode(fda.segment30,null,''-1'',
gcc.segment30)';

  l_string := l_string1 || l_string2 || l_string3 ;
  l_cur:= dbms_sql.open_cursor;
  dbms_sql.parse(l_cur, l_string, DBMS_SQL.V7);

  dbms_sql.bind_variable(l_cur,':b_sob',p_set_bks_id);
  dbms_sql.bind_variable(l_cur,':b_start_date1',l_start_date1);
  dbms_sql.bind_variable(l_cur,':b_end_date1',l_end_date1);
  dbms_sql.bind_variable(l_cur,':b_gl_period',p_gl_period);
  dbms_sql.bind_variable(l_cur,':b_currency_code',l_currency_code);
  dbms_sql.bind_variable(l_cur,':b_bl_seg_name',bl_seg_name);

  l_row := dbms_sql.EXECUTE(l_cur);
  dbms_sql.close_cursor(l_cur);
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                l_module_name,'1. l_end_date1 : '||l_end_date1);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                  l_module_name,'1. NUMBER OF ROWS INSERTED: '||l_row);
  END IF;

  /* END for  je_source is payables and je_category is non treasury*/

fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'End of Insert
for je_source is payables and je_category is non treasury');


 /* Start for je_source is payables and je_category is treasury confirmation */

 l_string2 := 'SELECT
                fv_sf1219_temp_s.NEXTVAL,
                glb.je_batch_id,
                ffp.fund_value,
                glb.name,
                :b_sob,
                glb.posted_date,
                gll.period_name,
                TO_CHAR(:b_start_date1,''MMYYYY''), -- reported_gl_period updated
                NVL(xal.unrounded_accounted_dr,0) - NVL(xal.unrounded_accounted_cr,0),    --NVL(gll.entered_dr,0) -NVL(gll.entered_cr,0),
                ''MANUAL'',                               -- default value
                LTRIM(RTRIM(xdl.APPLIED_TO_SOURCE_ID_NUM_1)), --treasury confirmation id
                NULL,
                LTRIM(RTRIM(AIP.check_id)),                      --Check_id
                LTRIM(RTRIM(aid.invoice_id)),                    --invoice_id
                NULL,
                LTRIM(RTRIM(aid.accounting_date)),           --Accomplish date
                NULL,                  --invoice_payment_id
                NULL,           -- reported month used for exceptions
                glb.default_period_name,
                NULL,   -- exception_category updated when exception occurred
                NULL,   -- accomplish_month derived during the process
                :b_end_date1,            -- accomplish date
                NULL,   -- obligation_date derived during the process
                NULL,           -- ia flag updated during the process
                fts.treasury_symbol,    -- no fund_value for null value(06/15)
                ffp.treasury_symbol_id, -- Added to fix Bug 1575992
                ''M'',                    -- Default record type as Manual
                ''N'',                    -- Default value for lines exist
                fda.agency_location_code,
                -1, --glb.org_id,
                NULL,           -- Group name assigned during the process
                NULL,           -- update type assigned during the process
                NULL,           -- type assigned during the process
                :b_gl_period,            -- gl period for which process is run
                ''N'',                    -- default processed flag
                SYSDATE,
                fnd_global.user_id,
                SYSDATE,
                fnd_global.user_id,
                fnd_global.login_id,
                gll.je_header_id,
                gll.je_line_num,
                glh.je_from_sla_flag
        FROM    gl_je_batches                   glb,
                gl_je_headers                   glh,
                gl_je_lines                     gll,
                gl_code_combinations            gcc,
                fv_sf1219_definitions_accts     fda,
                fv_fund_parameters              ffp,
                fv_treasury_symbols             fts,
                ap_invoice_distributions_all    aid,
                ap_invoice_payments_all         aip,
                ap_payment_hist_dists aphd,
                gl_import_references            glir,
                xla_ae_headers                  xah,
                xla_ae_lines                    xal,
                xla_distribution_links          xdl

        WHERE   gll.effective_date <= :b_end_date1
        AND     glh.currency_code = :b_currency_code
        AND     glb.status      = ''P''
        AND     glb.actual_flag = ''A''
        AND     glb.je_batch_id = glh.je_batch_id
        AND     glh.je_header_id = gll.je_header_id
        AND     gll.code_combination_id = gcc.code_combination_id
        --AND   gll.set_of_books_id     = p_set_bks_id
        AND     gll.ledger_id   = :b_sob
        AND     fda.set_of_books_id     = :b_sob
        AND     ffp.set_of_books_id     = :b_sob
        AND     fts.treasury_symbol_id  = ffp.treasury_symbol_id
        AND     fts.set_of_books_id     = :b_sob
        AND     glh.je_category = ''Treasury Confirmation''
        AND     glh.je_from_sla_flag = ''Y''
        AND     aip.invoice_payment_id = aphd.invoice_payment_id
        AND     glir.je_header_id = gll.je_header_id
        AND     glir.je_line_num = gll.je_line_num
        AND     xal.gl_sl_link_id = glir.gl_sl_link_id
        AND     xal.gl_sl_link_table = glir.gl_sl_link_table
        AND     xal.ae_header_id = xah.ae_header_id
        AND     xdl.event_id = xah.event_id
        AND     xdl.ae_header_id = xah.ae_header_id
        AND     xdl.ae_line_num = xal.ae_line_num
        AND 	xdl.source_distribution_type = ''FV_TREASURY_CONFIRMATIONS_ALL''
        AND 	xdl.source_distribution_id_num_1 = aphd.payment_hist_dist_id
        AND 	aid.invoice_distribution_id = aphd.invoice_distribution_id
        AND 	xdl.application_id = 8901

        AND     decode(:b_bl_seg_name,''SEGMENT1'', gcc.segment1,
                                   ''SEGMENT2'', gcc.segment2,
                                   ''SEGMENT3'', gcc.segment3,
                                   ''SEGMENT4'', gcc.segment4,
                                   ''SEGMENT5'', gcc.segment5,
                                   ''SEGMENT6'', gcc.segment6,
                                   ''SEGMENT7'', gcc.segment7,
                                   ''SEGMENT8'', gcc.segment8,
                                   ''SEGMENT9'', gcc.segment9,
                                   ''SEGMENT10'', gcc.segment10,
                                   ''SEGMENT11'', gcc.segment11,
                                   ''SEGMENT12'', gcc.segment12,
                                   ''SEGMENT13'', gcc.segment13,
                                   ''SEGMENT14'', gcc.segment14,
                                   ''SEGMENT15'', gcc.segment15,
                                   ''SEGMENT16'', gcc.segment16,
                                   ''SEGMENT17'', gcc.segment17,
                                   ''SEGMENT18'', gcc.segment18,
                                   ''SEGMENT19'', gcc.segment19,
                                   ''SEGMENT20'', gcc.segment20,
                                   ''SEGMENT21'', gcc.segment21,
                                   ''SEGMENT22'', gcc.segment22,
                                   ''SEGMENT23'', gcc.segment23,
                                   ''SEGMENT24'', gcc.segment24,
                                   ''SEGMENT25'', gcc.segment25,
                                   ''SEGMENT26'', gcc.segment26,
                                   ''SEGMENT27'', gcc.segment27,
                                   ''SEGMENT28'', gcc.segment28,
                                   ''SEGMENT29'', gcc.segment29,
                                 ''SEGMENT30'', gcc.segment30) = ffp.fund_value
  and nvl(fda.segment1,''-1'') = decode(fda.segment1,null, ''-1'', gcc.segment1)
  and nvl(fda.segment2,''-1'') = decode(fda.segment2,null, ''-1'', gcc.segment2)
  and nvl(fda.segment3,''-1'') = decode(fda.segment3,null, ''-1'', gcc.segment3)
  and nvl(fda.segment4,''-1'') = decode(fda.segment4,null, ''-1'', gcc.segment4)
  and nvl(fda.segment5,''-1'') = decode(fda.segment5,null, ''-1'', gcc.segment5)
  and nvl(fda.segment6,''-1'') = decode(fda.segment6,null, ''-1'', gcc.segment6)
  and nvl(fda.segment7,''-1'') = decode(fda.segment7,null, ''-1'', gcc.segment7)
  and nvl(fda.segment8,''-1'') = decode(fda.segment8,null, ''-1'', gcc.segment8)
  and nvl(fda.segment9,''-1'') = decode(fda.segment9,null, ''-1'', gcc.segment9)
 and nvl(fda.segment10,''-1'') = decode(fda.segment10,null,''-1'',gcc.segment10)
 and nvl(fda.segment11,''-1'') = decode(fda.segment11,null,''-1'',gcc.segment11)
 and nvl(fda.segment12,''-1'') = decode(fda.segment12,null,''-1'',gcc.segment12)
 and nvl(fda.segment13,''-1'') = decode(fda.segment13,null,''-1'',gcc.segment13)
 and nvl(fda.segment14,''-1'') = decode(fda.segment14,null,''-1'',gcc.segment14)
 and nvl(fda.segment15,''-1'') = decode(fda.segment15,null,''-1'',gcc.segment15)
 and nvl(fda.segment16,''-1'') = decode(fda.segment16,null,''-1'',gcc.segment16)
 and nvl(fda.segment17,''-1'') = decode(fda.segment17,null,''-1'',gcc.segment17)
 and nvl(fda.segment18,''-1'') = decode(fda.segment18,null,''-1'',gcc.segment18)
 and nvl(fda.segment19,''-1'') = decode(fda.segment19,null,''-1'',gcc.segment19)
 and nvl(fda.segment20,''-1'') = decode(fda.segment20,null,''-1'',gcc.segment20)
 and nvl(fda.segment21,''-1'') = decode(fda.segment21,null,''-1'',gcc.segment21)
 and nvl(fda.segment22,''-1'') = decode(fda.segment22,null,''-1'',gcc.segment22)
 and nvl(fda.segment23,''-1'') = decode(fda.segment23,null,''-1'',gcc.segment23)
 and nvl(fda.segment24,''-1'') = decode(fda.segment24,null,''-1'',gcc.segment24)
 and nvl(fda.segment25,''-1'') = decode(fda.segment25,null,''-1'',gcc.segment25)
 and nvl(fda.segment26,''-1'') = decode(fda.segment26,null,''-1'',gcc.segment26)
 and nvl(fda.segment27,''-1'') = decode(fda.segment27,null,''-1'',gcc.segment27)
 and nvl(fda.segment28,''-1'') = decode(fda.segment28,null,''-1'',gcc.segment28)
 and nvl(fda.segment29,''-1'') = decode(fda.segment29,null,''-1'',gcc.segment29)
 and nvl(fda.segment30,''-1'') = decode(fda.segment30,null,''-1'',
gcc.segment30)';

  l_string := l_string1 || l_string2 || l_string3 ;
  l_cur:= dbms_sql.open_cursor;
  dbms_sql.parse(l_cur, l_string, DBMS_SQL.V7);

  dbms_sql.bind_variable(l_cur,':b_sob',p_set_bks_id);
  dbms_sql.bind_variable(l_cur,':b_start_date1',l_start_date1);
  dbms_sql.bind_variable(l_cur,':b_end_date1',l_end_date1);
  dbms_sql.bind_variable(l_cur,':b_gl_period',p_gl_period);
  dbms_sql.bind_variable(l_cur,':b_currency_code',l_currency_code);
  dbms_sql.bind_variable(l_cur,':b_bl_seg_name',bl_seg_name);

  l_row := dbms_sql.EXECUTE(l_cur);
  dbms_sql.close_cursor(l_cur);
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                l_module_name,'1. l_end_date1 : '||l_end_date1);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                  l_module_name,'1. NUMBER OF ROWS INSERTED: '||l_row);
 END IF;

   /* END for je_source is payables and je_category is treasury confirmation  */
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'End of Insert
for je_source is payables and je_category is treasury confirmation');

   /* Start for je_source is project and je_category is labour_cost */


 l_string2 := 'SELECT
                fv_sf1219_temp_s.NEXTVAL,
                glb.je_batch_id,
                ffp.fund_value,
                glb.name,
                :b_sob,
                glb.posted_date,
                gll.period_name,
                TO_CHAR(:b_start_date1,''MMYYYY''), -- reported_gl_period updated
                NVL(xal.unrounded_accounted_dr,0) - NVL(xal.unrounded_accounted_cr,0),    --NVL(gll.entered_dr,0) - NVL(gll.entered_cr,0),
                ''MANUAL'',                               -- default value
                LTRIM(RTRIM(xte.SOURCE_ID_INT_1)), -- expenditure_item_id
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,           -- reported month used for exceptions
                glb.default_period_name,
                NULL,   -- exception_category updated when exception occurred
                NULL,   -- accomplish_month derived during the process
                :b_end_date1,            -- accomplish date
                NULL,   -- obligation_date derived during the process
                NULL,           -- ia flag updated during the process
                fts.treasury_symbol,    -- no fund_value for null value(06/15)
                ffp.treasury_symbol_id, -- Added to fix Bug 1575992
                ''M'',                    -- Default record type as Manual
                ''N'',                    -- Default value for lines exist
                fda.agency_location_code,
                -1, --glb.org_id,
                NULL,           -- Group name assigned during the process
                NULL,           -- update type assigned during the process
                NULL,           -- type assigned during the process
                :b_gl_period,            -- gl period for which process is run
                ''N'',                    -- default processed flag
                SYSDATE,
                fnd_global.user_id,
                SYSDATE,
                fnd_global.user_id,
                fnd_global.login_id,
                gll.je_header_id,
                gll.je_line_num,
                glh.je_from_sla_flag
        FROM    gl_je_batches                   glb,
                gl_je_headers                   glh,
                gl_je_lines                     gll,
                gl_code_combinations            gcc,
                fv_sf1219_definitions_accts     fda,
                fv_fund_parameters              ffp,
                fv_treasury_symbols             fts,
                gl_import_references            glir,
                xla_ae_headers                  xah,
                xla_ae_lines                    xal,
                xla_events                      xet,
                xla_distribution_links          xdl,
                xla_transaction_entities        xte

        WHERE   gll.effective_date <= :b_end_date1
        AND     glh.currency_code = :b_currency_code
        AND     glb.status      = ''P''
        AND     glb.actual_flag = ''A''
        AND     glb.je_batch_id = glh.je_batch_id
        AND     glh.je_header_id = gll.je_header_id
        AND     gll.code_combination_id = gcc.code_combination_id
        --AND   gll.set_of_books_id     = p_set_bks_id
        AND     gll.ledger_id   = :b_sob
        AND     fda.set_of_books_id     = :b_sob
        AND     ffp.set_of_books_id     = :b_sob
        AND     fts.treasury_symbol_id  = ffp.treasury_symbol_id
        AND     fts.set_of_books_id     = :b_sob
        AND 	glh.je_source=''Project Accounting''
        AND 	glh.je_category = ''Labor Cost''
        AND     glh.je_from_sla_flag = ''Y''
        AND     glir.je_header_id = gll.je_header_id
        AND     glir.je_line_num = gll.je_line_num
        AND     xal.gl_sl_link_id = glir.gl_sl_link_id
        AND     xal.gl_sl_link_table = glir.gl_sl_link_table
        AND     xal.ae_header_id = xah.ae_header_id
        AND     xet.event_id = xah.event_id
        AND     xdl.event_id = xet.event_id
        AND     xdl.ae_header_id = xah.ae_header_id
        AND     xdl.ae_line_num = xal.ae_line_num
        AND 	xte.entity_id = xet.entity_id
        AND 	xte.entity_code =''EXPENDITURES''
        AND 	xdl.APPLICATION_ID = 275

        AND     decode(:b_bl_seg_name,''SEGMENT1'', gcc.segment1,
                                   ''SEGMENT2'', gcc.segment2,
                                   ''SEGMENT3'', gcc.segment3,
                                   ''SEGMENT4'', gcc.segment4,
                                   ''SEGMENT5'', gcc.segment5,
                                   ''SEGMENT6'', gcc.segment6,
                                   ''SEGMENT7'', gcc.segment7,
                                   ''SEGMENT8'', gcc.segment8,
                                   ''SEGMENT9'', gcc.segment9,
                                   ''SEGMENT10'', gcc.segment10,
                                   ''SEGMENT11'', gcc.segment11,
                                   ''SEGMENT12'', gcc.segment12,
                                   ''SEGMENT13'', gcc.segment13,
                                   ''SEGMENT14'', gcc.segment14,
                                   ''SEGMENT15'', gcc.segment15,
                                   ''SEGMENT16'', gcc.segment16,
                                   ''SEGMENT17'', gcc.segment17,
                                   ''SEGMENT18'', gcc.segment18,
                                   ''SEGMENT19'', gcc.segment19,
                                   ''SEGMENT20'', gcc.segment20,
                                   ''SEGMENT21'', gcc.segment21,
                                   ''SEGMENT22'', gcc.segment22,
                                   ''SEGMENT23'', gcc.segment23,
                                   ''SEGMENT24'', gcc.segment24,
                                   ''SEGMENT25'', gcc.segment25,
                                   ''SEGMENT26'', gcc.segment26,
                                   ''SEGMENT27'', gcc.segment27,
                                   ''SEGMENT28'', gcc.segment28,
                                   ''SEGMENT29'', gcc.segment29,
                                 ''SEGMENT30'', gcc.segment30) = ffp.fund_value
  and nvl(fda.segment1,''-1'') = decode(fda.segment1,null, ''-1'', gcc.segment1)
  and nvl(fda.segment2,''-1'') = decode(fda.segment2,null, ''-1'', gcc.segment2)
  and nvl(fda.segment3,''-1'') = decode(fda.segment3,null, ''-1'', gcc.segment3)
  and nvl(fda.segment4,''-1'') = decode(fda.segment4,null, ''-1'', gcc.segment4)
  and nvl(fda.segment5,''-1'') = decode(fda.segment5,null, ''-1'', gcc.segment5)
  and nvl(fda.segment6,''-1'') = decode(fda.segment6,null, ''-1'', gcc.segment6)
  and nvl(fda.segment7,''-1'') = decode(fda.segment7,null, ''-1'', gcc.segment7)
  and nvl(fda.segment8,''-1'') = decode(fda.segment8,null, ''-1'', gcc.segment8)
  and nvl(fda.segment9,''-1'') = decode(fda.segment9,null, ''-1'', gcc.segment9)
 and nvl(fda.segment10,''-1'') = decode(fda.segment10,null,''-1'',gcc.segment10)
 and nvl(fda.segment11,''-1'') = decode(fda.segment11,null,''-1'',gcc.segment11)
 and nvl(fda.segment12,''-1'') = decode(fda.segment12,null,''-1'',gcc.segment12)
 and nvl(fda.segment13,''-1'') = decode(fda.segment13,null,''-1'',gcc.segment13)
 and nvl(fda.segment14,''-1'') = decode(fda.segment14,null,''-1'',gcc.segment14)
 and nvl(fda.segment15,''-1'') = decode(fda.segment15,null,''-1'',gcc.segment15)
 and nvl(fda.segment16,''-1'') = decode(fda.segment16,null,''-1'',gcc.segment16)
 and nvl(fda.segment17,''-1'') = decode(fda.segment17,null,''-1'',gcc.segment17)
 and nvl(fda.segment18,''-1'') = decode(fda.segment18,null,''-1'',gcc.segment18)
 and nvl(fda.segment19,''-1'') = decode(fda.segment19,null,''-1'',gcc.segment19)
 and nvl(fda.segment20,''-1'') = decode(fda.segment20,null,''-1'',gcc.segment20)
 and nvl(fda.segment21,''-1'') = decode(fda.segment21,null,''-1'',gcc.segment21)
 and nvl(fda.segment22,''-1'') = decode(fda.segment22,null,''-1'',gcc.segment22)
 and nvl(fda.segment23,''-1'') = decode(fda.segment23,null,''-1'',gcc.segment23)
 and nvl(fda.segment24,''-1'') = decode(fda.segment24,null,''-1'',gcc.segment24)
 and nvl(fda.segment25,''-1'') = decode(fda.segment25,null,''-1'',gcc.segment25)
 and nvl(fda.segment26,''-1'') = decode(fda.segment26,null,''-1'',gcc.segment26)
 and nvl(fda.segment27,''-1'') = decode(fda.segment27,null,''-1'',gcc.segment27)
 and nvl(fda.segment28,''-1'') = decode(fda.segment28,null,''-1'',gcc.segment28)
 and nvl(fda.segment29,''-1'') = decode(fda.segment29,null,''-1'',gcc.segment29)
 and nvl(fda.segment30,''-1'') = decode(fda.segment30,null,''-1'',
gcc.segment30)';

  l_string := l_string1 || l_string2 || l_string3 ;
  l_cur:= dbms_sql.open_cursor;
  dbms_sql.parse(l_cur, l_string, DBMS_SQL.V7);

  dbms_sql.bind_variable(l_cur,':b_sob',p_set_bks_id);
  dbms_sql.bind_variable(l_cur,':b_start_date1',l_start_date1);
  dbms_sql.bind_variable(l_cur,':b_end_date1',l_end_date1);
  dbms_sql.bind_variable(l_cur,':b_gl_period',p_gl_period);
  dbms_sql.bind_variable(l_cur,':b_currency_code',l_currency_code);
  dbms_sql.bind_variable(l_cur,':b_bl_seg_name',bl_seg_name);

  l_row := dbms_sql.EXECUTE(l_cur);
  dbms_sql.close_cursor(l_cur);
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                l_module_name,'1. l_end_date1 : '||l_end_date1);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                  l_module_name,'1. NUMBER OF ROWS INSERTED: '||l_row);
  END IF;

   /* END for  je_source is project and je_category is labour_cost */

    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'End of Insert
for je_source is project and je_category is labour_cost');

 /* Start for je_source is Receivables, based on ar_cash_receipt_history_all */

l_string2 := 'SELECT
                fv_sf1219_temp_s.NEXTVAL,
                glb.je_batch_id,
                ffp.fund_value,
                glb.name,
                :b_sob,
                glb.posted_date,
                gll.period_name,
                TO_CHAR(:b_start_date1,''MMYYYY''), -- reported_gl_period updated
                NVL(xal.unrounded_accounted_dr,0) - NVL(xal.unrounded_accounted_cr,0),    --NVL(gll.entered_dr,0) - NVL(gll.entered_cr,0),
                ''MANUAL'',                               -- default value
                NULL,
                LTRIM(RTRIM(arch.cash_receipt_id)),
                NULL,
                NULL,
                LTRIM(RTRIM(arch.CASH_RECEIPT_HISTORY_ID)),
                NULL,
                NULL,
                NULL,           -- reported month used for exceptions
                glb.default_period_name,
                NULL,   -- exception_category updated when exception occurred
                NULL,   -- accomplish_month derived during the process
                :b_end_date1,            -- accomplish date
                NULL,   -- obligation_date derived during the process
                NULL,           -- ia flag updated during the process
                fts.treasury_symbol,    -- no fund_value for null value(06/15)
                ffp.treasury_symbol_id, -- Added to fix Bug 1575992
                ''M'',                    -- Default record type as Manual
                ''N'',                    -- Default value for lines exist
                fda.agency_location_code,
                -1, --glb.org_id,
                NULL,           -- Group name assigned during the process
                NULL,           -- update type assigned during the process
                NULL,           -- type assigned during the process
                :b_gl_period,            -- gl period for which process is run
                ''N'',                    -- default processed flag
                SYSDATE,
                fnd_global.user_id,
                SYSDATE,
                fnd_global.user_id,
                fnd_global.login_id,
                gll.je_header_id,
                gll.je_line_num,
                glh.je_from_sla_flag
        FROM    gl_je_batches                   glb,
                gl_je_headers                   glh,
                gl_je_lines                     gll,
                gl_code_combinations            gcc,
                fv_sf1219_definitions_accts     fda,
                fv_fund_parameters              ffp,
                fv_treasury_symbols             fts,
                ar_distributions_all  		ard,
                ar_cash_receipt_history_all  	arch,
                gl_import_references            glir,
                xla_ae_headers                  xah,
                xla_ae_lines                    xal,
                xla_events                      xet,
                xla_distribution_links          xdl,
                xla_transaction_entities  	xte

        WHERE   gll.effective_date <= :b_end_date1
        AND     glh.currency_code = :b_currency_code
        AND     glb.status      = ''P''
        AND     glb.actual_flag = ''A''
        AND     glb.je_batch_id = glh.je_batch_id
        AND     glh.je_header_id = gll.je_header_id
        AND     gll.code_combination_id = gcc.code_combination_id
        --AND   gll.set_of_books_id     = p_set_bks_id
        AND     gll.ledger_id   = :b_sob
        AND     fda.set_of_books_id     = :b_sob
        AND     ffp.set_of_books_id     = :b_sob
        AND     fts.treasury_symbol_id  = ffp.treasury_symbol_id
        AND     fts.set_of_books_id     = :b_sob
        AND 	glh.je_source=''Receivables''
        AND     glh.je_from_sla_flag = ''Y''
        AND     glir.je_header_id = gll.je_header_id
        AND     glir.je_line_num = gll.je_line_num
        AND     xal.gl_sl_link_id = glir.gl_sl_link_id
        AND     xal.gl_sl_link_table = glir.gl_sl_link_table
        AND     xal.ae_header_id = xah.ae_header_id
        AND     xet.event_id = xah.event_id
        AND 	xte.entity_id = xet.entity_id
        AND     xdl.event_id = xet.event_id
        AND     xdl.ae_header_id = xah.ae_header_id
        AND     xdl.ae_line_num = xal.ae_line_num
        AND 	xdl.source_distribution_type = ''AR_DISTRIBUTIONS_ALL''
        AND 	xdl.source_distribution_id_num_1 =  ard.line_id
        AND 	ard.source_table=''CRH''
        AND 	ard.source_id = arch.CASH_RECEIPT_HISTORY_ID
        AND 	xdl.APPLICATION_ID = 222

        AND     decode(:b_bl_seg_name,''SEGMENT1'', gcc.segment1,
                                   ''SEGMENT2'', gcc.segment2,
                                   ''SEGMENT3'', gcc.segment3,
                                   ''SEGMENT4'', gcc.segment4,
                                   ''SEGMENT5'', gcc.segment5,
                                   ''SEGMENT6'', gcc.segment6,
                                   ''SEGMENT7'', gcc.segment7,
                                   ''SEGMENT8'', gcc.segment8,
                                   ''SEGMENT9'', gcc.segment9,
                                   ''SEGMENT10'', gcc.segment10,
                                   ''SEGMENT11'', gcc.segment11,
                                   ''SEGMENT12'', gcc.segment12,
                                   ''SEGMENT13'', gcc.segment13,
                                   ''SEGMENT14'', gcc.segment14,
                                   ''SEGMENT15'', gcc.segment15,
                                   ''SEGMENT16'', gcc.segment16,
                                   ''SEGMENT17'', gcc.segment17,
                                   ''SEGMENT18'', gcc.segment18,
                                   ''SEGMENT19'', gcc.segment19,
                                   ''SEGMENT20'', gcc.segment20,
                                   ''SEGMENT21'', gcc.segment21,
                                   ''SEGMENT22'', gcc.segment22,
                                   ''SEGMENT23'', gcc.segment23,
                                   ''SEGMENT24'', gcc.segment24,
                                   ''SEGMENT25'', gcc.segment25,
                                   ''SEGMENT26'', gcc.segment26,
                                   ''SEGMENT27'', gcc.segment27,
                                   ''SEGMENT28'', gcc.segment28,
                                   ''SEGMENT29'', gcc.segment29,
                                 ''SEGMENT30'', gcc.segment30) = ffp.fund_value
  and nvl(fda.segment1,''-1'') = decode(fda.segment1,null, ''-1'', gcc.segment1)
  and nvl(fda.segment2,''-1'') = decode(fda.segment2,null, ''-1'', gcc.segment2)
  and nvl(fda.segment3,''-1'') = decode(fda.segment3,null, ''-1'', gcc.segment3)
  and nvl(fda.segment4,''-1'') = decode(fda.segment4,null, ''-1'', gcc.segment4)
  and nvl(fda.segment5,''-1'') = decode(fda.segment5,null, ''-1'', gcc.segment5)
  and nvl(fda.segment6,''-1'') = decode(fda.segment6,null, ''-1'', gcc.segment6)
  and nvl(fda.segment7,''-1'') = decode(fda.segment7,null, ''-1'', gcc.segment7)
  and nvl(fda.segment8,''-1'') = decode(fda.segment8,null, ''-1'', gcc.segment8)
  and nvl(fda.segment9,''-1'') = decode(fda.segment9,null, ''-1'', gcc.segment9)
 and nvl(fda.segment10,''-1'') = decode(fda.segment10,null,''-1'',gcc.segment10)
 and nvl(fda.segment11,''-1'') = decode(fda.segment11,null,''-1'',gcc.segment11)
 and nvl(fda.segment12,''-1'') = decode(fda.segment12,null,''-1'',gcc.segment12)
 and nvl(fda.segment13,''-1'') = decode(fda.segment13,null,''-1'',gcc.segment13)
 and nvl(fda.segment14,''-1'') = decode(fda.segment14,null,''-1'',gcc.segment14)
 and nvl(fda.segment15,''-1'') = decode(fda.segment15,null,''-1'',gcc.segment15)
 and nvl(fda.segment16,''-1'') = decode(fda.segment16,null,''-1'',gcc.segment16)
 and nvl(fda.segment17,''-1'') = decode(fda.segment17,null,''-1'',gcc.segment17)
 and nvl(fda.segment18,''-1'') = decode(fda.segment18,null,''-1'',gcc.segment18)
 and nvl(fda.segment19,''-1'') = decode(fda.segment19,null,''-1'',gcc.segment19)
 and nvl(fda.segment20,''-1'') = decode(fda.segment20,null,''-1'',gcc.segment20)
 and nvl(fda.segment21,''-1'') = decode(fda.segment21,null,''-1'',gcc.segment21)
 and nvl(fda.segment22,''-1'') = decode(fda.segment22,null,''-1'',gcc.segment22)
 and nvl(fda.segment23,''-1'') = decode(fda.segment23,null,''-1'',gcc.segment23)
 and nvl(fda.segment24,''-1'') = decode(fda.segment24,null,''-1'',gcc.segment24)
 and nvl(fda.segment25,''-1'') = decode(fda.segment25,null,''-1'',gcc.segment25)
 and nvl(fda.segment26,''-1'') = decode(fda.segment26,null,''-1'',gcc.segment26)
 and nvl(fda.segment27,''-1'') = decode(fda.segment27,null,''-1'',gcc.segment27)
 and nvl(fda.segment28,''-1'') = decode(fda.segment28,null,''-1'',gcc.segment28)
 and nvl(fda.segment29,''-1'') = decode(fda.segment29,null,''-1'',gcc.segment29)
 and nvl(fda.segment30,''-1'') = decode(fda.segment30,null,''-1'',
gcc.segment30)';

  l_string := l_string1 || l_string2 || l_string3 ;
  l_cur:= dbms_sql.open_cursor;
  dbms_sql.parse(l_cur, l_string, DBMS_SQL.V7);

  dbms_sql.bind_variable(l_cur,':b_sob',p_set_bks_id);
  dbms_sql.bind_variable(l_cur,':b_start_date1',l_start_date1);
  dbms_sql.bind_variable(l_cur,':b_end_date1',l_end_date1);
  dbms_sql.bind_variable(l_cur,':b_gl_period',p_gl_period);
  dbms_sql.bind_variable(l_cur,':b_currency_code',l_currency_code);
  dbms_sql.bind_variable(l_cur,':b_bl_seg_name',bl_seg_name);

  l_row := dbms_sql.EXECUTE(l_cur);
  dbms_sql.close_cursor(l_cur);
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                l_module_name,'1. l_end_date1 : '||l_end_date1);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                  l_module_name,'1. NUMBER OF ROWS INSERTED: '||l_row);
  END IF;

/* END for  je_source is Receivables, based on ar_cash_receipt_history_all*/

    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'End of Insert
for je_source is Receivables, based on ar_cash_receipt_history_all');

/* Start for je_source is Receivables, based on AR_RECEIVABLE_APPLICATIONS_ALL*/


 l_string2 := 'SELECT
                fv_sf1219_temp_s.NEXTVAL,
                glb.je_batch_id,
                ffp.fund_value,
                glb.name,
                :b_sob,
                glb.posted_date,
                gll.period_name,
                TO_CHAR(:b_start_date1,''MMYYYY''), -- reported_gl_period updated
                NVL(xal.unrounded_accounted_dr,0) - NVL(xal.unrounded_accounted_cr,0),    --NVL(gll.entered_dr,0) - NVL(gll.entered_cr,0),
                ''MANUAL'',                               -- default value
                NULL,
                LTRIM(RTRIM(arr.cash_receipt_id)),
                NULL,
                NULL,
                LTRIM(RTRIM(arr.receivable_application_id)),
                NULL,
                NULL,
                NULL,           -- reported month used for exceptions
                glb.default_period_name,
                NULL,   -- exception_category updated when exception occurred
                NULL,   -- accomplish_month derived during the process
                :b_end_date1,            -- accomplish date
                NULL,   -- obligation_date derived during the process
                NULL,           -- ia flag updated during the process
                fts.treasury_symbol,    -- no fund_value for null value(06/15)
                ffp.treasury_symbol_id, -- Added to fix Bug 1575992
                ''M'',                    -- Default record type as Manual
                ''N'',                    -- Default value for lines exist
                fda.agency_location_code,
                -1, --glb.org_id,
                NULL,           -- Group name assigned during the process
                NULL,           -- update type assigned during the process
                NULL,           -- type assigned during the process
                :b_gl_period,            -- gl period for which process is run
                ''N'',                    -- default processed flag
                SYSDATE,
                fnd_global.user_id,
                SYSDATE,
                fnd_global.user_id,
                fnd_global.login_id,
                gll.je_header_id,
                gll.je_line_num,
                glh.je_from_sla_flag
        FROM    gl_je_batches                   glb,
                gl_je_headers                   glh,
                gl_je_lines                     gll,
                gl_code_combinations            gcc,
                fv_sf1219_definitions_accts     fda,
                fv_fund_parameters              ffp,
                fv_treasury_symbols             fts,
                ar_distributions_all 		ard,
                AR_RECEIVABLE_APPLICATIONS_ALL 	arr,
                gl_import_references            glir,
                xla_ae_headers                  xah,
                xla_ae_lines                    xal,
                xla_events                      xet,
                xla_distribution_links          xdl,
                xla_transaction_entities  	xte

        WHERE   gll.effective_date <= :b_end_date1
        AND     glh.currency_code = :b_currency_code
        AND     glb.status      = ''P''
        AND     glb.actual_flag = ''A''
        AND     glb.je_batch_id = glh.je_batch_id
        AND     glh.je_header_id = gll.je_header_id
        AND     gll.code_combination_id = gcc.code_combination_id
        --AND   gll.set_of_books_id     = p_set_bks_id
        AND     gll.ledger_id   = :b_sob
        AND     fda.set_of_books_id     = :b_sob
        AND     ffp.set_of_books_id     = :b_sob
        AND     fts.treasury_symbol_id  = ffp.treasury_symbol_id
        AND     fts.set_of_books_id     = :b_sob
        AND 	glh.je_source=''Receivables''
        AND     glh.je_from_sla_flag = ''Y''
        AND     glir.je_header_id = gll.je_header_id
        AND     glir.je_line_num = gll.je_line_num
        AND     xal.gl_sl_link_id = glir.gl_sl_link_id
        AND     xal.gl_sl_link_table = glir.gl_sl_link_table
        AND     xal.ae_header_id = xah.ae_header_id
        AND     xet.event_id = xah.event_id
        AND 	xte.entity_id = xet.entity_id
        AND     xdl.event_id = xet.event_id
        AND     xdl.ae_header_id = xah.ae_header_id
        AND     xdl.ae_line_num = xal.ae_line_num
        AND 	xdl.source_distribution_type = ''AR_DISTRIBUTIONS_ALL''
        AND 	xdl.source_distribution_id_num_1 =  ard.line_id
        AND 	ard.source_table=''RA''
        AND 	ard.source_id = arr.receivable_application_id
        AND 	xdl.APPLICATION_ID = 222

        AND     decode(:b_bl_seg_name,''SEGMENT1'', gcc.segment1,
                                   ''SEGMENT2'', gcc.segment2,
                                   ''SEGMENT3'', gcc.segment3,
                                   ''SEGMENT4'', gcc.segment4,
                                   ''SEGMENT5'', gcc.segment5,
                                   ''SEGMENT6'', gcc.segment6,
                                   ''SEGMENT7'', gcc.segment7,
                                   ''SEGMENT8'', gcc.segment8,
                                   ''SEGMENT9'', gcc.segment9,
                                   ''SEGMENT10'', gcc.segment10,
                                   ''SEGMENT11'', gcc.segment11,
                                   ''SEGMENT12'', gcc.segment12,
                                   ''SEGMENT13'', gcc.segment13,
                                   ''SEGMENT14'', gcc.segment14,
                                   ''SEGMENT15'', gcc.segment15,
                                   ''SEGMENT16'', gcc.segment16,
                                   ''SEGMENT17'', gcc.segment17,
                                   ''SEGMENT18'', gcc.segment18,
                                   ''SEGMENT19'', gcc.segment19,
                                   ''SEGMENT20'', gcc.segment20,
                                   ''SEGMENT21'', gcc.segment21,
                                   ''SEGMENT22'', gcc.segment22,
                                   ''SEGMENT23'', gcc.segment23,
                                   ''SEGMENT24'', gcc.segment24,
                                   ''SEGMENT25'', gcc.segment25,
                                   ''SEGMENT26'', gcc.segment26,
                                   ''SEGMENT27'', gcc.segment27,
                                   ''SEGMENT28'', gcc.segment28,
                                   ''SEGMENT29'', gcc.segment29,
                                 ''SEGMENT30'', gcc.segment30) = ffp.fund_value
  and nvl(fda.segment1,''-1'') = decode(fda.segment1,null, ''-1'', gcc.segment1)
  and nvl(fda.segment2,''-1'') = decode(fda.segment2,null, ''-1'', gcc.segment2)
  and nvl(fda.segment3,''-1'') = decode(fda.segment3,null, ''-1'', gcc.segment3)
  and nvl(fda.segment4,''-1'') = decode(fda.segment4,null, ''-1'', gcc.segment4)
  and nvl(fda.segment5,''-1'') = decode(fda.segment5,null, ''-1'', gcc.segment5)
  and nvl(fda.segment6,''-1'') = decode(fda.segment6,null, ''-1'', gcc.segment6)
  and nvl(fda.segment7,''-1'') = decode(fda.segment7,null, ''-1'', gcc.segment7)
  and nvl(fda.segment8,''-1'') = decode(fda.segment8,null, ''-1'', gcc.segment8)
  and nvl(fda.segment9,''-1'') = decode(fda.segment9,null, ''-1'', gcc.segment9)
 and nvl(fda.segment10,''-1'') = decode(fda.segment10,null,''-1'',gcc.segment10)
 and nvl(fda.segment11,''-1'') = decode(fda.segment11,null,''-1'',gcc.segment11)
 and nvl(fda.segment12,''-1'') = decode(fda.segment12,null,''-1'',gcc.segment12)
 and nvl(fda.segment13,''-1'') = decode(fda.segment13,null,''-1'',gcc.segment13)
 and nvl(fda.segment14,''-1'') = decode(fda.segment14,null,''-1'',gcc.segment14)
 and nvl(fda.segment15,''-1'') = decode(fda.segment15,null,''-1'',gcc.segment15)
 and nvl(fda.segment16,''-1'') = decode(fda.segment16,null,''-1'',gcc.segment16)
 and nvl(fda.segment17,''-1'') = decode(fda.segment17,null,''-1'',gcc.segment17)
 and nvl(fda.segment18,''-1'') = decode(fda.segment18,null,''-1'',gcc.segment18)
 and nvl(fda.segment19,''-1'') = decode(fda.segment19,null,''-1'',gcc.segment19)
 and nvl(fda.segment20,''-1'') = decode(fda.segment20,null,''-1'',gcc.segment20)
 and nvl(fda.segment21,''-1'') = decode(fda.segment21,null,''-1'',gcc.segment21)
 and nvl(fda.segment22,''-1'') = decode(fda.segment22,null,''-1'',gcc.segment22)
 and nvl(fda.segment23,''-1'') = decode(fda.segment23,null,''-1'',gcc.segment23)
 and nvl(fda.segment24,''-1'') = decode(fda.segment24,null,''-1'',gcc.segment24)
 and nvl(fda.segment25,''-1'') = decode(fda.segment25,null,''-1'',gcc.segment25)
 and nvl(fda.segment26,''-1'') = decode(fda.segment26,null,''-1'',gcc.segment26)
 and nvl(fda.segment27,''-1'') = decode(fda.segment27,null,''-1'',gcc.segment27)
 and nvl(fda.segment28,''-1'') = decode(fda.segment28,null,''-1'',gcc.segment28)
 and nvl(fda.segment29,''-1'') = decode(fda.segment29,null,''-1'',gcc.segment29)
 and nvl(fda.segment30,''-1'') = decode(fda.segment30,null,''-1'',
gcc.segment30)';

  l_string := l_string1 || l_string2 || l_string3 ;
  l_cur:= dbms_sql.open_cursor;
  dbms_sql.parse(l_cur, l_string, DBMS_SQL.V7);

  dbms_sql.bind_variable(l_cur,':b_sob',p_set_bks_id);
  dbms_sql.bind_variable(l_cur,':b_start_date1',l_start_date1);
  dbms_sql.bind_variable(l_cur,':b_end_date1',l_end_date1);
  dbms_sql.bind_variable(l_cur,':b_gl_period',p_gl_period);
  dbms_sql.bind_variable(l_cur,':b_currency_code',l_currency_code);
  dbms_sql.bind_variable(l_cur,':b_bl_seg_name',bl_seg_name);

  l_row := dbms_sql.EXECUTE(l_cur);
  dbms_sql.close_cursor(l_cur);
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                l_module_name,'1. l_end_date1 : '||l_end_date1);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                  l_module_name,'1. NUMBER OF ROWS INSERTED: '||l_row);
  END IF;

 /* END for je_source is Receivables, based on AR_RECEIVABLE_APPLICATIONS_ALL */

   fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'End of Insert
for je_source is Receivables , based on AR_RECEIVABLE_APPLICATIONS_ALL ');

/* Start for je_source is Receivables, based on AR_MISC_CASH_DISTRIBUTIONS_ALL */

l_string2 := 'SELECT
                fv_sf1219_temp_s.NEXTVAL,
                glb.je_batch_id,
                ffp.fund_value,
                glb.name,
                :b_sob,
                glb.posted_date,
                gll.period_name,
                TO_CHAR(:b_start_date1,''MMYYYY''), -- reported_gl_period updated
                NVL(xal.unrounded_accounted_dr,0) - NVL(xal.unrounded_accounted_cr,0),    --NVL(gll.entered_dr,0) - NVL(gll.entered_cr,0),
                ''MANUAL'',                               -- default value
                NULL,
                LTRIM(RTRIM(arm.cash_receipt_id)),
                NULL,
                NULL,
                LTRIM(RTRIM(arm.MISC_CASH_DISTRIBUTION_ID)),--cash_receipt_hist_id
                NULL,
                NULL,
                NULL,           -- reported month used for exceptions
                glb.default_period_name,
                NULL,   -- exception_category updated when exception occurred
                NULL,   -- accomplish_month derived during the process
                :b_end_date1,            -- accomplish date
                NULL,   -- obligation_date derived during the process
                NULL,           -- ia flag updated during the process
                fts.treasury_symbol,    -- no fund_value for null value(06/15)
                ffp.treasury_symbol_id, -- Added to fix Bug 1575992
                ''M'',                    -- Default record type as Manual
                ''N'',                    -- Default value for lines exist
                fda.agency_location_code,
                -1, --glb.org_id,
                NULL,           -- Group name assigned during the process
                NULL,           -- update type assigned during the process
                NULL,           -- type assigned during the process
                :b_gl_period,            -- gl period for which process is run
                ''N'',                    -- default processed flag
                SYSDATE,
                fnd_global.user_id,
                SYSDATE,
                fnd_global.user_id,
                fnd_global.login_id,
                gll.je_header_id,
                gll.je_line_num,
                glh.je_from_sla_flag
        FROM    gl_je_batches                   glb,
                gl_je_headers                   glh,
                gl_je_lines                     gll,
                gl_code_combinations            gcc,
                fv_sf1219_definitions_accts     fda,
                fv_fund_parameters              ffp,
                fv_treasury_symbols             fts,
                ar_distributions_all  		ard,
                AR_MISC_CASH_DISTRIBUTIONS_ALL 	arm,
                gl_import_references            glir,
                xla_ae_headers                  xah,
                xla_ae_lines                    xal,
                xla_events                      xet,
                xla_distribution_links          xdl,
                xla_transaction_entities  	xte

        WHERE   gll.effective_date <= :b_end_date1
        AND     glh.currency_code = :b_currency_code
        AND     glb.status      = ''P''
        AND     glb.actual_flag = ''A''
        AND     glb.je_batch_id = glh.je_batch_id
        AND     glh.je_header_id = gll.je_header_id
        AND     gll.code_combination_id = gcc.code_combination_id
        --AND   gll.set_of_books_id     = p_set_bks_id
        AND     gll.ledger_id   = :b_sob
        AND     fda.set_of_books_id     = :b_sob
        AND     ffp.set_of_books_id     = :b_sob
        AND     fts.treasury_symbol_id  = ffp.treasury_symbol_id
        AND     fts.set_of_books_id     = :b_sob
        AND     glh.je_source=''Receivables''
        AND     glh.je_from_sla_flag = ''Y''
        AND     glir.je_header_id = gll.je_header_id
        AND     glir.je_line_num = gll.je_line_num
        AND     xal.gl_sl_link_id = glir.gl_sl_link_id
        AND     xal.gl_sl_link_table = glir.gl_sl_link_table
        AND     xal.ae_header_id = xah.ae_header_id
        AND     xet.event_id = xah.event_id
        AND 	xte.entity_id = xet.entity_id
        AND     xdl.event_id = xet.event_id
        AND     xdl.ae_header_id = xah.ae_header_id
        AND     xdl.ae_line_num = xal.ae_line_num
        AND 	xdl.source_distribution_type = ''AR_DISTRIBUTIONS_ALL''
        AND 	xdl.source_distribution_id_num_1 =  ard.line_id
        AND 	ard.source_id = arm.MISC_CASH_DISTRIBUTION_ID
        AND 	ard.source_table=''MCD''
        AND 	xdl.APPLICATION_ID = 222

        AND     decode(:b_bl_seg_name,''SEGMENT1'', gcc.segment1,
                                   ''SEGMENT2'', gcc.segment2,
                                   ''SEGMENT3'', gcc.segment3,
                                   ''SEGMENT4'', gcc.segment4,
                                   ''SEGMENT5'', gcc.segment5,
                                   ''SEGMENT6'', gcc.segment6,
                                   ''SEGMENT7'', gcc.segment7,
                                   ''SEGMENT8'', gcc.segment8,
                                   ''SEGMENT9'', gcc.segment9,
                                   ''SEGMENT10'', gcc.segment10,
                                   ''SEGMENT11'', gcc.segment11,
                                   ''SEGMENT12'', gcc.segment12,
                                   ''SEGMENT13'', gcc.segment13,
                                   ''SEGMENT14'', gcc.segment14,
                                   ''SEGMENT15'', gcc.segment15,
                                   ''SEGMENT16'', gcc.segment16,
                                   ''SEGMENT17'', gcc.segment17,
                                   ''SEGMENT18'', gcc.segment18,
                                   ''SEGMENT19'', gcc.segment19,
                                   ''SEGMENT20'', gcc.segment20,
                                   ''SEGMENT21'', gcc.segment21,
                                   ''SEGMENT22'', gcc.segment22,
                                   ''SEGMENT23'', gcc.segment23,
                                   ''SEGMENT24'', gcc.segment24,
                                   ''SEGMENT25'', gcc.segment25,
                                   ''SEGMENT26'', gcc.segment26,
                                   ''SEGMENT27'', gcc.segment27,
                                   ''SEGMENT28'', gcc.segment28,
                                   ''SEGMENT29'', gcc.segment29,
                                 ''SEGMENT30'', gcc.segment30) = ffp.fund_value
  and nvl(fda.segment1,''-1'') = decode(fda.segment1,null, ''-1'', gcc.segment1)
  and nvl(fda.segment2,''-1'') = decode(fda.segment2,null, ''-1'', gcc.segment2)
  and nvl(fda.segment3,''-1'') = decode(fda.segment3,null, ''-1'', gcc.segment3)
  and nvl(fda.segment4,''-1'') = decode(fda.segment4,null, ''-1'', gcc.segment4)
  and nvl(fda.segment5,''-1'') = decode(fda.segment5,null, ''-1'', gcc.segment5)
  and nvl(fda.segment6,''-1'') = decode(fda.segment6,null, ''-1'', gcc.segment6)
  and nvl(fda.segment7,''-1'') = decode(fda.segment7,null, ''-1'', gcc.segment7)
  and nvl(fda.segment8,''-1'') = decode(fda.segment8,null, ''-1'', gcc.segment8)
  and nvl(fda.segment9,''-1'') = decode(fda.segment9,null, ''-1'', gcc.segment9)
 and nvl(fda.segment10,''-1'') = decode(fda.segment10,null,''-1'',gcc.segment10)
 and nvl(fda.segment11,''-1'') = decode(fda.segment11,null,''-1'',gcc.segment11)
 and nvl(fda.segment12,''-1'') = decode(fda.segment12,null,''-1'',gcc.segment12)
 and nvl(fda.segment13,''-1'') = decode(fda.segment13,null,''-1'',gcc.segment13)
 and nvl(fda.segment14,''-1'') = decode(fda.segment14,null,''-1'',gcc.segment14)
 and nvl(fda.segment15,''-1'') = decode(fda.segment15,null,''-1'',gcc.segment15)
 and nvl(fda.segment16,''-1'') = decode(fda.segment16,null,''-1'',gcc.segment16)
 and nvl(fda.segment17,''-1'') = decode(fda.segment17,null,''-1'',gcc.segment17)
 and nvl(fda.segment18,''-1'') = decode(fda.segment18,null,''-1'',gcc.segment18)
 and nvl(fda.segment19,''-1'') = decode(fda.segment19,null,''-1'',gcc.segment19)
 and nvl(fda.segment20,''-1'') = decode(fda.segment20,null,''-1'',gcc.segment20)
 and nvl(fda.segment21,''-1'') = decode(fda.segment21,null,''-1'',gcc.segment21)
 and nvl(fda.segment22,''-1'') = decode(fda.segment22,null,''-1'',gcc.segment22)
 and nvl(fda.segment23,''-1'') = decode(fda.segment23,null,''-1'',gcc.segment23)
 and nvl(fda.segment24,''-1'') = decode(fda.segment24,null,''-1'',gcc.segment24)
 and nvl(fda.segment25,''-1'') = decode(fda.segment25,null,''-1'',gcc.segment25)
 and nvl(fda.segment26,''-1'') = decode(fda.segment26,null,''-1'',gcc.segment26)
 and nvl(fda.segment27,''-1'') = decode(fda.segment27,null,''-1'',gcc.segment27)
 and nvl(fda.segment28,''-1'') = decode(fda.segment28,null,''-1'',gcc.segment28)
 and nvl(fda.segment29,''-1'') = decode(fda.segment29,null,''-1'',gcc.segment29)
 and nvl(fda.segment30,''-1'') = decode(fda.segment30,null,''-1'',
gcc.segment30)';

  l_string := l_string1 || l_string2 || l_string3 ;
  l_cur:= dbms_sql.open_cursor;
  dbms_sql.parse(l_cur, l_string, DBMS_SQL.V7);

  dbms_sql.bind_variable(l_cur,':b_sob',p_set_bks_id);
  dbms_sql.bind_variable(l_cur,':b_start_date1',l_start_date1);
  dbms_sql.bind_variable(l_cur,':b_end_date1',l_end_date1);
  dbms_sql.bind_variable(l_cur,':b_gl_period',p_gl_period);
  dbms_sql.bind_variable(l_cur,':b_currency_code',l_currency_code);
  dbms_sql.bind_variable(l_cur,':b_bl_seg_name',bl_seg_name);

  l_row := dbms_sql.EXECUTE(l_cur);
  dbms_sql.close_cursor(l_cur);
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                l_module_name,'1. l_end_date1 : '||l_end_date1);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                  l_module_name,'1. NUMBER OF ROWS INSERTED: '||l_row);
  END IF;

/* END for je_source is Receivables, based on AR_MISC_CASH_DISTRIBUTIONS_ALL */

    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'End of Insert
for je_source is Receivables , based on AR_MISC_CASH_DISTRIBUTIONS_ALL ');


   no_of_tran := 0;

    -- Get the count of the number of records in the temp table.
    SELECT      count(*)
    INTO        no_of_tran
    FROM        fv_sf1219_temp
    WHERE       set_of_books_id = p_set_bks_id ;

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    '2. l_end_date1 : '||l_end_date1);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    '2. NUMBER OF ROWS INSERTED: '||no_of_tran);
 END IF;

EXCEPTION
   WHEN OTHERS THEN
     p_error_code := 2;
     p_error_msg := SQLERRM || ' -- Error in INSERT_BATCHES procedure.';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
          l_module_name||'.final_exception',p_error_msg);
END INSERT_BATCHES;


-----------------------------------------------------------------------------
--		PROCEDURE PROCESS_1219_TRANSACTIONS
-----------------------------------------------------------------------------
-- Each record of temp table is processed to find other relevant information
-- like accomplished date, date of obligation of the transaction required for
-- 1219/1220 reports. SF1219 Record type is arrived for each record. At the
-- end of this procedure this information is updated in fv_sf1219_temp table.
--
-- Different record types used during the process are :
-- A - Auto, records which are assigned with a record type
-- M - Manual, records which could not be assigned to a record type
-- N - New, records entered using Transactions Correction Form  with group /
--     line assignments
-- E - Exception, records inserted during the process because of exceptions
-- O - Omitted, records caused the exception and hence not to be reported
-- R - Records with ALC_code as null.
-- P - Contains Reported GL Period and Legal Entity information.
--     Indicates that the pre-process has been run before TCF or 1219 Report.
-----------------------------------------------------------------------------
PROCEDURE PROCESS_1219_TRANSACTIONS IS
  	l_module_name 	    VARCHAR2(200);
	l_reference	    NUMBER;
	l_org_amount	    NUMBER;
	v_je_source	    gl_je_headers.je_source%TYPE;
	v_je_category	    gl_je_headers.je_category%TYPE;
	l_rev_cash_recpt_id gl_je_lines.reference_2%TYPE;
	l_exists	    VARCHAR2(1);
	vl_misc_cd_flag     VARCHAR2(1) := 'N';
	p_def_p_ia_paygroup VARCHAR2(30);
	l_inv_pay_id 	    NUMBER(15) := 0;
	l_void_incomplete   VARCHAR2(1) := 'N';
BEGIN

-- Whenever pre-process is run, one record with reported_gl_period will be
-- inserted, irrespective of whether pre-process produces any record or not.
-- This record will enable to produce appropriate message/output to indicate
-- whether pre-process has been run, in Transaction Correction Form and 1219
-- Report. For convenience, org_id column will be populated with
-- Legal Entity, for this record ONLY.
  	l_module_name  := g_module_name || 'PROCESS_1219_TRANSACTIONS';
        INSERT INTO fv_sf1219_temp (
                        temp_record_id,
                        batch_id,
                        fund_code,
                        name,
                        set_of_books_id,
                        gl_period,
                        reported_gl_period,
                        reported_month,
                        record_type,
			lines_exist,
			alc_code,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        last_update_login)
        VALUES          (
                        fv_sf1219_temp_s.NEXTVAL,
                        0,
                        'NO FUND',
                        'P Batch',
                        p_set_bks_id,
                        p_gl_period,
                        TO_CHAR(l_start_date1,'MMYYYY'),
                        TO_CHAR(l_start_date1,'MMYYYY'),
                        'P',
			'N',
			p_alc_code,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			FND_GLOBAL.LOGIN_ID);

	COMMIT;

	-----------------------------------------------------------------------
	-- PROCESSING BEGINS HERE WITH POPULATING THE Main Cursor TEMP_CURSOR
	-----------------------------------------------------------------------
        SELECT count(*)
        INTO transaction_count
        FROM fv_sf1219_temp
        WHERE record_type NOT IN ('P', 'N');

       IF transaction_count = 0
       THEN
           p_error_code := 0;
           p_error_msg := 'No transaction activity for this period';
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
                                  l_module_name||'.error1',p_error_msg);
           RETURN;
       ELSE
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                      'FOUND '||TRANSACTION_COUNT||' RECORD(S).');
 END IF;
       END IF;

       -- Determine the default paygroup based on the org_id
       BEGIN
          SELECT payables_ia_paygroup
          INTO   p_def_p_ia_paygroup
          FROM   FV_Operating_units_all
          WHERE  org_id = p_def_org_id;
       EXCEPTION
          WHEN No_Data_Found THEN
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||
               '.error2','PAYABLES IA PAYGROUP NOT FOUND, BASED ON THE ORG_ID '
               ||TO_CHAR(P_DEF_ORG_ID));

          WHEN OTHERS THEN
            p_error_code := 2;
            p_error_msg := SQLERRM || '-- Error in '||
                          'Process_1219_Transactions procedure '||
                         'while determining the payables ia paygroup.';
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
                                  l_module_name||'.error3',p_error_msg);
       END ;

       OPEN TEMP_CURSOR;
       IF (sqlcode < 0) THEN
	  p_error_code := sqlcode;
	  p_error_msg := sqlerrm;
       END IF;

       LOOP
 	   FETCH TEMP_CURSOR INTO
		l_rowid,
		l_batch_id,
		l_fund_code,
		l_name,
		l_posted_date,
		l_gl_period,
		l_amount,
		l_sf1219_type_code,
		l_reference_1,
		l_reference_2,
		l_reference_3,
		l_reference_4,
		l_reference_5,
		l_reference_6,
		l_reference_9,
		l_reported_month,
		l_exception_category,
		l_accomplish_month,
		l_accomplish_date,
		l_obligation_date,
		l_inter_agency_flag,
		l_treasury_symbol,
		l_treasury_symbol_id,
		l_record_type,
		l_lines_exist,
		l_alc_code,
		l_org_id,
		l_update_type,
		l_type,
		l_gl_period_name,
		l_processed_flag,
		l_je_header_id,
		l_je_line_num,
                l_je_from_sla_flag ;

	IF (TEMP_CURSOR%NOTFOUND)
        THEN
	   EXIT;
	END IF;

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                      l_module_name,'');
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
      l_module_name,'-------------------------------------------');
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_BATCH_ID: '||L_BATCH_ID);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_FUND_CODE: '||L_FUND_CODE);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_NAME: '||L_NAME);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_POSTED_DATE: '||L_POSTED_DATE);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_GL_PERIOD: '||L_GL_PERIOD);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_AMOUNT: '||L_AMOUNT);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_SF1219_TYPE_CODE: '||L_SF1219_TYPE_CODE);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_REFERENCE_1: '||L_REFERENCE_1);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_REFERENCE_2: '||L_REFERENCE_2);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_REFERENCE_3: '||L_REFERENCE_3);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_REFERENCE_4: '||L_REFERENCE_4);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_REFERENCE_5: '||L_REFERENCE_5);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_REFERENCE_6: '||L_REFERENCE_6);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_REFERENCE_9: '||L_REFERENCE_9);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_REPORTED_MONTH: '||L_REPORTED_MONTH);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_EXCEPTION_CATEGORY: '||L_EXCEPTION_CATEGORY);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_ACCOMPLISH_MONTH: '||L_ACCOMPLISH_MONTH);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_ACCOMPLISH_DATE: '||L_ACCOMPLISH_DATE);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_OBLIGATION_DATE: '||L_OBLIGATION_DATE);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_INTER_AGENCY_FLAG: '||L_INTER_AGENCY_FLAG);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_TREASURY_SYMBOL_ID: '||L_TREASURY_SYMBOL_ID);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_RECORD_TYPE: '||L_RECORD_TYPE);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_LINES_EXIST: '||L_LINES_EXIST);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_ALC_CODE: '||L_ALC_CODE);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_ORG_ID: '||L_ORG_ID);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_UPDATE_TYPE: '||L_UPDATE_TYPE);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_TYPE: '||L_TYPE);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_GL_PERIOD_NAME: '||L_GL_PERIOD_NAME);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_PROCESSED_FLAG: '||L_PROCESSED_FLAG);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_JE_HEADER_ID: '||L_JE_HEADER_ID);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_JE_LINE_NUM: '||L_JE_LINE_NUM);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
    l_module_name,'L_JE_FROM_SLA_FLAG: '||L_JE_FROM_SLA_FLAG);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'');
 END IF;

	-----------------------------------------------------------------------
	-- Initializing Variables
	-----------------------------------------------------------------------
	l_name_keep		:= l_name;
	l_name			:= upper(l_name);
	l_processed_flag	:= 'N';
 	l_org_amount 		:= l_amount;
 	l_inter_agency_flag	:= 'N';
 	x_amount 		:= abs(l_amount);
 	l_exception_category 	:= null;
 	l_billing_agency_fund 	:= null;
	l_reported_gl_period	:= to_char(l_start_date1,'MMYYYY');
 	l_accomplish_date 	:= l_end_date1;
	l_type			:= null;
	l_update_type		:= null;

	-- Get journal source and category
	BEGIN
	    SELECT je_source, je_category
            INTO   v_je_source, v_je_category
	    FROM   gl_je_headers
	    WHERE  je_header_id = l_je_header_id;
	EXCEPTION
	    WHEN OTHERS THEN
	      p_error_code := -1;
	      p_error_msg  := SUBSTR(sqlerrm,1,50||
                                    ': while fetching journal source');
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
                          l_module_name||'.error10',p_error_msg);
      	      RETURN;
	END;

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                            l_module_name,'SOURCE: '||V_JE_SOURCE);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                            l_module_name,'CATEGORY: '||V_JE_CATEGORY);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'');
 END IF;

        -----------------------------------------------------------------------------------
        -- Determine if the reference values for each row are not null and valid. Otherwise
	-- assign a value of MANUAL to l_name.
	-----------------------------------------------------------------------------------
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                    l_module_name,'-> CHECK FOR MANUAL ...');
 END IF;

	-- Accomplish date is obtained for records with batch name like TREASURY

	-- Reference Validity Check


       -- Adi


       -- Check to see if the journal is from SLA
       --
      IF l_je_from_sla_flag IN ('N', 'U') THEN
 	IF (v_je_source = 'Budgetary Transaction' AND
	     v_je_category = 'Treasury Confirmation')	-- Budgetary Transaction, = TC
	THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
            ' PROCESSING SOURCE = Budgetary Transaction, CATEGORY = TREASURY CONFIRMATION');
        END IF;

        IF l_reference_1 IS NULL AND l_reference_6 IS NULL  -- ref1
	    THEN
              l_name := 'MANUAL';
           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                  l_module_name,' REF_1 AND REF_6 ARE BOTH NULL, HENCE MANUAL');
           END IF;
        ELSIF l_reference_1 IS NOT NULL THEN
                BEGIN
                    SELECT 'Y'
                    INTO   l_exists
                    FROM   Fv_treasury_confirmations_all
                    WHERE  treasury_confirmation_id = to_number(l_reference_1)
		    AND org_id = p_def_org_id;

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                       l_name := 'MANUAL';
           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                       l_module_name,
                    '     NO_DATA_FOUND WHEN SELECTING FROM '||
                    'FV_TREASURY_CONFIRMATIONS_ALL WITH REF_1, HENCE MANUAL');
           END IF;

                    When INVALID_NUMBER OR VALUE_ERROR THEN
                       l_name := 'MANUAL';
           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                          '      INVALID NUMBER ERROR, HENCE MANUAL');
           END IF;
                END ;
	ELSE
               IF l_reference_3 IS NULL				   -- ref3
	       THEN
	   	  l_name := 'MANUAL';
               ELSE
                   BEGIN
                      SELECT 'Y'
                      INTO   l_exists
                      FROM   ap_checks_all
                      WHERE  check_id  = to_number(l_REFERENCE_3)
		      AND    org_id = p_def_org_id;

                   EXCEPTION
                      WHEN NO_DATA_FOUND THEN
			 l_name := 'MANUAL';
           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                ' NO_DATA_FOUND WHEN SELECTING '||
                                'FROM AP_CHECKS_ALL WITH REF_3, HENCE MANUAL');
           END IF;

                      WHEN INVALID_NUMBER OR VALUE_ERROR THEN
			 l_name := 'MANUAL';
           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                      l_module_name,
                                      '  INVALID NUMBER ERROR, HENCE MANUAL');
           END IF;
                   END;

	IF (l_reference_1 IS NULL) AND (l_reference_6 IS NOT NULL) -- ref1,ref6
		   THEN
		      BEGIN
			 -- If ref_1 is NULL and ref_3 is not NULL,
                         -- accomplish_date value comes from ref_6.
			 -- The following check will ensure that ref_6
			 -- does not get an invalid value and causes
                         -- 1219/1220 process to error.

		         l_ref6_date_check := l_reference_6;
		      EXCEPTION
			 WHEN OTHERS THEN
			    l_name := 'MANUAL';
			    IF (FND_LOG.LEVEL_STATEMENT >=
                                         FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 				FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                                      l_module_name,
                                                      '      INVALID VALUE '||
                                                      ' FOR REF_6, ' ||
                                                      ' HENCE MANUAL');
                            END IF;
		      END;
		   END IF;			      -- ref1, ref6
            	END IF;				    -- ref3
            END IF;				  -- ref1

	ELSIF (v_je_source = 'Payables'
            AND v_je_category <> 'Treasury Confirmation') -- Payables, <> TC
	THEN
           -- Check if ref_2/3/9 is NULL. If not, does it have a valid value.
           -- Else l_name is Manual.
            IF (FND_LOG.LEVEL_STATEMENT
                           >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                          l_module_name,
                                          '   PROCESSING SOURCE = PAYABLES, '||
                                         ' CATEGORY <> TREASURY CONFIRMATION');
            END IF;

	   IF (l_reference_2 IS NULL)				-- ref2
	   THEN
	       l_name := 'MANUAL';
                  IF (FND_LOG.LEVEL_STATEMENT >=
                                  FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                        l_module_name,'  REF_2 IS NULL');
                  END IF;
	   ELSE
             BEGIN
                SELECT 'Y'
                INTO   l_exists
                FROM   ap_invoices_all
                WHERE  invoice_id = TO_NUMBER(l_reference_2)
		AND    org_id = p_def_org_id;

             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   l_name := 'MANUAL';
                  IF (FND_LOG.LEVEL_STATEMENT >=
                                 FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                         l_module_name,
                                         ' NO_DATA_FOUND WHEN SELECTING' ||
                                         ' FROM AP_INVOICES_ALL WITH REF_2, '||
                                         ' HENCE MANUAL');
                  END IF;

                WHEN INVALID_NUMBER OR VALUE_ERROR THEN
	    	   l_name := 'MANUAL';
                   IF (FND_LOG.LEVEL_STATEMENT >=
                                 FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                              l_module_name,
                                              ' INVALID NUMBER ERROR, '||
                                              ' HENCE MANUAL');
                   END IF;
             END;
	   END IF;						-- ref2

	   IF (l_reference_3 IS NULL)				-- ref3
           THEN
               l_name := 'MANUAL';
               IF (FND_LOG.LEVEL_STATEMENT >=
                             FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                             l_module_name,'  REF_3 IS NULL');
               END IF;
           ELSE
              BEGIN
                 SELECT 'Y'
                 INTO   l_exists
                 FROM   ap_checks_all
                 WHERE  check_id  = to_number(l_REFERENCE_3)
		 AND    org_id = p_def_org_id;

              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                       l_name := 'MANUAL';
                  IF (FND_LOG.LEVEL_STATEMENT >=
                                 FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                            l_module_name,
                                            '      NO_DATA_FOUND WHEN '||
                                            ' SELECTING FROM AP_CHECKS_ALL '||
                                            ' WITH REF_3, HENCE MANUAL');
                  END IF;

                 WHEN INVALID_NUMBER OR VALUE_ERROR THEN
                    l_name := 'MANUAL';
                    IF (FND_LOG.LEVEL_STATEMENT >=
                                     FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                              l_module_name,'      INVALID '||
                                               'NUMBER ERROR, HENCE MANUAL');
                    END IF;
              END;
	   END IF;						-- ref3

           IF (l_reference_9 IS NULL)				-- ref9
           THEN
               l_name := 'MANUAL';
               IF (FND_LOG.LEVEL_STATEMENT >=
                          FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                       l_module_name,'  REF_9 IS NULL');
               END IF;
           ELSE
              BEGIN
                SELECT 'Y'
                INTO   l_exists
                FROM   ap_invoice_payments_all
                WHERE  invoice_payment_id  = to_number(l_REFERENCE_9)
		AND    org_id = p_def_org_id;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   l_name := 'MANUAL';
                   IF (FND_LOG.LEVEL_STATEMENT
                               >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                      l_module_name,'      NO_DATA_FOUND ' ||
                                      ' WHEN SELECTING FROM ' ||
                                      ' AP_INVOICE_PAYMENTS_ALL ' ||
                                      ' WITH REF_9, HENCE MANUAL');
                   END IF;

                WHEN INVALID_NUMBER OR VALUE_ERROR THEN
                 l_name := 'MANUAL';
                    IF (FND_LOG.LEVEL_STATEMENT >=
                                        FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                               l_module_name,
                              '      INVALID NUMBER ERROR, HENCE MANUAL');
                    END IF;
              END;
	   END IF;						-- ref9

	ELSIF (v_je_source = 'Receivables')			-- Receivables
	THEN
          vl_misc_cd_flag := 'N';

          IF (v_je_category = 'Misc Receipts')           -- Misc Receipts
	  THEN
                IF (FND_LOG.LEVEL_STATEMENT >=
                           FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                l_module_name,'   PROCESSING A MISC RECEIPT');
            END IF;

	    BEGIN
               l_cash_receipt_id := l_reference_2;
               l_cash_receipt_hist_id := l_reference_5;
            EXCEPTION
                WHEN INVALID_NUMBER OR VALUE_ERROR
                THEN
                    l_name := 'MANUAL';
                    IF (FND_LOG.LEVEL_STATEMENT >=
                              FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                                      l_module_name,
                                '      INVALID NUMBER ERROR, HENCE MANUAL');
                    END IF;
            END;

          ELSE
                IF (FND_LOG.LEVEL_STATEMENT >=
                           FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                           l_module_name,
                              '   PROCESSING A TRADE RECEIPT OR OTHER');
            END IF;

	    BEGIN
               l_cash_receipt_id := SUBSTR(l_reference_2,0,
                                            INSTR(l_reference_2,'C')-1);
               l_cash_receipt_hist_id := SUBSTR(l_reference_2,
                                           INSTR(l_reference_2,'C')+1,
                                               LENGTH(l_reference_2));
	    EXCEPTION
		WHEN INVALID_NUMBER OR VALUE_ERROR
		THEN
		    l_name := 'MANUAL';
		    IF (FND_LOG.LEVEL_STATEMENT >=
                                       FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
			 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                                    l_module_name,
                                  '      INVALID NUMBER ERROR, HENCE MANUAL');
                    END IF;
	    END;
          END IF;                                               -- Misc Receipts

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                           l_module_name,'    REFERENCE_2 = '||L_REFERENCE_2);
                       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                   l_module_name,'    CASH RECEIPT ID = '||
                                                TO_NUMBER(L_CASH_RECEIPT_ID));
                       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                  l_module_name,'    CASH RECEIPT HISTORY ID = '
                                  ||TO_NUMBER(L_CASH_RECEIPT_HIST_ID));
          END IF;

          IF ((l_cash_receipt_id IS NULL)
                            OR (l_cash_receipt_hist_id IS NULL)) -- Null
          THEN
                l_name := 'MANUAL';

          ELSIF (l_cash_receipt_id IS NOT NULL)
          THEN
             BEGIN
                SELECT 'Y'
                INTO   l_exists
                FROM   Ar_Cash_Receipts_All
                WHERE  cash_receipt_id =  to_number(l_cash_receipt_id)
		AND  org_id = p_def_org_id;

                IF (FND_LOG.LEVEL_STATEMENT >=
                            FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                        l_module_name,'    CASH RECEIPT ID ' ||
                                         ' EXISTS IN AR_CASH_RECEIPTS_ALL.');
                END IF;
             EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                     l_name := 'MANUAL';
                      IF (FND_LOG.LEVEL_STATEMENT >=
                                       FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                             l_module_name,'      NO_DATA_FOUND'
                                             || 'WHEN SELECTING FROM '||
                                             'AR_CASH_RECEIPTS_ALL, ' ||
                                             ' HENCE MANUAL');
                     END IF;

                 WHEN INVALID_NUMBER OR VALUE_ERROR THEN
                     l_name := 'MANUAL';
                        IF (FND_LOG.LEVEL_STATEMENT >=
                                  FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                         l_module_name,
                              '      INVALID NUMBER ERROR, HENCE MANUAL');
                     END IF;
             END;

             BEGIN
                SELECT 'Y'
                INTO   l_exists
                FROM   Ar_Cash_Receipt_History_All
                WHERE  cash_receipt_history_id =
                       to_number(l_cash_receipt_hist_id)
		AND    org_id = p_def_org_id;

              IF (FND_LOG.LEVEL_STATEMENT >=
                                   FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                  l_module_name,'    CASH RECEIPT HIST '||
                                 'ID EXISTS IN AR_CASH_RECEIPT_HISTORY_ALL.');
                END IF;
             EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    IF (v_je_category = 'Misc Receipts')      --  Misc Receipts
                    THEN
                      IF (FND_LOG.LEVEL_STATEMENT >=
                                    FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                                  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                       l_module_name,'    FOR MISC RECEIPT: ' ||
                                       'CASH RECEIPT HIST ID DOES NOT '||
                           'exist in Ar_Cash_Receipt_History_All table. ' ||
                           'Checking in Ar_Misc_Cash_Distributions_All table.');
                        END IF;
                        l_exists := 'M';

                    ELSE
                      IF (FND_LOG.LEVEL_STATEMENT >=
                                    FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                              l_module_name,'    FOR TRADE RECEIPT: ' ||
                              'CASH RECEIPT HIST ID DOES NOT '||
                          'exist in Ar_Cash_Receipt_History_All table. ' ||
                          ' Checking in Ar_Receivable_Applications_All table.');
                        END IF;
                        l_exists := 'C';
                    END IF;		-- Misc Receipts

                 WHEN INVALID_NUMBER OR VALUE_ERROR THEN
                     l_name := 'MANUAL';
                       IF (FND_LOG.LEVEL_STATEMENT >=
                                  FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                        l_module_name,'      INVALID NUMBER ' ||
                                        'ERROR, HENCE MANUAL');
                     END IF;
              END;

              IF ((v_je_category <> 'Misc Receipts')
                               AND (l_exists = 'C'))  -- je_cat, l_exists
              THEN
                 BEGIN
                    SELECT cash_receipt_history_id
                    INTO l_temp_cr_hist_id
                    FROM Ar_Receivable_Applications_All
                    WHERE receivable_application_id =
                                      TO_NUMBER(l_cash_receipt_hist_id)
		    AND org_id = p_def_org_id;

                    l_cash_receipt_hist_id := l_temp_cr_hist_id;

                   IF (FND_LOG.LEVEL_STATEMENT >=
                               FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                     l_module_name,'    CASH RECEIPT HIST ID '||
                                     L_CASH_RECEIPT_HIST_ID ||', EXISTS IN '||
		 	'Ar_Receivable_Applications_All. Checking in ' ||
                        ' Ar_Cash_Receipt_History_All to see' ||
                        ' if it is a valid id.');
                    END IF;

                    BEGIN
                       SELECT 'Y'
                       INTO l_exists
                       FROM Ar_Cash_Receipt_History_All
                       WHERE cash_receipt_history_id =
                                       TO_NUMBER(l_cash_receipt_hist_id)
		       AND org_id = p_def_org_id;

                        IF (FND_LOG.LEVEL_STATEMENT >=
                               FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                   l_module_name,'    CASH RECEIPT HIST ID ' ||
                                  '  EXISTS IN THE AR_CASH_RECEIPT_HISTORY_ALL '
                                  ||' TABLE.');
                       END IF;
                    EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                          l_name := 'MANUAL';
                           IF (FND_LOG.LEVEL_STATEMENT >=
                                      FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                        l_module_name,'      NO_DATA_FOUND ' ||
                                        ' WHEN SELECTING FROM '||
                                        ' AR_CASH_RECEIPT_HISTORY_ALL, ' ||
                                        'HENCE MANUAL');
                          END IF;

                       WHEN INVALID_NUMBER OR VALUE_ERROR THEN
                          l_name := 'MANUAL';
                          IF (FND_LOG.LEVEL_STATEMENT >=
                                        FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                              l_module_name,
                              '      INVALID NUMBER ERROR, HENCE MANUAL');
                          END IF;
                    END;
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      l_name := 'MANUAL';
                      IF (FND_LOG.LEVEL_STATEMENT >=
                                      FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                              l_module_name,
                                             '      NO_DATA_FOUND WHEN '||
                                             ' SELECTING FROM AR_RECEIVABLE' ||
                                             '_APPLICATIONS_ALL, HENCE MANUAL');
		      END IF;

		     WHEN INVALID_NUMBER OR VALUE_ERROR THEN
                        l_name := 'MANUAL';
                        IF (FND_LOG.LEVEL_STATEMENT
                                    >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                l_module_name,
                              '      INVALID NUMBER ERROR, HENCE MANUAL');
                        END IF;

                 END;
              ELSIF  ((v_je_category = 'Misc Receipts') AND (l_exists = 'M'))
	      THEN
                 BEGIN
                    SELECT 'Y'
                    INTO l_exists
                    FROM Ar_Misc_Cash_Distributions_All
                    WHERE misc_cash_distribution_id =
                                    TO_NUMBER(l_cash_receipt_hist_id)
		    AND org_id = p_def_org_id;

                    IF (FND_LOG.LEVEL_STATEMENT >=
                          FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                      l_module_name,
                                '    MISC CASH DISTRIBUTION ID EXISTS IN '||
                       		'Ar_Misc_Cash_Distributions_All table and is '||
                       		    TO_NUMBER(l_cash_receipt_hist_id));
                    END IF;

                    vl_misc_cd_flag := 'Y';
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                       l_name := 'MANUAL';
                        IF (FND_LOG.LEVEL_STATEMENT >=
                                  FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                                l_module_name,
                                          '      NO_DATA_FOUND WHEN '||
                                          ' SELECTING FROM AR_MISC_CASH_' ||
                                          'DISTRIBUTIONS_ALL, HENCE MANUAL');
                       END IF;

                     WHEN INVALID_NUMBER OR VALUE_ERROR THEN
                        l_name := 'MANUAL';
                         IF (FND_LOG.LEVEL_STATEMENT >=
                                        FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                                       l_module_name,
                                  '      INVALID NUMBER ERROR, HENCE MANUAL');
                        END IF;
                 END;
              END IF;				-- je_cat, l_exists
           END IF;			-- Null
	END IF;
	-- Reference Validity Check
      END IF;  -- l_je_from_sla_flag


         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                     '    L_NAME: '||L_NAME);
        END IF;

        -------------------------------------------
        -- Find ALC_CODE for each record.
        -------------------------------------------
       IF (l_name <> 'MANUAL')
       THEN			 	-- <> Manual

	 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
		 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                 l_module_name,'-> FIND ALC ...');
	 END IF;

         IF (v_je_source = 'Receivables')
         THEN 				-- Source Check to find ALC

	   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
		 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                       l_module_name,
                                       '   GETTING ALC FOR SOURCE = ' ||
                                       ' RECEIVABLES ...');
	   END IF;

          l_cash_receipt_id := l_reference_2;            --Bug# 640664

          -- Adiaaaa

       --Bug# 6406646
       /* IF l_je_from_sla_flag = 'Y' THEN

          get_reference_column ('RECEIPTS',
				l_batch_id ,
				l_je_header_id ,
				l_je_line_num ,
				l_cash_receipt_id  ,
                                l_appl_reference ,
                                l_cash_receipt_hist_id ,
                                200  );
      END IF;

               l_reference_2 := l_cash_receipt_id; */

           -- Get agency location code
   	   BEGIN
	      SELECT cba.agency_location_code
	      INTO   l_temp_alc_code
	      FROM   ce_bank_accounts cba,
                     ar_cash_receipts_all acr,
		     ce_bank_acct_uses_all cbau
 	      WHERE  acr.cash_receipt_id = l_cash_receipt_id --l_reference_2
 	      AND    acr.remit_bank_acct_use_id = cbau.bank_acct_use_id
	      AND    cba.bank_account_id = cbau.bank_account_id
	      AND    cbau.org_id = p_def_org_id
	      AND    cba.account_owner_org_id = cbau.org_id
	      AND    cbau.org_id = acr.org_id;

	   IF l_temp_alc_code IS NOT NULL
	   THEN
	      l_alc_code := l_temp_alc_code;
	   END IF;

           EXCEPTION
 	     WHEN NO_DATA_FOUND THEN
 		IF (FND_LOG.LEVEL_STATEMENT
                            >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
		    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                      l_module_name,'   SINCE NO_DATA_FOUND, USE DEFAULT ALC.');
		END IF;
           END;

        ELSIF v_je_source = 'Budgetary Transaction'
                AND v_je_category = 'Treasury Confirmation'      THEN

	   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
		 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                       l_module_name,
                                       '   GETTING ALC FOR SOURCE = '||
                                       ' Budgetary Transaction, CATEGORY = TREASURY ' ||
                                       'CONFIRMATION ...');
	   END IF;


          -- Adi

         --Bug# 6406646
      /*    IF l_je_from_sla_flag = 'Y'  THEN

             get_reference_column ('TREASURY_CONFIRMATION',
				l_batch_id ,
				l_je_header_id ,
				l_je_line_num ,
				l_reference_1  ,
                                l_reference_3 ,
                                l_cash_receipt_hist_id ,
                                200  );
         END IF; */

           BEGIN

	       SELECT cba.agency_location_code
               INTO l_temp_alc_code
               FROM Fv_Treasury_Confirmations_all ftc,
                    Ap_Inv_Selection_Criteria_all aisc,
		    ce_bank_accounts cba,
		    ce_bank_acct_uses_all cbau
               WHERE ftc.treasury_confirmation_id = to_number(l_reference_1)
               AND aisc.checkrun_name = ftc.checkrun_name
               AND cba.bank_account_id = aisc.bank_account_id
	       AND cba.bank_account_id = cbau.bank_account_id
	       AND cbau.org_id = p_def_org_id
	       AND cba.account_owner_org_id = cbau.org_id
	       AND cbau.org_id = ftc.org_id
	       AND ftc.org_id = aisc.org_id;

	       IF l_temp_alc_code IS NOT NULL
               THEN
                 l_alc_code := l_temp_alc_code;
               END IF;

	   EXCEPTION
	      WHEN NO_DATA_FOUND THEN
		-- IF agency location code cannot be found using
		-- reference_1 then use reference_3
      	        BEGIN
            	     SELECT cba.agency_location_code
		     INTO   l_temp_alc_code
		     FROM   ap_checks apa,
                  	    ce_bank_accounts cba,
			    ce_bank_acct_uses_all cbau
		     WHERE  TO_CHAR(apa.check_id) = l_reference_3
		     AND    apa.bank_account_id = cba.bank_account_id
		     AND apa.ce_bank_acct_use_id = cbau.bank_acct_use_id
		     AND apa.bank_Account_id = cbau.bank_account_id
		     AND cbau.org_id = p_def_org_id
		     AND cba.bank_account_id = cbau.bank_account_id
		     AND cba.account_owner_org_id = cbau.org_id
		     AND cbau.org_id = apa.org_id;

	             IF l_temp_alc_code IS NOT NULL
                     THEN
              	        l_alc_code := l_temp_alc_code;
          	     END IF;

      	        EXCEPTION
		    WHEN NO_DATA_FOUND THEN
			 IF (FND_LOG.LEVEL_STATEMENT >=
                                    FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
			     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                                     l_module_name,
                               '   SINCE NO_DATA_FOUND, USE DEFAULT ALC.');
			 END IF;
      	        END;
	   END;

        ELSIF (v_je_source = 'Payables'
                   AND v_je_category <> 'Treasury Confirmation')       THEN

	    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                            l_module_name,'   GETTING ALC FOR SOURCE = ' ||
                            ' PAYABLES, CATEGORY <> TREASURY CONFIRMATION ...');
	    END IF;


                 -- Adi

           --Bug# 6406646
            /*   IF l_je_from_sla_flag = 'Y' THEN

                        get_reference_column ('AP_PAYMENTS',
                                              l_batch_id ,
                                              l_je_header_id ,
                                              l_je_line_num ,
                                              l_reference_3  ,
                                              l_reference_2 ,
                                              l_cash_receipt_hist_id ,
                                              200  );


              END IF; */


              BEGIN
                 SELECT distinct org_id
                 INTO   l_org_id
                 FROM   ap_invoice_payments_all
                 WHERE  invoice_id = to_number(l_reference_2);
              EXCEPTION
                 WHEN OTHERS THEN
                    p_error_code := 2;
                    p_error_msg  := SQLERRM||'--Error while deriving ' ||
                                  'the org_id, in the '||
                                  'procedure Process_1219_Transactions.';
                    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
                                     l_module_name||'.error20',p_error_msg);
              END;


              IF (FND_LOG.LEVEL_STATEMENT
                        >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
		 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                            '   ORG ID OF THE TXN IS '||TO_CHAR(L_ORG_ID));
              END IF;

              IF l_org_id IS NULL THEN
                 l_payables_ia_paygroup := p_def_p_ia_paygroup ;
              ELSE
                 BEGIN
                    SELECT  payables_ia_paygroup
                    INTO    l_payables_ia_paygroup
                    FROM    fv_operating_units_all
                    WHERE   org_id = l_org_id;
                 EXCEPTION
                    WHEN OTHERS THEN
                       p_error_code := 2;
                       p_error_msg := SQLERRM ||'--Error while deriving the '||
                                    'payables_ia_paygroup in the procedure '||
                                    ' Process_1219_Transactions';
                    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
                                     l_module_name||'.error21',p_error_msg);
                 END;
              END IF;

              IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
                   then
		 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                         l_module_name,
                       '   PAYBLES PAY GROUP IS '||L_PAYABLES_IA_PAYGROUP);
              END IF;

	      l_sf1219_type_code := 'DISBURSEMENT';

              BEGIN  /* to process DIT payments */
                l_Error_stage := 0;
                l_inv_amount  := 0;

                l_reference := To_Number(l_reference_2) ;
                BEGIN
                    SELECT api.invoice_id,
                           api.vendor_id,
                           api.invoice_amount,
                           nvl(apc.treasury_pay_date,apc.check_date)
                    INTO   l_invoice_id ,
                           l_vendor_id,
                           l_inv_amount,
                           l_check_date
                    FROM   ap_checks_all apc,
                           ap_invoices_all api
                    WHERE  api.invoice_id = NVL(l_reference, 0)
                    AND    apc.check_id = to_number(l_reference_3)
                    AND    l_payables_ia_paygroup = api.pay_group_lookup_code
                    AND    apc.payment_method_lookup_code = 'CLEARING';

                    l_inter_agency_flag := 'Y';
                EXCEPTION
                    when too_many_rows THEN
                        p_error_msg := 'Too many rows in invoice ' ||
                                       'info,dit select';
                        p_error_code := -1;
		        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                                   l_module_name||'.error22', p_error_msg) ;
                        return;

                    when No_Data_Found THEN
                        l_inter_agency_flag := 'N' ;
                END;

                IF ( FND_LOG.LEVEL_STATEMENT >=
                           FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                       l_module_name,'VENDOR ID,INVOICE AMT,CHECK DATE ARE: '||
                       TO_CHAR(l_vendor_id)||'  '||TO_CHAR(l_inv_amount)||'  '||
                       TO_CHAR(l_check_date, 'MM/DD/YYYY'));
                END IF;

                IF ( FND_LOG.LEVEL_STATEMENT >=
                                   FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                  l_module_name,'INTERAGENCY FLAG IS '
                                        ||l_inter_agency_flag);
                END IF;

                l_error_stage := 1;

              -- Get agency location code
              BEGIN
                 SELECT cba.agency_location_code
	         INTO   l_temp_alc_code
    	         FROM   ap_invoice_payments_all aip,
                        ap_checks_all aca,
                        ce_bank_accounts cba,
			ce_bank_acct_uses_all cbau
    	         WHERE  TO_CHAR(aip.invoice_id) = l_reference_2
		 AND    aca.check_id = l_reference_3
                 AND    aip.set_of_books_id = p_set_bks_id
         	 AND    aip.check_id = aca.check_id
                 AND    aca.bank_account_id = cba.bank_account_id
		 AND    aca.ce_bank_acct_use_id = cbau.bank_acct_use_id
		 AND    cba.bank_account_id = cbau.bank_account_id
		 AND    cbau.org_id = p_def_org_id
                 AND    cba.account_owner_org_id = cbau.org_id
		 AND    cbau.org_id = aip.org_id
		 AND    aip.org_id  = aca.org_id
	         AND    rownum < 2;

                 IF l_temp_alc_code IS NOT NULL
                 THEN
              	   l_alc_code := l_temp_alc_code;
           	 END IF;

	      EXCEPTION
	         WHEN NO_DATA_FOUND THEN
			 IF (FND_LOG.LEVEL_STATEMENT >=
                                      FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
			      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                                   l_module_name,
                                '   SINCE NO_DATA_FOUND, USE DEFAULT ALC.');
			 END IF;
	      END;
	   END;
           END IF; -- Source Check to find ALC

	   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
		 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                        l_module_name,'   ALC: '||L_ALC_CODE);
	   END IF;
       END IF; 					       -- <> Manual

       -- Check to see if the derived alc_code is the same
       -- as the parameter alc_code. If it is the same then
       -- continue, else skip further processing.

   IF ((UPPER(p_alc_code) = 'ALL' OR l_alc_code = p_alc_code)
             AND l_name <> 'MANUAL')
   THEN		 -- Non-Manual Lines for ALL/any ALC

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                       '-> GET ACCOMPLISH_DATE ...');
     END IF;

     -- Following code derives Accomplish date,
     -- Inter Agency flag and Obligation date

    -- Source Check to find Accomplish Date
     IF (v_je_source = 'Receivables') THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                '   GETTING ACCOMPLISH_DATE FOR SOURCE = RECEIVABLES ...');
        END IF;



        l_exists := 'N';
 	l_inter_agency_flag := 'N';
 	l_sf1219_type_code := 'RECEIPT';
	l_record_type := 'A';

	BEGIN
	  SELECT 'X'
	  INTO  null_var
	  FROM  FV_INTERAGENCY_FUNDS_ALL
 	  WHERE cash_receipt_id = l_cash_receipt_id
	  and  org_id = p_def_org_id;

          l_inter_agency_flag  :=  'Y';
 	  l_update_type :=  'RECEIPT';

 	EXCEPTION
	     WHEN NO_DATA_FOUND THEN
 		l_inter_agency_flag := 'N';
		IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
                  then
		   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                 l_module_name, '   NO_DATA_FOUND: '||
                                 ' SETTING L_INTER_AGENCY_FLAG = N ... ');
		END IF;

	     WHEN TOO_MANY_ROWS THEN
		p_error_code := -1;
		p_error_msg :=
			'Too many rows in interagnecy select' ||
			' for cash receipt '|| to_char(l_cash_receipt_id)||
			' for Batch id '|| to_char(l_batch_id);
	                   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
                          l_module_name||'.error22',p_error_msg);
		RETURN;
 	END;

        BEGIN
           SELECT 'Y'
           INTO   l_exists
           FROM   ar_cash_receipt_history_all
           WHERE  reversal_cash_receipt_hist_id = l_cash_receipt_hist_id
	   AND    org_id = p_def_org_id;

        EXCEPTION
             WHEN NO_DATA_FOUND THEN
		NULL;
	        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
                     then
		   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                              l_module_name,
                          'NO_DATA_FOUND: AR_CASH_RECEIPT_HISTORY_ALL '||
                          'DOES NOT HAVE DATA FOR REVERSAL_CASH_RECEIPT_HIST_ID'
                          || ' = '|| L_CASH_RECEIPT_HIST_ID);
		END IF;
        END;

        BEGIN
       	   SELECT DECODE(l_exists,'N',deposit_date,reversal_date)
       	   INTO   l_accomplish_date
       	   FROM   ar_cash_receipts_all
       	   WHERE  cash_receipt_id = l_cash_receipt_id
	   ANd org_id = p_def_org_id;

        EXCEPTION
	     WHEN OTHERS THEN
	            p_error_msg := SQLERRM||
                              '- Error while deriving the accomplish date'
                              ||' for the cash receipt id '||l_cash_receipt_id;
                    p_error_code := 1 ;
                      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
                             l_module_name||'.error22',p_error_msg);
                    RETURN;
	END;

	-- Check for Refunded invoice
        OPEN refund_cursor;
	IF (SQLCODE < 0)
        THEN
   	   p_error_code := sqlcode ;
	   p_error_msg := sqlerrm ;
	   RETURN ;
	END IF;

        LOOP
	    FETCH refund_cursor
	 	INTO l_obligation_date, l_inv_amount ;

	    IF (refund_cursor%NOTFOUND)
            THEN
	       EXIT;
	    END IF;

 	    l_type := 'AP_REFUND';
 	    l_update_type := 'RECEIPT';
 	    l_processed_flag := 'Y';
 	    l_name  :=  'Refunds_and_Voids';

 	    l_sf1219_type_code := 'RECEIPT_REFUND';
	    l_record_type := 'A';

            -- Exception category is being derived before inserting new records
	    set_exception_category;

            -- If it is for Future month with Future accomplish date then
	    -- it is not reported.
   	    IF l_reported_month = 'FUTURE'
	       AND l_exception_category IN ('FUTURE_ACCOMPLISH','FUTURE PERIOD')
            THEN
   	       l_exception_category := NULL;
	       l_group_name := NULL;
            ELSE

               -- Assign Group Name for these records
	       assign_group_name;

               -- Accomplish month is populated for the new records
	       l_accomplish_month := to_char(l_accomplish_date, 'MMYYYY');

	       -- Insert new record as record_type 'A'. (changes on 7-Jun-1999)
	       -- This was being inserted as 'E'
               BEGIN
	            INSERT INTO FV_SF1219_TEMP(
		           	temp_record_id,
				batch_id,
				fund_code,
				name,
				set_of_books_id,
				posted_date,
				gl_period,
				reported_gl_period,
				amount,
				sf1219_type_code,
				reference_1,
				reference_2,
				reference_3,
				reference_4,
				reference_5,
				reference_6,
				reported_month,
				default_period_name,
				exception_category,
				accomplish_month,
				accomplish_date,
				obligation_date,
				inter_agency_flag,
				treasury_symbol,
				treasury_symbol_id,
				record_type,
				lines_exist,
				alc_code,
				org_id,
				group_name,
				update_type,
				type,
				gl_period_name,
				processed_flag,
				creation_date,
				created_by,
				last_update_date,
				last_updated_by,
				last_update_login,
				je_header_id,
				je_line_num)
			VALUES(
				fv_sf1219_temp_s.nextval,
				l_batch_id,
				l_fund_code,
				l_name,
				p_set_bks_id,
				l_posted_date,
				l_gl_period,
				l_reported_gl_period,
				l_inv_amount,
				l_sf1219_type_code,
				l_reference_1,
				l_reference_2,
				l_reference_3,
				l_reference_4,
				l_reference_5,
				l_reference_6,
				l_reported_month,
				l_default_period_name,
				l_exception_category,
				l_accomplish_month,
				l_accomplish_date,
				l_obligation_date,
				l_inter_agency_flag,
				l_treasury_symbol,
				l_treasury_symbol_id,
				'A' ,
				'N',
				l_alc_code,
				-1, --l_org_id,
				l_group_name,
				l_update_type,
				l_type,
				l_gl_period_name,
				l_processed_flag,
				sysdate,
				FND_GLOBAL.USER_ID,
				sysdate,
				FND_GLOBAL.USER_ID,
				FND_GLOBAL.LOGIN_ID,
				l_je_header_id,
				l_je_line_num )	;
	        	COMMIT;
	        EXCEPTION WHEN OTHERS THEN
		        p_error_code := sqlcode ;
		        p_error_msg  := sqlerrm ;
                        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
                                  l_module_name||'.error25',p_error_msg);
		        ROLLBACK ;
		        RETURN;
               END;

 	       l_org_amount := l_org_amount - l_inv_amount ;

            END IF ;
        END LOOP ;
        CLOSE refund_cursor ;

 	IF l_processed_flag = 'Y' THEN
 		l_amount := l_org_amount ;
 	END IF ;

	l_sf1219_type_code := 'RECEIPT' ;
	l_record_type := 'A' ;

   ELSIF (l_name like '%TREASURY%' AND
	  v_je_source = 'Budgetary Transaction' AND
	  v_je_category = 'Treasury Confirmation')
   THEN
 	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                   '   GETTING ACCOMPLISH_DATE FOR NAME LIKE %TREASURY%, '||
                   ' SOURCE = Budgetary Transaction, CATEGORY = TREASURY CONFIRMATION ...');
	END IF;

        IF (l_reference_1 IS NULL) THEN
	     l_accomplish_date := l_reference_6;
	ELSE
	   BEGIN
	     SELECT treasury_doc_date
	     INTO   l_accomplish_date
 	     FROM   fv_treasury_confirmations_all
	     WHERE  TO_CHAR(treasury_confirmation_id) = l_reference_1
	     AND    org_id = p_def_org_id;
	   EXCEPTION
	     WHEN TOO_MANY_ROWS THEN
		p_error_code := -1 ;
		p_error_msg :=
		'Too many rows in treasury_doc_date select for ' ||
		'treasury confirmation id '||substr(l_reference_6,1,20)||
		' for Batch id '|| to_char(l_batch_id)  ;
	        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
                        l_module_name||'.error26',p_error_msg);
		RETURN ;

	     WHEN OTHERS  THEN
		p_error_code := -1 ;
		p_error_msg := SQLERRM|| ' - Error when deriving the ' ||
                                 ' treasury_doc_date from ' ||
                                 'fv_treasury_confirmations_all.';
 	   END ;
	END IF;

	l_sf1219_type_code := 'DISBURSEMENT' ;
	l_record_type := 'A' ;

   ELSIF (v_je_source = 'Payables' AND
	  v_je_category <> 'Treasury Confirmation')
   THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
 	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
             '   GETTING ACCOMPLISH_DATE FOR SOURCE = PAYABLES, ' ||
                     ' CATEGORY <> TREASURY CONFIRMATION ...');
      END IF;

      --l_sf1219_type_code := 'DISBURSEMENT';
      l_record_type := 'A';
      l_inv_pay_id := 0;

      IF l_inter_agency_flag = 'Y'
      THEN
         BEGIN
           SELECT      chargeback_flag,
                       iaf.billing_agency_fund
           INTO        l_cb_flag,
                       l_billing_agency_fund
           FROM        fv_interagency_funds_all iaf
           WHERE       iaf.vendor_id   = l_vendor_id
           AND         iaf.invoice_id   = l_invoice_id
	   AND 	       iaf.org_id = p_def_org_id;
        EXCEPTION
	   when no_data_found THEN
                      l_billing_agency_fund := 'UNDEFINED';
                      l_exception_category  := 'PAYABLES_MISSING_IAF';
                      l_treasury_symbol     := 'UNDEFINED';
                      l_record_type := 'E' ;

                       --  Insert the exception transaction
                       insert_exceptions(l_amount);

                      -- The record type is set to 'O' to prevent the data
                      -- record to be shown up the 1219/1220 Report which caused
                      -- this exception.
                      l_record_type := 'O';

           when too_many_rows THEN
                p_error_msg := 'Too many rows in chargeback
                              flag Prelim select';
                p_error_code := -1;
                FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                            l_module_name||'.error23', p_error_msg) ;
                return;
        END;

      End If ; --l_inter_agency_flag = 'Y'

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                     l_module_name,'CHARGEBACK FLAG AND BILLING AGENCY ' ||
                     ' FUND ARE :' || L_CB_FLAG ||'  '||
                      L_BILLING_AGENCY_FUND);
      END IF;

      BEGIN /* Void Date */
         SELECT      nvl(apc.treasury_pay_date,apc.check_date),
                     apc.void_date
         INTO        l_accomplish_date,
                     l_void_date
         FROM        ap_checks_all apc,
                     ap_invoices_all api
         WHERE       api.invoice_id = Nvl(l_reference, 0)
         AND         apc.check_id = nvl(l_reference_3,0)
	 AND 	     apc.org_id = p_def_org_id
	 AND	     api.org_id = p_def_org_id;

         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                    l_module_name,'CHECK DATE/ACCOM DATE AND VOID DATE ARE '||
                        TO_CHAR(l_accomplish_date, 'MM/DD/YYYY')||'  '||
                        TO_CHAR(l_void_date, 'MM/DD/YYYY'));
         END IF;

         	BEGIN /* VOID */
                       l_inv_pay_id := 0;

                       IF (l_void_date IS NOT NULL) THEN

                         SELECT NVL(MAX(invoice_payment_id),0)
                         INTO l_inv_pay_id
                         FROM ap_invoice_payments
                         WHERE invoice_id = NVL(l_reference, 0)
                         AND   check_id = NVL(l_reference_3,0)
                         AND   invoice_payment_id >l_reference_9;

                         IF ( FND_LOG.LEVEL_STATEMENT >=
                               FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                           l_module_name,'VOID DATE IS NOT ' ||
                                           'NULL AND INVOICE '||
                                'payment id is '||TO_CHAR(l_inv_pay_id));
                         END IF;

                         IF (l_inv_pay_id = 0) THEN
                           l_accomplish_date := l_void_date ;
                           l_sf1219_type_code := 'VOID';
                           l_record_type := 'A';

                          BEGIN /* V1 */
                            SELECT      obligation_date
                            INTO        l_obligation_date
                            FROM        fv_refunds_voids_all
                            WHERE       type = 'VOID'
                            AND         invoice_id = to_number(l_reference_2)
                            AND         check_id   = to_number(l_reference_3)
			    AND		org_id = p_def_org_id;

                            l_processed_flag := 'Y';
                            l_update_type    := 'VOID_PAYABLE';
                            l_type           := 'VOID';
                            l_sf1219_type_code := 'VOID';
                            l_record_type    := 'A';

                            IF ( FND_LOG.LEVEL_STATEMENT >=
                                       FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                      l_module_name,'OBLIGATION DATE IS '||
                                     TO_CHAR(l_obligation_date, 'MM/DD/YYYY'));
                            END IF;

                          EXCEPTION
                            WHEN No_Data_Found Then
                                l_error_stage := -1;
                                l_billing_agency_fund := 'UNDEFINED';
                                l_exception_category  := 'VOID_MISSING_FRV';
                                l_treasury_symbol    := 'UNDEFINED';
                                l_accomplish_date := NULL;
                                l_record_type := 'E';

                         IF ( FND_LOG.LEVEL_STATEMENT >=
                                         FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                        l_module_name,'RITA GERA 1');
                         END IF;

                                --  Insert the exception transaction
                                INSERT_EXCEPTIONS(l_org_amount);
--			 -------------RITA GERA----------------
				l_record_type := 'O' ;

                            WHEN TOO_MANY_ROWS THEN
                                p_error_msg := 'Too many rows in' ||
                                               ' obligation_date select';
                                p_error_code := -1;
			        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                                  l_module_name||'.error25', p_error_msg) ;
                                return;
                          END ; /* V1 */

                       END IF; -- inv_pay_id = 0
                       END IF; -- l_void_date is not null
                    --END ; /* VOID */
                EXCEPTION
                    WHEN TOO_MANY_ROWS THEN
                        p_error_msg := 'Too many rows in void_date' ||
                                       ' disbursement select';
                        p_error_code := -1;
                        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                                 l_module_name||'.error26', p_error_msg) ;
                        return;

                    WHEN NO_DATA_FOUND THEN
                        null;

                    WHEN OTHERS THEN
                        p_error_msg  := sqlerrm ;
                        p_Error_Code := -1 ;
                        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                               l_module_name||'.error27', p_error_msg) ;
                        RollBack ;
                        Return ;
                END ; /* Void Date */

                If (l_inter_agency_flag = 'Y' and l_error_stage <> -1) Then
                    if (l_cb_flag = 'Y') then -- charge back flag
                        l_sf1219_type_code := 'RECEIPT';
                    End if; -- charge back flag = 'Y'
                End If ;

                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                  THEN
                    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                        l_module_name,'RECORD TYPE IS '||L_RECORD_TYPE);
                    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                       l_module_name,'1219 TYPE CODE IS '||L_SF1219_TYPE_CODE);
                END IF;

            EXCEPTION
                when no_data_found then
                    If (l_error_stage = 1) then
                      l_billing_agency_fund := 'UNDEFINED';
                      l_exception_category  := 'PAYABLES_MISSING_IAF';
                      l_treasury_symbol     := 'UNDEFINED';
                      l_record_type := 'E' ;

                      --  Insert the exception transaction
                      insert_exceptions(l_amount);

		      -- The record type is set to 'O' to prevent the data
		      -- record to be shown up the 1219/1220 Report which caused
		      -- this exception.
 		      l_record_type := 'O';

                    End if;
                WHEN others then
                    p_error_msg     := sqlerrm;
                    p_error_code    := -1;
                    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                          l_module_name||'.error28', p_error_msg) ;
                    rollback;
                    return;
            END ; /* End proces DIT */

   -- Following code would derive accomplish date for VOID transactions
   ELSIF (l_name LIKE  '%VOID%'
	  AND v_je_source = 'Budgetary Transaction'
	  AND v_je_category = 'Treasury Confirmation')
   THEN
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                         '   GETTING ACCOMPLISH_DATE FOR NAME LIKE %VOID%, '||
                         'SOURCE = Budgetary Transaction, CATEGORY = '||
                         ' TREASURY CONFIRMATION ...');
 END IF;

      l_sf1219_type_code := 'VOID' ;
      l_record_type := 'A' ;
      l_void_incomplete := 'N';

      BEGIN

	     SELECT void_date
             INTO l_accomplish_date
	     FROM ap_checks_all
	     WHERE TO_CHAR(check_id) = NVL(l_reference_3,'0')
	     ANd org_id = p_def_org_id;

 	     SELECT invoice_date into l_invoice_date
 	     FROM AP_INVOICES_ALL
	     WHERE TO_CHAR(invoice_id) = NVL(l_reference_4,'0')
	     ANd org_id = p_def_org_id;

       EXCEPTION WHEN NO_DATA_FOUND THEN
     	     l_billing_agency_fund := 'UNDEFINED' ;
 	     l_exception_category := 'VOID_INCOMPLETE' ;
 	     l_treasury_symbol  := 'UNDEFINED'  ;
 	     l_record_type := 'E' ;

             -- Bug# 3528849,
             -- if created VOID_INCOMPLETE do not
             -- create VOID_MISSING_FRV record
	     l_void_incomplete := 'Y';

	     -- Call procedure to insert exception tranasctions
	     INSERT_EXCEPTIONS(l_org_amount) ;

             --The record type is set to 'O' to prevent the data
	     -- record to be shown up the 1219/1220 Report which
	     -- caused this exception.

 	     l_record_type := 'M' ;
 	     l_accomplish_date := l_end_date1 ;

             UPDATE fv_sf1219_temp
             SET record_type = l_record_type,
                  sf1219_type_code = 'MANUAL',
                  alc_code = l_alc_code,
		  accomplish_date = l_accomplish_date
             WHERE rowid = l_rowid;

             COMMIT;
      END ;

      -- Re-assigning l_reference_4 to l_reference_2
      -- This is because the process is saving invoice_id in reference_2

      l_reference_2 := l_reference_4 ;

      BEGIN
  	     SELECT obligation_date
	     INTO l_obligation_date
 	     FROM  FV_REFUNDS_VOIDS_ALL
 	     WHERE  type = 'VOID'
	     AND TO_CHAR(invoice_id) = l_reference_2
	     AND TO_CHAR(check_id)   = l_reference_3
	     AND org_id = p_def_org_id;

	     l_sf1219_type_code := 'VOID' ;
	     l_record_type := 'A' ;
 	     l_processed_flag := 'Y' ;
 	     l_update_type := 'VOID_PAYABLE' ;
 	     l_type := 'VOID'  ;

       EXCEPTION
          WHEN NO_DATA_FOUND THEN
	    IF (l_void_incomplete = 'N')
	    THEN
 	       l_billing_agency_fund := 'UNDEFINED' ;
 	       l_exception_category := 'VOID_MISSING_FRV' ;
 	       l_treasury_symbol  := 'UNDEFINED'  ;
 	       l_accomplish_date := null ;
 	       l_record_type := 'E' ;

              IF ( FND_LOG.LEVEL_STATEMENT >=
                             FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                         l_module_name,'RITA GERA 2');
              END IF;


	       -- Call procedure to insert exception tranasctions
	       INSERT_EXCEPTIONS(l_org_amount) ;

               -- The record type is set to 'O' to prevent the data
	       -- record to be shown up the 1219/1220 Report which
	       -- caused this exception.
 	       l_record_type := 'O' ;

               UPDATE fv_sf1219_temp
               SET record_type = l_record_type,
                   sf1219_type_code = 'VOID',
	           alc_code = l_alc_code
               WHERE rowid = l_rowid;

               COMMIT;
	    ELSE
	       l_sf1219_type_code := 'MANUAL' ;
	    END IF;

          WHEN TOO_MANY_ROWS THEN
		p_error_code := -1;
		p_error_msg := 'Too many rows in obligation_date select '||
				'For JE batch id '||to_char(l_batch_id);
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
                             l_module_name||'.error32',p_error_msg);
		RETURN;
      END ;
   ELSE
	-- If l_name does not fall under any of the above
        -- Fetch the end date for the period in which txn was entered
        BEGIN

          SELECT  end_date
          INTO    l_accomplish_date
          FROM    gl_periods glp, gl_sets_of_books gsob
          WHERE   glp.period_name   = l_gl_period
          AND     glp.period_type   = period_type
          AND     gsob.set_of_books_id = p_set_bks_id
          AND     gsob.chart_of_accounts_id = flex_num
          AND     glp.period_set_name = gsob.period_set_name ;

        EXCEPTION WHEN OTHERS THEN
          p_error_code := 2;
          p_error_msg := substr(sqlerrm,1,50) ||
                         ' while fetching txn end date into accomplish_date';
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                                l_module_name||'.error5', p_error_msg) ;
        END;
   END IF; 			-- Source Check to find Accomplish Date
 END IF; 		 -- Non-Manual Lines for ALL/any ALC


 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                  '   ACCOMPLISH DATE: '||L_ACCOMPLISH_DATE);
 END IF;

   IF l_accomplish_date IS NOT NULL
   THEN
      IF l_exception_category  is null THEN
 	 SET_EXCEPTION_CATEGORY;
      END IF;

      -- Exception category is not required for 'M' and 'R' records
      IF l_record_type in ('M', 'R') THEN
	 l_exception_category := null ;
      END IF;

      -- *** Additional code for inserting exception records
      IF l_record_type = 'A' THEN
         IF l_exception_category = 'PRIOR PERIOD' THEN
               INSERT_EXCEPTIONS(x_amount) ;
         ELSIF l_reported_month in ('CURRENT','CURRENT / PRIOR') AND
                l_exception_category = 'FUTURE PERIOD' THEN
            INSERT_EXCEPTIONS(x_amount) ;
         ELSIF l_reported_month = 'FUTURE' AND
	        l_exception_category IN
                       ('FUTURE_ACCOMPLISH','FUTURE PERIOD') THEN
                INSERT_EXCEPTIONS(x_amount) ;
                l_record_type := 'O' ;
         END IF;
      END IF;
      -- *** End of additional code

      -- Accomplish date is converted to accomplish month
      l_accomplish_month := to_char(l_accomplish_date,'MMYYYY') ;

      -- Assign Group name based on 1219 Type code
      ASSIGN_GROUP_NAME  ;

      -- set the lines_exist to 'Y' if group name is assigned
      IF l_record_type = 'R' AND l_group_name IS NOT NULL THEN
	 l_lines_exist := 'Y'  ;
      END IF;
   END IF ;

      -- Once all the relevant information is ready, update fv_sf1219_temp table
      UPDATE fv_sf1219_temp
		set sf1219_type_code   = l_sf1219_type_code,
		    reported_gl_period = l_reported_gl_period ,
		    reported_month     = l_reported_month,
		    exception_category = l_exception_category,
		    accomplish_month   = l_accomplish_month,
		    accomplish_date    = l_accomplish_date,
		    obligation_date    = l_obligation_date,
		    inter_agency_flag  = l_inter_agency_flag,
		    record_type	       = l_record_type,
		    alc_code	       = l_alc_code,
		    amount	       = l_org_amount,
		    reference_2        = l_reference_2,
		    lines_exist	       = l_lines_exist,
		    --org_id	       = l_org_id,
		    group_name	       = l_group_name,
		    update_type	       = l_update_type,
		    type	       = l_type,
		    gl_period_name     = p_gl_period,
		    processed_flag     = l_processed_flag
       WHERE rowid = l_rowid	 ;

       COMMIT;

       IF sqlcode < 0 THEN
	   p_error_code := -1;
	   p_error_msg := 'fv_sf1219_temp update failed' ;
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
                                   l_module_name||'.error33',p_error_msg);
	   RETURN ;
       END IF;

END LOOP ;

-- Delete all records whose alc_code does not match parameter alc_code
-- only if the parameter passed is not 'ALL' in which case no records
-- are deleted
IF UPPER(p_alc_code) <> 'ALL'
THEN
   DELETE from FV_SF1219_TEMP
   WHERE record_type not in ('P')
   AND  alc_code IS NOT NULL
   AND  alc_code <> p_alc_code;
END IF;

-- Get the supplement Number for the alc_code and period
UPDATE fv_sf1219_temp fst
SET    supplement_number =
       (SELECT NVL(MAX(supplement_number), -1) + 1
        FROM   fv_sf1219_audits fsa
        WHERE  fst.alc_code = fsa.alc_code
        AND    gl_period = p_gl_period);

COMMIT;

CLOSE TEMP_CURSOR ;

EXCEPTION
   WHEN OTHERS THEN
	IF TEMP_CURSOR%ISOPEN THEN
   	   CLOSE TEMP_CURSOR ;
	END IF;

	p_error_code := SQLCODE;
        p_error_msg := SQLERRM || ' -- Error in ' ||
                            'PROCESS_1219_TRANSACTIONS procedure.';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                         l_module_name||'.final_exception',p_error_msg);
	ROLLBACK;
	RETURN;
END PROCESS_1219_TRANSACTIONS;


-----------------------------------------------------------------------------
--	PROCEDURE SET_EXCEPTION_CATEGORY
-----------------------------------------------------------------------------
-- Update REPORTED_MONTH and EXCEPTION_CATEGORY in FV_SF1219_TEMP table
----------------------------------------------------------------------------
PROCEDURE SET_EXCEPTION_CATEGORY is
  l_module_name VARCHAR2(200) := g_module_name || 'SET_EXCEPTION_CATEGORY';
BEGIN

-- start date and end date for the gl_period of the record being processed
-- is obtained in the following code

	BEGIN
		SELECT start_date, end_date
		INTO l_start_date2, l_end_date2
		FROM GL_PERIODS glp, GL_SETS_OF_BOOKS gsob
		WHERE glp.period_name = l_gl_period_name
		AND glp.period_type = period_type
		AND gsob.set_of_books_id = p_set_bks_id
		AND gsob.chart_of_accounts_id =  flex_num
		AND glp.period_set_name = gsob.period_set_name  ;

	EXCEPTION
		WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
		p_error_code := -1 ;
		p_error_msg := 'No such period ('||l_gl_period||')
				of TEMP exists in GL_PERIODS' ;
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
                          l_module_name||'.error1',p_error_msg);
		ROLLBACK ;
		RETURN ;
	END ;

IF l_accomplish_date BETWEEN l_start_date1 AND  l_end_date1 THEN
	l_reported_month := 'CURRENT' ;

	IF l_end_date2 = l_end_date1 THEN
		l_exception_category  := NULL ;
	 ELSIF  (l_end_date2 < l_end_date1) then
		l_exception_category := 'PRIOR PERIOD' ;
	 ELSIF (l_end_date2 > l_end_date1) then
		l_exception_category := 'FUTURE PERIOD' ;
	END IF ;

 ELSIF l_accomplish_date < l_start_date1 THEN
	l_reported_month := 'CURRENT / PRIOR' ;

	IF l_end_date2 = l_end_date1 THEN
		l_exception_category  := NULL ;
	 ELSIF  (l_end_date2 < l_end_date1) then
		l_exception_category := 'PRIOR PERIOD' ;
	 ELSIF (l_end_date2 > l_end_date1) then
		l_exception_category := 'FUTURE PERIOD' ;
	END IF;
 ELSE
	l_reported_month := 'FUTURE' ;
	IF l_end_date2 = l_end_date1 then
		l_exception_category := 'FUTURE_ACCOMPLISH' ;
	 ELSIF  (l_end_date2 < l_end_date1) then
		l_exception_category := 'FUTURE_ACCOMPLISH' ;
	 ELSIF (l_end_date2 > l_end_date1) then
		l_exception_category := 'FUTURE PERIOD' ;
	END IF ;
END IF ;
EXCEPTION	-- procedure SET_EXCEPTION_CATEGORY
	WHEN OTHERS THEN
		p_error_code := SQLCODE;
        	p_error_msg := SQLERRM || ' -- Error in ' ||
                                  'SET_EXCEPTION_CATEGORY procedure.';
                    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                              l_module_name||'.final_exception',p_error_msg);
		ROLLBACK;
		RETURN;
END SET_EXCEPTION_CATEGORY;


----------------------------------------------------------------------------
--	PROCEDURE INSERT_EXCEPTIONS
----------------------------------------------------------------------------
-- This procedure, being called from procedure PROCESS_1219_TRANSACTIONS
-- inserts new transactions for pre-defined Exceptions. In case any of the
-- pre-defined exception categories occurrs during the process of each
-- record, a new transaction is inserted in the FV_SF1219_TEMP table with
-- record type as 'E'. These exception transactions are not to be reported
-- on Report 1219/1220. All records inserted with record type 'E' are
-- reported on Exception Report.
----------------------------------------------------------------------------

PROCEDURE INSERT_EXCEPTIONS (x_amount NUMBER) IS
  l_module_name VARCHAR2(200) := g_module_name || 'INSERT_EXCEPTIONS';
BEGIN
	l_accomplish_month := to_char(l_accomplish_date,'MMYYYY') ;

	INSERT INTO fv_sf1219_temp(
		temp_record_id,
		batch_id,
		fund_code,
		name,
		set_of_books_id,
		posted_date,
		gl_period,
		reported_gl_period,
		amount,
		sf1219_type_code,
		reference_1,
		reference_2,
		reference_3,
		reference_4,
		reference_5,
		reference_6,
		reported_month,
		default_period_name,
		exception_category,
		accomplish_month,
		accomplish_date,
		obligation_date,
		inter_agency_flag,
		treasury_symbol,
		treasury_symbol_id, --Added to fix Bug. 1575992
		record_type,
		lines_exist,
		alc_code,
		org_id,
		group_name,
		update_type,
		type,
		gl_period_name,
		processed_flag,
		creation_date,
		created_by,
		last_update_date,
		last_updated_by,
		last_update_login,
		je_header_id,
		je_line_num)
	VALUES(
		fv_sf1219_temp_s.nextval,
		l_batch_id,
		l_fund_code,
		l_name_keep,
		p_set_bks_id,
		l_posted_date,
		l_gl_period,
		l_reported_gl_period,
		x_amount,
		l_sf1219_type_code,
		l_reference_1,
		l_reference_2,
		l_reference_3,
		l_reference_4,
		l_reference_5,
		l_reference_6,
		l_reported_month,
		l_default_period_name,
		l_exception_category,
		l_accomplish_month,
		l_accomplish_date,
		l_obligation_date,
		l_inter_agency_flag,
		l_treasury_symbol,
		l_treasury_symbol_id,
		'E' ,
		'N',
		l_alc_code,
		--l_org_id,
                -1,
		null,
		l_update_type,
		l_type,
		l_gl_period_name,
		l_processed_flag,
		sysdate,
		FND_GLOBAL.USER_ID,
		sysdate,
		FND_GLOBAL.USER_ID,
		FND_GLOBAL.LOGIN_ID,
		l_je_header_id,
		l_je_line_num )	;

		COMMIT;
EXCEPTION
	WHEN OTHERS THEN
		p_error_code := SQLCODE;
        	p_error_msg := SQLERRM || ' -- Error in ' ||
                               'INSERT_EXCEPTIONS procedure.';
                FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                               l_module_name||'.final_exception',p_error_msg);
		ROLLBACK;
		RETURN;
END INSERT_EXCEPTIONS;


-------------------------------------------------------------------------------
--	PROCEDURE ASSIGN_GROUP_NAME
-------------------------------------------------------------------------------
-- Once the 1219 record type is assigned, based on the specified set of rules
-- a group name is assigned  to each record, which enables to report the amount
-- against appropriate report line on the 1219/1220 reports.
-- Comment - ensure that type code is stored with upper case.
-------------------------------------------------------------------------------

PROCEDURE ASSIGN_GROUP_NAME IS
  l_module_name VARCHAR2(200) := g_module_name || 'ASSIGN_GROUP_NAME';
BEGIN
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                           '   Inside Assign_Group_Name ...');
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                           '   l_sf1219_type_code : '||l_sf1219_type_code);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                           '   l_inter_agency_flag: '||l_inter_agency_flag);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                           '   l_obligation_date  : '||l_obligation_date);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                          '   l_yr_start_date    : '||l_yr_start_date);
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                          '   l_yr_end_date      : '||l_yr_end_date);
   END IF;

	IF l_sf1219_type_code = 'DISBURSEMENT' AND l_inter_agency_flag = 'N'
           THEN
       	  		l_group_name := '2103' ;
	 ELSIF l_sf1219_type_code = 'DISBURSEMENT' AND l_inter_agency_flag = 'Y'
           THEN
         		l_group_name := '2803' ;
	 ELSIF l_sf1219_type_code = 'RECEIPT' AND l_inter_agency_flag = 'N'
           THEN
        	        l_group_name := '4202' ;
	 ELSIF l_sf1219_type_code = 'RECEIPT' AND l_inter_agency_flag = 'N'
           THEN
        		l_group_name := '4202' ;
	 ELSIF l_sf1219_type_code = 'RECEIPT' AND l_inter_agency_flag = 'Y'
	   THEN
        		l_group_name := '2802' ;
	 ELSIF l_sf1219_type_code = 'VOID' AND l_inter_agency_flag = 'N'
		AND l_obligation_date BETWEEN l_yr_start_date
			AND l_yr_end_date  THEN
        		l_group_name := '2103' ;
	 ELSIF  l_sf1219_type_code = 'VOID'
        	AND l_inter_agency_flag = 'N'
		AND l_obligation_date < l_yr_start_date
           THEN
        		l_group_name := '2102' ;
	 ELSIF  l_sf1219_type_code = 'VOID'
        	AND l_inter_agency_flag = 'Y'
		AND l_obligation_date between l_yr_start_date
		AND l_yr_end_date  THEN
        		l_group_name := '2803' ;
	 ELSIF l_sf1219_type_code = 'VOID'
        	AND l_inter_agency_flag = 'Y'
		AND l_obligation_date < l_yr_start_date THEN
        		l_group_name := '2802' ;
	 ELSIF l_sf1219_type_code = 'DISBURSEMENT_REFUND'
        	AND l_inter_agency_flag = 'N'
        	AND (l_obligation_date BETWEEN l_yr_start_date
					AND l_yr_end_date) THEN
        		l_group_name := '2103' ;
	 ELSIF l_sf1219_type_code = 'DISBURSEMENT_REFUND'
        	AND l_inter_agency_flag = 'N'
        	AND l_obligation_date < l_yr_start_date THEN
        		l_group_name := '2102' ;
	 ELSIF l_sf1219_type_code = 'DISBURSEMENT_REFUND'
        	AND l_inter_agency_flag = 'Y'
        	AND (l_obligation_date BETWEEN l_yr_start_date
					AND l_yr_end_date) THEN
        		l_group_name := '2803' ;
	 ELSIF l_sf1219_type_code = 'DISBURSEMENT_REFUND'
        	AND l_inter_agency_flag = 'Y'
        	AND l_obligation_date < l_yr_start_date THEN
        		l_group_name := '2802'  ;
	 ELSIF l_sf1219_type_code = 'RECEIPT_REFUND'
        	AND l_inter_agency_flag = 'N'
        	AND (l_obligation_date BETWEEN l_yr_start_date
					AND l_yr_end_date) THEN
        		l_group_name := '4203'  ;
	 ELSIF l_sf1219_type_code = 'RECEIPT_REFUND'
        	AND l_inter_agency_flag = 'N'
        	AND (l_obligation_date between l_yr_start_date
					AND l_yr_end_date) THEN
        		l_group_name := '4203' ;
	 ELSIF l_sf1219_type_code = 'RECEIPT_REFUND'
        	AND l_inter_agency_flag = 'N'
        	AND l_obligation_date < l_yr_start_date THEN
        		l_group_name := '4202' ;
	 ELSIF l_sf1219_type_code = 'RECEIPT_REFUND'
        	AND l_inter_agency_flag = 'N'
        	AND l_obligation_date < l_yr_start_date THEN
        		l_group_name := '4202' ;
	 ELSIF l_sf1219_type_code = 'RECEIPT_REFUND'
        	AND l_inter_agency_flag = 'Y'
        	AND (l_obligation_date BETWEEN l_yr_start_date
					AND l_yr_end_date) THEN
        		l_group_name := '2803' ;
	 ELSIF l_sf1219_type_code = 'RECEIPT_REFUND'
        	AND l_inter_agency_flag = 'Y'
        	AND l_obligation_date < l_yr_start_date THEN
        	l_group_name := '2802' ;
	 ELSIF  l_sf1219_type_code = 'MANUAL' THEN
		l_group_name := null;
	 ELSE		-- group name could not be assigned
		p_error_msg := 'Group Name could not be assigned ' ;
		p_error_code := -1 ;
                FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
                             l_module_name||'.error1',p_error_msg);
		RETURN ;
	END IF ;
EXCEPTION
        WHEN OTHERS THEN
          p_error_code := SQLCODE;
          p_error_msg := SQLERRM || ' -- Error in ' ||
                          'ASSIGN_GROUP_NAME procedure.';
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                         l_module_name||'.final_exception',p_error_msg);
          ROLLBACK;
          RETURN;
END ASSIGN_GROUP_NAME;


----------------------------------------------------------------------------
--		PROCEDURE PROCESS_VOID_TRANSACTIONS
----------------------------------------------------------------------------
PROCEDURE PROCESS_VOID_TRANSACTIONS  IS
  l_module_name VARCHAR2(200) := g_module_name || 'PROCESS_VOID_TRANSACTIONS';
BEGIN
   OPEN void_cursor ;
	IF sqlcode < 0 THEN
		p_error_code := sqlcode ;
		p_error_msg  := sqlerrm ;
		RETURN;
	END IF;
   LOOP
	FETCH void_cursor INTO
		l_name,
		l_gl_period,
		l_amount,
		l_sf1219_type_code,
		l_reference_2,
		l_reference_3,
		l_reported_month,
		l_accomplish_date,
		l_obligation_date,
		l_inter_agency_flag,
		l_record_type,
		l_lines_exist,
		l_alc_code	 ;

	EXIT WHEN void_cursor%NOTFOUND ;

      BEGIN
	SELECT obligation_date into l_obligation_date
	FROM fv_refunds_voids_all
	WHERE type = 'VOID'
	 AND TO_CHAR(invoice_id) = l_reference_2
	 AND TO_CHAR(check_id)   = l_reference_3
	 AND org_id = p_def_org_id;

	l_sf1219_type_code := 'VOID' ;
	l_record_type 	   := 'A'    ;
	l_processed_flag   := 'Y'  ;
	l_update_type      := 'VOID_PAYABLE' ;
	l_type             := 'VOID' ;
	l_group_name 	   := null ;

        -- The revised accomplish date based on Check for Void transaction,
        -- exception category also needs to be checked

	set_exception_category;

        --	l_name		   := 'Original Name N/A'	;

       IF l_exception_category = 'PRIOR PERIOD' THEN
               INSERT_EXCEPTIONS(l_amount);
        ELSIF l_reported_month in ('CURRENT','CURRENT / PRIOR')
               AND l_exception_category = 'FUTURE PERIOD' THEN
               INSERT_EXCEPTIONS(l_amount);
        ELSIF l_reported_month = 'FUTURE'
               AND l_exception_category IN
                       ('FUTURE_ACCOMPLISH','FUTURE PERIOD') THEN
               INSERT_EXCEPTIONS(l_amount);
               l_record_type := 'O';
       END IF;

       -- Assign Group Name for these Voids records
       assign_group_name;

       -- set the lines_exist to 'Y' if group name is assigned
	IF l_record_type = 'R' AND l_group_name IS NOT NULL THEN
			l_lines_exist := 'Y';
	END IF;

	UPDATE fv_sf1219_temp
	 SET   sf1219_type_code = l_sf1219_type_code,
	       reported_month  = l_reported_month,
	       exception_category = l_exception_category,
	       accomplish_month = to_char(l_accomplish_date,'MMYYYY'),
	       accomplish_date  = l_accomplish_date,
	       obligation_date = l_obligation_date,
	       record_type	  = l_record_type,
	       inter_agency_flag = l_inter_agency_flag,
	       group_name      = l_group_name,
	       lines_exist     = l_lines_exist,
	       update_type = l_update_type,
	       type 	    = l_type,
	       processed_flag = l_processed_flag
         WHERE   reference_2 = l_reference_2
	 AND   reference_3 = l_reference_3
	 AND   name <> 'Check for Void'
	 AND   record_type = 'A';

	DELETE fv_sf1219_temp
	WHERE reference_2 = l_reference_2
	AND reference_3 = l_reference_3
	AND name = 'Check for Void';

    EXCEPTION
	 WHEN NO_DATA_FOUND THEN

         -- Record type of existing record is converted to E as
         -- it is being done as a
         -- mass update. In case of each record processing original
         -- record should be
         -- made 'O' and new 'E' record should be inserted.

	UPDATE fv_sf1219_temp
	SET     record_type = 'E',
		exception_category = 'VOID_MISSING_FRV',
		treasury_symbol = 'UNDEFINED'
	WHERE reference_2 = l_reference_2
	AND reference_3 = l_reference_3
	AND name <> 'Check for Void';

	WHEN TOO_MANY_ROWS THEN
		p_error_code := -1 ;
		p_error_msg  := 'Too many rows in obligation_date select' ;
                FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
                l_module_name||'.error1',p_error_msg);
      END ;

   END LOOP ;
   CLOSE VOID_CURSOR;
EXCEPTION
   WHEN OTHERS THEN
      p_error_code := SQLCODE;
      p_error_msg := SQLERRM || ' -- Error in ' ||
                       'PROCESS_VOID_TRANSACTIONS procedure.';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                          l_module_name||'.final_exception',p_error_msg);
      ROLLBACK;
      RETURN;
END PROCESS_VOID_TRANSACTIONS;


-------------------------------------------------------------------------------
--		PROCEDURE  GROUP_REPORT_LINES
-------------------------------------------------------------------------------
-- The GROUP_REPORT_LINES procedure is called from Before Report trigger of
-- 1219/1220 report. The amount against each record of FV_SF1219_TEMP is rolled
-- up into FV_SF1219_ORG_TEMP table for each org_id and line_id, which was
-- assigned in the form of Group Name during MAIN_1219 procedure. This table is
-- used for reporting 1219/1220. Record Type 'A', 'M' and 'N' are selected for
-- reporting. If the record type is 'M', 'N' or 'R' (without group_name) report
-- line information is selected from Manual Lines tables.

-- Additionally, sub-total and total report lines are inserted. It is assumed
-- that sign would be set as per multiplication rule while displaying these
-- records on the 1219/1220 report, set for each Report Line in the seed process
-- itself, and just the arithmetic sum is sufficient at the time of inserting
-- Total records in ORG TEMP table.
-------------------------------------------------------------------------------

PROCEDURE GROUP_REPORT_LINES IS
  l_module_name VARCHAR2(200) := g_module_name || 'GROUP_REPORT_LINES';
	last_reported_gl_period   varchar2(6) ;
	v_legal_entity_id	number(15) ;
	v_alc_code		ce_bank_accounts.agency_location_code%TYPE;
BEGIN
        -- Before inserting new records, delete any previous records from
        -- FV_SF1219_ORG_TEMP table
	DELETE FROM FV_SF1219_ORG_TEMP;

	COMMIT;

	INSERT into FV_SF1219_ORG_TEMP (org_id, alc_code, line_id, amount)
	SELECT p_def_org_id, fvt.alc_code,
		 substr(fvt.group_name,1,3),
	   	 sum(fvt.amount * fvr.multiplier)
	FROM 	 FV_SF1219_TEMP  fvt,
		 FV_SF1219_REPORT_TEMPLATE fvr
	WHERE   fvt.alc_code is not null
	AND    ( fvt.record_type = 'A'  OR
		    (fvt.record_type = 'R' AND fvt.group_name IS NOT NULL))
	AND     substr(fvt.group_name,1,3) = fvr.line_id
	GROUP BY  fvt.alc_code, substr(fvt.group_name,1,3) 	;

	INSERT into FV_SF1219_ORG_TEMP (org_id, alc_code, line_id, amount)
	SELECT p_def_org_id, fvt.alc_code, fvm.line_id, sum(fvt.amount *
		 DECODE(fvt.record_type, 'N', 1,fvr.multiplier))
	FROM 	 FV_SF1219_TEMP fvt,
		 FV_SF1219_MANUAL_LINES fvm,
		 FV_SF1219_REPORT_TEMPLATE fvr
	WHERE   fvt.alc_code IS NOT NULL
	AND 	((fvt.record_type IN ('M', 'N')
		      OR (fvt.record_type = 'R' AND fvt.group_name IS NULL))
		  AND fvt.temp_record_id = fvm.temp_record_id  )
	AND	fvm.line_id = fvr.line_id
	GROUP BY  fvt.alc_code,  fvm.line_id;

	INSERT INTO FV_SF1219_ORG_TEMP (org_id, alc_code, line_id, amount)
	SELECT 	p_def_org_id, fvt.alc_code, '410' line_id, sum(fvt.amount * -1)
	FROM	FV_SF1219_TEMP fvt
	WHERE   fvt.alc_code is not null
	AND     fvt.group_name is not null
	AND    ( fvt.record_type = 'A'  OR
		    (fvt.record_type = 'R' AND fvt.group_name IS NOT NULL))
	GROUP BY  fvt.alc_code;

	COMMIT;

	SELECT alc_code INTO v_alc_code
	FROM fv_sf1219_temp
	WHERE record_type = 'P' ;

	INSERT INTO FV_SF1219_ORG_TEMP (org_id, alc_code, line_id, amount)
	SELECT p_def_org_id, fvam.alc_code, '100'
               line_id, fvam.accountability_balance
	FROM   FV_SF1219_AUDITS fvam
        WHERE  fvam.reported_gl_period = (
       	        select to_char(max(
                        to_date(fvas.reported_gl_period,'MM-YYYY')),'MMYYYY')
                from fv_sf1219_audits  fvas
                where fvas.alc_code = fvam.alc_code
                and fvas.record_type = 'B' )
	AND  fvam.record_type = 'B'
	AND  fvam.alc_code = DECODE(UPPER(v_alc_code),'ALL',alc_code,
			                 v_alc_code);
	COMMIT;

	INSERT INTO FV_SF1219_ORG_TEMP (org_id, alc_code, line_id, amount)
	SELECT p_def_org_id, alc_code, '290' line_id, sum(amount)
	FROM   FV_SF1219_ORG_TEMP
	WHERE line_id in ('210','211','212','234','236','237','280')
	GROUP BY alc_code;

	INSERT INTO FV_SF1219_ORG_TEMP (org_id, alc_code, line_id, amount)
	SELECT p_def_org_id, alc_code, '300' line_id, sum(amount)
	FROM   FV_SF1219_ORG_TEMP
	WHERE line_id in ('100','290')
	GROUP BY alc_code;

	INSERT INTO FV_SF1219_ORG_TEMP (org_id, alc_code, line_id, amount)
	SELECT p_def_org_id, alc_code, '490' line_id, sum(amount)
	FROM   FV_SF1219_ORG_TEMP
	WHERE line_id in ('410','420','434','436','437')
	GROUP BY alc_code;

	INSERT INTO FV_SF1219_ORG_TEMP (org_id, alc_code, line_id, amount)
	SELECT p_def_org_id, alc_code, '500' line_id,
	       sum(decode(line_id, '490',amount * -1, amount))
	FROM   FV_SF1219_ORG_TEMP
	WHERE line_id in ('300','490')
	GROUP BY alc_code;

	INSERT INTO FV_SF1219_ORG_TEMP (org_id, alc_code, line_id, amount)
	SELECT p_def_org_id, alc_code, '800' line_id, sum(amount)
	FROM   FV_SF1219_ORG_TEMP
	WHERE line_id in ('610','620','650','700')
	GROUP BY alc_code;

	INSERT INTO FV_SF1219_ORG_TEMP (org_id, alc_code, line_id, amount)
	SELECT p_def_org_id, alc_code, '990' line_id, sum(amount)
	FROM   FV_SF1219_ORG_TEMP
	WHERE  line_id in ('800','900')
	GROUP BY alc_code;

EXCEPTION
   WHEN OTHERS THEN
      p_error_code := SQLCODE;
      p_error_msg := SQLERRM || ' -- Error in ' ||
                      ' GROUP_REPORT_LINES procedure.';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                     l_module_name||'.final_exception',p_error_msg);
      ROLLBACK;
      RETURN;
END GROUP_REPORT_LINES;


-------------------------------------------------------------------------------
--		PROCEDURE  INSERT_AUDIT_TABLE
-------------------------------------------------------------------------------
-- The INSERT_AUDIT_TABLE procedure is  called  from  After Report trigger of
-- 1219/1220 report, only when report is run in Final mode. The procedure
-- inserts records from  FV_SF1219_TEMP table to  FV_SF1219_AUDITS table, which
-- have reported_month as 'CURRENT' or 'CURRENT / PRIOR', and org id is not null.
-- These batches are excluded for any subsequent run.
-- Also, it sets the processed_flag to 'Y' for fv_interagency_funds_all and
-- fv_refunds_voids_all tables.

-- For this procedure p_gl_period format needs to be same as gl_period which
-- is varchar2(15)
-------------------------------------------------------------------------------

PROCEDURE INSERT_AUDIT_TABLE(v_alc_code VARCHAR2) IS
  l_module_name VARCHAR2(200) := g_module_name || 'INSERT_AUDIT_TABLE';

	l2_reported_month	FV_SF1219_TEMP.reported_month%TYPE	;
	l2_batch_id		FV_SF1219_TEMP.batch_id%TYPE		;
	l2_reference_2		FV_SF1219_TEMP.reference_2%TYPE	;
	l2_reference_3		FV_SF1219_TEMP.reference_3%TYPE	;
	l2_inter_agency_flag	FV_SF1219_TEMP.inter_agency_flag%TYPE	;
	l2_update_type	 	FV_SF1219_TEMP.update_type%TYPE		;
	l2_type		 	FV_SF1219_TEMP.type%TYPE		;
	l2_gl_period_name 	FV_SF1219_TEMP.gl_period_name%TYPE	;
	l2_processed_flag	FV_SF1219_TEMP.processed_flag%TYPE	;
	v_supp_number		NUMBER;
        l_reported_period       VARCHAR2(6);
 	l_end_date		DATE;

CURSOR temp2_cursor  IS
	SELECT	batch_id,
		reference_2,
		reference_3,
		reported_month,
		inter_agency_flag,
		update_type,
		type,
		gl_period_name,
		processed_flag
	FROM	FV_SF1219_TEMP
	WHERE   (update_type is not null
	OR	type is not null )
	AND   alc_code = v_alc_code
	ORDER BY batch_id ;
BEGIN
     -- Find the period for which 1219/1220 is being run
     BEGIN
        SELECT gl_period
        INTO p_gl_period
        FROM fv_sf1219_temp
        WHERE record_type = 'P'
        ORDER BY gl_period;
     EXCEPTION
        WHEN OTHERS THEN
           p_error_code := SQLCODE;
           p_error_msg := SQLERRM || ' -- Error in ' ||
                    ' INSERT_AUDIT_TABLE procedure while finding GL period.';
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                          l_module_name||'.final_exception',p_error_msg);
           ROLLBACK;
           RETURN;
     END;

     BEGIN
        SELECT set_of_books_id
        INTO   p_set_bks_id
        FROM   fv_sf1219_temp
        WHERE  rownum = 1;

        SELECT chart_of_accounts_id
        INTO   flex_num
        FROM   gl_sets_of_books
        WHERE  set_of_books_id = p_set_bks_id;

        SELECT end_date
        INTO  l_end_date
        FROM  gl_periods glp,
              gl_sets_of_books gsob
        WHERE glp.period_name           = p_gl_period
        AND   gsob.set_of_books_id      = p_set_bks_id
        AND   gsob.chart_of_accounts_id = flex_num
        AND   glp.period_set_name       = gsob.period_set_name;

        l_reported_period := to_char(l_end_date,'MMYYYY');
      EXCEPTION
        WHEN OTHERS THEN
           p_error_code := SQLCODE;
           p_error_msg := SQLERRM || ' -- Error in ' ||
                           ' INSERT_AUDIT_TABLE procedure while ' ||
                           ' finding SoB, CoA and period end date.';
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                      l_module_name||'.final_exception',p_error_msg);
           ROLLBACK;
           RETURN;
      END;

	-- Increment the supplement number, if the record is not found in the
	-- audits table then set the supplement number to 0, otherwise add 1 to it.
	-- If the number goes beyond 3 then print a line in the log file
	-- indicating that the supplement number has reached 3.
	SELECT NVL(MAX(supplement_number),-1) + 1
	INTO   v_supp_number
	FROM   fv_sf1219_audits
	WHERE  alc_code = v_alc_code
	AND    reported_gl_period = l_reported_period;

	IF v_supp_number > 3
 	  THEN
               FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_EXCEPTION,
                       l_module_name||'.error211','Supplement number for
		       Agency Location Code: '||v_alc_code||' has exceeded 3');
          v_supp_number := 3;
	END IF;

	-- Records with alc_code not null and group_name not null
	-- are moved to Audit table in final mode.
	-- If any one of group_name and alc_code is null that record
	-- is not moved to Audit table

	INSERT INTO fv_sf1219_audits (
			batch_id,
			sf1219_type_code,
			exception_category,
			gl_period,
			reported_gl_period,
			treasury_symbol_id,
			accountability_balance,
			org_id,
			record_type,
			creation_date,
			created_by,
			last_update_date,
			last_updated_by,
			last_update_login,
			je_header_id,
			je_line_num,
			inter_agency_flag,
			alc_code,
			supplement_number)
	SELECT	        fvt.batch_id,
			fvt.sf1219_type_code,
			fvt.exception_category,
			fvt.gl_period,
			fvt.reported_gl_period,
			fvt.treasury_symbol_id,--Added to fix Bug. 1575992
			null,
			-- l_org_id,
                        -1,
			fvt.record_type,
			sysdate,
			FND_GLOBAL.USER_ID,
			sysdate,
			FND_GLOBAL.USER_ID,
			FND_GLOBAL.LOGIN_ID,
			fvt.je_header_id,
			fvt.je_line_num,
			fvt.inter_agency_flag,
			alc_code,
			v_supp_number --supplement_number
	FROM 		FV_SF1219_TEMP fvt
	WHERE		fvt.reported_month in ('CURRENT / PRIOR','CURRENT')
	AND		fvt.alc_code = v_alc_code	--is not null
	AND	      (	(fvt.record_type = 'A' OR (fvt.record_type = 'R' AND
						fvt.group_name IS NOT NULL))
		     OR ((fvt.record_type = 'M' OR
			     (fvt.record_type = 'R' AND fvt.group_name IS NULL))
				AND fvt.temp_record_id IN
				    (SELECT temp_record_id
					FROM fv_sf1219_manual_lines))	) ;
        COMMIT;


	-- Set processed flag to 'Y'
	-- It may be possible to substitue following code with table / columns instead
	-- of using a cursor. I am not sure at this stage, I will have to check up.

	OPEN TEMP2_CURSOR ;
     	LOOP
		FETCH temp2_cursor INTO
			l2_batch_id,
			l2_reference_2,
		        l2_reference_3,
		        l2_reported_month,
		        l2_inter_agency_flag,
		        l2_update_type,
		        l2_type,
		        l2_gl_period_name,
		        l2_processed_flag		;

		IF (temp2_cursor%NOTFOUND) THEN
			EXIT;
		END IF;

		BEGIN
	    	IF (l2_inter_agency_flag = 'Y' AND
					l2_reported_month LIKE '%CURRENT%') THEN

		   	UPDATE fv_interagency_funds_all
		   	SET processed_flag = 'Y',
				period_reported = l2_gl_period_name
		   	WHERE decode(l2_update_type, 'RECEIPT',
					cash_receipt_id, invoice_id)
				 	= to_number(l2_reference_2)
		   	AND processed_flag = 'N'
			AND org_id = p_def_org_id;

	    	END IF ;

	        IF (l2_processed_flag = 'Y' AND
			l2_reported_month LIKE '%CURRENT%') THEN

		    UPDATE fv_refunds_voids_all
		    SET processed_flag = 'Y',
			    period_reported = l2_gl_period_name
		    WHERE decode(l2_update_type, 'RECEIPT',
				    cash_receipt_id, invoice_id)
				     = to_number(l2_reference_2)
		    AND type = l2_type
		    AND nvl(check_id,0) = decode(l2_update_type,'RECEIPT',
						    nvl(check_id,0),
					        to_number(l2_reference_3))
		    AND org_id = p_def_org_id;

	        END IF ;

	        IF (sqlcode < 0) THEN
		    p_error_msg := 'fv_Sf1219_temp table update failed ' ;
		    p_error_code := -1 ;
                    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
                            l_module_name||'.error1',p_error_msg);
		    RETURN ;
	        END IF;

	END ;

END LOOP;
COMMIT;
CLOSE TEMP2_CURSOR;

-- Delete records from TEMP table which have been copied to AUDIT table. Though,
-- the deletion is taking place as part of MAIN process, following delete is
-- provided to prevent reporting same records again, just in case user runs the
-- report without running pre-process.
-- Keep only 'E' records for exception report. Exception report deletes all.

--DELETE FROM fv_sf1219_temp
--WHERE record_type <> 'E';

--DELETE FROM fv_sf1219_manual_lines;

--DELETE FROM fv_sf1219_org_temp;
--COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      p_error_code := SQLCODE;
      p_error_msg := SQLERRM || ' -- Error in INSERT_AUDIT_TABLE procedure.';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                   l_module_name||'.final_exception',p_error_msg);
      ROLLBACK;
      RETURN;
END INSERT_AUDIT_TABLE;


-----------------------------------------------------------------------------
--	PROCEDURE  INSERT_ACCOUNTABILITY_BALANCE
-----------------------------------------------------------------------------
-- The INSERT_ACCOUNTABILITY_BALANCE procedure is called from a formula
-- column of the 1219/1220 report. It inserts record for closing balance
-- of accountability, for each org id, which is used as opening balance
-- for subsequent run.
-----------------------------------------------------------------------------

PROCEDURE INSERT_ACCOUNTABILITY_BALANCE (p_rep_gl_period  IN VARCHAR2,
					 p_cl_balance     IN NUMBER,
					 p_alc_code       IN VARCHAR2) IS
  l_module_name VARCHAR2(200);
BEGIN
-- Insert a record for closing balance
-- First try to overlay the existing closing balance, if the report is already
-- run earlier for the same period (latest period is derived for this purpose).
-- Otherwise, insert a new record with closing balance for the org id for the
-- period.

-- Parameter p_rep_gl_period needs to be in varchar2(6) 'MMYYYY' format.

  l_module_name := g_module_name || 'INSERT_ACCOUNTABILITY_BALANCE';

	UPDATE  FV_SF1219_AUDITS
	set accountability_balance =  p_cl_balance,
		last_update_date = sysdate,
		last_updated_by  = FND_GLOBAL.USER_ID,
		last_update_login = FND_GLOBAL.LOGIN_ID
	where   reported_gl_period = p_rep_gl_period
	and   alc_code = p_alc_code
	and record_type = 'B' ;

	IF SQL%NOTFOUND then
		INSERT into FV_SF1219_AUDITS (
				batch_id,
				reported_gl_period,
				accountability_balance,
				alc_code,
				record_type,
				creation_date,
				created_by,
				last_update_date,
				last_updated_by,
				last_update_login,
				org_id,
				treasury_symbol_id)
		values (100,		    -- some batch id for not null column
			p_rep_gl_period,    -- gl period in MMYYYY format
			p_cl_balance,	--amount against line 500 of report
			p_alc_code,
			'B',
			sysdate,
			FND_GLOBAL.USER_ID,
			sysdate,
			FND_GLOBAL.USER_ID,
			FND_GLOBAL.LOGIN_ID,
			-1, --l_org_id,
			-2); --This is a dummy value needed for bug# 3537243

	end if;
	commit;
EXCEPTION
   WHEN OTHERS THEN
      p_error_code := SQLCODE;
      p_error_msg := SQLERRM || ' -- Error in ' ||
                        'INSERT_ACCOUNTABILITY_BALANCE procedure.';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                                 l_module_name||'.final_exception',p_error_msg);
      ROLLBACK;
      RETURN;
END INSERT_ACCOUNTABILITY_BALANCE;


-----------------------------------------------------------------------------
--		PROCEDURE GEN_FLAT_FILE
-----------------------------------------------------------------------------
PROCEDURE GEN_FLAT_FILE(v_period     IN VARCHAR2,
		        v_do_name    IN VARCHAR2,
		        v_do_tel_num IN VARCHAR2,
			v_alc_code   IN VARCHAR2)
IS
  l_module_name VARCHAR2(200) := g_module_name || 'GEN_FLAT_FILE';

i NUMBER;
x_line_id fv_sf1219_report_template.line_id%TYPE;
x_amt fv_sf1219_org_temp.amount%TYPE;

TYPE total_rec_type IS RECORD
  (line_id fv_sf1219_report_template.line_id%TYPE,
   amt  fv_sf1219_org_temp.amount%TYPE);

TYPE total_tab_type IS TABLE OF total_rec_type INDEX BY BINARY_INTEGER;

total_tab total_tab_type;

     CURSOR total_cur IS
        SELECT fvr.line_id v_line_id, SUM(DECODE(fvr.line_type,
                                            'A', fvo.amount,
                                             'T', fvo.amount,
                                             'B',fvo.amount,0)) v_amt
           FROM    fv_sf1219_report_template fvr,
                   fv_sf1219_org_temp fvo
           WHERE  fvr.line_id = fvo.line_id
           AND    fvo.alc_code = v_alc_code
	   AND line_type <> 'D'
           GROUP BY fvr.line_id
           UNION
           SELECT line_id,0
           FROM   fv_sf1219_report_template
           WHERE  line_id NOT IN
                        (SELECT line_id FROM fv_sf1219_org_temp
                         WHERE  alc_code = v_alc_code)
	   AND line_type <> 'D'
           GROUP BY line_id;

     -- Using the two select statements in the From clause
     -- because we need one line the goals for A, M and N records.
     CURSOR tc_210 IS
        SELECT SUM(grp_amount) group_amount, alc alc_code
        FROM (SELECT SUM(decode(fvt.record_type,'N', fvt.amount,
                                           fvt.amount*fvr.multiplier))
                  grp_amount, fvt.alc_code alc
        FROM    fv_sf1219_report_template fvr,
                  fv_sf1219_temp fvt
        WHERE   substr(fvt.group_name,1,3)  = fvr.line_id
        AND    (fvt.record_type IN ('A') OR
                 (fvt.record_type = 'R' AND fvt.group_name IS NOT NULL))
        AND      fvt. alc_code = v_alc_code
        AND      SUBSTR(fvt.group_name,1,3) = '210'
        GROUP BY fvt.alc_code, fvr.line_id
        UNION
        SELECT  SUM(decode(fvt.record_type,'N', fvt.amount,
                                   fvt.amount*fvr.multiplier))
                  grp_amount, fvt.alc_code alc
        FROM    fv_sf1219_report_template fvr,
                  fv_sf1219_temp fvt,
                  fv_sf1219_manual_lines fvm
        WHERE   fvm.line_id = fvr.line_id
        AND     fvt.temp_record_id = fvm.temp_record_id
        AND     (fvt.record_type IN ('M','N') OR
              (fvt.record_type = 'R' AND fvt.group_name IS NULL))
        AND     fvt.alc_code = v_alc_code
        AND     fvm.line_id = '210'
        GROUP BY fvt.alc_code, fvm.line_id)
        GROUP BY alc;

     -- Using the two select statements in the From clause
     -- because we need one line the goals for A, M and N records.
     CURSOR tc_211_420 IS
        SELECT alc alc_code, l_num line_num, acc_mon accomplish_month,
                SUM(grp_amt) group_amount
        FROM (SELECT fvt.alc_code alc, SUBSTR(fvt.group_name,1,3) l_num,
               to_char(to_date(fvt.accomplish_month,'MMYYYY'),'MM/YY') acc_mon,
               SUM(decode(fvt.record_type,'N', fvt.amount,
                           fvt.amount*fvr.multiplier)) grp_amt
        FROM   fv_sf1219_report_template fvr, fv_sf1219_temp fvt
        WHERE  substr(fvt.group_name,1,3)  = fvr.line_id
        AND    (fvt.record_type IN ('A') OR
               (fvt.record_type = 'R' AND fvt.group_name IS NOT NULL))
        AND    fvt.alc_code = v_alc_code
        AND    SUBSTR(fvt.group_name,1,3) IN ('211','212','280','420')
        GROUP BY fvt.alc_code, SUBSTR(fvt.group_name,1,3),      -- fvr.line_id,
                 to_char(to_date(fvt.accomplish_month,'MMYYYY'),'MM/YY')
        UNION
        SELECT fvt.alc_code alc, fvm.line_id l_num,
               to_char(to_date(fvt.accomplish_month,'MMYYYY'),'MM/YY') acc_mon,
               SUM(decode(fvt.record_type,'N', fvt.amount,
                     fvt.amount*fvr.multiplier)) grp_amt
        FROM  fv_sf1219_report_template fvr,
                fv_sf1219_temp fvt, fv_sf1219_manual_lines fvm
        WHERE  fvm.line_id = fvr.line_id
        AND    fvt.temp_record_id = fvm.temp_record_id
        AND    (fvt.record_type IN ('M','N') OR
             (fvt.record_type = 'R' AND fvt.group_name IS NULL))
        AND    fvt.alc_code = v_alc_code
        AND    fvm.line_id IN ('211','212','280','420')
        GROUP BY fvt.alc_code,  fvm.line_id,
                to_char(to_date(fvt.accomplish_month,'MMYYYY'),'MM/YY'))
        GROUP BY alc, l_num, acc_mon
        ORDER BY  2, 3;

     -- Using the two select statements in the From clause because we need
     -- one line the goals for A, M and N records.
     CURSOR tc_1220 IS
        SELECT ts treasury_symbol, SUM(c2) col2_amt,
               SUM(c3) col3_amt, alc alc_code
        FROM (
        SELECT fvt.treasury_symbol ts,
                SUM(DECODE(fvt.record_type, 'A',
                DECODE(SUBSTR(fvt.group_name,4,1),
                2, fvt.amount, 0),
              'R', DECODE(SUBSTR(fvt.group_name,4,1), 2, fvt.amount, 0))) c2,
                SUM(DECODE(fvt.record_type, 'A',
                    DECODE(SUBSTR(fvt.group_name,4,1), 3, fvt.amount*-1, 0),
              'R', DECODE(SUBSTR(fvt.group_name,4,1), 3, fvt.amount*-1, 0))) c3,
                fvt.alc_code alc
        FROM    fv_sf1219_temp fvt
        WHERE  (fvt.record_type = 'A' OR
             (fvt.record_type = 'R' AND fvt.group_name IS NOT NULL))
        AND    fvt.alc_code = v_alc_code
        GROUP BY fvt.alc_code, fvt.treasury_symbol
        UNION
        SELECT fvt.treasury_symbol ts,
                 SUM(DECODE(fvt.record_type, 'M',
                DECODE(fvm.column_no, 2, fvt.amount,0),
                'N', DECODE(fvm.column_no, 2, fvt.amount*-1,0),
                'R', DECODE(fvm.column_no, 2, fvt.amount,0))) c2,
                SUM(DECODE(fvt.record_type, 'M', DECODE(fvm.column_no, 3,
                                           fvt.amount*-1,0),
                'N', DECODE(fvm.column_no, 3, fvt.amount,0),
                'R', DECODE(fvm.column_no, 3, fvt.amount*-1,0))) c3,
                fvt.alc_code alc
        FROM  fv_sf1219_temp fvt, fv_sf1219_manual_lines fvm
        WHERE fvm.temp_record_id = fvt.temp_record_id
        AND   fvt.alc_code = v_alc_code
        AND   fvm.line_id = '410'
        AND  (fvt.record_type IN ('M','N') OR
           (fvt.record_type = 'R' AND fvt.group_name IS NULL))
        GROUP BY fvt.alc_code, fvt.treasury_symbol)
        GROUP BY alc, ts
        ORDER BY  1;

	max_supplement_number	NUMBER;
	v_stmt			VARCHAR2(2000);
	v_rec_count		NUMBER;
	old_tsymbol		fv_treasury_symbols.treasury_symbol%TYPE;
	old_line_num		NUMBER;
	v_line_count		NUMBER;
	v_entry_number		NUMBER;
	v_total_line_count	NUMBER;
	l_end_date		DATE;
	l_amt 			VARCHAR2(15);
	l_amt2 			VARCHAR2(15);
	l_ts			VARCHAR2(19);
        l_reported_period	VARCHAR2(6);

BEGIN
      -- This variable will count the number of rows in the GOALS file.
      -- This value will be used in the Trailer Record.
      v_total_line_count := 0;

      BEGIN
	SELECT set_of_books_id
	INTO   p_set_bks_id
	FROM   fv_sf1219_temp
	WHERE  rownum = 1;

        SELECT chart_of_accounts_id
        INTO   flex_num
        FROM   gl_sets_of_books
        WHERE  set_of_books_id = p_set_bks_id;

        SELECT end_date
        INTO  l_end_date
        FROM  gl_periods glp,
              gl_sets_of_books gsob
        WHERE glp.period_name 		= v_period
        AND   gsob.set_of_books_id      = p_set_bks_id
        AND   gsob.chart_of_accounts_id = flex_num
        AND   glp.period_set_name       = gsob.period_set_name;

	l_reported_period := to_char(l_end_date,'MMYYYY');
      EXCEPTION
        WHEN OTHERS THEN
           p_error_code := SQLCODE;
           p_error_msg := SQLERRM || ' -- Error in GEN_FLAT_FILE ' ||
                                   ' procedure while finding Acct Date ' ||
                                   '(End_Date of the period).';
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name
                                      ||'.final_exception',p_error_msg);
           ROLLBACK;
           RETURN;
      END;


      BEGIN
        SELECT MAX(supplement_number)
        INTO   max_supplement_number
        FROM   fv_sf1219_audits
        WHERE  alc_code = v_alc_code
        AND    reported_gl_period = l_reported_period;
      EXCEPTION
        WHEN OTHERS THEN
           p_error_code := SQLCODE;
           p_error_msg := SQLERRM || ' -- Error in GEN_FLAT_FILE procedure ' ||
                             'while finding max_supplement_number.';
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                          l_module_name||'.final_exception',p_error_msg);
           ROLLBACK;
           RETURN;
      END;

	--Print the HEADER Line with following format
	--000.000 xxxxxxxx mm/dd/yy xxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxx
        v_stmt := 'SELECT ''000.00''||'''||max_supplement_number||'''||'' ''||
                   '''||v_alc_code||'''||'' ''||'''||
                   to_char(l_end_date,'MM/DD/YY')||'''||'' ''||'''||
                   to_char(SYSDATE,'MM/DD/YY')||'''||'' ''||'''||
                   RPAD(v_do_name,20)||'''||'' ''||'''||RPAD(v_do_tel_num, 14)||
                   RPAD(' ',10)||''''||
                 ' FROM DUAL';

	v_total_line_count := v_total_line_count + 1;
	fv_flatfiles.create_flat_file(v_stmt);


	--TOTAL lines 1.00 thru 9.90
	total_tab.delete;

	i := 0;

	FOR total in total_cur
	LOOP
	   i := i +1;
	   total_tab(i).line_id := total.v_line_id;
	   total_tab(i).amt     := total.v_amt;
	END LOOP;

	FOR i IN 1..total_tab.COUNT
	LOOP
	   x_line_id := total_tab(i).line_id;
	   x_amt := total_tab(i).amt;

	   --Print the Total Lines with following format
	   --001.000 xxxxxxxxxxxxxxx
           v_stmt := 'SELECT ''00''||(SUBSTR('||x_line_id||',1,1)||''.''||
                     SUBSTR('||x_line_id||',2,2))||''0''||'' ''||
                     replace(replace(to_char('||x_amt||',
                     decode(sign('||x_amt||'), 1, ''0000000000000.00'', 0,
                                    ''0000000000000.00'', ''000000000000.00'')),
                                    ''.'',''''),'' '','''')|| RPAD('' '',57)
                      FROM DUAL';

	   v_total_line_count := v_total_line_count + 1;
           fv_flatfiles.create_flat_file(v_stmt);
	END LOOP;


	-- DETAIL lines for TC 210
	v_rec_count := 0;

	FOR line_210 IN tc_210
 	LOOP
          v_rec_count := v_rec_count + 1;

          SELECT replace(replace(to_char(line_210.group_amount,
                             decode(sign(line_210.group_amount), 1,
                             '0000000000000.00', 0,
                             '0000000000000.00',
                             '000000000000.00')),'.',''),' ','')
          INTO l_amt
          FROM DUAL;

          --Print 210 Lines with following format
          --210.001 xxxxxxxxxxxxxxx xxxxxxxx
          v_stmt := 'SELECT ''210.''||'''||LPAD(v_rec_count,3,0)||
                       '''||'' ''||'''||
                            l_amt||'''||'' ''||'''||line_210.alc_code||''''||
                    ' FROM DUAL';

          v_total_line_count := v_total_line_count + 1;
       	  fv_flatfiles.create_flat_file(v_stmt);
	END LOOP;


	-- Detail Lines for TC 211 to TC 420 (excluding TC 410)
	v_rec_count := 0;
	old_line_num := -1;

	FOR line_211_420 IN tc_211_420
 	LOOP
	   IF line_211_420.line_num <> old_line_num
	   THEN
	      v_rec_count := 0;
           END IF;

           v_rec_count := v_rec_count + 1;

           SELECT replace(replace(to_char(line_211_420.group_amount,
                     decode(sign(line_211_420.group_amount), 1,
                                '0000000000000.00', 0,
                                '0000000000000.00',
                                '000000000000.00')),'.',''),' ','')
           INTO l_amt
           FROM DUAL;

           --Print 211-420 (excl. 410) Lines with following format
           --211.001 xxxxxxxxxxxxxxx xxxxxxxx mm/yy
           v_stmt := 'SELECT '''||line_211_420.line_num||'''||'||'''.'''||'||
                     '''||LPAD(v_rec_count,3,0)||''''||
                     '||'' ''||'||''''||l_amt||'''||'||''' '''||'||'''||
                     line_211_420.alc_code||''''||
                     '||'' ''||'||''''||line_211_420.accomplish_month||''''||
                     ' FROM DUAL';

      	   v_total_line_count := v_total_line_count + 1;
      	   fv_flatfiles.create_flat_file(v_stmt);
     	   old_line_num := line_211_420.line_num;
	END LOOP;


	-- Details Lines for TC 410 FMS 1220 Data
	v_line_count   := 0;
       	v_entry_number := 0;
       	old_tsymbol    := '-123';

      	FOR line_1220 IN tc_1220
	LOOP

          IF old_tsymbol <> line_1220.treasury_symbol
          THEN
	     v_entry_number := 0;
	     old_tsymbol    := line_1220.treasury_symbol;
	  END IF;

	  -- If both receipt and disbursement amounts exist then print them
          -- as two separate lines in the 1220 bulk output
          IF (line_1220.col2_amt <> 0 AND line_1220.col2_amt IS NOT NULL)
	      AND (line_1220.col3_amt <> 0 AND line_1220.col3_amt IS NOT NULL)
          THEN

             v_entry_number      := v_entry_number + 1;
             v_line_count        := v_line_count + 1;

	     SELECT replace(replace(to_char(line_1220.col2_amt,
                             decode(sign(line_1220.col2_amt), 1,
                             '0000000000000.00', 0,
                             '0000000000000.00',
                             '000000000000.00')),'.',''),' ','')
	     INTO l_amt
	     FROM DUAL;

             SELECT rpad(nvl(substr(replace(line_1220.treasury_symbol,'-',
                       ''),1,19),'                   '),19, ' ')
             INTO   l_ts
             FROM   DUAL;

             --Print 410 Lines with following format
             --410.001 xxxxxxxxxxxxxxx xxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxx xxx
             v_stmt := 'SELECT ''410.''||'''||LPAD(v_line_count,3,0)||'''
                        ||'||''' '''||
                       '||'''||l_amt||''''||
                       '||'' ''||''000000000000000''||'' ''||'||
                       ''''||l_ts||'''||'||''' ''||'''||
                       LPAD(v_entry_number,3,0)||''''||
                       '||RPAD('' '',17)'||
                       ' FROM DUAL';

             v_total_line_count  := v_total_line_count + 1;
             fv_flatfiles.create_flat_file(v_stmt);

             v_entry_number      := v_entry_number + 1;
             v_line_count        := v_line_count + 1;

	     SELECT replace(replace(to_char(line_1220.col3_amt,
                          decode(sign(line_1220.col3_amt), 1,
                                 '0000000000000.00', 0,
                                 '0000000000000.00',
                                 '000000000000.00')),'.',''),' ','')
	     INTO l_amt
	     FROM DUAL;

             SELECT rpad(nvl(substr(replace(line_1220.treasury_symbol,'-',''),
                             1,19),'                   '),19, ' ')
             INTO   l_ts
             FROM   DUAL;

             --Print 410 Lines with following format
             --410.001 xxxxxxxxxxxxxxx xxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxx xxx
             v_stmt := 'SELECT ''410.''||'''||LPAD(v_line_count,3,0)||
                       '''||'||''' '''||
                       '||''000000000000000''||'' ''||'||
                       ''''||l_amt||'''||'' '''||
                       '||'''||l_ts||'''||'||''' ''||'''||
                       LPAD(v_entry_number,3,0)||''''||
                       '||RPAD('' '',17)'||
                       ' FROM DUAL';

             v_total_line_count  := v_total_line_count + 1;
             fv_flatfiles.create_flat_file(v_stmt);

          ELSE	-- If either receipt or disbursement amount exist

             v_entry_number     := v_entry_number + 1;
             v_line_count       := v_line_count + 1;

             SELECT replace(replace(to_char(line_1220.col2_amt,
                         decode(sign(line_1220.col2_amt), 1, '0000000000000.00',
                                 0, '0000000000000.00', '000000000000.00')),
                                 '.',''),' ','')
             INTO l_amt
             FROM DUAL;

             SELECT replace(replace(to_char(line_1220.col3_amt,
              decode(sign(line_1220.col3_amt), 1, '0000000000000.00', 0,
                '0000000000000.00', '000000000000.00')),'.',''),' ','')
             INTO l_amt2
             FROM DUAL;

	     SELECT rpad(nvl(substr(replace(line_1220.treasury_symbol,
                         '-',''),1,19),'                   '),19, ' ')
	     INTO   l_ts
	     FROM   DUAL;

             --Print 410 Lines with following format
             --410.001 xxxxxxxxxxxxxxx xxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxx xxx
             v_stmt := 'SELECT ''410.''||'''||LPAD(v_line_count,3,0)||
                        '''||'||''' '''||
                       '||'''||l_amt||'''||'' '''||
                       '||'''||l_amt2||'''||'' '''||
                       '||'''||l_ts||'''||'||''' ''||'''||
                       LPAD(v_entry_number,3,0)||''''||
                       '||RPAD('' '',17)'||
                       ' FROM DUAL';

             v_total_line_count := v_total_line_count + 1;
             fv_flatfiles.create_flat_file(v_stmt);
          END IF;
       END LOOP;

       --Print Trailer Line with following format. v_total_line_count
       --counts header and trailer lines too.
       --999.999 xxxxxxxx
       v_total_line_count := v_total_line_count + 1;

       v_stmt := 'SELECT ''999.999''||'' ''||LPAD('||
                  v_total_line_count||',8,'' '')'
                         ||'||RPAD('' '',64)'||
                         ' FROM DUAL';

       fv_flatfiles.create_flat_file(v_stmt);

-- For the 'Final' run of the request set, delete all records
-- from fv_sf1219_temp for the ALC
-- but the P record and the M records that do not have any lines
-- associated with them.

DELETE from fv_sf1219_temp t
WHERE t.alc_code = v_alc_code
AND EXISTS (SELECT 'X'
	    FROM FV_SF1219_MANUAL_LINES m
            WHERE m.temp_record_id = t.temp_record_id
	    AND t.record_type = 'M');

DELETE FROM fv_sf1219_temp
WHERE alc_code = v_alc_code
AND record_type NOT IN ('P', 'M');

-- If there are any records with record_type of M
-- where report lines are not assigned and
-- therefore not reported on the 1219/1220 report, they should
-- also not be deleted.

DELETE FROM fv_sf1219_manual_lines m
WHERE NOT EXISTS (SELECT 'X'
		  FROM fv_sf1219_temp t
                  WHERE t.temp_record_id = m.temp_record_id
                  AND t.record_type = 'M');

DELETE FROM fv_sf1219_org_temp;
COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      p_error_code := SQLCODE;
      p_error_msg := SQLERRM || ' -- Error in GEN_FLAT_FILE procedure.';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                      l_module_name||'.final_exception',p_error_msg);
      ROLLBACK;
      RETURN;
END GEN_FLAT_FILE;


-- Adi

/* PROCEDURE get_reference_column (p_entity_code IN VARCHAR2,
				p_batch_id IN NUMBER,
				p_je_header_id IN NUMBER,
				p_je_line_num IN NUMBER,
				p_reference  OUT  NOCOPY NUMBER,
                                p_appl_reference OUT NOCOPY NUMBER,
                                p_history_reference OUT NOCOPY NUMBER,
                                p_application_id IN NUMBER ) IS

  l_event_id      NUMBER;
  l_ae_header_id  NUMBER;
  l_ae_line_num   NUMBER;


BEGIN

  IF l_je_from_sla_flag = 'Y'  THEN

      -- Get the Treasury Confirmation ID for Treasury Confirmation
      -- Check ID  for Payments
      -- Receipt ID for Receivables

      SELECT ent.source_id_int_1 ,
             aeh.event_id,aeh.ae_header_id,ael.ae_line_num
	INTO p_reference,l_event_id,l_ae_header_id,l_ae_line_num
	FROM xla_transaction_entities ent,
	     xla_events evt,
	     xla_ae_headers aeh,
	     xla_ae_lines ael,
 	     gl_import_references gli
       WHERE ent.application_id =p_application_id
	 AND ent.entity_code = p_entity_code
	 AND ent.entity_id = evt.entity_id
	 AND evt.event_id = aeh.event_id
	 AND aeh.ae_header_id = ael.ae_header_id
	 AND gli.gl_sl_link_id = ael.gl_sl_link_id
	 AND gli.je_batch_id = p_batch_id
	 AND gli.je_header_id = p_je_header_id
	 AND gli.je_line_num = p_je_line_num
         AND ael.application_id = p_application_id;

      -- Get the invoice/transaction
      -- for which the PAYMENT/RECEIPT is applied.

     SELECT applied_to_source_id_num_1
       INTO p_appl_reference
       FROM xla_distribution_links
      WHERE ae_header_id = l_ae_header_id
        AND ae_line_num = l_ae_line_num
        AND application_id = p_application_id
        AND applied_to_application_id = p_application_id ;

     -- Get the cash receipt history id
     IF p_application_id = 222 THEN
       SELECT cash_receipt_history_id
         INTO l_cash_receipt_hist_id
         FROM ar_cash_receipt_history_all
        WHERE cash_receipt_id = p_reference
          AND event_id = l_event_id;
     END IF;



  END IF;

 --EXCEPTION
-- NULL;

END get_reference_column; */

END FV_1219_TRANSACTIONS ;

/
