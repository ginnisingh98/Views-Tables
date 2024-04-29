--------------------------------------------------------
--  DDL for Package Body FV_SF1080_TRANSACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_SF1080_TRANSACTION" AS
--$Header: FVX1080B.pls 120.15 2006/01/18 19:01:52 ksriniva ship $
--	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('FV_DEBUG_FLAG'),'N');
  g_module_name VARCHAR2(100) ;

--
-- ------------------------------------
-- Stored Input Parameters
-- ------------------------------------
	  parm_chart_of_accounts_id             NUMBER;
          parm_set_of_books_id            NUMBER;
          parm_order_by                   VARCHAR2(30);
          parm_batch                      NUMBER(15);
          parm_transaction_class          VARCHAR2(30);
          parm_transaction_type           NUMBER(15);
          parm_trans_num_low              VARCHAR2(20);
          parm_trans_num_high             VARCHAR2(20);
          parm_print_date_low             DATE;
          parm_print_date_high            DATE;
          parm_cust_profile_class_id      NUMBER(15);
          parm_customer_class             VARCHAR2(30);
          parm_customer                   VARCHAR2(360);
          parm_open_invoices_only         VARCHAR2(3);
          parm_office_charged             VARCHAR2(50);
	  parm_print_choice	          VARCHAR2(30);

--
-- ------------------------------------
-- Stored Global Variables
-- ------------------------------------
--
  g_error_code                  NUMBER;
  g_error_message               VARCHAR2(80);
--
--
-- ---------- Transactions Report Header Cursor Vaiables -----------
  remit_address1	   hz_locations.address1%TYPE;
  remit_address2           hz_locations.address2%TYPE;
  remit_address3           hz_locations.address3%TYPE;
  remit_address4           hz_locations.address4%TYPE;
  remit_city               hz_locations.city%TYPE;
  remit_state              hz_locations.state%TYPE;
  remit_postal_code        hz_locations.postal_code%TYPE;
  line_count		   number;
  line_counter      	   number;
  line_count_flag	   number;
  segment		   varchar2(800);
--

-- ---------- Define Report Transaction Header Cursor -------------
---
  PROCEDURE a100_clear_report_temp_table;
--
  PROCEDURE a200_load_report_tables;
--
--
  abort_error                     EXCEPTION;
  report_failure		  EXCEPTION;
--
-- ---------- End of Package Level Declaritives -----------------------------
--
PROCEDURE a000_load_table
       	  (error_code       OUT NOCOPY  NUMBER,
          error_message     OUT NOCOPY  VARCHAR2,
          order_by                IN   VARCHAR2,
          batch                   IN   NUMBER,
          transaction_class       IN   VARCHAR2,
          transaction_type        IN   NUMBER,
          trans_num_low           IN   VARCHAR2,
          trans_num_high          IN   VARCHAR2,
          print_date_low          IN   VARCHAR2,
          print_date_high         IN   VARCHAR2,
          cust_profile_class_id   IN   NUMBER,
          customer_class          IN   VARCHAR2,
          customer                IN   VARCHAR2,
          open_invoices_only      IN   VARCHAR2,
          office_charged          IN   VARCHAR2,
	  print_choice		  IN   VARCHAR2)
--
IS
--
  l_module_name VARCHAR2(200) ;
  l_status VARCHAR2(2) ;
  l_currency VARCHAR2(50) ;
  l_request_id NUMBER;
 -- number to handle the return value of the submit request

BEGIN
--
-- ------------------------------------
-- Store Input Parameters in Global Variables
-- ------------------------------------

  l_module_name := g_module_name || 'a000_load_table';
  parm_order_by := order_by;
  parm_batch  := batch;
  parm_transaction_class := transaction_class;
  parm_transaction_type := transaction_type;
  parm_trans_num_low := trans_num_low;
  parm_trans_num_high := trans_num_high;
  parm_print_date_low  := FND_DATE.CANONICAL_TO_DATE(print_date_low);
  parm_print_date_high := FND_DATE.CANONICAL_TO_DATE(print_date_high);
  parm_cust_profile_class_id  := cust_profile_class_id;
  parm_customer_class := customer_class;
  parm_customer := customer;
  parm_open_invoices_only := open_invoices_only;
  parm_office_charged := office_charged;
  parm_print_choice := print_choice;


--  Derive SOB,COA

   FV_utility.get_ledger_info(mo_global.get_current_org_id,parm_set_of_books_id,
                                  parm_chart_of_accounts_id,
                                  l_currency,l_status);
 If l_status = 0 then

    error_code    := 0;
    error_message := '?';
    g_error_code := 0;
    g_error_message := '?';

-- Delete All Entries from Report Temp Table
    a100_clear_report_temp_table;

  IF g_error_code = 0 THEN

-- ----------------------------------------
-- Load Report Lines
-- ----------------------------------------

    a200_load_report_tables;

     fnd_request.set_org_id(mo_global.get_current_org_id);
--- Kick Off the SL1080 report
     l_request_id :=fnd_request.submit_request(
 	application => 'FV',
	program => 'FVSF1080_NEW',
	description=>'',
	start_time=>'',
	sub_request => FALSE,
	argument1 => parm_set_of_books_id,
	argument2 => order_by);
     IF (l_request_id = 0) THEN
	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'l_request_id is'||l_request_id);
	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'argument1 is'||parm_set_of_books_id);
	RAISE report_failure;
     ELSE
	COMMIT;
     END IF;
   END IF;
 Else
   g_error_code := -1;
   error_message := 'Cannot get current org_id or Ledger info';
End if;

  IF g_error_code <> 0 THEN
    RAISE abort_error;
  END IF;

  error_code    := g_error_code;
  error_message := 'Normal End of FVSF1080 Package';
-- ------------------------------------
-- Exceptions
-- ------------------------------------
EXCEPTION
--
  WHEN abort_error THEN
    error_code    := g_error_code;
    error_message := g_error_message;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.abort_error',g_error_message);

--- in case the report submission is not successful ---
  WHEN report_failure THEN
     g_error_message := 'Submission of FVSF1080 Report failed';
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.report_failure',g_error_message);

  WHEN OTHERS THEN
    g_error_code := SQLCODE;
    g_error_message := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_message);
    RAISE_APPLICATION_ERROR(-20222,
                            'FVSF1080 Exception-'||g_error_message);
--
END a000_load_table;
-- ------------------------------------------------------------------
-- This procedure deletes records from temporary tables.
-- --------------------------------------------------------
PROCEDURE a100_clear_report_temp_table
--
IS
--
  l_module_name VARCHAR2(200) ;
BEGIN
--
---FV_UTILITY.DEBUG_MESG('Start a100_clear_report_temp_table');
--
  l_module_name := g_module_name || 'a100_clear_report_temp_table';

  BEGIN

  	DELETE
    	FROM FV_SF1080_HEADER_TEMP;
  	---FV_UTILITY.DEBUG_MESG('Deleting from FV_SF1080_HEADER_TEMP');
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		NULL;
	WHEN OTHERS THEN
		g_error_code := SQLCODE;
		g_error_message := 'a100_clear_report_header_table: /'||SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error1',g_error_message);
  END;

  BEGIN
	DELETE
   	FROM FV_SF1080_DETAIL_TEMP;
  	---FV_UTILITY.DEBUG_MESG('Deleting from FV_SF1080_DETAIL_TEMP');
 EXCEPTION
        WHEN NO_DATA_FOUND THEN
                NULL;
        WHEN OTHERS THEN
                g_error_code := SQLCODE;
                g_error_message := 'a100_clear_report_detail_table: /'||SQLERRM;
                FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_message);
 END;
--
COMMIT;
--
--
END a100_clear_report_temp_table;
--
-- --------------------------------------------------------
-- This procedure loads the three temporary tables by reading
-- records from the cursor.
-- --------------------------------------------------------
--
PROCEDURE a200_load_report_tables
--
AS
  l_module_name VARCHAR2(200);
CURSOR ts_report_header_cursor
      IS
   SELECT
           rct.customer_trx_id               customer_trx_id,
           rct.trx_number                    trx_number,
           rct.bill_to_customer_id           bill_to_customer_id,
           rct.remit_to_address_id           remit_to_address_id,
           hzp.party_name                    customer_name,
           hzl.address1                      cust_address1,
           hzl.address2                      cust_address2,
           hzl.address3                      cust_address3,
           hzl.address4                      cust_address4,
           hzl.city                          cust_city,
           hzl.state                         cust_state,
           hzl.postal_code                   cust_postal_code
   FROM RA_CUSTOMER_TRX rct,
         hz_locations hzl, hz_cust_acct_sites hzcas,
         hz_party_sites hzps , HZ_CUST_SITE_USEs hzcsu,hz_cust_accounts hzca, hz_parties hzp
   WHERE  rct.set_of_books_id = parm_set_of_books_id
   AND    rct.bill_to_customer_id =  hzca.cust_account_id
   AND    hzca.cust_Account_id = hzcas.cust_account_id
   AND     hzp.party_id = hzca.party_id
   AND hzca.cust_account_id = hzcas.cust_account_id
   AND        hzca.party_id = hzp.party_id
   And   hzcas.party_site_id = hzps.party_site_id
   AND hzps.location_id = hzl.location_id
   AND hzcsu.Cust_Acct_site_ID = hzcas.CUST_ACCT_SITE_ID
   AND    rct.complete_flag = 'Y'
   AND    rct.printing_option = 'PRI'
   AND    hzcsu.site_use_id = rct.bill_to_site_use_id
   AND    rct.bill_to_customer_id IN
          (SELECT cust_account_id
	   FROM   hz_customer_profiles
	   WHERE  profile_class_id = decode(parm_cust_profile_class_id,null,
					      profile_class_id,parm_cust_profile_class_id))
   AND    rct.cust_trx_type_id IN
           ((SELECT CUST_TRX_TYPE_ID
                FROM RA_CUST_TRX_TYPES
                WHERE TYPE LIKE NVL(parm_transaction_class,'%'))
        intersect
           (SELECT CUST_TRX_TYPE_ID
                FROM RA_CUST_TRX_TYPES
                WHERE CUST_TRX_TYPE_ID = decode(parm_transaction_type,null,
		CUST_TRX_TYPE_ID,parm_transaction_type)))
    AND   (rct.trx_number between nvl(parm_trans_num_low,'0')
                and nvl(parm_trans_num_high,'ZZZZZZZZZZZZZZZZZZZZ'))
   AND    rct.trx_date between DECODE(parm_print_date_low,null,TO_DATE('1990/1/1','yyyy/mm/dd'),
					parm_print_date_low)
   AND     DECODE(parm_print_date_high,null,trunc(sysdate),parm_print_date_high )
   AND    hzca.cust_account_id IN
        ((SELECT cust_account_id
          FROM hz_cust_accounts hzca
          WHERE NVL(customer_class_code,'XXX') LIKE DECODE(parm_customer_class,null,
							NVL(customer_class_code,'XXX'),parm_customer_class))
        INTERSECT
        (SELECT cust_account_id
        FROM hz_cust_accounts hzca
        WHERE cust_account_id like nvl(parm_customer,'%')))
   and rct.customer_trx_id in
                (SELECT CUSTOMER_TRX_ID
                FROM RA_CUSTOMER_TRX
                WHERE nvl(status_trx,'-1') LIKE decode(parm_open_invoices_only,'Y','OP','N','%'))
        AND rct.customer_trx_id IN
                (SELECT CUSTOMER_TRX_ID
                FROM RA_CUSTOMER_TRX
                WHERE batch_id IN
                        (SELECT BATCH_ID
                        FROM RA_BATCHES
                        WHERE BATCH_ID = decode(parm_batch,null,BATCH_ID,parm_batch))
		OR (nvl(BATCH_ID,'99') LIKE decode(parm_print_choice,'SEL','99','NEW','99')))
        AND rct.customer_trx_id IN
                (SELECT rct.CUSTOMER_TRX_ID
                FROM RA_CUSTOMER_TRX rct
                WHERE (nvl(rct.printing_count,'99') like
                        decode(parm_print_choice,'NEW','99','%'))
                AND (nvl(to_char(rct.printing_original_date,'DD-MM-YYYY'),'01-01-1999') like
                        decode(parm_print_choice,'NEW','01-01-1999','%'))
                AND (nvl(to_char(rct.printing_last_printed,'DD-MM-YYYY'),'01-01-1999') like
                        decode(parm_print_choice,'NEW','01-01-1999','%')))
        ORDER BY decode(parm_order_by,'TRX_NUMBER',rct.trx_number,
                                'POSTAL_CODE',hzl.postal_code,
				'CUSTOMER_NAME',hzp.party_name,rct.trx_number);
--
-- ----------------------------------------
BEGIN

	 l_module_name  := g_module_name || 'a200_load_report_tables';

--
    ---FV_UTILITY.DEBUG_MESG('Start a200_load_report_tables');
    ---FV_UTILITY.DEBUG_MESG('parm_chart_of_accounts_id = ' || parm_chart_of_accounts_id);
    ---FV_UTILITY.DEBUG_MESG('parm_set_of_books_id = ' || parm_set_of_books_id);
    ---FV_UTILITY.DEBUG_MESG('parm_order_by = ' || parm_order_by);
    ---FV_UTILITY.DEBUG_MESG('parm_batch = ' || parm_batch);
    ---FV_UTILITY.DEBUG_MESG('parm_transaction_class = ' || parm_transaction_class);
    ---FV_UTILITY.DEBUG_MESG('parm_transaction_type = ' || parm_transaction_type);
    ---FV_UTILITY.DEBUG_MESG('parm_trans_num_low = ' ||  parm_trans_num_low);
    ---FV_UTILITY.DEBUG_MESG('parm_trans_num_high = ' || parm_trans_num_high);
    ---FV_UTILITY.DEBUG_MESG('parm_print_date_low = ' || parm_print_date_low);
    ---FV_UTILITY.DEBUG_MESG('parm_print_date_high = ' ||  parm_print_date_high);
    ---FV_UTILITY.DEBUG_MESG('parm_customer_class = ' || parm_customer_class);
    ---FV_UTILITY.DEBUG_MESG('parm_customer = ' || parm_customer);
    ---FV_UTILITY.DEBUG_MESG('parm_open_invoices_only = ' || parm_open_invoices_only);
    ---FV_UTILITY.DEBUG_MESG('parm_office_charged = ' || parm_office_charged);
    ---FV_UTILITY.DEBUG_MESG('parm_print_choice = ' || parm_print_choice);

--
-- This for loop selects the remit address and then inserts into FV_SF1080_
-- HEADER_TEMP table based on cursor records.
---
  FOR ts_report_header_entry IN ts_report_header_cursor LOOP
--
	---FV_UTILITY.DEBUG_MESG('Inside the header cursor');
	---FV_UTILITY.DEBUG_MESG('customer_trx_id = '||TS_REPORT_HEADER_ENTRY.customer_trx_id);

	BEGIN
	SELECT ADDRESS1,ADDRESS2,ADDRESS3,ADDRESS4,CITY,STATE,POSTAL_CODE
	INTO REMIT_ADDRESS1,REMIT_ADDRESS2,REMIT_ADDRESS3,REMIT_ADDRESS4,
		REMIT_CITY,REMIT_STATE,REMIT_POSTAL_CODE
	FROM hz_locations hzl, hz_cust_acct_sites hzcas, hz_party_sites hzps
	WHERE hzcas.cust_Acct_site_id =
                 TS_REPORT_HEADER_ENTRY.REMIT_TO_ADDRESS_ID
	AND hzcas.party_site_id = hzps.party_site_id
	 AND    hzps.location_id = hzl.location_id;
	---FV_UTILITY.DEBUG_MESG('remit_address1 = '||REMIT_ADDRESS1);
	---FV_UTILITY.DEBUG_MESG('remit_address2 = '||REMIT_ADDRESS2);
	---FV_UTILITY.DEBUG_MESG('remit_address3 = '||REMIT_ADDRESS3);
	---FV_UTILITY.DEBUG_MESG('remit_address4 = '||REMIT_ADDRESS4);
	EXCEPTION
  		WHEN NO_DATA_FOUND THEN
			REMIT_ADDRESS1 := ' ';
			REMIT_ADDRESS2 := NULL;
			REMIT_ADDRESS3 := NULL;
			REMIT_ADDRESS4 := NULL;
			REMIT_CITY := NULL;
			REMIT_STATE := NULL;
			REMIT_POSTAL_CODE := NULL;
  		WHEN OTHERS THEN
    			g_error_code    := SQLCODE;
    			g_error_message := 'remit_address_info: /'||SQLERRM;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error3',g_error_message);
	END;

	Begin
	INSERT INTO FV_SF1080_HEADER_TEMP
	( CUSTOMER_TRX_ID,
	 TRX_NUMBER,
	 CUSTOMER_NAME,
	 CUST_ADDRESS1,
	 REMIT_TO_ADDRESS_ADDRESS1,
	 CUST_ADDRESS2,
	 CUST_ADDRESS3,
	 CUST_ADDRESS4,
	 CUST_CITY,
	 CUST_STATE,
	 CUST_POSTAL_CODE,
	 REMIT_TO_ADDRESS_ADDRESS2,
	 REMIT_TO_ADDRESS_ADDRESS3,
	 REMIT_TO_ADDRESS_ADDRESS4,
	 REMIT_TO_ADDRESS_CITY,
	 REMIT_TO_ADDRESS_STATE,
	 REMIT_TO_ADDRESS_POSTAL_CODE,
	 ACCT_OFC_CHRG)
	VALUES
	(TS_REPORT_HEADER_ENTRY.CUSTOMER_TRX_ID,
	 TS_REPORT_HEADER_ENTRY.TRX_NUMBER,
	 TS_REPORT_HEADER_ENTRY.CUSTOMER_NAME,
	 TS_REPORT_HEADER_ENTRY.CUST_ADDRESS1,
	 REMIT_ADDRESS1,
	 TS_REPORT_HEADER_ENTRY.CUST_ADDRESS2,
	 TS_REPORT_HEADER_ENTRY.CUST_ADDRESS3,
	 TS_REPORT_HEADER_ENTRY.CUST_ADDRESS4,
	 TS_REPORT_HEADER_ENTRY.CUST_CITY,
	 TS_REPORT_HEADER_ENTRY.CUST_STATE,
	 TS_REPORT_HEADER_ENTRY.CUST_POSTAL_CODE,
	 REMIT_ADDRESS2,
	 REMIT_ADDRESS3,
	 REMIT_ADDRESS4,
         REMIT_CITY,
	 REMIT_STATE,
	 REMIT_POSTAL_CODE,
	 PARM_OFFICE_CHARGED);
	EXCEPTION
                WHEN OTHERS THEN
                        g_error_code    := SQLCODE;
                        g_error_message := 'INSERT_HEADER_info: /'||SQLERRM;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error2',g_error_message);
        END;

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CUSTOMER_TRX_ID = ' || TS_REPORT_HEADER_ENTRY.CUSTOMER_TRX_ID);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TRX_NUMBER = ' ||TS_REPORT_HEADER_ENTRY.TRX_NUMBER);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CUSTOMER_NAME = ' || TS_REPORT_HEADER_ENTRY.CUSTOMER_NAME);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CUST_POSTAL_CODE = ' || TS_REPORT_HEADER_ENTRY.CUST_POSTAL_CODE);
	END IF;
	BEGIN
        LINE_COUNT := 0;
        line_count_flag := 0;
	SELECT COUNT(*)
	INTO LINE_COUNT
	FROM RA_CUSTOMER_TRX_LINES
	WHERE CUSTOMER_TRX_ID = TS_REPORT_HEADER_ENTRY.CUSTOMER_TRX_ID;
	---FV_UTILITY.DEBUG_MESG('line_count = ' ||line_count);
	EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        line_count_flag := 1;
                WHEN OTHERS THEN
                        g_error_code    := SQLCODE;
                        g_error_message := 'line_count_info: /'||SQLERRM;
                        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error1',g_error_message);
        END;

	BEGIN
	segment := NULL;

-- Commented out this piece of code because the accounting classification
-- section of the report is no longer needed
-- Uncommenetd the below code for the Bug 2138767

	SELECT decode(glc.segment1,null,null,glc.segment1)||
                        decode(glc.segment2,null,null,'.'||glc.segment2)||
                        decode(glc.segment3,null,null,'.'||glc.segment3)||
                        decode(glc.segment4,null,null,'.'||glc.segment4)||
                        decode(glc.segment5,null,null,'.'||glc.segment5)||
                        decode(glc.segment6,null,null,'.'||glc.segment6)||
                        decode(glc.segment7,null,null,'.'||glc.segment7)||
                        decode(glc.segment8,null,null,'.'||glc.segment8)||
                        decode(glc.segment9,null,null,'.'||glc.segment9)||
                        decode(glc.segment10,null,null,'.'||glc.segment10)||
                        decode(glc.segment11,null,null,'.'||glc.segment11)||
                        decode(glc.segment12,null,null,'.'||glc.segment12)||
                        decode(glc.segment13,null,null,'.'||glc.segment13)||
                        decode(glc.segment14,null,null,'.'||glc.segment14)||
                        decode(glc.segment15,null,null,'.'||glc.segment15)||
                        decode(glc.segment16,null,null,'.'||glc.segment16)||
                        decode(glc.segment17,null,null,'.'||glc.segment17)||
                        decode(glc.segment18,null,null,'.'||glc.segment18)||
                        decode(glc.segment19,null,null,'.'||glc.segment19)||
                        decode(glc.segment20,null,null,'.'||glc.segment20)||
                        decode(glc.segment21,null,null,'.'||glc.segment21)||
                        decode(glc.segment22,null,null,'.'||glc.segment22)||
                        decode(glc.segment23,null,null,'.'||glc.segment23)||
                        decode(glc.segment24,null,null,'.'||glc.segment24)||
                        decode(glc.segment25,null,null,'.'||glc.segment25)||
                        decode(glc.segment26,null,null,'.'||glc.segment26)||
                        decode(glc.segment27,null,null,'.'||glc.segment27)||
                        decode(glc.segment28,null,null,'.'||glc.segment28)||
                        decode(glc.segment29,null,null,'.'||glc.segment29)||
                        decode(glc.segment30,null,null,'.'||glc.segment30)
		INTO segment
                FROM RA_CUST_TRX_LINE_GL_DIST rld,
                        GL_CODE_COMBINATIONS glc
                WHERE rld.customer_trx_id =
                                TS_REPORT_HEADER_ENTRY.CUSTOMER_TRX_ID
                AND  rld.account_class = 'REC'
                AND  rld.code_combination_id = glc.code_combination_id;

	END;


	BEGIN
           LINE_COUNTER := 1;
	---FV_UTILITY.DEBUG_MESG('line_count= '||line_count);
	---FV_UTILITY.DEBUG_MESG('line_counter = '||line_counter);
	---FV_UTILITY.DEBUG_MESG('line_count_flag = '||line_count_flag);
	   IF LINE_COUNT > 1 AND line_count_flag = 0 THEN
	---FV_UTILITY.DEBUG_MESG('Inside the multi line if statement');
	   BEGIN
	     FOR LINE_COUNTER IN 1..LINE_COUNT LOOP
		INSERT INTO FV_SF1080_DETAIL_TEMP
			(
			CUSTOMER_TRX_ID,
		 	LINE_NUMBER,
		 	EXTENDED_AMOUNT,
		 	SALES_ORDER,
		 	DESCRIPTION,
		 	QUANTITY_INVOICED,
		 	UNIT_SELLING_PRICE,
		 	UOM_CODE,
		 	ACCT_OFC_RECV_FND
			)
		SELECT rtl.CUSTOMER_TRX_ID,
                 	rtl.LINE_NUMBER,
                 	rtl.EXTENDED_AMOUNT,
                 	rtl.SALES_ORDER,
                 	SUBSTR(rtl.DESCRIPTION,1,60),
                 	rtl.QUANTITY_INVOICED,
                 	rtl.UNIT_SELLING_PRICE,
                 	rtl.UOM_CODE,
			segment
		FROM RA_CUSTOMER_TRX_LINES rtl
		WHERE rtl.customer_trx_id =
				TS_REPORT_HEADER_ENTRY.CUSTOMER_TRX_ID
		AND rtl.line_number = line_counter;

	END LOOP;  --- for loop ended

	END;
	ELSIF LINE_COUNT = 1 AND line_count_flag = 0 THEN
		 ---FV_UTILITY.DEBUG_MESG('Inside the single line if statement');
		INSERT INTO FV_SF1080_DETAIL_TEMP
                	(
			CUSTOMER_TRX_ID,
                 	LINE_NUMBER,
                 	EXTENDED_AMOUNT,
                 	SALES_ORDER,
                 	DESCRIPTION,
                 	QUANTITY_INVOICED,
                 	UNIT_SELLING_PRICE,
                 	UOM_CODE,
                 	ACCT_OFC_RECV_FND
			)
                SELECT rtl.CUSTOMER_TRX_ID,
                 	rtl.LINE_NUMBER,
                 	rtl.EXTENDED_AMOUNT,
                 	rtl.SALES_ORDER,
                 	SUBSTR(rtl.DESCRIPTION,1,60),
                 	rtl.QUANTITY_INVOICED,
                 	rtl.UNIT_SELLING_PRICE,
                 	rtl.UOM_CODE,
			segment
                FROM RA_CUSTOMER_TRX_LINES rtl
                WHERE rtl.customer_trx_id =
			TS_REPORT_HEADER_ENTRY.CUSTOMER_TRX_ID;
           END IF;
    END;
END LOOP;
 ---FV_UTILITY.DEBUG_MESG('End of multiple line invoice loop.');
commit;
--
-- ------------------------------------
-- Exceptions
-- ------------------------------------
EXCEPTION
--
  WHEN OTHERS THEN
    g_error_code    := SQLCODE;
    g_error_message := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_message);
    IF ts_report_header_cursor%ISOPEN THEN
       close ts_report_header_cursor;
    END IF;
--
END a200_load_report_tables;
-------------------------------------------------------
------------------------------------------------------
BEGIN

 g_module_name := 'fv.plsql.fv_sf1080_transaction.';


End fv_sf1080_transaction;

/
