--------------------------------------------------------
--  DDL for Package FA_TRX_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_TRX_APPROVAL_PKG" AUTHID CURRENT_USER AS
/* $Header: FATRXAPS.pls 120.2.12010000.2 2009/07/19 11:48:37 glchen ship $ */

/*=====================================================================================+
|
|   Name:          faxcat()
|
|   Description:   This function checks whether depreciation or any Mass process is
|                  running on the book. Then it calls faxcti() to ensure that this
|                  transaction does not conflict with any other transactionon on the
|                  asset.
|
|   Parameters:    X_book - Book type code for the transaction
|                  X_asset_id - Asset_Id for the transaction
|                  X_trx_type - Requested transaction type
|                  X_trx_date - Requested transaction date
|                 -- X_result   - OUT parameter to check transaction integrity
|
|   Returns:       TRUE (boolean) if no errors
|
|   Notes:         Called from the user-exit faxcatx() --  #OFA TRX_APPROVAL
|
+====================================================================================*/

    FUNCTION faxcat    (X_book 		    VARCHAR2,
			X_asset_id 	    NUMBER,
			X_trx_type 	    VARCHAR2,
	 	     	X_trx_date 	    DATE,
			X_init_message_flag VARCHAR2 DEFAULT 'NO'
			, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)   RETURN BOOLEAN;



/*=====================================================================================+
|
|   Name:          faxcti()
|
|   Description:   This function checks transaction integrity. It checks whether there
|                  any transactions entered for this asset on a date after this
|                  transaction date. Also checks whether there are retirements
|                  pending for the asset.
|
|   Parameters:    X_book     - Book type code for the transaction
|                  X_asset_id - Asset_Id for the transaction
|                  X_trx_type - Requested transaction type
|                  X_trx_date - Requested transaction date
|                  X_result   - OUT NOCOPY parameter to check transaction integrity
|
|   Modifies:      X_result = TRUE (boolean) if transaction is allowed
|
|   Returns:       TRUE(boolean) if no errors
|
|   Notes:         Called by the function faxcat()
|
+====================================================================================*/


    FUNCTION faxcti    (X_book VARCHAR2,
			X_asset_id NUMBER,
			X_trx_type VARCHAR2,
		     	X_trx_date DATE,
			X_result IN OUT NOCOPY BOOLEAN, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)   RETURN BOOLEAN;

END FA_TRX_APPROVAL_PKG;

/
