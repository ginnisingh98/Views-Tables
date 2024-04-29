--------------------------------------------------------
--  DDL for Package FA_MASS_RECLASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MASS_RECLASS_PKG" AUTHID CURRENT_USER AS
/* $Header: FAXMRCLS.pls 120.3.12010000.2 2009/07/19 14:05:33 glchen ship $ */

/*=====================================================================================+
|
|   Name:          Do_Mass_Reclass
|
|   Description:   Mass transaction procedure for mass reclass.
|                  This procedure is no longer called from the concurrent
|                  wrapper procedure FA_C_MASS_RECLASS.Mass_Reclass().
|
|                  Instead it is called from a new pro*c wrapper (famrcl.opc)
|
|   Returns:
|
|   Notes:        02/01/02     bridgway    overhauled to be called from pro*c wrapper
|
+=====================================================================================*/

PROCEDURE Do_Mass_Reclass(
                p_mass_reclass_id    IN     NUMBER,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                p_request_number     IN     NUMBER,
                px_max_asset_id      IN OUT NOCOPY NUMBER,
                x_processed_count       OUT NOCOPY NUMBER,
                x_success_count         OUT NOCOPY number,
                x_failure_count         OUT NOCOPY number,
                x_return_status         OUT NOCOPY number);

/*=====================================================================================+
|
|   Name:          Check_Trans_Date
|
|   Description:   Function to check if reclass transaction date for the mass
|                  reclass record from mass reclass form is in the current
|                  corporate book period.
|
|   Parameters:    X_Corp_Book -- Corporate book to reclass.
|                  X_Trans_Date -- Reclass transaction date.
|
|   Returns:       TRUE -- if reclass date is in current corporate book period.
|                  FALSE -- if reclass date is in the prior corporate book period.
|
|   Notes:
|
+======================================================================================*/

FUNCTION Check_Trans_Date(
     X_Corp_Book           IN     VARCHAR2,
     X_Trans_Date          IN     DATE
   )     RETURN BOOLEAN;


/*=====================================================================================+
|
|   Name:          Check_Criteria
|
|   Description:   Function to make sure additional user selection criteria are met for
|                  the given asset.
|
|   Parameters:    X_Asset_Id -- Asset to reclass.
|                  X_Fully_Rsvd_Flag -- User selection criteria to include fully
|                                       reserved assets or not.
|
|   Returns:       TRUE -- if the asset passes all the criteria.
|                  FALSE -- if the asset fails any one of the criteria.
|
|   Notes:
|
+======================================================================================*/

FUNCTION Check_Criteria(
     X_Asset_Id            IN     NUMBER,
     X_Fully_Rsvd_Flag     IN     VARCHAR2
   )     RETURN BOOLEAN;


--------------------------------------------------------------------------------------

PROCEDURE write_message
              (p_asset_number    in varchar2,
               p_message         in varchar2);

END FA_MASS_RECLASS_PKG;

/
