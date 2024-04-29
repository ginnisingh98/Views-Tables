--------------------------------------------------------
--  DDL for Package IGI_IAC_ADDITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_ADDITIONS_PKG" AUTHID CURRENT_USER AS
-- $Header: igiiapas.pls 120.4.12000000.2 2007/10/16 14:21:13 sharoy ship $

/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Prior_Addition                                                    |
 |                                                                         |
 | Description:                                                            |
 |    This IAC function is for doing IAC processing for Assets added in    |
 |    Prior Periods and called from (FA_IGI_EXT_PKG.do_prior_addition).	   |
 |                                                                         |
 +=========================================================================*/
    FUNCTION Do_Prior_Addition(
       p_book_type_code                 VARCHAR2,
       p_asset_id                       NUMBER,
       p_category_id                    NUMBER,
       p_deprn_method_code              VARCHAR2,
       p_cost                           NUMBER,
       p_adjusted_cost                  NUMBER,
       p_salvage_value                  NUMBER,
       p_current_unit                   NUMBER,
       p_life_in_months                 NUMBER,
       p_event_id                       NUMBER,
       p_calling_function               VARCHAR2
    ) return BOOLEAN;

/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Addition                                                          |
 |                                                                         |
 | Description:                                                            |
 |    This IAC function is for processing the assets for IAC additions 	   |
 |    catchup. Called from do_prior_addition and igi_imp_iac_prepare_pkg.  |
 |    prepare_corp_data.
 |                                                                         |
 +=========================================================================*/
    FUNCTION Do_Addition(
       p_book_type_code                 VARCHAR2,
       p_asset_id                       NUMBER,
       p_category_id                    NUMBER,
       p_deprn_method_code              VARCHAR2,
       p_cost                           NUMBER,
       p_adjusted_cost                  NUMBER,
       p_salvage_value                  NUMBER,
       p_current_unit                   NUMBER,
       p_life_in_months                 NUMBER,
       p_deprn_reserve                  NUMBER,
       p_deprn_ytd                      NUMBER,
       p_calling_function               VARCHAR2,
       p_event_id                       NUMBER
    ) return BOOLEAN;
/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Addition_Wrapper                                                  |
 |                                                                         |
 | Description:                                                            |
 |    This IAC function is for wrapping up the the Do_Prior_Addition() 	   |
 |    procedure.                                                           |
 |    R12 uptake                                                           |
 +=========================================================================*/
    FUNCTION Do_Addition_Wrapper(
       p_book_type_code                 VARCHAR2,
       p_asset_id                       NUMBER,
       p_category_id                    NUMBER,
       p_deprn_method_code              VARCHAR2,
       p_cost                           NUMBER,
       p_adjusted_cost                  NUMBER,
       p_salvage_value                  NUMBER,
       p_current_unit                   NUMBER,
       p_life_in_months                 NUMBER,
       p_event_id                       NUMBER,
       p_calling_function               VARCHAR2
    ) return BOOLEAN;
/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Rollback_Addition                                                 |
 |                                                                         |
 | Description:                                                            |
 |    This IAC function is to process Rollback from FA Depreciation for    |
 |    IAC Prior Additions and called from                                  |
 |   (FA_IGI_EXT_PKG.do_rollback_deprn).                                   |
 |                                                                         |
 +=========================================================================*/
    FUNCTION Do_Rollback_Addition(
       p_book_type_code                 VARCHAR2,
       p_period_counter                 NUMBER,
       p_calling_function               VARCHAR2
    ) return BOOLEAN;

END igi_iac_additions_pkg; -- Package spec

 

/
