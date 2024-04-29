--------------------------------------------------------
--  DDL for Package Body FV_THIRD_PARTY_REMIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_THIRD_PARTY_REMIT_PKG" AS
/* $Header: FVTPREMB.pls 120.3 2005/11/23 12:15:50 bnarang ship $ */

-- -------------------------------------------------------------
--        GLOBAL VARIABLES AND PROCEDURES DECLARATION
-- -------------------------------------------------------------
  g_module_name VARCHAR2(100) ;
g_errbuf        VARCHAR2(1000);
g_retcode       NUMBER := 0;
g_org_id        Fv_Tpp_Check_Details.org_id%TYPE;
g_sob_id        gl_ledgers.ledger_id%TYPE;
g_sob_name      gl_ledgers.name%TYPE;
g_pay_date_from DATE;
g_pay_date_to	DATE;
g_from_supp_id  Fv_Tpp_Assignments.original_supplier_id%TYPE;
g_from_site_id  Fv_Tpp_Assignments.original_supplier_site_id%TYPE;
g_to_supp_id    Fv_Tpp_Assignments.third_party_agent_id%TYPE;
g_to_site_id    Fv_Tpp_Assignments.third_party_site_id%TYPE;
g_from_supp_name  Po_Vendors.vendor_name%TYPE;
g_to_supp_name    Po_Vendors.vendor_name%TYPE;
g_from_site_code  Po_Vendor_Sites.vendor_site_code%TYPE;
g_to_site_code  Po_Vendor_Sites.vendor_site_code%TYPE;
g_sort_by       VARCHAR2(1);
g_checkrun_name VARCHAR2(50);
g_debug_flag    VARCHAR2(1) ;
g_tpp_flag 	VARCHAR2(1) ;
g_message       VARCHAR2(3000);
g_data_found    VARCHAR2(1) ;

PROCEDURE LOG_MESSAGE (p_level NUMBER, p_module VARCHAR2, p_message VARCHAR2, p_debug VARCHAR2 DEFAULT NULL);

PROCEDURE INITIALIZATION;

PROCEDURE POPULATE_THIRD_PARTY_TEMP (p_from_supp_name  VARCHAR2,
                                     p_from_supp_site  VARCHAR2,
                                     p_to_supp_name    VARCHAR2,
                                     p_to_supp_site    VARCHAR2,
                                     p_check_number    NUMBER,
                                     p_check_date      DATE,
                                     p_check_amount    NUMBER,
                                     p_invoice_number  VARCHAR2,
                                     p_invoice_amount  NUMBER,
                                     p_discount_amount NUMBER);

FUNCTION VENDOR_NAME(p_vendor_id NUMBER) RETURN VARCHAR2;

FUNCTION VENDOR_SITE(p_vendor_site_id NUMBER) RETURN VARCHAR2;

PROCEDURE PROCESS_TPP_CHECK_DETAIL_RECS;

PROCEDURE SUBMIT_REPORT;

-- -------------------------------------------------------------
--              PROCEDURE MAIN
-- -------------------------------------------------------------
-- This is called from the concurrent program to execute Third
-- Party Remittance Process. The purpose of this process is to
-- call all the subsequent procedures.
-- -------------------------------------------------------------
PROCEDURE MAIN(x_errbuf          OUT NOCOPY VARCHAR2,
               x_retcode         OUT NOCOPY NUMBER,
	       p_pay_date_from		    VARCHAR2,
	       p_pay_date_to		    VARCHAR2,
               p_checkrun_name              VARCHAR2,
	       p_from_supp_id		    NUMBER,
	       p_from_supp_site_id	    NUMBER,
	       p_to_supp_id		    NUMBER,
	       p_to_supp_site_id	    NUMBER,
	       p_sort_by		    VARCHAR2)
IS
  l_module_name VARCHAR2(200) ;
BEGIN

  l_module_name := g_module_name || 'MAIN';
   g_message := 'Starting Third Party Remittance process ...';
   Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

   g_message := '   Third Party Profile Option: '|| g_tpp_flag;
   Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

   g_message := '   Set Of Books Id: '|| g_sob_id;
   Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

   g_message := '   Organization Id: '|| g_org_id;
   Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

   g_pay_date_from := FND_DATE.CANONICAL_TO_DATE(p_pay_date_from);
   g_message := '   Payment Date From: '|| to_char(g_pay_date_from);
   Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

   g_pay_date_to := FND_DATE.CANONICAL_TO_DATE(p_pay_date_to);
   g_message := '   Payment Date To: '|| to_char(g_pay_date_to);
   Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

   g_checkrun_name := p_checkrun_name;
   g_message := '   Payment Batch Name: '|| g_checkrun_name;
   Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

   g_from_supp_id := p_from_supp_id;
   g_message := '   Original Supplier Id: '|| g_from_supp_id;
   Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

   IF (g_from_supp_id IS NOT NULL)
   THEN
      IF (g_retcode = 0)
      THEN
         g_from_supp_name := Vendor_Name(g_from_supp_id);
         g_message := '   Original Supplier Name: '|| g_from_supp_name;
	 Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);
      END IF;
   END IF;

   g_from_site_id := p_from_supp_site_id;
   g_message := '   Original Supplier Site Id: '|| g_from_site_id;
   Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

   IF (g_from_site_id IS NOT NULL)
   THEN
      IF (g_retcode = 0)
      THEN
         g_from_site_code := Vendor_Site(g_from_site_id);
	 g_message := '   Original Supplier Site: '|| g_from_site_code;
         Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);
      END IF;
   END IF;

   g_to_supp_id := p_to_supp_id;
   g_message := '   Third Party Agent Id: '|| g_to_supp_id;
   Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

   IF (g_to_supp_id IS NOT NULL)
   THEN
      IF (g_retcode = 0)
      THEN
	 g_to_supp_name := Vendor_Name(g_to_supp_id);
         g_message := '   Third Party Agent: '|| g_to_supp_name;
         Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);
      END IF;
   END IF;

   g_to_site_id := p_to_supp_site_id;
   g_message := '   Third Party Site Id: '|| g_to_site_id;
   Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

   IF (g_to_site_id IS NOT NULL)
   THEN
      IF (g_retcode = 0)
      THEN
         g_to_site_code := Vendor_Site(g_to_site_id);
         g_message := '   Third Party Site: '|| g_to_site_code;
	 Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);
      END IF;
   END IF;

   g_sort_by := p_sort_by;
   g_message := '   Sort By: '|| g_sort_by;
   Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

   IF (g_tpp_flag = 'N')
   THEN
      g_errbuf := 'Erroring out from Third Party Remittance Process because Third Party Profile Option is set to NO !!';
      g_retcode := 2;
      Log_Message(FND_LOG.LEVEL_ERROR,l_module_name,g_errbuf, 'N');
   ELSE
      -- Purge fv_third_party_temp table using Initialization procedure
      IF (g_retcode = 0)
      THEN
         Initialization;
      END IF;

      -- Process records in Fv_Tpp_Checks_Details table
      IF (g_retcode = 0)
      THEN
         Process_Tpp_Check_Detail_Recs;
      END IF;

      -- Print the Third Party Remittance Report
      IF (g_retcode = 0)
      THEN
         Submit_Report;
      END IF;
   END IF; /* Third Party Profile */

   -- Check for errors
   IF g_retcode <> 0
   THEN
      x_errbuf := g_errbuf;
      x_retcode := g_retcode;
      ROLLBACK;
   ELSE
      COMMIT;
   END IF;

   IF (g_retcode = 0) AND (g_data_found = 'N')
   THEN
      x_errbuf := 'NO DATA FOUND for Third Party Remittance reporting ...';
      Log_Message(FND_LOG.LEVEL_ERROR,l_module_name,x_errbuf, 'N');
   END IF;

   g_message := 'Ending Third Party Remittance process ...';
   Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);
EXCEPTION
   WHEN OTHERS THEN
      g_retcode := SQLCODE;
      g_errbuf  := SQLERRM || ' -- Error in the Main procedure';
      x_retcode := g_retcode;
      x_errbuf  := g_errbuf;
      Log_Message(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',g_errbuf, 'N');
END MAIN;


-- -------------------------------------------------------------
--              PROCEDURE LOG_MESSAGE
-- -------------------------------------------------------------
-- The purpose of this procedures is to accept a message and
-- print it to the log file.
-- -------------------------------------------------------------
PROCEDURE LOG_MESSAGE
(
  p_level  NUMBER,
  p_module VARCHAR2,
  p_message VARCHAR2,
  p_debug   VARCHAR2 DEFAULT NULL
) IS
  l_module_name VARCHAR2(200) ;
  l_debug VARCHAR2(1);
BEGIN
  IF p_debug IS NULL THEN
	l_debug := 'Y' ;
  ELSE
	l_debug := p_debug;
  END IF;
  l_module_name := g_module_name || 'LOG_MESSAGE';
  IF (l_debug = 'Y') THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(p_level, p_module, p_message);
    END IF;
  ELSE
    FV_UTILITY.LOG_MESG(p_level, p_module, p_message);
  END IF;
EXCEPTION
   WHEN OTHERS THEN
    g_errbuf  := SQLERRM;
    Log_Message(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',g_errbuf, 'N');
END LOG_MESSAGE;


-- -------------------------------------------------------------
--              PROCEDURE INITIALIZATION
-- -------------------------------------------------------------
-- The purpose of this procedure is to delete any existing data
-- from Fv_Third_Party_Temp table
-- -------------------------------------------------------------
PROCEDURE INITIALIZATION IS
  l_module_name VARCHAR2(200) ;
l_count NUMBER := 0;
BEGIN
   g_message := '   Purging Fv_Third_Party_Temp table ...';
  l_module_name  := g_module_name || 'INITIALIZATION';
   Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

   DELETE FROM fv_third_party_temp;
EXCEPTION
   WHEN OTHERS THEN
      g_retcode := SQLCODE;
      g_errbuf  := SQLERRM ||
                      ' -- Error in Initialization Procedure when purging fv_third_party_temp table';
      Log_Message(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',g_errbuf, 'N');
END INITIALIZATION;


-- -------------------------------------------------------------
--              PROCEDURE POPULATE_THIRD_PARTY_TEMP
-- -------------------------------------------------------------
-- The purpose of this procedure is to populate fv_third_party_
-- temp table.
-- -------------------------------------------------------------
PROCEDURE POPULATE_THIRD_PARTY_TEMP (p_from_supp_name  VARCHAR2,
			    	     p_from_supp_site  VARCHAR2,
				     p_to_supp_name    VARCHAR2,
				     p_to_supp_site    VARCHAR2,
				     p_check_number    NUMBER,
				     p_check_date      DATE,
				     p_check_amount    NUMBER,
				     p_invoice_number  VARCHAR2,
				     p_invoice_amount  NUMBER,
				     p_discount_amount NUMBER) IS
  l_module_name VARCHAR2(200) ;
BEGIN
   g_message := '     Inserting a record in Fv_Third_Party_Temp ...';
  l_module_name  := g_module_name || 'POPULATE_THIRD_PARTY_TEMP';
   Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);
   Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,'');

   INSERT INTO fv_third_party_temp
     (original_supplier_name,
      original_supplier_site,
      third_party_agent,
      third_party_site,
      check_number,
      check_date,
      check_amount,
      invoice_number,
      invoice_amount,
      discount_amount,
      org_id,
      set_of_books_id)
   VALUES
     (p_from_supp_name,
      p_from_supp_site,
      p_to_supp_name,
      p_to_supp_site,
      p_check_number,
      p_check_date,
      p_check_amount,
      p_invoice_number,
      p_invoice_amount,
      p_discount_amount,
      g_org_id,
      g_sob_id);
EXCEPTION
   WHEN OTHERS THEN
      g_retcode := SQLCODE;
      g_errbuf  := SQLERRM ||
                      ' -- Error in Populate_Third_Party_Temp Procedure when inserting record into fv_third_party_temp table';
      Log_Message(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',g_errbuf, 'N');
END POPULATE_THIRD_PARTY_TEMP;


-- -------------------------------------------------------------
--              FUNCTION VENDOR_NAME
-- -------------------------------------------------------------
-- The purpose of this function is return a vendor_name
-- corresponding to a vendor_id
-- -------------------------------------------------------------
FUNCTION VENDOR_NAME(p_vendor_id NUMBER) RETURN VARCHAR2 IS
  l_module_name VARCHAR2(200);
l_vendor_name Po_Vendors.vendor_name%TYPE;
BEGIN

l_module_name  := g_module_name || 'VENDOR_NAME';

   SELECT vendor_name
   INTO l_vendor_name
   FROM po_vendors
   WHERE vendor_id = p_vendor_id;

   RETURN(l_vendor_name);
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      l_vendor_name := NULL;

   WHEN OTHERS THEN
      g_retcode := SQLCODE;
      g_errbuf  := SQLERRM ||
                      ' -- Error in Vendor_Name Function finding vendor name';
      Log_Message(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',g_errbuf, 'N');
END VENDOR_NAME;


-- -------------------------------------------------------------
--              FUNCTION VENDOR_SITE
-- -------------------------------------------------------------
-- The purpose of this function is return a vendor_site_code
-- corresponding to a vendor_site_id
-- -------------------------------------------------------------
FUNCTION VENDOR_SITE(p_vendor_site_id NUMBER) RETURN VARCHAR2 IS
  l_module_name VARCHAR2(200) ;
l_vendor_site_code Po_Vendor_Sites.vendor_site_code%TYPE;
BEGIN

  l_module_name := g_module_name || 'VENDOR_SITE';

   SELECT vendor_site_code
   INTO l_vendor_site_code
   FROM po_vendor_sites
   WHERE vendor_site_id = p_vendor_site_id;

   RETURN(l_vendor_site_code);
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      l_vendor_site_code := NULL;

   WHEN OTHERS THEN
      g_retcode := SQLCODE;
      g_errbuf  := SQLERRM ||
                      ' -- Error in Vendor_Site Function finding vendor site code';
      Log_Message(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',g_errbuf, 'N');
END VENDOR_SITE;


-- -------------------------------------------------------------
--              PROCEDURE PROCESS_TPP_CHECK_DETAIL_RECS
-- -------------------------------------------------------------
-- The purpose of this procedure is to process records in
-- fv_tpp_check_details table for Third Party Remittance
-- reporting
-- -------------------------------------------------------------
PROCEDURE PROCESS_TPP_CHECK_DETAIL_RECS IS
  l_module_name VARCHAR2(200) ;
l_where_clause VARCHAR2(1000);
l_row_select   VARCHAR2(3000);
l_row_cursor   INTEGER;
l_row_fetch    INTEGER;
l_exec_ret     INTEGER;
l_original_supplier Po_Vendors.vendor_name%TYPE;
l_original_site     Po_Vendor_Sites.vendor_site_code%TYPE;
l_third_party_agent Po_Vendors.vendor_name%TYPE;
l_third_party_site  Po_Vendor_Sites.vendor_site_code%TYPE;
l_original_supplier_id Po_Vendors.vendor_id%TYPE;
l_original_site_id     Po_Vendor_Sites.vendor_site_id%TYPE;
l_third_party_agent_id Po_Vendors.vendor_id%TYPE;
l_third_party_site_id  Po_Vendor_Sites.vendor_site_id%TYPE;
l_check_id	    Ap_Checks.check_id%TYPE;
l_check_number      Ap_Checks.check_number%TYPE;
l_check_date        Ap_Checks.check_date%TYPE;
l_check_amount      Ap_Checks.amount%TYPE;
l_invoice_num       Ap_Invoices.invoice_num%TYPE;
l_invoice_amount    Ap_Invoices.invoice_amount%TYPE;
l_discount_amount   Ap_Invoices.discount_amount_taken%TYPE;
l_assignment_id     Fv_Tpp_Assignments.assignment_id%TYPE;
l_checkrun_name     Fv_Tpp_Check_Details.checkrun_name%TYPE;
l_check_num_fvtpp   Fv_Tpp_Check_Details.check_number%TYPE;
l_bank_account_id   Ap_Invoice_Selection_Criteria.bank_account_id%TYPE;
l_invoice_id	    Ap_Invoices.invoice_id%TYPE;
l_vendor_name	    Po_Vendors.vendor_name%TYPE;
l_site_code	    Po_Vendor_Sites.vendor_site_code%TYPE;
l_exists	VARCHAR2(1);
i		NUMBER := 0;
l	        NUMBER;
j		NUMBER;
k		NUMBER := 0;

CURSOR l_checks_invoices_cur IS
   SELECT apc.check_number, apc.check_date, apc.amount,
          invoice_num, invoice_amount, discount_amount_taken
   FROM  ap_checks apc, ap_invoice_payments apip, ap_invoices api
   WHERE apc.bank_account_id = l_bank_account_id
   AND apc.checkrun_name = l_checkrun_name
   AND apc.check_number = l_check_num_fvtpp
   AND apc.vendor_id = l_third_party_agent_id
   AND apc.vendor_site_id = l_third_party_site_id
   AND apc.check_id = apip.check_id
   AND apip.set_of_books_id = g_sob_id
   AND apip.invoice_id = api.invoice_id
   AND api.vendor_id = l_original_supplier_id
   AND api.vendor_site_id = l_original_site_id
   AND api.set_of_books_id = g_sob_id
   AND status_lookup_code IN ('CLEARED', 'CLEARED BUT UNACCOUNTED', 'ISSUED',
                              'NEGOTIABLE', 'RECONCILED', 'RECONCILED UNACCOUNTED');
BEGIN
  l_module_name := g_module_name || 'PROCESS_TPP_CHECK_DETAIL_RECS';
   g_message := '   Processing Fv_Tpp_Check_Detail records ...';
   Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

   BEGIN
      l_row_cursor := DBMS_SQL.OPEN_CURSOR;
   EXCEPTION
      WHEN OTHERS THEN
         g_retcode := SQLCODE;
	 g_errbuf := SQLERRM ||
  		        ' -- Error when opening the cursor in Process_Tpp_Check_Detail_Recs Procedure';
         Log_Message(FND_LOG.LEVEL_ERROR,l_module_name,g_errbuf, 'N');
   END;

   -- Build up the where clause and the from clause based on the
   -- parameters entered in the SRS request for Third Party
   -- Remittance process

   IF (g_from_supp_id IS NOT NULL) OR (g_from_site_id IS NOT NULL) OR
      (g_to_supp_id IS NOT NULL) OR (g_to_site_id IS NOT NULL)
   THEN
      l_where_clause := ' tpp.assignment_id = fvcd.assignment_id AND ';
   END IF;

   IF (g_checkrun_name IS NOT NULL)
   THEN
      l_where_clause := l_where_clause || ' fvcd.checkrun_name = ' || '''' || g_checkrun_name || '''' || ' AND ';
   END IF;

   IF (g_from_supp_id IS NOT NULL)
   THEN
      l_where_clause := l_where_clause || ' tpp.original_supplier_id = '|| g_from_supp_id || ' AND ';
   END IF;

   IF (g_from_site_id IS NOT NULL)
   THEN
      l_where_clause := l_where_clause || ' tpp.original_supplier_site_id = '|| g_from_site_id || ' AND ';
   END IF;

   IF (g_to_supp_id IS NOT NULL)
   THEN
      l_where_clause := l_where_clause || ' tpp.third_party_agent_id = '|| g_to_supp_id || ' AND ';
   END IF;

   IF (g_to_site_id IS NOT NULL)
   THEN
      l_where_clause := l_where_clause || ' tpp.third_party_site_id = '|| g_to_site_id || ' AND ';
   END IF;

   IF (g_pay_date_from IS NOT NULL)
   THEN
      l_where_clause := l_where_clause || ' apisc.check_date >= ' || '''' || g_pay_date_from || '''' ||  ' AND ';
   END IF;

   IF (g_pay_date_to IS NOT NULL)
   THEN
      l_where_clause := l_where_clause || ' apisc.check_date <= ' || '''' || g_pay_date_to || '''' || ' AND ';
   END IF;

   l_row_select := '
      SELECT fvcd.assignment_id, tpp.original_supplier_id, tpp.original_supplier_site_id,
	     tpp.third_party_agent_id, tpp.third_party_site_id, fvcd.checkrun_name, fvcd.check_number
      FROM fv_tpp_check_details fvcd, fv_tpp_assignments_all tpp, ap_invoice_selection_criteria apisc
      WHERE '|| l_where_clause ||'
            fvcd.checkrun_name = apisc.checkrun_name
      AND   apisc.status = '||''''|| 'CONFIRMED' ||''''||'
      AND   fvcd.set_of_books_id = '|| g_sob_id ||'
      AND   tpp.set_of_books_id = '|| g_sob_id ||'
      AND   tpp.org_id = '|| g_org_id ||'
      AND   fvcd.assignment_id = tpp.assignment_id';

   g_message := l_row_select;
   Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);
   Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,'');

   BEGIN
      DBMS_SQL.PARSE(l_row_cursor, l_row_select, DBMS_SQL.V7);
   EXCEPTION
      WHEN OTHERS THEN
	 g_retcode := SQLCODE;
	 g_errbuf  := SQLERRM ||
			 ' -- Error when parsing through the cursor in Process_Tpp_Check_Detail_Recs Procedure';
	 Log_Message(FND_LOG.LEVEL_ERROR,l_module_name,g_errbuf, 'N');
   END;

   DBMS_SQL.DEFINE_COLUMN(l_row_cursor, 1, l_assignment_id);
   DBMS_SQL.DEFINE_COLUMN(l_row_cursor, 2, l_original_supplier_id);
   DBMS_SQL.DEFINE_COLUMN(l_row_cursor, 3, l_original_site_id);
   DBMS_SQL.DEFINE_COLUMN(l_row_cursor, 4, l_third_party_agent_id);
   DBMS_SQL.DEFINE_COLUMN(l_row_cursor, 5, l_third_party_site_id);
   DBMS_SQL.DEFINE_COLUMN(l_row_cursor, 6, l_checkrun_name, 50);
   DBMS_SQL.DEFINE_COLUMN(l_row_cursor, 7, l_check_num_fvtpp);

   BEGIN
      l_exec_ret := DBMS_SQL.EXECUTE(l_row_cursor);
   EXCEPTION
      WHEN OTHERS THEN
	 g_retcode := SQLCODE;
	 g_errbuf  := SQLERRM ||
		         ' -- Error when executing the cursor in Process_Tpp_Check_Detail_Recs Procedure';
	 Log_Message(FND_LOG.LEVEL_ERROR,l_module_name,g_errbuf, 'N');
   END;

   LOOP
      l_assignment_id := NULL;
      l_checkrun_name := NULL;
      l_check_number := NULL;
      l_bank_account_id := NULL;
      l_invoice_id := NULL;
      l_vendor_name := NULL;
      l_site_code := NULL;
      l_original_supplier := NULL;
      l_original_site := NULL;
      l_third_party_agent := NULL;
      l_third_party_site := NULL;
      l_original_supplier_id := NULL;
      l_original_site_id := NULL;
      l_third_party_agent_id := NULL;
      l_third_party_site_id := NULL;
      l_check_number := NULL;
      l_check_date := NULL;
      l_check_amount := NULL;
      l_invoice_num := NULL;
      l_invoice_amount := NULL;
      l_discount_amount := NULL;
      l_check_num_fvtpp := NULL;

      l_row_fetch := DBMS_SQL.FETCH_ROWS(l_row_cursor);

      IF (l_row_fetch = 0)
      THEN
	 IF (k = 0)
	 THEN
            g_message := '   NO DATA FOUND : Found no rows that satisfy the search criteria - Exiting from Process_Tpp_Check_Detail_Recs Procedure';
            Log_Message(FND_LOG.LEVEL_ERROR,l_module_name,g_message, 'N');
  	    g_data_found := 'N';
	 END IF;

         EXIT; -- Exit the loop
      ELSE
	 g_data_found := 'Y';
      END IF;

      k := k + 1;

      DBMS_SQL.COLUMN_VALUE(l_row_cursor, 1, l_assignment_id);
      DBMS_SQL.COLUMN_VALUE(l_row_cursor, 2, l_original_supplier_id);
      DBMS_SQL.COLUMN_VALUE(l_row_cursor, 3, l_original_site_id);
      DBMS_SQL.COLUMN_VALUE(l_row_cursor, 4, l_third_party_agent_id);
      DBMS_SQL.COLUMN_VALUE(l_row_cursor, 5, l_third_party_site_id);
      DBMS_SQL.COLUMN_VALUE(l_row_cursor, 6, l_checkrun_name);
      DBMS_SQL.COLUMN_VALUE(l_row_cursor, 7, l_check_num_fvtpp);

      g_message := '    Assignment Id: '|| l_assignment_id;
      Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

      IF (g_checkrun_name IS NULL)
      THEN
         g_message := '    Payment Batch Name: '|| l_checkrun_name;
         Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);
      END IF;

      BEGIN
	  SELECT bank_account_id
	  INTO l_bank_account_id
	  FROM ap_invoice_selection_criteria
	  WHERE checkrun_name = l_checkrun_name;

          g_message := '    Bank Account Id: '|| l_bank_account_id;
	  Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);
      EXCEPTION
	 WHEN OTHERS THEN
	    g_retcode := SQLCODE;
	    g_errbuf  := SQLERRM ||
			    ' -- Error in Process_Tpp_Check_Detail_Recs Procedure when finding bank_account_id for the Payment Batch';
	    Log_Message(FND_LOG.LEVEL_ERROR,l_module_name,g_errbuf, 'N');
      END;

      FOR l_checks_invoices_rec IN l_checks_invoices_cur
      LOOP
         l_check_number := l_checks_invoices_rec.check_number;
         l_check_date   := l_checks_invoices_rec.check_date;
         l_check_amount := l_checks_invoices_rec.amount;
         l_invoice_num  := l_checks_invoices_rec.invoice_num;
         l_invoice_amount  := l_checks_invoices_rec.invoice_amount;
         l_discount_amount := l_checks_invoices_rec.discount_amount_taken;

         g_message := '    Check Number: '|| l_check_number;
         Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

         g_message := '    Check Date: '|| l_check_date;
         Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

         g_message := '    Check Amount: '|| l_check_amount;
	 Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

         g_message := '    Invoice Number: '|| l_invoice_num;
         Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

         g_message := '    Invoice Amount: '|| l_invoice_amount;
         Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

         g_message := '    Discount Amount Taken: '|| l_discount_amount;
         Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

	 -- Set the values for the FOR loop range below, depending
   	 -- on the Original/Third Party Agent name and site
	 -- parameter values for Third Party Remittance SRS

	 IF (g_from_supp_id IS NULL) OR (g_from_site_id IS NULL) OR
   	    (g_to_supp_id IS NULL) OR (g_to_site_id IS NULL)
	 THEN
	    l := 1;
	    j := 2;
	 ELSIF (g_from_supp_id IS NULL) OR (g_from_site_id IS NULL)
   	 THEN
	    l := 1;
	    j := 1;
	 ELSIF (g_to_supp_id IS NULL) OR (g_to_site_id IS NULL)
   	 THEN
	    l := 2;
	    j := 2;
         ELSE
	    l := 0;
	    j := 0;
	    l_original_supplier := g_from_supp_name;
	    l_original_site     := g_from_site_code;
	    l_third_party_agent := g_to_supp_name;
	    l_third_party_site  := g_to_site_code;
	 END IF;

	 -- Select the Original and Third Party info
   	 -- if not specified as SRS parameters

    	 IF (l <> 0) AND (j <> 0)
    	 THEN
	    FOR i IN l .. j
	    LOOP
	       BEGIN
	          SELECT pv.vendor_name, ps.vendor_site_code
	          INTO l_vendor_name, l_site_code
	          FROM po_vendors pv, po_vendor_sites ps,
  	               fv_tpp_assignments_all fv
	          WHERE fv.assignment_id = l_assignment_id
		  AND fv.set_of_books_id = g_sob_id
		  AND fv.org_id = g_org_id
	          AND pv.vendor_id = DECODE(i, 1, fv.original_supplier_id,
	                        	       2, fv.third_party_agent_id)
	          AND ps.vendor_site_id = DECODE(i, 1, fv.original_supplier_site_id,
					            2, fv.third_party_site_id);

	       EXCEPTION
	          WHEN OTHERS THEN
	             g_retcode := SQLCODE;
		     IF i = 1
	 	     THEN
		        g_errbuf  := SQLERRM ||
			                ' -- Error in Process_Tpp_Check_Detail_Recs Procedure when finding Original vendor info';
	 	     ELSIF i = 2
		     THEN
		        g_errbuf := SQLERRM ||
				       ' -- Error in Process_Tpp_Check_Detail_Recs Procedure when finding Third Party vendor info';

		     END IF;
		     Log_Message(FND_LOG.LEVEL_ERROR,l_module_name,g_errbuf, 'N');
	       END;

	       IF i = 1
	       THEN
	          l_original_supplier := l_vendor_name;
	          l_original_site := l_site_code;

  	          g_message := '    Original Supplier: '|| l_original_supplier;
	          Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

	          g_message := '    Original Supplier Site: '|| l_original_site;
	          Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

	       ELSE
	          l_third_party_agent := l_vendor_name;
	          l_third_party_site := l_site_code;

	          g_message := '    Third Party Agent: '|| l_third_party_agent;
	          Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

	          g_message := '    Third Party Site: '|| l_third_party_site;
	          Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);
	       END IF;
	    END LOOP;
   	 END IF; /* l <> 0 AND j <> 0 */

         POPULATE_THIRD_PARTY_TEMP (l_original_supplier, l_original_site, l_third_party_agent,
                                    l_third_party_site, l_check_number, l_check_date,
                                    l_check_amount, l_invoice_num, l_invoice_amount,
                                    l_discount_amount);
      END LOOP; /* l_checks_invoices_rec */
   END LOOP;

   DBMS_SQL.CLOSE_CURSOR(l_row_cursor);

EXCEPTION
   WHEN OTHERS THEN
      g_retcode := SQLCODE;
      g_errbuf  := SQLERRM ||
                      ' -- Error in Process_Tpp_Check_Detail_Recs Procedure';
      Log_Message(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',g_errbuf, 'N');
END PROCESS_TPP_CHECK_DETAIL_RECS;


-- -------------------------------------------------------------
--              PROCEDURE SUBMIT_REPORT
-- -------------------------------------------------------------
-- The purpose of this procedure is to submit Third Party
-- Remittance Report.
-- -------------------------------------------------------------
PROCEDURE SUBMIT_REPORT IS
  l_module_name VARCHAR2(200) ;
l_req_id NUMBER;
l_call_status BOOLEAN;
l_rphase      VARCHAR2(30);
l_rstatus     VARCHAR2(30);
l_dphase      VARCHAR2(30);
l_dstatus     VARCHAR2(30);
l_message     VARCHAR2(240);
BEGIN
   g_message := '';
  l_module_name  := g_module_name || 'SUBMIT_REPORT';
   Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

   g_message := '   Submitting the Third Party Remittance report ...';
   Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

   l_req_id := FND_REQUEST.SUBMIT_REQUEST('FV', 'FVTPPREM', '', '', FALSE,
					  g_sob_id, g_org_id,
					  g_checkrun_name, g_pay_date_from,
					  g_pay_date_to, g_from_supp_name,
					  g_from_site_code, g_to_supp_name,
					  g_to_site_code, g_sort_by);

   g_message := '    Request Id: '|| l_req_id;
   Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

   IF (l_req_id = 0)
   THEN
      g_message := '     Cannot submit Third Party Remittance report';
      Log_Message(FND_LOG.LEVEL_ERROR,l_module_name,g_message, 'N');

      g_retcode := 2;
      g_errbuf := g_message;

      ROLLBACK;
      RETURN;
   ELSE
      g_message := '     Third Party Remittance report submitted';
      Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

      COMMIT;
   END IF;

   l_call_status := Fnd_Concurrent.Wait_For_Request(l_req_id, 20, 0, l_rphase , l_rstatus,
                                                    l_dphase, l_dstatus, l_message);

   IF (l_call_status = FALSE)
   THEN
      g_message := '     Cannot wait for the status of Third Party Payments report: '|| l_message;
      Log_Message(FND_LOG.LEVEL_ERROR,l_module_name,g_message, 'N');

      g_retcode := 2;
      g_errbuf := g_message;
   ELSE
      IF (l_dphase = 'COMPLETE' AND l_dstatus = 'NORMAL')
      THEN
         g_message := '     Third Party Payments report completed normal';
         Log_Message(FND_LOG.LEVEL_STATEMENT,l_module_name,g_message);

         COMMIT;
      ELSE
         g_message := '     Third Party Payments report did not complete normally: '|| l_message;
         Log_Message(FND_LOG.LEVEL_ERROR,l_module_name,g_message, 'N');

         g_retcode := 2;
         g_errbuf := g_message;
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      g_retcode := SQLCODE;
      g_errbuf  := SQLERRM ||
                      ' -- Error in Submit_Report Procedure';
      Log_Message(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',g_errbuf, 'N');
END SUBMIT_REPORT;
BEGIN

--MOAC changes, to derive the org_id and sob_id

  g_module_name  := 'fv.plsql.FV_THIRD_PARTY_REMIT_PKG.';
--g_org_id       := TO_NUMBER(FND_PROFILE.VALUE('ORG_ID'));
  g_org_id       := MO_GLOBAL.get_current_org_id;
--g_sob_id       := FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');
  g_debug_flag   := NVL(FND_PROFILE.VALUE('FV_DEBUG_FLAG'), 'N');
  g_tpp_flag 	 := NVL(FND_PROFILE.VALUE('FV_THIRD_PARTY_PAYMENT'), 'N');
  g_data_found   := 'N';
  MO_UTILS.get_ledger_info(p_operating_unit => g_org_id,
                           p_ledger_id => g_sob_id,
                           p_ledger_name => g_sob_name);

END FV_THIRD_PARTY_REMIT_PKG;

/
