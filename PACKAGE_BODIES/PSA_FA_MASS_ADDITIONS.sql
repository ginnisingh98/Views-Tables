--------------------------------------------------------
--  DDL for Package Body PSA_FA_MASS_ADDITIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_FA_MASS_ADDITIONS" AS
/* $Header: PSAFAUCB.pls 120.4 2006/03/16 15:32:01 tpradhan noship $ */

--===========================FND_LOG.START=====================================
g_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(50)  := 'PSA.PLSQL.PSAFAUCB.PSA_FA_MASS_ADDITIONS.';
--===========================FND_LOG.END=======================================

PROCEDURE update_asset_type
		(err_buf		OUT NOCOPY VARCHAR2,
		 ret_code		OUT NOCOPY VARCHAR2,
                 p_ledger_id            IN  NUMBER,
		 p_chart_of_accounts	IN  NUMBER,
		 p_asset_book		IN  VARCHAR2,
		 p_capital_acct_from	IN  VARCHAR2,
		 p_capital_acct_to	IN  VARCHAR2,
		 p_cip_acct_from	IN  VARCHAR2,
		 p_cip_acct_to		IN  VARCHAR2) IS

	p_where_clause		VARCHAR2(3000);
	p_mass_add_query	VARCHAR2(4000);
	p_mass_add_capital_stmt	VARCHAR2(4000);
	p_mass_add_cip_stmt	VARCHAR2(4000);
	l_mass_addition_id	NUMBER;

	TYPE var_cur IS REF CURSOR;
	mass_add_cur	VAR_CUR;
        -- ========================= FND LOG ===========================
        l_full_path VARCHAR2(100) := g_path || 'update_asset_type';
        -- ========================= FND LOG ===========================

BEGIN
	PRINT_HEADER_INFO (p_asset_book, p_capital_acct_from, p_capital_acct_to, p_cip_acct_from, p_cip_acct_to);

	p_where_clause := fa_rx_flex_pkg.flex_sql
				(101, 'GL#', p_chart_of_accounts, 'CC', 'WHERE', 'ALL','BETWEEN', p_capital_acct_from, p_capital_acct_to);

	p_mass_add_query :=  'SELECT mass_addition_id
			        FROM fa_mass_additions fma, gl_code_combinations cc
			       WHERE fma.payables_code_combination_id = cc.code_combination_id
			         AND fma.asset_type      = '''||'EXPENSED'||''''||
			       ' AND fma.posting_status  = '''||'NEW'     ||''''||
			       ' AND book_type_code      = :p_asset_book';

	p_mass_add_capital_stmt := p_mass_add_query || ' AND ' || p_where_clause;

        -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,
                                      l_full_path,
	         		      'Select statement used for fetching mass additions (Capitalized)');
        psa_utils.debug_other_string(g_state_level,l_full_path,p_mass_add_capital_stmt);
        -- ========================= FND LOG ===========================

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Updating asset type for mass additions (Capitalized)');
	PRINT_REPORT_HEADER;

	OPEN mass_add_cur FOR p_mass_add_capital_stmt USING p_asset_book;
	LOOP
	    FETCH mass_add_cur INTO l_mass_addition_id;
	    EXIT WHEN mass_add_cur%NOTFOUND;

		UPDATE fa_mass_additions
		   SET asset_type       = 'CAPITALIZED',
		       depreciate_flag  = 'YES'
		 WHERE mass_addition_id = l_mass_addition_id;

		PRINT_MASS_ADDITION_DETAILS (l_mass_addition_id);

	END LOOP;

	CLOSE mass_add_cur;

	p_where_clause := fa_rx_flex_pkg.flex_sql
				(101, 'GL#', p_chart_of_accounts,
				  'CC', 'WHERE', 'ALL','BETWEEN', p_cip_acct_from, p_cip_acct_to);

	p_mass_add_cip_stmt := p_mass_add_query || ' AND ' || p_where_clause;

	FND_FILE.NEW_LINE (FND_FILE.LOG,    1);
	FND_FILE.NEW_LINE (FND_FILE.OUTPUT, 1);
        -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,
	                              l_full_path,
				      'Select statement used for fetching mass additions (CIP)');
        psa_utils.debug_other_string(g_state_level,l_full_path, p_mass_add_cip_stmt);
        -- ========================= FND LOG ===========================

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
	                        'Updating asset type for mass additions (CIP)');
	PRINT_REPORT_HEADER;

	OPEN mass_add_cur FOR p_mass_add_cip_stmt USING p_asset_book;
	LOOP
	    FETCH mass_add_cur INTO l_mass_addition_id;
	    EXIT WHEN mass_add_cur%NOTFOUND;

		UPDATE fa_mass_additions
		   SET asset_type       = 'CIP'
		 WHERE mass_addition_id = l_mass_addition_id;

		PRINT_MASS_ADDITION_DETAILS (l_mass_addition_id);

	END LOOP;

	CLOSE mass_add_cur;

	COMMIT;

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Processing Complete ...');

EXCEPTION
	WHEN FND_FILE.UTL_FILE_ERROR THEN
	    -- Need not error out of the conc pgm just because of file i/o error.
	    -- File creation errors are recorded in the log file.
	NULL;

END update_asset_type;

PROCEDURE print_header_info (p_asset_book 	 IN VARCHAR2,
			     p_capital_acct_from IN VARCHAR2,
			     p_capital_acct_to	 IN VARCHAR2,
			     p_cip_acct_from	 IN VARCHAR2,
			     p_cip_acct_to	 IN VARCHAR2) IS

BEGIN
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'PROGRAM - UPDATE ASSET TYPE');

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
		                       'Asset Book              : '|| p_asset_book        );

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
		                       'Capitalize Account From : '|| p_capital_acct_from );

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
		                       'Capitalize Account To   : '|| p_capital_acct_to   );

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
		                       'CIP Account From        : '|| p_cip_acct_from     );

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
		                       'CIP Account To          : '|| p_cip_acct_to       );
      	FND_FILE.NEW_LINE (FND_FILE.OUTPUT, 1);

EXCEPTION
	WHEN FND_FILE.UTL_FILE_ERROR THEN
	    -- Need not error out of the conc pgm just because of file i/o error.
	    -- File creation errors are recorded in the log file.
	NULL;

END print_header_info;

PROCEDURE print_report_header IS

BEGIN

	FND_FILE.NEW_LINE (FND_FILE.OUTPUT, 1);
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, RPAD ('Mass Addition ID', 17) ||
					    RPAD ('Invoice Number',   27) ||
					    RPAD ('Amount',           22) || 'Description' );

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, RPAD ('----------------', 17) ||
					    RPAD ('--------------',   27) ||
					    RPAD ('------',           22) || '-----------' );
	FND_FILE.NEW_LINE (FND_FILE.OUTPUT, 1);

END print_report_header;

PROCEDURE print_mass_addition_details (p_mass_addition_id IN NUMBER) IS

	CURSOR c_invoice_details (c_mass_addition_id NUMBER) IS
		SELECT mass_addition_id, invoice_number, payables_cost, description
		  FROM fa_mass_additions
		 WHERE mass_addition_id = c_mass_addition_id;

	l_mass_addition_details c_invoice_details%rowtype;
BEGIN
	OPEN  c_invoice_details (p_mass_addition_id);
	FETCH c_invoice_details
	 INTO l_mass_addition_details;
	CLOSE c_invoice_details;

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
	                         RPAD (l_mass_addition_details.mass_addition_id, 17) ||
				 RPAD (l_mass_addition_details.invoice_number,   27) ||
				 RPAD (l_mass_addition_details.payables_cost,    22) ||
				 l_mass_addition_details.description );


END print_mass_addition_details;


END PSA_FA_MASS_ADDITIONS;

/
