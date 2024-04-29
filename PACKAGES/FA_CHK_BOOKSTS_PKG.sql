--------------------------------------------------------
--  DDL for Package FA_CHK_BOOKSTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CHK_BOOKSTS_PKG" AUTHID CURRENT_USER as
/* $Header: FAXCKBKS.pls 120.3.12010000.2 2009/07/19 14:21:46 glchen ship $ */

--
-- savepoint indicator, sets TRUE if savepoint has been created
--
  savepoint_set  BOOLEAN := FALSE;


/* ---------------------------------------------------------------------
 |   Name
 |        faxcbsx
 |
 |   Description
 |
 |        Check book status user exit entry function.
 |        Calls faxcbs to check the status of the book and returns TRUE
 |        if depreciation submission is allowed.
 |
 |
 |   Parameters
 |        X_book  - book_type_code for which status is checked
 |
 |   Returns
 |        TRUE if successful, FALSE otherwise
 |
 |   Notes
 |
 |   History
 |        03-Feb-1997           LSON              Created
 |
 + -------------------------------------------------------------------- */

FUNCTION faxcbsx(X_book        IN    VARCHAR2,
		 X_init_message_flag VARCHAR2 DEFAULT 'NO',
                 X_close_period IN   NUMBER DEFAULT 1, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
        return BOOLEAN;

/* ---------------------------------------------------------------------
 |   Name
 |        faxcrb
 |
 |   Description
 |        This function Checks the Reporting Books for a Primary Book.
 |        This function has been created to check the depreciation status
 |        and the current on all the associated reporting books of a MRC
 |        enabled Book. If depreciation has errored on a reporting book
 |        or has not yet been run on all the reporting books, we will
 |        false and prevent the transaction.
 |
 |   Parameters
 |        X_book  - book_type_code
 |        X_txn_type  - type of transaction performed on Primary Book
 |
 |   Returns
 |        TRUE if successful, FALSE otherwise
 |
 |   Notes
 |
 |   History
 |        02-Dec-1997      SNARAYAN       Created
 |        11-Aug-2001      BRIDGWAY       Added asset_id and close_period
 |
 + -------------------------------------------------------------------- */

FUNCTION faxcrb(X_book         IN  VARCHAR2,
                X_trx_type     IN VARCHAR2,
                X_asset_id     IN NUMBER,
                X_close_period IN NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
             return BOOLEAN;

/* ---------------------------------------------------------------------
 |   Name
 |        faxcbs
 |
 |   Description
 |
 |      Check the status of any processes on the book or its
 |        associated CORP book or TAX books
 |      Calls faxcps to check to see if any processes running on
 |        the book is pending,inactive,or running. If so, txn is
 |        not allowed.
 |      Calls faxptb if Corp book and txn type is TRANSFER or RECLASS
 |        and checks all associated TAX book status.
 |      Calls faxgcb if TAX book and checks its associated CORP book
 |        to see if any processes running on the corp books is MASS
 |        transfer or Mass additions post. If so, txn not allowed
 |
 |
 |   Parameters
 |        X_book  - book_type_code for which status is checked
 |        X_submit - TRUE, if request is for depreciation
 |        X_start - TRUE if mass trx should be resubmitted.
 |        X_asset_id - 0 for mass trx, other for individual txns
 |        X_trx_type - transaction type code of transaction
 |        X_result - TRUE if txn allowed, FALSE otherwise
 |
 |   Returns
 |        TRUE if successful, FALSE otherwise
 |
 |   Notes
 |
 |   History
 |        03-Feb-1997      LSON           Created
 |        11-Aug-2001      BRIDGWAY       Added close_period
 |
 + -------------------------------------------------------------------- */

FUNCTION faxcbs(X_book         IN    VARCHAR2,
                X_submit       IN    BOOLEAN,
                X_start        IN    BOOLEAN,
                X_asset_id     IN    NUMBER,
                X_trx_type     IN    VARCHAR2,
                X_txn_status   IN OUT NOCOPY   BOOLEAN,
                X_close_period IN    NUMBER DEFAULT 1, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
        return BOOLEAN;

/* ---------------------------------------------------------------------
 |   Name
 |        faxcps
 |
 |   Description
 |
 |        Check processes status.
 |        Calls faxcms to check the status of any process
 |        running on the book.
 |
 |   Parameters
 |        X_book  - book for transaction status is checked
 |        X_submit  - TRUE, if request for depreciation
 |                    FALSE, otherwise
 |        X_start - TRUE, if trx should be resubmitted
 |        X_asset_id - 0 for mass_trx, other for individual transactions
 |        X_txn_status - TRUE, if txns is allowed.
 |
 |   Returns
 |        TRUE if successful, FALSE otherwise
 |
 |   Notes
 |
 |   History
 |        03-Feb-1997      LSON           Created
 |        11-Aug-2001      BRIDGWAY       Added close_period
 |
 + -------------------------------------------------------------------- */


FUNCTION faxcps(X_book         IN    VARCHAR2,
                X_submit       IN    BOOLEAN,
                X_start        IN    BOOLEAN,
                X_asset_id     IN    NUMBER,
                X_trx_type     IN    VARCHAR2,
                X_txn_status   IN OUT NOCOPY   BOOLEAN,
                X_close_period IN    NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
             return BOOLEAN;


/* ---------------------------------------------------------------------
 |   Name
 |        faxcds
 |
 |   Description
 |        Checks Depreciation status.
 |        Gets DEPRN_STATUS and DEPRN_REQUEST_ID from FA_BOOK_CONTROLS.
 |        If deprn is running,inactive,or pending, trx is not approved.
 |        If requested process is depreciation, it is allowed even though
 |        last deprn errored out. A mass process is only allowed for deprn status
 |        complete.
 |
 |   Parameters
 |        X_book  - book for which txn status is checked
 |        X_submit - true if submitting depreciation
 |        X_asset_id -  asset for which txn approval is required
 |        X_trx_type - transaction type being done for the asset
 |        X_txn_status - TRUE if trx approved, FALSE otherwise
 |
 |   Returns
 |        TRUE if successful, FALSE otherwise
 |
 |   Notes
 |
 |   History
 |        05-NOV-1997           LSON              Created
 |
 + -------------------------------------------------------------------- */

FUNCTION faxcds(X_book        IN  VARCHAR2,
                X_submit      IN  BOOLEAN,
                X_asset_id    IN  NUMBER,
                X_trx_type    IN  VARCHAR2,
                X_txn_status  IN OUT NOCOPY BOOLEAN, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return BOOLEAN;



/* ---------------------------------------------------------------------
 |   Name
 |        faxcms
 |
 |   Description
 |        Checks the existance and status of any mass transactions running
 |        against a book. If there are no uncompleted transactions, it will
 |        return TRUE - meaning txns are allowed on this book. Otherwise
 |        it displays message and passes the request_id back to the calling function.
 |
 |   Parameters
 |        X_book  - book for which txn status is checked
 |        X_request_id  - request_id to be returned to when that request
 |                        is non-complete
 |
 |   Returns
 |        TRUE if successful, FALSE otherwise
 |
 |   Notes
 |
 |   History
 |        03-Feb-1997           LSON              Created
 |
 + -------------------------------------------------------------------- */

FUNCTION faxcms(X_book         IN    VARCHAR2,
                X_request_id   OUT NOCOPY   NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
             return BOOLEAN;

/* ---------------------------------------------------------------------
 |   Name
 |        faxcca
 |
 |   Description
 |        Checks the existance and status of any Create Accounting
 |        process running against a book. If there are no such requests,
 |        it will return TRUE - meaning txns are allowed on this book. Otherwise
 |        it displays message and passes the request_id back to the calling function.
 |
 |   Parameters
 |        X_book  - book for which txn status is checked
 |        X_request_id  - request_id to be returned to when that request
 |                        is non-complete
 |
 |   Returns
 |        TRUE if successful, FALSE otherwise
 |
 |   Notes
 |
 |   History
 |        14-Aug-2006           BRIDGWAY          Created
 |
 + -------------------------------------------------------------------- */


FUNCTION faxcca(X_book         IN    VARCHAR2,
                X_request_id   OUT NOCOPY   NUMBER,
		p_log_level_rec IN  FA_API_TYPES.log_level_rec_type default
null)
         return BOOLEAN;


/* ---------------------------------------------------------------------
 |   Name
 |        faxwcr
 |
 |   Description
 |        This function waits for concurrent request, caculates a concurrent
 |        request re-start time and issues request to run it at that time.
 |
 |   Parameters
 |        X_request_id  - request-id of the failed submission
 |
 |   Returns
 |        TRUE if successful, FALSE otherwise
 |
 |   Notes
 |        Funtion currently disabled, will return TRUE always
 |
 |   History
 |        03-Feb-1997           LSON              Created
 |
 + -------------------------------------------------------------------- */

FUNCTION faxwcr(X_request_id    IN  NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
             return BOOLEAN;


/* ---------------------------------------------------------------------
 |   Name
 |        faxptb
 |
 |   Description
 |
 |      Checks the status of any processes on the TAX books.
 |        For each Tax book of the associated CORP book
 |        it calls faxcps to check its status.
 |        If any one of them has process of running,pending,inactive
 |        all the lock will be rolled back and txn is disallowed.
 |
 |   Parameters
 |        X_book  - book_type_code for which status is checked
 |        X_start - TRUE if mass trx should be resubmitted.
 |        X_asset_id - 0 for mass trx, other for individual txns
 |        X_trx_type - transaction type code of transaction
 |        X_txn_status - TRUE if txn allowed, FALSE otherwise
 |
 |   Returns
 |        TRUE if successful, FALSE otherwise
 |
 |   Notes
 |
 |   History
 |        03-Feb-1997           LSON              Created
 |
 + -------------------------------------------------------------------- */


FUNCTION faxptb(X_book       IN     VARCHAR2,
                X_start      IN     BOOLEAN,
                X_asset_id   IN     NUMBER,
                X_trx_type   IN     VARCHAR2,
                X_txn_status     IN OUT NOCOPY    BOOLEAN, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
        return BOOLEAN;



/* ---------------------------------------------------------------------
 |   Name
 |        faxgcb
 |
 |   Description
 |
 |        Get associated corporate book for tax book passed in.
 |        Calls faxcms to check to see if any mass processes running
 |        on the corp book is mass transfer or mass additions post.
 |        If so, disallow txns.
 |
 |   Parameters
 |        X_book  - book_type_code for TAX book
 |        X_txn_status - TRUE, if txns is allowed.
 |
 |   Returns
 |        TRUE if successful, FALSE otherwise
 |
 |   Notes
 |
 |   History
 |        03-Feb-1997           LSON              Created
 |
 + -------------------------------------------------------------------- */

FUNCTION faxgcb(X_book         IN    VARCHAR2,
                X_txn_status       IN OUT NOCOPY   BOOLEAN, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)

             return BOOLEAN;



/* ---------------------------------------------------------------------
 |   Name
 |        faxlck
 |
 |   Description
 |        This function locks fa_book_control row for a book passed in
 |
 |   Parameters
 |        X_book  - book_type_code to lock
 |                  If null, it will rollback to savepoint
 |        X_txn_status  - TRUE if lock obtained
 |
 |   Returns
 |        TRUE if successful, FALSE otherwise
 |
 |   Notes
 |
 |   History
 |        03-Feb-1997           LSON              Created
 |
 + -------------------------------------------------------------------- */

FUNCTION faxlck(X_book        IN  VARCHAR2,
                X_txn_status  IN OUT NOCOPY BOOLEAN,
                X_asset_id    IN NUMBER,
                X_trx_type    IN VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
             return BOOLEAN;


/* ---------------------------------------------------------------------
 |   Name
 |        faxsav
 |
 |   Description
 |        This function create or rollback to a savepoint
 |
 |   Parameters
 |        X_action  - R for rollback to a savepoint
 |                    S for set savepoint
 |                    C for clear savepoint indicator
 |
 |        X_txn_status  - TRUE if savepoint obtained
 |
 |   Returns
 |        TRUE if successful, FALSE otherwise
 |
 |   Notes
 |        savepoint_set is global variable indicating whether or not savepoint is set
 |
 |   History
 |        03-Feb-1997           LSON              Created
 |
 + -------------------------------------------------------------------- */

FUNCTION faxsav(X_action     IN  VARCHAR2,
                X_txn_status     IN OUT NOCOPY BOOLEAN, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
     return BOOLEAN;

/* ---------------------------------------------------------------------
 |   Name
 |        faxcdr
 |
 |   Description
 |        This function checks if depreciation has been run for the
 |        current open period for the book passed as parameter
 |
 |   Parameters
 |        X_book     - book_type_code to check if depreciation has run
 |        X_asset_id - asset_id (0 for mass requests)
 |   Returns
 |        TRUE if depreciation not run, FALSE otherwise
 |
 |   Notes
 |
 |   History
 |        05-Nov-1998           SNARAYAN     Created
 |        07-Aug-2001           BRIDGWAY     added asset_id param and
 |
 + -------------------------------------------------------------------- */

FUNCTION faxcdr(
                X_book          IN      VARCHAR2,
                X_asset_id      IN      NUMBER DEFAULT 0, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
     return BOOLEAN;


END FA_CHK_BOOKSTS_PKG;

/
