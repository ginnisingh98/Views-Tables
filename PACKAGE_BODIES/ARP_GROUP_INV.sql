--------------------------------------------------------
--  DDL for Package Body ARP_GROUP_INV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_GROUP_INV" AS
/*$Header: ARPMINVB.pls 120.8.12010000.2 2008/11/26 23:23:29 vpusulur ship $*/
   PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/** Store the Cons billing Number in a PL/SQL table of cons_inv_id **/

   TYPE cons_billing_number_type IS
      TABLE OF VARCHAR2(100)
      INDEX BY BINARY_INTEGER;

   TYPE cons_inv_id_type IS
      TABLE OF NUMBER(15)
      INDEX BY BINARY_INTEGER;

   g_cons_billing_number    cons_billing_number_type;

   g_cons_inv_id            cons_inv_id_type;


/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    generate                                                                |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Will create new Grouped Invoices for the given AutoInvoice Request      |
 |                                                                            |
 | SCOPE - PRIVATE                                                            |
 |                                                                            |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                     |
 |                                                                            |
 | ARGUMENTS  : IN:                                                           |
 |                 P_request_id          -  Request id                        |
 |            : OUT:                                                          |
 |                 None                                                       |
 |                                                                            |
 | RETURNS    : NONE                                                          |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | MODIFICATION HISTORY                                                       |
 |                                                                            |
 |     13-JUL-2000 Ramakant Alat       Created                                |
 *----------------------------------------------------------------------------*/
   PROCEDURE generate ( p_request_id IN NUMBER) IS

      CURSOR C_group_inv (C_request_id NUMBER) IS
      SELECT
	    ps.cons_inv_id,
            bill_to_customer_id customer_id,
            bill_to_site_use_id site_use_id,
            ct.invoice_currency_code currency_code,
            decode(tt.type, 'CM', 'CREDIT MEMO', 'INVOICE') transaction_type,
            ct.trx_number,
            ct.trx_date,
            ct.customer_trx_id,
            ct.org_id
      FROM
	    ar_payment_schedules ps,
            ra_customer_trx ct,
            ra_cust_trx_types tt
      WHERE
            ct.cust_trx_type_id      = tt.cust_trx_type_id
      AND   ct.customer_trx_id       = ps.customer_trx_id
      AND   ps.cons_inv_id > 0
      AND   ps.terms_sequence_number = 1
      AND   ct.customer_trx_id in  ( SELECT customer_trx_id
		                     FROM   ra_interface_lines il
		                     WHERE  il.request_id = C_request_id
				     AND    customer_trx_id IS NOT NULL
				     AND    cons_billing_number IS NOT NULL
		                     AND    NVL(il.interface_status, '~') <> 'P'
                                    )
      ORDER BY
	    ps.cons_inv_id,
            ct.customer_trx_id;

      old_cons_inv_id              AR_PAYMENT_SCHEDULES.CONS_INV_ID%TYPE:=-1;
      new_cons_inv_id              AR_PAYMENT_SCHEDULES.CONS_INV_ID%TYPE:=-1;

      old_cons_billing_number      AR_CONS_INV.CONS_BILLING_NUMBER%TYPE:='$$~$$';
      new_cons_billing_number      AR_CONS_INV.CONS_BILLING_NUMBER%TYPE:='$$~$$';
      l_group_inv_line_number      AR_CONS_INV_TRX.cons_inv_line_number%TYPE:=1;

   BEGIN

      arp_standard.debug('arp_group_inv.generate()+');

      update_ps(p_request_id=>p_request_id);

      FOR c_group_inv_rec IN c_group_inv (p_request_id) LOOP

         new_cons_inv_id := c_group_inv_rec.cons_inv_id;

         --
         -- Check for the New Group
         --

         IF new_cons_inv_id <> old_cons_inv_id THEN

            old_cons_inv_id         := new_cons_inv_id;  -- Set the old id for future comparison

            new_cons_billing_number := g_cons_billing_number(new_cons_inv_id); -- From update_ps

            /* bug3886862 */
            SELECT nvl(max(cons_inv_line_number),0) + 1
            INTO l_group_inv_line_number
            FROM ar_cons_inv_trx
            WHERE cons_inv_id = new_cons_inv_id ;

            /* if there is no cons inv with the id, create new record */
            IF l_group_inv_line_number = 1 THEN

               INSERT INTO ar_cons_inv
                  (cons_inv_id,
                   cons_billing_number,
                   customer_id,
                   site_use_id,
                   concurrent_request_id,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login,
                   cons_inv_type,
                   status,
                   print_status,
                   issue_date,
                   cut_off_date,
                   due_date,
                   org_id)
               VALUES
                  (new_cons_inv_id,                      -- Cons Inv Id
                   new_cons_billing_number,              -- Cons Billing Number
                   c_group_inv_rec.customer_id,          -- Customer Id
                   c_group_inv_rec.site_use_id,          -- Site Use Id
                   arp_standard.profile.request_id,      -- Request Id
                   arp_global.last_update_date,          -- Last Update Date
                   arp_global.last_updated_by,           -- Last Updated By
                   arp_global.creation_date,             -- Creation Date
                   arp_global.created_by,                -- Created By
                   arp_global.last_update_login,         -- Last Update Login
                   'MINV',                               -- Cons Inv Type
                   'IMPORTED',                           -- Status
                   'PRINTED',                            -- Print Status
                   TRUNC(sysdate),                       -- Issue Date
                   NULL,                                 -- Cutoff Date
                   NULL,                                 -- Due Date
                   arp_standard.sysparm.org_id);

               arp_standard.debug('Inserted cons :' || SQL%ROWCOUNT);

            END IF;

         END IF; /** New group ***/

         INSERT INTO ar_cons_inv_trx
            (cons_inv_id,
             transaction_type,
             trx_number,
             transaction_date,
             amount_original,
             tax_original,
             adj_ps_id,
             cons_inv_line_number,
             customer_trx_id,
             org_id)
         VALUES
            (new_cons_inv_id,                                        -- Cons Inv Id
             c_group_inv_rec.transaction_type,                       -- Transaction Type
             c_group_inv_rec.trx_number,                             -- Transaction Number
             c_group_inv_rec.trx_date,                               -- Transaction Date
             NULL,                                                   -- Amount original
             NULL,                                                   -- Tax Original
             NULL,                                                   -- PS Id
             l_group_inv_line_number,                                -- Cons Inv Line Number
             c_group_inv_rec.customer_trx_id,                        -- Customer Trx Id
             c_group_inv_rec.org_id);

         l_group_inv_line_number := l_group_inv_line_number + 1;

         arp_standard.debug('Inserted ['|| l_group_inv_line_number||'] :' ||
            SQL%ROWCOUNT);

      END LOOP;

      arp_standard.debug('arp_group_inv.generate()-');

   EXCEPTION
    WHEN OTHERS THEN
        arp_standard.debug( 'EXCEPTION: arp_group_inv.generate()' );
        RAISE;
   END;
--
/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    validate_data                                                           |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Validate the interface data with respect to the Grouping of Invoice     |
 |                                                                            |
 | SCOPE - PRIVATE                                                            |
 |                                                                            |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                     |
 |                                                                            |
 | ARGUMENTS  :  IN:                                                          |
 |                 P_request_id   - concurrent request id                     |
 |                                                                            |
 |              OUT:                                                          |
 |                  none      -                                           |
 | RETURNS    :  None                                                         |
 |                                                                            |
 | MODIFICATION HISTORY                                                       |
 |     25-JUL-2000 Ramakant Alat         Created                              |
 |                                                                            |
 *----------------------------------------------------------------------------*/

PROCEDURE validate_data (P_request_id IN NUMBER) IS
   l_message_text   VARCHAR2(2000);
   BEGIN

      arp_standard.debug('arp_group_inv.validate_data()+');

      /******************************************************************
       *** All the transactions grouped under one Group must belong to **
       *** the same bill-to customer                                   **
       ******************************************************************/

      l_message_text :=  arp_standard.fnd_message('AR_RAXTRX-1810');

      INSERT INTO ra_interface_errors
        (interface_line_id,
         message_text,
         invalid_value,
         org_id)
        SELECT l.interface_line_id,
               l_message_text,
               l.cons_billing_number,
               l.org_id
        FROM   ra_interface_lines l
        WHERE  l.request_id = p_request_id
        AND    l.cons_billing_number IS NOT NULL
        AND    l.link_to_line_id IS NULL
        AND    l.orig_system_bill_customer_id IS NOT NULL
        AND    EXISTS (SELECT 'x'
                       FROM  ra_interface_lines l2
                       WHERE l2.request_id     = l.request_id
                       AND   l2.cons_billing_number = l.cons_billing_number
                       AND   l2.orig_system_bill_customer_id <> l.orig_system_bill_customer_id);

       arp_standard.debug('Inserted [1]:' || SQL%ROWCOUNT);

      /******************************************************************
       *** Imported Billing Number must be unique for given type MINV  **
       ******************************************************************/

      l_message_text :=  arp_standard.fnd_message('AR_RAXTRX-1811');

      INSERT INTO RA_INTERFACE_ERRORS
        (interface_line_id,
         message_text,
         invalid_value,
         org_id)
        SELECT l.interface_line_id,
               l_message_text,
               l.cons_billing_number,
               l.org_id
        FROM   ra_interface_lines l
        WHERE  l.request_id = p_request_id
        AND    l.cons_billing_number IS NOT NULL
        AND    (EXISTS (SELECT 'X'
                        FROM   ar_cons_inv
                        WHERE  cons_billing_number = l.cons_billing_number
                        AND    cons_inv_type       = 'MINV' )
                OR
                EXISTS (SELECT 'X'
                        FROM   ra_interface_lines l2
                        WHERE  l2.request_id          > 0
                        AND    l2.request_id          <> l.request_iD
                        AND    l2.cons_billing_number = l.cons_billing_number));

       arp_standard.debug('Inserted [2]:' || SQL%ROWCOUNT);

      /******************************************************************
       *** All the transactions grouped under one Group must belong to **
       *** the same bill-to address                                    **
       ******************************************************************/

      l_message_text :=  arp_standard.fnd_message('AR_RAXTRX-1812');

      INSERT INTO RA_INTERFACE_ERRORS
        (interface_line_id,
         message_text,
         invalid_value,
         org_id)
        SELECT l.interface_line_id,
               l_message_text,
               l.cons_billing_number,
               l.org_id
        FROM   ra_interface_lines l
        WHERE  l.request_id = p_request_id
        AND    l.cons_billing_number IS NOT NULL
        AND    l.link_to_line_id IS NULL
        AND    l.orig_system_bill_address_id IS NOT NULL
        AND    EXISTS (SELECT 'X'
                       FROM   ra_interface_lines l2
                       WHERE  l2.request_id                  = l.request_id
                       AND    l2.cons_billing_number         = l.cons_billing_number
                       AND    l2.orig_system_bill_address_id <> l.orig_system_bill_address_id);

       arp_standard.debug('Inserted [3]:' || SQL%ROWCOUNT);

      /******************************************************************
       *** Customer must be enabled to Import billing Number           **
       ******************************************************************/
-- Bug 2501153: To avoid the merge join cartesian, added a table hz_cust_acct_sites

      l_message_text :=  arp_standard.fnd_message('AR_RAXTRX-1814');

      INSERT INTO RA_INTERFACE_ERRORS
        (interface_line_id,
         message_text,
         invalid_value,
         org_id)
        SELECT l.interface_line_id,
               l_message_text,
               l.cons_billing_number,
               l.org_id
        FROM   ra_interface_lines l
        WHERE  l.request_id = p_request_id
        AND    l.cons_billing_number IS NOT NULL
        AND    l.link_to_line_id IS NULL
        AND    l.orig_system_bill_customer_id IS NOT NULL
        AND    l.orig_system_bill_address_id IS NOT NULL
        AND    EXISTS (SELECT /*+ no_unnest */'X'
                        FROM
                              hz_cust_site_uses su,
                              hz_customer_profiles cp,
                              hz_customer_profiles sp,
                              hz_cust_acct_sites ac
                        WHERE su.cust_acct_site_id = l.orig_system_bill_address_id
                        AND   su.site_use_code  = 'BILL_TO'
                        AND   su.status         = 'A'
                        AND   cp.cust_account_id = l.orig_system_bill_customer_id
                        AND   cp.site_use_id    IS NULL
                        AND   ac.cust_acct_site_id = su.cust_acct_site_id
                        AND   ac.cust_account_id = cp.cust_account_id
                        AND   su.site_use_id    = sp.site_use_id (+)
                        AND   NVL(NVL(sp.cons_inv_flag, cp.cons_inv_flag), 'N') = 'N'
                      );
      arp_standard.debug('Inserted [4]:' || SQL%ROWCOUNT);

      /******************************************************************
       *** You cannot import Billing Number for the customer using    ***
       *** Consolidated Billing functionality                         ***
       ******************************************************************/
-- Bug 2501153: To avoid the merge join cartesian, added a table hz_cust_acct_sites

      l_message_text :=  arp_standard.fnd_message('AR_RAXTRX-1813');

      INSERT INTO RA_INTERFACE_ERRORS
        (interface_line_id,
         message_text,
         invalid_value,
         org_id)
        SELECT l.interface_line_id,
               l_message_text,
               l.cons_billing_number,
               l.org_id
        FROM   ra_interface_lines l
        WHERE  l.request_id = p_request_id
        AND    l.cons_billing_number IS NOT NULL
        AND    l.link_to_line_id IS NULL
        AND    l.orig_system_bill_customer_id IS NOT NULL
        AND    l.orig_system_bill_address_id IS NOT NULL
        AND    EXISTS (SELECT /*+ no_unnest */'X'
                        FROM
                              hz_cust_site_uses su,
                              hz_customer_profiles cp,
                              hz_customer_profiles sp,
                              hz_cust_acct_sites ac
                        WHERE su.cust_acct_site_id  = l.orig_system_bill_address_id
                        AND   su.site_use_code  = 'BILL_TO'
                        AND   su.status         = 'A'
                        AND   cp.cust_account_id = l.orig_system_bill_customer_id
                        AND   cp.site_use_id    IS NULL
                        AND   ac.cust_acct_site_id = su.cust_acct_site_id
                        AND   ac.cust_account_id = cp.cust_account_id
                        AND   su.site_use_id    = sp.site_use_id (+)
                        AND   NVL(sp.cons_inv_flag, cp.cons_inv_flag) = 'Y'
			AND   NVL(sp.cons_inv_type, cp.cons_inv_type) <> 'IMPORTED'
                      );
      arp_standard.debug('Inserted [5]:' || SQL%ROWCOUNT);

      arp_standard.debug('arp_group_inv.validate_data()-');

   EXCEPTION
     WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug( ' Exception: validate_data: ');
       END IF;
       RAISE;
   END validate_data;
--
/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    update_ps                                                               |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Update ar_payment_schedules                                             |
 |                                                                            |
 | SCOPE - PRIVATE                                                            |
 |                                                                            |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                     |
 |                                                                            |
 | ARGUMENTS  :  IN:                                                          |
 |                 P_request_id   - concurrent request id                     |
 |                                                                            |
 |              OUT:                                                          |
 |                  none      -                                               |
 | RETURNS    :  None                                                         |
 |                                                                            |
 | MODIFICATION HISTORY                                                       |
 |     26-JUL-2000 Ramakant Alat         Created                              |
 |                                                                            |
 *----------------------------------------------------------------------------*/
   PROCEDURE update_ps (p_request_id IN NUMBER) IS

      CURSOR c01 IS
      SELECT DISTINCT cons_billing_number, customer_trx_id
      FROM   ra_interface_lines li
      WHERE  request_id = p_request_id
      and    li.customer_trx_id IS NOT NULL
      AND    cons_billing_number IS NOT NULL
      AND    NVL(interface_status, '~') <> 'P'      -- Only consider unprocessed Transactions
      AND    EXISTS (SELECT 1
		     FROM   ra_customer_trx ct
		     WHERE  ct.customer_trx_id = li.customer_trx_id)
      ORDER BY cons_billing_number, customer_trx_id;

      /* bug3886862 check if there is cons inv with the number */
      /* bug3895741 modified l_cbi_number type */
      CURSOR check_cbi_num (l_cbi_number
ar_cons_inv.cons_billing_number%TYPE) IS
      SELECT cons_inv_id
      FROM   ar_cons_inv
      WHERE  cons_billing_number = l_cbi_number
      AND    cons_inv_type = 'MINV';

      l_cons_inv_id                 ar_cons_inv.cons_inv_id%TYPE;
      old_cons_billing_number       ar_cons_inv.cons_billing_number%TYPE:='$$~$$';
      l_tot_rec_updated             NUMBER:=0;

   BEGIN
      --
      arp_standard.debug('arp_group_inv.update_ps()+');
      --
      FOR c01_rec IN c01 LOOP
      --
         IF old_cons_billing_number <> c01_rec.cons_billing_number THEN

            /* bug3886862 if there is cons inv already, get the cons_inv_id */
            OPEN check_cbi_num(c01_rec.cons_billing_number) ;
            FETCH check_cbi_num INTO l_cons_inv_id ;

               /* the cons_billing_number is new */
               IF check_cbi_num%NOTFOUND
               THEN
                  --
                  SELECT ar_cons_inv_s.NEXTVAL INTO l_cons_inv_id FROM dual;
                  --
               END IF;
            CLOSE check_cbi_num ;

            old_cons_billing_number := c01_rec.cons_billing_number;
         --
         -- Store the Group Invoice number in the PL/SQL table
         -- This information will be useful during the group invoice creation.
         --
            g_cons_billing_number(l_cons_inv_id) := c01_rec.cons_billing_number;

         END IF;
         --
         -- Store the cons_inv_id in the PL/SQL table
         --
         g_cons_inv_id(c01_rec.customer_trx_id) := l_cons_inv_id;
      --
         UPDATE ar_payment_schedules
         SET    cons_inv_id         = l_cons_inv_id
         WHERE  customer_trx_id     = c01_rec.customer_trx_id;
      --
	 l_tot_rec_updated := l_tot_rec_updated + SQL%ROWCOUNT;
      --
      END LOOP;

      --
      arp_standard.debug('Updated :' || l_tot_rec_updated);
      --
      arp_standard.debug('arp_group_inv.update_ps()-');
      --
   EXCEPTION
      WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug( ' Exception: arp_group_inv.update_ps()');
        END IF;
        RAISE;
   END update_ps;

/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    validate_group                                                          |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Will check if any of the invoices having the same consolidated billing  |
 | no have been rejected. If so, then the other invoices are also rejected    |
 |                                                                            |
 | SCOPE                                                                      |
 |    Public                                                                  |
 |                                                                            |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                     |
 |    None                                                                    |
 |                                                                            |
 | ARGUMENTS                                                                  |
 |   IN :       P_request_id          -  Request id                           |
 |   OUT:       O_rows_rejected       -  No of Rejections                     |
 |                                                                            |
 | RETURNS    : NONE                                                          |
 |                                                                            |
 | NOTES                                                                      |
 |     Is called from raavcb.lpc                                              |
 |                                                                            |
 | MODIFICATION HISTORY                                                       |
 |     11-JUN-2002 Sahana              Created                                |
 *----------------------------------------------------------------------------*/
PROCEDURE validate_group(p_request_id IN NUMBER,o_rows_rejected OUT NOCOPY NUMBER) IS
l_message_text   VARCHAR2(2000);
BEGIN
   arp_standard.debug('arp_group_inv.validate_group()+');

   l_message_text := arp_standard.fnd_message('AR_RAXTRX-1819');

   INSERT INTO RA_INTERFACE_ERRORS
        (interface_line_id,
         message_text,
         invalid_value,
         org_id)
   SELECT l.interface_line_id,
        l_message_text,
        l.cons_billing_number,
        l.org_id
   FROM   ra_interface_lines_gt l
   WHERE  l.request_id = p_request_id
   AND    l.cons_billing_number IS NOT NULL
   AND    nvl(l.interface_status,'~') <> 'P'
   AND    l.link_to_line_id is null
   AND    l.customer_trx_id is not null
   AND    EXISTS
       ( SELECT /*+ leading(L2) use_nl_with_index(E, RA_INTERFACE_ERRORS_N1) */  'x'
           FROM  ra_interface_errors e, ra_interface_lines_gt l2
           WHERE  e.INTERFACE_LINE_ID = l2.INTERFACE_LINE_ID
           AND l2.cons_billing_number = l.cons_billing_number
           AND l2.request_id = l.request_id );

   o_rows_rejected := SQL%ROWCOUNT;

   arp_standard.debug('validate_group: No of Invoices Rejected- '||
       o_rows_rejected);

   arp_standard.debug('arp_group_inv.validate_group()-');

 EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug( ' Exception: validate_group: '||SQLERRM);
      END IF;
      RAISE;
 END validate_group;

END arp_group_inv;

/
