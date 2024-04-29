--------------------------------------------------------
--  DDL for Package FUN_AP_TRANSFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_AP_TRANSFER" AUTHID CURRENT_USER AS
/* $Header: FUN_AP_XFER_S.pls 120.7 2006/07/04 15:49:44 bsilveir noship $ */

FUNCTION has_valid_conversion_rate (
    p_from_currency IN varchar2,
    p_to_currency   IN varchar2,
    p_exchange_type IN varchar2,
    p_exchange_date IN date) RETURN NUMBER;

/*-----------------------------------------------------
 * FUNCTION lock_and_transfer
 * ----------------------------------------------------
 * Acquires lock and transfer one trx.
 *
 * Returns TRUE iff it can obtain lock, see a valid
 * status, and transfer the trx.
 * ---------------------------------------------------*/

FUNCTION lock_and_transfer (
    p_trx_id        IN number,
    p_batch_date    IN date,
    p_vendor_id     IN number,
    p_site_id       IN number,
    p_gl_date       IN date,
    p_currency      IN varchar2,
    p_exchg_rate    IN varchar2,
    p_source        IN varchar2,
    p_approval_date IN date,
    p_to_org_id     IN number,
    p_invoice_num   IN varchar2,
    p_from_org_id   IN NUMBER) RETURN boolean;


/*-----------------------------------------------------
 * FUNCTION lock_transaction
 * ----------------------------------------------------
 * Lock the transaction, test if it's valid still.
 * ---------------------------------------------------*/

FUNCTION lock_transaction (
    p_trx_id        IN number) RETURN boolean;


/*-----------------------------------------------------
 * PROCEDURE update_status
 * ----------------------------------------------------
 * Returns the new status.
 * ---------------------------------------------------*/

PROCEDURE update_status (
    p_trx_id    IN number);


/*-----------------------------------------------------
 * PROCEDURE transfer_batch
 * ----------------------------------------------------
 * Transfer to AP interface in batch.
 * ---------------------------------------------------*/

PROCEDURE transfer_batch (
    errbuf          OUT NOCOPY varchar2,
    retcode         OUT NOCOPY number,
    p_org_id        IN number DEFAULT NULL,
    p_le_id         IN number DEFAULT NULL ,
    p_period_low    IN varchar2  DEFAULT NULL,
    p_period_high   IN varchar2  DEFAULT NULL,
    p_run_payables_import IN varchar2 DEFAULT 'N' );


/*-----------------------------------------------------
 * PROCEDURE transfer_single
 * ----------------------------------------------------
 * Transfer a single transaction to AP interface.
 * It assumes that the caller has a lock on the
 * transaction, and the caller will do the commit.
 * ---------------------------------------------------*/

PROCEDURE transfer_single (
    p_trx_id            IN number,
    p_batch_date        IN date,
    p_vendor_id         IN number,
    p_vendor_site_id    IN number,
    p_currency          IN varchar2,
    p_conv_type         IN varchar2,
    p_source            IN varchar2,
    p_gl_date           IN date,
    p_approval_date     IN date,
    p_org_id            IN number,
    p_invoice_num       IN varchar2,
    p_from_org_id       IN number,
    p_payables_ccid     OUT NOCOPY number);



END;


 

/
