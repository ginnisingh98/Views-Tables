--------------------------------------------------------
--  DDL for Package Body ARP_CORRECT_CC_ERRORS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CORRECT_CC_ERRORS" AS
/*$Header: ARCCCORB.pls 120.4.12010000.6 2009/04/08 11:10:40 dgaurab ship $*/

/* =======================================================================
 | Global Data Types
 * ======================================================================*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
pg_user_id          number;
pg_conc_login_id    number;
pg_login_id         number;
pg_user_name         VARCHAR2(100);

--
-- Private procedures used by the package
--

PROCEDURE get_action_code(p_cc_trx_id IN NUMBER,p_cc_trx_category IN VARCHAR2,
                          p_receipt_method_id IN NUMBER,
                          p_payment_trxn_extension_id IN NUMBER,
                          p_cc_error_code IN VARCHAR2,x_cc_error_desc OUT NOCOPY VARCHAR2,
			  x_first_record_flag OUT NOCOPY VARCHAR2,
			  x_cc_action_code OUT NOCOPY VARCHAR2,x_cc_action_type OUT NOCOPY VARCHAR2,
			  x_error_notes OUT NOCOPY VARCHAR2);

PROCEDURE insert_p(p_cc_error_hist IN ar_cc_error_history%ROWTYPE);

PROCEDURE clear_invoice_pay_info(p_customer_trx_id IN NUMBER,
                                 p_cc_trx_category IN VARCHAR2,
                                 p_source_receipt_id IN NUMBER DEFAULT NULL,
				 p_source_receipt_number IN VARCHAR2 DEFAULT NULL,
				 p_error_notes IN VARCHAR2);

FUNCTION default_reversal_gl_date(p_cash_receipt_id IN NUMBER) RETURN DATE;

FUNCTION default_reversal_date(p_cash_receipt_id IN NUMBER) RETURN DATE;

PROCEDURE reverse_receipt(p_cash_receipt_id IN ar_cash_receipts.cash_receipt_id%TYPE,
                          x_reversal_comments IN VARCHAR2 DEFAULT NULL);

/*Bug 8341117, Removed the parameter 'expiration_date' as part of the changes
  for PA - DSS Project.*/
PROCEDURE Raise_Collection_Event(
                                 p_cc_trx_id IN NUMBER,
                                 p_cc_error_code IN VARCHAR2,
				 p_cc_error_desc IN VARCHAR2,
				 p_cc_trx_category_dsp IN VARCHAR2,
				 p_cc_trx_number IN VARCHAR2,
			         p_cc_trx_currency IN VARCHAR2,
			         p_cc_trx_amount IN NUMBER,
			         p_cc_trx_date IN DATE,
			         p_customer_name IN VARCHAR2,
			         p_customer_number IN VARCHAR2,
			         p_customer_location IN VARCHAR2,
			         p_cc_number IN VARCHAR2,
			         p_payment_trxn_extension_id IN NUMBER,
			         p_approval_code IN VARCHAR2,
			         p_collector IN VARCHAR2,
                                 p_payment_method_name IN VARCHAR2,
				 p_billto_contact IN VARCHAR2 DEFAULT NULL,
                                 p_salesrep_name IN VARCHAR2 DEFAULT NULL,
			         p_source_receipt_id IN NUMBER DEFAULT NULL,
			         p_source_receipt_num IN VARCHAR2 DEFAULT NULL,
				 p_error_notes IN VARCHAR2);

PROCEDURE Raise_RefundReverse_Event(p_misc_cash_receipt_id IN NUMBER,
                                 p_cc_error_code IN VARCHAR2,
				 p_cc_error_desc IN VARCHAR2,
				 p_cc_trx_number IN VARCHAR2,
			         p_cc_trx_currency IN VARCHAR2,
			         p_cc_trx_amount IN NUMBER,
			         p_cc_trx_date IN DATE,
			         p_customer_name IN VARCHAR2,
			         p_customer_number IN VARCHAR2,
			         p_customer_location IN VARCHAR2,
			         p_cc_number IN VARCHAR2,
			         p_payment_trxn_extension_id IN NUMBER,
			         p_approval_code IN VARCHAR2,
			         p_collector IN VARCHAR2,
                                 p_payment_method_name IN VARCHAR2,
				 p_source_receipt_id IN NUMBER,
                                 p_source_receipt_num IN VARCHAR2,
				 p_error_notes IN VARCHAR2
                                 );

PROCEDURE AddParamEnvToList( x_list IN OUT NOCOPY WF_PARAMETER_LIST_T);

FUNCTION item_key(p_event_name  IN VARCHAR2,
                   p_unique_identifier  NUMBER) RETURN VARCHAR2;

FUNCTION event(p_event_name IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE raise_event
 (p_event_name          IN   VARCHAR2,
  p_event_key           IN   VARCHAR2,
  p_data                IN   CLOB DEFAULT NULL,
  p_parameters          IN   wf_parameter_list_t DEFAULT NULL);

PROCEDURE  attach_notes(p_customer_trx_id  IN NUMBER,
		        p_text IN VARCHAR2);

FUNCTION cc_error_occurred(p_mode VARCHAR2,p_request_id NUMBER) RETURN VARCHAR2;

PROCEDURE correct_remittance_errors(p_request_id IN NUMBER);

PROCEDURE correct_creation_errors(p_request_id IN NUMBER);

/*===========================================================================+
 | FUNCTION
 |    get_collector_name
 |
 | DESCRIPTION
 |    gets the collector name
 |
 |
 | SCOPE - PUBLIC
 |
 |
 | ARGUMENTS  : IN:
 |                 p_customer_id - Ideally cust_account_id
 |                 p_customer_site_use_id
 |              OUT:
 |
 | RETURNS    : l_collector_name if it finds a collector,
 |                 otherwise null
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by Srinivasa Kini - 25-Aug-2004
 |
 +===========================================================================*/
FUNCTION get_collector_name (
                p_customer_id IN NUMBER,
                p_customer_site_use_id IN NUMBER)
RETURN VARCHAR2 IS
  l_collector_name ar_collectors.name%TYPE;
  l_collector_id NUMBER;
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_standard.debug( 'ARP_CORRECT_CC_ERRORS.get_collector_name()+' );
 END IF;
 SELECT prof.collector_id INTO l_collector_id
 FROM hz_customer_profiles prof
 WHERE  prof.cust_account_id = p_customer_id AND
        prof.site_use_id = p_customer_site_use_id;

 SELECT name
 INTO l_collector_name
 FROM ar_collectors
 WHERE collector_id = l_collector_id;

 IF PG_DEBUG in ('Y', 'C') THEN
  arp_standard.debug( 'ARP_CORRECT_CC_ERRORS.get_collector_name()-' );
 END IF;
 RETURN l_collector_name;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
     SELECT prof.collector_id INTO l_collector_id
     FROM hz_customer_profiles prof
     WHERE  prof.cust_account_id = p_customer_id AND
            prof.site_use_id is NULL;

     SELECT name
     INTO l_collector_name
     FROM ar_collectors
     WHERE collector_id = l_collector_id;
     IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'ARP_CORRECT_CC_ERRORS.get_collector_name()-' );
     END IF;
     RETURN l_collector_name;
   WHEN OTHERS THEN
        RETURN null;
END get_collector_name;

/*===========================================================================+
 | FUNCTION
 |    cc_mapping_exist
 |
 | DESCRIPTION
 |    This function is used in report query for autorec execution report
 |    This function will return 'Y' if cc error mapping found otherwise 'N'
 |
 |
 | SCOPE - PUBLIC
 |
 |
 | ARGUMENTS  : IN:
 |                 p_cc_error_code - Error Code
 |                 p_cc_trx_category - Transaction category like 'REC'/'MISC'/'INV'
 |                 p_receipt_method_id - payment method identifier
 |              OUT:
 |
 | RETURNS    : 'Y' if mapping found otherwise 'N'
 |
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by Srinivasa Kini - 30-Oct-2004
 |
 +===========================================================================*/
FUNCTION cc_mapping_exist (
        p_cc_error_code IN ar_cc_error_mappings.cc_error_code%TYPE,
        p_cc_trx_category IN ar_cc_error_mappings.cc_trx_category%TYPE,
	p_receipt_method_id IN ar_cc_error_mappings.receipt_method_id%TYPE)
RETURN VARCHAR2 IS
 l_return VARCHAR2(1);
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_standard.debug( 'ARP_CORRECT_CC_ERRORS.cc_mapping_exist()+' );
 END IF;
 SELECT 'Y'
 INTO l_return
 FROM dual
 WHERE EXISTS (SELECT 1
               FROM ar_cc_error_mappings
	       WHERE cc_error_code = p_cc_error_code
	       AND cc_trx_category =  p_cc_trx_category
	       AND receipt_method_id = p_receipt_method_id);
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_standard.debug( 'ARP_CORRECT_CC_ERRORS.cc_mapping_exist()-' );
 END IF;
 RETURN l_return;
EXCEPTION
 WHEN OTHERS THEN
  RETURN 'N';
END;

/*===========================================================================+
 | PROCEDURE
 |    get_action_code
 |
 | DESCRIPTION
 |    Gets the cc_action_code from ar_cc_error_mappings if one exists
 |    otherwise passes 'Not avaialable'
 |
 |
 | SCOPE - PRIVATE
 |
 |
 | ARGUMENTS  : IN:
 |                p_cc_trx_id - Cash_receipt_id/Customer_trx_id
 |                p_cc_trx_category - CASH/MISC/INV
 |                p_receipt_method_id -
 |                p_payment_trxn_extension_id -
 |                p_cc_error_code - Error that was occured during CC processing
 |              OUT:
 |                x_cc_error_desc - From ar_cc_error_mappings
 |                x_first_record_flag - Y Indicates this is the first correction
 |                                      on the given transaction with the present
 |                                      error code and credit card number
 |                x_cc_action_code -  RET/REV REC/CLR PAY INFO/REAUT REC
 |                x_cc_action_type - A/S, 'A' for Action and 'S' for subsequent action
 |                x_error_notes - Error note, picked from ar_cc_error_mappings
 |
 |
 | RETURNS    : None
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by Srinivasa Kini - 25-Aug-2004
 |
 +===========================================================================*/
PROCEDURE get_action_code(p_cc_trx_id IN NUMBER,
                          p_cc_trx_category IN VARCHAR2,
			  p_receipt_method_id IN NUMBER,
                          p_payment_trxn_extension_id IN NUMBER,
                          p_cc_error_code IN VARCHAR2,
			  x_cc_error_desc OUT NOCOPY VARCHAR2,
			  x_first_record_flag OUT NOCOPY VARCHAR2,
			  x_cc_action_code OUT NOCOPY VARCHAR2,
			  x_cc_action_type OUT NOCOPY VARCHAR2,
			  x_error_notes OUT NOCOPY VARCHAR2) IS
l_no_days NUMBER;
l_first_cc_error_date DATE;
l_dummy_number NUMBER;
l_cc_action_code VARCHAR2(30);
l_subsequent_action_code VARCHAR2(30);
l_instr_assignment_id NUMBER;

BEGIN
IF PG_DEBUG in ('Y', 'C') THEN
 arp_standard.debug( 'ARP_CORRECT_CC_ERRORS.get_action_code()+' );
END IF;

IF PG_DEBUG in ('Y', 'C') THEN
   ---Print input parameters
   arp_standard.debug( '--- Input Parameters : ---');
   arp_standard.debug( 'p_cc_trx_id :'|| p_cc_trx_id);
   arp_standard.debug( 'p_cc_trx_category :'|| p_cc_trx_category);
   arp_standard.debug( 'p_payment_trxn_extension_id: ' ||
                        p_payment_trxn_extension_id);
   arp_standard.debug( 'p_cc_error_code: ' || p_cc_error_code);
   arp_standard.debug( 'p_receipt_method_id: ' || p_receipt_method_id);

END IF;


-- Check if there is action code in ar_cc_error_mappings
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_standard.debug( 'get_action_code()+' );
 END IF;
 SELECT cc_action_code,
        cc_error_text,
        no_days,
	subsequent_action_code,
	error_notes
 INTO   l_cc_action_code,
        x_cc_error_desc,
        l_no_days,
	l_subsequent_action_code,
	x_error_notes
 FROM ar_cc_error_mappings
 WHERE cc_error_code = p_cc_error_code
 AND cc_trx_category = p_cc_trx_category
 AND receipt_method_id = p_receipt_method_id;


  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'cc_action_code: '|| l_cc_action_code );
     arp_standard.debug( 'no_days: '|| l_no_days );
     arp_standard.debug( 'subsequent_action_code: '|| l_subsequent_action_code );

  END IF;


EXCEPTION
 WHEN NO_DATA_FOUND THEN
  x_cc_action_code := 'Not available';
  x_cc_action_type := NULL;
  x_first_record_flag := NULL;
  x_error_notes := NULL;
  RETURN;
 WHEN OTHERS THEN
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_standard.debug( 'EXCEPTION ARP_CORRECT_CC_ERRORS.get_action_code()' );
 END IF;
  raise;
END;


-- Check if subsequent action code already performed on this entity
BEGIN
 arp_standard.debug( 'Checking for subsequent action code');

 SELECT INSTR_ASSIGNMENT_ID INTO l_instr_assignment_id
 FROM IBY_FNDCPT_TX_EXTENSIONS
 WHERE TRXN_EXTENSION_ID = p_payment_trxn_extension_id;

 SELECT 1
 INTO l_dummy_number
 FROM dual
 WHERE NOT EXISTS ( SELECT 1
                    FROM ar_cc_error_history cc, iby_fndcpt_tx_extensions b
		    WHERE cc.cc_trx_id = p_cc_trx_id
		    AND cc.cc_trx_category = p_cc_trx_category
		    AND cc.payment_trxn_extension_id = b.trxn_extension_id
                    AND b.instr_assignment_id = l_instr_assignment_id
		    AND cc.cc_error_code = p_cc_error_code
		    AND cc.cc_action_type_flag = 'S' );
EXCEPTION
 WHEN NO_DATA_FOUND THEN
  arp_standard.debug( 'No Data Found for subsequent action code');
  x_cc_action_code := 'Not available';
  x_cc_action_type := NULL;
  x_first_record_flag := NULL;
  x_error_notes := NULL;
  RETURN;
 WHEN OTHERS THEN
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_standard.debug( 'EXCEPTION ARP_CORRECT_CC_ERRORS.get_action_code()' );
 END IF;
  raise;
END;

-- Check if this a first time error
BEGIN
 arp_standard.debug( 'Checking if it is first time error');
 SELECT cc.cc_error_date
  INTO l_first_cc_error_date
 FROM ar_cc_error_history cc, iby_fndcpt_tx_extensions b
 WHERE cc.cc_trx_id = p_cc_trx_id
  AND cc.cc_trx_category = p_cc_trx_category
  AND cc.payment_trxn_extension_id = b.trxn_extension_id
  AND b.instr_assignment_id = l_instr_assignment_id
  AND cc.cc_error_code = p_cc_error_code
  AND cc.first_record_flag = 'Y';

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'First CC error Date; '|| l_first_cc_error_date );
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
   arp_standard.debug( 'No Data Found for first time error check');
   x_cc_action_code := l_cc_action_code;
   x_cc_action_type := 'A';
   x_first_record_flag := 'Y';
   RETURN;
  WHEN OTHERS THEN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug( 'EXCEPTION ARP_CORRECT_CC_ERRORS.get_action_code()' );
  END IF;
  raise;
END;

-- Determine action to perform or subsequent action.
--Bug 4192014 change the sign from < to > for action/subsequent action logic
arp_standard.debug( 'Setting action for subsequent action');
IF trunc(NVL(l_first_cc_error_date,to_date('01/01/1951','dd/mm/yyyy')))+l_no_days
   > trunc(sysdate)
THEN /* Action */
  x_cc_action_code := l_cc_action_code;
  x_cc_action_type := 'A';
  x_first_record_flag := 'N';

ELSE /* Subsequent Action */
  x_cc_action_code := NVL(l_subsequent_action_code,'Not available');
  x_cc_action_type := 'S';
  x_first_record_flag := 'N';
END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( ' Action or Subsequent Action x_cc_action_type : ' ||
                            x_cc_action_type );
  END IF;

IF PG_DEBUG in ('Y', 'C') THEN
 arp_standard.debug( 'ARP_CORRECT_CC_ERRORS.get_action_code()-' );
END IF;
END get_action_code;

/*===========================================================================+
 | PROCEDURE
 |    insert_p
 |
 | DESCRIPTION
 |    Inserts the record into ar_cc_error_history
 |
 |
 | SCOPE - PRIVATE
 |
 |
 | ARGUMENTS  : IN:
 |                p_cc_error_hist - record variable containing data to be inserted
 |              OUT: NONE
 |
 |
 | RETURNS    : None
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by Srinivasa Kini - 25-Aug-2004
 |
 +===========================================================================*/
PROCEDURE insert_p(p_cc_error_hist IN ar_cc_error_history%ROWTYPE) IS
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_standard.debug( 'ARP_CORRECT_CC_ERRORS.insert_p()+' );
 END IF;
  INSERT INTO ar_cc_error_history
  (
     request_id,
     cc_trx_category,
     cc_trx_id,
     cc_error_code,
     cc_error_date,
     cc_vendor_error_desc,
     cc_error_text,
     cc_action_code,
     cc_action_type_flag,
     payment_trxn_extension_id,
     first_record_flag,
     current_record_flag,
     last_update_date,
     creation_date,
     created_by,
     last_update_login,
     last_updated_by
    )
    VALUES
    (
    p_cc_error_hist.request_id,
    p_cc_error_hist.cc_trx_category ,
    p_cc_error_hist.cc_trx_id,
    p_cc_error_hist.cc_error_code,
    sysdate,
    p_cc_error_hist.cc_vendor_error_desc,
    p_cc_error_hist.cc_error_text,
    p_cc_error_hist.cc_action_code,
    p_cc_error_hist.cc_action_type_flag,
    p_cc_error_hist.payment_trxn_extension_id,
    p_cc_error_hist.first_record_flag,
    p_cc_error_hist.current_record_flag,
    sysdate,
    sysdate,
    pg_user_id,
    NVL(pg_login_id,pg_conc_login_id),
    pg_user_id
    );
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_standard.debug( 'ARP_CORRECT_CC_ERRORS.insert_p()-' );
 END IF;
EXCEPTION
 WHEN OTHERS THEN
  arp_standard.debug( 'EXCEPTION ARP_CORRECT_CC_ERRORS.insert_p()' );
  raise;
END insert_p;

/*===========================================================================+
 | PROCEDURE
 |    clear_invoice_pay_info
 |
 | DESCRIPTION
 |    1)Clears the payment information on a invoice
 |    2)Attach an note to the invoice
 |    3)Raise an business event for this action
 |
 |
 | SCOPE - PRIVATE
 |
 |
 | ARGUMENTS  : IN:
 |                p_customer_trx_id - customer_trx_id of the invoice, for which
 |                                    payment information needs to be cleared
 |                p_cc_trx_category - INV/CM etc.
 |                p_source_receipt_id - This will be passed to this if this
 |                                      is being called because of reverse receipt action
 |                p_source_receipt_number - receipt number of above
 |                p_error_notes - note that has to be attached to the invoice
 |              OUT: NONE
 |
 |
 | RETURNS    : None
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by Srinivasa Kini - 25-Aug-2004
 |                        payment uptake
 |                        i) removed ap_bank_account
 |                       ii) added payment_trxn_extension_id
 |
 |  23-MAR-07  MRAYMOND  5589984   Modified routine to handle transactions
 |                         with split payment terms.
 +===========================================================================*/
PROCEDURE clear_invoice_pay_info(p_customer_trx_id IN NUMBER,
                                 p_cc_trx_category IN VARCHAR2,
                                 p_source_receipt_id IN NUMBER DEFAULT NULL,
				 p_source_receipt_number IN VARCHAR2 DEFAULT NULL,
				 p_error_notes IN VARCHAR2) IS
l_cc_error_code ra_customer_trx.cc_error_code%TYPE;
l_cc_error_desc ra_customer_trx.cc_error_text%TYPE;
l_cc_trx_category_dsp VARCHAR2(240);
l_cc_trx_number ra_customer_trx.trx_number%TYPE;
l_cc_trx_currency ra_customer_trx.invoice_currency_code%TYPE;
l_cc_trx_amount NUMBER;
l_cc_trx_date DATE;
l_customer_name hz_parties.party_name%TYPE;
l_customer_number hz_cust_accounts.account_number%TYPE;
l_customer_location hz_cust_site_uses.location%TYPE;
l_cc_number IBY_FNDCPT_PAYER_ASSGN_INSTR_V.CARD_NUMBER%TYPE;
l_payment_trxn_extension_id ra_customer_trx.payment_trxn_extension_id%TYPE;
l_approval_code ra_customer_trx.approval_code%TYPE;
l_collector ar_collectors.name%TYPE;
l_payment_method_name ar_receipt_methods.name%TYPE;
l_days_late NUMBER;
l_billto_contact varchar2(150);
l_salesrep_name ra_salesreps.name%TYPE;
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_standard.debug( 'ARP_CORRECT_CC_ERRORS.clear_invoice_pay_info()+' );
 END IF;
 SELECT  NVL(trx.cc_error_code,'Unknown'),
           NVL(trx.cc_error_text,'Unknown Error'),
           ARPT_SQL_FUNC_UTIL.get_lookup_meaning('CC_TRX_CATEGORY',p_cc_trx_category),
           trx.trx_number,
           trx.invoice_currency_code,
           trx.trx_date,
           party.party_name,
           cust.account_number,
           site_uses.location,
           iby.card_number,
           trx.payment_trxn_extension_id,
           trx.approval_code,
	   ARP_CORRECT_CC_ERRORS.get_collector_name(trx.paying_customer_id,site_uses.site_use_id),
           rm.name
    INTO  l_cc_error_code,
          l_cc_error_desc,
          l_cc_trx_category_dsp,
          l_cc_trx_number,
          l_cc_trx_currency,
          l_cc_trx_date,
          l_customer_name,
          l_customer_number,
          l_customer_location,
          l_cc_number,
          l_payment_trxn_extension_id,
          l_approval_code,
          l_collector,
          l_payment_method_name
    FROM ra_customer_trx trx,
         ar_receipt_methods rm,
         hz_parties party,
         hz_cust_accounts cust,
         hz_cust_site_uses site_uses,
         iby_trxn_extensions_v iby,
         iby_fndcpt_pmt_chnnls_b pc
    WHERE trx.receipt_method_id = rm.receipt_method_id
     AND rm.payment_channel_code = pc.payment_channel_code
     AND pc.instrument_type      = 'CREDITCARD'
     AND trx.paying_customer_id = cust.cust_account_id (+)
     AND cust.party_id = party.party_id (+)
     AND trx.paying_site_use_id = site_uses.site_use_id (+)
     AND iby.trxn_extension_id = trx.payment_trxn_extension_id
     AND trx.customer_trx_id = p_customer_trx_id;

  /* 5589984 - hack to insure that adr and due date are set.  Note
     that this probably should select amount_due_original instead.  Also,
     I kept the other where conditions to insure that this code would
     still raise an unhandled exception if there was no eligible PS.
     My main concern was the status=OP part.. snort!  we are reversing
     a receipt on a closed transaction! */
  SELECT sum(amount_due_remaining), trunc(sysdate) - trunc(max(due_date))
  INTO   l_cc_trx_amount, l_days_late
  FROM   ar_payment_schedules
  WHERE  customer_trx_id = p_customer_trx_id
  AND    selected_for_receipt_batch_id IS NULL
  AND    reserved_type IS NULL
  AND    reserved_value IS NULL;

  /* Splitted the query because if we have a single query, it might give rise
   * to performace issue
   */
  SELECT substrb(RACO_BILL_PARTY.person_last_name,1,50) ||' ' ||
          substrb(RACO_BILL_PARTY.person_first_name,1,50),
          substrb(RA_SALES.NAME,1,50)
   INTO l_billto_contact,
        l_salesrep_name
    FROM ra_customer_trx  CT,
         hz_cust_account_roles  RACO_BILL,
         hz_parties             RACO_BILL_PARTY,
         hz_relationships       RACO_BILL_REL,
         ra_salesreps           RA_SALES
    WHERE ct.bill_to_contact_id  = raco_bill.cust_account_role_id(+)
     and raco_bill.party_id      = raco_bill_rel.party_id(+)
     and  raco_bill_rel.subject_table_name(+) = 'HZ_PARTIES'
     and  raco_bill_rel.object_table_name(+) = 'HZ_PARTIES'
     and  raco_bill_rel.directional_flag(+)  = 'F'
     and  raco_bill.role_type(+)          = 'CONTACT'
     and  raco_bill_rel.subject_id        = raco_bill_party.party_id(+)
     and  raco_bill_rel.status(+)           = 'A'
     and  ct.primary_salesrep_id  = ra_sales.salesrep_id (+)
     and  ct.customer_trx_id = p_customer_trx_id;

 UPDATE ra_customer_trx
 SET payment_trxn_extension_id = NULL,
    receipt_method_id = NULL,
    cc_error_flag = NULL,
    cc_error_code = NULL,
    cc_error_text = NULL,
    last_update_date = sysdate,
    last_updated_by = pg_user_id,
    last_update_login = NVL(pg_login_id,pg_conc_login_id)
 WHERE customer_trx_id = p_customer_trx_id;

 /* Attach note */
 attach_notes(p_customer_trx_id  => p_customer_trx_id,
           	p_text => p_error_notes);

 Raise_Collection_Event(p_cc_trx_id => p_customer_trx_id,
                             p_cc_error_code=> l_cc_error_code,
			     p_cc_error_desc => l_cc_error_desc,
			     p_cc_trx_category_dsp=>l_cc_trx_category_dsp,
			     p_cc_trx_number=>l_cc_trx_number,
			     p_cc_trx_currency=>l_cc_trx_currency,
			     p_cc_trx_amount=>l_cc_trx_amount,
			     p_cc_trx_date=>l_cc_trx_date,
			     p_customer_name=>l_customer_name,
			     p_customer_number=>l_customer_number,
			     p_customer_location=>l_customer_location,
			     p_cc_number=>l_cc_number,
			     p_payment_trxn_extension_id=>l_payment_trxn_extension_id,
			     p_approval_code=>l_approval_code,
			     p_collector=>l_collector,
			     p_payment_method_name=>l_payment_method_name,
			     p_billto_contact => l_billto_contact,
                             p_salesrep_name => l_salesrep_name,
			     p_source_receipt_id=>p_source_receipt_id,
			     p_source_receipt_num=>p_source_receipt_number,
			     p_error_notes=>p_error_notes);



 IF PG_DEBUG in ('Y', 'C') THEN
  arp_standard.debug( 'ARP_CORRECT_CC_ERRORS.clear_invoice_pay_info()-' );
 END IF;
 EXCEPTION
  WHEN OTHERS THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug( 'Exception ARP_CORRECT_CC_ERRORS.clear_invoice_pay_info()' );
  END IF;
  raise;
END clear_invoice_pay_info;

/*===========================================================================+
 | FUNCTION
 |    default_reversal_gl_date
 |
 | DESCRIPTION
 |    1)Return reversal gl date for a receipt
 |
 |
 | SCOPE - PRIVATE
 |
 |
 | ARGUMENTS  : IN:
 |                p_cash_receipt_id
 |              OUT: NONE
 |
 |
 | RETURNS    : Reversal gl date
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by Srinivasa Kini - 25-Aug-2004
 |
 +===========================================================================*/
FUNCTION default_reversal_gl_date(p_cash_receipt_id IN NUMBER) RETURN DATE IS
l_sob_id NUMBER;
l_error_message      VARCHAR2(128);
l_defaulting_rule_used VARCHAR2(50);
l_default_gl_date    DATE;
l_gl_date DATE;
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_standard.debug( 'ARP_CORRECT_CC_ERRORS.default_reversal_gl_date()+' );
 END IF;
 SELECT max(gl_date)
 INTO l_gl_date
 FROM ar_cash_receipt_history
 WHERE cash_receipt_id = p_cash_receipt_id;

 SELECT set_of_books_id
 INTO l_sob_id
 FROM ar_cash_receipts
 WHERE cash_receipt_id = p_cash_receipt_id;

 IF (arp_util.validate_and_default_gl_date(
                                       l_gl_date,
                                       NULL,
                                       l_gl_date,
                                       NULL,
                                       NULL,
                                       l_gl_date,
                                       NULL,
                                       NULL,
                                       'N',
                                       NULL,
                                      l_sob_id,
                                       222,
                                      l_default_gl_date,
                                      l_defaulting_rule_used,
                                      l_error_message) = TRUE) THEN
      IF trunc(l_default_gl_date) > trunc(sysdate) THEN
       RETURN l_default_gl_date;
      ELSE
        RETURN trunc(sysdate);
      END IF;
  ELSE
      FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', l_error_message);
      FND_MSG_PUB.Add;
      app_exception.raise_exception;
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug( 'ARP_CORRECT_CC_ERRORS.default_reversal_gl_date()-' );
  END IF;
EXCEPTION
 WHEN OTHERS THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug( 'EXCEPTION ARP_CORRECT_CC_ERRORS.default_reversal_gl_date()' );
  END IF;
  raise;
END default_reversal_gl_date;

/*===========================================================================+
 | FUNCTION
 |    default_reversal_date
 |
 | DESCRIPTION
 |    1)Return reversal date for a receipt
 |
 |
 | SCOPE - PRIVATE
 |
 |
 | ARGUMENTS  : IN:
 |                p_cash_receipt_id
 |              OUT: NONE
 |
 |
 | RETURNS    : Reversal date
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by Srinivasa Kini - 25-Aug-2004
 |
 +===========================================================================*/
FUNCTION default_reversal_date(p_cash_receipt_id IN NUMBER) RETURN DATE IS
l_receipt_date DATE;
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_standard.debug( 'ARP_CORRECT_CC_ERRORS.default_reversal_date()+' );
 END IF;
 SELECT receipt_date
 INTO l_receipt_date
 FROM ar_cash_receipts
 WHERE cash_receipt_id = p_cash_receipt_id;

 IF trunc(l_receipt_date) < trunc(sysdate) THEN
  RETURN trunc(sysdate);
 ELSE
   RETURN l_receipt_date;
 END IF;
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_standard.debug( 'ARP_CORRECT_CC_ERRORS.default_reversal_date()+' );
 END IF;
END default_reversal_date;

/*===========================================================================+
 | PROCEDURE
 |    reverse_receipt
 |
 | DESCRIPTION
 |    reverses the receipt using receipt API AR_RECEIPT_API_PUB.Reverse
 |
 |
 | SCOPE - PRIVATE
 |
 |
 | ARGUMENTS  : IN:
 |                p_cash_receipt_id
 |                x_reversal_comments - reversal comments
 |              OUT: NONE
 |
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by Srinivasa Kini - 25-Aug-2004
 |
 +===========================================================================*/
PROCEDURE reverse_receipt(p_cash_receipt_id IN ar_cash_receipts.cash_receipt_id%TYPE,
                          x_reversal_comments IN VARCHAR2 DEFAULT NULL) IS
l_reversal_gl_date DATE;
l_reversal_date DATE;
l_called_from VARCHAR2(30) DEFAULT NULL;
l_return_status            VARCHAR2(1);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);
l_msg_index                NUMBER;
API_exception              EXCEPTION;
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_CORRECT_CC_ERRORS.reverse_receipt()+' );
   END IF;
   --
   -- Populate the arguments to pass to AR_RECEIPT_API_PUB.Reverse
   --
   l_reversal_gl_date := default_reversal_gl_date(p_cash_receipt_id);
   l_reversal_date := default_reversal_date(p_cash_receipt_id);

   AR_RECEIPT_API_PUB.Reverse(
                                     p_api_version           => 1.0,
                                         p_init_msg_list          => FND_API.G_TRUE,
                                         x_return_status          => l_return_status,
                                         x_msg_count              => l_msg_count,
                                         x_msg_data               => l_msg_data,
                                         p_cash_receipt_id        => p_cash_receipt_id,
                                         p_reversal_reason_code   =>'CC ERROR CORRECTION ACTION',
                                         p_reversal_comments      => x_reversal_comments,
                                         p_reversal_category_code =>'REV',
                                         p_reversal_gl_date       => l_reversal_gl_date,
                                         p_reversal_date          => l_reversal_date,
                                         p_called_from            => 'CC ERROR HANDLING');

   /*------------------------------------------------+
    | Write API output to the concurrent program log |
    +------------------------------------------------*/
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('reverse_action: ' || 'API error count '||to_char(NVL(l_msg_count,0)));
   END IF;

   IF NVL(l_msg_count,0)  > 0 Then

          IF l_msg_count  = 1 Then

             /*------------------------------------------------+
              | There is one message returned by the API, so it|
              | has been sent out NOCOPY in the parameter x_msg_data  |
              +------------------------------------------------*/
                 IF PG_DEBUG in ('Y', 'C') THEN
                    arp_util.debug('reverse_action: ' || l_msg_data);
                 END IF;

      ELSIF l_msg_count > 1 Then

                 /*-------------------------------------------------------+
                  | There are more than one messages returned by the API, |
                  | so call them in a loop and print the messages         |
                  +-------------------------------------------------------*/

             FOR l_count IN 1..l_msg_count LOOP

                        l_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,
                                                                      FND_API.G_FALSE);
                        IF PG_DEBUG in ('Y', 'C') THEN
                           arp_util.debug('reverse_action: ' || to_char(l_count)||' : '||l_msg_data);
                        END IF;

                 END LOOP;

          END IF; -- l_msg_count

   END IF; -- NVL(l_msg_count,0)

   /*-----------------------------------------------------+
    | If API return status is not SUCCESS raise exception |
    +-----------------------------------------------------*/
   IF l_return_status = FND_API.G_RET_STS_SUCCESS Then

      /*-----------------------------------------------------+
           | Success do nothing, else branch introduced to make  |
           | sure that NULL case will also raise exception       |
           +-----------------------------------------------------*/
          NULL;

   ELSE
          /*---------------------------+
           | Error, raise an exception |
           +---------------------------*/
      RAISE API_exception;

   END IF; -- l_return_status

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_CORRECT_CC_ERRORS.reverse_receipt()-' );
   END IF;
EXCEPTION
   WHEN API_exception THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('ARP_CORRECT_CC_ERRORS.reverse_action: ' || 'API EXCEPTION: ' ||
                             'ARP_CORRECT_CC_ERRORS.reverse_receipt'
                                         ||SQLERRM);
          END IF;
          RAISE;
   WHEN OTHERS THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('EXCEPTION: ARP_CORRECT_CC_ERRORS.reverse_receipt '
                                         ||SQLERRM);
          END IF;
         RAISE;
END reverse_receipt;

/*===========================================================================+
 | PROCEDURE
 |    Raise_RefundReverse_Event
 |
 | DESCRIPTION
 |    raises event 'oracle.apps.ar.ccerrorhandling.RefunReverse'
 |    which to be caught by payables
 |
 |
 | SCOPE - PRIVATE
 |
 |
 | ARGUMENTS  : IN:
 |                p_misc_cash_receipt_id
 |                p_cc_error_code
 |                p_cc_error_desc
 |                p_cc_trx_number
 |                p_cc_trx_currency
 |                p_cc_trx_amount
 |                p_cc_trx_date
 |                p_customer_name
 |                p_customer_number
 |                p_customer_location
 |                p_cc_number
 |                p_payment_trxn_extension_id
 |                p_approval_code
 |                p_collector
 |                p_payment_method_name
 |                p_source_receipt_id
 |                p_source_receipt_num
 |                p_error_notes
 |              OUT: NONE
 |
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by Srinivasa Kini - 25-Aug-2004
 |
 +===========================================================================*/
PROCEDURE Raise_RefundReverse_Event(p_misc_cash_receipt_id IN NUMBER,
                                 p_cc_error_code IN VARCHAR2,
				 p_cc_error_desc IN VARCHAR2,
				 p_cc_trx_number IN VARCHAR2,
			         p_cc_trx_currency IN VARCHAR2,
			         p_cc_trx_amount IN NUMBER,
			         p_cc_trx_date IN DATE,
			         p_customer_name IN VARCHAR2,
			         p_customer_number IN VARCHAR2,
			         p_customer_location IN VARCHAR2,
			         p_cc_number IN VARCHAR2,
			         p_payment_trxn_extension_id IN NUMBER,
			         p_approval_code IN VARCHAR2,
			         p_collector IN VARCHAR2,
                                 p_payment_method_name IN VARCHAR2,
				 p_source_receipt_id IN NUMBER,
                                 p_source_receipt_num IN VARCHAR2,
				 p_error_notes IN VARCHAR2
                                 ) IS
    l_list           WF_PARAMETER_LIST_T;
    l_param          WF_PARAMETER_T;
    l_key            VARCHAR2(240);
    l_event_name     VARCHAR2(150);
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('ARP_CORRECT_CC_ERRORS.Raise_RefundReverse_Event (+)');
 END IF;
 -- Assign the business event
 l_event_name := 'oracle.apps.ar.ccerrorhandling.RefunReverse';
 --Get the item key
 l_key := item_key( l_event_name ,
                    p_misc_cash_receipt_id);
 -- initialization of object variables
 l_list := WF_PARAMETER_LIST_T();

 -- Add Context values to the list
 AddParamEnvToList(l_list);

 -- add more parameters to the parameters list
 wf_event.AddParameterToList(p_name => 'REFUND MISC CASH RECEIPT ID',
                             p_value => p_misc_cash_receipt_id,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'CREDIT CARD ERROR CODE',
                             p_value => p_cc_error_code,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'CREDIT CARD ERROR DESCRIPTION',
                             p_value => p_cc_error_desc,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'REFUD MISC RECEIPT NUMBER',
                             p_value => p_cc_trx_number,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'CURRENCY CODE',
                             p_value => p_cc_trx_currency,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'AMOUNT',
                             p_value => p_cc_trx_amount,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'REFUND DATE',
                             p_value => p_cc_trx_date,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'CUSTOMER NAME',
                             p_value => p_customer_name,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'CUSTOMER NUMBER',
                             p_value => p_customer_number,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'CUSTOMER LOCATION',
                             p_value => p_customer_location,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'CREDIT CARD NUMBER',
                             p_value => p_cc_number,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'APPROVAL CODE',
                             p_value => p_approval_code,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'PAYMENT SERVER ID',
                             p_value => p_payment_trxn_extension_id,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'COLLECTOR',
                             p_value => p_collector,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'PAYMENT METHOD NAME',
                             p_value => p_payment_method_name,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'SOURCE CASH RECEIPT ID',
                             p_value => p_source_receipt_id,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'SOURCE RECEIPT NUMBER',
                             p_value => p_source_receipt_num,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'CREDIT CARD CORRECTION NOTES',
                             p_value => p_error_notes,
                             p_parameterlist => l_list);
 -- Raise Event
 raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );
 l_list.DELETE;
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('ARP_CORRECT_CC_ERRORS.Raise_RefundReverse_Event (-)');
 END IF;
EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ERR RAISING EVENT in ARP_CORRECT_CC_ERRORS.Raise_RefundReverse_Event: '||l_event_name);
  END IF;
  raise;
END Raise_RefundReverse_Event;

/*===========================================================================+
 | PROCEDURE
 |    Raise_RefundReverse_Event
 |
 | DESCRIPTION
 |    raises event 'oracle.apps.ar.ccerrorhandling.ClrInvPayInfoORReverseReceipt'
 |    which to be caught by collections
 |    This event typically followed by reversal of a receipt or clearing
 |    of payment information triggered by cc corrective action
 |
 |
 | SCOPE - PRIVATE
 |
 |
 | ARGUMENTS  : IN:
 |                p_cc_trx_id
 |                p_cc_error_code
 |                p_cc_error_desc
 |                p_cc_trx_category_dsp
 |                p_cc_trx_number
 |                p_cc_trx_currency
 |                p_cc_trx_amount
 |                p_cc_trx_date
 |                p_customer_name
 |                p_customer_number
 |                p_customer_location
 |                p_cc_number
 |                p_approval_code
 |                p_collector
 |                p_payment_method_name
 |		  p_billto_contact
 |                p_salesrep_name
 |	          p_source_receipt_id - cash_receipt_id of the receipt which triggered the
 |                                      clearance of payment information from the invoice
 |		  p_source_receipt_num - receipt no. of above
 |                p_source_receipt_id
 |                p_source_receipt_num
 |                p_error_notes
 |              OUT: NONE
 |
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by Srinivasa Kini - 25-Aug-2004
 |
 +===========================================================================*/
PROCEDURE Raise_Collection_Event(
                                 p_cc_trx_id IN NUMBER,
                                 p_cc_error_code IN VARCHAR2,
				 p_cc_error_desc IN VARCHAR2,
				 p_cc_trx_category_dsp IN VARCHAR2,
				 p_cc_trx_number IN VARCHAR2,
			         p_cc_trx_currency IN VARCHAR2,
			         p_cc_trx_amount IN NUMBER,
			         p_cc_trx_date IN DATE,
			         p_customer_name IN VARCHAR2,
			         p_customer_number IN VARCHAR2,
			         p_customer_location IN VARCHAR2,
			         p_cc_number IN VARCHAR2,
			         p_payment_trxn_extension_id IN NUMBER,
			         p_approval_code IN VARCHAR2,
			         p_collector IN VARCHAR2,
                                 p_payment_method_name IN VARCHAR2,
				 p_billto_contact IN VARCHAR2 DEFAULT NULL,
                                 p_salesrep_name IN VARCHAR2 DEFAULT NULL,
			         p_source_receipt_id IN NUMBER DEFAULT NULL,
			         p_source_receipt_num IN VARCHAR2 DEFAULT NULL,
				 p_error_notes IN VARCHAR2) IS
    l_list           WF_PARAMETER_LIST_T;
    l_param          WF_PARAMETER_T;
    l_key            VARCHAR2(240);
    l_event_name     VARCHAR2(150);
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('ARP_CORRECT_CC_ERRORS.Raise_Collection_Event (+)');
 END IF;
 --Assign the business event name
 l_event_name := 'oracle.apps.ar.ccerrorhandling.ClrInvPayInfoORReverseReceipt';
 --Get the item key
 l_key := item_key( l_event_name ,
                    p_cc_trx_id);
 -- initialization of object variables
 l_list := WF_PARAMETER_LIST_T();

 -- Add Context values to the list
 AddParamEnvToList(l_list);

 -- add more parameters to the parameters list
 wf_event.AddParameterToList(p_name => 'CREDIT CARD TRANSACTION ID',
                             p_value => p_cc_trx_id,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'CREDIT CARD ERROR CODE',
                             p_value => p_cc_error_code,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'CREDIT CARD ERROR DESCRIPTION',
                             p_value => p_cc_error_desc,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'TRANSACTION CATEGORY',
                             p_value => p_cc_trx_category_dsp,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'REFUD MISC RECEIPT NUMBER',
                             p_value => p_cc_trx_number,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'CURRENCY CODE',
                             p_value => p_cc_trx_currency,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'AMOUNT',
                             p_value => p_cc_trx_amount,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'REFUND DATE',
                             p_value => p_cc_trx_date,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'CUSTOMER NAME',
                             p_value => p_customer_name,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'CUSTOMER NUMBER',
                             p_value => p_customer_number,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'CUSTOMER LOCATION',
                             p_value => p_customer_location,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'CREDIT CARD NUMBER',
                             p_value => p_cc_number,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'APPROVAL CODE',
                             p_value => p_approval_code,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'PAYMENT SERVER ID',
                             p_value => p_payment_trxn_extension_id,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'COLLECTOR',
                             p_value => p_collector,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'PAYMENT METHOD NAME',
                             p_value => p_payment_method_name,
                             p_parameterlist => l_list);
 wf_event.AddParameterToList(p_name => 'CREDIT CARD CORRECTION NOTES',
                             p_value => p_error_notes,
                             p_parameterlist => l_list);
 IF p_source_receipt_id IS NOT NULL THEN
  wf_event.AddParameterToList(p_name => 'SOURCE CASH RECEIPT ID',
                              p_value => p_source_receipt_id,
                              p_parameterlist => l_list);
 END IF;
 IF p_source_receipt_num IS NOT NULL THEN
  wf_event.AddParameterToList(p_name => 'SOURCE RECEIPT NUMBER',
                             p_value => p_source_receipt_num,
                             p_parameterlist => l_list);
 END IF;
 IF p_billto_contact IS NOT NULL THEN
  wf_event.AddParameterToList(p_name => 'BILL TO CONTACT',
                             p_value => p_billto_contact,
                             p_parameterlist => l_list);
 END IF;
 IF p_salesrep_name IS NOT NULL THEN
  wf_event.AddParameterToList(p_name => 'SALES REP NAME',
                             p_value => p_salesrep_name,
                             p_parameterlist => l_list);
 END IF;


 -- Raise Event
 raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );
 l_list.DELETE;
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('ARP_CORRECT_CC_ERRORS.Raise_Collection_Event (-)');
 END IF;
EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ERR RAISING EVENT from ARP_CORRECT_CC_ERRORS.Raise_Collection_Event: '||l_event_name);
   raise;
  END IF;
END Raise_Collection_Event;

/*===========================================================================+
 | PROCEDURE
 |    AddParamEnvToList
 |
 | DESCRIPTION
 |    Adds user name and org name to business event parameter list
 |
 |
 | SCOPE - PRIVATE
 |
 |
 | ARGUMENTS  : IN/OUT:
 |                x_list - Business event parameter list
 |
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by Srinivasa Kini - 25-Aug-2004
 |
 +===========================================================================*/
PROCEDURE AddParamEnvToList( x_list IN OUT NOCOPY WF_PARAMETER_LIST_T) IS
 l_param             WF_PARAMETER_T;
 l_rang              NUMBER;
 l_org_name          VARCHAR2(240);
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ARP_CORRECT_CC_ERRORS.AddParamEnvToList ()+');
   END IF;
   l_rang :=  0;

   /* Get the org_name to pass while raising the business event */
   BEGIN
    SELECT name INTO l_org_name
    FROM hr_all_organization_units
    WHERE organization_id = fnd_profile.value( 'ORG_ID');
   EXCEPTION
    WHEN OTHERS THEN
     l_org_name := NULL;
   END;

   l_param := WF_PARAMETER_T( NULL, NULL );
   -- fill the parameters list
   x_list.extend;
   l_param.SetName( 'USER NAME' );
   l_param.SetValue( pg_user_name);
   l_rang  := l_rang + 1;
   x_list(l_rang) := l_param;

   l_param := WF_PARAMETER_T( NULL, NULL );
   -- fill the parameters list
   x_list.extend;
   l_param.SetName( 'ORG NAME' );
   l_param.SetValue( l_org_name );
   l_rang  := l_rang + 1;
   x_list(l_rang) := l_param;
   IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ARP_CORRECT_CC_ERRORS.AddParamEnvToList ()-');
   END IF;
EXCEPTION
 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('EXCEPTION ARP_CORRECT_CC_ERRORS.AddParamEnvToList ()');
   END IF;
   raise;
END AddParamEnvToList;

FUNCTION item_key(p_event_name  IN VARCHAR2,
                   p_unique_identifier  NUMBER) RETURN VARCHAR2
IS
  RetKey VARCHAR2(240);
BEGIN
   RetKey := p_event_name||'_'||to_char(p_unique_identifier)||'_'||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS');
 Return RetKey;
END item_key;

/*===========================================================================+
 | FUNCTION
 |    event
 |
 | DESCRIPTION
 |    Checks if the event exist
 |
 |
 | SCOPE - PRIVATE
 |
 |
 | ARGUMENTS  : IN:
 |                p_event_name - Business event name
 |              OUT: NONE
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by Srinivasa Kini - 25-Aug-2004
 |
 +===========================================================================*/
FUNCTION event(p_event_name IN VARCHAR2) RETURN VARCHAR2
 -----------------------------------------------
 -- Return event name if the entered event exist
 -- Otherwise return NOTFOUND
 -----------------------------------------------
IS
  RetEvent VARCHAR2(240);
  CURSOR get_event IS
   SELECT name
     FROM wf_events
    WHERE name = p_event_name;
BEGIN
   OPEN get_event;

   FETCH get_event INTO RetEvent;
    IF get_event%NOTFOUND THEN
     RetEvent := 'NOTFOUND';
    END IF;
   CLOSE get_event;

   RETURN RetEvent;
END event;

PROCEDURE raise_event
 (p_event_name          IN   VARCHAR2,
  p_event_key           IN   VARCHAR2,
  p_data                IN   CLOB DEFAULT NULL,
  p_parameters          IN   wf_parameter_list_t DEFAULT NULL)
IS
  l_item_key      VARCHAR2(240);
  l_event         VARCHAR2(240);
  EventNotFound   EXCEPTION;
  EventNotARCC  EXCEPTION;
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('ARP_CORRECT_CC_ERRORS.raise_event ()+');
  END IF;

  SAVEPOINT ar_cccorrection_raise_event;

  l_event := event(p_event_name);

  IF l_event = 'NOTFOUND' THEN
    RAISE EventNotFound;
  END IF;

  IF SUBSTRB(l_event,1,31) <> 'oracle.apps.ar.ccerrorhandling.' THEN
    RAISE EventNotARCC;
  END IF;

  Wf_Event.Raise
  ( p_event_name   =>  l_event,
    p_event_key    =>  p_event_key,
    p_parameters   =>  p_parameters,
    p_event_data   =>  p_data);

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('ARP_CORRECT_CC_ERRORS.raise_event ()-');
  END IF;

  EXCEPTION
    WHEN EventNotFound THEN

        FND_MESSAGE.SET_NAME( 'AR', 'AR_EVENTNOTFOUND');
        FND_MESSAGE.SET_TOKEN( 'EVENT' ,p_event_name );
	FND_MSG_PUB.Add;
        app_exception.raise_exception;

    WHEN EventNotARCC    THEN
        FND_MESSAGE.SET_NAME( 'AR', 'AR_EVENTNOTAR');
        FND_MESSAGE.SET_TOKEN( 'EVENT' ,p_event_name );
	FND_MSG_PUB.Add;
        app_exception.raise_exception;

    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO ar_cccorrection_raise_event;
        FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
	FND_MSG_PUB.Add;
        app_exception.raise_exception;

    WHEN OTHERS        THEN
        ROLLBACK TO ar_cccorrection_raise_event;
        FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
	FND_MSG_PUB.Add;
        app_exception.raise_exception;
END raise_event;

/*===========================================================================+
 | PROCEDURE
 |    attach_notes
 |
 | DESCRIPTION
 |    Attaches the note to the invoice
 |
 |
 | SCOPE - PRIVATE
 |
 |
 | ARGUMENTS  : IN:
 |                p_customer_trx_id - customer_trx_id of the invoice for which note
 |                                    to be attached
 |                p_text - note text
 |              OUT: NONE
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by Srinivasa Kini - 25-Aug-2004
 |
 +===========================================================================*/
PROCEDURE  attach_notes(p_customer_trx_id  IN NUMBER,
		        p_text IN VARCHAR2) IS
l_note_id  ar_notes.note_id%type;
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug('ARP_CORRECT_CC_ERRORS.attach_notes()+');
 END IF;

   INSERT INTO ar_notes
    (
     note_id,
     note_type,
     text,
     customer_trx_id,
     customer_call_id,
     customer_call_topic_id,
     call_action_id,
     last_updated_by,
     last_update_date,
     last_update_login,
     created_by,
     creation_date
    )
   VALUES
    (
     ar_notes_s.nextval,
     'MAINTAIN',
     p_text,
     p_customer_trx_id,
     NULL,
     NULL,
     NULL,
     pg_user_id,
     sysdate,
     NVL(pg_conc_login_id, pg_login_id),
     pg_user_id,
     sysdate
    );
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug('ARP_CORRECT_CC_ERRORS.attach_notes()-');
 END IF;
EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('EXCEPTION:  ARP_CORRECT_CC_ERRORS.attach_notes()');
      END IF;
      raise;
END attach_notes;

/*===========================================================================+
 | PROCEDURE
 |    lock_table_nowait
 |
 | DESCRIPTION
 |    Locks the table, this would be mainly used by OA frame work UI
 |
 |
 | SCOPE - PUBLIC
 |
 |
 | ARGUMENTS  : IN:
 |                 p_key - primary key of the record to be locked
 |                 p_object_version_number  - Applicable for receipts only
 |                 p_table_name - RA_CUSTOMER_TRX/AR_CASH_RECEIPTS/CASH/MISC
 |                 p_trx_number - receipt no./trx no.(USed to show in messages)
 |              OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by Srinivasa Kini - 25-Aug-2004
 |
 +===========================================================================*/
PROCEDURE lock_table_nowait(p_key IN NUMBER,
                 p_object_version_number IN NUMBER DEFAULT NULL,
		 p_table_name IN VARCHAR2,
		 p_trx_number IN VARCHAR2) IS
l_dummy_number NUMBER;
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug('ARP_CORRECT_CC_ERRORS.lock_table_nowait()+');
 END IF;
 IF p_table_name in ('AR_CASH_RECEIPTS','CASH','MISC') THEN
   arp_cash_receipts_pkg.nowaitlock_version_p(p_key,p_object_version_number);
 ELSE
 -- Here we need to consider calling some procedure
 -- which does locking
   ARP_CT_PKG.lock_p(p_key);
 END IF;
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug('ARP_CORRECT_CC_ERRORS.lock_table_nowait()-');
 END IF;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
  IF p_table_name in ('AR_CASH_RECEIPTS','CASH','MISC') THEN
    FND_MESSAGE.SET_NAME('AR','AR_RECEIPT_RECORD_CHANGED');
    FND_MESSAGE.SET_TOKEN('PARAMETER',p_trx_number);
    FND_MSG_PUB.Add;
  ELSE
    FND_MESSAGE.SET_NAME('AR','AR_TRANSACTION_RECORD_CHANGED');
    FND_MESSAGE.SET_TOKEN('PARAMETER',p_trx_number);
    FND_MSG_PUB.Add;
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('EXCEPTION:  ARP_CORRECT_CC_ERRORS.lock_table_nowait()');
  END IF;
  app_exception.raise_exception;
 WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
  IF p_table_name in ('AR_CASH_RECEIPTS','CASH','MISC') THEN
    FND_MESSAGE.SET_NAME('AR','AR_RECEIPT_RECORD_LOCKED');
    FND_MESSAGE.SET_TOKEN('PARAMETER',p_trx_number);
    FND_MSG_PUB.Add;
  ELSE
    FND_MESSAGE.SET_NAME('AR','AR_TRANSACTION_RECORD_LOCKED');
    FND_MESSAGE.SET_TOKEN('PARAMETER',p_trx_number);
    FND_MSG_PUB.Add;
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('EXCEPTION:  ARP_CORRECT_CC_ERRORS.lock_table_nowait()');
  END IF;
  app_exception.raise_exception;
 WHEN OTHERS THEN
  raise;
END lock_table_nowait;

/*===========================================================================+
 | FUNCTION
 |    cc_error_occurred
 |
 | DESCRIPTION
 |    Checks if CC error has been occured in a autoreceipt/remittance batch
 |
 |
 | SCOPE - PRIVATE
 |
 |
 | ARGUMENTS  : IN:
 |                p_mode : CREATION/REMITTANCE
 |                p_request_id : Request id of autoreceipt/remittance batch
 |              OUT: NONE
 |
 | RETURNS    : Y if atleast one transaction has been CC errored
 |              and has error code attached with it. 'N' otherwise
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by Srinivasa Kini - 25-Aug-2004
 |
 +===========================================================================*/
FUNCTION cc_error_occurred(p_mode VARCHAR2,p_request_id NUMBER) RETURN VARCHAR2 IS
l_return_status VARCHAR2(1);
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug('ARP_CORRECT_CC_ERRORS.cc_error_occurred()+');
 END IF;
 l_return_status := 'Y';
 IF p_mode = 'REMITTANCE' THEN
  BEGIN
   SELECT 'Y'
   INTO l_return_status
   FROM dual
   WHERE EXISTS (SELECT 1
                 FROM ar_cash_receipts
                 WHERE request_id IN ( select request_id
                                       from fnd_concurrent_requests
                                       where request_id  = p_request_id
                                       or    parent_request_id = p_request_id )
                 AND cc_error_flag = 'Y');
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
    l_return_status := 'N';
   WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Exception : ARP_CORRECT_CC_ERRORS.cc_error_occurred');
    END IF;
    raise;
  END;
 ELSE
  BEGIN
   SELECT 'Y'
   INTO l_return_status
   FROM dual
   WHERE EXISTS (SELECT 1
                 FROM ra_customer_trx
                 WHERE request_id IN ( select request_id
                                       from fnd_concurrent_requests
                                       where request_id  = p_request_id
                                       or    parent_request_id = p_request_id )
                 AND cc_error_flag = 'Y');
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
    l_return_status := 'N';
   WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Exception : ARP_CORRECT_CC_ERRORS.cc_error_occured');
    END IF;
    raise;
  END;
 END IF;
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug('ARP_CORRECT_CC_ERRORS.cc_error_occurred()-');
 END IF;
 RETURN l_return_status;
END cc_error_occurred;

/*===========================================================================+
 | PROCEDURE
 |    correct_remittance_errors
 |
 | DESCRIPTION
 |    Entry routine to automatically correct CC errors occured
 |    during automatic remittance
 |
 |
 | SCOPE - PRIVATE
 |
 |
 | ARGUMENTS  : IN:
 |                p_request_id : Request id of autoreceipt/remittance batch
 |              OUT: NONE
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by Srinivasa Kini - 25-Aug-2004
 |
 +===========================================================================*/
PROCEDURE correct_remittance_errors(p_request_id IN NUMBER) IS
l_cc_error_hist ar_cc_error_history%ROWTYPE;
l_cc_trx_category ar_cc_error_history.cc_trx_category%TYPE;
l_error_notes VARCHAR2(240);
l_cc_error_desc VARCHAR2(240);
l_first_record_flag VARCHAR2(1);
l_cc_action_type VARCHAR2(1);
l_cc_action_code ar_cc_error_mappings.cc_action_code%TYPE;
CURSOR cr IS
 Select cash_receipt_id,
        type,
	receipt_method_id,
        payment_trxn_extension_id,
	cc_error_code,
        cc_error_text,
        request_id
 FROM ar_cash_receipts
 WHERE request_id IN ( select request_id
                       from fnd_concurrent_requests
                       where request_id  = p_request_id
                       or    parent_request_id = p_request_id )
 AND cc_error_flag = 'Y'
 AND cc_error_code IS NOT NULL;
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug('arp_correct_cc_errors.correct_remittance_errors()+');
 END IF;
 FOR cr_rec IN cr LOOP

  -- Call get_action_code
  get_action_code( p_cc_trx_id           =>   cr_rec.cash_receipt_id,
                   p_cc_trx_category        =>   cr_rec.type,
		   p_receipt_method_id => cr_rec.receipt_method_id,
		   p_payment_trxn_extension_id =>  cr_rec.payment_trxn_extension_id,
                   p_cc_error_code       =>   cr_rec.cc_error_code,
		   x_cc_error_desc       =>   l_cc_error_desc, /* One which was stored in ar_cc_error_mappings*/
                   x_first_record_flag   =>   l_first_record_flag,
		   x_cc_action_code      =>   l_cc_action_code,
                   x_cc_action_type      =>   l_cc_action_type,
		   x_error_notes         =>   l_error_notes);

arp_util.debug('l_cc_action_code '|| l_cc_action_code);
arp_util.debug('l_cc_action_type '|| l_cc_action_type);
arp_util.debug('l_cc_error_desc '|| l_cc_error_desc);
arp_util.debug('l_error_notes '|| l_error_notes);

  IF l_cc_action_code = 'RET' THEN
    -- Unmark the errors so that receipt can be picked next time
    retry(p_cc_trx_id      =>   cr_rec.cash_receipt_id,
          p_cc_trx_category    =>  cr_rec.type,
	  p_payment_trxn_extension_id => cr_rec.payment_trxn_extension_id,
	  p_error_notes         =>   l_error_notes);
  ELSIF l_cc_action_code = 'REAUT REC' THEN
    --null out the PSON info and Unmark the errors so that receipt is picked next time and reauthorized
    reauthorize(p_cc_trx_id      =>   cr_rec.cash_receipt_id,
               p_cc_trx_category    =>  cr_rec.type,
	       p_payment_trxn_extension_id => cr_rec.payment_trxn_extension_id,
	       p_error_notes         =>   l_error_notes);
  ELSIF l_cc_action_code = 'REV REC' THEN
    obtain_alternate_payment(p_cc_trx_id           =>   cr_rec.cash_receipt_id,
                             p_cc_trx_category    =>  cr_rec.type,
			     p_error_notes         =>   l_error_notes);
  END If;

  -- Insert records into ar_cc_error_history
  IF l_cc_action_code in ('RET','REAUT REC','REV REC') THEN
    -- Update current_record_flag in ar_cc_error_history
    IF NVL(l_first_record_flag,'N') <> 'Y' THEN
     UPDATE ar_cc_error_history
     SET current_record_flag = 'N',
        last_update_date = sysdate,
        last_updated_by = pg_user_id,
        last_update_login = NVL(pg_login_id,pg_conc_login_id)
     WHERE cc_trx_id = cr_rec.cash_receipt_id
     AND cc_trx_category = cr_rec.type
     AND payment_trxn_extension_id = cr_rec.payment_trxn_extension_id
     AND cc_error_code = cr_rec.cc_error_code;
    END IF;
    l_cc_error_hist.request_id := cr_rec.request_id;
    l_cc_error_hist.cc_trx_category := cr_rec.type;
    l_cc_error_hist.cc_trx_id := cr_rec.cash_receipt_id;
    l_cc_error_hist.cc_error_code := cr_rec.cc_error_code;
    l_cc_error_hist.cc_vendor_error_desc := cr_rec.cc_error_text;
    l_cc_error_hist.cc_error_text := l_error_notes;
    l_cc_error_hist.cc_action_code := l_cc_action_code;
    l_cc_error_hist.cc_action_type_flag := l_cc_action_type;
    l_cc_error_hist.payment_trxn_extension_id := cr_rec.payment_trxn_extension_id;
    l_cc_error_hist.first_record_flag := l_first_record_flag;
    l_cc_error_hist.current_record_flag := 'Y';
    insert_p(l_cc_error_hist);
  END IF;
END LOOP;
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug('arp_correct_cc_errors.correct_remittance_errors()-');
 END IF;
EXCEPTION
 WHEN OTHERS THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('Exception in arp_correct_cc_errors.correct_remittance_errors()');
  END IF;
  raise;
END correct_remittance_errors;

/*===========================================================================+
 | PROCEDURE
 |    correct_creation_errors
 |
 | DESCRIPTION
 |    Entry routine to automatically correct CC errors occured during
 |    automatic creation program
 |
 |
 | SCOPE - PRIVATE
 |
 |
 | ARGUMENTS  : IN:
 |                p_request_id : Request id of autoreceipt/remittance batch
 |              OUT: NONE
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by Srinivasa Kini - 25-Aug-2004
 |
 +===========================================================================*/
PROCEDURE correct_creation_errors(p_request_id IN NUMBER) IS
l_cc_error_hist ar_cc_error_history%ROWTYPE;
l_cc_trx_category ar_cc_error_history.cc_trx_category%TYPE;
l_error_notes VARCHAR2(240);
l_cc_error_desc VARCHAR2(240);
l_first_record_flag VARCHAR2(1);
l_cc_action_type VARCHAR2(1);
l_cc_action_code ar_cc_error_mappings.cc_action_code%TYPE;
CURSOR inv IS
 Select trx.customer_trx_id,
        trx_type.type,
	trx.receipt_method_id,
	trx.payment_trxn_extension_id,
        trx.cc_error_code,
        trx.cc_error_text,
        trx.request_id
 FROM ra_customer_trx trx,
      ra_cust_trx_types trx_type
 WHERE trx.cust_trx_type_id =  trx_type.cust_trx_type_id
 AND trx.request_id IN ( select request_id
                         from fnd_concurrent_requests
                         where request_id  = p_request_id
                         or    parent_request_id = p_request_id )
 AND trx.cc_error_flag = 'Y'
 AND cc_error_code IS NOT NULL;
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_CORRECT_CC_ERRORS.correct_creation_errors()+');
  END IF;
  FOR inv_rec IN inv LOOP
  get_action_code( p_cc_trx_id           =>   inv_rec.customer_trx_id,
                   p_cc_trx_category        =>   inv_rec.type,
		   p_receipt_method_id => inv_rec.receipt_method_id,
		   p_payment_trxn_extension_id =>  inv_rec.payment_trxn_extension_id,
                   p_cc_error_code       =>   inv_rec.cc_error_code,
		   x_cc_error_desc       =>   l_cc_error_desc, /* One which was stored in ar_cc_error_mappings*/
                   x_first_record_flag   =>   l_first_record_flag,
		   x_cc_action_code      =>   l_cc_action_code,
                   x_cc_action_type      =>   l_cc_action_type,
		   x_error_notes         =>   l_error_notes);

arp_util.debug('l_cc_action_code '|| l_cc_action_code);
arp_util.debug('l_cc_action_type '|| l_cc_action_type);
arp_util.debug('l_cc_error_desc '|| l_cc_error_desc);
arp_util.debug('l_error_notes '|| l_error_notes);

   IF l_cc_action_code = 'RET' THEN
    -- Unmark the errors so that invoice is picked next time
    retry(p_cc_trx_id      =>   inv_rec.customer_trx_id,
          p_cc_trx_category    =>  inv_rec.type,
	  p_payment_trxn_extension_id => inv_rec.payment_trxn_extension_id,
	  p_error_notes         =>   l_error_notes);
   ELSIF l_cc_action_code = 'CLR PAY INFO' THEN
    obtain_alternate_payment(p_cc_trx_id           =>   inv_rec.customer_trx_id,
                             p_cc_trx_category    =>  inv_rec.type,
			     p_error_notes         =>   l_error_notes);
   END IF;

  -- Insert records into ar_cc_error_history
  IF l_cc_action_code in ('RET','CLR PAY INFO') THEN
    -- Update current_record_flag in ar_cc_error_history
    IF NVL(l_first_record_flag,'N') <> 'Y' THEN
     UPDATE ar_cc_error_history
     SET current_record_flag = 'N',
        last_update_date = sysdate,
        last_updated_by = pg_user_id,
        last_update_login = NVL(pg_login_id,pg_conc_login_id)
     WHERE cc_trx_id = inv_rec.customer_trx_id
     AND cc_trx_category = inv_rec.type
     AND payment_trxn_extension_id = inv_rec.payment_trxn_extension_id
     AND cc_error_code = inv_rec.cc_error_code;
     arp_util.debug('Update current_record_flag. Sql%rowcount '|| sql%rowcount);

    END IF;
    l_cc_error_hist.request_id := inv_rec.request_id;
    l_cc_error_hist.cc_trx_category := inv_rec.type;
    l_cc_error_hist.cc_trx_id := inv_rec.customer_trx_id;
    l_cc_error_hist.cc_error_code := inv_rec.cc_error_code;
    l_cc_error_hist.cc_vendor_error_desc := inv_rec.cc_error_text;
    l_cc_error_hist.cc_error_text := l_error_notes;
    l_cc_error_hist.cc_action_code := l_cc_action_code;
    l_cc_error_hist.cc_action_type_flag := l_cc_action_type;
    l_cc_error_hist.payment_trxn_extension_id := inv_rec.payment_trxn_extension_id;
    l_cc_error_hist.first_record_flag := l_first_record_flag;
    l_cc_error_hist.current_record_flag := 'Y';

    arp_util.debug('Calling Insert into ar_cc_error_history');
    insert_p(l_cc_error_hist);
  END IF;
END LOOP;
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_CORRECT_CC_ERRORS.correct_creation_errors()-');
  END IF;
EXCEPTION
 WHEN OTHERS THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('EXCEPTION ARP_CORRECT_CC_ERRORS.correct_creation_errors()');
  END IF;
  RAISE;
END correct_creation_errors;

/*===========================================================================+
 | PROCEDURE
 |    retry
 |
 | DESCRIPTION
 |    Make credit card errored transaction available
 |    for next run of automatic receipt creation/remittance by marking it as
 |    non-errored
 |
 |
 | SCOPE - PUBLIC
 |
 |
 | ARGUMENTS  : IN:
 |                 p_cc_trx_id  - Cash_receipt_id/Customer_trx_id
 |                 p_cc_trx_category - RECEIPT/INVOICE/REFUND
 |                 p_payment_trxn_extension_id - This is the id correpsonding to
 |                                              errored credit card in iby_trxn_extensions_v
 |                 p_error_notes - Error notes to be attached
 |              OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by Srinivasa Kini - 25-Aug-2004
 |
 +===========================================================================*/
PROCEDURE retry(p_cc_trx_id IN NUMBER,
                p_cc_trx_category IN VARCHAR2,
		p_payment_trxn_extension_id IN NUMBER,
	        p_error_notes IN VARCHAR2) IS
l_error_notes VARCHAR2(240);
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug('ARP_CORRECT_CC_ERRORS.retry()+');
  arp_util.debug('p_payment_trxn_extension_id ' || p_payment_trxn_extension_id );
  arp_util.debug('p_cc_trx_category ' || p_cc_trx_category);
  arp_util.debug('p_error_notes ' || p_error_notes);
 END IF;
 IF (p_error_notes IS NULL) OR(p_error_notes = ' ') THEN
  l_error_notes := NULL;
 ELSE
  l_error_notes := p_error_notes;
 END IF;
 IF p_cc_trx_category IN ('CASH','MISC') THEN
  arp_util.debug('Updating ar_cash_receipts record');
  arp_util.debug('cash_receipt_id '|| p_cc_trx_id);

  UPDATE ar_cash_receipts
  SET cc_error_flag = NULL,
      cc_error_code = NULL,
      cc_error_text = NULL,
      comments = DECODE(p_error_notes,NULL,comments,substrb('<'||l_error_notes||'>'||comments,1,2000)),
      rec_version_number = rec_version_number+1
  WHERE cash_receipt_id = p_cc_trx_id;

  arp_util.debug ('Sql rows updated ' || sql%rowcount);

 ELSE
  arp_util.debug('Updating ra_customer_trx records');
  arp_util.debug('customer_trx_id '|| p_cc_trx_id);

  UPDATE ra_customer_trx
  SET cc_error_flag =NULL,
      cc_error_code = NULL,
      cc_error_text = NULL
  WHERE customer_trx_id = p_cc_trx_id;

  arp_util.debug ('Sql rows updated ' || sql%rowcount);

  IF l_error_notes IS NOT NULL THEN
   attach_notes(p_customer_trx_id => p_cc_trx_id,
                p_text => l_error_notes);
  END IF;
 END IF;

 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug('ARP_CORRECT_CC_ERRORS.retry()-');
 END IF;
EXCEPTION
 WHEN OTHERS THEN
  arp_util.debug('Exception in ARP_CORRECT_CC_ERRORS.retry()');
  raise;
END retry;

/*===========================================================================+
 | PROCEDURE
 |    reauthorize
 |
 | DESCRIPTION
 |    Clears payment server order num and approval code from a receipt so that
 |    the receipt will be re-authorized in the next run of autoremittance
 |
 |
 | SCOPE - PUBLIC
 |
 |
 | ARGUMENTS  : IN:
 |                 p_cc_trx_id  - Cash_receipt_id/Customer_trx_id
 |                 p_cc_trx_category - RECEIPT/INVOICE/REFUND
 |                 p_payment_trxn_extension_id - This is the id correpsonding to
 |                                              errored credit card in iby_trxn_extensions_v
 |                 p_error_notes - Error notes to be attached
 |              OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by Srinivasa Kini - 25-Aug-2004
 |
 +===========================================================================*/
PROCEDURE reauthorize(p_cc_trx_id IN NUMBER,
                    p_cc_trx_category IN VARCHAR2,
		    p_payment_trxn_extension_id IN NUMBER,
	            p_error_notes IN VARCHAR2) IS
l_error_notes VARCHAR2(240);

l_return_status			 VARCHAR2(2000);
l_msg_count			 NUMBER;
l_msg_data			 VARCHAR2(2000);
l_instrument_assignment_id	 NUMBER;
l_response_rec			 IBY_FNDCPT_COMMON_PUB.RESULT_REC_TYPE;
l_payment_trxn_extension_id	 NUMBER;
l_payer_rec			 IBY_FNDCPT_COMMON_PUB.PAYERCONTEXT_REC_TYPE;
l_trxn_attribs_rec		 IBY_FNDCPT_TRXN_PUB.TRXNEXTENSION_REC_TYPE;
l_cust_account_id		 NUMBER;
l_cust_site_use_id           	 NUMBER;
l_party_id                       NUMBER;
l_org_id                         NUMBER;
l_org_type                       VARCHAR2(30);
l_payment_function               VARCHAR2(30);
l_payment_channel                VARCHAR2(30);
l_receipt_number                 ar_cash_receipts.receipt_number%TYPE;

BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug('ARP_CORRECT_CC_ERRORS.reauthorize()+');
 END IF;
 IF (p_error_notes IS NULL) OR(p_error_notes = ' ') THEN
  l_error_notes := NULL;
 ELSE
  l_error_notes := p_error_notes;
 END IF;
 -- Ideally this check is not necessary
 -- as there won't be reauthorization failure for invoice
 IF p_cc_trx_category = 'CASH' THEN
  UPDATE ar_cash_receipts
  SET approval_code = NULL,
      cc_error_flag = NULL,
      cc_error_code = NULL,
      cc_error_text = NULL,
      comments = DECODE(p_error_notes,NULL,comments,substrb('<'||l_error_notes||'>'||comments,1,240))
  WHERE cash_receipt_id = p_cc_trx_id;

  IF p_payment_trxn_extension_id IS NOT NULL THEN

     SELECT
  	P.PARTY_ID,
  	P.CUST_ACCOUNT_ID,
  	P.ACCT_SITE_USE_ID,
  	P.ORG_ID,
  	P.ORG_TYPE,
  	U.PAYMENT_FUNCTION,
  	B.INSTR_ASSIGNMENT_ID,
  	B.PAYMENT_CHANNEL_CODE,
        CR.RECEIPT_NUMBER
     INTO
  	l_party_id,
  	l_cust_account_id,
  	l_cust_site_use_id,
  	l_org_id,
  	l_org_type,
  	l_payment_function,
  	l_instrument_assignment_id,
  	l_payment_channel,
        l_receipt_number
     FROM
        IBY_FNDCPT_TX_EXTENSIONS B,
        IBY_EXTERNAL_PAYERS_ALL P,
        IBY_PMT_INSTR_USES_ALL U,
        AR_CASH_RECEIPTS CR
     WHERE B.TRXN_EXTENSION_ID   = p_payment_trxn_extension_id
     AND   B.INSTR_ASSIGNMENT_ID = U.INSTRUMENT_PAYMENT_USE_ID
     AND   U.EXT_PMT_PARTY_ID    = P.EXT_PAYER_ID
     AND   CR.CASH_RECEIPT_ID    = p_cc_trx_id
     AND   B.TRXN_EXTENSION_ID   = CR.PAYMENT_TRXN_EXTENSION_ID;

     /* Set Payer Details in Payer Rec. */
     l_payer_rec.payment_function     := l_payment_function;
     l_payer_rec.party_id             := l_party_id;
     l_payer_rec.cust_account_id      := l_cust_account_id;
     l_payer_rec.account_site_id      := l_cust_site_use_id;
     l_payer_rec.org_id               := l_org_id;
     l_payer_rec.org_type             := l_org_type;

     /* Set Transction Attributes in Transaction Atrribs Rec. */
     l_trxn_attribs_rec.originating_application_id  := arp_standard.application_id;
     l_trxn_attribs_rec.order_id                    := l_receipt_number;
     l_trxn_attribs_rec.trxn_ref_number1            := 'RECEIPT';
     l_trxn_attribs_rec.trxn_ref_number2            := p_cc_trx_id;

     IBY_FNDCPT_TRXN_PUB.CREATE_TRANSACTION_EXTENSION(
        p_api_version		=> 1.0,
        p_init_msg_list		=> FND_API.G_TRUE,
        p_commit		=> FND_API.G_FALSE,
        x_return_status		=> l_return_status,
        x_msg_count		=> l_msg_count,
        x_msg_data		=> l_msg_data,
        p_payer			=> l_payer_rec,
        p_payer_equivalency	=> IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
        p_pmt_channel		=> l_payment_channel,
        p_instr_assignment	=> l_instrument_assignment_id,
        p_trxn_attribs		=> l_trxn_attribs_rec,
        x_entity_id		=> l_payment_trxn_extension_id,
        x_response		=> l_response_rec);

     IF l_return_status = FND_API.G_RET_STS_SUCCESS  THEN

        update ar_cash_receipts set
           payment_trxn_extension_id = l_payment_trxn_extension_id
        where cash_receipt_id = p_cc_trx_id;

     ELSE
        arp_standard.debug('Processing cash_receipt_id :- ' || p_cc_trx_id);
        arp_standard.debug('result_code                :- ' || l_response_rec.result_code);
        arp_standard.debug('result_category            :- ' || l_response_rec.result_category);
        arp_standard.debug('result_message             :- ' || l_response_rec.result_message);
        arp_standard.debug('l_return_status            :- ' || l_return_status);
        arp_standard.debug('l_msg_count                :- ' || l_msg_count);
        arp_standard.debug('l_msg_data                 :- ' || l_msg_data);
     END IF;
  END IF;

 END IF;
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug('ARP_CORRECT_CC_ERRORS.authorize()-');
 END IF;
EXCEPTION
 WHEN OTHERS THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('Exception in ARP_CORRECT_CC_ERRORS.reauthorize()');
  END IF;
  raise;
END reauthorize;

/*===========================================================================+
 | PROCEDURE
 |    obtain_alternate_payment
 |
 | DESCRIPTION
 |    Perform the cc correction actions for clear payment info and reverse receipt
 |
 |
 | SCOPE - PUBLIC
 |
 |
 | ARGUMENTS  : IN:
 |                 p_cc_trx_id  - Cash_receipt_id/Customer_trx_id
 |                 p_cc_trx_category - RECEIPT/INVOICE/REFUND
 |                 p_error_notes - Error notes to be attached
 |              OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by Srinivasa Kini - 25-Aug-2004
 +===========================================================================*/
PROCEDURE obtain_alternate_payment(p_cc_trx_id IN NUMBER,
                                  p_cc_trx_category IN VARCHAR2,
			          p_error_notes    IN VARCHAR2) IS
CURSOR inv IS
    SELECT trx.customer_trx_id,
           trx.trx_number,
	   trx_types.type,
	   cr.receipt_number
    FROM ra_customer_trx trx,
        ar_receivable_applications ra,
        ar_cash_receipts cr,
	ra_cust_trx_types trx_types
    WHERE trx.customer_trx_id = ra.applied_customer_trx_id
    AND ra.cash_receipt_id = cr.cash_receipt_id
    AND cr.payment_trxn_extension_id = trx.payment_trxn_extension_id
    AND cr.receipt_method_id = trx.receipt_method_id
    AND ra.display = 'Y'
    AND trx_types.cust_trx_type_id = trx.cust_trx_type_id
    AND cr.cash_receipt_id = p_cc_trx_id;

l_cash_receipt_id  ar_cash_receipts.cash_receipt_id%TYPE;
l_rec_number ar_cash_receipts.receipt_number%TYPE;
l_error_notes VARCHAR2(240);
l_dummy_number NUMBER;
l_receivable_application_id ar_receivable_applications.receivable_application_id%TYPE;
l_customer_trx_id ra_customer_trx.customer_trx_id%TYPE;
l_trx_number ra_customer_trx.trx_number%TYPE;
l_object_version_number ar_cash_receipts.rec_version_number%TYPE;
l_cc_error_code ar_cash_receipts.cc_error_code%TYPE;
l_cc_error_desc ar_cash_receipts.cc_error_text%TYPE;
l_cc_trx_category_dsp VARCHAR2(240);
l_cc_trx_number ar_cash_receipts.receipt_number%TYPE;
l_cc_trx_currency ar_cash_receipts.currency_code%TYPE;
l_cc_trx_amount NUMBER;
l_cc_trx_date DATE;
l_customer_name hz_parties.party_name%TYPE;
l_customer_number hz_cust_accounts.account_number%TYPE;
l_customer_location hz_cust_site_uses.location%TYPE;
l_cc_number IBY_FNDCPT_PAYER_ASSGN_INSTR_V.CARD_NUMBER%TYPE;
l_payment_trxn_extension_id ar_cash_receipts.payment_trxn_extension_id%TYPE;
l_approval_code ra_customer_trx.approval_code%TYPE;
l_collector ar_collectors.name%TYPE;
l_payment_method_name ar_receipt_methods.name%TYPE;
PAY_exception              EXCEPTION;

BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_CORRECT_CC_ERRORS.obtain_alternate_payment()+');
 END IF;
 IF (p_error_notes IS NULL) OR (p_error_notes = ' ') THEN

  ---Bug 4192368 get notes from description field of lookup
  ---This is because CC mapping UI also selects from description
  BEGIN

    select description
    into l_error_notes
    from ar_lookups
    where lookup_type = 'AR_CC_ERROR_NOTES'
    and lookup_code = 'E1';

  EXCEPTION
  WHEN no_data_found then
  null;
  END;

 ELSE
  l_error_notes := p_error_notes;
 END IF;

IF p_cc_trx_category IN ('CASH','MISC')  THEN
  /*--------------------------------------------------------------+
   |This is the case of reverse receipt action                    |
   |1)Clear the credit card information and payment method        |
   |  from the invoice. This should be only done if the invoice   |
   |  has already not been unapplied for all the cash receipts,   |
   |  and attach an error note to the invoice.                    |
   |2)Reverse the receipt                                         |
   |3)Attach an comment to the receipt                            |
   |4)Raise business event for this                               |
   +--------------------------------------------------------------*/
   arp_util.debug('p_cc_trx_category '|| p_cc_trx_category);
   /* Loop through invoices */
   FOR inv_cur IN inv LOOP
    -- Lock the invoice that needs to be cleared
    -- Locking should be nowait when the package is being called
    -- other than conc program
    IF ARP_GLOBAL.request_id IS NOT NULL then
     BEGIN
      SELECT 1
      INTO l_dummy_number
      FROM ra_customer_trx
      WHERE customer_trx_id = inv_cur.customer_trx_id
      FOR UPDATE OF customer_trx_id;
     EXCEPTION
      WHEN OTHERS THEN
       raise;
     END;
    ELSE
      lock_table_nowait(p_key=>inv_cur.customer_trx_id,
                       p_table_name=>'RA_CUSTOMER_TRX',
		       p_trx_number=>inv_cur.trx_number);
    END IF;
    -- Clear the credit card information and payment method from invoice
    clear_invoice_pay_info(p_customer_trx_id=>inv_cur.customer_trx_id,
                           p_cc_trx_category =>inv_cur.type,
                           p_source_receipt_id => p_cc_trx_id,
			   p_source_receipt_number => inv_cur.receipt_number,
			   p_error_notes=>l_error_notes);
   END LOOP;
  /*Collect the info to pass to events */
  Select NVL(cr.cc_error_code,'Unknown'),
       NVL(cr.cc_error_text,'Unknown Error'),
       ARPT_SQL_FUNC_UTIL.get_lookup_meaning('CC_TRX_CATEGORY',cr.type),
       cr.receipt_number,
       cr.currency_code,
       cr.amount,
       cr.receipt_date,
       party.party_name,
       cust.account_number,
       site_uses.location,
       decode(iby.INSTRUMENT_TYPE,'CREDITCARD',iby.CARD_NUMBER,iby.ACCOUNT_NUMBER),
       cr.payment_trxn_extension_id,
       cr.approval_code approval_code,
       ARP_CORRECT_CC_ERRORS.get_collector_name(cr.pay_from_customer,cr.customer_site_use_id),
       rm.name
   INTO l_cc_error_code,
      l_cc_error_desc,
      l_cc_trx_category_dsp,
      l_cc_trx_number,
      l_cc_trx_currency,
      l_cc_trx_amount,
      l_cc_trx_date,
      l_customer_name,
      l_customer_number,
      l_customer_location,
      l_cc_number,
      l_payment_trxn_extension_id,
      l_approval_code,
      l_collector,
      l_payment_method_name
   FROM ar_cash_receipts cr,
     ar_receipt_methods rm,
     hz_parties party,
     hz_cust_accounts cust,
     hz_cust_site_uses site_uses,
     iby_trxn_extensions_v iby
   WHERE rm.receipt_method_id = cr.receipt_method_id
    AND cr.pay_from_customer = cust.cust_account_id (+)
    AND cust.party_id = party.party_id (+)
    AND cr.customer_site_use_id = site_uses.site_use_id (+)
    AND cr.cc_error_flag = 'Y'
    AND cr.selected_remittance_batch_id IS NULL
    AND iby.trxn_extension_id = cr.payment_trxn_extension_id
    AND cr.cash_receipt_id = p_cc_trx_id;
   -- reverse the receipt
   reverse_receipt(p_cc_trx_id,l_error_notes);
   -- Attach comment to the invoice
   UPDATE ar_cash_receipts
   SET comments = DECODE(p_error_notes,NULL,comments,substrb('<'||l_error_notes||'>'||comments,1,2000))
   WHERE cash_receipt_id = p_cc_trx_id;

   IF p_cc_trx_category = 'CASH' THEN
    Raise_Collection_Event(p_cc_trx_id => p_cc_trx_id,
                             p_cc_error_code=> l_cc_error_code,
			     p_cc_error_desc => l_cc_error_desc,
			     p_cc_trx_category_dsp=>l_cc_trx_category_dsp,
			     p_cc_trx_number=>l_cc_trx_number,
			     p_cc_trx_currency=>l_cc_trx_currency,
			     p_cc_trx_amount=>l_cc_trx_amount,
			     p_cc_trx_date=>l_cc_trx_date,
			     p_customer_name=>l_customer_name,
			     p_customer_number=>l_customer_number,
			     p_customer_location=>l_customer_location,
			     p_cc_number=>l_cc_number,
			     p_payment_trxn_extension_id=>l_payment_trxn_extension_id,
			     p_approval_code=>l_approval_code,
			     p_collector=>l_collector,
			     p_payment_method_name=>l_payment_method_name,
			     p_error_notes=>l_error_notes);
   ELSE
    /*Get the source cash receipt */
    SELECT cr.cash_receipt_id,
	   cr.receipt_number
    INTO l_cash_receipt_id,
	 l_rec_number
    FROM ar_cash_receipts cr
    WHERE cash_receipt_id in (SELECT ra.cash_receipt_id
                              FROM ar_receivable_applications ra
                              WHERE ra.application_ref_id = p_cc_trx_id
                              AND ra.applied_payment_schedule_id = -6);

    Raise_RefundReverse_Event(p_misc_cash_receipt_id => p_cc_trx_id,
                            p_cc_error_code=> l_cc_error_code,
			     p_cc_error_desc => l_cc_error_desc,
			     p_cc_trx_number=>l_cc_trx_number,
			     p_cc_trx_currency=>l_cc_trx_currency,
			     p_cc_trx_amount=>l_cc_trx_amount,
			     p_cc_trx_date=>l_cc_trx_date,
			     p_customer_name=>l_customer_name,
			     p_customer_number=>l_customer_number,
			     p_customer_location=>l_customer_location,
			     p_cc_number=>l_cc_number,
			     p_payment_trxn_extension_id=>l_payment_trxn_extension_id,
			     p_approval_code=>l_approval_code,
			     p_collector=>l_collector,
			     p_payment_method_name=>l_payment_method_name,
			     p_source_receipt_id=>l_cash_receipt_id,
			     p_source_receipt_num=>l_rec_number,
			     p_error_notes=>l_error_notes);
   END IF;
 ELSE
  /*------------------------------------------------------------+
   |1)Clear the credit card information and payment method      |
   |  from invoice  and Raise business event for this           |
   |2)Attach an error note to the invoice                       |
   +------------------------------------------------------------*/
   --  send an error message
   arp_util.debug('p_cc_trx_category '|| p_cc_trx_category);

    -- Clear the credit card information and payment method from invoice
    clear_invoice_pay_info(p_customer_trx_id	=> p_cc_trx_id,
                           p_cc_trx_category	=> p_cc_trx_category,
			   p_error_notes	=> p_error_notes);

 END IF;
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug('ARP_CORRECT_CC_ERRORS.obtain_alternate_payment()-');
 END IF;
EXCEPTION
 WHEN OTHERS THEN
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug('Exception in ARP_CORRECT_CC_ERRORS.obtain_alternate_payment()');
 END IF;
 raise;
END obtain_alternate_payment;

/*===========================================================================+
 | PROCEDURE
 |    cc_auto_correct
 |
 | DESCRIPTION
 |    Spawns concurrent program for Credit Card Correction
 |
 | SCOPE - PUBLIC
 |
 |
 | ARGUMENTS  : IN:
 |                 errbuf - Error buf for concurrent program
 |                 retcode - Error code for concurrent program
 |                 p_request_id         - autoreceipt/autoremittance request id
 |                 p_mode - Creation/Remittance
 |              OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by Srinivasa Kini - 25-Aug-2004
 |
 +===========================================================================*/
PROCEDURE cc_auto_correct(
       errbuf                   IN OUT NOCOPY VARCHAR2,
       retcode                  IN OUT NOCOPY VARCHAR2,
       p_request_id             IN NUMBER,
       p_mode                   IN VARCHAR2) IS
CURSOR lock_cr IS
 SELECT 'lock'
 FROM ar_cash_receipts
 WHERE request_id IN ( select request_id
                       from fnd_concurrent_requests
                       where request_id  = p_request_id
                       or    parent_request_id = p_request_id )
 AND cc_error_flag = 'Y'
 AND cc_error_code IS NOT NULL
 FOR UPDATE OF cash_receipt_id;
CURSOR lock_trx IS
 SELECT 'lock'
 FROM ra_customer_trx
 WHERE request_id IN ( select request_id
                       from fnd_concurrent_requests
                       where request_id  = p_request_id
                       or    parent_request_id = p_request_id )
 AND cc_error_flag = 'Y'
 AND cc_error_code IS NOT NULL
 FOR UPDATE OF customer_trx_id;
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug('Begin : ' ||to_char(sysdate,'DD-MON-YYYY hh24:mi:ss'));
  arp_util.debug('arp_correct_cc_errors.cc_auto_correct()+');
  arp_util.debug('--------------- Input parameters --------------------');
  arp_util.debug('p_request_id :'||to_char(p_request_id));
  arp_util.debug('Called from : '||p_mode);
 END IF;
 IF (p_mode = 'REMITTANCE') THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('Locking ar_cash_receipts records for processing..');
  END IF;
  OPEN lock_cr;
  CLOSE lock_cr;
  correct_remittance_errors(p_request_id);
 ELSE
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('Locking ra_customer_trx records for processing..');
  END IF;
  OPEN lock_trx;
  CLOSE lock_trx;
  correct_creation_errors(p_request_id);
 END IF;
 retcode := 0;
 errbuf := 'Sucess!';
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug('arp_correct_cc_errors.cc_auto_correct()-');
  arp_util.debug('End : ' ||to_char(sysdate,'DD-MON-YYYY hh24:mi:ss'));
 END IF;
EXCEPTION
 WHEN OTHERS THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('Exception in arp_correct_cc_errors.cc_auto_correct');
  END IF;
  IF lock_trx%ISOPEN THEN
    CLOSE lock_trx;
  END IF;
  errbuf  := fnd_message.get||' X  '||SQLERRM;
  retcode   := 2;
END cc_auto_correct;


/*===========================================================================+
 | PROCEDURE
 |    correct_funds_error
 |
 | DESCRIPTION
 |  Correct the errors. from funds transfer.
 |
 | SCOPE - PUBLIC
 |
 |
 | ARGUMENTS  : IN:
 |                 p_cc_trx_id  - Cash_receipt_id/Customer_trx_id
 |                 p_cc_trx_category - RECEIPT/INVOICE/REFUND
 |                 p_corrective_action -- WHAT is the action.
 |                 p_instrument_number -- the instrument_id
 |                 p_expiration_date   -- expiry date.
 |                 p_error_notes - Error notes to be attached
 |              OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by bichatte - 03-OCT-2005
 |
 +===========================================================================*/
PROCEDURE correct_funds_error(p_cc_trx_id IN NUMBER,
                p_cc_trx_category IN VARCHAR2,
                p_corrective_action In VARCHAR2,
                p_instrument_number IN VARCHAR2,
                p_expiration_date   IN VARCHAR2,
                p_error_notes IN VARCHAR2) IS
l_error_notes VARCHAR2(240);
BEGIN
         IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('ARP_CORRECT_CC_ERRORS.correct_funds_error()+');

          arp_util.debug('value of p_cc_trx_id        '||'<'||p_cc_trx_id||'>');
          arp_util.debug('value of p_cc_trx_category  '||'<'||p_cc_trx_category||'>');
          arp_util.debug('value of p_corrective_action'||'<'||p_corrective_action||'>');
          arp_util.debug('value of p_instrument_number'||'<'||p_instrument_number||'>');
          arp_util.debug('value of p_expiration_date  '||'<'||p_expiration_date||'>');
          arp_util.debug('value of p_error_notes      '||'<'||p_error_notes||'>');
          END IF;
         IF (p_error_notes IS NULL) OR(p_error_notes = ' ') THEN
            l_error_notes := NULL;
         ELSE
            l_error_notes := p_error_notes;
         END IF;

 IF p_corrective_action = 'Retry' THEN

    IF p_cc_trx_category IN ('CASH','MISC') THEN
  	 UPDATE ar_cash_receipts
  	SET cc_error_flag = NULL,
      		cc_error_code = NULL,
      		cc_error_text = NULL,
       	comments = DECODE(p_error_notes,NULL,comments,substrb('<'||l_error_notes||'>'||comments,1,2000)),
      	rec_version_number = rec_version_number+1
  	WHERE cash_receipt_id = p_cc_trx_id;
    ELSE
         UPDATE ra_customer_trx
         SET cc_error_flag =NULL,
             cc_error_code = NULL,
             cc_error_text = NULL
         WHERE customer_trx_id = p_cc_trx_id;

    END IF;

 END IF; /* end Retry */

 IF p_corrective_action = 'Change Instrument' THEN
    IF p_cc_trx_category IN ('CASH','MISC') THEN
         UPDATE ar_cash_receipts
        SET cc_error_flag = NULL,
                cc_error_code = NULL,
                cc_error_text = NULL,
        comments = DECODE(p_error_notes,NULL,comments,substrb('<'||l_error_notes||'>'||comments,1,2000)),
        rec_version_number = rec_version_number+1
        WHERE cash_receipt_id = p_cc_trx_id;
    ELSE
         UPDATE ra_customer_trx
         SET cc_error_flag =NULL,
             cc_error_code = NULL,
             cc_error_text = NULL
         WHERE customer_trx_id = p_cc_trx_id;

    END IF;


 END IF; /* end change instrument */

 IF p_corrective_action = 'Reverse Receipt' THEN

       /* i) reverse the rec
         ii) update receipt_method and payment info of Corresponding inv to null */
         obtain_alternate_payment(p_cc_trx_id           =>   p_cc_trx_id,
                                  p_cc_trx_category    =>  p_cc_trx_category,
                                  p_error_notes         =>   l_error_notes);
 END IF; /* end reverse receipt */

 IF p_corrective_action = 'Clear Payment Information' THEN
    IF p_cc_trx_category IN ('CASH','MISC') THEN
       /* i) update receipt_method and payment info of  RECEIPT to null */
             UPDATE ar_cash_receipts_all
             SET payment_trxn_extension_id = NULL,
                receipt_method_id = NULL,
                cc_error_flag = NULL,
                last_update_date = sysdate,
                last_updated_by = pg_user_id,
                last_update_login = NVL(pg_login_id,pg_conc_login_id)
             WHERE cash_receipt_id = p_cc_trx_id;


    ELSE
       /* i) update receipt_method and payment info of inv to null */
             UPDATE ra_customer_trx_all
             SET payment_trxn_extension_id = NULL,
                receipt_method_id = NULL,
                cc_error_flag = NULL,
                last_update_date = sysdate,
                last_updated_by = pg_user_id,
                last_update_login = NVL(pg_login_id,pg_conc_login_id)
             WHERE customer_trx_id = p_cc_trx_id;


    END IF;

 END IF; /* end Clear Payment Information */


 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug('ARP_CORRECT_CC_ERRORS.correct_funds_error()-');
 END IF;
EXCEPTION
 WHEN OTHERS THEN
  arp_util.debug('Exception in ARP_CORRECT_CC_ERRORS.correct_funds_error()'|| SQLERRM );
  raise;
END correct_funds_error;






 /*===========================================================================+
 | PROCEDURE
 |    cc_auto_correct_cover
 |
 | DESCRIPTION
 |    Calls cc_auto_correct based on if any CC Error has occured
 |
 | SCOPE - PUBLIC
 |
 |
 | ARGUMENTS  : IN:
 |                 p_request_id  - autoreceipt/autoremittance request id
 |                 p_mode - Creation/Remittance
 |              OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by Srinivasa Kini - 25-Aug-2004
 |
 +===========================================================================*/
PROCEDURE cc_auto_correct_cover(p_request_id  IN NUMBER,
                                p_mode        IN VARCHAR2) IS
l_request_id NUMBER;
l_org_id     NUMBER;

BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug('ARP_CORRECT_CC_ERRORS.cc_auto_correct_cover()+');
  arp_util.debug('Calling Program request id passed : ' || p_request_id);
 END IF;
 IF cc_error_occurred(p_mode,p_request_id) = 'Y' THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('cc error has occurred while automatic receipt processing..');
   arp_util.debug('So calling the concurrent program to correct any automatically correctable issues');
  END IF;

  l_org_id := mo_global.get_current_org_id;

  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('Setting the org_id context to child request '|| l_org_id);
  END IF;

  fnd_request.set_org_id(l_org_id);

  l_request_id := fnd_request.submit_request(
                                      application=>'AR',
				      program=>'ARCCAUTOCON',
				      argument1=>p_request_id,
                                      argument2=>p_mode);
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('Submitted request no : ' || l_request_id);
  END IF;
  commit;
 ELSE
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('No cc error has occurred while automatic receipt processing..');
  END IF;
 END IF;
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug('ARP_CORRECT_CC_ERRORS.cc_auto_correct_cover()-');
 END IF;
END cc_auto_correct_cover;
  /*---------------------------------------------+
   |   Package initialization section.           |
   |   Sets WHO column variables for later use.  |
   +---------------------------------------------*/
BEGIN
  pg_user_id          := fnd_global.user_id;
  pg_conc_login_id    := fnd_global.conc_login_id;
  pg_login_id         := fnd_global.login_id;
  /*Get the user_name */
  SELECT user_name
  INTO pg_user_name
  FROM fnd_user
  WHERE user_id = pg_user_id;
END ARP_CORRECT_CC_ERRORS;

/
