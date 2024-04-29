--------------------------------------------------------
--  DDL for Package Body ARP_DEDUCTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_DEDUCTION" AS
/* $Header: ARXLDEDB.pls 120.15.12010000.4 2009/06/17 10:11:59 spdixit ship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/

/*========================================================================
 | Prototype Declarations Procedures
 *=======================================================================*/

 PG_DEBUG  VARCHAR2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/*========================================================================
 | Prototype Declarations Functions
 *=======================================================================*/

/*========================================================================
 | PUBLIC FUNCTION CHECK_TM
 |
 | DESCRIPTION
 |      This function returns true if Trade Management is installed
 |      otherwise it returns false.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |      arlplb.opc  (lockbox main program)
 |      arccbp.lpc  (postbatch)
 |
 | CALLED PROCEDURES/FUNCTIONS
 |      OZF_CLAIM_INSTALL.CHECK_INSTALLED
 |
 | PARAMETERS
 |     none
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 27-NOV-2002           AMateen           Created
 | 20-NOV-2003		 jbeckett	   Bug 3251839: Checks cached arp_global
 |					   instead of TM function.
 |
 *=======================================================================*/
FUNCTION CHECK_TM RETURN BOOLEAN IS

BEGIN
  IF arp_global.tm_installed_flag = 'Y' THEN
     RETURN TRUE;
  ELSE
     RETURN FALSE;
  END IF;

EXCEPTION

  WHEN OTHERS THEN

    IF PG_DEBUG in ('Y','C') THEN
     arp_standard.debug('EXCEPTION - OTHERS : ARP_DEDUCTION.CHECK_TM');
    END IF;
    RETURN FALSE;

END CHECK_TM;


/*========================================================================
 | PUBLIC FUNCTION CHECK_TM_DEFAULT_SETUP
 |
 | DESCRIPTION
 |      This function returns true if Trade Management Default setup is
 |      available otherwise it returns false.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |      arlplb.opc (Lockbox)
 |      arccbp.lpc (Postbatch)
 |
 |
 | CALLS PROCEDURES/FUNCTIONS
 |      OZF_CLAIM_INSTALL.CHECK_DEFAULT_SETUP
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |    This will check to see if Trade Management is setup properly to
 |    handle Claims.  If TM is not set up to handle claims and the user
 |    has setup to create claims, we want postbatch and lockbox to
 |    error and force the setup of TM before continuing.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-FEB-2003           cthangai          Created
 | 20-NOV-2003		 jbeckett	   Bug 3251839: Replaced ozf function
 |					   call with check on cached
 |					   arp_global.tm_default_setup_flag.
 *=======================================================================*/
FUNCTION CHECK_TM_DEFAULT_SETUP RETURN BOOLEAN IS

BEGIN

  IF arp_global.tm_default_setup_flag = 'Y' THEN
     RETURN TRUE;
  ELSE
     RETURN FALSE;
  END IF;

EXCEPTION

  WHEN OTHERS THEN

    IF PG_DEBUG in ('Y','C') THEN
      arp_standard.debug('EXCEPTION - OTHERS : ARP_DEDUCTION.CHECK_TM_DEFAULT_SETUP');
    END IF;
    RETURN FALSE;

END CHECK_TM_DEFAULT_SETUP;


/*========================================================================
 | PUBLIC PROCEDURE claim_creation
 |
 | DESCRIPTION
 |     Procedure to create a deduction claim in Trade Management and  update
 |     receivable applications, appropriately with  Deduction ID, deduction
 |     number and customer reason code. Handles Non Trx realted claims
 |     and On Transaction related claims (short pays).
 |     This procedure is initiated by the Post Batch process.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |     arccbp.lpc (Postbatch)
 |
 | CALLS PROCEDURES/FUNCTIONS
 |     arp_process_application.create_claim
 |     app_exception.invalid_argument
 |
 | PARAMETERS
 |        IN :  p_request_id
 |              p_matched_claim_creation_flag
 |              p_matched_claim_excl_cm_flag
 |       OUT :  x_return_status
 |
 | KNOWN ISSUES
 |     This procedure will not create Cross Currency Claims.
 |
 | NOTES
 |     This procedure should only do claim creation for those records
 |     which have been created by postbatch during this request id,
 |     Since the receipt api is called during the postbatch process, it
 |     is possible that the receipt api will create 'OTHER ACC' (Claim
 |     Investigation Applications), however we do not want to create
 |     a claim for those records.  To deal with this, we are explicitly
 |     looking for claims created with an application rule = 90 (ie.
 |     OTHER ACC records which have come from postbatch)
 |
 | MODIFICATION HISTORY
 | Date         Author            Description of Changes
 | 19-DEC-2002  cthangai          Created
 | 07-FEB-2003  cthangai          Added parameters customer_reason,
 |                                x_claim_reason_name to the routine call
 |                                arp_process_application.create_claim
 |                                Also modified the cursors to fetch RA info
 |                                and associated composite data structures
 | 17-FEB-2003  cthangai          Added qualifier to exclude claim processing
 |                                for class = 'PMT'
 | 24-FEB-2003  cthangai          Qualified cursor get_ra_info by request_id
 | 26-FEB-2003  cthangai          Pass amount_applied to TM for claim creation
 | 27-FEB-2003  cthangai          Added OUT parameter x_return_status
 | 03-MAR-2003  cthangai          Qualified the update that stamps TRX based claims
 |                                with claim info by applied_payment_schedule_id
 |                                and applied_customer_trx_id
 |                                Qaulified the get_trx_app_info cursor by request_id
 | 05-MAR-2003  cthangai          Fail Recover - Full recover when the initial UNAPP
 |                                amount_applied is less than the sum of
 |                                amount applied for the paired UNAPP records
 |                                else partial recover.
 | 14-OCT-2005  jbeckett	  Bug 4565758 - AR/TM legal entity uptake
 *=======================================================================*/
PROCEDURE claim_creation
  (p_request_id  IN ar_receivable_applications.request_id%TYPE DEFAULT NULL
  ,p_matched_claim_creation_flag IN ar_system_parameters.matched_claim_creation_flag%TYPE
  ,p_matched_claim_excl_cm_flag IN ar_system_parameters.matched_claim_excl_cm_flag%TYPE
  ,x_return_status OUT NOCOPY VARCHAR2
  )IS

  --Primary cursor for processing Non TRX based claims
  CURSOR get_claim_rec IS
    SELECT
           ra.rowid
          ,ra.receivable_application_id
          ,ra.amount_applied
          ,ra.payment_schedule_id
          ,ra.applied_payment_schedule_id
          ,ra.applied_customer_trx_id
          ,ra.comments
          ,ra.attribute_category
          ,ra.attribute1
          ,ra.attribute2
          ,ra.attribute3
          ,ra.attribute4
          ,ra.attribute5
          ,ra.attribute6
          ,ra.attribute7
          ,ra.attribute8
          ,ra.attribute9
          ,ra.attribute10
          ,ra.attribute11
          ,ra.attribute12
          ,ra.attribute13
          ,ra.attribute14
          ,ra.attribute15
          ,ra.application_ref_num
          ,ra.secondary_application_ref_id
          ,ra.application_ref_reason
          ,ra.customer_reason
          ,ra.customer_reference
          ,NULL           -- x_return_status
          ,NULL           -- x_msg_count
          ,NULL           -- x_msg_data
          ,NULL           -- x_claim_reason_name
          ,apply_date     -- bug 5495310
    FROM   ar_receivable_applications  ra
    WHERE  ra.application_ref_type = 'CLAIM'
    AND    ra.status = 'OTHER ACC'
    AND    ra.application_ref_num IS NULL
    AND    ra.application_rule = 90
    AND    ra.request_id = p_request_id;


  --Cursor to fetch RA info based on the applied PS id retreived by the
  --primary cursor to process TRX based claims
  CURSOR get_ra_info (
    p_trx_ps_id ar_receivable_applications.applied_payment_schedule_id%type
                     ) IS
    SELECT
           ra.receivable_application_id
          ,ra.amount_applied
          ,ra.payment_schedule_id
          ,ra.applied_payment_schedule_id
          ,ra.applied_customer_trx_id
          ,ra.comments
          ,ra.attribute_category
          ,ra.attribute1
          ,ra.attribute2
          ,ra.attribute3
          ,ra.attribute4
          ,ra.attribute5
          ,ra.attribute6
          ,ra.attribute7
          ,ra.attribute8
          ,ra.attribute9
          ,ra.attribute10
          ,ra.attribute11
          ,ra.attribute12
          ,ra.attribute13
          ,ra.attribute14
          ,ra.attribute15
          ,ra.application_ref_num
          ,ra.secondary_application_ref_id
          ,ra.application_ref_reason
          ,ra.customer_reason
          ,ra.customer_reference
          ,NULL           -- x_return_status
          ,NULL           -- x_msg_count
          ,NULL           -- x_msg_data
          ,NULL           -- x_claim_reason_name
    FROM   ar_receivable_applications   ra
    WHERE  ra.applied_payment_schedule_id = p_trx_ps_id
    AND    ra.request_id = p_request_id
    AND    ra.display = 'Y'
    AND    ra.receivable_application_id = (
                select max(ra1.receivable_application_id)
                from   ar_receivable_applications ra1
                where  ra1.applied_payment_schedule_id
                     = ra.applied_payment_schedule_id);

  --Primary cursor for processing TRX based claims
  CURSOR get_ra_rec IS
    SELECT distinct ra.applied_payment_schedule_id
    FROM   ar_receivable_applications   ra
    WHERE  ra.applied_payment_schedule_id NOT IN (-4,-1)
    AND    ra.status = 'APP'
    AND    ra.display = 'Y'
    AND    ra.request_id = p_request_id;

  --Get TRX based info from ra_customer_trx and ar_payment_schedules
  --Exclude CLASS=PMT
  CURSOR get_ps_trx_info
    (p_trx_ps_id ar_receivable_applications.applied_payment_schedule_id%type
     ) IS
         SELECT ct.customer_trx_id          --customer_trx_id
               ,ct.trx_number               --trx_number
               ,ct.cust_trx_type_id         --trx_type_id
               ,ct.invoice_currency_code    --currency_code
               ,ct.exchange_rate_type       --exchange_rate_type
               ,ct.exchange_date            --exchange_date
               ,ct.exchange_rate            --exchange_rate
               ,ct.bill_to_customer_id      --customer_id
               ,ct.bill_to_site_use_id      --bill_to_site_use_id
               ,ct.ship_to_site_use_id      --ship_to_site_use_id
               ,ct.primary_salesrep_id      --salesrep_id
               ,ps.amount_due_remaining     --amount_due_remaining
               ,ps.amount_due_original      --amount_due_original
               ,ps.class                    --class
               ,ps.active_claim_flag        --active_claim_flag
               ,ct.legal_entity_id
         FROM   ra_customer_trx ct
               ,ar_payment_schedules ps
         WHERE  ct.customer_trx_id     = ps.customer_trx_id
         AND    ps.payment_schedule_id = p_trx_ps_id
         AND    ps.class              <> 'PMT';

  --Fetch receipt info using payment schedule id of the receipt
  CURSOR get_receipt_info (
    p_receipt_ps_id ar_receivable_applications.payment_schedule_id%type
                          ) IS
         SELECT ps.cash_receipt_id          --cash_receipt_id
               ,cr.receipt_number           --receipt_number
               ,cr.currency_code            --currency_code
               ,cr.exchange_rate_type       --exchange_rate_type
               ,cr.exchange_date            --exchange_date
               ,cr.exchange_rate            --exchange_rate
               ,cr.pay_from_customer        --customer_id
               ,cr.customer_site_use_id     --bill_to_site_use_id
               ,NULL                        --ship_to_site_use_id
 	       ,cr.legal_entity_id
         FROM   ar_payment_schedules        ps
               ,ar_cash_receipts            cr
               ,ar_cash_receipt_history     crh
         WHERE  ps.payment_schedule_id      = p_receipt_ps_id
         AND    cr.cash_receipt_id          = ps.cash_receipt_id
         AND    crh.cash_receipt_id         = cr.cash_receipt_id
         AND    crh.current_record_flag     = 'Y';

  --Fetch receipt info using applied payment schedule id of the trx
  CURSOR get_receipt_num (
    p_receipt_ps_id ar_receivable_applications.applied_payment_schedule_id%type
                         ) IS
         SELECT ps.cash_receipt_id          --cash_receipt_id
               ,cr.receipt_number           --receipt_number
         FROM   ar_payment_schedules        ps
               ,ar_cash_receipts            cr
         WHERE  ps.payment_schedule_id      = p_receipt_ps_id
         AND    cr.cash_receipt_id          = ps.cash_receipt_id;

  --Fetch Receivable application info required for subsequent receipt application
  CURSOR get_trx_app_info
   ( p_trx_ps_id ar_receivable_applications.applied_payment_schedule_id%type
   ) IS
    SELECT SUM(ra.amount_applied), MAX(ra.apply_date)
    FROM   ar_receivable_applications   ra
    WHERE  ra.applied_payment_schedule_id = p_trx_ps_id
    AND    ra.request_id = p_request_id
    AND    ra.status = 'APP'
    AND    ra.display = 'Y';

  -- Fetch the amount_applied from the initial UNAPP record for the cash receipt
  CURSOR unapp_amt_rec
   ( p_cr_id ar_receivable_applications.cash_receipt_id%type
   ) IS
    select ra.amount_applied
    from   ar_receivable_applications ra
          ,ar_distributions ard
    where  ra.cash_receipt_id = p_cr_id
    and    ra.status = 'UNAPP'
    and    nvl(ra.confirmed_flag,'Y') = 'Y'
    and    ra.receivable_application_id = ard.source_id
    and    ard.source_table = 'RA'
    and    ard.source_id_secondary IS NULL;

  -- Fetch the amount_applied from the Paired UNAPP records for the cash receipt
  CURSOR pair_unapp_amt_rec
   ( p_cr_id ar_receivable_applications.cash_receipt_id%type
   ) IS
    select sum(ra.amount_applied)
    from   ar_receivable_applications ra
          ,ar_distributions ard
    where  ra.cash_receipt_id = p_cr_id
    and    ra.status = 'UNAPP'
    and    nvl(ra.confirmed_flag,'Y') = 'Y'
    and    ra.receivable_application_id = ard.source_id
    and    ard.source_table = 'RA'
    and    ard.source_id_secondary IS NOT NULL;

  -- Fetch rapp_id for all application for a full claim creation failure recovery
  CURSOR fail_rec_rapp_id
   ( p_cr_id ar_receivable_applications.cash_receipt_id%type
   ) IS
    select ra.receivable_application_id
    from   ar_receivable_applications ra
    where  ra.cash_receipt_id = p_cr_id
    and    ra.status <> 'UNAPP'
    and    nvl(ra.confirmed_flag,'Y') = 'Y';

  TYPE ra_rec_type IS RECORD (
     l_rowid                      DBMS_SQL.VARCHAR2_TABLE
    ,receivable_application_id    DBMS_SQL.NUMBER_TABLE
    ,amount_applied               DBMS_SQL.NUMBER_TABLE
    ,payment_schedule_id          DBMS_SQL.NUMBER_TABLE
    ,applied_payment_schedule_id  DBMS_SQL.NUMBER_TABLE
    ,applied_customer_trx_id      DBMS_SQL.NUMBER_TABLE
    ,comments                     DBMS_SQL.VARCHAR2_TABLE
    ,attribute_category           DBMS_SQL.VARCHAR2_TABLE
    ,attribute1                   DBMS_SQL.VARCHAR2_TABLE
    ,attribute2                   DBMS_SQL.VARCHAR2_TABLE
    ,attribute3                   DBMS_SQL.VARCHAR2_TABLE
    ,attribute4                   DBMS_SQL.VARCHAR2_TABLE
    ,attribute5                   DBMS_SQL.VARCHAR2_TABLE
    ,attribute6                   DBMS_SQL.VARCHAR2_TABLE
    ,attribute7                   DBMS_SQL.VARCHAR2_TABLE
    ,attribute8                   DBMS_SQL.VARCHAR2_TABLE
    ,attribute9                   DBMS_SQL.VARCHAR2_TABLE
    ,attribute10                  DBMS_SQL.VARCHAR2_TABLE
    ,attribute11                  DBMS_SQL.VARCHAR2_TABLE
    ,attribute12                  DBMS_SQL.VARCHAR2_TABLE
    ,attribute13                  DBMS_SQL.VARCHAR2_TABLE
    ,attribute14                  DBMS_SQL.VARCHAR2_TABLE
    ,attribute15                  DBMS_SQL.VARCHAR2_TABLE
    ,application_ref_num          DBMS_SQL.VARCHAR2_TABLE
    ,secondary_application_ref_id DBMS_SQL.NUMBER_TABLE
    ,application_ref_reason       DBMS_SQL.VARCHAR2_TABLE
    ,customer_reason              DBMS_SQL.VARCHAR2_TABLE
    ,customer_reference           DBMS_SQL.VARCHAR2_TABLE
    ,return_status                DBMS_SQL.VARCHAR2_TABLE
    ,msg_count                    DBMS_SQL.NUMBER_TABLE
    ,msg_data                     DBMS_SQL.VARCHAR2_TABLE
    ,claim_reason_name            DBMS_SQL.VARCHAR2_TABLE
    ,apply_date                   DBMS_SQL.DATE_TABLE --bug 5495310
   );
  claim_tbl            ra_rec_type;
  claim_tbl_null       ra_rec_type;

  TYPE ra_trx_rec_type IS RECORD (
      applied_payment_schedule_id  DBMS_SQL.NUMBER_TABLE
                                 );
  ra_tbl            ra_trx_rec_type;
  ra_tbl_null       ra_trx_rec_type;


  TYPE ra_claim_rec_type IS RECORD (
       receivable_application_id    ar_receivable_applications.receivable_application_id%TYPE
      ,amount_applied               ar_receivable_applications.amount_applied%TYPE
      ,payment_schedule_id          ar_receivable_applications.payment_schedule_id%TYPE
      ,applied_payment_schedule_id  ar_receivable_applications.applied_payment_schedule_id%TYPE
      ,applied_customer_trx_id      ar_receivable_applications.applied_customer_trx_id%TYPE
      ,comments                     ar_receivable_applications.comments%TYPE
      ,attribute_category           ar_receivable_applications.attribute_category%TYPE
      ,attribute1                   ar_receivable_applications.attribute1%TYPE
      ,attribute2                   ar_receivable_applications.attribute2%TYPE
      ,attribute3                   ar_receivable_applications.attribute3%TYPE
      ,attribute4                   ar_receivable_applications.attribute4%TYPE
      ,attribute5                   ar_receivable_applications.attribute5%TYPE
      ,attribute6                   ar_receivable_applications.attribute6%TYPE
      ,attribute7                   ar_receivable_applications.attribute7%TYPE
      ,attribute8                   ar_receivable_applications.attribute8%TYPE
      ,attribute9                   ar_receivable_applications.attribute9%TYPE
      ,attribute10                  ar_receivable_applications.attribute10%TYPE
      ,attribute11                  ar_receivable_applications.attribute11%TYPE
      ,attribute12                  ar_receivable_applications.attribute12%TYPE
      ,attribute13                  ar_receivable_applications.attribute13%TYPE
      ,attribute14                  ar_receivable_applications.attribute14%TYPE
      ,attribute15                  ar_receivable_applications.attribute15%TYPE
      ,application_ref_num          ar_receivable_applications.application_ref_num%TYPE
      ,secondary_application_ref_id ar_receivable_applications.secondary_application_ref_id%TYPE
      ,application_ref_reason       ar_receivable_applications.application_ref_reason%TYPE
      ,customer_reason              ar_receivable_applications.customer_reason%TYPE
      ,customer_reference           ar_receivable_applications.customer_reference%TYPE
      ,return_status                VARCHAR2(1)
      ,msg_count                    NUMBER
      ,msg_data                     VARCHAR2(2000)
      ,claim_reason_name            ar_receivable_applications.application_ref_reason%TYPE
      );
  claim_rec              ra_claim_rec_type;
  claim_rec_null         ra_claim_rec_type;

  l_currency_code           ar_cash_receipts.currency_code%type;
  l_exchange_rate_type      ar_cash_receipts.exchange_rate_type%type;
  l_exchange_rate           ar_cash_receipts.exchange_rate%type;
  l_exchange_date           ar_cash_receipts.exchange_date%type;
  l_customer_id             ar_cash_receipts.pay_from_customer%type;
  l_bill_to_site_use_id     ar_cash_receipts.customer_site_use_id%type;
  l_ship_to_site_use_id     ar_cash_receipts.customer_site_use_id%type;
  l_receipt_number          ar_cash_receipts.receipt_number%type;
  l_cash_receipt_id         ar_cash_receipts.cash_receipt_id%type;
  l_amount_due_remaining    ar_payment_schedules_all.amount_due_remaining%type;
  l_amount_due_original     ar_payment_schedules_all.amount_due_original%type;
  l_class                   ar_payment_schedules_all.class%type;
  l_claim_amount            NUMBER;
  l_customer_trx_id         ra_customer_trx.customer_trx_id%type;
  l_cust_trx_type_id        ra_cust_trx_types.cust_trx_type_id%type;
  l_trx_number              ra_customer_trx.trx_number%type;
  l_salesrep_id             ra_customer_trx.primary_salesrep_id%type;
  l_index                   NUMBER;
  l_bulk_fetch_rows         NUMBER := 400;
  l_last_fetch              BOOLEAN := FALSE;
  l_claim_status            ar_payment_schedules.active_claim_flag%type;
  l_return_status           VARCHAR2(1); --'E','U' = ERROR ;; 'S'=Success;;
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_trx_claim_exist         VARCHAR2(1); --'Y'=Open Claim in TM;; 'N'=No Claim in TM
  l_trx_claim_type          VARCHAR2(1); --'O'=Over Pay Claim;; 'S'=Short Pay Claim
  l_applied_date            ar_receivable_applications.apply_date%TYPE;
  l_applied_action_type     VARCHAR2(1);
  l_amount_applied          ar_receivable_applications.amount_applied%TYPE;
  l_applied_receipt_id      ar_cash_receipts.cash_receipt_id%TYPE;
  l_applied_receipt_number  ar_cash_receipts.receipt_number%TYPE;
  l_object_version_number   NUMBER;
  l_claim_reason_code_id    NUMBER;
  l_claim_reason_name       VARCHAR2(255);
  l_active_claim_flag       ar_payment_schedules.active_claim_flag%TYPE;
  l_unapp_amt_appl          ar_receivable_applications.amount_applied%TYPE;
  l_sum_pair_unapp_amt_appl ar_receivable_applications.amount_applied%TYPE;
  l_legal_entity_id         NUMBER;

  invalid_param          EXCEPTION;
  skip_pmt_record        EXCEPTION;
  skip_overpay_create    EXCEPTION;

  jg_return_status           VARCHAR2(1); --'E','U' = ERROR ;; 'S'=Success;;

BEGIN

  IF PG_DEBUG in ('Y','C') THEN
    arp_standard.debug('ARP_DEDUCTION.claim_creation()+');
  END IF;

  IF (p_request_id IS NULL) THEN

    APP_EXCEPTION.INVALID_ARGUMENT
     ('ARP_DEDUCTION.CLAIM_CREATION'
     ,'P_REQUEST_ID'
     ,'NULL'
     );

    IF PG_DEBUG in ('Y','C') THEN
      arp_standard.debug('Invalid Argument - Request ID is Null');
    END IF;
    RAISE invalid_param;

  END IF;

  ------------------------------------------
  -- x_return_status initialized with 'S'
  -- Will be reset with 'E' or 'U' when
  -- TM API Call return status in 'E' or 'U'
  ------------------------------------------
  x_return_status := 'S';

  ------------------------------------------
  -- Begin Non TRX related claims processing
  -- 1. Create Claim Investigation
  ------------------------------------------
  IF PG_DEBUG in ('Y','C') THEN
    arp_standard.debug('Open Cursor - get_claim_rec');
  END IF;

  OPEN get_claim_rec;
  LOOP  -- Loop thru get_claim_rec

    FETCH get_claim_rec BULK COLLECT INTO
           claim_tbl.l_rowid
          ,claim_tbl.receivable_application_id
          ,claim_tbl.amount_applied
          ,claim_tbl.payment_schedule_id
          ,claim_tbl.applied_payment_schedule_id
          ,claim_tbl.applied_customer_trx_id
          ,claim_tbl.comments
          ,claim_tbl.attribute_category
          ,claim_tbl.attribute1
          ,claim_tbl.attribute2
          ,claim_tbl.attribute3
          ,claim_tbl.attribute4
          ,claim_tbl.attribute5
          ,claim_tbl.attribute6
          ,claim_tbl.attribute7
          ,claim_tbl.attribute8
          ,claim_tbl.attribute9
          ,claim_tbl.attribute10
          ,claim_tbl.attribute11
          ,claim_tbl.attribute12
          ,claim_tbl.attribute13
          ,claim_tbl.attribute14
          ,claim_tbl.attribute15
          ,claim_tbl.application_ref_num
          ,claim_tbl.secondary_application_ref_id
          ,claim_tbl.application_ref_reason
          ,claim_tbl.customer_reason
          ,claim_tbl.customer_reference
          ,claim_tbl.return_status
          ,claim_tbl.msg_count
          ,claim_tbl.msg_data
          ,claim_tbl.claim_reason_name
          ,claim_tbl.apply_date
    LIMIT l_bulk_fetch_rows;

    IF PG_DEBUG in ('Y','C') THEN
      arp_standard.debug('get_claim_rec cursor RowCount =  '||to_char(get_claim_rec%rowcount));
    END IF;

    IF get_claim_rec%NOTFOUND THEN
       l_last_fetch := TRUE;
    END IF;

    IF (claim_tbl.l_rowid.COUNT = 0) AND (l_last_fetch) THEN

      IF PG_DEBUG in ('Y','C') THEN
        arp_standard.debug('Claim_Tbl.Rowid.Count = 0 and Last Fetch is TRUE');
      END IF;
      EXIT;

    END IF;

    FOR i IN claim_tbl.l_rowid.FIRST..claim_tbl.l_rowid.LAST
    LOOP --Loop thru claim_tbl

      -----------------------------
      --Initialize Local Variables
      -----------------------------
      l_currency_code        := NULL;
      l_exchange_rate_type   := NULL;
      l_exchange_rate        := NULL;
      l_exchange_date        := NULL;
      l_customer_id          := NULL;
      l_bill_to_site_use_id  := NULL;
      l_ship_to_site_use_id  := NULL;
      l_receipt_number       := NULL;
      l_cash_receipt_id      := NULL;
      l_customer_trx_id      := NULL;
      l_cust_trx_type_id     := NULL;
      l_trx_number           := NULL;
      l_salesrep_id          := NULL;
      l_claim_status         := NULL;
      l_unapp_amt_appl       := NULL;
      l_sum_pair_unapp_amt_appl := NULL;

      ---------------------------------------------
      -- Fetch Receipt Info for Claim Investigation
      ---------------------------------------------
      IF PG_DEBUG in ('Y','C') THEN
        arp_standard.debug('Open get_receipt_info');
      END IF;
      OPEN get_receipt_info(claim_tbl.payment_schedule_id(i));
      FETCH get_receipt_info INTO
        l_cash_receipt_id
       ,l_receipt_number
       ,l_currency_code
       ,l_exchange_rate_type
       ,l_exchange_date
       ,l_exchange_rate
       ,l_customer_id
       ,l_bill_to_site_use_id
       ,l_ship_to_site_use_id
       ,l_legal_entity_id;
      CLOSE get_receipt_info;

      IF PG_DEBUG in ('Y','C') THEN
        arp_standard.debug('p_amount         => '||to_char(claim_tbl.amount_applied(i)));
        arp_standard.debug('p_currency_code  => '||l_currency_Code);
        arp_standard.debug('p_invoice_ps_id  => '||to_char(claim_tbl.payment_schedule_id(i)));
        arp_standard.debug('p_trx_number     => '||l_trx_number);
        arp_standard.debug('p_receipt_number => '||l_receipt_number);
      END IF;

      ----------------------------------------------
      -- Call create_claim for Non Trx related claim
      ----------------------------------------------
      arp_process_application.create_claim(
         p_amount                => claim_tbl.amount_applied(i)
        ,p_amount_applied        => claim_tbl.amount_applied(i)
        ,p_currency_code         => l_currency_code
        ,p_exchange_rate_type    => l_exchange_rate_type
        ,p_exchange_rate_date    => l_exchange_date
        ,p_exchange_rate         => l_exchange_rate
        ,p_customer_trx_id       => l_customer_trx_id
        ,p_invoice_ps_id         => claim_tbl.payment_schedule_id(i) --Non Trx Based
        ,p_cust_trx_type_id      => l_cust_trx_type_id
        ,p_trx_number            => l_trx_number
        ,p_cust_account_id       => l_customer_id
        ,p_bill_to_site_id       => l_bill_to_site_use_id
        ,p_ship_to_site_id       => l_ship_to_site_use_id
        ,p_salesrep_id           => l_salesrep_id
        ,p_customer_ref_date     => NULL
        ,p_customer_ref_number   => claim_tbl.customer_reference(i)
        ,p_cash_receipt_id       => l_cash_receipt_id
        ,p_receipt_number        => l_receipt_number
        ,p_reason_id             => to_number(claim_tbl.application_ref_reason(i))
        ,p_customer_reason       => claim_tbl.customer_reason(i)
        ,p_comments              => claim_tbl.comments(i)
        ,p_apply_date            => claim_tbl.apply_date(i) --bug 5495310
        ,p_attribute_category    => claim_tbl.attribute_category(i)
        ,p_attribute1            => claim_tbl.attribute1(i)
        ,p_attribute2            => claim_tbl.attribute2(i)
        ,p_attribute3            => claim_tbl.attribute3(i)
        ,p_attribute4            => claim_tbl.attribute4(i)
        ,p_attribute5            => claim_tbl.attribute5(i)
        ,p_attribute6            => claim_tbl.attribute6(i)
        ,p_attribute7            => claim_tbl.attribute7(i)
        ,p_attribute8            => claim_tbl.attribute8(i)
        ,p_attribute9            => claim_tbl.attribute9(i)
        ,p_attribute10           => claim_tbl.attribute10(i)
        ,p_attribute11           => claim_tbl.attribute11(i)
        ,p_attribute12           => claim_tbl.attribute12(i)
        ,p_attribute13           => claim_tbl.attribute13(i)
        ,p_attribute14           => claim_tbl.attribute14(i)
        ,p_attribute15           => claim_tbl.attribute15(i)
        ,x_return_status         => claim_tbl.return_status(i)
        ,x_msg_count             => claim_tbl.msg_count(i)
        ,x_msg_data              => claim_tbl.msg_data(i)
        ,x_claim_id              => claim_tbl.secondary_application_ref_id(i)
        ,x_claim_number          => claim_tbl.application_ref_num(i)
        ,x_claim_reason_name     => claim_tbl.claim_reason_name(i)
	,p_legal_entity_id       => l_legal_entity_id
        );
        IF PG_DEBUG in ('Y','C') THEN
          arp_standard.debug('Short Pay DED # => '||claim_tbl.application_ref_num(i));
        END IF;

        ---------------------------------------------------------------------------
        -- Check TM API Call return status. If E or U then initiate Failure recover
        -- and initiate concurrent log message
        ---------------------------------------------------------------------------
        IF claim_tbl.return_status(i) IN ('E','U') THEN

          ----------------------------------------------------------
          -- Assign the TM API call return status to x_return_status
          -- For PostBatch (ARCABP) to take appropraite action
          -- Assign only when the x_return_status is not 'E' or 'U'
          -- Note : x_return_status is initialized with 'S' before
          --        processing any claims
          ----------------------------------------------------------
          IF (x_return_status = 'S') THEN
            x_return_status := claim_tbl.return_status(i);
          END IF;

          l_claim_status := 'N';

          ------------------------------------------------------------------
          -- Amount applied from initial UNAPP record for the receipt
          -- Used in the determination of full or partial recovery
          ------------------------------------------------------------------
          IF PG_DEBUG in ('Y','C') THEN
           arp_standard.debug('arp_deduction.claim_creation: Fetch amount_aplied from '
                            ||'first UNAPP record for the receipt - Fail Recover');
          END IF;
          OPEN unapp_amt_rec(l_cash_receipt_id);
          FETCH unapp_amt_rec into l_unapp_amt_appl;
          CLOSE unapp_amt_rec;

          ------------------------------------------------------------------
          -- SUM(Amount applied) from the Paired UNAPP records for the receipt
          -- Used in the determination of full or partial recovery
          ------------------------------------------------------------------
          IF PG_DEBUG in ('Y','C') THEN
            arp_standard.debug('arp_deduction.claim_creation: Fetch Sum amount_aplied '
                             ||'from the paired UNAPP records for the receipt - Fail Recover');
          END IF;
          OPEN pair_unapp_amt_rec(l_cash_receipt_id);
          FETCH pair_unapp_amt_rec into l_sum_pair_unapp_amt_appl;
          CLOSE pair_unapp_amt_rec;

          --------------------------------------------------------------------
          -- Recover on Failure - Full or Partial
          -- if the sum(amount_applied) for the paired UNAPP records is less
          -- than the amount_applied from the initial UNAPP record then do a
          -- partial recover else do a full recover
          --------------------------------------------------------------------
          IF l_unapp_amt_appl > l_sum_pair_unapp_amt_appl THEN

             -------------------------------------------------------------
             -- Claim creation in TM failed. Initiate Partial recovery process
             -------------------------------------------------------------
             IF PG_DEBUG in ('Y','C') THEN
               arp_standard.debug('arp_deduction.claim_creation: Fail Recover in Partial');
             END IF;
             arp_deduction.claim_create_fail_recover
               (p_rapp_id => claim_tbl.receivable_application_id(i)
               ,p_cr_id => l_cash_receipt_id
               );

          ELSE -- Full Reversal

             IF PG_DEBUG in ('Y','C') THEN
               arp_standard.debug('arp_deduction.claim_creation: Fail Recover in FULL');
             END IF;
             FOR l_fail_rec in fail_rec_rapp_id(l_cash_receipt_id)
             LOOP

               -------------------------------------------------------------
               -- Claim creation in TM failed. Initiate full recovery process
               -------------------------------------------------------------
               arp_deduction.claim_create_fail_recover
                 (p_rapp_id => l_fail_rec.receivable_application_id
                 ,p_cr_id => l_cash_receipt_id
                 );

             END LOOP; -- FOR l_fail_rec in fail_rec_appi_id(l_cash_receipt_id)

             /*-----------------------------------------+
              |   Initialize return status to SUCCESS   |
              +-----------------------------------------*/
              jg_return_status := FND_API.G_RET_STS_SUCCESS;

             /* in the case of a full reversal, we have to also
                if the localization is installed rollback the
                interest adjustments. */

             jg_ar_receivable_applications.delete_interest_adjustment(
                       p_cash_receipt_id => l_cash_receipt_id,
                       x_return_status => jg_return_status);

             IF jg_return_status <> FND_API.G_RET_STS_SUCCESS then
               /* print an error message */
                arp_standard.debug('Error from jg_ar_receivable_applications.delete_interst_adjustment');
             END IF;

          END IF; -- IF l_unapp_amt_appl > l_sum_pair_unapp_amt_appl THEN

          --------------------------------------------------
          -- Write Failure Message to Concurrent Request Log
          --------------------------------------------------
          arp_deduction.conc_req_log_msg
           ('Claim Investigation - Creation Failure '
           ||' RAPP ID        = '||claim_tbl.receivable_application_id(i)
           ||' Receipt Number = '||l_receipt_number
           ||' PS ID          = '||to_char(claim_tbl.payment_schedule_id(i))
           ||' Claim Amount   = '||to_char(claim_tbl.amount_applied(i))
           );

        ELSE  -- Claim Creation was successful

          l_claim_status := 'Y';
          ---------------------------------------------------------
          -- Update AR_PAYMENT_SCHEDULES.ACTIVE_CLAIM appropriately
          ---------------------------------------------------------
          arp_deduction.update_claim_create_status
           (p_ps_id        => claim_tbl.payment_schedule_id(i)
           ,p_claim_status => l_claim_status
           );

        END IF; --IF claim_tbl.return_status(i) IN ('E','U')

    END LOOP; --Loop thru claim_tbl

    -----------------------------------------------------------------------
    -- Update Receivable Application with claim number and claim id from TM
    -----------------------------------------------------------------------
    IF PG_DEBUG in ('Y','C') THEN
        arp_standard.debug('Bulk Update RA with DED No, ID and translated oracle reason');
    END IF;
    FORALL i IN claim_tbl.l_rowid.FIRST .. claim_tbl.l_rowid.LAST
      UPDATE ar_receivable_applications
      SET    secondary_application_ref_id = claim_tbl.secondary_application_ref_id(i)
            ,application_ref_num          = claim_tbl.application_ref_num(i)
      WHERE  rowid = claim_tbl.l_rowid(i);

    IF l_last_fetch THEN

      IF PG_DEBUG in ('Y','C') THEN
        arp_standard.debug('Exit Loop for Processing Non Trx Related claims. Last Fetch');
      END IF;
      EXIT;

    END IF;  --IF l_last_fetch

  END LOOP; -- Loop thru get_claim_rec
  CLOSE get_claim_rec;  --End of Non Trx related claims processing

  ------------------------------------------------------------------------
  -- Begin TRX related claims processing
  -- 1. Short pay claim creation
  -- 2. Short pay and Over pay, subsequent receipt application
  -- Note: Subsequent receipt application for Over Pay, is for amount zero
  --       which results in claim cancel. No Over Pay claim creation
  ------------------------------------------------------------------------
  IF PG_DEBUG in ('Y','C') THEN
        arp_standard.debug('Determine to process Trx Related Claims');
  END IF;

  IF p_matched_claim_creation_flag = 'Y' THEN

    l_last_fetch := FALSE;

    OPEN get_ra_rec;
    LOOP -- Loop thru cursor get_ra_rec

      IF PG_DEBUG in ('Y','C') THEN
        arp_standard.debug('Bulk fetch cursor get_ra_rec into ra_tbl');
      END IF;

      FETCH get_ra_rec BULK COLLECT INTO
        ra_tbl.applied_payment_schedule_id
      LIMIT l_bulk_fetch_rows;

      IF get_ra_rec%NOTFOUND THEN

        IF PG_DEBUG in ('Y','C') THEN
          arp_standard.debug('LAST Bulk fetch. Set l_last_fetch=TRUE');
        END IF;

        l_last_fetch := TRUE;

      END IF; --IF get_ra_rec%NOTFOUND

      IF (ra_tbl.applied_payment_schedule_id.COUNT = 0) AND (l_last_fetch) THEN

        IF PG_DEBUG in ('Y','C') THEN
          arp_standard.debug('Get_RA_Rec: Count = 0 and Last Bulk Fetch');
        END IF;
        EXIT;

      END IF; --IF (ra_tbl.applied_payment_schedule_id.COUNT = 0) AND (l_last_fetch)

      FOR i IN ra_tbl.applied_payment_schedule_id.FIRST..ra_tbl.applied_payment_schedule_id.LAST
      LOOP   -- Loop thru ra_tbl.applied_payment_schedule_id
      BEGIN

        ----------------------------
        --Initialize Local Variables
        ----------------------------
        IF PG_DEBUG in ('Y','C') THEN
          arp_standard.debug('Processing Trx Related Claim Record = '||to_char(i)||'. Initialize');
        END IF;
        l_customer_trx_id       := NULL;
        l_trx_number            := NULL;
        l_cust_trx_type_id      := NULL;
        l_currency_code         := NULL;
        l_exchange_rate_type    := NULL;
        l_exchange_date         := NULL;
        l_exchange_rate         := NULL;
        l_customer_id           := NULL;
        l_bill_to_site_use_id   := NULL;
        l_ship_to_site_use_id   := NULL;
        l_salesrep_id           := NULL;
        l_amount_due_remaining  := NULL;
        l_amount_due_original   := NULL;
        l_class                 := NULL;
        l_cash_receipt_id       := NULL;
        l_receipt_number        := NULL;
        l_claim_amount          := NULL;
        claim_rec               := claim_rec_null;
        l_claim_status          := NULL;
        l_return_status         := NULL;
        l_msg_count             := NULL;
        l_msg_data              := NULL;
        l_trx_claim_exist       := NULL;
        l_trx_claim_type        := NULL;
        l_applied_date          := NULL;
        l_applied_action_type   := 'A';  --Apply
        l_amount_applied        := NULL;
        l_applied_receipt_id    := NULL;
        l_applied_receipt_number:= NULL;
        l_object_version_number := NULL;
        l_claim_reason_code_id  := NULL;
        l_claim_reason_name     := NULL;

        --------------------------------------------------------------------
        --Fetch PS and Trx info required to determine a short pay/over pay
        --Continue claims processing only if the payment schedule CLASS<>PMT
        --------------------------------------------------------------------
        IF PG_DEBUG in ('Y','C') THEN
          arp_standard.debug('Open cursor get_ps_rtx_info and fetch');
        END IF;

        OPEN get_ps_trx_info(ra_tbl.applied_payment_schedule_id(i));
        FETCH get_ps_trx_info INTO
          l_customer_trx_id
         ,l_trx_number
         ,l_cust_trx_type_id
         ,l_currency_code
         ,l_exchange_rate_type
         ,l_exchange_date
         ,l_exchange_rate
         ,l_customer_id
         ,l_bill_to_site_use_id
         ,l_ship_to_site_use_id
         ,l_salesrep_id
         ,l_amount_due_remaining
         ,l_amount_due_original
         ,l_class
         ,l_active_claim_flag
	 ,l_legal_entity_id;

        -----------------------------------------------------
        -- If Payment Schedule CLASS=PMT then skip processing
        -----------------------------------------------------
        IF get_ps_trx_info%NOTFOUND THEN
          RAISE skip_pmt_record;
        END IF;

        CLOSE get_ps_trx_info;

        IF PG_DEBUG in ('Y','C') THEN
          arp_standard.debug('Amount_due_remaining = '||to_char(l_amount_due_remaining));
          arp_standard.debug('Amount_due_original = '||to_char(l_amount_due_original));
          arp_standard.debug('Class = '||l_class);
          arp_standard.debug('Matched_claim_excl_cm = '||p_matched_claim_excl_cm_flag);
        END IF;

        ---------------------------------------------------------------
        --Determine if amount due remaining for the payment schedule id
        --and if claim to be created is short pay
        --and class <> 'CM' OR class='CM' and matched_claim_excl_cm_flag='N'
        ---------------------------------------------------------------
        IF (  ( (l_amount_due_remaining <> 0)
               OR
                ((l_amount_due_remaining = 0) AND (l_active_claim_flag = 'Y')) )
            AND
              ( (l_class <> 'CM')
               OR
                ((l_class = 'CM') AND (p_matched_claim_excl_cm_flag = 'N')) )
           ) THEN

          --------------------------------------------------------
          --Get RA Info Required for Trx Related Claims processing
          --------------------------------------------------------
          IF PG_DEBUG in ('Y','C') THEN
            arp_standard.debug('Open cursor Get_Ra_info for '
                             ||'PS ID = '||to_char(claim_rec.payment_schedule_id));
          END IF;
          OPEN  get_ra_info(ra_tbl.applied_payment_schedule_id(i));
          FETCH get_ra_info INTO
             claim_rec.receivable_application_id
            ,claim_rec.amount_applied
            ,claim_rec.payment_schedule_id
            ,claim_rec.applied_payment_schedule_id
            ,claim_rec.applied_customer_trx_id
            ,claim_rec.comments
            ,claim_rec.attribute_category
            ,claim_rec.attribute1
            ,claim_rec.attribute2
            ,claim_rec.attribute3
            ,claim_rec.attribute4
            ,claim_rec.attribute5
            ,claim_rec.attribute6
            ,claim_rec.attribute7
            ,claim_rec.attribute8
            ,claim_rec.attribute9
            ,claim_rec.attribute10
            ,claim_rec.attribute11
            ,claim_rec.attribute12
            ,claim_rec.attribute13
            ,claim_rec.attribute14
            ,claim_rec.attribute15
            ,claim_rec.application_ref_num
            ,claim_rec.secondary_application_ref_id
            ,claim_rec.application_ref_reason
            ,claim_rec.customer_reason
            ,claim_rec.customer_reference
            ,claim_rec.return_status
            ,claim_rec.msg_count
            ,claim_rec.msg_data
            ,claim_rec.claim_reason_name;
          CLOSE get_ra_info;

          ---------------------------------------------
          --Fetch Receipt Info - On TRX Related Claim.
          ---------------------------------------------
          IF PG_DEBUG in ('Y','C') THEN
            arp_standard.debug('Open cursor Get_receipt_num and fetch'
                             ||'PS ID = '||to_char(claim_rec.payment_schedule_id));
          END IF;
          OPEN get_receipt_num(claim_rec.payment_schedule_id);
          FETCH get_receipt_num INTO
            l_cash_receipt_id
           ,l_receipt_number;
          CLOSE get_receipt_num;
          IF PG_DEBUG in ('Y','C') THEN
              arp_standard.debug('Close cursor Get_receipt_num and fetch');
          END IF;

	  /*Bug 8584950: OZF procedure verifies l_applied_receipt_id value*/
	  l_applied_receipt_id := l_cash_receipt_id ;
	  l_applied_receipt_number := l_receipt_number;

          --------------------------------------------------------
          -- Claim Amount passed to TM is the amount_due_remaining
          --------------------------------------------------------
          l_claim_amount := l_amount_due_remaining;

          IF PG_DEBUG in ('Y','C') THEN
            arp_standard.debug('Claim Amount => '||to_char(l_claim_amount));
            arp_standard.debug('p_customer_trx_id  => '||to_char(l_customer_trx_id));
            arp_standard.debug('p_invoice_ps_id => '||to_char(claim_rec.payment_schedule_id));
            arp_standard.debug('p_trx_number => '||l_trx_number);
            arp_standard.debug('p_customer_ref_number => '||claim_rec.customer_reference);
            arp_standard.debug('p_cash_receipt_id => '||to_char(l_cash_receipt_id));
            arp_standard.debug('p_receipt_number => '||l_receipt_number);
            arp_standard.debug('p_reason_id => '||claim_rec.application_ref_reason);
          END IF;

          ------------------------------------------------------------
          -- Retreive application info - Amount_Applied, Applied_Date
          ------------------------------------------------------------
          IF PG_DEBUG in ('Y','C') THEN
            arp_standard.debug('Fetch application info for subsequent receipt application');
          END IF;
          OPEN  get_trx_app_info(ra_tbl.applied_payment_schedule_id(i));
          FETCH get_trx_app_info INTO l_amount_applied, l_applied_date;
          CLOSE get_trx_app_info;

          ---------------------------------------------------------------------
          -- Check for claim existence in TM
          -- Based on this result, call to create_claim API (only short pay) or
          -- subsequent receipt API is initiated
          ---------------------------------------------------------------------
          IF (ozf_claim_grp.check_open_claims(l_customer_trx_id,l_cash_receipt_id)) THEN

            l_trx_claim_exist := 'Y'; -- OPEN Claim Exist in TM. Subsequent Receipt App in TM
            IF PG_DEBUG in ('Y','C') THEN
              arp_standard.debug('Call subsequent receipt API. Open claim exist in TM');
            END IF;

          ELSE -- Create TRX based Claim
            l_trx_claim_exist := 'N';  -- Claim Does Not Exist in TM. Claim Creation in TM
            IF PG_DEBUG in ('Y','C') THEN
              arp_standard.debug('Initiate Create Claim API. Open claim Does Not exist in TM');
            END IF;

          END IF; --IF (ozf_claim_grp.check_open_claims(l_customer_trx_id,l_cash_receipt_id))

          --------------------------------------------------------------------
          -- Determine if short pay OR Over pay. This determination will aid
          -- in chosing to perform task specific to Over pay Or Short pay.
          -- IF Over Pay then the claim amount is initialized with 0 amount for
          -- subsequent receipt application. No claim creation for Over Pay.
          --------------------------------------------------------------------
          IF (SIGN(l_claim_amount) = SIGN(l_amount_due_original)) THEN
            l_trx_claim_type := 'S'; --Short Pay Claim

          ELSE -- Over Pay Claim
            l_trx_claim_type := 'O'; --Over Pay Claim
            l_claim_amount   := 0;   --Claim Amount for subsequent receipt Application

          END IF; --IF (SIGN(l_claim_amount) = SIGN(l_amount_due_original))

          IF l_trx_claim_exist = 'Y' THEN
            --------------------------------------------------
            -- Claim Status is set appropriately for
            -- updating AR_PAYMENT_SCHEDULES.ACTIVE_CLAIM_FLAG
            --------------------------------------------------
            IF (l_claim_amount = 0) THEN -- Claim Cancel
              l_claim_status := 'C';
            ELSE                         -- Claim Open
              l_claim_status := 'Y';
            END IF;

            ---------------------------------------------------------
            -- Subsequent Receipt Applcation for Open claims in TM
            -- Call to this routine handles
            -- 1. Claim updates in TM
            -- 2. Insert TRX Notes in AR
            -- 3. Update amount_in_dispute in AR
            ---------------------------------------------------------
            IF PG_DEBUG in ('Y','C') THEN
                arp_standard.debug('Call Subsequent Receipt API. Open Claim exist in TM');
            END IF;
            arp_deduction.update_claim
             (p_claim_id              => claim_rec.secondary_application_ref_id
             ,p_claim_number          => claim_rec.application_ref_num
             ,p_amount                => l_claim_amount
             ,p_currency_code         => l_currency_code
             ,p_exchange_rate_type    => l_exchange_rate_type
             ,p_exchange_rate_date    => l_exchange_date
             ,p_exchange_rate         => l_exchange_rate
             ,p_customer_trx_id       => l_customer_trx_id
             ,p_invoice_ps_id         => claim_rec.applied_payment_schedule_id
             ,p_cust_trx_type_id      => l_cust_trx_type_id
             ,p_trx_number            => l_trx_number
             ,p_cust_account_id       => l_customer_id
             ,p_bill_to_site_id       => l_bill_to_site_use_id
             ,p_ship_to_site_id       => l_ship_to_site_use_id
             ,p_salesrep_id           => l_salesrep_id
             ,p_customer_ref_date     => NULL
             ,p_customer_ref_number   => claim_rec.customer_reference
             ,p_cash_receipt_id       => l_cash_receipt_id
             ,p_receipt_number        => l_receipt_number
             ,p_reason_id             => to_number(claim_rec.application_ref_reason)
             ,p_comments              => claim_rec.comments
             ,p_attribute_category    => claim_rec.attribute_category
             ,p_attribute1            => claim_rec.attribute1
             ,p_attribute2            => claim_rec.attribute2
             ,p_attribute3            => claim_rec.attribute3
             ,p_attribute4            => claim_rec.attribute4
             ,p_attribute5            => claim_rec.attribute5
             ,p_attribute6            => claim_rec.attribute6
             ,p_attribute7            => claim_rec.attribute7
             ,p_attribute8            => claim_rec.attribute8
             ,p_attribute9            => claim_rec.attribute9
             ,p_attribute10           => claim_rec.attribute10
             ,p_attribute11           => claim_rec.attribute11
             ,p_attribute12           => claim_rec.attribute12
             ,p_attribute13           => claim_rec.attribute13
             ,p_attribute14           => claim_rec.attribute14
             ,p_attribute15           => claim_rec.attribute15
             ,p_applied_date          => l_applied_date
             ,p_applied_action_type   => l_applied_action_type
             ,p_amount_applied        => l_amount_applied
             ,p_applied_receipt_id    => l_applied_receipt_id
             ,p_applied_receipt_number=> l_applied_receipt_number
             ,x_return_status         => claim_rec.return_status
             ,x_msg_count             => claim_rec.msg_count
             ,x_msg_data              => claim_rec.msg_data
             ,x_object_version_number => l_object_version_number
             ,x_claim_reason_code_id  => l_claim_reason_code_id
             ,x_claim_reason_name     => l_claim_reason_name
             ,x_claim_id              => claim_rec.secondary_application_ref_id
             ,x_claim_number          => claim_rec.application_ref_num
             );

            IF PG_DEBUG in ('Y','C') THEN
              arp_standard.debug('Object Version Number => '||to_char(l_object_version_number));
            END IF;

          ELSE  -- Open Claim does not exist in TM

            IF l_trx_claim_type = 'S' THEN --Short Pay Claim Creation
              l_claim_status := 'Y';

              ---------------------------------------------
              -- Call create_claim for short pay deduction
              -- Call to this routine handles
              -- 1. Claim creation in TM
              -- 2. Insert into AR TRX Notes
              -- 3. Update amount_in_dispute in AR
              ---------------------------------------------
              IF PG_DEBUG in ('Y','C') THEN
                arp_standard.debug('Call Create Claim API - Short Pay. No Open Claim exist');
              END IF;
              arp_process_application.create_claim
                (p_amount                => l_claim_amount
                ,p_amount_applied        => l_amount_applied
                ,p_currency_code         => l_currency_code
                ,p_exchange_rate_type    => l_exchange_rate_type
                ,p_exchange_rate_date    => l_exchange_date
                ,p_exchange_rate         => l_exchange_rate
                ,p_customer_trx_id       => l_customer_trx_id
                ,p_invoice_ps_id         => claim_rec.applied_payment_schedule_id
                ,p_cust_trx_type_id      => l_cust_trx_type_id
                ,p_trx_number            => l_trx_number
                ,p_cust_account_id       => l_customer_id
                ,p_bill_to_site_id       => l_bill_to_site_use_id
                ,p_ship_to_site_id       => l_ship_to_site_use_id
                ,p_salesrep_id           => l_salesrep_id
                ,p_customer_ref_date     => NULL
                ,p_customer_ref_number   => claim_rec.customer_reference
                ,p_cash_receipt_id       => l_cash_receipt_id
                ,p_receipt_number        => l_receipt_number
                ,p_reason_id             => to_number(claim_rec.application_ref_reason)
                ,p_customer_reason       => claim_rec.customer_reason
                ,p_comments              => claim_rec.comments
                ,p_apply_date            => l_applied_date  --Bug 5495310
                ,p_attribute_category    => claim_rec.attribute_category
                ,p_attribute1            => claim_rec.attribute1
                ,p_attribute2            => claim_rec.attribute2
                ,p_attribute3            => claim_rec.attribute3
                ,p_attribute4            => claim_rec.attribute4
                ,p_attribute5            => claim_rec.attribute5
                ,p_attribute6            => claim_rec.attribute6
                ,p_attribute7            => claim_rec.attribute7
                ,p_attribute8            => claim_rec.attribute8
                ,p_attribute9            => claim_rec.attribute9
                ,p_attribute10           => claim_rec.attribute10
                ,p_attribute11           => claim_rec.attribute11
                ,p_attribute12           => claim_rec.attribute12
                ,p_attribute13           => claim_rec.attribute13
                ,p_attribute14           => claim_rec.attribute14
                ,p_attribute15           => claim_rec.attribute15
                ,x_return_status         => claim_rec.return_status
                ,x_msg_count             => claim_rec.msg_count
                ,x_msg_data              => claim_rec.msg_data
                ,x_claim_id              => claim_rec.secondary_application_ref_id
                ,x_claim_number          => claim_rec.application_ref_num
                ,x_claim_reason_name     => claim_rec.claim_reason_name
		,p_legal_entity_id       => l_legal_entity_id
                );

              IF PG_DEBUG in ('Y','C') THEN
                arp_standard.debug('Short Pay DED # => '||claim_rec.application_ref_num);
              END IF;

            ELSE -- Over Pay Claim
              IF PG_DEBUG in ('Y','C') THEN
                arp_standard.debug('Over Pay condition - Claim will not be created.');
              END IF;
              RAISE skip_overpay_create;

            END IF; --IF l_trx_claim_type = 'S' THEN

          END IF; --IF l_trx_claim_exist = 'Y' THEN

          ------------------------------------
          -- Check TM API Call return status
          ------------------------------------
          IF claim_rec.return_status = 'S' THEN  --TM API Return Status = Success

            --------------------------------------------------------------------------
            -- Update Payment Schedules with apporpriate claim status in TM
            -- AR_PAYMENT_SCHEDULES.ACTIVE_CLAIM = 'C' for subsequent receipt
            -- application of Over Pay Claim.
            -- AR_PAYMENT_SCHEDULES.ACTIVE_CLAIM = 'Y' for Short Pay Claim Creation
            --------------------------------------------------------------------------
            IF (  ((l_trx_claim_type = 'S') AND (l_trx_claim_exist = 'N'))
                OR ((l_trx_claim_exist = 'Y') AND (l_claim_amount = 0))
               ) THEN

              IF PG_DEBUG in ('Y','C') THEN
                arp_standard.debug('Update PS with active_claim_flag = C');
              END IF;
              arp_deduction.update_claim_create_status
               (p_ps_id        => claim_rec.applied_payment_schedule_id
               ,p_claim_status => l_claim_status
               );

            END IF; --IF l_trx_claim_type = 'S' AND l_trx_claim_exist = 'N' THEN


            ---------------------------------------------------------------------------
            --Update Receivable Application with Claim No, ID, Rec TRX id, Appl Ref Type
            ---------------------------------------------------------------------------
            IF (  ((l_trx_claim_type = 'S') AND (l_trx_claim_exist = 'N'))
                OR (l_trx_claim_exist = 'Y')
               ) THEN

              IF PG_DEBUG in ('Y','C') THEN
                arp_standard.debug('Update RA with Ded No,Ded ID,Type,receivables_trx_id');
              END IF;
              UPDATE ar_receivable_applications
              SET    secondary_application_ref_id = claim_rec.secondary_application_ref_id
                    ,application_ref_num          = claim_rec.application_ref_num
                    ,application_ref_type         = 'CLAIM'
                    ,receivables_trx_id           = ARP_DEDUCTION.GET_RECEIVABLES_TRX_ID(l_cash_receipt_id)
              WHERE  applied_payment_schedule_id  = claim_rec.applied_payment_schedule_id
              AND    applied_customer_trx_id      = claim_rec.applied_customer_trx_id;

            END IF; --IF l_trx_claim_type = 'S' AND l_trx_claim_exist = 'N' THEN

          ELSE -- TM API Return_Status = ERROR

            ----------------------------------------------------------
            -- Assign the TM API call return status to x_return_status
            -- For PostBatch (ARCABP) to take appropraite action
            -- Assign only when the x_return_status is not 'E' or 'U'
            -- Note : x_return_status is initialized with 'S' before
            --        processing any claims
            ----------------------------------------------------------
            IF (x_return_status = 'S') THEN
              x_return_status := claim_rec.return_status;
            END IF;

            l_claim_status := 'N';
            IF PG_DEBUG in ('Y','C') THEN
              arp_standard.debug('EXCEPTION - TM API : OZF_Claim_GRP ');
            END IF;

            --------------------------------------------------
            -- Write Failure Message to Concurrent Request Log
            --------------------------------------------------
            IF l_trx_claim_type = 'S' AND l_trx_claim_exist = 'N' THEN
              ---------------------------------------
              -- Specific to Short Pay Claim Creation
              ---------------------------------------
              arp_deduction.conc_req_log_msg
               ('Short Pay Claim Creation Failure - '
               ||' Receipt Number = '||l_receipt_number
               ||' Applied Payment Schedule ID = '
               ||to_char(claim_rec.applied_payment_schedule_id)
               ||' TRX Number = '||l_trx_number
               ||' Claim Amount = '||to_char(l_claim_amount)
               );

            ELSIF l_trx_claim_exist = 'Y' THEN
              ---------------------------------------------
              -- Specific to Subsequent Receipt Application
              ---------------------------------------------
              arp_deduction.conc_req_log_msg
               ('Subsequent Receipt Application Failure - '
               ||' Receipt Number = '||l_receipt_number
               ||' Receipt ID = '||l_cash_receipt_id
               ||' Claim ID = '||to_char(claim_rec.secondary_application_ref_id)
               ||' Claim Number = '||claim_rec.application_ref_num
               ||' Claim Amount = '||to_char(l_claim_amount)
               ||' TRX Number = '||l_trx_number
               ||' Cust TRX ID = '||to_char(l_customer_trx_id)
               ||' Cust TRX Type ID = '||to_char(l_cust_trx_type_id)
               ||' Invoice PS ID = '
               ||to_char(claim_rec.applied_payment_schedule_id)
               );

            END IF; --l_trx_claim_type = 'S' AND l_trx_claim_exist = 'Y' THEN

          END IF; --IF claim_rec.return_status = 'S' THEN

        END IF; --IF l_amount_due_remaining <> 0 And Short Pay Claim And Class qualified

      EXCEPTION
        WHEN skip_overpay_create THEN

         IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('EXCEPTION - Skip_overpay_create : Trx Related - '||
                              'Over Pay claim doesnot exist in TM.');
         END IF;

        WHEN skip_pmt_record THEN

         IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('EXCEPTION - Skip_PMT_Record : Non Trx Related - '||
                              'Payment Schedule CLASS=PMT. Skip processing this record.');
         END IF;

      END;
      END LOOP; -- Loop thru ra_tbl.applied_payment_schedule_id

      --If Recent Fetch is Last then exit loop
      IF l_last_fetch THEN

        IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('l_last_fetch=TRUE. Exit Loop for processing Non Trx claims');
        END IF;
        EXIT;

      END IF; --IF l_last_fetch

    END LOOP;  -- Loop thru cursor get_ra_rec
    CLOSE get_ra_rec;

  END IF; --IF p_matched_claim_creation_flag = 'Y' THEN

  IF PG_DEBUG in ('Y','C') THEN
    arp_standard.debug('ARP_DEDUCTION.claim_creation()-');
  END IF;

EXCEPTION
  WHEN invalid_param THEN

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('EXCEPTION - invalid_param : ARP_DEDUCTION.CLAIM_CREATION');
    END IF;
    RAISE;

  WHEN OTHERS THEN

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('EXCEPTION - OTHERS : ARP_DEDUCTION.CLAIM_CREATION');
    END IF;
    RAISE;

END claim_creation;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_claim                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Calls iClaim group API to update a deduction claim.                    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED -                                 |
 |      OZF_Claim_GRP.Update_Deduction - Group API to update a claim from AR |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT: X_RETURN_STATUS ('S' for success, 'E' or 'U' for Error  |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   CTHANGAI    03-FEB-2003  Created                                        |
 |   CTHANGAI    27-FEB-2003  Added OUT parameters x_claim_id,x_claim_number |
 +===========================================================================*/
PROCEDURE update_claim
            ( p_claim_id               IN NUMBER
            , p_claim_number           IN VARCHAR2
            , p_amount                 IN  NUMBER
            , p_currency_code          IN  VARCHAR2
            , p_exchange_rate_type     IN  VARCHAR2
            , p_exchange_rate_date     IN  DATE
            , p_exchange_rate          IN  NUMBER
            , p_customer_trx_id        IN  NUMBER
            , p_invoice_ps_id          IN  NUMBER
            , p_cust_trx_type_id       IN  NUMBER
            , p_trx_number             IN  VARCHAR2
            , p_cust_account_id        IN  NUMBER
            , p_bill_to_site_id        IN  NUMBER
            , p_ship_to_site_id        IN  NUMBER
            , p_salesrep_id            IN  NUMBER
            , p_customer_ref_date      IN  DATE
            , p_customer_ref_number    IN  VARCHAR2
            , p_cash_receipt_id        IN  NUMBER
            , p_receipt_number         IN  VARCHAR2
            , p_reason_id              IN  NUMBER
            , p_comments               IN  VARCHAR2
            , p_attribute_category     IN  VARCHAR2
            , p_attribute1             IN  VARCHAR2
            , p_attribute2             IN  VARCHAR2
            , p_attribute3             IN  VARCHAR2
            , p_attribute4             IN  VARCHAR2
            , p_attribute5             IN  VARCHAR2
            , p_attribute6             IN  VARCHAR2
            , p_attribute7             IN  VARCHAR2
            , p_attribute8             IN  VARCHAR2
            , p_attribute9             IN  VARCHAR2
            , p_attribute10            IN  VARCHAR2
            , p_attribute11            IN  VARCHAR2
            , p_attribute12            IN  VARCHAR2
            , p_attribute13            IN  VARCHAR2
            , p_attribute14            IN  VARCHAR2
            , p_attribute15            IN  VARCHAR2
            , p_applied_date           IN  DATE
            , p_applied_action_type    IN  VARCHAR2
            , p_amount_applied         IN  NUMBER
            , p_applied_receipt_id     IN  NUMBER
            , p_applied_receipt_number IN  VARCHAR2
            , x_return_status          OUT NOCOPY VARCHAR2
            , x_msg_count              OUT NOCOPY NUMBER
            , x_msg_data               OUT NOCOPY VARCHAR2
            , x_object_version_number  OUT NOCOPY NUMBER
            , x_claim_reason_code_id   OUT NOCOPY NUMBER
            , x_claim_reason_name      OUT NOCOPY VARCHAR2
            , x_claim_id               OUT NOCOPY NUMBER
            , x_claim_number           OUT NOCOPY VARCHAR2
            ) IS

  l_claim_rec               OZF_Claim_GRP.Deduction_Rec_Type;
  l_return_status           VARCHAR2(1);
  l_text                    VARCHAR2(2000);
  l_user_id                 NUMBER;
  l_last_update_login       NUMBER;
  l_sysdate                 DATE;
  l_note_id                 NUMBER;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('update_action: ' ||  'arp_deduction.update_claim()+' );
  END IF;

  x_return_status                      := 'S';
  l_claim_rec.claim_id                 := p_claim_id;
  l_claim_rec.claim_number             := p_claim_number;
  l_claim_rec.claim_type_id            := NULL;
  l_claim_rec.claim_date               := NULL;
  l_claim_rec.due_date                 := NULL;
  l_claim_rec.amount                   := p_amount;
  l_claim_rec.currency_code            := p_currency_code;
  l_claim_rec.exchange_rate_type       := p_exchange_rate_type;
  l_claim_rec.exchange_rate_date       := p_exchange_rate_date;
  l_claim_rec.exchange_rate            := p_exchange_rate;
  l_claim_rec.set_of_books_id          := arp_global.set_of_books_id;
  l_claim_rec.source_object_id         := p_customer_trx_id;
  l_claim_rec.source_object_type_id    := p_cust_trx_type_id;
  l_claim_rec.source_object_class      := 'INVOICE';
  l_claim_rec.source_object_number     := p_trx_number;
  l_claim_rec.cust_account_id          := p_cust_account_id;
  l_claim_rec.cust_billto_acct_site_id := p_bill_to_site_id;
  l_claim_rec.cust_shipto_acct_site_id := p_ship_to_site_id;
  l_claim_rec.sales_rep_id             := p_salesrep_id;
  l_claim_rec.reason_code_id           := p_reason_id;
  l_claim_rec.customer_ref_date        := p_customer_ref_date;
  l_claim_rec.customer_ref_number      := p_customer_ref_number;
  l_claim_rec.receipt_id               := p_cash_receipt_id;
  l_claim_rec.receipt_number           := p_receipt_number;
  l_claim_rec.comments                 := p_comments;
  l_claim_rec.deduction_attribute_category := p_attribute_category;
  l_claim_rec.deduction_attribute1     := p_attribute1;
  l_claim_rec.deduction_attribute2     := p_attribute2;
  l_claim_rec.deduction_attribute3     := p_attribute3;
  l_claim_rec.deduction_attribute4     := p_attribute4;
  l_claim_rec.deduction_attribute5     := p_attribute5;
  l_claim_rec.deduction_attribute6     := p_attribute6;
  l_claim_rec.deduction_attribute7     := p_attribute7;
  l_claim_rec.deduction_attribute8     := p_attribute8;
  l_claim_rec.deduction_attribute9     := p_attribute9;
  l_claim_rec.deduction_attribute10    := p_attribute10;
  l_claim_rec.deduction_attribute11    := p_attribute11;
  l_claim_rec.deduction_attribute12    := p_attribute12;
  l_claim_rec.deduction_attribute13    := p_attribute13;
  l_claim_rec.deduction_attribute14    := p_attribute14;
  l_claim_rec.deduction_attribute15    := p_attribute15;
  l_claim_rec.applied_date             := p_applied_date;
  l_claim_rec.applied_action_type      := p_applied_action_type;
  l_claim_rec.amount_applied           := p_amount_applied;
  l_claim_rec.applied_receipt_id       := p_applied_receipt_id;
  l_claim_rec.applied_receipt_number   := p_applied_receipt_number;

  -------------------------------------------------
  -- Call TM API for Subsequent Receipt Application
  -------------------------------------------------
  OZF_Claim_GRP.Update_Deduction
             (p_api_version_number    => 1.0
             ,p_init_msg_list         => FND_API.G_TRUE
             ,p_commit                => FND_API.G_FALSE
             ,x_return_status         => l_return_status
             ,x_msg_count             => x_msg_count
             ,x_msg_data              => x_msg_data
             ,p_deduction             => l_claim_rec
             ,x_object_version_number => x_object_version_number
             ,x_claim_reason_code_id  => x_claim_reason_code_id
             ,x_claim_reason_name     => x_claim_reason_name
             ,x_claim_id              => x_claim_id
             ,x_claim_number          => x_claim_number
             );

  IF l_return_status = FND_API.G_RET_STS_SUCCESS  THEN

    x_return_status := 'S';
    IF (p_customer_trx_id IS NOT NULL) AND (p_customer_trx_id > 0) THEN

      --------------------
      -- Insert Trx Notes
      --------------------
      IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('insert_trx_notes: arp_deduction.update_claim');
      END IF;

      l_text := 'RECEIPT_NUM : '||p_receipt_number||' CLAIM_NUM : '
               ||p_claim_number||' TRX_NUM : '||p_trx_number;

      l_user_id := arp_standard.profile.user_id;
      l_last_update_login := arp_standard.profile.last_update_login;
      l_sysdate := SYSDATE;

      arp_notes_pkg.insert_cover(
        p_note_type              => 'MAINTAIN',
        p_text                   => l_text,
        p_customer_call_id       => NULL,
        p_customer_call_topic_id => NULL,
        p_call_action_id         => NULL,
        p_customer_trx_id        => p_customer_trx_id,
        p_note_id                => l_note_id,
        p_last_updated_by        => l_user_id,
        p_last_update_date       => l_sysdate,
        p_last_update_login      => l_last_update_login,
        p_created_by             => l_user_id,
        p_creation_date          => l_sysdate);

      IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('insert_trx_notes: Note ID = '||to_char(l_note_id));
      END IF;

      --
      -- Update TRX Amount in Dispute
      --
      IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('put_trx_in_dispute: arp_deduction.update_claim');
      END IF;
      arp_process_application.update_dispute_on_trx
       (p_invoice_ps_id
       ,'Y'              --p_active_claim
       ,p_amount_applied
       );

    END IF; -- IF (p_customer_trx_id IS NOT NULL) AND (p_customer_trx_id > 0)

  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    x_return_status := 'E';

  ELSE --Unidentified Error
    x_return_status := 'U';

  END IF; --IF l_return_status = FND_API.G_RET_STS_SUCCESS

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug('update_action: arp_deduction.update_claim()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('update_action: EXCEPTION: arp_deduction.update_claim');
    END IF;
    RAISE;

END update_claim;


/*===========================================================================+
 | PUBLIC PROCEDURE                                                          |
 |    create_claims_rapp_dist                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure for creating claims related RA and associated Distributions  |
 |    Insert 2 RA rows - One as -ve UNAPP row and the second as 'OTHER ACC'  |
 |    The on-account ACC row is similar to the 'OTHER ACC'.                  |
 |    This new procedure is introduced for creating special applications like|
 |    claim.The RA records for 'ACC' or 'OTHER ACC' are created first along  |
 |    with thier corresponding distributions records. After which the        |
 |    negative UNAPP record is created along with its PAIRED distribution    |
 |    record.                                                                |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED -                                 |
 |   arp_app_pkg.insert_p - Insert a row into RA table                       |
 |   arp_acct_main.Create_Acct_Entry - Insert a row into Distributions table |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                                                                           |
 |              OUT: x_return_status (S=Success; E=Error/Failure             |
 |			                                                     |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES  -                                                                  |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 | 13-JAN-03    CTHANGAI      Created                                        |
 | 21-JAN-03    CTHANGAI      Added parameter receivables_trx_id             |
 | 05-FEB-03    CTHANGAI      Removed paramter application_ref_reason        |
 | 10-FEB-03    CTHANGAI      Initialize customer_reference with NULL        |
 |                            before creating UNAPP records in               |
 |                            ar_receivable_applications                     |
 | 13-FEB-03    CTHANGAI      Removed paramter applied_payment_schedule_id   |
 | 14-FEB-03    CTHANGAI      Initialize receivable_trx_id with NULL for ACC |
 | 18-FEB-03    CTHANGAI      On Exception write message to concurrent log   |
 | 19-FEB-03    CTHANGAI      Defualt program_application_id = 222           |
 | 24-FEB-03    CTHANGAI      Defualt postable='Y' for Claim Investigation   |
 | 24-FEB-03    CTHANGAI      On_Account_Customer populated only for ACC     |
 +===========================================================================*/
 PROCEDURE create_claims_rapp_dist
  (p_cash_receipt_id        IN  ar_receivable_applications.cash_receipt_id%TYPE
  ,p_unapp_ccid             IN  ar_receivable_applications.code_combination_id%TYPE
  ,p_other_acc_ccid         IN  ar_receivable_applications.code_combination_id%TYPE
  ,p_acc_ccid               IN  ar_receivable_applications.code_combination_id%TYPE
  ,p_gl_date                IN  ar_receivable_applications.gl_date%TYPE
  ,p_status                 IN  ar_receivable_applications.status%TYPE
  ,p_amount_applied         IN  ar_receivable_applications.amount_applied%TYPE
  ,p_created_by             IN  ar_receivable_applications.created_by%TYPE
  ,p_creation_date          IN  ar_receivable_applications.creation_date%TYPE
  ,p_last_updated_by        IN  ar_receivable_applications.last_updated_by%TYPE
  ,p_program_application_id IN  ar_receivable_applications.program_application_id%TYPE
  ,p_program_id             IN  ar_receivable_applications.program_id%TYPE
  ,p_request_id             IN  ar_receivable_applications.request_id%TYPE
  ,p_sob_id                 IN  ar_receivable_applications.set_of_books_id%TYPE
  ,p_apply_date             IN  ar_receivable_applications.apply_date%TYPE
  ,p_ussgl_transaction_code IN  ar_receivable_applications.ussgl_transaction_code%TYPE
  ,p_receipt_ps_id          IN  ar_receivable_applications.payment_schedule_id%TYPE
  ,p_unapp_application_rule IN  ar_receivable_applications.application_rule%TYPE
  ,p_other_application_rule IN  ar_receivable_applications.application_rule%TYPE
  ,p_acc_application_rule   IN  ar_receivable_applications.application_rule%TYPE
  ,p_on_account_customer    IN  ar_receivable_applications.on_account_customer%TYPE
  ,p_receivables_trx_id     IN  ar_receivable_applications.receivables_trx_id%TYPE
  ,p_customer_reference     IN  ar_receivable_applications.customer_reference%TYPE
  ,p_customer_reason        IN  ar_receivable_applications.customer_reason%TYPE
  ,p_attribute_category     IN  ar_receivable_applications.attribute_category%TYPE
  ,p_attribute1             IN  ar_receivable_applications.attribute1%TYPE
  ,p_attribute2             IN  ar_receivable_applications.attribute2%TYPE
  ,p_attribute3             IN  ar_receivable_applications.attribute3%TYPE
  ,p_attribute4             IN  ar_receivable_applications.attribute4%TYPE
  ,p_attribute5             IN  ar_receivable_applications.attribute5%TYPE
  ,p_attribute6             IN  ar_receivable_applications.attribute6%TYPE
  ,p_attribute7             IN  ar_receivable_applications.attribute7%TYPE
  ,p_attribute8             IN  ar_receivable_applications.attribute8%TYPE
  ,p_attribute9             IN  ar_receivable_applications.attribute9%TYPE
  ,p_attribute10            IN  ar_receivable_applications.attribute10%TYPE
  ,p_attribute11            IN  ar_receivable_applications.attribute11%TYPE
  ,p_attribute12            IN  ar_receivable_applications.attribute12%TYPE
  ,p_attribute13            IN  ar_receivable_applications.attribute13%TYPE
  ,p_attribute14            IN  ar_receivable_applications.attribute14%TYPE
  ,p_attribute15            IN  ar_receivable_applications.attribute15%TYPE
  ,x_return_status          OUT NOCOPY VARCHAR2
  ) IS

  l_ra_rec                 ar_receivable_applications%ROWTYPE;
  l_prev_app_id            ar_receivable_applications.receivable_application_id%TYPE;
  l_ae_doc_rec             ARP_ACCT_MAIN.ae_doc_rec_type;
  l_xla_ev_rec      		arp_xla_events.xla_events_type;
  l_msg_data               VARCHAR2(2000);

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('arp_deduction.create_claims_rapp_dist()+' );
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('p_receipt_ps_id = '||TO_CHAR(p_receipt_ps_id));
       arp_standard.debug('p_amount_applied = '||TO_CHAR( p_amount_applied ) );
       --arp_standard.debug('p_gl_date = '|| TO_CHAR( p_gl_date ) );
       --arp_standard.debug('p_apply_date = '|| TO_CHAR( p_apply_date ) );
    END IF;

    -- ---------------------------------------------------------------------
    -- Prepare for 'ACC' and 'OTHER ACC' record insertion with +ve amount applied
    -- applied_customer_trx_id = -1 and display = 'Y'
    -- ---------------------------------------------------------------------
    l_msg_data                         := 'Initialize local reccord type with parameter.';
    l_ra_rec.cash_receipt_id           := p_cash_receipt_id;
    l_ra_rec.receivable_application_id := NULL;
    l_ra_rec.gl_date                   := p_gl_date;
    l_ra_rec.status                    := p_status;
    l_ra_rec.amount_applied            := p_amount_applied;
    l_ra_rec.acctd_amount_applied_from := p_amount_applied;
    l_ra_rec.created_by                := p_created_by;
    l_ra_rec.creation_date             := p_creation_date;
    l_ra_rec.last_updated_by           := p_last_updated_by;
    l_ra_rec.last_update_date          := SYSDATE;
    l_ra_rec.program_application_id    := 222; --p_program_application_id;
    l_ra_rec.program_id	               := p_program_id;
    l_ra_rec.program_update_date       := SYSDATE;
    l_ra_rec.request_id	               := p_request_id;
    l_ra_rec.display                   := 'Y';
    l_ra_rec.set_of_books_id           := p_sob_id;
    l_ra_rec.apply_date                := p_apply_date;
    l_ra_rec.application_type          := 'CASH';
    l_ra_rec.posting_control_id        := -3;
    l_ra_rec.ussgl_transaction_code    := p_ussgl_transaction_code;
    l_ra_rec.payment_schedule_id       := p_receipt_ps_id;
    l_ra_rec.application_rule          := p_unapp_application_rule;
    l_ra_rec.applied_customer_trx_id   := -1;
    l_ra_rec.attribute_category        := p_attribute_category;
    l_ra_rec.attribute1                := p_attribute1;
    l_ra_rec.attribute2                := p_attribute2;
    l_ra_rec.attribute3                := p_attribute3;
    l_ra_rec.attribute4                := p_attribute4;
    l_ra_rec.attribute5                := p_attribute5;
    l_ra_rec.attribute6                := p_attribute6;
    l_ra_rec.attribute7                := p_attribute7;
    l_ra_rec.attribute8                := p_attribute8;
    l_ra_rec.attribute9                := p_attribute9;
    l_ra_rec.attribute10               := p_attribute10;
    l_ra_rec.attribute11               := p_attribute11;
    l_ra_rec.attribute12               := p_attribute12;
    l_ra_rec.attribute13               := p_attribute13;
    l_ra_rec.attribute14               := p_attribute14;
    l_ra_rec.attribute15               := p_attribute15;
    l_ra_rec.customer_reference        := p_customer_reference;
    l_ra_rec.customer_reason           := p_customer_reason;

    ----------------------------------------------------
    --  Assign values appropriate to 'ACC' or 'OTHER ACC'
    ----------------------------------------------------
    IF p_status = 'OTHER ACC' THEN
      l_ra_rec.applied_payment_schedule_id := -4;
      l_ra_rec.code_combination_id         := p_other_acc_ccid;
      l_ra_rec.application_ref_type        := 'CLAIM';
      l_ra_rec.application_rule            := p_other_application_rule;
      l_ra_rec.receivables_trx_id          := p_receivables_trx_id;
      l_ra_rec.postable                    := 'Y';
      l_ra_rec.on_account_customer         := NULL;
    ELSIF p_status = 'ACC' THEN
      l_ra_rec.applied_payment_schedule_id := -1;
      l_ra_rec.code_combination_id         := p_acc_ccid;
      l_ra_rec.application_ref_type        := NULL;
      l_ra_rec.application_rule            := p_acc_application_rule;
      l_ra_rec.receivables_trx_id          := NULL;
      l_ra_rec.postable                    := NULL;
      l_ra_rec.on_account_customer         := p_on_account_customer;
    END IF;

    -- ---------------------------------------------------------------------
    -- Insert 'OTHER ACC' OR 'ACC' record into AR_RECEIVABLE_APPLICATIONS
    -- ---------------------------------------------------------------------
    arp_app_pkg.insert_p( l_ra_rec, l_ra_rec.receivable_application_id );

	IF l_ra_rec.receivable_application_id  IS NOT NULL THEN

	    arp_standard.debug('Before calling ARP_XLA_EVENTS.create_events....');

       l_xla_ev_rec.xla_from_doc_id := l_ra_rec.receivable_application_id;
	   l_xla_ev_rec.xla_to_doc_id   := l_ra_rec.receivable_application_id;

	   l_xla_ev_rec.xla_mode        := 'O';
	   l_xla_ev_rec.xla_call        := 'B';
	   l_xla_ev_rec.xla_doc_table := 'APP';
	   ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);

	   arp_standard.debug('Processessed following RA row :receivable_application_id : '|| l_ra_rec.receivable_application_id);

	   END IF;

    ------------------------------------------------------------------------
    -- Replicate MRC data if necessary
    ------------------------------------------------------------------------
    ar_mrc_engine3.insert_ra_rec_quickcash(
            p_rec_app_id       =>  l_ra_rec.receivable_application_id);

    -- ---------------------------------------------------------------------
    -- Store APP id for PAIRING
    -- ---------------------------------------------------------------------
    l_prev_app_id := l_ra_rec.receivable_application_id;

    -- ---------------------------------------------------------------------
    -- Create 'OTHER ACC' OR 'ACC' record accounting in ar_distributions
    -- ---------------------------------------------------------------------
    l_ae_doc_rec.document_type             := 'RECEIPT';
    l_ae_doc_rec.document_id               := l_ra_rec.cash_receipt_id;
    l_ae_doc_rec.accounting_entity_level   := 'ONE';
    l_ae_doc_rec.source_table              := 'RA';
    l_ae_doc_rec.source_id                 := l_ra_rec.receivable_application_id;
    l_ae_doc_rec.source_id_old             := '';
    l_ae_doc_rec.other_flag                := '';
    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

    -- ---------------------------------------------------------------------
    -- Prepare for 'UNAPP' record insertion with -ve amount applied
    -- applied_customer_trx_id and applied_payment_schedule_id is NULL
    -- display = 'N'
    -- ---------------------------------------------------------------------
    l_ra_rec.receivable_application_id   := NULL; --Sequence generated while insert
    l_ra_rec.applied_customer_trx_id     := NULL;
    l_ra_rec.display                     := 'N';
    l_ra_rec.on_account_customer         := NULL;
    l_ra_rec.customer_reference          := NULL;
    l_ra_rec.customer_reason             := NULL;
    l_ra_rec.receivables_trx_id          := NULL;
    l_ra_rec.amount_applied              := -p_amount_applied;
    l_ra_rec.acctd_amount_applied_from   := -p_amount_applied;
    l_ra_rec.applied_payment_schedule_id := NULL;
    l_ra_rec.code_combination_id         := p_unapp_ccid;
    l_ra_rec.status                      := 'UNAPP';
    l_ra_rec.application_ref_type        := NULL;
    l_ra_rec.application_rule            := p_unapp_application_rule;

    -- ---------------------------------------------------------------------
    -- Insert Negative UNAPP record
    -- ---------------------------------------------------------------------
    arp_app_pkg.insert_p( l_ra_rec, l_ra_rec.receivable_application_id );

	IF l_ra_rec.receivable_application_id  IS NOT NULL THEN

	    arp_standard.debug('Before calling ARP_XLA_EVENTS.create_events....');

       l_xla_ev_rec.xla_from_doc_id := l_ra_rec.receivable_application_id;
	   l_xla_ev_rec.xla_to_doc_id   := l_ra_rec.receivable_application_id;

	   l_xla_ev_rec.xla_mode        := 'O';
	   l_xla_ev_rec.xla_call        := 'B';
	   l_xla_ev_rec.xla_doc_table := 'APP';
	   ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);

	   arp_standard.debug('Processessed following RA row :receivable_application_id : '|| l_ra_rec.receivable_application_id);

	   END IF;

    ------------------------------------------------------------------------
    -- Replicate MRC data if necessary
    ------------------------------------------------------------------------
       ar_mrc_engine3.create_matching_unapp_records(
                      p_rec_app_id   => l_prev_app_id,
                      p_rec_unapp_id => l_ra_rec.receivable_application_id);
   --

    -- ---------------------------------------------------------------------
    -- Create paired UNAPP record accounting in ar_distributions
    -- ---------------------------------------------------------------------
    l_ae_doc_rec.source_id_old        := l_prev_app_id;
    l_ae_doc_rec.source_id            := l_ra_rec.receivable_application_id;
    l_ae_doc_rec.other_flag           := 'PAIR';
    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_deduction.create_claims_rapp_dist()-' );
    END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('EXCEPTION: arp_deduction.create_claims_rapp_dist()-');
    END IF;

    x_return_status := FND_API.G_RET_STS_ERROR;
    arp_deduction.conc_req_log_msg
     ('EXCEPTION: arp_deduction.create_claims_rapp_dist'||
      ' STATUS='||p_status||
      ' CCID='||to_char(l_ra_rec.code_combination_id)||
      ' Cash_Receipt_ID='||to_char(l_ra_rec.cash_receipt_id)||
      ' Payment Schedule_ID='||to_char(l_ra_rec.payment_schedule_id)
      );
    arp_deduction.conc_req_log_msg('SQLERRM='||substr(SQLERRM,1,255));

    RAISE;

END create_claims_rapp_dist;


/*========================================================================
 | PUBLIC PROCEDURE claim_create_fail_recover
 |
 | DESCRIPTION
 |     Procedure to recover from claim creation failure.
 |     The receivable application records and thier corresponding distribution
 |     records for the claim are deleted. The payment schedule amounts are
 |     updated appropriately.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |     claim_creation
 |
 | CALLS PROCEDURES/FUNCTIONS
 |     arp_app_pkg.delete_p
 |     arp_acct_main.Delete_Acct_Entry(l_ae_doc_rec);
 |
 |
 | PARAMETERS
 |         IN  :
 |               p_rec_app_id
 |               p_receipt_id
 |
 |         OUT :
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date         Author            Description of Changes
 | 17-JAN-2003  cthangai          Created
 | 05-MAR-2003  cthangai          Removed Payment Schedule ID Parameter.
 | 01-Apr-2003  Debbie Jancis	  Added calls to replicate mrc data
 *=======================================================================*/
PROCEDURE claim_create_fail_recover
  (p_rapp_id    IN ar_receivable_applications.receivable_application_id%TYPE
  ,p_cr_id      IN ar_receivable_applications.cash_receipt_id%TYPE
  ) IS

  --
  -- Cursor to fetch the ('APP' OR 'OTHER ACC') AND 'UNAPP' applications
  -- for delete
  --
  CURSOR rapp_rec IS
    select ra.*     --'APP' OR 'OTHER ACC'
    from   ar_receivable_applications ra
    where  ra.receivable_application_id = p_rapp_id
    and    nvl(ra.confirmed_flag,'Y') = 'Y'
    and exists (select 'x'
                from  ar_distributions_all ard
                where ard.source_table = 'RA'
                and   ard.source_id    = ra.receivable_application_id)
    UNION
    select ra.*     --'UNAPP'
    from   ar_receivable_applications ra
         , ar_distributions ard
    where  ra.receivable_application_id = ard.SOURCE_ID
    and    nvl(ra.confirmed_flag,'Y') = 'Y'
    and    ard.source_table = 'RA'
    and    ard.source_id_secondary =
         ( select ra1.receivable_application_id
           from   ar_receivable_applications ra1
           where  ra1.receivable_application_id = p_rapp_id );

  l_ae_doc_rec                  ARP_ACCT_MAIN.ae_doc_rec_type;
  ln_unapp_ra_id                ar_receivable_applications.receivable_application_id%TYPE;
  ln_ra_id		        ar_receivable_applications.receivable_application_id%TYPE;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('arp_deduction.claim_create_fail_recover()+' );
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('p_rec_app_id = '||TO_CHAR(p_rapp_id));
       arp_standard.debug('p_receipt_id = '||TO_CHAR(p_cr_id));
    END IF;

      ------------------------------------------------------------------
      -- Loop through the RA ('APP' OR 'OTHER ACC') and UNAPP For Delete
      ------------------------------------------------------------------
      FOR l_rapp_rec in rapp_rec
      LOOP

        IF l_rapp_rec.status IN ('APP','OTHER ACC') THEN
          ln_ra_id       := l_rapp_rec.receivable_application_id;

        ELSIF l_rapp_rec.status = 'UNAPP' THEN
          ln_unapp_ra_id := l_rapp_rec.receivable_application_id;

        END IF;

        -------------------------------------------------
        --Delete child accounting records associated with
        --parent applications for APP
        -------------------------------------------------
        l_ae_doc_rec.document_type           := 'RECEIPT';
        l_ae_doc_rec.document_id             := l_rapp_rec.cash_receipt_id;
        l_ae_doc_rec.accounting_entity_level := 'ONE';
        l_ae_doc_rec.source_table            := 'RA';
        l_ae_doc_rec.source_id               := l_rapp_rec.receivable_application_id;
        l_ae_doc_rec.source_id_old           := '';
        l_ae_doc_rec.other_flag              := '';
        arp_acct_main.Delete_Acct_Entry(l_ae_doc_rec);

      END LOOP; -- FOR l_rapp_rec in rapp_rec

      -------------------------------------------------------------
      -- Delete 'APP' OR 'OTHER ACC' Receivable Application record.
      -------------------------------------------------------------
      arp_app_pkg.delete_p(ln_ra_id);

     /*----------------------------------+
      | Calling central MRC library      |
      | for MRC Integration              |
      +---------------------------------*/

      ar_mrc_engine.maintain_mrc_data(
             p_event_mode        => 'DELETE',
             p_table_name        => 'AR_RECEIVABLE_APPLICATIONS',
             p_mode              => 'SINGLE',
             p_key_value         => ln_ra_id);

      ------------------------------------------------
      -- Delete 'UNAPP' Receivable Application record.
      ------------------------------------------------
      arp_app_pkg.delete_p(ln_unapp_ra_id);

     /*----------------------------------+
      | Calling central MRC library      |
      | for MRC Integration              |
      +---------------------------------*/

      ar_mrc_engine.maintain_mrc_data(
             p_event_mode        => 'DELETE',
             p_table_name        => 'AR_RECEIVABLE_APPLICATIONS',
             p_mode              => 'SINGLE',
             p_key_value         => ln_ra_id);

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('arp_deduction.claim_create_fail_recover()-' );
    END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF PG_DEBUG IN ('Y', 'C') THEN
      arp_standard.debug('EXCEPTION: arp_deduction.claim_create_fail_recover' );
    END IF;
    RAISE;

END claim_create_fail_recover;


/*========================================================================
 | PUBLIC FUNCTION GET_FUNCTIONAL_CURRENCY
 |
 | DESCRIPTION
 |      This function is called in the view associated with the LOV in the
 |      multiple Quickcash screen for the receipt to receipt feature to
 |      derive the functional currency code
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURE/FUNCTIONS ACCESSED - NONE
 |
 | ARGUMENTS  :
 |         IN :    NONE
 |
 |         OUT:    NONE
 |
 | RETURNS    : VARCHAR (Functional Currency Code by Set Of Books)
 |
 |
 | NOTES      : This should be eventually rellocated into the arp_util package
 |
 | MODIFICATION HISTORY
 | Date		Author		Description of Changes
 | 21-JAN-2003	cthangai        Created
 | DD-MON-YYYY           Name              Bug #####, modified amount ..
 |
 *=======================================================================*/
FUNCTION GET_FUNCTIONAL_CURRENCY RETURN VARCHAR2 IS

  l_currency_code gl_sets_of_books.currency_code%type;

BEGIN

  SELECT gl.currency_code
  INTO   l_currency_code
  FROM   gl_sets_of_books gl
        ,ar_system_parameters ar
  WHERE  gl.set_of_books_id = ar.set_of_books_id;

  RETURN l_currency_code;

EXCEPTION
  WHEN OTHERS THEN

     IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('EXCEPTION: ARP_DEDUCTION.GET_FUNCTIONAL_CURRENCY');
     END IF;
     RETURN NULL;

END GET_FUNCTIONAL_CURRENCY;


/*========================================================================
 | PUBLIC FUNCTION GET_RECEIVABLES_TRX_ID
 |
 | DESCRIPTION
 |      This function is called to retreive the receivables_trx_id
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURE/FUNCTIONS ACCESSED - NONE
 |
 | ARGUMENTS  :
 |         IN :    p_cash_receipt_id
 |
 |         OUT:    NONE
 |
 | RETURNS    : NUMBER (receivable_trx_id associated with the cash_receipt_id)
 |
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 | Date		Author		Description of Changes
 | 23-JAN-2003	cthangai        Created
 | DD-MON-YYYY           Name              Bug #####, modified amount ..
 |
 *=======================================================================*/
FUNCTION GET_RECEIVABLES_TRX_ID
 (p_cash_receipt_id IN ar_cash_receipts.cash_receipt_id%TYPE) RETURN NUMBER IS

  l_receivables_trx_id  ar_receivables_trx.receivables_trx_id%TYPE;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug('arp_deduction.GET_RECEIVABLES_TRX_ID()+' );
  END IF;

  SELECT rt.receivables_trx_id
  INTO   l_receivables_trx_id
  FROM   ar_receivables_trx rt
  WHERE  rt.receivables_trx_id = (
    SELECT rma.claim_receivables_trx_id
    FROM   ar_receipt_method_accounts rma, ar_cash_receipts cr
    WHERE  rma.receipt_method_id = cr.receipt_method_id
    AND    cr.cash_receipt_id = p_cash_receipt_id
    AND    rma.primary_flag = 'Y' );

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug('arp_deduction.GET_RECEIVABLES_TRX_ID()-' );
  END IF;

  RETURN l_receivables_trx_id;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('EXCEPTION: ARP_DEDUCTION.GET_RECEIVABLES_TRX_ID');
    END IF;
    RETURN NULL;

END GET_RECEIVABLES_TRX_ID;


/*========================================================================
 | PUBLIC PROCEDURE UPDATE_CLAIM_CREATE_STATUS
 |
 | DESCRIPTION
 |      This function is called to update ar_payment_schedules,
 |      active_claim_flag column with the appropriate claim status returned
 |      from TM
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURE/FUNCTIONS ACCESSED - NONE
 |
 | ARGUMENTS  :
 |         IN : p_ps_id         --payment_schedule_id
 |              p_claim_status  --claim status
 |
 |         OUT:    NONE
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 | Date		Author	Description of Changes
 | 21-JAN-2003	cthangai    Update ar_payment_schdeules.active_claim_flag
 |                            based on the claim status in TM
 | DD-MON-YYYY    Name        Bug #####, modified amount ..
 |
 *=======================================================================*/
PROCEDURE UPDATE_CLAIM_CREATE_STATUS
 (p_ps_id        IN ar_payment_schedules.payment_schedule_id%type
 ,p_claim_status IN ar_payment_schedules.active_claim_flag%type
 ) IS

BEGIN

  -------------------------
  -- Update claim status
  -------------------------
  UPDATE ar_payment_schedules
  SET    active_claim_flag = p_claim_status
  WHERE  payment_schedule_id = p_ps_id;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('EXCEPTION: ARP_DEDUCTION.UPDATE_CLAIM_CREATE_STATUS');
     END IF;
     RAISE;

END UPDATE_CLAIM_CREATE_STATUS;


/*========================================================================
 | PUBLIC FUNCTION OVERAPPLICATION_INDICATOR
 |
 | DESCRIPTION
 |     Function to determine whether amount applied will cause an
 |     overapplication given the current amount due remaining and
 |     amount due original.
 |     A=sign(amount_due_remaining - amount_applied)
 |     B=sign(amount_due_original)
 |     If A=-1 and B=+1 or A=+1 and B=-1 then overapplication
 |     Returns Y else Return N
 | CALLED FROM PROCEDURES/FUNCTIONS
 |      Called from AR_INTERIM_CASH_RECEIPTS_V ,AR_INTERIM_CR_LINES_V
 |      and Quick Cash Form (ARXRWQRC.fmb)
 | CALLS PROCEDURES/FUNCTIONS
 |
 |
 |
 | PARAMETERS
 |  IN:
 |    P_AMOUNT_DUE_ORIGINAL IN  NUMBER
 |    P_AMOUNT_DUE_REMAININIG  IN NUMBER
 |    P_AMOUNT_APPLIED  IN NUMBER
 |  OUT:
 |      RETURN Y/N
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date         Author            Description of Changes
 | 21-JAN-2003  KDhaliwal         Created
 |
 *=======================================================================*/
FUNCTION OVERAPPLICATION_INDICATOR
 (P_AMOUNT_DUE_ORIGINAL IN  NUMBER
 ,P_AMOUNT_DUE_REMAINING  IN NUMBER
 ,P_AMOUNT_APPLIED  IN NUMBER
 ) RETURN VARCHAR2 IS

 l_return VARCHAR2(1);
 ln_balance_sign NUMBER;
 ln_amount_due_original_sign NUMBER;

BEGIN

 ln_balance_sign := SIGN(P_AMOUNT_DUE_REMAINING - P_AMOUNT_APPLIED);
 ln_amount_due_original_sign :=SIGN(P_AMOUNT_DUE_ORIGINAL);

 IF (ln_balance_sign=-1 AND ln_amount_due_original_sign=1) THEN
   l_return :='Y';

 ELSIF (ln_balance_sign=1 AND ln_amount_due_original_sign=-1) THEN
   l_return :='Y';

 ELSE
   l_return :='N';

 END IF;

 RETURN(l_return);

EXCEPTION
   WHEN OTHERS THEN
     RAISE;

END OVERAPPLICATION_INDICATOR;


/*========================================================================
 | PUBLIC FUNCTION CHECK_APP_VIOLATE
 |
 | DESCRIPTION
 |    Function to determine whether amount entered in the screen
 |    is violating Natural Applicatioon OR violating Over Application OR
 |    is a valid Natural Application
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |     Called from WHEN-VALIDATE-ITEM trigger of the AMOUNT field in the
 |     Multiple QuickCash window as well as the Receipt Application window
 |
 | CALLS PROCEDURES/FUNCTIONS
 |
 | PARAMETERS
 |  IN:
 |    P_AMOUNT IN NUMBER (amount passed from the form)
 |    P_RAPP_ID  IN NUMBER
 |    P_CR_ID  IN NUMBER
 |  OUT:
 |      RETURN ('NATURAL','OVER','NO')
 |         NATURAL -> Natural Application Violation
 |         OVER    -> Over Application Violation
 |         NO      -> No Violation
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date         Author      Description of Changes
 | 23-JAN-2003  CTHANGAI    Created
 | 17-FEB-2003  CTHANGAI    natural application of the receipt is based on
 |                          to the payment schedule of the receipt
 *=======================================================================*/
FUNCTION CHECK_APP_VIOLATE
 (p_amount   IN ar_receivable_applications.amount_applied%TYPE
 ,p_rapp_id  IN ar_receivable_applications.receivable_application_id%TYPE
 ,p_cr_id    IN ar_receivable_applications.cash_receipt_id%TYPE
 )  RETURN VARCHAR2 IS

  l_return            VARCHAR2(10);
  ln_amount_applied   ar_receivable_applications.amount_applied%TYPE;

  invalid_param       EXCEPTION;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug('arp_deduction.CHECK_APP_VIOLATE()+' );
  END IF;

  IF (p_rapp_id IS NOT NULL) AND (p_cr_id IS NOT NULL) THEN   --'On Account'

     SELECT amount_applied
     INTO   ln_amount_applied
     FROM   ar_receivable_applications
     WHERE  receivable_application_id = p_rapp_id;

  ELSIF (p_rapp_id IS NULL) AND (p_cr_id IS NOT NULL) THEN   --'Unapplied'

     SELECT sum(amount_applied)
     INTO   ln_amount_applied
     FROM   ar_receivable_applications
     WHERE  cash_receipt_id = p_cr_id
     AND    status = 'UNAPP';

  ELSE                                               --'Raise Invalid Arguments'

    APP_EXCEPTION.INVALID_ARGUMENT
     ('ARP_DEDUCTION.CHECK_APP_VIOLATE'
     ,'p_rapp_id'
     ,'NULL'
     );

    IF PG_DEBUG in ('Y','C') THEN
      arp_standard.debug('Invalid Argument -  p_rapp_id is Null');
    END IF;

    l_return := NULL;
    RAISE invalid_param;

  END IF; -- IF (p_rapp_id IS NOT NULL) AND (p_cr_id IS NOT NULL)

  IF ( SIGN(ln_amount_applied * -1) = SIGN(p_amount) ) THEN

    IF ( ABS(ln_amount_applied) < ABS(p_amount) ) THEN  -- Over Application Violation
      l_return := 'OVER';

    ELSE                                  -- Natural Application
      l_return := 'NO';

    END IF;

  ELSE                       --Natural Application Violation
    l_return := 'NATURAL';

  END IF; -- IF ( SIGN(ln_amount_applied * -1) = SIGN(p_amount) )

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug('arp_deduction.CHECK_APP_VIOLATE()-' );
  END IF;

  RETURN (l_return);

EXCEPTION
  WHEN invalid_param THEN

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('EXCEPTION - invalid_param : ARP_DEDUCTION.CHECK_APP_VIOLATE');
    END IF;
    RETURN(l_return);

  WHEN OTHERS THEN

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('EXCEPTION - OTHERS : ARP_DEDUCTION.CHECK_APP_VIOLATE');
    END IF;
    RETURN(l_return);

END CHECK_APP_VIOLATE;


/*========================================================================
 | PUBLIC FUNCTION GET_TM_ORACLE_REASON
 |
 | DESCRIPTION
 |      This function is called to retrieve the Oracle reason description
 |      from TM
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURE/FUNCTIONS ACCESSED - NONE
 |
 | ARGUMENTS  :
 |         IN :    TM Claim ID
 |
 |         OUT:    NONE
 |
 | RETURNS    : VARCHAR (Oracle Reason From TM)
 |
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 | Date		Author		Description of Changes
 | 12-FEB-2003	cthangai        Created
 | DD-MON-YYYY  Name            Bug #####, modified amount ..
 |
 *=======================================================================*/
FUNCTION GET_TM_ORACLE_REASON
 (p_claim_id   IN ar_receivable_applications.secondary_application_ref_id%TYPE
 ) RETURN VARCHAR2 IS

  l_query_string     VARCHAR2(2000);
  l_tm_oracle_reason ar_receivable_applications.customer_reason%type;

BEGIN

  l_query_string :=
   ' SELECT rc.name FROM ozf_reason_codes_vl rc, ozf_claims c '||
   ' WHERE  c.reason_code_id = rc.reason_code_id '||
   ' AND    c.claim_id       = :claim_id ';

  BEGIN
    EXECUTE IMMEDIATE l_query_string
    INTO    l_tm_oracle_reason
    USING   p_claim_id;
  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.set_name('AR','AR_RW_INVALID_CLAIM_ID');
        FND_MESSAGE.set_token('CLAIM_ID',p_claim_id);
        APP_EXCEPTION.raise_exception;
  END;

  RETURN l_tm_oracle_reason;

EXCEPTION
  WHEN OTHERS THEN

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('EXCEPTION: ARP_DEDUCTION.GET_TM_ORACLE_REASON');
    END IF;
    RETURN NULL;

END GET_TM_ORACLE_REASON;


/*========================================================================
 | PUBLIC PROCEDURE conc_req_log_msg
 |
 | DESCRIPTION
 |    This procedure writes messages to the concurrent request log file
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURE/FUNCTIONS ACCESSED - NONE
 |
 | ARGUMENTS  :
 |         IN :    message
 |
 |         OUT:    NONE
 |
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 | Date		Author	Description of Changes
 | 13-FEB-2003	cthangai    Created
 | DD-MON-YYYY    Name        Bug #####
 |
 *=======================================================================*/
PROCEDURE conc_req_log_msg (p_message IN VARCHAR2) IS
BEGIN

  fnd_file.put_line(FND_FILE.LOG, p_message);

END conc_req_log_msg;


/*========================================================================
 | PUBLIC PROCEDURE conc_req_out_msg
 |
 | DESCRIPTION
 |    This procedure writes messages to the concurrent request output file
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURE/FUNCTIONS ACCESSED - NONE
 |
 | ARGUMENTS  :
 |         IN :    message
 |
 |         OUT:    NONE
 |
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 | Date		Author	Description of Changes
 | 13-FEB-2003	cthangai    Created
 | DD-MON-YYYY    Name        Bug #####
 |
 *=======================================================================*/
PROCEDURE conc_req_out_msg (p_message IN VARCHAR2)  IS
BEGIN

  fnd_file.put_line(FND_FILE.OUTPUT, p_message);

END conc_req_out_msg;


/*========================================================================
 | PUBLIC PROCEDURE apply_open_receipt_cover
 |
 | DESCRIPTION
 |      This Procedure will be called from Postbatch to create receipt
 |      to receipt applications.   It will actually call the Receipt
 |      Api which will created the rec apps records, distribution records
 |      updates to payment schedules and the synch up with Trade management
 |      if necessary.
 |      This function will write messages to the concurrent request output file
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURE/FUNCTIONS ACCESSED
 |
 |     AR_RECEIPT_API_PUB.APPLY_OPEN_RECEIPT
 |
 | ARGUMENTS  :
 |         IN :    p_cash_receipt_id
 |                 p_applied_payment_schedule_id
 |                 p_open_rec_app_id
 |                 p_amount_applied
 |                 p_attribute_category
 |                 p_attribute1
 |                 p_attribute2
 |                 p_attribute3
 |                 p_attribute4
 |                 p_attribute5
 |                 p_attribute6
 |                 p_attribute7
 |                 p_attribute8
 |                 p_attribute9
 |                 p_attribute10
 |                 p_attribute11
 |                 p_attribute12
 |                 p_attribute13
 |                 p_attribute14
 |                 p_attribute15
 |
 |         OUT:    X_RETURN_STAUS (S=success, E=Error, U=Unidentified Error)
 |                 x_receipt_number
 |                 X_APPLY_TYPE (F=Full, P=Partial)
 |
 | NOTES
 |    This routine currently does not support receipt to receipt applications
 |    which are in a currency other then functional currency.
 |
 | MODIFICATION HISTORY
 | Date		Author	       Description of Changes
 | 19-FEB-2003	cthangai       Created
 |                             Modify get_open_cr_id cursor to include receipt
 |                             number by joining to ar_cash_receipts
 |                             Modify cursor c1_validate to get amount_applied
 |                             Modify cursor c2_validate to get
 |                             sum(amount_applied)
 |                             Amount_applied retreived is used in determining
 |                             Full or Partial payment
 |                             Add OUT parameters x_return_status, x_apply_type
 | 03-MAR-2003  Debbie Jancis  Added Comments and formatting. Fixed how
 |                             x_apply_type was figuring out whether
 |                             application was full or partial.  For a
 |                             receipt to receipt application, the sign
 |                             of the the p_amount_applied variable will
 |                             always be the opposite sign of the
 |                             l_amount_applied value retrieved from the
 |                             receivable apps record of the applied receipt.
 | 07-MAR-2003	cthangai       Added OUT parameter x_application_ref_num
 |                             for the TM API call to apply_open_receipt
 |                             local variable l_application_ref_num
 |
 *=======================================================================*/
PROCEDURE apply_open_receipt_cover
 (p_cash_receipt_id             IN ar_cash_receipts.cash_receipt_id%TYPE,
  p_applied_payment_schedule_id IN ar_payment_schedules.payment_schedule_id%TYPE
 ,p_open_rec_app_id             IN
                       ar_receivable_applications.receivable_application_id%TYPE
 ,p_amount_applied              IN
                       ar_receivable_applications.amount_applied%TYPE
 ,p_attribute_category          IN
                       ar_receivable_applications.attribute_category%TYPE
 ,p_attribute1                  IN  ar_receivable_applications.attribute1%TYPE
 ,p_attribute2                  IN  ar_receivable_applications.attribute2%TYPE
 ,p_attribute3                  IN  ar_receivable_applications.attribute3%TYPE
 ,p_attribute4                  IN  ar_receivable_applications.attribute4%TYPE
 ,p_attribute5                  IN  ar_receivable_applications.attribute5%TYPE
 ,p_attribute6                  IN  ar_receivable_applications.attribute6%TYPE
 ,p_attribute7                  IN  ar_receivable_applications.attribute7%TYPE
 ,p_attribute8                  IN  ar_receivable_applications.attribute8%TYPE
 ,p_attribute9                  IN  ar_receivable_applications.attribute9%TYPE
 ,p_attribute10                 IN  ar_receivable_applications.attribute10%TYPE
 ,p_attribute11                 IN  ar_receivable_applications.attribute11%TYPE
 ,p_attribute12                 IN  ar_receivable_applications.attribute12%TYPE
 ,p_attribute13                 IN  ar_receivable_applications.attribute13%TYPE
 ,p_attribute14                 IN  ar_receivable_applications.attribute14%TYPE
 ,p_attribute15                 IN  ar_receivable_applications.attribute15%TYPE
 ,x_return_status               OUT NOCOPY VARCHAR2
 ,x_receipt_number              OUT NOCOPY ar_cash_receipts.receipt_number%TYPE
 ,x_apply_type                  OUT NOCOPY VARCHAR2
 ) IS

  --Fetch open_cash_receipt_id
  CURSOR get_open_cr_id
   (p_applied_ps_id ar_payment_schedules.payment_schedule_id%TYPE) IS
    SELECT ps.cash_receipt_id, cr.receipt_number
    FROM   ar_payment_schedules ps
          ,ar_cash_receipts cr
    WHERE  ps.payment_schedule_id = p_applied_ps_id
    AND    ps.cash_receipt_id = cr.cash_receipt_id;

  --Fetch from receivable application if application is valid
  --for receipt to receipt application. Application is 'ACC' or 'OTHER ACC'
  CURSOR c1_validate
    (p_rapp_id ar_receivable_applications.receivable_application_id%TYPE) IS
     SELECT amount_applied --'Y'
     FROM   ar_receivable_applications
     WHERE  receivable_application_id = p_rapp_id
     AND    display = 'Y';

  --Fetch from receivable application if application is valid
  --for receipt to receipt application. Application is 'UNAPP'
  CURSOR c2_validate
    (p_cr_id ar_receivable_applications.cash_receipt_id%TYPE) IS
     SELECT sum(amount_applied)
     FROM   ar_receivable_applications
     WHERE  cash_receipt_id = p_cr_id
     AND    status = 'UNAPP'
     HAVING sum(amount_applied) >= p_amount_applied;

  l_attribute_rec              ar_receipt_api_pub.attribute_rec_type;
  l_global_attribute_rec       ar_receipt_api_pub.global_attribute_rec_type;
  l_global_attribute_rec_null  ar_receipt_api_pub.global_attribute_rec_type;
  l_return_status              VARCHAR2(1); --'E','U' = ERROR ;; 'S'=Success;;
  l_msg_count                  NUMBER;
  l_msg_data                   VARCHAR2(2000);
  l_called_from                VARCHAR2(255) := 'ARCABP'; --PostBatch Pro*C
  l_process                    VARCHAR2(1); --'Y'=Process 'N'=Stop Process
  l_amount_applied             ar_receivable_applications.amount_applied%TYPE;
  l_open_cash_receipt_id       ar_cash_receipts.cash_receipt_id%TYPE;
  l_open_receipt_number        ar_cash_receipts.receipt_number%type;
  l_application_ref_num        ar_receivable_applications.application_ref_num%TYPE;
  l_receivable_application_id  ar_receivable_applications.application_ref_num%TYPE;
  l_applied_rec_app_id         ar_receivable_applications.receivable_application_id%TYPE;
  l_acctd_amount_applied_from  NUMBER;
  l_acctd_amount_applied_to    NUMBER;

  invalid_param                EXCEPTION;
  amount_applied_null          EXCEPTION;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug('update_action: arp_deduction.apply_open_receipt_cover()+');
  END IF;

  ---------------------------------------------------------------
  -- Fetch open_cash_receipt_id using applied_payment_schedule_id
  ---------------------------------------------------------------
  IF (p_applied_payment_schedule_id IS NOT NULL) THEN
    OPEN get_open_cr_id (p_applied_payment_schedule_id);
    FETCH get_open_cr_id into l_open_cash_receipt_id ,l_open_receipt_number;

    IF get_open_cr_id%NOTFOUND THEN
      IF PG_DEBUG IN ('Y','C') THEN
        arp_standard.debug('No Data Found : Invalid p_applied_payment_schedule_id');
      END IF;
      CLOSE get_open_cr_id;
      RAISE invalid_param;

    ELSE
      x_receipt_number := l_open_receipt_number;

    END IF;

    CLOSE get_open_cr_id;

  ELSE
    APP_EXCEPTION.INVALID_ARGUMENT
     ('ARP_DEDUCTION.APPLY_OPEN_RECEIPT_COVER'
     ,'P_APPLIED_PAYMENT_SCHEDULE_ID'
     ,'NULL'
     );

    IF PG_DEBUG IN ('Y','C') THEN
      arp_standard.debug('Invalid Argument - Applied Payment Schedule ID IS NULL');
    END IF;
    RAISE invalid_param;

  END IF; --IF (p_applied_payment_schedule_id IS NOT NULL)

  -------------------------------------
  -- Initialize process flag. Y=Process
  -------------------------------------
  l_process := 'Y';

  ------------------------------------------------------------------------------
  -- Determine if the receipt api should be called and set l_process='Y' on
  -- success. For 'ACC' or 'OTHER ACC', the receivable application must have
  -- display='Y'.
  -- For 'UNAPP' record, the sum(amount_applied) for the cash receipt must
  -- be greater than or equal to the amount being applied to the open receipt
  ------------------------------------------------------------------------------
  IF (p_open_rec_app_id > 0) AND (l_open_cash_receipt_id IS NOT NULL) THEN

     -- 'ACC' OR 'OTHER ACC'
     OPEN c1_validate (p_open_rec_app_id);
     FETCH c1_validate INTO l_amount_applied;

     IF c1_validate%NOTFOUND THEN

       x_return_status := FND_API.G_RET_STS_ERROR;
       l_process := 'N';

       arp_deduction.conc_req_log_msg
        ('Failed Validation : display<>Y for the application. No Call will be '
        ||' initiated for receipt API - apply_open_receipt'
        ||' Receivable Application id = '||to_char(p_open_rec_app_id)
        ||' Cash Receipt id = '||to_char(l_open_cash_receipt_id));

     END IF;-- IF c1_validate%NOTFOUND

     CLOSE c1_validate;

  ELSIF (p_open_rec_app_id <= 0) AND (l_open_cash_receipt_id IS NOT NULL) THEN

     -- 'UNAPP'
     OPEN c2_validate (l_open_cash_receipt_id);
     FETCH c2_validate INTO l_amount_applied;

     IF c2_validate%NOTFOUND THEN

       x_return_status := FND_API.G_RET_STS_ERROR;
       l_process := 'N';

       arp_deduction.conc_req_log_msg
        ('Failed Validation : sum(amount_applied) is less than apply_amount for '
        ||' UNAPP. No call will be initiated for receipt API - apply_open_receipt'
        ||' Cash Receipt ID = '||to_char(l_open_cash_receipt_id));

     END IF; --IF c2_validate%NOTFOUND

     CLOSE c2_validate;

  END IF; --IF (p_open_rec_app_id IS NOT NULL) AND (l_open_cash_receipt_id IS NOT NULL)

  -------------------------------------------------------
  -- Determine if l_process='Y' to process call to TM API
  -------------------------------------------------------
  IF l_process = 'Y' THEN

    -----------------------------------------------
    -- Determine if apply amount is Partial or Full
    -- 'P' for Partial and 'F' for full
    -----------------------------------------------
    IF l_amount_applied <> -p_amount_applied THEN
      x_apply_type := 'P';

    ELSIF l_amount_applied = -p_amount_applied THEN
      x_apply_type := 'F';

    END IF;

    -------------------------------------------------------------
    -- Initialize the record type variables with the correspoding
    -- parameter values
    -------------------------------------------------------------
    l_attribute_rec.attribute_category := p_attribute_category;
    l_attribute_rec.attribute1         := p_attribute1;
    l_attribute_rec.attribute2         := p_attribute2;
    l_attribute_rec.attribute3         := p_attribute3;
    l_attribute_rec.attribute4         := p_attribute4;
    l_attribute_rec.attribute5         := p_attribute5;
    l_attribute_rec.attribute6         := p_attribute6;
    l_attribute_rec.attribute7         := p_attribute7;
    l_attribute_rec.attribute8         := p_attribute8;
    l_attribute_rec.attribute9         := p_attribute9;
    l_attribute_rec.attribute10        := p_attribute10;
    l_attribute_rec.attribute11        := p_attribute11;
    l_attribute_rec.attribute12        := p_attribute12;
    l_attribute_rec.attribute13        := p_attribute13;
    l_attribute_rec.attribute14        := p_attribute14;
    l_attribute_rec.attribute15        := p_attribute15;
    l_global_attribute_rec             := l_global_attribute_rec_null;

    --------------------------------------------
    -- Call to receipt API to Apply Open Receipt
    --------------------------------------------
    ar_receipt_api_pub.apply_open_receipt
     (p_api_version                 => 1.0
     ,p_init_msg_list               => FND_API.G_TRUE
     ,p_commit                      => FND_API.G_FALSE
     ,x_return_status               => l_return_status
     ,x_msg_count                   => l_msg_count
     ,x_msg_data                    => l_msg_data
     ,p_cash_receipt_id             => p_cash_receipt_id
     ,p_applied_payment_schedule_id => p_applied_payment_schedule_id
     ,p_open_cash_receipt_id        => l_open_cash_receipt_id
     ,p_open_receipt_number         => l_open_receipt_number
     ,p_open_rec_app_id             => p_open_rec_app_id
     ,p_amount_applied              => p_amount_applied
     ,p_called_from                 => l_called_from
     ,p_attribute_rec               => l_attribute_rec
     ,p_global_attribute_rec        => l_global_attribute_rec
     ,x_application_ref_num         => l_application_ref_num
     ,x_receivable_application_id   => l_receivable_application_id
     ,x_applied_rec_app_id          => l_applied_rec_app_id
     ,x_acctd_amount_applied_from   => l_acctd_amount_applied_from
     ,x_acctd_amount_applied_to     => l_acctd_amount_applied_to
     );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS  THEN
      x_return_status := 'S';

    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      x_return_status := 'E';
      arp_deduction.conc_req_log_msg
       ('FAILURE - ERROR : Return status = E from API call apply_open_receipt');

    ELSE
      x_return_status := 'U';
      arp_deduction.conc_req_log_msg
       ('FAILURE - UNIDENTIFIED : Return Status = U from API call apply_open_receipt');

    END IF; --IF l_return_status = FND_API.G_RET_STS_SUCCESS

  END IF; --IF l_process = 'Y' THEN

  IF PG_DEBUG in ('Y','C') THEN
    arp_standard.debug('update_action: ARP_DEDUCTION.apply_open_receipt_cover()-');
  END IF;

EXCEPTION
  WHEN invalid_param THEN

    x_return_status := FND_API.G_RET_STS_ERROR;

    IF PG_DEBUG in ('Y','C') THEN
      arp_standard.debug('EXCEPTION - invalid_param : ARP_DEDUCTION.apply_open_receipt_cover()-');
    END IF;

    RAISE;

  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_ERROR;

    arp_deduction.conc_req_log_msg
     ('EXCEPTION - WHEN OTHERS : ARP_DEDUCTION.apply_open_receipt_cover()-');
    arp_deduction.conc_req_log_msg('SQLERRM='||substr(SQLERRM,1,255));

    RAISE;

END apply_open_receipt_cover;

/*========================================================================
 | PUBLIC FUNCTION GET_ACTIVE_CLAIM_FLAG
 |
 | DESCRIPTION
 |      This function returns the value of the active claim flag which is
 |      stored on the Payment Schedule of a transaction.   This flag indicates
 |      whether or not an active claim exists in trade management.
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURE/FUNCTIONS ACCESSED - NONE
 |
 | ARGUMENTS  :
 |         IN     :    payment_schedule_id
 |         IN     :    payment_schedule_id
 |
 |         RETURNS:    ACTIVE_CLAIM_FLAG (for that payment schedule id)
 |
 | KNOWN ISSUES
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 | Date         Author          Description of Changes
 | 03-JUN-2003  Debbie Jancis   Created
 |
 *=======================================================================*/
FUNCTION GET_ACTIVE_CLAIM_FLAG(
    p_payment_schedule_id  IN ar_payment_schedules.payment_schedule_id%TYPE)
  RETURN VARCHAR2 IS

  l_active_claim_flag ar_payment_schedules.active_claim_flag%type;

BEGIN

  SELECT nvl(active_claim_flag,'N')
  INTO   l_active_claim_flag
  FROM   ar_payment_schedules
  WHERE  payment_schedule_id = p_payment_schedule_id;

  RETURN l_active_claim_flag;

EXCEPTION
  WHEN OTHERS THEN

     IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('EXCEPTION: ARP_DEDUCTION.GET_ACTIVE_CLAIM_FLAG');
     END IF;
     RETURN NULL;

END GET_ACTIVE_CLAIM_FLAG;





 /*========================================================================
 | INITIALIZATION SECTION
 |
 | DESCRIPTION
 |      Enter a brief description of what this section does.
 |      ----------------------------------------
 |      This does the following ......
 |
 | KNOWN ISSUES
 |      Enter business functionality which was de-scoped as part of the
 |      implementation. Ideally this should never be used.
 |
 | NOTES
 |      Any interesting aspect of the code in this section
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | DD-MON-YYYY           Name              Created
 | DD-MON-YYYY           Name              Bug #####, modified amount ..
 |
 *=======================================================================*/
BEGIN

   null;

EXCEPTION
  WHEN NO_DATA_FOUND THEN

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('EXCEPTION: ARP_DEDUCTION.INITIALIZE');
    END IF;
    RAISE;

  WHEN OTHERS THEN

     IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('EXCEPTION: ARP_DEDUCTION.INITIALIZE');
     END IF;
     RAISE;

END ARP_DEDUCTION;

/
