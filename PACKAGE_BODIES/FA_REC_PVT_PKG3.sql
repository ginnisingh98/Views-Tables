--------------------------------------------------------
--  DDL for Package Body FA_REC_PVT_PKG3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_REC_PVT_PKG3" AS
/* $Header: FAXVRC3B.pls 120.4.12010000.2 2009/07/19 11:15:17 glchen ship $ */

/*===================================================================================+
| FUNCTION Validate_Rule_Changes						     |
+====================================================================================*/

FUNCTION Validate_Rule_Changes(
        p_asset_id              IN      NUMBER,
        p_new_category_id       IN      NUMBER,
        p_book_type_code        IN      VARCHAR2,
        p_amortize_flag         IN      VARCHAR2,
        p_old_rules             IN 	FA_LOAD_TBL_PKG.asset_deprn_info,
        p_new_rules             IN   	FA_LOAD_TBL_PKG.asset_deprn_info,
	x_prorate_date	 OUT NOCOPY DATE,
        x_rate_source_rule      OUT NOCOPY     VARCHAR2,
        x_deprn_basis_rule      OUT NOCOPY     VARCHAR2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)	RETURN BOOLEAN IS
BEGIN
    ---- Validate each new depreciation rule ----

    /* Validate new depreciation ceiling. */
    IF NOT Validate_Ceiling(
		p_asset_id		=> p_asset_id,
		p_book_type_code 	=> p_book_type_code,
		p_old_ceiling_name	=> p_old_rules.ceiling_name,
		p_new_ceiling_name	=> p_new_rules.ceiling_name,
                p_log_level_rec         => p_log_level_rec)
    THEN
	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG3.Validate_Rule_Changes', p_log_level_rec => p_log_level_rec);
	RETURN (FALSE);
    END IF;

    /* Validate new depreciation flag. */
/*  Skip this check -- we will not change depreciate flag through mass reclass.
    IF NOT Validate_Deprn_Flag(
		p_old_rules		=> p_old_rules,
		p_new_rules		=> p_new_rules)
    THEN
	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG3.Validate_Rule_Changes', p_log_level_rec => p_log_level_rec);
	RETURN (FALSE);
    END IF;
*/

    /* Validate new prorate convention. */
    IF NOT Validate_Convention(
		p_asset_id		=> p_asset_id,
		p_book_type_code	=> p_book_type_code,
		p_date_placed_in_service => p_old_rules.start_dpis,
		p_old_conv		=> p_old_rules.prorate_conv_code,
		p_new_conv		=> p_new_rules.prorate_conv_code,
		p_amortize_flag 	=> p_amortize_flag,
		x_prorate_date		=> x_prorate_date,
                p_log_level_rec         => p_log_level_rec)
    THEN
	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG3.Validate_Rule_Changes', p_log_level_rec => p_log_level_rec);
	RETURN (FALSE);
    END IF;

    /* Validate new depreciation method. */
    -- p_old_rules.start_dpis and end_dpis store the current date placed in
    -- service for the asset.
    IF NOT Validate_Deprn_Method(
		p_asset_id		=> p_asset_id,
		p_book_type_code	=> p_book_type_code,
		p_old_deprn_method 	=> p_old_rules.deprn_method,
		p_new_deprn_method	=> p_new_rules.deprn_method,
		p_new_category_id	=> p_new_category_id,
                x_rate_source_rule      => x_rate_source_rule,
                x_deprn_basis_rule      => x_deprn_basis_rule,
                p_log_level_rec         => p_log_level_rec
		)
    THEN
	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG3.Validate_Rule_Changes', p_log_level_rec => p_log_level_rec);
	RETURN (FALSE);
    END IF;

    /* Validate new life and rates. */
    IF NOT Validate_Life_Rates(
		p_deprn_method		=> p_new_rules.deprn_method,
		p_basic_rate		=> p_new_rules.basic_rate,
		p_adjusted_rate		=> p_new_rules.adjusted_rate,
		p_life_in_months	=> p_new_rules.life_in_months,
                p_log_level_rec         => p_log_level_rec)
    THEN
	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG3.Validate_Rule_Changes', p_log_level_rec => p_log_level_rec);
	RETURN (FALSE);
    END IF;

    RETURN (TRUE);
EXCEPTION
    WHEN OTHERS THEN
        FA_SRVR_MSG.Add_SQL_Error(
                CALLING_FN =>  'FA_REC_PVT_PKG3.Validate_Rule_Changes', p_log_level_rec => p_log_level_rec);
        RETURN (FALSE);
END Validate_Rule_Changes;


/*===================================================================================+
| FUNCTION Validate_Ceiling							     |
+====================================================================================*/

FUNCTION Validate_Ceiling(
        p_asset_id              IN      NUMBER,
        p_book_type_code        IN      VARCHAR2,
        p_old_ceiling_name      IN      VARCHAR2,
	p_new_ceiling_name	IN	VARCHAR2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)       RETURN BOOLEAN IS
	l_book_class		VARCHAR2(15);
	l_allow_cost_ceil	VARCHAR2(3);
	l_allow_deprn_exp_ceil  VARCHAR2(3);
	l_cost			NUMBER;
	l_itc_amount_id		NUMBER(15);
	l_new_ceiling_type	VARCHAR2(30);
	CURSOR get_book_info IS
	    SELECT book_class, allow_cost_ceiling, allow_deprn_exp_ceiling
	    FROM FA_BOOK_CONTROLS
    	    WHERE book_type_code = p_book_type_code;
	CURSOR get_ceiling_type IS
	    SELECT ceiling_type FROM FA_CEILING_TYPES
    	    WHERE ceiling_name = p_new_ceiling_name;
	CURSOR get_cost_itc IS
	    SELECT cost, itc_amount_id FROM FA_BOOKS
    	    WHERE asset_id = p_asset_id and book_type_code = p_book_type_code
    	    AND date_ineffective IS NULL;
BEGIN
    -- Skip validation if rule remains the same or if new ceiling name
    -- is null.
    IF (nvl(p_old_ceiling_name, 'NULL')
		= nvl(p_new_ceiling_name, 'NULL') OR
	p_new_ceiling_name IS NULL) THEN
	RETURN (TRUE);
    END IF;

    OPEN get_book_info;
    FETCH get_book_info INTO l_book_class, l_allow_cost_ceil, l_allow_deprn_exp_ceil;
    CLOSE get_book_info;

    OPEN get_ceiling_type;
    FETCH get_ceiling_type INTO l_new_ceiling_type;
    CLOSE get_ceiling_type;

    OPEN get_cost_itc;
    FETCH get_cost_itc INTO l_cost, l_itc_amount_id;
    CLOSE get_cost_itc;

    IF (l_book_class IN ('BUDGET', 'CORPORATE') OR
        l_cost <= 0) THEN
	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG3.Validate_Ceiling',
		NAME => 'FA_REC_CANNOT_SET_CEIL', p_log_level_rec => p_log_level_rec);
		/* Message text: 'You cannot set a depreciation ceiling for
		   an asset in a corporate or budget book or an asset with a
		   negative or zero cost.' */
	RETURN (FALSE);
    END IF;

    IF (l_new_ceiling_type = 'RECOVERABLE COST CEILING') THEN
	IF (l_allow_cost_ceil = 'NO') THEN
	    FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG3.Validate_Ceiling',
		NAME => 'FA_REC_NO_COST_CEIL', p_log_level_rec => p_log_level_rec);
		/* Message text:
		   'Cost ceiling is not allowed in this book.' */
	    RETURN (FALSE);
	END IF;
    ELSIF (l_new_ceiling_type = 'DEPRN EXPENSE CEILING') THEN
	IF (l_allow_deprn_exp_ceil = 'NO') THEN
	    FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG3.Validate_Ceiling',
		NAME => 'FA_REC_NO_DEPRN_EXP_CEIL', p_log_level_rec => p_log_level_rec);
		/* Message text:
		   'Depreciation expense ceiling is not allowed in this book.' */
	    RETURN (FALSE);
	END IF;
    END IF;

    /* You can use either a depreciation cost ceiling or ITC for an asset,
       but not both. */
    IF (l_itc_amount_id IS NOT NULL AND
	l_new_ceiling_type = 'RECOVERABLE COST CEILING') THEN
	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG3.Validate_Ceiling',
		NAME => 'FA_BOOK_CANT_ITC_AND_COST_CEIL', p_log_level_rec => p_log_level_rec);
	RETURN (FALSE);
    END IF;

    RETURN (TRUE);
EXCEPTION
    WHEN OTHERS THEN
        FA_SRVR_MSG.Add_SQL_Error(
                CALLING_FN =>  'FA_REC_PVT_PKG3.Validate_Ceiling', p_log_level_rec => p_log_level_rec);
        RETURN (FALSE);
END Validate_Ceiling;


/*===================================================================================+
| FUNCTION Validate_Deprn_Flag							     |
+====================================================================================*/

FUNCTION Validate_Deprn_Flag(
        p_old_rules             IN      FA_LOAD_TBL_PKG.asset_deprn_info,
        p_new_rules             IN      FA_LOAD_TBL_PKG.asset_deprn_info
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)       RETURN BOOLEAN IS
	CURSOR chk_deprn_flag IS
	    SELECT 'N'
	    FROM FA_METHODS mth
	    WHERE mth.method_code = p_old_rules.deprn_method
	    AND mth.rate_source_rule = 'PRODUCTION';
	check_flag	VARCHAR2(3);
BEGIN
    -- Skip validation if rule remains the same.
    IF (p_old_rules.depreciate_flag = p_new_rules.depreciate_flag) THEN
	RETURN (TRUE);
    END IF;

    /* Other depreciation rules must remain the same, when changing the
       Depreciate flag. */
    IF NOT ((p_old_rules.prorate_conv_code = p_new_rules.prorate_conv_code) AND
            (p_old_rules.deprn_method = p_new_rules.deprn_method) AND
            (nvl(p_old_rules.life_in_months, 99999) =
                        nvl(p_new_rules.life_in_months, 99999)) AND
            (nvl(p_old_rules.basic_rate, 99999) =
                        nvl(p_new_rules.basic_rate, 99999)) AND
            (nvl(p_old_rules.adjusted_rate, 99999) =
                        nvl(p_new_rules.adjusted_rate, 99999)) AND
            (nvl(p_old_rules.production_capacity, 99999) =
                        nvl(p_new_rules.production_capacity, 99999)) AND
            (nvl(p_old_rules.unit_of_measure, 99999) =
                        nvl(p_new_rules.unit_of_measure, 99999)) AND
            (nvl(p_old_rules.bonus_rule, 'NULL') =
                        nvl(p_new_rules.bonus_rule, 'NULL')) AND
            (nvl(p_old_rules.ceiling_name, 'NULL') =
                        nvl(p_new_rules.ceiling_name, 'NULL')) AND
            (nvl(p_old_rules.allow_deprn_limit, 99) =
                        nvl(p_new_rules.allow_deprn_limit, 99)) AND
            (nvl(to_char(p_old_rules.deprn_limit_amount), 'NULL') =
                        nvl(to_char(p_new_rules.deprn_limit_amount), 'NULL')) AND
            (nvl(p_old_rules.percent_salvage_value, 99) =
                        nvl(p_new_rules.percent_salvage_value, 99)))
    THEN
	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG3.Validate_Deprn_Flag',
		NAME => 'FA_REC_NO_MULTIPLE_CHANGES', p_log_level_rec => p_log_level_rec);
		/* Message text: 'You cannot make more than one adjustment
		   upon changing the Depreciate flag.' */
	RETURN (FALSE);
    ELSE /* Other depreciation rules remain the same. */
	/* You cannot set Depreciate flag to No for units of production
	   assets. */
	IF (p_old_rules.depreciate_flag = 'YES' AND
	    p_new_rules.depreciate_flag = 'NO') THEN
	    OPEN chk_deprn_flag;
	    FETCH chk_deprn_flag INTO check_flag;
	    IF (chk_deprn_flag%found) THEN
		CLOSE chk_deprn_flag;
		FA_SRVR_MSG.Add_Message(
			CALLING_FN => 'FA_REC_PVT_PKG3.Validate_Deprn_Flag',
			NAME => 'FA_BOOK_INVALID_DEPRN_FLAG', p_log_level_rec => p_log_level_rec);
	 	RETURN (FALSE);
	    END IF;
	    CLOSE chk_deprn_flag;
	END IF;
    END IF;

    RETURN (TRUE);
EXCEPTION
    WHEN OTHERS THEN
        FA_SRVR_MSG.Add_SQL_Error(
                CALLING_FN =>  'FA_REC_PVT_PKG3.Validate_Deprn_Flag', p_log_level_rec => p_log_level_rec);
        RETURN (FALSE);
END Validate_Deprn_Flag;


/*===================================================================================+
| FUNCTION Validate_Convention							     |
+====================================================================================*/

FUNCTION Validate_Convention(
        p_asset_id              IN      NUMBER,
        p_book_type_code        IN      VARCHAR2,
	p_date_placed_in_service IN	DATE,
        p_old_conv              IN      VARCHAR2,
        p_new_conv              IN      VARCHAR2,
        p_amortize_flag         IN      VARCHAR2,
	x_prorate_date	 OUT NOCOPY DATE
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)       RETURN BOOLEAN IS
	l_dpis			DATE;
	l_prorate_date		DATE;
	check_flag		VARCHAR2(3);
	CURSOR get_prorate_date IS
	    SELECT conv.prorate_date
	    FROM FA_CONVENTIONS conv
	    WHERE conv.prorate_convention_code = p_new_conv
	    AND p_date_placed_in_service between conv.start_date and conv.end_date;
	CURSOR check_prorate_date IS
	    SELECT 'x'
	    FROM FA_CALENDAR_PERIODS cp, FA_BOOK_CONTROLS bc
	    WHERE bc.book_type_code = p_book_type_code
	    AND bc.prorate_calendar = cp.calendar_type
	    AND l_prorate_date between cp.start_date and cp.end_date;
BEGIN

    /* Get the prorate date.  This will be used in Do_Redefault(). */
    OPEN get_prorate_date;
    FETCH get_prorate_date INTO l_prorate_date;
    IF (get_prorate_date%notfound) THEN
	CLOSE get_prorate_date;
	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG3.Validate_Convention',
	 	NAME => 'FA_BOOK_CANT_GEN_PRORATE_DATE', p_log_level_rec => p_log_level_rec);
	RETURN (FALSE);
    END IF;
    CLOSE get_prorate_date;

    x_prorate_date := l_prorate_date;

    -- Skip the rest of the validations if rule remains the same.
    IF (p_old_conv = p_new_conv) THEN
	RETURN (TRUE);
    END IF;

    /* Cannot amortize a prorate convention adjustment. */
-- Bug 1111642
--    IF (p_amortize_flag = 'YES') THEN
--	FA_SRVR_MSG.Add_Message(
--		CALLING_FN => 'FA_REC_PVT_PKG3.Validate_Convention',
--		NAME => 'FA_CANNOT_AMORTIZE_PRORATE_CHE', p_log_level_rec => p_log_level_rec);
--	RETURN (FALSE);
--    END IF;

    /* Check if the new prorate date is valid. */
    OPEN check_prorate_date;
    FETCH check_prorate_date INTO check_flag;
    IF (check_prorate_date%notfound) THEN
	CLOSE check_prorate_date;
	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG3.Validate_Convention',
	 	NAME => 'FA_BKS_INVALID_PRORATE_DATE', p_log_level_rec => p_log_level_rec);
	RETURN (FALSE);
    END IF;
    CLOSE check_prorate_date;

    RETURN (TRUE);
EXCEPTION
    WHEN OTHERS THEN
        FA_SRVR_MSG.Add_SQL_Error(
                CALLING_FN =>  'FA_REC_PVT_PKG3.Validate_Convention', p_log_level_rec => p_log_level_rec);
        RETURN (FALSE);
END Validate_Convention;


/*===================================================================================+
| FUNCTION Validate_Deprn_Method						     |
+====================================================================================*/

FUNCTION Validate_Deprn_Method(
        p_asset_id              IN      NUMBER,
        p_book_type_code        IN      VARCHAR2,
        p_old_deprn_method      IN      VARCHAR2,
        p_new_deprn_method      IN      VARCHAR2,
        p_new_category_id       IN      NUMBER,
        x_rate_source_rule      OUT NOCOPY     VARCHAR2,
        x_deprn_basis_rule      OUT NOCOPY     VARCHAR2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)       RETURN BOOLEAN IS
	l_new_rate_src_rule	VARCHAR2(10);
	l_new_deprn_basis_rule	VARCHAR2(4);
	l_itc_amount_id		NUMBER(15);
	l_conversion_date	DATE;
	l_depreciation_check	VARCHAR2(3) := 'N';
		-- Indicates whether depreciation has already been run
		-- on the asset or not.
	l_book_class		VARCHAR2(15);
	l_count			NUMBER := 0;
	check_flag		VARCHAR2(3);
	CURSOR check_method IS
	    SELECT 'N'
  	    FROM FA_METHODS mth
	    WHERE l_depreciation_check = 'Y'
	    AND p_old_deprn_method = mth.method_code
	    AND mth.rate_source_rule <> 'PRODUCTION'
	    AND l_new_rate_src_rule = 'PRODUCTION';
	CURSOR check_tax_book_method IS
	    SELECT 'x'
	    FROM FA_METHODS mth, FA_CATEGORY_BOOK_DEFAULTS cbd,
		 FA_BOOK_CONTROLS bc, FA_BOOKS bk
	    WHERE bc.distribution_source_book = p_book_type_code
	    AND bc.book_class = 'TAX'
	    AND bk.book_type_code = bc.book_type_code
	    AND bk.asset_id = p_asset_id
	    AND bk.date_ineffective IS NULL
	    AND bk.book_type_code = cbd.book_type_code
	    AND cbd.category_id = p_new_category_id
	    AND bk.date_placed_in_service between cbd.start_dpis
		and nvl(cbd.end_dpis, to_date('31-12-4712', 'DD-MM-YYYY'))
	    AND cbd.deprn_method = mth.method_code
	    AND mth.rate_source_rule = 'PRODUCTION'
	    AND l_new_rate_src_rule <> 'PRODUCTION';
	CURSOR check_corp_book_method IS
	    SELECT 'x'
	    FROM FA_METHODS corp_mth, FA_CATEGORY_BOOK_DEFAULTS cbd,
		 FA_BOOK_CONTROLS bc, FA_BOOKS bk
	    WHERE bc.book_type_code = p_book_type_code
	    AND bk.book_type_code = bc.distribution_source_book
	    AND bk.asset_id = p_asset_id
	    AND bk.date_ineffective IS NULL
	    AND bk.book_type_code = cbd.book_type_code
	    AND cbd.category_id = p_new_category_id
	    AND bk.date_placed_in_service between cbd.start_dpis
		and nvl(cbd.end_dpis, to_date('31-12-4712', 'DD-MM-YYYY'))
	    AND cbd.deprn_method = corp_mth.method_code
	    AND corp_mth.rate_source_rule <> 'PRODUCTION'
	    AND l_new_rate_src_rule = 'PRODUCTION';
	CURSOR get_rate_deprn_rules IS
	    SELECT rate_source_rule, deprn_basis_rule
    	    FROM FA_METHODS
    	    WHERE method_code = p_new_deprn_method;
        /* cursor to get a book row for an asset */
        CURSOR get_book_info IS
            SELECT itc_amount_id, conversion_date
            FROM FA_BOOKS
            WHERE asset_id = p_asset_id AND book_type_code = p_book_type_code
            AND date_ineffective IS NULL;
	CURSOR get_book_class IS
	    SELECT book_class FROM FA_BOOK_CONTROLS
    	    WHERE book_type_code = p_book_type_code;
        /* cursor to validate depreciation method change for a
	   short-tax-year asset */
        CURSOR check_short_tax IS
            SELECT 'N'
            FROM FA_DEPRN_SUMMARY ds, FA_METHODS mth
            WHERE mth.method_code = p_old_deprn_method
            AND mth.rate_source_rule = 'FORMULA'
            AND ds.asset_id = p_asset_id
            AND ds.book_type_code = p_book_type_code
            AND ds.deprn_source_code = 'DEPRN' AND deprn_amount <> 0;
BEGIN
   -- If old_deprn_method is 'JP_STL_EXTND' then do not allow the method change
       IF (p_old_deprn_method = 'JP-STL-EXTND') THEN
	RETURN (FALSE);
       END IF;

    -- Get new rate source rule and depreciation basis rule for the new
    -- depreciation method.
    OPEN get_rate_deprn_rules;
    FETCH get_rate_deprn_rules INTO l_new_rate_src_rule, l_new_deprn_basis_rule;
    CLOSE get_rate_deprn_rules;

    x_rate_source_rule := l_new_rate_src_rule;
    x_deprn_basis_rule := l_new_deprn_basis_rule;

    -- Skip validation if rule remains the same.
    IF (p_old_deprn_method = p_new_deprn_method) THEN
	RETURN (TRUE);
    END IF;

    -- Get the asset's current book information.
    OPEN get_book_info;
    FETCH get_book_info INTO l_itc_amount_id, l_conversion_date;
    CLOSE get_book_info;

    -- Get the book class for the book being processed.
    OPEN get_book_class;
    FETCH get_book_class INTO l_book_class;
    CLOSE get_book_class;

    SELECT count(1) INTO l_count FROM FA_DEPRN_SUMMARY
    WHERE book_type_code = p_book_type_code AND asset_id = p_asset_id
    AND deprn_source_code = 'DEPRN' AND deprn_amount <> 0
    AND rownum < 2;

    IF (l_count > 0) THEN
	l_depreciation_check := 'Y'; -- Asset has already been depreciated.
    END IF;

    /* You can assign ITC to assets that use a life-based depreciation method
       only. */
    IF (l_new_deprn_basis_rule = 'NBV' AND
	l_new_rate_src_rule = 'FLAT' AND
	l_itc_amount_id IS NOT NULL) THEN
	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG3.Validate_Deprn_Method',
	 	NAME => 'FA_BOOK_INVALID_METHOD', p_log_level_rec => p_log_level_rec);
	RETURN (FALSE);
    END IF;

    /* You cannot change to a production method after you run depreciation. */
    OPEN check_method;
    FETCH check_method INTO check_flag;
    IF (check_method%found) THEN
	CLOSE check_method;
	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG3.Validate_Deprn_Method',
	 	NAME => 'FA_BOOK_NO_CHANGE_TO_PROD', p_log_level_rec => p_log_level_rec);
	RETURN (FALSE);
    END IF;
    CLOSE check_method;

    IF (l_book_class = 'CORPORATE') THEN
    /* Production method must be used in a corporate book, if a production
       method will be used in any of the associated tax books.
       Check the new depreciation methods for the corporate book and the
       associated tax books. */
	OPEN check_tax_book_method;
	FETCH check_tax_book_method INTO check_flag;
	IF (check_tax_book_method%found) THEN
	    CLOSE check_tax_book_method;
	    FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG3.Validate_Deprn_Method',
	 	NAME => 'FA_REC_MUST_USE_UOP', p_log_level_rec => p_log_level_rec);
	        /* Message text: 'Production method must be used in a
		   corporate book, if a production method will be used in
		   any of the associated tax books.' */
	    RETURN (FALSE);
        END IF;
	CLOSE check_tax_book_method;
    ELSE /* TAX book */
    /* Production method cannot be used in a tax book, if production method
       will not be used in its associated corporate book.
       Check the new depreciation methods for the corporate book and the
       associated tax books. */
	OPEN check_corp_book_method;
	FETCH check_corp_book_method INTO check_flag;
	IF (check_corp_book_method%found) THEN
	    CLOSE check_corp_book_method;
	    FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG3.Validate_Deprn_Method',
	 	NAME => 'FA_REC_CORP_NOT_UOP', p_log_level_rec => p_log_level_rec);
		/* Message text: 'Production method cannot be used in
		   a tax book, if production method will not be used in its
		   associated corporate book.' */
	    RETURN (FALSE);
        END IF;
	CLOSE check_corp_book_method;
    END IF;

    /* Depreciation method cannot be changed from a FORMULA method to
       a non-FORMULA method for a short-tax-year asset, if depreciation
       has already run. */
    IF (l_conversion_date IS NOT NULL AND
        l_new_rate_src_rule <> 'FORMULA') THEN
        /* If an asset is a short-tax-year asset and if the new method is
           not a FORMULA method
           -- Use conversion_date as a measure of whether an asset
           is a short-tax-year asset or not, since short_fiscal_year_flag
           can be 'NO' for short-tax-year assets, after the first fiscal
           year. */
        OPEN check_short_tax;
        FETCH check_short_tax INTO check_flag;
        IF (check_short_tax%found) THEN
        /* Old method was a FORMULA method, and asset has already depreciated,
           and therefore depreciation method change is disallowed. */
            CLOSE check_short_tax;
            FA_SRVR_MSG.Add_Message(
                CALLING_FN => 'FA_REC_PVT_PKG3.Validate_Deprn_Method',
                NAME => 'FA_SHORT_TAX_METHOD', p_log_level_rec => p_log_level_rec);
            /* New message:
                'Depreciation method cannot be changed from a formula-based
                 method to a non-formula-based method for an asset added in
                 a short fiscal year after depreciation has run.' */
            RETURN (FALSE);
        END IF;
        CLOSE check_short_tax;
    END IF;

    RETURN (TRUE);
EXCEPTION
    WHEN OTHERS THEN
        FA_SRVR_MSG.Add_SQL_Error(
                CALLING_FN =>  'FA_REC_PVT_PKG3.Validate_Deprn_Method', p_log_level_rec => p_log_level_rec);
        RETURN (FALSE);
END Validate_Deprn_Method;


/*===================================================================================+
| FUNCTION Validate_Life_Rates							     |
+====================================================================================*/

FUNCTION Validate_Life_Rates(
        p_deprn_method          IN      VARCHAR2,
        p_basic_rate            IN      NUMBER,
        p_adjusted_rate         IN      NUMBER,
        p_life_in_months        IN      NUMBER
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)       RETURN BOOLEAN IS
	check_flag		VARCHAR2(3);
	l_rate_src_rule		VARCHAR2(10);
	CURSOR check_rate IS
	    SELECT 'Y'
	    FROM FA_FLAT_RATES fr, FA_METHODS mth
	    WHERE mth.method_code = p_deprn_method
	    AND mth.life_in_months IS NULL
	    AND mth.method_id = fr.method_id
	    AND fr.basic_rate = p_basic_rate
	    AND fr.adjusted_rate = p_adjusted_rate;
	CURSOR check_life IS
	    SELECT 'Y'
	    FROM FA_METHODS mth
	    WHERE mth.method_code = p_deprn_method
	    AND nvl(mth.life_in_months, 99999) = p_life_in_months;
	CURSOR get_rate_src_rule IS
	    SELECT rate_source_rule FROM FA_METHODS
    	    WHERE method_code = p_deprn_method;
BEGIN
    -- Small validation unit.  Just validate without checking whehter
    -- change exists or not.

    -- Get new rate source rule for the new depreciation method.
    OPEN get_rate_src_rule;
    FETCH get_rate_src_rule INTO l_rate_src_rule;
    CLOSE get_rate_src_rule;

    IF (l_rate_src_rule = 'FLAT') THEN
	OPEN check_rate;
	FETCH check_rate INTO check_flag;
	IF (check_rate%notfound) THEN
	    CLOSE check_rate;
	    FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG3.Validate_Life_Rates',
	 	NAME => 'FA_SHARED_INVALID_METHOD_RATE', p_log_level_rec => p_log_level_rec);
	    RETURN (FALSE);
        END IF;
	CLOSE check_rate;
    ELSE
	IF (l_rate_src_rule <> 'PRODUCTION') THEN
	    OPEN check_life;
	    FETCH check_life INTO check_flag;
	    IF (check_life%notfound) THEN
	   	CLOSE check_life;
	 	FA_SRVR_MSG.Add_Message(
			CALLING_FN => 'FA_REC_PVT_PKG3.Validate_Life_Rates',
	 		NAME => 'FA_SHARED_INVALID_METHOD_LIFE', p_log_level_rec => p_log_level_rec);
	    	RETURN (FALSE);
            END IF;
	    CLOSE check_life;
	END IF;
    END IF;

    RETURN (TRUE);
EXCEPTION
    WHEN OTHERS THEN
        FA_SRVR_MSG.Add_SQL_Error(
                CALLING_FN =>  'FA_REC_PVT_PKG3.Validate_Life_Rates', p_log_level_rec => p_log_level_rec);
        RETURN (FALSE);
END Validate_Life_Rates;


END FA_REC_PVT_PKG3;

/
