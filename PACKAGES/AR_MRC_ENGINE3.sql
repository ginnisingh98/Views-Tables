--------------------------------------------------------
--  DDL for Package AR_MRC_ENGINE3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_MRC_ENGINE3" AUTHID CURRENT_USER AS
/* $Header: ARMCEN3S.pls 120.1 2004/12/03 01:45:52 orashid noship $ */

/*=============================================================================
 |   Public Functions / Procedures
 *============================================================================*/

/*=============================================================================
 |  PUBLIC PROCEDURE  Insert_ra_rec_cash
 |
 |  DESCRIPTION:
 |                This procedure will be called from ARP_PROC_RCT_UTIL
 |                to process the mrc data for insert.
 |
 |  CALLS PROCEDURES / FUNCTIONS (local to this package body)
 |
 |  PARAMETERS
 |      p_rec_app_id            IN NUMBER,
 |      p_rec_app_record        IN ar_receivable_applications%ROWTYPE
 |      p_cash_receipt_id       IN ar_cash_receipts.cash_receipt_id%TYPE
 |      p_amount                IN ar_cash_receipts.amount%TYPE
 |      p_payment_schedule_id   IN ar_payment_schedules.payment_schedule_id%TYPE
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date        Author                  Description of Change
 |  09/03/02    Debbie Sue Jancis  	Created
 *============================================================================*/
PROCEDURE insert_ra_rec_cash(
        p_rec_app_id            IN NUMBER,
        p_rec_app_record        IN ar_receivable_applications%ROWTYPE,
        p_cash_receipt_id       IN ar_cash_receipts.cash_receipt_id%TYPE,
        p_amount                IN ar_cash_receipts.amount%TYPE,
        p_payment_schedule_id   IN ar_payment_schedules.payment_schedule_id%TYPE
                        );

/*=============================================================================
 |  PUBLIC PROCEDURE  create_matching_unapp_records
 |
 |  DESCRIPTION:
 |                This procedure will be called from ARP_CONFIRMATION
 |                to process the mrc data for insert.
 |
 |  CALLS PROCEDURES / FUNCTIONS (local to this package body)
 |
 |  PARAMETERS
 |      p_rec_app_id            IN NUMBER,
 |      p_rec_unapp_id          IN NUMBER,
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date        Author                  Description of Change
 |  09/03/02    Debbie Sue Jancis       Created
 *============================================================================*/PROCEDURE create_matching_unapp_records(
        p_rec_app_id            IN NUMBER,
        p_rec_unapp_id          IN NUMBER
                        );

/*=============================================================================
 |  PUBLIC PROCEDURE  receipt_application
 |
 |  DESCRIPTION:
 |                This procedure will be called from ARP_PROCESS_APPLICATION
 |                to process the mrc data for insert.
 |
 |  CALLS PROCEDURES / FUNCTIONS (local to this package body)
 |
 |  PARAMETERS
 |      p_receipt_ps_id         IN NUMBER  - Receipt PS id
 |      p_invoice_ps_id         IN NUMBER  - Invoice PS id
 |      p_amount_applied        IN NUMBER
 |      p_amount_applied_from   IN NUMBER
 |      p_invoice_currency_code IN VARCHAR2
 |      p_receipt_currency_code IN VARCHAR2
 |      p_rec_ra_rec            IN receivable apps rowtype
 |      p_inv_ra_rec            IN receivable apps rowtype
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date        Author                  Description of Change
 |  09/04/02    Debbie Sue Jancis       Created
 *============================================================================*/
PROCEDURE receipt_application(
   p_receipt_ps_id      IN ar_payment_schedules.payment_schedule_id%TYPE,
   p_invoice_ps_id      IN ar_payment_schedules.payment_schedule_id%TYPE,
   p_amount_applied     IN ar_receivable_applications.amount_applied%TYPE,
   p_amount_applied_from IN ar_receivable_applications.amount_applied_from%TYPE,
   p_invoice_currency_code IN ar_payment_schedules.invoice_currency_code%TYPE,
   p_receipt_currency_code IN ar_cash_receipts.currency_code%TYPE,
   p_rec_ra_rec         IN ar_receivable_applications %ROWTYPE,
   p_inv_ra_rec         IN ar_receivable_applications %ROWTYPE
                        );

/*=============================================================================
 |  PUBLIC PROCEDURE  cm_application
 |
 |  DESCRIPTION:
 |                This procedure will be called from ARP_PROCESS_APPLICATION
 |                to process the mrc data for insert.
 |
 |  CALLS PROCEDURES / FUNCTIONS (local to this package body)
 |
 |  PARAMETERS
 |      p_cm_ps_id         IN NUMBER  - credit memo PS id
 |      p_invoice_ps_id    IN NUMBER  - Invoice PS id
 |      p_inv_ra_rec       IN receivable apps rowtype
 |      p_ra_id            IN NUMBER
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |
 |  MODIFICATION HISTORY
 |  Date        Author                  Description of Change
 |  09/04/02    Debbie Sue Jancis       Created
 *============================================================================*/PROCEDURE cm_application(
   p_cm_ps_id       IN ar_payment_schedules.payment_schedule_id%TYPE,
   p_invoice_ps_id  IN ar_payment_schedules.payment_schedule_id%TYPE,
   p_inv_ra_rec     IN ar_receivable_applications %ROWTYPE,
   p_ra_id          IN NUMBER
                 );

/*=============================================================================
 |  PUBLIC PROCEDURE  on_account_receipts
 |
 |  DESCRIPTION:
 |                This procedure will be called from ARP_PROCESS_APPLICATION
 |                to process the mrc data for insert.
 |
 |  CALLS PROCEDURES / FUNCTIONS (local to this package body)
 |
 |  PARAMETERS
 |      p_receipt_ps_id    IN NUMBER  - receipt PS id
 |      p_amount_applied   IN NUMBER
 |      p_acc_ra_rec       IN receivables apps rowtype
 |      p_unapp_rec_app_id IN NUMBER
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |
 |  MODIFICATION HISTORY
 |  Date        Author                  Description of Change
 |  09/04/02    Debbie Sue Jancis       Created
 *============================================================================*/
PROCEDURE on_account_receipts(
   p_receipt_ps_id       IN ar_payment_schedules.payment_schedule_id%TYPE,
   p_amount_applied      IN ar_receivable_applications.amount_applied%TYPE,
   p_acc_ra_rec          IN ar_receivable_applications %ROWTYPE,
   p_unapp_rec_app_id    IN NUMBER
                 );
/*=============================================================================
 |  PUBLIC PROCEDURE  other_account_application
 |
 |  DESCRIPTION:
 |                This procedure will be called from ARP_PROCESS_APPLICATION
 |                to process the mrc data for insert.
 |
 |  CALLS PROCEDURES / FUNCTIONS (local to this package body)
 |
 |  PARAMETERS
 |      p_receipt_ps_id    IN NUMBER  - receipt PS id
 |      p_amount_applied   IN NUMBER
 |      p_otheracc_ra_rec  IN receivables apps rowtype
 |      p_unapp_rec_app_id IN NUMBER
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |
 |  MODIFICATION HISTORY
 |  Date        Author                  Description of Change
 |  09/04/02    Debbie Sue Jancis       Created
 *============================================================================*/
PROCEDURE other_account_application(
   p_receipt_ps_id       IN ar_payment_schedules.payment_schedule_id%TYPE,
   p_amount_applied      IN ar_receivable_applications.amount_applied%TYPE,
   p_otheracc_ra_rec     IN ar_receivable_applications %ROWTYPE,
   p_unapp_rec_app_id    IN NUMBER
                 );

/*=============================================================================
 |  PUBLIC PROCEDURE  reversal_insert_oppos_ra_recs
 |
 |  DESCRIPTION:
 |                This procedure will be called from ARP_PROCESS_APPLICATION
 |                to process the mrc data for insert.
 |
 |  CALLS PROCEDURES / FUNCTIONS (local to this package body)
 |
 |  PARAMETERS
 |      p_ra_rec           IN receivables apps rowtype
 |      p_orig_rec_app_id  IN NUMBER
 |      p_new_rec_app_id   IN NUMBER
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |
 |  MODIFICATION HISTORY
 |  Date        Author                  Description of Change
 |  09/04/02    Debbie Sue Jancis       Created
 *============================================================================*/
PROCEDURE reversal_insert_oppos_ra_recs(
   p_ra_rec              IN ar_receivable_applications %ROWTYPE,
   p_orig_rec_app_id     IN NUMBER,
   p_new_rec_app_id      IN NUMBER
                 );


/*=============================================================================
 |  PUBLIC PROCEDURE  reverse_ra_recs
 |
 |  DESCRIPTION:
 |                This procedure will be called from ARP_CONFIRMATION
 |                to process the mrc data for insert.
 |
 |  CALLS PROCEDURES / FUNCTIONS (local to this package body)
 |
 |  PARAMETERS
 |      p_orig_app_id  IN NUMBER
 |      p_new_app_id   IN NUMBER
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |
 |  MODIFICATION HISTORY
 |  Date        Author                  Description of Change
 |  09/04/02    Debbie Sue Jancis       Created
 *============================================================================*/
PROCEDURE reverse_ra_recs(
   p_orig_app_id     IN NUMBER,
   p_new_app_id      IN NUMBER
                 );

/*=============================================================================
 |  PUBLIC PROCEDURE  confirm_ra_rec_update
 |
 |  DESCRIPTION:
 |                This procedure will be called from ARP_CONFIRMATION
 |                to process the mrc data for update.
 |
 |  CALLS PROCEDURES / FUNCTIONS (local to this package body)
 |
 |  PARAMETERS
 |      p_rec_app_id   IN NUMBER
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |
 |  MODIFICATION HISTORY
 |  Date        Author                  Description of Change
 |  09/04/02    Debbie Sue Jancis       Created
 *============================================================================*/
PROCEDURE confirm_ra_rec_update(
   p_rec_app_id      IN NUMBER
                      );


/*=============================================================================
 |  PUBLIC PROCEDURE  update_cm_application
 |
 |  DESCRIPTION:
 |                This procedure will be called from PRO*C files in the
 |                /src/paysched directory (araups.lpc and araupds.lpc)
 |                to process the mrc data for update.
 |
 |  CALLS PROCEDURES / FUNCTIONS (local to this package body)
 |
 |  PARAMETERS
 |      p_rec_app_id      IN NUMBER
 |      p_app_ps_id       IN NUMBER,
 |      p_ct_id           IN NUMBER,
 |      p_amount_applied  IN NUMBER
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |
 |  MODIFICATION HISTORY
 |  Date        Author                  Description of Change
 |  09/04/02    Debbie Sue Jancis       Created
 *============================================================================*/
PROCEDURE update_cm_application(
   p_rec_app_id      IN NUMBER,
   p_app_ps_id       IN NUMBER,
   p_ct_id           IN NUMBER,
   p_amount_applied  IN NUMBER
                 );

/*=============================================================================
 |  PUBLIC PROCEDURE  update_ra_rec_quickcash
 |
 |  DESCRIPTION:
 |                This procedure will be called from PRO*C files in the
 |                /src/cash directory
 |                to process the mrc data for update.
 |
 |  CALLS PROCEDURES / FUNCTIONS (local to this package body)
 |
 |  PARAMETERS
 |      p_rec_app_id      IN NUMBER
 |      p_cash_receipt_id IN NUMBER,
 |      p_amount_applied  IN NUMBER
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |
 |  MODIFICATION HISTORY
 |  Date        Author                  Description of Change
 |  09/04/02    Debbie Sue Jancis       Created
 *============================================================================*/
PROCEDURE update_ra_rec_quickcash(
   p_rec_app_id      IN NUMBER,
   p_cash_receipt_id IN NUMBER,
   p_amount_applied  IN NUMBER
                 ) ;

/*=============================================================================
 |  PUBLIC PROCEDURE  insert_ra_rec_quickcash
 |
 |  DESCRIPTION:
 |                This procedure will be called from PRO*C files in the
 |                /src/cash directory
 |                to process the mrc data for insert.
 |
 |  CALLS PROCEDURES / FUNCTIONS (local to this package body)
 |
 |  PARAMETERS
 |      p_rec_app_id      IN NUMBER
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |
 |  MODIFICATION HISTORY
 |  Date        Author                  Description of Change
 |  09/04/02    Debbie Sue Jancis       Created
 *============================================================================*/
PROCEDURE insert_ra_rec_quickcash(
   p_rec_app_id      IN NUMBER
                 );

/*=============================================================================
 |  PUBLIC PROCEDURE  update_selected_transaction
 |
 |  DESCRIPTION:
 |                This procedure will be called from
 |                ARP_PROCESS_APPLICATION(ARCEAPPB.pls)
 |                to process the mrc data for insert.
 |
 |  CALLS PROCEDURES / FUNCTIONS (local to this package body)
 |
 |  PARAMETERS
 |      pn_amount_applied IN NUMBER
 |      p_app_ra_rec      IN ar_receivable_applications%ROWTYPE
 |      p_unapp_ra_rec    IN ar_receivable_applications%ROWTYPE
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |
 |  MODIFICATION HISTORY
 |  Date        Author                  Description of Change
 |  09/09/02    Debbie Sue Jancis       Created
 *============================================================================*/
PROCEDURE update_selected_transaction(
   pn_amount_applied   IN NUMBER,
   p_app_ra_rec        IN ar_receivable_applications%ROWTYPE,
   p_unapp_ra_rec      IN ar_receivable_applications%ROWTYPE
                 );

/*=============================================================================
 |  PUBLIC PROCEDURE  activity_application
 |
 |  DESCRIPTION:
 |                This procedure will be called from
 |                ARP_PROCESS_APPLICATION(ARCEAPPB.pls)
 |                to process the mrc data for insert.
 |
 |  CALLS PROCEDURES / FUNCTIONS (local to this package body)
 |
 |  PARAMETERS
 |      p_receipt_ps_id       IN ar_payment_schedules.payment_schedule_id%TYPE
 |      p_amount_applied      IN NUMBER
 |      p_application_ref_id  IN NUMBER
 |      p_misc_ref_id         IN NUMBER
 |      p_application_ps_id   IN NUMBER
 |      p_activity_ra_rec     IN ar_receivable_applications%ROWTYPE
 |      p_unapp_ra_rec        IN ar_receivable_applications%ROWTYPE
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |
 |  MODIFICATION HISTORY
 |  Date        Author                  Description of Change
 |  09/09/02    Debbie Sue Jancis       Created
 *============================================================================*/
PROCEDURE activity_application(
        p_receipt_ps_id       IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_amount_applied      IN NUMBER,
        p_application_ref_id  IN NUMBER,
        p_misc_ref_id         IN NUMBER,
        p_application_ps_id   IN NUMBER,
        p_activity_ra_rec     IN ar_receivable_applications%ROWTYPE,
        p_unapp_ra_rec        IN ar_receivable_applications%ROWTYPE
                 );

/*=============================================================================
 |  PUBLIC PROCEDURE  rate_adj_insert_rec
 |
 |  DESCRIPTION:
 |                This procedure will be called from
 |                ARP_RATE_ADJUSTMENT
 |                to process the mrc data for insert.
 |
 |  CALLS PROCEDURES / FUNCTIONS (local to this package body)
 |
 |  PARAMETERS
 |        p_app_ra_rec          IN AR_RECEIVABLE_APPLICATIONS%ROWTYPE
 |        p_unapp_ra_rec        IN AR_RECEIVABLE_APPLICATIONS%ROWTYPE
 |        p_rec_orig_app_id     IN NUMBER
 |        p_rec_app_id          IN NUMBER
 |        p_rec_unapp_id        IN NUMBER
 |        p_amt_due_remaining   IN NUMBER
 |
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date        Author                  Description of Change
 |  09/09/02    Debbie Sue Jancis       Created
 *============================================================================*/
PROCEDURE rate_adj_insert_rec (
          p_app_ra_rec          IN AR_RECEIVABLE_APPLICATIONS%ROWTYPE,
          p_unapp_ra_rec        IN AR_RECEIVABLE_APPLICATIONS%ROWTYPE,
          p_rec_orig_app_id     IN NUMBER,
          p_rec_app_id          IN NUMBER,
          p_rec_unapp_id        IN NUMBER,
          p_amt_due_remaining   IN NUMBER);

/*=============================================================================
 |  PUBLIC PROCEDURE  confirm_ra_rec_create
 |
 |  DESCRIPTION:
 |                This procedure will be called from
 |                ARP_confirmation
 |                to process the mrc data for insert.
 |
 |  CALLS PROCEDURES / FUNCTIONS (local to this package body)
 |
 |  PARAMETERS
 |        p_rec_record          IN arp_confirmation.new_con_data
 |
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |
 |  MODIFICATION HISTORY
 |  Date        Author                  Description of Change
 |  09/16/02    Debbie Sue Jancis       Created
 *============================================================================*/
PROCEDURE confirm_ra_rec_create(
          p_rec_record      IN ARP_CONFIRMATION.NEW_CON_DATA
                               ) ;

/*=============================================================================
 |  PUBLIC PROCEDURE  update_ra_rec_cash_diff
 |
 |  DESCRIPTION:
 |                This procedure will be called from
 |                ARP_PROC_RECEIPTS1
 |                to process the mrc data for receivable applications
 |                this was created for bug 2576372.
 |
 |  CALLS PROCEDURES / FUNCTIONS (local to this package body)
 |
 |  PARAMETERS
 |        p_rec_app_id          IN NUMBER,
 |        p_cash_Receipt_id     IN ar_cash_Receipts.cash_Receipt_id%type
 |        p_diff_amount         IN ar_cash_Receipts.amount%TYPE
 |        p_old_rcpt_amount     IN ar_cash_Receipts.amount%TYPE
 |        p_payment_schedule_id IN ar_payment_schedules.payment_schedule_id%TYPE
 |
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |
 |  MODIFICATION HISTORY
 |  Date        Author                  Description of Change
 |  09/20/02    Debbie Sue Jancis       Created for bug 2576372
 *============================================================================*/
PROCEDURE update_ra_rec_cash_diff(
       p_rec_app_id          IN NUMBER,
       p_cash_receipt_id     IN ar_cash_receipts.cash_receipt_id%TYPE,
       p_diff_amount         IN ar_cash_receipts.amount%TYPE,
       p_old_rcpt_amount     IN ar_cash_receipts.amount%TYPE,
       p_payment_schedule_id IN ar_payment_schedules.payment_schedule_id%TYPE
                                 );
END AR_MRC_ENGINE3;

 

/
