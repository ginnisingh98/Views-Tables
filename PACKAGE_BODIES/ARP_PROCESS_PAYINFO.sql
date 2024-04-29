--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_PAYINFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_PAYINFO" AS
/*$Header: ARPPYMTSB.pls 120.5.12010000.4 2010/01/22 09:58:45 vpusulur ship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
G_PKG_NAME      CONSTANT VARCHAR2(30)   := 'ARP_PROCESS_PAYINFO';

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
pg_debug varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/*========================================================================
 | Prototype Declarations Procedures
 *=======================================================================*/
--
--
--
--
--

/*========================================================================
 | Procedure copy_payment_ext_id()
 |
 | DESCRIPTION
 |      Process Invoices from AutoInvoice batch
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 |
 | RETURNS
 |      nothing
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author           Description of Changes
 | 25-Aug-2005           Ramakant Alat    Created
 | 14-MAY-2008           M Raymond        7039838 - FT performance tuning
 |
 *=======================================================================*/
PROCEDURE copy_payment_ext_id  AS

--
-- Get all invoices / debit memos which need payment processing
--
CURSOR c01  IS
SELECT
      inv.trx_number,
      inv.customer_trx_id customer_trx_id,
      cus.party_id,
      inv.paying_customer_id,
      inv.paying_site_use_id,
      inv.org_id
FROM
      ra_customer_trx inv, hz_cust_accounts cus
WHERE
      inv.request_id         = fnd_global.conc_request_id
  AND inv.payment_attributes IS NOT NULL
  AND inv.paying_customer_id = cus.cust_account_id
  AND NOT EXISTS (
      SELECT /*+ leading(L) use_nl_with_index(E, RA_INTERFACE_ERRORS_N1) */ 1
      FROM  ra_customer_trx_lines l, ra_interface_errors e
      WHERE l.customer_trx_id = inv.customer_trx_id
      AND   l.customer_trx_line_id = e.interface_line_id
      AND   l.request_id = FND_GLOBAL.CONC_REQUEST_ID);  -- 7039838


l_ext_entity_tab        IBY_FNDCPT_COMMON_PUB.Id_tbl_type;
l_msg                   RA_INTERFACE_ERRORS.MESSAGE_TEXT%TYPE;
l_payer                 IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
l_trxn_attribs          IBY_FNDCPT_TRXN_PUB.TrxnExtension_rec_type;
l_result                IBY_FNDCPT_COMMON_PUB.Result_rec_type;

l_extension_id          NUMBER;


l_return_status         VARCHAR2(100);
l_msg_count             NUMBER:=0;
l_msg_data              VARCHAR2(20000):= NULL;

BEGIN
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_payinfo.copy_payment_ext_id()+ ');
      arp_standard.debug('Req Id : [' || arp_global.request_id || ']');
      arp_standard.debug('FND Req Id : [' || fnd_global.conc_request_id || ']');
   END IF;
   --
   l_payer.Org_Type                := null;
   l_payer.Org_id                  := null;
   l_trxn_attribs.Originating_Application_Id := 222; --- Receivables
   --
   -- Check if there are any Invoices to process in the list
   --
   <<inv_loop>>
   FOR c01_rec IN c01 LOOP
      --
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('INV Customer Trx ID [' || c01_rec.customer_trx_id || ']');
      END IF;
      --
      -- Get Payment extension entity IDs for given transaction
      --
      SELECT
            DISTINCT line.payment_trxn_extension_id
      BULK COLLECT INTO
            l_ext_entity_tab
      FROM
            ra_customer_trx_lines line
      WHERE
            line.customer_trx_id = c01_rec.customer_trx_id
      AND   line.payment_trxn_extension_id IS NOT NULL    -- 9274573
      AND   line.request_id = FND_GLOBAL.CONC_REQUEST_ID; -- 7039838

      --
      -- Copy Extension entity
      --
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('copying Transaction Extension....');
         FOR i IN l_ext_entity_tab.FIRST..l_ext_entity_tab.LAST LOOP
            arp_standard.debug('[' || i || '] :<' || l_ext_entity_tab(i)|| '>');
         END LOOP;
      END IF;
      --
      l_payer.Payment_Function        := 'CUSTOMER_PAYMENT';
      l_payer.Party_Id                := c01_rec.party_id;
      l_payer.Cust_Account_Id         := c01_rec.paying_customer_id;
      l_trxn_attribs.order_id         := c01_rec.trx_number;
      l_trxn_attribs.trxn_ref_number1 := 'TRANSACTION';
      l_trxn_attribs.trxn_ref_number2 := c01_rec.customer_trx_id;

 --
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('l_payer.payment_function :<' ||
                            l_payer.payment_function  || '>');
         arp_standard.debug('l_payer.Party_Id         :<' || l_payer.Party_Id || '>');
         arp_standard.debug('l_payer.Org_Type         :<' || l_payer.Org_Type || '>');
         arp_standard.debug('l_payer.Org_id         :<' || l_payer.Org_id || '>');
         arp_standard.debug('l_payer.Cust_Account_Id  :<' ||
                             l_payer.Cust_Account_Id || '>');
         arp_standard.debug('l_trxn_attribs.Originating_Application_Id :<'
            || l_trxn_attribs.Originating_Application_Id || '>');
         arp_standard.debug('l_trxn_attribs.Instrument_Security_Code :<'
            || l_trxn_attribs.Instrument_Security_Code || '>');
         arp_standard.debug('l_trxn_attribs.order_id :<'
            || l_trxn_attribs.order_id || '>');
      END IF;
      --
      IBY_FNDCPT_TRXN_PUB.Copy_Transaction_Extension
      (
      p_api_version        =>1.0,
      p_init_msg_list      =>FND_API.G_TRUE,
      p_commit             =>FND_API.G_FALSE,
      x_return_status      =>l_return_status,
      x_msg_count          =>l_msg_count,
      x_msg_data           =>l_msg_data,
      p_payer              =>l_payer,
      p_payer_equivalency  =>IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_DOWNWARD,
      p_entities           =>l_ext_entity_tab,
      p_trxn_attribs       =>l_trxn_attribs,
      x_entity_id          =>l_extension_id,
      x_response           =>l_result
      );

      --
      -- Print out variables
      --
      IF PG_DEBUG in ('Y', 'C') THEN
      --
         arp_standard.debug('x_return_status  :<' || l_return_status || '>');
         arp_standard.debug('x_entity_id      :<' || l_extension_id || '>');
         arp_standard.debug('x_msg_count      :<' || l_msg_count || '>');
      --
      END IF;

      <<msg_loop>>
      FOR i IN 1..l_msg_count LOOP
         --
         l_msg := SUBSTR(fnd_msg_pub.get(p_msg_index => i,
                     p_encoded => FND_API.G_FALSE),1,150);
         --
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('x_msg #' || TO_CHAR(i) || ' = <' ||
               l_msg || '>');
         END IF;
         --
         -- If unable to copy ext entities then insert into
         -- AutoInvoice errors table to reject transation
         --
         IF l_return_status <> 'S'  THEN
         --
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('Inserting into errors...');
            END IF;
         --
            INSERT INTO ra_interface_errors
                   (
                   org_id,
                   interface_line_id,
                   message_text,
                   invalid_value
                   )
            SELECT
                   org_id,
                   customer_trx_line_id,
                   l_msg,
                   payment_trxn_extension_id
            FROM
                   ra_customer_trx_lines lines
            WHERE
                   lines.customer_trx_id = c01_rec.customer_trx_id ;

         --
         END IF;
      END LOOP msg_loop;
      --
      -- If tranaction extension entity was copied
      -- then update the transaction header with it.
      --
      IF l_return_status = 'S'  THEN
         --
         UPDATE
               ra_customer_trx
         SET
               payment_trxn_extension_id = l_extension_id
         WHERE
               customer_trx_id = c01_rec.customer_trx_id;
         --
      END IF;
      --
      --
      --
   END LOOP inv_loop;
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_payinfo.copy_payment_ext_id()- ');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      arp_standard.debug('EXCEPTION : arp_process_payinfo.copy_payment_ext_id '           ||': ' || SQLERRM(SQLCODE));
      RAISE;
END copy_payment_ext_id;

/*========================================================================
 | Procedure default_payment_attributes()
 |
 | DESCRIPTION
 |      This procedure deaults the payment_attributes for transaction
 |      grouping
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 | RETURNS
 |      nothing
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author           Description of Changes
 | 28-Aug-2005           Ramakant Alat    Created
 |
 *=======================================================================*/
PROCEDURE default_payment_attributes AS


l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_payinfo.default_payment_attributes()+ ');
      arp_standard.debug('Req Id : [' || arp_global.request_id || ']');
      arp_standard.debug('FND Req Id : [' || fnd_global.conc_request_id || ']');
   END IF;
   --
   -- Update transaction header with payment attributes for grouping
   --
   /* 7039838 - replaced hint for FT performance tuning initialitive */

  UPDATE ra_interface_lines il
  SET payment_attributes =
    (SELECT
      CASE
      WHEN authorized_flag = 'Y' THEN
        CASE
       WHEN SUM(decode(auth.settle_req_auth_flag,    'Y',    1,    0)) > 0 THEN
          'PERSISTENT-AUTH~' || ext.instr_assignment_id || '~' || ext.trxn_extension_id
       ELSE
          'NON-PERSISTENT-AUTH~' || ext.instr_assignment_id || '~'
       END
     ELSE
         'NO-AUTH~' || ext.instr_assignment_id || '~'
     END
     FROM iby_fndcpt_tx_extensions ext,
        (SELECT /*+  leading(op) use_nl(summ,seft,ueft)  */
        op.trxn_extension_id,
         decode(decode(summ.status,    0,    'Y',    100,    'Y',    NULL), 'N',    'Y') authorized_flag,
         nvl(seft.settle_require_vrfy_flag,    'N') settle_req_auth_flag
       FROM iby_trxn_summaries_all summ,
         iby_fndcpt_tx_operations op,
         iby_fndcpt_sys_eft_pf_b seft,
         iby_fndcpt_user_eft_pf_b ueft
       WHERE(summ.transactionid = op.transactionid)
       AND(reqtype = 'ORAPMTREQ')
       AND(trxntypeid IN(2,    3,    20))
       AND(decode(instrtype,    'BANKACCOUNT',    summ.process_profile_code, NULL) = ueft.user_eft_profile_code(+))
       AND(ueft.sys_eft_profile_code = seft.sys_eft_profile_code(+)))
    auth,
       fnd_application a
     WHERE ext.trxn_extension_id = il.payment_trxn_extension_id
     AND ext.trxn_extension_id = auth.trxn_extension_id(+)
     AND auth.settle_req_auth_flag(+) = 'Y'
     AND ext.origin_application_id = a.application_id
     GROUP BY auth.authorized_flag,
       ext.instr_assignment_id,
       ext.trxn_extension_id)
  WHERE request_id = fnd_global.conc_request_id
   AND payment_trxn_extension_id IS NOT NULL;
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_payinfo.default_payment_attributes()- ');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      arp_standard.debug('EXCEPTION : arp_process_payinfo.default_payment_attributes : ' || SQLERRM(SQLCODE));
      RAISE;
END default_payment_attributes;
/*========================================================================
 | Procedure validate_payment_ext_id()
 |
 | DESCRIPTION
 |      This procedure validate ext id
 |      grouping
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 | RETURNS
 |      nothing
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author           Description of Changes
 | 28-Aug-2005           Ramakant Alat    Created
 |
 *=======================================================================*/
PROCEDURE validate_payment_ext_id AS


l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_payinfo.validate_payment_ext_id()+ ');
      arp_standard.debug('Req Id : [' || arp_global.request_id || ']');
      arp_standard.debug('FND Req Id : [' || fnd_global.conc_request_id || ']');
   END IF;
   --
   -- Validate payment_trxn_ext_id
   --
   -- 7039838 - perf tuning
   INSERT INTO RA_INTERFACE_ERRORS
    (INTERFACE_LINE_ID,
     MESSAGE_TEXT,
     INVALID_VALUE,
     ORG_ID)
    SELECT /*+ cardinality(L,10) leading(L) use_nl(rm,rc, P,X) */
           L.INTERFACE_LINE_ID,
           CASE
              WHEN l.receipt_method_id IS NULL THEN
                 arp_standard.fnd_message('AR_REC_MTHD_REQD_FOR_EXT_ID')
              WHEN rc.creation_method_code NOT IN ('AUTOMATIC', 'BR') THEN
                 arp_standard.fnd_message('AR_RECEIPT_METHOD_AUTO_OR_BR')
              WHEN NVL(rm.payment_channel_code, 'BILLS_RECEIVABLE')
                      <> p.payment_channel_code THEN
                 arp_standard.fnd_message('AR_PMT_CHNL_MISMTCH_REC_MTHD')
              ELSE
                 'VALIDATE_EXT_ID:NO_MSG'
           END,
           L.PAYMENT_TRXN_EXTENSION_ID,
           L.ORG_ID
    FROM   RA_INTERFACE_LINES_GT L,
           AR_RECEIPT_METHODS rm,
           AR_RECEIPT_CLASSES rc,
	   IBY_FNDCPT_PMT_CHNNLS_B P,
           IBY_FNDCPT_TX_EXTENSIONS X
WHERE      L.REQUEST_ID = fnd_global.conc_request_id
    AND    L.CUSTOMER_TRX_ID IS NOT NULL
    AND    NVL(L.INTERFACE_STATUS, '~') <> 'P'
    AND    l.receipt_method_id = rm.receipt_method_id (+)
    AND    rm.receipt_class_id = rc.receipt_class_id (+)
    AND    L.PAYMENT_TRXN_EXTENSION_ID IS NOT NULL
    AND    (l.receipt_method_id IS NULL OR rc.creation_method_code NOT IN ('AUTOMATIC', 'BR') OR
            NVL(rm.payment_channel_code, 'BILLS_RECEIVABLE') <> p.payment_channel_code )
    AND    l.PAYMENT_TRXN_EXTENSION_ID = X.TRXN_EXTENSION_ID
    AND x.payment_channel_code = p.payment_channel_code;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_payinfo.validate_payment_ext_id()- ');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      arp_standard.debug('EXCEPTION : arp_process_payinfo.validate_payment_ext_id : ' || SQLERRM(SQLCODE));
      RAISE;
END validate_payment_ext_id;


END arp_process_payinfo;

/
