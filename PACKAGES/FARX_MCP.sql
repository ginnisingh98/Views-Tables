--------------------------------------------------------
--  DDL for Package FARX_MCP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FARX_MCP" AUTHID CURRENT_USER AS
/* $Header: FARXMCPS.pls 120.0.12010000.2 2009/07/19 11:57:48 glchen ship $ */



/*=====================================================================================+
|
|   Name:          Preview_Change
|
|   Description:   Procedure for mass change preview.
|                  This procedure is called from the concurrent wrapper procedure
|                  FARX_C_CP.Mass_Change_Preview().
|                  This procedure inserts the results into the interface table:
|                     FA_MASS_CHANGE_ITF.
|                  User asset selection and change criteria are fetched from
|                  FA_MASS_CHANGES table.
|
|   Parameters:    X_Mass_Change_Id -- Mass Change ID from FA_MASS_CHANGES table.
|                  X_RX_Flag -- Indicates whether this procedure is called from
|                               RX report or not.
|                  retcode -- OUT parameter.  Denotes completion status.
|                        0 -- Completed normally.
|                        1 -- Completed with warning.
|                        2 -- Completed with error.
|                  errbuf -- OUT parameter.  Error or warning description.
|
|   Returns:
|
|   Notes:
|
+=====================================================================================*/

PROCEDURE Preview_Change(
     X_Mass_Change_Id     IN     NUMBER,
     X_RX_Flag            IN     VARCHAR2 := 'NO',
     retcode              OUT NOCOPY NUMBER,
     errbuf               OUT NOCOPY VARCHAR2);


/*=====================================================================================+
|
|   Name:          Store_Results
|
|   Description:   Procedure to store the preview results of an asset into a
|                  private pl/sql asset table(of type
|                  FA_MASS_CHG_UTILS_PKG.asset_table) for all the books
|                  the asset belongs to.  Proper conversions for output
|                  are taken care of in this procedure.
|
|   Parameters:    X_mc_rec
|                  X_to_rsr  (new rate source rule)
|                  X_cat_Flex_Struct
|
|   Returns:
|
|   Notes:
|
+=====================================================================================*/

PROCEDURE Store_Results(
     X_mc_rec              IN  FA_MASS_CHG_UTILS_PKG.mass_change_rec_type,
     X_To_RSR              IN  VARCHAR2,
     X_Cat_Flex_Struct     IN  NUMBER   := NULL
     );



END FARX_MCP;

/
