--------------------------------------------------------
--  DDL for Package Body FV_SF1081_TRANSACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_SF1081_TRANSACTION" AS
--$Header: FVX1081B.pls 120.17.12010000.5 2009/10/09 17:09:34 snama ship $
--	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('FV_DEBUG_FLAG'),'N');
  g_module_name VARCHAR2(100) ;


-- ------------------------------------
-- Stored Input Parameters
-- ------------------------------------
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
          parm_customer                   VARCHAR2(50);
	        parm_alc	          	  VARCHAR2(50);
          parm_open_invoices_only         VARCHAR2(3);
	        parm_print_choice	          VARCHAR2(30);
          parm_details_of_charges         VARCHAR2(50);

-- ------------------------------------
-- Stored Global Variables
-- ------------------------------------
  g_error_code                  NUMBER;
  g_error_message               VARCHAR2(80);
  v_segment			VARCHAR2(25);
  v_set_of_books_id             NUMBER;
  v_org_id                      NUMBER;
  v_bal_seg_name		VARCHAR2(25);
  v_default_alc                 VARCHAR2(30);
  v_warning                     VARCHAR2(1);
  v_exception                    VARCHAR2(1);
  v_trx_found_2                 varchar2(1) ;
  v_trx_found_1                 VARCHAR2(1) ;
  v_trx_found_3                 VARCHAR2(1) ;
  v_warning_num                 NUMBER;
  v_alc_code                    VARCHAR2(30);

  PROCEDURE a100_clear_report_temp_table;

  PROCEDURE a200_load_report_tables;

  PROCEDURE get_bal_seg_name;

  abort_error  EXCEPTION;
  report_failure EXCEPTION;

-- ---------- End of Package Level Declaritives -----------------------------

PROCEDURE a000_load_table
       	  (error_code       	  OUT NOCOPY  NUMBER,
          error_message     	  OUT NOCOPY  VARCHAR2,
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
	  alc			  IN   VARCHAR2,
	  prepared_by	          IN   VARCHAR2,
	  approved_by		  IN   VARCHAR2,
	  telephone_number_1      IN   VARCHAR2,
	  telephone_number_2      IN   VARCHAR2,
          open_invoices_only      IN   VARCHAR2,
	  print_choice		  IN   VARCHAR2,
          details_of_charges      IN   VARCHAR2)
IS
  l_module_name VARCHAR2(200) ;
  l_request_id number;

 CURSOR c_warning_1 IS
  select distinct trx_number
    from fv_sf1081_temp
   where alc_code = '1';

 CURSOR c_warning_2 IS
  select distinct trx_number
    from fv_sf1081_temp
   where alc_code = '2';

 CURSOR c_warning_3 IS
  select distinct customer_name
    from fv_sf1081_temp
   where alc_code = '3';

BEGIN


   l_module_name  := g_module_name || 'a000_load_table';


   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Parameters: ');
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'order_by: '||order_by);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'batch: '||batch);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'transaction_class: '||transaction_class);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'transaction_type: '||transaction_type);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'trans_num_low: '||trans_num_low);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'trans_num_high: '||trans_num_high);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'print_date_low: '||print_date_low);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'print_date_high: '||print_date_high);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'cust_profile_class_id: '||cust_profile_class_id);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'customer_class: '||customer_class);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'customer: '||customer);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'alc: '||alc);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'open_invoices_only: '||open_invoices_only);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'print_choice: '||print_choice);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'details_of_charges: '||details_of_charges);
   END IF;




-- ------------------------------------------
-- Store Input Parameters in Global Variables
-- ------------------------------------------
  parm_order_by := order_by;
  parm_batch  := batch;
  parm_cust_profile_class_id  := cust_profile_class_id;
  parm_transaction_class := transaction_class;
  parm_transaction_type := transaction_type;
  parm_trans_num_low := trans_num_low;
  parm_trans_num_high := trans_num_high;
  parm_print_date_low  := FND_DATE.CANONICAL_TO_DATE(print_date_low);
  parm_print_date_high  := FND_DATE.CANONICAL_TO_DATE(print_date_high);
  parm_customer_class := customer_class;
  parm_customer := customer;
  parm_alc := alc;
  parm_open_invoices_only := open_invoices_only;
  parm_details_of_charges := details_of_charges;
  parm_print_choice := print_choice;

  error_code    := 0;
  error_message := '?';
  g_error_code := 0;
  g_error_message := '?';

    a100_clear_report_temp_table;

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
  	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'g_error_code after clear temp table = ' || g_error_code);
   END IF;


    IF g_error_code = 0 THEN
       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
  	 	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CALLING A200_LOAD_REPORT_TABLES');
       END IF;
     a200_load_report_tables;
--     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Process Complete');
    END IF;

    IF g_error_code <> 0 THEN
       RAISE abort_error;
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'After a200_load_report_tables');
    END IF;

    -- print error messages to log file if there are any warnings.
    IF v_warning = 'Y' THEN
       g_error_code := '1';  --process should end in warning
       fv_utility.log_mesg('The receipt method has not been defined for the following transactions: ');

	 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	 	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'THE PAYMENT METHOD HAS NOT BEEN DEFINED IN THE '||
	         'Paying Customer tab for the following Transactions: ');
	 END IF;

     FOR c_warning1_rec IN c_warning_1 LOOP
            v_trx_found_1 := 'Y';

       fv_utility.log_mesg(C_WARNING1_REC.TRX_NUMBER);

    	 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	       	 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,C_WARNING1_REC.TRX_NUMBER);
    	 END IF;
     END LOOP;

     IF v_trx_found_1 = 'N' THEN
       fv_utility.log_mesg('No Transactions have this exception.');
    	 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	       	 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'NO TRANSACTIONS HAVE THIS EXCEPTION.');
    	 END IF;
     END IF;

   fv_utility.log_mesg('The Agency Location Code has not been defined for ');
   fv_utility.log_mesg('the Primary bank account of the payment method for the following transactions: ');
	 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'THE AGENCY LOCATION CODE HAS NOT BEEN DEFINED FOR '||
          'the Primary bank account of the payment method for the following '||
          'Transactions: ');
	 END IF;

     FOR c_warning2_rec IN c_warning_2 LOOP
        v_trx_found_2 := 'Y';

        fv_utility.log_mesg(C_WARNING2_REC.TRX_NUMBER);

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,C_WARNING2_REC.TRX_NUMBER);
    	END IF;
     END LOOP;

     IF v_trx_found_2 = 'N' THEN

       fv_utility.log_mesg('No transactions have this exception.');

    	 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      	  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'NO TRANSACTIONS HAVE THIS EXCEPTION.');
    	 END IF;
     END IF;
   fv_utility.log_mesg('The customer agency location code has not been defined for the ');
   fv_utility.log_mesg('primary bank account for the following customers: ');

	 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'THE CUSTOMER AGENCY LOCATION CODE HAS NOT BEEN '||
	        'defined for the Primary bank account for the following Customers: ');
	 END IF;

     FOR c_warning3_rec IN c_warning_3 LOOP
         v_trx_found_3 := 'Y';

       fv_utility.log_mesg(C_WARNING3_REC.CUSTOMER_NAME);

    	 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,C_WARNING3_REC.CUSTOMER_NAME);
	     END IF;
     END LOOP;

     IF v_trx_found_3 = 'N' THEN

       fv_utility.log_mesg('No customers have this exception.');

    	 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    	  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'NO CUSTOMERS HAVE THIS EXCEPTION.');
    	 END IF;
    END IF;

    delete from fv_sf1081_temp where alc_code in ('1','2','3');
    END IF;

    error_code    := g_error_code;
    error_message := 'Normal End of FVSF1081 Package';
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Process Complete');
    END IF;

    fnd_request.set_org_id(mo_global.get_current_org_id);
--- Kick Off the SL1081 report
    l_request_id :=fnd_request.submit_request(
 	application => 'FV',
	program => 'FVSF1081',
	description => '',
	start_time => '',
	sub_request => FALSE,
	argument1 => order_by,
	argument2 => prepared_by,
	argument3 => approved_by,
	argument4 => telephone_number_1,
	argument5 => telephone_number_2,
	argument6 => details_of_charges);
     IF (l_request_id = 0) THEN
	RAISE report_failure;
     ELSE
	COMMIT;
    END IF;

  EXCEPTION

  WHEN abort_error THEN
    error_code    := 2;
    error_message := g_error_message;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.abort_error',g_error_message);


  WHEN report_failure THEN
     g_error_message := 'Submission of FVSF1081 Report failed';
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.report_failure',g_error_message);


  WHEN OTHERS THEN
    error_code := 2;
    error_message := sqlerrm;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_message);
    RAISE_APPLICATION_ERROR(-20222,'FVSF1081 Exception-'||error_message);

END a000_load_table;

-- -------------------------------------------------------
-- This procedure derives the balancing segment name.
-- -------------------------------------------------------

PROCEDURE get_bal_seg_name
IS
  l_module_name VARCHAR2(200) ;
  v_boolean		boolean;
  sob    		number;
  flex_num 		number;
  flex_code		varchar2(60) ;
  apps_id   		number := 101;
  seg_number 		number;
  bl_seg_name 		varchar2(60);
  seg_app_name 		varchar2(60);
  seg_prompt   		varchar2(60);
  seg_value_set_name 	varchar2(60);

  BEGIN


      l_module_name := g_module_name || 'get_bal_seg_name';
        flex_code             := 'GL#';

--    sob := TO_NUMBER(fnd_profile.value('GL_SET_OF_BKS_ID'));

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'SOB ID: '||to_char(v_set_of_books_id));
    END IF;

    SELECT chart_of_accounts_id INTO  flex_num
    FROM   gl_sets_of_books
    WHERE  set_of_books_id = v_set_of_books_id;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'FLEX NUM: '||to_char(flex_num));
    END IF;

    v_boolean := FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(apps_id,flex_code,flex_num,
						    'GL_BALANCING',seg_number);

    IF (v_boolean) THEN
      v_boolean := FND_FLEX_APIS.GET_SEGMENT_INFO
                     (apps_id,flex_code,flex_num,seg_number,bl_seg_name,
			    seg_app_name,seg_prompt,seg_value_set_name);
    END IF;

    v_segment :=  ' glc.'||bl_seg_name;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'segment name: '||v_segment);
    END IF;
   v_bal_seg_name := UPPER(bl_seg_name);

  EXCEPTION
  WHEN OTHERS THEN
    g_error_code := SQLCODE;
    g_error_message := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_message);
    RAISE;
END get_bal_seg_name ;

-- -------------------------------------------------------
-- This procedure deletes records from temp table.
-- -------------------------------------------------------
PROCEDURE a100_clear_report_temp_table

IS
  l_module_name VARCHAR2(200) ;

 BEGIN

  l_module_name  := g_module_name || 'a100_clear_report_temp_table';

--  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'0_clear_reporxemp_table');
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Start a100_clear_report_temp_table');
  END IF;

  DELETE
  FROM fv_sf1081_temp;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Deleting from FV_SF1081_TEMP');
  END IF;

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
	NULL;
  WHEN OTHERS THEN
	g_error_code := SQLCODE;
	g_error_message := 'a100_clear_report_header_table: /'||SQLERRM;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_message);
 COMMIT;
END a100_clear_report_temp_table ;

-- --------------------------------------------------------
-- This procedure loads the temp table by reading
-- records from the cursor.
-- --------------------------------------------------------

PROCEDURE a200_load_report_tables
IS
  l_module_name VARCHAR2(200) ;
--
  l_ledger_id number;
  l_ledger_name varchar2(200);
--
  vc_trx_number    ra_customer_trx.trx_number%TYPE;
  vc_receipt_method_id ra_customer_trx.receipt_method_id%TYPE;
  vc_customer_name hz_parties.party_name%TYPE;
  vc_customer_id   hz_cust_accounts.cust_Account_id%TYPE;
  vc_cust_alc	   ce_bank_accounts.agency_location_code%TYPE;
  vc_address_id    hz_cust_acct_sites.cust_acct_site_id%type;
  vc_address1       hz_locations.address1%TYPE;
  vc_address2      hz_locations.address2%TYPE;
  vc_address3      hz_locations.address3%TYPE;
  vc_city          hz_locations.city%TYPE;
  vc_state         hz_locations.state%TYPE;
  vc_postal_code   hz_locations.postal_code%TYPE;
  vc_customer_trx_id  ra_customer_trx.customer_trx_id%TYPE;
  vc_amount        ra_cust_trx_line_gl_dist.amount%TYPE;
  vc_bill_to_customer_id ra_customer_trx.bill_to_customer_id%TYPE;
  vc_trx_date      ra_customer_trx.trx_date%TYPE;
  vc_code_combination_id   number;

  v_treasury_symbol fv_treasury_symbols.treasury_symbol%TYPE;
  err number;

 -- Bug 4960824
 CURSOR ts_report_noalc_cursor
 IS
 SELECT
      RCT.TRX_NUMBER,
      RCT.RECEIPT_METHOD_ID,
      HZP.PARTY_NAME,
      HZCA.CUST_ACCOUNT_ID,
      HZCAS.CUST_ACCT_SITE_ID,
      HZL.ADDRESS1,
      HZL.ADDRESS2,
      HZL.ADDRESS3,
      HZL.CITY,
      HZL.STATE,
      HZL.POSTAL_CODE,
      RCT.CUSTOMER_TRX_ID,
      SUM(RLD.AMOUNT) AMOUNT,
      RCT.BILL_TO_CUSTOMER_ID,
      RCT.TRX_DATE,
      RLD.CODE_COMBINATION_ID
 FROM
      RA_CUSTOMER_TRX              RCT,
      RA_CUSTOMER_TRX_LINES        RTL,
      RA_CUST_TRX_LINE_GL_DIST     RLD,
      HZ_CUST_SITE_USES            HZCSU,
      HZ_LOCATIONS                 HZL,
      HZ_CUST_ACCT_SITES           HZCAS,
      HZ_CUST_ACCOUNTS             HZCA,
      HZ_PARTY_SITES               HZPS,
      HZ_PARTIES                   HZP
 WHERE
          RCT.CUSTOMER_TRX_ID = RTL.CUSTOMER_TRX_ID
      AND RTL.CUSTOMER_TRX_LINE_ID = RLD.CUSTOMER_TRX_LINE_ID
      AND RCT.COMPLETE_FLAG = 'Y'
      AND RCT.PRINTING_OPTION = 'PRI'
      AND RCT.SET_OF_BOOKS_ID = v_set_of_books_id
      AND RCT.TRX_NUMBER BETWEEN NVL( parm_trans_num_low   ,'0')
                         AND     NVL( parm_trans_num_high  ,'zzzzzzzzzzzzzzzzzzzz')
      AND RCT.TRX_DATE   BETWEEN NVL( parm_print_date_low  , TO_DATE('1990/1/1', 'yyyy/mm/dd'))
                         AND     NVL( parm_print_date_high , TRUNC(SYSDATE))
      AND NVL(RCT.STATUS_TRX,'-1') LIKE DECODE( parm_open_invoices_only ,'Y','OP','N','%')
      AND HZPS.PARTY_ID = HZCA.PARTY_ID
      AND HZP.PARTY_ID  = HZPS.PARTY_ID
      AND RCT.BILL_TO_SITE_USE_ID = HZCSU.SITE_USE_ID
      AND HZCSU.CUST_ACCT_SITE_ID = HZCAS.CUST_ACCT_SITE_ID
      AND HZCAS.PARTY_SITE_ID = HZPS.PARTY_SITE_ID
      AND HZPS.LOCATION_ID = HZL.LOCATION_ID
      AND HZCAS.CUST_ACCOUNT_ID = HZCA.CUST_ACCOUNT_ID
      AND hzca.cust_account_id IN
            ((SELECT cust_account_id
	      FROM hz_cust_accounts hzca
	      WHERE NVL(customer_class_code,'XXX') LIKE
	                DECODE(parm_customer_class,null,
			   NVL(customer_class_code,'XXX'),parm_customer_class))
              INTERSECT
	      (SELECT  cust_account_id
	       FROM  hz_cust_accounts hzca
               WHERE cust_account_id  LIKE NVL(parm_customer,'%')))
      AND RCT.BILL_TO_CUSTOMER_ID IN
          (SELECT HCP.CUST_ACCOUNT_ID
           FROM   HZ_CUSTOMER_PROFILES HCP
           WHERE  HCP.CUST_ACCOUNT_ID = RCT.BILL_TO_CUSTOMER_ID
           AND    HCP.PROFILE_CLASS_ID = NVL(parm_cust_profile_class_id , HCP.PROFILE_CLASS_ID))
      AND RCT.CUST_TRX_TYPE_ID IN
          (SELECT CUST_TRX_TYPE_ID
            FROM   RA_CUST_TRX_TYPES    RCTT
            WHERE  RCTT.CUST_TRX_TYPE_ID = RCT.CUST_TRX_TYPE_ID
            AND   (     RCTT.TYPE LIKE NVL(parm_transaction_class ,'%')
                    OR  RCTT.CUST_TRX_TYPE_ID = NVL(parm_transaction_type, RCTT.CUST_TRX_TYPE_ID)))
      AND ((RCT.BATCH_ID IN
             (SELECT BATCH_ID
              FROM   RA_BATCHES    RB
              WHERE  RB.BATCH_ID = RCT.BATCH_ID
              AND    RB.BATCH_ID = NVL( parm_batch ,RB.BATCH_ID)))
           OR
           (parm_batch is null and NVL(BATCH_ID,'99') LIKE DECODE( parm_print_choice ,'SEL','99','NEW','99')))
      AND NVL(RCT.PRINTING_COUNT,'99') LIKE DECODE(parm_print_choice ,'NEW','99','%')
      AND NVL(TO_CHAR(RCT.PRINTING_ORIGINAL_DATE,'DD-MM-YYYY'),'01-01-1999')
              LIKE DECODE(parm_print_choice ,'NEW','01-01-1999','%')
      AND NVL(TO_CHAR(RCT.PRINTING_LAST_PRINTED,'DD-MM-YYYY'),'01-01-1999')
              LIKE DECODE(parm_print_choice ,'NEW','01-01-1999','%')
 GROUP BY
      RCT.TRX_NUMBER,
      RCT.RECEIPT_METHOD_ID,
      HZP.PARTY_NAME,
      HZCA.CUST_ACCOUNT_ID,
      HZCAS.CUST_ACCT_SITE_ID,
      HZL.ADDRESS1,
      HZL.ADDRESS2,
      HZL.ADDRESS3,
      HZL.CITY,
      HZL.STATE,
      HZL.POSTAL_CODE,
      RCT.CUSTOMER_TRX_ID,
      RCT.BILL_TO_CUSTOMER_ID,
      RCT.TRX_DATE,
      RLD.CODE_COMBINATION_ID
 ORDER BY parm_order_by;


	CURSOR ts_report_alc_cursor
	IS
	SELECT   rct.trx_number,
	         rct.receipt_method_id,
	         hzp.party_name,
	         hzca.cust_account_id,
	         cba.agency_location_code,
		 hzl.address1,
 	         hzl.address2,
	         hzl.address3,
	         hzl.city,
		 hzl.state,
		 hzl.postal_code,
	         rct.customer_trx_id,
	         sum(rld.amount) Amount,
	         rct.bill_to_customer_id,
		 rct.trx_date,
	         rld.code_combination_id
	FROM
		hz_locations hzl,
		hz_cust_acct_sites hzcas,
	        hz_party_sites hzps ,
		HZ_CUST_SITE_USEs hzcsu,
	        hz_cust_accounts hzca,
		hz_parties hzp,
		ra_customer_trx rct,
	        ra_customer_trx_lines rtl,
		ra_cust_trx_line_gl_dist rld,
	        ce_bank_accounts cba,
		ce_bank_acct_uses_all cbau
	WHERE
		    hzp.party_id = hzca.party_id
		AND hzca.cust_account_id = hzcas.cust_account_id
		AND hzcas.party_site_id = hzps.party_site_id
		AND hzps.location_id = hzl.location_id
		AND hzcsu.Cust_Acct_site_ID = hzcas.CUST_ACCT_SITE_ID
		AND hzps.party_id = hzp.party_id

		AND rct.bill_to_site_use_id = hzcsu.site_use_id
		AND rct.remit_bank_acct_use_id = cbau.bank_acct_use_id

		AND cba.bank_account_id = cbau.bank_account_id
		AND cba.account_owner_party_id = cbau.org_party_id
	        AND cba.account_classification = 'EXTERNAL'
		AND cbau.org_id = v_org_id
		AND cba.account_owner_org_id = cbau.org_id
		AND cbau.primary_flag = 'Y'
		AND cba.account_owner_party_id = hzp.party_id
		AND cba.agency_location_code = parm_alc
		AND rct.complete_flag = 'Y'
		AND rct.printing_option = 'PRI'
		AND rtl.customer_trx_line_id = rld.customer_trx_line_id
		AND rct.customer_trx_id = rtl.customer_trx_id
		AND rct.set_of_books_id = v_set_of_books_id
		AND rct.bill_to_customer_id IN
			   (SELECT DISTINCT cust_account_id
			    FROM   hz_customer_profiles
			    WHERE  profile_class_id =
				   DECODE(parm_cust_profile_class_id,null,profile_class_id,
					  parm_cust_profile_class_id))
		AND    rct.cust_trx_type_id IN
		           ((SELECT cust_trx_type_id
		             FROM ra_cust_trx_types
		             WHERE type LIKE NVL(parm_transaction_class,'%'))
		            INTERSECT
		           (SELECT cust_trx_type_id
		            FROM   ra_cust_trx_types
		            WHERE  cust_trx_type_id = DECODE(parm_transaction_type,null,
		                cust_trx_type_id,parm_transaction_type)))
		AND   (rct.trx_number BETWEEN NVL(parm_trans_num_low,'0')
		                AND NVL(parm_trans_num_high,'zzzzzzzzzzzzzzzzzzzz'))
		AND    rct.trx_date BETWEEN DECODE(parm_print_date_low,null,TO_DATE('1990/1/1', 'yyyy/mm/dd'),			           parm_print_date_low)
		AND    DECODE(parm_print_date_high,null,trunc(sysdate),parm_print_date_high )
		AND    hzca.cust_account_id IN
        		((SELECT cust_account_id
		          FROM hz_cust_accounts hzca
		          WHERE NVL(customer_class_code,'XXX') LIKE DECODE(parm_customer_class,null,
								NVL(customer_class_code,'XXX'),parm_customer_class))
		         INTERSECT
		        (SELECT  cust_account_id
		         FROM  hz_cust_accounts hzca
		         WHERE cust_account_id  LIKE NVL(parm_customer,'%')))
		AND rct.customer_trx_id IN
	                (SELECT customer_trx_id
	                 FROM   ra_customer_trx
	                 WHERE  NVL(status_trx,'-1') LIKE decode(parm_open_invoices_only,'Y','OP','N','%'))
		AND   ((rct.customer_trx_id IN
	                (SELECT customer_trx_id
	                 FROM   ra_customer_trx
	                 WHERE  batch_id IN
	                        (SELECT batch_id
	                         FROM   ra_batches
        	                 WHERE  batch_id = DECODE(parm_batch,null,BATCH_ID,parm_batch))))
	              OR (parm_batch is null and (NVL(BATCH_ID,'99') LIKE DECODE(parm_print_choice,'SEL','99','NEW','99'))))
		AND rct.customer_trx_id IN
	                (SELECT rct.customer_trx_id
	                 FROM   ra_customer_trx rct
	                 WHERE  (NVL(rct.printing_count,'99') LIKE
	                        DECODE(parm_print_choice,'NEW','99','%'))
	                AND (NVL(TO_CHAR(rct.printing_original_date,'DD-MM-YYYY'),'01-01-1999') LIKE
	                        DECODE(parm_print_choice,'NEW','01-01-1999','%'))
	                AND (NVL(TO_CHAR(rct.printing_last_printed,'DD-MM-YYYY'),'01-01-1999') LIKE
	                        DECODE(parm_print_choice,'NEW','01-01-1999','%')))
	GROUP BY  rct.trx_number,cba.agency_location_code,rct.receipt_method_id,
	          hzp.party_name, hzca.cust_account_id,
		  hzl.address1,hzl.address2,hzl.address3,hzl.city,hzl.state,hzl.postal_code,
	          rct.customer_trx_id,rct.bill_to_customer_id, rct.trx_date, rld.code_combination_id
	ORDER BY parm_order_by;

    BEGIN

    l_module_name := g_module_name ||'a200_load_report_tables';

    v_org_id          := mo_global.get_current_org_id;
    mo_utils.get_ledger_info(v_org_id,l_ledger_id,l_ledger_name);
    v_set_of_books_id := l_ledger_id;

   get_bal_seg_name;

   BEGIN
      -- get default alc for this org if there is one. cmb
      select alc_code
        into v_default_alc
        from fv_operating_units_all
       where default_alc = 'Y'
        and  nvl(org_id,-99) = nvl(v_org_id,-99);

	 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Default ALC Defined = '||v_default_alc);
	 END IF;

   EXCEPTION
      when others then
         v_default_alc := 'N';  -- no default alc was found
         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'v_default_alc = N');
         END IF;
   END;

  -- This for loop inserts values into FV_SF1081_TEMP table.
  v_warning := 'N';  -- set warning condition to No cmb

  IF parm_alc is not null THEN
     open ts_report_alc_cursor;
  ELSE
     open ts_report_noalc_cursor;
  END IF;

  LOOP

    v_exception := 'N';

    IF parm_alc is not null THEN
       FETCH ts_report_alc_cursor INTO vc_trx_number, vc_receipt_method_id,
         vc_customer_name,vc_customer_id, vc_cust_alc, vc_address1,
         vc_address2, vc_address3, vc_city, vc_state, vc_postal_code,
         vc_customer_trx_id, vc_amount,
         vc_bill_to_customer_id, vc_trx_date, vc_code_combination_id;

       EXIT when ts_report_alc_cursor%NOTFOUND;

    ELSE
       FETCH ts_report_noalc_cursor INTO vc_trx_number, vc_receipt_method_id,
         vc_customer_name, vc_customer_id,vc_address_id,vc_address1, vc_address2, vc_address3,
         vc_city, vc_state, vc_postal_code, vc_customer_trx_id, vc_amount,
         vc_bill_to_customer_id, vc_trx_date, vc_code_combination_id;

       EXIT when ts_report_noalc_cursor%NOTFOUND;
    END IF;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TRX_NUMBER = '||VC_TRX_NUMBER);
	 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'RECEIPT_METHOD_ID = '||VC_RECEIPT_METHOD_ID);
    END IF;

    IF (parm_alc is null) THEN
       --determine customer alc for the customer on the invoice.

       BEGIN

	       SELECT eb.agency_location_code
	       INTO   vc_cust_alc
	       FROM hz_cust_acct_sites_all hzcas,
	           hz_cust_site_uses_all hzcsu,
	           iby_external_payers_all payer,
	           iby_pmt_instr_uses_all iby_ins,
	           iby_ext_bank_accounts_v eb
	      WHERE hzcas.cust_account_id = vc_customer_id
	      AND   hzcas.cust_acct_site_id = vc_address_id
	      AND   hzcsu.cust_acct_site_id=hzcas.cust_acct_site_id
	      AND   hzcsu.site_use_code = 'BILL_TO'
	      AND   hzcsu.site_use_id  = payer.acct_site_use_id
	      AND   payer.ext_payer_id= iby_ins.ext_pmt_party_id
	      AND   iby_ins.instrument_type  = 'BANKACCOUNT'
	      AND   iby_ins.instrument_id = eb.ext_bank_account_id
              --Bug8654464
	      --AND   iby_ins.start_date < vc_trx_date
        AND  Decode(iby_ins.start_date,NULL,(vc_trx_date-1),iby_ins.start_date) < vc_trx_date
        AND (Decode(iby_ins.end_date,NULL,Sysdate,iby_ins.end_date))> vc_trx_date
        and iby_ins.payment_function = 'CUSTOMER_PAYMENT' ;

        EXCEPTION
            when no_data_found then
               IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'NO CUSTOMER ALC FOUND');
               END IF;
               v_warning := 'Y';
               v_warning_num := '3';
               v_exception := 'Y';
        END;

        IF vc_cust_alc is null THEN
           IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'NO CUSTOMER ALC DEFINED.');
           END IF;
           v_warning := 'Y';
           v_warning_num := '3';
           v_exception := 'Y';
        END If;

         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'VC_CUST_ALC = '||VC_CUST_ALC);
         END IF;


    END IF;

    IF v_exception = 'N' THEN
       --no warning condition found so continue.
     IF (vc_receipt_method_id is null) and (v_default_alc = 'N')
           THEN
     -- this is a warning condition since no default alc has been assigned.
     -- Set this warning num to 1 which is The payment method has not been
     -- defined in the Paying Customer tab.

       v_warning := 'Y';
       v_warning_num := '1';

       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'NO RM_ID AND NO DEFAULT');
       END IF;

     ELSIF (vc_receipt_method_id is not null) THEN
     -- must find the primary bank account and pull the alc code from there.
     -- Set this warning num to 2 if there is no alc code defined.

       BEGIN
        select cba.agency_location_code
         into v_alc_code
         from ar_receipt_method_accounts arma,
              ce_bank_accounts cba,
	      ce_bank_acct_uses_all cbau
        where arma.primary_flag = 'Y'
          and arma.receipt_method_id = vc_receipt_method_id
          and cbau.bank_acct_use_id = arma.remit_bank_acct_use_id
	  and cba.bank_account_id = cbau.bank_account_id
   	  and cbau.org_id = v_org_id;
 --Bug8654464
	  --and cba.account_owner_party_id = cbau.org_party_id

       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V_ALC_CODE = '||V_ALC_CODE);
       END IF;

       IF v_alc_code is null THEN
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'NO ALC FOUND ON BANK ACCOUNT');
          END IF;
          v_warning := 'Y';
          v_warning_num := 2;
       END IF;

       EXCEPTION
        when no_data_found then
          IF v_default_alc <> 'N' THEN
             v_alc_code := v_default_alc;
          ELSE
             v_warning := 'Y';
             v_warning_num := '2';
          END IF;
       END;

     ELSIF (vc_receipt_method_id is null)
                             and (v_default_alc <> 'N') THEN
     -- default alc has been found so use that alc code
     v_alc_code := v_default_alc;
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'USING DEFAULT ALC ');
     END IF;

    END IF;
  END IF;  -- v_warning = 'N' branch

  BEGIN

    SELECT fts.treasury_symbol
    INTO   v_treasury_symbol
    FROM   fv_fund_parameters ffp,
	   fv_treasury_symbols fts,
	   gl_code_combinations glc
   WHERE   decode(v_bal_seg_name,'SEGMENT1', glc.segment1,
                              'SEGMENT2', glc.segment2,
                              'SEGMENT3', glc.segment3,
                              'SEGMENT4', glc.segment4,
                              'SEGMENT5', glc.segment5,
                              'SEGMENT6', glc.segment6,
                              'SEGMENT7', glc.segment7,
                              'SEGMENT8', glc.segment8,
                              'SEGMENT9', glc.segment9,
                              'SEGMENT10', glc.segment10,
                              'SEGMENT11', glc.segment11,
                              'SEGMENT12', glc.segment12,
                              'SEGMENT13', glc.segment13,
                              'SEGMENT14', glc.segment14,
                              'SEGMENT15', glc.segment15,
                              'SEGMENT16', glc.segment16,
                              'SEGMENT17', glc.segment17,
                              'SEGMENT18', glc.segment18,
                              'SEGMENT19', glc.segment19,
                              'SEGMENT20', glc.segment20,
                              'SEGMENT21', glc.segment21,
                              'SEGMENT22', glc.segment22,
                              'SEGMENT23', glc.segment23,
                              'SEGMENT24', glc.segment24,
                              'SEGMENT25', glc.segment25,
                              'SEGMENT26', glc.segment26,
                              'SEGMENT27', glc.segment27,
                              'SEGMENT28', glc.segment28,
                              'SEGMENT29', glc.segment29,
                              'SEGMENT30', glc.segment30) = ffp.fund_value
    AND    glc.code_combination_id = vc_code_combination_id
    AND    ffp.treasury_symbol_id = fts.treasury_symbol_id
    AND    ffp.set_of_books_id = v_set_of_books_id;

    EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
         when others then
--		fnd_file.put_line(fnd_file.log,'hiuhkjsdhfkjsdhfkjsdfhjksdf'SQLERRM);
		fnd_file.put_line(fnd_file.log,SQLERRM);
  END;


      BEGIN
	INSERT INTO fv_sf1081_temp
	(customer_trx_id,
	 trx_number,
	 customer_name,
	 cust_address1,
	 cust_address2,
	 cust_address3,
	 cust_city,
	 cust_state,
	 cust_postal_code,
	 tax_reference,
	 treasury_symbol,
	 amount,
	 bill_to_customer_id,
	 trx_date,
         alc_code)
	VALUES
	(vc_customer_trx_id,
	 vc_trx_number,
	 vc_customer_name,
	 vc_address1,
	 vc_address2,
	 vc_address3,
	 vc_city,
	 vc_state,
	 vc_postal_code,
	 vc_cust_alc,
	 v_treasury_symbol,
	 vc_amount,
	 vc_bill_to_customer_id,
	 vc_trx_date,
         decode(v_warning_num,'1','1','2','2','3','3',v_alc_code));

	EXCEPTION
                WHEN OTHERS THEN
                        g_error_code    := SQLCODE;
                        g_error_message := 'INSERT_info: /'||SQLERRM;
                        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error1', g_error_message);
      END;

      v_warning_num := '0';
  END LOOP;

  IF (parm_alc is not null) THEN
     CLOSE ts_report_alc_cursor;
  ELSE
     CLOSE ts_report_noalc_cursor;
  END IF;

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'AFTER LOOP');
  END IF;

 COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    g_error_code    := 2;
    g_error_message := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_message);
    if  ts_report_alc_cursor%ISOPEN THEN
      close  ts_report_alc_cursor;
    end if;
    if  ts_report_noalc_cursor%ISOPEN THEN
      close  ts_report_noalc_cursor;
    end if;
    rollback;
    RAISE;


END a200_load_report_tables;
-------------------------------------------------------
------------------------------------------------------
BEGIN

  g_module_name := 'fv.plsql.FV_SF1081_TRANSACTION.';
  v_trx_found_2 := 'N' ;
  v_trx_found_1 := 'N' ;
  v_trx_found_3 := 'N' ;

END FV_SF1081_TRANSACTION ;

/
