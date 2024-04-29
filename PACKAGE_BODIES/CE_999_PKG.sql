--------------------------------------------------------
--  DDL for Package Body CE_999_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_999_PKG" AS
/* $Header: ceab999b.pls 115.11 2002/01/25 16:51:43 pkm ship   $	*/
/* ---------------------------------------------------------------------
|  PUBLIC FUNCTION                                                      |
|       lock_row                                                        |
|                                                                       |
|  DESCRIPTION                                                          |
|       This procedure would be called when open-interface transactions |
|	need to be locked					        |
|                                                                       |
|                                                                       |
|  HISTORY                                                              |
 --------------------------------------------------------------------- */
PROCEDURE lock_row( 	X_call_mode		VARCHAR2,
			X_trx_type		VARCHAR2,
			X_trx_rowid		VARCHAR2 ) IS

/* Example lock_open cursor

  trx_id ROWID;

  CURSOR lock_open IS
  select rowid
  from ce_999_interface_v
  where rowid = X_trx_rowid
  for update of trx_id nowait;

*/

/* Note: ce_999_interface_v is the base table of ce_999_interface_v in this example. */

BEGIN

null;

/* Example of lock_row procedure with cursor and exception handling

  OPEN lock_open;
  FETCH lock_open INTO trx_id;
  IF (lock_open%NOTFOUND) THEN
    CLOSE lock_open;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE lock_open;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF lock_open%ISOPEN THEN
      CLOSE lock_open;
    END IF;
    RAISE NO_DATA_FOUND;
  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
    IF lock_open%ISOPEN THEN
      CLOSE lock_open;
    END IF;
    RAISE APP_EXCEPTION.RECORD_LOCK_EXCEPTION;
*/

END lock_row;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       clear		                                                |
|                                                                       |
|  DESCRIPTION                                                          |
|       This procedure would be called during clearing phase	        |
|                                                                       |
|                                                                       |
|  HISTORY                                                              |
 --------------------------------------------------------------------- */
PROCEDURE clear(
    	X_trx_id                NUMBER,   -- transaction id
    	X_trx_type              VARCHAR2, -- transaction type ('PAYMENT'/'CASH')
	X_status		VARCHAR2, -- status
	X_trx_number		VARCHAR2, -- transaction number
    	X_trx_date              DATE,     -- transaction date
	X_trx_currency		VARCHAR2, -- transaction currency code
    	X_gl_date               DATE,     -- gl date
 	X_bank_currency		VARCHAR2, -- bank currency code
    	X_cleared_amount        NUMBER,   -- amount to be cleared
        X_cleared_date          DATE,	  -- cleared date
    	X_charges_amount        NUMBER,   -- charges amount
    	X_errors_amount         NUMBER,   -- errors amount
    	X_exchange_date         DATE,     -- exchange rate date
    	X_exchange_type  	VARCHAR2, -- exchange rate type
    	X_exchange_rate         NUMBER    -- exchange rate
  )IS

BEGIN

/* Note: ce_999_interface_v is the base table of ce_999_interface_v in this
	 example */

/* Note: You are required to pass the status column to your proprietary
	 database. The Reconciliation Open Interface feature requires a
	 non-null status column to function correctly. */

/* Note: If you have not defined the value for the open interface clear status
	 in the System Parameter Form, i.e. OPEN_INTERFACE_CLEAR_STATUS column
	 in the CE_SYSTEM_PARAMETERS_ALL table, you are required to do so. */

/* Example of clear procedure

  update ce_999_interface_v
  set status  			= X_status,
      gl_date 			= X_gl_date,
      cleared_amount		= X_cleared_amount,
      cleared_date		= X_cleared_date,
      charges_amount		= X_charges_amount,
      error_amount		= X_errors_amount,
      exchange_rate_date	= X_exchange_date,
      exchange_rate_type	= X_exchange_type,
      exchange_rate		= X_exchange_rate
  where trx_id = X_trx_id;

*/
null;

/* Reconciliation Accounting Logic goes here */

END clear;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       unclear	 	                                                |
|                                                                       |
|  DESCRIPTION                                                          |
|       This procedure would be called during unclearing phase	        |
|                                                                       |
|  HISTORY                                                              |
 --------------------------------------------------------------------- */
PROCEDURE unclear(
    	X_trx_id                NUMBER,   -- transaction id
    	X_trx_type              VARCHAR2, -- transaction type ('PAYMENT'/'CASH')
	X_status		VARCHAR2, -- status
    	X_trx_date              DATE,     -- transaction date
    	X_gl_date               DATE      -- gl date
  )IS

BEGIN

/* Note: ce_999_interface_v is the base table of ce_999_interface_v in this
	 example */

/* Note: You are required to pass the status column to your proprietary
	 database. The Reconciliation Open Interface feature requires a
	 non-null status column to function correctly. */

/* Note: If you have not defined the value for the open interface float status
	 in the System Parameter Form, i.e. OPEN_INTERFACE_FLOAT_STATUS column
	 in the CE_SYSTEM_PARAMETERS_ALL table, you are required to do so. */

/* Example of unclear procedure

  update ce_999_interface_v
  set status 		 	= X_status,
      gl_date 			= NULL,
      cleared_amount		= NULL,
      cleared_date		= NULL,
      charges_amount		= NULL,
      error_amount		= NULL,
      exchange_rate_date	= NULL,
      exchange_rate_type	= NULL,
      exchange_rate		= NULL
  where trx_id = X_trx_id;
*/

/* Reconciliation Accounting Logic goes here */
null;

END unclear;

END CE_999_PKG;

/
