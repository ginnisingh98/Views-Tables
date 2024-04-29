--------------------------------------------------------
--  DDL for Package FARX_RR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FARX_RR" AUTHID CURRENT_USER AS
/* $Header: FARXRRS.pls 120.2.12010000.2 2009/07/19 11:44:42 glchen ship $ */

/*=====================================================================================+
|
|   Name:          Review_Reclass
|
|   Description:   Procedure for mass reclass review.
|		   This procedure is called from the concurrent wrapper procedure
|		   FARX_C_RR.Mass_Reclass_Review().
|		   The results of reclass transactions on all the eligible assets
|		   are inserted into the interfact table, FA_MASS_RECLASS_ITF.
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

PROCEDURE Review_Reclass(
	X_Mass_Reclass_Id	IN	NUMBER,
	X_RX_Flag		IN	VARCHAR2 := 'NO',
	retcode		 OUT NOCOPY NUMBER,
	errbuf		 OUT NOCOPY VARCHAR2);


END FARX_RR;

/
