--------------------------------------------------------
--  DDL for Package Body OE_PAYMENT_DATA_MIGRATION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PAYMENT_DATA_MIGRATION_UTIL" AS
-- $Header: OEXUPDMB.pls 120.15.12010000.3 2009/08/14 06:05:36 msundara ship $
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    OEXUPDMB.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Package Spec of OE_Payment_Data_Migration_Util                     |
--|	 This package body contains some utility procedures for handling  |
--|	 payment data migration of an closed order to oracle payment.     |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|    Migrate_Data_MGR                                                   |
--|    Migrate_Data_WKR                                                   |
--|    Purge_Data_MGR                                                     |
--|    Purge_Data_WKR                                                     |
--|                                                                       |
--| HISTORY                                                               |
--|    JUN-25-2005 Initial creation                                       |
--+=======================================================================+

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'OE_Payment_Data_Migration_Util';

/*--6757060
Function Strip_Non_Numeric_Char(
   p_credit_card_num IN  iby_ext_bank_accounts_v.bank_account_number%TYPE
   )
RETURN VARCHAR2
IS
 p_stripped_cc_num iby_ext_bank_accounts_v.bank_account_number%TYPE;
BEGIN

   IF p_credit_card_num IS NOT NULL THEN
      ARP_EXT_BANK_PKG.strip_white_spaces(p_credit_card_num,p_stripped_cc_num);
      RETURN p_stripped_cc_num;
   ELSE
      RETURN NULL;
   END IF;

EXCEPTION
       when OTHERS then
             raise;
END Strip_Non_Numeric_Char;
--6757060 */

--6757060  -- modified for the bug 8731962
Function Strip_Non_Numeric_Char(
   p_credit_card_num IN  iby_ext_bank_accounts_v.bank_account_number%TYPE
   )
RETURN VARCHAR2
IS
 TYPE character_tab_typ IS TABLE of char(1) INDEX BY BINARY_INTEGER;
 len_credit_card_num   number := 0;
 l_cc_num_char         character_tab_typ;
 p_stripped_cc_num iby_ext_bank_accounts_v.bank_account_number%TYPE;
BEGIN

  IF p_credit_card_num IS NOT NULL THEN

   SELECT lengthb(p_credit_card_num)
   INTO   len_credit_card_num
   FROM   dual;

   FOR i in 1..len_credit_card_num LOOP
     SELECT substrb(p_credit_card_num,i,1)
     INTO   l_cc_num_char(i)
     FROM   dual;

    IF ( (l_cc_num_char(i) >= '0') and (l_cc_num_char(i) <= '9')) THEN
       -- Numeric digit. Add to stripped_number and table.
       p_stripped_cc_num := p_stripped_cc_num || l_cc_num_char(i);
    END IF;
   END LOOP;
    RETURN p_stripped_cc_num;
  ELSE
      RETURN NULL;
  END IF;

EXCEPTION
       when OTHERS then
             raise;
END Strip_Non_Numeric_Char;
--6757060  -- modified for the bug 8731962

PROCEDURE Migrate_Data_MGR
(   X_errbuf       OUT NOCOPY VARCHAR2,
    X_retcode      OUT NOCOPY VARCHAR2,
    X_batch_size    IN NUMBER,
    X_Num_Workers   IN NUMBER
)
IS
  l_product                   VARCHAR2(30) := 'ONT' ;
BEGIN
  AD_CONC_UTILS_PKG.submit_subrequests(
               X_errbuf                   => X_errbuf,
               X_retcode                  => X_retcode,
               X_WorkerConc_app_shortname => l_product,
               X_workerConc_progname      => 'ONTIBYFC_WKR',
               X_batch_size               => X_batch_size,
               X_Num_Workers              => X_Num_Workers) ;
END Migrate_Data_MGR ;

PROCEDURE Migrate_Data_WKR
(   X_errbuf     OUT NOCOPY VARCHAR2,
    X_retcode    OUT NOCOPY VARCHAR2,
    X_batch_size  IN NUMBER,
    X_Worker_Id   IN NUMBER,
    X_Num_Workers IN NUMBER
)
IS
  TYPE HEADER_ID                  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER ;
  TYPE LINE_ID                    IS TABLE OF NUMBER INDEX BY BINARY_INTEGER ;
  TYPE PAYMENT_NUMBER             IS TABLE OF NUMBER INDEX BY BINARY_INTEGER ;
  TYPE TANGIBLEID                 IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER ;
  TYPE INSTR_ASSIGNMENT_ID        IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER ;
  TYPE EXT_PARTY_ID               IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER ;
  TYPE TRXN_ENTITY_ID             IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER ;

  header_id_tab                   header_id ;
  line_id_tab                     line_id ;
  payment_number_tab              payment_number ;
  tangibleid_tab                  tangibleid ;
  instr_assignment_id_tab         instr_assignment_id ;
  ext_party_id_tab                ext_party_id ;
  trxn_entity_id_tab              trxn_entity_id ;

  l_table_owner                   VARCHAR2(30) ;
  l_batch_size                    VARCHAR2(30) ;
  l_worker_id                     NUMBER ;
  l_num_workers                   NUMBER ;
  l_any_rows_to_process           BOOLEAN ;

  l_table_name                    VARCHAR2(30) ;
  l_product                       VARCHAR2(30) := 'ONT' ;
  l_script_name                   VARCHAR2(30) := 'OEXUPDMB.pls' ;

  l_start_rowid                   ROWID ;
  l_end_rowid                     ROWID ;
  l_cutoff_date                   DATE;
  l_rows_processed                NUMBER ;
  l_user_id                       NUMBER := NVL(fnd_global.user_id, -1) ;

  l_status                        VARCHAR2(30) ;
  l_industry                      VARCHAR2(30) ;
  l_retstatus                     BOOLEAN ;

  l_return_status                 VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS ;
  l_msg_count                     NUMBER       := 0 ;
  l_msg_data                      VARCHAR2(2000) ;

  l_process_total1                NUMBER := 0 ;
  l_process_total2                NUMBER := 0 ;

  l_error_total                   NUMBER := 0 ;

  l_debug_level                   CONSTANT NUMBER := oe_debug_pub.g_debug_level ;

-- Cursors that query all transactions needed to be migrated
-- since all credit cards for closed orders would have already created bank account id
-- in ap_bank_accounts, so we can get the bank_account_id first, then get the instrument
-- assignment id from IBY_UPG_INSTRUMENTS. With the instrument assignemen id, we can directly
-- create and insert a new record in Oracle Payments table IBY_FNDCPT_TX_EXTENSIONS.

-- Define a cursor payments_cur1 to select the payment data that only exist in oe_order_headers_all
-- but not in oe_payments for closed orders

CURSOR payments_cur1 (p_start_rowid ROWID, p_end_rowid ROWID, l_cutoff_date DATE) is
 SELECT /*+ LEADING (OOH) */ ooh.header_id,
        null	         line_id, 	    -- line_id
        OE_Default_Header_Payment.get_payment_number(ooh.header_id),
        ita.tangibleid,
        uba.instr_assignment_id,
        uba.ext_party_id,
        iby_fndcpt_tx_extensions_s.nextval  -- the new transaction extension ID
   FROM oe_order_headers_all       ooh,
        hz_cust_site_uses_all      su,
        hz_cust_acct_sites_all     cas,
        ap_bank_accounts_all       ba,
        ap_bank_account_uses_all   bau,
        iby_trans_all_v            ita,
        iby_upg_instruments        uba
  WHERE ooh.open_flag            = 'N'
    AND ooh.payment_type_code    = 'CREDIT_CARD'
    AND ooh.ordered_date        >= l_cutoff_date
    AND NOT EXISTS ( SELECT 'Y'
                       FROM oe_payments op
                      WHERE op.header_id = ooh.header_id )
    AND	ita.authcode(+)          = ooh.credit_card_approval_code
    AND	ita.updatedate(+)        = ooh.credit_card_approval_date
    AND	ita.reqtype(+)           = 'ORAPMTREQ'
    AND	ita.status(+)            = 0
    AND ita.refinfo(+)           = to_char(ooh.header_id)  --6713227
    AND su.site_use_id           = ooh.invoice_to_org_id
    AND	su.site_use_code         = 'BILL_TO'
    AND su.cust_acct_site_id     = cas.cust_acct_site_id
    AND su.org_id                = cas.org_id
    AND	uba.cust_account_id      = cas.cust_account_id
    AND	uba.acct_site_use_id     = su.site_use_id
    AND uba.payment_function     = 'CUSTOMER_PAYMENT'
    AND uba.instrument_type      = 'CREDITCARD'
    AND	ba.bank_account_id       = uba.bank_account_id
    AND	ba.bank_account_num      = OE_Payment_Data_Migration_Util.Strip_Non_Numeric_Char(ooh.credit_card_number) --6757060
    AND ba.bank_branch_id        = 1
    AND ba.account_type          = 'EXTERNAL'
    AND ba.bank_account_id       = bau.external_bank_account_id
    AND bau.customer_site_use_id = ooh.invoice_to_org_id
    AND ooh.rowid BETWEEN p_start_rowid AND p_end_rowid ;

CURSOR payments_cur1_sec (p_start_rowid ROWID, p_end_rowid ROWID, l_cutoff_date DATE) is
 SELECT /*+ LEADING (OOH) */ ooh.header_id,
        null	         line_id, 	    -- line_id
        OE_Default_Header_Payment.get_payment_number(ooh.header_id),
        ita.tangibleid,
        uba.instr_assignment_id,
        uba.ext_party_id,
        iby_fndcpt_tx_extensions_s.nextval  -- the new transaction extension ID
   FROM oe_order_headers_all       ooh,
        hz_cust_site_uses_all      su,
        hz_cust_acct_sites_all     cas,
        iby_trans_all_v            ita,
        iby_upg_instruments        uba,
        iby_security_segments      seg,
        iby_creditcard             cc
  WHERE ooh.open_flag            = 'N'
    AND ooh.payment_type_code    = 'CREDIT_CARD'
    AND ooh.ordered_date        >= l_cutoff_date
    AND NOT EXISTS ( SELECT 'Y'
                       FROM oe_payments op
                      WHERE op.header_id = ooh.header_id )
    AND	ita.authcode(+)          = ooh.credit_card_approval_code
    AND	ita.updatedate(+)        = ooh.credit_card_approval_date
    AND	ita.reqtype(+)           = 'ORAPMTREQ'
    AND	ita.status(+)            = 0
    AND ita.refinfo(+)           = to_char(ooh.header_id)  --6713227
    AND su.site_use_id           = ooh.invoice_to_org_id
    AND	su.site_use_code         = 'BILL_TO'
    AND su.cust_acct_site_id     = cas.cust_acct_site_id
    AND su.org_id                = cas.org_id
    AND	uba.cust_account_id      = cas.cust_account_id
    AND	uba.acct_site_use_id     = su.site_use_id
    AND uba.payment_function     = 'CUSTOMER_PAYMENT'
    AND uba.instrument_type      = 'CREDITCARD'
    AND IBY_CC_SECURITY_PUB.get_segment_id(OE_Payment_Data_Migration_Util.Strip_Non_Numeric_Char(ooh.credit_card_number))
                                                                                               = seg.sec_segment_id  --6757060
    AND (seg.cc_number_hash1     = cc.cc_number_hash1
    AND  seg.cc_number_hash2     = cc.cc_number_hash2)
    AND cc.instrid               = uba.instrument_id
    AND ooh.rowid BETWEEN p_start_rowid AND p_end_rowid ;

-- Define another cursor payments_cur2 to select payment data that only exist in oe_payments
-- but not in oe_order_headers_all

CURSOR payments_cur2 (p_start_rowid ROWID, p_end_rowid ROWID, l_cutoff_date DATE) is
 SELECT /*+ LEADING (OP) */ op.header_id,
        op.line_id,
        op.payment_number,
        ita.tangibleid,
        uba.instr_assignment_id,
        uba.ext_party_id,
        iby_fndcpt_tx_extensions_s.nextval  -- the new transaction extension ID
   FROM oe_order_headers_all       ooh,
        hz_cust_site_uses_all      su,
        hz_cust_acct_sites_all     cas,
        ap_bank_accounts_all       ba,
        ap_bank_account_uses_all   bau,
        iby_trans_all_v            ita,
        iby_upg_instruments        uba,
        oe_payments                op
  WHERE ooh.open_flag            = 'N'
    AND ooh.ordered_date        >= l_cutoff_date
    AND ooh.header_id            = op.header_id
    AND op.trxn_extension_id is null
    AND	ita.authcode(+)          = op.credit_card_approval_code
    AND	ita.updatedate(+)        = op.credit_card_approval_date
    AND	ita.reqtype(+)           = 'ORAPMTREQ'
    AND	ita.status(+)            = 0
    AND ita.refinfo(+)           = to_char(op.header_id)  --6713227
    AND su.site_use_id           = ooh.invoice_to_org_id
    AND	su.site_use_code         = 'BILL_TO'
    AND su.cust_acct_site_id     = cas.cust_acct_site_id
    AND su.org_id                = cas.org_id
    AND	uba.cust_account_id      = cas.cust_account_id
    AND	uba.acct_site_use_id     = su.site_use_id
    AND uba.payment_function     = 'CUSTOMER_PAYMENT'
    AND uba.instrument_type      = 'CREDITCARD'
    AND	op.payment_type_code     = 'CREDIT_CARD'
    AND op.credit_card_number IS NOT NULL
    AND ba.bank_account_id       = uba.bank_account_id
    AND ba.bank_account_num      = OE_Payment_Data_Migration_Util.Strip_Non_Numeric_Char(op.credit_card_number) --6757060
    AND ba.bank_branch_id        = 1
    AND ba.account_type          = 'EXTERNAL'
    AND ba.bank_account_id       = bau.external_bank_account_id
    AND bau.customer_site_use_id = ooh.invoice_to_org_id
    AND op.rowid BETWEEN p_start_rowid AND p_end_rowid ;

CURSOR payments_cur2_sec (p_start_rowid ROWID, p_end_rowid ROWID, l_cutoff_date DATE) is
 SELECT /*+ LEADING (OP) */ op.header_id,
        op.line_id,
        op.payment_number,
        ita.tangibleid,
        uba.instr_assignment_id,
        uba.ext_party_id,
        iby_fndcpt_tx_extensions_s.nextval  -- the new transaction extension ID
   FROM oe_order_headers_all       ooh,
        hz_cust_site_uses_all      su,
        hz_cust_acct_sites_all     cas,
        iby_trans_all_v            ita,
        iby_upg_instruments        uba,
        oe_payments                op,
        iby_security_segments      seg,
        iby_creditcard             cc
  WHERE ooh.open_flag            = 'N'
    AND ooh.ordered_date        >= l_cutoff_date
    AND ooh.header_id            = op.header_id
    AND op.trxn_extension_id is null
    AND	ita.authcode(+)          = op.credit_card_approval_code
    AND	ita.updatedate(+)        = op.credit_card_approval_date
    AND	ita.reqtype(+)           = 'ORAPMTREQ'
    AND	ita.status(+)            = 0
    AND ita.refinfo(+)           = to_char(op.header_id)  --6713227
    AND su.site_use_id           = ooh.invoice_to_org_id
    AND	su.site_use_code         = 'BILL_TO'
    AND su.cust_acct_site_id     = cas.cust_acct_site_id
    AND su.org_id                = cas.org_id
    AND	uba.cust_account_id      = cas.cust_account_id
    AND	uba.acct_site_use_id     = su.site_use_id
    AND uba.payment_function     = 'CUSTOMER_PAYMENT'
    AND uba.instrument_type      = 'CREDITCARD'
    AND	op.payment_type_code     = 'CREDIT_CARD'
    AND op.credit_card_number IS NOT NULL
    AND IBY_CC_SECURITY_PUB.get_segment_id(OE_Payment_Data_Migration_Util.Strip_Non_Numeric_Char(op.credit_card_number))
                                                                                       = seg.sec_segment_id  --6757060
    AND (seg.cc_number_hash1     = cc.cc_number_hash1
    AND  seg.cc_number_hash2     = cc.cc_number_hash2)
    AND cc.instrid               = uba.instrument_id
    AND op.rowid BETWEEN p_start_rowid AND p_end_rowid ;

-- Define another cursor payments_cur3 to select payment data with ACH and Direct Debit payment types
-- that only exist in oe_payments but not in oe_order_headers_all, for these payment types,
-- we only need join with iby_upg_assignments directly to get the instrument assignment id and
-- then directly insert into iby_trxn_extensions table.

CURSOR payments_cur3 (p_start_rowid ROWID, p_end_rowid ROWID, l_cutoff_date DATE) is
 SELECT /*+ LEADING (OP) */ op.header_id,
        op.line_id,
        op.payment_number,
        uba.instr_assignment_id,
        uba.ext_party_id,
        iby_fndcpt_tx_extensions_s.nextval  -- the new transaction extension ID
   FROM oe_order_headers_all       ooh,
        hz_cust_site_uses_all      su,
        hz_cust_acct_sites_all     cas,
        iby_upg_instruments        uba,
        oe_payments                op
  WHERE ooh.open_flag            = 'N'
    AND ooh.ordered_date        >= l_cutoff_date
    AND ooh.header_id            = op.header_id
    AND op.trxn_extension_id is null
    AND	op.payment_type_code IN ('DIRECT_DEBIT', 'ACH')
    AND su.site_use_id           = ooh.invoice_to_org_id
    AND	su.site_use_code         = 'BILL_TO'
    AND su.cust_acct_site_id     = cas.cust_acct_site_id
    AND su.org_id                = cas.org_id
    AND uba.cust_account_id      = cas.cust_account_id
    AND uba.acct_site_use_id     = su.site_use_id
    AND uba.payment_function     = 'CUSTOMER_PAYMENT'
    AND op.payment_trx_id        = uba.bank_account_id
    AND uba.instrument_type      = 'BANKACCOUNT'
    AND op.rowid BETWEEN p_start_rowid AND p_end_rowid ;

BEGIN
  --
  -- get schema name of the table for ROWID range processing
  --
  l_retstatus := fnd_installation.get_app_info(l_product, l_status, l_industry, l_table_owner) ;

  IF ((l_retstatus = FALSE)
      OR
      (l_table_owner is null))
  THEN
     raise_application_error(-20001,
        'Cannot get schema name for product : ' || l_product) ;
  END IF ;

  -----------------------------------------------------------
  -- Log Output file
  -----------------------------------------------------------
  fnd_file.put_line(FND_FILE.OUTPUT, '');
  fnd_file.put_line(FND_FILE.OUTPUT, 'Migrate Payment Data for Closed Orders to Oracle Payment - Concurrent Program');
  fnd_file.put_line(FND_FILE.OUTPUT, '');
  fnd_file.put_line(FND_FILE.OUTPUT, 'Concurrent Program Parameters');
  fnd_file.put_line(FND_FILE.OUTPUT, 'Batch Size        : '|| X_batch_size);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Number of Threads : '|| X_Num_Workers);

  l_cutoff_date := NVL(fnd_profile.value('IBY_CREDITCARD_CUTOFF_DATE'), to_date('01/01/1000', 'DD/MM/YYYY')) ;

  -- migrate data in oe_oe_order_headers_all and not exist in oe_payments
  BEGIN
    -----------------------------------------------------------
    -- Fetching records from OE_ORDER_HEADERS_ALL table
    -----------------------------------------------------------
    l_table_name  := 'OE_ORDER_HEADERS_ALL' ;

    ad_parallel_updates_pkg.delete_update_information(
	     0,
	     l_table_owner,
	     l_table_name,
	     l_script_name ) ;

    ad_parallel_updates_pkg.initialize_rowid_range(
             ad_parallel_updates_pkg.ROWID_RANGE,
             l_table_owner,
             l_table_name,
             l_script_name,
             X_worker_id,
             X_num_workers,
             X_batch_size, 0) ;

    ad_parallel_updates_pkg.get_rowid_range(
             l_start_rowid,
             l_end_rowid,
             l_any_rows_to_process,
             X_batch_size,
             TRUE) ;

    fnd_file.put_line(FND_FILE.OUTPUT, '');
    fnd_file.put_line(FND_FILE.OUTPUT, 'Process starting from OE_ORDER_HEADERS_ALL table');

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('') ;
       oe_debug_pub.add('AD parallel details : ') ;
       oe_debug_pub.add('') ;
       oe_debug_pub.add('Table owner  : ' || l_table_owner) ;
       oe_debug_pub.add('Table name   : ' || l_table_name) ;
       oe_debug_pub.add('Batch Size   : ' || X_batch_size) ;
       oe_debug_pub.add('Worker ID    : ' || X_worker_id) ;
       oe_debug_pub.add('No of Worker : ' || X_num_workers) ;
       oe_debug_pub.add('Cut off Date : ' || l_cutoff_date) ;
    END IF ;

    l_process_total1 := 0 ;

    l_error_total    := 0 ;

    WHILE (l_any_rows_to_process = TRUE) LOOP
      header_id_tab.delete ;
      line_id_tab.delete ;
      payment_number_tab.delete ;
      tangibleid_tab.delete ;
      instr_assignment_id_tab.delete ;
      ext_party_id_tab.delete ;
      trxn_entity_id_tab.delete ;

    BEGIN --6757060
      IF NOT iby_cc_security_pub.encryption_enabled() THEN
         OPEN payments_cur1(l_start_rowid, l_end_rowid, l_cutoff_date) ;

         FETCH payments_cur1 BULK COLLECT INTO
           header_id_tab,
           line_id_tab,
           payment_number_tab,
           tangibleid_tab,
           instr_assignment_id_tab,
           ext_party_id_tab,
           trxn_entity_id_tab; --6757060
         --6757060 Limit X_batch_size ;

         CLOSE payments_cur1 ;
      ELSE
         OPEN payments_cur1_sec(l_start_rowid, l_end_rowid, l_cutoff_date) ;

         FETCH payments_cur1_sec BULK COLLECT INTO
           header_id_tab,
           line_id_tab,
           payment_number_tab,
           tangibleid_tab,
           instr_assignment_id_tab,
           ext_party_id_tab,
           trxn_entity_id_tab;  --6757060
         --6757060 Limit X_batch_size ;

         CLOSE payments_cur1_sec ;
      END IF ;

--      oe_debug_pub.add('Number of Records selected in payments_cur1 : ' || trxn_entity_id_tab.count) ;

      IF trxn_entity_id_tab.count > 0 THEN
         -- insert the transactions into IBY transaction extension table
	 FORALL k in trxn_entity_id_tab.FIRST..trxn_entity_id_tab.LAST SAVE EXCEPTIONS
	   INSERT INTO IBY_FNDCPT_TX_EXTENSIONS
             (trxn_extension_id,
              payment_channel_code,
              instr_assignment_id,
              ext_payer_id,
              order_id,
              po_number,
              trxn_ref_number1,
              trxn_ref_number2,
              additional_info,
              tangibleid,
              origin_application_id,
              encrypted,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login,
              object_version_number)
           VALUES
             (trxn_entity_id_tab(k),
              'CREDIT_CARD',
              instr_assignment_id_tab(k),
              ext_party_id_tab(k),
              header_id_tab(k),
              NULL,
              line_id_tab(k),
              payment_number_tab(k),
              NULL,
              tangibleid_tab(k),
              660,
              'N',
              l_user_id,
              sysdate,
              l_user_id,
              sysdate,
              l_user_id,
              1) ;

        FORALL i in trxn_entity_id_tab.FIRST..trxn_entity_id_tab.LAST SAVE EXCEPTIONS
	  INSERT INTO OE_PAYMENTS
             (trxn_extension_id,
              payment_level_code,
              payment_number,
              header_id,
              line_id,
              payment_type_code,
	      payment_collection_event,  --6700026
              creation_date,
              created_by,
              last_update_date,
              last_updated_by
             )
          VALUES
             (trxn_entity_id_tab(i),
              'ORDER',
              payment_number_tab(i),
              header_id_tab(i),
              line_id_tab(i),
              'CREDIT_CARD',
              'INVOICE',   --6700026
              sysdate,
              1,
              sysdate,
              1) ;

        l_rows_processed := SQL%ROWCOUNT ;

        l_process_total1 := l_process_total1 + l_rows_processed ;
      END IF ;

--6757060
   EXCEPTION
    WHEN OTHERS THEN
        IF payments_cur1%ISOPEN THEN
           CLOSE payments_cur1 ;
        END IF;

        IF payments_cur1_sec%ISOPEN THEN
	    CLOSE payments_cur1_sec ;
        END IF;
         l_error_total  := SQL%BULK_EXCEPTIONS.COUNT ;

	       FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
	         fnd_file.put_line(FND_FILE.OUTPUT,
		        'Inner Block :Error occurred during iteration ' ||
                         SQL%BULK_EXCEPTIONS(j).ERROR_INDEX ||
                         ' Oracle error is ' ||
                         SQL%BULK_EXCEPTIONS(j).ERROR_CODE );

                   fnd_file.put_line(FND_FILE.OUTPUT, 'Inner Block :upgrading failing for data from oe_order_headers_all for Header ID ' || header_id_tab(j));
               END LOOP;
    END ;
--6757060

      ad_parallel_updates_pkg.processed_rowid_range
                             (l_rows_processed,
                              l_end_rowid) ;

      COMMIT ;

      ad_parallel_updates_pkg.get_rowid_range
                             (l_start_rowid,
                              l_end_rowid,
                              l_any_rows_to_process,
                              X_batch_size,
                              FALSE) ;
    END LOOP ;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Total No of records processed successfully          : ' || l_process_total1) ;
    END IF;

    fnd_file.put_line(FND_FILE.OUTPUT, 'Process ending from OE_ORDER_HEADERS_ALL table');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN

       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('') ;
         oe_debug_pub.add('No record found from OE_ORDER_HEADERS_ALL table for Worker Id : ' || X_worker_id) ;
       END IF;

         fnd_file.put_line(FND_FILE.OUTPUT, 'No record found from OE_ORDER_HEADERS_ALL table for Worker Id : ' || X_worker_id) ;
    WHEN OTHERS THEN
         l_error_total  := SQL%BULK_EXCEPTIONS.COUNT ;

	       FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
		   fnd_file.put_line(FND_FILE.OUTPUT,
		        'Error occurred during iteration ' ||
                         SQL%BULK_EXCEPTIONS(j).ERROR_INDEX ||
                         ' Oracle error is ' ||
                         SQL%BULK_EXCEPTIONS(j).ERROR_CODE );

                   fnd_file.put_line(FND_FILE.OUTPUT,
		        'upgrading failing for data from oe_order_headers_all for Header ID ' ||
		         header_id_tab(j));
               END LOOP;
  END ;

  IF l_debug_level > 0 THEN
    oe_debug_pub.add('Total No of records errored in oe_order_headers_all : ' || l_error_total) ;
  END IF;

  -- Migrate data in oe_payments for Credit Card payment types.
  BEGIN
    -----------------------------------------------------------
    -- Fetching records from OE_PAYMENTS table
    -----------------------------------------------------------
    l_table_name  := 'OE_PAYMENTS' ;

    ad_parallel_updates_pkg.delete_update_information(
	     0,
	     l_table_owner,
	     l_table_name,
	     l_script_name ) ;

    ad_parallel_updates_pkg.initialize_rowid_range(
             ad_parallel_updates_pkg.ROWID_RANGE,
             l_table_owner,
             l_table_name,
             l_script_name,
             X_worker_id,
             X_num_workers,
             X_batch_size, 0) ;

    ad_parallel_updates_pkg.get_rowid_range(
             l_start_rowid,
             l_end_rowid,
             l_any_rows_to_process,
             X_batch_size,
             TRUE) ;

    fnd_file.put_line(FND_FILE.OUTPUT, '');
    fnd_file.put_line(FND_FILE.OUTPUT, 'Process starting from OE_PAYMENTS table');

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('') ;
       oe_debug_pub.add('AD parallel details : ') ;
       oe_debug_pub.add('') ;
       oe_debug_pub.add('Table owner  : ' || l_table_owner) ;
       oe_debug_pub.add('Table name   : ' || l_table_name) ;
       oe_debug_pub.add('Batch Size   : ' || X_batch_size) ;
       oe_debug_pub.add('Worker ID    : ' || X_worker_id) ;
       oe_debug_pub.add('No of Worker : ' || X_num_workers) ;
       oe_debug_pub.add('Cut off Date : ' || l_cutoff_date) ;
    END IF ;

    l_process_total1 := 0 ;

    l_error_total    := 0 ;

    WHILE (l_any_rows_to_process = TRUE) LOOP
      header_id_tab.delete ;
      line_id_tab.delete ;
      payment_number_tab.delete ;
      tangibleid_tab.delete ;
      instr_assignment_id_tab.delete ;
      ext_party_id_tab.delete ;
      trxn_entity_id_tab.delete ;

      IF NOT iby_cc_security_pub.encryption_enabled() THEN
         OPEN payments_cur2(l_start_rowid, l_end_rowid, l_cutoff_date) ;

         FETCH payments_cur2 BULK COLLECT INTO
           header_id_tab,
           line_id_tab,
           payment_number_tab,
           tangibleid_tab,
           instr_assignment_id_tab,
           ext_party_id_tab,
           trxn_entity_id_tab
         Limit X_batch_size ;

         CLOSE payments_cur2 ;
      ELSE
         OPEN payments_cur2_sec(l_start_rowid, l_end_rowid, l_cutoff_date) ;

         FETCH payments_cur2_sec BULK COLLECT INTO
           header_id_tab,
           line_id_tab,
           payment_number_tab,
           tangibleid_tab,
           instr_assignment_id_tab,
           ext_party_id_tab,
           trxn_entity_id_tab
         Limit X_batch_size ;

         CLOSE payments_cur2_sec ;
      END IF ;

--      oe_debug_pub.add('Number of Records selected in payments_cur2 : ' || trxn_entity_id_tab.count) ;

      IF trxn_entity_id_tab.count > 0 THEN
         -- insert the transactions into IBY transaction extension table
         FORALL k in trxn_entity_id_tab.FIRST..trxn_entity_id_tab.LAST SAVE EXCEPTIONS
	   INSERT INTO IBY_FNDCPT_TX_EXTENSIONS
             (trxn_extension_id,
              payment_channel_code,
              instr_assignment_id,
              ext_payer_id,
              order_id,
              po_number,
              trxn_ref_number1,
              trxn_ref_number2,
              additional_info,
              tangibleid,
              origin_application_id,
              encrypted,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login,
              object_version_number)
           VALUES
             (trxn_entity_id_tab(k),
              'CREDIT_CARD',
              instr_assignment_id_tab(k),
              ext_party_id_tab(k),
              header_id_tab(k),
              NULL,
              line_id_tab(k),
              payment_number_tab(k),
              NULL,
              tangibleid_tab(k),
              660,
              'N',
              l_user_id,
              sysdate,
              l_user_id,
              sysdate,
              l_user_id,
              1) ;

         FORALL i in trxn_entity_id_tab.FIRST..trxn_entity_id_tab.LAST SAVE EXCEPTIONS
	      UPDATE OE_PAYMENTS
                 SET trxn_extension_id  = trxn_entity_id_tab(i),
		     last_update_date   = sysdate,
		     last_updated_by    = l_user_id,
		     last_update_login  = l_user_id
	       WHERE header_id          = header_id_tab(i)
		 AND NVL(line_id,-99)   = NVL(line_id_tab(i),-99)
	         AND payment_number     = payment_number_tab(i) ;

        l_rows_processed := SQL%ROWCOUNT ;

        l_process_total1 := l_process_total1 + l_rows_processed ;
      END IF ;

      ad_parallel_updates_pkg.processed_rowid_range
                             (l_rows_processed,
                              l_end_rowid) ;

      COMMIT ;

      ad_parallel_updates_pkg.get_rowid_range
                             (l_start_rowid,
                              l_end_rowid,
                              l_any_rows_to_process,
                              X_batch_size,
                              FALSE) ;
    END LOOP ;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Total No of records processed successfully          : ' || l_process_total1) ;
    END IF;

    fnd_file.put_line(FND_FILE.OUTPUT, 'Process ending from OE_PAYMENTS table');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('') ;
         oe_debug_pub.add('No record found from OE_PAYMENTS table for Worker Id : ' || X_worker_id) ;
      END IF;

         fnd_file.put_line(FND_FILE.OUTPUT, 'No record found from OE_PAYMENTS table for Worker Id : ' || X_worker_id) ;
    WHEN OTHERS THEN
        l_error_total  := SQL%BULK_EXCEPTIONS.COUNT ;

	       FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
		   fnd_file.put_line(FND_FILE.OUTPUT,
		        'Error occurred during iteration ' ||
                         SQL%BULK_EXCEPTIONS(j).ERROR_INDEX ||
                         ' Oracle error is ' ||
                         SQL%BULK_EXCEPTIONS(j).ERROR_CODE );

                   fnd_file.put_line(FND_FILE.OUTPUT,
		        'upgrade failing in oe_payments for credit card for Header ID ' ||
		         header_id_tab(j));
               END LOOP;
  END ;

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('Total No of records errored in oe_payments          : ' || l_error_total) ;
  END IF;

  -- migrate data in oe_payments for ACH and Direct Debit payment types.
  BEGIN
    -----------------------------------------------------------
    -- Fetching records from OE_PAYMENTS table
    -----------------------------------------------------------
    l_table_name  := 'OE_PAYMENTS' ;

    ad_parallel_updates_pkg.delete_update_information(
	     0,
	     l_table_owner,
	     l_table_name,
	     l_script_name ) ;

    ad_parallel_updates_pkg.initialize_rowid_range(
             ad_parallel_updates_pkg.ROWID_RANGE,
             l_table_owner,
             l_table_name,
             l_script_name,
             X_worker_id,
             X_num_workers,
             X_batch_size, 0) ;

    ad_parallel_updates_pkg.get_rowid_range(
             l_start_rowid,
             l_end_rowid,
             l_any_rows_to_process,
             X_batch_size,
             TRUE) ;

    fnd_file.put_line(FND_FILE.OUTPUT, '');
    fnd_file.put_line(FND_FILE.OUTPUT, 'Process starting from OE_PAYMENTS table');

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('') ;
       oe_debug_pub.add('AD parallel details : ') ;
       oe_debug_pub.add('') ;
       oe_debug_pub.add('Table owner  : ' || l_table_owner) ;
       oe_debug_pub.add('Table name   : ' || l_table_name) ;
       oe_debug_pub.add('Batch Size   : ' || X_batch_size) ;
       oe_debug_pub.add('Worker ID    : ' || X_worker_id) ;
       oe_debug_pub.add('No of Worker : ' || X_num_workers) ;
       oe_debug_pub.add('Cut off Date : ' || l_cutoff_date) ;
    END IF ;

    l_process_total1 := 0 ;

    l_error_total    := 0 ;

    WHILE (l_any_rows_to_process = TRUE) LOOP
      header_id_tab.delete ;
      line_id_tab.delete ;
      payment_number_tab.delete ;
      instr_assignment_id_tab.delete ;
      ext_party_id_tab.delete ;
      trxn_entity_id_tab.delete ;

      OPEN payments_cur3(l_start_rowid, l_end_rowid, l_cutoff_date) ;

      FETCH payments_cur3 BULK COLLECT INTO
        header_id_tab,
        line_id_tab,
        payment_number_tab,
        instr_assignment_id_tab,
        ext_party_id_tab,
        trxn_entity_id_tab
      Limit X_batch_size ;

      CLOSE payments_cur3 ;

--      oe_debug_pub.add('Number of Records selected in payments_cur3 is : ' || trxn_entity_id_tab.count) ;

      IF trxn_entity_id_tab.count > 0 THEN
         -- insert the transactions into IBY transaction extension table
         FORALL k in trxn_entity_id_tab.FIRST..trxn_entity_id_tab.LAST SAVE EXCEPTIONS
	   INSERT INTO IBY_FNDCPT_TX_EXTENSIONS
             (trxn_extension_id,
              payment_channel_code,
              instr_assignment_id,
              ext_payer_id,
              order_id,
              po_number,
              trxn_ref_number1,
              trxn_ref_number2,
              additional_info,
              origin_application_id,
              encrypted,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login,
              object_version_number)
           VALUES
             (trxn_entity_id_tab(k),
              'BANK_ACCT_XFER',
              instr_assignment_id_tab(k),
              ext_party_id_tab(k),
              header_id_tab(k),
              NULL,
              line_id_tab(k),
              payment_number_tab(k),
              NULL,
              660,
              'N',
              l_user_id,
              sysdate,
              l_user_id,
              sysdate,
              l_user_id,
              1) ;

         FORALL i in trxn_entity_id_tab.FIRST..trxn_entity_id_tab.LAST SAVE EXCEPTIONS
	      UPDATE OE_PAYMENTS
	         SET trxn_extension_id  = trxn_entity_id_tab(i),
		     last_update_date   = sysdate,
		     last_updated_by    = l_user_id,
		     last_update_login  = l_user_id
	       WHERE header_id          = header_id_tab(i)
		 AND NVL(line_id,-99)   = NVL(line_id_tab(i),-99)
	         AND payment_number     = payment_number_tab(i) ;

        l_rows_processed := SQL%ROWCOUNT ;

        l_process_total1 := l_process_total1 + l_rows_processed ;
      END IF ;

      ad_parallel_updates_pkg.processed_rowid_range
                             (l_rows_processed,
                              l_end_rowid) ;

      COMMIT ;

      ad_parallel_updates_pkg.get_rowid_range
                             (l_start_rowid,
                              l_end_rowid,
                              l_any_rows_to_process,
                              X_batch_size,
                              FALSE) ;
    END LOOP ;

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Total No of records processed successfully          : ' || l_process_total1) ;
    END IF;

    fnd_file.put_line(FND_FILE.OUTPUT, 'Process ending from OE_PAYMENTS table');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('') ;
         oe_debug_pub.add('No record found from OE_PAYMENTS table for Worker Id : ' || X_worker_id) ;
       END IF;

         fnd_file.put_line(FND_FILE.OUTPUT, 'No record found from OE_PAYMENTS table for Worker Id : ' || X_worker_id) ;
    WHEN OTHERS THEN
         l_error_total := SQL%BULK_EXCEPTIONS.COUNT ;

	       FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
		   fnd_file.put_line(FND_FILE.OUTPUT,
		        'Error occurred during iteration ' ||
                         SQL%BULK_EXCEPTIONS(j).ERROR_INDEX ||
                         ' Oracle error is ' ||
                         SQL%BULK_EXCEPTIONS(j).ERROR_CODE );

                   fnd_file.put_line(FND_FILE.OUTPUT,
		        'upgrade failing in oe_payments for credit card for Header ID ' || header_id_tab(j));
               END LOOP;
  END ;

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('Total No of records errored in oe_payments          : ' || l_error_total) ;
  END IF;

  COMMIT ;

  X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL ;

       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Migrate_Data_WKR');
       END IF;

       FND_FILE.PUT_LINE(FND_FILE.LOG,'Concurrent Request Error : '||substr(sqlerrm,1,200));
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL ;

       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Migrate_Data_WKR');
       END IF;

       FND_FILE.PUT_LINE(FND_FILE.LOG,'Concurrent Request Error : '||substr(sqlerrm,1,200));
   WHEN OTHERS THEN
       X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL ;

       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Migrate_Data_WKR');
       END IF;

       FND_FILE.PUT_LINE(FND_FILE.LOG,'Concurrent Request Error : '||substr(sqlerrm,1,200));
END Migrate_Data_WKR ;

PROCEDURE Purge_Data_MGR
(   X_errbuf       OUT NOCOPY VARCHAR2,
    X_retcode      OUT NOCOPY VARCHAR2,
    X_batch_size    IN NUMBER,
    X_Num_Workers   IN NUMBER
)
IS
  l_product                   VARCHAR2(30) := 'ONT' ;
BEGIN
  AD_CONC_UTILS_PKG.submit_subrequests(
               X_errbuf                   => X_errbuf,
               X_retcode                  => X_retcode,
               X_WorkerConc_app_shortname => l_product,
               X_workerConc_progname      => 'ONTIBYCN_WKR',
               X_batch_size               => X_batch_size,
               X_Num_Workers              => X_Num_Workers) ;
END Purge_Data_MGR ;

PROCEDURE Purge_Data_WKR
(   X_errbuf       OUT NOCOPY VARCHAR2,
    X_retcode      OUT NOCOPY VARCHAR2,
    X_batch_size    IN NUMBER,
    X_Worker_Id     IN NUMBER,
    X_Num_Workers   IN NUMBER
)
IS
  TYPE HEADER_ID                  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER ;
  TYPE ROW_ID                     IS TABLE OF ROWID  INDEX BY BINARY_INTEGER ;

  header_id_tab                   header_id ;
  row_id_tab                      row_id ;

  l_table_owner                   VARCHAR2(30) ;
  l_batch_size                    VARCHAR2(30) ;
  l_worker_id                     NUMBER ;
  l_num_workers                   NUMBER ;
  l_any_rows_to_process           BOOLEAN ;

  l_table_name                    VARCHAR2(30) ;
  l_product                       VARCHAR2(30) := 'ONT' ;
  l_script_name                   VARCHAR2(30) := 'OEXUPDMB.pls' ;

  l_start_rowid                   ROWID ;
  l_end_rowid                     ROWID ;
  l_cutoff_date                   DATE;
  l_rows_processed                NUMBER ;
  l_user_id                       NUMBER := NVL(fnd_global.user_id, -1) ;

  l_status                        VARCHAR2(30) ;
  l_industry                      VARCHAR2(30) ;
  l_retstatus                     BOOLEAN ;

  l_return_status                 VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS ;
  l_msg_count                     NUMBER := 0 ;
  l_msg_data                      VARCHAR2(2000) ;

  l_exists_header                 VARCHAR2(1) := 'N' ;
  l_exists_payment                VARCHAR2(1) := 'N' ;
  l_exists_history                VARCHAR2(1) := 'N' ;

  l_error_total1                  NUMBER := 0 ;

  l_process_total1                NUMBER := 0 ;

  l_debug_level                   CONSTANT NUMBER := oe_debug_pub.g_debug_level ;

-- Define a cursor oe_payments_cur to select header_id from oe_payments where
-- payment type code in ('CREDIT_CARD', 'ACH',  'DIRECT_DEBIT'), for the given IN parameters

CURSOR oe_payments_cur (p_start_rowid ROWID, p_end_rowid ROWID) is
  SELECT /*+ LEADING (OP) */ op.header_id,
         op.rowid
    FROM oe_payments op
   WHERE ((op.payment_type_code = 'CREDIT_CARD' AND op.credit_card_number IS NOT NULL)
      OR  (op.payment_type_code IN ('ACH', 'DIRECT_DEBIT') AND op.payment_trx_id IS NOT NULL))
     AND op.trxn_extension_id IS NOT NULL
     AND op.rowid BETWEEN p_start_rowid AND p_end_rowid ;

-- Define another cursor header_payments_cur to select header_id from oe_order_headers_all,
-- where payment type = 'CREDIT_CARD'  for the given IN parameters

CURSOR header_payments_cur (p_start_rowid ROWID, p_end_rowid ROWID) is
  SELECT /*+ LEADING (OOH) */ ooh.header_id,
         ooh.rowid
    FROM oe_order_headers_all ooh
   WHERE (ooh.payment_type_code = 'CREDIT_CARD' AND ooh.credit_card_number IS NOT NULL)
     AND ooh.rowid BETWEEN p_start_rowid AND p_end_rowid ;

-- cursor to select from oe_order_header_history
CURSOR hist_payments_cur (p_start_rowid ROWID, p_end_rowid ROWID) is
  SELECT oohh.header_id, oohh.rowid
  FROM   oe_order_header_history oohh
  WHERE  oohh.payment_type_code = 'CREDIT_CARD'
  AND    oohh.credit_card_number is not null
  AND    oohh.credit_card_number <> '****'
  AND    oohh.instrument_id is not null
  AND    oohh.rowid BETWEEN p_start_rowid AND p_end_rowid;

BEGIN
  --
  -- get schema name of the table for ROWID range processing
  --
  l_retstatus := fnd_installation.get_app_info(l_product, l_status, l_industry, l_table_owner) ;

  IF ((l_retstatus = FALSE)
      OR
      (l_table_owner is null))
  THEN
     raise_application_error(-20001,
        'Cannot get schema name for product : ' || l_product) ;
  END IF ;

  -----------------------------------------------------------
  -- Log Output file
  -----------------------------------------------------------
  fnd_file.put_line(FND_FILE.OUTPUT, '');
  fnd_file.put_line(FND_FILE.OUTPUT, 'Purge Secured Payment Data - Concurrent Program');
  fnd_file.put_line(FND_FILE.OUTPUT, '');
  fnd_file.put_line(FND_FILE.OUTPUT, 'Concurrent Program Parameters');
  fnd_file.put_line(FND_FILE.OUTPUT, 'Batch Size        : '|| X_batch_size);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Number of Threads : '|| X_Num_Workers);

  BEGIN
    -----------------------------------------------------------
    -- Fetching records from OE_PAYMENTS table
    -----------------------------------------------------------
    l_table_name  := 'OE_PAYMENTS' ;

    ad_parallel_updates_pkg.delete_update_information(
	     0,
	     l_table_owner,
	     l_table_name,
	     l_script_name ) ;

    ad_parallel_updates_pkg.initialize_rowid_range(
             ad_parallel_updates_pkg.ROWID_RANGE,
             l_table_owner,
             l_table_name,
             l_script_name,
             X_worker_id,
             X_num_workers,
             X_batch_size, 0) ;

    ad_parallel_updates_pkg.get_rowid_range(
             l_start_rowid,
             l_end_rowid,
             l_any_rows_to_process,
             X_batch_size,
             TRUE) ;

    BEGIN
      SELECT 'Y'
        INTO l_exists_payment
        FROM oe_payments
       WHERE ((payment_type_code = 'CREDIT_CARD' AND credit_card_number IS NOT NULL)
          OR  (payment_type_code IN ('ACH', 'DIRECT_DEBIT') AND payment_trx_id IS NOT NULL))
         AND trxn_extension_id IS NULL
         AND ROWNUM = 1 ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('') ;
            oe_debug_pub.add('No record found from OE_PAYMENTS table for Worker Id : ' || X_worker_id) ;
         END IF;

         fnd_file.put_line(FND_FILE.OUTPUT, 'No record found from OE_PAYMENTS table for Worker Id : ' || X_worker_id) ;
    END;

    BEGIN
      SELECT 'Y'
        INTO l_exists_header
        FROM oe_order_headers_all ooh,
             oe_payments op
       WHERE op.payment_type_code = 'CREDIT_CARD'
         AND op.credit_card_number IS NOT NULL
         AND ooh.header_id        = op.header_id
         AND op.trxn_extension_id IS NULL
         AND ROWNUM               = 1 ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('') ;
            oe_debug_pub.add('No record found from OE_ORDER_HEADERS_ALL table for Worker Id : ' || X_worker_id) ;
         END IF;

         fnd_file.put_line(FND_FILE.OUTPUT, 'No record found from OE_ORDER_HEADERS_ALL table for Worker Id : ' || X_worker_id) ;
    END;

    BEGIN
      SELECT 'Y'
        INTO l_exists_history
        FROM oe_order_header_history
       WHERE payment_type_code = 'CREDIT_CARD'
         AND instrument_id IS NULL
         AND ROWNUM            = 1 ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('') ;
           oe_debug_pub.add('No record found from OE_ORDER_HEADER_HISTORY table for Worker Id : ' || X_worker_id) ;
        END IF;

        fnd_file.put_line(FND_FILE.OUTPUT, 'No record found from OE_ORDER_HEADER_HISTORY table for Worker Id : ' || X_worker_id) ;
    END;

    IF l_exists_header = 'Y' OR l_exists_payment = 'Y' OR l_exists_history = 'Y' THEN
       IF l_debug_level  > 0 THEN
          oe_debug_pub.add('') ;
          oe_debug_pub.add('Data NOT migrated from OE_ORDER_HEADERS_ALL table (Y/N)    : ' || l_exists_header) ;
          oe_debug_pub.add('Data NOT migrated from OE_PAYMENTS table (Y/N)             : ' || l_exists_payment) ;
          oe_debug_pub.add('Data NOT migrated from OE_ORDER_HEADER_HISTORY table (Y/N) : ' || l_exists_history) ;
          oe_debug_pub.add('Please migrate the data before proceeding to purge secured payment data') ;
       END IF;

       fnd_file.put_line(FND_FILE.OUTPUT, 'Data NOT migrated from OE_ORDER_HEADERS_ALL table (Y/N)    : ' || l_exists_header) ;
       fnd_file.put_line(FND_FILE.OUTPUT, 'Data NOT migrated from OE_PAYMENTS table (Y/N)             : ' || l_exists_payment) ;
       fnd_file.put_line(FND_FILE.OUTPUT, 'Data NOT migrated from OE_ORDER_HEADER_HISTORY table (Y/N) : ' || l_exists_history) ;
       fnd_file.put_line(FND_FILE.OUTPUT, 'Please migrate the data before proceeding to purge secured payment data') ;

       RETURN ;
    END IF ;

    fnd_file.put_line(FND_FILE.OUTPUT, '');
    fnd_file.put_line(FND_FILE.OUTPUT, 'Process starting from OE_PAYMENTS table');

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('') ;
       oe_debug_pub.add('AD parallel details : ') ;
       oe_debug_pub.add('') ;
       oe_debug_pub.add('Table owner  : ' || l_table_owner) ;
       oe_debug_pub.add('Table name   : ' || l_table_name) ;
       oe_debug_pub.add('Batch Size   : ' || X_batch_size) ;
       oe_debug_pub.add('Worker ID    : ' || X_worker_id) ;
       oe_debug_pub.add('No of Worker : ' || X_num_workers) ;
    END IF ;

    l_error_total1   := 0 ;

    l_process_total1 := 0 ;

    WHILE (l_any_rows_to_process = TRUE) LOOP
      header_id_tab.delete ;
      row_id_tab.delete ;

      OPEN oe_payments_cur(l_start_rowid, l_end_rowid) ;

      FETCH oe_payments_cur BULK COLLECT INTO
        header_id_tab, row_id_tab
      LIMIT X_batch_size ;

      CLOSE oe_payments_cur ;

--      oe_debug_pub.add('Number of Records : ' || header_id_tab.count) ;

      IF header_id_tab.count > 0 THEN
         BEGIN
           FORALL i in header_id_tab.FIRST..header_id_tab.LAST SAVE EXCEPTIONS
	     UPDATE oe_payments
	        SET credit_card_number          = null,
	            credit_card_holder_name     = null,
		    credit_card_expiration_date = null,
 		    credit_card_code            = null,
                    credit_card_approval_code   = null,
   		    credit_card_approval_date   = null,
		    tangible_id                 = null,
		    payment_trx_id              = null,
	            last_update_date            = sysdate,
		    last_updated_by             = l_user_id,
		    last_update_login           = l_user_id
	      WHERE rowid                       = row_id_tab(i) ;
	 EXCEPTION
	    WHEN OTHERS THEN
                 l_error_total1  := SQL%BULK_EXCEPTIONS.COUNT ;

	         FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
		     fnd_file.put_line(FND_FILE.OUTPUT,
		        'Error occurred during iteration ' ||
                         SQL%BULK_EXCEPTIONS(j).ERROR_INDEX ||
                         ' Oracle error is ' ||
                         SQL%BULK_EXCEPTIONS(j).ERROR_CODE );

		     fnd_file.put_line(FND_FILE.OUTPUT,
		        'Update failing at OE_PAYMENTS from OE_PAYMENTS_CUR for Header ID ' ||
		         header_id_tab(j));
                 END LOOP;
         END;

         l_rows_processed := SQL%ROWCOUNT ;

         l_process_total1 := l_process_total1 + l_rows_processed ;
      END IF ;

      ad_parallel_updates_pkg.processed_rowid_range
	                        (l_rows_processed,
	                         l_end_rowid) ;

      COMMIT ;

      ad_parallel_updates_pkg.get_rowid_range
	                        (l_start_rowid,
	                         l_end_rowid,
	                         l_any_rows_to_process,
	                         X_batch_size,
	                         FALSE) ;
    END LOOP ;

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Total No of records processed successfully           : ' || l_process_total1) ;
       oe_debug_pub.add('Total No of records errored in OE_PAYMENTS           : ' || l_error_total1) ;
    END IF;

    fnd_file.put_line(FND_FILE.OUTPUT, 'Process ending from OE_PAYMENTS table');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('') ;
         oe_debug_pub.add('No record found from OE_PAYMENTS table for Worker Id : ' || X_worker_id) ;
      END IF;

      fnd_file.put_line(FND_FILE.OUTPUT, 'No record found from OE_PAYMENTS table for Worker Id : ' || X_worker_id) ;
  END ;

  BEGIN
    -----------------------------------------------------------
    -- Fetching records from OE_ORDER_HEADERS_ALL table
    -----------------------------------------------------------
    l_table_name  := 'OE_ORDER_HEADERS_ALL' ;

    ad_parallel_updates_pkg.delete_update_information(
	     0,
	     l_table_owner,
	     l_table_name,
	     l_script_name ) ;

    ad_parallel_updates_pkg.initialize_rowid_range(
             ad_parallel_updates_pkg.ROWID_RANGE,
             l_table_owner,
             l_table_name,
             l_script_name,
             X_worker_id,
             X_num_workers,
             X_batch_size, 0) ;

    ad_parallel_updates_pkg.get_rowid_range(
             l_start_rowid,
             l_end_rowid,
             l_any_rows_to_process,
             X_batch_size,
             TRUE) ;

    fnd_file.put_line(FND_FILE.OUTPUT, '');
    fnd_file.put_line(FND_FILE.OUTPUT, 'Process starting from OE_ORDER_HEADERS_ALL table');

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('') ;
       oe_debug_pub.add('AD parallel details : ') ;
       oe_debug_pub.add('') ;
       oe_debug_pub.add('Table owner  : ' || l_table_owner) ;
       oe_debug_pub.add('Table name   : ' || l_table_name) ;
       oe_debug_pub.add('Batch Size   : ' || X_batch_size) ;
       oe_debug_pub.add('Worker ID    : ' || X_worker_id) ;
       oe_debug_pub.add('No of Worker : ' || X_num_workers) ;
    END IF ;

    l_error_total1   := 0 ;

    l_process_total1 := 0 ;

    WHILE (l_any_rows_to_process = TRUE) LOOP
      header_id_tab.delete ;
      row_id_tab.delete ;

      Open header_payments_cur(l_start_rowid, l_end_rowid) ;

      FETCH header_payments_cur BULK COLLECT INTO
        header_id_tab, row_id_tab
      LIMIT X_batch_size ;

      CLOSE header_payments_cur ;

--      oe_debug_pub.add('Number of Records : ' || header_id_tab.count) ;

      IF header_id_tab.count > 0 THEN
         BEGIN
           FORALL i in header_id_tab.FIRST..header_id_tab.LAST SAVE EXCEPTIONS
             UPDATE oe_order_headers_all
	        SET credit_card_number          = null,
	            credit_card_holder_name     = null,
	            credit_card_expiration_date = null,
		    credit_card_code            = null,
		    credit_card_approval_code   = null,
		    credit_card_approval_date   = null,
	            last_update_date            = sysdate,
		    last_updated_by             = l_user_id,
		    last_update_login           = l_user_id
	      WHERE rowid                       = row_id_tab(i) ;
         EXCEPTION
 	    WHEN OTHERS THEN
                 l_error_total1  := SQL%BULK_EXCEPTIONS.COUNT ;

	         FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
		   fnd_file.put_line(FND_FILE.OUTPUT,
		        'Error occurred during iteration ' ||
                         SQL%BULK_EXCEPTIONS(j).ERROR_INDEX ||
                         ' Oracle error is ' ||
                         SQL%BULK_EXCEPTIONS(j).ERROR_CODE );

                   fnd_file.put_line(FND_FILE.OUTPUT,
		        'Update failing at OE_ORDER_HEADERS_ALL from HEADER_PAYMENTS_CUR ' ||
		         header_id_tab(j));
                 END LOOP;
         END;

         l_rows_processed := SQL%ROWCOUNT ;

         l_process_total1 := l_process_total1 + l_rows_processed ;
      END IF ;

      ad_parallel_updates_pkg.processed_rowid_range
	                        (l_rows_processed,
	                         l_end_rowid) ;

      COMMIT ;

      ad_parallel_updates_pkg.get_rowid_range
	                        (l_start_rowid,
	                         l_end_rowid,
	                         l_any_rows_to_process,
	                         X_batch_size,
	                         FALSE) ;
    END LOOP ;

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Total No of records processed successfully           : ' || l_process_total1) ;
       oe_debug_pub.add('Total No of records errored in OE_ORDER_HEADERS_ALL  : ' || l_error_total1) ;
    END IF;

    fnd_file.put_line(FND_FILE.OUTPUT, 'Process ending from OE_ORDER_HEADERS_ALL table');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('') ;
         oe_debug_pub.add('No record found from OE_ORDER_HEADERS_ALL table for Worker Id : ' || X_worker_id) ;
      END IF;

      fnd_file.put_line(FND_FILE.OUTPUT, 'No record found from OE_ORDER_HEADERS_ALL table for Worker Id : ' || X_worker_id) ;
  END ;


  -- start processing oe_order_header_history
  BEGIN
    -----------------------------------------------------------
    -- Fetching records from OE_ORDER_HEADERS_HISTORY table
    -----------------------------------------------------------
    l_table_name  := 'OE_ORDER_HEADER_HISTORY' ;

    ad_parallel_updates_pkg.delete_update_information(
	     0,
	     l_table_owner,
	     l_table_name,
	     l_script_name ) ;

    ad_parallel_updates_pkg.initialize_rowid_range(
             ad_parallel_updates_pkg.ROWID_RANGE,
             l_table_owner,
             l_table_name,
             l_script_name,
             X_worker_id,
             X_num_workers,
             X_batch_size, 0) ;

    ad_parallel_updates_pkg.get_rowid_range(
             l_start_rowid,
             l_end_rowid,
             l_any_rows_to_process,
             X_batch_size,
             TRUE) ;

    fnd_file.put_line(FND_FILE.OUTPUT, '');
    fnd_file.put_line(FND_FILE.OUTPUT, 'Process starting from OE_ORDER_HEADER_HISTORY table');

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('') ;
       oe_debug_pub.add('AD parallel details : ') ;
       oe_debug_pub.add('') ;
       oe_debug_pub.add('Table owner  : ' || l_table_owner) ;
       oe_debug_pub.add('Table name   : ' || l_table_name) ;
       oe_debug_pub.add('Batch Size   : ' || X_batch_size) ;
       oe_debug_pub.add('Worker ID    : ' || X_worker_id) ;
       oe_debug_pub.add('No of Worker : ' || X_num_workers) ;
    END IF ;

    l_error_total1   := 0 ;

    l_process_total1 := 0 ;

    WHILE (l_any_rows_to_process = TRUE) LOOP
      header_id_tab.delete ;
      row_id_tab.delete ;

      Open hist_payments_cur(l_start_rowid, l_end_rowid) ;

      FETCH hist_payments_cur BULK COLLECT INTO
        header_id_tab, row_id_tab
      LIMIT X_batch_size ;

      CLOSE hist_payments_cur ;

--      oe_debug_pub.add('Number of Records : ' || header_id_tab.count) ;

      IF row_id_tab.count > 0 THEN
         BEGIN
           FORALL i in row_id_tab.FIRST..row_id_tab.LAST SAVE EXCEPTIONS
             UPDATE oe_order_header_history
	        SET credit_card_number          = '****',
	            credit_card_holder_name     = '****',
	            credit_card_expiration_date = sysdate,
		    credit_card_code            = '****',
	            last_update_date            = sysdate,
		    last_updated_by             = l_user_id,
		    last_update_login           = l_user_id
	      WHERE rowid                       = row_id_tab(i) ;
         EXCEPTION
 	    WHEN OTHERS THEN
                 l_error_total1  := SQL%BULK_EXCEPTIONS.COUNT ;

	         FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
		   fnd_file.put_line(FND_FILE.OUTPUT,
		        'Error occurred during iteration ' ||
                         SQL%BULK_EXCEPTIONS(j).ERROR_INDEX ||
                         ' Oracle error is ' ||
                         SQL%BULK_EXCEPTIONS(j).ERROR_CODE );

                   fnd_file.put_line(FND_FILE.OUTPUT,
		        'Update failing at OE_ORDER_HEADER_HISTORY from HIST_PAYMENTS_CUR ' ||
		         header_id_tab(j));
                 END LOOP;
         END;

         l_rows_processed := SQL%ROWCOUNT ;

         l_process_total1 := l_process_total1 + l_rows_processed ;
      END IF ;

      ad_parallel_updates_pkg.processed_rowid_range
	                        (l_rows_processed,
	                         l_end_rowid) ;

      COMMIT ;

      ad_parallel_updates_pkg.get_rowid_range
	                        (l_start_rowid,
	                         l_end_rowid,
	                         l_any_rows_to_process,
	                         X_batch_size,
	                         FALSE) ;
    END LOOP ;

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Total No of records processed successfully           : ' || l_process_total1) ;
       oe_debug_pub.add('Total No of records errored in OE_ORDER_HEADER_HISTORY  : ' || l_error_total1) ;
    END IF;

    fnd_file.put_line(FND_FILE.OUTPUT, 'Process ending from OE_ORDER_HEADER_HISTORY table');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('') ;
         oe_debug_pub.add('No record found from OE_ORDER_HEADER_HISTORY table for Worker Id : ' || X_worker_id) ;
      END IF;

      fnd_file.put_line(FND_FILE.OUTPUT, 'No record found from OE_ORDER_HEADER_HISTORY table for Worker Id : ' || X_worker_id) ;
  END ;
  -- end of processsing oe_order_header_history

  COMMIT ;

  X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL ;

       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Purge_Data_WKR');
       END IF;

       FND_FILE.PUT_LINE(FND_FILE.LOG,'Concurrent Request Error : '||substr(sqlerrm,1,200));
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL ;

       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Purge_Data_WKR');
       END IF;

       FND_FILE.PUT_LINE(FND_FILE.LOG,'Concurrent Request Error : '||substr(sqlerrm,1,200));
   WHEN OTHERS THEN
       X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL ;

       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Purge_Data_WKR');
       END IF;

       FND_FILE.PUT_LINE(FND_FILE.LOG,'Concurrent Request Error : '||substr(sqlerrm,1,200));
END Purge_Data_WKR ;

END OE_Payment_Data_Migration_Util ;

/
