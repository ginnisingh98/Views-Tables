--------------------------------------------------------
--  DDL for Package Body AR_MRC_ENGINE3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_MRC_ENGINE3" AS
/* $Header: ARMCEN3B.pls 120.2 2005/04/14 22:40:29 hyu noship $ */

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
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE insert_ra_rec_cash(
        p_rec_app_id            IN NUMBER,
        p_rec_app_record        IN ar_receivable_applications%ROWTYPE,
        p_cash_receipt_id       IN ar_cash_receipts.cash_receipt_id%TYPE,
        p_amount                IN ar_cash_receipts.amount%TYPE,
        p_payment_schedule_id   IN ar_payment_schedules.payment_schedule_id%TYPE
                        ) IS
BEGIN
NULL;
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug( 'AR_MRC_ENGINE3.insert_ra_rec_cash(+)');
--   END IF;

   /*-----------------------------------------------------------------+
    |  Dump the input parameters for debugging purposes               |
    +-----------------------------------------------------------------*/

--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('insert_ra_rec_cash: ' || ' p_rec_app_id        : ' || to_char(p_rec_app_id));
--      arp_standard.debug('insert_ra_rec_cash: ' || ' cash Receipt id     : ' || to_char(p_cash_receipt_id));
--      arp_standard.debug('insert_ra_rec_cash: ' || ' Amount              : ' || to_char(p_amount));
--      arp_standard.debug('insert_ra_rec_cash: ' || ' payment schedule id : ' || to_char(p_payment_schedule_id));
--   END IF;

   /*-----------------------------------------------------------------+
    |  First we need to check if MRC is enabled.  If it is than we    |
    |  continue processing.  If it is not then we are finished.       |
    +-----------------------------------------------------------------*/
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('insert_ra_rec_cash: ' || 'before checking to see if mrc is enabled..');
--   END IF;
--   IF (gl_ca_utility_pkg.mrc_enabled(
--                    p_sob_id => ar_mc_info.primary_sob_id,
--                    p_org_id => ar_mc_info.org_id,
--                    p_appl_id => 222
--                          ))  THEN

--        IF PG_DEBUG in ('Y', 'C') THEN
--           arp_standard.debug('insert_ra_rec_cash: ' || 'MRC is enabled...     ');
--        END IF;

--           BEGIN
--                ar_mc_rec_apps_pkg.insert_ra_rec_cash(
--                              p_rec_app_id          => p_rec_app_id,
--                              p_rec_app_record      => p_rec_app_record,
--                              p_cash_receipt_id     => p_cash_receipt_id,
--                              p_amount              => p_amount,
--                              p_payment_schedule_id => p_payment_schedule_id);
--           EXCEPTION
--            WHEN OTHERS THEN
--              IF PG_DEBUG in ('Y', 'C') THEN
--                 arp_standard.debug('insert_ra_rec_cash: ' || 'error during insert for AR_RECEIVABLES_APPS');
--              END IF;
--              APP_EXCEPTION.RAISE_EXCEPTION;
--           END;

--    END IF;  /* end of mrc is enabled */

--  IF PG_DEBUG in ('Y', 'C') THEN
--     arp_standard.debug( 'AR_MRC_ENGINE3.insert_ra_rec_cash(-)');
--  END IF;

END insert_ra_rec_cash;

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
 |  09/03/02    Debbie Sue Jancis  	Created
 *============================================================================*/
PROCEDURE create_matching_unapp_records(
        p_rec_app_id            IN NUMBER,
        p_rec_unapp_id          IN NUMBER
                        ) IS
BEGIN
NULL;
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug( 'AR_MRC_ENGINE3.create_matching_unapp_records(+)');
--   END IF;

   /*-----------------------------------------------------------------+
    |  Dump the input parameters for debugging purposes               |
    +-----------------------------------------------------------------*/

--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('create_matching_unapp_records: ' || ' p_rec_app_id        : ' || to_char(p_rec_app_id));
--      arp_standard.debug('create_matching_unapp_records: ' || ' p_rec_unapp_id      : ' || to_char(p_rec_unapp_id));
--   END IF;

   /*-----------------------------------------------------------------+
    |  First we need to check if MRC is enabled.  If it is than we    |
    |  continue processing.  If it is not then we are finished.       |
    +-----------------------------------------------------------------*/
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('create_matching_unapp_records: ' || 'before checking to see if mrc is enabled..');
--   END IF;
--   IF (gl_ca_utility_pkg.mrc_enabled(
--                    p_sob_id => ar_mc_info.primary_sob_id,
--                    p_org_id => ar_mc_info.org_id,
--                    p_appl_id => 222
--                          ))  THEN

--        IF PG_DEBUG in ('Y', 'C') THEN
--           arp_standard.debug('create_matching_unapp_records: ' || 'MRC is enabled...     ');
--        END IF;

--           BEGIN
--                ar_mc_rec_apps_pkg.create_matching_unapp_records(
--                              p_rec_app_id     => p_rec_app_id,
--                              p_rec_unapp_id   => p_rec_unapp_id);
--           EXCEPTION
--            WHEN OTHERS THEN
--              IF PG_DEBUG in ('Y', 'C') THEN
--                 arp_standard.debug('create_matching_unapp_records: ' || 'error during MRC create matching unapp recs');
--              END IF;
--              APP_EXCEPTION.RAISE_EXCEPTION;
--           END;

--    END IF;  /* end of mrc is enabled */

--  IF PG_DEBUG in ('Y', 'C') THEN
--     arp_standard.debug( 'AR_MRC_ENGINE3.create_matching_unapp_records(-)');
--  END IF;

END create_matching_unapp_records;

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
                        ) IS
BEGIN
NULL;
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug( 'AR_MRC_ENGINE3.receipt_application(+)');
--   END IF;

   /*-----------------------------------------------------------------+
    |  Dump the input parameters for debugging purposes               |
    +----------------------------------------------------------------*/

--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('receipt_application: ' || ' p_receipt_ps_id  : ' || to_char(p_receipt_ps_id));
--      arp_standard.debug('receipt_application: ' || ' p_invoice_ps_id  : ' || to_char(p_invoice_ps_id));
--      arp_standard.debug('receipt_application: ' || ' p_amount_applied : ' || to_char(p_amount_applied));
--      arp_standard.debug('receipt_application: ' || ' p_amount_applied_from : ' ||
--                          to_char(p_amount_applied_from));
--      arp_standard.debug('receipt_application: ' || ' p_invoice_currency_code : ' || p_invoice_currency_code);
--      arp_standard.debug('receipt_application: ' || ' p_receipt_currency_code : ' || p_receipt_currency_code);
--   END IF;

   /*-----------------------------------------------------------------+
    |  First we need to check if MRC is enabled.  If it is than we    |
    |  continue processing.  If it is not then we are finished.       |
    +-----------------------------------------------------------------*/
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('receipt_application: ' || 'before checking to see if mrc is enabled..');
--   END IF;
--   IF (gl_ca_utility_pkg.mrc_enabled(
--                    p_sob_id => ar_mc_info.primary_sob_id,
--                    p_org_id => ar_mc_info.org_id,
--                    p_appl_id => 222
--                          ))  THEN

--        IF PG_DEBUG in ('Y', 'C') THEN
--           arp_standard.debug('receipt_application: ' || 'MRC is enabled...     ');
--        END IF;

--           BEGIN
--                ar_mc_rec_apps_pkg.receipt_application(
--                      p_receipt_ps_id         => p_receipt_ps_id,
--                      p_invoice_ps_id         => p_invoice_ps_id,
--                      p_amount_applied        => p_amount_applied,
--                      p_amount_applied_from   => p_amount_applied_from,
--                      p_invoice_currency_code => p_invoice_currency_code,
--                      p_receipt_currency_code => p_receipt_currency_code,
--                      p_rec_ra_rec            => p_rec_ra_rec,
--                      p_inv_ra_rec            => p_inv_ra_rec);
--           EXCEPTION
--            WHEN OTHERS THEN
--              IF PG_DEBUG in ('Y', 'C') THEN
--                 arp_standard.debug('receipt_application: ' || 'error during MRC receipt application');
--              END IF;
--              APP_EXCEPTION.RAISE_EXCEPTION;
--           END;

--    END IF;  /* end of mrc is enabled */

--  IF PG_DEBUG in ('Y', 'C') THEN
--     arp_standard.debug( 'AR_MRC_ENGINE3.receipt_application(-)');
--  END IF;

END receipt_application;

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
 |      p_ra_id            IN NUMBER receivable_application_id
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |
 |  MODIFICATION HISTORY
 |  Date        Author                  Description of Change
 |  09/04/02    Debbie Sue Jancis       Created
 *============================================================================*/
PROCEDURE cm_application(
   p_cm_ps_id       IN ar_payment_schedules.payment_schedule_id%TYPE,
   p_invoice_ps_id  IN ar_payment_schedules.payment_schedule_id%TYPE,
   p_inv_ra_rec     IN ar_receivable_applications %ROWTYPE,
   p_ra_id          IN NUMBER
                 ) IS

l_ra_rec  ar_receivable_applications%ROWTYPE;

BEGIN
NULl;
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug( 'AR_MRC_ENGINE3.cm_application(+)');
--   END IF;
   /*-----------------------------------------------------------------+
    |  Dump the input parameters for debugging purposes               |
    +----------------------------------------------------------------*/

--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('cm_application: ' || ' p_cm_ps_id  : ' || to_char(p_cm_ps_id));
--      arp_standard.debug('cm_application: ' || ' p_invoice_ps_id  : ' || to_char(p_invoice_ps_id));
--   END IF;

   /*-----------------------------------------------------------------+
    |  First we need to check if MRC is enabled.  If it is than we    |
    |  continue processing.  If it is not then we are finished.       |
    +-----------------------------------------------------------------*/
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('cm_application: ' || 'before checking to see if mrc is enabled..');
--   END IF;
--   IF (gl_ca_utility_pkg.mrc_enabled(
--                    p_sob_id => ar_mc_info.primary_sob_id,
--                    p_org_id => ar_mc_info.org_id,
--                    p_appl_id => 222
--                          ))  THEN

--        IF PG_DEBUG in ('Y', 'C') THEN
--           arp_standard.debug('cm_application: ' || 'MRC is enabled...     ');
--        END IF;

--        IF (p_inv_ra_rec.receivable_application_id IS NULL) THEN
--           select *
--            INTO l_ra_rec
--            from ar_receivable_applications
--           where receivable_application_id = p_ra_id;
--        ELSE
--           l_ra_rec := p_inv_ra_rec;
--        END IF;

--           BEGIN
--                ar_mc_rec_apps_pkg.cm_application(
--                      p_cm_ps_id         => p_cm_ps_id,
--                      p_invoice_ps_id    => p_invoice_ps_id,
--                      p_inv_ra_rec       => l_ra_rec);
--           EXCEPTION
--            WHEN OTHERS THEN
--              IF PG_DEBUG in ('Y', 'C') THEN
--                 arp_standard.debug('cm_application: ' || 'error during MRC cm application');
--              END IF;
--              APP_EXCEPTION.RAISE_EXCEPTION;
--           END;

--    END IF;  /* end of mrc is enabled */

--  IF PG_DEBUG in ('Y', 'C') THEN
--     arp_standard.debug( 'AR_MRC_ENGINE3.cm_application(-)');
--  END IF;

END cm_application;

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
                 ) IS
BEGIN
NULL;
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug( 'AR_MRC_ENGINE3.on_account_receipts(+)');
--   END IF;
   /*-----------------------------------------------------------------+
    |  Dump the input parameters for debugging purposes               |
    +----------------------------------------------------------------*/

--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('on_account_receipts: ' || ' p_receipt_ps_id  : ' || to_char(p_receipt_ps_id));
--      arp_standard.debug('on_account_receipts: ' || ' p_amount_applied : ' || to_char(p_amount_applied));
--      arp_standard.debug('on_account_receipts: ' || ' p_unapp_rec_app_id:' || to_char(p_unapp_rec_app_id));
--   END IF;

   /*-----------------------------------------------------------------+
    |  First we need to check if MRC is enabled.  If it is than we    |
    |  continue processing.  If it is not then we are finished.       |
    +-----------------------------------------------------------------*/
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('on_account_receipts: ' || 'before checking to see if mrc is enabled..');
--   END IF;
--   IF (gl_ca_utility_pkg.mrc_enabled(
--                    p_sob_id => ar_mc_info.primary_sob_id,
--                    p_org_id => ar_mc_info.org_id,
--                    p_appl_id => 222
--                          ))  THEN

--        IF PG_DEBUG in ('Y', 'C') THEN
--           arp_standard.debug('on_account_receipts: ' || 'MRC is enabled...     ');
--        END IF;

--           BEGIN
--                ar_mc_rec_apps_pkg.on_account_receipts(
--                      p_receipt_ps_id     => p_receipt_ps_id,
--                      p_amount_applied    => p_amount_applied,
--                      p_acc_ra_rec        => p_acc_ra_rec,
--                      p_unapp_rec_app_id  => p_unapp_rec_app_id);
--           EXCEPTION
--            WHEN OTHERS THEN
--              IF PG_DEBUG in ('Y', 'C') THEN
--                 arp_standard.debug('error during MRC on_account_receipts');
--              END IF;
--              APP_EXCEPTION.RAISE_EXCEPTION;
--           END;

--    END IF;  /* end of mrc is enabled */

--  IF PG_DEBUG in ('Y', 'C') THEN
--     arp_standard.debug( 'AR_MRC_ENGINE3.on_account_receipts(-)');
--  END IF;

END on_account_receipts;

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
                 ) IS
BEGIN
NULL;
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug( 'AR_MRC_ENGINE3.other_account_application(+)');
--   END IF;
   /*-----------------------------------------------------------------+
    |  Dump the input parameters for debugging purposes               |
    +----------------------------------------------------------------*/

--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('other_account_application: ' || ' p_receipt_ps_id  : ' || to_char(p_receipt_ps_id));
--      arp_standard.debug('other_account_application: ' || ' p_amount_applied : ' || to_char(p_amount_applied));
--      arp_standard.debug('other_account_application: ' || ' p_unapp_rec_app_id:' || to_char(p_unapp_rec_app_id));
--   END IF;

   /*-----------------------------------------------------------------+
    |  First we need to check if MRC is enabled.  If it is than we    |
    |  continue processing.  If it is not then we are finished.       |
    +-----------------------------------------------------------------*/
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('other_account_application: ' || 'before checking to see if mrc is enabled..');
--   END IF;
--   IF (gl_ca_utility_pkg.mrc_enabled(
--                    p_sob_id => ar_mc_info.primary_sob_id,
--                    p_org_id => ar_mc_info.org_id,
--                    p_appl_id => 222
--                          ))  THEN

--        IF PG_DEBUG in ('Y', 'C') THEN
--           arp_standard.debug('other_account_application: ' || 'MRC is enabled...     ');
--        END IF;

--           BEGIN
--                ar_mc_rec_apps_pkg.other_account_application(
--                      p_receipt_ps_id     => p_receipt_ps_id,
--                      p_amount_applied    => p_amount_applied,
--                      p_otheracc_ra_rec   => p_otheracc_ra_rec,
--                      p_unapp_rec_app_id  => p_unapp_rec_app_id);
--           EXCEPTION
--            WHEN OTHERS THEN
--              IF PG_DEBUG in ('Y', 'C') THEN
--                 arp_standard.debug('error during MRC other_account_application');
--              END IF;
--              APP_EXCEPTION.RAISE_EXCEPTION;
--           END;

--    END IF;  /* end of mrc is enabled */

--  IF PG_DEBUG in ('Y', 'C') THEN
--     arp_standard.debug( 'AR_MRC_ENGINE3.other_account_application(-)');
--  END IF;

 END other_account_application;

/*=============================================================================
 |  PUBLIC PROCEDURE  reversal_insert_oppos_ra_recs
 |
 |  DESCRIPTION:
 |                This procedure will be called from ARP_PROCESS_APPLICATION
 |                and ARP_RATE_ADJUSTMENTS
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
                 ) IS
BEGIN
NULL;
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug( 'AR_MRC_ENGINE3.reversal_insert_oppos_ra_recs(+)');
--   END IF;
   /*-----------------------------------------------------------------+
    |  Dump the input parameters for debugging purposes               |
    +----------------------------------------------------------------*/

--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('reversal_insert_oppos_ra_recs: ' || ' p_orig_rec_app_id:' || to_char(p_orig_rec_app_id));
--      arp_standard.debug('reversal_insert_oppos_ra_recs: ' || ' p_new_rec_app_id :' || to_char(p_new_rec_app_id));
--   END IF;

   /*-----------------------------------------------------------------+
    |  First we need to check if MRC is enabled.  If it is than we    |
    |  continue processing.  If it is not then we are finished.       |
    +-----------------------------------------------------------------*/
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('reversal_insert_oppos_ra_recs: ' || 'before checking to see if mrc is enabled..');
--   END IF;
--   IF (gl_ca_utility_pkg.mrc_enabled(
--                    p_sob_id => ar_mc_info.primary_sob_id,
--                    p_org_id => ar_mc_info.org_id,
--                    p_appl_id => 222
--                          ))  THEN

--        IF PG_DEBUG in ('Y', 'C') THEN
--           arp_standard.debug('reversal_insert_oppos_ra_recs: ' || 'MRC is enabled...     ');
--        END IF;

--           BEGIN
--                ar_mc_rec_apps_pkg.reversal_insert_oppos_ra_recs(
--                      p_ra_rec           => p_ra_rec,
--                      p_orig_rec_app_id  => p_orig_rec_app_id,
--                      p_new_rec_app_id   => p_new_rec_app_id);
--           EXCEPTION
--            WHEN OTHERS THEN
--              IF PG_DEBUG in ('Y', 'C') THEN
--                 arp_standard.debug('error during MRC reversal_insert_oppos_ra_recs');
--              END IF;
--              APP_EXCEPTION.RAISE_EXCEPTION;
--           END;

--    END IF;  /* end of mrc is enabled */

--  IF PG_DEBUG in ('Y', 'C') THEN
--     arp_standard.debug( 'AR_MRC_ENGINE3.reversal_insert_oppos_ra_recs(-)');
--  END IF;

 END reversal_insert_oppos_ra_recs;

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
                 ) IS
BEGIN
NULL;
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug( 'AR_MRC_ENGINE3.reverse_ra_recs(+)');
--   END IF;
   /*-----------------------------------------------------------------+
    |  Dump the input parameters for debugging purposes               |
    +----------------------------------------------------------------*/

--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('reverse_ra_recs: ' || ' p_orig_rec_app_id:' || to_char(p_orig_app_id));
--      arp_standard.debug('reverse_ra_recs: ' || ' p_new_rec_app_id :' || to_char(p_new_app_id));
--   END IF;

   /*-----------------------------------------------------------------+
    |  First we need to check if MRC is enabled.  If it is than we    |
    |  continue processing.  If it is not then we are finished.       |
    +-----------------------------------------------------------------*/
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('reverse_ra_recs: ' || 'before checking to see if mrc is enabled..');
--   END IF;
--   IF (gl_ca_utility_pkg.mrc_enabled(
--                    p_sob_id => ar_mc_info.primary_sob_id,
--                    p_org_id => ar_mc_info.org_id,
--                    p_appl_id => 222
--                          ))  THEN

--        IF PG_DEBUG in ('Y', 'C') THEN
--           arp_standard.debug('reverse_ra_recs: ' || 'MRC is enabled...     ');
--        END IF;

--           BEGIN
--                ar_mc_rec_apps_pkg.reverse_ra_recs(
--                      p_orig_app_id  => p_orig_app_id,
--                      p_new_app_id   => p_new_app_id);
--           EXCEPTION
--            WHEN OTHERS THEN
--              IF PG_DEBUG in ('Y', 'C') THEN
--                 arp_standard.debug('error during MRC reverse_ra_recs ');
--              END IF;
--              APP_EXCEPTION.RAISE_EXCEPTION;
--           END;

--    END IF;  /* end of mrc is enabled */

--  IF PG_DEBUG in ('Y', 'C') THEN
--     arp_standard.debug( 'AR_MRC_ENGINE3.reverse_ra_recs(-)');
--  END IF;

 END reverse_ra_recs;

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
                 ) IS
BEGIN
NULL;
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug( 'AR_MRC_ENGINE3.confirm_ra_rec_update(+)');
--   END IF;
   /*-----------------------------------------------------------------+
    |  Dump the input parameters for debugging purposes               |
    +----------------------------------------------------------------*/

--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('confirm_ra_rec_update: ' || ' p_rec_app_id :' || to_char(p_rec_app_id));
--   END IF;

   /*-----------------------------------------------------------------+
    |  First we need to check if MRC is enabled.  If it is than we    |
    |  continue processing.  If it is not then we are finished.       |
    +-----------------------------------------------------------------*/
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('confirm_ra_rec_update: ' || 'before checking to see if mrc is enabled..');
--   END IF;
--   IF (gl_ca_utility_pkg.mrc_enabled(
--                    p_sob_id => ar_mc_info.primary_sob_id,
--                    p_org_id => ar_mc_info.org_id,
--                    p_appl_id => 222
--                          ))  THEN
--        IF PG_DEBUG in ('Y', 'C') THEN
--           arp_standard.debug('confirm_ra_rec_update: ' || 'MRC is enabled...     ');
--        END IF;

--           BEGIN
--                ar_mc_rec_apps_pkg.confirm_ra_rec_update(
--                      p_rec_app_id   => p_rec_app_id);
--           EXCEPTION
--            WHEN OTHERS THEN
--              IF PG_DEBUG in ('Y', 'C') THEN
--                 arp_standard.debug('error during MRC confirm_ra_rec_update ');
--              END IF;
--              APP_EXCEPTION.RAISE_EXCEPTION;
--           END;

--    END IF;  /* end of mrc is enabled */

--  IF PG_DEBUG in ('Y', 'C') THEN
--     arp_standard.debug( 'AR_MRC_ENGINE3.confirm_ra_rec_update(-)');
--  END IF;

 END confirm_ra_rec_update;

/*=============================================================================
 |  PUBLIC PROCEDURE  update_cm_application
 |
 |  DESCRIPTION:
 |                This procedure will be called from PRO*C files in the
 |		  /src/paysched directory (araups.lpc and araupds.lpc)
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
                 ) IS
BEGIN
NULL;
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug( 'AR_MRC_ENGINE3.update_cm_application(+)');
--   END IF;
   /*-----------------------------------------------------------------+
    |  Dump the input parameters for debugging purposes               |
    +----------------------------------------------------------------*/

--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('update_cm_application: ' || ' p_rec_app_id     :' || to_char(p_rec_app_id));
--      arp_standard.debug('update_cm_application: ' || ' p_app_ps_id      :' || to_char(p_app_ps_id));
--      arp_standard.debug('update_cm_application: ' || ' p_ct_id          :' || to_char(p_ct_id));
--      arp_standard.debug('update_cm_application: ' || ' p_amount_applied :' || to_char(p_amount_applied));
--   END IF;

   /*-----------------------------------------------------------------+
    |  First we need to check if MRC is enabled.  If it is than we    |
    |  continue processing.  If it is not then we are finished.       |
    +-----------------------------------------------------------------*/
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('update_cm_application: ' || 'before checking to see if mrc is enabled..');
--   END IF;
--   IF (gl_ca_utility_pkg.mrc_enabled(
--                    p_sob_id => ar_mc_info.primary_sob_id,
--                    p_org_id => ar_mc_info.org_id,
--                    p_appl_id => 222
--                          ))  THEN
--        IF PG_DEBUG in ('Y', 'C') THEN
--           arp_standard.debug('update_cm_application: ' || 'MRC is enabled...     ');
--        END IF;

--           BEGIN
--                ar_mc_rec_apps_pkg.update_cm_application(
--                      p_rec_app_id      => p_rec_app_id,
--                      p_app_ps_id       => p_app_ps_id,
--                      p_ct_id           => p_ct_id,
--                      p_amount_applied  => p_amount_applied);
--           EXCEPTION
--            WHEN OTHERS THEN
--              IF PG_DEBUG in ('Y', 'C') THEN
--                 arp_standard.debug('error during MRC update_cm_application ');
--              END IF;
--              APP_EXCEPTION.RAISE_EXCEPTION;
--           END;

--    END IF;  /* end of mrc is enabled */

--  IF PG_DEBUG in ('Y', 'C') THEN
--     arp_standard.debug( 'AR_MRC_ENGINE3.update_cm_application(-)');
--  END IF;

 END update_cm_application;

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
                 ) IS
BEGIN
NULL;
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug( 'AR_MRC_ENGINE3.update_ra_rec_quickcash(+)');
--   END IF;
   /*-----------------------------------------------------------------+
    |  Dump the input parameters for debugging purposes               |
    +----------------------------------------------------------------*/

--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('update_ra_rec_quickcash: ' || ' p_rec_app_id      :' || to_char(p_rec_app_id));
--      arp_standard.debug('update_ra_rec_quickcash: ' || ' p_cash_receipt_id :' || to_char(p_cash_receipt_id));
--      arp_standard.debug('update_ra_rec_quickcash: ' || ' p_amount_applied  :' || to_char(p_amount_applied));
--   END IF;

   /*-----------------------------------------------------------------+
    |  First we need to check if MRC is enabled.  If it is than we    |
    |  continue processing.  If it is not then we are finished.       |
    +-----------------------------------------------------------------*/
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('update_ra_rec_quickcash: ' || 'before checking to see if mrc is enabled..');
--   END IF;
--   IF (gl_ca_utility_pkg.mrc_enabled(
--                    p_sob_id => ar_mc_info.primary_sob_id,
--                    p_org_id => ar_mc_info.org_id,
--                    p_appl_id => 222
--                          ))  THEN
--        IF PG_DEBUG in ('Y', 'C') THEN
--           arp_standard.debug('update_ra_rec_quickcash: ' || 'MRC is enabled...     ');
--        END IF;

--           BEGIN
--                ar_mc_rec_apps_pkg.update_ra_rec_quickcash(
--                      p_rec_app_id      => p_rec_app_id,
--                      p_cash_receipt_id => p_cash_receipt_id,
--                      p_amount_applied  => p_amount_applied);
--           EXCEPTION
--            WHEN OTHERS THEN
--              IF PG_DEBUG in ('Y', 'C') THEN
--                 arp_standard.debug('error during MRC update_ra_rec_quickcash ');
--              END IF;
--              APP_EXCEPTION.RAISE_EXCEPTION;
--           END;

--    END IF;  /* end of mrc is enabled */
--  IF PG_DEBUG in ('Y', 'C') THEN
--     arp_standard.debug( 'AR_MRC_ENGINE3.update_ra_rec_quickcash(-)');
--  END IF;

 END update_ra_rec_quickcash;

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
                 ) IS
BEGIN
NULL;
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug( 'AR_MRC_ENGINE3.insert_ra_rec_quickcash(+)');
--   END IF;
   /*-----------------------------------------------------------------+
    |  Dump the input parameters for debugging purposes               |
    +----------------------------------------------------------------*/

--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('insert_ra_rec_quickcash: ' || ' p_rec_app_id      :' || to_char(p_rec_app_id));
--   END IF;

   /*-----------------------------------------------------------------+
    |  First we need to check if MRC is enabled.  If it is than we    |
    |  continue processing.  If it is not then we are finished.       |
    +-----------------------------------------------------------------*/
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('insert_ra_rec_quickcash: ' || 'before checking to see if mrc is enabled..');
--   END IF;
--   IF (gl_ca_utility_pkg.mrc_enabled(
--                    p_sob_id => ar_mc_info.primary_sob_id,
--                    p_org_id => ar_mc_info.org_id,
--                    p_appl_id => 222
--                          ))  THEN
--        IF PG_DEBUG in ('Y', 'C') THEN
--           arp_standard.debug('insert_ra_rec_quickcash: ' || 'MRC is enabled...     ');
--        END IF;

--           BEGIN
--                ar_mc_rec_apps_pkg.insert_ra_rec_quickcash(
--                      p_rec_app_id      => p_rec_app_id);
--           EXCEPTION
--            WHEN OTHERS THEN
--              IF PG_DEBUG in ('Y', 'C') THEN
--                 arp_standard.debug('error during MRC insert_ra_rec_quickcash ');
--              END IF;
--              APP_EXCEPTION.RAISE_EXCEPTION;
--           END;

--    END IF;  /* end of mrc is enabled */
--  IF PG_DEBUG in ('Y', 'C') THEN
--     arp_standard.debug( 'AR_MRC_ENGINE3.insert_ra_rec_quickcash(-)');
--  END IF;

 END insert_ra_rec_quickcash;

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
                 ) IS
BEGIN
NULL;
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug( 'AR_MRC_ENGINE3.update_selected_transaction(+)');
--   END IF;
   /*-----------------------------------------------------------------+
    |  Dump the input parameters for debugging purposes               |
    +----------------------------------------------------------------*/

--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('update_selected_transaction: ' || ' pn_amount_applied :' || to_char(pn_amount_applied));
--   END IF;

   /*-----------------------------------------------------------------+
    |  First we need to check if MRC is enabled.  If it is than we    |
    |  continue processing.  If it is not then we are finished.       |
    +-----------------------------------------------------------------*/
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('update_selected_transaction: ' || 'before checking to see if mrc is enabled..');
--   END IF;
--   IF (gl_ca_utility_pkg.mrc_enabled(
--                    p_sob_id => ar_mc_info.primary_sob_id,
--                    p_org_id => ar_mc_info.org_id,
--                    p_appl_id => 222
--                          ))  THEN
--        IF PG_DEBUG in ('Y', 'C') THEN
--           arp_standard.debug('update_selected_transaction: ' || 'MRC is enabled...     ');
--        END IF;
--           BEGIN
--                ar_mc_rec_apps_pkg.update_selected_transaction(
--                      pn_amount_applied => pn_amount_applied,
--                      p_app_ra_rec      => p_app_ra_rec,
--                      p_unapp_ra_rec    => p_unapp_ra_rec);
--           EXCEPTION
--            WHEN OTHERS THEN
--              IF PG_DEBUG in ('Y', 'C') THEN
--                 arp_standard.debug('update_selected_transaction: ' || 'error during MRC update_selected_transacation ');
--              END IF;
--              APP_EXCEPTION.RAISE_EXCEPTION;
--           END;

--    END IF;  /* end of mrc is enabled */
--  IF PG_DEBUG in ('Y', 'C') THEN
--     arp_standard.debug( 'AR_MRC_ENGINE3.update_selected_transaction(-)');
--  END IF;

 END update_selected_transaction;

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
                 ) IS
BEGIN
NULL;
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug( 'AR_MRC_ENGINE3.activity_application(+)');
--   END IF;
   /*-----------------------------------------------------------------+
    |  Dump the input parameters for debugging purposes               |
    +----------------------------------------------------------------*/

--  IF PG_DEBUG in ('Y', 'C') THEN
--     arp_standard.debug('activity_application: ' || 'p_receipt_ps_id  :' || to_char(p_receipt_ps_id ));
--     arp_standard.debug('activity_application: ' || 'p_amount_applied :' || to_char(p_amount_applied));
--     arp_standard.debug('activity_application: ' || 'p_application_ref_id :' || to_char(p_application_ref_id));
--     arp_standard.debug('activity_application: ' || 'p_misc_ref_id    :' || to_char(p_misc_ref_id));
--     arp_standard.debug('activity_application: ' || 'p_application_ps_id :' || to_char(p_application_ps_id));
--  END IF;

   /*-----------------------------------------------------------------+
    |  First we need to check if MRC is enabled.  If it is than we    |
    |  continue processing.  If it is not then we are finished.       |
    +-----------------------------------------------------------------*/
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('activity_application: ' || 'before checking to see if mrc is enabled..');
--   END IF;
--   IF (gl_ca_utility_pkg.mrc_enabled(
--                    p_sob_id => ar_mc_info.primary_sob_id,
--                    p_org_id => ar_mc_info.org_id,
--                    p_appl_id => 222
--                          ))  THEN
--        IF PG_DEBUG in ('Y', 'C') THEN
--           arp_standard.debug('activity_application: ' || 'MRC is enabled...     ');
--        END IF;
--           BEGIN
--                ar_mc_rec_apps_pkg.activity_application(
--                      p_receipt_ps_id      => p_receipt_ps_id,
--                      p_amount_applied     => p_amount_applied,
--                      p_application_ref_id => p_application_ref_id,
--                      p_misc_ref_id        => p_misc_ref_id,
--                      p_application_ps_id  => p_application_ps_id,
--                      p_activity_ra_rec    => p_activity_ra_rec,
--                      p_unapp_ra_rec       => p_unapp_ra_rec);
--           EXCEPTION
--            WHEN OTHERS THEN
--              IF PG_DEBUG in ('Y', 'C') THEN
--                 arp_standard.debug('error during MRC activity_application');
--              END IF;
--              APP_EXCEPTION.RAISE_EXCEPTION;
--           END;

--    END IF;  /* end of mrc is enabled */
--  IF PG_DEBUG in ('Y', 'C') THEN
--     arp_standard.debug( 'AR_MRC_ENGINE3.activity_application(-)');
--  END IF;

 END activity_application;

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
          p_amt_due_remaining   IN NUMBER)  IS
BEGIN
NULL;
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug( 'AR_MRC_ENGINE3.rate_adj_insert_rec(+)');
--   END IF;
   /*-----------------------------------------------------------------+
    |  Dump the input parameters for debugging purposes               |
    +----------------------------------------------------------------*/

--  IF PG_DEBUG in ('Y', 'C') THEN
--     arp_standard.debug('rate_adj_insert_rec: ' || 'p_rec_orig_app_id:' || to_char(p_rec_orig_app_id ));
--     arp_standard.debug('rate_adj_insert_rec: ' || 'p_rec_app_id :' || to_char(p_rec_app_id));
--     arp_standard.debug('rate_adj_insert_rec: ' || 'p_rec_unapp_id :' || to_char(p_rec_unapp_id));
--     arp_standard.debug('rate_adj_insert_rec: ' || 'p_amt_due_remaining :' || to_char(p_amt_due_remaining));
--  END IF;

   /*-----------------------------------------------------------------+
    |  First we need to check if MRC is enabled.  If it is than we    |
    |  continue processing.  If it is not then we are finished.       |
    +-----------------------------------------------------------------*/
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('rate_adj_insert_rec: ' || 'before checking to see if mrc is enabled..');
--   END IF;
--   IF (gl_ca_utility_pkg.mrc_enabled(
--                    p_sob_id => ar_mc_info.primary_sob_id,
--                    p_org_id => ar_mc_info.org_id,
--                    p_appl_id => 222
--                          ))  THEN
--        IF PG_DEBUG in ('Y', 'C') THEN
--           arp_standard.debug('rate_adj_insert_rec: ' || 'MRC is enabled...     ');
--        END IF;
--           BEGIN
--                ar_mc_rec_apps_pkg.rate_adj_insert_rec(
--                      p_app_ra_rec         => p_app_ra_rec,
--                      p_unapp_ra_rec       => p_unapp_ra_rec,
--                      p_rec_orig_app_id    => p_rec_orig_app_id,
--                      p_rec_app_id         => p_rec_app_id,
--                      p_rec_unapp_id       => p_rec_unapp_id,
--                      p_amt_due_remaining  => p_amt_due_remaining);
--           EXCEPTION
--            WHEN OTHERS THEN
--              IF PG_DEBUG in ('Y', 'C') THEN
--                 arp_standard.debug('error during MRC rate_adj_insert_rec ');
--              END IF;
--              APP_EXCEPTION.RAISE_EXCEPTION;
--           END;

--    END IF;  /* end of mrc is enabled */
--  IF PG_DEBUG in ('Y', 'C') THEN
--     arp_standard.debug( 'AR_MRC_ENGINE3.rate_adj_insert_rec(-)');
--  END IF;

 END rate_adj_insert_rec;

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
                               )  IS
BEGIN
NULL;
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug( 'AR_MRC_ENGINE3.confirm_ra_rec_create(+)');
--   END IF;
   /*-----------------------------------------------------------------+
    |  First we need to check if MRC is enabled.  If it is than we    |
    |  continue processing.  If it is not then we are finished.       |
    +-----------------------------------------------------------------*/
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('confirm_ra_rec_create: ' || 'before checking to see if mrc is enabled..');
--   END IF;
--   IF (gl_ca_utility_pkg.mrc_enabled(
--                    p_sob_id => ar_mc_info.primary_sob_id,
--                    p_org_id => ar_mc_info.org_id,
--                    p_appl_id => 222
--                          ))  THEN
--        IF PG_DEBUG in ('Y', 'C') THEN
--           arp_standard.debug('confirm_ra_rec_create: ' || 'MRC is enabled...     ');
--        END IF;
--           BEGIN
--                ar_mc_rec_apps_pkg.confirm_ra_rec_create(
--                      p_rec_record  => p_rec_record );
--           EXCEPTION
--            WHEN OTHERS THEN
--              IF PG_DEBUG in ('Y', 'C') THEN
--                 arp_standard.debug('error during MRC confirm_ra_rec_create ');
--              END IF;
--              APP_EXCEPTION.RAISE_EXCEPTION;
--           END;

--    END IF;  /* end of mrc is enabled */
--  IF PG_DEBUG in ('Y', 'C') THEN
--     arp_standard.debug( 'AR_MRC_ENGINE3.confirm_ra_rec_create(-)');
--  END IF;

 END confirm_ra_rec_create;

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
 |  09/20/02    Debbie Sue Jancis       Created
 *============================================================================*/
PROCEDURE update_ra_rec_cash_diff(
       p_rec_app_id          IN NUMBER,
       p_cash_receipt_id     IN ar_cash_receipts.cash_receipt_id%TYPE,
       p_diff_amount         IN ar_cash_receipts.amount%TYPE,
       p_old_rcpt_amount     IN ar_cash_receipts.amount%TYPE,
       p_payment_schedule_id IN ar_payment_schedules.payment_schedule_id%TYPE
                                 ) IS
BEGIN
NULL;
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug( 'AR_MRC_ENGINE3.update_ra_rec_cash_diff(+)');
--      arp_standard.debug('update_ra_rec_cash_diff: ' ||  'rec app id = ' || to_char(p_rec_app_id));
--      arp_standard.debug('update_ra_rec_cash_diff: ' ||  'cash receipt id = ' || to_char(p_cash_receipt_id));
--      arp_standard.debug('update_ra_rec_cash_diff: ' ||  'diff amount = ' || to_char(p_diff_amount));
--      arp_standard.debug('update_ra_rec_cash_diff: ' ||  'old rcpt amount = ' || to_char(p_old_rcpt_amount));
--      arp_standard.debug('update_ra_rec_cash_diff: ' ||  'ps id = ' || to_char(p_payment_schedule_id));
--   END IF;

   /*-----------------------------------------------------------------+
    |  First we need to check if MRC is enabled.  If it is than we    |
    |  continue processing.  If it is not then we are finished.       |
    +-----------------------------------------------------------------*/
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('update_ra_rec_cash_diff: ' || 'before checking to see if mrc is enabled..');
--   END IF;
--   IF (gl_ca_utility_pkg.mrc_enabled(
--                    p_sob_id => ar_mc_info.primary_sob_id,
--                    p_org_id => ar_mc_info.org_id,
--                    p_appl_id => 222
--                          ))  THEN
--        IF PG_DEBUG in ('Y', 'C') THEN
--           arp_standard.debug('update_ra_rec_cash_diff: ' || 'MRC is enabled...     ');
--        END IF;
--           BEGIN
--                ar_mc_rec_apps_pkg.update_ra_rec_cash_diff(
--                       p_rec_app_id          => p_rec_app_id,
--                       p_cash_receipt_id     => p_cash_receipt_id,
--                       p_diff_amount         => p_diff_amount,
--                       p_old_rcpt_amount     => p_old_rcpt_amount,
--                       p_payment_schedule_id => p_payment_schedule_id);

--           EXCEPTION
--            WHEN OTHERS THEN
--              IF PG_DEBUG in ('Y', 'C') THEN
--                 arp_standard.debug('error during MRC update_ra_rec_cash_diff ');
--              END IF;
--              APP_EXCEPTION.RAISE_EXCEPTION;
--           END;

--    END IF;  /* end of mrc is enabled */

--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug( 'AR_MRC_ENGINE3.update_ra_rec_cash_diff(-)');
--   END IF;

END update_ra_rec_cash_diff;

END AR_MRC_ENGINE3;

/
