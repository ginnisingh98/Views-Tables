--------------------------------------------------------
--  DDL for Package Body AR_CASH_RECEIPT_PRINT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CASH_RECEIPT_PRINT_PKG" AS
-- $Header: arcrprptb.pls 120.3.12010000.2 2008/11/12 12:59:54 ankuagar ship $
/*===========================================================================+
|  Copyright (c) 2003 Oracle Corporation BelmFont, California, USA           |
|                          ALL rights reserved.                              |
+============================================================================+
| FILENAME                                                                   |
|     arcrpb.pls                                                             |
|                                                                            |
| PACKAGE NAME                                                               |
|     ar_cash_receipt_print_pkg                                              |
|                                                                            |
| DESCRIPTION                                                                |
|     PACKAGE BODY. This provides XML extract for Receipt Print report for   |
|                   Israel                                                   |
| HISTORY                                                                    |
|     12/19/2006  sgautam         Created                                    |
|     06/28/2007 Ravikiran    Incorporated Review comments  |
|     14/07/2008  Rakesh Pulla  Made changes as per the SR # 7024551.992
|     23/07/2008 Rakesh Pulla  Made changes as per the SR # 6999382.993      |
+===========================================================================*/


--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================
--=============================================================================

-- Following are public routines
--
--    1.  beforeReport
--
--=============================================================================
p_program_short_name VARCHAR2(30) := 'ARCRPRRPT';
/* This function provides all the processing that needs to be done before the
   XML publisher engine starts to run the XML query */
FUNCTION beforeReport  RETURN BOOLEAN IS
 l_stmt                      VARCHAR2(32000);
 l_receipt_filter            VARCHAR2(120);
 l_doc_filter                VARCHAR2(120);
 l_cust_filter               VARCHAR2(120);
 l_cp_orig_select            VARCHAR2(120);
 l_cp_orig_filter            VARCHAR2(120);
 l_date_filter               VARCHAR2(240);
 l_copy_string               VARCHAR2(10);
 l_orig_string               VARCHAR2(10);
 l_nls_date_format           VARCHAR2(30);
 l_user                      VARCHAR2(100);
 /* Added for bug 7278191 */
 ln_conc_program_id fnd_concurrent_programs.concurrent_program_id%TYPE;
 ln_request_id     fnd_concurrent_requests.request_id%TYPE;
BEGIN
  /* Added for bug 7278191 */
 DELETE FROM AR_IL_CASH_RECEIPTS_GT;

 COMMIT;

 MO_GLOBAL.init('AR');
  -- to check if the output directory exists
  -- read the variable request_data to check if it is reentering the program
  ln_request_id := FND_GLOBAL.conc_request_id;




  /* Find out the user who issued the conc. prog */
  SELECT user_name
  INTO   l_user
  FROM fnd_user
  WHERE user_id=fnd_global.user_id;

  l_user:=','''||l_user||''' ';
  /* Added for bug 7278191 */
IF p_copy_or_original='Original' THEN

  SELECT concurrent_program_id
    INTO ln_conc_program_id
    FROM fnd_concurrent_programs
    WHERE concurrent_program_name=p_program_short_name;

    UPDATE fnd_concurrent_requests
    SET    save_output_flag='N'
    WHERE  request_id            = ln_request_id
    AND    concurrent_program_id = ln_conc_program_id;
	COMMIT;
END IF;

  --Check for the Star Date and End Date parameters.
IF p_start_date IS NOT NULL THEN
  l_date_filter := ' AND acr.receipt_date >= '''||p_start_date||'''';
ELSE
  l_date_filter := ' AND 1=1';
END IF;

  l_date_filter := l_date_filter||' AND acr.receipt_date <= NVL('''||p_end_date||''',SYSDATE) ';

-- Check for Receipt Number Parameters
IF p_receipt_from IS NOT NULL THEN
   l_receipt_filter := ' AND acr.receipt_number >= '''||p_receipt_from||'''';
END IF;

IF p_receipt_to IS NOT NULL THEN
   l_receipt_filter := l_receipt_filter|| ' AND acr.receipt_number <= '''||p_receipt_to||'''';
END IF;

-- Check for doc no parameters
IF p_doc_seq_value_from IS NOT NULL THEN
   l_doc_filter := ' AND acr.doc_sequence_value >= '||p_doc_seq_value_from;
END IF;

IF p_doc_seq_value_to IS NOT NULL THEN
   l_doc_filter := l_doc_filter|| ' AND acr.doc_sequence_value  <= '||p_doc_seq_value_to;
END IF;

-- check for ct. parameter
IF p_customer_id IS NOT NULL THEN
  l_cust_filter := ' AND acr.pay_from_customer = '||p_customer_id;
END IF;

-- Set the string copy or original
-- read from message dictionary

l_copy_string := FND_MESSAGE.GET_STRING('AR','AR_IL_COPY');

l_orig_string := FND_MESSAGE.GET_STRING('AR','AR_IL_ORIGINAL');

-- Check for Print Copy Or Original Parameter
IF p_copy_or_original='Original' THEN
    l_cp_orig_select := ''''||l_orig_string||''' ORIG_COPY';
    l_cp_orig_filter := ' AND NVL(acr.global_attribute20,''Copy'') <> ''Printed''';
ELSE
  l_cp_orig_select := ''''||l_copy_string||''' ORIG_COPY';
END IF;

/* populate gt table */
l_stmt := 'INSERT INTO AR_IL_CASH_RECEIPTS_GT(
                  CASH_RECEIPT_ID
                 ,RECEIPT_NUMBER
		 ,RECEIPT_DATE
		 ,RECEIPT_STATUS
		 ,DOCUMENT_NUMBER
		 ,RECEIPT_AMOUNT
		 ,CURRENCY
		 ,CREDIT_CARD_NO
		 ,CREDIT_CARD_TYPE
		 ,MATURITY_DATE
		 ,METHOD_NAME
		 ,BANK_ACCOUNT
		 ,BANK_NAME
		 ,BANK_BRANCH_NAME
		 ,CUSTOMER_NAME
		 ,CUSTOMER_NUMBER
		 ,TAX_REGISTRATION_NUMBER
	         ,CUST_ACCOUNT_ID
		 ,CUST_ACCT_SITE_ID
		 ,ADDRESS_LINE1
		 ,ADDRESS_LINE2
		 ,CITY
		 ,POSTAL_CODE
		 ,COPY_OR_ORIGINAL
		 ,USER_NAME)
		 SELECT /* Receipt Information */
			 acr.cash_receipt_id CASH_RECEIPT_ID
			 ,acr.receipt_number RECEIPT_NUMBER
			 ,acr.receipt_date RECEIPT_DATE
			 ,acr.status RECEIPT_STATUS
			 ,acr.doc_sequence_value DOCUMENT_NUMBER
			 ,acr.amount RECEIPT_AMOUNT
			 ,acr.currency_code CURRENCY
			 ,acr.attribute13 CREDIT_CARD_NO
			 ,acr.attribute14 CREDIT_CARD_TYPE
			 ,aps.due_date MATURITY_DATE
			 ,arm.name METHOD_NAME
			  /* Bank Information */
			 ,iebav.bank_account_number BANK_ACCOUNT
			 ,NVL(cbbv1.bank_name,cbbv2.bank_name) BANK_NAME
			 ,NVL(cbbv1.bank_branch_name,cbbv2.bank_branch_name) BANK_BRANCH_NAME
			  /* Customer Information */
			 ,hp.party_name CUSTOMER_NAME
			 ,hca.account_number CUSTOMER_NUMBER
			 ,(select registration_number
                 from xle_firstparty_information_v
                 where legal_entity_id = acr.legal_entity_id) TAX_REGISTRATION_NUMBER
			  /* The next two columns would be used to automatically
			    join to Q_INVOICES */
			 ,hca.cust_account_id CUST_ACCOUNT_ID
			 ,hcas.cust_acct_site_id CUST_ACCT_SITE_ID
			  /* Customer Address */
			 ,hl.address1 ADDRESS_LINE1
			 ,hl.address2 ADDRESS_LINE2
			 ,hl.city CITY
			 ,hl.postal_code  POSTAL_CODE,'||l_cp_orig_select||l_user||'
  FROM ar_cash_receipts acr,
       ar_receipt_methods arm,
       ar_payment_schedules aps,
       iby_ext_bank_accounts_v iebav,
       ce_bank_branches_v cbbv1,
       ce_bank_branches_v cbbv2,
       hz_parties hp,
       hz_party_sites hps,
       hz_cust_accounts hca,
       hz_cust_acct_sites hcas,
       hz_cust_site_uses hcsu,
       hz_locations hl
 WHERE aps.cash_receipt_id  = acr.cash_receipt_id
   AND acr.status IN (''APP'',''REV'',''NSF'',''STOP'')
   AND acr.confirmed_flag=''Y''
   AND arm.receipt_method_id = acr.receipt_method_id
   AND iebav.ext_bank_account_id (+) = acr.customer_bank_account_id
   AND iebav.branch_party_id = cbbv1.branch_party_id(+)
   AND acr.customer_bank_branch_id = cbbv2.branch_party_id (+)
   AND acr.pay_from_customer = hca.cust_account_id
   AND acr.customer_site_use_id = hcsu.site_use_id (+)
   AND hcsu.cust_acct_site_id = hcas.cust_acct_site_id
   AND hp.party_id = hca.party_id
   AND hca.cust_account_id = hcas.cust_account_id
   AND hcas.party_site_id = hps.party_site_id
   AND hps.location_id = hl.location_id'
   ||l_date_filter||l_receipt_filter||l_doc_filter||l_cust_filter||l_cp_orig_filter;



   EXECUTE IMMEDIATE l_stmt; --using p_start_date,p_end_date;

   return TRUE;

END;

/* This procedure marks global_attrbute20 of table ar_cash_receipts_all
   for its print status */
PROCEDURE update_ar_cash_receipts
IS

BEGIN

 IF p_copy_or_original='Original' THEN

    UPDATE ar_cash_receipts_all
    SET global_attribute20 = 'Printed'
    WHERE cash_receipt_id in (SELECT cash_receipt_id
                              FROM AR_IL_CASH_RECEIPTS_GT);




    COMMIT;

 END IF;


END;

/* This function provides all the processing that needs to be done before the
   XML publisher engine finished running the XML query */
FUNCTION afterReport  RETURN BOOLEAN IS
BEGIN

   update_ar_cash_receipts;

   return TRUE;

END;

END AR_CASH_RECEIPT_PRINT_PKG;

/
