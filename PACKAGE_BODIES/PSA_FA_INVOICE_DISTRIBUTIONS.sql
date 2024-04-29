--------------------------------------------------------
--  DDL for Package Body PSA_FA_INVOICE_DISTRIBUTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_FA_INVOICE_DISTRIBUTIONS" AS
/* $Header: PSAFATAB.pls 120.5.12010000.2 2009/04/17 05:33:44 gnrajago ship $ */

--===========================FND_LOG.START=====================================
g_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(50)  := 'PSA.PLSQL.PSAFATAB.PSA_FA_INVOICE_DISTRIBUTIONS.';
--===========================FND_LOG.END=======================================

PROCEDURE update_assets_tracking_flag
		(err_buf		OUT NOCOPY VARCHAR2,
		 ret_code		OUT NOCOPY VARCHAR2,
                 p_ledger_id            IN  NUMBER,
		 p_chart_of_accounts	IN  NUMBER,
		 p_from_gl_date		IN  VARCHAR2,
		 p_to_gl_date		IN  VARCHAR2,
		 p_from_account		IN  VARCHAR2,
		 p_to_account		IN  VARCHAR2) IS

	p_where_clause 	VARCHAR2(3000);
	p_inv_dist	VARCHAR2(4000);
        p_prev_inv      NUMBER := 0;

        l_from_gl_date DATE;
        l_to_gl_date   DATE;
	l_invoice_id    ap_invoice_distributions_all.invoice_id%type;
	l_inv_dist_id	ap_invoice_distributions_all.invoice_distribution_id%type;
	l_dist_line_num	ap_invoice_distributions_all.distribution_line_number%type;

	TYPE var_cur IS REF CURSOR;
	inv_dist_cur	VAR_CUR;
        -- ========================= FND LOG ===========================
        l_full_path VARCHAR2(100) := g_path || 'update_assets_tracking_flag';
        -- ========================= FND LOG ===========================

BEGIN
        l_from_gl_date := to_date(substr(p_from_gl_date,1,10),'YYYY/MM/DD');
        l_to_gl_date   := to_date(substr(p_to_gl_date,1,10)  ,'YYYY/MM/DD');

	p_where_clause := fa_rx_flex_pkg.flex_sql
				(101, 'GL#', p_chart_of_accounts, 'CC', 'WHERE', 'ALL','BETWEEN', p_from_account, p_to_account);

	p_inv_dist :=  'SELECT invoice_id, distribution_line_number, invoice_distribution_id
			  FROM ap_invoice_distributions ap_inv_dist, gl_code_combinations cc
		         WHERE ap_inv_dist.dist_code_combination_id = cc.code_combination_id
			   AND posted_flag           = '''||'Y'||''''||
			  'AND assets_addition_flag  = '''||'U'||''''||
			  'AND assets_tracking_flag != '''||'Y'||''''||
			  'AND accounting_date       BETWEEN :from_gl_date and :to_gl_date';

	IF l_from_gl_date IS NULL THEN

		p_inv_dist :=  'SELECT invoice_id, distribution_line_number, invoice_distribution_id
				  FROM ap_invoice_distributions ap_inv_dist, gl_code_combinations cc
			         WHERE ap_inv_dist.dist_code_combination_id = cc.code_combination_id
				   AND posted_flag           = '''||'Y'||''''||
				  'AND assets_addition_flag  = '''||'U'||''''||
				  'AND assets_tracking_flag != '''||'Y'||''''||
				  'AND accounting_date      <= :to_gl_date';

	END IF;

	p_inv_dist := p_inv_dist||' AND '||p_where_clause||' ORDER BY invoice_id';

                -- ========================= FND LOG ===========================
                psa_utils.debug_other_string(g_state_level,
		                              l_full_path,
					      'Select statement used for fetching invoice distributions');
                psa_utils.debug_other_string(g_state_level,l_full_path,p_inv_dist);
                -- ========================= FND LOG ===========================

	PRINT_HEADER_INFO (l_from_gl_date, l_to_gl_date, p_from_account, p_to_account);

	IF p_from_gl_date IS NOT NULL THEN
		OPEN inv_dist_cur FOR p_inv_dist USING l_from_gl_date, l_to_gl_date;
	ELSE
		OPEN inv_dist_cur FOR p_inv_dist USING l_to_gl_date;
	END IF;

	LOOP
	    FETCH inv_dist_cur INTO l_invoice_id, l_dist_line_num, l_inv_dist_id;
	    EXIT WHEN inv_dist_cur%NOTFOUND;

                IF p_prev_inv = 0 THEN
                   p_prev_inv := l_invoice_id;
                END IF;

                IF p_prev_inv <> l_invoice_id THEN
                   PRINT_INVOICE_DETAILS(p_prev_inv);
                   p_prev_inv := l_invoice_id;
                END IF;

	    	UPDATE ap_invoice_distributions
	    	   SET assets_tracking_flag    = 'Y'
	    	 WHERE invoice_distribution_id = l_inv_dist_id;

	END LOOP;

        PRINT_INVOICE_DETAILS(l_invoice_id);

        CLOSE inv_dist_cur;

	COMMIT;

	FND_FILE.NEW_LINE (FND_FILE.OUTPUT, 1);
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'update_assets_tracking_flag: Processing Complete ...');

EXCEPTION
	WHEN FND_FILE.UTL_FILE_ERROR THEN
	    -- Need not error out of the conc pgm just because of file i/o error.
	    -- File creation errors are recorded in the log file.
	NULL;

END update_assets_tracking_flag;

PROCEDURE print_header_info
		(p_from_gl_date IN DATE, p_to_gl_date IN DATE, p_from_account IN VARCHAR2, p_to_account IN VARCHAR2) IS

BEGIN
		FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'print_header_info: PROGRAM - UPDATE ASSETS TRACKING FLAG');

		FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'GL Date From : '|| p_from_gl_date );

		FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'GL Date To   : '|| p_to_gl_date   );

		FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Account From : '|| p_from_account );

		FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Account To   : '|| p_to_account   );
	FND_FILE.NEW_LINE (FND_FILE.OUTPUT, 1);

		FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Updating assets tracking flag for invoice distributions ...');
	FND_FILE.NEW_LINE (FND_FILE.OUTPUT, 1);
		FND_FILE.PUT_LINE (FND_FILE.OUTPUT, RPAD ('Supplier',       32) ||
					    RPAD ('Invoice ID',     17) ||
					    RPAD ('Invoice Number', 27) ||
					    RPAD ('Line',            6) ||
					    RPAD ('Amount',         22) || 'Description' );

		FND_FILE.PUT_LINE (FND_FILE.OUTPUT, RPAD ('--------',       32) ||
					    RPAD ('----------',     17) ||
					    RPAD ('--------------', 27) ||
					    RPAD ('----',            6) ||
					    RPAD ('------',         22) || '-----------' );

	FND_FILE.NEW_LINE (FND_FILE.OUTPUT, 1);

EXCEPTION
	WHEN FND_FILE.UTL_FILE_ERROR THEN
	    -- Need not error out NOCOPY of the conc pgm just because of file i/o error.
	    -- File creation errors are recorded in the log file.
	NULL;

END print_header_info;

PROCEDURE print_invoice_details (p_invoice_id IN NUMBER) IS

	CURSOR c_invoice_details (c_invoice_id NUMBER) IS
		SELECT po_ven.vendor_name                   supplier,
		       ap_inv.invoice_id                    invoice_id,
		       ap_inv.invoice_num                   invoice_number,
		       ap_inv_line.line_number              line_number,
		       ap_inv_line.description              line_description,
		       ap_inv_line.amount                   line_amount
		 FROM  ap_invoices_all              ap_inv,
                       ap_invoice_lines_all         ap_inv_line,
                       po_vendors                   po_ven
                WHERE  ap_inv.invoice_id = c_invoice_id
                  AND  ap_inv.invoice_id = ap_inv_line.invoice_id
                  AND  ap_inv.vendor_id  = po_ven.vendor_id;

	l_invoice_details c_invoice_details%rowtype;
BEGIN
	OPEN  c_invoice_details (p_invoice_id);
        LOOP
	    FETCH c_invoice_details INTO l_invoice_details;
            EXIT WHEN c_invoice_details%NOTFOUND;

		FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'print_invoice_details: ' || RPAD (l_invoice_details.supplier,       32) ||
					    RPAD (l_invoice_details.invoice_id,     17) ||
					    RPAD (l_invoice_details.invoice_number, 27) ||
					    RPAD (l_invoice_details.line_number,     6) ||
					    RPAD (l_invoice_details.line_amount,    22) || l_invoice_details.line_description);

        END LOOP;
        CLOSE c_invoice_details;

END print_invoice_details;

END PSA_FA_INVOICE_DISTRIBUTIONS;

/
