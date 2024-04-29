--------------------------------------------------------
--  DDL for Package Body FA_REC_PVT_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_REC_PVT_PKG2" AS
/* $Header: FAXVRC2B.pls 120.3.12010000.3 2010/01/18 11:00:56 mswetha ship $ */

--
-- FUNCTION Validate_Redefault
--

FUNCTION Validate_Redefault(
        p_asset_id              IN      NUMBER,
        p_new_category_id       IN      NUMBER,
	p_book_type_code	IN	VARCHAR2,
	p_amortize_flag		IN	VARCHAR2 := 'NO',
	p_mr_req_id		IN	NUMBER := -1,
	x_rule_change_exists OUT NOCOPY BOOLEAN,
	x_old_rules	 OUT NOCOPY FA_LOAD_TBL_PKG.asset_deprn_info,
        x_new_rules             OUT NOCOPY  	FA_LOAD_TBL_PKG.asset_deprn_info,
        x_use_rules          OUT NOCOPY  	BOOLEAN,
	x_prorate_date	 OUT NOCOPY DATE,
        x_rate_source_rule      OUT NOCOPY     VARCHAR2,
        x_deprn_basis_rule      OUT NOCOPY     VARCHAR2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)       RETURN BOOLEAN IS
	l_old_rules		FA_LOAD_TBL_PKG.asset_deprn_info;
	l_new_rules		FA_LOAD_TBL_PKG.asset_deprn_info;
	l_found			BOOLEAN := FALSE;
	CURSOR get_old_rules IS
	    SELECT	book_type_code,
			date_placed_in_service, date_placed_in_service,
			prorate_convention_code, deprn_method_code,
	   		life_in_months, basic_rate, adjusted_rate,
	   		production_capacity, unit_of_measure,
			bonus_rule, NULL, ceiling_name,
	   		depreciate_flag, allowed_deprn_limit,
	   		allowed_deprn_limit_amount, percent_salvage_value
    	    FROM 	FA_BOOKS
   	    WHERE 	book_type_code = p_book_type_code
	    AND 	asset_id = p_asset_id
    	    AND		date_ineffective IS NULL;
BEGIN

    ---- Prepare for validations ----

    /* Get old(current) depreciation rules from the current books row. */
    OPEN get_old_rules;
    FETCH get_old_rules INTO l_old_rules;
    CLOSE get_old_rules;

    /* Get new depreciation rules. */
    FA_LOAD_TBL_PKG.Get_Deprn_Rules(
		p_book_type_code	=> p_book_type_code,
		p_date_placed_in_service => l_old_rules.start_dpis,
		x_deprn_rules_rec	=> l_new_rules,
		x_found			=> l_found, p_log_level_rec => p_log_level_rec);
    IF not l_found THEN
	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG2.Validate_Redefault',
		NAME => 'FA_REC_NO_CAT_DEFAULTS', p_log_level_rec => p_log_level_rec);
		/* Message text:
		   'The new category default depreciation rules do not
		    exist for this asset and its date placed in service.' */
	RETURN (FALSE);
    END IF;

    /* We will not redefault depreciate_flag through mass reclass. */
    l_new_rules.depreciate_flag := l_old_rules.depreciate_flag;

    /* See if any rule change is needed. */
    IF NOT ((l_old_rules.prorate_conv_code = l_new_rules.prorate_conv_code) AND
	    (l_old_rules.deprn_method = l_new_rules.deprn_method) AND
	    (nvl(l_old_rules.life_in_months, 99999) =
			nvl(l_new_rules.life_in_months, 99999)) AND
	    (nvl(l_old_rules.basic_rate, 99999) =
			nvl(l_new_rules.basic_rate, 99999)) AND
	    (nvl(l_old_rules.adjusted_rate, 99999) =
			nvl(l_new_rules.adjusted_rate, 99999)) AND
	    (nvl(l_old_rules.production_capacity, 99999) =
			nvl(l_new_rules.production_capacity, 99999)) AND
	    (nvl(l_old_rules.unit_of_measure, 99999) =
			nvl(l_new_rules.unit_of_measure, 99999)) AND
	    (nvl(l_old_rules.bonus_rule, 'NULL') =
			nvl(l_new_rules.bonus_rule, 'NULL')) AND
	    (nvl(l_old_rules.ceiling_name, 'NULL') =
			nvl(l_new_rules.ceiling_name, 'NULL')) AND
/* Skip this check -- we will not change depreciate flag through mass reclass.
	    (l_old_rules.depreciate_flag = l_new_rules.depreciate_flag) AND
*/
	    (nvl(l_old_rules.allow_deprn_limit, 99) =
			nvl(l_new_rules.allow_deprn_limit, 99)) AND
	    (nvl(to_char(l_old_rules.deprn_limit_amount), 'NULL') =
			nvl(to_char(l_new_rules.deprn_limit_amount), 'NULL')) AND
	    (nvl(l_old_rules.percent_salvage_value, 99) =
			nvl(l_new_rules.percent_salvage_value, 99)))
    THEN
	x_rule_change_exists := TRUE; -- At least one change is needed.
    ELSE
	x_rule_change_exists := FALSE;
	RETURN (TRUE);
	-- No rule change is needed.  Skip the validations.
    END IF;

    ---- Validations -----

    /* Validate an adjustment transaction. */
    IF NOT Validate_Adjustment(
        	p_asset_id              => p_asset_id,
		p_book_type_code	=> p_book_type_code,
		p_amortize_flag		=> p_amortize_flag,
		p_mr_req_id		=> p_mr_req_id,
                p_log_level_rec         => p_log_level_rec)
    THEN
	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG2.Validate_Redefault', p_log_level_rec => p_log_level_rec);
	RETURN (FALSE);
    END IF;

    /* Validate depreciation rule changes. */
    IF NOT FA_REC_PVT_PKG3.Validate_Rule_Changes(
		p_asset_id		=> p_asset_id,
		p_new_category_id	=> p_new_category_id,
		p_book_type_code	=> p_book_type_code,
		p_amortize_flag		=> p_amortize_flag,
		p_old_rules		=> l_old_rules,
		p_new_rules		=> l_new_rules,
		x_prorate_date		=> x_prorate_date,
                x_rate_source_rule      => x_rate_source_rule,
                x_deprn_basis_rule      => x_deprn_basis_rule,
                p_log_level_rec         => p_log_level_rec
		)
    THEN
	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG2.Validate_Redefault', p_log_level_rec => p_log_level_rec);
	RETURN (FALSE);
    END IF;

    x_old_rules := l_old_rules;
    x_new_rules := l_new_rules;
    x_use_rules := TRUE;
    RETURN (TRUE);
EXCEPTION
    WHEN OTHERS THEN
	x_use_rules := FALSE;
	FA_SRVR_MSG.Add_SQL_Error(
		CALLING_FN =>  'FA_REC_PVT_PKG2.Validate_Redefault', p_log_level_rec => p_log_level_rec);
	RETURN (FALSE);
END Validate_Redefault;


--
-- FUNCTION Validate_Adjustment
--

FUNCTION Validate_Adjustment(
        p_asset_id              IN      NUMBER,
	p_book_type_code	IN	VARCHAR2,
	p_amortize_flag		IN	VARCHAR2,
	p_mr_req_id		IN	NUMBER := -1
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)       RETURN BOOLEAN IS
	check_flag		VARCHAR2(3);
	prior_transaction_date	DATE;
	prior_date_effective    DATE;
	check_another_trans     NUMBER;
	CURSOR check_mass_change_allowed IS
	    SELECT 'x' FROM FA_BOOK_CONTROLS
	    WHERE book_type_code = p_book_type_code AND allow_mass_changes = 'NO'
	    AND p_mr_req_id <> -1;
	CURSOR check_prior_amort IS
	    SELECT 'x' FROM FA_BOOKS
	    WHERE book_type_code = p_book_type_code AND asset_id = p_asset_id
	    AND rate_adjustment_factor <> 1;
	CURSOR check_cip IS
	    SELECT 'x' FROM FA_ADDITIONS
	    WHERE asset_id = p_asset_id AND asset_type = 'CIP';
	CURSOR check_amort_allowed IS
	    SELECT 'x' FROM FA_BOOK_CONTROLS
	    WHERE book_type_code = p_book_type_code AND amortize_flag = 'NO';
	CURSOR check_deprn IS
	    SELECT 'x' FROM FA_DEPRN_SUMMARY
	    WHERE book_type_code = p_book_type_code AND asset_id = p_asset_id
	    AND deprn_source_code = 'DEPRN'; --Bug#8969958
BEGIN
    -- Check if mass change(adjustment) is allowed.
    OPEN check_mass_change_allowed;
    FETCH check_mass_change_allowed INTO check_flag;
    IF (check_mass_change_allowed%found) THEN
	CLOSE check_mass_change_allowed;
	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG2.Validate_Adjustment',
		NAME => 'FA_REC_MASSCHG_NOT_ALLOWED', p_log_level_rec => p_log_level_rec);
		/* Message text:
		   'You cannot use mass transaction to redefault depreciation rules
		    for the asset in this book because Allow Mass Changes field in the
		    Book Controls form is set to No. */
	RETURN (FALSE);
    END IF;
    CLOSE check_mass_change_allowed;

    ---- Checks for Expensed Adjustment ----

    /* Check if there were prior amortized adjustments, in case of expensed
       adjustment. */
    IF (p_amortize_flag = 'NO') THEN
    	OPEN check_prior_amort;
	FETCH check_prior_amort INTO check_flag;
	IF (check_prior_amort%found) THEN
	    CLOSE check_prior_amort;
	    FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG2.Validate_Adjustment',
		NAME => 'FA_BOOK_CANT_EXP_AFTER_AMORT', p_log_level_rec => p_log_level_rec);
	    RETURN (FALSE);
        END IF;
	CLOSE check_prior_amort;

    ---- Checks for Amortized Adjustment ----

    ELSE
	/* Check if an asset is a CIP asset.  CIP assets cannot be amortized.
           Rule from fa_fin_adj3_pkg.transaction_type(). */
   	OPEN check_cip;
	FETCH check_cip INTO check_flag;
	IF (check_cip%found) THEN
	    CLOSE check_cip;
	    FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG2.Validate_Adjustment',
		NAME => 'FA_REC_CIP_CANNOT_AMORT', p_log_level_rec => p_log_level_rec);
		/* Message text:
		   'You cannot amortize an adjustment for a CIP asset.' */
	    RETURN (FALSE);
        END IF;
	CLOSE check_cip;

	/* Check if amortization is allowed in this book. */
	OPEN check_amort_allowed;
	FETCH check_amort_allowed INTO check_flag;
	IF (check_amort_allowed%found) THEN
	    CLOSE check_amort_allowed;
	    FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG2.Validate_Adjustment',
		NAME => 'FA_BOOK_AMORTIZED_NOT_ALLOW', p_log_level_rec => p_log_level_rec);
	    RETURN (FALSE);
        END IF;
	CLOSE check_amort_allowed;

	/* Check if the asset has already been depreciated. */
	OPEN check_deprn;
	FETCH check_deprn INTO check_flag;
	IF (check_deprn%notfound) THEN
	    CLOSE check_deprn;
	    FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_REC_PVT_PKG2.Validate_Adjustment',
		NAME => 'FA_BOOK_CANT_AMORT_BEF_DEPRN', p_log_level_rec => p_log_level_rec);
	    RETURN (FALSE);
        END IF;
	CLOSE check_deprn;

    END IF;

    RETURN (TRUE);
EXCEPTION
    WHEN OTHERS THEN
        FA_SRVR_MSG.Add_SQL_Error(
                CALLING_FN =>  'FA_REC_PVT_PKG2.Validate_Adjustment', p_log_level_rec => p_log_level_rec);
        RETURN (FALSE);
END Validate_Adjustment;


END FA_REC_PVT_PKG2;

/
