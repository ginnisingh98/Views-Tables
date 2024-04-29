--------------------------------------------------------
--  DDL for Package Body FA_IGI_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_IGI_EXT_PKG" AS
/* $Header: igiiafab.pls 120.5.12010000.4 2009/08/20 14:28:38 schakkin ship $   */

--===========================FND_LOG.START=====================================

    g_state_level NUMBER :=    FND_LOG.LEVEL_STATEMENT;
    g_proc_level  NUMBER :=    FND_LOG.LEVEL_PROCEDURE;
    g_event_level NUMBER :=    FND_LOG.LEVEL_EVENT;
    g_excep_level NUMBER :=    FND_LOG.LEVEL_EXCEPTION;
    g_error_level NUMBER :=    FND_LOG.LEVEL_ERROR;
    g_unexp_level NUMBER :=    FND_LOG.LEVEL_UNEXPECTED;
    g_path        VARCHAR2(200) := 'IGI.PLSQL.igiiacub.fa_igi_ext_pkg';

--===========================FND_LOG.END=====================================

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
) return BOOLEAN IS

BEGIN
   return TRUE;
END Do_Current_Addition;


-- Bug6391045 : Added the function Do_Addition
/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Addition                                                          |
 |                                                                         |
 | Description:                                                            |
 |    This IAC hook function is to calculate catch-up at the time of       |
 |    addition. IAC will encapsulate do_prior_addition call into this      |
 |    do_addition call.                                                    |
 |                                                                         |
 +=========================================================================*/

/* scalar
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
   p_event_id                       NIMBER,
   p_calling_function               VARCHAR2
) return BOOLEAN IS
BEGIN
   return TRUE;
END Do_Addition;

*/


FUNCTION Do_Addition(
   p_trans_rec                      FA_API_TYPES.trans_rec_type,
   p_asset_hdr_rec                  FA_API_TYPES.asset_hdr_rec_type,
   p_asset_cat_rec                  FA_API_TYPES.asset_cat_rec_type,
   p_asset_desc_rec                 FA_API_TYPES.asset_desc_rec_type,
   p_asset_fin_rec                  FA_API_TYPES.asset_fin_rec_type,
   p_asset_deprn_rec                FA_API_TYPES.asset_deprn_rec_type,
   p_asset_type_rec                 FA_API_TYPES.asset_type_rec_type,
   p_calling_function               VARCHAR2
) return BOOLEAN IS
BEGIN

      IF ( NOT (igi_iac_common_utils.is_iac_book(p_asset_hdr_rec.book_type_code))) THEN

         return TRUE;
      END IF;

-- Created a new procedure Do_Addition_Wrapper which encapsultaes the do_prior_addition call
-- R12 uptake
  IF ( NOT ( Igi_Iac_Additions_Pkg.Do_Addition_Wrapper(p_asset_hdr_rec.book_type_code,
                                                      p_asset_hdr_rec.asset_id,
                                                      p_asset_cat_rec.category_id,
                                                      p_asset_fin_rec.deprn_method_code,
                                                      p_asset_fin_rec.cost,
                                                      p_asset_fin_rec.adjusted_cost,
                                                      p_asset_fin_rec.salvage_value,
                                                      p_asset_desc_rec.current_units,
                                                      p_asset_fin_rec.life_in_months,
                                                      p_trans_rec.event_id,
                                                      p_calling_function))) THEN


        return FALSE;
     END IF;

     Return TRUE;
END Do_Addition;


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
   ) return BOOLEAN  IS
       l_path_name VARCHAR2(300);
   BEGIN

      l_path_name := g_path||'.Validate_Retire_Reinstate';

      IF ( NOT (igi_iac_common_utils.is_iac_book(p_book_type_code))) THEN
          Return True;
      END IF;

      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
          p_full_path => l_path_name,
          p_string => 'p_asset_id = '||p_asset_id);

      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
          p_full_path => l_path_name,
          p_string => 'p_book_type_code = '||p_book_type_code);

      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
          p_full_path => l_path_name,
          p_string => 'p_calling_function = '||p_calling_function);

      IF IGI_IAC_COMMON_UTILS.Is_Asset_Adjustment_Done(X_book_type_code => p_book_type_code,
                                                       X_asset_id => p_asset_id) THEN
         igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                 p_full_path => l_path_name,
                 p_string => 'Adjustment exists in the current period for the given asset');
          fnd_message.set_name('IGI', 'IGI_IAC_NO_REINST_ADJUST');
          fnd_msg_pub.add;
          Return False;
      ELSE
          igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                 p_full_path => l_path_name,
                 p_string => 'No Adjustment exists in the current period for the given asset');
          Return True;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
          igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
              p_full_path => l_path_name,
              p_string => 'Unexpected error SQLERRM(sqlcode) = '||SQLERRM(sqlcode));

          fnd_message.set_name('IGI', 'IGI_IAC_NO_REINST_ADJUST');
          fnd_message.set_token('PACKAGE', 'FA_IGI_EXT_PKG.Validate_Retire_Reinstate');
          fnd_msg_pub.add;
          Return False;
   END Validate_Retire_Reinstate;

-- Bug 8400876 : Uncommented the function Do_Prior_Addition
/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Prior_Addition                                                    |
 |                                                                         |
 | Description:                                                            |
 |     This function was added in R12 to allow FA to dual maintain the     |
 |     spec of this package. This function has been modified to return     |
 |     false. Release 12 FA code will never call this function.            |
 |                                                                         |
 +=========================================================================*/
-- Bug6391045
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
) return BOOLEAN IS
BEGIN
   -- Modified to return false as this function will never be called in Release 12.
   -- If flow reaches this point in R12, it is due to some error in FA code
   return FALSE;
END Do_Prior_Addition;
-- End of Bug 8400876

/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Adjustment                                                        |
 |                                                                         |
 | Description:                                                            |
 |    This IAC hook function is to process adjustment for IAC and called   |
 |    from Adjustment API(FA_ADJUSTMENT_PUB.DO_All_Books).                 |
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
) return BOOLEAN IS
BEGIN
    IF NOT(IGI_IAC_COMMON_UTILS.is_iac_book(p_asset_hdr_rec.book_type_code)) THEN
                 return TRUE;
    END IF;

    IF not (igi_iac_adj_pkg.Do_Record_Adjustments(
                                       p_trans_rec ,
                                       p_asset_hdr_rec,
                                       p_asset_cat_rec ,
                                       p_asset_desc_rec ,
                                       p_asset_type_rec  ,
                                       p_asset_fin_rec    ,
                                       p_asset_deprn_rec   ,
                                       p_calling_function
           )) THEN

           return FALSE;
     END IF;

      return TRUE;
END Do_Adjustment;

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
) return BOOLEAN IS

BEGIN
   IF NOT(IGI_IAC_COMMON_UTILS.is_iac_book(p_asset_hdr_rec.book_type_code)) THEN

                 return TRUE;
   END IF;
   IF ( NOT ( Igi_Iac_Reclass_Pkg.Do_Reclass(
                         p_trans_rec         ,
                         p_asset_hdr_rec     ,
                         p_asset_cat_rec_old ,
                         p_asset_cat_rec_new ,
                         p_asset_desc_rec    ,
                         p_asset_type_rec    ,
                         p_calling_function  ,
                         p_trans_rec.event_id  )))
    THEN
         return FALSE ;
    END IF;

    return TRUE;
END Do_Reclass;

/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Transfer                                                          |
 |                                                                         |
 | Description:                                                            |
 |    This IAC hook function is to process transfers for IAC and           |
 |    called from Transfer API(FA_TRANSFER_PUB.Do_Transfer).               |
 |                                                                         |
 +=========================================================================*/
FUNCTION Do_Transfer(
   p_trans_rec                      FA_API_TYPES.trans_rec_type,
   p_asset_hdr_rec                  FA_API_TYPES.asset_hdr_rec_type,
   p_asset_cat_rec                  FA_API_TYPES.asset_cat_rec_type,
   p_calling_function               VARCHAR2
) return BOOLEAN IS

BEGIN
   IF NOT(IGI_IAC_COMMON_UTILS.is_iac_book(p_asset_hdr_rec.book_type_code)) THEN

                 return TRUE;
   END IF;
   IF ( NOT ( IGI_IAC_TRANSFERS_PKG.Do_Transfer(
                                             p_trans_rec  ,
                                             p_asset_hdr_rec ,
                                             p_asset_cat_rec  ,
                                             p_calling_function,
                                             p_trans_rec.event_id   ))) THEN
        return FALSE;
   END IF;
   return TRUE;

END Do_Transfer;

-- Bug 8400876 : Uncommented the function Do_Prior_Transfer
/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Prior_Transfer                                                    |
 |                                                                         |
 | Description:                                                            |
 |     This function was added in R12 to allow FA to dual maintain the     |
 |     spec of this package. This function has been modified to return     |
 |     false. Release 12 FA code will never call this function.            |
 |                                                                         |
 +=========================================================================*/
-- Bug6391045
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
) return BOOLEAN IS

BEGIN
   -- Modified to return false as this function will never be called in Release 12.
   -- If flow reaches this point in R12, it is due to some error in FA code
   return FALSE;
END Do_Prior_Transfer;
-- End of Bug 8400876


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
) return BOOLEAN IS
BEGIN
   return TRUE;
END Do_Unit_Adjustment;

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
   p_period_rec                     FA_API_TYPES.period_rec_type,
   p_calling_function               VARCHAR2
) return BOOLEAN IS
BEGIN
   return TRUE;
END Do_Unplanned;

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
) return BOOLEAN IS

BEGIN
   IF ( NOT (igi_iac_common_utils.is_iac_book(p_book_type_code))) THEN

         return TRUE;
   END IF;

   IF ( NOT ( IGI_IAC_DEPRN_PKG.Do_Depreciation(
                  p_book_type_code  ,
                  p_period_counter  ,
                  p_calling_function ))) THEN
       RETURN FALSE ;
   END IF;
   return TRUE;
END Do_Depreciation;


/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Gain_Loss                                                         |
 |                                                                         |
 | Description:                                                            |
 |    This IAC hook function is to process gain and loss calculation for   |
 |    IAC and called from Gain and Loss program(fagpro.lpc).               |
 |    Added for FP Bug 8566785                                                                      |
 +=========================================================================*/
FUNCTION Do_Gain_Loss(
   p_retirement_id                  NUMBER,
   p_asset_id                       NUMBER,
   p_book_type_code                 VARCHAR2,
-- p_event_id                       NUMBER,-- Bug6391045
   p_calling_function               VARCHAR2
) return BOOLEAN  IS
BEGIN
          return FALSE;
END Do_Gain_Loss;

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
   p_event_id                       NUMBER,-- Bug6391045
   p_calling_function               VARCHAR2
) return BOOLEAN  IS

    l_txn_id_out   NUMBER := 0 ;
BEGIN
   IF ( NOT (igi_iac_common_utils.is_iac_book(p_book_type_code))) THEN

          return TRUE;
   END IF;

   SELECT  nvl(ret.transaction_header_id_out,0)
   INTO    l_txn_id_out
   FROM    fa_retirements ret
   WHERE   ret.retirement_id = p_retirement_id ;


   IF ( l_txn_id_out = 0  ) THEN
      IF ( NOT( IGI_IAC_RETIREMENT.Do_Iac_Retirement ( p_asset_id         ,
                                                       p_book_type_code   ,
                                                       p_retirement_id    ,
                                                       p_calling_function ,
                                                       p_event_id)))
      THEN
          RETURN FALSE ;
      END IF ;
   ELSE
      IF ( NOT( IGI_IAC_REINSTATE_PKG.Do_Iac_Reinstatement( p_asset_id         ,
                                                            p_book_type_code   ,
                                                            p_retirement_id    ,
                                                            p_calling_function ,
                                                            p_event_id)))
      THEN
          RETURN FALSE ;
      END IF ;
   END IF;

   return TRUE;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       Return TRUE ;
END Do_Gain_Loss;

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
 -- Bug6391045 : New Signature for the function Do_Rollback_Deprn
FUNCTION Do_Rollback_Deprn(
   p_asset_hdr_rec               fa_api_types.asset_hdr_rec_type,
   p_period_rec                  fa_api_types.period_rec_type,
   p_deprn_run_id                NUMBER,
   p_reversal_event_id           NUMBER,
   p_reversal_date               DATE,
   p_deprn_exists_count          NUMBER,
   p_calling_function            VARCHAR2
) return BOOLEAN IS

BEGIN
    IF NOT igi_iac_additions_pkg.do_rollback_addition(
                                           p_asset_hdr_rec.book_type_code,
                                           p_period_rec.period_counter,
                                           p_calling_function) THEN
        return FALSE;
    END IF;

    IF NOT igi_iac_transfers_pkg.do_rollback_deprn(
                                           p_asset_hdr_rec.book_type_code,
                                           p_period_rec.period_counter,
                                           p_calling_function) THEN
        return FALSE;
    END IF;

   return TRUE;
END Do_Rollback_Deprn;

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
) return BOOLEAN IS

BEGIN
   return TRUE;
END Do_Rollback_JE;


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
FUNCTION IAC_Enabled return BOOLEAN IS
BEGIN
     IF igi_gen.is_req_installed('IAC') THEN
        return TRUE ;
     END IF;
     return FALSE;
END IAC_Enabled;


-- Bug 8400876 : Added the function Do_Rollback_Deprn
/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Rollback_Deprn                                                    |
 |                                                                         |
 | Description:                                                            |
 |     This function was added in R12 to allow FA to dual maintain the     |
 |     spec of this package. This function has been modified to return     |
 |     false. Release 12 FA code will never call this function.            |
 |                                                                         |
 +=========================================================================*/
FUNCTION Do_Rollback_Deprn(
   p_book_type_code                 VARCHAR2,
   p_period_counter                 NUMBER,
   p_calling_function               VARCHAR2
) return BOOLEAN IS

BEGIN
   -- Modified to return false as this function will never be called in Release 12.
   -- If flow reaches this point in R12, it is due to some error in FA code
   return FALSE;
END Do_Rollback_Deprn;
-- End of Bug 8400876

END FA_IGI_EXT_PKG;

/
