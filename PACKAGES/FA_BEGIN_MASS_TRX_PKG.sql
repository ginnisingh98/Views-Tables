--------------------------------------------------------
--  DDL for Package FA_BEGIN_MASS_TRX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_BEGIN_MASS_TRX_PKG" AUTHID CURRENT_USER AS
/* $Header: FAXBMTS.pls 120.2.12010000.2 2009/07/19 14:20:44 glchen ship $ */

/*====================================================================================+
|   Name:	faxbmt()
|
|   Description:
|	Called by all mass transaction programs. It checks that the transaction is
|	allowed. If it is then it updates FA_BOOK_CONTROLS to prevent any further
|	transactions. If the transaction is not allowed, the request is re-submitted
|	and the function returns FALSE.
|      	Looks at the executable name to determine transaction type.
|      	Current "special" executables:
|              FAMAPT - Can cause RECLASSes.
|              FAMTFR - Causes TRANSFERs
|	       FAMRCL - Causes RECLASSes.
|
|   Parameters:
|      	X_book    - book_type_code for the transaction
|       X_request_id - ID or Mass Request asking for approval
|	X_result - OUT NOCOPY parameter.  Indicates whether transaction is allowed.
|
|   Returns:
|	TRUE if no errors
|
|   Notes:
|
+====================================================================================*/

FUNCTION faxbmt	(X_book		IN 	VARCHAR2,
		 X_request_id	IN	NUMBER,
		 X_result	IN OUT NOCOPY BOOLEAN
		 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)	RETURN BOOLEAN;


/*====================================================================================+
|   Name:	faxemt()
|
|   Description:
|	End Mass Transaction.
|	Called by all mass transaction programs to reset the MASS_REQUEST_ID to NULL
|	at the end of the mass process, but before the final commit and exit.
|
|   Parameters:
|      	X_book    - book_type_code for the transaction
|       X_request_id - REQUEST_ID of the failed submission
|
|   Returns:
|	TRUE if no errors
|
|   Notes:
|
+====================================================================================*/

FUNCTION faxemt	(X_book		IN 	VARCHAR2,
		 X_request_id	IN	NUMBER
		 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)	RETURN BOOLEAN;


END FA_BEGIN_MASS_TRX_PKG;

/
