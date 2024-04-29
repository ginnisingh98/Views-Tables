--------------------------------------------------------
--  DDL for Package FUN_GL_TRANSFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_GL_TRANSFER" AUTHID CURRENT_USER AS
/* $Header: FUN_GL_XFER_S.pls 120.3.12010000.4 2009/03/23 10:47:53 makansal ship $ */

    -- Raised when the transaction is in the wrong status.
    corrupted_transaction_status EXCEPTION;

    -- Raise when the party_type is unknown in batch transfer.
    trx_no_party_type_error EXCEPTION;

FUNCTION get_conversion_type(
    p_conversion_type IN varchar2) RETURN varchar2;


/*-----------------------------------------------------
 * FUNCTION lock_and_transfer
 * ----------------------------------------------------
 * Acquires lock and transfer.
 * ---------------------------------------------------*/

FUNCTION lock_and_transfer (
    p_trx_id        IN number,
    p_ledger_id     IN number,
    p_gl_date       IN date,
    p_currency      IN varchar2,
    p_category      IN varchar2,
    p_source        IN varchar2,
    p_desc          IN varchar2,
    p_conv_date     IN date,
    p_conv_type     IN varchar2,
    p_party_type    IN varchar2,
    p_user_env_lang IN varchar2) RETURN boolean;


/*-----------------------------------------------------
 * FUNCTION lock_transaction
 * ----------------------------------------------------
 * Lock the transaction.
 * If p_status is not null, test if it's valid still.
 * ---------------------------------------------------*/

FUNCTION lock_transaction (
    p_trx_id        IN number,
    p_party_type    IN varchar2) RETURN boolean;


/*-----------------------------------------------------
 * FUNCTION has_conversion_rate
 * ----------------------------------------------------
 * Is there a conversion rate between the two
 * currencies?
 * ---------------------------------------------------*/

FUNCTION has_conversion_rate (
    p_from_currency IN varchar2,
    p_to_currency   IN varchar2,
    p_exchange_type IN varchar2,
    p_exchange_date IN date) RETURN number;


/*-----------------------------------------------------
 * FUNCTION get_period_status
 * ----------------------------------------------------
 * Returns the period closing status.
 * ---------------------------------------------------*/

FUNCTION get_period_status (
    p_app_id        IN number,
    p_date          IN date,
    p_ledger_id     IN number) RETURN varchar2;


/*-----------------------------------------------------
 * FUNCTION update_status
 * ----------------------------------------------------
 * Returns the new status.
 * ---------------------------------------------------*/

FUNCTION update_status (
    p_trx_id        IN number,
    p_status        IN varchar2,
    p_party_type    IN varchar2) RETURN varchar2;



/*-----------------------------------------------------
 * PROCEDURE transfer_single
 * ----------------------------------------------------
 * Transfer a single transaction to GL interface.
 * It assumes that the caller has a lock on the
 * transaction, and will do the commit.
 * ---------------------------------------------------*/

PROCEDURE transfer_single (
    p_batch_number  IN varchar2,
    p_trx_id        IN number,
    p_ledger_id     IN number,
    p_gl_date       IN date,
    p_currency      IN varchar2,
    p_category      IN varchar2,
    p_source        IN varchar2,
    p_desc          IN varchar2,
    p_conv_date     IN date,
    p_conv_type     IN varchar2,
    p_party_type    IN varchar2,
    p_user_env_lang IN varchar2);



/*-----------------------------------------------------
 * PROCEDURE transfer_batch
 * ----------------------------------------------------
 *  Not used anymore
 * ---------------------------------------------------*/

PROCEDURE transfer_batch (
    p_request_id    IN number,
    p_source        IN varchar2,
    p_category      IN varchar2,
    p_date_low      IN date DEFAULT NULL,
    p_date_high     IN date DEFAULT NULL,
    p_ledger_low    IN varchar2 DEFAULT NULL,
    p_ledger_high   IN varchar2 DEFAULT NULL,
    p_le_low        IN varchar2 DEFAULT NULL,
    p_le_high       IN varchar2 DEFAULT NULL,
    p_ic_org_low    IN varchar2 DEFAULT NULL,
    p_ic_org_high   IN varchar2 DEFAULT NULL,
    p_commit_freq   IN number DEFAULT 100);

END;


/
