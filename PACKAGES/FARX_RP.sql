--------------------------------------------------------
--  DDL for Package FARX_RP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FARX_RP" AUTHID CURRENT_USER AS
/* $Header: FARXRPS.pls 120.2.12010000.2 2009/07/19 11:43:46 glchen ship $ */

/*=====================================================================================+
|
|   Name:          Preview_Reclass
|
|   Description:   Procedure for mass reclass preview.
|		   This procedure is called from the concurrent wrapper procedure
|		   FARX_C_RP.Mass_Reclass_Preview().
|		   This procedure calls Reclass Validation Engine to verify that
|		   the asset can be reclassified, and if so inserts the results
|		   into the interface table, FA_MASS_RECLASS_ITF.
|		   User asset selection and reclass criteria are fetched from
|		   FA_MASS_RECLASS table.
|
|   Parameters:    X_Mass_Reclass_Id -- Mass Reclass ID from FA_MASS_RECLASS table.
|		   X_RX_Flag -- Indicates whether this procedure is called from
|			RX report or not.
|		   retcode -- OUT parameter.  Denotes completion status.
|			0 -- Completed normally.
|			1 -- Completed with warning.
|			2 -- Completed with error.
|		   errbuf -- OUT parameter.  Error or warning description.
|
|   Returns:
|
|   Notes:
|
+=====================================================================================*/

PROCEDURE Preview_Reclass(
	X_Mass_Reclass_Id	IN	NUMBER,
	X_RX_Flag		IN	VARCHAR2 := 'NO',
	retcode		 OUT NOCOPY NUMBER,
	errbuf		 OUT NOCOPY VARCHAR2);


/*=====================================================================================+
|
|   Name:          Store_Results
|
|   Description:   Procedure to store the preview results of an asset into a
|		   private pl/sql asset table(of type
|		   FA_MASS_REC_UTILS_PKG.asset_table) for all the books
|		   the asset belongs to.  Proper conversions for output
|		   are taken care of in this procedure.
|
|   Parameters:    X_Get_New_Rules
|			1. If this flag is set to YES, new depreciation
|			   rules are retrieved from FA_LOAD_TBL_PKG.deprn_table
|			   and stored into the asset table, if the user chooses to
|			   redefault and if redefault is allowed in the book.
|			   Otherwise, the old(current) asset rules are retrieved
|			   and stored into the asset table.
|			   * Now we allow, redefault per book instead of per asset.
|			     Validation for redefault is performed in this
|			     procedure.
|			2. If this flag is set to NO(default), old(current) asset
|			   rules are retrieved and stored into the asset table.
|		   X_Cat_Flex_Struct -- Category flexfield structure.
|			If NULL, the procedure figures out nocopy the structure.
|
|   Returns:
|
|   Notes:         The asset's old(current) category information is stored in
|		   the asset table record.  New category information will
|		   be fetched from mass reclass record upon insertion into
|		   fa_mass_reclass_itf interface table.
|
+=====================================================================================*/

PROCEDURE Store_Results(
	X_Get_New_Rules		IN	VARCHAR2 := 'NO',
	X_Cat_Flex_Struct	IN	NUMBER := NULL
	);


/*=====================================================================================+
|
|   Name:          Check_Trans_Date_Book
|
|   Description:   Function to check if transaction_date_entered is valid in a given
|		   book.
|
|   Parameters:    X_Asset_Id -- Asset id.
|		   X_Book_Type_Code -- book the asset belongs to.
|		   X_Trx_Type -- Transaction type -- ADJUSTMENT or other values.
|
|   Returns:       TRUE -- if validation succeeds.
|                  FALSE -- if validation fails.
|
|   Notes:         Transaction_date_entered is validated in reclass/redefault
|		   transaction engines instead of validation engines, since all
|		   the required values for validation are available at transaction
|		   step.
|		   This validation is sufficed by FA_MASS_RECLASS_PKG.Check_Trans_Date
|		   for reclass part.  For adjustment part, the following function
|		   can be used.  This is separated out nocopy from redefault valiation engine,
|		   since there is no need to create performance overhead in mass
|		   reclass transaction, by duplicating the validation effort.
|
+======================================================================================*/

FUNCTION Check_Trans_Date_Book(
        X_Asset_Id              IN      NUMBER,
        X_Book_Type_Code        IN      VARCHAR2,
        X_Trx_Type              IN      VARCHAR2
        ) RETURN BOOLEAN;


END FARX_RP;

/
