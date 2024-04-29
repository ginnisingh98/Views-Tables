--------------------------------------------------------
--  DDL for Package IGI_IAC_YTD_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_YTD_ENGINE" AUTHID CURRENT_USER AS
-- $Header: igiiayts.pls 120.2.12000000.1 2007/08/01 16:20:32 npandya noship $

/*=========================================================================+
 | Function Name:                                                          |
 |    Calculate_YTD                                                        |
 |                                                                         |
 | Description:                                                            |
 |    This function splits the depreciation reserve linearly for the 	   |
 |    current year and prior year periods                                  |
 |                                                                         |
 +=========================================================================*/
    FUNCTION Calculate_YTD
        (p_book_type_code IN VARCHAR2,
        p_asset_id         IN NUMBER,
        p_asset_info  IN OUT NOCOPY igi_iac_types.fa_hist_asset_info,
        p_start_period  IN OUT NOCOPY NUMBER,
        p_end_period    IN OUT NOCOPY NUMBER,
        p_calling_program IN VARCHAR2
        )
     RETURN  BOOLEAN;

END igi_iac_ytd_engine; -- Package spec


 

/
