--------------------------------------------------------
--  DDL for Package FA_IGI_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_IGI_EXT_PKG" AUTHID CURRENT_USER AS
/* $Header: FAIGIEXS.pls 120.3.12010000.2 2009/06/01 11:29:44 mswetha ship $   */

/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Current_Addition                                                  |
 |                                                                         |
 | Description:                                                            |
 |    This IAC hook function is to process addition for IAC and called from|
 |    Depreciation program(fadcje.lpc).                                    |
 |                                                                         |
 +=========================================================================*/
FUNCTION Do_Current_Addition(
   p_book_type_code                 VARCHAR2,
   p_asset_id                       NUMBER,
   p_calling_function               VARCHAR2
) return BOOLEAN;

-- Bug6391045 : Added the function Do_Addition
/*=========================================================================+
| Function Name:
|    Do_Addition
|
|
| Description:
|    This IAC hook function is to calculate catch-up at the time of
|    addition. IAC will encapsulate do_prior_addition call into this
|    do_addition call.
|
+=========================================================================*/
 FUNCTION Do_Addition(
   p_trans_rec                      FA_API_TYPES.trans_rec_type,
   p_asset_hdr_rec                  FA_API_TYPES.asset_hdr_rec_type,
   p_asset_cat_rec                  FA_API_TYPES.asset_cat_rec_type,
   p_asset_desc_rec                 FA_API_TYPES.asset_desc_rec_type,
   p_asset_fin_rec                  FA_API_TYPES.asset_fin_rec_type,
   p_asset_deprn_rec                FA_API_TYPES.asset_deprn_rec_type,
   p_asset_type_rec                 FA_API_TYPES.asset_type_rec_type,
   p_calling_function               VARCHAR2
) return BOOLEAN;

/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Prior_Addition                                                    |
 |                                                                         |
 | Description:                                                            |
 |    This IAC hook function is to process addition for IAC and called from|
 |    Depreciation program(fadp5.lpc).                                     |
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
   p_calling_function               VARCHAR2
) return BOOLEAN;

/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Adjustment                                                        |
 |                                                                         |
 | Description:                                                            |
 |    This IAC hook function is to process adjustment for IAC and called   |
 |    from Adjustment API(FA_ADJUSTMENT_PUB.Do_All_Books).                 |
 |                                                                         |
 +=========================================================================*/
FUNCTION Do_Adjustment(
   p_trans_rec                      FA_API_TYPES.trans_rec_type,
   p_asset_hdr_rec                  FA_API_TYPES.asset_hdr_rec_type,
   p_asset_cat_rec                  FA_API_TYPES.asset_cat_rec_type,
   p_asset_desc_rec                 FA_API_TYPES.asset_desc_rec_type,
   p_asset_type_rec                 FA_API_TYPES.asset_type_rec_type,
   p_asset_fin_rec                  FA_API_TYPES.asset_fin_rec_type,
   p_asset_deprn_rec                FA_API_TYPES.asset_deprn_rec_type,
   p_calling_function               VARCHAR2
) return BOOLEAN;

/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Reclass                                                           |
 |                                                                         |
 | Description:                                                            |
 |    This IAC hook function is to process reclassification for IAC and    |
 |    called from Reclass API(FA_RECLASS_PVT.Do_Reclass).                  |
 |                                                                         |
 +=========================================================================*/
FUNCTION Do_Reclass(
   p_trans_rec                      FA_API_TYPES.trans_rec_type,
   p_asset_hdr_rec                  FA_API_TYPES.asset_hdr_rec_type,
   p_asset_cat_rec_old              FA_API_TYPES.asset_cat_rec_type,
   p_asset_cat_rec_new              FA_API_TYPES.asset_cat_rec_type,
   p_asset_desc_rec                 FA_API_TYPES.asset_desc_rec_type,
   p_asset_type_rec                 FA_API_TYPES.asset_type_rec_type,
   p_calling_function               VARCHAR2
) return BOOLEAN;

/*=========================================================================+
| Function Name:
|    Do_Transfer
|
|
| Description:
|
|    This IAC hook function is to process transfers for IAC and
|
|    called from Transfer API(FA_TRANSFER_PUB.Do_Transfer).
|
|
|
+=========================================================================*/
FUNCTION Do_Transfer(
   p_trans_rec                      FA_API_TYPES.trans_rec_type,
   p_asset_hdr_rec                  FA_API_TYPES.asset_hdr_rec_type,
   p_asset_cat_rec                  FA_API_TYPES.asset_cat_rec_type,
   p_calling_function               VARCHAR2
) return BOOLEAN;

/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Prior_Transfer                                                    |
 |                                                                         |
 | Description:                                                            |
 |    This IAC hook function is to process transfers for IAC and called    |
 |    from Depreciation program(fadp5.lpc).                                |
 |                                                                         |
 +=========================================================================*/
FUNCTION Do_Prior_Transfer(
   p_book_type_code                 VARCHAR2,
   p_asset_id                       NUMBER,
   p_category_id                    NUMBER,
   p_transaction_header_id          NUMBER,
   p_cost                           NUMBER,
   p_adjusted_cost                  NUMBER,
   p_salvage_value                  NUMBER,
   p_current_unit                   NUMBER,
   p_life_in_months                 NUMBER,
   p_calling_function               VARCHAR2
) return BOOLEAN;

/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Unit_Adjustment                                                   |
 |                                                                         |
 | Description:                                                            |
 |    This IAC hook function is to process unit adjustment for IAC and     |
 |    called from Unit Adjustment API(FA_UNIT_ADJ_PUB.Do_Unit_Adjustment). |
 |                                                                         |
 +=========================================================================*/
FUNCTION Do_Unit_Adjustment(
   p_trans_rec                      FA_API_TYPES.trans_rec_type,
   p_asset_hdr_rec                  FA_API_TYPES.asset_hdr_rec_type,
   p_asset_cat_rec                  FA_API_TYPES.asset_cat_rec_type,
   p_calling_function               VARCHAR2
) return BOOLEAN;

/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Unplanned                                                         |
 |                                                                         |
 | Description:                                                            |
 |    This IAC hook function is to process unplanned depreciation for IAC  |
 |    and called from Unplanned Depreciation API                           |
 |    (FA_UNPLANNED_PUB.Do_Unplanned).                                     |
 |                                                                         |
 +=========================================================================*/
FUNCTION Do_Unplanned(
   p_trans_rec                      FA_API_TYPES.trans_rec_type,
   p_asset_hdr_rec                  FA_API_TYPES.asset_hdr_rec_type,
   p_asset_cat_rec                  FA_API_TYPES.asset_cat_rec_type,
   p_asset_desc_rec                 FA_API_TYPES.asset_desc_rec_type,
   p_asset_type_rec                 FA_API_TYPES.asset_type_rec_type,
   p_unplanned_deprn_rec            FA_API_TYPES.unplanned_deprn_rec_type,
   p_period_rec                   FA_API_TYPES.period_rec_type,
   p_calling_function               VARCHAR2
) return BOOLEAN;

/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Depreciation                                                      |
 |                                                                         |
 | Description:                                                            |
 |    This IAC hook function is to process Post-Depreciation for IAC and   |
 |    called from Depreciation program(fadpmn.opc).                        |
 |                                                                         |
 +=========================================================================*/
FUNCTION Do_Depreciation(
   p_book_type_code                 VARCHAR2,
   p_period_counter                 NUMBER,
   p_calling_function               VARCHAR2
) return BOOLEAN;


/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Gain_Loss                                                         |
 |                                                                         |
 | Description:                                                            |
 |    This IAC hook function is to process gain and loss calculation for   |
 |    IAC and called from Gain and Loss program(fagpro.lpc).               |
 |                                                                         |
 +=========================================================================*/
FUNCTION Do_Gain_Loss(
   p_retirement_id                  NUMBER,
   p_asset_id                       NUMBER,
   p_book_type_code                 VARCHAR2,
   p_event_id                       NUMBER,  -- Bug6391045
   p_calling_function               VARCHAR2
) return BOOLEAN;

/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Gain_Loss                                                         |
 |                                                                         |
 | Description:                                                            |
 |    This IAC hook function is to process gain and loss calculation for   |
 |    IAC and called from Gain and Loss program(fagpro.lpc).               |
 |                                                                         |
 +=========================================================================*/
FUNCTION Do_Gain_Loss(
   p_retirement_id                  NUMBER,
   p_asset_id                       NUMBER,
   p_book_type_code                 VARCHAR2,
-- p_event_id                       NUMBER,  -- Bug6391045
   p_calling_function               VARCHAR2
) return BOOLEAN;

/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Rollback_Deprn                                                    |
 |                                                                         |
 | Description:                                                            |
 |    This IAC hook function is to process Rollback Depreciation for IAC   |
 |    and called from Rollback Depreciation program                        |
 |    (FA_DEPRN_ROLLBACK_PKG.do_rollback).                                 |
 |                                                                         |
 +=========================================================================*/
FUNCTION Do_Rollback_Deprn(
   p_book_type_code                 VARCHAR2,
   p_period_counter                 NUMBER,
   p_calling_function               VARCHAR2
) return BOOLEAN;

/*=========================================================================+
| Function Name:
|    Do_Rollback_Deprn
|
| Description:
|    This IAC hook function is to process Rollback Depreciation for IAC
|    and called from Rollback Depreciation program
|    (FA_DEPRN_ROLLBACK_PKG.do_rollback).
|
+=========================================================================*/
 -- Bug6391045 : New Signature for the function Do_Rollback_Deprn
FUNCTION Do_Rollback_Deprn(
   p_asset_hdr_rec               fa_api_types.asset_hdr_rec_type,
   p_period_rec                  fa_api_types.period_rec_type,
   p_deprn_run_id                NUMBER,
   p_reversal_event_id           NUMBER,
   p_reversal_date               DATE,
   p_deprn_exists_count          NUMBER,
   p_calling_function            VARCHAR2
) return BOOLEAN;

/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Rollback_JE                                                       |
 |                                                                         |
 | Description:                                                            |
 |    This IAC hook function is to process Rollback Journal Entries for    |
 |    IAC and called from (FA_JE_ROLLBACK_PKG.do_rollback).                |
 |                                                                         |
 +=========================================================================*/
FUNCTION Do_Rollback_JE(
   p_book_type_code                 VARCHAR2,
   p_period_counter                 NUMBER,
   p_set_of_books_id                NUMBER,
   p_batch_name                     VARCHAR2,
   p_je_batch_id                    NUMBER,
   p_calling_function               VARCHAR2
) return BOOLEAN;

/*=========================================================================+
 | Function Name:                                                          |
 |    IAC_Enabled                                                          |
 |                                                                         |
 | Description:                                                            |
 |    This is to return flag to indicate whether subsequent IAC calls      |
 |    should be made or not.                                               |
 |    This function will return FALSE if IAC is not installed or not set   |
 |    up to use IAC feature.                                               |
 |                                                                         |
 +=========================================================================*/
FUNCTION IAC_Enabled return BOOLEAN;


/*=========================================================================+
 | Function Name:                                                          |
 |    Validate_Retire_Reinstate                                            |
 |                                                                         |
 | Description: [Added for Bug 8524429]                                    |
 |    The function is called from package FA_RETIREMENT_PUB and is used to |
 |    perform validations before allowing retirement or reinstatements     |
 |                                                                         |
 +=========================================================================*/
FUNCTION Validate_Retire_Reinstate(
   p_book_type_code                 VARCHAR2,
   p_asset_id                       NUMBER,
   p_calling_function               VARCHAR2
) return BOOLEAN;

END FA_IGI_EXT_PKG;

/
