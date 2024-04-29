--------------------------------------------------------
--  DDL for Package FARX_MCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FARX_MCR" AUTHID CURRENT_USER AS
/* $Header: FARXMCRS.pls 120.0.12010000.2 2009/07/19 11:58:45 glchen ship $ */

/*=====================================================================================+
|
|   Name:          Review_Change
|
|   Description:   Procedure for mass reclass review.
|                  This procedure is called from the concurrent wrapper procedure
|                  FARX_C_CR.Mass_Change_Review().
|                  The results of change transactions on all the eligible assets
|                  are inserted into the interface table, FA_MASS_CHANGES_ITF.
|                  User asset selection and reclass criteria are fetched from
|                  FA_MASS_CHANGES table.
|
|   Parameters:    X_Mass_Change_Id -- Mass Change ID from FA_MASS_CHANGES table.
|                  X_RX_Flag -- Indicates whether this procedure is called from
|                               RX report or not.
|                  retcode -- OUT parameter.  Denotes completion status.
|                    0 -- Completed normally.
|                    1 -- Completed with warning.
|                    2 -- Completed with error.
|                  errbuf -- OUT parameter.  Error or warning description.
|
|   Returns:
|
|   Notes:
|
+=====================================================================================*/

PROCEDURE Review_Change(
     X_Mass_Change_Id     IN     NUMBER,
     X_RX_Flag            IN     VARCHAR2 := 'NO',
     retcode              OUT NOCOPY NUMBER,
     errbuf               OUT NOCOPY VARCHAR2);


END FARX_MCR;

/
