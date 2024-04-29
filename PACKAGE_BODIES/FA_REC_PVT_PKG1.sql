--------------------------------------------------------
--  DDL for Package Body FA_REC_PVT_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_REC_PVT_PKG1" AS
/* $Header: FAXVRC1B.pls 120.5.12010000.2 2009/07/19 11:13:25 glchen ship $ */

--
-- FUNCTION Validate_Reclass_Basic
--


FUNCTION Validate_Reclass_Basic(
	p_asset_id		IN	NUMBER,
	p_old_category_id	IN	NUMBER,
	p_new_category_id	IN	NUMBER,
	p_mr_req_id		IN	NUMBER,
	x_old_cat_type		IN OUT NOCOPY VARCHAR2
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)	RETURN BOOLEAN IS
BEGIN
          if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('FARX_RP.Preview_Reclass',
	       'Starting Validate_reclass_basic',
	        p_asset_id, p_log_level_rec => p_log_level_rec);
	  end if;

    /* Otherwise, mass reclass.  Just silently skip validation and transaction
       engine if old and new categories are the same.
       Redefault will be skipped as well. */
    -- This check is now handled by Mass Reclass Program.
    /*
    IF (p_old_category_id = p_new_category_id) THEN
	-- The rest can be skipped.
	RETURN (TRUE);
    END IF;
    */

    /* Check if an asset is retired in any book, or if a retirement is pending. */
    IF NOT Check_Retirements(p_asset_id => p_asset_id,
                             p_log_level_rec => p_log_level_rec) THEN
          if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('FARX_RP.Preview_Reclass',
	       'Check_retirments skipped asset:',
	        p_asset_id, p_log_level_rec => p_log_level_rec);
	  end if;

	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG1.Validate_Reclass_Basic', p_log_level_rec => p_log_level_rec);
	RETURN (FALSE);
    END IF;

    /* Check if category chage is feasible. */
    IF NOT Validate_Category_Change(
		p_asset_id 		=> p_asset_id,
		p_old_category_id	=> p_old_category_id,
		p_new_category_id	=> p_new_category_id,
		p_mr_req_id		=> p_mr_req_id,
		x_old_cat_type		=> x_old_cat_type,
                p_log_level_rec         => p_log_level_rec
		)
    THEN
          if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('FARX_RP.Preview_Reclass',
	       'Validate_Category_Change skipped asset:',
	        p_asset_id, p_log_level_rec => p_log_level_rec);
	  end if;

	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG1.Validate_Reclass_Basic', p_log_level_rec => p_log_level_rec);
	RETURN (FALSE);
    END IF;

          if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('FARX_RP.Preview_Reclass',
	       'Validate_reclass_basic successful:',
	        p_asset_id, p_log_level_rec => p_log_level_rec);
	  end if;

    RETURN (TRUE);

    /* May add validations for FA_ADDITIONS items in the future for single reclass.
       It is not necessary to add validations for these items, since mass reclass
       won't need validations for these items.  May borrow validation engine from
       ADDITIONS validation engine in the future. */

EXCEPTION
    WHEN OTHERS THEN
   	FA_SRVR_MSG.Add_SQL_Error(
		CALLING_FN => 'FA_REC_PVT_PKG1.Validate_Reclass_Basic', p_log_level_rec => p_log_level_rec);
        RETURN (FALSE);
END Validate_Reclass_Basic;


--
-- FUNCTION Check_Retirements
--

FUNCTION Check_Retirements(
	p_asset_id		IN	NUMBER
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)	RETURN BOOLEAN IS
	l_is_retired		NUMBER := 0;
	l_pending_retirements	NUMBER := 0;
	faurcl_error		EXCEPTION;
BEGIN
    /* Check if the asset is fully retired in any book. */
    -- Use the existing function in FA_ASSET_RECLASS_PKG.
    SELECT count(*)
      INTO l_is_retired
      FROM FA_BOOKS   BK,
           FA_BOOK_CONTROLS BC
     WHERE
           BK.ASSET_ID = p_asset_id AND
           BK.PERIOD_COUNTER_FULLY_RETIRED IS NOT NULL AND
           BK.DATE_INEFFECTIVE IS NULL AND
           BK.BOOK_TYPE_CODE = BC.BOOK_TYPE_CODE AND
           BC.DATE_INEFFECTIVE IS NULL;

    IF l_is_retired > 0 THEN
       FA_SRVR_MSG.Add_Message(
         CALLING_FN => 'FA_REC_PVT_PKG1.Check_Retirements',
         NAME => 'FA_REC_RETIRED'
         , p_log_level_rec => p_log_level_rec);
       RETURN (FALSE);
    END IF;

    /* Check if there is any pending retirements for the asset. */
    SELECT count(1) INTO l_pending_retirements
    FROM fa_retirements
    WHERE asset_id = p_asset_id
    AND status IN ('PENDING', 'REINSTATE')
    AND rownum < 2;

    IF (l_pending_retirements > 0) THEN
	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG1.Check_Retirements',
		NAME => 'FA_RET_PENDING_RETIREMENTS', p_log_level_rec => p_log_level_rec);
	RETURN (FALSE);
    END IF;

    RETURN (TRUE);
EXCEPTION
    WHEN faurcl_error THEN
	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG1.Check_Retirements', p_log_level_rec => p_log_level_rec);
	RETURN (FALSE);
    WHEN OTHERS THEN
   	FA_SRVR_MSG.Add_SQL_Error(
		CALLING_FN => 'FA_REC_PVT_PKG1.Check_Retirements', p_log_level_rec => p_log_level_rec);
        RETURN (FALSE);
END Check_Retirements;


--
-- FUNCTION Validate_Category_Change
--

FUNCTION Validate_Category_Change(
        p_asset_id              IN      NUMBER,
        p_old_category_id       IN      NUMBER,
        p_new_category_id       IN      NUMBER,
	p_mr_req_id		IN	NUMBER,
	x_old_cat_type		IN OUT NOCOPY VARCHAR2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)       RETURN BOOLEAN IS
	l_asset_type	VARCHAR2(11);
	l_old_cap_flag	VARCHAR2(3);
	l_new_cat_type	VARCHAR2(30);
	l_lease_id	NUMBER(15) := NULL;
	l_check_count1	NUMBER := 0;
	l_check_count2 	NUMBER := 0;
	l_ah_units	NUMBER := 0;
	l_dh_units	NUMBER := 0;
	CURSOR get_asset_type IS
	    SELECT asset_type FROM FA_ADDITIONS
    	    WHERE asset_id = p_asset_id;
	CURSOR get_old_cat_info IS
	    SELECT capitalize_flag, category_type
    	    FROM FA_CATEGORIES WHERE category_id = p_old_category_id;
	CURSOR get_lease_id IS
	    SELECT lease_id FROM FA_ADDITIONS
	    WHERE asset_id = p_asset_id;
	CURSOR get_ah_units IS
	    SELECT units FROM FA_ASSET_HISTORY
	    WHERE asset_id = p_asset_id
	    AND date_ineffective IS NULL;
	CURSOR get_dh_units IS
	    SELECT sum(units_assigned) FROM FA_DISTRIBUTION_HISTORY
	    WHERE asset_id = p_asset_id
	    AND date_ineffective is NULL;
BEGIN
    -- Check from transction approval per asset.  Units in asset history and
    -- distribution history must match.
    OPEN get_ah_units;
    FETCH get_ah_units INTO l_ah_units;
    CLOSE get_ah_units;

    OPEN get_dh_units;
    FETCH get_dh_units INTO l_dh_units;
    CLOSE get_dh_units;

    IF (l_ah_units <> l_dh_units) THEN
	FA_SRVR_MSG.Add_Message(
        	CALLING_FN  =>  'FA_REC_PVT_PKG1.Validate_Category_Change',
                NAME        =>  'FA_SHARED_UNITS_UNBAL', p_log_level_rec => p_log_level_rec);
	RETURN (FALSE);
    END IF;

    -- Make sure the new category is defined in all the books the asset belongs to.
    -- Get the number of books in which the new category is defined for the asset.
    SELECT count(*) INTO l_check_count1
    FROM FA_CATEGORY_BOOKS cb, FA_BOOKS bk, fa_book_controls bc
    WHERE bk.asset_id = p_asset_id
    AND bk.date_ineffective IS NULL
    AND bk.book_type_code = cb.book_type_code
    AND cb.category_id = p_new_category_id
    AND bc.book_type_code = bk.book_type_code
    AND nvl(bc.date_ineffective,sysdate) >= sysdate;

    -- Get the total number of books the asset belongs to.
    SELECT count(*) INTO l_check_count2
    FROM FA_BOOKS bk, FA_BOOK_CONTROLS bc
    WHERE bk.asset_id = p_asset_id
    AND bk.date_ineffective IS NULL
    AND bk.book_type_code = bc.book_type_code
    AND nvl(bc.date_ineffective,sysdate) >= sysdate;


    IF (l_check_count1 <> l_check_count2) THEN
          if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('FARX_RP.Preview_Reclass',
	       'Validate_category_change skipped asset:',
	        p_asset_id, p_log_level_rec => p_log_level_rec);

               fa_debug_pkg.add('FARX_RP.Preview_Reclass',
	       'You may need to define all books your asset belongs to, ',
	        'for the new category. See Setup Categories form.', p_log_level_rec => p_log_level_rec);
	  end if;

	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG1.Validate_Category_Change',
		NAME => 'FA_REC_CAT_BOOK_NOT_SETUP', p_log_level_rec => p_log_level_rec);
		/* Message text:
		   'The new category is not defined in at least one of the depreciation
		    books the asset belongs to.' */
	RETURN (FALSE);
    END IF;

    OPEN get_asset_type;
    FETCH get_asset_type INTO l_asset_type;
    CLOSE get_asset_type;

    OPEN get_old_cat_info;
    FETCH get_old_cat_info INTO l_old_cap_flag, x_old_cat_type;
    CLOSE get_old_cat_info;

    IF x_old_cat_type = 'LEASE' THEN
       OPEN get_lease_id;
       FETCH get_lease_id INTO l_lease_id;
       CLOSE get_lease_id;
    END IF;

    -- x_old_cat_type value returned from Val_Reclass.
    IF NOT FA_DET_ADD_PKG.Val_Reclass(
		X_Old_Cat_Id		=> p_old_category_id,
		X_New_Cat_Id		=> p_new_category_id,
		X_Asset_Id		=> p_asset_id,
		X_Asset_Type		=> l_asset_type,
		X_Old_Cap_Flag		=> l_old_cap_flag,
		X_Old_Cat_Type		=> x_old_cat_type,
		X_New_Cat_Type		=> l_new_cat_type,
		X_Lease_Id		=> l_lease_id,
		X_Calling_Fn		=> 'FA_REC_PVT_PKG1.Validate_Category_Change'
		, p_log_level_rec => p_log_level_rec)
    THEN
	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG1.Validate_Category_Change', p_log_level_rec => p_log_level_rec);
	RETURN (FALSE);
    END IF;

    RETURN (TRUE);

EXCEPTION
    WHEN OTHERS THEN
	FA_SRVR_MSG.Add_SQL_Error(
		CALLING_FN => 'FA_REC_PVT_PKG1.Validate_Category_Change', p_log_level_rec => p_log_level_rec);
        RETURN (FALSE);
END Validate_Category_Change;

/*===================================================================================+
| FUNCTION Check_Trans_Date
|
+====================================================================================*/

FUNCTION Check_Trans_Date(
        p_asset_id         IN   NUMBER,
        p_book_type_code   IN   VARCHAR2,
        p_trans_date       IN   DATE, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)       RETURN BOOLEAN IS

        prior_trans_date        DATE;
        prior_date_effective    DATE;
        check_another_trans     NUMBER := 0;
        CURSOR get_prior_trans_date IS
            SELECT      max(transaction_date_entered)
            FROM        FA_TRANSACTION_HEADERS
            WHERE       asset_id = p_asset_id
            AND         book_type_code = p_book_type_code
            AND         transaction_type_code not like '%/VOID';

        CURSOR get_prior_date_effective IS
            SELECT      max(date_effective)
            FROM        FA_TRANSACTION_HEADERS
            WHERE       asset_id = p_asset_id
            AND         book_type_code = p_book_type_code;
BEGIN
    /*  Logic from FA_BOOKS_VAL5.Amortization_Start_Date from FAXASSET. */
    -- Check another transaction between transaction date and current period.
    OPEN get_prior_trans_date;
    FETCH get_prior_trans_date INTO prior_trans_date;
    CLOSE get_prior_trans_date;

    IF (p_trans_date < prior_trans_date) THEN
        FA_SRVR_MSG.Add_Message(
            CALLING_FN => 'FA_REC_PVT_PKG5.Check_Trans_Date',
            NAME => 'FA_SHARED_OTHER_TRX_FOLLOW', p_log_level_rec => p_log_level_rec);
        RETURN (FALSE);
    END IF;

    OPEN get_prior_date_effective;
    FETCH get_prior_date_effective INTO prior_date_effective;
    CLOSE get_prior_date_effective;

    SELECT count(1) INTO check_another_trans
    FROM FA_DEPRN_PERIODS pdp, FA_DEPRN_PERIODS adp
    WHERE pdp.book_type_code = p_book_type_code
    AND pdp.book_type_code = adp.book_type_code
    AND pdp.period_counter > adp.period_counter
    AND prior_date_effective between pdp.period_open_date
            and nvl(pdp.period_close_date, to_date('31-12-4712','DD-MM-YYYY'))
    AND p_trans_date between
            adp.calendar_period_open_date and adp.calendar_period_close_date;

    IF (check_another_trans > 0) THEN
        FA_SRVR_MSG.Add_Message(
            CALLING_FN => 'FA_REC_PVT_PKG5.Check_Trans_Date',
            NAME => 'FA_SHARED_OTHER_TRX_FOLLOW', p_log_level_rec => p_log_level_rec);
        RETURN (FALSE);
    END IF;

    RETURN (TRUE);

EXCEPTION
    WHEN OTHERS THEN
        FA_SRVR_MSG.Add_SQL_Error(
                CALLING_FN =>  'FA_REC_PVT_PKG5.Check_Trans_Date', p_log_level_rec => p_log_level_rec);
        RETURN (FALSE);
END Check_Trans_Date;


END FA_REC_PVT_PKG1;

/
